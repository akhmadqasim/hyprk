import QtQuick

// Liquid-glass style toolbar capsule: near-white fill, hairline border, faint drop shadow.
Item {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real padding: 0

    implicitWidth: row.implicitWidth + 2 * padding
    implicitHeight: Theme.toolbar.capsuleHeight

    Rectangle {   // shadow
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: -2
        radius: height / 2
        color: Theme.color.capsuleShadow
    }
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.color.capsule
        border.width: 1
        border.color: Theme.color.capsuleBorder
    }
    Row {
        id: row
        x: root.padding
        anchors.verticalCenter: parent.verticalCenter
    }
}
