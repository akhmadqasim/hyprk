import QtQuick
import HyprK
import Finder.Native
import "lib/files.js" as Files

// Column (Miller) view derived from the current path: one column per folder from the
// root (home, or "/" outside home) down to the current folder. A selected folder adds a
// column with its contents, a selected file adds a preview column.
// 27.2.1 (Q-finder-19): 245 pt columns with a 1 pt divider, rows 24, icon 18, text at x 38, folder chevrons at
// the right; the selection is inset 10 / 11 with r 8, accent in the active column, grey in parent columns and
// everywhere while the window is inactive. Preview column about 240 wide.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) {
        const current = strip.itemAtIndex(root.dirs.length - 1);
        if (current && current.list) current.list.positionViewAtIndex(i, ListView.Contain);
    }

    function iconItem(i) {
        const current = strip.itemAtIndex(root.dirs.length - 1);
        const row = current && current.list ? current.list.itemAtIndex(i) : null;
        return row ? row.iconItem : null;
    }

    readonly property string home: FileOps.homePath()
    readonly property var dirs: {
        const p = browser.path;
        if (browser.isVirtual) return [p];
        const base = p === home || p.indexOf(home + "/") === 0 ? home : "/";
        return Files.segments(p).map(s => s.path).filter(d => base === "/" || d.length >= base.length);
    }
    readonly property var single: browser.selectedCount === 1 ? browser.selectedVisible[0] : null
    readonly property var columnDirs: single && single.isDir ? dirs.concat([single.path]) : dirs
    readonly property var previewEntry: single && !single.isDir ? single : null

    ListView {
        id: strip
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
        RubberBand { flickable: strip }
        clip: true
        model: root.columnDirs.length + (root.previewEntry ? 1 : 0)
        onCountChanged: Qt.callLater(() => positionViewAtEnd())

        delegate: Loader {
            id: slot
            required property int index
            readonly property bool isPreview: index >= root.columnDirs.length
            property var list: item && item.list ? item.list : null
            width: isPreview ? Math.max(Theme.columns.previewWidth, root.width - root.columnDirs.length * Theme.columns.width) : Theme.columns.width
            height: strip.height
            sourceComponent: isPreview ? previewColumn : dirColumn
        }
    }

    Component {
        id: dirColumn
        Item {
            id: col
            readonly property int colIndex: parent ? parent.index : 0   // parent is the Loader slot
            // "last" is the current folder's column, the only one that holds the selection
            readonly property bool last: colIndex === root.dirs.length - 1
            readonly property string dir: root.columnDirs[colIndex] || ""
            readonly property string chosen: colIndex < root.dirs.length - 1 ? root.dirs[colIndex + 1] : ""
            readonly property var entries: last ? root.browser.entries
                : Files.sortEntries(FileOps.list(dir, root.browser.showHidden), root.browser.sortKey, root.browser.ascending, false)
            property alias list: list

            ListView {
                id: list
                anchors.fill: parent
                anchors.rightMargin: 1
                topMargin: Theme.columns.top
                clip: true
                model: col.entries
                boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                RubberBand { flickable: list }
                footer: MouseArea {
                    width: list.width
                    height: Math.max(0, list.height - list.topMargin - list.count * Theme.columns.rowHeight)
                    onPressed: if (col.last) root.browser.clearSelection(); else root.browser.go(col.dir)
                }

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: col.last ? root.browser.isSelected(modelData.path) : modelData.path === col.chosen
                    readonly property bool accent: selected && col.last
                    readonly property bool renaming: root.browser.renamingPath === modelData.path
                    width: list.width
                    height: Theme.columns.rowHeight

                    Rectangle {
                        visible: row.selected
                        x: Theme.columns.insetLeft
                        width: parent.width - Theme.columns.insetLeft - Theme.columns.insetRight
                        height: parent.height
                        radius: Theme.list.rowRadius
                        color: row.accent ? Theme.color.listSelection : Theme.color.listSelectionInactive
                    }
                    readonly property Item iconItem: colIcon
                    FileIcon {
                        id: colIcon
                        x: Theme.columns.iconX
                        anchors.verticalCenter: parent.verticalCenter
                        entry: row.modelData
                        size: Theme.columns.iconSize
                    }
                    Text {
                        visible: !row.renaming
                        x: Theme.columns.textX
                        width: parent.width - x - 22 - (dots.visible ? dots.width + 6 : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.name
                        elide: Text.ElideMiddle
                        color: row.accent ? Theme.color.selectedText : Theme.color.label
                        font: Typography.body
                    }
                    TagDots {   // left of the chevron
                        id: dots
                        anchors.right: parent.right
                        anchors.rightMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        tags: row.modelData.tags || []
                    }
                    Loader {
                        active: row.renaming
                        x: Theme.columns.textX - 2
                        width: parent.width - x - 20
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: RenameField {
                            browser: root.browser
                            entry: row.modelData
                            horizontalAlignment: TextInput.AlignLeft
                            fontSize: Theme.font.list
                            multiLine: false
                        }
                    }
                    Symbol {
                        visible: row.modelData.isDir
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron.small.right"
                        size: 14
                        color: row.accent ? Theme.color.selectedText : Theme.color.secondaryLabel
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !row.renaming
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onPressed: mouse => {
                            root.forceActiveFocus();
                            const e = row.modelData;
                            const right = mouse.button === Qt.RightButton;
                            if (!col.last) {
                                // other column: make it the current folder with this item selected
                                root.browser.go(col.dir);
                                root.browser.selectPaths([e.path]);
                            } else if (!right || !row.selected) {
                                root.browser.click(row.index, right ? Qt.NoModifier : mouse.modifiers);
                            }
                            if (right) root.contextMenu(e, mapToItem(null, mouse.x, mouse.y));
                        }
                        onDoubleClicked: mouse => { if (mouse.button === Qt.LeftButton) root.browser.activate(row.modelData); }
                    }
                }
            }
            OverlayScrollbar {
                flickable: list
                x: list.width - width - Tokens.scroller.inset
                y: Tokens.scroller.inset
                height: col.height - 2 * Tokens.scroller.inset
            }
            Rectangle {   // 1 pt divider, no grip
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Theme.color.columnDivider
            }
        }
    }

    // preview column: the preview (219 wide), name, kind and size, Information rows
    Component {
        id: previewColumn
        Column {
            readonly property var entry: root.previewEntry
            leftPadding: 10
            rightPadding: 10
            topPadding: Theme.columns.top
            spacing: 8
            FileIcon {
                entry: parent.entry
                size: Theme.columns.previewImage
            }
            Item { width: 1; height: 20 }
            TextLabel {
                width: Theme.columns.previewImage
                elide: Text.ElideMiddle
                text: parent.entry ? parent.entry.name : ""
                size: 15
                weight: Typography.semibold
            }
            TextLabel {
                width: Theme.columns.previewImage
                elide: Text.ElideRight
                text: parent.entry ? parent.entry.kind + " - " + Files.formatSize(parent.entry.size, false) : ""
                color: Theme.color.secondaryLabel
                size: Theme.font.preview
            }
            InfoRows {
                width: Theme.columns.previewImage
                entry: parent.entry
            }
        }
    }
}
