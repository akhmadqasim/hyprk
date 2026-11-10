// SystemBannerUI.framework 27.2.1 (volume/brightness HUD content, hosted by MenuBarAgent), Ghidra 12.1.4 excerpts. Cache addresses.
//==== 2aed436a4 FUN_2aed436a4 (for 0x2aed436a4)

void FUN_2aed436a4(undefined8 param_1)

{
  $s7SwiftUI9AnimationV19interpolatingSpring4mass9stiffness7damping15initialVelocityACSd_S3dtFZ(0x4000000000000000,DAT_2aed89048,0x4049000000000000,0);
  DAT_2e1bf6780 = param_1;
  return;
}


//==== 2aed436dc FUN_2aed436dc (for 0x2aed436dc)

void FUN_2aed436dc(undefined8 param_1)

{
  $s7SwiftUI9AnimationV6spring8response15dampingFraction13blendDurationACSd_S2dtFZ(DAT_2aed89050,DAT_2aed89058,0);
  DAT_2e1bf6788 = param_1;
  return;
}


//==== 2aed43710 FUN_2aed43710 (for 0x2aed43710)

void FUN_2aed43710(undefined8 param_1)

{
  $s7SwiftUI9AnimationV6spring8response15dampingFraction13blendDurationACSd_S2dtFZ(DAT_2aed89060,DAT_2aed89068,0);
  DAT_2e1bf65d8 = param_1;
  return;
}


//==== 2aed43714 FUN_2aed43714 (for 0x2aed43740)

void FUN_2aed43714(undefined8 param_1)

{
  $s7SwiftUI9AnimationV6spring8response15dampingFraction13blendDurationACSd_S2dtFZ(DAT_2aed89060,DAT_2aed89068,0);
  DAT_2e1bf65d8 = param_1;
  return;
}


//==== 2aed44be4 FUN_2aed44be4 (for 0x2aed44be4)
//==== 2aed44e40 FUN_2aed44e40 (for 0x2aed44e40)

/* WARNING: Removing unreachable block (ram,0x0002aed44e88) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined8 * FUN_2aed44e40(undefined8 param_1)

{
  undefined8 *puVar1;
  long extraout_x8;
  long extraout_x16;
  code *pcVar2;
  undefined8 local_78 [5];
  
  _OUTLINED_FUNCTION_5();
  _OUTLINED_FUNCTION_0();
  (*_DAT_2daa728b8)(*(long *)(extraout_x8 + 0x40) + 0xfU & 0xfffffffffffffff0);
  local_78[0] = 0x3feccccccccccccd;
  _OUTLINED_FUNCTION_7();
  pcVar2 = *(code **)(extraout_x16 + 0x20);
  _OUTLINED_FUNCTION_6();
  (*pcVar2)();
  local_78[0] = 0;
  _OUTLINED_FUNCTION_7(DAT_2e1bf4dd8);
  _OUTLINED_FUNCTION_6();
  (*pcVar2)();
  local_78[0] = 0x4024000000000000;
  _OUTLINED_FUNCTION_7();
  _OUTLINED_FUNCTION_6();
  (*pcVar2)();
  FUN_2aed458fc(param_1,local_78);
  puVar1 = local_78;
  FUN_2aed4b19c(puVar1);
  FUN_2aed45964(param_1);
  return puVar1;
}


//==== 2aed49520 FUN_2aed49520 (for 0x2aed49520)
//==== 2aed4c4c0 FUN_2aed4c4c0 (for 0x2aed4c8b4)

/* WARNING: Removing unreachable block (ram,0x0002aed4c518) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_2aed4c4c0(long param_1,long *param_2,long param_3,undefined8 param_4)

{
  code *pcVar1;
  undefined8 uVar2;
  undefined1 *puVar3;
  long *plVar4;
  long *plVar5;
  long lVar6;
  undefined *puVar7;
  long extraout_x8;
  long extraout_x8_00;
  undefined8 *puVar8;
  long extraout_x8_01;
  long extraout_x9;
  long extraout_x16;
  undefined8 uVar9;
  long lVar10;
  undefined1 auStack_d0 [16];
  long *local_c0;
  long *local_b8;
  undefined1 auStack_a0 [24];
  long local_88;
  long local_80;
  long alStack_78 [3];
  long local_60;
  undefined8 uStack_58;
  
  uVar2 = 0;
  $s7SwiftUI27AnimationCompletionCriteriaVMa(0);
  _OUTLINED_FUNCTION_0();
  (*_DAT_2daa728b8)(*(undefined8 *)(extraout_x8 + 0x40));
  _OUTLINED_FUNCTION_5();
  lVar10 = extraout_x9 - extraout_x8_00;
  local_60 = param_3;
  uStack_58 = param_4;
  ___swift_allocate_boxed_opaque_existential_1(alStack_78);
  (**(code **)(*(long *)(param_3 + -8) + 0x10))();
  _OUTLINED_FUNCTION_19();
  _OUTLINED_FUNCTION_20();
  swift_getKeyPath();
  _OUTLINED_FUNCTION_12();
  swift_release(param_4);
  swift_release(param_1);
  lVar6 = local_88;
  _OUTLINED_FUNCTION_1();
  FUN_2aed4bf78(auStack_a0);
  plVar4 = (long *)0x0;
  if (lVar6 != 0) {
    swift_getKeyPath(param_3 + 0x110);
    _OUTLINED_FUNCTION_20();
    swift_getKeyPath();
    _OUTLINED_FUNCTION_12();
    swift_release(lVar6);
    swift_release(param_1);
    lVar6 = local_88;
    if (local_88 == 0) {
                    /* WARNING: Does not return */
      pcVar1 = (code *)SoftwareBreakpoint(1,0x2aed4c8e0);
      (*pcVar1)();
    }
    puVar3 = auStack_a0;
    ___swift_project_boxed_opaque_existential_0(puVar3,local_88);
    plVar4 = alStack_78;
    FUN_2aed8338c(plVar4,lVar6,local_80,puVar3);
    ___swift_destroy_boxed_opaque_existential_1Tm(auStack_a0);
    param_1 = local_80;
    if (((ulong)plVar4 & 1) != 0) goto LAB_2aed4c8b8;
  }
  plVar5 = param_2 + 2;
  swift_unknownObjectWeakLoadStrong();
  if (plVar5 != (long *)0x0) {
    param_1 = param_3 + 0x110;
    swift_getKeyPath(param_1);
    lVar6 = param_3;
    swift_getKeyPath(param_3);
    $s7Combine9PublishedV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAHyqd__ACyxGGtcRld__CluigZ(auStack_d0,param_2,param_1,lVar6);
    swift_release(param_1);
    swift_release(lVar6);
    plVar4 = plVar5;
    if (local_b8 == (long *)0x0) {
      swift_unknownObjectRelease(plVar5);
      _OUTLINED_FUNCTION_1();
      FUN_2aed4bf78(auStack_d0);
    }
    else {
      FUN_2aed4c4a8(auStack_d0,auStack_a0);
      FUN_2aed8558c(auStack_a0,1);
      FUN_2aed85608(auStack_a0,1);
      swift_unknownObjectRelease(plVar5);
      ___swift_destroy_boxed_opaque_existential_1Tm(auStack_a0);
    }
  }
  plVar5 = param_2 + 2;
  swift_unknownObjectWeakLoadStrong();
  if (plVar5 != (long *)0x0) {
    FUN_2aed8529c(alStack_78);
    swift_unknownObjectRelease(plVar5);
    plVar4 = plVar5;
  }
  swift_getKeyPath(param_3 + 0x110);
  _OUTLINED_FUNCTION_20();
  swift_getKeyPath();
  _OUTLINED_FUNCTION_12();
  swift_release(plVar4);
  swift_release(param_1);
  lVar6 = local_88;
  _OUTLINED_FUNCTION_1();
  FUN_2aed4bf78(auStack_a0);
  if (lVar6 == 0) {
    (**(code **)(*param_2 + 0x208))();
    plVar4 = param_2;
  }
  param_3 = param_3 + 0x110;
  swift_getKeyPath(param_3);
  _OUTLINED_FUNCTION_20();
  swift_getKeyPath();
  $s7Combine9PublishedV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAHyqd__ACyxGGtcRld__CluigZ(auStack_a0,param_2,plVar4,param_3);
  swift_release(plVar4);
  swift_release(param_3);
  _OUTLINED_FUNCTION_1();
  FUN_2aed4bf78(auStack_a0);
  if (local_88 == 0) {
    if (DAT_2e1bf4c48 != -1) {
      _OUTLINED_FUNCTION_8();
      swift_once();
    }
    puVar8 = &DAT_2e1bf6780;
  }
  else {
    if (DAT_2e1bf4c40 != -1) {
      swift_once(&DAT_2e1bf4c40,FUN_2aed436dc);
    }
    puVar8 = &DAT_2e1bf6788;
  }
  uVar9 = *puVar8;
  swift_retain(uVar9);
  local_b8 = alStack_78;
  local_c0 = param_2;
  FUN_2aed4c234(alStack_78,auStack_a0);
  puVar7 = &DAT_2dc82ecd0;
  swift_allocObject(&DAT_2dc82ecd0,0x40,7);
  *(long **)(puVar7 + 0x10) = param_2;
  FUN_2aed4c4a8(auStack_a0,puVar7 + 0x18);
  swift_retain(param_2);
  $s7SwiftUI27AnimationCompletionCriteriaV17logicallyCompleteACvgZ(lVar10);
  _OUTLINED_FUNCTION_30();
  $s7SwiftUI13withAnimation_18completionCriteria_0E0xAA0D0VSg_AA0d10CompletionF0VxyKXEyyctKlF(uVar9,lVar10,FUN_2aed4c940,auStack_d0,FUN_2aed4c99c,puVar7,extraout_x8_01 + 8)
  ;
  swift_release(uVar9);
  swift_release(puVar7);
  (**(code **)(extraout_x16 + 8))(lVar10,uVar2);
  if (lVar6 != 0) {
    FUN_2aed49f8c();
  }
LAB_2aed4c8b8:
  ___swift_destroy_boxed_opaque_existential_1Tm(alStack_78);
  return;
}


//==== 2aed44aa8 FUN_2aed44aa8 (for 0x2aed44aa8)
//==== 2aed49f8c FUN_2aed49f8c (for 0x2aed49f8c)

void FUN_2aed49f8c(void)

{
  if (DAT_2e1bf4c48 != -1) {
    _OUTLINED_FUNCTION_8();
    swift_once();
  }
  _OUTLINED_FUNCTION_30(DAT_2e1bf6780);
  $s7SwiftUI13withAnimationyxAA0D0VSg_xyKXEtKlF();
  return;
}


//==== 2aed4c4c0 FUN_2aed4c4c0 (for 0x2aed4c4c0)
//==== 2aed5ab20 FUN_2aed5ab20

void FUN_2aed5ab20(long *param_1,double param_2)

{
  undefined8 *puVar1;
  bool bVar2;
  long lVar3;
  long lVar4;
  long lVar5;
  ulong uVar6;
  long unaff_x20;
  long lVar7;
  
  lVar7 = *(long *)(unaff_x20 + 0x18);
  lVar3 = lVar7;
  if (lVar7 == 0) {
    lVar3 = 0x2e72656b61657073;
    if (DAT_2aed8af88 <= param_2) {
      if (DAT_2aed8ad58 <= param_2) {
        if (DAT_2aed8af90 <= param_2) {
          uVar6 = 0x332e65766177;
        }
        else {
          uVar6 = 0x322e65766177;
        }
      }
      else {
        uVar6 = 0x312e65766177;
      }
      uVar6 = uVar6 | 0xee00000000000000;
    }
    else {
      uVar6 = 0xed00006873616c73;
    }
    $s7SwiftUI5ImageV10systemNameACSS_tcfC(0x2e72656b61657073,uVar6);
    swift_retain();
  }
  bVar2 = lVar7 != 0;
  swift_retain_n(lVar7,2);
  $s7SwiftUI19HorizontalAlignmentV7leadingACvgZ();
  lVar4 = lVar7;
  $s7SwiftUI17VerticalAlignmentV19firstTextLineCenterACvgZ();
  lVar5 = 0;
  FUN_2aed758d4();
  $s7SwiftUI14SymbolVariantsV4fillACvgZ((long)param_1 + (long)*(int *)(lVar5 + 0x1c));
  swift_release(lVar3);
  *param_1 = lVar3;
  param_1[1] = lVar7;
  param_1[2] = lVar4;
  *(bool *)(param_1 + 3) = bVar2;
  puVar1 = (undefined8 *)((long)param_1 + (long)*(int *)(lVar5 + 0x20));
  *puVar1 = 0;
  *(undefined1 *)(puVar1 + 1) = 0;
  puVar1[2] = 0;
  *(undefined1 *)(puVar1 + 3) = 0;
  puVar1[4] = 0;
  *(undefined1 *)(puVar1 + 5) = 0;
  puVar1[6] = 0;
  *(undefined1 *)(puVar1 + 7) = 0;
  return;
}


//==== 2aed5ac68 FUN_2aed5ac68
//==== 2aed61dd8 FUN_2aed61dd8

/* WARNING: Removing unreachable block (ram,0x0002aed62290) */
/* WARNING: Removing unreachable block (ram,0x0002aed621a8) */
/* WARNING: Removing unreachable block (ram,0x0002aed620c8) */
/* WARNING: Removing unreachable block (ram,0x0002aed61eec) */
/* WARNING: Removing unreachable block (ram,0x0002aed62050) */
/* WARNING: Removing unreachable block (ram,0x0002aed62138) */
/* WARNING: Removing unreachable block (ram,0x0002aed6221c) */
/* WARNING: Removing unreachable block (ram,0x0002aed62434) */
/* WARNING: Removing unreachable block (ram,0x0002aed61e40) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_2aed61dd8(undefined8 param_1,long param_2)

{
  undefined4 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  undefined8 uVar7;
  undefined8 uVar8;
  undefined8 uVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  undefined8 uVar12;
  double dVar13;
  double dVar14;
  double dVar15;
  double dVar16;
  long lVar17;
  undefined *puVar18;
  undefined8 *puVar19;
  long extraout_x8;
  long extraout_x8_00;
  long extraout_x8_01;
  code *extraout_x8_02;
  code *extraout_x8_03;
  code *extraout_x8_04;
  code *extraout_x8_05;
  code *extraout_x8_06;
  code *extraout_x8_07;
  code *extraout_x8_08;
  undefined1 *puVar20;
  long lVar21;
  long extraout_x12;
  long extraout_x12_00;
  long extraout_x16;
  long extraout_x16_00;
  long extraout_x16_01;
  long extraout_x16_02;
  code *pcVar22;
  double dVar23;
  double dVar24;
  undefined1 auStack_280 [8];
  double local_278;
  double local_270;
  double local_268;
  double local_260;
  undefined8 local_258;
  undefined8 local_250;
  undefined8 local_248;
  undefined8 local_240;
  undefined8 local_238;
  undefined8 local_220;
  undefined8 local_1a0;
  undefined8 local_188;
  undefined8 local_180;
  undefined8 local_158;
  undefined8 local_150;
  undefined8 local_140;
  undefined8 local_138;
  double local_130;
  double local_128;
  undefined8 local_120;
  undefined8 local_118;
  double local_110;
  double dStack_108;
  undefined1 local_100 [8];
  undefined1 auStack_f8 [8];
  double local_f0;
  double dStack_e8;
  double local_e0;
  double dStack_d8;
  double local_d0;
  undefined8 uStack_c8;
  double local_c0;
  undefined8 uStack_b8;
  undefined8 local_b0;
  undefined8 uStack_a8;
  undefined8 *local_a0;
  undefined8 local_98;
  undefined8 local_90;
  undefined8 local_88;
  undefined8 local_80;
  
  uVar2 = 0;
  $s7SwiftUI11ColorSchemeOMa();
  _OUTLINED_FUNCTION_0();
  (*_DAT_2daa728b8)(*(undefined8 *)(extraout_x8 + 0x40));
  _OUTLINED_FUNCTION_12();
  _OUTLINED_FUNCTION_12();
  uVar3 = 0;
  $s7SwiftUI7CapsuleVMa();
  _OUTLINED_FUNCTION_3();
  (*_DAT_2daa728b8)(*(undefined8 *)(extraout_x16_00 + 0x40));
  _OUTLINED_FUNCTION_12();
  _OUTLINED_FUNCTION_12();
  uVar4 = 0;
  $s7SwiftUI6_GlassVMa();
  _OUTLINED_FUNCTION_0();
  (*_DAT_2daa728b8)(*(undefined8 *)(extraout_x8_00 + 0x40));
  puVar20 = auStack_280 + -(extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  (*_DAT_2daa728b8)();
  lVar21 = (long)puVar20 - extraout_x12;
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_12(lVar21 - extraout_x12_00);
  uVar5 = 0xff;
  FUN_2aed643b8();
  dVar24 = *(double *)(param_2 + 0x18);
  dVar23 = *(double *)(param_2 + 0x10);
  uVar6 = 0xff;
  local_88 = uVar5;
  FUN_2aed4db6c(0xff,dVar23,*(undefined8 *)(param_2 + 0x18));
  uVar5 = 0xff;
  local_80 = uVar6;
  $s7SwiftUI12TupleContentVMa(0xff,2,&local_88);
  _OUTLINED_FUNCTION_1();
  FUN_2aed63028();
  local_98 = uVar5;
  _OUTLINED_FUNCTION_6();
  local_a0 = &local_98;
  local_90 = uVar5;
  _OUTLINED_FUNCTION_4();
  swift_getWitnessTable();
  uVar7 = 0;
  local_220 = uVar5;
  $s7SwiftUI6HStackVMa(0);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  uVar5 = _DAT_2d803ffd0;
  uVar8 = 0;
  $s7SwiftUI15ModifiedContentVMa(0,uVar7,_DAT_2d803ffd0);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  uVar9 = 0;
  $s7SwiftUI15ModifiedContentVMa(0,uVar8,uVar5);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  uVar10 = 0;
  $s7SwiftUI15ModifiedContentVMa(0,uVar9,uVar5);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  uVar11 = 0;
  $s7SwiftUI15ModifiedContentVMa(0,uVar10,_DAT_2d803fcf0);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  uVar12 = 0;
  $s7SwiftUI15ModifiedContentVMa(0,uVar11,_DAT_2d803ffb0);
  uVar5 = uVar12;
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  _OUTLINED_FUNCTION_5();
  swift_getWitnessTable();
  uVar6 = uVar5;
  FUN_2aed48e50();
  dVar16 = _DAT_2d8040190;
  dVar13 = _DAT_2d8040190;
  local_b0 = uVar5;
  uStack_a8 = uVar6;
  swift_getWitnessTable(_DAT_2d8040190,uVar8,&local_b0);
  dVar14 = dVar16;
  local_278 = dVar13;
  local_c0 = dVar13;
  uStack_b8 = uVar6;
  swift_getWitnessTable(dVar16,uVar9,&local_c0);
  dVar13 = dVar16;
  local_270 = dVar14;
  local_d0 = dVar14;
  uStack_c8 = uVar6;
  swift_getWitnessTable(dVar16,uVar10,&local_d0);
  dVar14 = dVar13;
  local_268 = dVar13;
  FUN_2aed48ea4();
  dVar15 = dVar16;
  local_e0 = dVar13;
  dStack_d8 = dVar14;
  swift_getWitnessTable(dVar16,uVar11,&local_e0);
  dVar13 = dVar15;
  local_260 = dVar15;
  FUN_2aed605fc();
  local_f0 = dVar15;
  dStack_e8 = dVar13;
  swift_getWitnessTable(dVar16,uVar12,&local_f0);
  dVar13 = dVar16;
  _OUTLINED_FUNCTION_2();
  FUN_2aed63028();
  uVar5 = 0;
  local_120 = uVar12;
  local_118 = uVar3;
  local_110 = dVar16;
  dStack_108 = dVar13;
  swift_getOpaqueTypeMetadata2(0,&local_120,_DAT_2d80414d0,0);
  _OUTLINED_FUNCTION_0();
  _OUTLINED_FUNCTION_4();
  (*_DAT_2daa728b8)();
  _OUTLINED_FUNCTION_10();
  _OUTLINED_FUNCTION_12();
  $s7SwiftUI17VerticalAlignmentV6centerACvgZ();
  local_110 = dVar23;
  dStack_108 = dVar24;
  $s7SwiftUI6HStackV9alignment7spacing7contentACyxGAA17VerticalAlignmentV_12CoreGraphics7CGFloatVSgxyXEtcfC(local_238);
  $s7SwiftUI4EdgeO3SetV7leadingAEvgZ();
  $s7SwiftUI4ViewPAAE7paddingyQrAA4EdgeO3SetV_12CoreGraphics7CGFloatVSgtF(local_240);
  _OUTLINED_FUNCTION_41(local_100);
  (*extraout_x8_02)(local_238,uVar7);
  $s7SwiftUI4EdgeO3SetV8trailingAEvgZ();
  $s7SwiftUI4ViewPAAE7paddingyQrAA4EdgeO3SetV_12CoreGraphics7CGFloatVSgtF(local_248);
  _OUTLINED_FUNCTION_41(&dStack_108);
  (*extraout_x8_03)(local_240,uVar8);
  $s7SwiftUI4EdgeO3SetV8verticalAEvgZ();
  $s7SwiftUI4ViewPAAE7paddingyQrAA4EdgeO3SetV_12CoreGraphics7CGFloatVSgtF(local_250);
  _OUTLINED_FUNCTION_41(&local_128);
  (*extraout_x8_04)(local_248,uVar9);
  $s7SwiftUI9AlignmentV6centerACvgZ();
  $s7SwiftUI4ViewPAAE5frame5width6height9alignmentQr12CoreGraphics7CGFloatVSg_AkA9AlignmentVtF(local_258,0x4073300000000000,0,0x4050800000000000,0,local_248,uVar9,uVar10,
                      local_268);
  _OUTLINED_FUNCTION_41(&local_130);
  (*extraout_x8_05)(local_250,uVar10);
  lVar17 = param_2;
  FUN_2aed61d5c(param_2);
  FUN_2aed44ab8();
  swift_release(lVar17);
  $s7SwiftUI4ViewPAAE7opacityyQrSdF(local_150,dVar23,uVar11,local_260);
  _OUTLINED_FUNCTION_41(&local_110);
  (*extraout_x8_06)(local_258,uVar11);
  if (DAT_2e1bf4c58 != -1) {
    swift_once(&DAT_2e1bf4c58,FUN_2aed43774);
  }
  uVar6 = uVar4;
  ___swift_project_value_buffer(uVar4,&DAT_2e1bf6760);
  (**(code **)(extraout_x16_01 + 0x10))(lVar21,uVar6,uVar4);
  $s7SwiftUI6_GlassV8identityACvgZ(puVar20);
  FUN_2aed61d5c(param_2);
  FUN_2aed44ab8();
  swift_release(param_2);
  $s7SwiftUI6_GlassV3mix4with2byA2C_SdtF(local_1a0,1.0 - dVar23,puVar20);
  pcVar22 = *(code **)(extraout_x16_01 + 8);
  (*pcVar22)(puVar20,uVar4);
  (*pcVar22)(lVar21,uVar4);
  uVar1 = *_DAT_2d8040848;
  $s7SwiftUI18RoundedCornerStyleOMa(0);
  _OUTLINED_FUNCTION_3();
  (**(code **)(extraout_x16_02 + 0x68))(local_188,uVar1);
  $s7SwiftUI4ViewPAAE12_glassEffect_2inQrAA6_GlassV_qd__tAA5ShapeRd__lF(local_158,local_1a0,local_188,uVar12,uVar3,dVar16,dVar13);
  FUN_2aed631ec(local_188,_DAT_2d8041b30);
  (*pcVar22)(local_1a0,uVar4);
  _OUTLINED_FUNCTION_41(&local_c0);
  (*extraout_x8_07)(local_150,uVar12);
  puVar18 = &DAT_2aed8b628;
  swift_getKeyPath(&DAT_2aed8b628);
  (**(code **)(extraout_x16 + 0x68))(local_180,*_DAT_2d803fa88,uVar2);
  puVar19 = &local_140;
  local_140 = uVar12;
  local_138 = uVar3;
  local_130 = dVar16;
  local_128 = dVar13;
  swift_getOpaqueTypeConformance2(puVar19,_DAT_2d80414d0,1);
  $s7SwiftUI4ViewPAAE11environmentyQrs15WritableKeyPathCyAA17EnvironmentValuesVqd__G_qd__tlF(param_1,puVar18,local_180,uVar5,puVar19);
  swift_release(puVar18);
  (**(code **)(extraout_x16 + 8))(local_180,uVar2);
  _OUTLINED_FUNCTION_41(auStack_f8);
  (*extraout_x8_08)(local_158,uVar5);
  return;
}


//==== 2aed62950 FUN_2aed62950
