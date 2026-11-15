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

## 9. Control Center Sound slider held, on the stub sink (2026-11-14)

The CC sliders drove the machine's PipeWire volume, so judge #16 left 1h unmeasured. `HYPRK_AUDIO_STUB=1` (or
`HYPRK_STATUS_STUB=1`) now gives the shell a made-up sink (`services/Audio.qml`, `scripts/volume-key.sh`, shell
FALLBACKS.md). Headless session at scale 2, wallpaper a flat grey 127 (as the Mac picture), the knob held 0.8 s at the
fill end (1100, 468 pt) with vptr, full-output grim; against `panels/cc-sound-slider-rest-hover-drag-overdrag-dark-
grey127.png` frame 3 (crop x 110..220, y 320..400 of the picture; ours x 2150..2260, y 890..970).

| item | Mac (dark) | ours before | ours after |
|---|---|---|---|
| fill inside the lens, mean of the fill rows from the left rim to the fill end | **224.1** (core rows 223.5; peaks 254 at the rim to 221 at the end) | **222.6** (223.0) | 222.9 |
| fill outside / track right of the lens / module | 254 / 127 / 106 | 254 / 129 / 109 | same |
| rim line centres, width x height (the lens's middle row / column) | 44 x 38 px (x 26..70, y 21..59) | 48 x 42 px | 44-46 x 38 px |
| outer rim box (pixels under 75) | 47 x 40 | 50 x 44 | 46 x 40 |
| fill rows inside / outside (> 170) | 8 / 8 | 8 / 8 | 8 / 8 |
| shadow under the lens (middle column) | 99 98 95 93 91 88 86 85 85 85 then back to 106 by 20 px | 87 flat for 10 px | 87 flat for 10 px |
| module width while held | 588.5 px (583 at rest and hover: +2.75 pt, frames 3 and 4) | 583 (no lift) | about 588 (+2.25 pt, the glass press lift) |

1. **Fill inside the lens: confirmed**, 222.9 against the Mac's 224 (round 2's 223 vs 222 used rows 356-362 only).
2. **Lens 2 pt too large.** Cause: `Theme.cc.lensW / lensH` 24 x 20 was the Mac's outer size (Q-panels-08 "about
   24 x 20") but Knob draws its dark 1 pt line outside the face, so ours was 26 x 22 outside. Now the face is 22 x 18
   (the Mac's rim centres 21.8 x 18.8 pt at the held module's 1.009 scale), `shell/Theme.qml` cc.lensW / lensH.
3. **Module lift.** The Mac's module grows 2.75 pt wide while the knob is held (frames 3, 4; title and AirPlay button
   move out with it); ours did not move (`interactive: false`). Now the slider module is `pressed` while its slider is
   held (`ControlCenter.qml` SliderModule), the existing GlassButton press lift (+2.25 pt for 292 x 64, motion.js); no
   timing changed.
4. Not changed: the shadow's shape (ours flat right under the rim, the Mac's ramps to its darkest 4-5 pt below; depth
   the same, -21 vs -22); the lens outline's corner shape (the Mac's rim is 42 px wide 8 px above the middle against
   44 at the middle, ours 42 / 46: a slightly squarer end on the Mac, 1-2 px, inside the antialiasing).

**Light: no Mac reference** (no light frame of a held CC knob exists). Ours, same place: fill inside the lens 197.5,
outside 228.4 (the press overlay darkens the light fill while held), track 129, rim 65, shadow 97.

## 10. Round 5 (2026-11-14): the rim line is outside the glass; the preview's round ends; the switch's rim

Same session recipe and crops as round 3 (preview `grim -g "715,238 265x50"` against the middle panel of
`liquidglass-0-mid-1-{light,dark}.png`, crop rows 15..115, columns 588..1118; switch: "Animate opening applications"
held 1 s, `grim -g "930,445 70x36"`).

1. **Preview rim: the decoded stroke mode.** Cause of both round-end regressions: the rim line was drawn inside the glass
   over the glass's own (refracted, faced) colour. The decode (`QuartzCore-glass-shaders.c` step 4) draws the dark
   specular in stroke mode when KeyFillHighlightEffectOffset = -Height (Regular: 0.5 / -0.5, `live/glass-*.json`):
   mask (1 - coverage) x AA, the pixel just OUTSIDE the shape, which shows the backdrop there. The Mac shot agrees: the
   shape spans x 598..743, y 28..99 of the full picture (73 x 36 pt), the line pixels are x 597 / 744, y 27 / 100; the
   light top line is 211 over a sky of 231 (tone curve, hl 0.31 at 106 deg: 210) and the dark top line pixel is 232 =
   the sky (no lobe at the top at 75 deg; ours drew the face there, 169). Built as `rimSpec.z` 3 (`LensGlass.rimStroke`,
   `Tokens.control.regularRimStroke`): the item's outer outlineWidth is that line, the glass (refraction, outer mix,
   face) is the item inset by it, the line tones the plain backdrop under the pixel.
2. **The round ends' inner ramp is the outer sample seeing the Settings card.** The 2 px inside the line read dark
   127 145 then the face 151, light 238 236 then 234: the outer refraction (16 pt out, opacity 0.6 over the outermost
   1 pt) lands 8.5 pt beyond the article, on the card (43 dark / 247 light); the model gives 119 141 / 240 237. At the
   right end of the same capsule the outer sample lands on the photo and the Mac shows no ramp (164 164 165 then the
   line). With stroke mode and `fillBackdropOutside` the outer sample now reads `backdrop` beyond the source too.
3. **Dark top: the key / fill highlight is on in both modes** (`regularFillLight` 1; was 0 in dark since round 2). The
   Mac's dark top (174 175 168 166 over the face 164) is the highlight (+36 in the model) less the card in the outer
   sample (-30): the model gives 170 175 171 169.
4. **Not explained: the dark round-end line.** Tone over the plain backdrop gives 136 in both modes; light reads 139,
   dark 105. Same backdrop (206 left of the end in both shots), same bias (0.25 in every dump), lobe 1 at the end in
   both spreads. Over the dark face of the backdrop it gives 102, so in dark the face is mixed in by the lobe
   (`rimSpec.z` 4 via `regularRimFace: t.dark`): **fitted, not in the decode**, the round-2 per-mode choice in a form
   that keeps the top line pixel at the plain 232. The light right end reads 123 (Mac 129), the dark right end 99 (110).
5. **Held switch.** Cause of the yellow outer rim pixel (209, R - B +26): the foreground's re-read was drawn over the
   rim line, but the line is a stroke outside the glass shape (the switch's KeyFillHighlight height 1, offset -1) and
   the decoded foreground output is multiplied by the shape's coverage: the overlay now leaves the line (`fa` x
   (1 - line)); the switch uses stroke mode too (`Switch.qml` lensRimStroke). Tried and dropped: leaving the line out of
   the re-read as well (the middle line goes, R - B -12, but the round-end fringes fall to 5 % of the top columns) and
   the dump's edge opacities read literally (inputEdgeOpacityStart 1 at EdgeStart -6.2, End 0 at the rim: fringes 5 %).
   **The 1 px cyan line under the middle of the top rim stays** (R - B -30, was -35): it is the decoded offset's
   0.26 pt vertical part re-reading the 1 pt line; at 1 px per pt it averages to about -15, the Mac strip reads 0 there.
   The outer rim pixel (205) is lighter than the inner (194) because the lens edge falls inside a pixel (the lift's
   1.56 x height is not a whole pixel); not changed.

| item | Mac | round 4 (judge #17) | round 5 |
|---|---|---|---|
| preview light: top line (col 69 / 79) | 211 / 211 | 215 / 217 | **211 / 210** |
| preview light: face 8 px under the top | 241 | 243 | 243 |
| preview light: round end, next 2 | 139 238 236 | 171 237 237 | **136** 244 240 |
| preview light: right end line | 129 | 162 | 123 |
| preview dark: line pixel at the top / first inner (col 69) | 232 / 174 | 169 / 167 | **232 / 172** |
| preview dark: face 8 px under the top | 164 | 162-163 | 163 |
| preview dark: round end, next 3 | 105 127 145 151 | 86 158 158 157 | **102** 128 149 158 |
| preview dark: right end line | 110 | 98 | 99 |
| preview ripples, dips / row (corr) light, dark | 1.28, 2.03 | 1.20 (0.94), 1.97 (0.89) | 1.15 (0.99), 2.14 (0.92) |
| switch: top rim outer / inner (col 78) | 196 / 195 | 209 (R - B +26) / 197 | 205 (R - B 0) / 194 |
| switch: cyan line under the top middle (R - B) | 0 (1 px per pt) | -35 | -30 |
| switch: top columns cyan over >= 2 px | 25-35 % | 39 % | 33 % |
| switch: track inside, B std; shadow under the lens | (11,92,203), 4.2; -14 | (0,115,241), 3.2; -14 | (0,115,241), 3.1; -14 |

Not verified: the dark round-end line (item 4); a dark held switch against a Mac (none exists; ours unchanged in dark,
the stroke needs a dark specular, which the dark switch does not use).

## 11. Round 6 (2026-11-14): the switch's foreground as decoded; the Control Center held lens

Same session recipe as round 5; the Control Center as in section 9 (grey 127 wallpaper, dark, Sound knob held 0.8 s at
(1100, 468) pt on the stub sink, crop x 2150..2260, y 890..970 against frame 3 of `panels/cc-sound-slider-rest-hover-
drag-overdrag-dark-grey127.png`, x 110..220, y 320..400).

1. **Held switch: the cyan line under the middle of the top rim.** The Mac's last strip frame (x 1388..1518 of
   `switch-press-strip-light.png`) is at 2 px a line pixel, its chroma in 2 x 2 blocks: the line 196 / 195, then 251
   with R - B 0..1 along the whole middle; the cyan sits 2-5 px under the rim from about a fifth of the width from the
   ends (R - B -16..-31). Cause: rounds 3-5 drew the foreground at full strength at the rim and over taps that re-read the
   rim line. Now as decoded (`QuartzCore-glass-shaders.c` glass_foreground): the re-read layer is the glass without the
   line (the dark specular is a stroke in the backdrop filter's output, outside the shape, not in the content), an empty
   tap is black in the sum, the result is (R / 2, G / 3, B / 2) premultiplied with alpha = the taps' mean, times the
   dump's edge opacity (`switch-knob-held.json`: EdgeOpacityStart 1 at EdgeStart -6.2, EdgeOpacityEnd 0 at EdgeEnd 0:
   0 at the edge, 1 from 6.2 pt in; round 3 had it reversed). Measured from the item's edge (the knob layer with its
   1 pt line); from the glass shape's edge the ends' fringes covered only 3 % of the top columns (R - B -12..-20).
   `glasslens4.frag` lensImg and the aberration block.
2. **Switch outer rim pixel** (205 against 196): not changed. The lens is 13 x 1.5625 = 20.3 pt tall, so its edge falls
   0.28 px into a pixel and the outer line pixel is 78 % line, 22 % card (205); the full pixel reads 194. The Mac strip
   was captured at about 2.9 px per pt, so its line covers whole pixels; not a colour difference.
3. **Control Center held lens: fill ramp.** Cause: the dark lens used the fitted recording model (gain .86, haze, key
   bands, no ring shadow), which draws the fill flat. The frame's ramp is the decoded held-slider-knob stack (MAC-ANSWERS
   Verify B2 item 1, measured in dark; used in light only until now): face 0.1 + 0.9 c, ring shadow 0.4 (shape 8 pt
   down, stroke 4, blur 3: darkest across the middle rows away from the round ends), key / fill highlight. `Knob
   lensDecoded`, passed by `Slider` / `ControlCenterSlider` from `Theme.cc.lensDecoded` (both modes; light has no frame).
4. **Its shadow.** The decoded composite is mix(shadow, col, coverage) x (1 - ring) + ring over every pixel of the
   layer, so the ring term darkens what lies below the lens too: an inner 4 pt stroke of the shape moved 8 pt down is a
   band 4-8 pt under the bottom rim, 0.4 x 0.495 = x0.80 at its middle (106 -> 85). New `shaders/ringshadow.frag`
   under the lens, instead of the shape-8-pt-down shadow (which is darkest right under the rim).

| item | Mac | before | after |
|---|---|---|---|
| switch: R - B under the middle of the top rim | 0..1 | -30 (1 px) | -2 |
| switch: top columns cyan over >= 2 px; R - B there | 25-35 %; -16..-31 | 33 %; to -97 | 28 %; -20..-38 |
| switch: track inside B std, shadow under the lens | 4.2, -14 | 3.1, -14 | 2.6, -14 |
| switch: rim line outer / inner pixel | 196 / 195 | 205 / 194 | 205 / 194 |
| CC: fill inside the lens, first / last column to the fill end | 232 / 190 | 218 / 209 | 233 / 197 |
| CC: centre row over the fill, every 3 px | 245 233 222 217 213 212 213 | 223 flat | 239 232 223 216 211 209 208 |
| CC: centre row over the track, every 3 px | 113 112 113 113 115 120 126 | 137 flat | 116 116 117 119 120 125 132 |
| CC: fill mean (rows > 170, left rim to fill end) | 221.9 | 221.5 | 214.4 |
| CC: shadow under the lens, every 2 px from the rim | 98 93 88 85 85 86 90 94 | 87 87 87 88 88 89 95 | 98 95 91 88 87 88 92 |

Not settled: the CC fill's mean is 7.5 under the Mac's (the shape matches; the CC knob's own filter is not dumped,
the stack is the Settings slider's); the plateau of the shadow is 2-3 lighter than the Mac's.

**Round 6, follow-up (judge #18: CC fill mean 212.7 against 224.0).** The term that darkens the middle is the ring
shadow inside the lens: with its opacity set to 0 for a test the fill reads 251 flat (mean 250.9), with 0.4 214.4
(this capture; the face 0.1 + 0.9 c and the key / fill highlight move white by under 1 level). Its opacity is fixed by
the shadow outside (106 -> 85 = x0.80 = 0.4 x 0.495), so the level comes from where the fill sits in the band: in
frame 3 the fill rows are 15-22 of the 40 px rim box, ours 16-23, one pixel deeper into the band (the Mac's lens sits
0.5 pt below the track's centre). `Theme.cc.lensDy` 0.5 (`Slider` lensDy, scaled by the lift).

| item (`cc.py`, this session) | Mac | round 6 | follow-up |
|---|---|---|---|
| fill mean, rows > 170 inside the box | 221.9 | 214.4 | **217.9** |
| fill per column, first 6 | 232 240 236 233 236 232 | 233 230 227 224 221 219 | 229 236 233 230 228 225 |
| fill rows in the rim box | 15-22 | 16-23 | 15-22 |
| fill column 4 px in, top to bottom | 254 252 248 243 241 235 233 229 | 237 236 233 229 225 222 218 215 | 244 241 238 235 232 228 225 222 |
| shadow every 2 px under the rim | 98 93 88 85 85 86 | 98 95 91 88 87 88 | 98 95 91 88 88 88 |
| fill left of the lens | 254 | 251 | 252 |

Still open: the top fill rows are 8-11 under the Mac's while the bottom row matches (the Mac's band starts lower or is
softer at its top; the CC knob's filter is not dumped). Judge #18's per-column method reads the Mac 2-14 higher than
`cc.py` does; the ratio between the two captures is what moved.

## 12. Round 7 (2026-11-14): the new Mac captures (MAC-ANSWERS-2 G1.1-G1.3)

The new shots are at the default 1440 x 932 pt, 2x (round 1 was at the scaled 1710 x 1107): 2 px per pt, the same
scale as our headless session, so they compare pixel for pixel. They carry the built-in display's colour profile:
converted to sRGB the neutrals do not move, the blues do (the slider fill (46,106,217) -> (3,108,225), ours
(0,107,225)), so every colour below is the sRGB conversion. Session: headless hyprk, scale 2, scratch HOME; Settings >
Desktop & Dock, the Size knob held 1 s with vptr (`grim` 130 x 80 pt framed as the Mac crop), "Show suggested and
recent apps in Dock" held 1 s (240 x 160 pt, aligned on the unheld switch above it), the Control Center over a 4 pt
black / white stripe wallpaper (as the Mac) with Sound held at (1100, 468) and shot again right after release,
Appearance preview `grim` 268 x 50 pt from the photo's left edge. Side-by-sides (Mac left, ours right, 4x) in the
agent-g7 scratch dir: `v/zoom-{light,dark}-final.png`, `v/sbs-*-final-4x.png`, `v/swz-*-final.png`, `v/ccz-*-a2.png`.

1. **Held Settings slider: the decoded stack in both modes.** The slider's own dump (`live/verify/B/dumps/
   slider-knob-held.json`) has the switch's KeyFillHighlight: height 1, EffectOffset -1 (stroke mode), ColorBias -0.3,
   SpreadSDR 120 deg, Amount 0.5. Its tone curve gives the measured rim in both modes: top 194 over the card 247 (Mac
   195), 21 over 42 (Mac 20), the ends 0.37 / 0.2 of the backdrop (Mac 135 over the track 222, 10-15 over 42). The
   rim was a flat black .4 line of 0.5 pt (light) and .45 of 1 pt (dark). Face black 0.1 (0.1 + 0.9 c) shows only in
   dark (42 -> 63, Mac 58-73 with the light terms); the dark fitted recording model (gain .702, haze, key bands) is gone.
   Ring shadow: inside the lens the track drops 15 levels in both modes at the middle (dark 81 -> 66 = x0.81 =
   1 - 0.4 x 0.495, the dump's 0.4; light 225 -> 210 = x0.933) and the card under the lens the same ratios (42 -> 34,
   247 -> 229): one multiplier per mode, light **0.14, fitted** (not decoded; the dump's 0.4 drew 181 and 198 there).
   `Slider.qml:59-64` (lensDecoded true by default, lensRingOpacity, lensRimDecoded), `Knob.qml:53-56`,
   `Tokens.qml:228-241` (sliderLensRimBias / Spread / OutlineWidth, sliderLensRingOpacity). The lens size was right
   (rim centres 41 px tall, 51-52 wide in both; the outline of the round ends matches row by row within 1 px).
2. **Held switch, light and dark** (`switch-held-stripes-*.png`, the first dark reference). The dark lens took the
   slider's recording fit (the card 42 -> 74, the track (28,104,186) against the Mac's (48,131,244)); now the switch
   uses the decoded stack with its own dump in both modes (face black 0, ring 0.1, rim bias -0.3: `Switch.qml:86`,
   `Tokens.qml:215-227`). The ring shadow is drawn under the lens too (the Mac's 247 -> 234 band 4-5 pt below, ours was
   darkest right under the rim) and the rest shadows fade to 0.3. The held track gets the slider's press layer
   (`Switch.qml:73`; the Mac's held track is 246 -> 225 blue outside the lens, the unheld one above unchanged). The
   glassForeground edge opacity is reversed: 1 at the knob layer's edge, 0 from 2 pt in (`glasslens4.frag:370`,
   `Tokens.qml:205`): round 6's 0 at the edge / 1 from 6.2 pt in drew magenta / green bands across the track's end
   inside the lens, which the Mac shows clean, its fringes only in the outer 2-2.5 pt. **Fitted**: the 2 pt.
3. **Control Center Sound, light** (`slider-held-cc-light.png`, `slider-released-cc-light.png`). The same dark specular
   rim (Mac 83 / 63 at the top over the module 116: tone curve 67; ends 43-51). The lens cannot sample the module glass
   (empty source), where only white haze and a black .4 line were drawn: new `LensGlass.emptyLevel` draws the ring
   shadow (black of its own alpha), the key / fill highlight (white of alpha t (0.1471 - 0.0882 c0) / (1 - c0)) and the
   rim (black of alpha -bias hl (3 - 2 c0)) for a backdrop of the module's level c0 (`glasslens4.frag:169, 247, 275,
   282`; `ringshadow.frag:37` no longer darkens inside the capsule; `Theme.qml:698-705` cc.lensEmptyLevel .43 / .42,
   lensRimDecoded). No press layer on the light CC fill (Mac 255 outside the lens while held and after release; ours
   was 229). The released frame is the held lens at full lift in both (the shot is right after mouse-up).
4. **Appearance preview** (`liquidglass-flat-grey-*`): not changed. The photo starts 7.5 pt left of the share capsule
   (crop x 0 = window x 884, the card 247 / 42 beyond it), so the outer sample (16 pt out) still lands on the card: the
   round-5 explanation of the ramp holds. Tried the outer mix as a 2 pt quarter circle instead of the outermost 1 pt:
   the dark first pixel went 126 -> 138 (Mac 125), dropped.

| item | Mac | before | after |
|---|---|---|---|
| slider light: top / bottom rim | 194 / 186 | 163 / 166 | 194 / 194 |
| slider light: card just above the track, track middle, card just below (in the lens) | 238, 210, 234 | 220, 181, 220 | 240, 210, 237 |
| slider light: shadow every 2 px under the rim | 238 235 233 229 229 229 229 233 | 220 x5 224 233 240 | 235 234 232 229 227 229 229 233 |
| slider light: fill inside (mean luma; RGB 2 pt in) | 103.0; (31,119,231) | 87.6; (22,107,201) | 99.4; (25,118,221) |
| slider light: mean abs luma difference, lens box | | 15.8 | 6.7 |
| slider dark: top / bottom rim | 20 / 18 | 21 / 21 | 17 / 17 |
| slider dark: card in the lens every 2 px from 2.5 pt under the top | 68 65 63 60 58 | 58 55 53 52 51 | 64 62 59 57 54 |
| slider dark: fill 1.5 pt inside the left rim, top to bottom | 138 136 133 ... 117 | 104 ... 102 (flat) | 131 130 128 ... 114 |
| slider dark: fill inside (mean luma) | 116.7 | 100.3 | 112.1 |
| slider dark: shadow under the rim (card 42; ours 38) | 38 37 36 34 34 34 | 30 31 31 31 31 31 | 34 34 33 31 31 31 |
| slider dark: mean abs luma difference, lens box | | 10.6 | 8.5 |
| switch light: track in the lens; card in the lens | (5,103,213); 249 | (0,113,237); 251 | (0,102,214); 250 |
| switch light: shadow under the lens every 2 px | 243 240 238 235 234 234 | 233 234 235 237 237 238 | 238 238 234 234 233 233 |
| switch light: fringe pixels, mean chroma | 167, 29.3 | 241, 34.7 (across the track's end) | 144, 33.5 |
| switch dark: track in the lens; card in the lens | (48,131,244); 52 | (28,104,186); 74 | (29,131,242); 52 |
| switch dark: top rim 2 px, then the inner highlight | 20 20, 92 72 51 | 25 21, 57 74 66 | 22 17, 90 72 49 |
| switch dark: fringe pixels, mean chroma | 112, 19.8 | 159, 24.9 | 126, 20.9 |
| switch: mean abs luma difference, lens box (light / dark) | | 9.5 / 15.4 | 6.0 / 6.9 |
| CC light: top rim 2 px, inner highlight | 83 63, 120 152 134 | 109 80, 105 121 121 | 77 62, 131 148 130 |
| CC light: bottom highlight, rim | 140 136, 58 63 | 113 113, 63 98 | 134 146, 58 58 |
| CC light: fill inside the lens (mean > 170); fill outside | 218.1; 255 | 200.6; 229 | 219.6; 255 |
| CC light: module under the lens 2-8 pt | 100 98 98 94 94 90 90 89 87 | 98 97 96 94 93 90 90 89 87 | same |
| CC dark (grey 127, judge #19 method): fill mean, shadow | 224.0; 99 98 95 93 91 88 | 217.6; 98 95 91 88 88 | 216.9; 98 97 95 94 91 90 |
| CC dark: rim where it crosses the fill (outer / line pixel) | 227 / 170 | 173 / 140 | 187 / 179 |
| preview light: round-end line, next 3, face | 133, 234 233 231, 230 | 130, 242 238 235, 235 | unchanged |
| preview dark: round-end line, next 3, face from 3 to 10 pt | 102, 125 142 148, 149 -> 157 | 97, 126 147 156, 152 -> 156 | unchanged |

Still different (visible at 4x):
- the Settings dark card is #25262B (luma 38, bluish) against the Mac's neutral 42 under a grey desktop: the dark lens
  face reads 3-4 lower everywhere and the rim line keeps the card's blue (B - R 3-5); the dark accent fills are greener
  on the Mac ((51,138,255) against (30,138,255)); neither is a lens term.
- the Mac's lens sits half a pixel off the grid (its 1 pt rim covers 3 rows half / full / half), ours on it.
- held switch: the shrunk track inside the lens is about 1 px taller than the Mac's; the fringes 15 % stronger per
  pixel in light.
- CC light: over the module glass the lens reads 111-121 where the Mac reads 121-127 (and the track 111 vs 120): the
  empty-source layers are an approximation of the module the lens cannot sample; the ring 0.4 is kept because the fill
  (218) and the shadow under the lens fit it (0.14 drew 240 and 103 -> 100). The CC rim's outer pixel over the fill is
  40 darker than the Mac's.
- preview: the dark ramp settles 1 px late (147 156 against 142 148) and the light face is 5 levels bright.
- **fitted, not decoded**: the light ring opacity 0.14 (Settings slider), the foreground edge length 2 pt, the CC empty
  levels .43 / .42 (read off the module beside the lens).

## 13. Round 8 (2026-11-14): the held switch frame by frame (MAC-ANSWERS-3 R3.6)

Mac: `switch-held-stripes-{dark,light}.mov` (400 x 200 px at 2x, 60 fps VFR: every frame of a change is present, times
from the pts; `switch-press-strip-dark.png` is every 2nd frame of the dark clip). Press at 0.900 s (dark) / 0.883 s
(light, the cursor appears), release at 2.000 s; on release the switch turns off (knob travels left, track fades to
grey). Ours: the same switch ("Show suggested and recent apps in Dock") with mcap (`-k 1`, every presented frame, times
from the vptr press), press at t0, release at +1.1 s. Measured per 16.7 ms frame with the two series
aligned on their first changed frame (the Mac's input latency is not in the clip). The Mac's cursor covers the knob's
lower right, so every metric reads the upper half. Strips (Mac row over ours): agent-g7 `v/press-dl.png`,
`v/rel-dark-ab.png`, `v/growz.png`.

| press, dark (from the first change, every 16.7 ms) | Mac | ours (after the change below) |
|---|---|---|
| knob colour at its centre (R of the white fill fading to the track) | 239 224 197 170 137 111 84 67 51 45 44 | 241 224 199 169 138 106 78 57 41 32 29 |
| lens width 2 px above the track (px), from the frame it clears the track | 29 39 44 48 52 52 54 | 26 36 42 46 50 52 52 |
| darkest rim pixel | 30 31 28 22 19 16 15 11 9 6 6 | 37 37 31 27 23 18 14 11 9 7 7 |
| first change to still | 200 ms (0.950-1.150 s) | 183 ms |
| light: knob colour at its centre | 238 223 197 165 134 98 69 45 26 11 3 | 241 223 197 163 129 92 59 34 15 4 0 |
| light: darkest rim pixel | 78 78 73 66 59 51 45 40 36 32 33 | 95 90 83 76 68 59 51 45 41 39 38 |

| release, dark (both from their first changed frame) | Mac | ours (after) |
|---|---|---|
| knob travel per frame (px, centre of the lens above the track) | 2 2.5 2 3 2.5 | 0.5 1.5 2 2.5 2.5 |
| lens height above the track (px) | 6 5 5 4 3 2 0 | 6 6 5 5 4 3 2 0 |
| knob fill returning (luma of a fixed patch) | 124 135 146 157 168 181 193 205 217 228 236 244 251 | 119 127 138 159 174 185 194 203 213 222 231 239 246 |
| first change to still | 250-270 ms (2.083-2.35 s) | 267 ms |
| light: the same patch | 99 116 137 161 182 201 218 229 238 244 249 251 | 91 102 117 140 166 188 208 224 234 242 248 250 |

The size, the white fading at the knob's centre and the rim darkening match within a frame in both modes (the 0.20 s
easeInEaseOut growth). **One structural difference, fixed:** on the Mac the knob's white fill is the glass's own
content, refracted with the track: from the first growth frames the white sits about 4 pt inside the lens's ends (the
rim region samples the track outside it), a shelf at the track's level between the rim and the white. Ours drew the
white over the lens, unrefracted, edge to edge, with the lens cross-fading in under it. Now `Knob.lensFillInside`
(Switch): the white is a layer of the glass shape under the glass (`LensGlass.glassFill`, composited into every tap in
`glasslens4.frag` tap()), the lens is opaque from the first frame and its terms (refraction, light, ring shadow, rim
tone, aberration) grow with the lift (`LensGlass.strength`, uniform fxs). Fully held it is the same picture as before
(round-7 numbers unchanged: lens box mean difference 6.0 / 6.9).

| press, 5 frames in, dark: row 4 px above the knob's centre from the lens's left edge (every 2 px) | |
|---|---|
| Mac | 74, 124 137 143 143 143 159 168 175 177 |
| ours before (white over the lens) | 88, 143 184 182 182 182 |
| ours after (white under the glass) | 84, 122 122 114 170 183 183 |
| the lens top over the card at the knob's centre, 6-8 frames in (dark / light) | Mac 53 66 69 / 207 226 252; before 87 112 84 / 235 253 252; after 52 69 57 / 236 255 253 |

Release: with the two series aligned on their first changed frame ours starts about a frame later (travel per frame
0.5 1.5 2 2.5 2.5 against 2 2.5 2 3 2.5); one frame later, ours matches: knob travel -2 -4 -6.5 -9 -11.5 px against
-2 -4.5 -6.5 -9.5 -12, the lens's height above the track 5 5 4 3 2 0 against 5 5 4 3 2 0, the returning fill (light)
102 117 140 166 188 208 224 against 99 116 137 161 182 201 218 (dark up to 17 lighter in the middle, the same end). The
clip has no frame between the release (2.000 s) and the first change (2.083 s), so the one-frame offset is within the
clip's own uncertainty: the decoded spring (response 0.47, damping 0.7) is kept for the travel and the shrink.

Still different: the Mac's white edge inside the lens is soft (the shelf rises over 3-4 px, ours in 1-2); in light the
top highlight comes in brighter than the Mac's in the middle of the growth (255 against 226, the line above); the dark
rim pixel is 5-13 lighter than the Mac's in the first half of the growth in light (91 against 78 at the first frame:
our track's edge is lighter).

## 14. Round 9 (2026-11-14): plugin recipe (the alert's side rim, low-opacity glass)

Headless session at scale 2 over a flat grey 127 wallpaper (dark and light), the plugin built from the working tree in
an agent scratch dir and swapped in and out of the same session (`hyprctl plugin unload / load`, a copy under a new file
name each time: a second load of the same path returns the old handle), so before and after are the same shell state.
`hyprctl liquidglass trace <ns> <file>` for the boxes and the opacity of every draw; grim stills; mcap (`-k 1`) for the
HUD. Mac: `screens/27.2.1/windows/alert-shown-grey-{dark,light}.png`, `verify/B/menu-probe-popup-over-grey-dark.png`,
`panels/spotlight-modelist-{grey,white}-dark.png`.

1. **Alert and menus: every resting glass with an even marker level count sat 1/30 pt off.** The trace showed the alert at
   `box 510.033,158.033 260x234`. The shell's sub-point edge markers (`Glass.qml` placeHole) code each edge's offset
   d in n = floor(sqrt(w - 3)) levels as round((d + 0.5)(n - 1)); for an even n there is no code for d = 0, the shell
   rounds 0 to n / 2 and the plugin read that as +0.5 / (n - 1): +1/30 pt on all four edges of the 260 pt alert (n 16),
   1/26 pt for the 202-215 pt menus (n 14). Every glass 259-291, 199-227, 147-171, 103-123, 67-83 ... pt wide was moved
   right and down at rest. A shape 0.067 px right of the pixel grid weakens the 1 px dark specular line on the left and
   the top (line 0.93) and spills it into the next pixel on the right and the bottom (the 110 beside the line) and the
   glass's own bottom row into the pixel under it (109 instead of 105). Fix in the decoder (`plugin/src/Shape.cpp`
   `fractionEdge`): for an even n codes n / 2 - 1 and n / 2 read 0 and the others step by 1 / (n - 2) to -+0.5, so a
   resting glass is on whole points and every code still reads inside the shell's rounding bin (ctest checks both for
   n 3..17). The shell is unchanged, so a new plugin works with the running shell and the old one.
   **The light top and bottom lines: two lobes, summed.** After the shift the light alert's top / bottom line read 110 /
   99 over 120 / 108, the Mac's 100 / 90. The decode (`decomp/QuartzCore-glass-shaders.c` step 4) takes two opposite
   lobes, v = saturate((+-c0 - cos spread) / (1 - cos spread)), each through the Schlick curve, and adds them (hl = v.x +
   v.y); the shader took one lobe of |n.x|. With the light Regular spread of 106 deg both lobes reach the top and the
   bottom (0.155 each, 0.31 together; the tone then gives 101 / 90). Under 90 deg (dark Regular 75, Dock, Clear, Control
   Center, Spotlight) only one lobe is ever on, so dark and those recipes are unchanged. Checked on a second surface: the
   Mac's light Notification Center card (`nc/stack-light-{grey,white}.png`) has its top line at 79 over 95 and 169 over
   190; two lobes give 78 / 168, one lobe gave 87 / 177. Fix: `shaders/liquidglass.frag` dark specular block.
   **Not fixed: the dark side line** (53 against 46-47 on the Mac, alert and menu alike). The decoded tone
   c (1 + bias hl (3 - 2 c)) with the dumped bias -0.25 and hl 1 gives 52.6 over 112, and in light it gives the Mac's 54
   over 114 exactly; the Mac's dark line reads as bias -0.278 (or hl 1.11). No decoded term explains it (the shadow is
   composited before the tone in the decode, as here).

| alert over grey 127 (row 500 / column 1100 px) | Mac | before | after |
|---|---|---|---|
| dark left: outside, line, inside | 112, **46**, 112 | 112, **58**, 110 | 112, **53**, 113 |
| dark right: inside, line, outside | 112, **46**, 112 | 113, **58**, 110 | 113, **53**, 112 |
| dark top: outside, rim rows | 119, 156 138 | 119, 154 139 | 119, 155 138 |
| dark bottom: rim rows, outside | 137 155, **105** | 138 155, **109** | 139 156, **105** |
| light left: outside, line, inside | 114, **54**, **199** | 114, **60**, **190** | 114, **54**, **199** |
| light right: inside, line, outside | 199, **54**, 114 | 199, **64**, 111 | 199, **54**, 114 |
| light top: outside, line, rim rows | 120, **100**, **232** 219 | 120, **111**, **223** 219 | 120, **101**, **230** 218 |
| light bottom: rim rows, line, outside | 218 231, **90**, 108 | 218 231, **108**, 108 | 219 232, **90**, 108 |
| corner patches 74 x 74 px, bottom-left / top-right, rms against the Mac (light; dark) | | 2.41 / 1.75; 1.64 / 1.92 | 1.96 / 1.69; 1.46 / 1.94 |

| menus (Apple menu 262 x 305 pt, n 16; second menu 202 x 222 pt, n 14), dark over grey | Mac (menu probe) | before | after |
|---|---|---|---|
| left: outside, line, inside | 113, 47, 114 | 112, 58-59, 110 | 112, 53, 113 |
| right: inside, line, outside | 114, 47, 113 | 113, 58-59, 109-110 | 113, 53, 112 |
| top rim rows (the menu hangs from the bar: outside 107) | 156 138 | 153-154 138-139 | 155-157 137-138 |
| bottom: rim rows, outside | 138 156, 106 | 137-138 155, 109-110 | 139 156, 105 |
| light: left line, inside / right line, outside / top line (under the bar, 109), first row / bottom line | (no Mac still) | 60-61, 189-190 / 64-65, 111 / 100, 222-223 / 108-109 | 54, 199 / 54, 114 / 90, 230-232 / 90 |

   Surfaces whose markers were exact (odd n or no markers): Control Center (all 12 shapes whole points in the trace),
   Spotlight bar and list (520 pt, n 17), the Dock (524 pt), the HUD (303 pt, n 17). Re-measured as before / after stills
   of the desktop, Control Center open and Spotlight with results, dark and light, in one session: pixel-identical in
   light, in dark only the menu-bar clock differs (the minute changed). Nothing the earlier rounds matched moved.
   Spotlight R4.4's edge items are not this shift. The list's side line: Mac 83 / **68** / 91 over grey and 166 / **144** /
   166 over white is the tone of the shadowed backdrop with bias -0.077 on both backdrops (ours -0.25: 84 / 34 / 91), but
   the Mac's bar has a strong line (96 / 28 / 35) and ours draws both with one recipe, so no recipe change (a bias for
   the list would lift the bar's line 38 -> 74); the list is probably a different material on the Mac (not decoded). The
   gap between bar and list (Mac 47-52 over grey, ours 52-60) is the shadows, not the rim.

2. **Low-opacity glass: the 8 bit write, not the marker.** The trace gives the opacity of every draw (`fade x opacity`, the
   marker's steps are 1/306) and it grows smoothly; mcap of the HUD appear and hide over grey 127 (interior patch rows
   105-125, columns 470-850 of the 960 x 400 crop, 9.3 levels darker than grey at full): the darkening against that
   opacity was linear before rounding and the flat backdrop turned it into whole levels: 0 up to opacity .04, .108 from
   .075 to .12, .216 from .17 to .24, .324 ... (the "0 at .04, then .12 from .08 to .14" of MOTION-AUDIT R3.4). The
   dither that would spread it is gated off on flat backdrops (Precision, README). Fix (`plugin/shaders/liquidglass.frag`
   end of main): while the glass fades (layer alpha < 1 or materialize < 1) the same half-level noise goes on the blended
   result, unscaled by alpha and on every backdrop, so the mean follows the opacity; at rest the old gated dither is
   unchanged.

| HUD interior darkening / full against the drawn opacity (67 frames with 0 < opacity < 1) | before | after |
|---|---|---|
| rms, max | .021, .044 | **.0022, .007** |
| at opacity .039 / .075 / .121 / .173 | 0 / .108 / .108 / .216 | .039 / .075 / .121 / .172 |
| HUD agent's metrics (hudm.py / ffit.py / cmp.py): ours ag against o^2 | .0172 | .0093 |
| against the Mac's R3.4 frames, all / o^2 < .2 | .062 / .048 | .061 / .045 |

   Ours now follows o^2 (.041 .079 .127 .178 at o^2 .040 .077 .124 .179), the Mac reads -.017 .024 .104 .125 there: the
   rest of the low-opacity gap is the shell's mapping (`HudWindow.qml` glassAlpha = o^2; the Mac's glass starts later,
   R3.4's o x clamp((o - .14) / .79) form) and the Mac's 11 % lighter glass while animating, not the plugin.

3. **Alert dismiss blur (done since: MOTION-AUDIT.md "Alert, Round R3.1", dismiss blur / shadow; content by a
   QML layer, glass edge and shadow size by two window-wide markers).** The Mac's 5 p blur during the Cancel fade is applied to the whole window through a
   snapshot proxy (MOTION-AUDIT.md "Alert, Round R3.1"): the alert's text and buttons are the shell's own surface above
   the glass, so the glass's marker path cannot blur them; it needs the layer drawn to an offscreen buffer and blurred,
   which `plugin-motion` (hyprkmotion: the window close blur) does for windows. The shadow already follows the scaled
   shape; on the Mac its radius and offset also scale by 1 - 0.02 p, at most 0.5 pt, below what the stills resolve.

4. **Settings pop-up menus read lighter than the Mac's in dark (Settings agent's note): not the recipe.** Over a flat
   (37,38,43) wallpaper the plugin's dark menu reads (60,62,67), and the recipe (face, max luma 0.35, edge bleed; the
   model `check_model.py` face_ours, which matches the Mac's menu200 probe over flat backdrops) gives (60,61,67). The
   Mac's Settings pop-up reads (56,57,63) over its window background (30,31,36): the same model gives (55,56,62). In our
   Settings the Text highlight menu reads (67,70,73) to (64,77,92) over a (37,38,43) card because it covers the Icon &
   widget style tiles (the Tinted tile is blue) and the pop-up button, which its blur and edge bleed take in (with the
   glass off the popup draws no fill: the backdrop shows through unchanged). Next, on the Settings side: the window
   background under the menu (37 here, 30 on the Mac) and what lies under it.

Files: `plugin/src/Shape.cpp` fractionEdge + its use, `plugin/src/Shape.hpp` (declaration and note),
`plugin/shaders/liquidglass.frag` (two summed dark specular lobes, fading dither), `plugin/tests/test_main.cpp` (the alert's even n at rest, every code
inside its bin for n 3..17), `plugin/README.md` (Sub-point edges, Precision).

## 15. Round 10 (2026-11-14): shadows and scroll pocket from R5.2/R5.4

Mac: `screens/27.2.1/panels/shadow-{banner,module}-{grey,white}-{dark,light}.png` (MAC-ANSWERS-5 R5.2) and
`screens/27.2.1/finder/scrolled-under-toolbar-{icon,list}-{light,dark}.png` (R5.4). Ours: headless session at scale 2,
flat grey 127 and white wallpapers, banners from `Notify` on the session bus, the Wi-Fi module by a click on its item,
the Finder at 740 x 500 pt on a folder of 40 flat 256 x 192 PNGs in the Mac's colours (sampled from its shot) plus 20
text files, scrolled by `fscroll` finger frames. Scripts and crops: agent scratch `agent-sh/py`, `agent-sh/shots`.

### Shadows (judge #19: banner and module shadows never compared)

**Method.** Over two flat backdrops a shadow pixel is out = B (1 - a) + C, so grey 127 and white give a = 1 - (w - g) /
128 and C = w - 255 (1 - a). The Mac's grey desktop has a menu bar legibility gradient (112 at the top of the screen,
127 from 69 pt down; none over white, `shadow-module-*.png.full.png` x 200 pt), so the grey shot is used only below 69 pt;
the sides use the white shot. C is within 1 level of 0 for both surfaces in both modes: **no tint**, a pure darkening
out = B (1 - D). (A black shadow and the glass filter's backdrop-tinted one, ShadowVibrancyContribution, are the same
over a flat backdrop: two flat shots cannot tell them apart.) D is fitted as A x the shape's box blurred by a Gaussian
(sigma) and moved down (y): three columns below (and above, banner), three rows beside, out to the shot's edge; the
module's top is under the bar (left out). Shapes: banner 344 x 75 pt Mac / 344 x 57 pt ours (two text lines), module 308
x 175 pt both.

| surface | Mac sigma / y / A (light, dark) | ours before | rms |
|---|---|---|---|
| banner | 16.9 / 7.6 / .124, 16.8 / 7.65 / .185 | 16.45 / 7.1 / .096, 16.5 / 7.05 / .149 | Mac .45 / .48, ours .27 / .34 (of 255) |
| Wi-Fi module | 16.75 / 9.95 / .211, 16.8 / 9.95 / .241 | 16.7 / 10.25 / .208, 16.75 / 10.25 / .237 | Mac .31 / .33, ours .19 / .19 |

Darkening x 255 over white straight below the middle, Mac / ours, at 1, 4, 8, 14, 22, 30, 40 pt:
banner light 20/15 18/13 15/11 10/8 6/5 2/2 1/1, dark 30/23 27/21 23/17 17/13 10/7 4/3 1/1;
module light 37/37 34/34 29/29 22/21 13/13 6/6 2/2, dark 43/43 39/39 33/33 25/25 14/14 7/7 2/2.

**Who draws them: the plugin.** `Glass.qml` only passes `shadow`; the recipe is per layer (`config/hypr/hyprland.lua`
materials): banners `hyprk-notifications` -> `notificationcenter` (shadow 0.2925 light / 0.455 dark, r 24, y 8,
vibrancy 1: darkening 0.3 x opacity), the module `hyprk-overlay` -> `menu` (0.7 / 0.8 x fill 0.3 = 0.21 / 0.24, black,
r 24, y 10). The shader's edge 0.5 erfc(d / r) is a Gaussian of sigma r / sqrt 2 = 16.97 pt: both radii match the Mac.

- **Module: already equal** (A within 1.5 %, y within 0.3 pt, every distance within 1 level). No change.
- **Banner: 0.77 x (light) / 0.80 x (dark) the Mac's.** The opacity was fitted to the gap between two Notification Center
  cards (with the shell's list shadow, PC #62); the decoded `_Glass.notificationCenter` value, Regular at D 166 = 0.4 light
  / 0.6 dark (`decomp/NotificationCenter-glass.c`, Material.cpp note), scales ours by 1.368 / 1.319: light 20.5 17.8 15
  10.9 6.8 2.7, dark 30.3 27.7 22.4 17.1 9.2 4 against the Mac's 20 18 15 10 6 2 / 30 27 23 17 10 4 above: within 1
  level. So a banner's shadow is the decoded one and the cards keep their fit: a recipe of its own for the banner layer.
  **Plugin change (not applied here, the recipe files belong to the plugin's owner):** in `plugin/src/Material.cpp`
  after NOTIFICATIONCENTER (line 148):
  ```cpp
  // banners (hyprk-notifications): _Glass.notificationCenter with Regular's decoded shadow at D 166, 0.4 light /
  // 0.6 dark (r 24, y 8, vibrancy 1): Mac R5.2 shadow-banner-{grey,white}-*.png solved over grey 127 and white,
  // darkening .124 / .185, sigma 16.9 pt, y 7.6 pt (GLASS-HIG.md 15); the cards keep the gap fit above
  constexpr SRecipe NOTIFICATIONBANNER = [] {
      SRecipe r            = NOTIFICATIONCENTER;
      r.name               = "notificationbanner";
      r.shadowOpacityLo    = r.shadowOpacityHi = 0.4f;
      r.shadowOpacityHiDark = 0.6f;
      return r;
  }();
  ```
  add it to `RECIPES` (line 162), and map `hyprk-notifications:notificationbanner` in the default `materials`
  (`plugin/src/Config.cpp` line 85) and in `config/hypr/hyprland.lua` line 305 (both, in the same change: an unknown name
  falls back to Regular). y stays 8 (Mac 7.6, ours 7.1 at 8: within the fit's 0.5 pt).
  **Applied** by the main session at 18:55 (Material.cpp NOTIFICATIONBANNER + RECIPES, Config.cpp default `materials`,
  hyprland.lua `materials`; scratch build, ctest 2/2). Not yet re-captured on screen.

### Scroll pocket (Finder)

**What the R5.4 shots can show.** Scrolled 36 pt, the Mac's first thumbnails end at row 186 px and are 84 px tall like
ours: their tops are 1 pt under the 52 pt line. The icon shots show the band over plain content and a 1 pt strip, not
icons or names deep under it (no name and no row passes under the band). Ours rests 10.5 pt higher (first thumbnail top
77 pt, the Mac's 87.5 pt; row pitch 112 vs 116 pt, 5 columns beside our sidebar vs 6): compared at the same geometry,
ours scrolled 26 pt (thumbnail rows 102..186 px like the Mac's). Rows below are px at 2x, through the first thumbnail;
the two "above the strip" rows of "before" already have the new dark colour and line (only the blur's reach differs).

| | Mac | ours before | ours after |
|---|---|---|---|
| band over plain content, dark (content (31,31,36)) | (39.3,39.4,45.1) | (43,42,47) | (39..40,40,45..46) |
| band over plain content, light | 255 | (255,253,253) | 255 |
| line at the band's bottom (row 104) | 0.5 pt, 228 over 254 / 201 over the red 223 (black .10); (47,47,51) over (31,31,36) / 225 over 223 (white .07) | none | 229 / 199; (47,47,52) / 224 |
| above the 1 pt strip, light G rows 94..98, 99..103 | 255, 255 255 253 249 247 | 237, 234 228 218 205 200 | 252, 246 239 227 217 212 |
| same, dark R | 41, 42 43 49 59 65 | 47, 50 53 63 78 85 | 39, 43 47 57 69 76 |

- **The line is AppKit's separator** (0x18b463018 / 0x18b462f78, TOOLBAR-REA-27.2.1.md 1: black .10 light / white .07
  dark, 0.5 pt): the shot shows it is an alpha line over whatever lies there (over the thumbnail too), at 52 pt, while
  scrolled. Built in `finder/qml/Main.qml` (the Rectangle after the ScrollEdge, shown with it; .65 with Increase
  Contrast, decoded). Whether it shows unscrolled is not in these shots; it follows the pocket, like Settings' line.
- **The band's dark colour.** At the fitted replay opacity 0.7 the background (46,46,50) (solved at the dumped 0.6) gave
  (41.5,41.5,46.3) over (31,31,36) in the model, 43 on screen. Least squares over the two Settings points
  (TOOLBAR-REA 1: (30,31,36) -> (39,40,45), (37,38,43) -> (41,42,48)) and Finder's (31,31,36) -> (39.3,39.4,45.1),
  through the same replay saturation .833 and final x1.25: **(43,43.5,48.5)**, rms 0.28 levels (at 0.6 it would be
  (44.75,45.25,50.25), also 0.28: the two points per channel cannot separate opacity and colour; 0.7 stays from the
  photo fit). `ui/HyprK/ScrollEdge.qml` veilColor.
- **No haze from below.** The 16 pt fill blur and the variable blur read the textures' margin, so the thumbnails under
  the line (still in view) tinted the whole band: light G 237 at 5 pt above the line where the Mac reads 255, dark R 47
  for the Mac's 41. CA's backdrop layer captures its own bounds (normalized edges): taps outside the band rect now weigh
  0 and the kernel is renormalized (`scrolledge.frag` inBand, both loops). After: 252 / 39 (the 3 levels left in light
  are our thumbnail's own drop shadow inside the band).
- **Left: the strip right above the line reads about twice the Mac's** (light 25 % vs 5 % of the thumbnail at 1 px
  above, dark 20 % vs 14 %), spread over the same 3 px. A 1 pt strip does not settle it (the Mac's thumbnail top may be 1
  px lower; light vs dark also disagrees with the model, where both are about 13 %). A Mac shot scrolled 60+ pt (icons
  and names well under the band) would.
- **List view: not the hard strip we draw.** The Mac's rows run under the column header and the toolbar: the header strip
  (52..80 pt) shows the row under it at about 10 % (Image 01's thumbnail (223,86,79): R 56 over 40 dark, G 242 over 255
  light), blurred about sigma 3..4 pt (a 13 pt thumbnail spreads to about 20 pt at half height), spilling about 8 pt up
  into the toolbar strip (light G 254 at 46 pt, 243 at 58 pt); plain base dark (38,39,44), light 255; the header line at
  79 pt. Ours clips the rows at the header line and nothing shows (Q-finder-17's "solid bar" was read without content
  under it). Not built: FileList would need its rows under the header and a heavier pocket than the toolbar's ThinFilm
  (10 % through vs about 30 %). Recorded for the list view.
- **The toolbar capsules** sit over a flat band in both shots: no difference measured.

Files: `ui/HyprK/ScrollEdge.qml` (veilColor, note), `ui/HyprK/shaders/scrolledge.frag` + `.qsb` (inBand on both blurs),
`finder/qml/Main.qml` (`pocket` id, the separator line). Settings uses the same ScrollEdge: its plain dark window now
models (39,40,45) for the Mac's (39,40,45); not re-shot here. Tests: shell 403, finder 33, ui 98 pass.

**Round 11 (judge #20 defect 5: bleed above the line, list rows under the header).** Same geometry as round 10 (our
thumbnails 102..185 px scrolled 26 pt, the Mac's 102..185: both have their top 1 pt rim inside the band). Columns
through a thumbnail that no toolbar capsule covers (ours: Image 04, x 540..570 pt; our Image 01 sits under the
back/forward capsule, whose glass changes the rows above 88 px), rows 98..103 px:

| | Mac | ours before | ours after |
|---|---|---|---|
| light, B over Image 04 (thumbnail B 78..87) | 255 255 255 253 249 247 | 253 248 241 228 215 209 | 250 249 248 246 241 239 |
| light, rows 94..97 (above the strip) | 255 | 255 | 250 B / 252 G (new tint, see Left) |
| dark, R over Image 01 | 42 43 44 49 59 64 | 43 47 57 69 75 (99..103, judge) | 41 41 43 49 58 65 |
| dark, R / G over Image 04 rows 100..103 | 44 49 59 64 / 42 46 52 56 | | 43 48 57 64 / 42 45 50 54 |

- **Cause 1: the texture margin.** `soft` (1 texel per 2 pt) covered the band plus 40 pt; its bilinear filter mixed the
  texel under the band's edge into the last row. The textures now cover the band only (`_rect`, clamp-to-edge).
- **Cause 2: point taps 10 pt apart.** The fill blur's centre tap row landed on the band's last 2 pt texel, which holds
  the thumbnail's rim, and weighed it 40 % (debug output: b = 34 % thumbnail at row 103; the 16 pt Gaussian over a 1 pt
  strip gives about 5 %). `soft` is mipmapped and read at the level whose texel is about the tap spacing (`tapLod`).
  With both, dark matches the Mac within 1-2 levels in every row (the band model, both blurs renormalized in the band,
  predicted (65.1,50.1,54.5) at row 103 for the Mac's (64.2,49.0,54.4)).
- **Light `normal` FITTED 0.7 (dump 0.25).** With the dumped .25 the band model leaves the light strip too clear (G 236
  for the Mac's 247 at row 103, the grey icon shadow 250 for 255). A sweep over that strip and the Settings photo
  (appearance-scroll-000/-250-light, band-only model) picks .7: strip rms 4.7 -> 2.2, photo 5.1 -> 4.1 levels. Scripts:
  scratch `agent-fp/py/{band,photo,finder_edge,sweep2}.py`.
- **List view: built.** FileList runs its rows under the header and, without tabs, under the toolbar (Main `listUnder`,
  FileList `topInset`); a ScrollEdge over toolbar + header (80 pt) shows while a row is under it: FITTED plain blur
  sigma 5.5 pt under a veil .88 white / .86 (39.1,40.3,45.3), saturation 1.25 (rms over the Mac's thumbnail column
  rows 38..79 pt: .72 light / .67 dark). On screen (scrolled 36 pt like the Mac): light G 245.8 243.0 245.5 247.2 243.8
  at 52 / 58 / 64 / 70 / 76 pt (Mac 249.0 243.7 245.0 247.8 245.4), dark R 49.3 54.4 50.5 49.0 55.1 (Mac 47.7 54.5 52.2
  49.6 53.6). The header fill hides while the pocket shows; a MouseArea over toolbar + header keeps clicks off the rows
  under it; `ensureVisible` brings a row the header covers down under it. Rest state unchanged (header 52..80, rows from
  85 pt).
- **Settings (no regression):** Keyboard pane scrolled to the Mac's scroll-edge-keyboard-*.png ("Keyboard navigation"
  ink at 146 px), rms over the band x 170..500 pt: light 7.85 -> 7.57, dark 7.11 -> 7.00 (layout differences included).
- **Left:** (1) light rows above the strip now carry a 3-5 level tint (B 250 at 47..49 pt over Image 04; Mac 255): the
  mipmapped fill blur sees the rims of all thumbnails, the Mac's does not; the Mac's strip itself is still 2x clearer
  (row 103: 239 vs 247). The two Mac data sets (photo: bottom rows prefer a lower veil; Finder strip: higher) do not fit
  one replay opacity; next step: a Mac shot scrolled 60+ pt (icons and names deep under the band). (2) The list header's
  bottom line over a row: Mac light (229,218,215) (an alpha line), ours the opaque #E5E5E5. (3) Icon view keyboard
  `ensureVisible` can still leave a cell under the toolbar (GridView.Contain counts the band as visible), as before.

Files: `ui/HyprK/ScrollEdge.qml` (no margin, `mipmap`, light `normal`, `radius` / `replaySat` settable),
`ui/HyprK/shaders/scrolledge.frag` + `.qsb` (`tapLod`, no margin uniform; build line fixed), `finder/qml/FileList.qml`
(pocket, header z order, `topInset`, `ensureVisible`), `finder/qml/Main.qml` (`listUnder`). Tests: finder 33, shell 406,
settings 52, ui 104 pass.

## 16. Round 11 (2026-11-14): the OPEN-FIXES glass items 1-4, rendered and measured

Headless session at scale 2 (scratch HOME and state, flat grey 127 or the 4 pt stripes as the Mac shots), the plugin
built in agent scratch (`agent-gr`) and swapped in the same session (`hyprctl plugin unload / load` under a new file name;
every plugin option kept except `appearance_ack`), the shell restarted and Settings restarted for every shader build (a
QML reload keeps the old .qsb). Press series with mcap (`-k 1`, every frame, no missed frame), aligned with the Mac clips
(agent-g7's `movd` / `movl` frames, pts) on the frame where the knob's white centre starts fading. Scripts:
`agent-gr/py` (ccx / ccrow: CC lens; pvx / pvarc: preview ends; swx / swm2: held switch and press; minima: plugin lines).

1. **Control Center Sound lens, the rim over the white fill (applied, re-derived).** Dark grey 127, frame 3 of
   `panels/cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png` (judge #19's crop). The Mac's line pixel darkens down
   the fill rows (175 -> 160): the ring shadow's band, whose moved shape is nearer the lower rows. Ours read 179 flat:
   `glasslens4.frag` mixed the stroke line in after the ring term and drew it opaque over `ringshadow.frag`, so over an
   opaque source the line had no ring term (over an empty source it had: its black lies over `ringshadow.frag`). Now the
   line is multiplied by 1 - ring after its tone curve (the composite of round 6, `mix(shadow, col, coverage) x (1 - ring)`
   over the stroke too). The decomp's literal order (ring before the tone, 3b then 4) drew every row 5 dark (171 -> 155).
   Not applied: OPEN-FIXES' `lensRimBias` -0.333 (a flat 170, no gradient; it would darken the top rim over the module
   62 -> about 56, Mac 61: computed from these pixels, not rendered) and the edge shift at `frag:338`: after the ring term
   the line's darkening across the crossing equals the Mac's (ours 71 + 83 over two columns, the Mac 26 + 85 + 57 - 6 over
   three); judge #20's outer pixel (243 against 231) is the knob's sub-pixel phase (the Mac's line covers about 0.3 / 1 /
   0.7 of three columns, ours 0.9 / 1 / 0.1 at the stub's volume), and the shift would narrow the line.
2. **Liquid Glass preview, dark round ends (applied).** `liquidglass-0-mid-1-dark.png` (crop rows 15..115, columns
   588..1118; ours `grim` 265 x 50 pt at the window's offset): the rimSpec.z 4 face mix at 0.75 of the lobe. Light is
   unchanged (z 4 is dark only), the top line too (no lobe there).
3. **Held switch** (`switch-held-stripes-{dark,light}.mov`):
   - a) **soft white edge inside the lens (applied)**: the glass's content takes a 1.75 pt ramp, centred on the glass
     shape's edge, and the stroke line reads the backdrop without that content (`tapBack`: the white is in the glass, not
     in the backdrop the line tones). The ramp alone lightened the rim 4-6 levels mid-growth (dark 32 28 24 19 15 ->
     36 32 30 24 20); kept at the shape's outer edge instead (0 at +0.25 pt), it dropped the top pixels at frames 3-4
     (dark 138 139 -> 122 110, Mac 177 144). Held stills are the same picture (the white is gone at full lift).
   - b) **outer rim +9 (rejected)**: the lens is 40.6 px tall, so one end always splits a pixel. y rounded to device px:
     light top 206 / 194 -> 220 / 194 and bottom 192 / 202 -> 194 / 192 (Mac 192 / 193, 191 / 191); dark top 23 / 17 ->
     30 / 17, bottom 17 / 22 -> 18 / 17 (Mac 20 / 20, 19 / 19). The Mac's held lens is 44 px including the line (ours
     44.6) and its held slider sits off the grid (round 7), so CA does not snap; a whole-pixel height would be a fit.
   - c) **light top highlight mid-growth (rejected)**: `fxs * fxs * fillLight` left the light 255 at frames 5-9 (the
     brightness there is the white content refracted to the top, not the fill light) and darkened the dark top: rms
     against the Mac (frames 3-9) dark 18.4 -> 23.6, light 16.2 -> 14.2 (frames 3-5 only).
   - d) **early light rim (rejected)**: the press layer at full alpha from mouse-down took the light rim's rms (frames
     0-10) 14.1 -> 8.8 but put the track outside the lens 22 levels dark in the first frame. The Mac's held track darkens
     with the growth, not at once: B 248 246 244 240 238 233 230 225 over the first 8 frames from the first change, ours
     (unchanged, the layer on `_lift`) 247 246 243 240 237 234 229; the instant layer 223 throughout.
4. **Plugin Regular, dark side rim (applied, fit).** `REGULAR.dark.darkBias = -0.278f` (`plugin/src/Material.cpp`; MENU,
   NC and the banner recipe inherit it; `check_model.py` lists it as a measured deviation from the dumped -0.25). Mac:
   `windows/alert-shown-grey-dark.png` rows 420..580, `verify/B/menu-probe-popup-over-grey-dark.png` rows 250..290,
   `nc/stack-dark-grey.png`, `panels/banner-dark-grey127.png`. Same session, same shell state: the desktop with the Dock,
   Control Center (after reopening in the same state) and Spotlight with results are pixel-identical before / after
   (Spotlight's only difference is the caret blink); light is not touched (`.light` keeps -0.25). The Dock's hover label
   (`hyprk-dock-label:regular`) side line 102 -> 99 (no Mac still of it).

| item | Mac | before | after |
|---|---|---|---|
| 1 CC dark: line pixel per fill row, top to bottom | 175 173 172 168 165 162 160 | 179 179 179 178 178 179 179 | **175 173 171 170 168 167 165** |
| 1 CC dark: mean of the inner fill rows | 169.2 | 178.7 | **170.7** |
| 1 CC dark: top rim over the module; right end over the track | 82 61; 88 47 | 62 62; 68 43 | same |
| 1 CC light (stripes): left end over the fill | 178 | 184 | **176** |
| 1 Settings slider light: bottom rim; ends left / right | 190 192; 59 / 135 | 194 194; 63 / 151 | **192 191; 61 / 149** |
| 1 Settings slider dark: bottom rim; ends left / right | 19 20; 78 / 15 | 18 18; 84 / 21 | 17 17; **78** / 20 |
| 1 switch light: bottom rim outer / inner (dark unchanged) | 191 191 | 194 204 | **192 202** |
| 2 preview dark: the five round ends' middle (share L R, copy L R, search L) | 109 111 111 111 111 | 107 103 102 103 103 | 115 **109 108 109 108** |
| 2 preview dark: along the arcs, mean abs ours - Mac (per end) | | 10.2 10.2 10.1 9.7 10.2 | **7.5 5.9 6.2 5.8 6.4** |
| 2 preview light: the same ends | 141 130 129 128 128 | 140 127 126 125 125 | same |
| 3a white edge 10-90 % rise (px), frames 4-8, dark | 3.1 2.1 2.2 3.2 2.9 | 1.1 1.0 1.4 1.4 2.4 | **2.1 2.4 2.3 2.5 3.4** |
| 3a the same, light | 2.1 1.7 4.0 3.7 4.7 | 1.2 1.0 1.0 1.0 1.1 | **2.1 2.5 2.3 2.2 2.0** |
| 3a dark frame 5, row 4 px above the centre from the rim | 71, 127 141 140 141 151 175 177 | 83, 104 117 114 166 183 183 | 83, 92 123 133 152 177 183 |
| 3a rim pixel rms frames 0-10; top pixels rms frames 3-9 (dark / light) | | 6.0 / 14.1; 26.7 / 15.3 | 6.0 / 14.1; **18.4** / 16.2 |
| 4 alert dark: left / right line (outside 112-113) | 47 / 47 | 53 / 53 | **46 / 46** |
| 4 Apple menu dark: left / right line | 47 | 53 / 53 | **46 / 46** |
| 4 NC card dark: outside, line, inside | 100, 54, 103 | 102, 67, 97 | 102, **63**, 96 |
| 4 banner dark: outside, line, inside | 116, 67, 106 | 114, 82, 98 | 114, **78**, 96 |

Still different: the CC dark line's lower rows (Mac 160, ours 165) and our ring shadow just outside the lens over the
white fill (ours 246-247 one to two pixels left of the line, the Mac 254); the share capsule's left end middle (115, Mac
109) while the arcs improve; the switch's light rim mid-growth (15-19 lighter in the first 6 frames), the light top pixels
at 255 from frame 5 (Mac 204 233 242 at frames 4-6), the held lens's split outer pixel; the NC card and banner lines are
still 9-11 light (the bias that fits the alert and the menus does not reach them).

Files: `ui/HyprK/shaders/glasslens4.frag` + `.qsb` (tapBack, the content's ramp, the 0.75 lobe, the ring on the line),
`ui/HyprK/Tokens.qml` (regularRimFace note), `plugin/src/Material.cpp` (REGULAR dark bias), `plugin/README.md`,
`plugin/tools/check_model.py` (DEVIATIONS). Tests: ui 104, shell 406, settings 52, plugin ctest 2 / 2.

## 17. Spotlight: one window shadow, the rim before the veil (2026-11-14, judge #20 defect 4)

AppKit's window shadow (`SRecipe::shadowBlack`, only Spotlight) is now one shadow of the whole window: a group passes
the shapes of the groups drawn before it (`priorBox` / `priorInfo` / `priorCount`, `GlassElement.cpp`), and the shader
darkens by the rest of `1 - o min(1, sum of masks)` and never over their glass, where it used to stack one shadow per
group; Spotlight's recipe also takes the shell's .205 bottom veil as a black fill on a face clamped to 1 first
(`clampBeforeFill`), so the key/fill rim survives over white, and the shell's veils on the plugin path are the rest
(`Theme.spotlight.pluginVeil`, bar bottom rim line .093). Dark, gap between bar and list over white 104 -> 120 before,
96 -> 105 after (Mac 95 -> 104, rms 12.6 -> 1.1), over grey 52 -> 60 / 48 -> 53 (Mac 47 -> 52, rms 6.4 -> 0.8); the
list's bottom rim over white 203 203 204 203 / 207 209 220 233 (Mac 207 209 220 231), over grey 142 / 153 (Mac 150);
the light gap over white 164 -> 169 as the Mac's; worse: the list's top row over white 119 -> 136 (Mac 95). The other
glass (Dock, Control Center, menus, alert, Notification Center, banner, HUD; light and dark over grey 127 and white) is
the same pixel for pixel, the build swapped in one session. Numbers and the rest: `SPOTLIGHT-27.2.1.md` "Judge #20".
The REGULAR dark bias -0.278 and the round 11 notes above are unchanged.
Judge #21 (2026-11-15): the key lobe (top) now goes on the face before the clamp and the fill, the fill lobe (bottom)
after them, as the Mac's rims differ over white (bottom bright, top not): list top rows over white 136 129 -> 119 119
(Mac 100 119), over grey 89 79 -> 83 76 (Mac 85 83); bottom rim, gap and every other recipe unchanged
(`SPOTLIGHT-27.2.1.md` "Judge #21").

## 18. Interactive glass: hold shine, elastic knob, end glyphs (2026-11-14, round 7 user report)

The press light's BigGlow now covers the whole glass (`glasslens4.frag`: the square test is gone; the Mac shows no edge
where the code's square layer would end, max neighbouring step 2.0 / 2.3 levels against our 4.5 / 4.2): on the
Appearance preview's share capsule, held − rest dark 9-15 / 30-33 / 48-51 pt R +77 / +37 / +23 (Mac +81 / +35 / +17),
light 30-33 / 48-51 +17 / +12 (Mac +17 / +11). The toolbar platters (Settings / Finder back-forward) are one
FlexInteraction entry each: lifted about the centre (rims −3 / +3 px, Mac −3 / +3) and lit with the falloff, not the even
0.1 layer TOOLBAR-REA 2 had read off a still with the history menu open. The held slider / switch knob's lens is
deformed by its acceleration (FlexInteraction liquidLens, the VelocityIntegrator's three 0.3 EMA stages, applyMovement,
softClamp, a 0.444 s / 0.56 spring) as a geometry change, so the lens re-samples under its new shape: the Mac's fling
path replayed on Desktop & Dock > Size gives lens widths within 0.73 pt rms of the Mac's (26.5 static before: 1.60).
Control Center's end glyphs bounce (SF Symbols .bounce: decoded segment times, fitted peak / trough per glyph) when a
drag reaches an end, 0.028 rms against the Mac's frames. Details and sources: INTERACTIVE-GLASS-REA.md 5-6.

## 19. Round 12 (2026-11-15): the slider lens's ring decoded; the Control Center dark fill (judge #21, OPEN-FIXES 19)

The knob lens is DesignLibrary's `GlassRecipes.ControlSliderRecipe` (swift-DesignLibrary.txt: Spec = ControlClearSpec +
SliderSpecModifier, Parameters = ControlParametersModifier + SliderParametersModifier + the inactive terms). Bodies in
`decomp/DesignLibrary-recipes.c` (its addresses are the cache's + 0x1000: ControlClearSpec FUN_195f02fe4, SliderSpecModifier
FUN_195f04360, SliderParametersModifier FUN_195f046b8, ControlParametersModifier FUN_195f071b4):
- **Ring geometry is constant.** ControlClearSpec loads 3.0, 4.0 and 8.0 (doubles) in one block with the dark specular's
  -0.3 and 120 deg, pi/2, 0.15f and 0.1f; the dump's ring blur 3 / stroke 4 / offset 8 (verify B2) are these, not a
  share of the lens size (matched by value: the stores go through a stack copy). So the Control Center knob (22 x 18)
  takes the Settings slider's band (25 x 20).
- **Ring opacity by colour scheme.** SliderSpecModifier reads the Environment (accessor FUN_195f3c68c; field 2 is
  `colorScheme`, field 4 `controlTint`, whose nil default there is (0, 0.478, 1, 1), systemBlue) and writes Spec 0x4b8
  (ringShadow 0x4a0 + 0x18, NOTES.md) = `colorScheme == .dark ? 0.4 : 0.15`, inside a check (FUN_195ed53f0) not
  identified. Settings light was fitted at 0.14 (section 12): now **0.15** (`Tokens.control.sliderLensRingOpacity`;
  computed on the old shot: track 210 -> 208, card 229 -> 229; not re-shot). The Control Center's light frame reads
  0.4 (218 against 0.4's 220, 0.14's 240): its modules draw in the dark scheme in both appearances, as their white
  labels (inferred). `Theme.cc.lensRingOpacity` 0.4 unchanged, now with this source.
- **The dark fill (OPEN-FIXES 19) is not the band.** Ours re-measured (headless, scale 2, dark, grey 127, Sound knob held
  0.8 s at (1100, 468) pt, judge #21's `cc.py` crop): fill mean 216.9 (Mac 224.0); per column 238 .. 200 (Mac 246 ..
  211). Down the column 8 px into the rim box, white x (1 - 0.4 x the decoded band, face top 1 pt under the box top),
  Mac rows 15-22 and ours rows 14-21 (our fill sits 1 px higher in the box at this volume):

  | | fill rows, top to bottom |
  |---|---|
  | Mac | 243 242 235 232 226 222 218 214 |
  | white x decoded ring there | 224 219 214 210 207 204 204 204 |
  | Mac excess | +19 +23 +21 +22 +19 +18 +14 +10 |
  | ours | 234 233 229 225 221 217 213 210 |
  | white x decoded ring there | 228 224 219 214 210 207 204 204 |
  | ours excess | +6 +9 +10 +11 +11 +10 +9 +6 |

  Both follow the decoded band's slope; over it the Mac's fill inside the lens is 4-14 levels lighter than ours, most
  at the top (about white 1.08 before the ring, ours 1.04). The module rows above and below the fill match within 1-6. No term of the
  decoded stack lifts white that far 7-10 pt into the lens (the key / fill highlight's mix toward the clamped colour
  matrix gives white at most its 1.0; its diffuse part ends 8 pt in), so the lift is a source above 1 (the CC fill in an
  extended-range backdrop?) or a Control Center-only term; not decoded, not changed.

## 20. Round R8 (2026-11-15): gradientOvalization, the held slider knob over white (MAC-ANSWERS-8.md)

**R8.1 applied (plugin).** The key/fill highlight's lobes read an ovalized normal: `n = normalize(mix(n_sdf,
normalize(x, y W / H), 0.5))`, x, y from the shape's centre, on a shape whose shorter side is over 64 pt, else the plain
SDF normal (`Material.cpp` gradientOvalization, `GlassElement.cpp` shapeOval per member, `liquidglass.frag` scene() nk;
the pointer square and the Dock menu's tail keep 0). Interior, refraction, bleed and the dark specular line still read the
plain normal. Spread: the code's ramp, 80 deg up to D 96 and 90 from D 191, agrees with R8's two dumped sizes (56 -> 80,
260 -> 90); sizes in between are not in R8's trees. `check_model.py` 4b ports the lobe against the probe's captures:
640 x 260 r24 first row, middle / 40 pt from the ends, dark Mac 157 / 144, port 157.0 / 144.1 (6 rows rms .35, max 1.5);
light 246 / 236, port 246.0 / 237.3 (rms .34, max 1.4); the 640 x 56 capsule flat. Qt side: LensGlass is a capsule whose
shorter side is at most 37 pt in every use (knobs, the Appearance preview), so 0 there: nothing to change.

Not every Mac glass is ovalized. The R8 sweep is SwiftUI / AppKit glass; the Mac's Dock top rim over black reads 104 flat
from 25 pt (where its corner ends) to 229 pt from its left end (`glass53/dock-dark-black.png`; 0.5 would take it to about
70 near the end), Cmd-Tab's rim is as bright 100 pt from its end as mid-way (`cmdtab-dark.png`), and Control Center's Now
Playing tile keeps its bottom rim flat (231 / 179 over grey, 123 / 84 over black, `glass53/cc-*`). With 0.5 ours fell
from 156 to 139-143 near the Dock's ends and to 224 / 176 on the tile 15 pt out. So `SRecipe::ovalize` is false for the dock (Dock, Cmd-Tab) and
controlcenter (modules, HUD) recipes, true for the rest (alert / menus, Spotlight, banners, NC cards, window glass); the
Mac's banner and popup menu peak at the middle as the probe does (`panels/banner-dark-grey127.png` 156 -> 143 at 140 pt
out, `verify/B/menu-probe-popup-over-grey-dark.png` 156 -> 142 at 80 pt out).

Headless, scale 2, dark over flat grey 127 (light where marked), plugin built in scratch before / after, 5 px columns:

| item | Mac | before | after |
|---|---|---|---|
| alert top row, middle / 40 pt from the ends (`windows/alert-shown-grey-dark.png`) | 156 / 145 | 155 / 155 | **155 / 144** |
| alert bottom row, same | 155 / 144 | 156 / 156 | **156 / 145** |
| alert, 3 top + 3 bottom rows over +-90 pt every 2 pt: rms / max | | 3.97 / 12.0 | **0.89 / 1.7** |
| alert light (`alert-shown-grey-light.png`): top, bottom; rms / max | 232 / 224, 231 / 224 | flat: 2.81 / 8.6 | **231 / 223, 232 / 225; 0.96 / 2.0** |
| Spotlight list top row over white, middle / 200 pt out | 100 / 89 | 119 / 119 | 119 / 119 |
| same over grey; row 2 | 85 / 73; 83 / 78 | 83 / 83; 76 / 76 | **83 / 78; 76 / 73** |
| Spotlight bar bottom rim over white / grey, middle / 180 pt out | 167 / 156, 118 / 103 | 156 / 156, 112 / 112 | 156 / 151, 112 / 105 |
| Control Center Now Playing, Dock (recipes at 0) | flat | flat | flat (the same pixels) |

- The alert's rim is now the Mac's to the level over the straight part (dark and light). Apple menu rims change by up
  to 14 (not compared: no Mac shot of that menu over a flat backdrop).
- Spotlight's bar bottom rim falls half as far as the Mac's: about a third of it there is the shell's flat QML line
  (`Theme.spotlight.barRimBottom` .093, a fit to the Mac's middle rows, judge #20), left as it is. Over grey the list's
  top row now peaks at the middle (-5 at 200 pt, Mac -12); over white it stays 119 flat (the key lobe is on the face
  before the clamp, where white leaves it no room), Mac 100 / 89: the Mac's dark first row (OPEN-FIXES 17) is not this.

**R8.2 matched, nothing changed.** The held Settings slider knob as it is (Knob `lensDecoded`: face black 0.1, ring
shadow 8 pt down, stroke 4, blur 3, `Tokens.control.sliderLensRingOpacity` .4 dark / .15 light, as the R8.2 dump) over
pure white (a scratch QML scene: Slider with white track, fill and lens backdrop, `_lift` 1, grabbed at 2x), centre
column every 2 px from the lens top:

| | column |
|---|---|
| Mac dark (`cap-dark-held-white.png` x 480) | 255 254 252 248 243 234 224 215 208 **205** 206 211 219 229 238 245 250 253 252 255 |
| ours dark | 255 255 253 249 242 234 224 215 208 **205** 206 211 220 229 238 246 251 255 255 255 |
| Mac light (rows 8-13: the slider's track, not white) | 255 254 254 252 250 247 244 (219 216 215 216 218 220) 245 248 251 253 254 254 255 |
| ours light | 255 255 255 253 251 247 244 240 237 236 236 239 242 246 249 252 255 255 255 255 |

Dark rms 0.93 over the 40 rows (max 3, the Mac's bottom 2 pt); light rms 1.0 on `knob_fit.py`'s rows (max 2). The
Control Center lens (OPEN-FIXES 19), re-measured as judge #21 (my box: rim box from pixels under 75, fill > 170 inside
it): Mac 222.9, ours 217.1 before, 217.8 / 218.4 / 218.5 / 218.6 after (four holds; the lens is QML, the plugin change
does not reach it); fill column 8 px into the box Mac 243 242 235 232 226 222 218 214, ours 235 234 230 226 222 218 215
212. R8.2's stock knob fits our stack, so the CC lens's lighter fill is a Control Center term: the real CC slider was not
dumped (MAC-ANSWERS-8 "Not done").

## 21. After judge #24 (2026-11-15): the dark side line of Notification Center cards and banners; the CC lens fill again

**Side line.** `scripts/motion-capture/nc-side-line.py` (headless, scale 2, dark, three test notifications with a
two-line body; the wallpaper a flat picture). The line is read on the straight rows of a side, the line pixel against
the pixel outside it. A two-line card (56.5 pt) has no straight side: its line splits over two pixels (73 + 92), which
is where round 11's "63, Mac 54" came from; the Mac's own card ramps 98 -> 44 over its curve the same way.

| backdrop | Mac card (stack-dark-*.png, rows 80..108) | ours before, left / right | ours after | Mac banner (shadow-banner-*-dark.png) | ours after |
|---|---|---|---|---|---|
| grey 127 | 99.5 -> 44.5, both sides | 102 -> 40 / 96 -> 36 | 102 -> 46 / 102 -> 45 | 116.5 -> 50 | 115 -> 49 |
| white | 200 -> 70.4 | 206 -> 126 / 192 -> 111 | 206 -> 70 / 203 -> 69 | 233.5 -> 71.5 | 232 -> 72 |
| black | 0 -> 0 | 0 -> 0 | 0 -> 0 | | |
| blue (69,83,206) | (57,65,156) -> (20,24,86) | (56,67,166) -> (16,21,88) | (56,67,166) -> (24,31,93) | | |

1. **The tone.** The decoded dark specular, c (1 + bias (3 - 2 c)) per channel with the fitted -0.278, takes a lighter
   backdrop less far (ratio .38 at grey, .60 at white); the Mac's line goes the other way (.447 at .39, .429 at .457,
   .352 at .784, .306 at .916) and saturates near 72. Least squares on the four grey-axis points of the card and the
   banner: line = Y (0.5493 - 0.2602 Y) on luma (Rec. 709 of the encoded pixel), residuals 0.1 / 1.3 / 0.1 / 1.1
   levels; chroma x 0.62 from the one blue point. `SRecipe::darkToneK0 / K1 / Chroma` on NOTIFICATIONCENTER (and the
   banner recipe from it), dark only, `darkTone` in `liquidglass.frag`. Not decoded: Mac pixels. Regular itself (alert,
   menus, popovers) keeps the decoded tone: their Mac line is known over grey 127 only, where both tones are within 2
   (46 and 48 against 47); OPEN-FIXES capture N1.
2. **The column's dim.** `NotificationCenterWindow.qml` drew the 376 pt frame 50 pt past the screen edge, so the dim
   was flat to the edge. The Mac's (`nc/overview-redacted-dark-white.png` row 5, above the cards) is 207 until 62 pt
   from the edge, then 210 213 217 220 at 42 32 23 17 pt: a Gaussian edge of sigma 26.5 pt one point inside the screen
   edge (27.3 on the left side). The frame now ends at the screen edge: outside a card 102 / 102 over grey (96 on the
   right before), 206 / 203 over white (192).

Files: `plugin/src/Material.hpp`, `Material.cpp`, `GlassElement.hpp`, `GlassElement.cpp`, `plugin/shaders/
liquidglass.frag`, `plugin/tests/test_main.cpp`, `shell/modules/NotificationCenterWindow.qml`. Built into a scratch
dir and loaded with `HYPRK_GLASS_SO`; **`plugin/build` is not rebuilt**.

**Control Center lens fill** (OPEN-FIXES 19). `scripts/motion-capture/cc-lens-fill.py`: against R9.6's screenshot of
the real knob held still (`live/glass-r9/cc-sound-held-dark.png`) ours is the same to the level: per column Mac 238 236
233 230 228 225 222 221 219 217 216 215 214 214 213 213 212 212, ours 239 236 233 230 228 225 222 220 218 217 216 214
214 213 212 212 212 211, mean 220.0-220.6 against 221.0, rms 0.6-1.1 (three holds). The 223-224 the judges compare
with is a video frame of a drag, 5.9 over the Mac's own hold; in `controls/slider-fast-drag-cc-dark.mov` the fill in
the lens reads 231 when first held, 227-230 in the swings and 224 at rest again. Nothing changed; OPEN-FIXES capture
G1 decides whether the drag lightens it. Seen and not changed: our rim's line is 0-5 where it meets the fill's upper
left corner inside the lens (Mac 40-44, three pixels).

## 22. Round 17 (2026-11-15): Spotlight's list edge over a step; the rim line over the veil (MAC-ANSWERS-17.md R17.5)

The long-open first row of Spotlight's list (section 20: 119 flat over white, Mac 100 / 89) is decided by
`live/r17/spotlight-list-top-edge-step-*.png` and the r17 stills (measured in `SPOTLIGHT-27.2.1.md` "Round 17"):

- **Transmitted = the decoded outer refraction**, weights `saturate(d + 1 pt)` (.75 / .25 on the first two 2x rows),
  the sample 0.4 D outward. Two things were missing here. The sample **sees the window's glass above the shape**: the
  mode list's (D 214) lands 86 pt up in the bar's dark top and its first row over white is 100; the results list's
  (D 410) lands 164 pt up, past the bar, and its first row is 165 over the same white. And it leaves along the
  **ovalized normal** (gradientOvalization 0.5, section 20: so not only the key/fill lobes read it): over the black /
  white step the first row shows the step 25-30 pt nearer the shape's middle than the rows under it.
- **Added = a light line above the veil**: `row = .93 x transmitted + 53 / 31 / 9` on the first three rows at the
  middle on every backdrop (the bar's top the same, 57 / 34 / 13 over its .97 veil), falling along x with the ovalized
  normal (-14 at 200 pt). It cannot be the plugin's key lobe as we had it: that sits under the shell's veil and was
  clamped away over white.

Applied: `SRecipe::outerSeesPrior` + `priorVeil` (the other window-shadow groups above this one as `prior*` /
`seenCount`; the sample inside one reads its face x (1 - veil)), the outer sample along `nk` on that recipe, and
`SRecipe::keyTop` 0 (Spotlight only; every other recipe gets `outerSeen` 0 and `keyTop` 1: the same pixels by
construction, not re-shot). The line is the shell's `shaders/spotrim.frag` over its veil (bar top and bottom, panel
top). Dark, 2x, 5 px columns, plugin built in scratch before / after:

| item | Mac | before | after |
|---|---|---|---|
| mode list over white, row 1 middle / 200 pt out; row 2 | 100 / 90; 119 | 119 / 119; 119 | **100 / 88; 121** |
| results over white, same | 165 / 152; 142 | 119 / 119; 119 | **164 / 153; 142** |
| mode list over grey 127, same | 85 / 73; 83 | 83 / 78; 76 | **84 / 71; 82** |
| results over black, rows 1 / 2 / 3 | 68 46 25 | 37 26 17 | **67 44 22** |
| step 124 pt right of the middle, row 1 at 94 / 114 / 124 pt | 92 136 142 | (no lead) | **90 135 143** |
| bar bottom rim over white, middle / 150 pt out | 167 / 158 | 156 / 152 | **167 / 159** |
| bar top rows 1 / 2 | 57 34 | 39 40 | **56 35** |

Left: near the step the interior (rows 3 on) is 8-20 lighter than the Mac's on the black side (the face's blur over a
hard edge, not this edge). `plugin/build` needs a rebuild. Checks: `scripts/motion-capture/spotlight-edge.py`,
plugin `lgtests` (the recipe's flags).

## 23. Round 17 (2026-11-15): a window under a sheet is veiled, not dimmed and not blurred (MAC-ANSWERS-17.md R17.4)

`live/r17/alert-{light,dark}.png` (TextEdit's save sheet, 390 x 318 pt, centred: top 91 pt down a 500 pt window) against
`{in,}active-titlebar-*.png`, exact PNG levels:

| under the sheet | before the sheet | reads | 20 % black would read | veil `0.396 in + 103` / `0.39 in + 12.3` |
|---|---|---|---|---|
| light: document white | 255 | **204** | 204 | 204 |
| light: title "Untitled" | 88 | **138** | 70 | 138 |
| light: the document's black text | 0 | **102** | 0 | 103 |
| dark: title bar | 39,39,44 | **27,28,32** | 31,31,35 | 27.5 |
| dark: white text | 255 | **112** | 204 | 111.7 |

So TextEdit's sheet is the same veil rounds 12 and 13 found under System Settings' sheets (#AAAAAA at 60.4 % light,
#141414 at 61 % dark), and Finder's `finder/sheet-*.png` too (content 204, title 133; ours 204, 133). **The two sets
of evidence do not conflict.** What conflicts is the section's reading "light 255 -> 197 (x 0.77), dark 27 -> 23": 197
is the clip's video level for 204, and one white point cannot tell a veil from a dim. Text and ruler stay sharp: no
blur. The card's shadow is the one fitted in round 13 (right edge 180 of 204, 20 of 25 dark; under it 163-190).

The lights are left out of the veil: close reads what an inactive window's does and minimise and zoom what the active
window's do, to the level (light (242,242,244) (245,203,88) (152,213,111); dark (75,75,79) (243,194,34) (93,189,33),
with the bar around them veiled).

Built: `ui/HyprK/Tokens.qml` `panel.sheetDim` is the veil (was black .20), `sheetShadow*` the round 13 shadow;
`ui/HyprK/Sheet.qml` takes `lights` (holes in the veil over the discs, the window's own set faded out with the sheet, a
second set in the holes with close disabled) and `behind` (drawn without saturation: Settings only, R13);
`settings/controls/SubSheet.qml` keeps only its own fill; `finder/qml/Main.qml` passes the Finder's lights. On screen
(headless, 2x, Finder's Rename sheet): light content 204, title 133, file name 118, shadow right 180 182 182 184,
under 164 164 166 168, lights (241,242,244) (254,200,55) (129,214,90) = the inactive and active tables; dark content
(24,24,26), title 103 (Mac 104), close (73,75,89) (Mac (73,74,87)), shadow right 18-20 (Mac 20).

Which panels: document-modal sheets only (HyprK `Sheet`: Finder's Rename sheet, every Settings sheet, the alert-sheet
form). The app-modal `AlertPanel` (Finder's "permanently erase" alert) is another panel: PopIn, no veil, Cancel's 0.25 s
order-out with its text blur (MOTION-AUDIT "Alert, Round R3.1"); R17.4 holds nothing on it, not changed.

Both points left open here are closed (2026-11-15, LIGHTS-REA section 14):

- The window under a sheet is **main, not key**; nothing takes its saturation away. Settings' sidebar tiles keep .38 of
  their colour spread under the veil (max - min 190 -> 72 light, 194 -> 73 dark; ours was 0) and the dark sidebar its
  blue ((35,37,52) -> (26,26,35); ours (27,27,27)). What goes grey is what follows the key state: the selected row
  (accent -> 171 light, (32,32,39) dark), the sidebar labels (155 / 60 = `labelInactive` veiled), the pane's switches
  (190 -> 13). Finder alike: sidebar icons (151,152,152) / (68,69,75) = `sidebarIconInactive` veiled, "Recents" 145.5 /
  (70,70,75), the header 165.5, while the title stays #4C4C4C (133) and the selected file's label keeps its blue.
  Built: `SettingsApp.underSheet` (sidebar not key), `Sheet.behindLeft` (the saturation filter only right of the
  sidebar: the pane's controls follow the one `Tokens.windowActive` the sheet's own controls need),
  finder `Theme.sheet` / `sidebarKey`. Ours: Finder icons 153 / (68,68,72), text 144 / 71, header 169 / (46,46,51).
- **Dark, the toolbar strip of a window that is not key is 8 levels lighter**: (37,38,39) over the pane's (29,30,32)
  in `settings/desktop-dock-inactive-dark-iconDark.png` (31 while key), and under a sheet (27,27,32) over (24,26,29),
  the same 8 levels through the veil. Ours drew that wash (`Theme.toolbarHoverWash`) only under the pointer: 24 under a
  sheet, `sheet-depth.py` dark "shadow above" 23 against 28. Now also while not key or under a sheet: 26-27.
- The disabled close is the inactive disc, a layer, over the bar as it was: section 14 of LIGHTS-REA.
- Not built: the Mac's dark veil keeps more blue than #141414 at 61 % gives (pane (30,31,36) -> (24,26,29), ours
  24,24,24 with the filter; toolbar blue 32, ours 27); a veil near (20,20,27) fits the three surfaces within 2.

## 24. Round 18 (2026-11-15): the notification side line refitted, the Control Center Sound slider's states (MAC-ANSWERS-18.md R18.2, R18.3)

**Side line (R18.2).** `live/r18/{banner,nc-card}-{dark,light}-{white,blue}.png`: the real two-line card (344 x 57 pt)
over pure white and over pure blue (shown as (0,0,245)). Such a card has no straight side: the line is read on its
middle row and 3 pt above and below (`nc-side-line.py`, the Mac's values read from the stills by the same code).

| middle row, outside -> line | Mac | ours before | ours after |
|---|---|---|---|
| banner, dark, white | 233 -> 79 | 233 -> 83 | 233 -> 81 |
| banner, dark, blue | (0,0,224) -> (0,0,159) | (0,0,224) -> (0,0,143) | (0,0,224) -> (0,0,158) |
| card, dark, white | 203 -> 78 | 206 -> 81 | 206 -> 78 |
| card, dark, blue | (0,0,193) -> (0,0,126) | (0,0,197) -> (0,0,121) | (0,0,197) -> (0,0,130) |
| banner, light, white / blue | 240 -> 176, (0,0,231) -> (0,0,166) | 240 -> 177, 166 | the same (not changed) |
| card, light, white / blue | 209 -> 142, (0,0,201) -> (0,0,134) | 210 -> 143, 135 | the same |
| straight side (section 21): card grey / white, banner grey / white | 44.5 / 70.4, 50 / 71.5 | 46 / 70, 49 / 72 | 44 / 70, 50 / 70 |
| straight side, blue (69,83,206) | (57,65,156) -> (20,24,86) | (56,67,166) -> (24,31,93) | (56,67,166) -> (20,25,95) |

What the stills say: light is the decoded tone c (1 + bias (3 - 2 c)) per channel with the dump's -0.25 (the middle
row of a two-line card has .93 of the line's strength: 240 -> 176). **Dark over blue is the same tone with the same
-0.25** ((0,0,224) -> 158.8, (0,0,193) -> 125.9; the older (57,65,156) -> (20.6, 24.5, 86.8), the Mac's (20,24,86)), and
so is grey 99.5 (44.3). Only a light backdrop is darker in dark (white: 165 by the tone, 71.5 on the Mac): the toned
luma saturates near 0.28. So the round 21 luma curve with its chroma factor is replaced by the decoded tone at -0.25
followed by a limiter of the toned luma Y, x (1 + (Y / 0.278)^4)^(-1/4), fitted on the six grey-axis points (four
straight, two middle rows; residuals -1.8 -1.1 1.4 -1.2 2.3 0.5 levels; the old curve 4.4 on the white banner).
`SRecipe::darkToneCap` 0.278, `darkToneKnee` 4 and `dark.darkBias` -0.25 on NOTIFICATIONCENTER / NOTIFICATIONBANNER,
`darkTone` in `liquidglass.frag`. The limiter is Mac pixels, not decoded (it looks like the glass's max luma acting on
the line; MaxLuma 0.35 itself does not give these numbers in either order). Regular's alert and menus keep -0.278 and
no limiter: no still of them over white or blue.

Left: the blue straight case's blue channel, 95 against 86, is the pixel outside the line (166 against 156: the
panel's dim of that backdrop, not the line; the check judges that case as line / outside per channel, within .03).
Seen on the same stills and not changed: the Mac's top line is lighter than ours (dark over white 161 143 128 126 125
124 from the edge inward against 149 136 121 122 121 122; light over blue 165 150 136 134 133 against 154 142 129 130
129, red channel): about 1.4 x our key band and a soft band of 4-7 levels under it that the recipe has switched off
(`diffuseAmount` 0); the round 11 fit (1.23 x) was read on another card.

**Control Center Sound slider (R18.3).** `live/r18/cc-sound-{dark-dark,dark-blue,light-white,light-blue}-{idle,hover,
held,drag1,drag2,drag3}.png`, lossless stills of the real module. `cc-lens-fill.py` takes the same six states of ours
over the same wallpapers (pointer on the knob, cursor hidden, the drag at 15 pt/s in quarter-point steps).

- **The fill under the lens does not change in a drag.** Per column from the first whole pixel inside the rim, the
  Mac's dark stills: held 238 236 233 230 227 225 222 221 219 217 216 215 214 214 213 213 212 212 212, mean 221.0;
  dragged 220.5 / 220.7 / 220.2; over blue 220.5 held, 220.8 / 220.4 / 220.1; light over white 220.5, 220.3 / 220.5 /
  220.2. The 223-224 of the older picture was the video frame. Ours 218.0-221.0 by where the lens falls in a pixel
  (the Mac's own 220.1-221.4), within 1.5 at the best shift within a pixel. OPEN-FIXES 19 is closed; nothing changed
  in `LensGlass.qml` or `glasslens4.frag`.
- **Light and dark are the same module**: the two blue sets are equal to the pixel in idle and hover (same file
  hash). The module's level follows the wallpaper: 50 over (30,30,32), 106 over grey 127, 186 over white, (24,24,255)
  over blue: 0.125 + 0.604 x luma. Ours already drew exactly these at rest.
- **Hover: the module is 7 levels lighter**, every pixel of it but the white ones (50 -> 57, track 70 -> 77; 24 -> 31;
  186 -> 193), added, not veiled. **Held: about 3.5 % of its own level more** (57 -> 59; over blue 31 -> 32; over white
  193 -> 199..203 round the pointer, 194 at 100 pt). Ours had neither (50 / 70 in all three states). Built:
  `ControlCenter.qml` SliderModule (a plus-lighter layer, `Theme.cc.sliderHoverLift`, `sliderHeldGain` drawn flat).
- **Hover knob shadow**: the module under the knob, per px down, Mac -15 -12 -10 -9 -7 -7 -5 (light over white) and
  -4 -4 -3 -3 -2 -2 -1 (dark); ours -20 -17 -13 -11 -9 -8 -7 and -5 -5 -4 -3 -3 -2 -2 with the shared knob's black .10
  pair. Now x 0.75 (`Knob.shadowScale`, `Theme.cc.knobShadowScale`): -15 -12 -9 -9 -7 -6 -6 and -4 -3 -3 -2 -2 -2 -2.
- **Lens size**: the rim line's centres are 47.7 x 37.5 px apart on the stills (columns 196.5 .. 244 round the fill end
  at 220, rows 61.5 .. 99); ours 46.7 x 38.5 (rows to 100). `Theme.cc.lensW / lensH` 22 x 18 -> 22.5 x 17.5, `lensDy`
  0.5 -> 0.25: 47-48 px, rows 62 .. 99.
- **The lens over the module** (`LensGlass.emptyLevel`, the level its layers are drawn for) was the fixed .42 of the
  grey 127 frames: over white the rim line read 111 (Mac 146) and the lens's upper half 10 too dark. Now the module's
  level from the wallpaper's luma (`Wallpaper.topLuma`) and the lift: rim 142-143, upper half 3-9 under the Mac's,
  lower half 6-11 (the Mac's pointer light under the lens, not drawn); dark: rim 29 (Mac 30-31), inside within 4.

Left: the held module's light is flat (the Mac's is round the pointer, up to +10 over white); over a saturated
wallpaper the lens's rim line is too dark (blue: 52 against the Mac's 77, luma), its layers being grey ones; a window
under the Control Center is not seen by the level estimate.


## 25. After judge #25 (2026-11-15): the sheet's veil keeps the window's tint

OPEN-FIXES items 49-50. The dark veil is (20,22,24.5) at .61, not #141414 (per channel offsets 12.3 / 13.4 / 15.0 on
System Settings' Clock Options sheet and on TextEdit's save sheet, R17.4), and the pane under it loses its accent
colours but not the wallpaper tint (`ui/HyprK/shaders/sheetbehind.frag`). Finder's strip under a sheet takes the hover
wash (27,28,32 through the veil). The close light's (78,78,78) of judge #25 was a grey wallpaper's tint, not a
defect. Checks: `sheet-depth.py` "the veiled window's colour", `finder-live.py sheet`.
