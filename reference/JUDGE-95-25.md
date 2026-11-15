# hyprk independent judge #25, branch mac-27.2.1-rea-2026-11-14 (db9046e) + working tree (2026-11-15, 21:28-22:35 WITA, measured live)

Delta judgement against judge #24 (`JUDGE-95-24.md`, 93.6). Method, surfaces, crops and weights as #24 (from `JUDGE-95-7.md`):
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[25 live]** measured on
screen here; **[24]** carried from judge #24. Since #24 the Mac rounds 16, 17 and 18 landed (`MAC-ANSWERS-16/17/18.md`, stills
under `re/27.2.1/live/r17/` and `r18/`, fixes in `OPEN-FIXES.md` items 40-46 of the last two rounds). Surfaces that #24 carried
(Apps, Cmd-Tab, Window chrome, Spotlight) are re-scored here against the fresh r17 stills.

## What was judged

- All 27 scripts of `scripts/motion-capture/`, run here in my own headless sessions (the fifteen that #24 ran plus apps-view,
  cmd-tab, lights-colour, menu-blink, mc-bar, mc-pick, nc-side-line, cc-lens-fill, spotlight-edge, dock-plate-sync's new metric).
  `mcap.py`, `livecheck.py`, `fscroll.c` and `mcap.c` are helpers, not checks. Credit only for what ran green here.
- `plugin/build/libliquidglass.so` (21:27 today) is newer than every file under `plugin/src` and `plugin/shaders`: loaded as is,
  nothing built. **`finder/build/hyprk-finder` (17:37) is older than four Finder QML files** (`Toolbar.qml` 18:54, `ToolButton.qml`,
  `Main.qml`, `Theme.qml` 20:50): started as is, so those uncommitted Finder edits are not on screen here and earn nothing.
  No build was run (instruction).
- Three headless sessions, one at a time, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1
  HYPRK_BRIGHTNESS_STUB=1 HYPRK_SOUND_LOG=<scratch> scripts/smoke.sh`, state `$XDG_RUNTIME_DIR/hk-j25` (repo `appearance.json`
  copied, `wallpaper.json` flat grey 127, the scripts change it and put it back), scratch HOME, XDG_CACHE_HOME, TMPDIR, the script's
  private bus: scale 2 (2560 x 1664), scale 1.5 (2880 x 1866) and scale 1.25 (2560 x 1600) from a scratch `HYPRK_CONFIG` (repo
  `hyprland.lua` with the `MBA` rule changed) and `HYPRK_SCALE_POLICY=off`.
- Own scratch tools (in `/tmp`, not kept): a Spotlight / Apps state grabber (idle, "calc", mode list, Files, Actions, Clipboard,
  Applications, Applications "cal"; light over white 255, dark over flat (30,31,30) = the r17 "white-dark" backdrop), crop and rms
  against the r17 stills, ink-row runs for Settings (as #24's `meas.py`), a banner shadow / scale comparison (`scalecmp`), an emoji
  ink measure.
- One start-up slip, found and fixed during the run: the first Finder and Settings processes I started from my shell had no
  `FONTCONFIG_FILE`, `XDG_DATA_DIRS`, `QT_QPA_PLATFORM` (smoke.sh sets them for the session's own children only), so they drew with
  the system emoji and fallbacks. Scripts that read geometry only (lights-colour, mc-pick, search-press, toolbar-menus,
  style-tiles, sheet-depth, scale-lines) are not affected and passed. The emoji, font and Settings-text numbers below come from
  re-runs with the session's own environment (copied from the session shell's `/proc/<qs>/environ`).
- Stopped with `smoke.sh --stop <SIG>` three times; Finder and Settings killed by pid; the three bus pids killed by the pid the
  start printed. State dir and scratch removed. Not touched: `vptr` 398960 and 1957559 (other agents' scratch HOME).
  The headless sessions ran on `wayland-1`; nothing was started on the host display.
- Tests: `node shell/tests/run.mjs` **428 / 0**, `node finder/tests/run.mjs` **40 / 0**. Shell logs of the three sessions: no
  TypeError, ReferenceError or binding loop.
- Not measured, no credit: Spotlight over the Tahoe wallpaper (our flat backdrops stand in), Apps icons (our machine's apps, the
  Mac's are blurred), lock screen, Stage Manager, the light gallery inspector, the real PipeWire path, a hardware volume key,
  Mission Control with two Desktops, alert and menu rims over white and blue (not captured on the Mac).

## Overall: **94.3** (13 surfaces 94.29, with Stage Manager folded in at weight 2: 94.12; with the lock screen at 91.5: 94.15)

Judge #24: 93.6 (93.63). **+0.66**. The gain is nearly all surfaces that #24 had to carry because no Mac data existed
(Spotlight +1.9, Cmd-Tab +3.2, Apps +4.5, NC + banners +1.5, Window chrome +0.55) plus Mission Control and the HUD, whose
checks now match the Mac's frame counts.

Every script passes here. Four needed a second run or a clean desktop (not hyprk defects, see "Check scripts"): `cc-lens-fill.py`
failed its four r18 cases in the first run ("knob or lens not found", the stub's volume) and passes 37 / 37 on the next two runs;
`apps-view.py` failed the "panel grows" frame list in 2 of 4 runs (a dropped frame, see Apps); `sound-timing.py` needs an empty
desktop (with Finder and Settings open: "no pill, pop or HUD", "Dock motion not seen"), green with none; `lights-colour.py`
needs exactly one Finder and one Settings window.

## The live checks

| # | check | measured here | verdict |
|---|---|---|---|
| 1 | `dock-resize.py` | hover and drag cursor box -0.8, +0.5 / -1.0, -0.2 pt from the pointer; separator **72 -> 98 pt** while held; `dock.json` size 90 after the release | **reproduced** |
| 2 | `dock-plate-sync.py` | 134 frames of a 26 pt drag: icons' top - plate's top **17 pt at rest, 17..19** over the drag against the tile's own 16.2..18.8, worst 1.0 pt. (The script's metric changed since #24: the plate's top is no longer read inside the corner; #24's "7..14, 4 pt behind" was that reading. Not independently re-derived here; the check refuses 1.5 pt.) | **reproduced**, new metric |
| 3 | `volume-key-hud.py` | 8 of 8 steps show the HUD (full, zero, level changes, onto the test-call level) | **reproduced** |
| 4 | `mc-exit.py` | first exit frame bar edge 57 of 73 pt, title alpha **0.23** (Mac .23); bar track rms **0.007**, title track rms **0.001** | **reproduced** |
| 5 | `search-press.py` | disc **36 -> 39 pt** in one frame, x1.083, held (59,59,59); release opens the field 499 ms after the press (held 500). The check now compares with the Mac's **dark** stills (36 -> 39, 58.5), so #24's "1 pt smaller than the Mac's" is gone | **reproduced** |
| 6 | `style-tiles.py` | rms Default **12.9**, Dark **5.4**, Clear **10.2**, Tinted **11.8** (floors 11.7 / 5.6 / 10.6 / 12.1); pitch 53 50.5 51 pt | **reproduced** |
| 7 | `slider-glyphs.py` | 8 of 8: Display peak x1.23 / x1.26, trough x0.88-0.90; Sound peak x1.25 / x1.27, trough x0.86-0.93 (Mac 1.25 / 0.90) | **reproduced** |
| 8 | `sound-timing.py` | 10 key runs: pill -> pop out **42-57, mean 46.1 ms** (Mac 48.7); pop out -> first HUD frame **-1..26, mean 20.6** (Mac 18.0; #24: 32.0); pill -> HUD **50-83, mean 66.7 (Mac 66.7)**; key -> HUD first frame 79-110, mean 96.9 (Mac hand 84, filmed 112-127); 50 % 246-277, mean 264.1 (hand 238, filmed 277-293); 90 % 416-444, mean 431.4 (hand 418, filmed 440-445); HUD hold **966-1000, mean 980** (Mac 1000). Screenshot sound 225-255, mean 233.5 ms after the key (Mac 222 / 247). Remove from Dock: Dock first moves 372 ms after the click; poof **-10 ms** against the removal's first frame (check window -5..+10); Dock gap closes in **233 ms** (Mac 250); no cloud; item removed | **reproduced** |
| 9 | `player-latency.py` | 12 of 12 runs on a private PipeWire: 10.7-47.8 ms, **median 12.0**, mean 17.7 (#24: median 15.3) | **reproduced** |
| 10 | `scale-lines.py` | scale 2: 5 lines [1, 1], Settings 740 x 625. Scale 1.5: Dock separator [1.0, .51], 2 menu separators [.48, 1] / [1, .48], **Software Update row line [.73, 1.0]** at 445.3 pt (#24: [1.0, 1.0]); Settings 740 x 625 pt = 1110 x 937.5 px. Scale 1.25: Dock [.67, 1.0], menu [.24, 1] / [.53, 1], **Software Update row [1.0, .78]** at 463.2 pt (#24: [1.0, 1.0]); Settings 925 x 781.25 px. All on the Mac's resample patterns. Finder: "no 1 pt line found" at every scale | **reproduced**; the sub-pane separator defect of #24 is closed; the Finder line is still not found |
| 11 | `sheet-depth.py` | now portable (finds the Menu Bar row by ipc). light right of the sheet **179 183 186 190 192 195 197 198** (Mac 178 182 185 189 192 194 196 198, max 1.2), under max 2.4, above max 2.2; dark right max 0.2, under 0.8, above 1.2. Lights over the dim: light close (230,231,233) / Mac (229,230,234); dark close **(78,78,78) / Mac (72,74,86)**, max 8 | **reproduced** (8 of 8 within the script's tolerance) |
| 12 | `toolbar-menus.py` | Group glyph and chevron: open closed open closed (changed px 208 228 / 378) | **reproduced** |
| 13 | `lights-colour.py` | active close (242.0, 90.2, 80.9) / Mac (242.3, 91.2, 81.2), minimise (253.2, 191.9, 5.2) / (252.5, 191.2, 5.9), zoom (32.1, 190.9, 10.7) / (35.7, 191.5, 12.7); inactive white veil alpha **.169 centre, .191 top, .141 bottom** (Mac .170 / .195 / .150); Settings and Finder alike | **reproduced** |
| 14 | `menu-blink.py` | Desktop menu: highlight off **4**, on **3**, first fading frame **7** (Mac 4 / 3 / 7), fade rms 0.017; Dock menu: 4 / 4 / **8**, menu gone frame 19 (Mac 20), Dock moves frame **22-23** (Mac 22), fade rms 0.03-0.04; click -> Dock moves 384-401 ms | **reproduced** |
| 15 | `mc-pick.py` | Finder picked, Settings key: coloured **+2 frames**, old key grey +2 (Mac +2); Settings picked, Finder key: +2 / +1-2; first changed frame moves nothing (3 runs each). #24: Finder pick +4 | **reproduced** |
| 16 | `mc-bar.py` (r18) | bar **74 -> 166 pt** (Mac 68 -> 160, +92), track rms **0.31 pt** against the Mac's 16.7 ms frames; first moved frame 81 / 97 / 96 ms after the pointer (Mac about 85); top window row 113.5 -> 205.5 (+92.0), **39.5 pt** under the edge in every frame (Mac 39.5); still expanded 1.5 s after the pointer left | **reproduced** |
| 17 | `nc-side-line.py` (r18) | 8 r18 cases, line pixel Mac / ours: banner dark over white 79 / 81, over blue 159 / 158; card 78 / 78, blue 126 / 130; light banner 176 / 176 and 166 / 166, card 142 / 143 and 134 / 133. Straight sides: banner over grey 50 (Mac 50), over white 70 (72); card over grey 44 (44), white 70 / 69 (70), black 0 (0), blue **20/25/95 against 20/24/86** | **reproduced** (#24: card dark 63 against 54) |
| 18 | `cc-lens-fill.py` (r18) | 4 backdrops x idle / hover / held: module / track 50 / 70, 57 / 77, 59 / 79 (Mac 50 / 70, 57 / 77, 59 / 78); over blue 24 / 44, 31 / 51, 32 / 52 (Mac the same); light over white 186 / 206, 193 / 213, **200 / 220 (Mac 200 / 216)**; lens rim 47-48 px wide, rows 62..99 (Mac 48, 62..99); fill inside mean 219.4-220.7 against 220.2-221.4, rms 0.4-1.5; static hold rms 0.6 | **reproduced** on runs 2 and 3, run 1 failed on the stub's state |
| 19 | `spotlight-edge.py` (r17) | mode list over white row 1 / 100 pt / 200 pt / row 2 / row 3: **100 93 88 121 126** (Mac 100 94 90 119 123); bar bottom rows 132 149 167 162 159 (Mac 134 149 167 161 158); bar top 56 35 15 47 44 (57 34 13 49 43); results 164 157 153 142 125 (165 159 152 142 123); grey 127: 84 71 82 118 109 (85 73 83 118 105); step 67 90 135 143 154 (68 92 136 142 155) | **reproduced** (#24's top defect, row 1 119 / 120 against 100, is closed) |
| 20 | `cmd-tab.py` (r17) | light and dark, 6 cases each, all green: appear complete at **180 ms** (Mac 180), step 1 frame, cancel 1 frame, release ease-in-out 0.248 s (Mac 0.246), rms 0.6-0.7 %, quick tap 0 levels; geometry (ours / Mac, px at 2x): panel top 0, left 0 / -1, corner 33 / 33, 32 / 33, plate left 8 / 8, plate corner 28 / 27, plate fill -57 / -57 light, 65 / 64 dark, name rows 310-328 / 309-328, name level dark 247 / 246, light 20 / 17, stem 3.6-3.7 / 3.7 | **reproduced** |
| 21 | `apps-view.py` (r17) | rest: first chip 20.0 .. 46.0 pt (Mac 20 .. 46), separator at 168.0 pt, +35 levels (Mac 168, +35), bar unchanged, typed " — Open" 109 pt (Mac about 105), no chips and no separator while typed; close 84 ms, bar stays; **open: width 453 -> 866 pt, settled 845; level .38 .62 .79 .93 .97 against the Mac's .28 .47 .62 .75 .84 .89 .92 .98, settled 150-167 ms (Mac 215)**; the "panel grows" case failed in 2 of 4 runs (.38 .38 .93: a dropped frame) | **partly**: geometry reproduced, grow faster than the Mac's, flaky check |

## Surfaces: measured or carried

| surface | basis |
|---|---|
| Spotlight | **measured**: rows 19 above; our stills against r17 stills over white (light) and flat (30,31,30) (dark), crops `03`-`07` |
| Apps | **measured**: row 21, our stills against `apps-rest-*` / `apps-typed-cal-*` (`08`-`10`); the Mac's backdrop was the Tahoe wallpaper, so no pixel rms is quoted |
| Cmd-Tab | **measured**: row 20, crops `01`, `02` (the script's own Mac-above-ours strips) |
| Window chrome | **measured**: rows 11, 13, sheet crops `11`, `12`; inactive and active title text read roughly only (see defects) |
| Control Center | **measured**: row 18, crop `13` |
| NC + banners | **measured**: row 17, banner 344 x 57 pt on screen at 2, 1.5, 1.25, crops `14`-`17` |
| Mission Control | **measured**: rows 4, 15, 16 |
| Dock, Menu bar, HUD, Sounds | **measured**: rows 1, 2, 8, 14 |
| Finder | **measured**: rows 5, 12, emoji / name text (crop `18`); the binary lags its QML (see above) |
| System Settings | **measured**: rows 6, 11, 10, Software Update and Hover Text text runs, crops `19`, `20` |
| Lock screen, Stage Manager | **carried** [24] |

## Sound, scaling and depth, measured

**Sound** (rows 8, 9, 14). Pill -> HUD 66.7 ms (Mac 66.7), pop out -> first HUD frame 20.6 (Mac 18.0), HUD hold 980 (Mac 1000),
screenshot sound 233 (Mac 222 / 247), player median 12.0. Two relations against the round 16 real-click data
(`MAC-ANSWERS-16.md` R16.1, R16.5 hand key): (1) the Dock's poof sound starts 362 ms after the click here and **-10 ms** against
the Dock's first moving frame; the Mac's real click puts it at 449 ms after the mouse up and **+29 ms** after the Dock starts to
move (the check's window -5..+10 is the older AX-press data). That is about 40 ms early against the real-click clip. (2) key ->
HUD at 90 % 431 ms against the hand 418 and the filmed 440-445 less its 22 ms path (418-423): 8-13 ms late. The drag-off by hand
(R16.1b: tile fades in place 230 ms, sound 63 ms after the release) has no live check. Stub sink only.

**Scaling**, three sessions (device px of the 2x shot resampled to the scale, best offset within 4 px, rms against the shot at
that scale):

| measure | scale 2 | scale 1.5 | scale 1.25 |
|---|---|---|---|
| banner, pt | **344 x 57** (Mac 344 x 57) | 344 x 56.7 | 344 x 56.8 |
| banner shadow, light over grey, at 4 8 14 22 30 40 pt | 10 8 6 3 2 0 (Mac 9 7 5 3 1 0) | 10 8 6 3 2 0 | 10 8 6 3 2 0 |
| Dock plate height, pt | 84.0 (5.0 above the edge) | 83.3 (5.3) | (content differs, not read) |
| Settings window, pt | 740 x 625 | 740 x 625 (1110 x 937.5 px) | 740 x 625 (925 x 781.25 px) |
| Settings top 215 pt against the resample | - | rms **6.6**, 0.87 % over 40 | rms **4.4**, 0.39 % |
| menu bar right (status items) against the resample | - | rms 8.4, 1.0 % | rms 7.3, 0.6 % |
| Control Center against the resample | - | rms 6.1, 0.24 % | rms 8.9, 1.1 % |
| 1 pt lines (`scale-lines.py`) | 5 of 5 | 4 of 4 on patterns | 4 of 4 on patterns |

(#24's Settings rms 2.80 / 5.23 was a different crop; not comparable.) By eye (`21`, `22`, `23`): no doubled rim, clipped glyph
or missing stroke. Open: Settings is placed at 270 pt = 337.5 device px at 1.25 (a fraction of a device pixel); the Finder header
line is not found at any scale; the Mac side is simulated (every Mac capture is the 2x backing; r16's SCK stills exist for the
Dock, menu, Finder and Settings at 1.5 only).

**Depth**: rows 2, 11, 13. Sheet shadow within 0.2-2.4 levels of the Mac's in both modes; the lights above the dim as the Mac's
(dark close grey (78,78,78) against (72,74,86)); plate under the icons within 1 pt in every frame.

## Regression sweep

| surface | checked | result |
|---|---|---|
| plugin glass | sources against the build time | no file newer; the build is today's 21:27, after r18's refit |
| Dock | resize, plate, Remove from Dock | rows 1, 2, 8, 14 |
| Finder | Group menu four clicks, Search press, emoji / name text | rows 5, 12; no regression |
| HUD | 8 key steps, timing | rows 3, 8 |
| Control Center | 12 hover / held / drag states, end glyph bounce | rows 7, 18 |
| banner | shadow at 2, 1.5, 1.25 | 10 8 6 3 2 0 at each |
| Settings | Software Update, Hover Text, About text runs, both modes | below |
| shell log | three sessions | clean |
| tests | shell, finder | 428 / 0, 40 / 0 |

## Per dimension

| dimension | j24 | j25 | change | reason |
|---|---|---|---|---|
| animation | 93.5 | **94.3** | +0.8 | HUD pop -> first frame 20.6 ms (Mac 18.0), pill -> HUD 66.7 = Mac, hold 980; MC pick +2 frames (Mac +2); Spaces bar rms 0.31 pt; Cmd-Tab 180 ms, one-frame step and cancel; menu blink 4 / 3 / 7 frames. Left: Apps grow .38 .62 .79 .93 against .28 .47 .62 .75 (150-167 ms against 215), Dock gap 233 ms (Mac 250), poof -10 ms (R16.1 real click: +29) |
| transition | 91.4 | **92.2** | +0.8 | Spaces bar expansion, Cmd-Tab release ease 0.248 s, Apps collapse 84 ms (Mac about 100), sheet veil timing |
| visual | 94.45 | **94.8** | +0.35 | Spotlight edges and layout, NC side lines, CC module levels, Cmd-Tab plate. Left: Files mode is a 520 x 490 list, no tab hint or scroll bar, two mode glyphs differ |
| behaviour | 94.2 | **94.5** | +0.3 | menu blink then fade then Dock removal in the Mac's frames; quick tap shows no panel; Spaces bar stays expanded |
| shape | 92.6 | **92.9** | +0.3 | Cmd-Tab panel / plate corners 33 / 28 (Mac 33 / 27), banner 344 x 57, Search disc 36 -> 39 on the Mac's dark number. Left: Spotlight Files shape (520 x 490 against 844 x 520) |
| colour | 95 | **95.0** | 0 | at target; light held track 220 against 216 |
| shadow | 94.9 | **95.0** | +0.1 | banner profile at three scales, sheet shadow max 2.4, Cmd-Tab / Spotlight rims |
| refraction | 94.55 | **95.0** | +0.45 | Spotlight rows 100 93 88 121 126 against 100 94 90 119 123 and the step test; NC / banner side lines within 1-4; CC lens rim 47-48 px, rows as the Mac's. Left: held light flat (Mac +10 round the pointer), rim over saturated blue |
| icon | 93.95 | **93.95** | 0 | tiles at their floors; Spotlight Actions / Clipboard glyphs are not the Mac's (crop `05`) |
| font | 95 | **95.0** | 0 | measured: "Notes.txt" 107 px wide in both; Settings text runs 7 / 7 (Software Update) and 7 / 7 (Hover Text) at -1..1 px; Cmd-Tab name stem 3.7 / 3.7 |
| rendering | 91.1 | **92.2** | +1.1 | plate within 1 pt, lines on patterns at 1.5 and 1.25 (Software Update fixed), Settings 740 x 625 at all scales. Left: Finder line not found, Settings origin at 337.5 px at 1.25 |
| sound | 92.0 | **92.6** | +0.6 | pill -> HUD = Mac, HUD pop gap 20.6 (was 32.0), hold 980; poof ~40 ms early against the real click, 90 % level 8-13 ms late |

Plain mean of the 12: 93.95 (j24 93.55).

## Per surface

| surface | weight | j24 | j25 | basis | reason |
|---|---|---|---|---|---|
| Menu bar + menus | 15 | 94.85 | **94.95** | measured | blink / fade in the Mac's frames, separators on patterns at 1.5, 1.25 |
| Dock | 14 | 94.95 | **95.0** | measured | plate within 1 pt (new metric), blink, Dock moves frame 22-23 (Mac 22). Left: gap 233 against 250 ms, poof timing |
| Window chrome | 14 | 93.35 | **93.9** | measured | lights within 0.7-3.6, inactive veil .169 / .191 / .141 (Mac .170 / .195 / .150), sheet shadow max 2.4, light close under sheet 1 level. Left: dark close under sheet (78,78,78) against (72,74,86), light active title 88 against 76 (Mac conflict), TextEdit-style alert card not on screen |
| Finder | 13 | 94.15 | **94.3** | measured (stale binary) | Search disc matches the Mac's dark stills, Group menu, emoji ink within 2 px, list text widths identical. Left: light inspector +6 [24], header line not found at 1.5 |
| System Settings | 10 | 95.5 | **95.6** | measured | Software Update separator on the pattern at both scales, text runs 7 / 7, style tiles at floors |
| Control Center | 6 | 94.4 | **94.9** | measured | hover / held module levels 57 / 77, 59 / 79 (Mac 57 / 77, 59 / 78), lens rows 62..99, fill rms 0.4-1.5 |
| NC + banners | 6 | 92.4 | **93.9** | measured | dark side lines at the Mac's (card 44 / 44, 70 / 70, banner 50 / 70), 8 r18 cases within 1-4, 344 x 57 exact |
| Spotlight | 6 | 91.3 | **93.2** | measured | rims within 2 levels of r17 on every row and the step; idle, mode list, typed layout as the Mac's. Left: see defects |
| Mission Control | 4 | 91.75 | **93.0** | measured | pick +2 frames, Spaces bar rms 0.31 pt, windows 39.5 pt under it |
| Sounds | 4 | 92.0 | **92.6** | measured | as the dimension |
| HUD | 3 | 92.2 | **93.4** | measured | pop gap 20.6, pill -> HUD 66.7, hold 980; key -> HUD 96.9 against hand 84 |
| Cmd-Tab | 3 | 91 | **94.2** | measured | 12 of 12 script cases; panel, plate, name within 1 px |
| Apps | 2 | 86 | **90.5** | measured | chips, separator, typed completion, collapse on the Mac's numbers. Left: grow faster, 2 recents against 6, Files-like layout checks only |
| Lock screen | 5 | 91.5 | 91.5 | carried | |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried | |

Weighted: 13 surfaces 9428.95 / 100 = **94.29**. With Stage Manager (170): 9598.95 / 102 = 94.11. With the lock screen:
9886.45 / 105 = 94.15.

## Settings destinations (carried tail of #24, re-read here)

Mac stills `settings-r15/software-update-idle-*`, `settings-r12/acc-hover-text-00-*`, `settings-r15/about-00-*`, window 740 x 625
at 2x, ours the same window from the scale 2 session (ink row runs in the content column, session environment).

| destination | runs matched | row offset, px | rms over the content column | result |
|---|---|---|---|---|
| Software Update dark / light | 7 of 7 / 7 of 7 | -3..0 / -3..0 | 9.4 / 9.2 (1.3 % of px over 40) | match (`19`, `20`) |
| Accessibility > Hover Text dark / light | 6 of 7 / 7 of 7 | -4..1 | 9.1 / 8.2 | match |
| General > About dark / light | 3 of 10 / 4 of 11 | 0..2 | not read | this machine's rows (Ubuntu, no serial) |

The other seven destinations of #24 were not re-run (unchanged code).

## Top defects by points

| # | defect | numbers | file | cost (total points) |
|---|---|---|---|---|
| 1 | Spotlight Files mode | ours a **520 x 490 list** ("Recents", "No Recent Files") against the Mac's **844 x 520 grid** with five filter chips and 7 columns (`06`) | `shell/modules/Spotlight.qml` and the apps grid (`lib/appsgrid.js`) | 0.04 |
| 2 | Spotlight typed row and mode glyphs | no "Search Calculator" + `tab` key cap, no results scroll bar, the top hit's bar icon is larger and lighter; Actions shows a bolt (Mac layered squares), Clipboard a filled sheet (Mac two outline documents); caret has no halo (`04`, `05`, `07`) | `shell/modules/Spotlight.qml`, `themes/icons` | 0.03 |
| 3 | Dock removal sound against the real click | poof sound **362 ms** after the click, **-10 ms** against the Dock's first moving frame; Mac R16.1: 449 ms after the up, **+29 ms**; the check's window (-5..+10) is the AX-press data | `shell/scripts/sound.sh`, `shell/modules/Dock.qml` | 0.025 |
| 4 | Apps grow too fast, flaky check | level .38 .62 .79 .93 .97 (settled 150-167 ms) against .28 .47 .62 .75 .84 .89 .92 .98 (215 ms); close 84 ms against about 100; hover / press / scroll not on the Mac's clips | `shell/modules/AppsPanel.qml` | 0.02 |
| 5 | Window chrome: dark close under a sheet, titles | close **(78,78,78)** against (72,74,86); light active title 88 against 76 (two Mac values); inactive bottom veil .141 against .150 | `plugin/src/Titlebar.cpp`, `LightPress.cpp` | 0.02 |

Also open: NC dark card over blue straight side blue channel 95 against 86 and the Mac's top line about 1.4 x ours [r18
notes]; Finder light inspector +6 [24, not re-measured]; the Finder QML newer than the binary (4 files); CC held light flat
(Mac up to +10 round the pointer) and rim line over blue 52 against 77 [r18 notes]; light held track 220 against 216; HUD key ->
first frame 96.9 against the hand 84 and 90 % 8-13 ms late; Dock gap 233 against 250 ms; Settings origin at 337.5 px at 1.25;
`apps-view.py` "panel grows" and `cc-lens-fill.py` r18 first-run flakes (the check, not the shell).

## Check scripts

`cc-lens-fill.py` r18 cases depend on the stub sink's volume (a run after other checks found no knob); `apps-view.py` open
reads one dropped frame as a jump (2 of 4 runs fail); `sound-timing.py` and `lights-colour.py` need a clean desktop / exactly
the right windows (`sound-timing.py` says nothing about it); `player-latency.py` wants an absolute scratch dir (a relative one
makes it write `/<dir>`, which fails on permissions, harmlessly); started from a plain shell, Finder and Settings lack the
session's font environment (see "What was judged").

## What stands between 94.3 and 95

The gap is 0.71 points: 71 of the weight-points still missing, spread over every surface but the Dock and Settings, which are at
95. Gains are in total points (surface weight / 100 x its score gap).

| # | item | gain | availability |
|---|---|---|---|
| 1 | Window chrome 93.9 -> 95: dark close under a sheet (78,78,78 -> 72,74,86), inactive veil bottom .141 -> .150; light active title 88 against 76 | up to 0.15 (0.03 known) | **dark close and veil: fixable from the repo data** (R16.4, R17.4); the title conflict **needs a Mac** |
| 2 | Spotlight 93.2 -> 95: Files grid and chips, tab hint and key cap, scroll bar, caret halo, Actions / Clipboard glyphs | up to 0.11 | **fixable from the repo data** (the r17 stills show the grid and both glyphs at 2x; the exact SF symbols **need a Mac dump**) |
| 3 | Sounds 92.6 -> 95: poof timing to the R16.1 real-click numbers (+29 ms after the Dock moves), drag-off fade 230 ms with sound at +63 ms, 90 % level 8-13 ms early, real PipeWire path | up to 0.10 (0.04 known) | poof and drag-off: **fixable from the repo data**; hardware key and a real device **need a Mac (not available)** |
| 4 | Finder 94.3 -> 95: light inspector -6, Finder header line at 1.5, rebuild the binary (not done here) | up to 0.09 (0.05 known) | **fixable from the repo data**; the 1 pt line at 1.5 needs a look at the Mac's panel pixels (**needs a Mac**) |
| 5 | Apps 90.5 -> 95: grow curve, recents, hover / press / scroll / Dock open | up to 0.09 | grow curve **fixable from the repo data**; hover, press, scroll and Dock open **need a Mac (A1-A3)** |
| 6 | Mission Control 93.0 -> 95: two Desktops, light mode, full-screen Space, the Spaces' 18 pt gap | up to 0.08 | **needs a Mac (not available)** |
| 7 | NC + banners 93.9 -> 95: top line x1.4, blue straight side, alert and menu rims over white and blue | up to 0.07 (0.03 known) | the first two **fixable from the repo data** (r18 stills); alert and menu **need a Mac** |
| 8 | HUD 93.4 -> 95: key -> first frame -13 ms, 90 % level, hide | up to 0.05 | **fixable from the repo data** (hand clip), up to the 22 ms capture path |
| 9 | Cmd-Tab 94.2 -> 95: light name level 20 / 17, 8-10 app widths, badges | up to 0.02 | 8-10 apps **fixable** (linear in the pitch); badges **need a Mac** |
| 10 | Control Center, Menu bar: held light round the pointer, rim over saturated blue | up to 0.01 | **needs a Mac** |
| 11 | Lock screen 91.5 and Stage Manager 85 (not measured) | lock screen up to 0.17 of a 105-weight total, Stage Manager 0.20 of a 102-weight one | **needs a Mac**: no new stills |

## Reachable ceiling

About **94.6** from the repo data (items 1-5 and 7-8 known parts, about 0.30). About **94.9** only if the missing Mac captures (the
titles, Files / Apps interaction, Mission Control variants, lock screen, Stage Manager) confirm what is built. 95 is not
reachable from what is in the repo: roughly 0.35 of the gap sits behind captures that need the Mac, which is not available.

## The twelve areas of the 95 goal

| area | scored as | j24 | j25 | change | reason / what holds it under 95 |
|---|---|---|---|---|---|
| animation | animation | 93.5 | **94.3** | +0.8 | MC pick +2 (Mac +2), Spaces bar 0.31 pt, HUD gap 20.6 ms (Mac 18), Cmd-Tab one frame; Apps grow x1.3 too fast, Dock gap 233 / 250 ms, poof 40 ms early |
| liquid glass | refraction + visual | 94.5 | **94.9** | +0.4 | Spotlight rims, NC lines, CC lens rows within the Mac's; Files mode shape, mode glyphs, held light flat |
| glass refraction | refraction | 94.55 | **95.0** | +0.45 | Spotlight rows 100 93 88 / Mac 100 94 90 and the step; NC side lines 44 / 44, 70 / 70; CC rim; held light round the pointer and rim over blue open |
| shadows | shadow | 94.9 | **95.0** | +0.1 | banner 10 8 6 3 2 0 at 2, 1.5, 1.25 (Mac 9 7 5 3 1 0 at 2); sheet shadow max 2.4 |
| depth | shadow + rendering | 93.0 | **93.6** | +0.6 | sheet over the dim, lights above it, plate within 1 pt; dark close under a sheet 8 levels off |
| opacity | colour | 95 | **95.0** | 0 | at target; light held track 220 / 216 |
| blur | refraction + visual | 94.05 | **94.4** | +0.35 | Spotlight and Cmd-Tab backdrop rows match; the light inspector +6 is not re-measured |
| sound | sound | 92.0 | **92.6** | +0.6 | pill -> HUD = Mac, pop gap 20.6, hold 980; poof ~40 ms early against R16.1, no real device |
| icon | icon | 93.95 | **93.95** | 0 | tiles at their floors; Spotlight Actions / Clipboard glyphs not the Mac's |
| emoji | (direct) | 95 | **95.0** | 0 | measured now: 😀 +90..+120 from "R" (Mac +90..+118), 👍🏽 +128..+156 (+128..+156), 🇮🇩 +166..+194 (+166..+194) |
| font | font | 95 | **95.0** | 0 | measured: "Notes.txt" 107 px in both, Settings text runs 7 / 7 on two destinations, Cmd-Tab name stem 3.7 / 3.7 |
| scaling | (direct) | 92.5 | **93.3** | +0.8 | Settings separator on the pattern at 1.5 and 1.25, banner 344 x 57 pt at all three scales with one shadow, Settings 740 x 625; origin at 337.5 px at 1.25, Finder line not found, Mac panel pixels only for 1.5 |

## Crops (`reference/judge-95-25/`)

`01` / `02-cmd-tab-{light,dark}-mac-above-ours-below` (the script's strips), `03-spotlight-idle-light`, `04-spotlight-typed-dark`,
`05-spotlight-modelist-dark`, `06-spotlight-files-light`, `07-spotlight-actions-dark`, `08-apps-rest-dark`, `09-apps-rest-light`,
`10-apps-typed-cal-dark` (each `-mac-left-ours-right`, 1 px per device px: Mac crop of the r17 still, ours cut to the same window
rect + 30 pt, bar tops aligned), `11` / `12-settings-clock-options-sheet-{light,dark}`, `13-cc-sound-idle-held-dark-light` (rows:
dark idle, dark held, light idle, light held; their fill ends are not aligned), `14-banner-dark-over-white`,
`15-banner-light-over-blue`, `16-nc-card-dark-over-white`, `17-nc-card-light-over-blue`, `18-emoji-finder-list` (Mac above, ours
below), `19` / `20-settings-software-update-{light,dark}` (half size), `21-scale-1.5-settings-resampled-2x-left-ours-right` (the
Finder window in the right half is the scratch session's own), `22-scale-1.25-control-center-ours`,
`23-scale-1.5-banner-ours`. The scale crops are device pixels.
