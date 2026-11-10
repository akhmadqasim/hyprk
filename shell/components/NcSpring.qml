import QtQuick

// A retargetable spring for the notification surfaces, parameterised like SwiftUI
// (response in seconds, dampingFraction; SPEC 9.9.4: Animation.default = 0.5, 1.0).
// Changing `target` mid-flight keeps the current value and velocity, so a stack that
// is collapsed while still expanding turns around smoothly instead of restarting.
// Idea from MacShell's Spring.qml (github.com/0-ss/MacShell, MIT); own code.
Item {
    id: s
    visible: false
    width: 0
    height: 0

    property real target: 0
    property real value: 0
    property real velocity: 0
    property real response: 0.5
    property real damping: 1.0
    property real epsilon: 0.002          // in the unit of value: 0.002 for 0..1, ~0.3 for pixels
    readonly property bool moving: fa.running
    signal started()

    Component.onCompleted: { value = target; velocity = 0; }

    // jump without motion (first layout, hidden items)
    function snap() { fa.stop(); value = target; velocity = 0; }

    onTargetChanged: {
        if (Math.abs(target - value) > epsilon || Math.abs(velocity) > epsilon * 10) {
            if (!fa.running) { fa.start(); s.started(); }
        }
    }

    function step(dt) {
        dt = Math.min(Math.max(dt, 0), 0.05);          // a stalled frame must not explode the integrator
        const w = 2 * Math.PI / Math.max(response, 0.02);
        const k = w * w, c = 2 * damping * w;
        const n = Math.max(1, Math.ceil(dt / 0.004));
        const h = dt / n;
        let v = velocity, x = value;
        for (let i = 0; i < n; i++) {
            v += (k * (target - x) - c * v) * h;
            x += v * h;
        }
        if (Math.abs(target - x) < epsilon && Math.abs(v) < epsilon * 10) {
            velocity = 0;
            value = target;
            fa.stop();
            return;
        }
        velocity = v;
        value = x;
    }

    FrameAnimation {
        id: fa
        onTriggered: s.step(frameTime)
    }
}
