#!/bin/bash
# starts a private nested Hyprland with a headless output (never touches the real session). stop: tools/hypr-headless.sh stop
source "$(dirname "$0")/hypr-env.sh"; H=$HK_DIR
if [ "$1" = stop ]; then [ -f $H/pid ] && kill $(cat $H/pid) 2>/dev/null; exit; fi
cat > $H/hl.lua <<EOT
hl.monitor({ output = "WAYLAND-1", disabled = true })
hl.monitor({ output = "HEADLESS-1", mode = "${SIZE:-1440x900}@60", position = "0x0", scale = 1 })
hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 }, decoration = { rounding = 0 },
  misc = { disable_hyprland_logo = true, disable_splash_rendering = true, force_default_wallpaper = 0 },
  ecosystem = { no_update_news = true, no_donation_nag = true } })
EOT
export AQ_BACKENDS=headless,wayland
unset HYPRLAND_INSTANCE_SIGNATURE
XDG_CURRENT_DESKTOP=Hyprland Hyprland -c $H/hl.lua > $H/hl.log 2>&1 &
echo $! > $H/pid
for _ in $(seq 1 40); do PIDS=$(pgrep -f "Hyprland -c $H/hl.lua" | tr '
' ' '); [ -n "$PIDS" ] && for p in $PIDS; do hyprctl instances 2>/dev/null | grep -qE "pid: $p$" && break 2; done; sleep 0.25; done
# find OUR instance: the one whose pid belongs to a process started with our config path
read SIG WL < <(hyprctl instances | awk -v pids="$PIDS" 'BEGIN{n=split(pids,a," ");for(i=1;i<=n;i++)m[a[i]]=1} /^instance/{s=$2;sub(":","",s)} /pid:/{p=$2} /wl socket/{if(p in m)print s, $3}' | tail -1)
[ -z "$SIG" ] && { echo "could not find our Hyprland instance, see $H/hl.log" >&2; exit 1; }
echo $SIG > $H/sig; echo $WL > $H/wl
HYPRLAND_INSTANCE_SIGNATURE=$SIG hyprctl output create headless >/dev/null
echo "sig=$SIG wl=$WL"
