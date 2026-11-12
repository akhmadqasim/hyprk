import QtQuick
import qs
import qs.HyprK as HK
import "../lib/spring.js" as SpringLib

// One property moved along an exact Apple spring (lib/spring.js), evaluated in closed form once per frame of the
// window it sits in (HyprK FrameClock): frame k after go() shows the spring k + 1 refresh intervals in, so the first
// frame already moves and no value is drawn twice or skipped. (Until session 11 this was a NumberAnimation on a
// fitted BezierSpline: Qt advances those from a 16 ms timer while several windows are exposed, which loses about one
// value per 0.4 s on screen and runs 4 % fast.)
// go(to) starts from the property's current value and keeps the velocity of a run still in flight
// (like SwiftUI retargeting a spring). cutAt > 0 stops the run at that time, where the spring really
// is (the property does not jump to `to`); otherwise it runs until within 0.001 of the distance and
// then lands on `to`. Reduce motion: the same curve squeezed into at most 0.15 s (Theme.ms).
// `duration` is the length of the last run in ms. settlesGlass: glass moves with the value, so the window's glass is
// re-measured in the frame that draws it (Tokens.glassStepped). An Item (invisible, 0 x 0): the clock needs a window.
// Usage: SpringCurve { id: fade; target: w; property: "fade"; spring: SpringLib.fromResponse(0.3, 1) }
//        ...  fade.go(1)
Item {
    id: a
    visible: false
    width: 0
    height: 0

    property QtObject target: null
    property string property: ""
    property var spring: SpringLib.fromResponse(0.5, 1)
    property real cutAt: 0
    // a run that starts from rest leaves with this velocity, in fractions of the distance per second (0: from rest)
    property real kick: 0
    property real goal: 0                 // the value of the last go()
    property real duration: 0
    property bool settlesGlass: false
    // frames of a newly shown window that do not tick (HyprK FrameClock.freshHold); 0 where the run already waited
    // for a swapped frame of its window
    property alias freshHold: clock.freshHold
    // spring seconds the run's first frame shows (0: one refresh interval in); the next run of go() takes it
    property real firstAt: 0
    readonly property bool running: clock.running
    readonly property bool landed: !running
    signal finished()

    property var _spring: null
    property real _from: 0
    property real _v0: 0          // start velocity in distances per second
    property real _end: 0         // spring seconds at which the run ends
    property real _rate: 1        // spring seconds per real second
    property real _first: 0       // firstAt of this run

    function _set(v: real): void {
        target[property] = v;
        if (settlesGlass) HK.Tokens.glassStepped(a);
    }
    function go(to: real): void {
        const cur = target[property];
        let v = kick * (to - cur);
        const flying = clock.running && _spring;
        if (flying) v = SpringLib.state(_spring, _v0, clock.at)[1] * (goal - _from);
        clock.stop();
        goal = to;
        if (cur === to) return;
        _spring = spring;
        _from = cur;
        _v0 = v / (to - cur);
        // the run's length: the cut, or where the spring stays within 0.001 of the distance (cached per spring for
        // runs from rest or with the fixed kick, lib/spring.js plan)
        _end = cutAt > 0 ? cutAt : (flying ? SpringLib.settleTime(_spring, _v0, 0.001) : SpringLib.settleSeconds(_spring, _v0));
        duration = Theme.ms(Math.round(_end * 1000));
        _rate = duration > 0 ? _end * 1000 / duration : 1;
        _first = firstAt;
        clock.start();
    }
    // jump without motion
    function snap(to: real): void {
        clock.stop();
        goal = to;
        _set(to);
    }
    function stop(): void { clock.stop(); }

    HK.FrameClock {
        id: clock
        watchdog: true
        readonly property real at: (elapsed / 1000 + (a._first > 0 ? a._first : interval / 1000)) * a._rate
        onTick: {
            const end = at >= a._end;
            if (end && a.cutAt <= 0) a._set(a.goal);
            else a._set(a._from + (a.goal - a._from) * SpringLib.state(a._spring, a._v0, end ? a._end : at)[0]);
            if (!end) return;
            stop();
            // not from inside the window's own frame: a handler may unmap or unload it
            Qt.callLater(a.finished);
        }
        // the window draws no frame: land now
        onStalled: {
            stop();
            a._set(a.cutAt > 0 ? a._from + (a.goal - a._from) * SpringLib.state(a._spring, a._v0, a._end)[0] : a.goal);
            a.finished();
        }
    }
}
