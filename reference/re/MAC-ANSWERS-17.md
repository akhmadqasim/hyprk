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
  The title bar and toolbar dim with it; the traffic lights lose their colour (red goes grey) while the sheet is up.
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
