pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/spotlight.js" as SL

// File results for Spotlight: recent files (~/.local/share/recently-used.xbel) first,
// then a search of $HOME with the fastest tool found: plocate, locate, fd/fdfind, find.
// Searches are debounced and stream their results; a new query kills the old search.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    property string query: ""
    property string tool: ""            // detected search tool ("" until detection finishes)
    property var recents: []            // [{path, name, dir, isDir, mime}] (existing files only)
    property var hits: []               // rows from the running / last search
    property bool searching: search.running
    readonly property int limit: 40
    readonly property var results: SL.mergeFiles(recents, hits, query, limit)

    Process {
        running: true
        command: ["sh", "-c", "for t in plocate locate fd fdfind; do command -v $t >/dev/null && { echo $t; exit; }; done; echo find"]
        stdout: StdioCollector { onStreamFinished: root.tool = text.trim() }
    }

    // ---------- recents ----------
    // read when Spotlight shows files; xbel paths that no longer exist are dropped
    function loadRecents() { xbel.reload(); }
    FileView {
        id: xbel
        path: (Quickshell.env("XDG_DATA_HOME") || root.home + "/.local/share") + "/recently-used.xbel"
        printErrors: false
        blockLoading: false
        onLoaded: {
            const list = SL.parseXbel(text(), 60);
            const mimes = {};
            for (const r of list) mimes[r.path] = r.mime;
            root.pendingMime = mimes;
            exists.exec(["sh", "-c", 'for p; do [ -e "$p" ] && { [ -d "$p" ] && echo "$p/" || echo "$p"; }; done', "sh"].concat(list.map(r => r.path)));
        }
    }
    property var pendingMime: ({})
    Process {
        id: exists
        stdout: StdioCollector {
            onStreamFinished: root.recents = text.split("\n").filter(l => l !== "").slice(0, 20).map(l => {
                const r = SL.fileRow(l, root.home);
                r.mime = root.pendingMime[r.path] || "";
                return r;
            })
        }
    }

    // ---------- search ----------
    onQueryChanged: {
        hits = [];
        if (query.trim().length < 2) { search.running = false; debounce.stop(); return; }
        debounce.restart();
    }
    Timer {
        id: debounce
        interval: 180
        onTriggered: if (root.tool) search.exec(SL.searchCommand(root.tool, root.query, root.home, root.limit))
    }
    onToolChanged: if (query.trim().length >= 2) debounce.restart()
    Process {
        id: search
        stdout: SplitParser {
            onRead: line => {
                // lines of a killed search can still arrive: keep only what matches now
                if (!SL.matchesQuery(line, root.query) || root.hits.length >= root.limit) return;
                root.hits = root.hits.concat([SL.fileRow(line, root.home)]);
            }
        }
    }

    function open(row) { Quickshell.execDetached(["xdg-open", row.path]); }
    function reveal(row) {
        // Finder-like: open the parent folder (hyprk Finder takes a dir argument)
        Quickshell.execDetached(["xdg-open", row.isDir ? row.path : row.path.slice(0, row.path.lastIndexOf("/")) || "/"]);
    }
}
