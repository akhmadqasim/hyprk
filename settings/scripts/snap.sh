#!/usr/bin/env bash
# Render panes to reference/ours/settings-<pane>.png with the qml tool.
# Usage: snap.sh [pane...]   (default: all)
HERE=$(cd "$(dirname "$0")/.." && pwd)
OUT=$HERE/../reference/ours
mkdir -p "$OUT"
export QML_XHR_ALLOW_FILE_READ=1 QML_XHR_ALLOW_FILE_WRITE=1
panes=${*:-wifi bluetooth network energy general accessibility appearance controlcenter dock displays wallpaper notifications sound focus lockscreen privacy keyboard mouse trackpad}
for p in $panes; do
    timeout 15 /usr/lib/qt6/bin/qml "$HERE/main.qml" -- --pane="$p" --snapshot="$OUT/settings-$p.png" 2>&1 | grep -v "Cannot open: file:.*themes/icons" | sed "s/^/[$p] /"
done
