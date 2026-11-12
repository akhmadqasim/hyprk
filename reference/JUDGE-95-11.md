# hyprk independent judge #11, commit fdc1b2d (2026-11-12, 11:14-11:21 WITA, measured live)

Delta judgement against judge #10 (`JUDGE-95-10.md`, 0bc76d1, 90.59). Method and weights from `JUDGE-95-7.md`: 12
dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[11 live]** measured
on screen here; **[10]** carried from judge #10.

## What was judged

- HEAD fdc1b2d (live tree, no developer writing). Changes since 0bc76d1: c99ce3e, 159a699, e3d9ee8 (Mission Control
  exit: picked window on top from the first frame, active look while it flies, plugin title bar active), fdc1b2d
  (plugin + shell: `draw_over`, the Dock and its dots drawn over the hyprk-mission layer, replacing `wallpaper_under`).
  3b5b727, f6d784d: docs only, no score.
- One session: `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (2560x1664 MBA, no host window), scratch HYPRK_STATE /
  XDG_CACHE_HOME / TMPDIR, the script's private bus. Apps: System Settings, foot `-a footA`, foot `-a footB`, arranged
  with `hl.dsp.window.move` so all three overlap (logical x 520-900, y 380-660 at scale 2) and footB reaches under the
  Dock (bottom at 815 pt, Dock layer 674-832); z order Settings (bottom), footA, footB (top). Tools: repo `vptr` (scratch
  build), `mcap` (9 runs, full output `-k 4`, `long_intervals` 0 in all), `grim`. Dark at scale 2, then light at 2,
  Stage Manager on/off via the scratch `stagemanager.json`, then dark at 1.6 in the same session (`hyprctl eval
  hl.monitor`). Stopped with `smoke.sh --stop`, bus killed, runtime dir gone, no pid left.
- Untouched and carried from judge #10: colour, shadow, icon, font, sound, Finder, HUD, Apps, lock screen, window chrome,
  System Settings, Spotlight, Cmd-Tab, Sounds.
- Crops in `reference/judge-95-11/` (01-07).

## Overall: **90.7** (13 surfaces 90.67, with the lock screen 90.68, with Stage Manager folded in at weight 2: 90.55)

Judge #10: 90.59. Gain: judge #10's top item is fixed. The picked (bottom) window is on top at the overlap in every
exit frame, takes the active look 3-16 frames before the end, and the Dock with its dots stays drawn over Mission
Control in every enter and exit frame with no step at the layer's map or unmap, in dark 2, light 2 and dark 1.6. The
riskiest change (plugin layer order) shows no regression in the at-rest sweep. New findings, not shown to be regressions: the Dock's hover label is hidden while Mission Control is open, and clicking a
Dock icon in Mission Control leaves Mission Control open.

## Plugin regression sweep (dark, scale 2, at rest)

| item | result |
|---|---|
| `hyprctl plugin list` | liquidglass 0.1.0 and hyprkmotion 0.1.0 loaded |
| Hyprland log | no crash, segfault or abort; warnings are the start-hyprland notice and xkbcomp only |
| Shell log | no QML error, no TypeError / ReferenceError, no binding loop |
| Dock at rest | glass, dots, divider, icons right; over footB the band darkens as glass over a dark window should |
| Dock hover label (Ghostty) `05` | ok: glass pill above the icon |
| Dock menu (Notes, `r`) | ok: Options > / Open in glass |
| Menu bar menu (Edit) | ok: glass, disabled items grey, shortcut glyphs |
| Control Center, Notification Centre | ok: tiles, sliders, widgets drawn, glass over the window and wallpaper |
| Spotlight | ok: bar, placeholder, mic |
| Window reaching under the Dock | Dock and dots drawn over it at 2 and 1.6 |

## Mission Control (3 overlapping windows, pick the bottom one: Settings)

| measure | dark, scale 2 `01` | light, scale 2 `02` | dark, scale 1.6 `03` |
|---|---|---|---|
| enter, first change after trigger | 138 ms | 68 ms (hyprctl latency varies) | 84 ms |
| enter, Dock rows (680x76 pt) mean abs diff of consecutive frames at the layer's map frame | 0.41 (next frames 2.5, 4.0 while footB's thumbnail leaves the glass, motion) | 0.18, then 4.6 / 5.2 (Settings and footB leaving the band, motion, `07`) | 0.05, then 0.46, 5.24 |
| exit duration (trigger to last changing frame) | 388 ms | 390 ms | 374 ms |
| picked window on top at the triple overlap | every frame from the first moving one (71 ms) | every frame | every frame |
| active look (blue sidebar selection, coloured lights) | from 104 ms (frame 2 of 20) | from 189 ms (frame 7 of 20) | from 190 ms (frame 8 of 19) |
| exit, Dock rows: peak (motion of footB under the glass) | 3.93 at 87 ms, 11 % of samples > 20 | 5.66 at 89 ms | 4.66 at 89 ms |
| exit, Dock rows at the unmap (last) frame | **0.69**, 0 samples > 20 (judge #10 / dev before: 14.17) | **0.47**, 0 > 20 | **0.07**, 0 > 20 |
| exit, whole screen at the last frame | 2.69 (thumbnail text edges sharpening to the real window, the previous frame 0.71) | 2.69 | 1.82 |
| Dock and dots visible over Mission Control | every frame | every frame | every frame (band faint over footB, icons drawn) |

No pop in the last frame: the residual is text sharpness, not position, z order or look. This matches Q-dock-27 (the
Dock stays visible in Mission Control). The Mac recording of an exit with overlapping windows still does not exist, so
which window is drawn on top during the Mac's exit is assumed, not measured.

### Dock while Mission Control is open `04`

- Hover a Dock icon: **no label**. The `hyprk-dock-label` layer is mapped but drawn under the mission layer (it is not
  in `draw_over`'s list). At rest the same hover shows the label (`05`). On the Mac the Dock works normally in Mission
  Control (label not in MAC-ANSWERS, belum dicek on a recording).
- Click a Dock icon (Notes, not running): the app launched and its window joined the Mission Control layout; **Mission
  Control stayed open**. The Mac leaves Mission Control and activates the app. In the first layout after the new window
  appeared, footA's thumbnail was not visible (covered or not re-laid out); reopening Mission Control laid out all four
  windows. Seen once.

### Stage Manager + Mission Control `06`

Stage Manager on (strip with the two foot piles, Settings on stage): Mission Control shows only the stage's window
(Settings), the strip goes, the Dock is drawn over the layer. Enter Dock rows 4.25 / 3.97 for two frames, 0 samples
over 20 (Settings passing), then 0. Stage Manager off: all three windows back on workspace 1, no stage layer left.
Whether the Mac shows the other stages' windows in Mission Control: needs the Mac.

## Per dimension

| dimension | j10 | j11 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | [10] |
| transition | 89 | **90** | +1 | [11 live] MC exit: picked window on top and active while flying, no last-frame pop, 3 configs |
| visual | 92 | 92 | 0 | [11 live] sweep clean; Dock label missing in MC (-), Dock over MC (+) |
| behaviour | 90 | 90 | 0 | [11 live] Dock click in MC does not leave MC (pre-existing, -), MC pick raise right (+) |
| shape | 90 | 90 | 0 | [10]; 1.6 layout intact |
| colour | 95 | 95 | 0 | [10] |
| shadow | 94 | 94 | 0 | [10] |
| refraction | 91 | 91 | 0 | [11 live] Dock glass refracts the flying thumbnails (+, small); no Mac number for it |
| icon | 90 | 90 | 0 | [10] |
| font | 95 | 95 | 0 | [10] |
| rendering | 89 | **90** | +1 | [11 live] no Dock step at the layer's map / unmap (0.69 / 0.47 / 0.07 against 14.17), Dock never hidden |
| sound | 87 | 87 | 0 | [10] |

## Per surface

| surface | weight | j10 | j11 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92.5 | 92.5 | sweep clean |
| Dock | 14 | 91 | 91 | over MC (+); label hidden and click not leaving MC (-) |
| Window chrome | 14 | 90 | 90 | carried |
| Finder | 13 | 90 | 90 | carried |
| System Settings | 10 | 92.5 | 92.5 | carried |
| Control Center | 6 | 93 | 93 | sweep clean |
| NC + banners | 6 | 90.5 | 90.5 | sweep clean |
| Spotlight | 6 | 88 | 88 | carried (open drawn, not re-measured) |
| Mission Control | 4 | 87.5 | **89.5** | exit order, look and Dock fixed at 2 / 1.6, light / dark |
| Sounds | 4 | 87 | 87 | carried |
| HUD | 3 | 90 | 90 | carried |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91 | 91 | carried, not tested (rule) |
| *Stage Manager (extra)* | *2* | *85* | *85* | MC with SM clean on our side; Mac behaviour unknown |

Weighted: 13 surfaces 9066.5 / 100 = 90.67. With the lock screen 9521.5 / 105 = 90.68. With Stage Manager 9236.5 / 102
= 90.55.

## Regressions

None found. The plugin's layer order change leaves the at-rest screen, the Dock menu, menus, Control Center,
Notification Centre and Spotlight drawn as before; the log is clean. The developer's "not checked" items: scale 1.6
checked here (clean); a Dock tooltip while MC is open is hidden (popups and the label keep the normal order, under the
layer), recorded as a finding, not a regression: the commit message says popups were left in the normal order on purpose, and
judge #10 did not test the label in Mission Control.

## The next 10 changes, by gain

1. Dock click while Mission Control is open: close Mission Control and activate / launch the app, as the Mac (+0.05,
   repo only).
2. Dock hover label (and the Dock menu) over Mission Control: add `hyprk-dock-label` to `draw_over` or draw it from the
   mission layer (+0.03, repo only; confirm on a Mac recording that the label shows, needs the Mac for the check).
3. Mission Control exit with several windows from a Mac 4-window recording (which window flies on top) (+0.1, needs
   the Mac).
4. Spotlight reopen first frame (1.069 repeated, judge #10); agree the measure with the developer (+0.05, repo only).
5. Stack popup (fan / grid) after a Mac capture (+0.05, needs the Mac).
6. A window opened while Mission Control is open: re-lay out every thumbnail (footA vanished once) (+0.02, repo only).
7. Stage Manager + Mission Control: show the other stages' windows if the Mac does (+0.03, needs the Mac).
8. Spotlight open latency, Mac key-to-first-frame (+0.03, needs the Mac).
9. Press light: keep the tint at the pointer instead of clipping to white (+0.03, needs the Mac for the target).
10. Dock: clicking Finder with no Finder window opens one (carried) (+0.02, repo only).

## Reachable ceiling

About 91 with the repo's data (items 1, 2, 4, 6, 10), 91.5-92 with new Mac captures.
