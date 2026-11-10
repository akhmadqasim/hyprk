#!/usr/bin/env bash
# Built-in clipboard history for Spotlight (used when cliphist is not installed).
# Items live in $XDG_STATE_HOME/hyprk/clipboard (or $HYPRK_CLIP_DIR) as <ms>_<sha1>.<txt|png|...>.
# Output lines (store, list): "<file>\t<mime>\t<preview>" (preview: first 300 chars, one line).
#
#   clipboard.sh watch <cap>          run wl-paste --watch, store each new clipboard (stdout: new items)
#   clipboard.sh store <cap>          store stdin (called by wl-paste --watch), keep the newest <cap>
#   clipboard.sh list <maxAgeMin>     all items, newest first; deletes items older than maxAgeMin (0 = keep)
#   clipboard.sh prune <maxAgeMin>    delete items older than maxAgeMin
#   clipboard.sh copy <file>          put an item back on the clipboard
#   clipboard.sh clear                delete the history
#
# Skipped: empty data, password-manager copies (wl-paste sets CLIPBOARD_STATE=sensitive),
# non-image binary data, items over 20 MB.
set -u
shopt -s nullglob
DIR=${HYPRK_CLIP_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/hyprk/clipboard}
MAX_BYTES=$((20 * 1024 * 1024))

mimeof() {   # file -> mime from the extension
    case "$1" in *.txt) echo text/plain ;; *) echo "image/${1##*.}" ;; esac
}
emit() {   # file (bash builtins only: list runs this for up to 200 items)
    local f=$1 p=""
    [[ $f == *.txt ]] && { IFS= read -r -d '' -n 300 p <"$f"; p=${p//[$'\t\n\r']/ }; }
    printf '%s\t%s\t%s\n' "$f" "$(mimeof "$f")" "$p"
}

case "${1:-}" in
watch)
    mkdir -p "$DIR" && chmod 700 "$DIR"
    exec wl-paste --watch "$0" store "${2:-200}"
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
        text/*|application/json|application/xml) ext=txt ;;
        image/png|image/jpeg|image/gif|image/webp|image/bmp) ext=${mime#image/} ;;
        *) rm -f "$tmp"; exit 0 ;;
    esac
    hash=$(sha1sum "$tmp"); hash=${hash:0:16}
    rm -f "$DIR"/*_"$hash".*                 # same content copied again moves to the top
    items=("$DIR"/[0-9]*_*)                  # oldest first (equal-length ms names)
    # millisecond names sort newest last; keep them increasing even within one ms
    now=$(date +%s%3N)
    if [ ${#items[@]} -gt 0 ]; then last=${items[-1]##*/}; last=${last%%_*}; [ "$last" -ge "$now" ] && now=$((last + 1)); fi
    f="$DIR/${now}_$hash.$ext"
    mv "$tmp" "$f" && chmod 600 "$f"
    # keep the newest <cap> (the new item is one more than the listing above)
    drop=$(( ${#items[@]} + 1 - ${2:-200} ))
    [ "$drop" -gt 0 ] && rm -f "${items[@]:0:drop}"
    emit "$f"
    ;;
list|prune)
    [ "${2:-0}" -gt 0 ] && find "$DIR" -maxdepth 1 -type f -name '[0-9]*_*' -mmin +"$2" -delete 2>/dev/null
    [ "$1" = prune ] && exit 0
    items=("$DIR"/[0-9]*_*)
    for (( i = ${#items[@]} - 1; i >= 0; i-- )); do emit "${items[i]}"; done
    ;;
copy)
    f=${2:?file}
    exec wl-copy --type "$(mimeof "$f")" <"$f"
    ;;
clear)
    rm -f "$DIR"/[0-9]*_*
    ;;
*) echo "usage: $0 watch|store|list|copy|clear" >&2; exit 2 ;;
esac
