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

Trackpad scrolls: `scripts/motion-capture/fscroll` sends finger-source axis events. Hyprland 0.57 forwards a
virtual pointer's axis as a mouse wheel (WAYLAND_DEBUG: axis_source 0, axis_value120, axis 0.0) unless axis_source
follows axis in the frame; in that order the client gets axis_source finger, the axis value and axis_stop, and Qt
6.10 (qtbase src/plugins/platforms/wayland/qwaylandinputdevice.cpp, flushScrollEvent / pointer_axis_stop) delivers
ScrollBegin, ScrollUpdate with pixelDelta and ScrollEnd, which is what HyprK RubberBand reads. A real trackpad is
not available here: that libinput finger scrolls reach Qt the same way is read from the code, not seen.

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
| Move / resize | no Mac data (R2, Q-windows and REA have none) | - | - | - | - | no Apple data, left as is |
| Space switch | no 27.2.1 track | 1->2: slide out, visible ~140 ms; 2->1: visible 146..514 ms (SwiftUI spring 0.5) | same | - | alpha | no Mac track |
| Mission Control enter | crit. spring, track fits response 0.395 (R2) | 2-98 % 252 ms, fits response 0.285; first open had a 1-frame stall | 352 ms | 0.060 -> 0.024 / 29 -> 10.7 ms | alpha, full screen | fixed (value 2.4 %) |
| Mission Control exit | track fits response 0.300 (R2) | 216 ms, fits 0.220; hover ring + scale popped 0.15 s after landing (4 %) | 302 ms, no pop | 0.061 -> 0.025 / 33 -> 19 ms | alpha | fixed in value, time 19 ms (1.1 frame) |
| Mission Control exit, session 3 (daf9ac8) | R2 exit series (0.21 .. 0.99, 2-98 % 267 ms) | 0.35, still 100 ms in: 1 window 400-402 ms, 0.041-0.057 / 27-35 ms; 2 windows 301 ms, 0.035-0.045 / 15-18 ms, one repeated frame mid-flight (0.61 0.61) | exit spring 0.31, still taken in the tail: 1 window 351-369 ms, 0.023-0.030 / 17-23 ms; 2 windows 250-283 ms, 0.031-0.049 / 18-27 ms, no mid-flight repeat | see before/after | alpha, full screen | improved; a 2 % step when the layer goes and the spring's S-shaped start (Mac frame 1 = 0.21) remain |
| Mission Control exit, 2 windows at one place (judge #2) | as above | 450-500 ms, 5 % snap at ~575 ms (back window's thumb on top, inactive still) | snap 1.7 % (scaled still vs sharp window), 450 ms | 0.042 / 66-101 ms -> 0.022-0.043 / 28-44 ms | alpha, full screen | improved; the slow tail remains (see Remaining) |
| Spaces bar exit | spring 0.125 (REA), not measured on Mac | - | - | - | - | no Mac track |
| Cmd-Tab show | appears 0.19 s after Tab, 1 frame (Q-dock-22) | appears ~180 ms after the ipc lands, 1 frame | same | - | alpha | matches |
| Cmd-Tab dismiss | alpha ease-in-out 0.236 s (#42 b) | 2-98 % 202 ms | same | 0.013 / 3 ms | alpha | matches |
| Dock launch bounce | parabola, P 0.6997 s, H 18.0 pt at tile 64 (verify/A) | H 18.0 (max), P 0.695 | same | 0.45 pt (Mac self-fit 0.41) | icon top row, k 1 | matches |
| Dock attention bounce | 69 pt, hops 500/326/212 ms in 2 s (verify/A) | max 69 | same | 0.70 pt (1 %) | icon top row | matches |
| Dock magnification ramp | 147 ms cosine (REA; R2 eyeballed ~0.12 s) | - | in 135 ms, out 151 ms (2-98 %) | 0.007 / 1.4 ms in, 0.006 / 0.8 ms out vs cosine 147 ms | Finder icon left edge, magnification on | matches (1 of 3 runs had one repeated frame) |
| Dock hover label fade | cosine 0.292 s, alpha series (#42 c) | 252 ms (2-98 %) vs Mac 250 | same | 0.029 / 6.9 ms (Mac series noise 0.012) | alpha | matches in time, value 2.9 % |
| Dock autohide | show/hide top edge per frame (dock-live.json autohide), show 0.23 s after the edge | - | show starts ~240 ms after the edge, hide ~40 ms after leaving | show 0.012 / 2.9 ms, hide 0.020 / 3.7 ms | Dock top edge | matches |
| Dock slot grow | ~0.25 s, cosine (R2, REA side note) | cosine fit T 244 ms | same | 0.004 vs cosine 0.25 s | Dock edge column | matches |
| Dock slot shrink | ~0.15 s (R2, no track) | - | cosine 150 ms, starts ~45 ms after the window closes | 0.008 / 1.1 ms vs cosine 150 ms | Dock left edge, show-recents off | matches |
| Dock press darken | 1 frame on, 1 frame off (Q-dock-09) | - | on in the first frame after press, off in the first after release | - | alpha on the icon | matches |
| Menu open | complete in 1 frame (R2) | title pill in frame 1, menu in frame 2 (4 of 4 runs) | pill and menu in the same frame (4 of 4) | - | alpha on pill / menu | fixed (Overlay maps while the pointer is over the titles) |
| Menu row highlight | jumps in 1 frame (R2) | 1 frame | same | - | alpha | matches |
| Menu close (Esc) | 0.18-0.2 s fade, row-blink series (Q-menubar-24) | pill goes at once, fade starts 1 frame later, 217 ms | fade now 185 ms (13d0061), Esc not re-measured | 0.026 / 10 ms | alpha | near (value 2.6 %) |
| Menu row blink + fade | off 4 frames, on 3, fade 0.2 s (Q-menubar-24 row series, OutQuad 194 ms fits it at 0.010) | off 4-5, on 4-5 frames (two Timers), fade rms 0.025 / 4.3 ms | off 4 / on 3 in 5 of 8 runs (else one half +-1 frame); fade 185 ms | fade 0.025 -> 0.015 / 4.3 -> 2.8 ms | row blue - red | fixed |
| Submenu open delay | ~0.22 s = 13 frames after the row, complete in 1 frame (Q-menubar-23) | 14-15 frames (233-250 ms) | 12-14 frames, mean 13.2 | - | alpha on row / submenu, Dock menu Options | fixed |
| Control Center open | ease-out, 1.0 at ~0.3 s (R2) | fade matches until 0.96, then the last 4 % (tile rims) pops when the glass opacity reaches 1, at ~465 ms | same | 0.021 / 11 ms (before the pop) | alpha | remaining (pop is in plugin/: rims differ below opacity 1) |
| Control Center open (Glass hand-off) | REA spring 0.25, critically damped | 388-394 ms, 3.5 % rim pop at ~485 ms | 234-272 ms, no pop | 0.024 / 16-19 ms -> 0.011-0.018 / 4-11 ms | alpha | fixed (shell/components/Glass.qml); a repeated 2nd frame remains |
| Control Center close | 0.17-0.2 s (R2), REA spring 0.25 (95 % at 0.19 s) | 2-98 % 233 ms | 216 ms | 0.018-0.026 / 11-13 ms vs REA spring | alpha | matches REA within a frame |
| Notification Center open | spring 0.3, ratio 1 (nc/motion.json) | 2-98 % 300 ms | same | 0.015 (5.7 pt) / 7.4 ms | leading edge | matches |
| Notification Center close | offsets per frame (nc/motion.json) | 300 ms | same | 0.017 (6.6 pt) / 8.1 ms | leading edge | matches |
| Banner in | offsets f0..f22, fit 0.43 / 0.9 (nc/motion.json) | edge from first visible frame | same code | 0.042 (11.5 pt) / 10 ms -> 0.014 (3.8 pt) / 2.9 ms | leading edge, threshold 40 (the old threshold caught the faint glass of the first faded frames) | matches (no change needed) |
| Banner out | offsets 10, 51, 104, 148, 192 pt; gone 0.15 s | 18, 62, 108, 156, 203 pt; fade q^3 | same | ~9 pt (2 %) by frame readout | frames | matches |
| NC list push (new card while open) | push 81 pt per frame (nc/motion.json, ~0.35 s) | gap jumped 6 pt, then 3 frames held, then the spring | no gap jump, 2-frame start | 0.029 / 14.7 ms -> 0.024-0.027 / 3.7-8 ms | calendar widget offset | fixed |
| NC clear (close button) | card fades in place in 0.07 s, list up on spring 0.22 / 1.25 (3g) | card slid out first: list started 392 ms after the click, 13 pt jump at the end | list starts 112 ms after the click, no end jump | vs spring 0.035 -> 0.015 / 9.5 ms | calendar widget offset | fixed |
| HUD appear | alpha track (verify/A hud-appear-fit), 2-98 % 483 ms | 586 ms; glass jumped 0.71 -> 0.92 in one frame (opacity marker swallowed) | 483 ms | 0.052 -> 0.030 / 55 -> 24 ms | alpha on the HUD | fixed (one odd glass frame remains at ~350 ms) |
| HUD appear (plugin 80fd49d, judge #2) | hud-appear-fit.json | - | monotonic, no dip frame | 0.020-0.033 / 17-25 ms (frames dropped at random) | alpha | the judge's dip was the old plugin |
| HUD dismiss | spring(0.48669, 1), alpha = (1-x)^2 (REA) | - | 2-98 % 350 ms vs model 283 ms, gone at 483 ms (REA completion 487 ms) | 0.023 / 17.5 ms | alpha from shown | near (our last 5 % lingers) |
| HUD dismiss, session 3 (no change) | 1 - s(t)^2, s = spring(0.48669, 1): 2-98 % 267 ms | - | 317 ms; ahead of the model for the first 120 ms, behind after | 0.028 / 12-14 ms (3 runs) | alpha | the tail is the content, drawn at s while the glass is at s^2 (REA inference). The Mac appear track (verify/A hud-appear-fit) fits s (rms 0.0097, own omega) and s^2 (0.012) alike, so it cannot decide; no Mac dismiss track. Left as is |
| Full screen enter, menu bar and Dock (session 3, 02acb33) | Dock on the Space slide 0.5 - 0.5 cos(pi t / 0.5 s); menu bar out over 0.15 s (inferred default) (MOTION-PLUGIN.md Full screen REA) | titles and Dock gone in frame 1 (10 ms) | titles fade 43..145 ms, Dock slides out over the growing window until ~360 ms | - | bar title strip contrast, Dock band frames | done (both sit on Overlay while they leave: Hyprland hides Top layers at once) |
| Full screen exit, menu bar and Dock (session 3) | menu bar back over 0.5 s from the start (startMenuBarAnimation:), Dock on the 0.5 s cosine | Dock popped in whole at ~123 ms, menu bar faded 150 ms | Dock rises from the edge on the cosine, menu bar fades over 500 ms (curve CA ease-in-out, not decoded) | - | frames | done |
| Spotlight open blur 25 -> 0 (session 3, tried, not kept) | InvocationAnimationState blurRadius 25, Spring(0.51, 0.05) | no blur: 0 dropped frames in 3 runs | full-screen layer: a repeated 2nd frame and a dropped frame in 2 of 4; on the bar only (1x texture, blurMax 32): still a dropped frame in 4 of 6 | - | alpha on the bar | reverted: the blur costs frames on this stack |
| Spotlight open | scale 1.0877 -> 1 track (verify/A spotlight-open-fit) | first visible 1.092; first frame 63-113 ms after the shortcut (created on open) | first visible 1.096; 46-60 ms after the shortcut (kept loaded, unmapped) | scale 0.0027 -> 0.0005 (0.26 pt) | bar width | fixed (+1.9 MB anon at rest, 0 CPU) |
| Spotlight close | REA: x 1 -> 1.12, y 1 -> 0.95 Spring(0.45, 0.05), alpha Spring(0.28, 0.41) (0 at 0.12 s), content blur 0 -> 25 Spring(0.51, 0.05); R2 eyeballed 3 frames | 7 frames, no blur | 6-7 frames, with the content blur | no Mac track | alpha, bar width | done per REA |
| Spotlight mode list unfold | share per frame .04 .11 .22 .36 .51 .66 .78 .87 .94 .98 1 (Q-panels-26) | list came in one frame (Behavior gate race) | unfolds, 2-98 % 154 ms (Mac 167) | 0.24 -> 0.035 / 7 ms (two repeated frames at the start) | list bottom edge | fixed |
| Spotlight calculator card | sizes only (Q-panels-21), no timing | - | - | - | - | no Apple data, left as is |
| Apps | 1 frame in, icons fill over 0.5 s; Esc closes in 1 frame (R2) | fade in over 0.10 s; close 87 % + 0.12 s tail | 71 % in frame 1 (rest = icons), close 100 % in 1 frame | - | alpha | fixed |
| Rubber band (trackpad), Finder and shell views (judge #2) | AppKit filter floor(D(1 - 1/(1 + d c / D))), c 0.075, first 10 pt nothing | judge: 0 px with a virtual pointer | 300 pt pull: 21 pt stretch in Finder and the Apps grid (filter 20.9), held while the fingers rest, returned on lift | - | content offset, fscroll finger events | works on screen; the judge's virtual pointer sent wheel events (see Method) |
| Traffic-light glyphs (plugin, report only) | 0.07 s delay, ~0.1 s ease-out (M877) | in: starts ~70 ms after hover, 14/48/67/81/90/95/100 % per frame; out: 31/56/75/88/94/100 % | - | - | alpha on the lights | matches by eye |
| Quick Look | 0.79 -> 1 in 0.25 s ease-out (.79 .85 .90 .93 .95 .97 .98 .98 .99 1, Q-finder-26) | code OutQuint 250 ms = the Mac series within 0.01 | on screen the first frame (0.79) shows twice (panel created), then the curve | not tracked (panel edge lost in the icon grid) | alpha, width | near (1 repeated frame) |

## Fixes (commits)

- plugin-motion: genie progress solved per frame so the drawn area follows the Mac's ease-in-out remaining-area curve.
  Cause of the short look: with linear time the bend alone used ~90 ms and the last ~100 ms was a neck under 1 % of
  the area, so 0.27 s of the 0.5 s was visible.
- shell: Mission Control spring response 0.35 (the screen runs ~1.37x slower than the code's 0.25 in both
  directions); hover ring and hover scale only while open.
- shell: Apps mode of Spotlight opens and closes in one frame.
- shell: HUD window one row taller so the glass opacity marker is not swallowed by the glass region.

Session 2 (same day, per commit): 13d0061 menu blink/fade/submenu; 9059746 menu open in one frame; 6c0fc75
spring plans cached; 793b797 NC clear and gaps; 93fbbd6 Glass shape rounding (CC rim pop); 09c8ecd mcap shift range;
8acc1bb Mission Control stacking and exit still; 9eb1b02 Spotlight kept loaded + close blur; d82145d shell rubber
band; 40a1a15 fscroll; b725cd0 Spotlight mode list unfold.

## Remaining, with numbers

- Unzoom, full screen: done in plugin-motion (MOTION-PLUGIN.md).
- Mission Control exit: session 3 brought 2-98 % to 250-283 ms (two windows at one place) and 351-369 ms (one
  window) against the Mac's 267; a ~2 % step remains when the layer goes (scaled still against the sharp window).
- HUD dismiss: our last 5 % lingers (2-98 % 350 ms vs 283 ms of the REA model), rms 0.023.
- NC push: starts with a 2-frame hold (the Mac shows one of 2 frames too: 5, 5, 13.5 pt), rms 0.024-0.027.
- Spotlight mode list: two repeated frames at the start of the unfold (rms 0.035).
- Control Center open: its second frame repeats the first (rms 0.011-0.018).
- Quick Look: the first frame shows twice (the panel is created on Space).
- Repeated frames at the start of a motion (Dock magnification once in 3 runs, CC, Spotlight list, NC push, Spotlight
  open with any layer): session 3 tried the Spotlight open with QSG_RENDER_LOOP=basic and with
  QSG_USE_SIMPLE_ANIMATION_DRIVER=1: the second frame still repeats (4 of 4 and 5 of 5), the spring values of the
  frames are the same as with the default loop, so the animation clock is not the cause. The window's first commit after
  mapping seems to wait one extra frame callback (compositor pacing; not proven, not fixed).
- No Apple data: window move/resize, Spotlight calculator card growth.
- Not done: Spotlight's open blur 25 -> 0: tried twice in session 3, it drops frames (see the table).
