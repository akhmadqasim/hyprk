# GTK theme fallbacks

The theme is written so that a missing piece degrades to something usable, never to something broken.

| Wanted | Fallback | Where |
|---|---|---|
| SF Pro (`themes/fonts/SFNS.ttf`, family "System Font" / ".SF NS") | Inter, then Cantarell, then any sans-serif | `font-family` lists at the top of `src/gtk4.css` and `src/gtk3.css`; set the size with `gtk-font-name=SF Pro Text 10` (about 13px, the macOS body size). If SF is not installed GTK just walks the list. |
| SF Mono for monospace | JetBrains Mono, DejaVu Sans Mono | `.monospace` rules |
| Translucent glass (sidebar, toolbar buttons, menus, tooltips) | Opaque colours picked to look like the glass over a light/dark wallpaper (`glass_bg`, `sidebar_bg`, `popover_bg` in `build.py`) | GTK has no backdrop blur. The compositor plugin (`plugin/`) can blur layer surfaces, not GTK widgets, so GTK windows stay solid. |
| macOS window shadow and 16px corners (alerts 26px) | Drawn by GTK on `window.csd`. Maximised/tiled windows drop radius and shadow. Compositor rounding (Hyprland `decoration:rounding`) takes over if CSD is off. | |
| Traffic lights on the left | Need `gtk-decoration-layout=close,minimize,maximize:` in settings.ini AND the same `button-layout` in gsettings (GTK reads gsettings first on Wayland). `install.sh --gsettings` sets it. Without it the buttons stay on the right but keep the round coloured look. | |
| Minimise button | Hyprland does not implement minimise, GTK greys the yellow light out (40% opacity). It stays visible. | |
| Glyphs on the traffic lights (x, -, +) | Only on hover of the group, drawn with inline SVG backgrounds. If the SVG fails to parse the circles stay plain. | `windowcontrols:hover` rules |
| Accent colour | Fixed system blue (#007AFF light, #0A84FF dark). Change `accent_bg` in `build.py` and rerun it. libadwaita's own accent setting is overridden. | |
| Dark mode | GTK4 follows `color-scheme` (prefers-color-scheme media block in `gtk-4.0/gtk.css`). GTK3 uses the `MacOS27-Dark` theme or `gtk-application-prefer-dark-theme`. | |
| Liquid Glass refraction/lensing, Tahoe scroll-edge blur | Not possible in GTK CSS. A 1px hairline appears under the top bar when content scrolls beneath it (libadwaita `.raised`). | |
| Finder-style translucent sidebar selection in System Settings (accent fill) | Finder look (grey) is the default; add class `accent-sidebar` to a parent widget for the System Settings look. | |
