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
    // hyprk's own apps (sibling dirs of shell/), with the stock app used when one is missing
    readonly property var hyprkApps: ({
        // fallbacks: first installed command runs; their windows count as this app's
        "hyprk-finder": { id: "hyprk-finder", name: "Finder", icon: "hyprk-finder", run: "finder/run.sh",
                          fallbacks: ["nautilus", "thunar", "dolphin"], alsoIds: ["org.gnome.Nautilus", "nautilus", "thunar", "org.kde.dolphin"] },
        "org.hyprk.Settings": { id: "org.hyprk.Settings", name: "System Settings", icon: "settings", run: "settings/run.sh",
                                fallbacks: ["gnome-control-center"], alsoIds: ["org.gnome.Settings", "gnome-control-center"] },
    })

    readonly property var pinnedCandidates: [
        ["hyprk-finder"],
        ["hyprk-launchpad"],
        ["firefox", "firefox_firefox", "org.mozilla.firefox", "google-chrome", "chromium"],
        ["org.gnome.Evolution", "thunderbird", "org.mozilla.Thunderbird"],
        ["org.gnome.Calendar"],
        ["org.gnome.TextEditor", "org.gnome.gedit"],
        ["org.gnome.Music", "rhythmbox", "org.gnome.Rhythmbox3"],
        ["org.hyprk.Settings"],
        ["com.mitchellh.ghostty", "org.gnome.Terminal", "kitty", "org.gnome.Ptyxis"],
    ]

    readonly property var entries: DesktopEntries.applications.values
    // visible apps sorted by name (Apps panel), rebuilt only when the entry list changes
    // helper launchers like "Foot Client" / "Foot Server" next to "Foot" (same icon,
    // name extends the main one) are hidden, like macOS shows one app
    readonly property var sortedEntries: {
        const vis = entries.filter(e => !e.noDisplay);
        const helper = e => vis.some(m => m !== e && m.icon === e.icon && e.name.startsWith(m.name + " "));
        return vis.filter(e => !helper(e)).sort((a, b) => a.name.localeCompare(b.name));
    }

    readonly property var pinned: {
        // depend on the entry list so the dock fills in once .desktop files are scanned
        if (entries.length === 0) return [];
        const out = [];
        for (const ids of pinnedCandidates) {
            if (ids[0] === "hyprk-launchpad") {
                out.push({ id: "hyprk-launchpad", name: "Apps", icon: "hyprk-launchpad", action: () => Panels.toggle("launchpad") });
                continue;
            }
            const own = hyprkApps[ids[0]];
            if (own) {
                out.push({ id: own.id, name: own.name, icon: own.icon, alsoIds: own.alsoIds, action: () => root.runHyprkApp(own.id) });
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
        const out = pinned.map(p => Object.assign({ windows: windowsFor(p.id, p.entry, p.alsoIds) }, p));
        const seen = new Set();
        for (const p of out) {
            seen.add(Search.normId(p.id));
            for (const a of p.alsoIds || []) seen.add(Search.normId(a));
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

    function windowsFor(id, entry, alsoIds) {
        const keys = [Search.normId(id)].concat((alsoIds || []).map(Search.normId));
        if (entry && entry.startupClass) keys.push(Search.normId(entry.startupClass));
        keys.splice(0, keys.length, ...new Set(keys));       // same window must not count twice
        const found = [].concat(...keys.filter(k => running[k]).map(k => running[k]));   // no flatMap in QV4
        if (found.length > 0) return found;
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
        "hyprk-finder": "Finder", "nautilus": "Finder", "thunar": "Finder", "dolphin": "Finder",
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
        "screenshot": "Screenshot", "notes": "Notes", "messages": "Messages", "mail": "Mail",
        "photos": "Photos", "facetime": "FaceTime", "reminders": "Reminders", "music": "Music", "gnome-software": "App_Store", "snap-store": "App_Store",
        "snap-store_snap-store": "App_Store", "characters": "Font_Book", "simple-scan": "Image_Capture",
        "user-trash": "@TrashIcon", "user-trash-full": "@FullTrashIcon", "folder-download": "@DownloadsFolder",
    })
    readonly property string iconDir: Quickshell.shellDir + "/../themes/icons"
    readonly property string genericIcon: "file://" + iconDir + "/system/GenericApplicationIcon-512.png"

    // mapped macOS icon name for an app, "" when there is none
    function macIconFor(name, appId) {
        for (const k of [appId, name]) {
            const mac = macIcons[Search.normId(k).split(".").pop()];
            if (mac) return mac;
        }
        return "";
    }
    // true when the icon is one of the extracted macOS icons (already a squircle)
    function isMacIcon(name, appId) { return macIconFor(name, appId) !== ""; }

    // Absolute icon url: macOS icon when mapped, else the icon theme, else the generic app icon.
    function iconUrl(name, appId) {
        const mac = macIconFor(name, appId);
        if (mac) return "file://" + iconDir + (mac[0] === "@" ? "/system/" + mac.slice(1) : "/apps/" + mac) + "-512.png";
        if (!name) return genericIcon;
        if (name.startsWith("/")) return "file://" + name;
        const themed = Quickshell.iconPath(name, true);
        return themed ? themed : genericIcon;
    }

    function activeAppName() {
        const t = Hyprland.activeToplevel;
        if (!t || !appIdOf(t)) return "Finder";
        const id = appIdOf(t);
        if (hyprkApps[id]) return hyprkApps[id].name;
        const e = entryFor(id);
        return e ? e.name : id;
    }

    // Hyprland window selector for a HyprlandToplevel
    function windowSelector(t) {
        const addr = String(t.address);
        return `{ window = "address:${addr.startsWith("0x") ? addr : "0x" + addr}" }`;
    }
    function focusWindow(t) { Hyprland.dispatch(`hl.dsp.focus(${windowSelector(t)})`); }
    function closeWindow(t) { Hyprland.dispatch(`hl.dsp.window.close(${windowSelector(t)})`); }

    function activate(item) {
        if (item.windows && item.windows.length > 0) {
            // cycle through windows of the app, like clicking an active Dock icon
            const active = item.windows.findIndex(w => w === Hyprland.activeToplevel);
            focusWindow(item.windows[(active + 1) % item.windows.length]);
            return;
        }
        // items without a .desktop entry carry their own action (Apps panel, hyprk Settings)
        if (item.action) item.action();
        else launch(item.entry, item.id);
    }

    // hyprk System Settings (settings/run.sh), GNOME Settings when it is missing
    function runHyprkApp(id) {
        const app = hyprkApps[id];
        const run = Quickshell.shellDir + "/../" + app.run;
        const alts = app.fallbacks.map(c => `command -v ${c} >/dev/null && exec ${c};`).join(" ");
        Quickshell.execDetached(["sh", "-c", `[ -x "${run}" ] && exec "${run}"; ${alts} exit 1`]);
        markLaunching(id);
    }
    function openSettings() { runHyprkApp("org.hyprk.Settings"); }

    function openTrash() { Quickshell.execDetached(["gio", "open", "trash:///"]); }
    function openFolder(item) { Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/" + item.folder]); }

    // Dock right-click menu, macOS layout: windows, Options, Show in Finder, Open/Quit
    function dockMenu(item) {
        if (item.trash)
            return [{ label: "Open", action: root.openTrash },
                    { sep: true }, { label: "Empty Trash", action: root.confirmEmptyTrash }];
        if (item.folder)
            return [{ label: "Open “" + item.name + "”", action: () => root.openFolder(item) }];
        const wins = item.windows || [];
        const out = wins.map(w => ({ label: w.title || item.name, action: () => root.focusWindow(w) }));
        if (out.length > 0) out.push({ sep: true });
        out.push({ label: "Options", submenu: true, disabled: true });
        out.push({ label: "Show in Finder", disabled: true });
        out.push({ sep: true });
        if (wins.length > 0)
            out.push({ label: "Quit", action: () => wins.forEach(root.closeWindow) });
        else
            out.push({ label: "Open", action: () => root.activate(item) });
        return out;
    }

    function emptyTrash() {
        Quickshell.execDetached(["sh", "-c", `gio trash --empty && "${Sounds.script}" trash-empty`]);
    }

    // Finder-style confirmation before erasing
    function confirmEmptyTrash() {
        Panels.showAlert({
            icon: "user-trash-full",
            title: "Are you sure you want to permanently erase the items in the Trash?",
            message: "You can’t undo this action.",
            buttons: [{ label: "Cancel", isCancel: true }, { label: "Empty Trash", isDefault: true, action: root.emptyTrash }],
        });
    }

    function markLaunching(id) {
        const l = Object.assign({}, launching);
        l[id] = Date.now();
        launching = l;
        bounceTimer.restart();
    }

    function launch(entry, id) {
        if (!entry) return;
        entry.execute();
        markLaunching(id || entry.id);
    }

    function isLaunching(id) { return launching[id] !== undefined; }

    Timer {
        id: bounceTimer
        interval: 6000    // stop bouncing even if no window maps (CLI apps, failed launch)
        onTriggered: root.launching = ({})
    }
}
