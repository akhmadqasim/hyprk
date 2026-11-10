// Dock geometry and launch bounce, pure functions (tested in shell/tests/run.mjs).
.pragma library

// Size of a tile whose centre (in the unmagnified layout) is `center`, with the pointer at `focus`.
// Raised cosine that is `big` under the pointer and falls to `base` at `range` px on each side.
// `amount` 0..1 ramps the whole curve in and out when the pointer enters or leaves the Dock.
// Curve shape: by eye (SPEC.md 7 has only its width and the 128 pt largesize).
function magnifiedSize(base, big, amount, focus, center, range) {
    if (!(amount > 0) || big <= base || !(range > 0)) return base;
    const d = Math.abs(focus - center) / range;
    if (d >= 1) return base;
    return base + (big - base) * Math.min(1, amount) * (Math.cos(d * Math.PI) + 1) / 2;
}

// Lays out the Dock tiles left to right.
//   widths: unmagnified width of each cell (a fixed cell such as the separator is negative: -width)
//   o: { base, big, amount, focus, range, spacing, sidePad, dpr }
// Returns { x: [], w: [], center: [] (unmagnified centres), width, baseWidth }: x and w are snapped
// to device pixels so icons, dots and the separator never shimmer between pixels while the sizes
// change every frame; width (background, side padding included) is whole logical px like the
// compositor glass region.
function layout(widths, o) {
    const dpr = o.dpr > 0 ? o.dpr : 1;
    const snap = v => Math.round(v * dpr) / dpr;
    const out = { x: [], w: [], center: [], width: 0, baseWidth: 0 };
    let bx = o.sidePad;
    for (let i = 0; i < widths.length; i++) {
        const bw = Math.abs(widths[i]);
        out.center.push(bx + bw / 2);
        bx += bw + o.spacing;
    }
    const gaps = widths.length > 0 ? o.spacing : 0;
    out.baseWidth = bx - gaps + o.sidePad;
    // past the centre of the first or last tile the curve stays put, so the end tile keeps its full
    // size under the pointer instead of the Dock shrinking away from it (by eye)
    const n = out.center.length;
    const focus = n ? Math.min(out.center[n - 1], Math.max(out.center[0], o.focus)) : o.focus;
    let x = o.sidePad;
    for (let i = 0; i < n; i++) {
        const w = widths[i] < 0 ? -widths[i] : magnifiedSize(o.base, o.big, o.amount, focus, out.center[i], o.range);
        out.x.push(snap(x));
        out.w.push(snap(w));
        x += w + o.spacing;
    }
    out.width = Math.round(x - gaps + o.sidePad);
    return out;
}

// Launch bounce: height above the rest position at `phase` 0..1 of one hop. A ball under gravity:
// a parabola, fastest at the bottom, stopped at the top, never below 0 (no squash, no overshoot).
function bounceOffset(phase, height) {
    const p = Math.min(1, Math.max(0, phase));
    return 4 * height * p * (1 - p);
}
