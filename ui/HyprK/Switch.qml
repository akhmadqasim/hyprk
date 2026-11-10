import QtQuick
import "controls.js" as G

// macOS 27.2.1 switch (MAC-ANSWERS.md Q-settings-16, -17): accent track when on, white capsule knob (Knob).
// Not glass at rest. On mouse-down the knob grows x1.56 into a clear lens (45 ms delay, 185 ms ease-in-out, no
// overshoot) and shrinks back in 0.3 s on release. Click toggles on release; the knob can also be dragged across
// and lands on the nearer end. Space toggles when it has keyboard focus.
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

    // knob position, 0 off .. 1 on (overshoots a little while it lands)
    Spring {
        id: along
        target: sw.checked ? 1 : 0
        response: sw.reduceMotion ? Tokens.motion.reducedResponse : Tokens.motion.switchResponse
        damping: sw.reduceMotion ? 1 : Tokens.motion.switchDamping
        epsilon: 0.001
        instant: ma.dragging
    }
    readonly property real _a: Math.max(0, Math.min(1, along.value))

    // lens amount 0 .. 1: runs only between mouse-down and the end of the release
    property real _lift: 0
    SequentialAnimation {
        id: liftIn
        PauseAnimation { duration: Tokens.motion.lensDelay }
        NumberAnimation {
            target: sw; property: "_lift"; to: 1
            duration: Tokens.motion.lensDuration; easing.type: Easing.InOutSine
        }
    }
    NumberAnimation {
        id: liftOut
        target: sw; property: "_lift"; to: 0
        duration: Tokens.motion.lensRelease * sw._lift; easing.type: Easing.InOutSine
    }
    function _press() { liftOut.stop(); liftIn.start(); }
    function _release() { liftIn.stop(); if (_lift > 0) liftOut.start(); }

    Rectangle { // track; disabled: the background layers at opacity 0.5 (the knob stays white)
        anchors.fill: parent
        radius: height / 2
        readonly property color on: Tokens.control.switchOn
        readonly property color off: Tokens.control.trackOff
        color: Qt.rgba(off.r + (on.r - off.r) * sw._a, off.g + (on.g - off.g) * sw._a, off.b + (on.b - off.b) * sw._a,
                       (off.a + (on.a - off.a) * sw._a) * (sw.enabled ? 1 : Tokens.control.disabledOpacity))
        FocusRing { visible: sw.activeFocus }
    }
    Knob {
        restW: sw._m.knobWidth; restH: sw._m.knobHeight
        grow: Tokens.motion.switchLift
        lift: sw._lift
        // overshoot past an end flattens the knob against it instead of moving it
        squash: Math.max(0, along.value - 1, -along.value) * 2
        reduceMotion: sw.reduceMotion
        cx: G.switchKnobX(sw._m, sw._a) + sw._m.knobWidth / 2
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
            grabOffset = m.x - 4 - knobCx(sw._a);
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
