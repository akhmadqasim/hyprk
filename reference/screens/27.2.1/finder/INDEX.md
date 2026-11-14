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

## Round 5 (R5.3, R5.4)
Display 1440x932 pt (2x), wallpaper TahoeLight / TahoeDark, other apps hidden. Finder windows on dummy folders in
~/Pictures (removed afterwards); sidebar and path bar hidden (they show personal names). Window shots
`screencapture -x -o -l<id>` (no shadow).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| emoji-in-name-{light,dark}.png | window 400,200 640x360 pt, list view, "Report 😀👍🏽🇮🇩.txt" selected | emoji inside file names in the list ("Photo 🌅.png", "Report 😀👍🏽🇮🇩.txt") | both | window |
| scrolled-under-toolbar-icon-{light,dark}.png | window 400,150 740x500 pt, icon view arranged by name, folder of 40 coloured 256x192 PNGs + 20 text files; scrolled to the top, then one 36 pt wheel step | the first icon row passing under the toolbar (scroll edge effect) | both | window |
| scrolled-under-toolbar-list-{light,dark}.png | same window, list view, same scroll | rows (with coloured thumbnails) passing under the toolbar and the column header | both | window |

## Round 6 (R6.5): emoji in a file name, list with columns and a menu
| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| emoji-secondary-list-{light,dark}.png | window shot `-o -l`, Finder 300,200 840x320 pt, list view, sidebar and path bar hidden | "Trip 😀👍🏽🇮🇩.txt" with Date Modified / Size / Kind columns | both | window |
| emoji-secondary-menu-{light,dark}.png | right-click on the TextEdit window title (document = the dummy file), full screen still, crop = the menu window 393,125 344x328 pt (CGWindowList, incl. shadow) | the title path menu: file name with emoji (highlighted), its folders; the home folder and computer name rows are blurred | both | TextEdit window / Tahoe |
