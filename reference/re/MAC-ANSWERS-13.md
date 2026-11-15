# Answers from the Mac session, round 13 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #172 from the PC. Same method as round 12: capture only, **no setting changed** (every pop-up menu was closed
with Escape and its value read back unchanged; sheets closed with Escape, or Done/OK where Escape does nothing).
Everything is under `re/27.2.1/live/settings-r13/` (see its `INDEX.md`). Display 1440x932 at 2x, window 740x625 pt at
350,150. Region shots of the window rect, so sheets are included.

Privacy: network names, hotspot and VPN names, IP/MAC addresses, app lists (Privacy & Security sub-panes, Firewall
options, "Allow in the Menu Bar"), allowed contacts in Focus, device names, the "Your Photos" wallpaper row and the
sidebar's account rows are **blurred** in the stills and `[redacted]` in the AX dumps. Layout, row heights, switches and
chevrons stay visible.

## R13.1 Destinations: done (Mouse does not exist here)
- `DESTINATIONS.md`: 74 destinations with how each opens, the toolbar title, sheet size and the trigger's AX role.
  Stills `dest-<name>-{dark,light}.png`, AX `ax-dest-<name>-{dark,light}.jsonl`. **49 sub-panes, 24 sheets, 1 popover.**
- Per pane:
  - **Wi-Fi**: Details… (sheet 670x425, with a left list of sections), Other… (sheet 400x325, "Add a Wi-Fi Network
    Profile"), Advanced… (sheet 470x532, known networks table).
  - **Network**: rows Wi-Fi, VPN, Firewall and one row per interface (USB LANs, Thunderbolt Bridge, iPhone USB) are
    sub-panes. Wi-Fi there is the same pane as the sidebar's. Firewall → Options… (sheet 500x532). Each Ethernet-type
    interface → Details… (sheet 670x425). The "…" menu button's items are in `POPUPS.md`.
  - **Battery**: Options… (sheet 470x347). Battery Health's info button was not opened.
  - **Menu Bar**: Clock Options… (sheet 470x533), Battery Options… (sheet 470x210). "Add Controls…" was not opened.
  - **Spotlight**: the small info button (13x13) → sheet 500x533; Search Privacy… → sheet 470x375.
  - **Wallpaper**: Screen Saver… (sheet 500x548); **Clock Appearance… is a popover** (window 430x188, bubble about
    398x154 with an arrow under the button; it extends past the window's right edge).
  - **Focus**: each Focus (Do Not Disturb, Driving, Mindfulness, Reduce Interruptions, Sleep, Work) and "Focus status"
    are sub-panes ("Focus status" only in the light set). "Add Focus…", "Add Schedule…", "Delete Focus…" not opened.
  - **Lock Screen**: Accessibility Options… (sheet 470x479). "Set…" (lock message) is disabled while its switch is off.
  - **Privacy & Security**: 33 rows are sub-panes (Location Services … Lockdown Mode; rows are AXButton 468x42 or
    468x52), "Advanced…" is a sheet 470x199. Inside: Location Services → Details… (sheet 470x533), Photos → Options…
    (sheet 470x260), Apple Advertising → View Ad Targeting Information… (sheet 500x400). FileVault "Show" and
    Lockdown Mode "Turn On…" need a password / change something: not pressed.
  - **Mouse**: no mouse is attached, so the sidebar has no Mouse pane. Not captured.

## R13.2 Pop-up menus: done
- `POPUPS.md` (readable) and `popups.json` (titles, checked mark, enabled, separator, submenu, item frames, button
  frame, menu frame): **47 pop-up buttons** in 15 panes, one still each: `pop-<pane>-NN-dark.png` (crop of the button
  row and the open menu; the rest is masked grey).
- Panes with none: General, Accessibility (top), Siri, Focus, Screen Time, Touch ID & Password. Left out on purpose:
  Wi-Fi, Bluetooth, VPN, Users & Groups, iCloud, Internet Accounts, Wallet (menus hold account data).
- Pattern: the menu opens **over the button with the checked item aligned on the button's value** (e.g. Dock position:
  button 968,325 92x24, menu 956,297 92x82, items 24 pt tall, 5 pt top/bottom padding). `AXMenuItemMarkChar` = ✓ on
  the current item. Separators are untitled, disabled items less than 16 pt tall.
- A few menus expose no AX items (Menu Bar "Always Show" / "Fast User Switching", Lock Screen "Require password…",
  one Wallpaper menu button): the stills show what appeared.

## R13.3 Keyboard Shortcuts groups: done
- `ks-NN-<group>-{dark,light}.png` + `ax-ks-NN-<group>-{dark,light}.jsonl`. The left list has **14** rows here, not
  13: Dock, Display, Mission Control, Windows, Keyboard, Input Sources, Screenshots, Presenter Overlay, Services,
  Spotlight, Accessibility, App Shortcuts, Function Keys, Modifier Keys.
- Sheet 670x468 at window 35,78; left list 200 pt wide, rows 32 pt (AXOutlineRow; the label is an AXUnknown with the
  description "Dock shortcuts" etc.), right side 470 pt with "Restore Defaults" bottom-left and "Done" bottom-right.
  Function Keys has only a switch; Modifier Keys has a keyboard pop-up and five key pop-ups.

## R13.4 General: AppleCare & Warranty, AutoFill & Passwords, Device Management: done
- `nav-general--appleCareAndWarranty-{dark,light}.png`: redone with only the device-name lines blurred (round 12
  blurred the whole rows), so the tiles show: section headers "This Device" / "All Devices", rows with icon, name,
  "Coverage Expired" subtitle and chevron, "Includes Family" with a "Show All" button. The light shot caught the
  loading spinner (the list loads from the network); use the dark one for the loaded layout.
- `nav-general--passwords-light.png` (promo tile "All Your Passwords in One Place" with close button and "Open
  Passwords", then switches and a pop-up) and `nav-general--deviceManagement-light.png` ("Work or School Account" tile
  with "Sign In…", empty profiles list with + / −). Dark versions are in `settings-r12/`.

## R13.5 Light stills for the round 12 sheets and sub-panes: done
- `nav-<pane>--<target>-light.png` + `ax-nav-…-light.jsonl` for all 29 round-12 targets (14 General sub-panes,
  Desktop & Dock and Displays sheets, 3 Notifications sub-panes, 5 Keyboard sheets, 3 Trackpad tabs), same names as
  in `settings-r12/` with `-light`.

## Restored and checked
System Settings quit, wallpaper store copied back + `killall WallpaperAgent`, Stage Manager on, `CreateDesktop` deleted
+ Finder restarted, dark mode on, display 1710x1107. No toggle or menu value was changed.
