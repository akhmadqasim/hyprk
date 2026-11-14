# hyprk independent judge #12, HEAD 7c25576 + working tree (2026-11-14, 01:43-01:53 WITA, measured live)

Delta judgement against judge #11 (`JUDGE-95-11.md`, fdc1b2d, 90.7). Method and weights from `JUDGE-95-7.md`: 12
dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[12 live]** measured
on screen (or on the running scripts) here; **[11]** carried from judge #11; **[dev]** the developer's own measurement
in a commit message, not re-measured here, so not credited.

## What was judged

- Committed since fdc1b2d: eab86a4 (Dock label drawn over Mission Control), 0dc05d9 (Dock activation leaves Mission
  Control), 8b13236 (Mission Control re-lays out when a window opens or closes while open), 34747e4 / d2ee983 / bd0a565
  (Settings sidebar, inactive title, switch rows 37.5), dc48cca / f81f42c (NC app icon 32 at 13, heading x), 33fe036
  (Dock menu placement). 681b895, 67cc1c0, c54a39f, 7c25576: reference only.
- Working tree (not committed): Dock hover label width rule, Downloads stack (pile, fan / grid / list popup,
  `DockStack.qml`, `StackArt.qml`, `lib/dockstack.js`), the Mac's ZIP / PDF / text document art in the Finder and the
  stack, NC heading (18 semibold, 20 pt Clear All circle, 28 pt hit area), Settings card fill as 3 % primary,
  volume keys (Control Center path: pop on every step), Alert volume curve exp(s - 1) and default 1, double-click
  500 ms in the Finder (binary rebuilt 01:08:59, after main.cpp) and in the plugin's source. **The plugin binary
  (`plugin/build/libliquidglass.so`, 2026-11-12 11:23) is not rebuilt: the title bar still runs 400 ms.** Judged as it
  runs.
- Two sessions, one at a time: `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (2560x1664, scale 2, then 1.6 with
  `hyprctl eval hl.monitor`), scratch HOME from `finder/scripts/make-demo.py` with 11 files in Downloads (newest a ZIP,
  then a 1200x700 landscape JPEG, as in the Mac's `dock-dark.png` pile), scratch HYPRK_STATE / XDG_CACHE_HOME / TMPDIR,
  the script's private bus. Tools: `vptr`, `mcap` (2 runs, `long_intervals` 0), `grim`; the volume and sound scripts
  run against stand-in `wpctl` / `pw-play` that log their arguments. Both stopped with `smoke.sh --stop`, buses killed,
  runtime dir removed, only 161706 / 161746 left.
- Not re-measured: the three Settings commits (Settings did not relaunch for a second pane in session 2; carried with
  the developer's numbers as [dev]), shadow, colour, CC, Spotlight, Cmd-Tab, HUD, Apps, lock screen.
- Crops in `reference/judge-95-12/` (01-10).

## Overall: **91.1** (13 surfaces 91.12, with the lock screen 91.11, with Stage Manager folded in at weight 2: 91.00)

Judge #11: 90.7. The gain is mostly the Dock: the Downloads stack now has a popup (fan, grid, list) laid out by the
decoded Dock code, its pile and the Finder use the Mac's own ZIP / PDF / text pages, and judge #11's three Mission
Control findings are fixed. Sound moves on a static decode of Control Center's hot key path and the alert gain curve,
both verified rule by rule on the scripts. What is not credited in full: every stack number that rests on a guess or
an inference (the fan's vertical place, both durations, the chevron), and nothing of it has a Mac picture.

## Measured

### Dock

| item | ours | Mac | source | verdict |
|---|---|---|---|---|
| hover label "Finder", width (diff against the label-less frame, includes about 0.5 pt halo each side) | 69 (j11 / dev: 70-71) | 67.5 | Q-dock-08; rule ceil(text) + 26 from GAPS-REA-dock 2 | closer by about 2, rule confirmed in code `09` |
| Downloads menu: body left of the icon centre / bottom above the Dock top | 26 / 14 | 27 / 13 | Q-dock-10, 33fe036 | match within 1 |
| pile at tile 33: front ZIP page bbox | 44 x 58 px | 42 x 59 px | `dock-dark.png` | match within 2 px `01` |
| pile: items behind | photo + a third item (both visible at the sides / top) | one photo visible, centred 8 px above the page centre | `dock-dark.png`, decode `_maxNumberOfCollapsedItems` 3 | geometry plausible; the Mac shot cannot show whether a third item exists |
| grid, 11 items + Open in Finder: width | 547 (rim included) | 546 (AX group) | Q-dock-12, dock-live.json | match |
| grid: height body top to tail tip | 428.5 (formula 438 with the 12 pt band) | 438 (AX) | same | match by formula |
| grid: bottom against the Dock top | tail tip about 20 above | AX group bottom 1051 against the Dock top 1050 in `dock-dark.png` (if the same Dock) | dock-live.json + dock INDEX | **not settled**: could be 11-20 pt off, needs the Mac `03` |
| fan: vertical step | 64.75 | 64.6 | Q-dock-12 | match `04` |
| fan: item size bottom to top | constant (64 box) | grows 65.5 -> 78.3 | Q-dock-12 | **differs** (fan item size setter not traced) |
| fan: first item above the tile | first item bottom about 17 above the Dock top | no picture | `lib/dockstack.js` says GUESS | unverified |
| fan open (alpha, 320 x 620 pt) | starts +80 ms, .69 .84 1.00, ends +300 ms | no track; 0.25 s ease-in-out inferred | MOTION-REA 3.3 | unverified; the end comes in steps of .15 |
| fan close | .17 .17 .48 .53 .61 .68 .68 .75 ... 1 by +240 ms (2 held values) | no track | | unverified |
| fan photos rotated | edges aliased (stair steps) at 2 and 1.6 `05` | CALayer edge antialiasing is off by default on macOS | | not counted |
| tile while open | chevron drawn | "its tile shows a chevron" (size not given) | Q-dock-12 | partial (size guessed) |
| Mission Control: hover a Dock icon | label shown over the layer | Dock works in MC (Q-dock-27) | eab86a4 | **fixed** (j11 finding) |
| Mission Control: click Notes in the Dock | MC exits, Text Editor launched and active | Mac leaves MC and activates | 0dc05d9 | **fixed** |
| Mission Control: a window opened while open | 3 thumbnails laid out, none covered | | 8b13236 | **fixed** |

### Finder, NC

| item | ours | Mac | verdict |
|---|---|---|---|
| ZIP icon at 64 pt | the Mac's render (`icons-rendered/doc-zip@64pt`) drawn as is `02` | same file | match by construction |
| double-click interval | 500 ms (Qt style hint set in the rebuilt binary) | 0.5 s HIDClickTime | match; **title bar 400 ms** (plugin not rebuilt) |
| NC heading: "Notification" ink width / cap height of N | 95 / 12 | 93 / 12 (1 px/pt shot) | within 2 `06` |
| NC heading: whole ink width | 156.5 "Center" | 155 "Centre" | within 1.5 |
| NC Clear All circle | 20 pt (j11: 24) | 20 (1 px/pt shot), code 20 | **fixed** |
| NC card app icon | squircle 32.5 at 12.5 from the card edge | 32 at 13 | match (dc48cca) |

### Sound (scripts with stand-ins, real files)

| rule (SOUND-REA-27.2.1 2) | ours | verdict |
|---|---|---|
| step pops at once, feedback on | up 16: 1 pop, .5 -> .5625 | match |
| Shift inverts, only Shift alone | feedback on: Shift 0 pops; off: Shift 1 pop; Option+Shift (64): not inverted, .625 -> .640625 | match |
| full volume: a pop on every step | 5 steps at 1.0: 5 pops | match (was 1 s pops) |
| key up plays nothing | 0 | match |
| mute silent, unmute pops at once | 0 / 1 (no 0.08 s wait) | match |
| repeat cadence while held | Hyprland's repeat (25/s after 600 ms, not set in config) | Mac kernel defaults 83 ms after 500 ms; stock user values not decoded: **pops come about twice as often** |
| Alert volume gain exp(s - 1) | s 0 / .25 / .5 / .75 / 1 -> pw-play --volume 0 / .4724 / .6065 / .7788 / 1 | match the table |
| default Alert volume | 1 | match (the jq-failure fallback in sound.sh still prints 0.75) |

### Emoji and scaling

- Emoji: Apple Color Emoji in a notification (QML) and in a GTK text field (Text Editor) `07` `08`: 😀 👍 🎉 ❤️ 🇮🇩 are
  Apple's glyphs, the same drawings as `panels/emoji-picker-dark.png`. The ZWJ family sequence draws as a single
  glyph (no fallback split). No Mac shot of emoji inside body text, so size and baseline are not compared. Edit >
  "Emoji & Symbols" is a row with no action: there is no emoji picker.
- Scale 1.6 against 2: Dock pile, fan (11 labels), NC heading, notification with emoji all laid out the same in points,
  text crisp, no clipping `10`. The fan's rotated photos alias the same at both. Not compared: the Mac draws a scaled
  mode at 2x and downsamples the frame, we draw natively at 1.6 (ours is sharper, metrics on fractional pixels); no
  Mac capture of a scaled mode exists in reference/.

## Per dimension

| dimension | j11 | j12 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | [12 live] stack fan motion exists but every duration and curve is inferred and the close holds 2 frames; no credit |
| transition | 90 | 90 | 0 | [12 live] MC re-layout with a new window right; no motion (no Mac data) |
| visual | 92 | 92 | 0 | [12 live] stack popup and label in MC (+); fan item sizes constant, grid vertical place unsettled (-) |
| behaviour | 90 | **91** | +1 | [12 live] Dock click leaves MC, stack click opens fan / grid / list, View content as works; volume pop per step |
| shape | 90 | **91** | +1 | [12 live] label width, Clear All 20, grid 547 / 546, fan step 64.75 / 64.6, Dock menu 26 / 14 |
| colour | 95 | 95 | 0 | [11]; Settings card fill is the same pixel on our opaque window background |
| shadow | 94 | 94 | 0 | [11] |
| refraction | 91 | 91 | 0 | [11]; fan pills and grid bubble on the plugin's glass, no Mac picture to compare |
| icon | 90 | **91** | +1 | [12 live] Mac ZIP / PDF / text pages in the Finder, pile and popups; pile page within 2 px |
| font | 95 | 95 | 0 | [12 live] NC heading 18 semibold confirmed in code, cap height 12 = Mac |
| rendering | 90 | 90 | 0 | [12 live] logs clean (qt.svg "invalid path data" x6, not traced); aliased rotated photos not counted |
| sound | 87 | **89** | +2 | [12 live] Control Center key path and alert curve, every rule checked; repeat cadence and output latency open |

## Per surface

| surface | weight | j11 | j12 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92.5 | 92.5 | carried |
| Dock | 14 | 91 | **92.5** | MC label and click fixed, menu placement, label width, stack pile and popup (partial: no Mac picture) |
| Window chrome | 14 | 90 | 90 | double-click still 400 ms (plugin not rebuilt) |
| Finder | 13 | 90 | **90.5** | Mac ZIP page, 500 ms double-click |
| System Settings | 10 | 92.5 | 92.5 | three commits [dev], not re-measured, not credited |
| Control Center | 6 | 93 | 93 | carried |
| NC + banners | 6 | 90.5 | **91.5** | heading font, Clear All 20, icon 32 at 13 |
| Spotlight | 6 | 88 | 88 | carried |
| Mission Control | 4 | 89.5 | **90.5** | label, Dock click, re-layout with a new window |
| Sounds | 4 | 87 | **89** | volume key path and alert curve |
| HUD | 3 | 90 | 90 | carried (step cadence while held follows Hyprland's repeat) |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91 | 91 | carried, not tested (rule) |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried |

Weighted: 13 surfaces 9112 / 100 = 91.12. With the lock screen 9567 / 105 = 91.11. With Stage Manager 9282 / 102 =
91.00.

## Regressions

None measured. Things to watch, not counted: the title bar and the Finder now disagree on the double-click interval
(400 against 500) until the plugin is rebuilt; `sound.sh`'s jq-failure fallback still says 0.75; the Downloads tile no
longer opens the folder on a click (intended: the Mac opens the stack).

## The next 10 changes, by gain

1. Mac capture of the stack: fan and grid stills at 2x and open / close at 60 fps. Settles the fan's vertical place
   (marked GUESS), item size growth, the grid's gap to the Dock, both durations, the chevron (+0.1, needs the Mac).
2. Mission Control exit with 4 overlapping windows, Mac recording (+0.1, needs the Mac).
3. Dock menu tail 23.5 x 13, tip r 5.46 (decoded, GAPS-REA-dock 1) (+0.05, repo only, plugin).
4. Fan item size: find the setter of the fan's `_itemSize` (Mac 65.5 -> 78.3) (+0.03, static decode, then repo).
5. Key repeat: decode the stock user KeyRepeat / InitialKeyRepeat and set Hyprland's `repeat_rate` / `repeat_delay`,
   so held volume keys pop at the Mac's rate (+0.03, static decode, then repo).
6. Emoji & Symbols picker for Edit > Emoji & Symbols and Ctrl-Cmd-Space (Mac shot `emoji-picker-dark.png`) (+0.05,
   repo only).
7. Rebuild the plugin so the title bar runs 500 ms (+0.01, repo only).
8. Spotlight reopen first frame (judge #10 / #11) (+0.05, repo only).
9. Knob lens lower highlight (B2 fit) (+0.05, repo only).
10. Settings Sound sliders: play 30 ms after the last let-go and stop the previous preview (+0.01, repo only).

## Reachable ceiling

About 91.4 with the repo's data (items 3, 5-10), 92-92.5 with new Mac captures (1, 2, and the area items below).

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 90 | MC 4-window exit; stack fan / grid motion inferred (0.25 s, curves); submenu drawn in 2 frames; lock-in held first frames | Mac 60 fps captures (MC 4 windows, stack open / close, lock-in); the submenu is repo only |
| liquid glass | refraction + visual | 91 | Dock menu without its tail; fan pills and grid bubble never compared; knob lens lower highlight; no glass in third-party windows (stack limit) | tail: repo (decoded); stack glass and lens: Mac stills over stripes |
| glass refraction | refraction | 91 | knob lens lower rim (x1.30 on the Mac, ours x0.95); refraction of the stack glass not compared | repo (B2 fit) + one Mac still per stack view |
| shadows | shadow | 94 | banner shadow not measured; Dock menu shadow with a tail | Mac stills (banner over grey 127) |
| depth | shadow + rendering (layer order) | 92 | which window flies on top in a multi-window MC exit is assumed; stage strip in MC unknown | Mac recording |
| opacity | colour | 95 | at target; Settings card now 3 % primary as decoded (same pixel here) | none |
| blur | refraction + visual | 91 | NC column blur ramp (1.5 x openProgress) not measured against ours; Dock / menu blur radius per material only by eye | repo (measure ours against the decode) + Mac 60 fps NC open |
| sound | sound | 89 | output latency (ours 26-40 ms to the player); repeat cadence; Dock drop-on-Trash sound not wired (no file drops); Settings slider 30 ms | latency: Mac audio + screen capture; repeat: static decode; the rest repo |
| icon | icon | 91 | no per-type art beyond ZIP / PDF / text (docx shows a blank page); pile third item unverified; stack chevron size guessed | Mac renders of more document types (static: extract from CoreTypes icns); Mac still of an open stack |
| emoji | (direct) | 88 | glyphs are Apple's (same font); no emoji picker; size and baseline in text never compared | repo (picker, Mac shot exists); a Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 90 | 1.6 lays out and renders like 2 here; the Mac's scaled modes render 2x then downsample, so stroke weight and fractional positions differ; not compared | Mac capture of a scaled mode (e.g. 1470 x 956 "looks like") of the Dock, a menu and NC |

## Crops (`reference/judge-95-12/`)

`01-stack-pile-tile33-mac-left-ours-right.png`, `02-finder-zip-64pt-mac-render-left-ours-right.png`,
`03-stack-grid-11-items-scale2-light-ours.png`, `04-stack-fan-scale2-light-ours.png`,
`05-fan-photo-edge-scale2-ours.png`, `06-nc-heading-mac-top-ours-bottom.png`, `07-emoji-notification-scale2-ours.png`,
`08-emoji-gtk-text-field-ours.png`, `09-dock-label-finder-ours.png`, `10-nc-scale1.6-ours.png`.
