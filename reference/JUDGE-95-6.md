# hyprk independent judge #6, commit a2e61a0 (2026-11-12, 02:44-03:15 WITA)

Same rules as judges #4 and #5 (dimensions, 13 surface weights + lock screen 5, scale: 95+ a careful observer cannot
tell it from the Mac, 85-94 small measurable differences, 70-84 visible at a glance, below 70 clearly different).
Every row says where it comes from:

- **[a2e61a0]** re-measured by me on a2e61a0;
- **[573470c]** / **[fdb3858]** carried from judge #5 (or its part 1) because the code behind it did not change;
- **not measured** = no number from me, nothing new credited.

## What was judged

- **Commit a2e61a0** as a frozen copy (`git archive`), `reference/` linked to the live repo.
  `plugin/build/libliquidglass.so` copied from the live repo, sha256 7011ca88…, built 02:34:41, after the last
  `plugin/src` commit 1ff1180 (02:34:32). `plugin-motion/build/libhyprkmotion.so` 7480f6b6… (last `plugin-motion/src`
  commit ff8771f 16:39:48, built 16:39:53; same file as judge #5).
- **Finder binary:** the live `finder/build/hyprk-finder` (built 2026-11-11 19:37) is **older** than 045dadf (01:53:44,
  `finder/src/hypr.cpp` adds `Hypr::workArea`, which Quick Look now calls). I therefore built the Finder from the frozen
  tree (`cmake` + `ninja` in the scratch copy). `finder/run.sh` runs `cmake --build` on every start, so the owner's
  setup rebuilds it on the next launch; a copied binary would have judged old code.
- Own headless sessions only (`HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh`, MBA 2560x1664), each with its own
  private D-Bus, `HYPRK_STATE`, `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG`, a scratch HOME, muted. Eight sessions, at most two
  at once, all **fresh** for motion: A (scale 2 light, 46 mcap runs), B (scale 2 dark, 4 runs + stills: Settings
  Appearance pane against the 23.09.23 recording, CC, Sound module, shapes, lights), C (scale 2 light, then 1.6, 32 runs:
  Mission Control, CC, appearance at 1.6, Finder tags, alert over white), D (lock test double, 7 runs), E + F (dist
  against smoke, stills), G (4 pt stripes wallpaper, dark: CC refraction; Wallpaper pane), H (white wallpaper: window
  shadows). Host load 0.6-1.0 during motion runs, nothing compiling. Every Hyprland I started (and its forked child) is
  recorded and gone at the end.
- Tools built into scratch: `mcap`, `fscroll`, `vptr`, `vkbd`. Mac references: `reference/screens/27.2.1/**`,
  `re/MAC-ANSWERS.md` (R2, Q-dock-19..22), `re/27.2.1/live/verify/A/hud-appear-fit.json`, `verify/C2/cc-real-stripes-*`,
  `windows/lights-*`, `panels/alert-*`, `finder/icons-light.png`, `dock/dock-dark.png`, `hud-vol-dark.png`,
  `menubar/pulldown-dark.png`, the 23.09.23 recording (frames extracted to scratch only), the user's two Control Center
  JPEGs (scratch copies, layout only). Mac colours converted with `p3_to_srgb()`.
- Method: alpha = least-squares blend factor (`mcap.py`); "share" = R2's share of the total pixel change; rms after the
  best shift of -2..+2 frames; gap = a present interval over 25 ms inside 2-98 %.
- Scale 1.6 was set with `hl.monitor({... scale=1.6})` (the brief's example line says 1.5; judges #4/#5 used 1.6).

## Overall: **90** (13 surfaces 89.5, with the lock screen 89.6, plain mean of the 12 dimensions 90.3)

Judge #5 was 89 (88.9). Under the number: the four visible faults judge #5 found are gone or were not faults (the
appearance switch is in one curve in 19 of 20 runs, the shortcut writes the mode and Settings follows, the Mission
Control band is gone, the Cmd-Tab "patch" is the Dock recipe's thin blur that the Mac shows as well). Three judge #5
findings were wrong (HUD dismiss, alert material, Cmd-Tab patch). Against that: Mission Control now shows a 4-5 frame
hold before the flight and drops the Spaces bar in one frame on exit, and the new toolbar press washes the button to
white where the Mac keeps the glyph.

## The three disputed findings

| finding (judge #5) | what I measured | verdict |
|---|---|---|
| HUD dismiss front-loaded (.17 .33 .45) with a 6-10 % end snap | `hud hide` 0.75 s after `hud volume`: box alpha 1 .96 .85 .70 .55 .43 .33 .25 .19 .15 .12 .09 .07 .05 .04 .03 .02 .02 .02 .01 …, no step at the end, 2-98 % 263-270 ms (4 of 4). The Mac's own metric (p97 of the glyph box, `hudana2.py`) on ours: .98 .92 .84 .76 .68 .60 .52 .46 .39 .34 .29 .25 .21 .18, **rms .026-.027** against hud-appear-fit episode 2 (.98 .91 .82 .73 .65 .57 .50 .44 .38 .28 .28 .24 .18), 4 of 4. The automatic dismiss (no `hide`, starts 1080 ms after show) is the same curve (2 of 2). Reproduced judge #5's numbers only by mistake: triggering `hide` 1.2 s after `show` puts the reference frame inside the automatic dismiss, giving .79 .50 .41 … and a -.10/-.13 last step | **developers right**; judge #5 compared box alpha (ours) with glyph brightness (Mac), and its runs were most likely started inside the automatic dismiss |
| Alert material blue clear glass vs the Mac's near-neutral | Like backdrops: dark, over a dark window (Mac backdrop 30,30,35, ours 33,34,39): interior Mac 55,55,61, ours 60-70; Cancel fill Mac 70,70,76, ours 75,75,81. Light, over the white Finder: interior Mac 254, ours 252-254 (`02`, `03`). Mac `alert-light.png` sits over a white window, judge #5's crop of ours over the blue wallpaper | **developers right**: the material is within 5-15 levels over like backdrops; judge #5's crops had different backdrops |
| Cmd-Tab "unblurred patch" | Ours light over two windows (`ct-light`, scratch) shows the backdrop sharp through the panel; the Mac's `cmdtab-light.png` shows the wallpaper's diagonal edge equally sharp through its panel; Q-dock-19 says the Cmd-Tab is the Dock material (LIVE: blur 1.5) | **developers right**: not a fault |

## Per dimension

| dimension | j4 | j5 | j6 | change | evidence and reason |
|---|---|---|---|---|---|
| animation | 86 | 88 | **89** | +1 | Better, all [a2e61a0]: HUD dismiss rms .026-.027 on the Mac's glyph metric; lock shake 0 -10 -14 -10 0 10 14 10 … 7 5 0, 25 frames in 400 ms, longest interval 17.5 ms, 3 of 3 (Mac 400 ms, 14 / 8.25 / 6.75); minute change 32 frames, no repeat; Quick Look close 1 .97 .84 .68 .53 .38 .24 .14 .08 .06 0, 164-168 ms, no repeated value 3 of 3 (Mac ~180 ms); toolbar press .28 .70 .85 .91 .95 .97 .99 vs recording .24 .65 .83 .91 .96 .99; CC open 234 / close 217 ms (233), rms .024-.041 against a critical 0.25 s spring. Worse or still off: Mission Control 1 window: enter 317-334 ms but a .24 hold for 4-5 frames before the flight (rms .079-.096 against R2), exit 183-200 ms with .59 in the first frame (rms .112-.116; R2 .21, 267 ms), 4 of 4; 4 windows exit 200-300 ms, first frame .51 (rms .120), 4 of 4; at 1.6 enter 333-335 with a .14 hold (rms .051-.062), exit 183-185 (.70 first frame, rms .141), 3 of 3 |
| transition | 84 | 86 | **88** | +2 | Appearance switch [a2e61a0]: Settings click 8 of 8 in one curve (spread .004-.007, monotonic, 2-98 % 384-386 ms); shortcut 5 of 6 at scale 2 and 6 of 6 at 1.6 (spread .004-.009, Settings pane in the same curve); 1 of 20 with a 690 ms hold where bar, Dock and wallpaper ran 5 frames ahead of the pane (spread .30). Full-screen enter title bar: tracked red-light ink 1 .60 .46 .38 .32 .27 .22 .18 .16 .12 .09 .06 .04 .01, **rms .029-.030** against AppKit's (0,1,1,1) 0.25 s cross-fade, 4 of 4; menu bar strip fades monotonically, no blank frame (4 of 4). Unlock spot check (2 valid runs of 3; the first had a stray character in the field): clock 95 % +199-200 (Mac ~219), Dock 95 % +199-200 (226), bar 20 % / 95 % +117 / +232-235 (137 / 250), wallpaper 50 % +117 (Mac .33 at +100): about one frame earlier than judge #5's run, within 1-2 frames of the Mac. Against: Spaces bar gone in one frame on Mission Control exit |
| visual | 90 | 89 | **91** | +2 | Fixed [a2e61a0]: no band above window thumbnails in Mission Control (light and dark, `08`); Cmd-Tab complete and like `cmdtab-*` (patch not a fault); alert like the Mac over like backdrops; Quick Look panel bottom at 741 pt, Dock top 744 (inside the work area); Settings Appearance thumbnails show the desktop picture; Wallpaper pane Pictures and Landscape tiles filled 3.5 s after opening. Off: the new toolbar press turns the whole capsule near white and hides the share glyph (Mac: local glow, glyph visible); the preview toolbar capsule is brighter than the recording's (rest 185 vs 166 levels, pressed 230 vs 204; after the recording's level scale fitted on the photo, ×0.92, about +4 / +8); tag dots saturated (`04`); Dynamic wallpaper tiles and the current-picture preview still blank at 3.5 s (filled by ~9 s) |
| behaviour | 87 | 87 | **88** | +1 | [a2e61a0] the shortcut writes `"mode": "dark", "dark": true` (3 of 3) and the open Settings pane follows in the same curve; Quick Look stays in the work area; slider drag updates the preview toolbar live; trackpad scroll (`fscroll`) moves the preview article under the glass toolbar with momentum, like the recording. New: a click on the empty desktop with Settings open left the menu bar on "System Settings" (Mac: Finder becomes active), 1 of 1 |
| shape | 89 | 89 | **90** | +1 | [a2e61a0] pixel contours: Dock end cap at tile 33 (same Dock height, 94 px) row offsets .309 .151 .098 .057 .021 .011 … .032 .057 .087 .150 .277 of the height vs Mac `dock-dark.png` .330 .151 .098 .057 .036 .016 … .036 .057 .087 .150 .309 (≤ 2 px); HUD 614 x 130 px vs Mac 615 x 130, end-cap offsets within .008 of the height (≤ 1 px) vs `hud-vol-dark.png`; menu bottom corner offsets 22 14 10 8 6 4 3 2 2 1 1 vs `pulldown-dark.png` 30 14 10 8 6 4 3 2 1 1 1 px (one 2-px step); tagged folder 117 x 95 px vs 117 x 93; Cmd-Tab tile complete. Dock label tail: base about 14-15 pt, height about 6.3 pt, tip about 3 pt above the Dock at tile 48 (Mac numbers 16 x 6.5, 2.5 pt at tile 33): **no Mac crop exists** for a contour |
| colour | 93 | 95 | **95** | 0 | [a2e61a0] text highlight on screen (179,215,255) = the Mac's Blue selectedTextBackgroundColor #B3D7FF; tagged folder body within 1-3 levels of `icons-light.png` (tab 242,141,60 vs 239,139,58; front 245,142,60 vs 246,143,60); lights dark: rest within 1, hover within 2, pressed close 247,108,94 vs 255,114,100, pressed minimise 254,248,13 vs 255,247,0. Off: pressed zoom 41,231,4 vs the Mac crop's 27,192,0 (the crop shows no press change); tag dot orange 255,149,0 vs the Mac's 255,164,83 (pale) |
| shadow | 93 | 94 | **94** | 0 | [a2e61a0] re-measured over a white wallpaper (2 / 8 / 16 / 32 pt): light active side .19 .15 .09 .02, below .32 .28 .23 .10, above .07 .04 .02 0 (Mac .18 .14 .09 .02 / .32 .28 .22 .09 / .06 .04 .02 0); light inactive .10 .04 .01 0 / .17 .11 .03 0 / .03 .01 0 0 (Mac .09 .04 0 0 / .16 .10 .03 0 / .03 .01 0 0); dark inactive .20 .09 .01 0 / .35 .23 .07 0 / .07 .02 0 0 (Mac .19 .08 .01 0 / .33 .21 .06 0 / .06 .02 0 0). Banner shadow not measured |
| refraction | 88 | 90 | **91** | +1 | [a2e61a0] CC Display / Sound tiles over 4 pt stripes, dark, against `verify/C2/cc-real-stripes-a0.5071146.png`: interior rows p2p 7 and 4 vs 7 and 4, means 111.0 / 109.2 vs 110.4 / 109.2, gap rows std 13 vs 13, rim rows std 0-1 vs 0-1 (`05`). The Cmd-Tab finding is gone. Pressed knob lens looks like the recording's (dark lens with the blue track through it) but was **not measured** over stripes or at the rounded ends |
| icon | 87 | 88 | **89** | +1 | [a2e61a0] tagged folder (orange) matches pixel-wise; sidebar SF Symbols vs `icons-light.png`: Recents 34x34 px ink 393 vs 394 (IoU .99), Downloads 426 vs 427 (.99), Applications 395 vs 394 (.88), Shared 531 vs 521 (.74, 1 px offset). Off: tag dots saturated; Downloads stack in Dark / Tinted / Clear not re-checked (no code change since judge #5) |
| font | 95 | 95 | **95** | 0 | Carried [573470c] (menu bar titles within 1 px). Spot checks [a2e61a0]: Spotlight, alert and Cmd-Tab labels side by side with the Mac shots, no visible difference; Cmd-Tab label 13 pt bold per session 16 (not re-measured by me) |
| rendering | 88 | 88 | **89** | +1 | [a2e61a0] Cmd-Tab complete in the first frame 8 of 8 (shown 229-596 ms after the trigger; Mac ~190 ms after Tab); no Mission Control band; dist setup pixel-identical to smoke (max difference 0). Off: Spaces bar one-frame exit; toolbar press clips to white; the screencopy session leak of Hyprland 0.57.2 (stack, patch not installed) |
| sound | 84 | 84 | **84** | 0 | No sound code change since fdb3858 (git diff empty). Spot check: `sound.sh` picks Tink for alert, `empty trash.aif`, `poof item off dock.aif`, `Volume Mount.aif`, `Screen Capture.aif` (logged, muted). Alert-volume rule still needs the Mac |

## Per surface

| surface | weight | j5 | j6 | main reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92 | 92 | Menu corner within 2 px; titles carried |
| Dock | 14 | 90 | 90 | End cap within 2 px at tile 33; label tail and Downloads stack unchanged |
| Window chrome | 14 | 88 | 89 | Full-screen title fade matches; shadows re-measured; pressed zoom too bright |
| Finder | 13 | 88 | 89 | Quick Look in the work area, close without repeats; tag folder matches, tag dots saturated |
| System Settings | 10 | 90 | 91 | Follows the shortcut, thumbnails, toolbar hover; press washes out, dynamic tiles late |
| Control Center | 6 | 93 | 93 | Layout like the user's JPEGs; stripes match; Sound module device glyph |
| NC + banners | 6 | 89 | 89 | Not re-measured |
| Spotlight | 6 | 86 | 86 | Not re-measured (highlight colour checked) |
| Mission Control | 4 | 86 | 86 | Band gone; hold before the flight, one-frame Spaces exit, 4-window exit |
| Sounds | 4 | 84 | 84 | Unchanged |
| HUD | 3 | 87 | 90 | Dismiss on the Mac's metric, shape pixel-exact |
| Cmd-Tab | 3 | 84 | 89 | Complete every open, patch not a fault |
| Apps | 2 | 86 | 86 | Not re-measured |
| Lock screen | 5 | 91 | 92 | Shake and minute on the frame clock; unlock within 1-2 frames |

## Motion rows

### Re-measured at a2e61a0, scale 2, light (fresh sessions A and C)

| row | captures before | runs | result | Mac | gap runs |
|---|---|---|---|---|---|
| Appearance, Settings click | A 0 | 8 | spread .004-.007, monotonic, 384-386 ms, start +171-188 ms | AppKit 0.5 s cross-fade after the hold | 0 |
| Appearance, shortcut | A 8 | 6 | 5 in step (spread .004-.008); 1 with a 690 ms hold, shell .02 .05 .09 .22 .30 while the pane stays 0, then .37 | same | 1 (the hold) |
| Cmd-Tab first frame (400 x 240 pt) | A 14 | 8 | 0 → 1.00 in one frame, 8 of 8 | complete in one frame | 0 |
| Quick Look close / open (`remain`) | A 22 | 3 / 3 | close 164-168 ms, no repeat; open 133 ms | Q-finder-26 ~0.18 s; open: no Mac track | 0 |
| Full-screen enter, title bar ink | A 28 | 4 | rms .029-.030 (above) | (0,1,1,1) 0.25 s | 0 |
| HUD dismiss (`hide` 0.75 s after show) | A 36 | 4 | above | hud-appear-fit ep. 2 | 0 |
| HUD automatic dismiss | A 44 | 2 | same curve, starts 1080 ms after show | needs the Mac (timeout) | 0 |
| Toolbar press / release (preview share button, dark) | B 0 | 2 / 2 | press .28 .70 .85 .91 .95 .97 .99; release 1 .99 .97 .94 .90 .85 .80 .74 … | recording frames 196-215 / 251-285 | 0 |
| Mission Control 1 window (Settings 740 x 625) | C 0 | 4 / 4 | enter 317-334, hold .24 for 4-5 frames; exit 183-200, .59 first frame | R2 333 / 267 | 0 |
| Mission Control 4 windows | C 8 | 4 / 4 | enter 331-352 (rms .038-.065); exit 200-300, .51 first frame (rms .120) | R2 | 0 |
| Control Center open / close | C 16 | 2 / 2 | 234 / 217 ms | spring 0.25 critical (233) | 0 / 1 |

Per region on the 1-window runs (share): the window region holds at .40 for 4 frames on enter (it turns inactive
first), the menu bar leaves in 3 frames from +119-139 ms, the Spaces bar comes in from +119-139 ms; on exit the Spaces
bar and the menu bar change by .95-.97 in the first frame, the Dock comes back from +172-189 ms. Whether judge #5's
.009 / .007 rows used the same window size is not recorded; the hold and the one-frame Spaces exit are visible faults
either way, and the developers' session 17 describes the same hold at 1.6.

### Scale 1.6 (session C after a scale change, 20-32 captures)

| row | runs | result | judge #5 |
|---|---|---|---|
| Mission Control 1 window enter / exit | 3 / 3 | 333-335 ms (hold .14 for 4-5 frames, rms .051-.062) / 183-185 ms (.70 first frame, rms .141) | 384 / 300-318 |
| Appearance shortcut | 6 | 6 of 6 in step, spread .004-.009 | - |

### Lock screen (session D, PAM test double)

Shake 3 of 3 the same series, 400 ms, longest interval 17.5 ms; minute change 32 frames, longest interval 17.0 ms;
unlock above. Lock-in not re-measured.

### Carried, not re-measured

Spotlight, NC, banners, menu fade, Dock label fade and magnification, genie, window close, zoom, Dock bounce, alert
pop, Sound module open / close, bar peek, lock-in [573470c or fdb3858].

## Against the 23.09.23 recording (Settings > Appearance, dark, scale 2)

Aligned on the preview photo (NCC .97). Hover: a 31-32 pt disc on the share button in one frame, like frames 8-63.
Press: the curve matches (above), but the look does not: the recording keeps the white share glyph inside a local
glow that fades towards the "…" button; ours turns the whole left capsule near white and the glyph disappears. Knob
press: a dark glass lens with the blue track through it on both, no measurable difference by eye. Preview during the
drag: the toolbar glass goes clearer as the knob moves left, live, as in frames 2100-2500. Scroll: the article scrolls
under the glass toolbar with momentum and a scroll bar, and the toolbar picks up the photo's colours as in frames
1400-1460. Colour: our capsule rest 185 vs 166 levels (pressed 230 vs 204); the recording is about 8 % darker overall
(photo fit), leaving about +4 / +8.

## Side-by-side pass, largest visible difference first

1. **Toolbar press** (Settings preview): capsule washes to white, glyph gone (recording: glyph kept, local glow).
2. **Mission Control**: 4-5 frame hold before the windows move; the Spaces bar vanishes in one frame on exit.
3. **Tag dots** (Finder): saturated system colours where the Mac draws pale dots (`04`).
4. **Pressed zoom light**: bright neon green; the Mac crop keeps the rest green with the dark glyph (`01`).
5. **Desktop click** does not hand the menu bar to Finder (1 of 1).
6. **Wallpaper pane**: Dynamic tiles and current preview blank for several seconds.
7. **Sound module**: selected output shows a speaker glyph, the Mac a device-type glyph (laptop); rows, slider, header
   and "Sound Settings…" in the Mac's places (user JPEG 23.11.22).
8. **Control Center**: tiles, circles, sliders, Edit Controls in the user JPEG's places; on-states (white circle with
   blue glyph for Bluetooth, white circle with black glyph for Dark Mode) the same.
9. **Downloads stack** unstyled in Dark / Tinted / Clear (carried).
10. **HUD, menus, Dock, alert, Cmd-Tab, Finder icon view, desktop**: no visible difference at a glance; shapes within
    1-2 px where a Mac crop exists.

## Ranked gaps (gain in overall points)

| # | gap | surface / dim | fixable with | est. gain |
|---|---|---|---|---|
| 1 | Mission Control hold before the flight, one-frame Spaces bar exit, multi-window exit front-loaded | MC / animation, transition | repo data (R2, `mission-control.json`) | +0.3 |
| 2 | Toolbar press washes out the button | Settings / visual, rendering | repo data (the 23.09.23 recording, frames 196-285) | +0.15 |
| 3 | Tag dots too saturated | Finder / colour, icon | repo data (`finder/icons-*.png`, `popover-*`) | +0.1 |
| 4 | Downloads stack per icon style | Dock / icon | partly (`dock/dock-dark.png`); Clear / Tinted need the Mac | +0.1 |
| 5 | Preview toolbar capsule brighter than the recording | Settings / colour | repo data (recording) | +0.05 |
| 6 | Pressed zoom light brightens | windows / colour | repo data, but check `lights-press-zoom-*` first (it shows no press change) | +0.05 |
| 7 | Desktop click keeps the app's menu bar | all / behaviour | repo data (Mac behaviour known) | +0.05 |
| 8 | Wallpaper pane dynamic tiles late | Settings / visual | repo data | +0.05 |
| 9 | Appearance hold runs to 690 ms once in 20 | all / transition | repo data | +0.05 |
| 10 | Unlock about one frame early | lock / transition | repo data (LOCKSCREEN B3) | +0.03 |
| 11 | Sound module device glyph and open / close curve | CC / visual, animation | needs the Mac | +0.05 |
| 12 | Dock label tail 14-15 vs 16 pt | Dock / shape | numbers in repo; contour needs a Mac crop | +0.03 |
| 13 | Quick Look bar colour and open curve | Finder / visual, animation | needs the Mac | +0.1 |
| 14 | HUD automatic-dismiss timeout (1.08 s here) | HUD / behaviour | needs the Mac | +0.03 |
| 15 | Screencopy session leak | stack / rendering | stack (hypr-dev patch) | measurement only |

## Verdict on judge #5's top 15

| # | item | verdict |
|---|---|---|
| 1 | Shell out of step in the appearance switch | **fixed** (19 of 20; one long-hold outlier) |
| 2 | Shortcut writes mode light / dark true | **fixed** |
| 3 | Mission Control band | **fixed** |
| 4 | Cmd-Tab patch, ring, label | patch **wrongly reported**; tile on one surface, complete 8 of 8: **fixed**; label size not re-measured by me |
| 5 | Mission Control multi-window exit and 1.6 | **not** (4-window exit first frame .51; at 1.6 exit now 183-185 ms, too fast) |
| 6 | Qt-timer motions | **fixed** for shake, minute change, Quick Look close; banner not re-measured |
| 7 | Alert material | **wrongly reported** |
| 8 | Quick Look under the Dock, grey bar | **partly**: inside the work area; bar colour needs the Mac |
| 9 | HUD dismiss | **wrongly reported** |
| 10 | Downloads stack | **not** (no change) |
| 11 | Settings thumbnails, Wallpaper tiles | thumbnails **fixed**; tiles **partly** (Pictures yes, Dynamic and current preview late) |
| 12 | Full-screen title frame | **fixed** (rms .029-.030, no blank bar frame) |
| 13 | Lock-in Dock, status items | **not measured** |
| 14 | Screencopy leak patch | **not** (stack) |
| 15 | Sound module glyph | **not** |

## The next 15 changes

1. Mission Control: start the flight on the first frame (no inactive hold), keep the Spaces bar and menu bar on the
   exit curve, use R2's exit for several windows (+0.3).
2. Toolbar press: a local glow round the pointer that keeps the glyph visible, no clip to white (+0.15).
3. Tag dots in the Mac's pale tints (+0.1).
4. Downloads stack styled per icon style (+0.1).
5. Preview toolbar capsule 4-8 levels darker in dark (+0.05).
6. Pressed zoom without the brightening, after re-checking the Mac crop (+0.05).
7. A click on the empty desktop activates Finder (+0.05).
8. Wallpaper pane: Dynamic tiles and current preview at open (+0.05).
9. Cap the appearance hold so a slow answer cannot leave the window behind (+0.05).
10. Unlock one frame later (bar 20 % at +137, clock 95 % at +219) (+0.03).
11. Device-type glyphs in the Sound module (+0.05).
12. Dock label tail 16 x 6.5 pt (+0.03).
13. Quick Look bar colour after a Mac capture (+0.1).
14. HUD timeout after a Mac capture (+0.03).
15. Install the screencopy-leak patch on test machines (measurement quality).

Together about +1.2, so about 91 if all land.

## Needs the Mac (exact captures)

- Mission Control with 4 overlapping 700 x 500 windows, 60 fps, enter and exit (unchanged from judge #5).
- Dock label of one icon at tile 33 and 48, 2x crop over grey 127 (contour of the tail).
- Control Center Sound module open / close at 60 fps over grey 127; the selected-row glyph.
- Quick Look of a PDF: still and open series.
- HUD: time from the last key press to the start of the automatic dismiss.
- `lights-press-zoom-*` again (the current crop shows no press change).
- Mac Dock in Clear / Tinted with the Downloads stack.
- Unlock per region at 60 fps over grey 127.

## Reachable ceiling on this stack

- **With data already in the repo: about 91-92.** The gaps 1-10 above are bugs against data the repo holds (+1.0).
- **With new Mac captures: about 92-93.** Mission Control 4 windows, Sound module, Quick Look, HUD timeout, label tail,
  stack styles add about +0.3-0.5.
- **Never on this stack: the last 2-3 points to 95.** Evidence: rows on the frame clock already sit within a frame
  (HUD .026, CC 1 frame, title fade .03, shake exact, shadows ±.02, CC refraction p2p equal), so what is left is not
  tuning: no glass inside other apps' windows (the lens only samples its own window), no third-party menus or AppKit
  controls, Hyprland's screencopy leak and presentation gaps in long sessions, a zoom that stretches a buffer, no
  trackpad physics outside hyprk's views, and motions without Mac data.

## Crops (`reference/judge-95-6/`, 1.1 MB, no lock screen, no host device names, no recording frames)

`01-lights-pressed-dark-mac-left-ours-right.png`, `02-alert-dark-like-backdrop-mac-left-ours-right.png`,
`03-alert-light-over-white-mac-left-ours-right.png`, `04-tag-dot-orange-mac-left-ours-right.png`,
`05-cc-4pt-stripes-dark-mac-top-ours-bottom.png`, `06-hud-dark-mac-top-ours-bottom.png`,
`07-finder-tags-light-ours.png`, `08-mc-dark-no-band-ours.png`.
