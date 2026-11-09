import QtQuick

// Icon button inside a Capsule. `selected` draws the inner pill used by the view switcher.
Item {
    id: root

    property string icon
    property real iconSize: Theme.toolbar.iconSize
    property bool selected: false
    signal clicked()

    implicitWidth: Theme.toolbar.buttonWidth
    implicitHeight: Theme.toolbar.capsuleHeight
    opacity: enabled ? 1 : 0.9

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: height / 2
        color: Theme.color.capsuleSelected
        visible: root.selected || tap.pressed
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
