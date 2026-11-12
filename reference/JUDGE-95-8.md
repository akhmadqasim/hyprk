# hyprk independent judge #8, commit 1c180c3 (2026-11-12, 08:21-08:30 WITA)

Delta judgement against judge #7 (`JUDGE-95-7.md`, 3ea26fe, total 90). Same 12 dimensions, 13 surface weights + lock
screen 5. Row tags: **[1c180c3 code]** checked by reading the frozen tree and running its unit tests; **[dev]** the
developers' own measurement in `re/27.2.1/*.md`, read but not repeated; **[3ea26fe]** carried from judge #7.

## What was judged, and what was not

- Commit 1c180c3 as a frozen copy (`git archive`), plugins copied from `plugin/build` and `plugin-motion/build`.
  `shell/tests/run.mjs` 349 passed, `finder/tests/run.mjs` 27 passed.
- **No live session.** The headless session (`scripts/smoke.sh`, `HYPRK_HEADLESS=1`) needs the host Wayland socket for
  its allocator (`AQ_WAYLAND_NO_OUTPUT=1` still connects to it), and the host socket is wayland-0, which this judge was
  told never to use. The start was refused by the permission system. Hyprland's other backends (DRM) would touch the
  host seat, so I did not try them. So **no mcap run, no pointer or key test, no shell log**. Every live item in the
  brief (press light and lift, menu shadow, Spotlight Command-hold, Stage Manager pile click, safe triangle, regression
  sweep) is **not measured by me**. No crops (`reference/judge-95-8/` not created).
- So scores move only where the code clearly fixes a judge #7 finding and the developers' numbers hold up on reading.
  Everything else is carried. Treat this as a provisional judgement: a judge with a session should re-run the items in
  "not measured".

## Overall: **90** (13 surfaces 90.3, with the lock screen 90.3, with Stage Manager folded in at weight 2: 90.0)

Judge #7: 90 (89.9). The gain under the number is behaviour. The desktop no longer takes the keyboard on hover (code),
Cmd-Tab lists Finder, Dock Trash and folders open our Finder, and Spotlight has the decoded Command keys. Nothing is
credited for the glass press light, lift, stretch or shadow ink, because I did not see them on screen.

Stage Manager (new, off by default) scores **78** on its own (below). Folding: it is an extra surface at weight 2
(total weight 102 without the lock screen): 90.0. Without it: 90.3. Both round to 90.

## Per dimension

| dimension | j7 | j8 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | [dev] lock-in hold gone (4706e74: .087 .162 .330 .457 .583 ..., 234 ms, no repeat), but the .17 jump judge #7 saw is still there (.162 → .330) and there is no Mac lock-in track. Press lift / stretch / release: the 0.25 / 0.629 spring is decoded, the release transaction is **not decoded** (GLASS-INTERACTION 11). Not measured: carried [3ea26fe] |
| transition | 89 | 89 | 0 | Carried [3ea26fe]. Stage Manager flights are scored separately |
| visual | 91 | 91 | 0 | [1c180c3 code] NC "Show less" turns into a circle with chevron.up while x reads "Clear" (b3369c0). It is 20 pt from the decode, against MAC-ANSWERS Q-panels-32's 28 pt AX frame (the doc says the AX frame includes the hit area: plausible, not checked on a Mac). Cmd-Tab now lists Finder. [dev] press light ring rms .015 / .012 against the recording, but the LittleGlow opacity and blur are **fitted** (GLASS-INTERACTION 14), and light mode has no recording. Judge #7's toolbar glyph contrast item: not re-measured. Net: no change without a live look |
| behaviour | 88 | **89** | +1 | [1c180c3 code] Background.qml: `keyboardFocus` is None unless the desktop was clicked (Exclusive until focus arrives, then OnDemand, then None when focus leaves). That removes judge #7's hover regression by construction (not seen on screen). Cmd-Tab: `switcherApps` keeps Finder listed, Finder first when the desktop holds focus, Q ignored for Finder, a windowless Finder activates the desktop. Dock Trash and folders open our Finder, Trash window titled "Trash". Spotlight: Cmd-0, R, Return, comma, B, K, Y, I from the decoded KeyboardShortcut table, query kept 8 min. Menus: predictive submenu cone from the decoded constants (15° widening, 0.5 s). **Remaining (code reading):** `follow_mouse = 1` is still on, so after a desktop click, moving the pointer over a window gives that window the keyboard and the menu bar flips back to the app without a click (Mac: Finder stays frontmost until a click). The same holds between two windows. Cmd-Delete in the Spotlight clipboard is **inferred**, Cmd-D / L / H and the menu bar icon press-and-hold are not built. +1 only, because none of it was run |
| shape | 90 | 90 | 0 | [dev] the lift grows the longer side and merged two-button capsules move only the outer end (decoded applyScale). Not measured: carried |
| colour | 95 | 95 | 0 | Carried [3ea26fe] |
| shadow | 94 | 94 | 0 | [dev] the glass shadow ink = 0.3 x ShadowOpacity (83329b6). Against the Mac crop `verify/C/tint-0.5-dark-sizes-regular-white.png` rms 0.76 levels (k 0.3) vs 15.3 before, but that is **computed, not rendered**, and the doc says no hyprk surface draws Regular glass of that size. The menu moved 1-2 levels on screen. Real but small and not seen by me: carried |
| refraction | 91 | 91 | 0 | [dev] held knob, dark, against recording frame 2685: rim ×0.54 vs Mac ×0.70, highlight +39 vs +32, face +10..17 vs +15..20, track through the lens +1..5 vs +4..7. Over stripes the lens shows a flat `lensBackdrop` (std 1.0 vs 127.5 beside it), while the Mac's clear lens would show them. The fill now runs to the track ends (e1a0411, from recording frames 2204-2518): right. Judge #7's missing lower highlight: the dev numbers do not settle it. Carried |
| icon | 90 | 90 | 0 | [1c180c3 code] the CC Stage Manager tile draws squares.leading.rectangle (the one decoded Image(systemName:)). Stage Manager only: no change to the main total |
| font | 95 | 95 | 0 | Carried [573470c] |
| rendering | 89 | 89 | 0 | Not measured (no session). Judge #7's submenu two-frame appearance: no commit touches it |
| sound | 87 | 87 | 0 | Carried [3ea26fe] (no sound change) |

## Per surface

| surface | weight | j7 | j8 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 91 | 92 | hover regression fixed in code, safe triangle decoded |
| Dock | 14 | 90 | 90.5 | Trash and folders in our Finder |
| Window chrome | 14 | 89 | 89.5 | title no longer goes inactive on desktop hover (code) |
| Finder | 13 | 90 | 90 | Trash title only |
| System Settings | 10 | 92 | 92 | Stage Manager switch, slider fill ends: not seen |
| Control Center | 6 | 93 | 93 | Stage Manager tile: not seen |
| NC + banners | 6 | 90 | 90.5 | Show less circle (20 pt, decoded) |
| Spotlight | 6 | 87 | 88 | decoded Cmd keys, kept query, mode list. Open curve not re-measured |
| Mission Control | 4 | 88 | 88 | unchanged |
| Sounds | 4 | 87 | 87 | unchanged |
| HUD | 3 | 90 | 90 | unchanged |
| Cmd-Tab | 3 | 88 | 89 | Finder listed |
| Apps | 2 | 86 | 86 | unchanged |
| Lock screen | 5 | 91 | 91 | hold gone [dev], jump remains, not measured by me |
| *Stage Manager (extra)* | *2* | - | *78* | see below |

Weighted: 13 surfaces 9028 / 100 = 90.28. With the lock screen 9483 / 105 = 90.31. With Stage Manager 9184 / 102 = 90.04.

## Stage Manager, judged alone: 78

From STAGE-MANAGER-27.2.1.md and the code, not seen on screen. Good: every com.apple.WindowManager default decoded with
its address, its own layer namespaces, and no empty stage frame (dev: 8 of 8 clicks at 2, 3 of 3 at 1.6). Against: the
Mac has **no still and no video** in the repo (section 4 lists all four as "needs the Mac"), so pile frames, tilt,
badge and flight motion are decode plus guesswork. The plugin's title bars are missing from the pile pictures (a
visible difference). A dragged window is seen only at the next window event. Mission Control shows only the stage's
windows, and the Mac behaviour there is not decoded. 78 = it works and follows the decoded numbers, but the look and
motion are unverified.

## Regressions

- **Judge #7's regression (desktop hover → Finder frontmost):** fixed by the code (Background.qml: no keyboard
  interactivity until a left click). Not confirmed live.
- **Possible, from reading the code:** with `follow_mouse = 1`, the desktop's keyboard is lost as soon as the pointer
  crosses a window, because Hyprland focuses the hovered window, `focused` turns false and `takeKeys` goes false. So
  "click the desktop, then move to the menu bar over a window" may land on the app's menus, not Finder's. Needs one
  vptr run: desktop click, pointer path over a window to "File", read the menu.
- **Possible:** the desktop takes Exclusive keyboard until focus arrives. If it never does (another exclusive layer is
  up), keys stay stuck. Low risk, not tested.
- None found in tests (349 + 27 pass).

## Not measured (for the next judge with a session)

Press light and lift on a glass button (light and dark), the menu glass shadow vs a Mac crop, Spotlight open +
Command-hold 0.35 s + Cmd-0, Stage Manager on + pile click (flight frames), the submenu cone with a diagonal path, and
a sweep (menu bar, Dock, CC, NC open / close, shell log errors). Plus the follow_mouse item above.

## The next 10 changes, by gain

1. Desktop focus survives pointer motion: no follow-mouse focus change while the desktop holds the keyboard (or
   `follow_mouse = 2`-style click focus overall, as on the Mac) (+0.2, repo data).
2. Mission Control exit with several windows, from a Mac 4-window recording; remove the 1.6 end step (+0.15, needs the Mac).
3. Stage Manager stills and pile-click video from the Mac, then fit the strip and the flight (+0.1 with SM folded).
4. Stack popup (fan / grid) after a Mac capture (+0.1).
5. Knob lens: darker rim (×0.70) and the clear lens over content (stripes visible), from the recording (+0.05).
6. Toolbar press glyph contrast (judge #7 item 4): re-check against frames 196-215 now that the light changed (+0.05).
7. Downloads stack tile: document icon with type label, second item behind (+0.05).
8. Lock-in: the .162 → .330 jump, after a Mac lock-in track (+0.03).
9. Submenu drawn complete in one frame (+0.03).
10. Spotlight: menu bar icon press-and-hold and Cmd-D / L / H (+0.02).

## Needs the Mac

Judge #7's list stands (MC 4 windows, stack popup, lock-in track, Quick Look, HUD timeout, key-up latency, knob over
stripes, Cmd-Tab without Finder windows, Dock label). Add: Stage Manager stills with 1 / 3 / 6 apps and a 60 fps pile
click, Mission Control with Stage Manager on, a 2x crop of a menu's shadow over white (dark and light), and a held
glass button in light mode (the press light is decoded for light but fitted on the dark recording only).

## Reachable ceiling

Unchanged from judge #7: about 91 with the repo's data, 91.5-92 with new Mac captures. The last 3 points to 95 are the
stack (third-party windows, menus, focus model). Item 1 above belongs to the focus model and can be fixed in this repo.
