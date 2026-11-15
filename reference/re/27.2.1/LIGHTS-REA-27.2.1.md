# Traffic lights held down, macOS 27.2.1 (26B131): what the code says

Round "lights press" (2026-11-14). The user, on a real Mac: the three window buttons bounce while held; ours did not.
Sources: the 27.2.1 dyld cache (`~/Downloads/macos/dyld-27.2.1`), read with `ipsw dyld symaddr / disass / dump / class-dump`
(SwiftUICore, DesignLibrary and AppKit keep their exported Swift symbols; private DesignLibrary / AppKit functions are
`sub_` addresses). Whole-image disassemblies in scratch: `~/Downloads/macos/re-work/lights/{DL,AK}-ipsw.s`. The
FlexInteraction engine itself was decoded in `GLASS-INTERACTION.md` sections 1-4; this round finds which preset the
window buttons take and re-reads the parts it depends on. Every value: **decoded** (address), **measured** or
**inferred**; nothing here was observed on a Mac in this round.

## 1. Call path (decoded)

1. AppKit `_NSThemeWidgetCell` → `NSThemeWidgetAquaduckVisualProvider` (a Swift class with a lazy `hostingView`,
   class-dump) hosts the SwiftUI view `AppKit.ThemeWidgetView`.
2. `ThemeWidgetView.body` (AppKit sub_18b21d5e4) = `WindowControl(...)` (built in sub_18b21d834 with
   `WindowControl.init(variant:interactionState:titlebarRevealAmount:capabilities:)`), then `.controlSize(...)`,
   `ThemeWidgetLiftedPresentationModifier(x = NSControlSize == 4 ? 1 : 0)`, `.animation(.spring(response: 0.2,
   dampingFraction: 0.9), value: NSControlSize == 4)` (constants 0x3FC999999999999A / 0x3FECCCCCCCCCCCCD at
   0x18b21d76c) and `.opacity(hidden ? 0 : 1)`. The lifted-presentation part is for `.extraLarge` controls only, not
   the press. The cell's interaction int maps 1 disabled, 2 pressed, 3 deeplyPressed, 4 rollover, else idle
   (table 0x1e07077a8 → `DesignLibrary.InteractionState` cases): that only picks colours.
3. `DesignLibrary.WindowControl.body` 0x195dd78c8 builds `MacWindowControlElement` (metadata sub_195e391c4).
4. `MacWindowControlElement.body` (sub_195e393d0): the variant byte ≤ 0x9f and a glyph `ImageResource` → the flex
   branch sub_195e39790, else `LegacyWindowControlElement` (sub_195e39dfc).
5. sub_195e39790: frame 14 x 14 for the regular size (sub_195e3c438: ≤ small 10, large 26, extraLarge 54, else 14), then
   `View.flexInteraction(configuration: FlexInteraction.Configuration(behaviors: .all, variant: .windowControl,
   activation: .automatic, sources: .interaction), viewFrame: nil, isEnabled: e, action: nil)` (call at 0x195e39db4;
   `Variant.windowControl` getter at 0x195e39c94). `e` = control size < .large and the variant is not screen sharing /
   recording; it does **not** depend on key / inactive / disabled state.
6. AppKit routes the clicks to the button (`hitTestForContext:superResult:` 0x18b21f318 returns the button for a hit
   inside the hosting view) and hands SwiftUI the events through
   `supplementalGestureRecognizerContainerForContext:` 0x18b21f3dc (returns the hosting view's gesture container):
   the button tracks and acts, FlexInteraction animates. (Inferred from the method names and the code path; the
   container's internals were not traced.)

So the bounce is FlexInteraction with the `windowControl` preset, not a CoreUI recipe or an AppKit animation.

## 2. The preset (decoded)

`FlexInteraction.Settings(variant:size:)` 0x1908b1100: case windowControl tail-calls `Settings.windowControl`
0x1908b1bb4 (size ignored). Touch and cursor sets are identical (doubles read with `ipsw dyld dump`):

| field | value | source |
|---|---|---|
| associatedDimension | 14 | `mov x8, #0x402c000000000000` |
| big / little glow opacity, dissipation | 0, 0, 0 | zeroed: **no glow** |
| liftScalePoints | 2 | 0x1913941c0 |
| scaleDistanceThreshold | 3825.649 | 0x1913941c8 |
| movement norm / points / min / max | 10000 / 0 / 0.9 / 1.1 | 0x191393f10, 0x191393f20 (unused: no movement source) |
| pulse norm / X / Y / drift | 1 / 0 / 0 / 0 | |
| scaleSpringResponse / Damping | 0.355 / 0.4 | 0x1913941d0 |
| scaleSpringTrackingResponse / Damping | 0.1 / 1.0 | 0x191384720 (not used here, below) |

Gates (`ResolvedInteraction.updateValue` 0x190c20cf4): interaction = sources ∋ interaction, lift = behaviors bit 1,
flex = bit 0, glow = bit 2 (`Behaviors.flex` 1, `lift` 2, `glow` 4, `all` 7), **pulse = (variant == 7, menu)**. The
spring choice (`updateEffect` 0x190c220a0): tracking spring only with pulse on and the phase active; so the window
buttons use **0.355 / 0.4 for the press and for the release**.

## 3. Hold, drag, release

- **Gesture** (`GestureFactory.makeComponent` 0x190c17850): `LongPressComponentV3(pointCount 1, minimumDuration 0,
  maximumDuration max, maximumMovement 0x7fefffffffffffff = greatestFiniteMagnitude, failOnExceedingMaximumDuration
  false, requiredButtons .primary)`, `.idleTimeout(2 000 000 000 ns)` (`mov w8, #0x9400; movk #0x7735`). Active from
  mouse-down; dragging any distance does not end it; it ends at mouse-up. The idle timeout: the gesture ends after 2 s
  without an event (the constant is decoded, what `idleTimeout` does is **inferred** from its name: a still, held
  button would spring back after 2 s).
- **Lift** (`applyScale` 0x190c225cc): `s = (max(w, h) + 2) / max(w, h)` on both axes = 16/14 = 1.142857 for the 14 pt
  button (16 pt; MAC-ANSWERS Q-windows-08 saw "16 to 17 pt", i.e. the lift plus the overshoot). Anchor: the
  `AnchorProvider` (0x190c1bb14) falls back to `.center` when none is given (none is). The whole element scales:
  disc and glyph together (the flex modifier wraps the element with its overlay).
- **Spring**: response 0.355 s, damping fraction 0.4 (SwiftUI: stiffness (2π/0.355)², damping 4π·0.4/0.355). Closed
  form: overshoot e^(−πζ/√(1−ζ²)) = 25.4 % at π/ω_d = 0.194 s, so 14 → 16.51 pt at 0.19 s → 15.88 at 0.39 s → 16.03 at
  0.58 s → settled (±0.01 pt) by about 0.8 s. Release: the same spring back to 1: 16 → 13.49 at 0.19 s → 14.12 →
  14. (inferred: the release spring follows from the code; `GLASS-INTERACTION.md` measured a critically damped release
  for glass *inside a GlassContainer*; window buttons are not glass in a container.)
- **Drag stretch** (`applyScale`, flex gate on): per axis, d = pointer travel since the press, di = the travel with the
  pointer clamped to the 14 pt frame, k = (|d| − |di|)/3825.649 + |di|/(4·3825.649); x: scale.x += k, scale.y −= k,
  shift.x += 14·sign(d)·k (y alike), through the same spring. 50 pt out from a press at the centre: k = 0.0117, the
  button 16.16 x 15.84 pt, shifted 0.16 pt toward the pointer. No clamp, no velocity term.
- **Colour while held**: AppKit's pressed state (`InteractionState.pressed`) while the pointer is on the button
  (standard NSButton tracking; not disassembled this round). Leaving the button: rest colour, still lifted.
- **Action**: at mouse-up inside the button (AppKit), at once; the spring back runs after it. Release outside: no
  action, spring back.
- **Glow, shadow**: none (glow opacities 0; FlexInteraction draws no shadow, GLASS-INTERACTION.md 6).
- **Neighbours**: each button has its own flexInteraction; no glass container, so the others do not move.

## 4. Hover, inactive, other states

- Hover does not lift (no hover term in `applyScale`; sources = interaction only).
- Glyph opacity (sub_195e3ad5c): 0 for idle / disabled, else `titlebarRevealAmount`, animated with
  `.spring(response: 0.1, dampingFraction: 1)` (0x195e3b0f8). That spring per 60 Hz frame is .28 .62 .82 .92 .97,
  against the measured fade .30 .64 .81 .90 .95 (Tokens.lights.glyphIn): the measured fade is this spring. The 70 ms
  delay before it is AppKit's (not traced). Not changed this round.
- Inactive (non-key) window: `isEnabled` does not look at key state, so grey buttons lift the same (decoded for the
  SwiftUI side). Disabled zoom button: unknown whether AppKit forwards events to SwiftUI for a disabled cell; hyprk
  keeps a disabled light still.
- Large / extraLarge control sizes use `LegacyWindowControlElement` (no flex); not used by title bars.
- Reduce Motion: no Reduce Motion path found in FlexInteraction (unknown). hyprk: the lift without the spring.

## 5. Built

- `ui/HyprK/Tokens.qml` `lights.liftPoints / liftResponse / liftDamping / stretchDistance / idleTimeout` (replaces
  `pressedScale` 1.15).
- `ui/HyprK/TrafficLights.qml`: per light four `Spring`s (scale x, y, shift x, y) on the lift + stretch target from
  mouse-down to mouse-up / 2 s idle; disc (shader, kept at 7 pt radius, AA by the scale) and glyph scale together.
  `ui/tests/tst_traffic_lights.qml`: bounce, release undershoot, click, drag-out cancel, rest.
- `plugin/src/LightPress.{hpp,cpp}` (lgcore, closed-form spring), used by `Titlebar.cpp`; pressed textures drawn at the
  lifted density so the settled pressed disc is sharp. `plugin/tests/test_main.cpp`: lift, overshoot 1.254 at 0.2 s,
  undershoot, stretch, idle end. `shell/tests/run.mjs` checks the plugin constants equal the tokens.

## 6. Measured on screen (headless, scale 2, dark and light)

Disc width per captured frame (`mcap`, 2 px/pt, edge at half coverage), against the spring (best time shift):

| path | series | peak | rms |
|---|---|---|---|
| Finder dark, red, press | 14.00 14.01 14.19 14.74 15.00 15.21 15.79 16.00 16.06 16.22 16.38 **16.48** 16.47 16.38 16.27 16.17 16.08 16.02 … 15.97 (0.40 s) … 16.00 | 16.48 at 198 ms | 0.079 pt |
| Finder dark, release (pointer outside) | 16.05 15.97 15.80 15.37 15.02 14.76 14.20 14.00 13.89 13.69 13.49 **13.40** 13.41 13.49 13.63 … 14.02 (0.38 s) … 14.00 | 13.40 at 181 ms | 0.078 pt |
| Finder light, green, press | 14.00 14.02 14.18 14.68 14.97 15.20 15.73 15.96 16.08 16.22 16.36 **16.46** 16.44 … 15.91 (0.38 s) … | 16.46 at 181-198 ms | - |
| foot (plugin) dark, red, press | 14.00 14.15 14.65 15.00 15.17 15.73 15.99 16.08 16.26 16.44 16.56 **16.57** 16.52 16.39 … 15.98 (0.39 s) … 16.00 | 16.57 at 200 ms | 0.064 pt |
| foot, release | 16.23 16.11 15.87 15.54 15.13 14.84 14.37 14.04 13.92 13.73 13.53 **13.45** 13.44 13.49 … 14.08 (0.38 s) … 14.00 | 13.44 at 200 ms | 0.053 pt |

Drag to 54 pt right of the press on foot: width 16.23, centre +0.18 pt (model 16.18 / +0.18). On Finder (pointer 32 pt
out) the centre moved +0.05 pt against the model's +0.10 (the QML test reads the model's value exactly; the on-screen
half is not explained). Click on red closed foot, yellow minimised Finder, green took Finder full screen; a drag out
and release outside did nothing; two shots 1 s apart at rest are identical.

## 7. Unknown, and the Mac capture that settles it

- The size series itself on a Mac: a 120 fps screen recording of a held close button (press 1 s, then drag 50 pt out,
  release outside), dark, 2x. It checks 0.355 / 0.4, the release spring and the stretch. **Answered (sections 8, 9:
  60 fps): one spring both ways, measured 0.31 / 0.5; the stretch as decoded.**
- Hold still for 3 s: does the button drop back at 2 s (`idleTimeout`)? **Answered (section 9): yes, 2.10-2.12 s after
  the press, on the release spring; the pressed colour stays.**
- Disabled zoom button and an inactive window: do they lift?
- Whether the pressed colour change is animated (not found; built as a switch). **Answered (section 9): on in one
  frame, off on a 0.5 s critically damped fade when the pointer leaves the held button; built.**

## 8. Measured on a Mac recording (2026-11-14, MAC-ANSWERS-2.md M1.6)

`screens/27.2.1/windows/close-button-hold-drag.mov`: TextEdit, dark, 2x, H.264 with a 60 fps time base, variable frame
rate (60 Hz panel: 120 fps was not possible). Every frame extracted with its pts; the disc's left edge on the row
through its centre and its top edge on the column through its centre, at half coverage of the red channel between
the title bar and the disc (sub-pixel), the centre fixed from the rest frames (91.55, 71.47 px). Width = 2 x (centre
- left), height = 2 x (centre - top), in pt. The pointer sits on the lower right of the button, so those two edges are
clear of it.

| Phase | Mac series (pt per 60 Hz frame) | Fit | Ours before (decoded 0.355 / 0.4) | Ours after |
|---|---|---|---|---|
| Rest, hover | 13.8-14.1 x 13.99 | - | 14 | 14 |
| Press (0.400 s) | x 14.14 14.42 14.90 15.86 16.04 16.09 16.14 16.17 **16.19** 16.19 16.17 16.14 16.13 16.10 16.07 15.99; y 14.28 14.98 15.28 15.81 15.99 15.99 16.00 then 15.97-15.99 | 16 reached in about 70 ms, over by **0.19 pt at most** (x, about 0.14 s; y none). Best single spring over both axes: response **0.17 s, damping 0.65**, rms **0.128 pt** | peak 16.51 at 0.19 s: rms **0.294 pt**, peak error 0.53 | press spring 0.17 / 0.65: overshoot 6.8 %, 16.14 pt at 0.11 s (rms 0.128 against the Mac) |
| Held still 1.08 s (0.40 -> 1.48 s) | 15.98 x 15.97, no drop | - | - | - |
| Drag 50 pt right (1.48 -> 1.78 s) | x 16.07 -> 15.87, y 15.98 -> 15.91 (the left edge moves right 0.07 pt: the decoded stretch, 16.16 x 15.84 shifted 0.16 pt right, reads 15.84 from the left edge) | the decoded stretch, within 0.05 pt | same | same |
| Release outside (about 2.25 s) | x 15.60 14.73 14.33 14.19 14.09 14.01 13.89 13.75 13.65 13.55 **13.54** 13.56 13.68 13.80 13.84 13.93 13.98 14.02 14.03, y 15.73 15.29 14.97 14.67 14.23 14.04 13.98 13.88 13.82 13.75 **13.74** 13.74 13.83 13.88 13.93 13.98 14.00 14.01 14.03; last change at 3.18 s | dip 13.54-13.74 at about 0.17 s, back at 14 by 0.28 s. The decoded spring: rms **0.171 pt**; the best single spring (0.33 / 0.5) 0.145: a fast first drop (1.1 pt in 2 frames) that no single spring from rest gives | decoded (13.49 at 0.19 s) | unchanged |
| Action | none: released outside, the window stays | - | none | none |
| Idle end (2 s) | not testable in this clip: the pointer moved at 1.48 s (1.08 s after the press), and nothing dropped before | - | 2 s (inferred) | unchanged |

So the press is not the decoded `scaleSpringResponse` / `scaleSpringDamping` (0.355 / 0.4) on screen; the release is
close to it. Why (a second spring in AppKit's pressed state, or a different preset for cursor input) was not decoded.

**Superseded by section 9**: the 0.17 / 0.65 press spring fitted here was built and then replaced, the two cleaner
clips of section 9 put press and release on one spring.

Still unknown here: the 2 s idle end (section 9); disabled zoom / inactive window lift (section 10).

## 9. Held still for 3 s, dark and light (2026-11-14, MAC-ANSWERS-4.md R4.1)

`screens/27.2.1/windows/close-button-hold-still-{dark,light}.mov`: TextEdit, the pointer resting on the close button,
a synthetic mouse-down, 3 s without any pointer move, then a drag out (+80,+60 pt in 0.3 s) and the mouse-up outside;
the window stays open. 2x, 60 fps time base, variable frame rate, times from the pts. Same method as section 8 (red
channel in dark, green in light: the light disc has a darker rim and a white title bar), plus the mean colour of a
ring 4.5-5.75 pt from the centre on the left half (away from the pointer).

| Phase | dark (pt per frame) | light | 
|---|---|---|
| Rest, hover | 13.96 x 14.00 | 13.99 x 13.98 |
| Press | at 0.217 s: w 14.14 14.26 14.48 14.96 15.78 16.05 16.10 16.14 16.19 **16.21** 16.21 16.19 ... 16.08; h 14.18 14.57 15.00 15.21 15.75 15.93 16.05 16.16 16.40 **16.44** 16.44 16.40 16.25 ... 16.00 | at 0.417 s: w 14.55 15.03 15.58 15.96 16.06 16.21 16.55 16.74 **16.80** 16.80 16.79 16.70 16.58 16.44 16.21 ... 16.05, back up to 16.14; h ... **16.31** ... 15.90 -> 16.04 |
| Still | 16.08 x 16.00 from 0.62 s to 2.317 s, nothing moves | 16.13 x 16.02 to 2.533 s (one change at 1.30 s) |
| **Idle end** | at **2.317 s = 2.10 s after the press**: w 16.05 15.93 15.38 14.65 14.33 14.17 14.08 14.03 13.88 13.72 **13.58** 13.58 13.80 13.91 13.98 14.03 14.06 -> 14.08; h 15.98 15.87 15.42 15.03 14.91 14.27 14.02 13.97 13.87 13.71 **13.58** 13.58 13.77 ... 14.00 | at **2.533 s = 2.12 s after**: w 16.07 15.82 15.15 14.96 14.72 14.13 14.07 14.02 13.92 13.87 **13.87** 13.93 ... 14.16 (0.35 s) ... 14.09; h 15.96 15.42 15.14 14.71 14.30 14.10 13.95 13.78 13.57 13.51 **13.48** 13.59 ... 14.11 ... 14.02 |
| Colour at the idle end | unchanged: the pressed colour (ring 255,102,86; glyph 189,0,0) stays while the pointer is on the button | unchanged |
| Colour at the press | the pressed colour in the first press frame (one frame) | the same |
| Drag out (3.267 s / 3.517 s) | the colour fades back to rest (ring G 109.8 -> 76.5, glyph 195 -> 141) from about 3.37 s to 3.85 s | ring G 154.5 -> 108.1 from about 3.62 s to 4.1 s |
| Release outside | no size change (already 14), no action | the same |

Fits (least squares over the start time, `fit2.py`):
- Idle end = the same spring as the release: over the two idle ends and the section 8 release (6 series) the best
  single spring is response 0.31, damping 0.5 (rms 0.080 pt); the decoded 0.355 / 0.4: 0.106.
- Press over three clips (6 series): best 0.30 / 0.50 (rms 0.110); the decoded 0.144; section 8's 0.17 / 0.65: 0.140
  (it fitted the noisier hold-drag clip only).
- All 12 series together: **0.31 / 0.50, rms 0.096 pt** (0.30-0.315 alike), decoded 0.355 / 0.4: 0.126. So one spring
  both ways, as decoded, with its numbers measured: 16.33 pt at 0.18 s on the press, 13.67 pt on the way back.
- Idle end start: 2.10 s (dark) / 2.12 s (light) after the press, both from the first moving frame, so the screen's
  latency cancels: the decoded `idleTimeout` 2 s plus about 0.1 s (not decoded).
- Leave fade (the pressed colour going back when the pointer leaves the held button): a critically damped spring of
  response **0.5 s**, rms 0.009 of the way over both clips (CA default 0.5 s: 0.012; linear 0.3 s: 0.047), starting
  84 ms (light) / 102 ms (dark) after the drag starts. The pointer leaves the 7 pt disc about 20 ms into that drag
  (100 pt in 0.3 s), so the fade starts 60-80 ms after the pointer is off the disc (not explained: tracking-rect slop
  or the synthetic drag's event steps). Ours starts it when the pointer leaves.

Changed (measured): `ui/HyprK/Tokens.qml` `lights.liftResponse` 0.31, `liftDamping` 0.5 (the 0.17 / 0.65 press pair of
section 8 removed), `idleTimeout` 2100, new `leaveFade` 0.5. `ui/HyprK/TrafficLights.qml`: one spring again; a
`pressLook` spring (0 rest, 1 pressed) mixes the rest and pressed looks of the disc (the shader's table) and the glyph
colour: 1 in one frame on the press or when the pointer comes back, back to 0 on `leaveFade` when it leaves the held
button, at once on mouse-up. `plugin/src/LightPress.hpp` `SPRING_RESPONSE` 0.31, `SPRING_DAMPING` 0.5, `IDLE_TIMEOUT`
2.1, `LEAVE_FADE` 0.5 (PRESS_* removed); `plugin/src/Titlebar.{hpp,cpp}` `m_pressMix`: the rest textures, then the
pressed ones over them at the mix while it fades. Tests: `ui/tests/tst_traffic_lights.qml` (peak 1.159-1.175, the
leave fade in flight 40 ms after leaving, then 0), `plugin/tests/test_main.cpp` (peak 1.163 of the lift at about
0.18 s, undershoot 0.163 of the lift, idle end after 2.1 s), `shell/tests/run.mjs` (LEAVE_FADE = leaveFade).

Ours on screen (headless, scale 2, light, foot with the plugin built in the scratch dir and loaded through
`HYPRK_GLASS_SO`, `mcap -k 1`, mouse-down, 2.8 s still, drag +80,+60, up): press 14.19 14.67 15.04 15.25 15.76 15.99
16.10 16.20 16.27 **16.29** x **16.40** (0.18 s) ... 16.05 x 15.93; idle end at **2.09-2.11 s** after the press: 16.00
15.78 15.24 15.03 14.67 14.20 14.05 13.99 13.91 **13.84** x **13.83** (0.15 s) ... 14.05; leave fade ring G 122.6 ->
91.2 over about 0.5 s from the moment the pointer left. Against the Mac: peak 16.29-16.40 vs 16.21-16.80, idle end
2.1 vs 2.10-2.12 s, dip 13.84 vs 13.48-13.87.

Added later the same day: the fade's **start delay**. The cursor drawn in the clips leaves the 7 pt disc at 3.283 s
(dark: its tip at 14.2 px from the centre) and between 3.517 and 3.55 s (light); the fitted fade starts at 3.369 /
3.601 s, so **86 / 70 ms** after the pointer is off the disc. Built as `Tokens.lights.leaveFadeDelay` 80 ms (QML: a
timer before the fade's target moves) and `LEAVE_FADE_DELAY` 0.08 s (plugin: the pressed look held for that long after
leaving). Tests: the QML light keeps the full pressed look 30 ms after leaving, is mid-fade at 140 ms; `run.mjs` checks
the two constants agree.

## 10. Disabled zoom and inactive window (2026-11-14, MAC-ANSWERS-6.md R6.4)

`screens/27.2.1/windows/lights-zoom-disabled-press-dark.mov` (Calculator, key, its zoom disabled) and
`lights-inactive-press-dark.mov` (TextEdit behind the key Calculator), dark, 2x, variable frame rate, times from the
pts. Size: the centroid of the bright top rim (brightness over the face, column through the centre, cx +- 1 px)
against the fixed centre, in px = pt of diameter; it holds still while the rim blurs in motion, where the
half-crossing of sections 8-9 read a 51 % dip on the disabled release that is only the rim spreading over 2 px.
Colour: the upper-left quarter of a ring 4-5.5 pt from the centre (clear of the cursor drawn in the clips). Ours:
headless, scale 2, dark, `mcap -k 1`; the disabled zoom in a scratch QML window (`TrafficLights { zoomEnabled: false }`),
the inactive QML lights on the Finder behind it, the plugin's on foot behind it (plugin built in the scratch dir,
`HYPRK_GLASS_SO`).

| | Mac | Ours before | Ours after |
|---|---|---|---|
| Disabled zoom, colour | (60.5,61.7,66) at rest, hovered, pressed, released: never changes, never a glyph | no glyph, no press (MouseArea off) | (78,79,86) throughout, no glyph (the inactive table: 17 levels lighter, see below) |
| Disabled zoom, press | rim 13.67 -> **15.41 in one frame**, then no frame for 1.55 s (nothing moves) | nothing | 13.70 -> 15.50 in one frame, held |
| Disabled zoom, release | 15.39 15.18 14.89 14.61 14.30 13.84 13.59 13.45 13.24 13.19 **13.14** (0.18 s) ... 13.68 (0.30 s): dips 31 % of the lift | - | 15.38 15.05 14.70 14.45 13.98 13.73 13.70 13.58 13.48 **13.42** (0.15 s) ... 13.68 (0.27 s), dip 16 %; no zoom |
| Inactive, hover | pointer in at 0.383 s; at 0.400 all three in colour **with full glyphs** (minimize ink 66, then 66-68: no fade) | grey -> colour at once, glyphs after 70 ms + a 133 ms fade | QML (Finder) and plugin (foot): all in colour with full glyphs on the first frame, unchanged after |
| Inactive, press | close rim 13.60 -> **15.37 in one frame**, ring R 225 -> 236 (lighter: the pressed look) | the key window's spring (0.31 / 0.5, bounce) | QML 13.68 -> 15.20, plugin 13.67 -> 15.19, one frame; ring R 224 -> 229 |
| Inactive, release | the window closes, Calculator stays frontmost | plugin: focused at mouse-down | plugin: foot closes, the key window stays active (and `hyprctl activewindow` during a held press on the inactive foot's zoom is the other window; released outside, the lift springs back, dip 13.47 at 0.17 s); QML: unchanged, see below |
| Key window | (sections 8, 9) | spring 0.31 / 0.5 | unchanged: plugin foot rises to its peak and settles, released outside dips to 13.01; `tst_traffic_lights` peak 1.159-1.175, `lgtests` peak 1.163 |

Release spring of the disabled zoom (least squares over the start time, rim series): best single spring 0.335 s / 0.41
(rms 0.037 of the lift), the decoded 0.355 / 0.4 0.039, ours 0.31 / 0.5 0.057, the tracking spring 0.1 / 1.0 0.173
(no undershoot: OPEN-FIXES item 15's "back by 2.567 s, under by <= 0.1 px" stopped at the frame where the disc passes
rest). So the way back is the usual press spring; only the lift itself is instant. Kept 0.31 / 0.5 for all lights
(section 9's 12 series); this one clip prefers the decoded pair.

Built:
- `ui/HyprK/TrafficLights.qml`: the MouseArea is on for a disabled light; `down` needs `enabled_` (no pressed look),
  `onClicked` returns for it. `snapLift` (set at the press when the light is disabled, the window inactive or the
  hover began on an inactive window, `_enteredInactive`) makes the four springs `instant` while held; it goes off
  before `flex` at release / idle end, so the way back springs. An inactive window's hover sets `_glyphs` at once with
  the glyph Behavior off for that change (`_glyphSnap`, cleared by `Qt.callLater`); the fade-out is unchanged (not
  measured inactive). `_enteredInactive` is there because Hyprland activates a Qt window on the press (follow_mouse 2,
  `InputManager::processMouseDownNormal`) before the light sees it, where the Mac's stays inactive: Finder and
  Settings still become active on a light press (fixing it needs the light rects in the compositor; left). Done in
  section 11.
- `plugin/src/LightPress.{hpp,cpp}`: `press(..., snap)`: the targets are jumped to while held (`m_snap`), `release()`
  clears it. `plugin/src/Titlebar.{hpp,cpp}`: `m_glyphInstant` (the hover began on an inactive window) makes
  `glyphAlpha()` 1; the press snaps when the window was not active (read before any focus change); the bar focuses the
  window at mouse-down only off the lights (`hit < 0`): this hook runs before Hyprland's own refocus, which returns
  once a decoration took the button.
- Tests: `ui/tests/tst_traffic_lights.qml` (disabled zoom: 16 / 14 on the press, no pressed look, no glyph, no action,
  springs back with its undershoot; inactive: glyph opacity 1 on the hover, 16 / 14 on the press, the click acts, the
  fade-out still runs); `plugin/tests/test_main.cpp` (a snapped press is at the lift at once and still, the release
  springs with the usual undershoot, a later plain press springs).

Not changed, found on the way: (1) the disabled disc is the inactive table's grey, (78,79,86) against the Mac's
(60.5,61.7,66); the Mac's inactive grey in the second clip reads (66.8,65.8,71.2) on our ring metric, ours 75 (one
clip each, other window backgrounds: not fitted). (2) A key window's glyphs: the Mac's ink starts 50 ms after the first
hovered frame (zoom-disabled clip), ours 116 ms (the 70 ms `glyphDelay`, Q-windows-10, and the fade's first frame).

## 11. Qt windows: a light press does not activate them (2026-11-15, judge #21)

Mac (R6.4, `windows/lights-inactive-press-dark.mov`, section 10): a press on a light of an inactive window lifts and
lights it, the release closes it, and the app is never activated (the key window stays frontmost). Ours before: the
plugin's own title bar already did this (section 10), but Finder and System Settings draw their lights in QML, and
Hyprland focused and raised the window on the press (`InputManager::processMouseDownNormal`: `refocus()`, then
`windowState()->raise`) before Qt saw it.

Built: the client names its lights' rect per window class (`hyprctl liquidglass lights <class> <x> <y> <w> <h>`, window
px of the TrafficLights row: Finder `Hypr.setLights` in `finder/qml/Main.qml`, Settings `Backend.run(["hyprctl", ...])`
in `settings/SettingsApp.qml`, at start and whenever the window turns inactive), and `plugin/src/ClientLights.cpp`
hooks `processMouseDownNormal`: a plain left press inside that rect, on the window's own surface (hit test as
Hyprland's), with the window not focused and not full screen, goes through the keybinds (the `mouse:272` bind of
config/hypr/hyprland.lua still runs) and to the client, without the refocus and the raise. The release takes
Hyprland's path (the press is still in its held buttons, so the pointer stays on the window while held).

On screen (headless, scale 2, dark; foot key, the other window behind it, lights not covered), `hyprctl activewindow`
while the close light is held, then after the release:

| window | before (plugin without the hook) | after |
|---|---|---|
| Finder | active during the press: hyprk-finder | foot during the press and after; Finder closed on release |
| System Settings | (as Finder, judge #21) | foot during the press and after; Settings closed on release |

The held light shows the inactive press look (colour, full glyphs, the one-frame lift: `snapLift`). Not changed: a
press between the lights inside the row's rect does not focus either (the rect is the row's, 60 x 14 pt); a press with
Shift / Ctrl / Super keeps Hyprland's path.

## 12. Round 16: the dark lights in sRGB, and the inactive disc as a veil (R16.4, 2026-11-15)

Mac: `windows/lights-{finder,system-settings}-active-dark-{p3,srgb}.png`. Mean of the central 11 x 11 px:

| | close | minimise | zoom | inactive (Finder behind Settings) |
|---|---|---|---|---|
| raw numbers of the P3-tagged file | 224.8,101.4,88.4 | 243.1,193.6,34.1 | 93.1,188.5,33.4 | 72.7,74.6,75.3 |
| sRGB (`sips`; `p3_to_srgb` gives the same within 6 in blue) | 242.3,91.2,81.2 | 252.5,191.2,5.9 | 35.7,191.5,12.7 | 72.7,74.6,75.3 |
| `lights_model.py` table (unchanged) | 242.0,90.2,81.0 | 253.2,192.0,5.3 | 32.1,191.0,10.7 | |
| ours on screen (`lights-colour.py`, Finder and Settings) | 242.0,90.2,80.9 | 253.2,191.9,5.2 | 32.1,190.9,10.7 | |

- **Minimise and zoom are settled: no change.** The "(243,193,31) (92,188,30) against ours (245,186,8) (31,184,12)" of
  OPEN-FIXES 36 compared the Mac's raw P3 numbers with our sRGB pixels (`sheet-depth.py` reads its reference still
  unconverted). Body rms of the table against the new still: close 3.4, minimise 4.4, zoom 9.4 (the caustic's shape).
- **Inactive, dark: corrected.** The disc is a white layer over the window, not a grey: (72.7,74.6,75.3) over (35,38,39)
  here and (76,76.5,82) over (39,40,47) in `lights-inactive-dark.png` are both alpha .170 in the centre (.195 under
  the top rim, .15 above the bottom one). The opaque table (78,79,86) carried the first crop's blue bar. New row
  (`VEIL` in lights_model.py): T 50, M 47, B 33, rim 238 as alpha x 255, fitted on the old crop; against the new
  still body rms 1.5 (opaque 4.9), centre (72.2,74.7,75.5). Drawn by `shaders/lights.frag` (rimE.w) and
  `Titlebar.cpp lightTexture` (`veil`). On screen: alpha .161-.169 centre, .19 top, .14 bottom over our (36,38,43) and
  (36,38,55) bars. The "75 against 67" of section 10 was the same thing: other bars under the same layer.
- In the Finder-frontmost still the Finder window covers Settings' lights, so only Finder's inactive discs exist.

Open: the light inactive disc is still opaque (no second light still); the disabled zoom takes the same veil (the
clip's (60.5,61.7,66) over (25,26,31) is alpha .155, video levels); the compositor-drawn bars were built
(scratch build, `lgtests` pass) but not shot. plugin/build needs a rebuild.

## 13. Round 17: inactive windows again, lights under a sheet, the title (R17.4, 2026-11-15)

Mac, `live/r17/{in,}active-titlebar-{light,dark}.png` (TextEdit, 11 x 11 px means at the disc centres, rows 18..45 px):

| | lights | title "Untitled" (extreme px) | bar |
|---|---|---|---|
| dark, inactive | (75,75,79) x 3 | (105,105,110) | 39,39,44 |
| light, inactive | (242,242,244) x 3 | (183,183,183) | 255 |
| dark, active | (225,101,88) (243,194,34) (93,189,33) | (164,164,169) | |
| light, active | (234,132,122) (245,203,88) (152,213,111) | (88,88,88) | |

- Dark inactive disc: the white layer of section 12, alpha .17 over the (39,39,44) bar = 75.7. No change.
- Light inactive disc: the table's opaque (239,240,242) middle; on screen (Qt, Finder) (241,242,244), the compositor's
  bar the same rows (242 at the centre). No change. Over a sidebar it is not opaque on the Mac (GLASS-HIG section 23,
  "Left").
- Title, compositor-drawn bars (`plugin/src/Titlebar.cpp`): dark white .58 / .30 = 163 / 101 over our 36 bar (Mac 164 /
  105 over 39): no change. Light inactive read **191** (`titlebar_text_inactive` black .25), the Mac's 183: now black
  .282 (`0x00000048`, `plugin/src/Config.cpp`), **183** on screen (scratch build loaded with `hyprctl plugin load`).
  `plugin/build` needs a rebuild.
- **Conflict, not changed**: the light active title reads 88 here, `titlebar_text` is black .70 = 76 from Q-windows-11
  (TextEdit #4C4C4C) and System Settings' toolbar title is #4C4C4C too (Q-settings-13). Two older readings against one
  new still; a capture of the same title on both builds would settle it.
- Qt windows have no title-bar title; their toolbar titles keep Q-settings-06 (189 / 92 inactive).
- Section 11 (a light press does not activate a Qt window) is still listed by judge #24; checked again here (headless,
  dark, foot key, Finder behind): active window `Key` before, on hover, while the close light is held and after;
  Finder closed on release. Nothing to fix; the judge's session needs a plugin build that has `ClientLights.cpp`.
- Under a sheet the lights are left out of the veil: GLASS-HIG section 23.

## 14. The light inactive disc is a layer too; the disabled close under a sheet (2026-11-15)

Mac, the grey disc's central 11 x 11 px and its profile through the centre, at 2x:

| still | bar under it | centre | side rim, outer 2 px | top 3 px / bottom 3 px |
|---|---|---|---|---|
| `windows/lights-inactive-light.png`, `live/r17/inactive-titlebar-light.png` | 255 | 241.2,241.7,244.0 | 172 217 | 235 242 246 / 246 240 232 |
| `settings/desktop-dock-inactive-light-iconTintedDark.png` | 242 | 233.4,234.0,236.2 | 168 210 | 227 233 237 / 237 232 224 |
| `finder/sheet-light.png` (close under a sheet) | 236,237,238 before the veil, 197 veiled | 229.1,230.0,233.2 | 166 208 | 216 226 233 / 233 225 215 |
| `live/settings-r13/dest-controlCenter--clock-options-light.png` (the same) | 236,237,238 / 197 | 229,230,234 | 166 207 | 224 230 234 / 233 228 221 |
| dark: `clock-options-dark.png`, `finder/sheet-dark.png` | 35,37,52 before, 26,26,35 veiled | 72.1,73.8,85.9 / 72.9,73.7,86.7 | 76 78 | 179 127 82 / 72 117 171 |
| dark: `windows/lights-inactive-dark.png` | 39,40,47 | 75.3,76.1,81.8 | 76 79 | 180 127 82 / 73 117 173 |

- **Light: the disc is not opaque.** .60 (242 bar) to .65 (236.5 bar) of the bar's change shows through the body, .31
  through the side rim's outer pixel. This is the second light still section 12 left open. `TrafficLights.qml`
  `inactiveThrough` .63, `shaders/lights.frag` rimE.w between 0 and 1: premultiplied `col - t`, alpha `1 - t`, t =
  through x (1 - rim weight); the table's row stays the disc over white, so white bars and the compositor's bars
  (`Titlebar.cpp`, always over its own flat bar) do not change. Not modelled: the top and bottom edge pixels (235 / 232
  over white, ours 248 / 249).
- **Under a sheet, close is the inactive disc over the bar as it was before the veil, in colour**: dark white .17 over
  (35,37,52) = (72.4,74.1,86.5). Ours read (75,75,75): Settings drew its whole window without saturation under the
  veil, the bar in the hole too. Minimise and zoom are the active window's to the pixel, rims included (yellow's side
  rim (144,25,9) / (144,26,10)); only their outermost edge pixel differs (it blends with the veiled bar).
- On screen (headless, 2x): Settings light (230,231,233) (Mac (229,230,234)), dark (72,74,86) (Mac (72,74,86)); Finder
  light (230,231,234), dark (73,75,89) (Mac (229,230,233) / (73,74,87)); side rim light 159 211 (Mac 166 207).

