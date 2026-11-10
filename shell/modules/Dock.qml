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

// Floating glass Dock: running dots, separator, Downloads + Trash, app name label on hover,
// launch on click with bounce, press lift on icons, magnification when switched on.
// Hidden while a window is full screen on this output, and with "Automatically hide and show the
// Dock" (state/dock.json) until the pointer rests on the bottom edge for the autohide delay.
// Liquid Glass: it slides down while dematerializing and comes back materializing (also when the
// shell starts). Reduce motion: a dissolve in place, and no launch bounce (only the running dot).
ShellWindow {
    id: dock

    required property var modelData
    screen: modelData

    // tile from the screen width (see Theme.dock.tileFraction)
    readonly property int base: Math.round((screen ? screen.width : 1440) * Theme.dock.tileFraction)
    // magnified size: the Magnification slider's ratio to the Size slider (state/dock.json, default 96/48 = 2,
    // SPEC.md 7 largesize 128 / tilesize 64); the tile itself follows the screen width
    readonly property int magnified: Math.round(base * State.magnifyRatio(Prefs.dock))
    readonly property int pad: Theme.dock.padding
    readonly property int sidePad: Theme.dock.sidePadding
    readonly property int bgHeight: base + pad * 2
    readonly property int tooltipRoom: Theme.dock.tooltipHeight + Theme.dock.tooltipGap + 8
    readonly property real dpr: screen && screen.devicePixelRatio > 0 ? screen.devicePixelRatio : 1

    // Magnification is off by default, like macOS (state/dock.json `magnification`, Settings >
    // Desktop & Dock > Magnification). Off: hovering only shows the app name, nothing moves.
    readonly property bool magnification: Prefs.dock.magnification === true

    // ---------- launch bounce ----------
    // MAC-ANSWERS.md R2 (27.2.1): 0.70 s per bounce at every tile size, rise, a 0.14 s hold at the top,
    // a mirrored fall, one frame on the ground (curve in lib/dock.js bounceOffset), repeated while the app
    // launches (until it has a window; Apps stops it after 6 s); when launching ends the bounce in
    // progress finishes and the icon stays down. Height 11 pt at tile 33, 18 pt at tile 64, linear in
    // the tile size. No squash, never below the rest position, the Dock does not resize.
    readonly property real bounceHeight: DockLayout.bounceHeight(base)
    readonly property int bouncePeriod: 700

    readonly property int iconRoom: (magnification ? magnified : base) + Math.max(tooltipRoom, bounceHeight)
    anchors { bottom: true; left: true; right: true }
    implicitHeight: iconRoom + pad + Theme.dock.bottomMargin
    exclusiveZone: autohide ? 0 : bgHeight + Theme.dock.bottomMargin
    namespace: "hyprk-dock"
    WlrLayershell.layer: WlrLayer.Top
    inputMask: Region { item: hit }

    // ---------- genie target (plugin-motion) ----------
    // Where minimized windows go, global logical px, unmagnified layout (plugin-motion pickTarget):
    // each window into its app's Dock icon, like macOS's default minimize-to-application = 1
    // (MAC-ANSWERS.md R2 (27.2.1): minimise goes into the app's icon) as "<address> x y w h", and
    // for any other window the slot a minimized tile takes with that setting off, just left of
    // Downloads/Trash. Sent only when it changes, from the primary screen's Dock; errors
    // (plugin-motion not loaded) are ignored.
    readonly property bool primaryDock: screen === Panels.screen
    readonly property string genieTarget: {
        if (!primaryDock || !screen) return "";
        const x0 = screen.x + (dock.width - dock.baseWidth) / 2;
        const top = screen.y + screen.height - Theme.dock.bottomMargin - pad - base;
        const rect = left => [left, top, base, base].map(Math.round).join(" ");
        const out = [rect(x0 + dock.sidePad + (sepIndex + 1) * (base + Theme.dock.iconSpacing) + sepCell - base)];
        items.forEach((it, i) => (it.windows || []).forEach(w => {
            if (w && w.address) out.push(String(w.address) + " " + rect(x0 + geom.center[i] - base / 2));
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
    readonly property bool autohide: Prefs.dock.autohide
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property bool fullscreen: hyprMonitor && hyprMonitor.activeWorkspace ? hyprMonitor.activeWorkspace.hasFullscreen : false
    property bool pointerIn: false
    property bool revealed: false
    Timer { id: revealDelay; interval: Theme.anim.dockAutohideDelay; onTriggered: dock.revealed = true }
    onPointerInChanged: {
        if (pointerIn) revealDelay.restart();
        else { revealDelay.stop(); revealed = false; }
    }
    // a Dock menu (opened above an icon) keeps it up
    readonly property bool shown: !fullscreen && (!autohide || revealed || (Panels.open === "context" && Panels.contextAbove && Panels.activeScreen === dock.screen))
    Materializer { id: mat; shown: dock.shown; initial: 0 }
    readonly property real hideY: A11y.reduceMotion ? 0 : (1 - mat.value) * (bgHeight + Theme.dock.bottomMargin + 12)

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

    readonly property var items: Apps.dockItems.concat([{ id: "hyprk-separator", separator: true },
                                                        { id: "hyprk-downloads", name: "Downloads", icon: "folder-download", folder: "Downloads" },
                                                        { id: "hyprk-trash", name: "Trash", icon: "user-trash", trash: true }])
    readonly property int sepIndex: items.length - 3
    // separator cell width; the icon spacing on both sides is part of the visual gap
    readonly property real sepCell: Theme.dock.separatorHPad * 2 + Theme.dock.separatorWidth - Theme.dock.iconSpacing * 2
    // unmagnified cell widths, the separator fixed (negative, see lib/dock.js)
    readonly property var cellWidths: items.map(it => it.separator ? -sepCell : base)

    // ---------- hover and magnification ----------
    // The pointer is mapped into the unmagnified layout, so magnification never feeds back into
    // itself. The sizes follow the pointer directly every frame; only entering and leaving the Dock
    // ramp the curve in and out (`magnify`), around the last pointer position.
    property real focusX: 0
    readonly property real baseWidth: geom.baseWidth
    // MAC-ANSWERS.md R2 (27.2.1): grows in about 0.12 s (7 frames, ease-in-out) on entering the Dock and
    // collapses the same way on leaving
    property real magnify: magnification && pointerIn && shown && Panels.open !== "context" ? 1 : 0
    Behavior on magnify { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

    readonly property var geom: DockLayout.layout(cellWidths, {
        base: base, big: magnified, amount: magnify, focus: focusX,
        range: DockLayout.magnifyRange(base),      // MAC-ANSWERS.md R2 (27.2.1): 222 pt at tile 64
        spacing: Theme.dock.iconSpacing, sidePad: sidePad, dpr: dpr
    })

    // ---------- app name label ----------
    // MAC-ANSWERS.md R2 (27.2.1): it appears in the frame after the pointer reaches an icon (no delay, no
    // fade-in), moves to the next icon in one frame, and on leaving the Dock fades out in about 0.23 s
    // (ease-in-out). One label shows at a time: `tipCell` is the cell that has it.
    property int tipCell: -1
    property real tipAlpha: 0
    NumberAnimation { id: tipFade; target: dock; property: "tipAlpha"; to: 0; duration: 230; easing.type: Easing.InOutQuad }
    function tipShow(i) { tipFade.stop(); tipCell = i; tipAlpha = 1; }
    function tipHide(i) { if (tipCell === i) tipFade.restart(); }

    // hit area: the background, plus the magnified band while magnified; hidden by autohide only
    // the bottom edge below it (reveals it), hidden by a full-screen window nothing
    Item {
        id: hit
        x: bg.x
        width: dock.shown || dock.autohide && !dock.fullscreen ? bg.width : 0
        y: !dock.shown ? dock.height - 2 : dock.magnify > 0 ? bg.y - (dock.magnified - dock.base) : bg.y   // until the ramp-out ends
        height: dock.height - y
    }

    // on the window's root item so it sees hover above child MouseAreas
    HoverHandler {
        onPointChanged: if (hovered) dock.focusX = point.position.x - (dock.width - dock.baseWidth) / 2
        onHoveredChanged: dock.pointerIn = hovered
    }

    // test hook: `qs ipc call dock bounce <dock item id>` bounces that icon as if it were launching
    IpcHandler {
        target: "dock"
        enabled: dock.primaryDock
        function bounce(id: string): void { Apps.markLaunching(id); }
    }

    Item {
        id: stage
        anchors.fill: parent
        visible: mat.active
        transform: [
            MaterializeScale {
                mat: mat
                origin.x: bg.x + bg.width / 2
                origin.y: bg.y + bg.height
                w: bg.width
                h: bg.height
            },
            Translate { y: dock.hideY }
        ]

        // whole logical px, like the compositor glass region, so tint and glass edges line up
        Glass {
            id: bg
            width: dock.geom.width
            height: dock.bgHeight
            x: Math.round((dock.width - width) / 2)
            y: dock.height - height - Theme.dock.bottomMargin
            radius: Theme.dock.radius
            sx: x
            sy: dock.screen.height - dock.height + y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: Theme.dock.pluginLift
            materialize: mat.progress
        }

        Repeater {
            model: dock.items
            delegate: Item {
                id: cell
                required property var modelData
                required property int index

                // center of this cell in the unmagnified layout
                readonly property real baseCenter: dock.geom.center[index] || 0
                readonly property real size: modelData.separator ? dock.base : dock.geom.w[index] || dock.base
                readonly property bool running: (modelData.windows || []).length > 0
                readonly property bool launching: Apps.isLaunching(modelData.id) && !running
                readonly property bool bouncing: launching && !A11y.reduceMotion

                x: bg.x + (dock.geom.x[index] || 0)
                y: bg.y + dock.pad
                width: dock.geom.w[index] || 0
                height: dock.base            // constant; the icon grows upward out of the cell
                opacity: mat.progress

                // separator
                Rectangle {
                    visible: cell.modelData.separator === true
                    x: Math.round((parent.width - width) / 2 * dock.dpr) / dock.dpr
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.dock.separatorInset - dock.pad
                    width: Theme.dock.separatorWidth
                    height: dock.base - (Theme.dock.separatorInset - dock.pad) * 2
                    color: Theme.dock.separator
                }

                // one bounce, 0..1, linear in time (the shape is in lib/dock.js bounceOffset)
                property real hop: 1
                NumberAnimation on hop {
                    running: cell.bouncing
                    from: 0; to: 1
                    duration: dock.bouncePeriod
                    loops: Animation.Infinite
                    alwaysRunToEnd: true         // a hop in the air lands before it stops
                }
                readonly property real bounceY: Math.round(DockLayout.bounceOffset(hop, dock.bounceHeight) * dock.dpr) / dock.dpr

                // interactive press: the icon lifts (FlexInteraction ultraSmall) and darkens
                PressSpring { id: press; pressed: ma.containsPress; w: icon.width; h: icon.height; settlesGlass: false }
                AppIcon {
                    id: icon
                    transform: Scale { origin.x: icon.width / 2; origin.y: icon.height / 2; xScale: press.scale; yScale: press.scale }
                    visible: !cell.modelData.separator
                    size: cell.size
                    loadSize: dock.magnified     // load once at full size, then only scale
                    x: 0
                    y: cell.height - height - cell.bounceY
                    icon: cell.modelData.trash && dock.trashFull ? "user-trash-full" : cell.modelData.icon || ""
                    appId: cell.modelData.id
                }
                Rectangle {
                    x: icon.x; y: icon.y; width: icon.width; height: icon.height
                    transform: Scale { origin.x: icon.width / 2; origin.y: icon.height / 2; xScale: press.scale; yScale: press.scale }
                    visible: ma.containsPress && !cell.modelData.separator
                    color: Qt.rgba(0, 0, 0, 0.25)
                    radius: width * 0.22
                }

                // running indicator, also while launching (with Reduce Motion it is the only launch feedback)
                Rectangle {
                    visible: cell.running || cell.launching
                    width: Theme.dock.dotSize
                    height: width
                    radius: width / 2
                    x: Math.round((cell.width - width) / 2 * dock.dpr) / dock.dpr
                    y: cell.height + Theme.dock.dotOffset
                    color: Theme.color.dockDot
                }

                // app name label above the icon (timing: dock.tipShow / tipHide)
                readonly property bool tipWanted: ma.containsMouse && !cell.modelData.separator && !cell.bouncing && Panels.open !== "context"
                onTipWantedChanged: tipWanted ? dock.tipShow(index) : dock.tipHide(index)
                Rectangle {
                    visible: dock.tipCell === cell.index && dock.tipAlpha > 0
                    opacity: dock.tipAlpha
                    x: Math.round((cell.width - width) / 2)
                    y: icon.y - height - Theme.dock.tooltipGap
                    width: tip.implicitWidth + Theme.dock.tooltipHPad * 2
                    height: Theme.dock.tooltipHeight
                    radius: Theme.dock.tooltipRadius
                    color: Theme.color.tooltipBg
                    border.width: 1
                    border.color: Theme.glass.hairline
                    Text {
                        id: tip
                        anchors.centerIn: parent
                        text: cell.modelData.name || ""
                        font: Typography.font(Theme.font.dockTooltip)
                        color: Theme.color.label
                    }
                }

                // the whole cell column (icon and the band above it) plus half the icon spacing on each
                // side, so the label does not flicker in a gap while an icon bounces or the sizes change,
                // and moving to the next icon swaps it in one frame
                MouseArea {
                    id: ma
                    x: -Theme.dock.iconSpacing / 2; y: icon.y; width: cell.width + Theme.dock.iconSpacing; height: cell.height - icon.y + dock.pad
                    hoverEnabled: true
                    enabled: !cell.modelData.separator
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: m => {
                        if (m.button === Qt.RightButton) {
                            // menu above the icon, like the macOS Dock. Anchored to the
                            // unmagnified layout because icons shrink when the menu opens.
                            const x = (dock.width - dock.baseWidth) / 2 + cell.baseCenter;
                            Panels.openContext(Apps.dockMenu(cell.modelData), x, dock.screen.height - dock.height + bg.y - Theme.dock.tooltipGap, true, dock.screen);
                        } else if (cell.modelData.trash) Apps.openTrash();
                        else if (cell.modelData.folder) Apps.openFolder(cell.modelData);
                        else Apps.activate(cell.modelData);
                    }
                }
            }
        }
    }
}
