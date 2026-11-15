import QtQuick
import ".."
import "../HyprK"

// A row of the General sub-panes About, Storage and Software Update, placed by the Mac's own numbers (27.2.1
// live/settings-r12/ax-nav-general--{about,softwareUpdate,storage}-dark.jsonl): `rowHeight` of content under a 1 pt
// separator (none on a card's first row), so the pitch is rowHeight + 1; the label, the value and the controls centred
// on `centre` (from the content's top: 18 in a 36 pt row; Software Update's ⓘ rows are 38 with the centre still at 18).
// An optional picture `iconSize` wide at 10, the label 10 after it (About's 32 pt pictures) or `labelGap`.
Item {
    id: row
    property string label
    property string value
    property color valueColor: Theme.secondaryLabel
    property real rowHeight: 36
    property real centre: rowHeight / 2
    property string iconSource
    property real iconSize: 32
    property real labelGap: 10
    // the 13 pt text sits half a point lower than its centred box (the ink on the stills against ours)
    readonly property real inkDrop: 0.5
    property alias spacing: trail.spacing   // value to control: 8, or the Mac's own (the ⓘ rows: 11.5)
    default property alias trailing: trail.data
    property alias leading: lead.data    // drawn in the picture's place (Storage's glyph tiles)
    readonly property real sep: Positioner.index > 0 ? 1 : 0
    readonly property bool hasIcon: iconSource !== "" || lead.children.length > 0
    width: parent ? parent.width : 0
    implicitHeight: sep + rowHeight
    height: implicitHeight
    Rectangle {
        visible: row.sep > 0
        x: Theme.content.separatorInset; width: parent.width - 2 * x
        height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        color: Theme.separator
    }
    Item {
        id: lead
        x: Theme.content.rowPadding; y: row.sep + row.centre - row.iconSize / 2
        width: row.iconSize; height: row.iconSize
    }
    Image {
        id: picture
        visible: row.iconSource !== ""
        x: lead.x; y: lead.y; width: row.iconSize; height: row.iconSize
        source: row.iconSource
        sourceSize: Qt.size(Math.ceil(row.iconSize * 2), Math.ceil(row.iconSize * 2))
        fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true
    }
    Text {
        id: labelText
        x: Theme.content.rowPadding + (row.hasIcon ? row.iconSize + row.labelGap : 0)
        y: row.sep + row.centre - height / 2 + row.inkDrop
        width: Math.max(0, trail.x - x - 10); elide: Text.ElideRight
        text: row.label
        font: Typography.body
        color: Theme.label
    }
    Row {
        id: trail
        anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding
        y: row.sep + row.centre - height / 2
        spacing: 8
        Text {
            visible: row.value !== ""
            anchors.verticalCenter: parent.verticalCenter; anchors.verticalCenterOffset: row.inkDrop
            text: row.value
            font: Typography.body
            color: row.valueColor
        }
    }
}
