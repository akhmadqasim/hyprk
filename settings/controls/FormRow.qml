import QtQuick
import ".."
import "../HyprK"

// One row inside a Card: optional icon, label (+ sublabel), trailing control.
Item {
    id: row
    property string label
    property string sublabel
    property string sublink          // link text after the sublabel (accent colour)
    property color subdot: "transparent"   // a status dot before the sublabel (Network: green Connected, red Not connected)
    property string iconId           // tile: a pane icon or a row icon (Panes.js), themes/icons/settings
    property string iconSource       // app icon image instead of the tile
    property string symbol           // or a bare SF Symbol (HyprK sfpaths.js) in symbolColor, no tile
    property color symbolColor: Theme.label
    property color tint: Theme.tile.blue
    property real iconSize: 20       // the Mac's row tile: 40 px at 2x (accessibility-light.png)
    property real iconX: Theme.content.rowPadding   // the tile's left edge in the card
    property real labelGap: 10       // tile to label
    property bool dim: false
    property string value            // gray trailing text, e.g. "Off"
    property bool alignTop: false    // tall rows (pickers) keep the label at the top, like macOS
    property real topY: 11           // the label's top in an alignTop row
    property real iconY: -1          // the tile's top (>= 0), else centred in the row
    property real sublabelWidth: 0   // the sublabel wraps at this width (0 = the room up to the control)
    property real leftInset: 0       // the label further in (Notifications' "when display is sleeping" rows: 31)
    // a row with a sublabel: 12 pt above the label and below the text (27.2.1 ax-desktop-dock / ax-spotlight-light.jsonl:
    // "Click wallpaper to show desktop" 12.6 below its row's top, "Show Related Content" 11.6 and 12 to the card's end;
    // ours were 8); the gap between the two texts: 1, or the row's own (Spotlight's linked descriptions 6.5 / 13.5)
    property real sublabelGap: 1
    // label top + text bottom padding of a row with a sublabel: 24 (above), or 20 in the sub-panes and sheets of
    // 27.2.1 (live/settings-r12 ax-nav-*: label 10 below the row's top, the next row's label 21 below the text)
    property real sublabelPad: 24
    property real sublabelLineHeight: 0   // fixed line height of the sublabel (0 = the font's own): 14 in the same places
    signal clicked()
    signal sublinkActivated()        // a click on the sublink
    property string helpAnchor: ""   // the sublink's macOS User Guide topic (HeroCard.helpAnchor)
    default property alias trailing: trail.data
    width: parent ? parent.width : 0
    // a row whose only control is a Switch is 37.5, others 38 (Q-settings-12)
    // (trail's first child is the value Text, so the control is children[1])
    readonly property bool _switchRow: row.value === "" && trail.children.length === 2
                                       && trail.children[1]._lift !== undefined && trail.children[1].value === undefined
    implicitHeight: Math.max(_switchRow ? Theme.content.switchRowHeight : Theme.content.rowHeight,
                             texts.implicitHeight + (row.sublabel !== "" ? row.sublabelPad : 16), trail.childrenRect.height + 12)
    height: implicitHeight

    Rectangle { // separator between rows: inset 10 on both sides, under the icon too (accessibility-light.png, Q-settings-12)
        visible: row.Positioner.index > 0
        x: Theme.content.separatorInset
        width: parent.width - x - Theme.content.separatorInset
        height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))   // exact, antialiased at a fractional scale like the Mac's downsample (HyprK pixel.js)
        antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
        color: Theme.separator
    }
    PaneIcon {
        id: icon
        visible: row.iconId !== "" || row.iconSource !== "" || row.symbol !== ""
        size: row.iconSize; iconId: row.iconId; tint: row.tint; imageSource: row.iconSource
        opacity: row.symbol !== "" ? 0 : 1
        x: row.iconX; y: row.iconY >= 0 ? row.iconY : (row.height - height) / 2
    }
    SfSymbol {   // size not measured on the Mac (no shot of a row with a bare symbol): the body size
        visible: row.symbol !== ""
        anchors.centerIn: icon
        name: row.symbol; pointSize: 13; color: row.symbolColor
    }
    Column {
        id: texts
        y: row.alignTop ? row.topY : (row.height - implicitHeight) / 2
        x: (icon.visible ? row.iconX + icon.width + row.labelGap : Theme.content.rowPadding) + row.leftInset
        width: trail.x - x - 10
        spacing: row.sublabelGap
        Text {   // a long label wraps, as the Mac's (Desktop & Dock "When switching to an application, ...": 2 lines, AX 32 tall)
            width: parent.width; wrapMode: Text.WordWrap; maximumLineCount: 3; elide: Text.ElideRight
            text: row.label
            font: Typography.body
            color: row.dim ? Theme.secondaryLabel : Theme.label
        }
        Text {
            visible: row.sublabel !== ""
            width: row.sublabelWidth > 0 ? Math.min(row.sublabelWidth, parent.width) : parent.width; wrapMode: Text.WordWrap
            lineHeight: row.sublabelLineHeight > 0 ? row.sublabelLineHeight : 1
            lineHeightMode: row.sublabelLineHeight > 0 ? Text.FixedHeight : Text.ProportionalHeight
            // a trailing link in the accent colour, no underline (Spotlight's "About Search & Privacy…")
            readonly property bool rich: row.sublink !== "" || row.subdot.a > 0
            readonly property string escaped: row.sublabel.replace(/&/g, "&amp;").replace(/</g, "&lt;")
            textFormat: rich ? Text.StyledText : Text.PlainText
            text: !rich ? row.sublabel
                : row.sublink === "" ? "<font color=\"" + row.subdot + "\">\u25CF</font> " + escaped
                : escaped.replace(/\n/g, "<br>") + " <font color=\"" + Theme.accent + "\">" + row.sublink.replace(/&/g, "&amp;") + "</font>"
            font: Typography.subheadline
            color: Theme.secondaryLabel
            Text {   // where the sublink is: the same text with a real anchor, never drawn (linkAt)
                id: linkProbe
                visible: row.sublink !== ""
                opacity: 0
                anchors.fill: parent; wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                text: parent.escaped.replace(/\n/g, "<br>") + " <a href=\"more\">" + row.sublink.replace(/&/g, "&amp;") + "</a>"
                font: Typography.subheadline
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: mouse => {
            const p = mapToItem(linkProbe, mouse.x, mouse.y);
            if (row.sublink === "" || linkProbe.linkAt(p.x, p.y) === "") { row.clicked(); return; }
            if (row.helpAnchor !== "") Qt.openUrlExternally("https://support.apple.com/guide/mac-help/" + row.helpAnchor + "/mac");
            row.sublinkActivated();
        }
    }
    Row {
        id: trail
        anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding
        // with a sublabel the control sits on the label's line, not the row's centre (ax-desktop-dock-light.jsonl:
        // "Close windows when quitting an application" text 1058.0, its switch 1058.5; "Click wallpaper to show desktop"
        // 530.6 + 8 = 538.6, its pop-up's centre 539)
        y: row.alignTop ? row.topY : row.sublabel !== "" ? texts.y + 8 - height / 2 : (row.height - height) / 2
        spacing: 8
        Text {
            visible: row.value !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: row.value
            font: Typography.body
            color: Theme.secondaryLabel
        }
    }
}
