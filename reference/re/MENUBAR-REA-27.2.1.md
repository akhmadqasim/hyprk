# Menu bar REA, macOS 27.2.1 (26B131)

Question: is there any Liquid Glass on the menu bar (bar, open-title pill, status item highlight)?
Answer: **no**. Nothing on the bar uses `glassBackground`, `CASDFGlass*`, `NSGlassEffectView` or a DesignLibrary
glass variant. The bar is the desktop picture; the pills are a heavily blurred backdrop with a colour change.
The dropdown menus are a separate case (regular glass, see LIVE-27.2.1.md, not re-traced here).

## Method (PC, Linux)
- Dyld cache `~/Downloads/macos/dyld-27.2.1`. `ipsw dyld extract` and `ipsw dyld macho -x --force` both fail
  (`failed to remap symbol _objc_msgSend$...`). What worked without extracting:
  `ipsw dyld macho <DSC> SkyLight -s` (cstrings) and `-n` (symbols: SkyLight keeps its private C++ names),
  `ipsw dyld xref <DSC> <CFString addr> -i SkyLight` (first run writes `<DSC>.a2s`, then fast),
  `ipsw dyld disass <DSC> --vaddr A --count N --cache <DSC>.a2s --demangle` (no `--image` with `--vaddr`),
  `ipsw dyld dump <DSC> <addr> --size N` for constants. objc_msgSend stubs (0x188007ff0..) were disassembled once
  and mapped to selectors. ipsw is a snap: it cannot read /mnt/code or /tmp, keep its inputs under ~.
- MenuBarAgent, ControlCenter, SystemUIServer copied from the system volume (`141-12228-174.dmg`, apfs-fuse -o ro;
  the path holds a comma, which breaks apfs-fuse option parsing: mount through a symlink). Thinned with
  `llvm-lipo -thin arm64e`; `ipsw macho info -u` (fixups) + `llvm-objdump -d` for GOT refs, `ipsw macho disass` for names.

## Who draws what
- Bar, app menu titles, logo, title pill, status item pill: **WindowServer** (SkyLight, `PKGMenuBarContext.mm`,
  class `SolariumMenuBarContext`; enabled by `WS::Features::solarium_menubar_enabled` 0x182b0a910).
- Status items' own content: MenuBarAgent scenes (MenuBarCore). Its highlight layer is `MenuBarBackdropHighlightLayer`.
- MenuBarAgent's glass code (`GlassContainerViewDisplayItem`, `_kCAFilterGlassBackground`, `CASDFGlass*`) serves the
  HUD, Live Activities / Campo pills and the AV accessory, not the bar.

## Bar background: none
`SolariumMenuBarContext::configure_layers` 0x18298efd4 builds `menubar.root`, `menubar.desktop_capture` (IOSurface of
the desktop picture), `menubar.desktop_capture.enhancement`, `menubar.backstop.ax` / `.fs`, `menubar.logo`,
`menubar.text(.group)`, `menubar.pill.group`, `menubar.aux.shadow` (sublayers `smudge`, `edge`: shadowRadius 1.5,
offset (0, -0.5), darken blend: legibility shadow of the text). No filter on the capture in the normal state, so the
bar pixels equal the desktop (matches MAC-ANSWERS Q9.1). `update_layers` 0x18298fc90 only switches backstops:
- `colors` (static init 0x182995c48): kSolidDark = grey 0.87, kSolidLight = black (opaque backstops, Reduce
  Transparency / full screen), kDarken = black alpha 0.18, kLighten = white alpha 0.35 (enhancement layer, darken /
  lighten blend). A CoreUI `kCUIWidgetVisualEffectView` + `kCUIVariantMenuBarMaterial` image is used on another
  branch (not traced; legacy / full-screen material).

## Top dimming ("underbelly"): luminance curve, no blur
`Underbelly::rebuild_window_and_ca_context` 0x18298d174: own WS window from the screen top, height
`floor(H * (1 - underbelly_gradient_lo))` = 8.5 % of the display height (94 pt on a 1107 pt display; measured
"255 from about 100 pt"). One `CABackdropLayer` with two `luminanceCurveMap` filters, masked by a vertical
`CAGradientLayer` (alpha 0 at the bottom to 1 at (hi - lo) / (1 - lo) = 94 % up), interpolation
cubic-bezier(0.42, 0, 0.58, 1). Tunables (`__DATA` 0x1eb11bfb8..):
- dark_background_curve (light text) = [1.5446, 1.0, 0.762864, 0.69], compositing `plusD`
  (`adjust_for_light_text` 0x18298d95c);
- light_background_curve (dark text) = [0.45, 0.4, 0, 0], compositing `plusL` (`Underbelly::update` 0x18298daf0);
- underbelly_gradient_lo 0.915, hi 0.995; animation_duration 1.0, delay 0.4; order_underbelly_atop_icons 1.

## Open menu title pill: blur + colour, not glass
`SelectionPill::new_pill` 0x18298ecc0 always makes a `BlurrySelectionPill` (used for `menubar.pill.primary`,
`menubar.pill.help` and, from the `update_pills` block 0x182992434 with `PKGSystemStatusBarGetSelectedContentFrame`,
`menubar.pill.status_item`). Layers: `container`; `material` = CoreUI `kCUIWidgetMenuTitle`, state pressed,
indicatorOnly, backdropCompatible, presentation active/inactive, corner radius 12 continuous;
`blur` = the desktop capture with `desktop_capture_blurring_filters` 0x18298c848: colorSaturate 1.25 (dark text) /
1.5 (light text) + gaussianBlur radius 360, normalizeEdges, dither, bit depth medium; masked by `mask` (radius 12
continuous); `blur_enhancement` inside it: kDarken + darkenBlend (dark text) or kLighten + lightenBlend (light text).
`BlurrySelectionPill::update` 0x18298ddd0 hides the blur layer under a flag (bit 0x20 of the properties, or the
SwiftUI `Calistoga` feature flag vs `cgdebug::invert_ff_calistoga`); then only the CoreUI material shows.
The light/dark choice reads `AdjustmentProperties + 0x14 == 1`, which also picks the grey 0.87 backstop, so 1 is
read here as "dark text" (inferred).

## Status item highlight (MenuBarAgent): blur + colour matrix, not glass
`MenuBarBackdropHighlightLayer` init 0x10012ff5c (MenuBarAgent arm64e): `CABackdropLayer`, windowServerAware,
scale 0.125, masksToBounds, cornerRadius `kCALayerCornerRadiusAutomaticPill`, continuous; filters colorMatrix +
gaussianBlur radius 360 (0x1003fd120), normalizeEdges, dither, bit depth medium. Colour matrix per appearance
(0x1001302b8: appearance == 1 picks B), rows R G B A + bias:
- A: [0.9058 -0.2324 -0.0235 0 0.2480] [-0.0691 0.7426 -0.0235 0 0.2480] [-0.0691 -0.2324 0.9515 0 0.2480] [0 0 0 1 0]
- B: [0.9813 -0.1466 -0.0148 0 0.1490] [-0.0436 0.8784 -0.0148 0 0.1490] [-0.0436 -0.1466 1.0102 0 0.1490] [0 0 0 1 0]
Check: B on (69, 83, 206) gives (90, 105, 231); MAC-ANSWERS Q9.1 measured (90, 105, 230) for the open-title pill over
solid blue with white text. So white text = B, and the title pill looks the same as this layer (the CoreUI menu-title
material most likely carries the same recipe; not traced in CoreUI).
Hover: MenuBarAgent's `isPillHovered` belongs to the Live Activity pills; whether a plain status item lights up
on hover was not found in code and not measured.

## Not traced
CoreUI's `MenuTitle` pressed artwork; the `magic pocket` animation (`animate_magic_pocket` 0x18299184c,
`set_shadow_properties`); the VisualEffectView / MenuBarMaterial branch of `update_layers`; AppKit's NSMenu window
(dropdowns are glass per LIVE-27.2.1.md).
