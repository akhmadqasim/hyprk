#!/bin/sh
# Install the MacOS27 Qt theme for qt6ct (Fusion style + custom palette + QSS). Runs only when you call it.
#   ./install.sh [--dark] [--prefix DIR]    default target: ${XDG_CONFIG_HOME:-~/.config}/qt6ct ; --prefix DIR writes DIR/qt6ct instead
# Needs the `qt6ct` package (apt install qt6ct) and QT_QPA_PLATFORMTHEME=qt6ct in the session environment.
# An existing qt6ct.conf is kept (saved copy: qt6ct.conf.hyprk-backup) and only the macOS keys are written when --force is given.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
V=light; BASE=${XDG_CONFIG_HOME:-$HOME/.config}; FORCE=0
while [ $# -gt 0 ]; do case $1 in --dark) V=dark ;; --prefix) BASE=$2; shift ;; --force) FORCE=1 ;; *) echo "unknown option $1" >&2; exit 2 ;; esac; shift; done
T=$BASE/qt6ct; mkdir -p "$T/colors" "$T/qss" "$T/macos27-assets"
cp "$HERE"/colors/macos27-*.conf "$T/colors/"
cp "$HERE"/assets/*.svg "$T/macos27-assets/"
for v in light dark; do sed "s|@ASSETS@|$T/macos27-assets|g" "$HERE/qss/macos27-$v.qss" > "$T/qss/macos27-$v.qss"; done
CONF=$T/qt6ct.conf
if [ -f "$CONF" ] && [ $FORCE = 0 ]; then
  echo "kept existing $CONF. In qt6ct pick: style Fusion, palette 'Custom' = $T/colors/macos27-$V.conf, stylesheet $T/qss/macos27-$V.qss (or rerun with --force)"
else
  [ -f "$CONF" ] && cp "$CONF" "$CONF.hyprk-backup"
  cat > "$CONF" <<EOT
[Appearance]
color_scheme_path=$T/colors/macos27-$V.conf
custom_palette=true
standard_dialogs=default
style=Fusion
[Fonts]
fixed="SF Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="SF Pro Text,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
[Interface]
stylesheets=$T/qss/macos27-$V.qss
EOT
  echo "wrote $CONF ($V)"
fi
echo "Set QT_QPA_PLATFORMTHEME=qt6ct (and QT_STYLE_OVERRIDE unset) for Qt apps. Fonts: SF Pro, fallback Inter/Cantarell (themes/gtk/FALLBACKS.md)."
