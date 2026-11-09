#!/usr/bin/env bash
# Install (or remove) the "hyprk" entry in the GDM login screen. NOT run automatically.
#
#   dist/install-session.sh --dry-run               show what would happen, change nothing
#   dist/install-session.sh                         install /usr/share/wayland-sessions/hyprk.desktop (sudo)
#   dist/install-session.sh --uninstall [--dry-run] remove it again (sudo)
#
# Only this one file goes into /usr. GNOME keeps working: you pick "hyprk" or "Ubuntu" by the gear icon
# on the GDM login screen. The wrapper stays in the repo (dist/hyprk-session), so /mnt/code must be mounted at login.
set -eu
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WRAPPER=$HERE/hyprk-session
TARGET=/usr/share/wayland-sessions/hyprk.desktop
DRY=0 UNINSTALL=0
for a in "$@"; do
    case $a in
        --dry-run|-n) DRY=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) sed -n 2,9p "$0"; exit 0 ;;
        *) echo "install-session: unknown option $a" >&2; exit 2 ;;
    esac
done
[ "$(id -u)" -ne 0 ] || { echo "install-session: run as your normal user, it calls sudo itself" >&2; exit 2; }

run() { # print every action; execute unless dry run
    if [ $DRY = 1 ]; then echo "[dry-run] $*"; else echo "+ $*"; "$@"; fi
}

if [ $UNINSTALL = 1 ]; then
    if [ -e "$TARGET" ]; then run sudo rm -f "$TARGET"; else echo "nothing to remove: $TARGET does not exist"; fi
    echo "Done. Your private hyprk data (~/.local/share/hyprk-session, ~/.local/share/hyprk-try) is kept; delete it by hand if you want."
    exit 0
fi

[ -x "$WRAPPER" ] || { echo "install-session: $WRAPPER is missing or not executable" >&2; [ $DRY = 1 ] || exit 1; }
[ -d /usr/share/wayland-sessions ] || { echo "install-session: /usr/share/wayland-sessions does not exist (is this GDM?)" >&2; [ $DRY = 1 ] || exit 1; }
[ -x "${HYPRK_DEV:-/mnt/code/hypr-dev}/prefix/bin/Hyprland" ] || echo "warning: prefix Hyprland not found in ${HYPRK_DEV:-/mnt/code/hypr-dev}/prefix"

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
cat > "$TMP" <<DESK
[Desktop Entry]
Name=hyprk
Comment=Hyprland that looks like macOS (hyprk)
Exec=$WRAPPER
TryExec=$WRAPPER
Type=Application
DesktopNames=Hyprland
DESK

echo "Session file that will be written to $TARGET:"
sed 's/^/    /' "$TMP"
[ -e "$TARGET" ] && echo "(it already exists and will be replaced)"
run sudo install -m 644 -o root -g root "$TMP" "$TARGET"
echo
echo "Next: log out, click your name, then the gear icon (bottom right) and choose \"hyprk\"."
echo "Remove with: $0 --uninstall"
