#!/usr/bin/env bash
# The volume keys as macOS 27.2.1 does them: Control Center's hot keys (ControlCenter.framework
# HotKeys.registerBezelHotKeys(with:) 0x20a57cc34, reference/re/27.2.1/SOUND-REA-27.2.1.md section 2). BezelServices'
# VolumeStateMachine, which this script followed before (one pop when the key goes up), is not the live path: its
# -handleCGSEvent: returns at once while the feature flag ControlCenter/Bezel is on, and 27.2.1 ships it FeatureComplete.
# Hyprland binds call this (config/hypr/hyprland.lua):
#   volume-key.sh up|down <16|64> [shift]  key down and every auto-repeat (the Mac's own NSTimer at the key repeat
#                                          interval): one step of 1/16 (Option+Shift: 1/64) on the Mac's grid (the
#                                          level rounded to 1/64, then +-step truncated to a multiple of the step,
#                                          clamped to 0..1), unmutes, and ONE feedback pop, at once, on every step,
#                                          also when the level already is 0 or 1 (volume step 0x20a595dac, gate
#                                          0x20a596298)
#   volume-key.sh mute [shift]             toggles mute; unmuting pops at once, muting is silent (0x20a595bf0)
#   volume-key.sh release                  the key goes up: nothing (the Mac only stops its repeat timer). Kept so an
#                                          old bind does not fail
# "shift" is Shift held without Control, Option or Command at that key event: it inverts "Play feedback when volume
# is changed" for that pop (plays when playVolumeKeyFeedback != shift).
# State: one folder per Hyprland instance in $XDG_RUNTIME_DIR (HYPRK_VOLKEY_DIR overrides it for tests), the lock only.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
D=${HYPRK_VOLKEY_DIR:-${XDG_RUNTIME_DIR:-/tmp}/hyprk-volkey-${HYPRLAND_INSTANCE_SIGNATURE:-0}}
mkdir -p "$D" 2>/dev/null || exit 0
neg=""; [ "${!#}" = shift ] && neg=negate
SINK=@DEFAULT_AUDIO_SINK@
wp() { LC_ALL=C wpctl "$@"; }   # "0.44", never "0,44"

# one key event at a time, in the order they came
if command -v flock >/dev/null; then exec 9>"$D/lock"; flock 9; fi

pop() { "$HERE/sound.sh" volume $neg 9>&- & }   # never wait for the sound to end

case "${1:-}" in
    up|down)
        cur=$(wp get-volume "$SINK" 2>/dev/null) || exit 0     # no output device: canSetVolume is NO, nothing happens
        v=$(LC_ALL=C awk -v s="$cur" -v d="$1" -v n="${2:-16}" 'BEGIN {
            split(s, a, " "); q = int((a[2] + 1 / 128) * 64) / 64
            if (d == "up") x = q >= 1 ? 1 : int((q + 1 / n) * n) / n
            else x = q <= 0 ? 0 : int((q - 1 / n) * n) / n
            printf "%.6f", (x > 1 ? 1 : x < 0 ? 0 : x) }')
        wp set-mute "$SINK" 0
        wp set-volume "$SINK" "$v"
        pop ;;
    release) ;;
    mute)
        cur=$(wp get-volume "$SINK" 2>/dev/null) || exit 0
        case $cur in
            *MUTED*) wp set-mute "$SINK" 0; pop ;;
            *) wp set-mute "$SINK" 1 ;;
        esac ;;
    *) echo "usage: volume-key.sh up|down <16|64> [shift] | mute [shift]" >&2; exit 2 ;;
esac
exit 0
