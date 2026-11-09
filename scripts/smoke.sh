#!/usr/bin/env bash
# Smoke test: start a nested Hyprland (inside the current Wayland session) with
# the hyprk config, wait for the shell's layers, take a grim screenshot, and
# exit Hyprland cleanly.
#
# Usage: scripts/smoke.sh [out.png] [-- extra command run inside before the shot]
#   HYPRK_KEEP=1   leave the nested session running (prints its env)
#   HYPRK_WAIT=N   seconds to wait for the shell (default 40)
#   HYPRK_SETTLE=N seconds to wait after the shell is up (default 3)
#   HYPRK_HEADLESS=1  add a 2560x1664@2x "MBA" output and shoot that (MacBook Air-like)
set -u
HYPRK_ROOT=${HYPRK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
export HYPRK_ROOT
OUT=${1:-$HYPRK_ROOT/reference/ours/smoke-$(date +%Y%m%d-%H%M%S).png}
shift || true
[ "${1:-}" = "--" ] && shift
EXTRA=("$@")
SHOT_ARGS=()

# shellcheck disable=SC1091
source /mnt/code/hypr-dev/env.sh
command -v Hyprland >/dev/null || { echo "smoke: Hyprland not in PATH (dev env not ready)"; exit 2; }
command -v qs >/dev/null || command -v quickshell >/dev/null || { echo "smoke: quickshell not in PATH"; exit 2; }
[ -n "${WAYLAND_DISPLAY:-}" ] || { echo "smoke: needs a host Wayland session"; exit 2; }

LOGDIR=${XDG_CACHE_HOME:-$HOME/.cache}/hyprk/logs
mkdir -p "$LOGDIR" "$(dirname "$OUT")"
LOG=$LOGDIR/nested-$(date +%H%M%S).log

[ "${HYPRK_HEADLESS:-0}" = 1 ] && export HYPRK_PRIMARY=MBA
env -u HYPRLAND_INSTANCE_SIGNATURE Hyprland --config "$HYPRK_ROOT/config/hypr/hyprland.lua" >"$LOG" 2>&1 &
HPID=$!
echo "smoke: Hyprland pid $HPID, log $LOG"

cleanup() {
    # Hyprland 0.57 can leave a child behind after exit; remember ours to kill only those
    local kids
    kids=$(pgrep -P "$HPID" 2>/dev/null)
    if [ -n "${SIG:-}" ]; then
        HYPRLAND_INSTANCE_SIGNATURE=$SIG hyprctl dispatch 'hl.dsp.exit()' >/dev/null 2>&1
    fi
    for _ in $(seq 1 50); do kill -0 "$HPID" 2>/dev/null || break; sleep 0.1; done
    kill -9 "$HPID" 2>/dev/null
    for k in $kids; do kill -9 "$k" 2>/dev/null; done
}

# find the instance signature and nested wayland socket from the lock file
SIG=""; NESTED=""
for _ in $(seq 1 100); do
    for d in "$XDG_RUNTIME_DIR"/hypr/*/; do
        [ -f "$d/hyprland.lock" ] || continue
        if [ "$(head -n1 "$d/hyprland.lock")" = "$HPID" ]; then
            SIG=$(basename "$d"); NESTED=$(sed -n 2p "$d/hyprland.lock")
        fi
    done
    [ -n "$SIG" ] && [ -n "$NESTED" ] && break
    kill -0 "$HPID" 2>/dev/null || { echo "smoke: Hyprland exited early"; tail -n 30 "$LOG"; exit 1; }
    sleep 0.2
done
[ -n "$SIG" ] || { echo "smoke: no instance found"; cleanup; exit 1; }
export HYPRLAND_INSTANCE_SIGNATURE=$SIG
echo "smoke: instance $SIG on $NESTED"

if [ "${HYPRK_HEADLESS:-0}" = 1 ]; then
    timeout 10 bash -c 'until hyprctl version >/dev/null 2>&1; do sleep 0.2; done'
    hyprctl output create headless MBA >/dev/null
    SHOT_ARGS=(-o MBA)
fi

ok=0
for _ in $(seq 1 $(( ${HYPRK_WAIT:-40} * 2 ))); do
    if hyprctl layers 2>/dev/null | grep -q "hyprk-menubar" && hyprctl layers 2>/dev/null | grep -q "hyprk-dock"; then ok=1; break; fi
    sleep 0.5
done
if [ $ok = 0 ]; then
    echo "smoke: shell layers did not appear"
    tail -n 40 "$LOG"
    cleanup; exit 1
fi
sleep "${HYPRK_SETTLE:-3}"

if [ ${#EXTRA[@]} -gt 0 ]; then
    WAYLAND_DISPLAY=$NESTED "${EXTRA[@]}"
    sleep 1
fi

WAYLAND_DISPLAY=$NESTED grim "${SHOT_ARGS[@]}" "$OUT" && echo "smoke: screenshot $OUT"
rc=$?

if [ "${HYPRK_KEEP:-0}" = 1 ]; then
    echo "export HYPRLAND_INSTANCE_SIGNATURE=$SIG WAYLAND_DISPLAY=$NESTED  # pid $HPID"
    exit $rc
fi
cleanup
echo "smoke: done"
exit $rc
