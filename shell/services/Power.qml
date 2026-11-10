pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs

// Session actions from the Apple menu. Real power actions only run when
// HYPRK_ALLOW_POWER=1, so a nested test session can never suspend or shut
// down the host machine.
Singleton {
    readonly property bool allowed: Quickshell.env("HYPRK_ALLOW_POWER") === "1"

    function run(cmd) {
        if (allowed) Quickshell.execDetached(cmd);
        else console.log("hyprk: power action blocked (set HYPRK_ALLOW_POWER=1):", cmd.join(" "));
    }
    function sleep() { run(["systemctl", "suspend"]); }
    function restart() { run(["systemctl", "reboot"]); }
    function shutdown() { run(["systemctl", "poweroff"]); }
    // The shell's lock screen (modules/lock/Lock.qml registers itself here when the shell starts).
    // Without it: lockscreen/hyprk-lock.sh (hyprlock), loginctl when hyprlock is missing too.
    // Gated like the other session actions, so the idle timer and the Apple menu of a nested test
    // session never lock it (the Ctrl+Cmd+Q bind and `qs ipc call lock lock` still do).
    property var locker: null
    function lock() {
        if (!allowed) { console.log("hyprk: lock blocked (set HYPRK_ALLOW_POWER=1)"); return; }
        if (locker) { locker.lock(); return; }
        const script = Quickshell.shellDir + "/../lockscreen/hyprk-lock.sh";
        const dark = Theme.dark ? " --dark" : "";
        run(["sh", "-c", `command -v hyprlock >/dev/null && [ -x "${script}" ] && exec "${script}"${dark} || exec loginctl lock-session`]);
    }
    function logout() { Hyprland.dispatch("hl.dsp.exit()"); }
}
