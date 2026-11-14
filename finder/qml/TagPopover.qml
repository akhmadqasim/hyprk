import QtQuick
import HyprK

// Toolbar Edit Tags popover (Q-finder-25, reference/screens/27.2.1/finder/popover-*.png): drawn body 226 x 74 (the
// AX frame 252 x 99 includes the arrow and margins), arrow tip 7 pt under the button, the title "Assign tags to
// “name”" in 12 pt secondary, a 216 x 27 token field 5 pt in, with one tinted capsule per tag. Typing a
// tag name and Return adds it; Backspace in the empty field removes the last one. The suggestion table is not
// drawn (empty on the Mac too).
Popover {
    id: root
    required property var browser
    bodyWidth: 226
    bodyHeight: 74
    inset: 0
    anchorGap: 7
    readonly property var entries: browser.selectedVisible
    // tags every selected item has
    readonly property var common: entries.length === 0 ? [] : (entries[0].tags || []).filter(t => entries.every(e => (e.tags || []).indexOf(t) !== -1))

    function show(anchor) {
        input.text = "";
        openAt(anchor);
        input.forceActiveFocus();
    }
    function add(name) {
        const known = Theme.color.tags.find(t => t.name.toLowerCase() === name.trim().toLowerCase());
        const tag = known ? known.name : name.trim();
        if (tag && common.indexOf(tag) === -1) browser.toggleTag(tag);
        input.text = "";
    }

    Text {
        y: 5
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        text: "Assign tags to " + (root.entries.length === 1 ? "“" + root.entries[0].name + "”" : root.entries.length + " items")
        font: Typography.font(12)
        color: Tokens.secondaryLabel
    }
    Rectangle {
        y: 25
        x: 5
        width: 216
        height: 27
        radius: 6
        color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.8)
        border.width: 0.5
        border.color: Tokens.control.menuStroke
        Row {
            x: 4
            height: parent.height
            spacing: 3
            Repeater {
                model: root.common
                Rectangle {   // token: the tag colour tinted capsule with its name
                    required property string modelData
                    readonly property color tint: Theme.color.tagColors[modelData] || Theme.color.tagColors.Gray
                    anchors.verticalCenter: parent.verticalCenter
                    width: tokenText.implicitWidth + 8
                    height: 17
                    radius: 3
                    color: Qt.rgba(tint.r, tint.g, tint.b, Tokens.dark ? 0.3 : 0.15)
                    border.width: 0.5
                    border.color: Qt.rgba(tint.r, tint.g, tint.b, 0.5)
                    Text {
                        id: tokenText
                        anchors.centerIn: parent
                        text: parent.modelData
                        font: Typography.font(11)
                        color: Tokens.label
                    }
                }
            }
            TextInput {
                id: input
                TextMenu { target: input }   // the field editor's right-click menu (HyprK textmenu.js)
                width: 60
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                color: Tokens.label
                selectionColor: Accent.selectedText
                font: Typography.body
                Keys.onReturnPressed: root.add(text)
                Keys.onEnterPressed: root.add(text)
                Keys.onEscapePressed: root.close()
                Keys.onPressed: e => {
                    if (e.key === Qt.Key_Backspace && text === "" && root.common.length) {
                        root.browser.toggleTag(root.common[root.common.length - 1]);
                        e.accepted = true;
                    }
                }
            }
        }
    }
}
