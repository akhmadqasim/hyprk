#include "Minimize.hpp"

#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/config/values/ConfigValues.hpp>
#include <hyprland/src/desktop/state/ViewState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowBackend.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/eventLoop/EventLoopManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/workspace/HLWorkspace.hpp>
// CXDGToplevelResource keeps its xdg_toplevel resource private; the plugin only sends one more wm_capabilities event
// on it (same layout, no ABI change)
#define private public
#include <hyprland/src/protocols/XDGShell.hpp>
#undef private

#include <format>
#include <unordered_map>

namespace motion::minimize {
    namespace {
        using Desktop::View::CWindow;

        HANDLE                                             g_handle = nullptr;
        std::vector<CHyprSignalListener>                   g_listeners;
        std::unordered_map<CWindow*, CHyprSignalListener>  g_requests; // per window: its backend's state requests

        bool enabled() {
            static auto P = CConfigValue<Config::INTEGER>("plugin:hyprkmotion:client_minimize");
            return *P != 0;
        }

        // the window's xdg toplevel, if it is an xdg_shell window
        SP<CXDGToplevelResource> toplevelOf(const PHLWINDOW& w) {
            const auto surface = w->backend().surface();
            if (!surface || !surface->m_role || surface->m_role->role() != SURFACE_ROLE_XDG_SHELL)
                return nullptr;
            const auto xdg = sc<CXDGSurfaceRole*>(surface->m_role.get())->m_xdgSurface.lock();
            return xdg ? xdg->m_toplevel.lock() : nullptr;
        }

        // Hyprland's own list (XDGShell.cpp: FULLSCREEN, MAXIMIZE) plus MINIMIZE; clients apply it at the next configure
        void advertise(const PHLWINDOW& w) {
            const auto top = toplevelOf(w);
            if (!top || !top->m_resource || top->m_resource->version() < 5)
                return;
            wl_array arr;
            wl_array_init(&arr);
            for (const uint32_t cap : {XDG_TOPLEVEL_WM_CAPABILITIES_FULLSCREEN, XDG_TOPLEVEL_WM_CAPABILITIES_MAXIMIZE, XDG_TOPLEVEL_WM_CAPABILITIES_MINIMIZE})
                *sc<uint32_t*>(wl_array_add(&arr, sizeof(uint32_t))) = cap;
            top->m_resource->sendWmCapabilities(&arr);
            wl_array_release(&arr);
            // the toplevel's configure with its current states, then the surface's (as setActive does): an xdg_surface
            // configure alone leaves the client with empty states (GTK then drew itself inactive with its CSD shadow inset)
            top->scheduleStateApplication();
            if (const auto owner = top->m_owner.lock())
                owner->scheduleConfigure();
        }

        void minimize(const PHLWINDOWREF& ref) {
            const auto w = ref.lock();
            if (!w || !w->mapped() || (w->m_workspace && w->m_workspace->addressableName() == "special:minimized"))
                return;
            HyprlandAPI::invokeHyprctlCommand(
                "dispatch", std::format(R"(hl.dsp.window.move({{ workspace = "special:minimized", window = "address:0x{:x}", follow = false }}))", rc<uintptr_t>(w.get())));
        }

        void attach(const PHLWINDOW& w) {
            if (!w || g_requests.contains(w.get()))
                return;
            const PHLWINDOWREF ref = w;
            g_requests[w.get()]   = w->backend().m_events.stateRequest.listen([ref](const Desktop::View::SBackendStateRequest& r) {
                if (!enabled() || !r.minimized.value_or(false))
                    return;
                // not from inside the client's request: the move re-lays out and may configure the same toplevel
                g_pEventLoopManager->doLater([ref] { minimize(ref); });
            });
            if (enabled())
                advertise(w);
        }
    }

    void init(void* handle) {
        g_handle = handle;
        HyprlandAPI::addConfigValueV2(handle, makeShared<Config::Values::CIntValue>("plugin:hyprkmotion:client_minimize",
                                                                                    "honour client minimize requests (xdg set_minimized, X11 iconify)", 1));
        g_listeners.push_back(Event::bus()->m_events.window.open.listen([](PHLWINDOW w) { attach(w); }));
        g_listeners.push_back(Event::bus()->m_events.window.close.listen([](PHLWINDOW w) { g_requests.erase(w.get()); }));
        for (const auto& w : Desktop::viewState()->windows())
            if (w && w->mapped())
                attach(w);
    }

    void exit() {
        g_listeners.clear();
        g_requests.clear();
    }
}
