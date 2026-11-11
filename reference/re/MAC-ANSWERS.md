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

### Mission Control, Cmd-Tab, Apps, minimise, zoom, full screen (progress = share of the total pixel change, 17 ms steps)
- Mission Control enter (`open -a "Mission Control"`; a synthetic Ctrl-Up did not trigger it): about 0.38 s,
  ease-out: 0.05, 0.15, 0.25, 0.37, 0.46, 0.54, 0.60, 0.67, 0.73, 0.78, 0.82, 0.84, 0.86, 0.88, 0.91, 0.93, 0.94,
  0.95, 0.96, 0.98, 1.0. Windows move and scale to a non-overlapping layout, desktop widgets fade out, the menu bar
  and Dock go away, the Spaces bar appears at the top (current Desktop as a small labelled pill, "+" at the right).
  The wallpaper is not visibly dimmed or blurred. Exit: about 0.33 s, same ease-out (0.21, 0.34, 0.47, 0.57, 0.65,
  0.72, 0.77, 0.82, 0.86, 0.89, 0.91, 0.93, 0.94, 0.96, 0.97, 0.98, 0.99).
- Cmd-Tab: the switcher appears complete in one frame (no fade or scale); on releasing Cmd it disappears in about
  0.1 s (6 frames).
- Apps (Dock "Apps" / `open -a Apps`): on 27.2.1 it is an ordinary window titled "Applications" with a category bar
  and an icon grid, not a full-screen Launchpad. It appears in one frame and fills its icons over about 0.5 s; Escape
  closes it in one frame. Layout details still to be measured (Q-dock-23..26).
- Minimise (Cmd-M, `minimize-to-application = 1`, small TextEdit window): about 0.22 s into the app's Dock icon,
  genie shape (progress not monotonic). Restore by clicking the Dock icon: about 0.22 s, slow start then fast:
  0.06, 0.09, 0.17, 0.28, 0.37, 0.45, 0.55, 0.72, 0.85, 0.95, 0.99.
- Zoom (Window > Zoom): 0.33 s, symmetric ease-in-out: 0.01, 0.01, 0.03, 0.05, 0.07, 0.10, 0.14, 0.20, 0.26, 0.33,
  0.41, 0.49, 0.58, 0.69, 0.79, 0.87, 0.93, 0.98, 1.0. Unzoom 0.33 s, ease-out from the start: 0.01, 0.05, 0.11,
  0.18, 0.28, 0.38, 0.48, 0.56, 0.65, 0.71, 0.77, 0.83, 0.88, 0.92, 0.94, 0.96, 0.98, 0.99, 1.0.
- Full screen enter (Ctrl-Cmd-F): about 0.42 s. The window grows to the screen while the desktop slides out to the
  left and a black Space slides in from the right: 0.01, 0.03, 0.07, 0.14, 0.24, 0.33, 0.45, 0.59, 0.67, 0.72, 0.77,
  0.81, 0.84, 0.87, 0.89, 0.91, 0.93, 0.94, 0.95, 0.96, 0.97, 0.98, 0.99. Exit: about 0.5 s in two steps (first
  0.15 s to 0.47, a 0.15 s hold, then the rest over 0.3 s).

### Not measured yet
App launch window from a Dock click, control press states (switch, checkbox, segmented, slider).

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

## HUD volume and brightness (relay #18, #19)

Measured with synthetic media keys (NX system-defined events) and 60 fps recordings of the top-right corner;
pictures `screens/27.2.1/hud-{vol,mute,bright}-{light,dark}.png` (2x, over a solid Electric Blue wallpaper; the
blurred photo at the right end is a desktop widget seen through the glass).

- Drawn by **MenuBarAgent** (`/System/Library/CoreServices/MenuBarAgent.app`), window level 101, window frame
  1363,34 367 x 155 pt (includes room for the shadow). Not OSDUIHelper. While the HUD is up, the Control Center menu
  bar icon shows its highlight pill: the HUD is presented from the Control Center item.
- Shape: one capsule, x 1392.5..1700 pt (307.5 wide, 10 pt from the screen's right edge), y 44..109.5 (65.5 tall,
  10 pt below the 34 pt menu bar), radius = half height. Material: clear-looking glass with strong edge refraction
  (the widget behind is bent around the right end), light rim, interior slightly saturated (69,83,206 -> 68,85,232).
  Light and dark look the same over the same wallpaper (white content in both).
- Content: glyph centred about 34 pt from the left edge, 27.5 x 21.5 pt for speaker.wave.2.fill. Glyph per state:
  speaker.wave.1.fill at low level (3/16), speaker.wave.2.fill at 7/16, speaker.slash.fill when muted, sun.max.fill
  for brightness (max volume not tried: it would blast the speakers). Level bar: 16 dashes, each 12 x 4 pt with a
  2 pt gap (pitch 13.5 pt), bar 214 pt long starting 63 pt from the capsule's left edge (30.5 pt right padding),
  vertically centred. Filled part white; empty dashes white at low alpha; muted = all dashes empty.
- Steps: one key press = 1/16 (volume 38 -> 44 %). Option+Shift = quarter steps (bar moves 1/64).
- Appear: the menu bar highlight comes first, the HUD starts 3 frames (50 ms) after the key, then scales from about
  0.9 to 1.0 while fading in. Alpha per frame: 0.01, 0.02, 0.03, 0.06, 0.09, 0.13, 0.19, 0.24, 0.30, 0.35, 0.40,
  0.45, 0.50, 0.56, 0.61, 0.66, 0.71, 0.75, 0.78, 0.82, 0.85, 0.87, 0.89, 0.91, 0.93, 0.94, 0.95, 0.96, 0.97, 0.98:
  about 0.55 s, slow start then ease-out (spring-like). Width 0.82 -> 0.92 -> 1.0 of the final over the first 0.1 s
  then easing out to 1.0 by about 0.4 s.
- Stays up until about 1.05 s after the last key press, then hides: scales back towards 0.92 and fades. Alpha
  0.96, 0.85, 0.71, 0.56, 0.45, 0.36, 0.29, 0.23, 0.18, 0.14, 0.11, 0.09, 0.07, 0.05, 0.04, 0.03: about 0.3 s to 5 %
  (about x0.8 per frame); the glass rim goes first, glyph and bar linger faintly to about 0.5 s.
- Repeated presses (5 at 120 ms) and simulated key repeat (10 at 70 ms): the HUD does not re-animate; the filled part
  of the bar moves continuously (not dash by dash, it can stop inside a dash) and eases out about 0.15 to 0.2 s after
  the last press. The 1.05 s hide timer restarts on every press.
- Volume then brightness then volume within 0.5 s: same capsule, the glyph and bar crossfade in about 3 frames
  (both glyphs visible in the middle frame); no hide/show between them.
- Not measured: changing from the Control Center slider, full screen, a second display, real hardware key repeat,
  maximum level, keyboard backlight.

## R4 Fonts and emoji

Measured on macOS 27.2.1 (26B131), MacBook Air M2, in-process with AppKit/CoreText. No defaults were changed.

**Font files** (`reference/re/27.2.1/live/font-hashes.json`)
- System UI fonts are in `/System/Library/Fonts`. SFNS.ttf is 22.0d5e1, 7,872,432 B, sha256 `44890958…26da571`. SFNSItalic is 22.0d5e1, SFNSRounded 22.0d3e2, SFNSMono/MonoItalic 22.0d3e3, SFCompact/CompactItalic 22.0d5e1, SFCompactRounded 22.0d3e2 and NewYork/NewYorkItalic 22.0d4e2. The CTFont version string matches the name ID 5 string for every file.
- SF Mono exists in three places:
  - `SFNSMono.ttf`: the system mono font, variable wght 294.673–900. This is what `monospacedSystemFont` uses.
  - `Terminal.app/Contents/Resources/Fonts/SFMono-Terminal.ttf`: version 21.0d1e2.
  - 12 static `SF-Mono-*.otf` files: version 15.0d5e1.
- `/Library/Fonts` holds only the SF Pro developer download (21.0d6e2): SF-Pro.ttf (opsz 17–28), SF-Pro-Italic.ttf, and the static Text, Display and Rounded OTFs. There is no SF Compact, SF Mono or New York there.
- Apple Color Emoji.ttc: 192,120,460 B, sha256 `12bc8221…be8f9e` (re-checked, same as sent earlier).
- **PC comparison:** all 20 files in `themes/fonts/*.ttf|ttc` are **byte-identical** to the 27.2.1 system files. All 10 files in `themes/fonts/named/` **differ only in the `name` table** (checked table by table): they are renamed copies of the same system files at the same versions. `named/SF-Pro.ttf` is the 22.0d5e1 system SFNS. It is not the older 21.0d6e2 developer `/Library/Fonts/SF-Pro.ttf`.

**Text styles** (`text-styles.json`). All styles use `.SFNS-*` from SFNS.ttf.

| style | pt | font | line height | tracking pt |
|---|---|---|---|---|
| largeTitle | 26 | Regular | 32 | +0.2158 |
| title1 | 22 | Regular | 26 | −0.2578 |
| title2 | 17 | Regular | 22 | −0.4316 |
| title3 | 15 | Regular | 20 | −0.2344 |
| headline | 13 | **Bold** (wght 700) | 16 | −0.0762 |
| subheadline | 11 | Regular | 14 | +0.0645 |
| body | 13 | Regular | 16 | −0.0762 |
| callout | 12 | Regular | 15 | 0 |
| footnote | 10 | Regular | 13 | +0.1172 |
| caption1 | 10 | Regular | 13 | +0.1172 |
| caption2 | 10 | **Medium** (wght 510) | 13 | +0.1172 |

- caption2's descriptor weight trait says 0, but the font it resolves to is Medium.
- Line height = ascender − descender + leading. The result is an exact integer for every style.
- `systemFontSize(for:)`: mini 9, small 11, regular 13, large 13, extraLarge 13.
- systemFontSize 13, smallSystemFontSize 11, labelFontSize 10.
- menu, menuBar and message fonts are 13. toolTips and palette fonts are 11. controlContent is 12, label is 10, titleBar is 13 `.SFNS-Bold`. userFont is Helvetica 12 and userFixedPitch is Menlo 11.

**Optical size:** the opsz axis follows the point size, clamped to the range 17–96.
- ≤17 pt uses the Text design. Advance widths are identical to static SFProText.
- 18–27 pt interpolates continuously between Text and Display.
- ≥28 pt has advance widths identical to static SFProDisplay. They do not change from 28 to 96.
- There is no longer a hard switch at 20 pt.

**Tracking:** CoreText builds tracking into the glyph advances, using the SFNS `trak` table's "Normal" track.
- It is chosen by point size and linearly interpolated between table entries. Fractional unit values are truncated (25 pt: 11.5 → 11).
- Normal values in units/2048 at 9…17 pt: 38, 24, 12, 0, −12, −22, −32, −40, −52.
- Values at 20/22/24/28/32 pt: −46, −24, 6, 28, 26. The table returns to 0 from 80 pt.
- The full measured table for 9–30, 34, 40 and 48 pt is in `sfProRegularTrackingBySizeCompact`.

**Text samples:**
- `reference/screens/27.2.1/text-sample-light.png` and `text-sample-dark.png`: 2000×786 px (2x), drawn with real NSLayoutManager text drawing.
- They show SF Pro at 11, 13, 17 and 26 pt in Regular, Semibold and Bold, plus emoji lines at 13 and 26 pt.
- Light background is #FFFFFF with text #000000. Dark background (windowBackgroundColor) is #1E1E1E with text #FFFFFF.
- Baselines and widths for each line are in `text-styles.json` under `textSample`.

## R5 Accent and Multicolor

The current user's real values: `AppleAccentColor` is **absent** (Multicolor), `AppleHighlightColor` is **absent** (Automatic), and `AppleInterfaceStyle` is Dark. Full data is in `reference/re/27.2.1/live/accent-colors.json`.

The pane on this Mac offers 9 accents: Multicolor −2 (key absent), Graphite −1, and 0–6. Key −3 "This Mac" (enclosure colour) appears only on Macs with a coloured enclosure. Simulated values are in the JSON. Values 7, 8, 9 and −3 fall back to Multicolor.

Argument domain: negative values must be passed as `-AppleAccentColor "<integer>-1</integer>"`. A bare `-1` is silently ignored.

Values are sRGB hex, light / dark. "/.50" means alpha 0.5.

| accent | controlAccent | selectedContentBg | selectedTextBg = selectedControl | keyboardFocusIndicator |
|---|---|---|---|---|
| Multicolor (no app accent) | #007AFF / #007AFF | #0064E1 / #0059D1 | #B3D7FF / #3F638B | #0067F4/.50 / #1AA9FF/.50 |
| Blue 4 | #007AFF / #007AFF | #0064E1 / #0059D1 | #B3D7FF / #3F638B | #0067F4/.50 / #1AA9FF/.50 |
| Purple 5 | #953D96 / #A550A7 | #7D2A7E / #803482 | #DFC5E0 / #705771 | #842685/.50 / #DC78DE/.50 |
| Pink 6 | #F74F9E / #F74F9E | #D93B86 / #C93379 | #FDCBE2 / #89576E | #EC398D/.50 / #FF77D4/.50 |
| Red 0 | #E0383E / #FF5257 | #C4262B / #D13539 | #F6C4C5 / #8B5759 | #D32127/.50 / #FF7A80/.50 |
| Orange 1 | #F7821B / #F7821B | #D96B0A / #C96003 | #FDDABB / #896647 | #EC7002/.50 / #FFB33A/.50 |
| Yellow 2 | #FFC726 / #FFC600 | #E1AC15 / #D19E00 | #FFEEBE / #8B7A3F | #F4B90E/.50 / #FFFF1A/.50 |
| Green 3 | #62BA46 / #62BA46 | #4DA033 / #43932A | #D0EAC8 / #5C7654 | #4EAB30/.50 / #8DF56C/.50 |
| Graphite −1 | #989898 / #8C8C8C | #808080 / #696969 | #E0E0E0 / #696969 | #99999E / #C3C3C3/.50 |

These colours are the same for every accent:
- unemphasizedSelectedContentBackground: #DCDCDC / #464646
- alternateSelectedControlText: #FFFFFF
- link: #0068DA / #419CFF
- control: #FFFFFF / #FFFFFF at alpha 0.25
- findHighlight: #FFFF00

**Highlight colour:**
- With `AppleHighlightColor` absent, selectedTextBackgroundColor follows the accent. In Multicolor it follows the app's own accent.
- AppKit writes the value with the format `"%f %f %f %@"`. The name strings in AppKit are Red, Orange, Yellow, Green, Blue, Purple, Pink, Brown, Graphite and ThisMac.
- When reading, AppKit uses the trailing name (case-sensitive) and ignores the rgb:
  - A known colour name selects that key.
  - `Accent` or `ThisMac` selects Automatic.
  - `Other` uses a softened version of the custom rgb.
  - An unknown name (including `Automatic` and `Brown`) or rgb only uses the rgb verbatim.
- I did not observe the exact rgb Settings writes on 27.2.1, because writing defaults was off-limits. The light highlight display colours are in the JSON.

**Multicolor:**
- In Multicolor, each app uses its own Info.plist `NSAccentColorName` or `NSAppAccentColorName` from its asset catalog. Apps with neither get Blue #007AFF.
- Picking any explicit accent overrides the app's colour. I verified this with scratch bundles that carry a copied Assets.car.
- Apps with their own accent, shown as runtime light / dark:
  - Notes #FCB827
  - Calculator #FF9300
  - Home and Clock #FF8D28 / #FF9230
  - Calendar #FF383C / #FF4245
  - Freeform #00C0E8 / #3CD3FE
  - Journal #6155F5 / #6D7CFF
  - Podcasts #7224D8 / #9C5AF2
  - News #FF0054 / #FF005A
  - Stocks #4EACF8
  - Books #262626 / #FFFFFF
  - Games #FFFFFF
  - Mail, Contacts, TV and Siri AI use systemBlue #0088FF / #0091FF
  - Setup Assistant #0068DA / #419CFF
- Music, Photos, Messages, Safari and Finder have no accent key, so they get #007AFF.
- Catalog colours that reference a system colour resolve to the new 27 system palette. For example, systemBlue is #0088FF, not #007AFF.

**Multicolor swatch:**
- `reference/screens/27.2.1/multicolor-swatch.png` is AppKit's `NSMulticolorAccent` image, 32×32 px, an opaque square that the pane clips to a circle. It is identical in light and dark.
- `multicolor-highlight-swatch.png` is `NSMulticolorHighlight`, 48×24 px.
- Both come from AppKit's Assets.car. The Appearance.appex asset catalog has no Multicolor swatch.

## Sounds (27.2.1)

Host: macOS 27.2.1 (26B131). Repo index: 27.2 (26B123). Full list: `~/hyprk/reference/re/27.2.1/live/sounds-27.2.1.json` (path, size, sha256, duration/channels/rate/format, status, usage map).

### Counts
- Scanned: all of /System/Library, /System/Applications, /System/Cryptexes/App and /OS (superset of the requested roots). /Library/Sounds and /System/Library/Audio/UISounds do not exist.
- 4850 unique sound files (Versions/Current aliases collapsed), 520,058,753 bytes. m4a 3325, caf 1147, aiff 150, m4r 128, wav 57, aif 41, mp3 2.
- 3325 m4a are mostly MobileAsset (Music app 2475, TTS 501) and Siri/VoiceOver speech, not UI sounds.
- afinfo failed only for MediaPlaybackCore `empty.m4a` (258 bytes, empty).

### Comparison with ~/hyprk/sounds/originals (288 files)
| result | count |
|---|---|
| same (name and sha256) | 288 (all repo files; 295 live files share these hashes because of duplicates) |
| changed in 27.2.1 | 0 |
| missing in 27.2.1 | 0 |
| new in 27.2.1 inside the folders the repo imports (Sounds, SystemSounds, AlertTones, VoiceOverSounds, Telephony) | 0 |

Hence nothing needs to be re-copied from 27.2.1. Note: the repo's misc/ files live under different live names (e.g. misc/Mail-New_Mail.aiff = Mail.app `New Mail.aiff`, misc/BezelServices-volume.aiff = `volume.aiff`); matched by sha256.

Not in the repo (never imported, not "new in 27.2.1"; no 27.2 baseline to compare): 4555 files, 475,421,402 bytes. Bulk part: 4361 files, 385,083,322 bytes (Music MobileAssets, TTS models, SiriTTSService, SpeechObjects, VoiceOver training, Photos resources, ToneLibrary Ringtones folder). Remaining 194 files, 90,338,080 bytes, are listed per path in the JSON (status `not_in_repo`, `bulk` false) and in `.../scratchpad/snd/not_in_repo_paths.txt`. Largest non-bulk groups:

| location | files | bytes | examples |
|---|---|---|---|
| Slideshows.framework | 8 | 22.4M | Content/Audio/*.m4a (music beds) |
| AssistantServices.framework | 14 | 6.9M | siri-begin-improved.caf, dt-begin/cancel/confirm.caf, jbl_*_sae.caf, announce-messages-tone.wav |
| SiriUI + SpeakerRecognition | 12 | 23.1M | Siri+ Buddy / VoiceTriggerTraining caf (duplicates) |
| HearingUtilities.framework | 16 | 4.7M | background sounds (Rain, Ocean, ...) |
| AudioPasscode, HeadGestures, AccessibilitySharedSupport, AXMediaUtilities | 41 | 9.6M | accessibility/detection tones |
| Messages iMessageEffects | 10 | 1.4M | *SoundEffect.m4r |
| Game Center / Screen Sharing / Dwell / Assistive Control / Music / TV / Books / MIDI | ~15 | ~1.1M | GKInvite, SessionStarted, Invitation Accepted, Ringer.aiff, SoundActivateItem.aiff |
| Navigation.framework | 3 | 0.3M | Approach.caf, TurnLeft.caf, TurnRight.caf |

### Usage mapping (file used by the system)
Evidence: strings of on-disk binaries, plus strings of the dyld shared cache (CoreAudio's SystemSounds name table at cache offset ~95011706, listing Grab.aif, Screen Capture.aif, Volume Mount/Unmount, Media Keys, burn complete/failed, accessibility keys, finder/dock/ink/telephony/facetime/system names). Nothing was played; no code was decompiled beyond one call-site in screencapture.

| event | file | confidence | basis |
|---|---|---|---|
| volume change feedback ("pop") | `/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff` (repo misc/BezelServices-volume.aiff) | high | BezelServices: playVolumeKeyFeedback, pref com.apple.sound.beep.feedback, "volume"+"aiff" strings; full path also in dyld cache. Not Sounds/Pop.aiff (different sha). On this Mac the pref reads 0 (feedback off; setting untouched). |
| screenshot shutter | `SystemSounds/system/Screen Capture.aif` or `Grab.aif` (Grab.aif and Shutter.aif are byte-identical) | low | `/usr/sbin/screencapture` plays system sound ID 1393 (0x571) via AudioServicesPlaySystemSound; ID-to-file table not decoded. Name table lists Grab.aif and Screen Capture.aif, not Shutter.aif. `screencapture -x` = silent. |
| empty Trash | `SystemSounds/finder/empty trash.aif` | medium-high | name + CoreAudio table; Finder has no .aif strings (uses system sound IDs), caller not traced |
| move to Trash | `SystemSounds/finder/move to trash.aif` | medium-high | same. Dock: `dock/drag to trash.aif`, `dock/poof item off dock.aif` |
| alert sounds (Settings > Sound) | the 14 files in `/System/Library/Sounds`: Basso Blow Bottle Frog Funk Glass Hero Morse Ping Pop Purr Sosumi Submarine Tink | medium-high | Sound.appex has AlertSounds/alertSoundPath/playBeepSound, fallback `/System/Library/Sounds/Purr.aiff`. Selected now: Blow (`com.apple.sound.beep.sound`). Folder enumeration not traced; ~/Library/Sounds not checked. |
| Mail new mail | `/System/Applications/Mail.app/Contents/Resources/New Mail.aiff` | high | Mail binary strings "New Mail", "Mail Sent", "Mail Scheduled"; also Mail Fetch Error.aiff |
| AirDrop | `Sharing.framework/.../Resources/airdrop_invite.caf` | medium | name and cache string only |
| lock/unlock | no screen lock/unlock sound on disk. SecurityInterface `lock.aif`, `unlock.aif`, `lockClosing.aif`, `lockOpening.aif` = padlock control | medium | iOS-style LockScreen*.aiff names exist only as strings in the cache, files absent |
| device connect/disconnect | `SystemSounds/system/Volume Mount.aif` / `Volume Unmount.aif` | medium | names + table (disk mount/eject). No USB/Bluetooth connect sound found |
| Siri | `SystemSounds/siri/jbl_begin.caf`, `jbl_begin_short.caf`, `jbl_cancel.caf`, `jbl_confirm.caf` | medium-high | full paths referenced in the cache; which event uses which not traced |
| Apple Pay | `SystemSounds/system/payment_success.aif`, `payment_failure.aif` | medium | names + table |
| power connected | `/System/Library/CoreServices/PowerChime.app/Contents/Resources/connect_power.aif` | high | PowerChime: "connect_power", NSSound play, "PLAYING CHIME SOUND", chimeOnAttach; only audio file in the app |
| low battery | none found | n/a | PowerChime has no other audio resource |

### Not determined / not checked
- Exact screenshot file (ID 1393 not mapped).
- Callers of the finder/dock/payment/Volume Mount/AirDrop/Siri sounds (names only).
- Whether Settings > Sound enumerates ~/Library/Sounds (not checked); mic/media/head-gesture/facetime SystemSounds users not traced.
- /Applications, user Library and sounds outside the scanned roots: not checked.

## R6 27.2.1 against 27.2

Which binaries hold the UI (all on this Mac as plain files outside the dyld cache; frameworks are inside the cache):
- Dock, Mission Control, Launchpad remnants: `/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock` (7.8 MB).
- Menu bar extras, volume/brightness HUD: `/System/Library/CoreServices/MenuBarAgent.app` (11.2 MB, new owner of
  the HUD window) and `/System/Library/CoreServices/ControlCenter.app` (20.5 MB; Control Center panel and modules).
  The bar itself is a WindowServer window (SkyLight framework, in the cache).
- Notification Center and widgets: `/System/Library/CoreServices/NotificationCenter.app` (8.7 MB).
- Stage Manager / window management: `/System/Library/CoreServices/WindowManager.app` (13.9 MB).
- Spotlight: `/System/Library/CoreServices/Spotlight.app` (0.27 MB; UI in SpotlightUIInternal / SearchUI frameworks
  in the cache). Apps: `/System/Applications/Apps.app` (0.13 MB, UI in frameworks).
- System Settings: `/System/Applications/System Settings.app` (4.9 MB) plus the panes as 289 ExtensionKit
  extensions in `/System/Library/ExtensionKit/Extensions` (285 MB).
- Shared: AppKit, SwiftUI, QuartzCore, CoreMaterial, DesignLibrary, SkyLight, IconServices (cache).
The 27.2.1 cache here is 2.4 GB in 84 files. Since the PC is fetching the 27.2.1 IPSW, extracting from it is simpler
than copying the cache; nothing was copied from the Mac.

What 27.2.1 shows on this Mac (things to diff against the PC's 27.2 references; I have no 27.2 Mac to compare):
- Appearance pane: Appearance (Light / Dark / Auto), a "Liquid Glass" slider with a live preview (stored as
  `NSGlassTintAmount`, 0.5 here), a "Theme" group with Colour (Multicolour + 8) and Text highlight colour
  (Automatic), and "Icon & widget style" (Default / Dark / Clear / Tinted; `AppleIconAppearanceTheme`).
- System Settings sidebar icons follow the icon style (with Dark: dark tiles with coloured glyphs).
- Spotlight: a "Search or Ask" capsule with a mic glyph; with no query it can list the modes Applications, Files,
  Actions, Clipboard under the bar.
- Apps opens as a normal window ("Applications"), not a full-screen Launchpad.
- Volume / brightness HUD: a glass capsule at the top right under the menu bar (MenuBarAgent), see the HUD section.
- Menu bar: 34 pt on this notched display, no background, top-of-screen highlight dimming over bright wallpapers.
- Toolbars: item groups on 36 pt glass capsules, flat titlebar, full-height flush sidebar (see Q9).

### R3b-2 Menu bar, Control Center and Notification Center glyphs

Same pipeline and rules as R3b: no git, no GUI, no defaults writes. Nothing existing was overwritten. `names.json` was extended, and some notes in `symbols` were corrected (listed at the end).

**Files added**
- `themes/icons/sf-symbols/svg/`
  - 450 SF Symbol SVGs at their surface size, named `<symbol>.<weight>.<pt>pt[.hierarchical|.var-N|.tint-<colour>].svg`
  - 46 vector assets, `asset.<source>.<name>.svg`
  - 22 battery composites, `menubar-battery-level-<0..100>-<light|dark>.svg`
- `themes/icons/sf-symbols/png/`: 34 system battery bitmaps, `menubar-battery-<state>@2x-<light|dark>.png` (52×28 px)
- `names.json` has new keys: `menubar` (52 entries), `controlcenter` (44), `notificationcenter` (11), `focusModes` (10). Each entry has element, symbol, size, size basis, weights, rendering, confidence, evidence and files. Per-file metrics are in `files`, in the same schema as R3b.

**How the names were found**
- **Strings in the binaries:**
  - C strings and Swift string literals in ControlCenter.app, SystemUIServer, NotificationCenter.app, MenuBarAgent, TimeMachine.menu, and the frameworks ControlCenter links (MenuBarClient, DoNotDisturb, SystemStatus, LoginUIKit, HearingUtilities).
  - Short Swift literals are not stored as strings, so I decoded them from the instructions that build them (e.g. `switch.2`, `speaker.fill`, `sun.min.fill`, `play.fill`).
- **Focus modes** come from `DNDSystemImageNameForModeSemanticType()` and `DNDSystemColorNameForModeSemanticType()` called at run time:

  | Focus | Symbol | Colour |
  |---|---|---|
  | Do Not Disturb | moon.fill | indigo |
  | Sleep | bed.double.fill | indigo |
  | Driving | car.fill | indigo |
  | Fitness | figure.run | green |
  | Work | person.lanyardcard.fill | teal |
  | Personal | person.fill | purple |
  | Reading | book.closed.fill | orange |
  | Gaming | rocket.fill | blue |
  | Mindfulness | apple.mindfulness | mint |
  | Reduce Interruptions | `_gm` (private, Apple Intelligence-like) | purple/teal |

  These are sure; light and dark sRGB values are in `focusModes`.
- **Sizes:** the binaries do not reveal sizes. I measured glyphs in Apple's 27 screenshots (`reference/screens/macos27-control-center.png`, `macos27-notification-center.png`), calibrated by the 13 pt menu bar text cap height. Accuracy is about ±1 pt. Weight cannot be told from those images, so regular and medium are rendered (NC also semibold).

  | Surface | Measured size | Rendered |
  |---|---|---|
  | Menu bar | wifi ~15.5, switch.2 ~15, siri ~13.4 | 13/14/15 pt |
  | CC toggle tiles (Wi-Fi/Bluetooth/AirDrop/Focus) | ~18 | 18 pt |
  | CC round buttons (Dark Mode, Screen Mirroring, Stage Manager, the menubar.dock.rectangle button) and Now Playing play | ~23–25 | 24 pt |
  | Now Playing previous/next | ~17 | 17 pt |
  | Slider glyphs | ~16 | 16 pt |
  | Sound output (airplayaudio) | ~13 | 13 pt |
  | NC xmark | ~12–13 | 13 pt |

**Main mappings** (full list in names.json)

Menu bar:

| Item | Glyph | Confidence |
|---|---|---|
| Wi-Fi | wifi, levels as variable value `.var-0/20/50` | sure |
| Wi-Fi off / no internet / hotspot / scanning | wifi.slash, wifi.exclamationmark, personalhotspot; scanning = ControlCenter assets `wifi.menu.scanning.1-3` | likely |
| Bluetooth | bluetooth (private) | likely |
| Control Center | switch.2 | sure |
| Spotlight | magnifyingglass | likely |
| Siri | siri (new circle-and-wave glyph) | sure |
| Sound | speaker.wave.3.fill with variable levels, speaker.slash.fill (muted), speaker.fill | likely |
| AirDrop | airdrop / airdrop.slash (private) | likely |
| Screen Mirroring | rectangle.on.rectangle | likely |
| Accessibility Shortcuts | accessibility | likely |
| Hearing | ear | likely |
| Fast User Switching | person.crop.circle | likely |
| Time Machine | clock.arrow.circlepath (idle); custom glyph `time_machine_backingup` from TimeMachine.menu (backing up) | likely / sure |
| VPN | network.badge.shield.half.filled (CC module); legacy `VPN.menu` frames `asset.vpnmenu.VPN0-4` | likely / sure |
| Privacy indicators | mic.fill, video.fill, location.fill | likely |
| Timer, Music Recognition, Voice Control | timer, shazam.logo.fill, voice.control | likely |
| Now Playing | play.fill / pause.fill | guess |
| Display | display | guess |
| Keyboard Brightness | light.max | guess |
| Clock | text only, no glyph | sure |

Control Center:

| Element | Glyph | Confidence |
|---|---|---|
| Wi-Fi / Bluetooth / AirDrop tiles | blue glyph on white when on (`.tint-systemBlue`) | sure |
| Focus | moon.fill, plus each mode's glyph tinted in its colour | sure |
| Stage Manager | sidebar.squares.leading, hierarchical (found by visual match only; the name is in no binary) | likely |
| Screen Mirroring | rectangle.on.rectangle | sure |
| Dark Mode | appearance.darkmode (private) | likely |
| Unidentified button | menubar.dock.rectangle, hierarchical (which module it belongs to is unknown) | likely |
| Display slider | sun.min.fill / sun.max.fill | sure |
| Sound slider | speaker.fill / speaker.wave.3.fill | sure |
| Sound output button | airplayaudio | sure |
| Now Playing | backward.fill, play.fill, forward.fill (sure); pause.fill (likely) | sure / likely |
| Night Shift, True Tone | nightshift, truetone (private) | likely |
| Hearing | ear, hearingdevice.ear | likely |
| Keyboard Brightness | light.min / light.max | guess |
| Users | person.crop.circle | likely |

Notification Center:

| Element | Glyph | Confidence |
|---|---|---|
| Clear / close | xmark | sure |
| Clear (filled) | xmark.circle.fill | likely |
| Group expand / Show less | chevron.down / chevron.up | likely |
| Open | chevron.forward | likely |
| Options | ellipsis | likely |
| Summary | text.line.2.summary, apple.intelligence, hand.thumbsup/down | likely |
| Edit Widgets | text-only pill, no glyph | sure |

**Battery (menu bar).**
- It is not an SF Symbol. BatteryUIKit `-[BUIImage _modernBatteryImageForLevel:charging:pluggedIn:…]` draws a 26×14 pt image and returns a 2x bitmap.
- I captured its drawing into a PDF to get the geometry:
  - body: rounded rect (0,1,23,12) with radius 4
  - fill width: `max(2, round(level×23))` pt
  - opacities: fill 0.847, track 0.498 (light) / 0.549 (dark), cap 0.6
  - cap: the `battery-cap` nub at x=24
- The level SVGs are rebuilt from that geometry. They match the system bitmap with mean alpha difference under 0.8/255; edge pixels differ by up to 43/255.
- Charging, plugged, low-power (yellow), low (red), percent, no-battery and needs-replacement exist only as the 34 system PNGs, plus the vector parts (`asset.batteryuikit.battery-bolt/-plug/-cap/-alert/-missing` and their masks).

**Checks**
- All 450 symbol SVGs are paths only. 446 match AppKit's own 2x rendering, as in R3b. The 4 exceptions:
  - The two `person.lanyardcard.fill …tint` files differ only because AppKit's single-colour palette fills the knocked-out person. The SVGs keep the knockout, as the monochrome glyph does.
  - `airdrop.slash.regular.13pt` and `rectangle.on.rectangle.slash.regular.13pt` differ by a ≤0.25 pt horizontal pixel-snapping offset.
- 28 of the asset SVGs were flattened to plain paths and checked against the original PDFs. These 18 keep `<clipPath>`/`<mask>` exactly as pdftocairo exported them; they render only with an SVG renderer that supports masks:
  - `asset.controlcenter.wifi.menu.*`
  - `asset.vpnmenu.VPN0-3`
  - the 4 `asset.controlcenter.*-large` files
  - `asset.controlcenter.battery-small-cap`
  - `asset.batteryuikit.BatteryEmpty/None/DeadCropped`

**Not done:**
- Input-source icons: they are flag/letter images from the keyboard-layout bundles, not symbols.
- The CC "Edit Controls" glyph: not identified.
- The menu bar point size and weight could not be read from the binaries, so those are measured estimates.
- Vector versions of the charging/plugged battery: PNG plus parts only.

**Corrections to R3b `symbols`**
- `battery`: the menu bar uses the BatteryUIKit image above, not battery.100percent.
- `speaker`: the CC slider uses speaker.fill (left) and speaker.wave.3.fill (right).
- `sun`: the CC slider uses sun.min.fill / sun.max.fill.
- `square.grid`: Stage Manager is sidebar.squares.leading.
- Raised to sure: switch.2, screen.mirror, Now Playing, moon, airdrop.

### R3b-3 Settings icons per "Icon & widget style", and Finder sidebar glyph size

Same rules as before: no git, no GUI, no defaults writes. Nothing existing was overwritten.

#### 1. Settings pane icons per icon style

**How the style is selected**
- The preference `AppleIconAppearanceTheme` is a SkyLight `SLSIconAppearanceTheme`. SkyLight's strings list the values in this order:

  | Value | Name | Value | Name | Value | Name |
  |---|---|---|---|---|---|
  | 0 | RegularAutomatic | 3 | ClearAutomatic | 6 | TintedAutomatic |
  | 1 | RegularLight | 4 | ClearLight | 7 | TintedLight |
  | 2 | RegularDark | 5 | ClearDark | 8 | TintedDark |

  Read with this numbering, this Mac's `fetchCurrentIconAppearanceConfiguration` returns 2 (RegularDark), which is its stored value.
- IconServices reads that configuration through `-[ISImageDescriptor applyIconAppearanceConfiguration:]` (setting the appearance theme on a configuration object):
  - It sets `appearance`: 0 = light tile, 1 = dark tile.
  - It sets `appearanceVariant`: 0 = regular, 3 = clear, 2 = tinted.
  - Measured results: RegularLight → appearance 0 in both light and dark mode; RegularDark → 1 in both; RegularAutomatic → follows the mode.
- **What the Appearance pane writes** (`Appearance.appex`, decompiled with Ghidra):
  - `IconAppearanceModel` stores a style kind t (0 Regular, 1 Clear, 2 Tinted) and a mode s (0 light, 1 dark/"Always", 2 automatic).
  - It saves `theme = 3t + {light: 1, dark: 2, automatic: 0}` (function at 0x100030164, called before `setIconAppearanceTheme:`).
  - The label function (0x100030034) shows which pair each UI style is:
    - "[Icon Style] Default" / "Icon style, light." = t 0, s 0 → **RegularLight (1)**
    - "[Icon Style] Dark" = t 0, s ≠ 0 → RegularDark (2) for "Always", RegularAutomatic (0) for "Automatic"
    - "[Icon Style] Clear" = t 1 → 3/4/5
    - "[Icon Style] Tinted" = t 2 → 6/7/8
  - `-[SLSIconAppearanceConfiguration init]` defaults to icon theme 1 (RegularLight). So an untouched account is on Default = RegularLight.
- **Does the sidebar follow this setting?** Likely yes. System Settings links `IconServices` and `_IconServices_SwiftUI`, and the latter observes `NSWorkspaceIconAppearanceConfigurationDidChangeNotification`. Also, `NSWorkspace` icons on this Mac (RegularDark) come out as dark tiles in both appearances.

**Answer: Default style in Dark appearance shows the coloured light-style tile, not the dark tile.**
- `<id>@<px>-default-dark.png` is byte-identical to `-default-light.png` and to the R3b `<id>@<px>-light.png`.
- The dark tile appears only with the Dark style ("Always", or "Automatic" while in Dark Mode). Clear and Tinted also have dark versions.
- This Mac (RegularDark) shows the dark tile in both appearances. The R3b `<id>@<px>-dark.png` files are byte-identical to `-dark-dark.png`. All 92 comparisons matched.
- **Not measured:** a capture of the live sidebar.

**Files:** 368 PNGs, `themes/icons/settings/<pane id>@<64|128>-<default|dark|clear|tinted>-<light|dark>.png`, covering all 23 panes. Each was rendered with an in-memory `SLSIconAppearanceConfiguration` (never saved) applied to the `ISImageDescriptor`.

| Style | Theme used | Light / dark files |
|---|---|---|
| default | RegularLight | identical |
| dark | RegularDark ("Always") | identical |
| clear | ClearAutomatic | differ |
| tinted | TintedAutomatic | differ |

- Every style renders offscreen.
- **Tinted:** the tint is "Automatic", which follows the accent colour. This Mac has no `AppleAccentColor` set, so the tint is blue. With an explicit tint colour (`AppleIconAppearanceTintColor`) the tint would differ.
- **Clear:** the light tile is semi-transparent, so its look depends on the background behind it.
- The theme mapping is also recorded in `names.json` → `settingsIconStyles`.

#### 2. Finder sidebar "Shared" glyph and glyph size

- **Shared = `person.2`** (outline two people) on 27.2.1 (sure).
  - Evidence: the capture made on this Mac (`reference/screens/27.2.1/finder-toolbar-light.png`) shows it, and Finder references `person.2`.
  - Apple's older macOS 27 marketing screenshot shows `folder.and.person`, which was my R3b answer. Finder lists that name among its iCloud symbols, so it is probably the iCloud Shared folder (guess).
  - `names.json` `symbols.shared` is corrected to person.2, with folder.and.person kept as an extra.
- **Sidebar glyph size: 13 pt, scale `.large`, weight `.medium`**, monochrome tinted with the accent colour (sure).
  - Method: I rendered AppKit candidates at 11–19 pt × small/medium/large × regular–bold at 2x and compared them with the capture.
  - clock and person.2 match 13 pt/.large/.medium with 0.2–0.3 % mean coverage difference and equal ink area. The next best, 13 pt/.large/.semibold, is 14–16 % off.
  - 13 pt is the sidebar text size: the "Recents" cap height is 19 px at 2x.
- **Toolbar glyphs: same config, 13 pt/.large/.medium** (likely).
  - magnifyingglass, square.grid.2x2 and squares.below.rectangle fit best at 4–8 %.
  - The selected or disabled items (list.bullet, rectangle.split.3x1, chevrons, tag) could not be fitted cleanly.
- **Files:** 30 new SVGs in `themes/icons/sf-symbols/svg/`, all paths only and matching AppKit:
  - `<symbol>.medium.13pt-large.svg` for 15 sidebar glyphs (including person.2, folder.and.person, clock, appstore, doc…) and 12 toolbar glyphs (including magnifyingglass).
  - `person.2.<regular|medium|semibold>.svg` at 32 pt, to match the R3b set.
  - They are listed in `names.json` → `finder.sidebarGlyph` and `finder.toolbarGlyph` (size/scale/weight, evidence, files), with per-file metrics under `files`.
  - 13 pt `.large` is not the same as a larger point size at `.medium`, so use the 13pt-large files directly.

## Q-windows (27.2.1)

Files: pictures in `reference/screens/27.2.1/windows/`, data in `reference/re/27.2.1/live/windows/` (`windows-measurements.json` has every number below; `probe-windows-{light,dark}.json` is the AppKit dump; `cursors/` and `cursors-live/` hold cursor PNGs). Probe source: `reference/re/tools/probe/windows.swift`. Colours are sRGB from 2x screenshots. The wallpaper was solid blue (69,83,206).

- Q-windows-01: The shadow is pure black with alpha, so it looks the same over white and over the wallpaper. AppKit `shadowParameters` for a document window: blur radius 20 active / 8 inactive, y offset 18 / 7 pt, density 0.40 / 0.22 in light and 0.70 / 0.45 in dark. Finder, measured: alpha at 2, 8, 16 and 32 pt from the edge:
  - Dark active: below .56 .49 .38 .17; side .33 .25 .15 .04; above .11 .07 .03 .00. Visible extent: below 64.5 pt, side 46, above 29.5.
  - Light active: below .32 .28 .22 .09; side .18 .14 .09 .02; above .06 .04 .02 0. Extent: 61.5 / 43.5 / 24.5 pt.
  - Dark inactive: below .33 .21 .06 0; side .19 .08 .01; above .06 .02 0. Extent: 24.5 / 18 / 10.5 pt.
  - Light inactive: below .16 .10 .03 0; side .09 .04 0; above .03 .01 0. Extent: 22.5 / 16 / 8 pt.
  - Utility panel: radius 8, offset 4, density .25 light / .30 dark.
  (screencapture -l alpha profiles; NSWindow `shadowParameters` from the probe)
- Q-windows-02: 16 pt for every window type measured: TextEdit, Finder, Safari, and the Fonts utility panel. AppKit `_cornerRadius` is also 16 for utility, toolbar and fixed-size windows. The curve is continuous, not a circle: the corner spans 24 pt (1.5 r).
  - Fits on the Finder corner: Apple continuous r 16 to 17 pt (RMS 0.32 pt); best circle 17 pt (RMS 0.56 pt, poor); Hyprland-style superellipse rounding 39.5 pt, power 5.75 (RMS 0.18 pt).
  - Alert: about 26 pt (circle 26 to 28 pt; the glass edge is soft).
  - Green-button popover: about 9 pt.
  (alpha profile of -o captures fitted to circle, continuous curve and superellipse)
- Q-windows-03: Two rims around every edge. There is no extra top highlight.
  - Outside: a 0.5 pt (1 px) black rim. Alpha about .93 active / .83 inactive in dark, .21 / .19 in light.
  - Inside: a 1 pt white rim, alpha .10 (.08 dark inactive).
  - TextEdit dark active, top edge from outside to inside: on white 221 → 16 → (61,61,67) ×2 px → bar (40,40,46); on blue (62,72,171) → (5,5,13) → (61,61,67).
  - Light active: on white 232 → 184 → 255; on blue (65,75,182) → (52,60,144) → 255. The inner rim is invisible on white and shows on grey (sidebar 235 → 237).
  (2x pixel rows across each edge over a white window and over blue, active and inactive)
- Q-windows-04: No glass in any of the four.
  - TextEdit and Terminal: the bar is an NSScrollPocket "hard pocket" made of two CABackdropLayers (gaussianBlur r6 + colorMatrix with saturation about 1.2 and +0.03, then a colorMatrix) over the window's own background (NSVisualEffectView material 18). Measured pixels are the same over white and over blue, so it is effectively a solid fill.
  - Finder: see MAC-ANSWERS Q9 (empty backdrop; only the item platters are glass).
  - Safari: the 52 pt strip has no fill; page content shows through under it, and only the controls are glass capsules (pixels only; another process's layers cannot be dumped).
  (probe layer dump with filter inputs + pixels)
- Q-windows-05:
  - TextEdit dark: #28282E active, #28282F inactive, over content #1E1E1E, so a separate fill in dark.
  - TextEdit light: #FFFFFF active and inactive, the same as the content.
  - Terminal dark: #28282E.
  - Finder has no bar colour: the toolbar shows the content (dark #202127, light #FFFFFF) with the scroll-edge blur.
  (2x pixels, white and blue backdrops)
- Q-windows-06: Bar heights from AX: TextEdit 32 pt, Terminal 32, Finder 52 (AXToolbar), Safari 52 plus a 38 pt tab bar.
  - TextEdit and Terminal have a 0.5 pt divider at the top of the content: black a.10 in light (#E5E5E5 on white), white a.07 in dark (#2E2E2E on #1E1E1E). It is always drawn, not only when content scrolls.
  - Finder and Safari have no divider; they use the scroll edge effect (Q9).
  (AX frames, probe layer, pixels)
- Q-windows-07: All frames are window-relative.
  - TextEdit and Terminal: 14 pt discs at x 9, 32, 55 (pitch 23), y 9, so the centre is at 16 of 32. AX frames are 16×16 at (8,8), (31,8), (54,8).
  - Finder and Safari (52 pt toolbar): AX (18,18), (41,18), (64,18), so discs at x 19, 42, 65 with centre y 26.
  - Utility panel: 10 pt discs at x 8, 25, 42 (pitch 17).
  (axd + probe `standardWindowButton` frames)
- Q-windows-08: Colours at rest, top / centre / bottom of each disc:
  - Dark close: #E87061 / #E1675B / #DE6F64, with a 1 px specular rim at top and bottom (#F6C6BC / #F5C4BA) and plain sides.
  - Dark min: #F1B835 / #F3C22D / #F6CF50, rim #F5F581.
  - Dark zoom: #6EC341 / #62BD2D / #6DC04B, rim #BFF69A.
  - Light close: #ED786B / #EA857B / #E89189 with a darker rim (#E97469).
  - Light min: #F2BD50 / #F5CB59 / #F8D562 with a darker rim.
  - Light zoom: #7DCD4A / #98D46F / #A9DA86 with a darker rim.
  - Light discs also have a faint coloured glow about 1 pt outside.
  - Pressed: the disc grows to 16 to 17 pt (about 1.15×) and gets brighter, not darker. Fill beside the glyph: close #FF7C68 dark / #FFAC9E light, min #FFFF70 (bottom) and #F06000, zoom #C6FF8F light.
  - Holding green about 0.3 s opens the tile popover (Q19).
  (2x crops `lights-*.png`)
- Q-windows-09: The discs are grey in a non-key window.
  - Dark: #4C4C52 fill (#47484D at the bottom) with a light grey rim (#B4B4B4 at the top px).
  - Light: #EFEFF3 to #F6F7F8 with a grey ring (#EAEAEE).
  - On hover they turn fully coloured with glyphs, the same as the active hover state.
  (crops `lights-inactive*.png`)
- Q-windows-10: Glyphs show on all three buttons when the pointer enters the group, about 0.07 s after entering.
  - Fade-in per 60 fps frame: .30 .64 .81 .90 .95 .96 .97 1, about 0.1 s ease-out. Fade-out: .22 .52 .77 .89 .96 .97 .99, about 0.1 s. No delay on exit.
  - Glyph sizes: × 7×7 pt; − 7.5×1.9 pt; full-screen glyph (two triangles) 6×6 pt; Option turns it into + 8×8 pt. Stroke about 1.9 pt.
  - Colours: dark #850000 / #AA3600 / #005500; light #9E0000 / #BE4900 / #097900.
  (60 fps recording, patch progress + 2x coverage)
- Q-windows-11: The TextEdit title is SF (.AppleSystemUIFaceHeadline) 13 pt bold (weight 0.4), labelColor a.85 drawn with a plus-lighter blend.
  - Rendered colour: dark active (165,164,172), about white a.58; inactive (105,106,112), about a.30. Light active #4C4C4C, about black a.70; inactive #BEBEBE, about a.25.
  - Position: not centred. It is left-aligned at x 100 after the 16 pt proxy icon (x 82), y 8 to 24.
  - Truncation is at the tail.
  - The utility panel title is SF 11 regular and centred.
  (probe font dump + AX + pixels)
- Q-windows-12:
  - Finder: the title ("Applications") is bold 13 and left-aligned right after the back/forward capsule (text from x≈256 pt; its AX field spans the free space 248 to 525). It is vertically centred in the 52 pt bar. Active is (58,59,57) light / (236,236,235) dark; inactive (129,132,128) / (117,115,103).
  - Safari: no title text, only the profile capsule and the URL field.
  - Mail: not measured (no Mail window was open, and opening one would show mail). Probe `NSWindow.subtitle` instead: title .SFNS-Bold 13 labelColor; subtitle .SFNS-Regular 11 secondaryLabel (black a.50 light / white a.55 dark); left-aligned at the same x, subtitle directly below; title line 16 pt, subtitle line 14 pt.
  (AX, probe, pixels)
- Q-windows-13: Finder: yes, every item group is a regular glass platter (see Q9). Here: back/forward capsule 74×36; view popup capsule about 45×36; Group; one shared capsule for Share/Tags/Action; search is a 36 pt circle. Safari: all items look like glass capsules (sidebar 36 circle, profile capsule 128 wide, back/forward 75×36, extensions capsule, search field 238×31 capsule with focus ring, right capsule for Downloads/Share/+/Tabs). Dark fill is about #585C67 on a #3F4151 strip. Pixels only. Safari tab bar: not measured (it shows the user's pinned tabs). (AX + `safari-toolbar-left-dark.png`)
- Q-windows-14: See MAC-ANSWERS Q9. The strip is not glass and not an NSVisualEffectView. Content scrolls under it with a scroll edge effect about 52 pt tall (visible blur of the icons in `finder-toolbar-*.png`). TextEdit/Terminal content does not go under the bar.
- Q-windows-15: Glass (NSGlassEffectView `_variant` 18 per Q9; not vibrancy). It is flush with the window's left, top and bottom edges, 163 pt wide, with a 0.5 pt divider on the right (#D3D4D5 light / #3D4150 dark).
  - Active it lets the desktop through, more at the outer edge. Colours at x 6 pt → x 96 pt: dark over white #424352 → #2E3040; dark over blue #252B6D → #232749; light over white #EBEBEC; light over blue #D4DAFF → #E4E7FD.
  - Inactive it is flat and almost independent of the backdrop: dark #262837, light #F1F1F2.
  - Item rows are 32 pt, section headers 19 pt.
  - Selection is a grey pill, not the accent colour: #D7D7D8 active / #E7E7E8 inactive in light, 32 pt tall, x 10 to 153, radius about 8 pt.
  - The selected icon uses the accent (#006BEE light / #28A2FF dark); it turns grey when inactive.
  (pixels white/blue × active/inactive, AX rows)
- Q-windows-16: See MAC-ANSWERS R2 and LIVE: the window is complete in the first frame (95 % in frame 1, the rest within 0.1 s); no scale or fade is visible. Reduce Motion: not measured (it is an accessibility toggle, and the open is already instant).
- Q-windows-17: See MAC-ANSWERS R2: a fade of about 0.1 s, alpha per frame 1 .71 .44 .27 .16 .09 .05 .03 (TextEdit). There is a slight blur on Finder; scale cannot be resolved. Safari closes instantly.
- Q-windows-18: See MAC-ANSWERS R2 and LIVE: genie of about 0.22 s into the app's Dock icon (whole effect about 0.65 s); restore about 0.22 s. The default mineffect is genie (this account says genie; the Dock default is genie). Window alpha during genie: not measured.
- Q-windows-19:
  - Click: native full screen. On this notch screen the window becomes 0,34 1710×1073, with its own 32 pt titlebar window.
  - Option-click: zoom to the visible frame 0,34 1710×1020. While Option is held the glyph is +. Option-click again restores.
  - Hover about 0.8 s, or hold about 0.3 s: a glass popover (ThemeWidgetControlViewService window, layer 101). Body 238×190.5 pt plus a 9 pt arrow pointing at the button. It appears in 1 frame with no fade and stays while the pointer is on it; Esc closes it.
  - Popover items: "Move & Resize" (Left, Right, Top, Bottom), "Fill & Arrange" (Fill, Left & Right, Left & Quarters, Quarters), a separator, then "Full Screen ›".
  - The default on 27.2.1 is full screen.
  (60 fps recording + `green-button-hover-menu-*.png`)
- Q-windows-20: See MAC-ANSWERS R2: zoom 0.33 s ease-in-out (unzoom ease-out); full screen enter about 0.42 s, exit about 0.5 s in two steps. Menu bar reveal in full screen: not measured.
- Q-windows-21: Double-click on the titlebar zooms; it toggles between 300,200 700×450 and 0,34 1710×1020. AppleActionOnDoubleClick here is "Maximize", which is the "Zoom" default. Mouse-down on an inactive window's titlebar raises and activates it at once, before any drag (the lights turn coloured). The shadow while dragging is the normal active shadow, with no lift. (synthetic down/drag + wins + -l alpha)
- Q-windows-22: TextEdit (autosave) shows no dot in the close button when edited. The title becomes "Chrome Test.txt — Edited" with "Edited" dimmer; on hover a chevron appears.
  - Click on the title: a glass popover (Name, Tags, Where + lock) anchored under the chevron.
  - Cmd-click: path menu.
  - The 16 pt proxy icon is always shown left of the title.
  - Fixed-size window (probe, no .resizable): the zoom button is disabled; disc pixels not measured. Settings > Appearance in 27.2.1 reports zoom enabled (AXZoomButton).
  (`textedit-edited-title-states-dark.png`, `title-click-document-popover-dark.png`)
- Q-windows-23: Resize zones, using NSCursor.currentSystem at 0.5 to 1 pt steps:
  - Edges: about ±3 pt around the frame line (left/top observed −2..+2, right/bottom −3..+3), so about half the zone is outside the window.
  - Corners: the diagonal cursor runs for 16 pt along each edge from the corner and about 8 pt diagonally inside.
  - Cursor sizes (hotspot in brackets): left/right 24×18 (12,9); top/bottom 18×28 (9,14); corner 22×22 (11,11). These match NSCursor.frameResize.
  - Minimum size: TextEdit 115×46, Finder 479×280.
  - Live resize: the frame and content follow the drag every frame.
- Q-windows-24: Tiling.
  - Edge-drag: the preview appears only when the pointer touches the screen edge (at x=0, not at x=2).
  - The preview is a WindowManager "Drag Guide Window" equal to the tile frame: radius about 16 pt, a 3 pt light rim (about white a.5), the interior darkened about 17 %, and a soft shadow about 8 pt. It fades in about 0.13 s and out about 0.15 s with no visible scale.
  - Option-drag: the preview follows the half under the pointer anywhere on screen.
  - Window > Move & Resize with margins off (this account): Left 0,34 855×1020; Top Right 855,34 855×510; Fill 0,34 1710×1020; no gap.
  - With margins on (turned on briefly, then restored): 8 pt screen-edge margin and 8 pt gap. Left & Right: 8,42 843×1004 and 859,42 843×1004.
  - 60 fps of the tile move itself: not measured.
  (wins + screenshots + recording; `tile-preview-left-corner.png`)
- Q-windows-25: What changes when a Finder window becomes inactive; content icons and labels do not change.
  - Lights turn grey.
  - Title dims (light 58 → 129, dark 236 → 117).
  - Toolbar glass platters flatten (light fill 245 → 236, dark 76 → 60) and their glyphs dim.
  - The sidebar loses its translucency (flat #F1F1F2 / #262837) and its icons turn grey instead of the accent.
  - The selection pill gets lighter (#D7D7D8 → #E7E7E8) with grey text.
  - The shadow gets smaller (Q01) and the rim lighter (Q03).
  (`finder-toolbar-*`, `finder-sidebar-*`)
- Q-windows-26: 2x PNGs and hotspots are in `live/windows/cursors/` (NSCursor) and `cursors-live/` (captured on real windows). Sizes in pt with hotspot:
  - arrow 28×40 canvas (5,5); I-beam 23×22 (12,11)
  - pointingHand 32×32 (12,8); open/closedHand 32×32 (15,16)
  - edge resize 24×18 (12,9) and 18×28 (9,14); corner 22×22 (11,11)
  - column resize 30×24 (15,12); row resize 24×28 (12,14)
  - dragCopy and operationNotAllowed 28×40 (5,5); dragLink 16×21 (11,3)
  - Pointer size on this account is 1.02.
- Q-windows-27: Finder drag cursors:
  - Plain move: arrow, no badge.
  - Option: copy cursor (arrow with a green + badge, = dragCopy).
  - Cmd-Option: alias cursor (curved arrow, = dragLink).
  - Over the menu bar: plain arrow (no not-allowed cursor seen).
  - Drag image: icon and label at scale 1.0, opacity about 0.9, soft shadow.
  - Esc cancel: the image slides back to the source in about 0.25 s, ease-out (.28 .36 .44 .52 .59 .65 .72 .78 .84 .89 .93 .96 .99 1), no fade.
  (curmon + 60 fps recording + `finder-drag-image-dark.png`)
- Q-windows-28: not measured: neither Chrome nor VS Code is installed on this Mac.

## REA 27.2.1: Dock, Mission Control, Cmd-Tab

Static analysis only, macOS 27.2.1 (26B131), M2. Dock = `/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock`
(arm64e slice, symbols stripped; names come from ObjC metadata, objc_msgSend stubs and ivar tables). Mission Control =
`WindowManager.framework` (dyld cache, disassembled with `dyld_info -disassemble`) plus `WindowManager.app` (WindowManagerAgent).
Addresses are unslid VAs in the named image. Pseudocode excerpts are in `~/hyprk/reference/re/27.2.1/decomp/dock-*.c`.
Defaults on this account (read-only check): no `genie-speed` and no `com.apple.WindowManager` spring keys, so built-in defaults apply.

### 1. Dock launch bounce, attention bounce
- Code: Dock `-[Tile updateBouncing]` 0x10002d9f4. Height use: Dock `-[Tile updateRect]` 0x100012088. Setup: Dock
  `-[DockBar handleDockEventAppLaunch:alreadyExists:appLaunch:context:]` 0x10008dfd8 (writes at 0x10008e134..0x10008e15c),
  `handleDockEventAppNeedsAttention:...` 0x10009140c, `handleDockEventAddBounce:context:` 0x100091590.
- Tile ivars: `_bounceNow` f 0xe0, `_bouncePeriod` f 0xe4, `_bounceST` d 0x108, `_bounceDur` d 0x110, flags byte 0x68
  (`_bouncing`, `_bounceEnding`, `_bounceStop`, `_notifyBounce`). Clock = `mainMillis` (ms).
- Launch bounce (`_notifyBounce` = 0): `_bouncePeriod` = 350.0 (half-period), `_bounceDur` = 120000 ms cap.
  `bounceNow = 1 - (x/350)^2`, with x = |fmod(t + 350, 700) - 350|. So the shape is a plain parabola, `h = H * 4u(1-u)`,
  u = t / 700 ms. There is no hold at the top. The icon is on the ground only at u = 0.
- Launch end: setting `_bounceStop` rounds `_bounceDur` up to `(floor(t/700) + 1) * 700`. So the bounce in progress
  finishes and the icon stays down. No settle.
- Launch height (bottom Dock): `offset = bounceNow * ((tileRectH - 8) * 0.2 + 6) * (1 - autoHide)`, with 0.2 = float
  0x1002580c0. For tile 33 this gives 11.0. For tile 64 it gives 17.2.
- Attention bounce (`_notifyBounce` = 1, `requestUserAttention`): this is a separate curve. `_bouncePeriod` = 2000 ms cycle.
  - Inside each cycle there are three parabolic hops: 500 ms at amplitude 1.0, then 326 ms at 0.5, then 212 ms at 0.25.
  - The icon then rests until 2000 ms. A fourth hop (138 ms at 0.125) is computed but zeroed in code.
  - Amplitude = `(tileRectH + 1) * (1 - autoHide) + autoHideOffset`, so a full tile height plus 1 pt.
  - When the duration ends, it stops at the next rest point.
- Attention durations, DockCore `DockGlobals` init 0x1001a66d4. All are in seconds and can be overridden with prefs:
  - `bounce-duration` 60 (initial bouncing time, cycles of 2 s);
  - then every `bounce-secondary-interval` 60 s, it bounces again for `bounce-secondary-duration` 3 s.
- Single "bounce once" event (`AddBounce`): 2000 ms cycle with dur 350, so exactly one 1.038 s hop sequence.
- Agreement:
  - Period 0.70 s: **agrees** (exact 700 ms).
  - Height at tile 33: **agrees** (11.0).
  - Height at tile 64: **differs by 0.8 pt** (code 17.2, measured 18).
  - Shape: **differs**. Code is a pure parabola; the measured 0.14 s flat top is not in the code. The parabola is at 0.96 at
    u = 0.4 (about 0.7 pt below the top at tile 64). Guess: pixel rounding or sampling made it look flat.
  - Touches the ground for one frame: **agrees**.
  - "Finishes the current bounce": **agrees**.

### 2. Dock magnification
- Code: Dock FUN_1000118d4 (fish setup), per-tile edge mapping inline at 0x100011b68..0x100011ec0, bar rect FUN_100012670,
  enter/leave duration FUN_10005bf08.
- Constants: `-[DockBar fSize]` 0x1001b5690 = 3.0, `fishSpeed` 0x1001b5684 = 42.0, `moveSpeed` 270.0, `dropSpeed` 350.0,
  K = pi (0x1002581d8).
- Formula (T = tileSize, L = largeSize, c = pointer x, clamped to bar):
  - F = fishSize = 3 T; Rs = realScale = ((L - T)/2) / sin(pi T / (4F)) * fish, with fish = 0..1;
  - map(x) = x + Rs * sin(pi (x - c) / (2F)) for |x - c| < F, otherwise x +/- Rs;
  - tile size = map(right edge) - map(left edge) + (unchanged base T). In closed form, for |d| <= F - T/2:
    size = T + (L - T) * cos(pi d / (2F)) (d = unmagnified centre distance).
  - The effect ends at d = F + T/2 = 3.5 T (224 pt at T 64). R therefore scales with tile size only; L sets the amplitude.
- Enter/leave: `fish` is a DockFloatAnimatedProperty with `_easingFunction` 1, so p = 0.5 - 0.5 cos(pi t)
  (0x10022eff4). Duration in ms = floor(42 * ln(|target - (T + currentFish)| / 2 + 1) + 1), which is 147 ms for 64 -> 128
  in either direction.
- Agreement:
  - R: **agrees** (fit 222 against code 224).
  - Sizes: **differ by up to 4.5 pt** at d = 155..175 (code 83.1 / 73.8, measured 87.6 / 78.3; RMS 2.5 pt). The data fit
    F = 3.2 T with 0.14 pt RMS, but the code says 3 T. The cause was not found.
  - Ease: **differs by about 0.03 s** (code 147 ms cosine ease-in-out, measured about 0.12 s; the first and last frames
    move under 3 %).

### 3. Dock hover label
- Code: Dock `-[DOCKLabelLayer attach:]` 0x100014588, `-[DOCKLabelLayer _updateLabelImage:orientation:]` 0x10003f44c,
  `-[DOCKLabelLayer update]` 0x1000138ac, `-[DockBar blendAwayLabel]` 0x10005c470, backdrop factory FUN_10003f170,
  `ECCartoucheGlassLayerController` (Swift helpers 0x10018665c init, 0x100186fc0 layout, 0x10018767c / 0x10018772c /
  0x1001877dc / 0x10018788c metrics, 0x100186e18 size table).
- Appear: `attach:` sets blend = 1 and stops its animation, so the label shows at once.
- Fade-out: `blendAwayLabel` animates blend 1 -> 0 over 300 ms (double 0x1002583f0), cosine ease-in-out. If autohide is on,
  the autohide duration is used instead.
- Material: Liquid Glass. The glass flag FUN_1000b4d40 returns 1.
  - Bottom Dock: `ECCartoucheGlassLayerController` (`GlassMaterialProvider.Configuration.cartouchePopover`,
    `Size.minimum`, `adaptive(false)`). This is a pill with a pointer.
  - Side Docks: `ECRoundGlassLayerController` with radius 13.
- Geometry, size 1:
  - pill radius 13;
  - pointer = square of side 16 rotated 45 deg, corner radius 2.5, vertical offset 4;
  - (15, 8) from 0x100186e18: minimum body width 15 + 2*13 = 41 and 8 pt reserved for the pointer;
  - smooth-union smoothness 25.
- Label layer height = max(26, text image height). The text image is capH + 2*floor((floor(ascent + descent + 5) - capH)/2),
  about 19 pt for 14 pt text. Body height = layer height - 8. Guess: an 18 pt pill plus an 8 pt pointer.
- Horizontal padding: not resolved. The text image is exactly the text width; the body is max(width, 41).
- Font: `CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 14)`. A second style is 11 pt system with monospaced digits.
  Text maximum width is 600 pt, truncated in the middle.
- Gap: the label sits 9 pt above the tile top minus `distanceTop` (5 pt when magnification is on).
- Agreement:
  - No delay: **agrees**.
  - Fade: **differs by 0.07 s** (code 300 ms cosine ease-in-out, measured about 0.23 s; the cosine tails are near-invisible).
  - Material: glass **found**. Height, radius and font: **found**, as above.

### 4. Minimise (genie, scale, suck)
- Code:
  - Dock effect duration in ms (DockBar `effectDur`): `doCommand:` 0x10002f05c and FUN_1000568a4 set genie 500
    (0x43fa0000), suck 400, scale 200.
  - Window animation: minimise FUN_100053ca0, restore FUN_100054204, `-[WAWindow genieTo:direction:genie:]` 0x1001cd4fc.
  - Genie mesh step: FUN_10006933c, two cosine phases whose lengths are 50 * int(ln(distance/2 + 1)).
- Durations:
  - genie = pref `genie-speed`, default 0.5 s (x10 with Shift);
  - scale 0.25 s (2.5 s);
  - suck 0.4 s (4 s);
  - genie falls back to scale when the target rect is under 5 pt.
- Timing: no timing function is set, so the WATransaction default applies (FUN_100007f34 default duration 0.25,
  timingFunctionForType(0)).
- WATimingFunction table at 0x100258470:
  - 0 = bezier(0.25, 0.1, 0.25, 1);
  - 1 = linear;
  - 2 = (0.42, 0, 1, 1);
  - 3 = (0, 0, 0.58, 1);
  - 4 = (0.42, 0, 0.58, 1);
  - 5 = spring with mass 1, stiffness 100, damping 10.
- Minimise and restore use the same 0.5 s genie. `minimize-to-application` does not change the duration.
- Agreement: **differs by about 0.28 s** (code 0.5 s, measured 0.22 s for both directions).
  - Guess: the ease bezier(0.25, 0.1, 0.25, 1) reaches about 80 % by 0.22 s, and the rest is a small window near the icon,
    under the pixel-change threshold.
  - WindowManager only handles miniaturise for Stage Manager (`StageManagerMiniaturizeWindowTransitionModifier`), so normal
    minimise stays in the Dock.

### 5. Mission Control, Spaces bar, Cmd-Tab
- Mission Control runs in WindowManagerAgent (WindowManager.app). The Dock only forwards to it (`wmExposeCoordinator`,
  "Failed to show app expose via Window Manager").
- Preference defaults: WindowManager.framework `WindowManagerPreferencesController` init, stores at 0x1d2a7ad7c..0x1d2a7ae94.
  Each is a key string plus a Double default:

  | Key | Default |
  |---|---|
  | `ExposeSpringDampingRatio` | 1.0 |
  | `ExposeSpringResponse` | 0.25 |
  | `SpacesBarExitSpringResponse` | 0.125 |
  | `ExposeTrackpadVelocityThreshold` | 5.0 |
  | `ExposeTrackpadSpringResponseScale` | 0.6 |
  | `MissionControlAppIconSize` | 48.0 |
  | `AnimationSpeed` | 1.0 |

- WindowManagerAgent SpringBehavior:
  - `SpringBehavior.init(dampingRatio:response:)` 0x100073a14: tension = (2pi/response)^2,
    friction = dampingRatio * 2 sqrt(tension), settlingDuration from CASpringAnimation (mass 1) at 0x10007394c.
  - Factories: expose 0x100134554 (1.0, 0.25), Spaces bar exit 0x1001345a0 (1.0, 0.125), trackpad 0x1001345e4
    (response x 0.6 when |velocity| > 5).
  - The globals are filled at 0x1003d9574 and read by about ten Expose and Mission Control modifiers (e.g. FUN_10021ffa8,
    FUN_10025d374, FUN_1003aadb4).
- Mission Control enter and exit use the same spring: critically damped (no overshoot), response 0.25 s. Its time to within
  0.1 % is 0.37 s.
- Agreement:
  - Total duration: enter **agrees** (0.37 against 0.38 s); exit **differs by 0.04 s** (measured 0.33).
  - Curve: **differs**. The recorded progress is slower in the middle (best critically damped fit: response 0.41 s for enter,
    0.30 s for exit). Guess: the pixel-change metric is not the spring position.
  - Spaces bar: exit spring 0.125 s **found**; it was not measured.
- Cmd-Tab: Dock `-[ASAppSwitcher show:]` 0x1000897d4, `-[ASAppSwitcher exit:immediately:]` 0x10008a0f8,
  `-[BezelIconList show:]` 0x10003919c, `-[BezelIconList hide:completion:]` 0x100039438, fade block FUN_1000396d4.
  - It is in the Dock process. The `AppSwitcher/OutOfProcessAppSwitcher` feature check at 0x10008259c finds no domain plist,
    so it is off.
  - Show: the windows are ordered in at system level 0x1f2 with no animation.
  - Release of Cmd (`exit:1 immediately:0`): the layer opacity goes to 0 in a CATransaction with
    `kCAMediaTimingFunctionEaseInEaseOut`. No duration is set, so the CA default of 0.25 s applies (inferred: no override
    found on this path).
  - Agreement: appears instantly **agrees**; fade-out **differs by about 0.15 s** (code 0.25 s ease-in-out, measured about
    0.1 s). The cause was not found.

### Side notes (found in passing)
- Guess: the tile move animation uses `moveSpeed` 270 ms with cosine ease (FUN_100011268), which may be the measured 0.25 s
  slot growth on app insert. Not checked against the insert path.
- All Dock DockFloatAnimatedProperty instances (fish, blend, x, scale, squeeze, autoHide) are created with
  `_easingFunction` = 1, which is cosine ease-in-out.

## REA 27.2.1: Notification Center panel (open, close, trackpad swipe)

Binary: `/System/Library/CoreServices/NotificationCenter.app/Contents/MacOS/NotificationCenter`, arm64e slice
(`lipo -thin arm64e`), Ghidra 12.1.4. All addresses are in that slice. Type and field names come from Swift reflection
metadata (`CenterAnimationController`, `MainController`, `FluidSpringAnimator`). The panel animation code lives in the app
itself. The frameworks it uses only supply the curve (SwiftUI `Animation`) and the system gesture (WindowManager
`NotificationCenterSystemGesture`). Pseudocode excerpts are in `~/hyprk/reference/re/27.2.1/decomp/NotificationCenter-panel.c`.

### 1. Click open and close (clock click, Esc, click outside): one SwiftUI spring for both directions
- Open: `CenterAnimationController` open request `FUN_1001c10d0` (log "Center open requested (%s)")
  -> `MainController` `FUN_100176de0` -> `FUN_1001d39d8` -> main-queue async `FUN_1001fbb08` -> `FUN_1001e18b0`
  -> `FUN_1001e19c4` = `withAnimation(DAT_1003c1388, completionCriteria: .logicallyComplete) { FUN_1001e195c }`.
  `FUN_1001e195c` sets the panel model's `openProgress` (+0x68, setter `FUN_1001ddd18`) to 1.0 and its x offset
  (+0x30, setter `FUN_1001dd848`) to 0.
- Close: close request `FUN_1001c175c` (log "Center close requested %s") -> `FUN_100178444(0)` -> `FUN_1001d3ebc`
  -> the same `FUN_1001e19c4` with closure `FUN_1001e1b58`, which sets openProgress to 0 and the x offset back to
  the model's width W (+0x58). After that it calls `FUN_1001773d0(animated: false)`, which only does cleanup (it
  releases key focus and does no animation).
- Curve `DAT_1003c1388`, built by `FUN_1001910a4` -> `FUN_1001910d8`: `Spring(duration: 0.3 (@0x1002dbd50), bounce: -0.2
  (@0x1002dbd58))`. The conversion is SwiftUI's own, inlined: stiffness = (2π/duration)², dampingRatio = 1/(1+bounce)
  for bounce < 0, damping = 2·√stiffness·ratio. It ends in
  `Animation.interpolatingSpring(mass: 1, stiffness: 438.65, damping: 52.36, initialVelocity: 0)`.
  - In plain terms: **response 0.3 s, damping ratio 1.25** (overdamped, so it never overshoots).
  - Closed form: x(t) = 1 − (r2·e^(r1·t) − r1·e^(r2·t))/(r2 − r1), with r1 = −41.89 and r2 = −10.47 per second.
  - Values: 0.54 at 0.1 s, 0.72 at 0.15 s, 0.84 at 0.2 s, 0.94 at 0.3 s, 0.98 at 0.4 s. It reaches 90 % at 0.25 s,
    95 % at 0.31 s and 99 % at 0.47 s.
- What moves: only the x offset (W -> 0 on open, 0 -> W on close), plus openProgress (0 -> 1).
  - No opacity, scale or blur call sits in this path (checked: the two closures touch only these two fields).
  - The view-side use of openProgress (`OpenSlideModifier`: inCenter, clamp, transitionProgress, hideInWidgetEditing,
    reduceMotion) was not traced.
  - W is a model field; its value was not read. Guess: 424 pt. The gesture code uses `frame.width − 424` and
    `424` (@0x1002dd998 / @0x1002dd9a0, `FUN_1001c7498`) as the right-edge panel region.
- Agreement with the recording: **differs**.
  - Open: the recording (0.11 … 0.99 over 17 frames) fits a critically damped spring with response 0.3 s (RMS
    0.015). The code's ratio of 1.25 fits worse (RMS 0.055): at frame 17 the model gives 0.94, the recording 0.99.
  - Close: the recording (0.92 … 0.11 in 9 frames, then gone) fits response 0.25 s with ratio 1.0 (RMS 0.013), while
    the code's curve would still be at 0.28 after 9 frames.
  - Guess, not verified: `.logicallyComplete` lets the completion run before the spring settles, so the window may be
    ordered out early and the tail is cut. That does not explain why the open looks faster than the code.
  - Nothing else in the binary drives a click open or close, so treat the code values as the real ones and the
    recording as possibly distorted (pixel-change share, about 58 fps).

### 2. Two-finger swipe from the right trackpad edge: interactive, follows the finger
- The gesture is recognised by WindowManager (`WindowManager.NotificationCenterSystemGesture`, with show and hide
  directions) and comes in as a progress value.
- `FUN_1001c6ca8` stores it at most once per display refresh (`eventQueue_currentVBL` throttle):
  - p < 0 -> 0;
  - p > 1 -> rubber band 1 + 0.25·(p−1)/((p−1)/0.75 + 1) (limit 1.1875);
  - the value is passed on through a dispatch-source "data replace" (`progressSource`).
- The handler `FUN_1001c3a14` -> `MainController` `FUN_100178548` sets x offset = (1 − p)·W directly, with no
  animation. So the panel tracks the finger 1:1.
- Release: `FUN_1001c70b4` (log "System gesture did end, close=%d, velocity=%f"). The close/open decision and the
  velocity come from WindowManager; no threshold constant is in NotificationCenter (not traced in WindowManager).
  - close -> `FUN_1001773d0(animated: true, reason 2, velocity: −v)`;
  - open -> `FUN_1001781b4(progress, velocity)`.
  - Both run `FluidSpringAnimator` (below), not the SwiftUI spring.
- `FluidSpringAnimator` (class `_TtC21NotificationCenterApp19FluidSpringAnimator`):
  - Timer: a Combine DispatchQueue timer every 1/60 s (`FUN_10021099c`, frameRate 60, fixed at both call sites).
    It is created by `FUN_100210c50(progress, velocity)`; velocity is 1.0 when none is passed.
  - Per tick, `FUN_100211574`, with p = progress and v = velocity:
    ```
    v = 0.695·v + 2·(1 − p)          // 0.695 @0x1002e1768
    p' = p + v/60
    if !allowOvershoot && p' > 1 { p = 1; v = 0; done }
    v = 0.85·v − 0.8·(p' − 1)          // 0.85 @0x1002cda98, −0.8 @0x1002e1770
    if |v| < 0.01 { p = 1; v = 0; done } else { p = p' }   // 0.01 @0x1002dea10
    ```
  - Overshoot is allowed when completing an open and off when completing a close.
  - Offset mapping: open = (1 − p)·W (callback `FUN_100179e90` -> `FUN_100178330`); close = p·W
    (`FUN_1001778a4`; it animates p from 1 − current toward 1).
  - From rest (p 0, v 1) it gives per 60 Hz frame: 0.045 0.11 0.19 0.27 0.35 0.42 0.49 0.55 0.61 0.66 0.70 …
    0.90 at frame 19, 0.95 at frame 24.
  - With a real release velocity it starts faster. This path was not covered by the recording (it used clicks).

### 3. Stagger, delay
- NotificationCenter has no `Animation.delay` call site; the only animation modifier used is `speed` (once).
- The open and close closures set two scalars on one model, so the whole panel moves as one piece. No per-widget or
  per-notification stagger was found.
- Not traced: per-item effects inside `OpenSlideModifier` or `BannerTransitionModifier`. The latter's provider enum
  has cases completeSlide(start, velocity), none, slide and fade, plus `__Key_bannerSlideProgress`, and is used for
  notification banners.

### 4. Other NotificationCenter animation constants (for reference, not the panel)
- spring(response 0.35, ratio 1.25), `DAT_1003c1390`: widget Add Sheet show/hide (`FUN_1000fc6d4` "ShowAddSheet",
  `FUN_1000ee9c8` "Hide Add Sheet").
- spring(response 0.3, ratio 1.25), `DAT_1003c13b8`: used in `FUN_1001bc2fc`.
- spring(response 0.2, ratio 1), `DAT_1003c13a8`: used in `FUN_1002023c4`.
- `CASpringAnimation` mass 1, stiffness 20.00008, damping 8.94429, duration 1.40496 (critically damped, response
  1.405 s), `DAT_1003c13a0`: used with `_interiorLightFraction` / `_exteriorLightFraction` keys (`FUN_1000e5730`), so
  probably a light or indicator effect.
- `interpolatingSpring(mass 1, stiffness 100, damping 100, initialVelocity v/100)` in `FUN_1001e2284` (ratio 5):
  velocity-driven, probably the notification swipe dismissal (guess).
- `easeInOut` 0.1, 0.15, 0.25, 0.35 and 0.5 s; `spring(0.5, 0.85)` ×7; an `NSAnimationContext` group of 0.15 s
  linear (`FUN_10017b76c`).

## REA 27.2.1: HUD, Control Center, Notification Center, Spotlight, symbol effects

macOS 27.2.1 (26B131), MacBook Air M2. Apps are read as their arm64e slice (`lipo -thin arm64e`, image base
0x100000000). Frameworks come from the dyld shared cache and are listed at their cache addresses. Tools: `dyld_info
-disassemble`, a stub resolver (call targets inside the cache resolved with `dladdr` in a live process), Ghidra 12.1.4 headless.
Swift names come from reflection metadata; the RenderBox C++ names come from the extracted image's symbols.
Pseudocode excerpts (about 170 KB) are in `~/hyprk/reference/re/27.2.1/decomp/`: `SystemBannerUI-hud.c`,
`MenuBarAgent-banner.c`, `ControlCenter-panel.c`, `NotificationCenter-panel.c`, `SpotlightUIInternal-window.c`,
`RenderBox-symbol-animation.c`.

**Spring notation.** "Spring(d, b)" is SwiftUI `Spring(duration:bounce:)` or CoreAnimation
`CASpringAnimation(perceptualDuration:bounce:)`. Both use stiffness = (2π/d)²; the damping ratio is 1 − b for b ≥ 0 and
1/(1 + b) for b < 0. The apps inline this conversion before calling `interpolatingSpring(mass: 1, …)`.

### 1. Volume and brightness HUD
**Who draws what.**
- The window belongs to MenuBarAgent. Its system-banner scene hosts content made in the ControlCenter process.
- ControlCenter's `SystemBannerService` (`showVolume:max:isEnabled:` at ControlCenter 0x10041238c) builds a
  `VolumeSystemBannerContent` (ControlCenter `FUN_10040f684`).
- That content is rendered by **SystemBannerUI.framework**, which does the capsule, glass, glyph, slider and the
  appear/hide animation.

**Size.** SystemBannerUI `FUN_2aed61dd8`: `frame(width: 307, height: 66)`, `HStack(spacing: 7)`, padding leading 16,
trailing 31, vertical 18. The window content rect is 367 wide (`FUN_2aed4ea84`, `initWithContentRect` width 367).
- Agrees: recorded 307.5 × 65.5 (within the 0.5 pt edge anti-aliasing) and window 367 wide.
- Trailing padding 31 agrees with the recorded 30.5. Bar start: 16 + glyph frame + 7 against the recorded 63; the
  glyph frame width was not read.

**Position.**
- `BannerContentController` init (`FUN_2aed44e40`): `_scaleFactor` 0.9, `_opacity` 0, `_topMargin` 10. So 10 pt
  under the menu bar agrees.
- The 10 pt right margin was not found as a constant. The window (367 wide) is centred on the capsule with 30 pt
  around it; MenuBarAgent places it. Not confirmed.

**Appear.** `FUN_2aed4c4c0`. For the first show, `withAnimation(Animation.interpolatingSpring(mass: 2, stiffness: 300,
damping: 50))` runs (static `DAT_2e1bf6780`, set in `FUN_2aed436a4`). It animates scale 0.9 → 1 and opacity 0 → 1.
- That spring has ω0 12.25 rad/s and damping ratio 1.02 (just overdamped). Content values: 0.34 at 0.1 s,
  0.69 at 0.2 s, 0.87 at 0.3 s, 0.95 at 0.4 s, 0.98 at 0.5 s.
- **Agrees** with the recorded about 0.55 s. The recorded alpha fits *opacity²* almost exactly (RMS 0.017 with no
  time shift). A reason it could be squared (inference, not verified): the view uses `.opacity(o)` and the glass is
  `_Glass.controlCenter.mix(with: .identity, by: 1 − o)` (see Glass below), so it fades twice.
- The recorded width 0.82 → 0.92 at the start is the scale 0.9 → 1 seen through that fade. Agrees.

**Content swap (volume ↔ brightness, repeated presses).** When content is already showing, the same function uses
`spring(response: 0.2, dampingFraction: 0.85)` (static `DAT_2e1bf6788`, `FUN_2aed436dc`) for the new content. It then
runs the interpolating spring again through `FUN_2aed49f8c`.
- Agrees: crossfade in about 3 frames.
- The bar fill is `TickedSliderTrack` / `TickedTrackMask` (fill width = value × width, so it moves continuously). It
  changes inside that 0.2/0.85 spring, which settles in about 0.2 s. Agrees with the recorded continuous fill that
  eases out in 0.15–0.2 s.

**Hide.** `FUN_2aed49520` / `FUN_2aed49a34`: `withAnimation(spring(response: 0.48669, dampingFraction: 1))` (static
`DAT_2e1bf6778`, `FUN_2aed43744`). The end values are scale 0.9 and opacity 0 (`FUN_2aed44be4`). The dismissal
completion runs on `DispatchQueue.main.asyncAfter(now + 0.48669)`.
- Agrees: recorded alpha ≈ (1 − x)² with RMS 0.017.
- The glyph and bar "linger to about 0.5 s" matches the 0.48669 s completion delay.
- The recorded ~0.3 s is the time to 5 % of the squared value.

**Idle timeout.** MenuBarAgent `FUN_10031d44c` maps `SystemBannerTimeoutMode` to seconds: custom(t) → t, short → 1.0,
standard → 4.0, long → 20.0, keepAlive → assert.
- The timer restarts from `lastClientUpdateTime` on every press
  (`extendSystemBannerAssertionLifetimeWithID:lastClientUpdateTime:timeoutMode:…`).
- The recorded 1.05 s fits `short` (1.0 s) plus about 3 frames of hosting latency. Guess: the volume banner uses
  `.short`; the mode ControlCenter passes was not traced.

**Steps.**
- `TickedTrackMask(tickCount: 16, tickWidth: 1.0, tickProgress: 0|1)` (`FUN_2aed661ec`). The track frame height is 4;
  the leading corners have radius 2, and the trailing corners too when value == 1. Agrees with 16 dashes and 4 pt
  height.
- The key step of 1/16 and 1/64 with Option+Shift is **not found** in MenuBarAgent, ControlCenter or SystemBannerUI;
  the key handling lives elsewhere.

**Glyph.** SystemBannerUI `FUN_2aed5ab20`, used when ControlCenter gives no device image: `Image(systemName: "speaker." + x)`
with `.symbolVariant(.fill)`. x is:
- `slash` when value < 0.001;
- `wave.1` when value < 0.333;
- `wave.2` when value < 0.667;
- `wave.3` otherwise.

Agrees: wave.1 at 3/16, wave.2 at 7/16, slash when muted.
- No symbol effect is applied to the HUD glyph; SystemBannerUI imports no SymbolEffect API.
- The Control Center Sound module and the menu bar extra use a different rule (ControlCenter `FUN_1005542f8`):
  `speaker.wave.3.fill` with `variableValue` 0.01 / 0.34 / 1.0 at the same 0.333 / 0.667 thresholds,
  `speaker.slash.fill` under `muteVolumeEpsilon`, and `headphones` / `headphones.slash` for headphones.

**Glass.** `_glassEffect(_Glass.controlCenter.mix(with: _Glass.identity, by: 1 − opacity), in: Capsule())`.
- `_Glass.controlCenter` is static `DAT_2e1bf6760`, set by `FUN_2aed43774`. SwiftCore encodes it as tag 0x48, which is
  index 9 = `InternalConfiguration.Base.controlCenter`, so DesignLibrary's **ControlCenterRecipe** applies (IdiomModifier
  0x195f0a2bc, MacICExtra 0x195f0a2c4, RTExtra 0x195f0a2c0; decoded in `recipes-annotated.c`).
- No subvariant is set. The glass fades by mixing towards identity, not through its alpha.

### 2. Control Center panel (bento box)
**Open and close.** Both run in ControlCenter. Open is `FUN_1002dc74c`, close is `FUN_1002dce40` (completion log "bento
box dismiss animation did complete"). Both call `withAnimation(DAT_10095bf80, completionCriteria: .logicallyComplete)`.
- `DAT_10095bf80` is set by `FUN_10027f1f8` → `FUN_10027f228`: `Spring(duration: 0.25, bounce: -0.027)`, which
  becomes `interpolatingSpring(mass 1, stiffness 631.65, damping 51.66)`. That is **response 0.25 s, damping ratio
  1.028**.
- It animates a transition progress p. `FUN_1002db3fc` maps it to the view state:
  - appearing: `bentoBoxOpacity` = p, `bentoBoxScale` = 1.01 − 0.01·p (@0x1006f2bf8 = 1.01, @0x1006f2c00 = −0.01);
  - dismissing: opacity = 1 − p, scale = 1.0 → 1.01;
  - hidden: opacity 0, scale 1.01.

**Agreement.**
- Open: agrees. The model gives 0.13, 0.28, 0.43, 0.56 … 0.96 at 12 frames; recorded 0.16, 0.29, 0.40, 0.51 …
  0.94 (about half a frame offset). This is the "ease-out mostly done in 0.15 s".
- Close: agrees. 95 % is reached at 0.19 s; recorded 0.17–0.2 s.
- Scale: differs. There is a 1 % scale (1.01 → 1.0 on open, 1.0 → 1.01 on close) that the recording reported as "no
  scale". It is 3–4 pt on a 350 pt panel and probably below what the recording could resolve.

Module tile sizes: not done.

### 3. Notification Center panel
Sent earlier as `REA-B-NC.md`; full detail there and in `NotificationCenter-panel.c`. Summary:

**Click open and close.** Both use one SwiftUI `Spring(duration: 0.3, bounce: -0.2)`: response 0.3 s, damping ratio
1.25 (`FUN_1001910a4` → `FUN_1001910d8`, static `DAT_1003c1388`).
- It is used through `FUN_1001e19c4` (`withAnimation(…, .logicallyComplete)`). Open sets x offset 0 and
  openProgress 1 (`FUN_1001e195c`); close sets x offset W and openProgress 0 (`FUN_1001e1b58`).
- It moves x only: no fade, scale or blur, and no `Animation.delay` (no stagger).

**Agreement: differs.** The recording fits a critically damped spring better: response 0.3 s for open (RMS 0.015
against 0.055) and 0.25 s for close.

**Trackpad swipe.** WindowManager's `NotificationCenterSystemGesture` supplies the progress; the panel follows it 1:1.
- Above 1 it rubber-bands as 1 + 0.25(p−1)/((p−1)/0.75 + 1) (`FUN_1001c6ca8`).
- Release (`FUN_1001c70b4`): WindowManager decides close or open and supplies the velocity. Completion runs
  `FluidSpringAnimator` at 60 Hz (`FUN_100211574`):
  `v = 0.695v + 2(1−p); p += v/60; v = 0.85v − 0.8(p−1)`, stopping when |v| < 0.01.

### 4. Spotlight (SpotlightUIInternal.framework; Spotlight.app holds no UI code)
**Search field glass.** The glass elements are drawn by the `GlassEffect` / `GlassElementModifier` path,
`FUN_2adf11f2c`:

    materialEffect(Material._glass(_GlassVariant.regular.size(.large).adaptive(false).excludingShadow()
                   .interactionState(.disabled).contentLensing(true)), in: _ShapeSet(shapes, smoothness))

- So in 27.2.1 the field uses the **Regular** recipe at size large, with content lensing ("lens") switched on. It does
  **not** use SiriRecipe or a `spotlightField` subvariant; that string does not occur in SpotlightUIInternal, SearchUI,
  SpotlightUIShared or SpotlightUIServices. The SiriRecipe branch-A/lens question therefore does not apply to the field.
- Guess, not traced into DesignLibrary: `contentLensing(true)` resolves to `ResolvedContentEffect.lense` on that
  recipe.

**Results panel glass.** `FUN_2ade6f690`:
`_glassEffect(_Glass.siri.subvariant("searchResults").adaptive(false).excludingShadow(true), in: RoundedRectangle(cornerRadius: 37))`.
- Base `siri` with subvariant `searchResults` takes SiriRecipe **branch A** (not `.listening`) unless contentEffect
  resolves to `.lense`. The call sets no contentEffect, so it gets the default, which was not traced.
- Branch A values: face YCC 0.1 / 1.0 / 1.25, blur 8, no ring shadow.
- A second path, `FUN_2ade65b28`, uses public `Glass.regular` with `glassEffect` plus a window drag gesture. It is
  probably the compact or drag state (guess).

**Open (invocation).** `FUN_2ade99418` → `FUN_2adea2ff0` adds three `CASpringAnimation`s on the content layer:
- `transform.scale.x` 1.12 → 1: Spring(0.28, bounce 0.41), or 0.32 under a flag;
- `transform.scale.y` 0.95 → 1: Spring(0.28, 0.32);
- `transform.translation.y` → 0: Spring(0.28, 0.32).

The window also gets `alphaValue` with Spring(0.28, 0.41) in `FUN_2ade9ef14`. `WindowAnimationCoordinator.
InvocationAnimationState` = {xScale 1.12, yScale 0.95, opacity 0, blurRadius 25}, from `FUN_2ade9a5ec` and
`FUN_2ade9bff0`.

Agreement: partly.
- The code starts at 1.12× width, not the recorded 1.05×. Model x at frames 1–5: 1.113, 1.096, 1.074, 1.052, 1.031,
  1.003 at frame 7, then a slight undershoot (0.995 at frame 8, 0.99 at frame 9). With the alpha fade, the first clearly visible frame is around
  frame 3–4, at about 1.05–1.07×. So it agrees if the first visible frame is about 3 frames in.
- The code fades alpha in over about 0.1 s and squashes y 0.95 → 1; the recording saw "no fade-in". Differs slightly.

**Close (dismissal).** `FUN_2ade9c2dc` → `FUN_2adea36c8`:
- layer `transform.scale.x` 1 → 1.12, `scale.y` 1 → 0.95 and `translation.y` → 0, each Spring(0.45, bounce 0.05);
- window `alphaValue` Spring(0.28, 0.41) and `contentBlurRadius` 0 → 25 with Spring(0.51, 0.05) (`FUN_2ade9ef14`, flag 0).

Agrees qualitatively: fade + blur + slight growth. The recorded 0.05 s is shorter than these springs; the window
probably orders out once the alpha is about 0.5 (guess).

**Other springs.** `WindowAnimationCoordinator.Animations` statics (`FUN_2ade84974` ff.):
- Spring(0.49, 0.15).delay(0.17);
- Spring(0.71, 0.01) and Spring(0.39, 0.39);
- size-dependent set A: (0.35, 0.43), (0.45, 0.39), (0.55, 0.35), (0.6, 0.31);
- size-dependent set B: (0.41, 0.394), (0.55, 0.35), (0.65, 0.32);
- Spring(0.41, 0.12) and Spring(0.2, 0.05).

These are used for resize, morph and jump-to-app; the mapping was not traced.

### 5. SF Symbol effects
**Where the system UI applies them.**
- ControlCenter is the only one of the four apps that uses them, through SwiftUI. The contexts below come from nearby
  strings and are marked as guesses:
  - `variableColor` `.sequential.reversing` as an indefinite `_SymbolEffectModifier`: `FUN_10031ec60`, the Wi-Fi
    module (WiFiContentView), so most likely Wi-Fi searching;
  - variableColor sequential reversing plus `pulse`: `FUN_100425e18` (ListeningMode / MusicRecognition area);
  - indefinite `Pulse`: `FUN_1005315c0`, Screen Mirroring;
  - `Appear.up` transition: `FUN_10055d874`;
  - `DrawOn` transition: `FUN_1005dedd8`;
  - `Bounce`, `Replace`, and `Rotate` with `SymbolEffectOptions.speed(2)`: `FUN_100266fc8`
    (Bluetooth / app status items);
  - `ContentTransition.symbolReplace(.default)` at 10 sites, among them the Sound module (`FUN_10055494c`), Bluetooth
    (`FUN_10023f8c8`, `FUN_100240188`) and the menu-extra symbol (`FUN_10036fba8`,
    `SystemBannerAwareMenuExtraSymbolView`).
- MenuBarAgent, NotificationCenter, SystemBannerUI (the HUD speaker) and SpotlightUIInternal import no symbol-effect
  API. So the NC bell and the HUD speaker have no effect in 27.2.1.
- AirDrop was not found in these four.

**Implementation.**
- The Symbols framework holds the public API. `-[NSSymbolEffect _rbAnimation]` maps effects to RBSymbolAnimation ids
  (table @0x196a61330): variableColor 1, pulse 2, bounce 3, scale 4, appear 5, disappear 9, wiggle 10, rotate 11,
  breathe 12, drawOn 13, drawOff 14. Replace uses 6–8; not mapped.
- The engine is **RenderBox.framework, `RB::Symbol::Animation`**.

**Durations** at speed 1, from `local_duration` 0x196b15570, `intro_duration` 0x196b15904 and `outro_duration`
0x196b15b9c:

| Effect | Duration |
|---|---|
| Bounce | 0.70 s; in split intro/outro mode 0.4333 intro + 0.2667 outro |
| Wiggle | 0.935 s; split mode 0.3333 + 0.41667 |
| Rotate | 2.0 s; split mode 2.5 intro and 2.5 outro |
| Pulse | 2.0 s (1.0 s with flag bit 31) |
| Breathe | 3.0 s |
| Scale, Appear | 0.25 s |
| Disappear | 0.1667 s |
| Variable color | 1/3 + 1/3·clamp(layers, 1, 3), with other forms for more layers |
| Replace | 0.667, 0.7, 1.0, or 0.25/0.5 depending on style |
| DrawOn / DrawOff | `draw_duration` with a base of 0.25 / 0.1667 per layer |
| Default | 1/3 s |

**Per-layer delay** (`layer_delay` 0x196b15dc0).
- Bounce and wiggle: 0.05 s per layer; with more than 4 layers, 0.15/(n−1). Down bounces run the layers in reverse
  order.
- Variable color: the layer index times 1/9 · (1/3 + n/12 + (2n−8)/60)⁻¹ … for more than 3 layers. The exact form is
  in the excerpt.
- `frame_delay`: 0.05 s for the variable-color and pulse types.

**Keyframe tables** (`bounce_keyframes` 0x196b18c14 etc.).
- Bounce peak 1.109 (up) / 0.909 (down); whole-symbol values 0.95 / 1.05 and 1.059 / 0.95.
- Bounce segment times 0.21667, 0.21667 and 0.15 (minus the layer offset); outro 0.26667.
- Pulse goes 1 → 0 → 1 in two equal halves of 1.0 s (0.5 s with the flag).
- Wiggle angle 0.08727 rad = 5°. In the Symbols framework the direction angles are ±90°, 180° and 360°.

The exact meaning of each pushed value (scale or curve parameter) and the curve ids 1/3/4/5 were not decoded. The
wiggle and breathe keyframe functions failed to decompile. Treat the keyframe values as raw.

### Not found / not done
- Volume step size (1/16 and 1/64): not found in these images.
- The HUD's 10 pt right margin: not found as a constant.
- Timeout mode for the volume banner: `.short` is a guess.
- Control Center module tile sizes: not done.
- NC panel width W: probably 424 (guess).
- The view-side use of NC's `OpenSlideModifier`: not traced.
- Spotlight: the mapping of the Animations statics, and the results panel's contentEffect default: not traced.
- RenderBox keyframe curve semantics: not decoded.

## Answers from system files (no GUI)

- Q-dock-11 Default Dock items on a clean 27.2.1 account (Dock.app/Contents/Resources/default.plist, persistent-apps
  in order): Apps, Safari, Messages, Mail, Maps, Photos, FaceTime, Phone, Calendar, Contacts, Reminders, Notes, TV,
  Music, Keynote Creator Studio, Numbers Creator Studio, Pages Creator Studio, Games, App Store, iPhone Mirroring,
  System Settings (the three Creator Studio apps only appear if installed). persistent-others: the Downloads folder
  (showas 1 = Fan, arrangement 2 = Date Added; the usual Dock key meanings, 0 automatic, 2 grid, 3 list). Finder is not in the list because the Dock always puts it
  first; Trash is always last. So: Finder, Apps (the Launchpad replacement), ... System Settings | Downloads, Trash.
  Recent apps section: `show-recents` defaults to on (separator before the recent apps).
- Q-settings-08 Sidebar order (System Settings.app/Contents/Resources/Sidebar124.plist): groups separated by a gap:
  1 Apple Account, Family | 2 follow-up suggestions (only when there are any) | 3 Wi-Fi, Bluetooth, Network, VPN,
  Battery (Battery only on Macs with one; desktops show Energy) | 4 ClassKit / Classroom (only when managed) |
  5 General, then alphabetically sorted: Wallpaper, Accessibility, Appearance, Menu Bar (ControlCenter-Settings
  extension, titled "Menu Bar" on 27), Desktop & Dock, Displays, Siri, Spotlight -> shown sorted by localised name
  (en: Accessibility, Appearance, Desktop & Dock, Displays, Menu Bar, Siri, Spotlight, Wallpaper) | 6 Notifications,
  Sound, Focus, Screen Time | 7 Lock Screen, Privacy & Security, Touch ID & Password, Users & Groups |
  8 Internet Accounts, Game Center, iCloud, Wallet & Apple Pay | 9 Headphones (when paired), Keyboard, Mouse,
  Trackpad, Game Controllers, CDs & DVDs, Printers & Scanners | 10 "Others" catch-all (third-party panes).
  Passwords is no longer a pane (it is an app).

## Q-dock (27.2.1)

How it was measured: user account (Dark icon style, Multicolour accent, tilesize 33, magnification off), 1710x1107 pt at 2x. Solid Electric Blue wallpaper (69,83,206) or solid colour windows placed behind the surface. Dock prefs were exported first, changed only for a test, and restored with import + `killall Dock`.
- Pictures: `reference/screens/27.2.1/dock/` (see INDEX.md).
- Data: `reference/re/27.2.1/live/dock/`: `dock-geometry.json`, `dock-live.json`, `dock-menus.json`, `mission-control.json`, `apps-window.json`, `reconciliation-42.json`.
- Another process's layer tree cannot be dumped, so "glass" answers below come from pixels.

- Q-dock-01: Material, from pixels only (no layer dump; the RE agents may have the recipe).
  - Dock background over solid colours, dark mode: white 176, black 12, grey 127 → 108, red → (248,38,20), green → (59,197,16), Electric Blue → (59,75,216). Fit on greys: 12 + 164·(in/255)^0.77, plus a saturation boost.
  - Light mode: white 229, black 38, grey 127 → 134, red → (255,58,38). Fit: 38 + 0.75·in, plus the same saturation boost.
  - Blur is small (σ about 1–2 pt): 8 pt bars stay fully resolved. Lens refraction within about 6 pt of the edges.
  - 1 pt bright rim. Over black: 104 top / 65 bottom in dark, 116 / 83 in light. An inner glow fades to the fill over about 5 pt.
  - No outer shadow (the white row right above the Dock stays 255).
  - The Cmd-Tab panel is pixel-identical (same material). (solid-colour windows behind the Dock)
- Q-dock-02: Default tile size and Dock size.
  - With the `tilesize` key absent the built-in default is 64 (AX identical to tilesize 64). A fresh account could not be checked.
  - Item pitch = tile+2 at 32/33 and tile+4 at 48/64. Dock height = tile+14 at 32/33 (46, 47) and tile+20 at 48/64 (68, 84).
  - Icon art ≈ 0.79·tile: 25.5 at 33, about 38.5 at 48, 50.5 at 64.
  - Width = 2m + n·pitch + s·(0.478·tile), where n = items, s = separators, m = 2.7 (32/33), 7.6 (48), 8.4 (64).
  - 10 items with no separator: 696.8 x 84 at 64, 355.6 x 47 at 33. Add 30.6 / 15.8 per separator.
  - Second display: not measured (MBA only). (AX + pixels at 32/33/48/64)
- Q-dock-03: Padding (tile 33).
  - Background top to art top: 10.5. Art bottom to background bottom: 11 (the dot sits there). Background left to first art: 8. Background bottom to screen edge: 5.
  - Tile 48: 15.5 / 15 / 15. Tile 64: 17 / 16.5 / 16.5.
  - The 5 pt bottom gap is the same at every size. (AX + pixels)
- Q-dock-04: Corner radius (circle fit): 14 at 32/33, 21 at 48, 27.6 at 64. At 64 a continuous-corner fit is better (31).
  - So about 0.43·tile, or 0.30–0.33·height. Not fixed. (corner fit on 2x crops)
- Q-dock-05: Icon spacing. AX item frames touch (0 gap).
  - Art-to-art gap: 9.5 at 33 (pitch 35, art 25.5) and 17.5 at 64. (AX + pixels)
- Q-dock-06: Separator.
  - Item 0.478·tile wide (15.8 at 33, 30.6 at 64). Line 1 pt wide, from background top+6 to bottom−6 (35 pt at 33), square ends.
  - Colour: vibrant blend, plus-lighter +65/255 in dark and plus-darker −57/255 in light. Same value over black, grey and white.
  - Art to art across it: 25.3 at 33. (pixels over 3 greys)
- Q-dock-07: Running dot.
  - Diameter 4.1, centred on the tile. Centre 5 pt below the art bottom (y 1096 at 33), 6 pt above the background bottom.
  - Colour: dark plus-lighter +125/255 (12 → 137, red background → (255,164,145)); light plus-darker −128/255.
  - Same single dot for a hidden app and for an app with 2 windows. (pixels)
- Q-dock-08: Hover label: yes, it is glass (a checker shows through, refracted, with a light rim).
  - Capsule 26 pt tall (r 13), width = text + 2·14 ("Finder" 67.5).
  - A tail at the bottom centre, about 16 wide x 6.5 tall, rounded tip, pointing at the icon. Tip 2.5 pt above the Dock background (13 pt above the art at tile 33).
  - Text: SF 14 regular, white in dark (244), near-black in light (37).
  - Fill over black / white: dark 31 / 180, light 131 / 249. Shadow very faint (≤3 levels).
  - Dock on the left: capsule to the right of the icon, 5.5 pt gap, no tail. (pixels over solids and patterns)
- Q-dock-09: Press state: art × 0.475 on all channels (rms 0.4), no scale.
  - On in 1 frame at mouse-down, off in 1 frame at mouse-up: no animation.
  - Holding opens the context menu in under 0.8 s. (stills + 60 fps)
- Q-dock-10: Context menu (Option alternates read from AX). Full lists are in `dock-menus.json`.
  - Running app: [recent documents] — [windows] — app items (e.g. New Document) — Options ▸ — Show All Windows, Hide/Show (Opt: Hide Others), Quit (Opt: Force Quit).
  - Options ▸ for a running unpinned app: Keep in Dock, Open at Login, Show in Finder.
  - Not running, pinned: Options ▸ (Remove from Dock, Open at Login, Show in Finder) — Open.
  - Finder: [windows] — New Finder Window, New Smart Folder, Find… — Go to Folder…, Connect to Server… — [recent folders] — Show All Windows, Show/Hide. No Quit.
  - Downloads: Sort by (Name, Date Added, Date Modified, Date Created, Kind) — Display as (Folder, Stack) — View content as (Fan, Grid, List, Automatic) — Options ▸ (Remove from Dock, Show in Finder) — Open "Downloads".
  - Trash: Open — Empty Bin.
  - Shape: not the standard menu. It is a glass bubble with a tail at the icon centre, like the label, radius about 14 (visual). The submenu is a normal glass menu.
  - Placement: menu window x = icon centre − 40, so the body extends to the right of the icon. Window bottom = Dock top. Body inset 13 pt. Rows 24, separators 11, accent highlight pill. (AX + pictures)
- Q-dock-11: See nongui-answers.md: Finder, Apps, Safari, … System Settings | Downloads, Trash. Apps (the Launchpad replacement) is present and Finder is always first. Recents are on by default (Q-14).
- Q-dock-12: Stack, measured on my own test folder with 11 items.
  - Tile: "Stack" mode shows the newest file's icon; "Folder" mode shows the folder icon. While a stack is open its tile shows a chevron.
  - Fan: an arc rising to the right. Items grow from 65.5 to 78.3 pt bottom to top, step 64.6 pt. Glass capsule labels on the left. Top item "Open in Finder".
  - Grid: glass bubble with a tail, 546x438 for 11 items. Folder name title at the top. 4 columns, 128 pt cells. Last cell "Open in Finder". Radius about 28 (visual), so the SPEC's 16/24 is low.
  - List: the context-menu bubble (24 pt rows, small icons), then Options ▸ and Open in Finder. (AX + pictures)
- Q-dock-13: Minimised windows (minimize-to-application 0).
  - Own tile right of the separator, after the stacks, before Trash. Same tile size as apps.
  - Art: the window thumbnail fitted about 31 pt wide at 33 (1300x900 → 31x21.5), with the app icon about 10 pt at the bottom-right.
  - Genie: 0.5 s ease-in-out in both directions, 0.40–0.48 s visible; see Reconciliation (#42).
  - Built-in default mineffect = genie. minimize-to-application is off unless set (the user has 1). (AX + pixels)
- Q-dock-14: Yes. `show-recents` defaults to on: a second separator, then up to 3 recent non-running apps plus every running unpinned app (6 running apps gave 6 tiles).
  - Tiles look the same as the others. Setting: "Show suggested and recent apps in Dock". (AX)
- Q-dock-15: Badge (own test app, tile 33).
  - 13 pt tall. A circle for 1–2 digits; grows to the left (999 → 16, 12345 → 22). From about 34 pt it is middle-truncated ("New…sage").
  - Top 4 pt above the art top, right edge 3.75 pt outside the art. Red (228,84,69), white text about 9–10 pt.
  - Attention, critical: jump 36 pt (≈1.09·tile; a launch bounce is 11), then rebounds of 18 and 9 pt. Arcs 0.50 + 0.31 + 0.22 s, then about 1 s rest; repeats every 2.0 s until the app is activated.
  - Attention, informational: one group (36/18/9) only. (60 fps tracking)
- Q-dock-16: Autohide: pure slide, no fade, no visible sliver (0 px).
  - Trigger: bottom 2 pt (y ≥ 1105) anywhere along the bottom edge.
  - Show: starts about 0.23 s after reaching the edge, 0.17 s ease-out. Top edge per frame: 1105 1100 1094 1087 1083 1077 1070 1065 1060 1057 1055.
  - Hide: starts about 0.05 s after leaving, 0.17 s ease-in. (60 fps, autohide on temporarily)
- Q-dock-17: Drag out (own test app): the dragged icon keeps the Dock art size (no lift scale).
  - A "Remove" bubble (label style, with tail) shows above it once it is outside the Dock.
  - On release, icon and label fade out linearly in 0.25 s. No poof cloud seen.
  - Reorder gap: not measured. (stills + 60 fps)
- Q-dock-18: Left works.
  - Background x 4.5..52.5 (5 pt from the edge). AX list [10,202,47,738], items 47x35.
  - Label to the right, 5.5 pt gap. Dot on the left of the icon.
  - Settings still has the Left/Bottom/Right strings (DesktopSettings.appex); the pane itself was not opened. (orientation set temporarily)
- Q-dock-19: Cmd-Tab: same material as the Dock (identical fill, 59,75,216 over blue, and the same rim). No layer dump.
  - Corner about 58 pt circle-equivalent. The straight edge starts 56 pt from the corner, i.e. concentric: selection 34 + padding 24.
  - No separate shadow seen. (pixels)
- Q-dock-20: Cmd-Tab size.
  - 8 apps: panel 1114x176 at (298,466), exactly at the screen centre. Icon 128, pitch 134 (gap 6), padding 24 on all sides. The label sits inside the bottom padding.
  - 11 apps: 1516 wide.
  - 16 apps: icons shrink to 94 (pitch 100), panel [34,483,1642,142]. Still one row, 34 pt from the screen sides. (AX)
- Q-dock-21: Selection: a squircle 120x120 centred on the icon (button frame inset 4).
  - Corner like an icon: superellipse n≈3, extent 46 pt, circle-equivalent 34.
  - Fill: vibrant plus-lighter +65 in dark, plus-darker −57 in light. Flat, no blur.
  - Name only under the selected app: SF 13 bold. White in dark, dark in light. Top 2.5 pt below the 128 frame.
  - Hovering the pointer moves the selection; there is no separate hover state. (pixels + AX)
- Q-dock-22: Cmd-Tab behaviour.
  - Order is MRU (active app first, the previous one selected).
  - The panel shows about 0.19 s after Tab. A quick tap (release within about 30 ms) switches without showing it.
  - Keys: Tab, `, Shift-Tab and Left/Right move and wrap at both ends. Home/End jump.
  - Q quits the selected app; the panel stays open and the icon is removed.
  - H toggles hide/show of the selected app (no effect seen on the current app).
  - Hidden apps are listed. Release commits, Esc cancels. (AX + pixels)
- Q-dock-23: Dock "Apps" = `open -a Apps` (com.apple.apps.launcher, LSUIElement). The F4 key was not tested.
  - It opens a Spotlight-style UI drawn by the Siri process (layer 23, not in AX). It is not a normal app window, and there is no backdrop dim.
  - Window 844x617 at (433,251), centred horizontally.
  - Search capsule 520x87 (r 43.5, dark in both modes), a 10 pt gap, then a glass panel 844x520 (radius about 38 circle-equivalent, continuous corner extent 54.5).
  - R2 called it "an ordinary window"; that is wrong. (screencapture -l alpha)
- Q-dock-24: Grid.
  - 7 columns, pitch 115, first column centre 77 from the panel edge. Icon 60. Row pitch 102.
  - Label: SF 13 regular, white, cap top 11.5 below the icon, truncated with "…".
  - Order: a row of 7 suggested/recent apps, a 1 pt separator (x 20..824), then all apps A–Z.
  - Hover: no change. Keyboard: an accent focus ring, a 69 pt squircle. (pixels)
- Q-dock-25: Header = the separate capsule above the panel.
  - Placeholder "Applications", about 22 pt, grey. App Store glyph 26.5x23.5 at 32.5 from the left. "…" 17.5 wide at 37.5 from the right.
  - The "…" menu: View content as: Grid ✓ / List.
  - Chip row inside the panel: y +20, height 26, gap 8, inset 20.
  - Search filters the same grid in place. The field shows "cal — Open". The first result sits on a grey 68 pt plate. (pixels)
- Q-dock-26: No folders, no pages or dots, no wiggle/edit mode seen.
  - Categories are chips; clicking one puts a token in the field and filters the grid (iPhone apps included, with a phone badge).
  - It is a vertical list; a synthetic wheel did not scroll it (not verified).
- Q-dock-27: Mission Control backdrop: the wallpaper is not dimmed and not blurred (MC = desktop within 0.5% on Tahoe Light and on solid blue).
  - Only the Spaces bar band is a blur+tint material: ×0.8 on dark solid blue; lighter (×1.18) and blurred on Tahoe Light. A shadow below it over about 20 pt.
  - The menu bar is replaced by the bar. The Dock stays visible (R2 said it goes away; wrong). Widgets and desktop icons are hidden.
- Q-dock-28: MC window layout (frames in `mission-control.json`).
  - One uniform scale for all windows, as large as fits (max 1.0). The layout is spatial, kept near the real positions, not a grid.
  - 1 window: unchanged.
  - 2 overlapping: pushed apart vertically, scale 1, gap 13.
  - 4 stacked: scale 1, minimum gap about 11.
  - 5 spread: 0.965.
  - 7 stacked: 0.89, in the area x 17..1692, y 108..1043.
  - Windows keep their own shadow and radius.
  - Multi-display: not measured.
- Q-dock-29: Title on hover only, centred ON the window (not under it).
  - Capsule 30 pt tall, padding 14.5, SF 13 bold, black text, grey fill (106 over dark content).
  - No app icon seen (expose-group-apps 0). (pixels)
- Q-dock-30: Hover outline: an accent ring 4.5 pt wide, 1–1.5 pt outside the window frame (86,151,245 over blue).
  - It is a separate "Window Highlight Overlay" window = frame +6/7 pt.
  - No scale, no close button, arrow cursor. Drag to a Space: not tested.
- Q-dock-31: Spaces bar.
  - Band y 0..74 collapsed (covers the menu bar zone) and 0..166 when the pointer is at the top.
  - Collapsed: name pills ("Desktop" 75x24, r 12, additive +35 fill, SF 13 white, y 41.5). "+" is a 20 pt glyph at x 1674..1694, centre y 37.
  - Expanded: thumbnail 147x98 including a 3 pt accent ring (1 pt gap), name below in 13 pt.
  - A full-screen app gets its own tile with the app name. With a full-screen Space the bar opened already expanded.
  - The band is blur+tint material, not glass with a rim. (pixels + window list)

### Extra (#37)
- Mission Control with 3–5 windows: Q-27..31. Pictures: `mc-{light,dark}.png` (5 windows), `mc-bar-expanded-*`, `mc-hover-*`.
- Cmd-Tab with 5+ apps: Q-19..22. Pictures: `cmdtab-{light,dark}.png` (11 apps).
- Applications window: 844x617 (search capsule 520x87 + panel 844x520), centred.
  - Category list in order: Utilities, Developer Tools, Social, Productivity & Finance, Entertainment, Creativity, Information & Reading, Travel, Other. It depends on the installed apps and scrolls sideways.
  - Grid: icon 60, pitch 115 x 102, 7 columns, labels 13 pt.
  - Launching an app (click or Return) closes the panel.
  - Esc: the 1st Esc removes the Apps panel in one frame but leaves the plain Spotlight bar ("Search or Ask"); the 2nd Esc closes it. Reopening soon keeps the last query.
  - Pictures: `apps-{light,dark}.png`, `apps-category-{light,dark}.png` (Utilities). Numbers: `apps-window.json`.

### Reconciliation (#42)

Method: 60 fps full-screen recordings (real frame timestamps), solid Electric Blue wallpaper, cursor not captured. Genie: per frame, the area that still differs from the final frame (menu bar, desktop widgets, text caret excluded), normalised to the window's area = "remaining". Fades: least-squares alpha `frame = after + a * (before - after)` over the panel / label rect, then easing fits. Data: `reference/re/27.2.1/live/dock/reconciliation-42.json`.

- (a) Minimise genie. The code's 0.5 s holds; the earlier 0.22 s came from a cut-off tail (the old metric was "share of total pixel change", which the big window body dominates; the thin genie neck sliding into the icon has few pixels and was lost under the threshold).
  - Last unchanged frame to first frame equal to the final frame:
    - TextEdit 300x200 near (700,400): minimise 0.43 s, restore 0.40 s.
    - TextEdit 300x200 far (1150,60): minimise 0.48 s, restore 0.42 s.
    - TextEdit 1300x900: minimise 0.45 s, restore 0.42 s.
    - The same window with minimize-to-application 0 (into its own tile): minimise 0.45 s, restore 0.48 s.
    - Finder 780x500: about 0.40 s of genie, then the other Finder window turns active 0.15 s later.
  - Remaining per frame, TextEdit 1300x900, minimise: 1.00 .98 .95 .91 .86 .81 .76 .71 .66 .62 .57 .53 .48 .43 .38 .32 .26 .20 .15 .10 .07 .04 .02 .01 .01 0. Restore (1 - shown): 1.00 .99 .98 .97 .94 .91 .87 .82 .76 .71 .65 .60 .55 .51 .46 .41 .37 .32 .28 .22 .16 .12 .08 .05 .01 0.
  - Fits on that series: ease-in-out (.42,0,.58,1) T = 0.50 s (minimise 0.496, restore 0.504), starting about 2 to 3 frames before the first visible change (the slow start is invisible). The small window gives T 0.36 to 0.45 s with a visible part of 0.40 to 0.48 s.
  - The duration does not depend on window size, distance or minimize-to-application (all within 0.40 to 0.48 s visible). Minimise and restore take the same time. The last 5 % (the neck going into the icon) takes about 0.08 s.
- (b) Cmd-Tab hide on releasing Cmd: alpha per frame (17 ms): 1.0, .94, .94 (a duplicated capture frame), .80, .70, .59, .48, .36, .25, .17, .09, .05, .015, .003 (0). Truly 0 at 0.217 s after the last full frame.
  - Fit: ease-in-out (.42,0,.58,1) T = 0.236 s, rms 0.014 (cosine 0.224 s). Two recordings gave the same result.
  - So the code's 0.25 s ease-in-out is right. The earlier 0.1 s was only the steep middle (0.8 to 0.1) above a changed-pixel threshold.
- (c) Dock hover label fade-out after the pointer leaves the Dock: alpha .997, .985, .94, .90, .87, .79, .70, .62, .53, .48, .38, .28, .19, .125, .07, .05, .009, 0 (17 ms steps). Truly 0 at 0.283 s.
  - Fit: cosine T = 0.292 s, rms 0.012 (ease-in-out 0.31 s). So the code's 300 ms cosine is right.
  - The earlier 0.23 s missed the last 0.05 s, where alpha is below 0.07.

## Q-menubar (27.2.1)

Measured on the user's account (Dark, Multicolour accent = blue, NSGlassTintAmount 0.507, 2x built-in 1710x1107 pt with notch). Data: `reference/re/27.2.1/live/menubar/`, pictures: `reference/screens/27.2.1/menubar/`. Status items ARE in AX via the MenuBarAgent process (`axd <pid of MenuBarAgent>`), not via Control Center.

- Q-menubar-01: 34 pt on the notched Air (AXMenuBar 0,0,1710,34; MenuBarAgent bar window 0,0,1710,34; NSMenu.menuBarHeight 34; NSScreen.safeAreaInsets.top 33.5; legacy NSStatusBar.thickness 22). External non-notch display: not measured (none attached). (AX + probe metrics)
- Q-menubar-02: no scrim, blur, line or bottom edge; the bar shows the desktop picture 1:1 for dark/mid wallpapers (Electric Blue, grey ≤ 96: bar = desktop exactly) and never the windows. It does apply a luminance-adaptive contrast gradient over the top ≈100 pt that pushes the wallpaper away from the text colour: with white text, grey 112→110, 128→112, 144→116, 160→121, 163→122, and white (in a mixed wallpaper) 255→176; with black text, 166→195, 176→200, 200→212, 224→228, 240→241, 255→255 (uniform white stays 255), black (in a mixed wallpaper) 0→115. Strength vs y (same in both directions): 100 % at y ≤ 8, 96 % at 17, 87 % at 26, 79 % at 33, 75 % at 36, 59 % at 45, 30 % at 60, 5 % at 80, 0 by y 100 (smooth, no edge at y 34). Same in light and dark appearance. "Show menu bar background" (System Settings > Menu Bar) is OFF here, with no key written → default off. (solid test wallpapers, 2x pixels; Settings AX)
- Q-menubar-03: the text colour is chosen once for the whole bar from the wallpaper, not per region and not by appearance: uniform grey ≤ 163 → white, ≥ 166 → black (switch at sRGB ≈164.5/255 = 0.645 gamma-encoded, ≈0.37 linear); 50/50 black/white split (either side) → white everywhere; 75 % white + 25 % black (either side) → black everywhere (consistent with a mean of gamma-encoded luma vs ≈0.645). Title text is opaque: pure 0 (black) / 255 (white) at glyph cores; status glyphs and clock are slightly translucent: black ≈38 on 255 (a≈0.85), white ≈229–230 on 0 (a≈0.9). Identical in light and dark mode. (grey and split wallpapers, pixels)
- Q-menubar-04: not a solid fill: a blurred/brightened backdrop material (MenuBarAgent has `MenuBarBackdropHighlightLayer` and GlassBackground/GaussianBlur/VariableBlur strings; the layer cannot be dumped from another process). Pixels inside vs outside (light = dark identical): over white 226,226,228 at mid-left / 233 near the top vs 253 outside (pill is darker than white); over black 37,38,39 / 32 vs 0 (lighter); over Electric Blue 89,104,228 vs 69,83,206 (sRGB 85,105,237 vs 65,84,214). A faint shadow under the pill (white 244 at y 31). (pixels)
- Q-menubar-05: AX title frames (Finder, all y 0 h 34, neighbours overlap 1 pt): Apple 10..44 (34), Finder 43..105 (62), File 104..146 (42), Edit 145..190 (45), View 189..239 (50), Go 238..276 (38), Window 275..344 (69), Help 343..392 (49). AX width = text ink + ≈21–22 (≈11 pt each side; text-to-text gap ≈21). Pill (traced per pixel row, half-level edge): capsule, y 5.25..28.75 (≈23.5 tall, centred on y 17), x = AX frame outset ≈4 pt each side: File pill 100.3..150.2 (49.9 = AX 42 + 8), Apple pill 5.8..47.7 (42 = 34 + 8). Radius = full capsule (≈11.75; edge profile matches a capsule, soft 1 pt edge). So adjacent pills would overlap; only one shows. (AX + pill outline from 2x captures over Electric Blue, light and dark identical)
- Q-menubar-06: menuBarFont = .AppleSystemUIFont 13 (SF Pro). Normal titles 13 regular (ink widths File 20 / Window 48 / Help 26.5 vs rendered SF 13 regular 19.5 / 47.5 / 26.5); app name 13 bold (Finder ink 40.5 vs SF 13 bold 40.0, semibold 39.0, heavy 41.5) → wght 700. Default tracking (no extra). Cap height ink y 11..21. (pixels vs AppKit renders)
- Q-menubar-07: Apple glyph ink x 20.5..33.5 (13 pt wide), y 8.5..24 (15.5 tall), centred in its AX item 10..44 (centre 27). First title (app name) text ink starts at x 54 (AX 43 + 11). (pixels + AX)
- Q-menubar-08: this account, right→left (MenuBarAgent AX + Settings > Menu Bar): Clock, Control Centre, Wi-Fi, Battery (system AXMenuExtra items, 16 pt gaps), then NSStatusItems with no gap: Display/brightness (MonitorControl), Text Input (keyboard ⌘ glyph), Passwords key, Stats RAM, Stats CPU. Settings here: Siri off, Bluetooth off, AirDrop off, Focus off, Screen Mirroring off, Display/Sound/Now Playing/Timer "Show When Active", Text Input on, Fast User Switching off, Time Machine/Keyboard Brightness/VPN/Weather off; no Spotlight item shown. Clean-account defaults: not measurable here (account not clean). AX labels: "Battery" (value "100%, charging"), "Wi‑Fi, connected, 3 bars", "Control Centre", "Clock" (value = clock text); ids com.apple.menuextra.{battery,wifi,controlcenter,clock}. (AX + Settings AX)
- Q-menubar-09: status items are exposed via MenuBarAgent AX (AXMenuExtra, y 6 h 22): Battery 1450 w26, Wi-Fi 1492 w22, Control Centre 1530 w26, Clock 1572 w118 → 16 pt gaps between system items; clock right edge 1690 = 20 pt from the screen edge. Third-party NSStatusItems (AXGroup, contiguous, no gap, button y 5 h 24): 1240 w47, 1287 w47, 1334 w37, 1371 w36, 1407 w35, then 8 pt to Battery. Glyph ink: battery 25.5x14 at y 10..24 (x = item x exactly); Wi-Fi 16.5x12 at 1494.5,10 (2.5 pt side pads); CC 13.5x13.5 at 1536.5,10 (6 pt pads); clock text 1572.5..1687 (ink fills the frame; cap y 11..21.5). All glyphs centred on y 17. (AX of MenuBarAgent pid + pixels)
- Q-menubar-10: this account: com.apple.menuextra.clock ShowDayOfWeek 1, ShowDate 0 (= "when space allows", date shown here), ShowAMPM 1 but locale en-ID is 24 h → AX value "Wed 11 Nov  00.21" (two spaces before the time, "." time separator from the locale; no seconds). Font SF 13 regular with TABULAR digits: digit advance ≈8.1–8.5 pt ("1"s 8.5 apart; proportional "1" would be 6), whole ink 115 pt vs SF 13 monospaced-digit 117.8 advance / proportional 110.2. Clock is text only (no glyph). (AX value + pixels vs renders + defaults read)
- Q-menubar-11: hover: nothing (see #49). Pressed/open (Battery, Wi-Fi, Control Centre clicked, panel open): the same blurred pill material as the title pill (over Electric Blue: Wi-Fi pill 90,105,231 vs title pill 89,104,228, bar 69,83,206), but bigger padding: capsule y 5..29 (24 tall), x = AX item frame outset 10 pt each side (Battery 1440..1486 = 26+20, Wi-Fi 1482..1524 = 22+20, CC 1520..1566). Title pills are only 4 pt outset, y 5.25..28.75. Clock click opens Notification Centre with NO pill. While the Battery or CC panel is open the whole bar strip reads darker (bar 52,62,154 resp. 63,76,188 instead of 69,83,206; Wi-Fi panel: unchanged). No lift/scale seen; pill full in the first frame (#49). (pixels, display RGB)
- Q-menubar-12: solid accent fill, not glass: sRGB 0,122,255 (= controlAccent/systemBlue; multicolour→blue) identical over white and black backdrops in light and dark. Rect = row inset 5 pt left/right (x 5..W-5), full 24 pt row height, radius ~7 pt (continuous). On it label, shortcut glyphs and chevron are all white 255 (alpha 1). Disabled rows never highlight. (pointer hover on Finder File menu, 2x pixels, display→sRGB via ICC) Graphite (probe app with `-AppleAccentColor -1`: selection is solid neutral grey, light 152,152,152 (#989898), dark 140,140,140 (#8C8C8C), identical over white and black backdrops; text/shortcuts white 255, same rect; probe pointer hover).
- Q-menubar-13: yes, same window type. Menu-bar pull-down and context menu both = NSPopupMenuWindow (content) + separate `_NSGlassEffectWindow` 75 pt larger on every side holding NSGlassEffectView `_variant` 0, `_subvariant` "menu", cornerRadius 12; layers: window-level CABackdropLayer (sdrNormalize+gaussianBlur, shadow capture) and SDF CABackdropLayer `glassBackground` + CASDFLayer `vibrantColorMatrix` — identical trees (probe dumps `menu-pulldown-*.json`, `menu-context-*.json`). Empty-area pixel (Finder File menu over a solid probe backdrop): light over white 251,252,255 / over black 137,137,138; dark over white 120,120,121 / over black 33,34,44 (sRGB). (probe dump + pixels)
- Q-menubar-14: every pull-down (Apple, Finder, File … Help) opens at x = title AX x − 5 and y = 35 (bar bottom 34 + 1 pt gap). Apple title 10 → menu 5; Help title 343 → menu 338. First row at menu y+5 (5 pt top/bottom padding). Help menu: search-field row 40 pt flush at the top. (AX frames with the menus open). Edge clamp: status-item menu (probe NSStatusItem at x 1199/window 1200): normal x = window x − 5 (1195); an 884 pt wide menu is shifted left to x 820 so its right edge is 1704 = 6 pt from the screen edge. Vertical clamp for tall menus: bottom 1048 (see Q-26). (probe log)
- Q-menubar-15: Finder File menu (no state rows): text glyph origin x ≈ 16 from the menu's left edge (ink of "N" at 17.0, "G" 16.5). Menu with checkmarks (Finder View): check glyph at x 12.5..23 and plain text at ≈30 (ink 30.5..31), so the state column appears only when at least one item can show a state. Probe dump (LIVE) text field x 28 = glyph ≈30. (pixels, light/dark identical) Probe: AppKit text field x 14 in a menu without state column (glyph ≈16), x 28 with one (glyph ≈30). Column appears as soon as any item in the menu has a non-off state (or mixed); it is per menu, not per row. (probe `Plain` vs `States` dumps)
- Q-menubar-16: checkmark = `_NSMenuItemImageView` 13x11 at x 12, row y 6 (ink 9.5 x 10.5 pt at x 13.5–23, vertically centred); mixed = 12x4 image at x 13, y 10 (ink dash 8.5 pt wide at x 14.5–23). Colour = row text colour: label (black a.85 / white a.85), tertiary when disabled (light: 188 on 254), white on the selection (255). Indentation (menu with state column): level 1 → text x 31 (+3), level 2 → 43 (+15), i.e. ≈ 16 + 12·level + 3. (probe dump + pixels)
- Q-menubar-17: yes, some rows show leading SF Symbols, not all: Apple menu: About This Mac (laptop), System Settings (gear), App Store; File: Share, Manage Shared Folder, Move to Bin, Eject, Tags, Customise Folder, Print; Edit: Search, AutoFill, Start Dictation, Emoji & Symbols; View: as Icons/List/Columns/Gallery. Rows without an icon keep the plain text x (16) — text is NOT aligned across icon and non-icon rows. Icons ≈ 10–16 pt wide (glyph bbox), centred at x≈24 (no state column) or ≈36 (with state column); icon-row text at x ≈ 39.5–41 (no states) / ≈51 (with states). Tint = same colour as the row text (label / tertiary when disabled, white when selected). (pixels) Probe: custom `NSMenuItem.image` SF Symbols were NOT drawn at all in a 27 SDK probe app (no image view, text stays at 28); the Finder/Apple icons are the system's automatic images for standard actions (Share, Print, Copy, Search, Emoji…). (probe `Icons` dump)
- Q-menubar-18: yes, columns. Key char column = width of the widest key glyph in that menu, right edge at W−18.5 pt, each key char centred in it (I, N, P, ⌫ share one centre). Modifiers right-aligned to the key column's left edge −3 pt, order ⌃⌥⇧⌘ leftwards, ~3.5 pt between glyphs (⇧ 216–227, ⌘ 230.5–240, N 245–253 in a 273 pt menu). Glyph widths ⌘ 9.5, ⇧ 11, ⌥ 10.5, ⌃ 9, ⎋ 10.5, ⌫ 11. "fn F" (View > Enter Full Screen) = globe glyph in the modifier slot + F; Emoji & Symbols / Start Dictation show only 🌐 / mic in the key column. Font = system 13 (same as titles), tertiary colour. (pixels of File, Edit, Apple, View)
- Q-menubar-19: widths: Apple 274 (driven by "Log Out <full name>…"), Finder app menu 195, File 273, Edit 217, View 262, Go 238, Window 286, Help 360. (AX). No minimum width: a menu with the single item "A" is 41 x 34 pt (text field 14..35, ~6 pt right pad). Width = widest row content; probe "Plain" menu 196. (probe dump)
- Q-menubar-20: 1 pt (2 px) line, separator row 11 pt with the line at row y+5..+6; x inset 16 pt both sides (menu 273: line 16..256.5). Colour: light = black a0.10 (254→228 over white glass, 137→123 over black), dark = white a0.14 (121→140, 32→64). (pixels)
- Q-menubar-21: dark NSColor (sRGB): label 1,1,1 a.847; secondaryLabel 1,1,1 a.549; tertiaryLabel 1,1,1 a.247; separator 1,1,1 a.12; selectedMenuItemText 1,1,1 a1; disabledControlText 1,1,1 a.247. Light for comparison: label a.847, secondary a.498, tertiary a.259 (disabled .247), separator a.10, all black. (probe metrics-{light,dark}.json)
- Q-menubar-22: disabled text = tertiary: effective alpha 0.25 in light (0.254/0.255) and 0.25 in dark (0.252/0.243) — e.g. light over white glass 188, dark over black 87. Hover over a disabled row: no change (max pixel diff 1). Shortcut glyphs on enabled rows use the same tertiary alpha as disabled text. (pixels)
- Q-menubar-23: chevron = attachment glyph in a 17 pt key-font field at x W−32; ink 5.5 x 9.5 pt (x W−26..W−20.5, centred ≈W−23.25, y row+7.5..+17), same colour as the row text (label; tertiary on disabled rows; white when selected). Submenu = same `_NSGlassEffectWindow` menu glass (variant 0, subvariant menu, r12). Frame: x = parent right edge − 5 (overlaps 5 pt), y = hovered row top − 5 so its first row lines up with the parent row. Open delay: submenu appears ≈0.22 s (13 frames) after the row highlights, complete in one frame (no fade/slide). Close when the pointer jumps to another row: same frame as the highlight move (≤17 ms), no fade. Esc closes all with the normal 0.18–0.2 s fade. (probe Sort By submenu, 60 fps clip + probe dump/log)
- Q-menubar-24: yes: mouse-down on a title opens the menu at once (menu stays while the button is held), dragging onto a row highlights it, releasing runs the item (probe logged the action). Click-title-then-click-row behaves the same. Activation feedback (both ways, 60 fps): highlight goes off for 4 frames (≈67 ms), back on for 3 frames (≈50 ms) = one blink, then the whole menu incl. the highlight fades out in ≈0.2 s (12 frames, row blue 41,127,237 → 79 → 108 → 137 → 164 → 185 → 203 → 216 → 227 → 235 → 241 → 244 → gone). (probe Plain menu, clip blink.mp4 analysed per frame)
- Q-menubar-25: menu opened by click has no row selected. Down → first enabled row; Up (nothing selected) → last row; no wrap at either end (Up on first / Down on last stays). Right on a submenu row opens the submenu with its first row selected; Left closes it back to the parent row. Right/Left on other rows move to the next/previous title, whose menu opens with no row selected. Typing a letter jumps to the first row starting with it ("z" → Zoom In, "s" → Sort By). Return runs the selected row and closes the menu. Holding Option swaps alternates live (Close Window ⌘W → Close All Windows ⌥⌘W) and the menu re-sizes (196 → 207 pt). Esc closes. Keyboard highlight looks exactly like hover (solid accent, inset 5). (probe, synthetic keys, pixel check of the selection rect)
- Q-menubar-26: scroll arrows, no fade: a 90-item pull-down is clamped to y 35..1048 (1013 pt; bottom 59 pt above the screen edge = Dock/visibleFrame bottom 53 + 6). Window keeps the 5 pt paddings; inside, NSMenuScrollView is shortened by 24 pt and a 24 pt NSImageView row with a 13x8 chevron (down, centred, tertiary grey) sits at the bottom; the matching up-arrow row at the top is hidden until scrolled. NSScrollPocket exists in the tree but stays hidden/alpha 0 (no edge fade). (probe Long menu dump + pixels)
- Q-menubar-27: Finder desktop / icon right-click (window list, glass window inset 75): menu x = click x + 1 (desktop) and top = click y − 34, because 27.2.1 Finder context menus start with an "Ask Siri" header row (≈32 pt, its own light translucent rounded platter, Siri glyph + text, NOT the accent selection) and the first normal row lands at the pointer. Generic AppKit `popUp(positioning:nil at:)` in the probe: x = point, top = point − 5 (first row top at the point). Edge handling: right edge → flips to the left of the pointer (menu right edge = click x: clicks at x 1700 / icon at 1642 gave right edges 1700 / 1642); bottom → not flipped, shifted up so the bottom stays at y 1048 (visible-frame bottom − 6; clicks at y 900 and 1040 both gave 791..1048). Material, radius 12, paddings, row metrics, selection = identical to pull-downs; differences are only position and the Siri header. (window list + pixels; Finder's context menu is not exposed in its AX tree)
- Q-menubar-28: over white (Finder File menu, 2 pt steps from the edge): below: light 219,221,224,226,228,231,233,236,238,240,242,244,246,248,249,250,251,252,253,253,254… → 14 % darkening at 2 pt, 11 % at 10, 6 % at 20, 2 % at 30, gone by ~45–50 pt; dark mode slightly stronger (214 at 2 pt = 16 %, 225 at 10, 238 at 20, 248 at 30, 253 at 40). Beside (right): light 231 at 2 pt (9 %), 240 at 10, 249 at 20, 253 at 30, 255 by ~40; dark 228/238/248/253. 15 pt left of the menu still 243–245. Over black the shadow is invisible (0 everywhere). Outer hairline: 1 px (0.5 pt) dark line just outside the left/right edges: light 158 on 229 (≈ black a.3), dark 49 on 226 (≈ black a.78); invisible on black. Inner rim: the bottom 1 pt inside is brighter (light 255 vs 253; dark 144/161 vs 124 over white, 62/84 vs 37 over black); the top rim refracts the bar colour. Matches LIVE recipe (shadow 0.7/0.8, r24, y10). (pixels)
- Q-menubar-29: percentage off on this account (no BatteryShowPercentage key in com.apple.controlcenter; AX value "100%, charging" but no text drawn). Icon = BatteryUIKit bitmap 26x14 (ink 25.5x14 at item x, y 10..24); geometry/fills per R3b-2: body (0,1,23,12) r4, fill width max(2, round(level·23)) → 100 % 23, 50 % 12, 19 % 4; fill label a.847, track .498/.549, cap a.6 at x 24. Charging (current state): full white body with the bolt knocked out. Low (red) / Low Power (yellow) / plugged: only as the 34 system bitmaps from R3b-2 (battery level could not be forced live). (AX + pixels + R3b-2)
- Q-menubar-30: Wi-Fi = `wifi` 3 bars, ink 16.5x12 = SF 15 pt regular (render 16.5x12.0); Control Centre = `switch.2`, ink 13.5x13.5 = SF 14 pt medium (render 13.5x13.5; regular 13.0). Both drawn white (max 241 ≈ a.94 over the blue). Wi-Fi off / no internet / 1–2 bars: not measured (would need turning the user's Wi-Fi off); names per R3b-2 (wifi.slash, wifi.exclamationmark, variable value). Spotlight/Siri/Focus not shown on this account. (pixels vs SF Symbol renders at 2x)
- Q-menubar-31: Apple menu (274 x 305): About This Mac [icon] (⌥: System Information) | — | System Settings… [icon] | App Store [icon] | — | Recent Items ▸ | — | Force Quit… ⌥⌘⎋ (⇧ alt: Force Quit <front app> ⌥⇧⌘⎋) | — | Sleep | Restart… (⌥: Restart) | Shut Down… (⌥: Shut Down) | — | Lock Screen ⌃⌘Q | Log Out <full name>… ⇧⌘Q (⌥: Log Out <name> ⌥⇧⌘Q). All enabled; no trailing separator shown. Finder app menu (195 x 222): About Finder | — | Settings… ⌘, | — | Empty Bin… ⇧⌘⌫ (⌥: Empty Bin ⌥⇧⌘⌫) | — | Services ▸ | — | Hide Finder ⌘H | Hide Others ⌥⌘H | Show All. Hide Finder/Hide Others disabled when no Finder window is open; Show All enabled. No icons in the Finder app menu. (AX with menu open; row y = 24 pt, separator 11 pt; Option alternates share the frame of their primary)
- Q-menubar-32: (toggled in Settings > Accessibility > Display, restored to off; sRGB; wallpaper Electric Blue, menu over probe white/black backdrop)
  - Reduce Transparency: the BAR becomes opaque and ignores the wallpaper: dark 32,32,32 with white titles, light 218,218,218 with black titles. Pill: same capsule, solid grey 57 (dark) / 190 (light). Menu: opaque dark 20 (over white and black), light 255 over white / 250 over black. Text alphas unchanged (dark label 219 on 20, disabled 78; light 39 / 189); separator dark 53 on 20, light 229 on 255; outer hairline dark 5, light 159. Selection unchanged 0,122,255.
  - Increase Contrast (Reduce Transparency stays off): bar still shows the wallpaper, text colour rule unchanged; pill = solid grey 117,117,117 in both appearances. Menu stays glass but denser: dark 72 over white / 33 over black (base 120 / 33), light 253 / 191 (base 252 / 137). Label opaque (dark 255, light 0); disabled/shortcuts stronger: dark 163 (white bg) / 145 (black bg), light 112 / 85; separator dark 129 on 75 (≈white a.3), light 89 on 255 (≈black a.65). Selection darker accent: light 0,64,221, dark 24,116,218. Hairline dark 11, light 159. (pixels)
- Q-menubar-33: yes (this account: "Automatically hide and show the menu bar" = In Full Screen Only, AppleMenuBarVisibleInFullscreen 0). On the notched Air a full-screen window sits BELOW the bar strip (window 0,34,1710,1073); the top 34 pt stays solid black and the titles/status items are hidden. Pointer to the top edge: titles and status items FADE in place (no slide, ink y 11..23.5 constant) over ≈0.15 s (9–10 frames, roughly linear: title-region mean 3,9,13,19,25,32,…,46,56 = final), on the black strip (no material); the window's titlebar (0,34,…,32 tall) appears in one frame ≈0.12 s after the fade starts. Leaving: titles fade out in ≈0.17 s (10 frames), titlebar goes in ≈0.1 s. No dwell delay detectable (reveal and hide both started within a frame of the pointer crossing). Non-notch displays (bar overlapping content) not measured. (probe window toggleFullScreen, 60 fps clip)
- Q-menubar-34: no. Over a 2 pt black/white stripe wallpaper the stripes stay sharp and identical (0/176, std 88–95) in the empty bar, between Battery/Wi-Fi/CC/Clock, right of the clock and between titles at y 3, 17 and 31 → no capsule, blur or glass behind the right-side items or the bar. Only pills on open items (Q-04, Q-11). Measured at this account's Liquid Glass setting (NSGlassTintAmount 0.507); other Clear/Tinted values not tried (global user setting). (stripe wallpaper, pixels)

## Glass checks (#53)

Setup: user account (Multicolour, icon style Dark, NSGlassTintAmount 0.5071146, tile 33). The backdrops were solid
3420x2214 PNG wallpapers (255 / 127 / 0) set with System Events. Desktop icons sit under the CC panel, so a borderless
window of the same grey was placed just above the desktop-icon level to hide them (the screen reads exactly 255/127/0
there). All values are display RGB from `screencapture`, read at 2x px. Crops are in
`reference/screens/27.2.1/glass53/` (720 KB). Remaining disk: **40 GiB free** (Data volume 163 of 228 GiB used).

### 1. Control Center over a plain backdrop

**Light and dark appearance give identical pixels** (every tile, label and the gap). The only change is the Dark Mode
toggle tile, which is on in dark. The Liquid Glass slider does not change CC either: at tint 1 it is still 186 / 229 / 255.

| Backdrop | Gap between tiles | Off tile interior | Off icon circle (Focus) | Toggle title ("Bluetooth", "Focus") | Subtitle ("On") | Slider title ("Display"), glyphs | Slider track / fill |
|---|---|---|---|---|---|---|---|
| white 255 | 229 | **186** | 203 | 245 | 255 | 255 | 206 / 255 |
| grey 127 | 114 | **109** | 146 | 233 | 249 | 255 | 129 / 255 |
| black 0 | 0 | **32** | 88 | 221 | 172 | 255 | 52 / 255 |

- Off tile = **32 + 0.604·in**, linear in display values (all 3 points within ±1).
- On state = solid 255 (white):
  - Wi-Fi / Bluetooth / AirDrop icon circles are 255 with an accent glyph (52,120,246).
  - The Dark Mode tile when on is a 255 disc with a black (0) glyph.
  - The HomeKit accessory tile when on is 255 with dark text.
- Gap between tiles = **0.898·in** (a 10 % black dim). There is no hard panel edge. The dim feathers out over about
  100 pt to the left of the tiles and below "Edit Controls" (236 over white at 12 pt left of the tiles).
- How the labels and parts relate to the tile colour T:
  - Off icon circle = T + 0.25·(255−T): white at 25 %.
  - Toggle title = T + 0.85·(255−T): white at 85 %.
  - Subtitle = T + 140 (plus-lighter, clamps at 255).
  - Slider track = T + 20.
  - Slider-module titles and all glyphs are pure 255.
- **Labels stay white over white:** yes. 255 (or 245) on a 186 tile, about 1.9:1 (1.8:1 for 245). Nothing darkens them
  for a light backdrop.
- **The tile over white is 186, not 203.** 203 is the off icon circle (white at 25 % over the tile).
- Crops: `cc-{light,dark}-white.png`, `cc-{light,dark}-grey127.png`, `cc-dark-black.png`. The Wi-Fi SSID and accessory
  rows are cropped out.

### 2. Dock in dark appearance

Readings at a spot between icons (the item boundary), 2x px rows going inward from the edge.

| Backdrop | Body | Top edge, px 1,2,3,5,9 → body | Bottom edge (mirror) |
|---|---|---|---|
| white 255 | **176** | 193, 186, 179, 178, 177 → 176 (about 6 pt) | identical |
| grey 127 | **107** | 155, 135, 117, 112, 109 → 107 | identical |
| black 0 | **12** | 104, 65, 30, 22, 16 → 12 (about 7 pt) | identical |
| light mode, white | 229 | 237, 235, 233, 232, 230 | identical |
| light mode, black | 38 | 116, 83, 54, 47, 41 | identical |

- **Rim, top vs bottom:** they are the same, pixel for pixel, in every case. The old "104 top / 65 bottom" (and
  116/83 in light) were the outer and the second pixel of the same 1 pt rim, not top and bottom.
- The rim depends on angle:
  - full at the top and bottom edges;
  - about 46–50 at the 45° corners (over black);
  - none at the vertical sides.
- At mid-height on the sides, the outermost 1 px is instead darker than both the backdrop and the body: 104 over white,
  49 over grey, which is about 0.4·backdrop.
- **The ~230 the probe predicts over white is the light-mode Dock (229).** The dark Dock over white is 176, which
  confirms 176/108/12 (grey now 107).
- What changes the dark Dock body, all over white:

| Change | Body / rim |
|---|---|
| Icon style Dark (user) | 176 / 193 |
| Icon style Default (key removed) | 176 / 193 |
| Icon style Clear (ClearLight) | 176 / 193 |
| Icon style Tinted (TintedLight) | 176 / 193 |
| Liquid Glass slider 0 | 176 / 193 |
| Liquid Glass slider 0.5 | 176 / 193 |
| Liquid Glass slider 1 | 176 / 192–194 |

  **None of them changes the Dock body.** The whole Dock capture differs by at most 2 levels between slider 0 and 1.
  Only the icon art changes with the style.
- The slider is live elsewhere: the Settings preview buttons darken a lot, but the desktop context menu over white only
  moves 55 → 53 and CC does not change.
- Crops: `dock-dark-{white,grey127,black}.png`, `dock-light-{white,black}.png`,
  `dock-dark-black-leftedge-x4.png` (rim around the corner), `dock-dark-white-iconstyles-dark-default-clear-tinted.png`.

Restored and verified:
- Dark mode, Electric Blue wallpaper.
- AppleIconAppearanceTheme RegularDark ("Always"), NSGlassTintAmount 0.5071146 (float), set through the slider's AX
  value.
- System Settings hidden again, CC closed, the patch window quit.
- The two Finder windows were minimised during the test and are back at their original bounds.

## Q-settings (27.2.1)

Measured on the live System Settings (macOS 27.2.1, 2x, 740x625 pt window at 484,232) plus the control gallery probe
`reference/re/tools/probe/controls.swift`, which was extended in place. It adds every size and state, focus rings
(full keyboard access is forced on inside the probe process only), an inactive capture, and a 120 Hz layer sampler for
presses. Pictures are in `screens/27.2.1/settings/` and `screens/27.2.1/controls/`. Data (AX dumps, control JSON,
press series) is in `re/27.2.1/live/settings/` and `re/27.2.1/live/controls/`. Colours are sRGB from 2x captures. Window
x/y is measured from the window's top-left. Wallpapers were TahoeLight / TahoeDark. "Tint window background with
wallpaper colour" is on (the default), so the dark window background is bluish.

- Q-settings-01: The sidebar is Liquid Glass: `NSGlassEffectView` `_variant` 18. This is not an NSVisualEffectView
  (Q9; the probe was rebuilt the same way, because another process's layers cannot be dumped).
  - It is flush with the window's left, top and bottom edges and sits under the titlebar. It has no inset and no radius
    of its own.
  - Width is 232 pt at Medium icon size (228 at Small, 246 at Large).
  - A 0.5 pt divider runs on the right: #D3D4D5 light, #3F424D dark.
  - Sampled fill over Tahoe: light #ECEDEE, dark #232634, uniform from x 6 to 200.
  - Inactive: light #F2F2F2, dark #24262B (flat).
  - (pixels + AX + Q9)
- Q-settings-02: The back/forward control is Liquid Glass: a regular-glass toolbar platter (Q9: `_variant` 0, 36 pt
  tall, radius 18). Not a flat fill.
  - AX group 73x36 at window (240,8): Back 36x36, Forward 37x36.
  - A 1 pt divider sits at the middle, about 20 pt tall: dark #717177.
  - Chevrons: glyph 8x14.5 pt. Likely the 13 pt .large .medium symbol config (same as Finder, R3b-3).
  - Colours (dark): active white on a capsule face of #3D3D42 over the #1F1F24 bar. Disabled Forward is #707076
    (about tertiary).
  - Hover: a 36 pt circular highlight appears behind the hovered half and the divider hides. Pressed: the same circle,
    brighter.
  - Light colours: see Q9 / `settings-toolbar-light.png`.
  - (AX + `toolbar-backforward-rest-hover-press-dark.png`)
- Q-settings-03: Window.
  - Size is 740x625 pt on this account (default not reset).
  - Width is fixed at 740 (it follows the sidebar: 736 Small, 754 Large). Only the height resizes: min 470, max = the
    visible screen height (821 here). Tested with System Events, then restored.
  - Toolbar is 52 pt (AXToolbar). Traffic lights at (18,18) pitch 23.
  - Corners: fit to the alpha of the -o capture gives superellipse R 35.75 pt, n 5 (rms 0.15 pt), circle-equivalent
    about 17 pt. That is the same family as Finder (continuous about 16 pt).
  - Shadow and rims as in Q-windows.
  - Content scrolls under the toolbar: yes (Q-04).
- Q-settings-04: Scroll edge (Keyboard pane, 60 fps clip).
  - It is a fade and blur, not glass. Content under the 52 pt toolbar strip is washed almost to the window background:
    light card #F7F7F7 reads #FEFEFE in the strip, and text is barely visible.
  - A 0.5 pt hairline sits at y 52: light #DEDEDE on #F7F7F7 (black about a.10), dark #34353A on #25262B (white about
    a.05).
  - The hairline appears in the first frame the content offset is above 0, with no fade-in. It also shows
    permanently while the window is inactive (#E5E5E5 / #2D2E30).
  - Blur radius: not separable from pixels; the layer recipe is NSScrollPocket with variableBlur + colorMatrix (Q9).
  - (`scroll-edge-keyboard-{light,dark}.png`)
- Q-settings-05: Selected sidebar row.
  - Flat accent pill (not glass): #2F6EED light, #3478F6 dark.
  - Geometry: x 10..222 (inset 10 on both sides), 32 tall = the row height, radius about 8.5 pt.
  - Text is white and bolder: "Appearance" is 63 px wide selected vs 57 px unselected, so Semibold/Bold. The icon is
    unchanged.
  - Hover fill: none (`sidebar-hover-none-dark.png`).
  - When the sidebar is not first responder (search field focused), or the window is inactive: grey pill #E7E7E7 /
    #323439 with label-coloured text.
- Q-settings-06: Inactive and disabled.
  - Inactive window (`desktop-dock-inactive-*.png`):
    - Lights grey, title #BDBDBD / #5C5D5E.
    - Sidebar labels dim to #8C8C8C / #717378. The tiles keep their colour.
    - Selection #E7E7E7 / #323439.
    - Switch-on track #D3D3D3 / #414244 with white knob. Slider fill grey.
    - Checkbox-on #C1C1C1 / #535456 with dark tick.
    - Accent is gone everywhere. Content labels are unchanged.
  - Probe inactive: switch-on #DADADA / #3F4045, slider fill #C5C5C5 / #535357, segmented pill #CFCFCF / #4A4B50,
    default button becomes a plain grey button.
  - Disabled (probe, AppKit/SwiftUI layers): the control's background layers get opacity 0.5. The tick becomes black
    a.26 / white a.25, and the slider loses its accent fill (grey). Pixels:
    - Push light #F5F5F5 vs #ECECEC; dark #28292F vs #303137.
    - Switch-on light #6D9BF1 vs #3374EF; dark #3462B8 vs #397AF6.
    - Checkbox-on disabled light #ECECEC; dark #303137.
    - Slider disabled #DBDBDB / #404146.
    - Popup same as push.
    - Disabled label = disabledControlTextColor.
- Q-settings-07: Sidebar metrics (AX, window coordinates, Medium).
  - Search field 212x28 at (10,61). The list starts at y 98.
  - Account row 46 tall (button 141.5x38 at x 16): avatar about 38, name 13 pt bold-ish, "Apple Account" 11 pt
    secondary. Family row 32. Pictures of this block are withheld (privacy).
  - Group break = 13 pt of empty space (0-height spacer rows).
  - Rows 32, cell x 10..222. Tile 20x20 at x 19. Label at x 46 (gap 7). Label 13 pt.
  - Small: rows 24, Family 29, tile about 13–14, label x 42.5, 11 pt.
  - Large: rows 40, Family 40, tile 26, label x 48.5, 15 pt.
  - `NSTableViewDefaultSizeMode` 1/2/3. Changed in the pane, then restored to 2.
  - (`ax-sidebar-iconsize-*.jsonl`, `sidebar-iconsize-*-light.png`)
- Q-settings-08: Live 27.2.1 order, confirming the plist answer. Group breaks shown as |.
  - Apple Account, Family | Wi-Fi, Bluetooth, Network, VPN, Battery
  - | General, Accessibility, Appearance, Desktop & Dock, Displays, Menu Bar, Siri, Spotlight, Wallpaper
  - | Notifications, Sound, Focus, Screen Time | Lock Screen, Privacy & Security, Touch ID & Password, Users & Groups
  - | Game Center, iCloud, Internet Accounts, Wallet & Apple Pay | Keyboard, Trackpad, Printers & Scanners
  - | third-party (GPG Suite here).
  - Groups are sorted by localised name. Mouse, Game Controllers and CDs & DVDs appear only when that hardware is
    present. Battery would be Energy on a desktop. No Passwords pane.
  - (AX)
- Q-settings-09: Tile.
  - The tile is part of the IconServices icon art (R3b). There is no separate enclosure.
  - Drawn at 20x20 pt in a 32 pt row (40 px at 2x). Light-style tile fill, e.g. Wi-Fi #3C88F5 with a white glyph.
  - Dark style: a black tile (#171717) with the glyph in the tile colour.
  - Shape, radius, gloss and glyph per style: see the R3b PNGs (byte-identical renders).
- Q-settings-10: Search field.
  - Not glass in the sidebar (a flat translucent capsule). 212x28, full capsule (r 14).
  - Magnifier button 25x28 at the left. Placeholder "Search" 13 pt secondary.
  - Focus: a 3 pt accent focus ring around the capsule, plus a "Suggestions" popover under it.
  - Clear (cancel) button 28x28 at the right, shown only with text.
  - It does search inside panes: the sidebar is replaced by a result list, one row per setting ("Dock position on
    screen" / "Desktop & Dock"). Rows are 36.8 pt (1-line title), 52.8 (2-line) or 68.8 (3-line), each with the pane
    icon.
  - (`search-*.png`, `ax-search-dock.jsonl`)
- Q-settings-11: Content and card.
  - Window background is solid: light #FFFFFF; dark #1E1F24 (wallpaper-tinted; #202127 in the probe).
  - Cards (SwiftUI Form sections) are a solid fill, no stroke, no shadow, no glass: light #F7F7F7, dark #25262B.
  - Card radius about 13 pt (corner profile; a continuous curve).
  - Cards are 468 wide at x 252 (20 pt margins in the 508 pt content area).
- Q-settings-12: Rows.
  - Heights: 1-line row with a switch about 37.5. 1-line row with a popup 38. Row with a 2-line 11 pt sublabel 66–67.
    Icon + chevron navigation row (Accessibility) 42 + 1 separator.
  - Padding 10 pt left/right inside the card.
  - Separator: inset 10 on both sides, 0.5 pt. Light #EBEBEB on #F7F7F7 (black about a.05); dark #2F3035 on #25262B (white about a.04).
  - Gaps: card to card 10. Heading to card 10 (heading 16 tall). Card to the next section heading 30. First heading
    12 below the toolbar.
- Q-settings-13: Text styles. Pixel cap heights; colours composited.
  - Toolbar title: about 15 pt Bold, #E8E8E9 / #4C4C4C active.
  - Section heading: 13 Bold, label a.85.
  - Row label: 13 Regular, labelColor a.85 (#DEDEDF on the dark card, #262626 light).
  - Sublabel: 11 Regular, secondary (white a.55 → #9D9D9F dark).
  - Slider end labels ("Small/Large"): 11.
  - Sidebar: 13 Regular. Selected row: white Semibold/Bold.
  - Buttons and popups: 13 Regular (probe: `.AppleSystemUIFont 13`).
  - Tracking and opsz as R4. Emoji size: not measured.
- Q-settings-14: Hero.
  - Accessibility has a hero card as the first card (468x65.5): icon 26x26 at window (263,76) (12 pt inside the card), title 13 pt at x 300,
    description 11 pt secondary in 2 lines (28 tall) with an inline "Learn more…" link.
  - Displays uses a hero area, not a card: a 158 pt strip (bg #29292E vs #1E1F24) with a 304x157 MacBook picture and
    "Built-in Display" bold, then a 0.5 pt divider (#343539).
  - Appearance, Desktop & Dock, Sound and Keyboard have no hero.
  - Other panes: not surveyed (several show personal data).
- Q-settings-15: Push button. Flat, not glass (glass only with `.bezelStyle = .glass`, which draws a glassBackground
  SDF).
  - Sizes: regular 24 tall r6, pad 12, label 13 pt. Small 20 r5, pad 10. Mini 16 r4, pad 8. Large 28 r14 (capsule),
    pad 14. Alert buttons are the large size.
  - Fill: two layers, black a.047 + a.03 (light #ECECEC) / white a.047 + a.03 (dark #303137).
  - Default: accent #007AFF plus an accent a.75 layer, white text.
  - Pressed: an extra black a.098 layer, instant (no animation).
  - Disabled: opacity 0.5 on the fill.
  - Min width: none beyond the padding ("OK" is 42.5).
  - Help "?" button: 24x24 circle with the same fill; glyph 7.5x12.5.
  - (`controls-*.json`)
- Q-settings-16: Switch.
  - Regular: track 54x24 r12, knob 32x20 r10 (a capsule knob, 2 pt inset).
  - Small: 44x20, knob 26x16.
  - Mini: 36x16, knob 21x13 r6.5. Settings itself uses mini switches (AX 36x16).
  - Off track: black a.098 (#E4E4E4) / white a.098 (#36373C).
  - On track: accent + black a.098 + accent a.75 (#3374EF / #397AF6; Settings #3374EE / #397AF5).
  - Knob: white, two shadows: black a.10 r12 y3 and black a.10 r2 y1.
  - The knob is not glass at rest. While pressed it turns into a clear glass lens (next item).
- Q-settings-17: Press (120 Hz layer samples + 60 fps video).
  - Switch press: the knob grows from 32x20 to 50x31 (x1.56, centred). It reaches the peak 0.23 s after mouse-down
    with a smooth S-curve and no overshoot. It cross-fades from white to glass in proportion to the growth (opacity
    0.5/0.5 at 41 pt).
  - The glass lens: no blur, inner refraction height 0.1D, amount -0.15D, plus a displacementMap.
  - A quick click releases before the peak: peak x1.27 at 0.16 s.
  - Release: shrinks back in about 0.3 s while travelling.
  - Travel 2→20 pt: 95 % at 0.2 s, overshoot 0.7 pt (4 %), settled by 0.45 s.
  - Track colour cross-fades over about 0.25 s; on→off overshoots slightly (clamped).
  - Slider knob press: 20x16 → 25x20 (x1.25), fully glass in 0.17 s, back in 0.15 s.
  - Slider click on the track: the knob animates to the click point, ease-out, no overshoot: 50 % at 0.06 s, 90 % at
    0.16 s, done at about 0.4 s.
  - (`controls-press-light.json`, `switch-press/release-strip-light.png`)
- Q-settings-18: Slider.
  - Regular: track 6 pt r3, black/white a.098. Fill: accent layers as the switch.
  - Knob 20x16 r8, white, with the switch's two shadows. Row 16 tall.
  - Small: track 4, row 14. Mini: track 4, row 12.
  - Ticks: 2x2 dots r1 at y 14 (below the track), black a.26 / white a.25.
  - Settings end icons: about 16x13 and 17x13.5 at a 6 pt gap (Liquid Glass row). Brightness 16.5 / 18 pt sun
    buttons, 5 pt gap.
  - Desktop & Dock uses text end labels (11 pt) under the track. The row with labels is 69 tall.
- Q-settings-19: Pop-up button. Every pop-up has the same look.
  - Push-button fill, r6, 24 tall (small 20, mini 16). Label 13 at x 12.
  - Chevron: `chevron.up.chevron.down` image 7.5x10.5 at right (pad 10). Pull-down uses `chevron.down` 7.5x4.5.
  - Settings shows the double chevron inside a 24 pt circle.
  - Pressed and disabled: as the push button.
- Q-settings-20: Pop-up menu.
  - Glass menu in its own window (LIVE: regular glass, r12).
  - Rows 24, menu padding 5. Width = the button width (96 / 95).
  - The checked item is placed exactly over the button (y equal to the button's y).
  - Highlight (under the pointer): accent pill #3478F6 (dark sample; light looks the same), inset 5 pt, about 23–24 tall, radius about 6, white text.
  - Checkmark column at the left (about 12 pt).
  - Open is instant; close is a fade of about 0.2 s (LIVE).
  - (`popup-menu-open-*.png`)
- Q-settings-21: Checkbox and radio. Flat, not glass.
  - Checkbox: regular 16 r5.5, small 14 r4.5, mini 12 r3.5, large 18 r6.5.
  - Off: black/white a.098.
  - On: accent stack (as the switch) with a white tick shape (10x9.5 in 16; small 9x8.5; mini 7.5x7.5).
  - Mixed: white bar 6.5x2 r1.
  - Disabled: opacity 0.5, tick black a.26.
  - Pressed: an extra a.098 layer.
  - Label gap 6 (text at x 22).
  - Radio: 16 circle (14 / 12), the same fills. Dot 5 r2.5 (small 5, mini 4).
- Q-settings-22: Segmented. Not glass.
  - Track: push fill, regular 24 r6, small 20 r5, mini 16 r4, large 28 r14.
  - Selected pill: full-height accent segment, white text.
  - Separators: 1x14 black a.098 between unselected segments.
  - Pressed: a black a.098 overlay.
  - The pill does not slide: the selection jumps in one frame, both in the AppKit probe and in Settings' SwiftUI
    Output/Input picker (448x24, 60 fps).
- Q-settings-23: Text field and stepper.
  - NSTextField (rounded and square bezel are the same in 27): 24 tall (small 22), r6.
  - Fill: white a.85 / #161616 a.85 (#171819). Border 1 pt outside: black a.078 / white a.047, r7.
  - Text 13 pt, inset 4. Focus: 3 pt accent ring outside.
  - Search field: r12 capsule, same fills.
  - NSStepper: 20x24 regular, 17x20 small, 13x16 mini. Drawn by the cell (no layers): up/down chevrons, no glass.
    Pressed not measured.
- Q-settings-24: Focus ring.
  - 3 pt wide, directly outside the control (gap 0), following its shape (radius + 3).
  - Colour: light #95B3F6 on white, dark #38658F on #202127. This is keyboardFocusIndicatorColor a.5
    (#0067F4 / #1AA9FF).
  - Segmented: around the focused segment only. Slider: around the knob. Switch, checkbox and radio: around the
    control body only, not the label.
  - It appears without animation.
  - (`focus-rings-*.png`, `focus-*.json`)
- Q-settings-25: Accent row.
  - 9 AX buttons 32x32, pitch 36, x 394..718 (window), row 32.
  - Visible swatch: 24 pt disc. Selected: 3 pt accent ring with a 1 pt gap (outer 32).
  - Name label "Multicolour": 11 pt secondary, centred under the selected swatch, directly below it (gap about 0).
  - The card is 100 tall: colour row plus a 37 pt highlight row.
  - Hover/press animation: not measured.
- Q-settings-26: Mode and Liquid Glass.
  - Light/Dark/Auto: AX 74x66 each, pitch 82. Thumbnail 67x44, radius about 6 (visual estimate). Selected ring 3 pt with a 0.5 pt gap.
    Caption 11 pt, bold when selected.
  - The Liquid Glass preview is a scroll view 268x180 (an Apple Park article under glass toolbar capsules), r about 14 (visual estimate).
  - Slider 221.5 wide with 5 ticks (2 marked dots), between end buttons 16x13 (clear-glass capsule) and 17x13.5
    (tinted).
  - Preview at 0/50/100: not recorded (it would change the user's value).
- Q-settings-27: Highlight and icon style.
  - Text highlight colour is a pop-up (133x24) with a 16 pt colour dot (multicolour for Automatic).
  - Icon & widget style tiles: AX 38x52 incl. the caption. The tile is 29 pt. Selected ring 3 pt, gap 1.5. Caption
    11 pt, bold when selected.
  - Dark shows an Always/Auto radio row. Clear and Tinted show Light/Dark/Auto.
  - With Tinted, "Folder colour" becomes "Icon, widget & folder colour".
  - Written values: Default = key removed; Dark+Always = RegularDark; ClearLight, ClearDark, TintedLight, TintedDark.
  - Sidebar effect: see #35.
- Q-settings-28: Displays (built-in only; no external display was attached).
  - Hero strip 158 tall (above).
  - 5 resolution tiles as 50x50 AX buttons, pitch about 91. Drawn 45x45 window thumbnails with lights and text; the
    selected one has a 2 pt accent ring (49).
  - Labels "Larger Text"/"More Space" under the ends, a "Default" bold caption under the selected, and a thin line
    joining the middle tiles. Card 108 tall.
  - Then the Brightness card (slider with sun buttons, auto-brightness, True Tone), Colour profile, TV, and
    Advanced/Night Shift/? buttons.
- Q-settings-29: Desktop & Dock (27.2.1 order).
  - Dock: Size and Magnification sliders side by side (200 / 220 wide, text end labels "Small/Large",
    "Off Small … Large", tick dots), card 69.
  - Card: Position / Minimise animation / Double-click action pop-ups, then Minimise into app icon.
  - Card: Auto-hide, Animate, Indicators, Suggested apps.
  - Desktop & Stage Manager (Show items checkboxes, Click wallpaper pop-up + sublabel, Stage Manager + sublabel,
    Recent apps, Show windows pop-up).
  - Widgets.
  - Default web browser.
  - Windows (2 cards). Mission Control (description, 202 card). Shortcuts…, Hot Corners…, ?.
  - Magnification here is off (value 0).
- Q-settings-30: Accessibility.
  - Hero card, then sections:
    - Vision: VoiceOver, Zoom, Hover Text, Display, Motion, Read & Speak, Audio Descriptions.
    - Physical and Motor: Voice Control, Keyboard, Pointer Control, Switch Control.
    - Hearing: Hearing Devices, Audio, RTT, Subtitles and Captioning, Live Captions, Name Recognition.
    - Speech: Live Speech, Personal Voice, Vocal Shortcuts.
    - …
  - Rows 42 tall + separator. Tile 20 pt at x 21 (per-row colours: black VoiceOver/Zoom/Read & Speak, blue, green
    Motion).
  - Chevron 5.5x9 pt at right (x 704), tertiary colour.
  - Sub-page title/back: not opened.
- Q-settings-31: Wallpaper.
  - Preview 160x100 at (248,68), radius about 8 (visual estimate).
  - Card 306x75 with a name + "Fill Screen" pop-up and a "Show on all Spaces" switch. Below it, "Screen Saver…" and
    "Clock Appearance…" buttons.
  - Divider, then category rows (title 13 bold + "Show All (n)" link right) with a horizontal scroller:
    - Tiles 108.5x72 thumbnails plus an 11 pt caption (100 tall), pitch 117.5 (gap 9).
    - Dynamic tiles carry an appearance badge and a download badge.
  - Selected: 2 pt grey ring (#464646 dark) with a 0.5 pt dark gap.
  - "Your Photos" starts with an "Add Photo…" tile.

### Icon styles (#35)

Sidebar crops (below the account block), 2x: `screens/27.2.1/settings/sidebar-iconstyle-<appearance>-<style>.png`
(12 files) plus `sidebar-iconstyles-sheet.png`.
- Shot pairs: light/dark × default and dark, plus clearlight, cleardark, tintedlight and tinteddark in both
  appearances.
- Pixel check of the Wi-Fi tile body:
  - Default: #3C88F5 in Light AND in Dark appearance (identical), with a white glyph. **Confirmed: Default in Dark
    appearance shows the coloured light-style tiles.**
  - Dark (RegularDark): #171717 tile in both appearances, with a blue glyph.
  - Clear Light: #7D7D7D grey translucent. Clear Dark: #2B2B2B.
  - Tinted Light: #3478F1 tile with a white glyph. Tinted Dark: #1B222A tile with a blue glyph.
  - Clear and Tinted look the same in both window appearances: the tile follows the style's own Light/Dark radio, not
    the window mode (Auto follows the mode).
- User values restored and verified with `defaults read -g`: Dark, RegularDark, accent absent (Multicolour),
  NSGlassTintAmount 0.5071146, NSTableViewDefaultSizeMode 2.

## Q-finder (27.2.1)

Measured live on Finder, macOS 27.2.1 (26B131), 2x. Window 920 x 560 pt on a test folder (on a mounted test disk image, not Documents: the user's Documents may not be captured). Points are window-relative (0,0 = window top-left). Colours are sRGB from 2x window captures. Light = light appearance, dark = dark; a = key window, i = inactive. Account: Multicolour accent (blue), icon style Dark, glass tint 0.5. Data: `reference/re/27.2.1/live/finder/` (`finder-measurements.json`, `crops/`, `ax/`, `icons-*`); pictures: `reference/screens/27.2.1/finder/` (+ INDEX.md; the private sidebar rows are blanked).

- Q-finder-01: Yes, all five are glass: back/forward, view switcher, Group, Share/Tags/Action and Search are each an NSToolbar item-group platter = NSGlassEffectView `_variant` 0 (regular), 36 pt, full capsule. All platters right of the sidebar share one NSGlassContainerView (one `glassBackground` backdrop, shapes merged). Recipe at 36 pt, from MAC-ANSWERS Q9 + LIVE:
  - light: face black .4, white 1.03, saturation 1.2, fill white a.2;
  - dark: black .125, white 1.125, saturation 1.3, no fill;
  - both: blur r5 with opacities 0, 0, .5, 1; inner refraction 9 / -18; outer refraction 16 / 16 at opacity .6; ring shadow .06; drop shadow .04, r4, y 8; clamp 1.07 light / 1.31 dark.
  - Live pixels: light capsule 252 on the 255 strip; dark (61,62,70) on (32,33,39), or (67,69,77) while the pointer is in the toolbar. Inactive: light 240, dark (58,60,67).
  (Q9 probe dump + live pixels)
- Q-finder-02: Toolbar height 52 (AXToolbar). Every capsule spans y 8–44 (36 tall).
  - Back/forward x 170.5–244.5 (74; AX segments 36 + 37). It starts 7.5 pt after the 163 pt sidebar.
  - Title ink starts at x 256.
  - View switcher x 533.5–694.5 (161; 4 segments of 40.5).
  - Group x 702–749.5 (47.5).
  - Share / Tags / Action x 756.5–868.5 (112; buttons 36 / 38 / 37).
  - Search circle x 875.5–912.5 (36).
  - Gaps between capsules 7–7.5. Right inset 7.5. No other left inset (traffic lights at 18,18; pitch 23).
  - Glyphs are 13 pt `.large` `.medium` symbols (R3b-3). Ink: chevron 8x14, grid 15.5, list 16.5x12, columns 19.5x15, gallery 19x14.5, search 16x16.5, ellipsis 15x3.
  - At this width the view switcher shows 4 segments. At 800 pt (the user's windows), or when search is open, it collapses into one 51x38 popup.
  (AX frames + pixel edges)
- Q-finder-03: Glass `_variant` 18. It is edge to edge, not a floating inset panel: flush with the left, top and bottom edges, running under the toolbar from y 0, with no radius of its own (the window corner clips it). See MAC-ANSWERS Q9 §3 for the recipe and D, and Q-windows-15.
  - Width 163; 0.5 pt divider at x 162.5.
  - Live fill: light (237,237,238) a / (242,242,243) i. Dark over Electric Blue (36,38,55) a / (36,38,54) i (flat when inactive).
  (Q9 + AX + pixels)
- Q-finder-04: Sidebar layout.
  - Width 163. Rows 32. Section header rows 19.
  - First row (Recents) at y 52, directly under the toolbar.
  - Selection cell x 10–153 (inset 10, 143 wide), radius about 8.
  - Icon centre x 29 (ink 16–18 pt, e.g. clock 17x17, person.2 23x15.5). Text x 45 (AX), ink 46.5. Header text x 15 (ink 16.5).
  - Gap between sections: 13 pt of empty space before each header row, so 32 pt from the last row of one section to the first row of the next.
  (AX + pixels)
- Q-finder-05: See Q-windows-01/02/03; the same values hold for this Finder window.
  - Radius 16, continuous corner (spans about 24 pt).
  - Outer rim 0.5 pt black: a.21 light / a.93 dark (active).
  - Inner rim 1 pt white a.10.
  - Shadow: blur 20, y 18, density .40 light / .70 dark when active; 8 / 7 and .22 / .45 when inactive. Alpha profiles are in Q-windows-01.
- Q-finder-06: Title text.
  - SF **15 Semibold**: ink 88.5 pt for "finder-demo" equals SF 15 Semibold. This corrects Q-windows-12's "bold 13".
  - Only the folder name; no " — Local" and no subtitle.
  - Left-aligned at ink x 256, 11.5 pt after the back/forward capsule. The AX field fills the free space (248–530); the text truncates when it runs out.
  - Vertically centred in the 52 pt bar (ascender 19.5 to baseline 32).
  - Colours: light #4C4C4C a / #BFBDBD i; dark #E9E9E9 a / #5F5F64 i.
  (ink fit against AppKit renders)
- Q-finder-07: Sidebar text.
  - Items: SF 13 Regular. The selected row is 13 **Semibold** (ink 78.5 = 13 Semibold, against 74 for Regular).
  - Item colour: light black (0 at glyph cores, vibrant), dark 255. Inactive: light 113, dark (146,147,155).
  - Headers: SF 11 Semibold. Light 135 (about black a.43), dark (113,115,132) (about white a.35). Inactive 166 / (87,89,105).
  - Hovering a header shows a `chevron.down` at the right (ink 9.5x5.5 at x 136.5–146, centred on the header row, dark (160,162,177)). The header gets no fill.
  (ink fits + hover capture)
- Q-finder-08: Sidebar icons. They are monochrome 13 pt `.large` `.medium` symbols (R3b-3), not all tinted.
  - Recents (clock), Shared (person.2) and all Favourites use the accent: light (0,107,239), dark (30,152,255).
  - Locations (iCloud Drive, home, AirDrop, Bin) are not tinted: grey, light (123,123,128), dark (181,181,195).
  - All turn grey when inactive: light 127, dark (143,144,155). On a selected row the icon keeps its colour.
  - AirDrop = the `airdrop` glyph (ink 18x17).
  - Tag dots in the sidebar: not measured (the Tags section is off on this account).
  (pixels per row)
- Q-finder-09: Sidebar selection is a grey pill, not the accent.
  - Light (215,215,216) a / (231,231,232) i, on (237,237,238) / (242,242,243).
  - Dark (65,67,84) a / (50,52,67) i, on (36,38,55).
  - Geometry: x 10–153, 32 tall, radius about 8.
  - Hover: none. Pressed: none (the row selects on mouse-up, with no pressed fill).
  - A drag over a row shows an accent pill (47,110,237) with white text (drop target).
  (captures; press with drv3)
- Q-finder-10: Toolbar button states.
  - Hover: an inner capsule 28 tall (y 12–40), 30 wide on back/forward and Action, 35.5 on view segments; on Search the whole 36 circle lightens. The back/forward divider hides on hover.
  - Hover colours: light 242 on 252 (Search 236); dark (87,89,96) on (67,69,77).
  - Pressed looks the same as hover at 80 ms. Holding back/forward about 0.3 s opens the history menu.
  - Disabled: no hover; glyph tertiary (light 173; dark (113,114,122)).
  - The pill is a flat fill inside the glass capsule; the capsule is the glass.
  - Dark only: the whole toolbar strip lightens (32,33,39 → 39,41,47) while the pointer is anywhere in the toolbar, and also when the window is inactive.
  (still captures; recording)
- Q-finder-11: View switcher.
  - Selected segment: inner capsule 35.5x28, radius 14, inset 4 from the capsule top and bottom. Fill: light 231 on 252; dark (81,82,90) on (61,62,70).
  - Separators: 1 pt, about 20 tall, only between two unselected segments (hidden next to the selected or hovered one). Light 200, dark (113,114,122).
  - Icons: square.grid.2x2, list.bullet, rectangle.split.3x1, squares.below.rectangle (R3b-3).
  - Switching: the pill jumps in 1 frame (no slide), the same frame as the content change.
  (pixels + 60 fps)
- Q-finder-12: Icon grid.
  - Icon 64 (View Options: icon-size slider 24, grid spacing 54, text 12, labels at the bottom).
  - Cell 112 x 112 (icon pitch 112 in both directions). The grid starts at (173,62) = content + 10, toolbar + 10.
  - First icon at (197,66): centred in the cell, 4 pt from the cell top.
  - Label cap top 10 pt below the icon. Label max width about 104 (ink).
  (AX)
- Q-finder-13: Icon view selection.
  - Plate: 72x72, radius 7, icon inset 4. Light 230, dark (54,55,60). Unchanged when inactive.
  - Label: pill 17 tall for 1 line (2 pt below the plate), radius 5, about 5 pt side padding, white text. Fill: light (42,99,217) a / 220 i (text 33); dark (37,88,201) a / 70 i (text 228).
  - Hover: none.
  - Drop target: a grey plate (226), radius about 8.
  (rr fit)
- Q-finder-14: Icon label text.
  - SF 12 Regular, colour light 38 (label a.85), dark 221.
  - Line pitch 16 pt. At most 2 lines, centred; a long name wraps, then middle-truncates the last line with "…" ("from the…mber.txt").
  - Tag dots: 10 pt circles inside the label, left of the name. Each extra tag sits 5 pt to the right, behind the previous, with a 0.5 pt white ring. The text starts about 3 pt after the dots.
  - A tagged folder icon takes the tag colour (Projects with the orange tag is an orange folder).
  (ink fits)
- Q-finder-15: List view.
  - Header y 52–80 (28). Rows 20; first row at y 85.
  - Rows inset 10 pt both sides (x 173–910).
  - Disclosure triangle AX 15x22 at x 174. Icon 16 at x 189. Name x 209.
  - Default columns: Name 338, Date Modified 181, Size 97 (right-aligned, 7 pt pad), Kind 121.
  - Text: SF 13 Regular. Name = label colour (39 light); other columns secondary (128).
  - Header: SF 11.
  (AX + ink fits)
- Q-finder-16: List stripes and selection.
  - Stripes on the 2nd, 4th, … rows: light (244,245,245), dark (42,43,49). Full 20 pt, x 173–910, radius about 8.
  - Selection: same rect. Light (42,98,217), dark (36,87,201). Text white; secondary columns (191,208,244).
  - Inactive selection: light 220 (text 33 / 109); dark 70 (text 227 / 172).
  - Disclosure chevron: ink 5x8.5, secondary (dark 155).
  (pixels)
- Q-finder-17: List header.
  - Light: no own fill (white, like the content). Dark: a solid (40,40,46) bar that also covers the toolbar strip (hard pocket), over the (32,33,39) content.
  - Column separators: 1 pt x 16 (y 58–74). Light 229, dark (76,76,82).
  - Bottom line: 1 pt at y 79. Light 229, dark (66,66,72).
  - Sorted column: SF 11 Semibold in label colour (76 / 255), with a 7.5x5 chevron 6.5 pt left of the column edge. Other headers: 11 Regular, secondary 127.
  - Hover: none. Pressed: the cell fills 242 (light), square.
  - Resize cursor 30x24, hotspot (15,12), within about 1 pt of a boundary.
  (pixels + curmon)
- Q-finder-18: Exact strings on this account (en_GB, region Indonesia, 24 h; "." time and "," decimal come from the region).
  - Dates: "Today at 00.15", "Yesterday at 14.30", "9 Nov 2026 at 11.20" (this year, also within the week), "14 Jun 2023 at 16.05" (older). The year is shown in all cases.
  - Preview / inspector: "5 March 2026 at 09.12", "Yesterday, 14.30".
  - Sizes: "--" for folders, "43 bytes", "8 KB" (8000 B), "12 KB" (12134 B), "12,3 MB" (12345678 B). Decimal (1000) units, 1 decimal from MB up, none for KB.
  - 12 h strings: not measured (would mean changing the user's clock format).
  (AX values)
- Q-finder-19: Column view.
  - Columns 245 wide, with a 1 pt divider (light 229, dark 57). No grip; the resize cursor shows over the divider.
  - Rows 24. Icon 18. Text at column x + 38. Folder chevrons at the right.
  - Selection: inset 10 left / 11 right, 24 tall, radius about 8. Active column accent (light (41,98,217), dark (36,87,202)); parent columns grey (220 / 70); all grey when inactive.
  - Preview column (about 240): preview 219x259, name 13 bold, kind 11, "Information" rows (Created / Modified / Last opened) 23 pt pitch, Tags editor, Markup / More… buttons.
  - When opened on a volume, the first column lists Demo, Macintosh HD and Network.
  (AX + pixels)
- Q-finder-20: Gallery view.
  - Preview 443x357 at (195,84).
  - Strip: 48x48 thumbnails, pitch 59 (gap 11), at y 476.
  - Selected thumbnail: plate 54x54, radius 7 (light 189, dark (87,88,92)), unchanged when inactive.
  - Right pane, about 240–250 wide: same material as the sidebar (light 237, dark (36,38,55)), with a 0.5 pt edge. It holds:
    - a 50 pt icon;
    - the name, 15 Semibold;
    - "PNG image - 8 KB", 13 Regular tertiary;
    - "Information" (13 Semibold) with "Show More" (11, accent);
    - rows Created / Modified / Last opened: 11, label secondary, value Medium;
    - "Tags" with a tag editor;
    - Rotate Left / Markup / More… buttons at the bottom.
  (AX + ink)
- Q-finder-21: Yes, there is a status bar, hidden by default here (ShowStatusBar 0). It was toggled on, measured and turned off again.
  - Height 28, below the path bar; the window grows by 28.
  - No own fill (content background), 0.5 pt line above.
  - Centred text "9 items, 112,1 MB available" / "1 of 9 selected, …", about 11 pt, secondary (128).
  - In icon view: an icon-size slider 82x16 at the right.
  (AX + pixels)
- Q-finder-22: Path bar (on by default here).
  - At the bottom: 1 pt top line at y 531.5 (light 221–229, dark (66,67,73)), then 28 pt, with no fill and no glass.
  - Items: 16 pt icons + SF 11 Regular secondary (127). Chevron separators 4x6 secondary. Item x starts about 6 pt in from the content edge (AX 169).
  - Hover: none.
  - Drag target: the item gets an accent capsule behind its label (seen through the drag image).
  (AX + pixels)
- Q-finder-23: Finder context menus, in order (Finder's menu is not in AX; read from captures). Separators are shown as |.
  - File: Ask Siri | Open, Open With ▸ | Move to Bin | Get Info, Rename, Compress "Notes.txt", Duplicate, Make Alias, Quick Look, Copy | Share… | Quick Actions ▸ | Services ▸
  - Folder: Ask Siri | Open in New Tab, Paste Item* | Move to Bin | Get Info, Rename, Compress "Photos", Duplicate, Make Alias, Quick Look, Copy | Share… | Customise Folder… | Quick Actions ▸ | Services ▸
  - Multi-select: Ask Siri | New Folder with Selection (2 Items), Open, Open With ▸ | Move to Bin | Get Info, Rename…, Compress, Duplicate, Make Alias, Quick Look, Copy | Share… | Quick Actions ▸ | Services ▸
  - Background (icon view): Ask Siri | New Folder, Paste Item* | Get Info | View ▸, Use Groups, Sort By ▸, Clean Up, Clean Up By ▸, Show View Options
  - * only when something is on the clipboard.
  - No shortcuts are shown. Leading icons on Move to Bin, Share, Customise Folder, Quick Actions and Services; their text is at x 39, plain rows at 16.
  - No tag row, because this account has no favourite tags (FavoriteTagNames = ('')).
  - Files in `crops/context-menu-*.png`.
- Q-finder-24: See Q-menubar-12/22/24; context menus behave the same.
  - Hover: solid accent (0,122,255), rect inset 5 pt left/right, full 24 pt row, radius about 7, label / shortcut / chevron white.
  - Disabled: tertiary (a.25), no highlight on hover.
  - No animation: the highlight moves within 1 frame; activation blinks off 67 ms, on 50 ms, then a 0.2 s fade.
  - Text x 16 (28–30 with a state column, 39 with icons).
- Q-finder-25: not measured: the tag dots row only lists favourite tags, and this account has none (FavoriteTagNames is empty and syncs via iCloud, so it was not changed). What is visible instead:
  - Toolbar Edit Tags popover: a glass popover with an arrow, 252x99 pt, title "Assign tags to "<name>"" (11–12 pt secondary), a tag token field 218x27 (token = a tinted capsule with the tag name, e.g. "Red"), and an empty suggestion table. Picture: `popover-*.png`.
  - Icon labels: tag dots are 10 pt (Q-14).
  - List view: AX tag image 26x14 at the right end of the Name column.
- Q-finder-26: Quick Look.
  - A separate floating window (layer 3, AXWindow subrole "Quick Look"), not a sheet or an in-window panel. 1463x951 for a 1600x1000 px image (fits the screen), centred on screen.
  - Radius about 20 pt.
  - Title bar 38 with:
    - close and full-screen 14 pt discs (dark glyph discs) at (11,12) and (31,12);
    - the file name in 13 bold;
    - Markup, Rotate and Share buttons 34x26;
    - an "Open with Preview" capsule 139x26.
  - Content inset 5 on the left, right and bottom.
  - Frame grey 134–137 in light (over blue; looks opaque and neutral); the material could not be dumped.
  - Open: appears at about 0.79 scale, centred, and grows to 1 in about 0.25 s, ease-out (per frame .79 .85 .90 .93 .95 .97 .98 .98 .99 → 1), no fade seen.
  - Close: shrinks and moves into the file's icon in about 0.18 s.
  - Shadow: standard window shadow (not measured separately).
  (60 fps, AX)
- Q-finder-27: Rename field.
  - Fill: white text field. The base name is selected (#BAD6FB, 186,214,251); the extension is not.
  - Ring: 3 pt focus ring outside the field, accent at about a.5 (light (149,179,246)), with a 0.5 pt darker inner edge (114,158,244). Outer radius about 5; field corners almost square.
  - Icon view: the field is the label size (74x14 for "Old Letter.rtf"), text 12.
  - List view: the field is 16 tall in the 20 pt row and the ring spills over the row; the row keeps its accent selection.
  (pixels, light)
- Q-finder-28: Drag feedback.
  - Drag image: icon + accent label at about 0.90 opacity (label (62,113,221) vs (41,98,218)).
  - Multi-item: only the first item's image, plus a red count badge 19 pt (231,74,64) with a white bold number, at the icon's bottom-right.
  - Icon-view folder target: a grey plate 226, radius about 8, behind the folder.
  - Sidebar target: accent pill (47,110,237) with white text.
  - Path bar target: accent capsule.
  - List-view folder row: no highlight seen within 0.7 s.
  - Spring-load: the hovered folder opens in place within 1.9 s; Esc returns to the original folder and cancels.
  - Snap-back: Q-windows-27 (0.25 s, ease-out, no fade).
  - Cursor: Q-windows-27.
  (captures with drv3)
- Q-finder-29: Inactive window; values given as active → inactive.
  - Traffic lights grey.
  - Title: light #4C4C4C → #BFBDBD; dark #E9E9E9 → #5F5F64.
  - Toolbar capsules: light 252 → 240, glyphs 0 → 164; dark (61,62,70) → (58,60,67), glyphs dim. The dark strip lightens to (39,41,47).
  - Sidebar: flat (light 237 → 242). Text: light 0 → 113; dark 255 → 146. Icons grey: light 127; dark (143,144,155).
  - Sidebar selection: light 215 → 231; dark (65,67,84) → (50,52,67).
  - Icon / list / column selection: accent → grey (light 220, dark 70) with label-coloured text.
  - Unchanged: icon plates and gallery plates, stripes, content background, icons and labels.
  (a/i capture pairs)
- Q-finder-30: Motion, from 60 fps recordings.
  - View switch (Cmd-1..4): content and pill change in 1 frame.
  - Folder enter (Cmd-↓) and back: 1 frame, no slide.
  - Selection change: 1 frame.
  - Sidebar hover: none.
  - Search expand (click): the circle widens into a capsule (about 241 wide) in about 0.15–0.17 s, ease-out (left edge progress .19, .85, .86, .95, .99, 1). The view switcher collapses into its popup in 1 frame at the start. The focus ring appears after the expand, without a fade.
  - Search collapse (Esc twice): about 0.17 s.
  - Quick Look open and close: see Q-26.
- Q-finder-31: Rendered icons are in `icons-rendered/` (NSWorkspace icons: generic folder, Documents folder, Applications folder, PDF, txt, png, zip at 16 / 18 / 32 / 48 / 64 / 77 pt, 2x, light and dark). Live crops are in `icons-live/` (64 pt icon view, 16 pt list).
  - Light and dark renders are byte-identical, and the live Finder icons are pixel-identical in light and dark: no tint change in dark (this account's "Dark" icon style does not touch Finder's file icons).
  - Live folder blue (123,192,235) / (101,173,219).
  - In icon view, documents show Quick Look thumbnails (txt / pdf pages, the png image), not type icons.
  - A tagged folder is drawn in the tag colour.
  - The 64 pt live folder is about 9/255 mean different from the NSWorkspace render; the 16 pt one about 7.
- Q-finder-32: Tab bar (2 tabs; the second was opened with Open in New Tab on a test folder, then closed).
  - A 28 pt capsule track directly under the toolbar (y 52–80, x 167–879.5, radius 14). Light 232 with a 220 rim; dark (56,56,63) with a (72,72,78) rim.
  - Tabs share the width (AX 369 / 339).
  - Selected tab: an inner capsule 24 tall (2 pt inset), radius 12. Light 253 (text 75); dark (61,61,69) (text 235).
  - Unselected: no fill, text light 181 / dark 132.
  - Hover on an unselected tab: its segment darkens (light 220, dark (66,66,73)) and a × close glyph shows at its left (AX 18x18 at tab x + 4).
  - Text SF 11 Regular, centred.
  - New-tab "+" button: about 30 pt circle at x 883.5–912 (light fill 249, rim 191).
  - Inactive: everything dims (selected tab light 240, dark (51,51,60)).
  - When the tab bar shows, the toolbar keeps its 52 pt and the content moves down 28.
  (AX + pixels, `crops/tabbar-*.png`)

## Q-panels (27.2.1)

Setup: MacBook Air M2, 27.2.1, user account (not clean: Multicolour, icon style Dark, Liquid Glass 0.5, custom CC). CC
numbers are global pt (screen 1710 x 1107, menu bar 34). Backdrops for pixel work: a borderless window of solid white /
grey 127 / black / 4 pt stripes placed just under CC (level 3). Values are display RGB from `screencapture` at 2x.
Raw numbers: `reference/re/27.2.1/live/panels/`. Pictures: `reference/screens/27.2.1/panels/`.

### Control Center
- Q-panels-01: Other-process layers can't be dumped (no layer API into ControlCenter), so this is from pixels. Over a 4 pt
  black/white stripe backdrop, every 2x1 tile, round button, 2x2 Now Playing tile and slider module bends the stripes at
  its own rim and shows them blurred inside. So each module is its **own glass shape**; there is no shared panel glass.
  - Toggle circle **on** = opaque white disc (255), no backdrop. Toggle circle **off** = flat white 25 % over the tile
    glass (T + 0.25·(255−T)); no rim or refraction of its own. Same for the Now Playing art placeholder (white ~14 %
    over the tile) and the slider track (T+20).
  - Dark Mode **on** = the whole 64 pt disc is opaque white with a black glyph. The Home accessory tile when on = opaque
    white.
  - Variant: not readable. The closest AppKit match is `_variant` 9 (controlCenter). Over 255/127/0 it gives
    207/115/25 (dark) and 244/157/71 (light); the real tiles give 186/109/32 in both appearances. The real tiles sit on
    a 10 % black dim (gap = 0.898·in). Variant 9 composited over that dim comes out at about 188/106/25, within ±7. The HUD
    uses `_Glass.controlCenter` (REA section 1), so CC tiles likely do too; not traced. (stripe/white/grey/black
    captures + `tools/probe/ccglass.swift`)
- Q-panels-02:
  - **On** (Wi-Fi, Bluetooth, AirDrop): circle 255 white, glyph accent blue (52,120,246) = Multicolour systemBlue.
  - **Off** (Focus off; Wi-Fi/Bluetooth off use the same style): circle = white 25 % over the tile, i.e. 203/146/88 over
    white/grey/black backdrops. Glyph pure white 255.
  - **Focus on** (Do Not Disturb, toggled on and back off): circle 255 white with the moon in **indigo** (119,131,254
    at the most saturated pixel, i.e. the DND mode colour, not the accent). The title becomes "Do Not Disturb" (wraps to
    2 lines) with subtitle "On", and a chevron ">" (6 × 10.5, 193 over the grey backdrop) sits at the right.
  - Wi-Fi and Bluetooth were not switched off on this Mac (the network and input devices were in use). (pixels)
- Q-panels-03: Off tile, slider module and Now Playing tile all read the same.

  | Backdrop | Centre | 2 pt from left/right edge | 2 pt from top | 2 pt from bottom | Gap between tiles |
  |---|---|---|---|---|---|
  | white | 186 | 186–187 | 198 | 201 | 229 |
  | grey 127 | 109 | 109–110 | 123 | 127 | 114 |
  | black | 32 | 32 | 42 | 45 | 0 |

  - Centre = 32 + 0.604·in (as in #53).
  - The rim brightens only the top and bottom 2 pt: +12 at the top, +15 at the bottom. The sides are not lit.
  - The outermost 1 px at the vertical sides is dark (about 40 over grey).
  - Light and dark appearance are identical (#53). (pixels)
- Q-panels-04: AX order (window "Control Centre", AXSystemDialog). Grid = 4 columns × 64 pt, pitch 76 (gap 12).
  - Wi-Fi 2x1 (col 0–1, row 0)
  - Bluetooth 2x1 (row 1)
  - Now Playing 2x2 (col 2–3, rows 0–1)
  - AirDrop 2x1 (row 2)
  - Stage Manager 1x1 (col 2, row 2)
  - Screen Mirroring 1x1 (col 3, row 2)
  - Dark Mode 1x1 (col 0, row 3)
  - Capture Screen 1x1 (col 1, row 3)
  - Focus 2x1 (col 2–3, row 3)
  - Display slider 4x1 (row 4)
  - Sound slider 4x1 (row 5), with an AirPlay-audio button inside
  - row 6: empty cell, Background Sounds 1x1 (col 1), Home accessory 2x1 (col 2–3)
  - "Edit Controls" capsule 93.5 × 24, centred, 16 below the last row.

  This account is customised (the user added Stage Manager, Screen Mirroring, Dark Mode, Capture Screen, Background
  Sounds and Home), so the stock list can't be read here.
  - A Dark Mode button exists (when added). Reduce Transparency is not shown here.
  - **Extra row:** a privacy "recently used" pill (e.g. "<App> recently" with a purple screen-recording glyph) sometimes
    shows above the grid:
    - 137.5 × 24, centred on the grid, top y 44 (10 below the menu bar);
    - it pushes the whole grid down **28 pt** (first row y 74 instead of 46);
    - it is a glass capsule too. hyprk lacks it.

  (AX + pixels)
- Q-panels-05: **Window:** the AX window is 656 × 968 at x 1230 (it runs off the right screen edge); only the module
  frames matter.
  - **Grid:** x 1404..1696 → **width 292, right margin 14**, top **46 (12 below the menu bar)**.
  - **Tiles:** 2x1 140 × 64, 1x1 64 × 64, 2x2 140 × 140, slider 292 × 64; gap 12.

  Radii (shape fits on a window capture with the shape over black; rms ≤ 0.4 px):

  | Shape | Radius |
  |---|---|
  | 2x1 | capsule, r 32 (continuous fit 31.5) |
  | 1x1 | circle, d 64 |
  | 2x2 | continuous rounded rect, r 32 (fit 31.6) |
  | slider | continuous, **r 24** (fit 23.5) |
  | Edit Controls | capsule, r 12 |
  | sub-panels (Q-12) | continuous, **r 16** |

  **Panel behind:** none. Only a 10 % black dim under the module area that feathers out over about 100 pt; it is visible
  in the window capture's alpha as a soft rectangle about 0.09 opaque. (AX + `screencapture -l` alpha + fits)
- Q-panels-06: Matched against ink widths of the rendered system font.
  - **Toggle title:** SF **12 semibold**. Widths agree within 0.5 pt: Wi-Fi 30.0, Bluetooth 55.5, Focus 33.5, Not Playing
    65.5.
  - **Slider-module titles** (Display 42.0, Sound 36.0): also 12 semibold.
  - **Subtitle:** SF **11 regular** ("Contacts" 46.0, "On" 14.0). The Wi-Fi subtitle is the network name.
  - **Colours (#53):** title = white at 85 % over the tile (245/233/221 over white/grey/black backdrops). Subtitle =
    plus-lighter T+140 (255/249/172). Slider titles and all glyphs = 255.
  - **Over a light wallpaper:** no change; labels stay white.
  - "Edit Controls" = SF 12 regular (ink 71.5). (ink-width match, `ink.swift`)
- Q-panels-07: 140 × 64 tile, positions relative to the tile.
  - **Circle:** 36 at x 14, centred (y 14).
  - **Text:** ink starts at x 56.5 (≈ 6.5 after the circle); right pad ≥ 10.
  - **One title + subtitle:** title cap top y 19 (baseline ≈ 27.5), subtitle cap top y 36 (baseline ≈ 44).
  - **AirDrop (3 lines):** cap tops 13 / 28 / 42 (pitch 15 then 14); the block is centred vertically.
  - **Glyph ink in the circle:** Wi-Fi 19.5 × 14, Bluetooth 11 × 18.5, AirDrop 19 × 18, Focus moon 16.5 × 16. That fits
    ≈ 18 pt symbols (glyph ≈ 0.5 of the circle).
  - **Round 64 buttons, glyph ink:** Stage Manager 28 × 19, Screen Mirroring 27.5 × 23, Capture Screen 25.5 × 20,
    Background Sounds 25.5 × 22, Dark Mode 22.5 × 22.5. So ≈ 24 pt symbols, not 22.
  - **Hover chevron:** hovering a 2x1 tile adds a ">" at the right, 6 × 10.5 at x ≈ 119. (pixels)
- Q-panels-08: Slider module 292 × 64, r 24.
  - **Title:** "Display"/"Sound" 12 semibold, ink x 17, cap top y 13.5.
  - **Track:** 4 pt tall, centre y 42 (bottom 20 from the module bottom), capsule ends. The AX slider frame is 14 tall,
    centred on the track.
    - Display track x 36.5..254 (217.5).
    - Sound track x 34..214 (180), because the AirPlay-audio button (AX 26 × 26 at x 252, y 29; circle white ~25 %,
      glyph airplayaudio 13 × 13) takes the right end.
  - **Glyphs:**
    - sun.min.fill 15 × 15 at x 15.5, and sun.max.fill 16.5 × 16.5 ending 16 from the right;
    - speaker.fill 9 × 13.5 at x 16.5, and speaker.wave.3.fill 20.5 × 15 at x 220.5;
    - all white 255.
  - **Fill:** white 255. **Track:** T+20 (206/129/52 over white/grey/black).
  - **Thumb:**
    - none at rest;
    - on hover, a **white 18 × 14 rounded knob** appears at the fill end, and a chevron ">" appears at the top right of
      the module (it opens the sub-panel);
    - while pressed or dragged, the knob turns into a **clear glass lens about 24 × 20**, with a dark 1 pt rim, a soft
      drop shadow, and the track magnified through it. (AX + pixels + 60 fps video)
- Q-panels-09: Sound slider, 60 fps without cursor; the volume was restored to 38.
  - **Click:** the fill animates to the new value; no jump.
    - Progress per frame: 0.11, 0.19, 0.38, 0.56, 0.71, 0.83, 0.90, 0.95, 0.97, 0.99, 1.0 → **about 0.2 s**, ease-out
      spring, no overshoot.
  - **Drag:** follows the pointer 1:1. The fill end stays about 9 pt ahead of the pointer hotspot (half the knob) with no
    visible lag at 200 pt/s.
  - **Pressed look:** the knob turns into the glass lens within about 3 frames.
  - **Past the end:**
    - the track end and fill stretch **3.5–5 pt beyond** the end (1618 → 1621.5–1623) while the pointer is held 87 pt
      past it (rubber band, heavily damped);
    - on release it springs back over about 8 frames (0.13 s), 1621.5 → 1618;
    - the module itself does not move. (video)
- Q-panels-10: Over grey 127 (tile at rest = 109).
  - **2x1 tile:**
    - hover = **+7** (white ≈ 5 % overlay), ramping in over about **0.25 s**, plus the chevron;
    - press = **+37** (white ≈ 25 %), instant (1 frame), brighter near the pointer (pointer light), and the tile grows by
      about 1 pt (≈ ×1.01);
    - release falls back in about 3 frames (0.05 s), then the sub-panel opens.
  - **Round 64 button:** hover +7; press **+54** (white ≈ 37 %, slight gradient) and it grows ×1.04–1.05 (64 → about
    67).
  - **Toggle circle:**
    - hover = the whole tile hovers (+7 on tile and circle; no separate circle hover);
    - press = circle 146 → **206** (white ≈ 55 % over the off circle), tile 129;
    - the circle does not grow. (stills + video)
- Q-panels-11: **Idle:**
  - art placeholder 40 × 40 at (14, 14), continuous r 10, flat white ~14 % (129 over grey);
  - "Not Playing" 12 semibold at (14, 72);
  - three buttons 30 × 30 at y 96, x 15 / 55 / 95 (pitch 40);
  - prev/next disabled (glyph 160 over grey, ink 22 × 12.5); play enabled (186, ink 17.5 × 19).

  **Playing** (QuickTime, own silent test track):
  - the art is the app's placeholder (white 244, r 10, grey music note), still 40 × 40; it does not fill the tile;
  - title 12 semibold, wraps to 2 lines (pitch 15) with no artist line;
  - pause.fill replaces play.fill; prev/next stay disabled for a single file.

  (AX + pixels; crops `cc-nowplaying-*.png`)
- Q-panels-12: Clicking a tile body (not its circle) or a module chevron replaces the whole grid with **one glass panel
  of the same family**:
  - x 1394..1702 (**308 wide**, 8 pt right margin), **top 40**, continuous **r 16**;
  - fill = same as the tiles (109 over grey);
  - rows 280 × 32 at x 1408 (14 inset); hovered row = capsule fill +21 (130 over grey);
  - section header SF 13 bold at (1408, 53);
  - separators 1 pt; a "… Settings…" row at the bottom.

  | Panel | Height | Contents |
  |---|---|---|
  | Wi-Fi | 175 | header + switch 54 × 24 at the top right, "Known Network" heading, network rows, "Other Networks" disclosure, "Wi-Fi Settings…" |
  | Bluetooth | 280 | header + switch, device rows 32 (scrolls) |
  | Focus | 280 | header, 6 mode rows with 28 pt circle icons, "Focus Settings…" |
  | Display | 189 | slider 233.5 with a white knob 20 × 16 that is always visible here; three 87.5 × 69 round toggles (Dark Mode / Night Shift / True Tone) with labels; "Display Settings…" |
  | Sound | 258 | slider 230 with knob, "Output" heading, device rows 298 × 32, "Sound Settings…" |

  - **Screen Mirroring:** clicking its round button showed nothing (no receivers).
  - **Way back:** Esc returns to the grid (a 2nd Esc closes CC); clicking outside closes CC.
  - The grid-to-panel change is a morph of about 0.35 s. (AX + pixels; names of networks/devices not recorded)
- Q-panels-13: Already known.
  - R2 Motion: a fade, ease-out, about 0.3 s in and 0.17–0.2 s out.
  - REA section 2: **the whole panel** animates with Spring(0.25, bounce −0.027) (response 0.25 s, ratio 1.03).
    Opacity goes 0 → 1 and scale **1.01 → 1.0** on open, the reverse on close. Anchor not traced (centre assumed).
  - Not per tile: every tile is in place from the first frame, no stagger, no overshoot.

### Spotlight
The window belongs to the Siri process (layer 23) and its content is not in AX, so these are pixels. Dark appearance, over
grey 127 unless noted.
- Q-panels-14: No layer dump (other process). REA already gives the field = Regular glass, size large, content lensing,
  and the results = `siri`/`searchResults`, r 37.
  - **Field and results are two separate glass shapes**, with a 10 pt gap of plain backdrop between them.
  - **Field in pixels:**
    - over 4 pt stripes it refracts at the rim and shows heavily darkened, blurred stripes inside;
    - it is very dark with a **vertical gradient**: over white 8 at the top → 65 at mid → 127 at the bottom; over grey
      6 → 36 → 64; over black 1 → 6 → 17;
    - mid-height ≈ 6 + 0.23·in, so a strong dark tint (this account uses icon style Dark; see R2 note).
  - **Results panel:** lighter. 71 → 83 top to bottom over grey, with a bright 1 px rim top and bottom.
  - A wide soft shadow sits under the bar (grey 127 → 96 right at the edge, ~30 pt falloff). (pixels)
- Q-panels-15: **No inner field shape.** The empty bar is one dark capsule with the gradient, with no inset capsule.
  - The only inner fill is the completion pill behind "— Open" / "= 4" (fill 63 on the 25 bar at that height,
    ≈ white 15 %, radius ≈ 6). (pixels)
- Q-panels-16: **Query text:** SF **22 regular**, white 255 ("calculator" ink 91.5 = 22 regular).
  - **Placeholder:** "**Search or Ask**", 22 regular, grey ≈ 165 on the bar (white ~60 %).
  - **Inline completion:** "— Open" (apps), "— Run" (actions), "= 4" (calculator), grey ≈ 203 on a pill.
  - **Caret:** white, 2 × 26 pt (y 281..307), with a soft multicolour glow halo ~6 pt (bluish top, warm bottom).
  - **Text start:** x 634 (39 from the bar's left edge).
  - **Selection colour:** not measured. (pixels + ink match)
- Q-panels-17: Screen 1710 × 1107.
  - **Empty bar:** x 595..1115, y 251..338 → **520 × 87**, capsule (r 43.5), centred horizontally; top at 22.7 % of
    the screen height.
  - **With results:** the bar stays the same size and position.
  - **Calculator answer:** the bar itself grows to 520 × 172.5 (see Q-21).
  - **Magnifier:** **none** in 27.2.1. The left side is empty; in a mode the mode glyph sits there. The right side holds
    a **mic** glyph (ink 14.5 × 21 at x 1061.5, grey ≈ 166), or the top hit's app icon (≈ 28 pt) once text is typed.
  - The Siri window is 520 × 137 empty (shadow room) and grows with the content. (pixels + window list)
- Q-panels-18: **Two glass shapes.**
  - Results panel: x 595..1115 (520, same as the bar), top **348** (gap **10** below the bar), height 410 for a long
    list, r 37 (REA).
  - **No divider** between field and results; a 1 pt separator only in Apps/Files grids.
  - It scrolls with a 5 pt overlay scrollbar (x 1106..1111, white ~25 %).
  - Visible: chips row + 5½ rows of 62, so the max height ≈ 410 (not exceeded with long lists). (pixels)
- Q-panels-19: **Row:** **62 tall** (pitch 62, no gap).
  - Icon 32–36 (app icon 36.5, file icon 32 × 33.5) at x 620 (25 from the panel edge).
  - Title SF **17 regular** white at x 675 (80 from the edge).
  - Second line SF **15 regular** grey ≈ 153 (≈ white 55 %): "Kind · size · date · folder-glyph folder".
  - **Selection pill:** x 607..1102 (12 inset left, 13 right), 62 tall, r ≈ 22 (continuous), fill +11 over the panel
    (90 on 79 ≈ white 6 %).
  - **Keyboard:** Down/Up move the pill; the list scrolls with the chips row pinned at the top.
  - **Hover:** a synthetic pointer move over another row showed **no hover fill** and did not move the selection.
  - **Top hit row:** trailing text "Search <App>" SF 10 regular grey ≈ 158, plus a "tab" key badge (27.5 × 18, white
    ~30 % fill, dark text).
  - **Chips row** above the rows: recent-app chips, text SF 15 regular ≈ 210, height 26, top 20 below the panel top.
    (pixels + ink match)
- Q-panels-20: For "safari", "calculator" and a file name the layout is the same: chips row, then the **top hit** (app,
  with "Search <App>" + tab), then file rows.
  - **No section headers**, no "Top Hit" label, no "Show More", no kind column, **no preview pane**.
  - Right-side text appears only on the top hit; file rows carry the kind in their second line.
  - "2+2" has no list at all (see Q-21).
  - Headers do exist inside the modes: "Suggestions" (Actions) and "Recents" (Files). (pixels)
- Q-panels-21: **"2+2":** the answer is inline in the field ("2+2" + grey pill "= 4"). The **bar grows** to
  520 × 172.5 (y 251..423.5) and contains a **result card**:
  - card x 614..1096 (19 inset), y 338..398 (60 tall), capsule, glass with a light rim;
  - line 1 "2+2 =" SF 12 regular grey;
  - line 2 "4" SF **16 semibold** white;
  - a 30 pt round copy button at the right;
  - the calculator icon at the top right of the bar.

  Under the bar (gap 10), a separate glass capsule "**Show Results**": 148 × 44, SF 13 regular, with a calculator + Finder
  icon pair.

  **Unit conversion** ("100 cm in inches") uses the identical layout ("= 39,37 inches"; the locale decimal comma). There
  is no 1.3× row. (pixels + ink match)
- Q-panels-22: **There are no round mode buttons** in 27.2.1 (the hyprk 4 × 56 glass circles are wrong).
  - **Hovering the empty bar** drops a **mode list** panel under it: one glass panel 520 × 214 at y 348 (gap 10), same
    look as the results panel.
  - It has 4 rows, pitch 48:
    - glyph ~20–22 pt (ink 22 × 20 etc.) centred at x 44 from the panel edge;
    - label SF **17 regular** white at x 81;
    - shortcut "⌘1".."⌘4" SF 14 regular grey ≈ 143, right-aligned 39 from the edge.
  - Glyphs:
    - Applications = App Store "A" (`app.store`-like);
    - Files = `folder`;
    - Actions = `square.stack.3d.up`-like layers;
    - Clipboard = `doc.on.clipboard`-like.
  - Shown only while the field is empty and the pointer has entered the bar; it stays after the pointer leaves.
    (pixels)
- Q-panels-23: Mode rows: no active state was seen (they are shortcuts, not toggles). No hover fill and no tooltip were
  seen with synthetic moves. Glyphs and labels are white 255, shortcuts grey. (pixels)
- Q-panels-24: **Modes:** Applications ⌘1, Files ⌘2, Actions ⌘3, Clipboard ⌘4.
  - In a mode, the field shows the **mode glyph at the left** (≈ 22 pt, x ≈ 618) and the **placeholder = mode name**
    ("Applications", "Files", "Actions", "Clipboard"). There is no token pill.
  - A "…" menu sits at the right in Applications, Files and Clipboard (none in Actions).
  - **Left/Right** do not cycle modes (no change seen).
  - **Tab** in Actions puts the first suggestion into the field ("Send Message — Run").
  - **Esc:** 1st leaves the mode (or clears a query) back to "Search or Ask"; 2nd closes. (pixels)
- Q-panels-25: Windows (Siri, global pt):
  - **Applications** = the Apps view, documented in Q-dock-23..26: window 844 × 617 at (433, 251), capsule 520 × 87 +
    panel 844 × 520, 7 columns, icon 60, chips 26.
  - **Files** = the same 844 × 617 grid: filter chips by app (Preview, PDF, Microsoft Word, …), a first row of recent
    documents, a "Recents" header, then a 7-column icon grid with 2-line names.
  - **Actions** = a 520-wide list panel (y 348..838, 490 tall):
    - "Suggestions" header SF 12 semibold/bold grey at x 23, with a 1 pt separator under it;
    - rows pitch 62: app icon ~36, title 17 regular, app name 15 regular grey;
    - a trailing "Add quick keys" grey capsule (≈ 10 pt text) or a key badge.
  - **Clipboard** = the same 520-wide list (window 520 × 587):
    - rows pitch 62: kind icon, item text 17 regular (1 line, truncated), second line "Text · Copied yesterday"
      15 regular grey;
    - a round copy-type badge at the right.
  - **Empty or first-use texts:** not seen; every mode had content on this account.
  - Contents of Files and Clipboard are the user's and were not saved. (pixels)
- Q-panels-26: Open and close are in R2 + REA section 4: bar x 1.12 → 1, y 0.95 → 1, spring 0.28; close with blur 25 and
  a fade.
  - **Results:** the panel is a separate shape (it does not grow out of the bar).
  - **Mode list on hover:** it **unfolds downward from the bar** in about **0.17 s**. Share per frame: 0.04, 0.11, 0.22,
    0.36, 0.51, 0.66, 0.78, 0.87, 0.94, 0.98, 1.0 (ease-in-out). It starts within 1–2 frames of the pointer entering.
    (60 fps video)

### Banners (own test notifications from `osascript display notification`, shown as "Script Editor")
- Q-panels-27: AX `AXNotificationCenterBanner` in the NotificationCenter process; the window is a full-screen
  "Notification Center" at layer 23.
  - **Frame:** x 1350..1694 (**344 wide**, **right margin 16**), **top 44 (10 below the menu bar)**.
  - **Heights:**

    | Content | Height |
    |---|---|
    | title + 1-line body | 58 |
    | title + subtitle + body | 75 |
    | 3-line body | 90 |
    | title + **4-line body** (max; then "…") | 105.5 |

  - **Shape:** continuous **r 20** (fit on black, rms 0.08 px).
  - **Glass:** yes. Over the stripes/menu bar it refracts (it picks up the blue menu bar at its top edge).
    - Fill 33 over black, 114 over grey 127.
    - Rim +35 at the top edge, +20 at the bottom.
  - Variant: not readable (other process). (AX + pixels)
- Q-panels-28: **Fonts:**
  - title SF **13 semibold** (ink "hyprk test" 62.5);
  - subtitle also 13 semibold;
  - body SF **13 regular** (93.5);
  - all ≈ 233 (white ~90 %) on the 114 card; line pitch 17.
  - **Text frame:** x 1408 (58 from the card edge), first line 12 below the card top.
  - **No app-name line and no time in the banner.** In NC the card adds a right-aligned time ("now", "1h", SF ~12, grey,
    14 from the right edge).
  - **Icon:** the app icon ≈ 32 × 32 at 13 from the left, centred vertically.
  - Sender photo and badge: not tested (needs Messages). (AX + pixels + ink match)
- Q-panels-29: **On hover** the AX frame grows to (1344, 40, 350, 109.5) for the hit area, and these appear:
  - a **Close** button (xmark, 28 × 28 frame, a small glass circle) centred on the **top-left corner** (1340, 36);
  - a **chevron ">" "Show Details"** 16 × 20 at the top right (1666, 50);
  - the notification's **action** as a grey glass capsule "**Show**" 64 × 22 at the bottom right (1620, 117.5); the body
    text fades out under it.
  - There is no "Options" pill for this app.
  - Expanded banner and reply field: not available from osascript notifications.
  - A mouse **drag to the right** (140 pt) **dismisses** it. (AX + pixels)
- Q-panels-30: **In:** slides in **from the right screen edge** (x 1710 → 1350) **with a fade**; the size looks
  slightly blurred or larger in the first frames. Burst captures at ~30 Hz:
  - left edge at 0.43 s: 0.45 of the travel; 0.48: 0.81; 0.54: 0.89; 0.57: 0.94; 0.61: 0.96; 0.64: 0.98; 0.67: 0.99;
    settled ≈ 0.77;
  - so about **0.35 s ease-out** (spring-like, no visible overshoot), starting about 0.4 s after posting.
  - **On screen ≈ 4.7 s**, then **out**: slides right with a fade, accelerating, gone in ≈ 0.15 s.
  - **Hover pauses** the timer (it stayed 10 s while hovered) and it leaves ≈ 1 s after the pointer leaves.
  - **Same app twice:** the 2nd banner replaces the 1st in the same slot; no visible stack while showing. In NC they
    become one stack.
  - Banners are **suppressed while the screen is being recorded** (avfoundation/ffmpeg): "show notifications while
    sharing" is off. So 60 fps video was impossible; these are `screencapture` bursts. (pixel bursts)

### Notification Center (numbers only; the user's notifications were not captured)
- Q-panels-31: The window is full screen (1710 × 1107, layer 23). Scroll area x 958..1710 (752 wide).
  - **Column:** x **1350..1694 = 344 wide, right margin 16, top 44** (10 below the menu bar).
  - **Cards:** 344 wide, gap **6**; heights 58 / 75 / 90 / 106.5 by content (as banners); continuous r 20.
    - Fill **32 over black, 128 over white** (≈ 32 + 0.38·in). That is darker and more opaque than CC tiles
      (32 + 0.60·in) and the banner over grey.
    - Glass rim at the top/bottom.
    - Variant not readable (other process). The CC/HUD style `_variant` 9/10 in AppKit doesn't match these values.
  - **No scrim:** the backdrop is unchanged away from the column. Only a soft shadow/dim feathers ~50 pt around the
    cards (255 → 200 right next to them, over white).
  - **Widgets** (this account: Calendar small + Batteries small; not the stock set):
    - grid 344 wide, **164 × 164**, gap 16, 16 below the last notification element;
    - with icon & widget style "Dark", the **Calendar widget is opaque** (same 37 → 14 vertical gradient over white and
      black);
    - the Batteries widget is translucent (14 over black, 64 over white).
  - **"Edit Widgets"** capsule 87 × 24 at the bottom (y 1010), centred on the column.
  - **"N more notifications"** capsule 117.5–124.5 × 24, centred, glass (fill 31 over black, 166 over white). (AX + pixels)
- Q-panels-32: **Groups:**
  - section heading "Notification Centre" (159 × 21, ≈ SF 17 bold, white with a soft shadow) at x 1351, with a **"Clear
    All"** 28 pt glass circle (xmark) at the right edge (x 1670).
  - **Collapsed app stack:** the front card plus **2 plates peeking 8 pt each** below it (plate 1 fill ≈ 15, plate 2 ≈ 12
    over black; narrower than the card).
  - **Expanded group:**
    - header = app name (SF ≈ 15 bold, 94.5 × 19) at x 1351;
    - a "**Show less**" glass capsule 80.5 × 28 and a 28 pt "Clear" circle at the right;
    - first card 3 below the header, cards gap 6;
    - clicking the group's x morphs it into a "**Clear**" confirm capsule (56 × 28), while "Show less" shrinks to a
      28 pt circle; a 2nd click clears the group.
  - **Open and close:** slide in/out horizontally from the right edge, x only, no fade (REA: Spring(0.3, −0.2),
    ratio 1.25). The recording (R2) shows ~0.3 s ease-out in and ~0.15 s accelerating out. No stagger. (AX + pixels)

### Alerts and sheets (own probe `tools/probe/panels.swift`; layer dumps in `27.2.1/live/panels/`)
- Q-panels-33: App-modal NSAlert, dark mode (light has the same geometry).
  - **Size:** **260 wide**. Heights: 234 (2-line title + 1-line text), 274 (with text field + checkbox), 334 (3 buttons).
  - **Icon:** **66 × 66 at (19, 19), left-aligned**, not centred. The critical style uses a caution triangle with the
    app-icon badge.
  - **Text:** title SF 13 bold at x 21, 14 below the icon; message SF 13 regular, 8 below the title; text width 218.
  - **Position:** centred horizontally. Vertically the alert's top = 289.5 − h/4 (so the point h/4 down from its top
    sits at 26 % of the screen height); this held for all three heights.
  - **Dim scrim: none** for app-modal alerts. The desktop and the parent window are unchanged; the parent only goes
    inactive.
  - **2 buttons:** side by side. AX 112 × 30 (visible 110 × 28 capsules, r 14) at x 15 and 133, bottom 15 from the
    edge. Default (first) on the **right**, Cancel on the left.
  - **3 buttons: stacked vertically, full width** 230 × 30 (visible 228 × 28), pitch 34. Order top → bottom: default
    (Save…), 3rd (Delete), Cancel.
  - **Fills:**
    - default = accent **(52, 120, 246)** with white text;
    - other buttons = white ~4.7 % + 3 % layers (71, 72, 79 on the 55, 56, 63 dark alert body);
    - text 13 regular (default 13 regular white).
  - **Pressed:** the plain button gets lighter, 71 → 89 (+18). No size change seen. No hover state.
  - **Destructive** (`hasDestructiveAction`): **red text (≈ 220, 57, 41)** on the grey capsule. It is not blue even when
    it is the first button.
  - **Glass:** regular glass, radius 26, in its own `_NSGlassEffectWindow` (as LIVE-27.2.1).
  - **Accessories:**
    - text field 222 × 26 at x 19, 14 below the message, with an accent focus ring and selection;
    - suppression **checkbox** "Don’t ask again" (118 × 18) at x 21 under the field, 14 above the buttons.

  (own probe: AX + pixels + layer dump)
- Q-panels-34: **Sheets in 27.2.1 are centred on the parent window**, not hung from the titlebar:
  - a 440 × 220 sheet on an 800 × 552 window sat at the exact centre (x and y);
  - an NSAlert sheet (260 × 154) did the same.

  **Custom sheet** (`beginSheet`):
  - **solid** `windowBackgroundColor` (34, 35, 47 in dark), **continuous r 16** (fit ≈ 17.9), window shadow;
  - **no glass**, no titlebar.

  **Alert sheet:**
  - **regular glass r 26** in an `_NSGlassEffectWindow`, the same recipe as the app-modal alert (only size-scaled inputs
    differ: bleed 53.9 vs 91, outer refraction 38.5 vs 65, shadow 0.7 vs 0.8);
  - **no icon** in the sheet form; buttons side by side as in Q-33.

  **Parent dim:** with any sheet the **whole parent window, titlebar included, is dimmed ≈ 20 %** (content 32 → 26,
  titlebar 40 → 29 in dark).

  Timing: LIVE-27.2.1 (in 0.27 s, out 0.25 s).

  **TextEdit Save sheet** (new untitled test doc, Cmd-S) agrees:
  - 390 × 218, centred on the 586 × 488 parent;
  - solid fill (35, 33, 46) in dark, continuous r ≈ 16–18;
  - parent dimmed;
  - rows Save As / Tags / File Format / Where: labels right-aligned at x 39, fields 232 × 26 at x 118.5;
  - Cancel / Save capsules 81 × 26 at the bottom right, gap 6;
  - the close-with-changes variant is 390 × 318, with "Delete" at the bottom left.

  **Text field / checkbox alert:** see Q-33 (field 222 × 26, checkbox under it). (own probe: AX + pixels + layer dump)


## Appearance pane, Liquid Glass, icon style, switches, scrolling (PC #60)

# Appearance pane, 27.2.1 (live Mac, 2x)

Method: AX frames from `axd` (window at 484,232, so window y = AX y − 232), 2x `screencapture -o -l` pixel scans, 60 fps
clips, and a new probe `reference/re/tools/probe/switches.swift`, which samples NSSwitch presentation layers at about
one sample per display frame. y is the window y at scroll offset 0 unless noted. Wallpaper was Tahoe Light/Dark.
Already known and not redone: Q-settings-11/12/16/17/18/25/26/27, #35.

## 1. Pane, top to bottom
- Pictures: `screens/27.2.1/settings/appearance/appearance-full-{light,dark}.png` (stitched, 508x1088.5 pt). Window
  shots at offsets 0/10/250/463.5. Data: `re/27.2.1/live/settings/appearance/layout.json` and `ax-scroll*.jsonl`.
- Geometry:
  - Toolbar 52. The visible content is 573 tall.
  - The document is 1036.5 tall, so the maximum scroll is 463.5.
  - Cards are 468 wide at x 252 (20 pt side margins).
- Sections in order (y = top, h = height, gap = space above it):

  | # | section | y | h | gap | contents |
  |---|---|---|---|---|---|
  | 1 | Card (no heading) | 64 | 319 | 12 below the toolbar | see the two rows below |
  | 2 | Heading "Theme" (13 Bold) | 413 | 16 | 30 | |
  | 3 | Card | 439 | 100 | 10 | see the two rows below |
  | 4 | Card | 549 | 145.5 | 10 | see the two rows below |
  | 5 | Heading "Windows" | 724.7 | 16 | 30 | |
  | 6 | Card | 750.5 | 75 | 10 | see the two rows below |
  | 7 | Card | 835.5 | 189 | 10 | see the two rows below |
  | 8 | Button row | 1044.5 | 24 | 20 | "More in Accessibility Settings…" 212.5x24 at x 473.5, then "?" 24x24 at x 696 (gap 10) |
  | | Bottom margin | | 20 | | |

- Rows inside the cards:
  - Card 1:
    - "Appearance" row, 86 tall: three thumbnail buttons, AX 74x66 at y 74, x 472/554/636.
    - Separator.
    - "Liquid Glass" row, 232 tall: preview 268x180 at (442,161), then the slider row at y 354.
  - Card 3:
    - "Colour" row, 62 tall: 9 swatches, AX 32 pt, pitch 36, at y 445, with the caption under the selected one.
    - Separator.
    - "Text highlight colour" row, 37 tall: pop-up 133x24.
  - Card 4:
    - "Icon & widget style" row, 104.5 tall: 4 tiles, AX 38x52 at y 558, then the radio row at y 627 (16.5 tall).
    - Separator.
    - "Folder colour" row, 40 tall.
    - With Default selected the radio row goes away and the card is 129 tall.
  - Card 6:
    - "Sidebar icon size" row, 37.5 tall: pop-up 96x24.
    - Separator.
    - "Tint window background with wallpaper colour" row, 36.5 tall: mini switch 36x16 at x 674.
  - Card 7:
    - "Show scroll bars" row, 105 tall: label plus 3 radios at a 22.5 pitch.
    - Separator.
    - "Click in the scroll bar to" row, 83 tall: label plus 2 radios.
- Separators are 2 px (1 pt at 2x) here, #2F3035 on the #25262B dark card, inset 10 pt.
- Same layout in light and dark (AX identical).

## 2. Liquid Glass
- **No Clear/Tinted cards.** The control is one continuous slider, "Liquid Glass Tint Amount".
  - Track 221.5 pt wide at x 465, in a 16 pt row. Knob 20x16, as Q-18.
  - Left end: button "Capsule Shape On A Rectangle With A Liquid Glass Effect", 16x13, an outlined clear capsule.
  - Right end: button "Capsule Shape On A Rectangle", 17x13.5, a filled grey capsule. Gap to the track is about 6.
  - **3 tick dots, 2x2 pt**, at y 368–370 (bottom of the row, under the track), at the knob-centre positions for 0, 0.5 and 1 (x 475, 575.75, 676.5).
    - Dot colour: #B7B7B7 light, #5B5C5F dark.
    - The middle dot is hidden under the knob at 0.5.
  - Fill: accent #3375F0 light, #397BF7 dark. Unfilled: #DFDFDF light, #37383C dark.
  - There are no text labels; the end icons are the labels. The selected state is just the knob position.
- Behaviour:
  - It does not snap: dragging gave 0.2555831.
  - Clicking an end button steps the value by −0.1 / +0.1.
  - The preview (glass capsules over the Apple Park article) does not change while dragging. It updates in a single
    frame (no animation) about 50 ms after mouse-up (60 fps clip).
  - 0 = clearer, more transparent capsules. 1 = frosted, more opaque capsules: lighter in light mode, darker/greyer
    in dark mode.
  - Mean colour of the Search capsule: light 0 #E1DBCB, 0.5 #E0DDD4, 1 #E6E5E2; dark 0 #989590, 0.5 #8F8E89, 1 #5A5A57.
  - In dark mode the window's own back/forward toolbar capsule also changes: face #3C3E40 at 0, #4B4E52 at 1. The sidebar does not change.
- Defaults:
  - Only the global domain changes: `NSGlassTintAmount` (float), written on mouse-up. `com.apple.WindowManager` is unchanged.
  - Restored to 0.5071146 (float) by setting the slider's AXValue. `defaults read-type` gives float, and the whole
    `defaults read -g` output matches the backup.
- Pictures: `liquidglass-0-mid-1-*.png`, `liquidglass-slider-zoom4x-*.png`.

## 3. Icon & widget style
- Tiles:
  - Default/Dark/Clear/Tinted: AX 38x52 (Default is 40 wide when selected, because of the bold caption).
  - Pitch: Default to Dark 53, then 51, 51.
  - Tile 29 pt. Caption 11 pt, bold when selected.
- Selected state:
  - A 3 pt #3478F6 ring with a 1.5 pt gap (ring outer = the AX frame, 38). Pixel-confirmed in light and dark.
  - The tile itself is unchanged.
- Sub-choice (radio row, right-aligned at x 710):
  - Dark → Always / Auto (121 wide).
  - Clear and Tinted → Light / Dark / Auto (167 wide; radios 52, 49.5 and 49.5 wide at x 543/603/660.5).
  - Default → no row.
  - The mode carries over between styles. Default → Clear gave ClearLight. Tinted+Auto → Dark gave RegularAutomatic
    (Auto stayed selected).
- Tint colour (only with Tinted):
  - The row label becomes "Icon, widget & folder colour".
  - It is a pop-up menu: Automatic | Red, Orange, Yellow, Green, Blue, Purple, Pink, Graphite (each with a colour dot) | Choose Colour….
  - The pop-up width follows the text: 133 for Automatic, 95 for Red, 171 for Choose Colour….
- "Choose Colour…" opens a popover (310x178) with:
  - A Hue slider: a 264x28 rainbow capsule.
  - An opacity slider: 264x28, from transparent to the colour.
  - Both knobs are about 24 pt circles filled with the colour, with a light ring.
  - Two 264x24 buttons: "Colour Picker" (eyedropper) and "Use Theme Colour".
  - In dark mode the popover was 290 wide inside, and the two buttons were side by side (141 each).
- Keys written (`defaults read -g` diff):

  | action | AppleIconAppearanceTheme | tint keys |
  |---|---|---|
  | Default | key removed | |
  | Clear | ClearLight | |
  | Tinted | TintedLight | |
  | Auto radio | TintedAutomatic | |
  | Always | RegularDark | |
  | pick Red | | `AppleIconAppearanceTintColor = Red` (string) |
  | Hue +0.1 in the popover | | `AppleIconAppearanceTintColor = Other` and `AppleIconAppearanceCustomTintColor = "0.978757 0.638603 0.222359 1.000000"` (sRGB r g b a string) |
  | opacity −0.075 | | the 4th number becomes 0.925000 |
  | Use Theme Colour | | both tint keys removed (back to Automatic) |

- Restored: Dark + Always = RegularDark. No tint keys are left; `defaults read -g` is identical to before.
- Caveat: synthetic mouse clicks inside the colour popover broke event delivery to the Appearance extension until
  System Settings was relaunched. The popover was then driven through AX instead (AXPress, AXIncrement).
- Pictures: `iconstyle-*.png`.

## 4. Switches
- Size (probe and Settings agree with Q-16):

  | size | track | knob | knob x off → on | travel |
  |---|---|---|---|---|
  | regular | 54x24 r12 | 32x20 | 2 → 20 | 18 |
  | small | 44x20 | 26x16 | | |
  | mini | 36x16 r8 | 21x13 | 1.5 → 13.5 inside the track | 12 |

  Settings' "Tint window background" switch is mini: the knob measures 20.5x12.5 white pixels.
- Colours (probe pixels; Multicolour = blue accent):

  | | off track | on track | knob |
  |---|---|---|---|
  | light | #E5E5E5 | #3374EF | #FFFFFF |
  | dark (on #272726) | #3C3C3B | #397AF6 | #FFFFFF |

  The real Settings switch: on #3374EF light, #397AF6 dark.
- Layers: track = accent + accent a.75 + white/black a.098. Off = white a.098 (dark) / black a.098 (light).
- Knob travel (240 Hz sampler, which gets one value per display frame; data in `probe-switch-knob-series-dark.json`):
  - Movement starts 1–2 frames (17–35 ms) after the state flips on mouse-up.
  - From the start of movement: 10 % at about 33 ms, 50 % at about 100 ms, 90 % at about 183 ms. It reaches the
    target at about 233 ms and peaks at +4.2 % (+0.75 pt regular, +0.5 pt mini) at about 330 ms. Within 1 % by about
    430 ms.
  - **Shape: an underdamped spring from rest.** Fit: ζ 0.72, ω 13.75 rad/s (mass 1, stiffness ≈ 189, damping ≈ 19.8;
    SwiftUI-style response ≈ 0.46 s, dampingFraction ≈ 0.72). rms 0.003.
  - An ease-in-out fit is clearly worse (rms 0.02, 0.28 s).
  - Regular and mini have the identical normalised curve. Both directions are the same.
- Press-and-hold (down, 700–800 ms, up):
  - The knob grows centred: regular 32x20 → 50x31, mini 21x13 → 33x20 (×1.56).
  - At the same time the white knob cross-fades into a glass lens (SDF layer opacity = growth progress).
  - Growth starts on the mouse-down frame and matches **CAMediaTimingFunction easeInEaseOut (0.42,0,0.58,1), 0.20 s**
    exactly (rms 0.0002). Per frame: 0.014, 0.056, 0.129, 0.232, 0.359, 0.5, 0.641, …, 1.
  - The knob does not move while held.
  - On release it travels with the spring above while shrinking back to 32x20 over about 0.27 s; the glass fades out
    with it.
  - A quick click (down and up in the same instant) grows the knob only to about 33 wide.
- Track colour:
  - On→off: the accent layers' alpha falls from 1 to 0.1 over about 0.25 s from release, ease-out-like.
  - Off→on: about 0.23 s (0.455 → 0.689 s in the sample).
- Real Settings switch (Tint window background, 60 fps clip, toggled off and back on; no defaults diff remained):
  - Same behaviour: the knob turns glass while pressed. A click moves it 12 pt in about 0.18 s with a ~0.5 pt
    overshoot, settled by about 0.37 s.
  - The track cross-fades in about 0.17–0.2 s.
  - Hold: the white knob disappears into glass in about 0.2 s.
- Raw videos deleted. Probe source: `reference/re/tools/probe/switches.swift`. Data:
  `re/27.2.1/live/settings/appearance/probe-switch-*.json*`.

## 5. Scrolling
- The pane title "Appearance" is the toolbar title. It does not scroll; there is no large title in the content.
- Scroll edge:
  - At offset 0 there is no line.
  - From the first scrolled frame, a 0.5 pt (1 px) hairline sits at y 52: light #E5E5E5 on white, dark #2E2F33 on #1E1F24.
  - Content under the 52 pt toolbar strip is faded and blurred into the window background. At offset 250 the strip
    is #E7E8E9 light / #26282D dark over the photo (cf. Q-settings-04).
- Scroll bar:
  - Overlay style ("Automatically" with a trackpad). No track, only the knob.
  - Knob 6 pt wide at x 731–737 (3 pt from the window's right edge), from y 55 (3 pt below the toolbar) to 622.
    Length 325.5 at this content size (573 / 1036.5 of the track); ends rounded r 3.
  - Colour: light #808080 (black a.5), dark #8F9192 (white about a.5).
  - It appears on the first scroll frame and stays about 0.6 s after the last scroll event, then fades out over
    about 0.15 s (9 frames). 60 fps clip, two scrolls.


## Notification Center glass and transitions (PC #62)

# Notification Center: glass, open/close, banners, stacks (macOS 27.2.1, live)

## Setup
- **Account:** the user's own (icon & widget style Dark, glass slider 0.5).
- **Backdrops:** a full-screen solid window from the new probe `re/tools/probe/ncbg.swift`.
  - It sits at level -2147483600, above the desktop icons and the desktop widgets (-2147483601) and below NC (layer 23).
  - A solid wallpaper of the same colour was set under it. The wallpaper was restored afterwards.
  - Colours: white 255, grey 127, black 0, blue sRGB (69,83,206). The blue reads as (72,83,199) in display RGB, the
    same way the screen shows the blue wallpaper itself.
  - There is also a "checker N" mode (black/white checkerboard) for testing blur.
- **Values:** display RGB from 2x `screencapture`, 3x3 px medians. Single numbers mean R = G = B.
- **Notifications:** test notifications came from `osascript display notification` (app "Script Editor", grouped).
  The user's real notifications were never dismissed and never saved. In the PNGs they are blanked out; the numbers
  come only from the test stack, the widgets and the empty areas.
- **Recordings:** 60 fps avfoundation, deleted after analysis.
- **A change on the Mac that matters:** banners do not show while the screen is being recorded. The setting
  Notifications > "when mirroring or sharing the display" was switched to Allow for (3), then set back to
  "Notifications Off".

## (1) Glass

### 1a. Notification card (front card of a stack, and a single card)
- **Geometry:**
  - x 1350..1694 (**344 wide**). The top section starts at y 44 (10 below the menu bar).
  - Gap between cards **6**. Single cards (banner style) are 75 tall with title + subtitle + body.
  - Corner: the curve leaves the straight edge about 11 pt from the corner (profile 17, 11.5, 8.5, 7, 5.5, 4.5, 3.5,
    2.5, 1.5, 1, 0.5, 0 at dy 0..11). That fits the continuous r ≈ 18–20 found before.
- **Interior** (it hardly changes from top to bottom: 126 → 129 over white):

| backdrop | dark | light |
|---|---|---|
| white 255 | **128** | **237** |
| grey 127 | **104** | **190** |
| black 0 | **32** | **136** |
| blue | **(71,80,184)** | **(161,169,255)** |

  - The response is **not linear**. Dark gives 32 → 104 → 128, so most of the change comes in the lower half of
    the backdrop range. Light gives 136 → 190 → 237.
  - Over the checker the card blurs heavily: the 10–90 % edge is about 16 pt wide (Gaussian σ ≈ 6 pt). The 0/255
    checker comes out as only 68..116 in dark, so the backdrop contrast drops to about 19 % (strong tone compression).
- **Rim:**
  - **Top and bottom only:** a bright 1 pt line (2 px). Values below are outer px → inner px → body:

| backdrop | dark | light |
|---|---|---|
| black | 68 → 53 → 35 | 161 → 151 → 137 |
| grey | 132 → 120 → 105 | 210 → 201 → 191 |
| white | 154 → 143 → 129 | 252 → 245 → 237, plus a 255 px just outside the card |
| blue | (147) → (132) → (114) | — |

  - **Vertical sides:** no bright rim. Instead the outermost 0.5 pt is darker than both the card and the backdrop:
    70 over white, 44 over grey, 43 over blue, dark mode. The rim depends on angle, like the Dock.
- **Stack plates** (collapsed group), measured on the white backdrop:
  - plate 1 is **8 pt** high and inset **17 pt** each side (306 wide); plate 2 is **8 pt** and inset **24 pt** (292).
  - Fill, dark: plate 1 129 / 88 / 15 / (55,63,152) over white / grey / black / blue; plate 2 130 / 86 / 14.
  - Fill, light: plate 1 204 / 155 / 102; plate 2 199 / 148 / 94.
  - So the plates are a darker, less opaque version of the card glass.
  - Each plate has a bright 1 px top line (over black: 22 dark, 112 light).

### 1b. Widgets
- **Geometry:**
  - **164 × 164**, gap 16, x 1350..1514 and 1530..1694.
  - Corner: the curve leaves the edge about 27–30 pt from the corner, so continuous r ≈ 22–24.
- **The widgets do not depend on light or dark appearance** (identical pixels). They follow the "Dark" icon & widget
  style.
- **Calendar widget:** opaque, (32,31,31) at the top to 13 at the bottom, the same over every backdrop.
- **Batteries widget (translucent):**
  - 65 / 39 / 13 / (20,27,103) over white / grey / black / blue, which is **13 + 0.204·in**, linear.
  - That makes it a dark tint at about 80 % over the blurred backdrop.

### 1c. "Edit Widgets" capsule and the small circle buttons
- **"Edit Widgets":** 24 tall (capsule, r 12), about 81–87 wide, centred, near y 1010.
  - Dark: 179 / 128 / 31 / (85,97,226). Light: 246 / 190 / 131 / (157,167,255).
  - Over grey and black it is close to the card fill. Over white it is brighter than a card (179 vs 128 in dark).
- **x circle next to it:** 24 tall, the same glass (178 / 128 / 32 dark).
- **Section "Clear All" circle** (28 pt, at x 1675..1693 next to the "Notification Centre" header):
  - Dark: 167 / 116 / 32 / (79,89,200). Light: 231 / 184 / 135.
- **"N more notifications" capsule:**
  - Dark: 163 / 112 / 31. Light: 224 / 178 / 129 / (151,158,244).

### 1d. Section header, "No Notifications", and the column backdrop
- **Section header** "Notification Centre": white text with a soft shadow, sitting on the column backdrop (no glass
  of its own).
- **"No Notifications" / date header: not measured.** It only shows when NC is empty, and that would mean clearing
  the user's real notifications.
- **Is there a backdrop behind the cards? Yes, and it covers only the column.**
  - **Blur.** Over a 40 pt checker, the area between the cards and behind the section header is blurred: the 10–90 %
    edge is 7.5 pt, so Gaussian σ ≈ 3 pt (≈ 6 px). The blur region is the column rect (x ≈ 1350..1694) and feathers
    out over about 5–10 pt at its edges. Outside it the checker stays sharp, even 4 pt from the cards.
    `dark-checker40-top.png` shows it.
  - **Darkening.** It multiplies the backdrop and is the same in light and dark appearance:
    - **×0.71** in the 6 pt gaps between cards (white → 181 dark / 189 light; grey → 91; blue → (52,59,142); black
      stays 0);
    - ×0.78 behind the section header row (200);
    - ×0.80 in the 16 pt gap between the widgets (204);
    - ×0.82 right of the column (x 1702).
  - **The darkening is a soft shadow, not a scrim.** Going left from a card edge over white: 200 at 4 pt, 207 at 8,
    214 at 12, 224 at 20, 235 at 30, 248 at 50, 255 at about 80 pt. Below the last widget it fades to 255 over about
    85 pt; 20 pt below "Edit Widgets" it is back to 255. Above the first card (y 35–43) it is 0.82–0.85.
  - With NC closed, the screen is the plain backdrop. The far wallpaper never changes with NC open.
  - Static RE agrees: NotificationCenter.app has `NotificationBackdropLayer` (a CABackdropLayer subclass),
    `NotificationCenterApp/NotificationCenterBlurView.swift`, `BlurMask`, `toggleBlurDebug`, `wantsSubduedGlass`.
- **Shadow per card:** not separable from the column shadow. Every card, widget and capsule sits inside the same soft
  shadow field described above.

### 1e. Which _Glass variant or recipe
See "Static RE" at the end. In short: cards use `_Glass.notificationCenter` (Regular base, no inactive branch) with r 20 continuous; the buttons use `_Glass.regular`; there is a column backdrop blur of 1.5·openProgress, masked, with no dim.

## (2) Open/close transition (clock click; dark mode, grey backdrop, 7 cards + 2 widgets present)

### 2a. Trackpad swipe
**Not measured.** The two-finger swipe from the right edge is a WindowManager system gesture
(`NotificationCenterSystemGesture`) that runs on multitouch input. CGEvent cannot synthesise it: we have no
synthetic NSTouch / dock-swipe path that WindowManager accepts.
- From RE (already in MAC-ANSWERS): the panel follows the finger 1:1 and rubber-bands above 1.
- The release is completed by `FluidSpringAnimator`.

### 2b. Open
- **Timing:**
  - The NC window (layer 23, full screen) is on screen **0.24 s after the synthetic click** (`winpoll` probe, 4 ms
    polling).
  - Motion starts in the first frame the window is visible.
- **Curve:** x offset per frame, starting at +339 pt:
  339, 293.5, 245, 199, 159.5, 125, 97.5, 75.5, 57.5, 44, 33.5, (frame dropped), 14.5, 11, 8, 5.5, 4.5, 3.5, 2.5, 2,
  1.5, 1, 1, 0.5, 0.5, 0.
  - **Best fit: a spring from rest, response 0.30 s, damping ratio 1.0 (critically damped), travel W = 386 pt, RMS
    0.74 pt.**
  - The code's Spring(0.3, bounce −0.2) = ratio 1.25 fits at 12.5 pt RMS.
  - Read this as: response 0.3, **critical** damping, from x + ~386.
- **All elements move together.**
  - Card, section header, the other cards, Calendar and Batteries keep constant x offsets to each other in every
    frame (header − card = 59.0 pt, calendar − card = −2.5 pt in all frames).
  - No stagger and no parallax.
- **No panel alpha, scale or blur.**
  - The card glass fill is final (92–93 in video units) from the first measurable frame.
  - Card text is full brightness from the first frame. Row spacing is constant, so there is no scale.
  - The glass does **not** materialise late.
- **Exception: the Calendar widget's content fades in.**
  - The digits fade while the widget body is opaque from frame 1.
  - Alpha against time since motion start: 0.27 @0.045 s, 0.44 @0.078, 0.63 @0.111, 0.77 @0.145, 0.87 @0.178,
    0.95 @0.228, 0.98 @0.295. That tracks the open spring (openProgress).
  - The Batteries widget text is full from the start. So this is per widget (probably widget content becoming
    visible), not a panel effect.
  - See `open-click-strip-widgets.png`.
- **The column blur and shadow ride with the panel.** At a fixed point (x 1520) the gap pixel goes 115 → 111 → 92 →
  87 … → 79 (video units) as the panel passes; it does not fade in separately.
- **The rest of the desktop does not change:** no dim and no blur outside the column.

### 2c. Close (second click on the clock)
- **Timing:** motion starts about 0.08 s after the click.
- **Curve:** offset per frame: 0, 7, 38, 83, 131.5, 178, 216.5, 250, 278.5, 300.5, 317.5, 332, 342.5, 350.5, 357,
  then off screen.
  - **Fit: a spring from rest, response 0.28–0.31 s, ratio 1.0–1.1, W ≈ 380–385 pt (RMS 1.2–1.3 pt).** It is the
    same spring as the open, in reverse.
  - It **decelerates** at the end. The older "accelerating ~0.15 s" in MAC-ANSWERS came from pixel-change share and
    is wrong: the content leaves the screen after about 0.23 s while the spring is still running.
- **Window lifetime:** the window is ordered out 0.375 s after motion start (0.457 s after the click), when the spring
  is at about 99.7 %.
- No alpha change, no stagger, no blur. Widget content does not fade out on close.

## (3) Banners and in-NC changes

### 3a. Banner arrives (NC closed)
- **Final frame:** x 1350..1694, top at y 44, the same column and size as an NC card.
- **Entry:** it slides in from the right, starting partly off screen (first visible frame at +276 pt).
  - Card-left offsets: 276, 220.5, 178.5, (dup), 138, 111.5, 83.5, 64.5, 48.5, 37, 28, 21, (–), 12, 9, … 2.5 @+18
    frames, 0.5 @+22.
  - That is an ease-out of about 0.35 s. Spring fit: response ≈ 0.43, ratio ≈ 0.9 (RMS 5 pt; the start is off
    screen).
- **Fade and blur during entry:**
  - Content and glass fade in: darkest px 101 → 13 over about 15 frames.
  - The content is blurred at first and sharpens: max gradient 5 → 142 over about 0.25 s.
  - The icon is about 0.85× size in the first sharp frames, then 1.0. So there is a small scale-up as well, about
    0.85 → 1.
- **Duration:** the banner stays **4.97 s**, then auto-dismisses.

### 3b. Banner auto-dismiss ("into NC")
- **Motion:** it slides back to the right. Offsets 0, 10, 51, 104, 148, 192, 230.5, 260.5, 297.5, 319.5.
  - Fit: spring response 0.31, ratio 1.25 (RMS 2.6 pt). That is the code's NC spring (Spring 0.3, bounce −0.2).
  - It fades and blurs out at the same time (darkest px 15 → 111) and is gone in about **0.15 s** (9 frames).
- **No flight into the NC panel:** it just leaves to the right edge.
- Strips: `banner-arrive-strip.png`, `banner-dismiss-strip.png`.

### 3c. New notification while NC is open
- **The list moves down 81 pt** (card 75 + gap 6).
  - Per frame: 5, 5, 13.5, 36.5, 44, 51, 57, 62.5, 67, 70, 72.5, 74.5, 76.5, 77.5, 78.5, 79, 79.5, 80, … 81.
  - About 0.35 s, ease-out.
- **The new card** shows about 0.08 s after the list starts moving, at its final place.
  - It fades in and unblurs: text 123 → 228 and sharpness 39 → 156 over about 0.25 s.
  - It does not slide.

### 3d. Expanding a stack (click the stack)
- **At the click:** the "Show less" capsule and the x circle appear instantly (1 frame). The group header (app name)
  fades in.
- **Front card:** moves down 44 pt (to make room for the header).
  - Per frame: 0, 5.5, 5.5, 20.5, 25, 29, 32, 35, 37, 39, 40, 41, 41, 42, 42.5, 43, 43, 43.5, 43.5, 43.5, 44.
  - Fit: **spring response ≈ 0.20, ratio 1.25** (RMS 0.35 pt); about 0.35 s to settle.
- **Hidden cards:** they unfold from the plates, sliding down from behind the front card and fading in. The cards
  below are pushed down by the same spring.
- **"Show" on the front card:** fades out in about 0.15 s.

### 3e. Collapsing ("Show less")
- **Header and buttons:** "Show less" and x vanish in 1 frame; the app-name header fades out in about 0.1 s.
- **Other cards:** they move up about 47 pt in 6 frames, slide under the front card (clipped) and fade (icon min lum
  16 → 58). They are gone after about 0.1 s.
- **Front card:** moves up 44 pt. Per frame: 0, 2, 6.5, 12, 16.5, 25.5, 27, 30.5, 33.5, 36, 38, 39.5, 40.5, 41.5,
  42, 42.5, 43, 43.5, 44 (about 0.3 s).
- **List below:** follows with the same spring, starting about 0.1 s later.

### 3f. Hover on a card
- **x circle:** about 20 pt, the card glass, centred on the card's top-left corner (≈ 1354, 248). It appears and
  disappears in **1 frame, with no fade**.
- **"Show" capsule:**
  - 64 × 22 pt at the card's bottom-right (x 1620..1684, y 285..307), glass.
  - It **crossfades with the time label** ("2m ago") over about 0.3 s, symmetric in and out.
  - In: 0.07, 0.13, 0.23, 0.32, 0.39, 0.48, 0.57, 0.64, 0.69, 0.74, 0.78, 0.82, 0.86, 0.90, 0.92, 0.95 per frame
    (50 % at 0.1 s, 95 % at 0.27 s).
  - The crossfade starts 1 frame after the x shows.
- **Group:** hovering the x of a collapsed group widens it into a "Clear All" capsule.
- Pictures: `hover-off-on-dark-grey.png`.

### 3g. Clearing (x on my test group)
- **One click cleared the whole collapsed group.** It removed only the test notifications; the real ones were never
  touched.
- **The card blurs and fades in place in about 0.07 s** (4–5 frames). It does not slide.
- **The list below moves up 97 pt.** Remaining offset per frame: 97, 95.5, 71.5, 63, 51, 41, 33, 25.5, 19.5, 15,
  11.5, 9, 6.5, 6.5, 5.5, 3, 2, 1.5, … 0 (about 0.4 s).
  - Fit: spring response ≈ 0.22, ratio 1.25 (RMS 1.9 pt).
  - That is the same list-reflow spring as expand/collapse: **response ≈ 0.2, ratio 1.25**.
- **Not measured:** swiping a card away (it needs a trackpad gesture) and the clear-all confirm on the section header
  (it would clear real notifications).

## Static RE (glass variant)
Done by a separate static agent: NotificationCenter arm64e plus the DesignLibrary dump. Excerpts are in
`re/27.2.1/decomp/NotificationCenter-glass.c`.

### Cards (single and stacked; high confidence)
- `NotificationBackgroundModifier` (FUN_100119fe8 / FUN_10011a374):
  `_glassEffect(_Glass.notificationCenter.forceSubdued(isObscured).mix(with: .identity, by: 1-p).surfaceSize(.medium), in: RoundedRectangle(cornerRadius: 20, style: .continuous))`.
  - p = 1 unless Reduce Motion is on, so with normal settings the glass is never mixed out.
- `NotificationCenterRecipe` = RegularBase + RegularDiffusionAmount + ShadowVibrancy (shadow.vibrancyContribution 1),
  plus the accessibility conditionals.
  - It has no WindowActiveShadow and no Inactive branch, so `forceSubdued` probably does nothing to the material.
  - The numeric RegularBase values were not decoded.
- The stack plates are probably the same modifier with isObscured = true (inferred).

### Widgets (medium confidence)
- NC applies no glass to widgets. It only passes `CHSGlassOptions withSubduedGlass` to the widget renderer
  (FUN_1001560a4).
- The recipe is not determinable: it runs in the widget renderer, outside NC; no `_Glass` imports in WidgetKit,
  ChronoKit or ChronoUIServices. That fits the measurement that widgets ignore light/dark.

### Buttons (`NotificationButtonStyle`; high confidence)
- **Common style:** a fill of `.quaternary` while pressed, then `_glassEffect(glass, RoundedRectangle(r, .continuous))`
  and `glassEffectTransition(.identity)`.
- **Per button:**

| Button | Height | Radius | Padding | Glass |
|---|---|---|---|---|
| Card hover x | 20 or 24 | h/2 | — | `.notificationCenter.forceSubdued(true)` |
| "Show less" | 20 | 10 | 10 | `.regular` |
| Group Clear / x | 20 | 10 | — | `.regular` |
| "Edit Widgets" | 24 | 12 | 10 | `.regular` |
| Clear All circle | 24 × 24 | — | — | `.regular` |

- **"N more notifications":** `Material._glass(.regular)` background, height 24, padding 10.
- **Conflict with earlier values:** MAC-ANSWERS Q-panels-32 gives 28 for "Show less" and "Clear", from AX frames that
  probably include the hit area. The code says 20 for these two and 24 for the Clear All circle.

### Column backdrop (`NotificationCenterBackground`, FUN_100139bbc)
- **Frame:** width 376, horizontal padding 16.
- **Layer:** `NotificationBackdropLayer`, padding −40, with one variable blur.
  - inputRadius = **1.5 × openProgress**, or 0 with Reduce Transparency; `normalizeEdges` on.
  - Mask: a black sublayer inset 60, corner radius 40, itself Gaussian-blurred with radius 20.
  - **No dim, tint or colour matrix.**
- So the column blur ramps with openProgress during open and close. That is consistent with what was seen (it arrives
  with the panel). The measured σ ≈ 3 pt against radius 1.5 is a difference in units or behaviour that was not
  resolved.
- **Outside shadow** (`NotificationsListShadowBackground`):
  - RoundedRectangle(20, continuous), black shadow at opacity 0.2 × progress, radius 30, no offset.
  - This matches the soft fade of about 70–80 pt that was measured.

### Not resolved
- The ×0.71 / ×0.78 darkening between cards is not in the backdrop layer. It is probably overlapping card and list
  shadows (radius 30, opacity 0.2 each).


## NC panel spring: why code 1.25 runs as critically damped

# NC panel spring: code says ratio 1.25, screen shows 1.0 (macOS 27.2.1, 26B131, arm64e)

Tools: REA (Ghidra 12.1.4 provider) on the NotificationCenter arm64e slice and on raw dumps of SwiftUICore code from
the dyld shared cache; `dyld_info -disassemble` for asm. SwiftUICore addresses are unslid cache addresses
(0x190404000 + export offset). Excerpts: `~/hyprk/reference/re/27.2.1/decomp/NotificationCenter-spring.c`.

**Answer: hypothesis 1 is right. The 1.25 is real in NotificationCenter, but SwiftUI's `interpolatingSpring` solver
treats every damping ratio >= 1 as critically damped. Effective panel curve: ratio 1.0, response 0.30 s.**

1. **Call site (unchanged from the earlier RE, now confirmed with REA).**
   - `FUN_1001910a4` (swift_once init of `DAT_1003c1388`) calls `FUN_1001910d8(0.3 @0x1002dbd50, -0.2 @0x1002dbd58, 0)`.
   - `FUN_1001910d8` is the inlined `Spring(duration:bounce:)` conversion and tail-calls
     `SwiftUI.Animation.interpolatingSpring(mass:stiffness:damping:initialVelocity:)` (stub 0x1002be604):
     - stiffness k = (2π/0.3)² = 438.649, ratio = 1/(1+bounce) = 1.25, damping c = 2·√k·1.25 = 52.360, mass 1, v0 0.
   - Check: c / (2·√(m·k)) = 52.36 / 41.89 = 1.25. So the earlier decoding was correct, not a unit mix-up.
   - Open and close both use it: `FUN_1001e19c4` = `withAnimation(DAT_1003c1388, completionCriteria: .logicallyComplete)`.

2. **Where 1.25 becomes 1.0: SwiftUICore `SpringAnimation.animate(value:time:context:)` 0x190d236ec**
   (Double path 0x190d234ac and AnimatablePair path 0x190d23240 build the same model).
   ```
   w0   = sqrt(stiffness/mass)                 // 20.944 rad/s
   zeta = damping / (2*sqrt(mass*stiffness))   // 1.25
   if (1.0 <= zeta) { B = w0 - v0; wd = 0 }    // critical form for ALL zeta >= 1
   else             { wd = w0*sqrt(1-zeta^2); B = (w0*zeta - v0)/wd }
   A = 1
   ```
   `SpringModel.sample(at:)` 0x190d23e28:
   ```
   zeta >= 1:  x(t) = 1 - (A + B*t) * exp(-w0*t)          // zeta is not used at all
   zeta <  1:  x(t) = 1 - exp(-zeta*w0*t) * (A*cos(wd*t) + B*sin(wd*t))
   ```
   - There is no overdamped (two-exponential) branch. The damping value above critical is simply dropped.
   - Panel: x(t) = 1 − (1 + 20.944·t)·e^(−20.944·t), i.e. **response 0.30 s, ratio 1.0**. Offset = W·(1 − x) on open,
     W·x on close.
   - End of animation: `SpringModel.duration(epsilon:)` 0x190d23bf0 scans t in 0.1 s steps for |1 − x| < 0.001
     (epsilon 0.001 when no timing curve) -> **0.5 s**; after that the value snaps to the target (0.12 pt left).
   - `.logicallyComplete` flag: set when `time >= 2π/sqrt(stiffness)` = **0.300 s** (context+0x19 = 1).

3. **Why banners and list reflow do keep 1.25: a different SwiftUI API.**
   - `DAT_1003c13b8` (init at 0x100190fe0): `Animation.spring(response: 0.3, dampingFraction: 1.25, blendDuration: 0)`
     (stub 0x1002be624). Only this initialiser was re-checked; the other springs listed in the earlier notes
     (0.35/1.25, 0.2/1) were not re-traced to their API.
   - SwiftUICore 0x190edef7c boxes a `FluidSpringAnimation {response, dampingFraction, blendDuration}`.
   - `FluidSpringAnimation.animate` (Double specialisation 0x190c23768) integrates numerically, no clamp:
     ```
     k = (2π/response)^2 (max 45000);  c = 2*sqrt(k)*dampingFraction
     h = 1/300 s:  v += a*h/2;  x += v*h;  a = -c*v + k*(target - x);  v += a*h/2
     ```
     So ratio 1.25 stays overdamped there. This matches the live fits (banner dismiss, stack expand, clear group).
   - Rule for the theme: `interpolatingSpring(mass:stiffness:damping:)` -> ratio = min(ratio, 1), response from
     stiffness; `spring(response:dampingFraction:)` -> ratio as written.

4. **Hypothesis 2 (another animation on the click path): not supported.** The only curve reaching the click open/close
   closures is `DAT_1003c1388`. `FluidSpringAnimator` (60 Hz, own integrator) is only started from the gesture-release
   paths `FUN_1001781b4` / `FUN_1001773d0(animated: true)`. A Reduce Motion branch inside `OpenSlideModifier` was not
   traced (not determined), but it is not needed to explain the data.

5. **Hypothesis 3 (cannot tell 1.25 from 1.0 at 60 fps): rejected.** Fit to `click-open-close-track.jsonl`
   (testTitle x, rest 1352.5, duplicate frame i=81 dropped; t0 and W free unless noted):

   | segment | model | response | W | RMS pt | max pt |
   |---|---|---|---|---|---|
   | open (41 fr) | ratio 1.0, response free | 0.296 | 374.7 | 0.68 | 4.0 |
   | open | ratio 1.0, response 0.30 fixed (= SwiftUI curve) | 0.30 | 381.9 | 0.75 | 4.4 |
   | open | ratio 1.25, response free | 0.211 | 340.0 | 1.89 | 7.2 |
   | open | ratio 1.25, response 0.30 fixed | 0.30 | 520 (bound) | 11.9 | 26.2 |
   | open | ratio free, response free | 0.298 | 376.0 | 0.68 | 3.9 (ratio 0.997) |
   | close (16 fr) | ratio 1.0, response free | 0.299 | 375.9 | 0.51 | 1.2 |
   | close | ratio 1.0, response 0.30 fixed | 0.30 | 376.2 | 0.52 | 1.2 |
   | close | ratio 1.25, response free | 0.257 | 395.2 | 2.09 | 4.6 |
   | close | ratio 1.25, response 0.30 fixed | 0.30 | 418.1 | 4.63 | 9.5 |
   | close | ratio free, response free | 0.302 | 374.6 | 0.50 | 1.3 (ratio 0.987) |

   - The two curves (response 0.3, W 386) differ by up to 37.7 pt (at t = 0.15 s) and by more than 5 pt from 0.033 s
     to 0.43 s. At 60 fps with 0.5 pt resolution that is easy to tell apart.
   - With the ratio left free the data gives 0.99–1.00. The best W is 375–382 pt, slightly under the 386 in motion.json.
   - calLeft gives the same numbers (ratio 1.0: response 0.295, RMS 0.66; ratio 1.25 at 0.30: RMS 12.0).

6. **0.24 s between click and window on screen: not determined.** What the code shows:
   - `MainController` open `FUN_100176de0`: prepare model (`FUN_1001d3768`: isAnimating = 1, signpost begin) ->
     `makeKeyAndOrderFront:` -> `DispatchQueue.main.async` (`FUN_1001d39d8` -> `FUN_1001fbb08` -> `FUN_1001e18b0`) ->
     `withAnimation`. Only a plain `async` hop; no `asyncAfter`, no timer, no wait for widget snapshots in this path.
   - NotificationCenter has three `asyncAfter` sites (0x1001926a0: 0.2 s in the widget-configuration function
     0x1001911fc; 0x1001956a4; 0x10029fea0 in a generic helper 0x10029fbe4). None is called from the open path.
   - So the delay comes from before "Center open requested" reaches NotificationCenter (the menu bar clock's click
     handling and the request to NC) and/or from first-frame rendering. Neither was traced.

7. **Close timing.**
   - 0.08 s click -> motion: same situation as (6); the close path `FUN_100178444(0)` -> `FUN_1001d3ebc` has no delay.
   - Window gone 0.375 s after motion start: the completion uses `.logicallyComplete`, which this spring raises at
     t >= 0.300 s (item 2), not at the 0.5 s end. The remaining ~0.07 s (frame alignment, completion dispatch,
     order-out, capture) was not traced: not determined.

**For hyprk:** NC panel open/close = critically damped spring, ω0 = 2π/0.3 = 20.944 rad/s (mass 1, stiffness 438.65,
damping 41.89), x(t) = 1 − (1 + ω0·t)·e^(−ω0·t), x only; close hides the window about 0.30–0.375 s after start.


## Verification of motion and glass claims (PC #67)

### A. Bounce and springs

# Verify A (motion formulas), macOS 27.2.1 (26B131)

1. Dock launch bounce — TERKONFIRMASI (height formula corrected) — pure parabola `h = H·4u(1−u)`, u = t/700 ms, drawn rounded to whole points; `H = (R−8)·0.2+6` where R is the tile RECT (35 at tilesize 33, 68 at tilesize 64 = AX tile width ≈ tilesize·17/16), not the tilesize: H = 11.4 (shows max 11) and 18.0 — code: Dock `-[Tile updateBouncing]` 0x10002d9f4 (period 350.0 = 0x43af0000 set at 0x10008e134, `1 − x²/P²` at 0x10002dbf8), `-[Tile updateRect]` 0x100012088 (6.0, 8.0, 0.2f @0x1002580c0); measured 60 fps, BounceProbe (7 bounces each): period 0.699–0.700 s; tile 33: best H 11.25–11.5, RMS 0.39 pt with R=35 (0.47 with R=33); tile 64: best H 17.85–18.2, RMS 0.47 pt with R=68 (0.78 with R=64).
2. Dock attention bounce — TERKONFIRMASI — 2.000 s cycle; parabolic hops 500 / 326 / 212 ms at 1 / 0.5 / 0.25 × (R+1), then rest to 2 s; R = tile rect, so 36/18/9 pt at tilesize 33 and 69/34/17 at 64 (whole points) — code: same function, constants 500.0/326.0/212.0 (0x43fa0000, 0x43a30000, 0x43540000 at 0x10002dc70..dca8; 4th hop 138 ms zeroed), period 2000.0 at 0x100091524, amplitude `rectH + 1` in updateRect; measured with DockProbe `requestUserAttention(.criticalRequest)` in background, 4 full cycles each: cycle 2.000 s, peaks exactly 36/18/9 and 69/34/17, ground at 0.50 and 1.03–1.05 s; RMS 0.84 pt (tile 33) and 0.63 pt (tile 64) vs code (1.2 / 1.75 pt if tilesize+1 were used).
3. Switch knob — TERKONFIRMASI, values corrected — API is SwiftUI, not Core Animation: `.animation(.spring(response: 0.47, dampingFraction: 0.7), value:)` (FluidSpringAnimation). Its 1/300 s integrator makes it behave like an exact spring with response 0.4624 s, ratio 0.7113; overshoot 4.16 % (0.75 pt of 18). The animation is cut after 27 frames (≈0.46 s): the knob snaps from 1.0176 to 1.0 — code: NSSwitch hosts `_NSCoreHostingView<AppKitSwitch>` (AppKit) → DesignLibrary Mac switch body fn 0x195E349C4, call at 0x195E34E78 (d0 = 0.47, d1 = 0.7; stub → SwiftUICore 0x190ee11b8); knob layer set per frame by SwiftUI DisplayList (stack trace), no CAAnimation on any layer; measured in-process at 240 Hz (27 frames, identical for on and off): RMS 0.0019 pt vs code curve, 0.043 pt vs the claimed 0.46/0.72. The old JSON series is the same curve (peak 36.75 of 18→36).
4. Spotlight open — TERKONFIRMASI, labels corrected — `CASpringAnimation(perceptualDuration: 0.28, bounce: b)`; 0.41 and 0.32 are BOUNCE, not damping: damping ratio 0.59 and 0.68, response 0.28 s (mass 1, stiffness 503.55, damping 26.48 / 30.52). Normal open of the empty bar uses the flag-off path: scale.x AND scale.y both 1.12 → 1 with bounce 0.32 (ratio 0.68). Flag-on path (not seen live): x 1.12 → 1 bounce 0.41, y 0.95 → 1 bounce 0.32 — code: SpotlightUIInternal FUN_2adea2ff0 (fcsel at 0x2ADEA305C, y-from select at 0x2ADEA3184..94), caller 0x2ADE99894 (d0 1.12, d1 0.95, d2 0, w0 = Bool from vtable +0x460, not identified); measured 3 opens at 60 fps (bar width via edges): free fit response 0.289–0.291 s, bounce 0.315–0.317; RMS 0.22–0.30 pt (of 487) vs code 0.28/0.32, 1.44–1.54 pt vs 0.28/0.41; undershoot to 0.994; height fits 1.12 start (RMS 0.31–0.38 pt) not 0.95 (1.4–2.3 pt).
5. HUD appear — TERKONFIRMASI — `Animation.interpolatingSpring(mass: 2, stiffness: 300, damping: 50)`; SwiftUI clamps ratio 1.0206 → 1.0, so effective: critically damped, ω = √150 = 12.247 rad/s, response 0.513 s; `p = 1 − (1+ωt)e^(−ωt)`, scale 0.9 + 0.1p, opacity p — code: SystemBannerUI 0x2AED436A4 (d0 2.0, d1 [0x2aed89048] = 300.0, d2 50.0; stub 0x2b00a1c10 → SwiftUICore 0x190d2440c interpolatingSpring), clamp `fcmp zeta, 1.0; b.pl` at SwiftUICore 0x190D23500; measured 4 appears (volume keys, 60 fps, capsule height): free-fit ω 12.27 / 12.88 / 12.29 / 13.26 (response 0.47–0.51 s), RMS 0.08–0.15 pt (of 66) with code ω; glyph alpha follows p (RMS 0.020–0.025).

Notes
- Dock: the offset is applied in whole points, which is the "flat top" seen earlier (11.4 → 11 for about 0.19 s). Launch ends at the next ground touch (7 whole bounces seen). Theme: use R = tile rect (tile·17/16), round to integer px of the logical scale.
- Switch: other DesignLibrary spring site 0x195DF57F0 `spring(response: flag ? 0.23 : 0.46, dampingFraction: 0.75)` is a different view (Binding<Bool>), it does not fit the knob (RMS 0.26 pt). Same body also has `.animation(.easeInOut(duration: 0.2), value: InteractionState)` (press state). Ratio 0.72/response 0.46 in the claim was a fit of this curve; use 0.47/0.7 with the SwiftUI integrator, or 0.4624/0.7113 analytic, plus the cut at 0.46 s.
- Spotlight: the window alpha fades in at the same time (first visible frame is already at about 1.06–1.09×). Which state sets the flag is not traced.
- HUD: ratio 1.0 vs 1.0206 differ by at most 0.009 in p (0.06 pt): not measurable, the code decides. Hide and content-swap springs were not re-measured.
- lldb cannot attach here; API attribution used stub resolution in memory + in-process swizzled stack traces.
- Restored: Dock tilesize 33 (export/import), volume 31, hidden apps shown again, Dark mode on, test apps quit, videos and disassembly dumps deleted.

Files
- Data: ~/hyprk/reference/re/27.2.1/live/verify/A/ (dock-launch-t33/t64.json, dock-attention-t33/t64.json, switch-fit.json, switch-knob-240hz.jsonl, spotlight-open-fit.json, spotlight-open-track.json, hud-appear-fit.json, scripts/)
- Asm: ~/hyprk/reference/re/27.2.1/decomp/DesignLibrary-switch-spring.asm, SpotlightUIInternal-open-springs.asm, SystemBannerUI-hud-spring.asm
- Probe: ~/hyprk/reference/re/tools/probe/switchanim.swift
- PNG: ~/hyprk/reference/screens/27.2.1/verify/A/spotlight-open-dark.png


### B. Glass reflection and refraction

# Verify B (Liquid Glass reflection / refraction), macOS 27.2.1 (26B131), 2x SDR display

1. Rim model — TERKONFIRMASI, layout corrected — two separate effects, both in display-encoded values. (a) Dark specular = the glassBackground filter's KeyFillHighlight inputs: a 0.5 pt (1 px) line just OUTSIDE the edge, on the LEFT and RIGHT (angle π/2 → dir = (sin a, −cos a)), tone curve `c' = c·(1 + bias·hl·(3 − 2c))`, bias −0.25 (CC −0.3), `hl = Σ±dir schlick(saturate((cosθ − cos s)/(1 − cos s)), 0.4)`, `schlick(v,a) = v/((1/a − 2)(1 − v) + 1)`. It darkens (white 255 → 192, grey 128 → 65), black stays black. (b) Key/fill highlight = CASDFKeyFillHighlightEffect layer: key at TOP (angle 0), fill at BOTTOM (π), `dst' = dst + m·(M·dst + b − dst)` with the layer's vibrantColorMatrix (regular: R row 1.1202 −0.1894 −0.019 | +0.1471; dock dark 1.094 −0.358 −0.036 | +0.25; clear/CC 1.319 −0.048 −0.005 | +0.2), `m = spec + diffuse`: spec height 1 pt with falloff `1 − 0.75·depth/1`, diffuse band 8 pt linear, spread ×0.65, amount 0.5×0.15 = 0.075; m reaches 1.53 in the first pixel. Spreads: dark specular 75° dark, light uses SpreadSDR 106° on SDR (96° only with HDR headroom), Dock 75° on SDR (120° HDR), inactive window 120°; key/fill spread 80° up to D 96 → 90° from D 191. — code: metallib `glass_background_sdf_all_lpf` (highlight block, uniforms 0x108–0x120), uber shader `sdf_diffuse_kf_highlight` / `vibrant_color_matrix_sover`; CPU `CA::OGL::GlassBackgroundFilter::render` 0x18debc054 (sincos 0x18debca60, `cosf(SDR + (Spread − SDR)·edr)` 0x18debca94–caa0, `1/amount` and −2.0 at 0x18debcd84–90). Measured: isolated dark specular pixel-exact (5 13 21 29 37 44 … = model; 133 140 149 … on white); real rim 65/192/179 = model 64/191/178.5; light top 235 vs 233.6 (106°) / 246.4 (96°); highlight on black 56 33 11 8 6 5 4 vs model 57 33 11.4 8.4 6.5 5.0 4.0; real Dock 50 / 156 136 118 vs model 50 / 156 135.5 117.
2. Edge refraction — TERKONFIRMASI, labels corrected — "0.36 D max 20 / −0.65 D min −60" are the CLEAR recipe's inner refraction HEIGHT and AMOUNT (not inner/outer). D = min(width, height) of the shape in pt; height and amount are pt. Profile `m = 1 − sqrt(1 − (1 − depth/H)²)`; inner: `src = p + n·A·m` (A < 0 = sample further inside, full A at the edge, 0 from depth H); outer: second sample `p + n·Ao·m(depth, Ho)` taken OUTSIDE the shape, mixed with `opacity·saturate((d + 1)/1)` → only the outermost 1 pt. Regular: H min(0.25D, 20), A max(−0.5D, −60), Ho max(0.2D, 16), Ao max(0.25D, 16), opacity 0.6, backdrop margin 0.35D. Clear: 0.36D≤20 / −0.65D≥−60, no outer. Dock variant: 0.08D / −0.18D, outer opacity 0.2 with amount 0. CC: min(0.225D, 25) / max(−2D, −80), outer 0.0357D / 0.0714D at 0.1525. — code: same shader (uniforms 0x10–0x24, 0xe0), amounts passed unscaled. Measured on a position-coded ramp (R = x, G = y): isolated inner, 240 pt circle, 98 960 px: median error 0.00 px, MAD 0.45 px, tangential 0.00; straight edges RMS 0.6 px; isolated outer exact to 1 px; real active recipes (11 shapes, colour terms off): median |error| 0.43 px.
3. Content lensing / chromatic aberration — TERKONFIRMASI for backdrops, SEBAGIAN for Spotlight content — no chromatic aberration in regular, clear, dock, CC, NC glass: no recipe sets inputAberration*, and |R − B| ≤ 2 levels over 6 px black/white stripes and 8 px checker across the whole glass including the rim. Spotlight field over 6 px stripes: no fringe (only the coloured caret). Aberration exists only in `glassForeground` (7 taps, R at +0.78·ab, B at −0.78·ab), used by `control` (switch knob) and `focusPlatter`. Not measured: the field's content lens on text (text sits > 28 pt from the edge; another process, layers not dumpable).
4. Light direction — TERKONFIRMASI — fixed in layer space: key top, fill bottom, dark lines left/right; no gyro, no pointer, no window-position term (the shader has only `key_fill_highlight_dir`). Measured: window at (40,60) vs (640,700): 0 px differ by > 1 level; pointer on rim/centre of plain glass and dock-variant glass: max diff 0; real Dock hover: only the label changes; Control Center hover: identical. Only interactive glass reacts: glass button hover = uniform +20 levels; press = grows ~1.5 pt per side plus a soft glow centred on the pointer (Gaussian σ ≈ 26 pt on a 140×32 button, peak ≈ +12 levels) that follows the drag. hyprk's pointer light on CC / Dock / menu bar has no counterpart on the Mac.
5. Switch / slider knob lens — switch TERKONFIRMASI, slider SEBAGIAN — switch held: lens 50×31 pt (knob 32×20, ×1.56), D = 31; stack dumped in-process: backdrop displacementMap +7.75 (0.25D) with profile height 31 (D), glassBackground inner 3.1 / −4.65 (0.1D / −0.15D), no blur, identity face, dark specular height 1 offset −1 bias −0.3, ring shadow 0.1; glassForeground aberration 1.632 pt at −15°. Measured field (track hidden, ramps): outward `7.75·m(depth, 31) − 4.65·m(depth, 3.1)`, RMS 0.26 pt (free fit 7.75 / 31.8, RMS 0.15 pt), tangential 0.02 pt: 4.5 pt at depth 2.5 → 1.1 pt at the axis, i.e. it MINIFIES to about 0.79× (wide-angle look), with fringes only at the rim (interior R = G = B). Slider held: 25×20 (×1.25), inner 3.6 / −6 (0.18D / −0.3D), displacement amount 5 with height 0, aberration 0, ring shadow 0.4; its measured interior (ramp slope 0.70 plus an offset) is not explained by the dumped stack.

Notes
- Inactive window (not key): different recipe: no outer refraction, no shadow, key/fill highlight off, dark specular all around (spread 120°, bias −0.1875), backdrop margin 0.5. A borderless probe window that cannot become key shows this by mistake.
- Real Dock (Dock process, not dumpable): rim and body colours match the dock matrix exactly, but its end-cap refraction fits regular geometry 0.25D / −0.5D (RMS 1.4–1.9 levels) and not the dock variant 0.08D / −0.18D (6.7–7.2). The top-edge refraction could not be separated from the highlight band.
- Backdrop is sampled from a reduced texture: scale 0.25 for regular at D ≥ ~128, 0.5 otherwise, 1 for the knob lens.
- A glass with every amount 0 is skipped entirely (identity); KeyFillHighlightAmount 0 disables the dark specular.
- Menu hover and CC top-rim numbers were not obtained (synthetic pointer did not highlight the probe's popup; sampled columns hit content).
- hyprk shader: `light_angle −50` and the white rim are wrong; use the two effects above. `aberration 1.5` should be 0 except on the pressed switch knob rim.
- Restored: Dark mode on, Dock untouched, Spotlight and Control Center closed, probe apps exited. One Spotlight capture that showed the terminal behind was deleted, nothing personal is in the repo.

Files
- Data: ~/hyprk/reference/re/27.2.1/live/verify/B/ (glass-model-fit.json, configs/, dumps/, scripts/)
- Code: ~/hyprk/reference/re/27.2.1/decomp/QuartzCore-glass-shaders.c (pseudo-code), QuartzCore-metallib-*.ll (raw IR), QuartzCore-GlassBackgroundFilter-render-excerpts.asm
- Tools: ~/hyprk/reference/re/tools/probe/glassfit.swift, tools/metallib_list.py, metallib_dis.py, air_pp.py
- PNG: ~/hyprk/reference/screens/27.2.1/verify/B/


### C. Liquid Glass slider and thickness

# Verify C: adjustable glass "thickness" (Liquid Glass slider), macOS 27.2.1 (26B131)

1. Slider → who reads it, which parameters, linear? — **TERKONFIRMASI** — `NSGlassTintAmount` (Float, unset = 0.5) is read by AppKit (`NSGlassEffectView.Legibility`, 0x18b3176b0) and passed to SwiftUI as `EnvironmentValues.glassDiffusion = .amount(a)` (0x18b328f44); Dock reads it itself (`-[DockGlassMaterialEnvironment tintAmount]` 0x100177F10); DesignLibrary turns it into recipe changes. It is piecewise linear in a with the knee at 0.5 (0.5 = unchanged recipe). It changes only: blur-fill opacities, face fill colour, dark maxLuma (a < 0.5, size > 64 pt), and for Clear-type glass the blur radius. Rim, refraction, saturation, face black/white, shadow do not change. — code `RegularDiffusionAmount` 0x195f22ea0, `ClearDiffusionAmount` 0x195efeb9c, `SidebarDiffusionAmount` 0x195f2cbac; live filter inputs at a = 0, 0.25, 0.5, 0.75, 1 equal the code formulas exactly (all digits), dark and light.
2. Per material — **TERKONFIRMASI** (Control Center real panel: SEBAGIAN) — Regular, Menu, Notification Center: same response (RegularDiffusionAmount). Sidebar: own variant. Clear, Dock, Control Center: blur only (ClearDiffusionAmount), so nothing changes over a flat colour. — recipe type strings 0x195fd4cf4 / 5602 / 5690 / 5b3c / 41b4 / 4ade / 493a; probe variants pixel + filter dump; real Dock relaunched at 0 / 0.507 / 1 over 4 pt stripes: stripe contrast 72 / 31 / 0.6, flat colours identical (177 / 109 / 17). **Correction of #53:** "the slider does not change the Dock / CC" was only true for flat backdrops. Real CC panel not re-measured over stripes (same recipe in the probe).
3. Measured fit — **TERKONFIRMASI** for elements ≤ 64 pt; **SEBAGIAN** for panels > 64 pt and for light-mode Regular highlights — face model below fits greys within 0.6 level (dark Regular, all 5 values), colours rms 2.0 (max 7); Clear / Dock / CC rms 0.5–1.4. Panels of 200 pt: rms 4 (edge-bleed layer not modelled). Light Regular: rms 2.5, max 7 (soft shoulder near white not modelled). — 17 backdrops × 5 values, `live/verify/C/ramp-transfer.json`, `ramp-fit-errors.json`.
4. Size dependence — **TERKONFIRMASI** — the recipe depends on the shortest side D only. Corner radius and width change nothing (160x64 r12 = r28 = 64x64 r32; 200x200 r28 = r100, all 60+ filter inputs identical). — code RegularBase.Base 0x195f20248 (ranges 64→104, 64→160, 4→24, cap −60); filter dumps at 24, 36, 64, 200, 500 pt plus the earlier 24…400 table.

Restored: `defaults read -g NSGlassTintAmount` = 0.5071146 (float), `defaults read -g` identical to before, Dock prefs identical, Dock relaunched at that value.

## How the value travels
- Settings calls `NSGlassEffectView.Legibility.setSystemLegibility` (0x18b31ee4c): writes the global default, then `SLSPostCoordinatedDistributedNotificationFenced(cid, 12, fence, block, 0.5 s)`. Apps listen for `kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName` (0x18b4c4d48) and re-post `NSGlassEffectDiffusionDidChangeNotification`.
- **`defaults write` alone does not reach running apps** (probe held 15 s: no change). A newly launched app reads it. I measured by relaunching the probe (and the Dock) per value.
- Legacy key `NSGlassDiffusionSetting` 0 / 1 = `.standard` / `.increased`; the slider removes it. Not set on this Mac.

## Formulas (a = slider 0…1; u = clamp(2a), t = clamp(2a − 1))
**Regular, Menu, Notification Center** (base at a = 0.5: blur fill radius 8, normal N₀ = 0.5, darken 0.9 dark / lighten 0.9 light; fill dark (0,0,0,0), light (1,1,1,0.2)):

| | a < 0.5 | a ≥ 0.5 |
|---|---|---|
| blur-fill normal opacity N | 0.5·u | 0.5 + 0.5·t |
| blur-fill darken (dark) / lighten (light) | 0.9·(0.75 + 0.25·u) | 0.9 |
| face fill, dark | none (alpha 0) | grey k = 0.125·t, alpha 0.5·t |
| face fill, light | white, alpha 0.2·u | white, alpha 0.2 + 0.3·t |
| maxLuma, dark | M₀(D)·u + lerp(0.6, 0.45, s)·(1 − u) | M₀(D) |

  with s = clamp((D − 64)/40), M₀(D) = lerp(0.6, 0.35, s). Light maxLuma is 1 always.
  Measured only (not found in code): backdrop scale drops to 0.125 at a = 1 (0.5 / 0.25 otherwise).

**Sidebar:** as Regular, but N = 0.25 + 0.25·u below 0.5; above 0.5 fill = black (dark) / white (light) to alpha 0.5·t (light 0.2 + 0.3·t), and dark face black 0.125 → 0.15.

**Clear, Dock, Control Center** (base blur radius r₀ = 0.75 / 1.5 / 4):
- a < 0.5: blur radius = r₀·2a (0 at a = 0: perfectly sharp).
- a > 0.5: adds a blur fill, radius 8 (spec 16 × 0.5 backdrop scale), normal opacity 2a − 1, no darken/lighten. At 1 the backdrop is fully frosted.
- No colour change at all.

**Interior colour over a blurred backdrop c (sRGB-encoded 0…1), all materials:**
```
Y  = 0.2126 R + 0.7152 G + 0.0722 B
Yl = Y − (1 − M)·Y²                       // maxLuma M
out = black + (white − black)·Yl + sat·(Yl/Y)·(c − Y)
out = out·(1 − fillA) + fillRGB·fillA     // before clamping
out = clamp(out, 0, 1)
```
Dark Regular: black 0.125, white 1.125, sat 1.3, M 0.6 (≤ 64 pt). Check: white → 185, grey 127 → 134, black → 32 at a ≤ 0.5; 143 / 104 / 28 at 0.75; 108 / 83 / 32 at 1.
Light Regular: black 0.4, white 1.03, sat 1.2, M 1: black backdrop → 102 / 117 / 133 / 156 / 179 for a = 0…1.
Clear 0.125 / 1.08 / 1.06 / M 1; Dock dark 0.05 / 0.92 / 1.25 / M 0.75 + fill black 2 %; CC 0.125 / 0.8 / 1.2 / M 1.

**Blur seen through the glass** (4 pt stripes, contrast relative to a = 0): Regular ≤ 64 pt 1 / 0.68 / 0.40 / 0.14 / 0; Clear 1 / 0.80 / 0.56 / 0.28 / 0; Dock 1 / 0.52 / 0.21 / 0.10 / 0; CC 1 / 0.53 / 0.21 / 0.11 / 0. Model: blurred = mix(S − darken·max(S − B, 0), B, N), B = blur 8, S = the sharp layer. Regular glass ≤ 64 pt has no centre blur of its own (BlurOpacity0/1 = 0), so the slider is its whole frost. Panels ≥ 160 pt are fully blurred at every value.

## Size (D = shortest side, pt), Regular dark at a = 0.5
| | formula | 24 | 36 | 64 | 200 | 500 |
|---|---|---|---|---|---|---|
| inner refraction amount / height | −min(D/2, 60) / min(D/4, 20) | −12 / 6 | −18 / 9 | −32 / 16 | −60 / 20 | −60 / 20 |
| outer refraction amount / height | max(16, D/4) / max(16, D/5) | 16 / 16 | 16 / 16 | 16 / 16 | 50 / 40 | 125 / 100 |
| edge bleed amount = height | 0.35·D | 8.4 | 12.6 | 22.4 | 70 | 175 |
| bleed opacity = centre blur opacity | 0.8·clamp((D − 64)/96) | 0 | 0 | 0 | 0.8 | 0.8 |
| maxLuma | lerp(0.6, 0.35, clamp((D − 64)/40)) | 0.6 | 0.6 | 0.6 | 0.35 | 0.35 |
| shadow opacity / radius | 0.04 + 0.56·q / 4 + 20·q, q = clamp((D − 64)/96) | 0.04 / 4 | 0.04 / 4 | 0.04 / 4 | 0.6 / 24 | 0.6 / 24 |
| backdrop scale / margin | 0.5 below ~160, then 0.25 / max(16, 0.35·D) | 0.5 / 16 | 0.5 / 16 | 0.5 / 16 | 0.25 / 70 | 0.25 / 175 |
| centre over white / grey / black | measured | 182 / 131 / 31 | 184 / 133 / 32 | 185 / 134 / 32 | 122 / 115 / 32 | 122 / 115 / 32 |

Constant at every size: blur radius 5, blur-fill radius 8, rim (key highlight height 0.5, amount 0.4, spread 75°), ring shadow (0.06, stroke 4, blur 5, offset 8), face black / white / saturation.
Clear: inner refraction −min(0.65·D, 60) / min(0.36·D, 20), outer 0.2·D / 0.125·D, no bleed, no shadow; interior identical at all sizes (255 / 153 / 32).

## Files
- Code excerpt: `reference/re/27.2.1/decomp/DesignLibrary-diffusion-amount.c`
- Probe: `reference/re/tools/probe/thick.swift`
- Data: `reference/re/27.2.1/live/verify/C/` (filter inputs per variant / size / value, pixels, ramp, fit errors, real Dock)
- Pictures: `reference/screens/27.2.1/verify/C/` (variants at 0 / 0.5 / 1 dark and light; sizes over white and stripes)


### C2. Remaining glass items (edge bleed, light shoulder, real CC, backdrop scale, propagation)

# Verify C2: the four open items of verify-C (Liquid Glass slider), macOS 27.2.1 (26B131)

1. Regular glass panels > 64 pt (edge bleed) — **TERKONFIRMASI** — the bleed is not a layer: it is a step inside the same `glassBackground` fragment shader, after the face and before the shadow/rim. `out = mix(face, bleed, w)`, `w = g⁴ · BleedOpacity`, `g = 1 − Y(face)` in dark and `Y(face)` in light, `bleed = bb + (bw − bb)·Y(s) + bs·(s − Y(s))` with dark 0.125 / 0.5 / 1 and light 0.9 / 1 / 1.2. `s` is a sharp backdrop sample, moved outward by `0.35·D` at the edge and by 0 from depth `0.35·D` on. It acts over the whole interior, not only at the edge. — code: QuartzCore `default.metallib` `glass_background_base` (AIR bitcode read as LLVM IR), uniform packing `CA::OGL::GlassBackgroundFilter::render` 0x18debc058; measured: 17 backdrops × a = 0 / 0.5 / 1, dark and light, 96 / 200 / 500 pt and menu 200 pt: **rms 0.36–0.58, max 2.0** (same data without the bleed step, 200 / 500 pt: rms 2.6–8.9, max 35).
2. Light-mode Regular ("soft shoulder") — **TERKONFIRMASI** — light Regular has `maxLuma 1` but **`maxLumaSDR 0.94`**, and the filter uses `M = MaxLumaSDR + (MaxLuma − MaxLumaSDR)·h`, `h = (min(headroom, MaxHeadroom) − 1)/(MaxHeadroom − 1)`. MaxHeadroom is 9999, so h ≈ 0 on any display and M = 0.94: light glass is luminance-limited too. The limiter also raises chroma: `k = clamp(1 − Y·(1 − M))`, luma `k·Y`, chroma `× k·(1 + 0.3·(1 − k))` (the old model had only `k`). — code: render 0x18debc4f4 (h) and 0x18debcf04 (M), 0.94 at 0x195f21600 in RegularBase.Base, shader max-luma block; measured: light Regular 64 pt **rms 0.53 / 0.53 / 0.38, max 1.6** at a = 0 / 0.5 / 1 (was 2.5 / 2.0 / 1.4, max 7.2). Dark colours improve too: rms 0.5, max 1.3 (was 2.0 / 6.8).
3. Real Control Center panel vs slider — **TERKONFIRMASI** — tile colour does not move at all (0.00 levels over a = 0 / 0.25 / 0.507 / 0.75 / 1, four flat backdrops, two tiles). Tile colour = the controlCenter recipe (black 0.125, white 0.8, saturation 1.2) applied to the panel's dimmed backdrop (0.898·in): **rms 0.27, max 0.45** (n = 120). Over 4 pt stripes the tile contrast is 21.0 / 13.8 / 7.9 / 4.0 / 0.0 (the panel's own blur behind the tiles stays 32.0 at every value). The AppKit variant-9 probe over the same pattern, at the same depth below the tile edge, gives 20.2 / 12.9 / 7.3 / 3.5 / 0.0: **rms 0.64, max 1.3**. — code: ClearDiffusionAmount 0x195efeb9c (blur × 2a below 0.5, blur fill 2a − 1 above); measured on the real panel, driven by the coordinated notification (no relaunch).
4. Regular backdrop scale 0.125 at a = 1 — **TERKONFIRMASI** — `GlassMaterialProvider.BackdropScalePerceptualEstimator`: the first scale of [0.125, 0.25, 0.5] whose `visibleAlias = (1 − F)·(N·exp(−π²·rf²·s²/4) + (1 − N)·exp(−π²·r²·s²/4))` is ≤ 0.05, else 0.5. At a = 1: N = 1, F = 0.5, rf = 8 → 0.0424 at s = 0.125. — code: estimate 0x195e9f9dc, visibleAlias 0x195ea0618, epsilon and buckets set in RegularBase.Base 0x195f214a0–0x195f214d4; measured: the formula predicts the scale of every dumped Regular-type view, **794 of 794** (5 values × 6 sizes, dark and light, Regular / Menu / Notification Center / Sidebar).
5. How the value reaches running apps — **TERKONFIRMASI** — AppKit: the handler of `kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName` calls `+[NSGlassEffectView _legibilityNeedsUpdate]`, which re-reads `UserDefaults.standard` float `NSGlassTintAmount` and compares it with the last applied value; if it changed, `NSGlassEffectDiffusionDidChangeNotification` → `globalEnvironmentDidChange:` → `Legibility.apply(to:)` sets `glassDiffusion = .amount(x)`. Dock: `DockCore.SystemAppearanceMonitor` re-reads `NSGlassTintAmount` on the main queue and calls `appearanceDidChange:` on its observers. — code: 0x18b4c4ee8, 0x18b317694 → 0x18b32a01c, 0x18b2b3db8; Dock 0x1001e5cec, 0x1001e61e4, 0x1001e5600; measured: `defaults write` alone, no change for 3 s; posting type 12 changes a running probe within the next 1 s sample, both ways.

Restored: `defaults read -g NSGlassTintAmount` = 0.5071146, type float; `defaults read -g` identical to before. Running apps were returned to it with the same notification (checked on a running probe: 1 → 0.5071146). Control Center was never killed (pid unchanged), its panel is closed.

## 1 and 2. The interior colour, complete (replaces the block in verify-C)
Order inside the shader: backdrop sample (refracted, blurred) → blur fill → outer refraction (rim only) → face → edge bleed → shadow / ring → key highlight (rim) → clamp.
```
c  = backdrop behind the glass, display-encoded 0…1 (after blur and blur fill)
Y  = 0.2126 R + 0.7152 G + 0.0722 B
// face
M  = maxLumaSDR                               // dark: lerp(0.6, 0.35, clamp((D−64)/40)); light: 0.94
k  = clamp(1 − Y·(1 − M), 0, 1)
c1 = k·Y + k·(1 + 0.3·(1 − k))·(c − Y)        // skipped when M = 1
Y1 = luma(c1)
f  = (black + (white − black)·Y1 + sat·(c1 − Y1))·(1 − fillA) + fillRGB·fillA
// edge bleed (BleedOpacity = 0.8·clamp((D − 64)/96): 0 up to 64 pt, 0.8 from 160 pt)
b  = bb + (bw − bb)·Y(s) + bs·(s − Y(s))      // dark 0.125 / 0.5 / 1, light 0.9 / 1 / 1.2
g  = dark ? 1 − clamp(Yb(f)) : clamp(Yb(f))   // Yb = 0.2125 R + 0.7154 G + 0.0721 B
out = f + (b − f)·g⁴·BleedOpacity
out = clamp(out, −0.75, Clamp)                // then the display clamps to 0…1
```
- `s` = the backdrop itself at the panel centre. Near the edge it is read `0.35·D·(1 − √(t·(2 − t)))` further out along the outward normal, `t = clamp(depth / (0.35·D))`, so colours from just outside the panel bleed in. It is sharp (BleedBlurRadius 0), taken before blur fill and face.
- Blend is a plain mix, the mask is the glass shape itself, and the weight is flat over the interior (12 pt inside the edge equals the centre within 1–2 levels on every backdrop).
- Check, dark 200 pt at a = 0.5: white 122, grey 115, black 32 (model 121.5 / 115.2 / 31.9). At a = 1: white 86 (model 86.3; without bleed 76.5).
- The slider does not touch the bleed inputs.

## 3. Real Control Center
- Each tile is controlCenter glass over a panel layer that blurs and dims the desktop (gap between tiles: 0.898·in, stripe contrast 255 → 32, same at every slider value).
- The tile's own blur grows with depth: blur opacity runs from 0.1 at the edge to 1 at 100 pt inside (BlurOpacity 1, 0.1, 0.5, 1 over BlurDistance −100, −1, 0, 0). So a 64 pt tile is never at the full radius 4: about 0.9 at 15 pt deep, 1.5 at the centre line (at a = 0.5).
- Above 0.5 the blur fill takes over: contrast at 0.75 is half of 0.507 (4.0 vs 7.9), 0 at 1.
- Method: `defaults write`, then post the notification (`tools/probe/glasspost.m`), open the panel with a synthetic click over a probe window that cycles stripes / white / grey / black / blue.

## 4. Backdrop scale
- Inputs: `r = BlurRadius·BlurOpacity0` (0 up to 64 pt, 4 from 160 pt), `rf = 8` when any blur-fill opacity is > 0, `N` = blur-fill normal opacity, `F` = face fill alpha.
- Result for Regular: ≤ 64 pt 0.5 / 0.5 / 0.5 / 0.5 / 0.125 and ≥ 160 pt 0.5 / 0.5 / 0.25 / 0.25 / 0.125 at a = 0 / 0.25 / 0.5 / 0.75 / 1.
- Only RegularBase recipes use the estimator (the bucket array has one code reference). Clear, Dock and Control Center stay at 0.5.
- On a display with pixel length ≤ 1/3 the buckets are 0.125, 0.25, 1/3, 0.5 (code only, not measured).

## 5. Notification path
- Sender: `SLSPostCoordinatedDistributedNotificationFenced(SLSMainConnectionID(), 12, fencePort, completion, 0.5)` with a `CAFenceHandle` port (AppKit 0x18b4c4f80). Receivers entangle their commit on the fence, so all apps switch in one frame.
- An unentitled tool can post it: this is how the real panel was measured and how the value was restored.

## Not covered
- Sidebar glass: greys fit (within 1), colours do not (dark rms 6, max 20: measured colours are less saturated than the filter inputs predict). There is something on top of the `glassBackground` filter that this model does not have. Not one of the four items; not investigated.
- The blur kernel itself (mip level `log2(1.6·radius·scale)` of the backdrop texture) is in the code excerpt but was not fitted against pixels.

## Files
- Code: `reference/re/27.2.1/decomp/QuartzCore-glassBackground-shader.c`, `DesignLibrary-backdrop-scale.c`, `AppKit-Dock-glass-notification.c` (and a pointer section added to `DesignLibrary-diffusion-amount.c`)
- Data: `reference/re/27.2.1/live/verify/C2/` — `ramp-shader-model.json` (inputs, measured, model per backdrop), `ramp-fit-errors.json`, `glass_model.py` (the model), `cc-real.json`, `cc-probe-sinusoid.json`, `backdrop-scale.json`, `notification-live.log`
- Pictures: `reference/screens/27.2.1/verify/C2/` (real CC Display + Sound tiles over stripes at five values, probe over the sinusoid, ramp sheet). No personal content; raw captures deleted.
- Tools: `reference/re/tools/probe/thick.swift` (ramp now has 500 pt, menu 200 pt and Notification Center items; new `ccbg` and `ccsin` modes), `glasspost.m`, `air/` (metallib → LLVM IR → expressions)


### B2. Remaining glass items (slider knob lens, Spotlight lens, Dock refraction, menu hover, CC rim)

# Verify B2 (remaining Liquid Glass items of verify-B), macOS 27.2.1 (26B131), 2x SDR, Dark, NSGlassTintAmount 0.507

1. Slider knob lens while held — TERKONFIRMASI — the dumped stack explains it completely; nothing was missing from the dump, three terms were not modelled: (a) face colour matrix black 0.1 / white 1 → `c' = 0.1 + 0.9·c` (the "offset" and part of the slope); (b) ring shadow = inner stroke of the knob shape moved 8 pt DOWN, width 4 pt, Gaussian σ 3 pt, opacity 0.4 → `c·(1 − 0.4·[g(s/3) − g((s+4)/3)])`, `s = sdf(p + (0,−8))`, `g(x) = ½·erfc(x/√2)`: a dark band across the middle (×0.80 at the centre) that turns the ramp slope into 0.70; (c) the usual key/fill highlight. Geometry is only the inner refraction 3.6 pt / −6 pt (the displacementMap with effect height 0 is a zero map). — code: `glass_background_base` ring block (IR %116–%160: polynomial erf, `opacity·saturate(g(s/R) − g((s+w)/R))`), `glass_background_base_inl` (`compute_sdf(p + ring_shadow_offset)`), CPU `GlassBackgroundFilter::render` 0x18debc31c–c334 (offset → −offset along the layer y axis), face matrix inputs FaceColorMatrixBlack/White. Measured (existing captures, 25×20 pt lens, depth > 0.75 pt, 1420 px per ramp): shading off: face fit 0.102–0.105 + 0.891–0.897·c, rms 0.29 level, decoded source position rms 0.16 pt; full lens: rms 0.56 (x ramp) / 0.57 (y ramp) level, median 0.35; without the highlight 2.3, without ring and highlight 17.6–19.1; centre-row slope model 0.702 vs measured 0.706.
2. Spotlight content lens ("lens" on) — TERKONFIRMASI (code + in-process reproduction of the same recipe); on the real field it cannot be seen on text: proven — recipe = regular, surface size large (D = 201.3 pt), `contentEffect = .lense` → CAFilter `glassForeground` on the content: refraction height 16 pt, amount −16 pt, offset −3.3 pt; aberration height 6.6 pt, amount −5 pt, angle 90°; edge opacity 0→1. Absolute points, not size-scaled. Content is taken from `16·lens(depth + 3.3, 16)` pt further inside (6.0 pt at the edge, 2.4 pt at 4 pt, 0 from 12.7 pt); red/blue are taken ±`3.89·lens(depth, 6.6)` pt apart **times W/H at the left/right ends and times H/W at top/bottom** (the shader swaps the two matrix rows for the aberration vector; field 520×87 → ×5.98 at the ends, ÷5.98 at top/bottom). — code: SpotlightUI `contentLensing(true)` → `SwiftUI.Material._GlassVariant.contentLensing` 0x19B811534 (sets `GlassMaterialProvider.Options.contentLensing`, rawValue 1, 0x195E79964) → DesignLibrary 0x195E69AC4–0x195E69B44 (bit 0 → `_Glass.ContentEffect.lense`) → BaseSpec 0x195EF8E60–EA8 / 0x195EF91F4–922C (constants 0x195faa580 = 16, −16, −3.3, 6.6; −5; π/2; only for `.lense`) → shader `glass_foreground_base`, CPU `GlassForegroundFilter::render` 0x18DEBDD14. Measured: new probe `lensprobe.swift` calls the SwiftUI SPI (`_glassEffect(_Glass.regular.surfaceSize(.large)` + `.lense`); live filter inputs = the code constants exactly; content ramps on 3 shapes (capsule 520×87, rrect 300×150, capsule 200×44), shader model vs pixels in the lens zone (depth 1–14 pt): rms 1.15 / 0.81 / 0.53 level (median 0.16–0.21 level = 0.1 pt; no lens: 6.4 / 2.6 / 2.7); capsule ends: 0.33 with the W/H factor, 7.1 without, 34.5 with no lens. Real field: text ink stays 38.5–39 pt from the left edge, 37–37.5 pt from the right, 35 pt from the top (100/200/300 characters: the query wraps to more lines, it never scrolls toward an edge) → always outside the 12.7 pt zone. AppKit `NSGlassEffectView._contentLensing` creates no `glassForeground` filter (7 property combinations, identical layer trees).
3. Dock refraction (top edge separated from the highlight) — TERKONFIRMASI — neither "dock variant at its own height" nor regular: the Dock uses the **dock recipe with size class medium**, i.e. a fixed reference dimension D = 166 pt: inner refraction height 0.08·166 = **13.28 pt**, amount −0.18·166 = **−29.88 pt**, the same for every Dock size; blur 1.5, outer refraction opacity 0.2 with amount 0, colours = dock matrix (unchanged). — code: Dock.app 0x10011a534–0x10011a560 (`GlassMaterialProvider.Configuration.dock`, `.size = Size.medium`); DesignLibrary 0x195F64640–0x195F646E4 (size-class table 0x195fb2068 = 48 / 166 / 201.3 pt for minimum / medium / maximum, automatic = real shape); DockRecipe.Other 0x195F0DCBC (v2 branch −0.18 / 0.08). Measured highlight-free: per-pixel transfer function from 8 grey backdrops, then ramp backdrops decoded through it (source position per pixel; all 4 edges agree, row IQR 0). Tile 33 (platter 633×48): free fit A −32.3…−34.8 / H 12.9–13.9 pt; tile 64 (1233×84): A −26.3…−29.5 / H 13.0–14.1 pt. Model D = 166: rms 0.69 / 0.93 / 1.12 pt (top / bottom / left, tile 33) and 0.40 / 0.59 / 0.94 / 0.53 pt (tile 64); own-height dock variant 6.1–10.3 and 4.1–4.6 pt; regular 2.2–3.6 and 5.8–7.6 pt. Cross-checks: SwiftUI probe `_Glass.dock.surfaceSize(.medium)` at 633×48 and 633×84 dumps exactly 13.28 / −29.88 (automatic at 48: 3.84 / −8.64) and its decoded profile equals the real Dock's (rms 0.57–0.91 pt top edge); AppKit `_variant` 3 at 633×48 through the same pipeline gives back its own 3.84 / −8.64 (rms 0.31–0.41 pt), body colours identical to the real Dock (12 / 106 / 177 over 0 / 120 / 255).
4a. Menu item highlight on glass menus — TERKONFIRMASI — not glass: an opaque rounded rectangle under the row views: `NSRootMenuWindowBackgroundView` (inside `NSTableViewBackedMenuRepresentation`) holding one CALayer, backgroundColor sRGB (0, 0.478, 1, 1) = accent colour, cornerRadius 7 continuous, no filter; frame (5, 5, 185, 24) in a 195 pt menu → 5 pt inset left/right, row height 24, first row 5 pt below the menu top (menu radius 12 − 5 = 7). Hidden with a zero frame when nothing is highlighted. Text and key equivalent turn white (234 → 255, 150 → 255). — code: in-process layer dump of the open NSPopupMenuWindow at rest and highlighted. Measured: real NSMenu in the probe, highlighted with the Down key (2 items) and with real mouse moves: changed area exactly 370×48 px on all four backdrops (grey, white, black, colour bars); fill (52, 120, 246) on every backdrop = #007AFF converted to the display space (52.1, 120.1, 246.4); corner coverage → radius 7.26 pt (circle-equivalent of continuous 7).
4b. Control Center top-rim numbers — TERKONFIRMASI, formula corrected — module rim over grey 128 (body 110): 233 180 134 128 124 121 118 117 115 114 113 112 (px 1…12 from the edge); over white (body 187): 255 247 208 202 199 196 194 193 191; over black (body 32): 123 84 50 45 42 40 38 37 36; bottom rim identical to the top. Model `dst' = dst + m·(min(M·dst + b, 1) − dst)`, M row R = 1.319 −0.048 −0.005 | 0.2, m = 1.53, 0.877, 0.305, 0.224, 0.172, 0.134 …: rms 0.3 / 0.3 / 0.2 level. **Correction to verify-B:** the clamp applies to the matrix result BEFORE the mix (and m is not saturated), not to the final value — over white the old form gave rms 4.2. — code: uber shader `vibrant_color_matrix_sover` (IR label 75: `clamp(v, −0.75, inputClamp)`, then `(1 − a)·dst + v·a`). Measured on 7 modules (140×64, 140×140, 292×64 pt), 144–448 content-free columns each, found from a black-backdrop mask.

Notes
- Size classes are the general rule behind item 3 and the Spotlight field: `GlassMaterialProvider.Size` minimum / medium / maximum = D 48 / 166 / 201.3 pt (SwiftUI `_Glass.SurfaceSize` small / medium / large); every "normalized" recipe value is multiplied by that D instead of the shape's own shortest side. Dock = medium, Notification Center = medium, Spotlight field = large (live dump: inner −60 / 20, outer 50.3 / 40.3, margin 70.5). AppKit `NSGlassEffectView` is always automatic, which is why `_variant` 3 looked different from the real Dock.
- The real Dock at tile 33 measures about 10 % more displacement than D = 166 (best single D 174–176; tile 64: 154–168). Not explained; inside 1 pt.
- Control Center is not one panel: separate modules over a dimming layer (grey 128 → 115–122, white → 230–244 outside the modules).
- For hyprk: Dock lens = fixed 13.3 pt band with −29.9 pt amount (not a fraction of the Dock height); menu selection = plain accent rounded rect r 7, inset 5; rim highlight must clamp the matrix colour before mixing; Spotlight content lens exists but never reaches the text, so it can be left out (or drawn only within 12.7 pt of the field edge).
- Restored: Dock prefs identical to the backup (tilesize 33; it was 64 for about 40 s, Dock relaunched twice), Dark mode on, apps visible as before, Spotlight and Control Center closed, lock released. One "Problem Report" dialog came up when the first build of the new probe crashed; I closed it and deleted the two crash logs it left; the probe now exits silently on a fault. Raw captures of the Dock, Control Center and Spotlight were deleted; nothing personal is in the repo.

Files
- Data: ~/hyprk/reference/re/27.2.1/live/verify/B2/ (slider_fit.txt, lens_fit.txt/json, refr_*.json, cc_rim.txt/json, menu_hl.json, configs/, dumps/, scripts/)
- Code: ~/hyprk/reference/re/27.2.1/decomp/DesignLibrary-surface-size-content-lensing.asm, Dock-glass-configuration.asm, QuartzCore-GlassForegroundFilter-render-excerpts.asm; QuartzCore-glass-shaders.c updated (ring shadow, clamp order, glass_foreground)
- Tools: ~/hyprk/reference/re/tools/probe/lensprobe.swift (new), glassfit.swift (content pattern, menu-window dump, view properties), ~/hyprk/reference/re/tools/gotsym.c (resolves shared-cache stubs / GOT slots)
- PNG: ~/hyprk/reference/screens/27.2.1/verify/B2/


### C3. Sidebar chameleon tint, blur kernel, edge-bleed blur

# Verify C3: sidebar glass colours and the glass blur kernel, macOS 27.2.1 (26B131)

1. Sidebar glass colours — **TERKONFIRMASI** — sidebar glass (`NSGlassEffectView` `_variant` 17 and 18) has one layer that regular glass does not: a **`CAChameleonLayer`, compositingFilter `colorBlendMode`, opacity 0.10 dark / 0.05 light**, directly above the `glassBackground` backdrop and below the rim highlight. It is a solid fill in the window's "chameleon colour" = the **mean wallpaper colour under the window frame**, quantised to 6 bits per channel. Result: `out = f + (SetLum(tint, Lum(f)) − f)·opacity`, `f` = glass output clamped to 0…1, `Lum = 0.30 R + 0.59 G + 0.11 B`. The slider does not change it. With "Tint window background with wallpaper colour" off the layer is not created. — code: layer tree dump (class, filter, opacity); QuartzCore `CA::Render::Updater::prepare_layer0` 0x18dec6898 (copies the context colour into the layer), `render_subclass…ChameleonLayer` 0x18de36bf0 (solid fill), `CARenderContextSetChameleonColor` 0x18de86c9c; SkyLight `CGXWindow::resolved_chameleon_color` 0x1829f697c → `Payload::average_color` 0x182a94d60 (box mean over the window rect from a summed-area table, then `min(trunc(c·64), 63)/63`); SwiftUICore `Material.Layer.chameleon(fallbackColor:filters:)` 0x19122dfbc. Measured: 50 uniform backdrops × a = 0 / 0.5 / 1 × 6 sidebar views (17 and 18 at 160×64, 200×200, 240×500): **dark rms 0.48–0.88, max 3.0; light rms 0.46–0.75, max 2.7** (same data without the layer: dark rms 3.5–6.4, max 21; light 1.7–3.2, max 12.6). Regular glass in the same captures, no layer: rms 0.38–0.54, max 1.9.
2. Blur kernel — **TERKONFIRMASI** — the blur is one trilinear read of a mip pyramid. Backdrop at scale s = box average of 1/s × 1/s screen pixels; each mip level = the level below filtered by 13 bilinear taps (weights 0.1055 centre, 0.0902 at (±1.96, 0) and (0, ±1.96), 0.0771 at (±1.96, ±1.96), 0.0563 at (±3.92, 0) and (0, ±3.92) texels) and halved; level read = `lod(R) = max(0, log2(R < 2 ? R/2 + 1 : R))`, `R = 1.6 · radius[pt] · (backdrop texels per pt)`. **Gaussian equivalent: σ = 2.0 · radius points** (sd 0.03, 1.93–2.04, R ≥ 4), independent of the backdrop scale, isotropic. — code: shader `glass_background_base` (lod), `variable_blur_downsample_frag` (the 13 taps, AIR bitcode), `prepare_blur_mipmap` 0x18e078efc, `compute_variable_blur_parameters` 0x18de2bfe4, `MetalContext::create_variable_blur_mip_surface` 0x18df6be08. Measured: blur-only probe glass, radius 0…24 × scale 0.125 / 0.25 / 0.5 / 1, 349 captures: **edge rms 0.66 mean (0.04–2.1), 1 px line 0.24 mean (max 0.8), 8 px line 0.49 mean**, of 255; one configuration does not fit (scale 0.125, radius 6: rms 8.7). Stock recipes (Regular 64…300 pt, Menu, Clear, Dock, Control Center, Sidebar) over edge / line / stripes at a = 0 / 0.5 / 1, full model: **rms 0.1–1.0 per recipe (worst single capture 1.9), max 3.5**.
3. Correction of verify-C2 (edge bleed) — **TERKONFIRMASI** — the edge-bleed sample is not sharp. `inputBleedBlurRadius = BleedAmount = 0.35·D` whenever the bleed is on, and the shader blurs with half of it: **radius 0.175·D (σ ≈ 0.35·D)**. — code: `get_glass_filter_bleed_blur_radius` 0x18de1a408 (`0.5 × inputBleedBlurRadius`), probe dumps (33.6 / 42 / 56 / 70 / 84 / 105 at D = 96 / 120 / 160 / 200 / 240 / 300). Measured over an edge under 96…300 pt panels, dark and light: rms 0.24–0.66 (max 2.2) with that radius; 0.5–8.7 (max 20) with a sharp sample. C2 could not see it: its backdrops were uniform.

Restored / untouched: `NSGlassTintAmount` = 0.5071146 (float) was never written this time (the probe takes the value as a launch argument, `-NSGlassTintAmount <a>`, its own process only). Dark mode on, wallpaper untouched, no global default written, lock released, no probe left running.

## 1. Sidebar: the missing layer
Layer tree under the glass view (sidebar; regular glass is the same without `@1`):
```
CABackdropLayer  "@0"  filters [glassBackground]
CAChameleonLayer "@1"  compositingFilter colorBlendMode, opacity 0.10 (dark) / 0.05 (light)
SDFPortalLayer   "@2"
CASDFLayer       "@3"  key/fill highlight, filters [vibrantColorMatrix]
```
```
f    = clamp(glassBackground output, 0, 1)            // model of verify-C2
L    = 0.30 f.r + 0.59 f.g + 0.11 f.b
b    = ClipColor(tint + (L − Lum(tint)))              // PDF / CSS "color" blend
out  = f + (b − f) · (dark ? 0.10 : 0.05)
tint = quantise6(mean of the wallpaper pixels under the window frame)   // encoded values, not linear light
```
- Tint colour: measured with a bare `CAChameleonLayer` at opacity 1, moved over 20 screen positions: equals the mean of the wallpaper under the window, rms 1.8, max 3.7 (linear-light mean: rms 4.2, max 20). It follows the window at once (same value 0.25 s and 1.6 s after a move). An app can override it per window (`SLSSetChameleonOverrideColor`) or inherit a parent's.
- Bare layer vs the blend formula, 50 backdrops: opacity 1 rms 0.32 (max 0.70), opacity 0.1 rms 0.50 (max 1.45).
- Over greys the effect is a slight tint (dark, this wallpaper: 127 → 126 / 127 / 128). Over colours it pulls 10 % toward a near-grey of the same luminosity: pure blue under dark sidebar 28 / 29 / 235 (model 28.2 / 29.1 / 235.3; regular glass 26 / 26 / 255).
- `AppleReduceDesktopTinting = YES` (given to the probe as a launch argument): no `CAChameleonLayer` in either sidebar variant, sidebar 17 over grey = regular glass (134).
- The two sidebar variants differ in the glass recipe, not in this layer:

| | variant 17 | variant 18 (the one Finder and Settings use) |
|---|---|---|
| face black / white / saturation, dark | 0.125 / 1.125 / 1.3 (= Regular) | 0.10 / 0.50 / 0.6 |
| maxLuma, dark | 0.6 → 0.35 with size (= Regular) | 1 |
| face, light | 0.4 / 1.03 / 1.2, fill white 0.2, maxLumaSDR 0.94 | same, maxLumaSDR 0.85 |
| bleed black / white / saturation | 0.125 / 0.5 / 1 dark, 0.9 / 1 / 1.2 light | 0.10 / 0.5 / 1.5 dark, 0.75 / 0.9 / 1.5 light |
| refraction opacity, drop and ring shadow | 0.6, as Regular | 0, none |
| slider above 0.5 | face fill to 50 % (black dark, white light) | no face change (blur fill only) |

## 2. Blur: what to implement
- **Simple:** Gaussian with σ[pt] = 2.0 × filter radius (× display scale for pixels). The DesignLibrary spec radius is twice the filter radius, so σ ≈ spec radius. Stock values: blur fill radius 8 → σ 16 pt; Regular panel ≥ 160 pt own blur 5 × 0.8 → σ 8 pt; Control Center 4 × opacity(depth); Dock 1.5; Clear 0.75; edge-bleed sample 0.175·D → σ 0.35·D.
- Small radii do not go to zero: the backdrop scale sets a floor. σ (pt) from the model, stock recipes:

| filter radius | 0 | 0.375 | 0.75 | 1 | 1.5 | 2 | 3 | 4 | 5 | 8 | 16 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| scale 0.5 | 0.50 | 0.94 | 1.56 | 1.87 | 2.69 | 3.81 | 5.81 | 7.94 | 9.62 | 16.1 | 32.1 |
| scale 0.25 | 0.96 | 1.29 | 1.82 | 2.29 | 3.09 | 3.75 | 5.38 | 7.62 | 9.44 | 15.9 | 32.1 |
| scale 0.125 | 1.91 | 2.19 | 2.54 | 2.88 | 3.60 | 4.56 | 6.19 | 7.50 | 8.50 | 15.3 | 31.8 |

- **Exact:** downsample the backdrop by 1/s (box), build levels with the 13-tap kernel, read `lod(R)` trilinearly. A dual-Kawase chain is the same idea; match it by σ per level: level L has σ ≈ 1.31 · 2^L texels of the scaled backdrop.
- Blur fill reads two taps at ∓L/4 texels (diagonal) of its level and averages them; then `m = lighten·max(c, B) + darken·min(c, B) + (1 − lighten − darken)·c`, `c = mix(m, B, normal)` (verify-C formulas, now checked on edges and lines).
- The gauss fit is good but not perfect: residual of an erf fit rms 0.3–1.4, max 5 of 255 (the kernel has slightly heavier tails).
- Isotropy: horizontal vs vertical edge 10–90 % widths within 2 px; second moments of a dot along x / y / diagonal within 3 %.
- Detail only the probe hits: when the smallest blur radius of a backdrop group gives R > 2, the pyramid is stored from level 1 (half size) and the shader gets R/2, so the level is `1 + lod(R/2)` for 2 < R < 4 (measured 1.61 / 1.69 / 1.86 at R = 2.08 / 2.4 / 3.2; rule 1.60 / 1.68 / 1.85). Stock recipes fit with plain `lod(R)`.

## Not covered
- The mean wallpaper colour was checked on this one wallpaper (20 positions). The 6-bit quantisation is from code; the pixels agree with it only as far as the 2-level fit error shows.
- The SwiftUI / DesignLibrary site that sets opacity 0.10 / 0.05 was not located (symbol found, call site not); the values are from the live layer tree.
- Real Finder / Settings sidebars were not re-measured; variant 18 was measured in the probe only.
- Blur outlier: scale 0.125 with radius 6 in the blur-only probe (rms 8.7), not explained beyond a one-texel misalignment of the half-size base.
- Dual-Kawase pass counts for Hyprland were not derived; the table gives the σ to match.

## Files
- Model: `reference/re/27.2.1/live/verify/C3/glass_model.py` (superset of the C2 model: `face`, `chameleon`, `chameleon_color`, `level`, `sigma_pt`, `Pyramid1D`, `backdrop_1d`, `profile_1d`); fits: `fit_c3.py`
- Data, same folder: `sidebar-fit.json`, `sidebar-recipe-inputs.json`, `layer-tree-dark.json`, `layer-tree-light.json`, `layer-tree-dark-reduce-desktop-tinting.json`, `chameleon-vs-wallpaper.json`, `blur-kernel-fit.json`, `blur-level-fine.json`, `blur-gauss-fit.json`, `blur-sigma-table.json`, `blur-isotropy.json`, `blur-profiles.json` (measured edge / line responses, for testing an implementation), `recipes-edge-fit.json`, `bleed-blur-fit.json`
- Code excerpts: `reference/re/27.2.1/decomp/QuartzCore-SkyLight-chameleon.c`, `QuartzCore-glass-blur-pyramid.c`; correction note added to `QuartzCore-glassBackground-shader.c`
- Probes: `reference/re/tools/probe/glass3.swift` (tree / sb / blur / nat / nat3), `cham.swift`
- Pictures: `reference/screens/27.2.1/verify/C3/` (probe windows only)
