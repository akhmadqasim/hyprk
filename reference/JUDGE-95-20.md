# hyprk independent judge #20, branch mac-27.2.1-rea-2026-11-14 (e2d49ee) + working tree (2026-11-14, 19:19-20:08 WITA, measured live)

Delta judgement against judge #19 (`JUDGE-95-19.md`, 92.71). Method and weights from `JUDGE-95-7.md` as carried by #17-#19:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[20 live]** measured
on screen here; **[20 static]** checked in the code only; **[19]** carried from judge #19.

## What was judged

- Since judge #19: the large uncommitted round (Mac rounds 2-5, `MAC-ANSWERS-{2,3,4,5}.md`): glass rounds 7-10
  (`GLASS-HIG.md` 12-15), Spotlight R3.2 / R4.4, alert R3.1 + dismiss blur, HUD R3.4 / R5.1, Motion REA rounds 4-6, lights
  section 9, Settings UI audit, status modules round 4 + vibrancy, extras audit, preview article, scaling R3.3, sound
  section 7, emoji in text. `plugin/build/libliquidglass.so` 19:16 (after every plugin source, last 19:09); the session's
  Hyprland mapped exactly that file. Finder binary 19:02, its QML loads from the tree.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_SOUND_LOG=... scripts/smoke.sh`
  (2560 x 1664, scale 2; light, then dark, light for the CC stripes and the clear test; 2880 x 1866 at 1.5 for the
  scaling check, then back), state `$XDG_RUNTIME_DIR/hk-j20` (repo `appearance.json` copied, `wallpaper.json` pointed at
  flat grey 127, flat white or 4 pt black / white stripes made in scratch), scratch HOME (judge #19's `Documents` /
  `Downloads` + a folder, a 40 PNG + 20 txt folder in the Mac's colours, the Mac's four emoji file names), XDG_CACHE_HOME,
  TMPDIR, the script's private bus. Stub env read from `/proc/<qs pid>/environ` (HOME scratch, both stubs,
  `HYPRK_MUTE=1`). Cursor hidden in the nested session (`hl.config cursor.invisible`) so grabs carry no pointer.
  Finder and foot started with the shell's own environment (as the Dock does); Settings via `settings/run.sh`.
- Tools: `vptr` (one fifo for the session), `fscroll`, `mcap` (every capture `long_intervals` 0), `mcap.py alpha`,
  judge #19's `cc.py` / `cc2.py` unchanged, new scratch scripts: a per-frame scale + alpha fit of `frame - bg = a * warp(rest
  - bg, s)` (`fits.py`, same model as the dev's `fitscale.py`), the PopIn model fit, a Gaussian text-blur fit
  (calibrated: the Mac's dark dismiss frame gives **0.80 pt, a .846**, the dev's 0.80), a HUD per-frame s / content /
  glass metric, shadow darkening columns, lens column profiles, emoji ink segmentation, list-row shares, light clusters.
  Mac clips read by pts (`ffmpeg -vsync passthrough -frame_pts 1`).
- The coordinator's short agents edited the shell 19:49-19:56 (hot reloads at 19:50-19:53). Everything shell-side
  measured in that window was re-measured after 19:56 (Spotlight list and shortcuts, CC, alert dark); the HUD runs were
  before the first reload (19:48). Stopped with `smoke.sh --stop`, bus, pointer and holder killed, state dir and the
  session's volkey dir removed, frame dumps deleted. Nothing written to the repo but this file and the crops.
- Not measured: Cmd-Tab, Apps, lock screen, Stage Manager (no change claimed), Battery module, switch release frames,
  Dock separator at 1.5 (needs a shell restart), Settings scroll-edge line (changed at 19:56, not re-shot).

## Overall: **93.2** (13 surfaces 93.15, with the lock screen 93.07, with Stage Manager folded in at weight 2: 92.99)

Judge #19: 92.71. The new Mac data mostly confirms the developer: Spotlight's light field, list veil and shortcuts, the
banner / module shadows, the emoji in text, the Dock fan / grid curves, the Mission Control key look, the Settings pop-up
and the preview article all land within 0-2 levels or a frame of the Mac's. #19's top defect (the CC lens rim crossing
the fill, 173 / 140 vs 231 / 170) now reads 243 / 181. Not reproduced: the sound / HUD offset (pop leads the HUD's first
frame by 57-63 ms, claimed 25-29, Mac 18), the light dismiss blur, the HUD content curve. One new defect: the alert's first
appear frame is a 3.5 x 2.5 pt opaque glass speck (4 of 4 runs).

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | held Settings slider (Desktop & Dock > Size) light and dark vs `slider-held-settings-*.png` | lens 52 x 42 px both (Mac 51 x 41). Light column: rim **194 194 / 194 194** (Mac 198 195 / 190 192); card in lens 255 252 251 250 ... (Mac 254 250 249 248 ...); shadow every 2 px **236 235 232 230 228 228 230 233** (Mac 241 237 234 231 229 229 230 232); fill on the centre row 121-116 (Mac 133-128, the PNG is Display P3). Dark: rim **18 18 / 18 18** (Mac 21 20 / 19 20); card in lens 110 89 70 67 66 64 ... 54 (Mac 101 92 73 70 69 66 ... 56); shadow **36 34 33 32 32 32** (Mac 39 38 36 35 34 34; our card 38 vs 42); fill 140-121 (Mac 150-133) (`07`) | **confirmed** (1-5 levels; dark card 4 lower, bluish) |
| 1b | held switch, white knob inside the lens; press / release vs `switch-held-stripes-*.mov` | held, column through the lens centre, light: rim **206 194** (Mac 192 193), card in lens 255 255 252 250 ... (Mac 255 254 249 248 ...), bottom rim 194 204 (191 191), shadow 238 237 238 236 235 234 ... (243 242 241 239 238 237 ...). Dark: rim **22 18**, inner highlight **91 73 50** (Mac 20 20, 91 72 52), shadow 37 (card 39; Mac 41 on 42) (`09`). Press, light, knob R at its centre from the first change: **252 241 223 197 164 129 92 59 34 15 4 0** (Mac clip 254 253 238 220 195 164 131 97 69 44 25 10 3); first change to still **185 ms** (Mac 200). Frames 1, 3, 5, 7, 11 side by side: the white sits inside the lens and fades with the track refracted round it, as on the Mac (`08`) | **confirmed** (release not measured) |
| 1c | CC Sound lens, light (`slider-held-cc-light.png`, 4 pt stripes) and dark | light over stripes: fill in the lens (> 170) **218.8** (Mac 218.2); top rim 63 63 (Mac 70 68), inner highlight 167 148 131 (158 153 137), bottom 140 155 / 79 59 (145 163 / 89 65); module under the lens **109-120** (Mac 121-134) (`16`). Dark over grey, #19's `cc.py`: box **48 x 40**, rims 46 x 39 (Mac 47 x 40 / 46 x 38); fill mean **219.1** (Mac 224.0, #19 217.6); per column 237 238 235 232 229 226 224 222 220 218 ... 206 192 (Mac 246 245 241 238 235 231 ... 211 192); shadow **98 95 91 88 88 89** (99 95 91 86 85 85); rim where it crosses the fill, columns lx-2..lx+2: **245 243 181 186 237** (Mac 254 231 170 193 246; #19 had 173 / 140 at lx-1 / lx) (`15`) | **confirmed**; the rim crossing is fixed (+12 / +11 now), dark fill -5 |
| 2 | plugin round 9: alert / menu side rim, light dark-specular (two lobes), low-opacity dither | alert over grey 127 at rest (`01`), light: left **114 / 54 / 199**, right **199 / 54 / 114**, top **120 / 101 / 231 218**, bottom 219 **232 / 90** / 108: the Mac's 114 / 54 / 199, 120 / 100 / 230 219, 218 231 / 90 / 108, to the level. Dark: side line **53** (Mac 46), bottom rim **138 156 / 105** (Mac 136 153 / 105). Apple menu dark over grey: side **53 / 52**, bottom 138 156 / **105** (Mac probe 47, 138 156 / 106). HUD glass alpha during the appear, by my metric: .04 .07 .11 .16 .22 ... (no step to .108 at low opacity) | **confirmed** (dark side line not fixed, as stated) |
| 3 | shadows: banner 0.4 / 0.6, module, Finder scroll pocket | darkening straight below the middle at 1, 4, 8, 14, 22, 30, 40 pt. Banner light / grey **10 9 8 6 3 1 0** (Mac 10 9 7 5 3 1 0); light / white **20 18 15 11 6 3 1** (20 18 15 10 6 2 1); dark / white **25 21 17 11 6 2 1** (25 22 17 12 5 2); dark / grey **16 14 12 9 5 2 1** (16 14 11 8 5 2 0). Wi-Fi module: light / grey **19 17 14 11 6 3 1**, dark / grey **22 20 17 13 7 4 1**, and both over white: identical to the Mac's in every case (`04`). Finder icon view scrolled to the Mac's geometry (thumbnails 104..185 px, Mac 104..183): line at 52 pt **229** over plain (Mac 228), G **83 over 91** over the thumbnail (Mac 77 over 86); dark band **(40,40,46)** (39,39,44), line (47,47,52) (47,47,51); above the line, light G 252 250 246 240 228 218 213 (Mac 255 ... 253 249 247), dark R 43 47 57 69 75 (42 43 49 59 65) (`11`) | **confirmed**; the bleed above the line is still 2-4x the Mac's, as stated |
| 4 | Spotlight R3.2 / R4.4 | idle: bare pill, no change in 1.5 s (light and dark). Pointer moved far from the bar: the list appears and stays. Bar over white, light: top **178 pt** (Mac 205 at 932: centre .2662 vs .2666 of the height), rows at 5 / 14 / 23 / 51 / 74 / 87 % 13 25 40 89 176 206 (Mac 10 25 41 91 176 206), top rim 38 40 (51 31), shadow +2 / +20 / +60 px 235 246 254 (236 246 254). List rows at 2 / 11 / 50 / 80 / 98 % of 214 pt: light over white **123 133 165 188 203**, dark over white **123 133 165 188 203**, dark over grey **68 73 91 103 112** (Mac dark stills 121 134 166 189 203 / 68 74 91 104 113) (`10`). Shortcuts panel / ink: dark grey **76 / 144, 87 / 154, 96 / 163, 106 / 173** (Mac 77 / 143, 87 / 152, 96 / 162, 106 / 171), white 139 / 207 ... 193 / 255 (Mac 141 / 207 ... 193 / 255); the ⌘-digit gap 9 px (Mac 9; re-measured after the 19:51 edit). Open alpha **.383 .567 .733 .869 .971 .998** (Mac .375 .568 .736 .865 .963 .998); close remaining **.299 .048 .005** (Mac .325 .051, gone). Clear (a BackSpace sent with `send_shortcut` after a "t" query): the results panel shrinks and fades over 10 frames, width .97 .85 .73 .62 .52 .45 .38 .31 .27, gone at 181 ms (Mac .938 .832 .715 .505 .427 .366 .317 .255, gone in 0.2 s), ends on the bare pill | **confirmed**. Gap between bar and list in dark: 104-121 over white (Mac 95-104), 52-60 over grey (47-52) |
| 5 | alert: PopIn 0.4 s, Cancel spring, other buttons instant, dismiss blur, shadow scaling | scale + alpha fit per frame (light / dark): scale vs the decoded PopIn **rms .0067 / .0077** (Mac clip .0018 / .0068 by the same fit; claimed .0009 / .0012), peak **1.181** both (Mac 1.194 / 1.178), alpha vs v **.022 / .026** (Mac .009). Cancel, light: whole alert .725 .504 .344 .224 .145 .092 .057 .033, gone at 148 ms (spring .76 .54 .37 .24 .16 .10 .06; Mac dark clip one frame at .75, light clip none). Empty Trash: **gone in the first frame**. Text blur at the first Cancel frame, the calibrated Gaussian fit: dark **1.25 pt** (claimed 1.15, Mac **0.80**), frame 2 2.70 (claimed 2.65); light **2.0 pt** (fit rms 6.5, poor; no Mac light frame); text alpha at frame 1 .67 (Mac .85) (`03`). Shadow reach below / scale (footprint > 2 levels): dark ours 125-151 pt from s .13 (Mac 90-141 from s .21); light ours **127-142** where the Mac reads **75-120** for s .16-1.2 at the same alpha (.19 vs .20 at s .18). **First appear frame**: a 7 x 5 px fully opaque glass (194-224 face, 73-78 rim) at the centre, 4 of 4 runs, light and dark; the next frame is the expected faint s .05 (`02`) | **confirmed** for PopIn, the springs and the instant buttons; dismiss blur 1.6x the Mac's (dark), light not reproduced; shadow scales in dark, too large while small in light; **new: first-frame speck** |
| 6 | HUD: content curve, glass o^2 x .925, hold, empty dash +28 | dark over grey, IPC 13/16 -> 14/16, 2 runs, 960 x 400 crop like the Mac's. At rest: glass **-9.3** under the backdrop (Mac -10.0 in the clip), empty dash **+29** over the glass (Mac +30) (`14`). Glass step: ours **.92 -> 1.00** at first frame + 485 ms (Mac .80 -> 1.00 at + 533 ms, 8-bit steps). Hold (appear spring start from the scale fit to the first hide frame): about **1.00 s** (Mac 1.000). Content: my dash metric gives ours ahead of the Mac's at equal scale (s .96: .39 vs .28-.32; s .984: .78 vs .53-.57); ours follows the fitted model, the Mac clip reads below it (H.264 dashes); claimed rms .010 not reproduced by this metric | **confirmed** for rest, step, hold; content curve not reproduced |
| 7 | motion: Downloads fan / grid, More in Finder slot, fan close end; MC exits; close button hold | Fan (View content as Fan, 14 items): item 0's bottom per frame vs ease-in-out 0.25 s **rms .0064** (Mac .012, claimed .0047), 59 pt wide from the first frame; "6 More in Finder" disc and arrow drawn (`18`). Grid open top edge vs CA default 0.25 s **rms .0032** (Mac by the same fit .0215 at even 16.7 ms; dev .0115 by pts); grid close .050 .153 .294 .443 .584 .689 .771 .836 .874, gone (Mac .080 .199 .356 .497 .620 .719 .808 .860 .905, gone): same 9 frames, half a frame behind. Fan close: tile empty, label shown, item 0 59 -> 39 pt on the default curve. MC, 4 foot windows 700 x 500 at (80,70) +80,+50, click on Window 1's tile: Window 4's lights grey and Window 1's coloured **in the same frame, 2 frames after the first changed frame** (Mac f181: the same); top strip of every frame: only the flying thumbnails, no ghost (`17`); Esc exit: the Spaces bar slides up opaque, pill bottom .10 .28 .48 .66 .79 .93 of its way (Mac bar .22 .38 .53 .66 .78 .89 .94 .97). Close button (Finder) held 2.9 s: width +18.6 % at the peak (0.15-0.17 s after the first change), settles +15.2 % (Mac +16 to +20 %, +14.7 to +15 %), idle end **2.12 s** after the first change (Mac 2.10 / 2.12); dragged off: the ring colour holds **85 ms**, then 157.9 -> 115.5 over 0.5 s (Mac 70-86 ms, 0.5 s) | **confirmed**; MC menu bar fades in faster than the Mac's (stated gap) |
| 8 | Settings: pop-up pill, menu glass, open / blink / close, quick clicks; sidebar; panes; Siri hidden | Dock position pop-up: hover **229 on 247**, 24 pt, corner 8 6 4 3 2 2 1 1 px (Mac 228, 8 5 4 3 2 1 1 1); dark **39 -> 55** (Mac 39 -> 55). Quick click (vptr `b`, 0 ms): pressed look 3 frames (16 / 32 / 49 ms), menu complete in the 4th (66 ms), glass menu as the Mac's Small / Medium / Large shot. Choose: highlight off 4 frames, on 3, fade from the 7th; menu alpha .177 .329 .477 .604 .704 .787 (Mac .153 .310 .471 .607 .714); pressed look goes 50 ms after. Click outside x3: first fade frame **14-30 ms** after the click (#19 58-63), curve .057 .170 .323 .474 .603 .707 .789 .853 .904 (CA default). Sidebar scrolled: rows pass under the search field, nothing above it. Panes: Desktop & Dock and General light against `panes/*-00-light.png`: rows within 1-3 pt, AppleCare / AutoFill rows absent (stated), Siri row absent (user's choice) (`13`). Preview article: end state against still 11 light (mean abs diff 13.7, text and photo edge on the same rows) and dark (16.9; the rainbow photo's crop differs a little), top against still 00 dark (5.2) (`12`) | **confirmed** |
| 9 | status modules vs `module-*.png`, hover, Focus on | Wi-Fi light: lines at **42, 107-108, 140** pt (stated 42, 107, 140), hovered row x 749.5..1043 pt (7.5 in from the panel's 742..1050), 32 pt tall, **-21** flat under the glass (Mac -20); Focus with Do Not Disturb on: header "Focus / On", indigo disc, no line above Focus Settings…; the other five modes dimmed (Mac: enabled) (`19`). Menu bar Wi-Fi item shows the slash while the stub module lists "Home" connected (stub data, not judged) | **confirmed** (Battery not opened) |
| 10 | extras audit | 8 removed strings grep'd in shell / settings / finder / ui: 0 hits for "Check Caps Lock", "isn't available on Linux", "This computer has no battery", "Disk encryption is managed", "will be listed here", "Try again in a moment", "pinch-to-zoom", "Sound previews need"; "— Local" only in a comment; banners `showTime: false` (NC keeps "5m ago", seen live) | **confirmed** (spot check) |
| 11 | preview article 1257.5 pt, photos, scroll end | see 8: the end matches still 11 light; scrolled with finger frames, the pane did not move | **confirmed** |
| 12 | fractional scale lines | output 2880 x 1866 at 1.5, a fresh Settings: every card separator on the Desktop & Dock pane carries **1.46-1.54 rows** of ink (.31 1 .15, .31 1 .23, .69 .77, .38 1 .08, ...; Mac simulated 1.4-1.56) | **confirmed** for Settings; Dock separator not checked |
| 13 | sound: pop 60 ms after the level, timing vs `volume-pop.mov` | `volume-key.sh up/down 16 shift` on the stub, stamped by polling: level written 8.5-11.7 ms, sound log **76.5-80.0 ms** (pop **67.8-68.4 ms** after the level, 10 runs). With mcap of the bar and HUD (dark): pill 32-79 ms, HUD first frame (> 20 px over 4 levels) **146-198 ms**: pill -> HUD **100-119** (Mac 66.7), pill -> pop out (log + 11) 40-56 (Mac 48.7), pop -> HUD first frame **57-63** (one run 107) (Mac 18; claimed 25-29). At > 2 levels the HUD shows at 129-132 ms (pop -> HUD 41-44) | pop delay **confirmed**; pop -> HUD **not reproduced** (the HUD's first frames are late / faint) |
| 14 | emoji in text vs `emoji-in-banner-*`, `emoji-in-name-*` | banner body, light: 😀 **325-355, rows -25..+5** (Mac the same), 👍🏽 363-391 (364-392), 🇮🇩 401-429 (402-430), line end 576 (578) (`05`). Finder list, "Report 😀👍🏽🇮🇩.txt" selected, started with the shell's environment: 😀 90-120 from 'R' (Mac 90-118), pitches 37, 38 (38, 38), 🇮🇩 165-195 (166-194), 🇮🇩 -> '.' 7 (8), name end 238 (238) (`06`). Started from a plain shell without `FONTCONFIG_FILE` the same Finder draws them at 0.75 size (23 x 22 px, pitch 27): the fix depends on the session's fontconfig | **confirmed** (session environment) |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Finder menus | context menu close by a click outside x2 | .050 .157 .310 .464 .597 .704 .788 .854 .904, first fade frame 12-13 ms after the click: as #18 / #19 |
| Finder toolbar | ⋯ action menu (changed 19:50) | opens on the first click, closes on the second |
| Settings menus | pop-up open / choose / close (claim 8) | close start moved 58-63 -> 14-30 ms |
| alerts | appear x4 (light 3, dark 1) + stills both modes, Cancel light x2 / dark x2, Empty Trash | see claim 5; first-frame speck |
| menus | Apple menu dark over grey | side 53 / 52, bottom 105 |
| switches, sliders | held light and dark, press frames light | claim 1 |
| CC | dark held lens over grey, light open and held over stripes | claim 1c |
| NC | dark over grey, banner history | fine; banner time kept in NC only |
| Dock | grid open / close, fan open / close, stack menu | claim 7 |
| Mission Control | click exit, Esc exit | claim 7 |
| HUD | appear x2 dark over grey | claim 6 |
| shell log | whole session (210 lines) | no TypeError, ReferenceError or binding loop. New since #19: **71 x "ShaderEffect: 'pad' does not have a matching property"** (`plusfill.frag` has a `pad` uniform, `ControlCenterSlider.qml` uses it without the property; harmless, noise). Also: 4 reloads 19:50-19:53 (the coordinator's agents), NC + StackArt broken.png x1 each per load (the skip), qt.svg path x4 per load, portal, brightnessctl missing, libpng iCCP from the Mac-coloured test PNGs |
| tests | `node shell/tests/run.mjs` | **405 passed, 0 failed** |

## Per dimension

| dimension | j19 | j20 | change | reason |
|---|---|---|---|---|
| animation | 91.85 | **92.5** | +0.65 | [20 live] alert PopIn + alpha = v, Cancel spring, instant buttons; Dock fan / grid curves; MC key look and no ghost; lights one spring + 2.1 s idle + leave fade; switch press frames; minus the first-frame speck and the late HUD start |
| transition | 90.55 | **91.1** | +0.55 | [20 live] Spotlight open / close / list / clear on the Mac's frames; Settings pop-up open, blink, close start 14-30 ms; Spaces bar slides opaque |
| visual | 93.75 | **94.0** | +0.25 | Spotlight light field (was dark glass), status modules and Focus on, panes |
| behaviour | 93.5 | **93.75** | +0.25 | Spotlight list on motion, quick clicks open pop-ups, ⋯ menu second click, extras removed |
| shape | 92.3 | 92.35 | +0.05 | resting glass on whole points (alert / menu bottom row 105) |
| colour | 95 | 95 | 0 | shortcut plus-lighter and empty dash +29 at the Mac's; at target |
| shadow | 94.5 | **94.75** | +0.25 | banner and module shadows within 1 level of the Mac's in 8 cases; alert shadow scales (dark); minus the light small-scale halo |
| refraction | 93.85 | **94.1** | +0.25 | CC rim crossing 243 / 181 (Mac 231 / 170, #19 173 / 140), light CC fill 218.8 / 218.2, held slider / switch both modes within 1-5 |
| icon | 93.5 | **93.6** | +0.1 | "More in Finder" slot art |
| font | 95 | 95 | 0 | [19] |
| rendering | 90.6 | **90.75** | +0.15 | dither at low opacity, whole-point edges; minus the first-frame speck |
| sound | 90 | **90.25** | +0.25 | pop 68 ms after the level: pill -> pop 40-56 (Mac 49); the HUD lag is scored under HUD |

Plain mean of the 12: 93.10 (j19 92.87).

## Per surface

| surface | weight | j19 | j20 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.25 | **94.75** | modules match the Mac's layout, hover and Focus on; module shadow equal; menu bottom rim 105; extras gone. Left: side line 53 vs 47, light secondary text not vibrant, five Focus modes dimmed |
| Dock | 14 | 94.25 | **94.75** | fan ease-in-out .0064, grid default .0032, close curves, slot art, tile empty while closing |
| Window chrome | 14 | 92.5 | **92.75** | alert alpha / Cancel / instant buttons, light rims to the level, lights hold / idle / leave; minus the first-frame speck, the 1.6x dismiss blur and the light small-scale shadow halo |
| Finder | 13 | 92.5 | **93** | scroll pocket band + line at the Mac's, emoji in names, ⋯ menu; bleed above the line 2-4x, list view rows not under the header |
| System Settings | 10 | 95 | **95.25** | pop-up hover / press / open / blink / close start, held controls in light, preview end, panes; dark card bluish |
| Control Center | 6 | 93.75 | **94** | rim crossing fixed, light lens fill at the Mac's; dark fill -5, light module under the lens 12 dark |
| NC + banners | 6 | 91.75 | **92.25** | banner shadow decoded (within 1 level), emoji in banners exact, no time or stacking in banners |
| Spotlight | 6 | 89.5 | **90.75** | bare pill, list trigger, veil within 2 in 3 conditions, shortcuts, open / close / clear, bar centre; dark gap between bar and list, bottom rim over white |
| Mission Control | 4 | 90.5 | **91.25** | key look in the Mac's frame, no ghost, Spaces bar slides opaque; menu bar fades in early |
| Sounds | 4 | 90.25 | **90.5** | pop after the pill as on the Mac |
| HUD | 3 | 90.75 | **91** | rest glass, empty dash, glass step, hold; first visible frame 30-50 ms late |
| Cmd-Tab | 3 | 91 | 91 | [19] |
| Apps | 2 | 86 | 86 | [19] |
| Lock screen | 5 | 91.5 | 91.5 | [19] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [19] |

Weighted: 13 surfaces 9314.75 / 100 = 93.15. With the lock screen 9772.25 / 105 = 93.07. With Stage Manager
9484.75 / 102 = 92.99.

## Regressions

- **Alert appear, first frame** (new with the R3.1 rework, alpha = v from frame 1): a 7 x 5 px (3.5 x 2.5 pt) glass at full
  opacity at the alert's centre for one frame (face 194-224, rim 73-78 over grey 127), 3 of 3 runs light, 1 of 1 dark; the
  next frame is the expected faint s .05 / a .06. The Mac's first frame is s .03 at alpha .04 (invisible).
- Log noise: 71 "'pad' does not have a matching property" (ControlCenterSlider's `plusfill` use without `pad`).
- Not a regression, an older claim not holding: pop -> HUD first frame 57-63 ms (Mac 18), the sound doc's 25-29.

Defects still open: HUD first frames late / faint (pill -> HUD 100-119 vs 67); alert dismiss text blur 1.25 pt dark / ~2 pt
light at frame 1 (Mac 0.80) and text alpha .67 (Mac .85); light alert shadow halo while small (127-138 vs 75-101 pt per
scale); Spotlight dark gap between bar and list (+10 / +6) and no bright list bottom rim over white; Finder pocket bleed
above the line 2-4x, list view rows not under the header; dark side line 53 vs 46-47 (alerts, menus); Settings dark card
(37,38,43) bluish vs the Mac's neutral 42 over grey; CC dark fill -5, CC light lens over the module 109-120 vs 121-134;
MC menu bar fades in faster; five Focus modes dimmed; light module secondary text not vibrant; emoji size depends on
`FONTCONFIG_FILE` (an app started outside the session falls back to 0.75 size).

## The next 10 changes, by gain

Repo only:

1. Alert appear: no opaque first frame (the plugin draws the glass at full materialize when the shape is a few px; hold
   the first frame or carry the alpha marker from frame 1) (+0.03).
2. HUD: first visible frame 30-50 ms earlier (the faint start: content held to o .25 and glass o^2 x .925 together make
   frames 1-3 invisible; the Mac shows 14 levels at t0 + 35 ms) (+0.03).
3. Alert dismiss: text blur at the Mac's 0.8 pt at frame 1 (MultiEffect r = 4 sigma over-drives here; light 2 pt) and the
   text alpha on the window's alpha (.85, not .67) (+0.02).
4. Spotlight dark: the gap between bar and list and the list's bright bottom rim over white (+0.02).
5. Alert shadow in light at small scale (halo 127-138 pt / s vs 75-101) (+0.01).
6. Finder pocket: thumbnail bleed above the line (light 213 vs 247 at 1 px) and list rows under the header (+0.02).
7. CC dark lens fill +5 and the light lens over the module (+0.01).
8. Dark side line 53 -> 46 on alerts and menus (bias -0.278 or hl 1.11, not decoded) (+0.01).

Needs the Mac:

9. A disabled row and a non-DND Focus mode on in a module; Spotlight list appear blur over a structured backdrop (+0.01).
10. Settings dark window over grey 127 on a second backdrop (the chameleon rule for the card colour) (+0.01).

## Reachable ceiling

About 93.35 with the repo items 1-8. About 93.4-93.5 with the Mac captures above. 95 is not reachable on this stack for
judge #7's reasons (about 3 points: no glass in third-party windows, GTK / Qt apps, output latency, Stage Manager, Apps).

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 92.5 | HUD first frames late, alert first-frame speck, MC menu bar early, grid half a frame behind | none (repo 1, 2) |
| liquid glass | refraction + visual | 94.05 | CC dark fill -5, light lens over the module, no glass in third-party windows | repo 7 |
| glass refraction | refraction | 94.1 | as above; dark side line +7 | repo 7, 8 |
| shadows | shadow | 94.75 | alert halo while small (light) | repo 5 |
| depth | shadow + rendering | 92.75 | the speck; dismiss blur strength | repo 1, 3 |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93.5 | alert dismiss blur 1.6-2.5x; Finder pocket bleed; Spotlight list appear blur not measured | repo 3, 6; Mac 9 |
| sound | sound | 90.25 | output latency; Empty Trash / poof / shutter not filmed; HUD lag | Mac audio of Empty Trash, poof, shutter |
| icon | icon | 93.6 | rtf / generic / app documents | Mac renders of document pages |
| emoji | (direct) | 95 | measured equal in a banner and a Finder name (session env) | none |
| font | font | 95 | at target | none |
| scaling | (direct) | 91.5 | Settings lines at 1.5 carry the Mac's 1.4-1.56 rows of ink; Dock / menus / modules at 1.5 not re-shot; runtime scale change needs a shell restart | a run with the shell restarted at 1.5 |

## Crops (`reference/judge-95-20/`)

`01-alert-light-grey127-mac-left-ours-right.png`, `02-alert-appear-first-frames-89-139ms-ours-x8.png` (the speck, then the
next three frames), `03-alert-cancel-dark-grey127-mac-frame1-left-ours-rest-top-frame1-bottom-right.png`,
`04-banner-shadow-light-grey127-mac-top-ours-bottom.png`, `05-emoji-banner-light-mac-top-ours-bottom.png`,
`06-emoji-finder-name-light-mac-top-ours-bottom.png`, `07-settings-size-slider-held-mac-left-ours-right-light-top-dark-
bottom.png`, `08-switch-press-light-frames-mac-top-ours-bottom.png` (frames 1, 3, 5, 7, 11 of each),
`09-switch-held-mac-top-ours-bottom-light-left-dark-right.png`, `10-spotlight-modelist-dark-grey127-mac-left-ours-
right.png`, `11-finder-scroll-pocket-light-mac-top-ours-bottom.png`, `12-preview-article-end-light-mac-left-ours-right.png`,
`13-settings-desktop-dock-light-mac-left-ours-right.png`, `14-hud-rest-dark-grey127-mac-top-ours-bottom.png`,
`15-cc-sound-held-lens-dark-grey127-mac-left-ours-right-x4.png`, `16-cc-sound-held-light-stripes-mac-top-ours-bottom.png`,
`17-mc-click-exit-top-strip-frames-35-185ms-ours.png`, `18-dock-downloads-fan-open-ours.png`,
`19-focus-module-on-dark-mac-left-ours-right.png`. Crops 01-06 and 08, 10-14, 17-19 are palette PNGs (look only); 07, 09,
15, 16 are true colour.
