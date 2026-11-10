# DRAFT, UNTESTED (never built with rpmbuild/mock, no COPR project exists). Notes in packaging/README.md.
# Fedora's own repos have no hyprland >= 0.57 (packages.fedoraproject.org lists hyprland only up to F42 0.45.2;
# quickshell is 0.2.1 git). So this spec only makes sense in a COPR that ALSO builds hyprland 0.57.x,
# its hyprwm libraries and quickshell 0.3.2, or that chains to a COPR which does.
# Same blocker as the PKGBUILD: state must move out of /usr/share/hyprk first.
Name:           hyprk
Version:        0.1.0
Release:        0.1%{?dist}
Summary:        macOS 27-look desktop on Hyprland (no Apple assets)
License:        TBD
URL:            https://example.invalid/hyprk
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++ >= 15, cmake >= 3.27, ninja-build, pkgconf-pkg-config
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
hyprk: a Quickshell shell, a Liquid Glass Hyprland plugin, a Qt Finder and a System Settings app styled after
macOS 27. Ships no Apple fonts, wallpapers, icons or sounds; users may add their own (packaging/README.md).

%prep
%autosetup

%build
%cmake -S finder -B build-finder -G Ninja
%cmake_build --dir build-finder
%cmake -S plugin -B build-plugin -G Ninja
cmake --build build-plugin --target liquidglass

%install
mkdir -p %{buildroot}%{_datadir}/hyprk
cp -a config dist finder lockscreen scripts settings shell themes sounds ui %{buildroot}%{_datadir}/hyprk/
install -Dm755 build-finder/hyprk-finder %{buildroot}%{_datadir}/hyprk/finder/build/hyprk-finder
install -Dm755 build-plugin/libliquidglass.so %{buildroot}%{_datadir}/hyprk/plugin/build/libliquidglass.so
sed -i 's|/mnt/code/hyprk|%{_datadir}/hyprk|g' %{buildroot}%{_datadir}/hyprk/lockscreen/hyprlock.conf
mkdir -p %{buildroot}%{_datadir}/hyprk/dev && echo ': # distro Hyprland' > %{buildroot}%{_datadir}/hyprk/dev/env.sh
# /usr/bin/hyprk-session and /usr/share/wayland-sessions/hyprk.desktop: same content as in packaging/arch/PKGBUILD

%files
%{_datadir}/hyprk
