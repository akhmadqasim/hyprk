# hyprk independent judge #18, branch mac-27.2.1-rea-2026-11-14 (1db54be) + working tree (2026-11-14, 16:08-16:25 WITA, measured live)

Delta judgement against judge #17 (`JUDGE-95-17.md`, 92.52). Method and weights from `JUDGE-95-7.md` as carried by #17:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[18 live]** measured
on screen here; **[18 static]** checked in the code only; **[17]** carried from judge #17.

## What was judged

- Since judge #17: the alert glass / content frame sync (`AlertDialog.qml`, `MOTION-AUDIT.md` follow-up), the plugin's
  own popup fade for `popup_classes` (`plugin/src/PopupGlass.cpp`, `plugin/build/libliquidglass.so` 15:49, after the
  source at 15:47; the session's Hyprland mapped exactly that file), glass rounds 5-6 (`GLASS-HIG.md` 10-11: preview
  stroke rim, switch foreground decode, CC held-lens ramp and `ringshadow.frag`), the NC photo skip (`nc.js`).
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_SOUND_LOG=... scripts/smoke.sh`
  (2560 x 1664, scale 2; dark, light, dark, light; scale 1.6 with `hyprctl eval hl.monitor`, then back to 2), state
  `$XDG_RUNTIME_DIR/hk-j` (repo `state/` copied, dark, Dock 64 / 96), scratch HOME / XDG_CACHE_HOME / TMPDIR, the
  script's private bus. Stub env read from `/proc/<qs pid>/environ` (HOME scratch, `HYPRK_AUDIO_STUB=1`,
  `HYPRK_STATUS_STUB=1`, `HYPRK_MUTE=1`). PipeWire volume 0.46 before and after (read only). Scratch HOME: judge #17's
  `Documents` / `Downloads` (incl. `broken.png`); here `find` lists `Documents/broken.png` first, so the NC skip path ran.
  From the CC test on, `wallpaper.json` pointed at the flat grey 127 image. Tools: `vptr`, `mcap` (21 captures,
  `long_intervals` 0 in all), `mcap.py compare`, judge #17's scratch scripts (`pv.py`, `ripple.py`, `cc.py`) unchanged,
  two new ones (switch: one rule for lens / rim / fringe on both captures; alert: glass rims vs content per frame),
  each also run on judge #17's own captures so both judges' numbers sit on one method. Stopped with `smoke.sh --stop`,
  bus killed, state dir and the session's volkey dir removed.
- Mac data: as judge #17 (`controls/switch-press-strip-light.png`, `settings/appearance/liquidglass-0-mid-1-{dark,light}.png`,
  `panels/cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png` frame 3, the series quoted in `MOTION-AUDIT.md`).
- Not measured: Spotlight close at 1.6, sounds (no change claimed), Mission Control, Cmd-Tab, HUD (same one-frame-lag
  shape per the developer, not filmed), Apps, lock screen, Stage Manager. Crops in `reference/judge-95-18/` (01-12).
- Slip on my side: two hold captures were written to the repo root first (relative path after the env's `cd`); moved
  to scratch at once, nothing else touched. A Dock press launched the session's TextEdit (scratch HOME, wayland-1);
  closed by its pid.

## Overall: **92.7** (13 surfaces 92.66, with the lock screen 92.61, with Stage Manager folded in at weight 2: 92.51)

Judge #17: 92.52. All six claims hold on screen. The two defects #17 found are gone: the alert's glass and content now
scale in the same frame (0 frames with content past the glass in 3 runs, #17's captures show 3 by the same rule), and
the Finder menu close is one clean CA-default fade (rms .003-.004 where #17's captures read .017-.030). Both preview
round ends are back at the Mac (light 136 / 139, dark 102 / 105) and the held switch's middle cyan line is gone (R - B
-2, #17's capture -35). What holds it: the CC held lens got the Mac's ramp and shadow but lost level (fill mean 212.7
vs Mac 224.0; #17 220.8), and a newly measured defect: Settings' pop-up button menus close with a linear 200 ms Qt fade
(rms .046 against the CA-default series), untouched by the plugin fix.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1 | alert pop: glass and content agree in every frame (0 past; ratio 1.000 +- .012; peak 1.169 at 265 ms) | trash alert over grey 127, dark, 3 runs (`08`). Per frame: glass top / bottom rim on the centre column, right rim on the middle row, content = blue pixels (folder + default button). **0 of 35-36 frames** (from scale .59, where the rims are measurable) with a blue pixel past the glass, 3 of 3 runs; #17's captures by the same rule: 3 frames (234-265 ms, 233-277 px each), glass one frame behind (glass .592 / content .729, .725 / .872, .871 / 1.032). Now glass height / content height **.992-1.000** in every frame; peak glass **1.172 at 261 / 265 / 266 ms**. Body width (diff > 30) / final: .034 .050 .073 .103 .153 .215 .291 .379 .483 .598 .728 .870 1.027 **1.169** 1.142 1.115 1.088 1.069 1.050 1.034 1.023 1.011 1.004 1; vs the Mac outline rms **.0061-.0072** (#17's capture .0116); 13 rising frames to the peak (Mac 12, #17 14) | **confirmed** |
| 2 | Finder context menu close: one fade, CA default 236 ms, rms .0035-.0071 | 3 runs, closed by a click outside, judge #17's region and Mac series (`menu1-3`, `--sub 10,10,190,215`): **rms .0044 .0032 .0030** at 26-29 ms shift; the same rule on #17's captures: .030 .025 .017. Interior .00 .05 .16 .31 .46 .60 .70 .79 .86 .91 .94 .96 .99 1 (Mac .14 .29 .45 .58 .70 ...). Frames at 16 / 31 / 46 / 70 % (`07`): text sharp, no blur layer. Group-by pull-down, 1 run: rms .0043 | **confirmed** (better than claimed) |
| 3 | preview: light top 211, end 136, face 243; dark top 172, end 102, face 163 | `grim -g "715,238 265x50"` vs the middle panel (`03`), judge #17's `pv.py`. Light: top line col 69 / 79 **211 / 210** (Mac 211 / 211), face **243** (241), round end **136** 244 240 (Mac 139 238 236), right end **123** (128), ripples 1.15 dips/row (1.28, corr 0.99). Dark (col 69 from the line pixel): **232 172** 177 172 170 168 (Mac 232 173 175 167 166 165), col 79 232 172 (232 174), face **163** (164), round end **102 128 149 158** (105 127 145 151), right end **99** (110), ripples 2.14 (2.03, corr 0.92) | **confirmed** to the level |
| 4 | held switch: no cyan middle line (R - B -2), fringes 28 %, interior flat, shadow -14, outer rim 205 | light, "Animate opening applications" held 1 s, pressed at the switch's lower right so the pointer clears the middle (`01`). One rule on both captures: under the middle 40 % of the top rim, min R - B in the 4 px under the line: **median -2, 0 of 20 columns under -15**; #17's capture: median -35, 20 of 20. Cyan columns (R - B < -15 over >= 2 px in 7 px): **15 / 54 = 28 %**, at both ends only (Mac 25-35 % per #17). Middle column: line **205 / 194**, bottom **194 / 203** (Mac 196 / 195). Track inside the lens B std **2.6** (Mac 4.2). Under the lens: 233 at 2 px below the rim, same as #17 (-14) | **confirmed** (outer rim pixel +9 as stated, explained as sub-pixel, not verified) |
| 5 | CC Sound held (dark): fill 233 / 197, mean 214.4, shadow 98 95 91 88 87 | grey 127, knob held, pointer dragged straight up off the lens so it is not in the crop (`04`). Fill rows per column through the lens: **230 235 232 229 226 223 221 218 216 214 213 212 211 210 210 209 209 209 209 206 196 172** (Mac 246 245 241 238 235 231 229 226 224 221 220 219 218 217 217 216 216 216 216 211 192). Shadow every 2 px from the bottom rim: **98 95 91 88 87 88 92** (Mac 99 95 91 86 85 85 87 92). Judge #17's `cc.py` mean (fill rows, inside the box): **212.7** (Mac 224.0, #17 220.8); fill left of the lens 247 (Mac 254, #17 253) | **confirmed** for the ramp shape and the shadow; the level moved away from the Mac (-11 vs -3 at #17) |
| 6 | NC photo widget skips an undecodable first candidate | first `find` candidate `Documents/broken.png` (data, not a PNG): the widget shows `Documents/good.png` (orange 200,80,40, title "Documents") (`11`), one decode warning in the log for broken.png, no second. `shell/tests/run.mjs`: **404 passed, 0 failed** (incl. the photo-skip test) | **confirmed** live |

## Regression sweep

| surface | checked | result |
|---|---|---|
| alerts | trash alert show x3, Cancel x3 | pop as above; dismiss alpha rms **.0005-.0050** (#17's captures .0014-.0032 by this rule), same .31 first frame |
| Finder menus | context x3, group-by pull-down x1 | single fade, rms .003-.004; the group-by items all draw grey (disabled look): not compared with a Mac, not touched this round |
| Settings menus | Desktop & Dock "Dock position" pop-up, close x1 (`12`) | **linear 200 ms Qt fade** (`ui/HyprK/Popup.qml` exit), steps .08 per frame, rms **.046** against the CA-default series; file not changed this round, first measured here |
| popovers | emoji picker close x3 | rms .0138-.0147 (#17 .0141-.0144) |
| shell menus | Apple menu close x3 | rms .0053-.0077 (`--sub 10,10,240,200`) |
| toolbar | Settings back / forward, dark (`05`) | strip 31 / 39 / 39, capsule 60 / 67 / 85, disc 85 / 103, divider gone on hover / press, kept on disabled hover: identical to #17 |
| Settings controls | held switch light and dark (`02`), Size slider held dark (`06`) | fine; dark held switch: track inside the lens ends shorter with a green end and the rim fringes are gone (no Mac dark reference) |
| CC | dark held lens; dark and light open | ramp / shadow as claim 5; light and dark CC look alike over grey 127 (as #17) |
| NC | dark, light | fine; widgets keep the dark calendar / clock in light mode over grey (as #17) |
| Dock | magnification hover light, 1.6 | fine; 1.6 icon pitch about 110 px, whole |
| Spotlight | light | field is dark glass in light mode, here over a white window (as #17, not compared with a Mac) |
| scale 1.6 | Edit menu, Settings Appearance, Dock (`09`, `10`) | Edit separators rows 148-149, 320-321, 376-377, 432-433 (2 px each, same as #17) |
| shell log | whole session (35 lines) | no binding loop, TypeError or pixel-size warning; NC broken.png x1 (the skip), StackArt broken.png, qt.svg x7, text-input x4, portal x3, libpng iCCP from my grey test image |

## Per dimension

| dimension | j17 | j18 | change | reason |
|---|---|---|---|---|
| animation | 91.5 | **91.75** | +0.25 | [18 live] alert glass and content in the same frame, pop rms .006-.007 (was .012) |
| transition | 90.25 | **90.4** | +0.15 | Finder menu close .003-.004 (was .017-.030); minus Settings pop-up menus linear 200 ms (.046), first measured |
| visual | 93.75 | 93.75 | 0 | nothing new |
| behaviour | 93.5 | 93.5 | 0 | NC skip counted under NC |
| shape | 92.25 | 92.25 | 0 | CC lens box unchanged (46 x 40 vs 47 x 40) |
| colour | 95 | 95 | 0 | [17] |
| shadow | 94.25 | **94.5** | +0.25 | CC lens shadow ramp within 1-3 of the Mac (was flat 87) |
| refraction | 93.5 | **93.75** | +0.25 | preview ends back at the Mac (3-11 off), switch middle cyan line gone; minus the CC fill level (-11, was -3) |
| icon | 93.5 | 93.5 | 0 | [17] |
| font | 95 | 95 | 0 | [17] |
| rendering | 90.25 | **90.5** | +0.25 | content no longer outside its glass during the pop |
| sound | 90 | 90 | 0 | no change claimed |

Plain mean of the 12: 92.83 (j17 92.73).

## Per surface

| surface | weight | j17 | j18 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.25 | 94.25 | Apple menu close .005-.008, 1.6 separators unchanged |
| Dock | 14 | 94.25 | 94.25 | unchanged |
| Window chrome | 14 | 92.25 | **92.5** | alert content inside its glass in every frame |
| Finder | 13 | 92 | **92.5** | context and pull-down menu close: one CA-default fade, rms .003-.004 |
| System Settings | 10 | 94.5 | **94.75** | preview ends and switch middle line fixed; minus pop-up button menu close (linear, .046) |
| Control Center | 6 | 93.5 | 93.5 | ramp and shadow gained, fill level lost (212.7 vs 224.0) |
| NC + banners | 6 | 91.5 | **91.75** | photo skip verified live with a broken first candidate |
| Spotlight | 6 | 89.5 | 89.5 | [17] |
| Mission Control | 4 | 90.5 | 90.5 | [17] |
| Sounds | 4 | 90.25 | 90.25 | [17] |
| HUD | 3 | 90.5 | 90.5 | [17] |
| Cmd-Tab | 3 | 91 | 91 | [17] |
| Apps | 2 | 86 | 86 | [17] |
| Lock screen | 5 | 91.5 | 91.5 | [17] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [17] |

Weighted: 13 surfaces 9266.25 / 100 = 92.66. With the lock screen 9723.75 / 105 = 92.61. With Stage Manager
9436.25 / 102 = 92.51.

## Regressions

- None caused by this round's files that I could see.
- CC held lens level (not a new defect, a move away): fill mean 220.8 -> **212.7** (Mac 224.0), fill left of the lens
  253 -> 247 (Mac 254), while the ramp and shadow now match.
- First measured, older code: Settings pop-up button menus (`ui/HyprK/Popup.qml`, linear 200 ms) do not get the
  plugin's CA-default popup fade the Finder menus now have.

Defects still open: Settings pop-up menu close; CC fill level; preview dark right end 99 (Mac 110) and light end's
inner ramp 244 240 (238 236); switch outer rim pixel 205 (196); alert rise 1 frame longer than the Mac's; the fan's
tile chevron (#17); Spotlight dark field in light mode (not compared).

## The next 10 changes, by gain

Repo only:

1. Settings pop-up button menus: the CA-default 236 ms close the Finder menus have (now linear 200 ms, rms .046) (+0.03).
2. CC held lens: lift the fill level to the Mac's (212.7 -> 224, left of the lens 247 -> 254) keeping the ramp (+0.02).
3. HUD: the same glass-follows-scale fix as the alert (`HudWindow.qml`, same shape per the developer), then film it (+0.01).
4. Preview: dark right end 99 -> 110, light end's inner ramp 244 240 -> 238 236 (+0.01).
5. Finder group-by pull-down: items drawn disabled; check against the menu's enabled state (+0.01, belum dicek vs Mac).

Needs the Mac:

6. Alert at 60-120 fps over grey (ours 1 rising frame longer; shadow scaling) (+0.02).
7. Spotlight in light mode over a white window (ours is dark glass) (+0.03).
8. A scaled mode capture ("More Space"): menu, Settings card, Dock, Spotlight close (+0.05).
9. A dark held switch strip (ours changed in dark this round with nothing to compare) (+0.01).
10. Settings pop-up button menu close at 60 fps, to confirm it is the same curve as the context menu (+0.01).

## Reachable ceiling

About 92.75 with the repo's data (items 1-5). About 92.9-93.1 with the Mac captures. 95 is not reachable on this stack
for judge #7's reasons (about 3 points).

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91.75 | MC 4-window exit, stack fan / grid never filmed, alert rise 1 frame long | Mac 60-120 fps: MC 4 windows, stack, alert over grey |
| liquid glass | refraction + visual | 93.75 | CC fill level, no glass in third-party windows, Spotlight light field | repo 2; Mac Spotlight light |
| glass refraction | refraction | 93.75 | CC fill -11; preview dark right end -11; switch outer rim +9 | repo 2, 4 |
| shadows | shadow | 94.5 | switch lens shadow peak placed high; banner and module shadows never compared | Mac stills of banner and module shadows |
| depth | shadow + rendering | 93.75 | alert content now inside its glass; HUD not filmed | repo 3 |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93.25 | ripples at the Mac's; scroll pocket (j14) | Mac Finder scrolled under the toolbar |
| sound | sound | 90 | output latency; Empty Trash / poof not fired | Mac audio + screen capture |
| icon | icon | 93.5 | rtf / generic / app documents | Mac renders of document pages |
| emoji | (direct) | 94.5 | emoji in text never compared | Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 91 | lines and Dock whole-pixel at 1.6 (re-measured); no Mac scaled-mode capture | Mac "More Space" capture |

## Crops (`reference/judge-95-18/`)

`01-held-switch-light-mac-top-ours-bottom.png` (ours scaled 1.45 to the strip), `02-held-switch-dark-rest-held-j17held-
ours.png` (rest, held now, held at #17), `03-preview-buttons-{light,dark}-mac-top-ours-bottom.png`,
`04-cc-sound-held-lens-dark-grey127-mac-ours-j17.png`, `05-settings-back-forward-rest-hover-press-disabledhover-dark-
ours-left-j17-right.png`, `06-settings-size-slider-held-dark-ours.png`, `07-finder-menu-close-frames-0-16-31-46-70pct-
ours.png`, `08-alert-pop-frames-183-266ms-ours.png`, `09-edit-menu-scale1.6-ours.png`, `10-settings-appearance-scale1.6-
ours-half.png`, `11-nc-photo-widget-broken-first-ours.png`, `12-settings-popup-close-frames-linear-ours.png`.
