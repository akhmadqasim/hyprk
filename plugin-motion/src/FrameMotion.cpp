#include "FrameMotion.hpp"
#include "Frame.hpp"

#include <hyprland/src/animation/AnimationManager.hpp>
#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/shared/animation/AnimationTree.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/desktop/rule/windowRule/WindowRuleApplicator.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/desktop/state/WindowState.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/pass/RectPassElement.hpp>
#include <hyprland/src/plugins/HookSystem.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>
#include <hyprland/src/output/Monitor.hpp>

#include <chrono>
#include <cstdlib>
#include <string>
#include <optional>
#include <unordered_map>

using Hyprutils::Animation::SAnimationPropertyConfig;

namespace motion::frame {
    namespace {
        using clock = std::chrono::steady_clock;

        struct SRun {
            PHLWINDOWREF                 window;
            eKind                        kind;
            clock::time_point            start;
            SP<SAnimationPropertyConfig> config;
            Vector2D                     posGoal, sizeGoal;
        };

        std::vector<CHyprSignalListener>                            g_listeners;
        std::vector<SRun>                                           g_runs;
        std::unordered_map<uintptr_t, Fullscreen::eFullscreenMode> g_modes; // last internal mode seen per window

        bool enabled() {
            static auto P = CConfigValue<Config::INTEGER>("plugin:hyprkmotion:frames");
            return *P != 0;
        }

        SP<SAnimationPropertyConfig> moveConfig() {
            return Config::animationTree()->getAnimationPropertyConfig("windowsMove");
        }

        // hands the window back to windowsMove if its animations still run on our config
        void finish(SRun& r) {
            if (const auto w = r.window.lock()) {
                const auto mv = moveConfig();
                for (auto* av : {&w->positionAnimation(), &w->sizeAnimation()})
                    if (*av && (*av)->getConfig().lock() == r.config)
                        (*av)->setConfig(mv);
            }
            r.window.reset();
        }

        void finishFor(const PHLWINDOW& w) {
            for (auto& r : g_runs)
                if (r.window.lock() == w)
                    finish(r);
            std::erase_if(g_runs, [](const SRun& r) { return r.window.expired(); });
        }

        // Notched displays (MAC-ANSWERS Q-menubar-33): a full-screen window sits below the 34 pt bar strip (window
        // 0,34,1710,1073 on the Air), the strip stays black. `plugin:hyprkmotion:fullscreen_top` lists outputs and their
        // strip, "MBA:34"; other outputs keep true full screen. The layout sets a full-screen window's box over the whole
        // monitor (WindowTarget, setBox(monitor box)) after the fullscreen event and again on every relayout, so setBox is
        // hooked: a box that is exactly a listed monitor's, for a window in full screen, loses the strip at its top.
        double topInset(const PHLMONITOR& mon) {
            static auto P = CConfigValue<Config::STRING>("plugin:hyprkmotion:fullscreen_top");
            if (!mon)
                return 0;
            const std::string list = *P;
            size_t            i    = 0;
            while (i < list.size()) {
                const size_t end   = std::min(list.find(',', i), list.size());
                const auto   item  = list.substr(i, end - i);
                const size_t colon = item.rfind(':');
                if (colon != std::string::npos && item.substr(0, colon) == mon->m_name)
                    return std::atof(item.c_str() + colon + 1);
                i = end + 1;
            }
            return 0;
        }

        using setBox_t                = void (*)(Desktop::View::CGeometricMovableAnimated*, const CBox&);
        CFunctionHook* g_setBoxHook   = nullptr;
        HANDLE         g_handle       = nullptr;

        void hkSetBox(Desktop::View::CGeometricMovableAnimated* self, const CBox& box) {
            CBox out = box;
            for (const auto& w : Desktop::windowState()->windows()) {
                if (static_cast<Desktop::View::CGeometricMovableAnimated*>(w.get()) != self)
                    continue;
                const auto mon = w->m_monitor.lock();
                if (mon && box == mon->logicalBox() && Fullscreen::controller()->getFullscreenModes(w).internal == Fullscreen::FSMODE_FULLSCREEN)
                    if (const double inset = topInset(mon); inset > 0)
                        out = {box.x, box.y + inset, box.w, box.h - inset};
                break;
            }
            rc<setBox_t>(g_setBoxHook->m_original)(self, out);
        }

        // the strip itself: black under everything of the full-screen workspace (the wallpaper still draws there; the menu
        // bar is a top layer, which Hyprland hides over full screen). Overlay layers (HUD, Control Center) stay above.
        void blackStrip(const Event::SRenderStageEvent& e) {
            if (e.stage != RENDER_PRE_WINDOWS || !e.context || !e.monitor || !Fullscreen::controller()->hasFullscreen(e.monitor, true))
                return;
            const double inset = topInset(e.monitor);
            if (inset <= 0)
                return;
            CRectPassElement::SRectData data;
            data.box   = CBox{0, 0, e.monitor->m_transformedSize.x, inset * e.monitor->m_scale}.round();
            data.color = CHyprColor(0, 0, 0, 1);
            g_pHyprRenderer->addPassElement(e.context->get(), makeUnique<CRectPassElement>(data));
        }

        // Fired after the layout set the new goals (FullscreenController::setWindowFullscreenModeInternal), so the
        // position and size animations already run, on windowsMove; they continue on a private config.
        void onFullscreen(PHLWINDOW w) {
            if (!w)
                return;
            const auto key  = rc<uintptr_t>(w.get());
            const auto to   = Fullscreen::controller()->getFullscreenModes(w).internal;
            const auto from = g_modes.contains(key) ? g_modes[key] : Fullscreen::FSMODE_NONE;
            g_modes[key]    = to;
            finishFor(w);

            std::optional<eKind> kind;
            if (to == Fullscreen::FSMODE_FULLSCREEN && from != Fullscreen::FSMODE_FULLSCREEN)
                kind = eKind::FULLSCREEN_ENTER;
            else if (from == Fullscreen::FSMODE_FULLSCREEN && to != Fullscreen::FSMODE_FULLSCREEN)
                kind = eKind::FULLSCREEN_EXIT;
            else if (from == Fullscreen::FSMODE_MAXIMIZED && to == Fullscreen::FSMODE_NONE)
                kind = eKind::UNZOOM;
            // zoom (none -> maximized) keeps windowsMove: its bezier already matches the Mac (MOTION-MEASURED.md)

            // windowsMove off = Reduce Motion (hyprland.lua hyprk_motion): no motion at all, as before
            const auto mv = moveConfig();
            if (!kind || !enabled() || !mv || !mv->pValues || mv->pValues->internalEnabled == 0 || w->m_ruleApplicator->noAnim().valueOrDefault())
                return;
            auto& pos  = w->positionAnimation();
            auto& size = w->sizeAnimation();
            if (!pos || !size || (!pos->isBeingAnimated() && !size->isBeingAnimated()))
                return;

            auto cfg             = makeShared<SAnimationPropertyConfig>();
            cfg->internalBezier  = "linear";
            cfg->internalStyle   = "";
            cfg->internalEnabled = 1;
            cfg->internalSpeed   = float(hyprSpeed(0, 0));
            cfg->pValues         = cfg;
            pos->setConfig(cfg);
            size->setConfig(cfg);

            g_runs.push_back({.window = PHLWINDOWREF{w}, .kind = *kind, .start = clock::now(), .config = cfg, .posGoal = pos->goal(), .sizeGoal = size->goal()});
            if (Animation::mgr())
                Animation::mgr()->requestTick();
        }
    }

    void init(HANDLE handle) {
        g_handle = handle;
        for (const auto& m : HyprlandAPI::findFunctionsByName(handle, "setBox"))
            if (m.demangled.starts_with("Desktop::View::CGeometricMovableAnimated::setBox")) {
                g_setBoxHook = HyprlandAPI::createFunctionHook(handle, m.address, rc<void*>(&hkSetBox));
                if (g_setBoxHook && !g_setBoxHook->hook()) {
                    HyprlandAPI::removeFunctionHook(handle, g_setBoxHook);
                    g_setBoxHook = nullptr;
                }
                break;
            }
        HyprlandAPI::addConfigValueV2(handle, makeShared<Config::Values::CIntValue>("plugin:hyprkmotion:frames", "Mac unzoom and full screen enter/exit timing", 1));
        HyprlandAPI::addConfigValueV2(handle,
                                      makeShared<Config::Values::CStringValue>("plugin:hyprkmotion:fullscreen_top", "output:pt, full-screen windows keep that strip at the top (notch)",
                                                                               Config::STRING{""}));
        g_listeners.push_back(Event::bus()->m_events.window.fullscreen.listen([](PHLWINDOW w) { onFullscreen(w); }));
        g_listeners.push_back(Event::bus()->m_events.render.stage.listen([](const Event::SRenderStageEvent& e) { blackStrip(e); }));
        g_listeners.push_back(Event::bus()->m_events.window.close.listen([](PHLWINDOW w) {
            finishFor(w);
            g_modes.erase(rc<uintptr_t>(w.get()));
        }));
    }

    void exit() {
        if (g_setBoxHook)
            HyprlandAPI::removeFunctionHook(g_handle, g_setBoxHook);
        g_setBoxHook = nullptr;
        for (auto& r : g_runs)
            finish(r);
        g_runs.clear();
        g_listeners.clear();
        g_modes.clear();
    }

    // runs right after Hyprland's animation tick (about 1 kHz while anything animates): sets the speed the next tick
    // reads, so the shown share is at most ~1 ms behind the curve. No work when nothing runs.
    void tick() {
        if (g_runs.empty())
            return;
        const auto now = clock::now();
        for (auto& r : g_runs) {
            const auto w = r.window.lock();
            if (!w)
                continue;
            auto&      pos  = w->positionAnimation();
            auto&      size = w->sizeAnimation();
            const bool ours = pos && size && pos->getConfig().lock() == r.config && size->getConfig().lock() == r.config;
            // something else moved the window (a new goal, or windowsMove set back): hand it over
            if (!ours || pos->goal() != r.posGoal || size->goal() != r.sizeGoal) {
                finish(r);
                continue;
            }
            const double t          = std::chrono::duration<double>(now - r.start).count();
            r.config->internalSpeed = float(hyprSpeed(t * 1000.0, progress(r.kind, t)));
            if (t >= duration(r.kind) && !pos->isBeingAnimated() && !size->isBeingAnimated())
                finish(r);
        }
        std::erase_if(g_runs, [](const SRun& r) { return r.window.expired(); });
        if (!g_runs.empty() && Animation::mgr())
            Animation::mgr()->requestTick();
    }
}
