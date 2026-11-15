import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"

// A Privacy & Security class (27.2.1, live/settings-r13/dest-privacyAndSecurity--<class>-{dark,light}.png, ax-dest-...):
//   "table"   one card: the class's line (13 pt, 10 pt in), then the + / − strip (Remove dimmed)   (App Management: strip 181)
//   "empty"   no card: the line centred in the pane, secondary                           (Calendars: ax 338.8,322.5 294.5 x 32)
// The Mac's applications are blurred / redacted on every capture, so none is listed (PrivacyData.js): the rows between
// the line and the strip are not drawn. No TCC here: + takes the press only (settings/FALLBACKS.md "Privacy & Security").
Column {
    id: page
    property var pane
    property var cls
    spacing: Theme.content.sectionGap

    Item {
        visible: page.cls.kind === "empty"
        width: parent.width; height: 573 - Theme.content.top - 20
        Text {
            objectName: "privacyEmpty"
            anchors.horizontalCenter: parent.horizontalCenter
            y: 322.5 - 52 - Theme.content.top - (lineCount > 2 ? 8 : 0)
            width: 300; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            lineHeight: 16; lineHeightMode: Text.FixedHeight
            text: page.cls.head
            font: Typography.body; color: Theme.secondaryLabel
        }
    }
    Card {
        visible: page.cls.kind !== "empty"
        Item {
            width: parent.width; height: head.height + 20 + 1   // ax: the list 37 (App Management) under the card top
            Text {
                id: head
                objectName: "privacyHead"
                x: 10; y: 10; width: parent.width - 20; wrapMode: Text.WordWrap
                lineHeight: 16; lineHeightMode: Text.FixedHeight
                text: page.cls.head
                font: Typography.body; color: Theme.secondaryLabel
            }
        }
        ListBar { visible: page.cls.kind === "table" }
    }
}
