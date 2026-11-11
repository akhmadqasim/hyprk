pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../lib/search.js" as Search
import "../lib/macicons.js" as MacIcons
import "../lib/dock.js" as DockLayout

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

    // terminal emulators in order of preference (the user's default first)
    readonly property var terminalIds: ["com.mitchellh.ghostty", "org.gnome.Terminal", "kitty", "org.gnome.Ptyxis", "foot"]

    readonly property var pinnedCandidates: [
        ["hyprk-finder"],
        ["hyprk-launchpad"],
        ["firefox", "firefox_firefox", "org.mozilla.firefox", "google-chrome", "chromium"],
        ["org.gnome.Evolution", "thunderbird", "org.mozilla.Thunderbird"],
        ["org.gnome.Calendar"],
        ["org.gnome.TextEditor", "org.gnome.gedit"],
        ["org.gnome.Music", "rhythmbox", "org.gnome.Rhythmbox3"],
        ["org.hyprk.Settings"],
        terminalIds,
    ]

    readonly property var entries: DesktopEntries.applications.values
    // visible apps sorted by name (Apps panel), rebuilt only when the entry list changes
    // helper launchers like "Foot Client" / "Foot Server" next to "Foot" (same icon,
    // name extends the main one) are hidden, like macOS shows one app
    // terminal emulators: only the preferred one is listed (macOS has one Terminal)
    function isTerminal(e) { return (e.categories || []).indexOf("TerminalEmulator") !== -1; }
    readonly property var preferredTerminal: firstEntry(terminalIds)
    // first desktop entry of ids that exists (pinned groups, preferred terminal)
    // looks ids up in `entries` (not DesktopEntries.byId) so bindings re-run after the scan
    function firstEntry(ids) {
        for (const id of ids) { const e = entries.find(x => x.id === id); if (e) return e; }
        return null;
    }
    // categories of entries that are not apps on macOS terms (screensaver hacks, settings panels)
    readonly property var helperCategories: ["Screensaver", "X-GNOME-Settings-Panel", "X-XFCE-SettingsDialog", "X-KDE-settings-hardware"]
    // helper: a helper category, or "Settings" as the only real category (small settings tools)
    function isHelper(e) {
        const cats = Array.from(e.categories || []);
        if (cats.some(c => helperCategories.indexOf(c) !== -1)) return true;
        const real = cats.filter(c => !c.startsWith("X-"));
        return real.length === 1 && real[0] === "Settings";
    }
    // what the Apps view and Spotlight list: no NoDisplay entries, no terminal-only tools,
    // no helper categories, one terminal emulator, no "<App> Client/Server" style helpers
    readonly property var visibleEntries: {
        const vis = entries.filter(e => !e.noDisplay && !e.runInTerminal && !isHelper(e)
            && (!isTerminal(e) || !preferredTerminal || e === preferredTerminal));
        // names per icon once, then each entry only checks apps with the same icon
        const byIcon = {};
        for (const e of vis) if (e.icon) (byIcon[e.icon] = byIcon[e.icon] || []).push(e.name);
        const helper = e => !!e.icon && byIcon[e.icon].some(n => n !== e.name && e.name.startsWith(n + " "));
        return vis.filter(e => !helper(e));
    }
    readonly property var sortedEntries: visibleEntries.slice().sort((a, b) => a.name.localeCompare(b.name))

    // Apps taken out of the Dock (dragged off, or Options > Remove from Dock), by their first candidate id:
    // $HYPRK_STATE/dock-items.json {"removed": [...]}, written only by the shell (dock.json is the Settings app's).
    // Keep in Dock on a running removed app puts it back. Finder cannot be removed, as on the Mac.
    property var removed: []
    FileView {
        id: itemsFile
        path: Prefs.dir + "dock-items.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try { const r = JSON.parse(text()).removed; root.removed = Array.isArray(r) ? r.map(String) : []; }
            catch (e) { root.removed = []; }
        }
    }
    function pinKey(id) {
        const ids = pinnedCandidates.find(g => g.indexOf(id) !== -1);
        return ids ? ids[0] : "";
    }
    function canRemove(id) { const k = pinKey(id); return k !== "" && k !== "hyprk-finder" && removed.indexOf(k) === -1; }
    function setRemoved(list) {
        removed = list;
        itemsFile.setText(JSON.stringify({ removed: list }) + "\n");
    }
    function removeFromDock(id) { if (canRemove(id)) setRemoved(removed.concat([pinKey(id)])); }
    // a running app that was taken out of the Dock and can be put back
    function wasRemoved(item) {
        for (const ids of pinnedCandidates)
            if (removed.indexOf(ids[0]) !== -1 && (ids.indexOf(item.id) !== -1 || ids.some(i => Search.normId(i) === Search.normId(item.id))))
                return ids[0];
        return "";
    }

    readonly property var pinned: {
        // depend on the entry list so the dock fills in once .desktop files are scanned
        if (entries.length === 0) return [];
        const out = [];
        for (const ids of pinnedCandidates) {
            if (removed.indexOf(ids[0]) !== -1) continue;
            if (ids[0] === "hyprk-launchpad") {
                out.push({ id: "hyprk-launchpad", name: "Apps", icon: "hyprk-launchpad", alsoIds: [], action: () => AppsView.toggle() });
                continue;
            }
            const own = hyprkApps[ids[0]];
            if (own) {
                out.push({ id: own.id, name: own.name, icon: own.icon, alsoIds: own.alsoIds, action: () => root.runHyprkApp(own.id) });
                continue;
            }
            const e = firstEntry(ids);
            // the other ids of the group count as this app (one Terminal in the Dock)
            if (e) out.push({ id: e.id, name: e.name, icon: e.icon, entry: e, alsoIds: ids.filter(i => i !== e.id) });
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

    // pinned apps with their windows, then the running apps that are not pinned
    readonly property var pinnedItems: pinned.map(p => Object.assign({ windows: windowsFor(p.id, p.entry, p.alsoIds) }, p))
    readonly property var runningUnpinned: {
        const out = [];
        const seen = new Set();
        for (const p of pinnedItems) {
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
    readonly property var dockItems: pinnedItems.concat(runningUnpinned)

    // Recent apps for the Dock's recent section (macOS 27.2.1 show-recents, on by default; MAC-ANSWERS.md
    // Q-dock-14): unpinned apps that stopped running, most recent first, at most 3. Kept for this session only.
    property var recent: []
    property var _unpinnedBefore: []
    onRunningUnpinnedChanged: {
        const now = runningUnpinned.map(a => a.id);
        for (const a of _unpinnedBefore)
            if (now.indexOf(a.id) === -1) recent = DockLayout.pushRecent(recent, { id: a.id, name: a.name, icon: a.icon, entry: a.entry, windows: [] }, 3);
        _unpinnedBefore = runningUnpinned;
    }

    // Launch bounce state, kept here (not in the Dock's delegates, which are rebuilt when the model changes) so a
    // bounce is never cut short: id -> { start (ms), end }. end is 0 while the app is launching; stopLaunching()
    // sets it to the end of the bounce in progress (lib/dock.js bounceEnd) and the Dock lets the icon land there.
    property var launching: ({})

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

    readonly property string iconDir: Quickshell.shellDir + "/../themes/icons"
    // The macOS icons are user-provided (never shipped). HYPRK_APPLE_ICONS=0 (set by packaging/ when
    // themes/icons/apps is missing) maps nothing and uses the icon theme instead.
    readonly property bool appleIcons: Quickshell.env("HYPRK_APPLE_ICONS") !== "0"
    readonly property string genericIcon: appleIcons ? "file://" + iconDir + "/system/GenericApplicationIcon-512.png"
                                                     : Quickshell.iconPath("application-x-executable", true)

    // mapped macOS icon name for an app, "" when there is none. The table is themes/icons/apple-map.txt
    // (shell/lib/macicons.js is generated from it by themes/icons/tools/gen-map.mjs; the Finder uses the same).
    function macIconFor(name, appId) {
        return appleIcons ? MacIcons.lookup([appId, name]) : "";
    }
    // true when the icon is one of the extracted macOS icons (already a squircle)
    function isMacIcon(name, appId) { return macIconFor(name, appId) !== ""; }

    // freedesktop names for hyprk's own items, used when the macOS icons are not there
    readonly property var themeAliases: ({
        "hyprk-finder": ["system-file-manager", "org.gnome.Nautilus"],
        "hyprk-launchpad": ["view-app-grid", "appgrid", "view-app-grid-symbolic"],
        "settings": ["preferences-system", "org.gnome.Settings"],
    })
    // Absolute icon url: macOS icon when mapped, else the icon theme, else the generic app icon.
    // look (Theme.iconLook: icon style, its variant, dark mode) picks the mapped icon's Dark / Clear / Tinted
    // rendition (themes/icons/apps/<Name>-256-<style>-<mode>.png); without it, or for the Default style, the
    // Default icon. Only the url changes with the style: images at rest are not touched.
    function iconUrl(name, appId, look) {
        const mac = macIconFor(name, appId);
        if (mac) return "file://" + iconDir + "/" + (look ? MacIcons.styled(mac, look.style, look.variant, look.dark) : MacIcons.file(mac));
        if (!name) return genericIcon;
        if (name.startsWith("/")) return "file://" + name;
        for (const n of [name].concat(themeAliases[name] || [])) {
            const themed = Quickshell.iconPath(n, true);
            if (themed) return themed;
        }
        return genericIcon;
    }

    // The app whose menus the menu bar shows: the focused window's, or Finder while the desktop has the keyboard (a click
    // on the empty desktop activates Finder on the Mac; Hyprland keeps its focused window then, but hands the keyboard to
    // the wallpaper layer and deactivates the window: Background.qml sets this)
    property string desktopFocus: ""      // the screen whose desktop has the keyboard, or ""
    readonly property var activeToplevel: desktopFocus !== "" ? null : Hyprland.activeToplevel

    function activeAppName() {
        const t = root.activeToplevel;
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

    // minimized (yellow light, Hide, plugin-motion's client minimize): parked on special:minimized
    function isMinimized(t) { return !!t && !!t.workspace && t.workspace.name === "special:minimized"; }
    // back onto the focused monitor's workspace first (plugin-motion plays the genie out of the Dock), then focus: a
    // focus alone only showed special:minimized over the screen with the window still in it
    function restoreWindow(t) {
        const m = Hyprland.focusedMonitor;
        const ws = m && m.activeWorkspace ? m.activeWorkspace.name : "";
        if (ws !== "") Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${ws}", window = "address:${String(t.address).startsWith("0x") ? t.address : "0x" + t.address}" })`);
        focusWindow(t);
    }

    function activate(item) {
        if (item.windows && item.windows.length > 0) {
            // cycle through the app's windows on screen, like clicking an active Dock icon; with every window
            // minimized the most recently used one comes back (lowest focusHistoryID)
            const shown = item.windows.filter(w => !isMinimized(w));
            if (shown.length > 0) {
                const active = shown.findIndex(w => w === Hyprland.activeToplevel);
                focusWindow(shown[(active + 1) % shown.length]);
                return;
            }
            const hist = w => { const o = w.lastIpcObject; return o && o.focusHistoryID !== undefined ? o.focusHistoryID : 1e9; };
            restoreWindow(item.windows.slice().sort((a, b) => hist(a) - hist(b))[0]);
            return;
        }
        // items without a .desktop entry carry their own action (Apps panel, hyprk Settings)
        if (item.action) item.action();
        else launch(item.entry, item.id);
    }

    // hyprk System Settings (settings/run.sh), GNOME Settings when it is missing.
    // env: extra variables, e.g. { HYPRK_SETTINGS_PANE: "wifi" } (Spotlight pane actions)
    // args: passed to the app (and its fallback); "xdg:<NAME>" becomes that XDG user dir, "home" the home folder
    function runHyprkApp(id, env, args) {
        const app = hyprkApps[id];
        const run = Quickshell.shellDir + "/../" + app.run;
        const alts = app.fallbacks.map(c => `command -v ${c} >/dev/null && exec ${c} "$@";`).join(" ");
        const vars = Object.keys(env || {}).map(k => k + "=" + env[k]);
        const fix = `case "$1" in xdg:*) set -- "$(xdg-user-dir "\${1#xdg:}")";; home) set -- "$HOME";; esac;`;
        Quickshell.execDetached(["env"].concat(vars, ["sh", "-c", `${fix} [ -x "${run}" ] && exec "${run}" "$@"; ${alts} exit 1`, "sh"], args || []));
        markLaunching(id);
    }
    function openSettings() { runHyprkApp("org.hyprk.Settings"); }
    // a Finder window, at a location the Finder takes ("recents:", "applications:", a path, "xdg:DOCUMENTS", "home")
    function openFinder(loc) { runHyprkApp("hyprk-finder", {}, loc ? [loc] : []); }

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
        const out = wins.map(w => ({ label: w.title || item.name, action: () => root.isMinimized(w) ? root.restoreWindow(w) : root.focusWindow(w) }));
        if (out.length > 0) out.push({ sep: true });
        // Finder's own rows (live/dock/dock-menus.json "Finder"); the folder rows have no feature here: disabled
        if (item.id === "hyprk-finder")
            out.push({ label: "New Finder Window", action: () => root.openFinder("") }, { label: "New Smart Folder", disabled: true },
                     { label: "Find…", action: () => { Panels.open = "spotlight"; } }, { sep: true },
                     { label: "Go to Folder…", disabled: true }, { label: "Connect to Server…", disabled: true }, { sep: true });
        // Options ▸ as on 27.2.1 (MAC-ANSWERS.md Q-dock-10): pinned "Remove from Dock", else "Keep in Dock", then
        // Open at Login and Show in Finder. Keep in Dock only puts back a pinned app that was removed (the pinned list is
        // the built-in one minus `removed`); there is no login-items store, so the other two show disabled
        const pinned = root.pinned.some(p => p.id === item.id);
        const back = pinned ? "" : root.wasRemoved(item);
        out.push({ label: "Options", submenu: true, items: [
            pinned ? { label: "Remove from Dock", disabled: !root.canRemove(item.id), action: () => root.removeFromDock(item.id) }
                   : { label: "Keep in Dock", disabled: back === "", action: () => root.setRemoved(root.removed.filter(r => r !== back)) },
            { label: "Open at Login", disabled: true },
            { label: "Show in Finder", disabled: true },
        ] });
        out.push({ sep: true });
        // running: Show All Windows, Hide, Quit (dock-menus.json); App Exposé and Hide do not exist here: disabled
        if (wins.length > 0)
            out.push({ label: "Show All Windows", disabled: true }, { label: "Hide", disabled: true },
                     { label: "Quit", action: () => wins.forEach(root.closeWindow) });
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
            // the 27.2.1 alert shows a folder (screens/27.2.1/panels/alert-{dark,light}.png), not the Trash
            icon: appleIcons ? iconDir + "/system/GenericFolderIcon-512.png" : "folder",
            title: "Are you sure you want to permanently erase the items in the Trash?",
            message: "You can’t undo this action.",
            buttons: [{ label: "Cancel", isCancel: true }, { label: "Empty Trash", isDefault: true, action: root.emptyTrash }],
        });
    }

    function markLaunching(id) {
        const b = launching[id];
        const l = Object.assign({}, launching);
        if (!b || b.end !== 0) {        // a launch already bouncing keeps its phase (no jump)
            const now = Date.now();
            // a bounce still finishing from before carries on and a new one starts at its end
            l[id] = { start: b && b.end > now ? b.end : now, end: 0 };
        }
        launching = l;
        bounceTimer.restart();
    }

    // Launching is over (window mapped, or the cap): the bounce in progress finishes, the icon stays down.
    function stopLaunching(id) {
        const b = launching[id];
        if (!b || b.end !== 0) return;
        const l = Object.assign({}, launching);
        l[id] = { start: b.start, end: b.start + DockLayout.bounceEnd(Date.now() - b.start) };
        launching = l;
    }

    function launch(entry, id) {
        if (!entry) return;
        entry.execute();
        markLaunching(id || entry.id);
    }

    function isLaunching(id) { const b = launching[id]; return b !== undefined && b.end === 0; }

    // ms since the bounce of `id` started at wall time `now`, or -1 when it is not bouncing (not launching and
    // the last bounce has landed)
    function bounceTime(id, now) {
        const b = launching[id];
        if (!b || (b.end !== 0 && now >= b.end)) return -1;
        return Math.max(0, now - b.start);
    }

    // true while any icon bounces at wall time `now` (the Dock's frame clock runs only then)
    function anyBouncing(now) {
        for (const id in launching) if (bounceTime(id, now) >= 0) return true;
        for (const id in attention) if (attentionTime(id, now) >= 0) return true;
        return false;
    }

    // Attention bounce (lib/dock.js attentionOffset): id -> { start (ms), stop } while one of the app's windows
    // is urgent (Hyprland's `urgent` event; Quickshell clears it when the window is focused). stop is -1 while
    // it is urgent, then the ms after start when it was answered: the cycle in progress lands at its rest point.
    property var attention: ({})
    function markAttention(id, on) {
        const a = attention[id], now = Date.now();
        const live = a && (a.stop < 0 || now - a.start < DockLayout.attentionEnd(a.stop));
        if (on === (a !== undefined && a.stop < 0)) return;
        const m = Object.assign({}, attention);
        if (on) m[id] = { start: live ? a.start : now, stop: -1 };
        else m[id] = { start: a.start, stop: now - a.start };
        attention = m;
    }
    // ms since the attention bounce of `id` started, or -1 while it does not move (no request, landed, or the
    // pause between the 60 s of bouncing and each 3 s burst)
    function attentionTime(id, now) {
        const a = attention[id];
        if (!a) return -1;
        const t = Math.max(0, now - a.start);
        return DockLayout.attentionPlaying(t, a.stop) ? t : -1;
    }
    function attentionOffset(id, now, height) {
        const t = attentionTime(id, now);
        return t < 0 ? 0 : DockLayout.attentionOffset(t, height, attention[id].stop);
    }
    // wall time of the next attention burst while none plays (the Dock's frame clock is off until then), 0: none
    function nextAttention(now) {
        let next = 0;
        for (const id in attention) {
            const a = attention[id];
            if (a.stop >= 0) continue;
            const t = a.start + DockLayout.nextAttentionStart(now - a.start);
            if (t > now && (next === 0 || t < next)) next = t;
        }
        return next;
    }

    Timer {
        id: bounceTimer
        interval: 6000    // stop bouncing even if no window maps (CLI apps, failed launch)
        onTriggered: { for (const id in root.launching) root.stopLaunching(id); }
    }
}
