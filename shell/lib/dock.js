// Dock geometry, magnification, bounces and sections, pure functions (tested in shell/tests/run.mjs).
.pragma library

// ---------- geometry ----------
// Measured on macOS 27.2.1 (MAC-ANSWERS.md Q-dock-02..07, reference/re/27.2.1/live/dock/dock-geometry.json,
// AX frames of 17 tiles + 2 separators at tilesize 32, 33, 48 and 64). Per tile size T:
//   item   AX item width: T + 2 (32, 33), T + 4 (48, 64); the item frames abut (no gap)
//   height background height = item height: T + 14 (32, 33), T + 20 (48, 64)
//   margin background edge to the first item: 3.2 (32, 33), 8.1 (48), 8.9 (64)
//   sep    separator item 15.3 (32), 15.8 (33), 23.4 (48), 30.6 (64): about 0.478 T
//   radius corner, circle fit: 14 (32, 33), 21.1 (48), 27.6 (64); continuous-corner fit 31.1 at 64
// Between the measured sizes the extras are interpolated linearly in T, outside they are held.
const _T = [32, 33, 48, 64];
const _ITEM = [2, 2, 4, 4];
const _HEIGHT = [14, 14, 20, 20];
const _MARGIN = [3.2, 3.2, 8.1, 8.9];
const _SEP = [15.3 / 32, 15.8 / 33, 23.4 / 48, 30.6 / 64];   // separator item / T
const _RADIUS = [14 / 32, 14 / 33, 21.1 / 48, 27.6 / 64];   // circle-fit radius / T
const _CONTINUOUS = 31.1 / 27.6;                            // continuous / circle fit, measured at 64 only

function _interp(t, ys) {
    if (t <= _T[0]) return ys[0];
    for (let i = 1; i < _T.length; i++)
        if (t <= _T[i]) return ys[i - 1] + (ys[i] - ys[i - 1]) * (t - _T[i - 1]) / (_T[i] - _T[i - 1]);
    return ys[ys.length - 1];
}

// All Dock geometry for tile size `tile` (pt):
//   item, height, margin, separator (cell widths and the background height),
//   radius (continuous corner, for the compositor glass) and radiusCircle (the QML fallback),
//   iconTop (background top to the tile top: the tile is centred), artInset (tile edge to the icon
//   art: 100 of 1024 per side, the macOS icon grid), dot (running dot diameter 4.1, centre 5 below
//   the art bottom), sepInset (separator line from background top + 6 to bottom - 6, 1 pt wide),
//   bottomGap (background bottom to the screen edge, 5 at every size).
function metrics(tile) {
    const t = tile > 0 ? tile : 64;
    const height = t + _interp(t, _HEIGHT);
    const radiusCircle = t * _interp(t, _RADIUS);
    return {
        tile: t,
        item: t + _interp(t, _ITEM),
        height: height,
        margin: _interp(t, _MARGIN),
        separator: t * _interp(t, _SEP),
        radius: radiusCircle * _CONTINUOUS,
        radiusCircle: radiusCircle,
        iconTop: (height - t) / 2,
        artInset: t * 100 / 1024,
        dot: 4.1,
        dotBelowArt: 5,
        sepInset: 6,
        sepWidth: 1,
        bottomGap: 5,
    };
}

// Largest tile size up to `tile` at which `items` items and `separators` separators fit in `room` pt
// (macOS shrinks the Dock to the screen width); whole pt.
function fitTile(tile, items, separators, room) {
    for (let t = Math.round(tile); t > 16; t--) {
        const m = metrics(t);
        if (2 * m.margin + items * m.item + separators * m.separator <= room) return t;
    }
    return 16;
}

// ---------- magnification ----------
// From the Dock's own code (27.2.1 Dock FUN_1000118d4 and the edge mapping at 0x100011b68, MAC-ANSWERS.md
// "REA 27.2.1: Dock" section 2): with tile T, large size L and the pointer at c (clamped to the bar),
//   F = 3 T,  Rs = ((L - T) / 2) / sin(pi T / (4 F)) * fish   (fish 0..1 ramps it in and out)
//   map(x) = x + Rs sin(pi (x - c) / (2 F)) for |x - c| < F, else x +/- Rs
// and a tile's size is map(right edge) - map(left edge): T + (L - T) cos(pi d / (2 F)) for |d| <= F - T / 2
// (d = unmagnified centre distance). Nothing changes past d = F + T / 2 = 3.5 T.
function fishRadius(tile) {
    return 3 * tile;
}
function fishShift(tile, large, fish) {
    if (!(fish > 0) || !(large > tile)) return 0;
    return (large - tile) / 2 / Math.sin(Math.PI / 12) * Math.min(1, fish);
}
function fishMap(x, c, F, Rs) {
    const d = x - c;
    if (d >= F) return x + Rs;
    if (d <= -F) return x - Rs;
    return x + Rs * Math.sin(Math.PI * d / (2 * F));
}
// tile size at unmagnified centre `center` with the pointer at `focus`
function magnifiedSize(tile, large, fish, focus, center) {
    const F = fishRadius(tile), Rs = fishShift(tile, large, fish);
    if (Rs === 0) return tile;
    return fishMap(center + tile / 2, focus, F, Rs) - fishMap(center - tile / 2, focus, F, Rs);
}
// Enter / leave ramp of `fish` (27.2.1 Dock FUN_10005bf08, DockFloatAnimatedProperty with cosine ease
// in-out): floor(42 ln(|distance| / 2 + 1) + 1) ms, distance = the size change still to go in pt
// (147 ms for 64 -> 128 either way). fishSpeed 42 = -[DockBar fishSpeed].
function fishDuration(distance) {
    return Math.floor(42 * Math.log(Math.abs(distance) / 2 + 1) + 1);
}

// Lays out the Dock items left to right.
//   cells: kind of each item, "tile" or "separator"
//   o: { tile, large, fish, focus, dpr }  (focus in bar coordinates, from the background's left edge)
// Returns, in background coordinates:
//   center[] unmagnified item centres, x[] / w[] the item cells (magnified), size[] the icon size of
//   each tile (the separator's: its line height stays), baseWidth and width (the background), all
//   x / w snapped to device pixels; width whole logical px like the compositor glass region.
function layout(cells, o) {
    const m = metrics(o.tile);
    const dpr = o.dpr > 0 ? o.dpr : 1;
    const snap = v => Math.round(v * dpr) / dpr;
    const out = { center: [], x: [], w: [], size: [], width: 0, baseWidth: 0, metrics: m };
    // o.grow[i] (0..1): the slot of a tile being added or removed (Dock.qml), 1 when absent
    const widths = cells.map((k, i) => (k === "separator" ? m.separator : m.item) * (o.grow && o.grow[i] !== undefined ? o.grow[i] : 1));
    let bx = m.margin;
    for (const w of widths) { out.center.push(bx + w / 2); bx += w; }
    const left = m.margin, right = bx;
    out.baseWidth = Math.round(right + m.margin);
    const F = fishRadius(m.tile), Rs = fishShift(m.tile, o.large, o.fish);
    const c = Math.min(right, Math.max(left, o.focus));
    const map = x => Rs === 0 ? x : fishMap(x, c, F, Rs);
    const x0 = map(left);
    for (let i = 0; i < widths.length; i++) {
        const l = map(out.center[i] - widths[i] / 2) - x0 + m.margin;
        const r = map(out.center[i] + widths[i] / 2) - x0 + m.margin;
        out.x.push(snap(l));
        out.w.push(snap(r - l));
        out.size.push(cells[i] === "separator" ? m.tile
            : snap(Rs === 0 ? m.tile : map(out.center[i] + m.tile / 2) - map(out.center[i] - m.tile / 2)));
    }
    out.width = Math.round(map(right) - x0 + 2 * m.margin);
    return out;
}

// ---------- launch bounce ----------
// From the Dock's own code (macOS 27.2.1 Dock.app -[Tile updateBouncing] 0x10002d9f4 and
// -[Tile updateRect] 0x100012088; MAC-ANSWERS.md "REA 27.2.1: Dock", reference/re/27.2.1/decomp/dock-bounce.c).
// Half period 350 ms: one bounce lasts 700 ms at every tile size, a plain parabola h = H * 4u(1 - u),
// u = (t mod 700) / 700, on the ground only at u = 0 (one frame), no hold at the top, no squash.
// The Dock draws the offset in whole points (Dock.qml rounds it).
const bounceMs = 700;

// The tile RECT R the bounce heights are made from: the AX item width (35 at tile 33, 68 at tile 64,
// about tile * 17 / 16), not the tile size (MAC-ANSWERS "Verification of motion and glass claims (PC #67)" A1, A2).
function tileRect(tile) {
    return metrics(tile).item;
}

// Height in pt: (R - 8) * 0.2 + 6 (the code's float 0x1002580c0 = 0.2): 11.4 at tile 33 (11 on screen),
// 18.0 at tile 64; fits the recordings (verify/A/dock-launch-t33/t64.json) at RMS 0.39 / 0.47 pt.
function bounceHeight(tile) {
    return Math.max(0, (tileRect(tile) - 8) * 0.2 + 6);
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

// ---------- attention bounce ----------
// requestUserAttention (Hyprland's urgent window), from the Dock's own code (-[Tile updateBouncing] with
// _notifyBounce, DockGlobals init 0x1001a66d4; MAC-ANSWERS.md "REA 27.2.1: Dock" section 1): a 2000 ms cycle of
// three parabolic hops, 500 ms at 1, 326 ms at 0.5, 212 ms at 0.25 of the amplitude, then rest until 2000 ms.
// Amplitude (R + 1) pt (36 / 69 at tile 33 / 64, verify/A/dock-attention-*.json). It bounces for `bounce-duration` 60 s, then for `bounce-secondary-duration` 3 s every
// `bounce-secondary-interval` 60 s; a cycle that has started plays to its rest point.
const _HOPS = [[0, 500, 1], [500, 326, 0.5], [826, 212, 0.25]];
const attentionCycleMs = 2000;
const attentionRestMs = 1038;
function attentionHeight(tile) {
    return tileRect(tile) + 1;
}
// whether the attention cycle starting at `cycleStart` ms (after the app asked) plays
function attentionPlays(cycleStart) {
    if (cycleStart < 60000) return true;
    return cycleStart >= 120000 && (cycleStart - 120000) % 60000 < 3000;   // 3 s bursts at 120 s, 180 s, ...
}
// height above rest `t` ms after the app asked for attention; `stopMs` >= 0: it was answered then,
// and the cycle in progress stops at its rest point
function attentionOffset(t, height, stopMs) {
    if (!(t >= 0)) return 0;
    const start = Math.floor(t / attentionCycleMs) * attentionCycleMs;
    if (!attentionPlays(start)) return 0;
    if (stopMs >= 0 && t >= attentionEnd(stopMs)) return 0;
    const u = t - start;
    for (const [s, d, a] of _HOPS)
        if (u >= s && u < s + d) { const v = (u - s) / d; return height * a * 4 * v * (1 - v); }
    return 0;
}
// whether the attention bounce moves `t` ms after it started (its cycle plays and it has not landed)
function attentionPlaying(t, stopMs) {
    const start = Math.floor(Math.max(0, t) / attentionCycleMs) * attentionCycleMs;
    return attentionPlays(start) && (!(stopMs >= 0) || t < attentionEnd(stopMs));
}
// start (ms after the request) of the first playing cycle at or after `t`
function nextAttentionStart(t) {
    const start = Math.floor(Math.max(0, t) / attentionCycleMs) * attentionCycleMs;
    if (attentionPlays(start)) return Math.max(0, t);
    if (start < 120000) return 120000;
    return 120000 + (Math.floor((start - 120000) / 60000) + 1) * 60000;
}
// when an answered attention bounce has landed (ms after it started), or -1 while it is still asked
function attentionEnd(stopMs) {
    if (!(stopMs >= 0)) return -1;
    const start = Math.floor(stopMs / attentionCycleMs) * attentionCycleMs;
    return stopMs - start < attentionRestMs && attentionPlays(start) ? start + attentionRestMs : stopMs;
}

// ---------- sections ----------
// Dock items in order (macOS 27.2.1, MAC-ANSWERS.md Q-dock-11, Q-dock-14): the pinned apps; with
// "Show suggested and recent apps in Dock" (on by default) a separator, then every running unpinned app and up
// to 3 recent apps that are not running; a separator; Downloads and Trash. Without it the running unpinned apps
// follow the pinned ones. `recent` is most recent first.
function sections(pinned, runningUnpinned, recent, showRecents, others) {
    const sep = id => ({ id: id, separator: true });
    let out = pinned.slice();
    if (showRecents) {
        const ids = new Set(runningUnpinned.map(a => a.id));
        const rec = recent.filter(a => !ids.has(a.id)).slice(0, 3);
        const tail = runningUnpinned.concat(rec);
        if (tail.length > 0) out = out.concat([sep("hyprk-separator-recents")], tail);
    } else out = out.concat(runningUnpinned);
    return out.concat([sep("hyprk-separator")], others);
}
// ---------- slots ----------
// A tile added to the Dock grows its slot from 0 to full width in 0.25 s, a removed one shrinks out in 0.15 s
// (MAC-ANSWERS.md Q-dock launch bounce notes), both on the Dock's cosine ease in-out (DockFloatAnimatedProperty).
// Dock.qml keeps one ListModel row per slot so a delegate survives every change of the items (running windows,
// recents); a removed slot stays, `leaving`, where it was until its shrink ends.
const slotGrowMs = 250, slotShrinkMs = 150;
// one key per item: its id, made unique ("#2", "#3") if an id repeats
function slotKeys(items) {
    const seen = {};
    return items.map(it => {
        const k = String(it.id);
        seen[k] = (seen[k] || 0) + 1;
        return seen[k] > 1 ? k + "#" + seen[k] : k;
    });
}
// The edits that turn the slots `cur` ([{key, leaving}]) into `keys` in order, leaving slots kept in place:
// {op: "leave" | "revive", at}, {op: "move", from, to} (ListModel.move semantics), {op: "insert", at, key};
// applied one after the other. `slots` is the result.
function slotEdits(cur, keys) {
    const s = cur.map(c => ({ key: c.key, leaving: !!c.leaving }));
    const want = new Set(keys), ops = [];
    s.forEach((c, i) => {
        if (!c.leaving && !want.has(c.key)) { c.leaving = true; ops.push({ op: "leave", at: i }); }
    });
    let p = 0;
    for (const k of keys) {
        while (p < s.length && s[p].leaving && s[p].key !== k) p++;
        let j = s.findIndex(c => c.key === k);
        if (j < 0) {
            s.splice(p, 0, { key: k, leaving: false });
            ops.push({ op: "insert", at: p, key: k });
        } else {
            if (j !== p) {
                const c = s.splice(j, 1)[0];
                if (j < p) p--;
                s.splice(p, 0, c);
                ops.push({ op: "move", from: j, to: p });
            }
            if (s[p].leaving) { s[p].leaving = false; ops.push({ op: "revive", at: p }); }
        }
        p++;
    }
    return { ops: ops, slots: s };
}
function slotDuration(entering) { return entering ? slotGrowMs : slotShrinkMs; }

// the recent list after app `id` stopped running: it goes first, kept unique, at most `max`
function pushRecent(recent, item, max) {
    return [item].concat(recent.filter(a => a.id !== item.id)).slice(0, max || 3);
}

// ---------- label ----------
// App name label (27.2.1 DOCKLabelLayer / ECCartoucheGlassLayerController; MAC-ANSWERS.md "REA 27.2.1: Dock"
// section 3 and Q-dock-08): a glass capsule 26 pt tall (radius 13), text + 2 x 14 wide, at least 15 + 2 x 13 = 41
// wide (text at most 600, middle-truncated), its bottom 9 pt above the Dock background (the tail's tip 2.5).
function labelWidth(textWidth) {
    return Math.max(41, Math.min(600, textWidth) + 28);
}
