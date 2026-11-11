// the previous swapchain buffer is the only copy of the frame on screen: read-only access to the swapchain's ring
// (its own includes first, so only the swapchain class is opened)
#include <aquamarine/allocator/Allocator.hpp>
#define private public
#include <aquamarine/allocator/Swapchain.hpp>
#undef private

#include "AppearanceFade.hpp"
#include "Fade.hpp"
#include "Log.hpp"

#include <hyprland/src/managers/SessionLockManager.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderbuffer.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Texture.hpp>
#include <hyprland/src/render/gl/GLFramebuffer.hpp>
#include <hyprland/src/render/pass/TexPassElement.hpp>
#include <hyprland/src/state/MonitorState.hpp>
#include <GLES3/gl32.h>

#include <algorithm>
#include <chrono>
#include <format>
#include <map>

using namespace Render;
using namespace Render::GL;

namespace lg::appearancefade {
    namespace {
        using Clock = std::chrono::steady_clock;

        struct SFade {
            SP<IFramebuffer>  fb;
            Clock::time_point start;
            bool              pending = false; // snapshot not taken yet
            int               frames  = 0;
        };

        int                        g_appearance = -1; // the last frame's option (-1: none seen yet)
        Clock::time_point          g_switched;        // when the option last went light <-> dark
        std::string                g_ackSeen;         // the last appearance_ack value seen
        int                        g_ackAppearance = -1;
        Clock::time_point          g_ackAt;
        std::map<uintptr_t, SFade> g_fades;           // per monitor
        int                        g_runs = 0, g_lastFrames = 0;
        double                     g_lastSeconds = 0;

        bool locked() {
            return g_pSessionLockManager && g_pSessionLockManager->isSessionLocked();
        }

        // the frame on screen: the swapchain buffer acquired before the one this frame renders into
        SP<IFramebuffer> lastPresented(const PHLMONITOR& mon) {
            const auto sc = mon->m_output ? mon->m_output->swapchain : nullptr;
            if (!sc || sc->buffers.size() < 2)
                return nullptr;
            const size_t n    = sc->buffers.size();
            const auto   prev = sc->buffers[(size_t(sc->lastAcquired) + n - 1) % n];
            if (!prev)
                return nullptr;
            const auto rb = g_pHyprRenderer->getOrCreateRenderbuffer(prev, mon->m_output->state->state().drmFormat);
            return rb && rb->good() ? rb->getFB() : nullptr;
        }

        bool capture(const PHLMONITOR& mon, SFade& f) {
            const auto src = dynamicPointerCast<CGLFramebuffer>(lastPresented(mon));
            if (!src || mon->m_transform != WL_OUTPUT_TRANSFORM_NORMAL)
                return false;
            if (!f.fb)
                f.fb = g_pHyprRenderer->createFB("liquidglass-appearance");
            const auto size = mon->m_pixelSize;
            if (!f.fb->alloc(size.x, size.y, src->m_drmFormat))
                return false;
            const auto dst = dynamicPointerCast<CGLFramebuffer>(f.fb);
            if (!dst)
                return false;
            CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
            g_pHyprOpenGL->disableScissor();
            g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, src->getFBID());
            g_pHyprOpenGL->bindFramebuffer(GL_DRAW_FRAMEBUFFER, dst->getFBID());
            glBlitFramebuffer(0, 0, size.x, size.y, 0, 0, size.x, size.y, GL_COLOR_BUFFER_BIT, GL_NEAREST);
            return glGetError() == GL_NO_ERROR;
        }
    }

    // the handshake: the shell answers once every shown shell window has committed a frame in the new appearance
    // (config/hypr/hyprland.lua hyprk_appearance_ready -> appearance_ack "dark:<ms>"); a new value is noted with the
    // time it arrived
    static void noteAck(const SParams& p) {
        if (p.appearanceAck == g_ackSeen)
            return;
        g_ackSeen       = p.appearanceAck;
        g_ackAppearance = parseAppearance(p.appearanceAck.substr(0, p.appearanceAck.find(':')));
        g_ackAt         = Clock::now();
    }

    static double holdFor(const SParams& p, Clock::time_point start) {
        // an answer for this appearance that came after the switch ends the hold (at once if it came before this
        // output's snapshot); without one the hold runs to appearance_hold
        if (g_ackAppearance == g_appearance && g_ackAppearance > 0 && g_ackAt >= g_switched)
            return std::clamp(std::chrono::duration<double>(g_ackAt - start).count(), 0.0, double(p.appearanceHold));
        return p.appearanceHold;
    }

    void begin(const PHLMONITOR& mon, CRenderContext&, const SParams& p) {
        if (!mon || !g_pHyprRenderer)
            return;
        noteAck(p);
        if (g_appearance != p.appearance) {
            g_switched = Clock::now();
            // light <-> dark only: not the first value after a load, not to or from "auto"
            const bool run = g_appearance > 0 && p.appearance > 0 && p.appearanceFade > 0 && !p.reduceMotion && !locked();
            g_appearance   = p.appearance;
            if (run) {
                ++g_runs;
                for (const auto& m : State::monitorState()->monitors()) {
                    auto& f   = g_fades[reinterpret_cast<uintptr_t>(m.get())];
                    f.pending = true; // each output at its own first frame after the switch
                    g_pHyprRenderer->damageMonitor(m);
                }
            }
        }
        const auto it = g_fades.find(reinterpret_cast<uintptr_t>(mon.get()));
        if (it == g_fades.end() || !it->second.pending)
            return;
        auto& f   = it->second;
        f.pending = false;
        f.frames  = 0;
        f.start   = Clock::now();
        if (!capture(mon, f))
            g_fades.erase(it); // no snapshot: the switch snaps on this output
    }

    void lastMoment(const PHLMONITOR& mon, CRenderContext& ctx, const SParams& p) {
        noteAck(p);
        const auto it = g_fades.find(reinterpret_cast<uintptr_t>(mon.get()));
        if (it == g_fades.end() || it->second.pending)
            return;
        auto&        f = it->second;
        const double t = std::chrono::duration<double>(Clock::now() - f.start).count();
        const double a = appearanceSnapshotAlpha(t, holdFor(p, f.start), p.appearanceFade);
        const auto   tex = f.fb ? f.fb->getTexture() : nullptr;
        // never over a lock surface: the snapshot shows the unlocked desktop
        if (a <= 0 || !tex || locked() || p.reduceMotion) {
            g_lastFrames  = f.frames;
            g_lastSeconds = t;
            g_fades.erase(it); // frees the snapshot
            g_pHyprRenderer->damageMonitor(mon);
            return;
        }
        ++f.frames;
        CTexPassElement::SRenderData data;
        data.tex = tex;
        data.box = CBox{0, 0, mon->m_pixelSize.x, mon->m_pixelSize.y};
        data.a   = float(a);
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(std::move(data)));
        g_pHyprRenderer->damageMonitor(mon); // the whole output again next frame, only while it runs
    }

    void clear() {
        g_fades.clear();
    }

    std::string status() {
        return std::format("appearance fade: {} running, {} run since load, last {} frames in {:.3f} s, last answer \"{}\"\n", g_fades.size(), g_runs,
                           g_lastFrames, g_lastSeconds, g_ackSeen);
    }
}
