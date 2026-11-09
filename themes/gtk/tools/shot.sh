#!/bin/sh
# usage: shot.sh OUT_PREFIX [W H]  -> renders OUT_PREFIX-light.png / -dark.png with the current gtk-4.0/gtk.css (needs gtk4-broadwayd :5 running)
D=$(cd "$(dirname "$0")/.." && pwd); S=${TMPDIR:-/tmp}/hyprk-shot-$$; mkdir -p $S/cfg/gtk-4.0; cp $D/gtk-4.0/gtk.css $S/cfg/gtk-4.0/
cat > $S/fonts.conf <<EOT
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include><dir>$D/../fonts</dir><cachedir>$S/fccache</cachedir></fontconfig>
EOT
for s in light dark; do
 GDK_BACKEND=broadway BROADWAY_DISPLAY=:5 XDG_CONFIG_HOME=$S/cfg FONTCONFIG_FILE=$S/fonts.conf python3 $D/tools/shot4.py "$1-$s.png" $s ${2:-1000} ${3:-760} 2>&1 | grep -i -E "warn|error|parser" | sort | uniq -c
done
rm -rf $S
