import QtQuick

// A SwiftUI-style spring (response, dampingFraction; mass 1) for control motion.
// Unlike Behavior + NumberAnimation it keeps its velocity when the target changes
// (no restart from rest), and it steps once as soon as it is kicked, so the frame
// rendered right after a mouse-down already shows movement.
// stiffness = (2π / response)², damping = 4π · dampingFraction / response.
// Usage: Spring { id: lift; target: pressed ? 1 : 0 }  ...  scale: lift.value
QtObject {
    id: sp
    property real target: 0
    property real value: 0
    property bool _ready: false
    Component.onCompleted: { value = target; _ready = true; }   // initial values don't animate
    property real velocity: 0
    property real response: 0.5
    property real dampingFraction: 1
    property bool instant: false          // jump straight to the target (Reduce Motion, setup)
    readonly property bool moving: fa.running

    function snap() { fa.stop(); velocity = 0; value = target; }
    function _step(dt) {
        const r = Math.max(response, 0.02);   // 0 would make k and c infinite
        const k = Math.pow(2 * Math.PI / r, 2), c = 4 * Math.PI * dampingFraction / r;
        let v = velocity, x = value;
        for (let n = Math.max(1, Math.ceil(dt * 480)), h = dt / n; n > 0; --n) {
            v += (k * (target - x) - c * v) * h;   // semi-implicit Euler
            x += v * h;
        }
        velocity = v;
        value = x;
        if (Math.abs(target - x) < 1e-3 && Math.abs(v) < 1e-2) snap();
    }
    onTargetChanged: {
        if (instant || !_ready) { snap(); return; }
        if (!fa.running) { _step(1 / 60); fa.start(); }
    }
    onInstantChanged: if (instant) snap()

    property FrameAnimation _fa: FrameAnimation {
        id: fa
        // frameTime is 0 on the first tick after start; that frame was already stepped by the kick
        onTriggered: if (frameTime > 0) sp._step(Math.min(frameTime, 1 / 30))
    }
}
