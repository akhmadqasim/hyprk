import QtQuick
import QtQuick.Window

// In-window Liquid Glass capsule (shaders/glasslens2.frag): draws what lies under it in `source`, bent near the rim,
// blurred, tinted, lit and outlined. Client windows cannot sample the desktop, so this only reaches content of the same window
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
    property real outlineWidth: 0.5   // pt
    // light (white mixed in): everywhere (haze), from the top edge fading out over diffuseTopDepth pt and from the
    // bottom edge over diffuseBottomDepth pt, and a key band just inside the rim line (keyTop on the top edge,
    // keyBottom on the bottom, keyEnds on the round ends, keyFalloff pt deep). The rim line shows the plain sample.
    property real haze: 0
    property real diffuseTop: 0
    property real diffuseTopDepth: 1
    property real diffuseBottom: 0
    property real diffuseBottomDepth: 1
    property real keyTop: 0
    property real keyBottom: 0
    property real keyEnds: 0
    property real keyFalloff: 1
    property color tint: "transparent"   // rgb + mix amount in alpha
    property color backdrop: "transparent"
    // true: a sample that falls outside `source` (the bent rim or the blur of a capsule near the source's edge) repeats
    // the source's edge pixel. false: it is empty there and the capsule is transparent over `backdrop` (a knob that
    // leaves its track). The Liquid Glass preview's capsules sit 7 pt from the article's top and right edge and bend
    // 12 pt: unclamped their top and right end were cut away (user report). Edge repeat itself is inferred, not measured
    property bool clampToSource: false
    readonly property real margin: Math.ceil(Math.abs(amount) + blur + 1)
    // a button's light (ToolbarHighlight): a disc of Tokens.toolbar.hoverDiscRadius round discCentre with discLift added,
    // and the colour times 1 + glowGain (1 - r / Tokens.toolbar.pressReach) round glowCentre (item px)
    property point discCentre: Qt.point(0, 0)
    property real discLift: 0
    property point glowCentre: Qt.point(0, 0)
    property real glowGain: 0
    // only draw the light the disc and the glow add (over the capsule as already drawn; give `backdrop` the opaque
    // colour under the capsule so the gain sees what is on screen)
    property bool additive: false

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
        fragmentShader: Qt.resolvedUrl("shaders/glasslens2.frag.qsb")
        property var source: tex
        property size size: Qt.size(g.width, g.height)
        property real margin: g.margin
        property real band: Math.max(0.01, g.band)
        property real amount: g.amount
        property real blur: g.blur
        property real gain: g.gain
        property real outline: g.outline
        property real outlineWidth: g.outlineWidth
        property real haze: g.haze
        property vector4d diffuse: Qt.vector4d(g.diffuseTop, g.diffuseTopDepth, g.diffuseBottom, g.diffuseBottomDepth)
        property vector4d key: Qt.vector4d(g.keyTop, g.keyBottom, g.keyFalloff, g.keyEnds)
        property vector4d tint: Qt.vector4d(g.tint.r, g.tint.g, g.tint.b, g.tint.a)
        property vector4d bounds: g.clampToSource && g.source
            ? Qt.vector4d(0.25 - g.origin.x, 0.25 - g.origin.y, g.source.width - g.origin.x - 0.25, g.source.height - g.origin.y - 0.25)
            : Qt.vector4d(-1e6, -1e6, 1e6, 1e6)
        property vector4d glow: Qt.vector4d(g.glowCentre.x, g.glowCentre.y, g.glowGain, Tokens.toolbar.pressReach)
        property vector4d disc: Qt.vector4d(g.discCentre.x, g.discCentre.y, Tokens.toolbar.hoverDiscRadius, g.discLift)
        property real discEdge: Tokens.toolbar.hoverDiscEdge
        property real additive: g.additive ? 1 : 0
        property vector4d backdrop: Qt.vector4d(g.backdrop.r * g.backdrop.a, g.backdrop.g * g.backdrop.a,
                                                g.backdrop.b * g.backdrop.a, g.backdrop.a)
    }
}
