#!/usr/bin/env bash
# Start Hyprland with the hyprk config. Env that must exist before Hyprland
# starts (hyprcursor reads XDG_DATA_DIRS once at load) is set here.
HYPRK_ROOT=${HYPRK_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
export HYPRK_ROOT
export XDG_DATA_DIRS="$HYPRK_ROOT/config:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"   # config/icons/hyprk-cursors
export XCURSOR_PATH="$HYPRK_ROOT/themes/cursors/theme:${XCURSOR_PATH:-/usr/share/icons}"
unset HYPRK_GLASS        # decided by hyprland.lua after loading the glass plugin
export XCURSOR_THEME=hyprk-cursors HYPRCURSOR_THEME=hyprk-cursors XCURSOR_SIZE=24 HYPRCURSOR_SIZE=24
[ -f /mnt/code/hypr-dev/env.sh ] && source /mnt/code/hypr-dev/env.sh
exec env -u HYPRLAND_INSTANCE_SIGNATURE Hyprland --config "${HYPRK_CONFIG:-$HYPRK_ROOT/config/hypr/hyprland.lua}" "$@"
