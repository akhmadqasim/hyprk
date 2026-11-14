# System Settings 27.2.1 (26B131): live captures

These are 2x window captures without the shadow (`screencapture -o -l`) of the real System Settings window. The window
is 740x625 pt (1480x1250 px).

- Wallpapers: TahoeLight in light mode, TahoeDark in dark mode.
- Accent: Multicolour (the account's value).
- Privacy:
  - The Apple Account and Family rows are filled flat with the sidebar colour.
  - Sound output rows 2–4 (the user's device names) are blanked.
  - Search shots show only the result list.

## R1 panes (icon style Default, a clean-Mac look)
| file | content |
|---|---|
| appearance-{light,dark}.png | Appearance pane at the top: mode thumbnails, Liquid Glass preview + slider, accent row with Multicolour selected, highlight popup, icon style tiles |
| appearance-scrolled-light.png | the lower half: icon style, folder colour, Windows (sidebar icon size, tint switch), scroll bar radios; also shows the scroll edge under the toolbar |
| desktop-dock-{light,dark}.png | Desktop & Dock (sliders with text end labels, popups, mini switches, checkboxes) |
| displays-{light,dark}.png | Displays (hero strip, 5 resolution tiles, brightness card) |
| accessibility-{light,dark}.png | Accessibility (hero card, Vision rows with tiles + chevrons) |
| wallpaper-{light,dark}.png | Wallpaper (preview, card, category scrollers, Your Photos = system wallpapers) |
| sound-{light,dark}.png | Sound (alert sound, sliders with speaker icons, Output/Input segmented, device table redacted) |

## Other states
| file | content |
|---|---|
| appearance-iconstyle-tinted-light.png | Tinted style chosen: Light/Dark/Auto radio row, "Icon, widget & folder colour" popup, tinted sidebar |
| sidebar-iconstyle-<appearance>-<style>.png, sidebar-iconstyles-sheet.png | #35: sidebar below the account block per appearance (light/dark) × style (default, dark = RegularDark, clearlight, cleardark, tintedlight, tinteddark) |
| desktop-dock-active/inactive-dark-iconDark.png | Q-06: same pane with the window key and not key (icon style Dark, the account's own) |
| desktop-dock-active/inactive-light-iconTintedDark.png | Q-06 in light (taken while the style was temporarily Tinted Dark) |
| sidebar-iconsize-{small,large}-light.png | Q-07: Sidebar icon size Small / Large (rows 24 / 40; tiles are Tinted Dark here) |
| search-field-focused-light.png, search-results-light.png | Q-10: focused search (3 pt ring + Suggestions), results for "dock" (searches inside panes) |
| scroll-edge-keyboard-{light,dark}.png | Q-04: content area, Keyboard pane scrolled; fade under the 52 pt toolbar + 0.5 pt hairline |
| popup-menu-open-{light,dark}.png | Q-20: open pop-up menus (checked item over the button, accent hover pill) |
| toolbar-backforward-rest-hover-press-dark.png | Q-02: back/forward glass capsule at rest, hover, pressed |
| sidebar-hover-none-dark.png | Q-05: pointer over "Accessibility": no hover fill |

Data: `reference/re/27.2.1/live/settings/ax-*.jsonl` (AX frames in global points; the window's top-left is 484,232;
the account name is redacted).

## Round 3 (R3.9): sidebar scrolled under the search field
Display 1440x932 pt (2x), Settings relaunched per mode, window 350,150 740x625, Appearance selected, wallpaper
TahoeLight / TahoeDark. Search field 360,211 212x28 pt; sidebar scroll area 350,248 232x527 pt, content 232x1215 pt.
Rows: Apple Account 46 pt, then 32 pt rows. Scrolled with synthetic wheel events (pixel units = pt) over 466,600.
Stills: window `screencapture -x -o -l`, cropped to the sidebar = window px 0,0 464x1250 (pt 350,150 232x625).
Privacy: the Apple Account and Family rows are filled with the sidebar colour where they are below the search field,
left untouched under the field (the glass blurs them beyond reading), heavily blurred where they are above it. In the clip
the rows are found per frame by matching against frame 0 (60 fps CFR re-encode, x264 crf 12).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| sidebar-scrolled-1-{light,dark}.png | crop above, sidebar scrolled 32 pt | account row half under the search field | both | TahoeLight / TahoeDark |
| sidebar-scrolled-2-{light,dark}.png | scrolled 64 pt | Family row under the field | both | same |
| sidebar-scrolled-5-{light,dark}.png | scrolled 160 pt | Wi-Fi … Bluetooth gone, Network row under the field, scroller shown | both | same |
| sidebar-scroll-{light,dark}.mov | `screencapture -x -v -V 7 -R 350,150,232,625` (pointer shown), then redacted and re-encoded at 60 fps CFR | from the top, 180 wheel events of 4 pt every 16 ms down (to the end), 0.4 s pause, 180 of 4 pt back up | both | same |
