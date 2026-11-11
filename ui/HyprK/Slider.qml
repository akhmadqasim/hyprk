import QtQuick
import "controls.js" as G

// macOS 27.2.1 slider (MAC-ANSWERS.md Q-settings-17, -18): track black/white a.098 with the accent fill up to the
// knob's centre, white 20 x 16 capsule knob (Knob). Not glass at rest; while held the knob grows x1.25 into a clear
// lens and a press layer (Tokens.control.sliderPressOverlay) comes over the fill, on Tokens.motion.sliderLiftCurve
// (144 ms, back the same way), one value per frame (FrameAnim).
// The one slider of hyprk: Settings, Finder and the shell's Control Center use it. Per context (each backed by its
// own Mac data): fillColor / trackColor / trackHeight or a `trackFill` component (the Control Center's plus-lighter
// track), knob and lens sizes, knobShown (the Control Center grid shows the knob only while the module is hovered), fillToEnds (the fill runs
// from 0 to the full width and the knob is kept half a knob inside the ends), trackPressOffset (a track press puts the
// fill end that far ahead of the pointer), overdrag (pt of rubber band past an end), jumpResponse, hitMargin.
// Mouse-down on the knob grabs it where it was hit; mouse-down on the track sends the knob there (ease-out, no
// overshoot) and keeps tracking. tickMarks > 1 draws 2 x 2 dots under the track; onlyTicks snaps to them.
// End glyphs (SF Symbol names; or leftIcon / rightIcon components) sit beside the track and are buttons. A glyph is laid
// out by its layout frame, as the Mac's minimum / maximum value images are (sound-light.png and displays-light.png:
// the frames of speaker.fill / speaker.wave.3.fill and sun.min.fill / sun.max.fill span 463.6 .. 709.6 pt and end
// 3.9 - 4.4 pt before the track, on both sides; an icon component sits glyphGap away with its own box). They send the
// value to that end, or step it by endStep when that is > 0 (Liquid Glass: 0.1). Text labels sit under it, 11 pt (Desktop & Dock): leftText /
// rightText, or `labels: [[text, fraction], ...]` (0 = left-aligned at the start, 1 = right-aligned at the end,
// otherwise centred under that knob position).
// Controlled: it shows `value` and emits moved(value) while dragged and committed(value) once on mouse-up or an end
// button click (for settings written only on release, like NSGlassTintAmount); the caller owns the state.
// A press on the knob that never moves it emits nothing (no moved, released or committed): only the lens shows.
Item {
    id: s
    property real from: 0
    property real to: 1
    property real value: 0
    property int tickMarks: 0
    property bool onlyTicks: false
    property string controlSize: "regular"
    property string leftGlyph: ""
    property string rightGlyph: ""
    property Component leftIcon: null
    property Component rightIcon: null
    property real endStep: 0
    property real glyphSize: 12.5          // pt; regular weight. Sound: speaker.fill 12.5 (alpha rms 0.021), Displays 16.5
    property real rightGlyphSize: glyphSize
    property real glyphGap: leftIcon || rightIcon ? 6 : 4
    // with tick marks the track sits above the control's middle: the end images are 0.8 - 1.3 pt under the track's
    // centre on sound-light.png (both sliders), 0.0 - 0.1 pt on displays-light.png (no ticks)
    readonly property real _glyphDy: tickMarks > 1 && !leftIcon && !rightIcon ? 1 : 0
    property string leftText: ""
    property string rightText: ""
    property color fillColor: enabled ? Tokens.control.sliderFill : Tokens.control.sliderDisabled
    property color trackColor: enabled ? Tokens.control.trackOff : Tokens.control.sliderDisabled
    property real trackHeight: _m.track
    property Component trackFill: null    // drawn instead of the plain track (gets the track's width and height)
    property real knobWidth: _m.knobWidth
    property real knobHeight: _m.knobHeight
    property real lensWidth: knobWidth * Tokens.motion.sliderLift
    property real lensHeight: knobHeight * Tokens.motion.sliderLift
    property color lensBackdrop: Tokens.control.lensBackdrop
    property bool knobShown: true
    property bool fillToEnds: false
    property real trackPressOffset: 0
    property real overdrag: 0
    property int overdragBackMs: 130
    property real jumpResponse: Tokens.motion.sliderJumpResponse
    property real hitMargin: 0
    readonly property bool pressed: _dragging
    property var labels: (leftText !== "" ? [[leftText, 0]] : []).concat(rightText !== "" ? [[rightText, 1]] : [])
    signal moved(real value)
    signal released()
    // the keyboard modifiers when the pointer let go (0 for the arrow keys): Control Center reads Shift here, which
    // inverts "Play feedback when volume is changed" (ControlCenter 27.2.1 0x1000e3814: NSEvent modifierFlags bit 17)
    property int releaseModifiers: 0
    signal committed(real value)
    function _end(dir) {
        const v = endStep > 0 ? Math.max(from, Math.min(to, value + dir * endStep)) : dir < 0 ? from : to;
        releaseModifiers = 0;
        moved(v); released(); committed(v);
    }
    // Arrow keys (AppKit 27.2.1 -[NSSliderCell _moveInDirection:] 0x18b15eb0c): a twentieth of the range per press, or
    // one tick when the slider only takes ticks; Right / Up add, Left / Down subtract, Page Up / Down go to the ends.
    // Home, End and any modifier are not taken. One moved / released / committed per press that changes the value.
    activeFocusOnTab: true
    Keys.onPressed: e => {
        if (!enabled || e.modifiers & (Qt.ShiftModifier | Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) return;
        const snap = onlyTicks && tickMarks > 1;
        const step = snap ? (to - from) / (tickMarks - 1) : (to - from) / 20;
        let v;
        if (e.key === Qt.Key_Right || e.key === Qt.Key_Up) v = value + step;
        else if (e.key === Qt.Key_Left || e.key === Qt.Key_Down) v = value - step;
        else if (e.key === Qt.Key_PageUp) v = to;
        else if (e.key === Qt.Key_PageDown) v = from;
        else return;
        e.accepted = true;
        if (snap) v = from + Math.round((v - from) / step) * step;
        v = Math.max(Math.min(from, to), Math.min(Math.max(from, to), v));
        if (v === value) return;
        releaseModifiers = 0;
        moved(v); released(); committed(v);
    }
    readonly property var _m: G.slider(controlSize)
    implicitWidth: 220
    implicitHeight: _m.height + (labels.length > 0 ? 15 : 0)

    // While dragging, show the drag position without assigning `value`
    // (that would break the caller's binding to external state).
    property bool _dragging: false
    property real _dragValue: 0
    property bool _jump: false        // a track click is springing the knob to the pointer
    readonly property real _shown: _dragging ? _dragValue : value
    property bool reduceMotion: Tokens.reduceMotion
    readonly property real _frac: to > from ? Math.max(0, Math.min(1, (_shown - from) / (to - from))) : 0

    Spring {
        id: pos
        target: s._frac
        response: s.jumpResponse
        damping: 1
        epsilon: 0.001
        instant: !s._jump || s.reduceMotion
        // landed (within half a point): follow the pointer 1:1 from here on
        onValueChanged: if (s._jump && Math.abs(target - value) * track.usable < 0.5) s._jump = false
    }
    // lens amount 0 .. 1, only between mouse-down and the end of the release; a reversal runs the rest of the way
    // back for its share of the time
    property real _lift: 0
    FrameAnim {
        id: liftAnim
        target: s; property: "_lift"
        curve: Tokens.motion.sliderLiftCurve
    }
    function _liftTo(v: real): void {
        liftAnim.stop();
        liftAnim.to = v;
        liftAnim.duration = (v > 0 ? Tokens.motion.sliderLiftDuration : Tokens.motion.sliderLiftRelease) * Math.abs(v - _lift);
        if (liftAnim.duration > 0) liftAnim.start(); else _lift = v;
    }
    on_DraggingChanged: _liftTo(_dragging ? 1 : 0)
    // stretch past an end in pt (< 0 = the left end): `_pull` while held, eased back on release
    property real _pull: 0
    readonly property real _over: overEase.value
    FrameEase {
        id: overEase
        goal: s._pull
        animate: !s._dragging && !s.reduceMotion
        duration: s.overdragBackMs
        ease: Easing.OutCubic
    }

    Item {
        id: lg; visible: s.leftGlyph !== "" || s.leftIcon !== null
        anchors.left: parent.left; anchors.verticalCenter: track.verticalCenter
        anchors.verticalCenterOffset: s._glyphDy; anchors.alignWhenCentered: false   // no rounding to whole points
        width: s.leftIcon ? li.width : lt.advance; height: s.leftIcon ? li.height : lt.height
        SfSymbol {
            id: lt; visible: !s.leftIcon
            x: bearing
            name: s.leftGlyph; pointSize: s.glyphSize
            color: lma.pressed ? Tokens.label : Tokens.secondaryLabel   // pressed: darker (borderless image button)
        }
        Loader { id: li; sourceComponent: s.leftIcon; property bool pressed: lma.pressed }
        MouseArea { id: lma; objectName: "leftEnd"; anchors.fill: parent; anchors.margins: -3; onClicked: s._end(-1) }
    }
    Item {
        id: rg; visible: s.rightGlyph !== "" || s.rightIcon !== null
        anchors.right: parent.right; anchors.verticalCenter: track.verticalCenter
        anchors.verticalCenterOffset: s._glyphDy; anchors.alignWhenCentered: false   // no rounding to whole points
        width: s.rightIcon ? ri.width : rt.advance; height: s.rightIcon ? ri.height : rt.height
        SfSymbol {
            id: rt; visible: !s.rightIcon
            x: bearing
            name: s.rightGlyph; pointSize: s.rightGlyphSize
            color: rma.pressed ? Tokens.label : Tokens.secondaryLabel
        }
        Loader { id: ri; sourceComponent: s.rightIcon; property bool pressed: rma.pressed }
        MouseArea { id: rma; objectName: "rightEnd"; anchors.fill: parent; anchors.margins: -3; onClicked: s._end(1) }
    }
    Item {
        id: track
        anchors.left: lg.visible ? lg.right : parent.left
        anchors.right: rg.visible ? rg.left : parent.right
        anchors.leftMargin: lg.visible ? s.glyphGap : 0
        anchors.rightMargin: rg.visible ? s.glyphGap : 0
        height: s._m.height
        readonly property real usable: s.fillToEnds ? width : width - s.knobWidth
        // fill end = knob centre; fillToEnds: the fill spans 0 .. width and the knob stays half a knob inside
        readonly property real fillW: s.fillToEnds ? pos.value * width : s.knobWidth / 2 + pos.value * usable
        readonly property real knobCx: (s.fillToEnds ? Math.max(s.knobWidth / 2, Math.min(width - s.knobWidth / 2, fillW))
                                                     : fillW) + s._over

        Item { // what the pressed knob's lens shows: track, fill and ticks
            id: bar
            anchors.fill: parent
            Rectangle {
                visible: !s.trackFill
                x: Math.min(0, s._over)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width + Math.abs(s._over); height: s.trackHeight; radius: height / 2
                color: s.trackColor
            }
            Loader {
                active: s.trackFill !== null
                x: Math.min(0, s._over)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width + Math.abs(s._over); height: s.trackHeight
                sourceComponent: s.trackFill
            }
            Rectangle { // fill to the knob's centre; disabled: grey (Q-06)
                x: Math.min(0, s._over)
                anchors.verticalCenter: parent.verticalCenter
                width: track.fillW + Math.abs(s._over); height: s.trackHeight; radius: height / 2
                color: s.fillColor
                Rectangle { // held: the press layer over the fill
                    visible: s._lift > 0
                    anchors.fill: parent; radius: parent.radius
                    color: Qt.alpha(Tokens.control.sliderPressOverlay, Tokens.control.sliderPressOverlay.a * s._lift)
                }
            }
            Repeater {
                model: s.tickMarks > 1 ? s.tickMarks : 0
                Rectangle {
                    required property int index
                    width: s._m.tick; height: s._m.tick; radius: s._m.tick / 2
                    x: G.tickX(track.width, s._m.knobWidth, index, s.tickMarks) - width / 2
                    y: s._m.tickY
                    color: Tokens.control.disabledText
                }
            }
        }
        Knob {
            visible: s.knobShown || s._dragging || s._lift > 0
            restW: s.knobWidth; restH: s.knobHeight
            liftW: s.lensWidth; liftH: s.lensHeight
            lift: s._lift
            lensSource: bar
            lensBackdrop: s.lensBackdrop
            reduceMotion: s.reduceMotion
            cx: track.knobCx
            cy: track.height / 2
            FocusRing { visible: s.activeFocus; shapeRadius: parent.height / 2 }   // a capsule round the knob (focus-rings-light.png)
        }
        Repeater {
            model: s.labels
            Text {
                required property var modelData
                readonly property real f: modelData[1]
                y: s._m.height + 2
                x: f <= 0 ? 0 : f >= 1 ? track.width - width : s.knobWidth / 2 + f * track.usable - width / 2
                text: modelData[0]
                font: Typography.controlSmall
                color: s.enabled ? Tokens.label : Tokens.control.disabledText
            }
        }
        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -s.hitMargin
            anchors.bottomMargin: s.tickMarks > 1 ? -8 : -s.hitMargin
            preventStealing: true
            property real grabOffset: 0    // pointer minus knob centre when the knob was hit
            property bool touched: false   // this press changed the value (a track press always does)
            function upd(mx) {
                const raw = (mx - grabOffset - (s.fillToEnds ? 0 : s.knobWidth / 2)) / track.usable;
                let f = Math.max(0, Math.min(1, raw));
                if (s.overdrag > 0) {   // past an end: a damped stretch (Q-panels-09: 3.5 - 5 pt with the pointer 87 pt past)
                    const past = (raw - f) * track.usable;
                    s._pull = Math.sign(past) * s.overdrag * (1 - Math.exp(-Math.abs(past) / 30));
                }
                if (s.onlyTicks && s.tickMarks > 1)
                    f = Math.round(f * (s.tickMarks - 1)) / (s.tickMarks - 1);
                const v = s.from + f * (s.to - s.from);
                if (s._dragging && v === s._dragValue) return;
                s._dragValue = v;
                s._dragging = true;
                touched = true;
                s.moved(v);
                if (s._jump && !pos.moving) s._jump = false;   // nothing to spring to
            }
            onPressed: m => {
                const onKnob = s.knobShown && Math.abs(m.x - track.knobCx) <= s.knobWidth / 2;
                // grab: pointer minus the fill end (the knob's centre, or the fill end with fillToEnds)
                grabOffset = onKnob ? m.x - track.fillW : -s.trackPressOffset;
                s._jump = !onKnob;
                touched = false;
                if (onKnob) { s._dragValue = s.value; s._dragging = true; }   // a plain click on the knob changes nothing
                else upd(m.x);
            }
            onPositionChanged: m => { if (pressed) upd(m.x); }
            onReleased: m => {
                const v = s._dragValue;
                s.releaseModifiers = m.modifiers;
                s._pull = 0;
                s._dragging = false; s._jump = false;
                if (touched) { s.released(); s.committed(v); }
            }
            onCanceled: { s._pull = 0; s._dragging = false; s._jump = false; }
        }
    }
}
