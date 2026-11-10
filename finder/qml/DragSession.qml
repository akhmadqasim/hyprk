import QtQuick
import HyprK
import Finder.Native
import "lib/files.js" as Files

// In-window drag and drop of Finder items, macOS style. Started by EntryMouseArea once the pointer
// moves 4 px with the button down. It is a Qt Quick internal drag (Drag.Internal on the drag image),
// not a Wayland one: Hyprland forces its "grabbing" cursor during Wayland DnD, macOS shows the arrow.
//   cursor   arrow; arrow + green "+" (copy) with Option or across volumes; alias arrow with Ctrl+Option
//   image    translucent icon stack of the dragged items, name under it, red count badge when > 1
//   targets  folders in the view and sidebar locations (DropArea with keys ["hyprk-finder"])
Item {
    id: root

    required property var browser
    property real iconSize: 64

    property bool active: false
    property var entries: []
    property var dragged: ({})        // path -> true, so a folder cannot be dropped on itself
    property var parents: ({})        // folders the items come from: dropping there would do nothing
    property string target: ""        // folder under the pointer ("trash:" for the Trash)
    property var targetArea: null
    property bool crossDevice: false  // target on another filesystem: Finder copies instead of moving
    property int modifiers: Qt.NoModifier

    readonly property string op: !target ? ""
        : target === "trash:" ? "trash"
        : (modifiers & Qt.AltModifier) && (modifiers & Qt.ControlModifier) ? "link"
        : (modifiers & Qt.AltModifier) || crossDevice ? "copy"
        : "move"
    readonly property int cursorShape: op === "copy" ? Qt.DragCopyCursor : op === "link" ? Qt.DragLinkCursor : Qt.ArrowCursor

    function accepts(path) {
        return active && path !== "" && dragged[path] !== true && !(Object.keys(parents).length === 1 && parents[path]);
    }
    function enter(path, area) {
        // one stat pair per target entered, not per binding evaluation
        crossDevice = path !== "trash:" && !FileOps.sameDevice(entries[0].path, path);
        target = path;
        targetArea = area;
    }
    function leave(area) { if (targetArea === area) { target = ""; targetArea = null; } }

    function start(list, scenePos, mods) {
        if (list.length === 0) return;
        const d = {}, from = {};
        for (const e of list) { d[e.path] = true; from[Files.parentPath(e.path)] = true; }
        entries = list;
        dragged = d;
        parents = from;
        home.stop();
        image.opacity = 1;
        active = true;
        move(scenePos, mods);
        origin = Qt.point(image.x, image.y);
    }
    function move(scenePos, mods) {
        if (!active) return;
        modifiers = mods;
        image.x = scenePos.x - image.Drag.hotSpot.x;
        image.y = scenePos.y - image.Drag.hotSpot.y;
    }
    function _end() {
        active = false;    // Drag.active goes false first, so DropAreas see the drag end
        target = "";
        targetArea = null;
    }
    // Drops on the target under the pointer; without one the image slides back like Finder's "zip back".
    function finish() {
        if (!active) return;
        const paths = entries.map(e => e.path), dest = target, how = op;
        _end();
        if (!how) { home.start(); return; }
        image.opacity = 0;
        browser.drop(paths, dest, how);
    }
    function cancel() {
        if (!active) return;
        _end();
        home.start();
    }

    // Qt picks the cursor of the topmost item under the pointer, not of the grabbing one:
    // this button-less layer over the whole window carries the drag cursor
    MouseArea {
        anchors.fill: parent
        visible: root.active
        acceptedButtons: Qt.NoButton
        cursorShape: root.cursorShape
    }

    property point origin
    ParallelAnimation {
        id: home
        NumberAnimation { target: image; property: "x"; to: root.origin.x; duration: 220; easing.type: Easing.OutCubic }
        NumberAnimation { target: image; property: "y"; to: root.origin.y; duration: 220; easing.type: Easing.OutCubic }
        NumberAnimation { target: image; property: "opacity"; to: 0; duration: 220; easing.type: Easing.InQuad }
    }

    Item {
        id: image
        visible: root.active || home.running
        width: root.iconSize + 3 * 4
        height: root.iconSize + 3 * 4 + 22
        Drag.active: root.active
        Drag.keys: ["hyprk-finder"]
        Drag.source: root
        Drag.hotSpot: Qt.point(root.iconSize / 2, root.iconSize / 2)

        Repeater {   // up to 4 icons, the grabbed selection fanned slightly like Finder's stack
            model: root.entries.slice(0, 4).reverse()
            FileIcon {
                required property var modelData
                required property int index
                readonly property int depth: Math.min(root.entries.length, 4) - 1 - index
                entry: modelData
                size: root.iconSize
                x: depth * 4
                y: depth * 4
                opacity: 0.62
            }
        }
        Text {
            y: root.iconSize + 4
            width: Math.max(root.iconSize + 40, implicitWidth)
            x: (root.iconSize - width) / 2
            horizontalAlignment: Text.AlignHCenter
            text: root.entries.length > 0 ? root.entries[0].name : ""
            elide: Text.ElideMiddle
            maximumLineCount: 1
            color: Theme.color.label
            opacity: 0.62
            font: Typography.font(Theme.font.label)
        }
        Rectangle {   // count badge, like the red Finder drag badge
            visible: root.entries.length > 1
            x: root.iconSize - width / 2 - 2
            y: -height / 3
            height: 20
            width: Math.max(height, count.implicitWidth + 12)
            radius: height / 2
            color: "#FF3B30"
            Text {
                id: count
                anchors.centerIn: parent
                text: root.entries.length
                color: "white"
                font: Typography.font(13, Typography.semibold)
            }
        }
    }
}
