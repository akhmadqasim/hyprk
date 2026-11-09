pragma Singleton

import QtQuick
import "Parsers.js" as P

// Shared state files in state/ (also read by the shell). We read-modify-write and
// keep keys we do not know. Writes are debounced so sliders don't spawn a write per pixel.
QtObject {
    id: app

    readonly property string appearancePath: Backend.stateDir + "/appearance.json"
    readonly property string dockPath: Backend.stateDir + "/dock.json"
    readonly property string soundPath: Backend.stateDir + "/sound.json"
    readonly property string wallpaperPath: Backend.stateDir + "/wallpaper.json"

    property var appearance: P.normalizeAppearance({})
    property var dock: P.normalizeDock({})
    property var sound: P.normalizeSound({})
    property string wallpaper: ""       // state/wallpaper.json {path}
    property bool hasBattery: false
    property string userName: "User"

    // path -> text waiting to be written
    property var _pending: ({})
    property Timer _flush: Timer {
        interval: 250
        onTriggered: {
            for (const path in app._pending) Backend.writeFile(path, app._pending[path]);
            app._pending = {};
        }
    }
    function _save(path, obj) {
        _pending[path] = JSON.stringify(obj, null, 2) + "\n";
        _flush.restart();
    }

    function setAppearance(patch) { appearance = P.normalizeAppearance(Object.assign({}, appearance, patch)); _save(appearancePath, appearance); }
    function setDock(patch) { dock = P.normalizeDock(Object.assign({}, dock, patch)); _save(dockPath, dock); }
    function setSound(patch) { sound = P.normalizeSound(Object.assign({}, sound, patch)); _save(soundPath, sound); }
    function setWallpaper(path) { wallpaper = path; _save(wallpaperPath, { path: path }); }

    onAppearanceChanged: {
        Theme.dark = appearance.dark;
        Theme.reduceTransparency = appearance.reduceTransparency;
        const t = Theme.tile[appearance.accent];
        Theme.accentOverride = t !== undefined && appearance.accent !== "blue" ? t : "transparent";
    }

    Component.onCompleted: {
        // The shell (or `qs ipc`) may change these files too; follow it, except while
        // our own write is pending (an older file version would undo the user's change).
        const follow = fn => t => { if (!app._flush.running) fn(t); };
        Backend.watch(appearancePath, follow(t => app.appearance = P.readState(t, P.normalizeAppearance)));
        Backend.watch(dockPath, follow(t => app.dock = P.readState(t, P.normalizeDock)));
        Backend.watch(soundPath, follow(t => app.sound = P.readState(t, P.normalizeSound)));
        Backend.watch(wallpaperPath, follow(t => {
            let w = "";
            try { w = String(JSON.parse(t).path || ""); } catch (e) {}
            app.wallpaper = w;
        }));
        Backend.run(["sh", "-c", "cat /sys/class/power_supply/*/type 2>/dev/null"], (c, out) => app.hasBattery = P.hasBattery(out));
        Backend.run(["sh", "-c", "n=$(getent passwd \"$(id -un)\" | cut -d: -f5 | cut -d, -f1); echo \"${n:-$(id -un)}\""],
                    (c, out) => { if (c === 0 && out.trim()) app.userName = out.trim(); });
    }
}
