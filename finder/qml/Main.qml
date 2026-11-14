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
        // Emoji & Symbols open over this window keeps the key look, as the Mac's palette (Hypr.emojiOver)
        Theme.active = Qt.binding(() => (win.active || (Hypr.emojiOver !== "" && Hypr.emojiOver === win.title)) && !startup.inactive);
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
        if (startup.info) infoTimer.start();
        if (startup.panel) panelTimer.start();
    }
    Timer { id: panelTimer; interval: 300; onTriggered: win.openPanel(startup.panel) }   // after the first layout
    // --info (Spotlight's Cmd-I): Get Info on the selection, its popover on the item's icon (else the window's
    // middle, for the folder itself), after the first layout like --panel
    Timer { id: infoTimer; interval: 300; onTriggered: win.showInfo() }
    function showInfo() {
        const path = Files.infoTarget(fm.selectedEntries(), fm.path);
        const i = fm.entries.findIndex(e => e.path === path);
        const icon = i >= 0 && viewLoader.item && viewLoader.item.iconItem ? viewLoader.item.iconItem(i) : null;
        const p = icon ? icon.mapToItem(info, icon.width / 2, icon.height) : Qt.point(info.width / 2, info.height / 3);
        info.show(path, p.x, p.y);
    }
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

    // ---------- tabs ----------
    // each tab keeps its place ({ path, history, historyIndex, title, view }); `fm` shows the selected one. One tab
    // = no bar (tabs empty). New Tab opens where a new window does (home).
    property var tabs: []
    property int tabIndex: 0
    function saved() { return Object.assign(fm.state(), { view: win.view }); }
    function newTab(path) {
        if (!path) return;
        const t = tabs.length ? tabs.slice() : [saved()];
        t[tabIndex] = saved();
        t.push({ path: path, history: [path], historyIndex: 0, title: "", view: win.view });
        tabs = t;
        tabIndex = t.length - 1;
        fm.restore(t[tabIndex]);
        keys.forceActiveFocus();
    }
    function selectTab(i) {
        if (i === tabIndex || i < 0 || i >= tabs.length) return;
        const t = tabs.slice();
        t[tabIndex] = saved();
        tabs = t;
        tabIndex = i;
        quickLookEntry = null;
        view = t[i].view;
        fm.restore(t[i]);
        keys.forceActiveFocus();
    }
    function closeTab(i) {
        if (tabs.length < 2) { win.close(); return; }
        const t = tabs.slice();
        t[tabIndex] = saved();
        t.splice(i, 1);
        const next = i < tabIndex ? tabIndex - 1 : Math.min(tabIndex, t.length - 1);
        const switching = i === tabIndex;
        tabs = t.length > 1 ? t : [];
        tabIndex = t.length > 1 ? next : 0;
        if (switching) { view = t[next].view; fm.restore(t[next]); }
    }
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
        onContextMenuRequested: (item, kind, pos) => win.sidebarMenu(item, kind, pos)
    }

    TrafficLights {
        x: Theme.lights.x
        y: Theme.lights.y
        active: Theme.active
        fullScreenButton: true   // green = full screen, Option-click = zoom (MAC-ANSWERS.md Q-windows-19)
        onCloseClicked: win.close()
        onMinimizeClicked: win.minimize()
        onZoomClicked: win.zoom()
        onFullScreenClicked: win.visibility === Window.FullScreen ? win.showNormal() : win.showFullScreen()
    }

    // dark list view: the header's solid bar continues under the toolbar (hard pocket, Q-finder-17); the gallery has
    // the same kind of strip, (39,39,44), ended by a 1 px line at y 104 px that light has too (229 / (47,47,52);
    // gallery-{light,dark}.png)
    Rectangle {
        visible: (win.view === "list" || win.view === "gallery") && Theme.dark
        x: Theme.sidebar.width
        width: parent.width - x
        height: Theme.toolbar.height
        topRightRadius: win.radius
        color: win.view === "gallery" ? "#27272C" : Theme.color.listHeaderFill
    }
    Rectangle {
        visible: win.view === "gallery" && !tabBar.visible
        x: Theme.sidebar.width
        y: Theme.toolbar.height
        width: parent.width - x
        height: 0.5
        z: 1
        color: Theme.dark ? "#2F2F34" : "#E5E5E5"
    }

    // dark inactive window, other views: the toolbar strip lightens (Q-finder-29)
    Rectangle {
        visible: win.view !== "list" && Theme.dark && !Theme.active
        x: Theme.sidebar.width
        width: parent.width - x
        height: Theme.toolbar.height
        topRightRadius: win.radius
        color: Theme.color.toolbarStripInactive
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
            z: 2   // over the icon grid, which runs under it
            width: parent.width
            browser: fm
            window: win
            view: win.view
            onViewRequested: v => win.setView(v)
            onMoreRequested: anchor => win.actionMenu(anchor)
            onGroupRequested: anchor => win.popup(win.groupItems(), anchor)
            onTagRequested: anchor => tagPopover.show(anchor)
            onViewMenuRequested: anchor => win.popup(win.viewItems(), anchor)
        }

        // tabs (Q-finder-32): the bar shows with two or more; the track's bottom is at 80 (the gap under it was not
        // measured: 4 pt, so the list header does not touch it)
        TabBar {
            id: tabBar
            visible: win.tabs.length > 1
            x: 8
            y: Theme.toolbar.height
            width: parent.width - x - 8.5
            height: visible ? implicitHeight : 0
            titles: win.tabs.map((t, i) => i === win.tabIndex ? fm.title : t.title)
            current: win.tabIndex
            onSelected: i => win.selectTab(i)
            onCloseRequested: i => win.closeTab(i)
            onNewTabRequested: win.newTab(FileOps.homePath())
        }

        // icon view without tabs: the grid runs under the toolbar and scrolls through AppKit's scroll pocket, as a
        // Finder scroll view under a unified toolbar does (TOOLBAR-REA-27.2.1.md 1: -[NSToolbarView
        // _scrollPocketElementStyle] 0x18ad147cc returns the ThinFilm style for every toolbar; MAC-ANSWERS Q-windows-14:
        // the icons blur under the strip). List and gallery keep their hard strip (Q-finder-17), columns are not measured.
        readonly property bool underToolbar: win.view === "icons" && !tabBar.visible
        Loader {
            id: viewLoader
            anchors.top: tabBar.visible ? tabBar.bottom : keys.underToolbar ? parent.top : toolbar.bottom
            anchors.topMargin: tabBar.visible ? 4 : 0
            anchors.bottom: pathBar.visible ? pathBar.top : parent.bottom
            anchors.bottomMargin: 0
            width: parent.width
            sourceComponent: ({ icons: iconView, list: listView, columns: columnView, gallery: galleryView })[win.view]
        }
        Component { id: iconView; IconView { browser: fm; topInset: keys.underToolbar ? Theme.toolbar.height : 0
                                              onContextMenu: (e, p) => win.contextMenu(e, p) } }
        ScrollEdge {
            z: 1
            active: keys.underToolbar && viewLoader.item !== null && viewLoader.item.contentY > -viewLoader.item.topMargin + 0.5
            source: active ? viewLoader.item : null
            width: parent.width; height: Theme.toolbar.height
            dark: Theme.dark
            windowColor: Theme.color.window
            cornerRadius: win.fullScreen ? 0 : win.radius
        }
        Component { id: listView; FileList { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: columnView; ColumnView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p) } }
        Component { id: galleryView; GalleryView { browser: fm; onContextMenu: (e, p) => win.contextMenu(e, p); onTagRequested: anchor => tagPopover.show(anchor) } }


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
        case Qt.Key_Backspace: if (ctrl && !shift && !alt) fm.trashSelection(); break;
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
    Shortcut { sequence: "Ctrl+W"; onActivated: win.tabs.length > 1 ? win.closeTab(win.tabIndex) : win.close() }
    Shortcut { sequence: "Ctrl+T"; onActivated: win.newTab(FileOps.homePath()) }
    // Settings… (Cmd-,) and Hide Finder (Cmd-H), sent by the shell's app menu (shell/lib/menus.js): Finder's
    // settings have no window here, the nearest real ones are View > Show Path Bar / hidden files (the Action menu);
    // Hide = the window leaves the screen as on minimize (special:minimized, the Dock brings it back)
    Shortcut { sequence: "Ctrl+H"; onActivated: win.minimize() }
    function minimize() { if (!Hypr.minimizeWindow(win.title)) win.showMinimized(); }
    // Zoom (Option-click on the green light, a double-click on the toolbar's empty space): Hyprland's maximized mode, as
    // the shell's Window > Zoom; the session suppresses the xdg maximize request, so showMaximized is only the fallback
    function zoom() {
        if (!Hypr.zoomWindow(win.title)) win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized();
    }
    Shortcut { sequence: "Ctrl+Y"; onActivated: win.quickLook() }
    // Finder > Empty Trash… ⇧⌘⌫, and Empty Trash ⌥⇧⌘⌫ without the question (Q-menubar-31); the alert's words are
    // the shell's (shell/services/Apps.qml confirmEmptyTrash)
    Shortcut { sequence: "Ctrl+Shift+Backspace"; onActivated: alert.ask("Are you sure you want to permanently erase the items in the Trash?",
                                                                        "You can\u2019t undo this action.",
                                                                        [{ text: "Empty Trash", action: () => FileOps.emptyTrash() }, { text: "Cancel", cancel: true }]) }
    Shortcut { sequence: "Ctrl+Alt+Shift+Backspace"; onActivated: FileOps.emptyTrash() }

    // ---------- menus ----------
    PopupMenu { id: menu }

    function popup(items, anchor) {
        const p = anchor.mapToItem(null, 0, anchor.height + 6);
        showMenu(items, p.x, p.y);
    }
    // the menu is its own popup surface: it opens at the pointer and may leave the window; the compositor keeps it on
    // the screen (xdg_positioner slide / flip)
    function showMenu(items, x, y) {
        menu.items = items;
        menu.x = x;
        menu.y = y;
        // the menu's left edge on the screen, for its submenus (PopupMenu.showSub): the window's place from
        // Hyprland; the compositor keeps the menu itself on the screen
        const me = Hypr.windows().find(w => w.title === win.title);
        menu.screenLeft = me ? Math.min(me.x + x, Screen.virtualX + Screen.width - menu.width) : NaN;
        menu.open();
    }
    // the View rows (background menu View ▸, the toolbar's collapsed view popup)
    function viewItems() {
        const view = (key, label) => ({ text: label, checked: win.view === key, action: () => win.view = key });
        return [view("icons", "as Icons"), view("list", "as List"), view("columns", "as Columns"), view("gallery", "as Gallery")];
    }
    // one item: inline; several: the Rename Finder Items sheet
    function startRename() {
        if (fm.isVirtual) return;
        if (fm.selectedCount === 1) fm.renamingPath = fm.selectedPaths()[0];
        else if (fm.selectedCount > 1) renameSheet.open(fm.selectedEntries());
    }
    // The 27.2.1 context menus (Q-finder-23, live/finder/crops/context-menu-{file,folder,multi,background}-light.png),
    // in the Mac's order with its separators and leading symbols (Move to Trash, Share…, Customize Folder…, Quick
    // Actions, Services); Finder shows no shortcuts in context menus. Not here: the Ask Siri header (deferred) and the
    // tag dots row (the Mac lists favourite tags there and the captured account has none). Rows Finder cannot do here
    // stay as the Mac shows them, disabled: Customize Folder…, Use Groups, Clean Up, Clean Up By, Show View Options,
    // Quick Actions ▸ Customise…, Services ▸ No Services Apply. Paste Item only with files on the clipboard.
    function contextMenu(entry, pos) {
        const sel = fm.selectedEntries();
        const n = sel.length;
        const paths = sel.map(e => e.path);
        const writable = !fm.isVirtual;
        const one = n === 1 ? sel[0] : null;
        const pasteRow = dest => Clipboard.files.length && writable
            ? [{ text: Clipboard.files.length > 1 ? "Paste Items" : "Paste Item", action: () => fm.drop(Clipboard.files, dest, "copy") }] : [];
        const tail = [
            // no share sheet on Linux: Share… does what the toolbar's Share does (FALLBACKS.md)
            { text: "Share…", icon: "square.and.arrow.up", action: () => fm.openSelection() },
            { separator: true }
        ].concat(one && one.isDir ? [
            { text: "Customize Folder…", icon: "tag", enabled: false },
            { separator: true }
        ] : []).concat([
            { text: "Quick Actions", icon: "gearshape", submenu: [{ text: "Customise…", enabled: false }] },
            { separator: true },
            { text: "Services", icon: "gearshape.2", submenu: [{ text: "No Services Apply", enabled: false }] }
        ]);
        let items;
        if (entry) {
            const first = sel.find(e => !e.isDir);
            const apps = first ? FileOps.appsFor(first.path) : [];
            const openWith = apps.map(a => ({ text: a.name + (a.isDefault ? " (default)" : ""),
                                             action: () => FileOps.openWith(a.desktop, paths) }));
            const def = openWith.length && apps[0].isDefault ? 1 : 0;
            if (def && openWith.length > 1) openWith.splice(1, 0, { separator: true });
            const head = one && one.isDir
                ? [{ text: "Open in New Tab", action: () => win.newTab(one.path) }].concat(pasteRow(one.path))
                : (n > 1 ? [{ text: "New Folder with Selection (" + n + " Items)", enabled: writable && fm.userFiles,
                              action: () => fm.newFolderWithSelection() }] : []).concat([
                      { text: "Open", action: () => fm.openSelection() },
                      { text: "Open With", enabled: openWith.length > 0, submenu: openWith.length ? openWith : null }
                  ]);
            items = head.concat([
                { separator: true },
                { text: "Move to Trash", icon: "trash", enabled: n > 0 && fm.userFiles, action: () => fm.trashSelection() },
                { separator: true },
                { text: "Get Info", action: () => info.show(entry.path, pos.x, pos.y) },
                { text: n > 1 ? "Rename…" : "Rename", enabled: n > 0 && writable, action: () => win.startRename() },
                { text: n > 1 ? "Compress" : "Compress “" + entry.name + "”", enabled: writable, action: () => FileOps.compress(paths) },
                { text: "Duplicate", enabled: writable, action: () => FileOps.duplicate(paths) },
                { text: "Make Alias", enabled: writable, action: () => { const e = FileOps.makeAlias(paths); if (e) fm.errorRaised(e); fm.reload(); } },
                { text: "Quick Look", action: () => win.quickLook() },
                { text: "Copy", action: () => Clipboard.copyFiles(paths) },
                { separator: true }
            ]).concat(tail).concat(fm.isVirtual ? [{ separator: true }, { text: "Show in Enclosing Folder", action: () => {
                fm.go(Files.parentPath(entry.path));
                fm.selectPaths([entry.path]);
            } }] : []);
        } else {
            items = [
                { text: "New Folder", enabled: writable, action: () => fm.newFolder() }
            ].concat(pasteRow(fm.path)).concat([
                { separator: true },
                { text: "Get Info", enabled: writable, action: () => info.show(fm.path, pos.x, pos.y) },
                { separator: true },
                { text: "View", submenu: viewItems() },
                { text: "Use Groups", enabled: false },
                { text: "Sort By", submenu: sortItems() }
            ]).concat(win.view === "icons" ? [   // the captured menu is the icon view's; Clean Up arranges free icons
                { text: "Clean Up", enabled: false },
                // Clean Up By: -[TContextMenu addViewSpecificStuffToMenu:...] 0x10042098c, titles N220 N224 N221 N222 N223
                // N225 (table 0x100b267a8); this icon view has no free layout to arrange: the rows are disabled
                { text: "Clean Up By", submenu: ["Name", "Kind", "Date Modified", "Date Created", "Size", "Tags"]
                      .map(t => ({ text: t, enabled: false })) }
            ] : []).concat([
                { text: "Show View Options", enabled: false }
            ]);
        }
        showMenu(items, pos.x, pos.y);
    }
    // Sort By (27.2.1 Finder.app Base.lproj/ArrangeByMenu.nib, outlet sortByMenu): None, separator, Snap to Grid (icon
    // view), separator, Name, Kind, Date Last Opened, Date Added, Date Modified, Date Created, Size, Tags; Shared By and
    // Last Modified By only show for shared iCloud items. No key equivalents in Finder's context menus
    // (TArrangeByMenuController removeCommandKeyEquivalents). The orders this browser has no data or code for (None,
    // Snap to Grid, last opened, added, created, tags) stay disabled.
    function sortItems() {
        const sortBy = (key, label) => ({ text: label, checked: fm.sortKey === key,
                                          action: () => { fm.sortKey = key; fm.ascending = key === "name"; } });
        const off = label => ({ text: label, checked: false, enabled: false });
        return [off("None"), { separator: true }]
            .concat(win.view === "icons" ? [off("Snap to Grid"), { separator: true }] : [])
            .concat([sortBy("name", "Name"), sortBy("kind", "Kind"), off("Date Last Opened"), off("Date Added"),
                     sortBy("modified", "Date Modified"), off("Date Created"), sortBy("size", "Size"), off("Tags")]);
    }
    // The toolbar's group button: Group By, the nib's other menu (ArrangeByMenu.nib, outlet arrangeByMenu): None ⌃⌘0,
    // separator, [Volume], Name, Kind, Application, [Application Category, Shared By, Last Modified By], Date Last
    // Opened, Date Added, Date Modified, Date Created, Size, Tags (bracketed rows are hidden by bindings for a plain
    // folder). -[FIArrangeByPopUp mouseDown:] and -[TArrangementToolbarItem menuNeedsUpdate:] pick arrangeByMenu, or
    // sortByMenu when ⌥ is held or cmdArrange: is not valid (⌥ not built: the button's signal has no modifiers), and the
    // toolbar item strips the key equivalents (initWithItemIdentifier:... sends removeCommandKeyEquivalents). This
    // browser has no groups, so None is checked and the other orders are disabled.
    function groupItems() {
        const off = label => ({ text: label, checked: false, enabled: false });
        return [{ text: "None", checked: true, enabled: false }, { separator: true }]
            .concat(["Name", "Kind", "Application", "Date Last Opened", "Date Added", "Date Modified", "Date Created", "Size",
                     "Tags"].map(off));
    }
    // Sidebar row menu (files.js sidebarMenu: Finder 27.2.1 configureForSidebar, context 8): Open in New Tab, Show in
    // Enclosing Folder and Get Info act; the rest have no function here and show disabled (FALLBACKS.md)
    function sidebarMenu(item, kind, pos) {
        const real = kind !== "virtual" && item.path !== "" && !fm.isVirtualPath(item.path);
        const act = {
            newtab: () => win.newTab(item.path),
            enclosing: () => { fm.go(Files.parentPath(item.path)); fm.selectPaths([item.path]); },
            info: () => info.show(item.path, pos.x, pos.y)
        };
        showMenu(Files.sidebarMenu(kind, item.label, item.path !== "", real)
                     .map(r => r.separator ? r : { text: r.text, enabled: r.enabled, action: act[r.id] }), pos.x, pos.y);
    }
    // The toolbar's Action button (•••): Finder fills its menu with the context menu of the selection, or of the window
    // when nothing is selected (Finder 27.2.1 -[TContextMenu populateActionMenu:contextMenuDelegate:]; Toolbar.nib's
    // "Action" NSMenu is empty). Path Bar and hidden files stay on View > Show Path Bar ⌥⌘P and ⇧⌘. (Shortcuts above).
    function actionMenu(anchor) {
        const sel = fm.selectedEntries();
        const p = anchor.mapToItem(null, 0, anchor.height + 6);
        contextMenu(sel.length ? sel[0] : null, p);
    }

    // ---------- overlays ----------
    InfoPopover { id: info; anchors.fill: parent; onClosed: keys.forceActiveFocus() }
    // Quick Look: a window of its own (QuickLook.qml); it closes into the item's icon in the current view
    QuickLook {
        entry: win.quickLookEntry
        finder: win
        iconRect: path => {
            const i = fm.entries.findIndex(e => e.path === path);
            const icon = i >= 0 && viewLoader.item && viewLoader.item.iconItem ? viewLoader.item.iconItem(i) : null;
            return icon && icon.visible ? icon.mapToItem(null, 0, 0, icon.width, icon.height) : null;
        }
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
