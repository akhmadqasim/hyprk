# Sound timing clips, macOS 27.2.1 (round 5, R5.1)

Screen **and system audio** in one file, recorded with ScreenCaptureKit + `SCRecordingOutput`
(`reference/re/tools/probe/screc.swift`: `capturesAudio = true`, `captureMicrophone = false`, 48 kHz stereo AAC,
`minimumFrameInterval` 1/60 s, cursor shown, H.264, full display 1440x932 pt -> 2880x1864 px). Display 1440x932 (2x),
dark, TahoeDark, apps hidden. Output volume 81 (restored after each press), alert volume 100 (default, untouched),
"Play user interface sound effects" on (the account's value).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| volume-pop.mov | `screc` 3.5 s; one synthetic Volume Up key (NX_KEYTYPE_SOUND_UP) at about 1.2 s; "Play feedback when volume is changed" switched on in Settings for this clip, off again after | volume HUD + the feedback pop (audio 1.230 to 1.257 s) | dark | TahoeDark |
| screenshot.mov | `screc` 4 s; Cmd-Shift-3 (System Events keystroke) at about 1.0 s | shutter sound (audio 1.102 to 1.937 s); no flash or thumbnail is visible and no file was written (see answers) | dark | TahoeDark |
| screenshot-thumbnail.mov | `screc` 5 s, cropped to the bottom-right 240x182 pt, 0.9-2.6 s; Cmd-Shift-3 as a HID CGEvent at 1.151 s of the source (0.25 s in the clip) | Screen Capture.aif sound (+222 ms) and the floating thumbnail sliding in (+482 ms); no flash. A file was written (moved off the Desktop) | dark | flat grey 127 PNG |
| dock-drag-off-flyback.mov | `screc` of a 400x432 pt region above the Dock's right end, 2.5-4.6 s; one-process synthetic drag of a dummy folder tile 255 pt up, 1.2 s hold, mouse up | "Remove" bubble, then on the synthetic up the label reverts and the tile flies back; no poof, silent (no audio track kept) | dark | flat grey 127 PNG |
| dock-remove-menu-poof-sound.mov | `screc` 500x532 pt region over the Dock's right end, 0.9-2.7 s, with audio; Dock menu (AXShowMenu) > Options > Remove from Dock on a dummy folder tile | menu fade-out, tile removed and Dock re-centres over 250 ms, poof item off dock.aif starts in the same frame as the first visual change; no poof cloud | dark | flat grey 127 PNG |
| volume-key-hud-timing.mov | `screc` of the top-right 440x300 pt, cropped to 340x120 pt, 0.9-2.2 s; synthetic NX_KEYTYPE_SOUND_UP at 1.107 s of the source (0.21 s in the clip), pointer moved just before as a clock marker | volume HUD fade-in (first frame +127 ms in this run) and the Sound menu bar item highlight; feedback sound off, so silent | dark | flat grey 127 PNG |
| dock-remove-menu-real-click.mov | `screc` (ScreenCaptureKit screen + system audio, 60 fps) region 1000,580 500x527; HID right-click, HID click on Options > Remove from Dock | blink, menu fade, tile removed, poof sound (round 16) | dark | user wallpaper |
| volume-key-f12-hand-feedback.mov | `screc` region 1290,24 420x120; the user pressed F12 once; feedback sound on for the take | pop and HUD after a hardware key | dark | user wallpaper |
| dock-drag-off-hand.mov | `screc` region 850,720 600x387 (cropped); the user dragged a dummy folder tile off the Dock with the trackpad | "Remove" label, release, icon fades, poof sound | dark | user wallpaper |
