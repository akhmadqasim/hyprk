#!/usr/bin/env bash
# Usage: wallpaper.sh <width> <height> <blur-sigma> [dark] [pixel-width pixel-height]
# Prints three lines: WALL=<path> (at the pixel size: the desktop shows it 1:1 on the output's pixels),
# BLUR=<path or empty> (at the logical size) and LUMA=<menu bar strip luminance>, after SRC=<picture it was cut from>.
# HYPRK_WALL_ONLY=1: only SRC and WALL (another screen's cut at its own pixel size, services/Wallpaper.qml).
# Picks a wallpaper from themes/wallpapers (assets agent), falls back to a
# generated gradient. The blurred copy is the QML glass material backdrop.
set -u
W=${1:-1920}; H=${2:-1080}; SIGMA=${3:-20}; MODE=${4:-light}; PW=${5:-$W}; PH=${6:-$H}
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

# A picture with an embedded colour profile (Apple's wallpapers are Display P3) is converted to sRGB: Qt Quick and
# Hyprland show a file's numbers as sRGB, so the P3 numbers came out less saturated than on the Mac (TahoeLight at
# 2000,800 px of a 2560x1664 cut: file and screen 84,139,212, converted 63,141,218; COLOUR-P3-AUDIT.md 3.6). A picture
# without a profile only gets the sRGB tag. assets/sRGB.icc is LittleCMS's built-in sRGB profile.
ICC="$HERE/shell/assets/sRGB.icc"
[ -f "$ICC" ] && conv=(-profile "$ICC") || conv=()
key=$(printf '%s %s %s %s %s' "$src" "$(stat -c %Y "$src" 2>/dev/null)" "${W}x${H}" "$SIGMA" "${PW}x${PH}" "srgb${#conv[@]}" | md5sum | cut -c1-12)
wall="$CACHE/wall-$key.png"
blur="$CACHE/blur-$key.png"
if [ ! -f "$wall" ]; then
    # written under a temporary name and moved: Wallpaper.qml's prefetch of the other appearance may cut the same file
    t="$CACHE/tmp-$$-wall-$key.png"
    if magick "$src" "${conv[@]}" -resize "${PW}x${PH}^" -gravity center -extent "${PW}x${PH}" "$t" 2>/dev/null; then mv "$t" "$wall"; else rm -f "$t"; wall=$src; fi
fi
echo "SRC=$src"
if [ "${HYPRK_WALL_ONLY:-0}" = 1 ]; then echo "WALL=$wall"; exit 0; fi   # another screen's cut: no blur, no luma
if [ ! -f "$blur" ]; then
    # downscale, blur, upscale: cheap large-radius gaussian; slightly brighter and
    # desaturated so glass reads as near-neutral frost (macOS 27 Dock)
    # (shaders/menupill.frag undoes this -modulate: keep the two in step)
    # from the logical size, so the blur is the same at any output scale
    t="$CACHE/tmp-$$-blur-$key.png"
    if magick "$wall" -resize "${W}x${H}!" -resize 25% -blur "0x$(( SIGMA / 4 + 1 ))" -modulate 106,92 -resize "${W}x${H}!" "$t" 2>/dev/null; then mv "$t" "$blur"; else rm -f "$t"; blur=""; fi
fi
# mean luminance (0..1) of the menu bar strip, so the shell can pick white or dark menu bar text; kept next to the cut
# (decoding the 2560 x 1664 cut for it took most of a cached run: the appearance switch waits for this script)
lumaf="$CACHE/luma-$key.txt"
luma=$(cat "$lumaf" 2>/dev/null)
if [ -z "$luma" ]; then
    luma=$(magick "$wall" -crop "${PW}x$(( PH / 30 + 1 ))+0+0" -colorspace Gray -resize 1x1\! -format "%[fx:mean]" info: 2>/dev/null)
    if [ -n "$luma" ]; then printf '%s\n' "$luma" > "$lumaf.$$" && mv "$lumaf.$$" "$lumaf"; else luma=0.3; fi
fi
echo "WALL=$wall"
echo "BLUR=$blur"
echo "LUMA=$luma"
