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

// Launch bounce, from the Dock's own code (macOS 27.2.1 Dock.app -[Tile updateBouncing] 0x10002d9f4 and
// -[Tile updateRect] 0x100012088; MAC-ANSWERS.md "REA 27.2.1: Dock", reference/re/27.2.1/decomp/dock-bounce.c).
// Half period 350 ms: one bounce lasts 700 ms at every tile size, a plain parabola h = H * 4u(1 - u),
// u = (t mod 700) / 700, on the ground only at u = 0 (one frame), no hold at the top, no squash.
const bounceMs = 700;

// Height in pt: (tile - 8) * 0.2 + 6 (the code's float 0x1002580c0 = 0.2): 11.0 at tile 33, 17.2 at tile 64.
// (The recording measured 18 at tile 64; the code is the source.)
function bounceHeight(tile) {
    return Math.max(0, (tile - 8) * 0.2 + 6);
}

// Height above the rest position `t` ms after the bounce started (any t >= 0; it repeats every 700 ms).
function bounceOffset(t, height) {
    const u = (((t % bounceMs) + bounceMs) % bounceMs) / bounceMs;
    return height * 4 * u * (1 - u);
}

// When the bounce stops: launching ends (the app has a window, or the 6 s cap) `stopMs` after it started;
// the bounce in progress is finished, so it ends at the next multiple of 700 ms (the code rounds _bounceDur up
// to (floor(t / 700) + 1) * 700). The icon lands at the end of its arc and never snaps down mid-air.
function bounceEnd(stopMs) {
    return (Math.floor(Math.max(0, stopMs) / bounceMs) + 1) * bounceMs;
}
