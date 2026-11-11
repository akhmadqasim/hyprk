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
- `GlowContainer.body`: two CALayers, `FlexInteraction.BigGlow` (white, a backdrop-aware `vibrantColorMatrix` from
  `_ColorMatrix.YCC(0.05, 1.05, 1.2, 0)`) and `FlexInteraction.LittleGlow` (white, its own YCC matrix (…, 1, 1.5) and a
  grey level `pow(0.43 dark / 0.765 light, 2.4)`); opacity, frame, scale and position modifiers. The YCC argument order
  and the little glow's shape (gradient type and stops) were not decoded (objc selectors of the stubs unresolved).

Against the recording (measured in session 14/17, `Tokens.toolbar.pressRise` / `pressFall`): the capsule's mean
brightness rises like a critically damped spring of 0.1 s (rms .019) and falls like one of 0.5 s one frame later
(rms .017): the decoded big-glow springs. The recording has no frames where the pointer moves while a glass button is
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
  saturation 1.2, hue 0 by that signature (the argument order inferred from the callee's labels, not traced through the
  initializer). BigGlow / LittleGlow as two layers: not built.

## 7. What hyprk does with it (ui/HyprK)

- `motion.js pressScale / pressDamping / pressLift`: the automatic cursor rule above (longer side, ultraSmall below 120,
  small → large over the shorter side 80 … 160). `PressSpring` releases on the measured 0.21 s critically damped spring.
- `ToolbarHighlight`: the press light's centre follows the pointer (0.15 s, damping 1), halves beyond 50 pt from the
  press point (0.5 s); its rise / fall tables already are the decoded big-glow springs.
- `motion.js pressStretch` / `GlassButton`: the decoded drag stretch (round 2); `GlassButton.segments`: the pressed button
  of a merged capsule lifts by its own size, only its outer end moves (Appearance preview: left end 1.25 pt, right end 0;
  the Mac 1.555 / 0.35).
- Knob lens, light: the B2 model (ring shadow + key / fill light, `glasslens3.frag`); dark keeps the recording fit.
- Not built: the glow's growth to ×4 on release (our light is a gain profile, not a
  layer; the measured fall table already covers its brightness), per-button lift inside a merged capsule (the
  Appearance preview's `GlassButton` is the whole capsule: the right edge grows 1.25 pt where the Mac's grows 0.35).

## Needs the Mac

1. A glass button held while the pointer moves 0 → 80 pt across it (60 fps, dark and light): the light's track, the
   halving at 50 pt, and the stretch, if any (it would show `applyScale`'s input).
2. The same capsule pressed on its right button: which edges grow (per-button lift and its anchor); a press held while
   the pointer leaves the glass (does the lift stay, i.e. is the stretch past the edge ever visible).
4. The held slider knob in dark over 4 pt stripes and a gradient (the ring / fill model is only measured in light).
5. A glass button pressed in light mode (the press light) and the shadow under a pressed glass button (does it scale
   with the lift).
3. One `defaults read` of `FlexiGlass*` overrides on the Mac (to rule out tuning overrides).
