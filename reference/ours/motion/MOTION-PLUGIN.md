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

## Not derived from Apple data

- Full screen exit: only the R2 description exists (0.15 s to 0.47, 0.15 s hold, 0.3 s); the curve inside each
  step is not in the data. Both steps use ease-in-out (0.42, 0, 0.58, 1). What moves in each step on the Mac
  (window, Space, desktop) is not recorded either; here the window does both steps.
- The Space slide (desktop out to the left, black Space in from the right): a black Space sliding in behind the
  window over a still desktop was built and measured; it made the match worse (enter 0.056 / 41 ms, exit 0.16 vs
  0.033 / 17 ms and 0.048 without), because the Mac's desktop moves away instead of being covered. It was removed.
  Doing it properly needs the desktop (wallpaper layer and windows) to slide, which is outside the plugins.
- No REA value was found for these transitions in the time available: AppKit reads `NSFullScreenTransitionDuration`
  (default not decoded); Dock has `WASpaceFrameAnimation` (timing not decoded).

## Remaining

- Full screen enter frame 1: the menu bar, Dock and title bar vanish at once (0.10 of the change in one frame, Mac
  0.01); exit frame 1 shows them at once (0.12). Hyprland hides the top layers for a fullscreen workspace.
- The full-screen window covers the menu-bar strip; on the notched Mac it sits below a black 34 pt strip (Q-menubar-33).
