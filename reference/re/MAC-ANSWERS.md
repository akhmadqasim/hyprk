# Answers from the Mac session (macOS 27.2.1, 26B131, MacBook Air M2)

Answers to `MAC-REQUESTS.md` (PC) and the relay questions. One section per id. Measured on the user's account, not a
clean one: Dark appearance, Multicolour accent, icon & widget style "Dark" (`AppleIconAppearanceTheme = RegularDark`),
Liquid Glass slider `NSGlassTintAmount = 0.5`, built-in display at 1710 x 1107 pt (3420 x 2214 px, notch, menu bar 34 pt),
Dock `tilesize 33`, `magnification 0`. Settings that were changed for a test are named in that test and were restored.

## Q9 Which parts of the toolbar and menu bar are glass (relay #9)

Method: `tools/probe/toolbar.swift` builds a standard AppKit window (unified NSToolbar with item groups, NSSearchToolbarItem,
sidebar NSSplitViewItem, scroll view) and lists every backdrop / glass / material layer with its filter inputs
(`27.2.1/live/toolbar/toolbar-{unified,compact}-{light,dark}.json`, picture `screens/27.2.1/probe-toolbar-*.png`).
Real Finder and System Settings look the same (`screens/27.2.1/{finder,settings}-toolbar-{light,dark}.png`).
Other processes (Finder, WindowServer menu bar) cannot be dumped, so for them the answer is from pixels.

### 1. Menu bar
- No background of its own. The bar is a WindowServer window (`Menubar`, level 24, 0,0,1710,34) that shows the
  **desktop picture**, never the windows under it: a borderless test window placed at y 0 was covered by the bar,
  which still showed the wallpaper. With a solid wallpaper (Electric Blue) the bar pixels equal the desktop
  pixels exactly (69,83,206 in both, std 0): no tint, no blur.
- Over a bright wallpaper there is a top-of-screen legibility dimming that is not tied to the bar edge: white
  wallpaper reads 176 at y 2 pt, 189 at 30 pt, 193 at the bar edge (34 pt), 216 at 50 pt, 243 at 70 pt and 255 from
  about 100 pt down. Black stays 0 and saturated red (255,59,48) stays (235,78,61) all the way down, so it acts on
  bright pixels only (a highlight clamp / darken gradient, not a plain black overlay). Same in light and dark mode
  (`screens/27.2.1/menubar-top-gradient-checker.png`, wallpaper = 12 pt checker + bands).
- Menu bar text colour follows the wallpaper, not the system appearance: white over that checker in both light and
  dark mode.
- Open-menu title highlight: a capsule, y 6 to 29 pt (23 pt tall, in the 34 pt bar), width = title plus padding
  (padding not measured yet), heavily blurred and brightened backdrop: over the 12 pt checker it is a near-uniform grey (mean 113, std
  10 to 15; the checker under it averages about 89), over solid blue it is (90,105,230) on (69,83,206), with a faint
  shadow below (66,79,196 just under the pill). Same in light and dark. It is a blur material (likely glass), not a
  solid colour; the layer cannot be dumped from another process. Pictures: `menubar-pill-{checker,solid}-*.png`.
- Maximised (zoomed) window: it stays below the bar, so the bar still shows the wallpaper. Full-screen: not measured
  yet (the bar hides there).

### 2. Window toolbar (Finder, System Settings)
- The toolbar / titlebar strip has **no glass and no fill**. `NSTitlebarView` holds only an empty `CABackdropLayer`
  (no filters, used for grouping). What you see behind the buttons is the window content.
- Under the strip, each scroll view has a scroll edge effect (`NSScrollPocket`): backdrops with `variableBlur` +
  `colorMatrix` over the top 52 pt of the content (same height as the toolbar). It only shows when content scrolls
  under the toolbar.
- Each toolbar item group sits on a capsule platter: `NSToolbarPlatterView > NSGlassEffectView`, `_variant` 0 =
  regular glass. Height 36 pt, radius 18 (full capsule):
  - single button (sidebar toggle, collapsed search): 36 x 36 circle;
  - back/forward: one 74 x 36 capsule, 1 pt divider at the middle (20 pt tall);
  - view switcher (4 segments): one 158 x 36 capsule, the selected segment is an inner 33.5 x 28 pill, radius 14;
  - a run of plain buttons (group, share, tags, action): they share **one** capsule (189 x 36 for 4 buttons).
- All platters right of the sidebar are drawn by a **single** `NSGlassContainerView`: one `glassBackground` backdrop
  spanning all of them (x 420..972 in the probe) with the shapes merged as an SDF. The sidebar-toggle platter has
  its own container.
- Glass recipe at this size (36 pt): face white 1.03, black 0.4, saturation 1.2; **blur opacities 0, 0, 0.5, 1**
  (so almost no blur of the content behind), inner refraction height 9 amount -18, outer refraction 16 / 16 at
  opacity 0.6, ring shadow 0.06 (offset 8, stroke 4, blur 5), drop shadow opacity 0.04, radius 4, offset (0, 8).
  Over flat window content this reads as a slightly lifted flat capsule with a light rim, which is why it looks
  "not glass".
- Title: plain text in the toolbar (Finder "Applications", Settings "Appearance"), bold, left of the item groups.

### 3. Sidebar (Finder, System Settings)
- `NSGlassEffectView` `_variant` 18, full height (from y 0, under the titlebar) and flush with the window's left,
  top and bottom edges: **not** a floating inset panel, no own corner radius (the window's corners clip it). The
  traffic lights and the sidebar toggle sit on it.
- Recipe: blur distance -72 with opacities 0.67, 0.33, 0.5, 1, bleed opacity 0.42 (blur 50), inner refraction 20 /
  -60 but refraction opacity 0, no drop shadow, no ring shadow. Visually a flat lighter (light) / lighter grey
  (dark) panel with a hairline on its right edge.

## Questions for the PC
- None yet.

## R2 Motion (60 fps screen recordings, analysed per frame; 1 frame = 16.7 ms)

Recorded with `ffmpeg -f avfoundation -framerate 60` (about 58 fps effective, real frame timestamps used), analysed with
crop-and-diff scripts. Raw videos were deleted after measuring (they showed personal notifications); numbers only.

### Dock
- `defaults read com.apple.dock` on this account: magnification 0, largesize 16, tilesize 33, mineffect genie,
  launchanim 1, minimize-to-application 1, show-recents 1, show-process-indicators 1, autohide 0. Not a clean account.
  The Dock's factory `default.plist` (Dock.app/Contents/Resources) only sets persistent-apps / persistent-others /
  version, so every other key is the built-in default when absent; magnification absent = off (the PC report
  "magnification animated by default" is wrong for macOS).
- Launch bounce (slow-launching test app, `BounceProbe`):
  - period 0.70 s per bounce (both tile sizes), constant for the whole launch;
  - height 11 pt at tilesize 33 (icon art 25.5 pt), 18 pt at tilesize 64 (icon art 50.5 pt);
  - shape per bounce (phase 0..1, height as a fraction of the max): 0.02 0.09 | 0.07 0.30 | 0.12 0.43 | 0.17 0.60 |
    0.21 0.69 | 0.26 0.81 | 0.31 0.90 | 0.36 0.95 | 0.40..0.60 1.00 (holds at the top about 0.14 s) | 0.64 0.95 |
    0.69 0.87 | 0.74 0.77 | 0.79 0.70 | 0.83 0.57 | 0.88 0.43 | 0.93 0.26 | 0.98 0.12. Rise and fall are mirror images;
    the icon touches the ground for one frame only. Best simple fit: h = H * (sin(pi u))^0.7 (RMS 0.6 pt), a plain
    parabola 4u(1-u) gives 0.5 pt RMS but no flat top.
  - it keeps bouncing while the app launches; when launching ends it finishes the bounce in progress and stays
    down (no extra settle). Bounce count = launch time / 0.7 s.
  - a new (not pinned) app tile is inserted already in the air: its slot grows from 0 to full width in about
    0.25 s while the first bounce runs. On quit the tile shrinks out in about 0.15 s.
- Hover label (magnification off, tile 64): appears in the frame after the pointer reaches the icon (no delay, no
  fade-in); moving to the next icon swaps it in one frame; on leaving the Dock it fades out in about 0.23 s
  (ease-in-out).
- Magnification (switched on for the test: tilesize 64, largesize 128, then restored): from the AX frames of every
  tile at 81 pointer positions. Size against the distance d between the pointer and the tile's *unmagnified*
  centre: 128 at d 0, 127.6 at 15, 125.7 at 35, 122.3 at 55, 117.7 at 75, 111.6 at 95, 104.5 at 115, 96.5 at 135,
  87.6 at 155, 78.3 at 175, 70.8 at 195, 66.0 at 215, 64.1 at 235, 64 beyond. Fit:
  size = base + (large - base) * (1 - (d / 222)^2)^1.5 for d < 222 pt (RMS 0.4 pt). Only measured for 64 -> 128.
  Entering / leaving the Dock: the magnification grows in about 0.12 s (7 frames, ease-in-out) and collapses in
  about 0.12 s the same way; the Dock widens from the centre.

### Menu bar, moving across titles with a menu open (Finder)
- The highlight pill jumps to the new title in one frame as soon as the pointer crosses into the title's frame:
  no slide. The pill spans the title's AX frame (File: x 104..146, 42 pt; Edit: 145..190).
- The open menu is swapped 3 to 4 frames (50 to 67 ms) after the pill moves, in one frame: the old menu disappears and
  the new one appears complete. No crossfade, no fade-out of the old menu.
- First open: complete in one frame. Close with Escape: fades out in about 0.2 s (as measured earlier).
- Fast sweep across Go, Window, Help: every title switches the same way; no intermediate states.

### Control Center, Notification Center, Spotlight
- Control Center open (click on its menu bar icon): fades in, no scale and no slide (tiles are in their final place
  from the first frame). Progress (share of the final change): 0.16, 0.29, 0.40, 0.51, 0.61, 0.71, 0.76, 0.81, 0.86,
  0.89, 0.91, 0.94 at 17 ms steps, 1.0 at about 0.3 s: an ease-out with most of it in the first 0.15 s. The tile
  glass (and the white Sensibo tile) fills in during the same fade.
- Control Center close: fades out in about 0.17 to 0.2 s.
- Notification Center open (click on the clock): slides in from the right screen edge. Covered share per frame:
  0.11, 0.14, 0.29, 0.43, 0.54, 0.64, 0.71, 0.78, 0.83, 0.87, 0.90, 0.92, 0.94, 0.95, 0.96, 0.98, 0.99 (17 ms steps):
  about 0.3 s to 99 %, ease-out (spring-like, no visible overshoot).
- Notification Center close: slides out to the right in about 0.15 s, accelerating (0.92, 0.80, 0.66, 0.50, 0.41,
  0.28, 0.20, 0.14, 0.11).
- Spotlight (Cmd-Space) open: the bar appears complete in one frame at about 1.05 x its final width, then shrinks
  to 1.0 within 5 frames (about 0.08 s). No fade-in. 27.2.1 bar: dark capsule with "Search or Ask" and a mic
  glyph, also in light mode (measured with icon style Dark; see note at the top).
- Spotlight close (Escape): fades out with a blur and a slight growth in 3 frames (about 0.05 s).

### Windows (opening with Cmd-N / open, closing with Cmd-W)
- Open: Finder, TextEdit, Safari, Terminal: the window is complete in one frame (no scale, no fade).
- Close: Finder, TextEdit, Terminal fade out in about 0.1 s; alpha per frame 1, 0.71, 0.44, 0.27, 0.16, 0.09, 0.05,
  0.03 (TextEdit; Terminal 0.59, 0.35, 0.20, 0.11, 0.06, 0.04; Finder 0.81, 0.31, 0.18, -, 0.06). That is about
  x0.6 per frame (exponential, time constant about 33 ms). A slight blur is visible on Finder; any scale is too
  small to resolve. Safari: gone in one frame (instant).
- So the PC's "fade+blur 0.1 s" is right for most document windows; Safari is instant.

### Not measured yet
Mission Control, Cmd-Tab, Apps, app launch window, minimise/zoom/full screen, control press states.

## R3b SF Symbols and Settings pane icons

Measured on the Mac: macOS 27.2.1 (26B131), MacBook Air M2, 2026-11-10. No GUI app was opened and no defaults were written.

Data:
- `themes/icons/sf-symbols/svg/` holds 276 SVGs: 82 distinct symbols × regular/medium/semibold, plus 30 variant files.
- `themes/icons/sf-symbols/names.json` holds the mapping and per-file metrics.
- `themes/icons/settings/<pane id>@<64|128>-<light|dark>.png` holds 92 PNGs: 23 panes × 2 sizes × 2 appearances.
- `panes.json`, `siri.png` and `spotlight.png` were not created or touched.

### Method: SF Symbols to SVG

1. **Choosing the real symbol.** Each PC name was mapped to the symbol the system surface references. Evidence, strongest first:
   - The Finder sidebar symbols come from `UTTypeSymbolName` in `/System/Library/CoreServices/CoreTypes.bundle/Contents/Info.plist`. Examples: `com.apple.applications-folder` = `appstore`, `com.apple.desktop-folder` = `menubar.dock.rectangle`, `com.apple.airdrop` = `airdrop`.
   - Symbol-name strings in `Finder`, `ControlCenter`, `SpotlightUIInternal`/`SearchUI` (read via `dyld_info -section __TEXT __cstring`), matched against `name_availability.plist` of CoreGlyphs and CoreGlyphsPrivate.
   - Fill or outline follows the PC drawing (traced from 27.2 screenshots) when nothing else decides it.
   - Swift string literals of 15 bytes or less are stored inline in code. So a name missing from `strings` output is not evidence.
2. **Checking the name exists.** Public names were checked with `NSImage(systemSymbolName:accessibilityDescription:)` (all non-nil).
   - These 7 names return nil there because they are private symbols: `airdrop appstore bluetooth appearance photos dots.below.lock.fill trackpad.fill`.
   - Those 7 exist in `CoreGlyphsPrivate.bundle` and render through `+[NSImage imageWithPrivateSystemSymbolName:accessibilityDescription:]`.
   - They are flagged `"private": true` in names.json.
3. **Rendering.** Each file uses `NSImage.SymbolConfiguration(pointSize: 32, weight:, scale: .medium)` and the `NSSymbolImageRep`'s CoreUI `CUINamedVectorGlyph`.
   - Its vector layers (`monochromeLayers` / `hierarchicalLayers` / `multicolorLayers`, each a `CGPath` with opacity and eraser flag) are filled into a `CGContext(PDF)`.
   - The page box is `NSImage.size`. The glyph is placed at the rep's `imageRect` exactly as AppKit does.
   - Each PDF is then converted with `pdftocairo -svg`.
   - Drawing the `NSImage` straight into a PDF context does not work: AppKit embeds a bitmap (`<image>` + `<mask>`). That is why the layers were filled by hand.
4. **Verification of every file.**
   - All 276 SVGs contain only `<path>` elements: no `<image>`, no `<mask>`.
   - Every viewBox equals the image size.
   - Every PDF was rasterised at 2x and compared with AppKit's own 2x render of the same `NSImage` and config (aqua appearance).
   - Worst mean alpha difference is 0.89/255. No pixel differs by more than 96/255.
   - Layer rules taken from AppKit and checked this way:
     - Hierarchical opacities are primary 1.0, secondary 0.5, tertiary 0.3.
     - Variable-value layers that are not reached are drawn at 0.3, and value 0 turns every variable layer off.
     - An eraser layer clears what is beneath it and is itself drawn only when its opacity is above 0.
     - Multicolor names are resolved as NSColor in aqua: `tintColor` → black, `labelColor` → black at 0.847, `systemGreenColor` → rgb(52,199,89), and so on.
5. **Variants rendered** (only where a system surface plausibly uses them):
   - `wifi.<w>.var-0|var-20|var-50.svg`: the menu bar signal levels, with 0 / 1 / 2 parts lit. The plain file is everything lit. All wifi layers are primary, so hierarchical equals monochrome and was not rendered.
   - `speaker.wave.3.fill.<w>.var-0|20|50.svg`: menu bar volume levels.
   - `.hierarchical`: for `speaker.wave.3.fill` and `speaker.wave.2.fill`, and for `display`. AppKit's default rendering of `display` is hierarchical (glyph `preferredRenderingMode` = 3; the screen is filled at 0.3).
   - `battery.100percent.bolt.<w>.multicolor.svg`: green fill.
   - Not rendered:
     - Folder multicolor: the Finder sidebar draws its symbols monochrome, tinted with the accent colour (likely; not measured).
     - Hierarchical files for the Settings symbols: in the IconServices tile renders below, every symbol is drawn plain white.
   - In the hierarchical and variable SVGs, each path keeps its own `fill-opacity` (0.5 / 0.3). In the multicolor SVGs the label-coloured layer keeps `fill-opacity="0.8471"`.

### Mapping (PC name → real symbol)
Confidence:
- sure = read from a system plist or the exact surface.
- likely = string referenced by the binary that draws the surface, plus a visual match.
- guess = visual match only.

The extra files listed are rendered too.

Shell:

| PC name | real symbol | conf. | basis / extras |
|---|---|---|---|
| airdrop | airdrop (private) | likely | ControlCenter references it; same as Finder AirDrop |
| appstore | appstore (private) | likely | App Store "A"; the same glyph is the Applications folder symbol (CoreTypes) |
| backward / forward | backward.fill / forward.fill | likely | Now Playing, filled like the PC drawing |
| play / pause | play.fill / pause.fill | likely | Now Playing |
| battery | battery.100percent | likely | ControlCenter references battery.100percent and battery.25percent. Extras: battery.0percent (empty outline to draw your own level), battery.100percent.bolt (charging, also multicolor) |
| bell | bell.fill | guess | only the "Show Notification Center" action; extra: bell |
| bluetooth | bluetooth (private) | sure | ControlCenter; also graphic-icon.bluetooth ISSymbolName |
| bolt | bolt.fill | likely | SpotlightUIInternal references bolt.fill (Actions) |
| calendar | calendar | guess | no current use in shell/ |
| camera | camera | guess | screenshot actions |
| checkmark | checkmark | likely | menu check mark |
| chevron.down | chevron.down | likely | |
| chevron.right | chevron.forward | likely | byte-identical SVG to chevron.right in left-to-right layout; Finder references chevron.forward |
| clipboard | clipboard | guess | Spotlight Clipboard mode |
| controlcenter | switch.2 | likely | same as ControlCenterSettings.appex ISSymbolName |
| display | display (+hierarchical) | likely | ControlCenter references it; AppKit default rendering is hierarchical |
| doc | doc | likely | alias of `document` (byte-identical); CoreTypes uses `doc` |
| ellipsis | ellipsis | likely | Apps header |
| equal | equal | guess | calculator row |
| folder | folder.fill | guess | extra: folder (outline) |
| gear | gear | guess | System Settings General uses gear |
| keyboard | keyboard | guess | |
| lock | lock.fill | likely | Lock Screen action |
| magnifyingglass | magnifyingglass | sure | menu bar Spotlight item |
| moon | moon.fill | likely | Focus / Sleep; Settings Focus uses moon.fill |
| person | person.fill | guess | |
| photo | photo | likely | clipboard image rows |
| power | power | likely | |
| screen.mirror | rectangle.on.rectangle | likely | ControlCenter references rectangle.on.rectangle(.slash); the PC's screen-with-triangle is the old AirPlay glyph |
| speaker | speaker.wave.2.fill (+hierarchical) | likely | ControlCenter references speaker.wave.2.fill and speaker.wave.3.fill. Extra: speaker.wave.3.fill (menu bar, var + hierarchical) |
| speaker.slash | speaker.slash.fill | likely | ControlCenter |
| square.grid | square.grid.2x2.fill | guess | extras: square.grid.2x2; rectangle.3.group = the real Control Center Stage Manager glyph (ControlCenter reference) |
| sun | sun.max.fill | likely | CC brightness; Settings Displays tile |
| terminal | apple.terminal | guess | extra: terminal (older, nearly identical) |
| trash | trash | likely | |
| wifi | wifi (+var) | sure | ControlCenter; graphic-icon.wifi |
| wifi.slash | wifi.slash | likely | |
| xmark | xmark | likely | |

Finder:

| PC name | real symbol | conf. | basis / extras |
|---|---|---|---|
| airdrop | airdrop (private) | sure | CoreTypes com.apple.airdrop UTTypeSymbolName |
| applications | appstore (private) | sure | CoreTypes com.apple.applications-folder |
| arrow.up.down | arrow.up.arrow.down | likely | Finder references it |
| chevron.down | chevron.down | likely | |
| chevron.left / chevron.right | chevron.backward / chevron.forward | likely | Finder references these; identical to left/right in left-to-right layout |
| chevron.small.right | chevron.forward | guess | there is no "small" symbol; scale it down |
| clock | clock | sure | CoreTypes recent-items |
| desktop | menubar.dock.rectangle | sure | CoreTypes desktop-folder |
| doc | doc | sure | CoreTypes documents-folder |
| download | arrow.down.circle | sure | CoreTypes downloads-folder |
| drive | internaldrive | likely | CoreTypes storage-internal / public.volume. Extra: externaldrive (storage-external / removable) |
| eject | eject.fill | guess | Finder references eject and eject.fill; extra: eject |
| ellipsis | ellipsis | guess | Finder references ellipsis and ellipsis.circle; extra: ellipsis.circle |
| eye | eye | likely | Quick Look |
| group | square.grid.3x1.below.line.grid.1x2 | likely | Finder references it |
| icloud | icloud | sure | CoreTypes com.apple.iCloud |
| magnifyingglass | magnifyingglass | sure | |
| minus / plus | minus / plus | likely | name match, not used yet |
| network | network | sure | CoreTypes network-neighborhood |
| share | square.and.arrow.up | sure | Finder references it |
| shared | folder.and.person | likely | Finder references it; glyph matches the PC drawing |
| tag | tag | sure | |
| trash | trash | likely | |
| view.icons / list / columns / gallery | square.grid.2x2 / list.bullet / rectangle.split.3x1 / squares.below.rectangle | sure / likely / likely / likely | all referenced by Finder |
| xmark | xmark | likely | |
| xmark.circle | xmark.circle.fill | likely | search-field clear button |

Settings (sure: read from the pane extension Info.plist `CFBundleIcons.ISGraphicIconConfiguration`, or the CoreTypes `com.apple.graphic-icon.*` UTI it points to):

| symbol | panes |
|---|---|
| wifi, network | wifi, network |
| bluetooth | bluetooth (private) |
| network.badge.shield.half.filled | vpn |
| battery.100 | battery (see below) |
| bolt.fill | energy |
| gear | general |
| accessibility | accessibility |
| appearance | appearance (private; legacy alias of appearance.darkmode) |
| switch.2 | controlcenter |
| menubar.dock.rectangle | dock |
| sun.max.fill | displays |
| photos | wallpaper (private; alias of apple.photos) |
| bell.badge.fill | notifications |
| speaker.wave.3.fill | sound |
| moon.fill | focus |
| dots.below.lock.fill | lockscreen (private; alias of lock.dots.fill) |
| hand.raised.fill | privacy |
| keyboard.fill | keyboard |
| magicmouse.fill | mouse |
| trackpad.fill | trackpad (private) |

**Correction to panes.json:** the Battery pane is not always bolt.fill. `PowerPreferences.appex` has two `representations`:
- `powersource.battery == YES` (MacBooks) uses `com.apple.graphic-icon.battery` = **battery.100** on green.
- Without a battery it uses `com.apple.graphic-icon.energy` = bolt.fill.

So hyprk `battery` is rendered with battery.100 and `energy` with bolt.fill.

### Method: Settings sidebar icons
- **Source of each icon.**
  - Most panes: IconServices `ISBundleIcon(initWithBundleURL:)` on the pane's `/System/Library/ExtensionKit/Extensions/*.appex` (this honours `ISGraphicIconConfiguration` / `ISTypeIdentifier`).
  - battery and energy: `ISTypeIcon(initWithType:)` on `com.apple.graphic-icon.battery` / `.energy`, because PowerPreferences' own bundle icon is the generic extension icon.
  - All are rendered through `ISImageDescriptor` (`prepareImageForDescriptor:`) using dlopen and the ObjC runtime.
- **Sizes.**
  - 64 px = 32 pt @2x (native rendition).
  - 128 px = the native 128 pt @1x rendition.
  - IconServices has no 64 pt size. A 64pt@2x descriptor snaps to a 256 px tile, which has a proportionally smaller glyph. AppKit itself picks the 128 px rendition when drawing at 64 pt @2x.
  - Both sizes are byte-identical to `NSWorkspace.shared.icon(forFile:)` / `icon(for: UTType)` drawn at 32 pt and 64 pt @2x. All 46 dark PNGs were checked against NSWorkspace (max channel difference 2).
- **Light and dark.**
  - light = descriptor appearance 0; dark = descriptor appearance 1. All 23 pairs differ.
  - Light is the coloured tile with a white symbol. Dark is a black tile with the symbol in the tile colour.
  - Siri and Spotlight come out as their real asset-catalog app icons, with their own dark variants.
  - Why the appearance is set on the descriptor: icon tinting follows the global icon theme (SkyLight `SLSIconAppearanceConfiguration`), not `NSAppearance.performAsCurrentDrawingAppearance`. This Mac is set to `AppleIconAppearanceTheme = RegularDark` + Dark Mode, so NSWorkspace gave the dark tile for both appearances.
  - Theme → descriptor mapping:
    - 0 = Regular Automatic (follows light/dark mode)
    - 1 = Regular Light
    - 2 = Regular Dark
    - 3–5 = Tinted (automatic / light / dark)
    - 6–8 = Clear (automatic / light / dark)
- **Not measured:**
  - Which of these themes the Appearance pane's "Default" icon style writes, i.e. whether an untouched Mac in Dark Mode shows the light or the dark tile. Finding out would have needed a defaults change.
  - Tinted and Clear tiles (not rendered).
  - A comparison with a live sidebar capture, and the size the sidebar actually draws at (no GUI opened).
- **Panes that could not be rendered:** none. All 23 rendered through IconServices.

### Not done and why
- `distro`: skipped as asked.
- Finder `zoom`: the two-triangle glyph is AppKit's window full-screen/zoom button artwork. No name in CoreGlyphs or CoreGlyphsPrivate matches it, so no SVG.
- The surface assignments marked likely or guess were not checked against the live menu bar, Control Center or Spotlight (no GUI). In particular these are unverified:
  - Spotlight mode glyphs: bolt.fill, clipboard, square.grid.2x2.fill.
  - Fill versus outline for the shell action glyphs.
- Only 32 pt was rendered, in regular/medium/semibold. Other point sizes are a linear scale. Checked for wifi: the alignment rect at 16 pt is exactly half of 32 pt; the canvas rounding differs by up to 0.5 pt.

### How to use the SVG metrics (names.json → `files`)
All values are in points at `pointSize` 32 and in SVG coordinates (y down). The viewBox is `0 0 size[0] size[1]`: the symbol image canvas AppKit uses, including the symbol's built-in side margins.

- `baselineY`: the text baseline inside the viewBox. `capHeight`: 22.5 at 32 pt, the SF Pro cap height. `alignmentRect`: `[0, baselineY - capHeight, advance, capHeight]`; AppKit aligns this rect to text.
- `glyphRect`: where AppKit draws the glyph. It is pixel-snapped at 2x and is close to the ink bounds, so use it for optical centring in buttons.
- **Placing a glyph next to text of font size F:**
  1. Scale by `s = F / 32`.
  2. Put the SVG top at `baseline - baselineY*s` and its left at the pen x.
  3. Advance by `alignmentRect[2]*s`.
- **Centring on the cap height:** put `baselineY - capHeight/2` on the text's cap-centre line.
- Variant files (.hierarchical / .multicolor / .var-N) have exactly the same size and baseline as the plain file of the same symbol and weight.
- `symbols.<pc name>` gives:
  - the real `symbol`, `surface` and `surfaces`, `confidence` (plus `confidenceBySurface`), `private`, and `variants` (file list);
  - `extras` with their files, and a `note`;
  - `panes` for Settings entries.

Tools: the scratch scripts `sfrender.swift`, `gen.py` and `paneicons.swift` live on the Mac only, not in the repo. They can be added if the PC wants to re-run.
