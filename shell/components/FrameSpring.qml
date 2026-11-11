import QtQuick
import qs
import "../lib/spring.js" as SpringLib

// One property moved along an exact Apple spring (lib/spring.js), evaluated once per frame of the window it sits in
// (FrameClock): frame k after go() shows the spring k + 1 refresh intervals in, so the first frame already moves and no
// value is drawn twice or skipped. Same use as SpringCurve (go, snap, kick, goal, landed), for motions whose frames
// are measured against a Mac track; SpringCurve's NumberAnimation is advanced by Qt's 16 ms timer and loses about one
// value per 0.4 s on screen (FrameClock.qml). go(to) keeps the velocity of a run in flight. It lands on `to` once the
// spring is within 0.001 of the distance. Reduce motion: the same curve squeezed into 0.15 s.
FrameClock {
    id: a

    property QtObject target
    property string property
    property var spring: SpringLib.fromResponse(0.5, 1)
    // a run that starts from rest leaves with this velocity, in fractions of the distance per second (0: from rest)
    property real kick: 0
    property real goal: 0
    readonly property bool landed: !running

    property var _spring: null
    property real _from: 0
    property real _v0: 0          // start velocity in distances per second
    property real _rate: 1        // spring seconds per real second
    readonly property real _at: (elapsed + interval) / 1000 * _rate

    function go(to: real): void {
        const cur = target[property];
        let v = kick * (to - cur);
        if (running && _spring) v = SpringLib.state(_spring, _v0, _at)[1] * (goal - _from);
        stop();
        goal = to;
        if (cur === to) return;
        _spring = spring;
        _from = cur;
        _v0 = v / (to - cur);
        _rate = Theme.reduceMotion ? Math.max(1, 1.47 * spring.response / 0.15) : 1;
        start();
    }
    // jump without motion
    function snap(to: real): void {
        stop();
        goal = to;
        target[property] = to;
    }
    onTick: {
        const s = SpringLib.state(_spring, _v0, _at);
        if (Math.abs(s[0] - 1) < 0.001 && Math.abs(s[1]) < 0.05) {
            stop();
            target[property] = goal;
        } else target[property] = _from + (goal - _from) * s[0];
    }
}
