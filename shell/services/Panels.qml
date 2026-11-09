pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/menus.js" as Menus

// Which transient surface is open. Only one at a time, like macOS.
// Values: "" | "menu" | "context" | "alert" | "cc" | "nc" | "spotlight" | "launchpad" | "switcher" | "mission"
Singleton {
    id: root

    // screen for transient surfaces: $HYPRK_PRIMARY (output name) or the first screen
    readonly property var screen: Quickshell.screens.find(s => s.name === Quickshell.env("HYPRK_PRIMARY")) || Quickshell.screens[0]

    property string open: ""
    // query handed to Spotlight when it opens (IPC `spotlight search`)
    property string spotlightQuery: ""
    // screen whose Overlay shows menus / context menus / CC / NC (menus open where they were clicked)
    property var activeScreen: screen
    property int menuIndex: -1          // index of the open menu bar title (0 = Apple)
    property real menuX: 0              // screen x of the open menu title

    // context menu (desktop, Dock): items as in lib/menus.js, action may be a function.
    // (contextX, contextY) is the screen point; with contextAbove the menu ends there (Dock).
    property var contextItems: []
    property real contextX: 0
    property real contextY: 0
    property bool contextAbove: false
    function openContext(items, x, y, above, scr) {
        activeScreen = scr || screen;
        contextItems = items;
        contextX = x;
        contextY = y;
        contextAbove = !!above;
        open = "context";
    }

    // alert dialog: { icon, title, message, buttons: [{ label, action, isDefault, isCancel }] }
    property var alert: null
    function showAlert(a) {
        activeScreen = screen;
        alert = a;
        open = "alert";
        Sounds.play("alert");
    }

    // open on scr; closes only when it is already open on that same screen
    function toggle(name, scr) {
        const target = scr || screen;
        if (open === name && activeScreen === target) {
            open = "";
            return;
        }
        activeScreen = target;
        open = name;
    }
    function close() { open = ""; menuIndex = -1; }
    function openMenu(index, x, scr) { activeScreen = scr || screen; menuIndex = index; menuX = x; open = "menu"; }

    onOpenChanged: if (open !== "menu") menuIndex = -1

    // Hyprland binds call these via hl.dsp.global("hyprk:<name>")
    GlobalShortcut { appid: "hyprk"; name: "spotlight"; description: "Spotlight"; onPressed: root.toggle("spotlight") }
    GlobalShortcut { appid: "hyprk"; name: "launchpad"; description: "Apps"; onPressed: root.toggle("launchpad") }
    GlobalShortcut { appid: "hyprk"; name: "controlcenter"; description: "Control Center"; onPressed: root.toggle("cc") }
    GlobalShortcut { appid: "hyprk"; name: "notificationcenter"; description: "Notification Center"; onPressed: root.toggle("nc") }
    GlobalShortcut { appid: "hyprk"; name: "switcher"; description: "App switcher"; onPressed: root.open = "switcher" }
    GlobalShortcut { appid: "hyprk"; name: "missioncontrol"; description: "Mission Control"; onPressed: root.toggle("mission") }

    // fallback entry points for scripts: `qs -p shell ipc call panels toggle spotlight`
    IpcHandler {
        target: "panels"
        function toggle(name: string): void { root.toggle(name); }
        function close(): void { root.close(); }
        function current(): string { return root.open; }
        function menu(index: int, x: int): void { root.openMenu(index, x); }
        function desktopMenu(x: int, y: int): void { root.openContext(Menus.desktop(), x, y, false); }
        function confirmEmptyTrash(): void { Apps.confirmEmptyTrash(); }
    }

    // `qs ipc call spotlight search "2+2"`: open Spotlight with a query (scripted screenshots)
    IpcHandler {
        target: "spotlight"
        function search(q: string): void {
            root.open = "spotlight";
            root.spotlightQuery = q;      // Spotlight picks it up on creation or live
        }
    }
}
