import QtQuick
import "motion.js" as Motion

// A NumberAnimation that takes one value per frame of its window (FrameClock) instead of Qt's 16 ms animation timer:
// frame k after start() shows the curve (k + 1) refresh intervals in, so the first frame already moves, no value is
// drawn twice or skipped, and the speed is the screen's (the timer runs about 4 % fast, FrameClock.qml).
// Same members as the NumberAnimation uses it replaces: target, property, from (unset: the current value), to,
// duration, running, start(), stop(), restart(), complete(), finished(); the easing is `ease` (an Easing type:
// Linear, the Quad / Cubic / Quart / Quint / Sine families) or `curve` (an Easing.BezierSpline point list).
// Without a target it moves its own `value`. settlesGlass: glass moves with it (Tokens.glassStepped per frame).
// An Item (invisible, 0 x 0), because the clock needs a window.
Item {
    id: a
    visible: false
    width: 0
    height: 0

    property QtObject target: null
    property string property: ""
    property var from
    property real to: 0
    property real duration: 250
    property int ease: Easing.Linear
    property var curve: null
    property real value: 0
    property bool settlesGlass: false
    // frame k shows the curve (k + lead) intervals in. 2 for a motion whose first frame the Mac shows that far in (a
    // menu's fade after its item blinked: the first fading frame is 1.9 frames into the curve in AppKit's menus,
    // 1.6-1.7 in the Dock's, MAC-ANSWERS-16.md R16.1)
    property real lead: 1
    readonly property bool running: clock.running
    signal finished()

    property real _from: 0
    function _set(v: real): void {
        if (target) target[property] = v;
        else value = v;
        if (settlesGlass) Tokens.glassStepped(a);
    }
    function start(): void {
        clock.stop();
        _from = from !== undefined && from !== null ? from : (target ? target[property] : value);
        if (!(duration > 0)) { _set(to); Qt.callLater(finished); return; }
        if (from !== undefined && from !== null) _set(_from);
        clock.start();
    }
    function restart(): void { start(); }
    function stop(): void { clock.stop(); }
    // jump to the end, without finished() (as Animation.complete() of a stopped animation does nothing)
    function complete(): void {
        if (!clock.running) return;
        clock.stop();
        _set(to);
    }
    function _eased(p: real): real {
        if (curve) return Motion.bezierSpline(curve, p);
        return Motion.ease(ease, p);
    }

    FrameClock {
        id: clock
        watchdog: true
        onTick: {
            let p = (elapsed + a.lead * interval) / a.duration;
            if (p > 0.98) p = 1;   // a run of n frames must not take n + 1 for a rounding error
            a._set(p >= 1 ? a.to : a._from + (a.to - a._from) * a._eased(p));
            if (p < 1) return;
            stop();
            // not from inside the window's own frame: a handler may unmap or unload it
            Qt.callLater(a.finished);
        }
        onStalled: {
            stop();
            a._set(a.to);
            a.finished();
        }
    }
}
