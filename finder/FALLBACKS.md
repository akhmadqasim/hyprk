# Finder fallbacks

What the Finder does when a macOS-like resource is missing.

| Missing | Fallback | Where |
|---|---|---|
| Thumbnail | `image://thumb` (worker threads, never the UI thread): freedesktop cache `~/.cache/thumbnails/{x-large,large,normal}`, then our cache `~/.cache/hyprk-finder/thumbnails/<md5 uri>-<mtime>.png`, then generation at 512 px: images via QImageReader, PDFs via `pdftoppm` (first page). Videos only show a thumbnail when GNOME already cached one. Empty files and anything else get the file-type icon. | `src/thumbnails.cpp`, `qml/FileIcon.qml` |
| File-type icons | macOS PNGs from `themes/icons/system` (GenericDocumentIcon with an extension badge, GenericFolderIcon, Documents/Downloads/Desktop/... folder icons, GenericApplicationIcon). If that folder is missing, original drawn SVG folder/document icons. | `qml/Theme.qml` (`sysIcon`, `folderIcons`), `qml/lib/icons.js` |
| App icon (Applications) | `QIcon::fromTheme` in the current theme, then Adwaita, then hicolor. XDG `icons` dirs are added to the search path because Qt only searches `:/icons` without a platform theme. If nothing is found, the generic document icon. | `src/main.cpp` (`IconProvider`) |
| SF Pro | `themes/fonts/SFNS.ttf` is registered at start (family "System Font"). If it is absent: Inter, then Cantarell, then the default sans. SF is a variable font whose default optical size is display (opsz 28), so text pins `opsz 17` and sets `wght` through `font.variableAxes`; other fonts ignore the axes. | `qml/Theme.qml` (`pickFont`), `src/main.cpp` (`loadFonts`) |
| Blur behind the window | Solid sidebar `#EDEDED` (dark `#272727`, the 27.2.1 Finder), which is also what the reference screenshot shows. Set `HYPRK_BLUR=1` only when the compositor blurs behind the window (Hyprland windowrule for class `hyprk-finder`), then the sidebar uses the 27.2.1 sidebar glass fill (light 0.87/0.88/0.91 at 70%, dark 0.15 at 75%). | `qml/Theme.qml` (`sidebarSolid`, `sidebarGlass`) |
| Window shadow | None drawn by the app (an in-window shadow would need a margin and break tiling). The compositor draws it. | `qml/Main.qml` |
| Rounded corners | The frame, sidebar and content corners are drawn with a 22 px radius on a transparent window. If the compositor does not support alpha, the corners show its background. Maximized windows drop the radius and border. | `qml/Main.qml` |
| SF Symbols | The real outlines from `themes/icons/sf-symbols` (`qml/lib/sf.js`, a symlink to the generated `sf.js`) are tinted SVG data URLs, so they also work with the software backend. Names without an SVG (`zoom`) use the original 24x24 glyphs. | `qml/lib/symbols.js` |
| Trash | `gio trash`, run asynchronously so the UI never blocks. When it fails (for example tmpfs or a mount without trash support) the item stays and an alert shows the reason. | `FileOps::trash` |
| Share sheet | No Linux equivalent: Share opens the selection. | `qml/Toolbar.qml` |
| Tags | Stored in the xattr `user.xdg.tags`; on filesystems without user xattrs they live in `~/.local/share/hyprk-finder/tags.json`. That JSON also indexes every path tagged from the Finder, which is what the sidebar tag lists show (files tagged by other tools are not indexed). Tag from the toolbar Tag button or the context menu dots (click toggles). | `src/fileops.cpp` (`tags`, `setTags`) |
| Shared, iCloud Drive, AirDrop | Sidebar placeholders that do nothing; AirDrop is dimmed. | `qml/Sidebar.qml` |
