import QtQuick
import ".."
import "../HyprK"

// The strip under a list in a card (27.2.1: Language & Region's Preferred Languages, Time Machine's disks, Login Items;
// live/settings-r12 nav-general--*-dark.png): 23 pt, a hairline on top, "+" (ink 9.5 x 9.5) 7.5 pt in and "−"
// (9.5 x 1.5) 25 pt after it, a 1 pt divider between them. Remove is dimmed while nothing is selected (AX: disabled).
Item {
    id: bar
    property bool canRemove: false
    signal add()
    signal remove()
    width: parent ? parent.width : 0
    height: 23
    Rectangle { width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
    Rectangle { anchors.fill: parent; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.03) }
    Item {
        x: 7.5; y: 7; width: 9.5; height: 9.5
        Rectangle { y: 4; width: 9.5; height: 1.5; color: Theme.secondaryLabel }
        Rectangle { x: 4; width: 1.5; height: 9.5; color: Theme.secondaryLabel }
        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: bar.add() }
    }
    Rectangle { x: 24.5; y: 4; width: 1; height: 15; color: Theme.separator }
    Item {
        x: 32.5; y: 7; width: 9.5; height: 9.5
        Rectangle { y: 4; width: 9.5; height: 1.5; color: bar.canRemove ? Theme.secondaryLabel : Theme.tertiaryLabel }
        MouseArea { anchors.fill: parent; anchors.margins: -6; enabled: bar.canRemove; onClicked: bar.remove() }
    }
}
