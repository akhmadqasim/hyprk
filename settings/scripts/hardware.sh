#!/bin/sh
# Which hardware this computer has, as key=0|1 lines (Parsers.parseHardware). Read-only: /sys, udev's database and
# nmcli; nothing is written. Settings hides what belongs to hardware that is absent (FALLBACKS.md "Absent hardware").
any() { for f in "$@"; do [ -e "$f" ] && return 0; done; return 1; }
yn() { if "$@" >/dev/null 2>&1; then echo 1; else echo 0; fi; }
# an input device udev tagged with $1 (ID_INPUT_TOUCHPAD, ID_INPUT_MOUSE); the tags are libinput's own
input() { grep -qsx "E:$1=1" /run/udev/data/c13:* /run/udev/data/+input:*; }
wifi() { any /sys/class/net/*/wireless || any /sys/class/net/*/phy80211 || nmcli -t -f TYPE device 2>/dev/null | grep -qx wifi; }
battery() {
    for d in /sys/class/power_supply/*; do
        [ "$(cat "$d/type" 2>/dev/null)" = Battery ] && [ "$(cat "$d/scope" 2>/dev/null)" != Device ] && return 0
    done
    return 1
}
echo "wifi=$(yn wifi)"
echo "bluetooth=$(yn any /sys/class/bluetooth/hci*)"
echo "battery=$(yn battery)"
echo "trackpad=$(yn input ID_INPUT_TOUCHPAD)"
echo "mouse=$(yn input ID_INPUT_MOUSE)"
echo "keyboardBacklight=$(yn any /sys/class/leds/*kbd_backlight*)"
echo "ambientLight=$(yn any /sys/bus/iio/devices/*/in_illuminance*)"
