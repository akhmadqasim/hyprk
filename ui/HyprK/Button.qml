import QtQuick

// Capsule push button (macOS 26 style).
Rectangle {
    id: b
    property string text
    property bool primary: false
    signal clicked()
    implicitHeight: Tokens.control.buttonHeight
    implicitWidth: Math.max(64, label.implicitWidth + 24)
    radius: Tokens.control.buttonRadius
    // highlight on mouse-down, cleared while the pointer is dragged outside (AppKit tracking);
    // the action fires on release inside, like NSButton
    readonly property bool down: ma.pressed && ma.containsMouse
    color: primary ? (down ? Qt.darker(Tokens.accent, 1.15) : Tokens.accent)
                   : (down ? Tokens.control.fillPressed : Tokens.control.fill)
    opacity: enabled ? 1 : Tokens.control.disabledOpacity
    Text {
        id: label
        anchors.centerIn: parent
        text: b.text
        font.family: Tokens.fontText; font.pixelSize: Tokens.control.fontSize
        color: b.primary ? "white" : Tokens.label
    }
    MouseArea { id: ma; anchors.fill: parent; onClicked: b.clicked() }
}
