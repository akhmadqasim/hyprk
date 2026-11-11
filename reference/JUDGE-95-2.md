# hyprk independent judge #2: 95 % goal check (2026-11-11)

- Commit at start: **d1d516c** (plugin `libliquidglass.so` sha256 fd004cea0d5f15da…, `libhyprkmotion.so` c5b1e7a13a5a71f6…).
  Commit at end: **78b2429** (`libliquidglass.so` 47c09de1f4c5ea40…, `libhyprkmotion.so` 331613d657e540a3…).
  My nested Hyprland loaded the plugins once, at start, so every on-screen number below is from the **d1d516c plugins**.
  The plugin commits that landed while I judged (80fd49d HUD appear, ff4f9d6 unzoom and full screen) are not on my screen.
  I list them as "in progress at judging time" and do not count them as fixed or as gaps.
  The shell hot-reloads, so shell commits 13d0061 and 9059746 (menu blink, menu open in one frame) may have reached my session late. I did not measure them.
- Ground truth: `reference/screens/27.2.1/**`, `reference/re/MAC-ANSWERS.md`, `reference/re/27.2.1/live/**` (nc/motion.json,
  dock/reconciliation-42.json, verify/A, verify/B2, verify/C2, finder/crops, windows), `reference/re/LOCKSCREEN-27.2.1.md`.
- Ours: one headless session, `HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh` (MBA 2560x1664 at 2x = 1280x832 pt). It had its own
  `HYPRK_STATE`, `XDG_CACHE_HOME`, `HYPRK_SOUND_LOG` and lock PAM test double (`lockscreen/tools/lock-test-env.sh`), all in scratch.
  I drove it with `qs ipc`, `hyprctl dispatch` (Lua), `grim` and `mcap`. Input came from a scratch copy of `scripts/vptr`
  (plus right click, wheel and finger-axis events) and a small zwp_virtual_keyboard client, also in scratch.
  Backdrops: Tahoe Light, solid white / grey 127 / blue (69,83,206), and 8 pt black-and-white stripes via `wallpaper.json`.
  Finder ran on a fake demo tree. Settings, Finder and a GTK app (gnome-text-editor) ran inside the nested session only.
- **Measured on screen:** motion (`mcap`, 13 captures), window corner, menu shadow, Dock fill, traffic-light hover colour,
  lock screen (lock-in, wrong-password shake, unlock), refraction over stripes, and every visual comparison below.
- **By code (helper subagent, code only):** sound wiring. I spot-checked the subagent's claims at `shell/scripts/sound.sh:17-28` and
  `shell/services/Panels.qml:77`. The sound score rests on it.
- Same scale and method as JUDGE-95.md. 95+ means a careful observer can't tell it from the Mac. 85-94 means small measurable differences.
  70-84 is visible at a glance. Below 70 means clearly different. A missing item scores 0.

## Overall: **85** (old 13-surface weights; judge #1: 79) and **85** with the lock screen

- Old weights (menu bar 15, Dock 14, windows 14, Finder 13, Settings 10, CC 6, NC 6, Spotlight 6, MC 4, sounds 4, HUD 3,
  Cmd-Tab 3, Apps 2): the weighted sum is 85.6. I rounded it down.
- With the lock screen at weight 5 (seen at every wake and unlock): the old weights are scaled by 0.95, plus lock 86 x 0.05.
  That gives 85.6 → **85**.
- The plain mean of the 12 dimensions is 83.4. Refraction and sound pull it below the surface-weighted score.

## Per dimension

| dimension | judge 1 | judge 2 | evidence (short, ours vs Mac) |
|---|---|---|---|
| animation | 69 | 80 | On screen. Window close rms 0.013 / 1.5 ms (2-98 % 133 vs 133 ms). NC open: edge rms 4.8 pt of 378. Mission Control enter rms 0.010 / 6.8 ms. Apps opens and closes in 1 frame. Lock shake: rms 3.2 pt (amplitude 14), a little faster than 7.5 Hz. Off: Mission Control exit (2-98 % 435 vs 272 ms, a 2 % snap at 527 ms). HUD appear rms 0.038, one dip frame. Rubber band could not be triggered on screen |
| transition | 76 | 80 | Close matches. Zoom with a Finder window: 300 vs 267 ms, rms 0.031. Unzoom rms 0.073 and full screen were on the old plugin (in progress). Lock-in about 200 ms (Mac 235). Unlock: clock fade 250 vs 233 ms, but the menu bar returns in 70 ms (Mac 165 ms from +111). Spotlight close blur is in progress |
| visual | 84 | 87 | Bar, File menu, Settings Appearance, lock clock and field are close to the Mac side by side. Differences: Cmd-Tab panel is grey frosted (Mac clear Dock glass). Context menu is opaque grey (Mac glass). Quick Look is an in-window sheet (Mac: its own panel window) |
| behaviour | 68 | 80 | Fixed: Finder follows dark mode live, full File menu (25 rows, disabled states), file context menu, calculator in the bar with Show Results, CC Edit Controls and AirPlay, GTK traffic lights on the left, lock wrong password and unlock. Left: context menu does not close on a click outside the window, and stays in the old appearance. Quick Look model. Sound events |
| shape | 78 | 88 | Window corner inset at rows 0/1/2/4/8/16/32 px: 36/26/21/16/10/4/1 vs Mac 35/–/–/–/11/4/1. Bar 34 pt (Mac 34). Dock label tail 12 x 6.5 vs 16 x 6.5 pt. File menu 252 vs 272 pt wide |
| colour | 92 | 92 | Dock dark over grey 127: 108 vs 107-110. Close light hover disc 234,133,123 vs 233,127,117, glyph 158,0,0 vs 160,0,0. CC tile fills by eye only. Lock date ink whiter than the Mac's cyan-tinted ink |
| shadow | 76 | 84 | Menu shadow fixed: below at 2/10/20 pt 219/228/240 vs Mac 219/228/242, side at 2 pt 231 vs 231. Window shadow not re-measured (judge 1: side .26 vs .18). Cmd-Tab and QL shadows not compared |
| refraction | 78 | 66 | Measured over stripes for the first time (`judge-95-2/01`). Mac CC tile interior ripples ±2.5 levels and its rounded ends show concentric lens bands and a bright rim line. Ours is flat (±1 level), with no lens bands and a soft rim. Judge 1's 78 was unmeasured |
| icon | 74 | 85 | Apple logo. Green hover shows the full-screen glyph. Apps and Dock use mapped macOS-style icons. Left: Spotlight calculator icon and doc vs doc.on.doc copy glyph. Show Results has 1 icon vs 2. Plain-text files get a blank page (Mac: lined doc). Lock avatar falls back to initials |
| font | 95 | 95 | Menu titles match to 1 px (checked by eye at 2x). Lock clock in .SF Soft Numeric matches the Mac glyph shapes. Lock date looks a little heavier |
| rendering | 89 | 90 | Text AA matches. Glass interiors match (Dock grey). GTK now themed. Interior refraction missing (counted under refraction) |
| sound | 72 | 74 | Code only (subagent, spot-checked). Banners play only with a sound hint now (`shell/lib/nc.js:36-41`). Move to Trash plays `move to trash` where the Mac's Finder task uses `dock/drag to trash` (ID 16). Poof, mount and unmount, and sent have no caller. Finder's Empty Trash plays nothing (only the Dock does). Alert volume scales every event. The played copies are Vorbis. Every NSAlert-style dialog beeps (`Panels.qml:77`), and the Mac rule is unconfirmed |

## Per surface

| surface | weight | judge 1 | judge 2 | evidence |
|---|---|---|---|---|
| Menu bar + menus | 15 | 83 | 90 | Apple logo, 34 pt bar, titles 1:1 with `menubar/bar-light.png`. File menu has the Mac's rows, separators and disabled states (`02` vs `menubar/pulldown-light.png`). Width 252 vs 272 pt, "⌘ N" spaced wider than "⌘N", Print row without icon. Shadow matches |
| Dock | 14 | 85 | 89 | Fill 108 vs 107-110 (dark, grey 127). Label has a tail (12 x 6.5 pt, Mac 16 x 6.5, `06`). Slot grow/shrink and bounces: MOTION-MEASURED, not re-measured. Magnification and autohide not exercised |
| Window chrome | 14 | 65 | 85 | Corner matches (`04`). Lights match in colour and glyph (`09`). GTK app has traffic lights on the left and follows light mode. Close fade matches. Zoom 300 vs 267 ms on a Qt client. Full screen in progress. Window shadow not re-measured |
| Finder | 13 | 76 | 82 | Live dark mode, disclosure triangles, Quick Look present (`11`, zoom about 0.25 s) but as an in-window sheet. Context menu nearly complete (`03`: no Ask Siri, opaque, Share disabled). Rubber band unverified on screen. Text-file icon blank |
| System Settings | 10 | 86 | 89 | Appearance pane now has the photo + text preview card and matching thumbnails (vs `settings/appearance-light.png`). Menu Bar pane present. Energy instead of Battery (fair on a desktop). Scrolling not tested |
| Control Center | 6 | 82 | 84 | Edit Controls and the Sound AirPlay button exist. Glass fill matches by eye. Rim lens and interior refraction missing (`01`). Open pop in progress |
| Notification Center + banners | 6 | 85 | 87 | NC open edge rms 4.8 pt. Widgets and banner close to the Mac. Banner sound now only with a hint |
| Spotlight | 6 | 78 | 85 | Calculator: inline "= 4" pill, result card with copy, Show Results capsule (`05` vs `panels/spotlight-calculator-light.png`). Icons differ slightly. Close blur in progress |
| Mission Control | 4 | 80 | 84 | Enter matches the response-0.395 spring. Exit runs long, with a final 2 % snap. Chip reads "Desktop" |
| Sounds | 4 | 72 | 74 | See the dimension row |
| HUD | 3 | 92 | 86 | Appear 2-98 % 485 vs 467 ms, rms 0.038 / 26 ms, one dark dip frame at about 418 ms (fix 80fd49d landed after my session start). About 165 ms from `qs ipc` to the first frame. Rim lens weak |
| Cmd-Tab | 3 | 75 | 76 | Works with Super+Tab. Panel grey frosted with a light selection tile (`10`). The Mac uses clear Dock glass with a dark tile (`dock/cmdtab-light.png`). Window lights turn inactive while it is up (Mac behaviour not recorded) |
| Apps | 2 | 78 | 83 | 1-frame open and close. macOS-style icons. Panel greyer than the Mac's clear glass |
| Lock screen | 5 (new) | – | 86 | Clock and date layout, font and plus-lighter ink close (`07`). Field, arrow, "?" and line match (`08`). Lock-in about 200 ms (Mac 235 ms), with a 1-frame stall at the start. Shake 3 cycles, rms 3.2 pt. Unlock clock fade 250 ms vs 233. The menu bar comes back too late and too fast (70 vs 165 ms). The PAM delay (Mac 2.1 s, spinner at 1 s) can't be judged with the test double |

## Motion re-measured (mcap, my session) vs MOTION-MEASURED.md

| row | doc status | doc numbers | mine | agree? |
|---|---|---|---|---|
| Window close | matches | 134 ms, 0.010 / 0.8 ms | 133 ms, 0.013 / 1.5 ms | yes |
| Zoom | matches | 266 ms, 0.008 / 2.6 ms | 300 ms, 0.031 / 13 ms (vs the R2 per-frame series, Finder window) | **no**. The plugin agent also gets 0.010 with a blank window, so the gap likely comes from the Qt client's resize. Not settled |
| Unzoom | remaining | 0.040 / 14.7 ms | 0.073 / 31 ms | same verdict (fix ff4f9d6 landed after my session start) |
| Mission Control enter | fixed | 352 ms, 0.024 / 10.7 ms | 367 ms (Mac 360), 0.010 / 6.8 ms. One repeated frame at about 100 ms | yes |
| Mission Control exit | fixed | 302 ms, 0.025 / 19 ms, no pop | 435 ms (Mac 272), 0.023 / 37 ms. The windows still settle until 510 ms, then 2 % snaps in one frame at 527 ms | **no** (my test had two Finder windows at the same position) |
| HUD appear | fixed | 483 ms, 0.030 / 24 ms, one odd frame | 485 ms (Mac 467 in my normalisation), 0.038 / 26 ms, dip 0.68 → 0.59 at 418 ms | partly: duration agrees, value rms is worse, odd frame confirmed |
| NC open | matches | 0.015 (5.7 pt) / 7.4 ms | 4.8 pt rms at best shift | yes |
| Apps open / close | fixed | 71 % in frame 1 / close 1 frame | 100 % in frame 1 / 99 % in frame 1 | yes |
| (new) lock-in | – | – | first change → final about 200 ms. Menu bar out 0.71 at +33 ms (Mac 0.84 at +50) | – |
| (new) lock shake | – | – | 22 frames, peaks -13/+14/-13/+8/-8/+7 pt, rms 3.2 pt vs B2 | – |
| (new) Quick Look open | – | – | alpha 0.41 in frame 1, 1.0 at 245 ms (Mac 0.79→1 in 0.25 s) | close |

## Ranked gap list (weight x points lost)

The estimated gain is in overall points.

| # | surface | dim | ours vs Mac | owner | Apple data for the fix | est. gain |
|---|---|---|---|---|---|---|
| 1 | CC, Dock, HUD, menus, Spotlight (all glass) | refraction | Interior flat (±1 level over stripes vs ±2.5). No lens bands at the rounded ends, softer rim line (`01`) | `plugin/` (shaders) | yes: `screens/27.2.1/verify/C2/cc-real-stripes-*.png`, `verify/B2/content-lens-*.png`, `live/verify/B2/configs` | +1.2 |
| 2 | Finder | visual, behaviour | Quick Look is a sheet inside the Finder window (X + "Open"). The Mac uses its own panel window with traffic lights, title, "Open with Preview" and a shadow, and it can leave the Finder window | `finder/qml/QuickLook.qml` | yes: `live/finder/crops/quicklook-*.png`, MAC-ANSWERS Quick Look | +0.6 |
| 3 | menus (all apps) | shape, visual | File menu 252 vs 272 pt wide. Shortcut glyphs spaced ("⌘ N" vs "⌘N"). Print row has no icon | `shell/modules/MenuDropdown.qml` | yes: `screens/27.2.1/menubar/pulldown-light.png`, `live/menubar/menubar-metrics.json` | +0.5 |
| 4 | Finder | behaviour, visual | Context menu: opaque grey instead of glass, no Ask Siri header, Share disabled. Does not close when the click lands outside the Finder window. Keeps the old appearance after a dark switch | `finder/qml/PopupMenu.qml`, `finder/qml/Browser.qml` | yes: `live/finder/crops/context-menu-*.png` | +0.5 |
| 5 | sounds | sound, behaviour | Move to Trash plays the wrong file. Poof, mount and unmount, and sent have no caller. Finder Empty Trash is silent. Alert volume scales every event. Vorbis copies | `shell/scripts/sound.sh:17-36`, `finder/qml/Browser.qml:241`, `finder/src/fileops.cpp` | partial: `re/27.2.1/decomp/systemsoundserverd-ids.txt`, MAC-ANSWERS :526-582, :3688-3716 | +0.5 |
| 6 | Finder, Settings | animation | Rubber band can't be triggered from a virtual pointer's finger-axis events. Content does not stretch (0 px over 600 px of pull at the top). Either Hyprland's virtual pointer drops the axis source/phase, or real trackpads are affected too. Unverified on screen | `ui/HyprK/RubberBand.qml` (phase gate at :96) | yes: MAC-ANSWERS rubber-band constants, `reference/ours/rubberband/README.md` | +0.4 if it works on a real trackpad (needs a hardware check) |
| 7 | Cmd-Tab | visual, colour | Grey frosted panel and light selection tile. The Mac uses the Dock's clear glass with a dark tile. Windows go inactive while it is up | `shell/modules/Switcher.qml` | yes: `screens/27.2.1/dock/cmdtab-*.png`, Q-dock-22 | +0.3 |
| 8 | window chrome | shadow | Active window shadow not re-measured. Judge 1: side at 2 pt .26 vs .18 | `config/hypr/hyprland.lua` (Q-windows-01 block), `plugin/` | yes: `live/windows/shadow-profiles-finder.json` | +0.3 |
| 9 | Mission Control | animation | Exit 435 vs 272 ms with a 2 % one-frame snap at the hand-off (527 ms) | `shell/modules/MissionControl.qml` | yes: R2 track, `live/dock/mission-control.json` | +0.2 |
| 10 | windows | transition | Zoom of a Qt client 300 vs 267 ms, rms 0.031. Unzoom and full screen were rebuilt in ff4f9d6 (**in progress at judging time**) | `config/hypr/hyprland.lua`, `plugin-motion/` | yes: R2 per-frame series in `hyprland.lua:150` | +0.2 |
| 11 | lock screen | transition | Unlock: menu bar back in 70 ms at the end (Mac ease-in-out 165 ms from +111 ms). 1-frame stall at the start of the lock-in. Shake 3.2 pt rms, slightly fast | `shell/modules/lock/Lock.qml`, `LockOverlay.qml`, `lock.js` | yes: `re/LOCKSCREEN-27.2.1.md` B1-B3 | +0.2 |
| 12 | Spotlight | icon | Calculator app icon differs. Copy glyph is doc, not doc.on.doc. Show Results shows 1 icon (Mac: Calculator + Finder) | `shell/modules/spotlight/`, `shell/modules/Spotlight.qml` | yes: `panels/spotlight-calculator-*.png` | +0.15 |
| 13 | Dock | shape | Label tail 12 pt wide (Mac 16 x 6.5) | `shell/modules/Dock.qml` | yes: MAC-ANSWERS :1524 | +0.1 |
| 14 | HUD | animation | Appear rms 0.038 with one dip frame. Fix 80fd49d **in progress at judging time** | `plugin/`, `shell/modules/HudWindow.qml` | yes: `live/verify/A/hud-appear-fit.json` | +0.1 |
| 15 | CC | animation | Last 4 % (tile rims) pops in at about 465 ms. **In progress** (78b2429 traces it to Quickshell's truncated glass region) | `plugin/`, `shell/modules/ControlCenterWindow.qml` | R2 ease-out | +0.1 |
| 16 | Spotlight | transition | Close has no blur. **In progress** (shell agent) | `shell/modules/Spotlight.qml` | R2 (eyeballed only) | +0.1 |
| 17 | Finder | icon | Plain-text and markdown files show a blank page. The Mac draws a lined document | `finder/qml/lib/icons.js`, `macicons.js` | yes: `screens/27.2.1/finder/list-light.png` | +0.1 |
| 18 | lock screen | colour, font | Date ink whiter and a little heavier than the Mac's cyan-tinted medium. Avatar falls back to initials when there is no user picture | `shell/modules/lock/LockTheme.qml`, `LockContent.qml` | yes: `screens/27.2.1/lock/clock-date-*.png` | +0.1 |
| 19 | Apps | visual | Panel greyer than the Mac's clear glass | `shell/modules/Spotlight.qml` (apps mode), `shell/services/AppsView.qml` | yes: `screens/27.2.1/dock/apps-*.png` | +0.05 |
| 20 | Settings | behaviour | Sidebar shows Energy (Mac laptop: Battery). Scroll-edge and rubber band not checked | `settings/Panes.js` | yes: `screens/27.2.1/settings/` | +0.05 |

## Cannot reach on this stack

- **Trackpad momentum from the system.** Wayland sends no momentum events, so momentum and rubber band must be rebuilt in every
  toolkit. Ours covers only hyprk's own Qt views. GTK, Electron and browser apps keep their own scrolling.
- **Third-party app menus in the global bar.** GTK4 and most Wayland apps export no menu model, so their menu bar shows hyprk's generic
  menus, not the app's.
- **Glass inside client windows.** Finder and Settings toolbars are drawn by Qt inside the client. They cannot sample the desktop behind the
  window, so true lensing there would need compositor help per element.
- **Zoom of a real client.** The client re-lays out at each size it is configured to. Hyprland snapshots and stretches, so frames mid-zoom
  are never pixel-identical to AppKit's live resize. A blank window can match, a Qt or GTK window will lag at the end.
- **Hardware and Apple services.** Touch ID line, Siri ("Ask Siri" header), AirPlay targets, Apple Park preview art: placeholders only.
- **PAM timing on the lock screen.** The Mac's 2.1 s failure delay comes from system PAM (`pam_faildelay`), not from the shell.

## Not judged / limits

- Cmd-Tab dismiss, Dock bounces, label fade, slot grow, banners and menu motion: not re-measured (MOTION-MEASURED rows kept).
- Dock magnification and autohide, Settings scroll edge, the controls gallery, Displays and Sound panes: not exercised.
- Sounds: nothing was played (muted). `HYPRK_SOUND_LOG` stayed empty for a hint-less test banner, as the code predicts.
- The Settings and GTK screenshots showed the account name and a real file restored by the GTK editor. They were not saved.
- Crops: `reference/judge-95-2/01`-`11` (Mac left, ours right where paired). The lock avatar is covered in `08`.
