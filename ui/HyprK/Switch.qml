import QtQuick
import "controls.js" as G

// macOS 27.2.1 switch (MAC-ANSWERS.md Q-settings-16, -17 and PC #60 section 4): accent track when on, white
// capsule knob (Knob). Not glass at rest. On mouse-down the knob grows x1.56 into a clear lens (easeInEaseOut
// 0.20 s from that frame); on release it shrinks back with the travel spring while it slides. The knob travels on
// a spring (SwiftUI response 0.47, dampingFraction 0.7) that carries it 4 % past the end and is cut after 27 frames
// (0.46 s: the knob jumps the last 1.8 % home, PC #67 A3); the track colour cross-fades in
// 0.24 s from the release. Click toggles on release, also after a long hold; a drag flips the knob at the middle of
// the track (see the MouseArea). Space toggles when it has keyboard focus.
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
        lensHaze: Tokens.control.switchLensHaze
        lensRingOpacity: Tokens.control.switchLensRingOpacity
        lensRimBias: Tokens.control.switchLensRimBias
        lensRimSpread: Tokens.control.switchLensRimSpread
        lensShadow: Tokens.control.switchLensShadow
        lensOutlineWidth: Tokens.control.switchLensOutlineWidth
        restShadowHeld: Tokens.control.switchRestShadowHeld
        reduceMotion: sw.reduceMotion
        cx: G.switchKnobX(sw._m, along.value) + sw._m.knobWidth / 2
        cy: sw.height / 2
    }
    // Tracking as AppKit's NSSwitch 27.2.1 does it (_updateStateForDragAtPoint:isFinished:isDirectTouch: 0x18b16dbf0,
    // _stateForDragAtPoint: 0x18b16de40, _shouldToggleForEndTrackingAtPoint: 0x18b16e0c8; there is no timer in it):
    // - a click toggles on mouse-up when the pointer is still on the track, however long it was held (the Mac probe
    //   probe-switch-layers-dark.jsonl: held 0.77 and 0.80 s, the state flips at the release); released off the
    //   track without a drag across, nothing changes;
    // - a drag does not carry the knob: the knob jumps to the other side (on the travel spring) when the pointer
    //   crosses the middle of the track, or, when the press was on the empty half, after 0.4 of the track's width
    //   towards the other state; from then on the middle decides, and the release takes the side shown;
    // - dragged across and back: nothing changes and the click does not toggle either.
    // The state itself only changes at mouse-up; until then only the knob shows the side (`shown`).
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -4
        preventStealing: true
        property bool dragging: false           // the knob was dragged to the other side at least once
        property bool byDistance: false         // pressed on the empty half
        property bool start: false
        property bool shown: false
        property real pressX: 0
        function land() { along.target = Qt.binding(() => sw.checked ? 1 : 0); }
        function sideAt(x) {                     // x in the track's coordinates
            if (byDistance) return (x - pressX) * (start ? -1 : 1) > Tokens.motion.switchDragShare * sw.width ? !start : start;
            return x >= sw.width / 2;
        }
        onPressed: m => {
            start = shown = sw.checked;
            pressX = m.x - 4;
            dragging = false;
            byDistance = false;
            byDistance = sideAt(pressX) !== start;
            sw._press();
        }
        onPositionChanged: m => {
            const side = sideAt(m.x - 4);
            if (side === shown) return;
            dragging = true;
            byDistance = false;
            shown = side;
            along.target = side ? 1 : 0;
        }
        onReleased: m => {
            const x = m.x - 4, y = m.y - 4;
            const onTrack = x >= 0 && x <= sw.width && y >= 0 && y <= sw.height;
            const v = !dragging && onTrack ? !start : sideAt(x);
            dragging = false;
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
