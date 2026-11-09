#!/usr/bin/env bash
# Usage: thumbs.sh <src> <thumb> [<src> <thumb>...]
# Writes missing freedesktop "large" thumbnails (256px) so wallpaper grids load fast.
command -v magick >/dev/null || exit 3
while [ $# -ge 2 ]; do
    src=$1 thumb=$2; shift 2
    [ -f "$thumb" ] && continue
    mkdir -p "$(dirname "$thumb")"
    magick "$src[0]" -thumbnail 256x256 "$thumb.tmp.png" 2>/dev/null && mv "$thumb.tmp.png" "$thumb"
done
