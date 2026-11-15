import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Transfer or Reset (27.2.1, live/settings-r12/nav-general--transferOrReset-dark.png, ax-nav-...): one card
// (Migration Assistant's icon and name with "Open Migration Assistant…" in a 46 pt row, then three lines about it),
// then "Erase All Content and Settings…" and Help. Neither button acts: there is no Migration Assistant here, and the
// Mac's erase asks for a password first (R12.3: not opened).
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    Card {
        Item {
            width: parent.width; height: 46
            Image { x: 12; anchors.verticalCenter: parent.verticalCenter; width: 22; height: 22; sourceSize: Qt.size(128, 128); source: "file://" + Backend.root + "/themes/icons/apps/Migration_Assistant-128.png" }
            MacText { x: 44; anchors.verticalCenter: parent.verticalCenter; text: "Migration Assistant" }
            Button { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: "Open Migration Assistant…" }
        }
        Item {
            width: parent.width; height: 63
            Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Text {
                x: 10; y: 11; width: parent.width - 20; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "Use Migration Assistant to transfer information (data, computer settings and apps) to this Mac from another Mac, a Windows PC, a Time Machine backup or a disk. You can also transfer information from this Mac to another Mac."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
        }
    }
    PaneFooter { Button { text: "Erase All Content and Settings…" } }
}
