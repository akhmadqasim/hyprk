#!/bin/sh
# Print the files of the icons named in $@ (exact names, .svg/.svgz/.png) found in the icon
# dirs: $XDG_DATA_HOME/icons, ~/.icons, and icons/ + pixmaps/ of every $XDG_DATA_DIRS entry.
# Used by services/Distro.qml: Qt's theme lookup falls back from "a-b-c" to "a-b" to "a", which
# turns "distributor-logo-arch" into the theme's generic logo, so exact names are matched here.
# Paths with spaces are skipped.
set -f
[ $# -gt 0 ] || exit 0
dirs=""
add() { [ -d "$1" ] && case "$1" in *" "*) ;; *) dirs="$dirs $1" ;; esac; }
add "${XDG_DATA_HOME:-$HOME/.local/share}/icons"
add "$HOME/.icons"
oldifs=$IFS; IFS=:
for d in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do add "$d/icons"; add "$d/pixmaps"; done
IFS=$oldifs
[ -n "$dirs" ] || exit 0
expr=""
for n in "$@"; do expr="$expr -o -name $n.svg -o -name $n.svgz -o -name $n.png"; done
# shellcheck disable=SC2086
find $dirs -maxdepth 7 \( -type f -o -type l \) \( ${expr# -o } \) 2>/dev/null
