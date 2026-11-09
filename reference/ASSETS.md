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
- Not done: static instances (Display/Text/Bold...). Use fontTools `instancer` if an app can't use variable fonts. Fonts are Apple licensed, for local use only.

## themes/wallpapers/

- `heic/` originals, `png/` full-resolution PNG (ImageMagick + libheif). Multi-image HEICs get `-0`, `-1` suffixes (Sonoma).
- macOS 27 default: `TahoeLight.heic` and `TahoeDark.heic` (6016x6016, from OS `/System/Library/ExtensionKit/Extensions/NeptuneOneWallpaper.appex/Contents/Resources/`, `manifest.json` saved as `NeptuneOne-Tahoe-manifest.json`; it points to Apple's remote `tahoe-*-landscape.mov` aerials). Install default: `DefaultAerial.heic/.jpg` (3840x2160) and `Golden Gate.mov` (96 MB) from `/System/Library/Wallpapers/.default/`.
- Also: `Sonoma.heic`, `Sonoma Horizon.heic`, `Radial Sky Blue`, `iMac *` (7 colours), `Mac *` (4 colours) from `/System/Library/Desktop Pictures/`, and the Sonoma dynamic `.mov` set in `dynamic-sonoma/`.
- Not available: all `.madesktop` wallpapers (Big Sur, Monterey, Ventura, Light Stream, ...). They are only small plists, the real images are MobileAsset downloads not in the IPSW. The `.thumbnails` (tiny) were skipped. The Aerials extension only has thumbnails.

## themes/icons/

- `apps/<Name>-512.png` and `-128.png`: 72 app icons (all of `/System/Applications`, Utilities, plus Finder, Dock, Spotlight, ControlCenter, Screenshot, Siri, ... from OS and Safari from AppOS). Includes Finder, Safari, Messages, Maps, Photos, FaceTime, Calendar, Contacts, Reminders, Notes, Music, TV, App Store, System Settings, Terminal, Apps (= Launchpad replacement), and more.
- `apps-hires/`: native pre-rendered bitmap straight from each app's `Assets.car` (1024 px or 512 px, 65 apps). I wrote a small BOM/CSI reader (`KCBC` + LZFSE blocks, BGRA premultiplied) because no Linux tool for `.car` exists. 512/128 files for these apps are downscaled from here. Colours were checked visually.
- Upscaled from the 256 px `.icns` (only 256 px exists as a flat file): Mail, Freeform, Dock, Spotlight, ControlCenter, Archive Utility, Install Command Line Developer Tools. Mail's real icon is only stored as vector layers (Icon Composer `.iconstack`), which I could not render. No icon file at all: Notification Center, Software Update, Keychain Circle Notification.
- `system/<Name>-512/128.png`: 257 `CoreTypes.bundle` icons (OS `/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources`) from the `.icns` at real 1024 px. Trash: `TrashIcon` (empty), `FullTrashIcon`. Folders: `GenericFolderIcon`, `OpenFolderIcon`, `ApplicationsFolderIcon`, `DesktopFolderIcon`, `DocumentsFolderIcon`, `DownloadsFolder`, `MovieFolderIcon`, `MusicFolderIcon`, `PicturesFolderIcon`, `HomeFolderIcon`, `Sidebar*`, and more. Also Mac models (`com.apple.*`) and file types.
- Logs: `extract.log` (icns route) and `hires.log` (Assets.car route, with source path per app).
- Not extracted: SF Symbols. They live in `/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/Assets.car` (118 MB, ~31k vector renditions) but as Apple's binary vector format `BVG` inside `DWAR` blocks, no tool on Linux, not decoded. The SF fonts do not contain them either. Metadata (`symbol_order.plist`, `name_availability.plist`, ...) is next to the car file on the volume, not copied. Alternative for toolbar glyphs: a free icon set (Lucide, Phosphor).
- Liquid Glass layered icon sources (`*.iconstack`, SVG/PDF layer renditions) not exported.

## themes/cursors/

- `hiservices/` from `HIServices.framework/.../Resources/cursors` (43 cursors incl. `macos27/{pointinghand,openhand,closedhand}`): vector `cursor.pdf` + `info.plist` (hotspot `hotx/hoty`, shadow). `png/hiservices/` are 128 px renders (pdftoppm, 288 dpi), 43 files. Plus `ibeam_*x` PNG at 1x/2x/5x/10x with hotspot in the file name.
- `accessibility/` from `AccessibilityFoundation.framework/.../Resources/Cursors`: top/bottom PDF layers for many cursors (arrow, hand, resize, rotate, ...) and `default-pointer-0..3.png` + `default-iBeam-0..3.png` (large pointer sizes, real arrow). `png/accessibility/` has renders of the PDFs.
- Not extracted: the standard arrow at normal size is not in HIServices. It is in `SkyLight.framework/Versions/A/Resources/CursorAsset` (16 MB Mach-O, raw pixel data in `__TEXT.__const`, no PNG/PDF signature, format not reverse engineered). Use `default-pointer-*.png` from accessibility as the arrow.
- No Xcursor theme was built. Hotspots are in the `info.plist` files.

## What failed or was skipped (summary)

SF Symbols (BVG), Mail/Freeform hi-res icons, `.madesktop` wallpapers, arrow cursor from CursorAsset, Xcursor packaging, static SF font instances.
