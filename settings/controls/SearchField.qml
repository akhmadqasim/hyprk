import QtQuick
import ".."

Rectangle {
    id: sf
    property alias text: input.text
    implicitHeight: Theme.sidebar.searchHeight
    radius: Theme.sidebar.searchRadius
    color: Theme.sidebar.searchFill
    border.color: input.activeFocus ? Qt.alpha(Theme.accent, 0.6) : Theme.sidebar.searchStroke
    border.width: input.activeFocus ? 2 : 1
    Text {
        id: mag
        x: 9; anchors.verticalCenter: parent.verticalCenter
        text: "search"; font.family: Theme.fontGlyph; font.pixelSize: 16
        color: Theme.secondaryLabel
    }
    TextInput {
        id: input
        anchors.left: mag.right; anchors.leftMargin: 4
        anchors.right: parent.right; anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontText; font.pixelSize: Theme.font.body
        color: Theme.label
        selectionColor: Qt.alpha(Theme.accent, 0.35)
        clip: true
        Text {
            visible: !input.text && !input.preeditText
            text: "Search"
            font: input.font
            color: Theme.secondaryLabel
        }
    }
}
