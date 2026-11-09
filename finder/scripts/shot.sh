#!/usr/bin/env bash
# Reference-comparable screenshots: builds the demo home (scripts/make-demo.py) in a temp dir
# and renders each view offscreen into reference/ours/finder-<view>.png.
# Usage: scripts/shot.sh [views...]   (default: icons list columns gallery)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$here/../reference/ours"
demo="$(mktemp -d)"
trap 'rm -rf "$demo"' EXIT
python3 -I "$here/scripts/make-demo.py" "$demo" >/dev/null 2>&1
[[ -f "$here/build/build.ninja" ]] || cmake -S "$here" -B "$here/build" -G Ninja >/dev/null
cmake --build "$here/build" >/dev/null
views=("$@")
[[ ${#views[@]} -gt 0 ]] || views=(icons list columns gallery)
for v in "${views[@]}"; do
    select=()
    [[ $v == icons ]] || select=(--select "Briefing.pdf")   # the reference icon shot has no selection
    HOME="$demo" XDG_CACHE_HOME="$demo/.cache" QT_QPA_PLATFORM=offscreen \
        "$here/build/hyprk-finder" "$demo/Documents" --view "$v" "${select[@]}" \
        --shot "$out/finder-$v.png" --delay 3000 2>/dev/null
    echo "$out/finder-$v.png"
done
