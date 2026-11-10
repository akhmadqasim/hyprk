import QtQuick
import "motion.js" as Motion

// A SwiftUI-parameterised spring (response s, dampingFraction; mass 1) for every hyprk motion.
// stiffness = (2π / response)², damping = 4π · dampingFraction / response.
// Changing `target` mid-flight keeps the current value and velocity (no restart from rest), and
// the spring steps once as soon as it is kicked, so the frame right after a mouse-down already moves.
// Usage: Spring { id: lift; target: pressed ? 1 : 0 }  ...  scale: 1 + 0.2 * lift.value
// An Item (invisible, 0x0) so hosts can tell which window it animates in (Tokens.glassStepped).
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
    property real epsilon: 0.002          // settle threshold in the unit of value (~0.3 for pixels)
    property real initial: NaN            // start value on creation (NaN = at target, no motion)
    property bool instant: false          // jump straight to the target (Reduce Motion, dragging)
    // true when glass scales or moves with this value: the shell re-measures the window's glass
    // every frame while it moves (Tokens.glassStepped, shell ShellWindow.settleGlass)
    property bool settlesGlass: false
    readonly property bool moving: fa.running
    signal started()

    property bool _ready: false
    Component.onCompleted: {
        value = isNaN(initial) || instant ? target : initial;
        velocity = 0;
        _ready = true;
        if (value !== target) _kick();
    }

    // jump without motion (first layout, hidden items)
    function snap() {
        const was = value;
        fa.stop();
        velocity = 0;
        value = target;
        if (settlesGlass && was !== target) Tokens.glassStepped(s);   // the glass moved with this jump too
    }

    function _kick() {
        if (fa.running) return;
        fa.start();
        started();
        _step(1 / 60);
    }
    function _step(dt) {
        const [x, v] = Motion.springStep(value, velocity, target, response, damping, Math.min(Math.max(dt, 0), 0.05));
        if (Math.abs(target - x) < epsilon && Math.abs(v) < epsilon * 10) { snap(); return; }
        velocity = v;
        value = x;
    }
    onTargetChanged: {
        if (!_ready) return;
        if (instant) snap();
        else if (Math.abs(target - value) > epsilon || Math.abs(velocity) > epsilon * 10) _kick();
    }
    onInstantChanged: if (instant) snap()
    onValueChanged: if (settlesGlass && moving) Tokens.glassStepped(s)

    FrameAnimation {
        id: fa
        // frameTime is 0 on the first tick after start; that frame was already stepped by the kick
        onTriggered: if (frameTime > 0) s._step(frameTime)
    }
}
