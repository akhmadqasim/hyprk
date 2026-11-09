import QtQuick
import ".."

// Capsule push button (macOS 26 style).
Rectangle {
    id: b
    property string text
    property bool primary: false
    property bool enabled_: true
    signal clicked()
    implicitHeight: Theme.control.buttonHeight
    implicitWidth: Math.max(64, label.implicitWidth + 24)
    radius: Theme.control.buttonRadius
    color: primary ? Theme.accent : (ma.pressed ? Theme.controlFillPressed : Theme.controlFill)
    opacity: enabled_ ? 1 : 0.4
    Text {
        id: label
        anchors.centerIn: parent
        text: b.text
        font.family: Theme.fontText; font.pixelSize: Theme.font.body
        color: b.primary ? "white" : Theme.label
    }
    MouseArea { id: ma; anchors.fill: parent; enabled: b.enabled_; onClicked: b.clicked() }
}
