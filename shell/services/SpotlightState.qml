pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../lib/spotlight.js" as SL

// Spotlight browse mode and preferences (state/spotlight.json, shared with Settings):
//   clipboardHistory: "off" | "30m" | "8h" | "7d"   (off until the user turns it on, like macOS)
//   quickKeys: { "<action id>": "<key>" }           (short aliases typed in Spotlight)
// Global shortcuts hyprk:spotlight-<mode> open Spotlight straight in a mode (bind them to
// Super+Space-style keys; inside Spotlight Super/Ctrl/Alt+1..4 switch modes).
Singleton {
    id: root

    // "" = all results; else apps | files | actions | clipboard
    property string mode: ""
    // forget the mode when Spotlight closes (macOS opens on the all-results view)
    readonly property bool spotlightOpen: Panels.open === "spotlight"
    onSpotlightOpenChanged: if (!spotlightOpen) mode = ""

    function openIn(m) {
        mode = SL.modeInfo(m) ? m : "";
        Panels.open = "spotlight";
    }

    // hyprk defaults; the user's own keys replace the whole map once saved
    readonly property var defaults: ({
        clipboardHistory: "off",
        quickKeys: { "dark-mode": "dm", "lock": "ls", "terminal": "nt", "screenshot": "ss", "wifi": "wf", "bluetooth": "bt" },
    })
    property var prefs: defaults
    readonly property string clipboardHistory: SL.retentionMs(prefs.clipboardHistory) > 0 ? prefs.clipboardHistory : "off"
    readonly property var quickKeys: prefs.quickKeys

    FileView {
        id: file
        path: Prefs.dir + "spotlight.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            let o = {};
            try { o = JSON.parse(text()) || {}; } catch (e) { return; }
            const p = Object.assign({}, root.defaults);
            if (typeof o.clipboardHistory === "string") p.clipboardHistory = o.clipboardHistory;
            if (o.quickKeys && typeof o.quickKeys === "object" && !Array.isArray(o.quickKeys)) p.quickKeys = o.quickKeys;
            root.prefs = p;
        }
        // a deleted file means defaults again (clipboard history off)
        onLoadFailed: root.prefs = root.defaults
    }
    function save(changes) {
        prefs = Object.assign({}, prefs, changes);
        file.setText(JSON.stringify(prefs, null, 2) + "\n");
    }
    function setClipboardHistory(r) { save({ clipboardHistory: SL.retentionMs(r) > 0 ? r : "off" }); }
    function setQuickKey(actionId, key) { save({ quickKeys: SL.setQuickKey(quickKeys, actionId, key) }); }

    GlobalShortcut { appid: "hyprk"; name: "spotlight-apps"; description: "Spotlight: Applications"; onPressed: root.openIn("apps") }
    GlobalShortcut { appid: "hyprk"; name: "spotlight-files"; description: "Spotlight: Files"; onPressed: root.openIn("files") }
    GlobalShortcut { appid: "hyprk"; name: "spotlight-actions"; description: "Spotlight: Actions"; onPressed: root.openIn("actions") }
    GlobalShortcut { appid: "hyprk"; name: "spotlight-clipboard"; description: "Spotlight: Clipboard"; onPressed: root.openIn("clipboard") }

    // `qs -p shell ipc call spotlightmode open files` (scripted screenshots, no keyboard needed)
    IpcHandler {
        target: "spotlightmode"
        function open(m: string): void { root.openIn(m); }
        function set(m: string): void { root.mode = SL.modeInfo(m) ? m : ""; }
        function current(): string { return root.mode; }
        function clipboard(r: string): void { root.setClipboardHistory(r); }
    }
}
