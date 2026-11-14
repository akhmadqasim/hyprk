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

// The drag stretch (applyScale 0x190c225cc, its input from ResolvedLocalGesture.value 0x190c20ae4): per axis, d = the
// pointer's travel from the press point and di = the same travel with the pointer clamped into the glass (0 .. size),
// k = (|d| - |di|) / thr + |di| / (4 thr); the axis grows by k, the other shrinks by k, and the glass shifts by
// size * k toward the pointer. thr = scaleDistanceThreshold (cursor): 60000 under 120 pt (small / ultraSmall), then
// 60000 -> 70000 (small -> large) by the same t. Tiny by design on the Mac: 100 pt past the edge = +0.17 %.
function pressStretchThreshold(w, h) { return pressUltra(w, h) ? 60000 : 60000 + 10000 * pressT(w, h); }
function flexStretch(d, di, thr) {
    if (d === 0 || thr <= 0) return 0;
    const a = Math.abs(di);
    return Math.sign(d) * ((Math.abs(d) - a) / thr + a / (4 * thr));
}
// [scaleX, scaleY, shiftX, shiftY] added to the lift for a press at (sx, sy) with the pointer at (px, py), in pt
function pressStretch(w, h, sx, sy, px, py) {
    const thr = pressStretchThreshold(w, h);
    const kx = flexStretch(px - sx, Math.max(0, Math.min(w, px)) - sx, thr);
    const ky = flexStretch(py - sy, Math.max(0, Math.min(h, py)) - sy, thr);
    const ax = Math.abs(kx), ay = Math.abs(ky);
    return [ax - ay, ay - ax, w * kx, h * ky];
}

// The press light (FlexInteraction "glow"; GLASS-INTERACTION.md 4): GlowContainer.body 0x190c1f0c4 draws two CALayers,
// both size x size (size = min(1.5 x the glass's shorter side, 160), updateGlow 0x190c24650), at the pointer, scaled by
// the glow scale, clipped to the glass:
// - FlexInteraction.BigGlow: an opaque white square under a backdrop-aware vibrantColorMatrix of
//   _ColorMatrix.YCC(black 0.05, white 1.05, saturation 1.2, hue 0) (0x190c1f6f0; argument order from
//   apply(blackWhite:saturation:hue:) 0x190ec5bd0's identity test): Y' = 0.05 + Y, chroma x 1.2;
// - FlexInteraction.LittleGlow: no fill, a white shadow of its circle (kCALayerCornerRadiusAutomaticPill, shadowPathIsBounds,
//   offset 0, opacity 1, shadowRadius size / 2) under the matrix YCC(0, 1, 1.5, 0) then a Fill of grey g
//   (_ColorMatrix.apply(fills:) 0x190ec52a4, tag 2: diag 1 / (1 - g)): g = sRGB(pow(0.7630, 2.4)) = 0.75 dark,
//   sRGB(pow(0.4313, 2.4)) = 0.40 light, so the colour is multiplied by 4 (dark) / 5/3 (light), saturation x 1.5.
// Each layer mixes the colour under it toward its matrix by its opacity x coverage (Verify B's vibrantColorMatrix law),
// the matrices NOT clamped: the layers composite in extended range and the display clips once at the end (measured,
// the 23.09.23 recording: R 155 G 169 B 180 -> 215 243 255 at the pointer can only come from an unclamped x4 dodge
// mixed in by ~0.14; a clamped one mixes toward white and cannot reach B 255 while R stays at 215).
// Opacities and the dissipation distance: the FlexInteraction cursor set of the glass (Settings(variant:size:)
// 0x1908b1100, automatic): under 120 pt ultraSmall (big 0.75, little 0.2625 decoded, 50 pt), then small -> large by
// the shorter side (big 0.75 -> 0, little 0.75 -> 0.0375, 50 -> 25 pt).
// FITTED (dark, the 23.09.23 recording, two presses, frames 196 -> 220 and 314 -> 330, the preview's 37 pt share
// button): the ultraSmall LittleGlow opacity 0.475 (decoded 0.2625) and its blur glowSigma = 1.3 radii (the CA shadow
// convention is not decoded; 1 was assumed). Press-ratio rms over the rings 4..50 pt .015 / .012, pixel rms 5.7 / 5.6
// levels (decoded unclamped .068 / 14.5, decoded clamped as e73a0d3 .235 / 45.8, the old flat gain fit .017 / 8.9).
// On screen 0.405 = 0.475 x 0.854: the recording darkens mid-tones more than highlights, which inflates a press ratio
// (GLASS-INTERACTION.md 4: the old flat fit's 0.41 in the recording was 0.35 on screen; the same factor here).
// The light / dark difference stays the decoded one (glowDodge); light mode has no recording.
const glowLittleUltra = 0.405;   // fitted, see above
const glowSigma = 1.3;           // fitted, see above
function glowSize(w, h) { return Math.min(1.5 * Math.min(w, h), 160); }
function glowPreset(w, h) {
    if (pressUltra(w, h)) return { big: 0.75, little: glowLittleUltra, dissipation: 50 };
    const t = pressT(w, h);
    return { big: 0.75 * (1 - t), little: 0.75 + (0.0375 - 0.75) * t, dissipation: 50 - 25 * t };
}
function srgbEncode(l) { return l <= 0.0031308 ? 12.92 * l : 1.055 * Math.pow(l, 1 / 2.4) - 0.055; }
function glowDodge(dark) { return 1 / (1 - srgbEncode(Math.pow(dark ? 0.7630332 : 0.4312796, 2.4))); }
// The LittleGlow's coverage at u radii from its centre: its circle (radius 1) blurred by a Gaussian of sigma s radii
// (the CA shadow, shadowRadius = the radius; the sigma per radius is fitted, glowSigma), integrated over the disc in
// polar steps.
function glowMask(u, s) {
    const N = 48, M = 48;
    let sum = 0;
    for (let i = 0; i < N; i++) {
        const rho = (i + 0.5) / N;
        for (let j = 0; j < M; j++) {
            const a = Math.PI * (j + 0.5) / M;   // half circle, doubled below
            const dx = u - rho * Math.cos(a), dy = rho * Math.sin(a);
            sum += rho * Math.exp(-(dx * dx + dy * dy) / (2 * s * s));
        }
    }
    return 2 * sum * (1 / N) * (Math.PI / M) / (2 * Math.PI * s * s);
}
// 16 samples of glowMask(u, glowSigma) at u = 0, 1/3, ..., 5 radii (the shader interpolates and draws nothing past the
// last; under 0.01 there). The shader indexes the table in quarters of its radius uniform: pass glowLutRadius(radius).
const glowLutStep = 1 / 3;
function glowLutRadius(r) { return 4 * glowLutStep * r; }
let _lut = null;
function glowLut() {
    if (_lut) return _lut;
    const out = [];
    for (let i = 0; i < 16; i++) out.push(glowMask(i * glowLutStep, glowSigma));
    _lut = out;
    return out;
}

// AppKit's toolbar item-group platter (NSToolbarPlatterView: one NSGlassEffectView over the whole capsule,
// -[NSToolbarPlatterView initWithFrame:] 0x18af2584c) does not show SwiftUI's press glow or lift on the Mac
// (settings/toolbar-backforward-rest-hover-press-dark.png: the pressed capsule is 146 px wide as at rest, +16 levels
// evenly end to end). Its pressed look is the glass material's interaction layer, read from the live glass dump
// (live/glass-params-{dark,light}.json, `regular+_interactionState=1` / `=2`, layer "0:CALayer", backdrop-aware
// vibrantColorMatrix over the whole glass shape): rgb' = 0.3125 rgb + 0.9375 (dark) / - 0.25 (light), alpha 0.1 in
// state 1, 0.05 in state 2, 0 at rest. Composited as c + a (clamp(M c) - c) (GLASS-INTERACTION.md 8, Verify B).
// State 1 is taken as the press: it gives 84..88 on the Mac panel's capsule (Mac 85..88), state 2 gives 78
// (TOOLBAR-REA-27.2.1.md). Which AppKit state maps to 1 is inferred from that fit, not traced.
const platterPressAlpha = 0.1;
const platterRolloverAlpha = 0.05;   // state 2, decoded; not drawn (the Mac's hover capsule reads no overlay)
function platterMatrix(dark) { return { slope: 0.3125, bias: dark ? 0.9375 : -0.25 }; }
function platterPress(c, dark, a) {   // one channel 0..1
    const m = platterMatrix(dark);
    const t = Math.min(1, Math.max(0, m.slope * c + m.bias));
    return c + a * (t - c);
}

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
