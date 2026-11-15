# System Settings sub-panes, round 12 (27.2.1, 26B131)

Window 740x625 pt at 350,150 on a 1440x932 display, 2x. Personal strings are blurred / `[redacted]`.

| files | how | what |
|---|---|---|
| `accessibility-NN-{light,dark}.png`, `ax-accessibility-NN-{light,dark}.jsonl` | window shot (`screencapture -o -l`) + AX dump per 300 pt scroll step | Accessibility top pane |
| `acc-<name>-NN-{light,dark}.png`, `ax-acc-<name>-NN-{light,dark}.jsonl` | same; sub-pane opened with AXPress on the `AX_FEATURE_*` row | the 22 Accessibility sub-panes |
| `push-accessibility-voiceover-{light,dark}.mov` | `screencapture -v -V 5.5 -R 582,150,508,625`, h264 | Accessibility → VoiceOver → back: a one-frame cut |
| `NAV-ROWS.md`, `nav-rows.json` | from the AX dump of each of the 29 sidebar panes | every row/button/pop-up that navigates, with AX role |
| `nav-<pane>--<target>-dark.png`, `ax-nav-<pane>--<target>-dark.jsonl` | region shot of the window rect (`screencapture -R 350,150,740,625`) + AX dump | each sub-pane / sheet / tab opened from General, Desktop & Dock, Displays, Notifications, Keyboard, Trackpad |
