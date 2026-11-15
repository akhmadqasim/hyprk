import QtQuick
import HyprK
import "lib/files.js" as Files

// "Information" block of the gallery pane and the column-view preview (Q-finder-19/20): a 13 Semibold header,
// then Created / Modified / Last opened at a 23 pt pitch, label 11 secondary at the left, value 11 Medium at the
// right, 0.5 pt lines between. The header's centre is 22.5 pt above the first row's (gallery-dark.png: 148.5 and
// 171), with a "Show More" link at its right in 11 pt, (89,152,245) dark / (46,104,211) light. What the Mac shows
// after a click was not captured (FALLBACKS.md): the link does nothing here. The gallery (R9.2) hides the link for
// folders and text files, adds Dimensions for an image and draws the row titles in SF Medium 11. Last opened only
// for a file that has a last-used date (R9.2: none for new files, so Tags sits at 248 pt): FileOps' "opened" is its
// recently-used.xbel record, -1 without one (FALLBACKS.md).
Column {
    id: root
    property var entry: null
    property bool showMore: true
    property string dimensions: ""                    // "1600×1067": a Dimensions row after the dates
    property int titleWeight: Typography.regular
    readonly property var rows: !entry ? [] : [
        { label: "Created", ms: entry.created },
        { label: "Modified", ms: entry.modified },
        { label: "Last opened", ms: entry.opened }
    ].filter(r => r.ms !== undefined && r.ms >= 0).concat(dimensions ? [{ label: "Dimensions", text: dimensions }] : [])

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
            visible: root.showMore
            text: "Show More"
            color: Accent.link   // the shot's (89,152,245) / (46,104,211) are Display P3 readings of the catalog link colour
            size: Theme.font.small
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
                width: parent.width; height: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
                color: Theme.color.separator
            }
            TextLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: Theme.color.secondaryLabel
                size: Theme.font.small
                weight: root.titleWeight
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
