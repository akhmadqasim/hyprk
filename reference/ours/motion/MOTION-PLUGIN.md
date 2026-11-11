# Motion fixed in the plugins (2026-11-11)

Follow-up to `MOTION-MEASURED.md` for the rows that needed `plugin/` or `plugin-motion/`. Same method: `mcap`
(`scripts/motion-capture/`) in a headless session (`HYPRK_HEADLESS=1`, MBA 2560x1664@2x), metric `alpha`, compared
with `mcap.py`'s `compare` (value rms at the best time shift, time rms at equal progress 5..95 %, 2..98 % durations).
Per-frame values: `motion-plugin.csv` (motion, metric, t in ms from the trigger, value).

Window captures use a blank `foot` window (no text, cursor hidden), full output at `-k 8`: with text in the window
the client's reflow at the first and last frame added 0.1..0.25 jumps that are not motion. The Mac series are the R2
ones in `MAC-ANSWERS.md` (share of the total pixel change, TextEdit), so the numbers compare shapes and timing, not
pixels.

## Results

| Motion | Mac | Before | After | rms value / time | Commit |
|---|---|---|---|---|---|
| Unzoom | R2 series, 0.33 s ease-out | zoom curve, 2-98 % 269 ms | Mac series, 267 ms | 0.036 / 8.5 ms -> 0.019..0.026 / 7..9 ms (2 runs) | ff4f9d6 |
| Zoom (unchanged, control) | R2 series | 266 ms | 264 ms | 0.010 / 3.2 ms -> 0.010..0.016 / 3.6..5 ms | - |
| Full screen enter | R2 series, ~0.42 s | zoom curve, 301 ms | Mac series, 385 ms (Mac 350) | 0.076 / 51 ms -> 0.033 / 16..18 ms | ff4f9d6 |
| Full screen exit | 0.15 s to 0.47, 0.15 s hold, 0.3 s (R2, no per-frame series) | one step, 300 ms | two steps: 0.54 at 160 ms, held to ~330 ms, done 584 ms | vs the R2 anchors (0,0) (150,0.47) (300,0.47) (600,1): 0.26 -> 0.048..0.057 | ff4f9d6 |
| HUD appear | `hud-appear-fit.json` alpha track | dips 0.70 -> 0.51 -> 0.79 (~400 ms) and 0.30 -> 0.29 (~265 ms): soft rimless glass | monotonic | 0.037 / 25 ms -> 0.026 / 15..24 ms | 80fd49d |
| HUD appear, judge #3 gap 8 | `hud-appear-fit.json` alpha track | 0.55 -> 0.76 in one frame at ~400 ms (3 of 3) | no step: .51 .56 .60 .65 .70 .75 .78 (with the Glass.qml hand-off, scratch shell copy) | 0.048-0.052 -> 0.046 / 28 ms (the rest: our s^2 glass starts slower than the Mac, .01 .03 .05 .08 vs .02 .06 .12 .18) | 016799b + shell hand-off |
| Window close (judge #3 gap 11) | R2 TextEdit alpha 1, .71, .44, .27, .16, .09, .05, .03 | first frame 0.11-0.13 (bezier started at the close, phase-dependent), then .44 .65 .79 .88 .93 .97 1 | .28 .56 .73 .84 .91 .95 .97 .98 in 5 of 5 runs | 0.012-0.028 / 1.4-3.2 ms -> 0.006-0.010 / 0.3-0.8 ms (one run 0.020, fit shift) | this change |
| HUD appear, session 8 (plugin trace) | `hud-appear-fit.json` alpha track | .51 -> .61 step reported after 016799b + 87022d7 | monotonic, steps <= 0.052 (neighbours .037-.050) in 5 of 8 runs; the 3 others each lost one shell frame (the opacity marker skips a value, e.g. .7418 -> .8105), a 0.093-0.101 step that is the client, not the plugin | 0.022-0.029 / 15-19 ms, 2-98 % 516-533 ms (Mac 483) | no change needed |
| Window close, shadow (session 8) | the shadow fades with the window | shadow 1.5-2x too dark while fading (close blur over translucent pixels) | follows the window alpha (SHADOW.md) | 4 pt below: 78 / 86 / 92 vs 77.6 / 85.6 / 90.7 expected | 96fd560 |
| Control Center open | REA spring response 0.25, critically damped | last 3.5 % pops at ~470 ms, 2-98 % 392 ms | (shell hand-off below, verified with a scratch copy) 254 ms, no pop | 0.021 / 16 ms -> 0.0045 / 1.8 ms | hand-off |

## Causes and fixes

**Unzoom, full screen.** Hyprland has one `windowsMove` leaf. plugin-motion (`FrameMotion.cpp`) listens to the
fullscreen event (fired after the layout set the new goals), works out the direction from the last mode it saw
(maximized -> none = unzoom, -> fullscreen = enter, fullscreen -> = exit; zoom stays on `windowsMove`) and moves the
window's position and size animations to a private `linear` config. After each animation tick it sets that config's
speed to `elapsed / 100 / p(t)`, so Hyprland's own percent equals the Mac progress `p(t)`; a hold is a speed that
grows. No per-frame cost outside a transition, no rendering of its own; a new goal or `windowsMove` set back by
Hyprland hands the window back. `plugin:hyprkmotion:frames = 0` turns it off; `windowsMove` off (Reduce Motion) means
no motion as before. `p(t)` (`Frame.cpp`): unzoom and enter play the R2 per-frame series as measured (frame k at k/60
s, linear between frames; enter ends at 1.0 on frame 24 = 0.4 s).

**HUD.** `plugin/src/Shape.cpp`: the shell puts the materialize hole on the box's middle row and the shadow hole
(`shadow: false`) one row lower at the centre column, computed from the geometry it measured; Quickshell builds the
shape region from the geometry at commit. While the capsule scales these differ by a row, so in some frames the
shadow hole sat on the middle row and was read as materialize 0.5 (logged region per frame: box 969,45 294x64, hole
row 33 = box middle). Holes are now told apart by structure: of two hole rows the upper is materialize; a lone hole at
the centre column (+-2 px; that column stays put while a shape scales about its centre) is the shadow marker,
elsewhere materialize; rows within 2 px of the expected one count.

**Control Center.** Not in the plugin and not the opacity marker. The glass region is integer logical px:
Quickshell's `Region { item }` truncates the origin and rounds the size up. While the panel scale is 1 + 0.01 (1 -
fade), a tile at an integer x maps to x - 0.05 and truncates to x - 1, so every tile's glass sits 1 pt left/up and 1
pt larger until the spring lands on exactly 1, when it snaps (the measured "rims" pop: every tile outline moves 1 pt,
max channel change 185). A scratch copy of `shell/components/Glass.qml` that sets the shape rect from rounded mapped
edges removed the pop (hand-off below).

**HUD appear step (judge #3).** Not a hole-decoding case: a per-frame log of the hyprk-hud region showed the shadow marker
decoded in every frame and materialize 1 (the HUD fades by the opacity marker, smooth 0 -> 1). The capsule scaling 0.9 -> 1 grew
in whole points (region box 277x60 -> 307x66, heights 60 / 62 / 64 / 66), and the last step (64 -> 66 at ~366 ms) lit the
final top and bottom rim rows at once, which the alpha metric reads as 0.21. The plugin now reads sub-point edges from two more
marker holes (README "Sub-point edges"); Glass.qml has to send them (hand-off, tested with a scratch shell copy).

**Window close.** Hyprland starts `fadeOut` at the close, so the first frame drawn after it showed 0.03-0.16 of the fade
depending on where the close fell between two frames (blank foot over white, 2-98 % 133 ms either way). plugin-motion
(`Close.cpp`) now counts frames: the first time the closing window's snapshot is drawn on a monitor is frame 1, and every
time it is drawn after that (right before Hyprland reads its alpha) the fadeout's alpha variable is set to the TextEdit
frame k = 1 + round(elapsed / frame time) (`Frame.cpp closeAlpha`, then x0.6 per frame). `fadeOut` (speed 1.4) only
ends the fadeout now. `CWindowFadeout::alpha` itself is too short to hook. Over stripes the alpha metric also reads the
window's blur-behind (alpha sqrt(a)), so the numbers are over flat white; Finder (0.81) and Terminal (0.59) show the
Mac has the same phase spread in its first frame, TextEdit's 0.71 is the middle. Zoom / unzoom re-measured with the
change (foot, black, window-rect area metric): zoom 0.011-0.014 / 2.8-3.4 ms, 267 ms; unzoom 0.012 / 3.8-3.9 ms, 283 ms
(unchanged code path). Open: one frame, unchanged.

**HUD appear, session 8.** `hyprctl liquidglass trace hyprk-hud FILE` logs, per draw, the layer's 1-px rects, the opacity
marker and the decoded box, radius, materialize and shadow flag; joined per frame with mcap (`hud-appear-s8-*` in the CSV).
With the shell's sub-point edges the box grows in 1/16 pt steps (276.267 x 59.400 -> 306.875 x 66.000, radius = half the
height every frame, no size-class snap: the HUD stays on one recipe), materialize stays 1, the shadow marker is decoded in
every frame and the glass fades only by the opacity marker (= shownness^2). No frame repeats a geometry. The only steps
above 0.052 came with a skipped marker value (a dropped qs frame under host load). Left: the tail is slower than the
Mac's (0.95 at ~455 ms after the start vs the Mac's 0.98): the glass runs at s^2 of the shell's spring (MOTION-MEASURED
session 7: s fits the appear better, s^2 the dismiss; shell decision), and the last 1/16 pt edge steps add 0.018-0.025 each
(the Mac's own tail steps are 0.024-0.031).

**Client minimize (session 8).** Hyprland drops `xdg_toplevel.set_minimized` and X11 iconify, and lists only FULLSCREEN and
MAXIMIZE in `wm_capabilities`, so GTK 4 drew its yellow light disabled. plugin-motion (`Minimize.cpp`, `client_minimize`,
default 1) re-sends the capabilities with MINIMIZE at map (with a toplevel configure: an xdg_surface configure alone left GTK
with empty states, drawn inactive with its CSD inset) and moves a requesting window to `special:minimized`, so the genie plays
as for the title bars, Finder and Settings. gnome-calculator: yellow light enabled, click -> special:minimized, genie ~400 ms.
The plugin title bar's green light now enters full screen and Option-click zooms (it zoomed either way).

## Real app windows (Qt: Finder, Settings), 2026-11-11 follow-up

Judge #2 measured "zoom of a Finder window 300 ms, rms 0.031 / 13 ms" (alpha metric). Reproduced with the real
Finder (`finder/build/hyprk-finder` on a scratch tree) and Settings (`settings/run.sh`), each alone on the workspace,
over a black backdrop. Metric `area`: the window rect per frame (edges of non-black samples), area share between the
first and the last frame, so the client's content does not enter the number (the alpha metric reads a stretched or
cropped picture as motion). Per-frame values: `motion-plugin.csv`, metric `area`.

| Motion | Mac (R2) | Before | After | Note |
|---|---|---|---|---|
| Finder zoom | 267 ms | 0.006-0.009 / 1.8-2.5 ms, 267 ms | same | timing was never off; alpha metric 0.011-0.012 on black |
| Finder unzoom | 267 ms | 0.122 / 38 ms, 300 ms; alpha 0.031 / 12 ms, 317 ms (= judge's numbers) | 0.005-0.007 / 1.7-1.8 ms, 267 ms; alpha 0.004-0.005 | config `render.expand_undersized_textures = false` |
| Settings unzoom | 267 ms | 0.058 / 16 ms | 0.007 / 2.0 ms | same |
| Settings zoom | 267 ms | 0.007 / 1.8 ms | 0.006 / 1.5 ms | |
| Finder / Settings full screen enter | 350 ms (2-98 %) | 0.008 / 4.3 ms, 367 ms (Settings) | 0.007-0.008 / 2.8-4.0 ms, 350 ms | |
| foot (control) zoom / unzoom | 267 ms | 0.007 / 2.1 ms, 0.007 / 1.7 ms | same | foot is not affected |

Cause: not the client's commit timing. Wayland trace + a probe build of the plugin: Finder acks the shrink configure
at once and commits correct-size buffers (1872x1188 at 2x) 2 and 12 ms after it; acked, reported and buffer sizes
all agree from 8 ms on. Hyprland's `calculateUVForSurface` then sees a frame larger than the acked size and, with
`render:expand_undersized_textures` on (default), draws the buffer 1:1 and stretches its last row and column over
the rest ("expand edges"). Qt clients take that path because they set a fractional-scale viewport destination;
foot (integer buffer scale) is "scale unaware" and is stretched. On screen: for the first 120-180 ms of an unzoom the
new layout sat in the top-left corner with a white L of smeared edge pixels and the sidebar's bottom row dragged
down. The same artefact shows with both hyprk plugins unloaded. With the option off the buffer is stretched to the
animated frame, as for every other client. Growing frames (zoom, enter) are unchanged: Hyprland crops the new,
larger buffer to the frame (not configurable), so the final layout is revealed from the top-left; AppKit relayouts
every frame instead (live resize), which a compositor-driven animation cannot do without sending a configure per
frame (not done).

## Full screen REA (27.2.1 dyld cache and Dock, 2026-11-11)

Decoded (addresses unslid; AppKit from the dyld cache, Dock arm64e; work files were in scratch, removed):
- `NSFullScreenTransitionDuration`: read only by `__NSFullScreenTransitionDuration` (0x18a6a3de8), default 0.5 s
  (`fmov d0,#0.5` 0x18a6a3e48), used only when the Dock's reply is NaN (0x18ae665d8 enter, 0x18ae2d3ac exit).
- Dock replies 0.5 s to both requests (enter FUN_100130044, exit FUN_10011fa54; 2.5 s with `slow`); Split View
  tiles 0.25 s.
- AppKit `_NSFullScreenTransitionOverlayWindow`, enter (0x18a7a49ac / block 0x18a7a4e74) and exit (0x18a7a5160 /
  0x18a7a5408) alike: the window frame goes from start to target on `functionWithControlPoints(0.25, 0, 0, 1)` over
  the full duration (0x18a7a4f0c, 0x18a7a54a8); the after-contents layer fades in on (0, 1, 1, 1) over half of it
  (0x18a7a5034, 0x18a7a5678). Reduce Motion: linear opacity cross-fade over the duration.
- Dock Space slide (FUN_1000c27c8 from 0x10018b3bc enter and 0x10018c7dc exit, duration 0.5, flag 1): tick
  FUN_1000c60f8 eases `p = 0.5 - 0.5 cos(pi t / T)`; outgoing desktop and the full-screen Space move together
  (FUN_1000c52e0, offset p x (screen width + gap)).
- Dock bar: each slide frame (FUN_1000c4df8 -> FUN_1000c5c70) interpolates the per-Space Dock visibility linearly
  by that same p, so the Dock leaves and returns on the 0.5 s cosine.
- Menu bar on exit: `_doSucceededToExitFullScreen` calls `startMenuBarAnimation:` with the Dock's 0.5 s
  (0x18ae2ca54..5c), at the start of the transition. On enter AppKit only sets the presentation options;
  `+[NSMenuBarPresentationInstance _transitionDuration]` defaults to 0.15 s (0x18b00a964, constant 0x18b7eea18).
- `WASpaceFrameAnimation` (vtable 0x1002cccf0) is only built from FUN_1001cfefc, no caller on the full-screen paths
  found: most likely Split View (medium confidence).

Checks: (0.25, 0, 0, 1) over 0.5 s at 60 Hz is 0.01 0.03 0.09 0.20 0.33 0.45 0.54 0.61 0.67 0.72 0.76 0.79 ...;
the R2 enter recording is 0.01 0.03 0.07 0.14 0.24 0.33 0.45 0.59 0.67 0.72 0.77 0.81 ..., the same curve within
1-2 frames in the middle. Enter keeps the recorded series. Exit had no series: it now plays the decoded curve
(c65308a). Settings exit (area): vs the decoded curve 0.168 / 148 ms -> 0.014 / 7.8 ms (2-98 % 366 vs 383 ms);
vs the old R2 anchors (0.47 at 150 ms, held to 300 ms) 0.044 -> 0.25.
**Conflict, not settled:** no hold or second phase exists in AppKit or Dock code, yet the R2 recording describes
the exit "in two steps" with a 0.15 s hold. Not explained by the code read; possibly the share-of-change metric
mixing the cosine slide, the cross-fade and the window, or a wait between the Dock's reply and the animation. A
60 fps per-frame recording of a full screen exit on the Mac would settle it.

## Full screen strip and first frames (judge #4 gap 2)

- Exit frame 1: not a box at 0,0. The window box was at 0,34, but the plugin title bar is a decoration above the box and
  comes back with the exit, so it was drawn over the strip (the lights over the menu bar titles). The transition now starts
  from the frame including the title bar: on exit the box starts one bar height lower (bar at 34, strip stays black), on
  enter it starts with the bar's rows (the bar vanishes in that frame, the outline no longer jumps by 28 pt). Qt windows
  (Finder, Settings) have no decoration and are unchanged.
- Strip: black in the first enter frame before (120 -> 0 in one frame), gone in the first exit frame. It now cross-fades
  over 0.5 s on the Dock's Space cosine `0.5 - 0.5 cos(pi t / 0.5)` both ways (the strip is part of the full-screen Space,
  which slides on that curve; the duration and curve are decoded, a fade in place of the slide is ours). A full-screen
  window that closes, a workspace switch or Reduce Motion snap it. No cost outside full screen (one map lookup per frame).
- Measured, headless MBA 2x, window edges per frame (left / right / top over a green backdrop, `-k 4`; Settings also from a
  0.5 pt row band): foot enter 0.005-0.006 vs the R2 series (2-98 % 367-369 ms), exit 0.003-0.004 vs (0.25,0,0,1) 0.5 s
  (383-400 ms); Finder enter 0.006-0.007, exit 0.006-0.007 (2 pt samples); Settings 0.002-0.004 / 0.002-0.003 (row band).
  Top edge never above 34 pt in any frame (was 0 in exit frame 1 for foot). Strip over white vs the cosine: rms 0.001
  (enter) and 0.003 (exit), no held frame.
- Still inferred: the menu bar's 0.15 s on enter, and what the notch strip itself does during the Mac's transition.

## Lost frames mid-motion (judge #4 gap 3): what is real

Test client `fcount` (scratch, not in the repo): an xdg toplevel that paints a frame counter as colour on every frame
callback and asks for presentation feedback of every commit; mcap over the same interval. Headless MBA 2x.

- Compositor and headless backend, steady client: every buffer presented once. 0 discarded of about 3,000 commits, feedback
  intervals 16.66 ms median, max 21. mcap's time equals the feedback time of the same buffer within 0.14 ms.
- Capture tool: mcap asked for the next frame only after converting and writing the ready one. 8 pt and 600x400 pt regions:
  0 missed of 900 / 241. Full output: `-k 4` 4 of 241, `-k 8` 1 of 240, `-k 2` 67 of 240 missed, while the compositor
  presented all of them. Fixed in 088840a (next request first, two buffers): 0-1, 0 and 1-3. A miss is a 2-period interval
  in `present_ns`; the JSON now counts them (`long_intervals`). Window rows captured at full output before that fix
  (genie, zoom, full screen at `-k 8` or finer) can carry capture losses.
- Control Center open, 6 runs, 440x240 pt at `-k 4` (the shell's fade takes fixed values per shell frame, .042 .049 .152
  .272 .401 .522 .632 .730 .800 .855 ..., so a missing value is a shell frame that was not shown): a value missing in 6 of
  6. In 4 the presentation intervals around it are 22-34 ms (and one of 8 ms) instead of 16.7: the shell's commit came
  later than a refresh interval. The headless output has no vblank grid (aquamarine `CHeadlessOutput::scheduleFrame`: the
  next frame fires at lastFrame + 1/60 s, or at once when a frame is scheduled later than that, and `commit()` reports
  presented at once), so it shows a late buffer at once with a stretched interval; a DRM output flips at the next vblank,
  a repeated frame. Either way the cause is the late shell frame, not the capture and not the compositor. In 2 of 6 the
  value is missing at regular 16.7 ms intervals: two shell steps inside one compositor frame (not traced further).
- Plugin cost: `plugin:liquidglass:stats` over 3 Control Center opens and closes: glass 0.76 ms GPU per frame, p95 1.12,
  max 1.77. Not a cost spike.
- By code, on every backend: `CWLSurfaceResource::map()` (protocols/core/Compositor.cpp:561) answers a new surface's frame
  callback at once, so the first two buffers of a newly mapped layer fall into one refresh interval (the "frame lost after
  the layer maps" of MOTION-MEASURED session 4). Real on a DRM output too; in Hyprland, not in the plugins.
- Not separated: the host ran 4-6 other headless sessions during these runs, which lengthens shell frames.

## Unzoom tail (judge #4 gap 15)

Window edges per frame (row band, foot): the frame reaches .998 at frame 19 and 1 at frame 20, 2-98 % 283 ms (Mac 267, one
frame of sampling), rms 0.002-0.009 vs the R2 series. The full-output alpha metric's .97 -> 1 over 150 ms is not the
window: at +340 ms the frames still differ from the last only in the Dock band (y 728-832 pt) and the menu bar band. The
shell's Dock and menu bar finish about 190 ms after the frame (shell, not plugin-motion).

## Not derived from Apple data

- Inferred, not traced: the menu bar's enter timing (0.15 s default above).
- The Space slide (desktop out to the left, black Space in from the right): a black Space sliding in behind the
  window over a still desktop was built and measured; it made the match worse (enter 0.056 / 41 ms, exit 0.16 vs
  0.033 / 17 ms and 0.048 without), because the Mac's desktop moves away instead of being covered. It was removed.
  Doing it properly needs the desktop (wallpaper layer and windows) to slide, which is outside the plugins.
- No REA value was found for these transitions in the time available: AppKit reads `NSFullScreenTransitionDuration`
  (default not decoded); Dock has `WASpaceFrameAnimation` (timing not decoded).

## Remaining

- Full screen enter frame 1: the menu bar, Dock and title bar vanish at once (0.10 of the change in one frame, Mac
  0.01); exit frame 1 shows them at once (0.12). Hyprland hides the top layers for a fullscreen workspace
  (`CLayerSurface::isHiddenByFullscreen`, binary) and the shell hides the Dock on `hasFullscreen`
  (`shell/modules/Dock.qml` `shown`). Decoded targets for the shell (hand-off): Dock out/in on the Space slide's
  0.5 s cosine `0.5 - 0.5 cos(pi t / 0.5)`; menu bar out on enter over 0.15 s (default, inferred), back on exit over
  0.5 s starting with the transition. Both need the layers to stay drawn while they fade: a shell-side fade before
  the fullscreen state lands, or a plugin hook on `isHiddenByFullscreen` for the length of the run (not done).
- ~~The full-screen window covers the menu-bar strip~~ (judge #3 gap 12): on the notched Air a full-screen window is
  0,34,1710,1073 under a black 34 pt strip (Q-menubar-33). The MBA headless output models that Air, so plugin-motion
  (`fullscreen_top = "MBA:34"`, FrameMotion.cpp) hooks the window's setBox: a box that is exactly a listed monitor's, for a
  window in full screen (internal mode), loses the strip at its top, on every relayout; and at RENDER_PRE_WINDOWS of a
  full-screen workspace it adds a black rect over the strip (the wallpaper still draws there; the bar is a top layer that
  Hyprland hides over full screen). On screen: foot full screen at 0,34 1280x798 (Mac 0,34 on its 1107 pt screen), strip 0/0/0
  over grey (before: the window at 0,0 1280x832), exit back to its frame, zoom (maximized) unchanged (1,67 1278x675). Other
  outputs keep true full screen; on MBA too with `fullscreen_top = ""`. Enter on the inset box (foot over black, window-rect
  area): 0.020 / 6.4 ms, 2-98 % 317 ms (one clean run). Not done: the titles' hover reveal on the strip (shell hand-off).

## Appearance switch cross-fade (user report 2026-11-11: Dark <-> Light snapped)

No Mac measurement exists (MAC-ANSWERS has none, the Mac is offline). From the 27.2.1 binaries (AppKit in the dyld cache,
`ipsw dyld disass --vaddr`):

| what | where | value |
|---|---|---|
| start of a global transition | `+[NSGlobalPreferenceTransition transition]` 0x18aeb1ce0 | `SLSCopyBeginGlobalPreferenceTransitionCompletionBlock` |
| the snapshot | `-[NSGlobalPreferenceTransitionOverlay initOnScreen:]` 0x18aeb17c4 | one window per screen (level, collection behaviour, not movable, does not hide on deactivate), layer contents = `SLDisplayCreateImage` |
| apps repaint under it | `-[NSGlobalPreferenceTransition postChangeNotification:completionHandler:]` 0x18aeb1d4c | `SLSPostCoordinatedDistributedNotification(cid, name, block, 0.5)` |
| the fade | `-[NSGlobalPreferenceTransitionOverlay endPresentation]` 0x18aeb1b20 | `CATransaction begin; setCompletionBlock:; setAnimationDuration: d; setDisableActions: NO; [layer setOpacity: 0]; commit` |
| d | same, 0x18aeb1c18 | `_NSGetCGFloatAppConfig(@"NSGlobalPreferenceTransitionDuration", 0.5)` |
| in-process variant (System Settings) | `+[NSLocalGlobalPreferenceTransition localTransition]` 0x18aeb20ac | a space above everything (`SLSSpaceCreate`, `SLSSpaceSetAbsoluteLevel`, `SLSShowSpaces`) holding one overlay per screen |

Decoded: one display-wide snapshot fade, 0.5 s. Inferred, not decoded: the curve (no timing function is set, so the
implicit animation takes CoreAnimation's default (0.25, 0.1, 0.25, 1); QuartzCore was not read for it) and how long the
snapshot stays before the fade (until the coordinated notification is answered, 0.5 s at most; who calls `endPresentation`
was not traced into SkyLight). Mac capture that would settle both: a 60 fps recording of a Dark -> Light switch over a
grey 127 desktop with one TextEdit window, from the click to 1 s after it.

Ours (plugin `src/AppearanceFade.cpp`, README "Appearance switch"): snapshot = the output's last presented swapchain buffer,
hold 0.15 s (ours), fade 0.5 s on (0.25, 0.1, 0.25, 1). mcap, MBA headless, grey 127, Finder + Settings + Calculator open,
strip across the windows and the Dock, trigger = option on the socket, then the state file:

| run | new look vs the decoded curve, rms | 2-98 % | fade starts | intervals max |
|---|---|---|---|---|
| scale 2, dark -> light / light -> dark, Finder and Settings, 6 runs | 0.001-0.002 | 384-405 ms | +162..178 ms | 19.5-21.1 ms |
| scale 2, Dock strip, both directions | 0.004 | 401-405 ms | +176..178 ms | 20.0-20.7 ms |
| scale 1.6, both directions | 0.001-0.002 | 384-402 ms | +164..180 ms | 19.6-20.6 ms |
| `reduce_motion = 1` | no fade, done 94 ms after the command | | | |

Every track is monotonic and starts at 0 (no client visible before the snapshot). GPU while it runs (stats, same session,
600 frames with four fades): whole frame avg 10.3 ms / p95 16.2 ms, glass 0.19 ms per frame; the fade itself is one
full-output copy at the start and one textured quad per frame. Before: every surface snapped at its own time (fade off,
4 switches by the state file: Settings and Finder first change 10-44 ms after the write, done by 27-73 ms; the glass
146-1063 ms after it, when the shell's `hyprctl eval` arrived).

Not covered, hand-offs:
- settings/ and shell/: send the option on the socket before the own theme flips (README line). Today Settings flips itself,
  writes the file 16 ms later, and the shell answers the file 146 / 246 / 1063 ms after a replaced file (3 runs) with a
  spawned `hyprctl eval`; with that order the Settings window and Finder change before the snapshot is taken.
- shell/: the shell's own theme (bar and menu text) follows the file that late, so it can change after the 0.15 s hold.
- GTK apps: Calculator changed 3.1 s after the switch in one run and not within 3.5 s in another (it follows the keyfile
  the shell writes): after the fade, a snap.
- Not tried on screen: a lock during a fade (sessions are never locked in tests; by code the fade ends when a lock starts),
  two outputs, a rotated output (skipped by code).

## Genie follow-up (2026-11-11, plugin d104e6d, plugin-motion unchanged)

Method: mcap of the whole output below the bar (-k 4), minimise = move to `special:minimized`, restore = move back; share of
samples that differ from the first frame (restore) or no longer differ from the last (minimise), against the Mac's TextEdit
1300 x 900 series (#42), time shift fitted. Two readings of every capture: the whole region (as the Mac's, window + shadow +
neck) and the window's rect alone. 5 runs each, grey 127, the window alone on its workspace. 2-98 % of the Mac series by
the same function: 367 ms (the "383" quoted before counts one frame more).

| MBA, 5 runs each | whole region: rms / 2-98 % ms, minimise | restore | window rect: rms / 2-98 %, minimise | restore |
|---|---|---|---|---|
| foot, dark, 2x | .018-.019 / 400 | .020 / 400-401 | .015 / 350 | .017-.018 / 350-366 |
| GNOME Calculator, dark, 2x | .025-.026 / 416-417 | .027 / 417 | .032 / 383 | .035-.036 / 383-384 |
| Finder, dark, 2x | .027 / 400 | .028-.029 / 400 | .020 / 367 | .022 / 383-384 |
| Settings, dark, 2x | .026 / 416-417 | .028 / 416-417 | .026 / 383-400 | .029 / 383-384 |
| foot, light, 2x | .019-.020 / 400-405 | .020-.022 / 397-400 | .013 / 367-371 | .014-.015 / 364-367 |
| Calculator, light, 2x | .025-.026 / 417-419 | .027-.031 / 400-434 | .027-.029 / 384-388 | .029-.033 / 382-403 |
| Finder, light, 2x | .027-.029 / 400-403 | .030-.031 / 400-421 | .017-.019 / 383-385 | .020 / 382-398 |
| Settings, light, 2x | .023-.029 / 402-420 | .029 / 417-419 | .019-.025 / 381-400 | .025-.026 / 383-386 |
| all four, light and dark, scale 1.6 (whole region) | .016-.022 / 396-436 | .018-.024 / 391-421 | | |

- Dark is no longer worse than light (restore .020-.029 dark, .020-.031 light; the .041-.043 of before fddd07a's follow-up
  was not reproduced in 20 dark restores).
- The whole-region 2-98 % is 30-50 ms longer than the Mac's 367 ms; read on the window's rect it is the Mac's (350-384 ms on
  foot, Finder, Settings; Calculator 383-403). The difference is the shadow halo: it is warped with the window (fddd07a), and
  its side lobes outside the rect reach their final values only in the last frames, when the mesh is the identity.
- The window-rect reading at scale 1.6 came out at 286-359 ms and rms .042-.066 for every app; not explained (the same
  captures read .016-.024 / 391-436 on the whole region), so it is not in the table.
- By eye (frames 4 / 10 / 16 / 22 / 26 / 28 of a restore per app, dark, 2x): no outline beside the window, no line to the
  Dock. End pop: the largest single step of the window-rect share after 0.9 is .023-.045 at 2x (Mac series: .033), up to
  .071 once at 1.6 (Finder, dark). Frames longer than 25 ms: 0 at 2x dark, 0-6 per run in light and at 1.6.

Shadow during the genie on the Mac. No recording is in the repo (the #42 videos stayed on the Mac). From the binaries:
- Dock 27.2.1 warps the real window: `CGSSetWindowWarp` in the genie step (0x100026bf0, the function with cos / log / acos at
  0x100026228) and again when it ends (0x100026f9c, with `CGSOrderWindow`, `CGSReleaseWindow` and `CGSClearWindowTags` of tag
  bit 34). The Dock's only shadow call (`CGSWindowSetShadowProperties`, 0x1002213d4) is a Swift helper for its own windows;
  the genie path sets no shadow property and not the no-shadow tag (bit 3).
- SkyLight 27.2.1: `CGXWindow::set_mesh_warp` 0x1829f7550 stores the mesh; `WS::Updater::defenestrator::
  ca_window_prep_ingestion_phase` (call at 0x182797894) takes `CGXWindow::frame_mesh()` and, independently of it, the shadow
  (`CGXWindowIsShadowed` = shadow enabled and tag bit 3 clear, `wants_efficient_ca_shadow` / `wants_inefficient_ca_shadow`,
  `WSWindowShadowCurrentPropertiesPtr`), then `WSCAMeshFromWSMesh` (a `CAMutableMeshTransform`). No branch drops the shadow
  for a warped window.
- The #42 small-window series agrees: minimise starts 1.0 .992 .975 although the shadow is 30 % of the changed area there
  (area0 21426 cells against 15000 for the window), so the shadow does not vanish in the first frame.
- Not decoded: whether CoreAnimation bends the layer's shadow with the mesh or draws it from the warped content. Ours bends
  it with the window (fddd07a), unchanged.

## Follow-ups (2026-11-11, session 10)

**Genie window-rect reading at 1.6 (286-359 ms): the reading, not the motion.** `mcap.py sub()` mapped a logical rectangle
to samples with 2 / step, i.e. it assumed a 2x output; at 1.6 the rectangle landed 1.25x further out and larger, mostly off
the window. foot over grey, 3 minimises and 3 restores at 1.6: whole region 383-402 ms; window rect by the old mapping
282-286 ms; by the real one (samples / region width) 348-352 ms (2x foot 350-366, Mac 367). Fixed in `mcap.py`.

**Appearance cross-fade leftovers** (own headless session, `HYPRK_LOCK_TEST=1`):
- Lock during a fade: the fade ends in the frame the lock lands (19 frames / 0.317 s instead of 39 / 0.65), `liquidglass
  fade` shows 0 running at the first poll with `hyprctl locked` true, and the lock screen right after against 1.5 s later
  differs by rms 0.53 levels, no pixel over 12: no trace of the snapshot. The shell's lock call takes about 340 ms to lock
  (its own fade in), so a lock asked for at the switch lands mid-fade.
- Two outputs (MBA 2x + a headless 1920x1080 at 1): one fade per output (2 running), both blend (screenshots in a row: X2
  .21 .25 .29 .32 .., MBA .19 .68 .83 .93 .98). No per-frame series for the second output: mcap got no damage frames from it.
- Rotated output (transform 1): skipped as coded (1 running, the rotated output snaps), nothing drawn wrong on it.
- The 0.15 s hold is still needed. A real click on the Dark / Light thumbnail in Settings (vptr), mcap of the full output:

| | Settings pane | menu bar | Dock |
|---|---|---|---|
| hold 0.15, scale 2 (2 runs) and 1.6 (4 runs): rms vs the curve | 0.0005-0.0015 | 0.0008-0.0014 in 3 runs; late in 2 (234 and 491 ms, below); 0.013 in one | 0.0023-0.0035 in 4 runs; 0.10 in the two disturbed 1.6 runs |
| hold 0, scale 2 (6 runs) | 0.0007-0.0009 | old look for 100-117 ms after the first fade frame, then a step of .33-.37 | .13 -> .50 / .61 -> .77 / .94 -> .63, not monotonic |
| hold 0, scale 1.6 (4 runs, host load 13-18) | 0.002-0.006 | changes 337-526 ms after the click, step .83-1.0 | not monotonic |

  Settings repaints in the first frame; the shell (menu bar, Dock content) follows 100-120 ms after the option on a quiet
  host, so 0.15 s covers it with one frame to spare and 0 does not. Fade start 154-172 ms after the click, 2-98 % 384-405 ms.
- Not covered by any hold: with the host loaded (load average 13-18, other headless sessions) the shell restyled 234-505 ms
  after the click in 7 of 16 runs (2 of 6 with the hold, all 4 at 1.6 without it; and 458-969 ms when the switch came through `hyprctl` with two outputs), a step of up to
  1.0 in the menu bar inside or after the fade. Apple waits for the apps' answers for up to 0.5 s; here nothing answers.
  If it shows on a real session: the shell could send a second option when it has restyled and the plugin hold until then
  (at most 0.5 s). Not built: on a quiet host the fixed hold is enough.
