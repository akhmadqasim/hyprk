# Window captures, macOS 27.2.1 (round 2 additions)

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| close-button-hold-drag.mov | `screencapture -x -v -R 540,340,180,80` (2x, H.264 60 fps time base, VFR; the panel is 60 Hz, 120 fps not possible), 3.2 s | TextEdit window, pointer resting on the close button (hover glyphs shown), mouse down at about 0.4 s, held 1 s, dragged 50 pt right in 0.3 s (ends over the zoom button), held 0.3 s, released outside the close button at about 2.0 s; the window stays open. Last frame change at 3.18 s | dark | TahoeDark (window content) |

## Round 3 (R3.1): app-modal alert over flat grey
Display 1440x932 pt (2x), desktop = solid RGB 127,127,127, other apps hidden, desktop icons hidden. The alert is a real
app-modal NSAlert in Finder made with `tell application "Finder" to display alert "Are you sure you want to permanently
erase the items in the Trash?" message "You can’t undo this action." buttons {"Cancel","Empty Trash"} default button
"Empty Trash" cancel button "Cancel" as warning` (same text and buttons as Finder's Empty Trash alert, no Trash touched).
Shown about 0.5 s into the clip, dismissed with Esc (Cancel) about 1.6 s later. Pointer off the alert.
Clips `screencapture -x -v -V 4 -R 440,60,560,500` (H.264, 60 fps time base, VFR).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| alert-appear-dismiss-grey-dark.mov | region 440,60 560x500 pt, 2.18 s (last change) | alert appear, rest, dismiss | dark | grey 127 |
| alert-appear-dismiss-grey-light.mov | same, 2.27 s | same | light | grey 127 |
| alert-shown-grey-dark.png | `screencapture -x -R`, same region, alert at rest | still of the alert (window 410x384 incl. shadow at 515,109) | dark | grey 127 |
| alert-shown-grey-light.png | same | same | light | grey 127 |
