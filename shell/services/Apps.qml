pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../lib/search.js" as Search

// Dock model and app helpers: pinned apps, running windows (Hyprland IPC),
// icon lookup with a generic fallback, launching with a bounce state.
Singleton {
    id: root

    // Dock order, macOS-like: Finder, Launchpad/Apps, browser, mail, ... (first id that exists wins)
    readonly property var pinnedCandidates: [
        ["org.gnome.Nautilus", "nautilus", "thunar", "org.kde.dolphin"],
        ["hyprk-launchpad"],
        ["firefox", "firefox_firefox", "org.mozilla.firefox", "google-chrome", "chromium"],
        ["org.gnome.Evolution", "thunderbird", "org.mozilla.Thunderbird"],
        ["org.gnome.Calendar"],
        ["org.gnome.TextEditor", "org.gnome.gedit"],
        ["org.gnome.Music", "rhythmbox", "org.gnome.Rhythmbox3"],
        ["org.gnome.Settings", "gnome-control-center"],
        ["com.mitchellh.ghostty", "org.gnome.Terminal", "kitty", "org.gnome.Ptyxis"],
    ]

    readonly property var entries: DesktopEntries.applications.values

    readonly property var pinned: {
        // depend on the entry list so the dock fills in once .desktop files are scanned
        if (entries.length === 0) return [];
        const out = [];
        for (const ids of pinnedCandidates) {
            if (ids[0] === "hyprk-launchpad") {
                out.push({ id: "hyprk-launchpad", name: "Apps", icon: "hyprk-launchpad", builtin: true });
                continue;
            }
            for (const id of ids) {
                const e = DesktopEntries.byId(id);
                if (e) { out.push({ id: e.id, name: e.name, icon: e.icon, entry: e }); break; }
            }
        }
        return out;
    }

    // running windows grouped by app id
    readonly property var running: {
        const map = {};
        for (const t of Hyprland.toplevels.values) {
            const id = appIdOf(t);
            if (!id) continue;
            (map[Search.normId(id)] = map[Search.normId(id)] || []).push(t);
        }
        return map;
    }

    // dock items = pinned + running-but-not-pinned
    readonly property var dockItems: {
        const out = pinned.map(p => Object.assign({ windows: windowsFor(p.id, p.entry) }, p));
        const seen = new Set();
        for (const p of out) {
            seen.add(Search.normId(p.id));
            if (p.entry && p.entry.startupClass) seen.add(Search.normId(p.entry.startupClass));
        }
        for (const key in running) {
            const e = Search.matchEntry(entries, key);
            const k = e ? Search.normId(e.id) : key;
            if (seen.has(key) || seen.has(k)) continue;
            seen.add(k);
            out.push({ id: e ? e.id : key, name: e ? e.name : key, icon: e ? e.icon : key, entry: e, windows: running[key] });
        }
        return out;
    }

    property var launching: ({})    // id -> start time (ms)

    function appIdOf(t) {
        if (!t) return "";
        if (t.wayland && t.wayland.appId) return t.wayland.appId;
        const o = t.lastIpcObject;
        return o && o["class"] ? o["class"] : "";
    }

    function windowsFor(id, entry) {
        const keys = [Search.normId(id)];
        if (entry && entry.startupClass) keys.push(Search.normId(entry.startupClass));
        for (const k of keys) if (running[k]) return running[k];
        // last-segment match (org.gnome.Nautilus <-> nautilus)
        const seg = Search.normId(id).split(".").pop();
        for (const k in running) if (k.split(".").pop() === seg) return running[k];
        return [];
    }

    function entryFor(appId) {
        return Search.matchEntry(entries, appId);
    }

    // Linux app id / icon name -> macOS icon (themes/icons/apps, extracted by the assets agent).
    // Keys are the lowercased last id segment.
    readonly property var macIcons: ({
        "nautilus": "Finder", "thunar": "Finder", "dolphin": "Finder",
        "hyprk-launchpad": "Apps", "view-app-grid-symbolic": "Apps",
        "firefox": "Safari", "firefox_firefox": "Safari", "google-chrome": "Safari", "chromium": "Safari",
        "evolution": "Mail", "thunderbird": "Mail", "geary": "Mail",
        "calendar": "Calendar", "texteditor": "TextEdit", "gedit": "TextEdit",
        "music": "Music", "rhythmbox": "Music", "rhythmbox3": "Music",
        "settings": "System_Settings", "gnome-control-center": "System_Settings",
        "ghostty": "Terminal", "terminal": "Terminal", "kitty": "Terminal", "ptyxis": "Terminal",
        "calculator": "Calculator", "gnome-calculator": "Calculator",
        "gnome-system-monitor": "Activity_Monitor", "systemmonitor": "Activity_Monitor",
        "loupe": "Preview", "eog": "Preview", "evince": "Preview", "papers": "Preview",
        "clocks": "Clock", "weather": "Weather", "maps": "Maps", "contacts": "Contacts",
        "photos": "Photos", "shotwell": "Photos", "totem": "QuickTime_Player", "showtime": "QuickTime_Player",
        "baobab": "Disk_Utility", "diskutility": "Disk_Utility", "font-viewer": "Font_Book", "fontviewer": "Font_Book",
        "screenshot": "Screenshot", "notes": "Notes", "gnome-software": "App_Store", "snap-store": "App_Store",
        "snap-store_snap-store": "App_Store", "characters": "Font_Book", "simple-scan": "Image_Capture",
        "user-trash": "@TrashIcon", "user-trash-full": "@FullTrashIcon", "folder-download": "@DownloadsFolder",
    })
    readonly property string iconDir: Quickshell.shellDir + "/../themes/icons"
    readonly property string genericIcon: "file://" + iconDir + "/system/GenericApplicationIcon-512.png"

    // Absolute icon url: macOS icon when mapped, else the icon theme, else the generic app icon.
    function iconUrl(name, appId) {
        for (const k of [appId, name]) {
            const key = Search.normId(k).split(".").pop();
            const mac = macIcons[key];
            if (mac) return "file://" + iconDir + (mac[0] === "@" ? "/system/" + mac.slice(1) : "/apps/" + mac) + "-512.png";
        }
        if (!name) return genericIcon;
        if (name.startsWith("/")) return "file://" + name;
        const themed = Quickshell.iconPath(name, true);
        return themed ? themed : genericIcon;
    }

    function activeAppName() {
        const t = Hyprland.activeToplevel;
        if (!t || !appIdOf(t)) return "Finder";
        const e = entryFor(appIdOf(t));
        return e ? e.name : appIdOf(t);
    }

    function focusWindow(t) {
        const addr = String(t.address);
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr.startsWith("0x") ? addr : "0x" + addr}" })`);
    }

    function activate(item) {
        if (item.builtin) {
            Panels.toggle("launchpad");
            return;
        }
        if (item.windows && item.windows.length > 0) {
            // cycle through windows of the app, like clicking an active Dock icon
            const active = item.windows.findIndex(w => w === Hyprland.activeToplevel);
            focusWindow(item.windows[(active + 1) % item.windows.length]);
            return;
        }
        launch(item.entry, item.id);
    }

    function launch(entry, id) {
        if (!entry) return;
        entry.execute();
        const l = Object.assign({}, launching);
        l[id || entry.id] = Date.now();
        launching = l;
        bounceTimer.restart();
    }

    function isLaunching(id) { return launching[id] !== undefined; }

    Timer {
        id: bounceTimer
        interval: 6000    // stop bouncing even if no window maps (CLI apps, failed launch)
        onTriggered: root.launching = ({})
    }
}
