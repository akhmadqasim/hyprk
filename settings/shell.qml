//@ pragma AppId org.hyprk.Settings
import QtQuick
import Quickshell
import Quickshell.Hyprland

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

        SettingsApp {
            anchors.fill: parent
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
            onZoomRequested: win.maximized = !win.maximized
            onMoveRequested: win.startSystemMove()   // xdg_toplevel.move, title bar drag like macOS
        }
    }
}
