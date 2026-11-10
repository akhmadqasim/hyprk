# Control gallery (R1), macOS 27.2.1

The probe is `reference/re/tools/probe/controls.swift`. It was extended: every control size and state, focus rings,
an inactive capture, and a 120 Hz press sampler. Build: `swiftc -swift-version 5 -O -o controls controls.swift`.
Run: `./controls <outdir> light|dark <seconds> [focus,inactive,sample]`.

The window is 900x560 content (2x PNG, no shadow).

| file | content |
|---|---|
| controls-{light,dark}.png | All controls, key window. Left to right, top to bottom: checkboxes and radios (regular/small/mini/large, on/off/mixed/disabled), glass push button; segmented (regular/small), switches (regular on/off, mini), sliders (plain, 5 ticks, disabled, small, mini, 9 ticks), popup, text fields, search field, stepper; push buttons (regular, default, disabled, large, small), help, toolbar icon button, progress, spinner, colour well, date picker, level indicator, rounded/square/disabled/small text fields; segmented mini/large/disabled, mini push, small/disabled switches, popup small/mini/disabled, pull-down, small/mini steppers, labels (13, secondary 11, disabled, tertiary), combo box |
| controls-{light,dark}-inactive.png | The same with another window key (accent removed) |
| focus-rings-{light,dark}.png | Each focusable control as first responder (3 pt ring) |
| switch-press-strip-light.png | 60 fps frames 1/30 s apart: a long press grows the knob to a glass lens (0.23 s) |
| switch-release-strip-light.png | The release: shrink + travel to off + track colour fade |

Data is in `reference/re/27.2.1/live/controls/`:
- `controls-{light,dark}.json`: per control, the frames (window and screen), intrinsic size, font, view tree and full
  layer tree (colours, radii, shadows, filters).
- `focus-*.json`: the focus ring mask bounds.
- `controls-press-light.json`: 120 Hz presentation-layer series for switch, slider, segmented, push and checkbox
  presses, plus the pressed-knob glass filter.
