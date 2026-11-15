# Interactive glass: hold shine, knob elasticity, slider-end glyphs (macOS 27.2.1, 26B131)

Round 7 (2026-11-14), for the user's three reports: the hold shine looks boxy, nothing bounces when a slider knob or a
button is dragged fast, slider glyphs never move. Sources: the 27.2.1 dyld cache (`~/Downloads/macos/dyld-27.2.1`, read
with `ipsw dyld disass --cache …a2s` and `ipsw dyld dump`; SwiftUICore / SwiftUI keep Swift symbols, DesignLibrary is
read from `re-work/lights/DL-ipsw.s` with its conformance witnesses parsed from `re-work/ex/DesignLibrary.fixed`),
ControlCenter.app (`re-work/r2/ControlCenter`, `CC.ann`), `ipsw swift-dump` of SwiftUI, and the round 7 Mac clips
(`screens/27.2.1/controls/*`, `settings/appearance/preview-hold-shine-*`; VFR, pts from ffprobe, 2 px per pt). Earlier
decodes reused: GLASS-INTERACTION.md (FlexInteraction presets, glow layers), MAC-ANSWERS.md "SF Symbol effects".
Every value is **decoded** (address; float bytes), **measured** (clip frames) or **not decoded**.

## 1. Hold shine on a glass button

### What the code draws (decoded)
- `FlexCoreInteractionModifier.updateGlow` (SwiftUICore 0x190c24650): glow size `min(1.5 x min(w, h), 160)` (fmov 1.5
  at 0x190c246dc; 160 = 0x4064000000000000 at 0x190c246e4); position = gesture location on a critically damped 0.15 s
  spring (0x3fc3333333333333 at 0x190c2498c); big / little opacity rise on 0.1 s (0x3fb999…, 0x190c247dc), scale 2 beyond
  the dissipation distance (0x190c247bc), released: opacities 0 and scale 4 (0x190c2471c) on 0.5 s.
- `GlowContainer.body` 0x190c1f0c4: two plain `_CALayerView<CALayer>` (type of AttributeGraph body 0x190447c5c:
  `ZStack<(Color, _CALayerView<CALayer>.opacity.frame.scaleEffect.position …)>`), overlaid and clipped (`_ClipEffect<AnyShape>`).
  - BigGlow closure 0x190c1f670: `setName:`, `setBackgroundColor:` gray 1 alpha 1 (fmov 1, 1 at 0x190c1f6cc), filters
    `[vibrantColorMatrix]` backdrop-aware with `YCC(0.05, 1.05, 1.2, 0)` (floats 0x3d4ccccd / 0x3f866666 / 0x3f99999a at
    0x190c1f6f0…0x190c1f70c). Re-read this round: no `cornerRadius`, `mask`, `shadow*` or `contents` call in the closure,
    so by the code it is an opaque **square**.
  - LittleGlow closure 0x190c1f904: pill corner, white shadow radius size / 2, matrix x4 dodge (dark) / x5/3 (light).
- Opacities for the Appearance preview's 37 pt buttons: their glass is DesignLibrary `MacGlassButton`
  (`_Glass.interactive(_:)` at DL 0x195e04770 in sub_195e03b4c, beside `MacGlassButton` / `MacButtonGlassInteractionFill`
  bodies 0x195e03efc / 0x195e03fe8), no variant set, so `Settings(variant: .automatic, size:)` 0x1908b1100: max side < 120
  (0x405e000000000000 at 0x1908b11fc) → `small` with cursor littleGlow 0.2625 (0x3fd0cccccccccccd stored at +0xa0,
  0x1908b1238), bigGlow stays 0.75, spring 0.25 / 0.629 (table 0x191393fa0: 0x3fd0000000000000, 0x3fe420c49ba5e354).
- The disc under the glyph is a separate view, `MacButtonGlassInteractionFill` (DL 0x195e03fe8); its colours were not
  decoded. Decoded in 7 (a ShapeStyle: clear / .quinary / .quaternary by InteractionState).

### What the Mac shows (measured, R7.1b)
`preview-hold-shine-held-{dark,light}.png` (share held) minus rest frame 10 of `preview-hold-shine-share-*.mov`, binned by
distance from the share glyph (76, 72 px), glyph pixels masked:

| distance (pt) | 9-15 (disc) | 18-21 | 30-33 | 48-51 |
|---|---|---|---|---|
| dark R / G / B | +84 / +95 / +90 | +46 / +59 / +68 | +35 / +46 / +54 | +16 / +27 / +36 |
| light R / G / B | +1 / +4 / +6 | +24 / +20 / +9 | +17 / +20 / +6 | +11 / +17 / +2 |

- **No square edge.** Rows 46-63 and 80-97 averaged, x 120-149 px (where a 55.5 pt BigGlow centred at the pointer ends,
  27.75 pt right of it): dark R falls 62.1 → 50.3 smoothly, largest step between neighbouring pixels 1.1 levels; light
  28.3 → 25.6, largest 1.7. The code's square should give a 1 pt edge of about 0.75 x (0.05 + 0.2 chroma) = 5 / 10 / 14
  levels R / G / B before the dodge. So the Mac does not show the BigGlow's edge. Why is **not decoded** (the CA
  vibrant-filter layer path in QuartzCore was not traced); the light still reaches the far end of the capsule (+16..+36 at
  50 pt in dark), so a component covers the whole glass.
- The round, soft disc (radius 13.5-15 pt, edge at x ≈ 103 px) is the button's interaction fill under the dodge: dark
  hover +20 → held +84..+95; light hover −12 (darker) → held +1..+6 while around it is +20 (`Tokens.toolbar.hoverDiscRadius`
  15.9 pt matches).
- Timing: capsule mean 164 → 203 in the first changed frame (0.617 → 0.767 s, no frame between); release 204 → 186
  (+0.1 s) → 170 (+0.25 s) → 165 (+0.5 s): the decoded 0.5 s critically damped fall.

### Why ours is boxy
`glasslens4.frag` main(): `if (glowAmt.x > 0.0) { … cov = clamp(glow.z - max(dv.x, dv.y) + 0.5, 0, 1) … }` draws the
BigGlow as a hard square (1 pt antialiased edge) of half side `ToolbarHighlight.glowHalf` = 27.75 pt at opacity 0.75. On
the share | more capsule (74 x 37) its right edge lies inside "more" and moves with the pointer (0.15 s spring), and it
grows x2 / x4. Nothing else in the path is square: the LittleGlow is a radial LUT, the texture is ≥ 2 px / pt.

### Also seen: toolbar platters (R7.1, side finding)
Finder / Settings Back held (dark, `hold-shine-finder-dark.mov`): hover = disc +19..+21 at once plus the whole capsule
+5..6 over about 0.2 s (rollover); press = disc → +64..+71 and the rest a smooth falloff +36 (18 pt) → +21 (50 pt), the
capsule grows (edges −3 / +2..3 px left / right, −2 / +2 px top / bottom: ≈ +2.75 x +2 pt); the history menu opening does
not change the light; release about 0.25 s. TOOLBAR-REA-27.2.1.md 2 (uniform 0.1 layer, no lift) does not hold here.
Re-measured in the Applied section: the still TOOLBAR-REA 2 read was taken with the history menu already open.

## 2. Elasticity

### Buttons: no velocity bounce (decoded + R7.3b)
- `applyScale` 0x190c225cc: lift `(max + liftPts) / max` and the drag stretch `k = (|d| − |di|) / thr + |di| / (4 thr)`
  (GLASS-INTERACTION.md 3); no velocity term. Cursor `scaleDistanceThreshold` 60000 (small) → +0.13 pt 100 pt past the edge.
- `applyMovement` (below) needs `movementScalePoints > 0`; automatic / small / large / menu / window / windowControl
  have 0 (GLASS-INTERACTION.md 2), so buttons never deform with speed. R7.3b: no stretch, no release bounce on the preview
  capsule, Finder Back or a CC tile. Keep `PressSpring` as is.

### Slider / switch knob lens: FlexInteraction `liquidLens`, driven by acceleration (decoded)
- DesignLibrary sub_195e18154 (the Mac linear slider knob: `anchorPreference(Slider.KnobKey)`, next to
  `MacLinearSliderKnob.body` 0x195e17a48): `flexInteraction(configuration: Configuration(behaviors: .all, variant:
  .liquidLens (0x195e18830), activation: state ∈ {pressed, deeplyPressed} ? .alwaysActive : .inactive (0x195e18834 …
  0x195e18864), sources: same ? [.movement] : [] (0x195e18884)), viewFrame: nil, isEnabled:
  FlexiGlassMacOS.isEnabled && !_CFMZEnabled() (0x195e18938…0x195e18948))`. `InteractionState` = idle, disabled,
  rollover, pressed, deeplyPressed (swift-DesignLibrary.txt 4667). Same call in sub_195e36f74 (switch knob, referenced
  from 0x195e35dfc) and sub_195e2c274 (segmented selection, with `flexInteraction(state:)`).
- `Settings` liquidLens branch 0x1908b139c: `t = clamp((min(w, h) − 37) / 33)` (0xc042800000000000, 0x4040800000000000);
  cursor set: glows 0, lift 0, distThr 0 (0x1908b14cc, 0x1908b14ec), movementNormalizationFactor `2000 + 500 t`
  (table 0x191393f50 / f60: 0x407f40…, 0x409f40…), movementScalePoints `2.5 + 22.5 t` (0x4036800000000000 at
  0x1908b14d4, fmov 2.5 at 0x1908b14e4), min scale `0.9 − 0.15 t`, max `1.1 + 0.05 t` (0x3feccccccccccccd /
  0xbfc3333333333334, 0x3ff199999999999a / 0x3fa9999999999980), spring response `0.444 + 0.056 t`, damping
  `0.56 + 0.44 t` (table 0x191393f70 / f80: 0x3facac083126e978, 0x3fdc28f5c28f5c28, 0x3fdc6a7ef9db22d1,
  0x3fe1eb851eb851ec), tracking damping `0.56 + 0.34 t`. Our lenses (25 x 20, 24 x 20) give t = 0: **norm 2000, ±2.5 pt,
  0.9 … 1.1, spring 0.444 s / 0.56**.
- Input: `ResolvedMovement.updateValue` 0x190c2128c feeds the view position to `VelocityIntegrator<AnimatablePair>`
  `addSample(_:timestamp:)` and outputs `Movement { acceleration x, y; velocity x, y }` (0x190c21344 / 0x190c21350 /
  0x190c21368). `setupIntegrator` 0x190c21010 builds it with an `EMAFilter`; constants 0.0025 (0x3f647ae147ae147b,
  0x190c21038) and 0.3 (0x3fd3333333333333, 0x190c210c4), roles **not decoded**.
- `applyMovement` 0x190c22a70, per axis (x shown, y swaps the axes): `m = accel.x / norm` (fdiv 0x190c22af0); range per
  axis from `movementScaleRange` 0x1908b1ec0: `lo = max(minScale, (dim − pts) / dim)`, `hi = min(maxScale, (dim + pts) /
  dim)`; `sx = softClamp(1 + m (hi_x − 1))`, `scale.x += sx − 1`, `shift.x += w (1 − sx) / 2 · sign(velocity.x)`;
  `scale.y += softClamp(1 + m (lo_y − 1)) − 1`. `softClamp` 0x190c24b74: inside [lo, hi] unchanged, outside
  `edge + k tanh(0.55 (x − edge) / k)`, k = (hi − lo) / 3 (fmov 3 at 0x190c24b88, 0.55 = 0x3fe199999999999a): at most
  1.167 / 0.833. Then the scale springs (updateEffect, 0.444 / 0.56: about 12 % overshoot).
  So speeding up to the right widens the lens and flattens it, slowing down (or the stop at an end) narrows it, and the
  tail side moves by half the growth.
- Measured (R7.2 `slider-fast-drag-settings-dark.mov`): at the fling's stop at the minimum end (3.050-3.117 s) the lens is
  about 26-27.5 x 18 pt against 25 x 20 at rest (by eye on the zoomed frames; the lens edge is too faint for a clean
  per-frame fit).
- Follow: **no spring**. `MacLinearSlider` (sub_195e13cf4) only adds `.animation(reduceMotion ? nil : .spring(response:
  0.25, dampingFraction: 0.75), value: isPressed)` (fmov 0.25 / 0.75 at 0x195e14884, isPressed = state − 3 < 2 at
  0x195e148bc): it animates the press change, not the value. R7.2: the fill catches the pointer within one frame after
  the fling (3.000 s fill 92.5 pt, cursor 20.5 + grab 10.5; 3.033 s fill 32.5): the 30-40 pt "lead" at the turns is the
  cursor drawn ahead of the content at 1000-1800 pt/s, not a spring.
- CC rubber band past an end: **not decoded**. Searched: DesignLibrary `Slider`, `BaseSlider`, `SliderGesture`,
  `SliderGestureState { geometry, knobOffset, trackValue, previousLocation, … }` (no stretch field), SwiftUI / SwiftUICore
  symbols `rubber*` (only ScrollView, SwipeActions, DigitalCrown), a float survey of DL 0x195dce000…0x195dd26ec (none).
  Next: the CC `SolariumSlider` `_scrollState` (`ControlCenterCore.SliderScrollState`, field `distance`) and the
  `DesignLibrary.Slider` gesture closures in the Mac session. Q-panels-09's fit (5 pt, 0.13 s) stays.

## 3. Slider-end glyphs

- Control Center's slider is `ControlCenterUI.SolariumSlider` (View witness → 0x1005ffc80 → body 0x1005feac4), which
  builds the public `SwiftUI.Slider(value:in:step:neutralValue:enabledBounds:label:currentValueLabel:minimumValueLabel:
  maximumValueLabel:ticks:onEditingChanged:)` with the glyphs as minimum / maximum value labels.
- SwiftUI renders it as `LabeledSlider<StaticIf<…, MacUnbridgedSlider, DesignLibrarySlider<…>>>` with
  `PlatformSliderStyle.SymbolEffectState { minimumValueLabelSeed: UInt32, maximumValueLabelSeed: UInt32 }` (swift-dump).
- Trigger, `DesignLibrarySlider.body` closure `(Double, Double)` 0x19abe679c (onChange of the value): only while
  `isTracking` (LazyState, 0x19abe6814); new value == 0.0 → `minimumValueLabelSeed += 1` (0x19abe6888…0x19abe6898);
  == 1.0 → `maximumValueLabelSeed += 1` (0x19abe68a0…0x19abe68b4). So it fires once each time a drag brings the value
  onto an end; holding there or pulling further does not repeat it.
- Effect, `LabeledSlider.body` closure 0x19a9e7c0c: each label gets `.symbolEffect(BounceSymbolEffect()` (default
  `.bounce`, 0x19a9e80a0 / 0x19a9e8264), `options: .default` (0x19a9e8120), `value: seed)` through
  `_DiscreteSymbolEffectModifier<UInt32>` (0x19a9e80bc; max seed = high word, 0x19a9e8270).
- Engine (MAC-ANSWERS.md SF Symbol effects, RenderBox): bounce 0.70 s, segments 0.21667 / 0.21667 / 0.15, outro
  0.26667, 0.05 s per layer; raw keyframes 1.109 / 0.909 (their meaning not decoded).
- Measured (R7.4 `slider-icon-ends-cc-sound-dark.mov`, speaker.fill at 0, ink > 200): 18 x 26 px at rest → 23 x 33
  (x1.27) at about +0.22 s → 16 x 24 (x0.91) at +0.45 s → 18 x 26 at +0.6 s. The visible peak is larger than the raw
  1.109.
- Settings' Sound slider keeps static glyphs (Mac note R7.4; its glyphs are not Slider value labels, not traced).
- Variable value: the CC Sound glyphs stay `speaker.fill` / `speaker.wave.3.fill` here; the HUD and menu extra rules are
  in MAC-ANSWERS.md (wave.1 / 2 / 3 at 0.333 / 0.667).

## 4. Plan (Mac items only)

1. **Hold shine** (`ui/HyprK/shaders/glasslens4.frag`, main): BigGlow coverage `cov = 1.0` over the glass (drop the
   square test); keep opacity `glowAmt.x` and the matrix; rebuild the .qsb. `ToolbarHighlight.glowHalf` then sizes only the
   LittleGlow. Check against `preview-hold-shine-held-*.png` with the table in 1 (neighbouring-pixel step < 2 levels at
   27.75 pt, falloff within ±5 levels per bin). Light mode's darker disc (`MacButtonGlassInteractionFill`) is not
   decoded: leave `hoverLift` 0 there. Toolbar platters (1, side finding) are a separate change.
2. **Knob elasticity** (`ui/HyprK/motion.js`, `Knob.qml`; Slider and Switch pass nothing new): add `liquidLensSet(w, h)`,
   `movementRange`, `softClamp` and `movementScale(ax, ay, vx, vy, w, h)` exactly as in 2; in Knob, while `lift > 0` run
   a FrameAnimation that samples (cx, cy), derives velocity and acceleration (EMA 0.3 per frame: inferred from the
   constant), and drives two Springs (response 0.444, damping 0.56) to sx / sy, plus the shift; apply as a Scale about
   the knob centre and a Translate on the lens (body and LensGlass), identity at rest and under Reduce Motion. No follow
   spring, no button change.
3. **End glyphs** (`ui/HyprK/Slider.qml`, `ControlCenterSlider.qml`, `ControlCenter.qml` slider modules ~391/399,
   `CcSoundPanel.qml` 51-60): Slider emits `hitMin()` / `hitMax()` when `_dragging` and `_dragValue` becomes `from` /
   `to`; new HyprK `SymbolBounce` scale animation on the glyph's centre, 1 → 1.27 (0.22 s) → 0.91 (0.45 s) → 1 (0.6 s);
   enabled only for Control Center (`endBounce: true` in ControlCenterSlider), not Settings / Finder.

## 5. Decoded this round (2026-11-14, applying the plan)

- **The movement source** (SwiftUICore `VelocityIntegrator<AnimatablePair>`): `setupIntegrator` 0x190c21010 sets
  +0x10 = 0 (a distance threshold), +0x18 = 5 (window samples), +0x20 = 0.0025 (minimum sample interval, s), +0x28 =
  false (window-average mode off), +0x30 = 0 (no maximum age), three `EMAFilter`s (+0x48, +0x70, +0x98, each alpha 0.3 at
  +0x10) and a magnitude closure at +0x38 (0x190c2127c: `fabs` of the pair). `addSample(_:timestamp:)` 0x190c15eb0: drops a
  sample < 2.5 ms after the last (0x190c15fcc); position → EMA 1 (0x190c160b8); first sample: stored, no output
  (0x190c16148); velocity = (filtered p − last p) / dt (0x190c16360, flag off: not the 5-sample window) → EMA 2
  (0x190c1640c); acceleration = (|v| − |v last|) / dt per axis (0x190c16504: the closure on both, 1 / dt at 0x190c16568)
  → EMA 3 (0x190c1660c). `EMAFilter.update` 0x19091c308: `value = value.scaled(1 − α) + x.scaled(α)` (0x19091c404 …
  0x19091c458), the first sample taken as it is (0x19091c4b4). So `a > 0` while the knob speeds up either way, `< 0`
  while it slows down; the three filters put a stop's negative acceleration about four 60 Hz samples late.
- **applyMovement** 0x190c22a70 re-read: as in 2 (scale x += softClamp(1 + m (hi_x − 1)) − 1, offset x += w (1 − a) / 2
  · copysign(1, v.x) at 0x190c22c34…0x190c22c54, scale y += softClamp(1 + m (lo_y − 1)) − 1; then the y axis with the
  axes swapped, 0x190c22c8c…0x190c22d54). `softClamp` 0x190c24b74: below `lo` it returns `lo + k tanh(0.55 (x − lo) /
  k)`, above `hi` `hi + k tanh(0.55 (x − hi) / k)`, k = (hi − lo) / 3 (the slope drops from 1 to 0.55 at the edge).
- **CC rubber band**: `ControlCenterCore.SliderScrollState` (types-CC.json: axis, baseline, bounds, value, xFlip, yFlip,
  onEditingChanged, distance) is the scroll-wheel state, not a stretch. Still **not decoded**; the Q-panels-09 fit
  (5 pt, 0.13 s, measured) stays and nothing new was added.

## 6. Applied (2026-11-14)

Headless session, scale 2, Settings / Finder / shell from the working tree; Mac numbers from the round 7 clips (VFR,
ffprobe pts), ours from grim crops or mcap frame series at the same crop and 2 px / pt. Scripts and frame dumps in
the agent scratch (deleted after measuring).

**1. Hold shine** (`ui/HyprK/shaders/glasslens4.frag` main: the BigGlow covers the glass, no square test; .qsb rebuilt,
GLSL 150 / 300 es / HLSL 50 / MSL 12). Settings > Appearance preview, share held still 0.6 s, held − rest by distance
from the share glyph (R / G / B, glyph and pointer masked; the Mac's held frame 38 (dark) / 39 (light) − frame 10 of
`preview-hold-shine-share-*.mov`):

| | 9-15 pt | 18-21 | 30-33 | 48-51 | max step at the old edge |
|---|---|---|---|---|---|
| Mac dark | +81 / 92 / 93 | +48 / 61 / 70 | +35 / 47 / 56 | +17 / 28 / 38 | 2.0 |
| ours dark before | +77 / 87 / 83 | +47 / 59 / 67 | +30 / 38 / 43 | +17 / 23 / 29 | 4.5 (the square) |
| ours dark after | +77 / 87 / 83 | +47 / 59 / 67 | +37 / 50 / 58 | +23 / 35 / 44 | 1.0 |
| Mac light | +2 / 5 / 7 | +23 / 20 / 9 | +17 / 20 / 6 | +11 / 17 / 2 | 2.3 |
| ours light before | +22 / 15 / 5 | +20 / 16 / 5 | +10 / 12 / 4 | +5 / 7 / 1 | 4.2 (the square) |
| ours light after | +22 / 15 / 5 | +20 / 16 / 5 | +17 / 17 / 4 | +12 / 18 / 1 | 0.5 |

Dark 48-51 is +6 over: our rest capsule there is 13-17 levels brighter than the Mac's (140 / 169 / 192 against 123 /
153 / 179); held / rest is 1.16 / 1.21 / 1.23 against the Mac's 1.14 / 1.18 / 1.21. Light 9-15: the Mac's darker
interaction disc (`MacButtonGlassInteractionFill`) is still not decoded and not drawn.

**1b. Toolbar platters** (Settings back / forward, Finder's capsules; `ui/HyprK/ToolbarHighlight.qml`): the platter is
one interactive NSGlassEffectView, so the whole capsule is one FlexInteraction entry: lift by `pressScale(74, 36)` about
its centre (+2.5 x +1.2 pt) and the press glow sized by the capsule (ultraSmall preset, 54 pt), no even layer
(`platterPress` no longer driven). TOOLBAR-REA-27.2.1.md 2 was read off `settings/toolbar-backforward-rest-hover-press
-dark.png`, whose pressed panel already has the history menu open (the menu's top shows under it); the clips show the
lift ending and the capsule lighting evenly only once that menu opens (`hold-shine-settings-dark.mov` frame 40, 1.383 s:
146 px wide, +19 flat). Ours has no history menu (not built), so the pre-menu state holds while pressed.
- Settings Back held, dark, rims rest → held: Mac −3 / +3 px left / right, −1 / +1..2 px top / bottom; ours before 0 / 0 /
  0 / 0, after −3 / +2..3, −1 / +1..1.5. Finder Back: Mac −3 / +3, ours after −3 / +3..4.
- Press light, held − hover by distance from the pointer (R): Mac +37 / +25 / +21 / +15 (9-15 / 18-21 / 30-33 / 48-51 pt;
  B +52 / 37 / 30 / 20, the bluish face); ours before +18 flat; after +35 / +27 / +23 / +18 (B +38 / 30 / 26 / 20).
- Light: the Mac's pressed face goes to 255 end to end; ours before darkened to 229 (the layer's −0.25 bias), after 255.

**2. Knob elasticity** (`ui/HyprK/motion.js` liquidLensSet / movementRange / softClamp / movementScale /
movementSample, `ui/HyprK/Knob.qml`; Slider and Switch pass `pressed`): sampled per frame while pressed, the deformation
on four springs (0.444 s, 0.56) changes the knob's geometry (width, height, x, y), so the lens re-samples under its new
shape. No follow spring (the fill already follows the pointer 1:1), no button change, no segmented change (ours is
AppKit's NSSegmentedControl: no lens knob). Check: the Mac's knob path in `slider-fast-drag-settings-dark.mov` (lens
centre per frame, 0.917-3.15 s) replayed at 60 Hz as the pointer on our Desktop & Dock > Size slider (same 200 pt
track), mcap 60 fps, lens width (dark rim to rim) per frame:
- Mac 24.0 … 30.0 pt (26.5 held still): wider while it speeds up or just after a start (28.5-29.5), 24-24.5 about 0.15-
  0.25 s after a stop, 30 after the fling stops at the minimum end.
- Ours before: 26.5 throughout (rms 1.60 pt against the Mac, max 3.5). After: 23.0 … 29.5, rms 0.73 pt (best shift
  −12 ms, max 2.5 at a frame where the Mac's content stalled), e.g. the stop at the right end 24.0 Mac / 23.5 ours, the
  fling's end 30.0 / 29.5.

**3. End glyphs** (`ui/HyprK/Slider.qml` `endReached`, `ui/HyprK/SymbolBounce.qml`, `motion.js` symbolBounce;
`shell/modules/ControlCenter.qml` Display / Sound modules, `shell/modules/CcSoundPanel.qml`): the bounce fires once when a
drag brings the value onto an end. Curve: the decoded segment times 0.21667 / 0.21667 / 0.15 s with a smoothstep in each,
peak / trough fitted on the clips' ink height (t0 free): speaker.fill 1.27 / 0.89 (rms 0.015), speaker.wave.3.fill 1.21 /
0.87, sun.min.fill 1.21 / 0.86, sun.max.fill 1.23 / 0.86 (rms 0.015-0.023); linear segments fit worse (0.028). The ink
centre stays put (scale about the centre). The Mac's t0 is 0.067 s before its fill reaches 0 (the CC fill shows the
volume read back); ours fires when the drag sets 0. Check, CC Sound dragged to 0 (mcap): before no bounce (rms 0.138
against the Mac's frames); after peak 1.28 / 1.26 (w / h) at +0.22 s, trough 0.89 / 0.85 at +0.43 s, 1 at +0.55 s; rms
0.016 against the curve (t0 = the frame the value hit 0) and 0.028 against the Mac's frames (1 px = 0.04 at this size).
Settings' Sound and the Appearance slider keep static glyphs. Guess: a second trigger within 0.58 s restarts the bounce
(the Mac's queueing was not captured); Reduce Motion: no bounce (not recorded on the Mac).

## 7. The button's interaction fill (2026-11-15, judge #21: light's darker disc)

**Decoded.** `MacButtonGlassInteractionFill` is a struct with one field, `interactionState: InteractionState`
(`ipsw swift-dump` of DesignLibrary from the 27.2.1 cache), conforming to `ShapeStyle` with `Resolved = AnyShapeStyle`.
The MacGlassButton body fills the button's `ResolvedControlBorderShape` with it, under the label
(`FillShapeView<ResolvedControlBorderShape, MacButtonGlassInteractionFill, …>` in the body type). Its `resolve(in:)` is
the witness `sub_195e04fe8` → `sub_195e04f60`: InteractionState byte (`idle 0, disabled 1, rollover 2, pressed 3,
deeplyPressed 4`) < 2 → `Color.clear`; 3 or 4 → `HierarchicalShapeStyle.quaternary`; otherwise (rollover) →
`.quinary`. What the two levels resolve to on this glass was not traced (SwiftUICore
`HierarchicalShapeStyle._apply(to:)` 0x190af6f78 reads the environment).

**Measured** (`preview-hold-shine-share-{light,dark}.mov`, rest frame 10, hover frames 25-38, the same clip so its video
levels cancel; 2 pt rings from the share glyph's ink centroid, ink masked): the rollover disc is flat to 14 pt, half at
14-16, gone at 16-18; light −21 / −22 / −24 on (217, 231, 246) = black .097 over it on every channel; dark +20 / +18 /
+16 on (140, 156, 170) (the 23.09.23 recording: +19 / +20 / +20, `Tokens.toolbar.hoverLift` 19.5). Held: the clip
jumps from hover to the full press light between two frames, so the pressed level cannot be read alone; the held disc
is within 2 of ours in dark with the rollover value kept (9-13 pt +75..80 against ours +77), and in light the same
value kept gives the held clip frames' level (below). So one value per appearance, rollover and pressed alike
(`Tokens.toolbar.glassButtonFill`: dark +19.5 added, light black .097 over; `ToolbarHighlight.hoverFill`, set by the
Appearance preview only: AppKit's toolbar platters are a different fill, `GlassInteractionFill` in AppKit, not
decoded, and keep `hoverLift`). Shader: `glasslens4.frag` disc.w < 0 multiplies by 1 + disc.w (black over), .qsb
rebuilt (GLSL 150 / 300 es, HLSL 50, MSL 12).

The held still PNG reads 5-12 levels brighter than the clip's frames on parts the light does not reach (search capsule,
photo, card), so held PNG − rest frame 10 (the tables in 1 and 6, judge #21's +9 / 8 / 8) carries that bias; the
comparison below is clip frame − clip frame for the Mac and grim − grim for ours (headless, scale 2, Settings >
Appearance, light, share held still 0.7 s):

| light, R / G / B | 9-13 pt (disc) | 18-21 | 30-33 | 48-51 |
|---|---|---|---|---|
| Mac hover | −21 / −22 / −24 | 0 | 0 | 0 |
| ours hover before / after | 0 / **−22 / −23 / −24** | 0 | 0 | 0 |
| Mac held (clip, first held frame → 0.4 s later) | −11 / −9 / −7 → −4 / 0 / +3 | +24 / 20 / 10 | +17..19 / 20 / 6..7 | +14..17 / 17..20 / 5..6 |
| ours held before | +18 / 13 / 3 | +23 / 18 / 8 | +17 / 17 / 3 | +14 / 18 / 3 |
| ours held after | **−4 / −2 / 0** | +23 / 18 / 8 | +17 / 17 / 3 | +14 / 18 / 3 |

Dark unchanged (the same +19.5). Left: our disc's edge sits about 1 pt further out than the clip's (−16 at 14-16 pt
against −7); the radius 15.9 is the 23.09.23 recording's.

## 8. The preview's Search capsule (2026-11-15, user: the Mac's search button shines, ours does not)

**Measured** (`settings/appearance/preview-hold-shine-search-{dark,light}.mov`, pointer on the capsule's centre at
about 0.8 s, held 2 s; mean over the capsule's inside, frame - rest frames 5-9): nothing while the pointer is only over
it (after the release, still hovered: 0 / 0 / 0, so no interaction fill disc), and the press light at once: dark
+35 / +40 / +43 (R / G / B), light +17 / +19 / +14, from one frame to the next, falling over about 0.4 s after the
release (the 0.5 s critical fall). Along the capsule, by distance from the pointer (dark R): 15 pt +60, 25 +50, 35 +37,
45 +24, 55 +14: the share button's falloff (section 1: +48 / +35 / +17 at 18-21 / 30-33 / 48-51 pt).

**Ours before**: no light at all on the Search capsule (`settings/panes/Appearance.qml`: the ToolbarHighlight was
`enabled` only for the two button capsules, "the Search field has no reading").

**Applied**: the capsule takes the press light and no hover disc (`hoverFill` 0). Its glass is 128 x 37, over 120 pt,
so `Settings(variant: .automatic, size:)` gives the plain `small` set (LittleGlow 0.75); with that ours read dark
+60 / +67 / +63, far over the clip. With the 37 pt buttons' fitted LittleGlow (0.405, section 6 / GLASS-INTERACTION 14;
`ToolbarHighlight.littleOpacity`, new) ours reads **dark +35.4 / +40.4 / +43.4** (Mac +35.4 / +39.9 / +42.9) and light
+14 / +16 / +9 (Mac +17 / +19 / +14; near the pointer +24 / +24 / +22 against +25 / +24 / +23). So the capsule lights
like the buttons: either its interactive glass entry is under 120 pt (the field inside the capsule), or the small set's
LittleGlow needs the same factor as the ultraSmall one (0.405 / 0.2625 fitted against decoded). **Not decoded** which.
Left: ours falls off less toward the far end (dark at 55 pt +26 against +14, light +16 against +8): our BigGlow covers
the whole glass evenly (section 1).

The Finder toolbar's closed Search button keeps its hover pill and no press light: no Mac clip holds it (the R7.1 clips
hold Back). Needs the Mac.

## 8. Slider end glyphs, re-measured (2026-11-15: "these 6 icons do not animate")

The six: Settings > Appearance's Liquid Glass slider (capsule.on.rectangle.liquid.glass / capsule.on.rectangle.fill),
Control Center Display (sun.min.fill / sun.max.fill) and Sound (speaker.fill / speaker.wave.3.fill). Edges read per
frame, sub-pixel (threshold crossing of a 3-10 px wide mean), from `slider-icon-ends-cc-{sound,display}-dark.mov` and
the user's 23.09.23 recording of Settings > Appearance (dark, 976 px, about 57 fps).

**What the Mac does** (all six alike; nothing else moves):
- While the knob is dragged between the ends the glyphs do not change: no wave count, no ray change, no scale (Sound
  0.5-1.1 s and 2.6-3.1 s: boxes 18 x 26 and 41 x 30 px constant; they only shift 1.5 pt with the pressed module).
- When a drag brings the value onto an end, that end's glyph bounces once (section 3's seed rule). Holding there,
  pulling further past the end or the lens's stretch do not repeat it. A slow drag and a fast slam give the same
  bounce (R7.2 / R7.4 clips: nothing else on the fling).
- The bounce runs BY LAYER about the symbol's ink centre: each layer the curve of section 6.3 (peak at +0.217 s,
  trough at +0.433 s, rest by +0.58-0.65 s), each layer 0.05 s after the one before:

| glyph | layer 0 (first) | later layers |
|---|---|---|
| sun.max.fill (CC, at 1) | disc r 7.5 -> 9.3 px (1.24), trough 6.8 (0.907), peak at 1.608 s of the clip | rays' outer end 16.2 -> 20.4 (1.26), trough 14.4 (0.89), peak at 1.658 s (+0.05) |
| sun.min.fill (CC, at 0) | disc r 7.7 -> 9.6 (1.247), trough 7.0 (0.91), peak 3.60 s | rays 14.8 -> 18.5 (1.25), trough 13.15 (0.89), peak 3.65 s (+0.05) |
| speaker.wave.3.fill (CC, at 1) | speaker (its trough at 1.55-1.68 s) | outer wave 19.5 -> 24.5 px from the centre (1.26), trough 18 (0.92) at 1.70-1.75 s: 0.11-0.16 s after the speaker over three layers; the HUD's 0.04 / 0.10 / 0.16 (MOTION-REA R11.4) |
| speaker.fill (CC, at 0) | one layer: 1.27 / 0.89 (section 6.3) | |
| capsule.on.rectangle.fill (Appearance, at 1; frames 2488-2527) | the capsule: right edge +3.95 px of 15.55 (1.257), bottom 1.266, peak at +0.167 s; trough 0.897 | the rectangle: top 1.25, left 1.257, peak at +0.20-0.23 s (+0.05); trough 0.90 / 0.89 |
| capsule.on.rectangle.liquid.glass (Appearance, at 0; frames 2228-2262) | the capsule: right 1.23, bottom 1.24; trough 0.90 / 0.906 | the rectangle: top 1.24, left 1.25, 0.05 s later; trough 0.906 / 0.92 |

  So section 6.3's whole-glyph amplitudes (1.21-1.23 / 0.86-0.87) were the envelope of staggered layers, and its
  "the Appearance slider keeps static glyphs" was wrong: the recording shows both ends bounce. Settings > Sound's
  output slider stays static (R7.4; an AppKit slider, not traced).

**Ours before** (headless MBA, real pointer drags through `scripts/vptr`, mcap 60 fps):
- Control Center Sound: `endReached` did fire on a live drag, slow (40 moves) and fast (2 moves); the glyph bounced as
  one piece (speaker.fill 27 -> 34 -> 24 px). The waves did not trail the speaker.
- Control Center Display: on a machine without a backlight class device (this PC) `Brightness.available` is false, the
  slider is disabled and cannot be dragged, so the suns never move. With a backlight: one piece, as Sound.
- Appearance: no bounce at all (no `endReached` handler; the glyphs were plain SfSymbols).

**Applied**: `motion.js` symbolBounceLayerOf / symbolBounceLayers / symbolBounceStagger (0.05) and 1.25 / 0.90 per
layer for the multi-layer glyphs; `SymbolBounce.scales` (one scale per path); shell `Symbol.layerScales` (one image per
path of the same SVG while a bounce runs, about the ink centre; `sf.js` `url(..., only)`), HyprK `SfSymbol.layerScales`;
`ControlCenter.qml`, `CcSoundPanel.qml` and `settings/panes/Appearance.qml` (two SymbolBounce, the slider's
`endReached`). `HYPRK_BRIGHTNESS_STUB=1` gives test sessions a made-up backlight.

**Ours after** (same captures): sun.max.fill disc 1.253 / 0.907, rays 1.264 / 0.893 and 0.05 s later, peak to trough
0.217 s (Mac 1.24 / 0.907, 1.26 / 0.89, +0.05 s); Appearance at 0: capsule 1.23 / 0.85, rectangle 1.23-1.25 / 0.85-0.88
later (1 px = 0.07 at this size; Mac 1.23-1.25 / 0.90-0.92); the speaker leads its waves. Slow drag and slam alike, all
six. Checks: `scripts/motion-capture/slider-glyphs.py` (live, 8 cases), `settings/tests/tst_appearance.qml`
test_b1_glass_end_glyphs_bounce, `ui/tests/tst_controls.qml` test_symbol_bounce_by_layer.

**Not known**: the layer of the liquid.glass glyph's third path (the rectangle seen inside the capsule; taken with the
rectangle); the Display slider on a Mac whose display has no brightness control; Reduce Motion (not recorded).
