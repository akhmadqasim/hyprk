# Finder fallbacks

What the Finder does when a macOS-like resource is missing.

| Missing | Fallback | Where |
|---|---|---|
| Thumbnail | Image files decode directly (`Image`, async, `sourceSize` capped at 2x icon size). Other types use the freedesktop cache (`~/.cache/thumbnails/{large,normal}/<md5 uri>.png`) when GNOME already made one. Otherwise a drawn icon: blue folder, or the generic white document with the file extension badge (ZIP gets a zipper). A thumbnail that fails to load also falls back to the drawn icon. | `qml/FileIcon.qml`, `qml/lib/icons.js`, `FileOps::thumbnail` |
| App icon (Applications) | `QIcon::fromTheme` in the current theme, then Adwaita, then hicolor. XDG `icons` dirs are added to the search path because Qt only searches `:/icons` without a platform theme. If nothing is found, the generic document icon. | `src/main.cpp` (`IconProvider`) |
| SF Pro | `themes/fonts/SFNS.ttf` is registered at start (family "System Font"). If it is absent: Inter, then Cantarell, then the default sans. SF is a variable font whose default optical size is display (opsz 28), so text pins `opsz 17` and sets `wght` through `font.variableAxes`; other fonts ignore the axes. | `qml/Theme.qml` (`pickFont`), `src/main.cpp` (`loadFonts`) |
| Blur behind the window | Solid sidebar `#EDEDED` (dark `#2B2B2D`), which is also what the reference screenshot shows. Set `HYPRK_BLUR=1` only when the compositor blurs behind the window (Hyprland windowrule for class `hyprk-finder`), then the sidebar uses a 62% tint. | `qml/Theme.qml` (`sidebarSolid`, `sidebarGlass`) |
| Window shadow | None drawn by the app (an in-window shadow would need a margin and break tiling). The compositor draws it. | `qml/Main.qml` |
| Rounded corners | The frame, sidebar and content corners are drawn with a 22 px radius on a transparent window. If the compositor does not support alpha, the corners show its background. Maximized windows drop the radius and border. | `qml/Main.qml` |
| SF Symbols | Original 24x24 glyphs drawn as SVG paths (rendered by Qt SVG, so they also work with the software backend). | `qml/lib/symbols.js` |
| Trash | `gio trash`, run asynchronously so the UI never blocks. When it fails (for example tmpfs or a mount without trash support) the item stays and an alert shows the reason. | `FileOps::trash` |
| Share sheet, Tags | No Linux equivalent wired yet: Share opens the selection, the Tag button is disabled, sidebar tags are display only. | `qml/Toolbar.qml`, `qml/Sidebar.qml` |
