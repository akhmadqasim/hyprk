#!/usr/bin/env bash
# Play a macOS system sound for an event. Used by the shell (QML) and by
# Hyprland binds, so both honor the same settings in state/sound.json:
#   alertSound (name in sounds/oga/Sounds, default "Tink"), alertVolume (0..1, default 0.75),
#   uiSounds (bool, default true), volumeFeedback (bool, default true)
# Usage: sound.sh <alert|notification|volume|screenshot|trash-empty|trash-move|mount|unmount|sent|power|poof>
# HYPRK_MUTE=1 silences everything (nested test sessions at night). HYPRK_SOUND_LOG=<file>: append "<event> <file>"
# for every sound that would play (also when muted), to check the wiring without hearing it.
# Plays with pw-play, falls back to paplay, stays silent when neither exists or a file is missing.
set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SND=$ROOT/sounds/oga
STATE=${HYPRK_STATE:-$ROOT/state}/sound.json

alert="Tink"; vol=0.75; ui=true; fb=true
if [ -r "$STATE" ] && command -v jq >/dev/null; then
    IFS=$'\t' read -r alert vol ui fb < <(jq -r '[(if (.alertSound | type) == "string" and .alertSound != "" then .alertSound else "Tink" end), (if (.alertVolume | type) == "number" then .alertVolume else 0.75 end), (if .uiSounds == false then "false" else "true" end), (if .volumeFeedback == false then "false" else "true" end)] | @tsv' "$STATE" 2>/dev/null || printf 'Tink\t0.75\ttrue\ttrue\n')
fi

case "${1:-}" in
    alert|notification) f="$SND/Sounds/$alert.oga" ;;
    volume)       [ "$fb" = true ] || exit 0; f="$SND/misc/BezelServices-volume.oga" ;;
    screenshot)   [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/system/Screen Capture.oga" ;;
    trash-empty)  [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/finder/empty trash.oga" ;;
    trash-move)   [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/finder/move to trash.oga" ;;
    mount)        [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/system/Volume Mount.oga" ;;
    unmount)      [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/system/Volume Unmount.oga" ;;
    sent)         [ "$ui" = true ] || exit 0; f="$SND/misc/Mail-Sent.oga" ;;
    power)        [ "$ui" = true ] || exit 0; f="$SND/misc/PowerChime-connect_power.oga" ;;   # PowerChime connect_power
    poof)         [ "$ui" = true ] || exit 0; f="$SND/SystemSounds/dock/poof item off dock.oga" ;;
    *) echo "usage: sound.sh <event>" >&2; exit 2 ;;
esac
# unknown alert name: fall back to the default alert
if [ ! -f "$f" ] && { [ "$1" = alert ] || [ "$1" = notification ]; }; then f="$SND/Sounds/Tink.oga"; fi
[ -f "$f" ] || exit 0
[ -n "${HYPRK_SOUND_LOG:-}" ] && printf '%s %s\n' "$1" "$f" >> "$HYPRK_SOUND_LOG"
[ "${HYPRK_MUTE:-0}" = 1 ] && exit 0      # silent test runs

if command -v pw-play >/dev/null; then
    exec pw-play --volume "$vol" "$f"
elif command -v paplay >/dev/null; then
    exec paplay --volume "$(awk -v v="$vol" 'BEGIN{printf "%d", v*65536}')" "$f"
fi
exit 0
