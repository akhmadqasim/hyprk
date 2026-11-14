# Panels, macOS 27.2.1 (26B131), MacBook Air M2, 2x

## Setup
- **Account:** user account. Multicolour accent; icon & widget style Dark; Liquid Glass 0.5; customised Control Center.
- **Wallpaper:** Tahoe Light / Tahoe Dark for the `-light` / `-dark` reference shots.
- **Crops:** at 2x unless noted "1x". Every Finder window behind the surfaces shows only system folders.

## Blurred for privacy
- Wi-Fi network name and the HomeKit accessory name in Control Center.
- File names in Spotlight Files mode.
- All items in Spotlight Clipboard mode.

## Not captured
Notification Center (it holds the user's notifications). The numbers are in `reference/re/27.2.1/live/panels/`.

## Files

| File | What |
|---|---|
| `controlcenter-{light,dark}.png` | Control Center, x 1386..1710, y 34..622. In light the Dark Mode button is off; in dark it is on. |
| `spotlight-empty-{light,dark}.png` | Empty bar, "Search or Ask", mic. Dark capsule in both modes on this account. |
| `spotlight-modelist-{light,dark}.png` | Mode list that drops down while the pointer is over the empty bar (⌘1..⌘4). |
| `spotlight-calculator-{light,dark}.png` | "2+2": inline answer, result card inside the grown bar, "Show Results" capsule. |
| `spotlight-cmd1-applications-{light,dark}.png` | ⌘1 Applications view (1x). |
| `spotlight-cmd2-files-{light,dark}.png` | ⌘2 Files view (1x). Content blurred; chips visible. |
| `spotlight-cmd3-actions-{light,dark}.png` | ⌘3 Actions list. |
| `spotlight-cmd4-clipboard-{light,dark}.png` | ⌘4 Clipboard list. Rows blurred. |
| `alert-{light,dark}.png` | App-modal NSAlert from the own probe (`tools/probe/panels.swift alert2`). |
| `sheet-alert-{light,dark}.png` | NSAlert as a sheet. Centred on the parent, which is dimmed (1x, whole parent window). |
| `sheet-{light,dark}.png` | Custom 440x220 sheet: solid, r 16, centred, parent dimmed (1x). |
| `sheet-textedit-save-dark.png` | TextEdit Save sheet on a new untitled test document (1x, whole parent window). |
| `popover-{light,dark}.png` | NSPopover from the probe. |
| `emoji-picker-dark.png` | Emoji & Symbols popover (Ctrl-Cmd-Space in TextEdit on an own test file), Smileys tab. Window capture with shadow. |
| `cc-nowplaying-idle-dark-grey127.png` | Now Playing tile, idle, over a grey 127 backdrop. |
| `cc-nowplaying-playing-dark-grey127.png` | Now Playing tile while playing an own silent test track in QuickTime. |
| `cc-states-rest-tilehover-tilepress-roundpress-circlepress-dark-grey127.png` | Stage Manager / Screen Mirroring / Focus area. Left to right: rest, 2x1 tile hover (chevron appears), tile pressed, round button pressed (grows about 5 %), toggle circle pressed. |
| `cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png` | Sound module, frames from 60 fps video. Top to bottom: rest (no knob), hover (white 18x14 knob + chevron), dragging (glass lens 24x20), dragged past the end (track stretched about 4 pt). |
| `banner-dark-grey127.png` | Own test banner (title + subtitle + body), 344x75, r 20. |
| `banner-dark-black.png` | The same over black. |
| `banner-4line-dark.png` | 4-line body, max 4 lines then "…". |
| `banner-4line-hover-dark.png` | Hover: close button on the top-left corner, ">" at the top right, "Show" action capsule. |

## Round 2 (M2.7): menu bar status modules
Display 1440x932 pt (2x). Wallpaper TahoeLight / TahoeDark. Opened by a synthetic click on the menu bar item, full-screen
`screencapture -x`, then cropped around the panel (px x 1888..2543 or 1810..2465, from y 40: a strip of the menu bar is
included). The Focus item was set to "Always Show" for the shots and turned off again.
Blurred for privacy: the two Personal Hotspot names and the known network name in the Wi-Fi module (3 x Gaussian 14 px
over each name; the icons, signal / 4G / battery glyphs and lock are untouched).

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| module-wifi-light.png | full screen, crop 1888,40 655x586 px | Wi-Fi module: header + switch, Personal Hotspots (2), Known Network (1, connected, lock), Other Networks >, Wi-Fi Settings… | light | TahoeLight |
| module-wifi-dark.png | same | same | dark | TahoeDark |
| module-battery-light.png | full screen, crop 1810,40 655x505 px | Battery module: 100 %, Power Source, Fully Charged, Energy Mode (Low Power), Using Significant Energy (1 app), Battery Settings… | light | TahoeLight |
| module-battery-dark.png | same | same | dark | TahoeDark |
| module-focus-light.png | full screen, crop 1888,40 655x600 px | Focus module: 6 focus rows (Do Not Disturb, Work, Sleep, Mindfulness, Reduce Interruptions, Driving), none on, Focus Settings… | light | TahoeLight |
| module-focus-dark.png | same | same | dark | TahoeDark |

## Round 3 (R3.2): Spotlight in light mode over a white window
Display 1440x932 pt (2x), light, desktop grey 127 (hidden by the window). Behind: one empty TextEdit document resized to
0,29 1440x851 pt (the Dock limits the height), other apps hidden. Spotlight opened with Cmd-Space, closed with Esc.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| spotlight-light-white-empty.png | full screen `screencapture -x`, 1.5 s after Cmd-Space | empty "Search or Ask" field (it renders dark over the white window) | light | white TextEdit window |
| spotlight-light-white-results.png | full screen, 2 s after typing "text" | field "textEdit — Open" + results panel (TextEdit, Text, Text replacements, Text size …; no files listed) | light | white TextEdit window |
| spotlight-light-white-open-close.mov | `screencapture -x -v -V 3.5 -R 300,100,840,600`, 2.78 s | Cmd-Space at about 0.5 s, Esc about 1.5 s later | light | white TextEdit window |

## Round 3 (R3.2b): Spotlight pill idle / hover / clear
Display 1440x932 pt (2x). Behind: one empty TextEdit document at 0,29 1440x851 pt (white in light, dark grey in dark
mode), other apps hidden. Spotlight opened with Cmd-Space (System Events keystroke). Pointer parked at 20,900 pt (bottom
left, not a hot corner). Clips `screencapture -x -v -R 300,100,840,600` (H.264, 60 fps time base, VFR). The idle and
hover clips are untouched; the clear clips were re-encoded (x264 crf 12, same timestamps) to blur the result rows below
y 575 pt (clip px y 950..1200, x 320..1360): the "te" results there include browsing history.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| spotlight-pill-idle-light.mov | clip 3.3 s, Cmd-Space at about 0.3 s, pointer never moves | open animation, then the bare pill only | light | white TextEdit |
| spotlight-pill-idle-dark.mov | same | same | dark | dark TextEdit |
| spotlight-pill-idle-light.png | full screen `screencapture -x` right after the idle clip | bare pill: "Search or Ask" + mic, nothing below | light | white TextEdit |
| spotlight-pill-idle-dark.png | same | same | dark | dark TextEdit |
| spotlight-pill-hover-light.mov | Spotlight already open; clip 4.5 s; pointer glides from 20,900 to the bar centre 720,248 (starts about 0.6 s, 15 steps, about 0.7 s), rests about 1.3 s, glides back to 20,900 | mode list appears under the pill as soon as the pointer starts moving, stays after it leaves | light | white TextEdit |
| spotlight-pill-hover-dark.mov | same | same | dark | dark TextEdit |
| spotlight-pill-clear-light.mov | Spotlight already open; clip 5.5 s; "te" typed about 0.5 s, then 3 Backspaces 0.35 s apart from about 2.0 s (the first one removes the autocomplete "rminal — Open"), pointer at 20,900 | results panel, then the field goes empty and the panel collapses to the bare pill | light | white TextEdit |
| spotlight-pill-clear-dark.mov | same | same | dark | dark TextEdit |

## Round 3 (R3.4): volume HUD appear and fade
| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| hud-volume-appear-grey-dark.mov | `screencapture -x -v -V 4.5 -R 960,29,480,200` (2x, H.264 60 fps time base, VFR), display 1440x932 | one Volume Up key press (synthetic NX_KEYTYPE_SOUND_UP system-defined event, the same path as the F12 key) at about 0.5 s, volume 81 -> 88 (one step), then the HUD fades; volume set back to 81 after | dark | grey 127 |

## Round 4 (R4.2): Wi-Fi module hover, Focus module with a Focus on
Display 1440x932 pt (2x), wallpaper TahoeLight / TahoeDark, other apps hidden. Module opened by a synthetic click on the
menu bar item, pointer moved with CGEvents, full-screen `screencapture -x` 0.9 s later, cropped to pt 930,25 360x254
(Wi-Fi). Network names blurred: each `wifi-network-*` checkbox (AX, ControlCenter process), from 30 to 190 pt into the row.
Note: `screencapture` stills do not draw the pointer.

| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| module-wifi-hover-row-{light,dark}.png | pointer on the Known Network row centre (1107,181) | row hover highlight (full-width rounded fill) | both | TahoeLight / TahoeDark |
| module-wifi-hover-toggle-{light,dark}.png | pointer on the Wi-Fi switch (1220,51) | no visible hover change on the switch or the header row | both | same |
| module-focus-driving-on-{light,dark}.png | region 930,25 360x290 pt | Focus module with **Driving** on (header "Focus / On", Driving icon filled); stands in for "Do Not Disturb on", see MAC-ANSWERS-4 | both | same |

## Round 4 (R4.4): Spotlight mode list in dark, white window vs grey desktop
| file | how taken | content | mode | backdrop |
|---|---|---|---|---|
| spotlight-modelist-white-dark.png | full screen `screencapture -x`; Cmd-Space, pointer moved 10 small steps near the bottom-left corner, still 1.2 s later | pill + mode list (Applications ⌘1, Files ⌘2, Actions ⌘3, Clipboard ⌘4) | dark | Preview window 0,29 1440x903 showing an all-white 2880x1600 PNG (image area white, Preview's dark chrome around it) |
| spotlight-modelist-grey-dark.png | same | same | dark | desktop RGB 127 grey, apps hidden |
