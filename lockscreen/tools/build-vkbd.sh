#!/usr/bin/env bash
# Build vkbd (virtual keyboard for lock screen tests). Needs wayland-scanner, libwayland-client, libxkbcommon
# and the virtual-keyboard protocol XML from the Hyprland sources. Prints the binary path.
set -eu
cd "$(dirname "$0")"
XML=${VKBD_XML:-${HYPRK_DEV:-$(cd ../.. && pwd)/../hypr-dev}/src/Hyprland/protocols/virtual-keyboard-unstable-v1.xml}
OUT=${1:-${XDG_CACHE_HOME:-$HOME/.cache}/hyprk/vkbd}
T=$(mktemp -d); trap 'rm -r "$T"' EXIT
wayland-scanner client-header "$XML" "$T/vk.h"
wayland-scanner private-code "$XML" "$T/vk.c"
mkdir -p "$(dirname "$OUT")"
cc -O2 -I"$T" -o "$OUT" vkbd.c "$T/vk.c" $(pkg-config --cflags --libs wayland-client xkbcommon)
echo "$OUT"
