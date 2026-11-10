# Requests for the Mac session (macOS 27.2.1)

From the PC session, 2026-11-10. The user tested the nested session and listed what is still wrong.
The PC cannot measure these: please take them from the real Mac. Answer in `reference/re/MAC-ANSWERS.md`
(one section per request id, say "not done: why" where needed), put data next to it, commit as `re: ...`.
If something here is unclear or you see a better way, write it under "Questions for the PC" in the answers file.

What the user reported on the PC:
1. Dock magnification is animated by default; on macOS it is off by default.
2. macOS 27.2.1 changed the UI a lot; the PC still follows 27.2 screenshots and the 27.2 dyld cache.
3. Transitions and animations still glitch.
4. Moving between menu bar titles while hovering glitches.
5. The open and bounce animations do not look natural.
6. Icons are not the native ones.
7. Multicolor, text, fonts and emoji need work.

## R1 Screenshots (2x PNG, light and dark, default wallpaper) -> `reference/screens/27.2.1/`
Name them `<surface>-<light|dark>.png` and list them in an `INDEX.md` there.
- Desktop idle, Dock alone (cropped), menu bar with a menu open, a context menu.
- Control Center, Notification Center, Spotlight (empty, with results, each Cmd+1..4 mode), Cmd-Tab.
- Mission Control and the Spaces bar (the PC has no reference at all for these), Launchpad or Apps.
- System Settings: Appearance (accent row visible, once with Multicolor selected), Desktop & Dock, Displays
  (with the scaled sizes shown; on an external display too if one is at hand), Accessibility, Wallpaper, Sound.
- Finder window in all four views, an alert, a sheet, a popover.
- A control gallery from the probe: checkbox (off, on, mixed, disabled), radio, segmented control, switch,
  slider, popup button, text field, search field, stepper, push buttons. Also dump their frames and colours.
  The PC guessed every checkbox and segmented control number (ui/HyprK/Checkbox.qml, SegmentedControl.qml).
- The emoji picker and one text sample (SF Pro 11, 13, 17, 26 pt regular, semibold and bold, plus emoji).

## R2 Motion (60 fps recording + `tools/vidmotion.py` numbers) -> `27.2.1/live/` and a table in the answers
- Dock: `defaults read com.apple.dock` (magnification, largesize, tilesize, mineffect, launchanim) on a clean
  account. App launch bounce: height in pt, time per bounce, number of bounces, curve. Hover label timing.
  Magnification when switched on: size curve against pointer distance and how it eases in and out at the edge.
- Menu bar: with a menu open, move the pointer across the titles. Does the title highlight slide or jump,
  does the old menu fade while the new one appears, how many frames. Also the selection highlight in a menu.
- Control Center, Notification Center and Spotlight open and close. Mission Control enter and exit.
  Cmd-Tab show and hide. Launchpad or Apps open and close.
- App launch: from click on the Dock icon to the window, what the window does (scale, fade, from where).
- Window minimise, zoom, full screen enter and exit, close.
- Switch, checkbox, segmented control and slider being pressed and released.

## R3 Native icons -> `themes/icons/apple-27.2.1/`
Rendered 1024 px PNG (the icon as the Dock shows it, not the raw layers), light and dark variants if they
differ, plus `map.json` from bundle id to file. Finder, System Settings, Terminal, Safari, Mail, Calendar,
Notes, Reminders, Photos, Music, Maps, Messages, Preview, TextEdit, Calculator, App Store, Activity Monitor,
Disk Utility, Font Book, Archive Utility, Screenshot, Trash empty and full, the Downloads stack, the generic
folder and document, the generic application. The PC maps Linux apps to these.

Status on the PC (2026-11-10): all 72 app icons are now the real 512 or 1024 px renditions from the 27.2 IPSW
(`themes/icons/apps`, list in `apps-sources.txt`). Only send app icons whose artwork changed in 27.2.1.

## R3b SF Symbols and Settings pane icons (the PC cannot decode these)
- Every glyph in the menu bar, Control Center, Finder sidebar and toolbars is hand-drawn on the PC, because
  the symbols only exist as undecoded `BVG` vectors in CoreGlyphs. Please render with
  `NSImage(systemSymbolName:)` to vector (PDF or SVG, template, regular/medium/semibold weight, plus the
  hierarchical or multicolor variant where the system UI uses one) every symbol named in
  `shell/components/symbols.js`, `finder/qml/lib/symbols.js` and `themes/icons/settings/panes.json`
  (map the hand-drawn names to the real symbol names; say which real symbol each system surface uses where you
  can tell) -> `themes/icons/sf-symbols/svg/<symbol.name>.<weight>.svg` with a `names.json`.
- The System Settings sidebar icons are drawn at run time (enclosure + symbol), so the IPSW has no bitmaps:
  21 of 23 panes are still Material glyphs on the PC. Render each pane's sidebar icon (64 and 128 px PNG,
  light and dark) -> `themes/icons/settings/<pane id>.png`; pane ids are in `settings/Panes.js`.

## R4 Fonts and emoji
- `Apple Color Emoji.ttc` -> `themes/fonts/` (the PC has no Apple emoji yet).
- sha256 of the SF Pro, SF Compact, SF Mono and New York files on 27.2.1 so the PC can compare with its copies.
- The text style table: for each NSFont text style and control size, the point size, weight and tracking.

## R5 Accent and Multicolor
- A zoomed capture of the accent swatch row, and the Multicolor swatch asset itself if it can be exported.
- For each accent in light and dark: controlAccentColor, selectedContentBackgroundColor,
  selectedTextBackgroundColor, keyboardFocusIndicatorColor.
- What Multicolor does on 27.2.1 (per-app accent?) with one example of two apps side by side.

## R6 27.2.1 against 27.2
- A short list of what visibly changed from 27.2 (the user says: a lot).
- The PC only has the 27.2 dyld cache. Which is easier: you extract more binaries into `27.2.1/` (which ones
  hold the Dock, the menu bar, Control Center, WindowManager and System Settings UI?), or the user copies the
  whole 27.2.1 cache to the PC outside git? Say the size.
