# Answers from the Mac session, round 18 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #189 from the PC. Capture only. Files under `re/27.2.1/live/r18/`. Display 1440x932 at 2x, Stage Manager off,
desktop icons hidden, flat PNG wallpapers made for the round: white (255,255,255), blue (0,0,255), dark (30,30,32).
Frames are screen points; all PNGs are `screencapture` output at 2x (lossless), not video frames.

## R18.1 Mission Control, Spaces bar expanding: done
- `mc-spaces-bar-expand-dark.mov`: 60 fps (variable frame rate, frames only when the screen changes), region
  0,0 1440x870 pt (the Dock is cropped off), dark mode over the flat dark wallpaper, one desktop, three windows
  (two empty TextEdit documents and Calculator). `mc-spaces-bar-rest-dark.png` and `mc-spaces-bar-expanded-dark.png`
  are stills of the two end states (same crop).
- What the pointer did (recorder clock): 1.36 s jump to (720,120), below the bar; **2.03 s** jump to (720,60) then
  (720,40), inside the bar; 4.73 s jump back down to (720,500); Escape at about 7.9 s.
- Bar height, read from the bottom edge of the bar at x = 110 pt on every frame:

| time | height |
|---|---|
| up to 2.100 s | 68 pt (rest) |
| 2.117 | 70.5 |
| 2.133 | 86.5 |
| 2.150 | 95.5 |
| 2.183 | 104.5 |
| 2.200 | 113 |
| 2.217 | 120.5 |
| 2.233 | 127.5 |
| 2.250 | 133 |
| 2.267 | 138 |
| 2.283 | 142 |
| 2.300 | 145.5 |
| 2.317 | 148 |
| 2.350 | 152.5 |
| 2.400 | 156 |
| 2.450 | 158 |
| 2.500 | 159 |
| 2.600 | 160 (final) |

  So on this display the bar goes **68 → 160 pt** (+92 pt), starting about 85 ms after the pointer entered, most of
  the way in 200 ms and settled after about 480 ms.
- The bar **stays expanded** after the pointer leaves it (no change between 2.6 s and the Escape).
- Windows below, from the two stills (approximate, read at 1x): the two windows in the top row move down by about
  92 pt with the bar (top edge 108 → 200) and keep their size; the large window lower down is squeezed slightly instead
  (top 390 → 393, bottom 873 → 867). The clip shows the in-between frames.
- At rest the bar shows only the label "Desktop" in a small capsule and a "+" at the right; expanded it shows the
  desktop thumbnail (about 146x96 pt, blue ring on the current one) with the label under it, "+" moved down.

## R18.2 Notification banner and Notification Centre card over white and blue: done
- `banner-{dark,light}-{white,blue}.png`: the banner about 2 s after `display notification "Test" with title "Test"`
  (sender is Script Editor). Crop is 400x120 pt (800x240 px) with its top-left at (1040,30) pt.
- `nc-card-{dark,light}-{white,blue}.png`: the same notification as a card with Notification Centre open (opened with
  a click on the clock). Each crop is 400 pt wide from x = 1040 pt and holds **only the test card**; the height differs
  per file because the cards above and below were real notifications and were left out: dark-white y 30..118,
  dark-blue y 102..167 (the test card was second in the list there), light-white y 30..103, light-blue y 30..118.
  With Notification Centre open, the backdrop behind the cards is dimmed/tinted by the panel, so it is no longer
  the pure wallpaper colour (visible in the crops).
- Frames: banner and card are both at x 1080..1424 (**344 pt wide**), **57 pt tall** for this two-line content, top at
  y = 42 pt. In Notification Centre the cards repeat every **64 pt** (7 pt gap).

## R18.3 Control Centre Sound slider, knob held and during a slow drag: done
- `cc-sound-{dark,light}-{dark|white,blue}-{idle,hover,held,drag1,drag2,drag3}.png`: region 260x80 pt (520x160 px)
  around the slider, top-left at (1128, slider centre − 40). Backdrops: dark mode over flat dark and over blue, light
  mode over white and over blue.
  - `idle`: Control Centre open, pointer 60 pt below the slider (no knob, just the fill).
  - `hover`: pointer resting on the fill end (white capsule knob).
  - `held`: mouse down on the knob for 1.0 s without moving (the glass lens).
  - `drag1/2/3`: taken about 1.0, 1.6 and 2.2 s into a 4 s drag of 60 pt to the right (15 pt/s), mouse still down.
- Slider from AX (`sound volume`): frame x 1168, width 180, height 14; its centre y was 463 (dark over dark) and 491
  (the other three, one more row in the panel); value 0.38, so the knob centre was at x = 1238.
- The drag went back to the start before release and the volume was set to 38 again afterwards.

## Not done / notes
- Mission Control was recorded with one desktop only (no second Space, no full-screen app).
- Light mode was not asked for in R18.1 and was not recorded.
- The test notifications (five, from Script Editor) were left in Notification Centre.

## State after the round
Wallpaper store copied back + `killall WallpaperAgent`, the flat wallpapers moved out of `~/Pictures`, TextEdit and
Calculator quit, Stage Manager on, `CreateDesktop` deleted + Finder restarted, dark mode, display 1710x1107, volume 38.
