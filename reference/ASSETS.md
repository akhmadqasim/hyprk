# macOS 27.2 assets (local use)

Source: `~/Downloads/macos/UniversalMac_27.2_26B123_Restore.ipsw`, for the user's own local theming.
Volumes read read-only through apfs-fuse (all unmounted after use):
- Main system volume `141-12228-170.dmg` (decrypted by another agent, already in `~/Downloads/macos/work/`). Called `OS` below.
- AppOS cryptex `141-12233-175.dmg` (not encrypted, extracted from the IPSW). Holds Safari. Called `AppOS` below.
- SystemOS cryptex `141-12293-172.dmg` was mounted and checked: no fonts, sounds, apps or icons worth copying (only frameworks and dyld).
- `/Library` on the OS volume is empty, so there is no `/Library/Fonts` and no `/Library/Desktop Pictures`.

apt installs (logged in `/mnt/code/hypr-dev/APT-INSTALLED.txt`): ffmpeg, icnsutils, libheif-plugin-libde265, libheif-examples, python3-fonttools, python3-pil, liblzfse1, lzfse.

## sounds/ (see `sounds/INDEX.md` for the full per-file event table)

- `sounds/originals/` Apple files unchanged (288 files). `sounds/wav/` all converted to WAV (285, 3 name collisions, see INDEX). `sounds/oga/` Vorbis for 144 non-telephony, non-VoiceOver files.
- `Sounds/` from OS `/System/Library/Sounds` (14 alert sounds).
- `SystemSounds/` from OS `/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds` (system, finder, dock, ink, siri, facetime, telephony, accessibility).
- `AlertTones/` from ToneLibrary.framework (Classic, Modern, EncoreInfinitum, Messages tones).
- `VoiceOverSounds/` from ScreenReader.framework, `Telephony/` from TelephonyUtilities.framework.
- `misc/` single files: volume key sound (BezelServices `volume.aiff`), power chime, Mail sounds, Messages sent, lock/unlock, AirDrop invite, Find My, Photo Booth, and others. Original path is in the file name prefix (app or framework).
- Not found as files: boot chime (firmware), a dedicated "notification banner" sound (notifications use the Alert sounds), screenshot sound is `SystemSounds/system/Screen Capture.aif`.

## themes/fonts/

From OS `/System/Library/Fonts` (copied unchanged to `themes/fonts/`):
- `SFNS.ttf` + `SFNSItalic.ttf` = SF Pro. It is one variable font (axes wght, wdth, opsz 17-96, GRAD). SF Pro Text and SF Pro Display are not separate files: they are the `opsz` axis (small = Text, large = Display).
- `SFNSRounded.ttf` = SF Pro Rounded, `SFNSMono.ttf` + `SFNSMonoItalic.ttf` = SF Mono.
- `SFCompact.ttf`, `SFCompactItalic.ttf`, `SFCompactRounded.ttf` = SF Compact.
- `NewYork.ttf`, `NewYorkItalic.ttf` = New York.
- Also copied: SFCamera, SFArabic*, SFArmenian*, SFGeorgian*, SFHebrew*, SFIndia (script-specific SF fonts).
- `themes/fonts/named/` copies with the name table rewritten (family "SF Pro", "SF Mono", "SF Pro Rounded", "SF Compact", "SF Compact Rounded", "New York") because the originals are named "System Font" / ".SF NS", which fontconfig and apps hide. File names: `SF-Pro.ttf`, `SF-Mono.ttf`, etc. Glyph data unchanged.
- `themes/fonts/named/AppleColorEmoji.ttf` (82.1 MB, sha256 `c3c590a164f5318e28b2ebb48b2584e30eb5165bf7c0b5b3a117a6e8883d9fa8`) = Apple Color Emoji, rebuilt as CBDT/CBLC (the Noto Color Emoji format). NOT from the IPSW: made from the user's Mac copy (macOS 27.2.1, `Apple Color Emoji.ttc`, 192,120,460 bytes, sha256 `12bc8221a908c5bcf05f0fce940d3c3f6e9d09d8d806ffe31a969b4ac9be8f9e`), which is kept outside git at `/mnt/code/hyprk-assets/fonts/Apple Color Emoji.ttc` (sbix + AAT `morx`, over the GitHub 100 MB limit, no LFS).
  Rebuild: `python3 -I themes/fonts/tools/build-apple-color-emoji.py "/mnt/code/hyprk-assets/fonts/Apple Color Emoji.ttc" emoji-test.txt` with Unicode's `https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt` (sha256 `1d8a944f...acda`, 5,225 sequences); same inputs give the same bytes. Needs fontTools, Pillow and HarfBuzz via PyGObject (`gir1.2-harfbuzz-0.0`).
  What the script does: strikes 20, 26, 32, 40, 52, 96 ppem with Apple's PNG bytes unchanged (48, 64, 160 dropped for size); ~540 bitmaps Apple left out of some small strikes are downscaled from the next larger strike, and the 108 `flip` glyphs (people facing right) are mirrored, because FreeType draws neither (with the sbix font they were blank). Sequences: HarfBuzz shapes every emoji-test sequence with the original `morx`, the result becomes GSUB `ccmp` (3,618 ligatures, FE0F optional as in Noto; 396 mixed skin tone pairs that Apple draws as two overlapping halves get a placeholder glyph split into the two halves, which the original GDEF/GPOS positions). The script then shapes all 5,225 sequences again on the new font and stops unless glyphs and positions match morx exactly (they do). Only face 0 ("Apple Color Emoji") is kept, with the vertical metrics of the second face ".Apple Color Emoji UI" (773/-169 per 800, the same proportions as SF Pro), so a line with emoji is as tall as an SF Pro line. glyf/loca/sbix/morx/feat/trak/bgcl are dropped.
  Why CBDT: Qt 6.10.2 with FreeType 2.14.2 gets the metrics of the sbix font wrong (13 px "Hello 😀" gave a 342 px line, baseline 260 px down; dropping glyf, hhea or strike changes did not help). With CBDT, Qt Quick (distance field and NativeRendering, DPR 1 and 2) and pango give the same line height and baseline as text without emoji. Qt sizes a colour strike by pixelSize / (CBLC ascender - descender), so each strike's line is ppem + 1 px: exactly ppem would make Qt skip the DPR scaling at pixel sizes equal to a strike (20, 26, 32, 40, 52, 96 px drew half-size emoji at DPR 2). Left over: at exactly 97 px with a DPR other than 1 the emoji are still drawn half size, and in Qt the art is 1-5% under 1 em.
  It lives in `named/` (not the top dir) because `dist/lib/env.sh`, `themes/*/install.sh` and `hypr-env.sh` only scan `named/`; `config/fontconfig/fonts.conf` scans both. `config/fontconfig/emoji.conf` puts it ahead of Noto Color Emoji.
- Not done: static instances (Display/Text/Bold...). Use fontTools `instancer` if an app can't use variable fonts. Fonts are Apple licensed, for local use only.

## themes/wallpapers/

- `heic/` originals, `png/` full-resolution PNG (ImageMagick + libheif). Multi-image HEICs get `-0`, `-1` suffixes (Sonoma).
- macOS 27 default: `TahoeLight.heic` and `TahoeDark.heic` (6016x6016, from OS `/System/Library/ExtensionKit/Extensions/NeptuneOneWallpaper.appex/Contents/Resources/`, `manifest.json` saved as `NeptuneOne-Tahoe-manifest.json`; it points to Apple's remote `tahoe-*-landscape.mov` aerials). Install default: `DefaultAerial.heic/.jpg` (3840x2160) and `Golden Gate.mov` (96 MB) from `/System/Library/Wallpapers/.default/`.
- Also: `Sonoma.heic`, `Sonoma Horizon.heic`, `Radial Sky Blue`, `iMac *` (7 colours), `Mac *` (4 colours) from `/System/Library/Desktop Pictures/`, and the Sonoma dynamic `.mov` set in `dynamic-sonoma/`.
- Not available: all `.madesktop` wallpapers (Big Sur, Monterey, Ventura, Light Stream, ...). They are only small plists, the real images are MobileAsset downloads not in the IPSW. The `.thumbnails` (tiny) were skipped. The Aerials extension only has thumbnails.

## themes/icons/

Re-extracted 2026-11-10 (second pass). Mounts used: OS `141-12228-170.dmg` and AppOS `141-12233-175.dmg`, each
`apfs-fuse -o ro <dmg> /mnt/code/scratch/<dir>` (under /mnt/code, never $HOME), unmounted afterwards.
Tool: `themes/icons/tools/car.py`, a small pure-Python reader for `Assets.car` (BOM store, RENDITIONS tree, CSI blocks;
decodes raw, gzip and lzfse/KCBC bitmaps; needs python3-pil, numpy and liblzfse). It replaces the earlier one-off reader that was not saved.
- `apps/<Name>-1024|512|128.png`: all 72 app icons are now real Apple renditions (0 upscaled). Built by
  `themes/icons/tools/build-apps.py <OS root> [<AppOS root>]` from `apps-sources.txt` (app bundle + icon name in its `Assets.car`);
  `apps-build.log` says which rendition each came from. Rule: pre-rendered 1024 px bitmap if the car has one (15 apps: Books, Clock,
  ControlCenter, FaceTime, FindMy, Home, Journal, Maps, Messages, News, Phone, Podcasts, Stocks, VoiceMemos, Weather), else the
  pre-rendered 512 px (= 256@2x) bitmap. 512 and 128 are Lanczos-downsampled (premultiplied alpha) from that, `-1024` is the source itself.
- The first pass missed the 512 px bitmaps of Mail, Freeform, Dock, Spotlight, Archive Utility and Install Command Line Developer Tools
  (found now, `ApplicationIcon256x256_...`/`AppIcon256x256_...` at 512x512@2x) and the real 1024 px classic icon of ControlCenter
  (`icon_512x512@2x.png` in its car). So only the flat 256 px `.icns` route was upscaled before; that no longer applies to any app.
- Route that did not matter: Liquid Glass layered `.icon` sources (`*.iconstack`, per-layer SVG, gradients, fills in the same car) are not rendered;
  Apple's own pre-rendered bitmaps are used. `apps-hires/` and `hires.log` were removed (their 512 px files equal `apps/*-512.png`).
  `extract.log` is the log of the old `.icns` route: its `apps/` lines are superseded by `apps-build.log`, its `system/` lines still hold.
- No icon at all for: Notification Center, Software Update, Keychain Circle Notification.
- Icon styles (2026-11-11, 27.2.1 IPSW `141-12228-174.dmg` OS and `141-12233-179.dmg` AppOS, apfs-fuse read-only):
  no app car holds a Dark, Clear or Tinted bitmap. Each of the 71 layered icons has one pre-rendered Default bitmap
  (+ its RGBW twin) and an `.iconstack` (layout 1019) per appearance (DarkAqua id 1, Aqua 8 or UIAppearanceLight 4,
  ISAppearanceTintable 10; ids per car in `APPEARANCEKEYS`), IconGroups (layout 1020), layers as SVG (layout 9,
  LZFSE) or deepmap2 bitmaps (compression 11, 9 apps), COLR colours and GGRA gradients; ControlCenter is a classic
  icon without layers. Record layouts are in `themes/icons/tools/iconstack.py`. Deepmap2 bitmaps are stored
  B, G, R, A (fixed 2026-11-11 in `dmp2.py`: Preview, Siri, Image Capture, Grapher, ColorSync came out with red and
  blue swapped; Preview vs its own Default bitmap rms 86.5 -> 5.9). `apps/<Name>-256-<style>-<mode>.png` (360 files,
  5.4 MB): see `themes/icons/README.md` "Styles", `tools/build-styles.py` and `apps-styles.log`.
- IconRendering (27.2.1, read 2026-11-11): `IconRendering.framework/Versions/A/Resources/default.metallib` holds the
  kernels as AIR bitcode (14 modules, `llvm-dis` 21 reads them after cutting at the `0x0B17C0DE` wrappers;
  `binary.metallib` is the AGX build of the same): `glassHighlight` (the specular edge, ported in
  `themes/icons/tools/glass.py`), `glow`, `shapeAwareGradientMask`, `simplifiedShapeAwareGradientMask`, `sdfFill`,
  `clampToEdges`, `clampedPlusL` (min(1, a + b) on rgb, saturate on alpha, then max with b). All work on an SDF
  texture (r = distance, gb = normal). The renderer and its tunables are Swift: `ipsw swift-dump <DSC> IconRendering`
  gives `ICRRenderingParameters` with every field name and type (Highlights with 10 HighlightsSets of keySharp /
  keyDiffuse / fillSharp / fillDiffuse / dark / rim HighlightSettings, Shadow, ChicletShadow, TranslucencyEffect,
  ContourGradients, ClearMode with VCM black/white/saturation, SimulatedChiclet, Fills). Its `default` is built by
  the once-initialiser at 0x1cfd87b8c (0x363-byte struct; Highlights by 0x1cfd8cd9c, 0x3ef1 bytes, not walked).
  Read from it: systemLightGradient white 1.0 -> 0.961 (245/255), systemDarkGradient 31/255 -> 15/255 (the Dark
  tiles measure 31 -> 15); ContourGradients light/dark tint start 0.15 end 0, light clear 0.10 / 0, dark clear
  0.12 / 0, fake glass 0.88 / 0.75; glyphTranslucency strength 1, upper opacity 1; Shadow box radius 0.3,
  vibrant opacity 0.75, neutral 0.375, vibrantBrightness 0.75; mitigated tints (Reduce Transparency) light tint
  0.5,0.5,.. factor 0.9, dark clear 0.17. How the renderer maps the HighlightSettings onto the kernel inputs was
  not decoded, so `glass.py`'s inputs are fitted (see there).
- Icon Composer group glass in the car, decoded 2026-11-11 from CoreUI's reader (27.2.1 dyld cache,
  `-[_CUILayerStackRendition _initWithCSIHeader:version:]` at 0x18f2af564; the tag switch is at 0x18f2af734, selectors
  read from the objc stubs it calls): TLV 0x3fd, per child 20 bytes = u32 hasSpecular (bit 0), f32 translucency,
  u32 shadowStyle, f32 shadowOpacity, u32 specularPlacement (not blur, as guessed before: blurStrength lives on the
  layer image); TLV 0x3fe, per child 12 bytes = f32 refractionStrength, f32 refractionHeight, u32 not read. The same
  reader takes TLV 0x3f4 children as u32 flags (bit 0 fixedFrame), frame, u32 blendMode, f32 opacity, key.
  `themes/icons/tools/iconstack.py` decodes both into `glass` on every group and layer and prints them. Over the 72
  app cars x 3 appearances: only groups carry values (layers and the background are all zero); specular on or off,
  translucency 0 / 0.2 / 0.25 / 0.3 / 0.5, shadowStyle 0 / 2 / 3 (enum names not decoded; ICRRenderingParameters has
  a "neutral" and a "vibrant" shadow opacity), shadowOpacity 0.3-0.6, specularPlacement 0 or 2, refraction 0
  everywhere; an appearance can change them (Notes' sash group: translucency 0 / style 2 / 0.4 in Aqua and DarkAqua,
  0.3 / 3 / 0.6 in Tintable; Finder's head 0.25 with style 2 dark, 3 light).
  STILL NOT DECODED (so `build-styles.py` composes flat and its rms did not change: Dock 66 px Dark 6.4-14.9, Clear
  2.9-9.2, Tinted 7.8-15.4; tiles Dark 15.5 / 19.3, TintedDark 10.4 / 10.6, ClearDark 16.7 / 18.1): how IconRendering
  turns these into pixels (which blur and backdrop a translucency of 0.5 means, the shadow's offset / radius per
  style, where the per-group specular goes for placement 0 against 2), the Highlights builder (0x1cfd8cd9c) and how
  HighlightSettings feed the `glassHighlight` kernel inputs. Reproducing them without that would be a fit to the
  368 Settings tiles, not Apple's rule.
- Settings pane tiles as ground truth: per style the chiclet is the same on every symbol pane (spread <= 3/255):
  Dark 31 -> 15 grey, TintedLight flat 0,122,249, TintedDark grey 25 + accent x (0.15 top -> 0 bottom), ClearLight
  opaque 125, ClearDark opaque 43, each with a thin top/bottom specular edge. White symbols map to 167,240,255 /
  24,134,253 / 249 / 237 (TintedLight / TintedDark / ClearLight / ClearDark). The Dock does not draw TintedLight like
  these tiles (its tile is 0,109,195 in glass53/...-clear-tinted.png).
- `apple-map.txt` (Linux app id or icon name -> macOS icon, ~220 names) is the single source for the shell, the Finder and the `hyprk-apple`
  theme; `apple-map.js` is generated from it (`tools/gen-map.mjs`, tested in `themes/icons/tests`).
- `system/<Name>-512/128.png`: 257 `CoreTypes.bundle` icons (OS `/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources`) from the
  `.icns` at real 1024 px. Trash: `TrashIcon` (empty), `FullTrashIcon`. Folders: `GenericFolderIcon`, `OpenFolderIcon`, `ApplicationsFolderIcon`,
  `DesktopFolderIcon`, `DocumentsFolderIcon`, `DownloadsFolder`, `MovieFolderIcon`, `MusicFolderIcon`, `PicturesFolderIcon`, `HomeFolderIcon`,
  `Sidebar*`, and more. Also Mac models (`com.apple.*`) and file types.
- `settings/`: System Settings sidebar icons. macOS 27 has no bitmaps for them: IconServices draws a coloured enclosure with an SF Symbol at run
  time, configured by `CFBundleIcons > ISGraphicIconConfiguration` (ISEnclosureColor, ISSymbolName, ISSymbolColor) in each pane's
  `/System/Library/ExtensionKit/Extensions/*.appex/Contents/Info.plist`, or by a `com.apple.graphic-icon.*` UTI declared in
  `CoreTypes.bundle/Contents/Info.plist`. `settings/panes.json` holds that data for every hyprk pane id. Siri and Spotlight are rendered the same
  way (32ee0c7 dropped the `siri.png` / `spotlight.png` crops); every pane icon is in `themes/icons/settings/`. The other legacy pane artwork (Network globe, Displays monitor, Dock, Accessibility ring,
  Screen Time, `icon.icns` = generic extension brick) is the old large-icon style and is not what the sidebar shows, so it was not used.
  The 21 other panes keep the glyph tile until SF Symbols can be drawn.
- `sf-symbols/` (item for a later switch-over, nothing uses it yet): the IPSW has no symbols font. SFNS/SFCompact/SFNSRounded contain no symbol
  glyphs, the only font is `SFSymbolsNeededByCoreMedia-Semibold.ttf` (copied, 5 symbols). All symbols are in
  `/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/Assets.car` (118 MB, too big to track, re-extract with `car.py`;
  CoreGlyphsPrivate.bundle has 26 MB more). In that car the facet name is the SF Symbol name (8649 facets, `wifi`, `gearshape`, `bolt.fill`).
  Each facet has 3 vector renditions (layout 1022, blob `DWAR` + `BVG `, 300-800 bytes, rendition key attribute 26 = 1, 4, 9, apparently the
  light/regular/black weight masters, plus a transform and per-layer names like `p0.34`/`p0.68` for the hierarchical colour layers) and many
  small pre-rasterised GA8 bitmaps (11-112 px, 1x/2x, in `ZZZZPackedAsset` atlases compressed as deepmap2/`dmp2`, not decoded here).
  BVG is decoded (2026-11-11): `themes/icons/tools/bvg.py <car> <outdir> <names> [weights]` writes AppKit-like 32 pt
  SVGs + names.json metadata. Checked against the 73 Mac-rendered symbols x 3 weights in `sf-symbols/svg/`: IoU median
  0.9997, min 0.989, alpha rms <= 1.6/255. Format (CoreUI 27.2.1: CSIBVGPathDecoder::createDecodedPath 0x18f2e5484,
  CSIBVGNibbleReader 0x18f2e5d44/5b70/5bdc, consumeFlag 0x18f2e5d98, decodeGenericValue 0x18f2e5e34,
  CommandByte::resolvedSVGCommand 0x18f2e60f4, CSIBVGNumericListDecoder 0x18f2e58cc):
  container `BVG `, u8 version 1, u8 flags (low nibble w = 1 or 2 = width of every offset/index), size, end offset,
  u8 section count n, n+1 section offsets; sections form a storage table (strings such as `matrix(13/2048 ...)`, the
  name, layer tags; path data starting `00 00`; numeric lists starting `00 xx`); atoms < 89 are the predefined
  strings `_CSIBVGPredefinedStrings`, >= 89 are section (index - 89). Nibbles high first. Path: u8 0, u16 segment
  and point counts, then command bytes (0x7X = Z; high nibble 0 L/M, 1 C, 2 S, 3 Q, 4 T, 5 H, 6 V, 8.. relative;
  bits 0-1 set-count width, bit 2 odd count, bit 3 compact integers), flag bytes (signs, width class, pair count),
  compact pairs with kIntegerLargeBits [8,10,12,14] / kIntegerSmallBits [4,6,8,10], or generic decimal values
  (integerWidths [4,8,12,32], decimalWidths [12,16,28,40], halfNibbleDecimalWidths [10,14,26,38], exponentWidths
  [8,12]). Coordinates are font units, mapped to 13 pt by the matrix. The tail holds classes (monochrome-N /
  multicolor / hierarchical layers, `-sfsymbols-clear-behind` knockouts) and the node tree. Weights blend the three
  masters (attr 26 = 1/4/9) as W4 + u(W1-W4) + v(W9-W4): regular (0.182, 0), medium (0.148, 0.165), semibold
  (0.123, 0.291) (fitted, identical to 3 decimals on 10 symbols). The AppKit canvas uses TLV 0x3fa margins (u32 7,
  u32 13, 8 floats; the first float not identified). Decoded so far into `sf-symbols/svg/`: document.on.document.fill,
  pencil.tip.crop.circle, printer, rotate.left, document.on.clipboard, gearshape, gearshape.2, chevron.up.chevron.down
  (names.json notes say "decoded from BVG").
  Copied tables (binary plists, from CoreGlyphs and `private/` from CoreGlyphsPrivate): `symbol_order.plist` (names in SF Symbols app order),
  `name_availability.plist` (name -> release year), `symbol_search.plist` (name -> search terms), `symbol_categories.plist` and
  `categories.plist`, `name_aliases.strings` (old name -> current name), `nofill_to_fill.strings`, `legacy_flippable.plist`,
  `symbol_restrictions.strings` (Apple-only symbols), `semantic_to_descriptive_name.strings`, `private/container_recipes.plist`.
  Mapping: a symbol name (after `name_aliases`) is the facet name in the car; a variant suffix is part of the name (`.fill`, `.slash` are shape variants; `.ar` and `.hi` are apparently Arabic and Hindi variants, not checked).

- The Dock's own Trash (2026-11-11): Dock.app (`/System/Library/CoreServices/Dock.app`, 27.2.1 OS dmg) draws
  `Contents/Resources/s-trash*.png`, not CoreTypes' TrashIcon, and picks by `[iconAppearance style]` (0 light, 1 dark,
  2 clear light, 3 clear dark, 4 tinted light, 5 tinted dark; chooser at 0x1000090ac in the arm64e slice, CFStrings
  0x1002e5d68-0x1002e5f08, tint matrix 0x1000e2514 with constants at 0x10025c3c0, tint = `[iconAppearance tintColor]`).
  The eight 256 px results are `system/DockTrash[Full]-256[-<style>-<mode>].png`, built by `tools/build-trash.py`
  (rule and what is not Apple's in its header). Its glass layer (`s-trashempty-sdf.png`, 384 px, zero / one value
  distance -128 / 128, padding 152, glass background style 2) is not built. Dock.app has no per-style art for folders
  or stacks (only `s-pileArrow*`), so the Downloads stack stays as it is.
- App icon sizes: `apps/<Name>-256.png` (Lanczos from the 1024 / 512, `tools/build-apps.py`) joins 128 and 512 so
  `ui/HyprK/AppIconTile.qml` can load the smallest file at or above the drawn size; its shader
  (`ui/HyprK/shaders/iconart.frag`) resamples in one Lanczos-3 pass on the device pixel grid.

## themes/cursors/

- `hiservices/` from `HIServices.framework/.../Resources/cursors` (43 cursors incl. `macos27/{pointinghand,openhand,closedhand}`): vector `cursor.pdf` + `info.plist` (hotspot `hotx/hoty`, shadow). `png/hiservices/` are 128 px renders (pdftoppm, 288 dpi), 43 files. Plus `ibeam_*x` PNG at 1x/2x/5x/10x with hotspot in the file name.
- `accessibility/` from `AccessibilityFoundation.framework/.../Resources/Cursors`: top/bottom PDF layers for many cursors (arrow, hand, resize, rotate, ...) and `default-pointer-0..3.png` + `default-iBeam-0..3.png` (large pointer sizes, real arrow). `png/accessibility/` has renders of the PDFs.
- Not extracted: the standard arrow at normal size is not in HIServices. It is in `SkyLight.framework/Versions/A/Resources/CursorAsset` (16 MB Mach-O, raw pixel data in `__TEXT.__const`, no PNG/PDF signature, format not reverse engineered). Use `default-pointer-*.png` from accessibility as the arrow.
- No Xcursor theme was built. Hotspots are in the `info.plist` files.

## What failed or was skipped (summary)

`.madesktop` wallpapers, arrow cursor from CursorAsset, Xcursor packaging, static SF font instances.
