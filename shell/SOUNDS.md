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
| `poof` | no caller: the Dock has no drag-off removal yet (Mac: Q-dock-17 "Remove" bubble, fade 0.25 s, ID 15) | `SystemSounds/dock/poof item off dock` | `uiSounds` |
| `volume` | Control Center Sound slider settles (180 ms debounce), volume keys | `misc/BezelServices-volume` | `volumeFeedback` |
| `screenshot` | Cmd+Shift+3, Cmd+Shift+4 (slurp), Print | `SystemSounds/system/Screen Capture` | `uiSounds` |
| `trash-empty` | Dock Trash right-click > Empty Trash | `SystemSounds/finder/empty trash` | `uiSounds` |
| `trash-move`, `mount`, `unmount`, `sent` | available for other apps (Finder) | see `sound.sh` | `uiSounds` |

## Fallbacks

- Player: `pw-play`, then `paplay`, else silent.
- Unknown `alertSound` name: Tink. Missing sound file: silent.
- `HYPRK_MUTE=1` silences everything (set by `scripts/smoke.sh` and nested test sessions).
- `HYPRK_SOUND_LOG=<file>` appends `<event> <file>` for each sound that would play, muted or not.
- No startup chime: the Mac's is firmware, no file exists, so "Play sound on startup" (Settings) has nothing to play.

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
