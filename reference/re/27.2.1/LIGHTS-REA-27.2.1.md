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
  release outside), dark, 2x. It checks 0.355 / 0.4, the release spring and the stretch.
- Hold still for 3 s: does the button drop back at 2 s (`idleTimeout`)?
- Disabled zoom button and an inactive window: do they lift?
- Whether the pressed colour change is animated (not found; built as a switch).
