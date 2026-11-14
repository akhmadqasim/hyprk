//@ pragma AppId org.hyprk.Settings
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "HyprK"

// Entry for Quickshell: `quickshell -p settings/` (full command backend).
// Env: HYPRK_SETTINGS_PANE=<pane id> opens a pane, HYPRK_SNAPSHOT=<png> renders it and quits.
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
        // the liquidglass plugin loaded (config/hypr/hyprland.lua exports HYPRK_GLASS=plugin) draws the menu glass behind
        // this window's popups (popup_classes lists org.hyprk.Settings): the text field menu draws no fill
        Binding { target: Tokens; property: "popupGlass"; value: Quickshell.env("HYPRK_GLASS") === "plugin" }

        // Emoji & Symbols (the shell's hyprk-emoji layer) opened over this window keeps it key-looking: the Mac's
        // character palette does not take the app's key window. The layer takes the keyboard, so Qt reports the window
        // inactive; Hyprland's active window stays this one, so it is checked when the layer maps (socket2 openlayer)
        property bool emojiOver: false
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.data !== "hyprk-emoji") return;
                if (event.name === "closelayer") { win.emojiOver = false; return; }
                if (event.name !== "openlayer") return;
                const t = Hyprland.activeToplevel;
                const appId = !t ? "" : t.wayland ? t.wayland.appId : (t.lastIpcObject["class"] || "");
                win.emojiOver = appId === "org.hyprk.Settings";
            }
        }

        SettingsApp {
            anchors.fill: parent
            keepActive: win.emojiOver
            currentId: Quickshell.env("HYPRK_SETTINGS_PANE") || "appearance"
            snapshotPath: Quickshell.env("HYPRK_SNAPSHOT") || ""
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
