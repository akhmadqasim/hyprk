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
