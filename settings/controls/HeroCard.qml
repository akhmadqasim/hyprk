import QtQuick
import ".."
import "../HyprK"

// Pane header card: big tile, title, description (General, Appearance, etc.).
// compact (27.2.1 Accessibility, accessibility-light.png): 64 tall, a 26 pt icon 10 in from the left, then the title
// (13 semibold) and a 2-line 11 pt description ending in a "Learn more…" link (linkActivated).
Rectangle {
    id: h
    property string glyph
    property string iconId
    property color tint: Theme.tile.blue
    property string title
    property string text
    property bool compact: false
    property string link: ""         // compact: link text after the description
    signal linkActivated()
    width: parent ? parent.width : 0
    height: compact ? Math.max(64, row.implicitHeight + 20) : Math.max(110, col.implicitHeight + 36)
    radius: Theme.content.cardRadius
    color: Theme.cardFill
    border.color: Theme.cardStroke
    Row {
        id: row
        visible: h.compact
        x: 10; y: 10
        spacing: 12
        PaneIcon { size: 26; glyph: h.glyph; iconId: h.iconId; tint: h.tint }
        Column {
            width: h.width - 10 - 26 - 12 - 10
            MacText { text: h.title; weight: Typography.semibold; color: Theme.label }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                textFormat: Text.RichText   // the link has no underline on the Mac
                text: h.text + (h.link ? " <a href=\"more\" style=\"text-decoration:none; color:" + Theme.accent + "\">" + h.link + "</a>" : "")
                font: Typography.subheadline
                color: Theme.secondaryLabel
                onLinkActivated: h.linkActivated()
                HoverHandler { cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor }
            }
        }
    }
    Column {
        id: col
        visible: !h.compact
        anchors.centerIn: parent
        width: parent.width - 60
        spacing: 6
        PaneIcon { anchors.horizontalCenter: parent.horizontalCenter; size: Theme.content.heroIcon; glyph: h.glyph; iconId: h.iconId; tint: h.tint }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: h.title
            size: 18; weight: Typography.bold   // TODO verify (not measured)
            color: Theme.label
        }
        Text {
            visible: h.text !== ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: h.text
            font: Typography.subheadline
            color: Theme.secondaryLabel
        }
    }
}
