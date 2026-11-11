# Refraction and blur over stripes (plugin, 2026-11-11)

Judge #2 gap 1: glass interiors were flat over stripes (about ±1 level) and the rounded ends showed no lens bands. Cause: the
plugin's blur was not Apple's. Every glass read Hyprland's full blur (or deep box mips of a sharp copy), so the backdrop
the bevel bends was already uniform. The lens maths (quarter-circle bevel, amounts per recipe) was right all along.

## What changed (plugin only)

- **Blur = Apple's pyramid** (MAC-ANSWERS C3 2, `glass_model.py` C3). Level 1 of a box-sized copy is the 2x2 box (Apple's
  backdrop at scale 0.5). Every deeper level comes from the one above through Apple's 13-tap downsampler. Each read is one
  trilinear tap at `log2(1/scale) + lod(1.6 r texels/pt)`.
- **Per-pixel radius:** `r = BlurRadius x opacity(d + displacement)`, with Apple's BlurOpacity0..2 over BlurDistance0
  (-0.5 D, CC -100), -1, 0. The old shader read the three recipe opacities as differences, which inverted the CC ramp.
  The bevel now reads deeper and blurrier backdrop, so stripes compress into concentric bands at rounded ends.
- **Blur fill:** two taps at ∓L/4 texels of radius 8's level. **Edge bleed:** radius 0.175 D.
- **Recipes carry Apple's BlurRadius:** Regular 5 (opacity 0.8 q / 0.4 q / 0.5), Clear 0.75, Dock 1.5, CC 4, Spotlight 6
  (unverified, as before). `check_model.py` now ports BlurRadius, BlurOpacity0..2 and BlurDistance0. All 32 inputs equal
  Apple's on the whole grid.
- **Control Center underlay:** on the Mac the tiles sample the panel's own blur under them. hyprk's panel is a dim only,
  so `underlay_blur = hyprk-controlcenter:2.05` composes that blur into the tile reads (`4^L - 1` adds). The radius is
  **fitted** to the real tile's contrast at 15 pt deep (7.9 levels, C2 `cc-real.json`). It is not decoded.
- **Hyprland's blur is no longer called by the glass.** That is where the speed-up comes from.

## Numbers (MBA 2560x1664 @ 2, dark appearance, slider 0.507, 4 pt black/white stripes; peak to peak in levels of 255)

| surface | metric | Mac | before | after |
|---|---|---|---|---|
| CC Display tile | interior 8 / 15 pt below top | 10.4 model / 7.9 | 3 / 4 (dither) | 7 / 7 |
| CC Display tile | centre line | 3.0 (probe) | 4 (dither) | 2 |
| CC rounded end | centre row vs Mac crop, depth 1..50 pt | - | flat 108-110 | rms 1.61 (Apple's shader on the Mac's own panel blur: 0.91) |
| CC rounded end | lens band turning points, px from edge | 8 10 13 17 25 32 41 49 57 | none | 8 10 13 17 25 30 38 46 55 |
| HUD | 8 / 15 pt below top | no Mac capture; Apple model ~69 / 75 | 3 / 4 | 58 / 61 |
| Dock | std along x, 8 / 15 pt (Mac `stdx` 31.4, row not recorded) | 31.4 | 11.2 / 12.2 | 28.6 / 27.1 |
| Regular ≥ 160 (menus, NC banner) | interior | "fully blurred" (C2) | faint stripe streaks | uniform |

- **Rim profile** over grey, CC top, 0..9 px: before 231 178 134 128 123 119 117 116 114 113, after
  231 179 133 127 123 120 117 116 114 113. Mac: 233 180 134 128 124 121. Unchanged.
- **Flat colours, re-checked:** CC tile 186/109/32 (Mac 186/109/32, before 186/108/32). CC over blue 64,80,212 (Mac 64,80,212).
  HUD over blue 68,85,232 (Mac 68,85,232). Dock dark 176/108/13 (Mac 176/107/12). Gap 114 / 229 unchanged.
- **GPU time** per glass element while CC opens/closes and the HUD animates (`stats = 1`, same session):
  before 0.49-0.54 ms avg / 0.71-0.87 p95, after 0.17-0.22 / 0.29-0.37. Whole-frame p95 17.0-19.5 → 16.9-17.0 ms.
  Nothing new runs at rest.

## Crops (left before, right after; the CC crop is Mac | before | after)

`refraction-cc-end-mac-before-after.png`, `refraction-hud-before-after.png`, `refraction-dock-before-after.png`,
`refraction-menu-before-after.png`, `refraction-banner-before-after.png`

## In the apple_model ctest (section 5)

- A port of the shader's sampling is run on Apple's C3 pyramid against the Mac's real CC tile row (C2 crop). The test
  fails if rms > 2.5 or worse than Apple's own shader by more than 1 level.
- It also checks the 15 pt contrast (7.9 ± 1.5).
- It checks the port against Apple's model for 7 material/size cases (max diff 0.00).

## Not derived or not verified

- **CC panel blur:** its kernel and radius are not decoded; see "Panel blur" for what is fitted and what follows from it.
- **Pyramid base at scale 0.25 / 0.125:** ours is the 13-tap level of the 0.5 base, Apple's is a box. Apple's half-size
  base for R > 2 is not modelled. The shadow tint reads level 6 (not decoded).
- **HUD:** no Mac capture over stripes, so only Apple's model backs it. Over flat grey the HUD body has a 114→118
  vertical gradient. It was there before this change too and is not explained.
- **Not seen on screen over stripes:** Cmd-Tab (the switcher did not open in the headless session; same Dock recipe and
  code path). NC cards: the widgets drew opaque. Spotlight looked identical before and after (its field is the shell's
  dark fill).
- ~~The gap between CC tiles is still sharp stripes~~: done, see "Panel blur" below.

## Panel blur (Control Center, 2026-11-11, second pass)

On the Mac the gap between CC tiles shows the stripes blurred and dimmed (C2 `cc-real.json`: 32 levels peak to peak at every
slider value, mean 0.898 x in), and the tiles sample that blur. hyprk had the dim only (shell's dim layer), the gaps showed
sharp stripes, and the tiles read a fitted `underlay_blur` (2.05) composed into their own blur.

- **Kernel: Apple's pyramid, not a Gaussian.** The Mac's gap row (`cc-real-stripes-a0.5071146.png` row 150, 400 px) is a
  trapezoid (flat tops 4 px), which a single trilinear read of Apple's pyramid reproduces and a Gaussian does not: pyramid at
  scale 0.5, level 1.52 = **radius 1.79 pt**, rms **0.47** levels (Gaussian best fit sigma 2.6 pt: rms 1.37). One parameter,
  fitted. Not decoded: the CC panel layer cannot be dumped from another process.
- **Edge:** leaving the tile column the Mac's contrast grows over about 30 pt. A radius ramping linearly (as Apple's
  BlurOpacity) from 0 at a box 44.8 pt outside the tiles' bounds to full 72 pt inside fits the first 140 px at rms 2.8
  (no ramp 11.2). Fitted, two parameters.
- **Mechanism (plugin `panel_blur`):** before the CC layer's glass, the grown box is redrawn from the element's own
  full-resolution pyramid (level 0 = the screen, so the ramp's edge has no seam), then the tiles copy the framebuffer again and
  sample the blurred panel, as on the Mac. `underlay_blur` is off. Radius and alpha follow the tiles' materialize and the
  layer fade (CC open, gap peak to peak per frame from the first panel frame: 241 236 202 168 135 107 71 58 50 43 38 ... 28).
- **What follows without fitting** (apple_model section 5, sharp 4 pt stripes): tile 15 pt below the top 7.7 levels (Mac 7.9;
  underlay 2.05 gave 7.3), rounded-end row vs the Mac crop rms 1.37 (underlay 1.61; Apple's shader on the Mac's own gap 0.91),
  lens band turning points 8 10 13 17 25 31 40 46 56 px (Mac 8 10 13 17 25 32 41 49 57).

| on screen, MBA 2x, dark, 4 pt stripes | Mac | before (underlay 2.05) | after (panel blur) |
|---|---|---|---|
| gap between tiles, peak to peak | 32 (33 in the crop) | 229 (sharp) | 26 (interior; 33-38 near the screen edge, Mac also grows there) |
| gap shape | trapezoid 99..131 | square wave 0..229 | trapezoid 101..127 |
| Display tile 8 / 15 pt below top | 7.9 at 15 | 7 / 7 | 6 / 7 |
| rounded end ripple, depth 4-20 / 20-50 pt | 10 / 7 | 6 / 5 | 9 / 6 |
| lens band turning points (px) | 3 4 5 6 8 10 13 17 25 32 41 49 57 | 3 4 5 7 8 10 13 17 25 33 41 49 57 | 3 4 5 6 8 10 13 17 25 33 40 49 57 |
| flat tile white / grey / black / blue | 186 / 109 / 32 / 64,80,212 | same | 186 / 109 / 32 / 64,80,212 |
| flat gap white / grey / black / blue | 229 / 114 / 0 / 62,75,185 | same | 229 / 114 / 0 / 62,75,185 |
| top rim over grey, px 0..5 | 233 180 134 128 124 121 | 231 179 133 127 123 120 | 231 179 133 127 123 120 |

- The "after" column was taken with the wallpaper decoded at the logical size (4 pt stripes had 4 px ramps on the 2x
  output). Since 1ee085c the shell cuts and decodes it at the output's pixel size, so the stripes are sharp as on the Mac.
  Re-measured then (plugin 5e9aff0, same row between the Display and Sound tiles, x 1015..1235 pt): gap peak to peak
  **31** levels (Mac 32), trapezoid **99..130** with 4 px flat tops, mean 114.4 (Mac 99..131, 114.8); Display tile 8 / 15 pt
  below its top 8 / 8 (Mac 7.9 at 15). The other rows were not re-measured.
- **Cost** (`stats = 1`, CC opened and closed 6 times, same session): glass per element avg 0.24 -> 0.39 ms, p95 0.33 -> 0.66
  ms (the CC element: a panel pass over its box and a second pyramid); whole frame p95 18.1 -> 18.0-19.4 ms (noise). Nothing
  runs at rest.
- The phase of the stripes against the tile edge differs between the Mac crop and our screen, so row rms against the crop is
  phase-dominated on screen (4.2 before, 4.9 after); band positions and ripple amplitude are the phase-free measures above.

## Rounded-end ripple (judge #3 gap 15, 2026-11-11)

Judge #3 read the CC tiles' rounded ends at ±4-6 levels vs the Mac's ±3-4. Most of that was stripe phase: re-measured with the
wallpaper's stripes at the Mac crop's phase (black from 4.5 px left of the tile edge, the phase the Mac's gap row fits; MBA 2x,
dark, Display tile left end, rows 58..72 px of the tile = 15 rows above its slider, depth 2..28 pt), ours was 103..115, peak to
peak 12.0, vs the Mac's 105.6..115, 9.3: the troughs too deep by 2.6 levels. Cause: the panel blur's ramp. Beyond the lens the
tile reads straight down, and in the lens it reads up to 80 pt inside, both within the ramp; our gap row there had 90 where the
Mac has 96 (second trough, 15 pt in). A single linear ramp cannot give the Mac's gap row (sharp first stripe, full blur from the
third) and the tile end together (best: gap 2.0 / tile 1.4 or gap 3.6 / tile 1.1), so the ramp now has a knee: 0 at 54 pt
outside the tiles, 0.15 x the radius at 36 pt in from there, full at 72 pt (fitted, 4 parameters, not decoded; the shader's
BlurOpacity0..2 carry it, no new code). Model (check_model's port of the tile row over the ramped panel row) and screen:

| MBA 2x, dark, 4 pt stripes at the Mac's phase | Mac | before (44.8 / 72 linear) | after (54 / 36 @ 0.15 / 72) |
|---|---|---|---|
| Display tile left end, peak to peak / min / max | 9.3 / 105.6 / 115 | 12.0 / 103 / 115 | **9.0 / 105 / 114** |
| same, mean row rms vs the Mac crop / bias | | 1.34 / -1.09 | 1.16 / -0.96 |
| gap row where it leaves the tile column, rms over 140 px | | 2.28 | 2.27 |
| gap interior peak to peak / mean (x 1015..1235 pt) | 32 / 114.8 | 31 / 114.6 | 31 / 114.6 |
| Display tile 8 / 15 pt below its top | 7.9 at 15 | 8 / 8 | 8 / 8 |
| right end troughs | | 103 | 104 |

The panel box grows from 44.8 to 54 pt outside the tiles (a few more pixels redrawn while the CC changes; nothing at rest).

## Other glass checks (same session)

- **Finder context menu (plugin `popup_classes`):** before, the client's translucent tint over Hyprland's popup blur; after,
  the shell dropdown's `menu` glass behind the xdg_popup. Dark, over white: empty area 121 (Mac 120, shell dropdown 121),
  below at 2/10/20/30 pt 214/225/239/248 (Mac dark 214/225/238/248), beside at 2/10/20 pt 229/239/249 (Mac 228/238/248, shell
  230/240/249). Over blue: 75,90,220, the shell dropdown the same. Light over Finder's rows: 251,252,253 (Mac light over white
  251,252,255). Submenus get it too. Close: glass and content fade together, empty-area pixel over white per frame
  121 143 164 183 200 214 227 237 245 250 254 255 (the shell dropdown: 121 142 164 182 213 226 236 244 250 253 255).
  Side by side, light: `popup-menu-mac-finder-shell-light.png` (Mac | Finder | shell dropdown).
- **Cmd-Tab:** over grey 127 the switcher's top rim and body read 156 117 113 111 109 ... 107, the Dock's exactly the same
  (Dock material, as Q-dock-19). Its body vs the Mac Dock: 107 (Mac 107); the second rim px 117 vs the Mac's 135 is the Dock
  rim's own gap, not the switcher's.
- **HUD body gradient over flat grey (114 -> 118):** not the glass. The HUD sits in the menu bar's contrast gradient
  (Q-menubar-02: 128 -> 112 at the top, 30 % at 60 pt, gone by 100 pt): the backdrop beside it reads 122 at y 60 pt and 127 at
  95 pt, and the controlCenter face gives 0.125 x 255 + 0.675 x in = 114.2 / 117.6 there, the measured 114 / 118. White 204,
  black 32, blue 68,85,232 (Mac 68,85,232). The Mac HUD (y 44..109.5 pt) also lies in that zone; no Mac HUD capture over flat
  grey exists to confirm the Mac's backdrop includes the gradient.
- **Spotlight field:** REA gives Regular at size class large (D 201.3) with content lensing. Tried as a recipe: under the shell's
  fitted veil the field read white / grey / black at mid-height 32 / 30 / 10 (Mac 65 / 36 / 6) and bottom 62 / 59 / 21 (Mac
  127 / 64 / 17): dark Regular's max luma (0.35 at that size) flattens the backdrop to 115-122, while the Mac field rises
  0.23 x in at mid-height and 0.5 x in at the bottom. The pixels fit a near-identity glass under a dark gradient (the old
  Siri-branch recipe + veil: grey 6 / 37 / 71, Mac 6 / 36 / 64), so the old recipe stays; what darkens the real field on top of
  the Regular glass is not found. The Mac shows a soft shadow under the bar (127 -> 96 at the edge) although the code says
  excludingShadow(); ours has none.
