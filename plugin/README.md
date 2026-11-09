# liquidglass: macOS 27 Liquid Glass for Hyprland 0.57.2

Own plugin (C++ + GLSL ES 3.00). It draws the Liquid Glass material behind chosen layer-shell surfaces
(the hyprk shell: menu bar menus, dock, Control Center, notifications, Spotlight, Cmd+Tab).
Math follows the macOS 27.2 QuartzCore `glass_background_*` shader recovered in
`/mnt/code/liquid-glass-re/SPEC.md`: Apple's quarter-circle bevel for refraction, 7-tap chromatic aberration,
erfc-shaped drop shadow, two-lobe rim highlight applied as a colour bias, mip-LOD variable blur.
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
    namespaces = "hyprk-menubar,hyprk-dock,hyprk-overlay,hyprk-notifications,hyprk-spotlight,hyprk-switcher",
    radii      = "hyprk-menubar:0",
} } })
```

Live change: `hyprctl eval 'hl.config({ plugin = { liquidglass = { refraction = 24 } } })'` (read every frame).
Check a value: `hyprctl getoption plugin:liquidglass:refraction`.

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

## Materials (recipes)

Apple's numbers from `/mnt/code/liquid-glass-re/SPEC.md` section 9 (glass version v2) live in
`src/Material.cpp`. Most are size-relative: `D` = smallest extent of the glass shape in pt.

| Recipe | Face YCC light (black, white, sat) | Fill light | Refraction height / amount | Extra blur | Shadow | Used for (default) |
|---|---|---|---|---|---|---|
| `regular` | 0.4, 1.03, 1.2 | white 20% | 0.25 D (max 20) / -0.5 D (min -60) | D 64→160 : 0→4 | D 64→160 : 0.25→0.75, r 24, y 8 | notifications, spotlight, switcher |
| `menu` | as regular | white 20% | as regular | as regular | 0.6, r 24, y 10 (Mac glass window shadow) | `hyprk-overlay`, `hyprk-menubar` |
| `clear` | 0.125, 1.08, 1.06 | none | 0.25 D / -0.8 D | D 48→120 : 3→8 | as regular | |
| `dock` | 0.15, 0.9, 1.25 | none | 0.08 D / -0.18 D | 1.5 | as regular | `hyprk-dock` |
| `controlcenter` | 0.125, 0.8, 1.2 | none | 0.225 D (max 25) / -2.0 D (min -80) | 4 | as regular | `hyprk-controlcenter` |

Dark sides: regular (0.125, 1.125, 1.3), dock (0.05, 0.92, 1.25), others as light. Regular also has
Apple's V2 ring shadow (offset 8, stroke 4, radius 5, opacity 0.06). Face effect: luminance is mapped
into [black, white] and chroma scaled by saturation, then the fill is mixed in.
Light/dark: `appearance = "auto"` reads the backdrop luminance of each glass (1 pixel of a high mip,
read back asynchronously) and switches with Apple's V2 hysteresis: dark below 0.1, light again above
0.3 (`adapt_low` / `adapt_high`).

Not from the RE (by eye): `lift` (extra white on light faces), the rim floor, the inner shadow, the
dark-side rim bias (+0.3 instead of Apple's undecoded dark specular), the shadow tint amount, and
how Apple's blur radius maps to extra mip levels (`blur_lod_scale`).

## Config keys (`plugin:liquidglass:<key>`; lengths in logical px)

| Key | Default | Meaning |
|---|---|---|
| `enabled` | 1 | 0 = plugin inactive, Hyprland's normal blur rules apply |
| `namespaces` | hyprk-menubar, dock, overlay, controlcenter, notifications, spotlight, switcher | comma list of layer namespaces, `*` = all |
| `materials` | `hyprk-dock:dock,hyprk-controlcenter:controlcenter,hyprk-overlay:menu,hyprk-menubar:menu` | `ns:recipe` map |
| `material` | `regular` | recipe for namespaces not in `materials` |
| `window_material` | `regular` | recipe for window glass |
| `radii` | "" | `ns:radius` overrides |
| `default_radius` | -1 | radius for all shapes; < 0 = infer from the blur region |
| `rounding_power` | 2.6 | superellipse corner (2 = circle) |
| `appearance` | `auto` | `auto` (hysteresis on backdrop luminance), `light`, `dark` |
| `adapt_low` / `adapt_high` | 0.1 / 0.3 | hysteresis band (SPEC 9.6, V2 light range) |
| `lift` | 0.1 | extra white over light faces (0 = Apple's recipe as decoded) |
| `blur_lod` / `blur_lod_scale` | 0 / 0.6 | extra mip blur = `blur_lod + scale * log2(1 + recipe blur radius)` |
| `refraction_scale` | 1 | multiplies the recipe's refraction amount (0 = off) |
| `aberration` | 1.5 | px R/B split at the edge (7 taps); 0 = off |
| `light_angle` | -50 | degrees the light comes from (0 = right, -90 = top) |
| `highlight` | 1 | scales the recipe's rim colour bias (`rgb *= 1 + k(3-2rgb)`) |
| `highlight_width` / `highlight_spread` / `highlight_curve` | 1.5 / 0.09 / 0.5 | rim band px, lobe threshold (cos 85°), Apple's tone curve amount |
| `rim` | 0.5 | highlight floor all around the edge |
| `inner_shadow` / `inner_shadow_size` | 0.06 / 8 | darkening along the inner rim |
| `shadow_scale` / `shadow_tint` | 1 / 0.35 | drop shadow opacity scale; 0 = black shadow, 1 = saturated backdrop colour |
| `ring_scale` | 1 | ring shadow opacity scale |
| `require_region` | 1 | only layers that set an ext-background-effect blur region get glass |
| `full_damage` | 0 | 1 = redraw the whole output while glass is visible (debug; see below) |
| `shader_path` | "" | load this fragment shader instead of the built-in one |
| `window_classes` | "" | regex: windows whose class matches get glass behind them |
| `window_radius` | -1 | window glass radius; < 0 = the window's rounding |

Keys of the first iteration (`saturation`, `tint_light`, `tint_dark`, `brightness_*`, `refraction`, `shadow_opacity`, ...)
are still accepted so old configs load, but do nothing.

Damage: when any part of a glass is damaged, the plugin adds the whole glass box plus what its shader
reads (refraction reach + aberration + 8 px) to the frame damage while the pass is built
(`CGlassElement::claimDamage`), so a partial redraw never shows seams and idle frames cost nothing.
A screenshot with `full_damage = 1` was pixel-identical to the default (test 2026-11-10).

## Test

`test/run.sh start` launches a nested Hyprland with a headless 2560x1664 `MBA` output, the test shell in
`test/qs/shell.qml` (wallpaper, dock, two cards with blur regions) and a foot window.
`test/run.sh shot NAME` writes `/mnt/code/hyprk/reference/ours/plugin-NAME.png`, `reload` swaps in a new build,
`stop` exits and kills only this instance. Set `LG_WALLPAPER=TahoeDark` before `start` for the dark wallpaper.

## Windows

`window_classes = "^(foot|hyprk-finder)$"` puts glass (no drop shadow, the window keeps its own) behind matching
windows, radius = `decoration.rounding` unless `window_radius` is set. The window must be translucent. Give it a
`no_blur` rule, otherwise Hyprland also blurs behind it on top of the glass.

Fallbacks: see `FALLBACKS.md`.
