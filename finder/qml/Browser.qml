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
    readonly property bool isVirtual: isVirtualPath(path)
    // whether entries are the user's files (trash, tag); Applications lists .desktop files
    readonly property bool userFiles: path !== "applications:"
    // items can be dragged out (not from Applications, nor from the Trash: a plain mv would orphan .trashinfo)
    readonly property string trashPath: FileOps.standardPath("trash")
    readonly property bool canDrag: userFiles && path !== trashPath && path.indexOf(trashPath + "/") !== 0

    property string sortKey: "name"
    property bool ascending: true
    property bool foldersFirst: false
    property bool showHidden: false
    property string query: ""

    property var allEntries: []
    // sorting is cached apart from the search filter, so typing a query does not re-sort
    // Recents is always newest first (like Finder) without touching the user's folder sort.
    readonly property bool recents: path === "recents:"
    readonly property var sorted: Files.sortEntries(allEntries, recents ? "modified" : sortKey,
                                                    recents ? false : ascending, foldersFirst)
    // List view: folders open in place (disclosure triangles). expanded: folder path -> its raw listing.
    property bool treeMode: false
    property var expanded: ({})
    readonly property var entries: Files.flattenTree(Files.filterEntries(sorted, query), treeMode ? expanded : null,
                                                     list => Files.sortEntries(list, sortKey, ascending, foldersFirst))
    function isExpanded(p) { return expanded[p] !== undefined; }
    // open or close a folder row; closing also forgets the folders opened inside it
    function setExpanded(entry, open) {
        if (!entry || !entry.isDir || isExpanded(entry.path) === open) return;
        const e = Object.assign({}, expanded);
        if (open) e[entry.path] = FileOps.list(entry.path, showHidden);
        else for (const k in e) if (k === entry.path || k.indexOf(entry.path + "/") === 0) delete e[k];
        expanded = e;
    }

    // selection: path -> true. Always reassigned (never mutated) so bindings on it update.
    property var selected: ({})
    property string renamingPath: ""  // item being renamed inline
    // Cursor and anchor are kept as paths so re-sorting, filtering or reloading can't
    // make them point at another item; the indices are derived.
    property string cursorPath: ""   // keyboard focus
    property string anchorPath: ""   // shift-click range start
    readonly property int cursor: cursorPath ? entries.findIndex(e => e.path === cursorPath) : -1
    readonly property int anchor: anchorPath ? entries.findIndex(e => e.path === anchorPath) : -1
    // Only visible (not filtered out by search) items count as selected for actions.
    readonly property var selectedVisible: entries.filter(e => selected[e.path] === true)
    readonly property int selectedCount: selectedVisible.length

    // Desktop and Documents carry Finder's " — Local" suffix (not synced to iCloud)
    readonly property string title: path === "recents:" ? "Recents"
        : path === "applications:" ? "Applications"
        : path.indexOf("tag:") === 0 ? path.slice(4)
        : path === FileOps.homePath() ? Files.baseName(path)
        : path === FileOps.standardPath("documents") || path === FileOps.standardPath("desktop") ? Files.title(path) + " \u2014 Local"
        : Files.title(path)

    signal errorRaised(string message)

    // in-window drag and drop (DragSession in Main.qml); views read it for drop highlights and cursors
    property var dragSession: null

    // Folders list synchronously (callers select the result right away); virtual locations
    // can be slow (xbel, every .desktop file, tag index) and load on a worker thread.
    property int _token: 0
    function reload() {
        FileOps.watch(isVirtual ? "" : path);
        if (isVirtual) {
            FileOps.listAsync(path, ++_token);
        } else {
            _token++;   // drop any virtual listing still in flight
            _setEntries(FileOps.list(path, showHidden));
            const e = {};   // re-list open folders; drop the ones that are gone
            for (const k in expanded) if (FileOps.isDir(k)) e[k] = FileOps.list(k, showHidden);
            expanded = e;
        }
    }
    function _setEntries(list) {
        allEntries = list;
        // keep only selections that still exist
        const keep = {};
        for (const e of list) if (selected[e.path]) keep[e.path] = true;
        selected = keep;
    }

    function go(p) {
        if (!p || p === path) return;
        if (!isVirtualPath(p) && !FileOps.isDir(p)) return;
        history = history.slice(0, historyIndex + 1).concat([p]);
        historyIndex = history.length - 1;
        _enter(p);
    }
    // Tags: toggles `tag` on every selected item.
    function toggleTag(tag) {
        if (!userFiles) return;
        const sel = selectedVisible;
        const all = sel.length > 0 && sel.every(e => (e.tags || []).indexOf(tag) !== -1);
        for (const e of sel) {
            const t = (e.tags || []).filter(x => x !== tag);
            if (!all) t.push(tag);
            const err = FileOps.setTags(e.path, t);
            if (err) { errorRaised(err); break; }
        }
        reload();
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
        query = "";
        selected = ({});
        cursorPath = "";
        anchorPath = "";
        allEntries = [];   // don't show the previous folder while an async listing loads
        expanded = ({});
        reload();
    }
    function isVirtualPath(p) { return p === "recents:" || p === "applications:" || p.indexOf("tag:") === 0; }

    // ---------- selection ----------
    function isSelected(p) { return selected[p] === true; }
    function selectedPaths() { return selectedVisible.map(e => e.path); }
    function selectedEntries() { return selectedVisible; }
    function clearSelection() { selected = ({}); anchorPath = ""; }
    function selectAll() {
        const s = {};
        for (const e of entries) s[e.path] = true;
        selected = s;
    }
    function selectPaths(paths) {
        const s = {};
        for (const p of paths) s[p] = true;
        selected = s;
        const first = entries.find(e => s[e.path]);
        cursorPath = first ? first.path : "";
        anchorPath = cursorPath;
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
            anchorPath = p;
        } else {
            selected = { [p]: true };
            anchorPath = p;
        }
        cursorPath = p;
    }
    // base: selection to extend (e.g. the one from before a rubber-band drag started)
    function setSelection(indices, base) {
        const s = Object.assign({}, base || {});
        for (const i of indices) s[entries[i].path] = true;
        selected = s;
    }
    // Arrow keys: delta in items (a grid row is `columns` items).
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
        if (paths.length === 0 || !userFiles) return;
        FileOps.trash(paths);   // async, see onTrashFinished
    }
    // Drop of `paths` on folder `dest`: op "move" | "copy" | "link" | "trash" (async, see onTransferFinished)
    function drop(paths, dest, op) {
        if (paths.length === 0) return;
        if (op === "trash") FileOps.trash(paths);
        else FileOps.transfer(paths, dest, op);
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

    // QtObject has no default property, so the Connections lives in a property
    property Connections _watch: Connections {
        target: FileOps
        function onDirectoryChanged(dir) { if (dir === b.path) b.reload(); }
        function onListed(token, list) { if (token === b._token) b._setEntries(list); }
        function onTrashFinished(error) {
            if (error) b.errorRaised(error);
            // Finder's TMoveToTrashTask plays system sound 16 (dock/drag to trash.aif; MAC-ANSWERS.md "Sound ID ->
            // file"); sound.sh event "trash-move" is the Move to Trash event (its file mapping lives in sound.sh)
            else FileOps.playSound("trash-move");
            b.reload();
        }
        // TEmptyTrashTask: system sound 13, finder/empty trash.aif (sound.sh "trash-empty")
        function onTrashEmptied(error) {
            if (error) b.errorRaised(error);
            else FileOps.playSound("trash-empty");
            b.reload();
        }
        function onTransferFinished(error) {
            if (error) b.errorRaised(error);
            b.reload();   // virtual lists (Recents, tags) hold the old paths too
        }
    }
    onShowHiddenChanged: reload()
    Component.onCompleted: reload()
}
