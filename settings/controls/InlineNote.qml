import QtQuick
import ".."

// Calm one-line explanation shown instead of raw errors.
Row {
    id: n
    property string text
    property string glyph: "info"
    spacing: 6
    visible: text !== ""
    Text {
        text: n.glyph; font.family: Theme.fontGlyph; font.pixelSize: 14
        color: Theme.secondaryLabel
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        width: Math.min(implicitWidth, (n.parent ? n.parent.width : 400) - 24)
        wrapMode: Text.WordWrap
        text: n.text
        font.family: Theme.fontText; font.pixelSize: Theme.font.small
        color: Theme.secondaryLabel
        anchors.verticalCenter: parent.verticalCenter
    }
}
