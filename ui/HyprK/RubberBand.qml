import QtQuick
import "rubberband.js" as RB

// Elastic overscroll of a Flickable (ListView, GridView, ...) for trackpad scrolling, as AppKit 27.2.1 does it
// (rubberband.js has the maths and the sources). Use: boundsBehavior: Flickable.StopAtBounds on the view (a mouse
// wheel then stops hard at the edge, as on the Mac) and RubberBand { flickable: view } anywhere inside it.
//
// Qt Flickable cannot do this itself: a trackpad scroll is a drag in QQuickFlickable::wheelEvent, so with
// OvershootBounds it stops at the edge and with DragOverBounds it stretches by Qt's own velocity-eased curve, and
// Wayland sends no momentum events, so a trackpad scroll stops dead on lift. This overlay takes the trackpad events
// (phase != NoScrollPhase) and leaves mouse-wheel steps to the Flickable:
//  - while the fingers move, deltas scroll 1:1; past an edge they stretch by AppKit's hyperbolic filter
//    (_NSScrollingRubberbandFilter: elastic = D (1 - 1 / (1 + |d| c / D)), c 0.075, D the visible size), after the
//    first 10 pt of pull;
//  - on lift a stretch returns by _NSElasticDeltaForTimeDelta (critically damped exp(-12.5 t)); otherwise the
//    content coasts on AppKit's Cates momentum quartic and, hitting an edge, bounces out by its velocity there and
//    returns the same way. Each is one SequentialAnimation of NumberAnimations with spline easings fitted once.
// A gesture mostly along an axis this view cannot scroll is passed on (nested views: Finder columns, Displays).
// The overlay takes no buttons and no hover; nothing runs at rest.
MouseArea {
    id: rb
    property Flickable flickable
    property real coefficient: RB.C_TRACKPAD
    readonly property bool animating: seq.running
    readonly property bool stretched: !!flickable && (_over(1) !== 0 || _over(2) !== 0)

    parent: flickable
    anchors.fill: parent
    z: 10000
    acceptedButtons: Qt.NoButton
    hoverEnabled: false

    property int _axis: 0        // this gesture: 0 undecided, 1 x, 2 y, -1 passed on
    property bool _gesture: false
    property real _pull: 0
    property var _samples: []

    function _x(a) { return a === 1; }
    function _lo(a) { const f = flickable; return _x(a) ? f.originX - f.leftMargin : f.originY - f.topMargin; }
    function _hi(a) {
        const f = flickable;
        return _x(a) ? Math.max(_lo(a), f.originX + f.contentWidth + f.rightMargin - f.width)
                     : Math.max(_lo(a), f.originY + f.contentHeight + f.bottomMargin - f.height);
    }
    function _pos(a) { return _x(a) ? flickable.contentX : flickable.contentY; }
    function _set(a, v) { if (_x(a)) flickable.contentX = v; else flickable.contentY = v; }
    function _dim(a) { return _x(a) ? flickable.width : flickable.height; }
    function _over(a) { const p = _pos(a), lo = _lo(a), hi = _hi(a); return p < lo ? p - lo : p > hi ? p - hi : 0; }
    // QQuickFlickable::xflick() / yflick()
    function _can(a) {
        const f = flickable, d = f.flickableDirection;
        const c = _x(a) ? f.contentWidth : f.contentHeight, s = _x(a) ? f.width : f.height;
        if ((d & Flickable.AutoFlickIfNeeded) && c > s) return true;
        if (d === Flickable.AutoFlickDirection) return Math.floor(c) !== Math.floor(s);
        return !!(d & (_x(a) ? Flickable.HorizontalFlick : Flickable.VerticalFlick));
    }

    function _begin() { seq.stop(); _gesture = true; _axis = 0; _pull = 0; _samples = []; }

    // velocity of the last 50 ms of deltas (pt/s); 0 when the fingers rested before lifting
    function _velocity() {
        const now = Date.now();
        let s = 0;
        for (const e of _samples) if (now - e.t <= 50) s += e.d;
        return s / 0.05;
    }

    function _play(a, segs) {
        if (!segs.length) return;
        const anims = [a1, a2, a3];
        for (let i = 0; i < 3; i++) {
            const an = anims[i], sg = segs[i];
            an.property = _x(a) ? "contentX" : "contentY";
            if (!sg) { an.duration = 0; an.from = an.to = segs[segs.length - 1].to; continue; }
            an.from = sg.from; an.to = sg.to;
            an.duration = Math.max(0, Math.round(sg.duration * 1000));
            if (sg.quart || !sg.curve) an.easing.type = Easing.OutQuart;
            else { an.easing.type = Easing.BezierSpline; an.easing.bezierCurve = sg.curve; }
        }
        seq.start();
    }

    function _release(a) {
        const v = _velocity(), over = _over(a);
        if (over !== 0) _play(a, RB.planReturn(over < 0 ? _lo(a) : _hi(a), over, over < 0 ? -v : v));
        else _play(a, RB.planMomentum(_pos(a), v, _lo(a), _hi(a)));
    }

    onWheel: w => {
        if (!flickable || w.phase === Qt.NoScrollPhase || w.phase === Qt.ScrollMomentum) {
            if (seq.running) seq.complete();   // a wheel step starts from a resting, in-bounds view
            w.accepted = false;
            return;
        }
        if (w.phase === Qt.ScrollBegin) { _begin(); return; }
        if (w.phase === Qt.ScrollEnd) {
            const a = _axis;
            _gesture = false; _axis = 0;
            if (a > 0) _release(a); else if (a < 0) w.accepted = false;
            return;
        }
        if (!_gesture) _begin();
        if (_axis < 0) { w.accepted = false; return; }
        const dx = w.pixelDelta.x, dy = w.pixelDelta.y;
        if (_axis === 0) {
            if (dx === 0 && dy === 0) return;
            const a = Math.abs(dx) > Math.abs(dy) ? 1 : 2;
            _axis = _can(a) ? a : -1;
            if (_axis < 0) { w.accepted = false; return; }
        }
        const d = -(_x(_axis) ? dx : dy);
        const r = RB.step(_pos(_axis), d, _lo(_axis), _hi(_axis), _dim(_axis), _pull, coefficient);
        _pull = r.pull;
        _set(_axis, r.pos);
        const now = Date.now();
        _samples = _samples.filter(e => now - e.t <= 50).concat([{ t: now, d: d }]);
    }

    SequentialAnimation {
        id: seq
        NumberAnimation { id: a1; target: rb.flickable }
        NumberAnimation { id: a2; target: rb.flickable }
        NumberAnimation { id: a3; target: rb.flickable }
    }
}
