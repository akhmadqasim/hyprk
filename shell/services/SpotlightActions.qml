pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Networking
import qs
import "../lib/spotlight.js" as SL
import "../lib/state.js" as State
import "../lib/search.js" as Search
import "../lib/panes.js" as Panes   // symlink to settings/Panes.js: qs only loads files inside the config root

// Spotlight Actions (Cmd+3): hyprk system actions, System Settings panes and the
// "Actions" of .desktop entries (New Window, New Private Window, ...).
// An action: { id, title, subtitle, symbol | icon/appId, keywords, run() }.
// Actions without a backend are left out (no Wi-Fi device -> no Wi-Fi action), see FALLBACKS.md.
Singleton {
    id: root

    readonly property string hyprk: Quickshell.shellDir + "/.."
    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property var btAdapter: Bluetooth.defaultAdapter
    property bool hasSlurp: false

    property var probe: Process {
        running: true
        command: ["sh", "-c", "command -v slurp"]
        stdout: StdioCollector { onStreamFinished: root.hasSlurp = text.trim() !== "" }
    }

    // grim into Pictures like the Cmd+Shift+3 bind; waits for Spotlight to fade out first
    function screenshot(area) {
        const file = '"$(d=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures"); mkdir -p "$d"; echo "$d")/Screenshot $(date "+%Y-%m-%d at %H.%M.%S").png"';
        const sound = hyprk + "/shell/scripts/sound.sh screenshot";
        const grim = area ? `g=$(slurp) && grim -g "$g" ${file}` : `grim ${file}`;
        Quickshell.execDetached(["sh", "-c", `sleep 0.4; ${grim} && ${sound}`]);
    }
    // System Settings on a pane (GNOME Settings when hyprk Settings is missing)
    function openPane(id) { Apps.runHyprkApp("org.hyprk.Settings", { HYPRK_SETTINGS_PANE: id }); }
    // macOS asks before logging out / restarting / shutting down
    function confirm(title, label, fn) {
        Panels.showAlert({ icon: "system-shutdown", title: title, message: "",
                           buttons: [{ label: "Cancel", isCancel: true }, { label: label, isDefault: true, action: fn }] });
    }

    readonly property var system: {
        const out = [];
        const add = a => out.push(a);
        add({ id: "dark-mode", title: Theme.dark ? "Turn Off Dark Mode" : "Turn On Dark Mode", subtitle: "Appearance",
              symbol: Theme.dark ? "sun" : "moon", keywords: ["dark", "light", "appearance", "theme"], run: () => Theme.dark = !Theme.dark });
        if (wifiDev)
            add({ id: "wifi", title: Networking.wifiEnabled ? "Turn Off Wi‑Fi" : "Turn On Wi‑Fi", subtitle: "Wi‑Fi",
                  symbol: "wifi", keywords: ["wifi", "wireless", "network"], run: () => Networking.wifiEnabled = !Networking.wifiEnabled });
        if (btAdapter)
            add({ id: "bluetooth", title: btAdapter.enabled ? "Turn Off Bluetooth" : "Turn On Bluetooth", subtitle: "Bluetooth",
                  symbol: "bluetooth", keywords: ["bluetooth"], run: () => btAdapter.enabled = !btAdapter.enabled });
        add({ id: "dnd", title: Notifs.dnd ? "Turn Off Do Not Disturb" : "Turn On Do Not Disturb", subtitle: "Focus",
              symbol: "moon", keywords: ["focus", "dnd", "notifications"], run: () => Notifs.dnd = !Notifs.dnd });
        add({ id: "screenshot", title: "Take Screenshot", subtitle: "Entire screen, saved to Pictures", symbol: "camera",
              keywords: ["screenshot", "capture", "screen"], run: () => root.screenshot(false) });
        if (hasSlurp)
            add({ id: "screenshot-area", title: "Take Screenshot of Selection", subtitle: "Saved to Pictures", symbol: "camera",
                  keywords: ["screenshot", "capture", "area"], run: () => root.screenshot(true) });
        if (Apps.preferredTerminal)
            add({ id: "terminal", title: "New Terminal Window", subtitle: Apps.preferredTerminal.name, symbol: "terminal",
                  keywords: ["terminal", "shell", "console"], run: () => Apps.launch(Apps.preferredTerminal) });
        add({ id: "finder", title: "New Finder Window", subtitle: "Finder", symbol: "folder", keywords: ["finder", "files"],
              run: () => Apps.runHyprkApp("hyprk-finder") });
        add({ id: "controlcenter", title: "Show Control Center", symbol: "controlcenter", run: () => Panels.toggle("cc") });
        add({ id: "notificationcenter", title: "Show Notification Center", symbol: "bell", run: () => Panels.toggle("nc") });
        add({ id: "missioncontrol", title: "Mission Control", symbol: "display", keywords: ["windows", "overview"], run: () => Panels.toggle("mission") });
        add({ id: "apps", title: "Show Apps", symbol: "square.grid", keywords: ["launchpad"], run: () => AppsView.show() });
        add({ id: "empty-trash", title: "Empty Trash", symbol: "trash", run: () => Apps.confirmEmptyTrash() });
        if (SpotlightState.clipboardHistory !== "off")      // don't create Clipboard just to ask
            add({ id: "clear-clipboard", title: "Clear Clipboard History", symbol: "clipboard", keywords: ["clipboard"], run: () => Clipboard.clear() });
        const blocked = Power.allowed ? "" : "Blocked in this session";
        add({ id: "lock", title: "Lock Screen", subtitle: blocked, symbol: "lock", run: () => Power.lock() });
        add({ id: "sleep", title: "Sleep", subtitle: blocked, symbol: "moon", run: () => Power.sleep() });
        add({ id: "restart", title: "Restart", subtitle: blocked, symbol: "power", run: () => root.confirm("Are you sure you want to restart your computer now?", "Restart", Power.restart) });
        add({ id: "shutdown", title: "Shut Down", subtitle: blocked, symbol: "power", keywords: ["power off"], run: () => root.confirm("Are you sure you want to shut down your computer now?", "Shut Down", Power.shutdown) });
        add({ id: "logout", title: "Log Out", symbol: "power", keywords: ["sign out", "exit"], run: () => root.confirm("Are you sure you want to quit all applications and log out now?", "Log Out", Power.logout) });
        // the same panes as the Settings sidebar (Battery on laptops, Energy on desktops)
        for (const p of Panes.visible(State.hasBattery(UPower.devices.values), ""))
            add({ id: "settings:" + p.id, title: p.title + " Settings", subtitle: "System Settings", appIcon: "settings",
                  // pane titles use U+2011 (Wi‑Fi): also match a typed ASCII hyphen
                  keywords: ["settings", "preferences", p.title.replace("\u2011", "-")], run: () => root.openPane(p.id) });
        return out;
    }

    // .desktop [Desktop Action ...] entries of visible apps
    readonly property var appActions: {
        const out = [];
        for (const e of Apps.visibleEntries)
            for (const a of e.actions || [])
                out.push({ id: "desktop:" + e.id + ":" + a.id, title: a.name, subtitle: e.name, appIcon: a.icon || e.icon,
                           appId: e.id, keywords: [e.name], run: () => { a.execute(); Apps.markLaunching(e.id); } });
        return out;
    }
    readonly property var all: system.concat(appActions)

    function rank(query, limit) { return SL.rankActions(all, query, SpotlightState.quickKeys, Search.score, limit); }

    function run(action) {
        Panels.close();
        action.run();
    }
}
