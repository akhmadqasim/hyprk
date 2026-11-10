import QtQuick
import HyprK
import "lib/files.js" as Files

// Inline rename editor. Selects the base name (not the extension) like Finder.
// Return or focus loss commits, Escape cancels (Finder behaviour).
Rectangle {
    id: root

    required property var browser
    required property var entry
    property int horizontalAlignment: TextInput.AlignHCenter
    property real fontSize: Theme.font.label
    property bool multiLine: true

    implicitHeight: input.implicitHeight + 4
    color: Theme.color.fieldBg
    border.width: 2
    border.color: Theme.color.focusRing
    radius: 3

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
        anchors.margins: 2
        text: root.entry.name
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: TextInput.AlignVCenter
        wrapMode: root.multiLine ? TextInput.WrapAnywhere : TextInput.NoWrap
        clip: true
        color: Theme.color.label
        selectionColor: Theme.color.accent
        selectedTextColor: "white"
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
