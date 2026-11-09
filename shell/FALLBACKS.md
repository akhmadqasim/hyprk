# hyprk shell fallbacks

Every surface has a designed state for missing features, so nothing looks broken
(no empty boxes, no error text). Logic that decides availability lives in
`lib/state.js` and is unit tested (`node shell/tests/run.mjs`).

| Missing | Detection | What the user sees |
|---|---|---|
| Glass blur (no ImageMagick, blurred wallpaper not produced) | `scripts/wallpaper.sh` prints empty `BLUR=`, `Theme.blurAvailable = false` | Solid tinted material, like macOS "Reduce transparency": `Theme.glass.solid` (#ECECEE light, #2A2A2C dark). Same radii, rim and shadow. |
| User wants no transparency | `Theme.reduceTransparency`, from `state/appearance.json` `{"reduceTransparency": true}`, the Control Center display button, or `qs ipc call theme toggleTransparency` | Same solid material as above. |
| liquidglass plugin (opt-in, `HYPRK_LIQUIDGLASS=1`) | config loads `plugin/build/libliquidglass.so` in a `pcall`; only on success it exports `HYPRK_GLASS=plugin` | With the plugin: Glass items register their shapes in `ShellWindow` (ext-background-effect region) and draw no QML material; the plugin draws tint, rim, refraction and shadow. Missing or failing plugin: QML material as below. Reduce transparency always uses the solid material. |
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
