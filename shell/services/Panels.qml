pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/menus.js" as Menus

// Which transient surface is open. Only one at a time, like macOS.
// Values: "" | "menu" | "context" | "alert" | "cc" | "nc" | "spotlight" | "switcher" | "mission"
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
    // screen whose menu bar titles the pointer is over (MenuBar), or null: that screen's Overlay maps early, empty
    // and without input, so the click shows the menu in the same frame as the title pill (mapping it on the click
    // put the menu one frame behind the pill, mcap)
    property var warmScreen: null

    // Moving across the menu bar titles with a menu open (MAC-ANSWERS.md R2, 60 fps recording of the
    // 27.2.1 Finder): the title pill jumps to the new title in one frame, and the open menu is swapped
    // in one frame 3 to 4 frames (50 to 67 ms) later, with no crossfade. So the pill (MenuBar) follows
    // menuIndex at once and the dropdown (Overlay) draws menuShown, which follows menuIndex after
    // menuSwapDelay. A move while a swap is pending does not push it back, so the dropdown is never
    // more than that delay behind the pill. The first open shows both at once (one frame on the Mac).
    property int menuShown: -1          // menu the Overlay draws
    property real menuShownX: 0
    readonly property int menuSwapDelay: 58   // 3.5 frames at 60 Hz (measured 3 to 4)
    function showMenuNow() {
        menuShown = menuIndex;
        menuShownX = menuX;
    }
    function stepMenu() {
        if (open !== "menu" || menuIndex < 0) return;
        if (menuShown < 0) showMenuNow();
        else if (menuShown !== menuIndex && !menuSwap.running) menuSwap.start();
    }
    Timer { id: menuSwap; interval: root.menuSwapDelay; onTriggered: if (root.open === "menu" && root.menuIndex >= 0) root.showMenuNow() }
    onMenuIndexChanged: stepMenu()

    // Height of the band at the bottom of each screen (by name) that the Dock keeps visible, 0 when it hides:
    // Mission Control leaves it uncovered (the Dock stays visible there, MAC-ANSWERS.md Q-dock-27)
    property var dockZones: ({})
    function setDockZone(name, h) {
        if (dockZones[name] === h) return;
        const z = Object.assign({}, dockZones);
        z[name] = h;
        dockZones = z;
    }

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
    function openMenu(index, x, scr) { activeScreen = scr || screen; menuX = x; menuIndex = index; open = "menu"; }

    // Surfaces created on open (shell.qml LazyLoader) stay loaded while they dematerialize: closing
    // one holds it until its window releases it (ShellWindow.lingerAs), at most 1.5 s. The loaders
    // read only `loaded`, set here after `held`, so they never see a closed surface unheld.
    readonly property var lazySurfaces: ["spotlight", "switcher", "mission"]
    property var loaded: ({})           // name -> true while open or held
    property var held: ({})
    property string previous: ""
    function updateLoaded() {
        const l = {};
        for (const n of lazySurfaces) if (open === n || held[n]) l[n] = true;
        if (JSON.stringify(l) !== JSON.stringify(loaded)) loaded = l;   // menu hovers change `open` often
    }
    function release(name) {
        if (!held[name]) return;
        const h = Object.assign({}, held);
        delete h[name];
        held = h;
        updateLoaded();
    }
    Timer { id: holdTimeout; interval: 1500; onTriggered: { root.held = ({}); root.updateLoaded(); } }

    onOpenChanged: {
        if (open !== "menu") {
            menuIndex = -1;
            menuShown = -1;
            menuSwap.stop();
        } else stepMenu();
        if (previous !== open && lazySurfaces.indexOf(previous) !== -1) {
            held = Object.assign({}, held, { [previous]: true });
            holdTimeout.restart();
        }
        previous = open;
        updateLoaded();
    }

    // Hyprland binds call these via hl.dsp.global("hyprk:<name>")
    GlobalShortcut { appid: "hyprk"; name: "spotlight"; description: "Spotlight"; onPressed: root.toggle("spotlight") }
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
