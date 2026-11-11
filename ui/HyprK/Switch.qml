import QtQuick
import "controls.js" as G

// macOS 27.2.1 switch (MAC-ANSWERS.md Q-settings-16, -17 and PC #60 section 4): accent track when on, white
// capsule knob (Knob). Not glass at rest. On mouse-down the knob grows x1.56 into a clear lens (easeInEaseOut
// 0.20 s from that frame); on release it shrinks back with the travel spring while it slides. The knob travels on
// a spring (SwiftUI response 0.47, dampingFraction 0.7) that carries it 4 % past the end and is cut after 27 frames
// (0.46 s: the knob jumps the last 1.8 % home, PC #67 A3); the track colour cross-fades in
// 0.24 s from the release. Click toggles on release; the knob can also be dragged across and lands on the nearer
// end. Space toggles when it has keyboard focus.
// Sizes: controlSize "regular" 54 x 24, "small" 44 x 20, "mini" 36 x 16 (Settings; default Tokens.switchSize).
// Controlled: it shows `checked` and emits toggled(value); the caller owns the state, so
// `checked: backend.on; onToggled: on => backend.set(on)` keeps its binding.
Item {
    id: sw
    property bool checked: false
    property string controlSize: Tokens.switchSize
    property bool reduceMotion: Tokens.reduceMotion
    readonly property bool pressed: ma.pressed
    signal toggled(bool value)
    readonly property var _m: G.switchTrack(controlSize)
    implicitWidth: _m.width
    implicitHeight: _m.height
    activeFocusOnTab: true

    // knob position, 0 off .. 1 on (passes the end a little while it lands)
    Spring {
        id: along
        target: sw.checked ? 1 : 0
        response: sw.reduceMotion ? Tokens.motion.reducedResponse : Tokens.motion.switchTravelResponse
        damping: sw.reduceMotion ? 1 : Tokens.motion.switchTravelDamping
        epsilon: 0.001
        instant: ma.dragging
        onTargetChanged: cut.restart()
    }
    Timer { id: cut; interval: Tokens.motion.switchTravelCut; onTriggered: along.snap() }
    // track colour 0 off .. 1 on: a cross-fade from the release, not tied to the knob
    property real _on: checked ? 1 : 0
    Behavior on _on { NumberAnimation { duration: Tokens.motion.switchTrackFade; easing.type: Easing.OutCubic } }

    // lens amount: grows while held (bezier), shrinks on the travel spring after the release (may dip below 0
    // for a frame or two, as the Mac knob does: 31.5 of 32 wide)
    property bool _held: false
    property real _grow: 0
    readonly property real _lift: _held ? _grow : shrink.value
    NumberAnimation {
        id: liftIn
        target: sw; property: "_grow"; from: 0; to: 1
        duration: Tokens.motion.switchLensIn
        easing.type: Easing.BezierSpline; easing.bezierCurve: Tokens.motion.switchLensCurve
    }
    Spring {
        id: shrink
        target: 0
        response: Tokens.motion.switchTravelResponse
        damping: Tokens.motion.switchTravelDamping
        epsilon: 0.002
    }
    function _press() { shrink.snap(); _grow = 0; _held = true; liftIn.restart(); }
    function _release() { liftIn.stop(); _held = false; shrink.from(_grow); }

    Rectangle { // track; disabled: the background layers at opacity 0.5 (the knob stays white)
        id: track
        anchors.fill: parent
        radius: height / 2
        readonly property color on: Tokens.control.switchOn
        readonly property color off: Tokens.control.trackOff
        color: Qt.rgba(off.r + (on.r - off.r) * sw._on, off.g + (on.g - off.g) * sw._on, off.b + (on.b - off.b) * sw._on,
                       (off.a + (on.a - off.a) * sw._on) * (sw.enabled ? 1 : Tokens.control.disabledOpacity))
        FocusRing { visible: sw.activeFocus }
    }
    Knob {
        restW: sw._m.knobWidth; restH: sw._m.knobHeight
        grow: Tokens.motion.switchLift
        lift: sw._lift
        lensSource: track
        reduceMotion: sw.reduceMotion
        cx: G.switchKnobX(sw._m, along.value) + sw._m.knobWidth / 2
        cy: sw.height / 2
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -4
        preventStealing: true
        property bool dragging: false
        property real pressX: 0
        property real grabOffset: 0     // pointer minus knob centre at mouse-down
        readonly property real range: sw._m.width - 2 * sw._m.inset - sw._m.knobWidth
        function knobCx(a) { return G.switchKnobX(sw._m, a) + sw._m.knobWidth / 2; }
        function land() { along.target = Qt.binding(() => sw.checked ? 1 : 0); }
        onPressed: m => {
            pressX = m.x;
            grabOffset = m.x - 4 - knobCx(Math.max(0, Math.min(1, along.value)));
            dragging = false;
            sw._press();
        }
        onPositionChanged: m => {
            if (!dragging && Math.abs(m.x - pressX) > Tokens.motion.dragThreshold) dragging = true;
            if (dragging) // the knob keeps the spot it was grabbed at
                along.target = Math.max(0, Math.min(1, (m.x - 4 - grabOffset - knobCx(0)) / range));
        }
        onReleased: {
            const v = dragging ? along.value > 0.5 : !sw.checked;
            dragging = false;           // spring on: lands from where the knob is
            sw._release();
            if (v !== sw.checked) sw.toggled(v);
            land();                     // on the caller's new state, or back if it kept the old one
        }
        onCanceled: { dragging = false; sw._release(); land(); }
    }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Space && !e.isAutoRepeat) { sw.toggled(!sw.checked); e.accepted = true; }
    }

    Accessible.role: Accessible.CheckBox
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onToggleAction: toggled(!checked)
}
