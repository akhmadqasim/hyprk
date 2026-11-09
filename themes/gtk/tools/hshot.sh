#!/bin/bash
# usage: hshot.sh OUT.png light|dark [WxH] CMD...   runs a real app in the private headless Hyprland (tools/hypr-headless.sh) with the
# repo's gtk-4.0/gtk.css in a scratch XDG_CONFIG_HOME (+ GTK3_THEME=name to test a gtk-3.0 theme dir), grabs a grim screenshot.
D=$(cd "$(dirname "$0")/.." && pwd); source $D/tools/hypr-env.sh
OUT=$1; MODE=$2; SZ=${3:-1000x680}; shift 3
S=$(mktemp -d /tmp/claude-1000/hk/run.XXXX); C=$S/cfg; mkdir -p $C/gtk-4.0 $C/gtk-3.0 $C/glib-2.0/settings $S/data
cp $D/gtk-4.0/gtk.css $C/gtk-4.0/gtk.css
printf '[Settings]\ngtk-decoration-layout=close,minimize,maximize:\n%s\n' "${EXTRA_SETTINGS}" > $C/gtk-3.0/settings.ini; cp $C/gtk-3.0/settings.ini $C/gtk-4.0/settings.ini
[ -n "$GTK3_THEME" ] && { echo "gtk-theme-name=$GTK3_THEME"; [ $MODE = dark ] && echo gtk-application-prefer-dark-theme=1; } >> $C/gtk-3.0/settings.ini
{ echo "[org/gnome/desktop/wm/preferences]"; echo "button-layout='close,minimize,maximize:'"; echo "[org/gnome/desktop/interface]";
  echo "color-scheme='$([ $MODE = dark ] && echo prefer-dark || echo prefer-light)'"; echo "font-name='SF Pro Text 10'"; [ -n "$GTK3_THEME" ] && echo "gtk-theme='$GTK3_THEME'"; echo "monospace-font-name='SF Mono 10'"; } > $C/glib-2.0/settings/keyfile
cat > $S/fonts.conf <<EOT
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include><dir>$D/../fonts</dir><cachedir>/tmp/claude-1000/hk/fccache</cachedir></fontconfig>
EOT
export WAYLAND_DISPLAY=$HK_WL XDG_CONFIG_HOME=$C XDG_DATA_HOME=$S/data GSETTINGS_BACKEND=keyfile GTK_USE_PORTAL=0 FONTCONFIG_FILE=$S/fonts.conf XDG_CURRENT_DESKTOP=Hyprland GDK_BACKEND=wayland NO_AT_BRIDGE=1
unset XDG_SESSION_TYPE DISPLAY
mkdir -p $S/xdg; ln -s $D $S/xdg/themes; export XDG_DATA_DIRS="$S/xdg:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
setsid timeout ${LIFE:-30} dbus-run-session -- "$@" > $S/app.log 2>&1 &
APP=$!
sleep ${WAIT:-6}
W=${SZ%x*}; H=${SZ#*x}
hyprctl dispatch togglefloating >/dev/null 2>&1; hyprctl dispatch resizeactive exact $W $H >/dev/null 2>&1; hyprctl dispatch centerwindow >/dev/null 2>&1; sleep 1.5
${ACTION:+eval "$ACTION"}
grim -o "$(hyprctl monitors -j | python3 -c "import sys,json;print(json.load(sys.stdin)[0][\"name\"])")" "$OUT"
kill -- -$APP 2>/dev/null; sleep 1   # only our own process group (setsid), never pkill by name
grep -i -E "theme parser|gtk-warning.*css" $S/app.log | sort | uniq -c | head
rm -rf $S
