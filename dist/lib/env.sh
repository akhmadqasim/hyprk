#!/usr/bin/env bash
# Shared environment for dist/try-nested.sh and dist/hyprk-session. Source it, do not run it.
#
#   hyprk_env_setup DIR MODE THEME
#     DIR    private home of the hyprk session (config, data, state, fontconfig cache)
#     MODE   private = fresh empty config dir (nested try, nothing of your real config is visible)
#            farm    = fresh config dir, but every real ~/.config entry (except theme ones) is a symlink,
#                      so apps keep their settings (login session)
#     THEME  light | dark
#
# It only writes inside DIR. Your real ~/.config, ~/.local/share, GNOME settings, /etc and /usr stay untouched.
# Real dirs are only read (symlinked): applications, icons, flatpak, and in farm mode most other entries.

HYPRK_DIST=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HYPRK_ROOT=${HYPRK_ROOT:-$(cd "$HYPRK_DIST/.." && pwd)}
HYPRK_DEV=${HYPRK_DEV:-$HYPRK_ROOT/../hypr-dev}   # optional source-built prefix; distro packages work without it

# entries that must NOT leak from the real dirs into the hyprk dirs (we write our own theme there)
_HYPRK_CFG_SKIP=" gtk-3.0 gtk-4.0 glib-2.0 qt6ct Kvantum fontconfig dconf ghostty foot "
_HYPRK_DATA_SKIP=" themes gtksourceview-5 fonts hyprk-try hyprk-session "

_hyprk_farm() { # _hyprk_farm SRC DST SKIPLIST  (symlink every entry of SRC into DST, never overwrite)
    local src=$1 dst=$2 skip=$3 e n
    [ -d "$src" ] || return 0
    for e in "$src"/* "$src"/.[!.]*; do
        [ -e "$e" ] || [ -L "$e" ] || continue
        n=${e##*/}
        case "$skip" in *" $n "*) continue ;; esac
        [ -e "$dst/$n" ] || [ -L "$dst/$n" ] || ln -s "$e" "$dst/$n"
    done
}

# --- write safety: everything hyprk writes goes to REAL files inside DIR, never through a symlink into your real dirs ---
_hyprk_own_dir() {   # _hyprk_own_dir PATH...: PATH becomes a real directory (a stale symlink is removed, its target untouched)
    local d
    for d in "$@"; do [ -L "$d" ] && rm -f "$d"; mkdir -p "$d"; done
}
_hyprk_write() {     # _hyprk_write FILE < content: temp file next to FILE + mv, so a symlink at FILE is replaced, not followed
    local f=$1 t
    [ -L "$f" ] && rm -f "$f"
    t=$(mktemp "$f.XXXXXX") || return 1
    if cat > "$t" && chmod 644 "$t" && mv -f "$t" "$f"; then return 0; fi
    rm -f "$t"; return 1
}
_hyprk_sweep() {     # _hyprk_sweep DIR...: delete symlinks (the links only) at and below the dirs hyprk writes to
    local d
    for d in "$@"; do [ -L "$d" ] && rm -f "$d"; [ -d "$d" ] && find "$d" -type l -delete; done
    return 0
}
_hyprk_verify() {    # _hyprk_verify HOME DIR...: no symlink below the dirs, and every dir really lives inside HOME
    local home d real
    home=$(realpath "$1"); shift
    for d in "$@"; do
        [ -e "$d" ] || continue
        real=$(realpath "$d")
        case $real in "$home"/*) ;; *) echo "hyprk: refusing to continue, $d resolves to $real (outside $home)" >&2; return 1 ;; esac
        if [ -n "$(find "$d" -type l -print -quit)" ]; then echo "hyprk: refusing to continue, symlink inside $d" >&2; return 1; fi
    done
}

hyprk_env_setup() {
    local dir=$1 mode=${2:-private} theme=${3:-light}
    local real_cfg=${XDG_CONFIG_HOME:-$HOME/.config} real_data=${XDG_DATA_HOME:-$HOME/.local/share}
    # remember the real dirs (only if not already remembered by an outer hyprk shell)
    export HYPRK_REAL_CONFIG=${HYPRK_REAL_CONFIG:-$real_cfg} HYPRK_REAL_DATA=${HYPRK_REAL_DATA:-$real_data}
    real_cfg=$HYPRK_REAL_CONFIG; real_data=$HYPRK_REAL_DATA

    # dev prefix: Hyprland 0.57.2, Quickshell, hyprlock (PATH, LD_LIBRARY_PATH, XDG_DATA_DIRS ...)
    # shellcheck disable=SC1091
    [ -f "$HYPRK_DEV/env.sh" ] && . "$HYPRK_DEV/env.sh"

    mkdir -p "$dir"/{config,data,state,cache}; chmod 700 "$dir"
    local cfg=$dir/config data=$dir/data
    export XDG_CONFIG_HOME=$cfg XDG_DATA_HOME=$data XDG_STATE_HOME=$dir/state

    # dirs hyprk writes into (installers and generated files); they must be real dirs inside $dir
    local owned=("$cfg/gtk-3.0" "$cfg/gtk-4.0" "$cfg/glib-2.0" "$cfg/qt6ct" "$cfg/Kvantum" "$cfg/fontconfig" "$cfg/ghostty" "$cfg/foot"
                 "$data/themes" "$data/gtksourceview-5")
    _hyprk_sweep "${owned[@]}"          # old --share-config runs may have left links here
    _hyprk_own_dir "${owned[@]}"
    local n
    if [ "$mode" = farm ]; then
        # login session: apps keep their settings. Symlinks are made only for entries hyprk does not own.
        _hyprk_farm "$real_cfg" "$cfg" "$_HYPRK_CFG_SKIP"
        _hyprk_farm "$real_data" "$data" "$_HYPRK_DATA_SKIP"
    else
        # nested try: NO symlinks into your real dirs. Remove links left by an earlier --share-config run,
        # and let apps READ your real data dir (applications, icons, flatpak exports) through XDG_DATA_DIRS instead.
        find "$cfg" "$data" -maxdepth 1 -type l -delete
        export XDG_DATA_DIRS="$XDG_DATA_DIRS:$real_data"
        [ -d "$real_data/flatpak/exports/share" ] && XDG_DATA_DIRS="$XDG_DATA_DIRS:$real_data/flatpak/exports/share"
        [ -d "$real_data/flatpak" ] && export FLATPAK_USER_DIR=$real_data/flatpak   # flatpak apps still find their install
    fi
    # a real ~/.local/share/icons would hide nothing: hyprk cursors come through XCURSOR_PATH (start.sh)

    # --- GTK 3/4: theme dirs + gtk.css into the private dirs (install.sh honours XDG_*_HOME) ---
    local gtkname=MacOS27 dark=false
    [ "$theme" = dark ] && { gtkname=MacOS27-Dark; dark=true; }
    sh "$HYPRK_ROOT/themes/gtk/install.sh" --keyfile $([ "$theme" = dark ] && echo --dark) >/dev/null
    # GTK on Wayland reads button-layout / colour scheme from GSettings first; the private session has no dconf,
    # so use a keyfile (traffic lights on the left, theme, fonts) and keep libadwaita off the host portal
    # (GTK_USE_PORTAL=0 is not enough on GTK 4: GDK still asks the host portal for button-layout; GDK_DEBUG=no-portals stops that)
    export GSETTINGS_BACKEND=keyfile ADW_DISABLE_PORTAL=1 GTK_USE_PORTAL=0 GDK_DEBUG="no-portals${GDK_DEBUG:+,$GDK_DEBUG}"
    for n in gtk-3.0 gtk-4.0; do
        { grep -v '^gtk-application-prefer-dark-theme=\|^\[Settings\]' "$HYPRK_ROOT/themes/gtk/config/settings.ini"
          echo "gtk-theme-name=$gtkname"
          echo "gtk-cursor-theme-name=hyprk-cursors"
          echo "gtk-application-prefer-dark-theme=$dark"
        } | sed '1i [Settings]' | _hyprk_write "$cfg/$n/settings.ini"
    done
    export GTK_THEME=$gtkname

    # --- Qt: qt6ct platform theme, only when the plugin exists (apt install qt6ct) ---
    HYPRK_QT_NOTE=
    local p kv=
    # Debian/Ubuntu: /usr/lib/<triplet>/qt6, Arch: /usr/lib/qt6, Fedora/openSUSE: /usr/lib64/qt6
    p=$(ls /usr/lib/*/qt6/plugins/platformthemes/libqt6ct.so /usr/lib/qt6/plugins/platformthemes/libqt6ct.so \
           /usr/lib64/qt6/plugins/platformthemes/libqt6ct.so 2>/dev/null | head -n1)
    if [ -n "$p" ]; then
        ls /usr/lib/*/qt6/plugins/styles/libkvantum.so /usr/lib/qt6/plugins/styles/libkvantum.so \
           /usr/lib64/qt6/plugins/styles/libkvantum.so >/dev/null 2>&1 && kv=--kvantum
        XDG_CACHE_HOME="$dir/cache" sh "$HYPRK_ROOT/themes/qt/install.sh" $kv --fonts --force $([ "$theme" = dark ] && echo --dark) >/dev/null
        export QT_QPA_PLATFORMTHEME=qt6ct
        unset QT_STYLE_OVERRIDE
    else
        HYPRK_QT_NOTE="qt6ct is not installed: Qt apps keep their default look (install qt6ct and Kvantum from your distro, see packaging/DEPENDENCIES.md)"
    fi
    export QT_QPA_PLATFORM=wayland

    # --- Ghostty: server-side decoration, so the plugin draws the traffic lights on the left ---
    {
        # farm mode: keep the user's own Ghostty settings, then override the window theme below
        [ "$mode" = farm ] && [ -f "$real_cfg/ghostty/config" ] && echo "config-file = ?$real_cfg/ghostty/config"
        echo "window-theme = auto"      # dark terminal -> dark title bar, like macOS Terminal
        echo "window-decoration = server"   # asks for SSD; the liquidglass plugin draws the macOS title bar
        echo "gtk-titlebar = true"
        echo "window-padding-x = 10"       # macOS Terminal-like inset (text was ~2px from the edge)
        echo "window-padding-y = 6"
        echo "window-padding-balance = true"
        echo "gtk-single-instance = false"   # else a Ghostty already running on the host would take the new window
    } | _hyprk_write "$cfg/ghostty/config"

    # --- foot: same padding as Ghostty (farm mode keeps the user's own foot.ini via include) ---
    {
        [ "$mode" = farm ] && [ -f "$real_cfg/foot/foot.ini" ] && echo "include=$real_cfg/foot/foot.ini"
        echo "[main]"
        echo "pad=10x6 center"
    } | _hyprk_write "$cfg/foot/foot.ini"

    # --- fonts: system fontconfig + SF fonts + your own ~/.local/share/fonts, private cache ---
    mkdir -p "$dir/cache/fontconfig"
    _hyprk_write "$cfg/fontconfig/fonts.conf" <<FC
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<!-- generated by hyprk dist: nothing is installed system-wide -->
<fontconfig>
  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
  <dir>$HYPRK_ROOT/themes/fonts/named</dir>
  <dir>$real_data/fonts</dir>
  <dir>$HOME/.fonts</dir>
  <cachedir>$dir/cache/fontconfig</cachedir>
  <include ignore_missing="yes">$HYPRK_ROOT/config/fontconfig/macos-text.conf</include>
  <match target="pattern">
    <test qual="any" name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend" binding="same"><string>SF Pro</string><string>Inter</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>system-ui</string></test>
    <edit name="family" mode="prepend" binding="same"><string>SF Pro</string><string>Inter</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>serif</string></test>
    <edit name="family" mode="prepend" binding="same"><string>New York</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend" binding="same"><string>SF Mono</string></edit>
  </match>
</fontconfig>
FC
    export FONTCONFIG_FILE=$cfg/fontconfig/fonts.conf

    # --- cursors (same values as config/hypr/start.sh, which also exports them for Hyprland itself) ---
    export XCURSOR_PATH="$HYPRK_ROOT/themes/cursors/theme:${XCURSOR_PATH:-/usr/share/icons}"
    export XCURSOR_THEME=hyprk-cursors HYPRCURSOR_THEME=hyprk-cursors XCURSOR_SIZE=24 HYPRCURSOR_SIZE=24

    # last check: nothing hyprk wrote can lead into your real dirs
    _hyprk_verify "$dir" "${owned[@]}" "$dir/state" "$dir/cache" || return 1

    export HYPRK_ROOT HYPRK_DEV
    export HYPRK_CONFIG=$HYPRK_DIST/hyprk-dist.lua     # config/hypr/hyprland.lua + monitor override
}
