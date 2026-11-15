.pragma library

// Lines on the device pixel grid (reference/re/27.2.1/SCALING-AUDIT.md). A Rectangle or ShaderEffect without
// antialiasing fills the device pixels whose centres fall inside it, so a line t pt thick covers floor or ceil of
// t x dpr pixels depending on where it lands: at scale 1.6 a 1 pt separator (1.6 px) is 2 px in one row and 1 px in the
// next (the Edit menu's two separators, Settings' card rows), a 0.5 pt hairline (0.8 px) is 1 px or nothing. A whole
// number of device pixels covers that many pixels wherever it lands: the nearest one, at least 1 (1 pt at 1.6 -> 2 px,
// 0.5 pt -> 1 px; at 2x nothing changes, at 1x a 0.5 pt hairline is 1 px). For a line that cannot be antialiased.
function line(pt, dpr) {
    const r = dpr > 0 ? dpr : 1;
    return Math.max(1, Math.round(pt * r)) / r;
}

// The Mac's lines in a scaled mode: it renders at 2x and the panel scaler resamples the frame (More Space on the 15"
// Air: 3840 x 2486 backing onto 2880 x 1864, 1.5 px per pt; Default 1710 x 1107: 1.684). A 1 pt separator (2 backing
// px) reaches the panel as one full row and one half row, [1, .5] or [.5, 1] by position, 1.5 rows of ink (R3.3
// more-space-menu.png and -settings.png resampled with box, triangle, Lanczos and Catmull-Rom filters: every one
// within .1 of that). Whole pixels (line()) draw [1, 1] there, a third more ink. An antialiased Rectangle at the exact
// thickness draws what the downsample does (scale 1.5, measured in a Quickshell window: [1.00, .50] / [.50, 1.00],
// 0.5 pt [.83] / [.50, .16] against [.75] / [.25, .50] by box arithmetic). So at a fractional ratio: the exact
// thickness with `antialiasing: Pixel.soft(r)`; at a whole ratio (1, 2) the same as line(), no antialiasing (unchanged).
function stroke(pt, dpr) {
    return soft(dpr) ? pt : line(pt, dpr);
}
function soft(dpr) {
    return dpr > 0 && Math.abs(dpr - Math.round(dpr)) > 0.001;
}

// A window's size at a fractional ratio: the Mac keeps it in points. System Settings is 740 x 625 pt in More Space
// (R3.3 more-space-settings.png, 1480 x 1250 backing px) although that is 937.5 panel px, and the panel shows the whole
// 2x frame resampled: in the panel-size ScreenCaptureKit frame (MAC-ANSWERS-16.md R16.2 / R16.3,
// more-space-settings-sck.png, the window at 100,80 pt, card 46 on 36) the 1 pt separators read, in shares of their
// full contrast, [.1, .8, .6] (y 150 pt) and [.3, .9, .3] (y 501 pt), 1.5 rows of ink, and a card edge on a whole
// panel pixel [.14, .86]: a filter about two panel px wide, softer than the box ([1, .5] / [.5, 1]) the R3.3 notes
// simulated. Ours at 625 pt (Qt draws 938 rows, the compositor scales them onto 937.5): [.85, .62] and [.08, 1, .38],
// 1.46 rows of ink; forced to 626 pt, as whole() did from judge #23 to round 16, [1, .46] / [.46, 1]. Neither is
// the Mac's pattern row for row, the 625 pt one is the nearer (largest difference .22 against .30) and it is the
// Mac's size. So whole() returns the size unchanged; its callers (settings/shell.qml, finder/qml/Main.qml) ask for no
// resize. Hyprland puts a window whose origin is off the device grid (x or y odd at 1.5, not a multiple of 4 pt at
// 1.25) on the nearest device pixel: the same rows at 590,282 / 590,283 / 591,283 (scale-lines.py), so no rule is
// needed for the origin.
function whole(pt, dpr) {
    return pt;
}

// The ratio to use: the window's own when the app knows it (Quickshell: QsWindow.window.devicePixelRatio, Finder:
// windowInfo.dpr, both through Tokens.dpr), else the screen's. On a fractional output Qt's Screen.devicePixelRatio is
// the NEXT WHOLE number (2 at Hyprland scale 1.6, measured: a FloatingWindow reports 1.6, Screen and ShellScreen 2), so
// textures sized and lines snapped with it are 2x textures drawn at 0.8 and lines on a half-point grid.
function ratio(windowDpr, screenDpr) {
    return windowDpr > 0 ? windowDpr : screenDpr > 0 ? screenDpr : 1;
}
