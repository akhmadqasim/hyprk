# Sound REA, macOS 27.2.1 (26B131)

Static reverse engineering only. Nothing was played or run on a Mac. Every "designed delay" below is a constant or a
call order read from code, not a measured output latency.

Headline: on 27.2.1 the volume keys are handled by **ControlCenter.framework**, not by BezelServices. BezelServices'
`-[BezelServicesTask handleCGSEvent:]` returns at once when the feature flag `ControlCenter/Bezel` is on, and that flag is
on in a stock install. So the key-up pop that `shell/SOUNDS.md` and `shell/scripts/volume-key.sh` copy from BezelServices'
`VolumeStateMachine` is not what 27.2.1 does. Control Center pops on every step: the key press and every auto-repeat.

## Method (PC, Linux)
- Binaries copied read-only from the system volume (`141-12228-174.dmg`, already mounted by another agent under
  `~/Downloads/macos/re-work/gaps-panels/mnt`) into `~/Downloads/macos/re-work/gaps-sound/fat`, thinned with
  `llvm-lipo -thin arm64e`: `Sound.appex`, `MouseExtension.appex`, `BezelServices`, `systemsoundserverd`,
  `screencapture`, `screencaptureui`, `OSDUIHelper`; plus `/System/Library/FeatureFlags/Domain/ControlCenter.plist`.
- Ghidra 12.1.4 headless, own project `~/Downloads/macos/re-work/gh-sound-gaps` (heap 4 GB), scripts in
  `~/Downloads/macos/re-work/gaps-sound/scripts` (`DecNames.java`, `DecAddrs.java`, `Refs.java`).
- REA CLI (`rea decompile <path> <addr> --provider ghidra --json`, Ghidra 12.1.4) for the Evidence IDs cited as `ev_...`.
  Evidence JSON: `~/Downloads/macos/re-work/gaps-sound/out/rea/`.
- dyld cache `~/Downloads/macos/dyld-27.2.1/dyld_shared_cache_arm64e` (+ `.a2s`): `ipsw dyld symaddr`, `disass`,
  `xref -i <image>`, `dump`, `str`. ControlCenter.framework cannot be extracted (`failed to remap symbol
  _objc_msgSend$B14HasMedia`), so it was read by disassembly only. objc stubs were resolved by disassembling the stub
  (`adrp x1, selref; b _objc_msgSend`).
- Kernel: `ipsw extract --kernel` of the restore image, `kernelcache.release.Mac14,2_3_7_15`,
  `ipsw kernel extract ... com.apple.iokit.IOHIDFamily`, `llvm-objdump -d`.
- No REA Evidence exists for the dyld cache images (ControlCenter.framework, AudioToolbox, AppKit, HIToolbox, IOKit,
  MachineSettings, libsystem_featureflags) or the kernel: REA cannot open them. Those addresses come from ipsw /
  llvm-objdump output, quoted in the excerpt file.
- REA Evidence IDs are shortened in the text; the full IDs (binary, address, id):
  `Sound.appex.bin 0x100007f28` ev_45fd87a640460e0fdc1466b5aefe8eb2f01d31f2ce984573ccd6fea6458ce424
  `Sound.appex.bin 0x100008cfc` ev_56beeb9814a0e1d64b3ed3c31679a92dc4cdac94a1b53818cc9d0955d1e004bf
  `Sound.appex.bin 0x100008d74` ev_6481f841554d3ad55b2cfced3855d48ade01adee899207d972c4f8b924f3154c
  `Sound.appex.bin 0x100015d7c` ev_e3fc15eaac3865d99a39383e8e9acef912b1e078dfde8b741d18adb40ebc6941
  `systemsoundserverd 0x100005e78` ev_7b1a08dbbddf9aed1b1ecd0cc1664678893ce151c48d996e0a04414995c22967
  `systemsoundserverd 0x100006814` ev_0793222c06c1b83d7545a2fda46527d28ed68170a1e15a163cefa82be2f6a3f9
  `MouseExtension.bin 0x10003035c` ev_7d9333bbb7ed118cd4b5ddf4107c3cc9c39d37a942625a158a60e1f351fcf339
  `MouseExtension.bin 0x100018adc` ev_42ed2120dde5fec7d9f999591f4f0f1d3df828305d97ad25cbfe9805ce42aa83
  `screencapture 0x10000cc88` ev_a8217ce16c9c67f5daf2b493761e49624c786004235500d1fc1421ecb1df529d
  `BezelServices 0x309c` ev_49e064665b25e00357fffddbba06a42ad639cdfc6737d9c618487f47ac66932e
  `Sound.appex.bin 0x100007f98` ev_e732d5b70101bbafe231018d1307fd09c1f806e256d8516f5b5bb20166eb8a89
- Excerpts: `reference/re/27.2.1/decomp/sound-gaps.c` (sections 1 to 8 below refer to it).

## 1. Alert volume slider to gain

Chain, all confirmed:

| step | what | source |
|---|---|---|
| slider | position `s` in 0..1 | Sound.appex `FUN_10001d680` (setter closure): calls `setAlertSoundVolume:` only when `s` differs from the current value |
| curve | `stored = s == 0 ? 0 : exp(s - 1)` | `-[AppleSound_SoundSettings setAlertSoundVolume:]` 0x100007f98 (`ev_e732d5b70101...`); `AudioServicesSetProperty('ssvl', 4 bytes)` |
| reverse | `s = stored == 0 ? 0 : 1 + ln(stored)`; 0.5 when the property read fails | `-alertSoundVolume` 0x100007f28 (`ev_45fd87a64046...`) |
| store | `com.apple.sound.beep.volume` = `stored`, Float32, unchanged, then the notification `com.apple.coreaudio.SystemSoundVolumeChanged` | AudioToolbox `SaveSystemSoundPref` 0x1adcf43e8, 'ssvl' branch 0x1adcf4700..0x1adcf47d4 (CFNumber type 5; CFString 0x1e58a3c70 = 27 chars at 0x1adea2724) |
| daemon | `volume = user vol x client vol scalar x CM vol` | systemsoundserverd 0x10000b6cc, 0x10000b6f4 (SOUNDS.md, re-checked) |
| gain | `AudioUnitSetParameter(mixer, 0, kAudioUnitScope_Input, bus, volume)` on an `aumx/smxr/appl` Stereo Mixer | systemsoundserverd `FUN_100005e78` vtable +0x38 (slot 0x10001c220, PAC 0x1246) -> `FUN_100006814` (`ev_0793222c06c1...`): `v8 = v0` at 0x10000683c, calls at 0x100006df0 and 0x100006fc4; description at 0x100014cc0 |

- The Stereo Mixer's input volume parameter 0 is a linear gain (inferred from Apple's AudioUnitParameters.h meaning of
  `kStereoMixerParam_Volume`; the mixer's own code was not read).
- Client vol scalar: 1.0 for a plain `AudioServicesPlaySystemSound` (inferred: screencapture, Finder and NSBeep pass no
  options; the AudioToolbox default was not read). CM vol: 1.0 (SOUNDS.md, no other writer found).
- So the linear gain is `exp(s - 1)`, `20 log10(e) (s - 1)` = **8.69 dB x (s - 1)**, and `s = 0` is silent:

| slider s | Mac gain | Mac dB | hyprk now (`pw-play --volume s`) | hyprk dB |
|---|---|---|---|---|
| 0.25 | 0.472 | -6.51 | 0.25 | -12.04 |
| 0.50 | 0.607 | -4.34 | 0.50 | -6.02 |
| 0.75 | 0.779 | -2.17 | 0.75 | -2.50 |
| 1.00 | 1.000 | 0.00 | 1.00 | 0.00 |
| 0 | 0 (silent) | - | 0 | - |

- Same factor: every sound systemsoundserverd plays (alert 0x1000, screenshot 1393, Bin 13/16, poof 15, task done 1):
  one "Starting audio" path, gate only by `uiaudio.enabled` / `beep.enabled` (SOUNDS.md). Confirmed.
- Not this factor: the volume pop. On 27.2.1 it is an `AVAudioPlayer` in ControlCenter.framework (section 2), with no
  volume set in the play block (confirmed: the block only does init, `stop` on the old player, `play`). The power chime
  (PowerChime, NSSound) was not re-read.
- The Settings Alert volume slider plays the alert when you let go: onEditingChanged closure `FUN_10000d99c` plays when
  editing is false -> `-playBeepAtAlertVolume` 0x100008d74 (`ev_6481f841554d...`):
  `cancelPreviousPerformRequests`, then `performSelector:beepAtAlertVolume: afterDelay: 0.03` (const 0x10002daa8);
  `-beepAtAlertVolume:` 0x100008c9c does `AudioServicesStopSystemSound(0x1000)` then `AudioServicesPlaySystemSound(0x1000)`.
  Confirmed.
- Default: with no `com.apple.sound.beep.volume` the client sends 1.0: AudioToolbox `SendClientPrefsToServer`
  0x1adcf0590 stores 0x3f800000 in the local at 0x1adcf0628 before `CACFDictionary::GetFloat32` (0x1adcf0688), which
  leaves it when the key is absent. So the slider shows 1.0 (`1 + ln 1`). Confirmed.

What differs in hyprk (do not change here, listed for the fix):
- `shell/scripts/sound.sh:89` (and `:91` for paplay) plays at `--volume "$vol"` with `vol = alertVolume` (linear).
  Mac: `exp(alertVolume - 1)`, 0 when alertVolume is 0. `:82` (`vol=1` for volume and power) stays.
- `settings/panes/Sound.qml:51-53` `play(file, volume)`: the alert preview uses the same linear volume. Mac: same curve.
- `settings/panes/Sound.qml:111` plays on release at once and does not stop the previous preview. Mac: 30 ms after the
  last release, stops the alert that is still playing first. FIXED 2026-11-14: `letGo` timer (30 ms, restarts) and
  the pid file in `play()`.
- Default `alertVolume` 0.75 (`shell/scripts/sound.sh:42`, `:44`, `settings/Parsers.js:281`): the Mac's stock value is
  1.0 (stored and shown). 0.75 may be the user's own Mac setting; it is not the system default.

## 2. Designed delay: volume pop and screenshot shutter

### Volume keys (ControlCenter.framework), confirmed
- BezelServices is bypassed: `-[BezelServicesTask handleCGSEvent:]` 0x309c (`ev_49e064665b25...`) returns when
  `_os_feature_enabled_impl("ControlCenter", "Bezel")` is true. The flag plist has `Bezel: {DevelopmentPhase:
  FeatureComplete}` and no `Enabled` key; libsystem_featureflags `_os_feature_enabled_SLOWPATH` 0x18555d8a8 sets
  enabled = (`DevelopmentPhase` == "FeatureComplete") when `Enabled` is absent. A user override in
  /Library/Preferences/FeatureFlags could turn it off (not looked for; none on a stock install, inferred).
- Path: `HotKeys.registerBezelHotKeys(with:)` 0x20a57cc34 adds a keyDown observer (0x20a57cef4) and a keyUp observer
  (0x20a57d690). keyDown: maps the key (0x20a595548: step 1/16, 1/64 for the small-increment key; flag bit 0x10000
  only when the modifiers are exactly Shift), calls `perform` 0x20a59567c at once (0x20a57d4cc), then starts a repeating
  `NSTimer` with fire date `now + NXKeyRepeatThreshold` and interval `NXKeyRepeatInterval` (`_NXKeyRepeatPrefs`
  0x20a583328). Each timer tick calls `perform` again (block 0x20a5833b0 -> 0x20a57e428 -> 0x20a57e5f0). keyUp:
  `invalidate` (0x20a57d984) and nothing else: **no pop on key up**.
- `perform` -> volume step 0x20a595dac: `mainVolume`, `canSetVolume`, the 1/64 grid step 0x20a595d28 (same grid as
  BezelServices), `setMute:` when the level crosses 0, `setMainVolume:`, `HUDActionDelegate.showVolume`, then the
  feedback gate 0x20a596298: plays when `canSetVolume` and `playVolumeKeyFeedback != shift`. This runs on **every**
  step, also when the level is already at 0 or 1.
- Mute key: 0x20a595bf0: `isMuted`, `hasMute`, `setMute:(!muted)`, and the gate only when it was muted. So unmute pops
  at once, mute is silent. There is no 0.08 s timer on this path.
- `AudioVolumeFeedbackController.playVolumeFeedbackSound` 0x20a531f40: see 3b; dispatches the play block with
  `DispatchQueue.async` (no deadline) onto its own queue (self+0x10); the block (0x20a531cec) makes a new
  `AVAudioPlayer` for `volume.aiff`, calls `stop` on the previous one and `play` on the new one.
- Designed delays: key press -> play call **0 s** (synchronous, then one async hop). Repeats at
  `NXKeyRepeatThreshold`, then every `NXKeyRepeatInterval`. Kernel defaults (IOHIDSystem::createParameters,
  0xfffffe000ad28b90..0xfffffe000ad28bb8): `HIDKeyRepeat` 83,333,333 ns, `HIDInitialKeyRepeat` 500,000,000 ns. The
  user's Keyboard settings override these; the stock user values were not decoded.

### Screenshot shutter (screencapture), confirmed for the play site
- `FUN_10000cc88` (`ev_a8217ce16c9c...`) and `FUN_100050364`: `AudioServicesSetProperty('ifdi' = 1)`, then
  `AudioServicesPlaySystemSound(0x571)`, then the file is written. Callers `FUN_100055788` / `FUN_100057af0` read
  `CFAbsoluteTimeGetCurrent()` and call the play function with no timer, sleep or asyncAfter in between.
- The only `usleep` (10 ms, `FUN_100035d30`) is a loop that waits for another interactive screencapture's bootstrap
  service, not on the normal path. `-T` (default 5 s) and the toolbar's capture timer apply only when chosen.
- Not decoded: the path from Cmd-Shift-3 to the screencapture process (hotkey owner, launch).

What differs in hyprk:
- `shell/scripts/volume-key.sh:52-58` sets a pending pop and `:68-73` plays it on key up; `:59-67` pops every 1 s at
  full volume. Mac 27.2.1: pop on the press and on every repeat step (at the key repeat interval), never on key up, at
  any level including full and zero.
- `shell/scripts/volume-key.sh:77` waits 0.08 s before the unmute pop. Mac: no wait.
- `config/hypr/hyprland.lua:490-493`: the release binds would play nothing on the Mac's model; the repeating binds
  would call the pop.
- `shell/SOUNDS.md:41-57` (the BezelServices table) describes the path that 27.2.1 skips.
- Kept: the 1/16 and 1/64 grid, Shift-only inversion, no output device -> nothing, a new pop stops the old one.

## 3. Not decoded before

### 3a. Settings > Sound, Output volume slider (Sound.appex), confirmed
- No Shift: the binary has no `NSEvent` / `modifierFlags` reference (strings, imports). The onEditingChanged closure
  `FUN_100015d7c` (`ev_e3fc15eaac38...`) passes only the editing bool.
- When: on let-go only (closure plays when editing is false). While dragging, `FUN_10001f27c` only calls
  `setMainVolume:`.
- Throttle: `-playBeepAtSystemVolume` 0x100008cfc (`ev_56beeb9814a0...`): returns unless
  `playVolumeKeyFeedback`; `cancelPreviousPerformRequestsWithTarget:selector:beepAtSystemVolume:`, then
  `performSelector:afterDelay: 0.03`. So 30 ms after the last let-go, coalesced. `-beepAtSystemVolume:` 0x100008c14
  plays a new `NSSound` of `BezelServices.loginPlugin/.../volume.aiff` (data cached once).
- hyprk `settings/panes/Sound.qml:184`: plays at once on release, `pw-play ... 1`. Mac: 30 ms later, same file, no Shift.
  FIXED 2026-11-14 (same `letGo` timer).

### 3b. Control Center feedback throttle (ControlCenter.framework 0x20a532114), confirmed
- `playVolumeFeedbackSound` 0x20a531f40: `now = Date.now` (0x20a5320c4), reads the stored date (ivar offset
  `data_2712ce560`), `Date.<(stored, now)` at 0x20a532114. If true it queues the play block, then stores
  `now.advanced(by: 0.0)` (`movi v0.2d, #0` at 0x20a5322d0, `Date.advanced(by:)` at 0x20a5322dc). If false it returns.
- Interval: **0 s**. It only drops a second request with the very same Date value (or a clock that went back). It
  gates the key pops (gate 0x20a596298) and the Control Center slider's let-go pop (ControlCenter.app 0x1000e38e0,
  the only call site in the app).
- hyprk: no change needed for this (our CC slider plays once on let-go, `shell/modules/ControlCenter.qml:188`,
  `shell/modules/CcSoundPanel.qml:76`).

## 4. Double-click interval, confirmed

| step | value | source |
|---|---|---|
| `NSEvent.doubleClickInterval` | `GetDblTime() / 60.0` | AppKit 0x18a4ea648 |
| `GetDblTime` | `(UInt32)(secs x 60 + 0.5)` ticks, secs from `GetDoubleClickParameters` -> `NXClickTime` | HIToolbox 0x18ef06ed4, 0x18ef073b8 |
| `NXClickTime` | IOHIDGetParameter `HIDClickTime` (ns) / 1e9; 0 on error | IOKit 0x184e745a0 |
| default | `HIDClickTime` = 0x1dcd6500 = 500,000,000 ns = **0.5 s** | IOHIDFamily kext, IOHIDSystem::createParameters 0xfffffe000ad28b48..b5c and the reset path IOHIDSystem::setParamPropertiesPreGated 0xfffffe000ad2f1b4..f1cc |
| Settings slider | 11 stops, slow to fast: 5.0, 3.0, 2.0, 1.8, 1.7, 1.4, 1.1, 0.8, **0.5**, 0.2, 0.15 s | MouseExtension.appex static array 0x1000517d8 (count 11 at +0x10), `FUN_10003035c` (`ev_7d9333bbb7ed...`), index match within 0.01 s `FUN_100018adc` (`ev_42ed2120dde5...`) |
| write | `_setDoubleClickThresholdLevel(t)`: `NXSetClickTime(t)`, `NXSetClickSpace(min(2 + 6t, 14))`; defaults key `com.apple.mouse.doubleClickThreshold` | MachineSettings 0x297325d1c, string at 0x297326718 |

- The default stop is the 9th of 11 (index 8). NSEvent then returns 30/60 = 0.5 s exactly.
- Inferred: nothing at login sets another value when the user never touched the slider (loginwindow / hidd not read).
- hyprk: `plugin/src/Titlebar.cpp:669` uses 400 ms (comment `:667` says the Mac's is not known). Mac: 500 ms. The Finder
  QML (`finder/qml/Toolbar.qml:25`, `EntryMouseArea.qml:65`, `ColumnView.qml:172`) uses Qt's default
  `mouseDoubleClickInterval` (400 ms on Qt's side; not checked in this session).

## 5. Coverage: system events that play a sound on 27.2.1

From MAC-ANSWERS "Sounds per event", the ID table (`decomp/systemsoundserverd-ids.txt`) and this file. "hyprk" = a
caller found by grep in shell/, finder/, settings/, config/.

| event | Mac file | trigger (Mac) | hyprk |
|---|---|---|---|
| alert / NSBeep | `com.apple.sound.beep.sound`, ID 0x1000 | NSBeep, `AudioServicesPlayAlertSound` | yes (`alert`, Panels `beep`) |
| alert slider let-go | ID 0x1000 | Sound.appex, 30 ms after let-go | fixed 2026-11-14 (was: no 30 ms, no stop of the previous) |
| notification with a sound | the app's sound / alert sound | UNNotificationSound | yes (`notification`) |
| screenshot | system/Screen Capture.aif, ID 1393 | screencapture, before the file is written | yes |
| move to Bin | dock/drag to trash.aif, ID 16 | Finder TMoveToTrashTask | yes (finder `trash-move`) |
| item dropped on the Dock's Bin | dock/drag to trash.aif, ID 16 | Dock | **no**: no drop reaches the Dock (Finder drags in-window only, GAPS-dock-lock-sound.md item 4) |
| empty Bin | finder/empty trash.aif, ID 13 | Finder TEmptyTrashTask, Dock menu | yes |
| Dock poof | dock/poof item off dock.aif, ID 15 | Dock, item removed | yes |
| Finder task done | system/Volume Mount.aif, ID 1 | Finder copy, move, duplicate, put back, archive, mount, erase | yes (`task-done`) |
| volume key pop | BezelServices.loginPlugin/Contents/Resources/volume.aiff | ControlCenter.framework, each step | yes, wrong timing (key up) |
| CC Sound slider let-go | volume.aiff | ControlCenter.app 0x1000e3814 | yes |
| Settings Output slider let-go | volume.aiff (NSSound) | Sound.appex, 30 ms after let-go | fixed 2026-11-14 (was: no 30 ms) |
| charger connected | PowerChime.app/Contents/Resources/connect_power.aif | PowerChime | yes (`power`) |
| Sticky Keys on/off/modifier/locked/stuck | accessibility/Sticky Keys *.aif, IDs 4-8 | Accessibility (caller not traced) | **no** |
| Mouse Keys on/off | accessibility/Mouse Keys ON/OFF.aif, IDs 9-10 | Accessibility (caller not traced) | **no** |
| Slow Keys | accessibility/Slow Keys *.aif, IDs 11-12 | Accessibility (caller not traced) | **no** |
| Media Keys | system/Media Keys.aif, ID 3 | caller not traced | **no** |
| burn complete / failed | system/burn complete.aif, burn failed.aif, IDs 22-23 | disc burning (caller not traced) | **no** |
| screen recording start / stop | system/begin_record.caf, end_record.caf, IDs 1113-1114 | caller not traced | **no** |
| mic mute / unmute / fail | system/mic_mute.caf, mic_unmute.caf, mic_unmute_fail.caf, IDs 1364-1366 | caller not traced | **no** |
| screen sharing started | system/screen_sharing_started.caf, ID 1367 | caller not traced | **no** |
| media paused / handoff | system/media_paused.caf, media_handoff.caf, IDs 1368-1369 | caller not traced | **no** |
| message sent | system/SentMessage.caf, ID 1004 | Messages | no caller (event exists in `sound.sh`) |
| volume unmount | system/Volume Unmount.aif, ID 2 | no caller in Finder or Dock | no caller (event exists) |
| startup chime | firmware, no file | boot | no (nothing to play) |

Telephony, FaceTime, DTMF, Ink, head gesture and payment IDs exist in the table but belong to apps or hardware hyprk
does not have; not listed one by one.

## Not found
- The Stereo Mixer's internal volume law (parameter 0 is taken as linear from Apple's header meaning; the AU code was
  not read).
- AudioToolbox's default client vol scalar for a plain `AudioServicesPlaySystemSound` (not read; taken as 1.0).
- The stock user's `KeyRepeat` / `InitialKeyRepeat` (so the Mac's repeat pop interval for a new user): only the kernel
  defaults were read. Tried: IOHIDSystem::createParameters; not tried: hidd, loginwindow, Keyboard settings extension.
- The hotkey path from Cmd-Shift-3 to the screencapture process (WindowServer / SystemUIServer / screencaptureui):
  not traced. screencaptureui imports no sound API (no `AudioServicesPlaySystemSound`, no NSSound).
- Whether a user override of `ControlCenter/Bezel` exists on the user's Mac (/Library/Preferences/FeatureFlags): not
  readable from here.
- Callers of the accessibility, Media Keys, record, mic and screen sharing sound IDs: not traced.
