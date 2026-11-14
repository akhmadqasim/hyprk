# Live clips, macOS 27.2.1 (round 2)

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| mc-exit-4-windows.mov | `screencapture -x -v -R 0,0,1440,932` (full screen at the default 1440x932, 2x, H.264 60 fps time base, VFR), 5.0 s | 4 overlapping TextEdit windows ("Window 1".."4", 640x460 pt, offset 90,70 pt; "Window 4" in front). Mission Control entered at about 0.5 s (`open -a "Mission Control"`), at about 2.3 s the pointer moves to the back window ("Window 1", bottom right tile) and clicks it at about 2.8 s; it exits with Window 1 in front | dark | TahoeDark |
| mc-4-windows-entered.png | full screen `screencapture -x` 0.5 s after `open -a "Mission Control"` (plus screencapture latency) | the same 4 TextEdit windows (640x460, +90,+70 pt, "Window 4" in front) in Mission Control: 2 tiles on top, 2 below, "Desktop" chip, + button, Dock | dark | TahoeDark |
| mc-exit-esc.mov | `screencapture -x -v -V 3 -R 0,0,1440,932` (60 fps time base, VFR), MC already open | Esc (System Events key code 53) at about 0.5 s; exit animation back to the overlapping windows ("Window 4" still in front) | dark | TahoeDark |
