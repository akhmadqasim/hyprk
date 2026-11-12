# hyprk independent judge #10, commit 0bc76d1 (2026-11-12, 10:27-10:45 WITA, measured live)

Delta judgement against judge #9 (`JUDGE-95-9.md`, f8c2706, 90.49). Method and weights from `JUDGE-95-7.md`: 12
dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[10 live]** measured
on screen here; **[9]** carried from judge #9.

## What was judged

- HEAD 0bc76d1 (live tree, no developer writing). Changes since f8c2706: 2497cec (Cmd-Tab MRU), d5329d0 (Stage Manager
  pile click: uninvolved pile kept, flight from the pile's frame, incoming on top), 97f9631 + 5ee8ddd (Spotlight open
  first value and reopen first frame), 0aab450 (submenu glass in the labels' frame), 0bc76d1 (held slider knob, dark,
  refit). 7100748, 89204e0, 585e845: tooling, no score.
- One session: `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (2560x1664 MBA, no host window), scratch HYPRK_STATE /
  XDG_CACHE_HOME / TMPDIR, the script's private bus, PipeWire pointed at an empty dir, `wpctl` / `pw-play` / `paplay` /
  `notify-send` / `brightnessctl` stubs, HYPRK_MUTE=1. Apps: System Settings, foot `-a footA`, foot `-a footB`. Tools:
  repo `vptr` (with `r`), a scratch copy of `lockscreen/tools/vkbd.c` with `M` / `m` (Super down / up) and `Up`, `mcap`
  (19 runs). Appearance via `qs ipc call theme setDark`, scale via `hyprctl eval 'hl.monitor({... scale = "1.6"})'` in the
  same session (no restart). Light at scale 2 first (fresh state starts light), then dark at 2, then dark at 1.6.
  Stopped with `smoke.sh --stop`, bus killed, no pid left.
- Untouched and carried from judge #9: colour, shadow, icon, font, sound, Finder, HUD, Apps, lock screen, window chrome.
- Crops in `reference/judge-95-10/` (01-06).

## Overall: **90.6** (13 surfaces 90.59, with the lock screen 90.60, with Stage Manager folded in at weight 2: 90.48)

Judge #9: 90.49. Gains: Cmd-Tab is most-recently-used (5 of 5 orders right, light, dark and 1.6), the submenu's glass
comes with its labels (5 of 5 opens), Stage Manager keeps the uninvolved pile and draws the incoming window on top.
Against: the Spotlight reopen fix does not show in this pass's measure (first frame 1.069, repeated, 9 of 9 reopens),
and a Mission Control exit defect not seen before: the picked window flies **under** the other windows and the Dock
for the whole exit and pops to the front in the last frame (2 of 2, light and dark). Light and 1.6 sweeps are clean:
nothing unreadable, no stale glass frame found, no QML error or binding loop.

## Light (scale 2) and scale 1.6 (dark) sweep

| item | light, scale 2 | 1.6, dark |
|---|---|---|
| Menu bar menu (System Settings > View) | ok: light glass, disabled items grey, shortcut glyphs readable, title pill | ok, same layout at 0.8 sample/pt, nothing clipped |
| Dock menu + submenu (Notes, right click `r`, hover Options), `03`, `05` | ok: menu and submenu in light glass, labels black / grey; mcap -k 2: submenu appears in **one step** at 214 ms (region mean 180.9 -> 192.4, nothing after) | ok, one step at 197 ms |
| Control Center | ok: clear glass tiles, white labels over the wallpaper, as the Mac's CC (labels white in light too) | ok, grid intact, sliders full width |
| Notification Centre | ok. Widgets dark in light: intended (`Theme.qml`: "Dark" widget style in light and dark, PC #62). Settings > Icon & widget style shows "Default" selected while the widgets follow "Dark": a label mismatch only | ok |
| Spotlight open / reopen | bar is dark glass in light: matches `panels/spotlight-empty-light.png` (the Mac's bar is dark in light too). Reopen series: see claims | ok: bar, placeholder and mic placed right |
| Glass button press, Appearance preview share button (pointer 745,268 pt) | hover -> held -> released at 4 / 8 / 16 pt left: 233 249 255 / 232 249 255 / 223 245 255 -> **255 255 255** / 254 255 255 / 245 255 255 -> same as hover (diff 0). Glyph stays black on the lit disc. Clips to white at the pointer, as judge #9 saw in dark; no Mac light number | not run |
| Held slider knob, `06` | ok: clear lens, dark rim, track and fill seen through, soft shadow below (shape as `verify/B/knob-lens-switch-slider-held.png`) | ok in dark at 1.6, rim and lens drawn, no seam |
| Toolbar button press (Settings back, after General) | ok: capsule 240 -> 255 while held, chevron stays dark | not run |
| Stage Manager, 3 apps, pile click (footA in) | full output -k 8, 74 frames, `long_intervals` 0: uninvolved footB pile **drawn in every frame** (dark samples 646-650, dips to 437-538 at 134-201 ms only where the outgoing Settings passes over it); incoming footA drawn over outgoing Settings while they cross; no empty stage frame | not run |
| Mission Control enter / pick / exit, `01` | enter ok. Pick Settings with footA active: **Settings drawn under footA for the whole exit (5-307 ms), pops on top at 321 ms** (frame diff 29 at that frame, the largest of the exit); the foot window is drawn over the Dock during the exit and the Dock comes back in the same last frame | enter ok, layout fits 1600x1040 |
| Cmd-Tab, `04` | Settings, **footA (selected)**, footB, Finder after footA then Settings: MRU. Glass and label readable in light | Settings, footb (selected), footA, Finder after footB then MC pick of Settings: MRU |
| Shell log | no QML error, no binding loop. Environment only: 6x `qt.svg` invalid path, 2x portal ServiceUnknown, 4x `QLocalSocket PeerClosedError`, 14x `QWaylandTextInputv3` enable/disable surface (Spotlight field focus). The judge #9 MC `ScreencopyView` warning did not appear | same log, nothing new after the scale change |

Not reached: press light and toolbar press at 1.6, Stage Manager at 1.6, a Spotlight curve in light (the bar's edge on the
light sidebar is too soft for the rim measure), lock screen (rule).

## The developer claims (dark, scale 2)

| claim | measured | verdict |
|---|---|---|
| 2497cec Cmd-Tab MRU | after footA, Settings: Settings, footA, footB, Finder; after Settings, footB (Dock): footB, Settings, footA, Finder; plus the light and 1.6 orders above. 5 of 5 | **confirmed** |
| d5329d0 pile click | measured in light (above): uninvolved pile drawn every frame, incoming on top. Flight start width not measured frame by frame | **confirmed** (light) |
| 97f9631 + 5ee8ddd Spotlight reopen 1.088 1.069 1.046 | `mcap -k 2`, row y 232, x 300-420, edge = the rim's rising step. Over the dark Settings window (3 reopens after `panels close`) and over the wallpaper (3 after `toggle`, 3 after `close`): **1.069 1.069 1.046 1.031 1.015 1.008 1.000**, 9 of 9, first frame 78-80 ms after the `qs ipc` call. The content's alpha changes between the two 1.069 frames, the rim does not | **not reproduced** with this measure. It matches the developer's "before" series. The glass blur edge itself is invisible over these smooth backdrops, so the developer's edge may be a different feature; needs their exact backdrop |
| 0aab450 submenu glass with labels | dark 3 of 3, light 1 of 1, 1.6 1 of 1: one step, no frame with labels and no glass | **confirmed** |
| 0bc76d1 knob dark refit | held knob drawn, rim and lens fine at 2 and 1.6; not compared numerically with frame 2685 | seen, numbers not rechecked |

## Per dimension

| dimension | j9 | j10 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | Spotlight reopen first frame still repeats 1.069 in this measure; open starts 78-80 ms after the call (was 64-66) |
| transition | 89 | 89 | 0 | [10 live] SM flight cleaner (+), MC exit: picked window under the others and the Dock, pops in the last frame (-) |
| visual | 92 | 92 | 0 | [10 live] light: menus, CC, Dock menu, toolbar and glass button presses readable; knob refit not rechecked |
| behaviour | 89 | **90** | +1 | [10 live] Cmd-Tab MRU in 5 of 5 orders (judge #9's main deduction) |
| shape | 90 | 90 | 0 | carried; 1.6 layout intact |
| colour | 95 | 95 | 0 | carried; light glass colours as the references |
| shadow | 94 | 94 | 0 | carried |
| refraction | 91 | 91 | 0 | knob lens refit (dark) not rechecked numerically |
| icon | 90 | 90 | 0 | carried |
| font | 95 | 95 | 0 | carried |
| rendering | 89 | 89 | 0 | [10 live] submenu same frame (+), SM pile kept (+); MC exit z-order pop and the Dock hidden for ~300 ms (-) |
| sound | 87 | 87 | 0 | carried |

## Per surface

| surface | weight | j9 | j10 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92 | **92.5** | submenu glass with labels; light and 1.6 clean |
| Dock | 14 | 91 | 91 | Dock menu by right click works in light, dark, 1.6 |
| Window chrome | 14 | 90 | 90 | carried |
| Finder | 13 | 90 | 90 | carried |
| System Settings | 10 | 92.5 | 92.5 | light presses fine; knob refit not rechecked |
| Control Center | 6 | 93 | 93 | light and 1.6 clean |
| NC + banners | 6 | 90.5 | 90.5 | light and 1.6 clean |
| Spotlight | 6 | 88 | 88 | reopen fix not seen in this measure; later start (+15 ms) |
| Mission Control | 4 | 88.5 | **87.5** | exit: picked window under the others until the last frame, windows over the Dock |
| Sounds | 4 | 87 | 87 | carried |
| HUD | 3 | 90 | 90 | carried |
| Cmd-Tab | 3 | 89 | **91** | MRU, commit raises |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91 | 91 | carried, not tested |
| *Stage Manager (extra)* | *2* | *80* | ***85*** | uninvolved pile kept in every frame, incoming on top |

Weighted: 13 surfaces 9058.5 / 100 = 90.59. With the lock screen 9513.5 / 105 = 90.60. With Stage Manager 9228.5 / 102
= 90.48.

## Regressions

None found from today's commits. The MC exit defect is in code none of them touched (judge #9 measured only the end
state of a pick); the log is cleaner than judge #9's. One unexplained event: footB's shell showed bash's "Display all
3583 possibilities?" once after a Super+Tab while footB was active; a direct retest (cleared line, Super+Tab) did not
leak Tab. Not reproduced, no score.

## The next 10 changes, by gain

1. Mission Control exit: draw the picked window on top (and every window under the Dock) from the exit's first frame,
   not only after it ends (+0.1).
2. Mission Control exit with several windows, from a Mac 4-window recording (+0.1, needs the Mac).
3. Spotlight reopen: make the first frame differ from the second (measured here 1.069 1.069 1.046 on the rim); agree a
   shared measure (region, backdrop, feature) with the developer first (+0.05).
4. Stack popup (fan / grid) after a Mac capture (+0.05, needs the Mac).
5. Spotlight open latency: 78-117 ms from the trigger against 64-66 before; measure the Mac's key-to-first-frame (+0.03).
6. Press light: keep the tint at the pointer instead of clipping to 255 255 255 (seen again in light: 255 at 4 pt) (+0.03).
7. Stage Manager: incoming window's first flight frame at pile size (check frame by frame after d5329d0) (+0.02).
8. Settings > Icon & widget style: show "Dark" selected, since the widgets follow it (+0.01).
9. Dock: clicking Finder with no Finder window opens one (carried) (+0.02).
10. Knob lens at 1.6 and its bottom terms (the developer's "not checked") (+0.01).

## Needs the Mac

Judge #9's list stands. Plus: which window is on top during a Mission Control exit and whether the Dock stays drawn
over the flying windows; held glass button and toolbar press in light at the pointer; Spotlight key-to-first-frame
latency.

## Reachable ceiling

About 91 with the repo's data (item 1 and 3 are the largest repo-only gains left), 91.5-92 with new Mac captures.
