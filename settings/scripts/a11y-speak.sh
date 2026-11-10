#!/usr/bin/env bash
# Accessibility > Read & Speak through speech-dispatcher (spd-say).
# Usage: a11y-speak.sh selection        speak the selected text (Option-Esc); again stops it
#        a11y-speak.sh say <text>       speak a sample / announcement
# Rate comes from state/accessibility.json speechRate (0..1 -> spd-say -100..100).
# Exit 3 when spd-say is missing.
set -u
command -v spd-say >/dev/null || exit 3
root=$(cd "$(dirname "$0")/../.." && pwd)
state="${HYPRK_STATE:-$root/state}/accessibility.json"
rate=$(jq -r '.speechRate // 0.5' "$state" 2>/dev/null || echo 0.5)
rate=$(awk -v r="${rate:-0.5}" 'BEGIN { r = r * 200 - 100; if (r < -100) r = -100; if (r > 100) r = 100; printf "%d", r }')
flag="${XDG_RUNTIME_DIR:-/tmp}/hyprk-speaking"
case "${1:-}" in
    selection)
        # second press while speaking = stop, like macOS
        if [ -e "$flag" ]; then spd-say -C; rm -f "$flag"; exit 0; fi
        text=$(wl-paste -p -n 2>/dev/null) || text=""
        [ -n "$text" ] || exit 0
        touch "$flag"
        spd-say -w -r "$rate" -- "$text"
        rm -f "$flag" ;;
    say) shift; spd-say -r "$rate" -- "$*" ;;
    *) exit 2 ;;
esac
