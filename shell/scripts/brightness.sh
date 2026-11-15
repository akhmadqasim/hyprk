#!/usr/bin/env bash
# Display brightness backends for shell/services/Brightness.qml (always run off the UI thread, as a Process).
#   brightness.sh probe                      one line per backend that works (lib/hardware.js parseProbe):
#                                              "backlight <current> <max>"    a backlight class device (brightnessctl)
#                                              "ddc <bus> <current> <max>"    an external monitor, DDC/CI VCP 10 (ddcutil)
#                                            nothing = no brightness control (both sliders are disabled)
#   brightness.sh set <0..1> <bus>:<max>...  VCP 10 on each of those DDC monitors, one after another
# A monitor that is asleep or on another input does not answer DDC: it is left out of the probe, and the shell looks
# again later (Control Center opening, Settings > Displays opening). ddcutil holds a flock on /dev/i2c-N, so other
# DDC tools on the machine wait their turn. HYPRK_DDCUTIL names the ddcutil to run (tests: a fake one).
set -u
DDC=${HYPRK_DDCUTIL:-ddcutil}
tmo() { if command -v timeout >/dev/null 2>&1; then timeout "$@"; else shift; "$@"; fi; }

case "${1:-}" in
probe)
    if command -v brightnessctl >/dev/null 2>&1; then
        # name,class,current,percent%,max
        info=$(brightnessctl -m -c backlight info 2>/dev/null) && [ -n "$info" ] &&
            printf '%s\n' "$info" | head -n 1 | awk -F, '$5 > 0 { print "backlight", $3, $5; ok = 1 } END { exit !ok }' && exit 0
    fi
    command -v "$DDC" >/dev/null 2>&1 || exit 0
    # "Display N" blocks only: an "Invalid display" (no answer on I2C address 0x37) is skipped
    tmo 20 "$DDC" detect --brief 2>/dev/null |
        awk '/^[^ \t]/ { ok = ($1 == "Display") } ok && /I2C bus:/ { n = $NF; sub(/.*i2c-/, "", n); print n }' |
        while read -r bus; do
            # "VCP 10 C <current> <max>"
            tmo 10 "$DDC" --bus "$bus" --brief getvcp 10 2>/dev/null |
                awk -v b="$bus" '$1 == "VCP" && $2 == "10" && $3 == "C" && $5 > 0 { print "ddc", b, $4, $5 }'
        done
    ;;
set)
    v=${2:-}; [ -n "$v" ] || exit 2
    shift 2
    for d in "$@"; do
        bus=${d%%:*}; max=${d##*:}
        n=$(awk -v v="$v" -v m="$max" 'BEGIN { n = int(v * m + 0.5); if (n < 1) n = 1; if (n > m) n = m; print n }')
        tmo 10 "$DDC" --bus "$bus" --noverify setvcp 10 "$n" >/dev/null 2>&1
    done
    ;;
*) echo "usage: brightness.sh probe | set <0..1> <bus>:<max>..." >&2; exit 2 ;;
esac
exit 0
