import QtQuick
import Finder.Native
import HyprK
import "lib/files.js" as Files
import "../../ui/HyprK/panels.js" as PanelLayout
import "../../settings/Parsers.js" as P   // appearance.json normalization, shared with Settings

// Finder window: frameless, client-side traffic lights, flush full-height sidebar, unified toolbar.
Window {
    id: win

    readonly property var startSize: /^\d+x\d+$/.test(startup.size) ? startup.size.split("x").map(Number) : [Theme.win.width, Theme.win.height]
    width: startSize[0]
    height: startSize[1]
    minimumWidth: Theme.win.minWidth
    minimumHeight: Theme.win.minHeight
    visible: true
    title: fm.title
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    property string view: ["icons", "list", "columns", "gallery"].indexOf(startup.view) !== -1 ? startup.view : "icons"
    property bool showPathBar: startup.pathBar
    property var quickLookEntry: null
    // last left press in the window (Quick Look closes into the item there); a passive PointHandler sees every press
    property point lastPress: Qt.point(width / 2, height / 2)
    PointHandler { acceptedButtons: Qt.LeftButton | Qt.RightButton; onActiveChanged: if (active) win.lastPress = point.scenePosition }
    // a zoomed (maximized) window keeps its corners and rims on macOS; only full screen drops them. (Hyprland
    // also reports a floating window as maximized to Qt.)
    readonly property bool fullScreen: visibility === Window.FullScreen
    readonly property int radius: fullScreen ? 0 : Theme.win.radius

    Browser {
        id: fm
        path: /^(recents:|applications:|tag:)/.test(startup.path) || FileOps.isDir(startup.path) ? startup.path : FileOps.homePath()
        history: [path]
        treeMode: win.view === "list"
        onErrorRaised: message => alert.ask(message.split("\n")[0], message.split("\n").slice(1).join("\n"), [{ text: "OK" }])
        // the inline editor held focus; hand it back so shortcuts keep working
        onRenamingPathChanged: if (!renamingPath) keys.forceActiveFocus()
        dragSession: dnd
    }

    // The system appearance (state/appearance.json, written by Settings and the shell), followed live through
    // inotify (StateFile) like Settings' AppState. --dark forces dark for reference screenshots.
    StateFile { id: appearanceFile; path: startup.stateDir + "/appearance.json" }
    readonly property var appearance: P.mergeState(appearanceFile.text, null, P.normalizeAppearance)
    // wallpaper (state/wallpaper.json {path}) -> its mean colour for the sidebar chameleon tint, once per change
    StateFile { id: wallpaperFile; path: startup.stateDir + "/wallpaper.json" }
    WallpaperTint {
        path: P.mergeState(wallpaperFile.text, null, o => o).path || startup.stateDir + "/../themes/wallpapers/png/DefaultAerial.png"
        onTintChanged: Theme.chameleon = tint
    }

    Component.onCompleted: {
        Theme.dark = Qt.binding(() => startup.dark || win.appearance.dark);
        Theme.appearance = Qt.binding(() => win.appearance);
        Theme.blur = startup.blur;
        Theme.hasSysIcons = startup.hasSysIcons;
        Theme.active = Qt.binding(() => win.active && !startup.inactive);
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
        if (startup.panel) panelTimer.start();
    }
    Timer { id: panelTimer; interval: 300; onTriggered: win.openPanel(startup.panel) }   // after the first layout
    // --panel: open a panel for reference screenshots (alert2 / alert3 are sample texts and do nothing)
    function openPanel(name) {
        if (name === "alert2")
            alert.ask("Are you sure you want to delete \u201COld Letter.rtf\u201D?",
                      "This item will be deleted immediately. You can\u2019t undo this action.",
                      [{ text: "Delete", destructive: true }, { text: "Cancel", cancel: true }]);
        else if (name === "alert3")
            alert.ask("Do you want to keep this new document \u201CUntitled\u201D?",
                      "You can choose to save your changes, or delete this document immediately. You can\u2019t undo this action.",
                      [{ text: "Save\u2026" }, { text: "Cancel", cancel: true }, { text: "Delete", destructive: true }]);
        else if (name === "sheet") renameSheet.open(fm.selectedEntries());
        else if (name === "popover") toolbar.tagRequested(toolbar.tagAnchor);
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
        anchors.fill: parent
        radius: win.radius
        color: Theme.color.window
    }

    Sidebar {
        width: Theme.sidebar.width
        height: parent.height
        topLeftRadius: win.radius
        bottomLeftRadius: win.radius
        browser: fm
    }

    TrafficLights {
        x: Theme.lights.x
        y: Theme.lights.y
        active: Theme.active
        fullScreenButton: true   // green = full screen, Option-click = zoom (MAC-ANSWERS.md Q-windows-19)
        onCloseClicked: win.close()
        onMinimizeClicked: win.showMinimized()
        onZoomClicked: win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized()
        onFullScreenClicked: win.visibility === Window.FullScreen ? win.showNormal() : win.showFullScreen()
    }

    // dark list view: the header's solid bar continues under the toolbar (hard pocket, Q-finder-17)
    Rectangle {
        visible: win.view === "list" && Theme.dark
        x: Theme.sidebar.width
        width: parent.width - x
        height: Theme.toolbar.height
        topRightRadius: win.radius
        color: Theme.color.listHeaderFill
    }

    // ---------- content ----------
    Item {
        id: keys
        x: Theme.sidebar.width
        width: parent.width - x
        height: parent.height
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
            onTagRequested: anchor => tagPopover.show(anchor)
        }

        Loader {
            id: viewLoader
            anchors.top: toolbar.bottom
            anchors.bottom: pathBar.visible ? pathBar.top : parent.bottom
            anchors.bottomMargin: 0
            width: parent.width
            sourceComponent: ({ icons: iconView, list: listView, columns: columnView, gallery: galleryView })[win.view]
        }
        Component { id: iconView; IconView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: listView; FileList { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: columnView; ColumnView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: galleryView; GalleryView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }


        PathBar {
            id: pathBar
            visible: win.showPathBar
            anchors.bottom: parent.bottom
            width: parent.width
            browser: fm
        }

        Keys.onPressed: event => win.handleKey(event)
    }

    // inner white rim over the sidebar and content; the compositor draws the outer black one (Tokens.frame)
    Rectangle {
        anchors.fill: parent
        visible: !win.fullScreen
        radius: win.radius
        color: "transparent"
        border.width: Tokens.frame.rimWidth
        border.color: Tokens.frame.rim(Theme.active)
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
            else if (view === "list") { for (const e of fm.selectedEntries()) fm.setExpanded(e, false); }
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
            } else if (view === "list") { for (const e of fm.selectedEntries()) fm.setExpanded(e, true); }
            else move(1);
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
    // one item: inline; several: the Rename Finder Items sheet
    function startRename() {
        if (fm.isVirtual) return;
        if (fm.selectedCount === 1) fm.renamingPath = fm.selectedPaths()[0];
        else if (fm.selectedCount > 1) renameSheet.open(fm.selectedEntries());
    }
    // The 27.2.1 context menus (live/finder/crops/context-menu-{file,folder,background}-light.png), in the Mac's order,
    // with its leading symbols and submenus; Finder shows no shortcuts in context menus. Rows hyprk cannot do are
    // left out where a Mac without the feature has none (Ask Siri: Siri off; Open in New Tab: no tabs; Customise
    // Folder…, Clean Up, Clean Up By, Show View Options, Use Groups) or shown disabled where the Mac always has the
    // row (Share…, Quick Actions ▸ Customise…, Services ▸ No Services Apply). The tag dots follow Share….
    function contextMenu(entry, pos) {
        const sel = fm.selectedEntries();
        const n = sel.length;
        const paths = sel.map(e => e.path);
        const writable = !fm.isVirtual;
        const one = n === 1 ? sel[0] : null;
        const tail = [
            { text: "Share…", icon: "square.and.arrow.up", enabled: false },
            { separator: true },
            { tagRow: true, action: tag => fm.toggleTag(tag) },
            { separator: true },
            { text: "Quick Actions", icon: "gear", submenu: [{ text: "Customise…", enabled: false }] },
            { separator: true },
            { text: "Services", icon: "gear.2", submenu: [{ text: "No Services Apply", enabled: false }] }
        ];
        let items;
        if (entry) {
            const apps = one && !one.isDir ? FileOps.appsFor(one.path) : [];
            const openWith = apps.map(a => ({ text: a.name + (a.isDefault ? " (default)" : ""),
                                             action: () => FileOps.openWith(a.desktop, paths) }));
            const def = openWith.length && apps[0].isDefault ? 1 : 0;
            if (def && openWith.length > 1) openWith.splice(1, 0, { separator: true });
            items = [
                { text: "Open", action: () => fm.openSelection() }
            ].concat(one && one.isDir ? [] : [
                { text: "Open With", enabled: openWith.length > 0, submenu: openWith.length ? openWith : null }
            ]).concat(Clipboard.files.length && one && one.isDir && writable ? [
                { text: Clipboard.files.length > 1 ? "Paste Items" : "Paste Item", action: () => fm.drop(Clipboard.files, one.path, "copy") }
            ] : []).concat([
                { separator: true },
                { text: "Move to Trash", icon: "trash", enabled: n > 0 && fm.userFiles, action: () => fm.trashSelection() },
                { separator: true },
                { text: "Get Info", action: () => info.show(entry.path, pos.x, pos.y) },
                { text: n > 1 ? "Rename…" : "Rename", enabled: n > 0 && writable, action: () => win.startRename() },
                { text: n > 1 ? "Compress " + n + " Items" : "Compress “" + entry.name + "”", enabled: writable, action: () => FileOps.compress(paths) },
                { text: "Duplicate", enabled: writable, action: () => FileOps.duplicate(paths) },
                { text: "Make Alias", enabled: writable, action: () => { const e = FileOps.makeAlias(paths); if (e) fm.errorRaised(e); fm.reload(); } },
                { text: "Quick Look", action: () => win.quickLook() },
                { text: n > 1 ? "Copy " + n + " Items" : "Copy", action: () => Clipboard.copyFiles(paths) },
                { separator: true }
            ]).concat(tail).concat(fm.isVirtual ? [{ separator: true }, { text: "Show in Enclosing Folder", action: () => {
                fm.go(Files.parentPath(entry.path));
                fm.selectPaths([entry.path]);
            } }] : []);
        } else {
            const view = (key, label) => ({ text: label, checked: win.view === key, action: () => win.view = key });
            items = [
                { text: "New Folder", enabled: writable, action: () => fm.newFolder() }
            ].concat(Clipboard.files.length && writable ? [
                { text: Clipboard.files.length > 1 ? "Paste Items" : "Paste Item", action: () => fm.drop(Clipboard.files, fm.path, "copy") }
            ] : []).concat([
                { separator: true },
                { text: "Get Info", enabled: writable, action: () => info.show(fm.path, pos.x, pos.y) },
                { separator: true },
                { text: "View", submenu: [view("icons", "as Icons"), view("list", "as List"), view("columns", "as Columns"), view("gallery", "as Gallery")] },
                { text: "Sort By", submenu: sortItems() }
            ]);
        }
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
        { text: fm.selectedCount > 1 ? "Rename\u2026" : "Rename", enabled: fm.selectedCount > 0 && !fm.isVirtual, action: () => win.startRename() },
        { text: "Move to Trash", enabled: fm.selectedCount > 0 && fm.userFiles, action: () => fm.trashSelection() },
        { separator: true },
        { text: win.showPathBar ? "Hide Path Bar" : "Show Path Bar", shortcut: "⌥⌃P", action: () => win.showPathBar = !win.showPathBar },
        { text: fm.showHidden ? "Hide Hidden Files" : "Show Hidden Files", shortcut: "⇧⌃.", action: () => fm.showHidden = !fm.showHidden }
    ]

    // ---------- overlays ----------
    InfoPopover { id: info; anchors.fill: parent; onClosed: keys.forceActiveFocus() }
    QuickLook {
        width: Math.min(parent.width - 80, 760)
        height: Math.min(parent.height - 80, 560)
        anchors.centerIn: parent
        entry: win.quickLookEntry
        closeTo: win.lastPress
        onCloseRequested: win.quickLookEntry = null
    }

    // app-modal alert: no dim, centred, its top at 0.26 of the window minus a quarter of its height (Q-panels-33)
    AlertPanel {
        id: alert
        x: (win.width - width) / 2
        y: PanelLayout.alertTop(win.height, height)
        icon: startup.hasAppIcons ? Files.fileUrl(startup.iconRoot + "/apps/Finder-512.png") : ""
        property var actions: []
        function ask(title, message, buttons) {
            alert.title = title;
            alert.message = message;
            alert.buttons = buttons;
            alert.shown = true;
        }
        onActivated: index => {
            shown = false;
            keys.forceActiveFocus();
            const b = buttons[index];
            if (b && b.action) b.action();
        }
        MouseArea {   // the window takes no clicks while the alert is up
            parent: win.contentItem
            z: 1
            anchors.fill: parent
            visible: alert.shown
        }
        z: 2
    }

    RenameSheet {
        id: renameSheet
        anchors.fill: parent
        z: 3
        browser: fm
        onShownChanged: if (!shown) keys.forceActiveFocus()
    }

    TagPopover {
        id: tagPopover
        anchors.fill: parent
        z: 4
        browser: fm
        onClosed: keys.forceActiveFocus()
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
