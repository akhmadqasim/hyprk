#!/bin/sh
# Prints the path of the status icon to show on the lock screen. usage: status-icon.sh wifi|battery
# hyprlock calls it through `reload_cmd` every few seconds, so it uses only shell builtins (no forks) and never fails
# (falls back to the empty icon). HYPRK_LOCK_DEMO=1 (tools/shot.sh) shows fixed icons for screenshots on machines without Wi-Fi/battery.
D=${0%/*}/../assets/status
if [ -n "$HYPRK_LOCK_DEMO" ]; then
  case $1 in wifi) echo "$D/wifi-3.png" ;; battery) echo "$D/battery-75.png" ;; esac
  exit 0
fi
case $1 in
  wifi)
    have=
    for n in /sys/class/net/*/wireless; do
      [ -d "$n" ] || continue
      have=1; s=
      read -r s < "$n/../operstate" 2>/dev/null
      [ "$s" = up ] && { echo "$D/wifi-3.png"; exit 0; }
    done
    # a wired-only desktop shows nothing instead of a misleading "off" icon
    [ -n "$have" ] && echo "$D/wifi-off.png" || echo "$D/none.png" ;;
  battery)
    for b in /sys/class/power_supply/BAT*; do [ -d "$b" ] && break; done
    [ -d "$b" ] || { echo "$D/none.png"; exit 0; }
    st=; cap=; read -r st < "$b/status" 2>/dev/null; read -r cap < "$b/capacity" 2>/dev/null
    : "${cap:=100}"
    if   [ "$st" = Charging ]; then echo "$D/battery-charging.png"
    elif [ "$cap" -ge 88 ]; then echo "$D/battery-100.png"
    elif [ "$cap" -ge 63 ]; then echo "$D/battery-75.png"
    elif [ "$cap" -ge 38 ]; then echo "$D/battery-50.png"
    elif [ "$cap" -ge 18 ]; then echo "$D/battery-25.png"
    else echo "$D/battery-10.png"; fi ;;
  *) echo "$D/none.png" ;;
esac
