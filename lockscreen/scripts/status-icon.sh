#!/bin/sh
# Prints the path of the status icon to show on the lock screen. usage: status-icon.sh wifi|battery
# hyprlock calls it through `reload_cmd`; it must stay fast and never fail (falls back to the empty icon).
D=$(cd "$(dirname "$0")/../assets/status" && pwd)
# HYPRK_LOCK_DEMO=1 (used by tools/shot.sh) shows fixed icons so screenshots work on machines without Wi-Fi or a battery
[ -n "$HYPRK_LOCK_DEMO" ] && { case "$1" in wifi) echo "$D/wifi-3.png" ;; battery) echo "$D/battery-75.png" ;; esac; exit 0; }
case "$1" in
  wifi)
    up=0
    for n in /sys/class/net/*/wireless; do
      [ -d "$n" ] || continue
      dev=$(basename "$(dirname "$n")")
      [ "$(cat "/sys/class/net/$dev/operstate" 2>/dev/null)" = up ] && up=1
    done
    # a wired-only desktop shows nothing instead of a misleading "off" icon
    [ $up = 1 ] && echo "$D/wifi-3.png" || { ls -d /sys/class/net/*/wireless >/dev/null 2>&1 && echo "$D/wifi-off.png" || echo "$D/none.png"; } ;;
  battery)
    b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
    [ -n "$b" ] || { echo "$D/none.png"; exit 0; }
    st=$(cat "$b/status" 2>/dev/null); cap=$(cat "$b/capacity" 2>/dev/null || echo 100)
    if [ "$st" = Charging ]; then echo "$D/battery-charging.png"; exit 0; fi
    if   [ "$cap" -ge 88 ]; then echo "$D/battery-100.png"
    elif [ "$cap" -ge 63 ]; then echo "$D/battery-75.png"
    elif [ "$cap" -ge 38 ]; then echo "$D/battery-50.png"
    elif [ "$cap" -ge 18 ]; then echo "$D/battery-25.png"
    else echo "$D/battery-10.png"; fi ;;
  *) echo "$D/none.png" ;;
esac
