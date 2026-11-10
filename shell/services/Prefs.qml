pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../lib/state.js" as State

// Settings written by the hyprk Settings app (state/*.json), with defaults that
// match settings/Parsers.js. Missing or broken files keep the defaults.
// Also applies what belongs to the session: keyboard repeat (input.json),
// idle display-off and lock (lock.json).
Singleton {
    id: root

    // HYPRK_STATE overrides the folder (tests), like scripts/sound.sh
    readonly property string dir: (Quickshell.env("HYPRK_STATE") || Quickshell.shellDir + "/../state") + "/"

    property var notifications: ({ previews: "unlocked", summarize: false, whenSleeping: false, whenLocked: true, whenMirroring: false, apps: {} })
    property var lock: ({ screenSaverAfter: 1200, displayOffAfter: 600, requirePasswordAfter: 0, largeClock: "lock" })
    property var input: ({ repeatRate: 25, repeatDelay: 600 })
    property var wallpaper: ({ path: "" })
    property var dock: State.dockDefaults()

    component StateFile: FileView {
        required property string key
        // set: merge over these instead of the current values, so a key removed from the file goes back
        // to its default (dock.json without `magnification` = off)
        property var defaults: null
        path: root.dir + key + ".json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root[key] = State.parse(text(), defaults || root[key])
    }
    StateFile { key: "notifications" }
    StateFile { key: "lock" }
    StateFile { key: "input"; onLoaded: root.applyInput() }
    StateFile { key: "wallpaper" }
    StateFile { key: "dock"; defaults: State.dockDefaults() }

    // ---------- input.json -> Hyprland ----------
    function applyInput() {
        inputProc.command = ["hyprctl", "eval", State.luaInput(input)];
        inputProc.running = true;
    }
    Process { id: inputProc }

    // ---------- lock.json -> idle actions ----------
    // Display off: DPMS through Hyprland. Lock: hyprlock with lockscreen/hyprlock.conf,
    // loginctl as fallback; only with HYPRK_ALLOW_POWER=1 so a nested test session
    // never locks the host desktop.
    IdleMonitor {
        enabled: root.lock.displayOffAfter > 0
        timeout: Math.max(1, root.lock.displayOffAfter)
        onIsIdleChanged: Hyprland.dispatch(`hl.dsp.dpms({ action = "${isIdle ? "off" : "on"}" })`)
    }
    IdleMonitor {
        enabled: root.lock.screenSaverAfter > 0
        timeout: Math.max(1, root.lock.screenSaverAfter + root.lock.requirePasswordAfter)
        onIsIdleChanged: if (isIdle) Power.lock()
    }
}
