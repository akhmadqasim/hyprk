// ControlCenter.app 27.2.1 arm64e excerpts: Control Center panel (bento) transition, volume glyph selector.
//==== 1002dc74c FUN_1002dc74c (for 0x1002dc870)

/* WARNING: Removing unreachable block (ram,0x0001002dc7a0) */

void FUN_1002dc74c(undefined *param_1)

{
  AnimationCompletionCriteria AVar1;
  AnimationCompletionCriteria AVar2;
  AnimationCompletionCriteria AVar3;
  long lVar4;
  long extraout_x8;
  undefined1 auStack_50 [16];
  
  AVar2 = SwiftUI::AnimationCompletionCriteria::typeMetadataAccessor();
  lVar4 = *(long *)(AVar2.unknown + -8);
  (*(code *)PTR____chkstk_darwin_1008a04b8)(*(undefined8 *)(lVar4 + 0x40));
  if (DAT_1008de110 != -1) {
    _swift_once(&DAT_1008de110,FUN_10027f1f8);
  }
  AVar1.unknown = DAT_10095bf80.unknown;
  AVar3.unknown = param_1;
  _swift_retain();
  SwiftUI::AnimationCompletionCriteria::get_logicallyComplete(AVar3);
  SwiftUI::_withAnimation(AVar1);
  _swift_release(param_1);
  (**(code **)(lVar4 + 8))(auStack_50 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),AVar2.unknown);
  return;
}


//==== 1002dce40 FUN_1002dce40 (for 0x1002dcfa0)

/* WARNING: Removing unreachable block (ram,0x0001002dcebc) */
/* WARNING: Removing unreachable block (ram,0x0001002dce8c) */

void FUN_1002dce40(undefined8 param_1,undefined8 param_2)

{
  AnimationCompletionCriteria AVar1;
  AnimationCompletionCriteria AVar2;
  AnimationCompletionCriteria AVar3;
  undefined *puVar4;
  long extraout_x8;
  long extraout_x8_00;
  long extraout_x9;
  undefined8 uVar5;
  long extraout_x16;
  undefined8 *unaff_x20;
  undefined8 unaff_x30;
  
  uVar5 = *unaff_x20;
  AVar2 = SwiftUI::AnimationCompletionCriteria::typeMetadataAccessor();
  AVar3 = AVar2;
  FUN_10000d680();
  (*(code *)PTR____chkstk_darwin_1008a04b8)(*(undefined8 *)(extraout_x8 + 0x40));
  FUN_10000d770();
  if (DAT_1008de110 != -1) {
    AVar3.unknown = (undefined *)&DAT_1008de110;
    _swift_once(&DAT_1008de110,FUN_10027f1f8);
  }
  AVar1.unknown = DAT_10095bf80.unknown;
  SwiftUI::AnimationCompletionCriteria::get_logicallyComplete(AVar3);
  puVar4 = &DAT_10086af38;
  FUN_100095540();
  _swift_allocObject();
  *(undefined8 *)(puVar4 + 0x10) = param_1;
  *(undefined8 *)(puVar4 + 0x18) = param_2;
  *(undefined8 *)(puVar4 + 0x20) = uVar5;
  _swift_retain(param_2);
  SwiftUI::_withAnimation(AVar1);
  _swift_release(puVar4);
  (**(code **)(extraout_x16 + 8))(extraout_x9 - extraout_x8_00,AVar2.unknown);
  FUN_10003abd0(unaff_x30);
  return;
}


//==== 1002dcfdc FUN_1002dcfdc (for 0x1002dcfdc)
//==== 1002db3fc FUN_1002db3fc (for 0x1002db3fc)

void FUN_1002db3fc(undefined1 *param_1,ulong param_2)

{
  uint uVar1;
  bool bVar2;
  undefined1 uVar3;
  byte bVar4;
  byte bVar5;
  undefined *puVar6;
  undefined *puVar7;
  ulong uVar8;
  long lVar9;
  uint uVar10;
  int extraout_w8;
  int extraout_w8_00;
  int extraout_w8_01;
  long extraout_x8;
  long extraout_x8_00;
  undefined1 uVar11;
  undefined1 extraout_w9;
  undefined1 extraout_w9_00;
  undefined1 extraout_w9_01;
  long unaff_x20;
  undefined8 uVar12;
  undefined1 uVar13;
  undefined1 uVar14;
  undefined1 uVar15;
  long unaff_x26;
  undefined1 uVar16;
  undefined8 uVar17;
  undefined8 uVar18;
  undefined8 uVar19;
  undefined8 uVar20;
  undefined8 uVar21;
  undefined8 uVar22;
  ulong uVar23;
  undefined8 uVar24;
  undefined8 uVar25;
  undefined8 uVar26;
  undefined8 uVar27;
  double dVar28;
  double dVar29;
  double dVar30;
  undefined1 auStack_c8 [24];
  ulong local_b0;
  undefined8 uStack_a8;
  undefined8 uStack_a0;
  undefined8 uStack_98;
  char local_90;
  
  FUN_1002db2f8();
  bVar4 = (byte)param_2;
  bVar5 = bVar4;
  FUN_1002db23c();
  puVar7 = &DAT_1006f2f20;
  puVar6 = &DAT_1006f2f40;
  _swift_getKeyPath(&DAT_1006f2f40);
  _swift_getKeyPath(&DAT_1006f2f20);
  Combine::Published::_get_subscript(&local_b0);
  _swift_release(puVar6);
  _swift_release(puVar7);
  uVar1 = (uint)(local_b0 >> 0x20);
  uVar10 = uVar1 >> 0x1c;
  uVar8 = local_b0;
  if (uVar10 == 0) {
    dVar28 = *(double *)(local_b0 + 0x10);
    FUN_1002ddb68();
LAB_1002db520:
    dVar29 = dVar28 * DAT_1006f2c00 + DAT_1006f2bf8;
  }
  else {
    bVar2 = uVar10 == 8;
    if (bVar2) {
      FUN_1002de6d0();
      if (!bVar2) {
        dVar28 = *(double *)(extraout_x8 + 0x18);
        FUN_1002ddb68();
        dVar28 = 1.0 - dVar28;
        goto LAB_1002db520;
      }
      FUN_1002ddb68();
      dVar28 = 0.0;
      dVar29 = 1.0;
    }
    else if (uVar1 >> 0x1c == 9) {
      dVar28 = 0.0;
      dVar29 = DAT_1006f2bf8;
      if (local_b0 != 0x9000000000000000) {
        if (local_b0 == 0x9000000000000008) {
          dVar29 = 1.0;
          dVar28 = 1.0;
        }
        else if (local_b0 != 0x9000000000000010) goto LAB_1002db4d4;
      }
    }
    else {
LAB_1002db4d4:
      FUN_1002ddb68();
      dVar29 = 1.0;
      dVar28 = 0.0;
      if ((param_2 & 1) == 0) {
        dVar28 = 1.0;
      }
    }
  }
  FUN_1002d90a8();
  _swift_getKeyPath(&DAT_1006f2f40);
  FUN_1002de7dc();
  FUN_1002de4e4();
  _swift_release(puVar7);
  _swift_release();
  uVar17 = 0;
  uVar19 = 0;
  uVar16 = 1;
  uVar1 = (uint)(local_b0 >> 0x3c) - 2;
  uVar11 = 1;
  uVar20 = 0;
  uVar21 = 0;
  uVar22 = 0;
  uVar24 = 0;
  uVar26 = 0;
  uVar27 = 0;
  uVar3 = uVar1 == 6;
  if (uVar1 < 7) {
    uVar3 = uVar1 == 6;
    switch(uVar1) {
    default:
      uVar16 = 0;
//==== 1005542f8 FUN_1005542f8 (for 0x1005542f8)

undefined8 FUN_1005542f8(double param_1,ulong param_2)

{
  ulong *puVar1;
  bool bVar2;
  ulong uVar3;
  undefined8 uVar4;
  long unaff_x20;
  ulong uVar5;
  undefined1 auStack_58 [24];
  
  FUN_1000e3ad4();
  FUN_1000e3c80();
  if ((param_2 & 1) == 0) {
    bVar2 = param_1 < *(double *)(unaff_x20 + DAT_10095b028);
  }
  else {
    bVar2 = true;
  }
  puVar1 = (ulong *)(unaff_x20 + DAT_1008ced60);
  _swift_beginAccess(puVar1,auStack_58,0,0);
  uVar5 = *puVar1;
  if (uVar5 != 0) {
    uVar3 = uVar5;
    _swift_retain();
    FUN_1000e9e6c();
    if ((uVar3 & 1) != 0) {
      if (bVar2) {
        uVar4 = DAT_10095d450;
        if (DAT_1008f5348 != -1) {
          _swift_once(&DAT_1008f5348,FUN_100553a4c);
          uVar4 = DAT_10095d450;
        }
      }
      else {
        uVar4 = DAT_10095d448;
        if (DAT_1008f5340 != -1) {
          _swift_once(&DAT_1008f5340,FUN_100553a14);
          uVar4 = DAT_10095d448;
        }
      }
      _swift_retain(uVar4);
      _swift_release(uVar5);
      return uVar4;
    }
    _swift_release(uVar5);
  }
  if (bVar2) {
    uVar4 = DAT_10095d440;
    if (DAT_1008f5338 != -1) {
      _swift_once(&DAT_1008f5338,FUN_100553a84);
      uVar4 = DAT_10095d440;
    }
  }
  else if (DAT_100713770 <= param_1) {
    if (DAT_100713778 <= param_1) {
      uVar4 = DAT_10095d428;
      if (DAT_1008f5320 != -1) {
        _swift_once(&DAT_1008f5320,FUN_100553b54);
        uVar4 = DAT_10095d428;
      }
    }
    else {
      uVar4 = DAT_10095d430;
      if (DAT_1008f5328 != -1) {
        _swift_once(&DAT_1008f5328,FUN_100553b08);
        uVar4 = DAT_10095d430;
      }
    }
  }
  else {
    uVar4 = DAT_10095d438;
    if (DAT_1008f5330 != -1) {
      _swift_once(&DAT_1008f5330,FUN_100553abc);
      uVar4 = DAT_10095d438;
    }
  }
  _swift_retain(uVar4);
  return uVar4;
}


// asm FUN_10027f1f8 / FUN_10027f228 (Spring(duration 0.25, bounce -0.027) -> interpolatingSpring)
0x10027F1F8   pacibsp                       
0x10027F1FC   stp      x29, x30, [sp, #-0x10]! 
0x10027F200   mov      x29, sp              
0x10027F204   adrp     x8, 1133             ; 0x1006ec000
0x10027F208   ldr      d1, [x8, #0xeb0]     
0x10027F20C   fmov     d0, #0.25000000      
0x10027F210   movi.2d  v2, #0000000000000000 
0x10027F214   bl       0x10027f228          
0x10027F218   adrp     x8, 1756             ; 0x10095b000
0x10027F21C   str      x0, [x8, #0xf80]     
0x10027F220   ldp      x29, x30, [sp], #0x10 
0x10027F224   retab                         
0x10027F228   mov.16b  v3, v2               
0x10027F22C   fcmp     d0, #0.0             
0x10027F230   b.ls     0x10027f248          
0x10027F234   adrp     x8, 1133             ; 0x1006ec000
0x10027F238   ldr      d2, [x8, #0xeb8]     
0x10027F23C   fdiv     d0, d2, d0           
0x10027F240   fmul     d4, d0, d0           
0x10027F244   b        0x10027f250          
0x10027F248   mov      x8, #0x7ff0000000000000 
0x10027F24C   fmov     d4, x8               
0x10027F250   mov      x8, #0x7ff0000000000000 
0x10027F254   fmov     d0, x8               
0x10027F258   fmov     d2, #-1.00000000     
0x10027F25C   fmov     d5, #1.00000000      
0x10027F260   fadd     d6, d1, d5           
0x10027F264   fdiv     d6, d5, d6           
0x10027F268   fcmp     d1, d5               
0x10027F26C   fcsel    d7, d5, d1, gt       
0x10027F270   fsub     d7, d5, d7           
0x10027F274   fcmp     d1, #0.0             
0x10027F278   fcsel    d5, d5, d7, eq       
0x10027F27C   fcsel    d5, d6, d5, mi       
0x10027F280   fcmp     d1, d2               
0x10027F284   fcsel    d0, d0, d5, ls       
0x10027F288   fsqrt    d1, d4               
0x10027F28C   fadd     d1, d1, d1           
0x10027F290   fmul     d2, d1, d0           
0x10027F294   fmov     d0, #1.00000000      
0x10027F298   mov.16b  v1, v4               
0x10027F29C   b        _$s7SwiftUI9AnimationV19interpolatingSpring4mass9stiffness7damping15initialVelocityACSd_S3dtFZ 
0x10027F2A0   pacibsp                       
