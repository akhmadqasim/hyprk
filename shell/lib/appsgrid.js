// The Apps panel (Dock "Apps", Spotlight Cmd+1): its geometry and the pure parts of its content.
// macOS 27.2.1 (MAC-ANSWERS.md Q-dock-23..26, live/dock/apps-window.json; pt, panel-local):
//   panel 844 x 520 under the 520 x 87 search capsule (gap 10), 7 columns, pitch 115, first column centre 77,
//   icon 60, row pitch 102, label SF 13 regular cap top 11.5 below the icon;
//   chips at y 20, 26 tall, inset 20, gap 8; a row of 7 suggested apps with icon tops at 70, a 1 pt separator at
//   y 168 (x 20..824), then all apps A-Z from icon top 187. A category (or a search, not measured) drops the
//   chips and the suggestions: the grid starts at icon top 20.
// Pure JS (no Qt), unit tested by tests/run.mjs.
.pragma library

const M = {
    width: 844, height: 520, columns: 7, pitch: 115, firstCentre: 77, icon: 60, rowPitch: 102,
    labelCapTop: 11.5, labelSize: 13, labelWidth: 111,
    chipsTop: 20, chipHeight: 26, chipGap: 8, inset: 20,
    suggestTop: 70, separatorY: 168, gridTop: 187, plainTop: 20,
    ring: 69, ringWidth: 3.5, plate: 68,
};
function metrics() { return M; }

// x of a column's left edge (cells are pitch wide, centred on the column centre)
function cellX(col) { return M.firstCentre - M.pitch / 2 + col * M.pitch; }

// icon top of the first grid row: 187 with chips and suggestions, 20 for a category or a search
function gridTop(browsing) { return browsing ? M.gridTop : M.plainTop; }

// rows needed to fill the visible panel from gridTop, plus one partly visible row
function visibleRows(browsing) { return Math.ceil((M.height - gridTop(browsing)) / M.rowPitch); }

// icons the first screen of the "All" view shows: the suggestions row and the visible A-Z rows
function firstScreen() { return M.columns + M.columns * visibleRows(true); }

// keyboard move in a grid of n items: dx columns, dy rows, clamped to the items; -1 (nothing) starts at 0
function move(index, dx, dy, n) {
    if (n <= 0) return -1;
    if (index < 0) return 0;
    return Math.max(0, Math.min(n - 1, index + dx + dy * M.columns));
}

// suggested apps: the first `n` distinct entries of the given lists (recent first, then Dock apps), each item
// either an entry or an object with `entry`
function suggestions(lists, n) {
    const out = [], seen = {};
    for (const list of lists)
        for (const it of list || []) {
            const e = it && it.entry ? it.entry : it;
            if (!e || !e.id || seen[e.id] || e.noDisplay) continue;
            seen[e.id] = true;
            out.push(e);
            if (out.length >= n) return out;
        }
    return out;
}
