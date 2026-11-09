import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components
import qs.services

// Mission Control (Super+Up): Spaces bar on top, live thumbnails of the
// windows on the current Space laid out in a grid over the dimmed desktop.
// Click a window to focus it, a Space to switch, empty space or Esc to close.
ShellWindow {
    id: mc

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "mission"
    visible: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-mission"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property var windows: shown ? Hyprland.toplevels.values.filter(t => t.workspace && t.workspace === Hyprland.focusedWorkspace) : []
    readonly property var spaces: !shown ? [] : Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id)

    function opened() { if (shown) { Hyprland.refreshToplevels(); keys.forceActiveFocus(); } }
    onShownChanged: opened()
    Component.onCompleted: opened()   // built on demand (shell.qml LazyLoader)

    // grid geometry: as square as possible, cells share the area below the Spaces bar
    readonly property int cols: Math.max(1, Math.ceil(Math.sqrt(windows.length)))
    readonly property int rows: Math.max(1, Math.ceil(windows.length / cols))
    readonly property real gridTop: Theme.mission.spacesHeight + Theme.mission.margin / 2
    readonly property real cellW: (width - Theme.mission.margin * 2 - Theme.mission.gap * (cols - 1)) / cols
    readonly property real cellH: (height - gridTop - Theme.mission.margin * 1.5 - Theme.mission.gap * (rows - 1)) / rows

    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // backdrop: blurred wallpaper, dimmed
    Image {
        anchors.fill: parent
        readonly property string path: Wallpaper.blurred || Wallpaper.wallpaper
        source: path ? "file://" + path : ""
        asynchronous: true
    }
    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, Theme.mission.dim) }
    MouseArea { anchors.fill: parent; onClicked: Panels.close() }

    // Spaces bar: a wallpaper thumbnail per Space with its name under it,
    // the current one outlined (macOS shows these when the bar is expanded)
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.mission.spacesTop
        spacing: Theme.mission.spaceSpacing
        Repeater {
            model: mc.spaces
            delegate: Column {
                id: sp
                required property var modelData
                readonly property bool current: modelData === Hyprland.focusedWorkspace
                spacing: Theme.mission.spaceLabelGap

                ClippingRectangle {
                    width: Theme.mission.spaceThumbWidth
                    height: width * mc.height / Math.max(1, mc.width)
                    radius: Theme.mission.spaceRadius
                    color: Theme.glass.solid
                    border.width: sp.current ? Theme.mission.hoverBorder : 0
                    border.color: Theme.mission.text
                    scale: spm.containsMouse ? Theme.mission.hoverScale : 1
                    Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                    Image {
                        anchors.fill: parent
                        source: Wallpaper.url
                        sourceSize.width: Wallpaper.thumbWidth
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                    MouseArea {
                        id: spm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sp.modelData.activate()
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Desktop " + sp.modelData.id
                    font.family: Theme.fontText
                    font.pixelSize: Theme.mission.labelSize
                    font.weight: sp.current ? Font.DemiBold : Font.Normal
                    color: Theme.mission.text
                }
            }
        }
    }

    // windows
    Repeater {
        model: mc.windows
        delegate: Item {
            id: cell
            required property var modelData
            required property int index
            // a short last row is centered
            readonly property int row: Math.floor(index / mc.cols)
            readonly property int inRow: Math.min(mc.cols, mc.windows.length - row * mc.cols)
            x: Theme.mission.margin + (mc.cols - inRow) * (mc.cellW + Theme.mission.gap) / 2
               + (index % mc.cols) * (mc.cellW + Theme.mission.gap)
            y: mc.gridTop + row * (mc.cellH + Theme.mission.gap)
            width: mc.cellW
            height: mc.cellH

            ClippingRectangle {
                id: thumb
                anchors.centerIn: parent
                width: view.width
                height: view.height
                radius: Theme.mission.thumbRadius
                color: "transparent"
                scale: wma.containsMouse ? Theme.mission.hoverScale : 1
                Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                ScreencopyView {
                    id: view
                    captureSource: cell.modelData.wayland
                    live: mc.shown
                    // fit the cell but never grow past Theme.mission.maxScale of the real window
                    readonly property real dpr: mc.screen ? mc.screen.devicePixelRatio : 1
                    readonly property real maxW: cell.width
                    readonly property real maxH: cell.height - Theme.mission.titleReserve
                    constraintSize: Qt.size(Math.min(maxW, sourceSize.width / dpr * Theme.mission.maxScale || maxW),
                                            Math.min(maxH, sourceSize.height / dpr * Theme.mission.maxScale || maxH))
                }
                // fallback while no frame is available: app icon on a plain card
                Rectangle {
                    anchors.fill: parent
                    visible: !view.hasContent
                    color: Theme.glass.solid
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: Theme.mission.placeholderIcon
                        source: Apps.iconUrl(Apps.appIdOf(cell.modelData), Apps.appIdOf(cell.modelData))
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: wma.containsMouse ? Theme.mission.hoverBorder : 0
                    border.color: Theme.color.accent
                }
            }
            // title under the hovered window, styled like the Dock tooltip
            Rectangle {
                visible: wma.containsMouse
                anchors.horizontalCenter: parent.horizontalCenter
                y: thumb.y + thumb.height + Theme.dock.tooltipGap
                width: Math.min(cell.width, title.implicitWidth + Theme.dock.tooltipHPad * 2)
                height: Theme.dock.tooltipHeight
                radius: Theme.dock.tooltipRadius
                color: Theme.color.tooltipBg
                border.width: 1
                border.color: Theme.glass.hairline
                Text {
                    id: title
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, cell.width - Theme.dock.tooltipHPad * 2)
                    elide: Text.ElideRight
                    text: cell.modelData.title
                    font.family: Theme.fontText
                    font.pixelSize: Theme.font.dockTooltip
                    color: Theme.color.label
                }
            }
            MouseArea {
                id: wma
                x: thumb.x; y: thumb.y; width: thumb.width; height: thumb.height
                hoverEnabled: true
                onClicked: { Panels.close(); Apps.focusWindow(cell.modelData); }
            }
        }
    }
}
