# hyprk dependencies

Found by grepping the repo (commands in QML `Process`, scripts, CMake, Lua config) on 2026-11-10.
`install.sh` holds the same lists in `pkgs()` (source of truth; the table below is a summary).
Package names were checked inside official containers, see "Verified" at the end.

## Inventory

### Compositor stack

| Need | Min | Used by |
|---|---|---|
| Hyprland | 0.57.0 (Lua config, 0.57 APIs; tested 0.57.2) | `config/hypr/hyprland.lua`, `hyprctl` in shell/settings/scripts |
| Hyprland headers (`hyprland.pc`), hyprutils, pixman, libdrm | same build as the running Hyprland | `plugin/CMakeLists.txt` |
| Quickshell (`qs`/`quickshell`) | 0.3.2 tested | shell/, settings/. Modules: Quickshell, .Io, .Wayland, .Hyprland, .Widgets, .Bluetooth, .Networking, .Services.{Pipewire,Mpris,Notifications,UPower} |
| hyprlock | 0.9 (tested 0.9.7, `lockscreen/install.sh` says 0.9.2 reads the config) | lockscreen/ |
| hypridle | any | settings LockScreen pane, lockscreen/hyprk-lock.sh (optional) |
| Xwayland | any | X11 apps |

### Qt (Finder, Settings fallback, shell)

Qt >= 6.5 (`finder/CMakeLists.txt`), Qt Wayland, QtDeclarative with QML modules QtQuick, QtQuick.Controls.Basic,
QtQuick.Layouts, QtQuick.Window, QtQuick.Shapes, QtQuick.Effects, QtCore, Qt.labs.folderlistmodel, plus Qt SVG
(image plugin). Build: Qt6 Core/Gui/Qml/Quick dev, CMake >= 3.21 (Finder) / >= 3.27 (plugin), Ninja, a C++26
compiler for the plugin (GCC >= 15).

### Runtime commands

| Command | Package role | Used by | Missing = |
|---|---|---|---|
| `magick` (ImageMagick 7) | wallpaper scaling, blur, luma; settings thumbnails | `shell/scripts/wallpaper.sh`, `settings/scripts/thumbs.sh` | solid material, no blur |
| `jq` | state JSON in scripts and binds | `shell/scripts/sound.sh`, `hyprland.lua` | defaults |
| `pw-play`, `pw-mon`, `wpctl` (PipeWire + WirePlumber) | sounds, volume keys, Sound pane | `sound.sh`, `hyprland.lua`, `settings/panes/Sound.qml` | silent / no volume keys |
| `paplay` | sound fallback | `sound.sh` | optional |
| `brightnessctl` | brightness keys, CC slider | `hyprland.lua`, shell | slider hidden |
| `nmcli` (NetworkManager) | Wi-Fi pane, menu bar | settings, shell | dimmed |
| `bluetoothctl` (BlueZ) | Bluetooth pane | settings | dimmed |
| UPower (D-Bus) | battery | shell (Quickshell.Services.UPower) | hidden |
| `grim`, `slurp` | screenshots | `hyprland.lua` | no screenshots |
| `swaybg` or `hyprpaper` | Settings wallpaper apply | `settings/scripts/set-wallpaper.sh` | shell wallpaper still works |
| `python3` + Pillow | lock screen initials avatar | `lockscreen/scripts/initials-avatar.py` | default avatar |
| `pdftoppm` (poppler) | PDF thumbnails | `finder/src/thumbnails.cpp` | generic icon |
| `gio` (GLib) | trash, app launch | `finder/src/fileops.cpp`, `shell/services/Apps.qml` | no trash |
| `xdg-user-dir` | Pictures/Downloads dirs | shell, `hyprland.lua` | `$HOME/Pictures` |
| `loginctl`, `systemctl` (systemd or elogind) | sleep, restart, shut down, lock | `shell/services/Power.qml` | power menu fails |
| `fc-match` (fontconfig) | avatar font | lockscreen | default avatar |
| `gsettings`, `dconf` | GTK theme install (optional) | `themes/gtk/install.sh`, dist | keyfile backend is used |
| `qt6ct`, Kvantum | Qt app theme (optional) | `themes/qt/install.sh`, dist | Qt default look |
| terminal: `ghostty` (default, `HYPRK_TERMINAL`) or `foot`/`kitty` | | `hyprland.lua` | set `HYPRK_TERMINAL` |
| D-Bus session bus | notifications, MPRIS, BlueZ, NM | Quickshell services | |
| `node` | tests only (`*/tests`) | dev | |

Dev/test only (not installed by install.sh): `python3-fonttools`, `ffmpeg`, `icnsutils`, `libheif-examples`
(asset extraction, `reference/ASSETS.md`), `fastfetch`, `pkill`-free test rigs in `plugin/test`, `themes/gtk/tools`.

### Free fonts and themes (no Apple assets)

Inter (UI), DejaVu (fallback, mono), Adwaita icon theme + cursors. Optional: JetBrains Mono.

## Per-distro package map

`runtime` + `build` are always installed. `hypr`/`qs` only when the distro version is new enough
(otherwise the source build, which adds `srcbuild`).

| Role | Debian/Ubuntu (apt) | Arch (pacman) | Fedora (dnf) | openSUSE (zypper) |
|---|---|---|---|---|
| Hyprland + headers | hyprland hyprland-dev libhyprutils-dev | hyprland (headers included) | none in Fedora 43 (source build or a COPR) | hyprland hyprland-devel hyprutils-devel |
| Quickshell | quickshell | quickshell | none in F43 (F44+: 0.2.1-git, too old) | none (source) |
| lock / idle | hyprlock hypridle | hyprlock hypridle | hyprlock hypridle | hyprlock hypridle |
| Qt runtime | qt6-wayland, qml6-module-qtquick{,-controls,-layouts,-window,-shapes,-effects,-templates}, qml6-module-qtqml-workerscript, qml6-module-qtcore, qml6-module-qt-labs-folderlistmodel, qt6-svg-plugins | qt6-wayland qt6-declarative qt6-svg | qt6-qtwayland qt6-qtdeclarative qt6-qtsvg | qt6-wayland qt6-declarative-imports libQt6Svg6 |
| images | imagemagick | imagemagick | ImageMagick | ImageMagick |
| audio | pipewire-bin wireplumber | pipewire wireplumber | pipewire-utils wireplumber | pipewire-tools wireplumber |
| net / bt / power | network-manager bluez upower brightnessctl | networkmanager bluez bluez-utils upower brightnessctl | NetworkManager bluez upower brightnessctl | NetworkManager bluez upower brightnessctl |
| screenshots, wallpaper | grim slurp swaybg | grim slurp swaybg | grim slurp swaybg | grim slurp swaybg |
| misc | jq python3 python3-pil poppler-utils libglib2.0-bin xdg-user-dirs fontconfig dbus-user-session | jq python python-pillow poppler glib2 xdg-user-dirs fontconfig | jq python3 python3-pillow poppler-utils glib2 xdg-user-dirs fontconfig | jq python3 python3-Pillow poppler-tools glib2-tools xdg-user-dirs fontconfig |
| fonts, icons | fonts-inter fonts-dejavu-core adwaita-icon-theme | inter-font ttf-dejavu adwaita-icon-theme | rsms-inter-fonts dejavu-sans-fonts adwaita-icon-theme | inter-fonts dejavu-fonts adwaita-icon-theme |
| terminal, Qt theme, X | foot qt6ct xwayland | foot qt6ct xorg-xwayland | foot qt6ct xorg-x11-server-Xwayland | foot qt6ct xwayland |
| build | build-essential cmake ninja-build pkg-config git qt6-base-dev qt6-declarative-dev libpixman-1-dev libdrm-dev | base-devel cmake ninja pkgconf git qt6-base pixman libdrm | gcc-c++ cmake ninja-build pkgconf-pkg-config git qt6-qtbase-devel qt6-qtdeclarative-devel pixman-devel libdrm-devel | gcc-c++ cmake ninja pkgconf git qt6-base-devel qt6-declarative-devel libpixman-1-0-devel libdrm-devel |

Source-build `-dev` lists (about 60 packages each) are in `install.sh` (`pkgs <family> srcbuild`), taken from the
dev prefix's `APT-INSTALLED.txt` and translated.

Other distros: Gentoo (GURU has quickshell 0.3.2), Void (quickshell 0.3.2), Alpine (hyprland 0.54.3 on edge,
too old), NixOS (see `nix/flake.nix`): install.sh prints the inventory and wants `--no-deps`.

## Repo versions (2026-11-10)

| Distro | Hyprland | Quickshell | hyprlock | Path |
|---|---|---|---|---|
| Arch (extra) | 0.57.2 | 0.3.2 | 0.9.7 | distro packages |
| Manjaro / EndeavourOS | follows Arch (Manjaro stable lags a few weeks, not checked) | | | distro, else source |
| Debian sid / forky | 0.57.0 | 0.3.2 | 0.9.7 | distro packages |
| Debian trixie | 0.55.2 (backports) | 0.3.0 (backports) | ? | source; needs GCC 15 (trixie has 14) so effectively unsupported |
| Ubuntu 26.04 | 0.53.3 | none | 0.9.2 | source (Hyprland stack + hyprlock + Quickshell) |
| Ubuntu 26.10 | 0.56.2 | 0.3.0 | 0.9.6 | source |
| Ubuntu 27.04 (dev) | 0.57.0 | 0.3.0 | ? | Hyprland distro, Quickshell source |
| Fedora 43 | none (F42 had 0.45.2) | none (F44+: 0.2.1-git) | none | source, or a COPR |
| openSUSE Tumbleweed | 0.57.1 | none | 0.9.6 | Hyprland + hyprlock distro, Quickshell source |
| nixpkgs unstable | 0.57.x | 0.3.2 | ? | flake |
| Alpine edge | 0.54.3 | none | ? | source (musl, untested) |

Sources: archlinux.org/packages, tracker.debian.org, packages.ubuntu.com, packages.fedoraproject.org,
repology.org, nixpkgs master `package.nix` files, pkgs.alpinelinux.org. COPR pages could not be read (bot check).

## Verified (2026-11-10, unprivileged official containers, `packaging/install.sh --print-deps` names)

Every name in all five lists (runtime, build, hypr, qs, srcbuild) was looked up in the repo metadata
(`apt-cache show`, `pacman -Si`/`-Sg`, `dnf repoquery` incl. provides, `zypper info`/`se --provides`):

| Image | Result |
|---|---|
| archlinux:latest | all found after `libseat` -> `seatd`. hyprland 0.57.2, quickshell 0.3.2, hyprlock 0.9.7: no source build |
| debian:sid | all 115 found. hyprland 0.57.0, quickshell 0.3.2, hyprlock 0.9.7: no source build |
| ubuntu:26.04 | all found except `quickshell` (expected, it is then built). Hyprland 0.53.3 -> full source build |
| ubuntu:26.10 | all found. Hyprland 0.56.2, Quickshell 0.3.0 -> source build |
| fedora:43 | missing as expected: hyprland, hyprland-devel, hyprlock, hypridle, quickshell (all built). `glaze-devel` is not packaged: removed; Hyprland's hyprpm may need glaze, not checked |
| opensuse/tumbleweed | fixed `qt6-svg` -> `libQt6Svg6`, `pixman-devel` -> `libpixman-1-0-devel`, `libseat-devel` -> `seatd-devel`. hyprland 0.57.1, hyprlock 0.9.6, lua55-devel 5.5.0; no quickshell -> source |

Not verified: Manjaro/EndeavourOS repos, Debian trixie, Leap, Fedora 44/rawhide, that every srcbuild list is
complete enough for a real build (only the Ubuntu list was used for a real build, in the dev prefix).
