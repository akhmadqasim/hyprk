pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/spotlight.js" as SL

// File results for Spotlight: recent files (~/.local/share/recently-used.xbel) first,
// then a search of $HOME with the fastest tool found: plocate, locate, fd/fdfind, find.
// Searches are debounced, a new query kills the old search, hits are published in batches.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    property string query: ""
    property string tool: ""            // detected search tool ("" until detection finishes)
    property var recents: []            // [{path, name, dir, isDir, mime}] (existing files only)
    property var hits: []               // rows of the current search
    property bool searching: search.running
    readonly property int limit: 40
    readonly property var results: SL.mergeFiles(recents, hits, query, limit)

    Process {
        running: true
        command: ["sh", "-c", "for t in plocate locate fd fdfind; do command -v $t >/dev/null && { echo $t; exit; }; done; echo find"]
        stdout: StdioCollector { onStreamFinished: root.tool = text.trim() }
    }

    // ---------- recents ----------
    // the xbel is parsed when it changes; existence is checked when Spotlight shows files
    property var xbelRows: []           // parsed, newest first
    FileView {
        path: (Quickshell.env("XDG_DATA_HOME") || root.home + "/.local/share") + "/recently-used.xbel"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { root.xbelRows = SL.parseXbel(text(), 60); root.loadRecents(); }
    }
    function loadRecents() {
        exists.exec(["sh", "-c", 'for p; do [ -e "$p" ] && echo "$p"; done', "sh"].concat(xbelRows.map(r => r.path)));
    }
    Process {
        id: exists
        stdout: StdioCollector {
            onStreamFinished: {
                const ok = new Set(text.split("\n"));
                root.recents = root.xbelRows.filter(r => ok.has(r.path)).map(r =>   // all 60: the Files grid scrolls (r17: about a dozen rows)
                    Object.assign(SL.fileRow(r.path + (r.mime === "inode/directory" ? "/" : ""), root.home), { mime: r.mime }));
            }
        }
    }

    // ---------- search ----------
    onQueryChanged: {
        search.running = false;
        pending = [];
        hits = [];
        if (query.trim().length < 2) { debounce.stop(); return; }
        debounce.restart();
    }
    Timer {
        id: debounce
        interval: 180
        onTriggered: if (root.tool) { search.forQuery = root.query; search.exec(SL.searchCommand(root.tool, root.query, root.home, root.limit)); }
    }
    onToolChanged: if (query.trim().length >= 2) debounce.restart()
    property var pending: []            // streamed rows not yet published
    Process {
        id: search
        property string forQuery: ""
        stdout: SplitParser {
            onRead: line => {
                // lines of a killed search can still arrive: keep only those of the current query
                if (search.forQuery !== root.query || !SL.matchesQuery(line, root.query)) return;
                root.pending.push(SL.fileRow(line, root.home));
                if (!publish.running) publish.start();
            }
        }
        onExited: publish.triggered()
    }
    // one model update per batch instead of one per line
    Timer {
        id: publish
        interval: 30
        onTriggered: {
            if (root.pending.length === 0) return;
            root.hits = root.hits.concat(root.pending).slice(0, root.limit);
            root.pending = [];
        }
    }

    function open(row) { Quickshell.execDetached(["xdg-open", row.path]); }
}
