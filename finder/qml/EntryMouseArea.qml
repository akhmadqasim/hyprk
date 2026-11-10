import QtQuick

// Press handling shared by every view's items (entry set) and empty space (entry null):
// left click selects with modifiers, right click selects if needed and asks for a menu,
// double click opens, dragging an item starts a drag of the selection (DragSession).
MouseArea {
    id: root

    required property var browser
    property var entry: null
    property int index: -1
    signal contextMenu(var entry, point pos)

    readonly property var dnd: browser.dragSession
    property point pressAt
    property bool dragging: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    preventStealing: dragging   // once an item drag runs, ListView must not take it for flicking
    property bool dragCancelled: false   // Esc: no new drag until the button goes up

    // a plain press on an already selected item keeps the selection (it may be dragged);
    // the click narrows it to this item on release if no drag happened
    property bool narrowOnRelease: false

    onPressed: mouse => {
        root.forceActiveFocus();
        const right = mouse.button === Qt.RightButton;
        pressAt = Qt.point(mouse.x, mouse.y);
        narrowOnRelease = false;
        dragCancelled = false;
        // Option (copy) and Ctrl+Option (alias) are drag modifiers, not selection modifiers
        const mods = mouse.modifiers & Qt.AltModifier ? mouse.modifiers & ~(Qt.AltModifier | Qt.ControlModifier) : mouse.modifiers;
        if (!entry) {
            if (right || !(mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier))) browser.clearSelection();
        } else if (!right && mods === Qt.NoModifier && browser.isSelected(entry.path)) {
            narrowOnRelease = true;
        } else if (!right || !browser.isSelected(entry.path)) {
            browser.click(index, right ? Qt.NoModifier : mods);
        }
        if (right) contextMenu(entry, mapToItem(null, mouse.x, mouse.y));
    }
    onPositionChanged: mouse => {
        if (!dnd || !entry || !(mouse.buttons & Qt.LeftButton)) return;
        const p = mapToItem(null, mouse.x, mouse.y);
        if (!dragging) {
            if (dragCancelled || Math.hypot(mouse.x - pressAt.x, mouse.y - pressAt.y) < 4 || !browser.canDrag) return;
            if (!browser.isSelected(entry.path)) return;   // a Ctrl-click that deselected it drags nothing
            dragging = true;
            narrowOnRelease = false;
            dnd.start(browser.selectedEntries(), p, mouse.modifiers);
        }
        dnd.move(p, mouse.modifiers);
    }
    function endDrag(drop) {
        dragging = false;
        if (drop) dnd.finish(); else dnd.cancel();
    }
    onReleased: {
        if (dragging) endDrag(true);
        else if (narrowOnRelease) browser.click(index, Qt.NoModifier);
        narrowOnRelease = false;
    }
    onCanceled: if (dragging) endDrag(false)
    onDoubleClicked: mouse => {
        if (entry && mouse.button === Qt.LeftButton) browser.activate(entry);
    }
    // Option / Control pressed or released without moving the pointer still switch the operation.
    // The modifier bit of the key itself is applied by hand: platforms disagree on whether it is set yet.
    function modifierBit(key) {
        return key === Qt.Key_Alt ? Qt.AltModifier : key === Qt.Key_Control ? Qt.ControlModifier
             : key === Qt.Key_Shift ? Qt.ShiftModifier : 0;
    }
    Keys.onPressed: event => {
        if (!dragging) { event.accepted = false; return; }
        if (event.key === Qt.Key_Escape) { dragCancelled = true; endDrag(false); }
        else dnd.modifiers = dnd.modifiers | event.modifiers | modifierBit(event.key);
    }
    Keys.onReleased: event => {
        if (!dragging) { event.accepted = false; return; }
        dnd.modifiers = (dnd.modifiers | event.modifiers) & ~modifierBit(event.key);
    }
}
