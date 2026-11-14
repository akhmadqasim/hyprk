# Answers from the Mac session, round 4 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#107). Same conditions as `MAC-ANSWERS-3.md`: 1440x932 pt @2x (unscaled), Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel, `screencapture -v` clips are VFR on a 60 fps time base (times below are clip pts).

## R4.1 Close button held 3 s, pointer still: done
- `screens/27.2.1/windows/close-button-hold-still-{dark,light}.mov`
- Change at the button per frame (mean abs RGB diff of the button area, frames with change > 0.05):
  - dark: press at **0.217 s**, big change to 0.35 s, small changes to about 0.83 s (bounce settles about 0.62 s after
    the press); **still from 0.83 to 2.317 s**; a second animation **2.317 to about 2.97 s** (starts 2.10 s after the
    press: the knob/button eases back from its pressed size); still until the drag out at 3.267 s.
  - light: press at **0.417 s**, settles about 0.92 s (one tiny change at 1.30 s); second animation **2.533 to about
    3.23 s** (starts 2.12 s after the press); drag out at 3.517 s.
  So the idle end of the hold bounce starts about **2.1 s** after mouse down and lasts about 0.65 s.
