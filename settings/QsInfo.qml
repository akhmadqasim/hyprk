import QtQuick
import Quickshell
import Quickshell.Hyprland

// Quickshell-only facts (Backend loads it dynamically; absent under `qml`).
QtObject {
    readonly property string shellDir: Quickshell.shellDir
    // $HYPRK_STATE: the state folder the session decided (config/hypr/state-dir.sh); "" when unset
    readonly property string stateDir: Quickshell.env("HYPRK_STATE") ?? ""
    // hyprk is the login session (dist/hyprk-session exports HYPRK_ALLOW_POWER=1, the repo's one "real session"
    // signal: shell/services/Power.qml); not set in a nested try, a smoke run or a standalone settings/run.sh
    readonly property bool realSession: Quickshell.env("HYPRK_ALLOW_POWER") === "1"
    // Themed icon lookup; "" when the theme has no such icon.
    function iconPath(name) { return Quickshell.iconPath(name, true); }
    // Hyprland blurs what is behind our translucent sidebar (hyprland-rules.lua).
    readonly property bool hyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "") !== ""
    // a dispatcher (Lua) on Hyprland's socket: there in the order sent, no process to start
    function hyprDispatch(lua) { Hyprland.dispatch(lua); }
}
