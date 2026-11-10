import QtQuick
import ".."
import "../HyprK"

// Grouped inset section: optional bold header, rounded card, optional footer.
Column {
    id: card
    property string title
    property string footer
    default property alias rows: body.data
    width: parent ? parent.width : 0
    spacing: Theme.content.headerGap

    SectionHeader { visible: card.title !== ""; text: card.title }
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
