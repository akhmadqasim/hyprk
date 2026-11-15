# Motion audit: every Mac motion series in the repo against ours (2026-11-14)

Headless session (`scripts/smoke.sh`, `HYPRK_HEADLESS=1`, 2560 x 1664 at scale 2, light: no dark series differs, the
menu probe's dark and light alpha are identical), scratch HOME, private bus. Ours captured with
`scripts/motion-capture/mcap` (presentation-time stamped frames) with the same trigger as the Mac series where the repo
has one, compared with `mcap.py compare` (rms in value at the best time shift). Model fits: per-frame least squares
of a curve, a duration and a start shift (scratch `fit.py`). "Screen" = measured on ours; "model" = our code's curve
against the Mac series (used where the screen metric cannot be read the same way as the Mac's).

## Mac series in the repo

| source | surface | what moves | frames |
|---|---|---|---|
| `live/menu-motion-{dark,light}.json` | context menu close | window alpha, probe in-process 120 Hz (model values) | 14 at 60 Hz |
| `live/video-motion-1.json` (60 fps, `tools/vidmotion.py`: bbox + remaining share) | popover show / close, sheet in / out, plain window, alert show | outline, pixel share | 9-25 each |
| `live/video-motion-2.json` | document window, alertPanel window, alert show / dismiss, minimise / restore, menu bar | same | 7-40 each |
| `live/popover-motion-*.json`, `alert-motion-*.json` | popover, alert | window frame / alpha: no window-level change (WindowServer animates), so no series | - |
| `live/controls/controls-press-light.json` (120 Hz) | switch, slider, segmented, push, checkbox press | layer frames, lens share | fitted in `ui/HyprK/Tokens.qml` motion (rms .0002-.0003) |
| `live/nc/motion.json`, `screens/27.2.1/nc/*-strip.png` | NC open / close, banner in / out, push, clear | leading edge | MOTION-MEASURED.md sessions 4, 19, 20 |
| `live/dock/*.json`, `live/verify/A` | Dock bounce, attention, magnification, label, autohide, slots, HUD | edge, alpha | MOTION-MEASURED.md |
| `MAC-ANSWERS.md` R2, #42, Q-menubar-23/24, Q-panels-26, Q-finder-26, Q-dock-16 | windows, genie, zoom, Mission Control, Cmd-Tab, submenu, menu blink, Spotlight list, Quick Look | alpha / share | MOTION-MEASURED.md |
| 23.09.23 recording (GLASS-INTERACTION.md) | toolbar press / release, slider drag | capsule brightness | MOTION-MEASURED.md sessions 15-18 |
| `screens/27.2.1/lock/*-strip.png` | lock shake, minute change | x per frame | MOTION-MEASURED.md session 16 |

The repo's other per-frame comparisons (MOTION-MEASURED.md sessions 1-20) were not redone: they matched within a frame
or 2 % and nothing they cover was touched. This audit covers the series that had never been put against ours on
screen: the menu probe, the popover, the alert and the sheet.

## Ranked by error (before -> after)

| # | motion | Mac | ours before | after | change |
|---|---|---|---|---|---|
| 1 | popover close (`ui/HyprK/Popover.qml`; the emoji picker shares it) | remaining .853 .593 .348 .176 .076 .036 .021 .010 .004 0: CA "default" (0.25, 0.1, 0.25, 1) over 128 ms, rms .009 | out-quad 180 ms on Qt's timer: screen (emoji picker close) rms **.085-.092**, 3 runs, one skipped value | **.013-.018** (3 runs); Finder tag popover .035-.037 (3 runs, see remaining) | `Tokens.panel.popoverFadeOut` 128, `popoverFadeCurve`; FrameAnim in Popover.qml and EmojiPicker.qml |
| 2 | app menu close (Finder / Settings context and pull-down menus: the plugin's popup fade, `plugin/src/PopupGlass.cpp`; see "Follow-up" below) | menu probe alpha .8605 .7115 .5532 .4154 .305 .2188 .1521 .1013 .0631 .0355 .0167 .0053 .0004 0: CA "default" over 236 ms, rms **.0004** | `macOut` (0.2, 0.9, 0.3, 1) 0.2 s: 41 % gone in the first frame; screen rms **.082-.086** | claimed .014-.015, re-measured **.053-.055** (3 runs; judge #17 .017-.030); after the follow-up **.0035-.0071** (3 runs) | follow-up: `plugin/src/PopupGlass.cpp` (fadePopupsOut does not drive these menus) |
| 3 | alert dismiss (`shell/components/AlertDialog.qml`, `ui/HyprK/AlertPanel.qml`) | remaining .489 .312 .180 .097 .047 .017 0: out-cubic 154 ms rms .003 | out-quad 100 ms: model .030, screen **.045-.046** (2 runs) | screen **.020-.029** (3 runs) | `Theme.alert.fadeOut` 154 + `fadeEase` OutCubic; `Tokens.panel.alertFadeOut` / `alertFadeEase` |
| 4 | alert show, scale | outline / final: .043 .071 .106 .149 .206 .277 .362 .461 .582 .723 .840 1.011 1.170 1.145 1.117 1.096 1.071 1.050 1.032 1.018 1.004 1 | in-quad .04 -> 1.15 in 200 ms, out-quad to 1 in 170: model rms **.018** | 1.17 / 214 / 180: model **.0055** | `Theme.alert.popPeak / popRise / popSettle`, `Tokens.panel.alertPop*` |
| 5 | alert show, shape in the first frames | the whole window scales (corners and shadow with it) | the glass region kept r 26 at any scale: a 26 pt circle round the 10-40 pt body for the first 4-5 frames (screen, 2 runs) | rounded rect at the alert's scale (screen) | `shell/components/Glass.qml`: region radius x the item's scale on screen (`_regionScale`) |
| 6 | shell menu close (`MenuDropdown.qml`) | menu probe alpha (as 2) | out-quad 185 ms: screen rms **.0155** (3 runs), 3 frames short | **.0037-.0056** (3 runs) | `Theme.anim.menuFadeOut` 236 + `menuFadeCurve` (CA default); also fits the Q-menubar-24 activation series (rms .003) |
| 7 | sheet in / out (`ui/HyprK/Sheet.qml`) | remaining .97 .915 ... 0 / .839 .78 ... 0: linear 258 ms (rms .008 / .011) | linear 270 / 250: model .015 / .015 | not changed (within 2 %) | - |
| 8 | popover show (`Popover.qml` spring) | outline .125 .25 .397 .529 .654 .739 .816 .879 .930 .963 .985 1 1.007 1.015 ... | spring 0.25 / 0.9 from 12.5 %: model .010 | not changed (best fit 0.28 / 0.82: .0084, the gain is under one pixel of the 272 px outline) | - |

Why the old values were off: the alert / popover / menu durations came from `LIVE-27.2.1.md`'s eyeballed summary
("about 0.1 s", "0.15 to 0.2 s", "OutQuad over 0.2 s within 0.03") instead of a per-frame fit; the probe's menu alpha
(exact model values, never used before) settles it at CA's default curve. The 1.15 alert peak rested on the guess that
the outline's shadow inflates the scale; the whole window scales on the Mac, and an unscaled shadow would make the
outline ratio larger than the scale, not smaller, so 1.17 is the reading.

## Remaining

- Alert show: the drop shadow does not scale with the alert (the plugin draws the `hyprk-overlay` recipe's fixed
  24 pt shadow for any size), so the first frames show a 40-50 pt halo round a 10-40 pt body; on the Mac it scales.
  Needs a per-shape shadow scale in plugin/ (not done here). The same shadow makes an outline metric unusable on ours,
  so the pop is compared by model only. **Done since** ("Alert, Round R3.1", dismiss blur / shadow): the shadow scales
  with the alert, shadow reach / scale rms vs the Mac 41.5 -> 2.8 pt below.
- Alert dismiss: ours shows a first frame at .27 of the change, the Mac's first frame is already .51 (rms .020-.029):
  either the Mac's fade starts a frame before its first composited frame or its curve is steeper at the start; one
  recording cannot tell.
- Finder tag popover close: the fade has one short step (.35 .49 .83 at 30 / 47 / 65 ms, 3 of 3): Finder's window
  presents a frame late, not the curve (the emoji picker with the same curve has none). Not traced.
- Not re-measured here, carried from MOTION-MEASURED.md: Mission Control 4-window exit (needs the Mac's 4-window
  recording), HUD dismiss tail, stack fan / grid (no Mac capture), Spotlight list's repeated first frame.

## What a Mac capture would settle

- The alert at 60-120 fps over a flat grey wallpaper (shadow and body separable): the true scale curve and whether
  the shadow scales; the dismiss's first frame relative to the click.
- A popover close and an app menu close (Finder) over grey, 60 fps, to confirm the CA default curves seen in the
  probe and the video on the same surfaces as ours.

## Files changed

`shell/Theme.qml` (alert pop / fade, menuFadeOut / menuFadeCurve), `shell/modules/MenuDropdown.qml`,
`shell/components/AlertDialog.qml`, `shell/components/Glass.qml`, `shell/modules/EmojiPicker.qml`,
`ui/HyprK/Tokens.qml` (panel motion), `ui/HyprK/AlertPanel.qml`, `ui/HyprK/Popover.qml`, `config/hypr/hyprland.lua`
(fadePopupsOut; backup in ~/backups/hyprk). No plugin change, no rebuild. Tests: shell 400, finder 33, settings 52,
ui qml 96, all passing.

## Follow-up (same day, after judge #17)

- Alert pop, content past its glass 165-265 ms (JUDGE-95-17 3f). Cause: `AlertDialog.qml` re-measured its glass from
  `onPopChanged`, which ran before the `Scale { xScale: root.pop }` binding updated, so `Glass.placeHole()` mapped the
  previous frame's scale: the glass was exactly one frame behind the content (mcap over grey 127, glass / content scale
  .59 / .71, .72 / .84, .86 / 1.0, 1.0 / 1.15). Not the region's transport: Quickshell sends the blur region from the
  polish that `FrameClock.flush()` runs in the tick, and the plugin's RegionQueue pairs it with that commit. Fix: the
  re-measure hangs on the Scale's own `onYScaleChanged`. After: 3 runs x 37 frames, no default-button pixel outside the
  glass's box in any frame (before: 11 of 37), glass width / button width 1.000 +- .012 in every frame from the 2nd, peak
  1.169 at 265 ms. `HudWindow.qml` (`onShownnessChanged: glassMoved()`, scale bound to shownness) has the same shape:
  not measured.
- Finder context menu close. Cause: two fades on top of each other. A Qt popup destroys its surface, so Hyprland's
  `fadePopupsOut` snapshot is empty, but with `decoration:blur:popups` the fadeout still drew a blur over the popup's box
  (strength sqrt(alpha)) above the window, over the plugin's own fade (OutQuad 185 ms, glass dematerializing): the menu
  text turned into a blur from the first closing frame (mcap: interior .21 .27 .34 .43 ...; .00 .14 .27 .39 with
  fadePopupsOut off). Our earlier `fadePopupsOut` tuning only changed that blur's decay. Fix in the plugin: Hyprland's
  popup fadeout of a `popup_classes` window is cancelled when the plugin sees the popup go; the plugin fades the last
  buffer and its glass at one alpha (the Mac's window alpha; dematerializing lagged the content, .04 .13) on CA default
  over 236 ms, the first frame without the popup one refresh in (it repeated the open frame). Screen, 3 runs: interior
  .055 .167 .322 .479 .610 .717 .797 .861 .909 .945 .971 .986 .998 1, **rms .0035-.0071** at a 10 ms shift (before
  .053-.055 in this session). `fadePopupsOut` in `config/hypr/hyprland.lua` stays for other apps' popups.
- Files: `shell/components/AlertDialog.qml`, `plugin/src/PopupGlass.cpp`, `plugin/README.md`, `finder/qml/PopupMenu.qml`
  (comment), `config/hypr/hyprland.lua` (comment; backup in ~/backups/hyprk). Plugin built in a scratch dir and tested
  with `HYPRK_GLASS_SO`: **plugin/build needs a rebuild**. Tests: shell 403, finder 33, settings 52, ui qml 96, plugin
  ctest 2, all passing.

## Settings pop-up button menu: open, choose, close (judge #19 claim 1 follow-up and R3.5, 2026-11-14)

Mac: `screens/27.2.1/controls/popup-menu-open-close-{light,dark}.mov` (R3.5, 60 fps VFR, read by pts; Appearance >
Text highlight colour, Automatic re-chosen). Ours: Desktop & Dock "Dock position", headless scale 2, `mcap` region
`780,150 260x250`, alpha over `--sub 10,10,190,215` against the menu probe (`.1395 ... 1`), `vptr` clicks.

| | Mac (R3.5) | ours before | ours after |
|---|---|---|---|
| open | pressed look 3 (dark) / 4 (light) frames, then the menu complete in one frame | menu and pressed look in the same frame | pressed look 3 frames, menu complete in the 4th (5 runs) |
| choose | highlight off 4 frames, on 3, fade from the 7th frame after the off | no blink, fade at once | off 4, on 3, fade from the 7th (4 runs) |
| fade after choose | .153 .310 .471 .607 .714 ... (light), .147 .300 .459 .597 ... (dark): CA default 232 / 234 ms, rms .0021 / .0018, curve 1.9 frames in at its first frame | - | .167 .320 .476 .611 .715 ...: per frame rms **.0054** light, **.0092** dark |
| close by a click outside (start) | no Mac data; reference Finder's menu, 26-30 ms (judge #19) | best shift **59-61.5 ms** (5 runs; judge #19 58-63) | **26-27.5 ms** in 11 of 12 runs (light 2 of 3, dark 6 of 6, click on the button 2 of 2); 44 ms once (light, the click landed after the compositor took the frame) |
| close curve | CA default | rms .0023-.0045 | rms .0019-.0022 light, .0010-.0018 dark |
| pressed look after the fade | goes 33 (light) / 83 (dark) ms after the fade's last frame | at the fade's end | 50 ms after the curve's end |

Cause of the late start (WAYLAND_DEBUG on the client + mcap, one run): click 1.0 ms, Qt closes the popup at once, the
frames committed at 2.3 and 17.0 ms still have opacity 1, the first value (.95) is committed at 33.1 and shown at 47.3.
The exit `Transition`'s NumberAnimation is stepped by the threaded render loop's driver after each frame's sync, so the
first two frames after the start carry the start value. Fix: the fade runs on the window's frames (HyprK FrameClock;
frame k shows the curve k + lead intervals in: lead 1 after a click outside, lead 2 after the blink, as R3.5 shows), the
exit Transition only holds the menu up (PauseAnimation menuFadeOut + 50). One run right after a light -> dark switch
(the pointer was not parked, slow curve) is left out.

Files: `ui/HyprK/Popup.qml` (open pause, blink, FrameClock fade, a press that closes the menu does not reopen it),
`ui/HyprK/Tokens.qml` (`panel.menuOpenDelay` 42, `menuBlinkOff` 58, `menuBlinkOn` 42), `ui/tests/tst_controls.qml`
(test_popup_keeps_binding waits for the open and the blink). Tests: ui qml 96, settings 52, shell 400 + 3 failing in
the status modules (another agent's work in progress, not these files).

Left (exact next steps):
- R3.5 hover and pressed look (not built): on the Mac the whole button gets a pill on hover (pointer over it) and a
  darker one when pressed, and the chevron's own circle is not drawn then. Pill 24 pt tall (rows 216-263 of the 2x
  clip), from x 254 px (left edge) to about 519 px at the top row, fill light 225 hover / 200 pressed over the 246 card,
  dark 48 / 66 over 34. Still to measure: its exact left / right edges against the button frame and its radius (trace
  rows 214-266 of frames 49 / 50, scratch `mac/` arrays), then draw it in Popup.qml (Rectangle under the label, hover
  from the MouseArea) and compare with mcap. After the menu closes the pill is gone even with the pointer still over
  the button (light frame 4.500 s).
- The fade length: the clips fit 232 / 234 ms, ours keeps the probe's 236 (rms .0004 on the probe); not changed.
- A Mac click-outside close has not been filmed (R3.5 closes by choosing): the start for that path is still judged
  against Finder's menu.

## HUD, Round R3.4 (volume HUD appear, hold, fade; 2026-11-14, interrupted, no code changed yet)

Mac: `screens/27.2.1/panels/hud-volume-appear-grey-dark.mov` (commit cdbf213 on origin, not yet in this worktree; read
with `git show cdbf213:...`), dark, grey 127, one Volume Up, 81 -> 88 (13/16 -> 14/16). 77 frames, pts from `ffprobe
-show_frames` (60 fps base). Ours: headless session (scale 2, dark, grey 127 wallpaper, stub sink set to 0.8125, then
`volume-key.sh up 16`), `mcap -g 800,34,480,200 -k 1`, same 960x400 crop (capsule at the same pixels: x 325..940,
y 20..151 on both). Scripts in the agent's scratch (`py/hudm.py`, `py/ffit.py`), not in the repo.
Metrics per frame: scale s about the capsule centre (least squares of the frame change against the final frame warped by
s, free gains for glass and content), content alpha `ac` (bar dashes over the glass, / final), glass `ag` (interior
darkening, / final, 8-10 grey levels so +-0.1 per frame).

Mac results:
- Scale follows the decoded springs exactly. Appear interpolatingSpring(2, 300, 50) from t0 0.582 s (rms .0006 in s,
  0.901 -> 1); hide spring(0.48669, 1) from 1.582 s (rms .0006, 1 -> 0.90). First composited frame 18 ms after t0
  (ours: 18 ms too).
- Hold: hide start - appear start **1.000 s** (`short` timeout 1.0 s; both go through the same hosting delay).
- Bar: **no fill animation on a fresh HUD**. From the first visible frame the fill ends at 14/16 (fraction .877 in
  every frame). Ours snaps it too: matches.
- Content alpha is NOT the spring value o. It fits **ac = o x clamp((o - 0.25) / 0.51, 0, 1)** (rms .0064, max .021,
  appear and hide together; o from the fitted springs). o^1 rms .143, o^2 .075. So nothing shows until o 0.25
  (~70 ms into the appear), and the fade is visually over at o 0.25 (~0.2 s after the hide starts) although the
  window stays until 0.487 s. Code: BannerSlider.body is `content.opacity(o)._glassEffect(.controlCenter.mix(with:
  .identity, by: 1 - o), in: Capsule)` (decomp/SystemBannerUI-hud.c 587-605); the extra factor clamp(2o - 0.5) is
  inferred to come from the glass mix (not decoded).
- Glass darkening fits o^2 (rms .043) or o x clamp((o - 0.14) / 0.79) (.025), appear and hide alike, after taking out a
  step: while animating the interior is only .89 of its static value (jumps to 1.0 at t0 + 0.55 s and drops back to .88
  in the first hide frame). The top rim grows later still (.78 at o .96, full only at t0 + 0.7 s): not modelled.
- Fade: last changed frame 2.083 s = hide start + 0.50 s (window removal at 0.48669 + one frame). Visible content ends
  at hide start + 0.20 s.

Ours before (3 runs b2-b4, current HudWindow.qml): scale on the same springs (rms .0005); content ac = o (rms .009);
glass = o on appear, o^2 on hide; hold 0.985 / 1.002 s (b2 / b3; b4 not analysed); first frame 18 ms after the spring
start. Against the Mac's ac mapping ours is rms about .14: content visible from the first frame (ac .21 at +68 ms,
Mac .00) and the fade visibly lasts 0.4 s instead of 0.2 s. The stub path adds ~110 ms from `volume-key.sh` to
`Hud.show()` (file watch); one cold run took 1.0 s (not traced).

Next steps (not done):
1. `shell/modules/HudWindow.qml`: content `opacity: shownness * clamp((shownness - 0.25) / 0.51, 0, 1)` (Hud.motion
   tokens contentFrom 0.25, contentSpan 0.51, source this section); `glassAlpha: shownness * shownness` both ways (drop
   the appear-only linear glass). Optionally a pure helper in `shell/lib/hud.js` + a test in `shell/tests/run.mjs`.
2. Re-capture 3 runs the same way and compare ac / ag / s series with the Mac (target ac rms < .02).
3. Hold: keep hideAfter 1050 / showDelay 50 unless 3 runs show a bias (0.985-1.002 vs Mac 1.000).

Done afterwards (main session, 17:40): step 1 for the content only (`Hud.motion.contentFrom` 0.25 / `contentSpan` 0.51,
HudWindow.qml content opacity). The glass mapping was left as it was (o appearing, o^2 hiding): R3.4's glass signal is
8-10 grey levels (o^2 rms .043) and the earlier appear fit (verify/A hud-appear-fit.json) ties o and o^2. A headless
run shows the HUD at full content while held; the per-frame recapture (step 2) is still to do.

Step 2 and the glass / hold decision (HUD agent, 17:48-18:05). Same session setup (scale 2, dark, grey 127, stub sink at
13/16, one step up), mcap `-g 800,34,480,200 -k 1`, metrics as above, Mac and ours aligned at each one's fitted spring
starts (appear 0..0.6 s, hide 0..0.3 s, on the Mac's frames). Trigger `volume-key.sh up 16` (runs a, g) or
`qs ipc --pid <qs> call hud volume 0.875` (runs i, k, m, n: IPC round trip 20 ms, so show() is known to a few ms; the
stub file watch adds 0.08-0.95 s before show(), so it cannot time the delay).

| runs | code | ac rms vs Mac | ag rms vs Mac | hold (Mac 1.000) |
|---|---|---|---|---|
| b2 | before (content o, glass o / o^2, delay 50) | .152 | .160 | .985 |
| a1 a2 | content o x clamp((o - .25) / .51) (main session) | .0127 .0122 | .161 .161 | .970 1.004 |
| g1 g2 g3 | + glass o^2 both ways | .0121 .0104 .0099 | .0592 .0589 .0584 | .986 .970 .970 |
| i1 i2 i3 (IPC) | same, delay 50 | .0108 .0104 .0108 | .0592 .0588 .0591 | .969 .970 .969; spring 82 ms after show() |
| k1-3 / j2-3 / m1-3 (IPC) | delay 34 / 18 / 26 | - | - | .985 1.002 .986 / 1.018 1.019 / 1.003 .986 (1.019, a reload in that set) |
| n1 n2 n3 (IPC) | final: delay 26 | .0101 .0116 .0109 | .0591 .0590 .0591 | 1.019 1.005 .988 |

- Content: **ac rms .010-.012** on screen (target < .02; ours against the model f(o) .005-.007). Before .152.
- Glass: ours' interior darkening follows glassAlpha linearly (rms .013-.017 in every run), so the mappings were judged on
  the Mac data. Mac appear: o .177, o^2 .054, o x clamp((o - .14) / .79) .074 (raw); with the animating-glass step taken
  out (/ .89): .147 / .059 / .046. Hide: o^2 .050 (= current). Relay #18's appear alpha fits o^2 at .017 (MAC-ANSWERS
  REA section 1); verify/A's tie mixes content and glass. Chosen **o^2 both ways** (the clamp form wins only with the
  .89 normalisation and is within the 8-10 level noise; o^2 also removes the glass jump when a press brings back a hiding
  HUD). On screen **ag rms .160 -> .058-.059**, all 3 runs.
- Hold: with delay 50 the appear spring starts 82 ms after show() (the Timer fires on a frame and the spring starts a
  frame later), hide 1.051 s after show(): hold .969 x3, 31 ms short. `Hud.motion.showDelay` 50 -> **26**: holds .986-1.019
  over 6 runs (mean 1.003), one-frame quantisation either way. hideAfter 1050 unchanged (show() -> hide 1.051-1.052).
- Scale: both on the decoded springs at rms .0005-.0006, nothing to change. Bar: no fill animation on either.
- Left: ours' glass has a step at low opacity: interior 0 at o^2 ~.04, then a floor of ~.12 from o^2 .08 to .14 (Mac
  .02-.11 there), the main part of the remaining ag .059: the plugin's response to a low glass opacity (marker
  resolution is 1/306, not it), not traced, plugin/ is not this agent's. The Mac's glass is ~11 % lighter while animating
  than when settled (jumps at t0 + 0.55 s): not modelled. The top rim grows later than the interior (not modelled). Side
  by side strip in scratch only (`agent-hud/side.png`).
- Files: `shell/modules/HudWindow.qml` (glassAlpha o^2, `hiding` removed, comments), `shell/services/Hud.qml`
  (showDelay 26 + source). Tests: shell 403, ui qml 98, all passing.

### Round R5.1 / glass while animating (HUD agent 2, 2026-11-14 18:47-19:15)

Same session setup (scale 2, dark, grey 127, scratch HOME), trigger `qs ipc --pid <qs> call hud volume 0.875` from 13/16.
Glass and content: mcap `-g 800,34,480,200 -k 1` and the R3.4 scripts (`agent-hud/py/hudm.py`, `ffit.py`, `cmp.py`, Mac and
ours aligned at each one's fitted spring starts). Timing: mcap `-g 960,0,320,120 -k 2` with the criteria of the sound
agent's `hudt.py` (pill: > 3 px over 4 levels in the Control Center item; HUD: > 20 px over 4 levels). Scripts in scratch
`agent-hg/py` (not in the repo).

1. **Glass while animating.** Mac R3.4 rows (x 450..850 px, levels against the empty frame): from 1.1167 s (t0 + .535,
   o .9892) to 1.1333 (t0 + .551, o .9909) the rows under the bar (96..136 px, flat backdrop 115) go from -8 to -10 in one
   frame; the rows above the bar (34..80, backdrop 109-114) stay at -7..-9; the first hide frame (o .977) is back at -8.
   The top rim row (20 px) goes +127.9 -> +128.5 across the step and reaches +133.3 only at rest: no step there.
   So it is **not the mix**: `.controlCenter.mix(with: .identity, by: 1 - o)` is continuous and 1 - o = .01 cannot move 2
   levels in one frame. It is a change of state when o crosses about .99, both ways (inferred: the glass is drawn another
   way once the mix is at identity; that render path is not decoded). The critical spring (omega 12.25) reaches
   1 - o = .01 at 0.542 s, inside the Mac's .535-.551 window.
   Model, HUD only: glass alpha o^2 x **.925 while o < .99**, o^2 at rest (`Hud.motion.glassRestFrom` .99,
   `glassAnimating` .925). Fit over the Mac's 58 animated frames, appear and hide: o^2 alone rms .048, with the step .026
   (threshold .98: .034, .995: .032).
   Ours on screen, interior `ag` rms against the Mac: before (b2) **.059** (R3.4 n1-n3 .059) -> after (a1, a2) **.035,
   .035** (a third run, b1, .050: another agent's edit reloaded the shell during it, scale fit .0010). Content `ac` .010
   (unchanged), hold b2 1.003, a1 1.019, a2 .985 s (Mac 1.000).
   Rim: the Mac's is a function of o, not a time lag (.78 at o .963 appearing; .853 at o .977 hiding, .868 at .978
   appearing). Ours there .74 before, .68 after; rim rms against the Mac .075 before and after. Not modelled: the plugin
   draws the rim with the same alpha as the interior, and no QML input reaches a separate rim curve.
2. **Timing chain (pill -> HUD).** Ours (IPC, 3 runs): pill 31.3-32.2 ms after the call, first HUD frame 164.8-165.7:
   **pill -> HUD 133.4-133.5 ms** (volume-key path, 2 runs: 100.1, 116.7; its file watch moves the pill, see SOUND-REA
   section 7). Mac `sound/volume-pop.mov` at the same crop (x 2240..2880, y 0..240 px, area-scaled to 1 per pt): pill
   1.1833 s, a frame at 1.2333 with no HUD change (max 4), first HUD frame 1.2500 (613 px over 4, max 9), 1.2667 max 21,
   1.2833 max 38. The R3.4 clip at the same scale: t0 + .018 max 6, + .035 max 13, + .051 max 22, + .068 max 32, so
   volume-pop's spring starts at 1.216-1.232 s: **Mac pill -> spring start 32-49 ms**. Ours: fitted t0 62-95 ms after
   the call (4 runs, mean 76), so **pill -> spring start 30-63 ms, mean 44**. The delay already matches: `showDelay` 26
   and `hideAfter` 1050 kept (hold 1.000 within a frame).
   The 67 vs 133 ms is how faint the first frames are, not the delay. At the same spring time the Mac is brighter: at
   t0 + .035 (o .068) up to 14 levels in y 52..88 px, x 355..910 (the glyph and the bar's right end; the dashes at x
   450..850 stay within 4). Ours reaches 9 levels at t0 + .087 and 21 at + .121 (Mac 22 at + .051): its content is held
   out until o .25 (`contentFrom`, fitted on the dashes) and its glass is o^2. A 66 ms shorter delay would start our
   spring before the Mac's. Closing this needs the Mac's early faint content measured per element (glyph vs bar end).
3. **Light.** `hud-vol-light.png` and `hud-vol-dark.png` (blue desktop (69,83,206), 7/16) are the same within 3 levels.
   Ours at rest on a flat (69,83,206) wallpaper, level .4375, light and dark alike: top rim rows (171,197,255)
   (128,149,253) (88,107,239), Mac (171,196,255) (127,149,252) (88,107,239); interior (68,85,232) on both; bottom rows
   (89,107,239) (127,149,252), Mac (89,107,239) (128,150,253); filled dashes and glyph (255,255,255) on both. Glass at rest
   matches within 1 level. **Empty dashes do not**: Mac (96,113,255) = interior + 28 on every channel, clipped
   (plus-lighter); ours (98,112,236) = white at .16 (`Hud.metrics.empty`). About 6 levels apart over grey 127. Not
   changed here. Change: draw the empty `Bar` additively, premultiplied colour 28/255 with alpha 0 (Qt's and the
   compositor's premultiplied blend then add it to what lies under), which a `Rectangle` cannot output: a
   `layer.effect` ShaderEffect writing `vec4(vec3(28.0 / 255.0) * texture(source, uv).a * qt_Opacity, 0.0)`.
  **Applied** by the main session at 19:10 with shell/shaders/plustext.frag (the same output), `Hud.metrics.emptyLift`
  28/255, HudWindow.qml empty `Bar`. Headless check over the default wallpaper, held HUD: empty dash (109,182,199)
  against the glass 14 px above (74,148,170): +35 +34 +29 (that row is not the same glass; the old white .16 would give
  +29 +17 +14). Not yet on the Mac's flat (69,83,206).
- Files: `shell/modules/HudWindow.qml` 54-61 (glassAlpha step), `shell/services/Hud.qml` 39-46 (showDelay source),
  59-65 (`glassRestFrom`, `glassAnimating`). Tests: shell 403, ui qml 98, all passing.

### Round J20 (judge #20 item 1: the first visible frame comes late; 2026-11-14 21:00-22:10)

Judge #20: pop -> first HUD frame 57-63 ms (Mac 18), pill -> HUD 100-119 (Mac 67). Mac: R3.4 `hud-volume-appear-grey-dark`,
R6.2 `-grey-light`, `-blue-dark` (VFR, pts), `sound/volume-pop.mov`. Ours: headless session (scale 2, dark and light over
grey 127, stub sink, `HYPRK_MUTE=1`, `HYPRK_SOUND_LOG`), mcap `-g 800,34,480,200 -k 1` (the Mac's 960 x 400 crop) for the
look, `-g 960,0,320,120 -k 1` (pill + HUD) with the sound agent's `keytime.py` (Shift+Volume Up through `volume-key.sh`)
for the chain. Scripts in scratch `agent-hs/py` (`elfit3.py`, `gfit3.py`, `cmp3.py`, `t0fit.py`), not in the repo.

1. **The HUD scales about its top, not its centre.** Per frame, frame - backdrop = gains x (glass, glyph, bar of the rest
   frame) warped by s about an anchor. About the capsule's centre (R3.4's model) the Mac frames leave rms 12-13 levels
   mid-appear; the dashes sit 4-8 px above where that model puts them (rows 76-83 at s .935, model 82-89). A free
   vertical shift for glass and content gives the same shift for both, -87 px x (1 - s) at 2x; a scan of the anchor
   (crop y -12 / -6 / 0 / +6 px: mid-appear rms 2.71 / 2.05 / 1.74 / 2.12) puts it at y 0 +- 1 px = **10 pt above the
   capsule's top** (the banner's top edge with its `_topMargin` 10), x at the capsule's centre (width mid 632.5 in every
   frame). Frame rms 1.27-1.32 over the three clips. `Hud.motion.anchorAbove` 10, HudWindow's `scaled` item
   (transformOrigin Top, the capsule `anchorAbove` below its top; the window 1 pt taller at the top, `room`).
2. **The content is the spring value.** With that registration (o from the springs fitted on s: t0 / hold 0.582 / 1.000,
   0.448 / 1.020, 0.482 / 1.020 s), three clips, appear and hide: glyph o rms .013 (o^1.06 .008), bar o .023 (o^0.90
   .011); R3.4's o x clamp((o - .25) / .51) .111 / .139. That clamp came from dash rows sampled about the centre, under
   the early dashes: no content lag exists. The Mac's first frame (t0 + 18 ms): glyph .018, bar .030 (+4 levels). Content
   `opacity: win.shownness` (the decoded `content.opacity(o)`); `contentFrom` / `contentSpan` removed.
3. **Glass.** Same registration, whole glass gain: o^2 rms .0198, o^2 x .97 below o .99 .0202, R5.1's x .925 .0349 (R5.1
   fitted it about the centre). On screen (3 runs against the R3.4 clip, the plugin draws .95-.98 of the asked alpha
   between .5 and .95): o^2 .021, x .97 .028, x .925 .046. `glassAlpha: o^2`; `glassRestFrom` / `glassAnimating` removed.
4. **Ours against the Mac** (R3.4 clip, each aligned at its own spring start, rms):

   | | first frame | appear glyph / bar / glass | hide glyph / bar / glass | s | hold |
   |---|---|---|---|---|---|
   | Mac | t0 + 18 ms, glyph .018 bar .030 | | | .0009 (spring) | 1.000 |
   | before (2 IPC runs, centre model for ours) | t0 + 60 ms (o .2, glass .037) | .092-.094 / .104-.107 / .027-.028 | .144 / .169 / .017-.018 | .003-.005 | .978-.993 |
   | after, dark (3 IPC runs) | t0 + 14.5-17.5, glyph .023 bar .030 | .018-.019 / .014-.015 / .027-.029 | .014-.015 / .009-.010 / .019-.021 | .0006-.0008 | 1.018 .984 .998 |
   | after, light vs `-grey-light` (2) | t0 + 16.5 | .020-.024 / .015-.019 / .035-.037 | .014-.016 / .009-.010 / .019-.020 | .0006-.0009 | 1.000 .985 |

   IPC call -> first changed frame 132 ms before, 82 after (same session).
5. **Pop and pill.** Mac `volume-pop.mov`: pill 1.1833 s; the HUD's spring start from its content alpha (content = o)
   1.2285 in four frames (1.2282-1.2290; the method reads 3 ms early on the R3.4 / R6.2 clips against their s fits), so
   t0 ~1.2315: **the pop (file sample 0, 1.2320) starts with the spring**, the first frame 18 ms later; pill -> t0 48 ms.
   Ours, key path, 8 runs with the content drawn but still showDelay 26 / pop 60, medians: pill -> first frame 50,
   pill -> pop out (player + 11 ms, SOUND-REA section 7) 68, pop out -> first frame -20 ms; pill -> spring start 33.5
   (17-50). (Content held, judge #20: pop -> first frame 57-63, pill -> HUD 100-119.)
   `showDelay` 26 -> **42** (one frame; `hideAfter` 1050 -> 1066 keeps the hold) and the pop 60 -> **44 ms** after the
   level (`volume-key.sh` pop()). After, 12 runs: pill -> first frame mean 59.4 (30 runs pooled 61; Mac 66.7; ours lands
   on 3, 4 or 5 frames), pill -> pop out mean 45.8 (Mac 48.7), **pop out -> first frame mean 13.5, median 10.7 (Mac 18)**.
   With the judge's criterion (> 20 px over 4 levels at 1 per pt) our first frame over grey 127 (+4 levels) does not
   count, the next one does: pop -> that frame about 30 ms (the Mac's first frame counts in volume-pop over TahoeDark and,
   with H.264 noise, in R3.4 over grey: 165 px, max 6.8).
- Left: the pill's own latency in ours jitters 0-60 ms after show() (pill -> spring start -25..45 in loaded runs), so
  pill-based numbers need 10+ runs; the real path's PipeWire notify latency (vs the stub's file watch) is not measured;
  the rim's later growth (R5.1) is still not modelled.
- Files: `shell/modules/HudWindow.qml` 16-18, 23-24, 45-54 (room, margins), 60-67 (glassAlpha), 111-152 (`scaled`, content
  opacity), `shell/services/Hud.qml` 42-70 (showDelay 42, hideAfter 1066, anchorAbove, content note),
  `shell/scripts/volume-key.sh` 10-13, 44-53 (pop 44 ms), `shell/tests/run.mjs` 1194 (hold / anchor / content test).
  Tests: shell 406, ui qml 104, all passing.

### Round J21 (judge #21: first frame "late and fainter", energy .023 vs .031; 2026-11-15, nothing changed)

Decode: the appear has no term besides the spring. `BannerContentController` init (`FUN_2aed44e40`, decomp/SystemBannerUI-
hud.c 49-80) stores three values, 0.9 (`_scaleFactor`), 0 (`_opacity`), 10 (`_topMargin`): no blur, no initial offset.
`BannerSlider.body` (`FUN_2aed61dd8`) puts `.opacity(o)` on the content and `_glassEffect(.controlCenter.mix(with:
.identity, by: 1 - o))` on it, nothing else between the frame modifier and the environment. So the first frames are
content = o and glass ~ o^2 (R3.4: glass -.002 / .000 / -.001 in the first three frames).

Measured (scratch `agent-rd/py/hudfirst.py`): every frame at 1 px per pt (the Mac's 960 x 400 clip area-scaled, ours mcap
`-g 800,34,480,200 -k 1` scaled the same), content level = mean of the 60 brightest glyph pixels and of the bar's filled
pixels over their rest values, t0 fitted on the decoded spring (critical, omega 12.25) over 0.08 < o < 0.85 (rms .007-.011):

| clip / run | first visible frame after t0 | glyph / bar | spring there | 2nd frame | energy share (judge #21's L1), 1st frame |
|---|---|---|---|---|---|
| Mac R3.4 grey dark | 14.7 ms | .029 / .036 | .014 | 31.3: .051 / .065 | .0245 (.0126 counting only pixels over 2 levels: H.264 noise) |
| Mac R6.2 grey light | 31.8 ms (no frame recorded before) | .071 / .071 | .059 | 48.5: .133 / .138 | .0388 |
| Mac blue dark | 20.2 ms | .020 / .021 | .026 | 36.8: .069 / .073 | .0075 |
| ours, dark grey 127, IPC (3 runs) | 16.6-17.9 ms | .023 / .028 | .018-.021 | 33.4-34.0: .061 / .073 | .0093 |

- Ours lands between the Mac's two dark clips in both time and level; the Mac's own first frame moves 15-32 ms with the
  recorder's frame phase. Judge #21's .031 / .058 is the grey clip's (frame 0.600 s is 15 ms into its spring and
  half its L1 is codec noise); its "late" (pop -> first frame 21 ms by > 2 levels, Mac 18) is one sub-frame of phase.
- Not changed: showDelay / pop timing (a 3 ms shift is under the 10-run spread), content / glass curves (decoded).

## Alert, Round R3.1 (Mac 60 fps over grey 127, AppKit decode; 2026-11-14)

Mac clips `screens/27.2.1/windows/alert-appear-dismiss-grey-{dark,light}.mov` (VFR, pts from `ffprobe -show_frames`).
Per frame: least squares of `frame - bg = a * scale(rest - bg, s, about c)` over the whole region (scratch `fitscale.py`):
s = scale, a = window alpha. A 3-part split (content / glass body / shadow, `fitsplit.py`) gives the same alpha for all
three within noise, so the **whole window, shadow included, scales and fades**. No backdrop dim (corners 115.0 before and
after). Scale anchor = the body centre (window frame 410 x 384 = body 260 x 234 + 75 pt shadow margin each side).

- Appear, s: dark .036 .071 .141 .193 .259 .337 .431 .539 .666 .810 .974 1.159 **1.176** 1.146 1.118 1.091 1.068 1.046
  1.029 (1.013) 1.004 1; light .025 .050 .078 .114 .158 .218 .289 .373 .473 .589 .720 .873 1.044 **1.194** 1.135 ... 1.
  Alpha a (dark): .14 .19 .25 .30 .36 .41 .46 .51 .55 .61 .65 .68 .72 .77 .81 .85 .89 .97 1: a linear ramp.
- AppKit decode (dyld cache 27.2.1, `AppKit.fixed` + scratch `dsc.py` / `dis.py`): `___19-[NSAlert runModal]_block_invoke`
  sets `animationBehavior` 5 (AlertPanel) -> `-[NSWindow _effectiveOrderFrontAnimationTypeIfModal:]` type 3
  `NSWindowTransformAnimationPopIn`. `_NSWindowTransformAnimation initWithWindow:...`: types 3/4 run an NSAnimation of
  **0.4 s**, amount **0.2**; the PopIn block (0x18af87224) maps the progress v (linear) to
  scale = 1.2 (0.2 + 0.8 v / 0.6)^3 for v <= 0.6, else 1 + 0.2 cos(0.2 pi u) (1 - u)^1.5, u = (v - 0.6) / 0.4, and
  window alpha = v (`_NSWindowSetAnimationAlpha`). Fit to the frames: scale rms **.0019 dark / .0009 light** (linear v;
  NSAnimation ease-in-out .075 / .071); alpha = v rms .015 light. Ours today: in-quad .04 -> 1.17 in 214 ms, out-quad 180 ms
  (rms vs the old outline .0055), alpha 1 from the first frame (`fade = 1`): the Mac's 0.4 s fade-in is missing.
- Dismiss, decoded: after `runModalForWindow:` the block sets `_setOrderOutAnimationType:` **6
  (ScaleDownAndOut) when the pressed button is the Cancel button** (`+[NSAlert _isAlertButtonEqualToCancel:]`), else **2 =
  no animation** (return 1000 = default button, abort, other buttons), then `orderOut:`. Type 6 under Solarium: NSAnimation
  0.25 s, a `CASpringAnimation initWithPerceptualDuration: 0.1812 bounce: 0`, initialVelocity 13, amount 0.98; block
  0x18af87704: p = spring(progress), scale = 1 - 0.02 p, alpha = 1 - p, and a per-window value 5 p (a blur: the dark clip's
  dismiss frame is visibly blurred), through a snapshot proxy window. Critically damped w0 = 2 pi / 0.1812:
  alpha .76 .54 .37 .24 .16 .10 .06 per frame. Dark clip (Esc = Cancel): one frame a .78 s .997 blurred, then gone;
  light: gone in one frame. The old probe series (performClick Cancel) .489 .312 .180 .097 .047 .017 0 is a pixel share
  and sits about one frame behind the spring's alpha. Ours today: every dismissal a 154 ms out-cubic fade.
- Still (`alert-shown-grey-*.png` vs ours, headless 2x, grey 127, same pixel scale): body 260 x 233.5 pt both, fill 114 /
  203 both, Cancel capsule 125 / 187 vs ours 124 / 188, text rows and button boxes within 1 px, corner profile and shadow
  (below, side, above, 2-130 px) identical to the level. Left: side rim pixel dark 46 vs ours 58, light 54 / 199 vs 60 / 191,
  light bottom rim 216 / 89 vs 219 / 108 (the plugin's regular-glass rim, shared recipe: not alert-only). The blue reads
  (52,120,246) on the Mac only because the PNG is Display P3. The R3.1 icon is Finder's (`display alert`), not the folder.

Done (resumed 17:40): `ui/HyprK/panels.js` `alertPopScale(v, amount)`, `alertCancelProgress(ms, d, v0)`;
`shell/components/AlertDialog.qml` one linear FrameAnim on `appear` (400 ms), `pop = alertPopScale(v)`, `fade = v` (glass
materialize and content), Cancel -> FrameAnim on `outMs` (250 ms): fade 1 - p, pop x (1 - .02 p) from where it was;
any other button (and `Panels.close()` from elsewhere) hides at once; `ui/HyprK/AlertPanel.qml` the same on opacity
(cancel = `buttons[i].cancel`; sheet form unchanged: Sheet in / out); `Theme.alert` popIn / popAmount / cancelOut /
cancelDuration / cancelVelocity / cancelScale and `Tokens.panel.alertPopIn ... alertCancelScale` replace the old pop / fade
values; `ui/tests/tst_panels.qml` 2 new tests (curve values, default hides at once, cancel animates).
Found on the way: at v = 0.5 (m = 0.5) the glass drew one frame of full material without shadow (light: a .47 **.94**
.56; dark 257 ms), 3 of 3 runs. `hyprctl liquidglass trace hyprk-overlay`: that frame decoded `m 1.0000 shadow`: a lone
materialize hole within 2 columns of the centre is read as the shadow marker (plugin Shape.cpp; the stored rect is the
part left of the hole, so its right() is the hole's x). Fix on the shell side, `shell/components/Glass.qml` placeHole: a
shape without a shadow hole moves its materialize hole to centre -/+ 3 (m off by <= 3 / (w - 3)); trace after: m .4601
**.5174** .5436. Applies to every glass with a shadow that materializes across 0.5.

Measured after (mcap `-k 1`, 1 run each mode, `fitscale.py`, model fits `popfit.py`; frames with s > .3):

| | Mac clip vs model | ours before | ours after |
|---|---|---|---|
| appear scale vs PopIn | .0004 dark / .0007 light | .0113 (dark) | **.0009 dark / .0012 light** |
| appear alpha vs v | .014 / .009 | .33 (alpha 1 from frame 1) | **.013 / .015** |
| Cancel alpha vs the spring (alert box / glass only) | first frame .78 (model .76) | out-cubic 154 ms: model .055, on screen (judge #19) .064 | **.028 / .013 dark, .006 / .003 light** |
| default button (About: OK) | none (type 2) | 154 ms fade | gone in the first frame |

Dark Cancel's box rms .028 is the text: our content fades at the glass's alpha over a glass that fades too, so text
pixels read .05 lower at the first frames (.71 vs .76); a window alpha (the Mac) has no such term. Not done: the 5 p
dismiss blur and a shadow that scales with the alert (both plugin/), the side rim pixel (shared regular-glass recipe).
Also: About This Mac's alert title "About This Computer" (no Mac string, EXTRAS-AUDIT.md) is now the OS name
(`shell/modules/MenuDropdown.qml` "about"). Tests: shell 403, finder 33, settings 52, ui qml 98.
Scratch tools: `.../scratchpad/agent-al/py/` (`fitscale.py`, `fitsplit.py`, `popin.py`, `popfit.py`, `dsc.py`, `dis.py`).

### Dismiss blur / shadow (2026-11-14, 19:10)

The Mac's third ScaleDownAndOut value, 5 p, is a Gaussian sigma in pt: the dark clip's dismiss frame (f026 against the
rest f025, 2 px/pt) fits a blurred, scaled, faded rest frame (`blurfit2.py`: `a G_sigma(warp(rest, s))`, alignment searched)
at **sigma 0.80 pt** on the text (title + message box; a .835, s .995, rms 10.1 -> 2.6 with the blur) and **0.80 pt** on the
glass's left edge (a .856), so glass, content and shadow are blurred as one; 5 (1 - .835) = 0.83. Cheapest way on ours,
no offscreen pass of the layer (hyprkmotion's window close blur is for windows; the layer's text is the shell's own
pixels above the glass, so a glass pass cannot blur it):

- content: `shell/components/AlertDialog.qml` a MultiEffect layer on the text / icon / buttons only while the Cancel
  order-out runs (switched on with it: no empty first frame, text energy at the first frames .746 / .515 vs .744 / .510
  before; at rest no layer, the still unchanged); `soften = Theme.alert.cancelBlur (5) x p`. MultiEffect's blur "radius" r
  gave sigma r / 2.7 to r / 4 on this text (measured, 2 runs), so it is driven at r = 4 sigma.
- glass: two window-wide markers in `shell/components/ShellWindow.qml` (`glassSoften`, `glassShadowSize`), read by the
  plugin (`Shape.hpp` takeSoftenMarker / takeShadowSizeMarker, README "Whole-window scale and blur"): the glass edge as a
  Gaussian edge of sigma soften (coverage ramp sigma sqrt(2 pi) wide), and the drop shadow's radius and offset x the alert's
  scale. `shell/modules/Overlay.qml` sends the alert's `pop` and `soften`. Only the overlay layer, only while the alert
  animates (1 / 0 send nothing).

| dark, headless 2x over grey 127, mcap | Mac | ours before | ours after |
|---|---|---|---|
| dismiss frame 1: text sigma (model 5 p) | 0.80 pt (0.83) | 0 (1.19) | **1.15 pt (1.19)** |
| dismiss frame 2: text sigma (model 5 p) | gone | 0 (2.29) | **2.65 pt (2.29)** |
| text sigma vs 5 p, rms of frames 1-2 | .03 | 1.82 pt | **.26 pt** |
| glass edge sigma, frame 1 | 0.80 pt | 0.45 (scale, no blur) | 0.60 pt (the rim and shadow stay sharp) |
| body alpha frames 1-3 (spring .76 .54 .37) | .78 | .750 .500 .332 | .733 .490 .303 (dark), light .784 .566 .392 |
| appear: shadow reach / s, rms vs the Mac at the same s (s .14-1), below / side / above | | dark 41.5 / 18.3 / 7.0 pt, light 35.9 / 15.5 / 7.5 | **dark 2.8 / 6.2 / 6.3, light 2.4 / 6.1 / 8.6** |
| appear: whole-window fit, explained energy (s .14-1) | dark .89, light .96 | dark .79, light .89 | **dark .88, light .90** |

Reach = how far the footprint (|frame - bg| > 2 levels) reaches below / beside / above the body centre, divided by the
fitted scale (`outline.py`, `reachcmp.py`): the Mac's stays 129-145 pt below from s .14 to 1 (the whole window scales);
ours before grew to 186-265 pt at s < .25 (the 24 pt halo round a small body), after 125-146. Light Cancel: the Mac shows
no dismiss frame; ours blurs the same way (its Gaussian fit is poor, rms 7). Before = the R3.1 agent's `after-*`
captures (same geometry), after = 1 run per mode. Not done: the rim and shadow blur (only the edge's coverage ramp blurs:
edge sigma .60 vs .80), the apps' `ui/HyprK/AlertPanel.qml` (all QML: its PanelShadow already scales with it; a layer
blur there would clip the shadow at the item's bounds), Reduce Motion keeps no blur (as no scale). Our text alpha .05
under the window alpha at the first frames (above) is unchanged. Scratch: `.../scratchpad/agent-ab/py/` (`blurfit2.py`,
`outline.py`, `reachcmp.py`), fit outputs in `.../agent-ab/fits/`.

### Judge #20 fixes: first-frame speck, dismiss blur, light halo (2026-11-14, 21:00)

Headless 2x over grey 127, one session per plugin build, mcap `-k 1`; the same scratch tools on the Mac clips and ours
(`.../scratchpad/agent-fx/py/`: `first.py` footprint per frame, `dis.py` text-box fit `a G_sigma(warp(rest))` as
`blurfit2.py`, `reach.py` the judge's whole-window s / a fit and reach through the centre at > 2 levels).

- **Appear, first frames** (JUDGE-95-20: a 3.5 x 2.5 pt opaque speck, 4 of 4). `liquidglass trace hyprk-overlay`: the
  overlay's first commit is unsized (the alert at -130, -34: glass `box -1,116 2x2 m 1.0000`, a speck at the screen's
  left edge, mcap 3 x 6 px at 98 levels), the first tick draws `box 637,273 6x4 m 1.0000` (14 x 10 px at 98 levels).
  Cause: `Glass.qml` sent no hole the plugin reads: under 4 wide none, at 4-8 the hole moved off the centre band (the
  shadow marker's) landed on the edge column, an edge notch. Fix: `shell/components/Glass.qml` placeHole sends no shape
  while m < 0.5 when no readable hole fits (full material above); `shell/modules/Overlay.qml` fades the alert's glass with
  the layer's opacity marker (`glassOpacity` = fade, the glass at materialize 1) while no menu shares the layer: AppKit's
  window alpha at 1 / 1279 steps instead of materialize in 1 / (w - 3) steps. After: trace `opacity 0.0000`, then 6 x 4 at
  `opacity 0.0414`; first visible frame light s .025 a .036, then .042 / .066, .056 / .110 (Mac clip .030 / .033,
  .050 / .069, .077 / .114); dark: one pixel over 3 levels. a vs the Mac at equal s (light): .292 / .30 at s .32, .348 /
  .35 at .41, .401 / .398 at .52, .458 / .449 at .64.
- **Light shadow while small**: not the shadow-size mapping. The materialize ramp gave the small glass the SwiftUI edge
  blur ((1 - m) 10 pt, shader `appearBlur`), so the footprint grew on every side, above the body (where the offset
  shadow reaches least) as much as below. Reach / s below / side / above, light: Mac s .112 107 / 125 / 116, .158
  127 / 127 / 120, .219 128 / 123 / 119, .289 132 / 135 / 118; before s .129 140 / 147 / 147, .175 131 / 143 / 143;
  after (window alpha, no materialize) s .128 125 / 133 / 125, .179 129 / 134 / 123, .247 130 / 134 / 122, .320
  134 / 138 / 122. Judge #20's 75-101 for the Mac is its own metric; this one reads 104-128 below on the same clip at
  s .08-.22. Dark (s from the body's width, the dark glass is 13 levels off grey): Mac 175-179 / 188-194 / 145-156 at s
  .20-.33, ours 168-177 / 184-197 / 156-168 at s .13-.25.
- **Dismiss blur and text alpha**. The Mac's dark dismiss frame by `dis.py`: text sigma 0.78 pt, a .828 (body .840): p
  .16 of the spring. Ours before: dark 1.15 pt, a .641 (body .738); light 1.75 pt, rms 7.4 (body .786). Two causes:
  MultiEffect's blur mixes pre-blurred levels (a sharp core under a wide halo: as a Gaussian it read 1.15 dark / 1.75
  light for one value, and the text kept .64 of its alpha), and the spring was read at 16.7 ms (p .24, 5 p = 1.18) where
  the Mac's one dismiss frame sits at p .16 (11 ms). Fix: `shell/shaders/gausspass.frag` (a true separable Gaussian,
  sigma = soften pt, two passes in `AlertDialog.qml`'s layer.effect), `Theme.alert.cancelPhase` 2 / 3 (frame k reads the
  spring at k + 2/3 frames). After, frame 1: dark sigma **0.80 pt, a .833** (body .816, 12.5 levels of contrast); light
  **0.80 pt** (fit with an offset term; .85 without), a .847, body **.845**; frame 2 1.92 pt both (5 p 1.94). Light body
  alpha per frame .845 .615 .425 .284 .187 .121 .079 .051 against the spring at k + 2/3 .844 .611 .420 .279 .181 .115
  .072 .045. Left: light text contrast against its own glass .795 vs .845 (dark .832): the text sits on a glass that
  fades under it, k = (G - bg) / (bg - T) .78 light vs .12 dark over grey; a window alpha cannot be split exactly between
  the compositor's glass and the shell's layer, and a compensation would depend on the backdrop. No light Mac frame.
- Log: `plusfill.frag`'s optional `pad` uniform declared (`property real pad: 0`) on the three ShaderEffects without it
  (ControlCenterSlider track, Spotlight AppsPanel chip, Dock running-dot fallback): no "'pad' does not have a matching
  property" with Control Center and Spotlight opened.
- Plugin: no change (the scratch build of the tree is the one these numbers were taken with). Tests: plugin ctest 2 / 2,
  shell 405, ui qml 103.
