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

## Round 3 (R3.5, R3.6)
| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| popup-menu-open-close-dark.mov | `screencapture -x -C -v -V 4.5 -R 800,550,400,382` (pointer shown, 2x, H.264 60 fps time base, VFR), display 1440x932, Settings window at 350,150 | System Settings > Appearance > "Text highlight colour" pop-up (Automatic): pointer glides in, click at 994,670 pt opens the menu (Automatic ✓ over the button, Blue … Green, scroll chevron), 1.2 s later click on "Automatic" (same item, no setting change), menu closes, pointer leaves | dark | TahoeDark |
| popup-menu-open-close-light.mov | same, 6 s clip, 1.5 s with the menu open | same | light | TahoeLight |
| switch-press-strip-dark.png | frames from `switch-held-stripes-dark.mov` (round 2, not a new probe run), crop px 150,60 115x80 of each frame, 10 cells labelled frame # and pts | press and hold: rest (0 s), then every 2nd frame (1/30 s) from 0.900 s to 1.150 s while the knob grows into the lens; 1.150 s is the last change before the release at 2.000 s | dark | stripes / window |

## Round 6 (R6.3): segmented control, press and drag
Settings > Appearance's Light / Dark / Auto are thumbnail buttons, not a segmented control (and a drag there would
switch the system appearance), so the Finder toolbar view switcher (AXRadioGroup of 4 AXSegment radio buttons,
714,207 162x38 pt; segments 40.5 pt) was used, in a Finder window on a dummy folder (150,200 1240x400 pt so the
switcher is not collapsed into a pop-up). Clip `screencapture -x -C -v -V 4.5 -R 690,195,220,62` (pointer shown).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| segmented-drag-light.mov | mouse down on "icon view" (735,227) at about 0.8 s, held 0.5 s, dragged to "list view" (776,227) over 1.5 s, held 0.5 s, released | pressed segment, drag, selection change to list view | light | window / TahoeLight |
| segmented-drag-dark.mov | same | same | dark | window / TahoeDark |

## Round 7 (R7.1): hold shine on glass toolbar buttons
Display 1440x932 pt (2x), wallpaper TahoeLight / TahoeDark, other apps hidden. Clips `screencapture -x -C -v -V 4.5 -R …`
(pointer shown, H.264 60 fps time base, VFR). Synthetic CGEvents: pointer onto the button, mouse down, then while held
the pointer traces a 14x10 pt rectangle inside the button (0.3 + 0.4 + 0.3 + 0.4 + 0.3 s ≈ 1.7 s + 0.2 s still ≈ 2 s),
then mouse up on the button centre.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| hold-shine-finder-{light,dark}.mov | region 520,195 240x64 pt; Finder window 400,200 740x360 on a dummy folder `hyprk-r7/sub` (Back enabled), Back segment centre 586,227 | Back pressed and held: after about 0.5 s the Back history menu opens under it ("hyprk-r7"); release over the button | both | window / Tahoe |
| hold-shine-held-{light,dark}.png | `screencapture -x -R` same region, 0.9 s into the hold | held Back segment (pressed pill), history menu starting to appear | both | same |
| hold-shine-settings-{light,dark}.mov | region 560,150 240x60 pt; System Settings 350,150, Appearance then Desktop & Dock (so Back is enabled), Go Back 608,176 | same gesture; the history menu opens under the button too | both | same |

## Round 7 (R7.2): slider knob elasticity, fast drags
Clips `screencapture -x -C -v -V 5 -R …` (pointer shown, 60 fps time base, VFR). Synthetic gesture: pointer onto the
knob, mouse down, 0.25 s, then 3 fast swings (each 0.18 s between the two turn points, linear CGEvent drags at 120 Hz),
0.3 s pause, a fling to past the max end in about 0.1 s, mouse up there.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| slider-fast-drag-settings-{light,dark}.mov | region 580,225 260x80 pt; Settings > Desktop & Dock > Size (slider 612,250 200x34, track y 275), knob 645,275; swings between x 640 and 780; fling to x 600 (the min end) | knob turns into the glass lens and lags the pointer on each swing; fling to Small | both | window |
| slider-fast-drag-cc-{light,dark}.mov | region 1130,(slider y − 33) 260x70 pt; Control Centre > Sound (slider 1168,456 or 1168,484 180x14 in light / dark), knob at 81 %; swings between x 1200 and 1320; fling to x 1380 (past max) | same, Control Centre slider; fling to 100 % and past | both | Control Centre / Tahoe |
Dock size and volume were changed by these gestures and restored (Dock plist re-imported, tilesize 31; volume 81).

## Round 7 (R7.3): glass button pressed, pointer dragged fast out and back
| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| button-press-drag-fast-{light,dark}.mov | `screencapture -x -C -v -V 5 -R 645,197,220,120` (pointer shown); Finder window 150,200 1240x400 on a dummy folder, toolbar view switcher, selected "icon view" segment 735,227; mouse down, 0.4 s, then twice: drag to +20,+70 pt in 0.1 s, 0.35 s outside, back in 0.1 s, 0.45 s inside; release on the segment (no view change) | pressed look inside, normal look while outside, pressed again on return | both | window |

## Round 7 (R7.4): slider icons at the ends
Clips `screencapture -x -C -v -V 6.5 -R …` (pointer shown, 60 fps time base, VFR). Gesture: grab the knob, 0.3 s, drag
to 45 pt past the max end in 0.5 s, hold 0.8 s, drag to 45 pt past the min end in 0.8 s, hold 0.8 s, release there.
Slider positions from AX. Volume restored to 81 (unmuted) and brightness to 0.606 (DisplayServices) after each clip.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| slider-icon-ends-cc-sound-{light,dark}.mov | Control Centre > Sound (180 pt slider), region slider −50 / +60 pt | speaker glyphs at both ends while the lens is pulled past them | both | Control Centre |
| slider-icon-ends-cc-display-{light,dark}.mov | Control Centre > Display brightness (217 pt slider, 1170,415) | sun glyphs at both ends | both | Control Centre |
| slider-icon-ends-settings-sound-{light,dark}.mov | Settings > Sound > Output volume (830,617 205 pt, 9 ticks), region slider −60 / +60 pt | speaker glyphs at both ends; the Mute box ticks at 0 | both | window |
