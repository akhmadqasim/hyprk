# Notification Center (macOS 27.2.1) — glass and motion crops

The user's real notifications are blanked out as flat grey blocks labelled "redacted". The only real content left
visible is the "Script Editor" test notifications ("hyprk test N"), the system header "Notification Centre",
"N more notifications", and the Calendar (month grid only) and Batteries widgets.
All captures are 2x px from `screencapture`. The backdrop is a solid full-screen window (probe
`re/tools/probe/ncbg.swift`) at level -2147483600, which hides the desktop icons and desktop widgets.
The numbers are in `re/27.2.1/live/nc/`.

| File | What |
|---|---|
| `stack-{dark,light}-{white,grey,black,blue}.png` | Test stack (front card + 2 plates), pt x 1340..1704, y 130..240. Backdrop 255 / 127 / 0 / sRGB (69,83,206). |
| `widgets-{dark,light}-{white,grey,black,blue}.png` | Widgets row + "Edit Widgets" + its x circle, pt x 1340..1704, y 740..1040 |
| `overview-redacted-{dark-white,light-white,dark-blue}.png` | Whole column at 1x, real cards blanked |
| `dark-checker-top.png`, `dark-checker40-top.png` | Column over an 8 pt / 40 pt black-white checker: blur inside the column between cards, sharp outside it |
| `open-click-strip-widgets.png`, `close-click-strip-widgets.png` | Clock-click open/close, widget row (y 785..1040) per frame, labelled frame/time. The calendar digits fade in on open. |
| `banner-arrive-strip.png`, `banner-dismiss-strip.png` | Test banner arrival (slide from the right + fade + unblur) and auto-dismiss (reverse, faster) |
| `hover-off-on-dark-grey.png` | Test card without/with hover: x circle on the top-left corner, "Show" capsule replaces the time |
