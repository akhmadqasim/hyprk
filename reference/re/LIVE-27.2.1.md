# Ground truth measured on a real Mac (macOS 27.2.1, 26B131, MacBook Air M2, 2x display)

Method: `tools/probe/main.swift` (AppKit app) shows real glass, a menu, a popover, alerts and windows, then dumps the
layer trees. Every glass surface is a `CABackdropLayer` with one `glassBackground` CAFilter whose inputs are the
resolved recipe. Animations run in WindowServer, so those were measured from a 60 fps screen recording
(`tools/vidmotion.py`). Raw data: `27.2.1/live/`.

Build and run (Mac only): `swiftc -swift-version 5 -O -o probe tools/probe/main.swift`, then
`./probe <outdir> light|dark ui|variants|motion|motion2`. It takes focus while it runs.

## Data files (27.2.1/live)
- `glass-params-{light,dark}.json`: per variant, per D in 24..400 pt (D = shortest side), all filter inputs, with the
  window active and key. `*-inactive.json`: same sweep with the app not frontmost.
- `glass-table-*.txt`: same, as a diff against `regular` (`tools/glasstable.py`).
- `{glass,menu,popover,alert}-{light,dark}.json`: full window dumps (views with frames, fonts; layers with filters).
- `metrics-*.json`: system fonts, colours, bar heights. `*-motion-*.json`: in-process 120 Hz samples.
- `video-motion-{1,2}.json`: per-frame bounding box and progress for each recorded transition.

## How variants are selected
`NSGlassEffectView` has private KVC keys: `_variant` (Int), `_subvariant` (String), `_adaptiveAppearance`,
`_interactionState`, `_scrimState`, `_subduedState`. `_variant` = DesignLibrary `Variant` index + 1 (0 and 1 = regular):
3 dock, 4 appIcons, 5 widgets, 6 text, 9 controlCenter, 10 notificationCenter, 17 sidebar, 19 inspector, 20 control.
The public `style = .clear` gives clear. Subvariants that AppKit accepts: menu, window, documentModalWindow, sheet,
entryField, siriSnippet, cursorAccessory. spotlightField, searchResults, compose and the Siri ones fall back to a
default look through this route, so Spotlight's real values are still only known from the decompiled SiriRecipe (NOTES.md).

## Regular glass, active window (light | dark)
- Face YCC: black 0.4 | 0.125 (0.08 when inactive), white 1.03 | 1.125, saturation 1.2 | 1.3,
  fill white a 0.2 | none. Clamp 1.07 | 1.308.
- Blur radius 5 (constant). Blur opacities: o0 = clampedLinear(D, 64..160 -> 0.4..0.8), o1 = o0 / 2, o2 0.5, o3 1.
  Blur distances (-D/2, -1, 0, 0).
- Blur fill: radius 8, lighten 0.9 | 0, darken 0 | 0.9, normal 0.5.
- Inner refraction: height 0.25 D max 20, amount -0.5 D min -60. Outer: height max(0.2 D, 16), amount max(0.25 D, 16),
  opacity 0.6, distances (-1, 0).
- Edge bleed: amount = height = blur = 0.35 D; opacity clampedLinear(D, 64..160 -> 0..0.5 | 0.8); YCC 0.9, 1, 1.2 |
  0.125, 0.5, 1; darken blend.
- Drop shadow (was unknown): opacity clampedLinear(D, 64..160 -> 0.04..0.4 | 0.6), radius 4..24 over the same range,
  offset (0, 8), fill black a 0.3.
- Ring shadow: offset 8, stroke 4, blur 5, opacity 0.06.
- Key/fill highlight (dark specular): amount 0.4, angle 90 deg, spread 96 deg | 75 deg, spreadSDR 106 | 75 deg,
  height 0.5, effectOffset -0.5, colorBias -0.25.
- Backdrop layer scale 0.5 for D < 160, 0.25 from 160.
- Inactive window: white 0.96, no drop shadow, no outer refraction, highlight amount 0.5, spread 120 deg,
  colorBias -0.1875.

## Other materials (differences from regular; see glass-table-*.txt for all)
- Clear: face 0.125 / 1.08 / 1.06, no fill, blur 0.75, no blur fill, inner refraction 0.36 D / -0.65 D,
  outer 0.125 D / 0.2 D, no ring shadow, no drop shadow. Clamp 1.192.
- Dock: face 0.15 / 0.9 / 1.25, blur 1.5, inner 0.08 D / -0.18 D, refraction opacity 0.2, highlight spread 120 deg.
- Control Center: face 0.125 / 0.8 / 1.2, blur 4 with distance -100, inner height 0.225 D max 25, amount -80,
  outer 0.0357 D / 0.0714 D at 0.1525, highlight colorBias -0.3, spread 75 deg.
- Sidebar: fill (0.87, 0.88, 0.91, a 0.7), white 0.88, saturation 0.8, blur 2.5, inner 0.3 D max 20, no outer.

## Real windows
- Context menu = regular glass in its own `_NSGlassEffectWindow`, radius 12, drop shadow 0.7 | 0.8, radius 24, y 10.
  The glass window is 75 pt larger than the menu on every side (room for the shadow).
- Alert = regular, radius 26, shadow 0.6 | 0.7, radius 24, y 10. Popover = regular, radius 20, shadow by size, y 8.

## Menu metrics
- Row 24 pt, top and bottom padding 5, separator row 11. Width 182 for this menu.
- Text x 28 (12 pt checkmark column at x 12, mark 13 x 11), font system 13. Shortcut column right-aligned, 13 pt
  from the right edge, font 13, tertiary label colour. Submenu chevron 17 wide at x 150.
- Disabled text = tertiaryLabel. Label 0 0 0 a 0.847, secondary a 0.498, tertiary a 0.259, separator a 0.1.
- Selection highlight not captured (needs a real mouse hover).

## Alert metrics
- 260 x 154 for 2 lines of title; padding 20 sides, 16 bottom. Title SF bold 13, text SF regular 13, gap 10.
- Buttons 110 x 28 in a row, gap 8, 16 from the edges. Popover content inset 13.

## Motion (60 fps recording)
| Transition | Result |
|---|---|
| Menu open | instant, no animation |
| Menu close | fade out, about 0.2 s, ease-out (alpha 0.86, 0.71, 0.55, 0.42, 0.31, 0.22, 0.15, 0.10, 0.06, 0.04, 0.02, 0 per 1/60 s) |
| Popover show | scales up from the anchor from about 12 %, reaches full size at 0.20 s, overshoots about 1.5 %, settles by 0.42 s |
| Popover close | fade, about 0.15 to 0.2 s, no scale |
| Sheet on a window | in 0.27 s, out 0.25 s, near-linear progress, size constant |
| App-modal alert show | grows from the centre from about 4 %, overshoots at 0.22 s, settles at 0.37 s |
| Alert dismiss | fade, about 0.1 s |
| Plain or utility window open and close | instant (under 2 frames) |
| Document window open | 95 % there in the first frame, the rest within 0.1 s; close instant |
| alertPanel-behaviour window open | about 0.42 s pop |
| Minimise | window part about 0.27 s, whole effect about 0.65 s; restore about 0.58 s |

Not measured: Mission Control, Cmd-Tab, Spaces, Dock magnification, Control Center and Spotlight open/close (other
processes; would need synthetic key events and Accessibility permission), menu selection highlight, tooltips.
