import QtQuick

// Drop target for an in-window Finder drag (DragSession): a folder in a view or a sidebar location.
// `path` is the destination folder, or "trash:" for the Trash.
DropArea {
    id: root

    required property var browser
    required property string path
    readonly property var dnd: browser.dragSession
    readonly property bool hovered: containsDrag && dnd !== null && dnd.target === path

    keys: ["hyprk-finder"]
    onEntered: drag => {
        if (!dnd || !dnd.accepts(path)) { drag.accepted = false; return; }
        dnd.enter(path, root);
    }
    onExited: if (dnd) dnd.leave(root)
}
