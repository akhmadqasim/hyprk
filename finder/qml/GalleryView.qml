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
    signal tagRequested(Item anchor)
    readonly property int columns: 1

    function ensureVisible(i) { strip.positionViewAtIndex(i, ListView.Contain); }
    function iconItem(i) { const t = strip.itemAtIndex(i); return t ? t.iconItem : null; }

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
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: strip }
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
            readonly property Item iconItem: thumbIcon
            FileIcon {
                id: thumbIcon
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
            // gallery-dark.png, pane rows from the toolbar's bottom line: Information centre 96.5, rows from 107.5,
            // Tags centre 198, the token field 211-243.5 (the icon row above ends at 72)
            Column {
                width: parent.width
                topPadding: 85.5 - 72 - 6
                InfoRows {
                    width: parent.width
                    entry: root.focused
                }
                Item { width: 1; height: 10.5 }
                TextLabel {
                    height: 22
                    verticalAlignment: Text.AlignVCenter
                    text: "Tags"
                    size: Theme.font.preview
                    weight: Typography.semibold
                }
                Item { width: 1; height: 2 }
                // the tag field: the content background, 32.5 pt high; each tag a 14 pt token in its colour (fill
                // at 0.27 dark / 0.13 light, dashed rim 0.47 / 0.24), then "Add Tag" in (53,120,246). A file without
                // tags was not captured: the field then holds "Add Tag" alone
                Rectangle {
                    id: tagField
                    width: parent.width
                    height: 32.5
                    color: Theme.color.window
                    Row {
                        x: 1
                        y: 2
                        spacing: 4
                        Repeater {
                            model: root.focused && root.focused.tags ? root.focused.tags : []
                            Item {
                                id: token
                                required property string modelData
                                readonly property color tag: Theme.color.tagColors[modelData] || Theme.color.secondaryLabel
                                width: tokenText.implicitWidth + 9
                                height: 14
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 3
                                    color: Qt.rgba(token.tag.r, token.tag.g, token.tag.b, Theme.dark ? 0.27 : 0.13)
                                }
                                Canvas {      // the dashed rim (a Rectangle border cannot dash)
                                    anchors.fill: parent
                                    readonly property color ink: Qt.rgba(token.tag.r, token.tag.g, token.tag.b, Theme.dark ? 0.47 : 0.24)
                                    onInkChanged: requestPaint()
                                    onPaint: {
                                        const ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.strokeStyle = ink;
                                        ctx.lineWidth = 1;
                                        ctx.setLineDash([2, 1.5]);
                                        ctx.beginPath();
                                        ctx.roundedRect(0.5, 0.5, width - 1, height - 1, 3, 3);
                                        ctx.stroke();
                                    }
                                }
                                TextLabel {
                                    id: tokenText
                                    anchors.centerIn: parent
                                    text: token.modelData
                                    size: Theme.font.small
                                }
                            }
                        }
                        Item { width: 2; height: 1 }
                        TextLabel {
                            id: addTag
                            height: 14
                            verticalAlignment: Text.AlignVCenter
                            text: "Add Tag"
                            color: Theme.color.accent   // the shot's (53,120,246) is a Display P3 reading of #007AFF
                            size: Theme.font.small
                            TapHandler { onTapped: root.tagRequested(addTag) }
                        }
                    }
                }
            }
        }

        PreviewBar {
            anchors.bottom: parent.bottom
            width: parent.width
            entry: root.focused
            onMore: pos => { if (root.focused) root.contextMenu(root.focused, pos); }
        }
    }
}
