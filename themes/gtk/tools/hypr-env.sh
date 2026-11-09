# source me: points GTK/Qt apps, grim and hyprctl at the private headless Hyprland started by hypr-headless.sh.
# Paths can be overridden: HK_DIR (scratch + state), HYPR_DEV (dev prefix with Hyprland/hyprlock).
export HYPR_DEV=${HYPR_DEV:-/mnt/code/hypr-dev}
export HK_DIR=${HK_DIR:-${XDG_RUNTIME_DIR:-/tmp}/hyprk}
mkdir -p "$HK_DIR"
source "$HYPR_DEV/env.sh"
export HK_SIG=$(cat "$HK_DIR/sig" 2>/dev/null); export HYPRLAND_INSTANCE_SIGNATURE=$HK_SIG
export HK_WL=$(cat "$HK_DIR/wl" 2>/dev/null)
# fonts: one fontconfig (SF fonts from themes/fonts) for every rig script
export HK_FONTCONF=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../config/fontconfig" && pwd)/fonts.conf
# hk_monitor: name of the headless output (where test windows and the lock screen appear)
hk_monitor() { hyprctl monitors -j | python3 -c "import sys,json;m=[x['name'] for x in json.load(sys.stdin) if x['name'].startswith('HEADLESS')];print(m[0]) if m else sys.exit('no HEADLESS output, run hypr-headless.sh')"; }
# hk_wait_client SECONDS: wait until the headless Hyprland has at least one window, then let it paint
hk_wait_client() { for _ in $(seq 1 $(( ${1:-15} * 4 ))); do [ "$(hyprctl clients -j | python3 -c 'import sys,json;print(len(json.load(sys.stdin)))')" -gt 0 ] && break; sleep 0.25; done; sleep ${2:-1.5}; }
