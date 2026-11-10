import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/dock.js" as DockLayout
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

    // ---------- items ----------
    readonly property var others: [{ id: "hyprk-downloads", name: "Downloads", icon: "folder-download", folder: "Downloads" },
                                   { id: "hyprk-trash", name: "Trash", icon: "user-trash", trash: true }]
    readonly property var items: DockLayout.sections(Apps.pinnedItems, Apps.runningUnpinned, Apps.recent, Prefs.dock.showRecents !== false, others)
    readonly property var cells: items.map(it => it.separator ? "separator" : "tile")
    readonly property int separators: cells.filter(c => c === "separator").length
    readonly property int trashIndex: items.length - 1

    // ---------- geometry ----------
    readonly property int tile: DockLayout.fitTile(State.dockTile(Prefs.dock), items.length - separators, separators, screen ? screen.width : 1920)
    readonly property var m: DockLayout.metrics(tile)
    // magnified size: the Magnification slider's ratio to the Size slider (state/dock.json, default 96/48 = 2)
    readonly property int large: Math.round(tile * State.magnifyRatio(Prefs.dock))
    readonly property real dpr: screen && screen.devicePixelRatio > 0 ? screen.devicePixelRatio : 1
    // Magnification is off by default, like macOS (state/dock.json `magnification`, Settings >
    // Desktop & Dock > Magnification). Off: hovering only shows the app name, nothing moves.
    readonly property bool magnification: Prefs.dock.magnification === true
    readonly property real labelRoom: 26 + 9 + 4      // label capsule, its gap to the Dock, a margin
    readonly property real above: Math.max((magnification ? large - tile : 0) + labelRoom, DockLayout.attentionHeight(tile))

    anchors { bottom: true; left: true; right: true }
    implicitHeight: Math.ceil(above + m.height + m.bottomGap)
    exclusiveZone: autohide ? 0 : Math.ceil(m.height + m.bottomGap)
    namespace: "hyprk-dock"
    WlrLayershell.layer: WlrLayer.Top
    inputMask: Region { item: hit }

    // the band Mission Control leaves to the Dock (it stays visible there, Q-dock-27)
    readonly property int keepClear: shown && !autohide ? Math.ceil(m.height + m.bottomGap) : 0
    onKeepClearChanged: if (screen) Panels.setDockZone(screen.name, keepClear)

    // ---------- bounces ----------
    // Launch: 0.70 s parabolic hops, (tile - 8) * 0.2 + 6 pt high; attention (an urgent window): the 2 s cycle of
    // three hops, tile + 1 pt high (lib/dock.js, from Dock.app's -[Tile updateBouncing]). The heights are read
    // from the wall clock every frame while something bounces; the clock is off otherwise, and between attention
    // bursts a timer wakes it.
    readonly property real bounceHeight: DockLayout.bounceHeight(tile)
    readonly property real attentionHeight: DockLayout.attentionHeight(tile)
    property real now: Date.now()
    FrameAnimation {
        id: clock
        running: !A11y.reduceMotion && Apps.anyBouncing(dock.now)
        onRunningChanged: if (running) dock.now = Date.now()
        onTriggered: dock.now = Date.now()
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
        const x0 = screen.x + (dock.width - geom.baseWidth) / 2;
        const top = screen.y + screen.height - m.bottomGap - m.height + m.iconTop;
        const rect = left => [left, top, tile, tile].map(Math.round).join(" ");
        const out = [rect(x0 + geom.center[trashIndex] - tile / 2)];
        items.forEach((it, i) => (it.windows || []).forEach(w => {
            if (w && w.address) out.push(String(w.address) + " " + rect(x0 + geom.center[i] - tile / 2));
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
    readonly property bool fullscreen: hyprMonitor && hyprMonitor.activeWorkspace ? hyprMonitor.activeWorkspace.hasFullscreen : false
    property bool pointerIn: false
    property bool revealed: false
    Timer { id: revealDelay; interval: Theme.anim.dockRevealDelay; onTriggered: dock.revealed = true }
    Timer { id: hideDelay; interval: Theme.anim.dockHideDelay; onTriggered: dock.revealed = false }
    onPointerInChanged: {
        if (pointerIn) { hideDelay.stop(); if (!revealed) revealDelay.restart(); }
        else { revealDelay.stop(); hideDelay.restart(); }
    }
    // a Dock menu (opened above an icon) keeps it up
    readonly property bool shown: !fullscreen && (!autohide || revealed || (Panels.open === "context" && Panels.contextAbove && Panels.activeScreen === dock.screen))
    // 0 = hidden below the screen edge, 1 = in place; it also slides in when the shell starts
    property real slide: 0
    NumberAnimation {
        id: slideAnim
        target: dock
        property: "slide"
        easing.type: Easing.InOutSine
        onRunningChanged: if (running) dock.settleGlass(duration + 80)
    }
    function slideTo(v) {
        slideAnim.stop();
        slideAnim.to = v;
        slideAnim.duration = Theme.ms(Theme.anim.dockSlide);
        slideAnim.start();
    }
    onShownChanged: slideTo(shown ? 1 : 0)
    Component.onCompleted: {
        slideTo(shown ? 1 : 0);
        if (screen) Panels.setDockZone(screen.name, keepClear);
    }
    // the whole height of the background plus its gap: hidden, nothing is left on screen
    readonly property real hideY: A11y.reduceMotion ? 0 : Math.ceil((1 - slide) * (m.height + m.bottomGap))
    readonly property real restY: height - m.height - m.bottomGap

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
    readonly property real fishTarget: magnification && pointerIn && shown && Panels.open !== "context" ? 1 : 0
    property real fish: 0
    NumberAnimation { id: fishAnim; target: dock; property: "fish"; easing.type: Easing.InOutSine }
    onFishTargetChanged: {
        fishAnim.stop();
        fishAnim.to = fishTarget;
        fishAnim.duration = Theme.ms(DockLayout.fishDuration((fishTarget - fish) * (large - tile)));
        fishAnim.start();
    }
    readonly property var geom: DockLayout.layout(cells, { tile: tile, large: large, fish: fish, focus: fish > 0 ? focusX : 0, dpr: dpr })

    // ---------- app name label ----------
    // It shows in the frame the pointer reaches an icon (no fade-in), moves to the next icon in one frame, and on
    // leaving fades out over 300 ms on the Dock's cosine ease in-out, or over the autohide slide when autohide is on
    // (-[DockBar blendAwayLabel], reconciliation-42.json: cosine T 0.29 s). One label at a time: `tipCell`.
    property int tipCell: -1
    property real tipAlpha: 0
    NumberAnimation { id: tipFade; target: dock; property: "tipAlpha"; to: 0; easing.type: Easing.InOutSine
                      duration: Theme.ms(dock.autohide ? Theme.anim.dockSlide : 300) }
    function tipShow(i) { tipFade.stop(); tipCell = i; tipAlpha = 1; }
    function tipHide(i) { if (tipCell === i) tipFade.restart(); }

    // hit area: the background, plus the magnified band while magnified; hidden by autohide the bottom 2 pt of
    // the whole edge (reveals it), hidden by a full-screen window nothing
    Item {
        id: hit
        x: dock.shown ? bg.x : 0
        width: dock.shown ? bg.width : dock.autohide && !dock.fullscreen ? dock.width : 0
        y: !dock.shown ? dock.height - 2 : dock.fish > 0 ? dock.restY - (dock.large - dock.tile) : dock.restY
        height: dock.height - y
    }

    // on the window's root item so it sees hover above child MouseAreas
    HoverHandler {
        onPointChanged: if (hovered && dock.magnification) dock.focusX = point.position.x - (dock.width - dock.geom.baseWidth) / 2
        onHoveredChanged: dock.pointerIn = hovered
    }

    // test hooks: `qs ipc call dock bounce <dock item id>` bounces that icon as if it were launching,
    // `qs ipc call dock attention <dock item id> true|false` as if one of its windows were urgent
    IpcHandler {
        target: "dock"
        enabled: dock.primaryDock
        function bounce(id: string): void { Apps.markLaunching(id); }
        function attention(id: string, on: bool): void { Apps.markAttention(id, on); }
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
            model: dock.items
            delegate: Item {
                id: cell
                required property var modelData
                required property int index

                readonly property bool separator: modelData.separator === true
                // unmagnified centre of this cell (background coordinates)
                readonly property real baseCenter: dock.geom.center[index] || 0
                readonly property real size: dock.geom.size[index] || dock.tile
                readonly property bool running: (modelData.windows || []).length > 0
                readonly property bool launching: Apps.isLaunching(modelData.id) && !running
                // a window appeared: launching is over, the bounce in progress still lands (Apps.stopLaunching)
                readonly property bool launchDone: running && Apps.isLaunching(modelData.id)
                onLaunchDoneChanged: if (launchDone) Apps.stopLaunching(modelData.id)
                // an urgent window asks for attention until it is focused
                readonly property bool urgent: (modelData.windows || []).some(w => w && w.urgent)
                onUrgentChanged: if (!separator) Apps.markAttention(modelData.id, urgent)
                Component.onCompleted: {
                    if (launchDone) Apps.stopLaunching(modelData.id);
                    if (urgent) Apps.markAttention(modelData.id, true);
                }

                x: dock.geom.x[index] || 0
                width: dock.geom.w[index] || 0
                height: dock.m.height

                // separator: 1 pt from the background top + 6 to the bottom - 6, square ends (Q-dock-06)
                ShaderEffect {
                    visible: cell.separator
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: dock.m.sepInset
                    width: dock.m.sepWidth
                    height: cell.height - dock.m.sepInset * 2
                    property vector4d fill: Theme.dock.separator
                    property size sizePt: Qt.size(width, height)
                    property real radius: 0
                    property real dpr: dock.dpr
                    fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
                }

                // height above the rest position: the attention bounce, else the launch bounce
                readonly property real bounceT: A11y.reduceMotion || separator ? -1 : Apps.bounceTime(modelData.id, dock.now)
                readonly property real attentionY: A11y.reduceMotion || separator ? 0 : Apps.attentionOffset(modelData.id, dock.now, dock.attentionHeight)
                readonly property bool bouncing: bounceT >= 0 || attentionY > 0
                readonly property real bounceY: Math.round((attentionY > 0 ? attentionY : bounceT < 0 ? 0 : DockLayout.bounceOffset(bounceT, dock.bounceHeight)) * dock.dpr) / dock.dpr
                // the tile's top edge at rest (it grows upward out of the cell when magnified)
                readonly property real iconTop: dock.m.iconTop + dock.tile - size

                // pressed: the art darkened x 0.475, no scale, on and off in one frame (Q-dock-09)
                AppIcon {
                    id: icon
                    visible: !cell.separator
                    size: cell.size
                    loadSize: dock.magnification ? dock.large : dock.tile    // load once at full size, then only scale
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: cell.iconTop - cell.bounceY
                    icon: cell.modelData.trash && dock.trashFull ? "user-trash-full" : cell.modelData.icon || ""
                    appId: cell.modelData.id
                    layer.enabled: ma.containsPress
                    layer.effect: ShaderEffect {
                        property real k: 0.475
                        fragmentShader: Qt.resolvedUrl("../shaders/darken.frag.qsb")
                    }
                }

                // running dot, also while launching (with Reduce Motion it is the only launch feedback): 4.1 pt,
                // its centre 5 pt below the art bottom at rest (Q-dock-07)
                ShaderEffect {
                    visible: cell.running || cell.launching
                    width: dock.m.dot
                    height: width
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: dock.m.iconTop + dock.tile - dock.m.artInset + dock.m.dotBelowArt - height / 2
                    property vector4d fill: Theme.dock.dot
                    property size sizePt: Qt.size(width, height)
                    property real radius: width / 2
                    property real dpr: dock.dpr
                    fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
                }

                // app name label (timing: dock.tipShow / tipHide)
                readonly property bool tipWanted: ma.containsMouse && !separator && !bouncing && Panels.open !== "context"
                onTipWantedChanged: tipWanted ? dock.tipShow(index) : dock.tipHide(index)

                // the whole item frame (they abut, Q-dock-05) and the band above a magnified icon, so the label
                // moves to the next icon in one frame
                MouseArea {
                    id: ma
                    y: Math.min(0, cell.iconTop - dock.m.iconTop)
                    width: cell.width
                    height: cell.height - y
                    hoverEnabled: true
                    enabled: !cell.separator
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: m => {
                        if (m.button === Qt.RightButton) {
                            // menu above the icon, like the macOS Dock (its window bottom = the Dock top, Q-dock-10).
                            // Anchored to the unmagnified layout because icons shrink when the menu opens.
                            const x = (dock.width - dock.geom.baseWidth) / 2 + cell.baseCenter;
                            Panels.openContext(Apps.dockMenu(cell.modelData), x, dock.screen.height - dock.height + dock.restY, true, dock.screen);
                        } else if (cell.modelData.trash) Apps.openTrash();
                        else if (cell.modelData.folder) Apps.openFolder(cell.modelData);
                        else Apps.activate(cell.modelData);
                    }
                }
            }
        }
    }

    // App name label: a glass capsule 26 pt tall (radius 13), text + 2 x 14 wide (at least 41), its bottom 9 pt
    // above the tile top (above the Dock background at rest), centred on the icon (lib/dock.js labelWidth).
    // Material: Liquid Glass (ECCartoucheGlassLayerController); on the plugin it gets the Dock layer's glass plus
    // Theme.dock.labelFill. Its tail is not drawn: the tip is 2.5 pt above the Dock, inside the plugin's smooth
    // union reach (8), so a glass tail would merge into the Dock.
    readonly property var tipItem: tipCell >= 0 && tipCell < cellRepeater.count ? cellRepeater.itemAt(tipCell) : null
    Glass {
        id: label
        visible: dock.tipItem !== null && dock.tipAlpha > 0 && bg.visible
        width: DockLayout.labelWidth(labelText.implicitWidth)
        height: 26
        x: dock.tipItem ? Math.max(0, Math.min(dock.width - width, Math.round(bg.x + dock.tipItem.x + dock.tipItem.width / 2 - width / 2))) : 0
        y: dock.tipItem ? Math.round(bg.y + dock.tipItem.iconTop - dock.m.iconTop - 9 - height) : 0
        radius: 13
        sx: x
        sy: dock.screen.height - dock.height + y
        tint: Theme.glass.tintClear
        solidColor: Theme.glass.solidDock
        pluginLift: "transparent"
        shadow: false
        materialize: dock.tipAlpha
        ShaderEffect {
            anchors.fill: parent
            visible: Theme.compositorGlass && !Theme.solidMaterial
            opacity: dock.tipAlpha
            property vector4d fill: Theme.dock.labelFill
            property size sizePt: Qt.size(width, height)
            property real radius: 13
            property real dpr: dock.dpr
            fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
        }
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
}
