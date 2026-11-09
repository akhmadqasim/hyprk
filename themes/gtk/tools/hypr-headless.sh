#!/bin/bash
# starts a private nested Hyprland with a headless output (never touches the real session). stop: tools/hypr-headless.sh stop
H=/tmp/claude-1000/hk; mkdir -p $H
if [ "$1" = stop ]; then kill $(cat $H/pid) 2>/dev/null; exit; fi
source /mnt/code/hypr-dev/env.sh
cat > $H/hl.lua <<EOT
hl.monitor({ output = "", mode = "${SIZE:-1440x900}@60", position = "auto", scale = 1 })
hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 }, decoration = { rounding = 0 },
  misc = { disable_hyprland_logo = true, disable_splash_rendering = true, force_default_wallpaper = 0 },
  ecosystem = { no_update_news = true, no_donation_nag = true } })
EOT
export AQ_BACKENDS=headless
Hyprland -c $H/hl.lua > $H/hl.log 2>&1 &
echo $! > $H/pid; sleep 4
# find our instance by pid
read SIG WL < <(hyprctl instances | awk -v p="$(pgrep -P $(cat $H/pid) | head -1)" '/^instance/{s=$2;sub(":","",s)} /pid:/{pid=$2} /wl socket/{print s, $3}' | tail -1)
echo $SIG > $H/sig; echo $WL > $H/wl
HYPRLAND_INSTANCE_SIGNATURE=$SIG hyprctl output create headless >/dev/null
echo "sig=$SIG wl=$WL"
