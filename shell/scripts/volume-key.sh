#!/usr/bin/env bash
# The volume keys as macOS 27.2.1 does them: BezelServices' VolumeStateMachine (BezelServices.loginPlugin, arm64e,
# decoded for shell/SOUNDS.md "Volume keys"). Hyprland binds call this (config/hypr/hyprland.lua):
#   volume-key.sh up|down <16|64> [shift]  key down and every auto-repeat: one step of 1/16 (Option+Shift: 1/64) on
#                                          the Mac's grid (-changeVolumeBy:type: 0x10388: the level rounded to 1/64,
#                                          then +-step truncated to a multiple of the step, clamped to 0..1); unmutes
#   volume-key.sh release [shift]          the key goes up: ONE feedback pop if a step happened since the last pop
#                                          (VSIncrease / VSDecrease set singleBeepWhenFinished, VSStart plays it);
#                                          nothing plays while the key is down or repeating
#   volume-key.sh mute [shift]             toggles mute; unmuting pops 0.08 s later (VSMute: startOneBeep while still
#                                          muted, NSTimer 0.08 s at 0x401d8), muting is silent
# At full volume a held key pops at once and then every 1 s (startRepeatedBeeps 0x10214: NSTimer 1.0 s, fired now),
# and these pops clear the key-up pop (playOneBeep: always ends with singleBeepWhenFinished = NO), so the key going
# up at full volume plays nothing more
# until the key goes up or 4 s pass without a step (-changeVolumeBy:type: sets beepTimeout = now + 4 s, playOneBeep: 0xff78 checks it).
# "shift" is Shift held without Control, Option or Command at that key event: it inverts "Play feedback when volume
# is changed" for that pop (negateSilentPreference, -handleKeyEvent:shift:control:option:command: 0x10d04).
# State: one folder per Hyprland instance in $XDG_RUNTIME_DIR (HYPRK_VOLKEY_DIR overrides it for tests).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
D=${HYPRK_VOLKEY_DIR:-${XDG_RUNTIME_DIR:-/tmp}/hyprk-volkey-${HYPRLAND_INSTANCE_SIGNATURE:-0}}
mkdir -p "$D" 2>/dev/null || exit 0
neg=""; [ "${!#}" = shift ] && neg=negate
SINK=@DEFAULT_AUDIO_SINK@
wp() { LC_ALL=C wpctl "$@"; }   # "0.44", never "0,44"

# one key event at a time, in the order they came (a late auto-repeat must not run after the key went up)
if [ "${1:-}" != repeat ] && command -v flock >/dev/null; then exec 9>"$D/lock"; flock 9; fi

pop() { "$HERE/sound.sh" volume $neg 9>&- & }   # never wait for the sound to end
now() { date +%s%3N; }
repeating() {    # the 1 s loop runs: its pid file names a live volume-key process (never anything else)
    read -r p 2>/dev/null < "$D/repeat" && grep -qa volume-key "/proc/$p/cmdline" 2>/dev/null
}
stop_repeat() {   # stopBeeps: end the 1 s pops
    local p
    repeating && kill "$p" 2>/dev/null
    rm -f "$D/repeat"
    return 0
}

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
        now > "$D/changed"
        if [ "$v" != 1.000000 ]; then
            : > "$D/pending"
        elif ! repeating; then   # full volume: the loop pops at once, and its pops clear the key-up pop
            "$0" repeat $neg >/dev/null 2>&1 9>&- &
            echo $! > "$D/repeat"
        fi ;;
    repeat)   # the 1 s pops at full volume (started above, ended by release or the 4 s timeout)
        [ "${2:-}" = negate ] && neg=negate
        while :; do
            rm -f "$D/pending"   # playOneBeep: ends with singleBeepWhenFinished = NO
            pop
            read -r t 2>/dev/null < "$D/changed" || t=0
            [ $(( $(now) - t )) -gt 4000 ] && { rm -f "$D/repeat"; exit 0; }
            sleep 1
        done ;;
    release)
        stop_repeat
        if [ -f "$D/pending" ]; then
            rm -f "$D/pending"
            pop   # a step unmuted the output, so never the 0.08 s wait of startOneBeep while muted
        fi ;;
    mute)
        cur=$(wp get-volume "$SINK" 2>/dev/null) || exit 0
        case $cur in
            *MUTED*) wp set-mute "$SINK" 0; sleep 0.08; pop ;;
            *) wp set-mute "$SINK" 1 ;;
        esac ;;
    *) echo "usage: volume-key.sh up|down <16|64> [shift] | release [shift] | mute [shift]" >&2; exit 2 ;;
esac
exit 0
