import QtQuick
import QtQuick.Window

// In-window Liquid Glass capsule (shaders/lens.frag): draws what lies under it in `source`, bent near the rim, blurred,
// tinted and outlined. Client windows cannot sample the desktop, so this only reaches content of the same window
// (the pressed switch / slider knob over its track, the Appearance pane's Liquid Glass preview over its article).
// `origin` is the capsule's top-left in `source` coordinates (bound by the caller; a moving capsule or a scrolling
// source moves it). The texture is `band`-independent: it is `margin` larger on every side so the rim can bend in
// content from outside the capsule. Nothing runs while it is hidden (the texture is not live then).
Item {
    id: g
    property Item source
    property point origin: Qt.point(0, 0)
    property real band: Math.min(width, height) / 2
    property real amount: 0
    property real blur: 0
    property real gain: 1
    property real outline: 0
    property color tint: "transparent"   // rgb + mix amount in alpha
    property color backdrop: "transparent"
    readonly property real margin: Math.ceil(Math.abs(amount) + blur + 1)

    ShaderEffectSource {
        id: tex
        sourceItem: g.source
        live: g.visible && g.opacity > 0
        hideSource: false
        visible: false
        smooth: true
        sourceRect: Qt.rect(g.origin.x - g.margin, g.origin.y - g.margin, g.width + 2 * g.margin, g.height + 2 * g.margin)
        // at least 2 px per point: the rim minifies, a 1x texture smears the bent edges
        readonly property real k: Math.max(2, Screen.devicePixelRatio)
        textureSize: Qt.size(Math.ceil(sourceRect.width * k), Math.ceil(sourceRect.height * k))
    }
    ShaderEffect {
        anchors.fill: parent
        visible: g.source !== null && g.width > 0 && g.height > 0
        fragmentShader: Qt.resolvedUrl("shaders/lens.frag.qsb")
        property var source: tex
        property size size: Qt.size(g.width, g.height)
        property real margin: g.margin
        property real band: Math.max(0.01, g.band)
        property real amount: g.amount
        property real blur: g.blur
        property real gain: g.gain
        property real outline: g.outline
        property vector4d tint: Qt.vector4d(g.tint.r, g.tint.g, g.tint.b, g.tint.a)
        property vector4d backdrop: Qt.vector4d(g.backdrop.r * g.backdrop.a, g.backdrop.g * g.backdrop.a,
                                                g.backdrop.b * g.backdrop.a, g.backdrop.a)
    }
}
