# Answers from the Mac session, round 9 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay: Finder Gallery view (R9.1–R9.4), folder/document icon renditions (R9.5) and
live glass dumps of system surfaces (R9.6–R9.8). Same conditions as earlier rounds: 2x captures, Reduce Transparency /
Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots (restored after),
60 Hz panel. Account: Multicolour accent (blue), icon style RegularDark. "AX" = read from the AX tree;
"px" = measured on the 2x shots (Finder is another process, its layer tree is not readable).

Dummy folder `~/Pictures/hyprk-gallery` (moved out of the home folder afterwards): Alpine.jpg, Archive.zip, Bloom.png,
Brochure.pdf, Coast.jpg, Dunes.jpg, Notes.txt, Projects (folder), generated gradients and a one-page PDF. Sorted by
name, so "first" = Alpine.jpg, "middle" = Brochure.pdf (4th of 8).

## R9.1 Gallery stills: done
- `screens/27.2.1/finder/gallery/gallery-{1000x700,1400x900}-{first-jpg,middle-pdf,folder,txt}-{light,dark}.png`
  (16 stills), `INDEX.md`.
- Window frames (pt): 1000x700 at **200,100** (display 1440x932); 1400x900 at **150,60** (display 1710x1107, still
  2x: a 900 pt window does not fit 1440x932 above the Dock).
- Hidden: the "Developments" and home-folder sidebar rows (filled with the sidebar colour) and the user-name segment of
  the path bar (filled). AX dumps have those strings replaced by "[redacted]".

## R9.2 AX frames: done
- `re/27.2.1/live/finder/gallery/ax-{1000x700,1400x900}-{first-jpg,middle-pdf,folder,txt}-{light,dark}.jsonl` (every
  element with frame), `ax-font-1000x700-first-jpg-{light,dark}.jsonl` (AXAttributedStringForRange runs: font name,
  size, colour), summary in `gallery-measurements.json`.
- Layout, window 1000x700 at 200,100 (window-relative = subtract 200,100):
  - toolbar 52 pt; sidebar 159 pt (splitter at 358.5); gallery scroll area **359,152 601x620**; status bar hidden.
  - **Preview frame 391,184 537x497 = gallery area inset 32 pt** left/right/top; the image is aspect-fit and centred
    in it (Alpine 1600x1067 → 537x358 at y 253). The preview image has rounded corners, **≈ 6 pt (px)**, and a 1 px
    hairline (darker than the image in light, lighter in dark).
  - **Thumbnail strip**: section 364,713 467x54 (5 pt from the area's left edge, **left-aligned, not centred**, also
    at 1400x900: 314,873). Thumbs **48x48 pt** (AXImage frames 367,716 / 426 / 485 / … → **pitch 59 pt, gap 11 pt**).
    Thumbnail image fitted inside the 48 pt square (landscape images 48 wide, documents/folders as 48 pt icons). The
    gap from preview bottom (681) to strip top (713) is 32 pt; strip bottom 767; path bar 4 pt below.
  - GalleryViewSettings `iconSize = 48` is this thumb size.
  - **Path bar**: AXList "path" 364,771 587x30, items 28 pt tall (Macintosh HD 107, Users 64, … widths).
  - **Inspector**: scroll view `previewPaneScrollView` **960,152 240x578** → **width 240 pt** (= defaults
    `PreviewPaneGalleryWidth 240`), separator 0.5 pt at x 960; bottom bar 960,730 240x70 holding the quick actions.
    Minimum window width with the inspector: **715 pt** (the toolbar then collapses the view switcher to a pop-up).
  - Inspector rows (1000x700, Alpine.jpg): icon `previewPaneIcon` 969,171 **50x50**; name 1028,176.5 162x20; kind
    `sizeAndKind` 1027,198.5 164x18; "Information" 969,239 75.5x18; "Show More" (AXCheckBox toggle) 1126,241 65x16;
    rows (AXGroup 220x22, **pitch 23 pt**) Created 261, Modified 284, Dimensions 307 (title at x 969, value
    right-aligned to x 1191); "Tags" 969,339; tag field scroll 970,362 220x33 (text field 969,361 222x35, placeholder
    "Add Tags…"). Folder / txt: no Dimensions row, no "Show More" (only Created, Modified). No "Last opened" row is shown
    for these new files in the collapsed state.
  - Quick actions: **Rotate Left 972,744 64x42, Markup 1057,745 46x41, More… 1135,745 42x41** (AXButton,
    identifiers `APPEXTENSION-com.apple.finder.RotateQuickAction`, `…MarkupQuickAction`, `QuickActionMoreButton`).
    Folder / txt: only More…, centred in the 240 pt column (centre x 1080).
  - 1400x900 at 150,60: gallery area 309,112 1001x820, preview 341,144 937x697 (inset 32 again), strip 314,873,
    inspector 1310,112 240x778. Only the preview grows; inspector and strip keep their sizes.
- Fonts (AX attributed strings): kind SF Regular 13 secondary; "Information"/"Tags" SF Semibold 13; row titles SF
  Medium 11 secondary; row values SF Medium 11 label; status text SF Regular 11; window title SF Semibold 15; txt
  preview Menlo 11. AX reports colours resolved for dark in both modes (white 0.847 / 0.549 alpha even in light), so
  only the label / secondary-label distinction is usable. Name font not exposed: **≈ 16 pt (px, ink width)**.
- The selected-thumb highlight has no AX element of its own (only the AXImage `selected` flag).

## R9.3 Highlight, quick-action buttons, keyboard: done
- **Selected thumb plate (px): plain, not glass.** A square **54x54 pt** plate = thumb frame outset **3 pt** on all
  sides, behind the thumbnail; **corner radius 7.0 pt** (circular fit on the 2x edge pixels, r = 14 px); flat fill
  **light rgb(189,189,189)** on white, **dark rgb(86,86,90)** on rgb(30,31,36); no border, no shadow. For a square
  opaque thumbnail (txt page, folder) only the 3 pt ring shows. Same plate at both window sizes.
- **Markup / More… / Rotate Left (px): plain borderless buttons, no fill, no glass, no border** in both modes.
  Glyph ≈ 14x14 pt ink above an **11 pt regular** label (ink widths: More… 34 pt, Markup 38 pt, Rotate Left 56.5 pt,
  matching SF 11); glyph and label one grey: **light rgb(128,128,128), dark rgb(142,143,145)**. The bar behind them is
  the plain window background (light white, dark rgb(30,31,36)); the inspector column above is a translucent tinted
  material (light ≈ rgb(235,237,238), dark ≈ rgb(35,37,53) over Tahoe; it shows the blurred strip when the strip runs
  under it in a narrow window). "Show More" is an accent-coloured 11 pt text toggle.
- **Keyboard clips**: `gallery-keyboard-select-1000x700-{light,dark}.mov` (Right x4, Left x2) and
  `gallery-keyboard-scroll-715x700-{light,dark}.mov` (minimum-width window so the strip must scroll; Right x7, Left x7).
  Per-frame analysis: `keyboard-select-timing.txt`, `keyboard-scroll-timing.txt`.
  - The **highlight jumps** to the next thumb in one frame: no slide, no fade.
  - The **preview switches 0–2 frames (0–33 ms) after the highlight**, as a hard cut (no cross-fade, no zoom).
  - The **strip scrolls instantly** (offset jumps in one frame, no animated scroll), by the minimum needed to keep the
    selected plate inside the visible strip with **≈ 8 pt** margin at the edge (steps 46, 59, 56 pt in the clip). Going
    back left, it does not scroll until the plate reaches the left edge.

## R9.4 Hide Preview and gallery defaults: done
- `gallery-1000x700-preview-hidden-{light,dark}.png`, `ax-1000x700-preview-hidden-{light,dark}.jsonl`,
  `ax-1000x700-preview-shown-again-{light,dark}.jsonl`, `finder-defaults-gallery-keys.json`.
- Hidden: the inspector column and its quick-action bar disappear; the gallery area takes the full width (359,152
  **841**x620 = 601 + 240); the preview frame grows to 391,184 **777**x497 (still 32 pt insets) and the image re-fits
  (Alpine height-limited 745x497); the **strip stays left-aligned** at x+5; the path bar widens to 827. Toolbar
  unchanged. The menu item flips between "Hide Preview" and "Show Preview". Shown again: identical frames to before.
- Defaults (read only): `FXPreferredViewStyle = glyv` (Gallery is the account's default), `PreviewPaneGalleryWidth =
  240`, `PreviewPaneWidth = 240`, `StandardViewSettings.GalleryViewSettings = {arrangeBy = name; iconSize = 48;
  showIconPreview = 1; viewOptionsVersion = 1}`, `ShowPathbar = 1`, `ShowSidebar = 1`, `ShowStatusBar = 0`. The
  toggle writes `StandardViewOptions.GalleryViewOptions = {ShowPreviewPane = 0|1; ShowTitles = 0}` (this dict did not
  exist before the first toggle; it is left at ShowPreviewPane 1, the default behaviour). `ShowTitles` is the gallery
  "Show Filenames" option (off).

## R9.5 Folder / document icon renditions per icon style: done
Files in `re/27.2.1/live/icons-r9/`; probes `re/tools/probe/iconsr9-iconservices.m`, `iconsr9-nsworkspace.m`.
23 icons: folders (generic, Desktop, Documents, Downloads, Applications, home, Library, a red-tagged dummy folder),
Trash empty/full and external volume (type icons `com.apple.trash-empty/-full`, `com.apple.storage-external`; the real
Trash was not touched, nothing mounted), documents (dummy txt, pdf, zip, jpg, png, md, json), a dummy folder alias,
apps (Finder, Safari, System Settings, TextEdit); 16, 32, 64 (= 32@2x), 128 and 512 px.
- **IconServices in my own process, no global change** (`is-light/`, `is-dark/`): `ISImageDescriptor.appearance`
  0 = light, 1 = dark (`appearanceVariant` 0; a fresh descriptor defaults to appearance 0 whatever the global style).
  Result: **only the 4 app icons differ** between light and dark (20 of 115 PNGs). All folders, the tagged folder,
  documents, the alias, Trash empty/full and the volume are **byte-identical** in both. Changing `appearanceVariant`
  0–3 or appearance 2 does not change folders or Trash either.
- **NSWorkspace icons drawn under NSAppearance aqua / darkAqua** (`nsworkspace-aqua/`, `nsworkspace-darkaqua/`):
  folders and documents again identical; **Trash empty and full have a dark rendition** (dark grey bin) that
  IconServices did not return; Safari and TextEdit differ. Caveat: Finder and System Settings came out dark in *both*
  (the process seems to apply the account's RegularDark style to app icons through NSWorkspace), and the alias is drawn
  as a generic document with the alias badge there, so use the IconServices set for apps and the alias.
- **Real Finder** (`finder-iconview-{RegularLight,RegularAutomatic,RegularDark}-{light,dark}.png`, icon view of the
  dummy icons folder, 800x500 pt, sidebar user rows and path user segment hidden as in R9.1): the global value was
  changed briefly (`defaults write -g AppleIconAppearanceTheme`, Finder and Dock relaunched), then **restored to
  RegularDark and verified**. Pixel diff of the item crops between styles: **folders, tagged folder, documents and the
  folder alias are identical (diff 0) under all three styles in both modes**; only the TextEdit app alias changes
  (RegularLight → light in both modes, RegularDark → dark in both, Automatic → follows the mode). The red tag colours
  the folder red in Finder (Finder applies the tag tint; the IconServices URL icon of that folder is the plain blue
  folder). (In the Automatic-light still the Red folder happens to be selected.)
- So for hyprk: folders and documents have **one** rendition; showing the same folder/doc icons in light and dark is
  correct, and they are not dark versions. Apps and the Dock Trash have light and dark renditions.
- **Dock** (`dock-trash-<style>-<mode>.png`, crops of the Dock's right end): the **Trash follows the icon style like an
  app** (light bin for RegularLight, dark bin for RegularDark, Automatic follows the mode). The Downloads stack shows
  the folder's content (document previews; blurred in the crops) and does not change with style.
- **Finder sidebar glyphs** do not change with the icon style (pixel diff 0 between RegularLight and RegularDark in the
  same mode); they are accent-tinted template symbols that change only with light/dark mode.

## R9.6 Control Centre Sound knob held, layer tree: not done (attach blocked); AX + pixels given
- Not done: `lldb -p <ControlCenter pid>` → `error: attach failed: attach failed (Not allowed to attach to process.
  Look in the console messages (Console.app), near the debugserver entries, when the attach failed. …)`. SIP is enabled
  and was not changed (`glass-r9/attach-errors.txt`). No CA debug tool reads another process's layer tree with SIP on.
  The closest in-process reproduction is round 8's held SwiftUI `Slider` (`glass-r8/`, MAC-ANSWERS-8 "SwiftUI Slider
  knob while held"); the Control Centre slider is not the same view, so treat that only as a reference.
- Files (`re/27.2.1/live/glass-r9/`): `cc-sound-{idle,held}-{dark,light}.png` (Sound module only, rect 1130,y
  300x72 pt, light over TahoeLight, dark over TahoeDark), `ax-cc-sound-module-held-{dark,light}.jsonl`,
  `pixel-columns.txt` (columns through the knob over the white fill and the track).
- AX: slider `controlcenter-volume-slider` 180x14 pt; **while held an `AXValueIndicator` 22.5x17.5 pt appears** (the
  lens; there is none at rest), centred on the knob position. Module 292x64 pt.
- Pixels (held, value 0.38, both modes alike): the lens has a **dark 1 px rim** (≈ 60–75 grey) with a brighter inner
  top band (≈ 150–160) fading down (≈ 116 at the vertical centre, dark), a lighter band just inside the bottom rim
  (≈ 140–153) and a soft dark shadow under it. **The white fill continues inside the lens up to the knob centre**,
  dimmed from top to bottom (228 → 206 over the lens height in the column 5 pt left of centre; 243 → 224 at 10 pt
  left); right of the centre only the darker track shows through. The "Sound" title shifts and a ">" chevron shows
  while the pointer is over the module.
- Volume was 38 at the start (not 64) and is 38 after (pressed exactly on the knob, no drag); not changed.

## R9.7 Spotlight results list top edge: not done (no layer access, no AX); pixels given
- Not done: the panel belongs to the `Siri` process; lldb attach is denied as above, and its AX tree exposes only the
  menu bar (no window, no list elements), so there are no frames either.
- Files: `spotlight-top-light-over-{white,grey}.png` (screen rect 460,205 520x218 pt: search bar, app chips and the
  first result "Calculator"; cut above the second row because the further rows are the user's files),
  `pixel-columns.txt`.
- Seen (light mode, query "calculator"): the bar and the list panel are both **dark grey glass even in light mode
  over a white wallpaper**, each with a vertical gradient (darker at the top). The list panel starts ≈ 10 pt below
  the bar. Over the grey-127 wallpaper the same pixels are ≈ 50–60 levels darker than over white, so both panels are
  translucent glass, not opaque fills. The selected first row is a lighter rounded plate. The raw columns (centre and
  left inside edge, every 2 pt) are in `pixel-columns.txt`; the centre column crosses an app chip, so read the rim
  values from the x = 60 px column.

## R9.8 gradientOvalization and key-highlight spread: system surfaces not done; own-process sweep done
- Dock, Cmd-Tab switcher, Control Centre modules: not done, same attach error (Dock, ControlCenter); nothing else
  exposes their CA properties.
- Own process: `re/tools/probe/glassr9.swift` (copy of glassr8 with a 65–190 pt sweep that also logs every
  `CASDFLayer` effect) → `glass-r9/log-{dark,light}-sweep.json`, `cap-{dark,light}-sweep.png`. SwiftUI
  `.glassEffect(.regular, in:)` rounded rects, capsules and circles, backdrop grey 128.
- **gradientOvalization = 0.5 for every shape in the sweep** (all have min side ≥ 65 pt), as in round 8 (> 64 pt).
- **Key and fill highlight spread grow with the smaller side** (identical in dark and light; `keySpread` =
  `fillSpread`):

  | shape (pt) | min side | spread |
  |---|---|---|
  | 65x65 r16, 70 circle, 80x80 r20, 160x65 capsule, 190x80 capsule | 65–80 | 1.396263 (80.00°) |
  | 100x100 r24, 500x100 r30 | 100 | 1.403536 (80.42°) |
  | 120x120 r28 | 120 | 1.439897 (82.50°) |
  | 140 circle | 140 | 1.476258 (84.58°) |
  | 150x150 r24 | 150 | 1.494438 (85.63°) |
  | 190x190 r32, 300x190 r24 | 190 | 1.567160 (89.79°) |

  Exact fit: **spread = 80° + (min(W,H) − 96) × 10°/96, clamped to [80°, 90°]** (80° up to 96 pt, 90° from 192 pt
  on; slope 0.104167 °/pt = 0.0018181 rad/pt, residual 0). Round 8's "80° for ≤ 64 pt, 90° for large" are the two
  ends of this ramp. Other highlight inputs unchanged (amount 0.5, diffuseSpreadScale 0.65).
