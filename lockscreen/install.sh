#!/bin/sh
# Install the macOS 27 style hyprlock config. Runs only when you call it.
#   ./install.sh [--prefix DIR] [--wallpaper FILE] [--avatar FILE]
# Writes DIR/hypr/hyprlock.conf (default DIR = ${XDG_CONFIG_HOME:-~/.config}). An existing foreign file is saved once as hyprlock.conf.hyprk-backup.
# Avatar: --avatar, else ~/.face if present, else lockscreen/assets/avatar-default.png.
# Needs hyprlock >= 0.9 (apt hyprlock 0.9.2 reads this config; hyprk builds 0.9.7 into its dev prefix).
set -e
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/../themes/lib.sh"
PREFIX=; WP=; AV=
while [ $# -gt 0 ]; do case $1 in --prefix) PREFIX=$2; shift ;; --wallpaper) WP=$2; shift ;; --avatar) AV=$2; shift ;; *) echo "unknown option $1" >&2; exit 2 ;; esac; shift; done
[ -z "$AV" ] && { [ -f "$HOME/.face" ] && AV=$HOME/.face || AV=$HERE/assets/avatar-default.png; }
[ -z "$WP" ] && WP="$HERE/../themes/wallpapers/png/Sonoma Horizon.png"
DST=$(hk_cfgbase "$PREFIX")/hypr/hyprlock.conf; mkdir -p "$(dirname "$DST")"
hk_backup "$DST"
# awk -v keeps '|', '&' and backslashes in the paths intact (sed would not)
awk -v wp="$WP" -v av="$AV" '/^\$WALLPAPER = /{print "$WALLPAPER = " wp; next} /^\$AVATAR = /{print "$AVATAR = " av; next} {print}' "$HERE/hyprlock.conf" > "$DST"
echo "wrote $DST"
