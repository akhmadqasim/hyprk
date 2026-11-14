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
