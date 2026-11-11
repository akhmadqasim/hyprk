# hyprk independent judge #3: 95 % goal check (2026-11-11)

- Commit at start and end: **6d48f1f** (67 commits after judge #2's d1d516c). Working tree clean except my outputs.
  `plugin/build/libliquidglass.so` sha256 6154c4baf31f7706…, `plugin-motion/build/libhyprkmotion.so` 05aa53cdabf54c43…, the
  same at start and end. Both builds are newer than the last commit touching their sources (glass .so 13:00:24, last
  `plugin/src` commit 5e9aff0 12:56, newest source file 12:55; motion .so 11:11:12, newest `plugin-motion/src` file 11:11:08,
  commit c65308a 11:12 with the same content). So the glass and motion numbers below come from the current code.
- Ground truth: `reference/screens/27.2.1/**` (verify/C2 cc-real-stripes, panels, menubar, dock, settings, lock, nc),
  `reference/re/MAC-ANSWERS.md` (R2 motion series, Spotlight REA, Q-dock), `reference/re/27.2.1/live/**` (verify/A
  hud-appear-fit, verify/C2 cc-real.json, finder/crops), `reference/re/LOCKSCREEN-27.2.1.md` (B1-B3).
- Ours: one headless session, started only with `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (MBA 2560x1664 at 2x),
  with its own `HYPRK_STATE`, `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG` and the lock PAM test double, all in scratch. Muted.
  I drove it with `qs ipc --pid <my qs>`, `hyprctl dispatch` (Lua), `grim`, `mcap`, `fscroll`, a scratch vptr (plus a
  right click) and a scratch copy of `lockscreen/tools/vkbd.c` (plus holding Super and Shift, for Cmd-Tab).
  Backdrops: flat white, grey 127, black, blue 69,83,206, and vertical black/white stripes of **4 pt** (the Mac C2
  pitch, used by REFRACTION.md) and **8 pt** (the second pitch), via `wallpaper.json`. Finder ran on a scratch demo tree.
- **Measured on screen:** 16 motion rows (table below), CC refraction over 4 pt stripes against the Mac crop, glass over
  8 pt stripes (no Mac capture at that pitch), the window shadow, File menu width, Finder context menu, Quick Look,
  Cmd-Tab, Settings Appearance + preview scroll, rubber band in Finder and Settings (finger events), icon styles,
  Dock label tail, lock-in, wrong-password shake, unlock, lock clock ink, NC, Spotlight, Apps.
- **By code (helper subagent, read-only):** sound wiring. I spot-checked `shell/scripts/sound.sh:55-79`,
  `finder/qml/Browser.qml:240-250` and `shell/services/Panels.qml:78-83`. The sound score rests on it.
- Not re-measured (kept from docs or judge #2, scored conservatively): window shadow inactive and dark, Dock bounces and
  magnification, banner motion, Cmd-Tab dismiss, Dock and menu bar motion around full screen, Mission Control with two
  windows at one place, Displays/Wallpaper/Sound panes, the knob lens.
- Same scale as judges #1 and #2. 95+ means a careful observer can't tell it from the Mac. 85-94 means small measurable
  differences. 70-84 is visible at a glance. Below 70 means clearly different.

## Overall: **88** (old 13-surface weights; judge #1 79, judge #2 85) and **88** with the lock screen

- Old weights (menu bar 15, Dock 14, windows 14, Finder 13, Settings 10, CC 6, NC 6, Spotlight 6, MC 4, sounds 4, HUD 3,
  Cmd-Tab 3, Apps 2): 88.2.
- Lock screen at weight 5, others x0.95: 88.2 → **88**.
- Plain mean of the 12 dimensions: 88.0.

## Per dimension

| dimension | judge 1 | judge 2 | judge 3 | evidence (ours vs Mac, measured unless marked) |
|---|---|---|---|---|
| animation | 69 | 80 | 86 | Close 2-98 % 133-134 vs 133 ms. Zoom / unzoom / full screen enter on a real Finder window (edge progress) rms 0.003-0.008 / 2-3 ms. NC open 0.016 / 5 ms. CC open 0.015-0.029, no repeated 2nd frame in 3 runs. Shake peaks -13/+14/-13/+8/-8/+7 pt, rms 1.3 pt vs the Mac's first attempt. Rubber band 21 pt after a 300 pt finger pull in Finder and Settings. Off: Mission Control exit 368 vs 267 ms with a repeated first frame and a 6-frame 0.94 plateau. HUD appear has a 0.57 → 0.76 one-frame jump (5 of 5). HUD dismiss ends in a 4-12 % snap. Quick Look shows its first frame 3 times |
| transition | 76 | 80 | 86 | Full screen exit follows the decoded (0.25,0,0,1) 0.5 s curve at rms 0.004-0.006 (2-98 % 367 vs 383 ms). Unzoom has no smear (frames checked). Lock-in about 235 ms from the first change, like the Mac, after a 2-frame near-still start. Unlock is too fast: about 150 ms main fade vs about 270 ms, and the menu bar returns with the clock (Mac: 165 ms from +111). Spotlight open has no content blur (REA 25 → 0) |
| visual | 84 | 87 | 89 | CC tiles over 4 pt stripes match the Mac crop by eye (`01`). File menu 272 pt like the Mac, Print has its icon. Context menu is glass (`02`). Quick Look is its own window with the Mac title bar. Settings Appearance is close to the Mac. Spotlight bar: no soft shadow below (Mac 127 → 96) and a flatter field than the Mac's lighter bottom. The Apps panel corner is rounder |
| behaviour | 68 | 80 | 85 | Cmd-Tab: hold, Tab, release commits, and the windows keep their coloured lights. Rubber band works with finger events. Quick Look opens a window. The Liquid Glass preview scrolls under its glass buttons. Left: the folder context menu has Open and a tag row where the Mac has Ask Siri, Open in New Tab, Paste Item and Customise Folder. Finder's app menu greys out Settings… and Hide Finder. Every dialog beeps (no Mac evidence) |
| shape | 78 | 88 | 89 | Menu width 272 pt (Mac 272). Window corner kept. Dock label tail base about 12 pt (24 px at its join), height 6.5 pt, vs Mac 16 x 6.5. Apps panel radius larger than the Mac's |
| colour | 92 | 92 | 92 | Lock clock ink over grey 114: +90/+79/+90 (Mac +89/+80/+88). Lock date only +76..+79 (Mac: stronger than the clock, +127 on R and G in dark). CC flats as in REFRACTION.md (not re-measured) |
| shadow | 76 | 84 | 89 | Light, active, white backdrop: side 2/8/16 pt .18/.14/.09 (Mac .18/.14/.09), below 2/8/16/32 .33/.29/.20/.08 (Mac .32/.28/.22/.09), above .06/.05/.03/.01 (Mac .06/.04/.02/0). Inactive and dark taken from SHADOW.md (dark inactive rms .047, inactive tail too long). No shadow under the Spotlight bar |
| refraction | 78 | 66 | 88 | Over 4 pt stripes, dark, aligned with the Mac crop: Display tile peak to peak 8 / 8 levels at 8 / 15 pt below its top (Mac 8 / 8), Sound tile the same, gap 31 (Mac 32), means 109.0 vs 109.3 and 114.4 vs 115.0. The rounded end ripples ±4-6 levels (Mac ±3-4). Over 8 pt stripes the Dock and HUD show concentric lens bands (`04`), but there is no Mac capture at that pitch. Spotlight field is not Apple's Regular recipe (REFRACTION.md) |
| icon | 74 | 85 | 86 | Dark style matches the Mac Dock's look for Finder, Settings and TextEdit (`03`). Clear and Tinted are flat tints with no specular edge. There are no Mac Dock shots in those styles, so they are unverified. Plain-text files still show a blank page in the Finder |
| font | 95 | 95 | 95 | Menus, Settings and the lock clock look like the Mac side by side. No new font measurement |
| rendering | 89 | 90 | 91 | The Qt unzoom corner smear is gone (expand_undersized_textures off, frames checked). Text AA unchanged |
| sound | 72 | 74 | 80 | Code, via the subagent (spot-checked). Move to Trash now plays dock/drag to trash (ID 16, `sound.sh:63`, `Browser.qml:243`). Finder Empty Trash plays finder/empty trash (`Browser.qml:249`). Files played are the 27.2.1 originals (AIFF/CAF). Left: alert volume scales every event (rule not backed by a file under `reference/`). Every dialog beeps (`Panels.qml:82`, Mac unmeasured). Volume Mount plays after every Finder copy/move. Poof has no caller (Remove from Dock disabled). `packaging/install.sh:42` drops the originals, so an install plays Vorbis |

## Per surface

| surface | weight | judge 1 | judge 2 | judge 3 | evidence |
|---|---|---|---|---|---|
| Menu bar + menus | 15 | 83 | 90 | 92 | File menu 272 pt, rows, disabled states and Print icon like `menubar/pulldown-light.png`. Shortcut glyph spacing looks like the Mac's at 1x. App menu disables Settings… and Hide |
| Dock | 14 | 85 | 89 | 90 | Label with tail (measured: 12 vs 16 pt base). Dark icon style close to `dock/dock-dark.png`. Lens bands at the ends over stripes. Bounces and magnification taken from MOTION-MEASURED (not re-measured) |
| Window chrome | 14 | 65 | 85 | 89 | Light active shadow matches at 11 of 12 points within .02. Zoom, unzoom and full screen enter match on a real Qt window. Close matches in duration. The first-frame value depends on frame phase (0.16 in 2 of 3 runs vs Mac 0.29) |
| Finder | 13 | 76 | 82 | 86 | Glass context menu (`02`), Quick Look window, rubber band 21 pt. Context menu contents differ, text-file icon blank, Quick Look first frame held 3 frames |
| System Settings | 10 | 86 | 89 | 90 | Appearance close to `settings/appearance-light.png`. The preview scrolls under the glass buttons. Rubber band 21 pt. Displays, Wallpaper and Sound panes and the knob lens not checked |
| Control Center | 6 | 82 | 84 | 92 | `01`: interior ripple, gap blur and lens bands match the Mac crop within 1-2 levels. Open 236-253 ms vs REA spring 233, no repeated frame |
| Notification Center + banners | 6 | 85 | 87 | 87 | Open 0.016 / 5 ms. Calendar widget like the Mac, but the week starts Monday (Mac crop: Sunday). Hint-less test banner silent, as on the Mac |
| Spotlight | 6 | 78 | 85 | 84 | Open fades over about 100 ms (REA alpha spring, ok) with the scale, but without the content blur. No shadow under the bar. Field flatter than the Mac's |
| Mission Control | 4 | 80 | 84 | 82 | Enter 2-98 % 333 ms (Mac 333), rms 0.021-0.026, with 2-3 repeated frames. Exit 368 ms vs 267, rms 0.032-0.061 / 15-22 ms |
| Sounds | 4 | 72 | 74 | 80 | See the dimension row |
| HUD | 3 | 92 | 86 | 85 | Appear has a 19 % single-frame jump at about 400 ms in every run, rms 0.040-0.045 / 25-32 ms. Dismiss 2-98 % 202-283 ms vs 267 model, ends in a snap. Lens shape close to `hud-vol-light.png` |
| Cmd-Tab | 3 | 75 | 76 | 88 | Release commits. Dark selection tile and the label under it, like `dock/cmdtab-light.png`. Windows stay active |
| Apps | 2 | 78 | 83 | 84 | Category bar and grid like `dock/apps-light.png`. Panel corner rounder |
| Lock screen | 5 | – | 86 | 88 | Clock ink exact. Shake matches (1.3 pt rms). Lock-in about 235 ms. Unlock too fast and the menu bar is not delayed. Date ink weaker. PAM delay not judgeable with the test double (shake starts 97 ms after Return, Mac 2.1 s) |

## Motion re-measured (mcap, my session) vs MOTION-MEASURED.md / MOTION-PLUGIN.md

| row | doc | mine | agree? |
|---|---|---|---|
| Window close (foot) | matches, 0.010 / 0.8 ms | 133-134 ms (Mac 133), rms 0.013 / 1.5 ms in 1 run, 0.034-0.040 / 3.5 ms in 2 runs (first frame 0.11-0.16 vs Mac 0.29) | duration yes, value rms worse in 2 of 3 |
| Zoom, real Finder (edge progress) | 0.006-0.009 | 0.007 / 2.3 ms, 268 ms | yes |
| Unzoom, real Finder | 0.005-0.007 | 0.008 / 2.3 ms, 268 ms. Mid frames stretched, no smear | yes |
| Full screen enter | 0.007-0.008, 350 ms | 0.003-0.004 / 2.5 ms, 350-352 ms | yes |
| Full screen exit vs decoded curve | 0.014 / 7.8 ms | 0.004-0.006 / 1.6-1.9 ms, 367-368 ms (curve 383) | yes |
| Full screen exit vs R2 two-step anchors | 0.25 | 0.24 / 158 ms | yes (both say it does not follow R2) |
| Mission Control enter | 352 ms, 0.024 | 333 ms (Mac 333), 0.021-0.026 / 9-14 ms. Repeats: 0.23 0.23, 0.89 0.89, 0.96 x3 | partly (repeats not in the doc) |
| Mission Control exit, 1 window | 282-285 ms, 0.011 / 4.6-8.5 ms | **368 ms** (Mac 267), 0.032-0.061 / 15-22 ms. First frame 0.07 repeated, then a 0.94 plateau for about 6 frames | **no** |
| Control Center open | 233-251 ms, 0 repeats in session 6 | 236-253 ms, 0.015-0.029 / 6-12 ms, 0 exact repeats in 3 runs (one 0.11 → 0.15 small step) | yes |
| HUD appear | 0.020-0.033 / 17-25 ms, monotonic | 480-502 ms, **0.040-0.045 / 25-32 ms**. The same 0.57 → 0.76 jump in every run (5 of 5) | **no**: monotonic but with a 19 % step |
| HUD dismiss | 317-350 ms, "last 5 % lingers" | 202-283 ms vs model 267. The last 4-12 % goes in one frame | **no**: the tail is now a snap, not a linger |
| NC open | 0.006-0.016 | 0.016 / 5 ms, 267-286 ms | yes |
| Spotlight open | "first visible 1.096", fixed | first faint frame 45-49 ms. Alpha 0.03 → 1 over about 100 ms (REA alpha spring 0.28). Width 532 → 517 pt (1.03 at the first readable frame). No blur 25 → 0 | open blur still missing (known open) |
| Quick Look open | 1 repeated frame | first frame 0.67 held 3 frames (96-129 ms), then .85 .91 .95 .97 .98 .99 | **no**: 2 extra frames |
| Lock-in | (judge 2: about 200 ms) | 2 near-still frames (0.005), then 0.10 → 0.99 by +280 ms. About 235 ms from the first change (Mac 235) | – |
| Lock shake | (judge 2: 3.2 pt rms) | 22 frames, peaks -13/+14/-13/+8/-8/+7 pt, 7.5 Hz. rms 1.3 pt vs Mac 1st attempt, 2.6 pt vs 2nd | – |
| Unlock | (judge 2: menu bar 70 ms) | status items at +98 ms, hold to about +250, main fade about 300 → 447 ms. Menu bar 0.19 → 0.95 over about 120 ms with the clock | – |
| Rubber band, Finder + Settings (fscroll) | 21 pt at a 300 pt pull | 21 pt in both (42 px), held while the fingers rest, back to 0 after lift | yes (judge 2's 0 px was the wheel path) |

**Full screen exit, which is right.** I score against the decoded curve. The REA (MOTION-PLUGIN.md) traces one
duration source (the Dock's 0.5 s reply) and one frame curve (0.25,0,0,1) for enter and exit. It finds no hold in AppKit
or the Dock. The same curve reproduces the R2 enter series within 1-2 frames, which supports the decode. The R2 "two
steps" came from a whole-screen share-of-change metric. On exit that metric mixes the cosine Space slide, a cross-fade
over the first half, and the window frame. The menu bar also starts its own 0.5 s animation. A plateau in such a mix
is plausible without any hold in the code. Ours fits the decoded curve at rms 0.004-0.006 and the R2 anchors at 0.24.
If the Mac really holds, transition loses about 2 points. Only a per-frame Mac recording settles it.

## Ranked gap list (weight x points lost)

The estimated gain is in overall points.

| # | surface | dim | ours vs Mac | owner | Apple data for the fix | est. gain |
|---|---|---|---|---|---|---|
| 1 | Finder | behaviour, visual, icon | Folder context menu: Open + tag row vs Mac Ask Siri header, Open in New Tab, Paste Item, Customise Folder. App menu greys out Settings… and Hide Finder. Plain-text files show a blank page. Quick Look first frame held 3 frames | `finder/qml/PopupMenu.qml`, `finder/qml/Browser.qml`, `finder/qml/lib/icons.js`, `finder/qml/QuickLook.qml`, `shell/modules/MenuDropdown.qml` | yes: `live/finder/crops/context-menu-*.png`, `screens/27.2.1/finder/list-light.png`, Q-finder-26 series | +0.6 |
| 2 | Spotlight | transition, visual, shadow | No content blur 25 → 0 on open. No soft shadow under the bar (Mac 127 → 96 at the edge). The field is flatter and darker at the bottom than the Mac's | `shell/modules/Spotlight.qml`, `plugin/` (recipe) | yes: MAC-ANSWERS Spotlight REA (blurRadius 25, Spring 0.51), `panels/spotlight-empty-*.png`, `verify/B/spotlight-field-over-6px-stripes-dark.png` | +0.4 |
| 3 | Dock / all app icons | icon | Clear and Tinted are flat tints with no specular edge. In Dark style the Downloads stack and Trash stay in full colour | `themes/icons/`, `shell/services/Apps.qml` (iconUrl / styled) | partly: `settings/appearance-iconstyle-tinted-light.png`, `settings/desktop-dock-*-icon*.png`. No Mac Dock in Clear/Tinted | +0.4 |
| 4 | Mission Control | animation | Exit 368 vs 267 ms, first frame repeated, a 0.94 plateau for 6 frames, rms 0.032-0.061. Enter has 2-3 repeated frames | `shell/modules/MissionControl.qml` | yes: R2 exit series (MAC-ANSWERS:140) | +0.3 |
| 5 | Sounds | sound | Alert volume scales every event (rule not in `reference/`). Every dialog beeps. Volume Mount after every copy/move. Poof has no caller. Installs ship Vorbis only | `shell/scripts/sound.sh:76`, `shell/services/Panels.qml:82`, `finder/src/fileops.cpp:297,516`, `packaging/install.sh:42` | partial: `re/27.2.1/decomp/systemsoundserverd-ids.txt`, MAC-ANSWERS:3711-3715 (NSAlert not measured) | +0.3 |
| 6 | Lock screen | transition, colour | Unlock main fade about 150 ms vs about 270. Menu bar back with the clock, the Mac waits +111 ms and takes 165 ms. 2 near-still frames at the start of lock-in. Date ink +77 vs the Mac's stronger lift | `shell/modules/lock/Lock.qml`, `LockOverlay.qml`, `lock.js`, `LockTheme.qml` | yes: `re/LOCKSCREEN-27.2.1.md` A2, B1, B3 | +0.25 |
| 7 | Window chrome | shadow | Inactive shadow tail too long (Hyprland has one range). Dark inactive rms .047 (SHADOW.md, not re-measured). Sides near the corners | `config/hypr/hyprland.lua` (shadow block), `plugin/` | yes: Q-windows-01, AppKit shadowParameters | +0.25 |
| 8 | HUD | animation | Appear: a 0.57 → 0.76 jump in one frame at about 400 ms, every run, rms 0.040-0.045. Dismiss ends with a 4-12 % snap | `plugin/src/Shape.cpp` (marker holes), `shell/modules/HudWindow.qml` | yes: `live/verify/A/hud-appear-fit.json`, REA dismiss spring | +0.15 |
| 9 | Settings | visual, behaviour | Toolbar back/forward capsule lighter than the Mac's. Energy vs Battery. Displays, Wallpaper and Sound panes and the knob lens not judged here | `settings/` | yes: `screens/27.2.1/settings/` | +0.15 |
| 10 | Dock | shape | Label tail base 12 pt vs 16 | `shell/modules/Dock.qml`, `plugin/src/Shape.cpp` | yes: MAC-ANSWERS:1524 | +0.1 |
| 11 | Window chrome | animation | Close: the first fade frame is 0.11-0.16 in 2 of 3 runs vs the Mac's 0.29 (rms 0.034-0.040). The duration matches | `config/hypr/hyprland.lua` (fadeOut) | yes: R2 close series | +0.1 |
| 12 | Full screen | transition | Dock and menu bar motion around full screen not re-measured. The full-screen window covers the menu bar strip (Mac notch: black 34 pt strip) | `shell/modules/Dock.qml`, `plugin-motion/` | partial: MOTION-PLUGIN.md REA, Q-menubar-33 | +0.1 |
| 13 | NC | visual | Calendar week starts Monday. The Mac crop starts Sunday (locale-dependent) | `shell/modules/` (calendar widget) | yes: `screens/27.2.1/nc/widgets-*.png` | +0.05 |
| 14 | Apps | shape | Panel corner rounder than the Mac's | `shell/services/AppsView.qml`, `shell/modules/Spotlight.qml` | yes: `dock/apps-*.png` | +0.05 |
| 15 | CC | refraction | Rounded-end ripple ±4-6 levels vs Mac ±3-4. Everything else matches within 1 level | `plugin/` | yes: `verify/C2/cc-real-stripes-*.png` | +0.05 |

## Cannot reach on this stack

- **Trackpad momentum and rubber band outside hyprk's own Qt views.** Wayland has no momentum events. GTK, Electron and
  browsers keep their own scrolling.
- **Third-party app menus in the global bar.** GTK4 and most Wayland apps export no menu model.
- **Glass inside client windows.** Qt toolbars in Finder and Settings can't sample the desktop behind the window.
- **Live relayout during zoom.** Hyprland stretches or crops a buffer while AppKit relayouts every frame. The frame
  curves now match, but growing windows still reveal the new layout from the top-left.
- **Repeated frames when a layer maps.** Hyprland answers a new layer's first frame callback at once, and Qt's threaded
  loop syncs the first animated state twice (MOTION-MEASURED session 6). Mission Control and Quick Look repeats likely
  share this.
- **Spotlight open blur.** It was tried twice and drops frames on this stack (MOTION-MEASURED).
- **PAM failure delay, Touch ID, Siri, AirPlay targets, Apple Park art.** System or Apple-service features.

## Needs the Mac online

- A per-frame 60 fps recording of a full screen exit (decoded curve vs R2 "two steps").
- Mac Dock and app icons in the Clear and Tinted styles (only Settings pane icons exist).
- A HUD dismiss track and a Mac HUD over stripes.
- Whether an NSAlert beeps, and whether alert volume scales UI sounds, the volume pop and the power chime.
- What darkens the real Spotlight field on top of the Regular glass. The CC panel blur kernel (fitted, not decoded).

## Is 95 reachable?

Not on this stack in every dimension. Sound, behaviour and icons depend partly on data that doesn't exist yet or on
features Wayland doesn't offer. Glass refraction went from 66 to 88. CC over stripes is now hard to tell from the Mac.
Most remaining distance is in specific surfaces rather than the core model. A realistic ceiling is about 91-92.
The 5 changes that would move the score most:

1. Finder context menu and app-menu contents, the text-file icon, and the Quick Look first frame (+0.6).
2. Spotlight: the open blur if a cheap path exists, the shadow under the bar, and the field recipe (+0.4).
3. Icon styles with a specular glass pass for Clear and Tinted, plus Dark for stacks and Trash (+0.4, needs Mac shots to verify).
4. Mission Control exit timing and the repeated frames (+0.3).
5. Sound rules: alert volume only on alerts, no beep on confirm dialogs unless proven, and ship the originals (+0.3).

## Not judged / limits

- Crops: `judge-95-3/01` (Mac left, ours right, CC tiles over 4 pt stripes, dark), `02` (folder context menu, Mac left),
  `03` (Mac Dock in Dark style on top, ours in Dark / Clear / Tinted), `04` (ours, Dock and HUD over 8 pt stripes, dark).
- I did not save lock screen, Settings or CC full shots. They showed the account name, initials, or the host's Now
  Playing card (Brave). The CC crop `01` is cut below the Now Playing tile.
- Sounds: nothing played. `HYPRK_SOUND_LOG` stayed empty for a hint-less banner and for the actions I triggered.
