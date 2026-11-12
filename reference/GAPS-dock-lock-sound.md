# Dock, lock screen and sound against the Mac (re22, 2026-11-12)

Headless session, scale 2 (2560 x 1664, 1280 x 832 pt), tile 64 (no `size` in dock.json, the Mac's built-in default),
default items with Finder running, dark and light. Positions in pt. Dock numbers against the AX frames in
`live/dock/dock-geometry.json` (tile 64) and Q-dock-02..10; the lock screen against `screens/27.2.1/lock/full-*-locked-1x.png`
(1 px/pt, ours resampled to 1x); sounds against `re/27.2.1/live/sounds-27.2.1.json` (sha256 of the Mac's own files).

## Ranked differences
1. FIXED. Dock menu (right click) placement: Mac window x = icon centre - 40, window bottom = Dock top, body inset 13
   (Q-dock-10, `live/dock/dock-menus.json` geometry), so the body starts 27 left of the icon centre and ends 13 above
   the Dock; ours was centred on the icon and ended on the Dock top (Finder menu body 344..498, bottom 742.5 with the
   icon centre at 420.5 and the Dock top at 743) -> body from 394 (26.5 left of the centre), bottom 729.5, dark and light.
2. OPEN, plugin. Dock menu shape: Mac a glass bubble with a tail at the icon centre, like the hover label, radius about 14
   (Q-dock-10, visual); ours a plain menu with no tail. The label's pointer is a plugin marker (Theme.dock.labelPointer,
   plugin/README.md "Dock label pointer"); the menu would need the same marker on its own surface, hung at the icon
   centre (now 27 pt in from the body's left edge) under the body's 13 pt inset.
3. OPEN, not settled. Hover label width: ours "Finder" 70..71 including the rim's soft edge (diff against a frame without
   the label), Mac 67.5 (Q-dock-08: text + 2 x 14). The rule is the Mac's; the 2..3 pt is the text width of our font
   or the edge threshold. Wants an ink-to-ink measure on a solid backdrop. Height 26 and tail tip 2.5 above the Dock match.
4. OPEN, small. Dragging a file onto the Dock Trash: Mac plays `dock/drag to trash.aif` (ID 16, MAC-ANSWERS "Sounds per
   event"); the shell's Dock takes no file drops, so `trash-move` has no caller in the Dock (Finder only).

## Matched (within 1 pt / 4 levels)
- Dock at tile 64: background height 84 (AX 84), gap to the screen bottom 5 (5), width with 7 items + 1 separator 525
  (AX rule 2 x 8.9 + 7 x 68 + 30.6 = 524.4), icon art 51 (50.5), art top 16.5 below the background top (17), art bottom
  16.5 above its bottom (16.5), running dot 4 wide (4.1) centred on the tile, 5.5 below the art (5, pixel threshold),
  separator 1 pt.
- Hover label: capsule 26 tall, tail tip 2.5 above the Dock background (Q-dock-08).
- Lock screen, dark and light: date line centre y 118 (Mac 118), clock ink 152..265 (152..265), password field 160 x 27
  (160 x 27) with its bottom 86 above the screen bottom (87), "?" button beside it, hint line 71 above the bottom (71).
  Differences that are not gaps: the Mac shot's locale ("Wed 11 Nov", "09.07"; ours follows the session's locale) and its
  "Touch ID or Enter Password" (no Touch ID here).
- Sound: all 23 files the shell plays (14 alert sounds, poof, drag to trash, empty trash, Screen Capture, Volume Mount /
  Unmount, SentMessage, BezelServices volume.aiff, PowerChime connect_power) have the sha256 of the 27.2.1 files, so
  duration, rate and peak are the Mac's (e.g. volume.aiff 0.382 s 44.1 kHz mono, peak -7.0 dB; Tink 0.564 s 48 kHz -8.8 dB;
  Screen Capture 0.729 s 48 kHz -13.9 dB). The Vorbis fallbacks of the 14 alert sounds have the same durations (the others not checked). Trigger rules in SOUNDS.md agree
  with MAC-ANSWERS (Dock poof on drop off the Dock, Empty Bin from the Trash menu, volume pop on key-up / slider let-go).

## Not compared
- Tile 33 against `screens/27.2.1/dock/dock-*.png` pixel by pixel, Dock colours, two running apps, the Downloads stack's
  fan / grid, the Trash full icon, the Dock menu's row metrics (24 / 11) and which Finder items are enabled.
- Lock screen: avatar size (the Mac's is covered in every shot), placeholder colour, the caret, motion.
- Sound: anything played (no playback), loudness at two Alert volumes, latency (SOUNDS.md "Needs the Mac").
