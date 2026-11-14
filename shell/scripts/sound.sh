#!/usr/bin/env bash
# Play a macOS system sound for an event. Used by the shell (QML), the Finder and Hyprland binds, so all honor the same
# settings in state/sound.json:
#   alertSound (one of the 14 /System/Library/Sounds names, default "Tink"), alertVolume (0..1, default 1),
#   uiSounds (bool, default true), volumeFeedback (bool, default false, as the Settings app shows it)
# Usage: sound.sh <event> [arg]
#   alert                          the alert sound (NSBeep, SystemSoundID 0x1000)
#   notification [Name|/path]      a notification that asks for a sound: the named /System/Library/Sounds sound or a
#                                  sound file from its "sound-name" / "sound-file" hint, else the alert sound
#   volume [negate]                BezelServices volume.aiff (only with volumeFeedback; "negate": Shift was held, which
#                                  inverts the setting, as BezelServices and Control Center do). A new pop stops the
#                                  one still playing in the same session (BezelServices playOneBeep: stops its NSSound,
#                                  then plays it again): no overlap when pops come quickly
#   screenshot                     ID 1393 system/Screen Capture.aif
#   trash-move                     Finder's TMoveToTrashTask plays ID 16 dock/drag to trash.aif (not move to trash.aif,
#                                  ID 14, which nothing in Finder or the Dock plays)
#   trash-empty                    ID 13 finder/empty trash.aif (Finder TEmptyTrashTask)
#   poof                           ID 15 dock/poof item off dock.aif
#   task-done, mount               ID 1 system/Volume Mount.aif: Finder's "task finished" sound (copy, move, duplicate,
#                                  put back, archive, mount, erase); a disk image mount itself plays nothing
#   unmount                        ID 2 system/Volume Unmount.aif (no caller in Finder or the Dock)
#   sent                           ID 1004 system/SentMessage.caf
#   power                          PowerChime connect_power.aif
#   (MAC-ANSWERS "Sounds per event" and "Sound ID -> file", reference/re/27.2.1/decomp/systemsoundserverd-ids.txt)
# Volume: systemsoundserverd scales every system sound it plays by the user volume pref (the Alert volume slider), UI
# sounds included: volume = user vol x client vol scalar x CM vol on the one "Starting audio" path for every action ID
# (27.2.1 arm64e, 0x10000b4c0..0x10000b6f4; the pref is stored at 0x10000dea4: read for commit 5c23f3e, no dump of that
# range is under reference/). The volume feedback pop (BezelServices) and the power chime (PowerChime) are not played by
# systemsoundserverd but with NSSound (MAC-ANSWERS "Sounds per event"), so the Alert volume does not reach them: they
# play at 1 (the output volume only). uiSounds gates the UI sounds only.
# Files: the Apple originals (sounds/originals, 24-bit PCM, same start latency in pw-play as the Vorbis copies:
# ~11 ms to streaming for both); an install without them falls back to the Vorbis copies in sounds/oga.
# HYPRK_MUTE=1 silences everything (nested test sessions at night). HYPRK_SOUND_LOG=<file>: append "<event> <file>"
# for every sound that would play (also when muted), to check the wiring without hearing it.
# Plays with pw-play, falls back to paplay, stays silent when neither exists or a file is missing.
set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SND=$ROOT/sounds
STATE=${HYPRK_STATE:-$ROOT/state}/sound.json
ALERTS=" Basso Blow Bottle Frog Funk Glass Hero Morse Ping Pop Purr Sosumi Submarine Tink "

alert="Tink"; vol=1; ui=true; fb=false
if [ -r "$STATE" ] && command -v jq >/dev/null; then
    IFS=$'\t' read -r alert vol ui fb < <(jq -r '[(if (.alertSound | type) == "string" and .alertSound != "" then .alertSound else "Tink" end), (if (.alertVolume | type) == "number" then .alertVolume else 1 end), (if .uiSounds == false then "false" else "true" end), (if .volumeFeedback == true then "true" else "false" end)] | @tsv' "$STATE" 2>/dev/null || printf 'Tink\t1\ttrue\tfalse\n')
fi
case "$ALERTS" in *" $alert "*) ;; *) alert=Tink ;; esac

# originals/<path>.<aif|aiff|caf|wav>, else oga/<path>.oga
pick() {
    local e
    for e in aif aiff caf wav; do [ -f "$SND/originals/$1.$e" ] && { f="$SND/originals/$1.$e"; return; }; done
    f="$SND/oga/$1.oga"
}
alertfile() {   # a /System/Library/Sounds name, any case
    local n
    for n in $ALERTS; do [ "${n,,}" = "${1,,}" ] && { pick "Sounds/$n"; return 0; }; done
    return 1
}

ev=${1:-}; arg=${2:-}
case "$ev" in
    alert)        alertfile "$alert" ;;
    notification)
        if [ -n "$arg" ] && [ "${arg#/}" != "$arg" ] && [ -r "$arg" ]; then f=$arg
        elif [ -z "$arg" ] || ! alertfile "$arg"; then alertfile "$alert"; fi ;;
    volume)       want=$fb; [ "$arg" = negate ] && { [ "$fb" = true ] && want=false || want=true; }
                  [ "$want" = true ] || exit 0; pick "misc/BezelServices-volume" ;;
    screenshot)   [ "$ui" = true ] || exit 0; pick "SystemSounds/system/Screen Capture" ;;
    trash-empty)  [ "$ui" = true ] || exit 0; pick "SystemSounds/finder/empty trash" ;;
    trash-move)   [ "$ui" = true ] || exit 0; pick "SystemSounds/dock/drag to trash" ;;
    task-done|mount) [ "$ui" = true ] || exit 0; pick "SystemSounds/system/Volume Mount" ;;
    unmount)      [ "$ui" = true ] || exit 0; pick "SystemSounds/system/Volume Unmount" ;;
    sent)         [ "$ui" = true ] || exit 0; pick "SystemSounds/system/SentMessage" ;;
    power)        [ "$ui" = true ] || exit 0; pick "misc/PowerChime-connect_power" ;;
    poof)         [ "$ui" = true ] || exit 0; pick "SystemSounds/dock/poof item off dock" ;;
    *) echo "usage: sound.sh <event> [arg]" >&2; exit 2 ;;
esac
[ -f "$f" ] || exit 0
[ -n "${HYPRK_SOUND_LOG:-}" ] && printf '%s %s\n' "$ev" "$f" >> "$HYPRK_SOUND_LOG"
[ "${HYPRK_MUTE:-0}" = 1 ] && exit 0      # silent test runs

# The Alert volume slider s is not the gain: Settings stores exp(s - 1) (0 when s is 0) in com.apple.sound.beep.volume
# (Sound.appex -[AppleSound_SoundSettings setAlertSoundVolume:] 0x100007f98) and systemsoundserverd multiplies that
# into its mixer's linear input gain (reference/re/27.2.1/SOUND-REA-27.2.1.md section 1): -6.5 dB at s = .25, -4.3 at
# .5, -2.2 at .75. It was the slider itself as a linear gain (-12 / -6 / -2.5 dB). The stock value is s = 1.
vol=$(LC_ALL=C awk -v s="$vol" 'BEGIN { s = s < 0 ? 0 : s > 1 ? 1 : s; printf "%.4f", s == 0 ? 0 : exp(s - 1) }')
case "$ev" in volume|power) vol=1 ;; esac    # NSSound, not systemsoundserverd: no alert volume
if [ "$ev" = volume ]; then   # restart, never overlap: stop this session's previous pop (only a player of that file)
    pidf=${XDG_RUNTIME_DIR:-/tmp}/hyprk-volume-pop-${HYPRLAND_INSTANCE_SIGNATURE:-0}.pid
    read -r old 2>/dev/null < "$pidf" && grep -qa BezelServices-volume "/proc/$old/cmdline" 2>/dev/null && kill "$old" 2>/dev/null
    echo $$ > "$pidf"
fi
if command -v pw-play >/dev/null; then
    exec pw-play --volume "$vol" "$f"
elif command -v paplay >/dev/null; then
    exec paplay --volume "$(awk -v v="$vol" 'BEGIN{printf "%d", v*65536}')" "$f"
fi
exit 0
