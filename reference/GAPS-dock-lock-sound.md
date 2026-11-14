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
2. OPEN, plugin (re23: the shape is decoded, `re/27.2.1/GAPS-REA-dock.md` section 1: body radius 12, tail 23.5 wide
   x 13 deep, tip radius 5.46, base fillets 7.8, a CoreUI path, not the label's). Dock menu shape: Mac a glass bubble with a tail at the icon centre, like the hover label, radius about 14
   (Q-dock-10, visual); ours a plain menu with no tail. The label's pointer is a plugin marker (Theme.dock.labelPointer,
   plugin/README.md "Dock label pointer"); the menu would need the same marker on its own surface, hung at the icon
   centre (now 27 pt in from the body's left edge) under the body's 13 pt inset.
3. FIXED in part (re23, 2026-11-14: the rule is ceil(text) + 2 x 13, at least 41, decoded in `re/27.2.1/GAPS-REA-dock.md`
   section 2; ours added 2 x 14. "Finder" now 69, was 70..71, Mac 67.5: the rest is our text width). Was: Hover label width: ours "Finder" 70..71 including the rim's soft edge (diff against a frame without
   the label), Mac 67.5 (Q-dock-08: text + 2 x 14). The rule is the Mac's; the 2..3 pt is the text width of our font
   or the edge threshold. Wants an ink-to-ink measure on a solid backdrop. Height 26 and tail tip 2.5 above the Dock match.
4. OPEN, blocked (2026-11-14, checked in the code: nothing on this stack can drop a file on the Dock). Hyprk's Finder
   drags items with a Qt Quick internal drag (`finder/qml/DragSession.qml`: `Drag.active` on an Item, keys
   ["hyprk-finder"], no `Drag.dragType: Drag.Automatic`, no mime data), chosen so Hyprland does not force its
   "grabbing" cursor; an internal drag never leaves Finder's window, so no wl_data_device offer reaches the shell's
   Dock layer, and the Dock has no DropArea. Playing ID 16 needs a Wayland drag out of Finder (text/uri-list, the
   grabbing-cursor trade-off) plus a DropArea on the Trash tile that trashes the URIs; not small, not done.
   Was: Dragging a file onto the Dock Trash: Mac plays `dock/drag to trash.aif` (ID 16, MAC-ANSWERS "Sounds per
   event"); the shell's Dock takes no file drops, so `trash-move` has no caller in the Dock (Finder only).
5. SETTLED, small change (round3, 2026-11-14: `re/27.2.1/GAPS-REA-round3.md` section 1). Stack fan item size: the
   Mac's "65.5 -> 78.3" (Q-dock-12) is the AX box of a constant 64 pt item turned on the 3000 pt arc (ours gives 65.0 ->
   78.0 at tile 33; the 64.6 step is the boxes' top edges). `_itemSize` is written only by the fan's init (64 x 64);
   during open / close each item's bounds animate between its pile frame (tile - 2s(j+1)) and 64, now in
   `lib/dockstack.js fanSize`. The fan's -24 shift still has no settled sign (GUESS kept).
   UPDATE (motion round 3, 2026-11-14, `re/27.2.1/MOTION-REA-27.2.1.md` Round 3): sign SETTLED, -24 is down (the stack
   layer tree is y up: the grid frame code and the Mac's AX grid frame agree), `fanShift` = -24.
7. FIXED (motion round 3, R3.1/R3.2). Stack fan and grid motion decoded: 0.25 s (CATransaction default, read in
   QuartzCore; Shift slow motion 5 s), no stagger; fan position ease-in-out, rotation and size on CA's "default" curve
   (implicit animations), label scale ease-in-out, label opacity linear; grid all on the "default" curve from the
   tile's centre. Ours drove rotation, size and label with the position's curve and faded only the label text. On
   screen (scale 2, dark): fan open / close top edge against the decoded model rms 1.5 / 0.6 pt, grid open / close
   against the "default" curve rms about 0.03 / 0.010.
8. FIXED (motion round 3, R3.2). Grid place: the edge is the tile's icon box top, not the Dock background's top (Mac
   AX bottom 1051 = icon top 1062 - 11 at tile 33); ours sat iconTop (7 pt at tile 33) too high.
9. SETTLED, no change (R3.4). `mouse-over-hilite-stack` stock value: off (absent key reads false).
10. OPEN, not decoded (R3.5). Mission Control exit with several windows: layer order and when the picked window rises
   are still not found in WindowManagerAgent; ours keeps the stacking order and lifts the picked window from the first
   exit frame (seen on screen with 4 foot windows). Needs a Mac recording.
11. CHECKED, no change (2026-11-14, judge-95-16 change 6). Fan: the tile's chevron shows under the first item. Measured
   (headless, scale 2, dark, tile 64): icon box 753..817, first item box 713..777 (its bottom 24 below the icon top,
   exactly R3.3's decode; the photo art 716..772.5 inside it at photoFit), chevron ink 779.5..799. A 64 box on the
   decode cannot cover a chevron centred on the tile: the origin and the anchor are as decoded, the chevron is the
   guessed part. The Mac draws an image, not an SF chevron: Dock.app `s-pileArrow` / `s-pileLeftArrow` /
   `s-pileRightArrow` (+ `2`, cfstrings 0x1002e5988..0x1002e5a48 in the Dock binary), picked per Dock edge; its frame
   was not decoded (no adrp / add reference found from code) and the PNGs are not extracted (the OS dmg needs
   apfs-fuse). Needs: those files, or a Mac still of an open fan.
12. FIXED (2026-11-14, judge-95-16). `QFont::setPixelSize: Pixel size <= 0` x7..8 per fan open: StackArt's extension
   label (`9.926 x page.size / 77`) while the fan's item boxes were still 0; it now waits for a real box. Fan opens in
   the headless session: 7 warnings before, 0 after (two opens), look unchanged.
6. SETTLED, no change (round3, section 3). Key repeat on a fresh account: IOHIDKeyboardFilter starts at 500 ms / 83 ms
   (constructor), and no code was found that sets other values while KeyRepeat / InitialKeyRepeat are absent (inferred,
   bounded search), so ours 500 ms / 12 per second matches.

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
  fan / grid stills (no Mac picture; motion now decoded, items 7 to 9), the Trash full icon, the Dock menu's row metrics (24 / 11) and which Finder items are enabled.
- Lock screen: avatar size (the Mac's is covered in every shot), placeholder colour, the caret, motion.
- Sound: anything played (no playback), loudness at two Alert volumes, latency (SOUNDS.md "Needs the Mac").
