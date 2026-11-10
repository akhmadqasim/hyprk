import QtQuick

// Icon button inside a Capsule. The inner pill shows while pressed.
Item {
    id: root

    property string icon
    property real iconSize: Theme.toolbar.iconSize
    signal clicked()

    implicitWidth: Theme.toolbar.buttonWidth
    implicitHeight: Theme.toolbar.capsuleHeight
    opacity: enabled ? 1 : 0.9

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: height / 2
        color: Theme.color.capsuleSelected
        visible: tap.pressed
    }
    Symbol {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.enabled ? Theme.color.toolbarIcon : Theme.color.toolbarIconDisabled
    }
    TapHandler {
        id: tap
        enabled: root.enabled
        onTapped: root.clicked()
    }
}
