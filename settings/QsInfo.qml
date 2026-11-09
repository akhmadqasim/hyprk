import QtQuick
import Quickshell

// Quickshell-only facts (Backend loads it dynamically; absent under `qml`).
QtObject {
    readonly property string shellDir: Quickshell.shellDir
    // Hyprland blurs what is behind our translucent sidebar (hyprland-rules.lua).
    // Themed icon lookup; "" when the theme has no such icon.
    function iconPath(name) { return Quickshell.iconPath(name, true); }
    readonly property bool hyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "") !== ""
}
