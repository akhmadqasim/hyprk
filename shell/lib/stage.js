.pragma library

// Stage Manager, decoded from macOS 27.2.1 (26B131): WindowManager.framework (dyld cache) holds the defaults
// (WindowManagerPreferencesController init 0x1d2a7a2c0, one key / default pair per entry), WindowManager.app
// (WindowManagerAgent, arm64e slice) the layout. reference/re/27.2.1/STAGE-MANAGER-27.2.1.md has every address.
// Marks in the comments: decoded (address), inferred (reading of decoded code or a key's name), ours (no decode).

// com.apple.WindowManager defaults, decoded (key: default, init entry address)
const P = {
    preferredMinimumItemHeight: 96,        // 0x1d2a7aa78
    absoluteMinimumItemHeight: 20,         // 0x1d2a7aaa0
    maximumItemHeight: 160,                // 0x1d2a7aac8
    minimumRowCount: 4,                    // LeftStripMinimumRowCount 0x1d2a7aaf0
    maximumRowCount: 6,                    // LeftStripMaximumRowCount 0x1d2a7ab18
    pileVerticalSpacing: 30,               // LeftStripPileVerticalSpacing 0x1d2a7aa28
    edgeInset: 16,                         // LeftStripEdgeHorizontalInset 0x1d2a7a9dc
    insetFromStrip: 16,                    // HorizontalInsetFromStrip 0x1d2a7b02c
    stageMinimumInset: 4,                  // StageFrameMinimumHorizontalInset 0x1d2a7b084
    stageVerticalInset: 0,                 // VerticalInset 0x1d2a7b060
    pileMaximumWindowCount: 3,             // LeftStripPileMaximumWindowCount 0x1d2a7aa50
    appIconSize: 40,                       // AppIconSize 0x1d2a7b140
    appIconLeftOffset: -10,                // LeftStripAppIconLeftOffset 0x1d2a7a8e4
    appIconBottomOffset: 10,               // LeftStripAppIconBottomOffset 0x1d2a7a8bc
    cornerRadius: 8,                       // StripCornerRadius 0x1d2a7a848
    hoverScaleDistance: 16,                // StripHoverScaleDistance 0x1d2a7a870
    clickDownScaleDistance: 16,            // StripClickDownScaleDistance 0x1d2a7a898
    stackDepthStep: 0.1,                   // LeftStripStackDepthStepValue 0x1d2a7a790
    autoHideDelay: 0.15,                   // AutoHideDelay 0x1d2a7b18c = prolongedMouseEdgeEnterDelayInterval (0x1002e0944)
    // AutoHideOverlapThreshold has no table entry: its getter (0x1d2a880bc) falls back to AppIconSize +
    // LeftStripAppIconLeftOffset = 40 - 10
    overlapThreshold: 30,
    clickSessionTimeout: 1.25,             // StripClickSessionTimeout 0x1d2a7b4ec (a second click cycles the pile)
};

// StageManagerRowCountComponent (0x1002c5ec0): rows = round((H - s) / (maxH + s)) clamped to the row counts, the
// item height (H - s) / rows - s clamped to [preferred minimum, maximum], the scale that height over the display's.
// avail: the Stage Manager available frame's height; display: the display's height (both pt)
function rowCount(avail, display) {
    const s = P.pileVerticalSpacing, a = avail - s;
    const rows = Math.min(P.maximumRowCount, Math.max(P.minimumRowCount, Math.round(a / (P.maximumItemHeight + s))));
    const item = Math.min(P.maximumItemHeight, Math.max(P.preferredMinimumItemHeight, a / rows - s));
    return { rows: rows, itemHeight: item, scale: item / display };
}

// StageManagerPileStackedWindowLayoutComponent (0x1002c21f0): a window's thumbnail scale. Its height is its own
// height x the row scale, clamped to [preferred minimum, maximum]; the width may not pass the widest pile, the
// maximum height at the display's aspect
function pileMaxWidth(displayW, displayH) { return P.maximumItemHeight / displayH * displayW; }
function windowScale(w, h, scale, displayW, displayH) {
    if (!(w > 0 && h > 0)) return 0;
    let s = Math.min(P.maximumItemHeight, Math.max(P.preferredMinimumItemHeight, scale * h)) / h;
    const maxW = pileMaxWidth(displayW, displayH);
    if (w * s > maxW) s = maxW / w;
    return s;
}

// StageCalculatorComponent (0x1002938a8 frame, 0x100293a7c safe area): the strip side loses
// floor(strip maximum width x 0.66) + edge inset + inset from strip; with the strip hidden only 4 pt. With windows
// grouped "all at once" (the default) only the strip side is inset, else both sides. content: { x, y, w, h }
function stageFrame(content, stripMaxW, stripHidden, allWindows) {
    const inset = stripHidden ? P.stageMinimumInset : Math.floor(stripMaxW * 0.66) + P.edgeInset + P.insetFromStrip;
    const v = P.stageVerticalInset;
    if (allWindows === false) return { x: content.x + inset, y: content.y + v, w: content.w - 2 * inset, h: content.h - 2 * v };
    return { x: content.x + inset, y: content.y + v, w: content.w - inset, h: content.h - 2 * v };
}

// The strip (StageManagerStripComponent, 0x1002ed640..0x1002ed788): piles one above the other, 30 pt apart, the
// column centred in the available frame, each pile at the left edge inset. avail: { x, y, w, h }; heights: the
// piles' heights top to bottom. Returns their { x, y } (inferred: the centring term (H - total) / 2 and the spacing
// are decoded, the order of the piles in the column is not)
function stripLayout(avail, heights) {
    const n = heights.length;
    const total = heights.reduce((a, h) => a + h, 0) + Math.max(0, n - 1) * P.pileVerticalSpacing;
    let y = avail.y + (avail.h - total) / 2;
    const out = [];
    for (const h of heights) { out.push({ x: avail.x + P.edgeInset, y: y }); y += h + P.pileVerticalSpacing; }
    return out;
}

// the app icon under a pile (inferred from the key names and their signs): 40 pt, 10 pt left of the pile's left
// edge and 10 pt below its bottom edge
function iconRect(pile) {
    return { x: pile.x + P.appIconLeftOffset, y: pile.y + pile.h + P.appIconBottomOffset - P.appIconSize, w: P.appIconSize, h: P.appIconSize };
}

// The strip hides while a stage window covers it (AutoHideWhenOccluded, default on): by more than the overlap
// threshold past the strip's right edge (inferred: the threshold is decoded, the measure is not traced)
function occludes(win, stripRight) { return win.x < stripRight - P.overlapThreshold; }

// Hover / press (0x1002bc7e0): the pile grows by 16 pt of its height while hovered, shrinks by 16 pt while pressed
function interactionScale(height, state) {
    if (!(height > 0)) return 1;
    return state === "hover" ? (height + P.hoverScaleDistance) / height : state === "press" ? (height - P.clickDownScaleDistance) / height : 1;
}

// ---------- the model: which app is on stage, the strip's apps most recent first ----------
// { stage: app key or "", strip: [keys] }. Grouping "all at once" (AppWindowGroupingBehavior 1 = allWindows,
// 0x1d2a7a698): every window of an app goes with it.
function empty() { return { stage: "", strip: [] }; }
function without(list, k) { return list.filter(x => x !== k); }

// an app comes to the stage (a pile click, a new window of it, the Dock, Cmd-Tab): the app on stage goes to the
// top of the strip (ours: most recent first; LeftStripReplacementOrder 0 = leastRecentUsed is what falls off)
function activate(m, app) {
    if (!app || m.stage === app) return m;
    const strip = without(m.strip, app);
    if (m.stage) strip.unshift(m.stage);
    return { stage: app, strip: strip };
}
// a click on the desktop (EnableStageManagerClickToEmptyStage, on, 0x1d2a7b53c): the stage empties into the strip
function emptyStage(m) {
    if (!m.stage) return m;
    return { stage: "", strip: [m.stage].concat(without(m.strip, m.stage)) };
}
// an app's last window closed. Its pile goes; if it was on stage the stage stays empty (ours: the Mac's next step
// is not decoded)
function gone(m, app) {
    return { stage: m.stage === app ? "" : m.stage, strip: without(m.strip, app) };
}
// the piles the strip shows: one per row, the least recently used beyond them drop off (their windows stay parked,
// reachable from the Dock and Cmd-Tab)
function visible(m, rows) { return m.strip.slice(0, Math.max(0, rows)); }
// keep only apps that still have windows, in order; apps found parked but unknown go to the end (a shell reload)
function reconcile(m, apps, parked) {
    const has = new Set(apps);
    const strip = m.strip.filter(k => has.has(k) && k !== m.stage);
    for (const k of parked) if (k !== m.stage && strip.indexOf(k) < 0 && has.has(k)) strip.push(k);
    return { stage: has.has(m.stage) ? m.stage : "", strip: strip };
}
// a stage window that reaches into the strip's side moves out of it (Stage.Style inset, 0x100293b38: style 2 with
// all windows; inferred: the code that places the windows is not traced). Returns the new x or null
function insetX(win, safe) {
    if (win.x >= safe.x) return null;
    return win.w <= safe.w ? safe.x : Math.max(safe.x, safe.x + safe.w - win.w);
}

function prefs() { return P; }
