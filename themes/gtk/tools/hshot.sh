#!/bin/bash
# usage: hshot.sh OUT.png light|dark CMD...
# Runs a real app in the private headless Hyprland (tools/hypr-headless.sh) with the repo's gtk-4.0/gtk.css in a scratch
# XDG_CONFIG_HOME, then grabs a grim screenshot of the headless output.
# env: GTK3_THEME=MacOS27 (test the gtk-3.0 theme dir), KEYS="CTRL:A,:F10" (shortcuts sent to the window, MODS:KEY),
#      ACTION="shell cmd" (run before the shot), CFG_OVERLAY=dir (extra files copied into the config dir), LIFE=seconds.
D=$(cd "$(dirname "$0")/.." && pwd); source "$D/tools/hypr-env.sh"
OUT=$1; MODE=$2; shift 2
DARK=$([ "$MODE" = dark ] && echo 1 || echo 0)
S=$(mktemp -d "$HK_DIR/run.XXXX"); C=$S/cfg
mkdir -p "$C/gtk-4.0" "$C/gtk-3.0" "$C/glib-2.0/settings" "$S/data/gtksourceview-5/styles" "$S/xdg"
cp "$D/gtk-4.0/gtk.css" "$C/gtk-4.0/gtk.css"
cp "$D"/gtksourceview/*.xml "$S/data/gtksourceview-5/styles/"
[ -n "$CFG_OVERLAY" ] && cp -r "$CFG_OVERLAY"/. "$C/"
printf '[Settings]\ngtk-decoration-layout=close,minimize,maximize:\n' > "$C/gtk-3.0/settings.ini"
cp "$C/gtk-3.0/settings.ini" "$C/gtk-4.0/settings.ini"
[ -n "$GTK3_THEME" ] && { echo "gtk-theme-name=$GTK3_THEME"; [ $DARK = 1 ] && echo gtk-application-prefer-dark-theme=1; } >> "$C/gtk-3.0/settings.ini"
# GTK reads gsettings before settings.ini on Wayland, so the keyfile backend carries the same keys
{
  echo "[org/gnome/desktop/wm/preferences]"; echo "button-layout='close,minimize,maximize:'"
  echo "[org/gnome/desktop/interface]"; echo "color-scheme='$([ $DARK = 1 ] && echo prefer-dark || echo prefer-light)'"
  echo "font-name='System Font 10'"; echo "monospace-font-name='Monospace 10'"
  [ -n "$GTK3_THEME" ] && echo "gtk-theme='$GTK3_THEME'"
  echo "[org/gnome/TextEditor]"; echo "style-scheme='macos27-$([ $DARK = 1 ] && echo dark || echo light)'"
  echo "restore-session=false"; echo "show-line-numbers=true"; echo "highlight-current-line=true"
} > "$C/glib-2.0/settings/keyfile"
ln -s "$D" "$S/xdg/themes"
export WAYLAND_DISPLAY=$HK_WL XDG_CONFIG_HOME=$C XDG_DATA_HOME=$S/data GSETTINGS_BACKEND=keyfile GTK_USE_PORTAL=0 \
       FONTCONFIG_FILE=$HK_FONTCONF XDG_CURRENT_DESKTOP=Hyprland GDK_BACKEND=wayland NO_AT_BRIDGE=1 \
       XDG_DATA_DIRS="$S/xdg:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
unset XDG_SESSION_TYPE DISPLAY
MON=$(hk_monitor) || exit 1
setsid timeout ${LIFE:-30} dbus-run-session -- "$@" > "$S/app.log" 2>&1 &
APP=$!
hk_wait_client 15 2
for k in ${KEYS//,/ }; do hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"${k%%:*}\", key = \"${k#*:}\" })" >/dev/null 2>&1; done
[ -n "$KEYS" ] && sleep 1.5
${ACTION:+eval "$ACTION"}
grim -o "$MON" "$OUT"
kill -- -$APP 2>/dev/null   # only our own process group (setsid), never pkill by name
grep -i -E "theme parser|gtk-warning.*css" "$S/app.log" | sort | uniq -c | head
rm -rf "$S"
