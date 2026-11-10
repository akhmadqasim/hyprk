import QtQuick
import "controls.js" as G

// macOS 27.2.1 slider (MAC-ANSWERS.md Q-settings-17, -18): track black/white a.098 with the accent fill up to the
// knob's centre, white 20 x 16 capsule knob (Knob). Not glass at rest; while held the knob grows x1.25 into a clear
// lens and the fill darkens by a black a.098 layer (20 ms delay, 150 ms ease-in-out; back in 150 ms).
// Mouse-down on the knob grabs it where it was hit; mouse-down on the track sends the knob there (ease-out, no
// overshoot) and keeps tracking. tickMarks > 1 draws 2 x 2 dots under the track; onlyTicks snaps to them.
// End glyphs sit beside the track (6 pt gap); text labels sit under it, 11 pt (Desktop & Dock): leftText /
// rightText, or `labels: [[text, fraction], ...]` (0 = left-aligned at the start, 1 = right-aligned at the end,
// otherwise centred under that knob position).
// Controlled: it shows `value` and emits moved(value) while dragged; the caller owns the state.
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
    property string leftText: ""
    property string rightText: ""
    property var labels: (leftText !== "" ? [[leftText, 0]] : []).concat(rightText !== "" ? [[rightText, 1]] : [])
    signal moved(real value)
    signal released()
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
        response: Tokens.motion.sliderJumpResponse
        damping: 1
        epsilon: 0.001
        instant: !s._jump || s.reduceMotion
        // landed (within half a point): follow the pointer 1:1 from here on
        onValueChanged: if (s._jump && Math.abs(target - value) * track.usable < 0.5) s._jump = false
    }
    // lens amount 0 .. 1, only between mouse-down and the end of the release
    property real _lift: 0
    SequentialAnimation {
        id: liftIn
        PauseAnimation { duration: Tokens.motion.sliderLiftDelay }
        NumberAnimation {
            target: s; property: "_lift"; to: 1
            duration: Tokens.motion.sliderLiftDuration; easing.type: Easing.InOutSine
        }
    }
    NumberAnimation {
        id: liftOut
        target: s; property: "_lift"; to: 0
        duration: Tokens.motion.sliderLiftRelease * s._lift; easing.type: Easing.InOutSine
    }
    on_DraggingChanged: if (_dragging) { liftOut.stop(); liftIn.start(); } else { liftIn.stop(); if (_lift > 0) liftOut.start(); }

    Text {
        id: lg; visible: s.leftGlyph !== ""
        anchors.left: parent.left; anchors.verticalCenter: track.verticalCenter
        text: s.leftGlyph
        font.family: Tokens.fontGlyph; font.pixelSize: 15
        color: Tokens.secondaryLabel
    }
    Text {
        id: rg; visible: s.rightGlyph !== ""
        anchors.right: parent.right; anchors.verticalCenter: track.verticalCenter
        text: s.rightGlyph
        font.family: Tokens.fontGlyph; font.pixelSize: 18
        color: Tokens.secondaryLabel
    }
    Item {
        id: track
        anchors.left: lg.visible ? lg.right : parent.left
        anchors.right: rg.visible ? rg.left : parent.right
        anchors.leftMargin: lg.visible ? 6 : 0
        anchors.rightMargin: rg.visible ? 6 : 0
        height: s._m.height
        readonly property real usable: width - s._m.knobWidth
        readonly property real knobCx: s._m.knobWidth / 2 + pos.value * usable

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: s._m.track; radius: height / 2
            color: s.enabled ? Tokens.control.trackOff : Tokens.control.sliderDisabled
        }
        Rectangle { // fill to the knob's centre; disabled: grey (Q-06)
            anchors.verticalCenter: parent.verticalCenter
            width: track.knobCx; height: s._m.track; radius: height / 2
            color: s.enabled ? Tokens.control.sliderFill : Tokens.control.sliderDisabled
            Rectangle { // held: black a.098 over the fill
                visible: s._lift > 0
                anchors.fill: parent; radius: parent.radius
                color: Qt.alpha(Tokens.control.pressOverlay, Tokens.control.pressOverlay.a * s._lift)
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
        Knob {
            restW: s._m.knobWidth; restH: s._m.knobHeight
            grow: Tokens.motion.sliderLift
            lift: s._lift
            reduceMotion: s.reduceMotion
            cx: track.knobCx
            cy: track.height / 2
            FocusRing { visible: s.activeFocus }
        }
        Repeater {
            model: s.labels
            Text {
                required property var modelData
                readonly property real f: modelData[1]
                y: s._m.height + 2
                x: f <= 0 ? 0 : f >= 1 ? track.width - width : s._m.knobWidth / 2 + f * track.usable - width / 2
                text: modelData[0]
                font: Typography.controlSmall
                color: s.enabled ? Tokens.label : Tokens.control.disabledText
            }
        }
        MouseArea {
            anchors.fill: parent
            anchors.bottomMargin: s.tickMarks > 1 ? -8 : 0
            preventStealing: true
            property real grabOffset: 0    // pointer minus knob centre when the knob was hit
            function upd(mx) {
                let f = Math.max(0, Math.min(1, (mx - grabOffset - s._m.knobWidth / 2) / track.usable));
                if (s.onlyTicks && s.tickMarks > 1)
                    f = Math.round(f * (s.tickMarks - 1)) / (s.tickMarks - 1);
                const v = s.from + f * (s.to - s.from);
                if (s._dragging && v === s._dragValue) return;
                s._dragValue = v;
                s._dragging = true;
                s.moved(v);
                if (s._jump && !pos.moving) s._jump = false;   // nothing to spring to
            }
            onPressed: m => {
                const onKnob = Math.abs(m.x - track.knobCx) <= s._m.knobWidth / 2;
                grabOffset = onKnob ? m.x - track.knobCx : 0;
                s._jump = !onKnob;
                if (onKnob) { s._dragValue = s.value; s._dragging = true; }   // a plain click on the knob changes nothing
                else upd(m.x);
            }
            onPositionChanged: m => { if (pressed) upd(m.x); }
            onReleased: { s._dragging = false; s._jump = false; s.released(); }
            onCanceled: { s._dragging = false; s._jump = false; }
        }
    }
}
