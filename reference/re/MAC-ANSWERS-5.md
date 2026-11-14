# Answers from the Mac session, round 5 (macOS 27.2.1, 26B131, MacBook Air M2 15")

Requests from the PC over the relay (#115). Same conditions as rounds 2 to 4: 1440x932 pt @2x (unscaled), Reduce
Transparency / Increase Contrast / Reduce Motion off, Stage Manager off and desktop icons hidden during the shots
(restored after), 60 Hz panel.

## R5.1 Sound timing: a and d done; b and c not done
Method: `reference/re/tools/probe/screc.swift`, ScreenCaptureKit `SCStream` with `capturesAudio` (system audio, not
the mic) and an `SCRecordingOutput` writing one .mov (H.264 video, VFR on a 60 fps grid + AAC 48 kHz stereo). Both
tracks come from the same stream and are written against the same host clock by `SCRecordingOutput`; both start at
pts 0 in the file. Check: `afplay` of Pop.aiff and `osascript beep` land in the audio where expected.
- **a) volume-pop**: `screens/27.2.1/sound/volume-pop.mov`. "Play feedback when volume is changed" is **off** on this
  account, so it was switched on in Settings for the clip and off again after (with it off, a key press is silent).
  Audio pop 1.230 to 1.257 s (27 ms above -50 dB); first HUD pixel change (top-right, below the menu bar) at 1.267 s,
  HUD fade-in continues to about 1.45 s. So the sound starts about **37 ms before the first HUD frame**.
- **b) empty-trash: not done.** The user's Trash holds 4 real items, so Empty Trash would delete them for good.
  "Delete Immediately" (Cmd-Opt-Delete) on a dummy file makes **no sound** (tried and recorded; silent). The sound file
  itself is `/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/finder/empty trash.aif`
  (also `move to trash.aif`). Can be done if the user empties the Trash first.
- **c) dock-poof: not done.** Dragging a Dock app 200 pt up shows the "Remove" bubble (seen in the clip), but on a
  synthetic mouse up the Dock flies the icon back instead of removing it (tried twice, also with a last drag move just
  before the up), so no poof and no sound. Sound file: `…/SystemSounds/dock/poof item off dock.aif` (and `drag to trash.aif`).
  Dock restored from a plist backup either way.
- **d) screenshot**: `screens/27.2.1/sound/screenshot.mov`. Cmd-Shift-3 plays the shutter (audio 1.102 to 1.937 s), but
  while the ScreenCaptureKit stream runs, **no screenshot file is written** (none on the Desktop or anywhere in the home
  folder) and no flash / floating thumbnail is drawn, so there was nothing to delete. The sound file is
  `…/SystemSounds/system/Shutter.aif` (also `Screen Capture.aif`, `Grab.aif`).

## R5.2 Shadows, banner and Wi-Fi module, grey and white: done
- `screens/27.2.1/panels/shadow-{banner,module}-{grey,white}-{dark,light}.png`
- "White" is a solid white desktop picture (not a window), so the menu bar strip and the shots are over pure white.
  The banner comes from `display notification` (app icon = Script Editor). Both surfaces show a soft, wide, low-contrast
  shadow mostly below the shape; over grey 127 it is barely visible, over white it is clear.

## R5.3 Emoji in text: done
- `screens/27.2.1/panels/emoji-in-banner-{light,dark}.png`, `screens/27.2.1/finder/emoji-in-name-{light,dark}.png`
- Colour emoji render inline at the text size in all three banner lines and in the Finder list (selected row keeps
  the colour emoji; no monochrome fallback). Skin tone (👍🏽) and flag (🇮🇩) sequences render as single glyphs.
