# System Settings > Appearance, 27.2.1 (26B131)

2x captures. Window shots are `screencapture -o -l` (no shadow), 740x625 pt (1480x1250 px). Wallpaper TahoeLight in light
mode and TahoeDark in dark mode. Accent is Multicolour. Icon style is Dark (RegularDark, the account's value) unless the
file name says otherwise. The Apple Account and Family rows are filled flat with the sidebar colour (privacy).
Layout numbers: `reference/re/27.2.1/live/settings/appearance/layout.json`.

## Whole pane
| file | content |
|---|---|
| appearance-full-{light,dark}.png | the content column (x 232..740 pt, 508 pt wide) stitched top to bottom: toolbar + the full 1036.5 pt document. Shot at offset 0 up to doc y 544, then the offset-463.5 shot. 1016x2177 px |
| appearance-scroll-000-{light,dark}.png | whole window, scroll offset 0 (no hairline under the toolbar) |
| appearance-scroll-010-{light,dark}.png | offset 10: the 0.5 pt hairline at y 52 is present |
| appearance-scroll-250-{light,dark}.png | offset 250: the Liquid Glass preview passes under the toolbar (blurred/faded strip) |
| appearance-scroll-463-{light,dark}.png | offset 463.5 = bottom of the pane |

## Liquid Glass
| file | content |
|---|---|
| liquidglass-0-mid-1-{light,dark}.png | the Liquid Glass preview + slider row at NSGlassTintAmount 0 / 0.507 / 1 (left to right). 0 = clearer capsules, 1 = frosted/tinted capsules |
| liquidglass-slider-zoom4x-{light,dark}.png | the slider row at 4x (nearest): end buttons, track, knob, tick dots |

## Icon & widget style (light, card crop x 252..720, scroll offset 300)
| file | content |
|---|---|
| iconstyle-dark-light.png | Dark selected: Always/Auto radios, "Folder colour" pop-up |
| iconstyle-default-light.png | Default selected: no radio row (card 16.5 pt shorter) |
| iconstyle-clear-light.png | Clear selected: Light/Dark/Auto radios |
| iconstyle-tinted-light.png | Tinted selected: Light/Dark/Auto + "Icon, widget & folder colour" |
| iconstyle-tinted-red-auto-light.png | Tinted, Auto, colour Red (tile and caption) |
| iconstyle-colour-menu-light.png | the colour pop-up menu open (Automatic ✓, 8 colours with dots, Choose Colour…) |
| iconstyle-colour-menu-red-light.png | the same menu with Red checked (menu re-positioned over the button) |
| iconstyle-choose-colour-popover-{light,dark}.png | "Choose Colour…" popover: hue slider, opacity slider, Colour Picker, Use Theme Colour |

## Controls
| file | content |
|---|---|
| probe-switches-{light,dark}.png | own probe (`tools/probe/switches.swift`): NSSwitch regular, small, mini; off left, on right (window not key in these shots: grey traffic lights) |
| scroller-overlay-visible-dark.png | frame from a 60 fps clip (video colours, nv12): right edge of the pane while the overlay scroller is shown, 6 pt knob |

## Round 2 (G1.1): flat grey backdrop
Display at the default 1440x932 pt (2880x1864 px, 2x). Desktop picture = solid RGB 127,127,127 (2880x1864). Window shot
`screencapture -x -o -l<id>` (no shadow), 740x625 pt. Pointer moved off the window. NSGlassTintAmount 0.5088. Accent
Multicolour, icon style Dark. Apple Account / Family rows filled with the sidebar colour (privacy).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| liquidglass-flat-grey-light.png | window, -o -l | Appearance pane, scroll 0, Liquid Glass preview | light | grey 127 |
| liquidglass-flat-grey-dark.png | window, -o -l | same | dark | grey 127 |
| liquidglass-flat-grey-capsules-light.png | crop of the window shot, px x 884..1420, y 322..422 | share / more capsule, copy circle, search capsule at 2x | light | grey 127 |
| liquidglass-flat-grey-capsules-dark.png | same crop | same | dark | grey 127 |
