//@ pragma AppId org.hyprk.Settings
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "HyprK"

// Entry for Quickshell: `quickshell -p settings/` (full command backend).
// Env: HYPRK_SETTINGS_PANE=<pane id> opens a pane (HYPRK_SETTINGS_SUB=<id> its sub-pane), HYPRK_SNAPSHOT=<png> renders it
// (at the scroll offset HYPRK_SNAPSHOT_SCROLL) and quits.
ShellRoot {
    FloatingWindow {
        id: win
        title: "System Settings"
        implicitWidth: Theme.window.width
        implicitHeight: Theme.window.height
        minimumSize: Qt.size(Theme.window.minWidth, Theme.window.minHeight)
        color: "transparent"
        // icons are decoded and drawn on this window's real pixel grid (controls/PaneIcon.qml)
        Binding { target: Theme; property: "dpr"; value: win.devicePixelRatio }
        Binding { target: Tokens; property: "dpr"; value: win.devicePixelRatio }   // HyprK lines and textures (pixel.js)
        // the liquidglass plugin loaded (config/hypr/hyprland.lua exports HYPRK_GLASS=plugin) draws the menu glass behind
        // this window's popups (popup_classes lists org.hyprk.Settings): the text field menu draws no fill
        Binding { target: Tokens; property: "popupGlass"; value: Quickshell.env("HYPRK_GLASS") === "plugin" }

        // Emoji & Symbols (the shell's hyprk-emoji layer) opened over this window keeps it key-looking: the Mac's
        // character palette does not take the app's key window. The layer takes the keyboard, so Qt reports the window
        // inactive; Hyprland's active window stays this one, so it is checked when the layer maps (socket2 openlayer)
        property bool emojiOver: false
        // Mission Control picked this window (the shell's socket2 event custom>>hyprk-pick,<address>, sent at the
        // click): key look at once, as the Mac's picked window 2 frames into the exit, not when the focus comes 2
        // frames later (MOTION-REA Round 6 R6.1). Until another window is made active after it, or 1 s (focus refused)
        property bool picked: false
        property string pickedAddress: ""
        property bool pickedSeen: false
        Timer { id: pickTimeout; interval: 1000; onTriggered: win.picked = false }
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "custom" && event.data.startsWith("hyprk-pick,")) {
                    const a = event.data.slice(11).toLowerCase().replace(/^0x/, "");
                    const t = Hyprland.toplevels.values.find(w => String(w.address).toLowerCase().replace(/^0x/, "") === a);
                    win.picked = !!t && (t.wayland ? t.wayland.appId : (t.lastIpcObject["class"] || "")) === "org.hyprk.Settings";
                    win.pickedAddress = win.picked ? a : "";
                    win.pickedSeen = false;
                    if (win.picked) pickTimeout.restart();
                    return;
                }
                // the layer's keyboard release first refocuses the window key before Mission Control: only a change
                // after this window was active ends the pick
                if (event.name === "activewindowv2" && win.picked) {
                    if (event.data.toLowerCase().replace(/^0x/, "") === win.pickedAddress) win.pickedSeen = true;
                    else if (win.pickedSeen) win.picked = false;
                    return;
                }
                if (event.data !== "hyprk-emoji") return;
                if (event.name === "closelayer") { win.emojiOver = false; return; }
                if (event.name !== "openlayer") return;
                const t = Hyprland.activeToplevel;
                const appId = !t ? "" : t.wayland ? t.wayland.appId : (t.lastIpcObject["class"] || "");
                win.emojiOver = appId === "org.hyprk.Settings";
            }
        }

        // At a fractional scale the window takes the nearest size on whole device pixels (HyprK pixel.js whole: 625 pt
        // is 937.5 px at 1.5 and the compositor then resamples every row; 626 pt is drawn 1:1). Asked of Hyprland, which
        // sizes the window (settings/hyprland-rules.lua); 0.3 s after the last change, so a resize by hand is left alone
        // until it ends. Whole scales: nothing happens.
        Timer {
            id: fitPixels
            interval: 300
            onTriggered: {
                const r = win.devicePixelRatio;
                if (!Pixel.soft(r) || win.width <= 0 || win.height <= 0 || !Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) return;
                const w = Pixel.whole(Math.round(win.width), r), h = Pixel.whole(Math.round(win.height), r);
                if (w !== win.width || h !== win.height)
                    Hyprland.dispatch(`hl.dsp.window.resize({ x = ${w}, y = ${h}, exact = true, window = "class:^(org.hyprk.Settings)$" })`);
            }
        }
        onDevicePixelRatioChanged: fitPixels.restart()
        onWidthChanged: fitPixels.restart()
        onHeightChanged: fitPixels.restart()

        // `qs ipc --pid <this app> call settings row "Menu Bar"`: the row's centre in the window, "x y" in pt, "" when
        // the sidebar has no such row (live checks find rows by name, SettingsApp.sidebarRow)
        IpcHandler {
            target: "settings"
            function row(name: string): string { return settingsApp.sidebarRow(name); }
        }
        SettingsApp {
            id: settingsApp
            anchors.fill: parent
            keepActive: win.emojiOver || win.picked
            currentId: Quickshell.env("HYPRK_SETTINGS_PANE") || "appearance"
            snapshotPath: Quickshell.env("HYPRK_SNAPSHOT") || ""
            startSub: Quickshell.env("HYPRK_SETTINGS_SUB") || ""
            snapshotScroll: Number(Quickshell.env("HYPRK_SNAPSHOT_SCROLL") || 0)
            onCloseRequested: Qt.quit()
            // Hyprland ignores xdg set_minimized: hide the window to special:minimized as the shell's Minimize does
            // (the yellow light did nothing); elsewhere the plain request
            onMinimizeRequested: {
                if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
                    Hyprland.dispatch('hl.dsp.window.move({ workspace = "special:minimized", window = "class:^(org.hyprk.Settings)$" })');
                else win.minimized = true;
            }
            // Zoom as the shell's Window > Zoom (Hyprland's maximized mode): the session suppresses xdg maximize requests
            // for every window (config/hypr/hyprland.lua), so `maximized` did nothing
            onZoomRequested: {
                if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
                    Hyprland.dispatch('hl.dsp.window.fullscreen({ mode = "maximized", window = "class:^(org.hyprk.Settings)$" })');
                else win.maximized = !win.maximized;
            }
            onMoveRequested: win.startSystemMove()   // xdg_toplevel.move, title bar drag like macOS
        }
    }
}
