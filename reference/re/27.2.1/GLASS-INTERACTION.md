# Liquid Glass interaction, macOS 27.2.1 (26B131): what the code says

Round "glass interaction" (2026-11-12). Sources: the 27.2.1 dyld cache (`~/Downloads/macos/dyld-27.2.1`, read with
`ipsw dyld symaddr / disass / dump`; SwiftUICore keeps its Swift symbols, so every address below is named), the
restore image's system DMG `141-12228-174.dmg` (`System/Library/FeatureFlags/Domain/SwiftUI.plist`, one file extracted
with 7z), the existing decodes in this folder and `MAC-ANSWERS.md`, and the user's recording 23.09.23 (Settings >
Appearance, dark, 60 fps; frames read in scratch only, never kept). Frame numbers of the recording here are the
decoder's **passthrough** index (2886 frames; earlier sessions counted a constant-rate decode of 3063 frames, so
their "frame 196" is not this one).

Every value is marked **decoded** (address), **measured** (recording frames) or **unknown**.

## 1. Who does it: FlexInteraction ("FlexiGlass")

- Feature flags `flexiGlassMacOS` and `flexiGlassMacOSPointer` are `DevelopmentPhase = FeatureComplete` in
  `FeatureFlags/Domain/SwiftUI.plist`: on in 27.2.1 (decoded). AppKit reads `flexiGlassMacOS` too (string
  `AppKit.FlexiGlass`, `_NSEnableFlexiglass`, `NSMenuDisableFlexiglassForKeynote`).
- SwiftUI API: `_Glass.interactive(_:variant:sources:)` 0x190e82828 / `interactive(_:configuration:)` 0x190e82a30 →
  `FlexInteraction.Configuration { behaviors, variant, activation, sources }`.
  - `Behaviors` (OptionSet): `flex`, `lift`, `glow` (decoded, getters 0x190c2b2f4 / 0x190c2b2f8 / 0x190c17050).
  - `Sources`: `interaction` = 1, `movement` = 2, `all` (0x190c16fc4 / 0x190c16fe0).
  - `Activation`: automatic 0, inactive 1, uponInteraction 2, alwaysActive 3.
  - `Variant` (byte): automatic 0, ultraSmall 1, small 2, large 3, (4 = an internal case that `Settings.init` maps to
    `smallLoupe`), loupe 5, liquidLens 6, menu 7, windowControl 8, window 9 (getters 0x190c16a5c…0x190c16a8c).
- The effect itself: `FlexCoreInteractionModifier` (`Value.updateEffect` 0x190c21748, `applyScale` 0x190c225cc,
  `applyScalePulse` 0x190c22878, `applyMovement` 0x190c22a70, `updateGlow` 0x190c24650, `GlowContainer.body`
  0x190c1f0c4); the result is a `PlatformGlassInteractionState { scale: CGSize, translation: CGSize, isActive, anchor:
  UnitPoint }` (0x190e822e8) that the glass layer applies. So the "liquid" deformation is a non-uniform scale plus a
  translation about an anchor, animated by `FluidSpringAnimation` springs (response / damping fraction).
- DesignLibrary (`MacColorSliderKnob`, `MacSegmentedControlComposer`) holds a `PlatformGlassInteractionState` as
  `flexState`; `DesignLibrary.FlexInteraction { stateBinding, isActive, lensFrame }` passes a lens frame. The macOS
  linear slider knob (`MacLinearSliderKnob`) and the switch (`MacSolariumSwitch`) do **not** hold one: their press look
  is DesignLibrary's own (switch: `MAC-ANSWERS` Verify A 3; slider: B2 1).

## 2. Parameters (decoded)

`FlexInteraction.Settings` = two `ParameterSet`s, `touch` (offset 0) and `cursor` (offset 0x90), 18 CGFloats each, in
this order (getter offsets 0x00…0x88): associatedDimension, bigGlowOpacity, littleGlowOpacity,
littleGlowDissipationDistance, liftScalePoints, scaleDistanceThreshold, movementNormalizationFactor,
movementScalePoints, movementMinScale, movementMaxScale, interactionPulseNormalizationFactor,
interactionPulseScalePointsX, interactionPulseScalePointsY, interactionPulseDriftRatio, scaleSpringResponse,
scaleSpringDamping, scaleSpringTrackingResponse, scaleSpringTrackingDamping.

Presets (static getters; constants read from 0x191393f00…0x191394120 and 0x1913872b0). The **cursor** set (macOS
pointer) is what a Mac uses:

| preset (address) | assocDim | bigGlow | littleGlow | dissip. | lift pt | distThr | mvNorm | mvPts | mvMin | mvMax | pulseNorm | pulseX | pulseY | drift | resp | damp | trackResp | trackDamp |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| default `init()` 0x1908b109c | 0 | 0 | 0 | 0 | 20 | 100 | 10000 | 0 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.531 | 0.845 | 0.15 | 0.86 |
| small 0x1908b1918 | 80 | 0.75 | 0.75 | 50 | 2.25 | 60000 | 10000 | 0 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.25 | 0.375 | 0.262 | 0.625 |
| large 0x1908b1870 | 160 | 0 | 0.0375 | 25 | 2 | 70000 | 10000 | 0 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.25 | 0.6 | 0.314 | 0.625 |
| loupe 0x1908b19c8 | 70 | 0 | 0 | 0 | 0 | 0 | 2500 | 25 | 0.75 | 1.15 | 1 | 0 | 0 | 0 | 0.5 | 1 | 0.5 | 0.9 |
| smallLoupe 0x1908b1a64 | 37 | 0 | 0 | 0 | 0 | 6000 | 2000 | 2.5 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.444 | 0.56 | 0.444 | 0.56 |
| menu 0x1908b1b04 | 160 | 0 | 0.05 | 25 | 0 | 0 | 10000 | 0 | 0.9 | 1.1 | 24000 | 0 | 0 | 0 | 0.25 | 0.6007 | 0.15 | 0.5 |
| windowControl 0x1908b1bb4 | 14 | 0 | 0 | 0 | 2 | 3825.6 | 10000 | 0 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.355 | 0.4 | 0.1 | 1 |
| window 0x1908b1c40 | 160 | 0 | 0.05 | 25 | 0 | 30000 | 10000 | 0 | 0.9 | 1.1 | 1 | 0 | 0 | 0 | 0.35 | 0.398 | 0.1075 | 1.004 |

Touch differs (e.g. small: lift 16, littleGlow 1, distThr 6000, spring 0.4 / 0.375; menu touch has the pulse 10.99 /
7.19 pt, drift 1.052, normalisation 8000). Full dump: `flexemu.py` output in the round's scratch (not kept); the rows
above are complete for cursor.

`Settings(variant, size:)` 0x1908b1100 (jump table at 0x190411a48):
- **automatic**: if `max(w, h) < 120` (0x405e… = 120 at 0x1908b11fc) → `small` with the ultraSmall changes (0x1908b120c:
  touch distThr 2000; cursor lift **2.5**, distThr 60000, littleGlow **0.2625**, spring **0.25 / 0.629**); otherwise
  `small` → `large` blended per field by `t = clamp((min(w, h) − small.assocDim) / (large.assocDim − small.assocDim))`
  (cursor: (min − 80) / 80) (0x1908b15c0…).
- ultraSmall: the same ultraSmall set. liquidLens (0x1908b139c): `t = clamp((min(w, h) − 37) / 33)`, movement scales
  0.9 − 0.15 t / 1.1 + 0.05 t, cursor movementScalePoints 2.5 + 22 t, other terms interpolated (not needed here).
- `FlexiGlassSettingsOverrideObserver` (0x190c1902c) applies per-variant user-default overrides (tuning only).

## 3. The press ("lift") and the liquid bounce

`applyScale(to:width:height:)` 0x190c225cc (decoded):
- **Lift** (flag `Value+0x42`): `s = (max(w, h) + liftScalePoints) / max(w, h)` on both axes (`fcmp d9, d8; fcsel …
  ls` picks the LONGER side). So the longer side grows by exactly `liftScalePoints` pt (2.5 for a glass under 120 pt).
- **Stretch** (gate `flex`, `Value+0x43`, only when `scaleDistanceThreshold > 0`), round 2 (decoded): the `Value` read
  here is `FlexValue.Interaction { phase: Phase, gates: Gates }` (swift-dump): `phase` is `active(LocalGesture)` /
  `inactive(LocalGesture?)` with the tag byte at +0x40, `gates` = interaction +0x41, lift +0x42, flex +0x43, glow +0x44,
  pulse +0x45. `LocalGesture { start, location, translation, internalTranslation }` (+0x00 / +0x10 / +0x20 / +0x30) comes
  from `ResolvedLocalGesture.value` 0x190c20ae4: `start = gesture.startLocation - viewOrigin`, `translation =
  gesture.translation` (the pointer's travel since the press, pt), `location = start + translation`, `internalTranslation
  = clamp(location, 0, viewSize) - start` (the same travel with the pointer held inside the glass). Per axis, with
  `d` = translation, `di` = internalTranslation, `thr` = scaleDistanceThreshold:
  `k = (|d| - |di|) / thr + |di| / (4 thr)` (pulse gate: `(|d| - |di| + 40 |di| / w) / thr`); x: `scale.x += k, scale.y -= k,
  translation.x += w · sign(d) · k`; y the same with the axes swapped. No velocity and no spring of its own: the target
  scale / translation go through the same scale springs as the lift. Cursor thresholds 60000 (small, ultraSmall) / 70000
  (large): a 60 pt drag inside a 78 pt capsule gives k = 0.00025 (+0.02 pt), 100 pt past the edge 0.0017 (+0.13 pt).
  The pointer stretch is real but sub-point on a Mac; it is **not** the "water" the eye sees (that is the lift's
  under-damped spring, below). Built (`motion.js pressStretch`, `GlassButton`).
- Springs (round 2, `updateEffect` 0x190c220a0…0x190c22114, decoded): the scale / drift springs take
  `scaleSpringTrackingResponse / Damping` (ParameterSet +0x80 / +0x88) only while the `pulse` gate is on **and** the phase
  is active; otherwise, press **and release** alike, `scaleSpringResponse / Damping` (+0x70 / +0x78). A disabled or empty
  view springs on 0.5 / 0.5. So by SwiftUI's code the release is the press spring (0.25 / 0.629 for a glass under 120 pt);
  the recording shows a critically damped 0.21 s settle (below). `GlassContainer.MakeAnimatableInteractionState` (fields
  `_transaction`, `_phase`, scaleX / scaleY / translationX / translationY as `AnimatableFloatingPoint`) animates the state
  a second time inside the container with the current transaction: a likely source of the difference, not traced.
- `applyScalePulse` / `interactionPulse*`: only `menu` (touch) has a pulse; not used for macOS buttons.
- `applyMovement` (loupe / liquidLens / smallLoupe: `movementScalePoints`, min / max scale): the "magnifier" variants;
  not decoded further (no macOS control in this round uses them; the slider knob does not, see 5).

Measured against the code (preview share capsule of the Liquid Glass preview, left edge per frame, 2 px per pt):
- press frames 196-214: progress .145 .36 .569 .72 .849 .939 1.003 1.032 1.055 1.055 1.048 1.0 1.023 …; the decoded
  spring 0.25 / 0.629 fits with rms .021 (free fit 0.235 / 0.70, rms .010); a second press (frames 315-330) the same.
- release frames 252-275: .817 .659 .486 .338 .222 .148 .103 .068 .055 …, no overshoot; critically damped response
  0.21 s fits (rms .033); the press spring would give .079. **Measured** only (code unknown).
- amplitude 3.11 px = 1.555 pt on the left edge, +0.35 pt on the right: the pressed button grows (2.5 pt on its 37 pt
  side), the merged neighbour does not. Consistent with the share button scaling about a point near the pointer
  (`PlatformGlassInteractionState.anchor`, inferred, not decoded).

Liquid bounce of the slider knob (measured): frames 2093-2242 and 2246-2514 (held drags up to 120-170 pt/s): the lens's
chord width stays 34.0-35.0 px; no stretch along the motion, no lag. The knob's lens is DesignLibrary's own (switch:
grows ×1.56 on easeInEaseOut 0.2 s; slider: ×1.25 on the 144 ms bezier, MOTION-MEASURED session 14). Nothing to add.

## 4. The light that follows the pointer ("glow")

`updateGlow(gestureLocation:gestureStartLocation:width:height:)` 0x190c24650 (decoded):
- glow size `min(1.5 · min(w, h), 160)`.
- while the gesture is active (phase byte ≥ 0) and glow is on: `dist = |location − startLocation|`;
  - `dist ≤ littleGlowDissipationDistance` (50 small / 25 large): little glow opacity = littleGlowOpacity, glow scale 1,
    response 0.1;
  - beyond: little glow opacity × 0.5, glow scale 2, response 0.5;
  - big glow opacity = bigGlowOpacity (0.75 small, 0 large) on response 0.1.
- released (phase < 0): both opacities → 0 and the glow scale → **4** on response 0.5 (it grows while it fades).
- the glow's **position** = the gesture location, on a critically damped spring of response **0.15 s**
  (0x190c24988: 0x3fc3333… = 0.15, damping slot 1.0).
- `GlowContainer.body`: two CALayers, `FlexInteraction.BigGlow` and `FlexInteraction.LittleGlow`; fully decoded in
  round 3 (section 8 below: shapes, matrices, the grey level is 0.75 dark / 0.40 light, not 0.43 / 0.765).

Against the recording (measured in session 14/17, the former `Tokens.toolbar.pressRise` / `pressFall`): the capsule's mean
brightness rises like a critically damped spring of 0.1 s (rms .019) and falls like one of 0.5 s one frame later
(rms .017): the decoded big-glow springs. The fitted profile (gain 0.41 in the recording, 0.35 on screen, flat over the
16 pt hover disc, linear to 0 at 66 pt: ratios 1.43 1.38 1.41 1.41 / 1.37 at 18 pt, 1.34 at 22-26, 1.30 at 30, 1.27 at 34,
1.24 at 38, 1.13 at 50) was replaced in round 3 by the decoded layers (section 8). The recording has no frames where the pointer moves while a glass button is
held, so the follow (0.15 s) is code-only.

## 5. When does a control change its value (press and hold)

| control | Mac (source) | hyprk before | hyprk now |
|---|---|---|---|
| Slider, press on the knob, no move | nothing changes, the knob turns into the lens (recording 2064-2093; Slider.qml decode) | same | same (test) |
| Slider, press on the track | the knob runs to the pointer and the value changes **on mouse-down**, while held (recording 2622 down → knob moving from 2625, release 2635; preview capsules jump in the same frame) | same | same (new test `slider_track_press_changes_on_press`) |
| Slider drag | value follows the pointer from the first move; committed at release | same | same |
| Switch, click / press-and-hold | toggles at **mouse-up** inside the track, however long held (NSSwitch `_shouldToggleForEndTrackingAtPoint:` 0x18b16e0c8; probe holds of 0.77 / 0.80 s) | same | same (test) |
| Switch, release outside without a drag | no change | same | same (test) |
| Switch, drag across | the knob shows the side under the pointer; the state changes at mouse-up to that side; across and back: no change | same | same (tests) |
| Push / glass buttons, CC tiles | action at mouse-up inside (NSButtonCell `trackMouse:inRect:ofView:untilMouseUp:` 0x18a5949d4 → `_sendActionFrom:` 0x18a597c80; standard AppKit, not disassembled this round) | on click (release inside) | same |
| Pop-up button | menu opens on mouse-down, an item is chosen by release over it or by a second click (`NSPopUpButtonCell trackMouse` 0x18a6bfa00; not disassembled) | same | same |
| Segmented control | (`NSSegmentedCell _calculateSelectedSegmentForPoint:` 0x18a665f7c, `_applicableTrackingModeForSegment:`; not disassembled) | selects on release inside | same |
| Checkbox | toggles at mouse-up inside (standard) | on click | same |
| Stepper | `+[NSStepperCell prefersTrackingUntilMouseUp]` 0x18b168ee8; autorepeat while held (not decoded) | no stepper in HyprK | - |

The user's belief "click and hold does not change a button's value" is **right for switches, checkboxes, buttons and
tiles** (the value changes at the release, a long hold changes nothing until then) and **wrong for the slider's
track**: there the value changes on mouse-down. A press on the slider's knob without moving changes nothing.

## 6. Other findings

- Pointer light on non-interactive glass (CC, Dock, menu bar): none on the Mac (Verify B 4); only `.interactive` glass.
- Hover: `GestureFactory.allowedEvents` 0x190c17798 and `ResolvedContext.input` (`GestureState.EventMask`) choose the
  touch / cursor set; hover itself does not lift (no hover term in `applyScale`). The +19.5-level hover disc of the
  toolbar buttons is AppKit's button highlight, not FlexInteraction.
- Reduce Motion: `MacLinearSlider` / `BaseSlider` / `MacColorSliderKnob` read `_reduceMotion`; FlexInteraction's own
  Reduce Motion path was not found in this round (unknown).
- Shadows of interactive glass: FlexInteraction draws none; the glass shadow stays the recipe's (Verify B, SHADOW.md).
  No shadow value changed this round.
- Merge of neighbouring glass while one is pressed (round 2, types decoded, functions not): the container keeps one
  `InteractionStorage { state, animatedState, isActive }` per `Entry.StableID` (dictionaries at 0x19044dfc8 / 0x19044e0ec),
  so each button of a merged capsule is its own entry and its own lift; the union is the container's usual shape blend.
  No attraction term or constant appears in the interaction types: neighbours do not pull toward the pressed one, they
  merge more only because its shape grew. The 0.35 pt the far end of the share | more capsule moves is that blend
  (not drawn by hyprk).
- Control Center (round 2, ControlCenter.app 27.2.1, `re-work/r2/CC.ann`): the module glass is picked from three cached
  `_Glass` values (thunks 0x10027ed88 / 0x10027ee38 / 0x10027ec54, sites 0x100172828, 0x10029c148, 0x10045bf20, 0x10028c404):
  environment Bool A off -> `_Glass.regular.subvariant("menu")`; A on and Bool B on -> `_Glass.controlCenter.forceSubdued(true)`;
  A on and B off -> `_Glass.controlCenter.interactive(true)`. So the tiles do use FlexInteraction (variant automatic): a
  140 x 64 tile takes the small cursor set (lift 2.25, damping 0.375), as built. The two environment keys (read through
  0x100145fa8) are not named.
- vibrantColorMatrix: `_ColorMatrix.YCC` builds its matrix through `_ColorMatrix.apply(blackWhite:saturation:hue:)`
  (YCC.colorMatrix getter 0x190ec51e8, then `zapAndQuantize`), so `YCC(0.05, 1.05, 1.2, 0)` reads black .05, white 1.05,
  saturation 1.2, hue 0; round 3 confirmed the order (YCC.colorMatrix passes s0..s2, d3 straight to
  `apply(blackWhite:saturation:hue:)` 0x190ec5bd0, whose identity test is black = 0, white = 1, saturation = 1, hue = 0).
  Built in round 3 (section 8).

## 7. What hyprk does with it (ui/HyprK)

- `motion.js pressScale / pressDamping / pressLift`: the automatic cursor rule above (longer side, ultraSmall below 120,
  small → large over the shorter side 80 … 160). `PressSpring` releases on the measured 0.21 s critically damped spring.
- `ToolbarHighlight`: the press light is the decoded BigGlow + LittleGlow pair (round 3, section 8), light and dark, its
  matrices unclamped and the ultraSmall LittleGlow's opacity and blur fitted to the recording (round 4, section 14); with a
  `source` it also lifts the toolbar capsule (round 3, section 9).
- `motion.js pressStretch` / `GlassButton`: the decoded drag stretch (round 2); `GlassButton.segments`: the pressed button
  of a merged capsule lifts by its own size, only its outer end moves (Appearance preview: left end 1.25 pt, right end 0;
  the Mac 1.555 / 0.35).
- Knob lens, light: the B2 model (ring shadow + key / fill light, `glasslens4.frag` since round 3); dark keeps the
  recording fit.
- Not built: the union blend of merged glass (the far end's 0.35 pt; section 9).

## 8. Round 3: the press light as the code draws it (built)

Decoded (SwiftUICore 27.2.1; objc stubs resolved by disassembling each `objc_msgSend$sel` stub, e.g. 0x1980038a0 =
`setName:`):
- `GlowContainer` = `{ colorScheme environment (0x10), bigOpacity +0x10, littleOpacity +0x18, size +0x20, x +0x28,
  y +0x30, scale +0x38 }`; `updateGlow` 0x190c24650 writes its output in that order (springs at state +0xb0 big opacity,
  +0xd0 little opacity, +0x130 scale, +0xf0 / +0x110 position; every `FluidSpringAnimation.animate` gets damping 1.0).
- `GlowContainer.body` 0x190c1f0c4: `ZStack { Color.clear; layer.opacity().frame(size, size).scaleEffect(scale, anchor:
  .center).position(x, y) }` for both layers (closures 0x190c1f670 BigGlow, 0x190c1f904 LittleGlow), clipped to the glass
  shape (`EffectModifier.body` 0x190c1fe58 `clipShape(effectiveClipShape)`), hit testing off.
- BigGlow (0x190c1f670): `backgroundColor` = gray 1 alpha 1 (opaque white square, no corner radius); `filters` =
  `[vibrantColorMatrix]` with `inputBackdropAware` = YES and `inputColorMatrix` = `_ColorMatrix.YCC(0.05, 1.05, 1.2, 0)`
  (floats 0x3d4ccccd, 0x3f866666, 0x3f99999a at 0x190c1f6f0).
- LittleGlow (0x190c1f904): `allowsHitTesting` NO, `cornerRadius` = `kCALayerCornerRadiusAutomaticPill`, `cornerCurve`
  circular, `shadowPathIsBounds` YES, `shadowOffset` (0, 0), `shadowOpacity` 1, `shadowRadius` = size x 0.5,
  `shadowColor` gray 1 (white); no background colour, so only its shadow (a blurred circle) is drawn. Matrix:
  `YCC(0, 1, 1.5, 0)` then `apply(fills: [Fill(g, g, g, 1), tag 2])`, g = `powf(dark ? 0.7630332 : 0.4312796, 2.4)`
  (0x190c1fa18; ColorScheme 1 = dark). `apply(fills:)` 0x190ec52a4 converts the fill to sRGB (12.92 / 1.055 x^(1/2.4) -
  0.055) and, for tag 2, multiplies the matrix by diag(1 / (1 - c)) (0x190ec5384): g = 0.750 dark, 0.400 light, so the
  LittleGlow is a colour dodge x4 (dark) / x5/3 (light) with saturation x1.5.
- `_ColorMatrix.YCC.colorMatrix` 0x190ec51e8 -> `apply(blackWhite:saturation:hue:)` 0x190ec5bd0 -> M = yccToRgb x S x BW
  x rgbToYcc (BT.709 tables at 0x1913e49a0: Y .2126 .7152 .0722, Cb -.1146 -.3854 .5 +.5, Cr .5 -.4542 -.0458 +.5;
  back 1 0 1.5748 -.7874 / 1 -.1873 -.4681 +.3277 / 1 1.8556 0 -.9278); BW = Y' = black + (white - black) Y
  (0x190ec5eb8, flag 1), S = chroma x saturation (0x190ec5df0); then `zapAndQuantize(1e-12, 1e-4)`.
- Per layer: colour := colour + opacity x coverage x (clamp(M x colour) - colour) (Verify B's vibrantColorMatrix law).
- updateGlow springs (decoded): big opacity -> bigGlowOpacity on 0.1 s while active, -> 0 on 0.5 s released; little
  opacity -> littleGlowOpacity on 0.1 s, or x0.5 with the scale -> 2 on 0.5 s beyond `littleGlowDissipationDistance`;
  released: little -> 0, scale -> 4, both 0.5 s; position 0.15 s; all damping 1. Opacities per size from the cursor set
  (`Settings(variant:size:)`, re-read at 0x1908b11f4..0x1908b1244: max(w, h) < 120 -> ultraSmall, cursor littleGlow
  0.2625 at +0xa0, big stays 0.75).

Unknown: the CA shadow's blur convention (built as sigma = shadowRadius, the convention AppKit's shadows follow in
SHADOW.md; sigma = shadowRadius / 2 fits the recording better, see below), whether the vibrantColorMatrix runs on
values above 1 before the display clips (built clamped to 0..1). Both settled against the recording in round 4
(section 14): unclamped; the blur fitted.

Built (e73a0d3): `motion.js glowPreset / glowSize / glowDodge / glowMask / glowLut`, `ToolbarHighlight` (springs as
above, light and dark), `LensGlass` / `glasslens4.frag` (uniforms glow, glowAmt, glowLut0..3; glasslens3 removed),
`PressGlow` and the fitted `Tokens.toolbar.press*` removed. Hover disc unchanged (AppKit's, measured).

Against the 23.09.23 recording (dark, the preview's share button, 37 x 37 entry -> ultraSmall), press ratio per ring
(frame 220 / frame 196): **the decoded light is weaker**. rms against the measured ratios (0, 4, 8, 12, 18, 22, 26, 30,
34, 38, 50 pt): fitted gain .015 -> decoded .236 (sigma = R; .193 with sigma = R / 2). On screen (nested session, MBA 2x,
Settings > Appearance, dark, held 0.35 s): +15..18 levels over the hover state at the pointer, the recording about +55.
With littleGlowOpacity 0.75 (the `small` set) the model gives rms .131 (sigma = R) / .076 (sigma = R / 2). The BigGlow's
square edge at 27.75 pt matches the recording's 0.04 drop between 26 and 30 pt. So either the preview's buttons do not
take the automatic ultraSmall set (their variant is set in SwiftUI's button style code, `GlassButtonStyle` 0x19a6d2654 /
`ApplyGlassButtonConfiguration`, not traced) or the CA layer path differs; needs the Mac (below). Light mode: +4..8 levels
at the pointer on the preview's light glass.

Where the light goes: glass buttons with a ToolbarHighlight (Settings back / forward, Finder capsules with `lights`,
the Appearance preview). Not built: Control Center tiles (their glass is the compositor's; the light needs the backdrop the
plugin samples: a plugin feature, not done). Slider knob and switch thumb: none, by the code (`MacLinearSliderKnob` and
`MacSolariumSwitch` hold no `flexState`, no GlowContainer).

## 9. Round 3: toolbar capsules lift (built), the union blend (not decoded)

ToolbarHighlight with a `source` applies `PressSpring`'s lift and `pressStretch` to the capsule and to itself (7867571):
the pressed button's span runs halfway to its neighbours' centres; a whole-capsule button scales about its centre, the
first / last button about the far end with `1 + segW x lift / 2 / width` (as `GlassButton.segments`). Settings back /
forward: left end out 1.25 pt, right end still, the capsule 2.5 pt taller (nested session, back pressed: edge columns
16 -> 12 px left, 161 -> 161 right, rows 8..79 -> 5..82).

Union of merged glass: the per-fragment SDF (`compute_sdf_with_mode` in the metallib, modes rect / supercircle / texture)
holds no smooth-min; merged shapes come in as an SDF texture composed elsewhere (CASDFLayer / the GlassEffectContainer
spacing path in QuartzCore, function not found this round). The 0.35 pt at the far end stays undrawn.

## 10. Round 3: shadows from the code

The glassBackground filter's drop shadow (metallib `glass_background_base`, IR lines with uniforms 11..15, 22..26, 40, 41;
CPU `CA::OGL::GlassBackgroundFilter::render` 0x18debc058):
`shadow = (shadow_cm(blurred backdrop at uv + displacement) x contribution + fill.rgb, mix(fill.a, 1, contribution))
x ShadowOpacity x a x g(d_s / ShadowRadius)`, d_s = the shape's SDF at p + offset, g = the filter's polynomial
0.5 erfc (Gaussian sigma = radius / sqrt 2), the displacement `ShadowAmount - ShadowAmount sqrt((2 - t) t)`, t =
saturate(-(d + ShadowDistanceOffset) / ShadowHeight) (it moves where the shadow samples the backdrop, not the edge).
CPU: shadow_inv_radius = 1 / ShadowRadius (0x18debced4), face opacity = FillColor.a + SDRShadowOpacity x (1 - HDR
fraction) (0x18debc550), contribution = ShadowVibrancyContribution. Every dumped recipe fills black at 0.3 (control:
1.0): **ink = 0.3 x ShadowOpacity**. A press does not change the inputs: `regular+_interactionState=1` and `=2` dump the
same shadow as `regular` at every size (glass-params-*.json); the lift scales the whole glass layer, so its shadow grows
with it (`PlatformGlassInteractionState` applied as the layer's transform: inferred, not traced).

| surface (recipe, D) | appearance | drop shadow (opacity, radius, y; ink) | ring shadow (op / y / blur / width) | kind | press | hyprk before -> now |
|---|---|---|---|---|---|---|
| toolbar capsule, glass button (regular, 36-37) | light / dark | .04, 4, 8; ink .012 | .06 / 8 / 5 / 4 | filter | same, scaled with the lift | QML RectangularShadow .012, blur 4, y 8 (decoded); ring not drawn |
| regular glass, D 96 / 128 / 160 | light | .16 / .28 / .40, r 10.67 / 17.33 / 24, y 8; ink .048 / .084 / .12 | .06 / 8 / 5 / 4 | filter | same | plugin ink x .65 -> x .3 (0.46 x before) |
| same | dark | .227 / .413 / .60; ink .068 / .124 / .18 | same | filter | same | same change |
| CC tile, HUD (controlCenter) | both | none (op 0) | none | - | - | none (unchanged) |
| Dock (dock), Clear | both | none | none | - | - | none |
| menu (regular.menu, any D) | light / dark | .7 / .8, 24, y 10; ink .21 / .24 | .06 / 8 / 5 / 4 | filter | - | fitted .32 / .36 (ink .208 / .234) -> decoded .7 / .8; on screen 1-2 levels lighter |
| banner, NC card (notificationCenter, D 166) | light / dark | .4 / .6, 24, y 8, vibrancy 1 (tinted) | .06 / 8 / 5 / 4 | filter | - | kept the fit to the PC #62 gaps (ink .088 / .137 = 0.3 x .2925 / .455); decoded would be .12 / .18 |
| window glass (regular.window) | light / dark | .7 / .8, 24, y 10 | .06 / 8 / 5 / 4 | filter | - | windows use AppKit's window shadow (plugin WindowShadow, SHADOW.md, unchanged) |
| inactive window (regular.window+inactiveApp) | light | .55, 16, y 4 | 0 | filter | - | same |
| slider knob, switch thumb at rest | both | DesignLibrary knob: black .10 r 12 y 3 + .10 r 2 y 1 (Q-16, measured) | - | CA layer | - | unchanged |
| switch thumb pressed (control lens, live/controls) | light | .001 (none), 8, y 7, fill 1 | .10 / 8 / 3 / 4 | filter | the lens is the press | ring as RectangularShadow .10 y 8 (light), .19 dark (fitted) |
| slider knob pressed (B2) | light | - | .40 / 8 / 3 / 4 | filter | - | glasslens4 ring model (B2 fit, rms .56) |
| Spotlight panel | both | AppKit active window shadow .40 / .70, y 18, blur 20 (black, full opacity) | - | window | - | unchanged (shadowBlack) |

Built: 83329b6 (plugin: ink = opacity x mix(fill, 1, vibrancy), colour black or backdrop-tinted, `shadow_tint` removed,
menu decoded). Menu shadow on screen, nested session over the Settings window: beside the menu at mid height 148 / 221
221 224 226 228 230 -> 145 / 222 223 225 227 229 231; below 167 175 176 177 -> 169 177 177 178; the menu's inside identical.
Not re-measured against Mac crops: regular glass of D 96..160 (no Mac crop of its shadow; the change halves its ink).

## 11. Round 3: release spring

`GlassContainer.MakeAnimatableInteractionState.updateValue` 0x190bb782c reads the current `Transaction`: when it carries
an `Animation` (or `TracksVelocity`) and the four `AnimatableAttribute<AnimatableFloatingPoint>` (scale x / y,
translation x / y) are not made yet (flag +0x24), it makes them (`makeAnimatable(oldState:)` 0x190bb7b40, defaults scale
1, translation 0, anchor 0.5 / 0.5) and from then on the container re-animates FlexInteraction's per-frame values with that
transaction's animation; without an animation the values pass through. So the release on screen = FlexInteraction's
spring (0.25 / 0.629, `updateEffect`) further animated by whatever animation the release's transaction carries. That
animation comes from the caller (the gesture end / button action), not from this code: **not decoded**. The measured
critically damped 0.21 s settle (rms .033) stays in `PressSpring`.

## 12. Round 3: verification

- Scenegraph timing (QSG_RENDER_TIMING, Settings, three presses with drags): CPU render 0.10 ms mean (max 16 on one frame),
  renderer 0.03 ms mean; GPU ms of `glasslens4.frag` not measured (QML has no GPU timer here); the light only renders while lit.
- Not done this round: knob lens over stripes / at the track ends / at 1.6, the dark ring against frames 2678-2693, the
  drag-stretch frame ranges, `hyprctl liquidglass trace` (stats off in the session), the knob / thumb press from
  DesignLibrary code.

## 13. Round 3: refraction constants still fitted (task list, nothing changed)

| where | constant | status | what the code says |
|---|---|---|---|
| `Tokens.control.lensBand` / `lensAmount` (0.5 / 0.34 x height, the preview capsules) | fitted to the switch strip | the preview's buttons are Regular: inner H min(0.25 D, 20), A max(-0.5 D, -60) (inward), outer max(0.2 D, 16) / max(0.25 D, 16) at 0.6 over the outer 1 pt (Verify B 2): opposite sign to ours |
| `glasslens4.frag` refraction profile | `amount (1 - depth / band)^2` | the filter's `edge()`: `amount (1 - sqrt(1 - (1 - t)^2))`, t = depth / H (metallib, Verify B 2) |
| `knobLensBand` / `knobLensAmount` (0.1 / -0.15 D) | decoded inner term only | the switch lens also has the displacement map +0.25 D over height D (Verify B 5: field 7.75 m(depth, 31) - 4.65 m(depth, 3.1), rms 0.26 pt): not built |
| plugin `panel_blur` ramp (54 / 36 @ 0.15 / 72 pt) and radius 1.79 pt | fitted (REFRACTION.md) | the CC panel layer is not dumpable |
| plugin `underlay_blur` (off) | fitted | - |
| plugin Dock pointer fill (k + c (1 - a), Q-dock-08) | fitted | - |
| plugin rim, NC key band x1.23 | fitted to Mac pixels | - |

## 14. Round 4: the press light against the recording (built, partly fitted)

Cause of the 3x gap (measured, the 23.09.23 recording, not decoded): the layers' colour matrices are **not clamped**.
At the pointer the hovered capsule goes from R 155 G 169 B 180 (frame 196) to 215 243 255 (frame 220). Mixing toward a
clamped LittleGlow (x4 dodge -> white) by any amount a moves R and B together (R .608 + .392 a, B .706 + .294 a): B can
only reach 1 with R at 1. The unclamped dodge 4 x (Y + 1.5 chroma) = (2.33, 2.66, 2.92) mixed in by a = .136 / .145 /
>= .133 gives all three channels: the layers composite in extended range and the display clips once (CA renders
window content in an extended-range format on this P3 panel: inferred from this, not traced in QuartzCore).

What the variant search found (time-boxed, not settled): `GlassButtonStyle.makeBody` 0x19a6d2654 builds a
`DesignLibraryBorderedButtonStyle(isProminent:)` 0x19b47ba50 with the `Glass` in the environment and the
`ApplyGlassButtonConfiguration` input flag; the glass and its interaction are made inside DesignLibrary (no local symbols
in the cache), so the cursor set the preview's buttons take is still unknown. `ipsw dyld xref --imports` finds no caller
of `_Glass.interactive(_:variant:)` 0x190e82614 / `(_:variant:sources:)` 0x190e82828 / `(_:configuration:)` 0x190e82a30.
The CA shadow sigma convention was not decoded either.

Fit (scratch `pfit.py`, the share button 37 pt = 71 px, glow centre the pointer tip, rings around it, glyph, cursor and the
recorder's click circle masked; frames 196 -> 220 and a second press 314 -> 330), ring = rms of the red press ratio over
the rings 4..50 pt (the old metric), pixel = rms over all capsule pixels and channels, in levels:

| model | ring 1st / 2nd | pixel 1st / 2nd |
|---|---|---|
| decoded, clamped, ultraSmall (e73a0d3) | .235 / .241 | 45.8 / 45.8 |
| decoded, unclamped, ultraSmall, sigma = R | .068 / .073 | 14.5 / 14.5 |
| decoded, unclamped, small set (little .75), sigma = R | .258 | 31.7 |
| linear-light mixing variants (matrix on linear or encoded) | .052 ... .30 | 8.9 ... 37 |
| old flat gain fit (.41) | .017 / .012 | 8.9 / 8.5 |
| **built: unclamped, little .475, sigma = 1.3 R (fitted)** | **.015 / .012** | **5.7 / 5.6** |

Built (ui/HyprK `motion.js` glowLittleUltra / glowSigma, `glasslens4.frag`): BigGlow and LittleGlow as decoded with the
matrices unclamped and one clip after both; the ultraSmall LittleGlow opacity and its blur (sigma 1.3 x the radius;
the coverage table now spans 0..5 radii) are **fitted**. On screen the opacity is 0.405 = 0.475 x 0.854, the same
recording-to-screen factor as the old fit (0.41 in the recording, 0.35 on screen: the recording darkens mid-tones more
than highlights). Light mode: the decoded dodge (5/3) on the same fitted opacity and blur (no recording).

On screen (headless session, scale 2, Settings > Appearance, dark, held 0.6 s, R G B added over the hover state):
preview share button at 4 pt from the pointer +20 +19 +18 (e73a0d3) -> +60 +60 +49, at 30 pt +8 +7 +7 -> +33 +39 +44;
red press ratio by ring 1.11 1.14 1.10 1.17 ... 1.03 -> 1.33 1.36 1.36 1.40 1.31 1.29 1.22 1.20 1.17 1.12 (recording
1.42 1.41 1.39 1.39 1.35 1.30 1.27 1.24 1.22 1.13 before the screen factor). Settings back button (dark toolbar
capsule): +28 -> +41 at 6 pt, +11 -> +13 at 24 pt. Light, preview share button: +6 -> +12 (R) at 8 pt, +2 -> +11 at
30 pt (the light glass is near white, the dodge clips).

## Needs the Mac

1. A glass button held while the pointer moves 0 → 80 pt across it (60 fps, dark and light): the light's track, the
   halving at 50 pt, and the stretch, if any (it would show `applyScale`'s input).
2. The same capsule pressed on its right button: which edges grow (per-button lift and its anchor); a press held while
   the pointer leaves the glass (does the lift stay, i.e. is the stretch past the edge ever visible).
4. The held slider knob in dark over 4 pt stripes and a gradient (the ring / fill model is only measured in light).
5. A glass button pressed in light mode (the press light) and the shadow under a pressed glass button (does it scale
   with the lift).
3. One `defaults read` of `FlexiGlass*` overrides on the Mac (to rule out tuning overrides).
6. (round 3, round 4) The preview's share button held still 1 s, dark AND light, 60 fps, plus one `defaults` / AX dump
   of the preview glass buttons' interaction variant if reachable: which cursor set they take. Round 4 found the
   unclamped matrices (most of the 3x) and fitted the rest (LittleGlow .475, sigma 1.3 R); the light-mode press is
   untested against a Mac. A CALayer probe (8) settles the sigma; a press over a flat grey backdrop settles the opacity.
7. (round 3) A Regular glass panel of D >= 96 over white (e.g. a SwiftUI sheet or a large glass button) to check the
   0.3 x ShadowOpacity ink below and beside it at 2 / 8 / 16 / 32 pt.
8. (round 3) A CALayer probe with shadowRadius 20 over white to read CA's shadow sigma (= radius or radius / 2).
