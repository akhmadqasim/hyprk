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
| volume key pop | BezelServices.loginPlugin/Contents/Resources/volume.aiff | ControlCenter.framework, each step | yes, at once on every step (fixed 2026-11-14; was on key up) |
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

## 6. Live check in a headless session (2026-11-14)

Session `scripts/smoke.sh` with `HYPRK_AUDIO_STUB=1` (the stub sink: no `wpctl`, no PipeWire write; the machine's
volume untouched by it), `HYPRK_SOUND_LOG` (now `<event> <file> vol=<gain>`, the gain `pw-play` would get) and the
default `HYPRK_MUTE=1`, so nothing played. Events fired through the bind's own command run by Hyprland
(`hyprctl dispatch hl.dsp.exec_cmd`), the IPC, the private bus (`org.freedesktop.Notifications.Notify`) or the virtual
pointer.

| event | trigger here | logged file, gain | Mac rule | result |
|---|---|---|---|---|
| volume key up / down x3, mute, unmute, Shift+up, Option+Shift up (feedback on) | volume-key.sh, the binds' commands | 5 pops: up, up, down, unmute, up 64; none on mute, none on Shift+up; `misc/BezelServices-volume.aiff`, vol=1; stub level 0.25 -> 0.3125 -> 0.375 -> 0.3125 -> muted -> 0.3125 -> 0.375 -> 0.390625 | every step pops at once, muting is silent, Shift inverts, 1/16 and 1/64 grid; NSSound, no alert volume (section 2) | match |
| feedback off, Shift+up | same | 1 pop | Shift inverts the setting | match |
| CC Sound slider dragged 1060 -> 1030 pt, released | vptr | nothing during the drag, 1 pop after release, vol=1 | one pop on let-go (0x1000e3814) | match |
| alert | `qs ipc call sounds play alert` | `Sounds/Tink.aiff` vol=1.0000; with alertSound Funk, alertVolume 0.25: `Funk.aiff` vol=0.4724 | alert sound, gain exp(s - 1) = 0.472 (section 1) | match |
| notification with `sound-name` Glass / `sound-file` Hero.aiff / `sound-name` default | Notify on the session bus | `Glass.aiff`, `Hero.aiff`, `Tink.aiff` (the alert sound), vol=1.0000 | the named sound, the file, the default sound | match |
| notification without a sound hint / with `suppress-sound` | same | nothing | silent | match |
| critical notification | same | `alert` `Tink.aiff` | SOUNDS.md: alert sound | match (hyprk's choice, no Mac rule decoded) |
| screenshot (the Print / Cmd+Shift+3 bind's command) | exec_cmd | `SystemSounds/system/Screen Capture.aif` vol=1.0000 before grim writes; nothing with uiSounds off | ID 1393, before the file is written, gated by UI sounds, scaled by the alert volume | match |
| app dragged off the Dock (Launchpad, held 1.2 s 265 pt above, released) | vptr | `SystemSounds/dock/poof item off dock.aif` vol=1.0000 | ID 15 | match |
| Empty Trash (Dock menu, confirmed) | `qs ipc call panels confirmEmptyTrash`, click | nothing, the Trash not emptied | ID 13 after the erase | not testable here: `gio trash --empty` fails without gvfs on the session's private bus ("trash:: Operation not supported"), and the sound plays only after it succeeds (`services/Apps.qml` emptyTrash). The file and gain are covered by `shell/tests` ("sound log carries the gain") |
| lock / unlock | not fired (the lock screen needs the user's password to leave) | (static) no `Sounds` call in `shell/modules/lock` | the Mac plays nothing on lock / unlock (no ID for it, section 5) | match (by code) |
| Finder copy / move to Trash | not fired (no keyboard injection here) | (static) `finder/src/fileops.cpp` task-done, `finder/qml/Browser.qml` trash-move / trash-empty | IDs 1, 16, 13 | covered by the Finder's own tests, not live |

No mismatch found. Fixed in the docs: the volume key row above (stale), SOUNDS.md's `alertVolume` default (0.75 there,
1 in `sound.sh`, `settings/Parsers.js` and the Mac). Not checked: output latency (needs the Mac), the power chime (no
UPower battery in the session).

## 7. Round R5.1 (timing with system audio), 2026-11-14

Mac clips `reference/screens/27.2.1/sound/` (INDEX.md), method in MAC-ANSWERS-5.md R5.1: ScreenCaptureKit with
`SCRecordingOutput`, video and system audio from one stream on one host clock, both from pts 0. Read on the PC with
ffmpeg 6: the audio track's edit list (media time 2264 samples, the AAC priming) is applied, so audio pts are the
writer's. Onset = first sample above -50 dBFS on either channel; the file's position = cross-correlation with the
sound file decoded at 48 kHz; level = least-squares gain against the file at that lag, per channel; HUD = first frame
whose pixels differ from the frame before by more than 4 levels (crop x 2200..2880, y 40..280 px). Scripts in the
agent's scratch (`onset.py`, `scan.py`, `keytime.py`, `hudt.py`), not in the repo.

| clip | sound found | where | above -50 dBFS | level vs the file | picture |
|---|---|---|---|---|---|
| volume-pop.mov | `volume.aiff` (correlation .999) | file sample 0 at 1.2320 s (the -50 dB onset 1.2297 is AAC pre-echo) | 1.2297-1.2565 s, 26.8 ms (file 24.4) | -0.13 dB on both channels (mono file to both, no pan law) | menu bar Control Center pill 1.1833 s; first HUD frame 1.2500 (glyph and dashes faint, up to 11 levels); 1.2667 clearer |
| screenshot.mov | **`Blow.aiff`, the account's alert sound** (correlation 1.000), not the shutter | file sample 0 at 1.0929 s (keystroke "about 1.0 s") | 1.1019-1.9365 s, 834.6 ms (file 834.7) | 0.00 dB on both channels (gain 1.000) | nothing drawn |

- **Pop against the HUD:** the pop is in the output 18 ms before the HUD's first frame (35 ms before the clearer frame
  at 1.2667; MAC-ANSWERS-5's 37 ms is 1.230 to 1.267) and 49 ms after the Control Center pill. R3.4 put the first HUD
  frame 18 ms after the appear spring's start, so the pop and the spring start coincide here (1.232 s; inferred, one
  clip). Control Center calls play with no timer (section 2), so the 49 ms is the pill-to-sound time of its
  `AVAudioPlayer` path (inferred; the key's own time is not in the clip).
- **Pop level:** the file's level (-0.13 dB): no alert volume on the pop, as `sound.sh` does (vol=1). Confirmed.
- **Alert level:** Blow at alert volume 100 plays at gain 1.000 = exp(1 - 1), section 1's curve at its stock point (the
  other points not measured). The output volume (81) is not in the capture (the gain is exactly 1; inferred:
  ScreenCaptureKit takes the mix before the device volume).
- **Screenshot:** Cmd-Shift-3 from System Events while the stream ran wrote no file and played the alert sound
  (NSBeep; the account's `com.apple.sound.beep.sound` is Blow, MAC-ANSWERS.md:3705) instead of the shutter, so the
  shutter's offset and level are still **not measured**. The file stays Screen Capture.aif: screencapture plays ID
  1393 (`decomp/systemsoundserverd-ids.txt:97-105`); Shutter.aif (the same bytes as Grab.aif, ID 24) has no ID.
  MAC-ANSWERS-5's "Shutter.aif" names a file in the folder, not a match.
- **Empty Trash, Move to Trash, Dock poof** were not filmed. hyprk fires the Mac's files: `trash-empty` ->
  `finder/empty trash.aif` (ID 13; `shell/services/Apps.qml:541` after the erase, `finder/qml/Browser.qml:267`),
  `trash-move` -> `dock/drag to trash.aif` (ID 16, Finder TMoveToTrashTask, `finder/qml/Browser.qml:261`; `move to
  trash.aif` is ID 14, which nothing in Finder or the Dock plays), `poof` -> `dock/poof item off dock.aif` (ID 15,
  `shell/modules/Dock.qml:443`). No mapping changed.
- **"Play feedback when volume is changed"** is off on this account (R5.1; `com.apple.sound.beep.feedback` = 0 with the
  setting untouched, MAC-ANSWERS.md:564). hyprk is off by default already (`shell/scripts/sound.sh:43`,
  `settings/Parsers.js:282`). The stock default is not decoded: Sound.appex `-[AppleSound_SoundSettings
  playVolumeKeyFeedback]` reads that key, but the Ghidra project `gh-sound-gaps` was saved by Ghidra 12.2 and REA
  accepts only 12.1.x, so it was not decompiled this time.

Ours, headless session (scale 2, stub sink, `HYPRK_MUTE=1`, `HYPRK_SOUND_LOG`; nothing played). `keytime.py` runs
`volume-key.sh` and stamps on CLOCK_MONOTONIC (mcap's clock) the stub sink's rename (where `wpctl set-volume` returns on
the real path) and the log line (where `sound.sh` would exec `pw-play`) via inotify; mcap `-g 960,0,320,120 -k 2` gives
the pill and the HUD's first frame. "Pop out" = the player + 11 ms (`pw-play` to streaming, session 19, private
PipeWire: an estimate, not measured here).

| from the key, ms | before (3 runs) | after: pop 60 ms after the level (10 runs) | Mac |
|---|---|---|---|
| level set (stub) | 8.1-8.5 | 8.1-8.9 | - |
| player | 15.5-16.1 | 77.8-79.5 (one 110.1) | - |
| pill | 31.1-32.6 | 25.8-34.6 | - |
| HUD first frame | 114.6-115.9 | 114.0-117.9 (3 runs 127, 133, 148) | - |
| pill -> HUD first frame | 83.3-83.5 | 83.2-85.0 (3 runs 100-117) | 66.7 |
| pill -> pop out | about -5 | about 56-64 | 48.7 |
| pop out -> HUD first frame | about 88 | about 25-29 | 18.0 |

- Changed: `shell/scripts/volume-key.sh` `pop()` waits 60 ms before `sound.sh volume` (keys and the unmute pop). 60 sits
  between the two Mac relations (49 ms after the pill needs about 53, 18 ms before the HUD about 70).
- Stub artefact: the stub's file watch shows the pill 17-26 ms after the write (5 runs without any pop: 15-31). On the
  real path the HUD follows PipeWire's param event instead; that latency is not measured (no PipeWire here). Both the
  pop and the HUD start from the same level change, so only the difference between the two notifications moves the
  offset: if PipeWire is a frame faster, the pop lands about 10 ms before the HUD's first frame and 73 ms after the pill.
- HUD (not changed here, HUD owner): pill -> first frame is 83 ms against the Mac's 67, one frame longer, in 7 of 10
  runs and 4 of 5 without a pop (the outliers are the HUD's own, not the pop's). One clip on the Mac side.
- Not the pop's: the Mac shows the HUD on every key step, also at 0 and at full volume (section 2,
  `HUDActionDelegate.showVolume` before the gate); ours shows it only when the level or mute changes
  (`shell/services/Hud.qml` audioChanged), so at full volume a key pops without a HUD.
  **FIXED 2026-11-15 (after judge #22):** `volume-key.sh` rewrites `hud-step` in its folder for a step that leaves the
  level and mute as they were (up at 1, down at 0), and `services/Hud.qml` shows the HUD for it; a level change still
  shows through the sink, so its timing is unchanged. Headless (stub sink, mcap 960,0 320 x 120 pt, 4 runs each): up at
  full volume, pill 30-49 ms and HUD first frame 99-116 ms after the key (before: no HUD); a step at mid level, pill
  32-47 (one 97) and HUD 97-116 (one 180). Test: shell/tests "volume key step that leaves the level as it was".
- **Round J20** (judge #20, MOTION-AUDIT.md "HUD", "Round J20"): the HUD's first frames were held invisible (a content
  curve fitted about the wrong anchor), so "first frame" above was the HUD's fourth or fifth. With them drawn, the pop at
  60 ms came out 20 ms after the first frame. The Mac's pop starts with the HUD's appear spring (t0 from the content
  alpha 1.2285 + 3 ms, file sample 0 at 1.2320). Now `showDelay` 42 (one frame more) and the pop **44 ms** after the
  level: 12 runs, pill -> pop out mean 45.8 (Mac 48.7), pop out -> first frame mean 13.5 (Mac 18), pill -> first frame
  59.4 (Mac 66.7). The 60 ms row in the table above is superseded.

Still needs the Mac: the shutter (a screenshot that is taken while recording, e.g. `screencapture` from Terminal), Empty
Trash once the Trash holds only a dummy item, the Dock poof with a real drag, the key's own time (a hardware key press
on the same clock) to tie the pill to the key.


## 8. Round 10 (MAC-ANSWERS-10.md R10.2), 2026-11-15

- **Screenshot**: the sound is `system/Screen Capture.aif` (correlation 0.997), which is what hyprk plays (ID 1393), and
  no white flash. It starts 222 / 247 ms after the key on the Mac. Section 2 found no timer between the capture and the
  play call, so that time is the way from the key to the screencapture process, not a designed delay; hyprk plays it at
  the bind. Not changed (not measured on ours this round). The floating thumbnail (+482 / +647 ms) is not built.
- **Dock, Options > Remove from Dock**: the Mac plays `dock/poof item off dock.aif` within the frame of the first visual
  change and draws no cloud. Ours removed the item silently from the menu (the poof played only for a drag off the Dock):
  **fixed**, `shell/services/Apps.qml` plays `poof` with the removal. Not heard or timed here (audio stub).
- Empty Trash: not recorded on the Mac (its Trash held the user's items).

## 9. Round 11 (MAC-ANSWERS-11.md R11.4), 2026-11-15

Volume HUD on single key steps, measured per frame from `panels/hud-volume-steps-{light,dark}.mov` (MOTION-REA
"Round R11.4-R11.7"). Section 8's reading holds for the bar: one continuous fill on spring 0.2 / 0.85 on every step
(40 steps, rms .014 of a step), nothing else moving, no changed frame on a press at full or at 0 (the HUD only stays
up; it fades about 1.07 s after the last press). New: the wave count changes in one frame (3 at 11-16, 2 at 6-10, 1 at
1-5, the slash at 0), and the bounce at the ends plays layer by layer, 0.05 s apart, peak 1.25 and trough 0.90 (speaker
then waves at full; slash then speaker at 0). No sound data in this round.


## 10. After judge #23: output latency and the poof, measured (2026-11-15)

Headless session (scale 2, stub sink, `HYPRK_MUTE=1`, `HYPRK_SOUND_LOG`; nothing played, the real sink untouched). Two
live checks in `scripts/motion-capture/`:

- `player-latency.py SCRATCH`: a private PipeWire (own daemon and WirePlumber in a scratch runtime dir, one null sink,
  hardware monitors off, quantum 64). From the exec of `pw-play --volume 1 <file>` to the file's sample 0 in the sink's
  input: **median 12.0-12.1 ms** for volume.aiff (20 runs, 11.9-51.9), poof (12 runs) and Screen Capture.aif (12 runs);
  about 1 run in 5 takes 25-50 ms. The old estimate was 11. A real device's period and hardware delay come after this
  point and are the sink's, not hyprk's.
- `sound-timing.py [key|shot|poof]`: the sound log's append, the stub sink's rename and mcap's frames on one clock
  (CLOCK_MONOTONIC), "out" = the log + 12 ms.

| event | ours before | ours now | Mac | clip |
|---|---|---|---|---|
| pill -> pop out | not re-measured since #21 (51) | 42-59, mean **50.8-51.1** (2 x 10 runs) | 48.7 | volume-pop.mov |
| pop out -> first HUD frame | 21-38 (#21) | 15-45, mean **25.8-28.8** | 18.0 | volume-pop.mov |
| pill -> first HUD frame | 59-78 | 67-103, mean **76.6-79.9** | 66.7 | volume-pop.mov |
| key -> first HUD frame | 97-116 | 97-130, mean **103-107** | 112-127 filmed, about 90-105 less the 22-24 ms capture path | volume-key-hud-timing.mov (R10.3) |
| key -> HUD at 50 % / 90 % (mean pixel change against 0.6 s) | not measured | **263-298** (mean 269-274) / **413-447** (mean 419-424) | 277-293 / 440-445 filmed | the same |
| screenshot sound after the key | **27-64, mean 38** (played at the bind) | **226-255, mean 232-240** | 222 / 247 | screenshot-thumbnail.mov (R10.2 a) |
| Remove from Dock: poof against the removal's first frame | not measured | **+4..+6 ms** (the same frame) | +15 (the same frame) | dock-remove-menu-poof-sound.mov (R10.2 c) |
| Remove from Dock: the Dock closes the gap | **150 ms** (rms .143 against the clip) | **233 ms** to the last moving frame (slot 250 ms) | 250 ms, cosine ease in-out (rms .018) | the same |
| Remove from Dock: cloud | none | none (0 px) | none | the same |

- **Screenshot (fixed):** `config/hypr/hyprland.lua` `shutterDelay` 0.197 s before `sound.sh screenshot`; grim still
  starts at the bind. The Mac's 222 / 247 ms is the key's way to screencapture (section 8), copied as measured.
- **Remove from Dock (fixed):** read from the clip per frame (the Dock's right edge, 32 px of travel): the gap closes on
  the Dock's cosine ease in-out over 250 ms, starting 5 ms before the first changed frame. Ours shrank the slot in 150 ms
  (the quit-time shrink, MAC-ANSWERS.md:91). `shell/lib/dock.js slotDuration(entering, removed)`: 250 for the menu's
  removal (`Apps.menuRemoved`), 150 kept for an app that quits. Our menu blinks the chosen row first (off 4 frames, on
  3: 85 ms from the click); the clip chose the item through AX and shows no blink, so the click-to-removal time is not
  comparable. The menu's fade-out: ours 250 ms, the clip about 183 ms (not changed: one clip, the menu owner's).
- **Key path:** nothing changed. Every relation is within one 60 Hz frame of the Mac's; the pill's time in a stub session
  is the file watch's (section 7), so pill -> HUD carries that artefact.

Still needs the Mac: see "Still needs the Mac" in section 7 (Empty Trash, a real drag-off poof, a hardware key on the
recording clock), plus a clicked (not AX) Remove from Dock with the pointer visible, for the blink and the click time.

## 11. Round 16: Remove from Dock by a real click, drag-off by hand (2026-11-15)

`dock-remove-menu-real-click.mov` read per frame (pts) and per sample; frame 0 = the first frame with the row's
highlight off (4.533 s; mouse up logged at 4.48 +-20 ms):

| | Mac | ours before | ours now (`menu-blink.py dock`, `sound-timing.py poof`) |
|---|---|---|---|
| highlight off / on | 4 / 4 frames | 4 / 3-4 | 4 / 4 (14 runs) |
| first fading frame | 8th, the fade 1.6-1.7 frames in | 7th-8th, 1 frame in | 8th, 2 in |
| fade | CA default over 242 ms (rms .0056), last changing frame the 20th | CA default 236 | the same; plain menu rms .009 against the Mac's 13 frames, gone in the 20th |
| parent menu and submenu | fade in the same frame | parent 2 frames early | within 1 frame |
| Dock's first moving frame | the 22nd (367 ms after frame 0, about 420 after the up) | the 7th-8th (118 ms after the click) | the 22nd in 7 of 8, 23rd once (372 ms after the click) |
| poof | first sample 4.895-4.91, in the Dock's first moving frame (audible 4.926) | +3 ms | -13 ms (the same frame) |
| cloud | none | none | none |

- "Fade about 190 ms" (MAC-ANSWERS-16) is the visible part: the first fading frame is already 1.7 frames into a
  242 ms curve. So the fade was right; "250 against 183" (section 10) is closed.
- Changed: `MenuDropdown.qml` an item with `afterFade: true` runs `Theme.menu.afterFadePause` (16 ms) after the top
  menu's fade ends (`Apps.qml` Remove from Dock); the fade after a blink leads by 2 frames (`FrameAnim.lead`); a
  menu above the Dock blinks on for 4 frames (`Theme.menu.blinkOnDock`, `Overlay.qml`); the parent window draws
  frames during a submenu's blink (`keepPace`).
- AppKit's menus (desktop menu > New Folder): off 4, on 3, fade from the 7th, rms .032 against R3.5's curve (lead 2;
  with lead 1 the fade ran .75 frame behind).
- **Drag-off by hand** (`dock-drag-off-hand.mov`): the icon and "Remove" fade in place from 6.100 to 6.350 s, linear
  (.05 .11 .17 .23 .30 .38 .46 .54 .60 .67 .73 .79 .84 .89 .93 1), about 250 ms; sound from 6.131 s, 31 ms after the
  first fading frame and about 57 after the logged release; no cloud, no fly-back, the gap already closed. Ours
  (`Dock.qml dragDrop`): poof at the drop, linear 250 ms fade in place, slot closed during the drag: the same, not
  changed and not re-run live this round.

Open: a heavy item stalls the fade's start (desktop menu > Edit Widgets...: `trigger()` takes 40-49 ms, highlight on
for 4-6 frames); whether AppKit's menus also run the item after the fade is not filmed; the chosen row's own colour
bends towards the glass colour during the fade (its highlight fades over glass that is still there, rms .117 on that
row), where the Mac's goes straight.

## 12. After judge #25: the poof against the picture, by cross-correlation (2026-11-15)

Section 11's "first sample 4.895-4.91" was wrong: that is the AAC's pre-echo. `poof item off dock.aif` (48 kHz mono,
its first 0.25 s) cross-correlated with each clip's audio:

| clip | picture | file's first sample | r | ours before | ours now |
|---|---|---|---|---|---|
| `dock-remove-menu-real-click.mov` | Dock's first moving frame 4.900 s | 4.920 s, **+20 ms** (1 % of the peak 4.926) | .999 | -10..-13 | +19..+29 (`sound-timing.py poof`) |
| `dock-drag-off-hand.mov` | first fading frame 6.100 s, gone 6.350 s | 6.128 s, **+28 ms** | .999 | no fade at all; sound about -10 | +28..+31, fade 250 ms (`dock-drag-off.py`) |

`Apps.qml poofAfterMove` (30 ms after the removal runs, a frame before the Dock draws it), used by the menu's item
and by `Dock.qml dragDrop`. The drag-off's icon and "Remove" bubble had vanished in the drop's frame (the removed
tile's cell was destroyed under them): `Dock.dragInfo` keeps what they show; the fade is 260 ms (the Mac's 16
frames are a line of 15.6).
