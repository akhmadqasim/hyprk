import QtQuick
import Quickshell
import "../lib/motion.js" as Motion

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
    // where to start on creation (NaN = at target, no motion): 0 for surfaces created on open
    property real initial: NaN
    readonly property bool moving: fa.running
    signal started()
    // true when glass scales or moves with this value: the plugin glass only follows a moving
    // parent while its window re-measures every frame (ShellWindow.settleGlass)
    property bool settlesGlass: false
    onValueChanged: if (settlesGlass && moving) {
        const w = QsWindow.window;
        if (w && w.settleGlass) w.settleGlass(50);   // two frames past the last step
    }

    Component.onCompleted: {
        value = isNaN(initial) ? target : initial;
        velocity = 0;
        if (value !== target) { fa.start(); started(); }
    }

    // jump without motion (first layout, hidden items)
    function snap() { fa.stop(); value = target; velocity = 0; }

    onTargetChanged: {
        if (Math.abs(target - value) > epsilon || Math.abs(velocity) > epsilon * 10) {
            if (!fa.running) { fa.start(); s.started(); }
        }
    }

    function step(dt) {
        dt = Math.min(Math.max(dt, 0), 0.05);          // a stalled frame must not explode the integrator
        const [x, v] = Motion.springStep(value, velocity, target, response, damping, dt);
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
