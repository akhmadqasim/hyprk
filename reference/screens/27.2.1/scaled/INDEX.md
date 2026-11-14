# Scaled display mode, macOS 27.2.1 (round 3, R3.3)

Mode: Displays > "More Space" (the largest of the 5 sizes offered for the 15" built-in panel) = **1920x1243 pt, backing
3840x2486 px (2x)**, scaled down to the 2880x1864 panel. `screencapture` returns backing pixels (3840x2486 full screen),
so 1 pt = 2 px in these files, as in the other folders. Dark, wallpaper TahoeDark, other apps hidden, desktop icons hidden.
The 5 sizes in Displays, left to right: Larger Text, 1280x828?, 1440x932, Default = 1710x1107, More Space = 1920x1243
(from the 2x mode list: 1024x663, 1280x828, 1440x932, 1710x1107, 1920x1243).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| more-space-dock.png | full screen `screencapture -x`, crop px 1260,2360 1320x126 | the Dock (tile area), tilesize 31 | dark | TahoeDark |
| more-space-menu.png | full screen 1.2 s after a click on "File", crop px 0,0 780x1480 | Finder File menu open (menu bar strip included) | dark | TahoeDark |
| more-space-settings.png | window `screencapture -x -o -l` (1480x1250 px) | System Settings > Appearance with cards; Apple Account / Family rows filled with the sidebar colour | dark | TahoeDark |
| more-space-spotlight-close.mov | `screencapture -x -v -V 2.5 -R 560,100,800,400`, 1.22 s (last change) | Spotlight open (empty pill), Esc at about 0.5 s, close animation | dark | TahoeDark |
