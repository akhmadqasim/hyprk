pragma Singleton

import QtQuick
import "Parsers.js" as P

// Shared state files. appearance.json is also read by the shell, so we
// read-modify-write and keep keys we do not know.
QtObject {
    id: app

    readonly property string appearancePath: Backend.stateDir + "/appearance.json"
    readonly property string dockPath: Backend.stateDir + "/dock.json"
    readonly property string wallpaperPath: Backend.stateDir + "/wallpaper.json"

    property var appearance: P.normalizeAppearance({})
    property var dock: P.normalizeDock({})
    property bool hasBattery: false
    property string userName: "User"
    property string wallpaper: ""       // state/wallpaper.json {path}

    function setAppearance(patch) {
        appearance = JSON.parse(P.writeState(appearance, patch, P.normalizeAppearance));
        Backend.writeFile(appearancePath, JSON.stringify(appearance, null, 2) + "\n");
    }
    function setDock(patch) {
        dock = JSON.parse(P.writeState(dock, patch, P.normalizeDock));
        Backend.writeFile(dockPath, JSON.stringify(dock, null, 2) + "\n");
    }

    function setWallpaper(path) {
        wallpaper = path;
        Backend.writeFile(wallpaperPath, JSON.stringify({ path: path }, null, 2) + "\n");
    }

    function reload() {
        Backend.readFile(appearancePath, t => {
            const a = P.readState(t, P.normalizeAppearance);
            if (JSON.stringify(a) !== JSON.stringify(appearance)) appearance = a;
        });
        Backend.readFile(wallpaperPath, t => {
            let w = "";
            try { w = String(JSON.parse(t).path || ""); } catch (e) {}
            if (w !== wallpaper) wallpaper = w;
        });
        Backend.readFile(dockPath, t => {
            const d = P.readState(t, P.normalizeDock);
            if (JSON.stringify(d) !== JSON.stringify(dock)) dock = d;
        });
    }

    onAppearanceChanged: {
        Theme.dark = appearance.dark;
        Theme.reduceTransparency = appearance.reduceTransparency;
        const t = Theme.tile[appearance.accent];
        Theme.accentOverride = t !== undefined && appearance.accent !== "blue" ? t : "transparent";
    }

    // The shell (or `qs ipc`) may flip the theme; follow it.
    property Timer _poll: Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: app.reload() }

    Component.onCompleted: {
        Backend.run(["sh", "-c", "cat /sys/class/power_supply/*/type 2>/dev/null"], (c, out) => app.hasBattery = P.hasBattery(out));
        Backend.run(["sh", "-c", "n=$(getent passwd \"$(id -un)\" | cut -d: -f5 | cut -d, -f1); echo \"${n:-$(id -un)}\""],
                    (c, out) => { if (c === 0 && out.trim()) app.userName = out.trim(); });
    }
}
