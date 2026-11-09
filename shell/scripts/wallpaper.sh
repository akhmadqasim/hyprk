#!/usr/bin/env bash
# Usage: wallpaper.sh <width> <height> <blur-sigma> [dark]
# Prints two lines: WALL=<path> and BLUR=<path or empty>.
# Picks a wallpaper from themes/wallpapers (assets agent), falls back to a
# generated gradient. The blurred copy is the QML glass material backdrop.
set -u
W=${1:-1920}; H=${2:-1080}; SIGMA=${3:-20}; MODE=${4:-light}
HERE=$(cd "$(dirname "$0")/../.." && pwd)
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/hyprk
mkdir -p "$CACHE"

src=""
if [ -n "${HYPRK_WALLPAPER:-}" ] && [ -f "$HYPRK_WALLPAPER" ]; then
    src=$HYPRK_WALLPAPER
else
    for d in "$HERE/themes/wallpapers" "$HERE/themes/wallpaper"; do
        [ -d "$d" ] || continue
        # prefer a file whose name matches the mode, then any image
        # macOS 26+ default (Tahoe) matching the mode, then any png/jpg
        src=$(find "$d" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -iname "*tahoe*$MODE*" | sort | head -n1)
        [ -n "$src" ] || src=$(find "$d" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -iname "*$MODE*" | sort | head -n1)
        [ -n "$src" ] || src=$(find "$d" -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort | head -n1)
        [ -n "$src" ] && break
    done
fi

if ! command -v magick >/dev/null 2>&1; then
    # no ImageMagick: the shell switches to the solid (reduce transparency) material
    echo "WALL=$src"; echo "BLUR="; exit 0
fi

if [ -z "$src" ]; then
    src="$CACHE/placeholder-$MODE-${W}x${H}.png"
    if [ ! -f "$src" ]; then
        if [ "$MODE" = dark ]; then a="#0b1a3a"; b="#1d4f8f"; c="#3a1f5c"; else a="#2f7fd8"; b="#7cc4f0"; c="#9a7be0"; fi
        magick -size "${W}x${H}" "gradient:$a-$b" \( -size "${W}x${H}" "radial-gradient:$c-none" \) -compose over -composite "$src" 2>/dev/null
    fi
fi

key=$(printf '%s %s %s %s' "$src" "$(stat -c %Y "$src" 2>/dev/null)" "${W}x${H}" "$SIGMA" | md5sum | cut -c1-12)
wall="$CACHE/wall-$key.png"
blur="$CACHE/blur-$key.png"
if [ ! -f "$wall" ]; then
    magick "$src" -resize "${W}x${H}^" -gravity center -extent "${W}x${H}" "$wall" 2>/dev/null || wall=$src
fi
if [ ! -f "$blur" ]; then
    # downscale, blur, upscale: cheap large-radius gaussian; slightly brighter and
    # desaturated so glass reads as near-neutral frost (macOS 27 Dock)
    magick "$wall" -resize 25% -blur "0x$(( SIGMA / 4 + 1 ))" -modulate 106,92 -resize "${W}x${H}!" "$blur" 2>/dev/null || blur=""
fi
echo "WALL=$wall"
echo "BLUR=$blur"
