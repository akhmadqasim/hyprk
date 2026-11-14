# Answers from the Mac session, round 2 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Answers to `MAC-REQUESTS-2.md`. One section per item. Conditions for every capture unless the item says otherwise:
- Built-in display switched to its default mode 1440x932 pt (2880x1864 px, 2x). Round 1 was at the scaled 1710x1107.
  The panel runs at 60 Hz only, so no clip is above 60 fps (item 6 is 60 fps).
- Reduce Transparency, Increase Contrast, Reduce Motion: all off (`com.apple.universalaccess` 0).
- Stage Manager turned off for the captures (it shrinks the front window on screen); restored afterwards.
- Accent Multicolour, icon style Dark, `NSGlassTintAmount = 0.5087818`.
- Backdrops: grey = solid RGB 127,127,127 2880x1864 desktop picture; stripes = 2880x1864 PNG of 8 px (4 pt)
  black / white vertical stripes as the desktop picture (screen height is 1864 px, not 1800).
- Clips from `screencapture -v -R` are H.264 with a 60 fps time base and variable frame rate (a frame only when the
  screen changes); count time from the pts, not the frame index.

## G1.1 Liquid Glass preview over flat grey: done
- `screens/27.2.1/settings/appearance/liquidglass-flat-grey-{light,dark}.png` (window, 1480x1250)
- `screens/27.2.1/settings/appearance/liquidglass-flat-grey-capsules-{light,dark}.png` (crop x 884..1420, y 322..422 px)
- The preview capsules sit on the preview's own photo (Apple Park), not on the desktop, so the grey backdrop only
  changes the sidebar / window glass, not the capsules' backdrop.
- Luminance along y 50 of the capsule crop, x 0..59 (left round end of the share / more capsule starts at x 15):
  - light: photo 194..203, rim pixel x15 = **134**, then fill 235..231, glyph from x 39
  - dark: photo 194..203, rim pixel x15 = **103**, then 126, 143, 149, fill 150 rising to 158 by x 38

## G1.2 Switch held over stripes: done
- `screens/27.2.1/controls/switch-held-stripes-{light,dark}.png`, `switch-held-stripes-{light,dark}.mov`
- System Settings > Desktop & Dock > "Show suggested and recent apps in Dock" (on), held 1 s by a synthetic mouse
  down / up; it was switched back on after each clip. The knob lens sits over the window's own content (track), the
  stripes show only right of the window, so the fringe is the knob over the blue / grey track.

## G1.3 Slider knob held, light: done
- `screens/27.2.1/controls/slider-held-settings-light.png` (Dock Size slider, held without moving), plus
  `slider-held-settings-dark.png`
- `screens/27.2.1/controls/slider-held-cc-light.png` (Control Centre Sound, module glass over stripes) and
  `slider-released-cc-light.png` (just after release). Volume was put back to its value after the press.
