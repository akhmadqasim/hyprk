import QtQuick
import ".."
import "../HyprK"

// One row inside a Card: optional icon, label (+ sublabel), trailing control.
Item {
    id: row
    property string label
    property string sublabel
    property string glyph            // Material Icons ligature for a small tile
    property string iconSource       // app icon image instead of the glyph tile
    property color tint: Theme.tile.blue
    property real iconSize: 22
    property bool dim: false
    property string value            // gray trailing text, e.g. "Off"
    property bool alignTop: false    // tall rows (pickers) keep the label at the top, like macOS
    signal clicked()
    default property alias trailing: trail.data
    width: parent ? parent.width : 0
    implicitHeight: Math.max(Theme.content.rowHeight, texts.implicitHeight + 16, trail.childrenRect.height + 12)
    height: implicitHeight

    Rectangle { // separator between rows, inset like macOS
        visible: row.Positioner.index > 0
        x: Theme.content.separatorInset + (icon.visible ? icon.width + 10 : 0)
        width: parent.width - x - Theme.content.separatorInset
        height: 1
        color: Theme.separator
    }
    PaneIcon {
        id: icon
        visible: row.glyph !== "" || row.iconSource !== ""
        size: row.iconSize; glyph: row.glyph; tint: row.tint; imageSource: row.iconSource
        x: Theme.content.rowPadding; anchors.verticalCenter: parent.verticalCenter
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
