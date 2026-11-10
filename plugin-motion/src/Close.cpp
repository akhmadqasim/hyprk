#include "Close.hpp"

#include <hyprland/src/desktop/state/Fadeout.hpp>
#include <hyprland/src/desktop/view/WLSurface.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/scene/SceneSelection.hpp>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <unordered_map>

using namespace Render;
using Desktop::View::CWindow;

namespace motion::close {
    namespace {
        HANDLE         g_handle     = nullptr;
        CFunctionHook* g_commitHook = nullptr;
        CFunctionHook* g_snapHook   = nullptr;
        CFunctionHook* g_fadeFbHook = nullptr;

        using commit_t = void (*)(CWLSurfaceResource*, SSurfaceState&);
        using snap_t   = SP<IFramebuffer> (*)(IHyprRenderer*, PHLWINDOW, eSceneMode);
        using fadeFb_t = SP<IFramebuffer> (*)(const Desktop::IFadeout*, eSceneMode);

        constexpr double BLUR_PT = 5.0;   // SLSTransactionSetWindowContentBlurRadius(f * 5), 0x18af87704

        // window -> snapshot taken just before its null-buffer commit
        struct SSnap {
            PHLWINDOWREF                          window;
            SP<IFramebuffer>                      fb;
            std::chrono::steady_clock::time_point at;
        };
        std::vector<SSnap> g_snaps;

        // fadeout -> blurred copy of its snapshot, rebuilt when the radius changes
        struct SBlur {
            SP<IFramebuffer>                      fb;
            double                                radius = -1;
            std::chrono::steady_clock::time_point used;
        };
        std::unordered_map<const Desktop::IFadeout*, SBlur> g_blurs;

        void purge() {
            const auto NOW = std::chrono::steady_clock::now();
            std::erase_if(g_snaps, [&](const SSnap& s) { return s.window.expired() || NOW - s.at > std::chrono::seconds(2); });
            std::erase_if(g_blurs, [&](const auto& kv) { return NOW - kv.second.used > std::chrono::seconds(2); });
        }

        // Hyprland unmaps an xdg toplevel only after the null buffer is committed, when the
        // surface texture is already gone, so its close snapshot has no client content
        // (protocols/XDGShell.cpp surfaceCommit). Take the snapshot one commit earlier.
        void hkCommitState(CWLSurfaceResource* self, SSurfaceState& state) {
            if (state.updated.bits.buffer && !state.buffer && self->m_mapped && self->m_current.texture) {
                const auto hl  = self->m_hlSurface.lock();
                const auto win = hl ? CWindow::fromView(hl->view()) : nullptr;
                if (win && win->mapped() && win->wlSurface() && win->wlSurface()->resource().get() == self) {
                    purge();
                    if (auto fb = rc<snap_t>(g_snapHook->m_original)(g_pHyprRenderer.get(), win, eSceneMode::MONITOR))
                        g_snaps.push_back(SSnap{.window = PHLWINDOWREF{win}, .fb = fb, .at = std::chrono::steady_clock::now()});
                }
            }
            rc<commit_t>(g_commitHook->m_original)(self, state);
        }

        SP<IFramebuffer> hkMakeSnapshotFB(IHyprRenderer* self, PHLWINDOW window, eSceneMode mode) {
            if (mode == eSceneMode::MONITOR) {
                const auto it = std::ranges::find_if(g_snaps, [&](const SSnap& s) { return s.window.lock() == window; });
                if (it != g_snaps.end()) {
                    auto fb = it->fb;
                    g_snaps.erase(it);
                    return fb;
                }
            }
            return rc<snap_t>(g_snapHook->m_original)(self, window, mode);
        }

        // 12 taps on two rings plus the centre, averaged by the 1/k "over" trick
        void drawBlurred(SP<ITexture> tex, SP<IFramebuffer> out, double radiusPx) {
            auto&                        ctx = g_pHyprRenderer->context();
            GL::CFramebufferBindingGuard bindings{g_pHyprRenderer->glBackend()};
            auto                         state = ctx.saveDrawState();
            const Vector2D               SIZE  = out->m_size;
            const CRegion                DAMAGE{0, 0, sc<int>(SIZE.x), sc<int>(SIZE.y)};
            g_pHyprRenderer->bindFB(ctx, out);
            ctx.m_data.damage = DAMAGE;
            ctx.m_data.fbSize = SIZE;
            ctx.m_data.renderModif = {};
            g_pHyprRenderer->setProjectionType(ctx, RPT_EXPORT);
            glClearColor(0, 0, 0, 0);
            glClear(GL_COLOR_BUFFER_BIT);

            std::vector<Vector2D> taps{{0, 0}};
            for (int i = 0; i < 8; ++i)
                taps.push_back(Vector2D{std::cos(i * M_PI / 4), std::sin(i * M_PI / 4)} * radiusPx);
            for (int i = 0; i < 4; ++i)
                taps.push_back(Vector2D{std::cos(M_PI / 4 + i * M_PI / 2), std::sin(M_PI / 4 + i * M_PI / 2)} * (radiusPx * 0.5));
            for (size_t k = 0; k < taps.size(); ++k)
                GL::g_pHyprOpenGL->renderTexture(ctx, tex, CBox{taps[k], SIZE},
                                                 GL::CHyprOpenGLImpl::STextureRenderData{.damage = &DAMAGE, .a = 1.F / sc<float>(k + 1), .allowDim = false});
        }

        SP<IFramebuffer> hkFadeoutFramebuffer(const Desktop::IFadeout* self, eSceneMode mode) {
            auto orig = rc<fadeFb_t>(g_fadeFbHook->m_original)(self, mode);
            if (mode != eSceneMode::MONITOR || !orig || !orig->getTexture() || self->source().type != Desktop::eFadeoutSource::WINDOW)
                return orig;
            const auto mon = self->monitor().lock();
            if (!mon)
                return orig;

            // AppKit drives alpha and blur with the same f: alpha = 1 - f, radius = 5 f
            const double radius = std::round(BLUR_PT * mon->m_scale * std::clamp(1.0 - self->alpha(), 0.0, 1.0) * 2) / 2;
            if (radius < 0.5)
                return orig;

            auto& b = g_blurs[self];
            b.used  = std::chrono::steady_clock::now();
            if (b.fb && b.radius == radius)
                return b.fb;
            if (!b.fb || b.fb->m_size != orig->m_size) {
                b.fb = g_pHyprRenderer->createFB("hyprkmotion close blur");
                if (!b.fb->alloc(orig->m_size.x, orig->m_size.y))
                    return orig;
            }
            drawBlurred(orig->getTexture(), b.fb, radius);
            b.radius = radius;
            return b.fb;
        }

        CFunctionHook* hook(const char* name, const char* demangled, void* fn) {
            for (const auto& m : HyprlandAPI::findFunctionsByName(g_handle, name)) {
                if (!m.demangled.contains(demangled))
                    continue;
                auto* h = HyprlandAPI::createFunctionHook(g_handle, m.address, fn);
                if (h && h->hook())
                    return h;
                if (h)
                    HyprlandAPI::removeFunctionHook(g_handle, h);
                return nullptr;
            }
            return nullptr;
        }
    }

    bool init(void* handle) {
        g_handle     = handle;
        g_snapHook   = hook("makeSnapshotFB", "makeSnapshotFB(Hyprutils::Memory::CSharedPointer<Desktop::View::CWindow>, Render::eSceneMode)", rc<void*>(&hkMakeSnapshotFB));
        g_commitHook = g_snapHook ? hook("commitState", "CWLSurfaceResource::commitState", rc<void*>(&hkCommitState)) : nullptr;
        g_fadeFbHook = hook("framebuffer", "IFadeout::framebuffer(Render::eSceneMode)", rc<void*>(&hkFadeoutFramebuffer));
        return g_snapHook && g_commitHook && g_fadeFbHook;
    }

    void exit() {
        for (auto* h : {g_commitHook, g_snapHook, g_fadeFbHook})
            if (h)
                HyprlandAPI::removeFunctionHook(g_handle, h);
        g_commitHook = g_snapHook = g_fadeFbHook = nullptr;
        g_snaps.clear();
        g_blurs.clear();
    }
}
