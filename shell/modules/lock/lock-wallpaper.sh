#!/usr/bin/env bash
# Blurred lock screen backdrop, made once per wallpaper and cached.
# Usage: lock-wallpaper.sh <wallpaper> <width> <height> <scale> <sigma> <saturation>
#   width x height: the screen in logical px; scale: size of the cached copy (0.25 = a quarter);
#   sigma: gaussian blur in logical px; saturation: 1 = unchanged.
# Prints LOCK=<path>, or LOCK= when ImageMagick or the wallpaper is missing (the lock then shows the
# sharp wallpaper under the dim, or a plain fill).
set -u
SRC=${1:-}; W=${2:-1920}; H=${3:-1080}; SCALE=${4:-0.25}; SIGMA=${5:-24}; SAT=${6:-1}
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/hyprk
if [ -z "$SRC" ] || [ ! -f "$SRC" ] || ! command -v magick >/dev/null 2>&1; then echo "LOCK="; exit 0; fi
mkdir -p "$CACHE"
key=$(printf 'v2 %s %s %s %s %s %s %s' "$SRC" "$(stat -c %Y "$SRC" 2>/dev/null)" "$W" "$H" "$SCALE" "$SIGMA" "$SAT" | md5sum | cut -c1-12)
out=$CACHE/lock-$key.png
if [ ! -f "$out" ]; then
    read -r w h s m < <(awk -v W="$W" -v H="$H" -v k="$SCALE" -v g="$SIGMA" -v t="$SAT" \
        'BEGIN { printf "%d %d %.2f %d\n", W * k + 0.5, H * k + 0.5, g * k, t * 100 + 0.5 }')
    tmp=$(mktemp "$CACHE/lock-XXXXXX.png")
    # fill the screen like the desktop does, then shrink, blur and saturate; 16 bit so the smooth
    # upscale has no steps in dark gradients; written atomically
    if magick "$SRC" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -blur "0x$s" -modulate "100,$m" -depth 16 "$tmp" 2>/dev/null; then
        mv -f "$tmp" "$out"
    else
        rm -f "$tmp"; echo "LOCK="; exit 0
    fi
fi
echo "LOCK=$out"
