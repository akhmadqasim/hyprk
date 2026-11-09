#!/usr/bin/env bash
# Real hyprk shell + plugin in a nested Hyprland (headless MBA): open a panel through the shell's
# IPC (targets this session's quickshell instance, other sessions may run the same shell), grim it.
#   shell-shot.sh PANEL OUT.png      e.g.  shell-shot.sh cc /mnt/code/hyprk/reference/ours/plugin-cc.png
set -u
PANEL=$1 OUT=$2
ROOT=/mnt/code/hyprk
source /mnt/code/hypr-dev/env.sh
RES=$(HYPRK_KEEP=1 HYPRK_HEADLESS=1 "$ROOT/scripts/smoke.sh" /tmp/lg-shell-start.png 2>&1)
LINE=$(grep '^export HYPRLAND_INSTANCE_SIGNATURE' <<<"$RES") || { echo "$RES"; exit 1; }
eval "${LINE%%#*}"
HPID=$(sed -n 's/.*# pid \([0-9]*\).*/\1/p' <<<"$LINE")
trap 'hyprctl dispatch "hl.dsp.exit()" >/dev/null 2>&1; sleep 1; kill -9 $HPID $(pgrep -P $HPID) 2>/dev/null' EXIT
ID=$(qs list --all 2>/dev/null | awk -v d="wayland/$WAYLAND_DISPLAY" '/^Instance/{id=$2; sub(":","",id)} /Config path: .*hyprk\/shell\/shell.qml/{ok=1} /Display connection/{ if (ok && $3==d) print id; ok=0 }' | head -1)
[ -n "$ID" ] || { echo "no shell instance on $WAYLAND_DISPLAY"; exit 1; }
qs ipc -i "$ID" call panels toggle "$PANEL" >/dev/null
sleep 2.5
grim -o MBA "$OUT" && echo "$OUT"
