# hyprk independent judge #21, branch mac-27.2.1-rea-2026-11-14 (d693e6d) + working tree (2026-11-15, 00:22-00:51 WITA, measured live)

Delta judgement against judge #20 (`JUDGE-95-20.md`, 93.15). Method and weights from `JUDGE-95-7.md` as carried by #17-#20:
12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[21 live]** measured
on screen here; **[21 static]** checked in the code only; **[20]** carried from judge #20.

## What was judged

- Since judge #20 (all uncommitted): alert speck / window alpha / Gaussian dismiss blur / light halo (`MOTION-AUDIT.md`
  "Judge #20 fixes"), lights section 10 (disabled zoom, inactive window), segmented control (OPEN-FIXES 14), HUD "Round
  J20" (anchor above, content = spring, showDelay 42, pop 44 ms), Settings dark tint (OPEN-FIXES 12) and the alpha
  scroll-edge line, glass round 11 (GLASS-HIG 16) and §17 (Spotlight one window shadow), Finder list pocket (§15 round
  11), interactive glass (INTERACTIVE-GLASS-REA 6), emoji at alpha 1 (EMOJI-TEXT secondary text), Mac rounds 6-7
  (`MAC-ANSWERS-{6,7}.md`). `plugin/build/libliquidglass.so` 22:22 (last plugin source 22:02); the session's Hyprland
  mapped exactly that file. Finder binary 19:02 = its sources; QML from the tree.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_SOUND_LOG=... scripts/smoke.sh`
  (2560 x 1664, scale 2), state `$XDG_RUNTIME_DIR/hk-j21` (repo `appearance.json` copied, light then dark via
  `theme setDark`), `wallpaper.json` pointed at scratch flat grey 127, white, and red / green / navy in the Mac's display
  values ((234,51,35), (71,158,44), (0,0,123), OPEN-FIXES 12), scratch HOME (judge #20's folders), XDG_CACHE_HOME, TMPDIR,
  the script's private bus. Stub env read from `/proc/<qs pid>/environ`. Cursor hidden. Finder, foot and Settings started
  with the shell's environment / `settings/run.sh`.
- Tools: `vptr` on a fifo, `fscroll`, `mcap` (every capture `long_intervals` 0), `mcap.py alpha`, judge #20's `fits.py`,
  `cc.py`, `arim.py`, `shad.py` unchanged; new scratch scripts: `alap.py` (per-frame s / a fit + PopIn t0 fit), `reach2.py`
  (shadow reach / s, both clips at 1 px per pt), `dblur.py` (text box `F = a G_sigma(warp(rest, s)) + b`, sigma / s / a / b
  searched; on the Mac's dark dismiss frame it gives **0.78 pt, a .830**, #20's calibration 0.80 / .846), `hudkey.py`
  (sound-log time on mcap's CLOCK_MONOTONIC), `hudanchor.py` (edge motion per s), `spgap.py` (21 px column through the
  Spotlight centre from the bar's bottom rim), `shine.py` (held - rest by distance from the share glyph inside the
  capsule box, ink masked, run on the Mac pair too). Mac clips read by pts (`ffmpeg -vsync passthrough -frame_pts 1`).
- Stopped with `smoke.sh --stop`, bus, pointer killed, state dir and the session's volkey dir removed, frame dumps and
  Mac frame extracts deleted. Nothing written to the repo but this file and the crops.
- Not measured: Cmd-Tab, Apps, lock screen, Stage Manager, Dock fan / grid and MC exits (no change claimed; MC opened and
  closed once), scaling at 1.5, the disabled zoom (no product window uses `zoomEnabled: false`), the plugin lights on an
  inactive foot, the held switch's white edge mid-growth (claim 6c), segmented control and Settings line in light only
  partly (segmented dark only).

## Overall: **93.4** (13 surfaces 93.36, with the lock screen 93.27, with Stage Manager folded in at weight 2: 93.20)

Judge #20: 93.15. All three of #20's alert defects are gone on screen: no opaque first frame (first visible frame 9 px at
4.7 levels, the Mac's 21 px at 6.2), the dismiss text blur is the Mac's 0.8 pt in both modes, and the light shadow no
longer haloes the small alert. Spotlight's gap and list bottom rim now sit within 1-2 levels of the Mac's; the HUD moves
frame for frame like the Mac's from its first frame and lands 21-38 ms after the pop (was 57-63, Mac 18). The Settings
window takes the desktop's tint within 2 levels on four desktops, emoji keep alpha 1 in translucent labels, and the
interactive-glass round (hold shine without the square, back / forward lift, knob deformation, end-glyph bounce) shows
on screen. One regression, already known: Spotlight's dark list top row over white is a bright 136 where the Mac has a
dark 100.

## The developer's claims

| # | claim | measured here | verdict |
|---|---|---|---|
| 1a | alert: no first-frame speck, window-alpha fade (glass on the layer's opacity marker) | light over grey, 3 runs (`alap.py`, region the Mac's 560 x 500 pt crop at our alert's centre). First changed frame **9 px over 3 levels, max 4.7** at t0 + 16 ms (Mac clip: 21 px, max 6.2; #20: a 7 x 5 px fully opaque glass). s / a of the first frames **.023/.039 .034/.079 .060/.110 .087/.143 .129/.174 .180/.213** (Mac .030/.033 .050/.069 .077/.114 .112/.151 .158/.195 .219/.252). PopIn rms **.0010-.0021**, peak 1.181 (Mac .0005, 1.194); alpha vs v rms **.013** (Mac .011). Dark: first frame 1 px over 3 levels. The three runs are identical frame for frame (`01`) | **confirmed** |
| 1b | dismiss Gaussian 0.80 pt, spring read at k + 2/3 | Esc, `dblur.py` on the title + message box. Mac dark dismiss frame: **0.78 pt, a .830**. Ours frame 1: dark **0.80 pt, a .834** (2 runs, rms .73); light **0.80 pt, a .796** (3 runs); frame 2 **1.92 pt** both (5 p 1.94). Remaining share of the light dismiss per frame .77 .52 .35 .23 ..., gone at ~200 ms (Mac light: no dismiss frame; #20 judged the spring as confirmed) (`02`) | **confirmed** (#20: 1.25 dark, ~2 light) |
| 1c | light shadow size while small | reach of the > 2-level footprint through the centre / s, below / side / above (pt, both at 1 px per pt): Mac s .112 107/125/116, .158 126/126/120, .219 127/123/118, .289 131/134/117; ours s .129 **124/131/124**, .180 **127/133/122**, .243 131/135/119, .322 133/136/114. Light rims at rest to the level (left 114 / 54 / 199, top 120 / 101 / 231 219, as the Mac's) | **confirmed** (halo gone) |
| 1d | in-window AlertPanel content blur (Finder, Ctrl+Shift+Backspace, Esc) | first dismiss frame 47 ms after the key (Qt app), fit over the Finder's icons poor: sigma **0.64 pt, a .70, rms 9.0**; frame 2 1.14 pt, rms 16 | **not reproduced** (blur present, the fit cannot separate it from the moving backdrop) |
| 2 | window buttons: disabled zoom; inactive window hover / press | Finder (QML) behind foot, dark, mcap per frame: the first hovered frame shows all three in colour **with full glyphs**, unchanged after (Mac: the same at the next frame); press: close lifts **in one frame** (top edge -2 px) and lighter, the next frames unchanged (`06`). Disabled zoom and the plugin's inactive foot not filmed (no product window has a disabled zoom) | **confirmed** for the QML inactive window; rest not measured |
| 3 | segmented control (Finder view switcher) vs `segmented-drag-*.mov` | dark, Icons pill rest **82.0**, hover + wash **104.0** (+22; Mac 70.0 -> 93.9, +24), pressed **108.0** (+26; Mac +29), dragged onto List: Icons **88.0** / List **88.0** in one jump (Mac 77.1 / 78.3, +7 / +8 over rest; ours +6 / +6), the List / Columns separator hidden (114 -> 71), release commits List (selected + hovered 107.6), no lens. Capsule while pressed: left rim -2.5 px, right +2.4 px (Mac +2.07 per edge); back on release (`07`) | **confirmed** (absolute pill / face levels 12 above the clip's, as stated) |
| 4 | HUD: first frame vs the pop, anchor above, content = spring | 10 key runs (`volume-key.sh up/down 16 shift`, stub), mcap 960,0 320 x 120 pt at 1 per pt, sound log on mcap's clock, pop out = log + 11 ms: pill -> pop out **39-55, mean 51** (Mac 48.7); pop out -> first HUD frame by #20's rule (> 20 px over 4 levels) **17-46, mean 38** (#20 57-63; claimed 13.5 by another rule; Mac 18); by > 2 levels (the frame equivalent to the Mac's first, below) **-0.2..29, mean 21**; pill -> first frame (> 4) 67-100, mean 89 (Mac 66.7; the stub's pill jitters 32 / 79 ms). Look, 2 runs in the Mac's 480 x 200 pt crop, aligned on the frame where s = .941: energy share per frame **.023 .051 .090 .133 .185 .243 .301 .365 .423 .486 .536 .595** (Mac .031 .058 .088 .133 .187 .245 .293 .383 .443 .486 .536 .581) from 83 ms before to 100 ms after; bottom edge -9 -8 -7 -6 -5 -4 -3 px and top -1 at s .941 ... .984, **the same as the Mac's frame for frame** (scaling about a point ~10 pt above the capsule) (`03`) | **confirmed** for anchor and curve; first frame 3-20 ms behind the Mac's, a little fainter (.023 vs .031) |
| 5a | Settings dark window follows the desktop | Appearance pane, window / card / sidebar at the Mac's window px, ours vs Mac: red **(41,31,30) (48,38,37) (52,34,33)** / (40.5,31,30.5) (46,38,37) (53,34,32); green **(32,37,31) (39,44,38) (36,44,33)** / (32,36,30.5) (39,43,38) (35,43,32); navy **(28,28,35) (35,35,42) (34,34,51)** / (28,28,35) (35,35,42) (35,35,53); grey **35 / 42 / 41** / 35 / 42 / 40 (`04`) | **confirmed** (within 2 everywhere; #20's bluish card fixed) |
| 5b | Settings scroll-edge line as an alpha line | scrolled Desktop & Dock, light: one row at 52 pt, **229** over the white band (Mac 228 over 254); `Theme.scrollEdge` black .10 / white .07 [21 static] | **confirmed** (dark not shot) |
| 6a | CC lens rim line over the fill | dark grey, `cc.py` box 48 x 40, rims 47 x 39 (Mac 47 x 40 / 46 x 38), fill mean **219.4** (Mac 224.0, #20 219.1). Line pixel per fill row **176 175 173 172 171 170 168 165** (Mac 183 175 173 172 168 165 162 160), inner mean **171.5** (Mac 169.2; #20 ~179 flat by the dev's reading); crossing lx-2..lx+2 248 246 174 172 242 (Mac 254 227 172 203 250) (`10`) | **confirmed** |
| 6b | preview dark round ends | Appearance, dark, middle rows of the capsules (min at each end): share L, more R, copy L, copy R, search L **111 109 110 108 109** (Mac 109 110 110 110 110; #19 right end 99) | **confirmed** |
| 6c | switch white edge mid-growth | not filmed | not measured |
| 6d | Regular dark side rim (alert, menus, NC, banner) | alert **46 / 46** (Mac 46 / 46), Apple menu **46** (Mac 47), banner (3-line, straight rows) **47-51** (Mac 50), NC card **40** on the straight rows (Mac 44-47; outside 102-103 / 100-101) | **confirmed** (NC now 4-7 dark) |
| 7 | Spotlight one window shadow: gap, list bottom rim; known: list top row | dark over grey (`spgap.py`, rows from the bar's bottom rim): gap +1..+19 **48 49 50 50 51 51 53** (Mac 47 48 49 49 50 51 52), list 2 / 11 / 50 / 80 / 98 % 68 73 91 103 112 (the Mac's to the level), bottom rim **117 120 135 153** (Mac 118 120 136 154). Over white: gap **96 97 99 100 102 103 105** (Mac 95 96 98 99 101 102 104; #20 104-121), bottom rim **207 209 220 233** (Mac 207 210 221 234), under the list 110 137 205 (109 137 205). Light over white: gap **165 165 167 168 169** (Mac 164 165 166 167 168). **List top row over white +21 / +22: 136 129** (Mac 100 119), over grey 89 79 (Mac 85 83) (`05`) | **confirmed**; top row regression **reproduced** |
| 8 | Finder list header pocket; ⋯ second click | list view scrolled under the header (dark): the rows show through the header strip, R at 52 / 58 / 64 / 70 / 76 pt **50 55 52 49 53** (Mac 47.7 54.5 52.2 49.6 53.6; scroll offset not matched to the Mac's 36 pt). ⋯: four clicks open / close / open / close. The Group button: the second click leaves the menu open (OPEN-FIXES 10, pending) | **confirmed**; Group still open |
| 9a | hold shine (BigGlow over the whole glass) | Settings preview share capsule held 0.7 s, held - rest by distance inside the capsule (`shine.py`, same code on the Mac pair): dark R/G/B 9-15 pt **+76/86/83**, 18-21 +47/58/66, 30-33 +37/50/58, 48-51 +22/34/42 (Mac by this code +89/93/90, +63/68/72, +56/60/66, +39/41/45; the Mac's held still is also scrolled a few pt); light +21/16/6, +17/13/5, +18/17/4, +12/18/1 (Mac +9/8/8, +24/19/8, +25/22/7, +24/21/4). No square: largest neighbour step at the old edge **0.5 dark / 0.2 light** (Mac 1.1 / 0.4) (`09`) | **confirmed** (smooth, whole capsule); level 10-17 under the Mac's beyond 18 pt by my metric; light's darker disc missing (stated) |
| 9b | back / forward lift | Settings back held, light: left / right rims **-3 / +2 px**, top / bottom -2 / +2 px (Mac -3 / +3, -1 / +1..2); pressed face 255 end to end (Mac 255) | **confirmed** |
| 9c | knob acceleration stretch | Desktop & Dock > Size, a fling right, stop, fling left, stop (vptr 8 ms steps), mcap per frame: lens chord 10 pt above the centre **24.0** held; 24.5 -> **26.5** in the 50-100 ms after each stop, then **21.5-22** at 0.2 s, back to 24 (Mac full width 26.5 held, 24-30 in its fling: wider after a start / stop, narrower 0.15-0.25 s after). The Mac path replay (rms 0.73 pt) not repeated | **confirmed** in kind and size |
| 9d | CC end-glyph bounce | CC Sound dragged to 0 (stub), speaker.fill ink box per frame: **18x27 -> 24x34 (x1.33 / 1.26) at ~+0.2 s -> 17x24 (x.94 / .89) at ~+0.4 s -> 18x27 at ~+0.52 s** (Mac 18x26 -> 23x33 x1.27 at +0.22 -> 16x24 x.91 at +0.45 -> rest +0.6) | **confirmed** |
| 10 | emoji at alpha 1 in translucent labels | Finder list "Report 😀👍🏽🇮🇩.txt", inner emoji pixels light vs dark: **875 px, mean 0.00, max 0** (Mac 795 px, mean 0.05) (`08`) | **confirmed** |
| 11 | banner shadow, ⌘ spacing | banner light / grey darkening at 1-40 pt **10 9 8 6 3 1 0** (#20 the same; Mac 10 9 7 5 3 1 0). ⌘ 1: ⌘ **21 px** wide, gap **10 px**, digit 8 (Mac 25 / 9 / 9) | **confirmed** (⌘ glyph 2 pt narrow, stated) |

## Regression sweep

| surface | checked | result |
|---|---|---|
| alerts | appear light x3, dark x2, Esc light x3 / dark x2, stills both modes | claim 1; light rims to the level, dark side 46 |
| menus | Apple menu dark over grey | side **46** on every row (#20 53) |
| Finder menus | context menu close by a click outside | .051 .158 .310 .463 .596 .703 .787 .854 .904, first fade frame 14 ms: as #20 |
| Finder toolbar | ⋯ x4, Group x3, view switcher | ⋯ toggles; Group second click stays open (old) |
| Settings | Appearance, Desktop & Dock, back / forward | claims 5, 9 |
| CC | dark held lens over grey, end glyph | claims 6a, 9d |
| NC + banner | dark over grey, light banner shadow | as #20; side lines claim 6d |
| Spotlight | dark over grey / white, light over white | claim 7; top row over white 136 (known) |
| HUD | 12 key runs dark over grey | claim 4 |
| Mission Control | open / Esc with Finder + foot | opens, exits |
| shell log | whole session (39 lines) | no TypeError, ReferenceError or binding loop; **0 x "'pad' does not have a matching property"** (#20 71) with CC and Spotlight opened. Left: libpng iCCP x21 (the Mac-colour test PNGs), qt.svg path x4, StackArt / NC "broken.png" and my 2-byte "Photo 🌅.png" decode warnings, portal, brightnessctl missing, text-input enable/disable x3 |
| tests | `node shell/tests/run.mjs` | **411 passed, 0 failed** |

## Per dimension

| dimension | j20 | j21 | change | reason |
|---|---|---|---|---|
| animation | 92.5 | **92.9** | +0.4 | [21 live] alert fades in on the window alpha with no speck; HUD anchor and per-frame curve at the Mac's, first frame 21-38 ms after the pop (was 57-63); knob deformation; CC end-glyph bounce; segmented lift; inactive lights snap |
| transition | 91.1 | **91.25** | +0.15 | alert dismiss blur 0.80 pt at frame 1 both modes; HUD appear from its anchor |
| visual | 94.0 | **94.25** | +0.25 | Settings dark tint follows the desktop; list rows under the header; hold shine without a square; minus the Spotlight top row |
| behaviour | 93.75 | **93.85** | +0.1 | segmented hover / press / jump, inactive window lights; Group menu still reopens |
| shape | 92.35 | **92.5** | +0.15 | HUD scales about its anchor; back / forward and segmented lifts; knob geometry under acceleration |
| colour | 95 | 95 | 0 | at target |
| shadow | 94.75 | **94.9** | +0.15 | alert light small-scale halo gone; Spotlight one window shadow (gap within 1) |
| refraction | 94.1 | **94.3** | +0.2 | CC line per fill row, preview dark ends, dark side rims, Spotlight bottom rim, hold shine; minus the Spotlight top row |
| icon | 93.6 | 93.6 | 0 | nothing new |
| font | 95 | 95 | 0 | [20] |
| rendering | 90.75 | **90.95** | +0.2 | speck gone; a true Gaussian on the dismiss; the HUD's faint first frames drawn |
| sound | 90.25 | **90.35** | +0.1 | pop 44 ms: pill -> pop 51 (Mac 49), pop -> first HUD frame 21-38 (Mac 18) |

Plain mean of the 12: 93.24 (j20 93.10).

## Per surface

| surface | weight | j20 | j21 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 94.75 | **94.85** | menu dark side line 46 (Mac 47). Left: light secondary text not vibrant, five Focus modes dimmed |
| Dock | 14 | 94.75 | 94.75 | no change claimed |
| Window chrome | 14 | 92.75 | **93.2** | #20's three alert defects fixed (speck, 1.6x dismiss blur, light halo), dark side line at the Mac's, inactive lights snap with full glyphs. Left: in-window AlertPanel blur not verifiable, Qt windows activated by a light press, inactive grey 75 vs 67 |
| Finder | 13 | 93 | **93.4** | list rows under the header, emoji at alpha 1, segmented control. Left: Group / View menus reopen, light tint above the pocket line, header line opaque |
| System Settings | 10 | 95.25 | **95.5** | dark tint per desktop within 2, hold shine, back lift, knob deformation, preview dark ends |
| Control Center | 6 | 94 | **94.3** | line per fill row, end-glyph bounce. Left: dark fill -4.6, light lens over the module |
| NC + banners | 6 | 92.25 | **92.4** | dark side lines closer (banner at the Mac's, NC 4-7 dark), emoji at alpha 1 |
| Spotlight | 6 | 90.75 | **91.0** | gap and bottom rim within 1-2 in three conditions; minus the dark top row over white (136 vs 100) |
| Mission Control | 4 | 91.25 | 91.25 | [20] |
| Sounds | 4 | 90.5 | **90.6** | pop 44 ms after the level, in step with the HUD |
| HUD | 3 | 91 | **91.5** | anchor and curve frame for frame; first frame 3-20 ms late and a little faint |
| Cmd-Tab | 3 | 91 | 91 | [20] |
| Apps | 2 | 86 | 86 | [20] |
| Lock screen | 5 | 91.5 | 91.5 | [20] |
| *Stage Manager (extra)* | *2* | *85* | *85* | [20] |

Weighted: 13 surfaces 9336.35 / 100 = 93.36. With the lock screen 9793.85 / 105 = 93.27. With Stage Manager
9506.35 / 102 = 93.20.

## Regressions

- **Spotlight dark list, top row over white** (with GLASS-HIG §17, already listed as OPEN-FIXES 17): rows +21 / +22 under
  the bar's rim read **136 / 129** where the Mac has **100 / 119** (a dark line under the list's top edge); over grey
  89 / 79 vs 85 / 83. #20 did not measure the row; the dev's before was 119.
- None else found. The NC card's dark side line moved past the Mac's (40 vs 44-47, was 67 vs 54 by the dev's reading).

Defects still open: Spotlight dark top row over white (+36); HUD first frame 3-20 ms after the Mac's and fainter (energy
.023 vs .031: by #20's > 4-level rule pop -> HUD 38 ms vs 18); CC dark lens fill 219.4 vs 224.0 and the light lens over
the module; Finder Group / collapsed View menus reopen on a second click, light tint above the pocket line (3-5 levels),
list header line opaque (#E5E5E5 vs an alpha line); hold shine in light has no darker interaction disc (+21 vs +9 at
9-15 pt); Qt windows (Finder, Settings) activated by a light press; inactive light grey 75 vs 67; NC card dark side line
4-7 dark; ⌘ glyph 2 pt narrow; MC menu bar fades in early, five Focus modes dimmed, light module secondary text not
vibrant ([20]).

## The next 10 changes, by gain

Repo only:

1. Spotlight: the list's top row over white (a dark line under the top edge over white, bright over grey: a plugin
   term, OPEN-FIXES 17) (+0.03).
2. HUD: first frame one frame earlier or ~30 % brighter (energy .023 -> .031 at the Mac's first frame) (+0.02).
3. Finder Group / collapsed View buttons: the ⋯ fix (`closing`, `menuUp` / `inMenu`) (+0.02).
4. CC dark lens fill +4.6 and the light lens over the module (+0.01).
5. Hold shine, light: the interaction disc darker under the pointer (`MacButtonGlassInteractionFill`, not decoded) (+0.01).
6. Finder: list header line as an alpha line; light tint above the icon pocket line (+0.01).
7. Qt windows not activated by a light press (light rects in the compositor) (+0.01).
8. NC card dark side line 40 -> 45 (its own bias, not Regular's) (+0.005).

Needs the Mac:

9. A Finder in-window alert over plain content (the AlertPanel dismiss blur cannot be fitted over icons) (+0.01).
10. A Mac shot scrolled 60+ pt under the Finder icon pocket (the strip above the line) (+0.01).

## Reachable ceiling

About 93.5 with the repo items 1-8. About 93.55 with the Mac captures. 95 is not reachable on this stack for judge #7's
reasons (about 3 points: no glass in third-party windows, GTK / Qt apps, output latency, Stage Manager, Apps).

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 92.9 | HUD first frame a little late / faint, MC menu bar early, grid half a frame behind | none (repo 2) |
| liquid glass | refraction + visual | 94.3 | Spotlight top row, CC dark fill, light hold disc, no glass in third-party windows | repo 1, 4, 5 |
| glass refraction | refraction | 94.3 | as above; NC side line 4-7 dark | repo 1, 4, 8 |
| shadows | shadow | 94.9 | at the Mac's in every case measured (alert small scale, banner, Spotlight gap) | none |
| depth | shadow + rendering | 92.9 | HUD faint first frame; rendering items from #20 | repo 2 |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 93.85 | dismiss blur now at the Mac's; Finder pocket strip, AlertPanel blur unverifiable, Spotlight list appear blur not measured | repo 6; Mac 9, 10 |
| sound | sound | 90.35 | output latency; Empty Trash / poof / shutter not filmed | Mac audio of Empty Trash, poof, shutter |
| icon | icon | 93.6 | rtf / generic / app documents; ⌘ glyph narrow | Mac renders of document pages |
| emoji | (direct) | 95 | equal in banners, names and now translucent labels (alpha 1, light = dark) | none |
| font | font | 95 | at target | none |
| scaling | (direct) | 91.5 | not re-shot at 1.5; runtime scale change needs a shell restart | a run with the shell restarted at 1.5 |

## Crops (`reference/judge-95-21/`)

`01-alert-appear-first-4-frames-light-grey127-x8-mac-top-ours-bottom.png` (difference from grey x8, 1 px per pt),
`02-alert-esc-frame1-dark-grey127-text-mac-left-ours-right.png`, `03-hud-appear-dark-grey127-frames-83-50-17+17+67+250ms-
mac-top-ours-bottom.png` (aligned on s .941), `04-settings-dark-flat-red-left-half-mac-left-ours-right.png`,
`05-spotlight-dark-white-bar-gap-list-top-mac-left-ours-right.png`, `06-lights-inactive-finder-dark-hover-frames-1-3-
press-frames-1-2-5-x2.png`, `07-segmented-dark-rest-hover-press-drag-release-away-ours.png`, `08-emoji-finder-list-ours-
light-top-dark-bottom.png`, `09-hold-shine-share-dark-mac-top-ours-bottom-rest-left-held-right.png`,
`10-cc-sound-held-lens-dark-grey127-mac-left-ours-right-x4.png`. All true colour except 01-03 (grey).
