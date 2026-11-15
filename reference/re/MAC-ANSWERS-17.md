# Answers from the Mac session, round 17 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #181 from the PC. Capture only. Files under `re/27.2.1/live/r17/`. Display 1440x932 at 2x, Tahoe wallpapers,
Stage Manager off, desktop icons hidden; frames are screen points. Items are pushed one by one; this file grows.

## R17.4 Window chrome: in-window alert, inactive window: done
- `alert-{dark,light}.png` (region 250,110 800x600 pt), `alert-{dark,light}.mov` (appear, 60 fps VFR, Cmd-W at about
  1.2 s), `alert-dismiss-{dark,light}.mov` (Escape at about 1.0 s), `ax-alert-{dark,light}.jsonl`.
- Set-up: TextEdit, new document with the text "hyprk test", window 700x500 at 300,150, Cmd-W. What appears is the
  **save sheet as a floating card inside the window**: AXSheet **390x318 pt at 455,241** (centred horizontally, its top
  91 pt below the window top), rounded card with its own shadow. Content: bold title "Do you want to keep this new
  document “Untitled”?" (574,260 232x34), text (574,298 232x44), rows Save As / Tags / File Format / Where with
  right-aligned labels (label column 74 pt), then **Delete** (red tinted, left), **Cancel** and **Save** (accent,
  right).
- **Behind it the window is dimmed, not blurred**: text and ruler stay sharp. Window content level (px, a point in the
  text area away from the card): light **255 → 197** (×0.77, i.e. black at about 23 %); dark **27 → 23** (about 15 %).
  The title bar and toolbar dim with it; the close light goes grey while the sheet is up (yellow and green keep their colour).
  Outside the window nothing changes.
- Timing (light clip): first changed frame 1.350 s; the **dim ramps linearly 255 → 197 from 1.350 to 1.567 s
  (≈ 220 ms, about 3.5 levels per frame)**; the card is drawn from the first frame (full extent of the change region
  is there at 1.367 s) and fades/settles within the same 220 ms. Dark: 1.467 → 1.667 s, same length.
  **Dismiss** (Escape): light 197 → 255 from 1.100 to 1.367 s (**≈ 270 ms**, linear), card fades out with it; dark
  1.100 → 1.333 s.
- **Inactive window**: `inactive-titlebar-{dark,light}.png` and `active-titlebar-{dark,light}.png` (strip 300,150
  700x60 pt of the same TextEdit window, Finder frontmost for "inactive"). Disc 14 pt, centres 16 / 39 / 62 pt from the
  window's left edge. Values (px, mean of the central 11x11 px; title = extreme pixel of the title text):

| | lights | title text | bar |
|---|---|---|---|
| dark, active | 224,101,88 / 243,193,34 / 93,188,33 | 164,164,169 | 39,39,44 |
| dark, inactive | all three **75,75,79** | **105,105,110** | 39,39,44 |
| light, active | 234,132,121 / 245,202,87 / 151,213,110 (as captured 1 s after activation; lighter than the dark-mode values) | 88,88,88 | 255,255,255 |
| light, inactive | all three **241,242,244** (barely visible on white, rim only) | **183,183,183** | 255,255,255 |

  The title here is "Untitled — Edited" with the document icon; the inactive bar keeps its fill, only the text, icon
  and lights fade.

## R17.2 Cmd-Tab switcher: done
- Stills `cmdtab-{7,8,9,10}apps-{dark,light}.png` (band 0,300 1440x340 pt, panel held open), clips
  `cmdtab-appear-release-{dark,light}.mov`, `cmdtab-quick-tap-{dark,light}.mov` (`screencapture -v`, region 160,340
  1120x260) and `cmdtab-step-cancel-dark.mov` (ScreenCaptureKit recorder, same region). Keys are synthetic HID
  keyboard events (Cmd down, Tab taps, Cmd up). Background: Tahoe wallpaper, all other apps hidden.
- **3 and 6 apps could not be set up**: the switcher lists every running app and the user's own apps (5) stay
  running, so the counts captured are **7, 8, 9 and 10** (TextEdit, Calculator, Dictionary, Chess added). The panel
  grows linearly, so the smaller sizes follow from the pitch.
- Geometry (px on the 2x stills, ±1 pt):
  - icons **128 pt cells** (visible tile about 102 pt), **pitch ≈ 133.5 pt**, one row, centred on the screen;
    tile top at y 416, bottom 517 (screen 932 pt tall: the row centre is at y ≈ 466, the middle of the screen).
  - panel width **≈ 133.5·N + 42 pt**: 980 pt for 7 apps, ≈ 1374 pt for 10 (so ≈ 443 pt for 3, ≈ 843 pt for 6);
    height **≈ 175 pt** (y ≈ 378 to 553); capsule-like rounded rectangle, corner radius about 40 pt; glass with the
    wallpaper visible through it, a thin lighter rim all round (brightest on the top edge) and a soft shadow.
  - **selection plate**: rounded square **≈ 119x119 pt** around the selected icon (about 8 pt larger than the tile on
    each side), corner radius ≈ 28 pt, a lighter translucent fill (dark: about 157,144,252 over a panel of 94,80,199
    at the top, fading down to about 101,114,227) with a thin bright rim; in light it reads as a darker tinted plate
    (see the light stills).
  - **label**: only under the selected icon, centred on it, about 12 pt semibold, white with a soft shadow in dark,
    dark text in light; its centre is ≈ 12 pt below the plate's bottom edge (y ≈ 538), inside the panel.
  - badges (e.g. the red count) are drawn on the icons as in the Dock.
- Behaviour (step clip, epoch-based key times on the recorder clock):
  - **Appear**: Cmd down 1.050 s, Tab down 1.137 s, panel **fully there in one frame at 1.317 s (180 ms after the Tab
    press)**. No fade-in and no scale: the frame before has nothing, the next has the complete panel with the second
    app selected.
  - **Step** (Tab again): Tab at 1.904 s → the plate and label are on the next icon at 1.933 s; Tab at 2.649 s →
    2.667 s. **One frame, a jump** (no slide).
  - **Cancel** (Escape while holding Cmd, at 3.599 s): panel **gone in one frame** (3.600 s), no fade.
  - **Release to switch** (`cmdtab-appear-release-*`): after Cmd up the panel **fades out over about 200 ms**
    (per-frame level 98, 94, 89, 82, 73, 63, 50, 37, 26, 17, 10, 4, 2, 1 %: ease-in, 13 frames) with no scale change,
    while the chosen app comes forward.
  - **Quick tap** (Cmd down, Tab, Cmd up 150 ms after Cmd down): **no panel at all**; the previous app is activated
    directly (`cmdtab-quick-tap-*`: no changed frame in the panel area).

## R17.3 Spotlight stills: done
- `spotlight-<state>-<background>-<mode>.png`, crops of full-screen shots (window rect + 30 pt), for three
  backgrounds: `wallpaper-dark` (Tahoe Dark, nothing else on screen), `white-light` (a white TextEdit window 1200x800
  behind, light mode) and `white-dark` (the same window, dark mode). States: `idle`, `typed` (query "calc"),
  `modelist` (the four-row list that appears when the pointer moves), `mode-files`, `mode-actions`, `mode-clipboard`.
  Detail crops at 2x of the bar's lower half/rim and the top result row: `spotlight-typed-bar-and-top-row-*.png`
  (520x163 pt from the window's top-left).
- Blurred: result rows below the top hit in `typed`, the file grid in `mode-files`, the clipboard row in
  `mode-clipboard`. The Applications mode is the Apps grid: see R17.1.
- The UI's window (owner "Siri" in the window list, layer 23; **its AX tree is not reachable**, only the menu bar
  comes back), frames in pt on the 1440x932 screen:

| state | window frame |
|---|---|
| idle (bar only) | 336,349 520x137 |
| mode list | 336,349 520x311 |
| typed, results | 336,349 520x507 |
| Actions, Clipboard | 336,295 520x587 (the bar moves **54 pt up**) |
| Files, Applications | 174,295 844x617 (wider panel, bar stays 520 wide and centred) |

  The bar is 520 pt wide and centred on the screen (x 336..856); its top is the window's top edge. The bar is
  **86 pt tall** (y 349.5 to 435.5); the panel below is a separate rounded shape that starts **11 pt** under it (see R17.5).
- What the stills show:
  - **idle**: "Search or Ask" placeholder with the caret at the left, mic glyph at the right. Over the white window the
    bar is a **dark pill** (black at the top grading to mid grey at the bottom); over the dark wallpaper it is a dark
    glass with the wallpaper colour coming through.
  - **typed**: the query with the inline completion highlighted ("calc" + selected "ulator — Open"), the top hit's
    icon at the bar's right end. Panel below: rows about 41 pt apart; top row = app icon, name, and at the right a
    small hint "Search Calculator" with a `tab` key cap.
  - **mode list**: four rows (Applications ⌘1, Files ⌘2, Actions ⌘3, Clipboard ⌘4): glyph, name, shortcut right
    aligned.
  - **a mode**: the bar shows the mode's glyph + name as the placeholder and a "…" button at the right; Files has a
    row of filter chips (Preview, Microsoft Word, PDF, TextEdit, Music …) over a 7-column grid of file tiles with a
    "Recents" section; Actions is a list with section headers ("Suggestions", "Books" …), 2-line rows and a small
    button-like hint at the right of each row; Clipboard is a list of entries (time, kind) with an action at the right.
- Modes were opened with ⌘1..⌘4 after the mode list was showing; Escape twice closes.

## R17.5 Spotlight list top edge over a black/white step: done
- `spotlight-list-top-edge-step-{dark,light}.png`: **raw, unmodified 2x crop** (region 300,330 600x190 pt) of a
  full-screen shot with results open (query "calc"). Behind: a Quick Look window showing an image whose left half is
  pure black and right half pure white; the vertical step is at **x = 720 pt** (screen centre), so the list's top edge
  (horizontal) crosses it. Dark and light mode.
- Frames (px edges on the 2x shot, identical in dark and light):
  - bar: x 336 to 856 (520 pt), **y 349.5 to 435.5 (86 pt)**;
  - **list: x 338.5 to 853.5 (515 pt wide, 2.5 pt narrower than the bar on each side), top edge y = 446.5** (11 pt
    below the bar's bottom edge); the window continues to y 856, the list's bottom is cut by the window there.
  - Window frame from the window list: 336,349 520x507.

## R17.1 Apps (the Applications mode of the Spotlight panel): done, with limits
- In 27.2.1 the Apps grid is the **Applications mode of the Spotlight panel** (same bar, mode glyph + "Applications"
  as placeholder). Files: `apps-rest-{dark,light}.png`, `apps-typed-cal-{dark,light}.png` (stills, window rect + 30
  pt), `apps-open-close-{dark,light}.mov`, `apps-scroll-{dark,light}.mov` (ScreenCaptureKit recorder, 60 fps, region
  130,250 940x682 pt), `apps-hover-press-{dark,light}.mov` (region 534,556 120x110 pt around one icon).
- **Privacy**: third-party app cells are blurred in the stills; in the open/close and scroll clips the **whole grid
  area is blurred** (motion and timing remain visible, the bar and chips stay sharp). The hover/press clip shows one
  Apple app cell (Calculator) unblurred.
- **Limits**: the panel's AX tree is not reachable, so sizes are from pixels (±1-2 pt). Opening from a **Dock icon
  was not captured**: there is no Apps tile in this Dock; a tile for `/System/Applications/Apps.app` was added
  temporarily, but neither a synthetic click on it nor `open -a Apps` brought the panel up in this session (the Dock
  was restored). "From the key" here is ⌘Space then ⌘1. Trackpad scrolling by hand was not recorded (the scroll clip
  uses synthetic pixel-wheel and line-wheel events).
- **Geometry at rest** (window 174,295 844x617; values relative to the window's top-left):
  - bar 520x86 centred (x 162..682, y 0..86), panel starts 11 pt below it and is the full 844 pt wide;
  - **category chips** row at y ≈ 128: Utilities, Developer Tools, Social, Productivity, Entertainment, Creativity,
    Information & Reading, … (scrolls sideways, last chip cut off at the right edge); chips are small capsules with
    11 pt text;
  - **7 columns**, icon centres x ≈ 76, 191, 304, 419, 532, 646, 761 (**pitch ≈ 114 pt**); icons **≈ 64 pt**; label
    one line, centred, about 11 pt, its centre ≈ 47 pt below the icon centre, long names truncated with "…";
  - first row (y ≈ 197) is a row of **recent/suggested apps** with a hairline separator under it (y ≈ 263); the
    alphabetical grid follows with rows at y ≈ 314, 414, 515, 614 (**row pitch ≈ 100 pt**); it **scrolls vertically**
    (no pages), the bottom row is clipped by the panel edge.
  - Background: glass over the wallpaper (dark blue tint in dark mode over Tahoe Dark, lighter blue-grey in light
    mode over Tahoe Light), with a rim like the bar's.
- **Search**: typing filters the grid in place ("cal" → Calculator, Calendar, left-aligned from the first column);
  the bar shows the query with the inline completion ("cal — Open" with the completion highlighted); the chip row
  disappears while a query is typed (`apps-typed-cal-*`).
- **Open / close** (light clip, epoch-based key times on the recorder clock):

| key | time | what |
|---|---|---|
| ⌘Space | 1.139 s | bar appears from 1.350 to 1.450 s (starts ≈ 210 ms after the key, ≈ 100 ms long) |
| ⌘1 | 2.521 s | bar switches to "Applications" and moves 54 pt up; the grid panel grows in from **2.917 to 3.133 s (≈ 215 ms**, starting ≈ 400 ms after the key) |
| Escape | 4.906 s | the grid panel goes away from 5.083 to 5.300 s (≈ 215 ms), leaving the plain bar |
| Escape | 6.303 s | the bar goes away from 6.483 to 6.550 s (≈ 70 ms) |

  The dark open/close clip stopped early (92 frames); use the light one for timing.
- **Hover and press**, **scroll**: clips only; they were not analysed per frame in this round. In the press clip the
  mouse goes down on Calculator for 0.9 s and is released on it, which launches the app (it was quit again).
