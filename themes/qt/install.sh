#!/bin/sh
# Install the MacOS27 Qt theme for qt6ct (Fusion style + custom palette + QSS). Runs only when you call it.
#   ./install.sh [--dark] [--kvantum] [--force] [--prefix DIR]
#   default target: ${XDG_CONFIG_HOME:-~/.config}/qt6ct ; --prefix DIR writes DIR/qt6ct (and DIR/Kvantum) instead.
#   --kvantum: also install the Kvantum theme (rounded translucent menus) and make qt6ct use style=kvantum. Needs qt6-style-kvantum.
#   --force: overwrite an existing qt6ct.conf (original kept once as qt6ct.conf.hyprk-backup); without it only a hint is printed.
# Needs the `qt6ct` package (apt install qt6ct) and QT_QPA_PLATFORMTHEME=qt6ct in the session environment.
set -e
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/../lib.sh"
V=light; PREFIX=; FORCE=0; KVT=0
while [ $# -gt 0 ]; do case $1 in --dark) V=dark ;; --prefix) PREFIX=$2; shift ;; --force) FORCE=1 ;; --kvantum) KVT=1 ;; *) echo "unknown option $1" >&2; exit 2 ;; esac; shift; done
BASE=$(hk_cfgbase "$PREFIX"); T=$BASE/qt6ct; N=MacOS27$([ $V = dark ] && echo Dark || echo Light)
mkdir -p "$T/colors" "$T/qss" "$T/macos27-assets"
cp "$HERE/colors/macos27-$V.conf" "$T/colors/"
cp "$HERE"/assets/*.svg "$T/macos27-assets/"
sed "s|@ASSETS@|$(printf '%s' "$T/macos27-assets" | sed 's/[&|\\]/\\&/g')|g" "$HERE/qss/macos27-$V.qss" > "$T/qss/macos27-$V.qss"
if [ $KVT = 1 ]; then
  mkdir -p "$BASE/Kvantum"; rm -rf "$BASE/Kvantum/$N"; cp -r "$HERE/kvantum/$N" "$BASE/Kvantum/"
  hk_backup "$BASE/Kvantum/kvantum.kvconfig"
  printf '# hyprk-managed\n[General]\ntheme=%s\n' "$N" > "$BASE/Kvantum/kvantum.kvconfig"
fi
CONF=$T/qt6ct.conf
if [ -f "$CONF" ] && [ $FORCE = 0 ]; then
  echo "kept existing $CONF (use --force to rewrite it). In qt6ct pick: palette 'Custom' = $T/colors/macos27-$V.conf and either style Fusion + stylesheet $T/qss/macos27-$V.qss, or (with --kvantum) style kvantum"
else
  STYLE=Fusion; CUSTOMPAL=true; SHEET="stylesheets=$T/qss/macos27-$V.qss"
  [ $KVT = 1 ] && { STYLE=kvantum; CUSTOMPAL=false; SHEET=; }
  [ -f "$CONF" ] && cp -n "$CONF" "$CONF.hyprk-backup"
  cat > "$CONF" <<EOT
# hyprk-managed
[Appearance]
color_scheme_path=$T/colors/macos27-$V.conf
custom_palette=$CUSTOMPAL
standard_dialogs=default
style=$STYLE
[Fonts]
fixed="SF Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="SF Pro,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
[Interface]
$SHEET
EOT
  echo "wrote $CONF ($V, style $STYLE)"
fi
# SF fonts by family name: drop-in fontconfig snippet (same file the test rigs use), dir = themes/fonts/named
FC=$BASE/fontconfig/conf.d; mkdir -p "$FC"
hk_fontconf "$HERE/../fontconfig/60-hyprk-sf.conf.in" "$HERE/../fonts/named" "${XDG_CACHE_HOME:-$HOME/.cache}/hyprk-fontconfig" > "$FC/60-hyprk-sf.conf"
echo "Set QT_QPA_PLATFORMTHEME=qt6ct (and QT_STYLE_OVERRIDE unset) for Qt apps. Fonts: SF Pro / SF Mono via $FC/60-hyprk-sf.conf (fallback Inter, Cantarell; themes/gtk/FALLBACKS.md)."
