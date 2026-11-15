# Answers from the Mac session, round 16 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Request #180 from the PC. The user agreed to the resolution changes and did the three hand actions. Display was at its
normal **1710x1107 (Default)** for everything except R16.2/R16.3; put back afterwards. Times are on each clip's own
clock (pts) unless marked "epoch-based" (logged wall-clock time minus the recorder's start stamp, good to about
±20 ms).

## R16.1 Remove from Dock with a real click: done
- `screens/27.2.1/sound/dock-remove-menu-real-click.mov` (region 1000,580 500x527 pt, 60 fps VFR, system audio,
  pointer visible). Dummy folder tile "DummyDock"; menu opened with a HID right-click on the tile, pointer moved to
  Options, then to "Remove from Dock" (row 1288,980 147x24), **HID mouse down, 70 ms, up** (`CGEvent` at the HID tap).
- Per frame, row colour = mean of the item row (highlight blue 78,132,230; plain menu 141,135,133):

| t (s) | what |
|---|---|
| ≈ 4.33 | mouse down (epoch-based); no visible change on down |
| ≈ 4.48 | mouse up (epoch-based) |
| 4.533 | **blink: highlight off** (one captured frame, shown until 4.600 = 67 ms) |
| 4.600 | highlight on again (until 4.667 = 67 ms) |
| 4.667 | **first fading frame**: both menus start to fade (**≈ 185 ms after the up, 134 ms after the blink starts**) |
| 4.850-4.867 | fade finished (**≈ 185-200 ms**, eased: row blue 215 → 199 → 181 → 165 → 152 → 142 → 134 → 129 → 124 → 121 → 119 → 117) |
| 4.900-5.117 | Dock closes the gap and re-centres (≈ 220 ms); the tile simply goes, no cloud |
| **4.929-5.187** | **poof sound** (0.26 s): starts ≈ 30 ms after the Dock starts to move, ≈ 60 ms after the menu is gone, ≈ 450 ms after the mouse up |

- So with a real click the order is: blink (off 67 ms, on 67 ms) → menu fade ≈ 190 ms → tile removed + sound. Round 10's
  AX press skipped the blink, which is why its sound landed on the first fading frame.

## R16.2 More Space / Larger Text with ScreenCaptureKit: done
- `screens/27.2.1/scaled/{more-space,larger-text}-{dock,menu,finder,settings}-sck.png` (crops of the full frame: Dock
  strip, top-left 440 pt with the File menu open, the Finder list window, the Settings window) and
  `…-{finder,settings}-ax.jsonl`. Sidebar user rows and the account rows are blurred.
- What each API returned (full screen):

| mode (pt) | backing | `screencapture` | SCK `captureImage`, 2880x1864, `scalesToFit = false` | same, `scalesToFit = true` |
|---|---|---|---|---|
| More Space 1920x1243 | 3840x2486 | 3840x2486 (backing) | **2880x1864, the whole screen scaled to the panel** (1.5 px per pt) | identical (mean diff 0.02) |
| Larger Text 1024x663 | 2048x1326 | 2048x1326 | 2880x1864 canvas with the **2048x1326 frame unscaled in the top-left**, rest black | the frame upscaled to fill 2880x1864 |

  `SCContentFilter.pointPixelScale` reports 2.0 and `contentRect` the point size in both modes; `SCDisplay.width/height`
  are points. So for More Space the SCK frame at panel size **is** the scaled frame (as the panel shows it); for
  modes whose backing is smaller than the panel SCK does not upscale unless `scalesToFit` is on. The More Space stills
  here are those panel-resolution frames; the Larger Text stills are the unscaled 2x frames.
- "Larger Text" on this Mac is 1024x663 (Displays offers 1024x663, 1280x828, 1440x932, 1710x1107 Default, 1920x1243).

## R16.3 More Space: Settings window and separators (AX + px)
- Window (AX): **position 100,80, size 740x586 pt** (it was placed at 100,80; the height is 586 here, not 625). Toolbar
  title text 417,80 411x52; content scroll area 332,132 508x534; first card (Appearance + Liquid Glass) 352,144
  468x319; second card (Colour + Text highlight colour) 352,519 468x100; third 352,629.
- Separators are not AX elements; from the 2x backing shot (`screencapture`, 3840x2486): **1 pt thick (2 backing px)**,
  colour 46,47,47 on the card's 36,37,37, **x 362 to 810 (inset 10 pt from each card edge)**:
  - card 1, between Appearance and Liquid Glass: **y 230 to 231**;
  - card 2, between Colour and Text highlight colour: **y 581 to 582**.
  On the panel 1 pt is 1.5 px in this mode, so the line lands on 1-2 panel pixels.

## R16.4 Traffic lights with the profile and in sRGB: done
- `screens/27.2.1/windows/lights-{finder,system-settings}-active-dark-p3.png` (as `screencapture` wrote it: tagged
  **Display P3**) and `…-srgb.png` (`sips -m "sRGB Profile.icc"`). Strip 1420x64 pt across both windows' title bars,
  dark, pointer away; one shot with Finder frontmost, one with System Settings frontmost (only the frontmost app's
  window has coloured lights).
- Disc 14 pt, pitch 23 pt, first centre 25.5 pt from the window's left edge, centre y 25.5 pt (1710x1107 mode, 2x
  backing). Mean of the central 11x11 px of each disc:

| | red | yellow | green |
|---|---|---|---|
| pixel values in the P3-tagged file | 225,99,86 | 242,191,27 | 90,187,26 |
| after conversion to sRGB | 242,89,79 | 252,189,2 | 29,190,8 |

  Same values for the Finder and the Settings window. Inactive window (the other app's window in each shot): all
  three discs the same grey, **73,75,75** (P3 and sRGB).

## Hand actions (done by the user)
- **F12 volume key, feedback sound on**: `screens/27.2.1/sound/volume-key-f12-hand-feedback.mov` (region 1290,24
  420x120 pt, audio). "Play feedback when volume is changed" was switched on in Settings > Sound for the take and off
  again (the `defaults` key alone had no effect on a first take). A listen-only event tap logged the key:
  **key down 0.599 s, key up 0.714 s** (epoch-based). **Pop 0.660-0.684 s = 61 ms after key down.** HUD: first changed
  frame **0.683 s (84 ms after key down, 23 ms after the pop starts)**, 50 % at 0.833 s, 90 % at 1.05 s. Volume 38 → 44,
  set back to 38.
- **Dock tile dragged off by trackpad**: `screens/27.2.1/sound/dock-drag-off-hand.mov` (region 850,720 600x387 pt,
  audio). Mouse down 3.535 s on the tile, released 6.074 s at 135 pt above the Dock (epoch-based; shorter than the
  255 pt asked, "Remove" was showing). **With a real drag the tile is removed**: after the release the dragged icon and
  its "Remove" label **fade out in place from 6.117 to 6.350 s (≈ 230 ms)**; there is **no poof cloud** and no fly-back.
  **Sound 6.137-6.395 s, i.e. 63 ms after the release**, starting with the fade. The Dock had already closed the gap
  while the tile was being dragged.
- **Dock separator dragged**: `screens/27.2.1/dock/dock-separator-drag-hand.mov` (region 300,907 1110x200 pt, pointer
  shown, no audio). The drag was slower and larger than asked (about 5.5 s, 35 pt up and back). The Dock follows the
  pointer **in whole-point steps with no easing or lag**: its top edge moves 1 pt per step and its width grows about
  18 pt per step (9 pt each side) until it reaches the screen edges; on the way back it retraces the same steps.
  Tile size went 31 → 33 after the drag; the Dock plist was re-imported from the backup (31).

## Restored and checked
Display 1710x1107, desktop icons shown, Dock plist re-imported from the backup after each Dock test (no DummyDock
entry, tile size 31), volume 38, feedback sound off, System Settings quit. The leftover "Regulatory Certification"
window from round 15 (owned by System Information) was closed.
