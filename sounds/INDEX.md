# Sound index (macOS 27.2 build 26B123)

Source: main system volume of the user's own IPSW. `originals/` keeps the Apple files as-is (aiff/aif/caf/wav). `wav/` is every file converted to WAV with ffmpeg, `oga/` is Vorbis (q6) for everything except Telephony and VoiceOver.
`originals/` and `wav/` mirror each other; names with the same base but different extension (end_call_tone_cept, vc~ended, SecureCharacter) collide in `wav/` and the last one written wins.

## Where each folder comes from

- `originals/Sounds/` from `/System/Library/Sounds`
- `originals/SystemSounds/` from `/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds`
- `originals/AlertTones/` from `/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones`
- `originals/VoiceOverSounds/` from `/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds`
- `originals/Telephony/` from `/System/Library/PrivateFrameworks/TelephonyUtilities.framework/Versions/A/Resources`
- `originals/misc/` from `(various, see file name; apps/frameworks under /System)`

Event mappings are inferred from file names and Apple resource folders, not from tracing the OS. Empty event column means "no mapping known".

## Quick picks for Hyprland (freedesktop sound theme names)

| freedesktop event | use this |
|---|---|
| bell, dialog-warning | `oga/Sounds/Basso.oga` or `Sosumi` |
| message-new-instant, notification | `oga/Sounds/Tink.oga` / `Glass` / `Ping` |
| screen-capture | `oga/SystemSounds/system/Screen Capture.oga` |
| trash-empty | `oga/SystemSounds/finder/empty trash.oga` |
| trash-move (custom) | `oga/SystemSounds/finder/move to trash.oga` |
| device-added / media mount | `oga/SystemSounds/system/Volume Mount.oga` |
| device-removed / eject | `oga/SystemSounds/system/Volume Unmount.oga` |
| audio-volume-change | `oga/misc/BezelServices-volume.oga` |
| power-plug | `oga/misc/PowerChime-connect_power.oga` |
| message-sent | `oga/misc/Mail-Sent.oga` |

## Full list

| original | wav | oga | macOS event / use |
|---|---|---|---|
| `AlertTones/Classic/Alert.m4r` | `wav/AlertTones/Classic/Alert.wav` | `oga/AlertTones/Classic/Alert.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Anticipate.m4r` | `wav/AlertTones/Classic/Anticipate.wav` | `oga/AlertTones/Classic/Anticipate.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Bell.m4r` | `wav/AlertTones/Classic/Bell.wav` | `oga/AlertTones/Classic/Bell.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Bloom.m4r` | `wav/AlertTones/Classic/Bloom.wav` | `oga/AlertTones/Classic/Bloom.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Calypso.m4r` | `wav/AlertTones/Classic/Calypso.wav` | `oga/AlertTones/Classic/Calypso.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Chime.m4r` | `wav/AlertTones/Classic/Chime.wav` | `oga/AlertTones/Classic/Chime.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Choo Choo.m4r` | `wav/AlertTones/Classic/Choo Choo.wav` | `oga/AlertTones/Classic/Choo Choo.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Descent.m4r` | `wav/AlertTones/Classic/Descent.wav` | `oga/AlertTones/Classic/Descent.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Ding.m4r` | `wav/AlertTones/Classic/Ding.wav` | `oga/AlertTones/Classic/Ding.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Electronic.m4r` | `wav/AlertTones/Classic/Electronic.wav` | `oga/AlertTones/Classic/Electronic.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Fanfare.m4r` | `wav/AlertTones/Classic/Fanfare.wav` | `oga/AlertTones/Classic/Fanfare.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Glass.m4r` | `wav/AlertTones/Classic/Glass.wav` | `oga/AlertTones/Classic/Glass.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Horn.m4r` | `wav/AlertTones/Classic/Horn.wav` | `oga/AlertTones/Classic/Horn.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Ladder.m4r` | `wav/AlertTones/Classic/Ladder.wav` | `oga/AlertTones/Classic/Ladder.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Minuet.m4r` | `wav/AlertTones/Classic/Minuet.wav` | `oga/AlertTones/Classic/Minuet.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/News Flash.m4r` | `wav/AlertTones/Classic/News Flash.wav` | `oga/AlertTones/Classic/News Flash.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Noir.m4r` | `wav/AlertTones/Classic/Noir.wav` | `oga/AlertTones/Classic/Noir.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Sherwood Forest.m4r` | `wav/AlertTones/Classic/Sherwood Forest.wav` | `oga/AlertTones/Classic/Sherwood Forest.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Spell.m4r` | `wav/AlertTones/Classic/Spell.wav` | `oga/AlertTones/Classic/Spell.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Suspense.m4r` | `wav/AlertTones/Classic/Suspense.wav` | `oga/AlertTones/Classic/Suspense.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Swish.m4r` | `wav/AlertTones/Classic/Swish.wav` | `oga/AlertTones/Classic/Swish.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Swoosh.m4r` | `wav/AlertTones/Classic/Swoosh.wav` | `oga/AlertTones/Classic/Swoosh.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Telegraph.m4r` | `wav/AlertTones/Classic/Telegraph.wav` | `oga/AlertTones/Classic/Telegraph.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Tiptoes.m4r` | `wav/AlertTones/Classic/Tiptoes.wav` | `oga/AlertTones/Classic/Tiptoes.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Tri-Tone.m4r` | `wav/AlertTones/Classic/Tri-Tone.wav` | `oga/AlertTones/Classic/Tri-Tone.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Tweet.m4r` | `wav/AlertTones/Classic/Tweet.wav` | `oga/AlertTones/Classic/Tweet.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Typewriters.m4r` | `wav/AlertTones/Classic/Typewriters.wav` | `oga/AlertTones/Classic/Typewriters.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Classic/Update.m4r` | `wav/AlertTones/Classic/Update.wav` | `oga/AlertTones/Classic/Update.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Antic-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Antic-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Antic-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Cheers-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Cheers-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Cheers-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Droplet-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Droplet-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Droplet-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Handoff-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Handoff-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Handoff-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Milestone-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Milestone-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Milestone-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Passage-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Passage-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Passage-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Portal-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Portal-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Portal-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Rattle-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Rattle-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Rattle-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Rebound-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Rebound-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Rebound-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Slide-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Slide-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Slide-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/EncoreInfinitum/Welcome-EncoreInfinitum.caf` | `wav/AlertTones/EncoreInfinitum/Welcome-EncoreInfinitum.wav` | `oga/AlertTones/EncoreInfinitum/Welcome-EncoreInfinitum.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Aurora.m4r` | `wav/AlertTones/Modern/Aurora.wav` | `oga/AlertTones/Modern/Aurora.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Bamboo.m4r` | `wav/AlertTones/Modern/Bamboo.wav` | `oga/AlertTones/Modern/Bamboo.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Chord.m4r` | `wav/AlertTones/Modern/Chord.wav` | `oga/AlertTones/Modern/Chord.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Circles.m4r` | `wav/AlertTones/Modern/Circles.wav` | `oga/AlertTones/Modern/Circles.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Complete.m4r` | `wav/AlertTones/Modern/Complete.wav` | `oga/AlertTones/Modern/Complete.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Hello.m4r` | `wav/AlertTones/Modern/Hello.wav` | `oga/AlertTones/Modern/Hello.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Input.m4r` | `wav/AlertTones/Modern/Input.wav` | `oga/AlertTones/Modern/Input.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Keys.m4r` | `wav/AlertTones/Modern/Keys.wav` | `oga/AlertTones/Modern/Keys.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Note.m4r` | `wav/AlertTones/Modern/Note.wav` | `oga/AlertTones/Modern/Note.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Popcorn.m4r` | `wav/AlertTones/Modern/Popcorn.wav` | `oga/AlertTones/Modern/Popcorn.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Pulse.m4r` | `wav/AlertTones/Modern/Pulse.wav` | `oga/AlertTones/Modern/Pulse.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/Modern/Synth.m4r` | `wav/AlertTones/Modern/Synth.wav` | `oga/AlertTones/Modern/Synth.oga` | ToneLibrary alert/ringtone-style tones (Classic, Modern, EncoreInfinitum sets) |
| `AlertTones/PhotosMemoriesNotification.caf` | `wav/AlertTones/PhotosMemoriesNotification.wav` | `oga/AlertTones/PhotosMemoriesNotification.oga` | Photos Memories notification |
| `AlertTones/ReceivedMessage.caf` | `wav/AlertTones/ReceivedMessage.wav` | `oga/AlertTones/ReceivedMessage.oga` | Messages: received message tone |
| `AlertTones/Text-Message-Acknowledgement-Exclamation.caf` | `wav/AlertTones/Text-Message-Acknowledgement-Exclamation.wav` | `oga/AlertTones/Text-Message-Acknowledgement-Exclamation.oga` | Messages: incoming tapback tone |
| `AlertTones/Text-Message-Acknowledgement-HaHa.caf` | `wav/AlertTones/Text-Message-Acknowledgement-HaHa.wav` | `oga/AlertTones/Text-Message-Acknowledgement-HaHa.oga` | Messages: incoming tapback tone |
| `AlertTones/Text-Message-Acknowledgement-Heart.caf` | `wav/AlertTones/Text-Message-Acknowledgement-Heart.wav` | `oga/AlertTones/Text-Message-Acknowledgement-Heart.oga` | Messages: incoming tapback tone |
| `AlertTones/Text-Message-Acknowledgement-QuestionMark.caf` | `wav/AlertTones/Text-Message-Acknowledgement-QuestionMark.wav` | `oga/AlertTones/Text-Message-Acknowledgement-QuestionMark.oga` | Messages: incoming tapback tone |
| `AlertTones/Text-Message-Acknowledgement-ThumbsDown.caf` | `wav/AlertTones/Text-Message-Acknowledgement-ThumbsDown.wav` | `oga/AlertTones/Text-Message-Acknowledgement-ThumbsDown.oga` | Messages: incoming tapback tone |
| `AlertTones/Text-Message-Acknowledgement-ThumbsUp.caf` | `wav/AlertTones/Text-Message-Acknowledgement-ThumbsUp.wav` | `oga/AlertTones/Text-Message-Acknowledgement-ThumbsUp.oga` | Messages: incoming tapback tone |
| `Sounds/Basso.aiff` | `wav/Sounds/Basso.wav` | `oga/Sounds/Basso.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Blow.aiff` | `wav/Sounds/Blow.wav` | `oga/Sounds/Blow.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Bottle.aiff` | `wav/Sounds/Bottle.wav` | `oga/Sounds/Bottle.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Frog.aiff` | `wav/Sounds/Frog.wav` | `oga/Sounds/Frog.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Funk.aiff` | `wav/Sounds/Funk.wav` | `oga/Sounds/Funk.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Glass.aiff` | `wav/Sounds/Glass.wav` | `oga/Sounds/Glass.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Hero.aiff` | `wav/Sounds/Hero.wav` | `oga/Sounds/Hero.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Morse.aiff` | `wav/Sounds/Morse.wav` | `oga/Sounds/Morse.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Ping.aiff` | `wav/Sounds/Ping.wav` | `oga/Sounds/Ping.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Pop.aiff` | `wav/Sounds/Pop.wav` | `oga/Sounds/Pop.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Purr.aiff` | `wav/Sounds/Purr.wav` | `oga/Sounds/Purr.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Sosumi.aiff` | `wav/Sounds/Sosumi.wav` | `oga/Sounds/Sosumi.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Submarine.aiff` | `wav/Sounds/Submarine.wav` | `oga/Sounds/Submarine.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `Sounds/Tink.aiff` | `wav/Sounds/Tink.wav` | `oga/Sounds/Tink.oga` | Alert sounds list in System Settings > Sound > Alert sound (Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink). Also used as per-app notification sounds. |
| `SystemSounds/accessibility/Mouse Keys OFF.aif` | `wav/SystemSounds/accessibility/Mouse Keys OFF.wav` | `oga/SystemSounds/accessibility/Mouse Keys OFF.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Mouse Keys ON.aif` | `wav/SystemSounds/accessibility/Mouse Keys ON.wav` | `oga/SystemSounds/accessibility/Mouse Keys ON.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Slow Keys, 1st Key Pressed.aif` | `wav/SystemSounds/accessibility/Slow Keys, 1st Key Pressed.wav` | `oga/SystemSounds/accessibility/Slow Keys, 1st Key Pressed.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Slow Keys, Key Registered.aif` | `wav/SystemSounds/accessibility/Slow Keys, Key Registered.wav` | `oga/SystemSounds/accessibility/Slow Keys, Key Registered.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Sticky Keys Locked.aif` | `wav/SystemSounds/accessibility/Sticky Keys Locked.wav` | `oga/SystemSounds/accessibility/Sticky Keys Locked.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Sticky Keys MODIFER.aif` | `wav/SystemSounds/accessibility/Sticky Keys MODIFER.wav` | `oga/SystemSounds/accessibility/Sticky Keys MODIFER.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Sticky Keys OFF.aif` | `wav/SystemSounds/accessibility/Sticky Keys OFF.wav` | `oga/SystemSounds/accessibility/Sticky Keys OFF.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Sticky Keys ON.aif` | `wav/SystemSounds/accessibility/Sticky Keys ON.wav` | `oga/SystemSounds/accessibility/Sticky Keys ON.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/accessibility/Sticky Keys Stuck.aif` | `wav/SystemSounds/accessibility/Sticky Keys Stuck.wav` | `oga/SystemSounds/accessibility/Sticky Keys Stuck.oga` | Accessibility keyboard: Sticky/Slow/Mouse Keys state sounds |
| `SystemSounds/dock/drag to trash.aif` | `wav/SystemSounds/dock/drag to trash.wav` | `oga/SystemSounds/dock/drag to trash.oga` | Dock/Finder: drag item onto the Trash (drop) |
| `SystemSounds/dock/poof item off dock.aif` | `wav/SystemSounds/dock/poof item off dock.wav` | `oga/SystemSounds/dock/poof item off dock.oga` | Dock: drag item off the Dock (poof) |
| `SystemSounds/facetime/multiway_invitation.caf` | `wav/SystemSounds/facetime/multiway_invitation.wav` | `oga/SystemSounds/facetime/multiway_invitation.oga` | FaceTime group call join/leave/invite |
| `SystemSounds/facetime/multiway_join.caf` | `wav/SystemSounds/facetime/multiway_join.wav` | `oga/SystemSounds/facetime/multiway_join.oga` | FaceTime group call join/leave/invite |
| `SystemSounds/facetime/multiway_leave.caf` | `wav/SystemSounds/facetime/multiway_leave.wav` | `oga/SystemSounds/facetime/multiway_leave.oga` | FaceTime group call join/leave/invite |
| `SystemSounds/finder/empty trash.aif` | `wav/SystemSounds/finder/empty trash.wav` | `oga/SystemSounds/finder/empty trash.oga` | Finder: Empty Trash |
| `SystemSounds/finder/move to trash.aif` | `wav/SystemSounds/finder/move to trash.wav` | `oga/SystemSounds/finder/move to trash.oga` | Finder: move item to Trash |
| `SystemSounds/ink/InkSoundBecomeMouse.aif` | `wav/SystemSounds/ink/InkSoundBecomeMouse.wav` | `oga/SystemSounds/ink/InkSoundBecomeMouse.oga` | Ink / handwriting (Mac stylus) stroke sounds |
| `SystemSounds/ink/InkSoundStroke1.aif` | `wav/SystemSounds/ink/InkSoundStroke1.wav` | `oga/SystemSounds/ink/InkSoundStroke1.oga` | Ink / handwriting (Mac stylus) stroke sounds |
| `SystemSounds/ink/InkSoundStroke2.aif` | `wav/SystemSounds/ink/InkSoundStroke2.wav` | `oga/SystemSounds/ink/InkSoundStroke2.oga` | Ink / handwriting (Mac stylus) stroke sounds |
| `SystemSounds/ink/InkSoundStroke3.aif` | `wav/SystemSounds/ink/InkSoundStroke3.wav` | `oga/SystemSounds/ink/InkSoundStroke3.oga` | Ink / handwriting (Mac stylus) stroke sounds |
| `SystemSounds/ink/InkSoundStroke4.aif` | `wav/SystemSounds/ink/InkSoundStroke4.wav` | `oga/SystemSounds/ink/InkSoundStroke4.oga` | Ink / handwriting (Mac stylus) stroke sounds |
| `SystemSounds/siri/jbl_begin.caf` | `wav/SystemSounds/siri/jbl_begin.wav` | `oga/SystemSounds/siri/jbl_begin.oga` | Siri begin/confirm/cancel earcons |
| `SystemSounds/siri/jbl_begin_short.caf` | `wav/SystemSounds/siri/jbl_begin_short.wav` | `oga/SystemSounds/siri/jbl_begin_short.oga` | Siri begin/confirm/cancel earcons |
| `SystemSounds/siri/jbl_cancel.caf` | `wav/SystemSounds/siri/jbl_cancel.wav` | `oga/SystemSounds/siri/jbl_cancel.oga` | Siri begin/confirm/cancel earcons |
| `SystemSounds/siri/jbl_confirm.caf` | `wav/SystemSounds/siri/jbl_confirm.wav` | `oga/SystemSounds/siri/jbl_confirm.oga` | Siri begin/confirm/cancel earcons |
| `SystemSounds/system/Grab.aif` | `wav/SystemSounds/system/Grab.wav` | `oga/SystemSounds/system/Grab.oga` | Legacy Grab screenshot sound (older screenshot click) |
| `SystemSounds/system/Media Keys.aif` | `wav/SystemSounds/system/Media Keys.wav` | `oga/SystemSounds/system/Media Keys.oga` | Media key feedback (belum dicek exact trigger) |
| `SystemSounds/system/Screen Capture.aif` | `wav/SystemSounds/system/Screen Capture.wav` | `oga/SystemSounds/system/Screen Capture.oga` | Screenshot taken (Cmd-Shift-3/4/5 shutter) |
| `SystemSounds/system/SentMessage.caf` | `wav/SystemSounds/system/SentMessage.wav` | `oga/SystemSounds/system/SentMessage.oga` | Messages: message sent (swoosh) |
| `SystemSounds/system/Shutter.aif` | `wav/SystemSounds/system/Shutter.wav` | `oga/SystemSounds/system/Shutter.oga` | Camera shutter (Photo Booth style capture) |
| `SystemSounds/system/Volume Mount.aif` | `wav/SystemSounds/system/Volume Mount.wav` | `oga/SystemSounds/system/Volume Mount.oga` | External disk / volume mounted |
| `SystemSounds/system/Volume Unmount.aif` | `wav/SystemSounds/system/Volume Unmount.wav` | `oga/SystemSounds/system/Volume Unmount.oga` | External disk / volume ejected |
| `SystemSounds/system/acknowledgment_sent.caf` | `wav/SystemSounds/system/acknowledgment_sent.wav` | `oga/SystemSounds/system/acknowledgment_sent.oga` | Messages: tapback/acknowledgment sent |
| `SystemSounds/system/begin_record.caf` | `wav/SystemSounds/system/begin_record.wav` | `oga/SystemSounds/system/begin_record.oga` | Voice recording / dictation start |
| `SystemSounds/system/burn complete.aif` | `wav/SystemSounds/system/burn complete.wav` | `oga/SystemSounds/system/burn complete.oga` | Disc burn finished |
| `SystemSounds/system/burn failed.aif` | `wav/SystemSounds/system/burn failed.wav` | `oga/SystemSounds/system/burn failed.oga` | Disc burn failed |
| `SystemSounds/system/end_record.caf` | `wav/SystemSounds/system/end_record.wav` | `oga/SystemSounds/system/end_record.oga` | Voice recording / dictation end |
| `SystemSounds/system/head_gestures_double_nod.caf` | `wav/SystemSounds/system/head_gestures_double_nod.wav` | `oga/SystemSounds/system/head_gestures_double_nod.oga` | AirPods head gestures (nod/shake) feedback |
| `SystemSounds/system/head_gestures_double_shake.caf` | `wav/SystemSounds/system/head_gestures_double_shake.wav` | `oga/SystemSounds/system/head_gestures_double_shake.oga` | AirPods head gestures (nod/shake) feedback |
| `SystemSounds/system/head_gestures_partial_nod.caf` | `wav/SystemSounds/system/head_gestures_partial_nod.wav` | `oga/SystemSounds/system/head_gestures_partial_nod.oga` | AirPods head gestures (nod/shake) feedback |
| `SystemSounds/system/head_gestures_partial_shake.caf` | `wav/SystemSounds/system/head_gestures_partial_shake.wav` | `oga/SystemSounds/system/head_gestures_partial_shake.oga` | AirPods head gestures (nod/shake) feedback |
| `SystemSounds/system/media_handoff.caf` | `wav/SystemSounds/system/media_handoff.wav` | `oga/SystemSounds/system/media_handoff.oga` | Media handoff |
| `SystemSounds/system/media_paused.caf` | `wav/SystemSounds/system/media_paused.wav` | `oga/SystemSounds/system/media_paused.oga` | Media paused by system (e.g. handoff/route change) |
| `SystemSounds/system/mic_mute.caf` | `wav/SystemSounds/system/mic_mute.wav` | `oga/SystemSounds/system/mic_mute.oga` | Microphone muted |
| `SystemSounds/system/mic_unmute.caf` | `wav/SystemSounds/system/mic_unmute.wav` | `oga/SystemSounds/system/mic_unmute.oga` | Microphone unmuted |
| `SystemSounds/system/mic_unmute_fail.caf` | `wav/SystemSounds/system/mic_unmute_fail.wav` | `oga/SystemSounds/system/mic_unmute_fail.oga` | Microphone unmute failed |
| `SystemSounds/system/payment_failure.aif` | `wav/SystemSounds/system/payment_failure.wav` | `oga/SystemSounds/system/payment_failure.oga` | Apple Pay payment failure |
| `SystemSounds/system/payment_success.aif` | `wav/SystemSounds/system/payment_success.wav` | `oga/SystemSounds/system/payment_success.oga` | Apple Pay payment success |
| `SystemSounds/system/screen_sharing_started.caf` | `wav/SystemSounds/system/screen_sharing_started.wav` | `oga/SystemSounds/system/screen_sharing_started.oga` | Screen sharing started |
| `SystemSounds/telephony/busy_tone_ansi.caf` | `wav/SystemSounds/telephony/busy_tone_ansi.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/busy_tone_cept.caf` | `wav/SystemSounds/telephony/busy_tone_cept.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/call_waiting_tone_ansi.caf` | `wav/SystemSounds/telephony/call_waiting_tone_ansi.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/call_waiting_tone_cept.caf` | `wav/SystemSounds/telephony/call_waiting_tone_cept.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/call_waiting_tone_low_priority.caf` | `wav/SystemSounds/telephony/call_waiting_tone_low_priority.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-0.caf` | `wav/SystemSounds/telephony/dtmf-0.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-1.caf` | `wav/SystemSounds/telephony/dtmf-1.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-2.caf` | `wav/SystemSounds/telephony/dtmf-2.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-3.caf` | `wav/SystemSounds/telephony/dtmf-3.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-4.caf` | `wav/SystemSounds/telephony/dtmf-4.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-5.caf` | `wav/SystemSounds/telephony/dtmf-5.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-6.caf` | `wav/SystemSounds/telephony/dtmf-6.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-7.caf` | `wav/SystemSounds/telephony/dtmf-7.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-8.caf` | `wav/SystemSounds/telephony/dtmf-8.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-9.caf` | `wav/SystemSounds/telephony/dtmf-9.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-pound.caf` | `wav/SystemSounds/telephony/dtmf-pound.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/dtmf-star.caf` | `wav/SystemSounds/telephony/dtmf-star.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/end_call_tone_cept.caf` | `wav/SystemSounds/telephony/end_call_tone_cept.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/ringback_tone_ansi.caf` | `wav/SystemSounds/telephony/ringback_tone_ansi.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `SystemSounds/telephony/ringback_tone_cept.caf` | `wav/SystemSounds/telephony/ringback_tone_cept.wav` | - | Phone/FaceTime Audio: DTMF keypad tones and call progress tones |
| `Telephony/busy_tone_cept.caf` | `wav/Telephony/busy_tone_cept.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/call_waiting_tone_cept.caf` | `wav/Telephony/call_waiting_tone_cept.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/call_waiting_tone_low_priority.caf` | `wav/Telephony/call_waiting_tone_low_priority.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/end_call_tone_cept.caf` | `wav/Telephony/end_call_tone_cept.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/end_call_tone_cept.wav` | `wav/Telephony/end_call_tone_cept.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/hold.wav` | `wav/Telephony/hold.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/let-me-join.caf` | `wav/Telephony/let-me-join.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/multiway-join.caf` | `wav/Telephony/multiway-join.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/multiway-leave.caf` | `wav/Telephony/multiway-leave.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/mute.caf` | `wav/Telephony/mute.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/mute_fail.caf` | `wav/Telephony/mute_fail.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/ringback_tone_ansi.caf` | `wav/Telephony/ringback_tone_ansi.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/ringback_tone_aus.caf` | `wav/Telephony/ringback_tone_aus.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/ringback_tone_cept.caf` | `wav/Telephony/ringback_tone_cept.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/ringback_tone_hk.caf` | `wav/Telephony/ringback_tone_hk.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/ringback_tone_uk.caf` | `wav/Telephony/ringback_tone_uk.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/shareplay_activity.caf` | `wav/Telephony/shareplay_activity.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/unmute.caf` | `wav/Telephony/unmute.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/vc~callwaitingring.aif` | `wav/Telephony/vc~callwaitingring.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/vc~ended.aif` | `wav/Telephony/vc~ended.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/vc~ended.caf` | `wav/Telephony/vc~ended.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/vc~invitation-accepted.caf` | `wav/Telephony/vc~invitation-accepted.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `Telephony/vc~ringing.aif` | `wav/Telephony/vc~ringing.wav` | - | TelephonyUtilities call sounds (ringing, ended, mute, hold, SharePlay) |
| `VoiceOverSounds/ActionsAvailable.aiff` | `wav/VoiceOverSounds/ActionsAvailable.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Alert.aiff` | `wav/VoiceOverSounds/Alert.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/AlertRepeat.aiff` | `wav/VoiceOverSounds/AlertRepeat.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/AnimationFlyToDownloads.aiff` | `wav/VoiceOverSounds/AnimationFlyToDownloads.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/AnimationShake.aiff` | `wav/VoiceOverSounds/AnimationShake.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Announcement.aiff` | `wav/VoiceOverSounds/Announcement.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/AttachmentBegin.aiff` | `wav/VoiceOverSounds/AttachmentBegin.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/AttachmentEnd.aiff` | `wav/VoiceOverSounds/AttachmentEnd.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Back.aiff` | `wav/VoiceOverSounds/Back.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BackThrough.aiff` | `wav/VoiceOverSounds/BackThrough.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BrailleChordClockTick.aiff` | `wav/VoiceOverSounds/BrailleChordClockTick.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BrailleChordFailed.aiff` | `wav/VoiceOverSounds/BrailleChordFailed.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BrailleChordMemorize.aiff` | `wav/VoiceOverSounds/BrailleChordMemorize.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BrailleDisplayConnected.aiff` | `wav/VoiceOverSounds/BrailleDisplayConnected.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BrailleDisplayDisconnected.aiff` | `wav/VoiceOverSounds/BrailleDisplayDisconnected.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BubbleAppear.aiff` | `wav/VoiceOverSounds/BubbleAppear.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/BubbleDisappear.aiff` | `wav/VoiceOverSounds/BubbleDisappear.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/CallOut.aiff` | `wav/VoiceOverSounds/CallOut.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Capitals.aiff` | `wav/VoiceOverSounds/Capitals.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ClickFast.aiff` | `wav/VoiceOverSounds/ClickFast.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Collaboration.wav` | `wav/VoiceOverSounds/Collaboration.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DragShort.aiff` | `wav/VoiceOverSounds/DragShort.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DrawOn.aiff` | `wav/VoiceOverSounds/DrawOn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DrawerClosing.aiff` | `wav/VoiceOverSounds/DrawerClosing.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DrawerOpening.aiff` | `wav/VoiceOverSounds/DrawerOpening.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DrillIn.aiff` | `wav/VoiceOverSounds/DrillIn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/DrillOut.aiff` | `wav/VoiceOverSounds/DrillOut.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ElementBorder.aiff` | `wav/VoiceOverSounds/ElementBorder.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ElementBorderHit.aiff` | `wav/VoiceOverSounds/ElementBorderHit.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Ellipsis.aiff` | `wav/VoiceOverSounds/Ellipsis.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/EmptySpace.aiff` | `wav/VoiceOverSounds/EmptySpace.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/EnterInvisibleArea.aiff` | `wav/VoiceOverSounds/EnterInvisibleArea.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/EnterVisibleArea.aiff` | `wav/VoiceOverSounds/EnterVisibleArea.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/EnteringMultiSelect.aiff` | `wav/VoiceOverSounds/EnteringMultiSelect.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Error.aiff` | `wav/VoiceOverSounds/Error.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ExitingMultiSelect.aiff` | `wav/VoiceOverSounds/ExitingMultiSelect.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Focus.aiff` | `wav/VoiceOverSounds/Focus.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Focus2.aiff` | `wav/VoiceOverSounds/Focus2.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Forward.aiff` | `wav/VoiceOverSounds/Forward.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ForwardThrough.aiff` | `wav/VoiceOverSounds/ForwardThrough.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/GazeEnteredScene.aiff` | `wav/VoiceOverSounds/GazeEnteredScene.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/GazeLeftScene.aiff` | `wav/VoiceOverSounds/GazeLeftScene.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/GuideProgress.aiff` | `wav/VoiceOverSounds/GuideProgress.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/GuideSuccess.aiff` | `wav/VoiceOverSounds/GuideSuccess.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Hit.aiff` | `wav/VoiceOverSounds/Hit.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Indentation.caf` | `wav/VoiceOverSounds/Indentation.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/IntelligenceAvailable.wav` | `wav/VoiceOverSounds/IntelligenceAvailable.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/IntelligencePost.wav` | `wav/VoiceOverSounds/IntelligencePost.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/IntelligencePre.wav` | `wav/VoiceOverSounds/IntelligencePre.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/IntelligenceProgress.wav` | `wav/VoiceOverSounds/IntelligenceProgress.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Interactable.aiff` | `wav/VoiceOverSounds/Interactable.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/KBVONotSynched.aiff` | `wav/VoiceOverSounds/KBVONotSynched.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/KBVOSynched.aiff` | `wav/VoiceOverSounds/KBVOSynched.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/LayoutChanged.aiff` | `wav/VoiceOverSounds/LayoutChanged.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/LinkBegin.aiff` | `wav/VoiceOverSounds/LinkBegin.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/LinkEnd.aiff` | `wav/VoiceOverSounds/LinkEnd.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/MenuDown.aiff` | `wav/VoiceOverSounds/MenuDown.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Misspelled.aiff` | `wav/VoiceOverSounds/Misspelled.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/MoreContentAvailable.aiff` | `wav/VoiceOverSounds/MoreContentAvailable.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/MouseDown.aiff` | `wav/VoiceOverSounds/MouseDown.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/MouseDrag.aiff` | `wav/VoiceOverSounds/MouseDrag.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/MouseUp.aiff` | `wav/VoiceOverSounds/MouseUp.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/NotFound.aiff` | `wav/VoiceOverSounds/NotFound.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/NothingTracking.aiff` | `wav/VoiceOverSounds/NothingTracking.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/PopupAppeared.aiff` | `wav/VoiceOverSounds/PopupAppeared.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavArrowKeyOff.wav` | `wav/VoiceOverSounds/QuickNavArrowKeyOff.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavArrowKeyOn.wav` | `wav/VoiceOverSounds/QuickNavArrowKeyOn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavOff.wav` | `wav/VoiceOverSounds/QuickNavOff.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavOn.wav` | `wav/VoiceOverSounds/QuickNavOn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavSingleKeyOff.wav` | `wav/VoiceOverSounds/QuickNavSingleKeyOff.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/QuickNavSingleKeyOn.wav` | `wav/VoiceOverSounds/QuickNavSingleKeyOn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Reorder.aiff` | `wav/VoiceOverSounds/Reorder.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Ring.aiff` | `wav/VoiceOverSounds/Ring.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/RotorLeft.aiff` | `wav/VoiceOverSounds/RotorLeft.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/RotorRight.aiff` | `wav/VoiceOverSounds/RotorRight.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/ScrollPage.aiff` | `wav/VoiceOverSounds/ScrollPage.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SearchRangeWithinSameElement.aiff` | `wav/VoiceOverSounds/SearchRangeWithinSameElement.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SecureCharacter.aiff` | `wav/VoiceOverSounds/SecureCharacter.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SecureCharacter.caf` | `wav/VoiceOverSounds/SecureCharacter.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/Select.aiff` | `wav/VoiceOverSounds/Select.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SingleClick.aiff` | `wav/VoiceOverSounds/SingleClick.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SpringBack.aiff` | `wav/VoiceOverSounds/SpringBack.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/SpringForward.aiff` | `wav/VoiceOverSounds/SpringForward.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/StyleChangeDouble.aiff` | `wav/VoiceOverSounds/StyleChangeDouble.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/StyleChangeMultiple.aiff` | `wav/VoiceOverSounds/StyleChangeMultiple.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/StyleChangeSingle.aiff` | `wav/VoiceOverSounds/StyleChangeSingle.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/TrackingOff.aiff` | `wav/VoiceOverSounds/TrackingOff.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/TrackingOn.aiff` | `wav/VoiceOverSounds/TrackingOn.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/TrackingSystemElement.aiff` | `wav/VoiceOverSounds/TrackingSystemElement.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WebAreaLoaded.aiff` | `wav/VoiceOverSounds/WebAreaLoaded.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WebPageLoaded.aiff` | `wav/VoiceOverSounds/WebPageLoaded.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WindowActivated.aiff` | `wav/VoiceOverSounds/WindowActivated.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WrapBack.aiff` | `wav/VoiceOverSounds/WrapBack.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WrapBackHard.aiff` | `wav/VoiceOverSounds/WrapBackHard.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WrapBoundary.aiff` | `wav/VoiceOverSounds/WrapBoundary.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WrapForward.aiff` | `wav/VoiceOverSounds/WrapForward.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/WrapForwardHard.aiff` | `wav/VoiceOverSounds/WrapForwardHard.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/XcodeLineBreakpoint.aiff` | `wav/VoiceOverSounds/XcodeLineBreakpoint.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/XcodeLineDebugLine.wav` | `wav/VoiceOverSounds/XcodeLineDebugLine.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/XcodeLineError.aiff` | `wav/VoiceOverSounds/XcodeLineError.wav` | - | VoiceOver UI earcons |
| `VoiceOverSounds/XcodeLineWarning.aiff` | `wav/VoiceOverSounds/XcodeLineWarning.wav` | - | VoiceOver UI earcons |
| `misc/AirDrop-invite.caf` | `wav/misc/AirDrop-invite.wav` | `oga/misc/AirDrop-invite.oga` | AirDrop incoming request |
| `misc/BezelServices-volume.aiff` | `wav/misc/BezelServices-volume.wav` | `oga/misc/BezelServices-volume.oga` | Volume key press feedback ("pop") when changing volume |
| `misc/Dictation-UnableToStart.caf` | `wav/misc/Dictation-UnableToStart.wav` | `oga/misc/Dictation-UnableToStart.oga` | Dictation: unable to start |
| `misc/FindMy-fmd_sound.caf` | `wav/misc/FindMy-fmd_sound.wav` | `oga/misc/FindMy-fmd_sound.oga` | Find My: play sound on device |
| `misc/Finder-Invitation.aiff` | `wav/misc/Finder-Invitation.wav` | `oga/misc/Finder-Invitation.oga` | Finder: sharing invitation |
| `misc/Grapher-snapshot.aiff` | `wav/misc/Grapher-snapshot.wav` | `oga/misc/Grapher-snapshot.oga` | Grapher snapshot |
| `misc/Mail-Fetch_Error.aiff` | `wav/misc/Mail-Fetch_Error.wav` | `oga/misc/Mail-Fetch_Error.oga` | Mail: fetch error |
| `misc/Mail-New_Mail.aiff` | `wav/misc/Mail-New_Mail.wav` | `oga/misc/Mail-New_Mail.oga` | Mail: new mail received |
| `misc/Mail-Scheduled.wav` | `wav/misc/Mail-Scheduled.wav` | `oga/misc/Mail-Scheduled.oga` | Mail: send scheduled |
| `misc/Mail-Sent.aiff` | `wav/misc/Mail-Sent.wav` | `oga/misc/Mail-Sent.oga` | Mail: message sent (swoosh) |
| `misc/Messages-Sent_Acknowledgment.aiff` | `wav/misc/Messages-Sent_Acknowledgment.wav` | `oga/misc/Messages-Sent_Acknowledgment.oga` | Messages: sent tapback |
| `misc/Messages-Sent_Message.aiff` | `wav/misc/Messages-Sent_Message.wav` | `oga/misc/Messages-Sent_Message.oga` | Messages: sent message (IMDaemon) |
| `misc/Messages-Sent_Scheduled_Message.caf` | `wav/misc/Messages-Sent_Scheduled_Message.wav` | `oga/misc/Messages-Sent_Scheduled_Message.oga` | Messages: scheduled message sent |
| `misc/PhotoBooth-action.aif` | `wav/misc/PhotoBooth-action.wav` | `oga/misc/PhotoBooth-action.oga` | Photo Booth: capture countdown/action |
| `misc/PowerChime-connect_power.aif` | `wav/misc/PowerChime-connect_power.wav` | `oga/misc/PowerChime-connect_power.oga` | MagSafe / power adapter connected chime |
| `misc/SecurityInterface-lock.aif` | `wav/misc/SecurityInterface-lock.wav` | `oga/misc/SecurityInterface-lock.oga` | Security lock UI: lock |
| `misc/SecurityInterface-lockClosing.aif` | `wav/misc/SecurityInterface-lockClosing.wav` | `oga/misc/SecurityInterface-lockClosing.oga` | Security lock UI: lock closing animation |
| `misc/SecurityInterface-lockOpening.aif` | `wav/misc/SecurityInterface-lockOpening.wav` | `oga/misc/SecurityInterface-lockOpening.oga` | Security lock UI: lock opening animation |
| `misc/SecurityInterface-unlock.aif` | `wav/misc/SecurityInterface-unlock.wav` | `oga/misc/SecurityInterface-unlock.oga` | Security lock UI: unlock |
| `misc/Social-Sent.aiff` | `wav/misc/Social-Sent.wav` | `oga/misc/Social-Sent.oga` | Share sheet: post sent |
| `misc/VoiceBanking-recordingDidFinish.wav` | `wav/misc/VoiceBanking-recordingDidFinish.wav` | `oga/misc/VoiceBanking-recordingDidFinish.oga` | Personal Voice recording start/finish |
| `misc/VoiceBanking-recordingWillStart.wav` | `wav/misc/VoiceBanking-recordingWillStart.wav` | `oga/misc/VoiceBanking-recordingWillStart.oga` | Personal Voice recording start/finish |
