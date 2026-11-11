# hyprk shell sounds

macOS 27.2 sounds: the Apple originals in `sounds/originals` (played when present; an install ships the 23 the shell
uses, `packaging/install.sh` SHIP_SOUNDS_RE), the Vorbis copies in `sounds/oga` as the fallback (`sounds/INDEX.md`). Everything plays
through one script, `shell/scripts/sound.sh <event>`, used by the shell (QML,
`services/Sounds.qml`) and by Hyprland binds (`config/hypr/hyprland.lua`).

## Settings: `state/sound.json`

Written by the Settings app (Sound pane), read by `sound.sh` on every play, so
changes apply at once. Missing file or keys fall back to the defaults.

| key | type | default | meaning |
|---|---|---|---|
| `alertSound` | string | `"Tink"` | file name (no extension) in `sounds/originals/Sounds/` (or `oga`): Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink |
| `alertVolume` | number 0..1 | `0.75` | volume for every sound systemsoundserverd would play (alert, notification, UI sounds); not the volume feedback and the power chime, which BezelServices and PowerChime play with NSSound (at 1) |
| `uiSounds` | bool | `true` | "Play user interface sound effects": screenshot, trash, mount |
| `volumeFeedback` | bool | `false` | "Play feedback when volume is changed" |

## Events

| event | when | file | gated by |
|---|---|---|---|
| `notification` | a notification that asks for a sound (`sound-name` / `sound-file` hint) arrives; others are silent (`lib/nc.js` notificationSound) | alert sound | Focus / Do Not Disturb (no banner, no sound), the app's sound setting, `suppress-sound` |
| `alert` | critical notification, `qs ipc call sounds play alert`, an alert that sets `beep: true` (NSAlert plays no sound by itself; confirmations such as Empty Trash or Shut Down are silent) | alert sound | Focus |
| `power` | a laptop goes from battery to the charger (UPower) | `misc/PowerChime-connect_power` | `uiSounds` |
| `poof` | an app dragged off the Dock is let go there (Mac: Q-dock-17 "Remove" bubble, fade 0.25 s, ID 15) | `SystemSounds/dock/poof item off dock` | `uiSounds` |
| `volume` | the volume keys (`scripts/volume-key.sh`, below), the Control Center Sound slider and the Sound module's slider when let go after a change, the Settings Output volume slider when let go | `misc/BezelServices-volume` | `volumeFeedback`, inverted while Shift is held (keys and Control Center); a new pop stops the previous one |
| `screenshot` | Cmd+Shift+3, Cmd+Shift+4 (slurp), Print: as the screen is taken (screencapture 27.2.1 `FUN_10000cc88` plays ID 0x571 before writing the file; the only property it sets is CompletePlaybackIfAppDies `ifdi` = 1, so it stays a UI sound); ours starts with grim, 23 ms after the key (was after the PNG encode, ~1.5 s) | `SystemSounds/system/Screen Capture` | `uiSounds` |
| `trash-empty` | Dock Trash right-click > Empty Trash | `SystemSounds/finder/empty trash` | `uiSounds` |
| `trash-move`, `mount`, `unmount`, `sent` | available for other apps (Finder) | see `sound.sh` | `uiSounds` |

## Fallbacks

- Player: `pw-play`, then `paplay`, else silent.
- Unknown `alertSound` name: Tink. Missing sound file: silent.
- `HYPRK_MUTE=1` silences everything (set by `scripts/smoke.sh` and nested test sessions).
- `HYPRK_SOUND_LOG=<file>` appends `<event> <file>` for each sound that would play, muted or not.
- No startup chime: the Mac's is firmware, no file exists, so "Play sound on startup" (Settings) has nothing to play.

## Volume keys and the volume pop (BezelServices, Control Center)

`scripts/volume-key.sh` (Hyprland binds in `config/hypr/hyprland.lua`) follows BezelServices' `VolumeStateMachine`,
decoded from `/System/Library/LoginPlugins/BezelServices.loginPlugin` (macOS 27.2.1 26B131, arm64e slice, Ghidra 12.2
of the bundle extracted from the restore image, 2026-11-12):

| rule | Mac evidence |
|---|---|
| a key press and every auto-repeat change the level, show the HUD and play nothing | `VSIncrease` / `VSDecrease` `-generateOutput:stateMachine:` (0x11ac0, 0x11cf8): `changeVolumeBy:type:`, `displayOSD`, `setSingleBeepWhenFinished:YES`; the `*Repeat` states (0x11be8, 0x11e20) the same without the flag |
| ONE pop when the key goes up, if a step happened since the last pop | `VSStart` (0x11538): `singleBeepWhenFinished` -> `startOneBeep` (an `NSTimer` of 0 s), then `stopBeeps` clears it |
| a step is 1/16, Option+Shift 1/64, on a grid | `-changeVolumeBy:type:` (0x10388): level rounded to 1/64 (`(int)((v + 1/128) * 64) / 64`), +-step, truncated to a multiple of the step, clamped to 0..1 |
| at full volume a held key pops at once, then every 1 s, until the key goes up or 4 s pass without a step; the key going up then plays nothing more | `startRepeatedBeeps` (0x10214): repeating `NSTimer` 1.0 s, fire date now, started when the new level is 1.0; `beepTimeout` = now + 4 s on each step, `playOneBeep:` (0xff78) stops the timer once it has passed and always ends with `setSingleBeepWhenFinished:NO` |
| a pop stops the one still playing, then plays (no overlap) | `playOneBeep:`: `isPlaying` -> `stop`, then `play` on the one `NSSound` of `volume.aiff` |
| Shift held (without Control, Option, Command) inverts "Play feedback when volume is changed" for that pop | `-handleKeyEvent:shift:control:option:command:` (0x10d04) sets `negateSilentPreference`; `playOneBeep:` plays when `playVolumeKeyFeedback != negateSilentPreference` |
| Option alone with a volume or mute key opens the Sound settings | input 9 -> `VSSoundPrefs` (0x117b8): `displaySoundPrefs` |
| the mute key: muting is silent, unmuting pops 0.08 s later | `VSMute` (0x11f30): `startOneBeep` while still muted (the timer is 0.08 s when muted, double at 0x401d8), then `toggleMute`; no flag, so key up plays nothing |
| no output device: nothing | `canSetVolume` NO: "Manual volume adjustment not allowed", no level change, no pop |

The Control Center Sound slider (ControlCenter 27.2.1, `0x1000e3814`): `playAudioVolumeFeedback(onSliderEditingChanged:)`
returns while editing; when editing ends it reads `NSEvent.modifierFlags` bit 17 (Shift) and calls
`AudioVolumeFeedbackController.shared.playVolumeFeedbackSound()` when `SoundPreferences.shared.beepFeedback != Shift`.
That controller (ControlCenter.framework in the dyld cache, 0x20a531e74) plays the same
`BezelServices.loginPlugin/Contents/Resources/volume.aiff`. So nothing plays while dragging, one pop on let-go. Ours:
`HyprK.Slider.releaseModifiers` -> `Sounds.volumeReleased()` (was a 180 ms debounce after the last drag step).

Start latency, ours (session 19, headless session on a private PipeWire with a logging stand-in for `pw-play`, so no
sound reached a device): virtual key up -> the player starts 26, 28, 31, 33, 40 ms (one 105 ms outlier; with auto-repeat
still queued 30-100 ms); `sound.sh` itself 8-11 ms of that (jq 4 ms); `pw-play` reaches streaming about 11 ms later
(earlier measurement, above). Unmute -> pop 123 ms (0.08 s by design + 43 ms). The Mac's key-up -> sound time is not
measured: **needs the Mac** (a recording of key up and the output).

## Evidence: the alert volume scales every sound systemsoundserverd plays

Read from `/usr/sbin/systemsoundserverd`, macOS 27.2.1 (26B131), arm64e, base 0x100000000 (static, 2026-11-11; this
repeats the earlier reading that `sound.sh` relies on, with one correction: 0x10000dea4 is the store instruction for the
user volume, not a data address).

- The play handler `SystemSoundServerPlayActionID` (function 0x10000a044) has one "Starting audio" path, with no
  branch on the kind of sound, and multiplies three factors there:

      10000b4bc: ldr  s9,  [x8,  #0x10]   ; request: client volume scalar
      10000b4c0: ldr  s10, [x24, #0x34]   ; per-user record: user volume
      10000b4c4: ldr  s8,  [x22, #0x20]   ; play state: "CM" volume
      10000b6cc: fmul s9, s10, s9
      10000b6f4: fmul s8, s9, s8          ; logged at 0x10000b7e4

  The log string names them in the same order: "Starting audio … volume %f (user vol %f, client vol scalar %f, CM
  vol %f), pan %f". The CM volume is set to 1.0 at 0x10000afac (no other writer found: inferred to stay 1.0 on macOS).
- The user volume is not read by the daemon. The client library sends it (AudioToolbox `SendClientPrefsToServer`,
  0x1adcf0590 in the dyld cache, XPC action 0x34) from the global preference domain: `com.apple.sound.beep.volume`
  (Float32, default 1.0: the Alert volume slider), with `com.apple.sound.beep.flash`,
  `com.apple.sound.uiaudio.enabled` and `com.apple.sound.beep.enabled`. The daemon parses them at
  0x10000f2a0..0x10000f9ec and stores them in the per-user record (setter 0x10000dd08):

      10000dea4: str s8,  [x23, #0x34]        ; volume
      10000dea8: stp w19, w21, [x23, #0x2c]   ; alertAudioOn, uiAudioOn
      10000deac: str w20, [x23, #0x28]        ; alertVisualOn

- Gate (0x10000b4c8..0x10000b504, 0x10000b9f0): behaviour 1 (an alert, `AudioServicesPlayAlertSound`) plays only when
  alertAudioOn is set; any other sound whose isUI byte is 1 does not play when uiAudioOn is 0. The isUI byte is 1 for
  every sound object and cleared only for ID 0x1000, the alert sound (0x10000602c).

So: the Alert volume scales screenshot, Bin and Volume Mount sounds as well as alerts (they all go through this
path), and "Play user interface sound effects" silences only the UI sounds. That is what `sound.sh` does (`vol=1` only
for the volume feedback and the power chime, which BezelServices and PowerChime play with NSSound). Not measured on a
Mac: the loudness of a UI sound at two Alert volume settings (a recording of the output would confirm the binary).

## Open (2026-11-12, session 19)

- **Needs the Mac:** key-up -> sound start time of the volume pop and the shutter (ours 26-40 ms and 23 ms to the
  player); the loudness of a UI sound at two Alert volume settings (the binary says it scales); the double-click
  interval (the plugin's title-bar double-click uses Qt's 400 ms).
- **Not decoded yet:** whether Settings > Sound's Output volume slider inverts the pop with Shift (Sound.appex; ours
  plays on let-go when the switch is on, without Shift); the Control Center feedback controller's own throttle
  (ControlCenter.framework 0x20a532114 compares a stored date with now before it plays).
- Volume keys and the Hyprland binds: a press that changes nothing (already at 0 going down) still sets the key-up pop,
  as `VSDecrease` does (it sets the flag whatever the level).
