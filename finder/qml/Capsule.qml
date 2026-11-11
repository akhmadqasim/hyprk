import QtQuick
import HyprK

// Toolbar item-group capsule: a raised platter (macOS 27.2.1 renders it as glass that, at 36 pt, has almost no blur;
// the Finder is a plain Qt window, so it draws the measured look: HyprK ToolbarPlatter with its relief shading).
// Measured on screens/27.2.1/finder/icons-{light,dark}.png (2x, every capsule the same): light, a 37 pt tall shape
// (edge rows y 15 / 88 px, 234 / 231, sides 191) whose face has 1 pt lit rows under the top and over the bottom edge
// (255) and a 249 band at a quarter of the height (the platter's light relief draws that); dark, 36 pt (edge rows 16 / 87, lit 107..111, sides 11) over a
// face lit towards both edges (90, 72 .. 61 in the middle .. 71, 89). The face below follows those columns.
Item {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real padding: 0
    readonly property real inset: Theme.dark && Theme.active ? 0.5 : 0

    implicitWidth: row.implicitWidth + 2 * padding
    implicitHeight: Theme.toolbar.capsuleHeight

    ToolbarPlatter {
        id: platter
        visible: Theme.active   // inactive: no shadow under the flat capsule (255 below it, 252 when active)
        anchors.fill: parent
        anchors.topMargin: root.inset
        anchors.bottomMargin: root.inset
        relief: true
    }
    Rectangle {   // dark: a white lift over the face inside the 1 px edge (light: the platter's own relief face)
        visible: Theme.active && Theme.dark
        anchors.fill: platter
        anchors.margins: 0.5
        radius: height / 2
        gradient: darkFace
    }
    // inactive window (Q-finder-29, crops/toolbar-{light,dark}-inactive.png): the shading goes, a flat 37 pt capsule in
    // both appearances, light face 240 with a 213 edge and 191 sides, dark (58,60,67) with a 26 edge and 20 sides (drawn
    // neutral at their luminance: 59, 27, 21, as the active dark face here is the neutral 61 of the Mac's (61,62,70))
    Rectangle {
        id: flat
        visible: !Theme.active
        anchors.fill: parent
        radius: height / 2
        color: Theme.color.capsuleInactive
        border.width: 0.5
        border.color: Theme.dark ? "#1B1B1B" : "#D5D5D5"
    }
    Item {        // its sides darker: the same edge clipped to the straight middle third
        visible: flat.visible
        y: Math.round(root.height / 3)
        width: root.width
        height: root.height - 2 * y
        clip: true
        Rectangle {
            y: -parent.y
            width: root.width
            height: root.height
            radius: height / 2
            color: "transparent"
            border.width: 0.5
            border.color: Theme.dark ? "#151515" : "#BFBFBF"
        }
    }
    Row {
        id: row
        x: root.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Gradient {   // y 17..86 px over the 59 face: white (v - 59) / 196
        id: darkFace
        GradientStop { position: 0.007; color: Qt.rgba(1, 1, 1, 0.158) }
        GradientStop { position: 0.021; color: Qt.rgba(1, 1, 1, 0.066) }
        GradientStop { position: 0.036; color: Qt.rgba(1, 1, 1, 0.051) }
        GradientStop { position: 0.064; color: Qt.rgba(1, 1, 1, 0.031) }
        GradientStop { position: 0.121; color: Qt.rgba(1, 1, 1, 0.020) }
        GradientStop { position: 0.193; color: Qt.rgba(1, 1, 1, 0.010) }
        GradientStop { position: 0.493; color: Qt.rgba(1, 1, 1, 0.010) }
        GradientStop { position: 0.821; color: Qt.rgba(1, 1, 1, 0.015) }
        GradientStop { position: 0.921; color: Qt.rgba(1, 1, 1, 0.031) }
        GradientStop { position: 0.964; color: Qt.rgba(1, 1, 1, 0.046) }
        GradientStop { position: 0.979; color: Qt.rgba(1, 1, 1, 0.061) }
        GradientStop { position: 0.993; color: Qt.rgba(1, 1, 1, 0.153) }
    }
}
