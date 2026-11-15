import QtQuick

// AppKit 27.2.1's scroll pocket under a window toolbar: the "ThinFilm" pocket a toolbar's scroll view gets
// (NSScrollPocket builder sub_18b45e6d8, -[NSToolbarView _scrollPocketElementStyle] 0x18ad147cc = 2; decode in
// reference/re/27.2.1/TOOLBAR-REA-27.2.1.md 1, layer dump live/toolbar/toolbar-unified-{light,dark}.json). Bottom to top:
// - ThinFilmBackgroundReplay: the background behind the scrolled content replayed over it at opacity 0.6 dark / 0.5
//   light (dump), its saturation 1.25 - 0.25 / opacity (0x18b45ed94: .833 / .75, bias 0). The background's colour is
//   not in the dump: solved from the Mac's band over plain window / card (appearance-scroll-250-*.png, earlier fit:
//   dark window (30,31,36) -> (39,40,45), card (37,38,43) -> (41,42,48): (46,46,50); light 255 / 247 -> 255: white).
// - ThinFilmContentBlurFill: a variableBlur of inputRadius 2 pt (+0.5 x clamp((h - 52) / 38), 0x18b45efd0) times the
//   mask's red ramp R (1 at the band's top easing to 0.25 at its bottom, 0x18b45f070, mask 1 x 256 built by
//   0x18b495384), with the blur fill (radius 16, darken / lighten / normal .6 / .4 / 0 dark, .4 / .6 / .25 light:
//   0x18b45ed44), then saturation x1.25 and a clamp. CA's radius convention is not decoded: sigma = radius fits the Mac
//   (the variable blur 2 pt -> 0.5 pt, the fill 16 pt) better than sigma = radius / 2.
// FITTED: the replay opacity. Mac-to-Mac over the preview photo (appearance-scroll-000 rows 250..302 pt as the input,
// appearance-scroll-250 as the target, x 450..695 pt, no colour conversion): rms dark 6.4 at the dumped 0.6, 3.0 at
// 0.7; light 9.4 at 0.5, 6.8 at 0.55 (the old even-blur model: 9.2 / 10.8). The opacity and the unknown background
// colour trade off; TOOLBAR-REA-27.2.1.md 1. The dark background was solved at the dumped 0.6; at the fitted 0.7 it is
// (43,43.5,48.5): least squares over the two Settings points above and Finder's band over its plain content
// (finder/scrolled-under-toolbar-icon-dark.png, (31,31,36) -> (39.3,39.4,45.1)), rms 0.3 levels (the old (46,46,50)
// at 0.7 gave (41.5,41.5,46.3), 2 levels light). GLASS-HIG.md round 10.
// FITTED: light `normal` 0.7 (dump 0.25). With both blurs reading only the band (as below), the dumped 0.25 left the
// Mac's light pocket too clear at its bottom: Finder's thumbnail tops 1 pt inside the band (rim (229,125,122)) show
// G 247 on the Mac (finder/scrolled-under-toolbar-icon-light.png row 103 px), 236 in the model; the grey icon shadow
// above them 255 on the Mac, 250 in the model. A least-squares sweep over that strip and the Settings photo above
// (appearance-scroll-000/-250-light) picks 0.7: strip rms 4.7 -> 2.2 levels, photo 5.1 -> 4.1 (per 13 pt row
// 6.2 5.8 4.8 4.7 4.1 4.5 5.0 5.4 -> 3.5 3.1 4.5 4.7 3.9 3.7 3.8 5.0). Dark keeps the dump: its strip already
// matches within 1 level (row 103 (64.2,49.0,54.4) Mac, (65.1,50.1,54.5) model). GLASS-HIG.md §15.
// Put it over the band, with `source` the scrolled item (a sibling under it, not a parent); it draws only while
// `active`. Reduce Transparency: the plain window colour (the caller's veil is not needed then). Another pocket style
// sets the blend itself: lighten 0, darken 0, normal 1 is a plain `sigma` blur under the veil (Finder's list header).
Item {
    id: e
    property Item source
    property bool active: true
    property bool dark: Tokens.dark
    property color windowColor: "white"
    property real sigma: 16
    property real lighten: dark ? 0.4 : 0.6
    property real darken: dark ? 0.6 : 0.4
    property real normal: dark ? 0 : 0.7          // FITTED light (dump 0.25), see above
    property real saturation: 1.25
    property real veil: dark ? 0.7 : 0.55     // FITTED (dump 0.6 / 0.5), see above
    property color veilColor: dark ? Qt.rgba(43 / 255, 43.5 / 255, 48.5 / 255, 1) : "white"
    property real replaySat: Math.max(0, 1.25 - 0.25 / (dark ? 0.6 : 0.5))   // from the dumped opacity
    property real radius: 2 + 0.5 * Math.max(0, Math.min(1, (height - 52) / 38))
    property real cornerRadius: 0      // the top-right corner (a window corner the band reaches)
    visible: active && source !== null

    // the band's rect in the source's coordinates. The textures hold the band only: both blurs read nothing outside it
    // (CA's backdrop captures its own bounds), and a margin let the coarse texture's filtering reach across the band's
    // edge (its texel straddling the bottom edge put 34 % of the thumbnail under the line into the fill blur's last row)
    readonly property point _o: source ? mapToItem(source, 0, 0) : Qt.point(0, 0)
    readonly property rect _rect: Qt.rect(_o.x, _o.y, width, height)

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
        mipmap: true      // the fill blur reads it at about its tap spacing (scrolledge.frag tapLod)
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
        property real sigma: e.sigma
        property real lighten: e.lighten
        property real darken: e.darken
        property real normal: e.normal
        property real saturation: e.saturation
        property real veil: e.veil
        property real cornerRadius: e.cornerRadius
        property real radius: e.radius
        property real replaySat: e.replaySat
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
