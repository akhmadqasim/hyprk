# Lines the dist scripts must add (dist/ is not owned by the themes agent)

Why Ghostty and other libadwaita apps show the buttons on the right in the order min, max, close: GTK on Wayland reads
`button-layout` from GSettings first and `gtk-decoration-layout` in settings.ini only as a fallback. In the private session
there is no dconf database, so the schema default (Ubuntu: `appmenu:minimize,maximize,close`) wins. libadwaita also takes
its light/dark choice from the host's xdg-desktop-portal, not from settings.ini. Both are fixed by a GSettings keyfile plus two
environment variables.

## 1. `dist/lib/env.sh`, GTK block (replace the `sh .../themes/gtk/install.sh >/dev/null` line)

```sh
sh "$HYPRK_ROOT/themes/gtk/install.sh" --keyfile $([ "$theme" = dark ] && echo --dark) >/dev/null
export GSETTINGS_BACKEND=keyfile      # read $XDG_CONFIG_HOME/glib-2.0/settings/keyfile (button-layout, theme, colour scheme, fonts)
export ADW_DISABLE_PORTAL=1           # libadwaita: ignore the host portal's colour scheme, use the keyfile
export GTK_USE_PORTAL=0
```

`install.sh --keyfile` writes `$XDG_CONFIG_HOME/glib-2.0/settings/keyfile`:

```ini
[org/gnome/desktop/wm/preferences]
button-layout='close,minimize,maximize:'
[org/gnome/desktop/interface]
gtk-theme='MacOS27'            ; MacOS27-Dark with --dark
color-scheme='prefer-light'    ; prefer-dark with --dark
font-name='SF Pro 10'
monospace-font-name='SF Mono 10'
cursor-theme='hyprk-cursors'
```

The existing `settings.ini` block in env.sh can stay (it still carries `gtk-decoration-layout=close,minimize,maximize:` for GTK 3
apps that ignore GSettings). Add ` glib-2.0 ` to `_HYPRK_CFG_SKIP` (it currently lists gtk-3.0 gtk-4.0 qt6ct Kvantum fontconfig dconf) so farm mode
does not symlink the real `~/.config/glib-2.0` over our keyfile.

Trade-offs: `GSETTINGS_BACKEND=keyfile` replaces dconf for apps started inside this session, so they do not read the real dconf database
(and their own writes go to the keyfile). That is the intent for the private session, where there is no dconf database anyway.
`ADW_DISABLE_PORTAL=1` hides all host portal settings from libadwaita (colour scheme, accent), not only the colour scheme.

## 2. Fonts (already right in `dist/lib/env.sh`)

`themes/fonts/named` plus the `sans-serif -> SF Pro` alias is what GTK, Qt (qt6ct fonts `SF Pro` / `SF Mono`) and hyprlock use. The same
snippet as a drop-in is `themes/fontconfig/60-hyprk-sf.conf.in`.

## 3. Ghostty (optional, private config)

Ghostty (libadwaita) switches to the dark scheme when its terminal background is dark. Keep `window-theme = auto` (Ghostty's default)
so a dark terminal gets the dark MacOS27 title bar (#2B2B2B, close to a dark terminal background) like macOS Terminal; `system`
would give a white bar over a dark terminal.

```
# $XDG_CONFIG_HOME/ghostty/config
window-theme = auto
window-decoration = client
gtk-titlebar = true
```

## 4. Lock screen

`lockscreen/hyprk-lock.sh [--dark]` regenerates the hyprlock config from `state/wallpaper.json` (falls back to TahoeLight/TahoeDark)
and runs hyprlock. Use it for the lock bind and for hypridle's `lock_cmd`, instead of calling `hyprlock` directly.

## 5. Qt windows without a title bar

Qt apps have no client-side decorations on Hyprland, they only get Hyprland's border. A macOS title bar needs the hyprbars plugin:
see `themes/qt/hyprbars.lua` (proposal, not built or tested; it also excludes GTK apps that draw their own traffic lights).
