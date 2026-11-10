import QtQuick
import ".."

// Slider with accent fill and a capsule knob that turns into a Liquid Glass lens while
// held (GlassKnob). value in [from, to]. Mouse-down on the knob grabs it where it was hit;
// mouse-down on the track sends the knob there (a short spring) and keeps tracking.
// tickMarks > 1 draws ticks under the track; onlyTicks snaps to them.
// Motion values: Theme.motion (SPEC "Controls motion").
Item {
    id: s
    property real from: 0
    property real to: 1
    property real value: 0
    property bool enabled_: true
    property int tickMarks: 0
    property bool onlyTicks: false
    property string leftGlyph: ""
    property string rightGlyph: ""
    property string leftText: ""      // small end labels ("Slow" / "Fast") instead of glyphs
    property string rightText: ""
    signal moved(real value)
    signal released()
    implicitWidth: 220
    implicitHeight: Theme.control.sliderKnobH + 4 + (tickMarks > 1 ? 8 : 0)
    opacity: enabled_ ? 1 : 0.4

    // While dragging, show the drag position without assigning `value`
    // (that would break the caller's binding to external state).
    property bool _dragging: false
    property real _dragValue: 0
    property bool _jump: false        // a track click is springing the knob to the pointer
    readonly property real _shown: _dragging ? _dragValue : value
    property bool reduceMotion: AppState.appearance.reduceMotion === true
    readonly property real _frac: to > from ? Math.max(0, Math.min(1, (_shown - from) / (to - from))) : 0

    Spring {
        id: pos
        target: s._frac
        response: Theme.motion.sliderJumpResponse
        dampingFraction: 1
        instant: !s._jump || s.reduceMotion
        // landed (within half a point): follow the pointer 1:1 from here on
        onValueChanged: if (s._jump && Math.abs(target - value) * track.usable < 0.5) s._jump = false
    }
    Spring {
        id: lift
        target: s._dragging ? 1 : 0     // Reduce Motion: lens without growth (GlassKnob)
        response: Theme.motion.sliderLiftResponse
        dampingFraction: Theme.motion.sliderLiftDamping
    }

    Text {
        id: lg; visible: text !== ""
        anchors.left: parent.left; anchors.verticalCenter: track.verticalCenter
        text: s.leftGlyph || s.leftText
        font.family: s.leftGlyph ? Theme.fontGlyph : Theme.fontText
        font.pixelSize: s.leftGlyph ? 15 : Theme.font.small
        color: Theme.secondaryLabel
    }
    Text {
        id: rg; visible: text !== ""
        anchors.right: parent.right; anchors.verticalCenter: track.verticalCenter
        text: s.rightGlyph || s.rightText
        font.family: s.rightGlyph ? Theme.fontGlyph : Theme.fontText
        font.pixelSize: s.rightGlyph ? 18 : Theme.font.small
        color: Theme.secondaryLabel
    }
    Item {
        id: track
        anchors.left: lg.visible ? lg.right : parent.left
        anchors.right: rg.visible ? rg.left : parent.right
        anchors.leftMargin: lg.visible ? 8 : 0
        anchors.rightMargin: rg.visible ? 8 : 0
        height: Theme.control.sliderKnobH + 4
        readonly property real usable: width - Theme.control.sliderKnobW
        readonly property real knobCx: Theme.control.sliderKnobW / 2 + pos.value * usable

        Item { // what the glass knob refracts
            id: trackLayer
            anchors.fill: parent
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: Theme.control.sliderTrack; radius: height / 2
                color: Theme.switchOff
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: track.knobCx; height: Theme.control.sliderTrack; radius: height / 2
                color: Theme.accent
            }
        }
        Repeater {
            model: s.tickMarks > 1 ? s.tickMarks : 0
            Rectangle {
                required property int index
                width: 1; height: 4; radius: 0.5
                x: Theme.control.sliderKnobW / 2 + index / (s.tickMarks - 1) * track.usable - width / 2
                y: track.height + 2
                color: Theme.secondaryLabel
            }
        }
        GlassKnob {
            source: trackLayer
            restW: Theme.control.sliderKnobW; restH: Theme.control.sliderKnobH
            grow: Theme.motion.sliderLift; growH: Theme.motion.sliderLift - 1
            mag: 1.6
            glass: lift.value
            reduceMotion: s.reduceMotion
            cx: track.knobCx
            cy: track.height / 2
        }
        MouseArea {
            anchors.fill: parent
            anchors.bottomMargin: s.tickMarks > 1 ? -8 : 0
            enabled: s.enabled_
            preventStealing: true
            property real grabOffset: 0    // pointer minus knob centre when the knob was hit
            function upd(mx) {
                let f = Math.max(0, Math.min(1, (mx - grabOffset - Theme.control.sliderKnobW / 2) / track.usable));
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
                const onKnob = Math.abs(m.x - track.knobCx) <= Theme.control.sliderKnobW / 2;
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
