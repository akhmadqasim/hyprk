#!/bin/sh
# A made-up ddcutil for the tests (HYPRK_DDCUTIL): two monitors on I2C buses 7 and 8 kept as files in $FAKE_DDC_DIR.
#   $FAKE_DDC_DIR/asleep     present: the monitors do not answer (detect lists them as "Invalid display")
#   $FAKE_DDC_DIR/level-<N>  the monitor's VCP 10 value (25 when missing), max 100
#   $FAKE_DDC_DIR/writes     one line "<bus> <value>" per setvcp
# FAKE_DDC_SLOW=<seconds>: each setvcp takes that long (the real one takes about 0.1 s).
D=${FAKE_DDC_DIR:?}
bus=""
while [ $# -gt 0 ]; do
    case "$1" in
        --bus) bus=$2; shift 2 ;;
        --*) shift ;;
        *) break ;;
    esac
done
case "${1:-}" in
detect)
    for b in 7 8; do
        if [ -e "$D/asleep" ]; then echo "Invalid display"; else echo "Display $((b - 6))"; fi
        printf '   I2C bus:          /dev/i2c-%s\n   DRM connector:    card1-DP-%s\n   Monitor:          LEN:N27p:UMA%s\n\n' "$b" "$((b - 6))" "$b"
    done ;;
getvcp)
    [ -e "$D/asleep" ] && { echo "Display not found"; exit 1; }
    v=25; [ -r "$D/level-$bus" ] && v=$(cat "$D/level-$bus")
    echo "VCP 10 C $v 100" ;;
setvcp)
    [ -e "$D/asleep" ] && exit 1
    [ -n "${FAKE_DDC_SLOW:-}" ] && sleep "$FAKE_DDC_SLOW"
    echo "$3" > "$D/level-$bus"; echo "$bus $3" >> "$D/writes" ;;
esac
