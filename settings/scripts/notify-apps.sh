#!/usr/bin/env bash
# Lists apps that send notifications: desktop files with X-GNOME-UsesNotifications=true
# (the freedesktop-world marker GNOME Settings uses). Output: "<id>\t<Name>\t<Icon>".
dirs="${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
IFS=: read -ra list <<< "$dirs"
for d in "${list[@]}"; do
    [ -d "$d/applications" ] || continue
    grep -ls '^X-GNOME-UsesNotifications=true' "$d"/applications/*.desktop 2>/dev/null | while read -r f; do
        grep -q '^NoDisplay=true' "$f" && continue
        name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
        icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
        printf '%s\t%s\t%s\n' "$(basename "$f")" "$name" "$icon"
    done
done
