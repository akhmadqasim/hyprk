import QtQuick

Rectangle {
    id: sf
    property alias text: input.text
    implicitHeight: Tokens.control.searchHeight
    radius: Tokens.control.searchRadius
    color: Tokens.control.searchFill
    border.color: input.activeFocus ? Qt.alpha(Tokens.accent, 0.6) : Tokens.control.searchStroke
    border.width: input.activeFocus ? 2 : 1
    Text {
        id: mag
        x: 9; anchors.verticalCenter: parent.verticalCenter
        text: "search"; font.family: Tokens.fontGlyph; font.pixelSize: 16
        color: Tokens.secondaryLabel
    }
    TextInput {
        id: input
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
        anchors.left: mag.right; anchors.leftMargin: 4
        anchors.right: parent.right; anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font.family: Tokens.fontText; font.pixelSize: Tokens.control.fontSize
        color: Tokens.label
        selectionColor: Qt.alpha(Tokens.accent, 0.35)
        clip: true
        Text {
            visible: !input.text && !input.preeditText
            text: "Search"
            font: input.font
            color: Tokens.secondaryLabel
        }
    }
}
