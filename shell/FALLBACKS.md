# hyprk shell fallbacks

Every surface has a designed state for missing features, so nothing looks broken
(no empty boxes, no error text). Logic that decides availability lives in
`lib/state.js` and is unit tested (`node shell/tests/run.mjs`).

| Missing | Detection | What the user sees |
|---|---|---|
| Glass blur (no ImageMagick, blurred wallpaper not produced) | `scripts/wallpaper.sh` prints empty `BLUR=`, `Theme.blurAvailable = false` | Solid tinted material, like macOS "Reduce transparency": `Theme.glass.solid` (#ECECEE light, #2A2A2C dark). Same radii, rim and shadow. |
| User wants no transparency | `Theme.reduceTransparency`, from `state/appearance.json` `{"reduceTransparency": true}`, the Control Center display button, or `qs ipc call theme toggleTransparency` | Same solid material as above. |
| liquidglass plugin (on by default, `HYPRK_LIQUIDGLASS=0` disables) | config loads `plugin/build/libliquidglass.so` in a `pcall`; only on success it exports `HYPRK_GLASS=plugin` | With the plugin: Glass items register their shapes in `ShellWindow` (ext-background-effect region) and draw no QML material; the plugin draws tint, rim, refraction and shadow. Missing or failing plugin: QML material as below. Reduce transparency always uses the solid material. |
| Menu bar title pill and top dimming | always QML, no plugin needed: only the wallpaper is ever under the bar | The pill samples the blurred wallpaper (`shaders/topdim.frag`); without it (no ImageMagick, Reduce transparency) it is the solid material. The top dimming of bright wallpapers is a static shader strip in `Background.qml`, drawn once per wallpaper. |
| Compositor glass plugin | not required | The shell draws its own frosted material from the blurred wallpaper. Hyprland layer rules (`config/hypr/hyprland.lua`) add real blur of windows behind when available. |
| Wallpaper | no image in `themes/wallpapers` | Generated blue/purple gradient (cached in `~/.cache/hyprk`). No ImageMagick: the background layer shows a flat `#3a6fb0` / `#1c1c1e`. |
| Battery (desktop PC) | `State.hasBattery(UPower.devices)`: needs a present, power-supply battery | Battery item hidden in the menu bar (macOS desktops show none). |
| NetworkManager / Wi-Fi device | `State.wifiDevice(Networking.devices)` | Menu bar Wi-Fi icon hidden. Control Center Wi-Fi module dimmed, subtitle "Not Available". |
| Wi-Fi off / not connected | device state | Menu bar shows the slashed Wi-Fi glyph at 50% opacity. CC subtitle "Off" / "Not Connected". |
| Bluetooth adapter | `Bluetooth.defaultAdapter` is null | CC Bluetooth module dimmed, "Not Available", not clickable. |
| PipeWire / no sink | `State.hasAudio(Pipewire.ready, sink)` | CC Sound module dimmed, slider not draggable. |
| Backlight (external monitor) | `brightnessctl -c backlight info` fails | CC Display module dimmed, slider shown full and not draggable. |
| MPRIS player | `State.pickPlayer(Mpris.players)` returns null | Now Playing shows "Not Playing", empty art tile, controls at reduced opacity (macOS behavior). |
| AirDrop, Stage Manager, Screen Mirroring | no backend | AirDrop toggles a local state only; Stage Manager and Mirroring buttons dimmed. |
| Fonts | `Theme.pickFont()` checks `Qt.fontFamilies()` | SF Pro (or extracted "System Font"/.SF NS via `config/fontconfig/fonts.conf`), then Inter, Cantarell, Sans Serif. |
| App icons | `Apps.iconUrl()` | Mapped macOS icon from `themes/icons/apps`, else the icon theme, else `themes/icons/system/GenericApplicationIcon`. |
| Dock app without .desktop entry | `Search.matchEntry()` returns null | Shown with its window class as name and the generic app icon; still focusable. |
| Notification without icon | no appIcon / desktop entry | Generic app icon; title falls back to the app name, then "Notification". |
| Apps with no window after launch | launch timer (6 s) | Dock bounce stops after 6 s. |
| Power actions in a nested/test session | `HYPRK_ALLOW_POWER` unset | Sleep/Restart/Shut Down/Lock only log; Log Out exits Hyprland. |
| No running apps for Cmd+Tab | empty list | Switcher does not open. |
| Spotlight file search tool | `services/FileSearch.qml` probes plocate, locate, fd, fdfind | First found is used; else `find` over $HOME (hidden dirs skipped, 40 hits, 180 ms debounce). No recently-used.xbel: Files shows "No Recent Files". |
| Clipboard history backend | `services/Clipboard.qml`: wl-paste/wl-copy, cliphist | Off until the user turns it on (Spotlight Cmd+4 "Turn On", or `state/spotlight.json` `clipboardHistory` set to "30m", "8h" or "7d"). cliphist when installed (images show a photo glyph, no thumbnail; cliphist keeps no dates, so retention is not applied and the list refreshes when the view opens), else `scripts/clipboard.sh` in `$XDG_STATE_HOME/hyprk/clipboard` (200 items, 20 MB max each, password-manager copies skipped). No wl-clipboard: the Clipboard view says so and offers no switch. Turning it off (an explicit "off", not a missing or broken file) deletes the history. Selecting an item copies it (no auto-paste: no virtual keyboard tool assumed). |
| Spotlight actions without backend | no Wi-Fi device / Bluetooth adapter / slurp | The Wi-Fi, Bluetooth, area-screenshot actions are not listed. Power actions show "Blocked in this session" without `HYPRK_ALLOW_POWER=1`. |

## Settings state files (`state/*.json`, written by the Settings app)

Read by `services/Prefs.qml` (and `Theme.qml`, `scripts/sound.sh`). Missing or broken files keep the defaults
from `settings/Parsers.js`. The folder is `$HYPRK_STATE`, set once by `config/hypr/start.sh` (`state-dir.sh`): `<root>/state` if writable, else `~/.local/state/hyprk`.

| File | Effect in the shell |
|---|---|
| `appearance.json` | dark mode, Reduce transparency |
| `sound.json` | alert sound, volume, UI sounds, volume feedback (see SOUNDS.md) |
| `notifications.json` | per app (`apps["<desktop id>"]`): `allow: false` drops the notification, `style: "none"` = Notification Center only, `"alerts"` = banner stays until dismissed, `sounds: false` = silent. `previews: "never"` hides bodies. |
| `lock.json` | idle display off after `displayOffAfter` s (Hyprland DPMS); lock after `screenSaverAfter + requirePasswordAfter` s with hyprlock + `lockscreen/hyprlock.conf`, loginctl fallback, only when `HYPRK_ALLOW_POWER=1`. 0 = never. |
| `input.json` | keyboard repeat applied with `hyprctl eval` at start and on change (0.57 has no `hyprctl keyword`) |
| `spotlight.json` | `clipboardHistory` ("off" default, "30m", "8h", "7d"), `quickKeys` (`{"<action id>": "<key>"}`, written by Spotlight's "Add Quick Keys") |
| `wallpaper.json` | `path` replaces the default wallpaper; menu bar text turns dark over bright wallpaper tops |
