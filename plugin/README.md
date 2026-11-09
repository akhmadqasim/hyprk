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

## Materials (recipes)

Apple's numbers from `/mnt/code/liquid-glass-re/SPEC.md` section 9 (glass version v2) live in
`src/Material.cpp`. Most are size-relative: `D` = smallest extent of the glass shape in pt.

| Recipe | Face YCC light (black, white, sat) | Fill / lift light | Inner refraction height / amount | Outer layer (h / amount / opacity) | Blur | Shadow | Used for (default) |
|---|---|---|---|---|---|---|---|
| `regular` | 0.4, 0.92, 1.0 (Apple 1.03, 1.2) | white 12% (Apple 20%) | 0.25 D (max 20) / -0.5 D (min -60) | 0.2 D / 0.25 D / 0.6 | D 48→160 : 2→4 (Apple 64→160 : 0→4), variable: full until 1 pt from the edge (Apple: half at 1 pt) | D 64→160 : 0.25→0.75, r 24, y 8 | notifications, spotlight, switcher |
| `menu` | as regular | as regular | as regular | as regular | as regular | 0.6, r 24, y 10 | `hyprk-overlay`, `hyprk-menubar` |
| `clear` | 0.125, 1.08, 1.06 | none | 0.25 D / -0.8 D | none | D 48→120 : 3→8 | as regular | |
| `dock` | 0.15, 0.9, 1.1 (Apple 1.25) | none / 0.05 | 0.08 D / -0.18 D | 0.13 D / 0.42 D / 0.2 | 1.5 | as regular | `hyprk-dock` |
| `controlcenter` | 0.18, 0.55, 1.0 (Apple 0.125, 0.8, 1.2), 6 % warm grey, face tone kept in 0.15-0.45 (max as relative luminance: white labels >= 4.7:1; dark 0.10-0.40) | none | 0.225 D (max 25) / -2.0 D (min -80) | 0.0357 D / 0.0714 D / 0.1525 | none (Apple 4: too much on top of Hyprland's blur), variable from 100 pt in | as regular | `hyprk-controlcenter` |

The face colour is Apple's YCC composite (SPEC 9.7): `Y' = black + (white - black) Y`, chroma x saturation,
then the fill. The controlcenter face and the regular/dock saturation deviate from the decoded values:
in our gamma-space shader the decoded CC face measured ~1.4:1 against white tile labels (JUDGE.md);
(0.1, 0.5, 0.7) gives >= 5:1 (measured 5.3-9.0 in `reference/ours/plugin-shell-cc.png`).

Also per recipe (SPEC 9.2/9.3): edge bleed (opacity D 64→160 : 0→0.5, height/amount/blur 0.35 D, colour
regular (0.9, 1, 1.2), clear family (0.75, 1, 1.2)), blur fill (regular light: lighten 0.9, normal 0.5;
dark: darken 0.9, normal 0.5), drop shadow coloured by the backdrop saturated x1.2,
regular ring shadow (offset 8, stroke 4, radius 5, opacity 0.06). Dark sides: regular (0.125, 1.125, 1.3),
dock (0.05, 0.92, 1.25), others as light.

Variable blur needs the unblurred backdrop: the plugin copies the framebuffer being rendered (one blit +
mip chain per glass element) and mixes it with Hyprland's blur by Apple's per-pixel blur amount.

Light/dark: `appearance = "auto"` reads the backdrop luminance of each glass (1 pixel of a high mip,
read back asynchronously every 6 frames) and switches with Apple's V2 hysteresis: dark below 0.1, light
again above 0.3 (`adapt_low` / `adapt_high`).

Not from the RE (by eye): the per-recipe `lift` (scaled by the `lift` key), the rim floor, the inner shadow, the
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
| `lift` | 1 | scales each recipe's light-side lift (0 = none) |
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
| `linear` | 0 | 1 = shader works in linear light like QuartzCore. The recipes are tuned for 0; with 1 the CC labels drop to ~3:1, so it stays off until re-tuned |
| `stats` | 0 | GPU timing, read with `hyprctl liquidglass` |
| `full_damage` | 0 | 1 = redraw the whole output while glass is visible (debug; see below) |
| `shader_path` | "" | load this fragment shader instead of the built-in one |
| `window_classes` | "" | regex: windows whose class matches get glass behind them |
| `window_radius` | -1 | window glass radius; < 0 = the window's rounding |

Keys of the first iteration (`saturation`, `tint_light`, `tint_dark`, `brightness_*`, `refraction`, `shadow_opacity`, ...)
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
is skipped on rotated outputs. Then traffic lights #FF5F57 / #FEBC2E / #28C840 (grey when the
window is inactive, glyphs × − + while the pointer is over them), and the title centred in SF Pro Text 13
semibold. Close sends the client a close request, minimise moves the window to `special:minimized`, zoom
toggles maximised, dragging the rest of the bar moves the window.

`titlebar = "auto"` (default) gives a bar to Wayland clients that bound xdg-decoration (Hyprland always
answers server-side, so they draw none: foot, Qt apps); GTK apps with client-side decorations get none.
`titlebar_classes` (regex) forces a bar, `titlebar_exclude` (regex, default the hyprk apps, which draw their
own) prevents one, `titlebar = "classes"` only uses the regex, `"off"` disables it.

| Key | Default |
|---|---|
| `titlebar` | `auto` |
| `titlebar_classes` / `titlebar_exclude` | "" / `^(org\.hyprk\..*|hyprk-.*)$` |
| `titlebar_height` / `titlebar_button` / `titlebar_gap` / `titlebar_inset` | 32 / 14 / 7 / 15 pt (SPEC: bar 32, buttons 14; gap and inset measured on the reference screenshot) |
| `titlebar_font` / `titlebar_font_size` | `SF Pro Text` / 13 |
| `titlebar_color` / `titlebar_color_inactive` | `0xF3F1EFFF` / `0xF6F5F4FF` |
| `titlebar_text` / `titlebar_text_inactive` | `0x333333D9` / `0x33333359` |
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
