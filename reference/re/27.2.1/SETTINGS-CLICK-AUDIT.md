# System Settings click audit, macOS 27.2.1 (26B131) against settings/

2026-11-15. What the Mac makes interactive in each pane, and whether ours responds. Mac side: the AX dumps
`reference/re/27.2.1/live/settings/panes/ax-<pane>-light.jsonl` (R3.8b; every AXButton, AXPopUpButton, AXMenuButton,
AXCheckBox, AXRadioButton, AXSlider and AXLink right of the sidebar) and the stills
`reference/screens/27.2.1/settings/panes/`. Binaries: the 27.2.1 system volume (`141-12228-174.dmg`, apfs-fuse
read-only, unmounted after), `strings` on `System Settings.app` and the `/System/Library/ExtensionKit/Extensions/*.appex`
executables (static: names and literals, nothing was run).

`MAC-ANSWERS-12.md` (R12: Accessibility sub-panes, the push transition, navigating rows per pane) did not exist at the
start or at the end of this pass. Nothing in the repo shows a pushed sub-pane, a sheet or a navigating row's
destination, so no destination was built here; those rows are listed under "Needs the Mac".

Evidence keys: **AX** = the pane's AX dump; **S** = a still; **B** = a string or symbol in a 27.2.1 binary;
**none** = nothing in the repo.

## Sub-pane chrome

| question | Mac | source | kind |
|---|---|---|---|
| what a sub-pane is | a view pushed on the pane's SwiftUI `NavigationStack` (rows are `NavigationLink(value:)`, destinations `navigationDestination(for:)`) | B AccessibilitySettingsExtension: `NavigationStack.init(path:root:)`, `NavigationLink ... value:label:`, `navigationDestination(for:destination:)`, `GroupedFormNavigationLinkButtonStyle`, `_panelNavigationPath`, `popNavigationStack` | observed symbols |
| where the title goes | the window toolbar: the pushed view's `navigationTitle` replaces the pane's title, inline, right of the back/forward capsule | B the extension calls `View.navigationTitle`; System Settings.app has `navigationTitleOverride` ("{ extensionIdentity, newNavigationTitleOverride }" log lines), `ToolbarTitleDisplayMode.inline`, `toolbar(removing: .title)` | inferred from symbols; no still of a pushed sub-pane |
| in-content back link or title | none found: no back-link view or string in either binary; the only Back strings are the toolbar's "Go Back" / "Go Forward" / "Back" / "Forward" | B settings-en.json (System Settings.app loctable), AX `Go Back` / `Go Forward` | bounded negative search |
| back/forward capsule | one history for panes and sub-panes: pushing a sub-pane appends an item, Go Back returns to the pane's root, Go Forward re-pushes it; Go Forward is disabled at the end of the history | B System Settings.app `SettingsNavigationHistoryManager`, `SettingsNavigationHistoryItem`, `appendItemToHistory(_:)`, `_canGoBack` / `_canGoForward`, `ExtensionHistoryNavigationControls`, `requestNavigationPathsFromHistory(_:)`; AX every pane: Go Back enabled, Go Forward (AXMenuButton) disabled | observed symbols, inferred behaviour |
| the open pane's sidebar row | pops the sub-pane | B System Settings.app `_listSelectionAutomaticallyClearsNavigationStackPath` | inferred |
| hold on Back / Forward | a history menu after about 0.5 s; rows carry a pane icon | S controls/hold-shine-settings-{light,dark}.mov (only the menu's top edge is in frame), MAC-ANSWERS-7 R7.1; B "Navigation History", `SettingsNavigationEventRecord(icon:title:navigationPathComponents:...)` | observed; the menu's rows are not on a shot |
| push transition, row press look | none: a hard cut. Content and toolbar title change in one frame, forward and back; with the mouse the row is lit for about 0.1 s first (dark: the card 31 -> 43 of 255, about white 5 %), then the cut | R12.2 push-accessibility-voiceover-{light,dark}.mov (light: frames 1.167 / 3.383 s; dark: 1.233 / 3.450 s) | observed |

Ours before: the toolbar kept "Accessibility"; the content began with a row holding a blue "‹ Accessibility" link and a
centred bold title; the link was the only way back (Go Back left the pane).

Checked against R12 (reference/re/MAC-ANSWERS-12.md R12.1, R12.2; 22 sub-panes, light and dark): the rows above marked
"inferred from symbols" hold. Capsule: AX 240,8 73 x 36; its drawn edge is px 479..627 x 15..89 on acc-voiceover-00-light.png
and on ours (239.5,7.5 to 313.5,44.5 pt). Go Back is an enabled AXButton in a sub-pane, Go Forward disabled until a Go
Back. Title: one AXStaticText 317,0 411 x 52, left-aligned after the capsule; its ink starts at 325.5 pt on the Mac and
at 327 on ours, corrected to 325.5 (margin 13 -> 11.5; the same on the top pane). The sidebar keeps Accessibility
selected. Added from R12.2: the navigating row is lit while pressed. Not on R12: the open pane's sidebar row popping,
and the root's scroll offset after a pop (both stay as inferred).

Ours after (settings/SettingsApp.qml, shared by every pane): a pane with sub-panes exposes `page` and `pageTitle`; the
window keeps one history of `{ pane, sub-pane }`; the toolbar title is the sub-pane's; Go Back / Go Forward (and ⌘[ / ⌘])
walk panes and sub-panes; the pane's sidebar row pops; `AppState.navigate(pane, sub)` opens a sub-pane from another
pane. The in-content row is gone (settings/panes/Accessibility.qml). No transition is drawn. Popping shows the root at
the offset it was left at (the root stays in the stack; not measured on the Mac). Test: settings/tests/tst_nav.qml.

## Audit

"dead" = the item is drawn and the Mac makes it interactive, but a click does nothing. "ok" = it responds (a control
that only holds its value locally counts as responding). "absent" = the Mac's item is not in our pane (layout audits:
SETTINGS-UI-AUDIT.md), not counted.

| pane | item | Mac behaviour | ours before | ours after | evidence |
|---|---|---|---|---|---|
| window | Go Back / Go Forward click | walk the navigation history | ok for panes; sub-panes not in the history | ok, sub-panes included | B, AX |
| window | Go Back / Go Forward hold | history menu | dead | dead | S hold-shine-settings (top edge only) |
| window | sidebar pane rows, search field | open the pane; filter | ok | ok; the open pane's row pops its sub-pane | AX, B |
| window | Apple Account row | opens the account pane | dead | dead | AX (row blanked on every still) |
| window | Family row | opens Family | dead | dead | AX (blanked) |
| Wi‑Fi | Wi‑Fi switch | toggles | ok | ok | AX wifi-power |
| Wi‑Fi | "Learn More…" | help topic mchlp1180 | dead | opens the topic | AX `help:anchor=mchlp1180` |
| Wi‑Fi | current network "Details…" | sheet | dead | dead | AX; none for the sheet |
| Wi‑Fi | network rows | join (the Mac shows Connect on hover; ⓘ "Show Detail" per known network) | ok (click joins); ⓘ absent | same | AX |
| Wi‑Fi | "Other…" | sheet | absent | absent | AX |
| Wi‑Fi | Ask to join networks / hotspots pop-ups | menu | ok | ok | AX |
| Wi‑Fi | "Advanced…" | sheet | dead | dead | AX; none |
| Wi‑Fi | Help | help topic mh11935 | dead | opens the topic | B Wi-Fi.appex `mh11935` ("Wi-Fi settings on Mac") |
| Bluetooth | Bluetooth switch | toggles | ok | ok | AX |
| Bluetooth | "Learn more…" | help topic blth1004 | dead | opens the topic | AX `help:anchor=blth1004` |
| Bluetooth | device rows | ⓘ "Show Detail" per device (Connect on hover) | Connect / Disconnect button ok; ⓘ absent | same | AX |
| Bluetooth | "Advanced…" | not on this Mac's dump (the binary has `AdvancedOptionsView`) | dead | dead | B; none for the sheet |
| Bluetooth | Help | help topic | dead | dead | anchor not decoded |
| Network | Wi‑Fi service row | opens the Wi‑Fi pane | dead | opens Wi‑Fi (in the history) | AX `Wi-Fi;wifi`; B Network.appex `com.apple.wifi-settings-extension` |
| Network | VPN row | opens VPN | dead | opens VPN | AX; B Network.appex `com.apple.NetworkExtensionSettingsUI.NESettingsUIExtension` |
| Network | Firewall row | sub-pane | dead | dead | AX; none |
| Network | Ethernet and other service rows | sub-pane | dead | dead | AX; none |
| Network | "…" (More) | pull-down menu | dead | dead | AX `ellipsis` AXMenuButton; items not on a shot |
| Network | Help | help topic | dead | dead | several anchors in the binary, not told apart |
| VPN | configuration rows (ⓘ, switch) | detail sheet, connect | absent (no configurations) | absent | AX |
| VPN | "Add VPN Configuration…" (Mac: "+" AXMenuButton "Add") | menu of VPN types | dead | dead | AX; items not on a shot |
| VPN | "About VPNs & Privacy…" | privacy sheet | absent | absent | AX |
| VPN | Help | help topic | dead | dead | anchor cut off in the binary (`mchlp157…`) |
| Battery / Energy | Low Power Mode pop-up | menu | ok | ok | AX low_power_mode |
| Battery / Energy | Battery Health ⓘ, charging ⓘ | popover | absent | absent | AX |
| Battery / Energy | "Schedule…" (Mac laptop: "Options…") | sheet | dead | dead | AX options; none |
| Battery / Energy | Help | help topic | dead | dead | anchor not found |
| General | About, Software Update, Storage, AirDrop & Continuity, Date & Time, Language & Region, Login Items & Extensions, Sharing, Startup Disk, Time Machine, Transfer or Reset (11 rows) | each pushes its sub-pane | dead (11) | dead (11) | AX `com.apple.systempreferences.general.*`; no still or AX of any sub-pane |
| General | AppleCare & Warranty, AutoFill & Passwords, Device Management | push | absent | absent | AX |
| Accessibility | "Learn more…" | help topic mh35884 | opened settings/FALLBACKS.md | opens the topic | AX `help:anchor=mh35884` |
| Accessibility | 22 feature rows | push the feature's sub-pane (a cut; the row lit while pressed) | opened the page under an in-content header | pushed: toolbar title, Go Back; all 22 in the Mac's order (RTT added, its tile a plain green one) | AX `AX_FEATURE_*` (ax-accessibility-00-light.jsonl); R12.1, R12.2 |
| Accessibility | the sub-panes' own content | per feature | 9 built from Linux backends, 12 show the feature's row with a disabled switch | all 22 rebuilt from the Mac's rows, groups, labels, controls and defaults at the AX frames (settings/panes/accessibility/); a control with no hyprk backend keeps the Mac's default and takes input (settings/FALLBACKS.md "Accessibility"). Still dead: the 18 "Show Detail" ⓘ buttons, the "…" buttons that open sheets or apps (Advanced…, Choose Display…, Choose…, Set Up, Panel Editor…, Switch Timing…, Navigation Timing…, Commands…, Vocabulary…, Options…, Add Category…, Customize …, Trackpad / Mouse Options…, Siri Settings…, Open VoiceOver Tutorial…), the list + / − buttons, the colour wells, Zoom's combo box menu, Text size and Live Speech category rows | R12.1 ax-acc-*.jsonl, acc-*-{light,dark}.png |
| Accessibility | Help | help topic | dead | dead | 11 anchors in the binary, not told apart |
| Appearance | Light / Dark / Auto, Liquid Glass slider and its two end buttons, 9 colour dots, highlight pop-up, 4 icon styles, Always / Auto, folder colour pop-up, sidebar icon size pop-up, tint switch, 5 scroll radios | select / menu | ok | ok | AX |
| Appearance | "More in Accessibility Settings…" | opens Accessibility > Display | dead | pushes Accessibility > Display | B Appearance.appex `x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Seeing_Display` |
| Appearance | Help | help topic | dead | dead | anchor cut off (`mchlp122…`) |
| Menu Bar | auto-hide pop-up, background switch, recents pop-up, suggestions switch | menu / toggle | ok | ok | AX |
| Menu Bar | "Add Controls…" | Control Gallery | dead | dead | AX; none |
| Menu Bar | "Clock Options…", "Battery Options…" | sheets | dead | dead | AX; none |
| Menu Bar | control checkboxes and their pop-ups (off while unchecked) | toggle / menu | ok | ok | AX controlcenter-*-id |
| Menu Bar | 15 "Allow in the Menu Bar" switches | toggle | absent | absent | AX |
| Menu Bar | "Reset Control Center…" | confirmation | dead | dead | AX; none |
| Menu Bar | Help | help topic | dead | dead | anchor cut off (`mchlad96…`) |
| Desktop & Dock | 2 sliders, 9 pop-ups, switches, 4 checkboxes | adjust / menu / toggle | ok (widget and browser rows absent) | ok | AX |
| Desktop & Dock | "Shortcuts…", "Hot Corners…" | sheets | dead | dead | AX; B the Shortcuts sheet links to Keyboard settings; none for the sheets |
| Desktop & Dock | Help | help topic | dead | dead | anchor cut off (`mchlp111…`) |
| Displays | display thumbnail, 5 resolution tiles, brightness slider, 2 switches, colour profile and TV pop-ups | select / adjust / menu | ok | ok | AX |
| Displays | "Advanced…", "Night Shift…" | sheets | dead | dead | AX; none |
| Displays | Help | help topic mh40768 | dead | opens the topic | B DisplaysExt.appex `mh40768` ("Displays settings on Mac") |
| Spotlight | switches (Related Content, Improve Search, 5 result kinds, Clipboard) | toggle | ok | ok | AX |
| Spotlight | "About Search & Privacy…" (2 links) | privacy sheet | dead | dead | AX; none |
| Spotlight | "Reset Quick Keys…", "Delete Search History…", "Clear Clipboard History" | confirmation / action | dead | dead | AX; none |
| Spotlight | Files ⓘ, clipboard duration pop-up | popover / menu | absent | absent | AX |
| Spotlight | "Search Privacy…" | sheet | dead | dead | AX; none |
| Spotlight | Help | help topic | dead | dead | anchor cut off (`mchl54d9…`) |
| Wallpaper | fill pop-up, Show on all Spaces, Show All, tiles | menu / toggle / expand / apply | ok | ok | AX |
| Wallpaper | "Screen Saver…", "Clock Appearance…" | sheets | dead | dead | AX; none |
| Wallpaper | Help | help topic | absent | absent | AX |
| Notifications | "Learn more…" | help topic mchl205da693 | dead | opens the topic | AX |
| Notifications | Show previews pop-up, sleeping / locked switches | menu / toggle | ok | ok | AX |
| Notifications | when mirroring (Mac: pop-up), Summarize (Mac: row into its sub-pane) | menu / push | ok as switches | same | AX; the pop-up's items and the sub-pane are not on a shot |
| Notifications | "Allow notifications from iPhone" | push | absent | absent | AX |
| Notifications | app rows | push the app's sub-pane | ok as an inline Off / Banners / Alerts pop-up (not the Mac's control) | same | AX; none for the sub-pane |
| Notifications | Help | help topic mh40583 | dead | opens the topic | B NotificationsSettings.appex `mh40583` ("Notifications settings") |
| Sound | alert pop-ups, play button, sliders, 3 switches, Output / Input, device rows, mute, balance | all respond | ok | ok | AX |
| Sound | Help | help topic | dead | dead | anchor cut off (`mchl9777…`) |
| Focus | Do Not Disturb, Sleep, Personal, Work rows | push the mode's sub-pane | dead (4) | dead (4) | AX; none |
| Focus | "Add Focus…" | sheet | dead | dead | AX; none |
| Focus | Share across devices | toggle | ok | ok | AX |
| Focus | Focus status row | push | dead | dead | AX; none |
| Focus | Help | help topic | dead | dead | anchor not found |
| Lock Screen | 3 pop-ups, switches, 2 radios | menu / toggle | ok | ok | AX |
| Lock Screen | "Set…" | text sheet (enabled with its switch) | dead | dead | AX; none |
| Lock Screen | "Accessibility Options…" | sheet | dead | dead | AX; none |
| Lock Screen | Help | help topic mh11784 | dead | opens the topic | B LockScreen.appex `mh11784` ("Change Lock Screen settings on Mac") |
| Privacy & Security | "Learn more…" | help topic mchl0b8771e8 | dead | opens the topic | AX |
| Privacy & Security | Location Services; Calendars, Contacts, Files & Folders, Photos; Camera, Microphone, Screen & System Audio Recording (8 rows) | each pushes its app list | dead (8) | dead (8) | AX `*_Navigator`; none |
| Privacy & Security | the Mac's other 21 classes, Accessories, Background Security Improvements | push | absent | absent | AX |
| Privacy & Security | Allow applications from | menu | ok | ok | AX |
| Privacy & Security | FileVault, Lockdown Mode | push | dead (2) | dead (2) | AX; none |
| Privacy & Security | "Advanced…" | sheet | dead | dead | AX; none |
| Privacy & Security | Help | help topic | dead | dead | 4 anchors in the binary, not told apart |
| Keyboard | 2 sliders, switches, 🌐 key pop-up | adjust / toggle / menu | ok (brightness slider, backlight and shortcut pop-ups absent) | ok | AX |
| Keyboard | "Keyboard Shortcuts…", Input Sources "Edit…", "Text Replacements…" | sheets | dead (3) | dead (3) | AX; none |
| Keyboard | Dictation "Edit…", microphone and shortcut pop-ups, "About Ask Siri, Dictation & Privacy…" | sheet / menu | absent | absent | AX |
| Keyboard | "Set Up Keyboard…" | Keyboard Setup Assistant | dead | dead | AX; none |
| Keyboard | Help | help topic | dead | dead | anchor not found |
| Mouse | sliders, switch, pop-up | adjust | ok | ok | no Mac capture (no mouse on the Mac) |
| Mouse | "Advanced…" | sheet | dead | dead | none |
| Mouse | Help | help topic mh29222 | dead | opens the topic | B MouseExtension.appex `mh29222` ("Mouse settings") |
| Trackpad | 2 sliders, switches, 2 pop-ups | adjust / toggle / menu | ok | ok | AX |
| Trackpad | Point & Click / Scroll & Zoom / More Gestures tabs | switch the tab | absent (two cards instead) | absent | AX TabGroup; SETTINGS-UI-AUDIT |
| Trackpad | "Set Up Bluetooth Trackpad…" | Bluetooth Setup Assistant | dead | dead | AX; none |
| Trackpad | Help | help topic | dead | dead | anchor cut off (`mchlp122…`) |

Count of drawn, dead items (rows counted singly): **89 before, 77 after**. Made to respond (12): Wi‑Fi Learn More
and Help, Bluetooth Learn more, Network Wi‑Fi and VPN rows, Appearance "More in Accessibility Settings…", Displays
Help, Notifications Learn more and Help, Lock Screen Help, Privacy Learn more, Mouse Help. Also changed, not counted as
dead before: Accessibility's rows (now a real push, 22 with RTT) and its Learn more link (now the Mac's topic).

Help topics: the Mac opens its help viewer on the book `com.apple.machelp`; ours opens the same anchor in the guide's
web edition (`https://support.apple.com/guide/mac-help/<anchor>/mac`; each anchor answered 200 with the matching topic
title on 2026-11-15). A fallback, noted in settings/FALLBACKS.md "Help".

## R12 pass (2026-11-15): destinations from the round 12 captures

Evidence: `MAC-ANSWERS-12.md` R12.3, `live/settings-r12/NAV-ROWS.md`, the stills `nav-<pane>--<target>-dark.png` and
their AX dumps. Built: 11 General sub-panes, 9 sheets, 2 Notifications sub-panes, the Trackpad tabs. Tests:
`settings/tests/tst_destinations.qml` clicks each row or button and checks the destination and a sample of positions.

| pane | item | Mac | ours before | ours after |
|---|---|---|---|---|
| General | About, Software Update, Storage, AirDrop & Continuity, Date & Time, Language & Region, Login Items & Extensions, Sharing, Startup Disk, Time Machine, Transfer or Reset (11) | push | dead (11) | each pushes its sub-pane (`panes/general/`): toolbar title, Go Back |
| General | AppleCare & Warranty, AutoFill & Passwords, Device Management | push (stills exist; AppleCare is a web view with no AX content) | absent | absent: the three row tiles are not extracted |
| Desktop & Dock | Shortcuts… | sheet 470 x 326 | dead | sheet |
| Desktop & Dock | Hot Corners… | sheet 630 x 193 | dead | sheet |
| Displays | Advanced… | sheet 470 x 432 | dead | sheet |
| Displays | Night Shift… | sheet 470 x 331 | dead | sheet |
| Keyboard | Keyboard Shortcuts… | sheet 670 x 468 | dead | sheet; the group rows select, only Dock's list is on a shot |
| Keyboard | Input Sources Edit… | sheet 640 x 509 | dead | sheet |
| Keyboard | Text Replacements… | sheet 470 x 182 | dead | sheet |
| Keyboard | Dictation Languages Edit…, Shortcut pop-up, About Ask Siri, Dictation & Privacy… | sheet 420 x 403, menu, sheet 482 x 550 at y 52 (OK only, no Escape) | absent | rows added; both sheets open |
| Keyboard | Microphone source | pop-up of the Mac's devices | absent | absent |
| Notifications | Summarize notifications | row into its sub-pane | a switch | row with the value, pushes "Summarize Notifications" |
| Notifications | app rows | push the app's sub-pane | inline pop-up | push the sub-pane (allow, alert style and sounds stored) |
| Notifications | Allow notifications from iPhone | push | absent | absent: the sub-pane lists the Mac's phone apps (redacted) |
| Trackpad | Point & Click / Scroll & Zoom / More Gestures | tabs, content swaps in place | absent (two cards) | tab bar with the three contents |
| Appearance, Sound | | no sheet or sub-pane (R12.3) | ok | ok |

Count of the drawn, dead items of the audit above: **77 before, 59 after** (General 11, Desktop & Dock 2, Displays 2,
Keyboard 3). Still dead (59): window 3, Wi-Fi 2, Bluetooth 2, Network 4, VPN 2, Battery 2, Accessibility Help,
Appearance Help, Menu Bar 5, Desktop & Dock Help, Spotlight 7, Wallpaper 2, Sound Help, Focus 7, Lock Screen 2,
Privacy & Security 12, Keyboard 2 (Set Up Keyboard…, Help), Mouse Advanced…, Trackpad 2.

The new destinations hold controls of their own whose targets are on no shot. They are drawn as the Mac draws them and
take the press only (43): About System Report…; Software Update 2 ⓘ, Help; Storage Help; AirDrop & Continuity Manage…,
About AirDrop & Privacy…, Notifications & Live Activities, Set…, Help; Date & Time Set…, Help; Language & Region 2 "+",
Translation Languages…, Help; Login Items "+", Help; Sharing 10 ⓘ, Edit…, Help; Startup Disk Restart…, Help; Time
Machine "+", Options…, Help; Transfer or Reset 2 buttons, Help; an application's Help; Keyboard "See how your data is
managed…", the "+" of Input Sources and Text Replacements; Night Shift Help.

Positions against the Mac's AX frames (window pt, ours minus the Mac's, label tops): Date & Time rows -1.0 .. +2.0;
Sharing -0.5 .. +1.0; AirDrop & Continuity 0 .. +1.8 above the left-out iPhone row; Language & Region -1.0 .. +2.0;
Time Machine, Transfer or Reset, Login Items, Startup Disk 0 .. -1.0; an application's sub-pane -0.4 .. +1.5; Trackpad
tabs -0.5 .. +1.0; sheets: Shortcuts… within 1, Night Shift… -0.1 .. -0.9, Advanced… +0.8 .. +2.5, Input Sources
0 .. +3.4, Keyboard Shortcuts, Text Replacements and the privacy sheet 0; x differences 0 for labels. Sheets sit at
the Mac's y (centre rounded down).

## R13 pass A (2026-11-15): Wi-Fi, Bluetooth, Network, VPN, Battery, Menu Bar, Spotlight, Accessibility

Evidence: `MAC-ANSWERS-13.md` R13.1, R13.2; `live/settings-r13/DESTINATIONS.md`, `popups.json`, the stills
`dest-<name>-{dark,light}.png` and their AX dumps. Test: `settings/tests/tst_destinations_r13.qml` clicks each row or
button, checks the sub-pane or the sheet's frame, a sample of positions, and opens every pop-up.

| pane | item | Mac | ours before | ours after |
|---|---|---|---|---|
| Wi-Fi | Details… | sheet 670 x 425 at 35,100 | dead | sheet (controls/DetailSheet.qml) |
| Wi-Fi | Other… | sheet 400 x 325 at 170,150 | absent | button and sheet |
| Wi-Fi | Advanced… | sheet 470 x 532 at 135,52 | dead | sheet |
| Wi-Fi | Ask to join networks / hotspots | pop-ups (items not captured: R13.2 left Wi-Fi out) | ok, Notify / Ask to Join | ok, the Mac's values Ask / Never |
| Bluetooth | Advanced…, Help | not in round 13 | dead (2) | dead (2) |
| Network | Wi-Fi row | sub-pane "Wi-Fi" | opened the Wi-Fi pane | pushes it inside Network |
| Network | VPN row | sub-pane "VPN" | opened the VPN pane | pushes it inside Network |
| Network | Firewall row | sub-pane; Options… sheet 500 x 532 at 120,52 | dead | sub-pane and sheet |
| Network | service rows | sub-pane; Details… sheet 670 x 425 | dead | sub-pane and sheet |
| Network | "…" (More) | pull-down: Add Service…, Add VPN Configuration ▸ (3), —, Manage Virtual Interfaces…, Set Service Order…, —, Locations ▸ (✓ Automatic, —, Edit Locations…) | dead | the menu with both submenus (controls/PullDown.qml) |
| Network | Help | help topic | dead | dead |
| VPN | Add | "+" menu button (menu not opened on the Mac) | dead (a wrong "Add VPN Configuration…" button) | "+" pull-down with the three VPN types |
| VPN | About VPNs & Privacy… | sheet, not captured | absent | drawn, takes the press |
| VPN | Help | help topic | dead | dead |
| Battery | Options… | sheet 470 x 347 at 135,139 | dead ("Schedule…") | "Options…" and the sheet on a laptop |
| Battery | Low Power Mode | Never ✓ · Always · Only on Battery · Only on Power Adapter | ok | ok (the same items) |
| Battery | Help | help topic | dead | dead |
| Menu Bar | Clock Options… | sheet 470 x 533 at 135,52 | dead | sheet |
| Menu Bar | Battery Options… | sheet 470 x 210 at 135,207 | dead | sheet |
| Menu Bar | Recent documents pop-up | None · 5 · ✓ 10 · 15 · 20 · 30 · 50 | 5 items | the 7 items |
| Menu Bar | auto-hide, Always Show / Show When Active pop-ups | as popups.json | ok | ok (the same items) |
| Menu Bar | Add Controls…, Reset Control Center…, Help | not captured | dead (3) | dead (3) |
| Spotlight | Files ⓘ | sheet 500 x 533 at 120,52 | absent | 13 pt button and sheet |
| Spotlight | Search Privacy… | sheet 470 x 375 at 135,125 | dead | sheet |
| Spotlight | Clipboard history pop-up | 30 minutes · ✓ 8 hours · 7 days | absent | row and pop-up |
| Spotlight | About Search & Privacy… (2), Reset Quick Keys…, Delete Search History…, Clear Clipboard History, Help | not captured | dead (6) | dead (6) |
| Accessibility | ⓘ, "…" buttons, list + / −, colour wells, Zoom's combo menu | round 13 has no Accessibility destination | dead | dead |
| Accessibility | a disabled radio that is on | grey (229 on 247 light, 53 on 37 dark, acc-display-00) | accent at half strength | grey (HyprK Checkbox) |
| every pane | Help button | 24 pt (48 px disc on acc-zoom-00-{dark,light}.png; AX 24 x 24) | 22 pt | 24 pt |

Count of the drawn, dead items of the first audit in these panes: **25 before, 15 after** (Wi-Fi 2 -> 0, Bluetooth
2 -> 2, Network 4 -> 1, VPN 2 -> 1, Battery 2 -> 1, Accessibility 1 -> 1, Menu Bar 5 -> 3, Spotlight 7 -> 6).

Built: 5 sub-pane kinds (Network's Wi-Fi, VPN, Firewall, a service; one file serves every service), 10 sheets
(Wi-Fi 3, Firewall Options…, a service's Details…, Battery Options…, Clock Options…, Battery Options…, Files ⓘ, Search
Privacy…), 2 pull-down menus, and the items of 9 pop-ups checked against popups.json.

Controls inside the new destinations whose own target is on no shot take the press only: Wi-Fi Forget This Network…,
a known network's "…", the six detail sections; Network More's eight leaf items, Delete Service…, Make Inactive, a
service's Help, Firewall's list + ; VPN About VPNs & Privacy… and the Add menu's three rows; Clock Options' Voice ⓘ
and Customize Voice…; Spotlight's two "+" and the sheet's About Search & Privacy….

Positions against the Mac's AX frames (window pt, ours minus the Mac's, label tops; x differences 0): Wi-Fi Details…
list 0, cards +0.8 .. +3.5 (the scrolled last card +5 .. +6); Other… +0.4 .. +2.4; Advanced… -0.1 .. +3.9; Firewall
0, its Options… +0.4 .. +1; a service 0, its Details… +0.8 .. +2; Battery Options… +0.5 .. +0.8; Clock Options…
0 .. +3.5; Menu Bar Battery Options… -0.1 .. +0.9; Files ⓘ -0.1 .. -1.4; Search Privacy… 0 .. +1; every sheet's frame
and buttons 0. The drift is one cause: a one-row card is 36.5 pt on the Mac and 37.5 / 38 here. The firewall pop-up
is 240.3 pt wide for the Mac's 233.5 (the text runs wider).

Needs the Mac: the firewall placard's text while it is off; the six detail sections (TCP/IP … Hardware); the targets
of More's items; VPN's Add menu and About VPNs & Privacy…; a known network's "…" menu and the Wi-Fi pop-ups' items
(left out for privacy); the unblurred labels of Wi-Fi Other… and Advanced…; Battery Health's ⓘ; Add Controls…; the
menus of Wake for network access, Show Energy Mode, Interval and Voice; every Accessibility ⓘ / "…" destination;
Bluetooth's ⓘ and Advanced….

### Needs the Mac (R12 follow-up)

1. Stills + AX of every destination NAV-ROWS.md lists and round 12 did not open: Wi-Fi Details… / Other… / Advanced…;
   Network Firewall, an interface row, the More menu; VPN Add menu, About VPNs & Privacy…; Battery Options…; Menu Bar Add
   Controls… / Clock Options… / Battery Options… / Reset Control Centre…; Spotlight Reset Quick Keys… / Delete Search
   History… / Info / Search Privacy… / About Search & Privacy; Wallpaper Screen Saver… / Clock Appearance… / the Picture
   menu; Focus a mode, Add Focus…, Focus status; Lock Screen Set… / Accessibility Options…; every Privacy & Security row
   and Advanced…; Displays' Built-in Display tile; Mouse Advanced… (needs a mouse).
2. The second-level targets above (43), first: Sharing's ⓘ sheets, Time Machine Options…, Translation Languages…,
   Date & Time Set…, AirDrop's Manage… and Notifications & Live Activities, "See how your data is managed…".
3. Open pop-up menus (items): Hot Corners' actions, the three Shortcuts… keys, Night Shift Schedule, AirDrop, Allow
   AirPlay for, Region / Calendar / First day of week / Date format / Number format, Spelling and the two quote
   pop-ups, an application's Show previews and Notification grouping, the four More Gestures pop-ups, Dictation
   Shortcut, Notifications' mirroring pop-up.
4. Keyboard Shortcuts…: the list of each of the other 13 groups; the top three sidebar rows without the blur; the
   group tiles (Mission Control, Windows, Screenshots, Presenter Overlay, Services, App Shortcuts, Function Keys,
   Modifier Keys, Input Sources).
5. Assets: row tiles of AppleCare & Warranty, AutoFill & Passwords, Device Management; Sharing's service icons; the
   startup disk's picture; the macOS icon of About; the Trackpad previews as clips, light and dark.
6. Light stills of all of round 12's sheets and sub-panes (dark only so far); Software Update at rest (not checking);
   Time Machine with no disk; the Input Sources sidebar without the blur.

## R13 pass B (2026-11-15): Wallpaper, Focus, Lock Screen, Privacy & Security, Keyboard, General, Desktop & Dock, Displays, Sound, Notifications, Trackpad, Appearance (and Mouse)

Evidence: `MAC-ANSWERS-13.md` R13.1 - R13.5, `live/settings-r13/` (DESTINATIONS.md, POPUPS.md / popups.json, `dest-*`,
`ks-NN-*`, `nav-*-light`). Built: 43 sub-panes (Focus 7, Privacy & Security 33, General 3), 7 sheets (Wallpaper Screen
Saver…; Lock Screen Accessibility Options…; Privacy & Security Advanced…, Location Services Details…, Photos Options…,
View Ad Targeting Information…) and the Wallpaper popover. Test: `settings/tests/tst_r13.qml` (103 cases) opens every
one with the mouse, opens every pop-up's menu and selects each of the 14 Keyboard Shortcuts groups.

| pane | item | Mac | ours before | ours after |
|---|---|---|---|---|
| Wallpaper | Screen Saver… | sheet 500 x 548 at y 52 | dead | sheet (the pane's pictures as tiles; nothing stored) |
| Wallpaper | Clock Appearance… | popover under the button, 404 x 161 bubble | dead | popover (inside the window; the Mac's leaves it by 126 pt) |
| Wallpaper | fill pop-up | 5 items | "Centre Image" | the Mac's 5 items ("Center") |
| Focus | Do Not Disturb, Sleep, Personal, Work rows | the Mac lists Do Not Disturb, Driving, Mindfulness, Reduce Interruptions, Sleep, Work; each pushes | dead (4) | the Mac's six, each pushes its sub-pane (`panes/focus/Mode.qml`) |
| Focus | Focus status | push "Focus Status" | dead | pushes (`panes/focus/Status.qml`) |
| Focus | Add Focus… | sheet, not opened on the Mac | dead | dead |
| Focus | Help | help topic | dead | dead (anchor not found) |
| Lock Screen | Accessibility Options… | sheet 470 x 479 at y 73 | dead | sheet |
| Lock Screen | Set… | text sheet; disabled on the Mac's capture | dead | dead |
| Lock Screen | 2 display-off pop-ups | 13 items, Never last | 9 items, Never first | the Mac's 13 |
| Privacy & Security | Location Services; Calendars, Contacts, Files & Folders, Photos; Camera, Microphone, Screen & System Audio Recording (8) | push | dead (8) | push |
| Privacy & Security | the other 21 classes, Accessories, Background Security Improvements (23) | push | absent | present, push |
| Privacy & Security | FileVault, Lockdown Mode | push | dead (2) | push |
| Privacy & Security | Advanced… | sheet 470 x 199 | dead | sheet |
| Privacy & Security | Location Services > Details…, Photos > Options…, Apple Advertising > View Ad Targeting Information… | sheets 470 x 533, 470 x 260, 500 x 400 | absent | sheets |
| Privacy & Security | Help | help topic | dead | dead (4 anchors, not told apart) |
| Keyboard | Keyboard Shortcuts… groups | 14 groups | only Dock's list | all 14 with the Mac's rows, keys and states |
| Keyboard | Keyboard brightness, backlight time-out | slider, pop-up (6 items) | absent | present |
| Keyboard | 🌐 key and Dictation Shortcut pop-ups | 4 and 7 items with separators | 4 (other wording), 1 | the Mac's |
| Keyboard | Microphone source | pop-up of the Mac's devices | absent | absent |
| Keyboard | Set Up Keyboard…, Help | assistant, help topic | dead (2) | dead (2) |
| General | AppleCare & Warranty, AutoFill & Passwords, Device Management | push | absent | present, push (`panes/general/`) |
| Desktop & Dock | double-click and Prefer tabs pop-ups | Fill / Zoom / Minimise / — / No Action; Never / Always / In Full Screen | other items and order | the Mac's |
| Desktop & Dock | Widgets card, Default web browser | checkboxes, 2 pop-ups | absent | present |
| Desktop & Dock | Help | help topic | dead | dead |
| Displays | Colour profile, When connected to TV | 11 items with a separator and Customise…; 4 items | 3 and 3 | the Mac's |
| Displays | "+" menu | the Mac's displays | absent | absent |
| Sound | Play sound effects through | a separator after the first item | none | separator |
| Sound | Help | help topic | dead | dead |
| Notifications | when mirroring or sharing the display | pop-up, 2 items | a switch | the pop-up, same state |
| Trackpad | Look up, Secondary click pop-ups | Off first, the Mac's wording | other order | the Mac's |
| Trackpad | Set Up Bluetooth Trackpad…, Help | assistant, help topic | dead (2) | dead (2) |
| Appearance | Text highlight colour, Folder colour | end in a separator and Choose Colour… | 9 items | 10 items; the last leaves the choice |
| Appearance | Help | help topic | dead | dead |
| Mouse | Advanced… | no capture (no mouse on the Mac) | dead | dead |

Count of the drawn, dead items of the audit above, these panes only: **31 before, 12 after**. Still dead (12): Focus
Add Focus… and Help, Lock Screen Set…, Privacy & Security Help, Keyboard Set Up Keyboard… and Help, Trackpad Set Up
Bluetooth Trackpad… and Help, Appearance / Desktop & Dock / Sound Help, Mouse Advanced….

Second-level controls drawn as the Mac draws them that take the press only: the 43 of the R12 pass are unchanged
(their targets are not in round 13 either). The new destinations add 32: Focus modes' Allowed People, Allowed Apps,
Add Schedule…, Add Filter…, Delete Focus…, Help; Focus Status' Learn more… and Help; Privacy & Security's list + / −,
the Files & Folders / Automation rows, Location Services Help, Photos Reset, Sensitive Content Warning's two Learn
more…, About Device Analytics & Privacy…, About Apple Advertising & Privacy…, About Apple Intelligence & Privacy…,
Export Activity, FileVault Show, Background Security Improvements' Learn more…, Lockdown Mode's Learn more… and Turn
On…, Advanced…'s Help; AppleCare's device row, Open Passwords, Device Management Sign In…, + / − and Help; Keyboard
Shortcuts' collapsed groups, key fields and App Shortcuts + / −; Screen Saver's Show All.

Pop-up buttons: 27 of the Mac's 29 in these panes have the Mac's items, checked item and separators (not built:
Displays "+", Keyboard Microphone source; Wallpaper's menu button belongs to "Your Photos", which is not here).

Positions against the Mac's AX frames (window pt, ours minus the Mac's, label tops): Privacy & Security root -2.0 .. 0
down to y 1823; Camera, Photos, Calendars 0 .. -0.5; Analytics & Improvements 0; Focus root 0 .. +2.0; Do Not Disturb,
Sleep, Driving 0 .. -1.0 (No Focus filters -2.5); Focus Status 0 .. -0.2; General root rows 0 .. +2.5 (the two last cards); AutoFill & Passwords 0;
Keyboard Shortcuts' first rows within 1.5 (y) and 1 (x) in all 14 groups; sheets at the Mac's x, y and size, Done at the Mac's place;
Accessibility Options' switches within 2; the popover's faces at the Mac's y, its x shifted to stay in the window.

Light mode (R13.5): the round 12 sub-panes have the Mac's flat colours (#FFFFFF, #F7F7F7, label #262626). Fixed:
the window behind a sheet (was 20 % black: cards #C6C6C6, blue controls; the Mac: cards #C9C9C9, text #767676, no
colour), the sheet sidebar (#F7F7F7 -> #E7E8E9; dark #292A36 -> #232636), the dark sheet's fill (#22232F -> the
window's #1E1F24), Keyboard Shortcuts' row stripes, the Trackpad outline (#262626 -> #B9B9B9) and its previews (the
dark frames were shown in light).

### Needs the Mac (R13 follow-up, these panes)

1. Unblurred or named: the Location Services Details… services, the Photos Options… first radio, the six clock faces.
2. Open menus: Show large clock, Start Screen Saver…, Report Duration, Allow accessories to connect, Set Up Codes In,
   Require password (with iPhone Mirroring off), the five Modifier Keys menus, a Keyboard Shortcuts group expanded.
3. Sheets not opened in round 13: Add Focus…, Add Schedule…, Add Filter…, Allowed People / Apps, Lock Screen Set…,
   Set Up Keyboard…, About … & Privacy… (three), Software Update at rest, the AirPlay iPhone row in a neutral state.
4. Assets: the row tiles of Privacy & Security (24), FileVault, Accessories, Background Security Improvements,
   Lockdown Mode, AppleCare & Warranty, Device Management, the Keyboard Shortcuts groups, the Health tile.
5. Help anchors: Focus, Privacy & Security, Keyboard, Trackpad, Appearance, Desktop & Dock, Sound.

## R14 pass (2026-11-15): round 14 follow-ups and the guesses of the R13 passes

Evidence: `MAC-ANSWERS-14.md` R14.1 - R14.5, `live/settings-r14/` (row crops, `acc-*-dark.png`, `sound-input-dark.png`),
the round 13 dumps it points at, and, for text under the captures' blur and for American wording, the extensions' own
`Localizable.loctable` (table `en`) on the 27.2.1 system volume (`141-12228-174.dmg`, apfs-fuse read-only, unmounted
after; static). Test: `settings/tests/tst_r14.qml` (45 cases) opens each destination with the mouse.

Guesses of the R13 passes, and what became of them:

| where | the guess | now |
|---|---|---|
| Wi-Fi > Other… | "Password", "Show password" named from their widths | the Mac's labels (R14.1): they were right |
| Wi-Fi > Advanced… | heading and four labels named from widths and the extension's strings | the Mac's (R14.1); the heading lost its colon ("Require administrator authorization to") |
| a service's Details… | six section titles | the Mac's for Wi-Fi and Ethernet-type services (R14.1): unchanged |
| VPN Add menu | rows taken from More > Add VPN Configuration | the Mac's own menu (R14.1): the same three |
| Firewall, off | no text | the extension's string for the off state (`FIREWALL_EXPLANATORY_TEXT_OFF`); still not on a shot |
| Firewall > Options… list | three made-up rows (Finder, Terminal, Music), no icons | the Mac's layout with the four Apple entries R14.2 names |
| Privacy & Security lists | "Safari", "Terminal" in every list, counts of those lists | no application; the Mac's own line or "No Items" for an empty class, "None" / "0" on the root |
| Photos > Options… | first radio named "Full Access" | gone with the application rows (its button is a row's) |
| Focus row tiles | the symbol in a colour, no tile | the Mac's tiles (R14.3) |
| Privacy & Security row tiles | 21 plain tiles | the Mac's tiles (R14.3) |

Kept, because the evidence names it: "No VPN configurations" (VPN.appex), Default web browser "Safari" (popups.json),
the Wi-Fi pop-ups' items (WiFiSettingsKit loctable). Still open from the R13 passes (not in round 14): Location Services
Details… services, the six clock faces, the pop-ups with one item, the collapsed Keyboard Shortcuts groups.

| pane | item | Mac | ours before | ours after |
|---|---|---|---|---|
| Accessibility | Hover Text ⓘ | sheet 470 x 510 "Hover Text Settings" | dead | sheet |
| Accessibility | Read & Speak > System voice ⓘ | sheet 750 x 450 (wider than the window) | dead | sheet, cut 5 pt at each side |
| Accessibility | the other 16 ⓘ | not opened in round 14 | dead (16) | dead (16) |
| Accessibility | Voice Control "…" | menu 223 x 165, six items, opening upward | dead | menu (controls/PullDown.qml) |
| Accessibility | Switch Control list "+" | sheet 265 x 122 "Press your switch now…" | dead | sheet |
| Accessibility | Switch Control list "−", "…" | disabled without a selected row; "…" opened nothing | disabled | disabled |
| Accessibility | Subtitles and Captioning list "+" | a new style at once, then the editor sheet 600 x 533 | dead | the style and the sheet; "Edit…" on a new style's selected row |
| Accessibility | colour wells (2) | the Colors panel, a floating window 266 x 430 | dead (2) | the panel, drawn inside the window |
| Accessibility | Zoom's combo arrow | list 158 x 64 under the field | dead | list; a pick sets the modifier (`state/accessibility.json`) |
| Accessibility | the 14 other "…" buttons, Text size, Live Speech's 2 category rows | not in round 14 | dead (17) | dead (17) |
| Displays | "+" | menu button, "Mirror or extend to" and the available displays | absent | present: the heading and the session's other outputs |
| Sound | Input tab | the device table, Input volume, Input level | the table with filler rows; Output volume and Balance under both tabs | the Mac's table (28 pt header, a row per device) under both tabs; Input volume (wpctl) and Input level under Input |
| Wi-Fi, Network, VPN | labels and menus of R14.1 | as listed | guessed, right but for one colon | the Mac's |
| Network > Firewall > Options… | the application list (R14.2) | three made-up rows | the Mac's row layout, four named rows |
| Privacy & Security, Focus | row tiles (R14.3) | plain tiles / bare symbols | 27 tiles cut from the Mac's rows |

Dead counts. The first audit's drawn, dead items: **30 before, 30 after**; round 14 answers none of them (window 3,
Bluetooth 2, Network Help, VPN Help, Battery Help, Accessibility Help, Menu Bar 3, Spotlight 6, Focus 2, Lock Screen
Set…, Privacy & Security Help, Keyboard 2, Trackpad 2, Appearance / Desktop & Dock / Sound Help, Mouse Advanced…).
Accessibility's small controls (the first audit's "Still dead" list: 18 ⓘ, 15 "…" buttons, the lists' 2 "+", 2 colour
wells, the combo, Text size, 2 category rows): **41 before, 33 after** (16 ⓘ, 14 buttons, Text size, 2 rows).
Together 71 -> 63.

Second-level controls that take the press only. Gone with the application rows: the Files & Folders / Automation
outline rows, Photos Reset, the lists' switches. New, their own target on no shot: the six items of Voice Control's
menu; the voice sheet's language rows, Voice row and play button; the Colors panel's four other modes, eyedropper and
wells; the caption editor's and Hover Text Settings' pop-ups (one item each); Displays' Add rows (nothing is mirrored).

Positions (window pt, ours minus the Mac's; the round 14 stills carry no AX dump, so the Mac's are px / 2 on the
stills): Hover Text Settings rows within 3; the caption editor's rows within 3, its buttons 0; the voice sheet's
language rows within 1.5, Done 0; Switch Control's sheet buttons 0; the combo's list 0 (size), 2 under the field;
Firewall rows: icon, name and pop-up insets 0, row tops within 1.5; Displays "+" 0; Sound table: header and insets 0.
The offscreen runs use Qt's software renderer: the caption strip's mask and the sheets' veil are not drawn there.

### Needs the Mac (R14 follow-up)

1. Firewall: the placard with the firewall off (to confirm the string); which helper shows the globe.
2. Row tiles of Privacy & Security and Focus on the Default, Clear and Tinted icon styles (round 14's are Dark).
3. The 16 other Accessibility ⓘ, the 14 "…" buttons' sheets, Text size, Live Speech's categories.
4. Colors panel: the light look, the four other modes, its window buttons when key.
5. The voice sheet's first three language rows without the blur; the caption editor scrolled to its end, without the
   blur over the strip, and its pop-ups open; how a caption style is removed; Switch Control's sheet after a press.
6. Displays "+" with its device rows readable (glyph and text insets); what a pick does.
7. Sound > Input: the two microphone glyphs' symbol names.

## Needs the Mac (first pass; items 3, 4 and parts of 8, 9 are answered by round 12)

Each needs a still (light + dark) and an AX dump of what opens; rows marked * also need the pushed toolbar.

1. A pushed sub-pane's toolbar*: title position and font against the pane title, the capsule's state, and the push /
   pop transition (clip). Whether the root keeps its scroll offset after a pop. Whether a navigating row lights on press.
2. The Go Back / Go Forward history menu: full menu, row metrics, icons.
3. Accessibility: done from R12.1 (all 22 sub-panes). Still needs the Mac: what each "Show Detail" ⓘ and each "…"
   button opens, the RTT row's tile, the bookmark symbol of Live Speech > Saved, the menus' other items.
4. General*: About, Software Update, Storage, AirDrop & Continuity, Date & Time, Language & Region, Login Items &
   Extensions, Sharing, Startup Disk, Time Machine, Transfer or Reset.
5. Privacy & Security*: Location Services, one data class (Calendars), one device class (Camera), FileVault, Lockdown
   Mode; the Advanced… sheet.
6. Focus*: a mode's sub-pane, Focus status; the Add Focus… sheet.
7. Network*: Firewall, an Ethernet service; the "…" menu. Whether the Wi‑Fi row selects Wi‑Fi in the sidebar.
8. Notifications*: an app's sub-pane, Summarize notifications; the mirroring pop-up's items.
9. Sheets and menus: Wi‑Fi Details… / Other… / Advanced…; Bluetooth ⓘ; VPN "+" menu; Battery Options…; Menu Bar Add
   Controls… / Clock Options… / Battery Options… / Reset; Desktop & Dock Shortcuts… / Hot Corners…; Displays
   Advanced… / Night Shift…; Spotlight About Search & Privacy… / Reset Quick Keys… / Delete Search History… / Search
   Privacy…; Wallpaper Screen Saver… / Clock Appearance…; Lock Screen Set… / Accessibility Options…; Keyboard
   Keyboard Shortcuts… / Edit… / Text Replacements…; Mouse Advanced… (needs a mouse).
10. The "?" button's help anchor (AX identifier or the opened topic's URL) for: Bluetooth, Network, VPN, Battery,
    Accessibility, Appearance, Menu Bar, Desktop & Dock, Spotlight, Sound, Focus, Privacy & Security, Keyboard, Trackpad.
11. Apple Account and Family rows (blanked on every still).

## Round 15: General > About, Storage, Software Update (MAC-ANSWERS-15.md, live/settings-r15/)

Every control of the three sub-panes, the Mac's destination and ours (`settings/panes/general/`, tests
`settings/tests/tst_r15.qml`). AppleCare & Warranty is hidden by the user's choice (2026-11-15): no row in General, no
sub-pane, no Coverage row in About (settings/FALLBACKS.md); the earlier tables above still list it as the Mac has it.

| sub-pane | control | Mac | ours |
|---|---|---|---|
| About | Name | editable text field | the host name, not editable |
| About | Coverage "Details…" | sheet 470 x 600 | not drawn (AppleCare hidden) |
| About | Intel-Based Apps "Details…" | sheet 540 x 585 | not drawn (Apple's) |
| About | Display Settings… | navigates to Displays, Go Back returns | the same |
| About | Storage Settings… | navigates to General > Storage | the same |
| About | System Report… | launches System Information | takes the press only |
| About | four legal links | a window, two PDFs in Preview, a Finder window | not drawn (Apple's) |
| Storage | bar, legend | parts by size, grey "Calculating…" until sized, System Data and macOS parts | the same from this computer's sizes |
| Storage | hover on a part | bubble 121 x 77 with name and size | absent |
| Storage | Store in iCloud… | (not pressed) | not drawn (iCloud) |
| Storage | category ⓘ | sheet (Applications 650 x 490, Developer 470 x 400) | sheet 470 x 400 for every category: the folders counted, Delete… disabled, Done |
| Storage | Other Users & Shared, System Data | no ⓘ | no ⓘ |
| Storage | Help | help viewer | takes the press only (anchor not known) |
| Software Update | (opening) | "Checking for updates…" with a spinner, Installed | the same, 3 s |
| Software Update | Check for Updates | checks again | checks again (3 s), always up to date |
| Software Update | Automatic Updates ⓘ | sheet 470 x 274, three switches, Done | the same; the switches change nothing on the system |
| Software Update | Beta Updates ⓘ | sheet 470 x 284 (pop-up, Apple Account) | takes the press only |
| Software Update | licence link | not enabled | not enabled |
| Software Update | Help | help viewer | takes the press only (anchor not known) |

Still needs the Mac: the spinner's turn time and spoke shape frame by frame (software-update-checking-dark.mov is not
decoded yet); the bar's colours past the sixth part; the bubble's delay; the Storage sheet's header tile unblurred;
whether a category's row and part appear for Other Users & Shared when it is large; the Help anchors of the three.

