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
