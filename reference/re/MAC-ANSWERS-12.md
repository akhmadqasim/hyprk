# Answers from the Mac session, round 12 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #170 from the PC: System Settings sub-panes. Capture only; **no setting was changed**. Everything is under
`re/27.2.1/live/settings-r12/` (see its `INDEX.md`). Conditions: display 1440x932 at 2x, window 740x625 pt at 350,150,
Tahoe wallpapers, Stage Manager off. Names, serial number, device names, app lists and location strings are blurred in
the stills and replaced by `[redacted]` in the AX dumps; the sidebar's account and Family rows are blurred.

## R12.1 Accessibility, top pane and every sub-pane: done
- Stills: `accessibility-NN-{light,dark}.png` (top pane, 4 scroll steps) and `acc-<name>-NN-{light,dark}.png` for the
  **22 sub-panes**: voiceover, zoom, hover-text, display, motion, read-speak, audio-descriptions, voice-control,
  keyboard, pointer-control, switch-control, hearing-devices, audio, rtt, subtitles-and-captioning, live-captions,
  name-recognition, live-speech, personal-voice, vocal-shortcuts, siri, shortcut. `NN` = scroll step (300 pt wheel
  steps from the top until the content stops moving). Window shots (`screencapture -o -l`), 1480x1250 px.
- AX: `ax-<same name>-NN-{light,dark}.jsonl`: every element with frame, role, subrole, title/description/value,
  identifier, enabled.
- Top pane (AX): a placard (icon, "Accessibility", description, "Learn more…" link), then groups with an AXHeading
  each: **Vision** (7 rows), **Physical and Motor** (4), **Hearing** (6), **Speech** (3), **General** (2), and a Help
  button. Rows are **AXButton 468x42 pt** at x 602 (window x 252), identifiers `AX_FEATURE_*`, pitch 42-44 pt, chevron
  at the right. Content height about 1340 pt.
- **Toolbar in a sub-pane** (same geometry as the top pane):
  - back/forward capsule: group 590,158 **73x36**; Go Back 590,158 36x36, Go Forward 626,158 37x36 (AXSegment). In
    the top pane Go Back is disabled (AXMenuButton); in a sub-pane **Go Back is an enabled AXButton** and Go Forward is
    disabled; after going back, Go Forward becomes enabled.
  - title: one AXStaticText **667,150 411x52**, left-aligned right after the capsule, showing the sub-pane's name
    ("VoiceOver"). **No centred title and no in-content back link.**
  - The sidebar keeps "Accessibility" selected while a sub-pane is shown.
- Sub-pane content starts with the same kind of placard as a top pane (icon + name + description, often with the main
  switch at the right), then grouped rows. Example VoiceOver: placard with switch, two buttons "Open VoiceOver
  Tutorial…" 673,347 182x24 and "Open VoiceOver Utility…" 865,347 171x24, Help 1046,347 24x24.

## R12.2 Push transition Accessibility ↔ VoiceOver: done
- `push-accessibility-voiceover-light.mov` (AXPress on the row and on Go Back), `push-accessibility-voiceover-dark.mov`
  (real synthetic mouse clicks, pointer shown). Region 582,150 508x625 pt (content + toolbar, no sidebar), 60 fps VFR.
- **There is no push animation: it is a hard cut.** The content and the toolbar title change in a **single frame**,
  both forward and back (light: frames at 1.167 s and 3.383 s; dark: 1.233 s and 3.450 s; the frames before and after
  are static). With the mouse, the row shows its pressed highlight for about 0.1 s first (1.117 → 1.233 s), then the
  cut. No slide, no cross-fade, no title animation.

## R12.3 Rows that navigate, every sidebar pane: done
- `NAV-ROWS.md` (readable tables) and `nav-rows.json`: for each of the **29 panes** (Wi-Fi … Printers & Scanners; the
  Apple Account, Family and the third-party GPG pane were left out; there is no Mouse pane because no mouse is
  attached), every element that navigates, with AX role, label, size, enabled and kind. 236 entries.
- The patterns:
  - **Full-width row → sub-pane**: `AXButton`, 468 pt wide, 36-52 pt tall, chevron at the right (General's 14 rows,
    Accessibility's 22, Privacy & Security's rows, Network's interfaces, Notifications' app rows, Focus modes,
    Screen Time rows).
  - **Small button with "…" → sheet**: `AXButton`, 24 pt tall ("Hot Corners…", "Advanced…", "Night Shift…",
    "Keyboard Shortcuts…", "Edit…", "Options…").
  - **Pop-up menu**: `AXPopUpButton` 24 pt tall (also `AXMenuButton` for "Add"/"More").
  - **Tabs in place**: `AXRadioButton`/`AXTabButton` inside an `AXTabGroup` (Sound Output/Input, Trackpad's three tabs).
  - **Help**: `AXButton` "Help" 24x24 at the bottom right; **links**: `AXLink` ("Learn more…").
- One still + AX dump of each target opened (dark): `nav-<pane>--<target>-dark.png` (region shot of the window rect, so
  sheets are included), `ax-nav-<pane>--<target>-dark.jsonl`.

| pane | target | opens as | size (pt) |
|---|---|---|---|
| General | About, Software Update, Storage, AppleCare & Warranty, AirDrop & Continuity, AutoFill & Passwords, Date & Time, Language & Region, Login Items & Extensions, Sharing, Startup Disk, Time Machine, Device Management, Transfer or Reset | sub-pane (title changes, Go Back enabled) | window |
| Desktop & Dock | Shortcuts… | sheet | 470x326 |
| Desktop & Dock | Hot Corners… | sheet | 630x193 |
| Displays | Advanced… | sheet | 470x432 |
| Displays | Night Shift… | sheet | 470x331 |
| Notifications | Allow notifications from iPhone; Summarise notifications; an app row (Finder) | sub-pane | window |
| Keyboard | Keyboard Shortcuts… | sheet | 670x468 |
| Keyboard | Edit… (Input Sources) | sheet | 640x509 |
| Keyboard | Text Replacements… | sheet | 470x182 |
| Keyboard | Edit… (Dictation languages) | sheet | 420x403 |
| Keyboard | About Ask Siri, Dictation & Privacy… | sheet (privacy text, OK button) | 482x550 |
| Trackpad | Point & Click / Scroll & Zoom / More Gestures | tabs, content swaps in place | — |

  - Sheets are centred horizontally on the window and dim it; **Escape closes them**, except the privacy sheet, which
    only closes with its OK button. Sheet = `AXSheet` child of the window with a Done (or Cancel/OK) button.
  - **Appearance and Sound have no sheet or sub-pane**: only pop-up menus, tiles, sliders and (Sound) the Output/Input
    tabs. Displays' "Built-in Display" tile is an AXButton but was not opened.
  - Not opened: anything that needs a password or would change something (Touch ID & Password "Change…", Users &
    Groups "Add User…", "Set Up Keyboard…" and "Set Up Bluetooth Trackpad…", which launch a setup assistant, "Erase All
    Content and Settings…", "Restart…"), and pop-up menus (round 3 has the pop-up menu clip).
  - The General sub-pane "Login Items & Extensions" has the toolbar title "Login Items".

## Restored and checked
System Settings quit, wallpaper store copied back + `killall WallpaperAgent`, Stage Manager on, `CreateDesktop` deleted
+ Finder restarted, dark mode on, display 1710x1107, volume 38, the Tahoe wallpaper copies moved out of `~/Pictures`.
No toggle was touched.
