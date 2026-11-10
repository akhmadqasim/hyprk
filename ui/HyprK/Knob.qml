import QtQuick
import QtQuick.Effects

// Knob of Switch and Slider (MAC-ANSWERS.md Q-settings-16..-18): a white capsule with two shadows (black a.10
// radius 12 y 3, black a.10 radius 2 y 1). Not glass at rest. While pressed (`lift` 0 .. 1) it grows by `grow`
// around its centre and cross-fades into a clear lens: the white fill's opacity is 1 - lift (Mac: 0.51 at half
// growth) and a light rim with a thin dark outline fades in (switch-press-strip-light.png). The lens's refraction
// (inner height 0.1D, amount -0.15D, displacement map) is not drawn: the track shows through unbent.
// Reduce Motion: no growth. Reduce Transparency: the fill stays white.
// Place it with cx / cy (its centre in the parent).
Item {
    id: k
    property real restW: 20
    property real restH: 16
    property real grow: Tokens.motion.switchLift
    property real lift: 0
    property real squash: 0                // > 0 flattens the knob while it lands against an end
    property bool reduceMotion: Tokens.reduceMotion
    property real cx: 0
    property real cy: 0

    readonly property real _s: 1 + (grow - 1) * (reduceMotion ? 0 : lift)
    readonly property real _fill: Tokens.reduceTransparency ? 1 : 1 - lift
    width: restW * _s * (1 + 0.25 * squash)
    height: restH * _s * (1 - 0.15 * squash)
    x: cx - width / 2
    y: cy - height / 2

    // the lens keeps a faint shadow (strip frames); fading the shadows also keeps them from greying the track
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 12; offset.y: 3
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * (1 - 0.7 * k.lift))
    }
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 2; offset.y: 1
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * (1 - 0.7 * k.lift))
    }
    Rectangle {
        id: body
        anchors.fill: parent
        radius: height / 2
        color: Qt.alpha(Tokens.control.knob, k._fill)
        // the lens edge: 0.5 pt grey outline (195 on 240 in the strip) and a white band inside it
        border.width: k.lift > 0 ? 0.5 : 0
        border.color: Qt.rgba(0, 0, 0, 0.2 * k.lift)
        Rectangle {
            visible: k.lift > 0 && k._fill < 1
            anchors.fill: parent; anchors.margins: 0.5
            radius: height / 2
            color: "transparent"
            border.width: 1.5
            border.color: Qt.rgba(1, 1, 1, 0.85 * k.lift)
        }
    }
}
