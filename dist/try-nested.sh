#!/usr/bin/env bash
# Try hyprk inside a window on your GNOME desktop. Nothing of GNOME or your ~/.config is changed.
#
#   dist/try-nested.sh [--dark] [--sound] [--share-config] [--shot FILE] [--wait SEC]
#
#   --dark           dark GTK/Qt theme
#   --sound          play shell sounds (muted by default)
#   --share-config   let apps see your real ~/.config (symlinks); default is a private empty one
#   --shot FILE      test mode: wait for the shell, grim screenshot to FILE, exit
#   --wait SEC       how long to wait for the shell (default 40)
#
# Window size: GNOME lets the client pick, so it opens at 1280x720 (logical). Resize or maximise it with the
# mouse, hyprk follows. Sharp text on a scaled host screen (4K at 200% or 150%): the patched aquamarine
# (hypr-dev/patches/aquamarine-*-wayland-hidpi.patch) renders at the host's preferred (fractional) scale,
# and HYPRK_SCALE (default: the GNOME primary monitor scale) sets the matching Hyprland scale.
# Private dirs: ~/.local/share/hyprk-try/{config,data,state,cache}. Delete that folder to reset.
# Exit: Ctrl+Alt+Q, Super+Shift+Escape, the logo menu > Log Out, or Ctrl+C here. On exit only the processes this
# script started (its own session) are killed, including the stray Hyprland child.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
THEME=light MODE=private SHOT= WAIT=40 SOUND=0
while [ $# -gt 0 ]; do
    case $1 in
        --dark) THEME=dark ;;
        --sound) SOUND=1 ;;
        --share-config) MODE=farm ;;
        --shot) SHOT=$2; shift ;;
        --wait) WAIT=$2; shift ;;
        -h|--help) sed -n 2,18p "$0"; exit 0 ;;
        *) echo "try-nested: unknown option $1" >&2; exit 2 ;;
    esac
    shift
done

[ -n "${WAYLAND_DISPLAY:-}" ] || { echo "try-nested: start it from a terminal inside your GNOME Wayland session" >&2; exit 2; }
HOST_WAYLAND=$WAYLAND_DISPLAY

# shellcheck disable=SC1091
. "$HERE/lib/env.sh"
hyprk_env_setup "${HYPRK_TRY_HOME:-$HOME/.local/share/hyprk-try}" "$MODE" "$THEME" || exit 1
command -v Hyprland >/dev/null || { echo "try-nested: Hyprland not found in $HYPRK_DEV/prefix" >&2; exit 2; }
[ -n "$HYPRK_QT_NOTE" ] && echo "try-nested: note: $HYPRK_QT_NOTE"

export HYPRK_MUTE=$([ $SOUND = 1 ] && echo 0 || echo 1)   # shell sounds; power actions stay blocked (HYPRK_ALLOW_POWER unset)
unset HYPRLAND_INSTANCE_SIGNATURE
export XDG_CURRENT_DESKTOP=Hyprland        # nested only: stops the "managed externally" warning
export HYPRLAND_NO_SD_VARS=1               # never touch the host systemd/dbus environment
export HYPRK_NESTED=1                      # adds Ctrl+Alt fallbacks for the Super binds (hyprk-dist.lua)
# Hyprland scale = host scale, so the nested UI has the same size as host apps (hyprk-dist.lua reads it)
host_scale() {
    python3 -I -c '
from gi.repository import Gio
r = Gio.bus_get_sync(Gio.BusType.SESSION).call_sync("org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig",
    "org.gnome.Mutter.DisplayConfig", "GetCurrentState", None, None, 0, 2000, None).unpack()
print(next((lm[2] for lm in r[2] if lm[4]), r[2][0][2]))' 2>/dev/null
}
export HYPRK_SCALE=${HYPRK_SCALE:-$(host_scale)}
export HYPRK_SCALE=${HYPRK_SCALE:-1}
export HYPRK_SCALE_POLICY=off   # nested: match the host window, not the physical monitor

LOG=$XDG_STATE_HOME/nested-$(date +%H%M%S).log
# own session (setsid): everything started from here shares session id = $HPID, so we can clean up exactly it
setsid "$HYPRK_ROOT/config/hypr/start.sh" >"$LOG" 2>&1 &
HPID=$!
disown "$HPID"   # no "Segmentation fault" job message if Hyprland crashes on exit (see ISSUES.md)
echo "try-nested: Hyprland pid $HPID, log $LOG"

alive() { [ -r "/proc/$HPID/stat" ] && ! grep -q "^State:[[:space:]]*Z" "/proc/$HPID/status" 2>/dev/null; }   # a zombie does not count
SIG=""; NESTED=""
cleaned=0
cleanup() {
    [ $cleaned = 1 ] && return; cleaned=1
    trap '' INT TERM
    if [ -n "$SIG" ] && alive; then
        HYPRLAND_INSTANCE_SIGNATURE=$SIG hyprctl dispatch 'hl.dsp.exit()' >/dev/null 2>&1
    fi
    local i
    for i in $(seq 1 50); do alive || break; sleep 0.1; done
    sleep 0.5   # let qs and friends notice the compositor is gone
    # kill only members of OUR session (session id == $HPID): Hyprland, the stray child, qs, apps started inside
    local left
    left=$(pgrep -s "$HPID" 2>/dev/null)
    [ -n "$left" ] && kill $left 2>/dev/null
    for i in $(seq 1 20); do pgrep -s "$HPID" >/dev/null 2>&1 || break; sleep 0.1; done
    left=$(pgrep -s "$HPID" 2>/dev/null)
    [ -n "$left" ] && kill -9 $left 2>/dev/null
    echo "try-nested: closed"
}
trap 'cleanup; exit 130' INT TERM HUP
trap cleanup EXIT

for _ in $(seq 1 100); do
    for d in "$XDG_RUNTIME_DIR"/hypr/*/; do
        [ -f "$d/hyprland.lock" ] || continue
        if [ "$(head -n1 "$d/hyprland.lock")" = "$HPID" ]; then
            SIG=$(basename "$d"); NESTED=$(sed -n 2p "$d/hyprland.lock")
        fi
    done
    [ -n "$SIG" ] && [ -n "$NESTED" ] && break
    alive || { echo "try-nested: Hyprland exited early, log:" >&2; tail -n 30 "$LOG" >&2; exit 1; }
    sleep 0.2
done
[ -n "$SIG" ] || { echo "try-nested: no Hyprland instance found, log: $LOG" >&2; exit 1; }
echo "try-nested: instance $SIG on $NESTED (host $HOST_WAYLAND)"

if [ -n "$SHOT" ]; then
    ok=0
    for _ in $(seq 1 $((WAIT * 2))); do
        alive || break
        l=$(HYPRLAND_INSTANCE_SIGNATURE=$SIG hyprctl layers 2>/dev/null)
        if grep -q hyprk-menubar <<<"$l" && grep -q hyprk-dock <<<"$l"; then ok=1; break; fi
        sleep 0.5
    done
    [ $ok = 1 ] || { echo "try-nested: shell did not appear, log: $LOG" >&2; tail -n 30 "$LOG" >&2; exit 1; }
    sleep 3
    mkdir -p "$(dirname "$SHOT")"
    WAYLAND_DISPLAY=$NESTED grim "$SHOT" && echo "try-nested: screenshot $SHOT"
    exit 0   # EXIT trap closes it
fi

echo "try-nested: running. Exit with Ctrl+Alt+Q, Super+Shift+Escape, the logo menu > Log Out, or Ctrl+C here."
while alive; do sleep 0.5; done
