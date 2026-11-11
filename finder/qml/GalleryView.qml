import QtQuick
import HyprK
import "lib/files.js" as Files

// Gallery view (Q-finder-20): the focused item's preview in a 32 pt inset stage, a strip of 48 pt thumbnails at a
// 59 pt pitch (selected: a 54 pt grey plate, r 7, unchanged when inactive), and a 240 pt info pane on the right in
// the sidebar material: 50 pt icon, name 15 Semibold, kind and size, Information rows, tags.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) { strip.positionViewAtIndex(i, ListView.Contain); }

    readonly property var focused: {
        const i = browser.cursor >= 0 ? browser.cursor : 0;
        return browser.entries.length > i ? browser.entries[i] : null;
    }

    Item {
        id: stage
        x: Theme.gallery.pad
        y: Theme.gallery.pad
        width: pane.x - 2 * Theme.gallery.pad
        height: strip.y + (Theme.gallery.plate - Theme.gallery.thumb) / 2 - Theme.gallery.pad - Theme.gallery.stageGap

        Image {
            anchors.fill: parent
            visible: root.focused !== null && Files.isImage(root.focused)
            source: visible ? Files.fileUrl(root.focused.path) : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize: Qt.size(width * 2, height * 2)
        }
        FileIcon {
            visible: root.focused !== null && !Files.isImage(root.focused)
            anchors.centerIn: parent
            entry: root.focused || ({ name: "", isDir: false, mime: "" })
            size: Math.max(16, Math.min(parent.width, parent.height, 420))
        }
        EntryMouseArea {
            anchors.fill: parent
            browser: root.browser
            entry: root.focused
            index: Math.max(0, root.browser.cursor)
            onContextMenu: (e, pos) => root.contextMenu(e, pos)
        }
    }

    ListView {
        id: strip
        x: 0
        y: parent.height - Theme.gallery.stripBottom - height + (Theme.gallery.plate - Theme.gallery.thumb) / 2
        width: pane.x
        height: Theme.gallery.plate
        orientation: ListView.Horizontal
        clip: true
        spacing: Theme.gallery.pitch - Theme.gallery.plate
        leftMargin: Theme.gallery.pad
        rightMargin: 10
        model: root.browser.entries
        boundsBehavior: Tokens.scroller.bounds
        currentIndex: root.browser.cursor
        highlightFollowsCurrentItem: false
        onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)

        delegate: Item {
            id: thumb
            required property var modelData
            required property int index
            readonly property bool selected: root.browser.isSelected(modelData.path)
            width: Theme.gallery.plate
            height: Theme.gallery.plate
            Rectangle {
                anchors.fill: parent
                radius: Theme.gallery.plateRadius
                visible: thumb.selected
                color: Theme.color.galleryPlate
            }
            FileIcon {
                anchors.centerIn: parent
                entry: thumb.modelData
                size: Theme.gallery.thumb
            }
            EntryMouseArea {
                anchors.fill: parent
                browser: root.browser
                entry: thumb.modelData
                index: thumb.index
                onContextMenu: (e, pos) => root.contextMenu(e, pos)
            }
        }
    }

    Rectangle {
        id: pane
        x: parent.width - width
        width: Theme.gallery.paneWidth
        height: parent.height
        color: Theme.blur ? Theme.color.sidebarGlass : Theme.color.sidebarSolid
        Rectangle { width: 0.5; height: parent.height; color: Theme.color.separator }

        Column {
            visible: root.focused !== null
            x: 10
            y: 22
            width: parent.width - 20
            spacing: 6
            Row {
                spacing: 13
                FileIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    entry: root.focused || ({ name: "", isDir: false, mime: "" })
                    size: Theme.gallery.paneIcon
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    TextLabel {
                        width: pane.width - 20 - Theme.gallery.paneIcon - 13
                        elide: Text.ElideMiddle
                        text: root.focused ? root.focused.name : ""
                        size: 15
                        weight: Typography.semibold
                    }
                    TextLabel {
                        text: root.focused ? root.focused.kind + " - " + Files.formatSize(root.focused.size, root.focused.isDir) : ""
                        color: Theme.color.tertiaryLabel
                        size: Theme.font.preview
                    }
                }
            }
            Item { width: 1; height: 14 }
            InfoRows {
                width: parent.width
                entry: root.focused
            }
            Item { width: 1; height: 10 }
            TextLabel {
                visible: tagLine.visible
                text: "Tags"
                size: Theme.font.preview
                weight: Typography.semibold
            }
            TagDots {
                id: tagLine
                tags: root.focused && root.focused.tags ? root.focused.tags : []
            }
        }
    }
}
