# Scale 1.6 against scale 2 (2026-11-14)

Headless hyprk session (`scripts/smoke.sh`, 2560 x 1664 output `MBA`, scratch HOME, state `$XDG_RUNTIME_DIR/hk-b`), dark,
switched with `hyprctl eval 'hl.monitor({ output = "MBA", mode = "2560x1664@60", position = "auto", scale = "1.6" })'`
(and back to "2"). Config autoreload was turned off in the session (`misc.disable_autoreload`): another agent's edit of
`config/hypr/hyprland.lua` reloaded the config and put the output back to 2 mid-run, so every shot went through a script
that refuses to capture when the scale is not the wanted one. Full-output `grim` only: `grim -g` at 1.6 returns a 2x
image resampled from the 1.6 frame (a 740 x 625 pt window came back 1480 x 1250), useless for pixel work.

The Mac: no capture of a scaled mode exists under `reference/` (`settings/displays-*.png` is the Displays pane at the
default 2x). What the Mac does is known (SPEC.md 14, `config/hypr/scale-policy.lua`): a "More Space" mode renders at 2x
and the display scaler downsamples, so every line keeps its ink (1 pt = 1.6 px of coverage, spread over 1-2 rows) and
every texture is a 2x raster seen at 0.8.

## 1. The ratio Qt reports (the cause of most of what follows)

A Quickshell `FloatingWindow` on the 1.6 output (scratch `qstest/shell.qml`): `win.devicePixelRatio` and
`QsWindow.window.devicePixelRatio` **1.6**, `Screen.devicePixelRatio` **2**, the window's `ShellScreen.devicePixelRatio`
**2**. A plain `qml` Window: `Screen.devicePixelRatio` 2. Qt gives the screen the next whole number (the wl_output scale)
and the window the fractional one. Settings (`Theme.dpr`) and Finder (`windowInfo.dpr`) already knew this for their
icons; the lines, the Dock and the shader edges did not.

## 2. Defects found and fixed

| # | defect (only at 1.6) | pixel evidence | cause | fix |
|---|---|---|---|---|
| 1 | Menu separators 2 px in one place and 1 px in the next, in the same menu | Edit menu, column x 330 px: separator 1 rows 148-149 (83 over 54), separator 2 **row 320 only** (100 over 74). After: 148-149 and **320-321**. At 2x after: 2 rows each (186-187, 400-401) | a 1 pt Rectangle is 1.6 px; without antialiasing it fills the pixel centres inside it, 1 or 2 depending on where the row lands | `HyprK Pixel.line(1, ratio)` = whole device pixels (2 px at 1.6), `shell/modules/MenuDropdown.qml` 470 |
| 2 | Settings card row separators 2 px and 1 px in the same pane | Appearance pane, column x 1000 px: rows **362-363** (48 over 38) and **924 only**. After: 362-363 and **924-925**. 2x after: 2 rows each (452-453, 1154-1155) | same | `settings/controls/FormRow.qml` 34; the scroll-edge hairline `settings/SettingsApp.qml` 333 (0.5 pt = 0.8 px: 1 px or none by position, now 1 px) |
| 3 | The same 1 / 2 px alternation for every 1 pt line, and 0.5 pt hairlines that vanish where 0.8 px covers no pixel centre (y frac in (0.5, 0.7]) | Finder list view after the fix, row 418: column separators **1373-1374, 1663-1664, 1818-1819** (2 px each, 77 over 41), header bottom line **440-441**. The vanishing case is the rule above (`shell/tests` "pixel line" test: 1 pt at 1.6 over 160 positions covers 1 or 2 px before, always 2 after; 0.5 pt always 1) | same | Finder: `Sidebar.qml` edge, `Main.qml` gallery line, `FileList.qml` header lines, `ColumnView.qml` divider, `Toolbar.qml` divider, `PopupMenu.qml` separator, `InfoRows.qml`, `PreviewBar.qml`, `GalleryView.qml`; shell: `CcSoundPanel`, `StatusModulePanel`, `DockStack`, `NotifCard` plate line, `EmojiPicker` bar hairline, Spotlight `ModeView` / `AppsPanel` separators (ShaderEffect, same rasterisation); ui: `SegmentedControl` dividers |
| 4 | Dock tiles on a half-point grid, not on device pixels | `lib/dock.js layout` with the ratio the Dock used (2) at 1.6, 7 tiles and a separator at tile 48: cell x in px **12.8, 96, 179.2, 262.4, 345.6, 428.8, 466.4, 549.6**, widths 83.2: 7 of 8 off the grid, so the icon textures were resampled at a 0.2-0.8 px phase. With the window's ratio: **13, 96, 179, 263, 346, 429, 466, 550**, widths 83 | `Dock.qml` / `DockStack.qml` took `screen.devicePixelRatio` (2) | the window's `devicePixelRatio`, `Dock.qml` 91, `DockStack.qml` 53 |
| 5 | Spotlight's close blur 25 % too strong | arithmetic: `blurRadius x ratio / 64` with ratio 2 where the window draws 1.6 px per pt (not filmed) | `sp.screen.devicePixelRatio` | `sp.devicePixelRatio`, `Spotlight.qml` 391, 427 |
| 6 | Shader edges (plus-lighter tracks and chips, traffic lights) antialiased over 0.8 px instead of 1 px | arithmetic: the shaders take px per pt to size their edge ramp (not measured on screen) | `Screen.devicePixelRatio` | the window's ratio: `ControlCenterSlider.qml` 21, `spotlight/AppsPanel.qml` 160 / 194, `spotlight/ModeView.qml` 103 (QsWindow), `ui/HyprK/TrafficLights.qml` 118 (`Tokens.dpr`) |

`ui/HyprK/pixel.js` (qmldir `Pixel`): `line(pt, ratio)` = `max(1, round(pt x ratio)) / ratio` and `ratio(window,
screen)`. A whole number of device pixels covers that many pixels wherever it lands, so no position snapping is needed.
At 1.6 a 1 pt line is 2 px of ink where the Mac's downsample gives 1.6 (the nearest whole number; the old 1 px rows
were 0.6 px light and the 2 px rows the same as now). At 2x nothing changes; at 1x a 0.5 pt hairline becomes 1 px.
`Tokens.dpr` (new): the app window's ratio, bound by `settings/shell.qml` and `finder/qml/Main.qml`; the shell uses
`QsWindow.window.devicePixelRatio` per item (its windows can sit on different outputs).

## 3. Looked at, not changed

- **Glyph textures** (`shell/components/Symbol.qml`, `finder/qml/Symbol.qml`): rasterised at `ceil(size x 2)` and drawn
  at 0.8. Rasterised at the window's 1.6 instead, the menu bar's right side (battery, Wi-Fi, search, Control Center,
  220 x 54 px) read slightly softer: gradient energy 118291 -> 115026 (-3 %), pixels at full ink 13 -> 4, because the
  1:1 texture still lands at a fractional position and is resampled anyway. The 2x raster seen at 0.8 is also the Mac's
  own path for a scaled mode, so it stays (comment at Symbol.qml 42). Same reasoning kept `BatteryIcon`, `ScrollEdge`,
  `LensGlass` (max(2, ratio)) and the `sourceSize: width * 2` images (Spotlight rows, notification sender photos, lock
  screen, Finder gallery, tag dots, segmented icons, alert icon) at their 2x decodes.
- **Text**: menu bar, menus, Settings sidebar and Finder sidebar compared at 3x zoom against the 2x shots: no
  missing strokes, no doubled baselines; Qt places glyph runs at fractional pixels at 1.6 as the Mac's downsample
  smears them. Not measured against a Mac (no capture).
- **Dock icon art** at 1.6 (Finder, Launchpad, TextEdit, System Settings): the art matches the 2x shot scaled 0.8 by
  eye; the Finder tile was already on the grid (its left edge column identical before and after the Dock fix).
- **Control Center, NC widgets, Settings Appearance, Finder icon and list views** at 1.6: no clipped shadows, no
  missing rims, glass edges antialiased.
- **0.5 pt borders on rounded rectangles** (`Capsule`, `TagPopover`, `ToolbarPlatter`, `SearchField`, `Popup`,
  `AlertPanel`, `RenameField`, `FileIcon`, Finder `TabBar` (square: may vanish on a side at 1.6, not checked)):
  rounded borders are antialiased by Qt, not checked pixel by pixel.

## 4. Open

- A Mac capture of a scaled mode ("More Space" on a 2560 x 1664 panel: the Dock, a menu, NC, a Settings pane) to put
  numbers on the Mac side: line ink per row, glyph sharpness, Dock icon edges.
- Finder `TabBar` square 0.5 pt border, lock screen and Mission Control at 1.6: not looked at.
- Multi-output with mixed ratios: `Tokens.dpr` is one value per app (Finder and Settings are one window each); the
  shell's per-item `QsWindow` ratio handles it there.

## Round R3.3 (More Space), 2026-11-14 (in progress: handed back early, see "Left")

Mac: `screens/27.2.1/scaled/more-space-{dock,menu,settings}.png`, `more-space-spotlight-close.mov` (MAC-ANSWERS-3 R3.3).
More Space = 1920 x 1243 pt, 3840 x 2486 backing, panel 2880 x 1864 = **1.5 panel px per pt**. `screencapture` returns
the BACKING (2 px per pt), so no capture shows the panel scaler: the panel look was simulated by resampling the stills
to 75 % with box, triangle, Lanczos and Catmull-Rom (ImageMagick, sRGB values). Ours: headless session, output
`2880x1866@60` scale 1.5 (1920 x 1244 pt; 1243 is not a whole-pixel size at 1.5), dark, TahoeDark, shell restarted at
1.5 (see runtime switch below), `HYPRK_SCALE_POLICY=off`.

Corrections to section 0 / 4 above: round 1 (MAC-ANSWERS.md, 1710 x 1107 "Default") IS a scaled mode (2880/1710 =
1.684 panel px per pt), so "no capture of a scaled mode exists" and "Displays pane at the default 2x" were wrong; but
no capture from any round shows the downsample (backing pixels). "More Space on a 2560 x 1664 panel" -> 2880 x 1864.

| element | Mac at 1.5 (simulated, all 4 filters within .1) | ours at 1.5 before | now |
|---|---|---|---|
| 1 pt separator (File menu rows 265 / 527 / 586 pt, Settings cards) | [1, .5] or [.5, 1] by position, 1.4-1.56 rows of ink | [1, 1] (pixel.js whole px): +33 % ink | AA Rectangle at the exact thickness: [1.00, .50] / [.50, 1.00] measured in a Quickshell window at 1.5 |
| 0.5 pt hairline | [.75] or [.25, .50] (box arithmetic) | [1] | AA: [.83] / [.50, .16] |
| Dock separator (1 pt, plus-lighter) | 85 / 52 on 20 = [1, .49] | **[1] only**: 86 then 21 (the ShaderEffect item ended mid-pixel and cut the AA ramp) | [86, 53] (`pad`) |
| Dock platter rim top / bottom | 59, 71, 38 / 71, 57 | 74, 77, 38 / 76, 72 (about +20 % ink) | not changed (glass owner) |
| menu text (13 pt, "New Finder Window") | ink 424 /pt2, solid .47-.62, edge .55-.62 /pt | ink 423, solid .66, edge .65 | same weight, ours 5-15 % crisper: no change |
| menu bar title (13 bold) | solid .70-.76, edge .54 | .77, .55 | no change |
| icon sharpness (Finder art, Laplacian std, 2x raster -> 0.75 vs our direct resample) | 0.81-1.09 of ours (filter dependent) | | no change |
| menu row pitch | 24 pt = 36 px | 36 px | same |
| Spotlight pill (open) | x 141..658 pt in the clip region, top 288 pt | x 141.3..657.3, top 282 | position: Spotlight owner |

Spotlight close at 1.5 (mcap, region 560,100 800x400, k 1): ours alpha .91 .74 .54 .36 .21 .10 .02 over 6 frames,
width scale 1 -> .973, centre x constant (401.0 +-.3 pt): no snapping or jitter, same open size as the Mac. The Mac clip
(VFR) has ONE closing frame (550 ms: scale .952, alpha .30; full at 483, gone at 567): not enough for timing; the
2x comparison of ours was not run yet.

Changed (whole ratios 1 and 2 unchanged by construction: `stroke()` = `line()` and `soft()` false there, no edited
Rectangle has a radius; Dock: `pad` 0):
- `ui/HyprK/pixel.js`: `stroke(pt, dpr)` (exact at a fractional ratio, else `line()`) and `soft(dpr)`; `line()` kept.
- Call sites -> `Pixel.stroke` + `antialiasing: Pixel.soft(r)`: finder `PreviewBar, Sidebar, FileList (2), ColumnView,
  Main, Toolbar, PopupMenu, InfoRows, GalleryView`; settings `SettingsApp, controls/FormRow`; shell `CcSoundPanel,
  EmojiPicker, components/NotifCard`; ui `SegmentedControl`.
- `shell/shaders/plusfill.frag(.qsb)`: optional `pad` uniform (unset = 0: running dot and CC slider pixel-identical
  before/after at 1.5); `shell/modules/Dock.qml` separator uses it.

Found:
- Runtime scale change: a Quickshell window started at 1.5 still reported devicePixelRatio 1.5 three seconds after
  `hl.monitor` set scale 2 (hyprctl confirmed 2): long-lived layers keep the old ratio until the shell restarts. At
  startup the ratio goes 2 -> 1 -> 1.5 with notifications (bindings end right).
- Round-1 numbers that assumed 34 pt bar etc. (sweep of reference/): menu bar height is about 58 panel px on this Air
  (notch): 29 pt at 1440 x 932 (spotlight-light-white-*.png bar ends at px 58; TextEdit at 0,29), 34 at 1710, ~39 at
  More Space. `Theme.qml` 354 ("34 is exact" on MBA@2x), `hyprland.lua` `fullscreen_top = "MBA:34"`, plugin-motion
  FrameMotion.cpp 88, MissionControl.qml 63-92 (bar 74 -> 68, pill centre 53.5 -> 47.5, plus 37 -> 33.75 at 2x),
  Spotlight `barTop 0.227` (Theme.qml 795): the Mac keeps the bar CENTRE at .2665 x H (251+43.5)/1107, (205+43.5)/932,
  (288+43.5)/1243, so top = .2665 H - 43.5 (832 -> 178, ours 189). `scale-policy.lua` 10-11 "macOS never defaults to a
  fractional scale": not true for this Air's built-in (Default 1.684). `ui/HyprK/panels.js` 52 "1113 pt" -> 1107.

Left (next steps):
1. Re-measure Settings card rows with the AA stroke (the second Settings window opened at 590,282, the crop was off).
2. (Done: MenuDropdown, StatusModulePanel; DockStack's scroll lines 2026-11-15 after judge #22, `Pixel.stroke(1, win.dpr)`
   + `antialiasing: Pixel.soft(win.dpr)`, not shot at 1.5.) Other owners, exact change: `MenuDropdown.qml` 470, `StatusModulePanel.qml` 103, `DockStack.qml` 347:
   `height: Pixel.stroke(1, R)` + `antialiasing: Pixel.soft(R)` (R = the same ratio expression). Spotlight
   `ModeView.qml` 99 and `AppsPanel.qml` 190 (ShaderEffect, plusfill): `property real pad: Pixel.soft(R) ? 1 / R : 0`,
   x / y minus pad, width / height plus 2 pad, `sizePt` = the line's own size.
3. Re-verify at scale 2 and 1 with screenshots (only argued by construction so far), Spotlight close at 2x vs 1.5.
4. Tests for `stroke` / `soft` in shell/tests/run.mjs (pixel block). Fix the comments in scale-policy.lua and panels.js.
5. Runtime scale change: restart the shell (or re-create layers) after `scale-policy.lua set()`.

## After judge #23: re-shot at 1.5 and 1.25, shell born at the scale (2026-11-15)

Sessions: `scripts/smoke.sh` headless with a scratch `HYPRK_CONFIG` (the repo's `hyprland.lua` plus a monitor rule for
`MBA`), `HYPRK_SCALE_POLICY=off`: 2880 x 1866 at 1.5 (1920 x 1244 pt), 2560 x 1600 at 1.25 (2048 x 1280 pt), 2560 x 1664
at 2. The shell, Settings and Finder all started at the scale under test. Flat grey 127. Check:
`scripts/motion-capture/scale-lines.py` (full-output grim, device pixels): every 1 pt line, row by row, against what a
1 pt line on the Mac's 2x raster reads after a box resample (phases of a half point: [1, .5] [.5, 1] [.25, 1, .25] at
1.5; [1, .25] [1, .67] [.67, 1] [.25, 1] [1, .43] [.43, 1] [.12, 1, .12] at 1.25; [1, 1] at 2), +- .2.

| surface | 1.5 | 1.25 | 2 |
|---|---|---|---|
| Dock separator (the `pad` fix of R3.3) | [1, .5] (ink 1.51-1.53) | [1, .75] | [1, 1] |
| menu bar menu separators (File menu, 6-7 lines) | ink 1.48 each | 6 of 6 on a phase pattern | [1, 1] |
| Settings card separators (Appearance) | before **[.92, .67] and [.08, 1, .42]**, now [1, .46] / [.46, 1] | [.67, 1] / [1, .67] | [1, 1] |
| Finder list header line | 1.50 | 1.27 (after the size fix) | [1, 1] |

Found and fixed, **a window whose size is not a whole number of device pixels**: Settings is 740 x 625 pt = 937.5 px
tall at 1.5 (781.25 at 1.25), Finder 936 x 594 = 742.5 px at 1.25. Qt renders the next whole row count and the
compositor scales it onto the window, so the whole window is resampled with a shift that grows towards the bottom
(0.12 px at 150 pt, 0.4 px at 501 pt: the two separators above; text likewise). The Mac has no such shift (one 2x
raster resampled as a whole). `ui/HyprK/pixel.js whole(pt, dpr)` gives the nearest whole-point size on whole device
pixels (625 -> 626 at 1.5, 624 at 1.25; 594 -> 596 at 1.25); `settings/shell.qml` and `finder/qml/Main.qml` ask
Hyprland for it 0.3 s after the last size change (`Hypr.resizeWindow`, new in `finder/src/hypr.cpp`; Hyprland does not
take a size the client sets itself). Whole scales: nothing changes (625, 594 kept; checked at 2). Cost: the Settings
window is 1 pt taller than the Mac's at 1.5.

Looked at by eye at 2x zoom (menu bar, File menu, status items, Dock, Finder sidebar and list at 1.5 and 1.25): no
doubled baseline, no missing stroke, no clipped glyph; text is softer at 1.25 as the Mac's own downsample is.

Open:
- Any other window at an odd size on a fractional scale is still resampled (a size dragged by hand in a GTK or Qt app,
  the shell's own layers sized in points). A compositor-side rule (floating sizes snapped to device pixels) would cover
  all of them; not built.
- The check cannot tell an even split ([.75, .75] at 1.5, a line on a half point at one of its phases) from whole
  pixels, and has no amplitude for 0.5 pt hairlines (under one row); those are listed, not judged.
- Control Center, Spotlight, NC, lock screen and Mission Control were not shot at 1.5 / 1.25 this round (no 1 pt
  separators in Control Center; its glass rims are the plugin's).
- Runtime scale change still needs a shell restart (R3.3 "Found").
- Mac side: every capture so far is the backing (2 px per pt); the panel scaler's own filter is simulated (request below
  in OPEN-FIXES "After judge #23").

## Round 16: the panel's own frames (R16.2, R16.3), 2026-11-15

Mac: `screens/27.2.1/scaled/{more-space,larger-text}-{dock,menu,finder,settings}-sck.png` and the AX dumps
(MAC-ANSWERS-16.md). More Space's ScreenCaptureKit frame is the scaled frame at panel size (1.5 px per pt); Larger Text
(1024 x 663) comes back as its unscaled 2x frame, so it adds no second ratio. Measured here on the More Space frames:

| what | Mac, panel px (shares of the full contrast) | the box simulation of R3.3 | ours at 1.5 |
|---|---|---|---|
| Settings card separator, y 150 pt (46 on 36) | 37, 44, 42 = [.1, .8, .6], ink 1.5 rows | [1, .5] | 625 pt window [.85, .62]; 626 pt [1, .46]; ink 1.46 |
| the same, y 501 pt | 39, 45, 39 = [.3, .9, .3], ink 1.5 | [.5, 1] | 625 pt [.08, 1, .38]; 626 pt [.46, 1] |
| card edge on a whole panel pixel (x 378, y 96) | [.14, .86, 1] | [0, 1] | [0, 1] |
| File menu separators (rows 398, 630, 791, 879) | [.45, .92, .21] and [.07, .81, .65] of ink / 1.5, 3-4 % undershoot beside | [1, .5] | [1, .5] / [.51, 1] |
| Settings window (AX) | 100,80, 740 x 586 pt in this take (it had been shrunk to fit Larger Text's 663 pt screen); 740 x 625 in R3.3's backing still | | 740 x 625 |

- The scaler is about two panel px wide (a triangle of half-width 1 px gives [.125, .875, .5] and the edge's
  [.125, .875]), with a small negative lobe in the menu frame; not a box. Ink is kept: a 1 pt line is 1.5 rows.
- **Hairline weights: no change.** Ours keeps the ink (1.46-1.5 rows at 1.5, 1.23 at 1.25) and its strongest row is
  10-20 % stronger than the Mac's, as its text is (R3.3). Matching the row shape would mean filtering the whole output.
- **Window size: corrected.** `pixel.js whole()` returns the size unchanged: Settings is 625 pt again at 1.5 and 1.25
  (was 626 / 624), Finder 594 (was 596 at 1.25). The compositor-resampled 625 pt window is nearer the Mac's rows
  (largest difference .22) than the 626 pt one (.30). `shell/tests/run.mjs` "pixel whole".
- **Window origin at 1.25 (and 1.5): no rule needed.** Settings at 600,280 / 601,281 / 603,283 (1.25) and 590,282 /
  590,283 / 591,283 (1.5) draws the same rows: Hyprland puts the surface on the nearest device pixel.
- `scale-lines.py`: patterns of a 1 pt line through the box or the two-pixel triangle at any phase; `Settings size`
  = 740 x 625 pt replaces "window on whole device pixels". Runs: 1.5 (2880 x 1866) 5 lines ok, 1.25 (2560 x 1600) 5
  lines ok.

Open: Finder's header line and list were not found by the check in these runs (window behind Settings); the Dock
and menu frames have no same-day backing shot, so their phase against the backing is not known; 0.5 pt hairlines have
no Mac panel measurement; no Mac ratio other than 1.5.
