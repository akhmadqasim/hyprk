# hyprk independent judge, 2026-11-10 03:45

Judge: independent read-only agent. Self-scores in PROGRESS.md were ignored. Bar: 80 = a casual Mac user
mistakes it for macOS at a glance. Pixel numbers measured with Pillow; reference images are at different
scales, so sizes are given relative to screen width where needed.

Fresh shots taken by the judge (dist/try-nested.sh, own session, exited and cleaned, 0 leftover pids):
`ours/judge-finder-window.png` (Finder inside the real session), `ours/judge-windows.png` (Ghostty + Finder + Settings).

## Per-surface scores

| surface | ref image | our image | score | top 3 concrete differences |
|---|---|---|---|---|
| Desktop + menu bar + Dock | screens/macos27-desktop-menubar-dock.jpg, macos27-dock-default.png, macos27-apps-view.png | ours/v7-desktop-mba.png, ours/dist-try.png | 78 | 1) Dock icons too big: ours 42 px icon / 64 px Dock on a 1280 px wide screen (3.3% / 5.0%); ref 31 px / 54 px on 1144 px (2.7% / 4.7%), so icons are ~20% too large, Dock padding is right. 2) Right side of menu bar has only Spotlight + CC + clock; ref always shows battery, Wi-Fi, CC, Siri, then `Wed Apr 1  9:41 AM`. Ours hides Wi-Fi/battery and prints `Tue 10 Nov 03:36` (24h, day-month order). 3) Dock is 7 items with 4 non-Apple glyphs (Launchpad grid, notepad, terminal); ref has ~25 Apple squircle icons, so the strip reads half-empty. Menu bar text, Apple logo, glass Dock tint (+20..30 lift over wallpaper, ref +30) are right. |
| Control Center | screens/macos27-control-center.png | ours/shell-plugin-cc.png, ours/shell-cc-v3.png | 62 | 1) Contrast: our tile fill is ~(196,221,231) under white labels (about 1.4:1, `Wi-Fi`/`Display` almost unreadable); ref tile ~(108,93,86) with white text (~5:1). The glass is far too bright/milky. 2) Shape: big tiles are rounded rects (radius ~20 on a 60 px tile, 0.33h); ref Wi-Fi/Bluetooth/AirDrop/Focus are full capsules (radius = h/2) and small toggles are circles. 3) Display slider shows no fill and no visible track/thumb (dimmed fallback), the Wi-Fi tile is greyed `Not Available`, and the top `FaceTime recently` style pill row is missing. Grid layout and icon circles are right. |
| Notification Center | screens/macos27-notification-center.png | ours/shell-plugin-nc-apps.png (left half) | 70 | 1) Calendar widget is empty (`No events today`) and right half blank; ref fills it with coloured event pills; widget height ours ~140/280 of panel width vs ref ~315/655, same ratio but looks bare. 2) Clock widget is the small square only; ref also shows a large photo widget, so the column is short and ends at ~410 px of 666. 3) Notification banner has a doubled bottom edge (stacked group shows as a second pale strip that misaligns by ~4 px) and its glass is cyan-tinted vs ref neutral white. Edit Widgets + close pills match well. |
| Spotlight (+ Apps view) | screens/macos27-spotlight.png, macos27-apps-view.png | ours/shell-plugin-spotlight.png, ours/shell-plugin-nc-apps.png (right half) | 64 | 1) Result list is the old Sequoia layout: 9 dense 30 px rows with right-aligned grey `Application`; ref uses few, tall (~70 px at its scale) rows with a big icon and an inset rounded grey selection pill. 2) Selection row picks up the wallpaper (yellow-ish) instead of a neutral grey pill with radius; query text 16 px vs ref ~30 px at the same panel width (ref query is the dominant element). 3) Apps view: 7-column grid and placement match, but icons are Linux icons of mixed shapes (no squircle mask), labels truncate (`Advanced Netw...`), and the category header/`...` button is missing. |
| System Settings | screens/macos27-system-settings-appearance.webp | ours/settings-appearance.png | 80 | 1) Sidebar is too dark and blotchy: ours (179,172,167)..(203,199,200), ref flat (238,236,234). 2) Sidebar order: ref starts Wi-Fi, Bluetooth, Network, VPN, Battery, then General; ours starts with General (network group missing at top). 3) Text highlight row lacks the colour swatch before `Automatic`; preview photo shows no title strip; Liquid Glass slider end icons differ. Row pitch (64 px), header, segmented thumbnails, colour dots, icon-style tiles all match closely. |
| Finder | screens/macos27-finder-window.png | ours/finder-icons.png, ours/finder-list.png, ours/judge-finder-window.png | 84 | 1) File icons: blank generic `PDF`/`TXT` page icons where ref shows content thumbnails; several of our PDFs render tiny unreadable thumbnails. 2) Folder colour too saturated/light: ours (122,211,251), ref (113,185,227). 3) Sidebar has extra rows (`demohome`/`akhmadqasim`, `Macintosh HD`) and greyed `AirDrop`, pushing Tags off screen. Toolbar, title, sidebar colour (237,237,237 both), radius, traffic lights match almost exactly. |
| Windows / app theme (GTK, Qt, other apps) | Finder + Settings refs (traffic lights, toolbar) | ours/judge-windows.png, ours/gtk-gallery-light.png, ours/qt-kvantum-light.png | 50 | 1) Ghostty (GTK4) in the real session has traffic lights on the RIGHT in reversed order (min, max, close) and a dark Adwaita header with tab pills; this is the first thing anyone sees. 2) GTK gallery shows two sets of traffic lights (header bar and sidebar), the sidebar set greyed. 3) Qt apps get no title bar/traffic lights at all, use Noto Sans instead of SF Pro, and toolbars are plain text (`Back Forward Share`) with an in-window `File Edit View` menu. Also no traffic lights on plugin-window terminal shots. |
| Lock screen | none (no macOS 27 lock ref found) | ours/lockscreen.png | 62 | 1) Clock is a light/regular weight; macOS 26/27 lock clock is a heavy rounded numeral, much bolder. 2) Uses a different wallpaper (green hills) than the desktop; macOS blurs the desktop wallpaper. 3) No menu bar status (battery/Wi-Fi) top right, and the avatar is a generic grey silhouette. Layout (date over time, avatar + name + pill field near bottom) is right. |

## Weighted overall

| surface | weight | score | weighted |
|---|---|---|---|
| desktop + menu bar + Dock | 25 | 78 | 19.50 |
| Control Center | 10 | 62 | 6.20 |
| Notifications | 10 | 70 | 7.00 |
| Spotlight | 10 | 64 | 6.40 |
| Settings | 15 | 80 | 12.00 |
| Finder | 15 | 84 | 12.60 |
| windows / app theme | 10 | 50 | 5.00 |
| lock | 5 | 62 | 3.10 |
| **overall** | 100 | | **71.8 (72)** |

Target 80 is not met. Finder and Settings are near it, the gap is in app chrome, Control Center and Spotlight.

## Top 10 fixes, ranked by score impact

1. **themes/gtk**: force `gtk-decoration-layout=close,minimize,maximize:` (settings.ini + gsettings/portal in the
   try and session XDG dirs) so libadwaita apps (Ghostty seen) draw traffic lights left in mac order; restyle the
   Adwaita header bar to the Finder toolbar look. (+windows ~15)
2. **themes/gtk**: hide the second set of traffic lights in split views (only the sidebar header or the content
   header shows window controls, not both).
3. **shell/** (Control Center): darken/neutralise the CC glass so white labels read (target tile ~L 100 on a light
   wallpaper or switch labels to dark text on light glass), and make big tiles capsules (radius = h/2) and small
   toggles circles. (+CC ~12)
4. **plugin/**: the `controlcenter`/`regular` material is too bright and cyan on light wallpapers (CC tiles, banners,
   Spotlight); lower lift and remove the cyan tint toward ref neutral glass.
5. **shell/** (Spotlight): new macOS 27 layout: larger query text (~2x), fewer taller rows with big icons, neutral
   inset rounded selection pill, drop the right-aligned `Application` column. (+spotlight ~10)
6. **themes/qt**: SF Pro as the Qt font (qt6ct fonts), and a Hyprland/Kvantum route to a titlebar with traffic
   lights for Qt windows (or hyprbars-style decoration from **plugin/** for any app without CSD).
7. **shell/** (menu bar + Dock): Dock tile 52-54 pt instead of 64 to match ref ratio; show Wi-Fi/battery icons
   (dimmed if absent) and use macOS clock format `Tue Nov 10  3:36 AM`; default Dock with more Apple-style icons.
8. **settings/**: sidebar background to flat ~(238,236,234) with light blur (no dark blotches), and put Wi-Fi,
   Bluetooth, Network, VPN, Battery group first.
9. **shell/** (Notification Center + Apps view): fill Calendar widget (upcoming events or a mini month), add a
   larger photo/weather widget; fix the doubled banner stack edge; squircle-mask Linux icons in Apps view.
10. **lockscreen/**: bold rounded clock weight, desktop wallpaper blurred as background, status icons top right;
    plus **finder/**: folder colour to (113,185,227) and real thumbnails for PDFs/text.
