import QtQuick
import qs
import "../lib/spring.js" as SpringLib

// One property moved along an exact Apple spring (lib/spring.js): a single NumberAnimation on a
// BezierSpline fitted to the closed form, so no script runs per frame.
// go(to) starts from the property's current value and keeps the velocity of a run still in flight
// (like SwiftUI retargeting a spring). cutAt > 0 stops the run at that time, where the spring really
// is (the property does not jump to `to`); otherwise it runs until within 0.001 of the distance and
// then lands on `to`. Reduce motion: the same curve over at most 0.15 s (Theme.ms).
// Usage: SpringCurve { id: fade; target: w; property: "fade"; spring: SpringLib.fromResponse(0.3, 1) }
//        ...  fade.go(1)
NumberAnimation {
    id: a

    property var spring: SpringLib.fromResponse(0.5, 1)
    property real cutAt: 0
    // a run that starts from rest leaves with this velocity, in fractions of the distance per second (0: from rest)
    property real kick: 0
    property real goal: 0                 // the value of the last go()
    readonly property bool landed: !running

    property var _plan: null
    property var _planSpring: null
    property real _from: 0
    property double _t0: 0

    function go(to) {
        const now = Date.now(), cur = target[property];
        let v = 0;
        if (running && _plan) {
            const t = (now - _t0) / 1000 * _plan.duration / Math.max(1, duration);   // spring time
            v = SpringLib.velocityAt(_planSpring, _plan, _from, t);
        } else v = kick * (to - cur);
        stop();
        goal = to;
        if (cur === to && v === 0) return;
        _plan = SpringLib.plan(spring, cur, to, v, cutAt);
        _planSpring = spring;
        _from = cur;
        _t0 = now;
        from = cur;
        a.to = _plan.to;
        duration = Theme.ms(_plan.duration);
        easing.bezierCurve = _plan.curve;
        start();
    }
    // jump without motion
    function snap(to) {
        stop();
        goal = to;
        target[property] = to;
    }
    easing.type: Easing.BezierSpline
    onFinished: if (cutAt <= 0) target[property] = goal
}
