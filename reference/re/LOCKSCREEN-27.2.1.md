# macOS 27.2.1 lock screen, measured

Measured on the PC from the Mac recordings of PC #73 part 1 (lock-raw-27.2.1.tar: dark.mp4, light.mp4,
sleep.mp4, saver.mp4, dark/light-sc3.png, dark/light-ax.jsonl). Display 1710x1107 pt at 2x. All geometry in pt from
the top-left of the screen (px / 2). Times in seconds of the recording; "+N ms" is relative to the first changed
frame of an event. Crops: reference/screens/27.2.1/lock/ (INDEX.md). Earlier partial answers:
MAC-ANSWERS.md "Lock screen (PC #73 part 1, partial)"; this file supersedes their "not measured" items.

## 0. Method and limits

- Videos: H.264 4:2:0, 3420x2214, nominally 60 fps but variable: 4339 frames in 75 s for dark.mp4. Real frame
  times come from the packet pts. Frames are missing at the lock switch in dark.mp4 (2.300 to 2.433 has 4 frames
  for 9 slots); light.mp4 has none missing there, so the lock-in fit uses light.mp4.
- Colours from the videos are approximate (limited-range YUV decoded with ffmpeg defaults, no colour tag,
  chroma subsampled). The two screenshots (sc3) are lossless and tagged Display P3; their 8-bit values are quoted
  as "P3". Geometry comes from the screenshots where possible.
- Ink boxes: difference between a locked frame and the unlocked desktop frame of the same video (same wallpaper),
  threshold 25/255 on the max channel, then column/row runs. Sub-pixel accuracy: ±0.5 pt.
- Curves: least-squares fit of normalised progress (0 = start state, 1 = end state, projected per region onto
  end-minus-start) against linear, ease-in/out quad/cubic, CSS ease (0.25,0.1,0.25,1), ease-in-out (0.42,0,0.58,1),
  and exp-out families with free start time and duration. rms is in progress units (0..1).
- Fonts: rendered from the 27.2.1 system volume (141-12228-174.dmg, read-only apfs-fuse) with FreeType and fitted
  to the measured ink.

## A. Static layout

### A1. Wallpaper

| | dark (TahoeDark) | light (TahoeLight) | how |
|---|---|---|---|
| blur | none | none | edge profiles of the wave line identical by eye at 4x; gradient energy not lower in light |
| zoom / offset | none (0 px at 8 probes) | none (0 px at 7 of 8 probes; the 8th has no texture) | phase correlation, 512 px patches, locked vs desktop frame |
| darkening | locked = 0.95 x desktop (R 0.956, G 0.947, B 0.945, offsets < 5/255) | locked = 0.90 x desktop + ~5/255 (R 0.908, G 0.894 +5.5, B 0.913 +6.5) | per-channel linear fit over the whole frame, UI and desktop items masked |
| as an overlay | black at alpha ≈ 0.05 | black at alpha ≈ 0.09 with a slight lift | |

Uncertainty ±0.01 on the factors (video colour). The darkening is uniform top to bottom within ±0.02 (dark) and
±0.05 (light; top band 0.94). Tint: no colour shift beyond the factors above. The lock screen therefore shows
the same sharp desktop wallpaper, very slightly dimmed. With a screensaver running the saver keeps playing behind
the lock UI (section B5).

### A2. Date

- Text "Wed 11 Nov" (abbreviated weekday, day, abbreviated month; en-ID locale order), centred on x 855.
- Ink: x 775.5 to 935.0 (w 159.5), cap top y 107.0, baseline y 130.0, cap height 23.0 pt. AX frame x 772 y 98.5
  w 166 h 39.
- Font: SF Pro (SFNS.ttf) Semibold, 32.5 pt (±0.5; probably 32 or 33). Fit: cap height 23.0 needs 32.5 pt;
  the "1" stem is 4.0 pt = weight 590 to 600. At that size SF Pro renders the string 165.5 pt wide, the ink is
  159.5, so tracking is about -0.6 pt per character (or a narrower width instance; not resolved).
- Colour: the same additive "lighten" treatment as the clock, stronger. Dark: backdrop (20,5,124) becomes
  (147,131,250), so about +127/255 on R and G, blue clipped. Light: backdrop (135,174,207) becomes (212,254,253),
  near white with a cyan cast. Flat within the glyphs (rms 2.4/255).
- Gap: date baseline 130 to clock ink top 152 = 22 pt.

### A3. Clock

- "09.07" (dark) and "09.12" (light): 24 h, leading zero, separator "." from the locale. Centred: ink centre x
  857 (09.07) and 855 (09.12). Proportional: the AX frame width follows the digits (395 vs 361).
- Ink (dark, 09.07): 0 x 664.0 to 749.5 | 9 x 759.0 to 845.0 | . x 850.5 to 874.0 | 0 x 882.0 to 968.0 | 7 x 972.0 to
  1050.0. Round digits y 152.0 to 265.0 (h 113 incl. overshoot), flat digits ("7" top, "1", "2" base) y 153.0 to
  263.0 (h 110). The period is a disc 23.5 pt wide, y 241.0 to 264.5, sitting on the baseline.
- Ink (light, 09.11 at 4.0 s): 0 x 694.0 to 780.5 | 9 x 789.5 to 875.5 | . + 1 x 880.5 to 953.0 | 1 x 958.0 to 1013.0.
- Stroke: the "0" stem is 21 pt (42 px) at mid height, both themes.
- Font: `.SF Soft Numeric`, the variable face index 2 of /System/Library/Fonts/ADTNumeric.ttc (axes Width 30-150,
  Weight 1-1000, SOFT 0-100 default 70, GRAD). Best fit: size 156 pt, Weight 600-650, Width 95, digit positions
  within ±3.5 pt, 0 width 84-85.5 (meas. 85.75), 7 width 74.5-75.5 (meas. 78), stem 20-21.5 (meas. 21), dot
  22-23.5 (meas. 23.5); fit error 4.9 (pt, combined). SOFT changes only corner rounding, not the box, so its value
  is not determined by these numbers; the rounded inner corners in the crops fit the default 70. For comparison
  SF Pro Rounded fits much worse (error 22.9, stem 16.5) and `.SF Adaptive Soft Numeric` worse still (33.5).
  The face is not on Linux: an implementation needs a fallback (SF Pro Display Semibold 156 pt is the closest
  widely available shape; SF Pro Rounded is not the right family).
- Glass inside the digits (lossless P3 screenshot): along a row the interior is flat ((128,107,255) dark,
  (250,255,255) light), and it follows the backdrop: where the wave line passes behind the "7" the interior goes
  to (80,97,196) / (136,142,255). Per pixel, locked = backdrop + about (+89, +80, +88) on 0..255, clipped, in both
  themes (dark backdrop (39,27,167) gives (128,107,255); light (169,178,192) gives (250,255,255)). Video fit over
  the first "0": R slope 1.2, offset +72; G 1.1, +67; B clipped; rms 8-9. So: an additive (plus-lighter) white
  of about 0.33, not a flat white with alpha and not a screen blend (screen would lower the slope). Top to bottom
  the interior only changes with the backdrop (R 111 to 133 in the dark "0" where the backdrop goes 29 to 48).
- Edges: 1 px (0.5 pt) dark outer rim (backdrop -15/255); a 1 px white specular line on the top edge, fading into
  the fill over about 6 pt ((255,255,255) to (170,149,255) to (117,102,255) down the top of the "0"). Refraction:
  the wave line behind the "0"/"7" shows bent and brightened inside the digits (see clock-date-*.png); its
  displacement was not measured.

### A4. Avatar and name

- One disc, diameter 55.0 pt (x 827.5 to 882.5), centre (855, 953), top 925.5, bottom 980.5. Hard edge (the disc
  starts in one pixel), no ring, no shadow (the backdrop below it is unchanged from 1 px under the edge).
- No user name is shown (none in pixels or in the AX tree).
- Avatar to field gap: 980.5 to 992.5 = 12 pt.

### A5. Password field, buttons, caps lock

| item | value | how |
|---|---|---|
| capsule | x 775.0 to 936.0 (w 161), y 992.5 to 1021.0 (h 28.5), radius 14.25 (full capsule), centre x 855.5 | profile in dark-sc3 |
| AX | text field x 788 y 997.5 w 117 h 18; LUIBUTTON_GO x 906 w 30; LUIBUTTON_PASSWORD_HINT x 940 w 30 | AX |
| fill, dark | (81,79,159) over a backdrop of about (0,7,75) (video), P3 (94,95,169) over (2,9,82): about +0.3 additive lilac, the same family as the clock | samples |
| fill, light | (18,20,122) over (0,18,121) (video), P3 (20,30,132): almost no lift; the capsule is barely visible on the light wallpaper's dark-blue bottom | samples |
| placeholder | "Enter Password", shown when empty, left edge x 792.5, ink y 1002 to 1011.5; SF Pro ~13 pt (±0.5); low contrast (64,69,180) on (17,20,124) in light | light.mp4 10.0 s |
| caret | 2 pt x 16 pt (y 998.5 to 1014.5), at x 787 when empty; blinks 0.6 s on / 0.4 s off when idle (2.40 on, 3.02 off, 3.42 on, 4.02 off, 4.42 on); stays on while typing (no blink in 0.6 s pauses); hidden while verifying | light.mp4 |
| dots | about 5 pt discs (5.5 wide x 4.5 tall at the threshold), pitch 8.25 pt, first dot left edge x 790.5 (centre 793.3, 18.3 from the capsule edge), vertically centred (y 1004.5 to 1009); colour P3 (196,198,255) dark | dark-sc3 |
| return arrow | a ~22 pt circle outline (2 pt stroke) with an arrow glyph, at the right end inside the capsule (centre x ≈ 921); P3 ring (146,146,219) on the fill; present only when the field has text | dark-sc3 and the crops |
| Caps Lock | a filled up-arrow glyph 12.5 x 12.5 pt at x 906 to 918.5, y 1000 to 1012.5, in the arrow's place when the field is empty; appears and disappears with the key in one frame | light.mp4 4.9 / 5.4 / 6.9 / 8.1 / 8.9 / 14.4 s |
| "?" hint button | always shown: a dark disc 29 pt (x 941 to 970, y 992.5 to 1020.5, P3 (20,21,93) dark) with a 22 pt ring (2 pt stroke) and "?" glyph, P3 (145,145,217); centre x 955.5 | dark-sc3 |

The hint popover was not seen: the "?" was never activated in light.mp4 (no change anywhere outside the field
except the clock). Hint text, its box and its animation remain unknown.

### A6. Line under the field

- "Touch ID or Enter Password", always shown, centred (ink x 774 to 937, w 163). Cap top y 1031.75, baseline
  y 1040.5, cap height 8.75 pt. AX x 771.5 y 1027.5 w 167.5 h 17. Field bottom to cap top: 10.75 pt.
- Font: SF Pro ~12.5 pt Medium (wght 500 renders 163.2 wide at the measured cap height; 590 gives 164.0, 700
  gives 167.6). Colour P3 (147,165,250) dark, (146,182,255) light: a lilac/blue vibrant label.
- During password verification the line is replaced by a small spinner (about 15 pt, centred x 855, y ≈ 1041).

### A7. Status items (top right) and the rest of the screen

- AX, right to left: Wi-Fi menu button x 1665 y 9.5 w 26 h 15; battery image x 1625 y 9 w 28 h 16 ("battery
  charged 100%" glyph with bolt); "ABC" input-source button x 1559 y 8 w 54 h 18 (text + keyboard glyph). Right
  margin 19 pt, gaps 12 pt. A "Your screen is being observed" item (x 1337 w 185) is there only because of the
  recording. White-ish, no menu bar background.
- No normal menu bar, no Dock, no Sleep / Restart / Shut Down, nothing at the bottom of the screen, no
  notifications or widgets were visible in any recording (the desktop widgets are covered by the loginwindow
  window).

### A8. AX tree (both themes identical except the clock width)

```
AXApplication (loginwindow)
 AXWindow 0,0 1710x1107 (layer 2004; a second 30000x30000 shield window at layer 2001)
  AXMenuButton  1665,9.5 26x15        Wi-Fi
  AXImage       1625,9 28x16          battery
  AXButton      1559,8 54x18          "ABC"
  AXStaticText  1337,8 185x18         screen-recording notice (recording only)
  AXStaticText  772,98.5 166x39       "Wed 11 Nov" (id LargeDate)
  AXGroup/AXHostingView 657.5,115 395x185   (light: 674.5,115 361x185)
   AXStaticText                       "09.07" / "09.12"
  AXScrollArea  227.5,573.5 1255x414  (user list, one user)
   AXButton     227.5,573.5 1255x414  (user tile; label withheld)
   AXScrollBar  226.5,969.5 1257x19
  AXTextField/AXSecureTextField 788,997.5 117x18
  AXButton      906,998 30x17.5       LUIBUTTON_GO
  AXButton      940,998 30x17.5       LUIBUTTON_PASSWORD_HINT
  AXStaticText  771.5,1027.5 167.5x17 "Touch ID or Enter Password"
```

## B. Transitions

### B1. Lock from the desktop (^⌘Q)

light.mp4, t0 = 2.033 (first changed frame; the keystroke was sent at about 2.0 s). Progress 0 = desktop,
1 = locked, per region.

| t | +ms | menu bar gone | Dock gone | widgets | wallpaper dim | clock | date | field | avatar | status items |
|---|---|---|---|---|---|---|---|---|---|---|
| 2.033 | 0 | 0.10 | 0.10 | 0.10 | 0.11 | 0 | 0 | 0 | 0 | 0.04 |
| 2.050 | 17 | 0.26 | 0.21 | 0.17 | 0.17 | 0 | 0 | 0 | 0 | 0.10 |
| 2.067 | 33 | 0.57 | 0.36 | 0.28 | 0.23 | 0.28 | 0.26 | 0.21 | 0.24 | 0.29 |
| 2.083 | 50 | 0.84 | 0.59 | 0.41 | 0.29 | 0.35 | 0.33 | 0.26 | 0.30 | 0.35 |
| 2.100 | 67 | 0.96 | 0.74 | 0.53 | 0.38 | 0.43 | 0.40 | 0.35 | 0.36 | 0.33 |
| 2.117 | 83 | 0.97 | 0.81 | 0.63 | 0.43 | 0.51 | 0.47 | 0.42 | 0.42 | 0.32 |
| 2.133 | 100 | 0.97 | 0.89 | 0.71 | 0.49 | 0.59 | 0.54 | 0.52 | 0.49 | 0.66 |
| 2.150 | 117 | 0.98 | 0.96 | 0.78 | 0.58 | 0.66 | 0.60 | 0.56 | 0.55 | 0.71 |
| 2.167 | 133 | 1 | 0.96 | 0.79 | 0.63 | 0.73 | 0.67 | 0.63 | 0.62 | 0.76 |
| 2.183 | 150 | 1 | 0.97 | 0.84 | 0.70 | 0.80 | 0.73 | 0.70 | 0.69 | 0.81 |
| 2.200 | 167 | 1 | 1 | 0.88 | 0.75 | 0.87 | 0.80 | 0.78 | 0.76 | 0.85 |
| 2.217 | 183 | 1 | 1 | 0.92 | 0.85 | 0.92 | 0.86 | 0.85 | 0.82 | 0.90 |
| 2.233 | 200 | 1 | 1 | 0.95 | 0.89 | 0.96 | 0.92 | 0.90 | 0.89 | 0.93 |
| 2.250 | 217 | 1 | 1 | 0.99 | 0.94 | 0.99 | 0.98 | 0.96 | 0.97 | 0.98 |
| 2.267 | 233 | 1 | 1 | 1 | 1 | 1 | 0.99 | 0.99 | 1 | 0.99 |

Fits:
- Lock UI (clock, date, field, avatar, status, all together): opacity in from +7 ms, ease-out quad, 250 ms
  (rms 0.034); ease-out cubic 320 ms is as good (0.035); CSS ease 315 ms 0.045. No scale or offset: the clock ink
  box is at its final place in the first visible frame.
- Menu bar out: ease-in-out, 100 ms (quad, rms 0.020; cubic 135 ms same rms). Opacity only.
- Dock out: CSS ease (0.25,0.1,0.25,1), 190 ms (rms 0.022). Opacity only; it does not slide.
- Desktop widgets and icons: fade with the wallpaper dim, ~230 ms.
- Total: about 235 ms from the first change to the final frame. The desktop windows had been hidden before the
  recording, so a window's own exit was not seen (belum diukur).
- dark.mp4 shows the same order (menu bar 2.18 to 2.27, Dock 2.18 to 2.35, UI 2.30 to 2.43, status items appear
  at 2.433) with dropped frames, so it is not used for the fit.

### B2. Wrong password

Sequence (dark.mp4, two attempts; light.mp4 the same):

| t (1st / 2nd try) | event |
|---|---|
| 10.300 / 16.300 | Return: dots dim (video level 155 to 103 in light), caret hidden, arrow ring and "?" dim; field stays |
| 11.27 / 17.27 | ~0.97 s later the Touch ID line is replaced by a spinner |
| 12.433 / 18.367 | ~2.1 s after Return (PAM delay): the spinner goes, the line comes back, the dots come back at full strength and are shown SELECTED (a light lilac selection band x ≈ 783 to 900 behind the dots), and the shake starts |
| 12.817 / 18.767 | shake ends (400 ms) |
| 14.18 / 19.68 | the next key replaces the selection (field cleared to that one character); no timer clears it |

No red tint, no "incorrect password" text, no colour change of the capsule beyond the selection band.

Shake: the capsule, its arrow button and the "?" button move together, horizontally. The avatar (checked, 0 pt)
and the Touch ID line (checked by eye per frame) do not move.

Per-frame offset in pt (second attempt, the cleaner one, 16.7 ms steps from 18.350):

| frame | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dx | 0 | -8.5 | -14 | -11 | -1.5 | 8.5 | 14 | 11 | 1.5 | -8.5 | -14 | -11 | -1.5 | 5.5 | 9 | 6.5 | 1 | -5 | -7.5 | -6 | -1 | 4.5 | 6.5 | 5 | 1 | 0 |

First attempt (from 12.417): 0, -13.5, -13.5, -6.5, 4.5, 12.5, 13.5, 6.5, -4.5, -12.5, -13.5, -6.5, 3, 8, 8.5, 4, -2.5,
-7, -7, -3.5, 2, 6, 6.5, 3, 0 (same shape, sampled one phase step later).

Model: dx(t) = -A(t) * sin(2π * 7.5 Hz * t), 0 <= t <= 0.400 s (exactly 3 cycles, 8 frames per cycle), first move to
the LEFT; A = 14.0 pt for t < 0.200, 8.25 pt for 0.200 <= t < 0.333, 6.75 pt for 0.333 <= t <= 0.400; then 0.
rms 0.44 pt (2nd attempt), 1.02 pt (1st). A smooth damped sine fits worse: A = 16 * e^(-t/0.5 s), 7.5 Hz,
rms 1.05 pt. The envelope steps at half-cycle zero crossings, so it reads as keyframes (-14, +14, -14, +8.25,
-6.75, +6.75 at the peaks) rather than a spring.

### B3. Correct password and unlock

dark.mp4: Return at 23.000 (status items and field react), unlock starts at 23.367 (367 ms after Return).

| t | +ms | clock | date | field | avatar | menu bar back | Dock back | wallpaper un-dim |
|---|---|---|---|---|---|---|---|---|
| 23.350 | -17 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |
| 23.367 | 0 | 0.94 | 0.93 | 0.91 | 0.05 | 0.07 | 0 | 0.04 |
| 23.400 | 33 | 0.84 | 0.82 | 0.76 | 0.04 | 0 | 0 | 0.19 |
| 23.417 | 50 | 0.80 | 0.76 | 0.69 | 0.04 | 0 | 0 | 0.22 |
| 23.433 | 67 | 0.75 | 0.69 | 0.63 | 0.03 | 0 | 0 | 0.26 |
| 23.450 | 83 | 0.70 | 0.61 | 0.56 | 0.03 | 0 | 0.02 | 0.30 |
| 23.467 | 100 | 0.64 | 0.54 | 0.49 | 0.03 | 0 | 0.02 | 0.33 |
| 23.483 | 117 | 0.57 | 0.47 | 0.43 | 0.02 | 0 | 0.04 | 0.41 |
| 23.500 | 133 | 0.48 | 0.40 | 0.36 | 0.02 | 0.03 | 0.09 | 0.47 |
| 23.517 | 150 | 0.40 | 0.32 | 0.30 | 0.02 | 0.12 | 0.21 | 0.58 |
| 23.533 | 167 | 0.31 | 0.25 | 0.24 | 0.01 | 0.23 | 0.35 | 0.65 |
| 23.567 | 200 | 0.15 | 0.11 | 0.11 | 0 | 0.59 | 0.72 | 0.84 |
| 23.583 | 217 | 0.06 | 0.05 | 0.04 | 0 | 0.74 | 0.88 | 0.90 |
| 23.600 | 233 | 0 | 0 | 0 | 0 | 0.90 | 1 | 0.92 |
| 23.633 | 267 | 0 | 0 | 0 | 0 | 1 | 1 | 0.94 |
| 23.700 | 333 | | | | | | | 0.97 |

(clock/date/field: remaining opacity; menu bar/Dock/wallpaper: progress back to the desktop.)

Fits and observations:
- Avatar, Touch ID line, status items: gone in one frame at +0 (no fade).
- Clock, date, field, "?": opacity out, ease-in quad, 310 ms starting 87 ms before the first visible change
  (rms 0.017); seen as ~233 ms. Linear 225 ms: rms 0.030. No scale, no offset: the clock ink box stays at
  x 664 to 1049, y 152 to 265 through the fade.
- Menu bar in: ease-in-out quad, 165 ms from +111 ms (rms 0.021). Opacity only.
- Dock in: ease-in quad 135 ms from +89 ms (rms 0.016) or ease-in-out 150 ms (0.018). Opacity only, no slide.
- Wallpaper un-dim: ~0.33 s, mostly in the first 0.2 s.
- Desktop windows: none were open (not measured). Total visible: about 270 ms (+0 to the menu bar's end).
- light.mp4 unlock (23.967 to 24.35): same pattern, not fitted separately.

### B4. Display sleep and wake (sleep.mp4)

- `pmset displaysleepnow` at ~2 s. The screen capture keeps delivering the last desktop frame while the panel is
  off, so the sleep fade and the backlight are not visible in the recording (belum bisa diukur).
- Wake at 18.233: 15 frames (0.25 s) of pure black, then at 18.483 the complete lock screen in one frame (clock,
  field, avatar, status items all at full opacity; no fade, no wallpaper motion).
- Unlock 30.067 to 30.267: the same as B3 (clock fades over ~0.2 s, menu bar back by 30.27).

### B5. Screensaver and lock (saver.mp4)

- Desktop to saver: the whole screen fades to black, about linear, 217 ms (2.350 to 2.567: 73, 63, 53, 48, 43,
  38, 33, 28, 28, 19, 15, 10, 5, 0 mean level). Black for 0.5 s, a uniform grey frame for 0.1 s (3.067 to 3.167),
  then the saver content.
- Key press while the saver runs: the lock UI is drawn OVER THE RUNNING SAVER (it keeps animating behind the
  clock and field). The UI appears in one frame at 15.367 (no fade); the status items follow at 15.467 (+100 ms).
  The clock and field take the saver's colours (pink on the Peanuts saver) through the same additive treatment.
- Unlock from the saver: at 21.633 the saver is gone and the desktop rises from black, linear, ~217 ms (21.617
  to 21.833; mean level 10, 19, 24, 28, 33, 38, 42, 47, 52, 57, 62, 67, 73). The lock UI fades with it.

### B6. Typing, caps lock, hint

- Each dot appears at full strength in the frame after the key, the caret jumps by one pitch in the same frame;
  no fade, scale or slide of the dot (light.mp4 16.167 to 16.767, 12 keys).
- The first key hides the placeholder in the same frame. The arrow button appears with the first character
  (field-*-1char.png), no animation seen.
- Caps Lock glyph: appears and disappears in one frame (only seen with an empty field).
- Hint "?": not exercised (see A5).

### B7. Idle

- No fade of the field, avatar or clock while idle: 8.8 s in sleep.mp4 (18.48 to 27.25), 4.6 s in dark.mp4. Longer
  idle (the lock screen's own display-sleep timer) was not recorded.
- The caret blinks (0.6 on / 0.4 off) while idle.

### B8. Minute change (light.mp4 4.533 to 5.183)

- Only the changing digit animates, for about 650 ms. The old "1" fades from its bottom up while the new "2"
  is revealed from the bottom with a soft gradient mask, its top still faint at +600 ms
  (minute-change-light-strip.png); this looks like a SwiftUI numeric-text content transition. The other digits
  slide sideways to re-centre the string: the first "0" left edge moves from 694.3 to 683.5 in the first ~150 ms
  and ends at 680.5. The exact per-frame curve was not resolved (the edge tracker was disturbed by the wave line).

## C. What could not be determined

- Window exit on lock and window entrance on unlock (no windows open), Dock/menu bar on a desktop with apps.
- The hint popover (text, box, timing), Touch ID prompt (no Touch ID sensor used), lockout after many attempts.
- The display-sleep fade and the wake fade of the panel (not visible to screen capture).
- Notifications, Now Playing and widgets on the lock screen (none present).
- The clock's refraction displacement and the exact SOFT axis value; date tracking vs width.
- Field rim/shadow (if any) and the light-mode field recipe: the light capsule is nearly invisible on its backdrop.
- 12 h format.

## For the implementer

Differences between our lock screen (shell/modules/lock/LockTheme.qml, LockContent.qml, PasswordField.qml,
LockStatus.qml, LockOverlay.qml; lockscreen/hyprlock.conf carries the same guessed values) and 27.2.1:

1. Wallpaper: ours blurs (sigma 24, saturation 1.15) and dims black 0.16. Real: no blur, no zoom, black ≈ 0.05
   (dark) / ≈ 0.09 (light). The blurred-cache machinery (lock-wallpaper.sh, blurScale) is not needed for the look.
2. Clock font: ours SF Pro Rounded Bold 124 pt, white 0.95, top 118. Real: `.SF Soft Numeric` ~156 pt, Weight
   600-650, Width 95; ink top 152, baseline 263, centred on the screen; proportional digits with re-centring.
3. Clock colour: ours flat white 0.95. Real: additive white ≈ 0.33 over the wallpaper (plus-lighter, clipped),
   1 px white top highlight fading over 6 pt, 0.5 pt dark rim, slight refraction. In light it reads almost white
   with a cyan cast, in dark lilac.
4. Date: ours 24 pt Medium white 0.92 at top 92. Real: SF Pro Semibold ~32.5 pt, cap top 107, baseline 130, tracking
   ≈ -0.6 pt, additive tint ≈ 0.5 (stronger than the clock).
5. Avatar: ours 96 pt with a 0.30 black shadow (blur 16), bottom 132 above the screen bottom. Real: 55 pt disc,
   centre y 953 (bottom edge 126.5 above the screen bottom), no shadow, no ring.
6. Name: ours shows the user name at 17 pt. Real: no name.
7. Field: ours 210 x 36, 40 above the bottom, glass face white 0.10/0.20 with rims and shadow. Real: 161 x 28.5
   capsule, top y 992.5 (bottom edge 86 above the screen bottom), centred x 855.5; dark fill ≈ +0.3 additive
   lilac, light fill almost transparent.
8. Text inset: ours 14. Real: caret at 12 pt from the capsule edge, dots start 15.5 pt in.
9. Placeholder: ours 14 pt white 0.70. Real: ~13 pt, low-contrast tinted (light: (64,69,180) on (17,20,124)).
10. Dots: ours 7 pt + 4 spacing (pitch 11). Real: ~5 pt dots, pitch 8.25 pt, no appear animation.
11. Caret: ours 2 x 17, blink 530 ms half period for 10 s. Real: 2 x 16, 0.6 s on / 0.4 s off, solid while typing.
12. Return arrow: ours a 22 pt disc filled white 0.85. Real: a 22 pt ring (2 pt) with an arrow, inside the capsule at
    the right end, only when there is text.
13. Caps Lock: ours 15 pt glyph. Real: 12.5 pt filled up-arrow in the arrow's slot, only when empty.
14. Hint button: ours has none. Real: a separate 29 pt dark disc with a 22 pt ring and "?" at x 941 to 970, always
    shown, shakes with the field.
15. Line under the field: ours shows Lock.message (12 pt, white 0.80, 10 below the field) only when there is a message,
    with "Incorrect password", hint after 3 failures, "Too many attempts". Real: always "Touch ID or Enter Password"
    (~12.5 pt Medium, tinted lilac, cap top 10.75 below the field); a ~15 pt spinner replaces it ~1 s after Return;
    no wrong-password text was shown.
16. Verify state: ours dims the field to 0.45 while busy. Real: dots, arrow and "?" dim, caret hidden, then spinner.
17. Wrong password: ours shakes 450 ms, amplitude 14, 3 cycles, decay 1.6, then fades the dots and uses a red fail
    colour. Real: 400 ms, 7.5 Hz, 3 cycles, first move left, amplitude 14 / 8.25 / 6.75 pt (steps at 0.2 and 0.333 s);
    field + arrow + "?" move, avatar and text do not; the dots stay and are shown selected (next key replaces them);
    no red.
18. Lock-in: ours fades 400 ms CSS ease. Real: UI fades in ease-out quad 250 ms with no motion; menu bar out 100 ms
    ease-in-out, Dock out 190 ms ease; total ~235 ms.
19. Unlock: ours 350 ms ease with the clock rising 48 pt, the user block dropping 48 pt and a 4 % scale. Real: no
    motion and no scale; avatar, text and status items vanish at once; clock/date/field fade ease-in quad ~310 ms
    (233 ms visible); menu bar back ease-in-out 165 ms and Dock 135-150 ms near the end; total ~270 ms.
20. Status items: ours top 11, right 20, box 28, gap 10. Real (AX): Wi-Fi x 1665 w 26, battery x 1625 w 28, "ABC" +
    keyboard glyph x 1559 w 54, right margin 19, gaps 12, y 8 to 25.
21. Screensaver: the lock UI should draw over the still-running saver and appear without a fade; unlocking fades the
    desktop in from black over ~217 ms linear.
22. Wake from display sleep: show the lock screen complete at once (no fade in the framebuffer).
23. Minute change: animate only the changed digit (~650 ms numeric-text style) and re-centre the string.
