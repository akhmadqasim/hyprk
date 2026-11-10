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
