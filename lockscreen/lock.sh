#!/bin/sh
# Lock the hyprk session (the Ctrl+Cmd+Q bind, hypridle's lock_cmd, scripts):
#   1. the shell's lock screen: `qs ipc call lock lock` on the hyprk shell instance that runs on THIS
#      compositor (same shell.qml and Wayland display, so a nested session never locks its host)
#   2. else lockscreen/hyprk-lock.sh (hyprlock), with --dark from state/appearance.json
#   lockscreen/lock.sh [--dark]
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
QML=$ROOT/shell/shell.qml
if command -v qs >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    pid=$(qs list --all 2>/dev/null | awk -v p="$QML" -v d="wayland/$WAYLAND_DISPLAY" '
        /^Instance / { pid = ""; cfg = "" }
        /Process ID:/ { pid = $3 }
        /Config path:/ { sub(/^[ \t]*Config path: /, ""); cfg = $0 }
        /Display connection:/ { if (cfg == p && $3 == d) { print pid; exit } }')
    if [ -n "$pid" ]; then
        r=$(qs ipc --pid "$pid" call lock lock 2>/dev/null)
        case $r in ok|in|locked|out) exit 0 ;; esac
        echo "lock.sh: the shell did not take the lock (${r:-no answer}), using hyprlock" >&2
    fi
fi
dark=
[ $# -eq 0 ] && command -v jq >/dev/null 2>&1 &&
    [ "$(jq -r '.dark // false' "${HYPRK_STATE:-$ROOT/state}/appearance.json" 2>/dev/null)" = true ] && dark=--dark
exec "$HERE/hyprk-lock.sh" ${dark:+"$dark"} "$@"
