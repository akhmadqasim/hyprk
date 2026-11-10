import QtQuick
import Quickshell

// Quickshell-only facts (Backend loads it dynamically; absent under `qml`).
QtObject {
    readonly property string shellDir: Quickshell.shellDir
    // $HYPRK_STATE: the state folder the session decided (config/hypr/state-dir.sh); "" when unset
    readonly property string stateDir: Quickshell.env("HYPRK_STATE") ?? ""
    // Themed icon lookup; "" when the theme has no such icon.
    function iconPath(name) { return Quickshell.iconPath(name, true); }
    // Hyprland blurs what is behind our translucent sidebar (hyprland-rules.lua).
    readonly property bool hyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "") !== ""
}
