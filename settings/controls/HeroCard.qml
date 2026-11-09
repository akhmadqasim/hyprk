import QtQuick
import ".."

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
            font.family: Theme.fontDisplay; font.pixelSize: Theme.font.title + 2; weight: Font.Bold
            color: Theme.label
        }
        Text {
            visible: h.text !== ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: h.text
            font.family: Theme.fontText; font.pixelSize: Theme.font.small
            color: Theme.secondaryLabel
        }
    }
}
