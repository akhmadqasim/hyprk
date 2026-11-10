# hyprk for Fedora. Checked on 2026-11-10 in a fedora:latest (45) container: rpmlint, and an rpmbuild run with the
# liquidglass plugin step stubbed (Fedora has no hyprland-devel). Never built whole, never installed.
# Fedora's own repos have no hyprland >= 0.57 and no hyprlock (packages.fedoraproject.org: hyprland only up to F42
# 0.45.2; quickshell is 0.2.1). So this spec only makes sense in a COPR that ALSO builds hyprland 0.57.x, hyprlock,
# the hyprwm libraries and quickshell 0.3.2, or that chains to a COPR which does (packaging/README.md).
# State: config/hypr/state-dir.sh (shipped in config/) uses ~/.local/state/hyprk when /usr/share/hyprk is read-only.
#
# Source0 comes from the private checkout and must NOT contain the Apple assets (the repo tracks them), or the SRPM
# would publish them. Make it from the repo root:
#   git archive --format=tar.gz --prefix=hyprk-0.1.0/ -o ~/rpmbuild/SOURCES/hyprk-0.1.0.tar.gz HEAD -- . \
#     ':(exclude)reference' ':(exclude)packaging' ':(exclude)state' ':(exclude)themes/fonts' ':(exclude)themes/wallpapers' \
#     ':(exclude)themes/icons/apps' ':(exclude)themes/icons/apps-hires' ':(exclude)themes/icons/system' \
#     ':(exclude)themes/icons/hyprk-apple' ':(exclude)themes/cursors/png' ':(exclude)themes/cursors/accessibility' \
#     ':(exclude)themes/cursors/hiservices' ':(exclude)themes/cursors/cursorasset' \
#     ':(exclude)themes/cursors/theme/hyprk-cursors' ':(exclude)sounds/oga' ':(exclude)sounds/wav' ':(exclude)sounds/originals'
# (same list as NOSHIP in packaging/install.sh). %prep stops the build if any of them is in the tarball.
%global debug_package %{nil}

Name:           hyprk
Version:        0.1.0
Release:        0.1%{?dist}
Summary:        macOS 27-look desktop on Hyprland (no Apple assets)
License:        TBD
URL:            https://example.invalid/hyprk
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
System Settings app styled after macOS 27. Ships no Apple fonts, wallpapers,
icons or sounds; users may add their own (packaging/README.md).

%prep
%autosetup
for d in reference packaging themes/fonts themes/wallpapers themes/icons/apps themes/icons/apps-hires \
         themes/icons/system themes/icons/hyprk-apple themes/cursors/png themes/cursors/accessibility \
         themes/cursors/hiservices themes/cursors/cursorasset themes/cursors/theme/hyprk-cursors \
         sounds/oga sounds/wav sounds/originals; do
    if [ -e "$d" ]; then echo "Source0 contains $d: remake it with the git archive command at the top of this spec"; exit 1; fi
done

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
# config/icons/hyprk-cursors points into the cursor theme that is not shipped
find "$root" -xtype l -delete; rmdir --ignore-fail-on-non-empty "$root/config/icons"
install -Dm755 build-finder/hyprk-finder "$root/finder/build/hyprk-finder"
install -Dm755 build-plugin/libliquidglass.so "$root/plugin/build/libliquidglass.so"
# free defaults for the assets that are not shipped: gradient wallpapers, Inter instead of SF Pro (same as install.sh)
mkdir -p "$root/themes/wallpapers/png"
magick -size 3840x2160 'gradient:#2f7fd8-#7cc4f0' \( -size 3840x2160 'radial-gradient:#9a7be0-none' \) \
    -compose over -composite "$root/themes/wallpapers/png/hyprk-gradient-light.png"
magick -size 3840x2160 'gradient:#0b1a3a-#1d4f8f' \( -size 3840x2160 'radial-gradient:#3a1f5c-none' \) \
    -compose over -composite "$root/themes/wallpapers/png/hyprk-gradient-dark.png"
# hyprlock has no relative paths
sed -i -e 's|/mnt/code/hyprk|%{_datadir}/hyprk|g' \
    -e 's|^\$WALLPAPER = .*|$WALLPAPER = %{_datadir}/hyprk/themes/wallpapers/png/hyprk-gradient-light.png|' \
    -e 's|^\$FONT = SF Pro$|$FONT = Inter|' -e 's|^\$FONT_ROUNDED = SF Pro Rounded$|$FONT_ROUNDED = Inter|' \
    "$root/lockscreen/hyprlock.conf"
mkdir -p "$root/dev" && echo ': # distro Hyprland' > "$root/dev/env.sh"
install -Dm755 /dev/stdin %{buildroot}%{_bindir}/hyprk-session <<'SH'
#!/bin/sh
export HYPRK_ROOT=/usr/share/hyprk HYPRK_DEV=/usr/share/hyprk/dev HYPRK_APPLE_ICONS=0 HYPRK_CURSOR_THEME=Adwaita
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
