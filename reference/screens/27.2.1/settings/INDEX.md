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
