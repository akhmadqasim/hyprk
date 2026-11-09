import QtQuick
import ".."

// macOS switch: accent capsule when on, white knob.
Item {
    id: sw
    property bool checked: false
    property bool enabled_: true
    signal toggled(bool checked)
    implicitWidth: Theme.control.switchWidth
    implicitHeight: Theme.control.switchHeight
    opacity: enabled_ ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: sw.checked ? Theme.accent : Theme.switchOff
        Behavior on color { ColorAnimation { duration: Theme.control.animMs } }
    }
    Rectangle {
        id: knob
        width: parent.height - 4; height: width; radius: width / 2
        y: 2
        x: sw.checked ? sw.width - width - 2 : 2
        color: Theme.knob
        border.color: Qt.rgba(0, 0, 0, 0.06)
        Behavior on x { NumberAnimation { duration: Theme.control.animMs; easing.type: Easing.OutCubic } }
        Rectangle { // soft drop shadow
            z: -1; anchors.centerIn: parent; anchors.verticalCenterOffset: 0.8
            width: parent.width + 1; height: width; radius: width / 2
            color: Qt.rgba(0, 0, 0, 0.18)
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: sw.enabled_
        onClicked: { sw.checked = !sw.checked; sw.toggled(sw.checked); }
    }
}
