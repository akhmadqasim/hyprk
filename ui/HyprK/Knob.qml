import QtQuick
import QtQuick.Effects

// Knob of Switch and Slider (MAC-ANSWERS.md Q-settings-16..-18): a white capsule with two shadows (black a.10
// radius 12 y 3, black a.10 radius 2 y 1). Not glass at rest. While pressed (`lift` 0 .. 1) it grows by `grow`
// around its centre and cross-fades into a clear lens: the white fill's opacity is 1 - lift (Mac: 0.51 at half
// growth, "SDF layer opacity = growth progress"). With `lensSource` set (the track, an item at 0,0 of the knob's
// parent) the lens is a LensGlass that bends the track at its rim (the slider magnifies it there, the switch
// shrinks it to 0.79 x: Tokens knobLens* / sliderLens*), lights it and outlines it (Tokens
// knobLens*: the Mac's pressed-knob glass filter and the 2026-11-11 recording) over `lensBackdrop`, with a shadow
// 8 pt under it; without it a light rim with a thin dark outline fades in and the track shows through unbent.
// One knob for every slider and switch (Settings, Finder, Control Center); the sizes are the caller's: restW x restH
// at rest, liftW x liftH fully pressed (default x grow).
// Reduce Motion: no growth. Reduce Transparency: the fill stays white.
// Place it with cx / cy (its centre in the parent).
Item {
    id: k
    property real restW: 20
    property real restH: 16
    property real grow: Tokens.motion.switchLift
    property real liftW: restW * grow
    property real liftH: restH * grow
    property real lift: 0
    property bool reduceMotion: Tokens.reduceMotion
    property real cx: 0
    property real cy: 0
    property Item lensSource: null
    property color lensBackdrop: Tokens.control.lensBackdrop
    // the lens geometry in units of D (the lens height): the switch's by default, Slider passes its own (Tokens)
    property real lensBand: Tokens.control.knobLensBand
    property real lensAmount: Tokens.control.knobLensAmount
    property real lensDisp: Tokens.control.knobLensDisp
    property real lensDispBand: Tokens.control.knobLensDispBand
    property real lensAberration: Tokens.control.knobLensAberration   // the switch's; Slider passes 0 (Verify B 5)
    property real lensGain: Tokens.control.knobLensGain
    // light terms that differ between the switch's filter and the slider's (Tokens switchLens*): the slider's by
    // default, Switch passes its own. lensRimBias 0: the flat black line (knobLensOutline)
    property real lensHaze: Tokens.control.knobLensHaze
    property real lensRingOpacity: Tokens.control.knobLensRingOpacity
    property real lensRimBias: 0
    property real lensRimSpread: 120
    property real lensRimAmount: 0.5   // KeyFillHighlightAmount of both knob filters (switch / slider dumps)
    property color lensShadow: Tokens.control.knobLensShadow
    property real lensOutlineWidth: Tokens.control.knobLensOutlineWidth
    // the share of the large rest shadow (radius 12 y 3) kept at full lift (0.3: "the lens keeps a faint shadow",
    // strip frames); the small one (radius 2 y 1) always fades to 0.3
    property real restShadowHeld: 0.3

    readonly property real _l: reduceMotion ? 0 : lift
    readonly property real _fill: Tokens.reduceTransparency ? 1 : Math.min(1, 1 - lift)
    readonly property bool _lens: lensSource !== null && lift > 0 && _fill < 1
    width: restW + (liftW - restW) * _l
    height: restH + (liftH - restH) * _l
    x: cx - width / 2
    y: cy - height / 2

    // the lens keeps a faint shadow (strip frames); fading the shadows also keeps them from greying the track
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 12; offset.y: 3
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * (1 - (1 - k.restShadowHeld) * k.lift))
    }
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 2; offset.y: 1
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * (1 - 0.7 * k.lift))
    }
    RectangularShadow {   // the lens's shadow (Tokens.control.knobLensShadow*)
        visible: k._lens
        anchors.fill: body; radius: body.radius
        blur: Tokens.control.knobLensShadowBlur; spread: Tokens.control.knobLensShadowSpread
        offset.y: Tokens.control.knobLensShadowY
        color: Qt.alpha(k.lensShadow, k.lensShadow.a * Math.max(0, Math.min(1, k.lift)))
    }
    // the rim line lies outside the lens's own shape (MAC-ANSWERS rim model; the recording: the face is 25 x 20,
    // the dark line 1 pt outside it), so the glass is drawn that much larger
    Loader {
        anchors.fill: parent
        anchors.margins: -k.lensOutlineWidth
        active: k._lens
        sourceComponent: LensGlass {
            source: k.lensSource
            origin: Qt.point(k.x - k.lensOutlineWidth, k.y - k.lensOutlineWidth)
            opacity: Math.min(1, k.lift)
            band: Math.min(k.width, k.height) * k.lensBand
            amount: Math.min(k.width, k.height) * k.lensAmount
            dispAmount: Math.min(k.width, k.height) * k.lensDisp
            dispBand: Math.min(k.width, k.height) * k.lensDispBand
            aberration: k.lensAberration
            gain: k.lensGain
            haze: k.lensHaze
            diffuseTop: Tokens.control.knobLensDiffuseTop
            diffuseTopDepth: Tokens.control.knobLensDiffuseTopDepth
            diffuseBottom: Tokens.control.knobLensDiffuseBottom
            diffuseBottomDepth: Tokens.control.knobLensDiffuseBottomDepth
            keyTop: Tokens.control.knobLensKeyTop
            keyBottom: Tokens.control.knobLensKeyBottom
            keyEnds: Tokens.control.knobLensKeyEnds
            keyFalloff: Tokens.control.knobLensKeyFalloff
            ringOffset: Tokens.control.knobLensRingOffset
            ringWidth: Tokens.control.knobLensRingWidth
            ringBlur: Tokens.control.knobLensRingBlur
            ringOpacity: k.lensRingOpacity
            fillLight: Tokens.control.knobLensFillLight
            outline: Tokens.control.knobLensOutline
            rimBias: k.lensRimBias
            rimSpread: k.lensRimSpread
            rimAmount: k.lensRimAmount
            outlineWidth: k.lensOutlineWidth
            backdrop: k.lensBackdrop
        }
    }
    Rectangle {
        id: body
        anchors.fill: parent
        radius: height / 2
        color: Qt.alpha(Tokens.control.knob, k._fill)
        // the lens edge without a lens source: 0.5 pt grey outline (195 on 240 in the strip) and a white band inside it
        border.width: k.lift > 0 && !k._lens ? 0.5 : 0   // lift < 0: the switch's release spring dipping past rest
        border.color: Qt.rgba(0, 0, 0, 0.2 * k.lift)
        Rectangle {
            visible: k.lift > 0 && k._fill < 1 && !k._lens
            anchors.fill: parent; anchors.margins: 0.5
            radius: height / 2
            color: "transparent"
            border.width: 1.5
            border.color: Qt.rgba(1, 1, 1, 0.85 * k.lift)
        }
    }
}
