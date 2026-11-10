import QtQuick
import ".."
import "../HyprK"

// Pane header card: big tile, title, description (General, Appearance, etc.).
Rectangle {
    id: h
    property string glyph
    property string iconId
    property color tint: Theme.tile.blue
    property string title
    property string text
    width: parent ? parent.width : 0
    height: Math.max(110, col.implicitHeight + 36)
    radius: Theme.content.cardRadius
    color: Theme.cardFill
    border.color: Theme.cardStroke
    Column {
        id: col
        anchors.centerIn: parent
        width: parent.width - 60
        spacing: 6
        PaneIcon { anchors.horizontalCenter: parent.horizontalCenter; size: Theme.content.heroIcon; glyph: h.glyph; iconId: h.iconId; tint: h.tint }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: h.title
            size: 18; weight: Typography.bold   // TODO verify (not measured)
            color: Theme.label
        }
        Text {
            visible: h.text !== ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: h.text
            font: Typography.subheadline
            color: Theme.secondaryLabel
        }
    }
}
