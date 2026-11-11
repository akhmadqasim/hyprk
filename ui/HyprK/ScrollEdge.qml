import QtQuick

// AppKit 27.2.1's scroll pocket: the strip under a window toolbar where scrolled content passes (NSScrollPocket,
// reference/re/27.2.1/live/toolbar/toolbar-unified-{light,dark}.json). Layer 1 (a variableBlur) pulls the content
// towards a 16 pt blur of itself, lighten / darken / normal at .6 / .4 / .25 (light) and .4 / .6 / 0 (dark), then
// saturation x1.25 (its colour matrix: 1.197 on red = 0.2126 (1 - 1.25) + 1.25); layer 2 (opacity .5 light / .6
// dark, its colour matrix cut off in the dump) reads as a flat pocket colour laid over that. Fitted on the Mac's
// appearance-scroll-250-{light,dark}.png (ICC converted) with our own frame of the same scroll as the input, over the
// preview photo under the 52 pt band: the effect is even over the band (a per-row fit gives layer 1 at 1 and layer 2
// within .5-.6 in every row), blur sigma 8 pt (16 pt radius). The pocket colour: over plain window and card the Mac's
// band reads 255 / 255 in light (window 255, card 247) and (39,40,45) / (41,42,48) in dark (window (30,31,36), card
// (37,38,43)): white at .55 in light, (42,42,47) at .6 in dark (the dump's opacity; the colour solved at it). rms over
// the photo: light 118.6 -> 10.8 levels, dark 53.3 -> 8.9 (model).
// Put it over the band, with `source` the scrolled item (a sibling under it, not a parent); it draws only while
// `active`. Reduce Transparency: the plain window colour (the caller's veil is not needed then).
Item {
    id: e
    property Item source
    property bool active: true
    property bool dark: Tokens.dark
    property color windowColor: "white"
    property real sigma: 8
    property real lighten: dark ? 0.4 : 0.6
    property real darken: dark ? 0.6 : 0.4
    property real normal: dark ? 0 : 0.25
    property real saturation: 1.25
    property real veil: dark ? 0.6 : 0.55
    property color veilColor: dark ? Qt.rgba(42 / 255, 42 / 255, 47 / 255, 1) : "white"
    property real cornerRadius: 0      // the top-right corner (a window corner the band reaches)
    readonly property real margin: Math.ceil(2.5 * sigma)
    visible: active && source !== null

    // the band's rect in the source's coordinates
    readonly property point _o: source ? mapToItem(source, 0, 0) : Qt.point(0, 0)
    readonly property rect _rect: Qt.rect(_o.x - margin, _o.y - margin, width + 2 * margin, height + 2 * margin)

    ShaderEffectSource {
        id: sharp
        sourceItem: e.source
        live: e.visible
        hideSource: false
        visible: false
        sourceRect: e._rect
        textureSize: Qt.size(Math.ceil(e._rect.width * Screen.devicePixelRatio), Math.ceil(e._rect.height * Screen.devicePixelRatio))
    }
    ShaderEffectSource {
        id: soft
        sourceItem: e.source
        live: e.visible
        hideSource: false
        visible: false
        smooth: true
        sourceRect: e._rect
        textureSize: Qt.size(Math.ceil(e._rect.width / 2), Math.ceil(e._rect.height / 2))
    }
    ShaderEffect {
        anchors.fill: parent
        visible: !Tokens.reduceTransparency
        fragmentShader: Qt.resolvedUrl("shaders/scrolledge.frag.qsb")
        property var sharp: sharp
        property var soft: soft
        property size size: Qt.size(e.width, e.height)
        property real margin: e.margin
        property real sigma: e.sigma
        property real lighten: e.lighten
        property real darken: e.darken
        property real normal: e.normal
        property real saturation: e.saturation
        property real veil: e.veil
        property real cornerRadius: e.cornerRadius
        property vector4d windowColor: Qt.vector4d(e.windowColor.r, e.windowColor.g, e.windowColor.b, 1)
        property vector4d veilColor: Qt.vector4d(e.veilColor.r, e.veilColor.g, e.veilColor.b, 1)
        // the content's own edges: sampling stops there (the source's top is the band's top)
        property vector4d bounds: e.source ? Qt.vector4d(-e._o.x, -e._o.y, e.source.width - e._o.x, e.source.height - e._o.y)
                                           : Qt.vector4d(0, 0, 1, 1)
    }
    Rectangle {
        anchors.fill: parent
        visible: Tokens.reduceTransparency
        color: e.windowColor
        topRightRadius: e.cornerRadius
    }
}
