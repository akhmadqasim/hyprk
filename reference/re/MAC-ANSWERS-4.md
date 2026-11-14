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

## R4.2 Wi-Fi hover, Focus with DND on: Wi-Fi done; Focus done with Driving instead of Do Not Disturb
- `screens/27.2.1/panels/module-wifi-hover-{row,toggle}-{light,dark}.png`
  - Row hover: a full-width rounded highlight behind the row (Known Network row in the shots).
  - Toggle: hovering the Wi-Fi switch (and the header row) shows **no** visible change.
  - AX (ControlCenter): header text "Wi‑Fi" 967,43 34x16; switch AXCheckBox 1193,39 54x24 (`wifi-header`); network
    rows are AXCheckBox 280x32 (`wifi-network-<name>`, value 1 = connected); scroll area 953,78 308x152; "Wi‑Fi
    Settings…" button 967,241 280x22.
- `screens/27.2.1/panels/module-focus-driving-on-{light,dark}.png`: **not with Do Not Disturb**. A Focus (Driving) was
  already on, synced from the user's iPhone ("Share across devices" is on). Switching to Do Not Disturb on the Mac would
  change the Focus on the phone too, so it was left alone. The shot shows the "on" state the PC wanted to see: header
  "Focus" + "On" (secondary text, 967,52.5), the active row's icon disc filled/tinted. Rows are AXCheckBox 280x32 at
  y 78, 110, 142, 174, 206, 238; "Focus Settings…" 967,274. If the exact DND look is needed, ask the user to turn DND on.

## R4.3 Fan with "More in Finder": done
- `screens/27.2.1/dock/stack-fan-more-dark.png`, `stack-fan-more-close-dark.mov`
- 14 entries in the folder, the fan shows 9 + a top slot "5 More in Finder" (label capsule + round arrow button in the
  icon column). Close clip: frames change from 0.017 s to 1.033 s (pts), static after.

## R4.4 Spotlight mode list, dark, white vs grey: done
- `screens/27.2.1/panels/spotlight-modelist-{white,grey}-dark.png`
- White backdrop = a white PNG shown in Preview filling the screen (Spotlight and the list sit fully over white).
  In dark mode over white, the pill is black at the top grading to grey; the list panel is light grey with dark-grey
  fill at the top. Over grey 127 both read as darker greys.

## R4.5 Mission Control, 4 windows: entered still and Esc exit: done
- `screens/27.2.1/live/mc-4-windows-entered.png`, `mc-exit-esc.mov` (full screen, 2.9 MB)
- At 0.5 s after entering, the layout is already in its final positions (tiles at about 20,110 / 552,110 / 372,498 /
  904,498 pt, 520 pt wide). Esc exits with the previous front window (Window 4) still in front. The clip keeps changing
  until its end because of the live CPU / RAM menu bar items (not part of the animation).
