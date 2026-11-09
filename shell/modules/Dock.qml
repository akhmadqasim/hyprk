import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Floating glass Dock: magnification, running dots, separator + Trash,
// launch on click with bounce, app name tooltip.
ShellWindow {
    id: dock

    required property var modelData
    screen: modelData

    // SPEC.md: tile 64 pt, 52 on displays up to 800 pt tall
    readonly property int base: screen && screen.height <= 800 ? Theme.dock.iconSizeShort : Theme.dock.iconSize
    readonly property int pad: Theme.dock.padding
    readonly property int sidePad: Theme.dock.sidePadding
    readonly property int bgHeight: base + pad * 2
    readonly property int tooltipRoom: Theme.dock.tooltipHeight + Theme.dock.tooltipGap + 8

    anchors { bottom: true; left: true; right: true }
    implicitHeight: Theme.dock.magnifiedSize + pad + Theme.dock.bottomMargin + tooltipRoom
    exclusiveZone: bgHeight + Theme.dock.bottomMargin
    namespace: "hyprk-dock"
    WlrLayershell.layer: WlrLayer.Top
    mask: Region { item: hit }

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

    function sizeFor(baseCenter) {
        if (!hovering || Panels.open === "context") return base;
        const d = Math.abs(mouseX - baseCenter) / (base * Theme.dock.magnifyRange);
        if (d >= 1) return base;
        return base + (Theme.dock.magnifiedSize - base) * (Math.cos(d * Math.PI) + 1) / 2;
    }

    // hit area: background, plus the magnified band while hovering
    Item {
        id: hit
        x: bg.x
        width: bg.width
        y: dock.hovering ? bg.y - (Theme.dock.magnifiedSize - dock.base) : bg.y
        height: dock.height - y
    }

    // on the window's root item so it sees hover above child MouseAreas
    HoverHandler {
        // convert window x to the unmagnified dock coordinate space
        onPointChanged: dock.mouseX = hovered ? point.position.x - (dock.width - dock.baseWidth) / 2 : -1
        onHoveredChanged: if (!hovered) dock.mouseX = -1
    }

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
    }

    Row {
        id: row
        anchors.bottom: bg.bottom
        anchors.bottomMargin: dock.pad
        x: bg.x + dock.sidePad
        spacing: Theme.dock.iconSpacing

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
                Behavior on width { enabled: !cell.modelData.separator; NumberAnimation { duration: Theme.anim.magnify } }

                // separator
                Rectangle {
                    visible: cell.modelData.separator === true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.dock.separatorInset - dock.pad
                    width: Theme.dock.separatorWidth
                    height: dock.base - (Theme.dock.separatorInset - dock.pad) * 2
                    color: Theme.color.separator
                }

                AppIcon {
                    id: icon
                    visible: !cell.modelData.separator
                    size: cell.size
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
                    visible: ma.pressed && !cell.modelData.separator
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
