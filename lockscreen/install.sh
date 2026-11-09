#!/bin/sh
# Install the macOS 27 style hyprlock config. Runs only when you call it.
#   ./install.sh [--dark] [--prefix DIR] [--wallpaper FILE] [--avatar FILE]
# Writes DIR/hypr/hyprlock.conf (default DIR = ${XDG_CONFIG_HOME:-~/.config}). An existing foreign file is saved once as hyprlock.conf.hyprk-backup.
# Wallpaper: --wallpaper, else the path in hyprk's state/wallpaper.json (the desktop wallpaper), else TahoeLight (TahoeDark with --dark).
# Avatar: --avatar, else ~/.face if present, else lockscreen/assets/avatar-default.png.
# The wallpaper is fixed at install time; use lockscreen/hyprk-lock.sh to lock with whatever the desktop wallpaper is right now.
# Needs hyprlock >= 0.9 (apt hyprlock 0.9.2 reads this config; hyprk builds 0.9.7 into its dev prefix).
set -e
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/../themes/lib.sh"
PREFIX=; WP=; AV=; DARK=0
while [ $# -gt 0 ]; do case $1 in --prefix) PREFIX=$2; shift ;; --wallpaper) WP=$2; shift ;; --avatar) AV=$2; shift ;; --dark) DARK=1 ;; *) echo "unknown option $1" >&2; exit 2 ;; esac; shift; done
ROOT=$(cd "$HERE/.." && pwd)
[ -z "$AV" ] && { [ -f "$HOME/.face" ] && AV=$HOME/.face || AV=$HERE/assets/avatar-default.png; }
if [ -z "$WP" ]; then
  STATE=${HYPRK_STATE:-$ROOT/state}/wallpaper.json
  [ -f "$STATE" ] && WP=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("path",""))' "$STATE" 2>/dev/null)
  [ -f "$WP" ] || WP=$ROOT/themes/wallpapers/png/Tahoe$([ $DARK = 1 ] && echo Dark || echo Light).png
fi
DST=$(hk_cfgbase "$PREFIX")/hypr/hyprlock.conf; mkdir -p "$(dirname "$DST")"
hk_backup "$DST"
# ENVIRON (not awk -v) so backslashes, '|' and '&' in the paths stay literal; avoid '#' in paths, hyprlang reads it as a comment
WALLPAPER=$WP AVATAR=$AV STATUS=$HERE/scripts/status-icon.sh STATUS_DIR=$HERE/assets/status awk '
  /^\$(WALLPAPER|AVATAR|STATUS|STATUS_DIR) = / { k = substr($1, 2); print "$" k " = " ENVIRON[k]; next }
  { print }' "$HERE/hyprlock.conf" > "$DST"
echo "wrote $DST (wallpaper $WP)"
