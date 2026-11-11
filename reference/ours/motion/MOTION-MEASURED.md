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
| Mission Control exit, session 4 (one Settings window, NOT reproduced: judge #3 measured 368 ms, 0.032-0.061, a repeated first frame and a 0.94 plateau; session 7 measured the same, see below) | R2 exit series 0.21 .. 0.99; a critically damped spring fits it at rms 0.0043 only with a start velocity (response 0.355, 10 x the distance per second; from rest 0.0079 with its first 46 ms missing) | spring 0.31 from rest: 2-98 % 317-333 ms, first frame 0.07, a 3.8 % step at ~420 ms | start velocity 10/s (SpringCurve.kick): 282-285 ms, first frame 0.21 | 0.018-0.032 / 8.5-19 ms -> 0.011 / 4.6-8.5 ms (a third run dropped its first frame: 0.043) | alpha, full screen, k 4 | improved (Mac 267 ms); two windows at one place not re-measured |
| Notification Center open / close over 16 pt stripes, session 4 (plugin e7184e5) | nc/motion.json offsets, W 386 pt | - | open 3 runs, close 3 runs | open 0.0063-0.0066 (2.4-2.5 pt); close 0.007-0.029 (2.7-11 pt; one run with a late frame) | leading edge, threshold 30 | matches; the first frame comes 240 ms after the ipc call (Mac: 0.24 s after the click) |
| Control Center open, repeated 2nd frame (session 4) | REA spring 0.25 | first visible frames 0.06, 0.09, then 0.21 / 0.34 (steps of 0.13) | tried: the spring started on the first swapped frame (no change: 0.06, 0.09) and one frame ahead (0.02, 0.02-0.03, then 0.18: the hold moves before the motion); both reverted | 0.007-0.022 / 5-11 ms either way | alpha | not fixed shell-side: see "Repeated frame after a layer maps" |

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
- Mission Control exit: session 4 (start velocity) 282-285 ms with one window against the Mac's 267, first frame 0.21
  like the Mac; two windows at one place not re-measured since session 3 (250-283 ms).
- HUD dismiss: our last 5 % lingers (2-98 % 350 ms vs 283 ms of the REA model), rms 0.023.
- NC push: starts with a 2-frame hold (the Mac shows one of 2 frames too: 5, 5, 13.5 pt), rms 0.024-0.027.
- Spotlight mode list: two repeated frames at the start of the unfold (rms 0.035).
- Control Center open: its second frame repeats the first (rms 0.011-0.018).
- Quick Look: the first frame shows twice (the panel is created on Space).
- Repeated frames at the start of a motion (Dock magnification once in 3 runs, CC, Spotlight list, NC push, Spotlight
  open with any layer): session 3 tried the Spotlight open with QSG_RENDER_LOOP=basic and with
  QSG_USE_SIMPLE_ANIMATION_DRIVER=1: the second frame still repeats (4 of 4 and 5 of 5), the spring values of the
  frames are the same as with the default loop, so the animation clock is not the cause. Session 4: see below.

## Repeated frame after a layer maps (session 4, WAYLAND_DEBUG=client on the shell + mcap of the same CC open)

Times in ms from the shell's get_layer_surface (the Control Center maps two surfaces: the 456 x 646 panel on Top and a
full-screen catcher on Overlay); frame-done times are the compositor's (CLOCK_MONOTONIC ms), mcap presentation times
on the same clock:

| ms | event |
|---|---|
| 0 | get_layer_surface (panel), initial commit; catcher likewise |
| 11.5 | configure, ack |
| 21.6 | first buffer attached and committed (frame callback requested 0.6 ms before) |
| 21.8 | **frame done for that first commit, 0.2 ms after it** (no vblank in between) |
| 34.6 | second buffer committed, 13 ms after the first (inside the same refresh interval) |
| ~38 / ~55 | vblanks: mcap sees no Control Center pixel in either frame |
| 53.5 | frame done (vblank t = 411): from here one commit per vblank, done 16.7 ms apart |
| ~72 | first frame with Control Center pixels (alpha 0.057), next 0.085, then 0.21, 0.35, 0.48 |

So the compositor shows the layer from the third vblank after its first buffer, and the first visible frames carry
the spring's first state (fade 0: only the panel's compositor blur, alpha 0.06) and a small second step. Starting
the spring on Qt's first swapped frame changed nothing; starting it one frame ahead moved the hold before the motion
(1-3 frames at 0.02-0.03, then 0.18). The cause is on the compositor side: Hyprland answers the first frame
callback of a new layer surface at once, so Qt draws two buffers in one interval, and the layer appears two vblanks
later than its first buffer. Not fixable in QML (Qt gives no presentation feedback); hand-off to the plugin/config
agent (report: does the liquidglass plugin hold a new glass layer until it has its shape, and can the first frame
done of a mapping layer wait for the vblank that shows it).

- No Apple data: window move/resize, Spotlight calculator card growth.
- Not done: Spotlight's open blur 25 -> 0: tried twice in session 3, it drops frames (see the table).

## Session 5 (2026-11-11): shell hand-offs H1-H4 of the plugin's 61e74c6, regression check

Same method, MBA headless session, per-frame values in `motion-measured.csv` (`*-s5`). Changes: wallpaper decoded at the
pixel size (1ee085c), Dock label pointer from the plugin (fbc2541, 526a333), Cmd-Tab selection tile as a plus-darker /
plus-lighter fill on a second surface `hyprk-switcher-fill(-dark)` (2db3868).

| Motion | Mac | Before (rows above) | After (measured) | rms (value / time) | Method | Status |
|---|---|---|---|---|---|---|
| Cmd-Tab show | 1 frame, 0.19 s after Tab (Q-dock-22) | ~180 ms after the ipc, 1 frame | 216 ms after the Tab key (virtual keyboard, no ipc); panel, tile, icons and name in the same frame, only with a `no_anim` layer rule for the fill namespaces (now in the config, cd062de; re-measured: all at 1.0 in the first frame at 215-218 ms, 3 of 3 runs). Without it the fill surface comes one frame after the panel (alpha -0.04 at 216 ms, 0.92 at 232) and Hyprland's layer fade-in adds a tail to 331 ms | - | alpha, panel region | matches with the rule; config hand-off |
| Cmd-Tab dismiss (Escape) | `cmdtab_hide_alpha`, ease-in-out 0.236 s (#42 b) | 2-98 % 202 ms, 0.013 / 3 ms | panel region 218 ms, 0.016 / 4.0 ms; panel glass alone 201 ms, 0.011 / 2.1 ms. Re-measured with the plugin's 8199aad/5e9aff0 (fill fades with the glass): panel region 198-200 ms (Mac 200), 0.009 / 1.1 ms in 2 of 3 runs, 0.031 / 6.5 ms in the third (the fill one commit late, hand-off d) | 0.009 / 1.1 ms | alpha vs the Mac series | matches |
| Dock hover label fade-out | `dock_label_fadeout_alpha`, cosine 0.292 s | 252 ms, 0.029 / 6.9 ms | dark, grey, plugin 8199aad/5e9aff0 (the pointer fades with the pill; the shell's workaround that hid it at the fade start is gone, d928bf4): label 267 ms, 0.011 / 4.4 ms; pointer region alone 267 ms, 0.019 / 6.9 ms, no step and no full-material frame | 0.011 / 4.4 ms | alpha vs the Mac series | matches |
| Dock magnification ramp | 147 ms cosine (REA) | in 135 / out 151 ms (icon left edge) | Finder icon top: in 150-151 ms, 0.014-0.016 / 1.5-1.9 ms in 2 of 4 clean runs, 2 runs repeat 1-2 frames at the start (167-182 ms, 0.03-0.05); out 153 ms, 0.013 / 1.2 ms. With the pointer turned off the same repeats come in 2 of 4 runs: they are the label surface mapping (repeated frame after a layer maps, above), not the pointer | 0.014 / 1.5 ms | icon top row vs cosine 147 ms | unchanged |
| Dock launch bounce | H 18.0 pt, P 0.6997 s | H 18.0, P 0.695 | H 18.0, hops 64 -> 748 and 765 -> 1449 ms (P ~0.69 s) | - | icon top row, k 1 | unchanged |

## Session 6 (2026-11-11): which event repeats the Control Center's first state (follow-up of MAP-LATENCY.md)

Headless MBA, plugin 8199aad/5e9aff0, CC opened with `hl.dsp.global("hyprk:controlcenter")`. A temporary log in
ControlCenterWindow.qml (removed again) printed, per event of the panel's QQuickWindow, the time and `fade`:
`afterAnimating`, `beforeSynchronizing` (the state a buffer gets), `frameSwapped`, and each change of `fade`.

- Threaded render loop (default), every open: `go` -> afterAnimating / sync at fade 0 (buffer 1, empty) -> the spring's
  first tick changes `fade` to 0.0611 **between** two frames (on Qt's animation timer, before the render loop's
  driver runs) -> afterAnimating + sync at 0.0611 (buffer 2) -> a second afterAnimating in the same millisecond with
  no advance, and after the swap a second sync at 0.0611 (buffer 3 = buffer 2) -> from then on one advance per sync
  (0.2015, 0.3477, ...). So the duplicate is Qt's threaded loop taking over the animation clock: its first frame after
  an animation starts outside a frame does not advance. Not the catcher: with the dim window mapped all the time
  (`visible: true`, tried and reverted) the same pair of 0.0611 syncs came, plus a second fade-0 frame.
- `QSG_RENDER_LOOP=basic` (qs restarted with it, test only): fade 0, 0, then 0.0611, 0.1925, 0.3386, 0.4778, ...
  one advance per frame, no duplicate.
- mcap, 5 opens each, alpha over 814,30,460,660: threaded first visible 46-48 ms, values 0.04-0.07, 0.12, 0.28, 0.43,
  0 repeats at the 0.01 level in this session (the 2nd and 3rd buffer reach the screen in one vblank here), 2-98 %
  233-251 ms; basic first visible 29 ms (44 once), 0.05, 0.17, 0.32, 0.45, 0 repeats, 2-98 % 237-257 ms: one frame
  earlier. Before (MAP-LATENCY.md): 48-93 ms, 1 repeat in 5 of 5, 233-250 ms.
- Not changed: the basic loop renders every window of the shell on the GUI thread one after another (Dock, menu bar,
  panels, the lock), a global change whose cost was not measured; the first buffer still carries fade 0 there too.
  A shell-side fix would start the spring inside a frame (on the window's `afterAnimating`, so its first tick is the
  render loop's). Tried after this note: `go()` from the window's first `afterAnimating` (inside the frame): the
  first tick still came between frames (fade 0.0611 right after the swap of the fade-0 frame) and 0.0611 was synced
  twice again; reverted. The earlier tries (start on the first swapped frame, one frame ahead) were not repeated.

Cmd-Tab fill one commit late (hand-off d, 1 in 3 dismisses here): Quickshell sends a layer's ext-background-effect
region (with the glassOpacity marker) from the GUI thread at the window's polish (`BackgroundEffect::onWindowPolished`,
`wl_surface` pending state), while the threaded loop commits the content from the render thread. A polish of frame
N+1 can run before the render thread commits frame N, so the region rides on the wrong commit. The fill surface and the
panel are two windows on one animation, which makes it visible there. A clean fix is in Quickshell (set the region
from the render thread right before the swap, or with the frame's commit), not in the shell; not done.

## Session 7 (2026-11-11): Mission Control, render loop, HUD (after judge #3)

Headless MBA, mcap alpha over the full screen (k 4) or the panel; per-frame values in `motion-measured.csv` (`*-s7*`).
The host ran 6-9 other headless sessions on the same GPU: runs with frames 30-40 ms apart ("gaps") came and went in
both render loops, so every row below is several runs and the spread is given.

Mission Control (shell 455ae3a): the old layer faded the wallpaper over the real windows with `e`, so the real
windows cross-faded under the flying thumbnails: the screen ran ahead of the spring early and behind it late, and the
0.31 / 0.35 responses were stretches of that. Now the wallpaper is opaque over the windows for the whole flight (only
the 100 pt menu bar strip fades with `e`), the thumbnails stack in Hyprland's client order, the flight starts on the
first presented frame with the thumbnails in, and the tail capture (the 0.96 plateau: it held qs's frames) is gone.
Exit 0.25 (the code's ExposeSpringResponse) with the R2 track's start velocity 10/s; enter 0.33.

| Motion | Mac | Before (judge #3, reproduced) | After | rms (value / time) | Status |
|---|---|---|---|---|---|
| MC exit, 1 Finder, pointer off the windows | R2 exit, 2-98 % 267 ms | 351 ms, first state twice, 0.96 plateau 3-4 frames, 0.044-0.059 / 20-30 ms | basic loop: 267 ms, no repeat, 0.010-0.011 / 4.6 ms (2 of 3; 1 run 0.055 with a late first frame); threaded: 250-333 ms, 0.029-0.040 / 16-18 ms (skipped mid-flight frames) | 0.010 / 4.6 ms (basic) | fixed with the basic loop; threaded improved |
| MC exit, 1 Finder, pointer on the thumbnail | as above | 0.05 hover frame repeated | basic: 283 ms, 0.0087 / 3.3 ms, no repeat (3 of 3); threaded: the 0.05 frame twice in 4 of 4, 0.021 / 11.6 ms | 0.009 / 3.3 ms | matches (basic) |
| MC exit, Finder + Settings overlapping | as above | 350-366 ms, 0.046-0.051, a 6 % step at the end (Settings landed under the focused Finder) | 300-333 ms, 0.035 / 18-20 ms, end step 1.3 % | 0.035 | improved; the share-of-change metric runs long with two overlapping windows |
| MC exit, 3-4 windows | as above | - | 200-260 ms, 0.04-0.09 / 24-47 ms, frame gaps in most runs (both loops) | 0.05-0.08 | the metric runs short with small thumbnails; gaps from host load |
| MC enter, 1 Finder | R2 enter, 333 ms | 333 ms, repeats 0.23 0.23, 0.89 0.89 | basic 0.33: 327-338 ms, 0.014-0.038 / 11-24 ms, no repeat in 6 runs; threaded: the first frame twice in 4 of 4 | 0.014-0.038 | improved |
| HUD appear | verify/A hud-appear-fit | 0.040-0.045 / 25-32 ms, 0.57 -> 0.76 step | with Glass sub-point edges (87022d7, plugin 016799b..): 0.022-0.024 / 16-18 ms, the step now .51 -> .61 (twice its neighbours); glass at s instead of s^2: 0.013-0.023 (better) | 0.022-0.024 | improved; s^2 kept (see dismiss) |
| HUD dismiss | REA s^2, s = spring 0.48669, 2-98 % 283 ms | 4-12 % snap (judge) | glass at s^2: 265-300 ms, 0.011-0.017 / 3.6-4.2 ms, no snap; glass at s: 0.011-0.029 | 0.011-0.017 | matches (no snap seen in 6 runs) |

Render loop (QSG_RENDER_LOOP=basic vs the default threaded loop, same session, 5 runs each, warm):

| Row | threaded | basic | better |
|---|---|---|---|
| MC exit 1 window (above) | 0.029-0.040, hover repeat 4/4 | 0.009-0.011, 0 repeats | basic |
| MC enter 1 window | first frame twice 4/4 | 0 repeats | basic |
| CC open vs REA spring 0.25 | 0.005 / 1.2 ms in 4 of 5, first visible 61-64 ms | 0.006-0.013 / 2.3-5 ms: 0.14 -> 0.37 (a frame lost after the layer maps) every run | threaded |
| HUD appear vs hud-appear-fit | 0.031-0.037, 2-98 % 467-483 ms (Mac 467) | 0.029-0.036, 500-516 ms | mixed (rms basic, duration threaded) |
| NC open (alpha, panel) | 350-367 ms, 0 repeats | 366-384 ms, 0 repeats | threaded by a frame |
| Spotlight open | 117-134 ms, 0 repeats | 117-134 ms warm; the first open after start: first frame at 0.55 | equal warm |
| Spotlight + HUD at once | 0 repeats, 250 ms | 0 repeats warm; first run after start a 245 ms stall (basic renders every window on the GUI thread, first pipeline builds block all) | threaded |
| Dock press (input to first changed frame) | 12-13 ms | 12 ms | equal |
| qs CPU at rest, 30 s | 1 tick | 0 ticks | equal |
| qs CPU, the whole bench | 351 ticks | 320 ticks | basic |
| qs anon RSS after start | 172 MB (long-running) | 137 MB (fresh); not compared at equal age | not decided |
| Multi-monitor | not measured | not measured | - |

Not adopted: CC open and the first-use stalls are worse with the basic loop, so not every row is as good or better.
The env stays unset; a shell-side switch is one line (`//@ pragma DefaultEnv QSG_RENDER_LOOP=basic` in shell/shell.qml).
The Finder uses the basic loop since b65ebe8 (Quick Look first frame).


## Session 8 (2026-11-11): unlock stall, Dock drag-off, full-screen menu bar, HUD frame trace

Headless MBA, mcap + a temporary GUI-thread trace in the shell (Date.now() per event, mapped to mcap's clock); per-frame
series in the CSV (`*-s8`).

Unlock (48bacc7). Order per unlock, ms from PAM success: lock surface frame (busy off) 0-8, reveal overlay first swap 34-58,
Hyprland `openlayer` 2-7 later, release (lock surfaces destroyed in the same ms), first reveal tick 10-16 later. In 2-3 of
30 unlocks (light 3/30, dark 2/30) the GUI thread is blocked 106-163 ms starting within 2 ms of the lock surfaces'
destruction and ending with the overlay's queued swaps (about Qt Wayland's 100 ms frame-callback wait plus cleanup; the
blocked call could not be sampled: ptrace and perf are not allowed for the shell's process here). A lock surface kept
rendering through the release did not reproduce it (6 of 6 clean). With the clock started at the release, those runs
showed 3-5 frames between lock picture and desktop. Now the clock starts on the first tick after the release; a 160 ms
stall injected right after the release, 5 runs each: before 3 frames in the fade, +0 held 9-10 frames; after 11-12
frames, nothing held.

| Unlock, 95 % from the avatar step (+0) | Mac (B3) | Before (28 clean dark runs) | After (60 + 10 dark runs) |
|---|---|---|---|
| fade seen (frames between 0.1 and 0.9, clock region) | yes | 11-13; 3-5 in stalled runs | 6-16 in 70 of 70 |
| first frame repeated | (not in the table) | 1 in most runs | 1 of 70 |
| menu bar 5 % / 95 % | +137 / +250 | 134-153 / 252-269 | 125-142 / 244-263 |
| Dock 95 % | +226 | 227-246 | 222-224 or 238-240 |
| clock 95 % | ~+219 | 217-239 | 214-215 or 228-232 |
| field 95 % | ~+219 | 211-240 | 209-210 or 224-227 |

Both before and after the crossings fall in two modes one frame apart (which vsync shows the +0 frame); the date
region is mostly wallpaper and crosses 95 % on the dim's tail (not comparable).

| Motion | Mac | Measured | Status |
|---|---|---|---|
| Dock drag-off drop: icon + Remove bubble fade (5e3e54e) | Q-dock-17: linear 0.25 s | 2-98 % 236 ms, rms 0.013 vs linear 250 ms | matches |
| Full screen menu bar peek in (24ec60f) | Q-menubar-33: ~0.15 s, roughly linear | linear 150 ms, rms 0.004-0.006 clean; one skipped frame in 4 of 6 runs (rms 0.027-0.030) | matches when no frame is lost |
| Full screen menu bar peek out | ~0.17 s | linear 170 ms, rms 0.004; skipped frame in 6 of 7 runs (rms 0.024-0.028) | as above |
| Dock click on a minimized app (77014c6) | #47 restore 0.5 s ease-in-out | changed-share 0.012 at +46 to 0.94 at +495 ms (plugin-motion genie) | restores now (before: only special:minimized shown) |

Skipped frames (peek, HUD appear). During the peek fades and 6 HUD appears the shell's GUI ticks ran every 15-17 ms
and its window swapped every frame (trace), yet mcap shows one value skipped mid-fade (peek 4-6 of 6-7 runs; HUD
0.57 -> 0.66, 0.14 -> 0.23, 0.61 -> 0.71 in 4 of 6): the lost frame is between the shell's swap and Hyprland's
presentation, not a stalled shell thread. Separately the HUD's GUI thread stalls 80 ms right after its first appear frame
(5 of 5) and 160-210 ms at the start of the hide; and in every run two small steps 0.867 -> 0.895 and 0.918 -> 0.943
(twice their neighbours) at the same places. The Glass sub-point edges are sent each frame in 1/16 pt steps (Glass.qml
n = 17 for the HUD's 300 pt width).

Dock label fill, dark (task from judge #3: grey 121 vs the Mac's 131). Over solid wallpapers with the shell's label:
dark 34 / 121 / 184 over black / grey / white (Mac 31 / 131 / 180), light 131 / 189 / 249 (Mac 131 / 192 / 249). The
label sits on the Dock material (12 / 107 / 175 dark here, the Mac's 12 / 108 / 176) and the fill is a linear blend
k + dst (1 - a); the Mac's lift over its own material (+19 / +23 / +4) is not linear in dst, so no a, k reaches all three:
least squares (now) rms 6.0, max 8.5 at grey; minimax rms 6.4, max 6.4 (37 / 125 / 186). Left as is.

## Session 9 (2026-11-11): user-report fixes, full-screen peek, HUD glyph, Dock drag-off (after judge #4)

Headless MBA 2560x1664 at 2x (dist config copy, own state), mcap k 1-2; per-frame series in `motion-measured.csv` (`*-s9*`).

| Motion | Mac | Before | After | Status |
|---|---|---|---|---|
| Full screen menu bar peek, shown at all (a0a9cf4) | Q-menubar-33 | judge #4: missed 1 of 3 entries | 10 of 10 entries (3 at 1.2 s, 7 at 0.35 s after the full screen) | fixed |
| Peek in | ~0.15 s, roughly linear | first frame repeated 6 of 6 (judge #4) | .20 .40 .50 .61 .70 .81 .92 1.00 in 16.7 ms steps, no repeat in 10 of 10; one value skipped (.20 -> .40) in most runs | repeat fixed, skip left (lost after the shell's swap, session 8) |
| Peek out | ~0.17 s | as above | .20 .29 .38 .48 .57 .66 .75 .84 1.00, no repeat in 10 of 10 | matches |
| HUD speaker glyph, 1 -> 2 waves (cc232d4) | SystemBannerUI: Image(systemName:) swapped inside withAnimation(spring 0.2 / 0.85), no symbol effect; recording: HUD glyphs cross-fade with both visible (volume <-> brightness, "about 3 frames") | one frame | .09 .30 .50 .67 .80 .89 .95 .98 1.00 (3 runs, identical), the content spring | per-wave fade inferred: no Mac recording of a wave change |
| HUD glyph, 2 waves -> slash / slash -> 1 wave | as above | one frame | .09 .27 .44 .58 .69 .76 .87 .96 .99 / .14 .42 .58 .72 .83 .90 .95 .98 | as above |
| HUD appear over the wallpaper (not flat) | hud-appear series | (judge #4 .034-.045 over flat backdrops) | rms .007 / .011 / .013, time rms 3.5-5.8 ms, 2-98 % 502-517 ms (Mac 483) (3 runs) | not comparable with the judge's backdrops |
| HUD dismiss over the wallpaper | 0.96 .85 .71 .56 .45 .36 .29 .23 .18 .14 .11 .09 .07 .05 .04 .03 | (judge #4 334-386 ms) | .97 .85 .72 .60 .50 .41 .34 .28 .24 .19 .16 .13 .10 .09 .07 .06, rms .029-.032 (3 runs): ours is the REA model (glass s^2, content s); the white glyph and bar at s dominate the least squares over a dark wallpaper | unchanged: needs a Mac dismiss track over flat grey to tell whether the content also goes at s^2 |
| Dock drag-off on an empty desktop (95c796e) | Q-dock-17 | 0 of 1 (judge #4: nothing happens) | 10 of 10 remove the tile | fixed |
| Liquid Glass slider: mouse-up to appearance.json / plugin tint_amount (22731a8) | preview one frame about 50 ms after mouse-up | 259 / 267 ms | under 55 / 77 ms (poll step about 20 ms) | matches within the poll step |

Not done in this session: unlock per-region timing (B3), Mission Control Spaces band and first frame, Spotlight open blur,
the HUD's GUI-thread stalls (not re-traced after the glyph rewrite, whose Shapes are now built once instead of per symbol).

## Session 10 (2026-11-11): where the lost frames come from, unlock per region, Mission Control, HUD, peek

Headless MBA 2560x1664 at 2x, own state, mcap rebuilt from 088840a; per-frame series in `motion-measured.csv` (`*-s10*`).
Other headless sessions ran on the host. Not re-measured at scale 1.6.

Cause of "one value lost mid-motion" (judge #4 gap 3; MOTION-PLUGIN "two shell steps inside one compositor frame"):
with more than one window exposed, Qt's threaded render loop does not advance animations from a window's frames but
from a GUI-thread timer of int(1000 / 60) = 16 ms (qtdeclarative 6.10.2 `qsgthreadedrenderloop.cpp`
`startOrStopAnimationTimer`, lines 1096-1136: "with more than one window exposed we have to use the same path as the
no-windows case"). The shell always has several windows. Trace of the unlock overlay: ticks 16.0 ms apart against
frames 16.7 ms apart; a tick's value is on screen 8 to 24 ms later; about every 0.4 s two ticks fall between two frames
and one value is never drawn. The default animation driver also adds 16.7 ms of animation time per 16.0 ms tick, so
timer-driven animations run about 4 % fast. `shell/components/FrameClock.qml` ticks on `QQuickWindow.afterAnimating`
(GUI thread, right before each frame of that window is built) and counts frames; `FrameSpring.qml` evaluates a spring on it.

Tried and not adopted: `QSG_USE_SIMPLE_ANIMATION_DRIVER=1` (animations advance in each window's polishAndSync on the
wall clock, no timer). 8 runs each: Spotlight open repeats its first frame in 7 of 8 (.05 .05 .16 .33, 2-98 % 137 ms
against 111), Control Center open shows uneven steps and a repeat in 2 of 8 (timer driver: a missing value in 2 of 8),
HUD appear no better. `ShellWindow`'s glass re-measure on FrameClock was tried too: Spotlight repeated its first frame
in 6 of 6 (the forced frame has no new animation value), reverted.

GUI stall at unlock (106-163 ms, session 8): `QSGThreadedRenderLoop::windowDestroyed` waits for the destroyed lock
surface's render thread, which waits in `QWaylandGLContext::swapBuffers` -> `waitForFrameSync(100)` for the frame
callback of its previous frame; that callback never comes once the lock is released. `animationStarted()` posts an
update to every window, so the lock surface often has a frame in flight right then. Lock now releases at least 20 ms
after a lock surface's last frame.

| Motion | Mac | Before | After | Status |
|---|---|---|---|---|
| Unlock, clock 95 % from the avatar step (35ba87e) | ~+219 (B3) | 40 dark runs: 213-216 with one value lost (29), 229-233 one frame late (10) | 30 runs: 221 [221-223]; 16 more with the counting clock: 221-224 | matches |
| Unlock, field 95 % | ~+219 | 207-227 | 214 [213-216] | matches |
| Unlock, Dock 95 % | +226 | 221-241 | 227 [227-229] | matches |
| Unlock, menu bar 5 % / 95 % | +137 / +250 | 123-145 / 242-263 | 137 [137-139] / 252 [251-254] | matches |
| Unlock, wallpaper un-dim | from +0, .19 at +33 | .03 .11 .19 (starts at +0 here; judge #4 saw +152 under load) | .03 .12 .20 | matches |
| Unlock, lost or repeated value | - | lost in 29 of 40 | 0 of 30 | fixed |
| Unlock, GUI stall at the release | - | 1 of 40 to 6 of 12 | 0 of 86 | fixed (cause above) |
| Unlock, Return to the avatar step | 367 ms (PAM) | 109-212 ms | 94-156 ms | - |
| Lock-in, menu bar 95 % / clock / field | +67 / ~+196 / ~+214 | (judge #4: 67-74 / - / 191-222) | 65 / 191 / 216 (8 runs) | matches |
| Mission Control enter, 2 terminals partly overlapping (fd20e46) | R2 enter series, 333 ms | judge #4, 1 window: first frame twice 3 of 3, 319-335 ms, .013-.024 | .09 .15 .24 .34 .44 .53 .62 .69 .75 .80 the same in 8 of 8 (one run skipped one value), no repeated first frame, 318-322 ms, rms .026-.028 | repeat fixed; rms not comparable (new layout, other windows) |
| Mission Control exit, same | R2 exit series, 267 ms | judge #4, 1 window: 267-285 ms, .013-.019, a skipped frame 2 of 3 | .20 .39 .54 .65 .74 .80 .84 .87 .89 in 8 of 8, 277-281 ms, rms .029-.035, no skipped value | skip fixed; the windows now move less (Mac layout), the share-of-change metric runs ahead early |
| Mission Control layout | mission-control.json (1 / 2 / 4 / 5 / 7 windows) | scaled grid | every frame within 1 pt (shell test) | matches (decoded from WindowManager) |
| HUD appear, light Tahoe (eea3441) | hud-appear-fit, 483 ms | 492-520 ms, rms .026-.037, a value lost in 6 of 8 | 482-519 ms, rms .032-.035, same series every run, one run with an 84 ms gap | no lost values; rms unchanged (ours starts slower: .01 .03 .04 .07 .10 vs .02 .06 .12 .18 .25) |
| HUD dismiss | series .96 .85 .71 .56 .45, 283 ms | 282-291 ms, rms .006-.037 (.02-.04 when a value was lost) | 270-288 ms, rms .011-.016 | matches |
| HUD dismiss, content at opacity^2 (tried) | as above | - | 222-233 ms, rms .032-.038 | dropped: the binary has one .opacity on the content |
| Full screen bar peek in (eea3441) | ~0.15 s, roughly linear | .20 .40 .50 .61 .70 .81 .92 1.00, one value skipped in most runs | .11 .22 .33 .44 .56 .67 .78 .89 1.00 in 10 of 10, 144 ms | fixed (B5) |
| Full screen bar peek out | ~0.17 s | .20 .29 .38 ... | .10 .20 .29 .39 .49 .59 .69 .78 .88 .98 in 10 of 10, 159-168 ms | matches |
| Spotlight open (timer driver, unchanged) | REA open spring | - | .05 .20 .37 .56 .73 .86 .97, a value missing in 4 of 8, 2-98 % 99-120 ms | open: still on a NumberAnimation |
| Control Center open (unchanged) | - | - | .04 .07 .19 .31 .44 .55 .66, a value missing in 2 of 8, 235-245 ms | open: as above |

Left open: Spotlight open (blur 25 -> 0 and the frame clock), Control Center open and the other Qt-animated panels still
run on the 16 ms timer; moving a panel to FrameSpring is the fix that worked for Mission Control, the HUD and the peek.
The HUD's appear fits the Mac worse than its dismiss (slow start); the 84 ms gap in 1 of 8 appears was not traced.

## Session 11 (2026-11-11): every shell motion on the frame clock, Spotlight open blur, zoom, Mission Control band

Headless MBA 2560x1664 at 2x, own state, mcap from 088840a, small regions (240 x 240 pt and less; Mission Control full
screen at k 4). "Before" is the tree at 7176610 in a second headless session on the same host, measured the same day
with the same commands. 8 runs per row unless said. Per-frame series of the last 8 runs of eleven rows:
`motion-measured.csv` (`*-s11-after-run*`; that batch ran partly in a loaded phase, see the gap column). Other headless sessions ran on the host: at times the compositor's own presentation times were
uneven (intervals of 11 to 33 ms instead of 16.7; column "gap runs" = runs with an interval over 25 ms). A run with
such a gap steps over a value on purpose (FrameClock keeps the speed), so those runs are counted apart.

What changed (e87f6b0, 2ba6758, 24c14cd): `ui/HyprK/FrameClock.qml` (moved from the shell), `FrameAnim` (a
NumberAnimation's members on the clock), `FrameEase` (what a Behavior did), `SpringCurve` evaluated in closed form on
the clock, HyprK `Spring` stepped on it, `ShellWindow`'s glass settle on it. Three things the first port showed:

- Qt polishes a window's items before `afterAnimating`. Quickshell sends the blur region (glass shapes, the opacity
  marker) from the content item's polish, so a value set in the tick reached the compositor one frame after the
  content. The clock now polishes the content item in the tick's frame (`ensurePolished`), or when the frame before
  has been swapped if that one is still on its way (after idle Qt builds two frames back to back, 1 ms apart, and
  from then on a frame is built while the one before waits for its frame callback). Control Center close without
  this: .07 .22 .25 .43 (the glass one frame ahead of the content); with it .07 .22 .40 .54.
- An effect created in the tick is not polished for that frame: Spotlight's close blur layer, switched on by the
  first blur value, showed one empty frame (the bar gone, then back at .22). It is switched on before the first frame.
- One value read by two windows (Control Center panel and its dim window; Cmd-Tab panel and its fill surface) reaches
  the second window a frame late or not, by turns. Each window now runs the same curve on its own frames.
- A window shown less than 150 ms ago does not tick for its first two frames: the compositor presents a new layer
  from about its third buffer (session 4). Hold 0: .02 .02 .17; hold 1: three different starts in 6 opens; hold 2:
  .06 .17 .31 .45 in 7 of 8.
- The step over a missed frame is read from the tick's phase against the earliest phase of the run (2ba6758), not
  from the gaps between frameSwapped signals: those jitter by half an interval on the GUI thread and skipped values
  although every frame was shown.

| Motion | Mac | Before: runs with a lost or repeated value, 2-98 % | After: same series in, 2-98 % | rms vs Mac (value / time) | Gap runs (after) |
|---|---|---|---|---|---|
| Control Center open | REA spring 0.25, critical | 4 of 8 (.20 missing), 233-251 ms | 7 of 8 (.06 .18 .32 .45 .58 .69 .77 .83; one run starts .10), 248-250 ms | 0.0029-0.0042 / 0.6-2.4 ms vs the spring (session 7: 0.005 / 1.2 ms in 4 of 5) | 0 of 8 |
| Control Center close | same spring | 8 of 8 lost one, 233 ms | 8 of 8 (.07 .22 .40 .54 .66 .75 .82 .87), 233-234 ms | 0.012-0.013 / 3.4 ms vs the spring (the region holds the dim too) | 0 of 8 |
| Spotlight open (no blur, e87f6b0) | REA open spring | 5 of 8 lost one, 117-135 ms | 8 of 8 (.06 .20 .37 .56 .72 .86 .97), 133 ms | - | 0 of 8 |
| Spotlight open with the content blur 25 -> 0 (1f3ea25) | REA: blurRadius spring reversed | no blur | 10 of 10 and 8 of 8 (.05 .18 .34 .51 .67 .81 .92 .95, then the blur resolving to .99), 250 ms | bar width vs the open spring from the 4th visible frame, 1 px steps: 0.0023-0.0024 in 10 of 10 (before, no blur: 0.0015-0.0043 in 4) | 0 of 18 |
| Spotlight close | REA close springs | repeated .06 in 5 of 8, lost one in 4 of 8, 100-135 ms | 8 of 8 (.07 .22 .40 .59 .75 .88 .98), 133 ms | no Mac track | 0 of 8 |
| Spotlight mode list | Q-panels-26 share series, 167 ms | no two alike in 8 (repeats and lost values) | 8 of 8 quiet (.34 .34 .45 .60 .82; the first step is the panel's glass and shadow appearing, as before), 100 ms | 0.072-0.076 / 8 ms (before 0.058-0.106); share-of-change over the list region, not the edge reading of session 2 | 5 of 8 in the last run |
| Notification Center open | spring 0.3 | 1 of 8 lost one, 350-370 ms | 7 of 8 quiet (one lost a value), 383 ms | not re-fitted (alpha over the cards, not the edge) | 4 of 8 in the last run |
| Notification Center close | nc/motion.json | 4 of 8 lost one, 183-200 ms | 8 of 8 quiet (.07 .18 .31 .44 .57 .67 .76 .83 .88 .93), 200 ms | as above | 6 of 8 in the last run (2 with a repeated value) |
| Banner in | nc/motion.json | 3 of 8 lost one, 2 of 8 a repeated first value | 6 of 8 quiet (2 with the first value .03 twice) | not re-fitted | 7 of 8 in the last run |
| Menu fade (close) | 0.18-0.2 s | 8 of 8 lost one, 150 ms | 8 of 8 quiet (.16 .31 .45 .58 .69 .79 .86 .92 .97), 166-172 ms | - | 11 of 16 after 2ba6758: every lost value at a gap |
| Menu blink | off 4, on 3 frames | off 4 / on 3 in 5 of 8 (session 2) | counted in frames by construction; not captured | - | - |
| Dock hover label fade (magnification off) | cosine 0.292 s, #42 c | 0 of 8, 264-270 ms | 8 of 8 quiet (.02 .04 .08 .14 .21 .30 .38 .47 .55 .64 .72 .79 .85 .91 .95 .98), 262-284 ms; label on its own namespace | 0.013-0.015 / 3.8-4.4 ms in 5 clean runs (session 5: 0.011 / 4.4 ms) | 3 of 8 in the last run |
| Dock magnification in | cosine 147 ms | icon top non-monotone and repeated in 6 of 6 (45.5 44 43 44.5 pt) | 5 of 6 the same rising series (29.5 37 44.5 49 50 pt) | not fitted (the region holds the label) | 0 of 6 |
| Dock launch bounce | H 18 pt, P 0.70 s | works | works, symmetric per frame in 3 of 3 | not re-fitted (region clipped at 9 pt) | - |
| Cmd-Tab dismiss | #42 b, 200 ms | not measured here | 5 of 8 the same (.12 .15 .20 .28 .36 .46 .57 .69 .79 .87 .94 .98), 3 differ in one value by at most .03, 200-250 ms | 0.033-0.042 / 9-16 ms over an app window, whose return to the active look adds a first step of .10 (session 5 over the wallpaper: 0.009) | 0 of 8 |
| HUD appear (already on the clock) | hud-appear-fit, 483 ms | - | quiet: 7 of 8 the same, 518-533 ms | not re-fitted | 8 of 8 in the last run |
| Mission Control exit, one Settings window (ad4599e) | R2 exit series, 267 ms | session 10, 2 terminals: 277-281 ms, 0.029-0.035 | 8 of 8 (.21 .36 .47 .57 .64 .71 .76 .80), 266-270 ms | 0.0105-0.0109 / 5 ms | 1 of 8 |
| Mission Control enter, same | R2 enter series, 333 ms | session 10: 318-322 ms, 0.026-0.028 | 7 of 8 (.10 .22 .33 .43 .52 .59 .65), 350 ms | 0.0077-0.0095 / 4.3 ms | 0 of 8 |
| Unzoom, menu bar band / Dock band (7326d90) | 267 ms in all | 417 / 467 ms (bar and Dock came back as after a full screen) | 184 / 250 ms (window rect 317 ms) | - | 0 of 6 |
| Appearance switch from Settings (b80928a) | AppKit cross-fade 0.5 s (plugin 911cbe1) | Settings first, shell 146-1063 ms later | sidebar, menu bar and Dock: one ramp .02 .05 .10 .15 .22 .30 ... over 400-420 ms, both directions, no step before it | - | 0 of 12 |

Scale 1.6 (same session, once): Control Center open / close, Spotlight open / close, Notification Center close and the
menu fade show the same values as at 2x in the runs without gaps (NC close and the menu fade 8 of 8); Control Center
and Spotlight had gap runs in 5 of 8, and the unmodified tree at 1.6 had them in 12 of 16 with no two runs alike. The
menu fade's second value reads .42 at 1.6 (.30 at 2x, 8 of 8): not traced. Appearance switch at 1.6: Settings sidebar
and menu bar the same ramp; the Dock region was not read cleanly.

qs CPU at rest over 30 s: 4 ticks before, 1 after (both idle, no panel open).

Left on Qt's timer: the banner list's ListView transitions (`displaced`, `move`: a ViewTransition takes Qt animations
only), RubberBand's snap back, the lock's minute change and field shake, HyprK Switch / Slider's own NumberAnimations
(the shell does not use those controls; Settings and Finder have one window each, where Qt animates per frame).
Not re-measured: NC push and clear, banner out, Dock autohide, slot grow / shrink, drag-off, submenu delay, menu blink,
Apps, HUD dismiss, full-screen peek, lock.

Open: (1) frame gaps. With the motion tied to frames, a compositor frame that comes late is visible as one stepped-over
value; in a quiet phase a row is 8 of 8, in a loaded one most runs have a gap, and in three back-to-back comparisons
the unmodified tree's session showed none while this one did (Control Center close 0 of 20 against 12 of 20; NC close 0
of 16 against 10 of 16). The GUI thread's ticks were then 26-30 ms apart although the tick itself took under 6 ms;
what delays the frame callback there is not traced. (2) Inside the Dock's glass Mission Control still shows the real
window under the Dock.

## Session 12 (2026-11-11): the frame gaps are the compositor's, not the port's; old against new back to back

Question from session 11: under load the tree on the frame clock showed runs with a presentation interval over 25 ms
where the tree at 7176610 showed none (Control Center close 12 of 20 against 0 of 20). Answer: that comparison measured
two compositor instances, not two trees. With both trees captured at the same time, in sessions of the same age and
with the trees swapped between the sessions, the gap runs are the same within the sampling noise. No piece of the port
was dropped and `FrameClock` is unchanged.

Method. Two own headless sessions (MBA 2560x1664), each Hyprland started by its own command and each shell restarted
the same way; `old` = shell/ and ui/ of 7176610, `new` = HEAD, both on the same plugin build. A row is captured in
both sessions at the same moment (mcap, one reference frame, region 240 x 240 pt or the surface), then the trees are
swapped between the sessions and the row is run again: 10 + 10 runs per tree. A run counts as a gap run when an
interval between two presented frames inside the motion is over 25 ms (second number: over 31 ms, a whole missed
refresh); frames = presented frames from the first value over .01 to the first at .985 or more. Load: busy loops, at
first on the whole machine, then (the user was working on the host) the sessions and 6 loops at nice 19 pinned to
cores 12-15. The regions hold more than session 11's (the dim, the menu bar title), so the values differ from that
table; old and new are read from the same regions.

| Motion | scale 2, quiet: old | new | scale 2, pinned load: old | new | scale 1.6, pinned, no loops: old | new | scale 1.6, pinned load: old | new |
|---|---|---|---|---|---|---|---|---|
| Control Center open | 4 / 1 of 20, 15.2 frames | 5 / 1 of 20, 15.6 | 14 / 9 of 20, 12.6 | 12 / 8 of 20, 14.4 | 9 / 9 of 20, 13.6 | 11 / 7 of 20, 14.6 | 18 / 17 of 20, 9.5 | 20 / 20 of 20, 10.3 |
| Control Center close | 0 / 0 of 20, 14.9 | 0 / 0 of 20, 14.9 | 5 / 5 of 20, 14.0 | 7 / 6 of 20, 14.0 | 4 / 3 of 20, 13.8 | 6 / 6 of 20, 13.2 | 19 / 18 of 20, 9.3 | 20 / 20 of 20, 9.7 |
| Notification Center open | 0 / 0 of 20, 20.6 | 0 / 0 of 20, 22.3 | 7 / 5 of 20, 19.9 | 11 / 7 of 20, 20.2 | 15 / 12 of 20, 19.1 | 15 / 12 of 20, 20.0 | 20 / 20 of 20, 12.3 | 20 / 18 of 20, 12.4 |
| Notification Center close | 0 / 0 of 20, 9.6 | 0 / 0 of 20, 10.0 | 11 / 8 of 20, 8.3 | 5 / 3 of 20, 9.8 | 8 / 6 of 20, 8.4 | 12 / 9 of 20, 8.5 | 17 / 16 of 20, 6.2 | 20 / 20 of 20, 6.3 |
| Menu fade | 0 / 0 of 20, 9.8 | 0 / 0 of 20, 9.9 | 0 / 0 of 20, 9.8 | 2 / 1 of 20, 9.8 | 1 / 1 of 20, 9.7 | 1 / 0 of 20, 9.3 | 16 / 15 of 20, 8.0 | 14 / 9 of 20, 8.7 |
| HUD appear | 3 / 2 of 20, 33.0 | 5 / 0 of 20, 33.6 | 7 / 2 of 20, 32.6 | 4 / 2 of 20, 32.6 | 9 / 6 of 20, 34.1 | 6 / 5 of 20, 34.0 | 20 / 19 of 20, 27.7 | 20 / 20 of 20, 26.4 |
| Banner in | 0 / 0 of 20, 19.6 | 5 / 2 of 20, 18.8 | 7 / 3 of 20, 19.9 | 8 / 5 of 20, 17.8 | 2 / 1 of 20, 20.2 | 5 / 4 of 20, 18.4 | 19 / 19 of 20, 16.9 | 19 / 19 of 20, 15.0 |
| All seven (140 runs per tree) | 7 / 3 | 15 / 3 | 51 / 32 | 49 / 32 | 48 / 38 | 56 / 43 | 129 / 124 | 133 / 126 |

(cells: runs with an interval over 25 ms / over 31 ms, of the runs, mean frames per run.) Whole machine, 18 loops on 16
cores, scale 2 (stopped half way at the user's request): 76 of 82 old, 78 of 82 new, frames per run 6.7-25.2 old against
6.7-25.9 new. Whole machine, 24 loops, Control Center close, three sessions with the trees rotated through all of
them: 10.7 frames per run old, 10.2 new. The quiet columns were taken in sessions 20 to 60 minutes old, which adds gaps
of its own (below); new's banner and HUD rows at scale 2 were captured in the minutes in which this session also ran the
test suites on the host. In sessions a few minutes old on a quiet host: 0 gap runs in 70 (7 rows x 5 runs x 2 trees), the same series in
4-5 of 5 runs for new in Control Center open / close, menu fade, HUD appear, banner in (old: 2-4 of 5); per-frame
series in the CSV (`*-s12-new-run*`, `*-s12-old-run*`).

What the gaps are (second method, the shell's own Wayland trace, WAYLAND_DEBUG=client plus qt.scenegraph.time.renderloop,
both trees under the pinned load, 5 closes each): the panel surface's commits are 20 to 45 ms apart in both trees and
mcap's long intervals of the same runs are 27 to 59 ms, so a gap is a refresh at which that surface had no new buffer,
not a frame the capture missed. The commit follows the frame callback that released it by 1-7 ms on the frame clock
(typically 3-4) and by 0-5 ms in the old tree (typically 2): the tick sits between the callback and the commit, but it
is 1-2 ms of a 16.7 ms period. The callbacks themselves come 20 to 45 ms apart: the time goes between a commit and the
compositor's next frame, inside Hyprland. Tried against it and dropped: running the next frame's tick when the frame
before has been swapped, so that nothing but the scene sync is left after the callback. Under 24 loops it showed 8.5
frames per run against 10.2 for HEAD and 10.7 for the old tree (three sessions, trees rotated).

Why two sessions differ: a compositor that has run for a while costs more per frame. Same tree (HEAD), same quiet host,
captured at the same moment, Control Center close: a Hyprland 65 minutes old (about 2,000 captures, a dozen shell
restarts, scale switches, the load tests) 7 of 8 gap runs and 1,445 ms of compositor CPU per run; one started a minute
before 0 of 8, the same series in 8 of 8, 258 ms per run. For four Control Center open / close without any capture:
4,000-4,750 ms of main-thread CPU against 1,100-2,000 ms, with 7,392 minor page faults against 0, the same number of
syscalls and of frames in a run of three toggles (255 against 265), and the pango thread at 130 ms against 10 ms. It stays with both plugins
unloaded (4,670 against 1,510 ms), so it is in Hyprland 0.57 or aquamarine's headless backend, not in liquidglass,
hyprkmotion or the shell (the shell's CPU was lower in the old session). Not found: what makes it grow. Tried on a
fresh session without effect: 80 Control Center toggles, 500 captures, 30 HUD + banner + menu rounds, 3 scale round
trips, 3 shell restarts. Not tried: an hour of plain uptime, the load tests themselves. perf is not usable on this host
(perf_event_paranoid 4) and gdb cannot attach (ptrace_scope 1).
Not from the scheduler: sessions started from one command share an autogroup, but a compositor alone in its group, two
sharing one, and one set to nice 19 gave the same counts under 10, 18 and 24 loops.

Consequence for measuring: compare trees only at the same time in sessions of the same age, swap the trees, and start
new sessions for a long batch.

Other rows, old against new at the same time, scale 2, quiet, sessions a few minutes old (8 runs each unless said):

| Motion | old | new |
|---|---|---|
| HUD dismiss | 20.5 frames, 314-333 ms; the last step jumps .975 -> 1 | 16.9 frames, 252-267 ms to .985, no jump at the end (.19 .37 .51 .62 .70 .76 .81 .85 .88 .90 .92 .94 .95 .96 .97; old .19 .36 .51 .61 .68 .74 .79 .84 .86 .89) |
| Banner out | 7 frames, 100 ms, .27 .55 .75 .89 .95 .98 .99 in 7 of 8 | 8 frames, 116-117 ms, .28 .56 .55 .76 .89 .95 .98 .99 in 6 of 8: the second value twice. In a second batch of 3: .28 .56 .77 .89 .95 .98 .99. Open: where the repeated frame comes from (the leave spring ticked 9 times, .0167 to .15 s, the first three within 6 ms: Qt builds them back to back after idle) |
| Notification Center push (a second app's card while the panel is open) | 26 frames, 416-437 ms, 2 of 8 the same series | 27 frames, 419-450 ms, 6 of 8 the same series (.15 .29 .42 .52 .64 .69 .76 .80 .82 .85 .89 .91) |
| Notification Center clear all, Apps open / close (`apps open`, read on the bar and on the panel) | one frame, 16 of 16 | one frame, 16 of 16 |

Not measured: Dock autohide, slot grow / shrink, drag-off, submenu delay, bar peek, lock / unlock, and the motions left
on Qt's timer (RubberBand, the lock's minute change and shake, Switch / Slider).

Traced:

- Menu fade at scale 1.6, "second value .42": not reproduced. A region inside the menu body reads .14 .28 .41 .53 .64 .74
  .83 .90 .95 at scale 2 (5 of 6) and .14 .27 .40 .52 .63 .73 .82 .89 .95 at 1.6 (6 of 6). `mcap.py sub()` took every
  output for 2x until aa90d3e, so a sub-rectangle at 1.6 was 1.25 times off; which reading session 11 used is not noted.
- The 1x1 Control Center tile "64 x 63 pt": not a rounding at 1.6. Qt's ellipse region leaves the top row of a full
  circle empty, so the plugin decoded the round buttons as box 64 x 63, r 31.5, one point down, at scale 2 as well
  (`hyprctl liquidglass trace hyprk-controlcenter`). Glass now adds two cells in that row (83a7288): 64 x 64, r 32 at
  both scales; on screen the Display button's rim spans 126 -> 128 px vertically at scale 2 (130 horizontally) and
  101 -> 103 px at 1.6 (102 horizontally).
- Appearance switch: on the shell's shortcut (`hyprk:appearance-*`) the bindings take 8-20 ms and all four windows have
  built their restyled frame within 10-24 ms (6 switches, quiet host; no image is reloaded, the render pass of those
  frames reads 0 ms). The 234-526 ms of MOTION-PLUGIN's loaded runs were taken while this session's whole-machine loops
  ran: the same stall as the gaps above, not a step of the restyle.

## Session 13 (2026-11-11): no motion measured; why a compositor "ages"; what waits

No row was captured in this session: the host's inotify instance limit (128) was used up by five other headless
sessions for most of it (a session needs about 17: qs 14, Hyprland 3), and the work was stopped before a batch could
run. Nothing was added to `motion-measured.csv`.

Correction to session 12 ("what makes it grow was not found"), from the coordinator: Hyprland 0.57.2 leaks one
screenshare session per wlr-screencopy region request at a scale other than 1 (about 45 per mcap run, 1 per grim):
`CScreenshareManager::getManagedSession()` compares a logical box with a buffer-pixel box, and sessions are not stopped
when the client exits. From about 5,000 to 10,000 leaked sessions frames drop. It is not uptime. Patch (not installed):
`/mnt/code/hypr-dev/patches/hyprland-0.57.2-screencopy-session-leak.patch`. For measuring: a fresh session per motion
batch, restarted after at most about 100 mcap runs. `mcap` (3d41b19) refuses `wayland-0` or an unset display without
`-H`.

Still open, unchanged from session 12: banner in (1-3 fewer frames per run under load) and banner out (second value
twice in 6 of 8) are not traced; RubberBand's snap back, the lock's minute change and field shake and HyprK Switch /
Slider still run on Qt's timer (a frame-clock port of RubberBand and of the two lock motions was written and passed the
ui tests, but was not measured and is not committed); Dock autohide, slot grow / shrink, drag-off, submenu delay, bar
peek and lock / unlock are not re-measured.

One number from this session, not a capture: the shell's appearance handshake message (a9e060c) left the shell 52 and
125 ms after the `hyprctl dispatch` that switched the appearance (own session, quiet host, hyprctl's start included).
