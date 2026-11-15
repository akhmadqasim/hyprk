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

// ---------- resize by the separator ----------
// Dock 27.2.1 -[DockBarMouseEventHandler _handleResizeDockEvent:type:] 0x1000830f4 (REA, Ghidra 12.1.4): the press
// keeps the pointer and the tile size; a drag sets desiredTileSize = start size + the pointer's travel away from the
// screen edge (up, for the bottom Dock), clamped to 16..128 and truncated to a whole size; with Option held
// (kCGEventFlagMaskAlternate) it is cut to a multiple of 16: (int)(size x 0.0625) x 16. The release writes `tilesize`
// (FUN_100080dcc, CFPreferencesSetAppValue).
function resizeTile(start, travel, snap) {
    let t = Math.trunc(Math.min(128, Math.max(16, start + travel)));
    if (snap) t = Math.trunc(t * 0.0625) * 16;
    return t;
}
// The resize area over a separator (either one), -[DockBar updateWithContext:showDockWindow:transaction:]
// 0x10007549c at 0x100077948 (bottom Dock): 12 pt wide about the separator's centre, the Dock background's height
// less 8 pt, from 4 pt under its top. In it the cursor is CoreCursor 0x20 (resize up-down; 0x1c left-right for a
// side Dock). Cell coordinates.
function resizeArea(cellWidth, barHeight) {
    return { x: cellWidth / 2 - 6, y: 4, width: 12, height: barHeight - 8 };
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

// ---------- the Downloads stack's menu ----------
// Rows as the 27.2.1 Dock's AX lists them (live/dock/dock-menus.json "Downloads stack"): Sort by, Display as and View
// content as are section headers (disabled), their choices below with a check on the current one. A choice this Dock
// cannot do stays disabled: there is no date added or created on Linux. View content as picks the stack popup
// (lib/dockstack.js view, modules/DockStack.qml). opts: { sort: "name" | "modified" | "kind", display: "stack" |
// "folder", view: "fan" | "grid" | "list" | "automatic" }
const downloadsSorts = [["Name", "name"], ["Date Added", ""], ["Date Modified", "modified"], ["Date Created", ""], ["Kind", "kind"]];
function downloadsMenu(opts) {
    const o = opts || {};
    const out = [{ label: "Sort by", disabled: true }];
    for (const s of downloadsSorts) out.push({ label: s[0], checked: s[1] !== "" && s[1] === (o.sort || "modified"), sort: s[1], disabled: s[1] === "" });
    out.push({ sep: true }, { label: "Display as", disabled: true });
    for (const d of [["Folder", "folder"], ["Stack", "stack"]]) out.push({ label: d[0], checked: d[1] === (o.display || "stack"), display: d[1] });
    out.push({ sep: true }, { label: "View content as", disabled: true });
    for (const v of [["Fan", "fan"], ["Grid", "grid"], ["List", "list"], ["Automatic", "automatic"]])
        out.push({ label: v[0], checked: v[1] === (o.view || "automatic"), view: v[1] });
    return out;
}

// ---------- the Dock's own menu (right click on the separator) ----------
// Dock.app/Contents/Resources/DockMenus.plist "dock" (27.2.1), titles from en.lproj/DockMenus.strings: TURN_HIDING_ON |
// TURN_HIDING_OFF and TURN_MAG_ON | TURN_MAG_OFF (one of each pair, by the current setting), POSITION_ON_SCREEN ▸ LEFT,
// BOTTOM, RIGHT, MINIMIZE_USING ▸ GENIE_EFFECT, SCALE_EFFECT, a separator, DOCK_SETTINGS. No separator between the
// first four rows in the plist. `cmd` names what the row does (shell/services/Apps.qml dockSeparatorMenu). This Dock is
// only at the bottom (Left and Right disabled) and the shell draws no minimize effect (both disabled, the choice
// checked). d: dock.json ({ autohide, magnification, minimizeEffect })
function dockOwnMenu(d) {
    const o = d || {};
    const effect = o.minimizeEffect === "scale" ? "scale" : "genie";
    return [
        { label: o.autohide ? "Turn Hiding Off" : "Turn Hiding On", cmd: "hiding" },
        { label: o.magnification ? "Turn Magnification Off" : "Turn Magnification On", cmd: "magnification" },
        { label: "Position on Screen", submenu: true, items: [
            { label: "Left", disabled: true }, { label: "Bottom", checked: true, cmd: "none" }, { label: "Right", disabled: true }] },
        { label: "Minimize Using", submenu: true, items: [
            { label: "Genie Effect", checked: effect === "genie", disabled: true },
            { label: "Scale Effect", checked: effect === "scale", disabled: true }] },
        { sep: true },
        { label: "Dock Settings…", cmd: "settings" },
    ];
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

// Launching ends at the latest 120 s after it started: -[Tile] `_bounceDur` = 120000 ms cap for the launch bounce
// (MAC-ANSWERS.md "REA 27.2.1: Dock" section 1)
const launchCapMs = 120000;
// the ids in `launching` ({ id: { start, end } }, end 0 while launching) whose cap has passed at wall time `now`, and the
// wall time of the next cap (0: none left)
function launchCaps(launching, now) {
    const due = [];
    let next = 0;
    for (const id in launching) {
        const b = launching[id];
        if (b.end !== 0) continue;
        const t = b.start + launchCapMs;
        if (t <= now) due.push(id);
        else if (next === 0 || t < next) next = t;
    }
    return { due: due, next: next };
}

// When the bounce stops: launching ends (the app has a window, or the cap) `stopMs` after it started;
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
// A tile taken out with the Dock menu's Options > Remove from Dock closes its gap in 0.25 s on the same ease (R10.2 c,
// screens/27.2.1/sound/dock-remove-menu-poof-sound.mov: the Dock's right edge per frame against the cosine ease in-out,
// best fit 250 ms, rms .018 at 1 px of 32; 150 ms fits with rms .143).
const slotGrowMs = 250, slotShrinkMs = 150, slotRemoveMs = 250;
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
function slotDuration(entering, removed) { return entering ? slotGrowMs : removed ? slotRemoveMs : slotShrinkMs; }

// the recent list after app `id` stopped running: it goes first, kept unique, at most `max`
function pushRecent(recent, item, max) {
    return [item].concat(recent.filter(a => a.id !== item.id)).slice(0, max || 3);
}

// ---------- label ----------
// App name label (27.2.1 DOCKLabelLayer / ECCartoucheGlassLayerController; MAC-ANSWERS.md "REA 27.2.1: Dock"
// section 3 and Q-dock-08): a glass capsule 26 pt tall (radius 13), the text's width rounded up + 2 x 13 wide, at
// least 15 + 2 x 13 = 41 wide (text at most 600, middle-truncated), its bottom 9 pt above the Dock background (the
// tail's tip 2.5). The pad is 13, not the 14 that Q-dock-08 took from one label ("Finder" 67.5): -[ECCartoucheGlass
// LayerController setContentLayer:] pad = max(radius 13, 13), layer width = text + 2 pad, and the text width is
// ceil(CTLineGetTypographicBounds) (reference/re/27.2.1/GAPS-REA-dock.md section 2). Ours measured 70..71 for "Finder".
function labelWidth(textWidth) {
    return Math.max(41, Math.ceil(Math.min(600, textWidth)) + 26);
}

// ---------- Cmd-Tab ----------
// The switcher's apps: every Dock item with a window, plus Finder always (its Dock dot never goes, the desktop is
// Finder's: cmdtab-light.png lists it with no Finder window), most recently used first (Q-dock-22: "Order is MRU
// (active app first, the previous one selected)"): `history` is the app ids by last activation (activationOrder), an
// app not in it goes after them in Dock order. The frontmost stays first (Finder while the desktop has the keyboard)
// even before its activation reached the history. `isActive(item)` tells whether the item owns the focused window.
function switcherApps(items, desktopFocused, isActive, history) {
    const h = history || [];
    const rank = i => { const r = h.indexOf(i.id); return r === -1 ? h.length : r; };
    const running = items.filter(i => (i.windows || []).length > 0 || i.id === "hyprk-finder")
        .map((i, n) => ({ i, n })).sort((a, b) => rank(a.i) - rank(b.i) || a.n - b.n).map(x => x.i);
    const front = desktopFocused ? running.findIndex(i => i.id === "hyprk-finder") : running.findIndex(isActive);
    if (front > 0) running.unshift(running.splice(front, 1)[0]);
    return running;
}

// The activation history after the running apps are `runningIds` (in Dock order) and `frontId` is frontmost ("" for
// none): apps that quit leave it, an app that started running goes last (launch order for apps never activated), the
// frontmost goes first. Returns `history` itself when nothing changed.
function activationOrder(history, runningIds, frontId) {
    const h = history.filter(id => runningIds.indexOf(id) !== -1);
    for (const id of runningIds) if (h.indexOf(id) === -1) h.push(id);
    const f = h.indexOf(frontId);
    if (f > 0) h.unshift(h.splice(f, 1)[0]);
    return h.length === history.length && h.every((id, n) => id === history[n]) ? history : h;
}

// ---------- Dock menu tail ----------
// The Dock's right-click menu is AppKit's popover-framed menu (DockHelper _popUpMenuRelativeToRect:, AppKit
// _NSPopupMenuWindowPopoverFrame), its mask CoreUI's menu path (reference/re/27.2.1/GAPS-REA-dock.md 1,
// decomp/Dock-gaps.c): __CUICreateMenuPath 0x18f272ce4 arrow width 23.5 (double at 0x18f3287a8), height 13 (fmov #13 at
// 0x18f272dd8); __pathForRoundedRectWithAnchor 0x18f2fcfbc: base corners at +-(W/2 - 0.08 h) on the edge (0x18f2fd3f0),
// tip arc radius 0.42 h (0x18f2fd3d4), base fillets 0.60 h (0x18f2fd3c4), the tip at the anchor clamped W/2 in from
// each end, centred on an edge shorter than W (__CUICreateNewPopoverPathWithArrowPosition 0x18f272e24).
// The plugin draws the same outline (plugin/src/Shape.cpp sdBoxTail); this is the QML glass's copy.
const menuTail = { width: 23.5, height: 13, tip: 0.42, fillet: 0.60, baseIn: 0.08 };
// the tip's x from the body's left edge
function menuTailTip(at, w) {
    const h = menuTail.width / 2;
    return w < menuTail.width ? w / 2 : Math.max(h, Math.min(w - h, at));
}
// the tail's frame: v along the edge from the tip, u out of the body. Side from the base corner (c, 0) to (0, H), its
// outward normal (nx, ny); the tip circle centre (0, ctY); the fillet circle centre (vF, rf), its foot on the edge (vF, 0)
function menuTailGeometry() {
    const H = menuTail.height, c = menuTail.width / 2 - menuTail.baseIn * H;
    const rt = menuTail.tip * H, rf = menuTail.fillet * H, L = Math.hypot(H, c);
    const nx = H / L, ny = c / L, cS = c * nx;
    return { H, c, rt, rf, nx, ny, ctY: H - rt * L / c, vF: (rf + cS - rf * ny) / nx };
}
// SVG path of the tail under an edge at y = bottom, tip at x = tx, offset `off` into the shape (< 0: outside).
// closed: the fill, reaching 2 pt up into the body to cover its bottom rim; open: the curve alone (rim, hairline)
function menuTailPath(tx, bottom, off, closed) {
    const g = menuTailGeometry(), rt = g.rt - off, rf = g.rf + off;
    const pfx = g.vF - rf * g.nx, pfy = g.rf - rf * g.ny, ptx = rt * g.nx, pty = g.ctY + rt * g.ny;
    const n = v => Math.round(v * 1000) / 1000;
    const P = (x, y) => n(x) + " " + n(y);
    let s = closed ? "M " + P(tx - g.vF, bottom - 2) + " L " + P(tx - g.vF, bottom - off) : "M " + P(tx - g.vF, bottom - off);
    s += " A " + n(rf) + " " + n(rf) + " 0 0 1 " + P(tx - pfx, bottom + pfy);
    s += " L " + P(tx - ptx, bottom + pty);
    s += " A " + n(rt) + " " + n(rt) + " 0 0 0 " + P(tx + ptx, bottom + pty);
    s += " L " + P(tx + pfx, bottom + pfy);
    s += " A " + n(rf) + " " + n(rf) + " 0 0 1 " + P(tx + g.vF, bottom - off);
    if (closed) s += " L " + P(tx + g.vF, bottom - 2) + " Z";
    return s;
}
