// Dock geometry and launch bounce, pure functions (tested in shell/tests/run.mjs).
.pragma library

// Half-width of the magnification curve: 222 pt at tilesize 64 (MAC-ANSWERS.md R2 (27.2.1), AX frames
// of every tile at 81 pointer positions, 64 -> 128). Only measured at 64; scaled with the tile.
function magnifyRange(base) {
    return base * 222 / 64;
}

// Size of a tile whose centre (in the unmagnified layout) is `center`, with the pointer at `focus`.
// MAC-ANSWERS.md R2 (27.2.1): size = base + (large - base) * (1 - (d / range)^2)^1.5 for d < range,
// d = distance from the pointer to the tile's unmagnified centre (RMS 0.4 pt against the measurement).
// `amount` 0..1 ramps the whole curve in and out when the pointer enters or leaves the Dock.
function magnifiedSize(base, big, amount, focus, center, range) {
    if (!(amount > 0) || big <= base || !(range > 0)) return base;
    const d = Math.abs(focus - center) / range;
    if (d >= 1) return base;
    return base + (big - base) * Math.min(1, amount) * Math.pow(1 - d * d, 1.5);
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

// Launch bounce height in pt for a tile size: 11 pt at tilesize 33, 18 pt at 64 (MAC-ANSWERS.md R2
// (27.2.1)), linear between and beyond the two measured points.
function bounceHeight(tile) {
    return Math.max(0, 11 + (tile - 33) * 7 / 31);
}

// Launch bounce: height above the rest position at `phase` 0..1 of one bounce (0.70 s).
// MAC-ANSWERS.md R2 (27.2.1) shape: rises for 0.4 of the period, holds at the top from 0.40 to 0.60
// (0.14 s), falls as the mirror image of the rise, and touches the ground only at the phase wrap (one
// frame). Rise = 1 - (1 - p / 0.4)^1.55, least-squares fit to the 19 measured points (RMS 0.22 pt at
// 11 pt; the plain parabola was 0.31 pt and has no hold). Never below 0, no squash.
function bounceOffset(phase, height) {
    const p = Math.min(1, Math.max(0, phase));
    const u = Math.min(p, 1 - p);
    return u >= 0.4 ? height : height * (1 - Math.pow(1 - u / 0.4, 1.55));
}
