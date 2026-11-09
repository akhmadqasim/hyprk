import QtQuick
import QtQuick.Controls.Basic
import Finder.Native
import "lib/files.js" as Files

// Column (Miller) view derived from the current path: one column per folder from the
// root (home, or "/" outside home) down to the current folder. A selected folder adds a
// column with its contents, a selected file adds a preview column.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) {
        const current = strip.itemAtIndex(root.dirs.length - 1);
        if (current && current.list) current.list.positionViewAtIndex(i, ListView.Contain);
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
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: root.columnDirs.length + (root.previewEntry ? 1 : 0)
        onCountChanged: Qt.callLater(() => positionViewAtEnd())
        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

        delegate: Loader {
            id: slot
            required property int index
            readonly property bool isPreview: index >= root.columnDirs.length
            property var list: item && item.list ? item.list : null
            width: isPreview ? Math.max(Theme.columns.width + 40, root.width - root.dirs.length * Theme.columns.width) : Theme.columns.width
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
                anchors.margins: 6
                clip: true
                model: col.entries
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                footer: MouseArea {
                    width: list.width
                    height: Math.max(0, list.height - list.count * Theme.columns.rowHeight)
                    onPressed: if (col.last) root.browser.clearSelection(); else root.browser.go(col.dir)
                }

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: {
                        return col.last ? root.browser.isSelected(modelData.path) : modelData.path === col.chosen;
                    }
                    readonly property bool renaming: root.browser.renamingPath === modelData.path
                    width: list.width
                    height: Theme.columns.rowHeight
                    radius: Theme.list.rowRadius
                    color: !selected ? "transparent" : col.last ? Theme.color.listSelection : Theme.color.listSelectionInactive

                    FileIcon {
                        x: 6
                        anchors.verticalCenter: parent.verticalCenter
                        entry: row.modelData
                        size: Theme.columns.iconSize
                    }
                    Text {
                        visible: !row.renaming
                        x: 30
                        width: parent.width - x - 22
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.name
                        elide: Text.ElideMiddle
                        color: row.selected && col.last ? "white" : Theme.color.label
                        font.family: Theme.fontText
                        font.pixelSize: Theme.font.list
                    }
                    Loader {
                        active: row.renaming
                        x: 28
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
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        name: "chevron.small.right"
                        size: 14
                        color: row.selected && col.last ? "white" : Theme.color.secondaryLabel
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
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Theme.color.separator
            }
        }
    }

    Component {
        id: previewColumn
        Column {
            topPadding: 30
            spacing: 8
            FileIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                entry: root.previewEntry
                size: 180
            }
            TextLabel {
                width: (parent ? parent.width : 300) - 40
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                text: root.previewEntry.name
                color: Theme.color.label
                font.pixelSize: 15
                weight: Font.DemiBold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.previewEntry.kind + " – " + Files.formatSize(root.previewEntry.size, false)
                color: Theme.color.secondaryLabel
                font.family: Theme.fontText
                font.pixelSize: Theme.font.list
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Modified " + Files.formatDate(root.previewEntry.modified)
                color: Theme.color.secondaryLabel
                font.family: Theme.fontText
                font.pixelSize: Theme.font.list
            }
        }
    }
}
