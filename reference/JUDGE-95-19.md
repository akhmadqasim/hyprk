# hyprk independent judge #19, branch mac-27.2.1-rea-2026-11-14 (1db54be) + working tree (2026-11-14, 16:32-16:45 WITA, measured live)

Delta judgement against judge #18 (`JUDGE-95-18.md`, 92.66). Method and weights from `JUDGE-95-7.md` as carried by #17 / #18:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[19 live]** measured
on screen here; **[19 static]** checked in the code only; **[18]** carried from judge #18.

## What was judged

- Since judge #18: `ui/HyprK/Popup.qml` exit (CA default `Tokens.panel.popoverFadeCurve` over `Tokens.panel.menuFadeOut`
  236 ms, 16:25), `shell/modules/HudWindow.qml` (`onScaleChanged: win.glassMoved()` on the capsule, 16:26),
  `shell/modules/ControlCenterSlider.qml` + `Theme.cc.lensDy` 0.5 (16:29-16:30), CC held-lens fill.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_SOUND_LOG=... scripts/smoke.sh`
  (2560 x 1664, scale 2; dark, then light), state `$XDG_RUNTIME_DIR/hk-j` (repo `state/` copied, set dark), scratch HOME
  (judge #18's `Documents` with `broken.png`), XDG_CACHE_HOME, TMPDIR, the script's private bus. Stub env read from
  `/proc/<qs pid>/environ` (HOME scratch, `HYPRK_AUDIO_STUB=1`, `HYPRK_STATUS_STUB=1`, `HYPRK_MUTE=1`); `volume-key.sh` run
  with the same env plus `HYPRK_MUTE=1`, so only the stub sink moved (0.5 -> 0.5625 -> ... 0.8125). From the HUD test
  on, `wallpaper.json` pointed at the flat grey 127 image. Tools: `vptr`, `mcap` (all captures `long_intervals` 0),
  `mcap.py compare`, judge #18's scratch scripts unchanged (`cc.py` given a file argument, `cc2.py`, `aglass.py`), one new
  one for the HUD (`hud2.py`: glass width from the dark side rims on the centre rows vs the speaker glyph's left edge at
  half maximum, sub-pixel, both about the capsule centre). Stopped with `smoke.sh --stop`, bus killed, state dir and the
  session's volkey dir removed.
- Calibration: judge #18's own `spop1` / `menu1` captures through my compare give **.0460** / **.0044**, its numbers.
  Mac series as #18: menu probe alpha (progress `.1395 ... 1`), alert dismiss remaining (progress `.511 ... 1`), Mac CC
  frame 3 crop.
- Not measured: Spotlight, Mission Control, Cmd-Tab, Apps, lock screen, Stage Manager, sounds, scale 1.6 (no change
  claimed). Crops in `reference/judge-95-19/`.
- Slip on my side: one 50 x 50 grey probe (`g.png`) landed in the repo root after the env's `cd`; deleted at once
  (my file, 16:34). The held-switch tests toggled "Animate opening applications" twice in the scratch state only.

## Overall: **92.7** (13 surfaces 92.71, with the lock screen 92.65, with Stage Manager folded in at weight 2: 92.56)

Judge #18: 92.66. All three claims hold on screen. The Settings pop-up menu now closes on the CA-default curve
(rms .0019-.0033 dark, .0034-.0052 light, was .046 linear). The HUD's glass and its glyph scale in the same frame (within
.001-.004, a one-frame lag would read +.005-.008). The CC held lens recovered most of its level (fill mean 217.6, Mac
224.0, #18 212.7), the lens box and rim now match the Mac's (47 x 40, rims 46 x 38) and it sits 1 px (0.5 pt) lower.
Nothing regressed. What still holds it: the CC lens rim cuts the fill darker than the Mac's, and the Settings pop-up's
fade starts 2 frames later after the click than the Finder menu's.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1 | Settings pop-up menus close on CA default (0.25, 0.1, 0.25, 1) over 236 ms | Desktop & Dock "Dock position" pop-up, region `780,150 260x250`, `--sub 10,10,190,215`, closed by a click on the window's toolbar with the pointer parked off the menu first (else the item highlight leaving reads as a .62 step). Dark x3: **rms .0019 .0033 .0019**, light x3: **.0034 .0048 .0052**; #18's capture by the same rule .046. Progress .00 .05 .16 .31 .47 .60 .71 .79 .86 .90 .94 .97 .98 .99 1 (Finder menu .05 .16 .31 .46 .60 .70 .79 .86 .91 ...), 2-98 % in 198-202 ms. Frames (`12`): one fade, text sharp. Best shift **58-63 ms** after the click (Finder context menu 26-30 ms) | **confirmed** (start 2 frames later than the Finder menu) |
| 2 | HUD glass re-measured from the capsule's own scale, no one-frame trail on appear | `volume-key.sh up` on the stub, grey 127, `mcap -k 1` region `950,30 330x95`, 3 runs (`13`). Glass width / glyph scale per frame (run 1): 132 ms **.912/.914**, 147 .919/.920, 164 .925/.928, 182 .935/.935, 199 .941/.942, 215 .948/.949, 232 .954/.956, 249 .958/.961, 265 .964/.966, 282 .967/.971, 298 .974/.975, 332 .980/.981, 348 .984/.984; runs 2 and 3 identical to .001. Same-frame gap -.004..0 (glass on whole pixels, glyph sub-pixel); against the glyph one frame earlier it would be +.005..+.008. Glass alpha leads the glyph's a little (.32 / .19 at 147 ms) | **confirmed** |
| 3 | CC Sound held lens (dark): fill mean 217.9 (Mac 221.9), ramp 229 236 233, shadow 98 95 91 88 88, lens 0.5 pt down | grey 127, knob held and dragged up off the lens, lens box at x 2197-2243 (#18 2196-2241) (`04`). #18's `cc.py`: outer box **47 x 40**, rim centres **46 x 38** (Mac 47 x 40 / 46 x 38; #18's capture reads 46 x 40 / 40 x 38); fill mean **217.6** (Mac 224.0, #18 212.7); per column **239 236 233 230 227 225 223 221 218 217 215 214 213 212 212 212 211 211 209 202 180** (Mac 246 245 241 238 235 231 229 226 224 221 220 219 218 217 217 216 216 216 216 211 192; -4 to -12, mean -6.4); fill left of the lens **252.6** (Mac 254, #18 246.8). `cc2.py` shadow every 2 px from the rim **98 95 91 88 88 89** (Mac 99 95 91 86 85 85). Box top / bottom **917 / 956** vs #18's 916 / 955: 1 px = 0.5 pt lower. The developer's "229 236 233 / Mac 232 240 236" is not reproduced by either of #18's rules (centre row every 3 px: 241 233 225 vs Mac 250 242 232). At the rim: fill rows lx-1 / lx **173 / 140** (Mac 231 / 170): our rim cuts the fill darker | **confirmed** for the level (217.6 vs 217.9 claimed) and shadow; ramp numbers not reproduced, shape closer than #18 |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Settings menus | Dock position pop-up close, dark x3, light x3 (`12`) | claim 1; fade start 58-63 ms after the click (Finder 26-30) |
| HUD | appear x3 dark over grey, light still | claim 2; light HUD fine |
| CC | dark held lens, light open (`14`) | claim 3; light CC unchanged from #18 |
| alerts | trash alert show x3, Cancel x3 (`08`) | `aglass.py`: **0 of 33-35 frames** with content past the glass, ratio mean .998 (min .992), peak glass **1.172**; dismiss alpha .31 .53 .70 .83 .91 .96 .99 1, rms **.0022 .0022 .0042** (#18's captures by this rule .0011-.0016, same values, timing jitter) |
| Finder menus | context menu close x3 | rms **.0033 .0035 .0034** at 26-30 ms shift (#18 .003-.004) |
| switches and sliders | held switch dark and light, Size slider held dark (`02`, `06`) | look as #18's |
| NC | light | photo widget shows `good.png` with `broken.png` first, as #18 |
| shell log | whole session (20 lines) | no binding loop, TypeError or ReferenceError; NC + StackArt broken.png x1 each (the skip), qt.svg x3, portal x2, brightnessctl missing (also in #17's log), libpng iCCP x7 from my grey image |
| tests | `node shell/tests/run.mjs` | **404 passed, 0 failed** |

## Per dimension

| dimension | j18 | j19 | change | reason |
|---|---|---|---|---|
| animation | 91.75 | **91.85** | +0.1 | [19 live] HUD glass and glyph in the same frame on appear |
| transition | 90.4 | **90.55** | +0.15 | [19 live] Settings pop-up menu close CA default, rms .002-.005 (was .046) |
| visual | 93.75 | 93.75 | 0 | nothing new |
| behaviour | 93.5 | 93.5 | 0 | nothing new |
| shape | 92.25 | **92.3** | +0.05 | CC held lens box and rim centres at the Mac's (47 x 40, 46 x 38) |
| colour | 95 | 95 | 0 | [18] |
| shadow | 94.5 | 94.5 | 0 | CC lens shadow as #18 (98 95 91 88 88) |
| refraction | 93.75 | **93.85** | +0.1 | CC fill level -6.4 vs the Mac (was -11.3); rim still cuts the fill darker |
| icon | 93.5 | 93.5 | 0 | [18] |
| font | 95 | 95 | 0 | [18] |
| rendering | 90.5 | **90.6** | +0.1 | HUD glass no longer a frame behind its content |
| sound | 90 | 90 | 0 | no change claimed |

Plain mean of the 12: 92.87 (j18 92.83).

## Per surface

| surface | weight | j18 | j19 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.25 | 94.25 | [18] |
| Dock | 14 | 94.25 | 94.25 | [18] |
| Window chrome | 14 | 92.5 | 92.5 | alert pop / dismiss as #18 |
| Finder | 13 | 92.5 | 92.5 | context menu close .003 as #18 |
| System Settings | 10 | 94.75 | **95** | pop-up button menu close on the CA-default curve (.002-.005); start 2 frames late |
| Control Center | 6 | 93.5 | **93.75** | held lens level 217.6 (Mac 224.0), box / rim at the Mac's; rim crossing still dark |
| NC + banners | 6 | 91.75 | 91.75 | [18] |
| Spotlight | 6 | 89.5 | 89.5 | [18] |
| Mission Control | 4 | 90.5 | 90.5 | [18] |
| Sounds | 4 | 90.25 | 90.25 | [18] |
| HUD | 3 | 90.5 | **90.75** | glass follows the capsule's scale in the same frame, first filmed |
| Cmd-Tab | 3 | 91 | 91 | [18] |
| Apps | 2 | 86 | 86 | [18] |
| Lock screen | 5 | 91.5 | 91.5 | [18] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [18] |

Weighted: 13 surfaces 9271.00 / 100 = 92.71. With the lock screen 9728.50 / 105 = 92.65. With Stage Manager
9441.00 / 102 = 92.56.

## Regressions

- None found.
- First measured: the Settings pop-up menu's fade starts 58-63 ms after the click, the Finder context menu's 26-30 ms
  (same click path through `vptr`). Whether the Mac closes on mouse-down: belum dicek.

Defects still open: CC held lens rim cuts the fill (173 / 140 vs Mac 231 / 170) and the level is -6.4; preview dark
right end 99 (Mac 110); switch outer rim +9; alert rise 1 frame longer than the Mac's; Spotlight dark field in light
mode (not compared); HUD appear never compared with a Mac series.

## The next 10 changes, by gain

Repo only:

1. CC held lens: the rim where it crosses the fill (lx-1 / lx 173 / 140 -> 231 / 170) and the last 6 of level (+0.02).
2. Settings pop-up menu: start the close on the same event as the Finder menu (58-63 -> 26-30 ms) (+0.01).
3. Preview: dark right end 99 -> 110, light end's inner ramp 244 240 -> 238 236 (+0.01, [18]).
4. Finder group-by pull-down items drawn disabled (+0.01, belum dicek vs Mac, [18]).

Needs the Mac:

5. Alert at 60-120 fps over grey (ours 1 rising frame longer) (+0.02).
6. Spotlight in light mode over a white window (+0.03).
7. A scaled mode capture ("More Space") (+0.05).
8. HUD appear at 60 fps (scale 0.9 -> 1 and glass alpha against content alpha) (+0.01).
9. A dark held switch strip (+0.01).
10. Settings pop-up button menu close at 60 fps, including when the fade starts after the click (+0.01).

## Reachable ceiling

About 92.75 with the repo's data (items 1-4). About 92.9-93.1 with the Mac captures. 95 is not reachable on this stack
for judge #7's reasons (about 3 points). No repo-only item above +0.02 is left.

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91.85 | MC 4-window exit, stack fan / grid never filmed, alert rise 1 frame long, HUD appear not compared | Mac 60-120 fps: MC, stack, alert, HUD |
| liquid glass | refraction + visual | 93.85 | CC rim over the fill, no glass in third-party windows, Spotlight light field | repo 1; Mac Spotlight light |
| glass refraction | refraction | 93.85 | CC fill -6.4 and rim crossing; preview dark right end -11; switch outer rim +9 | repo 1, 3 |
| shadows | shadow | 94.5 | CC lens shadow 2-3 above the Mac's at the deepest; banner and module shadows never compared | Mac stills of banner and module shadows |
| depth | shadow + rendering | 93.85 | alert and HUD glass now in step with content | none from the repo |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93.25 | scroll pocket (j14) | Mac Finder scrolled under the toolbar |
| sound | sound | 90 | output latency; Empty Trash / poof not fired | Mac audio + screen capture |
| icon | icon | 93.5 | rtf / generic / app documents | Mac renders of document pages |
| emoji | (direct) | 94.5 | emoji in text never compared | Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 91 | no Mac scaled-mode capture | Mac "More Space" capture |

## Crops (`reference/judge-95-19/`)

`02-held-switch-dark-ours-j18.png` (ours left, #18 right), `04-cc-sound-held-lens-dark-grey127-mac-ours-j18.png` (Mac,
ours, #18; x4), `06-settings-size-slider-held-dark-ours-top-j18-bottom.png`, `08-alert-pop-frames-211-294ms-ours.png`,
`12-settings-popup-close-frames-ca-default-ours.png` (frames -19, 14, 49, 82, 115, 149 ms), `13-hud-appear-frames-132-
697ms-ours.png` (132, 164, 199, 232, 265, 348, 697 ms), `14-cc-nc-light-grey127-ours.png`.
