import QtQuick
import HyprK
import "lib/files.js" as Files

// Inline rename editor. Selects the base name (not the extension) like Finder.
// Return or focus loss commits, Escape cancels (Finder behaviour).
// 27.2.1 (Q-finder-27): a white field with almost square corners, the base name selected in (186,214,251), a
// 3 pt accent a.5 focus ring outside (outer radius about 5) with a 0.5 pt darker inner edge; 16 tall in a list
// row, the label's size in the icon view.
Rectangle {
    id: root

    required property var browser
    required property var entry
    property int horizontalAlignment: TextInput.AlignHCenter
    property real fontSize: Theme.font.label
    property bool multiLine: true

    implicitHeight: multiLine ? input.implicitHeight + 2 : 16
    color: Theme.color.fieldBg
    radius: 1.5
    border.width: 0.5
    border.color: Theme.color.focusEdge

    Rectangle {   // focus ring outside the field
        anchors.fill: parent
        anchors.margins: -Tokens.control.focusRingWidth
        radius: 5
        color: "transparent"
        border.width: Tokens.control.focusRingWidth
        border.color: Theme.color.focusRing
    }

    property bool _done: false
    function finish(commit) {
        if (_done) return;
        _done = true;
        const name = input.text;
        browser.renamingPath = "";
        if (commit) browser.rename(entry, name);
    }

    TextInput {
        id: input
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        text: root.entry.name
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: TextInput.AlignVCenter
        wrapMode: root.multiLine ? TextInput.WrapAnywhere : TextInput.NoWrap
        clip: true
        color: Theme.color.label
        selectionColor: Theme.color.textSelection
        selectedTextColor: Theme.color.label
        selectByMouse: true
        font: Typography.font(root.fontSize)
        Keys.onReturnPressed: root.finish(true)
        Keys.onEnterPressed: root.finish(true)
        Keys.onEscapePressed: root.finish(false)
        onActiveFocusChanged: if (!activeFocus) root.finish(true)
        Component.onCompleted: {
            forceActiveFocus();
            select(0, Files.splitName(root.entry.name, root.entry.isDir).base.length);
        }
    }
}
