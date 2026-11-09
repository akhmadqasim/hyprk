#!/usr/bin/env bash
# Build (if needed) and start the hyprk Finder. Extra args go to the app, e.g. ./run.sh ~/Documents --view list
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/build/build.ninja" ]] || cmake -S "$here" -B "$here/build" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo >/dev/null
cmake --build "$here/build" >/dev/null   # no-op when up to date
exec "$here/build/hyprk-finder" "$@"
