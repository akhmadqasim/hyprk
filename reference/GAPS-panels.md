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
4. OPEN. NC section "Clear All" circle: ours 24 (Theme code value from NotificationButtonStyle, MAC-ANSWERS "Buttons");
   Q-panels-32 AX says 28; the 1 px/pt overview reads about 20 tall (y 212.5..232.5). Three sources disagree: needs a
   2x Mac shot of the heading row.
5. OPEN, not ours to fix from data. Menu bar: our bar has a Spotlight item between Wi-Fi and Control Centre; the Mac's
   bar (`menubar/bar-dark.png`, menubar-metrics.json statusItems) shows Battery / Wi-Fi / Control Centre / Clock only.
   Whether 27.2.1 shows Spotlight by default is not in reference/.

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
