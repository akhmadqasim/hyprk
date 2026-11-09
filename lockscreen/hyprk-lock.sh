#!/bin/sh
# Lock the session with the current desktop wallpaper: regenerates the config into the runtime dir, then runs hyprlock.
#   lockscreen/hyprk-lock.sh [--dark]      (bind it to Super+Ctrl+Q, call it from hypridle's lock_cmd)
HERE=$(cd "$(dirname "$0")" && pwd)
CONF=${XDG_RUNTIME_DIR:-/tmp}/hyprk-hyprlock.conf
D=${XDG_CONFIG_HOME:-$HOME/.config}
T=$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/hyprk-lock.XXXXXX") || exit 1
"$HERE/install.sh" --prefix "$T" "$@" >/dev/null && mv "$T/hypr/hyprlock.conf" "$CONF"
rm -rf "$T"
pidof hyprlock >/dev/null 2>&1 && exit 0     # already locked
exec hyprlock -c "$CONF"
