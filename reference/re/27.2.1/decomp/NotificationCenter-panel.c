// NotificationCenter.app 27.2.1 (26B131), arm64e slice, Ghidra 12.1.4 pseudocode excerpts (panel open/close).
// Addresses are the thin arm64e slice (lipo -thin arm64e), image base 0x100000000.
//==== 1001910a4 FUN_1001910a4 (for 0x1001910a4)

void FUN_1001910a4(undefined8 param_1)

{
  FUN_1001910d8(DAT_1002dbd50,DAT_1002dbd58,0);
  DAT_1003c1388 = param_1;
  return;
}


//==== 1001c6da8 FUN_1001c6da8 (for 0x1001c6da8)
//==== 1001e19c4 FUN_1001e19c4 (for 0x1001e19c4)

/* WARNING: Removing unreachable block (ram,0x0001001e1a28) */

void FUN_1001e19c4(undefined8 param_1,undefined8 param_2,undefined8 param_3,
                  AnimationCompletionCriteria param_4)

{
  AnimationCompletionCriteria AVar1;
  AnimationCompletionCriteria AVar2;
  undefined *puVar3;
  long lVar4;
  long extraout_x8;
  undefined1 auStack_80 [32];
  undefined8 local_60;
  undefined8 uStack_58;
  
  AVar2 = SwiftUI::AnimationCompletionCriteria::typeMetadataAccessor();
  lVar4 = *(long *)(AVar2.unknown + -8);
  (*(code *)PTR____chkstk_darwin_10037a428)(*(undefined8 *)(lVar4 + 0x40));
  if (DAT_1003957f0 != -1) {
    _swift_once(&DAT_1003957f0,FUN_1001910a4);
  }
  AVar1.unknown = DAT_1003c1388.unknown;
  puVar3 = &DAT_100367e18;
  local_60 = param_1;
  uStack_58 = param_2;
  _swift_allocObject(&DAT_100367e18,0x20,7);
  *(undefined8 *)(puVar3 + 0x10) = param_3;
  *(undefined **)(puVar3 + 0x18) = param_4.unknown;
  _swift_retain();
  SwiftUI::AnimationCompletionCriteria::get_logicallyComplete(param_4);
  SwiftUI::_withAnimation(AVar1);
  _swift_release(puVar3);
  (**(code **)(lVar4 + 8))(auStack_80 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),AVar2.unknown);
  return;
}


//==== 1001e195c FUN_1001e195c (for 0x1001e195c)

void FUN_1001e195c(long param_1)

{
  code *pcVar1;
  undefined8 uVar2;
  ulong unaff_x30;
  
  uVar2 = *(undefined8 *)(param_1 + 0x10);
  _swift_retain(uVar2);
  FUN_1001ddd18(0x3ff0000000000000);
  _swift_release(uVar2);
  uVar2 = *(undefined8 *)(param_1 + 0x10);
  _swift_retain(uVar2);
  FUN_1001dd7b8();
  FUN_1001dd848(0);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x1001e19c0);
    (*pcVar1)();
  }
  _swift_release(uVar2);
  return;
}


//==== 1001e1b58 FUN_1001e1b58 (for 0x1001e1b58)

void FUN_1001e1b58(long param_1)

{
  code *pcVar1;
  undefined8 uVar2;
  ulong unaff_x30;
  undefined8 uVar3;
  undefined8 uVar4;
  
  uVar2 = *(undefined8 *)(param_1 + 0x10);
  _swift_retain(uVar2);
  FUN_1001ddd18(0);
  _swift_release(uVar2);
  uVar2 = *(undefined8 *)(param_1 + 0x10);
  uVar3 = *(undefined8 *)(param_1 + 0x58);
  uVar4 = *(undefined8 *)(param_1 + 0x60);
  _swift_retain(uVar2);
  FUN_1001dd848(uVar3,uVar4);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x1001e1bc8);
    (*pcVar1)();
  }
  _swift_release(uVar2);
  return;
}


//==== 1001dc75c FUN_1001dc75c (for 0x1001dc75c)
//==== 1001dd848 FUN_1001dd848 (for 0x1001dd848)

void FUN_1001dd848(double param_1,double param_2)

{
  bool bVar1;
  long unaff_x20;
  
  bVar1 = false;
  if ((*(double *)(unaff_x20 + 0x30) == param_1) &&
     (bVar1 = false, !NAN(*(double *)(unaff_x20 + 0x38)) && !NAN(param_2))) {
    bVar1 = *(double *)(unaff_x20 + 0x38) == param_2;
  }
  if (bVar1) {
    *(double *)(unaff_x20 + 0x30) = param_1;
    *(double *)(unaff_x20 + 0x38) = param_2;
  }
  else {
    _swift_getKeyPath(&DAT_1002df350);
    FUN_1001fd7d4();
    FUN_1001fd590();
    _swift_release();
  }
  return;
}


//==== 1001ddd18 FUN_1001ddd18 (for 0x1001ddd18)

void FUN_1001ddd18(double param_1)

{
  long unaff_x20;
  
  if (*(double *)(unaff_x20 + 0x68) == param_1) {
    *(double *)(unaff_x20 + 0x68) = param_1;
  }
  else {
    _swift_getKeyPath(&DAT_1002df288);
    FUN_1001fd7d4();
    FUN_1001fd590();
    _swift_release();
  }
  return;
}


//==== 1001e18b0 FUN_1001e18b0 (for 0x1001e18b0)

void FUN_1001e18b0(undefined8 param_1,undefined8 param_2,undefined8 param_3)

{
  code *pcVar1;
  undefined *puVar2;
  ulong unaff_x30;
  
  puVar2 = &DAT_100368840;
  _swift_allocObject(&DAT_100368840,0x28,7);
  *(undefined8 *)(puVar2 + 0x10) = param_1;
  *(undefined8 *)(puVar2 + 0x18) = param_2;
  *(undefined8 *)(puVar2 + 0x20) = param_3;
  _swift_retain(param_1);
  _swift_retain(param_3);
  FUN_1001e19c4(FUN_1001fbb14,param_1,FUN_1001fbb58,puVar2);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x1001e1958);
    (*pcVar1)();
  }
  _swift_release(puVar2);
  return;
}


//==== 1001d3ebc FUN_1001d3ebc (for 0x1001d3ebc)

void FUN_1001d3ebc(void)

{
  code *pcVar1;
  undefined *puVar2;
  undefined8 unaff_x19;
  undefined8 unaff_x20;
  undefined8 unaff_x21;
  ulong unaff_x30;
  
  FUN_100132264();
  puVar2 = &DAT_1003687c8;
  FUN_10002ae80();
  _swift_allocObject();
  *(undefined8 *)(puVar2 + 0x10) = unaff_x20;
  *(undefined8 *)(puVar2 + 0x18) = unaff_x21;
  *(undefined8 *)(puVar2 + 0x20) = unaff_x19;
  _swift_retain();
  _swift_retain();
  FUN_1001e19c4(FUN_1001fbae4);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x1001d3f54);
    (*pcVar1)();
  }
  _swift_release(puVar2);
  return;
}


//==== 1001c7498 FUN_1001c7498 (for 0x1001c7498)
//==== 100211574 FUN_100211574 (for 0x100211574)

bool FUN_100211574(ulong param_1)

{
  bool bVar1;
  bool bVar2;
  bool bVar3;
  long unaff_x20;
  double dVar4;
  double dVar5;
  double dVar6;
  
  dVar4 = 1.0 - *(double *)(unaff_x20 + 0x60);
  dVar4 = *(double *)(unaff_x20 + 0x68) * DAT_1002e1768 + dVar4 + dVar4;
  *(double *)(unaff_x20 + 0x68) = dVar4;
  dVar6 = *(double *)(unaff_x20 + 0x60) + dVar4 / *(double *)(unaff_x20 + 0x58);
  if (((param_1 & 1) != 0) || (dVar6 <= 1.0)) {
    if (0.0 < dVar6) {
      dVar5 = dVar4 * DAT_1002cda98 + (dVar6 + -1.0) * DAT_1002e1770;
      bVar1 = ABS(dVar5) < DAT_1002dea10;
      bVar2 = dVar6 + -1.0 < 3.0;
      bVar3 = bVar1 && bVar2;
      dVar4 = 0.0;
      if (!bVar1 || !bVar2) {
        dVar4 = dVar5;
      }
      *(double *)(unaff_x20 + 0x68) = dVar4;
      dVar4 = 1.0;
      if (!bVar1 || !bVar2) {
        dVar4 = dVar6;
      }
      goto LAB_10021166c;
    }
    if ((DAT_1002dea10 <= ABS(dVar4)) || (3.0 <= ABS(dVar6 + -1.0))) {
      bVar3 = false;
      dVar4 = dVar6;
      goto LAB_10021166c;
    }
  }
  *(undefined8 *)(unaff_x20 + 0x68) = 0;
  bVar3 = true;
  dVar4 = 1.0;
LAB_10021166c:
  *(double *)(unaff_x20 + 0x60) = dVar4;
  _swift_getObjectType(*(undefined8 *)(unaff_x20 + 0x48));
  FUN_1002a11e4(dVar4);
  return bVar3;
}


//==== 10021099c FUN_10021099c (for 0x10021099c)
//==== 1001781b4 FUN_1001781b4 (for 0x1001781b4)

/* WARNING: Function: _objc_retain replaced with injection: _objc_retain_fixup */
/* WARNING: Function: _objc_release replaced with injection: _objc_release_fixup */

void FUN_1001781b4(undefined8 param_1,undefined8 param_2,char param_3,undefined8 param_4)

{
  code *pcVar1;
  long lVar2;
  undefined *puVar3;
  long extraout_x8;
  long extraout_x8_00;
  long unaff_x20;
  long lVar4;
  ID self;
  ulong unaff_x30;
  undefined8 uVar5;
  
  FUN_100174bf0(param_4);
  FUN_10017a62c();
  FUN_10017a720(*(undefined8 *)(unaff_x20 + extraout_x8));
  FUN_1001ddcb0();
  _swift_release();
  uVar5 = 0x3ff0000000000000;
  if (param_3 != '\x01') {
    uVar5 = param_2;
  }
  lVar2 = 0;
  FUN_100211704();
  _swift_allocObject();
  FUN_100210c50(param_1,uVar5);
  puVar3 = &DAT_100364460;
  FUN_1000dad10();
  _swift_allocObject();
  *(long *)(puVar3 + 0x10) = unaff_x20;
  lVar4 = *(long *)(lVar2 + 0x18);
  *(code **)(lVar2 + 0x10) = FUN_100179e90;
  *(undefined **)(lVar2 + 0x18) = puVar3;
  _swift_release(lVar4);
  FUN_10017a4c0();
  _swift_unknownObjectWeakInit(lVar4 + 0x10);
  _swift_retain(lVar4);
  FUN_10021099c(0x404e000000000000,1,FUN_100179e98,lVar4);
  _swift_release_n(lVar4,2);
  FUN_10017a77c();
  self = *(ID *)(unaff_x20 + extraout_x8_00);
  *(long *)(unaff_x20 + extraout_x8_00) = lVar2;
  _swift_retain(lVar2);
  _swift_release();
  FUN_1002a9380();
  FUN_10017a684();
  FUN_10017a4e0();
  if (self != 0) {
    objc_stub::makeKeyAndOrderFront_(self);
  }
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x10017832c);
    (*pcVar1)();
  }
  _swift_release(lVar2);
  return;
}


//==== 1001778a4 FUN_1001778a4 (for 0x1001778a4)

void FUN_1001778a4(double param_1,long param_2)

{
  code *pcVar1;
  long lVar2;
  undefined8 uVar3;
  ulong unaff_x30;
  double dVar4;
  undefined8 uVar5;
  
  lVar2 = _TtC21NotificationCenterApp14MainController::notificationsController;
  uVar3 = *(undefined8 *)
           (*(long *)(*(long *)(param_2 +
                               _TtC21NotificationCenterApp14MainController::notificationsController)
                     + 0x28) + 0x10);
  _swift_retain(uVar3);
  FUN_1001ddd18(1.0 - param_1);
  _swift_release(uVar3);
  lVar2 = *(long *)(*(long *)(param_2 + lVar2) + 0x28);
  dVar4 = *(double *)(lVar2 + 0x58);
  uVar5 = *(undefined8 *)(lVar2 + 0x60);
  uVar3 = *(undefined8 *)(lVar2 + 0x10);
  _swift_retain(uVar3);
  FUN_1001dd848(param_1 * dVar4,uVar5);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x100177944);
    (*pcVar1)();
  }
  _swift_release(uVar3);
  return;
}


//==== 100179e90 FUN_100179e90 (for 0x100179e90)
//==== 1001c6ca8 FUN_1001c6ca8

void FUN_1001c6ca8(double param_1)

{
  long unaff_x20;
  double dVar1;
  double dVar2;
  
  dVar1 = param_1;
  _CFAbsoluteTimeGetCurrent();
  if (*(double *)
       (unaff_x20 + _TtC21NotificationCenterApp25CenterAnimationController::eventQueue_currentVBL) <
      dVar1 - *(double *)
               (unaff_x20 +
               _TtC21NotificationCenterApp25CenterAnimationController::
               eventQueue_gestureAnimationLastUpdate)) {
    *(double *)
     (unaff_x20 +
     _TtC21NotificationCenterApp25CenterAnimationController::eventQueue_gestureAnimationLastUpdate)
         = dVar1;
    dVar2 = 0.0;
    if ((0.0 <= param_1) && (dVar2 = param_1, 1.0 < param_1)) {
      dVar2 = ((param_1 + -1.0) * 0.25) / ((param_1 + -1.0) / 0.75 + 1.0) + 1.0;
    }
    *(double *)(unaff_x20 + _TtC21NotificationCenterApp25CenterAnimationController::progress) =
         dVar2;
    if (DAT_100398000 != -1) {
      _swift_once(&DAT_100398000,FUN_1001c7094);
    }
    DAT_1003c14a8 = dVar1;
    _swift_getObjectType
              (*(undefined8 *)
                (unaff_x20 + _TtC21NotificationCenterApp25CenterAnimationController::progressSource)
              );
    FUN_1002a11e4(dVar2);
  }
  return;
}


//==== 1001c53f8 FUN_1001c53f8
// FUN_1001910d8 (asm): Spring(duration:bounce:) -> interpolatingSpring(mass:stiffness:damping:initialVelocity:)
0x1001910D8   mov.16b  v3, v2               
0x1001910DC   fcmp     d0, #0.0             
0x1001910E0   b.ls     0x1001910f8          
0x1001910E4   adrp     x8, 330              ; 0x1002db000
0x1001910E8   ldr      d2, [x8, #0xd60]     
0x1001910EC   fdiv     d0, d2, d0           
0x1001910F0   fmul     d4, d0, d0           
0x1001910F4   b        0x100191100          
0x1001910F8   mov      x8, #0x7ff0000000000000 
0x1001910FC   fmov     d4, x8               
0x100191100   mov      x8, #0x7ff0000000000000 
0x100191104   fmov     d0, x8               
0x100191108   fmov     d2, #-1.00000000     
0x10019110C   fmov     d5, #1.00000000      
0x100191110   fadd     d6, d1, d5           
0x100191114   fdiv     d6, d5, d6           
0x100191118   fcmp     d1, d5               
0x10019111C   fcsel    d7, d5, d1, gt       
0x100191120   fsub     d7, d5, d7           
0x100191124   fcmp     d1, #0.0             
0x100191128   fcsel    d5, d5, d7, eq       
0x10019112C   fcsel    d5, d6, d5, mi       
0x100191130   fcmp     d1, d2               
0x100191134   fcsel    d0, d0, d5, ls       
0x100191138   fsqrt    d1, d4               
0x10019113C   fadd     d1, d1, d1           
0x100191140   fmul     d2, d1, d0           
0x100191144   fmov     d0, #1.00000000      
0x100191148   mov.16b  v1, v4               
0x10019114C   b        _$s7SwiftUI9AnimationV19interpolatingSpring4mass9stiffness7damping15initialVelocityACSd_S3dtFZ 
0x100191150   pacibsp                       
