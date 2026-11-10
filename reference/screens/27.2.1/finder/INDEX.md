# Finder 27.2.1 reference pictures

macOS 27.2.1 (26B131), MacBook Air M2, 2x (pixels = 2 x points). Finder window 920 x 560 pt on a test folder
(`finder-demo` on a mounted test disk image `Demo`). Light pictures over TahoeLight, dark over TahoeDark.
Window pictures are `screencapture -o -l` (window only, no shadow). The user's account is not clean: Multicolour
accent (blue), icon style "Dark", Liquid Glass tint 0.5.

**Privacy redaction:** in every window picture the sidebar rows between Downloads and the Locations header
(4 user folders) and the iCloud Drive and home-folder rows were filled with an empty strip of the sidebar
copied from below Bin. The gaps are not real; the real sidebar has 32 pt rows there.

| File | Surface |
|---|---|
| `icons-light.png`, `icons-dark.png` | Icon view, Sunset.png selected (plate + accent label), tag dots, tag-coloured folder (Projects, orange tag) |
| `list-light.png`, `list-dark.png` | List view, Report.pdf selected, stripes, header with sort chevron |
| `columns-light.png`, `columns-dark.png` | Column view, Report.pdf selected, parent column grey, preview column (clipped by the window width) |
| `gallery-light.png`, `gallery-dark.png` | Gallery view, Sunset.png, preview pane on the right |
| `alert-light.png`, `alert-dark.png` | App-modal alert (Delete Immediately confirmation, cancelled) over the window, 260 x 250 pt alert |
| `sheet-light.png`, `sheet-dark.png` | Sheet ("Rename Finder Items", 489 x 161 pt, cancelled): centred over the dimmed window |
| `popover-light.png`, `popover-dark.png` | Tag popover from the toolbar Edit Tags button (glass popover with arrow) |

More crops (toolbar hover states, sidebar, context menus, rename field, drag feedback, Quick Look, tabs, path
and status bar, icons) are in `reference/re/27.2.1/live/finder/crops/`; numbers are in
`reference/re/27.2.1/live/finder/finder-measurements.json`.
