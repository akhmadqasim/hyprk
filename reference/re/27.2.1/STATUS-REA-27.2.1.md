# Menu bar status item modules against macOS 27.2.1 (26B131), reverse engineered

What the Wi-Fi, Battery and Focus status items open on the Mac, and what hyprk builds from it
(`shell/lib/statusmodule.js`, `shell/modules/StatusModulePanel.qml`, `shell/modules/StatusModuleWindow.qml`).
Follows "Menu bar status items" in `MENUS-REA-27.2.1.md`.

Sources, as in MENUS-REA:

- **R** resource: `ControlCenter.app/Contents/Resources/{WiFi,Battery,Focus}.loctable` (en), from `141-12228-174.dmg`
  mounted read-only with apfs-fuse (unmounted after). Copies: `~/Downloads/macos/re-work/status/res/`.
- **C** code: ControlCenter arm64e (`re-work/r2/ControlCenter`, thin). Types and view composition from
  `ipsw swift-dump --demangle --extra` (`re-work/status/out/swift-extra.txt`: each View's `Body` type spells its
  children in source order). Functions decompiled with Ghidra headless (project `re-work/status/gh`, scripts
  `re-work/status/scripts/`; `analyzeHeadless` on PATH is Ghidra 12.2, the brief named 12.1.4: same decompiler output
  for these questions, noted for the record). REA 6.8.0's own Ghidra route was not used (it times out on big binaries,
  MENUS-REA). Decompiles: `re-work/status/out/{ccui,strfns,wifi,wifi2,bat,focus,modw,widths}.c`. Addresses below are
  the arm64e image's.
- **S** the user's photo of the Sound module (2026-11-11 23.11.22, readings in `shell/modules/CcSoundPanel.qml`).
- **M** the Mac session's shots of the three modules (2026-11-14, MAC-ANSWERS-2 M2.7):
  `screens/27.2.1/panels/module-{wifi,battery,focus}-{light,dark}.png`, 1440 x 932 pt at 2x. Section 6.
- **GUESS** none of the above.

Sections 1-4 were written from code and resources before the shots existed; section 6 measures the shots and replaces
every GUESS it could (the rows below say which).

## 1. One component family: ControlCenterUI.ModuleStack

**C** (swift-dump): `WifiExpandedView`, `BatteryView` (inside `BatteryExpandedView`) and `FocusModesExpandedView` are
all built from ControlCenterUI's `ModuleStack`: `ModuleStackHeader` (title, optional subtitle, accessory `.text(Text?,
Image?)` or `.toggle(Binding<Bool>)`), `ModuleStackList` (optional title, disclosure control), `ModuleStackToggle`
(a disc with a symbol, title, subtitle), `ModuleStackLabel`, `ModuleStackListDivider`, `ModuleStackPreferencesLink`
(the "… Settings…" row). The Sound module is the older family (`SoundView`: `ModuleHeader`, `SolariumSlider`,
`ModuleList`, `PreferencesListItem`), so the Sound photo is a cross-check, not the source.

Shared numbers, **C** unless marked:

| fact | value | source |
|---|---|---|
| module width | 308 | `Module` width getter `0x1000deadc` returns `__const 0x1006d4e20` = 308.0; the vtables of `WiFi`, `Battery`, `FocusModes`, `Sound` (and 18 other module classes) point at it (one override, `FUN_100225170`: 320 or 308). Next getter `0x1000deae8` = 458.0 (inferred: a maximum height) |
| item inset | 14 leading / trailing, 5 top / bottom | `ModuleStackItem` `.inset` style, `FUN_100612950` |
| label | symbol 26, symbol-to-text 8, baseline spacing 22, minimum height 22 | `PlainModuleStackLabel` plain style `FUN_10061428c` (style switch `FUN_100617f34`) |
| label styles | toggleDetail / toggleSubtitle: plain + 34 leading padding when there is no symbol (`FUN_100623434`, `FUN_100623650`); appIcon: symbol 16 (`FUN_1006307a0`); `_headerFooter`: minimum height 18 (`FUN_100611da0`) | |
| clickable row | at least 32 tall | `FUN_100616afc` (navigation info set and triggered by click → 32, else the minimum height) |
| text x | 14 + 26 + 8 = 48 | from the two rows above. **S**: device name ink from 49.4 (SF side bearing ≈1) |
| list title row | 18 + 5 + 5 = 28 | **S**: "Output" row 64.6 → 92.1 = 27.5. **M**: 22 tall, 5 under the line above (27 from the line's bottom to the first row) |
| row pitch | 32 | **S** 32 |
| toggle disc | 26 (`FUN_10062ca74`: frame ideal width 26, background + overlay) | **S** 25.5–26 |
| checkmark toggle symbol | 26 × 14 frame, SF 13 semibold | `FUN_10062c914`, font `FUN_1005fe3b4` |
| fonts | a table of `.body` / `.callout` / `.subheadline` / `.footnote` statics (`FUN_1005fe08c…`); which part takes which is not mapped | **S**: titles 13 bold, rows 13 regular (`.body` is 13 on macOS). **M**: header 13 Semibold, list titles 12 Semibold, rows 13 Regular, Battery state lines 12 Regular |
| header switch | `ModuleSwitchToggle` = SwiftUI `SwitchToggleStyle` (`FUN_100608da4`); control size not set there | **M**: 54 x 24, knob 32 x 20 (HyprK regular), y 9..33, right edge 14 in |
| header row height, title baseline | not decoded | **M**: 42, baseline 26, SF 13 Semibold (was GUESS 40 / 25.5 bold) |
| divider | 1 pt line, 14 in | **M**: 1 pt, 14 in, 5 under a list's last row and 5 above the next list's first; straight under the header (42) and under the Battery state lines |
| "… Settings…" row | `ModuleStackPreferencesLink` | **M**: the panel ends 34 under the line, baseline 21 under it (**S** read 32.6 off a JPEG) |

Placement, **C** `MenuPositionCoordinator` `FUN_1000f0694`: left to right the window's content left edge sits on the
status item's left edge (anchor minX minus the window's shadow inset); if its right edge would pass the screen's,
alignment becomes topTrailing and the right edge sits on the item's right edge. The width is the content's (window
width minus shadow insets) unless a Control Center frame is set (`bentoBoxFrame`, `FUN_1000eede4`: then the grid's
width, the from-the-grid case). Vertical gap under the bar: **M** 1 pt (section 6; was GUESS 6).

## 2. Wi-Fi

**R** WiFi.loctable: "Wi‑Fi", "Known Network", "Known Networks", "Personal Hotspot(s)", "Other Networks",
"Wi‑Fi Settings…", "Network Settings…", "WIFI_OFF" = "Off", details keys (IP Address, Router, Security, BSSID,
Channel, Country Code, RSSI, Noise, Tx Rate, PHY Mode, MCS Index, NSS), "Open Wireless Diagnostics…".

**C** `WifiExpandedView.Body` = ModuleStack { ModuleStackHeader<HeaderDetails>, DiagnosticOptions?, NetworkLists,
ModuleStackList { ModuleStackPreferencesLink } }. Header: `FUN_100314010` builds Text("Wi‑Fi") and a binding on the
controller, passed to the header's **toggle** accessory init `FUN_1006309a4`. `HeaderDetails` (interface, IP,
channel labels) and `DiagnosticOptions` are the ⌥-click extras (`KeyboardModifierMonitor` field, `showDetails`).
`NetworkLists` (`FUN_100317bf0`): one `ModuleStackList` per non-empty group, in this order: Personal Hotspot(s)
(singular when one), Known Network(s) (singular when one), four unconfigured-accessory groups (`WiFiGroup`
unconfiguredAirPort / AirPlay / AirPrint / MFi), **Other Networks**; only Other Networks gets a disclosure control
(`.visible(Binding)` from a `LazyState`), the others none. Rows: `WifiNetworkToggle` = `ModuleStackToggle` with
`WiFiNetworkStatusView` as accessory (an Image, Text, `BatteryGlyphSmall` for hotspots) plus a `ModuleStackLabel`.
Footer: "Wi‑Fi Settings…" (`FUN_10031481c`: "Network Settings…" in the other branch).

**M**: Other Networks is shown collapsed (">"); the known network's row carries a lock at the right; hotspot rows carry
signal bars, "4G" and a small battery. Not decoded: when the "searching…" label shows, the off state beyond "lists
are empty".

## 3. Battery

**R** Battery.loctable: "Battery", "Power Source: Battery", "Power Source: Power Adapter", "Power Source: UPS",
"Fully Charged", "%@ until fully charged", "More than 10 hours until fully charged", "Charging On Hold",
"Charge to Full Now", "Service Recommended", "Using Significant Energy", "No Apps Using Significant Energy",
"Battery Settings…", "Energy Settings…", "No Batteries", "Low Battery", "Slow Charger".

**C** `BatteryExpandedView` = ModuleStack { BatteryView | UPSView | NoPowerSourceView }. `BatteryView`
(`FUN_1001ad064`): header Text("Battery") through the accessory init `FUN_1006309a4`; the accessory is the
percentage Text (`FUN_1001ada08`) **only when `BatteryPreferences.showPercentage` is off** (the menu bar default,
MAC-ANSWERS Q-menubar-29), else none; then, when available, a "Charge to Full Now" list
(`charge-to-full-now-group`); the state labels (`FUN_1001ae218`: "Service Recommended" when flagged; the power source
/ charge line `FUN_1001ae7cc`, which also picks "Slow Charger"); an "Energy Mode" list when the Mac has energy modes
(`FUN_1001adf04`); `AppsUsingSignificantEnergy` (`FUN_1001af500`: list titled "Using Significant Energy" with app
rows in the appIcon label style, or the label "No Apps Using Significant Energy"); "Battery Settings…".

**M**: the percentage is SF 13 Regular in the secondary colour; on the adapter the state is two lines, "Power Source:
Power Adapter" then "Fully Charged" (SF 12 Regular, secondary, 18 apart). Not decoded: the duration format inside
"%@ until fully charged".

## 4. Focus

**R** Focus.loctable: "Focus", "Focus Settings…", "FOCUS_MODE_ON" = "On", "FOCUS_MODE_OFF" = "Off".

**C** `FocusModesExpandedView.Body` = ModuleStack { ModuleStackHeader (title + animated optional subtitle Text),
ModuleStackList { ForEach FocusActivityView }, ModuleStackPreferencesLink }; `FUN_10019fc18`: Text("Focus"), the
subtitle from the active activity (`FUN_1001a01c4`, optional), no accessory (`FUN_100630fe4`), the list, then
`SystemPreferences.focus` + "Focus Settings…" (anchor "focusmodes"). `FocusActivityView` = a `ModuleStackList` in a
toggle style whose children are `FocusLifetimeView` = `ModuleStackToggle` (the "for 1 hour" style choices; their
strings are not in ControlCenter's loctables). The modes themselves (Do Not Disturb, Sleep, Personal, Work…) come
from the user's Focus configuration, not ControlCenter.

## 5. What hyprk builds (2026-11-14, revised from the shots)

| module | rows built | data | disabled / not built |
|---|---|---|---|
| Wi-Fi | header "Wi‑Fi" + switch; "Known Network(s)" (known or connected, connected first, then by signal; a lock on a secured one); "Other Networks" with a chevron, collapsed until clicked; "Wi‑Fi Settings…" | Quickshell.Networking (scanner on while open); a row joins a known or open network (`connect()`) | an unknown secured network is shown disabled (no password sheet); Personal Hotspots (no Instant Hotspot on Linux), accessory groups, ⌥ details not built |
| Battery | header "Battery" + "NN%"; "Power Source: …" and, on the adapter, the charge line ("Fully Charged", "h:mm until fully charged", "Charging On Hold"); "Energy Mode" with "Low Power"; "No Apps Using Significant Energy"; "Battery Settings…" | UPower display device | Low Power disabled (hyprk sets no energy mode); per-app energy, Charge to Full Now, Service Recommended: no data on Linux |
| Focus | header "Focus"; the six default modes in the Mac's order (Do Not Disturb, Work, Sleep, Mindfulness, Reduce Interruptions, Driving; DoNotDisturb.framework glyphs); "Focus Settings…" | `Notifs.dnd`; with it on: the header's "On", the moon's disc in systemIndigo, no line above "Focus Settings…" (R4.2) | the five modes hyprk does not have are shown disabled (no text says why); the lifetime drawer not built |

The menu bar battery item no longer draws its percentage (Q-menubar-29; the module's header shows it).

Not built: Bluetooth, Sound, Display, Now Playing, Screen Mirroring, Fast User Switching (no status item in hyprk's
bar, and the stock Mac bar shows them only when enabled or active); Text Input (a classic NSMenu, no input-source
list in hyprk).

## 6. Measured on the Mac shots

`screens/27.2.1/panels/module-{wifi,battery,focus}-{light,dark}.png` (MAC-ANSWERS-2 M2.7; crops of 2880 x 1864 px
full-screen shots from px y 40, x 1888 or 1810; display RGB, converted to sRGB with the PNG's own profile for colours).
Panel pt = (px - panel origin) / 2; panel origin px (18, 20) in the Wi-Fi and Focus crops, (20, 20) in Battery. Ink
edges from a per-row median background, threshold 40 (text) or 12 (discs); lines from the column-averaged profile.

**Panel.** 616 px = **308** wide in all six (a 1 px darker rim just outside). Top **30.0 pt** on screen. The bar at
1440 x 932 is about 28.5-29 tall: the open item's 24 pt pill (Q-menubar-11) bottoms out at 26.25 (centred on a 28.5 bar),
and the module window's shadow is cut at 29.0 (a 2-4 level step left and right of the panel, stronger near it): the
panel sits **1 pt under the bar**, as the pull-downs (Q-menubar-14, bar 34 + 1). Horizontally all three shots are the
flipped case: the panel's right edge 1261 / 1223 / 1261 pt, the pill's right edge (its capsule curve extrapolated from
the rows under the crop's top) about 1262.5 / 1224 / 1261.5: **1 pt inside the pill** (0.5-1.5). Corner: the same
profile as a continuous r 16 (rows 20..60 px: left edge 49, 42, 38, 34, 31, 28, 25, 22, 21, 18 px; hyprk's within 1 px).
Heights: Wi-Fi **272**, Battery **233**, Focus **280**.

**Glass.** Light: a light frost tinted by the wallpaper (170-190, 220-235, 245-255 over Tahoe Light), dark text; dark:
dark blue frost (35-60, 50-80, 185-210 over Tahoe Dark), white text: it follows the appearance, unlike Control
Center's tiles (white text in both, `controlcenter-light.png`). hyprk draws it on the menus' layer (Regular + the menu
shadow). The shadow was not fitted (no shot without the panel).

**Vertical layout (pt from the panel's top).**

| part | Wi-Fi | Battery | Focus | rule |
|---|---|---|---|---|
| header | 0-42, "Wi‑Fi" baseline 26, switch 9..33 | 0-42, "Battery" and "100%" baselines 26 | 0-42, "Focus" baseline 26 | header 42, baseline 26 |
| first line | 42 | (none) | 42 | the line straight under the header |
| state lines | | 42-60, 60-78 (baselines 50.5, 68.5) | | 18 apart, baseline 8.5, no inset |
| list title | 48-70 "Personal Hotspots" (baseline 63.5), 145-167 "Known Network" (160.5), 210-232 "Other Networks" (225.5) | 84-106 "Energy Mode" (99.5), 149-171 "Using Significant Energy" (164.5) | none | 22 tall, 5 under the line, baseline 15.5 |
| rows | 70-102, 102-134 (hotspots), 167-199 (known) | 106-138 "Low Power"; app row 171-193 | 48-240, six of 32 | 32 tall, disc centred, baseline 5.0 under the middle |
| lines | 139, 204, 237 | 78, 143, 198 | 245 | 1 pt; 5 under a list's last row |
| footer | 238-272, baseline 259 | 199-233, baseline 220 | 246-280, baseline 267.3 | 34 under the line, baseline 21 |

The app row ("Ghostty") is 22 tall: its icon 16 x 16 at x 14 (y 174..190), the name's ink from x 38.5 (C: appIcon
style, 16 + 8).

**Horizontal.** Discs **26** at x 14..40 in every row; text ink from x 49 (frame **48**); title, header, footer and line
x **14**; lines 14..294; the switch's right edge 294; the percentage's ink 260..293; the Other Networks chevron's ink
287.5..293 x 216.5..226.5 (5.5 x 10); the lock's ink 283..291.5 x 177..189.5 (8.5 x 12.5); hotspot accessories (signal
bars, "4G", a battery) span 230.5..293.

**Type** (ink widths against SF Pro rendered at 2x, `themes/fonts/SFNS.ttf`): header titles **SF 13 Semibold** ("Wi‑Fi"
32.5 = 13 Semibold 32.5, Bold 33.5; "Focus" 36 = 36.5; was Bold); list titles **SF 12 Semibold** ("Known Network" 91.5,
"Personal Hotspots" 106.5, "Other Networks" 92, "Energy Mode" 75.5, "Using Significant Energy" 143: all exact at 12
Semibold); rows and footers **SF 13 Regular** ("Do Not Disturb" 88.5 / 89, "Low Power" 64 / 64.5, "Driving" 41 / 41,
"Wi‑Fi Settings…" 95 / 96); the state lines **SF 12 Regular** ("Power Source: Power Adapter" 166.5 / 166.5, "Fully
Charged" 76 / 75.5); the percentage SF 13 Regular ("100%" 33 / 33).

**Colours** (vibrant: a constant step over whatever the glass shows). Primary text: black **.85** in light (25,33,38
over 170,220,250: an exact alpha fit), white about **.9** in dark (234,234,246). Secondary (list titles, state lines,
the percentage, chevron, lock, accessories and the glyph in an off disc): about **100 levels under** the glass in light
(186,229,242 -> 85,128,146; 170,222,254 -> 60,117,153: plus-darker) and **70-80 over** it in dark (44,56,192 ->
123,133,255: plus-lighter); hyprk, which cannot read the glass under a text, uses the alpha with the same luminance
(black .5 / white .4). Lines **20 levels under** (light, 213 -> 193 at every line) / **over** (dark, 55 -> 75): black
.1 / white .1. Off discs the same step (light 176,222,252 -> 155,204,235; dark 43,56,188 -> 63,77,212). On disc (the
connected network): the accent, (0,136,255) sRGB, white glyph. The header switch on: the accent, white knob.

**Glyphs in the discs** (ink, pt; hyprk at 13 pt within 0.5): wifi (connected) 14.5 x 10.5; moon.fill 13 x 13;
person.lanyardcard.fill 10.5 x 14; bed.double.fill 16.5 x 11.5; apple.mindfulness 15 x 14; `_gm` (Reduce
Interruptions, DoNotDisturb.framework's private glyph) 15 x 14.5; car.fill 15.5 x 12.5; Low Power's battery 19 x 9.5
(a battery about a quarter full: `battery.25percent`, which ControlCenter references (names.json); not in hyprk's
extracted set, so hyprk draws battery.0percent at 13.5 pt and its level, a quarter of the outline's inside, at 75 % of
the outline's ink: the shot's level reads about three quarters of the outline's step over the disc).
Hotspot rows: a chain-link glyph 16.5 x 11.

**Rows.** Wi-Fi: Personal Hotspots (2), Known Network (1, connected, lock), Other Networks (collapsed), Wi‑Fi
Settings…. Battery: 100 %, Power Source: Power Adapter, Fully Charged, Energy Mode / Low Power, Using Significant
Energy / Ghostty, Battery Settings…. Focus: no list title; Do Not Disturb, Work, Sleep, Mindfulness, Reduce
Interruptions, Driving (none on); Focus Settings…. No disabled row on the shots: a disabled row's dimming stays
**GUESS** (text 45 %, disc 50 %). Hover and a Focus on: round 4 below.

### Round 4 (R4.2): a hovered row, a Focus on

`screens/27.2.1/panels/module-wifi-hover-{row,toggle}-{light,dark}.png` (crop pt 930,25 360 x 254: panel origin px
(46, 10)) and `module-focus-driving-on-{light,dark}.png` (360 x 290), MAC-ANSWERS-4 R4.2.

- **Hovered row** (the row shot minus the toggle shot, which differ only there): a rounded rectangle x **7..301** (7 in
  from the panel's sides, 294 wide), the row's full **32** (135..167 on the Known Network row), every pixel exactly
  **20 under** the glass in light and **20 over** in dark (the lines' step); its corner rows (first lit column 15, 11,
  9, 8, 7, 5, 5, 4, 3, 2, 2, 1, 1, 1 px in from the straight edge) fit a circle of **r 10** within a pixel. hyprk:
  `hoverInset` 7, `hoverRadius` 10, the line colour (black / white .1): its corner 15, 12, 10, 9, 7, 6, 5, 5, 4, 3, 3,
  2, 2, 1. Was GUESS: a capsule 5 in, white .144 / black .06.
- **Hovering the switch** (or the header row): no change anywhere in the header (max 5-8 levels, noise). hyprk: none.
- AX (ControlCenter): rows are AXCheckBox 280 x 32 (x 14..294); "… Settings…" a 22 pt button at x 14 (Wi-Fi at panel y
  211 = line bottom 206 + 5; the panel ends 7 under it): the footer's 5 + 22 + 7 = 34.
- **A Focus on** (Driving, synced from the user's phone; Do Not Disturb not turned on, MAC-ANSWERS-4): the header gets the
  subtitle **"On"** (SF 12 Regular, cap 8.5, secondary) with baseline **34**, the title's baseline moves up to **19**,
  the header stays 42 (line at 42). The active mode's disc is filled with **its colour**, (97,84,244) light /
  (109,124,255) dark = systemIndigo (names.json: light .3804 .3333 .9608, dark .4275 .4863 1), white glyph (car.fill
  15.5 x 12.5 as off). **No line above "Focus Settings…"**: its button starts 4 under the last row (AX y 274 = 270 + 4),
  baseline 20.3 under the row, the panel ends at **273** (280 with none on). hyprk with Do Not Disturb on: the same
  (Do Not Disturb's colour is systemIndigo too). Was GUESS: indigo fill (right), no subtitle, the line kept (wrong).
- The menu bar is above these crops (they start at y 25, the bar ends at 29): the Focus item's glyph with a Focus on is
  not on them; DoNotDisturb.framework gives each mode its glyph for the bar (names.json menubar "Focus: …"). hyprk's
  item shows the moon while Do Not Disturb is on (its only mode).
- "Personal Hotspot" is singular with one hotspot (R: "Personal Hotspot(s)"), as "Known Network".

### Against the Mac (headless session, scale 2, light and dark, `HYPRK_STATUS_STUB=1`)

Side-by-side crops (Mac left, hyprk right, the same margins round the panel): `sbs-{wifi,battery}-{light,dark}.png`,
`sbs-wifi-hover-{light,dark}.png` and `sbs-focus-on-{light,dark}.png` (hyprk's Do Not Disturb on against the Mac's Driving
on) in the session's scratch directory. hyprk on a 1280 x 832 screen with a 34 pt bar: panel top 35 (34 + 1); Wi-Fi 742..1050
under a pill 1009..1051 (right edge 1 in); Battery 967.5.. under a pill 967..1013 (not flipped: 967.5 + 308 < 1280).
Every row, title, line, disc and footer lands on the Mac's y within 0.5 pt (Wi-Fi without its hotspot group: lines 42,
107, 140, height 175; Battery: lines 78, 143, 176, height 211; Focus: lines 42, 245, height 280 = the Mac's). Ink widths
and x within 0.5. Still different:

- the Mac's secondary text and glyphs are vibrant (they take the backdrop's hue: teal-blue over Tahoe Light); hyprk's
  are a neutral grey / white alpha of the same luminance;
- Wi-Fi: no Personal Hotspots group (no data); Battery: no app list (the "No Apps…" label instead), Low Power disabled;
  Focus: five modes disabled; hyprk shows the Focus item only while Do Not Disturb is on, so its Focus module is
  compared with the R4.2 "Focus on" shot: header ("Focus" ink 9.5..19, "On" 25.5..34.5), footer ink 250.5..260.5 and
  the 273 pt height match the Mac's (9..19, 25.5..34, 250.5..260.5, 273);
- the hovered row: the same rectangle, its step 16-26 under the glass (alpha black .1) against the Mac's flat 20;
- the glass's shadow and exact fill are the plugin's menu recipe, not fitted to these shots.

### Left to do (2026-11-14 18:25, next steps)

Done since 17:35: the light and dark re-shoot (lock ink 282.5..291.5 x 12.5 against the Mac's 283..291.5), the hover
and Focus-on looks from R4.2, Low Power's quarter-full glyph, the lines through `Pixel.stroke()` / `soft()`
(SCALING-AUDIT.md R3.3).

1. Vibrant secondary text (list titles, state lines, the percentage, chevron, lock, off glyphs): the Mac's is
   plus-darker 100 / plus-lighter 75 over the glass, so it takes the backdrop's hue; hyprk's is an alpha of the same
   luminance. A QML text cannot read the plugin's glass; it would need the glass estimated from the blurred wallpaper
   (as `shaders/menupill.frag` samples it) through the plugin's menu recipe, or a plugin fill layer for text. The menus
   (`MenuDropdown`) use alpha text too, so they would change together.
2. Fit the panel's shadow: needs a Mac shot of a module over a flat backdrop (none yet).
3. Low Power: wire it to power-profiles-daemon (Quickshell `PowerProfiles`, power-saver) when the daemon is on the bus.
4. Mac requests: a disabled row's look (no Mac module shows one by default: maybe none exists), Do Not Disturb itself on
   (R4.2 used Driving), Wi-Fi off, the menu bar's Focus item with a Focus on.
