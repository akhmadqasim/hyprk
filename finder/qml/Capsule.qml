import QtQuick
import HyprK

// Toolbar item-group capsule: a flat raised platter (macOS 27.2.1 renders it as glass that, at 36 pt, has
// almost no blur; the Finder is a plain Qt window, so it draws the measured look, HyprK ToolbarPlatter).
Item {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real padding: 0

    implicitWidth: row.implicitWidth + 2 * padding
    implicitHeight: Theme.toolbar.capsuleHeight

    ToolbarPlatter {
        anchors.fill: parent
        unit: Theme.toolbar.pt
    }
    Row {
        id: row
        x: root.padding
        anchors.verticalCenter: parent.verticalCenter
    }
}
