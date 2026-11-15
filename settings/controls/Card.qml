import QtQuick
import ".."
import "../HyprK"

// Grouped inset section: optional bold header, rounded card, optional footer.
Column {
    id: card
    property string title
    property string footer
    property string subtitle
    property bool titleRegular: false     // the heading in the body weight (27.2.1 FileVault's "Password Reset")
    property real subtitleWidth: 0        // the subtitle wraps at this width (0 = the card's)
    property real subtitleLineHeight: 0   // fixed line height of the subtitle (0 = the font's own); 14 in a 27.2.1 sheet
    default property alias rows: body.data
    width: parent ? parent.width : 0
    spacing: Theme.content.headerGap

    // the pane's first heading sits right at the content top (12 below the toolbar); later ones 30 below a card
    SectionHeader { visible: card.title !== ""; text: card.title; regular: card.titleRegular; topPadding: card.Positioner.index > 0 ? Theme.content.headerTop : 0 }
    // a line under the heading (27.2.1 Desktop & Dock > Mission Control: 11 pt secondary, 1.5 pt under the 16 pt heading,
    // the card 9 below it; ax-desktop-dock-light.jsonl 1303 / 1320.5 + 28 / ~1357.5). Drawn 1.5 under, the card 10 below
    Text {
        visible: card.subtitle !== ""
        width: card.subtitleWidth > 0 ? Math.min(card.width, card.subtitleWidth + leftPadding + rightPadding) : card.width
        topPadding: 1.5 - card.spacing
        leftPadding: Theme.content.rowPadding
        rightPadding: Theme.content.rowPadding
        wrapMode: Text.WordWrap
        lineHeight: card.subtitleLineHeight > 0 ? card.subtitleLineHeight : 1
        lineHeightMode: card.subtitleLineHeight > 0 ? Text.FixedHeight : Text.ProportionalHeight
        text: card.subtitle
        font: Typography.subheadline
        color: Theme.secondaryLabel
    }
    Rectangle {
        width: card.width
        height: body.implicitHeight
        radius: Theme.content.cardRadius
        color: Theme.cardFill
        border.color: Theme.cardStroke
        Column { id: body; width: parent.width }
    }
    Text {
        visible: card.footer !== ""
        width: card.width
        leftPadding: Theme.content.rowPadding
        rightPadding: Theme.content.rowPadding
        wrapMode: Text.WordWrap
        text: card.footer
        font: Typography.subheadline
        color: Theme.secondaryLabel
    }
}
