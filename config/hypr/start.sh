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
unset HYPRK_GLASS        # decided by hyprland.lua after loading the glass plugin
export XCURSOR_THEME=hyprk-cursors HYPRCURSOR_THEME=hyprk-cursors XCURSOR_SIZE=24 HYPRCURSOR_SIZE=24
HYPRK_DEV=${HYPRK_DEV:-$HYPRK_ROOT/../hypr-dev}   # optional source-built prefix
[ -f "$HYPRK_DEV/env.sh" ] && source "$HYPRK_DEV/env.sh"
exec env -u HYPRLAND_INSTANCE_SIGNATURE Hyprland --config "${HYPRK_CONFIG:-$HYPRK_ROOT/config/hypr/hyprland.lua}" "$@"
