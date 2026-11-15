import QtQuick
import ".."
import "../HyprK"

// The "Details…" sheet of a network service (27.2.1, MAC-ANSWERS-13.md R13.1; live/settings-r13/dest-wifi--details-*.png,
// dest-network--usb-10-100-1000-lan--details-*.png and their AX dumps): 670 x 425 at window 35,100. Left, a 200 pt
// list: the service's own row (47.5 pt from 10: tile, name, a dot and its state; selected when the sheet opens) and
// six 32 pt rows TCP/IP, DNS, WINS, 802.1X, Proxies, Hardware (labels 16 pt in). Right, a 470 x 360 scroll area with
// the selected row's cards 20 pt in, and a 65 pt strip: Cancel and OK (66 x 24, 510 and 584 pt in), `leading` at its
// left (Wi-Fi: Forget This Network…). The six titles are the Mac's for Wi-Fi and for the Ethernet-type services alike
// (MAC-ANSWERS-14.md R14.1). Only the service's own page is on a shot: the other six select and show nothing.
SubSheet {
    id: ds
    sheetWidth: 670; sheetHeight: 425
    footer: false
    property string name
    property string status
    property color dot: Theme.tile.red
    property string iconId
    property int current: -1              // -1 = the service's own row, else an index of `sections`
    readonly property var sections: ["TCP/IP", "DNS", "WINS", "802.1X", "Proxies", "Hardware"]
    default property alias detail: cards.data
    property alias trailingLeft: lead.data
    onClosed: current = -1

    Rectangle {
        width: 200; height: ds.sheetHeight
        color: Theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.03)
        topLeftRadius: Tokens.panel.sheetRadius; bottomLeftRadius: Tokens.panel.sheetRadius
        Rectangle { anchors.right: parent.right; width: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: parent.height; color: Theme.separator }
        Rectangle {
            id: own
            objectName: "detailOwnRow"
            readonly property bool on: ds.current === -1
            x: 10; y: 10; width: 180; height: 47.5; radius: 8
            color: on ? Theme.sidebar.selection : "transparent"
            PaneIcon { x: 7; anchors.verticalCenter: parent.verticalCenter; size: 26; iconId: ds.iconId }
            MacText { x: 40; y: 8; width: 134; elide: Text.ElideRight; text: ds.name; color: own.on ? Theme.sidebar.selectionText : Theme.label }
            Rectangle { x: 41; y: 28; width: 8.5; height: 8.5; radius: 4.25; color: ds.dot }
            Text { x: 53.5; y: 25.5; text: ds.status; font: Typography.subheadline; color: own.on ? Theme.sidebar.selectionText : Theme.secondaryLabel }
            MouseArea { anchors.fill: parent; onClicked: ds.current = -1 }
        }
        Repeater {
            model: ds.sections
            Rectangle {
                required property string modelData
                required property int index
                readonly property bool on: index === ds.current
                objectName: "detailRow" + index
                x: 10; y: 57.5 + index * 32; width: 180; height: 32; radius: 8
                color: on ? Theme.sidebar.selection : "transparent"
                MacText {
                    x: 6; anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    weight: parent.on ? Typography.semibold : Typography.regular
                    color: parent.on ? Theme.sidebar.selectionText : Theme.label
                }
                MouseArea { anchors.fill: parent; onClicked: ds.current = index }
            }
        }
    }
    Flickable {
        x: 200; width: 470; height: 360
        clip: true
        contentHeight: cards.height + 40
        boundsBehavior: Flickable.StopAtBounds
        acceptedButtons: Qt.NoButton
        Column { id: cards; x: 20; y: 20; width: 430; spacing: Theme.content.sectionGap; visible: ds.current === -1 }
    }
    Rectangle { x: 200; y: 360; width: 470; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
    Row { id: lead; x: 220; y: 381; spacing: 10 }
    Button { objectName: "detailCancel"; x: 510; y: 381; width: 66; text: "Cancel"; onClicked: ds.close() }
    Button { objectName: "detailOK"; x: 584; y: 381; width: 66; text: "OK"; primary: true; onClicked: ds.close() }
    Shortcut { sequences: ["Return", "Enter"]; enabled: ds.shown; onActivated: ds.close() }
}
