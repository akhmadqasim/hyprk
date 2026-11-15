import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/spotlight.js" as SL
import "../../lib/appsgrid.js" as AG

// Spotlight's Files mode (Cmd+2), macOS 27.2.1: the Apps panel's 844 x 520 grid (MAC-ANSWERS-17.md R17.3, r17
// spotlight-mode-files-*.png; MAC-ANSWERS.md Q-panels-25). Geometry: lib/spotlight.js filesGrid() and the Apps
// columns (lib/appsgrid.js). Browsing: five equal filter chips, a first row of seven files, the header "Recents", then
// the recent files in 7 columns with two-line names; the grid scrolls under the chips, with a grey knob at the right.
// A chip (the host shows it as a token in the field) or a query drops the chips, the first row and the header.
// Not in the Mac's captures (its tiles are blurred): which files the first row holds (here the seven newest, the
// grid goes on after them), the selection (the Apps panel's plate and ring) and how a name is cut.
// The host (Spotlight.qml) owns the query, the chip and the keys: move(dx, dy), accept(); `items` is the keyboard order.
Item {
    id: panel

    property string query: ""
    property string category: ""
    signal pickCategory(string name)
    signal done()

    readonly property var m: AG.metrics()
    readonly property var f: SL.filesGrid()
    readonly property bool browsing: query.trim() === "" && category === ""
    readonly property var chips: SL.fileChips(FileSearch.recents, f.chips)
    readonly property var all: {
        const src = query.trim() ? FileSearch.results : FileSearch.recents;
        return category ? src.filter(x => SL.fileKind(x.isDir, x.mime) === category) : src;
    }
    readonly property var head: browsing ? all.slice(0, m.columns) : []
    readonly property var rest: browsing ? all.slice(m.columns) : all
    readonly property var items: head.concat(rest)
    property int selected: -1
    property bool keyboard: false
    onQueryChanged: { selected = query.trim() ? 0 : -1; keyboard = false; grid.positionViewAtBeginning(); }
    onCategoryChanged: { selected = -1; keyboard = false; grid.positionViewAtBeginning(); }
    Component.onCompleted: FileSearch.loadRecents()

    function move(dx, dy) {
        selected = AG.move(selected, dx, dy, items.length);
        keyboard = true;
        if (selected >= head.length) grid.positionViewAtIndex(selected - head.length, GridView.Contain);
        else grid.positionViewAtBeginning();
    }
    function accept() {
        const it = items[selected >= 0 ? selected : 0];
        if (!it || (selected < 0 && browsing)) return;
        FileSearch.open(it);
        done();
    }

    width: m.width
    height: m.height

    component FileCell: Item {
        id: cell
        required property var file
        required property int flatIndex
        readonly property bool sel: flatIndex === panel.selected
        readonly property bool isImage: String(file.mime || "").startsWith("image/")
        width: panel.m.pitch
        height: panel.f.rowPitch
        Rectangle {
            visible: cell.sel && !panel.keyboard
            anchors.centerIn: icon
            width: panel.m.plate
            height: width
            radius: width * 0.225
            color: Theme.spotlight.plate
        }
        Rectangle {
            visible: cell.sel && panel.keyboard
            anchors.centerIn: icon
            width: panel.m.ring
            height: width
            radius: width * 0.225
            color: "transparent"
            border.width: panel.m.ringWidth
            border.color: Theme.color.accent
        }
        Item {
            id: icon
            x: (parent.width - width) / 2
            width: panel.m.icon
            height: width
            Image {
                anchors.fill: parent
                source: cell.isImage ? "file://" + cell.file.path : Quickshell.iconPath(SL.fileIcon(cell.file.path, cell.file.isDir, cell.file.mime), true)
                sourceSize: Qt.size(width * 2, height * 2)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
        }
        Text {
            x: (parent.width - width) / 2
            width: panel.m.labelWidth
            anchors.baseline: parent.top
            anchors.baselineOffset: panel.m.icon + panel.m.labelCapTop + panel.m.labelSize * 0.705
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: panel.f.labelLines
            elide: Text.ElideRight
            text: cell.file.name
            font: Typography.font(panel.m.labelSize)
            color: Theme.spotlight.text
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { panel.selected = cell.flatIndex; panel.accept(); }
        }
    }

    // chips: fixed over the grid (the Mac's knob starts under them)
    Row {
        id: chipRow
        visible: panel.browsing
        x: panel.f.inset
        y: panel.f.chipTop
        spacing: panel.f.chipGap
        Repeater {
            model: panel.browsing ? panel.chips : []
            Item {
                id: chip
                required property string modelData
                width: SL.filesChipWidth(panel.m.width)
                height: panel.f.chipHeight
                ShaderEffect {
                    anchors.fill: parent
                    property vector4d fill: Qt.vector4d(Theme.spotlight.fileChipLift, Theme.spotlight.fileChipLift, Theme.spotlight.fileChipLift, 0)
                    property size sizePt: Qt.size(width, height)
                    property real radius: height / 2
                    property real dpr: (QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
                    property real pad: 0
                    fragmentShader: Qt.resolvedUrl("../../shaders/plusfill.frag.qsb")
                }
                Text {
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, parent.width - 2 * Theme.spotlight.chipPad)
                    elide: Text.ElideRight
                    text: chip.modelData
                    font: Typography.font(Theme.spotlight.chipSize)
                    color: "#FFFFFF"
                    layer.enabled: visible
                    layer.effect: ShaderEffect {
                        property real lift: Theme.spotlight.hintCapTextLift
                        fragmentShader: Qt.resolvedUrl("../../shaders/plustext.frag.qsb")
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: panel.pickCategory(chip.modelData) }
            }
        }
    }

    GridView {
        id: grid
        readonly property real viewTop: panel.browsing ? panel.f.viewTop : 0
        x: AG.cellX(0)
        y: viewTop
        width: panel.m.columns * panel.m.pitch
        height: parent.height - viewTop
        clip: true
        cellWidth: panel.m.pitch
        cellHeight: panel.f.rowPitch
        cacheBuffer: panel.f.rowPitch
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: grid }
        model: panel.rest
        header: Item {
            width: grid.width
            height: (panel.browsing ? panel.f.gridTop : panel.f.plainTop) - grid.viewTop
            Repeater {
                model: panel.head
                FileCell {
                    required property var modelData
                    required property int index
                    file: modelData
                    flatIndex: index
                    x: index * panel.m.pitch
                    y: panel.f.topRow - grid.viewTop
                }
            }
            Text {
                visible: panel.browsing && panel.rest.length > 0
                x: panel.f.inset - grid.x
                anchors.verticalCenter: parent.top
                anchors.verticalCenterOffset: panel.f.headerCY - grid.viewTop
                text: "Recents"
                font: Typography.font(Theme.spotlight.headerSize, Typography.semibold)
                color: Theme.spotlight.secondary
            }
        }
        delegate: FileCell {
            required property var modelData
            required property int index
            file: modelData
            flatIndex: panel.head.length + index
        }
    }

    // the scroll knob (r17 spotlight-mode-files-*: grey 124, x 835 .. 841, from y 102 = 40.5 under the scrolling part)
    Rectangle {
        readonly property var k: SL.scrollKnob(grid.height, grid.contentHeight, grid.contentY - grid.originY, panel.f.knobInset)
        visible: k[1] > 0
        x: panel.width - panel.f.knobRight - width
        y: grid.y + k[0]
        width: panel.f.knobWidth
        height: k[1]
        radius: width / 2
        color: Theme.spotlight.scrollKnob
    }

    Text {
        anchors.centerIn: parent
        visible: panel.items.length === 0
        text: !panel.query.trim() && !panel.category ? "No Recent Files" : FileSearch.searching ? "Searching…" : "No Results"
        font: Typography.font(Theme.spotlight.rowTitle)
        color: Theme.spotlight.secondary
    }
}
