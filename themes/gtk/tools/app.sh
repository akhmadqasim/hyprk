#!/bin/sh
# usage: app.sh OUT.png light|dark CMD... ; runs a real GTK4 app on broadway :5 inside a private dbus session with themed XDG_CONFIG_HOME, screenshots with headless chrome.
# needs: gtk4-broadwayd :5 running (HTTP on 8085), playwright's chrome-headless-shell.
D=$(cd "$(dirname "$0")/.." && pwd); OUT=$1; MODE=$2; shift 2
S=${TMPDIR:-/tmp}/hyprk-app-$$; mkdir -p $S/cfg/gtk-4.0 $S/cfg/gtk-3.0 $S/data $S/cache
cp $D/gtk-4.0/gtk.css $S/cfg/gtk-4.0/gtk.css
printf '[Settings]\ngtk-decoration-layout=close,minimize,maximize:\ngtk-application-prefer-dark-theme=%s\n' $([ $MODE = dark ] && echo 1 || echo 0) > $S/cfg/gtk-4.0/settings.ini
cp $S/cfg/gtk-4.0/settings.ini $S/cfg/gtk-3.0/settings.ini
[ -n "$GTK3_THEME_DIR" ] && echo "gtk-theme-name=$GTK3_THEME_NAME" >> $S/cfg/gtk-3.0/settings.ini
cat > $S/fonts.conf <<EOT
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include><dir>$D/../fonts</dir><cachedir>$S/fccache</cachedir></fontconfig>
EOT
export GDK_BACKEND=broadway BROADWAY_DISPLAY=:5 XDG_CONFIG_HOME=$S/cfg XDG_DATA_HOME=$S/data XDG_CACHE_HOME=$S/cache FONTCONFIG_FILE=$S/fonts.conf GSETTINGS_BACKEND=memory XDG_SESSION_TYPE=x11 GTK_USE_PORTAL=0 NO_AT_BRIDGE=1
[ $MODE = dark ] && export ADW_DEBUG_COLOR_SCHEME=prefer-dark
[ -n "$GTK3_THEME_DIR" ] && export XDG_DATA_DIRS="$GTK3_THEME_DIR:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
dbus-run-session -- "$@" >$S/app.log 2>&1 &
PID=$!
sleep ${WAIT:-6}
CH=$(ls -d $HOME/.cache/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-linux64/chrome-headless-shell | head -1)
$CH --no-sandbox --screenshot="$OUT" --window-size=${SIZE:-1280,860} --virtual-time-budget=4000 http://127.0.0.1:8085/ >/dev/null 2>&1
pkill -P $PID 2>/dev/null; kill $PID 2>/dev/null; sleep 0.5; pkill -f "dbus-run-session.*$S" 2>/dev/null
grep -i -E "theme parser|critical" $S/app.log | sort | uniq -c | head
rm -rf $S
