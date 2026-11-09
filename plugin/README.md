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
   `default_radius` sets it. Without a region the whole layer box is the glass.
3. The surface itself should be transparent where the glass is (draw only content, or a light tint on top).
   Hyprland's own blur for that layer is switched off while the glass draws, so they never stack.

The backdrop is Hyprland's own blur (`decoration.blur.*`, so size/passes/vibrancy there set the base frost),
mipmapped by the plugin for the extra per-pixel blur. Recommended base: `blur = { size = 10, passes = 3 }`.

## Config keys (`plugin:liquidglass:<key>`; lengths in logical px)

| Key | Default | Meaning |
|---|---|---|
| `enabled` | 1 | 0 = plugin inactive, Hyprland's normal blur rules apply |
| `namespaces` | hyprk shell list above | comma list of layer namespaces, `*` = all |
| `radii` | `hyprk-menubar:0` | `ns:radius` overrides |
| `default_radius` | -1 | radius for all shapes; < 0 = infer from the blur region |
| `rounding_power` | 2.6 | superellipse corner (2 = circle, ~2.6 close to Apple's continuous corner) |
| `blur_lod` | 0.5 | extra mip blur in the centre (0 = Hyprland's blur only, +1 = about 2x radius) |
| `edge_blur_lod` | 0.0 | extra mip blur at the rim (variable blur) |
| `blur_edge_distance` | 14 | px over which edge blur turns into centre blur |
| `refraction` | 18 | px displacement at the edge (+ pulls in what is outside the edge, - pushes) |
| `refraction_height` | 18 | px depth of the bevel |
| `aberration` | 1.5 | px R/B split at the edge (7 taps); 0 = off |
| `saturation` | 1.4 | backdrop saturation boost |
| `brightness_light` / `brightness_dark` | 1.04 / 0.9 | backdrop gain per appearance |
| `tint_light` / `tint_dark` | `0xFFFFFF33` / `0x1C1C1E38` | 0xRRGGBBAA, AA = tint amount |
| `appearance` | `auto` | `auto` adapts to backdrop luminance, or `light` / `dark` |
| `adapt_threshold` / `adapt_softness` | 0.22 / 0.08 | luminance where auto turns dark, width of the blend band |
| `light_angle` | -50 | degrees the light comes from (0 = right, -90 = top) |
| `highlight` | 0.6 | rim highlight strength (Apple colour bias `rgb *= 1 + k(3-2rgb)`) |
| `highlight_width` | 2.0 | px width of the rim band |
| `highlight_spread` | 0.0 | 0..1, larger = narrower lobes |
| `rim` | 0.3 | highlight floor all around the edge |
| `inner_shadow` / `inner_shadow_size` | 0.10 / 8 | darkening along the inner rim |
| `shadow_opacity` / `shadow_radius` / `shadow_offset_y` | 0.22 / 14 / 4 | Gaussian (erfc) drop shadow |
| `ring_opacity` / `ring_width` | 0.10 / 0.8 | thin dark contour at the edge |
| `full_damage` | 1 | redraw the full output when glass is visible (no seams) |
| `shader_path` | "" | load this fragment shader instead of the built-in one |
| `window_classes` | "" | regex: windows whose class matches get glass behind them |
| `window_radius` | -1 | window glass radius; < 0 = `decoration.rounding` |

## Test

`test/run.sh start` launches a nested Hyprland with a headless 2560x1664 `MBA` output, the test shell in
`test/qs/shell.qml` (wallpaper, dock, two cards with blur regions) and a foot window.
`test/run.sh shot NAME` writes `/mnt/code/hyprk/reference/ours/plugin-NAME.png`, `reload` swaps in a new build,
`stop` exits and kills only this instance. Set `LG_WALLPAPER=TahoeDark` before `start` for the dark wallpaper.

Fallbacks: see `FALLBACKS.md`.
