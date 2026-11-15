import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/dock.js" as DockLayout
import "../lib/dockstack.js" as DockStackLayout
import "../lib/state.js" as State

// Floating glass Dock as on macOS 27.2.1 (MAC-ANSWERS.md Q-dock and "REA 27.2.1: Dock"): pinned apps, the recent
// section (running unpinned and recent apps), Downloads + Trash; running dots, the app name label on hover, the
// launch and attention bounces, the icon darkened while pressed, magnification when switched on. Geometry from
// lib/dock.js metrics() at the tile size from state/dock.json `size` (lib/state.js dockTile: 64 when absent), shrunk
// to fit the screen.
// Hidden while a window is full screen on this output, and with "Automatically hide and show the Dock"
// (state/dock.json) until the pointer reaches the bottom edge: a pure slide, nothing left on screen.
// Reduce motion: a dissolve in place, and no bounces (only the running dot).
ShellWindow {
    id: dock

    required property var modelData
    screen: modelData
    // Empty desktop: Hyprland keeps the pointer with a layer surface outside its input region only while some
    // surface has keyboard focus, so a tile dragged up off the Dock lost the pointer at the Dock's edge and went
    // back (judge #4). With no window on the workspace the Dock takes the focus on a press; with windows it never
    // does (a Dock click must not make the front window inactive). An empty workspace can be unknown to Quickshell
    // (focusedWorkspace null). Test hook: qs ipc call dock emptyDesktop
    readonly property bool emptyDesktop: !Hyprland.focusedWorkspace || Hyprland.focusedWorkspace.toplevels.values.length === 0
    WlrLayershell.keyboardFocus: emptyDesktop ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // ---------- items ----------
    readonly property var others: [{ id: "hyprk-downloads", name: "Downloads", icon: "folder-download", folder: "Downloads" },
                                   { id: "hyprk-trash", name: "Trash", icon: "user-trash", trash: true }]
    readonly property var items: DockLayout.sections(Apps.pinnedItems, Apps.runningUnpinned, Apps.recent, Prefs.dock.showRecents !== false, others)
    readonly property var cells: items.map(it => it.separator ? "separator" : "tile")
    readonly property int separators: cells.filter(c => c === "separator").length
    readonly property int trashIndex: items.length - 1

    // ---------- slots ----------
    // One ListModel row per slot (lib/dock.js slotEdits), keyed by the item's id, so a change of the items (a window
    // opens, recents move) updates the delegates in place: the launch bounce, the hover label and the pressed state
    // live on. An added slot grows from 0 in 0.25 s, a removed one shrinks out in 0.15 s, cosine ease in-out
    // (MAC-ANSWERS.md Q-dock); each runs one NumberAnimation on its delegate, nothing else ticks.
    readonly property var itemKeys: DockLayout.slotKeys(items)
    readonly property var byKey: {
        const o = {};
        items.forEach((it, i) => o[itemKeys[i]] = it);
        return o;
    }
    ListModel { id: slots }
    property var slotList: []          // mirror of `slots`: [{key, leaving}]
    property bool slotsLive: false     // after the first fill: new slots grow in
    function syncSlots() {
        const r = DockLayout.slotEdits(slotList, itemKeys);
        for (const o of r.ops) {
            if (o.op === "leave") slots.setProperty(o.at, "leaving", true);
            else if (o.op === "revive") slots.setProperty(o.at, "leaving", false);
            else if (o.op === "move") slots.move(o.from, o.to, 1);
            else slots.insert(o.at, { key: o.key, leaving: false });
        }
        slotList = r.slots;
    }
    function dropSlot(key) {
        const i = slotList.findIndex(c => c.key === key);
        if (i < 0 || !slotList[i].leaving) return;
        slots.remove(i);
        slotList = slotList.filter((c, j) => j !== i);
    }
    onItemKeysChanged: syncSlots()
    readonly property var slotCells: slotList.map(c => /^hyprk-separator/.test(c.key) ? "separator" : "tile")
    // the slots' widths (0..1) while one grows or shrinks
    readonly property var slotGrow: {
        const n = slotList.length, g = [];
        for (let i = 0; i < n; i++) {
            const it = cellRepeater.count === n ? cellRepeater.itemAt(i) : null;
            g.push(it ? it.grow : 1);
        }
        return g;
    }

    // ---------- geometry ----------
    // > 0 while a separator is dragged: the Dock's desiredTileSize, shown live and written on release (lib/dock.js
    // resizeTile)
    property int resizeTile: 0
    readonly property int tile: DockLayout.fitTile(resizeTile > 0 ? resizeTile : State.dockTile(Prefs.dock), items.length - separators, separators, screen ? screen.width : 1920)
    readonly property var m: DockLayout.metrics(tile)
    // magnified size: the Magnification slider's ratio to the Size slider (state/dock.json, default 96/48 = 2)
    readonly property int large: Math.round(tile * State.magnifyRatio(Prefs.dock))
    // the window's ratio: the screen's says 2 on a 1.6 output, which snapped the tiles to half points (0.8 px), not
    // to device pixels (SCALING-AUDIT.md)
    readonly property real dpr: devicePixelRatio > 0 ? devicePixelRatio : screen && screen.devicePixelRatio > 0 ? screen.devicePixelRatio : 1
    // Magnification is off by default, like macOS (state/dock.json `magnification`, Settings >
    // Desktop & Dock > Magnification). Off: hovering only shows the app name, nothing moves.
    readonly property bool magnification: Prefs.dock.magnification === true
    readonly property real labelRoom: 26 + 9 + 4      // label capsule, its gap to the Dock, a margin
    readonly property real above: Math.max((magnification ? large - tile : 0) + labelRoom, DockLayout.attentionHeight(tile))

    anchors { bottom: true; left: true; right: true }
    // The surface always has one height, enough for the largest Dock (128): a separator drag is measured in this
    // surface, which must not resize under the pointer. Growing it on hover (as before) left Qt with the pointer's
    // old surface position until the next motion: the area lost its hover, the cursor went back to the arrow and a
    // press without a move first landed 128 pt above the separator (JUDGE-95-23 claim 2). The part above the Dock
    // is outside the input mask (`hit`)
    readonly property real resizeHeight: {
        const mm = DockLayout.metrics(128);
        const up = Math.max((magnification ? Math.round(128 * State.magnifyRatio(Prefs.dock)) - 128 : 0) + labelRoom, DockLayout.attentionHeight(128));
        return Math.ceil(up + mm.height + mm.bottomGap);
    }
    implicitHeight: Math.max(resizeHeight, Math.ceil(above + m.height + m.bottomGap))
    exclusiveZone: autohide ? 0 : Math.ceil(zoneM.height + zoneM.bottomGap)
    // the zone follows the saved size, not a separator drag in progress: a new zone per frame made Hyprland lay the
    // screen out again on every frame of the drag (dock-plate-sync.py: the Dock stood still for 3-7 frames near the
    // end of the drag, 2-3 with the zone held); it takes the new size once, on the release
    readonly property var zoneM: DockLayout.metrics(DockLayout.fitTile(State.dockTile(Prefs.dock), items.length - separators, separators, screen ? screen.width : 1920))
    namespace: "hyprk-dock"
    // Hyprland hides Top layers on a full-screen workspace at once: while the Dock slides out for a full screen
    // enter it sits on Overlay, so the slide is seen
    WlrLayershell.layer: fullscreen && slide > 0 ? WlrLayer.Overlay : WlrLayer.Top
    inputMask: Region { item: hit }

    // the band Mission Control leaves to the Dock (it stays visible there, Q-dock-27)
    readonly property int keepClear: shown && !autohide ? Math.ceil(m.height + m.bottomGap) : 0
    onKeepClearChanged: if (screen) Panels.setDockZone(screen.name, keepClear)

    // ---------- bounces ----------
    // Launch: 0.70 s parabolic hops, (R - 8) * 0.2 + 6 pt high; attention (an urgent window): the 2 s cycle of
    // three hops, R + 1 pt high, R = the tile rect (lib/dock.js, from Dock.app's -[Tile updateBouncing]), the
    // offset drawn in whole points like the Dock (PC #67 A1). The heights are read
    // from a clock that moves one refresh interval per frame of the Dock's window while something bounces (HyprK
    // FrameClock; a FrameAnimation is ticked by Qt's 16 ms timer and loses a value about every 0.4 s); the clock is off
    // otherwise, and between attention bursts a timer wakes it.
    readonly property real bounceHeight: DockLayout.bounceHeight(tile)
    readonly property real attentionHeight: DockLayout.attentionHeight(tile)
    property real now: Date.now()
    FrameClock {
        id: clock
        property double t0: 0
        readonly property bool wanted: !A11y.reduceMotion && Apps.anyBouncing(dock.now)
        function follow(): void {
            if (wanted === running) return;
            if (!wanted) { stop(); return; }
            t0 = Date.now();
            dock.now = t0;
            start();
        }
        // later: follow() moves dock.now, which `wanted` hangs on
        onWantedChanged: Qt.callLater(follow)
        Component.onCompleted: follow()
        watchdog: true
        onTick: dock.now = t0 + elapsed
        // no frames (the Dock is off screen): keep the time moving so the bounce ends
        onStalled: { t0 = Date.now() - elapsed; dock.now = Date.now(); }
    }
    readonly property real wakeAt: A11y.reduceMotion ? 0 : Apps.nextAttention(dock.now)
    Timer {
        running: !clock.running && dock.wakeAt > 0
        interval: Math.max(16, dock.wakeAt - Date.now())
        onTriggered: dock.now = Date.now()
    }

    // ---------- genie target (plugin-motion) ----------
    // Where minimized windows go, global logical px, unmagnified layout (plugin-motion pickTarget): each window
    // into its app's Dock tile, like macOS's default minimize-to-application = 1, as "<address> x y w h", and for
    // any other window the slot a minimized tile takes with that setting off: right of the separator, after the
    // stacks, before Trash (Q-dock-13), i.e. where Trash is now. Sent only when it changes, from the primary
    // screen's Dock; errors (plugin-motion not loaded) are ignored.
    readonly property bool primaryDock: screen === Panels.screen
    readonly property string genieTarget: {
        if (!primaryDock || !screen) return "";
        const x0 = screen.x + (dock.width - restGeom.baseWidth) / 2;
        const top = screen.y + screen.height - m.bottomGap - m.height + m.iconTop;
        const rect = left => [left, top, tile, tile].map(Math.round).join(" ");
        const out = [rect(x0 + restGeom.center[trashIndex] - tile / 2)];
        items.forEach((it, i) => (it.windows || []).forEach(w => {
            if (w && w.address) out.push(String(w.address) + " " + rect(x0 + restGeom.center[i] - tile / 2));
        }));
        return out.join(";");
    }
    function sendGenie(t) {
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ plugin = { hyprkmotion = { genie_target = "${t}" } } })`]);
    }
    property string sentGenie: ""
    onGenieTargetChanged: genieDebounce.restart()
    Timer {
        id: genieDebounce
        interval: 200
        running: true
        onTriggered: if (dock.genieTarget !== dock.sentGenie) { dock.sentGenie = dock.genieTarget; dock.sendGenie(dock.genieTarget); }
    }
    Component.onDestruction: if (sentGenie !== "") sendGenie("")

    // ---------- show / hide ----------
    // Autohide (Q-dock-16): the bottom 2 pt anywhere along the edge reveal it after Theme.anim.dockRevealDelay;
    // leaving hides it after dockHideDelay. Both slide on the Dock's cosine ease in-out over dockSlide.
    readonly property bool autohide: Prefs.dock.autohide
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    // A real full screen only: a zoomed (maximized) window also sets the workspace's hasFullscreen, and the Mac keeps
    // menu bar and Dock for Zoom. Hyprland reports the two apart as toplevel states (ForeignToplevelWlr.cpp:
    // FSMODE_FULLSCREEN -> fullscreen, any other mode -> maximized), with the change, no IPC round trip.
    readonly property bool fullscreen: {
        const ws = hyprMonitor ? hyprMonitor.activeWorkspace : null;
        return !!ws && ws.hasFullscreen && ws.toplevels.values.some(t => t.wayland && t.wayland.fullscreen);
    }
    property bool pointerIn: false
    property bool revealed: false
    Timer { id: revealDelay; interval: Theme.anim.dockRevealDelay; onTriggered: dock.revealed = true }
    Timer { id: hideDelay; interval: Theme.anim.dockHideDelay; onTriggered: dock.revealed = false }
    onPointerInChanged: {
        if (pointerIn) { hideDelay.stop(); if (!revealed) revealDelay.restart(); }
        else { revealDelay.stop(); hideDelay.restart(); }
    }
    // a Dock menu (opened above an icon) keeps it up
    readonly property bool shown: !fullscreen && (!autohide || revealed || stackOpen || (Panels.open === "context" && Panels.contextAbove && Panels.activeScreen === dock.screen))
    // 0 = hidden below the screen edge, 1 = in place; it also slides in when the shell starts
    property real slide: 0
    // every Dock motion below takes one value per frame of its window (HyprK FrameAnim)
    FrameAnim {
        id: slideAnim
        target: dock
        property: "slide"
        ease: Easing.InOutSine
        settlesGlass: true
    }
    function slideTo(v, ms) {
        slideAnim.stop();
        slideAnim.to = v;
        slideAnim.duration = Theme.ms(ms || Theme.anim.dockSlide);
        slideAnim.start();
    }
    // a full screen enter or exit moves the Dock on the Space slide (0.5 s), autohide on its own 210 ms. `shown` and
    // `fullscreen` change in one event, in either handler order: settle once both have
    property bool fsSeen: false
    function follow() {
        const fs = fullscreen !== fsSeen;
        fsSeen = fullscreen;
        if (slideAnim.to !== (shown ? 1 : 0) || (!slideAnim.running && slide !== (shown ? 1 : 0)))
            slideTo(shown ? 1 : 0, fs ? Theme.anim.fullscreenSlide : 0);
    }
    onShownChanged: Qt.callLater(follow)
    onFullscreenChanged: Qt.callLater(follow)
    Component.onCompleted: {
        fsSeen = fullscreen;
        slideTo(shown ? 1 : 0);
        if (screen) Panels.setDockZone(screen.name, keepClear);
        syncSlots();
        Qt.callLater(() => dock.slotsLive = true);   // slots added from now on grow in
    }
    // the whole height of the background plus its gap: hidden, nothing is left on screen
    readonly property real hideY: A11y.reduceMotion ? 0 : Math.ceil((1 - slide) * (m.height + m.bottomGap))
    readonly property real restY: height - m.height - m.bottomGap

    // ---------- Downloads: a stack of its newest items ----------
    // Display as Stack (the Dock's default for Downloads): the tile shows the newest 3 items piled as the 27.2.1 Dock
    // draws them (lib/dockstack.js pile: front 116/128 of the tile bottom-aligned, each one behind 12/128 smaller and
    // 18/128 higher, centred, no rotation; MOTION-REA-27.2.1.md 3.2), each item drawn in its box by StackArt.qml.
    // Against dock-dark.png at tile 33 (a ZIP over a landscape photo, the same under the Dark icon style in both
    // modes; measured in a test session at scale 2): the photo 24 pt wide as on the Mac, its centre about 1.5 pt
    // higher; the ZIP's face 29 pt tall as on the Mac but 2 pt lower and 2.5 pt wider (our ZIP art is wider, and the
    // Mac's face reaches 2 pt above the decoded front box, so its art or the tile mapping differs: not resolved).
    // An empty folder shows the folder. Watched by FolderListModel (a directory watch, no polling).
    // Not seen on the Mac: the Clear and Tinted styles.
    readonly property string downloadsUrl: "file://" + Quickshell.env("HOME") + "/Downloads"
    FolderListModel {
        id: downloads
        folder: dock.downloadsUrl
        showDirs: true
        showHidden: false
        showDotAndDotDot: false
        // Sort by in the stack's menu (Apps.downloads): Date Modified unless Name or Kind was chosen
        sortField: Apps.downloads.sort === "name" ? FolderListModel.Name : Apps.downloads.sort === "kind" ? FolderListModel.Type : FolderListModel.Time
    }
    readonly property bool downloadsWatched: downloads.status === FolderListModel.Ready && String(downloads.folder) === downloadsUrl
    // The document page of a file (themes/icons/system/<doc>-154.png): the Mac's renders for .zip / .pdf / .txt (text
    // included), IconServices' composition (themes/icons/tools/build-docs.py, ICONS-REA-27.2.1.md part 2) by the type's
    // ISDocumentIconConfiguration symbol for the rest, without the text (StackArt draws it). By extension only: the
    // folder model has no MIME type. Same table as Finder's Files.macDocKind
    function docArt(path) {
        const e = ((/\.([^./]+)$/.exec(path) || ["", ""])[1]).toLowerCase();
        if (e === "zip") return "ZipDocument";
        if (e === "pdf") return "PdfDocument";
        if (e === "txt" || e === "text") return "TextDocument";
        if (e === "docx") return "JustifyDocument";
        if (e === "xlsx" || e === "csv") return "TableDocument";
        if (e === "pptx") return "ChartDocument";
        if (e === "html" || e === "htm") return "CodeDocument";
        if (/^(mp3|m4a|aac|wav|aif|aiff|flac|ogg|opus|caf)$/.test(e)) return "AudioDocument";
        if (/^(mp4|m4v|mov|avi|mkv|webm|mpg|mpeg|3gp)$/.test(e)) return "VideoDocument";
        if (/^(heic|heif|tif|tiff|bmp|svg|ico|avif)$/.test(e)) return "ImageDocument";
        if (/^(log|md|markdown|json|xml|yaml|yml|toml|ini|conf|css|js|mjs|ts|py|sh|c|h|cpp|hpp|rs|go|java|swift|qml|ics|tsv|sql)$/.test(e))
            return "TxtfillDocument";
        return "";
    }
    // the first `n` items in the stack's order: {path, name, dir, image, zip, doc, ext}
    function downloadsItems(n) {
        const out = [];
        if (!downloadsWatched) return out;
        for (let i = 0; i < Math.min(n, downloads.count); i++) {
            const path = String(downloads.get(i, "filePath")), dir = downloads.get(i, "fileIsDir");
            out.push({ path: path, name: String(downloads.get(i, "fileName")), dir: dir,
                       image: !dir && /\.(png|jpe?g|gif|webp|bmp|tiff?)$/i.test(path), zip: !dir && /\.zip$/i.test(path),
                       // the 27.2.1 page for this type (docArt) and, on the composed pages, the extension text
                       doc: dir ? "" : docArt(path),
                       ext: dir ? "" : (/\.([^./]+)$/.exec(path) || ["", ""])[1].toUpperCase() });
        }
        return out;
    }
    // the pile: the newest three, front first (_maxNumberOfCollapsedItems 3)
    readonly property var downloadsStack: { downloads.count; return downloadsItems(3); }

    // ---------- Downloads: the stack's popup ----------
    // A click on the tile opens the fan or the grid (DockStack.qml) by "View content as" (Apps.downloads.view,
    // Automatic unless chosen: lib/dockstack.js view), List as a menu above the tile. Panels.open "stack" while it is
    // open, so it is the only popup; the tile shows a chevron then (Q-dock-12). The popup stays loaded through its
    // close motion (stackLive).
    readonly property bool stackOpen: Panels.open === "stack" && Panels.activeScreen === dock.screen
    property bool stackLive: false
    property var stackArgs: null
    onStackOpenChanged: if (!stackOpen && A11y.reduceMotion) stackLive = false
    function openStack(c) {
        if (stackOpen) { Panels.close(); return; }
        const files = downloadsItems(500);
        const cx = (dock.width - dock.restGeom.baseWidth) / 2 + c.baseCenter;
        const top = dock.screen.height - dock.height + dock.restY;
        const st = DockStackLayout.stage(dock.screen.width, dock.screen.height, Theme.menuBar.height, m.height);
        const v = DockStackLayout.view(Apps.downloads.view, files.length, st.h);
        if (v === "list") {
            const rows = files.map(f => ({ label: f.name, action: () => f.dir ? Apps.openFinder(f.path) : Quickshell.execDetached(["xdg-open", f.path]) }));
            if (rows.length > 0) rows.push({ sep: true });
            // DockMenus.plist "directorylist": the files, separator, Options ▸ (the sort / display / view rows only), Open
            // in Finder
            rows.push({ label: "Options", submenu: true, items: Apps.downloadsOptions() },
                      { label: "Open in Finder", action: () => Apps.openFolder(c.modelData) });
            Panels.openContext(rows, cx, top, true, dock.screen);
            return;
        }
        stackArgs = { view: v, files: files, title: c.modelData.name || "", folderMode: Apps.downloads.display === "folder",
                      tileCX: cx, tileBottom: top + m.iconTop + tile, dockTop: top, stage: st };
        stackLive = true;
        Panels.activeScreen = dock.screen;
        Panels.open = "stack";
    }
    LazyLoader {
        active: dock.stackLive && dock.stackArgs !== null
        DockStack {
            host: dock
            view: dock.stackArgs.view
            files: dock.stackArgs.files
            title: dock.stackArgs.title
            folderMode: dock.stackArgs.folderMode
            tile: dock.tile
            tileCX: dock.stackArgs.tileCX
            tileBottom: dock.stackArgs.tileBottom
            dockTop: dock.stackArgs.dockTop
            magnification: dock.magnification
            stageSize: dock.stackArgs.stage
            open: dock.stackOpen
            onStackDone: if (!dock.stackOpen) dock.stackLive = false
        }
    }

    // ---------- Trash: full can while the XDG trash has files ----------
    // Watched by FolderListModel (a directory watch, no polling). A missing folder (nothing trashed
    // yet) is retried every 5 s until it exists. Per-volume .Trash-$UID folders are not read.
    readonly property string trashFiles: (Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share") + "/Trash/files"
    readonly property string trashUrl: "file://" + trashFiles
    FolderListModel {
        id: trash
        folder: dock.trashUrl
        showDirs: true
        showHidden: true
        showDotAndDotDot: false
        sortField: FolderListModel.Unsorted
    }
    Timer {
        interval: 5000
        repeat: true
        running: !dock.trashWatched
        onTriggered: { trash.folder = ""; trash.folder = dock.trashUrl; }
    }
    // a missing folder makes FolderListModel fall back to the working directory: not the trash
    readonly property bool trashWatched: trash.status === FolderListModel.Ready && String(trash.folder) === trashUrl
    // kept while the model reloads (status Loading), so adding a second file does not flicker the can
    property bool trashFull: false
    function updateTrash() { if (trash.status !== FolderListModel.Loading) trashFull = trashWatched && trash.count > 0; }
    Connections {
        target: trash
        function onStatusChanged() { dock.updateTrash(); }
        function onCountChanged() { dock.updateTrash(); }
        function onFolderChanged() { dock.updateTrash(); }
    }

    // ---------- magnification ----------
    // The pointer is mapped into the unmagnified layout, so magnification never feeds back into itself; the sizes
    // follow the pointer directly. Entering and leaving the Dock ramp `fish` 0 <-> 1 on the Dock's cosine ease
    // in-out over lib/dock.js fishDuration (147 ms for 64 -> 128). The layout is recomputed only while magnified.
    property real focusX: 0
    readonly property real fishTarget: magnification && pointerIn && shown && resizeTile === 0 && Panels.open !== "context" && !stackOpen ? 1 : 0
    property real fish: 0
    FrameAnim { id: fishAnim; target: dock; property: "fish"; ease: Easing.InOutSine }
    onFishTargetChanged: {
        fishAnim.stop();
        fishAnim.to = fishTarget;
        fishAnim.duration = Theme.ms(DockLayout.fishDuration((fishTarget - fish) * (large - tile)));
        fishAnim.start();
    }
    readonly property var geom: DockLayout.layout(slotCells, { tile: tile, large: large, fish: fish, focus: fish > 0 ? focusX : 0, dpr: dpr, grow: slotGrow })
    // the items at rest, every slot full (where minimized windows go)
    readonly property var restGeom: DockLayout.layout(cells, { tile: tile, large: large, fish: 0, focus: 0, dpr: dpr })

    // ---------- app name label ----------
    // It shows in the frame the pointer reaches an icon (no fade-in), moves to the next icon in one frame, and on
    // leaving fades out over 300 ms on the Dock's cosine ease in-out, or over the autohide slide when autohide is on
    // (-[DockBar blendAwayLabel], reconciliation-42.json: cosine T 0.29 s). One label at a time: `tipItem`.
    property Item tipItem: null
    property real tipAlpha: 0
    // (tipFade sits in the label's window below: it is that window's frames that show it)
    function tipShow(c) { tipFade.stop(); tipItem = c; tipAlpha = 1; }
    function tipHide(c) { if (tipItem === c) tipFade.restart(); }

    // ---------- drag off the Dock (MAC-ANSWERS.md Q-dock-17, dock-live.json drag_remove) ----------
    // A pinned app (not Finder) dragged past the start distance leaves its tile and follows the pointer at the Dock's
    // art size (no lift scale). Once the pointer is out of the Dock background its slot shrinks out (the other tiles
    // close the gap on the slot ease) and 0.25 s later a "Remove" bubble in the hover label's style shows above it;
    // dropped then, the app is removed (Apps.removeFromDock, $HYPRK_STATE/dock-items.json), the poof sound plays
    // (system sound 15, Dock.app's poof) and icon and bubble fade out linearly in 0.25 s. Dropped anywhere else the
    // slot grows back. The start distance is Qt's (no Mac data); reordering by drag is not done (not measured). Icon
    // and bubble are drawn on the label's surface, which covers the screen during the drag (it is unmapped before,
    // so nothing is resized: growing the Dock's own surface showed one wrong Dock frame). The pointer stays with the
    // Dock outside its window only while Hyprland holds the focus for the pressed button, which it does when a
    // surface has the keyboard focus (InputManager.cpp, "if we are holding a pointer button"); on an empty desktop
    // the press ends as the pointer leaves the Dock and the tile goes back.
    property Item dragCell: null
    property point dragPos: Qt.point(0, 0)       // the pointer, this window's coordinates
    property point dragGrab: Qt.point(0, 0)      // the pointer inside the icon
    property bool dragOut: false
    property bool dragRemove: false
    property bool dragDropped: false
    property real dragFade: 1
    // what the dragged icon shows, kept apart from its cell: the removal destroys the cell (its slot is already
    // closed), and the icon and "Remove" then fade for 0.25 s without it (they vanished in the drop's frame:
    // dock-drag-off.py; Mac dock-drag-off-hand.mov, 16 fading frames)
    property var dragInfo: null
    readonly property bool dragging: dragCell !== null || dragDropped
    readonly property bool removeShown: dragRemove && dragging
    Timer { id: removeDelay; interval: Theme.ms(250); onTriggered: dock.dragRemove = dock.dragOut }
    // (dropFade sits in the label's window below, which draws the icon and the bubble)
    function dragMove(c, x, y) {
        dragPos = Qt.point(x, y);
        const out = x < bg.x || x > bg.x + bg.width || y < bg.y || y > bg.y + bg.height;
        if (out === dragOut) return;
        dragOut = out;
        c.slide(out ? 0 : 1);
        if (out) removeDelay.restart();
        else { removeDelay.stop(); dragRemove = false; }
    }
    function dragDrop(c) {
        removeDelay.stop();
        if (dragOut && dragRemove) {
            dragDropped = true;
            Apps.poofSoon();                 // behind the first fading frame, as the menu's removal (Apps.qml)
            Apps.removeFromDock(c.modelData.id);
            dropFade.restart();
        } else {
            if (dragOut) c.slide(1);
            endDrag();
        }
    }
    function endDrag() { dragCell = null; dragInfo = null; dragOut = false; dragRemove = false; dragDropped = false; dragFade = 1; }
    // hit area: the background, plus the magnified band while magnified; hidden by autohide the bottom 2 pt of
    // the whole edge (reveals it), hidden by a full-screen window nothing
    Item {
        id: hit
        // the whole surface during a separator drag: the pointer leaves the background on the way up, and on an empty
        // desktop Hyprland ends the press when it leaves the input region
        x: dock.resizeTile > 0 ? 0 : dock.shown ? bg.x : 0
        width: dock.resizeTile > 0 ? dock.width : dock.shown ? bg.width : dock.autohide && !dock.fullscreen ? dock.width : 0
        y: dock.resizeTile > 0 ? 0 : !dock.shown ? dock.height - 2 : dock.fish > 0 ? dock.restY - (dock.large - dock.tile) : dock.restY
        height: dock.height - y
    }

    // on the window's root item so it sees hover above child MouseAreas
    HoverHandler {
        onPointChanged: if (hovered && dock.magnification) dock.focusX = point.position.x - (dock.width - dock.geom.baseWidth) / 2
        onHoveredChanged: dock.pointerIn = hovered
    }

    // the resize cursor for the whole of a separator drag: the Dock grows under the pointer, which is soon over a tile
    MouseArea {
        anchors.fill: parent
        z: 10
        visible: dock.resizeTile > 0
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.SizeVerCursor
    }

    // test hooks: `qs ipc call dock bounce <dock item id>` bounces that icon as if it were launching,
    // `qs ipc call dock attention <dock item id> true|false` as if one of its windows were urgent
    IpcHandler {
        target: "dock"
        enabled: dock.primaryDock
        function bounce(id: string): void { Apps.markLaunching(id); }
        function attention(id: string, on: bool): void { Apps.markAttention(id, on); }
        function emptyDesktop(): bool { return dock.emptyDesktop; }
    }

    // whole logical px, like the compositor glass region, so tint and glass edges line up
    Glass {
        id: bg
        visible: dock.slide > 0
        opacity: A11y.reduceMotion ? dock.slide : 1
        width: dock.geom.width
        height: dock.m.height
        x: Math.round((dock.width - width) / 2)
        y: dock.restY + dock.hideY
        radius: Theme.compositorGlass ? dock.m.radius : dock.m.radiusCircle
        sx: x
        sy: dock.screen.height - dock.height + y
        // where it is on the screen, for Mission Control's cover (only while that is open)
        readonly property var onScreen: Panels.open === "mission" && dock.screen
            ? { x: x, y: dock.screen.height - dock.height + y, w: width, h: height, r: radius } : null
        onOnScreenChanged: if (onScreen && dock.screen) Panels.setDockRect(dock.screen.name, onScreen)
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: Theme.dock.pluginLift
        materialize: A11y.reduceMotion ? dock.slide : 1
    }

    Item {
        id: stage
        visible: bg.visible
        opacity: bg.opacity
        x: bg.x
        y: bg.y
        width: bg.width
        height: bg.height

        Repeater {
            id: cellRepeater
            model: slots
            delegate: Item {
                id: cell
                required property string key
                required property bool leaving
                required property int index
                // the item, kept after it left the Dock while the slot shrinks
                readonly property var live: dock.byKey[key]
                property var kept: ({})
                onLiveChanged: if (live) kept = live
                readonly property var modelData: live !== undefined ? live : kept

                // slot width 0..1: grows in when added after the first fill, shrinks out when removed, then goes
                property real grow: 1
                FrameAnim {
                    id: slotAnim
                    target: cell; property: "grow"; ease: Easing.InOutSine
                    onFinished: if (cell.leaving) dock.dropSlot(cell.key)
                }
                function slide(to) {
                    slotAnim.stop();
                    if (A11y.reduceMotion) {
                        grow = to;
                        if (leaving) Qt.callLater(() => dock.dropSlot(key));
                        return;
                    }
                    slotAnim.to = to;
                    slotAnim.duration = Theme.ms(DockLayout.slotDuration(to > grow, Apps.menuRemoved !== "" && Apps.menuRemoved === modelData.id)) * Math.abs(to - grow);
                    slotAnim.start();
                }
                onLeavingChanged: slide(leaving ? 0 : 1)

                readonly property bool separator: modelData.separator === true
                // unmagnified centre of this cell (background coordinates)
                readonly property real baseCenter: dock.geom.center[index] || 0
                readonly property real size: dock.geom.size[index] || dock.tile
                // Finder always runs on the Mac (its dot shows with no Finder window, screens/27.2.1/dock/dock-*.png; the
                // desktop is Finder's, Q-menubar-31)
                readonly property bool running: (modelData.windows || []).length > 0 || modelData.id === "hyprk-finder"
                readonly property bool launching: Apps.isLaunching(modelData.id) && !running
                // a window appeared: launching is over, the bounce in progress still lands (Apps.stopLaunching)
                readonly property bool launchDone: running && Apps.isLaunching(modelData.id)
                // after this change settles: stopLaunching rewrites Apps.launching, which launchDone reads (the
                // binding loop warning); an arrow per call, so two cells in one turn do not coalesce
                onLaunchDoneChanged: if (launchDone) { const id = modelData.id; Qt.callLater(() => Apps.stopLaunching(id)); }
                // an urgent window asks for attention until it is focused
                readonly property bool urgent: (modelData.windows || []).some(w => w && w.urgent)
                onUrgentChanged: if (!separator) Apps.markAttention(modelData.id, urgent)
                Component.onCompleted: {
                    if (launchDone) Apps.stopLaunching(modelData.id);
                    if (urgent) Apps.markAttention(modelData.id, true);
                    if (dock.slotsLive) { grow = 0; slide(1); }
                }

                x: dock.geom.x[index] || 0
                width: dock.geom.w[index] || 0
                height: dock.m.height

                // separator: 1 pt from the background top + 6 to the bottom - 6, square ends (Q-dock-06). At a
                // fractional scale the item is one device pixel larger on every side (`pad`, shaders/plusfill.frag):
                // the line's far edge falls inside a pixel there and its antialiasing ramp needs that pixel (1.5: [1]
                // before, [1, .5] now, the Mac's More Space downsample; SCALING-AUDIT.md R3.3). 0 at 1x and 2x
                ShaderEffect {
                    visible: cell.separator
                    property real pad: Pixel.soft(dock.dpr) ? 1 / dock.dpr : 0
                    x: Math.round((cell.width - dock.m.sepWidth) / 2 * dock.dpr) / dock.dpr - pad
                    y: dock.m.sepInset - pad
                    width: dock.m.sepWidth + 2 * pad
                    height: cell.height - dock.m.sepInset * 2 + 2 * pad
                    property vector4d fill: Theme.dock.separator
                    property size sizePt: Qt.size(dock.m.sepWidth, cell.height - dock.m.sepInset * 2)
                    property real radius: 0
                    property real dpr: dock.dpr
                    fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
                }
                // the Dock's own menu on a right click on the separator (Dock.app DockMenus.plist "dock",
                // Apps.dockSeparatorMenu), above the Dock like the item menus
                MouseArea {
                    anchors.fill: parent
                    enabled: cell.separator
                    visible: cell.separator
                    acceptedButtons: Qt.RightButton
                    onClicked: Panels.openContext(Apps.dockSeparatorMenu(), (dock.width - dock.geom.baseWidth) / 2 + cell.baseCenter,
                                                  dock.screen.height - dock.height + dock.restY, true, dock.screen)
                }

                // drag a separator up or down: the Dock grows or shrinks (lib/dock.js resizeTile / resizeArea have
                // the Dock's code). The travel is measured from the screen's bottom edge, which the surface keeps
                MouseArea {
                    readonly property var area: DockLayout.resizeArea(cell.width, cell.height)
                    x: area.x; y: area.y; width: area.width; height: area.height
                    enabled: cell.separator
                    visible: cell.separator
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.SizeVerCursor
                    preventStealing: true
                    hoverEnabled: true
                    property real pressUp: 0
                    property int pressTile: 0
                    function up(m) { return dock.height - mapToItem(null, m.x, m.y).y; }
                    onPressed: m => { pressUp = up(m); pressTile = dock.tile; dock.resizeTile = dock.tile; }
                    onPositionChanged: m => {
                        if (pressed) dock.resizeTile = DockLayout.resizeTile(pressTile, up(m) - pressUp, (m.modifiers & Qt.AltModifier) !== 0);
                    }
                    // the release writes `tilesize`; a press the compositor ended (the pointer left the surface) too
                    function done() {
                        if (dock.resizeTile > 0 && dock.resizeTile !== State.dockTile(Prefs.dock)) Prefs.setDock({ size: dock.resizeTile });
                        dock.resizeTile = 0;
                    }
                    onReleased: done()
                    onCanceled: done()
                }

                // height above the rest position: the attention bounce, else the launch bounce
                readonly property real bounceT: A11y.reduceMotion || separator ? -1 : Apps.bounceTime(modelData.id, dock.now)
                readonly property real attentionY: A11y.reduceMotion || separator ? 0 : Apps.attentionOffset(modelData.id, dock.now, dock.attentionHeight)
                readonly property bool bouncing: bounceT >= 0 || attentionY > 0
                readonly property real bounceY: Math.round(attentionY > 0 ? attentionY : bounceT < 0 ? 0 : DockLayout.bounceOffset(bounceT, dock.bounceHeight))
                // the tile's top edge at rest (it grows upward out of the cell when magnified)
                readonly property real iconTop: dock.m.iconTop + dock.tile - size

                // pressed: the art darkened x 0.475, no scale, on and off in one frame (Q-dock-09)
                // Display as Folder (its menu) shows the folder instead
                readonly property bool stack: cell.modelData.folder === "Downloads" && dock.downloadsStack.length > 0 && Apps.downloads.display !== "folder"
                AppIcon {
                    id: icon
                    visible: !cell.separator && dock.dragCell !== cell && !cell.stack && !(dock.stackOpen && cell.modelData.folder === "Downloads")
                    size: cell.size
                    loadSize: dock.magnification ? dock.large : dock.tile    // load once at full size, then only scale
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: cell.iconTop - cell.bounceY
                    // a removed tile shrinks out with its slot; an added one is full size at once (in the air)
                    scale: cell.leaving ? cell.grow : 1
                    transformOrigin: Item.Bottom
                    icon: cell.modelData.trash && dock.trashFull ? "user-trash-full" : cell.modelData.icon || ""
                    appId: cell.modelData.id || ""
                    layer.enabled: ma.containsPress
                    layer.effect: ShaderEffect {
                        property real k: 0.475
                        fragmentShader: Qt.resolvedUrl("../shaders/darken.frag.qsb")
                    }
                }

                Item {
                    // hidden while the popup lives: on the Mac the fan's items fly back into the tile and become the
                    // pile, the tile is empty through the close (stack-fan-close.mov, stack-grid-close.mov)
                    visible: cell.stack && dock.dragCell !== cell && !dock.stackOpen && !dock.stackLive
                    width: cell.size
                    height: cell.size
                    x: icon.x
                    y: icon.y
                    scale: icon.scale
                    transformOrigin: Item.Bottom
                    layer.enabled: ma.containsPress
                    layer.effect: ShaderEffect {
                        property real k: 0.475
                        fragmentShader: Qt.resolvedUrl("../shaders/darken.frag.qsb")
                    }
                    // back first, so the newest is drawn on top. The model is only the count, so a size change
                    // (magnification) moves and scales the items instead of recreating them (and reloading their art)
                    Repeater {
                        id: pileRep
                        readonly property int n: cell.stack ? Math.min(3, dock.downloadsStack.length) : 0
                        readonly property var boxes: DockStackLayout.pile(cell.size, n)
                        readonly property var big: DockStackLayout.pile(dock.magnification ? dock.large : dock.tile, n)
                        model: n
                        StackArt {
                            required property int index
                            readonly property int k: pileRep.n - 1 - index
                            readonly property var box: pileRep.boxes[k] || ({ x: 0, y: 0, size: 0 })
                            x: box.x
                            y: box.y
                            size: box.size
                            loadSize: (pileRep.big[k] || box).size   // load once at the magnified size, then only scale (as AppIcon)
                            file: dock.downloadsStack[k] || ({})
                            dpr: dock.dpr
                        }
                    }
                }
                // while its stack is open the tile shows a dark plate with a white chevron (measured on
                // stack-fan-open-dark.png / stack-grid-open-dark.png: Theme.dock.stack.chevron*). It goes at the close's
                // first frame; the tile then stays empty until the flying items land (stack-fan-close.mov)
                Rectangle {
                    visible: cell.modelData.folder === "Downloads" && dock.stackOpen
                    width: cell.size * Theme.dock.stack.chevronPlate
                    height: width
                    x: icon.x + (cell.size - width) / 2
                    y: icon.y + (cell.size - height) / 2
                    radius: cell.size * Theme.dock.stack.chevronPlateRadius
                    gradient: Gradient {
                        GradientStop { position: 0; color: Theme.dock.stack.chevronPlateTop }
                        GradientStop { position: 1; color: Theme.dock.stack.chevronPlateBottom }
                    }
                    Canvas {
                        anchors.fill: parent
                        readonly property real k: cell.size
                        onKChanged: requestPaint()
                        onPaint: {
                            const c = getContext("2d"), s = Theme.dock.stack, sw = k * s.chevronStroke;
                            const hw = (k * s.chevronWidth - sw) / 2, hh = (k * s.chevronHeight - sw) / 2;
                            const cx = width / 2, cy = height / 2 + k * s.chevronDrop;
                            c.reset();
                            c.strokeStyle = "white";
                            c.lineWidth = sw;
                            c.lineCap = "round";
                            c.lineJoin = "round";
                            c.beginPath();
                            c.moveTo(cx - hw, cy - hh);
                            c.lineTo(cx, cy + hh);
                            c.lineTo(cx + hw, cy - hh);
                            c.stroke();
                        }
                    }
                }

                // running dot, also while launching (with Reduce Motion it is the only launch feedback): 4.1 pt,
                // its centre 5 pt below the art bottom at rest (Q-dock-07). On the plugin it is a fill shape on the
                // dots surface below (dock.pluginDots); this one is the fallback
                // "Show indicators for open applications" (Desktop & Dock, show-process-indicators, on by default)
                readonly property bool dot: (cell.running || cell.launching) && Prefs.dock.showIndicators !== false
                ShaderEffect {
                    visible: cell.dot && !dock.dotsUp
                    width: dock.m.dot
                    height: width
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: dock.dotRowY - height / 2
                    property vector4d fill: Theme.dock.dot
                    property size sizePt: Qt.size(width, height)
                    property real radius: width / 2
                    property real dpr: dock.dpr
                    property real pad: 0   // the shader's optional uniform (no Qt warning)
                    fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
                }

                // app name label (timing: dock.tipShow / tipHide)
                readonly property bool tipWanted: ma.containsMouse && !separator && !leaving && !bouncing && Panels.open !== "context" && !dock.stackOpen && !dock.dragCell
                onTipWantedChanged: tipWanted ? dock.tipShow(cell) : dock.tipHide(cell)

                // the whole item frame (they abut, Q-dock-05) and the band above a magnified icon, so the label
                // moves to the next icon in one frame
                MouseArea {
                    id: ma
                    y: Math.min(0, cell.iconTop - dock.m.iconTop)
                    width: cell.width
                    height: cell.height - y
                    hoverEnabled: true
                    enabled: !cell.separator && !cell.leaving
                    // not over a separator: this area lies above its resize area, and Qt Quick takes the cursor from the
                    // topmost visible area under the pointer, disabled or not (the arrow instead of resize up-down)
                    visible: !cell.separator
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    // drag off (see dock.dragMove): window coordinates of the press, and whether this press dragged
                    property point pressAt: Qt.point(0, 0)
                    property bool dragged: false
                    onPressed: m => {
                        dragged = false;
                        pressAt = mapToItem(null, m.x, m.y);
                    }
                    onPositionChanged: m => {
                        if (!pressed || !(pressedButtons & Qt.LeftButton)) return;
                        const p = mapToItem(null, m.x, m.y);
                        if (!dragged) {
                            if (dock.dragCell !== null || !Apps.canRemove(cell.modelData.id)
                                || Math.hypot(p.x - pressAt.x, p.y - pressAt.y) < Qt.styleHints.startDragDistance) return;
                            dragged = true;
                            const i = icon.mapToItem(null, 0, 0);
                            dock.dragGrab = Qt.point(pressAt.x - i.x, pressAt.y - i.y);
                            dock.dragInfo = { icon: cell.modelData.icon || "", appId: cell.modelData.id || "", size: cell.size };
                            dock.dragCell = cell;
                        }
                        dock.dragMove(cell, p.x, p.y);
                    }
                    onReleased: if (dragged && dock.dragCell === cell) dock.dragDrop(cell)
                    onCanceled: if (dragged && dock.dragCell === cell) { if (dock.dragOut) cell.slide(1); dock.endDrag(); }
                    onClicked: m => {
                        if (dragged) return;
                        if (m.button === Qt.RightButton) {
                            // menu above the icon, like the macOS Dock (its window bottom = the Dock top, Q-dock-10).
                            // Anchored to the unmagnified layout because icons shrink when the menu opens.
                            const x = (dock.width - dock.geom.baseWidth) / 2 + cell.baseCenter;
                            Panels.openContext(Apps.dockMenu(cell.modelData), x, dock.screen.height - dock.height + dock.restY, true, dock.screen);
                        } else if (cell.modelData.trash) Apps.openTrash();
                        else if (cell.modelData.folder === "Downloads") dock.openStack(cell);
                        else if (cell.modelData.folder) Apps.openFolder(cell.modelData);
                        else Apps.activate(cell.modelData);
                    }
                }
            }
        }
    }

    // ---------- running dots on the plugin ----------
    // The Mac blends the dots plus-darker -128/255 (light) / plus-lighter +125/255 (dark) with the Dock's glass under
    // them (Q-dock-07: light 229/134/38 -> 101/6/0, dark 12 -> 137). Qt cannot blend with the compositor's glass, so on
    // the plugin they are fill shapes (`fill_layers` hyprk-dock-dots:darker:128, hyprk-dock-dots-dark:lighter:125) on a
    // surface of their own over the Dock's, created once the Dock has drawn its first frame so Hyprland stacks it
    // above (the Switcher's fill surface does the same). A strip along the screen bottom from just above the dots
    // (a full Dock-sized surface cost 6-9 MB anon for its buffers), same layer as the Dock, no input; it follows the
    // slide (the dots leave through its bottom edge) and magnification from the same cell geometry. Qt draws nothing.
    readonly property real dotRowY: m.iconTop + tile - m.artInset + m.dotBelowArt   // dot centre, in the Dock background
    readonly property bool pluginDots: Theme.compositorGlass && !Theme.solidMaterial
    property bool dockDrawn: false
    Connections {
        target: stage.Window.window
        enabled: !dock.dockDrawn
        function onFrameSwapped() { dock.dockDrawn = true; }
    }
    readonly property bool dotsUp: pluginDots && dockDrawn
    // the namespace (fill direction) is fixed when a layer surface is created: a new surface on a mode change
    property bool dotsRenew: false
    Connections {
        target: Theme
        function onDarkChanged() { dock.dotsRenew = true; Qt.callLater(() => dock.dotsRenew = false); }
    }
    LazyLoader {
        active: dock.dotsUp && !dock.dotsRenew
        ShellWindow {
            screen: dock.screen
            visible: dock.visible
            id: dots
            anchors { bottom: true; left: true; right: true }
            implicitHeight: Math.ceil(dock.m.height + dock.m.bottomGap - dock.dotRowY + dock.m.dot)
            // this surface's top in the Dock window's coordinates (both end at the screen bottom)
            readonly property real top: dock.height - height
            exclusionMode: ExclusionMode.Ignore
            namespace: Theme.dark ? "hyprk-dock-dots-dark" : "hyprk-dock-dots"
            WlrLayershell.layer: dock.WlrLayershell.layer
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            acceptsInput: false
            glassOpacity: bg.opacity

            Repeater {
                model: cellRepeater.count
                Glass {
                    required property int index
                    readonly property Item c: cellRepeater.itemAt(index)
                    visible: c !== null && c.dot && bg.visible
                    // whole points like every glass shape: 4 (the Mac's 4.1), centred on the tile and on the dot row.
                    // A square region: the plugin cannot read a 2 pt radius back from a 4 pt staircase (radius 2 came
                    // out 8 x 6 px), the circle is its `radii` hyprk-dock-dots:2.05 (config/hypr/hyprland.lua)
                    width: Math.round(dock.m.dot)
                    height: width
                    radius: 0
                    x: c ? bg.x + c.x + (c.width - width) / 2 : 0
                    y: bg.y + dock.dotRowY - height / 2 - dots.top
                }
            }
        }
    }

    // App name label: a glass capsule 26 pt tall (radius 13), ceil(text) + 2 x 13 wide (at least 41), its bottom 9 pt
    // above the tile top (above the Dock background at rest), centred on the icon (lib/dock.js labelWidth).
    // Material: Liquid Glass (ECCartoucheGlassLayerController); on the plugin the label's own recipe (namespace
    // hyprk-dock-label below). Pointer (Q-dock-08: about 16 x 6.5 pt, rounded tip 2.5 pt above the Dock): a marker rect
    // under the capsule that the plugin draws as Apple's pointer, a 16 pt square turned 45 deg with corner 2.5 unioned
    // to the pill at smoothness 25 (plugin/README.md "Dock label pointer"). The tip is inside that reach of the Dock
    // too, so the label is on a surface of its own (same geometry and recipe as the Dock: the union is per surface),
    // mapped only while the label shows.
    ShellWindow {
        id: labelHost
        screen: dock.screen
        visible: label.shown || dock.dragging
        anchors { bottom: true; left: true; right: true }
        implicitHeight: dock.dragging && dock.screen ? dock.screen.height : dock.implicitHeight
        readonly property real off: height - dock.height     // the Dock window's top in this one
        exclusionMode: ExclusionMode.Ignore
        // Apple's label glass from the plugin (Regular recipe at this size, plugin bbd615a; dark over black / grey /
        // white 32 / 131 / 180, Mac 31 / 131 / 180), no fill of ours on top; the Dock's layer rules (config 9c2ca30)
        namespace: "hyprk-dock-label"
        WlrLayershell.layer: WlrLayer.Top
        acceptsInput: false

    FrameAnim { id: tipFade; target: dock; property: "tipAlpha"; to: 0; ease: Easing.InOutSine
                duration: Theme.ms(dock.autohide ? Theme.anim.dockSlide : 300) }
    FrameAnim {
        id: dropFade
        // 260 ms: the Mac's 16 frames (.98 .91 .87 .78 ... .08 0, dock-drag-off-hand.mov) are a line of 15.6 frames;
        // with 250 the icon was gone a frame early (233 ms after the first fading frame, Mac 250)
        target: dock; property: "dragFade"; from: 1; to: 0; duration: Theme.ms(260)
        onFinished: dock.endDrag()
    }

    Glass {
        id: label
        readonly property bool shown: dock.tipItem !== null && dock.tipAlpha > 0 && bg.visible
        visible: shown
        width: DockLayout.labelWidth(labelText.implicitWidth)
        height: 26
        x: dock.tipItem ? Math.max(0, Math.min(dock.width - width, Math.round(bg.x + dock.tipItem.x + dock.tipItem.width / 2 - width / 2))) : 0
        y: dock.tipItem ? Math.round(labelHost.off + bg.y + dock.tipItem.iconTop - dock.m.iconTop - 9 - height) : 0
        radius: 13
        sx: x
        sy: dock.screen.height - labelHost.height + y
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: "transparent"
        shadow: false
        materialize: dock.tipAlpha
        Text {
            id: labelText
            anchors.centerIn: parent
            width: Math.min(implicitWidth, 600)
            elide: Text.ElideMiddle
            opacity: dock.tipAlpha
            text: dock.tipItem ? dock.tipItem.modelData.name || "" : ""
            font: Typography.font(Theme.font.dockLabel)
            color: Theme.dock.labelText
        }
    }
    // the pointer marker: centred on the pill, 1 pt below it (touching, the region union would merge it into the pill).
    // It stays through the label's fade-out: the plugin fades the pointer with the pill (8199aad, 5e9aff0; mcap over
    // grey, dark: pointer region 267 ms, rms 0.019 against the Mac's label series, no step)
    Glass {
        visible: label.visible && Theme.compositorGlass && !Theme.solidMaterial
        width: Theme.dock.labelPointer.width
        height: Theme.dock.labelPointer.height
        x: Math.round(label.x + label.width / 2) - width / 2
        y: label.y + label.height + 1
        sx: x
        sy: label.sy + y - label.y
        radius: 0
        shadow: false
        pointer: true
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: "transparent"
    }
    // the dragged tile (drag off, above): the Dock's art size, where the pointer holds it
    AppIcon {
        id: dragIcon
        visible: dock.dragging && dock.dragInfo !== null
        size: dock.dragInfo ? dock.dragInfo.size : dock.tile
        loadSize: dock.magnification ? dock.large : dock.tile
        x: dock.dragPos.x - dock.dragGrab.x
        y: labelHost.off + dock.dragPos.y - dock.dragGrab.y
        opacity: dock.dragFade
        icon: dock.dragInfo ? dock.dragInfo.icon : ""
        appId: dock.dragInfo ? dock.dragInfo.appId : ""
    }
    // the "Remove" bubble over a tile dragged off (Q-dock-17): the hover label's style, its bottom 9 pt above the tile
    Glass {
        id: removeLabel
        visible: dock.removeShown
        width: DockLayout.labelWidth(removeText.implicitWidth)
        height: 26
        x: Math.round(dragIcon.x + dragIcon.width / 2 - width / 2)
        y: Math.round(dragIcon.y - 9 - height)
        radius: 13
        sx: x
        sy: dock.screen.height - labelHost.height + y
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: "transparent"
        shadow: false
        materialize: dock.dragFade
        Text {
            id: removeText
            anchors.centerIn: parent
            opacity: dock.dragFade
            text: "Remove"
            font: Typography.font(Theme.font.dockLabel)
            color: Theme.dock.labelText
        }
    }
    Glass {
        visible: removeLabel.visible && Theme.compositorGlass && !Theme.solidMaterial
        width: Theme.dock.labelPointer.width
        height: Theme.dock.labelPointer.height
        x: Math.round(removeLabel.x + removeLabel.width / 2) - width / 2
        y: removeLabel.y + removeLabel.height + 1
        sx: x
        sy: removeLabel.sy + y - removeLabel.y
        radius: 0
        shadow: false
        pointer: true
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: "transparent"
    }
    }
}
