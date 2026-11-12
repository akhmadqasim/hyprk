#!/usr/bin/env bash
# Smoke test: start a nested Hyprland (inside the current Wayland session) with
# the hyprk config, wait for the shell's layers, take a grim screenshot, and
# exit Hyprland cleanly.
#
# Usage: scripts/smoke.sh [out.png] [-- extra command run inside before the shot]
#   HYPRK_KEEP=1   leave the nested session running (prints its env)
#   HYPRK_WAIT=N   seconds to wait for the shell (default 40)
#   HYPRK_SETTLE=N seconds to wait after the shell is up (default 3)
#   HYPRK_MUTE=0   let the shell play sounds (muted by default)
#   HYPRK_HEADLESS=1  add a 2560x1664@2x "MBA" output and shoot that (MacBook Air-like). No host window is
#                     opened: AQ_WAYLAND_NO_OUTPUT=1 (hypr-dev aquamarine patch) keeps the Wayland backend
#                     connected for the GPU allocator but creates no WAYLAND-1. HYPRK_HOST_WINDOW=1 keeps the
#                     window; with an unpatched aquamarine it is removed right after start (a short flash).
#                     The session gets its own dbus-daemon (no service directories, so nothing is activated; socket
#                     in $HYPRK_STATE/run), never the caller's bus; stopped at teardown, left running with HYPRK_KEEP=1.
#                     HYPRK_BUS_ADDRESS=addr uses that bus instead. NO_AT_BRIDGE=1 and GTK_A11Y=none for all of it
#
#   scripts/smoke.sh --stop SIG   stop a session this script started and left running (HYPRK_KEEP=1): only an instance
#                     whose runtime dir carries the smoke.pid marker written at start, matching its lock file. The
#                     private bus is not stopped by it: kill the bus pid the start printed
set -u
HYPRK_ROOT=${HYPRK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
export HYPRK_ROOT
[ "${1:-}" = --stop ] && STOP_SIG=${2:-}
OUT=${1:-$HYPRK_ROOT/reference/ours/smoke-$(date +%Y%m%d-%H%M%S).png}
shift || true
[ "${1:-}" = "--" ] && shift
EXTRA=("$@")
SHOT_ARGS=()

# shellcheck disable=SC1091
HYPRK_DEV=${HYPRK_DEV:-$HYPRK_ROOT/../hypr-dev}   # source-built prefix, optional with distro packages
[ -f "$HYPRK_DEV/env.sh" ] && source "$HYPRK_DEV/env.sh"
command -v Hyprland >/dev/null || { echo "smoke: Hyprland not in PATH (dev env not ready)"; exit 2; }
command -v qs >/dev/null || command -v quickshell >/dev/null || { echo "smoke: quickshell not in PATH"; exit 2; }
[ -n "${WAYLAND_DISPLAY:-}" ] || { echo "smoke: needs a host Wayland session"; exit 2; }

# the session's processes: the pid in the lock file and its descendants (Hyprland 0.57 runs the compositor in a forked
# child of the pid it was started as, and that child has hung after the exit dispatch in most runs)
descendants() {
    local p
    for p in $(pgrep -P "$1" 2>/dev/null); do echo "$p"; descendants "$p"; done
}
# exit dispatch to that instance, up to 3 s for its Hyprland processes to go, then SIGTERM, then SIGKILL; then its
# runtime dir and its shells' quickshell by-pid / by-id entries. Only pids under the lock file's pid are touched
stop_instance() {
    local sig=$1 dir=$XDG_RUNTIME_DIR/hypr/$1 lock hyp=() qs=() p t
    lock=$(head -n1 "$dir/hyprland.lock" 2>/dev/null)
    [ -n "$lock" ] || return 0
    for p in "$lock" $(descendants "$lock"); do
        case "$(cat /proc/"$p"/comm 2>/dev/null)" in
            Hyprland) hyp+=("$p") ;;
            qs|quickshell) qs+=("$p") ;;
        esac
    done
    HYPRLAND_INSTANCE_SIGNATURE=$sig hyprctl -i "$sig" dispatch 'hl.dsp.exit()' >/dev/null 2>&1
    alive() { for p in "${hyp[@]}"; do kill -0 "$p" 2>/dev/null && return 0; done; return 1; }
    for _ in $(seq 1 30); do alive || break; sleep 0.1; done
    if alive; then
        for p in "${hyp[@]}"; do kill -TERM "$p" 2>/dev/null; done
        for _ in $(seq 1 10); do alive || break; sleep 0.1; done
        for p in "${hyp[@]}"; do kill -KILL "$p" 2>/dev/null; done
    fi
    for p in "${qs[@]}"; do
        kill -KILL "$p" 2>/dev/null
        t=$(readlink "$XDG_RUNTIME_DIR/quickshell/by-pid/$p" 2>/dev/null)
        case "$t" in "$XDG_RUNTIME_DIR"/quickshell/by-id/?*) rm -rf "$t" ;; esac
        rm -f "$XDG_RUNTIME_DIR/quickshell/by-pid/$p"
    done
    rm -rf "$dir"
}
if [ "${STOP_SIG+set}" = set ]; then
    d=$XDG_RUNTIME_DIR/hypr/$STOP_SIG
    case "$STOP_SIG" in ""|*/*|.*) echo "smoke: --stop needs an instance signature"; exit 2 ;; esac
    if [ ! -f "$d/smoke.pid" ] || [ "$(cat "$d/smoke.pid")" != "$(head -n1 "$d/hyprland.lock" 2>/dev/null)" ]; then
        echo "smoke: $STOP_SIG was not started by smoke.sh (no matching $d/smoke.pid), not stopped"; exit 2
    fi
    stop_instance "$STOP_SIG"
    echo "smoke: stopped $STOP_SIG"
    exit 0
fi

LOGDIR=${XDG_CACHE_HOME:-$HOME/.cache}/hyprk/logs
mkdir -p "$LOGDIR" "$(dirname "$OUT")"
LOG=$LOGDIR/nested-$(date +%H%M%S).log

if [ "${HYPRK_HEADLESS:-0}" = 1 ]; then
    export HYPRK_PRIMARY=MBA
    # no WAYLAND-1 host window at all (needs aquamarine-0.16.0-wayland-no-output.patch, see hypr-dev README)
    [ "${HYPRK_HOST_WINDOW:-0}" = 1 ] || export AQ_WAYLAND_NO_OUTPUT=1
    # a private session bus: the caller's DBUS_SESSION_BUS_ADDRESS is never passed through
    export NO_AT_BRIDGE=1 GTK_A11Y=none
    if [ -n "${HYPRK_BUS_ADDRESS:-}" ]; then
        export DBUS_SESSION_BUS_ADDRESS=$HYPRK_BUS_ADDRESS
    else
        . "$HYPRK_ROOT/config/hypr/state-dir.sh"   # HYPRK_STATE
        mkdir -p "$HYPRK_STATE/run" && chmod 700 "$HYPRK_STATE/run"
        BUSDIR=$(mktemp -d "$HYPRK_STATE/run/bus.XXXXXX") || { echo "smoke: no bus dir"; exit 2; }
        cat >"$BUSDIR/session.conf" <<CONF
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>session</type>
  <listen>unix:path=$BUSDIR/bus</listen>
  <auth>EXTERNAL</auth>
  <policy context="default">
    <allow send_destination="*" eavesdrop="true"/>
    <allow eavesdrop="true"/>
    <allow own="*"/>
  </policy>
</busconfig>
CONF
        BUSINFO=$(dbus-daemon --config-file="$BUSDIR/session.conf" --fork --print-address=1 --print-pid=1) \
            || { echo "smoke: dbus-daemon failed"; exit 2; }
        DBUS_SESSION_BUS_ADDRESS=$(sed -n 1p <<<"$BUSINFO"); BUSPID=$(sed -n 2p <<<"$BUSINFO")
        export DBUS_SESSION_BUS_ADDRESS
        echo "smoke: private bus pid $BUSPID at $DBUS_SESSION_BUS_ADDRESS"
    fi
fi
export HYPRK_MUTE=${HYPRK_MUTE:-1}     # no sounds from test sessions unless HYPRK_MUTE=0
"$HYPRK_ROOT/config/hypr/start.sh" >"$LOG" 2>&1 &
HPID=$!
echo "smoke: Hyprland pid $HPID, log $LOG"

cleanup() {
    if [ -n "${SIG:-}" ]; then
        stop_instance "$SIG"
    else
        kill -9 "$HPID" 2>/dev/null
    fi
    stop_bus
}
stop_bus() {
    [ -n "${BUSPID:-}" ] || return 0
    kill "$BUSPID" 2>/dev/null
    rm -rf "$BUSDIR"
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
    kill -0 "$HPID" 2>/dev/null || { echo "smoke: Hyprland exited early"; tail -n 30 "$LOG"; stop_bus; exit 1; }
    sleep 0.2
done
[ -n "$SIG" ] || { echo "smoke: no instance found"; cleanup; exit 1; }
export HYPRLAND_INSTANCE_SIGNATURE=$SIG
echo "$HPID" >"$XDG_RUNTIME_DIR/hypr/$SIG/smoke.pid"   # marks the instance as this script's, for --stop
echo "smoke: instance $SIG on $NESTED"

if [ "${HYPRK_HEADLESS:-0}" = 1 ]; then
    timeout 10 bash -c 'until hyprctl version >/dev/null 2>&1; do sleep 0.2; done'
    hyprctl output create headless MBA >/dev/null
    # fallback for an aquamarine without the no-output patch: close the host window at once. With the patch
    # WAYLAND-1 does not exist and this is a harmless no-op (errors ignored)
    if [ "${HYPRK_HOST_WINDOW:-0}" != 1 ] && hyprctl monitors all 2>/dev/null | grep -q '^Monitor WAYLAND-1 '; then
        hyprctl output remove WAYLAND-1 >/dev/null 2>&1 || true
    fi
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
    echo "export HYPRLAND_INSTANCE_SIGNATURE=$SIG WAYLAND_DISPLAY=$NESTED${DBUS_SESSION_BUS_ADDRESS:+ DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS}  # pid $HPID${BUSPID:+, bus pid $BUSPID}"
    exit $rc
fi
cleanup
echo "smoke: done"
exit $rc
