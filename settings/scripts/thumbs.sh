#!/usr/bin/env bash
# Usage: thumbs.sh <src> <thumb> <uri> [<src> <thumb> <uri>...]
# Writes freedesktop "large" thumbnails (256px) with Thumb::URI and Thumb::MTime,
# and remakes them when the source is newer, so wallpaper grids load fast.
command -v magick >/dev/null || exit 3
while [ $# -ge 3 ]; do
    src=$1 thumb=$2 uri=$3; shift 3
    [ -f "$thumb" ] && [ "$thumb" -nt "$src" ] && continue
    mkdir -p "$(dirname "$thumb")"
    tmp=$(mktemp "$thumb.XXXXXX") || continue
    magick "$src[0]" -thumbnail 256x256 -set "Thumb::URI" "$uri" -set "Thumb::MTime" "$(stat -c %Y "$src")" "png:$tmp" 2>/dev/null \
        && mv "$tmp" "$thumb" || rm -f "$tmp"
done
