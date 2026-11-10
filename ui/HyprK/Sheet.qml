import QtQuick
import "panels.js" as P

// Window sheet as on macOS 27.2.1 (MAC-ANSWERS.md Q-panels-34): centred on the parent window (not hung from the
// titlebar), the whole parent, titlebar included, dimmed about 20 %. A custom sheet is solid windowBackground
// with a continuous r 16 and no titlebar; an alert sheet is an AlertPanel { sheet: true } with `bare` set (it
// draws its own r 26 body). In 0.27 s, out 0.25 s, near-linear, size constant (LIVE-27.2.1.md).
// Fill the parent window with it; children go into the centred card. Clicks outside the card are swallowed.
Item {
    id: root
    property bool shown: false
    property bool bare: false            // no card fill: the content draws its own body (alert sheet)
    property real cardWidth: 440
    property real cardHeight: 220
    default property alias content: card.data
    readonly property Item card: card

    visible: shown || opacity > 0
    opacity: 0
    onShownChanged: shown ? (fadeOut.stop(), fadeIn.restart()) : (fadeIn.stop(), fadeOut.restart())
    Component.onCompleted: if (shown) opacity = 1
    NumberAnimation { id: fadeIn; target: root; property: "opacity"; to: 1; duration: Tokens.panel.sheetIn }
    NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: Tokens.panel.sheetOut }

    Rectangle {   // parent dim
        anchors.fill: parent
        color: Tokens.panel.sheetDim
        radius: Tokens.frame.radius
    }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: w => w.accepted = true }

    Rectangle {
        id: card
        readonly property var r: P.sheetRect(root.width, root.height, root.cardWidth, root.cardHeight)
        x: r.x; y: r.y; width: r.width; height: r.height
        radius: Tokens.panel.sheetRadius
        color: root.bare ? "transparent" : Tokens.panel.sheetFill
        border.width: root.bare ? 0 : 0.5
        border.color: Tokens.control.menuStroke
    }
}
