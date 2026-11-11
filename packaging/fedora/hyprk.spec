# hyprk for Fedora. Checked on 2026-11-10 in a fedora:latest (45) container: rpmlint, and an rpmbuild run with the
# liquidglass plugin step stubbed (Fedora has no hyprland-devel). Never built whole, never installed.
# Fedora's own repos have no hyprland >= 0.57 and no hyprlock (packages.fedoraproject.org: hyprland only up to F42
# 0.45.2; quickshell is 0.2.1). So this spec only makes sense in a COPR that ALSO builds hyprland 0.57.x, hyprlock,
# the hyprwm libraries and quickshell 0.3.2, or that chains to a COPR which does (packaging/README.md).
# State: config/hypr/state-dir.sh (shipped in config/) uses ~/.local/state/hyprk when /usr/share/hyprk is read-only.
#
# !! The built RPM/SRPM CONTAINS APPLE FONTS, ICONS, CURSORS, SOUNDS AND WALLPAPERS. It is for your own machines only.
# !! NEVER upload it or the SRPM or the Source0 tarball anywhere: not COPR, not a repo, not a release, not a cache.
# (So the COPR idea in packaging/README.md only works for the Hyprland stack and quickshell, never for this package.)
#
# Source0 = the private checkout without reference/, packaging/, state/, sounds/originals (duplicates of sounds/wav)
# and the wallpaper collection (1.4 GB); only the wallpapers in the allowlist below go in. From the repo root:
#   git archive --prefix=hyprk-0.1.0/ -o /tmp/a.tar HEAD -- . ':(exclude)reference' ':(exclude)packaging' \
#     ':(exclude)state' ':(exclude)themes/wallpapers' ':(exclude)sounds/originals'
#   git archive --prefix=hyprk-0.1.0/ -o /tmp/w.tar HEAD -- themes/wallpapers/png/TahoeLight.png \
#     themes/wallpapers/png/TahoeDark.png themes/wallpapers/png/DefaultAerial.png
#   git ls-files -z sounds/originals | grep -zE "$(sed -n 's/^SHIP_SOUNDS_RE="\(.*\)"$/\1/p' packaging/install.sh)" |
#     xargs -0 git archive --prefix=hyprk-0.1.0/ -o /tmp/s.tar HEAD --
#   tar -Af /tmp/a.tar /tmp/w.tar && tar -Af /tmp/a.tar /tmp/s.tar && gzip -c /tmp/a.tar > ~/rpmbuild/SOURCES/hyprk-0.1.0.tar.gz
# (same lists as NOSHIP, SHIP_SOUNDS_RE and SHIP_WALLPAPERS in packaging/install.sh: the third archive adds the 23
# sounds/originals files the shell plays). The prep section stops the build if the tarball holds anything else from
# themes/wallpapers or sounds/originals, or reference/, packaging/ or state/. The install
# section downscales the wallpapers to 3840 px (the originals are 6016 px and 46 MB each). The rest of the wallpapers:
# copy them to /usr/share/hyprk/themes/wallpapers/png/ by hand (packaging/README.md).
%global debug_package %{nil}

Name:           hyprk
Version:        0.1.0
Release:        0.1%{?dist}
Summary:        macOS 27-look desktop on Hyprland (contains Apple assets, private use only)
License:        TBD
URL:            https://example.invalid/hyprk
# private repo: do not publish this package
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++ >= 15, cmake >= 3.27, ninja-build, pkgconf-pkg-config, ImageMagick
BuildRequires:  qt6-qtbase-devel, qt6-qtdeclarative-devel, pixman-devel, libdrm-devel
BuildRequires:  hyprland-devel >= 0.57, hyprutils-devel
# the plugin is ABI-locked to the Hyprland it was built against
%global hl_ver %(pkg-config --modversion hyprland 2>/dev/null || echo 0)
Requires:       hyprland = %{hl_ver}
Requires:       quickshell >= 0.3.2, hyprlock >= 0.9, hypridle
Requires:       qt6-qtwayland, qt6-qtdeclarative, qt6-qtsvg
Requires:       ImageMagick, jq, pipewire-utils, wireplumber, brightnessctl, NetworkManager, bluez, upower
Requires:       grim, slurp, swaybg, python3, python3-pillow, poppler-utils, glib2, xdg-user-dirs, fontconfig
Requires:       rsms-inter-fonts, dejavu-sans-fonts, adwaita-icon-theme, xorg-x11-server-Xwayland
Recommends:     foot, qt6ct, kvantum

%description
hyprk: a Quickshell shell, a Liquid Glass Hyprland plugin, a Qt Finder and a
System Settings app styled after macOS 27. Contains Apple fonts, icons, cursors,
sounds and a few wallpapers: private use only, never upload it.

%prep
%autosetup
for d in reference packaging state themes/wallpapers/heic themes/wallpapers/dynamic-sonoma; do
    if [ -e "$d" ]; then echo "Source0 contains $d: remake it with the git archive commands at the top of this spec"; exit 1; fi
done
extra=$(find themes/wallpapers -type f 2>/dev/null | grep -vE '^themes/wallpapers/png/(TahoeLight|TahoeDark|DefaultAerial)\.png$' || true)
if [ -n "$extra" ]; then echo "Source0 holds more wallpapers than the allowlist: $extra"; exit 1; fi
# sounds/originals: only what the shell plays (SHIP_SOUNDS_RE in packaging/install.sh)
extra=$(find sounds/originals -type f 2>/dev/null | grep -vE '^sounds/originals/(Sounds/[^/]+$|misc/(BezelServices-volume|PowerChime-connect_power)\.|SystemSounds/(system/(Screen Capture|Volume Mount|Volume Unmount|SentMessage)|finder/empty trash|dock/(drag to trash|poof item off dock))\.)' || true)
if [ -n "$extra" ]; then echo "Source0 holds more of sounds/originals than SHIP_SOUNDS_RE: $extra"; exit 1; fi

%build
cmake -S finder -B build-finder -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-finder
cmake -S plugin -B build-plugin -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-plugin --target liquidglass

%install
root=%{buildroot}%{_datadir}/hyprk
mkdir -p "$root"
cp -a config dist finder lockscreen scripts settings shell themes sounds ui "$root/"
find "$root" -name .gitignore -delete
find "$root" -name __pycache__ -prune -exec rm -rf {} +
install -Dm755 build-finder/hyprk-finder "$root/finder/build/hyprk-finder"
install -Dm755 build-plugin/libliquidglass.so "$root/plugin/build/libliquidglass.so"
# the default wallpapers, downscaled, plus gradient fallbacks (same as install.sh)
mkdir -p "$root/themes/wallpapers/png"
for w in TahoeLight.png TahoeDark.png DefaultAerial.png; do
    [ -f "themes/wallpapers/png/$w" ] || continue
    magick "themes/wallpapers/png/$w" -resize '3840x3840>' -define png:compression-level=9 "$root/themes/wallpapers/png/$w"
done
magick -size 3840x2160 'gradient:#2f7fd8-#7cc4f0' \( -size 3840x2160 'radial-gradient:#9a7be0-none' \) \
    -compose over -composite "$root/themes/wallpapers/png/hyprk-gradient-light.png"
magick -size 3840x2160 'gradient:#0b1a3a-#1d4f8f' \( -size 3840x2160 'radial-gradient:#3a1f5c-none' \) \
    -compose over -composite "$root/themes/wallpapers/png/hyprk-gradient-dark.png"
# hyprlock has no relative paths
sed -i 's|/mnt/code/hyprk|%{_datadir}/hyprk|g' "$root/lockscreen/hyprlock.conf"
mkdir -p "$root/dev" && echo ': # distro Hyprland' > "$root/dev/env.sh"
install -Dm755 /dev/stdin %{buildroot}%{_bindir}/hyprk-session <<'SH'
#!/bin/sh
export HYPRK_ROOT=/usr/share/hyprk HYPRK_DEV=/usr/share/hyprk/dev
exec /usr/share/hyprk/dist/hyprk-session "$@"
SH
install -Dm644 /dev/stdin %{buildroot}%{_datadir}/wayland-sessions/hyprk.desktop <<'DESK'
[Desktop Entry]
Name=hyprk
Comment=Hyprland that looks like macOS
Exec=/usr/bin/hyprk-session
TryExec=/usr/bin/hyprk-session
Type=Application
DesktopNames=Hyprland
DESK

%files
%{_bindir}/hyprk-session
%{_datadir}/hyprk
%{_datadir}/wayland-sessions/hyprk.desktop

%changelog
* Tue Nov 10 2026 hyprk packaging <noreply@example.invalid> - 0.1.0-0.1
- Draft, see the comments at the top
