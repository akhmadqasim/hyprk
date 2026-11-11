# Window shadow vs macOS 27.2.1 (2026-11-11)

Mac: `MAC-ANSWERS.md` Q-windows-01 (Finder, `screencapture -l` alpha at 2/8/16/32 pt from the edge) and the AppKit
`shadowParameters` (blur 20 / 8 pt, y offset 18 / 7, density .40 / .22 light, .70 / .45 dark, active / inactive).
Ours: headless session (`scripts/smoke.sh`, MBA 2560x1664@2x), a blank `foot` window 700 x 500 pt (+ 33 pt title bar)
at 150,160, flat wallpapers white, grey 127 and black, light and dark, active and inactive (a small second window took
the focus). Darkening = 1 - pixel / backdrop. White and grey give the same alpha within 0.005 (black ink, as on the
Mac); black shows nothing. Distances from the window body edge (outside our 1 pt rim; the Mac's 0.5 pt rim is
the Mac's px 1). Side profile at mid-height, below and above at mid-width.

Crops (`shadow-<active|inactive>-<light|dark>.png`, bottom-left corner, 2x): Mac left, before middle, after right.

## Numbers (alpha at 2 / 8 / 16 / 32 pt, white backdrop)

| state | side | below | above | rms (12 points) |
|---|---|---|---|---|
| Mac light active | .18 .14 .09 .02 | .32 .28 .22 .09 | .06 .04 .02 0 | |
| before | .27 .16 .07 .01 | .28 .28 .23 .05 | .08 .04 .01 0 | .031 |
| after | .18 .14 .09 .03 | .33 .29 .20 .08 | .06 .04 .03 .01 | **.010** |
| Mac light inactive | .09 .04 0 0 | .16 .10 .03 0 | .03 .01 0 0 | |
| before | .10 .06 .03 0 | .11 .11 .09 .02 | .03 .02 0 0 | .025 |
| after | .06 .05 .03 .01 | .12 .11 .07 .03 | .02 .02 .01 0 | **.023** |
| Mac dark active | .33 .25 .15 .04 | .56 .49 .38 .17 | .11 .07 .03 0 | |
| before | .47 .28 .13 .02 | .49 .49 .40 .08 | .15 .07 .02 0 | .054 |
| after | .32 .25 .16 .06 | .57 .51 .35 .13 | .10 .08 .05 .02 | **.019** |
| Mac dark inactive | .19 .08 .01 0 | .33 .21 .06 0 | .06 .02 0 0 | |
| before | .21 .13 .06 .01 | .22 .22 .18 .04 | .06 .03 .01 0 | .052 |
| after | .14 .11 .07 .02 | .25 .22 .15 .06 | .04 .03 .02 .01 | **.047** |

All 48 points: rms .043 -> .028. Judge #1's gap (light active side at 2 pt .26 vs .18) is closed: .18.
Against a 2D model of the Mac shadow (density x Gaussian edge in x and y, sigma = blur radius, offset rect; it
reproduces every Q-windows-01 point within .01) over the whole shadow field of 500x350, 700x533 and 1000x700
windows: mean rms .039 -> .031 (model numbers, not screen).

## What changed (config/hypr/hyprland.lua)

`range 70, render_power 3, offset 0 4` and the shadow colour as a 10-stop vertical gradient over the shadow box
(top, top, side x6, bottom, bottom) per state, alphas fitted to the 48 profile points:
light active .074 / .19 / .327, inactive .027 / .067 / .122; dark active .132 / .334 / .573, inactive .054 / .143 / .252
(above / side / below). Same shader and cost as a flat colour.

## What remains and why

- **One falloff for every side and state.** Hyprland's shadow is `alpha * (d / range)^power` from the box edge, at
  full alpha at the window edge; AppKit's is a Gaussian of a rect offset 18 pt down, so it is half density at the
  side edge and ~0.8 below. A flat colour cannot get both (the best flat fit is the old 52 / 4 / 12, side .27 vs .18).
  The gradient gives each band its own alpha, the falloff shape is still shared.
- **Inactive is too long.** AppKit's inactive blur is 8 pt (gone by ~16 pt beside); Hyprland has one range for
  active and inactive, so the inactive tail at 16-32 pt stays .03-.07 too dark (dark inactive rms .047).
- **Sides near the corners.** The gradient is linear between evenly spaced stops, so the side alpha ramps from the
  above value over the top ~75 pt of the window's sides and towards the below value over the bottom ~75 pt
  (measured 20 pt from the bottom: .28 vs Mac ~.18 light active; 20 pt from the top .14). The Mac's side is constant
  to ~25 pt from the bottom corner. Included in the 2D rms above.
- **Window height.** Stops are spaced by box height / 9; the bands above and below keep their own alpha only when
  that is at least range + offset (74 pt), i.e. windows from ~520 pt tall (with title bar). Below that the bands
  blend towards the side value (model: profile rms .028 at 533 pt, .033 at 350, .048 at 250).
- **Rims** were not re-measured here (Q-windows-03; the border is per state already). In the light active crop the
  plugin's title bar covers the top edge, which shows no outer rim there (hand-off to `plugin/`, not compared with
  the Mac top edge).

## Plugin shadow (judge #3 gap 7, 2026-11-11, second pass)

Hyprland's falloff cannot give AppKit's shadow (one range for every side and state, the gradient's bands blend on short
windows), so the liquidglass plugin now draws it (`window_shadow = 1`, `plugin/src/WindowShadow.cpp`) and the config turns
Hyprland's off when the plugin loads. It is the 2D model above, analytic per pixel: black, alpha = density x Gx x Gy, Gx and Gy
the Gaussian edges (sigma = blur radius, erf) of the frame (title bar and border included) moved down by y, with AppKit's
numbers (blur 20 / 8 pt, y 18 / 7, density .40 / .22 light, .70 / .45 dark), nothing inside the rounded frame. Derived, no fit.

Same method as above (blank foot 700 x 500 pt + title bar at 150,160, white, a small second window takes the focus; distances
from outside the 1 pt rim; title bar taken as 32 pt):

| state | Mac side / below / above at 2 / 8 / 16 / 32 pt | before (Hyprland gradient) | after (plugin) | rms before -> after (12 points) |
|---|---|---|---|---|
| light active | .18 .14 .09 .02 / .32 .28 .22 .09 / .06 .04 .02 0 | .17 .13 .09 .03 / .33 .27 .19 .07 / .06 .04 .03 .01 | .18 .14 .08 .02 / .32 .28 .22 .10 / .06 .04 .02 0 | .013 -> **.004** |
| light inactive | .09 .04 0 0 / .16 .10 .03 0 / .03 .01 0 0 | .06 .05 .03 .01 / .12 .10 .07 .03 / .02 .02 .01 0 | .09 .03 0 0 / .16 .10 .03 0 / .03 .01 0 0 | .022 -> **.003** |
| dark active | .33 .25 .15 .04 / .56 .49 .38 .17 / .11 .07 .03 0 | .31 .23 .15 .05 / .57 .48 .33 .12 / .10 .08 .05 .02 | .32 .24 .15 .04 / .55 .48 .38 .17 / .11 .07 .03 0 | .025 -> **.005** |
| dark inactive | .19 .08 .01 0 / .33 .21 .06 0 / .06 .02 0 0 | .13 .10 .07 .02 / .25 .21 .14 .06 / .04 .03 .02 .01 | .18 .07 .01 0 / .33 .20 .06 0 / .06 .01 0 0 | .045 -> **.005** |

All 48 points: rms .029 -> **.004**. Short windows and corners (light, 20 points: the three profiles plus the side 20 pt above
the bottom and 20 pt below the top, against the AppKit model for that window): 250 pt tall active .029 -> .001, inactive .024
-> .001; 350 pt .019 -> .001, .024 -> .001; 500 pt .030 -> .001, .025 -> .001 (before: side 20 pt above the bottom corner .27
vs .18 at 500 pt, the band below .25 vs .32 at 250 pt).

Cost (`stats = 1`, RX 6600 class GPU, MBA 2x, the 700 x 533 pt window moved every frame for 2 s, two windows): plugin shadow
0.16-0.17 ms per draw (p95 0.18); Hyprland's shadow, timed the same way in a scratch build that wrapped its
`drawShadowInternal`, 0.09 ms average over both windows, p95 0.18 ms (the large one). Same order; nothing is drawn at rest
(only damaged parts are redrawn, no texture or cache). The closing fade takes the shadow with the window as before (both are
window decorations). The close fade, zoom and full screen frames were checked on screen later (next section).

## Inner rim (judge #3 "not possible with Hyprland's border", 2026-11-11)

Q-windows-03: inside the 0.5 pt black rim a 1 pt white rim, alpha .10 (.08 dark inactive), on every edge. The plugin draws it
(`window_rim = 1`, same element and shader as the shadow, decoration layer OVER, inside the border at the window's corner).
Dark, blank foot (36): 2 px just inside the border 36 -> 58 active, 54 inactive (36 + .10 / .08 x 219; the Mac's TextEdit bar
40 -> 61 is the same formula). Shadow numbers unchanged with it on. Light: invisible over white content, as on the Mac.


## Shadow and rim in motion, other surfaces, cost (2026-11-11, plugin session 6)

Headless MBA 2x, blank foot 700 x 500 pt at 290,139, light, mcap per frame (the shadow read as 1 - frame / the same frame
without it, or against the backdrop after the close).

- **Close fade: fixed (plugin-motion 96fd560).** The shadow got darker while the window faded: plugin-motion's close blur
  averaged its 13 taps with the 1/k over trick, exact for opaque pixels only; over the translucent shadow the alpha piled up.
  4 pt below the window over a 100 backdrop (68 at rest): window alpha .73 / .47 / .30 read 53 / 71 / 82 (1.5-2x the faded
  shadow); now, clean session, alpha .70 / .45 / .29 / .18 / .10: 78 / 86 / 92 / 95 / 97 (rest x alpha: 77.6 / 85.6 / 90.7 /
  94.2 / 96.8), 8 pt beside 130 / 137 / 140 / 142 (130 / 135 / 138 / 140). The rim fades in the same snapshot.
- **Unzoom (and zoom, the same element):** frames paired by window box with a run without shadow: 8 pt beside .155-.169,
  16 pt below .236-.248 in every mid-flight frame vs .158 / .241 at rest; no detached or missing frame (the shadow is drawn
  from the animated box each frame). A zoomed (maximised) window keeps its shadow, as on the Mac.
- **Full screen:** no shadow and no rim (foot at 0,34 on MBA: strip 0, first column 36 = the client), as on the Mac. The
  shadow is dropped when the full-screen state is set, at the start of the enter animation (not compared with a Mac
  recording: none has the shadow over the transition).
- **Other surfaces:** layer surfaces and xdg_popups (GTK popovers and tooltips, Qt menus, Finder's context menu glass) are
  not windows and get neither (gnome-calculator's main menu: GTK's own outline only, no box behind it); X11 override-redirect
  windows (X menus, tooltips) and `suggestsNoBorder` windows are skipped by Hyprland's decoration pass; Quick Look has
  `no_shadow` (its own drawn shadow stays single) and that also removes the rim. Dialogs (toplevels with a parent) get both,
  as NSAlert / sheet windows do. Xwayland toplevels (xcalc) get shadow and rim, no title bar (the plugin cannot read
  `_MOTIF_WM_HINTS`; Hyprland does not parse them, so `titlebar = auto` would also decorate X clients that draw their own).
- **Cost: fixed (b819914).** The rim's quad covered the whole window to light its 1 pt edge, and the shadow's quad its
  inside: both now skip the frame deeper than the corner radius (pixel-identical). Four foot windows, GPU per frame for all
  shadows and rims: Control Center open/close 0.88 -> 0.40 ms (p95 1.06 -> 0.42), window drag 0.55 -> 0.31, Dock sweep 0.45
  -> 0.17, Mission Control 0.56 -> 0.33; nothing at rest. 4K 1.5x, one window, whole output redrawn: 0.07 ms per frame.
