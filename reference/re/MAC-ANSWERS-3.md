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
