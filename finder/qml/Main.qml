import QtQuick
import Finder.Native
import HyprK
import "lib/files.js" as Files

// Finder window: frameless, client-side traffic lights, floating sidebar, unified toolbar.
Window {
    id: win

    width: Theme.win.width
    height: Theme.win.height
    minimumWidth: Theme.win.minWidth
    minimumHeight: Theme.win.minHeight
    visible: true
    title: fm.title
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    property string view: ["icons", "list", "columns", "gallery"].indexOf(startup.view) !== -1 ? startup.view : "icons"
    property bool showPathBar: false
    property var quickLookEntry: null
    readonly property bool maximized: visibility === Window.Maximized || visibility === Window.FullScreen
    readonly property int radius: maximized ? 0 : Theme.win.radius

    Browser {
        id: fm
        path: /^(recents:|applications:|tag:)/.test(startup.path) || FileOps.isDir(startup.path) ? startup.path : FileOps.homePath()
        history: [path]
        onErrorRaised: message => alert.show(message)
        // the inline editor held focus; hand it back so shortcuts keep working
        onRenamingPathChanged: if (!renamingPath) keys.forceActiveFocus()
        dragSession: dnd
    }

    Component.onCompleted: {
        Theme.dark = startup.dark;
        Theme.blur = startup.blur;
        Theme.hasSysIcons = startup.hasSysIcons;
        Qt.callLater(applyStartup);
        keys.forceActiveFocus();
    }
    // after Browser has listed the folder
    function applyStartup() {
        if (startup.select) {
            const hit = fm.entries.find(e => e.name === startup.select);
            if (hit) fm.selectPaths([hit.path]);
        }
        if (startup.quicklook) quickLook();
    }

    function quickLook() {
        if (quickLookEntry) { quickLookEntry = null; return; }
        const sel = fm.selectedEntries();
        if (sel.length > 0) quickLookEntry = sel[0];
    }
    function focusContent() { keys.forceActiveFocus(); }
    function setView(v) {
        view = v;
        keys.forceActiveFocus();
    }

    // ---------- window frame ----------
    Rectangle {
        id: frame
        anchors.fill: parent
        radius: win.radius
        color: Theme.color.window
        border.width: win.maximized ? 0 : 1
        border.color: Theme.color.windowBorder
    }

    Sidebar {
        x: frame.border.width
        y: frame.border.width
        width: Theme.sidebar.width - x
        height: parent.height - 2 * y
        topLeftRadius: win.radius
        bottomLeftRadius: win.radius
        browser: fm
    }

    TrafficLights {
        x: Theme.lights.x
        y: Theme.lights.y
        active: win.active
        onCloseClicked: win.close()
        onMinimizeClicked: win.showMinimized()
        onZoomClicked: win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized()
    }

    // ---------- content ----------
    Item {
        id: keys
        x: Theme.sidebar.width
        y: frame.border.width
        width: parent.width - x - frame.border.width
        height: parent.height - 2 * y
        focus: true

        Toolbar {
            id: toolbar
            width: parent.width
            browser: fm
            window: win
            view: win.view
            onViewRequested: v => win.setView(v)
            onMoreRequested: anchor => win.popup(win.moreMenu, anchor)
            onGroupRequested: anchor => win.popup(win.sortItems(), anchor)
            onTagRequested: anchor => win.popup([{ tagRow: true, action: tag => fm.toggleTag(tag) }], anchor)
        }

        Loader {
            id: viewLoader
            anchors.top: toolbar.bottom
            anchors.bottom: pathBar.visible ? pathBar.top : parent.bottom
            anchors.bottomMargin: pathBar.visible ? 0 : win.radius / 2
            width: parent.width
            sourceComponent: ({ icons: iconView, list: listView, columns: columnView, gallery: galleryView })[win.view]
        }
        Component { id: iconView; IconView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: listView; FileList { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: columnView; ColumnView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: galleryView; GalleryView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }

        Text {
            visible: fm.entries.length === 0 && fm.query !== ""
            anchors.centerIn: viewLoader
            text: "No Results"
            color: Theme.color.tertiaryLabel
            font.family: Theme.fontText
            font.pixelSize: 15
        }

        PathBar {
            id: pathBar
            visible: win.showPathBar
            anchors.bottom: parent.bottom
            anchors.bottomMargin: win.radius / 2
            width: parent.width
            browser: fm
        }

        Keys.onPressed: event => win.handleKey(event)
    }

    function handleKey(event) {
        const ctrl = event.modifiers & Qt.ControlModifier;
        const alt = event.modifiers & Qt.AltModifier;
        const shift = event.modifiers & Qt.ShiftModifier;
        const cols = viewLoader.item ? viewLoader.item.columns : 1;
        const move = d => {
            fm.moveCursor(d, shift);
            if (quickLookEntry) quickLookEntry = fm.selectedEntries()[0] || null;
            if (viewLoader.item) viewLoader.item.ensureVisible(fm.cursor);
        };
        switch (event.key) {
        case Qt.Key_Space: quickLook(); break;
        case Qt.Key_Escape:
            if (quickLookEntry) quickLookEntry = null;
            else if (fm.query) { fm.query = ""; toolbar.searching = false; }
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            if (fm.selectedCount === 1 && !fm.isVirtual) fm.renamingPath = fm.selectedPaths()[0];
            break;
        case Qt.Key_Delete: fm.trashSelection(); break;
        case Qt.Key_Backspace: if (ctrl) fm.trashSelection(); break;
        case Qt.Key_Left:
            if (alt) fm.back();
            else if (view === "columns") fm.up();
            else move(-1);
            break;
        case Qt.Key_Right:
            if (alt) fm.forward();
            else if (view === "columns") {
                const sel = fm.selectedEntries();
                if (sel.length === 1 && sel[0].isDir) {
                    fm.go(sel[0].path);
                    fm.click(0, Qt.NoModifier);
                }
            } else move(1);
            break;
        case Qt.Key_Up:
            if (ctrl || alt) fm.up();
            else move(-cols);
            break;
        case Qt.Key_Down:
            if (ctrl) fm.openSelection();
            else move(cols);
            break;
        default:
            if (ctrl || !event.text || event.text.trim() === "") return;
            typeSelect(event.text);
        }
        event.accepted = true;
    }

    // type-to-select: jump to the first item whose name starts with the typed text
    property string typed: ""
    Timer { id: typedReset; interval: 900; onTriggered: win.typed = "" }
    function typeSelect(ch) {
        typed += ch.toLowerCase();
        typedReset.restart();
        const i = fm.entries.findIndex(e => e.name.toLowerCase().indexOf(typed) === 0);
        if (i >= 0) {
            fm.click(i, Qt.NoModifier);
            if (viewLoader.item) viewLoader.item.ensureVisible(i);
        }
    }

    // macOS Cmd shortcuts mapped to Ctrl
    Shortcut { sequence: "Ctrl+1"; onActivated: win.setView("icons") }
    Shortcut { sequence: "Ctrl+2"; onActivated: win.setView("list") }
    Shortcut { sequence: "Ctrl+3"; onActivated: win.setView("columns") }
    Shortcut { sequence: "Ctrl+4"; onActivated: win.setView("gallery") }
    Shortcut { sequence: "Ctrl+["; onActivated: fm.back() }
    Shortcut { sequence: "Ctrl+]"; onActivated: fm.forward() }
    Shortcut { sequence: "Ctrl+A"; onActivated: fm.selectAll() }
    Shortcut { sequence: "Ctrl+O"; onActivated: fm.openSelection() }
    Shortcut { sequence: "Ctrl+F"; onActivated: toolbar.focusSearch() }
    Shortcut { sequence: "Ctrl+Shift+N"; onActivated: fm.newFolder() }
    Shortcut { sequence: "Ctrl+Shift+H"; onActivated: fm.go(FileOps.homePath()) }
    Shortcut { sequence: "Ctrl+Shift+D"; onActivated: fm.go(FileOps.standardPath("desktop")) }
    Shortcut { sequence: "Ctrl+Shift+O"; onActivated: fm.go(FileOps.standardPath("documents")) }
    Shortcut { sequence: "Ctrl+Alt+L"; onActivated: fm.go(FileOps.standardPath("downloads")) }
    Shortcut { sequence: "Ctrl+Shift+A"; onActivated: fm.go("applications:") }
    Shortcut { sequence: "Ctrl+Shift+F"; onActivated: fm.go("recents:") }
    Shortcut { sequence: "Ctrl+Shift+."; onActivated: fm.showHidden = !fm.showHidden }
    Shortcut { sequence: "Ctrl+Alt+P"; onActivated: win.showPathBar = !win.showPathBar }
    Shortcut { sequence: "Ctrl+W"; onActivated: win.close() }
    Shortcut { sequence: "Ctrl+Y"; onActivated: win.quickLook() }

    // ---------- menus ----------
    PopupMenu { id: menu }

    function popup(items, anchor) {
        const p = anchor.mapToItem(null, 0, anchor.height + 6);
        showMenu(items, p.x, p.y);
    }
    function showMenu(items, x, y) {
        menu.items = items;
        menu.x = Math.min(x, win.width - menu.width - 8);
        menu.y = Math.min(y, win.height - menu.implicitHeight - 8);
        menu.open();
    }
    function startRename() {
        if (fm.selectedCount === 1 && !fm.isVirtual) fm.renamingPath = fm.selectedPaths()[0];
    }
    function contextMenu(entry, pos) {
        const n = fm.selectedCount;
        const writable = !fm.isVirtual;
        const items = entry ? [
            { text: "Open", action: () => fm.openSelection() },
            { separator: true },
            { text: "Move to Trash", shortcut: "Del", enabled: n > 0 && fm.userFiles, action: () => fm.trashSelection() },
            { separator: true },
            { tagRow: true, action: tag => fm.toggleTag(tag) },
            { separator: true },
            { text: "Quick Look", shortcut: "Space", action: () => win.quickLook() },
            { text: "Rename", shortcut: "↩", enabled: n === 1 && writable, action: () => win.startRename() },
            { separator: true },
            { text: "Show in Enclosing Folder", enabled: fm.isVirtual, action: () => {
                fm.go(Files.parentPath(entry.path));
                fm.selectPaths([entry.path]);
            } }
        ] : [
            { text: "New Folder", shortcut: "⇧⌃N", enabled: writable, action: () => fm.newFolder() },
            { separator: true }
        ].concat(sortItems());
        showMenu(items, pos.x, pos.y);
    }
    function sortItems() {
        const sortBy = (key, label) => ({ text: label, checked: fm.sortKey === key,
                                          action: () => { fm.sortKey = key; fm.ascending = key === "name"; } });
        return [
            sortBy("name", "Sort by Name"), sortBy("kind", "Sort by Kind"),
            sortBy("modified", "Sort by Date Modified"), sortBy("size", "Sort by Size"),
            { separator: true },
            { text: "Keep Folders on Top", checked: fm.foldersFirst, action: () => fm.foldersFirst = !fm.foldersFirst }
        ];
    }
    readonly property var moreMenu: [
        { text: "New Folder", shortcut: "⇧⌃N", enabled: !fm.isVirtual, action: () => fm.newFolder() },
        { text: "Rename", enabled: fm.selectedCount === 1 && !fm.isVirtual, action: () => win.startRename() },
        { text: "Move to Trash", enabled: fm.selectedCount > 0 && fm.userFiles, action: () => fm.trashSelection() },
        { separator: true },
        { text: win.showPathBar ? "Hide Path Bar" : "Show Path Bar", shortcut: "⌥⌃P", action: () => win.showPathBar = !win.showPathBar },
        { text: fm.showHidden ? "Hide Hidden Files" : "Show Hidden Files", shortcut: "⇧⌃.", action: () => fm.showHidden = !fm.showHidden },
        { text: Theme.dark ? "Light Appearance" : "Dark Appearance", action: () => Theme.dark = !Theme.dark }
    ]

    // ---------- overlays ----------
    QuickLook {
        width: Math.min(parent.width - 80, 760)
        height: Math.min(parent.height - 80, 560)
        anchors.centerIn: parent
        entry: win.quickLookEntry
        onCloseRequested: win.quickLookEntry = null
    }

    Alert {
        id: alert
        anchors.fill: parent
        onMessageChanged: if (message === "") keys.forceActiveFocus()
    }

    ResizeEdges {
        anchors.fill: parent
        window: win
    }

    DragSession {
        id: dnd
        anchors.fill: parent
        browser: fm
        iconSize: win.view === "icons" ? Theme.grid.iconSize : 32
    }
}
