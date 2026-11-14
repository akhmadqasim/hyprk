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

## Round 2 (G1.2, G1.3): held controls over stripes
Display at the default 1440x932 pt (2x). Desktop picture = 2880x1864 PNG of 8 px (4 pt) black / white vertical stripes;
all other apps hidden. Real System Settings (Desktop & Dock pane, window at 350,150 pt) and Control Centre. Presses are
synthetic CGEvents (mouse down, hold, up) with the pointer on the control. Stills: `screencapture -x -R` (region, 2x).
Clips: `screencapture -x -v -V 4 -R` (H.264, 60 fps time base, variable frame rate: frames only when the screen
changes), not re-encoded.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| switch-held-stripes-light.png | region 940,560 200x100 pt, 0.6 s into the hold | "Show suggested and recent apps in Dock" switch (on), knob held = glass lens; the switch above is idle for comparison; right 50 pt = desktop stripes | light | stripes |
| switch-held-stripes-dark.png | same | same | dark | stripes |
| switch-held-stripes-light.mov | same region, 3.4 s | idle 1 s, press, 1 s hold, release (the switch turns off; it was clicked back on after the clip) | light | stripes |
| switch-held-stripes-dark.mov | same | same | dark | stripes |
| slider-held-settings-light.png | region 590,230 130x80 pt, 0.8 s into the hold | Desktop & Dock > Dock Size slider, knob held (lens over the track, no drag) | light | stripes (window content under the knob) |
| slider-held-settings-dark.png | same | same (extra) | dark | stripes (window content under the knob) |
| slider-held-cc-light.png | region 1140,450 290x80 pt, 0.8 s into the hold | Control Centre Sound module, knob held | light | stripes |
| slider-released-cc-light.png | same region, 0.3 s after release | the same knob just after release (lens still shown) | light | stripes |
