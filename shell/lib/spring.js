.pragma library

// Exact SwiftUI / CoreAnimation springs as QML NumberAnimation curves (no per-frame script).
// A spring is { response, ratio }: response = 2π/ω0 in seconds, ratio = damping ratio ζ (mass 1).
// Apple's notations convert as (MAC-ANSWERS.md "Spring notation"):
//   Spring(duration d, bounce b), CASpringAnimation(perceptualDuration d, bounce b): response d, ratio 1 - b (b >= 0)
//     or 1 / (1 + b) (b < 0)
//   spring(response r, dampingFraction f): response r, ratio f
//   interpolatingSpring(mass m, stiffness k, damping c): response 2π sqrt(m / k), ratio c / (2 sqrt(k m))
// The motion is normalised: from 0 at rest (or with initial velocity v0, in units of the distance per
// second) to 1. curve() fits it with cubic Hermite segments, written as an Easing.BezierSpline list;
// each segment's control points sit at 1/3 and 2/3 of its time span, so time is linear in the Bezier
// parameter and the spline is exact at every knot in value and slope. Knots are spread so each segment
// carries the same share of the fourth derivative's fourth root (the cubic Hermite error term), and
// segments are added until the worst error, sampled every 0.5 ms, is below `tol` of the distance.

function fromBounce(duration, bounce) {
    return { response: duration, ratio: bounce >= 0 ? 1 - bounce : 1 / (1 + bounce) };
}
function fromResponse(response, dampingFraction) {
    return { response: response, ratio: dampingFraction };
}
function fromPhysics(mass, stiffness, damping) {
    return { response: 2 * Math.PI * Math.sqrt(mass / stiffness), ratio: damping / (2 * Math.sqrt(stiffness * mass)) };
}

// [x, x'] at time t (seconds) of the normalised spring
function state(s, v0, t) {
    const w = 2 * Math.PI / s.response, z = s.ratio;
    if (Math.abs(z - 1) < 1e-6) {
        const b = v0 - w, e = Math.exp(-w * t);
        return [1 + (-1 + b * t) * e, (b - w * (-1 + b * t)) * e];
    }
    if (z < 1) {
        const wd = w * Math.sqrt(1 - z * z), a = z * w, b = (v0 - a) / wd;
        const e = Math.exp(-a * t), c = Math.cos(wd * t), sn = Math.sin(wd * t);
        return [1 + e * (-c + b * sn), e * (a * c - a * b * sn + wd * sn + b * wd * c)];
    }
    const q = Math.sqrt(z * z - 1), r1 = -w * (z + q), r2 = -w * (z - q);
    const c1 = (v0 + r2) / (r1 - r2), c2 = -1 - c1, e1 = Math.exp(r1 * t), e2 = Math.exp(r2 * t);
    return [1 + c1 * e1 + c2 * e2, r1 * c1 * e1 + r2 * c2 * e2];
}
function value(s, v0, t) { return state(s, v0, t)[0]; }

// fourth derivative of x (the ODE x'' = -ω²(x - 1) - 2ζω x' applied three times)
function _d4(s, v0, t) {
    const w = 2 * Math.PI / s.response, k = w * w, c = 2 * s.ratio * w;
    const [x, d1] = state(s, v0, t), e = x - 1;
    const d2 = -k * e - c * d1, d3 = -k * d1 - c * d2;
    return -k * d2 - c * d3;
}

// time after which the motion stays within tol of 1 (scanned in 1 ms steps, up to 10 s)
function settleTime(s, v0, tol) {
    let last = 0;
    for (let i = 0; i <= 10000; i++) {
        const t = i / 1000;
        if (Math.abs(value(s, v0, t) - 1) >= tol) last = t;
    }
    return last + 0.001;
}

// time of the first crossing of 1 (an underdamped spring), or settleTime when it never crosses
function firstCrossing(s, v0, tol) {
    for (let i = 1; i <= 10000; i++)
        if (value(s, v0, i / 1000) >= 1) return i / 1000;
    return settleTime(s, v0, tol);
}

// BezierSpline points for the motion over [0, T], scaled so the spline ends at (1, 1): value(t) / value(T).
// Use it with from = a, to = a + (b - a) * value(s, v0, T) to follow the spring exactly up to T.
function _spline(s, v0, T, knots) {
    const xT = value(s, v0, T), out = [];
    for (let i = 1; i < knots.length; i++) {
        const u0 = knots[i - 1], u1 = knots[i], du = u1 - u0;
        const a = state(s, v0, u0 * T), b = state(s, v0, u1 * T);
        const y0 = a[0] / xT, y1 = b[0] / xT, m0 = a[1] * T / xT, m1 = b[1] * T / xT;
        out.push(u0 + du / 3, y0 + m0 * du / 3, u1 - du / 3, y1 - m1 * du / 3,
                 i === knots.length - 1 ? 1 : u1, i === knots.length - 1 ? 1 : y1);
    }
    return out;
}
// worst |spline - spring| over [0, T] in units of the distance (sampled every 0.5 ms)
function splineError(s, v0, T, pts) {
    const xT = value(s, v0, T);
    let worst = 0, p0 = [0, 0];
    for (let i = 0; i < pts.length; i += 6) {
        const p1 = [pts[i], pts[i + 1]], p2 = [pts[i + 2], pts[i + 3]], p3 = [pts[i + 4], pts[i + 5]];
        const n = Math.max(2, Math.ceil((p3[0] - p0[0]) * T / 0.0005));
        for (let j = 0; j <= n; j++) {
            const u = j / n, iu = 1 - u;
            const bx = iu * iu * iu * p0[0] + 3 * iu * iu * u * p1[0] + 3 * iu * u * u * p2[0] + u * u * u * p3[0];
            const by = iu * iu * iu * p0[1] + 3 * iu * iu * u * p1[1] + 3 * iu * u * u * p2[1] + u * u * u * p3[1];
            worst = Math.max(worst, Math.abs(by * xT - value(s, v0, bx * T)));
        }
        p0 = p3;
    }
    return worst;
}
function curve(s, v0, T, tol) {
    tol = tol || 0.002;
    // cumulative |x''''|^(1/4) over 200 steps
    const N = 200, cum = [0];
    for (let i = 1; i <= N; i++)
        cum.push(cum[i - 1] + Math.pow(Math.abs(_d4(s, v0, (i - 0.5) / N * T)), 0.25));
    let pts = [];
    for (let n = 1; n <= 12; n++) {
        const knots = [0];
        for (let k = 1; k < n; k++) {
            const goal = cum[N] * k / n;
            let i = 1;
            while (cum[i] < goal) i++;
            knots.push((i - 1 + (goal - cum[i - 1]) / (cum[i] - cum[i - 1])) / N);
        }
        knots.push(1);
        pts = _spline(s, v0, T, knots);
        if (splineError(s, v0, T, pts) < tol) break;
    }
    return pts;
}

// Everything a NumberAnimation needs to run `s` from `from` to `to` (initial velocity `velocity` in
// value units per second), cut at `cutAt` seconds or at its settle time (within 0.001 of the distance):
// { duration (ms), curve, to } where `to` is where the spring really is at the cut.
function plan(s, from, to, velocity, cutAt) {
    const d = to - from, v0 = d !== 0 ? (velocity || 0) / d : 0;
    const T = cutAt > 0 ? cutAt : settleTime(s, v0, 0.001);
    const xT = value(s, v0, T);
    return { duration: Math.round(T * 1000), curve: curve(s, v0, T), to: from + d * xT, seconds: T, v0: v0 };
}
// velocity (value units per second) of a running plan `p` (from `from`) `t` seconds after its start
function velocityAt(s, p, from, t) {
    const d = (p.to - from) / value(s, p.v0, p.seconds);
    return t >= p.seconds ? 0 : d * state(s, p.v0, t)[1];
}
