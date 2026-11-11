# hyprk independent judge #7, commit 3ea26fe (2026-11-12, 05:38-06:20 WITA)

Same rules as judges #4-#6 (12 dimensions, 13 surface weights + lock screen 5; 95+ a careful observer cannot tell it
from the Mac, 85-94 small measurable differences, 70-84 visible at a glance). Every row says where it comes from:
**[3ea26fe]** re-measured by me on 3ea26fe; **[a2e61a0]** / **[573470c]** carried because the code behind it did not
change; **not measured** = nothing new credited.

## What was judged

- **Commit 3ea26fe** as a frozen copy (`git archive`), `reference/` linked to the live repo. `libliquidglass.so`
  copied from the live repo (sha256 f8d0eb1e…, built 04:43:48, after the last `plugin/src` commit d121a59 04:43:40);
  `libhyprkmotion.so` 7480f6b6… (no `plugin-motion/src` change since ff8771f). Finder built from the frozen tree.
- Own headless sessions only, ONE at a time after A: A (scale 2 light, 31 mcap runs, behaviour), B (scale 2 dark,
  4 pt stripes, stills, sound, knob lens), C (scale 1.6 light, 6 runs; then 2 for the lights), D (PAM test double,
  lock-in), E (dist setup) against F (smoke, 6 appearance runs). Each with a private D-Bus, scratch HOME / state /
  cache, `HYPRK_MUTE=1` + `HYPRK_SOUND_LOG`, stand-ins for `wpctl` / `pw-play` / `paplay`, and a private PipeWire
  (two null sinks, own runtime dir) for Quickshell, so nothing reached the user's mixer or speakers. Tools in scratch:
  `mcap`, `fscroll`, `vptr` (+ a right-click variant), `vkbd` and a raw-keycode variant (`vkey`: press / release,
  modifiers). Host load 1.3-3.4 (the user's browser); every motion row below had no capture gap (longest interval
  ≤ 20.4 ms) unless stated.
- Mac references: `re/MAC-ANSWERS.md` (R2, Q-menubar-23..31, Q-panels-32, Q-dock-*), `re/27.2.1/live/nc/motion.json`,
  `verify/A/spotlight-open-track.json`, `verify/B2/slider_fit.txt`, `screens/27.2.1/{windows,finder,dock,panels}/*`,
  `shell/SOUNDS.md` (decoded BezelServices / ControlCenter rules), the 23.09.23 recording (frames extracted to scratch
  only). Mac colours converted with `p3_to_srgb()`.

## Overall: **90** (13 surfaces 89.9, with the lock screen 89.9, plain mean of the 12 dimensions 90.75)

Judge #6 was 90 (89.5 / 89.6). Under the number: Mission Control's hold is gone and its single-window exit is on R2,
tag dots, wallpaper tiles and the Sound module glyph are fixed, and the volume keys now follow BezelServices rule for
rule. Against that, one **new regression** with real input: since f8bb588 the pointer merely *passing over* the
desktop makes Finder frontmost (no click needed), so the menu bar flips between the app and Finder as the pointer
moves, a click on a menu title reached from the desktop opens the wrong menu, and Cmd-H / Cmd-Q / Cmd-` act on
Finder. The 4-window Mission Control exit is still front-loaded.

## The four disputed findings

| finding (judge #6) | what I measured | verdict |
|---|---|---|
| MC 1-window exit first frame .59 | Same captures, both metrics (full output, `-k 8`, Settings 740 x 625, 4 of 4): `alpha` .23 .38 .51 .65 .74 .79 …, rms .030-.042 against R2, 218-235 ms; `changed` (share of samples over 12 levels) .68 .79 .86 …, rms .155-.161. R2 is "share of the total pixel change" (MAC-ANSWERS), i.e. a sum of change = `alpha`; `changed` counts every pixel touched by a faint cross-fade (bars) as done. Per region the Spaces bar now leaves .18 .39 .63 .78 (no one-frame drop) | **developers right** on the metric (judge #6's .59 was the `changed` metric; on the R2 metric the first frame is .23 against .21). Note 1 of 4 runs skipped a value (.79 → .86) |
| banner in: first value repeated | 3 of 3: .01 .05 .12 .21 .31 .41 .52 .63 .71 …, no repeat; out 1 .87 .58 .31 .16 .07 .03 .01, no repeat; longest interval 19-20 ms | **not reproduced** (fixed or never systematic) |
| appearance: 690 ms hold (1 of 20) | Shortcut with Settings open, 6 of 6: start +168-184 ms, 2-98 % 384-386 ms, spread over pane / bar / wallpaper / Dock .007-.008, monotonic | **not reproduced** (0 of 6 here, 0 of 30 for the developers); not called wrong, a 1-in-20 event cannot be excluded |
| `lights-press-zoom-dark.png` is not a pressed state | Pixel-identical to `lights-hover-dark.png` (max difference 0). The light pair differs: pressed zoom sRGB 143,255,77 vs hover 107,208,64, so the Mac **does** brighten the green light on press. Ours (foot, light session) hover 19,189,0 → pressed 19,228,0 | **developers right**: judge #6's "pressed zoom too bright" compared against a hover crop; the brightening is Mac behaviour (`07`). Side note: foot's title bar is drawn dark in light mode, so its lights use the dark set (not investigated) |

## Per dimension

| dimension | j5 | j6 | j7 | change | evidence and reason |
|---|---|---|---|---|---|
| animation | 88 | 89 | **90** | +1 | [3ea26fe] MC 1 window enter: flight from +105-140 ms, no hold, `alpha` rms .020-.033 against R2 (4 of 4, 1 skipped value); exit above. MC 4 windows (Settings + 3 terminals stacked at one spot): enter rms .017 (3 of 3, start +117-250 ms), **exit .34 .56 .72 .82 .89, 150-169 ms, rms .100-.116** (3 of 3, 1 skipped value; the developers' own layout gave .062-.075). Scale 1.6, 1 window: enter rms .026 (3 of 3); exit .33 .59 .71 .79 … .96 .97 then a .03-.04 step to 1 at +350 ms, rms .074-.076 (3 of 3). Banner arrive left-edge offsets 270 228 189 156 127 102 80 63 49 38 29 22 16 12 8 pt vs Mac 276 220.5 178.5 – 138 111.5 83.5 64.5 48.5 37 28 21 – 12 9 (rms about 6 pt, the Mac's own fit 5.3); dismiss 0 21 63 112 163 220 260 then gone vs Mac 0 10 51 104 148 192 230.5 260.5 297.5 (ours about half a frame ahead). NC open 358 318 270 223 181 144 113 88 68 52 40 30 23 … vs Mac 339 293.5 245 199 159.5 125 97.5 75.5 57.5 44 33.5 (half a frame behind), close 0 19 59 106 153 196 233 264 289 309 325 337 347 354 vs 0 7 38 83 131.5 178 216.5 250 278.5 300.5 317.5 332 342.5 350.5 357 (half a frame ahead), 2 of 2 each, identical repeats. Spotlight open bar width (incl. shadow) 1.041 1.061 1.056 1.046 1.035 1.022 1.013 1.006 1.000 .996 vs Mac 1.087 1.068 1.050 1.033 1.018 1.009 1.001 .997 .994: same shape, about a frame slower, smaller first frame (3 of 3). Submenu (Dock menu Options ▸): first visible 11 / 11 / 13 / 12 frames after the row highlight, drawn in **two frames** (.27 then 1) in 4 of 4 (Mac 13 frames, complete in one). Lock-in (test double, 4 of 4): .03 held for 2-3 frames, then .07 .13 **.30** .42 .50 …, 267-285 ms (no Mac track). Wrong-password shake: my cross-correlation tracker failed (method), **not measured**; carried [a2e61a0] although FrameClock.qml changed |
| transition | 86 | 88 | **89** | +1 | [3ea26fe] Appearance shortcut 6 of 6 in one curve (above). MC exit: Spaces bar / menu bar strip on the exit curve (.18 .39 .63 .78 .83), Dock returns from +185 ms. The Dock disappears in **one frame** at MC enter (+105 ms; R2 says only "goes away", no per-region Mac track). Unlock carried [a2e61a0] (session 18 within a frame) |
| visual | 89 | 91 | **91** | 0 | Fixed [3ea26fe]: Wallpaper pane: Dynamic, Landscape and Pictures tiles and the current preview filled at 1.5 s on a cold cache; tag dots pale (`03`). Partly: toolbar press keeps the share glyph now, but as a faint outline in a near-white disc (crop mean 172 vs the recording's 157; the recording's glyph is clearly darker than its glow) (`02`); NC expanded group: the x turns into "Clear" but "Show less" stays a text capsule (Mac: shrinks to a 28 pt circle). New / remaining: Cmd-Tab lists no Finder (Mac `cmdtab-light.png` always shows it; the Dock now gives Finder a permanent dot); the Downloads stack is a flat white sheet with no type label and only white slivers of the second item (Mac: the document icon with its label and the item behind visible) (`06`) |
| behaviour | 87 | 88 | **88** | 0 | Works with real input [3ea26fe]: press title-drag-release runs the row (Window ▸ Zoom); typed letter selects ("s" → Show All) and Return runs it; Right / Left walk View → Window → Help → Window with no row selected; hover switches titles; click on the open title closes, Esc closes; Cmd-Q quits every window of the app (3 terminals), Cmd-H hides to special:hidden, Option-Cmd-H hides the others, Show All restores; Cmd-Tab tap brings the hidden app back; Cmd-Tab + H toggles hide of the selection, + Q quits it and the switcher stays; Cmd-` / Shift-Cmd-` cycle the app's windows only; Cmd-M minimises (genie target the app tile, the owner's Mac setting); title-bar double-click zooms and restores, two clicks 600 ms apart do not; banner hovered past its timeout stays, leaves about 1.0 s after the pointer; collapsed stack x clears at once, expanded group x asks first; Spotlight: Cmd-A selects all, Ctrl-A goes to the line start (no longer global). **Regression (f8bb588):** with `follow_mouse = 1` the wallpaper layer's on-demand keyboard focus is taken on *hover*: pointer over the empty desktop → menu bar "Finder", the window's lights grey (`01`); pointer back on the window → the app again. Consequences measured: a click on "View" reached straight from the desktop opened **Window** (index of the Finder layout), 3 of 3 plus 3 of 3 with 20-100 ms waits; from over a window it opened View; Cmd-H did nothing with the pointer on the desktop (`activeToplevel` null). Also: clicking the Downloads stack runs `xdg-open` (a clean HOME opened GNOME Files; no fan / grid popup, its "View content as" rows all disabled, none checked); screenshots go to Pictures (Mac: Desktop); new windows of one app open at the same spot (Mac cascades) |
| shape | 89 | 90 | **90** | 0 | Carried [a2e61a0]. Spot check [3ea26fe]: pressed knob lens 25 x 20 pt (Mac 25 x 20, MAC-ANSWERS B2); Finder icon grid, sidebar and toolbar against `icons-dark.png` no visible difference (`03`) |
| colour | 95 | 95 | **95** | 0 | [3ea26fe] orange tag dot on screen 254,168,90 = Mac dark 242,172,104 P3 → 254,168,90 sRGB (light: 255,164,83 in code = Mac converted). The pressed-zoom item is withdrawn (above). Note: the Theme.qml comment lists the P3 values as "converted to sRGB" (the code uses the right ones) |
| shadow | 94 | 94 | **94** | 0 | Carried [a2e61a0] (WindowShadow.cpp changed 3 lines: inactive while the desktop has the keyboard; not re-measured). Banner shadow not measured |
| refraction | 90 | 91 | **91** | 0 | [3ea26fe] CC Sound knob held over 4 pt stripes (dark): centre row through the lens 219 on the white fill (×0.86) and 105-112 on the track (×0.85) vs the Mac model's centre ≈ ×0.88; vertical profile top 140 → middle 108-114 → **dark band 94 below the middle → 104-107 at the bottom** (×1.16 / .99 / .95 of the 109 backdrop) vs the Mac's 149 / 124 / 171 on 132 (×1.13 / .94 / **1.30**): the bright lower highlight of the Mac lens is missing. At the track's rounded ends the lens shows the fill end refracted, no clipping (`04`). Over the CC tile the stripes are already blurred, so stripe refraction inside the lens is not testable there |
| icon | 88 | 89 | **90** | +1 | [3ea26fe] tag dots exact; Sound module: built-in output shows the computer (desktopcomputer on a battery-less host, `05`), other sinks the speaker; 12 SF Symbols decoded from CoreGlyphs added. Off: Downloads stack sheet (visual) |
| font | 95 | 95 | **95** | 0 | Carried [573470c]; spot check [3ea26fe]: menus, NC heading "Notification Center", Finder labels side by side, no visible difference |
| rendering | 88 | 89 | **89** | 0 | [3ea26fe] dist setup (E) against smoke (F): identical but for the clock-width shift of the status items (max difference only at 2040-2077 px, the clock region); no capture gaps in any run. Off: submenu two-frame appearance; MC 1.6 exit end step; screencopy leak unchanged (stack) |
| sound | 84 | 84 | **87** | +3 | [3ea26fe] every rule checked from the stand-in logs, real key events: tap = 1/16 step (0.5 → .5625), no pop with feedback off; Shift tap pops on key-up (+55 ms), with feedback on Shift silences; Option+Shift = 1/64 (.625 → .640625) and no pop; off-grid level snaps (.640625 → .6875); held key: repeat from +600 ms, **no pop while repeating**, one pop on key-up (+20-50 ms after the key goes up, 6 taps; one 750 ms outlier under load); at full volume pops at +979 and +1980 while held, none on key-up; mute silent, unmute pops +128 ms (80 ms by design); Option + volume opens Settings > Sound. CC Sound slider: no pop while dragging, one pop 50 ms after release with feedback on; feedback off + Shift on release pops. Cmd-Shift-3: shutter logged +61 ms after the key. Not verifiable without the Mac: key-up → sound latency, alert-volume loudness |

## Per surface

| surface | weight | j6 | j7 | main reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92 | 91 | Press-drag, type-select, Left / Right all right; desktop hover flips the bar and mis-targets clicks |
| Dock | 14 | 90 | 90 | Finder dot, stack menu; stack tile flat, no popup |
| Window chrome | 14 | 89 | 89 | Double-click zoom, Cmd-M; pressed zoom withdrawn as a fault; title inactive on desktop hover |
| Finder | 13 | 89 | 90 | Tag dots exact, icon view like `icons-dark` |
| System Settings | 10 | 91 | 92 | Wallpaper tiles at once; toolbar press partly |
| Control Center | 6 | 93 | 93 | Sound module glyph; knob lens lower highlight missing |
| NC + banners | 6 | 89 | 90 | Banner and NC motion within half a frame of the Mac; group clear |
| Spotlight | 6 | 86 | 87 | Open curve like the Mac's, AppKit key bindings |
| Mission Control | 4 | 86 | 88 | Hold gone, 1-window exit on R2; 4-window exit front-loaded |
| Sounds | 4 | 84 | 87 | Volume state machine verified |
| HUD | 3 | 90 | 90 | Carried |
| Cmd-Tab | 3 | 89 | 88 | Q / H work; Finder missing |
| Apps | 2 | 86 | 86 | Not re-measured |
| Lock screen | 5 | 92 | 91 | Lock-in first value held 2-3 frames and a .17 jump |

## Side-by-side pass, largest visible difference first

1. **Desktop hover makes Finder frontmost**: menu bar and title bar flip as the pointer crosses the desktop; menu
   clicks from the desktop open the wrong menu (`01`).
2. **Mission Control with several windows**: exit runs ahead (.34 first frame vs R2 .21).
3. **Cmd-Tab without Finder** (Mac: always first-class in the list).
4. **Toolbar press**: glyph barely visible in a white disc (recording: darker glyph inside a bluish glow) (`02`).
5. **Downloads stack**: flat white sheet; click opens a folder window instead of the fan / grid.
6. **Knob lens**: no bright lower rim highlight (`04`).
7. **Submenu**: appears over two frames, 11-13 frames after the row.
8. **NC expanded group confirm**: "Show less" keeps its width.
9. **Lock-in**: brief hold at the start, one jump.
10. **Finder icon view, CC, NC, banners, menus, Spotlight bar**: no visible difference at a glance.

## Ranked gaps (gain in overall points; fix source)

| # | gap | surface / dim | fixable with | est. gain |
|---|---|---|---|---|
| 1 | Desktop focus on hover (f8bb588 + follow_mouse) | menu bar, windows / behaviour | repo data: take the wallpaper's keyboard only on a click (or drop follow_mouse focus for the background layer) | +0.3 |
| 2 | MC multi-window exit front-loaded; 1.6 exit end step | MC / animation | needs the Mac (4-window recording); the end step is repo-side | +0.15 |
| 3 | Cmd-Tab without Finder | Cmd-Tab / behaviour, visual | repo data (`cmdtab-*.png`, Q-dock-19..22) | +0.05 |
| 4 | Toolbar press glyph contrast / disc brightness | Settings / visual | repo data (recording 196-285) | +0.05 |
| 5 | Downloads stack tile (document icon with type label, second item) | Dock / icon | repo data (`dock-*.png`) | +0.05 |
| 6 | Knob lens lower highlight | CC, Settings / refraction | repo data (B2 `slider_fit.txt`: ring offset sign, key / fill highlight) | +0.05 |
| 7 | Submenu one-frame appearance | menus / rendering | repo data (Q-menubar-23) | +0.03 |
| 8 | Lock-in first frames | lock / animation | needs the Mac (no lock-in track) | +0.03 |
| 9 | NC confirm: Show less → circle | NC / visual | repo data (Q-panels-32) | +0.02 |
| 10 | Stack popup (fan / grid), "View content as" | Dock / behaviour | needs the Mac (popup geometry, motion) | +0.1 |
| 11 | Screenshots to Desktop, Mac file name | behaviour | repo data (macOS default) | +0.02 |
| 12 | Window cascade for new windows of one app | windows / behaviour | repo data (AppKit cascade 20 pt-ish; measure on the Mac to be exact) | +0.02 |
| 13 | Quick Look bar colour / open curve, HUD timeout | Finder, HUD | needs the Mac (unchanged from judge #6) | +0.1 |
| 14 | foot title bar dark in light mode (lights use the dark set) | windows / colour | repo (check the plugin's per-window appearance) | +0.03 |
| 15 | Screencopy session leak | stack / rendering | stack (hypr-dev patch) | measurement only |

## Verdict on judge #6's next 15

| # | item | verdict |
|---|---|---|
| 1 | MC: flight on first frame, bars on the exit curve, multi-window exit | **partly**: hold gone, bars on the curve, 1-window exit on R2; 4-window exit not (rms .100-.116 in my layout), 1.6 exit end step |
| 2 | Toolbar press keeps the glyph | **partly**: glyph kept but faint; disc too white |
| 3 | Tag dots pale | **fixed** (254,168,90 = Mac) |
| 4 | Downloads stack per icon style | **partly**: shows the newest items in every style, but as a flat sheet |
| 5 | Preview capsule 4-8 levels darker | **not measured** (the press look was judged instead) |
| 6 | Pressed zoom brightening | **wrongly reported** by judge #6 (the dark Mac crop is the hover state; the light crop shows the Mac brightens) |
| 7 | Desktop click activates Finder | **fixed, with a regression**: hover does it too |
| 8 | Wallpaper pane tiles at open | **fixed** (1.5 s, cold cache) |
| 9 | Appearance hold cap | **fixed / not reproduced** (6 of 6) |
| 10 | Unlock one frame later | **not** changed (developers: within a frame; carried) |
| 11 | Sound module device glyphs | **fixed** (computer for built-in outputs) |
| 12 | Dock label tail 16 x 6.5 pt | **not measured** (no change in the label code seen) |
| 13 | Quick Look bar colour | **not** (needs the Mac) |
| 14 | HUD timeout | **not** (needs the Mac) |
| 15 | Screencopy leak patch | **not** (stack) |

## The next 15 changes

1. Background layer takes the keyboard on a click only; hover over the desktop never changes the frontmost app (+0.3).
2. Mission Control exit with several windows from the Mac's 4-window recording; remove the 1.6 end step (+0.15).
3. Finder in the Cmd-Tab list whenever the Dock shows its dot (+0.05).
4. Toolbar press: darker glyph inside a smaller, bluish glow like frames 196-215 (+0.05).
5. Downloads stack tile: the item's document icon with its type label and the second item visibly behind (+0.05).
6. Knob lens: the lower highlight (B2 fit: ring offset down, key / fill highlight) (+0.05).
7. Submenu drawn complete in one frame at 13 frames (+0.03).
8. NC confirm: "Show less" shrinks to a 28 pt circle while the x reads "Clear" (+0.02).
9. Lock-in without the held first frames (+0.03, Mac track preferred).
10. Screenshots to ~/Desktop with the Mac's name pattern (+0.02).
11. Cascade new windows of the same app (+0.02).
12. foot / plugin-titled windows follow the light appearance (+0.03).
13. Stack popup (fan / grid) after a Mac capture (+0.1).
14. Quick Look bar and HUD timeout after Mac captures (+0.1).
15. Install the screencopy-leak patch on test machines (measurement quality).

Together about +1.0, so about 91 if all land.

## Needs the Mac (one sitting, most valuable first)

1. Mission Control enter / exit with 4 overlapping 700 x 500 windows, 60 fps, over grey 127 (and 1 window at a
   1.6-equivalent scaled resolution).
2. Downloads stack click: the fan and the grid popup, still and open / close at 60 fps; the stack tile at 2x in
   Default / Dark / Clear / Tinted.
3. Lock-in (Ctrl-Cmd-Q) at 60 fps over grey 127, per region.
4. Quick Look of a PDF: still and open series.
5. HUD: last key-up to the start of the automatic dismiss.
6. Volume key-up → pop latency and the screenshot shutter latency (audio + screen recording together).
7. Slider knob lens held over 4 pt stripes and at both track ends, 2x still (to confirm the lower highlight).
8. Cmd-Tab with no Finder window open (to confirm Finder stays listed) and the window cascade offset of a second
   TextEdit window.
9. Dock label of one icon at tile 33 and 48, 2x crop over grey 127.

## Reachable ceiling

- **With data already in the repo: about 91.** Items 1, 3-12 above are fixes against data the repo holds (+0.6-0.7).
- **With new Mac captures: about 91.5-92.** Captures 1-9 add about +0.4-0.6 (MC multi-window, stack popup, lock-in,
  Quick Look, HUD timeout).
- **Never on this stack: the last 3 points to 95**, roughly: no glass and AppKit-style controls inside third-party
  windows (about 1.0); third-party app menus and behaviours we cannot reach (Services, app-specific menus, about 0.5);
  a stretched-buffer zoom and Hyprland's presentation / screencopy behaviour in long sessions (about 0.5); focus
  model and input differences that Hyprland imposes (no click-through focus semantics per app, trackpad physics only in
  hyprk's views, about 0.5); motions with no Mac data (about 0.5).

## Crops (`reference/judge-95-7/`, 0.5 MB, no lock screen, no host names, no recording frames)

`01-desktop-hover-menubar-flips-to-finder-ours.png`, `02-toolbar-press-share-dark-ours.png`,
`03-finder-tags-dark-mac-top-ours-bottom.png`, `04-cc-sound-knob-lens-stripes-mid-left-right-release-ours.png`,
`05-sound-module-device-glyph-ours.png`, `06-downloads-stack-dark-style-mac-left-ours-right.png`,
`07-zoom-light-hover-pressed-ours.png`.
