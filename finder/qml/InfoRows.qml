import QtQuick
import HyprK
import "lib/files.js" as Files

// "Information" block of the gallery pane and the column-view preview (Q-finder-19/20): a 13 Semibold header,
// then Created / Modified / Last opened at a 23 pt pitch, label 11 secondary at the left, value 11 Medium at the
// right, 0.5 pt lines between.
Column {
    id: root
    property var entry: null
    readonly property var rows: !entry ? [] : [
        { label: "Created", ms: entry.created },
        { label: "Modified", ms: entry.modified },
        { label: "Last opened", ms: entry.opened }
    ].filter(r => r.ms !== undefined && r.ms >= 0)

    TextLabel {
        height: 30
        verticalAlignment: Text.AlignVCenter
        text: "Information"
        size: Theme.font.preview
        weight: Typography.semibold
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
                text: Files.formatDateLong(modelData.ms)
                size: Theme.font.small
                weight: Typography.medium
            }
        }
    }
}
