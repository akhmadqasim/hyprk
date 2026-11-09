//@ pragma AppId org.hyprk.Settings
import QtQuick
import Quickshell

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

        SettingsApp {
            id: ui
            anchors.fill: parent
            currentId: Quickshell.env("HYPRK_SETTINGS_PANE") || "appearance"
            onCloseRequested: Qt.quit()
            onMinimizeRequested: win.minimized = true
            onZoomRequested: win.maximized = !win.maximized
            // Hyprland moves floating windows with SUPER+drag; FloatingWindow
            // does not expose xdg move requests.
        }

        Timer {
            readonly property string out: String(Quickshell.env("HYPRK_SNAPSHOT") ?? "")
            running: out !== ""
            interval: 4000
            onTriggered: ui.grabToImage(r => { r.saveToFile(out); Qt.quit(); })
        }
    }
}
