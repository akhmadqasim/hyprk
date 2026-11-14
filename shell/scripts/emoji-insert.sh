#!/usr/bin/env bash
# Emoji & Symbols picker (shell/modules/EmojiPicker.qml): put the picked text on the clipboard so the shell can paste
# it into the focused app with its paste key (hl.dsp.send_shortcut), then put the user's clipboard back.
# hyprk has no virtual-keyboard tool (no wtype), so typing the text is not possible; pasting is.
#
#   emoji-insert.sh copy <text>   save the current clipboard when it is text and not secret, then copy <text>
#   emoji-insert.sh restore       copy the saved text back (nothing saved: the clipboard keeps <text>)
#
# Not saved, so not restored: images and other non-text copies, and copies a password manager marks secret
# (the same marks as clipboard.sh). Needs wl-copy / wl-paste (wl-clipboard); exits 2 without them.
set -u
SAVE=${XDG_RUNTIME_DIR:-/tmp}/hyprk-emoji-clipboard-${WAYLAND_DISPLAY:-wayland}
command -v wl-copy >/dev/null && command -v wl-paste >/dev/null || exit 2

case "${1:-}" in
copy)
    rm -f "$SAVE"
    nl=$'\n'
    types=$(timeout 1 wl-paste --list-types 2>/dev/null) || types=""
    case "$nl$types$nl" in
        *"${nl}org.nspasteboard.ConcealedType$nl"*|*"${nl}org.nspasteboard.TransientType$nl"*|*"${nl}x-kde-passwordManagerHint$nl"*) ;;
        *"${nl}text/plain;charset=utf-8$nl"*|*"${nl}text/plain$nl"*|*"${nl}UTF8_STRING$nl"*)
            (umask 077; timeout 1 wl-paste --no-newline --type text/plain >"$SAVE" 2>/dev/null) || rm -f "$SAVE" ;;
    esac
    # wl-copy stays in the background to serve the paste: its output goes nowhere, so the caller sees this script end
    printf '%s' "${2:-}" | wl-copy --type 'text/plain;charset=utf-8' >/dev/null 2>&1
    ;;
restore)
    [ -f "$SAVE" ] || exit 0
    wl-copy --type 'text/plain;charset=utf-8' <"$SAVE" >/dev/null 2>&1
    rm -f "$SAVE"
    ;;
*)
    echo "usage: $0 copy <text> | restore" >&2
    exit 1
    ;;
esac
