import QtQuick

// Quick Look title-bar button: 34 x 26, glyph only (live/finder/crops/quicklook-titlebar-light.png). No hover or press
// look was captured; a press darkens like the "Open with" capsule.
Item {
    id: root
    property string icon
    property real iconSize: 18
    signal clicked()
    width: 34
    height: 26
    y: 6
    Rectangle { anchors.fill: parent; radius: 13; color: Qt.rgba(0, 0, 0, 0.125); visible: tap.pressed }
    Symbol {
        anchors.centerIn: parent
        size: root.iconSize
        name: root.icon
        color: Theme.color.quickLookInk
        opacity: root.enabled ? 1 : 0.35
    }
    TapHandler { id: tap; onTapped: root.clicked() }
}
