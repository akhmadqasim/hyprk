# Window surfaces: static RE of the open GAPS-windows items (macOS 27.2.1, 26B131)

Scope: the OPEN items 4, 5, 6, 7 and 8 of `reference/GAPS-windows.md` (Settings content and cards, Form rows,
sidebar search capsule, sidebar over other wallpapers, Finder inactive title). Static work only, on the Linux PC.
Pseudocode excerpts: `decomp/windows-gaps.c`. Scratch files (scripts, listings, decoded archives):
`~/Downloads/macos/re-work/gaps-windows/`.

## Method (PC, Linux)
- Asset catalogs: `~/Downloads/macos/re-work/tl-car/{Aqua,DarkAqua,SystemAppearance,DL-Assets}.car` (already
  extracted). There is no assetutil here and `mcp__rea__inspect_asset_catalog` needs macOS, so I wrote a small BOM
  reader (`scripts/cartree.py`): BOM header and block index (big endian), the `tree` B+tree walk, then the CSI
  (`ISTC`) rendition header (little endian, rendition data at 184 + TLV length).
  - `scripts/dumpcolors.py`: the `COLORS` tree (old named-colour table, 8-bit BGRA). Output `colors-all.txt`.
  - `scripts/extractdata.py`: the `DATA` renditions named `Mica: *.caar` (NSVisualEffectView material layer trees).
    Payload tag `DWAR`, LZFSE (`bvxn`), decoded with `/usr/bin/lzfse`, giving NSKeyedArchiver plists.
    `scripts/ka.py` + `scripts/layers.py` print each CALayer tree. Output `mica-layers.txt`.
  - `scripts/fx2.py`: the `XFTC` effect presets ("Image (Effect)" renditions). Layout: tag, 3 words, count n,
    n offsets, total size, then per effect a fourcc, a parameter count and (id u32, 4-byte value) pairs.
  - Rendition key attributes: 10 = state, 14 = presentation state (1 = inactive window), 12 = scale.
- Code: dyld cache `~/Downloads/macos/dyld-27.2.1/dyld_shared_cache_arm64e` with ipsw (inputs under ~):
  `ipsw dyld macho <DSC> <image> -n --demangle` (SwiftUI keeps 267k local symbols, DesignLibrary few),
  `ipsw dyld disass --vaddr A --count N --cache <DSC>.a2s --demangle`.
  `ipsw dyld extract` still fails for SwiftUI (`failed to remap symbol _objc_msgSend$CGColorSpace`).
- `scripts/dscread.py`: reads cache bytes by vmaddr across the sub-caches. It decodes Swift field descriptors
  (`__swift5_fieldmd`) and walks `__swift5_proto` conformance descriptors to their resilient witnesses. That is how
  the stripped DesignLibrary `MacGroupBox.body` and `SeximalShapeStyle.resolve` were found. Packed pointers use
  0x180000000 + (v & 0x3ffffffff) (NOTES.md).
- REA CLI (Ghidra 12.1.4) on the extracted `re-work/ex/DesignLibrary.macho`, which sits 0x1000 below the cache
  (checked: same bytes at file 0x195de8758 and cache 0x195de9758):
  `rea decompile ... 0x195de8758 --snapshot gaps-windows/rea/DL.snapshot --provider ghidra`, Evidence
  `ev_daed777e6e7d98ed7ccc3ffa825235c3b47c69bde0dc73967d6629e3ea02942e`. Its pseudocode leaves SwiftUI calls
  unnamed, so I took the names from the ipsw listing of the same function.
- Pixels: I re-sampled `reference/screens/27.2.1/settings/desktop-dock-{active,inactive}-*.png` (2 px/pt,
  dithered, values are means over 50 x 70 px).

Marks: **confirmed** = read from code or data at the given address or rendition. **inferred** = derived, with the
basis named. **observed** = a pixel reading.

## 1. Settings content background and cards (GAPS item 4)

### 1a. Correction to the GAPS reading
- Observed. Inactive dark shot (`desktop-dock-inactive-dark-iconDark.png`, x 1420..1470): toolbar strip
  y 0..103 px = (36.5, 38.0, 38.8). Hairline y 104 = (45, 46, 48). Content from y 106 = (29.5, 30.5, 32.5).
  Card = (36, 37, 39).
- Active dark shot, same place: strip = content = (30.5, 31.5, 36.5). There is no hairline at rest.
- Light, active and inactive: strip and content both 255. Hairline only when inactive: 229.
- So the Mac "(37,38,39)" in item 4 is the 52 pt toolbar strip of an inactive window, not the content. The
  inactive content is (29.5, 30.5, 32.5). Ours stays (30,31,36). The inactive hairline matches Q-settings-04
  (#2D2E30).

### 1b. What draws the content: Material.contentFill, which is the Mica "ContentBackground" material
- Confirmed. SwiftUI `GroupedFormBackgroundModifier.DefaultBackgroundStyle._apply(to:)` 0x19adc1b70 switches on
  `GroupedFormBackground.Key`:
  - case 0 = `Material.contentFill` (0x19adc1fa4);
  - case 1 = `Material.windowFill` (0x19adc1f80);
  - case 2 = `Color(.sRGBLinear, white: 0.9765625, opacity: 1)` (0x19adc2014);
  - `Color.clear` when `scrollContentBackground` is hidden.
- Inferred: Settings uses case 0. Only `contentFill` matches the light 255 (windowFill is 246, see below).
- Confirmed (DarkAqua.car / Aqua.car, `Mica: ContentBackground.caar`, element 176, stored as 32-bit floats in
  `LKCGColorCodingProxy` r g b a, colour space not stored, so device / sRGB):

| material | layer | dark (active = inactive) | light (active = inactive) |
|---|---|---|---|
| ContentBackground | `fill` | 0.1176 grey = (30,30,30) a1 | 1.0 = (255,255,255) a1 |
| ContentBackground | `desktop tint` CAChameleonLayer | opacity 0.10 | none |
| WindowBackground (174) | `fill` | 0.1569 = (40,40,40) | 0.9647 = (246,246,246) |
| WindowBackground | chameleon | 0.10 | none |
| UnderPageBackground (201) | `fill` | 0.0784 = (20,20,20) | 0.9255 = (236,236,236) |
| UnderPageBackground | chameleon | 0.10 | 0.05 |

  - Confirmed: the Active and Inactive archives of these three materials are the same. Only their root layer name
    differs.
  - The chameleon layer is stored with a placeholder colour (0.708, 0.443, 0.684, a 0) and no compositingFilter.
    WindowServer supplies the colour (C3: mean wallpaper under the window, 6-bit).
  - The old `COLORS` table in the same cars (`windowBackgroundColor` #ECECEC / #323232, ...) is the legacy table
    and does not match 27 pixels. Do not use it.
- Inferred: active dark (30.5, 31.5, 36.5) = 30 grey + 10 % chameleon of the TahoeDark mean. That fits the table.
- Not found: why the inactive content is less blue (29.5, 30.5, 32.5). The material data does not change.
  `CGXWindow::resolved_chameleon_color` 0x1829f697c has no active-state branch: it takes the window, then
  `DesktopEffectsGetAverageColor`. Two candidates I could not settle:
  - the inactive shot was taken at another window position (the tint follows the wallpaper under the window);
  - an AppKit path such as `SLSTransactionSetBackdropChameleonContribution` (0x182741408) changes it.
  It needs a second inactive capture at the same position.

### 1c. The inactive toolbar strip
- Observed: (36.5, 38.0, 38.8) over content (29.5, 30.5, 32.5) = +7, +7.5, +6.3. Light: no change (255).
- Inferred, not decoded: AppKit's scroll pocket in an inactive window. AppKit has a default
  `NSScrollPocketConditionalThinFilmOnInactive`, set to true by the static init at 0x18b460ae4. The pocket builder
  that names the layer `ThinFilmBackgroundReplay` (sub_18b45e6d8, string xref 0x18b45eb9c) sets up blur and replay
  filters (radius values 16, 0.25, 6.0 seen), not a colour.
- Not found: the thin film's colour and blend. The Swift pocket code (NSScrollPocket.swift) is large and was not
  traced to the end.
- Mica `Titlebar` / `SeamlessWindowTitlebar` Inactive (fill 40 + chameleon 0.10, dark; 240 light) does not fit:
  light would read 240, the Mac reads 255.

### 1d. The card: DesignLibrary MacGroupBox, fill `Color.primary.opacity(0.03)`
- Confirmed: a grouped Form section is a SwiftUI `GroupBox`. `GroupedSection.body` 0x19adc83f0 builds
  `GroupBox<EmptyView, VStack<...>>`. `MacIdiomGroupBoxStyle.makeBody` 0x19a96c7c8 renders it as
  `DesignLibrary.GroupBox`.
- Confirmed: in a grouped form, `MacIdiomGroupBoxStyle.makeContent` 0x19a96cab4 passes contentInsets
  EdgeInsets(0) (0x19a96cd58). So the card adds no padding of its own.
- Confirmed: `DesignLibrary.GroupBox.body` picks `MacGroupBox` under `StaticIf<Solarium>`, else `MacGladeGroupBox`
  (typeref 0x195fc4ba0).
- Confirmed: `MacGroupBox.body` 0x195de9758 (found through its View conformance 0x195f975a0, witness 0x195de9c88)
  has these parts:
  - `.background { PositionStrokeShapeView<ContainerRelativeShape, ControlBorderShapeStyle,
    _ShapeView<ContainerRelativeShape, SeximalShapeStyle>>? }` (mangled name 0x195fc7be4);
  - stroke `StrokeStyle(lineWidth: 1, miterLimit: 10)` (0x195de9c38); the border is nil when a flag is set;
  - `clipShape(ContainerRelativeShape)`;
  - corner style `.continuous` with `groupBoxCornerRadius` from the environment.
- Confirmed: `SeximalShapeStyle.resolve(in:)` 0x195f89be4 = `Color.primary._settingOpacity(0.03)._adaptive`.
  The double is 0x3f9eb851eb851eb8 = 0.03.
- Inferred from pixels: `Color.primary` resolves to opaque black (light) and opaque white (dark). With labelColor's
  0.85 the light card would read 248.5, not 247.

| | content under the card | card = content + primary 3 % | Mac |
|---|---|---|---|
| light | 255 | 255 x 0.97 = 247.4 | 247 (#F7F7F7) |
| dark, key | (30.5, 31.5, 36.5) | (37.2, 38.2, 43.1) | (37, 38, 43) |
| dark, not key | (29.5, 30.5, 32.5) | (36.3, 37.2, 39.2) | (36, 37, 39) |

- Not traced: the stroke colour (`ControlBorderShapeStyle`, resolve witness 0x195e452c0). Q-settings-11 sees no
  stroke at normal contrast.
- Not traced: the radius value (`groupBoxCornerRadius` env, getter 0x195dbb5c0 in the cache). Q-settings-11 reads about 13.

### 1e. What to change in hyprk (not changed)
- `settings/Theme.qml:164` `cardFill: theme.dark ? "#25262B" : "#F7F7F7"` (opaque). Mac: black / white at
  alpha 0.03 over the content. Make it `theme.dark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.03)`. Then the card
  follows the content in every state.
- `settings/Theme.qml:162` `windowBg: theme.dark ? "#1E1F24" : "#FFFFFF"`. Mac rule: dark = 30 grey + 10 %
  chameleon of the wallpaper mean (the same `Ch` blend the sidebar uses, but 0.10), light = 255 with no tint.
  The inactive reading (29.5, 30.5, 32.5) is not explained yet (1b), so I would not special-case it.
- The inactive strip (36.5, 38, 38.8) + hairline (45,46,48) belongs to the toolbar / ScrollEdge path
  (`Theme.qml:173` `scrollEdge` and the HyprK ScrollEdge). It is not the content background. The colour rule is
  not found (1c).

## 2. Grouped Form rows (GAPS item 5)
- Confirmed: `FormCell<Content>.body` 0x19adca230 is `VStack(spacing: 0) { row content, Optional(Divider) }`. The
  row content is padded by the row insets. The Divider is padded by `dividerInsets` (type in the symbol at
  0x19adca8f0).
- Confirmed: row insets = the `FormRowInsetsTraitKey` value. The default (0x19add0664: zeros, tag 2) gives
  EdgeInsets(10, 10, 10, 10) (0x19adca6a0..ac). Leading gets + 31 x `FormRowIndentationKey` (0x19adca6e8).
  - So vertical padding is 10 above and 10 below the row content.
  - The FullRow button style uses the same 10 (0x19add11b0).
- Confirmed: separator insets (`preferredSeparatorInsets` 0x19adc96d8) are horizontal only: leading 10 + 31 x
  indent, trailing 10. They are 0 when the row has a `FormRowBackground`.
- Confirmed: `FormCell.dividerInsets` 0x19adcbd80 takes this row's insets and, when a next row exists, the smaller
  of this row's and the next row's leading / trailing.
- Inferred from the above: the divider is the last child of a row, at its bottom. So each row's height holds the
  divider below it. The divider is Optional, so the last row of a section has none.
- Confirmed: there are no card paddings (1d: contentInsets 0).
- Confirmed: GroupedFormMetrics.init 0x19add26d4 (field names from `__swift5_fieldmd` 0x19bc2be34):
  - defaultFormInsets 20 all round;
  - seamlessFormInsetsWithHeader (top 4, 20, 20, 20);
  - rootSectionHeaderPadding 20;
  - headerToContentSpacing 10, which matches the 10 heading-to-card gap. Size variant 2 uses 10 / 6.
- Confirmed: `GroupedFormRowLayout` (Cache.updateDimensions 0x19b74d394, place 0x19b74b6b0) uses 10 and 16 as
  horizontal spacings between label, value and accessories. No vertical constant was found there.
- Confirmed: a layout trait `ReducedGroupedFormRowBottomPadding` exists. Its writer is the menu-button / pop-up
  path (`MacUnbridgedMenuButtons ... DesignLibraryButton`, 0x19a8d73e4). So pop-up rows can get a smaller bottom
  padding. Its value was not read: the default getter 0x19a60f728 is a shared thunk.
- Not found: a rule that makes the first row of each card 1 pt shorter. Nothing in FormCell, GroupedSection or
  MacGroupBox treats index 0 specially. Only the last row is special (no divider). Two ways to read GAPS item 5:
  - the row edges were measured at the separator lines, where the divider belongs to the row above on the Mac
    (bottom) and to the row below in hyprk;
  - the difference comes from content height (label baseline alignment in `GroupedFormRowLayout.updateAlignment`
    0x19b74e4a4).
- What to change in hyprk (not changed):
  - `settings/controls/FormRow.qml:30-31` draws the separator at the top of every row with `Positioner.index > 0`.
    The Mac draws it at the bottom of every row except the last, inside that row's height.
  - The padding constant `settings/Theme.qml:151` `rowPadding: 10` and `separatorInset: 10` (`:152`) already match.
  - Re-measure item 5 with the separator-at-bottom rule before touching row heights.

## 3. Sidebar search capsule (GAPS item 6)
- Not found. I tried these:
  - AppKit cstrings: `CUISearchFieldTextView`, `NSSearchFieldCell`, nothing glass-specific.
  - DarkAqua.car renditions `SearchFieldTextured_*`, `SearchFieldForm_*`, `SearchField_Frame_*`. All of them are
    InternalLinks into `ZZZZPackedAsset` images, which my parser does not unpack (not exported in `DarkAqua-tl`).
  - DesignLibrary strings: no search-field colour.
  The Settings sidebar search is SwiftUI `.searchable` in a sidebar. That path was not traced.
- Inferred arithmetic only, so do not apply it. Mac (81,86,105) minus the sidebar (34,38,53) is +47, +48, +52.
  - A white source-over fill (ours, 21 %) would give +46, +46, +42: the blue drops.
  - A near-constant offset fits an additive blend better (plus-lighter with white about 0.19 gives (82,86,101)).
  - So would a fill that sits inside the glass content and gets the glass colour matrix and chameleon after it.
  Neither is confirmed.

## 4. Finder inactive toolbar title (GAPS item 8)
- Confirmed (Aqua.car and DarkAqua.car, element 216 part 179 "Toolbar State Transform Text", effect presets):
  - active: Fade 1.0, SOpc 1.0;
  - inactive (presentation state 1): Fade 0.5, Colr (RGB 0,0,0, opacity 1.0, blend `'sat '`), SOpc 1.0;
  - the same in light and dark. So CoreUI's inactive toolbar text is desaturated, then drawn at 50 % opacity.
  - Other states: state 4 is Fade 0.4. State 2 is Colr black at 0.15 with blend 0x1a, which looks like
    kCGBlendModePlusDarker (pressed). The blend numbering is inferred.
- Confirmed: "Titlebar Raised Text" (element 82):
  - light: active Colr black 0.65, inactive black 0.28;
  - dark: Colr white at 0.55 active, 0.25 inactive;
  - each also has Fade and SOpc.
  This is a raised (emboss) text effect. That it is the title fill is not established.
- Not found: which of these the 27 toolbar title uses. The `NSToolbar` / titlebar title code was not traced.
  Neither preset reproduces both readings:
  - 50 % of the active ink gives light 255 - 179 x 0.5 = 166 (Q-finder-06 says 191, Settings 189) and dark 132
    (Mac 92);
  - "Raised" 0.28 / 0.25 gives light 184, dark 86, close to Q-finder-06 / Q-settings-06 but not exact.
- Inferred, about the two readings: a 50 % fade blends the title with whatever is under the toolbar. The toolbar is
  see-through when content is under it. So a reading over blurred content (130) and over plain white (189..191) can
  both come from one rule. No vibrancy blend (`plusD` / `plusL`) appears in the inactive preset, only a
  saturation colour and a fade. This stays inferred until the title's draw path is found.
- hyprk: `finder/qml/Theme.qml:169` `title: ... (theme.active ? "#4C4C4C" : "#BFBDBD")` (dark `#5F5F64`) and
  `settings/Theme.qml:173` `toolbarTitle` (#BDBDBD / #5C5D5E). These are flat colours. Leave them until the rule
  is settled. If the 50 % rule is confirmed, the inactive title becomes the active ink at opacity 0.5 over the
  toolbar backdrop, not a fixed grey.

## 5. Sidebar over other wallpapers (GAPS item 7)
- The layer stack is fully given by MAC-ANSWERS "Verify C3":
  - `CABackdropLayer` + `glassBackground`;
  - `CAChameleonLayer` with colorBlendMode at 0.10 dark / 0.05 light, colour = 6-bit mean of the wallpaper under
    the window frame;
  - SDF portal;
  - highlight.
- What is missing:
  - the DesignLibrary / SwiftUI site that sets 0.10 / 0.05 (C3 "Not covered");
  - a check of the mean colour over more than one wallpaper.
  Neither changes the model.
- hyprk side: `settings/Theme.qml:120-126` uses the measured TahoeDark colour as it is in dark (no chameleon) and
  only the light 5 % blend. The C3 model wants the glass output + 10 % colour blend in dark too. Over a plain
  desktop, C3 predicts about (37,38,38) dark, which matches `settings-toolbar-dark.png`.
- For the inactive sidebar, Mica `Sidebar.caar` Inactive (element 173) is: dark fill 0.1569 = (40,40,40) opaque +
  chameleon 0.10; light fill 0.9412 = (240,240,240), no chameleon.
  - Observed: inactive dark (37.5, 39.5, 44.5). Q-settings-01 inactive: #F2F2F2 / #24262B.
  - Light 240 vs 242 and dark 40-lum vs about 39 are close but not exact.
  - Inferred: the inactive sidebar is this flat material plus chameleon. Not confirmed that AppKit 27 uses Mica for
    it.

## Not found
- Inactive dark content tint (29.5, 30.5, 32.5) vs active (30.5, 31.5, 36.5). The material is the same in both
  states. Tried: Mica archives, `resolved_chameleon_color`.
- Inactive toolbar strip colour. Tried: Mica Titlebar materials (do not fit light), AppKit pocket strings and the
  ThinFilm builder (filters only).
- The 1 pt first-row difference. Tried: FormCell, GroupedSection, MacGroupBox, GroupedFormMetrics,
  GroupedFormRowLayout.
- Sidebar search field fill and blend. Tried: AppKit strings, CoreUI SearchField renditions (packed, not decoded),
  DesignLibrary strings.
- Which CoreUI text effect or AppKit rule the 27 toolbar title uses when inactive.
- `ControlBorderShapeStyle` colour and the `groupBoxCornerRadius` default.
