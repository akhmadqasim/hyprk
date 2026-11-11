import QtQuick
import HyprK
import "lib/files.js" as Files

// "Information" block of the gallery pane and the column-view preview (Q-finder-19/20): a 13 Semibold header,
// then Created / Modified / Last opened at a 23 pt pitch, label 11 secondary at the left, value 11 Medium at the
// right, 0.5 pt lines between. The header's centre is 22.5 pt above the first row's (gallery-dark.png: 148.5 and
// 171), with a "Show More" link at its right in 11 pt, (89,152,245) dark / (46,104,211) light. What the Mac shows
// after a click was not captured: here it adds the size.
Column {
    id: root
    property var entry: null
    readonly property var rows: !entry ? [] : [
        { label: "Created", ms: entry.created },
        { label: "Modified", ms: entry.modified },
        { label: "Last opened", ms: entry.opened }
    ].filter(r => r.ms !== undefined && r.ms >= 0).concat(more ? [{ label: "Size", text: Files.formatSize(entry.size, entry.isDir) }] : [])
    property bool more: false
    onEntryChanged: more = false

    Item {
        width: root.width
        height: 22
        TextLabel {
            anchors.verticalCenter: parent.verticalCenter
            text: "Information"
            size: Theme.font.preview
            weight: Typography.semibold
        }
        TextLabel {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.more ? "Show Less" : "Show More"
            color: Theme.dark ? Qt.rgba(89 / 255, 152 / 255, 245 / 255, 1) : Qt.rgba(46 / 255, 104 / 255, 211 / 255, 1)
            size: Theme.font.small
            TapHandler { onTapped: root.more = !root.more }
        }
    }
    Repeater {
        model: root.rows
        Item {
            required property var modelData
            required property int index
            width: root.width
            height: Theme.gallery.infoPitch
            Rectangle {
                visible: index > 0
                width: parent.width; height: 0.5
                color: Theme.color.separator
            }
            TextLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: Theme.color.secondaryLabel
                size: Theme.font.small
            }
            TextLabel {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.text !== undefined ? modelData.text : Files.formatDateLong(modelData.ms)
                size: Theme.font.small
                weight: Typography.medium
            }
        }
    }
}
