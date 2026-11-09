import QtQuick
import QtQuick.Controls.Basic
import Finder.Native
import "lib/files.js" as Files

// Column (Miller) view derived from the current path: one column per folder from the
// root (home, or "/" outside home) down to the current folder, plus a preview column.
Item {
    id: root

    required property var browser
    signal contextMenu(var entry, point pos)
    readonly property int columns: 1

    function ensureVisible(i) {
        const last = strip.itemAtIndex(strip.count - 1);
        if (last && last.list) last.list.positionViewAtIndex(i, ListView.Contain);
    }

    readonly property string home: FileOps.homePath()
    readonly property var dirs: {
        const p = browser.path;
        if (browser.isVirtual) return [p];
        const base = p === home || p.indexOf(home + "/") === 0 ? home : "/";
        const out = [base];
        if (p !== base) {
            let acc = base === "/" ? "" : base;
            for (const part of p.slice(acc.length + 1).split("/")) {
                acc += "/" + part;
                out.push(acc);
            }
        }
        return out;
    }
    readonly property var previewEntry: {
        browser.selRev;
        const sel = browser.selectedEntries();
        return sel.length === 1 && !sel[0].isDir ? sel[0] : null;
    }

    ListView {
        id: strip
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: root.dirs.length + (root.previewEntry ? 1 : 0)
        onCountChanged: Qt.callLater(() => positionViewAtEnd())
        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

        delegate: Loader {
            id: slot
            required property int index
            readonly property bool isPreview: index >= root.dirs.length
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
            readonly property bool last: colIndex === root.dirs.length - 1
            readonly property string dir: root.dirs[colIndex]
            readonly property string chosen: last ? "" : root.dirs[colIndex + 1]
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
                        root.browser.selRev;
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
                            if (!col.last) {
                                // earlier column: re-root the chain at this column
                                root.browser.go(e.isDir ? e.path : col.dir);
                                if (!e.isDir) root.browser.selectPaths([e.path]);
                            } else if (e.isDir && mouse.button === Qt.LeftButton && !(mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier))) {
                                root.browser.go(e.path);
                                return;
                            } else {
                                if (mouse.button !== Qt.RightButton || !row.selected)
                                    root.browser.click(row.index, mouse.button === Qt.RightButton ? Qt.NoModifier : mouse.modifiers);
                            }
                            if (mouse.button === Qt.RightButton)
                                root.contextMenu(e, mapToItem(null, mouse.x, mouse.y));
                        }
                        onDoubleClicked: mouse => { if (!row.modelData.isDir) root.browser.activate(row.modelData); }
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
            Text {
                width: (parent ? parent.width : 300) - 40
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                text: root.previewEntry.name
                color: Theme.color.label
                font.family: Theme.fontText
                font.pixelSize: 15
                font.weight: Font.DemiBold
                font.variableAxes: ({ "wght": Font.DemiBold, "opsz": 17 })  // SF variable font: weight + text optical size
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
