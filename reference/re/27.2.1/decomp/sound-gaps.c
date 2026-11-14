// sound-gaps.c: excerpts for reference/re/27.2.1/SOUND-REA-27.2.1.md (macOS 27.2.1, 26B131, arm64e).
// Ghidra 12.1.4 headless pseudocode (thinned arm64e binaries from the system volume) and ipsw 'dyld disass'
// against dyld_shared_cache_arm64e (ControlCenter.framework, AudioToolbox, AppKit, HIToolbox, IOKit,
// MachineSettings, libsystem_featureflags) and llvm-objdump (IOHIDFamily kext from kernelcache.release.Mac14,2_3_7_15).
// Target strings and names are data from the binaries.

/* ===== 1. Sound.appex (System Settings > Sound), /System/Library/ExtensionKit/Extensions/Sound.appex ===== */
//==== 100007f28 AppleSound_SoundSettings::alertSoundVolume

/* Function Stack Size: 0x10 bytes */

float AppleSound_SoundSettings::alertSoundVolume(ID param_1,SEL param_2)

{
  int iVar1;
  float fVar2;
  double dVar3;
  undefined4 local_18;
  float local_14;
  
  local_14 = 0.0;
  local_18 = 4;
  iVar1 = _AudioServicesGetProperty(0x7373766c,0,0,&local_18,&local_14);
  fVar2 = 0.5;
  if ((iVar1 == 0) && (fVar2 = 0.0, local_14 != 0.0)) {
    dVar3 = (double)_log((double)local_14);
    fVar2 = (float)(dVar3 + 1.0);
  }
  return fVar2;
}


//==== 100007f98 AppleSound_SoundSettings::setAlertSoundVolume:

/* Function Stack Size: 0x14 bytes */

void AppleSound_SoundSettings::setAlertSoundVolume_(ID param_1,SEL param_2,float param_3)

{
  int iVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  ID self;
  double dVar4;
  float local_24;
  
  local_24 = param_3;
  if (param_3 != 0.0) {
    dVar4 = (double)_exp((double)param_3 + -1.0);
    local_24 = (float)dVar4;
  }
  uVar2 = _AudioServicesSetProperty(0x7373766c,0,0,4,&local_24);
  if ((int)uVar2 == 0) {
    self = NSDistributedNotificationCenter::defaultCenter
                     ((ID)PTR__OBJC_CLASS___NSDistributedNotificationCenter_10003e448);
    NSDistributedNotificationCenter::postNotificationName_object_userInfo_options_
              (self,PTR_cf_com_apple_sound_alertVolumeChanged_100043128,0,0,3);
  }
  else {
    uVar3 = _OSLogForCategory("General");
    iVar1 = _os_log_type_enabled(uVar3,0x10);
    if (iVar1 != 0) {
      FUN_10002948c(uVar2,uVar3);
    }
  }
  return;
}


//==== 100008c14 AppleSound_SoundSettings::beepAtSystemVolume:

/* Function Stack Size: 0x18 bytes */

void AppleSound_SoundSettings::beepAtSystemVolume_(ID param_1,SEL param_2,ID param_3)

{
  code *pcVar1;
  ID IVar2;
  ulong unaff_x30;
  
  if (*(long *)(param_1 + 0x18) == 0) {
    IVar2 = _objc_alloc(PTR__OBJC_CLASS___NSData_10003e538);
    IVar2 = NSData::initWithContentsOfFile_
                      (IVar2,&
                             cf__System_Library_LoginPlugins_BezelServices_loginPlugin_Contents_Resources_volume_aiff
                      );
    *(ID *)(param_1 + 0x18) = IVar2;
  }
  IVar2 = _objc_alloc(PTR__OBJC_CLASS___NSSound_10003e518);
  IVar2 = NSSound::initWithData_(IVar2,*(undefined8 *)(param_1 + 0x18));
  NSSound::setDelegate_(IVar2,param_1);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x100008c88);
    (*pcVar1)();
  }
  NSSound::play(IVar2);
  return;
}


//==== 100008c9c AppleSound_SoundSettings::beepAtAlertVolume:

/* Function Stack Size: 0x18 bytes */

void AppleSound_SoundSettings::beepAtAlertVolume_(ID param_1,SEL param_2,ID param_3)

{
  code *pcVar1;
  ulong unaff_x30;
  
  _AudioServicesStopSystemSound(0x1000,1);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x100008ccc);
    (*pcVar1)();
  }
  _AudioServicesPlaySystemSound(0x1000);
  return;
}


//==== 100008cd0 AppleSound_SoundSettings::cancelBeepAtSystemVolume

/* WARNING: Function: _objc_autorelease replaced with injection: _objc_retain_fixup */
/* Function Stack Size: 0x10 bytes */

void AppleSound_SoundSettings::cancelBeepAtSystemVolume(ID param_1,SEL param_2)

{
  *(undefined8 *)(param_1 + 0x18) = 0;
  return;
}


//==== 100008cfc AppleSound_SoundSettings::playBeepAtSystemVolume

/* Function Stack Size: 0x10 bytes */

void AppleSound_SoundSettings::playBeepAtSystemVolume(ID param_1,SEL param_2)

{
  undefined *puVar1;
  code *pcVar2;
  bool bVar3;
  ulong unaff_x30;
  
  bVar3 = playVolumeKeyFeedback(param_1);
  puVar1 = PTR_s_beepAtSystemVolume__1000421f0;
  if (bVar3 == 0) {
    return;
  }
  NSObject::cancelPreviousPerformRequestsWithTarget_selector_object_
            ((ID)PTR__OBJC_CLASS___NSObject_10003e498,param_1,PTR_s_beepAtSystemVolume__1000421f0,0)
  ;
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar2 = (code *)SoftwareBreakpoint(0xc471,0x100008d64);
    (*pcVar2)();
  }
  objc_stub::performSelector_withObject_afterDelay_(param_1,DAT_10002daa8,puVar1,0);
  return;
}


//==== 100008d74 AppleSound_SoundSettings::playBeepAtAlertVolume

/* Function Stack Size: 0x10 bytes */

void AppleSound_SoundSettings::playBeepAtAlertVolume(ID param_1,SEL param_2)

{
  undefined *puVar1;
  code *pcVar2;
  ulong unaff_x30;
  
  puVar1 = PTR_s_beepAtAlertVolume__1000421f8;
  NSObject::cancelPreviousPerformRequestsWithTarget_selector_object_
            ((ID)PTR__OBJC_CLASS___NSObject_10003e498,param_1,PTR_s_beepAtAlertVolume__1000421f8,0);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar2 = (code *)SoftwareBreakpoint(0xc471,0x100008dd4);
    (*pcVar2)();
  }
  objc_stub::performSelector_withObject_afterDelay_(param_1,DAT_10002daa8,puVar1,0);
  return;
}



/* const 0x10002daa8 (Sound.appex __const) = 3fb851eb851eb81e = 0.03 (the afterDelay: above) */

/* onEditingChanged closures handed to the sliders (FUN_100014d14 Output volume row, FUN_1000094d0 Alert volume row) */
//==== 10000d99c FUN_10000d99c

void FUN_10000d99c(ulong param_1)

{
  long unaff_x20;
  
  if ((param_1 & 1) == 0) {
    objc_stub::playBeepAtAlertVolume(*(ID *)(*(long *)(unaff_x20 + 0x18) + 0x20));
    return;
  }
  return;
}


//==== 100015d7c FUN_100015d7c

void FUN_100015d7c(ulong param_1)

{
  long unaff_x20;
  
  if ((param_1 & 1) == 0) {
    objc_stub::playBeepAtSystemVolume(*(ID *)(*(long *)(unaff_x20 + 0x18) + 0x20));
    return;
  }
  return;
}



/* value setters: FUN_10001d680 (Alert volume), FUN_10001f27c (Output volume) */
//==== 10001d680 FUN_10001d680

/* WARNING: Function: _objc_retain replaced with injection: _objc_retain_fixup */
/* WARNING: Function: _objc_release replaced with injection: _objc_release_fixup */

undefined8 FUN_10001d680(undefined8 param_1)

{
  code *pcVar1;
  ID self;
  ulong unaff_x30;
  float extraout_s0;
  
  if (DAT_100044778 != -1) {
    _swift_once(&DAT_100044778,FUN_10001c4e4);
  }
  self = *(ID *)(DAT_100045a78 + 0x20);
  objc_stub::alertSoundVolume(self);
  if (extraout_s0 != (float)param_1) {
    objc_stub::setAlertSoundVolume_(self,param_1);
  }
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x10001d6f4);
    (*pcVar1)();
  }
  return 0;
}


//==== 10001f27c FUN_10001f27c

/* WARNING: Function: _objc_retain replaced with injection: _objc_retain_fixup */
/* WARNING: Function: _objc_release replaced with injection: _objc_release_fixup */

undefined8 FUN_10001f27c(undefined8 param_1)

{
  code *pcVar1;
  ID self;
  ulong unaff_x30;
  float extraout_s0;
  
  if (DAT_100044778 != -1) {
    _swift_once(&DAT_100044778,FUN_10001c4e4);
  }
  self = *(ID *)(DAT_100045a78 + 0x20);
  objc_stub::mainVolume(self);
  if (extraout_s0 != (float)param_1) {
    objc_stub::setMainVolume_(self,param_1);
  }
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x10001f2f0);
    (*pcVar1)();
  }
  return 0;
}



/* ===== 2. AudioToolbox (dyld cache): SaveSystemSoundPref, 'ssvl' (kAudioServicesPropertySystemSoundVolume) branch =====
   SaveSystemSoundPref(unsigned, unsigned, const void*) at 0x1adcf43e8, called from AudioServicesSetProperty 0x1adcf1a88.
   CFString 0x1e58a3c70 -> 0x1adea2724 "com.apple.sound.beep.volume" (length 0x1b); value stored unchanged as Float32
   0x1adcf478c:  60 02 40 bd   ldr	s0, [x19]
   0x1adcf4790:  e0 23 00 bd   str	s0, [sp, #0x20]
   0x1adcf4794:  e2 83 00 91   add	x2, sp, #0x20
   0x1adcf4798:  00 00 80 d2   mov	x0, #0
   0x1adcf479c:  a1 00 80 52   mov	w1, #0x5
   0x1adcf47a0:  40 cd 92 94   bl	j__CFNumberCreate
   0x1adcf47a4:  e1 03 00 aa   mov	x1, x0
   0x1adcf47a8:  33 00 80 52   mov	w19, #0x1
   0x1adcf47ac:  e0 03 00 f9   str	x0, [sp]
   0x1adcf47b0:  f3 23 00 39   strb	w19, [sp, #0x8]
   0x1adcf47b4:  60 dd 1b f0   adrp	x0, 0x1e58a3000
   0x1adcf47b8:  00 c0 31 91   add	x0, x0, #0xc70 ; _ptr.__NSCFConstantString
   0x1adcf47bc:  78 00 00 94   bl	CACFPreferences::SetValue(__CFString const*, void const*, bool, bool, bool)
   0x1adcf47c0:  48 20 20 d0   adrp	x8, 0x1ee0fe000
   0x1adcf47c4:  08 21 3c 91   add	x8, x8, #0xf08 ; _gClientPrefsHaveChanged.0
   0x1adcf47c8:  13 fd 9f 08   stlrb	w19, [x8]
   0x1adcf47cc:  60 0d 00 d0   adrp	x0, 0x1adea2000
   0x1adcf47d0:  00 64 25 91   add	x0, x0, #0x959 ; "com.apple.coreaudio.SystemSoundVolumeChanged"
   0x1adcf47d4:  8f 00 00 94   bl	SendPropertyChangeNotification(char const*)
   
*/

/* ===== 3. systemsoundserverd: volume -> AUStereoMixer input-bus volume =====
   0x10000b6cc fmul s9, s10, s9 (user vol x client vol scalar); 0x10000b6f4 fmul s8, s9, s8 (x CM vol)
   FUN_10000a044 -> FUN_100005e78(vol...) -> vtable+0x38 (slot 0x10001c220 -> FUN_100006814, PAC diversity 0x1246):
   100005ef8:     	ldr	x16, [x19]
   100005efc:     	autda	x16, x22
   100005f00:     	ldr	x8, [x16, #0x38]!
   100005f04:     	mov	x0, x19
   100005f08:     	mov.16b	v0, v10
   100005f0c:     	mov.16b	v1, v9
   100005f10:     	mov.16b	v2, v8
   100005f14:     	mov	x1, x21
   100005f18:     	mov	x2, x20
   100005f1c:     	movk	x16, #0x1246, lsl #48
   100005f20:     	blraa	x8, x16
   FUN_100006814 entry: 0x10000683c mov v8, v0 (the volume); then:
   100006dd4:     	ldr	x8, [x19, #0x60]
   100006dd8:     	ldr	x0, [x8, #0x68]
   100006ddc:     	ldr	w3, [x19, #0x78]
   100006de0:     	mov	w1, #0x0                ; =0
   100006de4:     	mov	w2, #0x1                ; =1
   100006de8:     	mov.16b	v0, v8
   100006dec:     	mov	w4, #0x0                ; =0
   100006df0:     	bl	0x100014180 <_xpc_uint64_get_value+0x100014180>
   AudioUnitSetParameter(mixerAU, paramID 0, scope 1 (input), bus [x19+0x78], v8, 0)
   Mixer: AudioComponentDescription at 0x100014cc0 = 'aumx' 'smxr' 'appl' (Stereo Mixer), output 0x100014c68 = 'auou' 'ahal' */

/* ===== 4. BezelServices.loginPlugin: -[BezelServicesTask handleCGSEvent:] 0x309c (head) ===== */
//==== 0000309c BezelServicesTask::handleCGSEvent:

/* WARNING: Function: _objc_claimAutoreleasedReturnValue replaced with injection: _objc_retain_fixup
    */
/* WARNING: Function: _objc_release replaced with injection: _objc_release_fixup */
/* WARNING: Function: _objc_retain replaced with injection: _objc_retain_fixup */
/* Function Stack Size: 0x18 bytes */

void BezelServicesTask::handleCGSEvent_(ID param_1,SEL param_2,__CGEvent *param_3)

{
  undefined8 uVar1;
  code *pcVar2;
  int iVar3;
  int iVar4;
  ulong uVar5;
  long lVar6;
  ulong uVar7;
  ulong uVar8;
  ulong uVar9;
  ID IVar10;
  class_t *pcVar11;
  dispatch_time_t dVar12;
  undefined4 uVar13;
  int iVar14;
  ulong unaff_x30;
  undefined4 local_80;
  int local_7c;
  undefined2 local_78;
  undefined4 local_76;
  undefined2 local_72;
  undefined4 local_70;
  undefined2 local_6c;
  undefined4 local_6a;
  undefined2 local_66;
  undefined4 local_64;
  undefined2 local_60;
  undefined4 local_5e;
  
  iVar3 = _CGEventGetType(param_3);
  if (iVar3 != 0xe) {
    return;
  }
  uVar5 = __os_feature_enabled_impl("ControlCenter","Bezel");
  if ((uVar5 & 1) != 0) {
    return;
  }
  lVar6 = _CGEventGetIntegerValueField(param_3,0x53);
  uVar13 = 100;
  if (lVar6 != 9 && lVar6 != 6) {
    uVar13 = 0x95;
  }
  iVar4 = _CGEventGetIntegerValueField(param_3,uVar13);
  uVar5 = _CGEventGetFlags(param_3);
  uVar5 = uVar5 & 0x20000;
  uVar7 = _CGEventGetFlags(param_3);
  uVar7 = uVar7 & 0x40000;
  uVar8 = _CGEventGetFlags(param_3);
  uVar8 = uVar8 & 0x80000;
  uVar9 = _CGEventGetFlags(param_3);
/* ... (rest: key dispatch to Display/Keyboard/VolumeStateMachine, never reached while the flag is on) */

/* ===== 5. libsystem_featureflags (dyld cache) _os_feature_enabled_SLOWPATH: DevelopmentPhase =====
   0x18555d864:  f8 00 00 b4   cbz	x24, loc_18555d880 ; ⤵ 0x1c
   0x18555d868:  e0 03 18 aa   mov	x0, x24
   0x18555d86c:  29 3f ac 94   bl	j__xpc_get_type
   0x18555d870:  68 63 2d f0   adrp	x8, 0x1e01cc000
   0x18555d874:  08 4d 47 f9   ldr	x8, [x8, #0xe98] ; _ptr.OS_xpc_bool
   0x18555d878:  1f 00 08 eb   cmp	x0, x8
   0x18555d87c:  00 02 00 54   b.eq	loc_18555d8bc ; ⤵ 0x40
   0x18555d880:  ; loc_18555d880
   0x18555d880:  5a 02 00 b4   cbz	x26, loc_18555d8c8 ; ⤵ 0x48
   0x18555d884:  e0 03 1a aa   mov	x0, x26
   0x18555d888:  22 3f ac 94   bl	j__xpc_get_type
   0x18555d88c:  68 63 2d f0   adrp	x8, 0x1e01cc000
   0x18555d890:  08 a9 47 f9   ldr	x8, [x8, #0xf50] ; _ptr.OS_xpc_string
   0x18555d894:  1f 00 08 eb   cmp	x0, x8
   0x18555d898:  81 01 00 54   b.ne	loc_18555d8c8 ; ⤵ 0x30
   0x18555d89c:  e0 03 1a aa   mov	x0, x26
   0x18555d8a0:  28 3f ac 94   bl	j__xpc_string_get_string_ptr
   0x18555d8a4:  01 00 00 b0   adrp	x1, 0x18555e000
   0x18555d8a8:  21 84 2e 91   add	x1, x1, #0xba1 ; "FeatureComplete"
   0x18555d8ac:  b9 3c ac 94   bl	__stub_18555b4b8
   0x18555d8b0:  1f 00 00 71   cmp	w0, #0
   0x18555d8b4:  f6 17 9f 1a   cset	w22, eq
   0x18555d8b8:  04 00 00 14   b	loc_18555d8c8 ; ⤵ 0x10
   0x18555d8bc:  ; loc_18555d8bc
   0x18555d8bc:  e0 03 18 aa   mov	x0, x24
   0x18555d8c0:  98 aa ac 94   bl	j__xpc_bool_get_value
   0x18555d8c4:  f6 03 00 aa   mov	x22, x0
   0x18555d8c8:  ; loc_18555d8c8
   0x18555d8c8:  e0 03 1a aa   mov	x0, x26
   0x18555d8cc:  81 44 ac 94   bl	j__objc_release_x0
   
   /System/Library/FeatureFlags/Domain/ControlCenter.plist: {'AVLiveActivity': {'DevelopmentPhase': 'FeatureComplete'},
                                                           'Bezel': {'DevelopmentPhase': 'FeatureComplete'}} */

/* ===== 6. ControlCenter.framework (dyld cache): volume keys on 27.2.1 =====
   HotKeys.registerBezelHotKeys(with:) 0x20a57cc34: keyDown observer -> 0x20a57cef4, keyUp observer -> 0x20a57d690.
   keyDown handler 0x20a57cef4 (excerpt): perform once, then a repeating NSTimer from NXKeyRepeatPrefs
   0x20a57d470:     ldur x8, [fp, #-0x98]
   0x20a57d474:     stur x8, [fp, #-0x68]
   0x20a57d478:     sub x0, fp, #0x70
   0x20a57d47c:     bl 0x20a595548
   0x20a57d480:     and x8, x0, #0xff00
   0x20a57d484:     cmp x8, #0x200
   0x20a57d488:     b.ne loc_20a57d498 ; ⤵ 0x10
   0x20a57d48c:     mov x0, x23
   0x20a57d490:     bl j__swift_unknownObjectRelease
   0x20a57d494:     b loc_20a57d414 ; ⤴ -0x80
   0x20a57d498:    
   0x20a57d498:     mov x25, x0
   0x20a57d49c:     mov x22, x1
   0x20a57d4a0:     fmov d0, x22
   0x20a57d4a4:     and w2, w25, #0xff
   0x20a57d4a8:     lsr w8, w25, #0x8
   0x20a57d4ac:     ubfx w9, w25, #0x8, #0x1
   0x20a57d4b0:     stur w9, [fp, #-0x80]
   0x20a57d4b4:     bfi w2, w8, #0x8, #0x1
   0x20a57d4b8:     lsr w8, w25, #0x10
   0x20a57d4bc:     ubfx w24, w25, #0x10, #0x1
   0x20a57d4c0:     bfi w2, w8, #0x10, #0x1
   0x20a57d4c4:     mov x0, x23
   0x20a57d4c8:     mov x1, x20
   0x20a57d4cc:     bl 0x20a59567c
   0x20a57d4d0:     bl _NXKeyRepeatPrefs
   0x20a57d4d4:     mov v8.16b, v1.16b
   0x20a57d4d8:     mov x8, x26
   0x20a57d4dc:     bl j__$s10Foundation4DateV20timeIntervalSinceNowACSd_tcfC
   0x20a57d4e0:     ldur x8, [fp, #-0x88]
   0x20a57d4e4:     ldr x0, [x8, #0x58]
   0x20a57d4e8:     cbz x0, loc_20a57d4f0 ; ⤵ 0x8
   0x20a57d4ec:     bl 0x210002710
   0x20a57d4f0:    
   0x20a57d4f0:     ldp x21, x28, [fp, #-0xb8]
   0x20a57d4f4:     mov x8, x28
   0x20a57d4f8:     ldr x9, [x8, #0x10]!
   0x20a57d4fc:     mov x0, x21
   0x20a57d500:     mov x1, x26
   0x20a57d504:     mov x27, x26
   0x20a57d508:     ldur x26, [fp, #-0xa8]
   0x20a57d50c:     mov x2, x26
   0x20a57d510:     mov x17, x8
   0x20a57d518:     blraa x9, x17
   0x20a57d51c:     adrp x0, 0x26a2f7000
   0x20a57d520:     add x0, x0, #0x310
   0x20a57d524:     mov w1, #0x30
   0x20a57d528:     mov w2, #0x7
   0x20a57d52c:     bl j__swift_allocObject
   0x20a57d530:     mov x19, x0
   0x20a57d534:     adrp x8, 0x2680cf000
   0x20a57d538:     ldr x0, [x8, #0x2c0] ; _ptr.NSTimer
   0x20a57d53c:     strb w25, [x19, #0x10]
   0x20a57d540:     ldur w8, [fp, #-0x80]
   0x20a57d544:     strb w8, [x19, #0x11]
   0x20a57d548:     strb w24, [x19, #0x12]
   0x20a57d54c:     stp x22, x23, [x19, #0x18]
   0x20a57d550:     str x20, [x19, #0x28]
   0x20a57d554:     bl j__objc_allocWith_Zone
   0x20a57d558:     mov x20, x0
   0x20a57d55c:     mov x0, x23
   0x20a57d560:     bl j__swift_unknownObjectRetain
   0x20a57d564:     adrp x16, 0x20a583000
   0x20a57d568:     add x16, x16, #0x3b0
   0x20a57d56c:     mov x17, #0x8438
   0x20a57d570:     pacia x16, x17
   0x20a57d574:     mov x2, x16
   0x20a57d578:     mov x0, x21
   0x20a57d57c:     mov v0.16b, v8.16b
   0x20a57d580:     mov w1, #0x1
   0x20a57d584:     mov x3, x19
   0x20a57d588:     bl 0x20a57f290
   0x20a57d58c:     mov x19, x0
   0x20a57d590:     adrp x8, 0x2680cf000
   0x20a57d594:     ldr x0, [x8, #0x298] ; _ptr.NSRunLoop
   0x20a57d598:     bl j__objc_opt_self
   0x20a57d59c:     bl 0x21003f7b0
   0x20a57d5a0:     mov fp, fp
   0x20a57d5a4:     bl j__objc_retainAutoreleasedReturnValue
   0x20a57d5a8:     mov x20, x0
   0x20a57d5ac:     adrp x8, 0x2680ce000
   0x20a57d5b0:     ldr x8, [x8, #0xcf8] ; _ptr._kCFRunLoopDefaultMode
   0x20a57d5b4:     ldr x3, [x8]
   0x20a57d5b8:     mov x2, x19
   0x20a57d5bc:     bl 0x210005e10
   0x20a57d5c0:     mov x0, x20
   0x20a57d5c8:     mov x0, x23
   0x20a57d5cc:     bl j__swift_unknownObjectRelease
   0x20a57d5d0:     ldr x8, [x28, #0x8]!
   0x20a57d5d4:     mov x0, x27
   0x20a57d5d8:     mov x1, x26
   0x20a57d5dc:     mov x17, x28
   0x20a57d5e4:     blraa x8, x17
   0x20a57d5e8:     ldur x8, [fp, #-0x88]
   0x20a57d5ec:     ldr x0, [x8, #0x58]
   0x20a57d5f0:     str x19, [x8, #0x58]
   0x20a57d5f8:     b loc_20a57d414 ; ⤴ -0x1e4
   0x20a57d5fc:     pacibsp
   _NXKeyRepeatPrefs 0x20a583328: d0 = NXKeyRepeatThreshold, d1 = NXKeyRepeatInterval
   timer block 0x20a5833b0 -> b 0x20a57e428 -> bl 0x20a59567c (perform) at 0x20a57e5f0
   keyUp handler 0x20a57d690: 0x20a57d984 bl invalidate (stub 0x210002710), 0x20a57d98c str xzr,[x26,#0x58]; no perform call

   key -> action and step (sub_20a595548): step 0x3fb0000000000000 = 1/16, 0x3f90000000000000 = 1/64;
   bit 0x10000 set only when (flags & 0x1e0000) == 0x20000 (Shift alone):
   0x20a59565c:  9f 81 40 f1   cmp	x12, #0x20, lsl #0xc
   0x20a595660:  61 00 00 54   b.ne	loc_20a59566c ; ⤵ 0xc
   0x20a595664:  21 00 a0 52   mov	w1, #0x10000
   0x20a595668:  02 00 00 14   b	loc_20a595670 ; ⤵ 0x8
   0x20a59566c:  ; loc_20a59566c
   0x20a59566c:  01 00 80 d2   mov	x1, #0
   0x20a595670:  ; loc_20a595670
   0x20a595670:  20 00 09 aa   orr	x0, x1, x9
   0x20a595674:  e1 03 08 aa   mov	x1, x8
   0x20a595678:  c0 03 5f d6   ret
   

   step on the 1/64 grid (0x20a595d28):
   0x20a595d20:     brk #0xc471
   0x20a595d24:    
   0x20a595d24:     b j__objc_release_x0
   0x20a595d28:     fmov d3, #1.00000000
   0x20a595d2c:     fdiv d2, d3, d0
   0x20a595d30:     mov x8, #0x3f80000000000000
   0x20a595d34:     fmov d4, x8
   0x20a595d38:     fadd d1, d1, d4
   0x20a595d3c:     mov x8, #0x4050000000000000
   0x20a595d40:     fmov d4, x8
   0x20a595d44:     fmul d1, d1, d4
   0x20a595d48:     frintm d1, d1
   0x20a595d4c:     mov x8, #0x3f90000000000000
   0x20a595d50:     fmov d4, x8
   0x20a595d54:     fmul d1, d1, d4
   0x20a595d58:     fcmp d0, #0.00000000
   0x20a595d5c:     b.le loc_20a595d78 ; ⤵ 0x1c
   0x20a595d60:     fcmp d1, d3
   0x20a595d64:     b.pl loc_20a595d94 ; ⤵ 0x30
   0x20a595d68:     fadd d0, d0, d1
   0x20a595d6c:     fmul d0, d2, d0
   0x20a595d70:     frintm d0, d0
   0x20a595d74:     b loc_20a595d90 ; ⤵ 0x1c
   0x20a595d78:    
   0x20a595d78:     movi v3.2d, #0
   0x20a595d7c:     fcmp d1, #0.00000000
   0x20a595d80:     b.le loc_20a595d94 ; ⤵ 0x14
   0x20a595d84:     fadd d0, d0, d1
   0x20a595d88:     fmul d0, d2, d0
   0x20a595d8c:     frintp d0, d0
   0x20a595d90:    
   0x20a595d90:     fdiv d3, d0, d2
   0x20a595d94:    
   0x20a595d94:     fmov d0, #1.00000000
   0x20a595d98:     fminnm d0, d3, d0
   0x20a595d9c:     fcmp d0, #0.00000000
   0x20a595da0:     movi v1.2d, #0
   0x20a595da4:     fcsel d0, d0, d1, ge
   0x20a595da8:     ret
   0x20a595dac:     pacibsp

   volume step 0x20a595dac (excerpt): mainVolume, canSetVolume, step, setMute:, setMainVolume:, showVolume, feedback
   0x20a595e90:     adrp x8, 0x275d84000
   0x20a595e94:     add x0, x8, #0xab8 ; AppleSoundSettings
   0x20a595e98:     bl j__objc_opt_self
   0x20a595e9c:     bl 0x2100698c0
   0x20a595ea0:     mov fp, fp
   0x20a595ea4:     bl j__objc_retainAutoreleasedReturnValue
   0x20a595ea8:     cbz x0, loc_20a596270 ; ⤵ 0x3c8
   0x20a595eac:     mov x22, x0
   0x20a595eb0:     bl 0x2100696a0
   0x20a595eb4:     fcvt d8, s0
   0x20a595eb8:     mov x0, x22
   0x20a595ebc:     bl 0x2100693d0
   0x20a595ec0:     cbz w0, loc_20a595ff4 ; ⤵ 0x134
   0x20a595ec4:     mov v0.16b, v9.16b
   0x20a595ec8:     mov v1.16b, v8.16b
   0x20a595ecc:     bl 0x20a595d28
   0x20a595ed0:     mov v10.16b, v0.16b
   0x20a595ed4:     mov x0, x22
   0x20a595ed8:     bl 0x2100695e0
   0x20a595edc:     cbz w0, loc_20a595f08 ; ⤵ 0x2c
   0x20a595ee0:     fcmp d10, #0.00000000
   0x20a595ee4:     cset w27, eq
   0x20a595ee8:     mov x0, x22
   0x20a595eec:     bl 0x210069670
   0x20a595ef0:     cmp w27, w0
   0x20a595ef4:     b.eq loc_20a595f08 ; ⤵ 0x14
   0x20a595ef8:     fcmp d10, #0.00000000
   0x20a595efc:     cset w2, eq
   0x20a595f00:     mov x0, x22
   0x20a595f04:     bl 0x210069840
   0x20a595f08:    
   0x20a595f08:     fcvt s0, d10
   0x20a595f0c:     mov x0, x22
   0x20a595f10:     bl 0x210069820
   0x20a595f14:     mov x0, x22
   0x20a595f18:     bl 0x2100696a0
   0x20a595f1c:     fcvt d9, s0
   0x20a595f20:     adrp x8, 0x2712ce000
   0x20a595f24:     ldr x8, [x8, #0x2a0] ; data_2712ce2a0 (ControlCenter/__DATA.__data)
   0x20a595f28:     fcmp d10, d9
   0x20a595f2c:     b.ne loc_20a596114 ; ⤵ 0x1e8
   0x20a596254:     blraa x9, x17
   0x20a596258:    
   0x20a596258:     and w1, w25, #0x1
   0x20a59625c:     mov w0, #0
   0x20a596260:     mov x20, x22
   0x20a596264:     bl 0x20a596298

   mute toggle 0x20a595bf0 (excerpt): isMuted -> x23, hasMute, setMute:(!x23), feedback only when it was muted
   0x20a595c20:     bl j__objc_opt_self
   0x20a595c24:     bl 0x2100698c0
   0x20a595c28:     mov fp, fp
   0x20a595c2c:     bl j__objc_retainAutoreleasedReturnValue
   0x20a595c30:     cbz x0, loc_20a595c94 ; ⤵ 0x64
   0x20a595c34:     mov x22, x0
   0x20a595c38:     bl 0x210069670
   0x20a595c3c:     mov x23, x0
   0x20a595c40:     mov x0, x22
   0x20a595c44:     bl 0x2100695e0
   0x20a595c48:     cbz w0, loc_20a595cac ; ⤵ 0x64
   0x20a595c4c:     eor w2, w23, #0x1
   0x20a595c50:     mov x0, x22
   0x20a595c54:     bl 0x210069840
   0x20a595c58:     cbz x20, loc_20a595ce8 ; ⤵ 0x90
   0x20a595c5c:     movi v8.2d, #0
   0x20a595ce4:     blraa x9, x17
   0x20a595ce8:    
   0x20a595ce8:     cbz w23, loc_20a595cfc ; ⤵ 0x14
   0x20a595cec:     and w1, w19, #0x1
   0x20a595cf0:     mov w0, #0x1
   0x20a595cf4:     mov x20, x22
   0x20a595cf8:     bl 0x20a596298
   0x20a595cfc:    
   0x20a595cfc:     mov x0, x22

   feedback gate 0x20a596298: canSetVolume && playVolumeKeyFeedback != shift -> AudioVolumeFeedbackController.play
   0x20a596298:     pacibsp
   0x20a59629c:     stp x20, x19, [sp, #-0x20]!
   0x20a5962a0:     stp fp, lr, [sp, #0x10]
   0x20a5962a4:     add fp, sp, #0x10
   0x20a5962a8:     mov x19, x1
   0x20a5962ac:     mov x0, x20
   0x20a5962b0:     bl 0x2100693d0
   0x20a5962b4:     cbz w0, loc_20a596304 ; ⤵ 0x50
   0x20a5962b8:     mov x0, x20
   0x20a5962bc:     bl 0x2100696f0
   0x20a5962c0:     and w8, w19, #0x1
   0x20a5962c4:     cmp w8, w0
   0x20a5962c8:     b.eq loc_20a596304 ; ⤵ 0x3c
   0x20a5962cc:     adrp x8, 0x2712ce000
   0x20a5962d0:     ldr x8, [x8, #0x550] ; data_2712ce550 (ControlCenter/__DATA.__data)
   0x20a5962d4:     cmn x8, #0x1
   0x20a5962d8:     b.eq loc_20a5962f8 ; ⤵ 0x20
   0x20a5962dc:     adrp x0, 0x2712ce000
   0x20a5962e0:     add x0, x0, #0x550 ; data_2712ce550 (ControlCenter/__DATA.__data)
   0x20a5962e4:     adrp x16, 0x20a531000
   0x20a5962e8:     add x16, x16, #0xc54
   0x20a5962ec:     paciza x16
   0x20a5962f0:     mov x1, x16
   0x20a5962f4:     bl j__swift_once
   0x20a5962f8:    
   0x20a5962f8:     adrp x8, 0x2712ce000
   0x20a5962fc:     ldr x20, [x8, #0x558] ; data_2712ce558 (ControlCenter/__DATA.__data)
   0x20a596300:     bl 0x20a531f40
   0x20a596304:    
   0x20a596304:     ldp fp, lr, [sp, #0x10]

   AudioVolumeFeedbackController.playVolumeFeedbackSound 0x20a531f40 (excerpt): the 'throttle'
   0x20a5320c0:     mov x8, x24
   0x20a5320c4:     bl j__$s10Foundation4DateV3nowACvgZ
   0x20a5320c8:     adrp x8, 0x2712ce000
   0x20a5320cc:     ldr x8, [x8, #0x560] ; data_2712ce560 (ControlCenter/__DATA.__data)
   0x20a5320d0:     add x23, x20, x8
   0x20a5320d4:     sub x1, fp, #0x70
   0x20a5320d8:     mov x0, x23
   0x20a5320dc:     mov x2, #0
   0x20a5320e0:     mov x3, #0
   0x20a5320e4:     bl j__swift_beginAccess
   0x20a5320e8:     mov x8, x22
   0x20a5320ec:     ldr x9, [x8, #0x10]!
   0x20a5320f0:     mov x0, x27
   0x20a5320f4:     stur x23, [fp, #-0xd0]
   0x20a5320f8:     mov x1, x23
   0x20a5320fc:     mov x2, x21
   0x20a532100:     mov x17, x8
   0x20a532108:     blraa x9, x17
   0x20a53210c:     mov x0, x27
   0x20a532110:     mov x1, x24
   0x20a532114:     bl j__$s10Foundation4DateV1loiySbAC_ACtFZ
   0x20a532118:     mov x26, x0
   0x20a53211c:     mov x8, x22
   0x20a532120:     ldr x9, [x8, #0x8]!
   0x20a532124:     mov x23, x8
   0x20a532128:     movk x23, #0x4f8, lsl #0x30
   0x20a53212c:     mov x0, x27
   0x20a532130:     mov x1, x21
   0x20a532134:     stur x9, [fp, #-0xb0]
   0x20a532138:     mov x17, x8
   0x20a532140:     blraa x9, x17
   0x20a532144:     tbz w26, #0, loc_20a532334 ; ⤵ 0x1f0
   0x20a532148:     ldr x8, [x20, #0x10]
   0x20a53214c:     stur x8, [fp, #-0xd8]
   0x20a532280:     mov x3, x28
   0x20a532284:     ldur x20, [fp, #-0xd8]
   0x20a532288:     bl j__$sSo17OS_dispatch_queueC8DispatchE5async5group3qos5flags7executeySo0a1_b1_F0CSg_AC0D3QoSVAC0D13WorkItemFlagsVyyXBtF
   0x20a53228c:     mov x0, x28
   0x20a5322c4:     blraa x8, x17
   0x20a5322c8:     ldur x0, [fp, #-0x78]
   0x20a5322d0:     movi v0.2d, #0
   0x20a5322d4:     mov x8, x27
   0x20a5322d8:     mov x20, x24
   0x20a5322dc:     bl j__$s10Foundation4DateV8advanced2byACSd_tF
   0x20a5322e0:     mov x0, x24
   0x20a5322e4:     mov x1, x21
   0x20a5322e8:     ldur x8, [fp, #-0xb0]
   0x20a5322ec:     blraa x8, x23
   0x20a5322f0:     sub x1, fp, #0xa0
   0x20a5322f4:     ldur x19, [fp, #-0xd0]
   0x20a5322f8:     mov x0, x19
   0x20a5322fc:     mov w2, #0x21
   0x20a532300:     mov x3, #0
   0x20a532304:     bl j__swift_beginAccess
   0x20a532308:     ldur x9, [fp, #-0xe0]
   0x20a53230c:     ldr x8, [x9, #0x28]!
   0x20a532324:     blraa x8, x17
   0x20a532328:     sub x0, fp, #0xa0
   0x20a53232c:     bl j__swift_endAccess
   0x20a532330:     b loc_20a532344 ; ⤵ 0x14
   0x20a532334:    
   0x20a532334:     mov x0, x24
   0x20a532338:     mov x1, x21
   0x20a53233c:     ldur x8, [fp, #-0xb0]
   queued body 0x20a531cec: new AVAudioPlayer(contentsOf: .../BezelServices.loginPlugin/Contents/Resources/volume.aiff),
   old player -> stop (stub 0x210004220), new player stored at ivar data_2712ce568 -> play (stub 0x210003180) */

/* ===== 7. screencapture /usr/sbin/screencapture: shutter (ID 0x571 = 1393) ===== */
//==== 10000cc88 FUN_10000cc88 (asked 0x10000cc88)

void FUN_10000cc88(ulong param_1,undefined8 param_2,undefined8 param_3)

{
  undefined8 uVar1;
  int iVar2;
  undefined8 uVar3;
  undefined2 *puVar4;
  undefined4 *puVar5;
  undefined4 local_b0;
  undefined4 local_ac;
  undefined2 local_a8 [16];
  undefined4 local_88 [6];
  undefined2 auStack_70 [16];
  undefined4 auStack_50 [6];
  long local_38;
  
  local_38 = *(long *)PTR____stack_chk_guard_1000b4d70;
  if ((DAT_1000bb894 & 1) == 0) {
    local_b0 = 1;
    local_ac = 0x571;
    _AudioServicesSetProperty(0x69666469,4,&local_ac,4,&local_b0);
    _AudioServicesPlaySystemSound(local_ac);
  }
  if ((param_1 & 1) == 0) {
    uVar3 = __s10Foundation3URLVMa(0);
    iVar2 = FUN_100003968(param_3,1,uVar3);
    if (iVar2 == 1) goto LAB_10000cdac;
    puVar5 = auStack_50;
/* (rest of FUN_10000cc88 writes the file after the play call) */
//==== 100050364 FUN_100050364 (asked 0x100050364)

void FUN_100050364(void)

{
  undefined1 in_ZR;
  undefined8 extraout_x8;
  undefined4 local_20;
  undefined4 local_1c;
  undefined8 local_18;
  
  FUN_100009e98();
  local_20 = 1;
  local_1c = 0x571;
  local_18 = extraout_x8;
  _AudioServicesSetProperty(0x69666469,4,&local_1c,4,&local_20);
  _AudioServicesPlaySystemSound(local_1c);
  FUN_100009e84(local_18);
  if ((bool)in_ZR) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  ___stack_chk_fail();
}


/* callers: FUN_100055788 / FUN_100057af0: CFAbsoluteTimeGetCurrent(); if (!flag0x1ec && !flag0x1ed) FUN_100050364();
   the only usleep (10000 us) is in FUN_100035d30 (entry), a loop waiting for com.apple.screencapture.interactive */

/* ===== 8. Double-click interval =====
   AppKit +[NSEvent doubleClickInterval] 0x18a4ea648: GetDblTime() / 60.0
   
   +[NSEvent doubleClickInterval]
   0x18a4ea648:  7f 23 03 d5   pacibsp
   0x18a4ea64c:  fd 7b bf a9   stp	fp, lr, [sp, #-0x10]!
   0x18a4ea650:  fd 03 00 91   mov	fp, sp
   0x18a4ea654:  6f 76 70 95   bl	j__GetDblTime
   0x18a4ea658:  00 00 63 1e   ucvtf	d0, w0
   0x18a4ea65c:  c8 09 e8 d2   mov	x8, #0x404e000000000000
   0x18a4ea660:  01 01 67 9e   fmov	d1, x8
   0x18a4ea664:  00 18 61 1e   fdiv	d0, d0, d1
   0x18a4ea668:  fd 7b c1 a8   ldp	fp, lr, [sp], #0x10
   0x18a4ea66c:  ff 0f 5f d6   retab
   
   HIToolbox GetDblTime 0x18ef06ed4: GetDoubleClickParameters(&secs) ; (UInt32)(secs * 60 + 0.5)
   
   _GetDblTime
   0x18ef06ed4:  7f 23 03 d5   pacibsp
   0x18ef06ed8:  ff 83 00 d1   sub	sp, sp, #0x20
   0x18ef06edc:  fd 7b 01 a9   stp	fp, lr, [sp, #0x10]
   0x18ef06ee0:  fd 43 00 91   add	fp, sp, #0x10
   0x18ef06ee4:  ff 07 00 f9   str	xzr, [sp, #0x8]
   0x18ef06ee8:  e0 23 00 91   add	x0, sp, #0x8
   0x18ef06eec:  01 00 80 d2   mov	x1, #0
   0x18ef06ef0:  32 01 00 94   bl	_GetDoubleClickParameters
   0x18ef06ef4:  e0 07 40 fd   ldr	d0, [sp, #0x8]
   0x18ef06ef8:  c8 09 e8 d2   mov	x8, #0x404e000000000000
   0x18ef06efc:  01 01 67 9e   fmov	d1, x8
   0x18ef06f00:  02 10 6c 1e   fmov	d2, #0.50000000
   0x18ef06f04:  00 08 41 1f   fmadd	d0, d0, d1, d2
   0x18ef06f08:  00 00 79 1e   fcvtzu	w0, d0
   
   GetDoubleClickParameters 0x18ef073b8 -> NXClickTime (cached at +0x558). IOKit NXClickTime 0x184e745a0:
   IOHIDGetParameter("HIDClickTime", 8 bytes) as ns, / 1000 / 1000 / 1000; 0 on error
   MachineSettings _doubleClickThresholdLevel 0x297325bf8 -> NXClickTime; _setDoubleClickThresholdLevel 0x297325d1c:
   NXSetClickTime(t); NXSetClickSpace(min(2 + 6 t, 14))

   IOHIDFamily kext, IOHIDSystem::createParameters (kernel default parameters):
   fffffe000ad28b48:      	adrp	x1, 0xfffffe0007ae5000 <_thread_call_free+0xfffffe0007ae5000>
   fffffe000ad28b4c:      	add	x1, x1, #0xe2b
   fffffe000ad28b50:      	mov	w2, #0x6500     ; =25856
   fffffe000ad28b54:      	movk	w2, #0x1dcd, lsl #16
   fffffe000ad28b58:      	mov	w3, #0x40       ; =64
   fffffe000ad28b5c:      	bl	0xfffffe000ad2e2a4 <__ZN11IOHIDSystem23makeNumberParamPropertyEP12OSDictionaryPKcyj>
   fffffe000ad28bb0:      	movk	w2, #0x1dcd, lsl #16
   fffffe000ad28bb4:      	mov	w3, #0x40       ; =64
   fffffe000ad28bb8:      	bl	0xfffffe000ad2e2a4 <__ZN11IOHIDSystem23makeNumberParamPropertyEP12OSDictionaryPKcyj>
   fffffe000ad28bbc:      	ldr	x0, [x19, #0x178]
   fffffe000ad28bc0:      	adrp	x1, 0xfffffe0007ae4000 <_thread_call_free+0xfffffe0007ae4000>
   fffffe000ad28bc4:      	add	x1, x1, #0xe4c
   fffffe000ad28bc8:      	mov	w2, #0xb000     ; =45056
   fffffe000ad28bcc:      	mov	w3, #0x20       ; =32
   fffffe000ad28bd0:      	bl	0xfffffe000ad2e2a4 <__ZN11IOHIDSystem23makeNumberParamPropertyEP12OSDictionaryPKcyj>
   fffffe000ad28bd4:      	ldr	x0, [x19, #0x178]
   fffffe000ad28bd8:      	adrp	x1, 0xfffffe0007ae4000 <_thread_call_free+0xfffffe0007ae4000>
   fffffe000ad28bdc:      	add	x1, x1, #0xe1c
   fffffe000ad28be0:      	mov	w2, #0xb000     ; =45056
   fffffe000ad28be4:      	mov	w3, #0x20       ; =32
   fffffe000ad28be8:      	bl	0xfffffe000ad2e2a4 <__ZN11IOHIDSystem23makeNumberParamPropertyEP12OSDictionaryPKcyj>
   fffffe000ad28bec:      	ldr	x0, [x19, #0x178]
   strings: 0xfffffe0007ae5e2b HIDClickTime, ...5e46 HIDKeyRepeat, ...5e53 HIDInitialKeyRepeat
   0x1dcd6500 = 500000000 ns = 0.5 s; 0x04f790d5 = 83333333 ns

   MouseExtension.appex Double-Click Speed (FUN_10003035c): slider index default 5.0, setter _setDoubleClickThresholdLevel,
   value table (static array 0x1000517d8, count 11, values from 0x1000517f8):
   [5.0, 3.0, 2.0, 1.8, 1.7, 1.4, 1.1, 0.8, 0.5, 0.2, 0.15] seconds; index = the entry within 0.01 of NXClickTime (FUN_100018adc) */
//==== 100018adc FUN_100018adc (asked 0x100018adc)

long FUN_100018adc(double param_1)

{
  long lVar1;
  long lVar2;
  long unaff_x20;
  
  lVar2 = *(long *)(*(long *)(unaff_x20 + 0x10) + 0x10);
  if (lVar2 == 0) {
    return -1;
  }
  lVar1 = lVar2;
  do {
    lVar1 = lVar1 + -1;
    lVar2 = lVar2 + -1;
    if (ABS(*(double *)(*(long *)(unaff_x20 + 0x10) + 0x20 + lVar2 * 8) - param_1) < 0.01) {
      return lVar1;
    }
  } while (lVar1 != 0);
  return -1;
}


