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

- **CC panel blur:** its kernel and radius are not decoded. The underlay is a single-number fit to 4 pt data. Under a
  Gaussian panel, 8 pt stripes would show about 1.5x our contrast, and nothing on the Mac measures that.
- **Pyramid base at scale 0.25 / 0.125:** ours is the 13-tap level of the 0.5 base, Apple's is a box. Apple's half-size
  base for R > 2 is not modelled. The shadow tint reads level 6 (not decoded).
- **HUD:** no Mac capture over stripes, so only Apple's model backs it. Over flat grey the HUD body has a 114→118
  vertical gradient. It was there before this change too and is not explained.
- **Not seen on screen over stripes:** Cmd-Tab (the switcher did not open in the headless session; same Dock recipe and
  code path). NC cards: the widgets drew opaque. Spotlight looked identical before and after (its field is the shell's
  dark fill).
- **The gap between CC tiles is still sharp stripes** (Mac: the panel blur, 32 levels). That needs a shell/config change.
  See hand-off.
