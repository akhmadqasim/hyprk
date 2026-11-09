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

    // Unsaved local changes per file. External edits that arrive meanwhile are
    // merged under them, so neither side is lost.
    property var _patches: ({})
    property var _wallpaperFile: ({})    // keep keys the shell may add
    property Timer _flush: Timer {
        interval: 250
        onTriggered: {
            const files = { [app.appearancePath]: app.appearance, [app.dockPath]: app.dock,
                            [app.soundPath]: app.sound, [app.wallpaperPath]: app._wallpaperFile };
            for (const path in app._patches) Backend.writeFile(path, JSON.stringify(files[path], null, 2) + "\n");
            app._patches = {};
        }
    }
    function _patch(path, patch) {
        _patches[path] = Object.assign(_patches[path] || {}, patch);
        _flush.restart();
    }
    function _merged(path, text, normalize) {
        let obj = {};
        try { obj = JSON.parse(text); } catch (e) {}
        return normalize(Object.assign({}, obj, _patches[path] || {}));
    }

    function setAppearance(patch) { appearance = P.normalizeAppearance(Object.assign({}, appearance, patch)); _patch(appearancePath, patch); }
    function setDock(patch) { dock = P.normalizeDock(Object.assign({}, dock, patch)); _patch(dockPath, patch); }
    function setSound(patch) { sound = P.normalizeSound(Object.assign({}, sound, patch)); _patch(soundPath, patch); }
    function setWallpaper(path) {
        wallpaper = path;
        _wallpaperFile = Object.assign({}, _wallpaperFile, { path: path });
        _patch(wallpaperPath, { path: path });
    }

    onAppearanceChanged: {
        Theme.dark = appearance.dark;
        Theme.reduceTransparency = appearance.reduceTransparency;
        const t = Theme.tile[appearance.accent];
        Theme.accentOverride = t !== undefined && appearance.accent !== "blue" ? t : "transparent";
    }

    Component.onCompleted: {
        // The shell (or `qs ipc`) may change these files too; follow it.
        Backend.watch(appearancePath, t => app.appearance = app._merged(appearancePath, t, P.normalizeAppearance));
        Backend.watch(dockPath, t => app.dock = app._merged(dockPath, t, P.normalizeDock));
        Backend.watch(soundPath, t => app.sound = app._merged(soundPath, t, P.normalizeSound));
        Backend.watch(wallpaperPath, t => {
            app._wallpaperFile = app._merged(wallpaperPath, t, o => o);
            app.wallpaper = String(app._wallpaperFile.path || "");
        });
        // Skip peripheral batteries (mouse, headset): their scope is "Device".
        Backend.run(["sh", "-c", "for d in /sys/class/power_supply/*; do [ \"$(cat $d/scope 2>/dev/null)\" = Device ] || cat $d/type 2>/dev/null; done"], (c, out) => app.hasBattery = P.hasBattery(out));
        Backend.run(["sh", "-c", "n=$(getent passwd \"$(id -un)\" | cut -d: -f5 | cut -d, -f1); echo \"${n:-$(id -un)}\""],
                    (c, out) => { if (c === 0 && out.trim()) app.userName = out.trim(); });
    }
}
