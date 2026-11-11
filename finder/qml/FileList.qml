import QtQuick
import HyprK
import "lib/files.js" as Files

// List view (Q-finder-15/16/17): a 28 pt header (dark: a solid bar, Main extends it under the toolbar), rows
// 20 pt from 5 pt under it, inset 10 pt both sides, stripes on every second row, accent selection (grey while
// the window is inactive). Columns Name / Date Modified / Size / Kind; the sorted header is 11 Semibold with a
// chevron. Folders have a disclosure triangle at row x 1 (AX 15 x 22, ink 5 x 8.5, secondary) that opens them
// in place; each level indents by 16 (not measured: the icon's offset from the row start, one disclosure column).
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) { list.positionViewAtIndex(i, ListView.Contain); }
    function iconItem(i) { const r = list.itemAtIndex(i); return r ? r.iconItem : null; }

    readonly property var widths: Files.listColumns(width, Theme.list.sidePad, Theme.list.dateWidth, Theme.list.sizeWidth, Theme.list.kindWidth)
    readonly property var cols: [
        { key: "name", title: "Name" },
        { key: "modified", title: "Date Modified" },
        { key: "size", title: "Size", right: true },
        { key: "kind", title: "Kind" }
    ]

    Rectangle {
        width: parent.width
        height: Theme.list.headerHeight
        color: Theme.color.listHeaderFill
    }
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
                readonly property bool sorted: root.browser.sortKey === modelData.key
                width: root.widths[index]
                height: header.height
                Rectangle {   // 1 x 16 separator at the column's left edge
                    visible: h.index > 0
                    x: -1
                    width: 1; height: Theme.list.headerSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.color.listHeaderSeparator
                }
                TextLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: h.index === 0 ? Theme.list.nameX + 5 : 5   // header text x 214 / column + 5
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.list.cellPad
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    text: h.modelData.title
                    color: h.sorted ? Theme.color.listHeaderSorted : Theme.color.secondaryLabel
                    size: Theme.font.listHeader
                    weight: h.sorted ? Typography.semibold : Typography.regular
                }
                Symbol {
                    visible: h.sorted
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.list.sortChevronRight - (width - 7.5) / 2
                    anchors.verticalCenter: parent.verticalCenter
                    name: "chevron.down"
                    size: 9
                    weight: "semibold"
                    color: Theme.color.listHeaderSorted
                    rotation: root.browser.ascending ? 180 : 0
                }
                TapHandler {
                    onTapped: {
                        if (h.sorted) root.browser.ascending = !root.browser.ascending;
                        else { root.browser.sortKey = h.modelData.key; root.browser.ascending = h.modelData.key === "name"; }
                    }
                }
            }
        }
    }
    Rectangle {   // 1 pt bottom line at y 79
        y: Theme.list.headerHeight - 1
        width: parent.width
        height: 1
        color: Theme.color.listHeaderLine
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.topMargin: header.height
        anchors.leftMargin: Theme.list.sidePad
        anchors.rightMargin: Theme.list.sidePad
        topMargin: Theme.list.firstRowGap
        clip: true
        model: root.browser.entries
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: list }
        currentIndex: root.browser.cursor
        highlightFollowsCurrentItem: false

        // empty space below the rows
        footer: EntryMouseArea {
            width: list.width
            height: Math.max(0, list.height - list.topMargin - list.count * Theme.list.rowHeight)
            browser: root.browser
            onContextMenu: (e, pos) => root.contextMenu(e, pos)
            // the stripes go on below the last row
            Repeater {
                model: Math.ceil(parent.height / Theme.list.rowHeight)
                Rectangle {
                    required property int index
                    visible: (list.count + index) % 2 === 1
                    y: index * Theme.list.rowHeight
                    width: list.width
                    height: Theme.list.rowHeight
                    radius: Theme.list.rowRadius
                    color: Theme.color.listAlternate
                }
            }
        }

        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index
            readonly property bool selected: root.browser.isSelected(modelData.path)
            readonly property bool renaming: root.browser.renamingPath === modelData.path
            width: list.width
            height: Theme.list.rowHeight
            radius: Theme.list.rowRadius
            readonly property Item iconItem: rowIcon
            color: selected ? Theme.color.listSelection : index % 2 ? Theme.color.listAlternate : "transparent"

            Item {
                width: root.widths[0]
                height: parent.height
                readonly property real indent: (row.modelData.depth || 0) * Theme.list.indent
                Item {   // disclosure triangle: AX 15 x 22 at row x 1, ink 5 x 8.5 (Q-finder-15/16)
                    visible: row.modelData.isDir === true && !root.browser.isVirtual
                    x: parent.indent + Theme.list.disclosureX
                    width: Theme.list.disclosureWidth
                    height: parent.height
                    z: 2
                    readonly property bool open: root.browser.isExpanded(row.modelData.path)
                    Symbol {
                        anchors.centerIn: parent
                        name: "chevron.small.right"
                        size: 14
                        rotation: parent.open ? 90 : 0
                        color: row.selected ? Theme.color.selectedSecondaryText : Theme.color.secondaryLabel
                    }
                    TapHandler { onTapped: root.browser.setExpanded(row.modelData, !parent.open) }
                }
                FileIcon {
                    id: rowIcon
                    x: parent.indent + Theme.list.iconX
                    anchors.verticalCenter: parent.verticalCenter
                    entry: row.modelData
                    size: Theme.list.iconSize
                }
                Text {
                    visible: !row.renaming
                    x: parent.indent + Theme.list.nameX
                    width: parent.width - x - Theme.list.cellPad - (dots.visible ? dots.width + 6 : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.name
                    elide: Text.ElideMiddle
                    color: row.selected ? Theme.color.selectedText : Theme.color.label
                    font: Typography.body
                }
                TagDots {   // at the right end of the Name column
                    id: dots
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.list.cellPad
                    anchors.verticalCenter: parent.verticalCenter
                    tags: row.modelData.tags || []
                }
                Loader {
                    active: row.renaming
                    x: parent.indent + Theme.list.nameX - 2
                    width: parent.width - x - Theme.list.cellPad
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
                    x: root.widths.slice(0, index + 1).reduce((a, b) => a + b, 0)
                    width: root.widths[index + 1]
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.list.cellPad
                    rightPadding: Theme.list.cellPad
                    horizontalAlignment: index === 1 ? Text.AlignRight : Text.AlignLeft
                    text: modelData
                    elide: Text.ElideRight
                    color: row.selected ? Theme.color.selectedSecondaryText : Theme.color.secondaryLabel
                    font: Typography.body
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
            FolderDrop {   // no highlight on a list row under a drag (Q-finder-28)
                anchors.fill: parent
                enabled: row.modelData.isDir === true
                browser: root.browser
                path: row.modelData.path
            }
        }
    }
    OverlayScrollbar {
        flickable: list
        x: root.width - width - Tokens.scroller.inset
        y: list.y + Tokens.scroller.inset
        height: list.height - 2 * Tokens.scroller.inset
    }
}
