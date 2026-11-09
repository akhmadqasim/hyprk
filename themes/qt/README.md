# MacOS27 Qt theme

qt6ct palette + QSS on top of the Fusion style, same colours as `../gtk`. Light and dark.
- `build.py` generates `colors/*.conf` (qt6ct palettes) and `qss/*.qss` from `src/macos.qss.in`.
- `install.sh` copies them to `~/.config/qt6ct` (only when you run it). Needs `apt install qt6ct`.
- Kvantum was not used: a Kvantum theme needs a full hand-drawn SVG sprite sheet; QSS gives the capsule/rounded look with less code.
- Test: `tools/gallery.cpp` (Qt6 widget gallery) + `tools/qshot.sh OUT.png light|dark [main|menu|combo]` (private headless Hyprland, see `../gtk/tools/hypr-headless.sh`).
- Limits: QMenu corners are not transparent (Qt cannot do that from QSS on Wayland), no blur, window titlebars come from the compositor.
