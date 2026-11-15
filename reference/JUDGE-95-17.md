# hyprk independent judge #17, branch mac-27.2.1-rea-2026-11-14 (1db54be) + working tree (2026-11-14, 15:19-15:36 WITA, measured live)

Delta judgement against judge #16 (`JUDGE-95-16.md`, 92.28). Method and weights from `JUDGE-95-7.md`: 12 dimensions,
13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[17 live]** measured on screen
here; **[17 static]** checked in the code only; **[16]** carried from judge #16.

## What was judged

- Since judge #16: glass rounds 3-4 and the CC slider on the stub sink (`GLASS-HIG.md` 7-9), the toolbar hover wash /
  divider / disabled half (`TOOLBAR-REA-27.2.1.md` "Hover wash"), the motion audit (`MOTION-AUDIT.md`), scale 1.6
  (`SCALING-AUDIT.md`), the sound log with gains (`SOUND-REA-27.2.1.md` 6), NC photo skip and the StackArt label font.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_SOUND_LOG=... scripts/smoke.sh`
  (2560 x 1664, scale 2; dark, light, dark; scale 1.6 with `hyprctl eval hl.monitor`, autoreload off, then back to 2),
  state `$XDG_RUNTIME_DIR/hk-j` (`dock.json` magnification on 64 / 96, `appearance.json` dark), scratch HOME /
  XDG_CACHE_HOME / TMPDIR, the script's private bus. The stub env was read from `/proc/<qs pid>/environ` (HOME scratch,
  `HYPRK_AUDIO_STUB=1`, `HYPRK_STATUS_STUB=1`, `HYPRK_MUTE=1`, `HYPRK_SOUND_LOG`). The machine's PipeWire volume read
  0.46 before and after every CC / volume test (read only, `wpctl get-volume`). `Downloads` / `Documents` as judge #16
  (13 / 5 throwaway files incl. `broken.png`). From the CC test on: `wallpaper.json` in the scratch state pointed at a
  flat grey 127 image (as the Mac's CC picture). Tools: `vptr`, `mcap` (15 captures, `long_intervals` 0 in all),
  `mcap.py compare`, `grim`, ImageMagick, numpy. Stopped with `smoke.sh --stop`, bus killed, state dir and the
  session's volkey dir removed.
- Mac data: `controls/switch-press-strip-light.png` (last frame), `settings/appearance/liquidglass-0-mid-1-{dark,light}.png`,
  `settings/toolbar-backforward-rest-hover-press-dark.png`, `panels/cc-sound-slider-rest-hover-drag-overdrag-dark-
  grey127.png` (frame 3 crop), the series quoted in `MOTION-AUDIT.md` (menu probe alpha, video remaining / outline).
- Not measured: Spotlight's close blur at 1.6 (code only), the NC photo skip path (the first candidate decodes, see 6),
  Empty Trash / screenshot / poof sounds, Mission Control, Cmd-Tab, HUD, Apps, lock screen, Stage Manager.
  Crops in `reference/judge-95-17/` (01-13).

## Overall: **92.5** (13 surfaces 92.52, with the lock screen 92.47, with Stage Manager folded in at weight 2: 92.38)

Judge #16: 92.28. The gain is spread: the held switch now matches the Mac strip in interior, fringe placement, rim
and lens shadow; the CC held lens is verified on the stub sink; the toolbar hover wash and divider match the Mac
panel within 1-4 levels; the alert pop matches the Mac outline series frame for frame; menu / popover closes follow
CA's default curve; 1 pt lines are whole pixels at 1.6; the fan's pixel-size warnings are gone. What holds it: both
preview round ends moved away from the Mac (light 171 vs 139, was 141; dark 86 vs 105, was 107), the alert's content
overhangs its glass during the pop (new, seen in 3 of 3 runs), the Finder context menu close is 1.2-2x the claimed rms.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | held switch interior flat, same colour as outside (B std ~4.2, Mac 4.8) | light `01`, "Animate opening applications" held 1 s, `grim -g "930,445 70x36"`; track core (middle half of its rows): **inside (0,114,238) B std 1.4, outside (0,114,243)**; Mac inside (11,92,203) B std 4.2, outside (13,96,208). Inside - outside B: ours -5, Mac -5. Track inside / outside height 25 / 33 = 0.76 (Mac 0.73) | **confirmed** |
| 1b | cyan fringe only near the ends (24 % of top columns, Mac 24 %) | R - B < -15 over >= 2 px in the 7 px under the top rim: ours **20-25 of 64 columns (31-39 %)**, runs at both ends only (47-50, 89-110); Mac 26-36 of 102 (25-35 %), ends only. Middle columns: ours a 1 px R - B -35 line along the whole top, Mac 0 | **confirmed** for placement (share 4-6 points over the Mac's); the 1 px cyan line in the middle remains |
| 1c | lens shadow -13 (Mac -14), rim 208/197 (Mac 196/195) | shadow ours 247 -> **233 (-14)** right under the rim, Mac 249-252 -> 238 (-11..-14) peaking 4-6 px lower. Rim middle column: ours **208 / 197** top, 197 / 208 bottom; Mac 223 / 194 (x 111), 195 / 195 (x 90) | **confirmed** (outer rim pixel +12 over the Mac's 195; shadow peak sits higher) |
| 1d | preview light top rim 214/217 (Mac 211/210), face 243 (241); dark face 162 (164); misses: ends dark 86 (105), light 170 (139) | `grim -g "715,238 265x50"` vs the middle panel (`03`). Light: top rim at 60 / 70 px **215 / 217** (Mac 211 / 211), face 8 px under **243** (241), end **171** (139), ripples **1.20** dips/row (Mac 1.28, corr 0.94). Dark: top rim 169 / 170 (Mac 173 / 174), face **162-163** (164), end **86** then 158 (Mac 105 127 145 151), ripples 1.97 (2.03, corr 0.89) | **confirmed** as stated, misses included. Both ends are now further from the Mac than at judge #16 (light 141 -> 171, dark 107 -> 86) |
| 1e | CC slider held lens: face 22x18, lens 44-46 x 38 (Mac 44x38), fill 222.9 (Mac 224), module lifts 2.25 pt (Mac 2.75) | dark, grey 127, knob held 0.8 s at (1100, 468) pt on the stub sink (`04`). Rim centres on the middle row / column: ours **45 x 38**, Mac 46 x 38 (my method; outer box 46 x 40 vs 47 x 40). Fill inside the lens, mean of the fill rows to the fill end: ours **220.8** flat (223 until the end column), Mac **224.0** ramping 246 -> 216. Fill rows 8 / 8 both, track right 129 / 127. Shadow: ours flat 87, Mac ramps to 85 4-5 pt below. Module rim-to-rim at y 900 px: rest 585 -> held **589 px (+2 pt)** | **confirmed** (size within 1 px; fill within 1-3 but flat where the Mac ramps; lift +2 pt vs Mac +2.75) |
| 2 | toolbar: dark hover washes strip 31 -> 39, capsule 61 -> 68, press capsule ~85 (Mac 84), disc ~103-104 (Mac 107.5), divider hidden on hover / press in Finder and Settings, disabled half lights nothing | row through the capsule, dark (`05`, `06`). **Settings**: strip 31 / 39 / 39, capsule 60 / 67 / 85, disc 85 hover, **103** press, divider 113 at rest, gone on hover and press, disabled Forward hovered: wash only, no disc, divider kept. **Finder**: strip 31 / 39 / 39, capsule 62 / 69 / **87**, disc 87 / **104**, same divider / disabled behaviour. Mac panel (row 52): strip 31 / 39 / 39, capsule 60-61 / 68 / 84-85, disc 87-88 / 107-108 | **confirmed** (disc 3-4.5 under the Mac, Finder press +3) |
| 3a | popover close: CA default curve 128 ms | emoji picker close, 3 runs, `mcap.py compare alpha` against the Mac's remaining (as progress): **rms .0141 .0144 .0142**, 2-98 % 117 ms (Mac 117) | **confirmed** |
| 3b | app menu close 236 ms (Hyprland fadePopupsOut) | Finder context menu, closed by a click outside, 3 runs, menu interior: **rms .030 .025 .017**, 2-98 % 186 / 185 / 169 ms (Mac 167). Runs 1-2 start with a .17 step then +.09 per frame (Mac .14 .29 .45) | **partly**: 1 of 3 at the claim (.014-.015), 2 runs 1.7-2x |
| 3c | shell menu close 236 ms | Apple menu, 3 runs, menu only (`--sub` off the Finder window): **rms .0044 .0051 .0061** | **confirmed** |
| 3d | alert pop peak 1.17 / 214 / 180 ms | trash alert over grey 127, 3 runs, body width / final (diff from the first frame > 30): ours .027 .042 .054 .080 .119 .169 .226 .303 .391 .490 .602 .728 .870 1.027 **1.169** 1.142 1.111 1.088 1.065 1.050 1.034 1.019 1.011 1.004 1; Mac .043 .071 .106 .149 .206 .277 .362 .461 .582 .723 .840 1.011 **1.170** 1.145 1.117 1.096 1.071 1.050 1.032 1.018 1.004 1. The last 5 rising frames and the whole settle within .03; ours has 2 more frames under .06 at the start | **confirmed** (peak and settle; rise 233 vs 200 ms from the first visible frame) |
| 3e | alert dismiss out-cubic 154 ms | Cancel clicked, 3 runs, alpha vs the Mac remaining: **rms .0018 .0039 .0027** at best shift 26-30 ms; ours shows a .31 frame the Mac does not | **confirmed** |
| 3f | tiny alert glass radius scales | first frames (`07`, `08`): a rounded rect at the alert's scale, no circle. **But** from 165 to 265 ms the content overhangs the glass: the buttons sit across the glass's bottom edge and Cancel / the folder past its left edge (234 ms, scale 0.6: button bottom 228 px, rim about 224); the final frame has them inside | radius **confirmed**; new defect: glass smaller than / behind its content during the pop |
| 4a | 1 pt lines whole pixels at 1.6 (menus, Settings cards) | scale 1.6, full-output grim (`09`, `10`): Edit menu separators at x 330 px rows **148-149, 320-321, 376-377, 432-433**, all 2 px of 134 on 114. Settings Appearance card separators rows 528-529 and 1090-1091 (49 over 39) | **confirmed** |
| 4b | Dock cells on whole pixels | 1.6, row 1590 px (`11`): icon left edges 997, 1106, 1215, 1324 (pitch **109 px**, whole), edges a single-step transition (113 -> 245, 244 -> 113) | **confirmed** |
| 4c | Spotlight close blur ratio | `Spotlight.qml` 391 / 427 use `sp.devicePixelRatio`; Spotlight renders at 1.6; the close was not filmed | **static only** |
| 5 | sound log with gains (SOUND-REA 6) | `sound.json` feedback on, Funk, alertVolume 0.25; `volume-key.sh` up, up, down, mute, mute, Shift+up, Option+Shift up on the stub (0.5625 -> 0.625 -> 0.5625 -> muted -> unmuted -> 0.625 -> 0.640625): **5 pops** `BezelServices-volume.aiff vol=1` (none on mute, none on Shift+up). Notify on the private bus: sound-name Glass -> `Glass.aiff vol=0.4724`, default -> `Funk.aiff 0.4724`, no hint -> nothing, urgency 2 -> `alert Funk.aiff 0.4724` (exp(0.25 - 1) = 0.472). Real volume 0.46 before / after | **confirmed** (the events tested) |
| 6a | NC photo widget skips undecodable images | NC (`13`) shows `Downloads/good.png`, no NotificationCenter decode error in the log (judge #16 had one). The candidate list here (`find $HOME -maxdepth 2`) puts good.png first, so the skip path did not run | **not exercised** (code path present, `NotificationCenter.qml` 581) |
| 6b | StackArt: no "pixel size <= 0" on fan open | view set to Fan from the tile's menu, fan opened 3 times (`12`) plus the grid twice: **0** `setPixelSize` warnings (j16 x8 per open); the broken.png decode warning stays (x2 per open) | **confirmed** |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Dock | magnification hover (light), fan and grid, 1.6 | fine; the tile's chevron is still visible under the fan's first item (as j16) |
| Control Center | dark and light, held Sound knob on the stub | fine; the module rim darkens 83 -> 62 while held (no Mac reference) |
| NC | dark, widgets | fine |
| menus | Finder context, Apple, Edit (2x and 1.6), Dock stack menu | fine |
| alerts | trash alert show / dismiss x3 | content overhangs the glass during the pop (3f) |
| popovers | emoji picker open / close x3 | fine |
| Finder | icon view, toolbar, 2x | fine |
| Settings | Desktop & Dock, Appearance, dark / light, 1.6 | fine |
| Spotlight | 2x light, 1.6 dark | renders; the field is dark glass in light mode over grey 127 (not compared with a Mac shot: belum dicek) |
| shell log | whole session (47 lines) | no binding loop, TypeError or pixel-size warning; StackArt broken.png decode x13, qt.svg x6, text-input x6, portal x3 |

## Per dimension

| dimension | j16 | j17 | change | reason |
|---|---|---|---|---|
| animation | 91 | **91.5** | +0.5 | [17 live] alert pop within .03 of the Mac outline, popover close rms .014, shell menu .005 |
| transition | 90 | **90.25** | +0.25 | alert dismiss rms .002-.004; Finder menu close .017-.030 |
| visual | 93.5 | **93.75** | +0.25 | toolbar hover wash / divider / disabled match the Mac panel; preview light rim / face fixed |
| behaviour | 93.5 | 93.5 | 0 | nothing new |
| shape | 92 | **92.25** | +0.25 | CC lens 45 x 38 vs 46 x 38 (was 2 pt large), module lift +2 pt |
| colour | 95 | 95 | 0 | [16] |
| shadow | 94 | **94.25** | +0.25 | held switch lens shadow -14 = Mac (was -30) |
| refraction | 93 | **93.5** | +0.5 | switch interior flat and equal, fringes at the ends, CC fill verified, light ripples at the Mac's; minus both preview round ends now 20-32 off |
| icon | 93.5 | 93.5 | 0 | [16] |
| font | 95 | 95 | 0 | [16] |
| rendering | 90 | **90.25** | +0.25 | whole-pixel lines at 1.6, pixel-size warnings gone; alert content outside its glass during the pop |
| sound | 90 | 90 | 0 | log and gains match (checks, no behaviour change) |

Plain mean of the 12: 92.73 (j16 92.54).

## Per surface

| surface | weight | j16 | j17 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94 | **94.25** | shell menu close CA default (rms .005), separators 2 px at 1.6 |
| Dock | 14 | 94 | **94.25** | fan label font fixed, cells on whole pixels at 1.6; chevron unchanged |
| Window chrome | 14 | 91.75 | **92.25** | toolbar hover / press / divider / disabled in both apps; alert pop curve matches, but content overhangs the glass |
| Finder | 13 | 91.75 | **92** | toolbar, 1.6 lines; context menu close 1.2-2x the claim |
| System Settings | 10 | 94.25 | **94.5** | switch interior / fringe / rim / shadow, light preview rim and face; minus round ends |
| Control Center | 6 | 93 | **93.5** | held lens size and fill verified on the stub, module lift |
| NC + banners | 6 | 91.5 | 91.5 | photo skip not exercised |
| Spotlight | 6 | 89.5 | 89.5 | 1.6 blur static only |
| Mission Control | 4 | 90.5 | 90.5 | [16] |
| Sounds | 4 | 90 | **90.25** | gains and events verified live on the stub |
| HUD | 3 | 90.5 | 90.5 | [16] |
| Cmd-Tab | 3 | 91 | 91 | [16] |
| Apps | 2 | 86 | 86 | [16] |
| Lock screen | 5 | 91.5 | 91.5 | [16] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [16] |

Weighted: 13 surfaces 9252.25 / 100 = 92.52. With the lock screen 9709.75 / 105 = 92.47. With Stage Manager
9422.25 / 102 = 92.38.

## Regressions

- Preview round ends (Appearance, both modes): light 141 -> **171** (Mac 139), dark 107 -> **86** (Mac 105). Known to the
  developer (GLASS-HIG 8.3), but at judge #16 both were within 2 of the Mac.
- Alert pop: from 165 to 265 ms the buttons and folder icon extend past the glass's bottom / left edge (`08`); not
  visible at judge #16's method (the glass was a circle then, also wrong).

Defects still open: 1 px cyan line along the middle of the held switch's top rim (Mac none); the switch's outer rim
pixel +12; CC lens fill flat 223 (Mac ramps 246 -> 216) and shadow flat; the fan's tile chevron; Finder menu close
first-frame step.

## The next 10 changes, by gain

Repo only:

1. Alert pop: draw the glass at the content's scale in the same frame (the content overhangs it 165-265 ms) (+0.04).
2. Preview round ends: back to judge #16's levels (light 139-141, dark 105-107) without losing the light top rim (+0.03).
3. Finder context menu close: find the slow first frames (.17 then +.09; Mac .14 .29 .45) in 2 of 3 runs (+0.02).
4. Held switch: drop the 1 px cyan line in the middle of the top rim; outer rim pixel 208 -> 196 (+0.02).
5. CC held lens: fill ramp bright at the left rim (246 -> 216) and the shadow's ramp 4-5 pt below (+0.02).
6. A test for the NC photo skip with an undecodable first candidate (+0.01, unblocks 6a).

Needs the Mac:

7. The alert at 60-120 fps over grey (rise length: ours 2 frames longer under .06; shadow scaling) (+0.03).
8. Finder context menu close and a popover close over grey at 60 fps (+0.02).
9. A scaled mode capture ("More Space"): menu, Settings card, Dock, Spotlight close (+0.05).
10. Preview over a flat backdrop or the Regular recipe's highlight offset / height, to settle the round ends (+0.03).

## Reachable ceiling

About 92.65 with the repo's data (items 1-6). About 92.9-93.1 with the Mac captures. 95 is not reachable on this stack
for judge #7's reasons (about 3 points).

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91.5 | MC 4-window exit, stack fan / grid never filmed, alert rise 2 frames long | Mac 60-120 fps: MC 4 windows, stack, alert over grey |
| liquid glass | refraction + visual | 93.6 | round ends, alert content past the glass, no glass in third-party windows | repo 1, 2; Mac preview over flat backdrop |
| glass refraction | refraction | 93.5 | preview ends 20-32 off; switch middle cyan line; CC fill flat | repo 2, 4, 5 |
| shadows | shadow | 94.25 | switch / CC lens shadow peak placed too high; banner and module shadows never compared | Mac stills of banner and module shadows |
| depth | shadow + rendering | 93.5 | alert content over its glass edge during the pop | repo 1 |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93.25 | light / dark ripples at the Mac's now; scroll pocket (j14) | Mac Finder scrolled under the toolbar |
| sound | sound | 90 | output latency; Empty Trash / poof not fired here | Mac audio + screen capture |
| icon | icon | 93.5 | rtf / generic / app documents | Mac renders of document pages |
| emoji | (direct) | 94.5 | emoji in text never compared | Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 91 | lines and Dock grid whole-pixel at 1.6 (measured); no Mac scaled-mode capture | Mac "More Space" capture |

## Crops (`reference/judge-95-17/`)

`01-held-switch-light-mac-top-ours-bottom.png` (ours scaled 1.45 to the strip), `02-held-switch-dark-ours.png`
(rest above, held below), `03-preview-buttons-{light,dark}-mac-top-ours-bottom.png`,
`04-cc-sound-held-lens-dark-grey127-mac-left-ours-right.png`, `05-settings-back-forward-rest-hover-press-disabledhover-
dark-ours.png`, `06-finder-back-forward-rest-hover-press-disabledhover-dark-ours.png`,
`07-alert-pop-frames-184-265ms-and-final-ours.png`, `08-alert-pop-234ms-content-past-glass-ours.png`,
`09-edit-menu-scale1.6-ours.png`, `10-settings-appearance-scale1.6-ours.png`, `11-dock-scale1.6-ours.png`,
`12-stack-fan-light-grey-ours.png`, `13-nc-photo-widget-ours.png`.
