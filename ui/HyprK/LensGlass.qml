import QtQuick
import QtQuick.Window

// In-window Liquid Glass capsule (shaders/glasslens4.frag): draws what lies under it in `source`, bent near the rim,
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
    // the glassBackground filter's other two geometry terms (glasslens4.frag, MAC-ANSWERS Verify B 2 / B 5): the
    // backdrop's displacementMap (amount pt outward at the rim over dispBand pt, the same quarter-circle law; the held
    // switch's +0.25 D over D) and the Regular recipe's outer refraction (a sample outerAmount pt further out over
    // outerBand pt, mixed in by outerOpacity over the outermost 1 pt). All 0 by default
    property real dispAmount: 0
    property real dispBand: 1
    property real outerAmount: 0
    property real outerBand: 1
    property real outerOpacity: 0
    property real blur: 0
    // the glassBackground filter's blur fill (glasslens4.frag blurFill; MAC-ANSWERS verify C / C2, decomp
    // QuartzCore-glassBackground-shader.c): the sharp sample mixed with the backdrop blurred by a Gaussian of fillSigma pt,
    // first lightened / darkened toward it (fillLighten, fillDarken), then mixed toward it by fillNormal. 0: off.
    // Needs a mipmapped texture, made only when on
    property real fillSigma: 0
    property real fillNormal: 0
    property real fillDarken: 0
    property real fillLighten: 0
    // true: the rim's dark specular darkens the faced sample (the face* matrix and fill when set, else the decoded dark
    // Regular face), not the plain sample (glasslens4.frag; GLASS-HIG.md rounds 2 and 4)
    property bool rimFace: false
    // true: the decoded stroke mode (QuartzCore-glass-shaders.c step 4, KeyFillHighlightEffectOffset = -height): the
    // dark specular is the pixel just outside the glass shape and tones the plain backdrop there; the outer outlineWidth
    // pt of this item is that line and the glass (refraction, outer mix, face) is the item inset by it. With
    // fillBackdropOutside the outer sample also reads `backdrop` beyond the source (GLASS-HIG.md round 5)
    property bool rimStroke: false
    // the glassForeground filter's chromatic aberration (the held switch, MAC-ANSWERS Verify B 5: inputAberrationAmount
    // 1.632 pt, inputAberrationAngle -15 deg, inputEdgeStart -6.2; live/verify/B/dumps/switch-knob-held.json): the
    // glass re-read per channel along an offset that follows the rim normal through the swapped displacement matrix
    // (decoded from glass_foreground_base, glasslens4.frag), full at the item's edge and gone aberrationEdge pt in
    // (GLASS-HIG.md round 7; round 6 had it the other way round). 0: none.
    // Until 2026-11-14 a fixed offset on the rim line only (GLASS-HIG.md round 3)
    property real aberration: 0
    property real aberrationAngle: -15
    property real aberrationEdge: 6.2
    // where `source` is empty (backdrop transparent: a knob over a window's own glass), the backdrop level (0..1) the
    // glass's ring shadow, key / fill highlight and dark specular line are drawn for as plain layers (glasslens4.frag
    // eRing / eLight / eLine). 0: the white lit and black `outline` only (GLASS-HIG.md round 7)
    property real emptyLevel: 0
    // the glass's own content (glasslens4.frag gfill): a layer of this colour in the glass shape UNDER the glass, so the
    // refraction bends it with the backdrop (the held switch knob's white fill: switch-held-stripes-*.mov show it inset
    // about 4 pt from the growing lens's ends, the rim region sampling the track outside it; GLASS-HIG.md round 8).
    // strength 0 .. 1 scales the glass's terms (refraction, light, ring shadow, rim tone, aberration): the growth
    property color glassFill: "transparent"
    property real strength: 1
    // the filter's face colour matrix instead of gain / tint-only (MAC-ANSWERS verify C / C2: black, white, saturation,
    // maxLuma; faceWhite 0: off). The fill colour stays `tint`
    property real faceBlack: 0
    property real faceWhite: 0
    property real faceSat: 1
    property real faceMaxLuma: 1
    property real gain: 1
    property real outline: 0
    property real outlineWidth: 0.5   // pt
    // the filter's dark specular on the rim line instead of the flat `outline` (glasslens4.frag; 0: off): its tone
    // curve bias (-0.25) and lobe spread in degrees (106 light, 75 dark on SDR: MAC-ANSWERS Verify B 1)
    property real rimBias: 0
    property real rimSpread: 106
    // KeyFillHighlightAmount: the lobes' Schlick parameter (the CPU passes 1 / amount - 2: MAC-ANSWERS Verify B 1,
    // 0x18debcd84; Regular 0.4, the held switch and slider 0.5 = linear lobes)
    property real rimAmount: 0.4
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
    // the glassBackground filter's ring shadow (a band ringWidth pt wide inside the edge of the face moved ringOffset pt
    // down, blurred ringBlur pt, darkening the face by ringOpacity) and its key / fill highlight (fillLight 0 .. 1);
    // both off by default (glasslens4.frag). The highlight reads the plain capsule normal: QuartzCore ovalizes it only on
    // shapes whose shorter side is over 64 pt (MAC-ANSWERS-8.md R8.1), and every LensGlass is a capsule of at most 37 pt
    property real ringOffset: 0
    property real ringWidth: 0
    property real ringBlur: 0
    property real ringOpacity: 0
    property real fillLight: 0
    property color tint: "transparent"   // rgb + mix amount in alpha
    property color backdrop: "transparent"
    // true: a sample that falls outside `source` (the bent rim or the blur of a capsule near the source's edge) repeats
    // the source's edge pixel. false: it is empty there and the capsule is transparent over `backdrop` (a knob that
    // leaves its track). The Liquid Glass preview's capsules sit 7 pt from the article's top and right edge and bend
    // 12 pt: unclamped their top and right end were cut away (user report). Edge repeat itself is inferred, not measured
    property bool clampToSource: false
    // with clampToSource: the blur fill still reads `backdrop` beyond the source's edge (only the sharp samples repeat
    // the edge). The Appearance preview: its capsules' face fits the Mac only with the card around the article in
    // the blur, its rim only with the edge repeat (GLASS-HIG.md round 3)
    property bool fillBackdropOutside: false
    readonly property real margin: Math.ceil(Math.abs(amount) + Math.abs(dispAmount) + Math.abs(outerAmount) + Math.max(blur, 2.25 * fillSigma) + 1)
    // a button's light (ToolbarHighlight): a disc of Tokens.toolbar.hoverDiscRadius round discCentre with discLift added
    // (< 0: black at -discLift over it, a glass button's interaction fill in light),
    // then SwiftUI's press light round glowCentre (item px; motion.js glow*): the BigGlow over the whole glass (opacity
    // glowBig; the code's square edge does not show on the Mac, INTERACTIVE-GLASS-REA.md 1, so glowHalf is unused) and
    // the LittleGlow blurred circle (opacity glowLittle, gain glowDodge, coverage table glowLut indexed in quarters of
    // glowRadius: motion.js glowLutRadius)
    property point discCentre: Qt.point(0, 0)
    property real discLift: 0
    property point glowCentre: Qt.point(0, 0)
    property real glowHalf: 0
    property real glowBig: 0
    property real glowLittle: 0
    property real glowRadius: 1
    property real glowDodge: 1
    property var glowLut: []
    // an AppKit toolbar platter's interaction layer (motion.js platterPress): the whole face mixed toward 0.3125 c +
    // 0.9375 (dark) / - 0.25 (light) by this alpha. The Mac shows it once a held Back's history menu is open (round 7,
    // TOOLBAR-REA-27.2.1.md 2); ours opens no such menu, so nothing sets it now
    property real platterPress: 0
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
        mipmap: g.fillSigma > 0
        sourceRect: Qt.rect(g.origin.x - g.margin, g.origin.y - g.margin, g.width + 2 * g.margin, g.height + 2 * g.margin)
        // at least 2 px per point: the rim minifies, a 1x texture smears the bent edges
        readonly property real k: Math.max(2, Screen.devicePixelRatio)
        textureSize: Qt.size(Math.ceil(sourceRect.width * k), Math.ceil(sourceRect.height * k))
    }
    ShaderEffect {
        anchors.fill: parent
        visible: g.source !== null && g.width > 0 && g.height > 0
        fragmentShader: Qt.resolvedUrl("shaders/glasslens4.frag.qsb")
        property var source: tex
        property size size: Qt.size(g.width, g.height)
        property real margin: g.margin
        property real band: Math.max(0.01, g.band)
        property real amount: g.amount
        property real blur: g.blur
        property vector4d refr2: Qt.vector4d(g.dispAmount, Math.max(0.01, g.dispBand), g.outerAmount, Math.max(0.01, g.outerBand))
        property real outerOpacity: g.outerOpacity
        property vector4d rimSpec: Qt.vector4d(g.rimBias, Math.cos(g.rimSpread * Math.PI / 180), g.rimStroke ? (g.rimFace && g.faceWhite > 0 ? 4 : 3) : g.rimFace ? (g.faceWhite > 0 ? 2 : 1) : 0, g.rimAmount)
        property vector4d aberr: Qt.vector4d(g.aberration, g.aberrationAngle * Math.PI / 180, g.aberrationEdge, g.emptyLevel)
        property vector4d face: Qt.vector4d(g.faceBlack, g.faceWhite, g.faceSat, g.faceMaxLuma)
        property real fillOut: g.fillBackdropOutside ? 1 : 0
        property vector4d gfill: Qt.vector4d(g.glassFill.r * g.glassFill.a, g.glassFill.g * g.glassFill.a,
                                             g.glassFill.b * g.glassFill.a, g.glassFill.a)
        property real fxs: Math.max(0, Math.min(1, g.strength))
        property vector4d bfill: Qt.vector4d(g.fillSigma, g.fillNormal, g.fillDarken, g.fillLighten)
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
        property vector4d glow: Qt.vector4d(g.glowCentre.x, g.glowCentre.y, g.glowHalf, g.glowDodge)
        property vector4d glowAmt: Qt.vector4d(g.glowBig, g.glowLittle, g.glowRadius, 0)
        function lutAt(i) { return g.glowLut[i] ?? 0; }
        property vector4d glowLut0: Qt.vector4d(lutAt(0), lutAt(1), lutAt(2), lutAt(3))
        property vector4d glowLut1: Qt.vector4d(lutAt(4), lutAt(5), lutAt(6), lutAt(7))
        property vector4d glowLut2: Qt.vector4d(lutAt(8), lutAt(9), lutAt(10), lutAt(11))
        property vector4d glowLut3: Qt.vector4d(lutAt(12), lutAt(13), lutAt(14), lutAt(15))
        property vector4d disc: Qt.vector4d(g.discCentre.x, g.discCentre.y, Tokens.toolbar.hoverDiscRadius, g.discLift)
        property real discEdge: Tokens.toolbar.hoverDiscEdge
        property real additive: g.additive ? 1 : 0
        property vector4d ring: Qt.vector4d(g.ringOffset, g.ringWidth, g.ringBlur, g.ringOpacity)
        property real fillLight: g.fillLight
        property vector4d platter: Qt.vector4d(g.platterPress, 0.3125, Tokens.dark ? 0.9375 : -0.25, 0)
        property vector4d backdrop: Qt.vector4d(g.backdrop.r * g.backdrop.a, g.backdrop.g * g.backdrop.a,
                                                g.backdrop.b * g.backdrop.a, g.backdrop.a)
    }
}
