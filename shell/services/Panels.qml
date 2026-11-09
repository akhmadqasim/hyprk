pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which transient surface is open. Only one at a time, like macOS.
// Values: "" | "menu" | "cc" | "nc" | "spotlight" | "launchpad" | "switcher"
Singleton {
    id: root

    property string open: ""
    property int menuIndex: -1          // index of the open menu bar title (0 = Apple)
    property real menuX: 0              // screen x of the open menu title

    function toggle(name) { open = open === name ? "" : name; }
    function close() { open = ""; menuIndex = -1; }
    function openMenu(index, x) { menuIndex = index; menuX = x; open = "menu"; }

    onOpenChanged: if (open !== "menu") menuIndex = -1

    // Hyprland binds call these via hl.dsp.global("hyprk:<name>")
    GlobalShortcut { appid: "hyprk"; name: "spotlight"; description: "Spotlight"; onPressed: root.toggle("spotlight") }
    GlobalShortcut { appid: "hyprk"; name: "launchpad"; description: "Apps"; onPressed: root.toggle("launchpad") }
    GlobalShortcut { appid: "hyprk"; name: "controlcenter"; description: "Control Center"; onPressed: root.toggle("cc") }
    GlobalShortcut { appid: "hyprk"; name: "notificationcenter"; description: "Notification Center"; onPressed: root.toggle("nc") }
    GlobalShortcut { appid: "hyprk"; name: "switcher"; description: "App switcher"; onPressed: root.open = "switcher" }

    // fallback entry points for scripts: `qs -p shell ipc call panels toggle spotlight`
    IpcHandler {
        target: "panels"
        function toggle(name: string): void { root.toggle(name); }
        function close(): void { root.close(); }
        function current(): string { return root.open; }
    }
}
