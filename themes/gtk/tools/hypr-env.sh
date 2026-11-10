# source me: points GTK/Qt apps, grim and hyprctl at the private headless Hyprland started by hypr-headless.sh.
# Paths can be overridden: HK_DIR (scratch + state), HYPR_DEV (dev prefix with Hyprland/hyprlock).
export HYPR_DEV=${HYPR_DEV:-${HYPRK_DEV:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)/hypr-dev}}
export HK_DIR=${HK_DIR:-${XDG_RUNTIME_DIR:-/tmp}/hyprk}
mkdir -p "$HK_DIR"
[ -f "$HYPR_DEV/env.sh" ] && source "$HYPR_DEV/env.sh"
{ read -r HK_SIG < "$HK_DIR/sig"; } 2>/dev/null || :; export HK_SIG HYPRLAND_INSTANCE_SIGNATURE=$HK_SIG
{ read -r HK_WL < "$HK_DIR/wl"; } 2>/dev/null || :; export HK_WL
# fonts: one fontconfig for every rig script (SF Pro, SF Pro Rounded, SF Mono by their family names from themes/fonts/named),
# regenerated only when the template is newer
_hk_themes=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
source "$_hk_themes/lib.sh"
if [ ! -f "$HK_DIR/fonts.conf" ] || [ "$_hk_themes/fontconfig/60-hyprk-sf.conf.in" -nt "$HK_DIR/fonts.conf" ]; then
  hk_fontconf "$_hk_themes/fontconfig/60-hyprk-sf.conf.in" "$_hk_themes/fonts/named" "$HK_DIR/fccache" > "$HK_DIR/60-hyprk-sf.conf"
  printf '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd"><fontconfig><include ignore_missing="yes">/etc/fonts/fonts.conf</include><include>%s</include></fontconfig>\n' "$HK_DIR/60-hyprk-sf.conf" > "$HK_DIR/fonts.conf"
fi
export HK_FONTCONF=$HK_DIR/fonts.conf
unset _hk_themes
# hk_monitor: name of the headless output (where test windows and the lock screen appear)
hk_monitor() { local m; m=$(hyprctl monitors | awk '/^Monitor HEADLESS/{print $2; exit}'); [ -n "$m" ] && echo "$m" || { echo "no HEADLESS output, run hypr-headless.sh" >&2; return 1; }; }
# hk_wait_client SECONDS [SETTLE]: wait until the headless Hyprland has a window, then let it paint
hk_wait_client() { local i; for ((i = 0; i < ${1:-15} * 4; i++)); do hyprctl clients | grep -q '^Window' && break; sleep 0.25; done; sleep ${2:-1.5}; }
