import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.services

// Floating glass Dock: magnification, running dots, separator + Trash,
// launch on click with bounce, app name tooltip, press lift on icons.
// Hidden while a window is full screen on this output, and with "Automatically hide and show the
// Dock" (state/dock.json) until the pointer rests on the bottom edge for the autohide delay.
// Liquid Glass: it slides down while dematerializing and comes back materializing (also when the
// shell starts). Reduce motion: a dissolve in place.
ShellWindow {
    id: dock

    required property var modelData
    screen: modelData

    // tile from the screen width (see Theme.dock.tileFraction)
    readonly property int base: Math.round((screen ? screen.width : 1440) * Theme.dock.tileFraction)
    readonly property int magnified: Math.round(base * Theme.dock.magnifyRatio)
    readonly property int pad: Theme.dock.padding
    readonly property int sidePad: Theme.dock.sidePadding
    readonly property int bgHeight: base + pad * 2
    readonly property int tooltipRoom: Theme.dock.tooltipHeight + Theme.dock.tooltipGap + 8

    anchors { bottom: true; left: true; right: true }
    implicitHeight: dock.magnified + pad + Theme.dock.bottomMargin + tooltipRoom
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
    // separator cell width; Row spacing on both sides is part of the visual gap
    readonly property real sepCell: Theme.dock.separatorHPad * 2 + Theme.dock.separatorWidth - Theme.dock.iconSpacing * 2
    // unmagnified width, used for hover math so magnification does not feed back into itself
    readonly property real baseWidth: (items.length - 1) * base + sepCell + (items.length - 1) * Theme.dock.iconSpacing + sidePad * 2
    property real mouseX: -1
    readonly property bool hovering: mouseX >= 0
    // last cursor x over the Dock: icons shrink back around it after the cursor leaves
    property real focusX: 0
    onMouseXChanged: if (mouseX >= 0) focusX = mouseX

    // Like macOS: icon sizes follow the cursor directly every frame; only entering and
    // leaving the Dock ramp the magnification in and out. (A Behavior on each icon's
    // size chased the cursor and lagged behind it, so icons overlapped and jittered.)
    property real magnify: hovering && Panels.open !== "context" ? 1 : 0
    Behavior on magnify { NumberAnimation { duration: Theme.anim.magnify; easing.type: Theme.anim.easing } }

    function sizeFor(baseCenter) {
        if (magnify <= 0) return base;
        const d = Math.abs(focusX - baseCenter) / (base * Theme.dock.magnifyRange);
        if (d >= 1) return base;
        return base + (dock.magnified - base) * magnify * (Math.cos(d * Math.PI) + 1) / 2;
    }

    // hit area: background, plus the magnified band while hovering; hidden by autohide only
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
        // convert window x to the unmagnified dock coordinate space
        onPointChanged: dock.mouseX = hovered ? point.position.x - (dock.width - dock.baseWidth) / 2 : -1
        onHoveredChanged: {
            dock.pointerIn = hovered;
            if (!hovered) dock.mouseX = -1;
        }
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

        Glass {
            id: bg
            width: row.width + dock.sidePad * 2
            height: dock.bgHeight
            x: (dock.width - width) / 2
            y: dock.height - height - Theme.dock.bottomMargin
            radius: Theme.dock.radius
            sx: x
            sy: dock.screen.height - dock.height + y
            tint: Theme.glass.tintClear
            solidColor: Theme.glass.solidDock
            pluginLift: Theme.dock.pluginLift
            materialize: mat.progress
        }

        Row {
            id: row
            anchors.bottom: bg.bottom
            anchors.bottomMargin: dock.pad
            x: bg.x + dock.sidePad
            spacing: Theme.dock.iconSpacing
            opacity: mat.progress

            Repeater {
                model: dock.items
                delegate: Item {
                    id: cell
                    required property var modelData
                    required property int index

                    // center of this cell in the unmagnified layout
                    readonly property real baseCenter: dock.sidePad + index * (dock.base + Theme.dock.iconSpacing) + dock.base / 2
                                                       + (index > dock.sepIndex ? dock.sepCell - dock.base : 0)
                    readonly property real size: modelData.separator ? dock.base : dock.sizeFor(baseCenter)
                    readonly property bool running: (modelData.windows || []).length > 0
                    readonly property bool bouncing: Apps.isLaunching(modelData.id) && !running

                    width: modelData.separator ? dock.sepCell : size
                    height: dock.base            // constant; the icon grows upward out of the cell

                    // separator
                    Rectangle {
                        visible: cell.modelData.separator === true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.dock.separatorInset - dock.pad
                        width: Theme.dock.separatorWidth
                        height: dock.base - (Theme.dock.separatorInset - dock.pad) * 2
                        color: Theme.dock.separator
                    }

                    // interactive press: the icon lifts (FlexInteraction ultraSmall) and darkens
                    PressSpring { id: press; pressed: ma.containsPress; w: icon.width; h: icon.height; settlesGlass: false }
                    AppIcon {
                        id: icon
                        transform: Scale { origin.x: icon.width / 2; origin.y: icon.height / 2; xScale: press.scale; yScale: press.scale }
                        visible: !cell.modelData.separator
                        size: cell.size
                        loadSize: dock.magnified     // load once at full size, then only scale
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - bounceY
                        property real bounceY: 0
                        icon: cell.modelData.icon || ""
                        appId: cell.modelData.id

                        SequentialAnimation on bounceY {
                            running: cell.bouncing
                            loops: Animation.Infinite
                            alwaysRunToEnd: true
                            NumberAnimation { to: Theme.dock.bounceHeight; duration: Theme.anim.bounce / 2; easing.type: Easing.OutQuad }
                            NumberAnimation { to: 0; duration: Theme.anim.bounce / 2; easing.type: Easing.InQuad }
                        }
                    }
                    Rectangle {
                        x: icon.x; y: icon.y; width: icon.width; height: icon.height
                        transform: Scale { origin.x: icon.width / 2; origin.y: icon.height / 2; xScale: press.scale; yScale: press.scale }
                        visible: ma.containsPress && !cell.modelData.separator
                        color: Qt.rgba(0, 0, 0, 0.25)
                        radius: width * 0.22
                    }

                    // running indicator
                    Rectangle {
                        visible: cell.running
                        width: Theme.dock.dotSize
                        height: width
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height + Theme.dock.dotOffset
                        color: Theme.color.dockDot
                    }

                    // tooltip
                    Rectangle {
                        visible: ma.containsMouse && !cell.modelData.separator && !cell.bouncing && Panels.open !== "context"
                        anchors.horizontalCenter: parent.horizontalCenter
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

                    MouseArea {
                        id: ma
                        x: icon.x; y: icon.y; width: icon.width; height: icon.height
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
}
