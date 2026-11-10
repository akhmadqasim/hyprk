#!/usr/bin/env bash
# Built-in clipboard history for Spotlight (used when cliphist is not installed).
# Items live in $XDG_STATE_HOME/hyprk/clipboard (or $HYPRK_CLIP_DIR) as <ms>_<sha1>.<txt|png|...>.
# Output lines (store, list): "<file>\t<mime>\t<preview>" (preview: first 300 chars, one line).
#
#   clipboard.sh watch <cap> <maxAgeMin>   run wl-paste --watch, store each new clipboard (stdout: new items)
#   clipboard.sh store <cap> <maxAgeMin>   store stdin (called by wl-paste --watch)
#   clipboard.sh list <maxAgeMin>          all items, newest first (prunes expired ones)
#   clipboard.sh copy <file>               put an item back on the clipboard
#   clipboard.sh clear                     delete the history
#
# Skipped: empty data, password-manager copies (wl-paste sets CLIPBOARD_STATE=sensitive),
# non-image binary data, items over 20 MB.
set -u
DIR=${HYPRK_CLIP_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/hyprk/clipboard}
MAX_BYTES=$((20 * 1024 * 1024))

emit() {   # file
    local f=$1 mime preview=""
    case "$f" in
        *.txt) mime=text/plain; preview=$(head -c 300 "$f" | tr '\t\n\r' '   ') ;;
        *) mime="image/${f##*.}" ;;
    esac
    printf '%s\t%s\t%s\n' "$f" "$mime" "$preview"
}

prune() {   # maxAgeMin cap
    [ "${1:-0}" -gt 0 ] && find "$DIR" -maxdepth 1 -type f -mmin +"$1" -delete 2>/dev/null
    if [ -n "${2:-}" ]; then
        ls -1 "$DIR" 2>/dev/null | sort -r | tail -n +"$(( $2 + 1 ))" | while read -r f; do rm -f "$DIR/$f"; done
    fi
    return 0
}

case "${1:-}" in
watch)
    mkdir -p "$DIR" && chmod 700 "$DIR"
    exec wl-paste --watch "$0" store "${2:-200}" "${3:-0}"
    ;;
store)
    case "${CLIPBOARD_STATE:-data}" in sensitive|clear|nil) cat >/dev/null; exit 0 ;; esac
    mkdir -p "$DIR"
    tmp=$(mktemp "$DIR/.in.XXXXXX") || exit 1
    head -c $((MAX_BYTES + 1)) >"$tmp"
    size=$(stat -c %s "$tmp")
    if [ "$size" -eq 0 ] || [ "$size" -gt "$MAX_BYTES" ]; then rm -f "$tmp"; exit 0; fi
    if command -v file >/dev/null; then mime=$(file -b --mime-type "$tmp")
    elif LC_ALL=C grep -qI . "$tmp"; then mime=text/plain
    else mime=application/octet-stream; fi
    case "$mime" in
        text/*|application/json|application/xml|inode/x-empty) ext=txt ;;
        image/png|image/jpeg|image/gif|image/webp|image/bmp) ext=${mime#image/} ;;
        *) rm -f "$tmp"; exit 0 ;;
    esac
    hash=$(sha1sum "$tmp" | cut -c1-16)
    rm -f "$DIR"/*_"$hash".* 2>/dev/null     # same content copied again moves to the top
    # millisecond names sort newest first; keep them increasing even within one ms
    now=$(date +%s%3N)
    last=$(ls -1 "$DIR" 2>/dev/null | sort -r | head -n 1); last=${last%%_*}
    [ -n "$last" ] && [ "$last" -ge "$now" ] 2>/dev/null && now=$((last + 1))
    f="$DIR/${now}_$hash.$ext"
    mv "$tmp" "$f" && chmod 600 "$f"
    prune "${3:-0}" "${2:-200}"
    emit "$f"
    ;;
list)
    prune "${2:-0}"
    ls -1 "$DIR" 2>/dev/null | sort -r | while read -r f; do emit "$DIR/$f"; done
    ;;
copy)
    f=${2:?file}
    case "$f" in *.txt) exec wl-copy --type text/plain <"$f" ;; *) exec wl-copy --type "image/${f##*.}" <"$f" ;; esac
    ;;
clear)
    rm -f "$DIR"/[0-9]*_* 2>/dev/null
    ;;
*) echo "usage: $0 watch|store|list|copy|clear" >&2; exit 2 ;;
esac
