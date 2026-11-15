# Extras audit: text and motion that macOS 27.2.1 does not have (2026-11-14)

The user: "perhatikan setiap menu jangan ada gerakan tambahan seperti nambahan informasi ini biar user tau. ga perlu,
malah terlihat ai slop" (every menu and panel: no extra motion, no extra information "so the user knows").

Every menu, menu-like popover and panel was checked for hint / helper / caption text, explanatory sublabels and notes,
empty-state messages, tooltips, toast-like notes, status lines, extra motion (nudges, pulses, flashes, staggered rows,
animated counters) and extra rows, icons or badges.

Evidence used:
- **R** the 27.2.1 system volume (`141-12228-174.dmg`, apfs-fuse read-only): every en `.loctable` / `.strings` of
  System Settings and its extensions, ControlCenter, NotificationCenter, Dock, loginwindow, CharacterPalette,
  MenuBarAgent, SystemUIServer, WindowManager, OSDUIHelper, Finder, AppKit, ControlCenter.framework,
  NotificationCenterUI, CharacterPicker, CalendarWidget, CalendarUIKit, ClockUIFramework, OSD, LoginUIKit, FinderKit,
  DesktopServicesUI, EmojiFoundation, LockoutUI, QuickLook, dumped to one grep-able table (33 259 strings; dump script
  and table in the session scratchpad, not kept). A string counts as "on the Mac" only when the exact text is there.
- **S** the screenshots in `reference/screens/27.2.1/` and `reference/re/27.2.1/live/`; **A** `MAC-ANSWERS.md` answers.
- The docs already decoded row by row: `MENUS-REA-27.2.1.md`, `STATUS-REA-27.2.1.md`, `GAPS-REA-panels.md`.
- A headless session (scale 2, light and dark): Apple menu, the six Finder menus, desktop, Dock, Downloads-stack and
  Dock-separator menus, Control Center, Notification Center, the volume HUD, the emoji picker, About This Mac, a Finder
  window (menus, sidebar menu, Group By, Action), System Settings panes.

Rule: text or motion with a Mac source stays; what has none is removed; when unsure it is listed, not deleted.
Fallbacks (CONTRIBUTING): where a removed note was the only sign that a feature is missing, the control stays disabled or
hidden, as the Mac does; the FALLBACKS.md files say so.

Action: **removed**, **Mac wording** (the text stays, replaced with the Mac's exact string), **kept** (with source),
**unsure**, **for owner** (a file another pass owns; not edited here).

## Menus (menu bar, context menus, Dock menus, text menu)

These were rebuilt from the Mac's resources earlier the same day (MENUS-REA-27.2.1.md). Nothing extra was left.

| place | what | Mac evidence | action |
|---|---|---|---|
| shell/lib/menus.js:55-73 `apple()` | Apple menu rows, icons on About / System Settings / App Store | R AppKit Menus.loctable; A Q-menubar-31, -17; S matches the headless capture | kept |
| shell/lib/menus.js:79-186 `finderMenus()` | Finder File / Edit / View / Go / Window / Help rows, keys, icons | A live/menubar/finder-menus-ax.txt (incl. "Show Clipboard", "Mac User Guide", "Tips for Your Mac") | kept |
| shell/lib/menus.js:184, 235, 254 | Help's "Search" as a plain disabled row | the Mac has a search field there (finder-menus-ax.txt); a stand-in for it, no text added | kept (stand-in) |
| shell/lib/menus.js:193-213 `windowMenu()` | AppKit Window rows | R MenuCommands.loctable; A finder-menus-ax.txt | kept |
| shell/lib/menus.js:344-354 `windowList()` | window list after a separator, ✓ key window, ◆ minimised | C `_addWindowsMenu:enabled:` 0x18a558ab0; A "◆ Applications" | kept |
| shell/lib/menus.js:348 | "Untitled" for a window without a title | none (GUESS in the code) | unsure |
| shell/lib/menus.js:268-277 | Firefox / terminal / TextEdit menus (History, Bookmarks, Tools, Shell, Format) | the apps' own menus, not macOS (GUESS in MENUS-REA) | unsure |
| shell/lib/menus.js:283-296 `desktop()` | desktop context menu | S menubar/context-{light,dark}.png; C context 2 rows | kept |
| shell/lib/menus.js:299-322 `appMenu()` | app-name menu | A Q-menubar-31; C FUN_10002bca8 for System Settings | kept |
| shell/modules/MenuDropdown.qml:17-19, 180-200, 248-268 | motion: appears at once, chosen row blinks off 4 / on 3 frames, 0.2 s fade out, selection jumps (no glide) | A Q-menubar-23, -24, "the highlight moves within 1 frame" | kept |
| shell/modules/MenuDropdown.qml:357-359 | submenu opens 13 frames after its row | A Q-menubar-23 | kept |
| shell/modules/MenuDropdown.qml:490-499 | ◆ drawn as a 5 pt square at 45° | the mark is on the Mac (A); its size is GUESS | kept |
| shell/modules/MenuDropdown.qml:152-157 | About This Mac opens an alert titled "About This Computer", body = distro + "Linux <kernel>", buttons More Info… / OK | "More Info…" R AboutExtension SPInfo.loctable MORE_INFO_BUTTON; "About This Computer" is in no Mac table (the Mac window heads with the model name; the window itself is not built) | unsure (alert owned by the alerts pass) |
| shell/modules/MenuBar.qml:189-216 | battery percentage text | A Q-menubar-29: hidden by default; already `visible: false` | kept (hidden) |
| shell/modules/MenuBar.qml:305-306, 360-366 | title pill: full in one frame, jumps between titles, gone in one frame | A relay #52, R2 | kept |
| shell/services/Apps.qml:490-541 `dockMenu()` | Dock app / Finder / Trash / Downloads menus | R DockMenus.plist + DockMenus.strings; A live/dock/dock-menus.json, Q-dock-10 | kept |
| shell/lib/dock.js:157-174 `dockOwnMenu()` | Dock separator menu | R DockMenus.plist "dock" | kept |
| shell/modules/Dock.qml:798-860 | app name label over a hovered tile | the Mac's Dock label (Q-dock-08) | kept |
| shell/modules/Dock.qml:883-905 | "Remove" bubble over a tile dragged off | R Dock.app en.lproj/Localizable.strings "Remove"; A Q-dock-17 | kept |
| ui/HyprK/textmenu.js:39-71 | text field context menu rows | R AppKit NSTextViewContextMenu.nib; C `-[NSTextView menuForEvent:]` | kept |
| ui/HyprK/textmenu.js:32 | Look Up cut-off at 30 characters | GUESS in the code | unsure |
| ui/HyprK/TextMenu.qml:113-114 | text menu appears at once, fades out 0.2 s | A Q-menubar-24 (the menu fade) | kept |
| ui/HyprK/SearchField.qml:40 | "Search" placeholder | R AppKit / Settings "Search"; S settings sidebar | kept |
| ui/HyprK/Popover.qml:5-7, 44 | popover (Get Info, tags): spring from the arrow tip, 0.128 s fade out, no scale | A Q-windows-17, Q-finder-25 (Tokens.panel) | kept |
| ui/HyprK/Sheet.qml:22-23 | sheet fade in / out | Tokens.panel (sourced there) | kept |

## Control Center, Notification Center, banners, HUD, emoji picker, lock screen

| place | what | Mac evidence | action |
|---|---|---|---|
| shell/components/NotifCard.qml:172 (banners) | time label ("now", "2m ago") on every banner | A Q-panels-28: "No app-name line and no time in the banner" | removed from banners (`showTime: false`); kept in NC (nc/hover-off-on-dark-grey.png, NotificationCenter Localizable MIN_AGO) |
| shell/modules/Banners.qml:117, 160 | plates stacked under a banner when one app posts several | A Q-panels-30: "the 2nd banner replaces the 1st in the same slot; no visible stack while showing" | removed |
| shell/modules/Banners.qml:173-175 | "refocus" fade of the text from 0.25 to 1 in 260 ms when the same app posts again | none (Q-panels-30: replaced in place) | removed (the fresh timeout stays) |
| shell/modules/lock/LockTheme.qml:108, Lock.qml:61, 69, 119 | "?" with no hint set showed "Check Caps Lock and the keyboard layout" | none (lock screen B6: the "?" was never pressed on the Mac) | removed: with no hint the "?" does nothing |
| shell/modules/NotificationCenter.qml:527 | calendar widget "No more events today" | R CalendarWidget Localizable "No Events Today" (also "No More Events Today", other case) | Mac wording: "No Events Today" (no calendar source here, so never any events) |
| shell/modules/lock/LockTheme.qml:109 | lockout line "Too many attempts" | R loginwindow RATE_LIMIT_LOCKED_OUT "Your account is locked." | Mac wording |
| shell/modules/ControlCenter.qml:14-16, shell/FALLBACKS.md:16, 18, 25 | docs said modules show "Not Available" and Stage Manager is dimmed; the code shows "Off" and Stage Manager works | S panels/controlcenter-dark.png | docs corrected, nothing visible changed |
| shell/modules/ControlCenter.qml | Wi-Fi / Off / Not Connected, Bluetooth / On, AirDrop / Contacts Only, Not Playing, Focus, Do Not Disturb / On, Display, Sound, Edit Controls | R ControlCenter WiFi / Bluetooth / AirDrop / NowPlaying / Focus / BentoBox loctables; S controlcenter-dark.png; A Q-panels-02 | kept |
| shell/modules/ControlCenter.qml:65 | AirDrop shows "Contacts Only" from a local toggle, no backend | R AirDrop.loctable "Contacts Only" (the state is not real) | unsure |
| shell/modules/ControlCenter.qml:239 | colour fade (`Theme.anim.fast`) on a capsule's circle when toggled | not measured | unsure |
| shell/modules/ControlCenterWindow.qml | open / close fade with a 1 % scale, grid to Sound morph | A MAC-ANSWERS REA section 2, Q-panels-12 | kept |
| shell/modules/CcSoundPanel.qml:47, 84, 104 | "Sound", "Output", "Sound Settings…" | R Sound.loctable | kept |
| shell/modules/NotificationCenter.qml:217, 226, 365, 375 | "Notification Center", "Clear All", "Show less", "Clear" | R NotificationCenter Localizable; A Q-panels-32 | kept |
| shell/modules/NotificationCenter.qml | no notifications: no empty-state text, heading hidden | nothing to remove | kept |
| shell/modules/NotificationCenter.qml:288-331 | a new card waits then fades in; a cleared card fades, then the list closes up | lib/nc.js fits (motion.json, PC #62) | kept |
| shell/modules/NotificationCenter.qml:449 | calendar contents fade in on open | S nc/INDEX.md "The calendar digits fade in on open" | kept |
| shell/modules/NotificationCenter.qml:44 | Photos widget caption "Featured Photo" or the folder name | R PhotosReliveWidget.loctable "Featured Photo" is the widget's accessibility name; S macos27-notification-center.png shows a memory title | unsure |
| shell/modules/NotificationCenter.qml:602 | photo date "JUL 19, 2024" style | S macos27-notification-center.png | kept |
| shell/modules/NotificationCenter.qml:613-614 | "Edit Widgets" capsule and the ✕ circle beside it | S nc/widgets-dark-grey.png; R Localizable "Edit Widgets" | kept |
| shell/components/NotifCard.qml:216, 223 | "Show" capsule and close button on hover | R Localizable "Show"; A Q-panels-29; S hover-off-on-dark-grey.png | kept |
| shell/components/NotifCard.qml:67 | card fades while swiped | swipe-to-dismiss A Q-panels-29; the fade not measured | unsure |
| shell/modules/Banners.qml:94-99 | the other banners glide up (360 ms) or move to the top | not measured | unsure |
| shell/lib/clock.js:38-43 | "now", "%dm ago", "%dh ago", weekday | R MIN_AGO "now", "%dm ago"; the hour form not found | kept (hour form unsure) |
| shell/modules/HudWindow.qml, shell/lib/hud.js | spring scale and fade, glyph and fill crossfade, no text | A MAC-ANSWERS REA section 1; S hud-*.png | kept |
| shell/modules/EmojiPicker.qml:345 | "Search" placeholder | R CharacterPicker Localizable "Search" | kept |
| shell/modules/EmojiPicker.qml:42-43, shell/lib/emoji.js:194-203 | section and tab names, used in code only, never drawn | – | kept |
| shell/modules/lock/LockTheme.qml:71, 101 | "Enter Password" placeholder and line | R loginwindow ENTER_PASSWORD, LoginUICore SECURE_TEXTFIELD_ENTER_PASSWORD | kept |
| shell/modules/lock/Lock.qml:239 | a PAM error message replaces the line | the Mac shows no wrong-password text (lock screen B2); PAM rarely sends one | unsure |
| shell/modules/lock/Lock.qml:61 | a hint that is set shows in the line (the Mac uses a popover) | "password hint" in LoginUICore; the popover was never recorded (A5) | unsure |
| shell/modules/lock/PasswordField.qml:30-41 | wrong-password shake, 400 ms | lock screen B2; S lock/shake-dark-arrow-hint-per-frame.png | kept |
| shell/modules/lock/PasswordField.qml | caret blink 0.6 / 0.4 s, Caps Lock glyph | A5 / B6; S field-light-capslock-empty.png | kept |
| shell/modules/lock/LockContent.qml:185-242 | spinner about 1 s after Return | B2; S lock/field-dark-spinner.png | kept |
| shell/modules/lock/LockClock.qml | a minute change reveals only the changed digit | B8; S minute-change-light-strip.png | kept |
| shell/modules/lock/LockTheme.qml:145-183 | lock-in and unlock fades | B1 / B3 per-frame tracks | kept |
| shell/modules/lock/LockFeed.qml | Now Playing card and notifications on the lock screen, look guessed | R settings "Allow notifications when the screen is locked"; not in the recordings | unsure |
| shell/modules/lock/LockStatus.qml | Wi-Fi, battery, "ABC" + keyboard | A7; S status-items-dark.png | kept |
| shell/modules/Switcher.qml:211-221 | the selected app's name under its icon | measured on cmdtab-*.png (Theme switcher labelTop) | kept |
| shell/modules/StageStrip.qml:152 | a pile grows on hover (120 ms) | lib/stage.js 0x1002bc7e0 decoded; the 120 ms GUESS | kept |
| shell/modules/Background.qml | no text, no extra motion | – | kept |

## Finder

| place | what | Mac evidence | action |
|---|---|---|---|
| finder/qml/Browser.qml:62-67 | window title "Documents — Local" / "Desktop — Local" | R NE84 " — Local" exists, but A Q-finder-06: "Only the folder name; no " — Local" and no subtitle" (the suffix belongs to iCloud Desktop & Documents) | removed |
| finder/qml/InfoRows.qml:8-9, 17-19, 33-36 | "Show More" added an invented "Size" row (the size is already in the header) and turned into "Show Less" | none (the code said the Mac's result was not captured) | removed; "Show More" stays (PV1, gallery-light.png) and does nothing (FALLBACKS.md) |
| finder/qml/PopupMenu.qml:10-11, 94-98, 171-192 | unused tag-dot row whose dots grow 1.2× on hover | none (Main.qml: the tag-dot row is not built) | removed (dead code) |
| finder/qml/Main.qml:437, 454 | Quick Actions ▸ "Customise…" | R N270 / N274 "Customize…" (en US, as MENUS-REA uses) | Mac wording |
| finder/qml/lib/files.js:139-142 | rename errors in invented words ("…is reserved.", "Names can’t contain “/”.", "…null character.", "The name is too long.") | R RN5, RN31, NE74 | Mac wording |
| finder/qml/lib/files.js:138 | "Please enter a name." | none; whether Finder keeps the old name silently was not checked | unsure |
| finder/qml/QuickLook.qml:397, 403 | card for a file with no preview: "kind – size", "Modified Today at …" | R QuickLook PlugIns.loctable "%1$@ - %2$@", "Last modified %@", "Today %@" | Mac wording |
| finder/qml/DragSession.qml:98 | the drag image fades while sliding back after a failed drop | none (the slide-back is AppKit's) | unsure |
| finder/src/fileops.cpp:226, 253, 279, 294, 314, 475, 565, 589 | failure alerts ("The Trash can’t be emptied.", "The destination folder can’t be found.", …) | none found (shown only when an operation fails) | unsure |
| finder/qml/Main.qml:446-507 | item context menu rows, Open With "App (default)", Services ▸ "No Services Apply" | R N151–N169, LaunchServices DEFAULT_APP_SUFFIX, AppKit Services.loctable; S crops/context-menu-*-light.png | kept |
| finder/qml/Main.qml:516-537, lib/files.js:372-388 | Sort By, Group By, sidebar menu rows | R ArrangeByMenu.nib, N162 / N165 / N169.x | kept |
| finder/qml/Main.qml:88-94, 397-399 | alert texts (Empty Trash, the --panel fixture) | R MT16_V1, MT18_V1, A15, MN4, AppKit | kept |
| finder/qml/Browser.qml:223, 234 | "You don’t have permission to create a folder here." | R SC5 | kept |
| finder/qml/TagPopover.qml:37 | "Assign tags to “x”" / "n items" | R TG11_V1 / TG11_V2 | kept |
| finder/qml/RenameSheet.qml:65-100 | Rename Finder Items sheet labels | R BulkRenameWindow.nib; S sheet-*.png | kept |
| finder/qml/InfoRows.qml:14-16, 26 | "Information", Created / Modified / Last opened | R ColumnPreview.nib, PV3 / PV4; S gallery-light.png | kept |
| finder/qml/GalleryView.qml:152, 210 | "Tags", "Add Tag" | R PV53, TG7 | kept |
| finder/qml/PreviewBar.qml:19-21 | Rotate Left / Markup / More… | R N271, QK4, QK8 | kept |
| finder/qml/InfoPopover.qml:34, 41 | Get Info stand-in: "kind – size", "Where: path" | R InfoWindowGeneralView.nib "Where:" | kept |
| finder/qml/QuickLook.qml:268 | "Open with <app>" capsule | S crops/quicklook-titlebar-light.png | kept |
| finder/qml/Toolbar.qml:201, 250 | search field widens, "Search" placeholder | A Q-finder-30; S crops/search-expand-frames-light.png | kept |
| finder/qml/PopupMenu.qml:34-39, 76 | submenu after 0.22 s, 0.2 s fade on close | A Q-menubar-23, Q-finder-24 | kept |
| finder/qml/DragSession.qml:111-147 | drag image with a name label and a red count badge | S crops/drag-multi-badge-and-sidebar-target-light.png | kept |
| finder/qml/Sidebar.qml:90-99, TabBar.qml:145-157 | section chevron on hover, tab close × on hover | A Q-finder-07; S crops/sidebar-header-hover-dark-2x.png, tabbar-*.png | kept |
| finder/qml/FileIcon.qml:195-203 | extension text on the generic document icon | ICONS-REA-27.2.1 part 2 | kept |
| finder empty folders (IconView, FileList, ColumnView, GalleryView) | no empty-state text; no ToolTip anywhere; no status bar | – | kept |

## System Settings

Settings had no extra motion (no Behavior, Animation or Transition in settings/). The extras were notes: an
`InlineNote` control (an info.circle line under a card), an `Unavailable` empty-state control, `Backend.statusNote()`
sentences and sublabels explaining what Linux, Hyprland, PipeWire, NetworkManager or BlueZ do. Both controls are deleted
(nothing uses them). Where a feature is missing, its control stays disabled or its card hidden (settings/FALLBACKS.md).
Places are file:line before the edit. "Mac wording" = an invented or shortened text replaced with the exact Mac string.

| place | what | Mac evidence | action |
|---|---|---|---|
| settings/SettingsApp.qml:214 | "Local Account" under the user name | R System Settings Localizable "Apple Account, iCloud+, and more" (mac rule) = "Apple Account"; no "Local Account" anywhere | Mac wording: "Apple Account" |
| settings/Backend.qml:89-94 | `statusNote()`: "… is not available, so … can't be managed here." / "… is not responding right now. Try again in a moment." | none | removed |
| settings/controls/InlineNote.qml, Unavailable.qml | the note control and the 40 pt-symbol empty state | none | removed (files deleted) |
| settings/panes/General.qml:7 | hero "Manage your overall setup … for your computer, … AirDrop and more." | R GeneralSettings.appex Localizable ("… for Mac, … AirDrop, and more.") | Mac wording |
| settings/panes/Siri.qml:8 | hero "Siri is not available on this computer." | none; R SiriPreferenceExtension SIRI_PLACARD_DESCRIPTION | Mac wording (the placard sentence, without its link) |
| settings/panes/Energy.qml:21 | note "This computer has no battery, so battery settings are hidden." | none | removed |
| settings/panes/VPN.qml:9 | sublabel "VPN connections from NetworkManager will be listed here." | none ("No VPN configurations" is R VPN.appex: kept) | removed |
| settings/panes/Privacy.qml:28 | FileVault sublabel "Disk encryption is managed by your Linux installer." | none | removed |
| settings/panes/Accessibility.qml:32-58 | 11 `about` texts shown as sublabels on unsupported pages ("Show a larger version…", "Control your computer…", …) | none (the Mac's descriptions are worded differently) | removed |
| settings/panes/Accessibility.qml:70 | hero "Personalize your computer … speech and cognition." | R AccessibilitySettingsExtension accessibilityPlacardInfo | Mac wording |
| settings/panes/accessibility/Unsupported.qml:18, 22-26 | sublabel + empty state "<Feature> Unavailable" / "This feature isn't available on Linux yet." | none | removed; the row stays dimmed, its switch disabled |
| settings/panes/accessibility/Audio.qml:25 | note "Saved for the shell and PipeWire; they don't apply these two yet." | none | removed |
| settings/panes/accessibility/Audio.qml:30 | shortened Background Sounds description | R audio.backgroundSounds.desc | Mac wording (full sentence) |
| settings/panes/accessibility/Captions.qml:36 | "Use closed captions or SDH subtitles instead of standard subtitles when available." | none; R caption.preferSDH.subtitle | Mac wording |
| settings/panes/accessibility/KeyboardA11y.qml:17, 25, 30, 39 | 4 sublabels ("…GTK and Qt apps already do this with Tab.", "Press modifier keys…", "Add a delay…", "…such as wvkbd.") | none (the Mac's *.desc differ) | removed |
| settings/panes/accessibility/KeyboardA11y.qml:34 | note "Hyprland doesn't support Sticky Keys or Slow Keys yet. Key repeat is in Keyboard settings." | none | removed |
| settings/panes/accessibility/LiveSpeech.qml:17 | sublabel "Press Return or Speak to hear what you typed." / "Live Speech needs speech-dispatcher (spd-say)." | none | removed |
| settings/panes/accessibility/Motion.qml:18, 23, 28, 33-35, 40 | 6 sublabels ("Reduce the motion of the user interface…", "Video playback here can't detect…", gsettings / GTK texts, "Needs the motion sensors of a laptop.") | none | removed |
| settings/panes/accessibility/Motion.qml:44, Zoom.qml:57, Display.qml:138, A11yCtl.qml:18-19 | `hyprNote`: "Saved, but Hyprland isn't reachable here, so the change applies at the next login." | none | removed |
| settings/panes/accessibility/PointerControl.qml:26-28 | 3 sublabels ("Move the pointer with the keyboard.", …) | none (the Mac's pointerControl.*.desc differ) | removed |
| settings/panes/accessibility/PointerControl.qml:30 | note "These need a Hyprland pointer helper that isn't available yet." | none | removed |
| settings/panes/accessibility/ReadSpeak.qml:20, 25, 34, 55 | sublabels "…isn't available on Linux.", "Press ⌥Esc to hear…", "Saved for notifications…" and the note "Speech needs speech-dispatcher (spd-say)." | none | removed |
| settings/panes/accessibility/VoiceOver.qml:18-20, 34 | sublabel "Speaks what's on the screen, using the Orca…" / "Install the Orca screen reader…" and the note "Orca reads apps that expose AT-SPI…" | none | removed |
| settings/panes/accessibility/Zoom.qml:20 | "Toggle zoom: ⌥⌘8   Zoom in: ⌥⌘=   Zoom out: ⌥⌘−" | R zoom.keyboardShortCutToggleZoom / ZoomIn / ZoomOut | kept |
| settings/panes/accessibility/Zoom.qml:25, 43, 52 | sublabels "Hyprland has no pinch-to-zoom…", "Split Screen and Picture-in-Picture need…", "The screen follows the pointer…" | none | removed |
| settings/panes/accessibility/Display.qml:27, 39, 44, 50, 67, 76, 93, 103 | 8 sublabels ("Apps choose their own text size on Linux.", "Hyprland can't enlarge the pointer…", "Needs a recolored cursor theme…", …) | none | removed |
| settings/panes/Sound.qml:42, 74-75, 79 | notes "The volume could not be changed.", "Sound previews need pw-play…", "That sound could not be played.", "That output device could not be selected." | none | removed |
| settings/panes/Sound.qml:138, 220-223 | note "PipeWire (wpctl) is not available…" and "No output devices found." | none (R NO_OUTPUT_DEVICES "No audio output devices found" exists, where it shows is unknown) | removed |
| settings/panes/Sound.qml:118 | "Selected sound output device" | R Sound.appex DEFAULT_ALERT_DEVICE "Selected Sound Output Device" | Mac wording (capitals) |
| settings/panes/WiFi.qml:68-69 | sublabel "No hardware installed" / "Not available on this system" | none (Wi-Fi.appex, WiFiSettingsKit, CoreWLAN, Network.appex) | removed; the switch stays disabled |
| settings/panes/WiFi.qml:45, 50, 52 | "Wi‑Fi could not be turned on… NetworkManager.", "Joining “x”…", "Could not join … nmtui or nm-applet." | none | removed |
| settings/panes/WiFi.qml:90-94 | note "This computer has no Wi‑Fi adapter. Wired connections are in Network." | none | removed |
| settings/panes/WiFi.qml:101 | "No networks found" | R WiFiSettingsKit NO_NETWORKS "No Networks" | Mac wording ("Searching…" kept: SEARCHING) |
| settings/panes/WiFi.qml:121 | shortened "Known networks will be joined automatically." | R WiFiSettingsKit, the three footers | Mac wording, follows the Off / Notify / Ask pop-up |
| settings/panes/WiFi.qml:70, 80 | "Connected" | R WiFiSettingsKit CONNECTED | kept |
| settings/panes/Bluetooth.qml:42-47 | empty state: bluetooth.slash, "Bluetooth Unavailable", "BlueZ (bluetoothctl) is not installed." / "No Bluetooth controller was found…" | none | removed; the Bluetooth row stays, its switch disabled |
| settings/panes/Bluetooth.qml:54 | "Now discoverable as “host”." | R Bluetooth.appex now_discoverable_as_mac | Mac wording: "This Mac is discoverable as “%@” while Bluetooth Settings is open." |
| settings/panes/Bluetooth.qml:55, 59, 77 | "Bluetooth could not be turned on.", "Couldn't reach “x”. Make sure it's turned on and nearby." | none | removed |
| settings/panes/Bluetooth.qml:64 | "No paired devices" | R Bluetooth.appex empty_connected_paired_devices "No Bluetooth Devices" | Mac wording |
| settings/panes/Bluetooth.qml:86 | "Searching…" under Nearby Devices | R Bluetooth.appex empty_nearby_devices | kept |
| settings/panes/Network.qml:24 | "No network services" / "Network services can't be listed" + statusNote | none | removed; the card is hidden with no services |
| settings/panes/Network.qml:43 | "Not Configured" | R Network.appex "Not configured" | Mac wording (capitals) |
| settings/panes/Keyboard.qml:30, 65 | note "Saved to state/input.json, but Hyprland isn't reachable here…" | none | removed |
| settings/panes/Keyboard.qml:63, 73 | shortened keyboard navigation and Dictation texts | R KeyboardSettings.appex, Dictation.Description; S scroll-edge-keyboard-light.png | Mac wording |
| settings/panes/Notifications.qml:42-46 | dim row "Loading…" / "No apps have asked to send notifications" | none | removed; the card is hidden with no apps |
| settings/panes/Notifications.qml:65 | note "The app list is not available…" | none | removed |
| settings/panes/Displays.qml:54, 181-184 | "Hyprland did not accept that display setting.", "Display details come from Hyprland…", the looks-like reasons ("This is a virtual display. Its size is set by its own rule.") | none | removed |
| settings/panes/Displays.qml:237-244, 222-224 | "Looks like 1470 × 956" under the size tiles, changing on hover | none (not in DisplaysExt / Display frameworks; S displays-light.png has no such line) | removed |
| settings/panes/Displays.qml:274 | "Default for display" | R DisplaysExt "Default" | Mac wording |
| settings/panes/Displays.qml:296, 306 | True Tone and "When connected to TV" sublabels | R DisplaysExt; S displays-light.png | kept |
| settings/Parsers.js:423-428 | the looks-like reason sentences | none; no longer drawn, tests/displays.test.js checks them | kept (not shown) |
| settings/panes/Wallpaper.qml:39-40, 121-126 | "Saved. Install hyprpaper or swaybg…", "…could not be applied right now.", "No wallpapers found yet. Pictures placed in themes/wallpapers appear here." | none | removed |
| settings/panes/Wallpaper.qml:103 | "No wallpaper selected" | none | removed (label empty) |
| settings/panes/Wallpaper.qml:145 | "Show All (n)" / "Show Less" | R Wallpaper.appex SHOW_ALL_%@ / SHOW_LESS | kept |
| settings/panes/Dock.qml:76 | "Click wallpaper to move windows out of the way…" | R DesktopSettings.appex; S desktop-dock-light.png | kept |
| settings/panes/Dock.qml:77 | shortened Stage Manager description | R DesktopSettings.appex | Mac wording |
| settings/panes/Mouse.qml:10 | "Content tracks finger movement" | R MouseExtension GNAME_SCROLL_LABEL | kept |
| settings/panes/Focus.qml:13-15 | sublabel "Set Up" on Sleep, Personal, Work | not found in FocusSettingsExtension, FocusSettingsUI, DoNotDisturbKit | unsure |
| settings/panes/Accessibility.qml:71-73 | "Learn more…" link, opened settings/FALLBACKS.md | S accessibility-light.png; AX `help:anchor=mh35884 bookID=com.apple.machelp` | 2026-11-15: opens that topic (web edition of the guide) |
| settings/panes/Accessibility.qml:105-130 | in-pane back link "‹ Accessibility" with a centred title | none (the Mac uses the toolbar back button) | removed 2026-11-15: sub-panes are pushed on the window's history, the toolbar shows their title (SETTINGS-CLICK-AUDIT.md) |
| settings/panes/accessibility/KeyboardA11y.qml:22 | section header "Physical Keyboard" | not found | unsure |
| settings/panes/accessibility/LiveSpeech.qml:16-39 | "Type to speak" row with a field and a Speak button | none (the Mac page has liveSpeech.toggle and phrases) | unsure (the only way to use Live Speech here) |
| settings/panes/accessibility/Zoom.qml:50-55 | "Zoom now" row with Zoom Out / Zoom In | none | unsure (it works) |
| settings/panes/Network.qml:34 | green / grey status dot at the end of service rows | not checked | unsure |
| settings/panes/Notifications.qml:55 | app sublabels "Off" / "Banners, Sounds" / "Alerts, Sounds" | "Banners" and "Alerts" not found in NotificationsSettings.appex | unsure |

## For other owners (not edited here)

| owner | place | what | note |
|---|---|---|---|
| alerts (ui/HyprK/AlertPanel.qml, AlertDialog.qml) | shell/modules/MenuDropdown.qml:152-157 (content) | About This Mac shows an alert "About This Computer" + distro / kernel | the heading is no Mac string; the Mac opens a window (model name, Chip, Memory, macOS, More Info…). Left as is (unsure); since R3.1 the alert heads with the OS name (MOTION-AUDIT.md) |
| status modules (statusmodule.js) | shell/tests/run.mjs | 3 tests failed mid-audit ("status module metrics", "battery rows", "focus rows and layout") while the owner was changing that file | passing again at the end; not touched here |
| Spotlight | shell/modules/Spotlight.qml:196 | runtime warning "Unable to assign [undefined] to double" | seen in the headless log |
| Mission Control, Dock stack | MissionControl.qml:508-782, DockStack.qml:186-326 | text: space names, window titles, item names | all are Mac labels (Desktop n, titles on hover, stack names); a grep found no hint text; not audited further |

## Counts

| area | removed or replaced by the Mac string | kept with source | unsure |
|---|---|---|---|
| menus, Dock, text menu, popover, sheet | 0 | 21 | 4 |
| CC, NC, banners, HUD, emoji, lock | 6 (4 removed, 2 Mac wording) | 25 | 8 |
| Finder | 6 (3 removed, 3 Mac wording) | 17 | 3 |
| System Settings (counted per text, not per row) | 46 (about 12 of them Mac wording) | 16 | 8 |
| total | 58 | 79 | 23 |

For other owners: 4 rows (section above).

Tests after the audit: `node shell/tests/run.mjs` 403 passed, 0 failed;
`node finder/tests/run.mjs` 33 passed; `node --test settings/tests/*.test.js` 52 passed;
`qmltestrunner -import ui -input ui/tests` 96 passed.
