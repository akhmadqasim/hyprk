# hyprk independent judge #5: PARTIAL (stopped early), commit fdb3858 (2026-11-11, 22:30-23:25 WITA)

## What was judged

- **Commit fdb3858** only, as a frozen copy (`git archive fdb3858`) in scratch with `HYPRK_ROOT` pointing at it;
  `reference/` read from the live repo. Other agents committed during the run (HEAD was 52e961f at 23:08); none of that
  is in here.
- Built artefacts copied from the live repo at 22:31, when HEAD was still fdb3858: `plugin/build/libliquidglass.so`
  sha256 dc6ea571…, built 21:17:25 (last `plugin/src` commit 3700816, 21:17:18); `plugin-motion/build/libhyprkmotion.so`
  7480f6b6…, built 16:39:53 (last `plugin-motion/src` commit ff8771f, 16:39:48); `finder/build/hyprk-finder` built
  19:37:40 (newest `finder/src` file 19:37:35; its QML loads from the tree). Settings is QML run by Quickshell.
- Ours: own headless sessions only, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` of the copy, own `HYPRK_STATE`,
  `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG`, a **private D-Bus** (the Control Center reads "Not Playing", no host notification
  service is touched), muted, PAM test double. Session A: MBA 2560x1664 at scale 2, started 22:31:49. Session B and D
  (a forked judge, same tree): scale 1.5 (Hyprland gives 1.6) and the `dist/hyprk-dist.lua` setup.
- Driven with `hyprctl dispatch` (own signature), `qs ipc --pid`, scratch builds of `vptr`, `vkbd` (and a copy with
  arrow keys), `mcap` / `mcap.py` for motion, `grim` for stills. Finder and Settings ran with HOME and XDG dirs in scratch.
- **Colour method changed** (COLOUR-P3-AUDIT.md): every Mac pixel that enters a colour comparison was converted with
  `p3_to_srgb()` first. Greys are unchanged by it; the "raw" column of the lights table shows what the old method read.
- The host was not quiet: other agents compiled on it (load 1.4-5.0, 8 x `cc1plus` at 22:49). Rows taken under load are
  marked. The motion rows of the first 20 minutes ran at load 0.5-1.9.
- Same scale as judges #1-#4: 95+ a careful observer cannot tell it from the Mac, 85-94 small measurable differences,
  70-84 visible at a glance, below 70 clearly different. Same 12 dimensions, same 13 surface weights.
- Rule: unverified = not credited. "carried" = judge #4's number kept because I did not re-measure; "not measured" = no
  number from me and no credit for a claimed fix.

## Status: PARTIAL

The run was stopped by the coordinator before it was finished. **There is no total.** A dimension has a score only when
its rows were finished; the others list what was measured and what is open. Nothing from judge #4 is carried forward.

Two things the next judge must know first:

1. **Capture leak (found by the coordinator during this run).** Hyprland 0.57.2 leaks one screenshare session per
   wlr-screencopy region request at scale != 1 (about 45 per `mcap` run, 1 per `grim`); from some thousands on, frames
   drop. So "session age" is really "captures taken". A patch exists (`/mnt/code/hypr-dev/patches/
   hyprland-0.57.2-screencopy-session-leak.patch`), not installed. My session A took 238 mcap runs and about 120 grims.
   Rows are marked with the mcap count before them: **under about 100 the timing and gap numbers are valid, above it only
   the curve shape is** (gap runs, late starts and "held frames" may be the leak). My own sample: Control Center open /
   close gap runs 0 of 8 / 3 of 8 at 0-16 captures, 1 / 2 at about 215, 4 / 6 at 238 (same tree, load 1.8).
2. **Host load.** Other agents compiled (load 1.4-5, once 11). The first 100 captures of A ran at load 0.5-1.9.

## Motion, scale 2, light, Tahoe (session A; C = a second fresh session)

rms / time rms from `mcap.py compare` after the best time shift; "same" = runs with the most common series.

| row | captures before | runs | 2-98 % ms (Mac) | rms / time rms | gap runs > 25 ms | same | Mac reference |
|---|---|---|---|---|---|---|---|
| Control Center open | 0 | 8 | 244-251 (233) | .013-.024 / 3.2-9.9 ms | 0 | 7 | REA spring 0.25, critical |
| Control Center close | 8 | 8 | 212-239 (233) | .018-.037 / 4.5-16 | 3 | 5 | same |
| Spotlight open, with the blur 25 -> 0 | 16 | 8 | 383 (main rise .91 in 110 ms) | no track | 0 | 8 | REA |
| Spotlight close | 24 | 8 | 132-135 | no track | 0 | 8 | REA |
| Notification Center open | 32 | 8 | 267-286 (267) | .004-.009 / 1.1-3.1 | 0 | 6 | nc/motion.json offsets as covered share |
| Notification Center close | 48 | 8 | 216-217 (233) | .033-.036 / 17 (share metric, not the edge: method) | 0 | 8 | nc/motion.json |
| HUD appear | 56 | 8 | **528-536 (483)** | **.026-.030 / 15-18** | 0 | 8 | verify/A hud-appear-fit |
| HUD dismiss | 64 | 8 | **331-353 (267)**, last step .98 -> 1.00 | .025-.027 / 22-27 | 0 | 5 | 1-(1-s)^2, s = spring 0.48669 |
| Banner in | 72 | 8 | 330-337 | not fitted | 0 | 8 | - |
| Banner out | 80 | 6 | 116-120 | not fitted; 2nd value lost or repeated (.24 .53 .88 .89 / .24 .75 .76) in 4 of 6 | 0 | 2 | - |
| Menu fade | 86 | 8 | 166-170 | within about .02 of OutQuad 194 ms by hand (my model in the tool was wrong) | 0 | 7 | Q-menubar-24 |
| Dock label fade | 94 | 8 | 263-285 (250) | .005-.014 / 1.5-4.2 | 0 | 4 | cosine 0.292 s |
| Full screen enter (foot) | 102 | 4 | 367 (350) | .020-.021 / 14 | 0 | - | R2 series |
| Full screen exit | 106 | 4 | 383-400 (383) | .011 / 9 | 0 | 3 | bezier (0.25,0,0,1) 0.5 s |
| Genie minimize | 126 | 4 | 416-421 (417) | .0073-.0088 / 3.4-4.1 | 1 | - | 1 - easeInOut(t / 0.5 s) |
| Genie restore | 127 | 4 | 416-421 | .0076-.0083 / 3.5-4.0 | 2 | - | same |
| Window close (foot) | 134 | 4 | 132-137 (133) | .005-.030 / 1.3-3.6 | 2 | - | R2 .29 .56 .73 .84 .91 |
| Cmd-Tab show | 139 | 5 | appears 221-256 ms after the trigger; in 3 of 5 over two frames (.19, then 1) | - | 1 | 3 | Q-dock-22 |
| Cmd-Tab dismiss | 144 | 8 | 217-232 (200) | .014-.031 / 3.3-6.3 | 1 | 3 | ease-in-out 0.236 s |
| Mission Control enter, Settings, **fresh C** | 0 | 6 | **333-335 (333)** | .0124-.0131 / 8.5-9.2; starts with 2-4 frames at .01 | 0 | 3 | R2 enter |
| Mission Control exit, Settings, **fresh C** | 6 | 6 | **267-284 (267)** | .012-.016 / 6.8-11 | 0 | 5 | R2 exit |
| Mission Control enter / exit, Settings, A | 152 | 6 / 6 | 417-433 / 283-290 | .008-.010 / 14 and .011-.016 / 3 | 0 / 2 | - | leak-affected: use the C rows |
| Mission Control enter / exit, one foot | 110 | 5 / 5 | 266-289 / 167-172 | .040-.047 / 26-30 and .067-.077 / 23-33 | 2 / 2 | - | **open: redo fresh** (plugin title bar windows) |
| Mission Control enter / exit, 4 windows | 164 | 5 / 5 | 311-350 / 242-250, exit plateau .94 | .034-.054 and .083-.091 | 4 / 1 | - | **open: redo fresh** (a C batch was cut off) |
| Unlock, 20 runs | 179 | 20 | menu bar 5 / 95 % +117 / +233 (Mac +137 / +250); clock 95 % +200 (~+219); Dock 95 % +200 (+226); wallpaper .50 at +100 (.33), starts with the first frame | - | 7 of 20 | fade seen 20 | LOCKSCREEN B3; zero = first frame with the clock region over 3 % |
| Appearance switch, shell (`theme setDark`) | 199 | 4 | 2 % at 205-261 ms, 2-98 % 385-402 | menu bar, Dock, wallpaper in step | - | - | AppKit cross-fade 0.5 s |
| Appearance switch, Settings click, **fresh C** | 12 | 5 | 2 % at 172-203 ms, 2-98 % 385-400 | bar, Dock, sidebar, pane, wallpaper within .006-.012 of each other per frame | 0-1 | 5 clean | same |
| Appearance switch, Settings click, A | 203 | 6 | 3 clean, 3 with a one-frame snap or a late start | - | 3-13 | - | leak / load: use the C row |
| Zoom / unzoom (`fullscreen({mode="maximized"})`) | 214 | 4 / 4 | 267-285 / 264-285 (267) | .015-.016 / 4 and .017-.018 / 6 | 3 / 3 | - | R2 zoom / unzoom |
| Dock magnification in / out | 222 | 6 / 6 | 150-151 / 166-167 (147) | .024-.040 / 3-6 (region holds the label) | 0 | 3 / 5 | cosine 147 ms |
| Full-screen bar peek in / out | 226 | 6 / 6 | 146-155 / 145-179 (150 / 170) | .004-.019 / .004-.033 | 0 / 2 | 6 / 4 | linear; no repeated first frame, 6 of 6 appeared |
| Lock-in | 235 | 3 | bar 95 % +67-75 (67), Dock +123-134 (117), field +207-218 | - | 0 | - | LOCKSCREEN |

Frames inspected: full screen enter / exit strip (`judge-95-5/01`): the strip darkens with the motion and the exit has no
overlap frame (both judge #4 faults gone), but on enter the menu bar titles are blank for one frame (frame 2, 4 of 4 runs,
the series reads .03, .00) and the window's own title bar is gone from that frame on. Genie (`03`): no ghost lines, the
shadow follows, no end pop (8 runs, 2 inspected).

Not measured: Quick Look open, shake, Dock bounce, NC push / clear, Apps, submenu delay, autohide, space switch.

## Scale 1.6 and the dist setup (forked judge, sessions B and D, both fresh, under 100 captures)

- Scale set with `hyprctl eval 'hl.monitor({output="MBA", mode="2560x1664@60", position="0x0", scale=1.5})'`: 1.6, 1600x1040.
- 1.6, light, 8 runs a row, load 5-13 for the first rows: CC open 217-234 ms .010-.033 (1 gap run), close 233-235
  (0); Spotlight open / close 8 of 8 the same; NC open .004 / 1 ms; HUD appear 533 ms .019 / 11 ms, dismiss 333-350;
  banner out loses a value in 7 of 8 (.23 .74 .75 .88); Dock label .006 / 2 ms; full screen enter .015 / 9-10 ms with
  the same one-frame blank, exit .006 / 2 ms; genie .004 / 1.5 ms; Cmd-Tab dismiss .010-.012, show in one frame 5 of 5;
  unlock equal to scale 2 (1 gap run of 20).
- **Mission Control at 1.6 with a Settings window: enter .061-.100 / 20-32 ms, starts with .39 held 4-5 frames; exit
  .109-.114, starts at .56 and plateaus at .93.** Frames: Settings drops to its inactive look (grey lights, grey selected
  row, sidebar glass gone) in frame 1 for about 4 frames (`B-mc-enter-inactive-flash-1.6.png`). Largest finding at 1.6.
- Shape at 1.6 against the plugin's own curve (`contour.py`, grey 127, rms px left / right, profile reading): slider
  tile .27 / .27, 2x2 tile .22 / .21, Dock .22 / .22, banner .11 / .13. Round CC button 104 x 104 px.
- Other 1.6 defects: Dock running dots drawn as dark vertical smears in one light shot after a window move, not
  reproduced in three later shots (`B-dock-dots-1.6-light-top-dark-bottom.png`); lights 22-23 px, within 1-2 px of
  round; text, rims, hairlines and icons sharp in magnified crops.
- Dist setup, headless (`hyprk_env_setup DIR private light`, HYPRK_NESTED=1, HYPRK_SCALE_POLICY=off,
  HYPRLAND_NO_SD_VARS=1, XDG_CURRENT_DESKTOP=Hyprland, HYPRK_CONFIG=dist/hyprk-dist.lua, through smoke.sh): Dock, menu
  bar, foot title bar and Settings are **pixel-identical** to the smoke setup at scale 2 (rms 0.00); CC open / close and
  the menu fade give the same series. Differences: HYPRK_SCALE does not reach the headless output (the named rule for
  MBA in `config/hypr/hyprland.lua:19` wins over dist's `output=""` rule, so the owner's nested window path could not be
  reproduced headless); 12 extra Ctrl+Alt binds; `titlebar_classes` holds Ghostty's class; apps get the dist fontconfig
  file (also reads the user's own font dirs), `QT_QPA_PLATFORMTHEME=qt6ct`, own XDG data / state homes; foot gets
  `pad=10x6` (in the smoke setup foot has no padding and its block cursor at column 0 is cut by the window corner).
  Not measured: a real nested host window, Ghostty / GTK / Qt apps in the dist setup.

## Per dimension

| dimension | score | measured (ours vs Mac) | open |
|---|---|---|---|
| animation | none (open) | rows above | Mission Control with foot and with 4 windows fresh, Quick Look, bounce, NC push |
| transition | none (open) | full screen, unlock, lock-in, peek, appearance switch above | shake, unlock in a fresh session (gap count), dark-mode runs |
| visual | none (open) | Pairs with the Mac shots, light and dark: Control Center, Spotlight, HUD, File menu, Finder icon view, Settings Appearance look close. Differences seen: the shell's Empty Trash alert is centred with a clear blue glass, the Mac's 27.2.1 alert is left-aligned on a neutral dark material (`05`); in Mission Control 2 of 3 inactive foot windows lose their title bar in the thumbnail (`04`); the Quick Look panel for a PDF (page shown: judge #4 gap closed) reaches under the Dock and its bar is mid-grey in dark; Cmd-Tab label about 14 pt bold vs about 12 pt; Settings appearance thumbnails show a photo, the Mac's the wallpaper; the smoke shot 3 s after start has a flat blue wallpaper; Applications and Movies folders have no glyph | lock screen, NC widgets, Apps, Settings panes other than Appearance, menus in detail, Finder list / column / gallery pairs |
| behaviour | none (open) | Dock drag-off on an empty desktop works (Remove bubble, poof logged, a running app moves to the recent section). Appearance > Auto without Settings: file set to auto at 23:02 Asia/Makassar, the shell went dark and wrote `dark: true`. Liquid Glass slider: Tab focuses it, Right adds .05. Settings window 740 x 625. **`qs ipc theme setDark` (the same property the `hyprk:appearance-*` shortcuts set) changes the shell only: appearance.json keeps `dark: false` and Settings stays light on a dark desktop.** One Spotlight toggle 0.6 s after closing Control Center was ignored (1 of 3). Deleting wallpaper.json does not restore the default (`{"path": ""}` does) | text highlight colour on screen, Finder context menus and tabs, menus, Mission Control layout rule, rubber band |
| shape | none (open) | CC slider tile over white against `verify/C2/cc-real-white-a0.507.png`: top edge per column, ours minus Mac, rms .62-.67 px over both corners (half-level threshold reading), flat middle +.01 px; 1.6 numbers above | Dock label tail, Dock end cap and HUD against Mac crops, menu corners |
| colour | **95** | P3 converted. Finder selection (0,100,225) light, (0,89,209) dark = the Mac's `live/finder/crops` to the level in icon, list and column view; sidebar glyph blue equal. Traffic lights, plugin bars (`02`, pointer quadrant masked, interior r 11 px), rms levels close / minimise / zoom: light rest 1.2 / 1.7 / 1.7, dark rest 2.6 / 1.7 / 7.4, inactive 1.1 and 0.7, hover (glyph pixels in) 7.9 / 3.6 light and 9.3 / 2.0 dark, pressed close 18.6 light / 15.8 dark, pressed minimise 10.9 / 3.8, pressed zoom 18.0 light. Finder's QML lights at rest: means within 2 levels. Alert tokens converted (#007AFF, destructive (240,29,20) = the Mac crop). Settings sidebar selection (0,142,255) vs (0,134,250). **P3 share:** read raw, the same lights would be rms 11-40 (rest) instead of 1-8, and judge #4's 93 rested on greys only, which the conversion does not move. With the corrected method judge #4's tree would have been about 91-92 (164 constants off by dE 1.5-4.5), so about +3 is code (constants converted, wallpaper import) and the method itself lowers the old baseline by about 1.5 | pressed states without the pointer in the shot; accents other than multicolour; dark zoom rest 7.4 |
| shadow | **94** | 2 / 8 / 16 / 32 pt, white, side / below / above (foot 700 x 532). Light active .19 .15 .09 .02 / .32 .28 .22 .10 / .07 .04 .02 0 (Mac .18 .14 .09 .02 / .32 .28 .22 .09 / .06 .04 .02 0). Light inactive .10 .04 .01 0 / .17 .11 .03 0 / .03 .01 0 0 (Mac .09 .04 0 0 / .16 .10 .03 0 / .03 .01 0 0). Dark inactive .20 .08 .01 0 / .35 .22 .07 0 / .07 .02 0 0 (Mac .19 .08 .01 0 / .33 .21 .06 0 / .06 .02 0 0). Dark active .33 .25 .16 .04 / .56 .49 .39 .18 / .12 .07 .04 0 (Mac .33 .25 .15 .04 / .56 .49 .38 .17 / .11 .07 .03 0). The genie carries the shadow. Banner shadow below: 6 % at the edge vs about 11 % on `panels/banner-dark-grey127.png` | Spotlight, menu, Mission Control band shadows |
| refraction | **91** | CC over 4 pt stripes, dark, against `verify/C2/cc-real-stripes-a0.5071146.png`, 18 rows: peak-to-peak equal within 1 (gap rows 33 vs 32-33, rim rows 1-2 vs 1-2, interior 4-8 vs 4-8), means within 0.5. Over white: rim rows 255 247 207 202 198 196 vs 255 247 207 201 198 195, interior 186.0 vs 186.0. Dock dark over white 192 185 179 178 177 vs 193 186 179 179 178 (`glass53/dock-dark-white.png`), over grey 156 135 117 114 113 112 vs 155 135 117 114 112 111. Banner top rim +26 over its backdrop vs +36. Banding on Tahoe with CC open (blue channel, longest equal run / one-level steps per 100 px): panel blur between the Sound tile and Edit Controls 34 px / 37 light, 50 px / 44 dark (wallpaper alone 9 / 45); Sound tile interior 42 / 42 and 57 / 44 | the lens at rounded ends, HUD and menu over stripes, icon clear-mode masks |
| icon | none (open) | Dock in Default / Dark / Clear / Tinted x light / dark: 8 looks on screen, Trash follows; `check-styles.py` re-run (files vs the Mac's Dock shots, converted, 66 px): Dark 4.7-8.4 rms, Default 5.6-13.5, ClearLight 2.9-9.2, TintedLight 7.8-15.4. Special folders carry glyphs (not Applications, Movies), PDF and text files show the page. The Downloads folder in the Dock keeps one blue in every style | Cmd-Tab and Apps in the styles, Settings row tiles and pane icons on screen, tagged folders, SF symbols |
| font | **95** | Menu bar, dark, against `menubar/bar-dark.png`: Apple mark and 7 titles start at x 41 108 230 312 399 496 572 708 px vs 41 108 231 313 398 497 571 709, widths within 1 px, ink rows 16-47 vs 17-47 | body text, Settings, lock clock |
| rendering | none (open) | No ghost lines, no overlap frame; under 100 captures 0 gap runs in 11 of 12 rows; the one-frame menu bar blank on full-screen enter; the capture leak above is a fault of the stack | fractional scale in dark, multi-monitor |
| sound | **84** | By code and log, as judge #4; no commit touched the sounds since. All 12 events resolve to an Apple original in my own log, `poof` logged on a live drag-off, `volume` only with feedback on. Left: the alert volume scales every UI event except volume and power; no Mac data for that | needs the Mac |

## Largest gaps seen so far (not a final ranking)

1. Mission Control with plugin title bar windows and at 1.6 (inactive flash, plateau, lost title bars in thumbnails).
2. HUD appear 528-536 ms vs 483 and dismiss 331-353 vs 267 with an end step, the same at 2 and 1.6: the curve, not frames.
3. Full screen enter: menu bar blank for one frame, title bar gone at once.
4. Shell-side appearance switch is not written to appearance.json and does not reach Settings / Finder.
5. The shell's alert layout and material against the 27.2.1 alert.
6. Banner out loses or repeats its second value (4 of 6 at 2x, 7 of 8 at 1.6).
7. Screencopy session leak in Hyprland 0.57.2 (stack; patch not installed).
8. Cmd-Tab: first frame partial in 3 of 5, label size. Quick Look panel under the Dock. Pressed lights. Banner rim / shadow.
9. Sound: alert volume on every UI event (needs a Mac capture of whether the screenshot, trash and mount sounds follow it).

Needs the Mac (unchanged from judge #4 where not closed): HUD dismiss track, Mac Dock in Clear / Tinted with Trash and
stacks, 27.2.1 shell alerts (Empty Trash) in light, Quick Look of a PDF, unlock per region at 60 fps, alert volume rule.

## Crops (`reference/judge-95-5/`)

- `01-fullscreen-strip.png`: top 60 pt, enter (upper 8 frames) and exit (lower 8), 2x.
- `02-traffic-lights-mac-left-ours-right.png`: 7 states, dark then light; Mac halves converted from Display P3.
- `03-genie-minimize-restore-frames.png`, `04-mission-control-mac-left-ours-right.png`, `05-alert-mac-left-ours-right.png`.
- `B-mc-enter-inactive-flash-1.6.png`, `B-dock-dots-1.6-light-top-dark-bottom.png` (scale 1.6).
