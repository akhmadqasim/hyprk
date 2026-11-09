# hyprk independent judge, round 2 (2026-11-10 ~04:00)

Same rules as JUDGE.md (strict, 80 = a casual Mac user mistakes it for macOS at a glance, owners' self-scores
ignored). Shots used: ours/shell-final-*.png (03:56), settings-*.png (03:53, 1490x1260), finder-*.png (03:54),
gtk-*/qt-*/lockscreen.png (03:56), plugin-shell-cc.png (03:55), dist-try-ghostty.png (03:58, real try-nested
session). No new judge shots were needed: Ghostty was shot fresh in both the themes rig and the dist session.

## Per-surface scores

| surface | ref image | our image | r1 | r2 | top 3 concrete differences still left |
|---|---|---|---|---|---|
| Desktop + menu bar + Dock | screens/macos27-desktop-menubar-dock.jpg, macos27-apps-view.png | ours/shell-final-desktop.png, shell-final-desktop-dark.png | 78 | 80 | 1) Dock icons still ~25% too big: Finder icon 86 px on a 2560 px screen (3.4%) vs ref 2.7%. 2) Clock still `Tue 10 Nov 03:56` (24h, day before month) vs ref `Wed Apr 1  9:41 AM`. No battery icon (Wi-Fi now shown, crossed out). 3) Dock has 8 items, 3 of them non-Apple glyphs (notepad, two terminals that look alike), so the strip looks sparse next to the ref's ~25. |
| Control Center | screens/macos27-control-center.png | ours/shell-final-control-center.png, plugin-shell-cc.png | 62 | 75 | Fixed: tiles are capsules and circles now, fill ~(91,96,100) with white labels (readable). Left: 1) Display slider has no fill (brightness missing), and Wi-Fi is greyed `Not Available`, so two of six controls look dead. 2) Glass reads as flat dark grey slabs over a white window. The ref is lighter and more translucent (about (108,93,86) over a mid-tone wallpaper) with a visible rim highlight. 3) No top `recently used` pill. The panel overlaps the Finder toolbar with no gap or shadow separating it. |
| Notification Center | screens/macos27-notification-center.png | ours/shell-final-notification-center.png, shell-final-banner.png | 70 | 75 | Fixed: month grid, bigger clock, photo widget. Left: 1) Calendar widget is see-through: Finder labels (`Downloads`, `env`) show through behind `No events today`. The ref widget is opaque white. 2) The left half of the calendar is still empty (no event pills). 3) `Edit Widgets` and `x` pills have no visible background over a white window. Banners show a generic icon instead of the app icon. |
| Spotlight (+ Apps view) | screens/macos27-spotlight.png, macos27-apps-view.png | ours/shell-final-spotlight.png, shell-final-apps.png | 64 | 74 | Fixed: section headers, tall rows with big icons, neutral grey selection pill, larger query, squircle icon tiles and `...` in Apps. Left: 1) Over a white window the panel is almost opaque white with cyan blurred smudges of the icons behind. The ref glass is a warm translucent tint with even frosting. 2) The query field has no capsule background and the separator runs full width. The ref has a tokenised query and a thin inset divider. 3) Apps view still shows Linux icons (pale `Disks`, three identical `Foot` icons) and truncated labels. |
| System Settings | screens/macos27-system-settings-appearance.webp | ours/settings-appearance.png | 80 | 85 | Fixed: sidebar is now flat (238,236,234), exactly the ref. A Wi-Fi/Bluetooth/Network/VPN group comes first, and a highlight swatch was added. Left: 1) Sidebar icons are coloured. The ref (Clear style) uses grey glyph tiles, but the coloured icons match the Default style, so this costs only a little. 2) An extra `User / Linux Account` row sits in the sidebar (ref has none here). It says `Energy` where the ref says `Battery`. 3) The preview title strip reads `Default Aerial` in a much larger weight than the ref `Welcome to Apple Park`, and the Liquid Glass slider's right-end icon differs. |
| Finder | screens/macos27-finder-window.png | ours/finder-icons.png, finder-list.png, shell-final-desktop.png | 84 | 87 | Fixed: folder colour (114,187,229) vs ref (113,185,227). Real thumbnails, and the sidebar now matches the ref rows. Left: 1) Demo thumbnails are synthetic (blocks of colour). Fine for real files but it still reads as fake in the shot. 2) Several image thumbnails are dark squares (`Inspiration 1`, `Adopt a Cat`), and the ref shows real image content. 3) In the session the window title shows the folder name only (`akhmadqasim`), which is correct, but the window covers the menu bar gap at 720p (see dist/ISSUES.md). |
| Windows / app theme | Finder + Settings refs | ours/dist-try-ghostty.png, gtk-ghostty-light.png, gtk-gallery-light.png, qt-kvantum-light.png | 50 | 58 | Fixed in the themes rig: traffic lights on the left, a single set in split views. Left: 1) In the real try-nested session, Ghostty STILL draws traffic lights on the RIGHT in reversed order (03:58 shot). The rig gets the decoration layout, the dist session does not. 2) Qt apps still have no title bar or traffic lights, plain-text toolbar buttons (`Back Forward Share`) and an in-window `File Edit View` menu. 3) The Ghostty header is a white Adwaita bar over a dark terminal, with Adwaita tab pills, not a unified dark toolbar. |
| Lock screen | none (no macOS 27 ref) | ours/lockscreen.png | 62 | 78 | Fixed: heavy rounded clock, blurred desktop wallpaper, Wi-Fi and battery top right. Left: 1) Generic grey avatar. 2) The password field is a dim pill with small placeholder text. On macOS it is narrower and frosted lighter. 3) The clock's drop shadow is visible as a halo, and macOS has none. |

## Weighted overall

| surface | weight | r1 | r2 | r2 weighted |
|---|---|---|---|---|
| desktop + menu bar + Dock | 25 | 78 | 80 | 20.00 |
| Control Center | 10 | 62 | 75 | 7.50 |
| Notifications | 10 | 70 | 75 | 7.50 |
| Spotlight | 10 | 64 | 74 | 7.40 |
| Settings | 15 | 80 | 85 | 12.75 |
| Finder | 15 | 84 | 87 | 13.05 |
| windows / app theme | 10 | 50 | 58 | 5.80 |
| lock | 5 | 62 | 78 | 3.90 |
| **overall** | 100 | **71.8** | **77.9 (78)** | |

## What improved most
Control Center (+13), lock screen (+16), Spotlight (+10) and Settings sidebar. The round 1 fixes 3, 5, 8 and 10 landed.

## Still worst
1. Windows / app theme (58). Ghostty in the real session still has right-side, reversed buttons. Qt has no chrome.
2. Spotlight/Apps glass over light content (opaque white with smudges).
3. Notification Center's see-through calendar widget.

## Top 10 remaining fixes (ranked by impact)

1. **dist/ + themes/gtk**: apply `gtk-decoration-layout=close,minimize,maximize:` in the try-nested and session
   XDG config (settings.ini for gtk-3.0/gtk-4.0 and `org.gnome.desktop.wm.preferences button-layout` via the
   private dconf or `GSETTINGS_BACKEND=keyfile`). The rig has it, the dist session does not. (+windows ~10)
2. **plugin/** (or **shell/** fallback decoration): title bar with traffic lights for windows without client-side decorations
   (Qt, foot, xterm), and **themes/qt**: icon toolbar buttons and no in-window menubar where the global menu bar exists.
3. **shell/** (Dock): tile 52–54 instead of 64 (Finder icon should be ~69 px on a 2560 screen, now 86).
4. **shell/** (menu bar): macOS clock format `Tue Nov 10  3:56 AM`, battery icon (dimmed if absent).
5. **plugin/**: the regular and Spotlight materials over white are too opaque, with cyan smudges. Use lower lift, more
   blur and neutral tint, so content behind becomes even frost and not recognisable blobs.
6. **shell/** (NC): calendar widget must be opaque (white light, ~(28,28,30) dark). Add an event list or `Up next`
   on the left. Give the `Edit Widgets` pills a glass background so they show over white.
7. **shell/** (CC): show a filled Display slider (fallback value) and a non-greyed Wi-Fi state style. Make the CC glass
   a little lighter with a rim highlight like the ref.
8. **themes/gtk**: unify the libadwaita header bar with the window content for terminals (dark header when the content
   is dark) and restyle tab-bar pills into the Finder toolbar look.
9. **shell/** (Apps view and banners): dedupe or hide helper .desktop entries (Foot Client/Server). Map more apps to
   macOS-style icons, and use the app's real icon in banners.
10. **settings/**: remove the `User / Linux Account` row or style it like macOS (Apple Account row with real avatar).
    Rename `Energy` to `Battery` on laptops. Also **lockscreen/**: real user avatar (AccountsService icon), lighter
    narrower password field, drop the clock halo.
