import QtQuick
import Finder.Native
import HyprK
import "lib/files.js" as Files

// Get Info from the context menu. The Mac opens an Info window; hyprk shows the same facts in a popover at the
// pointer: icon, name, kind and size, then Created / Modified / Last opened (InfoRows) and Where. Fill the window
// with it and call show(path, x, y).
Popover {
    id: root
    property var entry: null
    bodyWidth: 260
    bodyHeight: col.implicitHeight + 2 * inset
    Item { id: spot; width: 1; height: 1 }
    function show(path, x, y) {
        entry = FileOps.info(path);
        spot.parent = root;
        spot.x = x; spot.y = y;
        openAt(spot);
    }
    Column {
        id: col
        width: parent.width
        spacing: 6
        Row {
            spacing: 10
            FileIcon { entry: root.entry || ({ name: "", path: "", isDir: false }); size: 48; visible: !!root.entry }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: col.width - 58
                TextLabel { width: parent.width; elide: Text.ElideMiddle; text: root.entry ? root.entry.name : ""; size: 13; weight: Typography.semibold }
                TextLabel {
                    width: parent.width; elide: Text.ElideRight; size: 11; color: Theme.color.secondaryLabel
                    text: !root.entry ? "" : root.entry.kind + (root.entry.isDir ? "" : " – " + Files.formatSize(root.entry.size, false))
                }
            }
        }
        InfoRows { width: col.width; entry: root.entry }
        TextLabel {
            width: col.width; elide: Text.ElideMiddle; size: 11; color: Theme.color.secondaryLabel
            text: root.entry ? "Where: " + Files.parentPath(root.entry.path) : ""
        }
    }
}
