# hyprk independent judge #23, branch mac-27.2.1-rea-2026-11-14 (defe388) + working tree (2026-11-15, 15:53-16:10 WITA, measured live)

Delta judgement against judge #22 (`JUDGE-95-22.md`, 93.5). Method and weights from `JUDGE-95-7.md` as carried by #17-#22:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[23 live]** measured
on screen here; **[23 static]** checked in the code only; **[22]** carried from judge #22. The new Settings destinations
are outside #22's crops: they are judged in their own section and only enter the **extended** total.

## What was judged

- Since judge #22: Finder (Gallery first selection, inspector rows, inspector glass from R11.1 / R11.3, wheel in icon
  view), Dock (resize by the separator), HUD (shown on every key step, glyph bounce by layer), slider end glyphs, Search
  capsule press, Icon & widget style tiles, Mission Control exit (R10.1), Settings (sub-pane chrome, 22 Accessibility
  sub-panes, the round 12 / 13 sub-panes, sheets and pop-ups).
- `plugin/build/libliquidglass.so` (11:44) is newer than every file under `plugin/src` and `plugin/shaders` (none changed
  since #22's scratch build at 09:24): loaded as is. #22's delivery gap is closed. Finder binary 12:47 = `main.cpp`.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 scripts/smoke.sh` (2560 x 1664,
  scale 2), state `$XDG_RUNTIME_DIR/hk-j23` (repo `appearance.json` copied; `wallpaper.json` to a scratch flat grey 127),
  scratch HOME with the R9 / R11 gallery folder (Alpine.jpg, Archive.zip, Bloom.png, Brochure.pdf, Coast.jpg, Dunes.jpg,
  Flat-blue / -green / -red.png in the Mac stills' sRGB values (1,0,245), (117,251,76), (233,51,36), Notes.txt,
  Projects), XDG_CACHE_HOME, TMPDIR, the script's private bus. Mode switched only in the scratch `appearance.json`.
- Tools: `vptr` (fifo, and one process per drag with the delays in the writer), `fscroll` built from the tree into
  scratch (`scripts/motion-capture/build/fscroll` is 11:55, its source 12:03: the old binary sent no wheel), grim bursts
  (17-35 ms apart) for the HUD glyph box, new scratch `meas.py` (ink row runs and their x extents in the content column
  of two 1480 x 1250 stills, sample colours), `insp.py` (R11.1's pixel table on ours).
- Stopped with `smoke.sh --stop`; Settings, Finder and the bus killed by pid (HYPRK_HEADLESS=1 checked in environ);
  state dir, the session's volkey dir and the scratch dir removed. **Left running**: my fifo helpers `tail` 3618375 and
  `vptr` 3630728, 3631577 (started without HYPRK_HEADLESS in their environ, so not killed under the rule; idle, on a
  deleted fifo). Nothing written to the repo but this file and the crops. Tests: `node shell/tests/run.mjs` **415 / 0**,
  `node finder/tests/run.mjs` **40 / 0**. Shell log (29 lines): no TypeError, ReferenceError or binding loop.
- Not measured: Mission Control exit, Search capsule press, Icon & widget style tiles, slider end glyphs (Control Center,
  Appearance), HUD at zero, Dock menu poof, alert / Spotlight / menu rims (plugin sources unchanged, [22]), CC, Cmd-Tab,
  lock screen, Stage Manager, scaling at 1.5. No credit is given for these.

## Overall: **93.5** (13 surfaces 93.50, with the lock screen 93.41, with Stage Manager folded in at weight 2: 93.34)

Judge #22: 93.5 (93.46). Extended total with the new Settings destinations: **93.48** (Settings 95.5 -> 95.3).

Both gallery defects of #22 are fixed (first item selected at launch, no "Last opened" row, Tags at 248 pt). The
inspector is now a material over the strip: in dark it is the Mac's within 0-3 per channel on 24 of 27 samples. The HUD
shows on an extra step at full and its glyph bounces to the Mac's peak (1.15x) and undershoot. **The Dock's separator
drag does nothing in this session** (no cursor change, no resize, nothing written). The 9 sampled Settings sub-panes
lay out within 0-2 px of the Mac in both modes; the sheets carry the defects.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | Gallery first selection | 1000 x 700 dark at launch: plate on Alpine.jpg, path bar ends "Alpine.jpg", inspector shows it (Mac the same; #22: 0 plate px) | **confirmed** |
| 1b | inspector rows | Created, Modified, Dimensions; Tags header at **248 pt** (Mac 248; #22 271) | **confirmed** |
| 1c | inspector glass (R11.1) | 715 wide, dark, thumb centre columns blue / green / red, window rows 600..644 (Mac / ours): 600 (37,39,56) / (37,39,57), (39,40,53) / (38,39,54), (43,40,54) / (40,38,52); 633 (34,36,86) / (33,35,91), (47,73,52) / (48,70,56), (75,43,51) / (72,41,50); 644 (32,35,98) / (30,32,110), (52,91,51) / (54,87,58), (91,44,50) / (89,42,49). Base (36,38,53) / (36,38,55). Bar under it (31,31,36) / (31,31,37) (`07`) | **confirmed** in dark: within 0-3, blue column B +5..+12 on the last 4 rows |
| 1d | the same, light | base Mac (235,237,239) ours **(241,241,244)**; row 633 (195,197,255) / (203,204,255), (207,240,197) / (213,243,203), (252,204,199) / (254,209,204); row 644 (171,175,254) / (183,184,255), (192,243,178) / (198,245,183) | **partly**: +6 at the base, +6..+12 in the glow |
| 1e | wheel in icon view | 240 files, 900 x 560: 3 wheel notches move the grid **432 px = 72 pt per notch**, one nested-style notch 72 pt (before: none). Mac per-notch step in icon view not captured | **confirmed** (scrolls) |
| 1f | gallery wheel (R11.2) | 3 vertical notches over the strip and over the preview: strip offset **0** (Mac 0); finger scroll moves it; 10 pt per horizontal notch [23 static] `Theme.gallery.wheelStep` | **confirmed** |
| 2 | Dock resize by the separator | pointer on the separator (x 742, line at 742): **arrow cursor** (Mac: resize up-down). Press, 26 pt up in 7 moves, release (one virtual pointer, delays in the writer): Dock **525 x 84 pt before, during and after**, no `dock.json`. Same with a drag down. In one unsynchronised frame the glass plate was drawn about 94 pt above the icons (`08`, `09`) | **not confirmed**: no resize here |
| 3a | HUD on every key step | stub at 1.0, HUD hidden, one more `volume-key.sh up`: HUD shown 0.45 s later, 16 segments (`10`) | **confirmed** |
| 3b | glyph bounce at full | IPC 0.9375 -> 1.0, glyph box per grim: rest **68 x 49 px**, peak **78 x 55** (1.15x) at 0.26-0.30 s after the call, height 61 at 0.36-0.40 (waves later than the speaker), undershoot **64 x 44** (0.94x) at 0.60, rest at 0.73 s (Mac 67 x 47 -> 77 x 53 at 0.2 -> 62 x 43 at 0.5 -> rest 0.67; the call adds about 0.06 s). An ordinary step (0.875 -> 0.9375): box static | **confirmed**; rest box 2 px taller, HUD gone 1.13-1.20 s after the step (Mac about 1.0) |
| 3c | key path, level-changing steps | in this stub session `volume-key.sh down / up` changed `stub-sink` (1.0 -> 0.9375 -> 0.875) but **no HUD** at 0.35 and 0.75 s on 5 of 5 steps, after it had worked for the first steps. Likely the stub only: the script renames `stub-sink` twice per step (set-mute, set-volume) and `Audio.qml`'s file watch is lost. PipeWire path not driven | **test path broken**, not scored |
| 4 | slider end glyphs, Search capsule press, style tiles, MC exit | not measured | no credit |
| 5 | Settings sub-pane chrome | sub-pane: Go Back enabled, Go Forward disabled, one left-aligned title, sidebar row kept; Go Back returns to the pane (11 destinations, both modes) | **confirmed** |

## Regression sweep

| surface | checked | result |
|---|---|---|
| plugin glass | sources against #22's build time | no file changed: alert, menu, Spotlight numbers [22] |
| Finder | gallery 1000 x 700 and 715 wide, dark / light; icon and list view | claims 1; no regression |
| Dock | hover, press, drag, release on the separator | claim 2 |
| HUD | extra step at full, bounce, ordinary step | claims 3 |
| Settings | 11 destinations, 1 pop-up, light and dark | section below |
| shell log | whole session | clean (libpng iCCP, portal warnings only) |
| tests | shell, finder | 415 / 0, 40 / 0 |

## Per dimension

| dimension | j22 | j23 | change | reason |
|---|---|---|---|---|
| animation | 92.95 | **93.1** | +0.15 | HUD glyph bounce at the Mac's 1.15x / 0.93x, by layer; MC exit and slider glyphs not measured |
| transition | 91.25 | 91.25 | 0 | [22] |
| visual | 94.4 | **94.45** | +0.05 | gallery launch state and inspector rows fixed; light inspector +6 |
| behaviour | 93.9 | **93.95** | +0.05 | first selection, wheel in icon view, HUD on every step; minus the dead separator drag and its cursor |
| shape | 92.6 | 92.6 | 0 | [22] |
| colour | 95 | 95 | 0 | at target |
| shadow | 94.9 | 94.9 | 0 | [22]; the Settings sheet shadow is in the extended section |
| refraction | 94.5 | **94.55** | +0.05 | inspector material over the strip within 0-3 in dark |
| icon | 93.85 | 93.85 | 0 | style tiles not measured |
| font | 95 | 95 | 0 | sub-pane text runs within 0-2 px |
| rendering | 90.95 | 90.95 | 0 | [22] |
| sound | 90.35 | 90.35 | 0 | [22]; poof on Remove from Dock not measured |

Plain mean of the 12: 93.33 (j22 93.30).

## Per surface

| surface | weight | j22 | j23 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.85 | 94.85 | [22] |
| Dock | 14 | 94.85 | **94.8** | separator drag: no resize, arrow cursor, one frame with the plate off the icons |
| Window chrome | 14 | 93.35 | 93.35 | [22] |
| Finder | 13 | 93.75 | **94.0** | first selection, "Last opened" gone, inspector glass, wheel. Left: light inspector +6, Group / View menus [21] |
| System Settings | 10 | 95.5 | 95.5 | #22's crops unchanged; new destinations in the extended total only |
| Control Center | 6 | 94.3 | 94.3 | [22] (end glyphs not measured) |
| NC + banners | 6 | 92.4 | 92.4 | [22] |
| Spotlight | 6 | 91.3 | 91.3 | [22] |
| Mission Control | 4 | 91.25 | 91.25 | [22] (exit not measured) |
| Sounds | 4 | 90.6 | 90.6 | [22] |
| HUD | 3 | 91.5 | **92.0** | shown on every step, bounce at the ends as the Mac's |
| Cmd-Tab | 3 | 91 | 91 | [22] |
| Apps | 2 | 86 | 86 | [22] |
| Lock screen | 5 | 91.5 | 91.5 | [22] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [22] |

Weighted: 13 surfaces 9350.25 / 100 = 93.50. With the lock screen 9807.75 / 105 = 93.41. With Stage Manager
9520.25 / 102 = 93.34. Extended (Settings 95.3): 9348.25 / 100 = 93.48.

## Settings destinations (extended, outside #22's crops)

Mac stills `re/27.2.1/live/settings-r12/` and `settings-r13/`, window 740 x 625 at 2x; ours the same window shot from
the session (`grim` of the window rect). Light and dark each, except Location Services (dark). `meas.py`: ink row runs
in the content column, (top, bottom) and (left, right) in px.

| # | destination | light | dark | result |
|---|---|---|---|---|
| 1 | Accessibility (top) | 13 / 13 runs, all **3-5 px high** | the same | content 1.5-2 pt too high: "Vision" heading 320 vs 324-325, rows 390 vs 393, placard text 213-214 vs 216 (`06`) |
| 2 | Accessibility > VoiceOver | 6 / 6 within 1 px; buttons x 675 vs 671 (+4) | the same | match (`01`) |
| 3 | Accessibility > Zoom | 13 / 13 within 2 px | the same | match; Help "?" dot 4 px high |
| 4 | Accessibility > Display | 23 / 23 within 2 px | 18 / 18 within 2 px | match (text widths differ by the Mac's British spelling only) |
| 5 | Accessibility > Motion | 11 / 11 within 1 px | 9 / 9 | match |
| 6 | Accessibility > Keyboard | 24 / 24 rows within 1 px | the same | match; two caption lines 12-13 px shorter |
| 7 | Network > Firewall | rows within 1 px | the same | placard switch **72 x 32 px (36 x 16 pt)**, Mac **88 x 40 (44 x 20)** (`02`) |
| 8 | Focus > Do Not Disturb | 18 of 19 rows within 2 px | the same | match; one caption wraps 35 px later |
| 9 | Privacy & Security > Location Services | - | header within 2 px | the same small placard switch (Mac 88 x 40); app list is the machine's own |
| 10 | Lock Screen > Accessibility Options… (sheet) | sheet 470 x 479 at 135,73, rows 137 / 175 / 212 / 250 / 288 / 325 (Mac 287 for the fifth) | the same | sheet matches; see defects 1, 2 |
| 11 | Menu Bar > Clock Options… (sheet) | sheet 470 x 533 at 135,52 | the same | rows drift: Style 248 vs 246, Announce 370 vs 367, Interval 408 vs 405, Voice 446 vs 443 pt (`03`, `04`) |
| 12 | Lock Screen pop-up "Turn display off" | - | 13 items, "For 10 minutes" checked, pitch 24 pt | items as `pop-lockScreen-00` |

Defects, by cost (points of the Settings surface):

| # | defect | numbers | file | cost |
|---|---|---|---|---|
| 1 | sheet shadow, light | level just outside the right edge over the dimmed pane (201): ours **126 136 147 159 172 186 201** in 14 px, Mac **177 179 181 183 185 186 188 190**, still fading at 40 px; under the bottom edge ours **100**, Mac **162**; top ours 145, Mac 196. Dark within 3 (18-19 vs 21-22) | `settings/controls/SubSheet.qml`, `DetailSheet.qml` | 0.08 |
| 2 | window lights under a sheet | ours all grey (167), (182), (173) light and (65), (85), (60) dark; Mac only the red is greyed: (230,230,235), **(245,202,88), (150,210,109)** light, (73,74,86), (243,194,45), (97,188,47) dark | `settings/SettingsApp.qml` | 0.04 |
| 3 | placard switch size | Firewall, Location Services: 36 x 16 pt, Mac 44 x 20 | `settings/panes/network/Firewall.qml`, `panes/privacy/Location.qml` | 0.03 |
| 4 | Clock Options: disabled rows | "Interval" / "Voice" labels dimmed, light **121** / dark **159**; Mac full label colour **38** / **222** (only the values are dimmed); rows +2..+3 pt | `settings/panes/ControlCenter.qml` | 0.02 |
| 5 | Lock Screen root | no "Show Live Activities when locked" row and no caption under "Require password"; "Accessibility Options…" at y 437 vs 585 (part of it the battery / power adapter rows of a laptop) (`05`) | `settings/panes/LockScreen.qml` | 0.02 |
| 6 | Accessibility top pane | content 1.5-2 pt high (rows -3 px, heading -4 / -5 px) | `settings/panes/Accessibility.qml` | 0.01 |

Not comparable: the dark window and card fill, ours (35,35,35) / (42,42,42) over the flat grey wallpaper, Mac
(30,31,36) / (37,38,43) over Tahoe Dark (light is exact: 255 / 247). The Mac's sidebar icons are its Dark icon style.

## Regressions

None in the surfaces #22 measured. New and not working here: the Dock's separator drag (claim 2). Test path only: the
stub sink loses the key steps (claim 3c).

## Top defects by points

| # | defect | numbers | file | cost |
|---|---|---|---|---|
| 1 | Spotlight dark list top row over white [22] | rows +21 / +22 **119 / 120** flat, Mac **100 / 119** middle and **89** at 200 pt | `plugin/shaders/liquidglass.frag` | 0.03 |
| 2 | Finder Group / collapsed View menus reopen on a second click [21] | second click leaves the menu open | `finder/qml/Toolbar.qml` | 0.02 |
| 3 | Gallery inspector material in light | base **(241,241,244)**, Mac **(235,237,239)**; over the blue thumb row 644 (183,184,255) vs (171,175,254) | `finder/qml/shaders/inspector.frag`, `finder/qml/Theme.qml` | 0.013 |
| 4 | Dock separator drag does nothing | 26 pt drag: Dock stays 525 x 84 pt, arrow cursor (Mac resize up-down), no `dock.json`; one frame with the plate about 94 pt above the icons | `shell/modules/Dock.qml` (611-636) | 0.01 |
| 5 | Spotlight bar bottom rim along x [22] | white 156 -> 146 at 200 pt (Mac 167 -> 156) | `shell` `Theme.spotlight.barRimBottom` + plugin | 0.01 |

Also open: HUD hides 1.13-1.20 s after a step (Mac about 1.0), glyph rest box 68 x 49 vs 67 x 47 px; dark inspector blue
column +5..+12 on the last rows; icon view wheel step 72 pt per notch (no Mac number); #22's list (CC dark lens fill,
light hold disc, light press activates Qt windows, inactive light grey 75 vs 67, NC card dark side, gallery hairline).

## The next changes, by gain

1. Dock separator drag: make the press reach the resize area and show the resize cursor (+0.01, and the claim).
2. Spotlight top row over white (+0.03).
3. Finder Group / View menus second click (+0.02).
4. Light inspector material 6 darker (+0.013).
5. Settings sheets: shadow in light, lights under a sheet, placard switch size (extended +0.15 of the Settings surface).
6. `volume-key.sh` stub: one rename per step, so headless sessions can measure the key path again.
7. Rebuild `scripts/motion-capture/build/fscroll` (older than its source).

## Reachable ceiling

About 93.6 with items 1-4 and #21's repo items. 95 is not reachable on this stack for judge #7's reasons.

## The twelve areas of the 95 goal

| area | scored as | j22 | j23 | change | reason / what holds it under 95 |
|---|---|---|---|---|---|
| animation | animation | 92.95 | **93.1** | +0.15 | HUD bounce measured at the Mac's sizes; MC exit, slider glyphs not measured; HUD first frame [21] |
| liquid glass | refraction + visual | 94.45 | **94.5** | +0.05 | inspector material; Spotlight top row (+19), CC fill, no glass in third-party windows |
| glass refraction | refraction | 94.5 | **94.55** | +0.05 | inspector over the strip within 0-3 (dark); Spotlight top row and bar rim |
| shadows | shadow | 94.9 | 94.9 | 0 | at the Mac's where #22 measured; Settings sheet shadow in light 3x too dark at the edge (extended) |
| depth | shadow + rendering | 92.9 | 92.9 | 0 | [22] |
| opacity | colour | 95 | 95 | 0 | at target |
| blur | refraction + visual | 93.85 | **94.05** | +0.2 | gallery strip blurred under the inspector as R11.1 (was clipped); light +6..+12 |
| sound | sound | 90.35 | 90.35 | 0 | output latency [21]; poof on Remove from Dock not measured |
| icon | icon | 93.85 | 93.85 | 0 | style tiles not measured; document renders, ⌘ glyph [21] |
| emoji | (direct) | 95 | 95 | 0 | [21] |
| font | font | 95 | 95 | 0 | [21]; sub-pane text within 0-2 px |
| scaling | (direct) | 91.5 | 91.5 | 0 | not re-shot at 1.5 |

## Crops (`reference/judge-95-23/`)

`01-settings-acc-voiceover-dark-mac-left-ours-right.png`, `02-settings-firewall-dark-placard-switch-mac-left-ours-right.png`,
`03-settings-clock-options-sheet-light-mac-left-ours-right.png`, `04-settings-clock-options-sheet-dark-mac-left-ours-right.png`,
`05-settings-lock-screen-root-light-mac-left-ours-right.png`, `06-settings-accessibility-top-dark-mac-left-ours-right.png`,
`07-gallery-715-inspector-strip-glow-{dark,light}-ours.png`, `08-dock-separator-hover-press-drag-release-after-ours.png`,
`09-dock-separator-drag-glass-plate-detached-ours.png`, `10-hud-shown-on-extra-step-at-full-ours.png`. Settings crops
1 px per pt (740 x 625 each side); the rest true colour.
