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
- **GUESS** none of the above.

There is **no picture** of an open Wi-Fi, Battery or Focus module (`screens/27.2.1/menubar/status-pills-open-blue.png`
shows only the pills). Every row below is from code or resources; vertical sizes are code cross-checked against
the Sound photo where the same parts exist.

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
| list title row | 18 + 5 + 5 = 28 | **S**: "Output" row 64.6 → 92.1 = 27.5 |
| row pitch | 32 | **S** 32 |
| toggle disc | 26 (`FUN_10062ca74`: frame ideal width 26, background + overlay) | **S** 25.5–26 |
| checkmark toggle symbol | 26 × 14 frame, SF 13 semibold | `FUN_10062c914`, font `FUN_1005fe3b4` |
| fonts | a table of `.body` / `.callout` / `.subheadline` / `.footnote` statics (`FUN_1005fe08c…`); which part takes which is not mapped | **S**: titles 13 bold, rows 13 regular (`.body` is 13 on macOS) |
| header switch | `ModuleSwitchToggle` = SwiftUI `SwitchToggleStyle` (`FUN_100608da4`); control size not set there | size **GUESS** |
| header row height, title baseline | not decoded | **GUESS**: 40, baseline 25.5 (**S**: Sound's title) |
| divider | 1 pt line, 14 in | **S**: line 5.5 under the last row, next row 0.5 under it |
| "… Settings…" row | `ModuleStackPreferencesLink` | **S**: 32 row, panel ends 32.6 under the separator |

Placement, **C** `MenuPositionCoordinator` `FUN_1000f0694`: left to right the window's content left edge sits on the
status item's left edge (anchor minX minus the window's shadow inset); if its right edge would pass the screen's,
alignment becomes topTrailing and the right edge sits on the item's right edge. The width is the content's (window
width minus shadow insets) unless a Control Center frame is set (`bentoBoxFrame`, `FUN_1000eede4`: then the grid's
width, the from-the-grid case). Vertical gap under the bar: not decoded, **GUESS** 6 (Control Center's measured top).

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

Not decoded: the disclosure's starting state (**GUESS** collapsed), the status view's glyph names (lock), when the
"searching…" label shows, the off state beyond "lists are empty".

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

Not decoded: the duration format inside "%@ until fully charged", the percentage text's weight and colour.

## 4. Focus

**R** Focus.loctable: "Focus", "Focus Settings…", "FOCUS_MODE_ON" = "On", "FOCUS_MODE_OFF" = "Off".

**C** `FocusModesExpandedView.Body` = ModuleStack { ModuleStackHeader (title + animated optional subtitle Text),
ModuleStackList { ForEach FocusActivityView }, ModuleStackPreferencesLink }; `FUN_10019fc18`: Text("Focus"), the
subtitle from the active activity (`FUN_1001a01c4`, optional), no accessory (`FUN_100630fe4`), the list, then
`SystemPreferences.focus` + "Focus Settings…" (anchor "focusmodes"). `FocusActivityView` = a `ModuleStackList` in a
toggle style whose children are `FocusLifetimeView` = `ModuleStackToggle` (the "for 1 hour" style choices; their
strings are not in ControlCenter's loctables). The modes themselves (Do Not Disturb, Sleep, Personal, Work…) come
from the user's Focus configuration, not ControlCenter.

## 5. What hyprk builds (2026-11-14)

| module | rows built | data | disabled / not built |
|---|---|---|---|
| Wi-Fi | header "Wi‑Fi" + switch; "Known Network(s)" (known or connected, connected first, then by signal); "Other Networks" with a chevron, collapsed until clicked; "Wi‑Fi Settings…" | Quickshell.Networking (scanner on while open); a row joins a known or open network (`connect()`) | an unknown secured network is shown disabled (no password sheet); Personal Hotspots, accessory groups, ⌥ details, lock / hotspot battery accessories not built |
| Battery | header "Battery" + "NN%"; the power source / charge line; "No Apps Using Significant Energy" (disabled); "Battery Settings…" | UPower display device | Charge to Full Now, Service Recommended, Energy Mode, per-app energy: no data on Linux |
| Focus | header "Focus"; "Do Not Disturb" toggle (moon.fill; on: white disc, the mode's colour, Q-panels-02); "Focus Settings…" | `Notifs.dnd` | other modes (hyprk has one), the lifetime drawer, the header subtitle |

The menu bar battery item no longer draws its percentage (Q-menubar-29; the module's header shows it).

Not built: Bluetooth, Sound, Display, Now Playing, Screen Mirroring, Fast User Switching (no status item in hyprk's
bar, and the stock Mac bar shows them only when enabled or active); Text Input (a classic NSMenu, no input-source
list in hyprk).

### Against the Mac (headless session, scale 2, light and dark, stub data `HYPRK_STATUS_STUB=1`)

Wi-Fi with two known networks (light): panel 308 wide from x 728 = the Wi-Fi item's right edge (1036) − 308 (item
left + 308 passes the 1280 pt screen, so it flips: C), top 40 (34 + 6, GUESS), height 210.6. Disc 26 × 26 at 14.5 from
the panel edge (C 14, S 14.5); name ink from 50 (C frame 48, S 49.4); title ink from 15.5 (S 15); disc pitch 32
(C, S 32); list title row 28 (C 28, S 27.5). Battery, with the Focus item shown: its left edge on the battery item's (937.5; 937.5 + 308 < 1280). Control Center and its Sound module open as before. Before this change: Wi-Fi and Focus opened
Control Center, Battery did nothing.
