import QtQuick
import ".."

// Knob shared by MacSwitch and MacSlider (macOS 26/27 Liquid Glass controls).
// At rest: solid white capsule with a soft shadow. While held (glass -> 1) it swells and
// turns into a clear lens that refracts `source` (the control's track layer, a sibling
// in the same parent) through shaders/glassknob.frag.
// Place it with cx/cy (centre, parent coordinates). The item itself is the body plus a
// shadow margin, so it is larger than the visible knob.
Item {
    id: k
    required property Item source
    property real cx: 0
    property real cy: 0
    property real restW: 18
    property real restH: 18
    property real grow: 1.55          // width x restW when fully glass
    property real growH: 0.3          // extra height x restH when fully glass
    property real glass: 0            // drives size; may overshoot (springs)
    property real squash: 0           // >0 flattens the body when it lands against an end
    property real mag: 1.35           // track magnification in the lens centre
    property bool reduceTransparency: Theme.reduceTransparency
    property bool reduceMotion: false
    // Colour behind the track (the card row). The lens is opaque: it shows the refracted
    // track over this colour instead of the unrefracted pixels under it.
    property color backdrop: Qt.tint(Theme.windowBg, Theme.cardFill)

    readonly property real lens: Math.max(0, Math.min(1, glass))
    readonly property real _g: reduceMotion ? 0 : glass   // Reduce Motion: no swelling
    readonly property real bodyW: Math.max(restW * 0.9, restW * (1 + (grow - 1) * _g)) * (1 + 0.25 * squash)
    readonly property real bodyH: Math.max(restH * 0.9, restH * (1 + growH * _g)) * (1 - 0.15 * squash)
    readonly property int pad: 6

    width: bodyW + 2 * pad
    height: bodyH + 2 * pad
    x: cx - width / 2
    y: cy - height / 2

    ShaderEffectSource {
        id: grab
        // Only capture while the lens shows; at rest the knob is solid and needs no texture.
        sourceItem: k.lens > 0.001 && !k.reduceTransparency ? k.source : null
        sourceRect: Qt.rect(k.x - k.source.x, k.y - k.source.y, k.width, k.height)   // source is a sibling
        hideSource: false
        visible: false
        smooth: true
    }
    ShaderEffect {
        id: fx
        anchors.fill: parent
        visible: !k._fallback
        property var src: grab
        property size itemSize: Qt.size(width, height)
        property size bodySize: Qt.size(k.bodyW, k.bodyH)
        property real glass: k.lens
        property real clarity: k.reduceTransparency ? 0 : 1
        property real mag: k.mag
        property real refrHeight: k.bodyH * 0.3
        property real refrAmount: -k.bodyH * 0.28
        property real aberration: k.bodyH * 0.06
        property color backdrop: k.backdrop
        property real shadowAlpha: 0.2 - 0.1 * k.lens
        property real shadowRadius: 1.2 + 2.5 * k.lens
        property real shadowY: 0.8 + 1.2 * k.lens
        property real dark: Theme.dark ? 1 : 0
        fragmentShader: Qt.resolvedUrl("shaders/glassknob.frag.qsb")
    }
    // Fallback when shaders can't run (software renderer, load error): the solid knob.
    readonly property bool _fallback: GraphicsInfo.api === GraphicsInfo.Software || fx.status === ShaderEffect.Error
    Rectangle {
        visible: k._fallback
        anchors.centerIn: parent
        width: k.bodyW; height: k.bodyH; radius: height / 2
        color: Theme.knob
        border.color: Qt.rgba(0, 0, 0, 0.08)
    }
}
