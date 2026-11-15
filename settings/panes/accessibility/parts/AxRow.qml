import QtQuick
import "../../.."
import "../../../controls"
import "../../../HyprK"

// One row of an Accessibility sub-pane's group, at the Mac's AX frames (reference/re/27.2.1/live/settings-r12/
// ax-acc-*.jsonl): `h` is the row's height (label top to the next label top), the label sits `labelY` below the row's
// top (10), the description 18 below the label in 14 pt lines, and the trailing controls are centred on `ctlY`
// (the label's centre unless the dump says otherwise). info: the row's "Show Detail" button (17 x 17, 11.5 from the
// card's edge; the controls then end 40 in). A row without a label is a description beside a button.
Item {
    id: row
    property real h: 37.5
    property string label
    property string sub
    property string sub2             // a second paragraph (VoiceOver, Full Keyboard Access)
    property real sub2Y: 0
    property string link             // accent "Learn more…" under the description
    property real linkY: 0
    property string linkUrl
    property real labelY: 10
    // Qt puts a line's ink one device pixel above CoreText's at the same frame (measured on every acc-*-00-light.png at
    // 2x: -0.5 pt); a quarter point moves it onto the Mac's pixel row
    readonly property real _ink: 0.25
    property real labelWidth: 0      // 0: one line
    property real subWidth: 0        // 0: up to the controls
    property real ctlY: labelY + 8
    property real textX: iconId !== "" || iconSource !== "" ? 48 : Theme.content.rowPadding
    property string iconId
    property string iconSource
    property real iconSize: 26
    property string symbol           // a bare SF Symbol centred 18 in (Live Speech's categories)
    property real iconX: 11 + (26 - iconSize) / 2
    property real iconY: 12          // acc-voiceover-00-light.png: the 26 pt tile at 11, 12 in the card
    property color tint: Theme.tile.blue
    property bool dim: false
    property bool info: false
    property bool sep: true
    property real spacing: 8
    signal infoClicked()
    default property alias trailing: trail.data
    width: parent ? parent.width : 0
    height: h
    implicitHeight: h

    Rectangle {
        visible: row.sep && row.Positioner.index > 0
        x: Theme.content.separatorInset
        width: parent.width - 2 * x
        height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        color: Theme.separator
    }
    PaneIcon {
        visible: row.iconId !== "" || row.iconSource !== ""
        x: row.iconX; y: row.iconY
        size: row.iconSize; iconId: row.iconId; imageSource: row.iconSource; tint: row.tint
    }
    SfSymbol {
        visible: row.symbol !== ""
        x: 18 - width / 2; y: row.labelY + 8 - height / 2   // acc-live-speech-00-light.png: clock 16 x 16 at 10, 10
        name: row.symbol; pointSize: 16; color: Theme.label
    }
    Text {
        visible: row.label !== ""
        x: row.textX; y: row.labelY + row._ink
        width: row.labelWidth > 0 ? row.labelWidth : implicitWidth
        wrapMode: row.labelWidth > 0 ? Text.WordWrap : Text.NoWrap
        text: row.label
        font: Typography.body
        color: row.dim ? Tokens.control.disabledText : Theme.label
    }
    readonly property real _subW: subWidth > 0 ? subWidth + 1 : trail.x - textX - 10
    Text {
        visible: row.sub !== ""
        x: row.textX; y: (row.label !== "" ? row.labelY + 18 : row.labelY) + row._ink
        width: row._subW
        wrapMode: Text.WordWrap
        lineHeight: 14; lineHeightMode: Text.FixedHeight
        text: row.sub
        font: Typography.subheadline
        color: row.dim ? Tokens.control.disabledText : Theme.secondaryLabel
    }
    Text {
        visible: row.sub2 !== ""
        x: row.textX; y: row.sub2Y + row._ink
        width: row.subWidth > 0 ? row.subWidth + 1 : row.width - row.textX - 10
        wrapMode: Text.WordWrap
        lineHeight: 14; lineHeightMode: Text.FixedHeight
        text: row.sub2
        font: Typography.subheadline
        color: Theme.secondaryLabel
    }
    Text {
        visible: row.link !== ""
        x: row.textX; y: row.linkY + row._ink
        lineHeight: 14; lineHeightMode: Text.FixedHeight
        text: row.link
        font: Typography.subheadline
        color: Theme.accent
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (row.linkUrl !== "") Qt.openUrlExternally(row.linkUrl)
        }
    }
    Row {
        id: trail
        anchors.right: parent.right; anchors.rightMargin: row.info ? 40 : Theme.content.rowPadding
        y: row.ctlY - height / 2
        spacing: row.spacing
        onChildrenChanged: { for (const c of children) c.anchors.verticalCenter = trail.verticalCenter; }
    }
    Item {   // info.circle, the row's detail sheet
        visible: row.info
        x: parent.width - 11.5 - width; y: row.ctlY - height / 2
        width: 17; height: 17
        SfSymbol { anchors.centerIn: parent; name: "info.circle"; pointSize: 16.5; color: Theme.secondaryLabel }
        MouseArea { anchors.fill: parent; onClicked: row.infoClicked() }
    }
}
