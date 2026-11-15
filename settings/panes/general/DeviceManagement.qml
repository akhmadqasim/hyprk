import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// General > Device Management (27.2.1, MAC-ANSWERS-13.md R13.4, live/settings-r13/nav-general--deviceManagement-light.png,
// ax-nav-general--deviceManagement-light.jsonl): "Work or School Account" with Sign In… (52 pt), an empty profile list
// 208 pt tall ("No profiles installed") over a + / − strip, Help. No profiles here: the buttons take the press only.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    Card {
        FormRow {
            implicitHeight: 52
            iconId: "general-devicemanagement"; tint: Theme.tile.black; iconSize: 26; labelGap: 12
            label: "Work or School Account"
            Button { text: "Sign In…" }
        }
    }
    Card {
        Item {
            width: parent.width; height: 208
            MacText { anchors.horizontalCenter: parent.horizontalCenter; y: 96; text: "No profiles installed" }
        }
        ListBar {}
    }
    PaneFooter {}
}
