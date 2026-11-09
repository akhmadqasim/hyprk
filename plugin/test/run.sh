#!/usr/bin/env bash
# Nested Hyprland test bench for the liquidglass plugin.
#   run.sh start [plugin.so]   start nested Hyprland + headless MBA + foot + test shell
#   run.sh shot NAME           grim the MBA output to reference/ours/plugin-NAME.png
#   run.sh reload              unload + load the plugin again (after a rebuild)
#   run.sh eval 'LUA'          hyprctl eval in the test instance
#   run.sh stop                exit and kill only our own processes
set -euo pipefail
source /mnt/code/hypr-dev/env.sh
HERE="$(cd "$(dirname "$0")" && pwd)"
STATE="${XDG_RUNTIME_DIR}/lgtest.state"
OUT=/mnt/code/hyprk/reference/ours
SO_DEFAULT="$HERE/../build/libliquidglass.so"

load_state() { [[ -f $STATE ]] && source "$STATE" || { echo "not running"; exit 1; }; export HYPRLAND_INSTANCE_SIGNATURE=$SIG; }
hc() { hyprctl "$@"; }

case "${1:-}" in
start)
    SO="$(realpath "${2:-$SO_DEFAULT}")"
    export LG_PLUGIN="$SO" LG_TEST_DIR="$HERE"
    env -u HYPRLAND_INSTANCE_SIGNATURE Hyprland -c "$HERE/hyprland.lua" >"$HERE/nested.log" 2>&1 &
    PID=$!
    SIG=""
    for _ in $(seq 50); do
        sleep 0.2
        SIG=$(hyprctl instances -j 2>/dev/null | python3 -c "import json,sys;print(next((i['instance'] for i in json.load(sys.stdin) if i['pid']==$PID),''))" || true)
        [[ -n $SIG ]] && break
    done
    [[ -z $SIG ]] && { echo "no instance for pid $PID"; kill -9 $PID; exit 1; }
    SOCK=$(hyprctl instances -j | python3 -c "import json,sys;print(next(i['wl_socket'] for i in json.load(sys.stdin) if i['pid']==$PID))")
    printf 'PID=%s\nSIG=%s\nSOCK=%s\nLOADED=%s\n' "$PID" "$SIG" "$SOCK" "$SO" >"$STATE"
    export HYPRLAND_INSTANCE_SIGNATURE=$SIG
    sleep 1
    hc output create headless MBA >/dev/null
    sleep 1
    hc dispatch 'hl.dsp.focus({ monitor = "MBA" })' >/dev/null || true
    hc dispatch 'hl.dsp.exec_cmd("foot -o colors.alpha=0.55 -o font=monospace:size=11 -- sh -c \"ls -la /mnt/code/hyprk; fastfetch 2>/dev/null; exec sh\"")' >/dev/null
    sleep 3
    echo "started pid=$PID sig=$SIG sock=$SOCK"
    hc plugin list || true
    ;;
shot)
    load_state
    hc dismissnotify >/dev/null 2>&1 || true
    # force a full redraw so config changes from eval show up
    hc dispatch 'hl.dsp.exec_cmd("foot -T lgdamage -e sleep 0.2")' >/dev/null; sleep 1.2
    sleep "${3:-0.5}"
    WAYLAND_DISPLAY=$SOCK grim -o MBA "$OUT/plugin-$2.png"
    echo "$OUT/plugin-$2.png"
    ;;
reload)
    load_state
    # dlopen caches by path: load every build from a fresh copy
    NEW="$XDG_RUNTIME_DIR/liquidglass-$(date +%s%N).so"
    cp "$SO_DEFAULT" "$NEW"
    hc plugin unload "$LOADED" || true
    hc plugin load "$NEW"
    sed -i "s|^LOADED=.*|LOADED=$NEW|" "$STATE"
    hc reload >/dev/null
    ;;
eval)
    load_state
    hc eval "$2"
    ;;
stop)
    load_state
    hc dispatch 'hl.dsp.exit()' >/dev/null 2>&1 || true
    sleep 1
    # the stray single-threaded child of OUR instance (see hypr-dev README), never others
    for p in $PID $(pgrep -P "$PID" 2>/dev/null) $(pgrep -f "Hyprland -c $HERE/hyprland.lua" 2>/dev/null); do
        kill -9 "$p" 2>/dev/null || true
    done
    rm -f "$STATE"
    echo stopped
    ;;
*) sed -n 2,8p "$0"; exit 1 ;;
esac
