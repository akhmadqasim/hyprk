# Finder Gallery view, 27.2.1 (26B131), round 9

2x captures (pixels = 2 x points). Window shots are `screencapture -x -o -l<id>` (window only, no shadow), taken after
`select item` via AppleScript and the pointer parked outside the window. Dummy folder `hyprk-gallery` with 8 items
(sorted by name): Alpine.jpg, Archive.zip, Bloom.png, Brochure.pdf, Coast.jpg, Dunes.jpg, Notes.txt, Projects (folder).
1000x700 pt windows: window at 200,100 on the 1440x932 pt display. 1400x900 pt windows: window at 150,60 on the
1710x1107 pt display (a 900 pt tall window does not fit 1440x932 with the menu bar and Dock; still 2x). Light pictures
over TahoeLight, dark over TahoeDark; Stage Manager off, desktop icons hidden. Account: Multicolour accent, icon style
RegularDark. AX frames for every still: `re/27.2.1/live/finder/gallery/ax-<same name>.jsonl`.

**Privacy redaction:** in every still the sidebar rows "Developments" (a user folder) and the home folder (user name)
are filled line by line with the sidebar colour (empty rows remain), and the user-name segment of the path bar is
filled with the path bar colour (gap remains between "Users ›" and "Pictures"). Clips are cropped to the gallery
area and do not include the sidebar or the path bar.

| File | How taken | Shows | Mode | Backdrop |
|---|---|---|---|---|
| `gallery-1000x700-first-jpg-light.png` / `-dark.png` | window shot | 1000x700, Alpine.jpg (1st) selected; Rotate Left / Markup / More… buttons | light / dark | TahoeLight / TahoeDark |
| `gallery-1000x700-middle-pdf-light.png` / `-dark.png` | window shot | 1000x700, Brochure.pdf (4th of 8) selected | light / dark | same |
| `gallery-1000x700-folder-light.png` / `-dark.png` | window shot | 1000x700, Projects folder selected (no Dimensions row, only More…) | light / dark | same |
| `gallery-1000x700-txt-light.png` / `-dark.png` | window shot | 1000x700, Notes.txt selected (text preview; plate shows as a 3 pt ring) | light / dark | same |
| `gallery-1400x900-first-jpg-light.png` / `-dark.png` | window shot | 1400x900, Alpine.jpg selected (toolbar shows the full search field) | light / dark | same |
| `gallery-1400x900-middle-pdf-light.png` / `-dark.png` | window shot | 1400x900, Brochure.pdf selected | light / dark | same |
| `gallery-1400x900-folder-light.png` / `-dark.png` | window shot | 1400x900, Projects selected | light / dark | same |
| `gallery-1400x900-txt-light.png` / `-dark.png` | window shot | 1400x900, Notes.txt selected | light / dark | same |
| `gallery-1000x700-preview-hidden-light.png` / `-dark.png` | window shot after View > Hide Preview | 1000x700, Alpine.jpg, inspector hidden (restored with Show Preview after) | light / dark | same |
| `gallery-keyboard-select-1000x700-light.mov` / `-dark.mov` | `screencapture -v -V 5 -R 359,152,601,650`, cropped to 601x619 pt (path bar cut), h264 | Right x4, Left x2 from Alpine.jpg, 0.6 s apart: highlight and preview change | light / dark | same |
| `gallery-keyboard-scroll-715x700-light.mov` / `-dark.mov` | `screencapture -v -V 7 -R 359,152,316,619`, h264 | window at its minimum width with inspector (715 pt): Right x7, Left x7, 0.35 s apart: strip scrolling | light / dark | same |
| `gallery-715x715-first-jpg-light.png` / `-dark.png` | window shot (`screencapture -o -l`), window 715x715 at 200,100 (minimum width with the 240 pt inspector) | round 11: Alpine.jpg selected, strip at offset 0; Flat-blue/green/red thumbs sit under the inspector (only their top 14 pt is under the material) | light / dark | TahoeLight / TahoeDark |
| `gallery-715x715-flat-red-light.png` / `-dark.png` | same | Flat-red.png selected, strip scrolled: strip under the sidebar on the left | light / dark | same |
| `gallery-1000x715-first-jpg-light.png` / `-dark.png` | same, window 1000x715 | the same thumbs in the clear (reference colours) | light / dark | same |
| `gallery-wheel-notches-715x715-dark.mov` | `screencapture -v -V 6 -R 359,700,556,115`, cropped to 85 pt height, h264 | 3 synthetic horizontal wheel notches over the strip, then 3 back over the preview, 0.7 s apart: 10 pt per notch, one frame each | dark | TahoeDark |
