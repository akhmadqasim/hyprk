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
    // hyprk lock screen (lockscreen/hyprk-lock.sh regenerates the hyprlock config from the
    // current wallpaper); loginctl when hyprlock is missing
    function lock() {
        const script = Quickshell.shellDir + "/../lockscreen/hyprk-lock.sh";
        const dark = Theme.dark ? " --dark" : "";
        run(["sh", "-c", `command -v hyprlock >/dev/null && [ -x "${script}" ] && exec "${script}"${dark} || exec loginctl lock-session`]);
    }
    function logout() { Hyprland.dispatch("hl.dsp.exit()"); }
}
