# hyprk independent judge #5 (complete), commit 573470c (2026-11-12, 00:50-01:20 WITA)

Part 1 of this round (22:30-23:25, commit fdb3858) was stopped early. This document replaces it. Its rows are kept
where they are still valid and every row says where it comes from:

- **[573470c]** re-measured by me on 573470c;
- **[fdb3858]** carried from part 1, valid because the code behind it did not change (I checked the diff) or because
  I could not re-measure it; carried rows get no credit for later claimed fixes;
- **not measured** = no number from either part, nothing credited.

## What was judged

- **Commit 573470c** as a frozen copy (`git archive 573470c`), `reference/` linked to the live repo. Built files copied
  from the live repo: `plugin/build/libliquidglass.so` sha256 d67a140b…, built 00:30:40 (last `plugin/src` commit
  0396e57, 00:30:24); `plugin-motion/build/libhyprkmotion.so` 7480f6b6… (same file as part 1; last `plugin-motion/src`
  commit ff8771f 16:39:48, built 16:39:53); `finder/build/hyprk-finder` built 19:37:40. The last `finder/src` commit
  6dd172e is at 19:39:54, but no `finder/src` file is newer than the binary, so it was built from that code.
- Own headless sessions only (`HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh`, MBA 2560x1664), each with its own
  private D-Bus, `HYPRK_STATE`, `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG`, muted. I used seven sessions, one after the
  other (at most 2 running at once), all **fresh**, so the motion rows are below the capture-leak limit:
  A (scale 2, light, 51 mcap runs), B (scale 2, light, 46), C (scale 2, lock test double, light then dark, 48),
  D (scale 1.6, dark, 22), E + F (dist setup against the smoke setup, stills only), G (stills, light / dark, icon
  styles). Host load during the motion runs: 0.3-0.6, nothing else compiling.
- Tools built into scratch: `mcap`, `vptr`, `vkbd`. Mac shots: `reference/screens/27.2.1/**`, `re/MAC-ANSWERS.md` (R2),
  `re/LIVE-27.2.1.md`, `re/LOCKSCREEN-27.2.1.md`, `re/27.2.1/live/verify/A/hud-appear-fit.json`. Mac colours were
  converted with `p3_to_srgb()` (COLOUR-P3-AUDIT.md). The user's new JPEGs (Control Center dark, Sound module) were
  used from scratch copies for layout only. The 23.09.23 recording was **not** re-read by me (session 15's reading of
  it is in MOTION-MEASURED.md; not credited here beyond what I saw on screen).
- Same scale as judges #1-#4: 95+ a careful observer cannot tell it from the Mac, 85-94 small measurable differences,
  70-84 visible at a glance, below 70 clearly different. Same 12 dimensions, same 13 surface weights (+ lock screen 5).
- Method notes: alpha = least-squares blend factor per frame (`mcap.py`), rms / time rms after the best time shift,
  "gap" = a present interval over 25 ms inside the 2-98 % window. Mac series with a 0 prepended (R2 lists start at the
  first moved frame), so R2 Mission Control enter = 333 ms, exit = 267 ms, Control Center critical spring 0.25 s = 233 ms.

## Overall: **89** (13 surfaces 88.9, with the lock screen 89.0, plain mean of the 12 dimensions 89.4)

Judge #4 was 89 as well. Under the number: the unlock now matches the Mac per region, Mission Control with one window
and the slider knob are within a frame, the HUD appear is closer. Against that, four new visible faults: a 25-30 pt band
of wallpaper glass above the Settings thumbnail in Mission Control, an unblurred patch in the Cmd-Tab glass, the
appearance switch where the shell runs out of step with the window for 5 frames (every run), and the shell shortcut
that turns the desktop dark while Settings stays light.

## Per dimension

| dimension | j4 | j5 | change | evidence and reason |
|---|---|---|---|---|
| animation | 86 | **88** | +2 | Better: Mission Control 1 window, knob, HUD appear, Control Center, alert pop, Dock bounce all within a frame or two of the Mac (rows below). Still off: Mission Control with 4 windows exits in 200-217 ms vs 267 (rms .085-.093); at 1.6 enter 384 ms vs 333 and exit 300-318 vs 267; HUD dismiss is front-loaded (.17 .33 .45 in the first 3 frames vs the Mac's .02 .09 .18) and ends with a 6-10 % one-frame snap in 9 of 9; the lock shake loses one frame in 3 of 3; Quick Look close repeats a frame in 3 of 4 |
| transition | 84 | **86** | +2 | Unlock (20 runs, fresh session): clock 95 % +216-219 ms (Mac ~219), Dock +216-219 (226), menu bar 95 % +233-252 (250), wallpaper 50 % +133 (Mac .33 at +100), 17 of 18 runs the same series, 1 gap run: was judge #4's biggest transition loss. Lost: the appearance switch (below) is out of step in 8 of 8 Settings clicks and steps back in 8 of 8 shell-shortcut switches; part 1's fdb3858 rows were in step. Full-screen enter not re-measured by me (session 15 says the blank title frame is gone: not credited) |
| visual | 90 | **89** | -1 | New faults: Mission Control draws a 25-30 pt band of glass above the Settings thumbnail (light: pale blue, dark: navy, 1.6 too; `07`); Cmd-Tab glass has an unblurred rectangle at the top right where the backdrop shows sharp, a grey (light) / white (dark) ring round the selection where the Mac's is a dark translucent square, label about 14 pt vs 12 (`06`); the 27.2.1 alert layout is now right but its material over a blue wallpaper is a clear blue glass, the Mac's is near-neutral white (`09`). Unchanged: Quick Look panel runs under the Dock; Settings Appearance thumbnails show a photo; Wallpaper pane "Pictures" tiles blank at 3.5 s; Downloads stack light blue in every icon style. Better: Mission Control has the Spaces band and every foot thumbnail its title bar (`mc4` still, 4 windows); Sound module laid out like the Mac's |
| behaviour | 87 | **87** | 0 | Fixed half: `hyprk:appearance-dark` now writes appearance.json, but as `"mode": "light", "dark": true`; Settings (open or started afterwards) stays Light on a dark desktop, 2 of 2 checks (scale 2). Sound module: opens from the output button, Escape returns to Control Center, a click outside closes everything; rows list the host's PipeWire outputs. NC: a notification posted while NC is open appears in one frame (no Mac data). Dock bounce of a running app: one bounce, then down. At 1.6 the focused Settings showed its inactive look in the Mission Control still (at 2 it stayed active) |
| shape | 89 | **89** | 0 | Alert pop width per frame .10 .16 .25 .33 .45 .55 .68 .82 .98 1.15 1.12 … 1.00: peak 1.15 at 167 ms, settled 317 ms (Mac outline peak 1.17 at ~200 ms, settled 370 ms, `LIVE-27.2.1.md`), 4 of 4 the same. Sound module width ~305 pt, rows and 32 pt circles like the Mac JPEG. CC slider tile edge rms .62-.67 px **[fdb3858]**. Not measured: Dock label tail, Dock end cap, HUD and menu corners against Mac crops |
| colour | 93 | **95** | +2 | **[fdb3858]** rows (Finder selection to the level, lights rms 1-8, P3 method) kept: `TrafficLights.qml` changed only to take a bar's own appearance. **[573470c]** spot checks: alert default button dark (0,122,255) = Mac (0,122,255) after conversion; Settings sidebar selection median (0,119,249) vs Mac (0,112,245) (mask includes icons); red light (224,56,62) light and dark. Text highlight colour on screen not measured |
| shadow | 93 | **94** | +1 | **[fdb3858]** rows carried: `plugin/src` shadow code and the Glass shadow are unchanged since fdb3858 (git diff). Not re-measured on white at 573470c; banner shadow below 6 % vs ~11 % still open |
| refraction | 88 | **90** | +2 | **[fdb3858]** CC over 4 pt stripes and Dock over white / grey carried (plugin glass shaders unchanged; `GlassElement.cpp` 7 lines changed, not re-measured). One point below part 1: the new shared knob lens (`glasslens.frag`) and the lens at rounded ends were not measured over stripes, and Cmd-Tab shows an unblurred patch |
| icon | 87 | **88** | +1 | **[573470c]** Dark / Tinted / Clear apply to the Dock, Cmd-Tab and Apps alike (`08`), Trash follows, special folders have glyphs; Downloads stack stays light blue in every style. `check-styles.py` numbers **[fdb3858]**. Tagged folders and SF Symbols not measured pixel-wise |
| font | 95 | **95** | 0 | **[573470c]** menu bar dark, Apple mark + 7 titles start at x 41 108 230 312 400 496 572 708 px vs Mac 42 109 231 313 399 498 572 710, widths within 1 px |
| rendering | 88 | **88** | 0 | Genie ghost lines gone **[fdb3858]**. New: the Mission Control band and the Cmd-Tab patch above; gap runs return after ~45 captures in one session (CC open 0 at start, 3 of 4 runs at 45-51): the Hyprland 0.57.2 screencopy session leak, a fault of the stack (patch at `hypr-dev/patches/hyprland-0.57.2-screencopy-session-leak.patch`, not installed) |
| sound | 84 | **84** | 0 | No sound file or `sound.sh` change since fdb3858 (git diff empty); part 1's log check stands. Alert-volume rule still needs the Mac |

**Colour and the P3 correction.** Of +2 against judge #4, the method moves the old baseline down by about 1.5 (judge
#4's tree read with converted Mac values is about 91-92) and the code (converted constants, wallpaper import) moves it
up by about 3.5. So the P3 correction is not a gain: the gain is code, measured with the corrected method.

## Per surface

| surface | weight | j4 | j5 | main reason |
|---|---|---|---|---|
| Menu bar + menus | 15 | 92 | 92 | Titles within 1-2 px; menus look like `pulldown-*`. Peek not re-measured |
| Dock | 14 | 89 | 90 | Bounce matches (below), styles in Dock; Downloads stack unstyled |
| Window chrome | 14 | 87 | 88 | Genie fixed (part 1); full-screen not re-measured |
| Finder | 13 | 88 | 88 | Icon / list / column / gallery views on screen; QL shows the PDF page but runs under the Dock |
| System Settings | 10 | 91 | 90 | Stays light when the shortcut switches; Wallpaper tiles late |
| Control Center | 6 | 92 | 93 | Open / close rms .002-.018; Sound module added |
| NC + banners | 6 | 89 | 89 | Widgets like `nc/widgets-*`; push in one frame (no Mac data) |
| Spotlight | 6 | 86 | 86 | Not re-measured |
| Mission Control | 4 | 85 | 86 | 1 window within a frame; band over the Settings thumbnail; 4 windows exit fast |
| Sounds | 4 | 84 | 84 | Unchanged |
| HUD | 3 | 85 | 87 | Appear .009-.026; dismiss front-loaded + end snap |
| Cmd-Tab | 3 | 89 | 84 | Unblurred patch, ring, label size |
| Apps | 2 | 84 | 86 | Styles applied; layout like `apps-light.png` |
| Lock screen | 5 | 88 | 91 | Unlock per region matches; lock-in Dock 150 vs 117 |

## Motion rows

### Re-measured at 573470c, scale 2, light (fresh sessions A / B)

| row | captures before | runs | 2-98 % ms (Mac) | rms / time rms | gap runs | same | Mac reference |
|---|---|---|---|---|---|---|---|
| Mission Control enter, 1 Settings window | 0 | 6 | 333-335 (333) | .009-.011 / 5.2-6.1 ms; run 1 lost a value (.039) | 0 | 5 | R2 enter |
| Mission Control exit, same | 1 | 6 | 266-269 (267) | .007-.010 / 4.5-5.1; run 4 lost a value (.014) | 0 | 5 | R2 exit |
| Mission Control enter, Settings + 3 stacked foot | 13 | 5 | 335-353 (333) | .034-.036 / 19-23 (slow start .04 .08 .13 vs .05 .15 .25) | 1 | 4 | R2 enter |
| Mission Control exit, same | 14 | 5 | 200-217 (267) | .085-.093 / 37-46 (.26 .54 .70 in 3 frames) | 0 | 4 | R2 exit |
| HUD appear (`hud volume`) | 23 | 6 | 515-536 (483 fit, 467 track) | .024-.026 / 14-16 | 0 | 3 + 3 (one lost value) | hud-appear-fit ep. 0 |
| HUD dismiss (`hud hide`) | 24 | 6 | 246-284; .17 .33 .45 .55 … .92, then 1.00 (end snap .06-.08) | Mac tracks ep. 2 .02 .09 .18 .27: ours ahead ~3 frames | 0 | 6 | hud-appear-fit tracks |
| Alert show (width of the changed area) | 35 | 4 | peak 1.15 at 167 ms, 1.00 at 317 | Mac peak ~1.17 at ~200, settled 370 | 0 | 4 | LIVE-27.2.1 |
| Alert dismiss | 36 | 4 | 83-87 (~100) | .72 .48 .28 .13 0 | 0 | 4 | LIVE-27.2.1 |
| Control Center open (spot check of part 1) | 43 | 4 | 211-233 (233) | .002-.018 / 1-10 | **3** | 1 | spring 0.25 critical |
| Control Center close | 44 | 4 | 232-241 (233) | .009-.026 / 4-9 | **4** | 2 | same |
| Sound module open (output button) | B 0 | 4 | 362-370 | no Mac track | 0 | 4 | **needs the Mac** |
| Sound module close (Escape, back to CC) | B 1 | 4 | 367-374 | no Mac track | 0 | 4 | **needs the Mac** |
| Slider knob press, Settings > Appearance | B 8 | 4 | 116-118 (Mac curve 144) | .009-.016 / 2.0-2.4 | 0 | 4 | layer-sample series .061 .219 .405 … |
| Slider knob release | B 9 | 4 | 117-119 (one run 98, lost value) | .017-.018 / 1.0-1.1 | 0 | 3 | same |
| Appearance switch, Settings click | B 16 | 8 | 400-403 (one 434) | window pane in one curve; **bar, Dock, wallpaper out of step for 4-6 frames in 8 of 8** (spread .19-.99; wallpaper snaps to .90 in 2 frames in 1, overshoots to 1.04 and steps back to .63 in 1), then all join the window's curve | 0 | - | AppKit cross-fade 0.5 s, held until apps answer |
| Appearance switch, shell shortcut `hyprk:appearance-*` | B 24 | 8 | 368-387 | shell layers rise .13 .21 .30 .40 then **step back** to .37 (8 of 8); Settings pane does not change at all | 0 | 8 | same |
| Dock bounce (`dock bounce org.hyprk.Settings`) | B 33 | 1 | one bounce 686 ms, 18 pt; phase .07 → .33, .12 → .50, .21 → .72, .31 → .89, top held ~130 ms | Mac 700 ms, shape .30 .43 .69 .90, top held ~140 ms | 0 | - | R2 launch bounce |
| NC push (notification while NC is open) | B 36 | 3 | in one frame | - | 0 | 2 (3rd stacked) | **needs the Mac** |
| Quick Look open (Space on a PDF) | B 39 | 4 | 167 (one run ended .95) | .04 .23 .41 .59 .71 .80 .85 .89 .93 .96 .99 | 0 | 3 | **needs the Mac** |
| Quick Look close | B 40 | 4 | 115-135 | a repeated value in 3 of 4 (.84 .84 / .87 .87 / .14 .14) | 0 | 1 | - |

### Lock screen (fresh session C with the PAM test double, scale 2, light)

| row | runs | ours | Mac | notes |
|---|---|---|---|---|
| Unlock, zero = first frame the clock fades ≥ 6 % | 20 (18 valid; 2 captures missed the unlock: harness timing) | menu bar 20 % +132-135, 95 % +233-252; clock 95 % +216-219; Dock 95 % +216-219; wallpaper 50 % +133 | bar +137 / +250, clock ~+219, Dock +226, wallpaper .33 at +100 | 17 of 18 the same series; 1 gap run (a 160 ms stall before the fade); the lock's status items vanish in one frame at zero (.11 of the bar region) |
| Lock-in | 3 | bar .10 .25 .57 .78 .89 .91 .92 .93 (95 % +133 with the status items' tail), Dock 95 % +150, clock +183, field +200 | bar 67, Dock 117 | 3 of 3 the same, 0 gaps |
| Shake (wrong password) | 3 | 0 -11.5 -13.5 -8.5 2 11.5 14 8 -2.5 -11 -13.5 -8 1 6.5 8 5 -1.5 -6.5 -8 (…) 1 5.5 6.5 4 0, 384 ms | 1st attempt 0 -13.5 -13.5 -6.5 4.5 12.5 13.5 6.5 … 400 ms, A 14 / 8.25 / 6.75 | same shape and amplitudes; **one frame lost in 3 of 3** (Qt timer) |

### Dark, scale 2 (session C after the lock rows, 26-48 captures)

| row | runs | 2-98 % ms (Mac) | rms / time rms | gap runs |
|---|---|---|---|---|
| Mission Control enter, 1 Settings window | 4 | 333-336 in 2; one plateau at .44 for 10 frames (600 ms); one lost value | .017 (clean runs) / 11 | 0 |
| Mission Control exit | 4 | 186-233 (267) | .016-.042 / 7-23 | 0 |
| Control Center open / close | 4 / 4 | 213-250 / 233-247 (233) | .005-.016 / .003-.007 | 4 / 3 (leak range) |
| HUD appear / dismiss | 3 / 3 | 481-503 (483) / 197-250, end snap .08-.10 | .018-.020 / 11-12 | 0 |

### Scale 1.6, dark (fresh session D)

| row | runs | 2-98 % ms (Mac) | rms / time rms | gap runs | part 1 at 1.6 |
|---|---|---|---|---|---|
| Mission Control enter, 1 Settings window | 4 | 384 (333) | .034-.035 / 12 | 0 | .061-.100 with a .39 hold |
| Mission Control exit | 4 | 300-318 (267) | .055-.058 / 21-23 | 0 | .109-.114, plateau .93 |
| Control Center open / close | 4 / 4 | 216-236 / 232-244 (233) | .001-.024 / .001-.021 | 1 / 2 | .010-.033 |
| HUD appear | 3 | 481-484 (483) | **.009-.011 / 6** | 0 | .019 / 11 |
| HUD dismiss | 3 | 216-250, end snap .06-.08 in 2 of 3 | - | 0 | 333-350 |

### Carried from part 1 [fdb3858], not re-measured

Spotlight open / close, NC open / close, banner in / out (banner out lost a value in 4 of 6 at 2x, 7 of 8 at 1.6),
menu fade, Dock label fade, full screen enter / exit (enter: menu bar titles blank one frame, 4 of 4), genie
minimize / restore (no ghost lines), window close, Cmd-Tab show / dismiss, zoom / unzoom, Dock magnification, bar peek.
Rows at fdb3858 above 100 captures (Mission Control A, appearance A, zoom, magnification, lock-in) are superseded by
the fresh rows above where a fresh row exists.

## Dist setup (session E against smoke session F, scale 2, light)

`hyprk_env_setup DIR private light`, `HYPRK_NESTED=1 HYPRK_SCALE_POLICY=off HYPRLAND_NO_SD_VARS=1
XDG_CURRENT_DESKTOP=Hyprland HYPRK_CONFIG=dist/hyprk-dist.lua`, through smoke.sh: menu bar, Dock and the whole output
**pixel-identical** to the smoke session (rms 0.00, max 1 level, the clock). Part 1's other dist differences (output
rule, extra binds, foot padding) not re-checked.

## Side-by-side pass, every main surface (largest visible difference first)

1. **Cmd-Tab** (`06`): an unblurred rectangle in the top-right of the glass (backdrop sharp), 4 of 4 shots in all icon
   styles; selection is a grey (light) / white (dark) ring, the Mac's is a dark translucent rounded square; label
   about 14 pt bold vs 12 pt; panel milky grey in light where the Mac's is clear glass.
2. **Mission Control** (`07`): a 25-30 pt band of glass above the Settings thumbnail at 2 and 1.6, light and dark.
   Windows in a grid when 4 overlap (Mac keeps scale 1 when they fit, Q-dock-28). Band and pill present now.
3. **Appearance switch**: shell layers out of step with the window for 4-6 frames (Settings click) or stepping back
   (shortcut); after the shortcut Settings stays Light on a dark desktop.
4. **Alert** (`09`): layout now the Mac's (icon, left-aligned text, 110 x 28 capsules); material is a clear, blue-tinted
   glass over the wallpaper where the Mac's 27.2.1 alert is near-white.
5. **Quick Look**: PDF page shown, but the panel reaches under the Dock and its bar is a mid-grey.
6. **HUD**: look matches `hud-vol-light.png`; dismiss front-loaded with an end snap.
7. **Settings**: Appearance thumbnails are a photo (Mac: the wallpaper); Wallpaper pane "Pictures" blank at 3.5 s;
   Sound pane and Sound module list the host's outputs; Displays virtual (no laptop picture).
8. **Control Center + Sound module** (user JPEGs): tiles, rows, slider knob and Edit Controls in the Mac's places.
   Selected output shows a speaker glyph in the white circle, the Mac shows the device type (laptop).
9. **Dock**: Downloads stack stays light blue in Dark / Tinted / Clear (Mac Dark: dark folder).
10. **Notification Center**: widgets (calendar, clock, photo, Edit Widgets) and grouped stack like `nc/widgets-*`.
11. **Lock screen**: clock, date, avatar, field and status items in the Mac's places; not compared pixel-wise
    (user's initials; no crop saved).
12. **Menu bar + menus, Finder views, Spotlight, Apps, desktop**: no visible difference at a glance; menu bar text
    within 1-2 px.

## Ranked gaps (cost = weight x points lost; gain in overall points)

| # | gap | surface / dim | fix with repo data? | est. gain |
|---|---|---|---|---|
| 1 | Shell layers out of step / stepping back during the appearance switch | all / transition, rendering | yes: the plugin holds a snapshot; the shell must not draw into the hold (64e0b28 / a9e060c are the suspects; part 1 had them in step) | +0.4 |
| 2 | Shortcut writes `mode: light, dark: true`; Settings and apps do not follow | Settings / behaviour | yes (`hyprland.lua` appearance writer, Settings reads `mode`) | +0.3 |
| 3 | Mission Control band of glass above the Settings thumbnail | MC / visual, rendering | yes (thumbnail vs glass region offset; likely the 52 pt scroll-edge pocket of 059f054 drawn at window coords) | +0.25 |
| 4 | Cmd-Tab unblurred patch, ring, label size | Cmd-Tab / visual, rendering | yes: `dock/cmdtab-*.png` | +0.2 |
| 5 | Mission Control with 4 windows exits in 200-217 ms; 1.6 enter 384, exit 300-318 | MC / animation | yes: R2, `mission-control.json` | +0.15 |
| 6 | HUD dismiss front-loaded and a 6-10 % end snap | HUD / animation | yes: hud-appear-fit tracks (end of curve needs the Mac) | +0.1 |
| 7 | Alert material blue clear glass vs neutral | windows / visual, colour | yes: `panels/alert-*.png`, `live/alert-*.json` | +0.15 |
| 8 | Quick Look panel under the Dock, grey bar | Finder / visual | partly: needs a Mac QL of a PDF | +0.15 |
| 9 | Downloads stack never styled | Dock / icon | partly: `dock/dock-dark.png` | +0.1 |
| 10 | Lock-in Dock +150 vs 117, status items step on unlock | lock / transition | yes: LOCKSCREEN B3 | +0.05 |
| 11 | Frame loss on Qt-timer motions (shake 3/3, QL close 3/4, banner out) | all / animation | yes: move them to the frame clock like the knob | +0.15 |
| 12 | Settings Appearance thumbnails photo; Wallpaper tiles late | Settings / visual | yes: Mac Settings shots | +0.1 |
| 13 | Screencopy session leak (gaps after ~45 captures) | stack / rendering | stack: install the hypr-dev patch | measurement only |
| 14 | Full-screen enter blank title frame (part 1) | windows / transition | re-measure; dev says fixed | +0.1 if confirmed |
| 15 | Sound module device glyph, module open / close curve | CC / visual, animation | needs the Mac curve | +0.05 |

## The 15 changes that would raise the score most

1. Keep the shell out of the appearance hold so bar, Dock and wallpaper fade in one curve with the window (+0.4).
2. Make every appearance path write `mode` and `dark` together so Settings, Finder and GTK follow the shortcut (+0.3).
3. Remove the glass band above window thumbnails in Mission Control (+0.25).
4. Fix the Cmd-Tab glass region (no sharp patch), the dark selection square and a 12 pt label (+0.2).
5. Use R2's exit curve for multi-window Mission Control and remove the slow tail at 1.6 (+0.15).
6. Put the Qt-timer motions (shake, Quick Look, banner list, RubberBand) on the frame clock (+0.15).
7. Give the alert the Mac's neutral material (+0.15).
8. Keep the Quick Look panel above the Dock and use the Mac's bar colour (+0.15).
9. Follow the Mac's HUD dismiss tracks from frame 1 and end it without a snap (+0.1).
10. Style the Downloads stack per icon style (+0.1).
11. Show the wallpaper in the Settings Appearance thumbnails and preload the Wallpaper pane tiles (+0.1).
12. Re-check and, if still there, fix the full-screen enter title frame (+0.1).
13. Lock-in Dock timing (+117 ms) and fading the lock status items on unlock (+0.05).
14. Install the screencopy-leak patch on dev machines so long test runs stay valid (measurement quality).
15. Device-type glyphs in the Sound module rows (+0.05).

Together about +2.2, so about 91 if all land.

## Needs the Mac (exact captures)

- Control Center Sound module open and close at 60 fps over grey 127 (per-frame alpha of the module).
- A notification arriving while Notification Center is open (60 fps strip).
- Quick Look of a PDF: still + open series (unchanged from judge #4).
- HUD dismiss to the end (the existing tracks stop at 80-85 %).
- Mac Dock in Clear / Tinted with Trash and the Downloads stack.
- Unlock per region at 60 fps over grey 127 (B3 is one run with dropped frames; ours now matches it).
- Whether the alert volume scales the screenshot, trash and mount sounds.
- Mission Control with 4 overlapping 700 x 500 windows (frames + still).

## Reachable ceiling on this stack: about 92

Evidence: the rows that are on the frame clock are already within a frame of the Mac (knob .009-.016, Control Center
.002-.008 in clean runs, Mission Control 1 window .009, unlock within 1 frame per region, HUD appear at 1.6 .009).
The gaps listed above are fixable bugs worth about +2.2 together. What stays: frame gaps that come from Hyprland /
Quickshell presentation (gap runs return in long sessions, one value lost per Qt-timer motion), no glass inside client
windows, no trackpad momentum outside hyprk's views, no third-party app menus, zoom stretching a buffer, and no Mac
data for several motions. That keeps animation, transition and rendering at about 90 and the total at about 92.

## Crops (`reference/judge-95-5/`)

- From part 1: `01-fullscreen-strip.png`, `02-traffic-lights-mac-left-ours-right.png`,
  `03-genie-minimize-restore-frames.png`, `04-mission-control-mac-left-ours-right.png`,
  `05-alert-mac-left-ours-right.png` (fdb3858, centred alert), `B-mc-enter-inactive-flash-1.6.png`,
  `B-dock-dots-1.6-light-top-dark-bottom.png`.
- New: `06-cmdtab-ours-light-dark-mac-right.png`, `07-mc-settings-thumbnail-band-dark.png`,
  `08-icon-styles-dock-cmdtab-apps.png` (Dark / Tinted / Clear), `09-alert-light-mac-left-ours-right.png`.
- No lock-screen, Sound-module (host device names) or user-JPEG crops are saved.
