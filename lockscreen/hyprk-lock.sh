#!/bin/sh
# Lock the session with the current desktop wallpaper: regenerates the config into the runtime dir, then runs hyprlock.
#   lockscreen/hyprk-lock.sh [--dark]      (bind it to the lock key, call it from hypridle's lock_cmd)
pgrep -u "$(id -u)" -x hyprlock >/dev/null 2>&1 && exit 0     # already locked
HERE=$(cd "$(dirname "$0")" && pwd)
RT=${XDG_RUNTIME_DIR:-/tmp}
T=$(mktemp -d "$RT/hyprk-lock.XXXXXX") || exit 1
"$HERE/install.sh" --prefix "$T" "$@" >/dev/null && mv "$T/hypr/hyprlock.conf" "$RT/hyprk-hyprlock.conf"
rm -rf "$T"
exec hyprlock -c "$RT/hyprk-hyprlock.conf"
