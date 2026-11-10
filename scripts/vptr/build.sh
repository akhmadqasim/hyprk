#!/usr/bin/env bash
# Build vptr (needs wayland-scanner, libwayland-client and the wlr-virtual-pointer protocol XML).
set -eu
cd "$(dirname "$0")"
XML=${VPTR_XML:-${HYPRK_DEV:-$(cd ../.. && pwd)/../hypr-dev}/src/Hyprland/protocols/wlr-virtual-pointer-unstable-v1.xml}
OUT=${1:-${XDG_CACHE_HOME:-$HOME/.cache}/hyprk/vptr}
T=$(mktemp -d); trap 'rm -r "$T"' EXIT
wayland-scanner client-header "$XML" "$T/vp.h"
wayland-scanner private-code "$XML" "$T/vp.c"
mkdir -p "$(dirname "$OUT")"
cc -O2 -I"$T" -o "$OUT" main.c "$T/vp.c" -lwayland-client
echo "$OUT"
