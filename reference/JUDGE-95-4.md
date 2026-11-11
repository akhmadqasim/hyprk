# hyprk independent judge #4: 95 % goal check (2026-11-11)

- Commit at start and end: **35a6947** (57 commits in 3cbd531..HEAD). Working tree clean except my outputs.
  `plugin/build/libliquidglass.so` sha256 3c87e169251d3cb3…, `plugin-motion/build/libhyprkmotion.so` 835a786f6e92089b…, the
  same at start and end. Glass .so built 15:15:29, last `plugin/src` commit b819914 15:15:26. Motion .so 15:07:21, last
  `plugin-motion/src` commit 96fd560 15:07:18. Finder binary 15:16:11, newest `finder/src` file 15:16:07 (QML loads from
  the tree). So everything measured is the current code.
- Ground truth: `reference/screens/27.2.1/**` (verify/C2, panels, dock, settings, finder), `reference/re/MAC-ANSWERS.md`
  (R2 series, Q-dock-17/27/28, Q-menubar-33), `reference/re/27.2.1/live/**` (verify/A hud-appear-fit, nc/motion.json,
  finder/crops, dock/mission-control.json), `reference/re/LOCKSCREEN-27.2.1.md` (B1-B3, A2, A3),
  `reference/ours/windows/SHADOW.md` (Mac Q-windows-01 numbers).
- Ours: one headless session started only with `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (MBA 2560x1664 at 2x), own
  `HYPRK_STATE`, `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG`, muted, PAM test double. Driven with `qs ipc --pid`, `hyprctl dispatch`
  (my instance only), `grim`, `mcap`/`mcap.py`, a scratch vptr (plus right click) and a scratch vkbd (plus held Super and
  Shift). Finder and Settings ran with a private D-Bus, HOME and XDG dirs in scratch. Backdrops: flat white, grey 127,
  grey 114, black, and 4 pt black/white stripes. Note: `lockscreen/tools/build-vkbd.sh` was run once and made (and
  removed) a temp dir under /tmp before I built my own copy in scratch.
- **Measured on screen:** 23 motion rows, about 110 captures (table below), shadow in 4 states, CC over 4 pt stripes vs
  the Mac crop, Spotlight bar shadow (light and dark), lock clock and date ink, 20 unlocks per region, 3 lock-ins,
  3 shakes, Finder icon view / folder context menu / tab bar / Quick Look, Settings Appearance / Displays / Wallpaper /
  Sound, Dock in Dark / ClearDark / TintedDark / ClearLight, Dock label tail, Dock drag-off with and without a window,
  yellow-light minimize, Dock-click restore, green light, full-screen bar peek, Cmd-Tab, Mission Control 1 / 2 / 4 windows.
- **By code only (no helper agents):** sound wiring (`shell/scripts/sound.sh`, `shell/services/Panels.qml:83-84`,
  `packaging/install.sh:46`) plus one live poof in `HYPRK_SOUND_LOG`. NC calendar week start (1c68693, not looked at).
- Not re-measured (scored conservatively, from judge #3 or docs): menu bar pulldowns, Apps panel, Dock bounces and
  magnification, banners, HUD lens look, CC flat colours, glass over 8 pt stripes, multi-monitor.
- Same scale: 95+ a careful observer can't tell it from the Mac, 85-94 small measurable differences, 70-84 visible at a
  glance, below 70 clearly different.

## Overall: **89** (old 13-surface weights: 88.7; judge #3 88) and **89** with the lock screen (88.6)

- Old weights (menu bar 15, Dock 14, windows 14, Finder 13, Settings 10, CC 6, NC 6, Spotlight 6, MC 4, sounds 4, HUD 3,
  Cmd-Tab 3, Apps 2): 88.7.
- Lock screen at weight 5, others x0.95: 88.6.
- Plain mean of the 12 dimensions: 88.7.
- The gains (shadow, colour, sound, behaviour, Mission Control exit, Quick Look) are partly eaten by three new visible
  faults: ghost lines during the genie, the full-screen strip popping black in one frame, and the window jumping over
  the strip on full-screen exit.

## Per dimension

| dimension | j1 | j2 | j3 | j4 | evidence (ours vs Mac, measured unless marked) |
|---|---|---|---|---|---|
| animation | 69 | 80 | 86 | 86 | Close over the desktop .32 .58 .74 .85 .91 (Mac .29 .56 .73 .84 .91), rms .007-.015 / 0.9-1.8 ms (4 runs). Zoom .011 / 3 ms, 269 ms. MC exit 1 window **267-285 ms** (Mac 267), rms .013-.019 / 4.5-8.6 ms, first frame .17 (Mac .21) (judge #3: 368 ms). QL open .68 .79 .87 .92 .95 .97 .98 .99, **no repeated frame** (4/4). CC open 234 ms, .010-.014. NC open .007-.009 / 2.4-3.3 ms (2 of 3, one repeat .029). Off: HUD appear .034-.045 / 17-21 ms (no better than judge #3), HUD dismiss 334-386 ms vs 283 with a 3 % tail lingering ~150 ms, MC enter first frame repeated 3/3, frames lost mid-motion in most rows (CC 3/4, shake 3/3, genie 3-8 per run) |
| transition | 76 | 80 | 86 | **84** | Full screen enter: the whole 34 pt bar strip goes 120 → 0 in one frame, then 3 held frames at .09 (rms .028-.029 / 17-18 ms, judge #3 .003-.004). Full screen exit vs the decoded (0.25,0,0,1) 0.5 s curve: .014 / 7 ms, 402 ms vs 383, and frame 1 shows the window over the strip with the bar titles under its traffic lights (2/2, `01`). Unlock: menu bar 5 / 95 % at +152 / +261 (Mac +137 / +250), clock 95 % +253 (Mac ~+219), Dock 95 % +253 (Mac +226), wallpaper un-dim starts at +152 (Mac at once, .33 by +100). Lock-in matches (bar 95 % +67-74, Mac 67, Dock 121-152, Mac 117). Restore genie ends with a 14 % shadow pop (3/3). Spotlight open still has no blur |
| visual | 84 | 87 | 89 | 90 | CC tiles over 4 pt stripes like the Mac crop (`02`). Spotlight bar now casts the Mac shadow. Finder icon view, folder menu, tab bar, Settings Appearance and Sound panes close to the Mac shots. Off: QL of a PDF shows an info card, not the page. MC has no Spaces-bar blur band, and windows with plugin title bars (foot) lose their lights and title in the thumbnails. Settings Displays has no laptop picture and no scaling row (headless output) |
| behaviour | 68 | 80 | 85 | 87 | Folder context menu rows in the Mac order (Ask Siri and Paste Item absent, Customize Folder disabled). Ctrl-T opens a tab. Green light → full screen at 0,34 (`fullscreen 2`). Yellow light minimizes (genie). A Dock click restores a minimized foot. Dock drag-off with a focused window: icon follows, "Remove" bubble, poof logged, item removed. Off: drag-off does nothing on an empty desktop (confirmed). The bar peek did not appear after the first green-light full screen (1 of 3 entries, then it worked). MC lays 4 windows in a scaled grid (Mac Q-dock-28 keeps scale 1 and the spatial layout when they fit) |
| shape | 78 | 88 | 89 | 89 | Dock label tail base 14.5 pt, height 6 pt (Mac 16 x 6.5; judge #3 12). Menus 272 pt (judge #3). MC layout differs (above) |
| colour | 92 | 92 | 92 | 93 | Lock over grey 114: clock interior +93/+83/+93 (Mac +89/+80/+88), **date ink +133** (Mac +127; judge #3 +77). Dock label fill dark 34-39 over black (Mac 31) |
| shadow | 76 | 84 | 89 | **93** | 2 / 8 / 16 / 32 pt, white: light active side .19 .15 .09 .02 below .32 .29 .23 .11 above .07 .04 .02 0 (Mac .18 .14 .09 .02 / .32 .28 .22 .09 / .06 .04 .02 0). Light inactive .10 .04 .01 0 / .17 .11 .04 0 / .04 .01 0 0 (Mac .09 .04 0 0 / .16 .10 .03 0 / .03 .01 0 0). Dark inactive .18 .07 .01 0 / .33 .21 .06 0 / .06 .02 0 0 (Mac .19 .08 .01 0 / .33 .21 .06 0 / .06 .02 0 0). Dark active .33 .24 .15 .04 / .55 .49 .38 .17 / .11 .07 .03 0 (Mac .33 .25 .15 .04 / .56 .49 .38 .17 / .11 .07 .03 0). Spotlight light below 174 177 181 184 188 (Mac 172 175 178 181 185), above 237 240 242 (same). Off: no shadow during the genie, MC Spaces band shadow missing |
| refraction | 78 | 66 | 88 | 88 | CC over 4 pt stripes, dark, aligned on the Display tile (`02`): interior rows p2p 7-8 vs Mac 9-10, means within 0.4, gap rows p2p 33 vs 39, means 114.6 vs 114.8. The tile top and bottom rim rows are flat in ours (p2p 2-3) where the Mac's show the stripes (31 / 51). Rounded end not separately re-measured |
| icon | 74 | 85 | 86 | 87 | ClearDark / TintedDark / ClearLight exist with a glass edge (not verifiable: no Mac Dock in those styles). Text files show the lined page. Off: Trash and the Downloads stack keep full colour in every style; the Mac Dark Dock (`dock/dock-dark.png`) has a dark Trash. One JPEG in the demo tree shows a generic glyph instead of its thumbnail |
| font | 95 | 95 | 95 | 95 | No new font measurement. Menus, Settings and lock clock look like the Mac side by side |
| rendering | 89 | 90 | 91 | **88** | Genie minimize and restore draw **ghost lines**: a thin rectangle outline offset right of the bending window and a vertical line down to the Dock (minimize and restore, every frame inspected, 3 runs, `03`). Full-screen exit frame 1 overlap (above). Frame loss mid-motion in most captures (host had 3 stale sessions) |
| sound | 72 | 74 | 80 | 84 | By code plus log: dialogs beep only with `beep: true` (`Panels.qml:83-84`). Poof now has a caller (logged `poof … poof item off dock.aif` on drag-off). install.sh ships the 23 originals (`SHIP_SOUNDS_RE`, line 46), PKGBUILD/spec/flake too (3450d80). Volume Mount after copy/move is now backed by the Finder binary (86ebb9b, not re-checked by me). Left: alert volume scales every UI event (`sound.sh` sets vol=1 only for volume and power), no Mac data |

## Per surface

| surface | weight | j1 | j2 | j3 | j4 | evidence |
|---|---|---|---|---|---|---|
| Menu bar + menus | 15 | 83 | 90 | 92 | 92 | Peek on the full-screen strip: linear in/out, rms .014-.051, first frame repeated 6/6, one skipped frame 2/3; failed once. Pulldowns not re-measured |
| Dock | 14 | 85 | 89 | 90 | 89 | Drag-off + Remove + poof work with a window; nothing on an empty desktop. Restore from Dock works but with ghost lines and an end pop. Label tail 14.5 vs 16. Trash not styled |
| Window chrome | 14 | 65 | 85 | 89 | 87 | Shadow matches in all 4 states (≤ .02). Close, zoom match. Full-screen enter strip pop and exit overlap frame. Genie ghost lines |
| Finder | 13 | 76 | 82 | 86 | 88 | Context menu rows, tab bar, QL first frame fixed, text icons. QL for PDF is an info card |
| System Settings | 10 | 86 | 89 | 90 | 91 | Appearance, Sound close; Wallpaper thumbnails fill in after ~4 s cold; Displays differs (virtual output) |
| Control Center | 6 | 82 | 84 | 92 | 92 | `02` close to the Mac; rim rows flat; open 234 ms .010-.014 with a skipped frame 3/4 |
| NC + banners | 6 | 85 | 87 | 87 | 89 | Open .007-.009 (one run with a repeated frame). Week start by code |
| Spotlight | 6 | 78 | 85 | 84 | 86 | Shadow fixed (light and dark). Open: alpha ramp 100-135 ms, no repeats, still no blur |
| Mission Control | 4 | 80 | 84 | 82 | 85 | Exit 1 window fixed (267-285 ms). Enter first frame repeated 3/3. 2 / 4 windows: plateaus and a .68 first-frame jump (metric weak). No Spaces band, grid layout |
| Sounds | 4 | 72 | 74 | 80 | 84 | See dimension row |
| HUD | 3 | 92 | 86 | 85 | 85 | Appear .034-.045, dismiss tail lingers (334-386 vs 283 ms) |
| Cmd-Tab | 3 | 75 | 76 | 88 | 89 | Shows 210-215 ms after Tab in one frame (2/3; the 3rd had the fill one frame late), fades out ~200 ms |
| Apps | 2 | 78 | 83 | 84 | 84 | Not re-measured |
| Lock screen | 5 | – | 86 | 88 | 88 | Date ink fixed. Fade seen in 20/20 unlocks but frames lost in 18/20 (0-8 gaps in 300 ms). Timing 1-2 frames late, un-dim late. Shake shape matches the Mac's 1st attempt but a frame was lost in 3/3 (rms 2.5 pt) |

## Motion re-measured (mcap, my session) vs MOTION-MEASURED.md / MOTION-PLUGIN.md

| row | doc | mine | agree? |
|---|---|---|---|
| Window close (foot over desktop) | .28 .56 .73, .006-.010 | .32 .58 .74 .85, .007-.015 / 0.9-1.8 ms, 148-151 ms (4) | yes |
| Zoom | .010-.016 | .011-.012 / 3 ms, 269 ms (2) | yes |
| Unzoom | .019-.026 | .013-.014 / 7.8 ms, 369 ms 2-98 % (tail .97 → 1 over ~150 ms) (2) | value yes, tail longer |
| Full screen enter | .033 (doc), judge #3 .003-.004 | **.028-.029 / 17-18 ms**, 382-385 ms, bar strip black in one frame + 3 held frames (2) | **no**: regression since the strip (2915ccf) |
| Full screen exit vs decoded curve | judge #3 .004-.006 | **.014 / 7 ms**, 402 ms, frame 1 window over the strip (2) | **no** |
| MC enter 1 window | basic loop no repeat, threaded first frame twice | first frame twice 3/3, .013-.024 / 8-19 ms, 319-335 ms | yes (threaded ships) |
| MC exit 1 window | basic 267 ms .010; threaded 250-333, .029-.040 | threaded **267-285 ms, .013-.019 / 4.5-8.6 ms**, a skipped frame 2/3 | better than the doc's threaded row |
| MC exit 2 / 4 windows (stacked) | 300-333 / 200-260 ms | 317-335 ms .046-.077; 333 ms .12-.13 (metric unreliable with overlap) | roughly |
| CC open | .005 / 1.2 ms threaded | .010-.014 / 5-8 ms, 234 ms, skipped frame 3/4 | partly (frame loss) |
| HUD appear | session 8: .022-.029 | **.034-.045 / 17-21 ms**, 483-503 ms (5) | **no** |
| HUD dismiss | s7: 265-300 ms, .011-.017, no snap | **334-386 ms**, .020-.028 / 17-28 ms, last 3 % lingers (5 ipc + 2 auto) | **no** |
| NC open | .006-.016 | .007-.009 (2), .029 with a repeat (1) | yes |
| Spotlight open | 117-134 ms, 0 repeats | 119-135 ms, 0 repeats, 1 skipped frame in 3 | yes |
| Quick Look open | basic loop fix | .68 → 1, no repeat in 4/4 | yes (fixed) |
| Cmd-Tab show / dismiss | 215-218 ms, 1 frame | 210-215 ms, 1 frame in 2/3; fade ~200 ms | yes |
| Minimize genie (yellow) | .024 / 8.8 ms | .023-.030 / 9-11 ms (changed metric), 3-8 lost frames, **ghost lines** | value yes, picture no |
| Restore from Dock | "restores now" | .05-.06 / 30-38 ms, **14 % pop at the end**, ghost lines (3) | not covered by the doc |
| Full screen bar peek in / out | 150 / 170 ms linear, .004-.006 clean | .014-.051 / .026-.030, first frame repeated 6/6, skipped frame 2/3, once no peek | **partly** |
| Dock drag-off | does not work on an empty desktop | confirmed | yes |
| Lock-in | (judge #3: 2 still frames) | bar 95 % +67-74, Dock +121-152, field +191-222, no still start, 2-4 lost frames | improved |
| Unlock (20 runs) | menu bar 125-142 / 244-263, clock 214-232, fade 70/70 | menu bar 137-170 / 250-287, clock 95 % 233-271, Dock 233-271, fade seen 20/20 but frames lost in 18/20 | **no**: 1-2 frames later than the doc, many more lost frames |
| Shake | judge #3 1.3 pt | same shape, one frame lost in 3/3 (rms 2.5 pt vs 1st attempt) | partly |

Reported limits: "one frame lost between swap and presentation" confirmed and broader than the doc says (CC, shake,
peek, MC, unlock, genie). "Unlock crossings in two modes one frame apart" not seen as two clean modes: my spread is
continuous (233-271 ms). Drag-off on an empty desktop: confirmed.

**Full screen exit.** Scored against the decoded REA curve (0.5 s, (0.25,0,0,1), no hold) as judge #3 did. The curve fit
itself is still fine (rms .014). What costs points is new: the first exit frame and the enter's instant black strip.
If the Mac really holds (R2 two steps), transition loses about 2 more points. Only a per-frame Mac recording settles it.

## Ranked gap list (weight x points lost; gain in overall points)

| # | surface | dim | ours vs Mac | owner | Apple data | est. gain |
|---|---|---|---|---|---|---|
| 1 | Windows, Dock | rendering, transition | Genie draws ghost lines (outline + line to the Dock) on minimize and restore, no shadow during it, 14 % shadow pop at the end of restore | `plugin-motion/` (genie), `plugin/src/WindowShadow.cpp` and the rim (b819914, 3e73468) | yes: #42 a genie track | +0.6 |
| 2 | Windows | transition, rendering | Full screen enter: strip 120 → 0 in one frame, 3 held frames, rms .029 (was .004). Exit: frame 1 shows the window at y 0 over the bar titles | `plugin-motion/` (fullscreen_top), `shell/modules/MenuBar.qml` | yes: R2 enter series, Q-menubar-33 | +0.5 |
| 3 | all motion | animation, rendering | One frame lost mid-motion in most rows (CC, shake, MC, peek, unlock 18/20, genie 3-8) | Quickshell threaded loop / Hyprland presentation (MOTION-MEASURED session 8) | n/a | +0.4 |
| 4 | Finder | visual, behaviour | Quick Look of a PDF shows an info card; Mac shows the page | `finder/qml/QuickLook.qml:29-30,306` | yes: Q-finder-26 (images only) | +0.3 |
| 5 | Lock | transition | Unlock 1-2 frames late (clock 95 % +253 vs +219, Dock +253 vs +226), wallpaper un-dim starts +152 (Mac at once), clock fade slow-start (≈.10 at +85 vs .30) | `shell/modules/lock/LockOverlay.qml`, `lock.js` | yes: LOCKSCREEN B3 | +0.25 |
| 6 | Dock | icon | Trash and Downloads stack never take Dark / Tinted / Clear | `themes/icons/`, `shell/modules/Dock.qml` | partly: `dock/dock-dark.png` (dark Trash) | +0.25 |
| 7 | Mission Control | visual, behaviour, shape | No Spaces-bar blur band + shadow; plugin title bars missing on thumbnails; 4 windows in a scaled grid (Mac scale 1, spatial); enter first frame twice | `shell/modules/MissionControl.qml`, `plugin/` | yes: Q-dock-27/28/31, `mission-control.json`, `dock/mc-*.png` | +0.25 |
| 8 | Dock | behaviour | Drag-off does nothing on an empty desktop | `shell/modules/Dock.qml` (drag needs a focused surface) | yes: Q-dock-17 | +0.15 |
| 9 | HUD | animation | Dismiss 334-386 ms vs 283, last 3 % lingers; appear rms .034-.045 | `shell/modules/HudWindow.qml`, `shell/components/Glass.qml` | yes: REA dismiss spring, hud-appear-fit | +0.15 |
| 10 | Spotlight | transition | No content blur 25 → 0 on open | `shell/modules/Spotlight.qml` | yes: MAC-ANSWERS Spotlight REA | +0.15 |
| 11 | Menu bar | behaviour, animation | Peek missed once after a green-light full screen; first frame repeated 6/6 | `shell/modules/MenuBar.qml:43-80` (readStrip timing) | yes: Q-menubar-33 | +0.1 |
| 12 | CC | refraction | Tile rim rows flat (p2p 2-3) vs Mac 31 / 51; interior p2p 7-8 vs 9-10 | `plugin/` (rim pass) | yes: `verify/C2/cc-real-stripes-*.png` | +0.1 |
| 13 | Sounds | sound | Alert volume scales every UI event; no Mac measurement | `shell/scripts/sound.sh:78` | no | +0.1 |
| 14 | Dock | shape | Label tail base 14.5 vs 16 pt, height 6 vs 6.5 | `shell/modules/Dock.qml`, `plugin/src/Shape.cpp` | yes: MAC-ANSWERS:1524 | +0.05 |
| 15 | Windows | animation | Unzoom tail .97 → 1 over ~150 ms (2-98 % 369 vs 267) | `plugin-motion/` | yes: R2 unzoom | +0.05 |

## Cannot reach on this stack

- Trackpad momentum and rubber band outside hyprk's Qt views (no Wayland momentum events).
- Third-party app menus in the global bar (GTK4 and most Wayland apps export no menu model).
- Glass inside client windows (Qt toolbars can't sample what is behind the window).
- Live relayout during zoom (Hyprland stretches a buffer).
- Frame-exact presentation: Quickshell sets the glass region from the GUI thread while the threaded loop commits from the
  render thread, and Hyprland answers a new layer's first frame callback at once; both lose or repeat frames. Partly
  fixable only in Quickshell / Hyprland, not in QML.
- Spotlight open blur: dropped frames when tried (MOTION-MEASURED).
- PAM delay, Touch ID, Siri, AirPlay, Apple Park art.

## Needs the Mac online

- A per-frame 60 fps recording of full screen enter and exit on the notched Air, with the 34 pt strip region cropped
  (does the strip go black at once, and is there an exit hold?).
- Mission Control with 4 windows of 700 x 500 stacked at one place (frames + a still), and the Spaces band over grey 127.
- Mac Dock in Clear, ClearDark, Tinted and TintedDark (whole Dock incl. Trash and stacks).
- A HUD dismiss track (alpha per frame) and the HUD over 4 pt stripes.
- Quick Look of a PDF (still + open series).
- Whether alert volume scales the screenshot, trash and mount sounds.
- Unlock per region at 60 fps over grey 127 (B3 is one run with dropped frames).

## Is 95 reachable?

Not on this stack in every dimension. Shadow (93), colour (93) and font (95) are at or near the goal. Refraction is
stuck at 88 on details (rims). Animation and transition are limited by lost and repeated frames that sit in
Quickshell and Hyprland. A realistic ceiling is about 91-92. The 5 changes that would move the score most:

1. Fix the genie's ghost lines, its missing shadow and the end pop (+0.6).
2. Make the full-screen strip arrive with the motion, not in frame 1, and fix the exit's first frame (+0.5).
3. Find the frame loss between swap and presentation (Quickshell region on the render thread, layer frame callbacks) (+0.4).
4. Quick Look page preview for PDFs (+0.3).
5. Unlock timing per B3 (start the un-dim at +0, clock ease-in from -87 ms) and a styled Trash / Downloads stack (+0.5 together).

## Crops

- `judge-95-4/01-fullscreen-top-strip-frames.png`: top 60 pt, frames of full screen enter (upper 6) and exit (lower 6),
  2x nearest. Enter frame 2 is black at once. Exit frame 2 shows the window's lights over the bar titles.
- `judge-95-4/02-cc-tiles-4pt-stripes-dark-mac-left-ours-right.png`: Display and Sound tiles, Mac C2 crop left, ours right.
  Cut below the host Now Playing card.
- `judge-95-4/03-dock-restore-genie-frames.png`: three restore frames with the ghost outline and line to the Dock.
- No lock, Settings account or full CC shots were saved: they show the user's initials or the host's Now Playing card.
