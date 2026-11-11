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
