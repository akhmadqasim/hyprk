#!/usr/bin/env bash
# Apply a wallpaper with whatever backend is running/installed.
# Exit 0 applied, 3 no backend available, other = backend failed.
set -u
img=$1
[ -f "$img" ] || exit 2
if command -v hyprctl >/dev/null && pgrep -x hyprpaper >/dev/null; then
    hyprctl hyprpaper preload "$img" >/dev/null && hyprctl hyprpaper wallpaper ",$img" >/dev/null
    exit $?
fi
if command -v swaybg >/dev/null && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    pkill -x swaybg
    setsid swaybg -m fill -i "$img" >/dev/null 2>&1 < /dev/null &
    exit 0
fi
exit 3
