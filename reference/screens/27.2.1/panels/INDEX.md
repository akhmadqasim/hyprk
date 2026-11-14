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
