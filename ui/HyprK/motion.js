.pragma library

// Liquid Glass motion math (SwiftUICore 27.2, /mnt/code/liquid-glass-re SPEC 10 and notes/round3).
// Values in Tokens.motion; tests in shell/tests/run.mjs.

// Materialize: hidden glass is scaled up per axis around its anchor, min((dim + 16) / dim, 1.2)
// (AppearanceSettings.materialize: scale 1.2, maxPointScale 16; GlassAppearanceScaleEffect).
function clamp01(x) { return Math.max(0, Math.min(1, x)); }

function hiddenScale(dim) { return Math.min((dim + 16) / Math.max(dim, 1), 1.2); }

// Scale of one axis at materialize spring value v (0 hidden .. 1 shown; overshoot past 1 shrinks
// slightly below 1 like SwiftUI). reduce = Reduce motion: no scale at all.
function materializeScale(dim, v, reduce) {
    return reduce ? 1 : 1 + (1 - v) * (hiddenScale(dim) - 1);
}

// Interactive press, SwiftUI FlexInteraction (SwiftUICore 27.2.1, reference/re/27.2.1/GLASS-INTERACTION.md):
// Settings(variant: .automatic, size:) 0x1908b1100 takes the cursor ParameterSet of `small` when the LONGER side is under
// 120 pt, with the ultraSmall changes (lift 2.5 pt, spring damping 0.629); from 120 it blends small -> large by
// t = clamp((shorter side - 80) / (160 - 80)) (associatedDimension 80 / 160): lift 2.25 -> 2, damping 0.375 -> 0.6;
// response 0.25 s throughout. applyScale 0x190c225cc turns the lift into a uniform scale (longer + lift) / longer, so
// the longer side grows by `lift` pt.
function pressT(w, h) { return Math.max(0, Math.min(1, (Math.min(w, h) - 80) / 80)); }
function pressUltra(w, h) { return Math.max(w, h) < 120; }
function pressLift(w, h) { return pressUltra(w, h) ? 2.5 : 2.25 - 0.25 * pressT(w, h); }
function pressScale(w, h) {
    const m = Math.max(Math.max(w, h), 1);
    return (m + pressLift(w, h)) / m;
}
function pressDamping(w, h) { return pressUltra(w, h) ? 0.629 : 0.375 + 0.225 * pressT(w, h); }

// One step of a SwiftUI-parameterised spring (response s, dampingFraction), semi-implicit Euler
// in <= 4 ms sub-steps. Returns [x, v].
function springStep(x, v, target, response, damping, dt) {
    const w = 2 * Math.PI / Math.max(response, 0.02);
    const k = w * w, c = 2 * damping * w;
    const n = Math.max(1, Math.ceil(dt / 0.004));
    const h = dt / n;
    for (let i = 0; i < n; i++) {
        v += (k * (target - x) - c * v) * h;
        x += v * h;
    }
    return [x, v];
}

// Spotlight mode buttons emerge from the field: button i (0 = nearest the field) starts `travel`
// px left of its place, so at v = 0 every button sits inside the field's right end, and springs
// out with the field's materialize value (fusing with the field on the way, then separating).
function emergeOffset(i, v, travel, pitch) {
    return (1 - v) * (travel + i * pitch);
}

// Qt's easing curves by QEasingCurve::Type number (Easing.Linear = 0, the In / Out / InOut / OutIn Quad, Cubic,
// Quart and Quint families 1..16, the Sine family 17..20), for FrameAnim. p and the result are 0..1.
function _pow(kind, n, p) {
    if (kind === 0) return Math.pow(p, n);                                        // In
    if (kind === 1) return 1 - Math.pow(1 - p, n);                                // Out
    if (kind === 2) return p < 0.5 ? Math.pow(2 * p, n) / 2 : 1 - Math.pow(2 - 2 * p, n) / 2;   // InOut
    return p < 0.5 ? (1 - Math.pow(1 - 2 * p, n)) / 2 : 0.5 + Math.pow(2 * p - 1, n) / 2;       // OutIn
}
function ease(type, p) {
    if (p <= 0) return 0;
    if (p >= 1) return 1;
    if (type >= 1 && type <= 16) return _pow((type - 1) % 4, 2 + Math.floor((type - 1) / 4), p);
    if (type === 17) return 1 - Math.cos(p * Math.PI / 2);
    if (type === 18) return Math.sin(p * Math.PI / 2);
    if (type === 19) return (1 - Math.cos(Math.PI * p)) / 2;
    if (type === 20) return p < 0.5 ? Math.sin(Math.PI * p) / 2 : 1 - Math.sin(Math.PI * p) / 2;
    return p;
}
// An Easing.BezierSpline list [c1x, c1y, c2x, c2y, ex, ey, ...] from (0, 0): y at x = p (x is monotonic per segment)
function bezierSpline(pts, p) {
    if (p <= 0) return 0;
    if (p >= 1) return 1;
    let x0 = 0, y0 = 0;
    for (let i = 0; i + 5 < pts.length; i += 6) {
        const x3 = pts[i + 4], y3 = pts[i + 5];
        if (p <= x3 || i + 11 >= pts.length) {
            const x1 = pts[i], y1 = pts[i + 1], x2 = pts[i + 2], y2 = pts[i + 3];
            const bx = u => { const v = 1 - u; return v * v * v * x0 + 3 * v * v * u * x1 + 3 * v * u * u * x2 + u * u * u * x3; };
            let lo = 0, hi = 1;
            for (let k = 0; k < 24; k++) {
                const mid = (lo + hi) / 2;
                if (bx(mid) < p) lo = mid; else hi = mid;
            }
            const u = (lo + hi) / 2, v = 1 - u;
            return v * v * v * y0 + 3 * v * v * u * y1 + 3 * v * u * u * y2 + u * u * u * y3;
        }
        x0 = x3;
        y0 = y3;
    }
    return p;
}
