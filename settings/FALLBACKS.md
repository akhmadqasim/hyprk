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
or stops, the pane falls back to polling every 15 s. A stream dies with Settings, also when
Settings is killed (`Backend.stream` starts it through `setpriv --pdeathsig TERM`; without
setpriv it runs as before).

Settings of the host desktop (`gsettings`, today only "Prefer non-blinking cursor") go through
`Backend.runHost()`: they are written only when hyprk is the login session (`HYPRK_ALLOW_POWER=1`
from `dist/hyprk-session`, the same signal the shell's power actions use). In a nested preview,
a smoke run or a standalone `settings/run.sh` on another desktop only hyprk's own state changes
and the row says so.

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
| Keyboard | not in Hyprland (`hyprctl eval` fails) | values are saved to `state/input.json`, note "Saved to state/input.json, but Hyprland isn't reachable here, so the keyboard didn't change." |
| Notifications | app list script fails | note from `Backend.statusNote`; the global switches still work |
| Notifications | an app icon is not in the icon theme | gray tile with a generic glyph |
| Lock Screen | no hypridle/hyprlock | settings are only saved to `state/lock.json` |
| Lock Screen | a stored timeout that is not in the menu | shown as an extra item, e.g. "For 15 min" |
| Displays | Hyprland rejects a mode | note "Hyprland did not accept that display setting." |
| Displays (Looks like) | `HYPRK_SCALE_POLICY=off` in the Hyprland session | sizes shown dimmed and disabled, selection = what Hyprland runs, note "Display scaling is turned off for this session (HYPRK_SCALE_POLICY=off)." |
| Displays (Looks like) | virtual output (MBA, HEADLESS*, WAYLAND-*, X11-*) without `HYPRK_NATIVE_<OUT>` | no size list, disabled Resolution row with the current size, note "This is a virtual display. Its size is set by its own rule." |
| Displays (Looks like) | `HYPRK_LOOKS_LIKE` / `HYPRK_LOOKS_LIKE_<OUT>` set (env wins over the saved choice) | sizes disabled, selection = the env size, note "Set by HYPRK_LOOKS_LIKE_<OUT> for this session." |
| Displays (Looks like) | `config/hypr/scale-policy.lua` report fails (`hyprctl eval` error, file missing) | disabled Resolution row, note "Display sizes come from hyprk's scale policy, which Hyprland could not run here." |
| Displays (Looks like) | a saved size in `state/displays.json` that has no clean Hyprland scale | scale-policy.lua ignores it (logged), Default is used and shown |
| Network | `nmcli` missing | row "Network services can't be listed" |
| Battery / Energy | no `Battery` in `/sys/class/power_supply/*/type` | sidebar shows **Energy** instead of **Battery** (macOS desktop behavior); Energy pane says battery settings are hidden |
| Wallpaper | `themes/wallpapers` empty | note "No wallpapers found yet…" |
| Wallpaper | no hyprpaper or swaybg | choice is still saved to `state/wallpaper.json` for the shell, note says how to apply it elsewhere |
| Wallpaper | thumbnail missing or `magick` missing | full image is decoded instead (slower, same look) |
| Appearance, Dock, Sound | state file missing or corrupt | defaults from `Parsers.js` (`appearanceDefaults`, `dockDefaults`, `soundDefaults`); next change rewrites a clean file |
| Appearance, Dock, Sound | running under `qml` (no processes) | files go through XMLHttpRequest and are polled every 2 s instead of inotify; `run.sh` exports `QML_XHR_ALLOW_FILE_READ/WRITE=1` |

## Accessibility

Overview and sub-pages follow macOS 27 (support.apple.com mchlp1400). Display flags live in
`state/appearance.json` (`reduceTransparency`, `increaseContrast`, `reduceMotion`), the rest
in `state/accessibility.json` (`panes/accessibility/A11y.js`). Each change also writes
`state/accessibility.lua` (+ `state/a11y-screen.frag`) and runs it with `hyprctl eval`;
`shell/services/A11y.qml` runs the same file at login and after every Hyprland reload.

| Feature | Linux backend | Fallback |
|---|---|---|
| Reduce transparency | Settings + shell themes (opaque fills) | — |
| Increase contrast | Settings theme (strokes, separators, secondary text, no transparency), Hyprland window borders; shell via `A11y.increaseContrast` | — |
| Reduce motion | Settings controls, Hyprland: no window zoom, Spaces cross-fade; shell via `A11y.ms()` | — |
| Invert colors (Smart/Classic), Display contrast, Color filters (Grayscale, Protanopia, Deuteranopia, Tritanopia, Tint) | Hyprland `decoration:screen_shader` = `config/hypr/shaders/a11y-filter.frag` with #defines | screencopy (grim, screen sharing) skips screen shaders, so screenshots show the unfiltered screen |
| Pointer size | `hyprctl setcursor` + `XCURSOR_SIZE`/`HYPRCURSOR_SIZE` for new apps | — |
| Pointer colors, Shake to locate, Text size | none | rows dimmed with a one-line reason |
| Zoom shortcuts ⌥⌘8 / ⌥⌘= / ⌥⌘−, scroll + modifier | Hyprland `cursor:zoom_factor` (`scripts/a11y-zoom.sh`) | Split Screen / Picture-in-Picture fall back to Full Screen with a note; no trackpad pinch |
| VoiceOver (⌘F5) | Orca (`scripts/a11y-orca.sh`, stops only the Orca it started) | no `orca`: switch disabled, "Install the Orca screen reader" |
| Read & Speak: Speak selection (⌥Esc), rate, Play Sample; Live Speech | speech-dispatcher `spd-say` (`scripts/a11y-speak.sh`), primary selection via `wl-paste -p` | no `spd-say`: rows disabled, "Speech needs speech-dispatcher" |
| Prefer non-blinking cursor | `gsettings org.gnome.desktop.interface cursor-blink` (written only when toggled: it is shared with the host desktop) | no gsettings: disabled with a note |
| Sticky Keys, Slow Keys, Full Keyboard Access, Accessibility Keyboard, Pointer Control methods | none in Hyprland/xkbcommon | disabled rows + note |
| Flash screen on alert, Mono audio, Speak announcements, Auto-play animated images, Captions SDH, Differentiate without color | saved only | note "Saved for …" |
| Hover Text, Audio Descriptions, Hearing Devices, Live Captions, Name Recognition, Voice Control, Switch Control, Personal Voice, Vocal Shortcuts, Siri, Shortcut | none | "<Feature> Unavailable" empty state (`accessibility/Unsupported.qml`) |
| Hyprland not reachable | — | values are saved; note "Saved, but Hyprland isn't reachable here…" |

## Sidebar glass

Under Hyprland the sidebar is a light warm fill at 88 % alpha over the compositor blur
(decoration.blur in config/hypr), so the desktop only softly shows through, like the
reference (238,236,234). Elsewhere (GNOME, plain `qml`) and with Reduce transparency it
is the same colour, opaque.

## Assets

| Asset | Preferred | Fallback |
|---|---|---|
| UI font | `themes/fonts/SFNS.ttf` loaded with FontLoader (weights through the `wght` axis) | Inter, then Cantarell, then Noto Sans (`Theme.pickFont`) |
| Glyphs in rows and the toolbar | SF Symbols outlines in `ui/HyprK/sfpaths.js` (drawn by HyprK `SfSymbol`, which the shared controls use too; add names with `ui/scripts/sfpaths.py`) | none: a name that is not in the table draws nothing |
| Pane icons | `themes/icons/settings/<pane id>@<64\|128>-<default\|dark\|clear\|tinted>-<light\|dark>.png` (all 23 panes, picked by the icon style and appearance) | a plain coloured rounded tile |
| Row icons | `themes/icons/settings/<id>@48-...png`: the Mac's 24 pt row icon at 2x, built from Apple's graphic icon configuration of that row (`Panes.js` rowIcons, `themes/icons/settings/graphic.json`) | a plain coloured rounded tile |
| Wallpaper thumbnails | freedesktop `~/.cache/thumbnails/large` (made by `scripts/thumbs.sh`) | the full image |

## Files written for other parts of hyprk

They go to `$HYPRK_STATE` (`Backend.stateDir`, set once by `config/hypr/start.sh`/`run.sh`: `<root>/state` if writable, else `~/.local/state/hyprk`; plain `qml` has no env and uses `<root>/state`).

`appearance.json`: `mode` is light / dark / auto and `dark` is what is shown now. With Auto, `dark` is the sun's
answer (dark while the sun is below -3 degrees at the system time zone's city, `Parsers.js` autoDark: the rule of
macOS 27.2.1 without Location Services); Settings sets it when it starts, when Auto is chosen and at each crossing
while it runs. Nothing changes it while Settings is closed. `highlight` is the text highlight colour ("" = Automatic).

Settings writes these; the readers belong to the shell/config agents. As of this commit
`appearance.json`, `dock.json`, `sound.json` and `wallpaper.json` have readers or are
planned; `displays.json` is read by `config/hypr/scale-policy.lua` (Hyprland start and hotplug); **`notifications.json`, `lock.json` and `input.json` have no reader yet**, so those
panes only store the choice until the shell (notification server, hypridle glue, login
config) reads them.

Text field menu (HyprK `TextMenu`: search field, Live Speech phrase): with the liquidglass plugin (HYPRK_GLASS=plugin,
`popup_classes` lists org.hyprk.Settings in config/hypr/hyprland.lua) the plugin draws the menu glass behind it and the
menu draws no fill; without the plugin, or with Reduce Transparency / Increase Contrast, the opaque menu fill and stroke.
Zoom (toolbar double-click, Option-click on the green light): Hyprland's maximized mode; outside Hyprland the xdg request.
