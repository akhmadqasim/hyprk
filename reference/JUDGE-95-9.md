# hyprk independent judge #9, commit f8c2706 (2026-11-12, 09:23-09:40 WITA, measured live)

Delta judgement against judge #8 (`JUDGE-95-8.md`, 1c180c3, total 90, measured live as judge #8b). Method and weights
from `JUDGE-95-7.md`: 12 dimensions, 13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row
tags: **[9 live]** measured on screen here; **[8b]** carried from judge #8b's live session of 1c180c3.

## What was judged

- HEAD f8c2706 (live tree, no developer writing). Changes since 1c180c3: d1175a3 (Finder stays frontmost after a
  desktop click: `follow_mouse = 2`, no warps, click-to-focus bind), e9fd3dc + f8c2706 (Mission Control pick takes
  focus, Cmd-Tab / Mission Control / Dock raise the window), 69be61f + e15d33b + c8ccb49 (Stage Manager pile click),
  585e845 (smoke.sh private bus, tooling, no score), 420d056 (doc: the Mac's pressed glyph).
- One session: `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (virtual 2560x1664@2x output MBA, no host window),
  scratch HYPRK_STATE / XDG_CACHE_HOME / TMPDIR, the script's private dbus-daemon, PipeWire pointed at an empty dir,
  `wpctl` / `pw-play` / `paplay` / `notify-send` stubs, `HYPRK_MUTE=1`. Apps: System Settings, foot `-a footA`, foot
  `-a footB`. Tools: `vptr` (repo), a scratch `vkbd` (zwp_virtual_keyboard_v1), `mcap` full output `-k 8` (8 runs, 2
  usable pile clicks, `long_intervals` 0). Light first, then dark from Settings > Appearance.
- Note for later judges: `mcap -- sh -c "..."` runs only `sh` (the trigger is ONE string run through `/bin/sh -c`):
  the first 4 captures here triggered nothing. Pass the trigger as one argument.
- Untouched since 1c180c3 and carried from judge #8b: colour, shadow, refraction, icon, font, sound, animation (no
  animation code changed outside Stage Manager), lock screen, Finder, Control Center content, NC, Spotlight, HUD, Apps.
- Crops in `reference/judge-95-9/` (01-04).

## Overall: **90** (13 surfaces 90.5, with the lock screen 90.5, with Stage Manager folded in at weight 2: 90.3)

Judge #8: 90 (90.1). The focus work holds up on screen: every focus case asked for passes, judge #8's menu-bar
regression is gone, and windows activated by Dock, Cmd-Tab and Mission Control come to the front without the pointer
moving. Stage Manager's pile click is now one continuous flight with no doubled window. Judge #8's "pressed glyph
vanishes" finding is withdrawn after measuring against the Mac's numbers (420d056). Not enough for 91: Cmd-Tab is not
most-recently-used, the uninvolved Stage Manager pile still blinks out for 2-3 frames, and the carried items
(Spotlight open curve, submenu two frames, MC exit with many windows) are untouched.

## Measured live (judge #9)

| item | measured | verdict |
|---|---|---|
| Desktop click, then hover (`04`) | footA clicked (bar "footA"), desktop click: bar "Finder"; pointer moved over Settings (5 steps, 1.2 s) and then over foot (1 s), no click: bar stays "Finder" both times. Settings active, pointer over foot 1.2 s: bar stays "System Settings" | **fixed** (judge #8b: flipped in 1 s) |
| Desktop click, then "File" (`04`) | desktop click, pointer to "File", click: **Finder's File menu** (New Finder Window, New Folder ...), bar "Finder"; Escape closes, bar "Finder"; keys typed afterwards (`zz`) land nowhere (foot unchanged) | **fixed** (judge #8b: System Settings' menu, 2 of 2) |
| Desktop click, Spotlight round trip | desktop click, Spotlight icon, Escape: bar "Finder" | Finder kept |
| First click in an inactive window's text field | after a desktop click, click in Settings' sidebar search field, type `wi`: bar "System Settings", field reads "wi" with the caret | works (one click) |
| Click a window | Settings active, click on foot: foot active and drawn in front (overlap pixel 735,400 = 36 36 36, foot) | works |
| Dock click | foot active, click the Settings Dock icon: Settings active and drawn in front (overlap pixel 247 247 247), pointer still at 575,785 | **raises**, no warp |
| Cmd-Tab (Super held, Tab, release) | switcher: **Settings, Finder, footA**; commit: bar "Finder", pointer not moved; again: back to Settings (overlap 247, Settings in front) | raise works. **Order is not MRU**: last activations were Finder, Settings, foot, Settings, so the Mac lists Settings, footA, Finder. `lib/dock.js switcherApps` keeps Dock order with only the frontmost moved first |
| Mission Control pick | Super+Up, click foot: foot active and in front (overlap 36); again, click Settings: Settings active and in front (247). 2 of 2 | **works** |
| Dock Finder click (no Finder window) | bar "Finder", no Finder window opened after 3 s | Mac opens a new Finder window; whether the Finder app runs in this session not checked |
| Stage Manager pile click, foot in (`03`) | full output `-k 8`, 98 frames. 0-34 ms unchanged, 51 + 67 ms: the **uninvolved Settings pile is gone** (strip white samples 621 -> 1 -> 1 -> 637), flight from 85 ms: outgoing footB flies to the strip while footA flies out of its pile, both continuous; no empty stage frame, no doubled window; new pile filled from the flight's end on (strip dark samples 800-990 every frame to 1.6 s) | flight **fixed**; the uninvolved pile blinks 2 frames |
| Stage Manager pile click, Settings in (`02`) | 97 frames. Uninvolved footB pile gone at 23, 40, 56 ms (3 frames). Settings flies out of its pile: top edge 248 208 180 156 140 124 116 108 104 100 96 92 pt, right edge 712 804 872 924 964 996 1016 1032 1040 1048 1056 1060 pt (monotonic). The first flight frame (74 ms) is already about 420 pt wide against the hovered pile's ~260 pt. Outgoing foot is drawn **over** the incoming Settings while they cross (74-140 ms) | continuous; developers' "Settings as incoming not checked" now checked |
| Stage Manager off | 2 of 2: the focused Settings drawn on top (focusHistoryID 0, its lights coloured, foot behind) | **fixed** (judge #8b: under an inactive window) |
| Stage Manager, window moved off the strip | Settings over the strip hides it (as on the Mac); after `hyprctl` moved Settings to x 330 the strip did not come back, not even with the pointer at the left edge, until Stage Manager was turned off and on | edge case, moved by `hyprctl` not by a drag; noted, small weight |
| Press light, dark, Appearance preview share button (`01`) | pointer 812,268 pt (right of the glyph). Hover -> held 0.6 s -> released, 4 / 8 / 16 pt left: 190 198 207 -> **255 255 255** -> 190 198 207 (+65 +57 +48, clipped); 26 pt: +53 +62 +52; 16 pt below-left 168 185 195 -> 224 252 255; 30 pt (dots) +29 +37 +44. Released = hover exactly (diff 0) | at the pointer ours clips to white on this brighter spot (hover 190 vs judge #8b's 156); the Mac's peak stays 215 243 255. Same backdrop as judge #8b not reproduced, so not a regression call |
| Pressed glyph vs its disc (20 pt box) | hover: glyph 255 255 255 on disc 177 191 203 (box mean 204); held: glyph 255 255 255 on **disc 234 253 255** (box mean 251); Mac (420d056): glyph 255 255 255 on 229 250 255 | glyph over disc **+21 +2 0, Mac +26 +5 0**: the disc keeps the backdrop's tint (not flat 250). Judge #8's "glyph vanishes" deduction **withdrawn** |
| Lift | the held press changes 778-853.5 x 256.5-296 pt, the merged capsule plus about 2 pt per side | about 4-5 % growth; the Mac's lift not measured |
| Regression sweep | Finder File menu, Control Center (open, Stage Manager tile on / off 4 times), Notification Centre (clock), Spotlight (icon): each opens and closes, nothing left on screen. Dock menu: not reached (no right-button tool; a 1.2 s hold opens no menu, only the label) | clean |
| Shell log | no QML error, no binding loop. Environment only (no portal, no `brightnessctl`, PipeWire unreachable by design, 4x `qt.svg` invalid path data), plus **1x `ScreencopyView at MissionControl.qml:329: Cannot capture frame, no recording context`** at the first Mission Control open and 2x `QLocalSocket PeerClosedError` | MC warning new to the judge logs (judge #8b did not open MC); no visible effect |

Not testable: scrolling a background window (vptr has no axis events), so `follow_mouse = 2`'s scroll focus is
unverified. Not reached: press and menu shadow in light, Dock menu by right click, lock screen (not tested, rule).

## Per dimension

| dimension | j8 | j9 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | Carried [8b]: Spotlight open still starts near 1.0 (code untouched). Stage Manager flights scored separately |
| transition | 89 | 89 | 0 | Carried [8b]. Stage Manager flight now continuous (counted in the SM score) |
| visual | 91 | **92** | +1 | [9 live] the pressed glyph keeps a tinted disc (234 253 255 vs Mac 229 250 255, glyph contrast +21 vs +26): judge #8's deduction withdrawn. Against: the press light clips to white at the pointer over a bright spot |
| behaviour | 88 | **89** | +1 | [9 live] hover keeps the frontmost app, desktop click + "File" gives Finder's menu, first click in a text field types, Dock / Cmd-Tab / MC activate and raise, pointer never moves. Against: Cmd-Tab not most-recently-used, Dock Finder click opens no window (unverified cause), submenu two frames carried |
| shape | 90 | 90 | 0 | [9 live] the lift reaches the merged capsule, +2 pt per side; no Mac number. Carried |
| colour | 95 | 95 | 0 | Carried |
| shadow | 94 | 94 | 0 | Carried [8b] (menu shadow = decode) |
| refraction | 91 | 91 | 0 | Carried |
| icon | 90 | 90 | 0 | Carried |
| font | 95 | 95 | 0 | Carried |
| rendering | 89 | 89 | 0 | [9 live] no doubled window, no empty stage frame; the uninvolved pile drops for 2-3 frames (SM only); submenu two frames carried. No `mcap` gap |
| sound | 87 | 87 | 0 | Carried |

## Per surface

| surface | weight | j8b | j9 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 91 | **92** | desktop click + menu title opens Finder's menu; hover keeps the app; submenu two frames carried |
| Dock | 14 | 90.5 | **91** | click activates and raises without a warp; Finder with no window opens none |
| Window chrome | 14 | 89.5 | **90** | click raises, inactive window's field takes the first click, no hover activation |
| Finder | 13 | 90 | 90 | carried |
| System Settings | 10 | 92 | **92.5** | pressed glyph matches the Mac's numbers |
| Control Center | 6 | 93 | 93 | opens / closes, SM tile 4 of 4 |
| NC + banners | 6 | 90.5 | 90.5 | opens / closes |
| Spotlight | 6 | 88 | 88 | opens / closes; curve carried |
| Mission Control | 4 | 88 | **88.5** | pick activates and raises (2 of 2); one ScreencopyView warning |
| Sounds | 4 | 87 | 87 | carried |
| HUD | 3 | 90 | 90 | carried |
| Cmd-Tab | 3 | 89 | 89 | commit raises (+), order not MRU (-) |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91 | 91 | carried, not tested |
| *Stage Manager (extra)* | *2* | *72* | ***80*** | see below |

Weighted: 13 surfaces 9049 / 100 = 90.49. With the lock screen 9504 / 105 = 90.51. With Stage Manager 9209 / 102 =
90.28. All round to 90.

## Stage Manager, judged alone: 80 (judge #8b: 72)

Fixed and seen: one continuous flight each way, no doubled window, no empty stage frame, the incoming window flies out
of its pile (also Settings), the new pile is filled from the flight's end, the focused window is on top after turning
it off. Left: the uninvolved pile disappears for 2-3 frames at 23-67 ms in 2 of 2 clicks; the incoming window's first
flight frame is already ~420 pt wide (pile ~260 pt); the outgoing window is drawn over the incoming one while they
cross (Mac order unknown); the strip stays hidden after a window is moved off it by `hyprctl`. Still no Mac stills or
video for the strip's look.

## Regressions

None found from the focus change. Checked: hover, desktop click + menu, desktop click + Spotlight, text-field first
click, window click, Dock, Cmd-Tab, Mission Control, Stage Manager on / off. Not testable: scrolling a background
window. New log line: the Mission Control ScreencopyView warning at the first open (no visible effect).

## The next 10 changes, by gain

1. Mission Control exit with several windows, from a Mac 4-window recording (+0.15, needs the Mac).
2. Stack popup (fan / grid) after a Mac capture (+0.1, needs the Mac).
3. Cmd-Tab order most recently used first (here Settings, Finder, footA; Mac: Settings, footA, Finder) (+0.05).
4. Submenu: draw the glass in the same frame as its labels (+0.05, carried).
5. Knob lens: darker rim (x.70) and a clear lens over content (+0.05, carried).
6. Stage Manager: keep the uninvolved pile drawn while the strip's set changes (gone 2-3 frames at 23-67 ms) (+0.03).
7. Spotlight open: start at 1.09 and shrink monotonically (spotlight-open-fit.json) (+0.03, carried).
8. Press light: keep the tint at the pointer over a bright backdrop instead of clipping to 255 255 255 (Mac peak 215
   243 255); check against the recording on the same backdrop first (+0.03).
9. Dock: clicking Finder with no Finder window opens one (check first that the Finder app runs in a test session) (+0.02).
10. Stage Manager: incoming window's first flight frame at pile size (74 ms: ~420 pt wide) (+0.02).

## Needs the Mac

Judge #8's list stands (MC 4 windows, stack popup, lock-in track, Quick Look, HUD timeout, key-up latency, knob over
stripes, Cmd-Tab without Finder windows, Dock label, Stage Manager stills and a 60 fps pile click, menu shadow crop over
white, held glass button in light, Spotlight open at 60 fps). Plus: which window is on top while the Stage Manager
flights cross, and the press light at the pointer over a bright sky backdrop.

## Reachable ceiling

Unchanged: about 91 with the repo's data, 91.5-92 with new Mac captures. Items 3, 6 and 8 are the largest repo-only
gains left; behaviour has no open focus regression.
