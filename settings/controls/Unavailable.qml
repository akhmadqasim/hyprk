import QtQuick
import ".."
import "../HyprK"

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
            size: 16; weight: Typography.semibold   // TODO verify (not measured)
            color: Theme.secondaryLabel
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: u.text
            font: Typography.subheadline
            color: Theme.secondaryLabel
        }
    }
}
