# hyprk independent judge #22, branch mac-27.2.1-rea-2026-11-14 (b43dc5f) + working tree (2026-11-15, 09:24-09:31 WITA, measured live)

Delta judgement against judge #21 (`JUDGE-95-21.md`, 93.4). Method and weights from `JUDGE-95-7.md` as carried by #17-#21:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[22 live]** measured
on screen here; **[22 static]** checked in the code only; **[21]** carried from judge #21.

## What was judged

- Since judge #21: Mac round 8 (GLASS-HIG §20, OPEN-FIXES 17-20: gradientOvalization of the key / fill highlight in
  `plugin/shaders/liquidglass.frag`, `Material.cpp` / `GlassElement.cpp`; `ovalize` off for the dock and controlcenter
  recipes), Mac round 9 (`MAC-ANSWERS-9.md`: Finder Gallery view rebuilt to R9.1-R9.4, app and Dock Trash icons by icon
  style and mode, CoreTypes Trash dark under dark mode, `themes/icons/apple-map.js` `styled()`).
- **`plugin/build/libliquidglass.so` is stale** (22:22 on 11-14; plugin sources to 07:48 on 11-15): the user preview does
  not have R8.1. Judged with the plugin built from the tree into scratch (`cmake -S plugin -B /tmp/claude-1000/j22/pb`,
  09:24) and loaded by `HYPRK_GLASS_SO`. Finder binary 08:04 = its C++ sources; QML from the tree (08:17).
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 scripts/smoke.sh` (2560 x 1664,
  scale 2), state `$XDG_RUNTIME_DIR/hk-j22` (repo `appearance.json` copied; `wallpaper.json` to scratch flat grey 127 /
  white), scratch HOME with a gallery folder built like R9.1 (Alpine.jpg 1600 x 1067, Archive.zip, Bloom.png,
  Brochure.pdf, Coast.jpg, Dunes.jpg, Notes.txt, Projects), XDG_CACHE_HOME, TMPDIR, the script's private bus. Finder
  started with the shell's environment (`/proc/<qs pid>/environ`) as `hyprk-finder <dir> --view gallery --size 1000x700
  --pathbar`. Icon style switched only in the scratch copy of `appearance.json`.
- Tools: `vptr` on a fifo, `mcap` (`long_intervals` 0), new scratch `rim3.py` (5 px x 3 row max on the top / bottom rim
  row, every 20 pt; run on the Mac stills too), `sp2.py` (5 px columns from the Spotlight bar's bottom rim, judge #21's
  rows), gallery extents / plate colour by pixel on the 2x stills.
- Stopped with `smoke.sh --stop`, bus, Finder, pointer killed by pid (environ checked), state dir, the session's volkey dir
  and the scratch dir removed. Nothing written to the repo but this file and the crops.
- Not measured: keyboard in the gallery (`send_shortcut` Right did not reach the Qt window; selection by click instead),
  the 715 pt strip scroll, gallery txt / pdf / folder / Hide Preview stills, banners / NC cards / Apple menu rims along x
  (no Mac shot over a flat backdrop for the menu), CC, HUD, MC, Cmd-Tab, lock screen, Stage Manager, scaling at 1.5.

## Overall: **93.5** (13 surfaces 93.46, with the lock screen 93.37, with Stage Manager folded in at weight 2: 93.30)

Judge #21: 93.4 (93.36). The alert's rim now falls off along x as the Mac's, to the level in dark and within 1-2 in
light; Spotlight's dark top row over white came down from 136 to 119 (Mac 100) and over grey peaks at the middle as the
Mac's. The Finder Gallery is the Mac's to the pixel where it was measured (preview frame, thumb pitch, plate colour in
both modes, quick-action greys), and the Dark icon style gives dark app icons and a dark Trash in the Dock. Two gallery
defects found: nothing is selected at launch (no plate, no file in the path bar) and the inspector has an extra "Last
opened" row. No regression found.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | R8.1 alert rim along x (dark) | over grey 127, top rim row every 20 pt from the left end (`rim3.py`, same code on `windows/alert-shown-grey-dark.png`): ours **145 148 151 153 155 154 151 148 146**, Mac 146 149 152 155 156 155 152 149 146; middle / 40 pt from the ends **155 / 148** (Mac 156 / 149); bottom row **146 .. 156 .. 147** (Mac 145 .. 155 .. 146). Height 467 px both (`01`) | **confirmed** (#21 flat 155) |
| 1b | R8.1 alert rim along x (light) | top **224 225 227 229 231 230 228 226 224** (Mac 225 227 229 231 232 232 230 227 226), middle / 40 pt **231 / 225** (Mac 232 / 227); bottom 225 .. 232 .. 226 (Mac 224 .. 231 .. 225) (`02`) | **confirmed** (within 1-2) |
| 1c | Spotlight dark list top row (OPEN-FIXES 17) | dark, query "calculator", columns from the bar's bottom rim. Over white rows +21 / +22 **119 / 120** at the middle and at 200 pt out **119 / 120** (Mac 100 / 119, 89 at 200 pt; #21 136 / 129). Over grey **83 / 76** middle, **77 / 73** at 200 pt (Mac 85 / 83, 73 / 78). Gap +1..+19 over white 96 97 99 100 102 103 105, over grey 48 49 50 50 51 51 53 (as #21, Mac within 1). Bar bottom rim middle / 200 pt: white **156 / 146** (Mac 167 / 156 at 180 pt), grey **112 / 98** (Mac 118 / 103) (`03`) | **confirmed** as stated: +17 better over white, still +19 at the middle and +30 at 200 pt |
| 1d | dock / controlcenter recipes not ovalized | Dock top rim not re-shot; [22 static] `SRecipe::ovalize` false for both | not measured |
| 2a | Gallery layout (R9.1-R9.2) | 1000 x 700, dark, Alpine selected, 2x pixels against `gallery-1000x700-first-jpg-dark.png`: preview image x **382-1456**, y **307-1022** (Mac 382-1456, 307/308-1023/1024); thumb runs on row 645 pt **328-435, 468-531, 570-665, 698-771, 806-901, 924-1019, 1052-1125, 1163-1252** (Mac 328-435, 469-530, 570-665, 702-769, 806-901, 940-1003, 1042-1137, 1164-1251: the differences are our own pictures' aspect); quick actions, inspector widths, toolbar as the Mac's by eye (`04`, `05`) | **confirmed** |
| 2b | selected plate (R9.3) | after a click: plate **(86,86,90)** dark, **(189,189,189)** light, left edge x 328 px (Mac (86,86,90), (189,189,189), 328). **At launch nothing is selected**: 0 plate pixels, the path bar ends at the folder (Mac: Alpine.jpg selected, plate shown, path bar ends "Alpine.jpg") (`06`) | **confirmed** after a click; launch state wrong |
| 2c | highlight jump / hard cut | click on the third thumb, mcap per frame (keys not deliverable here): plate moves in **one frame** (+29 ms), the preview is 15 % changed in that frame (new frame size, old picture) and complete **one frame later** (+45 ms), no fade after (Mac: highlight jumps, preview 0-2 frames after, hard cut) | **confirmed** |
| 2d | inspector rows | ours Created, Modified, **Last opened**, Dimensions; Tags header at **271 pt** in the window (Mac: Created, Modified, Dimensions; Tags at **248**). Documented fallback (atime, `finder/FALLBACKS.md`) | **defect** (+23 pt shift of everything under it) |
| 2e | preview hairline | light, column through the top edge: Mac 255 / **230** (hairline row) / image 48,80,147 from row 307; ours 255 / image 81,126,179 from row **306** (the hairline is drawn darkened inside the image, 1 px higher) | small difference |
| 3a | Dark icon style: app icons and Dock Trash | scratch `appearance.json` iconStyle dark, auto, dark mode: Launchpad, Notes, Settings, Terminal dark renditions, Trash a dark bin (Mac `dock-trash-RegularDark-dark.png` dark bin); default style keeps the light bin in dark (Mac `dock-trash-RegularLight-dark.png` light bin) (`07`) | **confirmed** |
| 3b | folders / documents one rendition, CoreTypes Trash by mode | [22 static] `apple-map.js` `modeArt` (TrashIcon, FullTrashIcon) by `dark`, others `file()`; Downloads stack in colour in both styles on screen | **confirmed** (static) |

## Regression sweep

| surface | checked | result |
|---|---|---|
| alerts | appear dark, light (live switch), click outside | rims claim 1a/b; height, buttons as #21 |
| menus | Apple menu dark over grey | side **45-46** (Mac 47, #21 46); top rim 149 at 100 pt (no Mac flat shot) |
| Spotlight | dark over white and grey | gap and list unchanged from #21; claim 1c |
| Dock | dark, default and Dark styles | claim 3a |
| Finder | gallery dark / light, click selection | claims 2 |
| shell log | whole session (17 lines) | no TypeError, ReferenceError, binding loop or "matching property". Left: qt.svg path x4, libpng iCCP x4, portal x3, brightnessctl missing, text-input x1 |
| tests | `node shell/tests/run.mjs`, `node finder/tests/run.mjs` | **411 / 0** and **35 / 0** |

## Per dimension

| dimension | j21 | j22 | change | reason |
|---|---|---|---|---|
| animation | 92.9 | **92.95** | +0.05 | gallery plate jump and preview cut within the Mac's 0-2 frames |
| transition | 91.25 | 91.25 | 0 | [21] |
| visual | 94.25 | **94.4** | +0.15 | Gallery layout to the pixel, plate colours; alert rim; minus the launch state and the extra row |
| behaviour | 93.85 | **93.9** | +0.05 | gallery click selection, Hide Preview; nothing selected at launch |
| shape | 92.5 | **92.6** | +0.1 | rim falls off along x (alert); gallery plate / frame geometry |
| colour | 95 | 95 | 0 | at target |
| shadow | 94.9 | 94.9 | 0 | Spotlight gap unchanged (within 1) |
| refraction | 94.3 | **94.5** | +0.2 | alert rim profile within 1 (dark) / 2 (light); Spotlight top row 136 -> 119 over white, middle peak over grey |
| icon | 93.6 | **93.85** | +0.25 | app icons and Dock Trash by icon style and mode; CoreTypes Trash dark by mode |
| font | 95 | 95 | 0 | gallery fonts by AX [22 static] |
| rendering | 90.95 | 90.95 | 0 | [21] |
| sound | 90.35 | 90.35 | 0 | [21] |

Plain mean of the 12: 93.30 (j21 93.24).

## Per surface

| surface | weight | j21 | j22 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.85 | 94.85 | side line as #21; ovalized menu rim not comparable (no Mac flat shot) |
| Dock | 14 | 94.75 | **94.85** | Dark style: dark app icons and Trash |
| Window chrome | 14 | 93.2 | **93.35** | alert rim along x to the Mac's in both modes |
| Finder | 13 | 93.4 | **93.75** | Gallery rebuilt to R9 (frame, strip, plate, inspector, quick actions). Left: no selection at launch, "Last opened" row, Group / View menus reopen [21] |
| System Settings | 10 | 95.5 | 95.5 | [21] |
| Control Center | 6 | 94.3 | 94.3 | [21] (recipe not ovalized, as the Mac's tile) |
| NC + banners | 6 | 92.4 | 92.4 | ovalized now [22 static], not shot |
| Spotlight | 6 | 91.0 | **91.3** | top row over white 136 -> 119 (Mac 100), middle peak over grey |
| Mission Control | 4 | 91.25 | 91.25 | [21] |
| Sounds | 4 | 90.6 | 90.6 | [21] |
| HUD | 3 | 91.5 | 91.5 | [21] |
| Cmd-Tab | 3 | 91 | 91 | [21] |
| Apps | 2 | 86 | 86 | [21] |
| Lock screen | 5 | 91.5 | 91.5 | [21] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [21] |

Weighted: 13 surfaces 9346.20 / 100 = 93.46. With the lock screen 9803.70 / 105 = 93.37. With Stage Manager
9516.20 / 102 = 93.30.

## Regressions

None found. Not a regression but a delivery gap: `plugin/build` predates every plugin change since 22:22, so the
running user preview shows #21's flat alert rim and the 136 Spotlight row until it is rebuilt.

## Top defects by points

| # | defect | numbers | file | cost |
|---|---|---|---|---|
| 1 | Spotlight dark list top row over white | rows +21 / +22 **119 / 120** flat, Mac **100 / 119** middle and **89** at 200 pt; over grey row 2 76 / 73 vs 83 / 78 | `plugin/shaders/liquidglass.frag` (key lobe before the clamp) | 0.03 |
| 2 | Gallery opens with nothing selected | 0 plate px at launch (Mac 54 pt plate (86,86,90) on the first item), path bar ends at the folder (Mac "Alpine.jpg") | `finder/qml/GalleryView.qml` / `Main.qml` | 0.02 |
| 3 | Finder Group / collapsed View menus reopen on a second click [21] | second click leaves the menu open | `finder/qml/Toolbar.qml` | 0.02 |
| 4 | Gallery inspector "Last opened" row | 4 rows vs 3; Tags at 271 pt vs 248 (+23 pt) | `finder/qml/InfoRows.qml` (atime fallback) | 0.015 |
| 5 | Spotlight bar bottom rim falls half as far along x | white 156 -> 146 at 200 pt (Mac 167 -> 156), grey 112 -> 98 (Mac 118 -> 103): ours 6-11 dark | `shell` `Theme.spotlight.barRimBottom` (flat QML line) + plugin | 0.01 |

Also open ([21]): CC dark lens fill 217.8-218.6 vs 222.9; light hold disc; Qt windows activated by a light press;
inactive light grey 75 vs 67; NC card dark side 40 vs 44-47; gallery strip clipped (not blurred) under the inspector;
gallery preview hairline 1 px high and drawn inside the image.

## The next changes, by gain

1. Rebuild `plugin/build` (no score gain in this judge, but the preview is two rounds behind).
2. Spotlight top row over white (+0.03).
3. Gallery: select the first item when the view opens (+0.02).
4. Finder Group / View menus second click (+0.02).
5. Gallery: drop "Last opened" or show it only where the Mac does (+0.015).
6. Spotlight bar bottom rim along x (+0.01).

## Reachable ceiling

About 93.6 with items 2-6 and #21's repo items. 95 is not reachable on this stack for judge #7's reasons.

## The twelve areas of the 95 goal

| area | scored as | j21 | j22 | change | reason / what holds it under 95 |
|---|---|---|---|---|---|
| animation | animation | 92.9 | **92.95** | +0.05 | gallery jump / cut in the Mac's range; HUD first frame, MC menu bar [21] |
| liquid glass | refraction + visual | 94.3 | **94.45** | +0.15 | alert rim profile; Spotlight top row (+19), CC fill, no glass in third-party windows |
| glass refraction | refraction | 94.3 | **94.5** | +0.2 | alert rim within 1-2; Spotlight top row and bar rim along x |
| shadows | shadow | 94.9 | 94.9 | 0 | at the Mac's where measured |
| depth | shadow + rendering | 92.9 | 92.9 | 0 | [21] |
| opacity | colour | 95 | 95 | 0 | at target |
| blur | refraction + visual | 93.85 | 93.85 | 0 | gallery strip not blurred under the inspector (new fallback) offsets the rest |
| sound | sound | 90.35 | 90.35 | 0 | output latency [21] |
| icon | icon | 93.6 | **93.85** | +0.25 | icons and Dock Trash by style / mode; document renders, ⌘ glyph [21] |
| emoji | (direct) | 95 | 95 | 0 | [21] |
| font | font | 95 | 95 | 0 | [21] |
| scaling | (direct) | 91.5 | 91.5 | 0 | not re-shot at 1.5 |

## Crops (`reference/judge-95-22/`)

`01-alert-top-rim-dark-grey127-mac-top-ours-bottom.png`, `02-alert-top-rim-light-grey127-mac-top-ours-bottom.png`,
`03-spotlight-dark-{white,grey}-bar-gap-list-top-ours.png`, `04-gallery-1000x700-first-jpg-dark-mac-top-ours-bottom.png`,
`05-gallery-1000x700-first-jpg-light-mac-top-ours-bottom.png`, `06-gallery-dark-at-launch-no-plate-ours.png`,
`07-dock-dark-iconstyle-dark-ours.png`. All true colour, 2x pixels except 04/05 (1 px per pt).
