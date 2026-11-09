# System Settings: unsupported and failure states

Rule: a pane never shows raw command output or errors. When a backend is missing or a
command fails, the pane keeps its normal layout, disables the controls that can't work,
and shows one calm line (`controls/InlineNote.qml`) or a full empty state
(`controls/Unavailable.qml`), the way macOS does.

Commands run through `Backend.run()`. `Backend.status(code)` turns the exit code into
"missing" (127: the binary is missing, or the app runs under the plain `qml` tool, which
has no process support) / "failed" / "ok", and `Backend.statusNote()` gives the matching
calm sentence. Parsers in `Parsers.js` return safe empty values on any input.

Live updates come from event streams (`controls/EventSource.qml`): `nmcli monitor` (Wi-Fi,
Network), `pw-mon` (Sound), `dbus-monitor` on BlueZ (Bluetooth). When a stream can't run
or stops, the pane falls back to polling every 15 s.

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
| Keyboard | not in Hyprland (`hyprctl eval` fails) | values are still saved to `state/input.json`, note "Saved. It takes effect the next time Hyprland starts." |
| Notifications | app list script fails | note from `Backend.statusNote`; the global switches still work |
| Notifications | an app icon is not in the icon theme | gray tile with a generic glyph |
| Lock Screen | no hypridle/hyprlock | settings are only saved to `state/lock.json`; the shell applies them |
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

## Sidebar glass

The sidebar area of the window is translucent. Under Hyprland the compositor blurs what is
behind it (decoration.blur in config/hypr). Elsewhere (GNOME, plain `qml`) the sidebar
paints the current wallpaper itself, blurred and desaturated (`controls/SidebarBackdrop.qml`).
Reduce transparency turns both off and uses an opaque fill.

## Assets

| Asset | Preferred | Fallback |
|---|---|---|
| UI font | `themes/fonts/SFNS.ttf` loaded with FontLoader (weights through the `wght` axis) | Inter, then Cantarell, then Noto Sans (`Theme.pickFont`) |
| Pane icons | `themes/icons/settings/<pane id>.png` | colored rounded tile + Material Icons glyph (`fonts-material-design-icons-iconfont`, already installed) |
| Wallpaper thumbnails | freedesktop `~/.cache/thumbnails/large` (made by `scripts/thumbs.sh`) | the full image |
