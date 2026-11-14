# hyprk independent judge #15, HEAD 7c25576 + working tree (2026-11-14, 12:13-12:29 WITA, measured live)

Delta judgement against judge #14 (`JUDGE-95-14.md`, 91.90). Method and weights from `JUDGE-95-7.md`: 12 dimensions,
13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[15 live]** measured on screen
here; **[15 static]** checked in the code only; **[14]** carried from judge #14.

## What was judged

- Working tree (all uncommitted) since judge #14: glass text field menus (Finder, Settings, `shell/components/TextMenuHost.qml`
  for Spotlight and the emoji search), desktop menu width, emoji picker tail in every open path, Finder / Settings
  toolbar double-click, the Wi-Fi / Battery / Focus status modules (`StatusModulePanel.qml`, `STATUS-REA-27.2.1.md`),
  Edit menu and About This Mac icons, per-type document icons (`ICONS-REA-27.2.1.md`) in Finder and the Dock stack, the
  stack fan / grid motion and places (`MOTION-REA-27.2.1.md` Round 3).
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_STATUS_STUB=1 scripts/smoke.sh` (2560 x 1664, scale 2; dark, then
  light; scale 1.6 spot checks with `hyprctl eval hl.monitor`), state in `$XDG_RUNTIME_DIR/hk-j`, scratch HOME /
  XDG_CACHE_HOME / TMPDIR, the script's private bus. The shell, Finder and Settings all ran with the scratch HOME
  (checked in `/proc/<pid>/environ`). `Downloads` held 13 throwaway files: docx, xlsx, csv, pptx, html, mp3, mp4 (random
  bytes), a broken png (random bytes: an image without a thumbnail), txt, md, json, pdf, zip; `Documents` a copy of ten.
  Tools: `vptr`, `mcap` (6 runs, `long_intervals` 0 in all), `grim`. Stopped with `smoke.sh --stop`, bus killed, state
  dir removed. No real Wi-Fi, power or Focus state was changed (stub rows log instead of acting).
- Run from the repo: `plugin/build`, `finder/build` as left by the developer; shell and Finder QML from disk.
- Not re-measured: toolbar press levels, scroll pocket, shadow, colour, Cmd-Tab, HUD, Apps, Stage Manager, lock screen,
  knob lens, NC banner detail. Crops in `reference/judge-95-15/` (01-17).
- Test artefact, not counted: one Finder window closed when a `vptr` process that held the button down (started by
  `mcap` as trigger) exited over the close button; the compositor released the button there. Redone with one `vptr`
  process: press, drag out, release outside does not close (as judge #14).

## Overall: **92.2** (13 surfaces 92.17, with the lock screen 92.14, with Stage Manager folded in at weight 2: 92.03)

Judge #14: 91.9. The gain is the items judge #14 listed as repo work: every text field menu is now glass (Finder,
Settings, Spotlight, emoji search, dark and light), the desktop menu keeps the chevron column (label end 49 pt from the
edge against the Mac's 49.5, chevron end 21 against 21), the picker tail shows in all paths, both apps zoom on a toolbar
double-click up to 450 ms, the status items open their own modules, and documents carry per-type art. What holds it: a
new bug (a shell text menu outlives its panel and keeps the keyboard), an undecodable image shows a blank tile in the
Dock stack, and none of the new layouts (status modules, fan, grid) has a Mac picture.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1 | text field menu as glass in Finder, Settings and the shell's fields | Settings search (dark) `04`: interior 60-74 and varying with the blurred content under it (judge #14: flat 44); Spotlight field (dark) `05`: the Settings photo shows through blurred; emoji search (dark) `08`: emoji blurred through; Finder search (light) `15`: wallpaper blue blurred through. Rows as judge #14 | **confirmed** (glass in all four, dark and light). New defect, see Regressions |
| 2 | desktop menu 184.5 pt, label 49 from the edge (Mac 49.5), chevron 23 (Mac 23.5) | panel 999-1368 px = **184.5 pt**; "Change Wallpaper..." ink end **49.0 pt** from the right edge (Mac `context-dark.png`: 49.5); chevron ink end 21.0 (Mac 21.0), chevron start 25.0 (Mac 26.0). At 1.6: 184.4 pt `03` | **confirmed** (within 0.5-1 pt). Mac shot is the stacks-on variant with a check column, so the label's left inset (ours 17) is not comparable |
| 3 | emoji tail in every open path, light inner rim | `panels toggle emoji` (dark): tail at the pointer, about 24 pt base x 10 pt tall with a light inner rim (Mac 26.5 x 11, `emoji-picker-dark.png`) `07`; Edit > Emoji & Symbols: opens at the pointer, tail on the bottom edge; light, IPC near the Dock: tail on the bottom edge. Ctrl-Cmd-Space not pressed (no keyboard tool); it calls the same global (`hyprland.lua` 388) | **confirmed** (within 1-2.5 pt of the Mac's tail) |
| 4 | Finder and Settings toolbar double-click zooms at 150 / 300 / 450 ms, not at 600 | Settings (740 x 625 at 270,76) and Finder (936 x 594 at 172,92): 150, 300, 450 ms -> 1278 x 707 at 1,35 each, restored each time; 600 ms -> unchanged, both apps | **confirmed** (judge #14's Finder watch item closed) |
| 5 | Wi-Fi, Battery, Focus open their own 308 pt modules (stub data) | Wi-Fi `01`: panel 618 px = 309 pt with rim (308 + 2 x 0.5), right edge 1037 = the item's right (flipped: item left + 308 > 1280), disc 15 pt from the edge, name ink 49.5 (decode 48 + bearing); rows Wi-Fi + switch, Known Networks, Home / Office, Other Networks >, Wi-Fi Settings... Battery `02`: 308.5 pt, header "Battery 73%", Power Source: Battery, No Apps Using Significant Energy (disabled), Battery Settings... Focus: Focus, Do Not Disturb, Focus Settings... Light `16` and 1.6 (307 pt) the same. The panel edge sits 10.5 pt inside the open pill's edge (pill 1005-1047.5, item 1015-1037: `statusPillOutset` 10) | **confirmed as decoded** (no Mac picture: layout unverified; header 40 and the switch size are GUESS in the decode). Watch: whether the Mac anchors to the pill's extent |
| 6 | Edit rows AutoFill, Start Dictation, Emoji & Symbols with icons; About This Mac icon | Settings' Edit menu `10`: pencil-and-ellipsis, microphone, grinning face, in the row's icon column; Apple menu: laptop glyph on About This Mac | **confirmed** on screen (symbols decoded, no Mac picture of this menu) |
| 7 | document icons for docx, xlsx / csv, pptx, html, audio, video, image without thumbnail, other text; Finder and Dock stack | Finder icon view: docx justify, xlsx table, pptx pie, mp3 waveform, mp4 video, broken png photo, json txt-fill, each with its extension; txt / csv / html / md get content thumbnails (as the Mac's Quick Look does). 64 pt image-without-thumbnail against the Mac's `doc-png@64pt-dark.png` composited on our background: **rms 9.2** (page area 12.7), outline and symbol aligned, our "PNG" darker and heavier than the Mac's `11`. pdf at 64: rms 0.1 (the Mac's own render). List view 16 pt: all kinds `17`. Dock grid / fan: csv, xlsx, pptx, docx, html, mp3, mp4, zip, pdf correct; json / md / txt the txt-fill art with the extension (as the Mac's txt render does); **broken.png: blank cell in grid and fan** (`StackArt.qml` 33 "Unsupported image format", no fallback) `12` `13` | **partly**: Finder confirmed (rms 9.2 against the Mac's only comparable render); Dock stack misses the image fallback |
| 8 | stack fan / grid 0.25 s, CA default curve, fan shift -24, grid 11 above the icon top | grid open `mcap` (680 x 440 pt, 60 fps): panel width per frame fits CA default (0.25, 0.1, 0.25, 1) best (rms 0.3 % at 215 ms, 1.4 % at 250 ms; ease-in-out 4 %, linear 3 %). Fan open top edge (488 pt travel): ease-in-out **D 260 ms rms 2.9 pt** (250 ms: 3.1 pt; default 11 pt, linear 7 pt), the position channel as decoded. Grid: glass body bottom 729.5, tail tip 735, tail band bottom 741.5 = the icon box top 752.5 - 11 (box top from the squircle top 759.5 - 6.25 + rounding). Fan: the first item's page bottom 776 = 23.5 below the icon box top; the tile's chevron (788-790) stays **visible below** the item, not covered | **partly**: curves and places consistent with the decode; the duration is 215-260 ms by these metrics; "covers the chevron" not seen on screen; no Mac pixels |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Dock menu with tail | Finder's menu, scale 2, dark `14` | body from 393.5 (icon centre 420.5: 27 left), bottom 729, tail at the centre: as judge #14 |
| window button lift | Finder red, held, 60 fps | 13.65 -> **16.06 at 180-210 ms**, held 15.7 (j14 16.37 / 15.73, coarser metric here); drag-out release does not close |
| toolbar double-click | both apps | see claim 4 |
| Spotlight reopen | 2 reopens after `close`, j10 method (lower edge threshold) | **1.090 1.071 1.048 1.033 1.017 1.010 1.002**, first frame 80 ms after the call (j14 1.088 1.069 1.046 ...; within 0.002) |
| Control Center, NC | dark, IPC | rendered, nothing broken (CC's Wi-Fi tile reads the real device, the module the stub: not counted) |
| Mission Control enter / exit (2 windows) | `mcap -k 8` full output | enter 120 -> 640 ms, exit 20 -> 350 ms, `long_intervals` 0 |
| Finder views | icon, list (via the toolbar's collapsed view popup with search open) | fine |
| Settings | Appearance pane, sidebar, search | fine |
| shell log | whole session | as before (portal, text-input enable / disable, qt.svg x5) plus **new**: `QFont::setPixelSize: Pixel size <= 0` x7 when the fan opens (label scale from 1e-5), `StackArt.qml` decode errors for the broken png. No QML error, no binding loop |

## Per dimension

| dimension | j14 | j15 | change | reason |
|---|---|---|---|---|
| animation | 91 | 91 | 0 | [15 live] fan position ease-in-out 260 ms rms 2.9 pt, grid on the default curve; no Mac pixels, so no gain |
| transition | 90 | 90 | 0 | MC enter / exit clean; carried |
| visual | 93 | **93.5** | +0.5 | [15 live] text menus glass in four fields (dark and light); desktop menu label clear of the chevron |
| behaviour | 93 | 93 | 0 | + status modules open, toolbar zoom both apps; - a shell text menu outlives Spotlight / the picker and holds the keyboard (2 of 2) |
| shape | 91 | **92** | +1 | desktop menu width within 0.5 pt of the Mac's margins; picker tail in every path (24 x 10 vs 26.5 x 11) |
| colour | 95 | 95 | 0 | [14] |
| shadow | 94 | 94 | 0 | [14] |
| refraction | 92 | 92 | 0 | [14] |
| icon | 92 | **93** | +1 | per-type pages (rms 9.2 against the Mac's image render), Edit and About icons; minus the blank image tile in the Dock stack |
| font | 95 | 95 | 0 | [14]; the icon extension text reads heavier than the Mac's (counted under icon) |
| rendering | 90 | 90 | 0 | new log noise (pixel size 0) |
| sound | 90 | 90 | 0 | [14] |

Plain mean of the 12: 92.38 (j14 92.17).

## Per surface

| surface | weight | j14 | j15 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 93.5 | **94** | text menus glass, desktop menu width, Edit / About icons, status modules (decoded, no Mac picture); minus the stale shell text menu |
| Dock | 14 | 93.5 | **93.75** | per-type art in the stack, fan / grid curves and places as decoded; blank image tile, chevron not covered |
| Window chrome | 14 | 91.5 | **91.75** | toolbar double-click zoom in Finder and Settings at the Mac's interval |
| Finder | 13 | 91 | **91.75** | per-type document icons (16-77 pt), glass search menu, toolbar zoom |
| System Settings | 10 | 93.5 | **93.75** | glass search menu, toolbar zoom |
| Control Center | 6 | 93 | 93 | carried (modules counted under the menu bar) |
| NC + banners | 6 | 91.5 | 91.5 | carried (rendered fine) |
| Spotlight | 6 | 89 | 89 | glass field menu (+) offset by the menu staying up after Spotlight closes (-); reopen unchanged |
| Mission Control | 4 | 90.5 | 90.5 | carried, clean |
| Sounds | 4 | 90 | 90 | carried |
| HUD | 3 | 90.5 | 90.5 | carried |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91.5 | 91.5 | carried |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried |

Weighted: 13 surfaces 9216.75 / 100 = 92.17. With the lock screen 9674.25 / 105 = 92.14. With Stage Manager
9386.75 / 102 = 92.03.

## Regressions

One, in new work:

- **A shell text field menu outlives its panel** (2 of 2): right-click in Spotlight's field, then `panels toggle
  spotlight` or `panels close`: Spotlight goes, the menu stays on screen in its `hyprk-overlay` layer (a second overlay
  layer listed by `hyprctl layers`), over the emoji picker opened after it and over the windows, until the next click
  outside. `TextMenuHost` is `visible: open` with `open: fieldMenu.open` and takes `WlrKeyboardFocus.Exclusive` while open,
  so the keyboard stays with the dead menu meanwhile (Settings' lights showed inactive) `06` `09`.

Defects in new work (counted above, not regressions):

- Dock stack: an image the shell cannot decode shows an empty cell (grid and fan), no `ImageDocument` fallback `12` `13`.
- Fan label font starts at pixel size 0 (7 warnings per open).
- Status module edge 10.5 pt inside the open pill (the anchor is the item frame, the pill is drawn 10 pt beyond it);
  unverified without a Mac picture.
- Finder: conf.json shows the txt-fill icon while the other text files get content thumbnails (the Mac thumbnails json
  too); the Dock stack shows type art for csv / html where Finder shows thumbnails.

## The next 10 changes, by gain

Repo only:

1. Close a shell text field menu when its panel closes (bind TextMenuHost / fieldMenu to the panel's shown state) (+0.03).
2. Dock stack: fall back to `ImageDocument` art when an image fails to decode (+0.02).
3. Check the status module anchor against `status-pills-open-blue.png` (is the Mac's button frame the pill's extent?) (+0.01).
4. Doc icon extension text: lighter weight / colour at 48-77 pt (ours heavier than the Mac's "PNG") (+0.01).
5. Clamp the fan label font (no pixel size 0) and thumbnail json like the other text files (+0.01).

Needs the Mac:

6. Downloads stack fan and grid stills at 2x and 60 fps open / close (chevron under the first item, durations) (+0.1).
7. Mission Control exit with 4 overlapping windows (+0.1).
8. Stills of the Wi-Fi, Battery and Focus modules, dark and light (header height and switch size are GUESS) (+0.05).
9. 120 fps recording of a held close button (spring 0.355 / 0.4, the idle 2 s) (+0.03).
10. Knob lens in light and on the CC slider (+0.03).

## Reachable ceiling

About 92.3 with the repo's data (items 1-5). About 92.7-93 with the Mac captures (6-10 and the area items below). 95
is not reachable on this stack: judge #7's reasons (no glass or AppKit controls in third-party windows, unreachable app
menus, Hyprland's presentation and focus model, motions with no Mac data) still hold about 3 points.

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91 | MC 4-window exit; stack fan / grid curves decoded and consistent, never filmed on the Mac; button spring decoded | Mac 60-120 fps captures (MC 4 windows, stack, held close button) |
| liquid glass | refraction + visual | 92.5 | text menus now glass; fan / grid / status module glass never compared; no glass in third-party windows | Mac stills of the stack views and status modules |
| glass refraction | refraction | 92 | lens fitted to one dark frame; light and CC slider untested | Mac stills of a held knob over stripes, dark and light |
| shadows | shadow | 94 | banner, tail and module shadows never compared | Mac stills (banner over grey 127, Dock menu, Wi-Fi module) |
| depth | shadow + rendering (layer order) | 93 | MC multi-window order assumed; a stale text menu can sit above later panels | Mac recording of MC exit; repo fix 1 |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93 | pocket 2-3 levels dark, 3-12 light; NC column blur not measured; Finder pocket colour GUESS | Mac Finder scrolled under the toolbar; NC open at 60 fps |
| sound | sound | 90 | output latency; no drag-to-Trash sound in the Dock | Mac audio + screen capture |
| icon | icon | 93 | per-type pages now (rms 9.2 on the one comparable render); blank image fallback in the Dock; rtf / generic / app documents not built | Mac renders of docx / xlsx / pptx / audio / video pages and the generic page |
| emoji | (direct) | 94.5 | tail in every path now; emoji in text never compared | a Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 90 | 1.6 lays out the same in points (Wi-Fi module 307, desktop menu 184.4 checked); the Mac's scaled modes never compared | Mac capture of a scaled mode of the Dock, a menu and NC |

## Crops (`reference/judge-95-15/`)

`01-status-wifi-module-stub-dark-ours.png`, `02-status-battery-focus-modules-stub-dark-ours.png`,
`03-desktop-menu-mac-left-ours-right.png`, `04-text-field-menu-settings-search-dark-ours.png`,
`05-text-field-menu-spotlight-dark-ours.png`, `06-emoji-tail-ipc-and-stale-spotlight-text-menu-dark-ours.png`,
`07-emoji-tail-mac-top-ours-bottom.png`, `08-text-field-menu-emoji-search-dark-ours.png`,
`09-stale-text-menu-after-spotlight-toggle-dark-ours.png`, `10-edit-menu-icons-dark-ours.png`,
`11-doc-icon-image-no-thumb-64pt-mac-left-ours-right.png`, `12-stack-fan-shift-chevron-and-blank-png-dark-ours.png`,
`13-stack-grid-doc-icons-blank-png-dark-ours.png`, `14-dock-menu-tail-dark-scale2-ours.png`,
`15-text-field-menu-finder-search-light-ours.png`, `16-wifi-module-and-desktop-menu-light-ours.png`,
`17-finder-list-view-doc-icons-light-ours.png`.
