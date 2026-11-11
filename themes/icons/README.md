# App icons

macOS 26/27 draws every app icon as the same squircle. hyprk does the same on any distro:

1. **Icon theme** (what the shell looks up), first found wins, chosen in `config/hypr/start.sh`
   through `QS_ICON_THEME`:
   - `hyprk-apple`: layer with the extracted macOS icons (`build-apple-theme.sh`, names in
     `apple-map.txt`). The Apple artwork is tracked in this private repo on purpose (commit f6ca83b,
     `.gitignore`, CONTRIBUTING.md "Assets"): never make the repo public and never copy these files
     into a public repo or package. They come from your own IPSW (`reference/ASSETS.md`).
     It inherits WhiteSur, then your system theme.
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

`apple-map.txt` is the one table that says which macOS icon stands for a Linux app. The shell
(`shell/lib/macicons.js`) and the Finder (`finder/qml/lib/macicons.js`) import the generated
`apple-map.js` through symlinks, and `build-apple-theme.sh` builds the theme from the same file:
after editing it run `node themes/icons/tools/gen-map.mjs && themes/icons/build-apple-theme.sh`.

Files: `apps/<Name>-{1024,512,128}.png` (all 72 are real renditions from `Assets.car`, 1024 px only
where Apple ships one, 15 apps), `system/` (folders, Trash, file types), `settings/` (real System
Settings pane icons, `<pane>@<64|128>-<light|dark>.png`, see `panes.json`), `sf-symbols/` (SF Symbols
rendered on macOS 27.2.1: `svg/`, `names.json`; `sf.js` is generated from them by `tools/gen-sf.mjs` and
used by the shell and Finder through symlinks), `tools/` (`car.py` Assets.car reader, `build-apps.py`, `build-styles.py` + `iconstack.py` + `dmp2.py` +
`check-styles.py` for the styles, `gen-map.mjs`, `gen-sf.mjs`).
3. **Styles** (Settings > Appearance > Icon & widget style, `iconStyle` + `iconStyleVariant` in
   `state/appearance.json`): `default`, `dark`, `clear`, `tinted`.
   - macOS icons: their own renditions `apps/<Name>-256-<style>-<mode>.png` (`dark-dark`, `clear-light`,
     `tinted-light`), picked by `styled()` in `apple-map.js` (shell `Apps.iconUrl(..., Theme.iconLook)`, Finder
     `FileIcon.qml`). Dark + Auto in light mode is the Default icon; Clear / Tinted Dark fall back to Light.
     macOS 27.2.1 keeps no bitmap for these styles: each app's `Assets.car` has the Default bitmap plus the
     Icon Composer layers (`*.iconstack`, groups, SVG and deepmap2 bitmap layers, fills per appearance:
     DarkAqua, Aqua, ISAppearanceTintable), which IconRendering composes at run time.
     `tools/build-styles.py` (with `iconstack.py`, `dmp2.py`) renders those layers flat (no Liquid Glass pass):
     Dark = the DarkAqua layers as they are; Clear / Tinted = the tintable layers mapped by luminance with a
     tile colour and glyph ramp fitted to the Mac's ClearLight / TintedLight Dock (blue accent). Rms against the
     Mac's Dock at 66 px: `tools/check-styles.py` (Dark 6-15, Clear 3-9, Tinted 8-15; Apple's own Default
     bitmap scores 6-14 on the same shots). 256 px only: the shell draws app icons at most 128 pt.
   - Linux icons on the generated tile (`AppIconTile.qml`): tile colours per style and a monochrome glyph.
     The Mac's rule for icons without layers (WebStorm, Spotify in the same Mac shot): Dark leaves them as
     they are, Clear / Tinted map their luminance with the same ramp as above.

Used by the Dock, Apps (Launchpad), Cmd+Tab, Spotlight (`AppIcon.qml`), Finder's Applications
view and Settings' app lists (`AppIconTile.qml` in the shared HyprK module, `ui/HyprK`).

Installer hook for `dist/` / packaging: run `themes/icons/install.sh` (optional, needs curl),
then `themes/icons/build-apple-theme.sh` (no-op without Apple icons), and export the same
`QS_ICON_THEME` / `XDG_DATA_DIRS` lines as `config/hypr/start.sh`.
