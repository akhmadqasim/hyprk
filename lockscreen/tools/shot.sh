#!/bin/bash
# usage: shot.sh OUT.png [conf]   locks the private headless Hyprland (themes/gtk/tools/hypr-headless.sh) with the repo's hyprlock.conf and grims it.
# Only our nested compositor is locked; the lock is released with SIGUSR1 to OUR hyprlock child (never pkill by name).
L=$(cd "$(dirname "$0")/.." && pwd); source "$L/../themes/gtk/tools/hypr-env.sh"
CONF=${2:-$L/hyprlock.conf}; OUT=$1
export WAYLAND_DISPLAY=$HK_WL FONTCONFIG_FILE=$HK_FONTCONF
MON=$(hk_monitor) || exit 1
setsid timeout ${LIFE:-25} hyprlock -c "$CONF" > "$HK_DIR/hyprlock.log" 2>&1 &
P=$!
for _ in $(seq 1 40); do hyprctl layers 2>/dev/null | grep -qi lock && break; sleep 0.25; done
sleep ${SETTLE:-2}
grim -o "$MON" "$OUT"
HL=$(pgrep -P $P hyprlock | head -1); [ -n "$HL" ] && kill -USR1 "$HL"
sleep 0.5; kill -- -$P 2>/dev/null
tail -5 "$HK_DIR/hyprlock.log"
