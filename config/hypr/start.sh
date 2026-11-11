#!/usr/bin/env bash
# Start Hyprland with the hyprk config. Env that must exist before Hyprland
# starts (hyprcursor reads XDG_DATA_DIRS once at load) is set here.
HYPRK_ROOT=${HYPRK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
export HYPRK_ROOT
. "$HYPRK_ROOT/config/hypr/state-dir.sh"   # exports HYPRK_STATE: the one state folder (shell, Settings, Lua config)
export XDG_DATA_DIRS="$HYPRK_ROOT/config:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"   # config/icons/hyprk-cursors
# App icons: the local hyprk-apple layer (user-extracted macOS icons, themes/icons/build-apple-theme.sh),
# else WhiteSur (themes/icons/install.sh, in the hyprk data prefix), else the system theme.
# Either way the shell puts non-squircle icons on a macOS 26 tile (ui/HyprK/AppIconTile.qml).
HYPRK_DATA=${HYPRK_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/hyprk}
if [ -z "${QS_ICON_THEME:-}" ]; then
    if [ -f "$HYPRK_ROOT/themes/icons/hyprk-apple/index.theme" ]; then export QS_ICON_THEME=hyprk-apple
    elif [ -f "$HYPRK_DATA/icons/WhiteSur/index.theme" ]; then export QS_ICON_THEME=WhiteSur
    fi
fi
export XDG_DATA_DIRS="$HYPRK_ROOT/themes:$HYPRK_DATA:$XDG_DATA_DIRS"   # themes/icons/hyprk-apple, <data>/icons/WhiteSur
export XCURSOR_PATH="$HYPRK_ROOT/themes/cursors/theme:${XCURSOR_PATH:-/usr/share/icons}"
# the compositor's own text (the plugin's title bars) and the apps it starts use the shell's fontconfig: SF Pro for
# sans-serif and system-ui, Apple Color Emoji (judge #17: titles were Noto Sans). An explicit FONTCONFIG_FILE wins.
[ -z "${FONTCONFIG_FILE:-}" ] && [ -f "$HYPRK_ROOT/config/fontconfig/fonts.conf" ] && export FONTCONFIG_FILE=$HYPRK_ROOT/config/fontconfig/fonts.conf
unset HYPRK_GLASS        # decided by hyprland.lua after loading the glass plugin
export XCURSOR_THEME=hyprk-cursors HYPRCURSOR_THEME=hyprk-cursors XCURSOR_SIZE=24 HYPRCURSOR_SIZE=24
# GTK apps of this session (JUDGE-95 #3): on Wayland GTK reads the theme, button-layout and colour scheme from GSettings
# and the host's portal, not from settings.ini, so they came up as Adwaita with the controls on the right and in the
# host's light/dark. The session gets a private config dir inside $HYPRK_STATE (every real ~/.config entry linked in,
# as dist farm mode, except the GTK/GLib ones) with the MacOS27 theme and a GSettings keyfile that hyprland.lua's
# hyprk_appearance() rewrites on every appearance change (GLib watches the file, GTK 3 and libadwaita follow live).
# Nothing outside $HYPRK_STATE is written; the real dconf and gsettings are not read or touched. HYPRK_GTK=0: off.
if [ "${HYPRK_GTK:-1}" = 1 ]; then
    . "$HYPRK_ROOT/dist/lib/env.sh"   # _hyprk_farm
    G=$HYPRK_STATE/gtk-session
    mkdir -p "$G/config/glib-2.0/settings" "$G/data" && chmod 700 "$G"
    _hyprk_farm "${XDG_CONFIG_HOME:-$HOME/.config}" "$G/config" " gtk-3.0 gtk-4.0 glib-2.0 "
    XDG_CONFIG_HOME=$G/config XDG_DATA_HOME=$G/data sh "$HYPRK_ROOT/themes/gtk/install.sh" >/dev/null
    export XDG_CONFIG_HOME=$G/config XDG_DATA_DIRS="$G/data:$XDG_DATA_DIRS" HYPRK_GTK_KEYFILE=$G/config/glib-2.0/settings/keyfile
    export GSETTINGS_BACKEND=keyfile ADW_DISABLE_PORTAL=1 HDY_DISABLE_PORTAL=1 GTK_USE_PORTAL=0 GDK_DEBUG="no-portals${GDK_DEBUG:+,$GDK_DEBUG}"
    unset GTK_THEME   # it would pin one appearance
fi
HYPRK_DEV=${HYPRK_DEV:-$HYPRK_ROOT/../hypr-dev}   # optional source-built prefix
[ -f "$HYPRK_DEV/env.sh" ] && source "$HYPRK_DEV/env.sh"
exec env -u HYPRLAND_INSTANCE_SIGNATURE Hyprland --config "${HYPRK_CONFIG:-$HYPRK_ROOT/config/hypr/hyprland.lua}" "$@"
