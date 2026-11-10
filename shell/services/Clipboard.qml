pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/spotlight.js" as SL

// Clipboard history for Spotlight (Cmd+4). Off until the user turns it on
// (SpotlightState.clipboardHistory), like macOS 26. Backend: cliphist when installed,
// else scripts/clipboard.sh (files in $XDG_STATE_HOME/hyprk/clipboard, 200 items,
// expired by the retention setting). Both need wl-paste/wl-copy (wl-clipboard).
// Created by shell.qml only while history is on, or when Spotlight's Clipboard view opens.
Singleton {
    id: root

    readonly property string retention: SpotlightState.clipboardHistory
    readonly property int retentionMs: SL.retentionMs(retention)
    readonly property bool enabled: retentionMs > 0
    readonly property int cap: 200
    // tools, probed once on first use
    property bool detected: false
    property bool available: false       // wl-paste and wl-copy
    property bool cliphist: false
    readonly property bool shouldWatch: detected && enabled && available

    property var items: []       // [{id, file, mime, ts, text}] newest first
    readonly property string script: Quickshell.shellDir + "/scripts/clipboard.sh"

    Process {
        running: !root.detected
        command: ["sh", "-c", "command -v wl-paste >/dev/null && command -v wl-copy >/dev/null && echo wl; command -v cliphist >/dev/null && echo cliphist"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = text.indexOf("wl") !== -1;
                root.cliphist = text.indexOf("cliphist") !== -1;
                root.detected = true;
                root.reload();
            }
        }
    }

    // the watcher runs while history is on; restarts if wl-paste dies (compositor restart)
    Process {
        id: watcher
        running: root.shouldWatch
        command: root.cliphist
            ? ["sh", "-c", "wl-paste --watch cliphist store & wl-paste --type image --watch cliphist store & wait"]
            : [root.script, "watch", String(root.cap)]
        stdout: SplitParser {
            onRead: line => {
                const it = SL.parseClipLine(line, false);
                if (it) root.setItems(SL.addClip(root.items, it, root.cap));
            }
        }
        onExited: if (root.shouldWatch) restart.start()
    }
    Timer { id: restart; interval: 3000; onTriggered: watcher.running = root.shouldWatch }

    // full list from disk (expired files are deleted there); when the Clipboard view opens
    function reload() {
        if (!enabled || !available) { items = []; return; }
        lister.exec(cliphist ? ["cliphist", "list"] : [script, "list", String(Math.round(retentionMs / 60000))]);
    }
    Process {
        id: lister
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const l of text.split("\n")) { const it = SL.parseClipLine(l, root.cliphist); if (it) out.push(it); }
                root.setItems(out.slice(0, root.cap));
            }
        }
    }

    // expiry in memory: drop expired items and wake up again at the next expiry (no idle polling)
    function setItems(list) {
        items = SL.pruneClips(list, Date.now(), retentionMs);
        const next = SL.nextExpiry(items, retentionMs);
        if (next > 0) { expiry.interval = Math.max(1000, next - Date.now()); expiry.restart(); }
        else expiry.stop();
    }
    Timer { id: expiry; onTriggered: root.setItems(root.items) }

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
        expiry.stop();
    }
}
