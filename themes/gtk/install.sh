#!/bin/sh
# Install the MacOS27 GTK theme. Runs ONLY when you call it; nothing is touched otherwise.
#
#   ./install.sh                 install into $HOME  (~/.local/share/themes, ~/.config/gtk-4.0, ~/.config/gtk-3.0)
#   ./install.sh --prefix DIR    install into DIR/share/themes (+ DIR/etc-xdg/gtk-{3,4}.0 for the user css); touches nothing else
#   ./install.sh --gsettings     also set gtk-theme / button-layout via gsettings (HOME install only)
#   ./install.sh --keyfile [--dark]   write <config>/glib-2.0/settings/keyfile with the GSettings values GTK needs (traffic lights on
#                                the left, theme, colour scheme, fonts). Export GSETTINGS_BACKEND=keyfile ADW_DISABLE_PORTAL=1 in the
#                                session so GTK/libadwaita read it instead of dconf and the host portal (see DIST-NOTES.md)
#   ./install.sh --uninstall     remove what a HOME install put there (originals saved as *.hyprk-backup are restored)
#
# Existing ~/.config/gtk-4.0/gtk.css is copied to gtk.css.hyprk-backup first (once).
set -e
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/../lib.sh"
PREFIX=; GS=0; UN=0; KF=0; DARK=0
while [ $# -gt 0 ]; do
  case $1 in
    --prefix) PREFIX=$2; shift ;;
    --gsettings) GS=1 ;;
    --uninstall) UN=1 ;;
    --keyfile) KF=1 ;;
    --dark) DARK=1 ;;
    -h|--help) sed -n 2,13p "$0"; exit 0 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done

if [ -n "$PREFIX" ]; then
  DATA=$PREFIX/share; CFG3=$PREFIX/etc-xdg/gtk-3.0; CFG4=$PREFIX/etc-xdg/gtk-4.0
else
  DATA=${XDG_DATA_HOME:-$HOME/.local/share}; CFG3=$(hk_cfgbase)/gtk-3.0; CFG4=$(hk_cfgbase)/gtk-4.0
fi
THEMES=$DATA/themes; GSV=$DATA/gtksourceview-5/styles

if [ $UN = 1 ]; then
  rm -rf "$THEMES/MacOS27" "$THEMES/MacOS27-Dark" "$GSV"/macos27-light.xml "$GSV"/macos27-dark.xml
  for f in "$CFG4/gtk.css" "$CFG4/settings.ini" "$CFG3/settings.ini" "$(hk_cfgbase "$PREFIX")/glib-2.0/settings/keyfile"; do
    if grep -q "hyprk-managed" "$f" 2>/dev/null; then rm -f "$f"; [ -f "$f.hyprk-backup" ] && mv "$f.hyprk-backup" "$f"; fi
  done
  echo "removed"; exit 0
fi

mkdir -p "$THEMES" "$CFG3" "$CFG4" "$GSV"
for t in MacOS27 MacOS27-Dark; do rm -rf "$THEMES/$t"; cp -r "$HERE/$t" "$THEMES/$t"; done
cp "$HERE"/gtksourceview/*.xml "$GSV/"   # Text Editor: gsettings set org.gnome.TextEditor style-scheme macos27-light
# GTK 4 / libadwaita apps ignore theme names; they read the user stylesheet (light + dark via prefers-color-scheme)
hk_backup "$CFG4/gtk.css"; cp "$HERE/gtk-4.0/gtk.css" "$CFG4/gtk.css"
for d in "$CFG3" "$CFG4"; do
  if [ ! -f "$d/settings.ini" ] || grep -q hyprk-managed "$d/settings.ini"; then cp "$HERE/config/settings.ini" "$d/settings.ini"
  else echo "note: $d/settings.ini exists, merge $HERE/config/settings.ini by hand (gtk-decoration-layout=close,minimize,maximize:)"; fi
done
if [ $KF = 1 ]; then
  KD=$(hk_cfgbase "$PREFIX")/glib-2.0/settings; mkdir -p "$KD"; hk_backup "$KD/keyfile"
  cat > "$KD/keyfile" <<EOT
# hyprk-managed
[org/gnome/desktop/wm/preferences]
button-layout='close,minimize,maximize:'

[org/gnome/desktop/interface]
gtk-theme='MacOS27$([ $DARK = 1 ] && echo -Dark)'
color-scheme='$([ $DARK = 1 ] && echo prefer-dark || echo prefer-light)'
font-name='SF Pro 10'
monospace-font-name='SF Mono 10'
cursor-theme='hyprk-cursors'
EOT
  echo "wrote $KD/keyfile (export GSETTINGS_BACKEND=keyfile ADW_DISABLE_PORTAL=1)"
fi
if [ $GS = 1 ] && [ -z "$PREFIX" ] && command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme MacOS27
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
fi
echo "installed to $THEMES (theme dirs) and $CFG4/gtk.css"
echo "GTK 3: set gtk-theme-name=MacOS27 (MacOS27-Dark for dark) in settings.ini or via gsettings (--gsettings)."
echo "Fonts: see FALLBACKS.md (SF Pro from ../fonts, else Inter, else Cantarell)."
