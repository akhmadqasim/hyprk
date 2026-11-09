#!/usr/bin/env bash
# GPU frame-time benchmark of the liquidglass plugin with the real hyprk shell.
# Headless 3840x2160 @ 1.5 output, Dock + Control Center + a notification banner open over a
# terminal that redraws constantly, so every frame repaints the glass.
# Prints `hyprctl liquidglass` for the glass and with the plugin disabled (plain Hyprland blur).   Usage: plugin/test/bench.sh [seconds per run]
set -u
SECS=${1:-8}
ROOT=/mnt/code/hyprk
source /mnt/code/hypr-dev/env.sh
OUT=$(HYPRK_KEEP=1 HYPRK_HEADLESS=1 "$ROOT/scripts/smoke.sh" /tmp/lg-bench-start.png 2>&1)
LINE=$(grep '^export HYPRLAND_INSTANCE_SIGNATURE' <<<"$OUT") || { echo "$OUT"; exit 1; }
eval "${LINE%%#*}"
HPID=$(sed -n 's/.*# pid \([0-9]*\).*/\1/p' <<<"$LINE")
trap 'hyprctl dispatch "hl.dsp.exit()" >/dev/null 2>&1; sleep 1; kill -9 $HPID $(pgrep -P $HPID) 2>/dev/null' EXIT

hc() { hyprctl "$@"; }
hc eval 'hl.monitor({ output = "MBA", mode = "3840x2160@60", position = "auto", scale = 1.5 })' >/dev/null
sleep 1
hc dispatch 'hl.dsp.focus({ monitor = "MBA" })' >/dev/null
hc dispatch 'hl.dsp.exec_cmd("foot -e sh -c \"while :; do date +%s%N; sleep 0.005; done\"")' >/dev/null
sleep 2
qs -p "$ROOT/shell" ipc call panels toggle cc >/dev/null 2>&1
hc eval 'hl.config({ plugin = { liquidglass = { stats = 1 } } })' >/dev/null

run() {
    hc eval "hl.config({ plugin = { liquidglass = { $1 } } })" >/dev/null
    qs -p "$ROOT/shell" ipc call notifs test "Benchmark" "banner glass" >/dev/null 2>&1
    sleep 1
    hc liquidglass reset >/dev/null
    sleep "$SECS"
    echo "== $2"
    hc liquidglass
}
run "enabled = 1" "liquid glass (default)"
run "enabled = 0" "plugin disabled (plain Hyprland blur)"
WAYLAND_DISPLAY=$WAYLAND_DISPLAY grim -o MBA "$ROOT/reference/ours/plugin-bench.png" 2>/dev/null
