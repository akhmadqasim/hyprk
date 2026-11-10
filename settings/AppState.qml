pragma Singleton

import QtQuick
import "Parsers.js" as P
import "panes/accessibility/A11y.js" as A11y

// Shared state files state/<key>.json, also read by the shell. Each key below is a
// property holding the normalized object; change it with AppState.set(key, patch).
// Writes are debounced, and unknown keys in the files are kept.
QtObject {
    id: app

    property var appearance: P.normalizeAppearance({})
    property var dock: P.normalizeDock({})
    property var sound: P.normalizeSound({})
    property var lock: P.normalizeLock({})
    property var input: P.normalizeInput({})
    property var notifications: P.normalizeNotifications({})
    property var accessibility: A11y.normalize({})              // panes/accessibility/A11y.js
    property var displays: P.normalizeDisplays({})                // looks-like size per output (Displays pane)
    property var wallpaper: ({})                                  // {path, ...}
    readonly property string wallpaperImage: String(wallpaper.path || "")

    readonly property var _normalize: ({
        appearance: P.normalizeAppearance, dock: P.normalizeDock, sound: P.normalizeSound,
        lock: P.normalizeLock, input: P.normalizeInput, notifications: P.normalizeNotifications,
        accessibility: A11y.normalize, displays: P.normalizeDisplays,
        wallpaper: o => o
    })
    function path(key) { return Backend.stateDir + "/" + key + ".json"; }

    property bool hasBattery: false
    property string userName: "User"

    function set(key, patch) {
        app[key] = _normalize[key](Object.assign({}, app[key], patch));
        _patches[key] = Object.assign(_patches[key] || {}, patch);
        _flush.restart();
    }
    function setWallpaper(p) { set("wallpaper", { path: p }); }

    // Unsaved local changes per key. External edits that arrive meanwhile are
    // merged under them, so neither side is lost.
    property var _patches: ({})
    property Timer _flush: Timer {
        interval: 250
        onTriggered: {
            for (const key in app._patches) Backend.writeFile(app.path(key), JSON.stringify(app[key], null, 2) + "\n");
            app._patches = {};
        }
    }

    onAppearanceChanged: {
        Theme.dark = appearance.dark;
        Theme.reduceTransparency = appearance.reduceTransparency;
        Theme.increaseContrast = appearance.increaseContrast;
        Theme.reduceMotion = appearance.reduceMotion === true;
        Theme.sidebar.size = appearance.sidebarIconSize;
        const t = Theme.tile[appearance.accent];
        Theme.accentOverride = t !== undefined && appearance.accent !== "blue" ? t : "transparent";
    }

    Component.onCompleted: {
        Theme.compositorBlur = Backend.compositorBlur;
        // The shell (or `qs ipc`) may change these files too; follow it.
        for (const key in _normalize) {
            const k = key;
            Backend.watch(path(k), text => app[k] = P.mergeState(text, app._patches[k], app._normalize[k]));
        }
        // Skip peripheral batteries (mouse, headset): their scope is "Device".
        Backend.run(["sh", "-c", "for d in /sys/class/power_supply/*; do [ \"$(cat $d/scope 2>/dev/null)\" = Device ] || cat $d/type 2>/dev/null; done"],
                    (c, out) => app.hasBattery = P.hasBattery(out));
        // Full name from /etc/passwd, found by home dir (works under both runtimes;
        // users not in /etc/passwd, e.g. LDAP, show their home folder's name).
        Backend.readText("/etc/passwd", t => app.userName = P.gecosName(t, Backend.home));
    }
}
