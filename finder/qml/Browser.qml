import QtQuick
import Finder.Native
import "lib/files.js" as Files

// Navigation, listing and selection state of one Finder window.
// Virtual locations: "recents:" and "applications:"; everything else is a local path.
QtObject {
    id: b

    property string path: FileOps.homePath()
    property var history: [path]
    property int historyIndex: 0
    readonly property bool canGoBack: historyIndex > 0
    readonly property bool canGoForward: historyIndex < history.length - 1
    readonly property bool isVirtual: path.indexOf(":") !== -1 && path[0] !== "/"

    property string sortKey: "name"
    property bool ascending: true
    property bool foldersFirst: false
    property bool showHidden: false
    property string query: ""

    property var allEntries: []
    readonly property var entries: Files.filterEntries(Files.sortEntries(allEntries, sortKey, ascending, foldersFirst), query)

    // selection: path -> true. selRev bumps on every change so bindings can depend on it.
    property var selected: ({})
    property int selRev: 0
    property string renamingPath: ""  // item being renamed inline
    property int cursor: -1          // keyboard focus index into entries
    property int anchor: -1          // shift-click range start
    readonly property int selectedCount: { selRev; return Object.keys(selected).length; }

    readonly property string title: path === "recents:" ? "Recents"
        : path === "applications:" ? "Applications"
        : path === FileOps.homePath() ? FileOps.homePath().split("/").pop()
        : Files.title(path)

    signal errorRaised(string message)

    function reload() {
        let list;
        if (path === "recents:") list = FileOps.recents(200);
        else if (path === "applications:") list = FileOps.applications();
        else list = FileOps.list(path, showHidden);
        allEntries = list;
        // keep only selections that still exist
        const keep = {};
        for (const e of list) if (selected[e.path]) keep[e.path] = true;
        selected = keep;
        selRev++;
        FileOps.watch(isVirtual ? "" : path);
    }

    function go(p) {
        if (!p || p === path) return;
        if (!isVirtualPath(p) && !FileOps.isDir(p)) return;
        history = history.slice(0, historyIndex + 1).concat([p]);
        historyIndex = history.length - 1;
        _enter(p);
    }
    function back() { if (canGoBack) { historyIndex--; _enter(history[historyIndex]); } }
    function forward() { if (canGoForward) { historyIndex++; _enter(history[historyIndex]); } }
    function up() {
        if (isVirtual || path === "/") return;
        const from = path;
        go(Files.parentPath(path));
        selectPaths([from]);
    }
    function _enter(p) {
        path = p;
        renamingPath = "";
        // Recents lists newest first, like Finder
        if (p === "recents:") { sortKey = "modified"; ascending = false; }
        query = "";
        selected = ({});
        cursor = -1;
        anchor = -1;
        reload();
    }
    function isVirtualPath(p) { return p === "recents:" || p === "applications:"; }

    // ---------- selection ----------
    function isSelected(p) { return selected[p] === true; }
    function selectedPaths() { return Object.keys(selected); }
    function selectedEntries() { return entries.filter(e => selected[e.path]); }
    function clearSelection() { selected = ({}); anchor = -1; selRev++; }
    function selectAll() {
        const s = {};
        for (const e of entries) s[e.path] = true;
        selected = s;
        selRev++;
    }
    function selectPaths(paths) {
        const s = {};
        for (const p of paths) s[p] = true;
        selected = s;
        const i = entries.findIndex(e => s[e.path]);
        cursor = i;
        anchor = i;
        selRev++;
    }
    // Click semantics: plain = only this, ctrl = toggle, shift = range from anchor.
    function click(index, modifiers) {
        if (index < 0 || index >= entries.length) return;
        const p = entries[index].path;
        if (modifiers & Qt.ShiftModifier && anchor >= 0) {
            const s = (modifiers & Qt.ControlModifier) ? Object.assign({}, selected) : {};
            const lo = Math.min(anchor, index), hi = Math.max(anchor, index);
            for (let i = lo; i <= hi; i++) s[entries[i].path] = true;
            selected = s;
        } else if (modifiers & Qt.ControlModifier) {
            const s = Object.assign({}, selected);
            if (s[p]) delete s[p]; else s[p] = true;
            selected = s;
            anchor = index;
        } else {
            // keep a multi-selection when pressing on an already selected item (drag start)
            if (!selected[p] || selectedCount <= 1) {
                selected = { [p]: true };
            }
            anchor = index;
        }
        cursor = index;
        selRev++;
    }
    function setSelection(indices, additive) {
        const s = additive ? Object.assign({}, selected) : {};
        for (const i of indices) s[entries[i].path] = true;
        selected = s;
        selRev++;
    }
    // Arrow keys: dx/dy in cells; cols = items per row (1 for lists).
    function moveCursor(delta, extend) {
        if (entries.length === 0) return;
        const next = cursor < 0 ? 0 : Math.max(0, Math.min(entries.length - 1, cursor + delta));
        click(next, extend ? Qt.ShiftModifier : Qt.NoModifier);
    }

    // ---------- actions ----------
    function activate(entry) {
        if (!entry) return;
        if (entry.isDir) go(entry.path);
        else if (entry.appId) FileOps.launchApp(entry.path);
        else FileOps.open(entry.path);
    }
    function openSelection() {
        const sel = selectedEntries();
        if (sel.length === 1) activate(sel[0]);
        else for (const e of sel) if (!e.isDir) activate(e);
    }
    function trashSelection() {
        const paths = selectedPaths();
        if (paths.length === 0 || isVirtual && path !== "recents:") return;
        const err = FileOps.trash(paths);
        if (err) errorRaised(err);
        reload();
    }
    function newFolder() {
        if (isVirtual) return;
        const created = FileOps.makeFolder(path, "untitled folder");
        if (!created) { errorRaised("You don’t have permission to create a folder here."); return; }
        reload();
        selectPaths([created]);
        renamingPath = created;
    }
    // Returns "" on success, otherwise the error (also raised).
    function rename(entry, newName) {
        const err = Files.validateName(newName, allEntries.map(e => e.name), entry.name)
                 || FileOps.rename(entry.path, newName);
        if (err) { errorRaised(err); return err; }
        if (newName !== entry.name) {
            const target = Files.joinPath(Files.parentPath(entry.path), newName);
            reload();
            selectPaths([target]);
        }
        return "";
    }

    property Connections _watch: Connections {
        target: FileOps
        function onDirectoryChanged(dir) { if (dir === b.path) b.reload(); }
    }
    onShowHiddenChanged: reload()
    Component.onCompleted: reload()
}
