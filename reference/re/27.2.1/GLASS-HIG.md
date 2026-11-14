# Glass refraction on controls: Apple's HIG pictures against hyprk (2026-11-14)

The user's complaint: the glass refraction on buttons, sliders and the like still looks wrong next to a real Mac.
This round looked only at how the glass bends and lights what is behind it on controls (HyprK `LensGlass` /
`glasslens4.frag`: the held slider and switch knob, the Appearance pane's Liquid Glass preview buttons). The plugin's
panel glass (`plugin/shaders/liquidglass.frag`) was not touched: the controls' defects below are in the controls' own
model (it already implements the decoded recipes).

## 1. The pictures

Apple's pages (HIG Materials, Buttons, Sliders, Toggles, Segmented controls, Toolbars, Tab bars, Menus; the
Liquid Glass and Adopting Liquid Glass technology overviews) were read through the JSON behind them
(`developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`,
`.../documentation/technologyoverviews/<page>.json`). The pictures with real glass over a known backdrop are all
**iOS**; the component pages carry flat illustrations. Kept and indexed in `reference/hig/INDEX.md`:

- `adoption-guide-slider.mp4` (iOS, 30 fps): a held slider knob as a lens over its track and fill.
- `adoption-guide-segmented-control.mp4` (iOS): the segmented selection dragged as a lens over the labels.
- `materials-ios-liquid-glass-over-dark@2x.png` (iOS): a 157 pt Regular disc over stars (rim light by angle).
- looked at, not measurable: the Clear disc over bricks (too blurred to trace a displacement), the light disc, the
  tab bar / toolbar "after" pictures (illustrations: grey fill and a white rim, nothing behind them).

The Mac data reused (wins for macOS where they differ): MAC-ANSWERS Verify B 1 (rim tone curve), B 2 (inner / outer
refraction law, Regular recipe), B 5 (the held switch's displacement map), B2 1 (held slider), the 23.09.23
recording (section 17 of GLASS-INTERACTION), `settings/appearance/liquidglass-0-mid-1-{light,dark}.png`.

## 2. Method

- iOS slider: the blue fill mask (B - R > 50) inside the lens, 5063 pixels at depth > 3 px from the left end, against
  a simulation of the inner refraction law over the track reconstructed from outside the lens (scratch
  `fitflare.py`); grid over amount A and height H in units of the lens height D, both profiles.
- ours, geometry: `LensGlass` rendered in a headless hyprk session (scale 2) over a position-coded ramp
  (R = 4 x mod 256, G = 4 y mod 256 in pt), the source position decoded per pixel (scratch `decode.py`): the
  outward displacement as a function of depth from the rim (straight edge and round end agree within 0.25 pt).
- ours, on screen: Settings > Appearance in the same session, light and dark, the preview capsules at rest and the
  Liquid Glass slider knob held with vptr; "before" from a scratch tree with the old `ui/HyprK` and Appearance.
- held knobs over 4 pt black / white stripes (scratch `knob.qml`, Knob at lift 1): stripe edges along the lens.

## 3. Side by side

Displacement outward in pt (negative = the sample is taken further inside = the rim magnifies), by depth from the rim:

| control | source | 0.25 | 0.75 | 1.25 | 1.75 | 2.75 | 4.25 | 7.25 | axis |
|---|---|---|---|---|---|---|---|---|---|
| slider lens 25 x 20 | Mac decoded (3.6 / -6, quarter circle) | -3.80 | -2.33 | -1.45 | -0.85 | -0.17 | 0 | 0 | 0 |
| | ours before (0.1 D / -0.15 D, (1 - t)^2) | -2.24 | -1.24 | -0.50 | 0 | 0 | 0 | 0 | 0 |
| | ours after | -3.74 | -2.24 | -1.50 | -0.74 | -0.24 | 0 | 0 | 0 |
| switch lens 50 x 31 | Mac decoded / measured (7.75 m(d,31) - 4.65 m(d,3.1)) | +3.95 | +4.44 | +4.65 | +4.72 | +4.53 | +3.83 | +2.77 | +1.04 (Mac 1.1) |
| | ours before (inner only) | -4.00 | -2.74 | -1.74 | -0.74 | 0 | 0 | 0 | 0 |
| | ours after | +4.00 | +4.50 | +4.76 | +4.76 | +4.50 | +3.76 | +2.76 | +1.0 |
| preview button D 37 (Regular) | Mac recipe (inner 9.25 / -18.5, outer 16 / 16 at .6) | -14.2* | -11.2* | -9.2 | -7.7 | -5.3 | -2.9 | -0.4 | 0 |
| | ours before (fitted band 18.5 / +12.6) | +12.26 | +11.50 | +11.00 | +10.26 | +9.00 | +7.50 | +4.76 | 0 |
| | ours after | (outer mix) | -7.74 | -9.24 | -7.74 | -5.24 | -3.00 | -0.50 | 0 |

\* the outermost 1 pt also mixes in the outer sample (opacity .6 x (d + 1)); the ramp decode reads the mix there.

Checks of the new geometry against pictures:

| check | Mac / Apple | ours before | ours after |
|---|---|---|---|
| fill height 1.5 pt inside the held slider's round end (23.09.23 recording, 14 px fill) | 20 px | 18.2 px | 20.2 px |
| iOS slider video: fill mask mismatch (5063 px; no refraction 407) | best fit A -0.52 D, H 0.30 D: 170 | 388 | 334 (283 with the old profile) |
| held switch over 4 pt stripes: stripe pitch at the round ends | 0.79 x (Verify B 5) | 1.0 x (magnified only in the outer 3 pt) | 0.75-0.87 x (3.0-3.5 pt per 4 pt) |
| preview share button, bottom (light): what the rim shows | sky, no trees (the Mac shot) | trees pulled up from below the button | sky |
| preview Search button over the building | stripes folded vertical at the right end | stripes compressed diagonal | stripes folded vertical |

Rim and light, preview share button (`liquidglass-0-mid-1-*.png`, 2x, levels over the backdrop beside it):

| place | Mac | ours before (flat black .4 / .5 line) | ours after (dark specular, bias -0.25) |
|---|---|---|---|
| light, top rim | 227 -> 207 (x.91), then 255 252 244 | 224 -> 124 (x.55), then 240 | 224 -> 190 (x.85), then 255 255 253 |
| light, round end | 202 -> 135 (x.67) | 202 -> 125 (x.62) | 202 -> 141 (x.70) |
| dark, top rim | 228 -> 172 174 (no line, +10 key) | 224 -> 104 (x.46), 164 | 224 -> 212 (antialiased) -> 173 |
| dark, round end | 202 -> 101 (x.50), 126 144 | 202 -> 106 (x.52) | 202 -> 141 (x.70): worse |

Light direction: the HIG's dark disc is brightest at the top (+103) and bottom (+78), weakest at left / right (+44):
the same as the Mac decode (key top, fill bottom, dark lines left / right, fixed in layer space). There is no
top-left light on either.

What the iOS pictures show that the Mac data does not settle: the iOS slider lens bends harder than the Mac's dumped
slider recipe (best fit -0.52 D / 0.30 D against 0.18 D / -0.3 D) and has cyan / magenta fringes; the Mac's slider
filter has aberration 0 (Verify B 5), so the Mac numbers were kept. The iOS segmented lens shows the selected label
at 1.16 x inside the lens (a content scale of the lifted label, not a refraction of the grey label): not applied
(no macOS capture of a dragged NSSegmentedControl selection).

## 4. What changed

1. `ui/HyprK/shaders/glasslens4.frag`: the refraction profile is the filter's quarter circle
   `1 - sqrt(1 - (1 - depth / H)^2)` (`prof()`, line 88) instead of the fitted `(1 - depth / band)^2`; a second
   displacement term with its own amount and height (the backdrop displacementMap, line 127) and the Regular
   recipe's outer refraction (a sample further out mixed in over the outermost 1 pt, line 130); the rim line can use
   the filter's dark specular tone curve (line 162) instead of a flat black line. Rebuilt with
   `/usr/lib/qt6/bin/qsb --qt6 -o glasslens4.frag.qsb glasslens4.frag`.
2. `ui/HyprK/LensGlass.qml`: `dispAmount` / `dispBand`, `outerAmount` / `outerBand` / `outerOpacity`, `rimBias` /
   `rimSpread`; the texture margin covers the new amounts.
3. `ui/HyprK/Tokens.qml`: the switch lens gets the displacement map (+0.25 D over D: the rim now samples 4 pt outward
   and the middle shows the track at 0.79 x, where it magnified before); the slider lens its own inner term 0.18 D /
   -0.3 D (`sliderLens*`, was the switch's 0.1 D / -0.15 D); the fitted `lensBand` / `lensAmount` (0.5 D / +0.34 D,
   wrong sign) replaced by the Regular recipe functions `regular*` plus the rim bias -0.25, spread 106 / 75 deg, the
   key / fill highlight in light only (`regularFillLight`, dark measured +10 against the model's +36).
4. `ui/HyprK/Knob.qml` (lens geometry properties, switch by default), `ui/HyprK/Slider.qml` (slider geometry; also
   the Control Center sliders), `settings/panes/Appearance.qml` (the preview buttons use the Regular recipe, the
   dark specular rim and the fill light).

The light terms of the knob (gain, haze, diffuse, key, ring, fill; Tokens knobLens*) are unchanged; on screen the
held slider differs from before only inside the outer 3.6 pt (rms 0.0096 light / 0.0057 dark over a 90 x 45 pt box).

## 5. Unknown, and which Mac capture settles it

- The held switch's chromatic aberration (glassForeground, 1.632 pt at -15 deg, Verify B 5): only the tap layout is
  decoded (7 taps, R at +0.78 ab, B at -0.78 ab), not the height of its profile: not built. A 2x capture of the held
  switch over 4 pt black / white stripes, light and dark, would show the fringe width.
- The dark round end of the Regular buttons reads x0.50 on the Mac against the decoded curve's x0.70 (bias -0.25):
  the Mac dark shot over a flat grey backdrop at the end of a preview button would separate the tone curve from
  the outer sample.
- The preview's blur (17 taps) shows ripples over the building that the Mac's smooth blur does not; the folded rim
  makes them easier to see. Not changed (blur kernel, not refraction).
- The light preview face reads about 10 levels brighter than the Mac 4 pt under the top (252 vs 242): the face
  colour fit, not refraction; not changed.
- macOS segmented control selection dragged (does it become a lens, does its label scale 1.16 x as on iOS).

## 6. Round 2 (2026-11-14): dark rim, preview blur, held switch, fringes, segmented, CC knob

Measured in a headless hyprk session (scale 2, scratch HOME), Settings > Appearance preview crops at 2x
(`grim -g "715,238 265x50"`) against `settings/appearance/liquidglass-0-mid-1-{dark,light}.png` (middle panel, row
through the share capsule's centre; the Mac crop sits 8 px right of ours).

1. **Dark round end too light.** Cause: the rim's dark specular darkened the plain sample in both modes; the filter
   darkens after the face (verify C2 shader order), and the dark Regular face of 202 is 170 (verify C formula). Tone
   curve over the plain sample: 130; over the dark face: 99 (Mac 101). Light keeps the plain sample (face first would
   give 160 against the Mac's 135). `glasslens4.frag` rimSpec.z, `LensGlass.rimFace`, `Tokens.control.regularRimFace`.

   | | Mac | before | after |
   |---|---|---|---|
   | dark round end | 101 | 141 | 105 |
   | dark top rim pixel / next | 173 / 173 | 221 / 175 | 174 / 176 |
   | light round end | 135 | 141 | 138 |
   | light top rim / next | 217 / 252 | 199 / 255 | 201 / 254 |
   | light face 2 px inside the end | 237 | 243 | 236 |

2. **Preview ripples.** Cause: the 17-tap blur (two rings of 8 taps at the radius and half of it, radius 16 pt) drew
   each stripe of the building several times. The Mac's Regular glass at D <= 64 has no centre blur; its frost is the
   blur fill (verify C: radius 8, sigma 2.0 x radius = 16 pt, QuartzCore-glass-blur-pyramid.c), mixed with the sharp
   sample after darken (dark) / lighten (light) 0.9 and normal opacity N (0.507 at the slider's 0.507). Built as
   `blurFill()` (a 7 x 7 Gaussian grid read from a mip level near the tap spacing; ShaderEffectSource mipmap on), the
   outer sample sharp. Dark lines in the building now stay sharp in dark and vanish in light, as on the Mac.
   Measure: dips per row deeper than 1.5 levels in a band-pass (Gaussian 1 px minus 6 px) of the Search capsule right of
   its label (x 150..245 px from its left rim, y 18..82):

   | | Mac | before | after |
   |---|---|---|---|
   | dark: dips / row, correlation with the Mac | 4.00 | 9.53, 0.63 | 3.59, 0.76 |
   | light | 3.47 | 7.20, 0.85 | 4.11, 0.83 |

   The shader now builds with `--glsl "300 es,150" --hlsl 50 --msl 12` (textureSize / textureLod, as iconart.frag).
3. **Held switch in Settings** (Desktop & Dock, light and dark). The strip's last frame, measured in the lens's straight
   part (x 104..116 of the frame, not its round end): track 48 px outside, 36 px inside a 65 px lens = 0.75 x; the
   decoded field (Verify B 5) predicts 18.0 pt of 24 = 0.75 x, and at the right end the track end (7.25 pt inside the
   rim) shows at 9.75 pt (decoded 9.4). Ours: track 33 px outside, 25 px inside a 43 px lens = 0.76 x; lens / track
   1.30 (Mac 1.35). No geometry change. Rim: Mac 195 over 252 at the top (x0.77), 185 at the bottom, 150-165 at the
   ends; ours 170 over 246, 150-164, 157-191: not changed (the dark specular bias -0.3 of the dump cannot reach the
   Mac's ends alone; the switch's spread is not decoded).
4. **Fringes**, measurable on the same strip frame: the rim pixel stays neutral (195 195 195); just inside it cyan at
   the top (209 215 222) and the right end (208 240 236), yellow at the bottom (251 254 222, 214 217 185), 1-2 px. Built
   from the decode (glassForeground 1.632 pt at -15 deg, 7 taps, R / B centred at +-0.78) on the rim line only, each
   channel's line read over the 7 taps with triangle weights (assumed) and never lighter than the line itself; the
   direction (R's image moves down and left) read from the strip. Ours light: top inside 236 233 241, 224 243 255; bottom
   245 242 217, 254 242 223; right end 172 207 218. Stronger and 1 px wider than the Mac at the top (R - B -31 vs -13),
   about equal at the bottom (B - R -28 vs -29). Switch only (`Tokens.control.knobLensAberration`; the slider's is 0).
5. **Segmented control**: macOS has no lens. `controls-press-light.json` "press seg 1, drag to seg 3" shows only the
   black a.098 layer moving with the pointer and the selection jumping on release (no LiftLayer / SDFLayer); HyprK
   SegmentedControl does the same. The iOS 1.16 x label does not apply. **CC slider** (Sound, held on the knob, dark):
   the white fill read 187 inside the lens against the Mac's 222 (`panels/cc-sound-slider-...-dark-grey127.png`
   frame 3, rows 356-362): `Theme.cc.lensGain` .86 in dark (fitted to that frame), passed through Slider / Knob
   `lensGain`; after: 223. Light CC: no Mac frame, unchanged. Rim (Mac 41-60 over 106) and top light (+38) were close.

Not verified: the dark preview face (ours 167-170 at the end, Mac 150: the face gain, not refraction); a light CC held
knob; the switch fringes in dark against a Mac (no dark strip); the 7-tap weights.

## 7. Round 3 (2026-11-14): held switch filter, glassForeground decode, preview face

Measured in a headless hyprk session (scale 2, scratch HOME), with the judge's crops and rows (`JUDGE-95-16.md`): the held
switch is Desktop & Dock > "Animate opening applications" held 1 s (`grim -g "930,445 70x36"`, cursor hidden), against
`screens/27.2.1/controls/switch-press-strip-light.png` (last frame); the preview is `grim -g "715,238 265x50"` against
`settings/appearance/liquidglass-0-mid-1-{light,dark}.png` (middle panel; the Mac crop sits 8 px right and 15 px down).

1. **Held switch interior.** Cause: the switch took the slider's light terms (the B2 fit of `slider-knob-held.json`:
   face black 0.1 = haze .1, ring shadow 0.4). The switch's own dump (`live/verify/B/dumps/switch-knob-held.json`) has
   face black 0 (identity face) and ring shadow 0.1. `Tokens.control.switchLens*`, passed by `Switch.qml` through new
   `Knob` properties (the slider keeps the old ones).
2. **Fringes.** Cause: the aberration was a fixed offset 15 deg off vertical, read on the rim line only. Decoded from
   QuartzCore's `glass_foreground_base` (`~/Downloads/macos/re-work/air-qc/ann/glass_foreground_lpf.ll`): the offset is
   amount x the displacement matrix rows rotated by the angle with the rows SWAPPED, applied to the rim normal (x W/H at
   the ends, x H/W at top and bottom, as MAC-ANSWERS Verify B2 measured for Spotlight); R taps at +v, +2/3 v, +1/3 v
   (weights 1, 2/3, 1/3: the "+0.78" centre), G round 0, B mirrored; the whole glass layer is re-read, faded out
   6.2 pt inside (inputEdgeStart). At the top and bottom the offset runs 2.5 pt along the edge and 0.26 pt across, so
   the fringes sit where the rim turns: yellow upper left / lower right, cyan upper right / lower left, as in the strip
   (sign of the normal's y taken from the strip; the decode is in the layer's y-up space). A tap beyond the glass reads
   what lies under it: black there (the decoded sum of an empty tap) drew R - B -130 against the strip's -31.
3. **Rim and shadow.** The switch's KeyFillHighlight (height 1, offset -1, bias -0.3, spread SDR 120 deg) is the
   Verify B 1 dark specular, 1 pt wide: replaces the flat black .4 line of 0.5 pt (the lens is then 1.36 x the track's
   height, Mac 1.35). Lens shadow: the filter's shadow opacity is 0.001, so no lens shadow in light; the strip's soft
   shadow (-14 at 3.5-7 pt) is the knob's large rest shadow kept whole (`Knob.restShadowHeld`).
4. **Preview face (light and dark).** Cause: a fitted gain (light 1.14 + white .22, dark 0.79) instead of the decoded
   Regular face (verify C / C2: light 0.4 / 1.03 / sat 1.2 / maxLumaSDR 0.94 + white 0.2..0.5, dark 0.125 / 1.125 / 1.3 /
   0.6): the light gain clipped the bright sky to white (251) and stretched its contrast (the ripples). With the decoded
   face the dark face still read 20 too light until the blur fill also sees the Settings card around the article
   (`LensGlass.fillBackdropOutside`; the sharp samples keep the edge repeat, which the rims need: with the card in the
   outer sample too the dark top rim read 132). The dark round end's ramp (Mac 105 127 145 151) is not explained.

| item | Mac | before | after |
|---|---|---|---|
| switch: track inside / outside (RGB) | (10,94,207) / (10,95,210) | (29,120,218) / (11,124,248) | (9,119,241) / (11,123,246) |
| switch: B std inside | 4.8 | 14.7 | 4.2 |
| switch: top columns cyan over >= 1 pt | 22 of 92 (24 %) | 58 of 68 (85 %) | 15 of 62 (24 %) |
| switch: fringe R - B | -16..-31 | -31..-43 | -22..-38 |
| switch: rim pixel top / bottom | 196 / 193 | 170 / 163 | 219 / 218 (2 px: 219 210) |
| switch: shadow under the lens | -14 (252 -> 238) | -30 | -13 |
| preview light: top rim (60 / 70 px from the end) | 211 / 210 | 189 / 195 | 191 / 197 |
| preview light: face 8 px under the top | 241 | 251 | 243 |
| preview light: round end | 139 | 138 | 148 |
| preview light: dips per row, correlation | 1.28 | 1.95, 0.85 | 1.18, 0.97 |
| preview dark: top rim / next | 173 / 175 | 171 / 173 | 170 / 166 |
| preview dark: face 8 px under the top | 164 | 182 | 163 |
| preview dark: round end, next 3 | 105 127 145 151 | 103 169 170 171 | 87 152 158 157 |
| preview dark: dips per row, correlation | 2.03 | 2.09, 0.70 | 1.95, 0.89 |
| held slider (dark) fill rows by column, B - R > 60 | 14 -> 20 20 16 16 | 12 -> 18 18 14 14 | 12 -> 18 18 14 14 |

The strip is 1 px per pt (2 x 2 blocks), so the switch's 0.26 pt fringe along the top and bottom middle (1 px at 2x,
R - B -27) cannot show there; the column count above needs 1 pt of depth. Not verified: the switch in dark (no Mac
strip; the dark terms are unchanged, the new aberration applies), the switch rim (+15..23 over the Mac: the
KeyFillHighlight amount 0.5 is not in the Verify B 1 law), the light preview top rim (-14..-20, unchanged) and both
round ends (light +9, dark -18: the face change moved the rim's input), the rest shadow's place (ours peaks at the rim,
the Mac's 3.5-7 pt below).

## 8. Round 4 (2026-11-14): the dark specular's amount, the light rim's input, the round ends

Same session recipe and crops as round 3.

1. **Switch rim (light; the strip is the light probe, `switch-press-strip-light.png`, and the dump is light).** Cause:
   the lobes used Schlick 0.4 for every glass. The decode (`glass_background_sdf_all_lpf.ll`, uniforms 51-56) takes
   the Schlick parameter from KeyFillHighlightAmount (the CPU passes 1 / amount - 2: MAC-ANSWERS Verify B 1,
   0x18debcd84): Regular 0.4, both knob filters 0.5, which makes the lobes linear (hl 0.67 at the top with spread 120,
   not 0.5). `glasslens4.frag` rimSpec.w, `LensGlass.rimAmount`, `Knob.lensRimAmount` 0.5. Opacity and blend: the
   decoded line is the same tone curve over the faced colour, with no separate opacity.
2. **Light preview top rim.** Cause: the light rim toned the plain sample; the decoded order (verify C2) tones the
   faced colour (round 2 kept the plain sample because the then-fitted face made the end 160). With the decoded face
   (round 3) the face first is used in both modes (`Tokens.control.regularRimFace` true; rimSpec.z 2 uses `face*`).
3. **Dark round end.** Not fixed. Tried: the rim reading the sample before the blur fill (dark end 96, light end 151,
   top 178), the outer sample through the blur fill (light top 209 but dark top 149, end 75), the full outer mix on
   the line (no change). The Mac's 2D end (rows 14-86 of the crop) shows the rim's effect reaching about 1.5 pt
   inward at both ends: dark 105 127 145 then the face 151, light the line then one pixel BRIGHTER than the face
   (235-244 over 232). An outer mix that sees the card would do both, but the top rim (dark 173, brighter than the
   face) says the outer sample there sees the sky. Needs: the Mac preview over a flat backdrop, or the Regular
   recipe's KeyFillHighlightEffectOffset / Height in light.

| item | Mac | round 3 | round 4 |
|---|---|---|---|
| switch rim, 2 px at the top (outer / inner) | 196 / 195 | 219 / 210 | 208 / 197 |
| switch rim, bottom | 193 | 218 | 208 / 197 |
| switch: track in / out, B std, fringe columns, shadow | see round 3 | (9,119,241) / (11,123,246), 4.2, 24 %, -13 | (9,119,241) / (11,123,246), 4.3, unchanged, -13 |
| preview light: top rim (60 / 70 px from the end) | 211 / 210 | 191 / 197 | 214 / 217 |
| preview light: face 8 px under the top, ripples | 241, 1.28 | 243, 1.18 (0.97) | 243, 1.20 (0.94) |
| preview light: round end | 139 | 148 | 170 |
| preview dark: top rim, face 8 px under the top | 173, 164 | 170, 163 | 169, 162 |
| preview dark: round end, next 3 | 105 127 145 151 | 87 152 158 157 | 86 157 157 156 |
| held slider fill rows (dark, B - R > 60) | 14 -> 20 20 16 16 | 12 -> 18 18 14 14 | 12 -> 18 18 14 14 |

Not verified: the light round end's regression (148 -> 170) has the same unknown as the dark end (item 3).
