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
