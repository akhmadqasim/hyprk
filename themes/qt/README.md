# MacOS27 Qt theme

qt6ct palette + QSS on top of the Fusion style, same colours as `../gtk`. Light and dark.
- `build.py` generates `colors/*.conf` (qt6ct palettes) and `qss/*.qss` from `src/macos.qss.in`.
- `install.sh` copies them to `~/.config/qt6ct` (only when you run it). Needs `apt install qt6ct`.
- `build_kvantum.py` (called by `build.py`) generates the Kvantum themes `kvantum/MacOS27Light|Dark` (kvconfig + SVG sprite sheet made of exact-bounds rounded 3x3 frames, capsule buttons, rounded translucent menus). Use `install.sh --kvantum`; needs `qt6-style-kvantum`. qt6ct palette+QSS stays the fallback when Kvantum is not installed.
- Kvantum limits: default push button is not accent-filled (Kvantum draws it through an indicator element that cannot be a 3-patch), no menu shadow, no real blur (Hyprland does not expose the KDE blur protocol to Qt).
- Test: `tools/gallery.cpp` (Qt6 widget gallery) + `tools/qshot.sh OUT.png light|dark [main|menu|combo]` (`KV=1` for the Kvantum theme; Kvantum plugin and libKF6WindowSystem from extracted debs in /tmp/claude-1000/qtroot) (private headless Hyprland, see `../gtk/tools/hypr-headless.sh`).
- Limits of the QSS path: QMenu corners are not transparent (Qt cannot do that from QSS on Wayland), no blur, window titlebars come from the compositor. Kvantum fixes the menu corners.
- Fonts: qt6ct conf uses `SF Pro` / `SF Mono` (real family names from `themes/fonts/named`); `install.sh` also drops `fontconfig/conf.d/60-hyprk-sf.conf` (template `themes/fontconfig/60-hyprk-sf.conf.in`, fallback Inter then Cantarell).
- Title bars: Qt apps have no client-side decorations on Hyprland, they only get Hyprland's border. `hyprbars.lua` is a proposal (not built, not tested) for a macOS style bar with traffic lights via the hyprbars plugin; third-party plugin code needs your OK to build.
