# Vibrancy of secondary text on glass, macOS 27.2.1 (26B131)

Question: do secondary / tertiary / disabled text, shortcut glyphs and separators on the glass menus and panels blend
with the backdrop (plus-darker in light, plus-lighter in dark, or a colour matrix), or are they a plain alpha?
Answer: **it depends on the surface**. The menus (NSMenu, Finder's File menu and the desktop menu) are a plain alpha
mix on every channel over every backdrop. The menu bar status modules (ControlCenter.app's Wi-Fi / Battery / Focus)
are additive: a constant step on every channel, so their secondary text takes the backdrop's hue. Spotlight's mode
list shortcuts are additive too (SPOTLIGHT-27.2.1.md R4.4, +67).

Marks: **decoded** (file / string), **measured** (Mac pixels or our session), **inferred**, **unknown**.

## Decode chain

1. **Vibrant appearance colours** (decoded). `VibrantLight.car` and `VibrantDark.car` from
   `System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/`, taken from the restore image's system
   DMG `141-12228-174.dmg` with 7z, read with the BOM / `COLORS` tree reader of GAPS-REA-windows.md
   (`re-work/gaps-windows/scripts/cartree.py`). In a vibrant appearance the label colours are **opaque greys**, made
   for a plus-darker / plus-lighter composite (out = D + S - 255 in light, D + S in dark):

   | colour | VibrantLight | step (plusD) | VibrantDark | step (plusL) | Aqua / DarkAqua (alpha, for comparison) |
   |---|---|---|---|---|---|
   | secondaryLabelColor | 128 | -127 | 124 | +124 | black .50 / white .55 |
   | tertiaryLabelColor | 191 | -64 | 65 | +65 | black .26 / white .25 |
   | quaternaryLabelColor | 230 | -25 | 35 | +35 | black .10 / white .10 |
   | quinaryLabelColor | 242 | -13 | 20 | +20 | black .05 / white .05 |
   | disabledControlTextColor, placeholderTextColor | 198 | -57 | 65 | +65 | black .25 / white .25 |
   | controlTextColor | 76 | -179 | 229 | +229 | black .85 / white .85 |

2. **Which filter a material uses** (decoded). Each `Mica: <name>.caar` material rendition in `Aqua.car` /
   `DarkAqua.car` / `SystemAppearance.car` (`re-work/tl-car/`) carries `NSVisualEffectViewDefaultVibrancyFilter`:
   `Menu.caar` ThickLight **PlusD** / MediumDark **PlusL**; `MenuBar.caar` PlusD / PlusL; `Sidebar`, `InlineSidebar`,
   `InlineTitlebar`, `OverlayBacking`, `SheetUnderlay` the same pair; `Sheet.caar` SourceOver; `Selection.caar`
   (Focused) "Sover". Every light material PlusD, every dark one PlusL. The filter names exist in QuartzCore
   (`plusD`, `plusL`, `plusDIgnoreAlpha`, `vibrantColorMatrix`, `vibrantDark(S, D)`, `vibrantLight(S, D)`) and CoreUI
   (`PlusD`, `PlusL`, "Vibrant Color Source Over", "Vibrant Color Multiply"): `re-work/cstr/`.
   So a legacy vibrant menu would draw tertiary text at D - 64 (light) / D + 65 (dark).
3. **27.2.1 menus are glass menus** (decoded strings, not traced): AppKit holds `NSGlassMenusEnabled`,
   `NSMenuUseGlassWindowStyle`, `NSGlassMenuLayoutEnabled`, **`NSGlassMenuContentAboveGlass`** and
   `NSMenuShowNonVibrantRegion` (`re-work/cstr/AppKit.txt`). Their defaults and readers were not traced. The pixels
   (below) say the menu content is drawn source-over above the glass, not through the Mica Menu material's PlusD/PlusL.
4. **Control Center module styles** (decoded, CoreMaterial `moduleStroke.visualstyleset`, `re-work/res/CoreMaterial`):
   `moduleSecondary` = vibrantColorMatrix, identity + 0.35 bias, backdrop-aware (= D + 89); `moduleSecondaryOnLight`
   = 0.4 D + (36, 36, 40); `moduleRuleOnDark` = vibrantDark, colorDodge .45 + colorLighten white .38. The macOS status
   modules measure +80 / -104 (below): additive like `moduleSecondary`, but not its +89, and the light one is not
   `moduleSecondaryOnLight` (that would scale the backdrop). ControlCenter.app's own style for these labels was not
   traced: **unknown**; the numbers below are measured.

## Mac, per role (2x shots, display RGB)

Test: an **alpha** mix moves each channel in proportion to its distance from black / white (the fitted alpha is the
same on R, G and B, the step is not); an **additive** filter moves every channel by the same step (the step is the
same, the fitted alpha is not). The Tahoe wallpapers put a strongly coloured glass under each sample, and the glass
under the menus runs from blue to cream (light) and navy to violet (dark), so one shot holds several backdrops.

### Menus: plain alpha (measured)

`menubar/pulldown-{light,dark}.png` (File menu over Tahoe), `menubar/a11y-modes-file-menu.png` (1x, the same menu
over a white desktop; normal column). glass -> ink (alpha fitted per channel):

| role | light, over Tahoe | light, over white | dark, over Tahoe | dark, over white |
|---|---|---|---|---|
| shortcut (⌘T, enabled row) | 212,232,255 -> 156,171,188 (.264 .264 .263) | 252,253,255 -> 190,192,193 (.246 .243 .242) | 53,43,191 -> 104,96,209 (.254 .251) | 120 -> 151 (.23) |
| shortcut (⌘D, disabled row) | 240,239,227 -> 176,176,168 (.263 .263 .261) | 253 -> 189 (.255, ⌘O) | 89,66,224 -> 131,113,231 (.252 .250 .249) | 120 -> 154 (.25, ⌘O) |
| shortcut (⌘N, top row) | 172,221,255 -> 122,159,189 (-50 -62 -66) | 243,247,255 -> 177,180,190 | 35,34,134 -> 90,89,168 (+55 +55 +34) | 121 -> 155 (+34) |
| disabled label | 240,240,224 -> 177,178,165 (.26, Quick Look) | 253 -> 187 (.262, Open) | 96,76,217 -> 136,122,226 (.252 .257, Quick Look) | 120 -> 155 (.258, Open) |
| separator | 229,235,240 -> 206,211,216 (.101 .103 .102) | (not on the shot) | 72,53,217 -> 98,82,223 (.143 .142 .140) | (not on the shot) |
| separator, lower | 241,241,221 -> 216,216,198 (.102 .102 .102) | | 98,80,214 -> 120,105,221 (.140 .144 .141) | |

The ⌘N row decides it: light -50 on R (glass 172) but -66 on B (255); dark +55 on R (glass 35) but +34 at glass 120.
Additive would be -64 / +65 everywhere (VibrantLight / VibrantDark tertiary). Menus: **black .26 / white .25**
(tertiaryLabelColor of Aqua .259 / DarkAqua .247), separators **black .10 / white .14**. Primary labels .85 (both).

### Status modules: additive (measured)

`panels/module-wifi-{light,dark}.png` (Tahoe). glass -> ink (step per channel):

| role | light | dark |
|---|---|---|
| lock (filled glyph, full coverage) | 180,240,255 -> 74,137,153 (-106 -103 -102) | 66,90,209 -> 145,169,255 (+79 +79, B clips) |
| chevron | 151,227,255 -> 46,119,153 (-105 -108 -102) | 42,70,187 -> 124,152,255 (+82 +82) |
| "Known Network" | 192,234,247 -> 85,128,146 (-107 -106 -101) | 58,72,206 -> 136,152,255 (+78 +80) |
| glyph in an off disc (step over the disc) | 154,204,235 -> 47,100,133 (-107 -104 -102) | 59,74,208 -> 139,154,255 (+80 +80) |
| lines (3 rows, neighbour difference) | -20.0 -20.0 -20.0 at 174,224,253 / 190,235,247 / 170,225,254 | +20.0 on every channel at 33,50,188 / 58,73,208 / 54,75,198 |
| off disc, hovered row | -20 (STATUS-REA R4.2) | +20 (STATUS-REA R4.2) |

Fitted alphas on the light lock: .59 / .43 / .40 on R / G / B while the step stays 102-106: additive. Module
values: **secondary plus-darker 104 / plus-lighter 80; lines, off discs, the hovered row 20 / 20**; the off disc's
glyph stacks (glass + 20 + 80 in dark). Not the VibrantLight / VibrantDark secondary (-127 / +124). No flat second
backdrop exists for the modules (STATUS-REA "Left to do" 2); the colour test above stands in for it.

## hyprk (headless, scale 2, wallpapers flat grey 127 and a gradient #2f7fe0 -> #f2d65a)

Over-blends in the scene graph and in the compositor are premultiplied src-over: out = src + D (1 - a). Plus-lighter
is src = (k, k, k), a = 0 (`shell/shaders/plustext.frag`, `plusfill.frag`). **Plus-darker cannot be built from it**:
any mix of src-over and additive layers gives out = s D + c with one s in [0, 1] for all channels and c >= 0, while
D - k needs s = 1 and c = -k. Without the glass's colour under the text (the plugin draws it; a QML item cannot read
it), light keeps the alpha with the right step at the glass's luminance, as the Dock does (Theme.dock).

**Menus** (MenuDropdown, TextMenu, Tokens): already the Mac's alphas, **no change** (comments now cite this file).

| role | light, grey | light, colour | dark, grey | dark, colour |
|---|---|---|---|---|
| shortcut / disabled | 203 -> 150 (.261) | 160,216,255 -> 117,159,189 (.267 .264 .259) | 115 -> 150 (.25) | 72,126,174 -> 118,159,196 (.251 .254 .269) |
| separator | 203 -> 182 (.103) | 170,219,252 -> 153,197,226 (.101 .100 .105) | 115 -> 135 (.143) | 83,128,159 -> 107,146,173 (.140 .141 .143) |
| primary label | .85 | .85 | .852 | .852 |

**Status modules** (StatusModulePanel.qml). Before: black .5 / .1, white .4 / .1. After: dark additive
(+80 secondary, +20 lines, off discs and hovered row, through plustext.frag); light unchanged.

| role | Mac | before, grey | before, colour | after, grey | after, colour |
|---|---|---|---|---|---|
| dark secondary | +80 every channel | 115 -> 171 (+56) | 59,124,193 -> +78 +52 +25 | 115 -> 195 (+80 / +81) | 59,124,193 -> 140,205,255 (+81 +81, B clips) |
| dark line | +20 | +14 | +20 +13 +6 | +20.0 | 56,123,196 -> 76,143,216 (+20 +20 +20) |
| dark hovered row | +20 | +14 | | 115 -> 135 (+20) | |
| light secondary | -104 every channel | 203 -> 101 (-102) | 146,212,255 -> 72,105,127 (-74 -107 -128) | unchanged | unchanged |
| light line | -20 | -21 | 143,210,255 -> -15 -21 -26 | unchanged | unchanged |

"Before" in dark is computed from the alphas (white .4 / .1); the light rows were measured and are an exact alpha
fit (.502 / .103 on every channel), so the computed dark rows hold. Battery's state lines, percentage and "Energy
Mode" read +81 over grey after the change.

## Left to do

- Light module text: plus-darker needs the glass's colour under the text. Options: the plugin drawing secondary text
  coverage with a subtract blend (plugin territory), or the text coloured from the glass estimated from the blurred
  wallpaper (wrong over windows). Until then the light secondary keeps its hue at half strength (-74 / -128 where the
  Mac is -104 / -104 on a blue glass).
- Trace `NSGlassMenuContentAboveGlass` and the 27.x menu item view to confirm in code what the pixels show.
- ControlCenter.app's label style for the modules (+80 / -104, not CoreMaterial's moduleStroke +89): not found.
- Status modules over a flat backdrop on the Mac (none on file): the additive fit rests on the colour test.

Scripts used (scratch, not kept): a per-glyph sampler (ink = mean of the 6 darkest / brightest pixels, glass = the
lightest / darkest 40 % of the box) and a line sampler (line row minus the mean of the rows 3 px above and below,
per column).
