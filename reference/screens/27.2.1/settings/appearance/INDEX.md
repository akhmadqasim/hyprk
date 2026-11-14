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

## Round 3 (R3.7): Liquid Glass preview article, scrolled
Display 1440x932 pt (2x), Settings relaunched in each mode, window at 350,150 (740x625 pt), wallpaper TahoeLight /
TahoeDark. Window shot `screencapture -x -o -l<id>`, cropped to the preview scroll area: window px **884,322 536x360**
(= screen pt 792,311 268x180, the AXScrollArea frame). Steps: one synthetic scroll-wheel event of -100 px (pixel units,
no momentum) with the pointer over the preview (926,400 pt), still 1 s after each step; stopped when a still matched the
previous one. 00 = top, 11 = end (content 268x1257.5 pt, so the last step is partial).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| preview-article-scroll-{00..11}-light.png | window shot, crop above | the article under the toolbar capsules, 100 pt apart | light | article (page colour) |
| preview-article-scroll-{00..11}-dark.png | same | same | dark | article (page colour) |

## Round 3 (R3.8a): Appearance pop-up buttons up close
Display 1440x932 pt (2x), Settings relaunched per mode, window at 350,29 (740x625 pt) so every menu fits on screen,
content scrolled 250 pt so the three pop-ups are in view (frames from an AX dump). Region shots `screencapture -x -R`.
rest = pointer 120 pt below; hover = pointer on the button centre 0.8 s; pressed = 30 ms after a synthetic mouse down
(the menu is not drawn yet; it opens on mouse down); open = 1 s into the hold, crop = the menu window (CGWindowList layer
101) united with the button, +8 pt. The mouse up landed on the checked item, so no value changed.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| control-text-highlight-colour-{rest,hover,pressed,open}-{light,dark}.png | button 927,537 133x24 pt, crop ±24/16 pt; menu 840,458 318x422 | "Text highlight colour" (Automatic): Automatic ✓, Blue, Purple, Pink, Red, Orange, Yellow, Green, Graphite, Choose Colour… | both | window / TahoeLight, TahoeDark |
| control-folder-colour-{rest,hover,pressed,open}-{light,dark}.png | button 927,439.5 133x24; menu 840,360 296x422 | "Folder colour" (Automatic, shown with icon style Dark): Automatic ✓, Red … Graphite, Choose Colour… | both | same |
| control-sidebar-icon-size-{rest,hover,pressed,open}-{light,dark}.png | button 964,536 96x24; menu 877,432 246x232 | "Sidebar icon size" (Medium): Small, Medium ✓, Large | both | same |

## Round 7 (R7.1b): Liquid Glass preview capsules, hold and tap
Display 1440x932 pt (2x), Settings relaunched per mode, window 350,150, Appearance at scroll 0, other apps hidden. Crop
rect (screen pt) **780,300 292x200** = the preview (scroll area 792,311 268x180) plus a 12 pt margin. The capsules are
not AX elements; targets from pixels: share glyph 818,336 (share / more capsule 800..873 x 318..354), search capsule
centre 987,336 (925..1052). Clips `screencapture -x -C -v -V 6.5 -R 780,300,292,200`: pointer on target at about 0.8 s,
mouse down, 2 s hold while tracing a 14x10 pt rectangle, release, 1 s, then a quick tap (80 ms).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| preview-hold-shine-share-{light,dark}.mov | clip above, target share | hold (moving) then tap on the share part of the share / more capsule | both | article photo |
| preview-hold-shine-search-{light,dark}.mov | clip above, target search capsule | hold (moving) then tap on the search capsule | both | article photo |
| preview-hold-shine-held-{light,dark}.png | `screencapture -x -R` same rect, 0.9 s into the share hold | share held: bright glow inside the capsule around the pressed glyph | both | article photo |
