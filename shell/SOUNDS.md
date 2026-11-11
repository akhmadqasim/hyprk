# hyprk shell sounds

macOS 27.2 sounds live in `sounds/oga` (see `sounds/INDEX.md`). Everything plays
through one script, `shell/scripts/sound.sh <event>`, used by the shell (QML,
`services/Sounds.qml`) and by Hyprland binds (`config/hypr/hyprland.lua`).

## Settings: `state/sound.json`

Written by the Settings app (Sound pane), read by `sound.sh` on every play, so
changes apply at once. Missing file or keys fall back to the defaults.

| key | type | default | meaning |
|---|---|---|---|
| `alertSound` | string | `"Tink"` | file name (no extension) in `sounds/oga/Sounds/`: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink |
| `alertVolume` | number 0..1 | `0.75` | volume for every sound played by `sound.sh` |
| `uiSounds` | bool | `true` | "Play user interface sound effects": screenshot, trash, mount |
| `volumeFeedback` | bool | `true` | "Play feedback when volume is changed" |

## Events

| event | when | file | gated by |
|---|---|---|---|
| `notification` | a notification that asks for a sound (`sound-name` / `sound-file` hint) arrives; others are silent (`lib/nc.js` notificationSound) | alert sound | Focus / Do Not Disturb (no banner, no sound), the app's sound setting, `suppress-sound` |
| `alert` | critical notification, `qs ipc call sounds play alert`, system alerts (Panels.showAlert; not traced on the Mac) | alert sound | Focus |
| `power` | a laptop goes from battery to the charger (UPower) | `misc/PowerChime-connect_power.oga` | `uiSounds` |
| `poof` | available (no Dock item can be removed yet) | `SystemSounds/dock/poof item off dock.oga` | `uiSounds` |
| `volume` | Control Center Sound slider settles (180 ms debounce), volume keys | `misc/BezelServices-volume.oga` | `volumeFeedback` |
| `screenshot` | Cmd+Shift+3, Cmd+Shift+4 (slurp), Print | `SystemSounds/system/Screen Capture.oga` | `uiSounds` |
| `trash-empty` | Dock Trash right-click > Empty Trash | `SystemSounds/finder/empty trash.oga` | `uiSounds` |
| `trash-move`, `mount`, `unmount`, `sent` | available for other apps (Finder) | see `sound.sh` | `uiSounds` |

## Fallbacks

- Player: `pw-play`, then `paplay`, else silent.
- Unknown `alertSound` name: Tink. Missing sound file: silent.
- `HYPRK_MUTE=1` silences everything (set by `scripts/smoke.sh` and nested test sessions).
- `HYPRK_SOUND_LOG=<file>` appends `<event> <file>` for each sound that would play, muted or not.
- No startup chime: the Mac's is firmware, no file exists, so "Play sound on startup" (Settings) has nothing to play.
