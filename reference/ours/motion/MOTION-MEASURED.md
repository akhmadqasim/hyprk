# Motion measured on screen (2026-11-11)

Every number below comes from frames captured on screen in a headless test session (`scripts/smoke.sh`,
`HYPRK_HEADLESS=1`, output MBA 2560x1664@60, scale 2), not from code. Mac ground truth: `reference/re/MAC-ANSWERS.md`
(R2, REA sections, Reconciliation #42, Q-panels, Q-menubar, NC #62) and the per-frame tracks under
`reference/re/27.2.1/live/` (verify/A, nc/motion.json, dock/reconciliation-42.json). Per-frame values of every capture:
`motion-measured.csv` (motion, metric, t in ms from the trigger, value).

## Method

`scripts/motion-capture/mcap` (C, wlr-screencopy v3): `copy_with_damage` requests chained back to back on a region, so
every rendered frame with damage is captured; the time stamp is the compositor's presentation time of that frame
(CLOCK_MONOTONIC), so the time axis has no client jitter. A trigger command runs after 2 reference frames; its start
is t0. `mcap.py` turns frames into one number per frame and compares it with a Mac series:

- `alpha`: least-squares blend factor between the first and last frame (fades, and "share of the total pixel change");
- `changed` / `remain`: share of samples that differ from the first / last frame (slides, genie remaining area as #42);
- edge and offset trackers for slides and bounces (leading edge column, icon top row; 0.5 pt resolution at k = 1).
- `compare`: rms in value at the best time shift, rms in time at equal progress (5..95 %), 2..98 % durations.

Validation (exact by construction): Hyprland `fadeOut` set to a linear bezier over 0.5 s, window closed over the
wallpaper. Measured T = 500.5 ms, rms 0.0013 against the line; frame interval 16.69 +- 0.34 ms (min 15.3, max 18.2),
49 frames in 0.8 s, none dropped. Trigger latency: `hyprctl dispatch` about 7 ms, `qs ipc call` about 45 ms (first
frame of any shell reaction), so absolute start times in the table include that; curves are compared after the best
time shift. Matches = value rms within 2 % of travel AND time rms within one 60 Hz frame (16.7 ms).
The pointer is drawn into the frames (software cursor), so it was parked outside each region.

## Results

| Motion | Mac (duration, curve, source) | Ours before (measured) | Ours after (measured) | rms (value / time) | Method | Status |
|---|---|---|---|---|---|---|
| Window open | 1 frame, no fade (R2) | 1 frame | same | - | alpha, full region | matches |
| Window close | alpha x0.6/frame, 2-98 % 133 ms (R2 TextEdit) | 134 ms | same | 0.010 / 0.8 ms | alpha | matches |
| Minimise genie | remaining area = 1 - easeInOut(.42,0,.58,1)(t/0.5 s), visible 0.37-0.48 s (#42 a) | visible 0.265 s (96..361 ms), rms 0.103, time rms 40 ms | visible 0.40 s (78..478 ms) | 0.024 / 8.8 ms | remain (thr 20) over window + Dock | fixed (value 2.4 %, just over) |
| Restore genie | shown area ease-in-out 0.5 s, visible 0.38 s (#42 a) | linear mapping (same cause), not captured | visible 0.38 s | 0.025 / 9.4 ms | changed | fixed (value 2.5 %) |
| Zoom | 0.33 s ease-in-out, 2-98 % 267 ms (R2) | 266 ms | same | 0.008 / 2.6 ms | alpha | matches |
| Unzoom | 0.33 s ease-out from the start (R2) | zoom curve, 267 ms | same | 0.040 / 14.7 ms | alpha | remaining (config: one windowsMove leaf for both directions) |
| Full screen enter | 0.42 s, window grows while a black Space slides in (R2) | 282 ms, zoom curve, no Space slide | same | 0.065 / 31 ms | alpha | remaining (config) |
| Full screen exit | 0.5 s in two steps (0.15 s to 0.47, 0.15 s hold, 0.3 s rest) | one step, ~0.3 s | same | not comparable | alpha | remaining (config) |
| Move / resize | no Mac data | - | - | - | - | not measured |
| Space switch | no 27.2.1 track | 1->2: slide out, visible ~140 ms; 2->1: visible 146..514 ms (SwiftUI spring 0.5) | same | - | alpha | no Mac track |
| Mission Control enter | crit. spring, track fits response 0.395 (R2) | 2-98 % 252 ms, fits response 0.285; first open had a 1-frame stall | 352 ms | 0.060 -> 0.024 / 29 -> 10.7 ms | alpha, full screen | fixed (value 2.4 %) |
| Mission Control exit | track fits response 0.300 (R2) | 216 ms, fits 0.220; hover ring + scale popped 0.15 s after landing (4 %) | 302 ms, no pop | 0.061 -> 0.025 / 33 -> 19 ms | alpha | fixed in value, time 19 ms (1.1 frame) |
| Spaces bar exit | spring 0.125 (REA), not measured on Mac | - | - | - | - | no Mac track |
| Cmd-Tab show | appears 0.19 s after Tab, 1 frame (Q-dock-22) | appears ~180 ms after the ipc lands, 1 frame | same | - | alpha | matches |
| Cmd-Tab dismiss | alpha ease-in-out 0.236 s (#42 b) | 2-98 % 202 ms | same | 0.013 / 3 ms | alpha | matches |
| Dock launch bounce | parabola, P 0.6997 s, H 18.0 pt at tile 64 (verify/A) | H 18.0 (max), P 0.695 | same | 0.45 pt (Mac self-fit 0.41) | icon top row, k 1 | matches |
| Dock attention bounce | 69 pt, hops 500/326/212 ms in 2 s (verify/A) | max 69 | same | 0.70 pt (1 %) | icon top row | matches |
| Dock magnification ramp | 147 ms cosine (REA) | magnification off in the test state | - | - | - | not measured |
| Dock hover label fade | cosine 0.292 s, alpha series (#42 c) | 252 ms (2-98 %) vs Mac 250 | same | 0.029 / 6.9 ms (Mac series noise 0.012) | alpha | matches in time, value 2.9 % |
| Dock autohide | 0.17 s ease-in hide (Q-dock-16) | autohide off in the test state | - | - | - | not measured |
| Dock slot grow | ~0.25 s, cosine (R2, REA side note) | cosine fit T 244 ms | same | 0.004 vs cosine 0.25 s | Dock edge column | matches |
| Dock slot shrink | ~0.15 s | a quit app stays as a Recent, no shrink in the test | - | - | - | not measured |
| Dock press darken | 1 frame (Q-dock-09) | - | - | - | - | not measured |
| Menu open | complete in 1 frame (R2) | title pill in frame 1, menu in frame 2 (4 % then 100 %) | same | 1-frame stagger | alpha | near (1 frame late) |
| Menu row highlight | jumps in 1 frame (R2) | 1 frame | same | - | alpha | matches |
| Menu close (Esc) | 0.18-0.2 s fade, row-blink series (Q-menubar-24) | pill goes at once, fade starts 1 frame later, 217 ms | same | 0.026 / 10 ms | alpha | near (value 2.6 %) |
| Menu title switch / row blink / submenu delay 0.22 s | Q-menubar-23/24 | the scripted click did not act; submenu not driven | - | - | - | not measured |
| Control Center open | ease-out, 1.0 at ~0.3 s (R2) | fade matches until 0.96, then the last 4 % (tile rims) pops when the glass opacity reaches 1, at ~465 ms | same | 0.021 / 11 ms (before the pop) | alpha | remaining (pop is in plugin/: rims differ below opacity 1) |
| Control Center close | 0.17-0.2 s (R2, no track) | 2-98 % 233 ms | same | - | alpha | near (no Mac track) |
| Notification Center open | spring 0.3, ratio 1 (nc/motion.json) | 2-98 % 300 ms | same | 0.015 (5.7 pt) / 7.4 ms | leading edge | matches |
| Notification Center close | offsets per frame (nc/motion.json) | 300 ms | same | 0.017 (6.6 pt) / 8.1 ms | leading edge | matches |
| Banner in | offsets f0..f22, fit 0.43 / 0.9 (nc/motion.json) | edge from first visible frame | same | 0.042 (11.5 pt) / 10 ms | leading edge | near (the 0.85 scale adds to the edge) |
| Banner out | offsets 10, 51, 104, 148, 192 pt; gone 0.15 s | 18, 62, 108, 156, 203 pt; fade q^3 | same | ~9 pt (2 %) by frame readout | frames | matches |
| NC list reflow / clear | nc/motion.json | - | - | - | - | not measured |
| HUD appear | alpha track (verify/A hud-appear-fit), 2-98 % 483 ms | 586 ms; glass jumped 0.71 -> 0.92 in one frame (opacity marker swallowed) | 483 ms | 0.052 -> 0.030 / 55 -> 24 ms | alpha on the HUD | fixed (one odd glass frame remains at ~350 ms) |
| HUD step / dismiss | REA springs | - | - | - | - | not measured |
| Spotlight open | scale 1.0877 -> 1 track (verify/A spotlight-open-fit) | first visible 1.092, settles like the track | same | scale 0.0027 (0.7 pt) | bar width | matches; first frame 174 ms after the ipc (window created on open; 111 ms while held) |
| Spotlight close | fade + blur + growth "in 3 frames" (R2, eyeballed) | alpha 6 -> 100 % in 7 frames (~0.11 s), no blur | same | no track | alpha | remaining (no blur; Mac duration only eyeballed) |
| Spotlight mode list / calculator | 0.17 s ease-in-out (Q-panels-26) | code: 180 ms InOutSine | - | - | - | not measured |
| Apps | 1 frame in, icons fill over 0.5 s; Esc closes in 1 frame (R2) | fade in over 0.10 s; close 87 % + 0.12 s tail | 71 % in frame 1 (rest = icons), close 100 % in 1 frame | - | alpha | fixed |
| Traffic-light glyphs (plugin, report only) | 0.07 s delay, ~0.1 s ease-out (M877) | in: starts ~70 ms after hover, 14/48/67/81/90/95/100 % per frame; out: 31/56/75/88/94/100 % | - | - | alpha on the lights | matches by eye |
| Quick Look (report only) | 0.79 -> 1 in 0.25 s | not measured (Finder, other owner) | - | - | - | not measured |

## Fixes (commits)

- plugin-motion: genie progress solved per frame so the drawn area follows the Mac's ease-in-out remaining-area curve.
  Cause of the short look: with linear time the bend alone used ~90 ms and the last ~100 ms was a neck under 1 % of
  the area, so 0.27 s of the 0.5 s was visible.
- shell: Mission Control spring response 0.35 (the screen runs ~1.37x slower than the code's 0.25 in both
  directions); hover ring and hover scale only while open.
- shell: Apps mode of Spotlight opens and closes in one frame.
- shell: HUD window one row taller so the glass opacity marker is not swallowed by the glass region.

## Remaining, with numbers

- Unzoom 0.040 rms, full screen 0.065 rms / 31 ms, two-step exit: Hyprland has one `windowsMove` leaf for zoom, unzoom
  and full screen, no per-direction curve, no Space slide, no hold. Config cannot express them.
- Control Center open: the last 4 % (tile rims) pops when the glass opacity reaches exactly 1 (~465 ms, 85 ms after
  the fade reached 0.96). The rims render differently below opacity 1 in plugin/ (other owner).
- HUD: one frame at ~350 ms of the appear shows the glass with a different (darker, thicker) look over the left half.
  Likely the same plugin/region path; the jump it caused before is gone.
- Spotlight close has no blur (judge #29), and its duration on the Mac is only an eyeball estimate.
- Menu open shows the title pill one frame before the menu; menu close drops the pill at once and starts the fade a
  frame later.
- Banner in: 11.5 pt rms (4 %), partly because our left edge also carries the 0.85 -> 1 scale.
- Not measured: magnification ramp and autohide (off in the test state), slot shrink, press darken, menu blink and
  submenu delay, NC reflow and clear, HUD dismiss, Spotlight list unfold and calculator growth, Quick Look, move/resize.
