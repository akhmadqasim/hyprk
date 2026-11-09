import QtQuick
import ".."

// Grouped inset section: optional bold header, rounded card, optional footer.
Column {
    id: card
    property string title
    property string footer
    default property alias rows: body.data
    width: parent ? parent.width : 0
    spacing: Theme.content.headerGap

    Text {
        visible: card.title !== ""
        leftPadding: Theme.content.rowPadding
        topPadding: Theme.content.headerTop
        text: card.title
        font.family: Theme.fontText; font.pixelSize: Theme.font.sectionHeader; font.weight: Theme.fw(Font.Bold); font.variableAxes: Theme.axes(Font.Bold)
        color: Theme.label
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
        font.family: Theme.fontText; font.pixelSize: Theme.font.small
        color: Theme.secondaryLabel
    }
}
