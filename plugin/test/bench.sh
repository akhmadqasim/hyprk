#!/usr/bin/env bash
# GPU frame-time benchmark of the liquidglass plugin with the real hyprk shell.
# Headless 3840x2160 @ 1.5 output, Dock + Control Center + a notification banner open over a
# terminal that redraws constantly, so every frame repaints the glass.
# Prints `hyprctl liquidglass` for the glass and with the plugin disabled (plain Hyprland blur).
# Usage: plugin/test/bench.sh [seconds per run]
#   BENCH_OUT=dir  where the start and end screenshots go (default: a fresh dir under $XDG_CACHE_HOME or ~/.cache)
#   Pass HYPRK_STATE / XDG_CACHE_HOME to keep the session's state and logs out of the checkout.
set -u
SECS=${1:-8}
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
source "${HYPRK_DEV:-$ROOT/../hypr-dev}/env.sh"
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/hyprk
OUTDIR=${BENCH_OUT:-$(mkdir -p "$CACHE" && mktemp -d "$CACHE/lg-bench.XXXXXX")}
mkdir -p "$OUTDIR"
OUT=$(HYPRK_KEEP=1 HYPRK_HEADLESS=1 "$ROOT/scripts/smoke.sh" "$OUTDIR/start.png" 2>&1)
LINE=$(grep '^export HYPRLAND_INSTANCE_SIGNATURE' <<<"$OUT") || { echo "$OUT"; exit 1; }
eval "${LINE%%#*}"
HPID=$(sed -n 's/.*# pid \([0-9]*\).*/\1/p' <<<"$LINE")
KIDS=$(pgrep -P "$HPID")
trap 'hyprctl dispatch "hl.dsp.exit()" >/dev/null 2>&1; sleep 1; kill -9 $HPID $KIDS 2>/dev/null' EXIT
# this session's shell only: other test sessions run the same config path, and `qs -p` would pick any of them
QPID=$(qs list --all 2>/dev/null | awk -v d="wayland/$WAYLAND_DISPLAY" '/Process ID/ {p = $3} $0 ~ d {print p}')
[ -n "$QPID" ] || { echo "bench: no shell on $WAYLAND_DISPLAY"; exit 1; }

hc() { hyprctl "$@"; }
q() { qs ipc --pid "$QPID" call "$@" >/dev/null 2>&1; }
hc eval 'hl.monitor({ output = "MBA", mode = "3840x2160@60", position = "auto", scale = 1.5 })' >/dev/null
sleep 1
hc dispatch 'hl.dsp.focus({ monitor = "MBA" })' >/dev/null
hc dispatch 'hl.dsp.exec_cmd("foot -e sh -c \"while :; do date +%s%N; sleep 0.005; done\"")' >/dev/null
sleep 2
q panels toggle cc
hc eval 'hl.config({ plugin = { liquidglass = { stats = 1 } } })' >/dev/null

run() {
    hc eval "hl.config({ plugin = { liquidglass = { $1 } } })" >/dev/null
    q notifs test "Benchmark" "banner glass"
    sleep 1
    hc liquidglass reset >/dev/null
    sleep "$SECS"
    echo "== $2"
    hc liquidglass
}
run "enabled = 1, full_damage = 0" "liquid glass (default: glass redrawn only where damaged)"
run "enabled = 1, full_damage = 1" "liquid glass, whole output redrawn every frame (worst case)"
run "enabled = 0, full_damage = 0" "plugin disabled (plain Hyprland blur)"
grim -o MBA "$OUTDIR/end.png" 2>/dev/null && echo "screenshots: $OUTDIR"
