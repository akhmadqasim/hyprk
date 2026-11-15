# Window toolbar: the scroll pocket and the pressed platter, macOS 27.2.1 (26B131)

Round "toolbar" (2026-11-14). The user, next to a real Mac: (A) the bar over scrolled content "must have a blur I
cannot put into words"; (B) holding Back "is not smooth, boxy like 8-bit".

Sources: the 27.2.1 dyld cache (`~/Downloads/macos/dyld-27.2.1`) read with `ipsw dyld disass / xref / a2s / dump`;
objc stubs resolved by disassembling the cache's stub island (0x190000000.., 170 000 instructions, scratch
`~/Downloads/macos/re-work/toolbar/island.asm`) and each `objc_msgSend$sel` stub's `add x1, ..; <selector>`; AppKit
regions saved under `~/Downloads/macos/re-work/toolbar/` (`platterview.ann`, `configPlatters.ann`, `gev-region.asm`,
`tabbtn.ann`, `pocket/region.asm`, `pocket/soft.asm`). The live layer dumps in this folder (`live/toolbar/`,
`live/glass-params-*.json`) and the Mac screenshots in `reference/screens/27.2.1/settings/`. Ghidra / REA were not
needed (every function here disassembles with ipsw; no decompiler output is quoted).

Every value is marked **decoded** (address), **dumped** (a live layer dump of the Mac), **measured** (a Mac
screenshot), **fitted** or **GUESS**.

## 1. (A) The scroll pocket under a toolbar: the ThinFilm pocket

### What AppKit builds
- `-[NSToolbarView _scrollPocketElementStyle]` 0x18ad147cc and `NSTitlebarView` 0x18af1504c return 2 (decoded): a
  scroll view under any window toolbar gets the same pocket; `NSToolbarPlatterView._scrollPocketElementStyle`
  0x18af26840 forwards it.
- The pocket the dump shows (`live/toolbar/toolbar-unified-{light,dark}.json`, the two `NSScrollPocket > CALayer >
  CABackdropLayer` over 144,508 836 x 52) is built by **sub_18b45e6d8** on its "ThinFilm" path (0x18b45e88c ..
  0x18b45ed40, behind the feature flag at data_1eb436070). It makes two layer descriptors, in this order (array copied at
  0x18b45ef74 / 0x18b45f174), bottom first (decoded; the order matches the dump's surface order):
  1. **ThinFilmBackgroundReplay**: a backdrop layer that replays the scroll view's background (the capture is the
     plain `NSScrollView > BackdropView` backdrop under the content in the dump) over the content. Opacity 0.6 dark /
     0.5 light (dumped). Colour matrix: saturation `max(0, 1.25 - 0.25 / opacity)` = .833 / .75 (0x18b45ed94 ..
     0x18b45edb4), bias 0, gain 1 (decoded; matches the dumped first row 0.8688 0.119 0.0121 / 0.8032 0.1787 0.0181).
  2. **ThinFilmContentBlurFill** (0x18b45f010): a `variableBlur` backdrop, then `colorMatrix` saturation 1.25
     (0x18b45f0c4; dumped row 1.197 -0.179 -0.018), then `sdrNormalize` clamp.
- The variableBlur (decoded; shader `variable_blur_frag_lpf` in the QuartzCore metallib, `air-qc/simp/`):
  - `inputRadius` = 2 + 0.5 x clamp((h - 52) / 38, 0, 1) (0x18b45efd0): 2 pt for the 52 pt band.
  - The mask (`inputMaskImage`) is 1 x (128 x scale) px, 256 at 2x, made by 0x18b4635d0 -> 0x18b495384
    (CGImageCreate, 8 bpc, sRGB). Red = the blur ramp, green = the fill ramp.
  - Red: lerp(0.25, 1.0, easeInEaseOut(u)) (0x18b45f070 .. 0x18b45f0a0, the curve set at 0x18b4952bc), 1 at the
    band's outer (top) edge, 0.25 at the content side, over L = min(1 - clamp(a / h), 64 / h) of the band (a = 0 here,
    so the whole 52 pt). Green: 1 everywhere (0x18b45f0ac).
  - Per row: blur radius = inputRadius x R. The fill blur has its own constant radius `inputBlurFillBlurRadius` 16.
  - Fill blend (shader): `out = l G max(v, b) + d G min(v, b) + (1 - (l + d) G) v`, then `mix(out, b, n G)`, where
    v is the variable-blurred input and b the 16 pt blur. Opacities (0x18b45ed44 .. 0x18b45ed80, = the dump):
    dark darken .6 / lighten .4 / normal 0, light .4 / .6 / .25.
- Separator (0x18b463018 / 0x18b462f78, decoded): 0.5 pt at 2x (round(scale x 2/3) / scale), white a .07 dark /
  black a .10 light (.125 under a flag, .65 with Increase Contrast). Whether the ThinFilm pocket draws it is not
  decoded; Settings keeps its measured 0.5 pt hairline from the first scrolled frame (Q-settings-04).
- Fade: `FadeOnScroll` on, `FadeMinimumPocketAlpha` 1.0 (defaults at 0x18b468f18): inferred, the pocket never fades
  out. When it first shows (alwaysShownPocketEdges, occupancy) is not decoded; ours shows from the first scrolled
  frame (Mac shots: unscrolled bands are plain).
- Sidebar ("SoftPocket", builder 0x18b45f278, applied by 0x18b465218; the dump's 0,508 144 x 52 layers): a
  variableBlur kind 1, radius 1, inputFade 1, mask from 0x18b463194 (coverage 1 for the top 12 pt, 0 for the bottom
  10 pt, linear between), plus a destIn CAGradientLayer (0.5 / h .. min(30.5 / h, 1), factor .85). Not built: our
  sidebars do not scroll under the toolbar.

### Not decoded
- CA's radius convention (sigma per radius) and whether the backdrop renders at a reduced scale. Fitted below.
- The replayed background's colour (the dump shows a backdrop, not a colour): solved from the Mac.
- A conflict in the flag bits: saturation 1.25 on the blur layer needs flag bit 0 clear, and with bit 0 clear the
  code also gives the replay layer a 16 pt gaussian at backdrop scale 0.25, which the dump does not show. Built as
  the dump shows (no gaussian on the replay).
- What makes the inactive window's strip lighter (`NSScrollPocketConditionalThinFilmOnInactive`, set true at
  0x18b460ae4; GAPS-REA-windows 1c).

### Fit and before / after (Mac to Mac)
The Mac's own unscrolled frame is the input: `appearance-scroll-000-*.png` rows 500..604 px (content 250..302 pt) are
exactly what lies under the band of `appearance-scroll-250-*.png` (row match 0.014 levels dark). Region x 900..1390 px
(the preview photo; the toolbar title and capsule left out), 2 px/pt, no colour conversion (both are the same space).
Script: scratch `agent-t/py/fit*.py`. rms in levels over the 52 pt band:

| model | dark | light |
|---|---|---|
| no pocket | 54.5 | 118.4 |
| before: even 8 pt blur, sequential blends, flat veil after (old ScrollEdge) | 9.18 | 10.84 |
| decoded, sigma = radius / 2, replay at the dumped .6 / .5 | 8.17 | 16.04 |
| decoded, sigma = radius (2 -> .5 pt, fill 16 pt), dumped .6 / .5 | 6.36 | 9.37 |
| **built: sigma = radius, replay .7 / .55 (fitted)** | **2.99** | **6.78** |

Per row (13 px bands, top to bottom), built: dark 5.1 3.3 2.7 2.3 2.2 2.1 2.3 2.6, light 11.6 8.9 6.6 5.3 3.6 2.9
3.2 7.1 (before: dark 14.6 11.8 9.8 8.3 6.8 6.8 6.0 5.4, light 15.8 13.3 10.8 9.6 8.7 10.0 9.2 6.7). The top rows,
where the variable blur is widest, still carry most of the error. The replayed background colour: dark (46,46,50)
(solved from the band over plain window (30,31,36) -> (39,40,45) and card (37,38,43) -> (41,42,48), the earlier
ScrollEdge fit), light white.

Built: `ui/HyprK/ScrollEdge.qml` (header, `veil`, `sigma` 16, `radius`, `replaySat`) and
`ui/HyprK/shaders/scrolledge.frag` (replay first, then the variable blur on the red ramp and the fill blend, then
saturation; smoothstep stands in for CA's easeInEaseOut). On screen (headless, scale 2, Settings > Appearance
scrolled 235 pt, our own unscrolled frame as the input) the shader matches the Python model within 0.7..1.1 levels
per row in dark and 1.5..1.8 in light (the first 6 pt row also holds the window's top rim).

### Finder
Finder's icon view now runs under the toolbar with the same pocket (`finder/qml/Main.qml` `keys.underToolbar`,
`IconView.topInset`): at rest the first row stays 10 pt under the toolbar; scrolled, icons and labels smudge under it.
Source for "the Mac scrolls Finder content under the toolbar": MAC-ANSWERS Q-windows-14 (icons blur under the strip)
and the decode above (every toolbar gets the ThinFilm style). Not done: list view (dark keeps its measured hard strip,
Q-finder-17), columns and gallery (no Mac capture of them scrolled), and the band colour over plain Finder content
(the Settings-solved background is used: GUESS for Finder). A Mac capture of Finder's icon view scrolled 100+ pt,
dark and light, would settle it.
Update (R5.4, GLASS-HIG.md 15): the band over plain Finder content is measured ((31,31,36) -> (39.3,39.4,45.1) dark,
255 light) and the dark background re-solved at 0.7 to (43,43.5,48.5); Finder draws the separator line while scrolled;
both blurs read the band's own rect only. The Mac's list view is not a hard strip: rows show through the header at
about 10 % (not built). The 36 pt shots put icon tops only 1 pt under the band: a deeper scroll is still wanted.

## 2. (B) Holding a toolbar button: SwiftUI's FlexInteraction lift and glow on the whole platter

**Corrected 2026-11-14 (round 7, INTERACTIVE-GLASS-REA.md 6, 1b).** The "no lift, an even 0.1 layer" below was read
off a still whose pressed panel already had the Back button's history menu open (the menu's top shows at the bottom of
the third panel). The round 7 clips (`controls/hold-shine-{settings,finder}-{dark,light}.mov`, 60 Hz) show the press
before the menu opens (about 0.3 s after the press): the capsule lifts about its centre (rims −3 / +3 px left / right,
−1 / +1..2 px top / bottom: +3 x +1.5 pt; the decoded ultraSmall lift on one 74 x 36 glass is +2.5 x +1.2) and the
light falls off from the pointer over the whole capsule (dark, held − hover: +37 / +25 / +21 / +15 at 9-15 / 18-21 /
30-33 / 48-51 pt), the face going to 255 in light. Once the menu opens the lift ends and the capsule stays lit about
evenly (+19, `hold-shine-settings-dark.mov` 1.383 s): that is what the still caught. So the platter's one interactive
NSGlassEffectView (decoded below) shows FlexInteraction on the whole capsule as one entry; the "Not decoded" question
"why no glow or lift" is void. Built: `ToolbarHighlight` `platter` = one entry (lift and glow by the whole capsule), no
even layer; ours has no history menu, so the menu-open look is not drawn. The text below is kept as it was written.

### What the Mac shows (measured, `settings/toolbar-backforward-rest-hover-press-dark.png`, 2 px/pt; the pressed panel has the history menu open)
- The capsule is 146 px wide (x 16..162, 20..166, 24..170 in the three panels): **no lift** while pressed.
- Row 52 px through the capsule: rest 62; hover 69 with a 89 disc (the strip under it 32 -> 40); pressed **85..88 end
  to end** with a 110 disc: no square, no gradient (the SwiftUI BigGlow would leave a hard edge 27 pt from the pointer,
  which is what ours drew: 98 up to that edge, then 84 -> 79).
- The divider hides in the hover and pressed panels.

### Who draws the capsule (decoded)
- `-[NSToolbarPlatterView initWithFrame:]` 0x18af2584c: one `NSGlassEffectView` over the whole capsule,
  `set_effectIsInteractive: YES`, `set_flexInteractionSources: 1` (interaction only); no variant set
  (`effectInteractiveVariant` getter 0x18b30ca0c falls back to `.automatic`). `_NSToolbarConfigurePlattersOnItems`
  0x18af24b5c assigns the platters to item groups.
- NSGlassEffectView renders through SwiftUI: `_Glass.explicit(Material.statefulProvider(DesignLibrary
  .GlassMaterialProvider(...)))` then `_Glass.interactive(_:configuration:)` with `FlexInteraction.Configuration
  (behaviors:variant:activation: .automatic, sources:)` (0x18b30f500 .. 0x18b30f6c4).
- The glass material has an interaction state: `GlassMaterialProvider.Configuration.interactionState`
  (`DesignLibrary.InteractionState` idle / disabled / rollover / pressed / deeplyPressed, fields.txt) and
  NSGlassEffectView `_interactionState` (init 0, 0x18b30a884). `-[NSTabBarViewButton setHasMouseOverHighlight:animated:]`
  0x18aeace90 sets `_interactionState = 2` for mouse-over (0x18aeacee4: `csel x2, #2, xzr`): **2 = rollover**,
  so 1 = pressed (inferred from that and from the fit below).
- The material's interaction layer (dumped, `live/glass-params-{dark,light}.json`, `regular+_interactionState=1|2`,
  layer `0:CALayer`, backdrop-aware vibrantColorMatrix over the whole glass shape): rgb' = 0.3125 rgb + 0.9375
  (dark) / 0.3125 rgb - 0.25 (light); alpha **0.1** in state 1, **0.05** in state 2, 0 at rest. Composited as
  c + a (clamp(M c) - c) (GLASS-INTERACTION.md 8, Verify B's law).
- Check against the Mac panel: state 1 on the hover panel's face (about 65 under the lit strip) gives 84 (Mac 85..88),
  on the 89 disc 106 (Mac 110); state 2 would give 78.

### Not decoded
- The call path that sets the toolbar platter's `_interactionState` while a button is held: `set_interactionState:`
  (stub 0x190081da0) has three AppKit callers (NSTabBarViewButton, `_NSCampoTextFormattingBackgroundView`
  sub_18b53e0e0, a key-path thunk 0x18a725f28); none is toolbar code. So the platter's pressed state reaching the
  material is **inferred** from the Mac panel (even +16, the numbers above), not traced.
- Why the Mac shows no FlexInteraction glow or lift on the platter although the glass is `.interactive` with
  `.automatic` (ultraSmall: BigGlow .75, 54 pt square): not found. Inferred: the flex gesture does not see the
  button's mouse tracking. The panel is one still: a recording of a held Back would settle the timing too.
- The layer's timing: GUESS, the 0.5 s critically damped spring (at 80 ms a quarter in, which agrees with
  MAC-ANSWERS Q-finder-10 "pressed looks the same as hover at 80 ms").
- Hover: whether the toolbar platter takes state 2 on hover. Not drawn: the Mac's hover capsule (69) reads the strip
  change only (+8 strip, +7 capsule); state 2 would add about +10.

### Built
- `ui/HyprK/motion.js` `platterMatrix`, `platterPress` (+ alphas); `ui/HyprK/ToolbarHighlight.qml` `platter`
  (default on with a `source`): no glow, no lift, `platterPress` springs to 0.1 while held; `pressed` exposed.
  `ui/HyprK/LensGlass.qml` `platterPress`; `ui/HyprK/shaders/glasslens4.frag` `platter` uniform (the layer after the
  glow; drawn opaque when it is on, since light darkens). Settings' back / forward divider hides on hover and press
  (`settings/SettingsApp.qml`); Finder's already did. The Appearance preview's SwiftUI glass buttons keep the decoded
  FlexInteraction glow (recording-verified, GLASS-INTERACTION.md 14).
- On screen (headless, scale 2, Settings back / forward, held 0.6 s), row 102 pt: dark rest 71, hover disc 88..90,
  pressed **91 flat end to end** with the disc 106..108 (was 98 up to a hard edge, then 84 -> 79); light 253 -> 229
  flat (no Mac capture: **unverified**). Finder's back / forward, dark: 71 -> 82 outside the disc, 90 -> 99 on it.

### Hover wash, disabled buttons, Finder (2026-11-14, judge-95-16 change 5)
- Rechecked on the Mac panel, row 52 px (G): rest strip 31, capsule 61; hover strip 39, capsule 68, disc 88; pressed
  strip 39, capsule 83..85, disc 107..108 (measured). The press over the hover panel is capsule +16, disc +19.5:
  alpha (84 - 68) / (255 - 68) = .086 and (107.5 - 88) / 167 = .117 under c + a (1 - c); the decoded .1 sits between
  and stays. The rest of the Mac's gain (+23 / +46 from rest) is the hover: the **whole strip lightens** while the
  pointer is in the toolbar, strip and capsule alike (8 / 224 = 7 / 194 = white .036; Finder Q-finder-10 (32,33,39) ->
  (39,41,47), .031 .. .037), which ours did not draw.
- Built: `settings/Theme.qml toolbarHoverWash` (.036) and `finder/qml/Theme.qml color.toolbarHoverWash` (.034), drawn
  over the toolbar while hovered, dark only. `ToolbarHighlight.disabled` (per centre): a disabled button gets no disc
  and no press light (Q-finder-10 "Disabled: no hover"). Finder: the capsule's light, not `ToolButton.lit`, drives the
  divider (the light's HoverHandler sits over the buttons, so they never saw the hover: the divider stayed), and the
  button's own pill is off where the light draws the disc (on press both lit it: disc 121).
- On screen (headless, scale 2, dark, row 22 pt; rest / hover / press): Settings strip 31 / 39 / 39, capsule 60 / 67 /
  85, disc 85 / 103 (Mac 61 / 68 / 84, disc 88 / 107.5); Finder capsule 62 / 69 / 87, disc 87 / 104. A disabled half:
  nothing lights, the divider stays. Light (Finder): pill 242 on 252 on hover (Q-finder-10), pressed capsule 253 -> 229
  from the decoded formula: **unverified** (no Mac capture). The disc stays 3..4.5 under the Mac (the hover lift,
  Tokens.toolbar.hoverLift, from the 23.09.23 recording).

## 3. Wanted from the Mac
1. A 60+ fps recording of holding Back in Settings and in Finder, dark and light (timing of the layer, whether any
   glow or lift appears, hover vs press).
2. Finder icon view scrolled 100+ pt under the toolbar, dark and light (band colour over plain content).
3. A layer dump of a held toolbar platter (`_interactionState` value while pressed).
