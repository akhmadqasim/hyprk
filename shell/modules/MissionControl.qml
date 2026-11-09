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
PanelWindow {
    id: mc

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "mission"
    visible: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "hyprk-mission"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property var windows: shown ? Hyprland.toplevels.values.filter(t => t.workspace && t.workspace === Hyprland.focusedWorkspace) : []
    readonly property var spaces: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id)

    onShownChanged: if (shown) { Hyprland.refreshToplevels(); keys.forceActiveFocus(); }

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
        source: Wallpaper.blurred ? "file://" + Wallpaper.blurred : (Wallpaper.wallpaper ? "file://" + Wallpaper.wallpaper : "")
        asynchronous: true
    }
    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, Theme.mission.dim) }
    MouseArea { anchors.fill: parent; onClicked: Panels.close() }

    // Spaces bar
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: (Theme.mission.spacesHeight - 24) / 2
        spacing: 12
        Repeater {
            model: mc.spaces
            delegate: Rectangle {
                id: sp
                required property var modelData
                readonly property bool current: modelData === Hyprland.focusedWorkspace
                width: label.implicitWidth + 24
                height: 24
                radius: 12
                color: current ? Qt.rgba(1, 1, 1, 0.30) : spm.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.10)
                Text {
                    id: label
                    anchors.centerIn: parent
                    text: "Desktop " + sp.modelData.id
                    font.family: Theme.fontText
                    font.pixelSize: Theme.mission.labelSize - 1
                    font.weight: sp.current ? Font.DemiBold : Font.Normal
                    color: "white"
                }
                MouseArea {
                    id: spm
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${sp.modelData.id} })`)
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
                scale: wma.containsMouse ? 1.03 : 1
                Behavior on scale { NumberAnimation { duration: Theme.anim.fast } }
                ScreencopyView {
                    id: view
                    captureSource: cell.modelData.wayland
                    live: mc.shown
                    // fit the cell but never grow past Theme.mission.maxScale of the real window
                    readonly property real dpr: mc.screen ? mc.screen.devicePixelRatio : 1
                    constraintSize: Qt.size(Math.min(cell.width, sourceSize.width / dpr * Theme.mission.maxScale || cell.width),
                                            Math.min(cell.height - 28, sourceSize.height / dpr * Theme.mission.maxScale || cell.height - 28))
                }
                // fallback while no frame is available: app icon on a plain card
                Rectangle {
                    anchors.fill: parent
                    visible: !view.hasContent
                    color: Theme.glass.solid
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 64
                        source: Apps.iconUrl(Apps.appIdOf(cell.modelData), Apps.appIdOf(cell.modelData))
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: wma.containsMouse ? 3 : 0
                    border.color: Theme.color.accent
                }
            }
            // title pill under the hovered window, like macOS
            Rectangle {
                visible: wma.containsMouse
                anchors.horizontalCenter: parent.horizontalCenter
                y: thumb.y + thumb.height + 8
                width: Math.min(cell.width, title.implicitWidth + 20)
                height: 22
                radius: 11
                color: Qt.rgba(0, 0, 0, 0.45)
                Text {
                    id: title
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, cell.width - 20)
                    elide: Text.ElideRight
                    text: cell.modelData.title
                    font.family: Theme.fontText
                    font.pixelSize: Theme.mission.labelSize - 1
                    color: "white"
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
