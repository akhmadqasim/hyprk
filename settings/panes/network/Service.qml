import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// Network > a service (27.2.1, live/settings-r13/dest-network--usb-10-100-1000-lan-*.png, ax-dest-network--*): one
// 56 pt card: the service's tile, its name 14 pt down, a dot and the state under it, Details… (76 x 24) 10 pt down at
// the right; below, Delete Service… and Make Inactive at the left and Help at the right. Details… is the 670 x 425
// sheet (controls/DetailSheet.qml): Name in a field, Limit IP address tracking (on, the Mac's value).
// The state is NetworkManager's (read-only). Nothing is deleted, made inactive or renamed (settings/FALLBACKS.md).
Column {
    id: page
    property var pane
    property var dev
    readonly property string name: pane.serviceName(dev)
    readonly property bool up: dev.state.startsWith("connected")
    spacing: Theme.content.sectionGap
    Card {
        Item {
            width: parent.width; height: 56
            PaneIcon { x: 10; y: 15; size: 26; iconId: page.pane.serviceIcon(page.dev) }
            MacText { x: 48; y: 14; text: page.name }
            Rectangle { x: 49; y: 34.5; width: 8.5; height: 8.5; radius: 4.25; color: page.up ? Theme.tile.green : Theme.tile.red }
            Text { x: 61.5; y: 32; text: page.up ? "Connected" : "Not connected"; font: Typography.subheadline; color: Theme.secondaryLabel }
            Button { objectName: "serviceDetailsButton"; anchors.right: parent.right; anchors.rightMargin: 10; y: 10; text: "Details…"; onClicked: details.open() }
        }
    }
    Item {
        width: parent.width; height: 34
        Row {
            y: 10; spacing: 10
            Button { text: "Delete Service…" }
            Button { text: "Make Inactive" }
        }
        HelpButton { objectName: "serviceHelp"; anchors.right: parent.right; y: 10 }
    }
    DetailSheet {
        id: details
        objectName: "serviceDetails"
        iconId: page.pane.serviceIcon(page.dev)
        name: page.name
        status: page.up ? "Connected" : "Not connected"
        dot: page.up ? Theme.tile.green : Theme.tile.red
        Card {
            FormRow {
                label: "Name"
                TextInput {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 340; clip: true   // 366.5 on the Mac, from the label's end; FormRow keeps a gap; horizontalAlignment: TextInput.AlignRight
                    text: page.name
                    font: Typography.body; color: Theme.label
                    selectByMouse: true; selectionColor: Theme.accent
                }
            }
        }
        Card {
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Limit IP address tracking"
                sublabel: "Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari. When this is turned off, iCloud Private Relay will also be turned off for this network."
                LocalSwitch { checked: true }
            }
        }
    }
}
