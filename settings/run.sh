#!/usr/bin/env bash
# Launch hyprk System Settings. Prefers Quickshell (full backend), falls back
# to the Qt `qml` tool (visual only, state files via XHR).
HERE=$(cd "$(dirname "$0")" && pwd)
export QML_XHR_ALLOW_FILE_READ=1 QML_XHR_ALLOW_FILE_WRITE=1
[ -f /mnt/code/hypr-dev/env.sh ] && [ -z "${HYPRK_NO_DEVENV:-}" ] && . /mnt/code/hypr-dev/env.sh 2>/dev/null
if command -v quickshell >/dev/null 2>&1 && [ -z "${HYPRK_USE_QML:-}" ]; then
    exec quickshell -p "$HERE" "$@"
fi
QML=$(command -v qml || echo /usr/lib/qt6/bin/qml)
exec "$QML" "$HERE/main.qml" "$@"
