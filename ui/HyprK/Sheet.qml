import QtQuick
import QtQuick.Effects
import "panels.js" as P

// Window sheet as on macOS 27.2.1 (MAC-ANSWERS.md Q-panels-34; MAC-ANSWERS-17.md R17.4, TextEdit's save sheet): a card
// centred on the parent window (not hung from the titlebar). The whole parent, titlebar included, fades towards a grey
// under a veil (Tokens.panel.sheetDim), sharp: no blur. The window's lights stay above the veil, close greyed out
// (`lights`). A custom sheet is solid windowBackground with a continuous r 16 and no titlebar; an alert sheet is an
// AlertPanel { sheet: true } with `bare` set (it draws its own r 26 body). In 0.27 s, out 0.25 s, linear, size
// constant (LIVE-27.2.1.md, R17.4).
// Fill the parent window with it; children go into the centred card. Clicks outside the card are swallowed.
Item {
    id: root
    property bool shown: false
    property bool bare: false            // no card fill: the content draws its own body (alert sheet)
    property real cardWidth: 440
    property real cardHeight: 220
    // the card's top in the parent, when the caller places it (System Settings' sheets: settings/controls/SubSheet.qml);
    // not set: centred (panels.js sheetRect)
    property real cardY: NaN
    default property alias content: card.data
    readonly property Item card: card
    // the parent's veil, the card's fill, and items drawn over the parent under the veil
    property color dimColor: Tokens.panel.sheetDim
    property color fillColor: Tokens.panel.sheetFill
    property alias underlay: under.data
    // items over the veil and under the card, with input
    property alias overlay: over.data
    // what the sheet covers, when it is one item: drawn without saturation under the veil (System Settings' panes lose
    // every accent colour, R13; the window's wallpaper tint stays). Not set: the veil alone (it leaves .396 of a
    // colour's spread)
    property Item behind: null
    // only from this x on (System Settings: right of the sidebar, whose tiles keep their colours under a sheet)
    property real behindLeft: 0
    // the window's TrafficLights. The veil leaves the three discs out: under a sheet close reads exactly what an
    // inactive window's does and minimise and zoom exactly what the active window's do, over the bar as it was (R17.4
    // alert-*.png against {in,}active-titlebar-*.png, 11 x 11 px means: light (242,242,244) (245,203,88) (152,213,111),
    // dark (75,75,79) (243,194,34) (93,189,33) with the bar veiled 39 -> 27 around them; Finder sheet-*.png and
    // settings-r13 clock-options the same for minimise and zoom, close (229,231,234) / (73,74,87) over their sidebars:
    // the inactive disc is a layer, and what shows through it is the sidebar as it was, neither veiled nor greyed:
    // dark white .17 over (35,37,52) = (72,74,87); so `behind` must not cover the bar under the lights).
    // So: holes in the veil over the discs, the window's own set faded out with the sheet's fade, and a second set
    // in the holes with close disabled, minimise and zoom live
    property Item lights: null
    // the card's shadow (PanelShadow sigma / density / offsetY; 0 / -1 / 8 = the glass recipe's)
    property real shadowSigma: Tokens.panel.sheetShadowSigma
    property real shadowDensity: Tokens.panel.sheetShadowDensity
    property real shadowOffsetY: Tokens.panel.sheetShadowOffsetY

    visible: shown || opacity > 0
    opacity: 0
    onShownChanged: shown ? (fadeOut.stop(), fadeIn.restart()) : (fadeIn.stop(), fadeOut.restart())
    Component.onCompleted: if (shown) opacity = 1
    NumberAnimation { id: fadeIn; target: root; property: "opacity"; to: 1; duration: Tokens.panel.sheetIn }
    NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: Tokens.panel.sheetOut }

    ShaderEffectSource {
        id: behindCopy
        visible: false
        x: root.behindLeft; width: parent.width - x; height: parent.height
        sourceItem: root.visible ? root.behind : null
        sourceRect: Qt.rect(x, 0, width, height)
    }
    // without saturation, but for the window's faint wallpaper tint (shaders/sheetbehind.frag: chroma under 14 levels
    // stays, over 40 goes). It was MultiEffect saturation -1: the dark pane read (24,24,24) under a sheet, the Mac's
    // (24,26,29)
    ShaderEffect {
        visible: root.behind !== null
        x: behindCopy.x; width: behindCopy.width; height: behindCopy.height
        property var source: behindCopy
        property vector2d keep: Qt.vector2d(14 / 255, 40 / 255)
        fragmentShader: Qt.resolvedUrl("shaders/sheetbehind.frag.qsb")
    }
    Item { id: under; anchors.fill: parent }
    Rectangle {   // the parent's veil
        id: veil
        anchors.fill: parent
        color: root.dimColor
        radius: Tokens.frame.radius
        layer.enabled: over2.own !== null
        layer.effect: MultiEffect { maskEnabled: true; maskSource: holes; maskInverted: true }
    }
    Item {
        id: holes
        anchors.fill: parent
        visible: false
        layer.enabled: over2.own !== null
        Repeater {
            model: over2.own ? 3 : 0
            Rectangle {
                required property int index
                width: Tokens.lights.size; height: width; radius: width / 2
                x: over2.at.x + index * (Tokens.lights.size + Tokens.lights.spacing); y: over2.at.y
                color: "black"
            }
        }
    }
    Binding { target: root.lights; property: "opacity"; value: 1 - root.opacity; when: root.visible && root.lights !== null }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onWheel: w => w.accepted = true }

    TrafficLights {
        id: over2
        readonly property Item own: root.visible ? root.lights : null
        readonly property point at: own ? own.mapToItem(root, 0, 0) : Qt.point(0, 0)
        visible: own !== null
        x: at.x; y: at.y
        closeEnabled: false
        active: own ? own.active : true
        zoomEnabled: own ? own.zoomEnabled : true
        fullScreenButton: own ? own.fullScreenButton : true
        onMinimizeClicked: own.minimizeClicked()
        onZoomClicked: own.zoomClicked()
        onFullScreenClicked: own.fullScreenClicked()
    }
    Item { id: over; anchors.fill: parent }
    PanelShadow {
        visible: !root.bare; x: card.x; y: card.y; width: card.width; height: card.height; cornerRadius: card.radius
        sigma: root.shadowSigma; density: root.shadowDensity; offsetY: root.shadowOffsetY
    }
    Rectangle {
        id: card
        readonly property var r: P.sheetRect(root.width, root.height, root.cardWidth, root.cardHeight)
        x: r.x; y: isNaN(root.cardY) ? r.y : root.cardY; width: r.width; height: r.height
        radius: Tokens.panel.sheetRadius
        color: root.bare ? "transparent" : root.fillColor
        border.width: root.bare ? 0 : 0.5
        border.color: Tokens.control.menuStroke
    }
}
