#!/bin/bash
# usage: shot.sh OUT.png [conf]   locks the private headless Hyprland (themes/gtk/tools/hypr-headless.sh) with the repo's hyprlock.conf and grims it.
# Only our nested compositor is locked; the lock is released with SIGUSR1 to OUR hyprlock pid (never pkill by name).
L=$(cd "$(dirname "$0")/.." && pwd); source $L/../themes/gtk/tools/hypr-env.sh
CONF=${2:-$L/hyprlock.conf}; OUT=$1
export WAYLAND_DISPLAY=$HK_WL FONTCONFIG_FILE=$L/../config/fontconfig/fonts.conf
MON=$(hyprctl monitors -j | python3 -c "import sys,json;print([m['name'] for m in json.load(sys.stdin) if m['name'].startswith('HEADLESS')][0])")
setsid timeout ${LIFE:-25} hyprlock -c "$CONF" > /tmp/claude-1000/hk/hyprlock.log 2>&1 &
P=$!
sleep ${WAIT:-6}
grim -o "$MON" "$OUT"
kill -USR1 $(pgrep -P $P hyprlock | head -1) 2>/dev/null; sleep 1; kill -- -$P 2>/dev/null
tail -5 /tmp/claude-1000/hk/hyprlock.log
