pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/spotlight.js" as SL

// Clipboard history for Spotlight (Cmd+4). Off until the user turns it on
// (SpotlightState.clipboardHistory), like macOS 26. Backend: cliphist when installed,
// else scripts/clipboard.sh (files in $XDG_STATE_HOME/hyprk/clipboard, 200 items,
// expired by the retention setting). Both need wl-paste/wl-copy (wl-clipboard).
Singleton {
    id: root

    readonly property string retention: SpotlightState.clipboardHistory
    readonly property bool enabled: retention !== "off"
    readonly property int cap: 200
    // tools, detected once: "wl" = wl-clipboard present, "cliphist" = use cliphist
    property bool hasWlClipboard: false
    property bool cliphist: false
    property bool detected: false
    readonly property bool available: hasWlClipboard
    readonly property bool watching: watcher.running

    property var items: []       // [{id, file, mime, ts, text}] newest first
    readonly property string script: Quickshell.shellDir + "/scripts/clipboard.sh"
    readonly property int maxAgeMin: Math.round(SL.retentionMs(retention) / 60000)

    Process {
        running: true
        command: ["sh", "-c", "command -v wl-paste >/dev/null && command -v wl-copy >/dev/null && echo wl; command -v cliphist >/dev/null && echo cliphist"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.hasWlClipboard = text.indexOf("wl") !== -1;
                root.cliphist = text.indexOf("cliphist") !== -1;
                root.detected = true;
            }
        }
    }

    // the watcher runs while history is on; restarts if wl-paste dies (compositor restart)
    Process {
        id: watcher
        running: root.detected && root.enabled && root.available
        command: root.cliphist
            ? ["sh", "-c", "wl-paste --watch cliphist store & wl-paste --type image --watch cliphist store & wait"]
            : [root.script, "watch", String(root.cap), "0"]
        stdout: SplitParser {
            onRead: line => {
                const it = SL.parseClipLine(line, false);
                if (it) root.items = SL.addClip(root.items, it, root.cap);
            }
        }
        onExited: if (root.enabled) restart.start()
    }
    Timer { id: restart; interval: 3000; onTriggered: watcher.running = root.detected && root.enabled && root.available }

    // full list (newest first); called when the Clipboard view opens and every few minutes
    function reload() {
        if (!enabled || !available) { items = []; return; }
        lister.exec(cliphist ? ["cliphist", "list"] : [script, "list", String(maxAgeMin)]);
    }
    Process {
        id: lister
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const l of text.split("\n")) { const it = SL.parseClipLine(l, root.cliphist); if (it) out.push(it); }
                root.items = SL.pruneClips(out, Date.now(), SL.retentionMs(root.retention)).slice(0, root.cap);
            }
        }
    }
    // expire old items while the shell runs
    Timer { running: root.enabled; interval: 300000; repeat: true; onTriggered: root.reload() }
    // turning history off deletes it (nothing copied is kept on disk without consent)
    onEnabledChanged: if (enabled) reload(); else if (detected && available) clear()
    onRetentionChanged: reload()

    function copy(item) {
        if (cliphist) Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", item.id]);
        else Quickshell.execDetached([script, "copy", item.file]);
    }
    function clear() {
        Quickshell.execDetached(cliphist ? ["cliphist", "wipe"] : [script, "clear"]);
        items = [];
    }
}
