# hyprk independent judge #14, HEAD 7c25576 + working tree (2026-11-14, 10:47-11:06 WITA, measured live)

Delta judgement against judge #13 (`JUDGE-95-13.md`, 91.32). Method and weights from `JUDGE-95-7.md`: 12 dimensions,
13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[14 live]** measured on screen
here; **[14 static]** checked in the code only; **[13]** carried from judge #13.

## What was judged

- Working tree (all uncommitted) since judge #13: emoji picker (ink, filled category glyphs, host stays active), key
  repeat default applied at start, Spotlight reopen first frame (`plugin/src/RegionQueue.cpp`), window button lift and
  bounce (`ui/HyprK/TrafficLights.qml`, `plugin/src/LightPress.cpp`), toolbar platter press, the ThinFilm scroll pocket
  (`ui/HyprK/ScrollEdge.qml`, `scrolledge.frag`), menus rebuilt from the Mac's resources (`MENUS-REA-27.2.1.md`,
  `ui/HyprK/TextMenu.qml`), Dock stack fan size, Settings > Sound let-go preview.
- **Run from the repo itself**: `plugin/build/libliquidglass.so` 10:06 (no plugin source newer), `finder/build` 09:39
  (Finder QML is read from disk, so the 10:xx QML is what ran). Unlike judge #13, the repo's plugin build now carries the
  Dock tail and the 500 ms title bar.
- Two sessions, one at a time, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (2560 x 1664, scale 2, then 1.6 with
  `hyprctl eval hl.monitor`), state in `$XDG_RUNTIME_DIR/hk-j`, scratch XDG_CACHE_HOME / TMPDIR, the script's private
  bus. Session 1 (dark, then light, then 1.6): Finder (scratch HOME, 47 files), System Settings, foot. Session 2 (dark):
  the whole session with the scratch HOME (11 files in Downloads, distinct mtimes, newest a PDF) for the stack fan.
  Tools: `vptr`, `fscroll`, `mcap` (13 runs, `long_intervals` 0 in all), `grim`. Both stopped with `smoke.sh --stop`,
  buses killed, state dir removed. **Slip**: in session 1 the shell ran with the real HOME, and one click on the Dock's
  Downloads stack showed the user's Downloads grid for about 2 s (nothing opened, moved or read beyond the listing; the
  shot was deleted, the measurement redone in session 2). The Dock's terminal icon also launched one ghostty window,
  closed with its button.
- Not re-measured: shadow, colour, CC / NC detail (rendered, not compared), Cmd-Tab, HUD stepping on screen, Apps,
  Stage Manager, lock screen (rule), the knob lens, MC with several windows.
- Crops in `reference/judge-95-14/` (01-12).

## Overall: **91.9** (13 surfaces 91.90, with the lock screen 91.88, with Stage Manager folded in at weight 2: 91.76)

Judge #13: 91.3. The gain is in things the user can see every minute: the window buttons now lift and bounce on the
decoded spring (14 -> 16.4-16.5 at 0.18-0.20 s, dip 13.4-13.5 on release, Finder, Settings and foot, at 2 and 1.6), the
toolbar press lightens evenly with the Mac's level steps, the scroll pocket under the toolbar is within 2-3 levels of
the Mac's own frame in dark, the menus now follow the Mac row by row, key repeat runs at 12 / 500, and Spotlight's
reopen first frame finally differs from the second (judges #10-#13). What holds it: the new text field menu is drawn
opaque, not as glass; the desktop menu is narrower than AppKit would lay it out; the stack fan and the toolbar press in
light still have no Mac picture.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1 | emoji ink 27 pt; filled face / dog / ball in dark; host keeps its active look | first-row ink 56 px (Mac 57 px, `panels/emoji-picker-dark.png`, same threshold; j13 read 51-52 vs 54 with another), 44 px = 27.5 pt tall at 1.6; dog and soccer ball filled white as on the Mac `02`; Settings' lights and blue sidebar selection pixel-identical before and with the picker open (dark and light) | **confirmed** (ink within 0.5 pt). Opened by `panels toggle emoji` no tail is drawn (Mac shot has one at the caret) `01` |
| 2 | key repeat 12 / s after 500 ms with no input.json | fresh state dir with no input.json: `repeat_rate` 12, `repeat_delay` 500, both "set: true" | **confirmed** |
| 3 | Spotlight reopen 1.090 1.071 1.048 ... | judge #10's measure (`mcap -k 2`, row y 232, x 300-420, the rim's rising step, scale = (640 - x) / (640 - 380)): **1.088 1.069 1.046 1.031 1.015 1.008 1.000**, 5 of 5 reopens (3 after `close`, 2 after `toggle`), first frame 58-112 ms after the call | **confirmed** (within 1 px = 0.004; first frame now distinct from the second) |
| 4 | window buttons lift 14 -> 16, spring 0.355 / 0.4, peak about 16.5 at 0.19 s, dip about 13.5 | disc chord through the centre row, 2 px/pt, per frame. Finder red (QML), dark: rest 13.84 (AA), **peak 16.37 at 182 ms**, held 15.73; release after a drag out: **dip 13.38 at about 170 ms**. foot red (plugin): rest 13.98, **peak 16.50 at 199 ms**, dip 13.52. Settings red at 1.6: 14.02 -> **16.52 at 184 ms**, dip 13.44. Idle 2 s: a held still button drops back (seen by accident: a release 2+ s after the press read 14.00) | **confirmed** (within 0.1-0.15 pt of the model's 16.51 / 13.49) |
| 5 | toolbar press: even, no square edge, no lift, divider hidden | Settings back / forward, dark, row 52 of the panel, against `settings/toolbar-backforward-rest-hover-press-dark.png` `03`: capsule width 146 px in all three (Mac 146); rest face 60 (Mac 61-62); hover disc 79 / face 60 (Mac 88 / 68 over a strip that also rose 32 -> 40); press face **79 flat end to end**, disc 97 (Mac 84-87 / 107-110). Relative to the strip: press face +48 / disc +66 (Mac +45 / +68). Divider gone in hover and press (both). Disc edge at the same x. Light: rest 253, hover **no visible disc**, press 229 flat `09` (no Mac light picture) | **confirmed** in dark (levels within 3 of the Mac relative to the strip); light unverified |
| 6 | scroll pocket: variable blur, replayed background | Settings > Appearance scrolled exactly 250 pt (slider row lands on the Mac's), window grab 1480 x 1250 against `appearance/appearance-scroll-250-{dark,light}.png`, x 900..1390 px, 13 px bands top to bottom: dark **15.7 3.2 3.1 2.6 2.2 1.9 2.2 2.6** (band 6.06; the first band is the window's top rim, ours brighter 71 vs 63); light 12.2 9.2 7.1 6.5 4.4 3.4 3.9 5.6 (band 7.10). The unblurred photo just below differs by 12.5 / 26 (different photo crop), so the band is closer than the content `04` `08`. Finder icon view: icons smudge under the toolbar when scrolled `12` (no Mac picture) | **confirmed** (Settings, dark and light); Finder unverified |
| 7 | menus rebuilt from the Mac's resources | Finder File menu against `menubar/pulldown-dark.png`: same rows, separators, keys and row pitch (52, 76, 100 ...), width 273 vs 272 pt. Window menu against `finder-menus-ax.txt`: same rows and separators, window list with a check on the key window, 284 vs 286 pt. Desktop menu against `context-dark.png` `05`: rows as the decode (no Ask Siri, no Paste Item, stacks-off variant: Sort By / Clean Up / Clean Up By), no separator between Get Info and Change Wallpaper, **but 151 pt wide: "Change Wallpaper..." ends under the submenu chevron column** (Mac keeps about 47 pt from the longest title to the edge when chevrons are present; ours 16). Window background menu against `context-menu-background-light.png`: same rows; Sort By ▸ = None, —, Snap to Grid, —, Name ✓, Kind, Date Last Opened, Date Added, Date Modified, Date Created, Size, Tags; Clean Up By ▸ Name .. Tags (disabled); View ▸ as Icons ✓ .. as Gallery. Apple menu: About This Mac, rows and keys as the table. Dock separator menu: Turn Hiding On, Turn Magnification On, Position on Screen ▸, Minimize Using ▸, —, Dock Settings…, with the tail. Finder sidebar (Documents): Open in New Tab, Show in Enclosing Folder, —, Remove from Sidebar, —, Get Info, Add to Dock, —, Share. Text field (Settings search, empty): Cut, Copy, Paste, Paste and Match Style, —, Spelling and Grammar ▸, Substitutions ▸, Transformations ▸, Speech ▸ (rules as decoded), **drawn as an opaque flat panel (about 44 grey), no glass, no blur** `06`. No invented row found | **confirmed** for rows; two visual defects (text menu opaque, desktop menu width) |
| 8 | stack fan item a constant 64 square on the arc | fan of 10 items `11`: items the same size from bottom to top, step 65 pt (Mac AX 64.6); `dockstack.js` explains the Mac's 65.5 -> 78.3 as the AX box of a turned 64 square (64 (cos + sin) = 78.3 at about 13°, plausible). Fan shift still GUESS in the code | **partly** (consistent with the AX numbers, no Mac pixels) |
| 9 | Sound let-go preview 30 ms after the last let-go; sound.sh fallback 1 | `settings/panes/Sound.qml`: `Timer letGo` 30 ms, `restart()` on every let-go (earlier requests dropped), alert volume read when it fires; `sound.sh` default and jq-failure `printf` both 1 (judge #13's watch item fixed) | **confirmed** [14 static], not run |

## Regression sweep

| surface | checked | result |
|---|---|---|
| Dock menu with tail | Finder's menu, scale 2 and 1.6 `07` `10` | tail at the icon centre, body 27 pt left, now in the repo's own plugin build |
| title bar double-click (foot, plugin) | 450 ms apart: zoom to 1278 x 675, again: restore; 560 ms apart: nothing | 500 ms, as judge #13 (now from the repo build) |
| Finder list and icon view | list view `Name / Date Modified / Size / Kind`, icon view scrolled | fine |
| Settings panes | Appearance, General, back / forward | fine |
| Control Center, NC, banner | dark, one notification on the private bus | rendered, nothing broken |
| Mission Control enter / exit (one window) | `mcap -k 8` full output | enter moves from 139 to about 500 ms, exit 40 to 340 ms, no missed frame |
| shell log | session 1 | as judge #13: qt.svg x6, text-input enable / disable, portal, brightnessctl. No QML error, no binding loop |

Not reproduced, watch item: a 450 ms double-click on the Finder's empty toolbar (x 640 pt) did not zoom the Finder. The
Finder had just been raised with one click before; not retried, not counted.

## Per dimension

| dimension | j13 | j14 | change | reason |
|---|---|---|---|---|
| animation | 90 | **91** | +1 | [14 live] window buttons bounce on the decoded spring within 0.15 pt (QML and plugin, 2 and 1.6); Spotlight reopen's first frame now distinct (5 of 5) |
| transition | 90 | 90 | 0 | [13]; MC one-window enter / exit clean |
| visual | 92 | **93** | +1 | [14 live] toolbar press even with Mac level steps; scroll pocket within 2-3 levels (dark); emoji ink and glyphs. Minus: text field menu opaque, desktop menu label under the chevron |
| behaviour | 92 | **93** | +1 | [14 live] key repeat 12 / 500 applied; menus row-exact (submenus act or are disabled where hyprk has no function); Dock separator menu; sidebar and text menus |
| shape | 91 | 91 | 0 | desktop menu 151 pt (narrower than AppKit's layout), picker without its tail when opened by IPC |
| colour | 95 | 95 | 0 | [13] |
| shadow | 94 | 94 | 0 | [13] |
| refraction | 92 | 92 | 0 | [13]; platter press is a colour matrix, counted under visual |
| icon | 92 | 92 | 0 | filled picker glyphs (+), nothing else new |
| font | 95 | 95 | 0 | [13] |
| rendering | 90 | 90 | 0 | log as before |
| sound | 89 | **90** | +1 | [14 live / static] repeat now 12 / 500 so held keys pop at the Mac's cadence; preview 30 ms and fallback 1 by reading |

Plain mean of the 12: 92.17 (j13 91.83).

## Per surface

| surface | weight | j13 | j14 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 93 | **93.5** | File / Window / Apple / Go menus row-exact; desktop and background menus with the nib's submenus; text field menu opaque, desktop menu width |
| Dock | 14 | 93 | **93.5** | separator menu (plist rows, tail); tail now in the repo build; fan size reinterpretation consistent, no Mac picture |
| Window chrome | 14 | 90 | **91.5** | lights bounce (decoded spring, QML and plugin); 500 ms double-click in the repo build; toolbar press |
| Finder | 13 | 90.5 | **91** | icon view pocket, background menu's Sort By / Clean Up By, sidebar menu |
| System Settings | 10 | 93 | **93.5** | pocket matches both Mac 250 shots; back / forward press |
| Control Center | 6 | 93 | 93 | carried |
| NC + banners | 6 | 91.5 | 91.5 | carried (rendered fine) |
| Spotlight | 6 | 88 | **89** | reopen first frame fixed, 5 of 5 |
| Mission Control | 4 | 90.5 | 90.5 | carried |
| Sounds | 4 | 89 | **90** | repeat cadence now the Mac's; preview timing by reading |
| HUD | 3 | 90 | **90.5** | held keys step at 12 / s after 500 ms (from the option, not filmed) |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91.5 | 91.5 | carried |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried |

Weighted: 13 surfaces 9190 / 100 = 91.90. With the lock screen 9647.5 / 105 = 91.88. With Stage Manager 9360 / 102 =
91.76.

## Regressions

None measured. Defects found in today's new work (counted above, not regressions):

- `ui/HyprK/TextMenu.qml` draws an opaque flat panel; every other menu is glass `06`.
- Desktop menu: no room is kept for the submenu column, so "Change Wallpaper..." runs under the chevrons `05`.
- Emoji picker opened with `panels toggle emoji` has no tail; the Mac's points at the caret.
- Light toolbar hover shows no disc (dark shows one, +19). No Mac light picture, so not counted.

## The next 10 changes, by gain

Repo only:

1. Text field menu as glass, the same material as the shell and Finder menus (+0.03).
2. Desktop menu width: reserve the chevron column after the longest title as AppKit does (+0.02).
3. Emoji picker tail when opened by the shortcut or IPC (at the pointer as before, or at the caret when known) (+0.02).
4. Check the Finder's toolbar double-click zoom (450 ms did nothing here once) (+0.01).
5. Status items: Wi-Fi / Battery / Focus modules instead of opening Control Center (MENUS-REA gaps 1-3) (+0.03).

Needs the Mac:

6. Downloads stack fan and grid stills at 2x and 60 fps open / close (fan shift GUESS, timing) (+0.1).
7. Mission Control exit with 4 overlapping windows (+0.1).
8. 120 fps recording of a held close button: press 1 s, drag 50 pt out, release outside (checks 0.355 / 0.4 and the idle 2 s) (+0.03).
9. Held Back in light and dark at 60 fps, and Finder icon view scrolled 100+ pt (toolbar press in light, pocket colour over Finder) (+0.03).
10. Knob lens in light and on the CC slider (+0.03).

## Reachable ceiling

About 92.1 with the repo's data (items 1-5). About 92.5-93 with the Mac captures (6-10 and the area items below). 95 is
not reachable on this stack: judge #7's reasons (no glass or AppKit controls in third-party windows, unreachable app
menus, Hyprland's presentation and focus model, motions with no Mac data) still hold about 3 points.

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 91 | MC 4-window exit; stack fan / grid motion inferred; the button spring is decoded, not filmed | Mac 60-120 fps captures (MC 4 windows, stack, held close button) |
| liquid glass | refraction + visual | 92 | text field menu not glass; fan / grid glass never compared; no glass in third-party windows | Mac stills of the stack views; repo fix for the text menu |
| glass refraction | refraction | 92 | lens fitted to one dark frame; light and CC slider untested | Mac stills of a held knob over stripes, dark and light |
| shadows | shadow | 94 | banner shadow and the tail's shadow never compared | Mac stills (banner over grey 127, Dock menu) |
| depth | shadow + rendering (layer order) | 93 | MC multi-window layer order assumed (host window now stays active under the picker) | Mac recording of MC exit |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93 | pocket within 2-3 levels in dark, 3-12 in light (top rows); NC column blur not measured; Finder pocket colour GUESS | Mac Finder scrolled under the toolbar; NC open at 60 fps |
| sound | sound | 90 | output latency; drop-on-Trash sound in the Dock; preview timing not run | Mac audio + screen capture |
| icon | icon | 92 | no per-type art beyond ZIP / PDF / text; AutoFill / Dictation glyphs missing in Edit | Mac renders of more document types and those symbols |
| emoji | (direct) | 94 | picker tail missing when opened without a caret; emoji in text never compared | a Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 90 | 1.6 lays out the same in points (lights, picker, Dock tail checked); the Mac's scaled modes never compared | Mac capture of a scaled mode of the Dock, a menu and NC |

## Crops (`reference/judge-95-14/`)

`01-emoji-picker-mac-left-ours-right.png`, `02-emoji-category-bar-mac-top-ours-bottom.png`,
`03-toolbar-backforward-rest-hover-press-mac-top-ours-bottom.png` (dark), `04-scroll-pocket-settings-250-dark-mac-top-ours-bottom.png`,
`05-desktop-menu-mac-left-ours-right.png`, `06-text-field-menu-settings-search-dark-ours.png`,
`07-dock-menu-finder-tail-dark-scale2-ours.png`, `08-scroll-pocket-settings-250-light-mac-top-ours-bottom.png`,
`09-toolbar-backforward-rest-hover-press-light-ours.png`, `10-dock-menu-finder-tail-dark-scale1.6-ours.png`,
`11-stack-fan-scale2-dark-ours.png`, `12-finder-icon-view-pocket-dark-ours.png`.
