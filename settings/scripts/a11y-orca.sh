#!/usr/bin/env bash
# Accessibility > VoiceOver on Linux: the Orca screen reader.
# Usage: a11y-orca.sh start|stop|toggle|status|restore
#   restore  start Orca if state/accessibility.json says voiceOver, once per Hyprland
#            session (state/accessibility.lua runs it at login and on every apply)
# Exit: 0 ok (status: running), 1 status: not running, 3 Orca not installed.
# Stops only the Orca this script started (pid file); an Orca started elsewhere
# counts as running but is left alone.
# toggle (⌘F5) also records the choice in accessibility.json (voiceOver).
set -u
root=$(cd "$(dirname "$0")/../.." && pwd)
state="${HYPRK_STATE:-$root/state}/accessibility.json"
run="${XDG_RUNTIME_DIR:-/tmp}"
pidf="$run/hyprk-orca.pid"

ours() {
    local p
    p=$(cat "$pidf" 2>/dev/null) || return 1
    [ -n "$p" ] && [ "$(cat /proc/"$p"/comm 2>/dev/null)" = orca ]
}
running() { ours || pgrep -u "$(id -u)" -x orca >/dev/null; }
record() {   # record <true|false> into accessibility.json, keeping other keys
    command -v jq >/dev/null || return 0
    mkdir -p "$(dirname "$state")"
    local t; t=$(mktemp "$state.XXXXXX") || return 0
    { jq --argjson v "$1" '.voiceOver = $v' "$state" 2>/dev/null || jq -n --argjson v "$1" '{voiceOver: $v}'; } > "$t" && mv "$t" "$state"
}
start() {
    command -v orca >/dev/null || exit 3
    running && return 0
    setsid orca >/dev/null 2>&1 < /dev/null &
    echo $! > "$pidf"
}
stop() {
    ours && kill "$(cat "$pidf")"
    rm -f "$pidf"
}
case "${1:-status}" in
    start) start ;;
    stop) stop ;;
    toggle) if running; then stop; record false; else start; record true; command -v spd-say >/dev/null && spd-say "VoiceOver on" & fi ;;
    status) command -v orca >/dev/null || exit 3; running ;;
    restore)
        flag="$run/hyprk-orca-restored-${HYPRLAND_INSTANCE_SIGNATURE:-none}"
        [ -e "$flag" ] && exit 0
        touch "$flag"
        [ "$(jq -r '.voiceOver // false' "$state" 2>/dev/null)" = true ] && start
        exit 0 ;;
    *) exit 2 ;;
esac
