# Answers from the Mac session, round 10 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (captures only). Same conditions as earlier rounds: 1440x932 pt @2x, Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), dark mode. Flat wallpaper: a solid grey 127 PNG (2880x1864); it reads as luminance 122 in the
capture, the menu bar strip over it as 113.

**Frame rate:** the panel is 60 Hz, so 60 fps is the cap. All clips are from `reference/re/tools/probe/screc.swift`
(ScreenCaptureKit, `minimumFrameInterval` 1/60, screen + system audio in one .mov via `SCRecordingOutput`). The file is
VFR on a 60 fps grid: SCK only emits a frame when something changed, so a gap of 33 ms means one unchanged frame, not a
dropped one.

**Clock method (R10.2, R10.3).** Video and audio come from one SCK stream and are written by `SCRecordingOutput` against
the same host clock; both start at pts 0. To put the key press on that clock, a small one-process tool (`mk`, `reference/re/tools/probe/mk.swift`) posts
a pointer move (visual marker, cursor is captured) and then, about 12 ms later, the key, and prints `time.time()`-style
Unix times for both; `screc` prints the Unix time of `recordingOutputDidStartRecording`. Calibration: across 6 runs the
pointer move shows up in the capture **12 to 27 ms** after it was posted (`started` + offset). So the recording clock is
"Unix time - started", and an event's first frame is at most about 1 to 1.5 frames late due to the compositor/capture
path. Error bound for a key-to-frame time: about **+-17 ms** (one frame of quantisation), plus up to about 25 ms of
pipeline delay that applies to any on-screen change (the pointer path shows how much). Audio onsets are found by
cross-correlation with the system sound file (normalised correlation >= 0.997), resolution about 1 ms.

## R10.1 Mission Control exit, menu bar vs Spaces bar: done
- `screens/27.2.1/live/mc-exit-menubar-flat-grey.mov` (top 160 pt, left 720 pt, 0.6 s, 60 fps VFR, no audio),
  `screens/27.2.1/live/mc-exit-menubar-strip.png` (top 80 pt of frames 45, 47-53, 55, 57 stacked, full width crop 720 pt).
- Setup: 4 TextEdit windows (empty), other apps hidden, MC entered with `open -a "Mission Control"`, Esc after 2 s.
- **The menu bar titles are drawn above the Spaces bar, not seen through it.** In the first exit frames the bar is still
  fully there (luminance 86-88 behind the titles, same as in MC) and the title glyphs brighten on top of it. The Spaces
  bar does **not** fade: it **slides up**, its bottom edge moving from 69 pt to 0 while the part still on screen keeps
  its MC luminance (opaque). The menu bar's own background (113) appears only in the rows the bar has left.
- Per frame (t = recording time; Esc at about 0.76 s; frame 46 is the last full-MC frame for the top strip):

| frame | t (s) | Spaces bar bottom edge (pt) | bar alpha in menu bar rows | title alpha (est.) |
|---|---|---|---|---|
| 46 | 0.950 | 68 | 1.00 | 0.00 |
| 47 | 0.983 | 53 | 1.00 | 0.23 |
| 48 | 1.000 | 42 | 1.00 | 0.42 |
| 49 | 1.017 | 32 | 1.00 | 0.58 |
| 50 | 1.033 | 24 | 1.00 | 0.72 |
| 51 | 1.050 | 16 | 0.68 | 0.80 |
| 52 | 1.067 | 11 | 0.41 | 0.86 |
| 53 | 1.083 | 7 | 0.22 | 0.90 |
| 54 | 1.100 | 4 | 0.07 | 0.90 |
| 55 | 1.117 | 2 | 0.00 | 0.93 |
| 56 | 1.133 | 0 | 0.00 | 0.94 |
| 57 | 1.150 | - | 0.00 | 0.97 |
| 59 | 1.183 | - | 0.00 | 0.98 |
| 62+ | 1.233 | - | 0.00 | 1.00 |

  - "Bar alpha in menu bar rows" = (113 - L) / (113 - 87.8) over a title-free patch (x 500-650 pt, y 2.5-25 pt); it drops
    only because the sliding edge passes through those rows, so it is coverage, not a fade.
  - "Title alpha" = (mean L of the glyph pixels - L of the backdrop under them) / (246 - 113), i.e. glyph contrast relative
    to the final frame, assuming the title colour itself is constant (white). It runs about 0.2 per frame at first and
    eases out over about 250 ms (0.98 at 0.2 s after the first frame).
  - Bar edge: 69 pt in MC (with a soft shadow below it to about 100 pt). It moves 16, 11, 10, 8, 8, 5, 4, 3, 2, 2 pt per
    frame: an ease-out of about 150 ms.

## R10.2 Sounds on the screen clock: a done, b not done, c done another way (menu, not drag)
- **a) screenshot shutter: done.** `screens/27.2.1/sound/screenshot-thumbnail.mov` (bottom-right 240x182 pt, with audio).
  Cmd-Shift-3 posted as a CGEvent (keycode 20 + Cmd+Shift) at 1.151 s. Sound = `…/SystemSounds/system/Screen Capture.aif`
  (corr 0.997; not `Shutter.aif`), starting **222 ms after the key** (second run: 247 ms). No white flash. The floating
  thumbnail starts sliding in from the bottom-right corner **482 ms after the key** (second run: 647 ms), i.e. about
  260 to 400 ms after the sound starts; it is in place about 170 ms later.
  - **This time a file was written**: `~/Desktop/Screenshot … .png` (2880x1864), about 5.8 s after the key (when the
    thumbnail timed out). Both files (one per run) were created during this run (birth times checked against the
    recording start) and were moved, by exact path, out of the Desktop into the session scratch folder. In round 5 the
    key was sent with `System Events keystroke`; this round that also did nothing at all (no sound, no file), so the
    round-5 sound may have come from a different path. With a HID-level CGEvent the shortcut works while SCK records.
- **b) Empty Trash: not done: Trash holds the user's items** (Finder reports 32 items; not listed). Round 5 found
  "Delete Immediately" on a dummy file is silent. Sound file: `…/SystemSounds/finder/empty trash.aif`.
- **c) Dock poof: the drag-off still flies back; removal via the Dock menu plays the poof sound.**
  - Dummy item: an empty-ish folder (one 2-byte file) in the session scratch folder, added to `persistent-others`
    after `defaults export com.apple.dock`.
  - Tried, all with the "Remove" bubble shown while held off the Dock, all ending with the label switching back to the
    item name and the tile flying back on mouse up (no poof, silent):
    1. press + 0.4 s hold before moving: that opens the stack (fan) instead of dragging (folder tiles open on press);
    2. press then immediate drag 255 pt up over 1.15 s, 1.2 s hover, a 1 pt move, 1.0 s hover, up (separate processes);
    3. one process (`reference/re/tools/probe/dragoff.swift`), `CGEventSource(.hidSystemState)`, clickState 1, pressure 1/0, deltas set, 1.0 s drag, 1.2 s hold
       with zero-delta drag events at 60 Hz, up at the same point, HID tap;
    4. as 3 but posted at the session tap.
    `screens/27.2.1/sound/dock-drag-off-flyback.mov` shows run 3 (no audio): the bubble changes from "Remove" to the
    item name in the frame after the up, then the tile flies back over about 350 ms. So the synthetic up is not taken as
    a drop; it needs a real pointer or a different event path.
  - **Done another way:** Dock context menu (AXShowMenu) > Options > "Remove from Dock":
    `screens/27.2.1/sound/dock-remove-menu-poof-sound.mov` (500x532 pt, with audio). The sound is
    `…/SystemSounds/dock/poof item off dock.aif` (corr 0.999, 0.337 s long). On the recording clock: the menu starts
    fading at 1.917 s (first frame after the click; the menu fades out over about 180 ms), the poof sound starts at
    **1.932 s (15 ms after the first visual change, i.e. in the same frame)**, and the Dock closes the gap and re-centres
    from 1.917 to about 2.167 s (250 ms). **No poof cloud sprite is drawn** for this kind of removal; the tile just goes.
  - Dock restored from the backup (`defaults import`, `killall Dock`): `persistent-apps` and `persistent-others`
    byte-identical to the backup; the dummy tile is gone. `recent-apps` differs by one entry, which the Dock maintains
    itself at runtime.

## R10.3 Volume key to HUD: done (synthetic key)
- `screens/27.2.1/sound/volume-key-hud-timing.mov` (top-right 340x120 pt, 1.3 s, run 5).
- Key: **synthetic** NX_KEYTYPE_SOUND_UP system-defined event (subtype 8, key down, 50 ms, key up), posted at the HID
  tap by the one-process `mk` tool right after the pointer marker. "Play feedback when volume is changed" is off on this
  account and was left off, so the clip has no sound (round 5 measured the pop at 37 ms before the first HUD frame).
  Output volume read as 38 before, set back to 38 after each run, read back 38 at the end.
- Three runs (key at 1.105-1.110 s; the pointer marker appeared 22-24 ms after it was posted in each run):

| run | first HUD frame after key-down | HUD 50 % | HUD 90 % | menu bar Sound item highlight first frame |
|---|---|---|---|---|
| 4 | 123 ms | 290 ms | 440 ms | 173 ms |
| 5 | 127 ms | 277-293 ms | 443 ms | 177 ms |
| 6 | 112 ms | 278 ms | 445 ms | 145 ms |

  - **Key-down to first HUD frame: 112-127 ms (mean 121 ms), +-17 ms.** Taking off the 22-24 ms capture path that the
    pointer marker needs, the HUD's own delay is about 90-105 ms. HUD % = mean pixel change in the pill area relative to
    the change 0.6 s after the key. The fade-in is roughly linear, about 0.33 s from first frame to 90 %.
  - While the HUD shows, the menu bar Sound item gets a selected pill (visible in the clip), appearing 20-50 ms after the
    HUD's first frame.

## Restored and checked
Wallpaper store copied back from the backup + `killall WallpaperAgent` (the agent then rewrote only the two "last set"
dates; everything else identical), Stage Manager on (`GloballyEnabled` = 1), `CreateDesktop` deleted + Finder
restarted, dark mode on, display mode 1710x1107, output volume 38, Dock from the backup (see R10.2 c), TextEdit closed
without saving, the grey PNG moved out of `~/Pictures` into the session scratch folder, the 2 screenshot files moved off
the Desktop.
