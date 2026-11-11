# hyprk independent judge: 95 % goal check (2026-11-11)

- Commit judged: **774722a** (plugin `plugin/build/libliquidglass.so` sha256 a35cda2e88a33bd7…, built 08:37 from 2821fa0's glass model).
  Glass, refraction and glass shadows are judged as final, not provisional (the coordinator confirmed the plugin was stable from 774722a).
- Ground truth: `reference/screens/27.2.1/**`, `reference/re/MAC-ANSWERS.md`, `reference/re/27.2.1/live/**`.
- Ours: my own headless session (`HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh`, output MBA 2560x1664 at 2x = 1280x832 pt), with its own
  state and cache dirs. I drove it with `qs ipc`, `hyprctl`, a virtual pointer (scripts/vptr plus right click and wheel, built in scratch) and `grim`.
  I used flat backdrops (white, grey 127, black, blue 69,83,206) through `wallpaper.json`, light and dark. Finder ran on a fake `finder-demo` tree.
  Settings and a GTK app (gnome-calculator) ran inside the nested session only. I restarted the session once, at 08:38, to load the new plugin build.
  All shots used in this file come from the second session.
- Two helper subagents read code only (no screen). They covered the motion constants against the Mac tracks and the sound files and wiring.
  I spot-checked their key claims (`Notifs.qml:64,68`, `Panels.qml:77`, the Finder `--dark` path). Motion is **by code, not measured on screen**.
  I did not capture frame sequences, so animation and transition scores rest on code constants and the subagent's curve fits against the Mac JSON tracks.
- Scale: 95+ means a careful observer can't tell it from the Mac reference. 85-94 means small measurable differences. 70-84 is visible at a glance to a macOS user.
  Below 70 means clearly different. A missing feature scores 0 for that item.

## Overall: **79**

Method: each surface gets one score, the mean of its applicable dimensions, with missing items counted as 0.
Weights follow how often a user sees the surface: menu bar 15, Dock 14, windows 14, Finder 13, Settings 10, CC 6, NC 6, Spotlight 6,
Mission Control 4, sounds 4, HUD 3, Cmd-Tab 3, Apps 2 (sum 100). The weighted sum is 79.3. I rounded it down.

## Per dimension

| dimension | score | evidence (short) |
|---|---|---|
| animation | 69 | By code. Springs and bounces fit the Mac tracks: NC open RMS 1.5 pt, Dock bounce 0.5 pt, switch 0.2 pt. Missing: rubber band, Quick Look, CC module morph, Dock tile insert/remove. Menu highlight glides 0.15 s, the Mac jumps in 1 frame |
| transition | 76 | By code. Window close/zoom fit (RMS 0.006). Full screen uses the zoom curve (no Space slide, RMS 0.086). Traffic-light glyph fade 0.3 s, Mac ~0.12 s. Spotlight close has no blur |
| visual | 84 | Bar, HUD, CC and NC side by side are hard to tell apart. Window corners, menus with few items, the GTK chrome and the distro logo give it away |
| behaviour | 68 | Finder ignores system dark mode. Menus and context menus are short. Spotlight calculator layout differs. CC has no Edit Controls. GTK apps ignore the appearance |
| shape | 78 | Dock 525x82 pt vs formula 523x84. HUD width identical (581 px). CC pitch identical (152 px). Window corner much rounder (row-0 inset 52 pt vs 17.5). Label has no tail. Popover has no arrow |
| colour | 92 | CC tiles 109/114, 186/229, 32 (Mac identical). Dock 107/175/12/38/229 (Mac 107/176/12/38/229). Finder dark bg 30 vs 31,31,37. Traffic lights within 16 levels |
| shadow | 76 | Window light active side .26/.16/.07 vs .18/.14/.09, below .28/.28/.22 vs .32/.28/.22. Menu shadow about 2x too dark (2 pt below: 176 vs 219) |
| refraction | 78 | Glass interior numbers match the Mac model exactly (see Settings). The rim lens is weaker than the Mac HUD and CC edges, which show the backdrop bent at the ends. Not measured with stripes: weak evidence, so scored low |
| icon | 74 | Distro logo instead of the Apple logo. Linux app icons in the Dock, Apps and Spotlight. Green light hover shows "+". Spotlight mode glyphs differ. NC card falls back to a generic icon |
| font | 95 | Menu-bar title ink runs within 1 px of the Mac in position and width (File 39 px both, Window 96 vs 95). SF Pro everywhere |
| rendering | 89 | Text AA matches. Glass interior matches the model to 1 level. GTK apps render Adwaita |
| sound | 72 | Subagent, files and wiring only. All 288 originals are sha256-identical to 27.2.1. The played copies are Vorbis. Move to Trash, Dock poof, mount, power and startup sounds are not wired. Banners and every alert play the alert sound |

## Per surface

| surface | weight | score | evidence (ours vs Mac, reference) |
|---|---|---|---|
| Menu bar + menus | 15 | 83 | Title ink identical to 1 px (`judge-95/14`). Bar 32 pt vs 34. Distro logo. Menu glass dark over W/G/B 121/115/32 vs 122/115/32, light 254/136 vs 251/137. File menu 7 rows vs ~25 with disabled rows and icons (`05`). Shadow 2x (`06`). Highlight glides (by code) |
| Dock | 14 | 85 | Geometry within 2 pt (Q-dock-02). Fill matches over 5 backdrops (`15`). Label 25x70.5 pt, fill 250/42 vs 249/31, no tail (`21`). Press darkens. Recents section works. No tile insert/remove animation. Linux icons |
| Window chrome | 14 | 65 | Corner far too round (`01`). Shadow close. Rim 1 pt vs 0.5 pt. Lights: green "+" glyph and no press glow (`02`). GTK app: Adwaita header bar, controls on the right, dark while the system is light (`20`) |
| Finder | 13 | 76 | 4 views present. Colours within 1-6 levels (`07`, `18`). Not dark when the system is dark (`07`). Context menu 5 rows vs 15 (`03`). Tag popover has no arrow (`04`). No list disclosure triangles. Stray chevrons in columns view |
| System Settings | 10 | 86 | Layout and controls close (`10`, `11`). Liquid Glass slider: menu over white 146/133/121/99/86 at 0/0.25/0.5/0.75/1. The Mac gives 122 at 0.5 and 86 at 1. Dock and CC fill stay constant, as on the Mac. Sidebar has Energy and Control Center where the Mac has Battery and Menu Bar. Some labels differ. Preview card and icon-style glyphs differ |
| Control Center | 6 | 82 | Fills identical on 5 backdrops (`19`). Tile pitch identical. No Edit Controls. Sound tile has no AirPlay button. Module expand missing (`12`) |
| Notification Center + banners | 6 | 85 | Cards, stack plates and widgets close (`17`). Card icon falls back to generic. Banner sound always plays. Motion fits (by code) |
| Spotlight | 6 | 78 | Bar close. Mode list present but 3 of 4 glyphs differ (`09`). Calculator: no inline "= 4", no card in the bar, no Show Results (`08`). Close blur missing (by code) |
| Mission Control | 4 | 80 | Windows spread, Dock visible, Spaces bar. "Desktop 1" vs "Desktop". Motion RMS 0.07 (by code) |
| Sounds | 4 | 72 | See the dimension row |
| HUD | 3 | 92 | Capsule 581 px wide in both, top right under the bar, CC pill lit, segments and fills close (`16`). Rim lens weaker |
| Cmd-Tab | 3 | 75 | Selection tile and label right. Panel greyer than the Mac's Dock material (`13`). No 0.19 s show delay and no quick-tap switch (by code) |
| Apps | 2 | 78 | Category chips, suggestion row and grid are right. Panel is greyer than the Mac's clear glass. Linux icons |
| Lock screen | 0 | – | No reference |

## Top gaps (ordered by impact on the overall score)

| # | surface | dimension | what differs | Mac vs ours | reference / crop | sure |
|---|---|---|---|---|---|---|
| 1 | every window | shape | Corner much rounder, visible on every window. At 4 px below the top edge the inset is 62 px vs 16 px | Mac inset at rows 0/8/16/32 px: 35/11/4/1 px. Ours: 104/47/31/16 px. Hyprland `rounding = 36` at 2x looks doubled | finder/list-light.png, `judge-95/01` | high |
| 2 | Finder | behaviour | Ignores the system appearance. Only `--dark` makes it dark, and the Dock launch (`Apps.runHyprkApp`) does not pass it. `Main.qml:40` reads `startup.dark` once | Mac follows dark live. Ours stays light | finder/list-dark.png, `judge-95/07` | high |
| 3 | third-party windows | visual, behaviour | GTK apps keep Adwaita: header bar, controls on the right, no traffic lights. The calculator was dark while the system was light | macOS chrome vs Adwaita | `judge-95/20` | high |
| 4 | menus | behaviour | Finder File menu has 7 rows. The Mac has ~25, with disabled rows and leading SF Symbols (Q-menubar-17, -31) | 25 vs 7 rows | menubar/pulldown-light.png, `judge-95/05` | high |
| 5 | menus | shadow | Drop shadow about 2x too dark | below at 2/10/20 pt: Mac 219/228/242, ours 176/203/228. Side at 2 pt: Mac 231, ours 203 (Q-menubar-28) | `judge-95/06` | high |
| 6 | Finder | behaviour | File context menu is short and has no icons | Mac: Ask Siri header, Open, Open With ▸, Move to Bin, Get Info, Rename, Compress, Duplicate, Make Alias, Quick Look, Copy, Share…, tags, Quick Actions ▸, Services ▸. Ours: Open, Move to Trash, Rename, Quick Look, tags | live/finder/crops/context-menu-file-light.png, `judge-95/03` | high |
| 7 | menus | animation | Row highlight glides on a 0.15 s spring | Mac jumps in 1 frame (Q-menubar, MAC-ANSWERS ~2255). Ours `MenuDropdown.qml:251` | by code | medium |
| 8 | menu bar | icon | Distro logo instead of the Apple logo, always visible top-left | – | menubar/bar-light.png, `judge-95/14` | high |
| 9 | scrolling everywhere | animation | No rubber-band overscroll (`StopAtBounds`) | macOS elastic vs hard stop | by code | medium |
| 10 | window chrome | icon, visual | Traffic lights: green hover glyph is "+", the Mac shows the full-screen glyph. Press has no bright glow. Lights look flat, without the Mac's darker rim | close hover centre Mac (160,0,0), ours glyph lighter | windows/lights-*-light.png, `judge-95/02` | high |
| 11 | Spotlight | behaviour, shape | Calculator: Mac grows the bar with an inline "= 4" and a result card inside, plus a Show Results capsule. Ours adds a separate row below | – | panels/spotlight-calculator-light.png, `judge-95/08` | high |
| 12 | Control Center | behaviour | No "Edit Controls" button. Sound tile has no AirPlay output button. Modules don't expand (morph ~0.35 s missing) | – | panels/controlcenter-light.png, `judge-95/12` | high |
| 13 | Dock | shape, colour | Hover label has no tail (Mac: 16x6.5 pt tail pointing at the icon). Dark fill is too light | dark over black 31 vs 42. Light 249 vs 250 (Q-dock-08) | `judge-95/21` | high |
| 14 | sounds | behaviour | Every banner plays the alert sound (`Notifs.qml:64,68`), and so does every alert dialog (`Panels.qml:77`). Not traced on the Mac, so the Mac behaviour is unconfirmed | – | shell/services | medium |
| 15 | sounds | behaviour | Missing events: Move to Trash, Dock poof, mount/unmount, power chime. "Play sound on startup" is a dummy switch | files shipped, no callers | MAC-ANSWERS "Sounds" | high |
| 16 | windows | transition | Full screen reuses the zoom curve: no Space slide, no two-step exit | RMS 0.086, max 0.20 against M153 | by code | medium |
| 17 | windows | animation | Traffic-light glyph reveal is a 0.3 s spring | Mac 0.07 s delay, then ~0.1 s ease-out (M877) | by code | medium |
| 18 | Finder | animation | No Quick Look zoom (0.79→1 in 0.25 s) and no close-into-icon | missing | by code | medium |
| 19 | Dock | animation | No tile insert/remove slot animation | Mac 0.25 s grow / 0.15 s shrink (M90) | by code | medium |
| 20 | Finder | shape | Tag popover has no arrow. Its glass is flatter, without the bluish lit rim | – | live/finder/crops/tag-popover-light.png, `judge-95/04` | high |
| 21 | Settings | behaviour | Sidebar shows Energy where the Mac has Battery, and a Control Center pane where the Mac has Menu Bar. Labels differ: "Position on screen" vs "Dock position on screen", "Double-click a window's title bar to" vs "Window title bar double-click action" | – | settings/desktop-dock-dark.png, `judge-95/11` | high |
| 22 | Settings | visual, icon | Appearance pane: the Liquid Glass preview card (Mac: photo plus a text card), the mode thumbnails (Mac shows wallpaper art) and the icon-style tile glyph (cloud vs sun and cloud) all differ | – | settings/appearance-light.png, `judge-95/10` | high |
| 23 | Spotlight | icon | Mode-list glyphs: Files (filled vs outline folder), Actions (bolt vs stacked layers), Clipboard (clipboard vs doc on doc) | – | panels/spotlight-modelist-light.png, `judge-95/09` | high |
| 24 | Finder | visual | List view has no disclosure triangles on folders. Columns view draws stray chevrons in the empty parent column | – | finder/list-*.png, `judge-95/18` | high |
| 25 | Cmd-Tab | colour, behaviour | Panel greyer than the Dock material (Mac: pixel-identical to the Dock). No 0.19 s show delay and no quick-tap switch | – | dock/cmdtab-light.png, `judge-95/13` | medium |
| 26 | icons | icon | Linux apps keep non-Apple icons in the Dock, Apps and Spotlight. Unknown apps get a generic doc icon on NC cards (Script Editor) | – | dock/apps-light.png, nc/stack-*.png, `judge-95/17` | high |
| 27 | menu bar | shape | Bar 32 pt vs 34 pt on the notched Air (Q-menubar-01), so titles sit 1.5 pt higher | 68 vs 64 px | `judge-95/14` | high |
| 28 | window chrome | shadow, shape | Outer rim 1 pt (2 px) at alpha .20 vs the Mac's 0.5 pt (1 px) at .21. Light active side shadow too strong near the edge | side at 2 pt .26 vs .18 (Q-windows-01, -03) | measured | high |
| 29 | Spotlight | transition | Close adds no blur (Mac 0→25) | – | by code | medium |
| 30 | Mission Control | visual | With one Space the chip reads "Desktop 1", the Mac reads "Desktop" | – | dock/mc-light.png | medium |

## What is already at Mac level (for calibration)

- Menu-bar title text: same positions and widths to 1 px.
- Glass interior over flat colours: CC, Dock and menus are within 1-2 levels on every backdrop I tried. The Liquid Glass slider reproduces the Mac's
  dark menu values at 0.5 and 1 (121 vs 122, 86 vs 86), and Dock and CC stay constant across the slider, as on the Mac.
- HUD geometry and position. Dock geometry. CC tile pitch.
- Finder and Settings colours: within a few levels in both appearances.

## Not judged / no reference

- Lock screen (`lockscreen/`, `shell/modules/lock`): no Mac reference, not scored.
- Motion on screen: no frame captures. All animation and transition numbers are by code, from the motion subagent's fits against `live/**` tracks.
- Controls gallery (switch, slider, segmented, checkbox, radio, popup, button, focus ring): not captured side by side. Only Settings panes and code constants were checked.
- Settings Displays, Sound and Accessibility: captured in dark but not compared in detail. Settings scrolling and the scroll edge were not tested.
- Menu bar submenu, status-item menus (Wi-Fi, battery) and the desktop context menu: not opened. Battery and Wi-Fi can't be shown in a headless session.
- Dock magnification, autohide and launch bounce: not exercised on screen (by code only, 80-92).
- Refraction at the rim: not measured with stripe backdrops, so that score is low on purpose.
- Cursors and emoji: not compared to `live/windows/cursors*` or the R4 emoji data.
- Quick Look, sheets and alerts in Finder: not opened.
- Sounds: files and wiring only. Nothing was played.
