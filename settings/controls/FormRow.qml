import QtQuick
import ".."
import "../HyprK"

// One row inside a Card: optional icon, label (+ sublabel), trailing control.
Item {
    id: row
    property string label
    property string sublabel
    property string iconId           // tile: a pane icon or a row icon (Panes.js), themes/icons/settings
    property string iconSource       // app icon image instead of the tile
    property string symbol           // or a bare SF Symbol (HyprK sfpaths.js) in symbolColor, no tile
    property color symbolColor: Theme.label
    property color tint: Theme.tile.blue
    property real iconSize: 20       // the Mac's row tile: 40 px at 2x (accessibility-light.png)
    property bool dim: false
    property string value            // gray trailing text, e.g. "Off"
    property bool alignTop: false    // tall rows (pickers) keep the label at the top, like macOS
    signal clicked()
    default property alias trailing: trail.data
    width: parent ? parent.width : 0
    // a row whose only control is a Switch is 37.5, others 38 (Q-settings-12)
    readonly property bool _switchRow: trail.children.length === 1 && trail.children[0]._lift !== undefined
                                       && trail.children[0].value === undefined
    implicitHeight: Math.max(_switchRow ? Theme.content.switchRowHeight : Theme.content.rowHeight,
                             texts.implicitHeight + 16, trail.childrenRect.height + 12)
    height: implicitHeight

    Rectangle { // separator between rows: inset 10 on both sides, under the icon too (accessibility-light.png, Q-settings-12)
        visible: row.Positioner.index > 0
        x: Theme.content.separatorInset
        width: parent.width - x - Theme.content.separatorInset
        height: 1
        color: Theme.separator
    }
    PaneIcon {
        id: icon
        visible: row.iconId !== "" || row.iconSource !== "" || row.symbol !== ""
        size: row.iconSize; iconId: row.iconId; tint: row.tint; imageSource: row.iconSource
        opacity: row.symbol !== "" ? 0 : 1
        x: Theme.content.rowPadding; anchors.verticalCenter: parent.verticalCenter
    }
    SfSymbol {   // size not measured on the Mac (no shot of a row with a bare symbol): the body size
        visible: row.symbol !== ""
        anchors.centerIn: icon
        name: row.symbol; pointSize: 13; color: row.symbolColor
    }
    Column {
        id: texts
        y: row.alignTop ? 11 : (row.height - implicitHeight) / 2
        x: Theme.content.rowPadding + (icon.visible ? icon.width + 10 : 0)
        width: trail.x - x - 10
        spacing: 1
        Text {
            width: parent.width; elide: Text.ElideRight
            text: row.label
            font: Typography.body
            color: row.dim ? Theme.secondaryLabel : Theme.label
        }
        Text {
            visible: row.sublabel !== ""
            width: parent.width; wrapMode: Text.WordWrap
            text: row.sublabel
            font: Typography.subheadline
            color: Theme.secondaryLabel
        }
    }
    MouseArea { anchors.fill: parent; onClicked: row.clicked() }
    Row {
        id: trail
        anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding
        y: row.alignTop ? 11 : (row.height - height) / 2
        spacing: 8
        Text {
            visible: row.value !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: row.value
            font: Typography.body
            color: Theme.secondaryLabel
        }
    }
}
