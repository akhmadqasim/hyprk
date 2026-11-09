import QtQuick
import ".."

// Full-pane empty state, e.g. "Bluetooth Unavailable" when no controller exists.
Item {
    id: u
    property string glyph
    property string title
    property string text
    width: parent ? parent.width : 0
    height: 300
    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 360)
        spacing: 8
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: u.glyph; font.family: Theme.fontGlyph; font.pixelSize: 54
            color: Theme.tertiaryLabel
        }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: u.title
            font.family: Theme.fontDisplay; font.pixelSize: Theme.font.title; weight: Font.DemiBold
            color: Theme.secondaryLabel
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: u.text
            font.family: Theme.fontText; font.pixelSize: Theme.font.small
            color: Theme.secondaryLabel
        }
    }
}
