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
