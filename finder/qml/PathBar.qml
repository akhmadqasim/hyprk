import QtQuick
import HyprK
import "lib/files.js" as Files

// Path bar (View > Show Path Bar; Q-finder-22): a 1 pt top line, then 28 pt with no fill and no glass. Items
// from x 6: 16 pt icon + 11 pt Regular secondary text, 4 x 6 chevrons between; no hover. Every item is clickable.
Item {
    id: root

    required property var browser

    height: Theme.pathBar.height + 1

    Rectangle { width: parent.width; height: 1; color: Theme.color.pathBarLine }

    Flickable {
        y: 1
        width: parent.width
        height: Theme.pathBar.height
        leftMargin: Theme.pathBar.x
        contentWidth: row.width
        clip: true
        flickableDirection: Flickable.HorizontalFlick
        Row {
            id: row
            height: Theme.pathBar.height
            spacing: 4
            Repeater {
                // the folder's ancestors, then the selected item (Demo > finder-demo > Sunset.png)
                model: (root.browser.isVirtual ? [{ name: root.browser.title, path: root.browser.path }]
                                               : Files.segments(root.browser.path, "Macintosh HD"))
                       .concat(root.browser.selectedCount === 1
                               ? [{ name: root.browser.selectedVisible[0].name, path: "", entry: root.browser.selectedVisible[0] }] : [])
                Row {
                    required property var modelData
                    required property int index
                    height: row.height
                    spacing: 4
                    Symbol {
                        visible: index > 0
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron.small.right"
                        size: 9
                        weight: "semibold"
                        color: Theme.color.secondaryLabel
                    }
                    Symbol {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: modelData.path === "/"
                        name: "drive"
                        size: Theme.pathBar.iconSize
                        color: Theme.color.sidebarIconGrey
                    }
                    FileIcon {
                        visible: modelData.path !== "/"
                        anchors.verticalCenter: parent.verticalCenter
                        entry: modelData.entry || ({ name: modelData.name, path: modelData.path, isDir: true, mime: "inode/directory" })
                        size: Theme.pathBar.iconSize
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: EmojiText.opaque(modelData.name, color)   // emoji at alpha 1 (OPEN-FIXES.md 16)
                        textFormat: EmojiText.has(modelData.name) ? Text.StyledText : Text.PlainText
                        color: Theme.color.secondaryLabel
                        font: Typography.font(Theme.font.pathBar)
                        TapHandler { onTapped: if (modelData.path) root.browser.go(modelData.path) }
                    }
                }
            }
        }
    }
}
