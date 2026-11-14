# Answers from the Mac session, round 6 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#127). Same conditions as rounds 2 to 5: 1440x932 pt @2x (unscaled), Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel, `screencapture -v` clips are VFR on a 60 fps time base. No Focus changes.

## R6.1 Dark Settings window over flat red / green / navy: done
- `screens/27.2.1/settings/window-dark-flat-{red,green,navy}.png`
- Yes, the dark window takes a tint from the desktop. Pixels (window px, sRGB):

| desktop | sidebar (240,700) | content background (1200,1200) | toolbar strip (1200,60) |
|---|---|---|---|
| red 255,0,0 | 53,34,32 | 46,38,37 | 41,31,31 |
| green 0,160,0 | 35,43,32 | 39,43,38 | 31,36,30 |
| navy 0,0,128 | 35,35,53 | 35,35,42 | 28,29,35 |

## R6.2 Volume HUD, light/grey and dark/blue: done
- `screens/27.2.1/panels/hud-volume-appear-{grey-light,blue-dark}.mov`
- Frame changes (pts): light/grey: 0.483 to 1.250 s (appear), pause, 1.433 to 1.967 s (fade). Dark/blue: 0.483 to
  1.283 s, pause, 1.483 to 2.000 s. Same timing as round 3 (dark/grey): fade starts about 1.0 s after the first frame
  and lasts about 0.5 s.

## R6.3 Segmented control drag: done (Finder view switcher)
- `screens/27.2.1/controls/segmented-drag-{light,dark}.mov`
- Control: Finder toolbar view switcher (the Appearance Light/Dark/Auto choice is not a segmented control).
- Answer: **no lens.** On mouse down the selected segment's pill darkens (pressed). While dragging, the pill stays on
  the original segment until the pointer is over the next segment, then the pressed pill **jumps** to that segment
  (no sliding, no glass lens, no magnification). On release the selection is committed (view changes to list).
  Same in light and dark.

## R6.4 Disabled zoom press and inactive close press: done
- `screens/27.2.1/windows/lights-{zoom-disabled,inactive}-press-dark.mov`
- Disabled zoom (Calculator): the green button is a plain grey disc. On hover the red and yellow show their glyphs, the
  grey disc gets **no glyph**; pressing and holding it shows no visible change (no darken, no bounce); release does
  nothing.
- Inactive window (TextEdit behind key Calculator): all three lights are grey. Moving the pointer onto the group turns
  all three to their colours with glyphs (red ×, yellow −, green zoom) while the window stays inactive; pressing the
  close button darkens it (pressed state); release over it closes the window **without** activating the app first
  (Calculator stayed frontmost).

## R6.5 Emoji in a file name, list and menu: done
- `screens/27.2.1/finder/emoji-secondary-{list,menu}-{light,dark}.png`
- Menu: the window title path menu (right-click / Cmd-click on the document title) instead of Open Recent (Open Recent
  lists the user's real documents). Blurred: the home folder name and the computer name.
- Emoji keep full colour in the list row (secondary columns stay grey text) and in the menu, including the highlighted
  (selected, accent-filled) menu row; no monochrome fallback.
