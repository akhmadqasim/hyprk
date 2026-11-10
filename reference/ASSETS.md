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
  BVG is not decoded. `car.py bvg <car> <outdir> <names>` dumps the raw blobs; `sf-symbols/bvg-samples/` has 16 symbols x 3 masters for a decoder.
  Copied tables (binary plists, from CoreGlyphs and `private/` from CoreGlyphsPrivate): `symbol_order.plist` (names in SF Symbols app order),
  `name_availability.plist` (name -> release year), `symbol_search.plist` (name -> search terms), `symbol_categories.plist` and
  `categories.plist`, `name_aliases.strings` (old name -> current name), `nofill_to_fill.strings`, `legacy_flippable.plist`,
  `symbol_restrictions.strings` (Apple-only symbols), `semantic_to_descriptive_name.strings`, `private/container_recipes.plist`.
  Mapping: a symbol name (after `name_aliases`) is the facet name in the car; a variant suffix is part of the name (`.fill`, `.slash` are shape variants; `.ar` and `.hi` are apparently Arabic and Hindi variants, not checked).

## themes/cursors/

- `hiservices/` from `HIServices.framework/.../Resources/cursors` (43 cursors incl. `macos27/{pointinghand,openhand,closedhand}`): vector `cursor.pdf` + `info.plist` (hotspot `hotx/hoty`, shadow). `png/hiservices/` are 128 px renders (pdftoppm, 288 dpi), 43 files. Plus `ibeam_*x` PNG at 1x/2x/5x/10x with hotspot in the file name.
- `accessibility/` from `AccessibilityFoundation.framework/.../Resources/Cursors`: top/bottom PDF layers for many cursors (arrow, hand, resize, rotate, ...) and `default-pointer-0..3.png` + `default-iBeam-0..3.png` (large pointer sizes, real arrow). `png/accessibility/` has renders of the PDFs.
- Not extracted: the standard arrow at normal size is not in HIServices. It is in `SkyLight.framework/Versions/A/Resources/CursorAsset` (16 MB Mach-O, raw pixel data in `__TEXT.__const`, no PNG/PDF signature, format not reverse engineered). Use `default-pointer-*.png` from accessibility as the arrow.
- No Xcursor theme was built. Hotspots are in the `info.plist` files.

## What failed or was skipped (summary)

SF Symbols (BVG vector format not decoded), `.madesktop` wallpapers, arrow cursor from CursorAsset, Xcursor packaging, static SF font instances.
