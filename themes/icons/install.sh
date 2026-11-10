#!/usr/bin/env bash
# Install the default hyprk app icon theme: WhiteSur-icon-theme (vinceliuice, GPL-3.0),
# a free macOS-like theme. It is downloaded (pinned tag + sha256), not kept in the repo,
# and installed into the hyprk data prefix, never into ~/.local/share/icons or /usr.
#
# Usage: themes/icons/install.sh [--prefix DIR] [--remove]
#   DIR defaults to ${XDG_DATA_HOME:-~/.local/share}/hyprk; themes land in DIR/icons/.
# config/hypr/start.sh puts DIR on XDG_DATA_DIRS and sets QS_ICON_THEME when the theme is there.
# Without it hyprk uses the system icon theme; icons that are not squircles get the macOS 26
# tile either way (ui/HyprK/AppIconTile.qml).
set -euo pipefail

TAG=2026-09-10
SHA256=406c9cd59705583f1754b0eaca96cc48bafda042b88ef143f16d8ae1820ecd95
URL=https://codeload.github.com/vinceliuice/WhiteSur-icon-theme/tar.gz/refs/tags/$TAG
PREFIX=${XDG_DATA_HOME:-$HOME/.local/share}/hyprk
REMOVE=0
while [ $# -gt 0 ]; do
    case $1 in
        --prefix) PREFIX=$2; shift 2 ;;
        --remove) REMOVE=1; shift ;;
        -h|--help) sed -n 2,11p "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
done
DEST=$PREFIX/icons

if [ $REMOVE = 1 ]; then
    rm -rf "$DEST"/WhiteSur "$DEST"/WhiteSur-light "$DEST"/WhiteSur-dark
    echo "removed WhiteSur from $DEST"
    exit 0
fi

for c in curl tar sha256sum; do command -v $c >/dev/null || { echo "needs $c" >&2; exit 1; }; done
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/ws.tar.gz" "$URL"
echo "$SHA256  $tmp/ws.tar.gz" | sha256sum -c --quiet - || { echo "checksum mismatch, not installing" >&2; exit 1; }
mkdir -p "$tmp/src" "$DEST"
tar -xzf "$tmp/ws.tar.gz" -C "$tmp/src" --strip-components=1
# its installer only copies into -d (blue variant = WhiteSur, WhiteSur-light, WhiteSur-dark)
(cd "$tmp/src" && bash ./install.sh -d "$DEST" >/dev/null)
cp "$tmp/src/COPYING" "$DEST/WhiteSur/COPYING"
echo "WhiteSur $TAG (GPL-3.0) installed in $DEST"
