import QtQuick

// Press handling shared by every view's items (entry set) and empty space (entry null):
// left click selects with modifiers, right click selects if needed and asks for a menu,
// double click opens.
MouseArea {
    id: root

    required property var browser
    property var entry: null
    property int index: -1
    signal contextMenu(var entry, point pos)

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onPressed: mouse => {
        root.forceActiveFocus();
        const right = mouse.button === Qt.RightButton;
        if (!entry) {
            if (right || !(mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier))) browser.clearSelection();
        } else if (!right || !browser.isSelected(entry.path)) {
            browser.click(index, right ? Qt.NoModifier : mouse.modifiers);
        }
        if (right) contextMenu(entry, mapToItem(null, mouse.x, mouse.y));
    }
    onDoubleClicked: mouse => {
        if (entry && mouse.button === Qt.LeftButton) browser.activate(entry);
    }
}
