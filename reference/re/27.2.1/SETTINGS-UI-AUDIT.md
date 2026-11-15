# System Settings UI audit against macOS 27.2.1 (round 3)

Ours: headless session (scripts/smoke.sh, HYPRK_HEADLESS=1, 2560x1664 at 2x), Settings launched from the tree with
HYPRK_GLASS=plugin, window 740x625 pt, captures with grim at 2x. Mac: R3.8a (settings/appearance/control-*.png),
R3.8b (settings/panes/{pane}-{NN}-{light,dark}.png, AX live/settings/panes/ax-{pane}-*.jsonl), R3.9
(settings/sidebar-scrolled-*.png, sidebar-scroll-*.mov). Values are 2x pixels of the stills unless noted; "pt" = points.

## Pop-up button (ui/HyprK/Popup.qml: Text highlight colour, Folder colour, Sidebar icon size and every Settings pop-up)

| element | Mac (R3.8a) | ours before | after | source |
|---|---|---|---|---|
| rest | value + 20 pt circle (228 on 247 / 53 on 37), no frame | same | same | control-*-rest-*.png |
| hover | whole 133 x 24 frame filled 228 light / 53 dark, radius ~6 (continuous; circular fit 6.0-6.1 pt, rms .03), circle not drawn | nothing changed on hover | frame 229 / 53, r 6, circle hidden | control-*-hover-*.png, coverage fit |
| pressed | frame 206 light (228 x .902: black a.098 over the fill) | only the circle darkened | frame 207 light; dark white a.098 over the fill (73; the R3.5 clip reads 48 -> 66 over 34, same ratio) | control-*-pressed-light.png, popup-menu-open-close-dark.mov |
| after the menu closes, pointer still on the button | no frame | n/a (no hover) | no frame until the pointer leaves | MOTION-AUDIT.md (R3.5 light 4.500 s) |
| menu material | glass window, may leave the Settings window | flat #F6F6F6 / #2C2C2E in the window, cut off at the window's edge (Folder colour near the bottom) | its own popup surface, the plugin's `menu` glass and shadow (as Finder's pull-downs); flat fallback (no plugin, Reduce Transparency, Increase Contrast) now 249 / (63,64,70) with the 0.5 pt rim black a.33 / a.75 and a Gaussian shadow sigma 17 pt a.2 | control-*-open-*.png (rows over the window), shadow profile of the light shot's left side |
| menu x | rim 12.5 pt left of the button | 16 | 12.5 | rim px 165, button px 190 in all three open shots |
| menu y | the checked row's highlight on the button's top | same (5 pt padding) | same, with separators counted | sidebar open shot: highlight 224 = button 224 |
| width | as its rows ask: 169 / 147 / 97 pt with "Choose Colour…" | max(button, rows) | same rule; ours 132 / 136 / 97 (no "Choose Colour…" row, see below) | rims 165..502, 165..458, 165..358 px |
| padding / rim | 5 pt inside a 0.5 pt rim | 5 | 5 + 0.5 | highlight 176 px from the rim at 165 |
| separators | after Automatic and before Choose Colour…: 11 pt rows, 1 pt line from 25 pt to 11 pt before the row's end, black a.10 light / white a.14 dark | none | after Automatic (the second goes with Choose Colour…) | px 234-235 line, 226..469 |
| dots | 16 pt at 24 pt into the highlight, 0.5 pt darker rim (light) | 12 pt at 25 | 16 at 24 | dot px 224..255, row 176 |
| text x | 47 pt with dots, 25 without (ink 26 for "Medium") | 43 / 25 | 47 / 25 | ink px 270 / 228 |
| checkmark | ink 7.5 pt into the highlight in dot menus, 8.5 without | 8.5 | 7.5 / 8.5 | ink px 191 (dot menus) / 193 |
| Text highlight colour dots | the highlight colours (selectedTextBackground: blue #BAD6FB light, #476288 dark, graphite #E0E0E0 / #696969) | the accent swatches (saturated) | Accent.table text colours | dot centres sampled per row |
| row lit when the menu opens under the held pointer | yes (Automatic lit, pointer not moved) | no | yes; hover takes over on the first move | control-*-open-*.png |
| Folder colour | one dot inside the button | a second 16 pt dot drawn beside the button | the button's own dot only | control-folder-colour-rest-*.png |

Not done / limits:
- "Choose Colour…" (both colour menus) is not offered: no colour panel / popover is built, so the menus are narrower
  than the Mac's (132 against 169 pt, 136 against 147). The Folder colour popover is on iconstyle-choose-colour-popover-*.png.
- As a popup surface the menu takes the pointer from the button (Qt cancels the press), so press-drag-release does not
  choose: the menu stays up as after a click (Finder's pull-downs behave the same). The in-window fallback keeps it.
- Dark menu face (rechecked): not lighter. Ours over the window (30,31,36) reads (57,60,68) and over a card (37,38,43)
  (62,65,74); the Mac's (60,62,69) and (65,67,73) over the same colours (control-*-open-dark.png beside the menu's edge):
  2-3 levels darker, nothing from Settings under or in the surface (it draws no fill there). The earlier "lighter" came
  from a session whose scratch appearance.json lacked `dark`, so the plugin stayed on its light appearance.
- Dark card: R3.8b dark (TahoeDark) cards and window are (37,38,43) / (30,31,36), the same as ours (#25262B / #1E1F24).
  Over a flat grey 127 desktop the Mac's are neutral 42 / 35 (sidebar 40; liquidglass-flat-grey-dark.png): the dark window
  follows the desktop. A fit on these two points (a luminance shift 0.044 x (Lum(mean) - 127), then the chameleon
  colour blend at 0.06) gives TahoeDark (30.4,30.9,35.8); not built, two desktops are not enough to call it the rule.
- Dark window follows the desktop (built 2026-11-14, OPEN-FIXES 12, R6.1 red / green / navy + grey 127): window 28.24 +
  0.0525 c, sidebar `Ch.apply(35.20 + 0.04253 c, c, true)`, cards unchanged (white .03 on top), c = the 6-bit mean
  under the centred window. Headless, ours / Mac: TahoeDark window (30,31,36) / same, card (37,38,43) / same (still
  #25262B), sidebar (35,37,51) / (35,37,52); red card (48,38,37) / (46,38,37), navy sidebar (34,34,51) / (35,35,53),
  the rest within 1. Light: window and cards stay 255 / 247 (no tint, also over grey 127); sidebar base #EDEDED (237
  over grey, Mac 237). Dark, not key: window #1D1E20 (29,30,32). WallpaperTint no longer reads back a quarter at 2x.
- An instant press + release (vptr "b", 0 ms) shows no menu in the headless session, also with the menu as it was
  before this round; a 150 ms click opens it. Not chased further (harness).

## Sidebar: rows scroll under the search field (settings/SettingsApp.qml)

| element | Mac (R3.9) | ours before | after | source |
|---|---|---|---|---|
| list top | AX scroll area from window y 98, rows scroll up behind the field (10,61 212x28) | list clipped at y 98: rows vanished 9 pt below the field | the list starts at the field's top (61) with a 37 pt content inset: rows rest at 98 and pass under the field | ax-sidebar-scrolled-2-*.jsonl, sidebar-scroll-*.mov |
| above the field | nothing of the rows in the traffic-light strip in any frame | n/a | clipped at the field's top | frames 0.9-1.7 s of the clip |
| under the field | a faint blur: the dark Wi-Fi icon darkens the field by ~20 of 214 levels | n/a | rows cut out of the list under the capsule, drawn there blurred (16 px) at 0.2 under the field's fill | frame 1.0 s, x 70: 207-210 against 228 |
| reveal of the selected row | n/a | could leave it under the field | keeps it below the 37 pt inset | |

## Scroll views: no mouse-drag scrolling

AppKit scroll views scroll by wheel, trackpad and the scroller only. Ours flicked on a mouse drag (Qt's default). Now
`acceptedButtons: Qt.NoButton` (Qt 6.9+) on the content view, the sidebar list, the Liquid Glass preview article, the
Displays strip and the Wallpaper strip; wheel and trackpad (RubberBand) unchanged.

## Panes (R3.8b, light first; dark checked on the same panes after)

Columns: element | Mac 27.2.1 | ours before | after | source (ax = live/settings/panes/ax-{pane}-light.jsonl, doc y in pt
from the content top). "Held" = a local control with no backend, as before. The Mac's en_GB strings are kept in the
app's US spelling where the app already used it (Color, Center, Minimize, Customize, Summarize).

### Appearance
| element | Mac | before | after | source |
|---|---|---|---|---|
| pop-ups | see the pop-up table | | | R3.8a |
| Folder colour button | one dot inside | an extra 16 pt dot beside the button | the button's own dot | control-folder-colour-rest-*.png |
| radio text | "Jump to the spot that’s clicked" | straight ' | ’ | ax 946.1 |
| preview article | wheel / trackpad only | also scrolled by a mouse drag | no drag | coordinator note, AppKit |

### Desktop & Dock
| element | Mac | before | after | source |
|---|---|---|---|---|
| Stage Manager card | + Show recent apps in Stage Manager (switch), Show windows from an application (All at Once) | missing | added, held | ax 673.6 / 711.1 |
| Click wallpaper to show desktop | Always | Only in Stage Manager (held) | Always (Mac value = macOS default) | ax 527 |
| Close windows when quitting | with its line "When enabled, open documents …" | no line | line added | ax 1076 |
| tiling rows | Drag windows to left or right edge of screen to tile / to menu bar to fill screen / Hold ⌥ key while dragging windows to tile | one row "Drag windows to screen edges to tile" | the three Mac rows, held | ax 1134-1209 |
| Mission Control | heading + line + 5 switches | missing | added (Card `subtitle`), held, Mac values | ax 1303-1534 |
| footer | Shortcuts…, Hot Corners…, Help | Hot Corners…, Help | Mac's | ax 1580.5 |
| controls on rows with a line | on the label's line | centred on the row | on the label's line (FormRow) | ax 1058.0 / 1058.5, 530.6 / 539 |
| rows with a line | 12 pt above and below | 8 | 12 (FormRow) | ax 518 → 530.6 |
| long labels | wrap (2 lines, AX 32 tall) | elided | wrap (FormRow) | ax 1406 |
| Widgets card, Default web browser | present | missing | not added: no desktop widgets, the dim pop-up's items not on a shot, no browser list | ax 768-889 |

### Displays
| element | Mac | before | after | source |
|---|---|---|---|---|
| built-in display | "Larger Text … More Space" picker | Resolution / Refresh rate rows (external-display rows) | unchanged: the picker needs the scaling owner (pixel.js / scale policy) | displays-00-light.png |
| rest | Brightness, auto, True Tone, Colour profile, When connected to TV, Advanced…, Night Shift…, Help | same | same | |

### Sound
| element | Mac | before | after | source |
|---|---|---|---|---|
| Balance | 246.5 pt slider, no fill, end ticks, Left / Right, knob centred | missing | added (held; no per-channel backend), track 1 pt over the label's centre | sound-01-light.png, ax 598.5 |

### Wallpaper
| element | Mac | before | after | source |
|---|---|---|---|---|
| tile caption | 10 pt ("Tahoe" 56 px of ink) | 13 pt (71 px) | 10 pt | wallpaper-00-light.png |
| Show All (N) | 11 pt, 69 pt wide | 13 pt, 79 | 11 pt | same |
| header | fixed; the sections scroll under it (ScrollArea "Wallpapers" from y 142) | scrolls away with the pane | pinned (see below) | ax 142 |
| sections | Dynamic, Your Photos, Landscape, Shuffle Aerials, Pictures, Colours | the installed sets | unchanged (data) | |

### Accessibility
| element | Mac | before | after | source |
|---|---|---|---|---|
| Hearing | Hearing Devices, Audio, RTT, Subtitles and Captioning, Live Captions, Name Recognition | "Captions", no RTT | "Subtitles and Captioning"; RTT not added (tile not extracted) | ax 716.5-931.5 |
| Speech / General | Speech: Live Speech, Personal Voice, Vocal Shortcuts; General: Siri, Shortcut | Siri under Speech | Siri first in General | ax 1029.5-1256.5 |
| Help | 24 pt "?" 20 below the last card | none | PaneFooter | ax 1318.5 |

### General
| element | Mac | before | after | source |
|---|---|---|---|---|
| hero | 164 tall, 50 pt tile 25.5 in, title 22 pt bold, 13 pt text on 16 pt lines, 448 wide | ~152, tile 56, title 18, text 11 pt | Mac's (HeroCard full layout; Theme heroIcon 50) | general-00-light.png, ax 12-156 |
| toolbar title | none until the hero's title scrolls under | always | hidden until then (`toolbarTitleAfter`) | general-00 / -01 |
| rows | 48 pt (pitch 49) with a chevron | 38, no chevron | 48 + chevron | ax 186-868 |
| row tile / label | tile 22 at 12.5 in, label at 47.5 (ink px 529 / 600) | 20 at 10, label 40 | 22 at 12.5, label 47.5 (FormRow iconX / labelGap); ours px 529 / 599 | general-00-light.png |
| order / names | [About, Software Update, Storage] [AppleCare & Warranty] [AirDrop & Continuity] [AutoFill & Passwords, Date & Time, Language & Region, Login Items & Extensions, Sharing, Startup Disk, Time Machine] [Device Management] [Transfer or Reset] | AirDrop & Handoff + Login Items; Language, Date, Sharing, Time Machine, Transfer, Startup | Mac's order and names; AppleCare & Warranty, AutoFill & Passwords, Device Management not added (tiles not extracted) | ax |

### Siri
Not rebuilt: 27.2.1's pane is the Apple Intelligence one (Requests, Language, Voice, Responses, Siri App, ChatGPT
extension, Automatic Visual Look Up, Excluded Apps, Suggestions, Accessibility Settings, Turn Off Siri: ax-siri-light.jsonl),
ours the older Siri / Listen for / Keyboard shortcut. Left for a decision (all of it would be held rows with no backend).

### Menu Bar (control-center)
| element | Mac | before | after | source |
|---|---|---|---|---|
| layout | Auto-hide pop-up, Show menu bar background, Recent documents; Show suggestions in Control Gallery; Menu Bar Controls (line + Add Controls…); the controls list (checkbox, 22 pt tile, name, pop-up / Options button); Allow in the Menu Bar; Reset Control Centre…, Help | "Control Center Modules" / "Menu Bar Only" (older layout) | the Mac's rows in order, held; controls rows 42 (+1), checkbox 13.5 in, tile 37 in, pop-up off with its checkbox | ax 18.5-1856.5, control-center-00/01-light.png |
| not added | Screen Mirroring, Keyboard Brightness, Timer, Weather rows; the illustration; Allow in the Menu Bar | | tiles / list not available | |

### Spotlight
| element | Mac | before | after | source |
|---|---|---|---|---|
| layout | compact hero; Show Related Content (+ line, link); Reset Quick Keys, Spotlight Search History; Help Apple Improve Search (+ text, link); Results from System (Apps, Files, Folders, iPhone Apps, Menu Items); Results from Clipboard (+ line), Clear Clipboard History; Search Privacy…, Help | "Search results" list of 11 categories + Help Apple improve Search | the Mac's, held; FormRow `sublink` / `sublabelGap` (6.5, 13.5) | ax 22-833.5 |
| not added | Clipboard history is available in Spotlight (8 hours) | | the pop-up's other items not on a shot | ax 737.5 |

### Notifications
| element | Mac | before | after | source |
|---|---|---|---|---|
| layout | compact hero with Learn more…; Notification Centre heading + line; Show previews; "Show Notifications:" with 3 indented rows (x 61); Allow notifications from iPhone; Summarise (row into a page); Application Notifications rows 52 | heading only, 5 flat rows | hero, heading line, the indented rows (FormRow `leftInset` 31), app rows 52 | ax 22-480.5 |
| kept | | | the mirroring row stays a switch (Mac: a pop-up "Notifications Off", its other item not on a shot); Summarize stays a switch; app rows keep their Off / Banners / Alerts pop-up | |
| not added | Allow notifications from iPhone | | no iPhone | |

### Focus
| element | Mac | before | after | source |
|---|---|---|---|---|
| modes | rows 52 with a chevron | 38, no chevron | 52 + chevron | ax 12-277 |
| Share across devices | + line | no line | line added | ax 401 |
| Focus status | row with line, value On, chevron (68 tall) | "On" button | row with line, value, chevron | ax 449 |
| Help | at the end | none | added | ax 537 |

### Lock Screen
| element | Mac (MacBook) | before | after | source |
|---|---|---|---|---|
| display off | on battery / on power adapter (+ warning line at Never) | one row | one row on a desktop, two with a battery; the warning line at Never | ax 18-78 |
| removed | | Start Screen Saver when inactive, Show large clock (not in 27.2.1's pane; nothing read them) | removed | ax |
| switches | Show username and photo, Show password hints, Show message when locked + Set… | Show password hints under When Switching User | the Mac's card | ax 219.7-294.7 |
| Login window shows | two radios | a pop-up | radios (16 apart) | ax 437.2 |
| footer | Accessibility Options…, Help | Help | Mac's | ax 521 |
| not added | iPhone Mirroring line, Show Live Activities when locked | | no iPhone | |

### Privacy & Security
| element | Mac | before | after | source |
|---|---|---|---|---|
| layout | compact hero; Location Services card; data classes; device classes; …; Security: Allow applications from, FileVault, Accessories, Background Security Improvements, Lockdown Mode + line; Advanced…, Help | "Privacy" heading + 9 rows, Security with a Turn On… button | hero, Location card, data card (Calendars, Contacts, Files & Folders, Photos), device card (Camera, Microphone, Screen & System Audio Recording), chevrons; FileVault / Lockdown Mode as rows (value Off), the Lockdown line, Advanced… | ax 22-1833 |
| removed | | Accessibility row (not in 27.2.1's list) | removed | ax |
| not added | ~20 classes and Security rows without tiles here | | | |

### Wi-Fi, Bluetooth, Network
| element | Mac | before | after | source |
|---|---|---|---|---|
| Wi-Fi first row | hero line: 26 pt tile, "Set up Wi‑Fi to …" + Learn More…, switch at the top | "Wi-Fi" + Connected | the hero line | ax-wifi 21-53.5 |
| Ask to join hotspots | + line "Allow this Mac to automatically discover …" | no line | added | ax-wifi 843.5 |
| Bluetooth first row | hero line "Connect to accessories …" + Learn more…, switch at the top; "discoverable as" on a card of its own | discoverable line as the sublabel | Mac's | ax-bluetooth 21-54.9 |
| Network | rows 52 with a dot + state under the name and a chevron: connected services, then VPN + Firewall, then Other Services | one card of devices with a trailing dot, Firewall value, VPN under Other Services | Mac's grouping, FormRow `subdot`, "Not connected" | ax-network 12-572 |

### Keyboard, Trackpad
| element | Mac | before | after | source |
|---|---|---|---|---|
| repeat sliders | side by side in one card, 214 wide, 8 / 6 tick dots, Off / Slow / Fast, Long / Short | two rows, 260 wide, no ticks | Mac's layout (values stay continuous; the Mac snaps) | keyboard-00-light.png, ax 46 |
| Keyboard Shortcuts…, Text Replacements… | inside their cards, right-aligned | Shortcuts… under the card; no Text Replacements… | inside, both | ax 325 / 470 |
| Trackpad | Tracking speed / Click sliders (Slow-Fast; Light-Medium-Firm), Force Click line, "Click with Two Fingers" with Tap to click off, Tap to click line | Click as a pop-up, no lines, Tap to click on | Mac's | ax-trackpad 209-473.5 |
| not added | the tab bar with its illustration and video; keyboard brightness rows (MacBook) | | no assets / no backlight | |

### Wallpaper header (after)
Pinned: the header follows the content view's offset over the window colour down to its divider, the sections scroll
under it, no toolbar hairline / pocket on this pane (`pinnedHeader`).

### Not changed
VPN, Battery / Energy (ours is the desktop Energy pane; the shot is a MacBook's Battery).

## Verification
Headless session at 2x, light and dark, every pane above captured at its top and after 30 wheel notches, side by side
with the R3.8b stills (scratch, not in the repo). Tests: settings node 52, ui qml 98, settings tst_appearance 8,
tst_symbols 6, shell 403; all pass.

## Icon & widget style tiles (2026-11-15, user: "perhatikan juga setiap icon dan gambar")

| | Mac 27.2.1 | ours before | ours now | evidence |
|---|---|---|---|---|
| what a tile is | the Weather app's icon in that style: `ISIcon(bundleIdentifier: "com.apple.weather")` + `ISImageDescriptor` in an `AsyncIconImage` (Appearance.appex `IconStyleRow`, strings of `~/Downloads/macos/extracted/appearance/Appearance-arm64`) | a flat rounded square, an 11 pt sun disc and SF `cloud.fill` | the same icon, composed by the IconRendering port (`themes/icons/tools/build-style-tiles.py`, `settings/assets/icon-style/*.png`, 20 files) | iconstyle-*-light.png; decoded |
| size | 72 px image, 58 px body (36 pt, body 29) | 29 pt square | 36 pt image centred on the 29 pt tile | fitted: best side 72 of 70-74, rms 10-16 levels |
| Clear / Tinted tiles | follow the radios: Dark + Always in light mode shows the dark Clear and Tinted; Light, and Auto in light mode, the light ones | one drawing each | `iconStyleVariant` dark, or auto in dark mode: the dark files | iconstyle-dark-light.png, iconstyle-tinted-light.png, appearance-full-dark.png |
| Tinted tile's colour | the chosen colour; Automatic = blue under the Multicolour accent | a flat fill of the colour | the tinted rendition of that accent (8 colours x light / dark) | iconstyle-tinted-red-auto-light.png |
| Default / Dark tiles | never change | | `default.png` (Apple's bitmap), `dark.png` | all captures |

Not known: what Clear and Tinted show with Default selected in dark mode (ours follows the stored mode, Auto = the
system's). Other panes: all 20 snapshotted at 2x (headless, light); no missing or broken icon or image file (no load
warning in any log); not compared pixel by pixel this round.
