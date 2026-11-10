# App icons

macOS 26/27 draws every app icon as the same squircle. hyprk does the same on any distro:

1. **Icon theme** (what the shell looks up), first found wins, chosen in `config/hypr/start.sh`
   through `QS_ICON_THEME`:
   - `hyprk-apple`: LOCAL layer with the user's own extracted macOS icons
     (`build-apple-theme.sh`, names in `apple-map.txt`). Apple artwork is never shipped or
     committed (`.gitignore`); it only exists after extracting it from your own IPSW
     (`reference/ASSETS.md`). It inherits WhiteSur, then your system theme.
   - `WhiteSur`: [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme) by
     vinceliuice, **GPL-3.0** (licence checked 2026-11-10 on GitHub and in its `COPYING`), a free
     macOS-like theme. `install.sh` downloads the pinned tag `2026-09-10` (sha256 checked) and
     installs it into the hyprk data prefix `${XDG_DATA_HOME:-~/.local/share}/hyprk/icons`
     (about 100 MB, so it is not in the repo). `install.sh --remove` removes it.
   - otherwise the system icon theme.
2. **Squircle tiles** (`ui/HyprK/AppIconTile.qml`, `ui/HyprK/iconshape.js`): an icon
   that is not already a squircle tile (round, square, free-form logos) is put on a standard
   macOS 26 tile: continuous corner (superellipse n=5), light gradient, rim highlight, soft
   contact shadow, art body at 70% of the tile. Icons that already are squircles are scaled so
   their body matches the macOS icon body (82% of the cell), so all icons line up. The check
   reads the icon's alpha on a 48 px canvas once per file per process (cached): filled share
   of the bounding box >= 0.86, clear corners, square aspect, body >= 60% of the image.
   The extracted macOS icons, folders and the Trash are drawn as they are.
3. **Styles** (Settings > Appearance > Icon & widget style, `iconStyle` in
   `state/appearance.json`): `default` (light tile), `dark` (dark tile), `clear` (translucent
   tile, monochrome art), `tinted` (accent tile, monochrome art).

Used by the Dock, Apps (Launchpad), Cmd+Tab, Spotlight (`AppIcon.qml`), Finder's Applications
view and Settings' app lists (`AppIconTile.qml` in the shared HyprK module, `ui/HyprK`).

Installer hook for `dist/` / packaging: run `themes/icons/install.sh` (optional, needs curl),
then `themes/icons/build-apple-theme.sh` (no-op without Apple icons), and export the same
`QS_ICON_THEME` / `XDG_DATA_DIRS` lines as `config/hypr/start.sh`.
