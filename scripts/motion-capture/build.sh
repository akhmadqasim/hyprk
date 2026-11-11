#!/usr/bin/env bash
# Build mcap into ${1:-$MCAP_BUILD} (default: ./build next to this script; keep it out of git).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out=${1:-${MCAP_BUILD:-$here/build}}
mkdir -p "$out"
wayland-scanner client-header "$here/wlr-screencopy-unstable-v1.xml" "$out/wlr-screencopy-unstable-v1-client-protocol.h"
wayland-scanner private-code "$here/wlr-screencopy-unstable-v1.xml" "$out/wlr-screencopy-unstable-v1-protocol.c"
cc -O2 -Wall -I"$out" -o "$out/mcap" "$here/mcap.c" "$out/wlr-screencopy-unstable-v1-protocol.c" $(pkg-config --cflags --libs wayland-client)
echo "$out/mcap"
