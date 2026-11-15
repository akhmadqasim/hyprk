# hyprk independent judge #24, branch mac-27.2.1-rea-2026-11-14 (0e5bb73) + working tree (2026-11-15, 18:24-18:45 WITA, measured live)

Delta judgement against judge #23 (`JUDGE-95-23.md`, 93.5). Method and weights from `JUDGE-95-7.md` as carried by #17-#23:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[24 live]** measured
on screen here; **[23]** carried from judge #23. The new Settings destinations stay outside the comparable crops: they
are judged in their own section and only enter the **extended** total.

## What was judged

- The twelve live checks of `scripts/motion-capture/`, each run here; sound, scaling and depth measured (they were carried
  for several rounds); 10 Settings destinations of Mac rounds 12, 13 and 15 against their stills, light and dark.
- `plugin/build/libliquidglass.so` (11:44) is newer than every file under `plugin/src` and `plugin/shaders`: loaded as
  is, nothing built. Finder binary 17:37, newer than `finder/src` and `finder/qml`; started as `finder/build/hyprk-finder`
  (not `run.sh`, which would build).
- Three headless sessions, one at a time, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1
  HYPRK_BRIGHTNESS_STUB=1 HYPRK_SOUND_LOG=<scratch> scripts/smoke.sh`, state `$XDG_RUNTIME_DIR/hk-j24` (repo
  `appearance.json` copied, `wallpaper.json` to a scratch flat grey 127), scratch HOME, XDG_CACHE_HOME, TMPDIR, the
  script's private bus:
  - scale 2, 2560 x 1664 (1280 x 832 pt);
  - scale 1.5, 2880 x 1866 (1920 x 1244 pt) and scale 1.25, 2560 x 1600 (2048 x 1280 pt): a scratch `HYPRK_CONFIG` (the
    repo's `hyprland.lua` with the `MBA` monitor rule changed), `HYPRK_SCALE_POLICY=off`, so the shell is born at the scale.
- Own scratch tools: `meas.py` (ink row runs in the content column of two 1480 x 1250 stills, as #23's), `scalecmp.py`
  (the scale 2 shot resampled to the scale under test, best offset within a few px, rms against the shot at that scale),
  `ban.py` (banner shadow column, Dock box), four-click shots of the Group button.
- Stopped with `smoke.sh --stop`; Settings and Finder killed by pid after checking the scratch HOME in their environ; the
  three bus pids killed after checking their command line names my state dir. State dir and scratch removed. Not
  touched: `vptr` 398960 and 1957559 (other agents' scratch HOME, started 14 and 15 Nov). One slip: the first start at
  1.25 ran in a shell that still had the stopped session's `WAYLAND_DISPLAY`; Hyprland exited at once ("CBackend::create()
  failed") and a Settings process started against the dead socket for some seconds before I killed it by pid. Nothing was
  shown anywhere (no `wayland-1` socket existed). That start left a hung Hyprland child (69357, my scratch config and
  HOME), killed by pid at the end with its runtime dir. Nothing written to the repo but this file and the crops.
- Tests: `node shell/tests/run.mjs` **425 / 0**, `node finder/tests/run.mjs` **40 / 0**. Shell logs of the three sessions:
  no TypeError, ReferenceError or binding loop.
- Not measured, no credit: Spotlight top row over white, the light gallery inspector, Cmd-Tab, lock screen, Stage Manager,
  Apps, NC, alert and menu rims (plugin sources unchanged since #22), emoji and font (carried), the real PipeWire path,
  Control Center / Spotlight / NC / lock screen line patterns at 1.5 and 1.25, Lock Screen root and Accessibility top pane
  (#23's Settings defects 5 and 6).

## Overall: **93.6** (13 surfaces 93.63, with the lock screen 93.53, with Stage Manager folded in at weight 2: 93.46)

Judge #23: 93.5 (93.50). Extended total with the new Settings destinations: **93.62** (Settings 95.5 -> 95.4; #23 95.3).

Every live check passes here except two that depend on the session, not on hyprk: `sheet-depth.py` clicked the wrong
sidebar row (this session's Settings lists no Wi-Fi, so Menu Bar sits 32 pt higher than the script assumes), and
`toolbar-menus.py` failed its first run on its base shot. Both pass when driven correctly. The Dock's separator now
resizes with the resize cursor, the sheet shadow and the lights under a sheet are the Mac's, sound timing is within one
60 Hz frame of the Mac's on every relation. Scaling holds its geometry and shadow in points at 2, 1.5 and 1.25; one
Settings sub-pane separator is still drawn on whole pixels at both fractional scales.

## The live checks

| # | check | measured here | verdict |
|---|---|---|---|
| 1 | `dock-resize.py` | cursor box centre -0.8, +0.5 pt from the pointer on hover and -1.0, -0.2 in the drag (resize up-down); separator line **72 -> 98 pt** while held (26 pt up); `dock.json` size **90** after the release (put back to 64) | **reproduced** (#23: nothing happened) |
| 2 | `dock-plate-sync.py` | 126 frames of a 26 pt drag: icons' top - plate's top 10 pt at rest, **7..14** during the drag, worst 4 pt off | **reproduced**; the plate still trails the icons by 3-4 pt |
| 3 | `volume-key-hud.py` | 8 of 8 steps show the HUD: at full, at zero, level changes, and a step onto the level a test call left | **reproduced** (#23 claim 3c: test path broken) |
| 4 | `mc-exit.py` | first exit frame: bar edge 57 of 73 pt, title alpha **0.23** (Mac .23); bar track rms **0.007**, title track rms **0.001** against the Mac's | **reproduced** |
| 5 | `search-press.py` | press frame: disc **36.0 -> 39.0 pt** in one frame (Mac 37 -> 40), x1.083 (Mac 1.081), held (59,59,59) (Mac 58.5); release opens the field 503 ms after a 500 ms hold | **reproduced**; the disc is 1 pt smaller than the Mac's at rest and held |
| 6 | `style-tiles.py` | rms over the 54 px body: Default **12.9**, Dark **5.4**, Clear **10.2**, Tinted **11.8** (floors 11.7 / 5.6 / 10.6 / 12.1); pitch 53 50.5 51 pt (Mac 53.5 50.5 51) | **reproduced** |
| 7 | `slider-glyphs.py` | 8 of 8 cases: Display low / high peak **x1.26 / x1.24**, trough x0.90 / x0.88; Sound low / high **x1.29 / x1.27**, trough x0.89 / x0.93 (Mac 1.25 / 0.90), slow drag and slam alike | **reproduced** |
| 8 | `sound-timing.py` | 10 key runs: pill -> pop out **42-59, mean 49.2 ms** (Mac 48.7); pop out -> first HUD frame **16-44, mean 32.0** (Mac 18.0); pill -> HUD 67-103, mean 81.2 (Mac 66.7); key -> first HUD frame **97-119, mean 109.2** (Mac 112-127 filmed, about 90-105); 50 % at 263-284, mean 275.8 (Mac 277-293); 90 % at 415-434, mean 425.7 (Mac 440-445). Screenshot sound **225-246, mean 229.7 ms** after the key (Mac 222 / 247). Poof **+3 ms** after the removal's first frame (Mac +15, the same frame); the gap closes in **233 ms** (Mac 250); no cloud | **reproduced** |
| 9 | `player-latency.py` | 12 of 12 runs on a private PipeWire: 12.0-49.3 ms, **median 15.3**, mean 23.2 (the docs say median 12.0-12.1; the timing check adds 12) | **reproduced within its limit**, 3 ms above the documented median |
| 10 | `scale-lines.py` | scale 2: 7 lines at [1, 1]. Scale 1.5: Dock separator, 2 menu separators, 2 Settings rows (Appearance) on a resample pattern; **Software Update row separator [1.0, 1.0]** (two whole px for 1 pt) at 445.3 pt. Scale 1.25: Dock and menu separators on a pattern; the same Software Update separator **[1.0, 1.0]** at 464.0 pt. Finder: "no 1 pt line found" in every run | **partly**: the Finder header line is not reproduced, one sub-pane separator fails at both fractional scales |
| 11 | `sheet-depth.py` | as shipped: 8 of 8 FAIL, it opened Spotlight instead of Menu Bar (sidebar row at y 538; here 506, no Wi-Fi row). With that one coordinate changed (scratch copy): light right of the sheet **179 183 186 190 192 195 197 198** (Mac 178 182 185 189 192 194 196 198), under **161 163 166 170 174 178 181 185 188** (Mac 161 164 168 172 176 180 184 187 190), above 198-204 (Mac 196-203); dark right **22 23 24 25 26 26 27 27** (the Mac's to the level), under within 1, above 25-26 (Mac 27-29). Lights: close (226,227,229) / (75,76,82) (Mac (229,230,234) / (72,74,86)), minimise and zoom in colour | **reproduced** with the row fixed; the script is not portable |
| 12 | `toolbar-menus.py` | first run FAIL (open open open open, 178 231 / 249 526 changed px: the base shot differed). My own four clicks with a shot each: open, closed, open, closed (`15`, `16`). Two more runs of the script: ok, 208 320 / 378 px | **reproduced**; the first run's failure is the check's base shot |

## Sound, scaling and depth, measured

**Sound** (row 8 and 9 above). Every relation of the key path is within one 60 Hz frame of the Mac's. Largest gaps: pop
out -> first HUD frame +14 ms (32.0 against 18.0), HUD at 90 % 14-19 ms early, the Dock gap 233 against 250 ms. Stub
sink only: the real PipeWire path and a real device's period were not driven. No Mac clip exists for Empty Trash, a
drag-off poof by hand or a hardware volume key on the recording clock.

**Scaling**, three sessions:

| measure | scale 2 | scale 1.5 | scale 1.25 |
|---|---|---|---|
| Dock box (with its rim), pt | 525 x 84 [23] | **525.33 x 84.67**, 4.67 above the edge | **524.80 x 84.80**, 4.80 |
| banner, pt | 345.0 x 58.5 | 345.3 x 59.3 | 345.6 x 59.2 |
| banner shadow, light over grey, at 1 4 8 14 22 30 40 pt | **10 9 8 6 3 1 0** (Mac 10 9 7 5 3 1 0) | 10 9 8 6 3 1 0 | 10 9 8 6 3-4 1-2 0-1 |
| Settings window, pt | 740 x 625 | 740 x 626 at px 885, 423 | 740 x 624 at px **817.5, 376.25** |
| Settings (Software Update) against the scale 2 shot resampled | - | rms **2.80**, 0.03 % of px over 40 | rms **5.23**, 0.60 % |
| Dock against the scale 2 shot resampled | - | rms 9.50, 2.0 % over 40 | rms 14.50, 3.3 % |
| status items against the scale 2 shot resampled | - | rms 6.17 | rms 10.73 |
| 1 pt lines (`scale-lines.py`) | 7 of 7 | 5 of 6 | 3 of 4 |

By eye at 1.5 and 1.25 (`10`-`14`): no doubled rim, no clipped glyph, no missing stroke in the menu bar, the Finder menu,
Control Center and the Dock. Open: the Software Update separator; the Settings window's origin on a fraction of a device
pixel at 1.25; the Mac side is simulated (every Mac capture is the 2x backing, not the panel's pixels).

**Depth**: rows 2 and 11. The sheet shadow is within 0-3 levels of the Mac's in both modes and only the close light is
greyed under a sheet. The Dock's plate trails its icons by up to 4 pt during a separator drag. The dark minimise / zoom
under the sheet read (245,186,8) (31,184,12) against the still's (243,193,31) (92,188,30): green 60 lower in red on zoom.

## Regression sweep

| surface | checked | result |
|---|---|---|
| plugin glass | sources against the build time | no file changed: alert, menu, Spotlight numbers [23] |
| Dock | hover, drag, release on the separator; Remove from Dock | rows 1, 2, 8 |
| Finder | Group menu four clicks, Search press | rows 5, 12 |
| HUD | 8 key steps, timing | rows 3, 8 |
| Control Center | opened at 2, 1.5, 1.25; end glyph bounce | row 7; no regression |
| banner | shadow at 2, 1.5, 1.25 | 10 9 8 6 3 1 0 at each |
| Settings | 10 destinations, both modes; Clock Options sheet | section below |
| shell log | three sessions | clean |
| tests | shell, finder | 425 / 0, 40 / 0 |

## Per dimension

| dimension | j23 | j24 | change | reason |
|---|---|---|---|---|
| animation | 93.1 | **93.5** | +0.4 | MC exit tracks rms .007 / .001, slider end glyphs bounce at 1.24-1.29 / 0.88-0.93 (Mac 1.25 / 0.90), Search press in one frame, Dock gap 233 ms (Mac 250) |
| transition | 91.25 | **91.4** | +0.15 | MC exit: titles above the bar from the first frame |
| visual | 94.45 | 94.45 | 0 | [23] |
| behaviour | 93.95 | **94.2** | +0.25 | separator resize with its cursor, Group menu closes on the second click, HUD on 8 of 8 steps |
| shape | 92.6 | 92.6 | 0 | [23]; Search disc 36 pt against 37 |
| colour | 95 | 95 | 0 | at target |
| shadow | 94.9 | 94.9 | 0 | banner profile re-measured, the same at three scales; the sheet shadow is in the extended section |
| refraction | 94.55 | 94.55 | 0 | [23] |
| icon | 93.85 | **93.95** | +0.1 | style tiles within their floors (12.9 / 5.4 / 10.2 / 11.8) |
| font | 95 | 95 | 0 | [23]; sub-pane text runs within 0-2 px on 7 of 10 destinations |
| rendering | 90.95 | **91.1** | +0.15 | plate never detached (worst 4 pt), lines at 1.5 / 1.25 on the resample patterns bar one |
| sound | 90.35 | **92.0** | +1.65 | measured: every relation within one frame, screenshot 230 ms (Mac 222 / 247), poof in the removal's frame |

Plain mean of the 12: 93.55 (j23 93.33).

## Per surface

| surface | weight | j23 | j24 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.85 | 94.85 | [23]; menu separators hold at 1.5 / 1.25 |
| Dock | 14 | 94.8 | **94.95** | separator resize and cursor work, gap closes in 233 ms with the poof in the same frame. Left: plate 3-4 pt behind during the drag |
| Window chrome | 14 | 93.35 | 93.35 | [23] |
| Finder | 13 | 94.0 | **94.15** | Group menu fixed, Search press as the Mac's bar 1 pt. Left: light inspector +6 [23], disc 36 pt |
| System Settings | 10 | 95.5 | 95.5 | #22's crops unchanged; new destinations in the extended total only |
| Control Center | 6 | 94.3 | **94.4** | end glyphs bounce by layer on Display and Sound |
| NC + banners | 6 | 92.4 | 92.4 | [23]; banner shadow re-measured, unchanged |
| Spotlight | 6 | 91.3 | 91.3 | [23] |
| Mission Control | 4 | 91.25 | **91.75** | exit tracks at the Mac's |
| Sounds | 4 | 90.6 | **92.0** | timing measured on all three events |
| HUD | 3 | 92.0 | **92.2** | shown at zero and after a test call; first frame 109 ms after the key |
| Cmd-Tab | 3 | 91 | 91 | [23] |
| Apps | 2 | 86 | 86 | [23] |
| Lock screen | 5 | 91.5 | 91.5 | [23] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [23] |

Weighted: 13 surfaces 9363.1 / 100 = 93.63. With the lock screen 9820.6 / 105 = 93.53. With Stage Manager
9533.1 / 102 = 93.46. Extended (Settings 95.4): 9362.1 / 100 = 93.62.

## Settings destinations (extended, outside #22's crops)

Mac stills `re/27.2.1/live/settings-r12/`, `settings-r13/`, `settings-r15/`, window 740 x 625 at 2x; ours the same
window shot from the scale 2 session (one Settings process per destination, `HYPRK_SETTINGS_PANE` / `HYPRK_SETTINGS_SUB`).
Light and dark each. `meas.py`: ink row runs in the content column, (top, bottom, left, right) in px.

| # | destination | runs matched (Mac / ours) | row offset, px | result |
|---|---|---|---|---|
| 1 | General > About (r15) | 5 of 11 | 0..2 | Name / Chip / Memory rows at 289 / 326 / 363 pt as the Mac's; the rest is this machine's (no Serial number, no Coverage, an "Ubuntu" group) (`07`) |
| 2 | General > Software Update (r15) | 7 of 7 | -1..1 | match; 0.9-1.0 % of px over 40 |
| 3 | General > Storage (r15) | 4 of 16 | 0..1 | bar and legend match; **no "Recommendations" group**, 4 category rows against 7+, the Applications row has a generic glyph (`05`) |
| 4 | Accessibility > Hover Text (r12) | 7 of 7 | 0..1 | match |
| 5 | Accessibility > Audio (r12) | 5 of 15 | -1..3 | first card matches; the Mac's still has an AirPods group ours cannot have; Background Sounds group the same rows (`09`) |
| 6 | Accessibility > Pointer Control (r12) | 18 of 18 dark, 17 of 18 light | -1..1 | match |
| 7 | Accessibility > Switch Control (r12) | 15 of 15 dark, 14 of 15 light | -2..0, one row +5 | match; the "Duration of inactivity" field 24 px of ink high against 34, its "seconds" dimmed (`08`) |
| 8 | Focus > Sleep (r13) | 15 of 17 | -3..1 | match; the "Allow Notifications" caption runs to x 730 pt, the Mac wraps at 648 (`06`) |
| 9 | Privacy & Security > FileVault (r13) | 6 of 7 | -2..0 | **"Password Reset" header bold**: ours x 640-729 px, ink 7.11; Mac 649-714, ink 5.94 (regular, 4.5 pt further right) (`03`) |
| 10 | Privacy & Security > Lockdown Mode (r13) | 6 of 7 | 0..2 | placard text 1 pt low; caption lines end at 1231 / 1194 px, Mac 1186 / 1179 (wraps 22 pt later) (`04`) |
| + | Menu Bar > Clock Options… (sheet, r13) | 7 of 7 | 0..1 | rows now at the Mac's (410 482 557 632 726 800 876 against 409-410 483 558 632 727 801 876-877); "Interval" / "Voice" labels **37** light, 223 dark (Mac 38 / 222) (`01`, `02`) |

Since #23: its defects 1 (sheet shadow), 2 (lights under a sheet) and 4 (Clock Options rows and dimmed labels) are fixed
and measured here; 3 (placard switch): the Firewall switch box reads 219 x 93 px against the Mac's 220 x 92 by one crude
box, so likely fixed; 5 and 6 not re-measured (carried).

Defects, by cost (points of the Settings surface):

| # | defect | numbers | file | cost |
|---|---|---|---|---|
| 1 | Storage: no Recommendations group, generic row glyphs | 4 of 16 runs match | `settings/panes/general/Storage.qml` | 0.03 |
| 2 | FileVault: section header weight | ink 7.11 against 5.94, 89 px wide against 65 | `settings/panes/privacy/FileVault.qml` | 0.02 |
| 3 | caption wrap width in placards and headers | Lockdown +22 pt, Sleep +82 pt before the wrap | `settings/panes/privacy/Lockdown.qml`, `panes/focus/Mode.qml` | 0.02 |
| 4 | Lock Screen root [23] | no "Show Live Activities" row | `settings/panes/LockScreen.qml` | 0.02 |
| 5 | Accessibility top pane [23], Switch Control field | content 1.5-2 pt high; field 12 against 17 pt | `settings/panes/Accessibility.qml`, `accessibility/SwitchControl.qml` | 0.01 |

Not comparable: the dark window and card fill over the flat grey wallpaper ((35,35,35) / (42,42,42), Mac (30,31,36) /
(37,38,43) over Tahoe Dark); the Mac's Dark icon style on its placard tiles; rows that belong to the Mac's hardware
(Wi-Fi, Battery, Siri in the sidebar: this session has no Wi-Fi device).

## Regressions

None in what #23 measured. Check scripts, not hyprk: `sheet-depth.py` assumes a Wi-Fi row; `toolbar-menus.py` can take
its base shot too early; `--keep DIR` in `sheet-depth.py` and `scale-lines.py` crashes when DIR does not exist.

## Top defects by points

| # | defect | numbers | file | cost |
|---|---|---|---|---|
| 1 | Spotlight dark list top row over white [23] | rows +21 / +22 **119 / 120** flat, Mac **100 / 119** and 89 at 200 pt | `plugin/shaders/liquidglass.frag` | 0.03 |
| 2 | Settings sub-pane separator on whole pixels at a fractional scale | Software Update row line **[1.0, 1.0]** at 1.5 (445.3 pt) and 1.25 (464.0 pt); wanted [1, .5] / [1, .25] | `ui/HyprK/pixel.js`, `settings/panes/general/SoftwareUpdate.qml` | 0.015 |
| 3 | Gallery inspector material in light [23] | base **(241,241,244)**, Mac (235,237,239) | `finder/qml/shaders/inspector.frag`, `finder/qml/Theme.qml` | 0.013 |
| 4 | Dock plate trails its icons in a separator drag | icons' top - plate's top 7..14 pt against 10 at rest, 126 frames | `shell/modules/Dock.qml`, plugin | 0.01 |
| 5 | HUD after the pop, Finder Search disc | pop out -> first HUD frame **32.0 ms** (Mac 18.0); disc **36 -> 39 pt** (Mac 37 -> 40) | `shell/services/Hud.qml`, `finder/qml/ToolButton.qml` | 0.01 |

Also open: Spotlight bar bottom rim 156 -> 146 (Mac 167 -> 156) [23]; player start median 15.3 ms against the 12 the
timing check adds; dark zoom light (31,184,12) against a second Mac still's (92,188,30); Settings window origin at a
fraction of a device pixel at 1.25; #22's list (CC dark lens fill, light hold disc, inactive light grey 75 vs 67).

## What stands between 93.6 and 95

The gap is 1.37 points, which is 137 of the 142 weight-points still missing on all 13 surfaces together. So 95 needs
nearly every surface at 95; no single list of repo fixes reaches it. In order of gain:

| # | item | gain (total) | needs new Mac data |
|---|---|---|---|
| 1 | Window chrome 93.35 -> 95: in-window alert blur, Qt windows activated by a light press, inactive grey 75 vs 67, dark lights fit | up to 0.23 | yes (D1 dark lights still; alert blur clip) |
| 2 | Spotlight 91.3 -> 95: top row over white, bar bottom rim, mode list glyphs | up to 0.22 (0.04 known) | partly (the rest of the gap has no named defect: new stills) |
| 3 | Apps 86 -> 95 | up to 0.18 | yes (never re-captured since #7) |
| 4 | NC + banners 92.4 -> 95: NC dark side line 63 vs 54, card dark side | up to 0.16 | partly |
| 5 | Mission Control 91.75 -> 95: Finder pick +4 frames, Spaces bar | up to 0.13 | no for the pick; yes for the rest |
| 6 | Sounds 92.0 -> 95: Empty Trash, drag-off poof, hardware key, real PipeWire path | up to 0.12 | yes (S1-S4) |
| 7 | Cmd-Tab 91 -> 95 | up to 0.12 | yes |
| 8 | Finder 94.15 -> 95: light inspector 6 darker, Search disc 37 pt | up to 0.11 (0.02 known) | no |
| 9 | HUD 92.2 -> 95: first frame 14 ms after the Mac's, hide 1.13-1.20 s | up to 0.08 | no |
| 10 | Control Center, Menu bar, Dock: dark lens fill, plate and icons in one frame | up to 0.07 | D2 for the Dock |
| 11 | Scaling (area only, not in the total): sub-pane separators, window origin at 1.25 | area +0.5 | yes for more (C1, C2: the panel's own pixels) |

## Reachable ceiling

About 93.75 with the known repo items (Spotlight top row, light inspector, the separator, HUD delay, Search disc, the
plate). About 94.0 if the requested Mac captures (S1-S4, C1, C2, D1, D2) confirm what is built. 95 is not reachable on
this stack for judge #7's reasons.

## The twelve areas of the 95 goal

| area | scored as | j23 | j24 | change | reason / what holds it under 95 |
|---|---|---|---|---|---|
| animation | animation | 93.1 | **93.5** | +0.4 | MC exit, slider glyphs, Search press, Dock gap reproduced; HUD first frame +14 ms, MC pick in Finder +4 frames |
| liquid glass | refraction + visual | 94.5 | 94.5 | 0 | [23]; Spotlight top row, CC fill, no glass in third-party windows |
| glass refraction | refraction | 94.55 | 94.55 | 0 | [23]; Spotlight top row and bar rim |
| shadows | shadow | 94.9 | 94.9 | 0 | banner 10 9 8 6 3 1 0 at 2, 1.5 and 1.25; sheet shadow within 0-3 (extended) |
| depth | shadow + rendering | 92.9 | **93.0** | +0.1 | measured: sheet over the dimmed pane, lights above the dim, plate under the icons (worst 4 pt); the plate trails by 1-2 frames |
| opacity | colour | 95 | 95 | 0 | at target |
| blur | refraction + visual | 94.05 | 94.05 | 0 | [23]; light inspector +6..+12 |
| sound | sound | 90.35 | **92.0** | +1.65 | measured: all relations within one frame; no Mac data for Empty Trash, drag-off poof, a hardware key; stub sink only |
| icon | icon | 93.85 | **93.95** | +0.1 | style tiles at their floors; document renders, ⌘ glyph [21] |
| emoji | (direct) | 95 | 95 | 0 | [21], not measured here |
| font | font | 95 | 95 | 0 | [21]; 7 of 10 sub-panes within 0-2 px; FileVault header weight (extended) |
| scaling | (direct) | 91.5 | **92.5** | +1.0 | measured at 1.5 and 1.25: geometry and shadow constant in pt, Settings rms 2.8 / 5.2 against the resampled 2x; one separator on whole pixels, Finder line not found, Mac panel pixels never captured |

## Crops (`reference/judge-95-24/`)

`01` / `02-settings-clock-options-sheet-{light,dark}-mac-left-ours-right.png`,
`03-settings-filevault-light`, `04-settings-lockdown-dark`, `05-settings-storage-dark`, `06-settings-sleep-dark`,
`07-settings-about-dark`, `08-settings-switchcontrol-dark`, `09-settings-audio-light` (each `-mac-left-ours-right.png`,
1 px per pt), `10-scale-1.5-settings-software-update-ours.png`, `11-scale-1.5-dock-ours.png`,
`12-scale-1.5-control-center-ours.png`, `13-scale-1.5-finder-menu-ours.png`,
`14-scale-1.25-control-center-dock-2x-zoom-ours.png`, `15-finder-group-menu-click-1-open-ours.png`,
`16-finder-group-menu-click-2-closed-ours.png`. The scale crops are device pixels.
