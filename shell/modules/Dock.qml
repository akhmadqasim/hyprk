import QtQuick
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
    // A ball under gravity: each hop is one parabola (fast at the bottom, stopped at the top), no squash,
    // never below the rest position, repeated until the app has a window (Apps stops it after 6 s).
    // The Dock does not resize. Names match reference/re/MAC-REQUESTS.md R2 (height, time per bounce, curve).
    readonly property real bounceHeight: Math.round(base * 0.5)   // guessed: half a tile; R2 will measure it in pt
    readonly property int bouncePeriod: 600                       // ms per hop, up and down; guessed, R2 will measure it

    readonly property int iconRoom: (magnification ? magnified : base) + Math.max(tooltipRoom, bounceHeight)
    anchors { bottom: true; left: true; right: true }
    implicitHeight: iconRoom + pad + Theme.dock.bottomMargin
    exclusiveZone: autohide ? 0 : bgHeight + Theme.dock.bottomMargin
    namespace: "hyprk-dock"
    WlrLayershell.layer: WlrLayer.Top
    inputMask: Region { item: hit }

    // ---------- genie target (plugin-motion) ----------
    // Where the next minimized window's tile would go: like macOS, the right section just left of
    // Downloads/Trash (the Downloads slot, unmagnified layout), in global logical px. Sent only when it
    // changes, from the primary screen's Dock; errors (plugin-motion not loaded) are ignored.
    readonly property bool primaryDock: screen === Panels.screen
    readonly property string genieTarget: {
        if (!primaryDock || !screen) return "";
        const left = (dock.width - dock.baseWidth) / 2 + dock.sidePad + (sepIndex + 1) * (base + Theme.dock.iconSpacing) + sepCell - base;
        const top = dock.height - Theme.dock.bottomMargin - pad - base;
        return [screen.x + left, screen.y + screen.height - dock.height + top, base, base].map(Math.round).join(" ");
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
    property real magnify: magnification && pointerIn && shown && Panels.open !== "context" ? 1 : 0
    Behavior on magnify { NumberAnimation { duration: Theme.anim.magnify; easing.type: Theme.anim.easing } }

    readonly property var geom: DockLayout.layout(cellWidths, {
        base: base, big: magnified, amount: magnify, focus: focusX,
        range: base * Theme.dock.magnifyRange,     // SPEC.md 7: magnification width 3 x tilesize
        spacing: Theme.dock.iconSpacing, sidePad: sidePad, dpr: dpr
    })

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

                // one hop of the launch bounce, 0..1, linear in time (the parabola is in bounceOffset)
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
                    icon: cell.modelData.icon || ""
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

                // app name label above the icon
                Rectangle {
                    visible: ma.containsMouse && !cell.modelData.separator && !cell.bouncing && Panels.open !== "context"
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
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.dockTooltip
                        color: Theme.color.label
                    }
                }

                // the whole cell column (icon and the band above it), so the label does not flicker in the
                // gap while an icon bounces or the sizes change
                MouseArea {
                    id: ma
                    x: 0; y: icon.y; width: cell.width; height: cell.height - icon.y + dock.pad
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
