#!/usr/bin/env bash
# hyprk installer for any Linux distro. DRY RUN BY DEFAULT: it prints every command and changes nothing.
#
#   packaging/install.sh                 show the plan for this machine (dry run)
#   packaging/install.sh --yes           do it
#   packaging/install.sh --uninstall [--yes]
#
# Options
#   --yes, -y            execute (default: dry run, print only)
#   --prefix DIR         install root (default ${XDG_DATA_HOME:-~/.local/share}/hyprk), becomes HYPRK_ROOT
#   --from-source MODE   auto (default) | yes | no: build Hyprland, Quickshell and hyprlock from source into
#                        PREFIX/dev/prefix. auto = only when the distro package is missing or too old.
#   --assets DIR         copy more of your own extracted assets (typically the rest of the wallpapers) from DIR,
#                        laid out like the repo (DIR/themes/fonts, DIR/sounds/oga ...). Never downloaded, never shipped.
#   --keep-src           keep PREFIX/dev/src after a source build (default: each source tree is deleted as soon as
#                        it is installed; the Hyprland and Quickshell build trees are about 3 GB each, and nothing
#                        reads them afterwards: the plugin builds against PREFIX/dev/prefix)
#   --no-deps            do not install distro packages (print them only)
#   --no-session         do not install /usr/share/wayland-sessions/hyprk.desktop (the only step that needs sudo
#                        besides the package manager)
#   --print-deps         print the distro package list and exit
#   -h, --help
#
# Env: HYPRK_OS_RELEASE=FILE  read this instead of /etc/os-release (tests)
#      HYPRK_SRC=DIR          repo to install from (default: the checkout this script lives in)
#      J=N                    build parallelism (default: nproc)
#
# Nothing is written outside PREFIX except: distro packages (sudo, your package manager) and the session file (sudo).
set -euo pipefail

HYPRLAND_MIN=0.57.0   # hyprk's config is Lua (Hyprland >= 0.55) and uses 0.57 APIs; .conf was dropped in 0.57
QS_MIN=0.3.2          # the only Quickshell release hyprk was tested with
HYPRLOCK_MIN=0.9.0
# tags for the source build (same set as the dev prefix, see packaging/README.md)
SRC_TAGS="wayland-protocols=1.50 hyprwayland-scanner=v0.4.6 hyprutils=v0.14.3 hyprlang=v0.6.8 hyprwire=v0.3.1
hyprland-protocols=v0.8.0 hyprcursor=v0.1.14 hyprgraphics=v0.6.0 aquamarine=v0.16.0 Hyprland=v0.57.2
quickshell=v0.3.2 hyprlock=v0.9.7"

# What an install contains. The repo is private and tracks Apple fonts, icons, cursors, sounds and wallpapers; the look
# needs them, so they are copied (this install is for YOUR machine only: never upload or share the result).
# Left out: reference/ (macOS screenshots, RE dumps), packaging/, the dev's state/, sounds/originals (the unconverted
# duplicates of sounds/wav and sounds/oga, 44 MB) except the 23 files the shell plays (SHIP_SOUNDS_RE, 6.2 MB:
# shell/scripts/sound.sh and the Settings preview play the Apple original when it exists, else the Vorbis copy), and
# the whole wallpaper collection (1.4 GB). Only the wallpapers in SHIP_WALLPAPERS (themes/wallpapers/png, what the code
# uses as defaults) are copied, downscaled to WP_MAX px.
# The same lists are mirrored in packaging/arch/PKGBUILD, fedora/hyprk.spec and nix/flake.nix.
NOSHIP="reference packaging state themes/wallpapers sounds/originals"
# the originals sound.sh plays: the 14 alert sounds and its event files (keep in step with its `pick` calls)
SHIP_SOUNDS_RE="^sounds/originals/(Sounds/[^/]+$|misc/(BezelServices-volume|PowerChime-connect_power)\.|SystemSounds/(system/(Screen Capture|Volume Mount|Volume Unmount|SentMessage)|finder/empty trash|dock/(drag to trash|poof item off dock))\.)"
SHIP_WALLPAPERS="TahoeLight.png TahoeDark.png DefaultAerial.png"
WP_MAX=3840

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC=${HYPRK_SRC:-$(cd "$HERE/.." && pwd)}
YES=0 UNINSTALL=0 FROM_SOURCE=auto ASSETS='' NO_DEPS=0 NO_SESSION=0 PRINT_DEPS=0 KEEP_SRC=0
PREFIX=${XDG_DATA_HOME:-$HOME/.local/share}/hyprk
while [ $# -gt 0 ]; do
    case $1 in
        -y|--yes) YES=1 ;;
        --uninstall) UNINSTALL=1 ;;
        --prefix) PREFIX=${2:?--prefix needs a dir}; shift ;;
        --from-source) FROM_SOURCE=${2:?}; shift; case $FROM_SOURCE in auto|yes|no) ;; *) echo "--from-source: auto|yes|no" >&2; exit 2 ;; esac ;;
        --assets) ASSETS=$(cd "${2:?--assets needs a dir}" && pwd); shift ;;
        --keep-src) KEEP_SRC=1 ;;
        --no-deps) NO_DEPS=1 ;;
        --no-session) NO_SESSION=1 ;;
        --print-deps) PRINT_DEPS=1 ;;
        -h|--help) sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^# \{0,1\}//'; exit 0 ;;
        *) echo "install.sh: unknown option $1 (see --help)" >&2; exit 2 ;;
    esac
    shift
done
[ "$(id -u)" -ne 0 ] || [ $PRINT_DEPS = 1 ] || { echo "install.sh: run as your normal user; it calls sudo only for packages and the session file" >&2; exit 2; }
case $PREFIX in /*) ;; *) PREFIX=$PWD/$PREFIX ;; esac
PREFIX=${PREFIX%/}
case $PREFIX in ""|/usr|/usr/*|/etc|/etc/*|"$HOME") echo "install.sh: refusing prefix '${PREFIX:-/}'" >&2; exit 2 ;; esac
DEV=$PREFIX/dev                 # HYPRK_DEV: env.sh (+ prefix/ when built from source)
SESSION_FILE=/usr/share/wayland-sessions/hyprk.desktop
MARKER=.hyprk-install           # uninstall only deletes a PREFIX that has this file

# ---------------------------------------------------------------- output helpers ----
say()  { printf '%s\n' "$*"; }
step() { printf '\n== %s\n' "$*"; }
q()    { local a s=; for a in "$@"; do case $a in *[!A-Za-z0-9_./:=@%+,-]*|'') s+=" '${a//\'/\'\\\'\'}'" ;; *) s+=" $a" ;; esac; done; printf '%s' "${s# }"; }
run()  { if [ $YES = 1 ]; then say "+ $(q "$@")"; "$@"; else say "[dry-run] $(q "$@")"; fi; }
# write FILE MODE < content   (dry run shows the content)
write() {
    local f=$1 m=${2:-644} t
    if [ $YES = 1 ]; then
        say "+ write $f"; mkdir -p "$(dirname "$f")"; t=$(mktemp "$f.XXXXXX"); cat > "$t"; chmod "$m" "$t"; mv -f "$t" "$f"
    else
        say "[dry-run] write $f (mode $m):"; sed 's/^/    | /'
    fi
}
tag() { local kv; for kv in $SRC_TAGS; do [ "${kv%%=*}" = "$1" ] && { echo "${kv#*=}"; return; }; done; }
have() { command -v "$1" >/dev/null 2>&1; }
vge()  { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }   # vge A B: A >= B

# ---------------------------------------------------------------- distro detection ----
OSR=${HYPRK_OS_RELEASE:-}
[ -n "$OSR" ] || for f in /etc/os-release /usr/lib/os-release; do [ -r "$f" ] && { OSR=$f; break; }; done
ID='' ID_LIKE='' PRETTY_NAME=''
# shellcheck disable=SC1090
[ -n "$OSR" ] && [ -r "$OSR" ] && . "$OSR"
FAMILY=unknown
for w in $ID $ID_LIKE; do
    case $w in
        arch|manjaro|endeavouros|cachyos|garuda|artix) FAMILY=arch ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|kali|neon) FAMILY=debian ;;
        fedora|rhel|centos|nobara|ultramarine|almalinux|rocky) FAMILY=fedora ;;
        opensuse*|suse|sles|sle) FAMILY=suse ;;
        nixos) FAMILY=nixos ;;
        *) continue ;;
    esac
    break
done

PM_INSTALL=() PM_REFRESH=()
case $FAMILY in
    debian) PM_REFRESH=(sudo apt-get update); PM_INSTALL=(sudo apt-get install -y --no-install-recommends) ;;
    arch)   PM_REFRESH=(); PM_INSTALL=(sudo pacman -S --needed --noconfirm) ;;   # -Sy alone = partial upgrade, so no refresh
    fedora) PM_INSTALL=(sudo dnf install -y) ;;
    suse)   PM_REFRESH=(sudo zypper --non-interactive refresh); PM_INSTALL=(sudo zypper --non-interactive install --no-recommends) ;;
esac

# repo_version PKG: candidate version in the distro repos ("" = not packaged / unknown). Read-only queries.
repo_version() {
    local v=
    case $FAMILY in
        debian) v=$(apt-cache policy "$1" 2>/dev/null | sed -n 's/^ *Candidate: *//p' | head -n1); [ "$v" = "(none)" ] && v= ;;
        arch)   v=$(pacman -Si "$1" 2>/dev/null | sed -n 's/^Version *: *//p' | head -n1) ;;
        fedora) v=$(dnf -q repoquery --latest-limit 1 --qf '%{version}' "$1" 2>/dev/null | tail -n1) ;;
        suse)   v=$(zypper --non-interactive -q info "$1" 2>/dev/null | sed -n 's/^Version *: *//p' | head -n1) ;;
    esac
    v=${v#*:}; v=${v%%[-+~^]*}   # strip epoch, Debian/Fedora revision, +ds, ~bpo, ^git
    printf '%s' "$v"
}
installed_version() {   # installed_version BIN: version printed by the binary, "" if absent
    have "$1" || return 0
    case $1 in
        Hyprland) Hyprland --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | tr -d v ;;
        quickshell) quickshell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 ;;
        hyprlock) hyprlock --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 ;;
    esac
}

# ---------------------------------------------------------------- package map ----
# Kept in sync with packaging/DEPENDENCIES.md. Names marked (?) there are not verified in that distro's repos.
# RUNTIME: what the shell, settings, finder, lock screen and scripts call. BUILD: finder + plugin.
# HYPR: compositor stack from the distro (only when new enough). SRCBUILD: extra -dev libs for the source build.
pkgs() {   # pkgs FAMILY KIND
    case $1-$2 in
    debian-runtime) echo qt6-wayland qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
        qml6-module-qtquick-window qml6-module-qtquick-shapes qml6-module-qtquick-effects qml6-module-qtquick-templates \
        qml6-module-qtqml-workerscript qml6-module-qtcore qml6-module-qt-labs-folderlistmodel qt6-svg-plugins \
        imagemagick jq pipewire-bin wireplumber brightnessctl network-manager bluez upower grim slurp swaybg \
        python3 python3-pil poppler-utils libglib2.0-bin xdg-user-dirs fontconfig fonts-inter fonts-dejavu-core \
        adwaita-icon-theme foot qt6ct xwayland dbus-user-session ;;
    debian-build) echo build-essential cmake ninja-build pkg-config git qt6-base-dev qt6-declarative-dev \
        libpixman-1-dev libdrm-dev ;;
    debian-hypr) echo hyprland hyprland-dev libhyprutils-dev hyprlock hypridle ;;
    debian-qs) echo quickshell ;;
    debian-srcbuild) echo meson libpugixml-dev libgtest-dev libgmock-dev libseat-dev libinput-dev libdisplay-info-dev \
        hwdata libudev-dev libgbm-dev libegl-dev libgles-dev libffi-dev libcairo2-dev libpango1.0-dev libzip-dev \
        libtomlplusplus-dev librsvg2-dev libmagic-dev libjpeg-dev libpng-dev libwebp-dev libjxl-dev libheif-dev \
        libspng-dev liblua5.5-dev libeis-dev libmuparser-dev libre2-dev liblcms2-dev libcanberra-dev glslang-dev \
        glslang-tools uuid-dev libxcursor-dev libxkbcommon-dev libglaze-dev libreadline-dev libxcb1-dev \
        libxcb-render0-dev libxcb-xfixes0-dev libxcb-icccm4-dev libxcb-composite0-dev libxcb-res0-dev libxcb-errors-dev \
        libwayland-dev wayland-protocols qt6-base-private-dev qt6-declarative-private-dev qt6-shadertools-dev \
        qt6-wayland-dev qt6-svg-dev spirv-tools libcli11-dev libjemalloc-dev libunwind-dev libdwarf-dev \
        libpipewire-0.3-dev libpam0g-dev libpolkit-agent-1-dev libpolkit-gobject-1-dev libglib2.0-dev libvulkan-dev \
        libsdbus-c++-dev ;;
    arch-runtime) echo qt6-wayland qt6-declarative qt6-svg imagemagick jq pipewire wireplumber brightnessctl \
        networkmanager bluez bluez-utils upower grim slurp swaybg python python-pillow poppler glib2 xdg-user-dirs \
        fontconfig inter-font ttf-dejavu adwaita-icon-theme foot qt6ct xorg-xwayland ;;
    arch-build) echo base-devel cmake ninja pkgconf git qt6-base pixman libdrm ;;
    arch-hypr) echo hyprland hyprlock hypridle ;;     # hyprland ships its headers + hyprland.pc
    arch-qs) echo quickshell ;;
    arch-srcbuild) echo meson pugixml gtest seatd libinput libdisplay-info hwdata mesa libffi cairo pango libzip \
        tomlplusplus librsvg file libjpeg-turbo libpng libwebp libjxl libheif libspng lua muparser re2 lcms2 \
        libcanberra glslang util-linux-libs libxcursor libxkbcommon glaze readline libxcb xcb-util-errors \
        xcb-util-wm wayland wayland-protocols qt6-shadertools spirv-tools cli11 jemalloc libunwind libdwarf \
        libpipewire pam polkit vulkan-headers sdbus-cpp ;;
    fedora-runtime) echo qt6-qtwayland qt6-qtdeclarative qt6-qtsvg ImageMagick jq pipewire-utils wireplumber \
        brightnessctl NetworkManager bluez upower grim slurp swaybg python3 python3-pillow poppler-utils glib2 \
        xdg-user-dirs fontconfig rsms-inter-fonts dejavu-sans-fonts adwaita-icon-theme foot qt6ct \
        xorg-x11-server-Xwayland ;;
    fedora-build) echo gcc-c++ cmake ninja-build pkgconf-pkg-config git qt6-qtbase-devel qt6-qtdeclarative-devel \
        pixman-devel libdrm-devel ;;
    fedora-hypr) echo hyprland hyprland-devel hyprlock hypridle ;;   # not in Fedora's own repos (COPR only), see README
    fedora-qs) echo quickshell ;;
    fedora-srcbuild) echo meson pugixml-devel gtest-devel gmock-devel libseat-devel libinput-devel \
        libdisplay-info-devel hwdata systemd-devel mesa-libgbm-devel mesa-libEGL-devel mesa-libGLES-devel \
        libffi-devel cairo-devel pango-devel libzip-devel tomlplusplus-devel librsvg2-devel file-devel \
        libjpeg-turbo-devel libpng-devel libwebp-devel libjxl-devel libheif-devel lua-devel muParser-devel \
        re2-devel lcms2-devel libcanberra-devel glslang-devel glslang libuuid-devel libXcursor-devel \
        libxkbcommon-devel readline-devel libxcb-devel xcb-util-errors-devel xcb-util-wm-devel \
        wayland-devel wayland-protocols-devel qt6-qtbase-private-devel qt6-qtdeclarative-private-devel \
        qt6-qtshadertools-devel qt6-qtwayland-devel qt6-qtsvg-devel spirv-tools cli11-devel jemalloc-devel \
        libunwind-devel libdwarf-devel pipewire-devel pam-devel polkit-devel glib2-devel vulkan-headers \
        sdbus-cpp-devel ;;
    suse-runtime) echo qt6-wayland qt6-declarative-imports libQt6Svg6 ImageMagick jq pipewire-tools wireplumber \
        brightnessctl NetworkManager bluez upower grim slurp swaybg python3 python3-Pillow poppler-tools glib2-tools \
        xdg-user-dirs fontconfig inter-fonts dejavu-fonts adwaita-icon-theme foot qt6ct xwayland ;;
    suse-build) echo gcc-c++ cmake ninja pkgconf git qt6-base-devel qt6-declarative-devel libpixman-1-0-devel libdrm-devel ;;
    suse-hypr) echo hyprland hyprland-devel hyprutils-devel hyprlock hypridle ;;
    suse-qs) echo quickshell ;;
    suse-srcbuild) echo meson pugixml-devel gtest gmock seatd-devel libinput-devel libdisplay-info-devel hwdata \
        libudev-devel libgbm-devel Mesa-libEGL-devel Mesa-libGLESv3-devel libffi-devel cairo-devel pango-devel \
        libzip-devel tomlplusplus-devel librsvg-devel file-devel libjpeg8-devel libpng16-devel libwebp-devel \
        libjxl-devel libheif-devel lua55-devel muparser-devel re2-devel liblcms2-devel libcanberra-devel \
        glslang-devel libuuid-devel libXcursor-devel libxkbcommon-devel glaze-devel readline-devel libxcb-devel \
        xcb-util-errors-devel xcb-util-wm-devel wayland-devel wayland-protocols-devel qt6-base-private-devel \
        qt6-declarative-private-devel qt6-shadertools-devel qt6-wayland-private-devel qt6-svg-devel spirv-tools \
        cli11-devel jemalloc-devel libunwind-devel libdwarf-devel pipewire-devel pam-devel polkit-devel \
        glib2-devel vulkan-headers sdbus-cpp-devel ;;
    esac
}

# ---------------------------------------------------------------- uninstall ----
if [ $UNINSTALL = 1 ]; then
    step "uninstall hyprk ($([ $YES = 1 ] && echo live || echo dry run))"
    if [ -e "$SESSION_FILE" ] && grep -q "$PREFIX/bin/hyprk-session" "$SESSION_FILE" 2>/dev/null; then
        run sudo rm -f "$SESSION_FILE"
    elif [ -e "$SESSION_FILE" ]; then
        say "keeping $SESSION_FILE: it does not point at $PREFIX (another install, or dist/install-session.sh)"
    fi
    if [ -f "$PREFIX/$MARKER" ]; then run rm -rf -- "$PREFIX"
    elif [ -e "$PREFIX" ]; then say "refusing to delete $PREFIX: no $MARKER in it (not made by this installer)"
    else say "nothing at $PREFIX"; fi
    say "Kept: distro packages (remove them with your package manager if you want), the per-session data in"
    say "  ~/.local/share/hyprk-session and ~/.local/share/hyprk-try, and ~/.cache/hyprk."
    [ $YES = 1 ] || say "(dry run: add --yes to do it)"
    exit 0
fi

# ---------------------------------------------------------------- plan ----
say "hyprk installer ($([ $YES = 1 ] && echo LIVE || echo 'DRY RUN, nothing is changed; add --yes to execute'))"
say "distro   : ${PRETTY_NAME:-unknown} (ID=${ID:-?} ID_LIKE=${ID_LIKE:-} -> family $FAMILY)  [$OSR]"
say "source   : $SRC"
say "prefix   : $PREFIX  (HYPRK_ROOT)"

if [ $PRINT_DEPS = 1 ]; then
    for k in runtime build hypr qs srcbuild; do printf '%s: %s\n' "$k" "$(pkgs "$FAMILY" "$k")"; done
    exit 0
fi

case $FAMILY in
    nixos) say ""; say "NixOS: packages cannot be installed imperatively here. See packaging/nix/flake.nix (draft) and"
           say "install with --no-deps after adding hyprland, quickshell, hyprlock and the runtime list to your config."
           [ $NO_DEPS = 1 ] || { say "Re-run with --no-deps."; exit 1; } ;;
    unknown) say ""; say "Unknown distro: no package names. Install the list in packaging/DEPENDENCIES.md by hand,"
             say "then re-run with --no-deps (add --from-source yes if your Hyprland is older than $HYPRLAND_MIN)."
             NO_DEPS=1 ;;
esac

# --- does the distro (or what is installed) have new enough Hyprland / Quickshell / hyprlock? ---
need_src() {   # need_src BIN PKG MIN -> prints "distro X" or "source (reason)"
    local have_v repo_v
    have_v=$(installed_version "$1"); repo_v=
    [ "$FAMILY" = unknown ] || [ "$FAMILY" = nixos ] || repo_v=$(repo_version "$2")
    if [ -n "$have_v" ] && vge "$have_v" "$3"; then echo "installed $have_v"
    elif [ -n "$repo_v" ] && vge "$repo_v" "$3"; then echo "distro $repo_v"
    else echo "source (installed ${have_v:-none}, repo ${repo_v:-none}, need >= $3)"; fi
}
H_SRC=$(need_src Hyprland hyprland "$HYPRLAND_MIN")
Q_SRC=$(need_src quickshell quickshell "$QS_MIN")
L_SRC=$(need_src hyprlock hyprlock "$HYPRLOCK_MIN")
case $FROM_SOURCE in
    yes) BUILD_HYPR=1 BUILD_QS=1 ;;
    no)  BUILD_HYPR=0 BUILD_QS=0 ;;
    auto) BUILD_HYPR=0 BUILD_QS=0
          case $H_SRC in source*) BUILD_HYPR=1 ;; esac
          case $Q_SRC in source*) BUILD_QS=1 ;; esac
          # hyprlock links hyprutils/hyprlang/hyprgraphics: build it with the stack when the stack is built
          case $L_SRC in source*) BUILD_HYPR=1 ;; esac ;;
esac
say "Hyprland : $H_SRC"
say "Quickshell: $Q_SRC"
say "hyprlock : $L_SRC"
say "=> build from source: Hyprland stack + hyprlock $([ $BUILD_HYPR = 1 ] && echo yes || echo no), Quickshell $([ $BUILD_QS = 1 ] && echo yes || echo no)"
if [ "$FROM_SOURCE" = no ]; then
    case "$H_SRC$Q_SRC" in *source*) say "WARNING: --from-source no but a component is missing/too old; the session will not start until you fix that." ;; esac
fi

# ---------------------------------------------------------------- preflight: stop before anything is installed ----
LIST="$(pkgs "$FAMILY" runtime) $(pkgs "$FAMILY" build)"
[ $BUILD_HYPR = 1 ] || LIST="$LIST $(pkgs "$FAMILY" hypr)"
[ $BUILD_QS = 1 ] || LIST="$LIST $(pkgs "$FAMILY" qs)"
[ $BUILD_HYPR = 1 ] || [ $BUILD_QS = 1 ] && LIST="$LIST $(pkgs "$FAMILY" srcbuild)"
# shellcheck disable=SC2206
PKGS=($LIST)
stop() { say ""; say "ERROR: $*"; say "Nothing was installed or changed."; exit 1; }
if [ $BUILD_HYPR = 1 ] && [ $FAMILY != unknown ] && [ $FAMILY != nixos ]; then
    # Hyprland 0.57 is C++26: needs GCC >= 15. Installed g++ first, else what the repos would give.
    case $FAMILY in debian) GCCPKG=g++ ;; arch) GCCPKG=gcc ;; *) GCCPKG=gcc-c++ ;; esac
    GCC_PLAN=$( (g++ -dumpversion 2>/dev/null || repo_version $GCCPKG) | cut -d. -f1)
    case $GCC_PLAN in ''|*[!0-9]*) say "note: could not tell which GCC this system has; the source build needs GCC >= 15" ;;
        *) [ "$GCC_PLAN" -ge 15 ] || stop "building Hyprland $(tag Hyprland) needs GCC >= 15 (C++26), this system has GCC $GCC_PLAN. Use a newer release of $PRETTY_NAME, or install a newer Hyprland yourself and re-run with --from-source no." ;;
    esac
fi
if [ $NO_DEPS = 0 ] && [ ${#PKGS[@]} -gt 0 ]; then
    # read-only simulation with the package manager: which of the packages do not exist in this release's repos?
    case $FAMILY in
        debian) MISSING=$(apt-get install -s "${PKGS[@]}" 2>&1 | sed -n "s/^E: Unable to locate package //p; s/^E: Package '\(.*\)' has no installation candidate.*/\1/p" | sort -u) || true ;;
        arch)   MISSING=$(pacman -Sp --needed "${PKGS[@]}" 2>&1 >/dev/null | sed -n 's/^error: target not found: //p' | sort -u) || true ;;
        fedora) MISSING=$(dnf -q install --assumeno "${PKGS[@]}" 2>&1 | sed -n 's/^No match for argument: //p' | sort -u) || true ;;
        *)      MISSING='' ;;   # suse: zypper needs root even to simulate, so the names are not checked here
    esac
    [ -z "$MISSING" ] || stop "this release of $PRETTY_NAME does not have: $(echo $MISSING). Its repos are too old or too different for hyprk (see packaging/DEPENDENCIES.md). If the package lists are empty or stale, refresh them and re-run."
fi

# ---------------------------------------------------------------- 1. packages ----
step "1. distro packages"
if [ ${#PKGS[@]} -eq 0 ]; then say "(no package list for family $FAMILY)"
elif [ $NO_DEPS = 1 ]; then say "skipped (--no-deps). Needed: ${PKGS[*]}"
else
    [ ${#PM_REFRESH[@]} -eq 0 ] || run "${PM_REFRESH[@]}"
    [ "$FAMILY" = arch ] && say "(Arch: run 'sudo pacman -Syu' first if the system is not up to date)"
    run "${PM_INSTALL[@]}" "${PKGS[@]}"
fi

# ---------------------------------------------------------------- 2. source build ----
P=$DEV/prefix
url() {
    case $1 in
        wayland-protocols) echo https://gitlab.freedesktop.org/wayland/wayland-protocols.git ;;
        quickshell) echo https://git.outfoxxed.me/quickshell/quickshell.git ;;
        *) echo "https://github.com/hyprwm/$1.git" ;;
    esac
}
build_one() {   # build_one REPO [extra cmake args...]
    local r=$1 s=$DEV/src/$1; shift
    say "-- $r $(tag "$r")"
    if [ -d "$s/.git" ]; then run git -C "$s" fetch -q --tags; else run git clone -q --filter=blob:none "$(url "$r")" "$s"; fi
    run git -C "$s" -c advice.detachedHead=false checkout -q "$(tag "$r")"
    [ "$r" = Hyprland ] && run git -C "$s" submodule update --init --recursive -q
    if [ "$r" = Hyprland ] && [ "$GCC_MAJOR" -lt 16 ]; then
        # 0.57.2 uses two C++26 library calls libstdc++ 15 lacks; the patch swaps them (no behaviour change)
        run git -C "$s" apply "$HERE/patches/hyprland-0.57.2-gcc15-compat.patch"
    fi
    if [ "$r" = wayland-protocols ]; then
        run meson setup "$s/build" "$s" --prefix="$P" --libdir=lib --buildtype=release -Dtests=false --wipe
        run meson install -C "$s/build"
    else
        run cmake -S "$s" -B "$s/build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$P" \
            -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_RPATH="$P/lib" -DBUILD_TESTING=OFF -Wno-dev "$@"
        run cmake --build "$s/build" -j"${J:-$(nproc)}"
        run cmake --install "$s/build" --strip   # symbol tables only: plugins resolve through .dynsym (nm -D)
    fi
    # the tree is not read again (later builds and the plugin use $P), and a later --from-source run clones it anew
    [ $KEEP_SRC = 1 ] || run rm -rf -- "$s"
}
GCC_MAJOR=$( (g++ -dumpversion 2>/dev/null || echo 0) | cut -d. -f1)
step "2. source build into $P"
if [ $BUILD_HYPR = 0 ] && [ $BUILD_QS = 0 ]; then say "not needed (distro packages are new enough)"
else
    # without g++ (dry run before the packages exist) use the version the preflight read from the repos
    [ "$GCC_MAJOR" -gt 0 ] || case ${GCC_PLAN:-} in ''|*[!0-9]*) ;; *) GCC_MAJOR=$GCC_PLAN ;; esac
    if [ $BUILD_HYPR = 1 ] && [ "$GCC_MAJOR" -lt 15 ] && { [ $YES = 1 ] || [ "$GCC_MAJOR" -gt 0 ]; }; then
        say "ERROR: Hyprland $(tag Hyprland) needs GCC >= 15 (C++26); this system has g++ ${GCC_MAJOR}."
        say "Use a newer distro release, or a toolchain such as a distro gcc-15 package, then re-run."
        [ $YES = 1 ] && exit 1
    fi
    # the build finds its own libs first
    export PATH="$P/bin:$PATH" PKG_CONFIG_PATH="$P/lib/pkgconfig:$P/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    export LD_LIBRARY_PATH="$P/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" CMAKE_PREFIX_PATH="$P"
    run mkdir -p "$DEV/src"
    if [ $BUILD_HYPR = 1 ]; then
        for r in wayland-protocols hyprwayland-scanner hyprutils hyprlang hyprwire hyprland-protocols hyprcursor \
                 hyprgraphics aquamarine; do build_one "$r"; done
        build_one Hyprland
        build_one hyprlock
    fi
    [ $BUILD_QS = 1 ] && build_one quickshell -DINSTALL_QMLDIR="$P/lib/qt6/qml" -DVENDOR_CPPTRACE=ON \
        -DDISTRIBUTOR="hyprk packaging/install.sh (source build)"
    [ $KEEP_SRC = 1 ] || run rmdir --ignore-fail-on-non-empty "$DEV/src"
    say "Note: Quickshell uses private Qt API. Re-run this installer after every Qt update (--from-source yes)."
fi

# ---------------------------------------------------------------- 3. files ----
step "3. copy hyprk into $PREFIX (fonts, icons, cursors, sounds included; no reference/, no wallpaper collection)"
[ -d "$SRC/shell" ] && [ -d "$SRC/config/hypr" ] || { say "ERROR: $SRC is not a hyprk checkout"; exit 1; }
run mkdir -p "$PREFIX"
NOSHIP_RE="^($(echo $NOSHIP | tr ' ' '|'))/"
if [ -d "$SRC/.git" ] && have git; then
    # the tracked files minus NOSHIP
    say "[files] git ls-files minus: $(echo $NOSHIP) ($(git -C "$SRC" ls-files | grep -cvE "$NOSHIP_RE") files)"
    if [ $YES = 1 ]; then
        { git -C "$SRC" ls-files -z | grep -zvE "$NOSHIP_RE"; git -C "$SRC" ls-files -z sounds/originals | grep -zE "$SHIP_SOUNDS_RE"; } |
            tar -C "$SRC" --null -T - -cf - | tar -C "$PREFIX" -xf -
    else say "[dry-run] { git -C $(q "$SRC") ls-files -z | grep -zvE $(q "$NOSHIP_RE"); git ls-files -z sounds/originals | grep -zE $(q "$SHIP_SOUNDS_RE"); } | tar -C $(q "$SRC") --null -T - -cf - | tar -C $(q "$PREFIX") -xf -"; fi
else
    # tarball without .git: copy everything except NOSHIP
    EXC=(--exclude='*/build' --exclude=__pycache__)
    for d in $NOSHIP; do EXC+=("--exclude=./$d"); done
    if [ $YES = 1 ]; then
        tar -C "$SRC" "${EXC[@]}" -cf - . | tar -C "$PREFIX" -xf -
        [ -d "$SRC/sounds/originals" ] && (cd "$SRC" && find sounds/originals -type f -print0 | grep -zE "$SHIP_SOUNDS_RE" |
            tar --null -T - -cf - | tar -C "$PREFIX" -xf -)
    else say "[dry-run] tar -C $(q "$SRC") ${EXC[*]} -cf - . | tar -C $(q "$PREFIX") -xf -, plus sounds/originals matching $(q "$SHIP_SOUNDS_RE")"; fi
fi
run mkdir -p "$PREFIX/bin" "$PREFIX/themes/wallpapers/png"
[ $YES = 1 ] && date -u +"installed %Y-%m-%dT%H:%M:%SZ from $SRC" > "$PREFIX/$MARKER"
[ $YES = 1 ] || say "[dry-run] write $PREFIX/$MARKER"

# ---------------------------------------------------------------- 4. assets ----
step "4. assets"
has_file() { [ -e "$SRC/$1" ] || { [ -n "$ASSETS" ] && [ -e "$ASSETS/$1" ]; }; }
# the small default wallpaper set from the checkout, downscaled (the originals are 6016 px, 46 MB each)
for w in $SHIP_WALLPAPERS; do
    [ -f "$SRC/themes/wallpapers/png/$w" ] || { say "  - wallpaper $w: not in $SRC, skipped"; continue; }
    if have magick || [ $YES = 0 ]; then
        run magick "$SRC/themes/wallpapers/png/$w" -resize "${WP_MAX}x${WP_MAX}>" -define png:compression-level=9 "$PREFIX/themes/wallpapers/png/$w"
    else run cp "$SRC/themes/wallpapers/png/$w" "$PREFIX/themes/wallpapers/png/$w"; fi
done
if [ -n "$ASSETS" ]; then
    say "more of your own assets from $ASSETS (only these sub-dirs, each only if present; e.g. the rest of the wallpapers):"
    for d in themes/fonts themes/wallpapers themes/icons/apps themes/icons/system themes/icons/hyprk-apple \
             themes/cursors/theme/hyprk-cursors sounds/oga sounds/wav; do
        [ -d "$ASSETS/$d" ] || { say "  - $d: not in $ASSETS, skipped"; continue; }
        run mkdir -p "$PREFIX/$(dirname "$d")"
        run cp -a "$ASSETS/$d" "$PREFIX/$(dirname "$d")/"
    done
fi
# which look is available (a checkout without the Apple assets, e.g. a public tarball, gets the free fallbacks)
HAS_SF=0 HAS_ICONS=0 HAS_CURSORS=0
has_file themes/fonts && HAS_SF=1
has_file themes/icons/apps && HAS_ICONS=1
has_file themes/cursors/theme/hyprk-cursors && HAS_CURSORS=1
[ $HAS_SF = 1 ] && [ $HAS_ICONS = 1 ] && [ $HAS_CURSORS = 1 ] || say "note: some of fonts/icons/cursors are not in $SRC: the free fallbacks (Inter, icon theme, Adwaita) are used for those"
# a free wallpaper (ImageMagick): wallpaper.sh picks *light* / *dark* from themes/wallpapers
for m in light dark; do
    f=$PREFIX/themes/wallpapers/png/hyprk-gradient-$m.png
    if [ "$m" = dark ]; then c="#0b1a3a-#1d4f8f" r="#3a1f5c-none"; else c="#2f7fd8-#7cc4f0" r="#9a7be0-none"; fi
    if [ $YES = 1 ] && [ -e "$f" ]; then continue; fi
    if have magick || [ $YES = 0 ]; then
        run magick -size 3840x2160 "gradient:$c" \( -size 3840x2160 "radial-gradient:$r" \) -compose over -composite "$f"
    else say "skip $f: no ImageMagick 'magick' (install it, then re-run)"; fi
done

# hyprlock has no relative paths: point the in-tree lock config at this prefix (and at Inter without SF fonts)
LOCKCONF=$PREFIX/lockscreen/hyprlock.conf
SED=(-e "s|^\\\$WALLPAPER = .*|\$WALLPAPER = $PREFIX/themes/wallpapers/png/$(has_file themes/wallpapers/png/TahoeLight.png && echo TahoeLight || echo hyprk-gradient-light).png|"
     -e "s|^\\\$AVATAR = .*|\$AVATAR = $PREFIX/lockscreen/assets/avatar-default.png|"
     -e "s|^\\\$STATUS = .*|\$STATUS = $PREFIX/lockscreen/scripts/status-icon.sh|"
     -e "s|^\\\$STATUS_DIR = .*|\$STATUS_DIR = $PREFIX/lockscreen/assets/status|")
[ $HAS_SF = 1 ] || SED+=(-e 's|^\$FONT = SF Pro$|$FONT = Inter|' -e 's|^\$FONT_ROUNDED = SF Pro Rounded$|$FONT_ROUNDED = Inter|')
run sed -i "${SED[@]}" "$LOCKCONF"

# ---------------------------------------------------------------- 5. build hyprk ----
step "5. build Finder and the liquidglass plugin"
DEVENV=$DEV/env.sh
{
    echo "# generated by hyprk packaging/install.sh: sourced by dist/lib/env.sh as \$HYPRK_DEV/env.sh"
    if [ $BUILD_HYPR = 1 ] || [ $BUILD_QS = 1 ]; then
        cat <<EOF
export HYPR_PREFIX='$P'
export PATH="\$HYPR_PREFIX/bin:\$PATH"
export LD_LIBRARY_PATH="\$HYPR_PREFIX/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="\$HYPR_PREFIX/lib/pkgconfig:\$HYPR_PREFIX/share/pkgconfig\${PKG_CONFIG_PATH:+:\$PKG_CONFIG_PATH}"
export CMAKE_PREFIX_PATH="\$HYPR_PREFIX\${CMAKE_PREFIX_PATH:+:\$CMAKE_PREFIX_PATH}"
export QML_IMPORT_PATH="\$HYPR_PREFIX/lib/qt6/qml\${QML_IMPORT_PATH:+:\$QML_IMPORT_PATH}" QML2_IMPORT_PATH="\$HYPR_PREFIX/lib/qt6/qml\${QML2_IMPORT_PATH:+:\$QML2_IMPORT_PATH}"
export XDG_DATA_DIRS="\$HYPR_PREFIX/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
EOF
    else echo ": # distro Hyprland + Quickshell: nothing to add"; fi
} | write "$DEVENV" 644
run cmake -S "$PREFIX/finder" -B "$PREFIX/finder/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
run cmake --build "$PREFIX/finder/build"
# The plugin must be built against the EXACT Hyprland that runs it (headers + ABI hash check in the plugin).
# hyprland.lua loads $HYPRK_ROOT/plugin/build/libliquidglass.so and falls back to QML glass when it fails.
if ! run sh -c ". '$DEVENV' && cmake -S '$PREFIX/plugin' -B '$PREFIX/plugin/build' -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build '$PREFIX/plugin/build' --target liquidglass"; then
    say "WARNING: the liquidglass plugin did not build (no Hyprland headers?). hyprk still runs with the QML glass."
fi
say "Rebuild the plugin after every Hyprland update: $PREFIX/bin/hyprk-rebuild-plugin"
write "$PREFIX/bin/hyprk-rebuild-plugin" 755 <<EOF
#!/bin/sh
# Rebuild the liquidglass plugin against the Hyprland that is installed now (run after Hyprland updates).
. '$DEVENV' && rm -rf '$PREFIX/plugin/build' && cmake -S '$PREFIX/plugin' -B '$PREFIX/plugin/build' -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build '$PREFIX/plugin/build' --target liquidglass
EOF

# ---------------------------------------------------------------- 6. launchers + session ----
step "6. launchers"
write "$PREFIX/bin/hyprk-session" 755 <<EOF
#!/bin/sh
# hyprk login session (generated by packaging/install.sh). Sets the install paths, then runs dist/hyprk-session.
export HYPRK_ROOT='$PREFIX' HYPRK_DEV='$DEV'
export HYPRK_APPLE_ICONS=$HAS_ICONS
$([ $HAS_CURSORS = 1 ] || echo 'export HYPRK_CURSOR_THEME=Adwaita   # honoured once start.sh/hyprland.lua read it (packaging/README.md)')
exec "\$HYPRK_ROOT/dist/hyprk-session" "\$@"
EOF
write "$PREFIX/bin/hyprk-try" 755 <<EOF
#!/bin/sh
# Try hyprk in a window inside your current Wayland desktop (generated by packaging/install.sh).
export HYPRK_ROOT='$PREFIX' HYPRK_DEV='$DEV'
export HYPRK_APPLE_ICONS=$HAS_ICONS
exec "\$HYPRK_ROOT/dist/try-nested.sh" "\$@"
EOF

step "7. login session entry (sudo, the only file outside $PREFIX)"
if [ $NO_SESSION = 1 ]; then say "skipped (--no-session). Try it nested: $PREFIX/bin/hyprk-try"
else
    # A display manager does not expand \$HOME in Exec, so the path is absolute: one entry per installing user.
    TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
    cat > "$TMP" <<EOF
[Desktop Entry]
Name=hyprk
Comment=Hyprland that looks like macOS (hyprk, installed for $(id -un 2>/dev/null || echo "uid $(id -u)"))
Exec=$PREFIX/bin/hyprk-session
TryExec=$PREFIX/bin/hyprk-session
Type=Application
DesktopNames=Hyprland
EOF
    say "session file:"; sed 's/^/    | /' "$TMP"
    [ -e "$SESSION_FILE" ] && say "($SESSION_FILE exists and will be replaced)"
    run sudo install -D -m 644 "$TMP" "$SESSION_FILE"
fi

step "done"
if [ $YES = 1 ]; then
    say "Log out and pick \"hyprk\" in your display manager, or try it nested: $PREFIX/bin/hyprk-try"
else
    say "Dry run only. Re-run with --yes to execute the commands above."
fi
say "Uninstall: $0 --uninstall --yes"
