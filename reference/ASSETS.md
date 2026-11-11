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
  `themes/icons/tools/glass.py` and `icr.py`), `glow`, `shapeAwareGradientMask`, `simplifiedShapeAwareGradientMask`, `sdfFill`,
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
  0.5,0.5,.. factor 0.9, dark clear 0.17. How the renderer uses all of it: the composition item below.
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
  How IconRendering uses them is in the next item.
- IconRendering composition, decoded 2026-11-11 (27.2.1 dyld cache; text dumped raw into Ghidra 12.2 at 0x1cfd26000,
  ObjC stub names from `ipsw dyld disass`; addresses are cache addresses). What is exact, checked or still open is
  listed at the end of this item.
  * Enums (swift-dump field order): `Icon.GlassMaterial.ShadowStyle` automatic 0 / none 1 / vibrant 2 / neutral 3;
    `SpecularPlacement` automatic 0 / inside 1 / outside 2; `SizeClass` small 0 / medium 1 / large 2 / display 3
    (thresholds minMedium 25, minLarge 60, minDisplay 256); `GlobalConfiguration.RenderingSteps` chicletContents 1,
    chicletHighlights 2, chicletDarklights 4, glyphContents 8, glyphInnerGlow 0x10, glyphHighlights 0x20,
    glyphDarklights 0x40, glyphShadow 0x80, glyphTranslucency 0x100, glyphGlass 0x200, outline 0x400,
    maskToChiclet 0x800; `RenderingMode.Contents` tinted(IconColor, saturation) / color / clear.
  * `ICRRenderingParameters.default` (0x1cfd87b98, Highlights 0x1cfd8cd9c): every value is in
    `themes/icons/tools/icr-params.json` (emulated, not read by eye): 10 HighlightsSets, Shadow (offsetY 32,
    radius 0.3, ringWidth 16, vibrant 0.75, neutral 0.375, multiply), ClearMode (lightening 1.0, darkening 0.3,
    highlights 1.0, VCMs), ChicletShadow, TranslucencyEffect, ContourGradients, SimulatedChiclet, glow = nil.
  * `IconRenderer` struct offsets: globalConfig 0 (effectsAreEnabled 0x21, drawMitigatedVersion 0x22,
    enabledRenderingSteps 0x28), parameters 0x68, icon 0x3d0, style 0x4e0 (appearance 0x4e1, renderingMode
    0x4e8..0x510), list 0x520 (RBDisplayList, fill 0x530, shape 0x538), chicletShape 0x588, highlights 0x5f0,
    shadow 0x4508, clearMode 0x4600, hasChicletShadow 0x469e, sizeClass 0x469f, pointUnit 0x46a0, pixelUnit 0x46a8.
  * Top level 0x1cfd6ce14: transform, chiclet drop shadow (0x1cfd6d250, `addShadowStyleWithRadius:` from
    ChicletShadow by size class), clip to the chiclet shape (maskToChiclet), then 0x1cfd70f98 -> 0x1cfd71dfc.
  * 0x1cfd71dfc, the mode wrapper: effective clear mode = renderingMode clear, or tinted + light appearance
    (ClearMode.applyToLightTintToo = true; chosen in 0x1cfd878e0). In clear mode the WHOLE icon is drawn through a
    colour matrix R' = totalLighteningStrength x R, G' = totalDarkeningStrength x (1 - G), B' =
    totalHighlightsStrength x B: the result is not a picture but three masks (lighten / darken / highlights) that
    the system glass under the icon consumes (ClearMode.DebugMode names them: rawImage, lighteningMask,
    darkeningMask, highlightsMask). That is why the Dock's TintedLight / Clear icons differ from IconServices'
    Settings tiles: the tile is `SimulatedGlassRenderer`'s stand-in glass, the Dock's is real glass.
    Tinted + dark is NOT clear mode: the layers are drawn in a layer with `addSaturationFilterWithAmount:`
    (the mode's saturation) and a duotone colour matrix (0x1cfdab484) C' = black + (tint - black) x C.
  * Highlights: 0x1cfd8c894 picks the chiclet HighlightsSet: colour mode by IconBrightness (normal / bright / dim,
    limits maxDimChicletLuminance 0.2, minBrightChicletLuminance 0.99), clear mode -> chicletClear, tinted dark ->
    chicletScreened. 0x1cfd59270 turns a set into up to 7 lights: keySharp and keyDiffuse at angleFromKey 0,
    fillSharp / fillDiffuse at pi (matchKey = the key's settings), dark at +pi/2 and -pi/2 (isDarklight), rim at 0;
    curvature = the set's highlight / darklight curvature for sharp, dark and rim, 1 for the diffuse ones.
    0x1cfd7603c resolves one light for the size class: height = max(distance, minDistancePixels x pixelUnit),
    inset likewise, opacity = lightIntensity x opacity, direction = (sin a, cos a) with a = angleFromKey + light
    longitude (default 0 = from the top), colour = brightness grey, blend = plusLighter when brightness >= 0.5
    else plusDarker (or blendModeOverride). 0x1cfd765d4 groups lights with equal constraints into one pass.
  * A highlight pass on a vector shape (the chiclet), 0x1cfd34fb0 + 0x1cfd3a0cc: intensity over the angle around
    the shape centre (a 256-stop conic gradient) l = max(0, (cos(theta - theta_light) - cos(spread)) / (1 -
    cos(spread))), lights of one pass unioned; times the edge falloff 1 - curvature x d / height inside the band
    0 <= d <= height (RBShape rendering mode 2 with argument height, the shape stroked 2 x height); then a 65-stop
    gradient map alpha = t / ((1 / bias - 2)(1 - t) + 1) (Schlick bias); drawn with the pass opacity and blend mode.
    This is the `glassHighlight` kernel's formula with spread = cos(spread angle) and biasAmount = 1 / bias - 2.
    In clear mode chiclet highlights are drawn in pure blue (the highlights mask) with plusLighter and chiclet
    darklights are skipped (leaveChicletDarklightsToSystem).
  * Working space: the final image is rendered with RBColorMode 14 / RBColorSpace 1 (0x1cfd3b03c from
    `FinalizedIcon.renderedIcon(at:with:)`), whose working colour space is sRGB with the sRGB transfer curve
    (RenderBox `RBColorModeWorkingColorSpace` table 0x196bda4fc, `RB::ColorMode` 0x196a8f544): blending is done on
    gamma-encoded values, extended range. IconColor values are passed as RBColorSpace 3 = Display P3
    (`rb_color_space` table 0x196be7751). RBBlendMode from Icon.BlendMode (table 0x1cfdc2790): normal 0, darken 4,
    multiply 1, colorBurn 7, plusDarker 26, lighten 5, screen 2, colorDodge 6, plusLighter 27, overlay 3, ...
  * Chiclet contents 0x1cfd72690: an axial gradient from 10 % to 90 % of the bounds height. Stops from
    0x1cfd87710: colour mode = the icon's own fill (no fill: fake glass 0.88 -> 0.75), tinted = ContourGradients
    tint start -> end (0.15 -> 0) as greys, clear = 0.10 / 0.12 -> 0. In clear mode the chiclet is drawn as pure
    green instead (no lightening, no darkening).
  * The layers, 0x1cfd6d430 (the simple path; see open points). A `FinalizedIcon.Layer` is ONE Icon Composer group
    baked into one image (0x1cfd40bc8) with an SDF texture and a baked shadow image. Per group, in order:
    1. 0x1cfd74500: the group's shadow (0x1cfd740e8) and, with blurStrength / refraction, a backdrop blur
       (blurStrength x blurStrengthMax 64) and refraction inside the SDF.
       Shadow image bake 0x1cfd4589c (re-read 2026-11-11, second pass): one display list with, in this order,
       colour multiply by vibrantBrightness 0.75 ("vibrant") or alpha multiply to black ("neutral"), translate by
       the offset (0, 32) canvas units, blur filter of radius blurStrengthMax 64 x Shadow.radius 0.3 = 19.2 units,
       then a clip layer and the group's own display list. The clip is the group's SDF drawn by 0x1cfd39594 with
       inset -ringWidth: that function is an alpha threshold (`addAlphaThresholdFilterWithMinAlpha:maxAlpha:`)
       between the SDF value of the edge (0.5) and the value at the inset, i.e. a RING ringWidth 16 wide along the
       edge, not the shape grown by 16 (the first pass read it as that). The filters act on the whole list, so
       the shadow is the ring cut of the group, moved down by 32 and blurred: a soft band below the group and no
       shadow over its interior. Which side of the edge the ring lies on depends on the sign of the SDF, which was
       not read: MEASURED on the Cmd-Tab shot, inside (rms 9.4 against 9.6 for outside, 10.9 for the grown shape).
       Draw: tint white (vibrant) or black (neutral), alpha = group opacity x shadowOpacity x 0.75 (vibrant) or
       0.375 (neutral), blend multiply (vibrant on a dim icon: normal). Style: colour mode: automatic and vibrant
       -> vibrant, neutral -> neutral, none -> nothing; tinted and clear modes: everything but none -> neutral.
    2. 0x1cfd74eec contents: translucency t > 0 clips the group by a vertical gradient over its effects frame
       (0x1cfd37554, useSimpleMask = replicateBadSmoothing = true): alpha(v) = m^2 (3 - 2 m), m = 1 - t x strength x
       v, v = 0 at the top, 1 at the bottom, 17 stops (0x1cfd348b0). Then the baked image with the group's opacity
       and blend mode (0x1cfd75774). Clear mode: through R' = contentLighteningStrength 0.85 x R, G' =
       contentDarkeningStrength x G + (1 - it) = 1, B' = 0 (0x1cfd75194).
       Shadow overdraw (Shadow.drawOverContent, blend mode normal groups only): the group's shadow again, clipped
       to the group's own content, alpha x min(1, t / translucencyForMaxOverdraw 0.3) x 0.5 (vibrant, automatic)
       or 0.2 (neutral), overdrawBlendMode multiply. The translucency clip of step 2 is still set while it is
       drawn (`clipLayerWithAlpha:mode:` is not undone before it), so it fades with the same gradient.
    3. glow: `ICRRenderingParameters.glow` is nil, nothing.
    4. 0x1cfd73374 highlights (hasSpecular groups): the set from 0x1cfd8cac4 (glyphsDefault / Bright / Dim by
       IconBrightness, glyphsClear, glyphsScreened), light = defaultGlyphLight, each light drawn by the
       `glassHighlight` kernel on the group's SDF (0x1cfd35f90: biasAmount = 1 / bias - 2, sdfScaleFactor = -2 x
       maxDistance, sdfZeroValue 0.5), opacity x group opacity. Not clear mode (glyphHighlightsUseVCM = true): the
       kernel's output is only a MASK; inside it the backdrop is replaced by a vibrant colour matrix of itself
       (BT.709 YCbCr, Y' = black + (white - black) Y, chroma x saturation; matrices 0x1cfdbda70 / 0x1cfdbdab0):
       glyphHighlightVCM 0.2 / 1.2 / 1.25, glyphDarklightVCM -0.15 / 0.7 / 1.25. Clear mode: highlights are
       screened into the red mask, darklights multiply the green one to 0.
       Darklights with an outsetOpacity (all glyph sets: 0.9 / 0.9 / 0.2 / 0.2) are drawn OUTSIDE the group
       (inset - height, opacity = outsetOpacity) unless specularPlacement is inside, or automatic on a bright icon
       in colour mode.
    Bake 0x1cfd40bc8: tinted and clear modes bake every group through `addGrayscaleFilterWithAmount: 1` into a
    grey image (RBColorMode 0 / RBColorSpace 16), colour mode into RBColorMode 14 / sRGB.
  * One layer inside a group, 0x1cfd42e9c (read 2026-11-11, second pass). The layer's picture (SVG through
    `CGContextDrawSVGDocument`, bitmap as an RBImage) is the CLIP; the fill is a rect drawn with
    `drawShape:fill:alpha:blendMode:` = the layer's opacity and its own blend mode (the car's CGBlendMode, e.g.
    Safari's tick marks are plusLighter at 0.6; 28 of the 72 icons have such layers). Fill kinds (0x1cfd66c3c, tag
    in the top two bits): 0 colour, 1 automaticGradient(colour), 2 gradient, 3 system (light / dark). A gradient's
    start and end are unit points of the BOUNDING RECT of what the layer draws (`boundingRect` of its display
    list), not of the canvas; only Icon.Fill.system is laid over the whole canvas
    (`supportsChicletAlignmentForSystemFills`) with `GradientPlacement.default` (0,0) -> (0,1) (0x1cfd62d1c) and
    IconRendering's own stops (Fills.systemLightGradient / systemDarkGradient).
  * Automatic gradient 0x1cfd2c2a8 (the car's GGRA type 0, one colour; Apps, Automator, Freeform, Time Machine,
    Bluetooth File Exchange, Screen Sharing, VoiceOver Utility, Spotlight): Y = 0.2126 r + 0.7152 g + 0.0722 b of
    the colour's components; lightening l = dimLightening 0.04 for Y <= 0.25, midDimLightening 0.08 for Y <= 0.5,
    midBrightLightening 0.15 for Y <= 0.75, else brightLightening -0.05; c' = c + saturationBoost 0.2 x (c - Y);
    second colour = c' + l (1 - c') for l >= 0, c' + l c' for l < 0, clamped to 0..1. l > 0: second colour at
    location 0, the given one at 1 - basePosition; l <= 0: the given one at basePosition 0, the second at 1.
    The points are the fill's own (the car's GGRA points).
  * SDF of a group, 0x1cfd45064 -> 0x1cfd47bb4: the group's layers are drawn AGAIN through 0x1cfd42e9c with its mask
    flag (one solid colour, alpha 1: a fill's alpha gradient or a layer's opacity is not in the shape), into a
    texture 2 px larger than the group image (RGBA16Float above precisePixelFormatThreshold 256 px, else
    RGB10A2), with RenderBox's distance style (`addStyle:data:` 10) and the `clampToEdges` shader, then stacked by
    0x1cfd38d98 (clampThreshold 0.002, useAdvancedStacking); the encoded range is +-0.2 x the shorter side
    (value 0.5 = the edge). RenderBox's distance style itself (and the smoothing, maxRelativeSmoothing 0.005) was
    not read: the port still computes an exact Euclidean distance field, now of that solid shape.
  * Size class, 0x1cfd6c4a8: the shorter side, in points, of the content rect from 0x1cfd6be14 (the size minus
    floor(size x 100 / 1024) on each side when the icon carries its margin: 128 -> 104, 33 -> 27, 16 -> 14)
    against minMedium 25 / minLarge 60 / minDisplay 256. pointUnit = canvas units per point, pixelUnit =
    pointUnit / scale.
  * Then the chiclet highlights (0x1cfd715e0, above) and, only for the mitigated version in colour mode, the outline
    (0x1cfd71b8c -> 0x1cfd76bc0, useDynamicOpacity): inside a stroke of lineWidth 1 point (large; 0.667 medium /
    small, 1.333 display) the backdrop is mapped through a gradient map of its own luminance: white with alpha
    lineOpacityOnDim 0.15 at luminance 0 fading to nothing at luminanceRangeOnDim 0.1 (bright icons: black 0.12
    from luminance 0.9 up). Groups with knocksOutBorder are cut out of it in the static variant.
  * The mitigated version (`GlobalConfiguration.drawMitigatedVersion`, 0x1cfd70f98): what IconServices' still
    images are (the Settings tiles), because a still has no live glass under it. Colour mode: as above plus the
    outline. Other modes: a plate colour (0x1cfd87564: clear light 0.5, clear dark 0.17, tinted dark 0.1, tinted
    light = mix(0.5 grey, tint, 0.9 x saturation)), then the icon drawn into its own display list and put over the
    plate with `FinalizedIcon`'s layer passes (0x1cfd69ffc, drawn by 0x1cfd6b4b0):
    tinted dark: one pass, RBBlendMode 2 = screen. Clear (and tinted light), passOrder lightenFirst:
    1. lighten: inside alpha = the red mask the backdrop is replaced by lighteningVCM (0.9 / 2.5 / 2.0, headroom 1.2)
       of itself; 2. darken: plusDarker with the grey 1 - green mask, i.e. backdrop - 0.3 x darkening; 3. highlights:
       inside alpha = the blue mask, highlightsVCM (0.2 / 1.35 / 1.4, headroom 1.2).
       The same three passes exist as CAFilters for the live layer, which is what the Dock shows over its real
       glass: see "The live layer's CAFilter passes" below.
  * The live layer's CAFilter passes (0x1cfd69ffc builds the list, 0x1cfd6b31c sets each pass on a CALayer with
    `setFilters:`, `setCompositingFilter:`, `setOpacity:` 1; filters built by 0x1cfd6a928 colorMatrix and
    0x1cfd6ac24 vibrantColorMatrix; read 2026-11-11). Every pass shows the SAME picture, the icon drawn as the
    three masks (R lighten, G = 1 - darken, B highlights, see 0x1cfd71dfc), and sits over the backdrop the system
    provides (the Dock's glass). A colour matrix below is CAColorMatrix rows R, G, B, A x (r, g, b, a, bias).
    Clear mode and tinted + light, ClearMode.debugMode 0, in ClearMode.passOrder (0 = lighten first, the
    default; 1 swaps the first two):
      1. lighten. lighteningUsesVCM true (default): filters [`kCAFilterColorMatrix` (`inputColorMatrix` R' = G' =
         B' = 1, A' = R: white with the lighten mask as alpha; `inputPremultipliedValues`), `kCAFilterVibrantColorMatrix`
         (`inputColorMatrix` = lighteningVCM 0.9 / 2.5 / 2.0 as BT.709 YCbCr: Y' = black + (white - black) Y, chroma x
         saturation; `inputBackdropAware` true; `inputClamp` = headroom 1.2 when it is set; these two keys on
         26.0 and later)], no compositing filter: where the mask is, the backdrop is replaced by the matrix of
         itself. lighteningUsesVCM false: [colorMatrix R' = G' = B' = R, A' = A], compositingFilter `kCAFilterPlusL`
         (RBBlendMode 27).
      2. darken. darkeningUsesVCM false (default): filters [colorMatrix R' = G' = B' = 1 - G, A' = A],
         compositingFilter `kCAFilterPlusD` (RBBlendMode 26): backdrop - totalDarkeningStrength 0.3 x darkening.
         darkeningUsesVCM true: [colorMatrix R' = G' = B' = 1, A' = G, vibrantColorMatrix of darkeningVCM
         -0.5 / 0.5 / 1.5], no compositing filter.
      3. highlights (always last): filters [colorMatrix R' = G' = B' = 1, A' = B, vibrantColorMatrix of
         highlightsVCM 0.2 / 1.35 / 1.4, clamp 1.2], no compositing filter.
    debugMode 1 shows the raw picture without filters, 2 / 3 / 4 one mask through a single colorMatrix.
    Tinted + dark: ONE pass, no filters, compositingFilter `kCAFilterScreenBlendMode` (RBBlendMode 2).
    Colour mode and the mitigated version: one pass, no filters, no compositing filter.
    The RenderBox twin of a VCM pass is 0x1cfd6b00c: clip to the mask, `addContentHeadroom:` headroom,
    `addStyle:data:` 9 with (0, 0, 0, h, h, h, ...), the same colour matrix, `beginLayerWithFlags: 1` (the
    backdrop), `drawLayerWithAlpha:`.
    For hyprk's plugin: three quads over the Dock's composited glass under an icon, each sampling the icon's mask
    texture and the backdrop: (1) mix(backdrop, clamp(VCM_lighten(backdrop), 0, 1.2), R), (2) max(x - (1 - G'), 0)
    with G' as stored (already 1 - 0.3 x darkening), (3) mix(x, clamp(VCM_highlights(x), 0, 1.2), B).
    Not read: what CoreAnimation does with values above 1 after `inputClamp` (the stills go through RenderBox's
    style 9, measured as L / (1 + 0.27 L)), and what the Dock puts under the icon (its own glass tile).
    Tried as a static file (2026-11-11): these three passes over the Dock tile's measured colour (192 grey for
    ClearLight, 0,109,195 for TintedLight) against the style sheet shot: ClearLight mean 7.0 (clipped at 1) /
    10.3 (with the stills' tone curve) against 5.8 for the fitted rule, TintedLight 23.0 / 18.8 against 11.4. The
    fitted rule stays.
  * `simplifiedShapeAwareGradientMask` (default.metallib, the translucency mask when useSimpleMask is off): d =
    (zero - r) x scale, e = saturate(d / borderWidth), v = saturate((y - y0) / height), m = mix(mix(contour bounds,
    v), mix(opacity bounds, v), e), out = mix(1, m^2 (3 - 2 m), saturate(d + 1)).
  * The port: `themes/icons/tools/icr.py` (numpy; `build-styles.py` builds the files, `check-styles.py` compares).
    Checked stage by stage against the Mac's Settings tiles (IconServices stills, 128 px), nothing fitted unless
    said:
    - the Dark plate, identical on 21 panes: gradient only rms 7.7, + chiclet highlights 1.96, + outline 1.02
      (the old fitted rim: 2.25); 64 px 1.24. The side edges only fit with darklights AND outline, so the tiles
      are the mitigated version.
    - Siri / Spotlight, rms before -> after: Dark 15.5 / 19.3 -> 7.1 / 8.8; TintedDark 10.4 / 10.6 -> 8.3 / 8.6;
      ClearDark 16.7 / 18.1 -> 7.6 / 10.7; ClearLight (not compared before) 6.9 / 8.5; TintedLight 7.4 / 9.7.
      Each stage alone (Spotlight Dark / ClearDark): without shadows 11.8 / 11.6 (measured before the P3 fix: 11.5 /
      10.7 with), without highlights 11.7 / 14.3, without translucency 12.0 / 11.3, darklights inside instead of
      outside 11.2 / 12.2.
    - the Mac's Dark Dock at 66 px (files scaled down): Finder 11.1 -> 11.0, Mail 11.2 -> 11.1, Notes 6.4 -> 7.9,
      System Settings 13.3 -> 9.4, Calculator 14.9 -> 9.5 (mean 11.4 -> 9.8); Safari (style sheet) 13.1 -> 15.4.
      Without shadows mean 10.3, without highlights 10.6, without translucency 10.9, flat 10.9. The outline makes
      no difference there.
    - Second pass (2026-11-11), the port corrected against two more shots of the Dark style, Cmd-Tab (128 pt at
      2x, 8 icons: the shipped size, size class large) and the Apps grid (76 pt, 15 icons). Causes found, each
      in the port, none per icon: (1) the translucency gradient ran across the columns in colour mode (a numpy
      broadcast: Notes' lines faded left to right, Finder's face had no fade) - this alone is the Notes
      regression; (2) the shadow bake is a blurred ring, so there is no overdraw darkening over a group's
      interior (Finder's face was 7 % too dark); (3) a layer's gradient spans the layer's bounds, not the canvas
      (Safari's dial, Finder's face, Mail); (4) layer blend modes inside a group (Safari's ticks are plusLighter:
      the Safari regression is (2) + (3) + (4)); (5) the SDF is the layers' solid shape (a white line across
      Spotlight's lens came from the alpha of a fading fill); (6) the automatic gradient as decoded.
      rms before -> after. Dark Dock 66 px: Finder 11.0 -> 4.7, Mail 11.1 -> 4.9, Notes 7.9 -> 7.2, System Settings
      9.4 -> 8.4, Calculator 9.5 -> 5.6 (mean 9.8 -> 6.2; Apple's own Default bitmap scores 5.6-13.5 on the sheet);
      style sheet Dark row Safari 15.4 -> 10.7. Cmd-Tab 258 px: TextEdit 4.6 -> 4.9, Preview 23.4 -> 18.5, Font
      Book 16.9 -> 11.3, Finder 10.7 -> 5.3, Calculator 10.3 -> 7.5, Safari 14.2 -> 8.8, Mail 11.2 -> 6.4, System
      Settings 7.9 -> 6.7 (mean 12.4 -> 8.7). Apps grid 152 px, 15 icons: mean 19.0 -> 16.8, none worse by more
      than 0.4 (Freeform 19.6 -> 10.4, Safari 14.6 -> 9.0; Mail and Calendar carry a badge / today's date).
      Settings tiles, Spotlight: Dark 8.8 -> 7.6, TintedDark 8.6 -> 8.2, ClearDark 10.7 -> 7.0, ClearLight 8.5 ->
      6.7, TintedLight 9.7 -> 8.3; Siri unchanged (7.1 / 8.3 / 7.6 / 6.9 / 7.4).
    - Direct render at the Dock's size (33 pt at 2x, 66 px): the 20-34 rms of the first pass was the harness,
      not the size class: at 54 px the layers were rasterised and placed on whole pixels and the distance field
      had no sub-pixel accuracy. Rendered at 4 x and box-filtered down (pixel parameters kept in device pixels,
      `icr.render(supersample=)`): size class medium (what 0x1cfd6c4a8 gives for 33 pt: content 27 pt >= 25)
      mean 7.1, large 7.2, small 6.1, against 6.2 for the 256 px file scaled down (the five Dock icons). Medium and small weaken the
      darklights (opacity 1 / 0.9 -> 0.2) and the Mac's Dock indeed shows no dark halo around Notes' lines; small
      also weakens the sharp highlights (1 -> 0.3) and fits best, but the decoded thresholds do not give small at
      33 pt and how the Dock asks for its icons was not read. No Dock-size renditions are shipped: medium is not
      better than the scaled file.
    - The Dock's TintedLight / ClearLight: the port over a fixed plate is WORSE than the old Dock fit (TintedLight
      9-15 -> 11-27, ClearLight 3-9 -> 9-14), so those two styles keep the fitted rule. Explained, not solved: the
      Dock puts the three masks on live glass (CAFilter passes on portal layers), the tiles on a plate.
  * Measured, not read from code (marked in `icr.py` / `iconstack.py`):
    - SDR tone curve of the clear-mode still: with the vibrant colour matrices clamped to their headroom 1.2
      (`addContentHeadroom:` + style 9, as decoded), eight flat regions of the tiles (plates, white symbol,
      Spotlight magnifier and lens, light and dark) sit on L' = L / (1 + 0.27 L) in linear light, on the
      luminance (per channel fits the TintedLight tiles worse: 11-14 against 7-10); rms 0.8, without it 13.2.
      RenderBox's own curve was not read.
    - the car's sRGB-tagged fill components are used as Display P3 components (Spotlight Dark 11.5 -> 8.8).
    - the tint of the Mac's captures is 0,122,255 taken as sRGB; the TintedLight tile plate 0,122,249 needs the mix
      weight 0.9 x saturation to be 1 (saturation is the caller's; `RBColorAdd` mixes with ColorInterpolation 2).
      Decoded since: the caller is IconFoundation's `-[CUINamedIconLayerStack _icrRenderingModeFromAppearanceVariant:
      tintColor:]` (0x197533c1c; variant 2 = tinted, 3 = clear), which calls `+[ICRRenderingMode tintWithRed:green:
      blue:alpha:]` (0x1cfd7cb58) with the tint's CIColor components: the colour is (r, g, b, 1) and the SATURATION
      IS THE TINT'S ALPHA, 1 for an opaque tint. So the weight is 0.9, and the plate is explained by the colour
      space instead: 0,122,255 as Display P3 (RBColorSpace 3) is -59,124,264 in extended sRGB, and mix(0.5 grey,
      that, 0.9) clipped = 0,125,250. On the tiles that reading gives TintedLight 7.6 / 8.5 (the weight-1 reading
      7.4 / 8.3, sRGB tint at weight 0.9: 12.9 / 13.3). The same P3 tint in the tinted dark duotone is worse (13.6 /
      10.2 against 8.3 / 8.2: the Mac's white symbol 24,131,247 has no negative red), so the port keeps the sRGB
      tint there and `check-styles.py` keeps weight 1 for the light plate; unresolved.
    Assumed: Gaussian sigma = RenderBox's blur radius; grey bake = BT.709 luma; IconBrightness = dim when the
    chiclet's brightest stop is <= 0.2, bright when its darkest is >= 0.99; a layer's bounding rect = the box of
    its rendered alpha; gradient stops interpolated on the encoded values. Measured: the side of the shadow ring.
  * NOT decoded / not ported: RenderBox's distance style behind the SDF generator (the port's own Euclidean field
    stands in for it); the second layer path of 0x1cfd6d430 (shouldPreventDarklightCompounding, which draws
    darklights by reference before the contents; the flag is RBProjectVersion-dependent); blurStrength /
    refraction glass of a group (0x1cfd74500; refraction is 0 in every app car, blurStrength is not in the group
    record; Preview's loupe is the icon that shows it, 18.5 on the Cmd-Tab shot); `SimulatedGlassRenderer` /
    `ICRSimulatedGlassChicletLayer` (dimmingStrength 0.22, backdrop blur 0.0065, refraction 0.28 / 0.11); how
    the Dock chooses the size class; hue / saturation / color / luminosity blend modes; the u32 that starts each
    fill record of TLV 0x3fc (0 on Safari's ticks, 1 elsewhere). `iconstack.flat()` (only the fitted Dock rule of
    TintedLight / ClearLight uses it) keeps the canvas gradients and the fitted 0.3 automatic gradient it was
    fitted on.
  * The Dock Trash's glass is not IconRendering's: Dock.app hands `s-trashempty-sdf.png` (384 px RGBA, r =
    distance with 0.5 at the edge, gb = normal) to a CoreAnimation glass background (style 2). Not built;
    `build-trash.py` is unchanged (full Trash against the Dark Dock shot rms 5.5).
- Settings pane tiles as ground truth: they are IconServices stills = IconRendering's mitigated version (above).
  Per style the chiclet is the same on every symbol pane (spread <= 3/255): Dark 31 -> 15 grey (systemDarkGradient
  over 10 % .. 90 %), TintedDark = screen(0.1, tint x (0.15 -> 0)), TintedLight flat 0,122,249, ClearLight 125 (0.5
  through the tone curve), ClearDark 43 (0.17). White symbols: 163,238,255 / 24,131,247 / 246 / 233 (TintedLight /
  TintedDark / ClearLight / ClearDark). The Dock does not draw TintedLight like these tiles (its tile is 0,109,195
  in glass53/...-clear-tinted.png): live glass under the masks instead of the plate.
- `apple-map.txt` (Linux app id or icon name -> macOS icon, ~220 names) is the single source for the shell, the Finder and the `hyprk-apple`
  theme; `apple-map.js` is generated from it (`tools/gen-map.mjs`, tested in `themes/icons/tests`).
- The generic folder (2026-11-11): `system/GenericFolderIcon-512/-128.png` were the OLDER folder (lighter tab, gradient
  the other way): that is what `GenericFolderIcon.icns` still holds on 27.2.1, and so do IconFoundation's `Folder` /
  `FolderDark` iconsets (`IconFoundation.framework/Resources/Assets.car`; against Apple's renders rms 21-23 and 19-21).
  macOS 27 composes folders at run time: CoreTypes' Info.plist declares public.folder with `ISIconPackageIdentifier`
  com.apple.icon-package.folder, `_ISIconRecipe` class ISEmbossedFolder and `ISLayers` back-flap (conforms to
  icon-package-attribute.tintable), paper-sheet (optional), front-flap (embossable, tintable); special folders add
  `ISFolderIconConfiguration` { ISSymbolName } (Documents `document`, Downloads `arrow.down.circle`, Applications
  `appstore`, Desktop `menubar.dock.rectangle`, Pictures `photo`, Music `music`, Movies `film`, Home `house.fill`,
  Library `building.columns.fill`, Developer `hammer.fill`, Public `figure.walk.diamond`, ...). The art is in CoreTypes'
  `Assets.car`: `FolderComponent_BackFlap` / `_PaperSheet` / `_FrontFlap`, image_16 .. image_512 at 1x and 2x (256 px
  and up deepmap2, smaller ones in packed atlases car.py does not decode). Colour space at extraction: the flaps' CSI
  colour space id is 1 = sRGB (the numbering of COLR records), the paper sheet 2 = Gray Gamma 2.2; the new PNGs carry
  an sRGB chunk. `tools/build-folder.py <os root>` writes back flap + front flap (the empty generic folder), -512 from
  the 512 px renditions as they are, -128 from the 256 px ones. Against Apple's own sRGB renders
  (`reference/re/27.2.1/live/finder/icons-rendered/folder-generic@*`, light and dark are identical files), body rms,
  old file -> new: 16 pt 22.6 -> 6.9, 18 pt 20.7 -> 7.0, 32 pt 23.0 -> 6.0, 48 pt 22.8 -> 3.9, 64 pt 23.9 -> 2.8
  (-128) / 3.7 (-512), 77 pt 24.4 -> 2.1 / 2.9, with NO tint: a least-squares gain per channel is 1.00-1.05 at the top
  and 0.96-1.00 at the bottom.
- Embossed and tinted folders (2026-11-11, decoded from the 27.2.1 dyld cache; addresses and the full filter chain
  are in the header of `tools/build-folder.py` and in `finder/src/sysicons.cpp`):
  * Layer tree, `-[ISFolderRecipe layerTreeForSize:scale:]` 0x1975b99d4: back flap, paper sheet, front flap, an
    emoji text layer, an "Emboss Layer" (ISEmbossedEffect) with the symbol, and an ISDropShaddowEffect on the root
    (offset (0, -s / 2), blur 2 s, s = size / 32, black 0.5). `-[ISEmbossedFolder layerTreeForSize:scale:]`
    0x1975b8f6c is the older one-bitmap path (IconFoundation's `Folder` asset + emboss).
  * Tint: `-[OKLChColor adjustForFolder]` 0x1975b98e0 on the tint colour (L += 0.23 (1 - L), L above the hue's cusp
    is pulled to cusp + 0.4 (L - cusp), C = min(1.3 C, the sRGB gamut edge)), then CIColorMonochrome
    (`ISMonochromeTintEffect` 0x1975e2114) on the back flap and the front flap, in linear sRGB:
    luma < 0.5 ? 2 luma colour : max(colour, 1 - 2 (1 - luma)(1 - colour)). A tag's tint is its system colour
    (`+[IFColor systemColorFromTagColorIndex:]` 0x1975e73ac: tag 1..7 = gray, green, purple, blue, yellow, red,
    orange). `+[IFColor folderColor]` 0x1975b8e84 is CUIDesignLibrary colour 15 and only colours the emboss
    symbol layer, whose colour the Solarium emboss filter does not use (only its alpha). The Finder ports the tint
    (`finder/src/sysicons.cpp`); against the Mac's orange-tagged folder crop (converted from Display P3) the front
    flap is within 2 levels (rms 2.9 at 64 pt, 3.2 at 16 pt) with systemOrange #FF8D28. The crop also shows the
    white paper sheet between the flaps; when IconServices adds it was not read, so it is not drawn.
  * Emboss: the symbol (ISFolderIconConfiguration.ISSymbolName, medium scale, regular weight, font size 180 at 512)
    centred on hintedBadgeRect (144, 110.5, 224, 224 at 512), then `ISEmbossedEffect` 0x1975df7a0: inside the glyph
    the folder keeps 0.7 of its linear light (Apple's renders: 0.693-0.700), plus a 2 px inner shadow and a 2 px
    white rim below. `tools/build-folder.py` builds the 17 special folders this way under their old names
    (Applications `appstore`, Burnable `burn`, Desktop `menubar.dock.rectangle`, Developer `hammer.fill`, Documents
    `document`, Downloads `arrow.down.circle`, Group `person.2.fill`, Home `house.fill`, Library
    `building.columns.fill`, Movie `film`, Music `music`, Pictures `photo`, Public `figure.walk.diamond`,
    ServerApplications `appstore.circle.fill`, Sites `globe`, Users `person.crop.circle`, Utilities
    `wrench.and.screwdriver.fill`; glyphs from CoreGlyphs / CoreGlyphsPrivate through `bvg.py`, rasterised by
    rsvg-convert). Against Apple's renders through the Finder's provider, body rms old art -> new at 16 / 18 / 32 /
    48 / 64 / 77 pt: Documents 17.5 17.3 18.8 17.3 18.0 17.3 -> 10.7 9.6 7.7 2.8 2.9 3.4, Applications 17.5 17.4
    18.9 17.2 17.8 17.2 -> 11.2 7.7 7.5 2.4 2.4 3.3; the other 15 have no Apple render or Mac crop in the repo.
    Glyph box at 77 pt: Documents 44.5 x 56.5 px for Apple's 44.5 x 56.7, Applications 55.9 x 49.3 for 56.1 x 49.5.
  * Assumed or not built: the blur inside CoreUI's glow / shadow filters (taken as a Gaussian, sigma = radius);
    the rim is drawn at the file's size (512 / 128 px), Apple draws it at the rendered size; the drop shadow;
    `SmartFolderIcon` (ISEmbossedSmartFolder), `SystemFolderIcon` (ISOverlayEmbossedFolder, bitmap `macOSText`)
    and `OpenFolderIcon` are still the older `.icns` art; dark-appearance tint colours not checked.
  The 34 rebuilt PNGs are 3.0 MB smaller than the old ones (system/ 23.1 -> 20.1 MB).
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

## settings/assets/ and shell/assets/

- `settings/assets/glass-preview/{apple-park,architecture,pond,rainbow}.jpg`: the four photos of the Appearance pane's
  Liquid Glass preview, from `AppearancePreferencesFramework.framework` 27.2.1 `Assets.car` (GlassStylePreviewView),
  804 px wide JPEGs, Display P3 converted to sRGB (commit 6bb37d8).
- `settings/controls/sfpaths.js`: SF Symbols outlines used by Settings only, decoded from SF Pro: the preview's
  `square.and.arrow.up`, `ellipsis`, `square.on.square`, `magnifyingglass`, `capsule.on.rectangle.liquid.glass`,
  `capsule.on.rectangle.fill`, and `chevron.backward` / `chevron.forward` of the toolbar (commit 7ee8a39). Not registered in the theme's
  symbol set under `themes/icons/`: that folder was being rebuilt when this was written.
- `shell/assets/sRGB.icc`: not Apple's. LittleCMS's built-in sRGB profile (588 bytes, written with PIL
  `ImageCms.createProfile("sRGB")`), used by `shell/scripts/wallpaper.sh` to convert profiled wallpapers to sRGB.

## What failed or was skipped (summary)

`.madesktop` wallpapers, arrow cursor from CursorAsset, Xcursor packaging, static SF font instances.
