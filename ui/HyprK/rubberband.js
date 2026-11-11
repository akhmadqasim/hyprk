.pragma library
// Rubber-band (elastic overscroll) maths of AppKit 27.2.1, for RubberBand.qml. Sources: reference/re/MAC-ANSWERS.md
// "Rubber-band scroll constants", reference/re/27.2.1/decomp/AppKit-rubberband.asm and the REA notes in
// reference/ours/rubberband/README.md (which code path a scroll view takes, the momentum curve).
//
// Positions are in content coordinates (contentY grows downwards). An overshoot is the signed distance past an
// edge: < 0 before the start, > 0 after the end. Velocities are in pt/s. Time is in seconds.

// NSScrollViewRubberbandStiffness, ...MinimumRequiredDeltaBeforeStretch (AppKit defaults)
var STIFFNESS = 20;
var MIN_DELTA_BEFORE_STRETCH = 10;
// NSScrollingBehaviorHyperbolicCoefficientTrackpad (touch is 0.55)
var C_TRACKPAD = 0.075;
var C_TOUCH = 0.55;
// _NSElasticDeltaForTimeDelta2: x(t) = (x0 + C1 v t) exp(-stiffness t / C2), v clamped to NSScrollViewScrollVelocityMax
var C1 = 0.31;
var C2 = 1.6;
var VELOCITY_MAX = 20000;
// _NSScrollingMomentumCatesCalculator: duration = (distance / K)^(1/4), position = distance - K (T - t)^4;
// it stops rubber-banding below REST pt and bisects the end time to BISECT s
var CATES_K = 1000;
var REST = 0.5;
var BISECT = 0.01;
// our animations run on until 0.05 pt (invisible even at 2x) so the curve matches AppKit's to the end; the last
// 0.05 pt is spread over the animation
var SETTLE = 0.05;
// return-rate 20 / 1.6 = 12.5 /s
var RATE = STIFFNESS / C2;

function sign(x) { return x < 0 ? -1 : 1; }

// _NSHyperbolicElasticDeltaForReboundDelta(d, c, D): finger travel past the edge -> visible stretch.
// D is the clip view's size along the axis (-[_NSScrollingRubberbandFilter clippingSize]); D <= 0 -> d / 20.
function elastic(d, D, c) {
    if (c === undefined) c = C_TRACKPAD;
    if (!(D > 0)) return d / STIFFNESS;
    return sign(d) * D * (1 - 1 / (1 + Math.abs(d) * c / D));
}
// _NSHyperbolicReboundDeltaForElasticDelta(e, c, D): the inverse; a stretch of D or more maps to 999 D / c.
function rebound(e, D, c) {
    if (c === undefined) c = C_TRACKPAD;
    if (!(D > 0) || !(c > 0)) return e * STIFFNESS;
    var a = Math.abs(e) / D;
    var r = a < 1 ? 1 / (1 - a) - 1 : 999;
    return sign(e) * D * r / c;
}

function clampV(v) { return Math.max(-VELOCITY_MAX, Math.min(VELOCITY_MAX, v)); }
// overshoot t s after release, from overshoot x0 (> 0) moving outwards at vOut pt/s (< 0: inwards)
function decay(x0, vOut, t) { return (x0 + C1 * clampV(vOut) * t) * Math.exp(-RATE * t); }
// first time after which |decay| stays below limit (default REST; bisected to BISECT s like the Cates calculator)
function restTime(x0, vOut, limit) {
    var REST_ = limit === undefined ? REST : limit;
    var f = function (t) { return Math.abs(decay(x0, vOut, t)); };
    var lo = 0, hi = 0.05;
    while (f(hi) >= REST_ && hi < 10) { lo = hi; hi *= 2; }
    if (f(lo) < REST_ && lo === 0) return 0;
    while (hi - lo > BISECT) { var m = (lo + hi) / 2; if (f(m) >= REST_) lo = m; else hi = m; }
    return hi;
}

// momentum after a release at v pt/s (content coordinates); AppKit's Cates quartic
function momentumDuration(v) { return Math.cbrt(Math.abs(clampV(v)) / (4 * CATES_K)); }
function momentumDistance(v) { var T = momentumDuration(v); return sign(v) * CATES_K * Math.pow(T, 4); }
function momentumAt(v, t) {   // distance travelled after t s
    var T = momentumDuration(v);
    var r = Math.max(0, T - Math.min(t, T));
    return sign(v) * CATES_K * (Math.pow(T, 4) - Math.pow(r, 4));
}
function momentumVelocity(v, t) { var T = momentumDuration(v); return sign(v) * 4 * CATES_K * Math.pow(Math.max(0, T - t), 3); }

// Qt easing (Easing.BezierSpline) for a progress function f on [0, 1] with f(0) = 0 and f(1) = 1: cubic Hermite
// segments through f at n nodes (derivatives by central differences). Built once per animation, never per frame.
function spline(f, n) {
    if (!n) n = 8;   // Qt 6.10 BezierSpline corrupted its heap with 16 segments (qmltestrunner abort); 8 is safe
    var h = 1 / n, e = 1e-4, out = [];
    var df = function (x) {
        var a = Math.max(0, x - e), b = Math.min(1, x + e);
        return (f(b) - f(a)) / (b - a);
    };
    for (var i = 0; i < n; i++) {
        var x0 = i * h, x1 = (i + 1) * h;
        out.push(x0 + h / 3, f(x0) + h * df(x0) / 3, x1 - h / 3, f(x1) - h * df(x1) / 3, x1, i === n - 1 ? 1 : f(x1));
    }
    return out;
}

// A plan is a list of segments {from, to, duration (s), curve (bezierCurve list) or quart: true}.
// Return to the edge from overshoot over (signed, past `edge`) with vOut pt/s outwards.
function planReturn(edge, over, vOut) {
    var x0 = Math.abs(over);
    if (x0 < 1e-6) return [];
    var T = restTime(x0, vOut, SETTLE);
    if (T <= 0) return [{ from: edge + over, to: edge, duration: 0, curve: null }];
    var xT = decay(x0, vOut, T);
    return [{ from: edge + over, to: edge, duration: T,
              curve: spline(function (s) { return 1 - (decay(x0, vOut, s * T) - s * xT) / x0; }) }];
}

// Momentum from pos at v pt/s inside [lo, hi]; hitting an edge it bounces out by the edge velocity and returns.
function planMomentum(pos, v, lo, hi) {
    v = clampV(v);
    var T = momentumDuration(v), dist = momentumDistance(v);
    if (Math.abs(dist) < REST) return [];
    var target = pos + dist;
    if (target >= lo && target <= hi) return [{ from: pos, to: target, duration: T, quart: true }];
    var edge = v > 0 ? hi : lo, e = Math.abs(edge - pos);
    var tE = T - Math.pow(Math.max(0, Math.pow(T, 4) - e / CATES_K), 0.25);
    var segs = [];
    if (e > 1e-6)
        segs.push({ from: pos, to: edge, duration: tE,
                    curve: spline(function (s) { return Math.abs(momentumAt(v, s * tE)) / e; }) });
    var vE = Math.abs(momentumVelocity(v, tE));
    var tp = 1 / RATE, xp = decay(0, vE, tp);
    if (xp < REST) return segs;
    var s = sign(v), tEnd = restTime(0, vE, SETTLE), xEnd = decay(0, vE, tEnd);
    segs.push({ from: edge, to: edge + s * xp, duration: tp,
                curve: spline(function (u) { return decay(0, vE, u * tp) / xp; }) });
    segs.push({ from: edge + s * xp, to: edge, duration: tEnd - tp,
                curve: spline(function (u) { return 1 - (decay(0, vE, tp + u * (tEnd - tp)) - u * xEnd) / xp; }) });
    return segs;
}

// One trackpad delta d (content coordinates) at pos in [lo, hi] with D visible; pull is the past-edge travel this
// gesture has swallowed so far (AppKit stretches only after MIN_DELTA_BEFORE_STRETCH). Returns {pos, pull}.
function step(pos, d, lo, hi, D, pull, c) {
    var over = pos < lo ? pos - lo : pos > hi ? pos - hi : 0;
    if (over === 0) {
        var np = pos + d;
        if (np >= lo && np <= hi) return { pos: np, pull: pull };
        var edge = np < lo ? lo : hi, ex = np - edge;
        var p = pull + Math.abs(ex);
        if (p <= MIN_DELTA_BEFORE_STRETCH) return { pos: edge, pull: p };
        return { pos: edge + elastic(sign(ex) * (p - MIN_DELTA_BEFORE_STRETCH), D, c), pull: MIN_DELTA_BEFORE_STRETCH };
    }
    var edge2 = over < 0 ? lo : hi;
    var r = rebound(over, D, c) + d;
    if (sign(r) === sign(over) && r !== 0) return { pos: edge2 + elastic(r, D, c), pull: pull };
    return { pos: Math.max(lo, Math.min(hi, edge2 + r)), pull: pull };   // pushed back in: the rest scrolls 1:1
}
