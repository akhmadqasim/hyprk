#!/usr/bin/env bash
# Lists apps that send notifications: desktop files with X-GNOME-UsesNotifications=true
# (the marker GNOME Settings uses). Output: "<id>\t<Name>\t<Icon>".
# Data dirs are searched in XDG order and the first file with a given id wins, so a
# user override (e.g. NoDisplay=true in ~/.local/share/applications) hides the system one.
dirs="${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
IFS=: read -ra list <<< "$dirs"
declare -A seen
for d in "${list[@]}"; do
    for f in "$d"/applications/*.desktop; do
        [ -f "$f" ] || continue
        id=$(basename "$f")
        [ -n "${seen[$id]:-}" ] && continue
        seen[$id]=1
        grep -q '^X-GNOME-UsesNotifications=true' "$f" || continue
        grep -qE '^(NoDisplay|Hidden)=true' "$f" && continue
        name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
        icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
        printf '%s\t%s\t%s\n' "$id" "$name" "$icon"
    done
done
