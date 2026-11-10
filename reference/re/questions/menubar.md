# Questions for the Mac: menubar
Scope: menu bar, titles, pull-down and context menus, status items, Apple menu. pt at 2x, light and dark if different; R1-R6 = MAC-REQUESTS.md (title-switch motion is R2).
Files under shell/: T=Theme.qml MB=modules/MenuBar.qml MD=modules/MenuDropdown.qml OV=modules/Overlay.qml

Q-menubar-01 Bar height
now: 30 (T:186, SPEC only); metrics-light.json says menuBarHeight 34 on the Air
ask: AXMenuBar height on the notched Air and on an external non-notch display.

Q-menubar-02 Bar background
now: transparent (T:148, guessed)
ask: Bar over very bright, very dark and default wallpaper: any scrim, blur, gradient or bottom edge line? Is "Show menu bar background" off by default?

Q-menubar-03 Title text colour
now: white, or black a0.85 when wallpaper luma >0.62 (T:41,146, guessed)
ask: Text pixel colour over light and dark wallpaper in both appearances. Is there a luma switch, at what level (gradient wallpaper)?

Q-menubar-04 Open title: glass?
now: regular Glass capsule, tint white a0.22 / black a0.10 (MB:233-244, T:147, guessed)
ask: Yes/no: CABackdropLayer with glassBackground? If not, fill colour+alpha. Pixel inside vs outside the pill over light/dark wallpaper.

Q-menubar-05 Title pill frame
now: h24, radius 12, pad 9, gap 2 (T:189-192, guessed)
ask: AX frames: open title, neighbours, logo, app name. Pill x, width, height, corner radius, gap.

Q-menubar-06 Title fonts
now: 13 regular; app name DemiBold+wght700 (MB:177-180, T:104; size SPEC, bold by eye)
ask: Font, size, wght, tracking of app name and normal titles.

Q-menubar-07 Left edge, logo
now: left margin 14, logo box 16 (MB:39, T:187-188, guessed)
ask: x and size of the Apple glyph, x of first title text.

Q-menubar-08 Status item list
now: battery (laptop), Wi-Fi, Focus (DND), search, Control Center, clock (MB:79-147, by eye)
ask: Right-to-left list on a clean 27.2.1 account with AX labels. Search, Siri, Bluetooth, Sound, Focus: shown by default or only when active?

Q-menubar-09 Status item frames
now: icon 16, pad 8, gap 4 (T:193-195, guessed)
ask: AX frame of every status item, glyph bbox, gap, clock right margin to screen edge.

Q-menubar-10 Clock
now: "Tue Nov 10  4:34 AM", 13 regular (clock.js:32, T:106, by eye)
ask: Default text with the Date & Time options (weekday, date, seconds, AM/PM, spaces); font, weight, tracking, tabular digits.

Q-menubar-11 Status hover and press
now: glass pill on hover and open, lifts on press (MB:260, T:147, guessed)
ask: Hover with no menu: anything shown? Pressed: shape, colour, glass yes/no, same as title pill? 60 fps clip.

Q-menubar-12 Row selection highlight
now: solid accent, r7, inset 5, white text (MD:119-127, T:151; r7/inset SPEC, fill guessed)
ask: Real pointer hover: accent solid, glass or grey? RGBA light/dark, with blue and graphite accent; label, shortcut, chevron colours on it.

Q-menubar-13 Pull-down material
now: plugin regular glass, tint .74 / .72 (MD:83-90, T:167, guessed)
ask: Yes/no: the pull-down is the same glass window as the context menu (subvariant menu)? Empty-area pixel over white and black wallpaper.

Q-menubar-14 Pull-down position
now: x = title left, y +3 below bar, 4 edge margin (OV:83-84, T:209, guessed)
ask: Menu frame offset from title and bar bottom, for Apple menu and the last title. Edge clamp.

Q-menubar-15 Text column, checkmarks
now: text x 16, no state column (MD:159); Mac: x28 with a checkmark column
ask: Text x for a menu with no checkmark or icon rows. Does the column appear only when needed?

Q-menubar-16 State rows
now: missing (no check, mixed dash, indent)
ask: Checkmark and mixed-dash size, x, colour (normal, selected); indentationLevel 1 shift.

Q-menubar-17 Row icons
now: missing
ask: Do 27.2.1 menus show leading SF Symbols (Apple, File, Edit, context)? Which, size, x, tint, text x.

Q-menubar-18 Shortcut column
now: 13pt tertiary, right-aligned text, gap 22 (MD:165-174, T:206; gap SPEC medium)
ask: Are "⌥⌘⎋", "fn E", "⇧⌘N" modifier glyphs aligned in columns? Font, tracking, glyph gaps.

Q-menubar-19 Menu width
now: min 220, text+shortcut+62 (MD:35, T:208, guessed); Mac sample 182
ask: Widths of Apple, Finder File, Edit menus; is there a minimum?

Q-menubar-20 Separator
now: 1px line, inset 16, row 11 (MD:149-155, T:207; row measured, rest guessed)
ask: Line thickness px, x insets, colour, light/dark pixel.

Q-menubar-21 Dark menu colours
now: label .85 / .55 / .25 (Tokens:27-29, guessed in dark)
ask: Dark NSColor label, secondary, tertiary, separator, selectedMenuItemText, disabledControlText RGBA.

Q-menubar-22 Disabled row
now: tertiary text, no highlight on hover (MD:143,163, measured text)
ask: Pixels of disabled row text and under hover.

Q-menubar-23 Submenus
now: chevron 11 shown, nothing opens (MD:175-183)
ask: Chevron size, x, colour. Submenu frame offset, open and close delay, same glass? 60 fps clip.

Q-menubar-24 Click and drag
now: click opens, click row runs; drag-release missing, no flash (MB:187)
ask: Press title, drag to row, release: runs? Row blink on activation: count, frames. Menu fade after.

Q-menubar-25 Keyboard
now: only Esc (OV:41-43); no arrows, type-select, Return, Option alternates
ask: Arrows, wrap, Left/Right between titles, Return, letter jump, Option swaps; key highlight look.

Q-menubar-26 Long menus
now: missing (no scroll, no max height)
ask: Menu taller than screen: arrows or fade (NSScrollPocket in tree), max height, bottom margin.

Q-menubar-27 Context menu
now: same widget, at click, 4 margin (OV:54-65, guessed)
ask: Frame offset from click (desktop, Finder icon), edge flip, differences from pull-down.

Q-menubar-28 Menu shadow
now: plugin menu recipe, params only (T:179-181; LIVE 0.7/0.8, r24, y10)
ask: Pixel rows under and beside a menu over white and black wallpaper: extent, strength, outer hairline.

Q-menubar-29 Battery
now: "NN%" 12pt + hand-drawn icon, red <20% (MB:82-107, guessed)
ask: Percent shown by default? Icon size, fills at 100/50/19%, bolt, low-power colour.

Q-menubar-30 Other glyphs
now: Wi-Fi (0.5 dim off), CC, search 15, moon 15 (MB:110-134, guessed; R3b: vectors)
ask: Symbol name, pt size, weight, bbox per glyph; Wi-Fi off, no link, 1-3 bars.

Q-menubar-31 Apple menu rows
now: 14 rows (menus.js:7-25, by eye)
ask: Exact rows, order, shortcuts, disabled state in Apple and Finder app-name menu.

Q-menubar-32 Solid modes
now: #ECECEE / #2A2A2C solid (T:166, guessed)
ask: Menu, pill, selection pixels with Reduce Transparency and Increase Contrast.

Q-menubar-33 Full screen bar
now: missing (bar always shown)
ask: Full screen window: bar hides? Reveal: slide or fade, ms, curve, background.

Q-menubar-34 Glass containers
now: none on the bar; only pills (MB)
ask: Yes/no: any glass capsule behind the right-side items or the bar itself, in default or Clear/tinted modes?
