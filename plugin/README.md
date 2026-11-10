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
   glass rounded rect. The corner radius is read back from the region's staircase, unless `radii` or
   `default_radius` sets it. Without a region the layer is left to Hyprland (`require_region = 1`, default),
   or the whole layer box becomes glass (`require_region = 0`).
3. The surface itself should be transparent where the glass is (draw only content, or a light tint on top).
   Hyprland's own blur for that layer is switched off while the glass draws, so they never stack.

The backdrop is Hyprland's own blur (`decoration.blur.*`, so size/passes/vibrancy there set the base frost),
mipmapped by the plugin for the extra per-pixel blur. Recommended base: `blur = { size = 10, passes = 3 }`.

## Motion (materialize, merging, interactive light)

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

Interactive light (`pointer_light_namespaces`): the rim brightens and widens around the pointer
(Gaussian, `pointer_light_radius`), the face glows faintly, and while a button is held the light is
brighter and 1.5x wider, fading over 0.3 s after release. Light reaches nearby glass too. The plugin damages
only glass within reach of the old and new pointer position.

`reduce_motion = 1` (the shell sets it from Settings > Accessibility > Reduce motion) turns off merging and
the pointer light; the shell then crossfades panels instead of materializing them.

| Key | Default | Meaning |
|---|---|---|
| `spacing` | `hyprk-controlcenter:8,hyprk-dock:8,hyprk-overlay:8,hyprk-spotlight:8` | `ns:pt` smoothness k of the union (SwiftUI default 8; CC tiles 12 apart stay separate at rest; Spotlight's mode buttons, 12 from the field, fuse with it only while they emerge) |
| `pointer_light_namespaces` | `hyprk-controlcenter,hyprk-dock` | glass that lights up around the pointer |
| `pointer_light` / `pointer_light_radius` | 1 / 60 | strength (0 = off), Gaussian radius in px |
| `reduce_motion` | 0 | 1 = no merging, no pointer light |

Custom shaders (`shader_path`) must now declare `shapeCount` and `shapeBox` (the old `glassBox`/`radius`
uniforms are gone): see the header of `shaders/liquidglass.frag`.

## Materials (recipes)

Apple's numbers from `/mnt/code/liquid-glass-re/SPEC.md` section 9 (glass version v2) live in
`src/Material.cpp`. Most are size-relative: `D` = smallest extent of the glass shape in pt.

| Recipe | Face YCC light (black, white, sat) | Fill / lift light | Inner refraction height / amount | Outer layer (h / amount / opacity) | Blur | Shadow | Used for (default) |
|---|---|---|---|---|---|---|---|
| `regular` | 0.4, 1.03, 1.2 (27.2.1 probe; dark 0.125, 1.125, 1.3, max luma 0.6 / 0.4 / 0.35 at D 64 / 96 / 128) | white 20% | 0.25 D (max 20) / -0.5 D (min -60) | 0.2 D / 0.25 D / 0.6 | D 48→160 : 2→4 (Apple 5), variable: opacities 0.8 / 0.4 / 0.5, the first two from 0 at D 64 to full at D 160 (probe) | D 64→160 : 0.25→0.75, r 24, y 8 | notifications, switcher |
| `menu` | as regular | as regular | as regular | as regular | as regular | 0.6, r 24, y 10 | `hyprk-overlay` |
| `spotlight` | 0.1, 1.0, 1.25 (SiriRecipe branch A, reference/re/NOTES.md; light and dark) | none | 0.4 D / -0.72 D (no caps) | 0.4 D / 0.4 D / 1.0 | 6 (Apple 8 x opacity 0.75), variable: full from 60 pt in to 1 pt from the edge; blur fill darken 0.75, normal 0.5 | none, no edge bleed, no ring | `hyprk-spotlight` |
| `clear` | 0.125, 1.08, 1.06 (27.2.1 probe) | none | 0.36 D (max 20) / -0.65 D (min -60) | none | 0.75 | none, no edge bleed | |
| `dock` | 0.15, 0.9, 1.25 (dark 0.05, 0.92, 1.25 + black 2 %; 27.2.1 probe, light matches the real Dock) | none | 0.08 D / -0.18 D | 0 / 0 / 0.2 | 1.5 | none, no edge bleed | `hyprk-dock` |
| `controlcenter` | 0.125, 0.8, 1.2, light and dark (SPEC 9.5 = 27.2.1 probe; over (69, 83, 206) it gives the Mac HUD's (68, 85, 232)) | none | 0.225 D (max 25) / -2.0 D (min -80) | 0.0357 D / 0.0714 D / 0.1525 | none (Apple 4: too much on top of Hyprland's blur), variable from 100 pt in, opacities 1 / 0.1 / 0.5 | none, no edge bleed | `hyprk-controlcenter`, `hyprk-hud` |

The face colour is Apple's YCC composite (SPEC 9.7): `Y' = black + (white - black) Y`, chroma x saturation,
then the fill, all in gamma space: that reproduces the Mac's pixels (HUD and Dock over flat colours).
All recipes use the 27.2.1 probe numbers (Regular since the menu pass, see Material.cpp).

Rim (every recipe, `reference/re/27.2.1/live/glass-params-*.json` + the HUD screenshots): the glass filter's
key highlight with a negative colour bias (-0.25, Control Center -0.3) keyed sideways, 0.5 pt at the edge
(spread 96 / 75 / 120 deg for regular light / dark and CC / Dock), and a key/fill highlight layer top and
bottom: a mix toward the layer's vibrantColorMatrix (as YCC per recipe) by a mask of a 1 pt key band and an
8 pt diffuse band, clamped to 1.5. The mask shape was fitted to the HUD over flat blue (light and dark agree).

Also per recipe (SPEC 9.2/9.3): edge bleed (opacity D 64→160 : 0→0.5, height/amount/blur 0.35 D, colour
regular (0.9, 1, 1.2), clear family (0.75, 1, 1.2)), blur fill (regular light: lighten 0.9, normal 0.5;
dark: darken 0.9, normal 0.5), drop shadow coloured by the backdrop saturated x1.2,
regular ring shadow (offset 8, stroke 4, radius 5, opacity 0.06). Dark sides: regular (0.125, 1.125, 1.3),
dock (0.05, 0.92, 1.25, max luma 0.75), others as light. Max luma bends the backdrop luma before the face:
Y - (1 - m) Y^2.

Variable blur needs the unblurred backdrop: the plugin copies the framebuffer being rendered (one blit +
mip chain per glass element) and mixes it with Hyprland's blur by Apple's per-pixel blur amount.

Light/dark: `appearance = "auto"` reads the backdrop luminance of each glass (1 pixel of a high mip,
read back asynchronously every 6 frames) and switches with Apple's V2 hysteresis: dark below 0.1, light
again above 0.3 (`adapt_low` / `adapt_high`).

Not from the RE (by eye): Regular's light face, fill, blur fill and blur alphas (JUDGE-r2), the shadow tint
amount, and how Apple's blur radius maps to extra mip levels (`blur_lod_scale`).

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
| `rounding_power` | 2.6 | superellipse corner (2 = circle) |
| `appearance` | `auto` | `auto` (hysteresis on backdrop luminance), `light`, `dark` |
| `adapt_low` / `adapt_high` | 0.1 / 0.3 | hysteresis band (SPEC 9.6, V2 light range) |
| `blur_lod` / `blur_lod_scale` | 0 / 0.6 | extra mip blur = `blur_lod + scale * log2(1 + recipe blur radius)` |
| `refraction_scale` | 1 | multiplies the recipe's refraction amount (0 = off) |
| `aberration` | 1.5 | px R/B split at the edge (7 taps); 0 = off |
| `highlight` | 1 | scales the key/fill highlight mask (1 = Apple) |
| `shadow_scale` / `shadow_tint` | 1 / 0.35 | drop shadow opacity scale; 0 = black shadow, 1 = saturated backdrop colour |
| `ring_scale` | 1 | ring shadow opacity scale |
| `require_region` | 1 | only layers that set an ext-background-effect blur region get glass |
| `linear` | 0 | 1 = shader works in linear light. Keep 0: Apple's face and rim numbers reproduce the Mac's pixels in gamma space (HUD, Dock) |
| `stats` | 0 | GPU timing, read with `hyprctl liquidglass` |
| `full_damage` | 0 | 1 = redraw the whole output while glass is visible (debug; see below) |
| `shader_path` | "" | load this fragment shader instead of the built-in one |
| `window_classes` | "" | regex: windows whose class matches get glass behind them |
| `window_radius` | -1 | window glass radius; < 0 = the window's rounding |

Keys of earlier iterations (`saturation`, `tint_light`, `tint_dark`, `brightness_*`, `refraction`, `shadow_opacity`, `light_angle`, `rim`, `lift`, `inner_shadow`, ...)
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

## Performance

Each glass element copies the unblurred backdrop under its own boxes (plus the mip footprint) at its
turn in the pass and rebuilds that copy's mip chain; an element is only drawn when something under it was
damaged. A copy shared by all glass of a frame (taken once, at the first element) was tried in iteration 4:
it was ~13 % cheaper but showed stale pixels in the real shell's Control Center, because the framebuffer
under a later layer is not final at an earlier element's turn, so it was dropped.
`plugin:liquidglass:stats = 1` turns on GPU timestamp queries; `hyprctl liquidglass` prints the averages
(`hyprctl liquidglass reset` clears them). `test/bench.sh` runs the real shell on a headless 3840x2160 @ 1.5
output (the user's 4K 150 %) with Dock, Control Center and a banner over a terminal that redraws every
frame. Result on this PC (AMD RDNA2, the RX 6600 class GPU), 6 s each, 2026-11-10:

| Configuration | Glass GPU time per element (avg / p95) | Whole frame GPU (avg / p95) |
|---|---|---|
| per-element copy (current code, run 04:58) | 0.64 / 1.08 ms | 14.4 / 22.7 ms |
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
centred in SF Pro Text 13 semibold. Close sends the client a close request, minimise moves the window to `special:minimized`, zoom
toggles maximised, dragging the rest of the bar moves the window.

`titlebar = "auto"` (default) gives a bar to Wayland clients that bound xdg-decoration (Hyprland always
answers server-side, so they draw none: foot, Qt apps); GTK apps with client-side decorations get none.
`titlebar_classes` (regex) forces a bar, `titlebar_exclude` (regex, default the hyprk apps, which draw their
own) prevents one, `titlebar = "classes"` only uses the regex, `"off"` disables it.

| Key | Default |
|---|---|
| `titlebar` | `auto` |
| `titlebar_classes` / `titlebar_exclude` | "" / `^(org\.hyprk\..*|hyprk-.*)$` |
| `titlebar_height` / `titlebar_button` / `titlebar_gap` / `titlebar_inset` | 32 / 14 / 9 / 15 pt (SPEC: bar 32, buttons 14, gap 9; inset measured on the reference screenshot, toolbar windows use 19) |
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

## Windows

`window_classes = "^(foot|hyprk-finder)$"` puts glass (no drop shadow, the window keeps its own) behind matching
windows, radius = `decoration.rounding` unless `window_radius` is set. The window must be translucent. Give it a
`no_blur` rule, otherwise Hyprland also blurs behind it on top of the glass. A window that sets an
ext-background-effect region (e.g. a glass sidebar: Quickshell `BackgroundEffect.blurRegion`) gets glass only in
that region, with the region's corner radius; Hyprland would blur that region too, so `no_blur` matters there.

Fallbacks: see `FALLBACKS.md`.
