# macOS 27.2.1 lock screen crops

Source: the PC #73 lock recordings (dark.mp4, light.mp4, saver.mp4; 3420x2214, 60 fps, no cursor) and the
full-resolution screenshots dark-sc3.png / light-sc3.png. Full spec: reference/re/LOCKSCREEN-27.2.1.md.
Pixel crops are 2x (1 pt = 2 px) unless the name says 1x. Video crops went through H.264 (4:2:0), so colours in
them are approximate. The screenshot crops (clock-date-*, status-items-*) are lossless Display P3 values.

Privacy: the user avatar was covered, never saved. Where a crop shows the full typed password as dots, the
dots are covered too (that row shows the real password length).

| file | source | what | blanked |
|---|---|---|---|
| clock-date-dark.png | dark-sc3.png px 1200,150 to 2220,560 | date + 09.07 clock, dark (TahoeDark) | none |
| clock-date-light.png | light-sc3.png same box | date + 09.12 clock, light (TahoeLight) | none |
| status-items-dark.png | dark-sc3.png px 2600,0 to 3420,60 | top-right status items; "Your screen is being observed" exists only because of the recording | none |
| field-dark-1char.png | dark.mp4 t=19.80 s, px 1500,1970 to 2000,2110 | field with one dot + caret, arrow button, "?" button, Touch ID line | none (avatar is above the box) |
| field-light-1char.png | light.mp4 t=16.20 s, same box | same, light appearance | none |
| field-light-capslock-empty.png | light.mp4 t=10.00 s, same box | empty field, placeholder, caret, Caps Lock glyph in place of the arrow | none |
| field-dark-verifying.png | dark.mp4 t=10.60 s, same box | after Return: dots dimmed, caret gone, "?" dimmed | dots row covered by a grey rectangle (crop px 60,28 to 330,62) |
| field-dark-spinner.png | dark.mp4 t=11.60 s, same box | ~1 s after Return: spinner replaces the Touch ID line | dots row covered (same rectangle) |
| shake-dark-arrow-hint-per-frame.png | dark.mp4 18.333 to 18.80 s, px 1840,1975 180x75, one row per frame | right end of the field and the "?" button during the wrong-password shake | none (dots are outside the box) |
| minute-change-light-strip.png | light.mp4 4.50 to 5.20 s, px 1720,280 420x270, every 4th frame, 0.5x | minute change 09.11 -> 09.12 (per-digit transition) | none |
| full-dark-locked-1x.png | dark.mp4 t=5.0 s, downscaled to 1710x1107 | whole lock screen, dark | avatar covered by a grey square (pt 815,915 to 895,990) |
| full-light-locked-1x.png | light.mp4 t=8.0 s, 1x | whole lock screen, light | avatar covered (same square) |
| full-saver-locked-1x.png | saver.mp4 t=16.0 s, 1x | lock UI drawn over the running screensaver (Peanuts saver) | avatar covered (same square) |
