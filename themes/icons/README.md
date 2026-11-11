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
where Apple ships one, 15 apps), `system/` (folders, Trash, file types; `GenericFolderIcon` is macOS 27's
run-time folder, back flap + front flap from CoreTypes' `Assets.car`, sRGB, built by `tools/build-folder.py`; the
17 special folders (Documents, Downloads, Desktop, Applications, ...) are that folder with their SF Symbol embossed
by IconServices' recipe, same tool; none needs a tint, and the Finder tints tagged folders at run time by
IconServices' rule (`finder/src/sysicons.cpp`). `SmartFolderIcon`, `SystemFolderIcon` and `OpenFolderIcon` are
still the older `.icns` art, and no folder has the Mac's drop shadow), `settings/` (real System
Settings pane icons, `<pane>@<64|128>-<light|dark>.png`, see `panes.json`), `sf-symbols/` (SF Symbols
rendered on macOS 27.2.1: `svg/`, `names.json`; `sf.js` is generated from them by `tools/gen-sf.mjs` and
used by the shell and Finder through symlinks), `tools/` (`car.py` Assets.car reader, `build-apps.py`, `build-styles.py` + `iconstack.py` + `dmp2.py` +
`check-styles.py` + `glass.py` for the styles, `gen-map.mjs`, `gen-sf.mjs`).
3. **Styles** (Settings > Appearance > Icon & widget style, `iconStyle` + `iconStyleVariant` in
   `state/appearance.json`): `default`, `dark`, `clear`, `tinted`.
   - macOS icons: their own renditions `apps/<Name>-256-<style>-<mode>.png` (`dark-dark`, `clear-light`,
     `clear-dark`, `tinted-light`, `tinted-dark`), picked by `styled()` in `apple-map.js` (shell
     `Apps.iconUrl(..., Theme.iconLook)`, Finder `FileIcon.qml`). Dark + Auto in light mode is the Default icon.
     System icons (Downloads, Trash, folders) keep their Default file: the Mac's Dark-style Dock shows them in
     colour too (`reference/screens/27.2.1/dock/dock-dark.png`; no Mac shot of them in Clear / Tinted).
     macOS 27.2.1 keeps no bitmap for these styles: each app's `Assets.car` has the Default bitmap plus the
     Icon Composer layers (`*.iconstack`, groups, SVG and deepmap2 bitmap layers, fills per appearance:
     DarkAqua, Aqua, ISAppearanceTintable), which IconRendering composes at run time.
     `tools/build-styles.py` composes them with `tools/icr.py`, a port of IconRendering's own composition (27.2.1;
     render graph, addresses and parameters in `reference/ASSETS.md` "IconRendering composition";
     `tools/icr-params.json` is `ICRRenderingParameters.default`): chiclet gradient, per group the baked shadow,
     translucency, contents and the highlights / darklights of the `glassHighlight` kernel through the vibrant
     colour matrix, chiclet highlights, outline; Dark = colour mode on the DarkAqua stack, TintedDark = the
     tintable stack baked grey, duotone to the tint, screened over the plate, ClearDark = the lighten / darken /
     highlights masks over the plate (the mitigated version, which is what IconServices' stills are).
     TintedLight / ClearLight stay FITTED to the Mac's Dock (flat luminance ramp + `glass.py`'s fitted rim): there
     the masks act on live glass, and the port over a fixed plate fits the Dock shot worse.
     `tools/check-styles.py`: rms against the Mac's Dock at 66 px (Dark 5-11, mean of the Dark Dock shot 11.4 ->
     9.8 -> 6.2 after the second pass; Clear 3-9, Tinted 8-15 unchanged; Apple's own Default bitmap 6-14 on the same
     shots) and against the Siri / Spotlight Settings tiles at 128 px (Dark 7.1 / 7.6, TintedDark 8.3 / 8.2,
     ClearDark 7.6 / 7.0, ClearLight 6.9 / 6.7 and TintedLight 7.4 / 8.3 by the port's mitigated version). Against
     the Mac's Cmd-Tab (the shipped size, 8 icons) the Dark files are 4.9-18.5, mean 8.7 (was 12.4). Second pass
     (2026-11-11, all in `reference/ASSETS.md`): the translucency gradient ran sideways in colour mode, the group
     shadow is a blurred ring (no darkening over a group's interior), a layer's gradient spans the layer's bounds,
     layers blend with their own blend mode inside a group, the SDF is the layers' solid shape, the automatic
     gradient is IconRendering's. Fitted, measured or assumed inside the port, each marked in `icr.py` /
     `iconstack.py`: the SDR tone curve of the clear stills, the side of the shadow ring, Gaussian sigma =
     RenderBox's blur radius, BT.709 grey bake, the distance field itself. 256 px only: the shell draws app icons
     at most 128 pt, and a render at the Dock's own size class is no closer to the Mac's Dock than the scaled
     file (7.1 against 6.2).
   - Linux icons (`AppIconTile.qml`): the Mac's rule for icons without layers (WebStorm, Spotify in the same Mac
     shot): Dark leaves them as they are (on the dark tile), Clear / Tinted map the art's luminance L with the same
     ramp as above (`ui/HyprK/shaders/iconart.frag`, one quad over the art's own texture, built only while the
     style is on): Tinted rgb (-84 + 198 L, 83 + 158 L, 189 + 66 L) on a flat sRGB 0,109,195 tile, Clear white at
     alpha (182 + 72 L - 176) / 79 on a flat white 0.20 tile. Same in dark appearance (the Apple renditions have no
     dark files either). Icons that already are squircles are mapped whole, as the Mac maps WebStorm's.

Used by the Dock, Apps (Launchpad), Cmd+Tab, Spotlight (`AppIcon.qml`), Finder's Applications
view and Settings' app lists (`AppIconTile.qml` in the shared HyprK module, `ui/HyprK`).

Installer hook for `dist/` / packaging: run `themes/icons/install.sh` (optional, needs curl),
then `themes/icons/build-apple-theme.sh` (no-op without Apple icons), and export the same
`QS_ICON_THEME` / `XDG_DATA_DIRS` lines as `config/hypr/start.sh`.
