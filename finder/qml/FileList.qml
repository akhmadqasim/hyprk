import QtQuick
import QtQuick.Controls.Basic
import "lib/files.js" as Files

// List view: sortable columns Name, Date Modified, Size, Kind with alternating rows.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) { list.positionViewAtIndex(i, ListView.Contain); }

    readonly property var cols: [
        { key: "name", title: "Name", width: Math.max(160, width - Theme.list.dateWidth - Theme.list.sizeWidth - Theme.list.kindWidth - 2 * Theme.list.sidePad) },
        { key: "modified", title: "Date Modified", width: Theme.list.dateWidth },
        { key: "size", title: "Size", width: Theme.list.sizeWidth, right: true },
        { key: "kind", title: "Kind", width: Theme.list.kindWidth }
    ]

    Row {
        id: header
        x: Theme.list.sidePad
        height: Theme.list.headerHeight
        Repeater {
            model: root.cols
            Item {
                id: h
                required property var modelData
                required property int index
                width: modelData.width
                height: header.height
                Rectangle {
                    visible: h.index > 0
                    width: 1; height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.color.separator
                }
                TextLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: h.index === 0 ? 28 : 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: h.modelData.right ? Text.AlignRight : Text.AlignLeft
                    text: h.modelData.title
                    color: Theme.color.secondaryLabel
                    font.pixelSize: Theme.font.listHeader
                    weight: root.browser.sortKey === h.modelData.key ? Font.DemiBold : Font.Medium
                }
                Symbol {
                    visible: root.browser.sortKey === h.modelData.key
                    anchors.right: parent.right
                    anchors.rightMargin: h.modelData.right ? -12 : 8
                    anchors.verticalCenter: parent.verticalCenter
                    name: "chevron.down"
                    size: 11
                    color: Theme.color.secondaryLabel
                    rotation: root.browser.ascending ? 180 : 0
                }
                TapHandler {
                    onTapped: {
                        if (root.browser.sortKey === h.modelData.key) root.browser.ascending = !root.browser.ascending;
                        else { root.browser.sortKey = h.modelData.key; root.browser.ascending = h.modelData.key === "name"; }
                    }
                }
            }
        }
    }
    Rectangle {
        anchors.top: header.bottom
        width: parent.width
        height: 1
        color: Theme.color.separator
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.topMargin: header.height + 1
        anchors.leftMargin: Theme.list.sidePad
        anchors.rightMargin: Theme.list.sidePad
        clip: true
        model: root.browser.entries
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.browser.cursor
        highlightFollowsCurrentItem: false
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        // empty space below the rows
        footer: EntryMouseArea {
            width: list.width
            height: Math.max(0, list.height - list.count * Theme.list.rowHeight)
            browser: root.browser
            onContextMenu: (e, pos) => root.contextMenu(e, pos)
        }

        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index
            readonly property bool selected: root.browser.isSelected(modelData.path)
            readonly property bool renaming: root.browser.renamingPath === modelData.path
            readonly property color textColor: selected ? "white" : Theme.color.label
            width: list.width
            height: Theme.list.rowHeight
            radius: Theme.list.rowRadius
            color: selected ? Theme.color.listSelection : index % 2 ? Theme.color.listAlternate : "transparent"
            border.width: drop.hovered ? 2 : 0   // Finder outlines the folder row under a drag
            border.color: Theme.color.accent

            Row {
                anchors.fill: parent
                Item {
                    width: root.cols[0].width
                    height: parent.height
                    FileIcon {
                        x: 6
                        anchors.verticalCenter: parent.verticalCenter
                        entry: row.modelData
                        size: Theme.list.iconSize
                    }
                    Text {
                        visible: !row.renaming
                        x: 28
                        width: parent.width - x - 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: Files.hasTags(row.modelData) ? Files.styledName(row.modelData, Theme.color.tagColors) : row.modelData.name
                        textFormat: Files.hasTags(row.modelData) ? Text.StyledText : Text.PlainText
                        elide: Text.ElideMiddle
                        color: row.textColor
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.list
                    }
                    Loader {
                        active: row.renaming
                        x: 26
                        width: parent.width - x - 8
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: RenameField {
                            browser: root.browser
                            entry: row.modelData
                            horizontalAlignment: TextInput.AlignLeft
                            fontSize: Theme.font.list
                            multiLine: false
                        }
                    }
                }
                Repeater {
                    model: [
                        Files.formatDate(row.modelData.modified),
                        Files.formatSize(row.modelData.size, row.modelData.isDir),
                        row.modelData.kind
                    ]
                    Text {
                        required property var modelData
                        required property int index
                        width: root.cols[index + 1].width
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8
                        rightPadding: 8
                        horizontalAlignment: index === 1 ? Text.AlignRight : Text.AlignLeft
                        text: modelData
                        elide: Text.ElideRight
                        color: row.selected ? "white" : Theme.color.secondaryLabel
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.list
                    }
                }
            }

            EntryMouseArea {
                anchors.fill: parent
                enabled: !row.renaming
                browser: root.browser
                entry: row.modelData
                index: row.index
                onContextMenu: (e, pos) => root.contextMenu(e, pos)
            }
            FolderDrop {
                id: drop
                anchors.fill: parent
                enabled: row.modelData.isDir === true
                browser: root.browser
                path: row.modelData.path
            }
        }
    }
}
