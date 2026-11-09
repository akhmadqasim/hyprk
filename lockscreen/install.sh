#!/bin/sh
# Install the macOS 27 style hyprlock config. Runs only when you call it.
#   ./install.sh [--prefix DIR] [--wallpaper FILE] [--avatar FILE]
# Writes DIR/hypr/hyprlock.conf (default DIR = ${XDG_CONFIG_HOME:-~/.config}). An existing file is saved as hyprlock.conf.hyprk-backup.
# Avatar: --avatar, else ~/.face if present, else lockscreen/assets/avatar-default.png.
# Needs hyprlock >= 0.9 (apt hyprlock 0.9.2 works with this config; hyprk builds 0.9.7 into /mnt/code/hypr-dev/prefix).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
BASE=${XDG_CONFIG_HOME:-$HOME/.config}; WP=; AV=
while [ $# -gt 0 ]; do case $1 in --prefix) BASE=$2; shift ;; --wallpaper) WP=$2; shift ;; --avatar) AV=$2; shift ;; *) echo "unknown option $1" >&2; exit 2 ;; esac; shift; done
[ -z "$AV" ] && { [ -f "$HOME/.face" ] && AV=$HOME/.face || AV=$HERE/assets/avatar-default.png; }
[ -z "$WP" ] && WP="$HERE/../themes/wallpapers/png/Sonoma Horizon.png"
mkdir -p "$BASE/hypr"; DST=$BASE/hypr/hyprlock.conf
[ -f "$DST" ] && ! grep -q "macOS 27 style lock screen" "$DST" && cp -n "$DST" "$DST.hyprk-backup"
sed -e "s|^\$WALLPAPER = .*|\$WALLPAPER = $WP|" -e "s|^\$AVATAR = .*|\$AVATAR = $AV|" "$HERE/hyprlock.conf" > "$DST"
echo "wrote $DST"
