import QtQuick
import "keybindings.js" as KeyBindings

// System Settings sidebar search field (MAC-ANSWERS.md Q-settings-10): a flat translucent 28 pt capsule, not glass,
// with a 0.5 pt dark rim (pixels of desktop-dock-{light,dark}.png). Magnifier (magnifyingglass, 13 pt) at the left,
// placeholder "Search" 13 pt secondary. Focus: the 3 pt focus ring outside the capsule.
Rectangle {
    id: sf
    property alias text: input.text
    readonly property bool inputFocus: input.activeFocus
    // View > Search ⌘F (System Settings' menu): the field takes the keyboard
    function focusField() { input.forceActiveFocus(); input.selectAll(); }
    implicitHeight: Tokens.control.searchHeight
    radius: Tokens.control.searchRadius
    color: Tokens.control.searchFill
    border.color: Tokens.control.searchStroke
    border.width: 0.5
    FocusRing { visible: input.activeFocus }
    SfSymbol {   // regular, 13 pt: alpha rms 0.015 light / 0.012 dark on appearance-{light,dark}.png, ink centre 16.25 pt in
        id: mag
        x: 16.25 - width / 2; y: (parent.height - height) / 2 + 0.2
        name: "magnifyingglass"; pointSize: 13
        color: Tokens.secondaryLabel
    }
    TextInput {
        id: input
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
        TextMenu { target: input }   // the field editor's right-click menu (textmenu.js)
        anchors.left: parent.left; anchors.leftMargin: 28.5
        anchors.right: parent.right; anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        font: Typography.control
        color: Tokens.label
        selectionColor: Accent.selectedText   // selectedTextBackgroundColor
        selectedTextColor: Tokens.label
        clip: true
        Keys.onPressed: e => KeyBindings.handle(e, input)   // AppKit's text keys (keybindings.js)
        Text {
            visible: !input.text && !input.preeditText
            text: "Search"
            font: input.font
            color: Tokens.secondaryLabel
        }
    }
}
