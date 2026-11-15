// The Dock's Downloads stack: the pile on its tile and the popup a click opens (Fan or Grid), pure functions
// (tested in shell/tests/run.mjs). Every number is macOS 27.2.1's Dock.app (26B131), decoded in
// reference/re/27.2.1/MOTION-REA-27.2.1.md section 3 and GAPS-REA-dock.md section 4 (pseudocode:
// reference/re/27.2.1/decomp/motion-gaps.c), unless a comment says otherwise. Units: pt.
.pragma library

// ---------- the pile on the tile ----------
// -[DOCKStack _imageForCollapsedImages] 0x10000dbac, block 0x10000dea8: at most 3 items (_maxNumberOfCollapsedItems,
// 0x10000c3b4), newest in front, in a 128 x 128 canvas. Front 116 x 116 at (6, 0) (CG, y up), each one behind 12
// smaller (6 each side) and its bottom 18 higher, centred in x. No rotation, no shadow, no x offset.
// Returns the boxes front first in tile coordinates with y DOWN: {x, y, size} (y = the box's top).
function pile(tile, n) {
    const k = Math.max(0, Math.min(3, Math.floor(n) || 0)), u = tile / 128, out = [];
    for (let i = 0; i < k; i++) {
        const size = 116 - 12 * i;
        out.push({ x: (6 + 6 * i) * u, y: (128 - 18 * i - size) * u, size: size * u });
    }
    return out;
}

// ---------- the stage and the view ----------
// -[DOCKStack expandUsingHandler:...] 0x100019dc4, asm 0x10001a098..0x10001a0e8: for a bottom Dock the screen
// without the menu bar, minus the Dock bar's height; stage = int(0.8 W) x int(0.8 H) (0.8 at 0x100258438).
function stage(screenW, screenH, menuBarH, barH) {
    return { w: Math.trunc(screenW * 0.8), h: Math.trunc(Math.max(0, screenH - menuBarH - barH) * 0.8) };
}
// "View content as" (`_viewAs`): "fan" | "grid" | "list" | "automatic" (the default). Automatic on a bottom Dock:
// Fan while items <= stage height / 64, else Grid (0x10001a16c, 1/64 = 0x3f90000000000000). List is a menu.
function view(viewAs, count, stageH) {
    if (viewAs === "fan" || viewAs === "grid" || viewAs === "list") return viewAs;
    return stageH / 64 < count ? "grid" : "fan";
}

// ---------- fan ----------
// DOCKStackFanLayer: item box 64 x 64, icon 64 (0x100071acc), pitch 64. Viewable slots = floor(stage height / 64)
// (0x100071fa0). -[DOCKFolder expandedStackValueForKey:...] 0x10001df18: with more items than that the last slot reads
// "N More in Finder" (N = the items left, that slot included); otherwise one more slot "Open in Finder".
// Returns {items: how many files are shown, extra: the last slot's text}.
function fanSlots(count, stageH) {
    const max = Math.max(1, Math.floor(stageH / 64));
    if (count >= max) return { items: max - 1, extra: (count - max + 1) + " More in Finder" };
    return { items: count, extra: "Open in Finder" };
}
// -[DOCKStackFanLayer layout] 0x100072030 on the frame of -expandedFrameForStage: 0x100071ec0 (the tile's frame moved
// 24 off, the 24 at 0x100071f98: up on screen, measured, see below). Slot i: arc height y = int(t/2) + 32 + 64 i, x offset dx = 3000 - int(sqrt(3000^2 -
// y^2)) to the right, rotation atan(y / (3000 - dx)) (the code's -atan, CA's y-up, so clockwise on screen); the code
// places the centre at (x0 + dx, x0 + y) of that frame, x0 = int(t/2). So the centre is int(t/2) + y + 24 above the
// tile's bottom. The frame's reference layer is the tile's imageLayer (the icon box, t x t: see below). Inferred, not
// read: the item anchor (taken as the centre: no setAnchorPoint: on the fan item layer, the Dock's two calls are the
// grid cell 0x10001f638 and the fan label 0x100042668). Returns {dx, up (centre above the tile bottom), angle
// (degrees, clockwise), y}.
// The 24 is UP on screen, measured (MOTION-REA-27.2.1.md Round 4, R4.1: reference/screens/27.2.1/dock/
// stack-fan-open.mov, tile 31 at x 982, 9 items + "5 More in Finder"): every one of the 10 slots of the settled fan
// sits on int(t/2) + y + 24 above the icon box bottom to about 1 pt (first centre 85 measured, 86 here), the
// first item's box wholly above the Dock, the tile's chevron plate free below it. Round 3 (R3.3) had read the
// frame's y - 24 (asm 0x100071f68..0x100071f9c) as down in a y-up tree; the recording says the fan's frame is
// above the tile, so that reading was wrong (the conversion to the fan's layer was not read).
const fanRadius = 3000;
const fanShift = 24;
function fanItem(tile, i) {
    const half = Math.floor(tile / 2);
    const y = half + 32 + 64 * i;
    const dx = fanRadius - Math.trunc(Math.sqrt(fanRadius * fanRadius - y * y));
    return { dx: dx, up: half + y + fanShift, angle: Math.atan(y / (fanRadius - dx)) * 180 / Math.PI, y: y };
}
// -[DOCKStack getCollapsedLayoutFrames:count:] 0x100067df4, where the fan's items start and end: s = 1 / 2 / 3 for
// DockBar.tileSize < 32 / < 48 / larger (0x100067e88..0x100067ebc); frame i = {s(i+1), 3si, W - 2s(i+1), H - 2s(i+1)}
// (CG, y up), W x H the tile's imageLayer bounds; items past the 3rd use the 3rd. DockBar.tileSize is NOT the icon box:
// sub_100078598 (called with -desiredTileSize, the `tilesize` pref, before -setTileSize: at 0x10001164c) returns
// desired + 2 x tileInset (fmadd at 0x10007876c), tileInset = 1 for desired <= 47 (0x1000786a8..0x100078710), 2 up to
// 127 (0x100078640, 0x100078684), 3 above (0x1000785d4, 0x1000785fc); the imageLayer (-[DOCKTileLayer
// layoutImageLayer] 0x10000c524 -> _computeLayoutFrameFromBounds: 0x10007fa38, set at 0x10008015c) is the tile bounds
// less 2 x tileInset, so W = the pref = our `tile` (the icon box). So at tile 31 tileSize is 33 and s = 2, not 1:
// items 0 / 1 end at 27 / 23 (MOTION-REA Round 6).
function collapsedStep(tile) {
    const t = tile + 2 * (tile <= 47 ? 1 : tile <= 127 ? 2 : 3);
    return t < 32 ? 1 : t < 48 ? 2 : 3;
}
// Returns item i's collapsed centre above the tile bottom (x: the tile centre).
function collapsedUp(tile, i) {
    const s = collapsedStep(tile), j = Math.min(Math.max(0, i), 2);
    return tile / 2 + s * (2 * j - 1);
}
// One fan item at progress p (0 = in the pile, 1 = in place), already eased by the caller. -[DOCKStackFanAnimator
// expand:] 0x100063c2c: the position follows CGPathAddArc (0x100064984: centre the first item + (3000, 0), radius 3000
// at 0x100258428, start angle pi at 0x100258108, clockwise) on the same 3000 pt circle (centre int(t/2) + 24 above the
// tile bottom, 3000 right of the tile centre), the rotation goes from 0 to the layout angle. At p = 1 it is fanItem.
// `q`: the rotation's own progress (fanChannels .turn; it is an implicit animation, not the position's keyframe
// animation), p when left out. Returns {dx, up, angle}.
function fanAt(tile, i, p, q) {
    const end = fanItem(tile, i);
    const cy = Math.floor(tile / 2) + fanShift;
    const a0 = Math.asin(Math.max(-1, Math.min(1, (collapsedUp(tile, i) - cy) / fanRadius)));
    const a1 = Math.asin(end.y / fanRadius);
    const a = a0 + (a1 - a0) * p;
    // the pile's centre is on the tile's centre line, the code truncates the end point to whole points: blend both
    // remainders in so p = 0 and p = 1 land on them exactly
    const arcDx = v => fanRadius * (1 - Math.cos(v));
    return { dx: arcDx(a) - (1 - p) * arcDx(a0) + p * (end.dx - arcDx(a1)), up: cy + fanRadius * Math.sin(a) + p * (end.up - (cy + fanRadius * Math.sin(a1))),
             angle: end.angle * (q === undefined ? p : q) };
}
// Core Animation's named timing functions as QuartzCore 27.2.1 stores them (a table of 4 floats each at QuartzCore
// 0x18e119380, file offset 0x42b380: default (0.25, 0.1, 0.25, 1), linear, easeIn (0.42, 0, 1, 1), easeOut (0, 0, 0.58,
// 1), easeInEaseOut (0.42, 0, 0.58, 1)). An implicit animation takes "default": _CALayerCreateImplicitAnimation
// 0x18dd3e2d0 caches +[CAMediaTimingFunction functionWithName:@"default"] (cfstring 0x1e2d10710 -> "default"). An
// explicit CABasicAnimation without setTimingFunction: is linear. `name`: "default" | "easeInEaseOut" | "linear".
function caTiming(name, t) {
    const c = name === "default" ? [0.25, 0.1, 0.25, 1] : name === "easeInEaseOut" ? [0.42, 0, 0.58, 1] : null;
    const x = Math.max(0, Math.min(1, t));
    if (!c || x === 0 || x === 1) return x;
    const bez = (u, a, b) => { const v = 1 - u; return 3 * v * v * u * a + 3 * v * u * u * b + u * u * u; };
    let lo = 0, hi = 1;
    for (let k = 0; k < 40; k++) { const mid = (lo + hi) / 2; if (bez(mid, c[0], c[2]) < x) lo = mid; else hi = mid; }
    return bez((lo + hi) / 2, c[1], c[3]);
}
// What each part of the fan has done `ms` into an open or a close of `d` ms, as "how far open" 0..1 (MOTION-REA-27.2.1.md
// Round 3, R3.1). -[DOCKStackFanAnimator expand:] 0x100063c2c and -collapse: 0x100064d90, one CATransaction each,
// duration d = +[CATransaction animationDuration] (0.25, QuartzCore 0x18dd0a9b8; 5 s with Shift when slow motion is
// allowed, 0x1000642e0): position: CAKeyframeAnimation along the arc, kCAMediaTimingFunctionEaseInEaseOut (0x100064334,
// close 0x100065054); rotation and bounds (item size): setTransform: / setBounds: on the item, implicit, so the
// "default" curve (0x100064918, 0x1000649e8; close 0x1000655ac, 0x1000654cc); label (textBackgroundLayer): transform
// scale 1e-5 <-> identity, easeInEaseOut, duration d (0x100064380, 0x10006438c); its opacity a CABasicAnimation from the
// presentation value with no timing function: linear over d (0x100064ac8..0x100064af8, close 0x100065384..0x1000653e8).
function fanChannels(ms, d, closing) {
    const t = d > 0 ? Math.max(0, Math.min(1, ms / d)) : 1;
    const f = (name) => closing ? 1 - caTiming(name, t) : caTiming(name, t);
    // size: measured (MOTION-REA Round 4, R4.1), the open keeps every item at 64 from its first frame (the folder 117 px
    // wide at 2x in every frame of stack-fan-open.mov while it rises), the close shrinks it on "default" over d (rms
    // 0.01 of the fitted way); so on the open the implicit bounds animation does not show, size = 1 throughout
    return { pos: f("easeInEaseOut"), turn: f("default"), size: closing ? f("default") : 1, labelScale: f("easeInEaseOut"),
             labelOpacity: f("linear") };
}
// The item's side at progress p (same p as fanAt). At rest every fan item is 64 x 64: DOCKStackExpandedLayer's
// _itemSize is written only by -[DOCKStackFanLayer initWithStack:usingLayerSource:] 0x100071acc (64.0, 64.0) and read
// by -layout 0x100072030 (setBounds 0,0,size,size for every item); the grid's _sizeForStage: writes its own. No hover
// growth: -mouseEnteredItemLayer:fromDrag: 0x10007279c selects the item only during a drag or with the
// `mouse-over-hilite-stack` default on. Stock: off. DockGlobals' init (0x1001a5e94..0x1001a5f20) reads the key with
// CFPreferencesCopyValue (0x100206018, no registered default) and stores `value as? Bool` AND the cast's success, so an
// absent key is false (MOTION-REA Round 3, R3.4): a pointer hover draws nothing; a selected item gets
// a plate under it (-setSelectedIndex: 0x1000723d0: ECMaterialLayer, its bounds + 4, radius 6, its transform, 0.15 s)
// and keeps its own 64 bounds. During the open, -[DOCKStackFanAnimator
// expand:] 0x100063c2c sets each item's bounds to its collapsed frame's size with actions disabled (line 356 of
// decomp 0x100063c2c.c), re-enables them, then sets the item size (line 517): an implicit bounds animation over the
// same transaction, so the side grows from the pile's tile - 2s(j+1) (getCollapsedLayoutFrames 0x100067df4, j at most 2)
// to 64. -collapse: 0x100064d90 sets the collapsed size back with actions on (line 342). The bounds change is an
// implicit animation, so CA's "default" curve over the transaction's duration, not the position's ease-in-out: the
// caller passes fanChannels().size as p. Measured (MOTION-REA Round 4, R4.1): the open's growth does not show (64 from
// the first frame, fanChannels gives 1); the close's shrink does, on "default" over 0.25 s from the position's start.
// The close's end side at tile 31 (stack-fan-more-close-dark.mov): item 0's folder body 50 px wide at the end against
// 117 px at 64 pt, so 27.4 pt (s = 2 here: 27; the old s = 1 read gave 29); item 1 fitted about 20.5-21.6 (23 here: its
// page is behind the folder at the end, the least sure of the two).
// The Mac's "65.5 -> 78.3" (Q-dock-12) is the AX frame of the rotated 64 square: fanBox below. Its 64.6 step is the
// frames' top edges (64 + half the box growth per slot), so it confirms the constant size.
function fanSize(tile, i, p) {
    const s = collapsedStep(tile), j = Math.min(Math.max(0, i), 2);
    const pile = Math.max(1, tile - 2 * s * (j + 1));
    return pile + (64 - pile) * Math.max(0, Math.min(1, p));
}
// The axis-aligned box of a side x side square turned by `angle` degrees (what AX reports for a fan item)
function fanBox(side, angle) {
    const r = angle * Math.PI / 180;
    return side * (Math.abs(Math.cos(r)) + Math.abs(Math.sin(r)));
}
// The item's opacity `ms` into the close (duration d ms). -[DOCKStackFanAnimator collapse:] 0x100064d90: the first 3
// stay (they become the pile); the others fade over 0.1 s from d - 0.05 s (-0.05 at 0x100258430, 0.1 at 0x1002581f8).
// Display as Folder: every item fades from d/3 over 2d/3.
function fanCloseOpacity(i, ms, d, folder) {
    if (folder) return Math.max(0, Math.min(1, 1 - (ms - d / 3) / (2 * d / 3)));
    if (i < 3) return 1;
    return Math.max(0, Math.min(1, 1 - (ms - (d - 50)) / 100));
}
// Fan label (-[DOCKStackFanItemLayer _setText:] 0x100042474): a glass pill, radius 13, text at most 500 wide
// (0x100258068), the cartouche's pad 13 each side like the hover label (lib/dock.js labelWidth)
function fanLabelWidth(textWidth) {
    return Math.max(41, Math.ceil(Math.min(500, textWidth)) + 26);
}

// ---------- grid ----------
// -[DOCKStackGridLayer _sizeForStage:] 0x10001b4d4 at the default preferred item size 3: cell 128 (16 x 3 + 80), pitch
// for fitting 128 + 28. n = min(cells, int(stageW / pitch x stageH / pitch)); columns = ceil(sqrt n), rows = ceil(n /
// columns) (fcvtps at 0x10001b5d4, 0x10001b5e4); a non-zero remainder smaller than the rows adds a column. The cell
// shrinks to fit the stage. Panel W = columns x cell + 34, H = rows x cell + 44, + 10 with a title. The +8 of an
// always-on scroll bar (scrollbarVisibility 2, not traced) is left out. `cells` counts the "Open in Finder" cell.
// Q-dock-12 (11 files + that cell): 4 x 3, 546 x 438, the Mac's AX frame.
function gridSize(cells, stageW, stageH, title) {
    const base = 128, pitch = base + 28;
    const n = Math.max(1, Math.min(cells, Math.trunc((stageW / pitch) * (stageH / pitch))));
    let cols = Math.ceil(Math.sqrt(n)), rows = Math.ceil(n / cols);
    const rem = n % cols;
    if (rem !== 0 && rem < rows) { cols++; rows = Math.ceil(n / cols); }
    let cell = Math.trunc(stageW / cols);
    if (stageH < rows * cell) cell = Math.trunc(stageH / rows);
    cell = Math.max(1, Math.min(cell, base, Math.trunc(2 * pitch)));
    const allRows = Math.ceil(Math.max(1, cells) / cols);
    return { cols: cols, rows: rows, cell: cell, icon: cell - 28, width: cols * cell + 34, height: rows * cell + (title ? 54 : 44),
             allRows: allRows, scroll: allRows > rows };
}
// -[DOCKStackGridLayer _expandedFrameWithSize:...] 0x10001bc58 (asm 0x10001bd9c): x = int(tile centre - W/2), kept 30 pt
// inside the screen; the panel's bottom (the 12 pt tail band included) `gap` above `edge`: 11, 5 with magnification on.
// `edge` is the tile's icon box top, not the Dock background's: expandUsingHandler: passes the imageLayer's frame
// y + height (0x10001a2bc, y up), and the Mac's AX grid bottom 1051 is 11 above the icon top 1062 at tile 33 (Q-dock-12,
// dock-geometry.json bg top 1055 + 7). In screen coordinates (y down): {x, y}.
function gridPlace(tileCenterX, screenX, screenW, w, h, edge, magnification) {
    const x = Math.max(screenX + 30, Math.min(screenX + screenW - 30 - w, Math.trunc(tileCenterX - w / 2)));
    return { x: x, y: edge - (magnification ? 5 : 11) - h };
}
// Inside the panel (y down), -[DOCKStackGridLayer layout] 0x10001bfb8: glass body = the panel less the 12 pt tail band
// at the bottom; the grid {17, top, W - 34, rows x cell} with its bottom 24 above the panel's bottom (30 from the top
// with a title, the Mac's AX scroll area 912,643 in the group 895,613); cell i at column i % cols, row i / cols.
function gridCell(i, cols, cell) {
    return { x: (i % cols) * cell, y: Math.floor(i / cols) * cell };
}
// Where the tail sits on the body's bottom edge: the tile centre, kept clear of the corners (radius + half the tail)
function tailX(tileCenterX, panelX, w, radius, tail) {
    return Math.max(radius + tail / 2, Math.min(w - radius - tail / 2, tileCenterX - panelX));
}
