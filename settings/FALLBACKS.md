# System Settings: unsupported and failure states

Rule: a pane never shows raw command output or errors. When a backend is missing or a
command fails, the pane keeps its normal layout and disables or hides the controls that
can't work, the way macOS does. No explanatory notes, empty-state messages or sublabels that
the Mac does not have (every visible string is a 27.2.1 string).

Commands run through `Backend.run()`. `Backend.status(code)` turns the exit code into
"missing" (127: the binary is missing, or the app runs under the plain `qml` tool, which
has no process support) / "failed" / "ok". Parsers in `Parsers.js` return safe empty values
on any input.

Live updates come from event streams (`controls/EventSource.qml`): `nmcli monitor` (Wi-Fi,
Network), `pw-mon` (Sound), `dbus-monitor` on BlueZ (Bluetooth). When a stream can't run
or stops, the pane falls back to polling every 15 s. A stream dies with Settings, also when
Settings is killed (`Backend.stream` starts it through `setpriv --pdeathsig TERM`; without
setpriv it runs as before).

Settings of the host desktop (`gsettings`, today only "Prefer non-blinking cursor") go through
`Backend.runHost()`: they are written only when hyprk is the login session (`HYPRK_ALLOW_POWER=1`
from `dist/hyprk-session`, the same signal the shell's power actions use). In a nested preview,
a smoke run or a standalone `settings/run.sh` on another desktop only hyprk's own state changes.

| Pane | Condition | What the user sees |
|---|---|---|
| Wi-Fi | `nmcli` missing or NetworkManager not running | Wi-Fi switch off and disabled, Ask to join pop-ups and Advanced… disabled |
| Wi-Fi | no wifi device in `nmcli device` | the pane is not in the sidebar ("Absent hardware" below); opened anyway: Wi-Fi switch off and disabled |
| Wi-Fi | radio on/off or join fails | the switch / list goes back to what nmcli reports |
| Bluetooth | `bluetoothctl` missing or no controller ("No default controller available") | Bluetooth switch off and disabled, device lists hidden, Advanced… disabled |
| Bluetooth | connect / power fails | the row goes back to what bluetoothctl reports |
| Sound | `wpctl` missing or PipeWire down | slider and mute disabled |
| Sound | no sinks | empty device table |
| Sound | `pw-play` missing (alert preview) | choice is still saved to `state/sound.json`, no preview |
| Displays | not in a Hyprland session (`hyprctl` fails or returns no monitors) | placeholder display tile, popups disabled |
| Keyboard | not in Hyprland (`hyprctl eval` fails) | values are saved to `state/input.json` only |
| Notifications | app list script fails | no Application Notifications list; the global switches still work |
| Notifications | an app icon is not in the icon theme | gray tile with a generic glyph |
| Lock Screen | no hypridle/hyprlock | settings are only saved to `state/lock.json` |
| Lock Screen | a stored timeout that is not in the menu | shown as an extra item, e.g. "For 15 min" |
| Displays | Hyprland rejects a mode | the selection goes back to what Hyprland runs |
| Displays (Looks like) | `HYPRK_SCALE_POLICY=off` in the Hyprland session | sizes shown dimmed and disabled, selection = what Hyprland runs |
| Displays (Looks like) | virtual output (MBA, HEADLESS*, WAYLAND-*, X11-*) without `HYPRK_NATIVE_<OUT>` | no size list, disabled Resolution row with the current size |
| Displays (Looks like) | `HYPRK_LOOKS_LIKE` / `HYPRK_LOOKS_LIKE_<OUT>` set (env wins over the saved choice) | sizes disabled, selection = the env size |
| Displays (Looks like) | `config/hypr/scale-policy.lua` report fails (`hyprctl eval` error, file missing) | disabled Resolution row |
| Displays (Looks like) | a saved size in `state/displays.json` that has no clean Hyprland scale | scale-policy.lua ignores it (logged), Default is used and shown |
| Network | `nmcli` missing or no services | the connected-services card and Other Services are hidden; the VPN / Firewall card stays |
| Apple Intelligence & Siri | always (user's choice, 2026-11-14, `Panes.js`) | the pane is not in the sidebar (27.2.1 lists it); `panes/Siri.qml` is unused |
| Battery / Energy | no `Battery` in `/sys/class/power_supply/*/type` | sidebar shows **Energy** instead of **Battery** (macOS desktop behavior) with the desktop rows; battery rows hidden |
| Wallpaper | `themes/wallpapers` empty | no picture sections |
| Wallpaper | no hyprpaper or swaybg | choice is still saved to `state/wallpaper.json` for the shell |
| Wallpaper | thumbnail missing or `magick` missing | full image is decoded instead (slower, same look) |
| Appearance, Dock, Sound | state file missing or corrupt | defaults from `Parsers.js` (`appearanceDefaults`, `dockDefaults`, `soundDefaults`); next change rewrites a clean file |
| Appearance, Dock, Sound | running under `qml` (no processes) | files go through XMLHttpRequest and are polled every 2 s instead of inotify; `run.sh` exports `QML_XHR_ALLOW_FILE_READ/WRITE=1` |

## Absent hardware (the user's choice of 2026-11-15)

The user's words: "wifi kalau ga ada di hidden aja", then "bluetooth dll nya juga begitu yah". What belongs to
hardware this computer does not have is **hidden**, never shown off or disabled, and the rows around it close the gap
(a Column or the sidebar list lays out what is visible). This replaces the "switch off and disabled" rows above for the
case of no device at all; those rows still hold when the device is there and its tool fails.

Detection: `settings/scripts/hardware.sh` (read-only; `Parsers.parseHardware` -> `AppState.hw`), run at start and again
every time the window becomes key, so hardware plugged in while Settings runs (a USB Bluetooth or Wi-Fi dongle, a mouse)
shows its pane the next time the window is clicked, without a restart. Unplugging hides it the same way; the open pane
gives way to the first one in the list. `HYPRK_HW="wifi=0,trackpad=1"` (tests) decides an item whatever the machine has.
Under the plain `qml` tool nothing can be probed: everything is shown.

| Hardware | Detection | Hidden without it |
|---|---|---|
| Wi-Fi adapter | `/sys/class/net/*/wireless` or `phy80211`, or a `wifi` device in `nmcli device` | the Wi-Fi pane in the sidebar; the Wi-Fi row in Network; the Wi-Fi control in Menu Bar |
| Bluetooth adapter | `/sys/class/bluetooth/hci*` | the Bluetooth pane; the Bluetooth control in Menu Bar |
| AirDrop | Wi-Fi and Bluetooth both (the Mac's AirDrop needs both radios) | the AirDrop control in Menu Bar; the AirDrop card of General > AirDrop & Continuity (the row stays: Continuity is more than AirDrop) |
| Battery | a `Battery` in `/sys/class/power_supply` that is not a peripheral's (`scope` Device) | as before: the Battery pane (Energy takes its place), Lock Screen's battery row, the laptop picture in About; now also the Battery control in Menu Bar |
| Trackpad | an input device udev tags `ID_INPUT_TOUCHPAD` (`/run/udev/data`) | the Trackpad pane |
| Mouse | an input device tagged `ID_INPUT_MOUSE` | the Mouse pane |
| Keyboard backlight | `/sys/class/leds/*kbd_backlight*` | Keyboard's three rows: Adjust keyboard brightness in low light, Keyboard brightness, Turn keyboard backlight off after inactivity |
| Ambient light sensor | `/sys/bus/iio/devices/*/in_illuminance*` | Displays' "Automatically adjust brightness" and "True Tone" rows |

Left as they are: Ethernet and VPN rows in Network (a service row is there only when NetworkManager lists the device,
and the Mac keeps VPN and Firewall without hardware); Accessibility > Pointer Control's trackpad rows (they are about
wireless trackpads too); the "Touch ID" wording in two Accessibility texts (there is no Touch ID pane or row to hide).

## Brightness (2026-11-15)

Displays' Brightness slider, Control Center's Display slider, the brightness keys and the HUD are one level, owned by
the shell (`shell/services/Brightness.qml`: a backlight through `brightnessctl`, else external monitors through DDC/CI
VCP 10 with `ddcutil`). Settings is another process: `state/brightness.json` `{ value, available, source, probe }`
carries it both ways, as the other state files do. The shell writes it on every change; the slider shows `value` and a
drag writes it back every 50 ms (`AppState.brightnessThrottle`); opening the pane raises `probe`, which asks the shell
to look at the hardware again (a monitor that slept when the shell started answers DDC now).

| Condition | What the user sees |
|---|---|
| `available` false (no backlight and no monitor answers DDC/CI), or no file (no shell running) | the slider disabled at full, its row dimmed, as the Mac's on a display without brightness control |
| the file not read yet | nothing is written: a write carries `value`, and Settings' default would reach the monitors |
| several DDC monitors | one level for all of them, whichever display is selected in the strip (the Mac has one per display) |

## Several displays (2026-11-15)

The strip shows one thumbnail per Hyprland output (`hyprctl monitors -j`); a nested preview session has one output and
shows one. Two displays of one model are numbered ("N27p (1)", "N27p (2)"). With more than one: a "Use as" row for the
selected display ("Main display" for the one at the layout's origin, "Extended display", "Mirror for <name>"), disabled
because nothing here changes the role, and an "Arrange…" button left of Add that opens a read-only picture of
Hyprland's layout. Neither is on a Mac shot (every capture is of one display): the strings are DisplaysExt's, the
places and the sheet are this copy's.

## Sub-panes and sheets (R12)
Built from the Mac's stills and AX dumps (reference/re/27.2.1/live/settings-r12, MAC-ANSWERS-12.md R12.3). A control is
wired only where a backend already exists; the rest shows the Mac's value and keeps its own state while the pane is
open. A pop-up whose other items are not on a shot shows the Mac's value alone. Buttons, ⓘ and + whose own destination
is not on a shot are drawn and take the press, nothing more (listed in reference/re/27.2.1/SETTINGS-CLICK-AUDIT.md).

| Where | Real | The Mac's value, not stored | Left out |
|---|---|---|---|
| General > About | `settings/scripts/sysinfo.sh`, read-only, once per visit: product name and vendor (`/sys/class/dmi/id`; the vendor stands where the Mac has its model line), host name (`/etc/machine-info` PRETTY_HOSTNAME, else the kernel's), CPU model as `/proc/cpuinfo` has it, installed memory (online memory blocks), system name, release name and number and its icon (`/etc/os-release` NAME, VERSION, LOGO from the icon theme), every connected display (`/sys/class/drm`: EDID name and diagonal, preferred mode), the system volume (`df /`: available of size; its label, else "Macintosh HD" as Finder names `/`). Display Settings… and Storage Settings… navigate (R15.1) | | Name is not editable (the Mac's is a text field). Serial number; Coverage and its Details… sheet (AppleCare, hidden by the user's choice); Intel-Based Apps and its Details… sheet; the legal links and the Regulatory Certification window (Apple's). System Report… takes the press only (the Mac launches System Information). The pictures are the generic display or laptop, a generic display per display row and the sidebar's internal disk |
| General > Software Update | Installed and the up to date line: `/etc/os-release` PRETTY_NAME. Automatic Updates: apt's `APT::Periodic::Unattended-Upgrade` where `/etc/apt/apt.conf.d/*auto-upgrades` has it | Automatic Updates "On" without such a file, Beta Updates "Off" | No update is ever looked up (no package manager runs): opening the sub-pane and Check for Updates show the Mac's checking state (R15.3) for 3 s (`checkTime`; the Mac's took 6 s over the network, under 1 s cached), then always "Your Mac is up to date." (the Mac's sentence, kept). The Automatic Updates sheet's three switches start from the setting and change nothing on the system. Beta Updates ⓘ (an Apple Account sheet) takes the press only. The licence line is the Mac's in US spelling; its link is not enabled, as the Mac's |
| General > Storage | The system volume: `df /` (used = size - available, as the Mac's); per category `settings/scripts/storage.sh` (`du -x` at idle CPU and IO priority, one after another, off the UI thread; kept in `Backend.storageSizes` so a second visit shows the last sizes while it sizes again): Applications (`/opt`, snaps, flatpak, `~/Applications`), Documents (the XDG Documents, Desktop and Downloads folders), Music, Photos (XDG Pictures), Trash, Other Users & Shared (other folders of `/home`; no row without one), the system's row under its own name (`/usr`, `/boot`, `/etc`); System Data is what is left of the used space. Folders on another volume are not counted. The ⓘ sheet lists the folders counted and their sizes | | Recommendations: the Mac's "Store in iCloud" card is drawn as on R15.2's stills, its button takes the press only (no iCloud); the rows of the Mac's own applications (Books, Developer, iCloud Drive, iOS Files, Mail, Messages, Music Creation, Podcasts, TV). Every ⓘ sheet has the Mac's Developer form (470 x 400, Name / Size) without its line of advice and "Manage in …" button; the Applications form (650 x 490, Kind and Last Accessed columns, Show in Finder) is not built; Delete… stays disabled (read-only) and the columns do not sort. The bubble over a hovered part of the bar (121 x 77) is not built. Other Users & Shared is a part of the bar here (the Mac's 3.4 MB shows none). Tiles: the Mac's art is not extracted, they are drawn (dark tile and glyph; the system's grey tile has a display glyph) |
| General > AirDrop & Continuity | | every switch and pop-up | the "iPhone" row (53 pt) |
| General > Date & Time | clock, zone abbreviation, zone city, read-only | the three switches, Source | |
| General > Language & Region | language, region, samples and formats of the session locale, read-only | Calendar, Live Text; Temperature and Measurement follow the locale | |
| General > Login Items | `~/.config/autostart/*.desktop` as "Open at Login", read-only | | Background App Activity, Extensions |
| General > Sharing | local host name | ten service switches, off | the services' 32 pt icons |
| General > Startup Disk | the system (`/etc/os-release`) on "/" | | the disk's picture |
| General > Time Machine | | | the Mac's disk row: the list is empty |
| General > Transfer or Reset | | | |
| Desktop & Dock > Shortcuts…, Hot Corners… | the desktop picture in Hot Corners | the three keys; four corners "-" | |
| Displays > Advanced…, Night Shift… | | all of it | |
| Keyboard > Keyboard Shortcuts… | | Dock's one shortcut | the lists of the other 13 groups; 9 group tiles are plain |
| Keyboard > Input Sources Edit… | | all switches and pop-ups; the source is "U.S." as in the pane | the Mac's second source row |
| Keyboard > Text Replacements… | | the "omw" row | |
| Keyboard > Dictation Languages Edit… | | the Mac's language list (KeyboardData.js) | the entries redacted on the capture; no box is ticked |
| Keyboard > About Ask Siri, Dictation & Privacy… | | Apple's text, en_GB as captured | the "Learn More" button at its end |
| Notifications > Summarize Notifications | `state/notifications.json` summarize | | |
| Notifications > an application | allow, style (Temporary = banners, Persistent = alerts), sounds in `state/notifications.json` | the three places, Badge, Show previews, grouping | |
| Trackpad tabs | | everything (no pointer backend is wired) | the fingers on the outline; the preview is one frame of the Mac's clip (dark capture) |

Text is US spelling as in the rest of the app (the captures are en_GB).

## Sub-panes and sheets (R13: Wi-Fi, Network, VPN, Battery, Menu Bar, Spotlight)
Built from reference/re/27.2.1/live/settings-r13 (MAC-ANSWERS-13.md R13.1, R13.2), same rules as R12. `Backend.qml` has
no backend for any of these settings, so every switch, radio and pop-up below shows the Mac's captured value and keeps
its own state while the pane is open. Real, read-only: what `nmcli` reports.

| Where | Real | The Mac's value, not stored | Left out / differs |
|---|---|---|---|
| Wi-Fi > Details… | network name; Wi-Fi address, IP address, Router (`nmcli device show`) | Automatically join (on), Private Wi-Fi address "Fixed", Low Data mode, Limit IP address tracking (off) | TCP/IP, DNS, WINS, 802.1X, Proxies, Hardware select and show nothing (not on a shot); Forget This Network… takes the press only |
| Wi-Fi > Other… | | Security "WPA2/WPA3 Personal" | no profile is written; OK only closes. Labels: the Mac's (R14.1) |
| Wi-Fi > Advanced… | Wi-Fi MAC address; Known Networks = NetworkManager's saved Wi-Fi connections with their key management | the three switches (off) | heading and labels: the Mac's (R14.1; "authorization" for its en_GB "authorisation"); a row's "…" menu is not on a shot |
| Wi-Fi pane | | Ask to join networks "Ask", Ask to join hotspots "Never" (were Notify / Ask to Join) | |
| Network > Wi-Fi, VPN | the Wi-Fi and VPN panes, pushed inside Network | | |
| Network > Firewall | | on ("Active" on the Network row); Options…: Block all (off), built-in and signed software (on), stealth mode (off) | the application list: see "Round 14" below; the text while it is off is not on a shot: the extension's own string for that state |
| Network > a service | name and state from `nmcli device` | Limit IP address tracking (on) | Delete Service…, Make Inactive and a rename do nothing; the six detail sections are empty |
| Network > More | | Locations > Automatic | a pick closes the menu: Add Service…, the VPN types, Manage Virtual Interfaces…, Set Service Order…, Edit Locations… open sheets that are not on a shot |
| VPN | | | no configurations; the Add menu has the Mac's three rows (R14.1), a pick closes it; About VPNs & Privacy… takes the press only |
| Battery > Options… | | dim on battery (off), prevent sleeping (on), Wake for network access "Always", optimize streaming (off) | the desktop's (Energy) button stays "Schedule…", not on a Mac shot |
| Menu Bar > Clock Options… | | Show date, day of the week (on), Digital, the other switches off, "On the hour", "System Voice" | the shell's clock reads none of it; Voice ⓘ and Customize Voice… take the press only |
| Menu Bar > Battery Options… | | Show Percentage (off), Show Energy Mode "Always" | |
| Spotlight > Files ⓘ, Search Privacy… | | nine file types (on), clipboard history "8 hours" | both lists stay empty: + and "About Search & Privacy…" take the press only |

Pull-down menus (controls/PullDown.qml: Network's More, VPN's Add) open at once and close on a pick without the blink of
the pop-up menus. Their menu is its own popup surface with the liquidglass plugin, else in the window and kept inside it.

## Sub-panes, sheets and pop-ups (R13: Wallpaper, Focus, Lock Screen, Privacy & Security, Keyboard, General, Desktop & Dock, Displays, Sound, Notifications, Trackpad, Appearance)

Built from `reference/re/MAC-ANSWERS-13.md` and `reference/re/27.2.1/live/settings-r13/` (DESTINATIONS.md, popups.json,
`ks-NN-*`, the `-light` stills). `settings/Backend.qml` has no backend for any of the features below, so every control
here keeps the Mac's captured value and its own state while the window is open; nothing is stored or applied.

- **Application lists: no invented names.** The Mac's application lists are blurred on the stills and `[redacted]` in
  the AX dumps of rounds 13 and 14, so Privacy & Security lists no application (the earlier "Safari" / "Terminal" sample
  rows are gone, and with them the per-application rows' controls: the switches, the Files & Folders / Automation
  outline rows and Photos > Options…, whose button belongs to an application's row). A class the Mac shows with
  applications shows what the Mac shows for a class without: its own "… will appear here." line, centred
  (SecurityPrivacyExtension.appex `Localizable.loctable`, en: `*_EMPTY_APP_LIST`); a class with a + / − strip (Full
  Disk Access, App Management, …) shows its line and the strip; Screen & System Audio Recording shows "No Items" in
  both lists. Root rows: "None" under a data class and "0" at the end of the others (the Mac's wording on Calendars
  and Motion & Fitness); Location Services' count (the Mac's own 22) is left out. What stays because the evidence
  names it: Firewall > Options' four Apple entries (R14.2, below), Desktop & Dock's Default web browser "Safari"
  (popups.json), Notifications' list (this computer's own applications). Blocked Contacts
  shows "No Items" (the Mac's one entry is a contact). Focus: "None allowed" and "No Schedules" on every mode (the
  Mac's own people, apps and the Work location are not copied). AppleCare & Warranty: hidden (below).
- **General > AppleCare & Warranty is hidden by the user's choice (2026-11-15)**: no row in General, no sub-pane
  (`panes/general/AppleCare.qml` is deleted), no `general-applecare` icon reference, no Coverage row in About. The
  Mac has the row in a card of its own between [About, Software Update, Storage] and [AirDrop & Continuity]; without
  it the cards after it sit 58 pt higher (its 48 pt card and the 10 pt gap), as on a Mac without the row. Do not add it
  back, also when a later capture round shows it.
- **Location Services > Details…**: the services are redacted on the capture; only the readable row is drawn, at its
  place in the 470 x 533 sheet.
- **Clock Appearance…**: the Mac's popover is its own window and reaches 126 pt past the window's right edge; ours is
  drawn inside the window (HyprK Popover), so it sits further left with its arrow still on the button. The six faces
  are "12" in the system font (the Mac's clock faces are not in the repo).
- **Screen Saver…**: hyprk has no screen savers; the sheet lists the Wallpaper pane's pictures under the Mac's
  layout, a click marks a tile. "Show All (n)" does nothing. The "Start Screen Saver…" pop-up has the Mac's value only.
- **Focus**: the root lists the Mac's six modes (Personal is gone: no still). The row tiles are the Mac's own, cut from its rows
  (R14.3, below). Sleep's Health icon is a white tile with a heart glyph;
  Driving's is the System Settings icon.
- **Row tiles not in `themes/icons/settings`**: General's Device Management and most Keyboard
  Shortcuts groups draw a plain tile. AutoFill & Passwords borrows the Passwords app icon. Privacy & Security's and
  Focus's: R14.3, below.
- **Keyboard Shortcuts…**: all 14 groups with the Mac's rows, keys and check states. Collapsed groups do not open (their
  children are not on a shot); a double-click on the keys does not record. Restore Defaults puts the Mac's states back.
  Modifier Keys names the Mac's keyboard; its pop-ups have the Mac's value only.
- **Pop-up menus** have the Mac's items, checked item and separators (US spelling, as the rest of the app). Items that
  open a panel on the Mac ("Choose Color…" in the two Appearance menus, "Customize…" in Color profile and Dictation
  Shortcut) leave the choice as it was. Not built: Keyboard's Microphone
  source (the Mac's devices), Wallpaper's "Add Photo…" menu button (no photo library). Lock Screen's "Require password"
  did not open on the Mac (disabled there): ours keeps its earlier items. Pop-ups inside the new sub-panes whose menus
  are not on a shot (Report Duration, Allow accessories to connect, Set Up Codes In, Show large clock) have one item.
- **Desktop & Dock**: the Widgets card and Default web browser are drawn with the Mac's values (no desktop widgets, no
  browser list). **Keyboard**: Keyboard brightness and the backlight time-out likewise (no backlight backend).
- **Notifications**: "when mirroring or sharing the display" is the Mac's pop-up on the existing `whenMirroring` state.
- **Sheets, colours**: a Settings sheet is the window's colour with the window's cards, and the window behind it is
  drawn without colour under a grey veil (light #AAAAAA at 60.4 %, dark #141414 at 61 %), measured on the R13.5 light
  and R12 dark stills; with Qt's software renderer (the tests) the veil is there but the colour stays.
- **Trackpad**: the light previews are the same crop of the R13.5 light stills (`assets/trackpad/*-light.png`).

## Round 14 (MAC-ANSWERS-14.md, live/settings-r14)

Strings under the captures' blur, and the American wording of en_GB captures, are read from the extensions' own tables on
the 27.2.1 system volume (`*.appex/Contents/Resources/Localizable.loctable`, table `en`): Accessibility (`hoverText.*`,
`caption.*`, `voiceControl.*`, `switch.deviceAssigment.instruction`), Network (`FIREWALL_*`), Security & Privacy
(`*_EMPTY_APP_LIST`). Nothing else was taken from them.

| Where | Built from the Mac | Differs / left out |
|---|---|---|
| Wi-Fi Other…, Advanced…, Details…; a service's Details…; VPN Add; Network "…" | the labels, section titles and menu items of R14.1 | a pick in the menus closes them; the six detail sections (TCP/IP … Hardware) select and show nothing |
| Firewall placard | on: `FIREWALL_EXPLANATORY_TEXT_LIMITED` (the captured text, American) | off: not captured (R14.1). The line is `FIREWALL_EXPLANATORY_TEXT_OFF` of the same table, not a guess; take it out if only captured text may be shown |
| Firewall > Options… list (R14.2) | rows 460 x 32 (40 with a two-line name), icon 16 x 16 at +10,+4, name at +28, the pop-up right-aligned 10 pt in with a 10 pt green / red dot, a hairline under each row from the name's x, + / − strip | four rows only, the Apple entries R14.2 names (the other 36 are redacted): AirPlayXPCHelper, audioclocksyncd, avconferenced (rows 0-2: their AX widths 108 / 101.5 / 90 pt match the names) and com.apple.WebKit.Networking (the two-line row 6), all "Allow incoming connections" as those rows are. Icons cut from the still: the "exec" tile of row 2 for the first three (rows 0 and 1 are under the blur; R14.2 says one of the helpers shows a globe, not which), the document icon of row 6. The pop-up is 240 pt wide for the Mac's 233.5. No firewall: nothing is stored |
| Privacy & Security and Focus row tiles (R14.3) | 21 + 6 tiles cut from the Mac's rows with their shadow (`themes/icons/tools/cut-row-crops.py` -> `themes/icons/settings/crops/`), light and dark | the Mac was on the **Dark** icon style: these tiles are that style's in every Icon & widget style (the five rows built from Apple's icon configuration and the six application icons still follow the style). Lockdown Mode keeps the pane icon |
| Hover Text ⓘ | sheet 470 x 510 "Hover Text Settings" | the pop-ups have the Mac's value alone; Text size is a field with a stepper; nothing stored. Hover Color's and Hover Typing's ⓘ: not captured |
| Read & Speak > System voice ⓘ | sheet 750 x 450: languages, Voice, Rate, Pitch, Speech Volume, Reset Voice Settings, play, Done | the Mac's sheet is 10 pt wider than the window: here it is cut 5 pt at each side. The language list starts at its fourth row (the first three are under the blur) and shows the 11 rows on the shot. Rows, Voice and play take the press only; Reset puts the captured values back. Pitch's end glyphs are cut from the still (`settings/assets/r14/`) |
| Voice Control "…" | the menu of six items, opening upward | a pick closes it |
| Switch Control list | "+": sheet 265 x 122 "Press your switch now…" with a spinner, Cancel, Done (disabled); "−" and "…" disabled without a selected row | no switch press is taken (what follows one was not captured); rows do not select. The spinner turns once a second like the lock screen's (its speed on the Mac is not measured) |
| Subtitles and Captioning list | "+" makes "Untitled" at once, selects it and opens the editor (600 x 533); Cancel / Escape keep the style; the selected new style has "Edit…" | the editor's rows below Font are not on the shot; pop-ups have the Mac's value alone; the colour swatch sits before the pop-up. The preview strip is the capture's own picture: its left quarter is under the capture's blur. "−" removes a style made here and selects the first one (how the Mac removes one was not captured) |
| Colour wells | the Colors panel: title bar, five mode pictures, wheel, brightness, swatch, eyedropper, 40 wells; the open well has the accent ring | the Mac's panel is a floating window of its own, 266 x 430; here it is drawn inside the Settings window at its left and moves within it (a second window of the app's class would be caught by the session's window rules and by the minimize / zoom dispatchers). Dark look only (the light panel is not on a shot). Title "Colors" (the Mac adds the host's name). Only the wheel and the brightness work: the four other modes, the eyedropper and the wells take the press only. Window buttons grey as on the capture; the first closes the panel |
| Zoom's combo | the list 158 x 64 under the field, the current key highlighted | |
| Displays "+" (R14.5) | menu button 61 x 24 at 659,171; "Mirror or extend to" (disabled), a row with a display glyph per display | the rows are the session's other outputs (the Mac's two devices are redacted); glyph and text insets in a row are not readable under the blur (11 and 33 pt here); a pick closes the menu, nothing is mirrored. Without the liquidglass plugin the menu is kept inside the window |
| Sound > Output / Input table (R14.5) | header 28 pt on a faint fill, 24 pt rows, one per device, Name / Type insets | the Type is "Built-in", "HDMI" or "Bluetooth" from the node's name (the Mac also has "Continuity Camera", "Virtual", "AirPlay", "Aggregate device") |
| Sound > Input | "Input volume" (the default source, `wpctl`), "Input level" with 15 bars | no level meter: the bars stay unlit. The microphone glyphs are cut from the still (no such symbol in the decoded set) |

## Help
There is no help viewer. A pane's "Learn more…" link and its "?" button open the same macOS User Guide topic the
Mac opens (book `com.apple.machelp`), in the guide's web edition:
`https://support.apple.com/guide/mac-help/<anchor>/mac`, through `Qt.openUrlExternally`. Anchors come from the Mac's
AX dumps (links) and from the extensions' binaries ("?"); a "?" whose anchor is not decoded does nothing
(reference/re/27.2.1/SETTINGS-CLICK-AUDIT.md).

## Accessibility

The pane and its 22 sub-panes are the Mac's (macOS 27.2.1, reference/re/MAC-ANSWERS-12.md R12.1: rows, groups, labels,
control types, defaults and footers from `re/27.2.1/live/settings-r12/ax-acc-*.jsonl`, looks from the `acc-*` stills).
A control with a hyprk backend is wired to it; every other control keeps the Mac's default and takes input, and nothing
is stored. Display flags live in `state/appearance.json` (`reduceTransparency`, `increaseContrast`, `reduceMotion`), the
rest in `state/accessibility.json` (`panes/accessibility/A11y.js`). Each change also writes `state/accessibility.lua`
(+ `state/a11y-screen.frag`) and runs it with `hyprctl eval`; `shell/services/A11y.qml` runs the same file at login and
after every Hyprland reload.

Wired:

| Sub-pane | Control | Backend | Limit |
|---|---|---|---|
| Display | Reduce transparency | Settings + shell themes (opaque fills) | on and locked while Increase contrast is on |
| Display | Increase contrast | Settings theme, Hyprland window borders; shell via `A11y.increaseContrast` | |
| Display | Invert colors, Invert colors mode, Display contrast, Color filters, Filter type, Intensity | Hyprland `decoration:screen_shader` = `config/hypr/shaders/a11y-filter.frag` with #defines | screencopy (grim, screen sharing) skips screen shaders; Intensity starts at the state's 0.8, the Mac's at the maximum |
| Display | Pointer size | `hyprctl setcursor` + `XCURSOR_SIZE` / `HYPRCURSOR_SIZE` for new apps | |
| Display | Differentiate without color | saved only | no reader |
| Motion | Reduce motion | Settings controls, Hyprland (no window zoom, Spaces cross-fade), shell via `A11y.ms()` | |
| Motion | Auto-play animated images | saved only | no reader |
| Motion | Prefer non-blinking cursor | `gsettings org.gnome.desktop.interface cursor-blink` | written only in the hyprk session (`Backend.runHost`) |
| Zoom | Use keyboard shortcuts, Use scroll gesture, Zoom style | Hyprland `cursor:zoom_factor` (`scripts/a11y-zoom.sh`) | Split Screen / Picture-in-Picture zoom the full screen |
| VoiceOver | the switch, Open VoiceOver Utility… | Orca (`scripts/a11y-orca.sh`, stops only the Orca it started; `orca -s`) | without `orca` the switch keeps its own state |
| Read & Speak | Speak selection | speech-dispatcher `spd-say` (`scripts/a11y-speak.sh`), primary selection via `wl-paste -p` | saved even without `spd-say` |
| Read & Speak | Speak announcements | saved only | no reader |
| Audio | Flash the screen, Play stereo audio as mono | saved only | no reader |
| Subtitles and Captioning | Prefer closed captions and SDH | saved only | no reader |
| Keyboard, Switch Control | Keyboard Settings… | opens the Keyboard pane | |
| Audio | Sound Settings… | opens the Sound pane | |

Not wired (the Mac's default, input taken, nothing stored): everything else in the 22 sub-panes, and the whole of Hover
Text, Audio Descriptions, Voice Control, Keyboard, Pointer Control, Switch Control, Hearing Devices, RTT, Live Captions,
Name Recognition, Live Speech, Personal Voice, Vocal Shortcuts, Siri and Shortcut. What the small controls open is built
where round 14 captured it ("Round 14" below). The rest do nothing, their destination is on no shot: 16 of the 18
"Show Detail" ⓘ buttons, Advanced…, Choose…, Choose Display…, Set Up, Panel Editor…, the timing sheets, Commands…,
Vocabulary…, Add Category…, Customize …, Trackpad / Mouse Options…, Siri Settings…, Open VoiceOver Tutorial…, Text size
and Live Speech's category rows.
Read & Speak's speaking rate and Play Sample, and Live Speech's type-to-speak field, are gone: they are not on the Mac's
sub-panes (the rate is behind System voice's ⓘ).

Differences from the Mac's stills that are deliberate or open:

| What | Ours | Why |
|---|---|---|
| Spelling | American ("Color", "Customize") | the stills are from a Mac set to British English; the rest of Settings uses the American loctable strings |
| Voice Control / Live Captions "Language" | "English (United States)" | same |
| Voice Control "Microphone" | "Automatic" | the Mac names its own microphone |
| Audio: the group of the AirPods connected to that Mac | absent | a device of that Mac (its heading is redacted) |
| Display "Text size" value | "Custom" | what the capture shows; the Mac's own default is not known |
| RTT tile (pane row and placard) | a plain green tile | the row's graphic icon is not extracted (`themes/icons/tools/build-graphic.py` needs its plist entry) |
| Live Speech > Saved | no symbol | `bookmark` is not in the decoded SF Symbols set |
| Live Speech placard text | "Click the icon in the menu bar" | the Mac draws a keyboard glyph inline (its AX text says "icon"); that line sits 2.5 pt higher here |
| Placard and row tiles | the Icon & widget style of hyprk | the Mac was on the Dark style |
| Color Filters pencils, captions preview | cut from the stills (`settings/assets/accessibility/`) | the pictures' sources are not extracted; the preview always shows the first style |
| Hyprland not reachable | values are saved and applied at the next login | |

## Sidebar glass

Under Hyprland the sidebar is a light warm fill at 88 % alpha over the compositor blur
(decoration.blur in config/hypr), so the desktop only softly shows through, like the
reference (238,236,234). Elsewhere (GNOME, plain `qml`) and with Reduce transparency it
is the same colour, opaque.

## Assets

| Asset | Preferred | Fallback |
|---|---|---|
| UI font | `themes/fonts/SFNS.ttf` loaded with FontLoader (weights through the `wght` axis) | Inter, then Cantarell, then Noto Sans (`Theme.pickFont`) |
| Glyphs in rows and the toolbar | SF Symbols outlines in `ui/HyprK/sfpaths.js` (drawn by HyprK `SfSymbol`, which the shared controls use too; add names with `ui/scripts/sfpaths.py`) | none: a name that is not in the table draws nothing |
| Pane icons | `themes/icons/settings/<pane id>@<64\|128>-<default\|dark\|clear\|tinted>-<light\|dark>.png` (all 23 panes, picked by the icon style and appearance) | a plain coloured rounded tile |
| Row icons | `themes/icons/settings/<id>@48-...png`: the Mac's 24 pt row icon at 2x, built from Apple's graphic icon configuration of that row (`Panes.js` rowIcons, `themes/icons/settings/graphic.json`) | a plain coloured rounded tile |
| Wallpaper thumbnails | freedesktop `~/.cache/thumbnails/large` (made by `scripts/thumbs.sh`) | the full image |

## Files written for other parts of hyprk

They go to `$HYPRK_STATE` (`Backend.stateDir`, set once by `config/hypr/start.sh`/`run.sh`: `<root>/state` if writable, else `~/.local/state/hyprk`; plain `qml` has no env and uses `<root>/state`).

`appearance.json`: `mode` is light / dark / auto and `dark` is what is shown now. With Auto, `dark` is the sun's
answer (dark while the sun is below -3 degrees at the system time zone's city, `Parsers.js` autoDark: the rule of
macOS 27.2.1 without Location Services); Settings sets it when it starts, when Auto is chosen and at each crossing
while it runs. Nothing changes it while Settings is closed. `highlight` is the text highlight colour ("" = Automatic).

Settings writes these; the readers belong to the shell/config agents. As of this commit
`appearance.json`, `dock.json`, `sound.json` and `wallpaper.json` have readers or are
planned; `displays.json` is read by `config/hypr/scale-policy.lua` (Hyprland start and hotplug); **`notifications.json`, `lock.json` and `input.json` have no reader yet**, so those
panes only store the choice until the shell (notification server, hypridle glue, login
config) reads them.

Text field menu (HyprK `TextMenu`: search field): with the liquidglass plugin (HYPRK_GLASS=plugin,
`popup_classes` lists org.hyprk.Settings in config/hypr/hyprland.lua) the plugin draws the menu glass behind it and the
menu draws no fill; without the plugin, or with Reduce Transparency / Increase Contrast, the opaque menu fill and stroke.
Pop-up button menus (HyprK `Popup`, every pane): the same rule. With the plugin the menu is its own popup surface (it may
leave the window) on the plugin's `menu` glass and fade; a press-drag-release then does not choose (the surface takes
the pointer), the menu stays up as after a click. Without it the in-window menu, flat 249 / (63,64,70) with its rim and
shadow, which keeps press-drag-release and may be cut at the window's edge.
Sidebar under the search field: rows scrolled under the field show through it blurred and faint; with Reduce
Transparency the field shows none of them (they are cut out under it either way).
Zoom (toolbar double-click, Option-click on the green light): Hyprland's maximized mode; outside Hyprland the xdg request.

## Lines at a fractional scale

Card row separators and the scroll-edge hairline are whole device pixels (`HyprK Pixel.line`, `Tokens.dpr` bound to
the window's ratio in `shell.qml`): 1 pt = 2 px at 1.6 in every row, 0.5 pt = 1 px (they drew 2 px and 1 px in the same
pane before, `reference/re/27.2.1/SCALING-AUDIT.md`). Under the plain `qml` tool (no window ratio): the screen's ratio.
