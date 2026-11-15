# Answers from the Mac session, round 14 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #174 from the PC. Capture only. Files under `re/27.2.1/live/settings-r14/` (`INDEX.md` there). Window 740x625 pt
at 350,150 on 1440x932, 2x; sheet and control frames below are **screen points** (subtract 350,150 for window-relative).

**One side effect, reverted.** In Accessibility > Subtitles and Captioning the list "+" does not just open a sheet: it
**creates a new style at once ("Untitled") and makes it the active style**, then opens the editor; Escape/Cancel closes
the editor but keeps the style. Two runs left "Untitled" and "Untitled 2" with "Untitled 2" active. Both were removed
again and the active style is back to **Transparent Background** (checked in the pane: four built-in styles, first one
selected). Nothing else was changed.

## R14.1 Labels that were scrubbed but are not personal
- **Wi-Fi > Other…** (sheet 400x325 at 520,300): title "Add a Wi‑Fi Network Profile" (588,330), text "Enter the name and
  security type of the profile you want to add." Rows: "Network Name" + text field (640,397 250x16); "Security" +
  pop-up "WPA2/WPA3 Personal" (709,430 181x24); "Password" + secure text field (608,472 282x16); "Show password" +
  switch (854,510 36x16). Buttons "Cancel" 760,581 66x24 and "OK" 834,581 66x24 (OK disabled until a name is typed).
- **Wi-Fi > Advanced…** (sheet 470x532 at 485,202; scroll area 470x467): heading "Require administrator authorisation
  to" with switch rows "Change networks" and "Turn Wi‑Fi on or off"; switch row "Show legacy networks and options";
  row "Wi‑Fi MAC address" with the address right-aligned; heading "Known Networks"; a table 430 pt wide with sortable
  headers "Network Name" (192 pt) and "Security Type" (194 pt) plus a 44 pt column; rows 24 pt: lock glyph 9x12 for
  secured networks, name, security text ("WPA2 Personal", "WPA3 Personal", "None", …), and a "…" menu button 21x15 at
  the right of each row. "Done" 871,690 64x24 below the scroll area.
- **Wi-Fi pane texts** behind them: "Set up Wi‑Fi to wirelessly connect your Mac to the internet. Turn on Wi‑Fi, then
  choose a network to join. Learn More…"; section headings "Personal Hotspots", "Known Network", "Other Networks";
  "Ask to join networks": "Known networks will be joined automatically. If no known networks are available, you will be
  asked before joining a new network."; "Ask to join hotspots": "Allow this Mac to automatically discover nearby
  personal hotspots when no Wi‑Fi network is available."; buttons "Details…", "Other…", "Advanced…".
- **Wi-Fi > Details…** (670x425): right side rows "Automatically join this network"; "Private Wi-Fi address" (pop-up
  "Fixed"): "Using a private address helps reduce tracking of your Mac by Wi-Fi network operators. A fixed private
  address allows this network to track this Mac, but helps reduce tracking across other networks."; "Wi‑Fi address";
  "Low Data mode": "Low Data mode helps reduce your Mac data usage over specific Wi‑Fi networks you select."; "Limit IP
  address tracking": "Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari.";
  "IP address"; "Router"; buttons "Forget This Network…", "Cancel", "OK".
- **Section titles of a network service's Details sheet** (left list 200 pt wide; first row 48 pt with the service name
  and its status, then 32 pt rows): **TCP/IP, DNS, WINS, 802.1X, Proxies, Hardware**. Same six for Wi-Fi and for the
  Ethernet-type services. An Ethernet service's first page: "Name" + text field, "Limit IP address tracking" + switch
  with the description above; the service pane itself has "Delete Service…", "Make Inactive" and Help.
- **Firewall description**: on = "The firewall is turned on and set up to prevent unauthorised applications, programs
  and services from accepting incoming connections." **The off text was not captured**: the firewall is on here and
  switching it off would change a setting.
- **VPN "Add" menu** (AXMenuButton "Add" 61x24, identifier `plus`; menu 142x82 opens below it): "L2TP over IPSec…",
  "Cisco IPSec…", "IKEv2…".
- **Network "…" menu** (AXMenuButton 62x24): "Add Service…", "Add VPN Configuration ▸" (submenu: "L2TP over IPSec…",
  "Cisco IPSec…", "IKEv2…"), separator, "Manage Virtual Interfaces…", "Set Service Order…", separator, "Locations ▸"
  (submenu: separator, "✓ Automatic", separators, "Edit Locations…").

## R14.2 Firewall > Options: app list layout
- Sheet 500x532 at 470,202. Top: switch row "Block all incoming connections" + description "Blocks all incoming
  connections except those required for basic internet services, such as DHCP and IPSec." The list: scroll area
  **460 pt wide** starting 96 pt below the sheet top, inside the sheet's own scroll area (the whole sheet content
  scrolls; 40 rows here).
- **Row: 460x32 pt.** Icon **16x16** at row x+10, y+4; name (13 pt regular) at x+28, y+4; pop-up **233.5x24** right
  aligned 10 pt from the row's right edge, at y+4, value "Allow incoming connections" (green dot) or "Block incoming
  connections" (red dot). Long names wrap to two lines inside the same 32 pt row. A hairline separator runs under
  each row, starting at the name's x (not under the icon). Below the list: "+" 9.5x9.5 and "−" buttons at the list's bottom-left.
- Apple helper tools in the list have **no app icon**: the 16x16 slot shows the generic black "exec" tile (one
  shows a small globe). Example rows with Apple-only entries (names as shown): `AirPlayXPCHelper`, `audioclocksyncd`,
  `avconferenced`, `com.apple.WebKit.Networking`; third-party rows look the same with their app icon.
- After the list: switch rows "Automatically allow built-in software to receive incoming connections",
  "Automatically allow downloaded signed software to receive incoming connections" (+ "Allows software signed by a
  valid certificate authority to provide services accessed from the network."), and the stealth-mode switch with
  "Don’t respond to or acknowledge attempts to access this computer from the network by test applications using ICMP,
  such as Ping." Buttons "Cancel" 810,690 and "OK" 884,690 (66x24) under the scroll area.
- Still (names blurred): `settings-r13/dest-network--firewall--options-{dark,light}.png`.

## R14.3 Row tile icons: done (crops)
- `icon-privacyAndSecurity-<row>-{dark,light}.png` (33) and `icon-focus-<row>-{dark,light}.png` (6): **80x80 px crops
  (40x40 pt)** of the left end of each row, centred on the row. Contact sheets: `icons-privacyAndSecurity-{dark,light}.png`,
  `icons-focus-{dark,light}.png` (9 per line, in pane order).
- The tile is a **rounded square about 20 pt** with a dark fill in both modes for Privacy rows (glyph in colour: blue
  arrow, orange home, green running figure, red record ring…), Calendar/Contacts/Files/Photos/Home use their app-style
  artwork. Focus rows use the same dark tile with the Focus glyph in its colour (moon, car, flower, bed, badge). The crops also catch the first pixels of the row label at the right edge. SF Symbol names are not exposed by AX
  for these rows (only the row label), so crops are given instead.

## R14.4 Accessibility: what the small controls open
One still each (dark), background outside the window and its child windows masked grey:
- **ⓘ** (AXButton "Show Detail" 17x17, identifiers `….infoButton`): a **sheet**. `acc-hover-text--info-dark.png`
  (Hover Text Settings, 470x510) and `acc-read-speak--voice-info-dark.png` (voice list + sliders, **750x450, wider than
  the window**).
- **"…"**: Voice Control's "…" is an **AXMenuButton 61.5x24 → menu** 223x165 opening upward from the button:
  "Import Vocabulary…", "Export Vocabulary…", "Delete All Vocabulary…", separator, "Import Custom Commands…", "Export
  Custom Commands…", "Delete All Custom Commands…" (`acc-voice-control--options-menu-dark.png`). Switch Control's
  list "…" (AXButton 11.5x11.5) is **disabled** until a switch row is selected; pressing it opened nothing
  (`acc-switch-control--ellipsis-dark.png` shows the list footer with +, −, …).
- **List +/−**: Switch Control "+" → small **sheet 265x122** "Press your switch now…" with Cancel / Done
  (`acc-switch-control--add-dark.png`, cancelled). Subtitles and Captioning "+" → **sheet 600x533** with a preview
  strip on top, "Style name" field, Background / Text groups of pop-ups each with an "Allow video to override"
  checkbox, Cancel / OK (`acc-captions--add-dark.png`); see the side effect note at the top.
- **Colour well** (AXColorWell 48x24, Display > Pointer outline colour): opens the **system Colours panel**, a separate
  floating window 266x430 (not a popover, not attached to the window; it appeared at the screen's left).
  `acc-display--colour-well-dark.png`. Closed with its close button; colour unchanged (read back).
- **Zoom's combo** (AXComboBox 150x24, "Modifier key for scroll gesture", value "⌃ Control", arrow button 23.5x17.5
  at its right): the arrow opens a **list 158x64 directly under the field** with "⌃ Control", "⌥ Option", "⌘ Command"
  (current one highlighted). `acc-zoom--combo-dark.png`. Escape closes it; value unchanged.

## R14.5 Displays "+" menu and Sound > Input list
- **Displays "+"**: AXMenuButton "Add" 61x24 at 1009,321 (identifier `plus`), menu **175x82** opening below it, left
  edge 5 pt left of the button: a disabled header item "Mirror or extend to" (24 pt), then one 24 pt item per
  available device (two here, each with a display glyph), then a separator. Still with the device names blurred:
  `settings-r13/pop-displayAndBrightness-00-dark.png`.
- **Sound > Input** (`sound-input-dark.png`, names blurred): tabs "Output" / "Input" (AXTabGroup 448x24, two 224 pt
  AXTabButtons); table 468 pt wide: header 28 pt with sortable "Name" (296 pt) and "Type" (172 pt), rows **24 pt**
  (name at x+10, type text at column x+12: "Built-in", "Continuity Camera", "Virtual"), selected row highlighted;
  three rows here, table area 100.5 pt tall. Below: "Input volume" row (mic glyphs 13.5 pt at both ends, slider
  205.5 pt) and "Input level" (a row of 15 level bars instead of a slider). Help button bottom right. Switching the
  tab is view state only; it was put back to Output.

## Restored and checked
System Settings quit, wallpaper store copied back, Stage Manager on, desktop icons back, dark mode, display 1710x1107.
Caption styles reverted as described at the top.
