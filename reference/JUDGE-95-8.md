# hyprk independent judge #8, commit 1c180c3 (2026-11-12, 08:21-08:30 WITA; measured live by judge #8b 08:25-08:37)

Delta judgement against judge #7 (`JUDGE-95-7.md`, 3ea26fe, total 90). Same 12 dimensions, 13 surface weights + lock
screen 5. Row tags: **[8b live]** measured on screen by judge #8b in a headless session of 1c180c3; **[1c180c3 code]**
checked by reading the frozen tree and running its unit tests; **[dev]** the developers' own measurement in
`re/27.2.1/*.md`, read but not repeated; **[3ea26fe]** carried from judge #7.

## What was judged

- Commit 1c180c3. Judge #8 read a frozen copy (`git archive`) and ran `shell/tests/run.mjs` (349 passed) and
  `finder/tests/run.mjs` (27 passed), without a session.
- **Judge #8b, live:** one session from the live tree (HEAD 1c180c3 + this doc, no developer writing):
  `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (virtual 2560x1664@2x output MBA, `AQ_WAYLAND_NO_OUTPUT=1`, no host
  window), scratch HYPRK_STATE / XDG_CACHE_HOME / TMPDIR, private dbus-daemon without service activation,
  `NO_AT_BRIDGE=1 GTK_A11Y=none`, PipeWire pointed at an empty dir, `wpctl` / `pw-play` / `paplay` / `notify-send`
  stubs, `HYPRK_MUTE=1`. Tools built in scratch: `mcap` (6 runs, no capture gap: `long_intervals` 0), `vptr` + a
  right-click variant, `vkbd` (zwp_virtual_keyboard_v1). Light first, then dark from Settings > Appearance. Crops
  in `reference/judge-95-8/` (01-06).

## Overall: **90** (13 surfaces 90.1, with the lock screen 90.2, with Stage Manager folded in at weight 2: 89.8)

Judge #7: 90 (89.9). Seen on screen: judge #7's hover regression is gone, menus, Dock menu, Control Center,
Notification Centre and Spotlight open and close cleanly, the menu shadow renders exactly as decoded, the press light
on a dark glass button matches the recording's numbers, the submenu cone works, Spotlight's Command-hold list and
Cmd-1 work. Against: the **menu bar still flips away from Finder**, now on the click itself (below), the pressed
button's glyph disappears in dark, the submenu still draws its labels one frame before its glass, and the Stage
Manager pile click is rough. Judge #8's +1 for behaviour is withdrawn.

## Measured live (judge #8b)

| item | measured | verdict |
|---|---|---|
| Regression sweep | Finder File menu, Dock menu (Finder, Settings), Control Center, Notification Centre (clock), Spotlight (icon): each opens and closes (Escape / outside click), nothing left on screen. Quickshell log: no QML error, no binding loop; only environment warnings (no portal on the private bus, no `brightnessctl`, PipeWire not reachable by design, 4x `qt.svg` invalid path data) | clean |
| Judge #7's regression (hover over the desktop) | Ghostty clicked, pointer moved over the desktop without a click: menu bar stays "Ghostty" | **fixed** |
| `follow_mouse` after a desktop click | desktop click: bar "Finder"; pointer moved over the Settings window, no click: bar "System Settings" within 1 s (`03`, rows 1-3) | **confirmed** (Mac: Finder stays until a click) |
| Desktop click, then click "File" | desktop click: "Finder"; pointer to "File" without crossing a window: still "Finder"; **click on "File": the bar flips to System Settings and its app menu opens** at that spot (`03`, rows 4-6; reproduced twice) | **regression**: the click on the menu bar takes the keyboard from the desktop before the menu opens. Same user-visible symptom as judge #7's (wrong menu from the desktop), on a click instead of a hover |
| Press light, dark, Settings > Appearance preview share button | hover vs held 0.6 s, R G B added: 4 pt from the pointer **+58 +72 +76** (hover 156 175 173 -> 213 247 249); 8 pt +58 +70 +75; 26 pt +40 +54 +66. Recording frames 196 -> 220: 155 169 180 -> 215 243 255 = +60 +74 +75. Dev number (GLASS-INTERACTION 14): +60 +60 +49 at 4 pt, +33 +39 +44 at 30 pt. Release: back to the hover frame exactly (max diff 0) | light at the pointer **matches the recording** within 2 levels; wider than the dev's own numbers (more blue far out) |
| Pressed glyph, dark (`01`) | 20 pt box on the share glyph: hover mean 201, glyph 63 levels over the disc; held: mean 250, **glyph 4 levels over the disc** (invisible) | judge #7 item 4 **worse in dark**: the recording's glyph stays darker than its glow |
| Toolbar back button, dark (`02`) | +37 +37 +40 at 6 pt, +28 +29 +32 at 16 pt, +23 +23 +25 at 26 pt (dev: +41 at 6 pt, +13 at 24 pt). Chevron 245 on 79 -> 255 on 113 (contrast 166 -> 142): visible | light spreads further than the dev's figure; glyph fine |
| Lift | the press changes the whole merged capsule (718-793 x 242-282 pt), not only the share half | consistent with the decoded applyScale; size not measured |
| Menu drop shadow, dark (`04`), app menu over the wallpaper | ratio with / without the menu, left side at mid height, 3 / 6 / 9 / 12 / 18 pt: .899 .915 .928 .946 .968; decoded (ink .24, r 24): .897 .913 .928 .942 .965. Below (menu bottom 221 pt), 1 / 7 / 13 / 19 / 25 / 31 pt: .830 .860 .891 .924 .952 .973; decoded with y 10: .832 .863 .897 .928 .955 .974 | rendered **= decode** within .006. No Mac menu crop exists, so not checked against the Mac itself |
| Spotlight open (mcap, 680 x 170 pt) | first frame 110 ms after the click (includes vptr latency); fade `alpha` .18 .28 .44 .59 .73 .84 .92 .94 (16.7 ms steps), then a slow tail to 1 (caret). Bar extent incl. shadow: right edge 1.03 at the first frame, **1.04 at +33 ms**, 1.0 at +115 ms. Mac (`spotlight-open-fit.json`): 1.088 first visible, monotonic down to .994 at 150 ms | Mac shrinks from 1.09; ours starts near 1.0 and grows first. Shadow-included extent, so a rough measure; the shape difference is clear |
| Spotlight Command-hold | Ctrl held 0.6 s on the empty bar: the mode list (Applications Cmd-1, Files Cmd-2, Actions Cmd-3, Clipboard Cmd-4) below the bar; released: gone. Ctrl-1: Applications mode, categories and app grid | works |
| Stage Manager (CC tile on, 3 apps) | strip on the left with 2 piles + app icon badges, flat, no title bars in the thumbnails. Pile click (Settings), full output `-k 8`, 62 frames, no gap: frames 22 and 39 ms show **Ghostty twice** (two title bars, one offset up-right), at 55 ms Ghostty is up-right of its start, at 72 ms left: the outgoing window **jumps** instead of flying to the strip. Settings appears full size at 88 ms (no flight out of the pile). No empty stage frame. The new pile for Ghostty is **black for about 430 ms** (`alpha` steps .80 -> .99 at 539 ms, 1.0 at 690 ms). After switching it off: Ghostty drawn **above the focused Settings** (Ghostty's lights grey, bar "System Settings") | works, but the flight is erratic |
| Safe triangle, Dock menu > Options (`05`) | Options hovered, then 8 steps of 14 / 6 pt in 200 ms across "Show All Windows" toward the submenu: Options stays selected, submenu stays open | **works** |
| Submenu appearance (`06`) | Options hovered: submenu after 180 ms; first frame shows its labels on the menu's backdrop **without the glass**, glass on the next frame (`alpha` .54 then 1.0) | judge #7's two-frame item **still there** |

Not reached: the press in light mode, the menu shadow in light, the lift's size, Mission Control, the lock screen.

## Per dimension

| dimension | j7 | j8 | j8b | change vs j7 | reason |
|---|---|---|---|---|---|
| animation | 90 | 90 | 90 | 0 | [8b live] Spotlight open starts near 1.0 and grows to 1.04 before settling (Mac: 1.09 down to .99). [dev] lock-in .162 -> .330 jump. Release transaction not decoded. Carried |
| transition | 89 | 89 | 89 | 0 | Carried [3ea26fe]. Stage Manager flights scored separately |
| visual | 91 | 91 | 91 | 0 | [8b live] press light at the pointer within 2 levels of the recording (+58 +72 +76 vs +60 +74 +75), a real gain; against it the pressed glyph vanishes in dark (4 levels). [1c180c3 code] NC "Show less" circle. Net 0 |
| behaviour | 88 | 89 | **88** | 0 | [8b live] judge #7's hover regression fixed; Spotlight Command-hold and Cmd-1 work; safe triangle works. But desktop click + click on "File" opens System Settings' menu, and hovering a window flips the bar (`follow_mouse = 1`). Judge #8's +1 withdrawn |
| shape | 90 | 90 | 90 | 0 | [8b live] the press reaches the whole merged capsule. Lift size not measured. Carried |
| colour | 95 | 95 | 95 | 0 | Carried [3ea26fe] |
| shadow | 94 | 94 | 94 | 0 | [8b live] the menu shadow renders exactly as decoded (ratio within .006, beside and below). No Mac menu crop to settle the last step: 94 kept |
| refraction | 91 | 91 | 91 | 0 | [dev] knob lens rim x.54 vs x.70, flat lensBackdrop over stripes. Carried |
| icon | 90 | 90 | 90 | 0 | [8b live] CC Stage Manager tile glyph seen (squares.leading.rectangle). Stage Manager only |
| font | 95 | 95 | 95 | 0 | Carried [573470c] |
| rendering | 89 | 89 | 89 | 0 | [8b live] submenu labels one frame before its glass (`06`); Stage Manager double window frames (SM only). No `mcap` gap |
| sound | 87 | 87 | 87 | 0 | Carried [3ea26fe] |

## Per surface

| surface | weight | j7 | j8 | j8b | reason |
|---|---|---|---|---|---|
| Menu bar + menus | 15 | 91 | 92 | **91** | hover fix and safe triangle seen; the click from the desktop opens the app's menu; submenu two frames |
| Dock | 14 | 90 | 90.5 | 90.5 | Dock menus open / close, Options submenu cone works |
| Window chrome | 14 | 89 | 89.5 | 89.5 | no inactive flicker on desktop hover (seen) |
| Finder | 13 | 90 | 90 | 90 | Trash title only (not seen) |
| System Settings | 10 | 92 | 92 | 92 | press light right, pressed glyph gone in dark |
| Control Center | 6 | 93 | 93 | 93 | opens / closes; SM tile works |
| NC + banners | 6 | 90 | 90.5 | 90.5 | opens / closes (Show less circle not seen) |
| Spotlight | 6 | 87 | 88 | 88 | Command-hold list and Cmd-1 seen; open curve shape off |
| Mission Control | 4 | 88 | 88 | 88 | not seen |
| Sounds | 4 | 87 | 87 | 87 | unchanged |
| HUD | 3 | 90 | 90 | 90 | unchanged |
| Cmd-Tab | 3 | 88 | 89 | 89 | not seen |
| Apps | 2 | 86 | 86 | 86 | unchanged |
| Lock screen | 5 | 91 | 91 | 91 | not measured (no lock tests) |
| *Stage Manager (extra)* | *2* | - | *78* | ***72*** | see below |

Weighted: 13 surfaces 9013 / 100 = 90.13. With the lock screen 9468 / 105 = 90.17. With Stage Manager 9157 / 102 =
89.77. All round to 90.

## Stage Manager, judged alone: 72 (judge #8: 78 from the code)

Good: on and off from the Control Center tile, strip with piles and app badges, no empty stage frame, every default
decoded (STAGE-MANAGER-27.2.1.md). Seen against: the outgoing window jumps (up-right, then left) and is drawn twice in
the first two frames instead of flying into the strip; the incoming window appears in place at full size; the new pile
is black for about 430 ms; turning it off leaves the focused window under an inactive one; thumbnails without title
bars. Still no Mac stills or video, so the strip's look is unverified.

## Regressions

- **Desktop click, then a click on a menu title** opens the frontmost app's menu, not Finder's (`03`). Reproduced twice
  over the wallpaper with no window crossed. Judge #7's hover form is fixed; this click form is new or was hidden by it.
- **follow_mouse**: after a desktop click, moving over a window (no click) makes that app frontmost (`03`).
- **Pressed glyph in dark**: the share glyph vanishes in a 250-level disc (judge #7 saw it faint in light).
- Stage Manager: after turning it off, the focused window stays behind an inactive one.
- Not seen: the desktop stuck on Exclusive keyboard (judge #8's low-risk item); keys worked throughout.

## The next 10 changes, by gain

1. Keep Finder frontmost when the menu bar is clicked after a desktop click (the bar's click must not take the desktop's
   keyboard before the menu opens), and no follow-mouse focus change while the desktop holds it (+0.25).
2. Pressed glass glyph: keep it darker than the glow (dark: 4 levels now; recording frames 196-220) (+0.05).
3. Submenu: draw the glass in the same frame as its labels (+0.05).
4. Stage Manager pile click: one continuous flight to the strip, no double frame; incoming window out of the pile (+0.05 with SM folded).
5. Stage Manager: fill the new pile's thumbnail at once; raise the focused window when switching off (+0.03).
6. Spotlight open: start at 1.09 and shrink monotonically (spotlight-open-fit.json, bounce .32) (+0.03).
7. Mission Control exit with several windows, from a Mac 4-window recording (+0.15, needs the Mac).
8. Stack popup (fan / grid) after a Mac capture (+0.1, needs the Mac).
9. Knob lens: darker rim (x.70) and a clear lens over content (+0.05).
10. Lock-in: the .162 -> .330 jump, after a Mac lock-in track (+0.03).

## Needs the Mac

Judge #7's list stands (MC 4 windows, stack popup, lock-in track, Quick Look, HUD timeout, key-up latency, knob over
stripes, Cmd-Tab without Finder windows, Dock label). Plus: Stage Manager stills with 1 / 3 / 6 apps and a 60 fps pile
click, Mission Control with Stage Manager on, a 2x crop of a menu's shadow over white (dark and light: ours now equals
the decode, only the Mac can settle it), a held glass button in light mode, and a 60 fps Spotlight open with the
shadow separated from the bar.

## Reachable ceiling

Unchanged: about 91 with the repo's data, 91.5-92 with new Mac captures. Item 1 is the largest repo-only gain.
