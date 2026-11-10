.pragma library

// Liquid Glass motion math (SwiftUICore 27.2, /mnt/code/liquid-glass-re SPEC 10 and notes/round3).
// Theme.anim forwards these; tests in tests/run.mjs.

// Materialize: hidden glass is scaled up per axis around its anchor, min((dim + 16) / dim, 1.2)
// (AppearanceSettings.materialize: scale 1.2, maxPointScale 16; GlassAppearanceScaleEffect).
function clamp01(x) { return Math.max(0, Math.min(1, x)); }

function hiddenScale(dim) { return Math.min((dim + 16) / Math.max(dim, 1), 1.2); }

// Scale of one axis at materialize spring value v (0 hidden .. 1 shown; overshoot past 1 shrinks
// slightly below 1 like SwiftUI). reduce = Reduce motion: no scale at all.
function materializeScale(dim, v, reduce) {
    return reduce ? 1 : 1 + (1 - v) * (hiddenScale(dim) - 1);
}

// Interactive press (FlexInteraction cursor presets, SPEC 10.3): smaller side < 120 pt is
// ultraSmall (lift 2.5 pt, damping 0.629); from 120 small -> large over 40 pt (lift 2.25 -> 2,
// damping 0.375 -> 0.6). The lift becomes a scale (min + lift) / min; spring response 0.25 s.
function pressT(w, h) { return Math.max(0, Math.min(1, (Math.min(w, h) - 120) / 40)); }
function pressScale(w, h) {
    const m = Math.max(Math.min(w, h), 1);
    return (m + (m < 120 ? 2.5 : 2.25 - 0.25 * pressT(w, h))) / m;
}
function pressDamping(w, h) { return Math.min(w, h) < 120 ? 0.629 : 0.375 + 0.225 * pressT(w, h); }

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
