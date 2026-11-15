#!/bin/sh
# Usage: storage.sh <category> [list]   prints the bytes that category takes on the system volume, or "-" when this
# computer has no such thing (General > Storage). With `list`: a "bytes<TAB>path" line per folder counted (the ⓘ sheet). Read-only: du at the lowest CPU and IO priority, on the system volume only
# (-x, and a folder on another volume is left out, since the bar is the system volume's).
root=$(stat -c %d / 2>/dev/null)
xdg() { d=$(xdg-user-dir "$1" 2>/dev/null); [ -n "$d" ] && [ "$d" != "$HOME" ] && [ "$d" != "$HOME/" ] && echo "$d" || echo "$HOME/$2"; }
mode=${2:-}
case ${1:-} in
    applications) set -- /opt /var/lib/snapd/snaps /var/lib/flatpak "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak" "$HOME/Applications" ;;
    trash) set -- "${XDG_DATA_HOME:-$HOME/.local/share}/Trash" ;;
    documents) set -- "$(xdg DOCUMENTS Documents)" "$(xdg DESKTOP Desktop)" "$(xdg DOWNLOAD Downloads)" ;;
    music) set -- "$(xdg MUSIC Music)" ;;
    photos) set -- "$(xdg PICTURES Pictures)" ;;
    system) set -- /usr /boot /etc ;;
    otherusers)
        me=$(cd "$HOME" 2>/dev/null && pwd -P); set --
        for d in /home/*/; do
            d=${d%/}; [ -d "$d" ] && [ "$(cd "$d" 2>/dev/null && pwd -P)" != "$me" ] && [ "$d" != "/home/lost+found" ] && set -- "$@" "$d"
        done
        [ $# -gt 0 ] || { echo -; exit 0; } ;;
    *) echo "usage: storage.sh <category>" >&2; exit 2 ;;
esac
low=; command -v nice >/dev/null 2>&1 && low="nice -n 19"
command -v ionice >/dev/null 2>&1 && low="$low ionice -c 3"
total=0
for p in "$@"; do
    [ -e "$p" ] && [ "$(stat -c %d "$p" 2>/dev/null)" = "$root" ] || continue
    n=$($low du -sxB1 -- "$p" 2>/dev/null | cut -f1)
    total=$((total + ${n:-0}))
    [ "$mode" = list ] && printf '%s\t%s\n' "${n:-0}" "$p"
done
[ "$mode" = list ] || echo "$total"
