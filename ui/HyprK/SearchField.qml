import QtQuick

// System Settings sidebar search field (MAC-ANSWERS.md Q-settings-10): a flat translucent 28 pt capsule, not glass,
// with a 0.5 pt dark rim (pixels of desktop-dock-{light,dark}.png). Magnifier at the left in a 25 pt button,
// placeholder "Search" 13 pt secondary. Focus: the 3 pt focus ring outside the capsule.
Rectangle {
    id: sf
    property alias text: input.text
    readonly property bool inputFocus: input.activeFocus
    implicitHeight: Tokens.control.searchHeight
    radius: Tokens.control.searchRadius
    color: Tokens.control.searchFill
    border.color: Tokens.control.searchStroke
    border.width: 0.5
    FocusRing { visible: input.activeFocus }
    Text {
        id: mag
        x: 15 - width / 2; anchors.verticalCenter: parent.verticalCenter
        text: "search"; font.family: Tokens.fontGlyph; font.pixelSize: 16
        color: Tokens.secondaryLabel
    }
    TextInput {
        id: input
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
        anchors.left: parent.left; anchors.leftMargin: 28.5
        anchors.right: parent.right; anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font: Typography.control
        color: Tokens.label
        selectionColor: Accent.selectedText   // selectedTextBackgroundColor
        selectedTextColor: Tokens.label
        clip: true
        Text {
            visible: !input.text && !input.preeditText
            text: "Search"
            font: input.font
            color: Tokens.secondaryLabel
        }
    }
}
