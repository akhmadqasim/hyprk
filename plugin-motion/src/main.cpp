// hyprk motion: macOS window motion Hyprland's animation config cannot express.
// Today: the Dock genie for minimize/restore (Dock.app WAGenieAnimation, SPEC.md 11.3).
// Minimize stays "move to special:minimized" (plugin/src/Titlebar.cpp); this plugin delays
// that move by the genie duration and warps the live window into the Dock meanwhile.
#include "GenieTransformer.hpp"

#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/desktop/state/ViewState.hpp>
#include <hyprland/src/desktop/view/LayerSurface.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowEffectsController.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/workspace/HLWorkspace.hpp>
#include <hyprland/src/render/transformer/TransformerList.hpp>
#include <hyprland/src/animation/AnimationManager.hpp>

#include <algorithm>
#include <chrono>
#include <format>
#include <optional>
#include <utility>

namespace {
    using namespace Config::Values;
    using Desktop::View::CWindow;

    HANDLE                           g_handle   = nullptr;
    CFunctionHook*                   g_moveHook = nullptr;
    std::vector<CHyprSignalListener> g_listeners;
    bool                             g_inOriginal = false;   // our own delayed call: let it through

    // The transformer is owned by the window's list (Hyprland may delete inactive ones at any
    // time), so it is looked up each tick instead of keeping a pointer.
    struct SAnim {
        PHLWINDOWREF                                         window;
        std::function<void()>                                onDone;    // the delayed minimize move (minimize only)
        std::optional<std::chrono::steady_clock::time_point> movedAt;   // when that move ran
    };
    std::vector<SAnim> g_anims;

    constexpr const char* MINIMIZED = "special:minimized";
    using origMove_t                = void (*)(void*, PHLWORKSPACE);

    bool isMinimized(const PHLWORKSPACE& ws) {
        return ws && ws->addressableName() == MINIMIZED;
    }

    // Dock target, monitor-local logical. The Dock is a full-width layer (hyprk-dock); macOS puts
    // minimized windows in the Dock's right section, which the shell does not report, so aim at the
    // middle of the bar: a 48 pt icon (64 pt tile inset by the Dock's 4 pt, 0x100053ca0) 12 pt above its bottom.
    motion::Rect dockTarget(const PHLMONITOR& mon) {
        const CBox m = mon->logicalBox();
        CBox       dock{m.x, m.y + m.h - 84, m.w, 84};
        for (const auto& ls : Desktop::viewState()->layers()) {
            if (ls && ls->m_namespace == "hyprk-dock" && ls->m_monitor == mon && !ls->m_geometry.empty()) {
                dock = ls->m_geometry;
                break;
            }
        }
        const double s = 48;
        return {dock.x + dock.w / 2 - s / 2 - m.x, dock.y + dock.h - 12 - s - m.y, s, s};
    }

    double genieSeconds() {
        static auto P = CConfigValue<Config::FLOAT>("plugin:hyprkmotion:genie_duration");
        return *P;
    }
    bool enabled() {
        static auto P = CConfigValue<Config::INTEGER>("plugin:hyprkmotion:genie");
        return *P != 0;
    }

    motion::CGenieTransformer* genieOf(const PHLWINDOW& w) {
        return w ? w->effects().transformers()->get<motion::CGenieTransformer>() : nullptr;
    }

    void removeGenie(const PHLWINDOW& w) {
        if (auto* g = genieOf(w)) {
            g->stop();
            w->effects().transformers()->removeInactive();
        }
    }

    enum class eEnd {
        NORMAL,   // time is up: run the pending move, keep the (empty) genie a moment longer
        NOW,      // another move or plugin exit: run the pending move, remove the genie at once
        DROP,     // the window closes: no move, remove at once
    };

    // The delayed minimize runs through the dispatcher (synchronous). Hyprland then fades the
    // window out of its old workspace for a moment; the genie, which draws nothing at p = 1,
    // stays 400 ms longer so no frame shows the plain window.
    void endAnim(SAnim& a, eEnd how) {
        if (auto cb = std::exchange(a.onDone, nullptr)) {
            a.movedAt = std::chrono::steady_clock::now();
            if (how != eEnd::DROP)
                cb();
        }
        const auto w = a.window.lock();
        if (how == eEnd::NORMAL && a.movedAt && w && std::chrono::steady_clock::now() - *a.movedAt < std::chrono::milliseconds(400))
            return;   // checked again next tick
        removeGenie(w);
        a.window.reset();
    }

    void finishFor(const PHLWINDOW& w, eEnd how) {
        for (size_t i = 0; i < g_anims.size(); ++i)   // index loop: the pending move re-enters the hook
            if (g_anims[i].window.lock() == w)
                endAnim(g_anims[i], how);
        std::erase_if(g_anims, [](const SAnim& a) { return a.window.expired(); });
    }

    void callOriginal(CWindow* self, PHLWORKSPACE ws) {
        g_inOriginal = true;
        rc<origMove_t>(g_moveHook->m_original)(self, ws);
        g_inOriginal = false;
    }

    void startGenie(const PHLWINDOW& w, bool reverse, std::function<void()> onDone) {
        const auto mon = w->m_monitor.lock();
        if (!mon) {
            if (onDone)
                onDone();
            return;
        }
        w->effects().transformers()->emplace<motion::CGenieTransformer>(w, dockTarget(mon), reverse, genieSeconds());
        g_anims.push_back(SAnim{.window = PHLWINDOWREF{w}, .onDone = std::move(onDone)});
        if (Animation::mgr())
            Animation::mgr()->requestTick();
    }

    void hkMoveToWorkspace(CWindow* self, PHLWORKSPACE ws) {
        const auto w = self ? self->m_self.lock() : nullptr;
        // no-op moves too: Hyprland repeats the call while laying out
        if (g_inOriginal || !w || !ws || !enabled() || !w->mapped() || genieSeconds() <= 0 || w->m_workspace == ws) {
            callOriginal(self, ws);
            return;
        }
        const auto from = w->m_workspace;
        // the same minimize again while its genie runs: the delayed move covers it
        if (isMinimized(ws) && std::ranges::any_of(g_anims, [&](const SAnim& a) { return a.onDone && a.window.lock() == w; }))
            return;
        finishFor(w, eEnd::NOW);   // any other move ends a genie in flight (its own delayed move runs first)

        if (isMinimized(ws) && from && !isMinimized(from) && from->visible()) {
            // minimize: genie first, then the real move (Reduce Motion users get it at once: genie = 0)
            // Hyprland drops the empty special workspace meanwhile, so the delayed move goes
            // through the dispatcher again (it recreates it), with the hook stepping aside
            const PHLWINDOWREF wref = w;
            startGenie(w, false, [wref] {
                const auto win = wref.lock();
                if (!win || !win->mapped())
                    return;
                g_inOriginal = true;
                HyprlandAPI::invokeHyprctlCommand(
                    "dispatch", std::format(R"(hl.dsp.window.move({{ workspace = "{}", window = "address:0x{:x}", follow = false }}))", MINIMIZED, rc<uintptr_t>(win.get())));
                g_inOriginal = false;
            });
            return;
        }

        callOriginal(self, ws);
        if (isMinimized(from) && !isMinimized(ws) && ws->visible()) {
            // restore: icon -> window at its final frame (no slide in from the special workspace)
            w->positionAnimation()->warp();
            w->sizeAnimation()->warp();
            startGenie(w, true, nullptr);
        }
    }

    void onTick() {
        if (g_anims.empty())
            return;
        for (auto& a : g_anims) {
            auto* g = genieOf(a.window.lock());
            if (!g || !g->tick())
                endAnim(a, eEnd::NORMAL);
        }
        std::erase_if(g_anims, [](const SAnim& a) { return a.window.expired(); });
        if (!g_anims.empty() && Animation::mgr())
            Animation::mgr()->requestTick();
    }

    void* findMoveToWorkspace() {
        for (const auto& m : HyprlandAPI::findFunctionsByName(g_handle, "moveToWorkspace"))
            if (m.demangled.contains("CWindow::moveToWorkspace"))
                return m.address;
        return nullptr;
    }
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    g_handle = handle;
    if (std::string{__hyprland_api_get_client_hash()} != __hyprland_api_get_hash()) {
        HyprlandAPI::addNotification(handle, "[hyprkmotion] built for another Hyprland, not loaded", CHyprColor{1.0, 0.3, 0.3, 1.0}, 6000);
        throw std::runtime_error("[hyprkmotion] version mismatch");
    }

    HyprlandAPI::addConfigValueV2(handle, makeShared<CIntValue>("plugin:hyprkmotion:genie", "Dock genie on minimize and restore", 1));
    HyprlandAPI::addConfigValueV2(handle, makeShared<CFloatValue>("plugin:hyprkmotion:genie_duration", "seconds (Dock genie-speed default 0.5)", 0.5F));

    if (void* addr = findMoveToWorkspace()) {
        g_moveHook = HyprlandAPI::createFunctionHook(handle, addr, rc<void*>(&hkMoveToWorkspace));
        if (g_moveHook && !g_moveHook->hook()) {
            HyprlandAPI::removeFunctionHook(handle, g_moveHook);
            g_moveHook = nullptr;
        }
    }
    if (!g_moveHook)
        HyprlandAPI::addNotification(handle, "[hyprkmotion] could not hook CWindow::moveToWorkspace, no genie", CHyprColor{1.0, 0.6, 0.2, 1.0}, 6000);

    g_listeners.push_back(Event::bus()->m_events.tick.listen([] { onTick(); }));
    g_listeners.push_back(Event::bus()->m_events.window.close.listen([](PHLWINDOW w) { finishFor(w, eEnd::DROP); }));

    return {"hyprkmotion", "macOS window motion: Dock genie minimize/restore", "hyprk", "0.1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    auto pending = std::move(g_anims);
    g_anims.clear();
    for (auto& a : pending)
        endAnim(a, eEnd::NOW);   // pending minimizes still happen; no transformer may outlive the .so
    g_listeners.clear();
    if (g_moveHook)
        HyprlandAPI::removeFunctionHook(g_handle, g_moveHook);
    g_moveHook = nullptr;
}
