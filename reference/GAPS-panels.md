# Control Center, Notification Centre and the menu bar's right side against the Mac (re21, 2026-11-12)

Headless session, scale 2 (2560 x 1664, 1280 x 832 pt, menu bar 34), dark and light, Tahoe wallpaper. Mac shots are
2 px/pt (`overview-redacted-*` 1 px/pt). Positions in pt from the screen's right / top edge or the module's edge, so the
Mac's 1710 pt screen and ours compare directly. Test notifications from the session's private bus (gdbus Notify and
`notifs test`). Only geometry and ink was compared; colours of the glass were not (different backdrops).

## Ranked differences
1. FIXED (dc48cca). Notification card and banner app icon: Mac squircle 32 x 32 at 13 from the card edge
   (Q-panels-28; `panels/banner-dark-black.png` squircle 31.5 at 13; `nc/stack-dark-grey.png` 32 at 13); ours 26 x 26
   at 16 (the 32 pt box held the icon's transparent margin, body .8047) -> 32 x 32 at 13, NC card and banner, dark and light.
2. FIXED (f81f42c). "Notification Center" heading x: Mac text frame 1 pt inside the cards' edge (Q-panels-32: x 1351,
   cards 1350), ink 3 in (`nc/overview-redacted-dark-blue.png`); ours frame 4 in, ink 5.5 -> ink 2.5, dark and light.
3. OPEN. NC Calendar month grid: Mac (small Calendar, `nc/widgets-dark-grey.png`) column pitch 19.6, row pitch 19.2,
   heading to first row 19.5; ours (medium Calendar) 19, 18, 18 (Theme.nc.monthCell 17, monthGap 2; widgetMonth /
   widgetSmall marked TODO). Digit ink height 7.5 both. The Mac data is the small widget and ours is the medium one: needs a
   Mac capture of the medium Calendar before changing.
4. FIXED (re23, 2026-11-14: the heading's button is NotificationsConfirmCloseButton, 20 pt glass with a 28 pt click
   area, and the title is system 18 semibold; decoded in `re/27.2.1/GAPS-REA-panels.md` section 1; ours 24 and 17 bold
   -> 20 and 18 semibold, seen in a headless session). Was: NC section "Clear All" circle: ours 24 (Theme code value from NotificationButtonStyle, MAC-ANSWERS "Buttons");
   Q-panels-32 AX says 28; the 1 px/pt overview reads about 20 tall (y 212.5..232.5). Three sources disagree: needs a
   2x Mac shot of the heading row.
5. SETTLED, no change (re23: `MenuItemHidden` in com.apple.Spotlight is absent on a clean account and absent means
   shown, `re/27.2.1/GAPS-REA-panels.md` section 3; the reference Mac's owner hid it, inferred). Was: Menu bar: our bar has a Spotlight item between Wi-Fi and Control Centre; the Mac's
   bar (`menubar/bar-dark.png`, menubar-metrics.json statusItems) shows Battery / Wi-Fi / Control Centre / Clock only.
   Whether 27.2.1 shows Spotlight by default is not in reference/.
6. FIXED (round3, 2026-11-14: `re/27.2.1/GAPS-REA-round3.md` section 2). Emoji picker category bar: the Mac dark
   shot draws the dog and the soccer ball filled while not selected; ours drew the outlines. UIKitCore's
   `+[UIKeyboardEmojiGraphics emojiCategoryImageName:forRenderConfig:]` 0x1ac1b58a4 picks `.inverse` for the face, dog
   and ball unless the render config is a light keyboard; `lib/emoji.js tabs(dark)` does the same (seen in a headless
   session, dark). Weight stays regular (ink of apple, heart, flag within 1.5 %). Which framework draws the Mac
   popover's bar is inferred from the pixels: CharacterPicker names only the plain symbols.
7. FIXED (2026-11-14, judges #10-#13 item "Spotlight reopen first frame"). Spotlight reopen: the first frame repeated the
   second's glass. Measure agreed with judge #10: `mcap -k 2`, row y 232, x 300-420, the rim's rising step, 1 sample
   per pt; reopen = `panels toggle spotlight` on a closed Spotlight (and `panels close` then toggle). Before: 1.090 1.071
   1.048 ... in most reopens, but 1.071 1.071 1.048 in 9 of 60 (judge #10 saw it 9 of 9 on its setup). Cause, from
   Qt and Hyprland logs: after idle Qt builds the open's first two frames 1 ms apart; Hyprland 0.57.2 holds each
   commit until its buffer is ready but its ext-background-effect keeps one region per surface and copies the newest
   one when a commit is applied (protocols/BackgroundEffect.cpp), so the first frame was drawn with the second
   frame's region and opacity marker. The plugin now records the region with each queued commit and draws the one of
   the applied commit (`plugin/src/RegionQueue.cpp`). After: 40 of 40 toggles and 12 of 12 close-then-open reopens
   1.090 1.071 1.048 1.033 1.017 1.010 1.002 (trace boxes 1.090 1.069 1.049 1.032 1.018; Mac 1.088 1.068 1.050 1.033
   1.019 1.009). Not checked: over a Settings window, scale 1.6, light mode.
8. FIXED (2026-11-14, judge #13 item 5, first part). Emoji & Symbols picker over an app: Settings and Finder took
   the inactive look (grey traffic lights, grey sidebar selection) because the picker layer takes the keyboard; the
   Mac's palette leaves the app key. They now keep the active look while the `hyprk-emoji` layer is open over them
   (Hyprland openlayer / closelayer events, `shell/FALLBACKS.md`). The plugin title bar already stayed active. Seen in
   a headless session (scale 2, dark): Settings and Finder active with the picker open, typing "dog" in its search
   field works, Return pastes the dog into foot. Not done: other apps (GTK, foot's hollow cursor) still look unfocused.
9. FIXED (2026-11-14, judge-95-14 change 1). Text field menu (ui/HyprK/TextMenu.qml) was an opaque flat panel (about
   44 grey, `judge-95-14/06`); the Mac's is an NSMenu with the `menu` glass (Q-menubar-13). It now draws no fill when
   `Tokens.popupGlass` is set (Finder: plugin enabled; Settings: HYPRK_GLASS=plugin) and the plugin's client-popup glass
   draws the shell menus' material, radius 12 and shadow behind it (`popup_classes` now also lists org.hyprk.Settings,
   config/hypr/hyprland.lua). Headless, scale 2, Settings search field, against the shell's desktop menu opened at the
   same place over the same window: body (58,59,67) / (57,59,66) vs (58,59,66) / (58,59,65) dark, (251,252,254) vs
   (251,253,253) light; shadow under the bottom edge -6 decaying to -1 over 27 px in both. Width 198 pt with "Paste and
   Match Style" ending 48.5 before the edge (change 2's column). Open: the shell's own fields (Spotlight, Emoji picker
   search) now have the menu but it stays opaque: their layer surfaces' popups get no plugin glass (no plugin change
   this round); without the plugin, under Reduce Transparency or Increase Contrast the opaque fill as before.
10. FIXED (2026-11-14, judge-95-14 change 2). Menus with a submenu row now keep the submenu column on every row:
   every row ends 48 pt before the edge (`lib/menus.js rowEnd`, Theme.menu.submenuTrailing; HyprK textmenu.js rowEnd).
   Source: desktop menu 198.5 pt with "Change Wallpaper…" 48.4 from the edge (`menubar/context-dark.png`), Dock menus
   Notes 111 / Calculator 174 (`live/dock/dock-menus.json`). Desktop menu (stacks off, no state column): 151 -> 184.5 pt,
   "Change Wallpaper..." ink 18 -> 49 pt from the edge (Mac 49.5), chevron centre 23 from the edge (Mac 23.5); with the
   Mac's state column (+14) that is the Mac's 198.5. Finder's PopupMenu keeps its own rule (200 minimum): not changed.
11. CHECKED (2026-11-14, judge-95-14 change 3). Emoji picker tail: present in every open path (IPC toggle, the
   Ctrl-Cmd-Space global, pointer anywhere); the judge's case was the tail over the Dock's black Terminal icon, where
   our 31-grey arrow had only the dark outer rim. The light inner rim now runs around the arrow too (`lib/emoji.js
   popoverPath`): arrow edge 51-56 over the icon (Mac 70-73 over black, `panels/emoji-picker-dark.png`; body side 56 on
   both). Not done: anchoring at the caret (no app reports one: Wayland gives the shell no caret position).
12. FIXED (2026-11-14, judge-95-16 change 6). Notification Centre's photo widget took the first file `find` listed in
   ~/Pictures and showed an empty card when Qt could not decode it. Now it lists up to 20 candidates (then a wallpaper)
   and moves to the next on `Image.Error`; with none left the card shows the session's wallpaper. Headless (scale 2,
   dark, ~/Pictures with an undecodable `aaa-broken.jpg` listed first and a good jpg): before an empty dark card, after
   the good picture. The Mac's Photos widget empty state was not compared (no capture).

## Checked, no difference (<= 1 pt / <= 4 levels)
- Control Center grid: right margin 14, top 46 (12 under the 34 bar), tiles 140 x 64 / 64 / 140 x 140 / 292 x 64, gap 12,
  Edit Controls 16-17 below the last row (Q-panels-04, -05; `panels/controlcenter-dark.png`). 2x1 circle 35-36 at 14.
  Display and Sound slider: track 4 tall, centre 41.5 below the module top (Mac 42), Display track x 37..253.5 (Mac
  36.5..254). "Not Playing" title and media glyph rows within 1 pt.
- Control Center Sound module (opened with the output button, dark): panel x 964..1272 (308 wide, 8 from the edge),
  top 40.5, title 14 in, device rows pitch 32, 1 pt separators (Mac 308 / 8 / 40 / 14 / 32, Q-panels-12). Its height
  (193, two devices) is not comparable with the Mac's 258 (more devices).
- Control Center pill on the menu bar: y 5..28.5, width 45.5 (Mac AX 26 + 2 x 10 = 46, y 5..29).
- Menu bar right side (`menubar/bar-dark.png`): Control Centre glyph ink 13.5 wide, y 10.5..23.5 (Mac 13, 10.5..23.5);
  Control Centre ink to clock ink 23 (Mac 23); clock ink ends 21 from the screen edge (Mac 21.5), digit ink y 12..21
  (Mac 11.5..21).
- NC: card 344 wide at 16 from the screen edge; text frame 58.5 from the card edge (Mac 58); "now" 15 from the right
  (Mac 14); collapsed stack plate 8 pt (Mac 8 each); heading ink width 153 (Mac 156 for "Centre").

## Not compared
- Glass colours of CC tiles, NC cards and pills (no shot of ours over the Mac's solid backdrops this round).
- CC module panels (Sound / Display sub-panels), CC hover / pressed states, status-item hover (Mac: none) and the
  Battery item (the test output has no battery), light-mode menu bar ink levels, NC hover state and "Edit Widgets",
  scale 1.6.
