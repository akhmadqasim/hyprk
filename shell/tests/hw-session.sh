#!/usr/bin/env bash
# Session tests of the brightness sync and of the hardware-bound items, in nested headless Hyprland sessions
# (scripts/smoke.sh; needs a host Wayland session and the dev env). Everything lives in one scratch folder: HOME,
# HYPRK_STATE and the fake DDC monitors. No real display, backlight, volume or state file is touched, and every
# process started here is stopped by its pid.
#   A  HYPRK_BRIGHTNESS_STUB=1, HYPRK_STATUS_STUB=1: one level for Control Center (IPC set), Settings (the state
#      file) and the keys, the HUD on a key only, a level an earlier session left is never applied; Wi-Fi shown
#   B  the fake ddcutil (HYPRK_DDCUTIL), HYPRK_HW=wifi=0,bluetooth=0,battery=0: asleep monitors = no brightness
#      control, a probe after they wake = DDC, a burst of sets = throttled writes ending on the last level;
#      Wi-Fi, Bluetooth, AirDrop and the battery hidden and Control Center's grid closed up
# Usage: shell/tests/hw-session.sh      exit 0 = all passed
set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
# shellcheck disable=SC1091
[ -f "${HYPRK_DEV:-$ROOT/../hypr-dev}/env.sh" ] && . "${HYPRK_DEV:-$ROOT/../hypr-dev}/env.sh"
T=$(mktemp -d "${TMPDIR:-/tmp}/hyprk-hw.XXXXXX") || exit 2
pass=0; fail=0; SIG=""; BUS=""; QP=""
ok() { if [ "$2" = "$3" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL $1: got '$2', want '$3'"; fi; }
stop() {
    [ -n "$SIG" ] && "$ROOT/scripts/smoke.sh" --stop "$SIG" >/dev/null 2>&1
    [ -n "$BUS" ] && kill "$BUS" 2>/dev/null
    SIG=""; BUS=""
}
trap 'stop; rm -rf "$T"' EXIT
desc() { local p; for p in $(pgrep -P "$1" 2>/dev/null); do echo "$p"; desc "$p"; done; }
# start <name> VAR=value...: a kept headless session with its own HOME and state folder
start() {
    local name=$1 out p; shift
    mkdir -p "$T/$name/home" "$T/$name/state"
    S=$T/$name/state/brightness.json
    out=$(env HOME="$T/$name/home" HYPRK_STATE="$T/$name/state" HYPRK_HEADLESS=1 HYPRK_AUDIO_STUB=1 HYPRK_KEEP=1 HYPRK_SETTLE=2 "$@" \
          "$ROOT/scripts/smoke.sh" "$T/$name/shot.png" 2>&1)
    SIG=$(printf '%s\n' "$out" | sed -n 's/^export HYPRLAND_INSTANCE_SIGNATURE=\([^ ]*\).*/\1/p')
    BUS=$(printf '%s\n' "$out" | sed -n 's/.*bus pid \([0-9]*\).*/\1/p' | tail -n 1)
    local hp; hp=$(printf '%s\n' "$out" | sed -n 's/.*# pid \([0-9]*\).*/\1/p')
    QP=""
    for p in $(desc "${hp:-0}"); do
        case "$(cat /proc/"$p"/comm 2>/dev/null)" in qs|quickshell) grep -qa "$ROOT/shell" /proc/"$p"/cmdline && QP=$p ;; esac
    done
    [ -n "$SIG" ] && [ -n "$QP" ] || { echo "hw-session: session $name did not start"; printf '%s\n' "$out" | tail -n 5; exit 2; }
}
ipc() { qs ipc --pid "$QP" call "$@" 2>/dev/null; }
js() { node -e 'let o; try { o = JSON.parse(process.argv[1]); } catch (e) { o = {}; } const v = eval("o." + process.argv[2]); console.log(typeof v === "object" ? JSON.stringify(v) : String(v))' "$1" "$2"; }
file() { js "$(cat "$S" 2>/dev/null)" "$1"; }
settings_writes() { printf '%s\n' "$1" > "$S.tmp" && mv "$S.tmp" "$S"; sleep 0.5; }   # as Settings does: tmp + mv
key() { hyprctl -i "$SIG" dispatch "hl.dsp.global(\"hyprk:brightness-$1\")" >/dev/null; sleep 0.4; }

# ---------- A: the stub backlight ----------
mkdir -p "$T/a/state"
echo '{"value":0.2,"available":true,"source":"ddc","probe":3}' > "$T/a/state/brightness.json"   # an earlier session's
start a HYPRK_STATUS_STUB=1 HYPRK_BRIGHTNESS_STUB=1
ok "A stub mode" "$(js "$(ipc brightness state)" mode)" stub
ok "A an earlier session's level is not applied" "$(js "$(ipc brightness state)" value)" 0.6
ok "A the file is the shell's at start" "$(file value),$(file available),$(file source),$(file probe)" "0.6,true,stub,3"
ipc brightness set 0.4; sleep 0.4                           # the Control Center slider's call
ok "A Control Center -> file (Settings reads it)" "$(file value)" 0.4
settings_writes '{"value":0.8,"available":true,"source":"stub","probe":3}'
ok "A Settings -> shell" "$(js "$(ipc brightness state)" value)" 0.8
ok "A Settings -> HUD level, no HUD" "$(js "$(ipc hud state)" brightness),$(js "$(ipc hud state)" shown)" "0.8,false"
key up
ok "A key: one 1/16 step" "$(js "$(ipc brightness state)" value)" 0.875
ok "A key: HUD shown with the level" "$(js "$(ipc hud state)" shown),$(js "$(ipc hud state)" kind),$(js "$(ipc hud state)" brightness)" "true,brightness,0.875"
ok "A key -> file" "$(file value)" 0.875
key down-fine
ok "A Option+Shift key: 1/64" "$(file value)" 0.8594
settings_writes '{"value":0,"available":false,"source":"","probe":3}'
ok "A the shell owns available / source and the floor" "$(file value),$(file available),$(file source)" "0.01,true,stub"
h=$(ipc hardware state)
ok "A Wi-Fi and battery shown (status stub)" "$(js "$h" wifi),$(js "$h" battery)" "true,true"
stop

# ---------- B: DDC monitors (fake ddcutil), hardware absent ----------
mkdir -p "$T/ddc" "$T/bin"
printf '#!/bin/sh\nexit 1\n' > "$T/bin/brightnessctl"; chmod +x "$T/bin/brightnessctl"   # no backlight, also on a laptop
: > "$T/ddc/asleep"
start b PATH="$T/bin:$PATH" HYPRK_DDCUTIL="$ROOT/shell/tests/fake-ddcutil.sh" FAKE_DDC_DIR="$T/ddc" FAKE_DDC_SLOW=0.15 HYPRK_HW=wifi=0,bluetooth=0,battery=0
ok "B asleep monitors: no brightness control" "$(js "$(ipc brightness state)" available),$(file available)" "false,false"
ipc brightness set 0.5; key up
ok "B unavailable: set and keys do nothing" "$(js "$(ipc brightness state)" value),$(js "$(ipc hud state)" shown)" "1,false"
rm "$T/ddc/asleep"
settings_writes '{"value":1,"available":false,"source":"","probe":1}'   # Settings > Displays opened: look again
sleep 1.5
st=$(ipc brightness state)
ok "B awake after Settings asked: DDC, the monitors' level" "$(js "$st" mode),$(js "$st" value),$(js "$st" ddc.length)" "ddc,0.25,2"
ok "B the file says so (Settings' slider is enabled at 0.25)" "$(file value),$(file available),$(file source),$(file probe)" "0.25,true,ddc,1"
ok "B reading wrote nothing to the monitors" "$(cat "$T/ddc/writes" 2>/dev/null | wc -l)" 0
for v in 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70; do ipc brightness set $v; done   # a drag: 9 levels at once
sleep 2
n=$(wc -l < "$T/ddc/writes")
ok "B a drag is throttled (2 monitors x 9 levels = 18 writes unthrottled)" "$([ "$n" -ge 2 ] && [ "$n" -lt 18 ] && echo yes || echo "no: $n")" yes
ok "B both monitors end on the last level" "$(cat "$T/ddc/level-7"),$(cat "$T/ddc/level-8")" "70,70"
key up
ok "B key on DDC: 12/16 and the HUD" "$(js "$(ipc brightness state)" value),$(js "$(ipc hud state)" shown)" "0.75,true"
sleep 1
ok "B key on DDC: the monitors" "$(cat "$T/ddc/level-7"),$(cat "$T/ddc/level-8")" "75,75"
h=$(ipc hardware state)
ok "B Wi-Fi, Bluetooth, AirDrop, battery hidden" "$(js "$h" wifi),$(js "$h" bluetooth),$(js "$h" airdrop),$(js "$h" battery)" "false,false,false,false"
ok "B Control Center closed up: 3 rows, Focus over both columns" "$(js "$h" ccLayout.rows),$(js "$h" ccLayout.wifi),$(js "$h" ccLayout.focus.span)" "3,null,2"
stop

echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
