pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// "Apps" (Dock "Apps", Go > Applications, Spotlight "Show Apps", Cmd+F4). On macOS 27.2.1 it is not a window:
// `open -a Apps` shows Spotlight's Applications mode, an 844 x 520 panel under the search capsule drawn by the
// same process (MAC-ANSWERS.md Q-dock-23). So here it is Spotlight in mode "apps" (modules/spotlight/AppsPanel.qml);
// the first Esc returns to the plain "Search or Ask" bar, the second closes.
Singleton {
    id: root

    readonly property bool open: Panels.open === "spotlight" && SpotlightState.mode === "apps"
    function show() { SpotlightState.openIn("apps"); }
    function close() { if (open) Panels.close(); }
    function toggle() { if (open) Panels.close(); else show(); }

    // Hyprland binds: hl.dsp.global("hyprk:apps")
    GlobalShortcut { appid: "hyprk"; name: "apps"; description: "Applications"; onPressed: root.toggle() }

    // `qs -p shell ipc call apps toggle`
    IpcHandler {
        target: "apps"
        function toggle(): void { root.toggle(); }
        function open(): void { root.show(); }   // not "show": the qs ipc CLI takes that word itself
        function close(): void { root.close(); }
        function isOpen(): bool { return root.open; }
    }
}
