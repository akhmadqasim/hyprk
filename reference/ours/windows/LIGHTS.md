# Traffic lights as glass (2026-11-11)

User report: "the close, minimize and maximize buttons should be liquid glass". Ours were a three-stop vertical fill in a
0.5 pt ring, in the plugin title bar (`plugin/src/Titlebar.cpp`) and in the QML one (`ui/HyprK/TrafficLights.qml`).

## What the Mac does (REA, 27.2.1 dyld cache, unslid addresses)

- AppKit: `_NSThemeWidget` has no drawRect. `+[_NSThemeWidgetCell _visualProviderClassForBezelConfiguration:]` (0x18adf01bc)
  picks `NSThemeWidgetAquaduckVisualProvider` when Solarium is on (CoreUI `NSThemeWidgetAppearanceBasedVisualProvider` only
  with it off). It hosts SwiftUI `AppKit.ThemeWidgetView` -> `DesignLibrary.WindowControl` (body 0x18b21d5e4, call
  0x18b21da70), with `.spring(response 0.2, damping 0.9)` (0x18b21d790).
- DesignLibrary (`MacWindowControlElement` body 0x195e393d0): the disc is `Color.clear.materialEffect(Material(provider:
  WindowControlMaterialProvider))` in a capsule (0x195e3ab7c), or a pre-rendered `WindowControlBodies/*` image when the
  control cannot animate its size; glyph `WindowControls/*` on top with `.spring(response 0.1, damping 1)` (0x195e3b110).
- `WindowControlMaterialProvider` (resolve 0x195f78670, `usesGlassAppearance` true for all but closeHUD): an SDF layer
  group: a linear gradient from the top to 75 % of the height (0x195f7943c), two inner `SDFLayer.shadow`s with a Gaussian
  blur of 1 (0x195f790ac..), and a rim `SDFLayer.glassKeyFillHighlight` (0x195f7a558: key angle pi/2, key spread 120 deg,
  fill angle 3pi/2; 0x195f7acf8: spread 80 deg, fill angle pi), masked to a ring.
- No backdrop: nothing in these functions samples, blurs or refracts what is behind the button (no GlassMaterialProvider,
  CABackdropLayer, NSGlassEffectView or displacement call). **So: not the Liquid Glass backdrop material, but a glass-styled
  disc: gradient + inner shadows + the glass key/fill specular rim.** That is what the crops show.
- Gradient colours decoded (0x195e3d9c4, pairing by hue): dark close (250,106,97) -> (239,105,98), min (250,181,26) ->
  (254,207,52), zoom (86,200,58) -> (82,196,61); glow colours (0x195e3d38c) close (255,16,0), min (255,141,0), zoom
  (60,181,0): our fitted light glows are (225,26,0), (229,112,0), (52,154,0).
- Press: SwiftUI `FlexInteraction` variant `.windowControl` (settings 0x1908b1bb4): lift 2 pt on the 14 pt disc = 16 pt
  (the measured 1.15x), scale spring response 0.355 damping 0.4 (name mapping inferred). No hover delay constant found.
- Not determined: the asset catalog bodies, the exact state -> opacity table, what brightens the pressed disc.

## What we draw

`plugin/tools/lights_model.py`: one formula (lit top, darker belt, caustic glow in the lower centre, rim arcs with an
angular profile, edge, coloured shadow) with one row of numbers per state, **fitted** to the 2x crops
`reference/screens/27.2.1/windows/lights-*.png` (not derived from the SDF recipe above, whose constants are only partly
decoded). The rim is defined in pt (1.25 pt reach), so it does not vanish at a fractional scale. Both title bars draw the
same formula from the same table (`lights_model.py check` compares them): the plugin per pixel into a texture, QML in
`ui/HyprK/shaders/lights.frag`.

## Measured (headless MBA 2x; rms / max over the disc interior vs the Mac crop, sRGB levels; close / minimise / zoom)

| state | before (plugin) | after, plugin | after, QML (Settings; Finder the same at rest) |
|---|---|---|---|
| dark rest | 10.5 / 20.3 / 22.6 | 4.3 / 8.3 / 9.4 | 4.3 / 8.3 / 9.4 |
| light rest | 6.8 / 7.4 / 8.4 | 4.1 / 4.2 / 5.1 | 4.1 / 4.2 / 5.1 |
| dark hover (glyphs) | not measured | 6.8 / 8.0 / 10.2 | 6.5 / 8.0 / 12.5 |
| light hover | not measured | 6.0 / 4.6 / 8.5 | 5.6 / 4.5 / 12.6 |
| dark pressed (16 pt, glyph masked) | not measured | 4.9 / 10.0 / no Mac crop | 4.9 / 10.1 / - |
| light pressed | not measured | 5.3 / 6.3 / 7.1 | 5.3 / 7.2 / 7.1 |
| dark inactive | not measured | 2.5 | 2.5 |
| light inactive | not measured | 2.8 | 2.8 |
| inactive hover | = hover | = hover | = hover |

- Dark rest close, rim rows top (outer, inner): Mac #F5C6BC #FFA094, ours #FDC3BA #F3998F (before #F5C2B8 #E87364); sides
  plain: Mac #D96154 #E16052, ours #E05D4E #E25E4F. Top / centre / bottom #E76E62 #E16457 #DD766E vs #E76D60 #E26657 #DE7064.
- Light rest close: side rim Mac #B40A0A #D7655A, ours #A81A0C #DC6A5E; top / centre / bottom #EC786B #EA8277 #E99990 vs
  #EC776B #EA8278 #EA9389. Glow 2 px below: -13 G on white (Mac -15).
- Disc 14.0 pt, pressed 16.0 pt in both (Mac 14 / 16; light pressed reads 17 with its rim).
- Scale 1.6 and 1.25: the top and bottom rim rows stay (close centre column G 157 139 | 110 at 1.6 in the plugin, 146 158 |
  113 in QML; 147 / 154 at 1.25), the caustic stays.
- Minimise and zoom in dark carry the larger residual: the crops clip the P3 yellow and green in the blue channel.
- Plugin bar inset 15 -> 9 pt (Q-windows-07: TextEdit and Terminal discs at x 9, 32, 55), disc centre 16,16 as the Mac.
- Glyphs fitted on the hover crops: x stroke 2.05 pt, minus 2.0 x 7.9 pt, full-screen triangles in a 5.8 pt box.

Not from Apple data: the dark pressed zoom (its crop shows the rest disc): the rest disc times the close / minimise press
gains. Not verified on screen: Option hover (+ glyph), the press spring, GTK client-side lights (drawn by the theme).

## Colour space of the crops (2026-11-11)

The `lights-*.png` crops carry the Mac display's values (Display P3) with the profile embedded ("Display"): close at rest is
226,103,91 in the file and 244,93,84 in sRGB; yellow 243,191,0 -> 253,188,0; the green leaves the sRGB gamut (clipped). The
table was fitted to the raw values and drawn as sRGB. `lights_model.py load()` now converts each crop through its profile
(relative colorimetric, clipped) before the fit, and the table was refitted (body colours moved by up to 18 levels for
close, 64 for minimise, 80 for zoom in the clipped channel). The dark pressed zoom entry is again the new rest row x 1.205
(no crop of that press).

| interior vs the Mac crop in sRGB, rms levels | close | minimise | zoom |
|---|---|---|---|
| dark rest, plugin title bar on screen (foot, MBA 2x), old table | 12.7 | 19.3 | 38.0 |
| same, new table | 3.0 | 4.0 | 8.9 |
| fit, whole disc: dark rest / light rest | 4.1 / 5.4 | 4.7 / 5.7 | 8.4 / 6.8 |
| the raw crop against its sRGB version (what the old fit could not see): dark / light | 12.4 / 10.5 | 21.1 / 18.5 | 38.5 / 16.0 |

Light, pressed and inactive states read back on screen (2026-11-11, session 10; plugin title bar on foot, MBA 2x; a foot
with a white background gets the light bar; press held with a virtual pointer, cursor hidden). Interior = the disc without
its outer 1 pt, glyph pixels (luma under 0.8 of the disc's median, grown by 1 px) left out; against the crops converted to
sRGB, rms levels close / minimise / zoom:

| state | rms | glyph ink at the centre, ours = Mac |
|---|---|---|
| dark rest | 3.5 / 4.4 / 9.4 (the 3.0 / 4.0 / 8.9 above with this mask) | |
| dark pressed | 5.0 / 5.8 / no Mac crop | 199,0,0; 251,62,0 |
| dark inactive | 1.5 (one disc, three places) | |
| light rest | 2.3 / 2.4 / 3.4 | |
| light pressed | 2.7 / 3.8 / 4.4 | 232,0,0; 255,86,0; zoom 179,255,122 vs 183,255,128 beside the glyph |
| light inactive | 1.4 | |

The legacy flat table in `Titlebar.cpp` (`LIGHTS` / `LIGHTS_INACTIVE`: fill / ring / glow per state, raw Display P3) is
dead but still there: only its glyph inks are drawn, and those are sRGB already, so nothing is left to convert. It cannot
go alone: `shell/tests/run.mjs` ("traffic lights: plugin colours and timing match Tokens.lights") parses that table and
`RIM_WIDTH` out of `Titlebar.cpp` and fails without them (tried: 287 passed, 1 failed). The removal (a 3 x 2 x 2 `GLYPHS`
table in its place, 12 lines for 35) waits for that test to compare the glyph inks only.
`#56F66E`, the dark pressed zoom fill it carries (also
`ui/HyprK/Tokens.qml` and `themes/gtk/build.py`), is sRGB as it stands: it is a pixel of the legacy art
`WindowFrame_WindowControlButtons_Regular@2x.psd` in DarkAqua.car (SPEC 13.6), whose CSI header has colour space id 1 (sRGB;
3 would be Display P3) and whose pixels live in `ZZZZPackedAsset-2.0.0-gamut0` (ARGB, id 1). No conversion. It is the
non-Solarium art, not what 27.2.1 draws: the Solarium disc has no crop of that press.
The ui/ hand-off of the refit is done: `lights_model.py check` reports that the tables in `Titlebar.cpp` and
`ui/HyprK/TrafficLights.qml` match (2026-11-11, session 10).
