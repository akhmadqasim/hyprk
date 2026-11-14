# hyprk independent judge #13, HEAD 7c25576 + working tree (2026-11-14, 03:03-03:12 WITA, measured live)

Delta judgement against judge #12 (`JUDGE-95-12.md`, 91.1). Method and weights from `JUDGE-95-7.md`: 12 dimensions,
13 surfaces + lock screen 5, Stage Manager as an extra surface at weight 2. Row tags: **[13 live]** measured on screen
here; **[13 static]** checked in the code or by rendering the shipped asset against a Mac picture, not on a running
surface; **[12]** carried from judge #12.

## What was judged

- Working tree changes since judge #12 (all uncommitted): Emoji & Symbols picker (`EmojiPicker.qml`, `Emoji.qml`,
  `lib/emoji.js`, Edit > Emoji & Symbols, Ctrl-Cmd-Space), decoded SF Symbols in the picker's category bar, the lock
  field's Caps Lock and return arrow and the Finder menus' checkmark, the held knob lens' bottom diffuse in dark
  (`knobLensDiffuseBottom` .04 / 4 pt -> .03 / 9 pt), the Dock menu tail (plugin `sdBoxTail` + shell), default key
  repeat 12 / s after 500 ms, Settings > Sound preview stops the previous one, the stack fan's PDF / text art, the title
  bar's 500 ms double-click (plugin source).
- **Run from a copy, not the repo**: `~/hyprk-tail-work` refreshed from the repo with the given rsync, plugin rebuilt
  there (`libliquidglass.so` 03:02, `lgtests` all passed), plugin-motion and Finder up to date. `/proc/<pid>/maps` of the
  test Hyprland showed `~/hyprk-tail-work/plugin/build/libliquidglass.so`. **The repo's own plugin build
  (`plugin/build`, loaded by the user's preview) is older: it has neither the tail nor the 500 ms title bar.** A user on
  the repo build sees the plain Dock menu (the shell's marker is dropped, per the README) and 400 ms.
- One session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (2560 x 1664, scale 2, then 1.6 and back with
  `hyprctl eval hl.monitor`), dark, scratch HOME from `make-demo.py` with 26 files in Downloads (distinct mtimes set
  later, newest a text file then a PDF), scratch HYPRK_STATE / XDG_CACHE_HOME / TMPDIR, the script's private bus.
  Tools: `vptr` (scratch build), `grim`, `cursor:invisible` for the lens. Apps: foot (title bar), System Settings.
  Stopped with `smoke.sh --stop`, bus killed, state dir removed, only 161706 / 161746 left. No user file was opened.
- Not re-measured: animation, shadow, colour, CC, NC, Spotlight, MC, HUD, Cmd-Tab, light mode, the lock screen on
  screen (rule; its glyphs were checked by rendering the shipped SVG against the Mac crop), the Sound preview (static).
- Crops in `reference/judge-95-13/` (01-07).

## Overall: **91.3** (13 surfaces 91.32, with the lock screen 91.32, with Stage Manager folded in at weight 2: 91.19)

Judge #12: 91.1. The gain is the emoji picker (it matches the Mac shot to within 1-2 pt everywhere measured, inserts
into a focused field, and Edit > Emoji & Symbols now works), the decoded symbols, and the knob lens, where the
correction of the judges' own reading holds. The Dock tail runs and sits on the icon centre at 2 and 1.6 but has no
Mac picture, so it gets partial credit. The key repeat change earns nothing: on a fresh state the session still ran
Hyprland's 25 / 600.

## Measured

### Emoji & Symbols picker (Mac: `panels/emoji-picker-dark.png`, 2 px/pt window capture) `01` `02`

| item | ours (scale 2) | Mac | verdict |
|---|---|---|---|
| body width | 640 px = 320 pt | 640 px (x 72..711) | match |
| body height, top to bottom | about 896 px (bottom edge blurred over the Dock) | 887 px | within about 4 pt |
| search field border below the body top | 16 px | 14 px | within 1 pt |
| first emoji row below the body top | 112 px | 110 px | within 1 pt |
| category bar separator below the body top | 801 px | 799 px | within 1 pt |
| row pitch | 88 px (44 pt) | 87.9 px | match |
| column pitch | 101-102 px (50.5 pt) | 101 px | match |
| emoji ink (yellow, 😀 row) | 51-52 px | 54 px | **about 1-1.5 pt smaller** |
| 48 smileys, order | same glyphs, same order | | match |
| category bar glyphs | decoded `emoji.*`, clock, lightbulb, heart, flag, chevron at the same places | same | match in shape; the Mac's dog and soccer ball read as filled white (inverse), ours as outlines, and the Mac's strokes are a little heavier `02` |
| tail on the top edge | yes, at the pointer | yes, at the caret | opened at the pointer (no caret position is known); not compared |
| scale 1.6 | row pitch 44.0 pt, column 50.5 pt, ink 25.6 pt | | same layout in points |
| Edit > Emoji & Symbols (Settings' menu) | opens the picker | | **fixed** (j12: row with no action) |
| pick 😃 with the Settings search field focused | 😃 in the field, picker closed, window active again | inserted | works (clipboard paste) |
| host window while the picker is open | **inactive look** (grey lights, dimmed sidebar) | no Mac picture of the host window | likely differs (the Mac palette does not take the app's key status), not counted |

### Dock menu tail (copy's plugin) `03` `04`

| item | ours | Mac | verdict |
|---|---|---|---|
| tail drawn, one outline with the body | yes, dark, scale 2 and 1.6 | "a glass bubble with a tail at the icon centre" (Q-dock-10, words only) | present |
| tip x against the Finder icon centre (scale 2) | about 420.5 pt, icon centre 420.5 | at the icon centre (decode + AX) | match |
| tail half widths under the body (column scan over the wallpaper) | about 10 at 1 pt, 2.5 at 9 pt | decode: 11.75 base, tip r 5.46 | consistent with the decode; no Mac pixels |
| scale 1.6 | tail drawn, tip on the icon centre | | no regression |

### Knob lens (dark, Settings > Appearance, held, cursor hidden) `07`

The GLASS-INTERACTION section 17 claim **holds**. In `live/verify/B2/slider_fit.txt` the `vert meas` row comes from
`slider_fit.py` lines 69-70: `full[4:46:2, 30]` of the **grady** capture, whose backdrop is the capture row (ramp value
2y - 0.5 = row, 124 .. 164 over the printed rows). The Mac's 149 / 124 / 171 sit on 126 / 142 / 160: x1.18 / .87 / 1.07.
The decoded model with a flat face, the ring and the key highlights (`vert model`) reproduces it (172 / 147 .. 172 /
171), so there is no extra lower highlight to copy. The "x1.30" judges #7-#12 carried was the ramp divided by the
centre value 132. Judges' ours x.95 at the bottom on a flat backdrop is still below the Mac's x1.07, but the gap was
about a quarter of what was charged.

Ours live, column 6 pt right of the lens centre, levels over the backdrop 17 pt right (card 38 / track 59), rims 19.5 pt
apart, 2 px/pt (section 17 resampled to 1.92, so the rims differ a little):

| pt | -8 | -6 | -4 | 0 | +4 | +5 | +6 | +7 | +8 | +9 |
|---|---|---|---|---|---|---|---|---|---|---|
| Mac (section 17, recording) | +26.1 | +18.8 | +14.7 | +4.0 | +13.5 | +15.6 | +16.6 | +18.2 | +20.9 | +24.9 |
| ours section 17 "after" | +23.4 | +16.5 | +13.7 | +3.0 | +11.0 | +12.0 | +13.5 | +15.4 | +20.4 | +24.6 |
| ours here | +25.5 | +16.5 | +13.5 | +2.0 | +11.0 | +12.5 | +14.5 | +16.0 | +22.5 | +27.5 |

The face under the track now rises toward the bottom rim as the Mac's does (before: flat +10). The fit is to one
recording frame on a 32 card (ours 38), dark only; light, the CC slider and stripes are not compared.

### Other

| item | ours | Mac / source | verdict |
|---|---|---|---|
| title bar double-click (copy's plugin, foot) | 450 ms apart: zooms, again restores; 560 ms apart: nothing | 0.5 s HIDClickTime (decode) | **500 ms in the plugin**, now the same as the Finder. Repo build still 400 |
| key repeat, fresh state | `hyprctl getoption input:repeat_rate` 25, `repeat_delay` 600 (both "set: false") | 12 / 500 intended | **not applied**: `Prefs.applyInput()` runs only from input.json's `onLoaded`; no input.json exists in `state/` or the scratch state, and no config sets repeat. Held volume keys still pop at 25 / s |
| stack fan art | PDF and ZIP pages, a text page with its first lines, Mac art (`05`) | `themes/icons/system/*-154.png` | match by construction; fan item size still constant (Mac grows 65.5 -> 78.3) |
| stack order, Date Modified | newest at the bottom (text, then PDF) | newest first | match (with equal mtimes it falls back to name) |
| lock Caps Lock glyph | `capslock.fill` medium, decoded | `field-light-capslock-empty.png` | same shape (arrow over a bar) `06`; size fitted to that crop (25 x 25 px) [13 static] |
| lock return arrow | `arrow.right.circle` regular 22 pt | `field-dark-1char.png` ring 44 px / 3.7 px | ring and stroke within 0.1 px by the developer's crop reading [13 static]; LoginUICore's own symbol name not found |
| Finder menu checkmark | `checkmark` semibold 10.7 pt, as the shared popup | no Finder menu shot with a check | consistent with the shared menus, not compared |
| Settings > Sound preview | kills the pane's previous `pw-play` by pid file before playing (`$$` survives `exec`, pid reuse checked by cmdline) | Sound.appex stops the alert first (decode) | correct by reading; not run |
| shell log | qt.svg "invalid path data" x5, portal and brightnessctl (headless) | | as judge #12, nothing new |

## Per dimension

| dimension | j12 | j13 | change | reason |
|---|---|---|---|---|
| animation | 90 | 90 | 0 | [12]; picker open / close motion has no Mac data |
| transition | 90 | 90 | 0 | [12] |
| visual | 92 | 92 | 0 | [13 live] picker matches its Mac shot, tail drawn (+); picker leaves the host window inactive, emoji ink 1-1.5 pt small (-) |
| behaviour | 91 | **92** | +1 | [13 live] Edit > Emoji & Symbols and Ctrl-Cmd-Space (bound) open a working picker that inserts into the focused field; title bar 500 ms in the copy's plugin. Key repeat default not applied (0) |
| shape | 91 | 91 | 0 | [13 live] picker 320 pt, 44 / 50.5 pitch = Mac; tail from the decode only (partial, counted in the Dock surface) |
| colour | 95 | 95 | 0 | [12] |
| shadow | 94 | 94 | 0 | [12] |
| refraction | 91 | **92** | +1 | [13 live] the x1.30 lower highlight was a misreading (checked in `slider_fit.py`), so the lens gap was overstated; ours now rises under the track as the recording does; one continuous rim and lens under the Dock menu's tail |
| icon | 91 | **92** | +1 | [13 live / static] decoded symbols in the picker bar (match the Mac shot in shape), lock glyphs (Apple's shapes, matched to the Mac crops), Finder checkmark, Mac PDF / text art in the fan. The picker's filled dog / ball not copied |
| font | 95 | 95 | 0 | [12] |
| rendering | 90 | 90 | 0 | [13 live] logs as before; nothing new |
| sound | 89 | 89 | 0 | [13 live] key repeat still 25 / 600 on a fresh state, so the held-key pop cadence is unchanged; preview stop by reading only |

Plain mean of the 12: 91.83 (j12 91.58).

## Per surface

| surface | weight | j12 | j13 | reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92.5 | **93** | Emoji & Symbols row works; picker within 1-2 pt of the Mac shot |
| Dock | 14 | 92.5 | **93** | menu tail on the icon centre at 2 and 1.6 (decode, no Mac picture: partial); fan PDF / text art |
| Window chrome | 14 | 90 | 90 | 500 ms runs only with a rebuilt plugin; judge #12 valued it at +0.01, not enough for a step |
| Finder | 13 | 90.5 | 90.5 | checkmark symbol, no Mac shot to compare |
| System Settings | 10 | 92.5 | **93** | knob lens bottom refit against the recording (Appearance slider), live profile as reported |
| Control Center | 6 | 93 | 93 | the same tokens, CC slider not compared |
| NC + banners | 6 | 91.5 | 91.5 | carried |
| Spotlight | 6 | 88 | 88 | carried |
| Mission Control | 4 | 90.5 | 90.5 | carried |
| Sounds | 4 | 89 | 89 | repeat cadence unchanged in practice; preview stop static |
| HUD | 3 | 90 | 90 | held keys step at 25 / s, as before |
| Cmd-Tab | 3 | 91 | 91 | carried |
| Apps | 2 | 86 | 86 | carried |
| Lock screen | 5 | 91 | **91.5** | Caps Lock and return arrow are Apple's symbols, matched to the Mac crops (static) |
| *Stage Manager (extra)* | *2* | *85* | *85* | carried |

Weighted: 13 surfaces 9131.5 / 100 = 91.32. With the lock screen 9589 / 105 = 91.32. With Stage Manager 9301.5 / 102 =
91.19.

## Regressions

None measured. Checked: Dock menu at 2 and 1.6 (rows, separators, placement unchanged, tail added), the Downloads stack
menu (all rows, checks), stack grid and fan, Finder icon in the Dock, title bar zoom / restore, Settings menus, the
Settings search field after a paste, shell log. Watch items, not counted:

- Key repeat: Settings > Keyboard and `Prefs.input` now say 12 / 500 as the default, but nothing applies it without an
  input.json, so the session runs 25 / 600. The Keyboard pane reads Hyprland's live value, so it shows 25 / 600: no
  visible mismatch, just a fix that does not run.
- The repo's plugin build is older than its source: the Dock tail and the 500 ms title bar run only after a rebuild.
- The picker deactivates the window under it while open (inactive lights and sidebar).
- `sound.sh`'s jq-failure `printf` still says 0.75 (the jq default is now 1).

## The next 10 changes, by gain

1. Mac capture of the Downloads stack: fan and grid stills at 2x, open / close at 60 fps (fan place marked GUESS, item
   growth, grid gap, durations, chevron) (+0.1, needs the Mac).
2. Mission Control exit with 4 overlapping windows, Mac recording (+0.1, needs the Mac).
3. Spotlight reopen first frame (judges #10-#12) (+0.05, repo only).
4. Apply the key repeat default at shell start when input.json is missing (one call to `applyInput()` on start), so
   held volume keys step at the Mac's 12 / s after 500 ms (+0.03, repo only).
5. Emoji picker: keep the host window active (no keyboard-focus steal look), emoji ink 27 pt, filled (`.inverse`)
   dog / soccer glyphs as in the Mac shot, open at the text caret where the app reports one (+0.03, repo only).
6. Fan item size setter (Mac 65.5 -> 78.3) (+0.03, static decode, then repo).
7. One Mac still of the Dock menu over grey 127 at 2x to confirm the tail on screen (+0.02, needs the Mac).
8. Knob lens in light mode and on the CC Sound slider, Mac stills over stripes (+0.03, needs the Mac).
9. The stock user's KeyRepeat / InitialKeyRepeat (if different from the kernel's) (+0.01, static decode).
10. Settings Sound sliders: preview 30 ms after the last let-go; `sound.sh` fallback 1 (+0.01, repo only).

## Reachable ceiling

About 91.5 with the repo's data (items 3, 4, 5, 6, 9, 10 and rebuilding the repo's plugin). About 92-92.5 with new Mac
captures (1, 2, 7, 8 and the area items below). 95 is not reachable on this stack with or without them: the reasons in
judge #7 (no glass or AppKit controls in third-party windows, unreachable app menus, Hyprland's presentation and focus
model, motions with no Mac data) still hold about 3 points.

## The twelve areas of the 95 goal

| area | scored as | now | what holds it under 95 | evidence needed |
|---|---|---|---|---|
| animation | animation | 90 | MC 4-window exit; stack fan / grid motion inferred; submenu in 2 frames; lock-in first frames; picker motion unknown | Mac 60 fps captures (MC 4 windows, stack, lock-in, emoji picker); the submenu is repo only |
| liquid glass | refraction + visual | 92 | tail present but never compared with Mac pixels; fan pills / grid bubble never compared; no glass in third-party windows | Mac stills: Dock menu, stack views over grey 127 |
| glass refraction | refraction | 92 | lens fitted to one dark frame (32 card); light and CC slider untested; stack glass not compared | Mac stills of a held knob over stripes, dark and light |
| shadows | shadow | 94 | banner shadow not measured; the tail's shadow never compared | Mac stills (banner over grey 127, Dock menu) |
| depth | shadow + rendering (layer order) | 92 | MC multi-window layer order assumed; picker over the Dock and the host's inactive look | Mac recording; Mac still of TextEdit with the picker open |
| opacity | colour | 95 | at target | none |
| blur | refraction + visual | 91 | NC column blur ramp not measured against ours; picker / menu blur radius by eye only | repo (measure ours against the decode) + Mac 60 fps NC open |
| sound | sound | 89 | repeat cadence (fix not applied); output latency; drop-on-Trash sound; preview timing | repo for the first; latency needs Mac audio + screen capture |
| icon | icon | 92 | no per-type art beyond ZIP / PDF / text (docx blank); picker's filled category glyphs; stack chevron size guessed | Mac renders of more document types (CoreTypes icns); repo for the glyphs |
| emoji | (direct) | 92 | picker emoji 1-1.5 pt small; host window goes inactive; size and baseline of emoji in text never compared | repo for the first two; a Mac shot of emoji in a notification and a menu |
| font | font | 95 | at target | none |
| scaling | (direct) | 90 | 1.6 lays out the same in points (tail, picker, Dock, NC); the Mac renders scaled modes at 2x and downsamples, never compared | Mac capture of a scaled mode of the Dock, a menu and NC |

## Crops (`reference/judge-95-13/`)

`01-emoji-picker-mac-left-ours-right.png`, `02-emoji-category-bar-mac-top-ours-bottom.png`,
`03-dock-menu-tail-finder-scale2-dark-ours.png`, `04-dock-menu-tail-finder-scale1.6-dark-ours.png`,
`05-stack-fan-pdf-text-scale2-dark-ours.png`, `06-lock-capslock-glyph-mac-left-decoded-symbol-right.png` (the right half
is the shipped SVG rendered larger, shape only), `07-knob-lens-held-dark-scale2-ours.png`.
