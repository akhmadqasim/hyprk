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
| Window close (judge #3 gap 11) | R2 TextEdit alpha 1, .71, .44, .27, .16, .09, .05, .03 | first frame 0.11-0.13 (bezier started at the close, phase-dependent), then .44 .65 .79 .88 .93 .97 1 | .28 .56 .73 .84 .91 .95 .97 .98 in 5 of 5 runs | 0.012-0.028 / 1.4-3.2 ms -> 0.006-0.010 / 0.3-0.8 ms (one run 0.020, fit shift) | this change |
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
