import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components
import qs.services
import "../../lib/search.js" as Search
import "../../lib/appcategories.js" as Cats
import "../../lib/appsgrid.js" as AG

// The Apps panel (Dock "Apps", Go > Applications, Spotlight Cmd+1), macOS 27.2.1: not a window but Spotlight's
// Applications mode, an 844 x 520 glass panel under the search capsule (MAC-ANSWERS.md Q-dock-23..26). Geometry:
// lib/appsgrid.js. Browsing: category chips, a row of 7 suggested apps, a 1 pt separator, then every app A-Z in
// 7 columns. A chip filters to its category (the host shows it as a token in the field, the chips and suggestions
// go away); typing filters the same grid in place and puts the first hit on a grey plate. Arrow keys move an
// accent ring; hovering changes nothing. Only the visible rows and one more are instantiated (GridView,
// cacheBuffer one row). The host (Spotlight.qml) owns the query, the category and the keys: move(dx, dy), accept().
Item {
    id: panel

    property string query: ""
    property string category: ""
    signal pickCategory(string name)
    signal done()

    readonly property var m: AG.metrics()
    readonly property bool browsing: query.trim() === "" && category === ""
    readonly property var chips: Cats.present(Apps.visibleEntries)
    readonly property var suggested: browsing ? AG.suggestions([Apps.recent, Apps.pinnedItems, Apps.runningUnpinned].map(l => l.filter(it => it.entry)), m.columns) : []
    readonly property var apps: {
        const q = query.trim();
        if (q) return Search.rank(Apps.visibleEntries, q, 200);
        if (category) return Apps.sortedEntries.filter(e => Cats.groupOf(e.categories) === category);
        return Apps.sortedEntries;
    }
    // keyboard order: the suggestions row, then the grid
    readonly property int count: suggested.length + apps.length
    property int selected: -1
    property bool keyboard: false            // the ring shows only after an arrow key
    onQueryChanged: { selected = query.trim() ? 0 : -1; keyboard = false; grid.positionViewAtBeginning(); }
    onCategoryChanged: { selected = -1; keyboard = false; grid.positionViewAtBeginning(); }

    function itemAt(i) { return i < suggested.length ? suggested[i] : apps[i - suggested.length]; }
    function move(dx, dy) {
        selected = AG.move(selected, dx, dy, count);
        keyboard = true;
        if (selected >= suggested.length) grid.positionViewAtIndex(selected - suggested.length, GridView.Contain);
        else grid.positionViewAtBeginning();
    }
    function accept() {
        const e = itemAt(selected >= 0 ? selected : 0);
        if (!e || (selected < 0 && browsing)) return;
        Apps.launch(e, e.id);
        done();
    }

    width: m.width
    height: m.height

    component AppCell: Item {
        id: cell
        required property var entry
        required property int flatIndex
        readonly property bool sel: flatIndex === panel.selected
        width: panel.m.pitch
        height: panel.m.rowPitch
        // first search hit: grey 68 pt plate; keyboard: accent ring 69 pt, about 3.5 thick
        Rectangle {
            visible: cell.sel && !panel.keyboard
            anchors.horizontalCenter: icon.horizontalCenter
            anchors.verticalCenter: icon.verticalCenter
            width: panel.m.plate
            height: width
            radius: width * 0.225
            color: Theme.spotlight.plate
        }
        Rectangle {
            visible: cell.sel && panel.keyboard
            anchors.horizontalCenter: icon.horizontalCenter
            anchors.verticalCenter: icon.verticalCenter
            width: panel.m.ring
            height: width
            radius: width * 0.225
            color: "transparent"
            border.width: panel.m.ringWidth
            border.color: Theme.color.accent
        }
        // the 60 is the icon art (Safari 60 wide on the Mac); the tile around it is larger by Theme.appIcon.body
        Item {
            id: icon
            x: (parent.width - width) / 2
            width: panel.m.icon
            height: width
        }
        AppIcon {
            anchors.centerIn: icon
            width: panel.m.icon / Theme.appIcon.body
            height: width
            size: width
            icon: cell.entry.icon || ""
            appId: cell.entry.id
        }
        // SF 13 regular white, cap top 11.5 below the icon (cap height 0.705 em)
        Text {
            x: (parent.width - width) / 2
            width: panel.m.labelWidth
            anchors.baseline: parent.top
            anchors.baselineOffset: panel.m.icon + panel.m.labelCapTop + panel.m.labelSize * 0.705
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: cell.entry.name
            font: Typography.font(panel.m.labelSize)
            color: Theme.spotlight.text
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { panel.selected = cell.flatIndex; panel.accept(); }
        }
    }

    GridView {
        id: grid
        x: AG.cellX(0)
        width: panel.m.columns * panel.m.pitch
        height: parent.height
        clip: true
        cellWidth: panel.m.pitch
        cellHeight: panel.m.rowPitch
        cacheBuffer: panel.m.rowPitch
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: grid }
        model: panel.apps
        header: Item {
            width: grid.width
            height: AG.gridTop(panel.browsing)
            // chips: y 20, 26 tall, from x 20, gap 8; fill +9 over the panel, grey SF 15 text
            ListView {
                id: chipStrip
                visible: panel.browsing
                x: panel.m.inset - grid.x
                y: panel.m.chipsTop
                width: panel.m.width - 2 * panel.m.inset
                height: panel.m.chipHeight
                orientation: ListView.Horizontal
                spacing: panel.m.chipGap
                clip: true
                boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                RubberBand { flickable: chipStrip }
                model: panel.browsing ? panel.chips : []
                delegate: Item {
                    id: chip
                    required property string modelData
                    width: chipText.implicitWidth + 2 * Theme.spotlight.chipPad
                    height: panel.m.chipHeight
                    ShaderEffect {
                        anchors.fill: parent
                        property vector4d fill: Qt.vector4d(Theme.spotlight.chipLift, Theme.spotlight.chipLift, Theme.spotlight.chipLift, 0)
                        property size sizePt: Qt.size(width, height)
                        property real radius: height / 2
                        property real dpr: (QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
                        property real pad: 0   // the shader's optional uniform (no Qt warning)
                        fragmentShader: Qt.resolvedUrl("../../shaders/plusfill.frag.qsb")
                    }
                    Text {
                        id: chipText
                        anchors.centerIn: parent
                        text: chip.modelData
                        font: Typography.font(Theme.spotlight.chipSize)
                        color: Theme.spotlight.chipText
                    }
                    MouseArea { anchors.fill: parent; onClicked: panel.pickCategory(chip.modelData) }
                }
            }
            Repeater {
                model: panel.suggested
                AppCell {
                    required property var modelData
                    required property int index
                    entry: modelData
                    flatIndex: index
                    x: index * panel.m.pitch
                    y: panel.m.suggestTop
                }
            }
            // 1 pt separator at y 168, x 20..824, plus-lighter +35
            // exact at a fractional scale: one device pixel of `pad` on every side there (as ModeView's separator)
            ShaderEffect {
                visible: panel.browsing
                readonly property real lineW: panel.m.width - 2 * panel.m.inset
                property real dpr: (QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
                property real pad: Pixel.soft(dpr) ? 1 / dpr : 0
                x: panel.m.inset - grid.x - pad
                y: panel.m.separatorY - pad
                width: lineW + 2 * pad
                height: Pixel.stroke(1, dpr) + 2 * pad
                property vector4d fill: Qt.vector4d(Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, 0)
                property size sizePt: Qt.size(lineW, Pixel.stroke(1, dpr))
                property real radius: 0
                fragmentShader: Qt.resolvedUrl("../../shaders/plusfill.frag.qsb")
            }
        }
        delegate: AppCell {
            required property var modelData
            required property int index
            entry: modelData
            flatIndex: panel.suggested.length + index
        }
    }

    Text {
        anchors.centerIn: parent
        visible: panel.apps.length === 0
        text: "No Results"
        font: Typography.font(Theme.spotlight.rowTitle)
        color: Theme.spotlight.secondary
    }
}
