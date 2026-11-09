# System Settings: unsupported and failure states

Rule: a pane never shows raw command output or errors. When a backend is missing or a
command fails, the pane keeps its normal layout, disables the controls that can't work,
and shows one calm line (`controls/InlineNote.qml`) or a full empty state
(`controls/Unavailable.qml`), the way macOS does.

Commands run through `Backend.run()`. Exit code 127 means "can't run": the binary is
missing, or the app runs under the plain `qml` tool, which has no process support
(only Quickshell does). Parsers in `Parsers.js` return safe empty values on any input.

| Pane | Condition | What the user sees |
|---|---|---|
| Wi-Fi | `nmcli` missing or NetworkManager not running | Wi-Fi switch disabled, sublabel "Not available on this system", note "NetworkManager (nmcli) is not available…" |
| Wi-Fi | no wifi device in `nmcli device` | sublabel "No hardware installed" (macOS wording), switch disabled, note pointing to Network |
| Wi-Fi | radio on/off or join fails | note "Wi-Fi could not be turned on…" / "Could not join …" |
| Bluetooth | `bluetoothctl` missing | "Bluetooth Unavailable" empty state, "BlueZ (bluetoothctl) is not installed." |
| Bluetooth | no controller ("No default controller available") | "Bluetooth Unavailable" empty state, "No Bluetooth controller was found…" |
| Bluetooth | connect / power fails | note "Couldn't reach …" / "Bluetooth could not be turned on." |
| Sound | `wpctl` missing or PipeWire down | slider and mute disabled, note "PipeWire (wpctl) is not available…" |
| Sound | no sinks | note "No output devices found." |
| Sound | `pw-play` missing (alert preview) | choice is still saved to `state/sound.json`, note "Sound previews need pw-play (PipeWire tools)." |
| Displays | not in a Hyprland session (`hyprctl` fails or returns no monitors) | placeholder display tile, popups disabled, note "Display details come from Hyprland…" |
| Displays | Hyprland rejects a mode | note "Hyprland did not accept that display setting." |
| Network | `nmcli` missing | row "Network services can't be listed" |
| Battery / Energy | no `Battery` in `/sys/class/power_supply/*/type` | sidebar shows **Energy** instead of **Battery** (macOS desktop behavior); Energy pane says battery settings are hidden |
| Wallpaper | `themes/wallpapers` empty | note "No wallpapers found yet…" |
| Wallpaper | no hyprpaper or swaybg | choice is still saved to `state/wallpaper.json` for the shell, note says how to apply it elsewhere |
| Wallpaper | thumbnail missing or `magick` missing | full image is decoded instead (slower, same look) |
| Appearance, Dock, Sound | state file missing or corrupt | defaults from `Parsers.js` (`appearanceDefaults`, `dockDefaults`, `soundDefaults`); next change rewrites a clean file |
| Appearance, Dock, Sound | running under `qml` (no processes) | files go through XMLHttpRequest and are polled every 2 s instead of inotify; `run.sh` exports `QML_XHR_ALLOW_FILE_READ/WRITE=1` |

## Reduce transparency

Accessibility > Display > "Reduce transparency" writes `reduceTransparency` to
`state/appearance.json` (the shell reads the same key). Settings honors it itself:
`Theme.sidebar.fill` switches from the translucent tint to an opaque color.

## Assets

| Asset | Preferred | Fallback |
|---|---|---|
| UI font | `themes/fonts/SFNS.ttf` loaded with FontLoader (weights through the `wght` axis) | Inter, then Cantarell, then Noto Sans (`Theme.pickFont`) |
| Pane icons | `themes/icons/settings/<pane id>.png` | colored rounded tile + Material Icons glyph (`fonts-material-design-icons-iconfont`, already installed) |
| Wallpaper thumbnails | freedesktop `~/.cache/thumbnails/large` (made by `scripts/thumbs.sh`) | the full image |
