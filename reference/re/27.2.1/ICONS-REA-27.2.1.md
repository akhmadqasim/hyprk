# Icons: menu row glyphs and document icons, macOS 27.2.1 (26B131)

2026-11-14. Sources: the 27.2.1 system volume (`141-12228-174.dmg`, apfs-fuse read-only at
`~/Downloads/macos/re-work/icons2/mnt`, unmounted after) and the dyld cache (`~/Downloads/macos/dyld-27.2.1`).
Code read with `ipsw dyld disass --cache <DSC>.a2s` (whole IconServices `__text` in `re-work/icons2/is-all.dis`),
objc stub selectors, constants and CFStrings resolved by reading the cache (`ipsw dyld dump`), scripts in the agent's
scratch dir (`ann.py`, `xref.py`, `fn.py`; not kept in the repo). Assets read with `themes/icons/tools/car.py` /
`dmp2.py`. REA's Ghidra provider was not needed: every function below is short enough to read as disassembly.
Observed = read in the binary or the file; MEASURED = on the Mac's own renders in `live/finder/icons-rendered`;
GUESS = neither.

Files hashed (sha256):
- `IconFoundation.framework/Versions/A/Resources/Assets.car` 881a6e99c6227a54f5f4cfa56085294073c648b03e4b6812a0b9ba410888cddb
- `CoreServices/CoreTypes.bundle/Contents/Resources/Assets.car` 26bc65c73a7853c7c5aa14259a049bc5284388fba60381d71d7792551de9f855
- `CoreServices/CoreTypes.bundle/Contents/Info.plist` cb64e52f21072ac5e12b14e4a26adfc11c7a57ab6dd5d1611d34f66220f3a62f
- `CoreServices/CoreGlyphs.bundle/Contents/Resources/Assets.car` 933b39bddcd99874b2727cc339be0c2e7d188855352836236d7fc41daca48a76

## Part 1: menu row glyphs

The image names were already decoded (MENUS-REA-27.2.1.md "Edit menu icons" and its Apple / Help rows); what was
missing was the glyphs. Decoded from CoreGlyphs' BVG data with `themes/icons/tools/add-sf.py` (regular, medium,
semibold; the AppKit 32 pt canvas), registered in `themes/icons/sf-symbols/names.json` (surface shell), `sf.js`
regenerated (`tools/gen-sf.mjs`): 9 SVGs, 19 KB.

| row | menu | image (source) | state |
|---|---|---|---|
| AutoFill ▸ | Edit (AppKit append) | `rectangle.and.pencil.and.ellipsis`, private symbol, `+[NSMenuItem _standardAutoFillMenuItem]` 0x18aa1103c | added |
| Start Dictation | Edit (AppKit append) | `microphone`, AppKit action table next to `startDictation:` | added |
| Emoji & Symbols | Edit (AppKit append) | `emoji.face.grinning` | was there |
| About This Mac | Apple menu | `laptopcomputer` (Mac14,2) | the glyph was already in the set (Settings); now drawn |
| Mac User Guide | System Settings' Help | `Image(systemName: "book.pages")` 0x1000676a8 | added |

Sweep of MENUS-REA for other rows "not in our symbol set": these three were all. The undo / redo / cut / copy / paste
symbols of AppKit's table are not drawn by Finder's Edit menu on the Mac (Q-menubar-17), so they stay off.
Checked on screen (headless session, scale 2, dark and light): Finder's Edit menu shows the three icons at the icon
column; AutoFill and Start Dictation disabled (no action behind them), Emoji & Symbols enabled.

## Part 2: document icons

### How 27.2.1 makes a document icon

No per-type picture exists. CoreTypes' `.icns` files cover special items (clippings, VCard, KEXT ...);
`GenericDocumentIcon.icns` still holds the older page. Types declare in CoreTypes' Info.plist (`UTTypeIcons`):
`ISDocumentIconConfiguration { ISSymbolName }` (375 types), `UTTypeIconBackgroundName` (a page fill in CoreTypes'
Assets.car: `txt-fill` for public.text, `rtf-fill`, `ArchiveBackground` for zip with `ISSymbolTreatment`),
`UTTypeIconText`, `UTTypeIconBadgeName`. IconServices composes at run time:

- `+[ISRecipeInfo documentRecipeForPlatform:descriptor:]` 0x197596638: `ISDocumentRecipe` alloc-init, `setPlatform:`.
- `-[ISDocumentRecipe layerTreeForSize:scale:]` 0x1975ef824 (s = icon size in points):
  - "root layer" (s) <- "background layer" (s), content `pageResource` 0x1975ef6d4 = IconFoundation Assets.car
    `document/solarium/page` (`document/solarium_ios/page` on iOS platforms); with `hasBespokeBackground` a
    "suppliedBackground layer" (s, content kISBackgroundResourceKey) with `ISMaskEffect` (`ISSymbolEffect` when
    `treatLikeSymbol`) is its sublayer; the background layer's effect is `ISDropShaddowEffect` with scale 1,
    spread 1, offset (0, -0.5 x s/32), blur 2 x s/32, colour white 0 alpha 0.5 (`initWithWhite:alpha:`).
  - a container layer, frame = `hintedPaperRect`; in it the "badge layer" at `hintedBadgeRect`: an `ISSymbolLayer`
    (symbol = kISBadgeResourceKey, fontSize = `hintedSymbolFontSize`) when `badgeWithSymbol`, else an image
    (coordinateSystem 1) masked by a continuous rounded rect when `maskBadgeResource`; then, only when s > 32
    (`fcmp d9, 32; b.le`), the "text layer" (`ISTextLayer`, frame `hintedTextRect`, text kISTextResourceKey,
    fontSize `hintedTextFontSize`).
  - "page fold layer" (s), content `curlResource` 0x1975ef77c = `document/solarium/page-fold`.
- Hinted tables (blocks of `-[ISDocumentRecipe hinted*]`); the branch with `platform & 0x3c == 0` is the macOS one
  (the other has 51 / 56 / 98 / 148 / 373 / 1120 pt keys and the `solarium_ios` art). Points, x / y from the bottom
  left of the paper rect (badge, text) or of the icon (paper):

  | table | 16 | 32 | 128 | 256 | 512 |
  |---|---|---|---|---|---|
  | paper | 3,1,10,14 | 5,2,22,28 | 23,9,82,110 | 46,18,166,220 | 92,37,327,438 |
  | badge, symbol | 2,4,6,6 | 4,7,14,14 | 21,35,40,40 | 42,70,80,80 | 80,135,168,168 |
  | badge, image | 2,4,6,6 | 3,6,16,16 | 16,30,50,50 | 33,61,98,98 | 60,115,208,208 |
  | symbol font, with text | 5.25 | 10.25 | 37.5 | 75 | 150 |
  | symbol font, no text | 5.25 | 10.25 | 41.25 | 82.5 | 165 |
  | text rect | | 1,1,20,1 | 9,8,64,17 | 16,17,132,33 | 33,31,261,60 |
  | text font | | | 16.5 | 33 | 60 |

  The 128 px Mac render (64 pt) has its page at 82 x 110 +23 +9 and the 256 px page art at 164 x 220 +46 +18: the
  paper rect is the page body.
- `-[ISHintedRect hintedRectForSize:options:]` 0x1975f9fd4, `-[ISHintedFloat hintedFloatForSize:options:]`
  0x1975fa42c, `-[ISHintedValue indexForSize:]` 0x1975f9914 / `interpolationFactorForSize:` 0x1975f9d88 /
  `scaleFactorForSize:` 0x1975f9cb8: the first key >= s, linear from the key before; outside the table the edge
  value times s / key; options 5 (from `initWithOptions:5`): rects rounded to 0.5, floats not rounded.
- Symbol: `-[ISSymbolLayer init]` 0x1975b7ee0: colour CUIDesignLibrary colour 17 (when Solarium is on), symbol size
  2 (medium), weight 4 (regular); the recipe sets neither. Drawn centred like the folder emboss
  (`-[IFGraphicsContext drawSymbolImage:centeredInRect:]` 0x19753d494, see reference/ASSETS.md).
- Text: `-[ISTextLayer init]` 0x1975b7d38: the same colour 17. `-[IFGraphicsContext drawText:fontName:fontSize:
  inRect:]` 0x19753d5d0: `CTFontCreateUIFontForLanguage(2 = kCTFontUIFontSystem, size)`, the line's typographic
  width w; scale = 1 when w + 6 <= rect width, else (width - 6) / w; x = rect.x + (width - floor(w x scale)) / 2;
  y = ceil(rect.y - the line's image-bounds y): the glyphs' bottom on the rect's bottom.
- The text itself: `-[ISRecordResourceProvider _findTextResourceWithIconDictionary:]` 0x1975cd138: `UTTypeIconText`
  (or `CFBundleIconText`) uppercased; when absent or `*`, the file's own `fileExtension`, uppercased; none for
  folders. So every document with an extension carries its extension (also public.text: the 77 pt `doc-txt` render
  shows a faint "TXT" over the lines).
- MEASURED: symbol and text ink 182 grey on the 245 page (`doc-pdf`, `doc-png`), light and dark renders identical
  files: the colour scheme is fixed. Colour 17's value in CoreUI's design library was not read.

### What was built

`themes/icons/tools/build-docs.py <os root>` composes the page (`document/solarium/page/image_128` 256 px, deepmap2,
Gray Gamma 2.2), the drop shadow, the symbol (CoreGlyphs through `bvg.py`, regular, the AppKit canvas scaled to the
hinted font, rasterised by rsvg-convert) or the `txt-fill` background (masked by the page), and the fold, at
16 / 18 / 32 / 48 / 64 / 77 pt x 2. The text is NOT baked in (it is per file): Finder (`finder/qml/lib/files.js`
`macDocKind`, `docText`, `docTextFor`; `FileIcon.qml`) and the Dock stack (`shell/modules/StackArt.qml`) draw the
extension with the decoded geometry. Kinds (CoreTypes Info.plist, the type or the first type it conforms to that has
icons):

| kind | ISSymbolName / background | types |
|---|---|---|
| justify | character.text.justify | docx (org.openxmlformats.wordprocessingml.document) |
| table | tablecells | xlsx, csv |
| chart | chart.pie | pptx |
| code | chevron.left.forwardslash.chevron.right | html, htm (public.html) |
| audio | waveform | public.audio |
| video | video | public.movie |
| image | photo | public.image (an image without a thumbnail) |
| txtfill | txt-fill background | public.text: json, md, css, js, py, sh, yaml, ics, sources, log ... |
| txt, zip, pdf | the Mac's own renders (text included) | .txt, .zip, .pdf |

New files: `finder/qml/icons/doc-<kind>@<pt>pt.png` (8 kinds x 6 sizes, plus the 6 `doc-pdf` Mac renders copied
from `live/finder/icons-rendered`, sha-identical) and `themes/icons/system/<Kind>Document-154.png` (8, the 77 pt
2x art for the Dock stack): 62 files, 197 KB. 154 px art sha256 prefixes: Justify 469a4145cfa97dc7, Table
65a6109febc614dd, Chart 9d36eeb6a1178199, Code d7af086cf94a88b7, Audio 277704974139cf06, Video e642f73f3eb49c1b,
Image 6eca3233982aabe7, Txtfill c104a7469c9e23ce.

Check against the Mac's renders (`build-docs.py --compare`, the same composition with the text drawn by PIL from
SFNS.ttf, over white, rms in 8-bit levels at 16 / 18 / 32 / 48 / 64 / 77 pt): pdf 10.2 11.1 9.3 7.0 7.9 6.1, png
10.8 13.4 7.9 8.4 9.0 7.6, txt 15.2 10.1 11.8 11.9 15.3 6.6. Page outline identical (bbox 100 x 132 +27 +11 at
77 pt), the symbol's centre within 1 px at every size, the text's ink 1 px lower than the Mac's (the baseline is
not lifted by the glyphs' overshoot in the comparison renderer). The rest is the drop shadow.

GUESS / not read:
- The shadow's blur kernel: taken as a Gaussian with sigma = blur / 4 (fitted: sigma = blur / 2 gave rms 9-10 at
  77 pt, blur / 4 gives 6-7); alpha 0.5 and the offset as decoded.
- The page rendition per size: the 256 px one for every size (the 16 / 32 pt renditions sit in packed atlases
  car.py cannot read); the 16 / 18 pt rms is the highest because of it.
- Linux has MIME types, not UTIs: the extension picks the Mac's type where one is declared (docx, xlsx, csv, pptx,
  html), else the MIME top level (audio/, video/, image/, text/ and the text-like ones `Files.isText` knows); the Dock
  stack has no MIME type and uses an extension list (`Dock.qml docArt`). A type the Mac knows under another UTI
  (e.g. its own .md / .json declarations in other bundles) could differ.
- `hasText` false (a file without an extension) takes the bigger no-text symbol on the Mac; ours keeps the with-text
  art (1-2 px).
- The text in Qt: SF Pro through HyprK Typography, baseline at the rect's bottom (uppercase without descenders sits
  there), not CoreText's image-bounds placement.

Not done:
- The generic page (public.data: GenericDocumentIcon.icns plus `_ISIconRecipe ISmacosDocumentRecipe1016` in the
  plist, but `documentRecipeForPlatform:` always makes an ISDocumentRecipe): which art 27.2.1 shows for an unknown
  type was not settled and no Mac render of it exists, so unknown files keep the older page with the drawn badge.
- `rtf-fill` (public.rtf) and `ArchiveBackground` (zip, `ISSymbolEffect`): rtf files have no art yet; zip keeps the
  Mac's render. Image badges (`UTTypeIconBadgeName`, app-supplied document icons, an app's icon on its documents)
  are not built: on Linux no app declares them.
- Keynote / Pages / Numbers (`apple.keynote` ...), vcf (`person.crop.circle`, with VCard.icns as well): not mapped.
