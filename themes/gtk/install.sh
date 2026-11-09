#!/bin/sh
# Install the MacOS27 GTK theme. Runs ONLY when you call it; nothing is touched otherwise.
#
#   ./install.sh                 install into $HOME  (~/.themes, ~/.config/gtk-4.0, ~/.config/gtk-3.0)
#   ./install.sh --prefix DIR    install into DIR/share/themes (+ DIR/etc-xdg/gtk-{3,4}.0 for the user css); touches nothing else
#   ./install.sh --gsettings     also set gtk-theme / button-layout / color-scheme via gsettings (HOME install only)
#   ./install.sh --uninstall     remove what a HOME install put there (backups, if any, stay in ~/.config/*/gtk.css.hyprk-backup)
#
# Existing ~/.config/gtk-{3,4}.0/gtk.css and settings.ini are copied to <name>.hyprk-backup first.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
PREFIX=; GS=0; UN=0
while [ $# -gt 0 ]; do
  case $1 in
    --prefix) PREFIX=$2; shift ;;
    --gsettings) GS=1 ;;
    --uninstall) UN=1 ;;
    -h|--help) sed -n 2,10p "$0"; exit 0 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

if [ -n "$PREFIX" ]; then
  THEMES=$PREFIX/share/themes; CFG3=$PREFIX/etc-xdg/gtk-3.0; CFG4=$PREFIX/etc-xdg/gtk-4.0
else
  THEMES=${XDG_DATA_HOME:-$HOME/.local/share}/themes; CFG3=${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0; CFG4=${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0
fi

if [ $UN = 1 ]; then
  rm -rf "$THEMES/MacOS27" "$THEMES/MacOS27-Dark"
  for f in "$CFG4/gtk.css" "$CFG3/gtk.css"; do
    if grep -q "MacOS27 theme" "$f" 2>/dev/null; then rm -f "$f"; [ -f "$f.hyprk-backup" ] && mv "$f.hyprk-backup" "$f"; fi
  done
  echo "removed"; exit 0
fi

backup() { [ -f "$1" ] && ! grep -q "MacOS27 theme" "$1" && cp -n "$1" "$1.hyprk-backup" || true; }
mkdir -p "$THEMES" "$CFG3" "$CFG4"
cp -r "$HERE/MacOS27" "$HERE/MacOS27-Dark" "$THEMES/"
GSV=${PREFIX:+$PREFIX/share}; GSV=${GSV:-${XDG_DATA_HOME:-$HOME/.local/share}}/gtksourceview-5/styles
mkdir -p "$GSV"; cp "$HERE"/gtksourceview/*.xml "$GSV/"   # Text Editor: gsettings set org.gnome.TextEditor style-scheme macos27-light
# GTK 4 / libadwaita apps ignore theme names; they read the user stylesheet (light + dark via prefers-color-scheme)
backup "$CFG4/gtk.css"; cp "$HERE/gtk-4.0/gtk.css" "$CFG4/gtk.css"
# GTK 3 apps use the theme dir; the user css is only needed on top of another theme, so it is not installed
for d in "$CFG3" "$CFG4"; do
  if [ ! -f "$d/settings.ini" ]; then cp "$HERE/config/settings.ini" "$d/settings.ini"
  else echo "note: $d/settings.ini exists, merge $HERE/config/settings.ini by hand (gtk-decoration-layout=close,minimize,maximize:)"; fi
done
if [ $GS = 1 ] && [ -z "$PREFIX" ] && command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme MacOS27
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
fi
echo "installed to $THEMES (theme dirs) and $CFG4/gtk.css"
echo "GTK 3: set gtk-theme-name=MacOS27 (MacOS27-Dark for dark) in settings.ini or via gsettings (--gsettings)."
echo "Fonts: see FALLBACKS.md (SF Pro from ../fonts, else Inter, else Cantarell)."
