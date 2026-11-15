#include "ClientLights.hpp"
#include "Log.hpp"

#include <hyprland/src/config/ConfigValue.hpp>
#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/desktop/state/ViewState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/keybinds/Manager.hpp>
#include <hyprland/src/managers/SeatManager.hpp>
#include <hyprland/src/managers/SessionLockManager.hpp>
#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include <hyprutils/string/VarList.hpp>

#include <format>
#include <map>

namespace lg {

    namespace {
        // window class -> rect of its lights in the window's surface (logical px)
        std::map<std::string, CBox> g_rects;
        CFunctionHook*              g_hook = nullptr;

        using FnMouseDown = void (*)(void*, const IPointer::SButtonEvent&, SP<IPointer>);

        // a plain left press on the lights of a window that is not the focused one
        bool lightPress(const IPointer::SButtonEvent& e) {
            if (g_rects.empty() || e.state != WL_POINTER_BUTTON_STATE_PRESSED || e.button != 272 /* BTN_LEFT */)
                return false;
            // a modifier keeps Hyprland's path (Cmd-drag binds; Option-click on green is the client's and needs no focus)
            const auto mods = g_pInputManager->getModsFromAllKBs();
            if (bool(mods & Input::ModifierMask(Input::HL_MODIFIER_SHIFT)) || bool(mods & Input::ModifierMask(Input::HL_MODIFIER_CTRL)) ||
                bool(mods & Input::ModifierMask(Input::HL_MODIFIER_META)) || g_pInputManager->m_lastFocusOnLS || g_pSessionLockManager->isSessionLocked())
                return false;
            const auto pos = g_pInputManager->getMouseCoordsInternal();
            const auto w   = Desktop::viewState()->hitTest().windowAt(pos, Desktop::View::ALLOW_FLOATING | Desktop::View::RESERVED_EXTENTS | Desktop::View::INPUT_EXTENTS);
            if (!w || !w->mapped() || Desktop::focusState()->window() == w || Fullscreen::controller()->isFullscreen(w))
                return false;
            const auto it = g_rects.find(w->metadata().appID());
            if (it == g_rects.end())
                return false;
            // the window's own surface under the pointer (not a popup or a subsurface of it), in its coordinates
            Vector2D   local;
            const auto surface = Desktop::viewState()->hitTest().windowSurfaceAt(pos, w, local);
            return surface && surface == w->resource() && it->second.containsPoint(local);
        }

        // InputManager::processMouseDownNormal for a press on a client's light of a window that is not focused: what it
        // does with a click it passes on (the keybinds see it first; the client gets the button), without the refocus
        // and the raise. Everything else goes to Hyprland's own.
        void hkProcessMouseDownNormal(void* thisptr, const IPointer::SButtonEvent& e, SP<IPointer> mouse) {
            if (lightPress(e)) {
                static auto PPASSMOUSE = CConfigValue<Config::INTEGER>("binds:pass_mouse_when_bound");
                if (!Keybinds::mgr()->onMouseEvent(e, mouse) && !*PPASSMOUSE)
                    return;
                g_pSeatManager->sendPointerButton(e.timeMs, e.button, e.state);
                return;
            }
            reinterpret_cast<FnMouseDown>(g_hook->m_original)(thisptr, e, mouse);
        }
    }

    bool initClientLights(void* handle) {
        for (const auto& m : HyprlandAPI::findFunctionsByName(handle, "processMouseDownNormal")) {
            if (!m.demangled.contains("CInputManager::processMouseDownNormal"))
                continue;
            g_hook = HyprlandAPI::createFunctionHook(handle, m.address, reinterpret_cast<void*>(&hkProcessMouseDownNormal));
            if (g_hook && g_hook->hook())
                return true;
            if (g_hook)
                HyprlandAPI::removeFunctionHook(handle, g_hook);
            g_hook = nullptr;
            break;
        }
        logOnce("could not hook CInputManager::processMouseDownNormal: a press on a client's traffic light focuses its window");
        return false;
    }

    void exitClientLights(void* handle) {
        if (g_hook)
            HyprlandAPI::removeFunctionHook(handle, g_hook);
        g_hook = nullptr;
        g_rects.clear();
    }

    std::string clientLightsCommand(const std::string& args) {
        Hyprutils::String::CVarList a{args, 0, ' ', true};
        if (a.size() < 5)
            return "usage: liquidglass lights <class> <x> <y> <w> <h>\n";
        try {
            const CBox r{std::stod(a[1]), std::stod(a[2]), std::stod(a[3]), std::stod(a[4])};
            if (r.w <= 0 || r.h <= 0)
                g_rects.erase(a[0]);
            else
                g_rects[a[0]] = r;
        } catch (...) { return "lights: bad number\n"; }
        return std::format("lights {} {}\n", a[0], g_rects.contains(a[0]) ? "on" : "off");
    }
}
