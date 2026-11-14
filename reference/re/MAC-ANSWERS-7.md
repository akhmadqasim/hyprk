# Answers from the Mac session, round 7 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#134). Same conditions as rounds 2 to 6: 1440x932 pt @2x (unscaled), Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel, pointer shown in clips (`-C`), clips VFR on a 60 fps time base.

## R7.1 Hold shine: done (Finder Back, Settings Back); no Dock glass capsule
- `screens/27.2.1/controls/hold-shine-{finder,settings}-{light,dark}.mov`, `hold-shine-held-{light,dark}.png` (Finder)
- Both Back buttons are **menu buttons**: holding them opens the navigation history menu after about 0.5 s, so a 2 s hold
  always ends with that menu open (release over the button closes it without navigating). The pressed look before the
  menu: the Back segment's pill darkens (light) / brightens (dark); in dark a lighter highlight is visible around the
  pointer while it moves inside the held button.
- Dock-style glass capsule: the Dock has no pressable glass capsule (items are icons; the Dock background is not a
  button), so none was recorded.

## R7.1b Liquid Glass preview capsules, hold and tap: done
- `screens/27.2.1/settings/appearance/preview-hold-shine-{share,search}-{light,dark}.mov`, `preview-hold-shine-held-{light,dark}.png`
- Crop rect 780,300 292x200 pt (screen). Targets: share glyph 818,336, search capsule 987,336 (found from pixels; the
  preview's capsules have no AX elements).
- Seen: on press the pressed part of the capsule lights up: a soft white glow (light) / a lit, brighter disc (dark)
  centred under the pointer, inside the capsule shape, and it follows the pointer while held. The capsule keeps its
  size (no visible stretch with this small movement). Release fades the glow. The quick tap shows a short flash of the
  same glow.
- Side effect: the preview is a scroll view, so the held drag also scrolled the article a few points (visible in the
  clips: the photo shifts, and the search glyph hides when the search capsule's placeholder state changes).

## R7.2 Slider knob elasticity: done (Settings Dock Size, Control Centre Sound)
- `screens/27.2.1/controls/slider-fast-drag-{settings,cc}-{light,dark}.mov`
- Seen: on grab the knob becomes the glass lens; during fast swings the lens **lags behind the pointer** (the pointer
  leads by up to about 30–40 pt at the turn points, then the lens catches up), i.e. a spring follow, not a rigid
  attachment; the fill follows the lens, not the pointer. On the fling to the end the lens arrives after the pointer and
  settles; on release it shrinks back to the small knob. Settings and Control Centre behave alike.
- The Control Centre slider sits about 28 pt lower in dark than in light here (layout shift from the modules above);
  positions were read from AX each time. Dock size and volume restored after.

## R7.3 Button pressed and dragged fast out and back: done
- `screens/27.2.1/controls/button-press-drag-fast-{light,dark}.mov` (Finder toolbar view switcher segment; the Back
  buttons were not used because holding them opens the history menu)
- Seen: **no stretch toward the pointer and no bounce.** While the pointer is inside, the segment shows the pressed pill
  (darker in light, lighter in dark); the moment it leaves, the pill returns to the normal selected look (classic
  track-inside highlight); on return it is pressed again. Release inside keeps the selection (no change).
