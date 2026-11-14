import QtQuick
import HyprK
import "lib/files.js" as Files

// "Rename Finder Items" for a multi-selection (context menu Rename…), as a 27.2.1 sheet (Q-panels-34,
// reference/screens/27.2.1/finder/sheet-*.png): 489 pt wide, centred on the window, the window dimmed. Only the
// Replace Text mode is implemented: every occurrence of Find in each name is replaced.
Sheet {
    id: root
    required property var browser
    property var entries: []
    cardWidth: 489
    cardHeight: 161

    function open(list) {
        entries = list;
        find.text = "";
        replace.text = "";
        shown = true;
        find.input.forceActiveFocus();
    }
    function close() { shown = false; }
    function newName(name) { return find.text === "" ? name : name.split(find.text).join(replace.text); }
    function apply() {
        for (const e of entries) {
            const n = newName(e.name);
            if (n !== e.name && root.browser.rename(e, n) !== "") break;   // the alert shows the first error
        }
        close();
    }

    component Field: Rectangle {
        property alias text: field.text
        property alias input: field
        width: 160
        height: 26
        radius: 5
        color: Tokens.dark ? "#1E1E28" : "#FFFFFF"
        border.width: field.activeFocus ? 0 : 0.5
        border.color: Tokens.control.menuStroke
        FocusRing { visible: field.activeFocus }
        TextInput {
            id: field
            TextMenu { target: field }   // the field editor's right-click menu (HyprK textmenu.js)
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Tokens.label
            selectionColor: Accent.selectedText
            selectedTextColor: Tokens.label
            font: Typography.body
            Keys.onReturnPressed: root.apply()
            Keys.onEnterPressed: root.apply()
            Keys.onEscapePressed: root.close()
            Keys.onTabPressed: (field === find.input ? replace.input : find.input).forceActiveFocus()
        }
    }

    Text {
        x: 20; y: 4
        height: 20
        verticalAlignment: Text.AlignVCenter
        text: "Rename Finder Items:"
        font: Typography.body
        color: Tokens.secondaryLabel
    }
    Rectangle { y: 24; width: parent.width; height: 1; color: Tokens.control.menuStroke }
    Popup {
        x: 20; y: 34
        model: ["Replace Text"]
    }
    Row {
        x: 20; y: 64
        spacing: 8
        Text { height: 26; verticalAlignment: Text.AlignVCenter; text: "Find:"; font: Typography.body; color: Tokens.label }
        Field { id: find }
        Text { height: 26; verticalAlignment: Text.AlignVCenter; text: "Replace with:"; font: Typography.body; color: Tokens.label }
        Field { id: replace }
    }
    Rectangle { y: 120; width: parent.width; height: 1; color: Tokens.control.menuStroke }
    Text {
        x: 20
        y: 121
        width: 260
        height: 40
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideMiddle
        text: "Example: " + (root.entries.length ? root.newName(root.entries[0].name) : "")
        font: Typography.body
        color: Tokens.label
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 20
        y: 129
        spacing: 12
        Button { text: "Cancel"; width: 72; onClicked: root.close() }
        Button { text: "Rename"; width: 72; primary: true; onClicked: root.apply() }
    }
}
