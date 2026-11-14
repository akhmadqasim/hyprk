# Answers from the Mac session, round 3 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#89). Same conditions as `MAC-ANSWERS-2.md`: default 1440x932 pt @2x, Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel so clips are 60 fps at most, `screencapture -v` clips are VFR on a 60 fps time base.

## R3.1 Alert appear and dismiss over flat grey: done
- `screens/27.2.1/windows/alert-appear-dismiss-grey-{dark,light}.mov`, extra stills `alert-shown-grey-{dark,light}.png`
- Finder app-modal NSAlert via `display alert ... as warning` with the Empty Trash text and buttons (the real Empty Trash
  was not used, so nothing could be deleted). Alert window frame 515,109 410x384 pt (CGWindowList, layer 8, incl. shadow).
  Dismissed with Esc.

## R3.2 Spotlight light over white: done
- `screens/27.2.1/panels/spotlight-light-white-{empty,results}.png`, `spotlight-light-white-open-close.mov`
- TextEdit window 0,29 1440x851 pt behind. In light mode the field reads dark over the white window (see the stills).
  The results for "text" list only the app and Settings items, nothing personal.

## R3.3 More Space scaled mode: done
- `screens/27.2.1/scaled/more-space-{dock,menu,settings}.png`, `more-space-spotlight-close.mov`
- Mode: 1920x1243 pt, 3840x2486 px backing (2x), panel 2880x1864, 60 Hz. Display put back to 1440x932 afterwards.
- Note on "default": Displays labels **1710x1107 as "Default"** on this 15" MacBook Air. Rounds 2 and 3 use 1440x932,
  the unscaled 2x mode (1 pt = 2 panel px), as the brief asked ("2x, no scaled mode"). Round 1 was at 1710x1107 (Apple's
  Default, which is a scaled mode on this panel).

## R3.2b Spotlight pill idle / hover / clear: done
Files: `screens/27.2.1/panels/spotlight-pill-{idle,hover,clear}-{light,dark}.mov`, `spotlight-pill-idle-{light,dark}.png`.
Times are clip pts. Keystrokes come from `osascript` so their exact moments are only known from the pixels.
- **a) idle:** with the pointer parked and never moved, only the pill shows: "Search or Ask" placeholder + caret on the
  left, mic glyph on the right. No mode icons, no suggestion rows, no panel below. Same in light and dark. In light over
  the white window the pill is dark (black at the top, grading lighter at the bottom).
- **b) hover:** the mode list is a separate rounded panel under the pill, with 4 rows: Applications ⌘1, Files ⌘2,
  Actions ⌘3, Clipboard ⌘4. It appears when the pointer **starts moving**, while the pointer is still far from the bar
  (first change 0.82 s light / 0.73 s dark, fully in by about 0.98 s / 0.93 s, so a fade / grow of about 0.2 s). It
  does **not** go away when the pointer leaves: it is still there at the end of the clip (about 1.5 s after the pointer
  left). With no pointer movement (a) it never shows.
- **c) clear:** the "te" results panel (Terminal row highlighted with "Search Terminal tab", TextEdit, TeraBox,
  TestFlight, more) stays while the field holds text. Field empty (placeholder back) at about 3.55 s light / 3.88 s dark.
  The panel then collapses to the bare pill: light from 3.80 s to 4.02 s (starts about 0.25 s after the field empties,
  about 0.22 s long); dark at about 4.45 to 4.52 s (about 0.6 s after the field empties; the 4.5 s frame shows a smaller
  empty panel shrinking under the pill). After that, only the bare pill until the clip ends (1 s later and more).

## R3.4 Volume HUD appear and fade: done
- `screens/27.2.1/panels/hud-volume-appear-grey-dark.mov`
- HUD: a capsule in the top-right corner under the menu bar (in the clip at about x 1123..1430, y 39..104 pt on screen),
  speaker glyph + 16-segment level. First HUD frame at 0.600 s, then continuous frames to 1.383 s, a pause, changes again
  1.567 s to 2.083 s (the fade), static after 2.083 s. So it is on screen about 1.0 s after the press, and the fade lasts
  about 0.5 s. `output volume` 81 -> 88 for one step (16 steps total), restored to 81.
