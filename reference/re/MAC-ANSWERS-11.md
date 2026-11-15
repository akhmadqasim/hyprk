# Answers from the Mac session, round 11 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#167, #168): Finder Gallery strip under the inspector (R11.1-R11.3), volume HUD
steps (R11.4), Finder Search button hover/press (R11.5), Icon & widget style tiles (R11.6), Mission Control Spaces bar
height (R11.7). Capture only. Conditions as before: 2x captures, display 1440x932 unless noted, Stage Manager off and
desktop icons hidden during the shots, Tahoe wallpapers, 60 Hz panel. "AX" = read from the AX tree, "px" = measured on
the 2x shots.

Dummy folder `~/Pictures/hyprk-gallery` (moved out again afterwards): the round 9 files plus four flat 800x800 PNGs,
`Flat-blue` (0,0,255), `Flat-green` (0,255,0), `Flat-red` (255,0,0), `Flat-white`. Sorted by name the strip is: Alpine,
Archive, Bloom, Brochure, Coast, Dunes, Flat-blue, Flat-green, Flat-red, Flat-white, icons, Notes, Projects (13 thumbs).
Finder draws the flat files as rgb **(1,0,245)**, **(117,251,76)**, **(233,51,36)** on this display (colour-managed),
so compare against those, not against the file values.

## R11.1 Gallery stills with the strip under the inspector: done
- `screens/27.2.1/finder/gallery/gallery-715x715-first-jpg-{light,dark}.png` (strip at offset 0, Alpine selected),
  `gallery-715x715-flat-red-{light,dark}.png` (Flat-red selected, strip scrolled),
  `gallery-1000x715-first-jpg-{light,dark}.png` (same thumbs in the clear, for reference).
- AX: `re/27.2.1/live/finder/gallery/ax-{715x715-first-jpg,715x715-flat-red,1000x715-first-jpg}-{light,dark}.jsonl`.
  Pixel table: `gallery-inspector-pixels.json`.
- Window **715x715 pt at 200,100** (715 is the minimum width with the inspector at 240 pt; I read "715 pt height" as
  this narrow window and made it 715 both ways). The sidebar rows with user names and the user segment of the path bar
  are filled, as in round 9.
- Layout at 715x715 (AX, screen pt): gallery area 359,152 316x635; preview frame 391,184 252x512; thumbs y 731..779,
  x = 367 + 59·i; inspector scroll view 675,152 240x**593** (ends at y 745); quick-action bar below it 745..815.
- **Only the top 14 pt of the thumbs (y 731..745) lie under the inspector material.** Below y 745 the quick-action bar
  is opaque window background (light 255,255,255; dark 31,31,36) and hides the rest of the strip completely. So the
  strip is not visible "through" the bar, only as a soft colour glow along the bottom 40-50 pt of the inspector column.
- Pixel values at the thumb centre column (light / dark), inspector over Flat-blue (thumb x 721..769), Flat-green
  (780..828), Flat-red (839..887):

| screen y (pt) | blue, light | green, light | red, light | blue, dark | green, dark | red, dark |
|---|---|---|---|---|---|---|
| 700 (31 pt above the strip) | 233,235,239 | 234,236,235 | 238,235,233 | 37,39,56 | 39,40,53 | 43,40,54 |
| 715 | 230,232,243 | 231,237,230 | 240,232,230 | 36,38,60 | 40,44,54 | 47,41,54 |
| 725 | 220,222,255 | 223,238,219 | 246,224,223 | 35,37,69 | 42,54,52 | 55,42,53 |
| 729 | 206,209,255 | 214,240,207 | 253,213,209 | 36,37,80 | 44,65,52 | 66,42,52 |
| 733 (over the thumb) | 195,197,255 | 207,240,197 | 252,204,199 | 34,36,86 | 47,73,52 | 75,43,51 |
| 739 | 180,183,254 | 197,242,186 | 251,192,185 | 32,35,94 | 49,84,51 | 85,43,50 |
| 744 (last row of the material) | 171,175,254 | 192,243,178 | 251,186,177 | 32,35,98 | 52,91,51 | 91,44,50 |

  - Inspector material with nothing coloured behind it: light **236,237,238**, dark **36,37,53** (Tahoe Dark shows
    through as the blue cast). Window background of the gallery area: light 255,255,255, dark 30,31,36.
  - No thumb edge is recognisable: the 11 pt gaps between thumbs are gone, the colours run into each other, and the
    glow reaches 30-45 pt above the strip's top edge.
- The strip also runs under the **sidebar** on the left when scrolled (see `gallery-715x715-flat-red-*`): there the
  whole strip height shows, heavily blurred (the sidebar reaches the window bottom). The big preview bleeds into the
  sidebar and inspector edges the same way (red glow on both sides in the flat-red shots).

## R11.2 Wheel notches: done (synthetic wheel)
- `screens/27.2.1/finder/gallery/gallery-wheel-notches-715x715-dark.mov` (strip region 359,700 556x85 pt),
  `re/27.2.1/live/finder/gallery/wheel-notch-timing.txt`. Tool: `re/tools/probe/notch.swift` (CGEvent
  scrollWheelEvent2, **units .line, not continuous**, like a classic wheel mouse; no physical wheel mouse is attached,
  so the system's acceleration for fast real turns is not covered). Strip offset read from the thumbs' AX frames after
  each event.
- **Vertical notch over the strip: no scroll** (6 notches, both directions, offset stayed 0).
- **Horizontal notch (or Shift + vertical notch) over the strip: 10 pt per notch** (the event's point delta is 10 per
  line; 1 line = 1 notch). 3 notches = 30 pt. Left clamps at 0, right clamps at the end (offset 456 = 13·59 + 5 − 316).
- **Over the big preview: the same.** Vertical does nothing (it does not change the selection either); horizontal and
  Shift + vertical scroll the strip 10 pt per notch.
- Each notch is **one frame, no animation**: the offset jumps 10 pt in a single frame (clip: 1.333, 2.033, 2.733 s for
  three notches 0.7 s apart, back at 3.733, 4.433, 5.133 s). No rubber band at the ends with line events.

## R11.3 Inspector column background: layer dump not reachable, pixel estimate given
- Finder is another process; with SIP on (not touched) its layer tree cannot be read, so material name, filter list
  and exact radius are **not available**. AX exposes only the scroll view (`previewPaneScrollView`).
- Estimate from the stills (`gallery-inspector-pixels.json`, key `fit_rows_sigma_px_rms_gain_offset`): the band
  y 690..745 of the 715 shot was fitted as `out = gain · gaussian(source, sigma) + offset` per channel, with the source
  taken from the 1000 shot (same strip, in the clear) on a plain window background.
  - Best fit **sigma ≈ 20-24 px = 10-12 pt** (rms 5.5 light / 2.7 dark of 255; the minimum is flat from 16 to 28 px).
  - **gain ≈ 0.26-0.34** (light R 0.31, G 0.26, B 0.34; dark 0.29, 0.26, 0.27): about 30 % of the blurred backdrop
    shows, the rest is tint. Offset at the best fit: light (159,170,153), dark (30,31,44).
  - Treat these as rough: sigma and gain trade off against each other in this fit, and the model has no saturation
    term (the blue under the inspector stays at B = 254-255 in light, which a plain mix does not reproduce exactly).

## R11.4 Volume HUD, single steps: done (synthetic keys)
- `screens/27.2.1/panels/hud-volume-steps-{light,dark}.mov` (crop 1100,28 340x84 pt, 2x, 60 fps VFR), per-frame table
  `hud-volume-steps-timing-{light,dark}.txt` (fill edge, glyph box), key times `hud-volume-steps-keys-{light,dark}.txt`.
- Sequence: start at 10/16, **6 ups to full, 2 more ups, 16 downs to 0, 2 more downs**, about 0.79 s apart, first
  press about 1.0 s into the clip. Volume put back to 38 afterwards. Keys are synthetic NX_KEYTYPE_SOUND_UP/DOWN events.
- **The user is right: every step animates.** What moves, per frame:
  - **Fill**: one continuous white bar that slides to the new level over **7-8 frames (about 115-135 ms)**, ease-out
    going up (2x px per frame, 13.3 pt step: +9, +5, +5, +3, +2, +1, +2). Going down it takes 5-6 frames, closer to
    linear (−9, −4, −5, −3, −5). The fill edge is seen mid-segment during the step, so the fill is a bar clipped by the
    dash shape, not 16 separate dashes switching on.
  - **Dashes (track)**: the 16 dim dashes do not move or change; segment pitch 26.6 px = 13.3 pt, bar from x 171 to
    597 px in the crop, row y 87 px.
  - **Glyph**: static during ordinary steps. Its wave count changes at once (one frame, at the start of the step):
    **3 waves at 11-16, 2 waves at 6-10, 1 wave at 1-5, none at 0** (glyph box right edge 153 / 141 / 130 px).
  - **Arriving at full** (6th up): the fill finishes in about 0.1 s and the **glyph bounces**: box 67x47 px at rest →
    about 77x53 (**≈ 1.15x**, peak about 0.2 s after the step starts) → undershoot about 62x43 (≈ 0.93x, at 0.5 s) →
    rest by **≈ 0.67 s**.
  - **Arriving at 0** (16th down): the glyph becomes the speaker without waves and bounces the same way: 44x45 px →
    56x57 (**≈ 1.27x**, at 0.2 s) → 40x41 (≈ 0.91x, at 0.4 s) → rest by ≈ 0.65 s.
  - **Extra presses at full and at 0: nothing moves** (no changed frame at all in either mode); the HUD only stays up
    longer. It fades about 1.0 s after the last press.
  - First press (HUD not yet shown): the HUD fades in over about 0.6 s with the fill already at the new level.
- Light and dark behave the same (same frame counts and positions); only the glass differs.

## R11.5 Finder toolbar Search button, hover and held: done
- `screens/27.2.1/controls/finder-search-button-hover-held-{light,dark}.mov` (crop 1096,100 104x52 pt; window
  1000x715 at 200,100, button AX frame 1155,107 38x38): pointer moves on (about 1.0 s), off (2.7 s), on again (3.8 s),
  mouse down (4.4 s), small drags while held, drag off and release outside (7.3 s, so the search field does not open).
  Stills without the pointer: `finder-search-button-{hover,held}-{light,dark}.png`. Frame table:
  `finder-search-button-timing-{light,dark}.txt`.
- Values from the stills (px; the clips are video-encoded and colour-shifted, use them for timing only):
  - Rest: disc **37 pt** across, same fill as the toolbar (light 253, dark 39,40,47) with a 1 px rim (light 190,
    dark 15 on the outside, lighter 133 → 97 along the top inside).
  - **Hover**: fill light **235-238**, dark **87,88,97**; size unchanged. Appears in a single frame, no fade.
  - **Held**: disc grows to **40 pt** (**≈ 1.08x**, about 1.5 pt per side), fill light **255** (pure white), dark
    **58-59 neutral grey** (darker than hover); the glyph gets heavier/brighter (light 83 vs 72-89, dark 255 vs
    221-238). The pressed state also appears in a single frame. While held, the disc follows the pointer by a
    pixel or two during the drags (top edge moves 1-2 px).
  - **Release**: fades back over about 0.25-0.5 s (see the tables after 7.3 s).

## R11.6 Icon & widget style tiles, dark mode: done
- `screens/27.2.1/settings/icon-style-tiles-default-selected-dark.png` (tiles only, 210x68 pt at 2x),
  `icon-style-row-default-selected-dark.png` (whole row with the label). For comparison, the account's own state:
  `icon-style-{tiles,row}-dark-selected-dark.png`.
- **The Clear and Tinted tiles change with the selection.** With **Default** selected (dark mode): Clear is a light
  grey tile with a white cloud, Tinted is a bright blue tile with a light cloud. With **Dark** selected: Clear is a dark
  grey tile, Tinted a dark navy tile with a blue cloud. Default and Dark tiles themselves stay the same.
- AX: buttons 38x52 pt (Default 868, Dark 921, Clear 972, Tinted 1023 at y 678; pitch about 51-53 pt), the selected
  one 40 pt wide with the accent ring.
- Selecting Default **removes** the global key `AppleIconAppearanceTheme` (no value = Default). Selected through the
  pane, then Dark clicked again: the key is back at `RegularDark` (verified).

## R11.7 Mission Control Spaces bar height: done
- `screens/27.2.1/dock/mc-spaces-bar-collapsed-1710x1107-dark-top.png`,
  `mc-spaces-bar-collapsed-1440x932-dark-top.png`, `mc-spaces-bar-expanded-1440x932-dark-top.png` (top of the screen
  only; one Space, "Desktop").
- **74 pt at the default 1710x1107 mode; 68 pt at 1440x932.** Measured from the screen top (y 0) to the bar's bottom
  edge (px: rows 0..147 and 0..135). Not 69.
- It fits **notch safe-area inset + 40 pt**: `NSScreen.safeAreaInsets.top` is 33.5 pt at 1710x1107 and 28 pt at
  1440x932. Expanded (pointer at the top): **166 pt** at 1710x1107, **160 pt** at 1440x932 = inset + 132 pt.
- The Dock process exposed no AX windows for Mission Control here, so this is from stills only.

## Restored and checked
Wallpaper store copied back from the backup + `killall WallpaperAgent`, Stage Manager on (`GloballyEnabled` = 1),
`CreateDesktop` deleted + Finder restarted, dark mode on, display mode 1710x1107, output volume 38, icon style
`RegularDark`, Finder `PreviewPaneGalleryWidth` back to 399 (the value found at the start; it was dragged to 240 for
the shots), the dummy folder and the two Tahoe wallpaper copies moved out of `~/Pictures` into the session scratch
folder. System Settings quit.
