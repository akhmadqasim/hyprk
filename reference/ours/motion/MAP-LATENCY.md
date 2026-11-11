# Layer map latency: where the first frames go (2026-11-11)

Follow-up of MOTION-MEASURED.md "Repeated frame after a layer maps". Question: does Hyprland 0.57.2 lose vblanks
when a shell layer maps (its first `wl_surface.frame` is answered at map time), and would sending it after the first
composite fix the late first frame and the repeated second frame?

Answer: no. The compositor shows every buffer of a new layer at the first composite after its commit. The late
first visible frame and the repeat are in the buffers the shell draws. Deferring the frame callback was built
and measured: no change. The patch is kept unapplied (hypr-dev `patches/not-applied/`, README "Layer first frame").

## Method

Scratch build of Hyprland 0.57.2 with trace points (not shipped): commit (buffer, callbacks), `map()`,
frame-done, every frame event and composite, `renderLayer` (mapped, alpha, texture), ext-background-effect
region commits, screencopy copy. Headless session (`HYPRK_HEADLESS=1`, MBA 60 Hz), mcap on the same CLOCK_MONOTONIC.
Trigger `hyprctl dispatch 'hl.dsp.global("hyprk:controlcenter")'` (t = 0).

## Control Center open, unpatched (trace run 1)

Panel = `hyprk-controlcenter` on Top (456 x 646), catcher on Overlay.

| ms | compositor | mcap |
|---|---|---|
| 21.6 | layer surfaces created (initial commits, no buffer) | |
| 28.3 | panel buffer 1 committed, `map()`, frame-done for it at once (Compositor.cpp `CWLSurfaceResource::map`) | |
| 40.2 | composite: panel drawn with buffer 1 (mapped, alpha 1.000, texture) | 40.8: no CC pixel |
| 43.7 / 43.9 | catcher maps; panel buffer 2 committed | |
| 57.0 | composite: panel buffer 2 drawn, frame-done | 58.1: no CC pixel |
| 63.9 | panel buffer 3 | |
| 73.6 | composite: buffer 3 | 75.2: first pixels, alpha 0.055 |
| 78.7 | buffer 4 | |
| 90.2 | composite: buffer 4 | 91.3: 0.050 (the "repeat") |
| 95.3 | buffer 5 | |
| 106.9 | composite: buffer 5 | 108.0: 0.177 |

Every buffer was composited at the next frame after its commit, once, with the layer fully opaque. So:

- "Lost" vblank 1 (40 ms): buffer 1 is on screen; it is transparent (the spring's start state, fade 0, glass opacity 0).
- "Lost" vblank 2 (57 ms): buffer 2 is on screen; in this run it is still transparent. In other runs buffer 2
  already shows 0.05 (trace run 2: first pixels at the second composite).
- Repeat: two consecutive buffers carry about the same state (0.052 then 0.048, always this pair, in all runs).
  The values per buffer are the same in every run (0.05, 0.05, 0.167, 0.298, 0.437, 0.560 ...), so Qt advances the
  animation in fixed steps per rendered frame and two of its frames have the same state. Shell / Qt side.

Code read for the layer path: `CLayerShellResource` commit listener (protocols/LayerShell.cpp ~67) calls `map()`
then `CLayerSurface::onMap` (desktop/view/LayerSurface.cpp ~180) damages the box and starts the fade from 0
(`LayerSurfaceAnimationController::apply`); with `no_anim` the animation manager warps it to 1 on the next tick
(animation/AnimationManager.cpp `handleUpdate`), and `renderMonitor` ticks before drawing
(render/Renderer.cpp ~2290), so the first composite already draws it at alpha 1 (trace: alpha=1.000 every time).
The liquidglass plugin's `renderLayer` hook never holds a layer back (plugin/src/main.cpp, it always calls the
original).

## Test backend vs DRM

The headless output (aquamarine Headless.cpp `scheduleFrame`) composites on a 60 Hz timer and reports presentation
at commit time. On DRM the composite runs on the page-flip event and is scanned out at the next vblank: the same
order (commit, then the next composite takes it), plus one constant frame of scan-out latency for every frame. No
part of the late first frame or the repeat is a test-backend artefact; by code reading nothing more is lost on DRM.

## Patch tried: first frame callback after the first composite

hypr-dev `patches/not-applied/hyprland-0.57.2-layer-first-frame.patch`: for layer surfaces only, the mapping
commit's callbacks are kept out of `map()` and sent when the monitor composites (while drawing the surface, or at
RENDER_POST if it is not drawn); old behaviour when the monitor is off. Checked: frame-done now at the first
composite (28.8 ms instead of at map); windows unchanged (foot: map and per-frame callbacks as before); a menu layer
mapped under the lock (HYPRK_LOCK_TEST session) got its callback at the next composite; the lock surface kept its
per-frame callbacks; screencopy (mcap) worked.

Measured (alpha over the CC panel 814,30,460,660; first visible = first frame > 0.01 after the trigger):

| Motion | Before (installed) | After (patched) |
|---|---|---|
| CC open, 5 runs each | first visible 48-93 ms; frames 0.05, 0.05, 0.17, 0.30 ...; 1 repeat in 5 of 5; 2-98 % 233-250 ms | 64-111 ms; same pairs (0.052/0.042-0.048, once 0.172/0.167); 1 repeat in 5 of 5; 216-250 ms |
| Spotlight open, 4 each (370,180,540,110) | 33-83 ms, 0 repeats, 102-119 ms | 48-65 ms, 0 repeats, 100-117 ms |
| Dock hover label (Finder, 380,705,82,40), 12 each | one frame, 15-67 ms (mostly 31) | one frame, 15-35 ms (mostly 31) |
| NC push | not measured | not measured |

The spread is the trigger landing on the 16.7 ms frame grid and the shell's own reaction time, the same with and
without the patch. No gain, so the patch stays unapplied (rule: stay light).

## Hand-off (shell side)

- The first buffer of a new panel is drawn at the spring's start (fade 0, glass opacity 0): invisible. Starting the
  visible state one spring step in (first buffer = first moving frame) removes one dead frame.
- The repeated pair: two Qt frames with the same animation state. A guess, not checked: the second window of the
  Control Center (the catcher) mapping causes an extra render without an animation advance.
