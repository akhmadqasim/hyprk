#pragma once

#include <string>

// Traffic lights a client draws itself (Finder, System Settings: ui/HyprK/TrafficLights.qml). On the Mac a press on a
// light of an inactive window does not activate the app, and the window stays where it is in the stack (R6.4,
// windows/lights-inactive-press-dark.mov: TextEdit closed behind the key Calculator, which stayed frontmost;
// reference/re/27.2.1/LIGHTS-REA-27.2.1.md section 10). Hyprland focuses and raises the window under the pointer on any
// press (InputManager::processMouseDownNormal) before the client sees it. A client names the rect of its lights per
// window class (`hyprctl liquidglass lights <class> <x> <y> <w> <h>`, window-local logical px, w <= 0 removes it); a
// left press inside it on a window that is not focused then goes to the client without the refocus and the raise.
namespace lg {
    // installs the hook on CInputManager::processMouseDownNormal; false when Hyprland's symbol was not found
    bool initClientLights(void* handle);
    void exitClientLights(void* handle);
    // the `lights` part of the `liquidglass` hyprctl command: "<class> <x> <y> <w> <h>"
    std::string clientLightsCommand(const std::string& args);
}
