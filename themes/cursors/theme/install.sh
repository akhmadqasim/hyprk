#!/usr/bin/env bash
# Install the hyprk-cursors theme (Xcursor + hyprcursor in one directory).
# Usage: install.sh [ICONS_DIR]   default: ~/.local/share/icons
# Builds the theme first (build.py) when hyprk-cursors/ is missing or --build is given.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
name=hyprk-cursors
build=0
dest=""
for a in "$@"; do
  case "$a" in
    --build) build=1 ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) dest="$a" ;;
  esac
done
dest="${dest:-${XDG_DATA_HOME:-$HOME/.local/share}/icons}"

if [[ $build -eq 1 || ! -d "$here/$name" ]]; then
  python3 -I "$here/build.py" "$here/$name"
fi

mkdir -p "$dest"
rm -rf "${dest:?}/$name"
cp -a "$here/$name" "$dest/$name"
echo "installed $name -> $dest/$name"
cat <<MSG
Activate:
  Hyprland (hyprcursor):  env = HYPRCURSOR_THEME,$name   env = HYPRCURSOR_SIZE,24
                          hyprctl setcursor $name 24
  Xcursor / XWayland:     env = XCURSOR_THEME,$name      env = XCURSOR_SIZE,24
  GTK:                    gsettings set org.gnome.desktop.interface cursor-theme $name
MSG
