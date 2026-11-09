#!/bin/bash
# usage: shot.sh OUT.png [conf]   locks the private headless Hyprland (themes/gtk/tools/hypr-headless.sh) with the repo's hyprlock.conf and grims it.
# Only our nested compositor is locked; the lock is released with SIGUSR1 to OUR hyprlock child (never pkill by name).
L=$(cd "$(dirname "$0")/.." && pwd); source "$L/../themes/gtk/tools/hypr-env.sh"
OUT=$1
# install into a scratch dir so wallpaper/avatar paths are resolved from this checkout, not hard-coded
TMPC=$(mktemp -d "$HK_DIR/lock.XXXX"); "$L/install.sh" --prefix "$TMPC" >/dev/null; CONF=${2:-$TMPC/hypr/hyprlock.conf}
export WAYLAND_DISPLAY=$HK_WL FONTCONFIG_FILE=$HK_FONTCONF
MON=$(hk_monitor) || exit 1
setsid timeout ${LIFE:-25} hyprlock -c "$CONF" > "$HK_DIR/hyprlock.log" 2>&1 &
P=$!
for _ in $(seq 1 40); do grep -q "onLockLocked" "$HK_DIR/hyprlock.log" 2>/dev/null && break; sleep 0.25; done
grep -q "onLockLocked" "$HK_DIR/hyprlock.log" || { echo "hyprlock did not lock, see $HK_DIR/hyprlock.log" >&2; kill -- -$P 2>/dev/null; rm -rf "$TMPC"; exit 1; }
sleep ${SETTLE:-2}
grim -o "$MON" "$OUT"
HL=$(pgrep -P $P hyprlock | head -1); [ -n "$HL" ] && kill -USR1 "$HL"
sleep 0.5; kill -- -$P 2>/dev/null
rm -rf "$TMPC"
tail -5 "$HK_DIR/hyprlock.log"
