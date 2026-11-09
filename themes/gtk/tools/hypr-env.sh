# source me: points GTK apps + grim at the headless nested Hyprland (started by tools/hypr-headless.sh)
source /mnt/code/hypr-dev/env.sh
export HK_SIG=$(cat /tmp/claude-1000/hk/sig 2>/dev/null); export HYPRLAND_INSTANCE_SIGNATURE=$HK_SIG
export HK_WL=$(cat /tmp/claude-1000/hk/wl 2>/dev/null)
