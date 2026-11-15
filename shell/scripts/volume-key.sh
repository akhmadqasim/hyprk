#!/usr/bin/env bash
# The volume keys as macOS 27.2.1 does them: Control Center's hot keys (ControlCenter.framework
# HotKeys.registerBezelHotKeys(with:) 0x20a57cc34, reference/re/27.2.1/SOUND-REA-27.2.1.md section 2). BezelServices'
# VolumeStateMachine, which this script followed before (one pop when the key goes up), is not the live path: its
# -handleCGSEvent: returns at once while the feature flag ControlCenter/Bezel is on, and 27.2.1 ships it FeatureComplete.
# Hyprland binds call this (config/hypr/hyprland.lua):
#   volume-key.sh up|down <16|64> [shift]  key down and every auto-repeat (the Mac's own NSTimer at the key repeat
#                                          interval): one step of 1/16 (Option+Shift: 1/64) on the Mac's grid (the
#                                          level rounded to 1/64, then +-step truncated to a multiple of the step,
#                                          clamped to 0..1), unmutes, and ONE feedback pop (44 ms later, pop() below) on every step,
#                                          also when the level already is 0 or 1 (volume step 0x20a595dac, gate
#                                          0x20a596298)
#   volume-key.sh mute [shift]             toggles mute; unmuting pops (no timer, same 44 ms), muting is silent (0x20a595bf0)
#   volume-key.sh release                  the key goes up: nothing (the Mac only stops its repeat timer). Kept so an
#                                          old bind does not fail
# "shift" is Shift held without Control, Option or Command at that key event: it inverts "Play feedback when volume
# is changed" for that pop (plays when playVolumeKeyFeedback != shift).
# State: one folder per Hyprland instance in $XDG_RUNTIME_DIR (HYPRK_VOLKEY_DIR overrides it for tests): the lock, and
# the stub sink of test sessions.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
D=${HYPRK_VOLKEY_DIR:-${XDG_RUNTIME_DIR:-/tmp}/hyprk-volkey-${HYPRLAND_INSTANCE_SIGNATURE:-0}}
mkdir -p "$D" 2>/dev/null || exit 0
neg=""; [ "${!#}" = shift ] && neg=negate
SINK=@DEFAULT_AUDIO_SINK@
wp() { LC_ALL=C wpctl "$@"; }   # "0.44", never "0,44"
setlevel() { wp set-mute "$SINK" 0; wp set-volume "$SINK" "$1"; }   # a key step: unmute, then the new level
# HYPRK_AUDIO_STUB=1 (or HYPRK_STATUS_STUB=1; headless test sessions only): a made-up sink in "$D/stub-sink"
# ("<volume 0..1> <muted 0|1>", default "0.5 0"), shared with the shell's services/Audio.qml stub, so a volume key in a
# test session never reaches the machine's real PipeWire volume. wpctl is not called at all.
if [ "${HYPRK_AUDIO_STUB:-0}" = 1 ] || [ "${HYPRK_STATUS_STUB:-0}" = 1 ]; then
    wp() {
        local v=0.5 m=0
        [ -r "$D/stub-sink" ] && read -r v m < "$D/stub-sink"
        case "$1" in
            get-volume) [ "$m" = 1 ] && printf 'Volume: %s [MUTED]\n' "$v" || printf 'Volume: %s\n' "$v" ;;
            set-volume) printf '%s %s\n' "$3" "$m" > "$D/stub-sink.tmp" && mv -f "$D/stub-sink.tmp" "$D/stub-sink" ;;
            set-mute)   printf '%s %s\n' "$v" "$3" > "$D/stub-sink.tmp" && mv -f "$D/stub-sink.tmp" "$D/stub-sink" ;;
        esac
    }
    # a key step: unmuted at the new level in ONE rename of the stub file (two, as wpctl's two calls, gave the
    # shell's file watch two changes a millisecond apart per step)
    setlevel() { printf '%s 0\n' "$1" > "$D/stub-sink.tmp" && mv -f "$D/stub-sink.tmp" "$D/stub-sink"; }
fi

# one key event at a time, in the order they came
if command -v flock >/dev/null; then exec 9>"$D/lock"; flock 9; fi

# The pop's player starts 44 ms after the level is set; never wait for the sound to end. Control Center calls play at
# once, but on the Mac the pop reaches the output 49 ms after the menu bar's Control Center pill, with the HUD's appear
# spring (within 3 ms) and 18 ms before the HUD's first frame (R5.1 screen + system audio, SOUND-REA-27.2.1.md
# section 7: AVAudioPlayer's start-up). Without the wait ours was in the output about 5 ms before the pill (player 16 ms
# after the key, pw-play streaming 11 ms later (estimate)). 60 was set while the HUD's first frames were held invisible;
# with them drawn (and the HUD one frame later, services/Hud.qml showDelay) 41 put the pop out 41 ms after the pill and
# 28 ms before the HUD's first frame (medians, 8 runs), 49 at 54 / 9 (means, 18 runs); 44 puts it at the Mac's 49 after
# the pill and 14 before the first frame (Mac 18) (headless session, stub sink; SOUND-REA-27.2.1.md section 7, "Round J20")
pop() { { sleep 0.044; exec "$HERE/sound.sh" volume $neg; } 9>&- & }
# a key step that leaves the level and mute as they were: "$D/hud-step" is rewritten (rename, as the stub sink) and the
# shell's services/Hud.qml shows the HUD for it
hudstep() { printf '%s %s\n' "$$" "$(date +%s%N)" > "$D/hud-step.tmp" && mv -f "$D/hud-step.tmp" "$D/hud-step"; }

case "${1:-}" in
    up|down)
        cur=$(wp get-volume "$SINK" 2>/dev/null) || exit 0     # no output device: canSetVolume is NO, nothing happens
        read -r v same < <(LC_ALL=C awk -v s="$cur" -v d="$1" -v n="${2:-16}" 'BEGIN {
            split(s, a, " "); q = int((a[2] + 1 / 128) * 64) / 64
            if (d == "up") x = q >= 1 ? 1 : int((q + 1 / n) * n) / n
            else x = q <= 0 ? 0 : int((q - 1 / n) * n) / n
            x = x > 1 ? 1 : x < 0 ? 0 : x
            printf "%.6f %d\n", x, (x == q) }')
        setlevel "$v"
        # the Mac shows the HUD on every step, also when the level stays at 0 or 1 (HUDActionDelegate.showVolume runs
        # before the feedback gate, volume step 0x20a595dac; SOUND-REA-27.2.1.md section 2). The shell shows it on a
        # change of level or mute (services/Hud.qml), so a step that changes neither tells it through this file
        case $cur in *MUTED*) ;; *) [ "$same" = 1 ] && hudstep ;; esac
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
