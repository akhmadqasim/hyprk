# Appearance > Liquid Glass preview: the "Welcome to Apple Park" article, macOS 27.2.1 (26B131)

2026-11-14. User report: the Mac's preview article is "very long downwards", ours must match. Sources and method:

- System volume `141-12228-174.dmg` (IPSW `UniversalMac_27.2.1_26B131_Restore.ipsw`), read with apfs-fuse read-only
  (`/mnt/code/apfs-fuse/build/apfs-fuse -o ro`, unmounted after). Resources copied from
  `/System/Library/PrivateFrameworks/AppearancePreferencesFramework.framework/Versions/A/Resources/`.
- The binary is in the dyld cache (`~/Downloads/macos/dyld-27.2.1/dyld_shared_cache_arm64e`, image
  `AppearancePreferencesFramework`, `__TEXT` 0x2612C5000-0x2613C7E0C, sub-cache `.52` file offset 0xec5000).
  `ipsw dyld extract` fails on it (stub remap error), so: `ipsw swift-dump` for the Swift types, `ipsw dyld disass
  --cache <dsc>.a2s -i AppearancePreferencesFramework --demangle` for the code (42.8k lines, functions unnamed),
  `strings` on the dumped `__TEXT`. Every function below is short enough to read as disassembly; REA's Ghidra
  provider was not needed (no MCP Ghidra this session).
- Assets: `themes/icons/tools/car.py` (BOM/CSI), `dmp2.py` (deepmap2), heif-convert. Mac data: R3.7
  (`MAC-ANSWERS-3.md`, `screens/27.2.1/settings/appearance/preview-article-scroll-{00..11}-{light,dark}.png`,
  `live/settings/appearance/ax-preview-article-{top,end}-{light,dark}.jsonl`).

OBSERVED = read in the binary, the resources or the Mac data. MEASURED = fitted on the Mac stills. Nothing below is
guessed; open points are listed at the end.

## Answer to the report

The Mac article is 268 x 1257.5 pt (AXContentSize, R3.7) in the 268 x 180 scroll view: it scrolls 1077.5 pt. Ours was
268 x 1265.5 (8 pt too long at the end), so ours was already long; now 1257.5. The article has the same 13 elements
as ours and no more (AX dumps; the code below). What did differ:

- the end spacing (16 + 8, not 16 + 8 + 8),
- the appear sequence (fade-in, then the article slides up 52 pt and back), missing in ours,
- a wheel at the article's end scrolled the whole Settings pane in ours; the Mac never passes it on,
- the hero's crop (13.5 pt, not 13.33) and the photo files (now the Mac's 2x size from the catalog).

## Chain: file -> view -> article

1. `Localizable.loctable` (binary plist, 44 locales): the article's strings, keys = English text (OBSERVED, table "en"):
   "Welcome to Apple Park", "Cupertino, California", "Learn about the design and history of Apple Park, and discover
   its unique nature and beauty.", "The Architecture", "Apple Park was made for walking and exploring. The innovative
   design elements emphasize openness and connection to nature.", "The Pond", "With gently lapping waves and a
   surrounding of trees, it's one of the most serene spots on campus." (U+2019), "The Rainbow", "One of the most iconic
   features of Apple Park, the Rainbow brings much joy to all who experience it.", "Apple Park" (hero label), "Search".
   `en_GB` / `en_AU` have "emphasise": the R3.7 Mac runs English (UK). hyprk's UI is US English ("Color", "Text
   highlight color"), so ours keeps the "en" text.
   Also in the table but with no C string in the framework's `__TEXT` (so not used by this view's code): "Auto-scroll",
   "Overlay Bar", "Glass Preview Layout", "Tuning", "Reset All Constants", "Export to /tmp/constants.txt".
2. `Assets.car` (OBSERVED, car.py): 4 renditions, all scale 1x (CSI scale 100):
   `apple-park.heic` 1620x1080, `architecture.heic` 1616x1080, `pond.heic` 1620x1080 (RAWD, HEIF, Display P3 ICC),
   `rainbow.png` 1614x1803 (CELM compression 11 = deepmap2, colour space id 1, a transparent 1-3 px rim and baked
   round corners). Colour check against `preview-article-scroll-10-light.png` (converted to sRGB): the rainbow read as
   sRGB differs by 1.5 levels (mean abs), read as P3 by 6.3, so id 1 = sRGB (MEASURED).
3. Swift types (`ipsw swift-dump`, OBSERVED): `struct GlassStylePreviewView { style: AppearancePickerStyle;
   _reduceMotion: Environment<Bool>; __photoOpacity: LazyState<Double>; _demoScrollOffset: State<CGFloat>;
   _OREnabled, _scrollDemoFinished, _ORLocked: State<Bool>; _ORCharCount: State<Int>; _ORBounceTrigger: State<Bool>;
   _OROpacity: State<Double>; _lastBottomDistance: State<CGFloat>; _scrollLocked: State<Bool>;
   _currentScrollPhase: State<ScrollPhase>; _pendingORScrollToBottom: State<Bool>; _ORLastRevealDistance:
   State<CGFloat>; _ORLastRevealTime: State<Date?>; _ORRevealScheduled: State<Bool> }`. The field-offset vector of the
   metadata (`sub_2612deebc`) is read at +0x10 + 4 i, so +0x18 photoOpacity, +0x1c demoScrollOffset, +0x24
   scrollDemoFinished, +0x28 ORLocked, +0x34 OROpacity. `style` == 0 is the Settings style (268-wide preview), 1 the
   Setup Assistant style (450 wide).
4. `body` (`sub_2612df7b8`, OBSERVED):
   - hero height = style 0 ? 152 : 263 (0x2612dfc30-0x2612dfc4c, doubles 0x4063000000000000 / 0x4070700000000000);
   - ZStack { ScrollViewReader { ScrollView ... }, toolbar capsules } `.clipShape(RoundedRectangle(16))` (0x2612dfd4c)
     `.opacity(photoOpacity)` (0x2612dfdcc) `._scrollInputForwardingBehavior(.never, axes: .vertical)` (0x2612dfe24)
     `.animation(.spring(response: 0.7, dampingFraction: 0.65), value: photoOpacity)` (0x2612dfe64-0x2612dfe84)
     `.task(priority: .userInitiated)` ("View.task @ .../GlassStylePreviewView.swift:" line 79, 0x2612dffa4,
     `_TaskModifier2` 0x2612e0050).
5. Appear sequence (`sub_2612e026c`, called at 0x2612e8490, OBSERVED):
   - only when photoOpacity == 0 (0x2612e04f4);
   - Reduce Motion (`sub_2612e90a4`): photoOpacity = 1, scrollDemoFinished = true, nothing else (0x2612e050c-0x2612e0550);
   - else `DispatchQueue.main.asyncAfter`: now + 0.08 (0x3fb47ae147ae147b, 0x2612e0588) -> `sub_2612e5d40`:
     photoOpacity = 1.0; now + 1.3 (0x3ff4cccccccccccd, 0x2612e0824) -> `sub_2612e5da0`: if !scrollDemoFinished,
     demoScrollOffset = style 0 ? -52 : -93 (0xc04a000000000000 / 0xc057400000000000); now + 1.3 + 2.2 = 3.5
     (0x400199999999999a, 0x2612e0a00) -> `sub_2612e5e68`: if !scrollDemoFinished, demoScrollOffset = 0,
     scrollDemoFinished = true. User scrolling does not cancel it (the scroll-phase handler `sub_2612e4de4` writes
     only scrollLocked / pendingORScrollToBottom).
6. Scroll view (`sub_2612e1534`, OBSERVED): `ScrollView(.vertical, showsIndicators: true)` (0x2612e1b40)
   `.contentMargins(.top, 52, for: .scrollIndicators)` (0x2612e1b90) `.contentMargins(.bottom, 16, for:
   .scrollIndicators)` (0x2612e1c30) `.scrollEdgeEffectStyle(.soft, for: .top)` (0x2612e1c94-0x2612e1d14)
   `.ignoresSafeArea(.container, edges: .top)` (0x2612e1d50) `.scrollDisabled(scrollLocked)` (0x2612e1de4)
   `.onScrollGeometryChange` (0x2612e1f20; transform `sub_2612e4d10`: contentSize, visibleRect height, contentInsets,
   contentOffset: the distance to the bottom) `.onScrollPhaseChange` (0x2612e2088) `.onChange(initial:)` (0x2612e21e8).
7. Content (`sub_2612e98f0` -> `sub_2612e2238`, OBSERVED): `VStack(alignment: .leading) { article }`
   `.frame(width: style 0 ? 268 : 450)` `.frame(width: same, alignment: .leading)` `.offset(y: demoScrollOffset)`
   `.animation(.spring(response: 2.0, dampingFraction: 0.82), value: demoScrollOffset)` (0x2612e2408-0x2612e2438;
   0.82 = 0x3fea3d70a3d70a3d).
8. Article (`sub_2612e24b4`, OBSERVED), a VStack with default spacing:
   - hero: `Image("apple-park", bundle:)` (0x2612e2734) `.resizable()` `.aspectRatio(nil, contentMode: .fill)`
     (0x2612e27f8: 0x101) `.frame(width: 268, height: 152, alignment: .center)` (0x2612e27ec)
     `.frame(width: 268, alignment: .trailing)` (0x2612e2870) `.clipShape(Rectangle())`
     `.accessibilityLabel("Apple Park")` (0x2612e29ec) `.padding(.bottom, style 0 ? -8 : 4)` (0x2612e2aa0-0x2612e2ab8);
   - text: `VStack(alignment: .leading) { ... }` (0x2612e2ad8, `sub_2612e3d04`) `.padding(.all, 16)` (0x2612e2b18);
   - end: `Spacer().frame(height: ORLocked ? 32 : 8)` (0x2612e2b94-0x2612e2be0);
   - only if ORLocked and a static NSImage exists: `Image(nsImage:).resizable().aspectRatio(.fill)
     .frame(268, 180)` (style 1: 450 x 303) with `.opacity(OROpacity)` (0x2612e2c24-0x2612e2e40).
9. Text stack (`sub_2612e3d04`, OBSERVED): title (0x2612e3e98) `.font` `.fontWeight` `.padding(.bottom, -4)`
   (0x2612e4030); subtitle `.font` `.foregroundStyle(.secondary)` (0x2612e41c0) `.padding(.bottom, 4)` (0x2612e4224);
   description `.foregroundStyle(.primary)` (0x2612e4338); three sections `sub_2612e5f34("architecture" | "pond" |
   "rainbow", title, text)` (0x2612e4520, 0x2612e46c4, 0x2612e4844).
10. Section (`sub_2612e5f34`, OBSERVED): `Image(name, bundle:).resizable()` + aspect ratio
    `.clipShape(RoundedRectangle(cornerSize: 16 x 16))` `.padding(.vertical, 16)` `.accessibilityLabel(title)`;
    title `.font` `.fontWeight`; text `.font` `.foregroundStyle(.primary)`.
    The font statics (`swift_once` tokens) were not decoded this time; the earlier decode (title3 15 pt, body 13 pt)
    stands, and the title's ink on the Mac still is 33..361 px wide, ours 34..360 (MEASURED).

## The numbers this gives, against the Mac (R3.7 AX, content y in pt)

| element | code | Mac AX (end dump + 1077.5) | ours |
|---|---|---|---|
| hero image frame | fill 268 x 178.5 centred in 152, clipped | -13.5, 268 x 178.5 | -13.5, 268 x 178.5, clipped to 152 |
| title | 152 - 8 + 8 + 16 | 167.9 | 168 |
| subtitle | + 19 - 4 + 8 | 190.9 | 191 |
| description | + 19 + 4 + 8 | 221.9 (48 tall) | 222 |
| architecture photo | + 48 + 8 + 16 | 294.0 | 294 |
| heading / text | + 157.5 + 16 + 8 / + 19 + 8 | 475.6 / 502.6 | 475.5 / 502.5 |
| pond photo, heading | | 590.5, 772.0 | 590.5, 772 |
| rainbow photo, heading, text end | | 871.0, 1158.6, 1233.6 | 871, 1158.5, 1233.5 |
| content height | text end + 16 + 8 (Spacer, 0 spacing) | 1257.5 | 1257.5 (was 1265.5) |
| scroll range | | 0 .. 1077.5 | 0 .. 1077.5 |

Pixel check (MEASURED): our scroll captures matched against a strip built from the 12 Mac stills land on whole
offsets (0, 75, 150.5, ... 1050.5) with 5.8-10.7 levels mean abs difference (text anti-aliasing and photo
resampling); our end state matches still 11 at 1077.0 (one 2x pixel from 1077.5), light and dark. The hero's top
fitted on still 00 is -27.2 px = -13.6 pt.

## The OR feature (found, not shown on the Mac, not built)

`ORRevealField { displayed: String; bounceTrigger: Bool; cursorVisible: Bool }`, `ORCursor` (blinking),
`ORLetter.AnimationState`: the Search capsule can type out a string letter by letter when the article is pulled
past its end (lastBottomDistance, ORLastRevealDistance, pendingORScrollToBottom -> `ScrollViewProxy.scrollTo` at
0x2612ea4d4); when ORLocked the article ends with a 32 pt spacer and an extra 268 x 180 picture. Next to it in
`__cstring`: "no AKURLBag instance available", "bag fetch failed: ", "bag value missing or not a Bool",
"bag resolved to " and one 853,872-character encoded blob; the framework links AuthKit. So it is most likely switched
by an Apple server bag value (which key: not traced; the blob: not decoded). The Mac shows none of it (13 AX elements,
content 1257.5 at the end), so it is left out ("Mac items only").

## What ours does now (settings/panes/Appearance.qml, article part)

- content height 1257.5; hero 268 x 178.5 at -13.5 clipped to 152; photos at the Mac's 2x size
  (`settings/assets/glass-preview`: apple-park.jpg 536x357, architecture.jpg / pond.jpg 472x315, rainbow.png
  472x527 with its alpha rim; see `reference/ASSETS.md`);
- appear: the preview fades in from 0 (Spring 0.7 / 0.65, from 0.08 s), the article slides to -52 at 1.3 s and back
  at 3.5 s (Spring 2.0 / 0.82, a Translate: no change to the scroll position or range); Reduce Motion: none of it;
- a wheel the article cannot use stops in the preview (was: scrolled the pane at the article's end; checked in the
  headless session: 5 notches at the end, the pane did not move).

## Open

- R3.7's top dump has the hero at -15.03 and the photos 0.1-0.5 pt off their end-dump positions while the text
  matches to 0.001; still 00 shows the hero at -13.6. Not explained (not a visible difference).
- The Mac's wheel step per notch was not measured (R3.7 used 100 pt programmatic steps); ours is Qt's 72 pt.
- Ours can be dragged with the mouse (Qt Flickable) and a drag at the article's end moves the pane; the Mac does not
  drag-scroll. Not changed here (Flickable behaviour shared by every hyprk scroll view).
