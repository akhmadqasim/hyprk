# liquidglass: macOS 27 Liquid Glass for Hyprland 0.57.2

Own plugin (C++ + GLSL ES 3.00). It draws the Liquid Glass material behind chosen layer-shell surfaces
(the hyprk shell: menu bar menus (not the bar: it has no glass on 27.2.1), dock, Control Center, notifications, Spotlight, Cmd+Tab).
Math follows the macOS 27.2 QuartzCore `glass_background_*` shader recovered in
`/mnt/code/liquid-glass-re/SPEC.md`: Apple's quarter-circle bevel for refraction, 7-tap chromatic aberration,
erfc-shaped drop shadow, the 27.2.1 rim (dark specular + key/fill highlight), mip-LOD variable blur.
Per-material numbers are not recovered (SPEC section 4), so every number is a config key with a
by-eye default.

## Build

```sh
source /mnt/code/hypr-dev/env.sh      # pkg-config must find hyprland 0.57.2
cmake -S . -B build -G Ninja && cmake --build build
ctest --test-dir build                 # pure-logic unit tests
```

Output: `build/libliquidglass.so` (the shader is embedded; `shaders/liquidglass.frag` is the source).

## Load

```sh
hyprctl plugin load /mnt/code/hyprk/plugin/build/libliquidglass.so
```

or in `hyprland.lua`, before the config block:

```lua
hl.plugin.load("/mnt/code/hyprk/plugin/build/libliquidglass.so")
hl.config({ plugin = { liquidglass = {
    namespaces = "hyprk-dock,hyprk-overlay,hyprk-notifications,hyprk-spotlight,hyprk-switcher",
    radii      = "hyprk-dock:26",
} } })
```

Live change: `hyprctl eval 'hl.config({ plugin = { liquidglass = { refraction_scale = 0.5 } } })'` (read every frame).
Check a value: `hyprctl getoption plugin:liquidglass:refraction_scale`.

## How a surface gets glass

1. Its layer namespace is in `namespaces` (`*` = every layer).
2. Shape: if the client sets an ext-background-effect blur region (Quickshell:
   `BackgroundEffect.blurRegion: Region { item: bg; radius: 24 }`), each connected part of the region is one
   glass rounded rect. The corner radius is read back from the region's staircase (see Corners), unless `radii` or
   `default_radius` sets it. Without a region the layer is left to Hyprland (`require_region = 1`, default),
   or the whole layer box becomes glass (`require_region = 0`).
3. The surface itself should be transparent where the glass is (draw only content, or a light tint on top).
   Hyprland's own blur for that layer is switched off while the glass draws, so they never stack.

The backdrop is Apple's blur pyramid (MAC-ANSWERS C3 2), built by the plugin from a copy of what lies under the glass:
level 1 is the 2x2 box (Apple's backdrop at scale 0.5), every deeper level the one above through Apple's 13-tap
downsampler; each read is one trilinear tap at `log2(1 / scale) + lod(1.6 r texels-per-pt)`. Hyprland's
`decoration.blur.*` no longer feeds the glass (it still blurs layers without glass).

## Corners

The shape is QuartzCore's own: a port of `CA::OGL::Metal::ShaderUtils::supercircle_sdf` (27.2.1 metallib,
`reference/re/27.2.1/decomp/QuartzCore-metallib-glass_background_sdf_all_lpf.ll`; `sdBoxN` in the shader, `sdRoundedBox`
in `src/Shape.cpp`). A continuous corner of radius r spans E = 1.528665 r along each edge; where a half side is shorter than
E it goes over to the circle of radius r (`cap = (1.528665 - half / r) / 0.528665`, the rule `compute_sdf_with_mode` applies
to a continuous radius), so circles and capsule ends stay round while a capsule's long edge still leaves the flat 1.53 r
from its end. Every glass uses it (the Mac's shapes are `RoundedRectangle(style: .continuous)` / Capsule); window glass
and title bars keep Hyprland's superellipse, which the window itself is clipped with.
Until 2026-11-11 the corner was an Lp superellipse of power 2.6 and extent r. On the real Control Center slider tile
(292 x 64, r 24) over 4 pt stripes the top edge 11..46 pt from the tile's end is off by 1.36 px rms with that curve and by
0.16 px with Apple's, and the rim rows 0..4 px below the top, read across both corners (crop x 40..556), went from peak to
peak 118 / 31 / 40 / 3 / 4 to 135 / 98 / 82 / 48 / 31 (Mac 140 / 103 / 91 / 52 / 33): judge #4's "flat rim rows" were the
corner starting 12.7 pt late, not the rim. `tools/check_model.py` step 7 keeps the port, the Mac contour and those rows.

The radius comes from the region's top left staircase. Quickshell rounds a Region with Qt ellipse regions of a whole radius,
and Qt's ellipse is a flattened polygon, so the circle formula read 12 as 13.7, 31 as 37.1 and 32 as 38.2; `cornerRadius()`
now knows Qt's staircase per radius (rows to the left edge + cells left out, 1..128, Qt 6.10.2) and returns that radius
exactly, the formula for any other staircase. 2 and 4, and 3 and 5, make the same region (read as 4 and 5).

## Motion (materialize, merging)

Liquid Glass does not fade: it *materializes* (WWDC25 "Meet Liquid Glass": it appears by modulating its
light bending and lensing). In SwiftUICore 27.2 the materialize transition animates each glass entry's
scale (hidden: x min((dim + 16) / dim, 1.2) per axis around its centre), opacity and a 10 pt blur on the
transition spring (response 0.5, damping 0.7) (`/mnt/code/liquid-glass-re/notes/round3`). Here the shell
animates the scale; the plugin takes a materialize progress `m` (0..1) per shape, softens the edge by
10 pt x (1 - m) and ramps every effect from identity to the full material in the shader: refraction, aberration, outer layer, edge bleed,
blur (the variable-blur amount, so the backdrop goes from sharp to frosted), blur fill, face YCC (from
(0, 1, 1) = untouched), fill, rim, drop and ring shadow. At `m = 0` the glass draws
the backdrop unchanged; layer alpha stays 1. The shell drives `m` with its open/close springs.

Channel: a 1x1 **hole** in the shape's own region, in its middle row (y = top + floor(h / 2)), at
x = left + 1 + round(m (w - 3)) (shell/components/Glass.qml `materialize`). Shapes without a hole are at 1.
The older window-wide opacity marker (1x1 rect in the surface's bottom row, x = opacity x (W - 1)) is still
read and still fades the whole layer.

Sub-point edges: a region is whole logical px, so glass that scales (HUD appear 0.9 -> 1, Control Center modules) grew in
1 pt steps per edge, and the last step lit the final rim rows in one frame (HUD alpha 0.55 -> 0.76, judge #3). Two more
1x1 holes carry the true edges: row mid - 4 for left / right, row mid - 5 for top / bottom, at
x = centre - floor(n^2 / 2) + i1 n + i2 with centre = left + floor(w / 2), n = min(17, floor(sqrt(w - 3))),
i = round((d + 0.5)(n - 1)) and d = true edge - region edge in [-0.5, 0.5] (1/16 pt steps on wide shapes). Both rows or
none, shapes at least 12 pt tall; a capsule or circle then takes half its true size as radius. Without them the box stays
whole points.

Merging: SwiftUI passes `GlassEffectContainer(spacing:)` (default 8 pt) straight to `CASDFLayer.smoothness`,
and QuartzCore unions the element SDFs with a normal-aware polynomial smooth min: `k' = k (0.5 - 0.5 nA.nB)`,
`h = sat(0.5 + 0.5 (dB - dA) / k')`, `d = mix(dB, dA, h) - k' h (1 - h)`, `n = mix(nB, nA, h)` (facing edges
across a gap blend over the full k, parallel edges stay sharp). The plugin does the same with `k = spacing`
for shapes of one layer closer than k (drawn as one group, max 8): gaps below k / 2 fuse, below k they reach
toward each other, farther apart the glass is pixel-identical to separate shapes. The shader also takes the
normal for refraction and the rim from this union (no finite differences).
A group uses the recipe values of its largest shape (Apple's `minimumDistanceOfLargestArea`), and per-pixel
materialize blends across the smooth zone like the distance. This makes a pressed, swelling Control Center
module bridge to its neighbour and lets shapes moving together morph into one.

No pointer light: on 27.2.1 the light is fixed in layer space (key top, fill bottom, dark lines left and right);
pointer, window position and Control Center / Dock hover change nothing (MAC-ANSWERS PC #67 B 4). Only glass
buttons react (hover: uniform +20 levels; press: a soft glow, sigma about 26 pt, at the pointer): not done here, the
plugin does not know which shapes are buttons. `pointer_light*` keys are accepted and ignored.

`reduce_motion = 1` (the shell sets it from Settings > Accessibility > Reduce motion) turns off merging;
the shell then crossfades panels instead of materializing them.

| Key | Default | Meaning |
|---|---|---|
| `spacing` | `hyprk-controlcenter:8,hyprk-dock:8,hyprk-overlay:8,hyprk-spotlight:8` | `ns:pt` smoothness k of the union (SwiftUI default 8; CC tiles 12 apart stay separate at rest; Spotlight's mode buttons, 12 from the field, fuse with it only while they emerge) |
| `reduce_motion` | 0 | 1 = no merging |

Custom shaders (`shader_path`) must now declare `shapeCount` and `shapeBox` (the old `glassBox`/`radius`
uniforms are gone): see the header of `shaders/liquidglass.frag`.

## Materials (recipes)

Apple's model as verified on the Mac against the binaries and the screen (reference/re/MAC-ANSWERS.md PC #67 B, C
and C2; DesignLibrary / QuartzCore pseudo-code in reference/re/27.2.1/decomp/) lives in `src/Material.cpp`
(`resolveMaterial(recipe, D, dark, tint)`) and `shaders/liquidglass.frag`. `D` = smallest extent of the glass
shape in pt. `tools/check_model.py` (ctest `apple_model`) checks both against Apple: the resolved inputs on every
material x light/dark x D x slider value, the face colour against the Mac's measured pixels (17 flat backdrops)
and the rim rows; run it after any change here.

| Recipe | Face (black, white, sat) light / dark | Fill | Inner refraction height / amount | Outer (h / amount / opacity) | Shadow | Used for (default) |
|---|---|---|---|---|---|---|
| `regular` | 0.4, 1.03, 1.2, max luma 0.94 (SDR) / 0.125, 1.125, 1.3, max luma lerp(0.6, 0.35) over D 64 → 104 | white 0.2 / none | min(0.25 D, 20) / max(-0.5 D, -60) | max(0.2 D, 16) / max(0.25 D, 16) / 0.6 | 0.04 + 0.56 q dark (light to 0.4), radius 4 + 20 q, y 8; ring 0.06 | |
| `menu` | as regular | as regular | as regular | as regular | 0.7 light / 0.8 dark, r 24, y 10 | `hyprk-overlay` |
| `notificationcenter` | as regular, max luma of D >= 104 (the column) | as regular | as regular | as regular | as regular | `hyprk-notifications`, `hyprk-notificationcenter` |
| `clear` | 0.125, 1.08, 1.06 | none | min(0.36 D, 20) / max(-0.65 D, -60) | none | none | |
| `dock` | 0.15, 0.9, 1.25 / 0.05, 0.92, 1.25 + black 2 %, max luma 0.75 | | as regular (the real Dock's end caps; the probe variant has 0.08 D / -0.18 D) | 0 / 0 / 0.2 | none | `hyprk-dock` |
| `controlcenter` | 0.125, 0.8, 1.2 both | none | min(0.225 D, 25) / max(-2 D, -80) | 0.0357 D / 0.0714 D / 0.1525 | none | `hyprk-controlcenter`, `hyprk-hud` |
| `spotlight` | 0.1, 1.0, 1.25 (SiriRecipe branch A, reference/re/NOTES.md; not in the verified model) | none | 0.4 D / -0.72 D | 0.4 D / 0.4 D / 1.0 | AppKit's active window shadow, black: 0.40 light / 0.70 dark, sigma 20 (radius 20 sqrt 2), y 18 (fitted to the Mac's bar, = shadowParameters); a shape inside another group's box casts none | `hyprk-spotlight` |

q = clamp((D - 64) / 96). Face (all in display-encoded values): max luma `k = clamp(1 - Y (1 - M))`, luma `k Y`,
chroma `x k (1 + 0.3 (1 - k))` (skipped at M = 1); then `black + (white - black) Y + sat (c - Y)` and the fill.
Edge bleed (Regular family, panels > 64 pt): a sharp backdrop sample moved outward by 0.35 D at the edge (0 from
depth 0.35 D on) through its colour matrix (dark 0.125 / 0.5 / 1, light 0.9 / 1 / 1.2), mixed over the whole
interior by `g^4 x opacity`, `g = 1 - Y(face)` dark / `Y(face)` light, opacity 0.8 q dark / 0.5 q light; read at the
mip of Apple's backdrop scale (perceptual estimator: 0.5 / 0.25 / 0.125). Blur fill (radius 8 in Apple's units):
lighten 0.9 light / darken 0.9 dark, normal 0.5.

Rim, two effects: (1) dark specular, the glass filter's KeyFillHighlight inputs: a 0.5 pt line just outside the
left and right edges, `c (1 + bias h (3 - 2 c))`, bias -0.25 (Control Center -0.3), lobes through
`v / ((1 / 0.4 - 2)(1 - v) + 1)`, spread 75 deg (dark, Dock, Clear, CC) / 106 deg (light Regular); (2) the key/fill
highlight layer top and bottom: a mix toward the layer's vibrantColorMatrix (as YCC per recipe) by spec 1 pt
(`1 - 0.75 depth`) + diffuse 8 pt linear at 0.65 x the spread, amounts 0.5 and 0.075; spread 80 deg up to D 96,
90 from D 191. Notification Center: the key band alone x 1.23 (the real NC card's rows, not decoded).
No chromatic aberration (`aberration` 0: Apple has it only on glassForeground, the pressed switch knob).

Liquid Glass slider (`tint_amount`, NSGlassTintAmount, 0.5 = the recipes as is), piecewise linear with the knee at
0.5, u = clamp(2a), t = clamp(2a - 1). Regular family: blur-fill normal `0.5 u | 0.5 + 0.5 t`, lighten/darken
`0.9 (0.75 + 0.25 u) | 0.9`, fill dark `none | grey 0.125 at 0.5 t`, light `white 0.2 u | 0.2 + 0.3 t`, dark max luma
`M0 u + lerp(0.6, 0.45, s)(1 - u)` below 0.5. Clear family (Clear, Dock, Control Center): blur x 2a below 0.5, a
blur fill of normal opacity 2a - 1 above, colours unchanged. Rim, refraction, saturation and shadow never change.
Spotlight is not changed (not in the model).

Blur and refraction per pixel, as glass_background_base: the inner refraction reads `p + n x amount x (1 - sqrt(t (2 - t)))`,
t = depth / height; the blur radius there is `BlurRadius x opacity(d + displacement)` (BlurOpacity0..2 over
BlurDistance0 (-0.5 D, Control Center -100), -1, 0), so the bevel reads deeper and blurrier backdrop; blur fill: two
taps at -+ L / 4 texels of radius 8's level; edge bleed at radius 0.175 D. Over stripes this gives the concentric lens
bands at rounded ends and the interior ripple of the real glass (reference/ours/glass/REFRACTION.md).
Control Center: on the Mac the tiles sample the panel's own blur under them (MAC-ANSWERS C2 3). `panel_blur` draws it: before
a layer's glass, the box of its shapes grown by 44.8 pt is redrawn as one trilinear read of its own full-resolution pyramid at
Apple's radius (1.79 pt for `hyprk-controlcenter`), ramping linearly in radius from 0 at that edge to full 72 pt inside; then the
tiles copy that and sample it, as on the Mac. Radius fitted to the Mac's gap row over 4 pt stripes (rms 0.47 levels over 400 px;
a Gaussian fits at 1.37), edge and ramp to where it leaves the tile column (rms 2.8, 11.2 without a ramp); it comes and goes with
the shapes' materialize and the layer's opacity (reference/ours/glass/REFRACTION.md "Panel blur"). `underlay_blur` (the older
stand-in: the same blur composed into the tiles' reads, no pass of its own) is off by default.

Light/dark: `appearance = "auto"` reads the backdrop luminance of each glass (1 pixel of a high mip,
read back asynchronously every 6 frames) and switches with Apple's V2 hysteresis: dark below 0.1, light
again above 0.3 (`adapt_low` / `adapt_high`).

Not Apple's: the shadow tint amount and the shadow's backdrop level (6), Spotlight, the Control Center panel blur
(fitted to the Mac's pixels, not decoded), the pyramid base at backdrop scale 0.25 / 0.125 (ours: the 13-tap levels of
the 0.5 base, Apple: a 4x4 / 8x8 box; the half-size base Apple uses when R > 2 is not modelled either).

## Appearance switch (Dark <-> Light)

macOS changes the whole screen with one cross-fade: AppKit 27.2.1 `NSGlobalPreferenceTransition` (`+transition` 0x18aeb1ce0
calls `SLSCopyBeginGlobalPreferenceTransitionCompletionBlock`) puts a borderless `NSGlobalPreferenceTransitionOverlay` window
on every screen whose layer holds `SLDisplayCreateImage` of that display (`-initOnScreen:` 0x18aeb17c4), posts the change
with `SLSPostCoordinatedDistributedNotification` (timeout 0.5 s, `-postChangeNotification:completionHandler:` 0x18aeb1d4c) so
the apps repaint under the snapshot, and then `-endPresentation` (0x18aeb1b20) sets the layer's opacity to 0 inside a
`CATransaction` of duration `NSGlobalPreferenceTransitionDuration` (default 0.5 s, `_NSGetCGFloatAppConfig`), actions
enabled, no timing function set: an implicit CoreAnimation fade, i.e. CA's default curve (0.25, 0.1, 0.25, 1) (the curve is
CA's documented default for implicit animations, not read from QuartzCore). One fade per display, not per window.

`src/AppearanceFade.cpp` does the same in the compositor: when the `appearance` option goes light <-> dark, each output's
last presented buffer (the swapchain buffer before the one being drawn) is copied once at that output's next frame and
drawn as the last element of every pass at `appearanceSnapshotAlpha(t)` (`src/Fade.cpp`): 1 for `appearance_hold`, then
1 -> 0 over `appearance_fade` on that curve. The whole output is damaged each frame only while it runs; the copy is freed at
the end; nothing at rest. Skipped with `reduce_motion`, for "auto", on rotated outputs and while the session is locked (a
running fade ends at once when a lock starts: the snapshot shows the unlocked desktop).
The hold ends at the shell's answer, as Apple's waits for the apps' answers (at most 0.5 s, `appearance_hold`): the shell
calls `hyprk_appearance_ready("dark" | "light", <ms>)` (config/hypr/hyprland.lua) once every shown shell window has committed
a frame in the new appearance, which sets `appearance_ack` to "dark:<ms>"; an answer for the appearance switched to that came
after the switch ends the hold (at once when it came before the output's snapshot); none, and the hold runs to 0.5 s. A hold is
needed with the option sent first (b80928a): the shell's menu bar and Dock restyle 100-120 ms after the option, and with hold 0
they step by .33-.37 inside the fade (MOTION-PLUGIN.md "Follow-ups"). With the answer (own session, 5 switches by
`qs ipc call theme setDark`): 33 frames in 0.552 s each (fixed 0.15 s hold: 0.65 s). Tried on screen: a lock during the fade ends it
in that frame, two outputs fade each on their own snapshot, a rotated output snaps.
The option must reach the compositor before the first client repaints, or that client snaps before the snapshot exists:
whoever starts the switch sends it on Hyprland's socket in the same turn (Quickshell:
`Hyprland.dispatch('function() hl.config({ plugin = { liquidglass = { appearance = "light" } } }) end')`), not through a
spawned `hyprctl`. `hyprctl liquidglass fade` prints the running fades and the last one's frames and length.
Measured (mcap, MBA, Finder + Settings + Dock, option then state file, both directions): the new look's share against the
decoded curve rms 0.001-0.002 (Finder, Settings; 6 runs at scale 2, 2 at 1.6) and 0.004 (Dock), monotonic, 2-98 % 384-405 ms,
the fade starting 162-180 ms after the switch command; `reduce_motion`: done in 94 ms, no fade.

## Precision (banding)

User report 2026-11-11: around the open Control Center the blurred backdrop showed steps "like an 8-bit transition". Three
causes, measured over the Tahoe wallpaper (MBA 2x; a row is "banded" when equal values run for tens of px):
1. The blur pyramid was 8 bit: every level is an average and lost up to half a level again, which drew flat facets (the
   triangles of a bilinear read between texels one level apart). The copies now have 16 bit unorm storage
   (`EXT_texture_norm16`, exact for every 8 bit value, so flat backdrops read as before; 10 bit unorm and half floats moved
   flat numbers by a level). 8 bit where the extension or the framebuffer refuses it.
2. The write is 8 bit: a wallpaper carries its own grain (65-70 one-level steps per 100 px), the blur removes it, and
   plain rounding draws the smooth result as contour lines. The shader now adds half a level of fixed interleaved-gradient
   noise before the write (`dither`). **Ours, not Apple's**: QuartzCore's glass shaders have no dither term; the Mac composes
   into a deeper buffer. It is gated on the backdrop itself: off where the backdrop is flat (its deepest level does not
   change) and off where it has detail (level 2 changes by more than a level in about 3 px), so flat and striped backdrops
   keep their values.
3. Not the plugin: the shell's dim layer under the Control Center is an 8 bit alpha ramp of 10 %; its contour rings and
   blocky steps are there with the plugin disabled (hand-off to the shell).

| longest run of equal values / one-level steps per 100 px (blue) | wallpaper alone | before | after |
|---|---|---|---|
| panel blur between the Sound tile and Edit Controls | 3 px / 72 | 140 px / 0 | 19 px / 56 |
| Sound tile interior | 7 px / 65 | 59 px / 2.7 | 19 px / 44 |
| menu body | | 347 px / 0.8 | 9 px / 80 |
| Dock body between icons | | 55 px / 2.5 | 4 px / 83 |
| Sound tile, scale 1.6 (dither off / on) | | 54 px / 5.4 | 42 px / 35 |

Flat backdrops, after = before: CC tile 186 / 109 / 32 (sd 0), rim over grey 231 179 133 127 123 120, over white 255 247 207
202, over black 123 84 50 45. Over 4 pt stripes the deeper pyramid (not the dither: same with `dither = 0`) moved three
numbers by one level: gap between tiles peak to peak 32 -> 31 (99..130, Mac 99..131), tile row 8 pt below its top 8 -> 7
(15 pt: 8), rim row 4 px across the corners 31 -> 32. GPU, Control Center opened and closed 6 times (`stats`): glass per
frame avg 0.87 -> 1.16 ms, p95 1.13 -> 1.62 ms; the backdrop copies take twice the memory (8 bytes per px of the glass
boxes); nothing at rest.

## Config keys (`plugin:liquidglass:<key>`; lengths in logical px)

| Key | Default | Meaning |
|---|---|---|
| `enabled` | 1 | 0 = plugin inactive, Hyprland's normal blur rules apply |
| `namespaces` | hyprk-dock, overlay, controlcenter, notifications, spotlight, switcher | comma list of layer namespaces, `*` = all |
| `materials` | `hyprk-dock:dock,hyprk-controlcenter:controlcenter,hyprk-overlay:menu` | `ns:recipe` map |
| `material` | `regular` | recipe for namespaces not in `materials` |
| `window_material` | `regular` | recipe for window glass |
| `radii` | "" | `ns:radius` overrides |
| `default_radius` | -1 | radius for all shapes; < 0 = infer from the blur region |
| `rounding_power` | 0 | 0 = Apple's continuous corner (QuartzCore `supercircle_sdf`, see Corners); >= 1 = an Lp superellipse of extent r (2 = circle) |
| `appearance` | `auto` | `auto` (hysteresis on backdrop luminance), `light`, `dark` |
| `adapt_low` / `adapt_high` | 0.1 / 0.3 | hysteresis band (SPEC 9.6, V2 light range) |
| `underlay_blur` | "" | `ns:radius` (Apple blur radius, pt) of a blur composed into that glass's reads without a pass (the panel blur's older stand-in; 2.05 fitted the CC tiles) |
| `panel_blur` | `hyprk-controlcenter:1.79` | `ns:radius`: draw that panel blur behind the layer's glass (see Materials) |
| `fill_layers` | "" | `ns:lighter` / `ns:darker`: every shape of that layer is a plus-lighter (+65/255) or plus-darker (-57/255) fill over what lies under it, drawn before the layer's content (Dock dots; Cmd-Tab's tile is a cut, see Cuts: Qt cannot blend with the compositor's glass). `ns:lighter:125` / `ns:darker:128` sets the amount in 1/255 (0 < a <= 255; the Dock's running dots, Q-dock-07). The fill takes the layer's opacity like the glass under it; give the namespace the `no_anim` layer rule, or Hyprland's layer fade runs on it and it trails the glass |
| `cut_fills` / `cut_fills_dark` | "" / "" | same syntax as `fill_layers`, used in light / dark `appearance`: the cuts of that layer's glass region (holes of 2 px or more across, see Cuts) are plus-lighter / plus-darker fills of the hole's rounded rect over the layer's glass, in the same commit as the glass (Cmd-Tab's selection tile) |
| `wallpaper_under` | `hyprk-dock:hyprk-mission` | `ns:other`: while a layer `other` is mapped on the output, the glass of `ns` samples the output's background layers (the wallpaper) and not what lies under it: the background layers' textures are drawn again inside what that glass reads, right before it. The Dock while Mission Control is open: the shell's Mission Control layer covers the windows with the wallpaper but sits above the Dock, whose glass refracted the real window under it (red window parked under the Dock, Dock box against the Dock over the bare wallpaper: rms 115.2 -> 0.5 levels). One clipped quad, only while `other` is mapped |
| `icon_masks` / `sdf_layers` | "" / "" | pictures handed over as layer surfaces: the Dock icons' clear-mode masks, an SDF picture as a glass shape (see Textures from the shell) |
| `popup_classes` / `popup_material` / `popup_radius` | `^hyprk-finder$` / `menu` / 12 | glass behind the xdg_popups of matching windows (see Client popups) |
| `refraction_scale` | 1 | multiplies the recipe's refraction amount (0 = off) |
| `aberration` | 0 | px R/B split at the edge (7 taps); 0 = off (Apple: none on background glass) |
| `highlight` | 1 | scales the key/fill highlight mask (1 = Apple) |
| `appearance_fade` / `appearance_hold` | 0.5 / 0.5 | s: the cross-fade after an appearance switch and the longest time the old picture stays whole before it (see Appearance switch); fade 0 = off |
| `appearance_ack` | "" | the shell's answer, "dark" or "light" with ":<stamp>": ends the hold (set by `hyprk_appearance_ready`) |
| `dither` | 1 | half a level of fixed per-pixel noise where the glass or the panel blur draws a slow gradient (see Precision); 0 = off |
| `tint_amount` | 0.5 | Liquid Glass slider (macOS NSGlassTintAmount) 0..1, see Materials. Live: `hyprctl eval 'hl.config({ plugin = { liquidglass = { tint_amount = 0.3 } } })'` then `hyprctl liquidglass damage` (the eval fires no reload event, the damage redraws every output now) |
| `shadow_scale` / `shadow_tint` | 1 / 0.35 | drop shadow opacity scale; 0 = black shadow, 1 = saturated backdrop colour |
| `ring_scale` | 1 | ring shadow opacity scale |
| `require_region` | 1 | only layers that set an ext-background-effect blur region get glass |
| `linear` | 0 | 1 = shader works in linear light. Keep 0: Apple's face and rim numbers reproduce the Mac's pixels in gamma space (HUD, Dock) |
| `stats` | 0 | GPU timing, read with `hyprctl liquidglass` |
| `full_damage` | 0 | 1 = redraw the whole output while glass is visible (debug; see below) |
| `shader_path` | "" | load this fragment shader instead of the built-in one |
| `window_classes` | "" | regex: windows whose class matches get glass behind them |
| `window_rim` | 0 | 1 = the 1 pt white rim just inside every window frame (title bar included), alpha .10, .08 dark inactive (MAC-ANSWERS Q-windows-03; Hyprland's border is the 0.5-1 pt black rim outside). Over the window (decoration layer OVER); dark foot 36 -> 58 at 2 px inside the border (Mac TextEdit bar 40 -> 61) |
| `window_shadow` | 0 | 1 = AppKit's window shadow on every window (`src/WindowShadow.cpp`; turn Hyprland's `decoration.shadow` off). Black, alpha = density x Gx x Gy, two Gaussian edges (sigma = blur radius) of the frame (title bar and border included) moved down by y; blur 20 / 8 pt, y 18 / 7, density .40 / .22 light, .70 / .45 dark (active = focused window; light / dark = `appearance`). Nothing inside the rounded frame; `no_shadow`, `decorate = false` and full screen get none. One analytic quad per damaged window, about the cost of Hyprland's own shadow (reference/ours/windows/SHADOW.md) |
| `window_radius` | -1 | window glass radius; < 0 = the window's rounding |

Keys of earlier iterations (`blur_lod`, `blur_lod_scale`, `saturation`, `tint_light`, `tint_dark`, `brightness_*`, `refraction`, `shadow_opacity`, `light_angle`, `rim`, `lift`, `inner_shadow`, `pointer_light`, `pointer_light_radius`, `pointer_light_namespaces`, ...)
are still accepted so old configs load, but do nothing. They will be removed once config/hypr/hyprland.lua no longer sets them.

Damage: when any part of a glass is damaged, the plugin adds the whole glass box plus what its shader
reads (refraction reach + aberration + 8 px) to the frame damage while the pass is built
(`CGlassElement::claimDamage`), so a partial redraw never shows seams and idle frames cost nothing.
A screenshot with `full_damage = 1` was pixel-identical to the default (test 2026-11-10).

## Test

`test/run.sh start` launches a nested Hyprland with a headless 2560x1664 `MBA` output, the test shell in
`test/qs/shell.qml` (wallpaper, dock, two cards with blur regions) and a foot window.
`test/run.sh shot NAME` writes `/mnt/code/hyprk/reference/ours/plugin-NAME.png`, `reload` swaps in a new build,
`stop` exits and kills only this instance. Set `LG_WALLPAPER=TahoeDark` before `start` for the dark wallpaper.

`hyprctl liquidglass trace NS FILE` appends, on every draw of layer NS, its 1-px region rects (marker holes), the opacity
marker and each decoded shape (box, radius, materialize, shadow flag) to FILE; `hyprctl liquidglass trace` stops. Join it with
an mcap capture by time (both CLOCK_MONOTONIC) to tell a plugin step from a client one (the HUD check in
reference/ours/motion/MOTION-PLUGIN.md).

`tools/contour.py SHOT --box X,Y,W,H --r R --scale S [--method peak|profile|cover]` reads a shape's top edge near its corners
against the corner curve at any output scale (box and radius from the trace; numbers at 1.6 and 2 in
reference/ours/glass/REFRACTION.md "Corner contour at a fractional scale").

## Performance

Each glass element copies the backdrop under its own boxes (the extents of what it reads, aligned to its deepest
level) at its turn in the pass and builds Apple's pyramid on it (a box level, then one 13-tap pass per level,
each a quarter of the one above); an element is only drawn when something under it was damaged. Hyprland's blur is
not used (until 2026-11-11 every element also ran it and copied its result: 2.5x the GPU time). A copy shared by all glass of a frame (taken once, at the first element) was tried in iteration 4:
it was ~13 % cheaper but showed stale pixels in the real shell's Control Center, because the framebuffer
under a later layer is not final at an earlier element's turn, so it was dropped.
`plugin:liquidglass:stats = 1` turns on GPU timestamp queries; `hyprctl liquidglass` prints the averages per element and
the sums per frame (`hyprctl liquidglass reset` clears them). `test/bench.sh` runs the real shell on a headless 3840x2160 @ 1.5
output (the user's 4K 150 %) with Dock, Control Center and a banner over a terminal that redraws every
frame. Result on this PC (AMD RDNA2, the RX 6600 class GPU), 6 s each, 2026-11-10:

| Configuration | Glass GPU time per element (avg / p95) | Whole frame GPU (avg / p95) |
|---|---|---|
| test/bench.sh 4K @ 1.5, whole output redrawn (`full_damage`), 2026-11-11 session 6 | 0.13 / 0.39 ms; per frame 0.52 / 0.63 | 11.9 / 16.6 ms (plugin off 12.4 / 18.5) |
| MBA 2x, 4 foot windows, per frame (glass / window shadow + rim), session 6 | CC open/close 0.73 / 0.40, drag 0.16 / 0.31, Dock sweep 0.14 / 0.17, Mission Control 0.20 / 0.33 ms; at rest nothing | - |
| Apple pyramid, no Hyprland blur (current code; MBA 2560x1664 @ 2, CC open/close + HUD, 2026-11-11) | 0.17-0.22 / 0.29-0.37 ms | 20.2 / 16.9-17.0 ms |
| Hyprland blur + sharp copy (before, same run and session) | 0.49-0.54 / 0.71-0.87 ms | 20.2-20.3 / 17.0-19.5 ms |
| per-element copy (run 04:58, 4K bench) | 0.64 / 1.08 ms | 14.4 / 22.7 ms |
| plugin disabled, same run | - | 15.8 / 22.3 ms |
| shared copy (iteration 4, dropped; earlier, quieter run) | 0.56 / 0.78 ms | 11.1 / 16.3 ms |
| old per-element copy of all glass boxes (iteration 3; earlier run) | 0.64 / 0.93 ms | 11.2 / 16.6 ms |

"Whole frame" spans the pass from `RENDER_LAST_MOMENT` to `RENDER_POST` and is dominated by
Hyprland's own work in the nested session (3 blur passes, two outputs), so its differences are within
noise: the glass costs well under 1 ms per element per redrawn frame at 4K.

## Title bars

Windows that draw no title bar themselves get a macOS one (`src/Titlebar.cpp`): a 32 pt bar in the client's
own colour (`titlebar_auto_color = 1`: one row of the client just below its rounded corners is read back
from the framebuffer every 15 draws, median of every 4th pixel; inactive windows get it slightly
desaturated; on a dark colour the title turns white and the inactive lights dark grey), or the fixed
`titlebar_color` / `titlebar_color_inactive`, or light glass with `titlebar_glass = 1`. The client's own
rounded top corners sit on the bar's colour, so no notch shows. Hyprland 0.57.2 rounds a whole surface with
one radius (no per-corner control), which is why the corners are filled rather than squared. Colour sampling
is skipped on rotated outputs. Then the traffic lights (liquid-glass-re SPEC 13, drawn with cairo): two-stop
vertical gradients (close #FF6D63 -> #F57269 a0.8, minimise #FBB316 -> #FFD134 a0.92, zoom #5ACF1F -> #79D34C
a0.73; dark bars their dark stops), a 0.75 pt rim over the fill (black 0.20 / 0.12 dark), a flat translucent
inactive fill with a 0.14 rim, flat pressed colours while the pointer stays on the pressed light, and
1.2 pt round-cap glyphs (× − +) that fade in on hover on a 0.3 s critically damped spring. The title is
centred in SF Pro Text 13 semibold. Close sends the client a close request, minimise moves the window to `special:minimized`
(plugin-motion plays the genie into the Dock), the green light toggles full screen and Option-click toggles zoom (maximised), as on
27.2.1 (Q-windows-10: Option turns the glyph into +); dragging the rest of the bar moves the window. A client's own yellow light
(GTK header bars, Xwayland) sends set_minimized, which Hyprland drops: plugin-motion (`client_minimize`) takes it the same way.

`titlebar = "auto"` (default) gives a bar to Wayland clients that bound xdg-decoration (Hyprland always
answers server-side, so they draw none: foot, Qt apps); GTK apps with client-side decorations get none.
`titlebar_classes` (regex) forces a bar, `titlebar_exclude` (regex, default the hyprk apps, which draw their
own) prevents one, `titlebar = "classes"` only uses the regex, `"off"` disables it.

| Key | Default |
|---|---|
| `titlebar` | `auto` |
| `titlebar_classes` / `titlebar_exclude` | "" / `^(org\.hyprk\..*|hyprk-.*)$` |
| `titlebar_height` / `titlebar_button` / `titlebar_gap` / `titlebar_inset` | 32 / 14 / 9 / 9 pt (SPEC: bar 32, buttons 14, gap 9; inset: MAC-ANSWERS Q-windows-07, TextEdit and Terminal discs at x 9, 32, 55 on 27.2.1 (was 15 from an older screenshot); toolbar windows use 19) |
| `titlebar_font` / `titlebar_font_size` | `SF Pro Text` / 13 |
| `titlebar_color` / `titlebar_color_inactive` | `0xF3F1EFFF` / `0xF6F5F4FF` |
| `titlebar_text` / `titlebar_text_inactive` | `0x000000B3` / `0x00000040` (TextEdit #4C4C4C / #BEBEBE on white, Q-windows-11) |
| `titlebar_auto_color` | 1 |
| `titlebar_glass` | 0 |

Ghostty: set `window-decoration = server`; if a build does not bind xdg-decoration, add its class
(`com.mitchellh.ghostty`) to `titlebar_classes`. Clients that bind xdg-decoration but explicitly request
client-side mode keep their own header. A `decorate = false` window rule removes the bar. The bar is
re-evaluated when the config or the window class changes, and every 120 frames while a window has none
(late xdg-decoration binds).

Which clients asked for server-side decorations is read from Hyprland's private xdg-decoration map
(`#define private public` around one header, read only). The bar's fill also covers the window's rounded
top corners, so the two read as one shape.

`hyprctl liquidglass bars` prints one JSON array with an object per window that has this bar: `address`, `height`,
`button`, `gap`, `inset`, `titleX` (pt), `font`, `fontSize`, `weight`, `title`, `active` and `look.active` /
`look.inactive` = `{fill, dark, text}` (colours as `#AARRGGBB`, `dark` = the discs and text of a dark bar). Mission
Control draws the bar from it in the thumbnails (a window capture holds the client only, the bar is a decoration).

**Full screen enter.** Hyprland draws no decoration for a full-screen window, so the bar went in one frame. AppKit's
`_NSFullScreenTransitionOverlayWindow` fades the after-contents in on (0, 1, 1, 1) over half the 0.5 s transition, over the
before-contents (window and bar), both on the moving frame (MOTION-PLUGIN.md "Full screen REA"). `CTitlebar::drawFullscreenFade`
(RENDER_POST_WINDOWS) draws the bar's last look (fill, lights, glyphs, title) over the window's top rows, mapped from the last
drawn bar + window box to the window's current box, at 1 - (0, 1, 1, 1)(t / 0.25 s); Reduce Motion: linear over 0.5 s, not
moved. Only for a bar drawn in the last 100 ms (not a window opened full screen). Cost: one rect and up to 7 small textured
quads for about 15 frames; at rest one mode lookup per bar and frame. Red-light ink per frame, foot at 2x, 20 of 20 enters:
1.03 .59 .48 .40 .33 .29 .24 .20 .15 .10 .05 .01 0 (the curve: 1 .60 .46 .36 .29 .23 .18 .14 .11 .08 .06 .04 .02; rms .038, was
1 then 0: .265; the ink grows with the scaled lights mid-way).

## Windows

`window_classes = "^(foot|hyprk-finder)$"` puts glass (no drop shadow, the window keeps its own) behind matching
windows, radius = `decoration.rounding` unless `window_radius` is set. The window must be translucent. Give it a
`no_blur` rule, otherwise Hyprland also blurs behind it on top of the glass. A window that sets an
ext-background-effect region (e.g. a glass sidebar: Quickshell `BackgroundEffect.blurRegion`) gets glass only in
that region, with the region's corner radius; Hyprland would blur that region too, so `no_blur` matters there.

Fallbacks: see `FALLBACKS.md`.

## Client popups

A client's context menu is an xdg_popup (Finder's PopupMenu.qml, as the Mac's NSPopupMenuWindow). For windows whose class
matches `popup_classes`, `IHyprRenderer::renderWindow` is hooked: after Hyprland adds the window's pass elements, a glass element
(`popup_material`, radius `popup_radius`, the popup's xdg window geometry) goes right before each popup's root surface, and
Hyprland's own popup blur is turned off for it. Q-menubar-13: pull-down and context menu are the same window type and glass, so
the default is the shell dropdown's `menu` recipe and shadow. A Qt popup destroys its surface on close, which leaves Hyprland's
popup fadeout empty, so the plugin keeps the popup's last buffer and fades it with its glass over the shell menus' 185 ms
ease-out (materialize 1 -> 0). The client draws no fill when `plugin:liquidglass:enabled` is 1.

## Textures from the shell (icon masks, SDF shapes)

Two things the glass needs as pictures, not as rounded rects. The hand-off is a layer surface of its own per picture: its
buffer is the texture, its box says where it lies, and while the plugin is enabled Hyprland never draws it (with the key
unset, or the plugin off, it is an ordinary layer and shows its picture, so the shell maps it only when the key is set).
Both keys are empty by default: nothing in the shell maps such a layer yet. Give the layer an empty input region and
`exclusionMode: Ignore`; an external (YUV) buffer is not taken.

**`icon_masks = "hyprk-dock:hyprk-dock-masks"`** (glass namespace : mask namespace). IconRendering's clear mode (icon style
Clear, and Tinted in light) draws no picture: the icon is three masks that the glass under it takes (0x1cfd71dfc, the live
layer's CAFilter passes 0x1cfd69ffc, reference/ASSETS.md). The mask layer's buffer, premultiplied, anywhere over the glass:
R = lighten, G = darken (the amount taken off: totalDarkeningStrength x darkening, `icr.render_masks()` channel 1), B =
highlights; (0, 0, 0, 0) = nothing. The glass shader applies, on its own finished colour and inside its coverage only,
`mix(c, clamp(VCM(c; 0.9, 2.5, 2.0), 0, 1.2), R)`, then `max(c - G, 0)`, then `mix(c, clamp(VCM(c; 0.2, 1.35, 1.4), 0, 1.2), B)`
(ICRRenderingParameters.default ClearMode, pass order lighten first), clipped to 1 at the write. One more texture read in the
Dock's own pass, no copy, no pass of its own. On screen (MBA 2x, dark Dock over white, four test squares of masks) against
the same formula on the Dock without masks: rms 1.0 level over 18,166 px, nothing changed outside the masks. GPU, Dock
redrawn every frame: 0.050 -> 0.053 ms per frame.
Not Apple's, or not known: values above 1 are clipped (what CoreAnimation does after `inputClamp` was not read); the masks
act where the Dock's glass is, so a magnified icon's part above the Dock gets none; and what the Dock puts under each icon
is not built: every `DOCKTileLayer` has a glass background of its own (`_requiresGlassBackground` 0x10007f9d4,
`setGlassBackgroundStyle:` 0x100080264, a `DockGlassMaterialLayerController` per tile, `initWithVariant:adaptive:`
0x100176f18; variant -> recipe not read). The icon port's still test says what to expect until then: these passes over the
Dock's flat colour fit the Mac's Dock worse than the fitted rule (ClearLight rms 7.0 against 5.8, TintedLight 18.8-23.0
against 11.4, ASSETS.md), so the key is for trying the masks on live glass, not yet a replacement.

**`sdf_layers = "ns"`** or `"ns:one:padding:size"`. The layer's buffer is an SDF picture, R = distance with 0.5 at the edge
(below inside), G / B = the outward normal as n / 2 + 0.5, opaque; the glass of that namespace (recipe from `materials`) takes
its shape from it: the shader's distance and normal are read from the picture instead of computed, everything after is the
same code (refraction along the normal, rim, shadow). `one` is the distance of value 1 from the edge, `padding` the margin
around the shape and `size` the picture's side, in the picture's own px; a bare name is Dock.app's `s-trashempty-sdf.png`
(128, 152, 384: the Dock Trash's glass, `preferredGlassBackgroundStyle: 2`). The shape's own part of the picture is the glass
box (it picks the recipe's size values). On screen (a 40 pt rounded square as a 384 px picture, Control Center recipe over
white): the silhouette is the picture's (5,900 px inside, 100 of them unchanged, 208 changed outside: the rim's edge pixels),
body 204 as the recipe's. GPU: 0.027 ms per frame for that shape (its own backdrop copy).
Assumed, not checked against the asset (it is not on this machine): the sign of the distance and the normal's encoding.
Not read: which recipe glass background style 2 is.

## Cuts (a fill in the glass's own commit)

A fill on a surface of its own (`fill_layers`) commits apart from the glass it sits on, so the first frame of a panel could
show the glass without the content of the other surface (Cmd-Tab: 2 of 5 opens, MOTION-MEASURED session 16). A cut keeps
both on one surface: the shell subtracts the fill's rounded rect from the glass region (`Glass.cut`, Quickshell
`Intersection.Subtract`), and for a namespace in `cut_fills` / `cut_fills_dark` the plugin reads every hole of 2 px or more
across in the region's bands (`Shape.cpp cutShapes`; the marker holes are 1 px wide) as a shape of its own, box and corner
radius from the hole's staircase, and draws it as a fill after the glass, before the surface. The glass itself is drawn from
its shape's box and does not see the hole. A glass with a cut sends no sub-point edge markers (`Glass.subPointEdges`):
those rows cross the cut. Cost: the same fill quad the fill layer drew, one layer element less.

## Dock label pointer

A plain rect with a 1x1 hole in its top row at left + 1, hanging 1 pt below the label pill, becomes Apple's cartouche pointer
(Dock `ECCartoucheGlassLayerController`, MAC-ANSWERS "REA 27.2.1" 3): a square of side 16 turned 45 deg, corner radius 2.5, centred
4 pt above the pill's bottom edge, unioned with the pill at smoothness 25 (a group with a pointer uses 25 instead of the layer's
`spacing`). The hole is needed because a region is a union: a shape touching the pill would merge with it.
The pointer has no materialize hole of its own: it takes the materialize of the largest other shape of its group (the pill),
so pill and pointer fade as one shape; the layer's opacity covers both (one draw). Alone in a group it stays at 1.
The label is a layer of its own (`hyprk-dock-label`, material `regular`, config/hypr/hyprland.lua) and needs no fill there:
Regular at that size over the wallpaper is the Mac's label (32 / 134 / 185 dark, 133 / 195 / 253 light against 31 / 131 / 180
and 131 / 192 / 249). The shell no longer draws one (`Theme.dock.labelFill` was removed in 2210b40). The plugin still has the
old fill for a pointer group on the Dock's own recipe (a label drawn on the `hyprk-dock` namespace, as before the move):
k + c (1 - a) with dark k 23.5 / 255 a 0.083, light 107 / 255 a 0.382 outside its plain shapes (GlassElement.cpp,
`pointerFill`); over black that pointer read 14 under a 35 pill, with the fill 36 (Mac: one shape, 31).
Shape check (judge #4 gap 14, "base 14.5 pt vs 16"; 2026-11-11): the shader's union and a Python reference of the decoded
one (16 pt square turned 45 deg, r 2.5, centre 4 above the pill's bottom, QuartzCore's normal-aware smooth min at 25) are the
same curve: width 16.2 / 12.1 / 8.2 / 4.1 pt at 0.75 / 1.75 / 3.25 / 5.25 pt below the pill, tip 6.3 (14.1 at 1.2 pt: the
judge's "base" is the second pixel row under the pill at 2x). On screen the edge sits on that curve: per pixel row under the
pill, where the pixels cross half of the edge's own rim peak against the curve's edge, rms px: dark 0.15 (2x) / 0.22 (1.6),
light 0.05 / 0.06. A reading at 50 % of the pill's contrast over black is wider than the shape, because the pointer's rim is
brighter than the pill's body (dark: rim 85-99, body 39), so a 20 % covered pixel already passes: dark 17.8 / 12.9 / 8.6 /
4.6 (2x) and 18.1 / 13.5 / 8.7 / 4.8 (1.6), light 16.9 / 12.4 / 8.2 / 4.2 and 16.9 / 12.4 / 8.2 / 4.3. Nothing changed in
the shape; no Mac capture of the label exists to read the same way (Q-dock-08 "about 16 wide x 6.5 tall").
