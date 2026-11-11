#include "FrameMotion.hpp"
#include "Frame.hpp"

#include <hyprland/src/animation/AnimationManager.hpp>
#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/shared/animation/AnimationTree.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/desktop/rule/windowRule/WindowRuleApplicator.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>

#include <chrono>
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
        HyprlandAPI::addConfigValueV2(handle, makeShared<Config::Values::CIntValue>("plugin:hyprkmotion:frames", "Mac unzoom and full screen enter/exit timing", 1));
        g_listeners.push_back(Event::bus()->m_events.window.fullscreen.listen([](PHLWINDOW w) { onFullscreen(w); }));
        g_listeners.push_back(Event::bus()->m_events.window.close.listen([](PHLWINDOW w) {
            finishFor(w);
            g_modes.erase(rc<uintptr_t>(w.get()));
        }));
    }

    void exit() {
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
