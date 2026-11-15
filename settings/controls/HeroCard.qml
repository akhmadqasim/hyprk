import QtQuick
import ".."
import "../HyprK"

// Pane header card: big tile, title, description (General, Appearance, etc.).
// compact (27.2.1 Accessibility, accessibility-light.png): 64 tall, a 26 pt icon 10 in from the left, then the title
// (13 medium) and a 2-line 11 pt description ending in a "Learn more…" link (linkActivated).
Rectangle {
    id: h
    property string iconId
    property color tint: Theme.tile.blue
    property string title
    property string text
    property bool compact: false
    property string link: ""         // compact: link text after the description
    // the link's topic in the macOS User Guide (the Mac's AX identifier "help:anchor=<id> bookID=com.apple.machelp"; the
    // Mac opens it in its help viewer, here the same topic of the guide's web edition)
    property string helpAnchor: ""
    signal linkActivated()
    width: parent ? parent.width : 0
    // full (27.2.1 General, ax-general-light.jsonl: card 164 at y 12): the 50 pt tile 25.5 below the top, the title
    // (22 pt bold, frame 26) 10.5 under it, the 13 pt description (16 pt lines, 448 wide) right under that, 20 to the end
    height: compact ? Math.max(64, row.implicitHeight + 20) : col.implicitHeight + 25.5 + 20
    radius: Theme.content.cardRadius
    color: Theme.cardFill
    border.color: Theme.cardStroke
    Row {
        id: row
        visible: h.compact
        x: 10; y: 10
        spacing: 12
        PaneIcon { size: 26; iconId: h.iconId; tint: h.tint }
        Column {
            width: h.width - 10 - 26 - 12 - 10
            // 13 Medium: the title's ink is 150 px at 2x on the Mac (accessibility-light.png), semibold measured 159
            MacText { text: h.title; weight: Typography.medium; color: Theme.label }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                textFormat: Text.RichText   // the link has no underline on the Mac
                text: h.text + (h.link ? " <a href=\"more\" style=\"text-decoration:none; color:" + Theme.accent + "\">" + h.link + "</a>" : "")
                font: Typography.subheadline
                color: Theme.secondaryLabel
                onLinkActivated: { if (h.helpAnchor !== "") Qt.openUrlExternally("https://support.apple.com/guide/mac-help/" + h.helpAnchor + "/mac"); h.linkActivated(); }
                HoverHandler { cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor }
            }
        }
    }
    Column {
        id: col
        visible: !h.compact
        x: 10; y: 25.5
        width: parent.width - 20
        // general-00-light.png: tile ink 922..1021 px (50 pt), title ink 79 pt wide (AX 80 x 26), description 2 lines
        PaneIcon { anchors.horizontalCenter: parent.horizontalCenter; size: Theme.content.heroIcon; iconId: h.iconId; tint: h.tint }
        Item { width: 1; height: 10.5 }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: h.title
            size: 22; weight: Typography.bold
            color: Theme.label
        }
        Text {
            visible: h.text !== ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            lineHeight: 16; lineHeightMode: Text.FixedHeight
            text: h.text
            font: Typography.body
            color: Theme.secondaryLabel
        }
    }
}
