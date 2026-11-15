import QtQuick
import QtQuick.Effects
import "motion.js" as Motion

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
// While `pressed` the lens is elastic: SwiftUI's FlexInteraction liquidLens with the movement source (DesignLibrary
// knob sub_195e18154, activation .alwaysActive only while pressed / deeply pressed): the knob's centre is sampled every
// frame, its ACCELERATION (motion.js movementSample) stretches the lens along the motion and flattens it while it
// speeds up, narrows and heightens it while it slows down (or stops at an end), the leading edge staying put
// (motion.js movementScale, applyMovement 0x190c22a70), on a spring of response 0.444 s, damping 0.56 (liquidLensSet).
// The deformation changes the knob's geometry (the lens re-samples what lies under its new shape, as the Mac's
// scaled glass does), not a stretched picture. Released: the source is off, the shape springs back. R7.2
// slider-fast-drag-settings-dark.mov: the lens 26.5 pt wide (rim included) held still, up to 28.5-30 after a fling
// starts or stops, 24-24.5 about 0.15-0.25 s after a stop (INTERACTIVE-GLASS-REA.md Applied).
// Reduce Motion: no growth, no deformation. Reduce Transparency: the fill stays white.
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
    property bool pressed: false     // the control is pressed (Slider dragging, Switch held): the lens is elastic
    property bool elastic: true
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
    // the rim line in the decoded stroke mode (LensGlass rimStroke): the switch's KeyFillHighlight height 1 = -offset
    property bool lensRimStroke: false
    // true: the decoded held-slider-knob stack (MAC-ANSWERS Verify B2 item 1, measured in dark; Tokens knobLens* light
    // values) in both modes: face 0.1 + 0.9 c, ring shadow 0.4 (8 down, 4 wide, blur 3), key / fill highlight; no
    // fitted diffuse / key bands. Every Slider (Settings, Finder, Control Center) and, with its own dump's values, the
    // Switch (GLASS-HIG.md rounds 6 and 7)
    property bool lensDecoded: false
    // the decoded stack's ring shadow opacity (inside the lens and below it, shaders/ringshadow.frag): the dump's 0.4
    // (slider-knob-held.json inputRingShadowOpacity); Slider passes Tokens.control.sliderLensRingOpacity
    property real lensDecodedRing: 0.4
    // the decoded stack's face black (inputFaceColorMatrixBlack: the slider's 0.1; the switch's dump has 0)
    property real lensDecodedHaze: 0.1
    property real lensEmptyLevel: 0   // LensGlass emptyLevel (the Control Center: its module glass)
    // true: the white fill is the glass's own content, under the glass (LensGlass glassFill), and the glass is opaque
    // from the first frame with its terms growing with the lift (LensGlass strength) instead of cross-fading in over the
    // track under an unrefracted white body. The Switch (switch-held-stripes-{dark,light}.mov: the white sits about 4 pt
    // inside the growing lens's ends from the first frames; GLASS-HIG.md round 8)
    property bool lensFillInside: false
    // the share of the large rest shadow (radius 12 y 3) kept at full lift (0.3: "the lens keeps a faint shadow",
    // strip frames); the small one (radius 2 y 1) always fades to 0.3
    property real restShadowHeld: 0.3
    // the two rest shadows' opacity x this (the Control Center's hover knob 0.75: R18.3, Theme.cc.knobShadowScale)
    property real shadowScale: 1

    readonly property real _l: reduceMotion ? 0 : lift
    readonly property real _fill: Tokens.reduceTransparency ? 1 : Math.min(1, 1 - lift)
    readonly property bool _lens: lensSource !== null && lift > 0 && _fill < 1
    readonly property real _lift01: Math.max(0, Math.min(1, lift))   // lift clamped to 0..1
    // the undeformed size (applyMovement reads the layout size, not the scaled one)
    readonly property real _w: restW + (liftW - restW) * _l
    readonly property real _h: restH + (liftH - restH) * _l
    width: _w * sxS.value
    height: _h * syS.value
    x: cx - width / 2 + txS.value
    y: cy - height / 2 + tyS.value

    // ---- the elastic lens (FlexInteraction liquidLens, movement source) ----
    readonly property bool _moving: pressed && elastic && !reduceMotion && lift > 0
    readonly property var _set: Motion.liquidLensSet(liftW, liftH)
    property var _mv: Motion.movementStart()
    property var _target: [1, 1, 0, 0]
    on_MovingChanged: {
        _mv = Motion.movementStart();
        _target = [1, 1, 0, 0];
        if (_moving) mclock.start();
        else {
            mclock.stop();
            // a spring at rest within its epsilon of the new target is not kicked: land it exactly (sub-0.1 %)
            for (const sp of [sxS, syS, txS, tyS]) if (!sp.moving) sp.snap();
        }
    }
    FrameClock {
        id: mclock
        onTick: {
            const st = Motion.movementSample(k._mv, k.cx, k.cy, elapsed / 1000);
            k._mv = st;
            k._target = Motion.movementScale(st.acc[0], st.acc[1], st.vel[0], st.vel[1], k._w, k._h, k._set);
        }
    }
    Spring { id: sxS; target: k._target[0]; response: k._set.response; damping: k._set.damping; epsilon: 0.001; instant: k.reduceMotion }
    Spring { id: syS; target: k._target[1]; response: k._set.response; damping: k._set.damping; epsilon: 0.001; instant: k.reduceMotion }
    Spring { id: txS; target: k._target[2]; response: k._set.response; damping: k._set.damping; epsilon: 0.02; instant: k.reduceMotion }
    Spring { id: tyS; target: k._target[3]; response: k._set.response; damping: k._set.damping; epsilon: 0.02; instant: k.reduceMotion }
    readonly property var deformation: [sxS.value, syS.value, txS.value, tyS.value]

    // the lens keeps a faint shadow (strip frames); fading the shadows also keeps them from greying the track
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 12; offset.y: 3
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * k.shadowScale * (1 - (1 - k.restShadowHeld) * k.lift))
    }
    RectangularShadow {
        anchors.fill: body; radius: body.radius
        blur: 2; offset.y: 1
        color: Qt.alpha(Tokens.control.knobShadow, Tokens.control.knobShadow.a * k.shadowScale * (1 - 0.7 * k.lift))
    }
    RectangularShadow {   // the lens's shadow (Tokens.control.knobLensShadow*)
        visible: k._lens && !k.lensDecoded
        anchors.fill: body; radius: body.radius
        blur: Tokens.control.knobLensShadowBlur; spread: Tokens.control.knobLensShadowSpread
        offset.y: Tokens.control.knobLensShadowY
        color: Qt.alpha(k.lensShadow, k.lensShadow.a * k._lift01)
    }
    // lensDecoded: the lens's shadow is the filter's ring shadow where it falls outside the glass (shaders/
    // ringshadow.frag; the decoded composite applies it to every pixel): darkest 4-8 pt under the bottom rim, as the
    // Control Center frame (99 under the rim, 85 from 4 to 7 pt down, GLASS-HIG.md round 6)
    ShaderEffect {
        readonly property real m: Tokens.control.knobLensRingOffset + Tokens.control.knobLensRingWidth
                                  + 3 * Tokens.control.knobLensRingBlur
        visible: k._lens && k.lensDecoded
        x: -m; y: -m; width: k.width + 2 * m; height: k.height + 2 * m
        opacity: k._lift01
        property size size: Qt.size(width, height)
        property real margin: m
        property vector4d ring: Qt.vector4d(Tokens.control.knobLensRingOffset, Tokens.control.knobLensRingWidth,
                                            Tokens.control.knobLensRingBlur, k.lensDecodedRing)
        fragmentShader: Qt.resolvedUrl("shaders/ringshadow.frag.qsb")
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
            opacity: k.lensFillInside ? 1 : Math.min(1, k.lift)
            strength: k.lensFillInside ? k._lift01 : 1
            glassFill: k.lensFillInside ? Qt.alpha(Tokens.control.knob, Math.max(0, k._fill)) : "transparent"
            band: Math.min(k.width, k.height) * k.lensBand
            amount: Math.min(k.width, k.height) * k.lensAmount
            dispAmount: Math.min(k.width, k.height) * k.lensDisp
            dispBand: Math.min(k.width, k.height) * k.lensDispBand
            aberration: k.lensAberration
            aberrationEdge: Tokens.control.knobLensAberrationEdge
            emptyLevel: k.lensEmptyLevel
            gain: k.lensDecoded ? 1 : k.lensGain
            haze: k.lensDecoded ? k.lensDecodedHaze : k.lensHaze
            diffuseTop: k.lensDecoded ? 0 : Tokens.control.knobLensDiffuseTop
            diffuseTopDepth: Tokens.control.knobLensDiffuseTopDepth
            diffuseBottom: k.lensDecoded ? 0 : Tokens.control.knobLensDiffuseBottom
            diffuseBottomDepth: Tokens.control.knobLensDiffuseBottomDepth
            keyTop: k.lensDecoded ? 0 : Tokens.control.knobLensKeyTop
            keyBottom: k.lensDecoded ? 0 : Tokens.control.knobLensKeyBottom
            keyEnds: k.lensDecoded ? 0 : Tokens.control.knobLensKeyEnds
            keyFalloff: Tokens.control.knobLensKeyFalloff
            ringOffset: Tokens.control.knobLensRingOffset
            ringWidth: Tokens.control.knobLensRingWidth
            ringBlur: Tokens.control.knobLensRingBlur
            ringOpacity: k.lensDecoded ? k.lensDecodedRing : k.lensRingOpacity
            fillLight: k.lensDecoded ? 1 : Tokens.control.knobLensFillLight
            outline: Tokens.control.knobLensOutline
            rimBias: k.lensRimBias
            rimSpread: k.lensRimSpread
            rimAmount: k.lensRimAmount
            outlineWidth: k.lensOutlineWidth
            rimStroke: k.lensRimStroke
            backdrop: k.lensBackdrop
        }
    }
    Rectangle {
        id: body
        anchors.fill: parent
        radius: height / 2
        color: Qt.alpha(Tokens.control.knob, k._lens && k.lensFillInside ? 0 : k._fill)
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
