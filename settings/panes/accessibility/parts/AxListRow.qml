import QtQuick
import "../../.."
import "../../../HyprK"

// A row of a list inside a group (ax-acc-subtitles-and-captioning: 24 tall, text 10 in; the selected row grey, 223 on
// the 247 card and 91 on 37 in the stills, whose window is not key).
Item {
    id: r
    property string text
    property bool selected: false
    property bool centered: false
    property bool sep: true
    property real h: 24
    property real textY: (h - 16) / 2
    property real sepX: Theme.content.separatorInset
    signal clicked()
    default property alias content: slot.data
    width: parent ? parent.width : 0
    height: h
    Rectangle { anchors.fill: parent; visible: r.selected; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.098) }
    Rectangle {
        visible: r.sep && !r.selected
        x: r.sepX; width: parent.width - x - Theme.content.separatorInset; height: 1
        color: Theme.separator
    }
    Text {
        visible: r.text !== ""
        x: r.centered ? (parent.width - width) / 2 : Theme.content.rowPadding
        y: r.textY + 0.25
        text: r.text
        font: Typography.body
        color: r.centered ? Theme.secondaryLabel : Theme.label
    }
    MouseArea { anchors.fill: parent; onClicked: r.clicked() }
    Item { id: slot; anchors.fill: parent }
}
