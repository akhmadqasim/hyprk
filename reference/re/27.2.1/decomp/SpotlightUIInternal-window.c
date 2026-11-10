// SpotlightUIInternal.framework 27.2.1 excerpts: window invocation/dismissal springs, glass.
//==== 2adea2ff0 FUN_2adea2ff0 (for 0x2adea3088)

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

ulong FUN_2adea2ff0(undefined8 param_1,undefined8 param_2,double param_3,ulong param_4)

{
  code *pcVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  ulong uVar6;
  undefined *puVar7;
  undefined *puVar8;
  ulong uVar9;
  ulong uVar10;
  ulong uVar11;
  ulong uVar12;
  double dVar13;
  double dVar14;
  double dVar15;
  
  uVar3 = 0x3fda3d70a3d70a3d;
  if ((param_4 & 1) == 0) {
    uVar3 = 0x3fd47ae147ae147b;
  }
  uVar2 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,uVar3);
  objc_retain();
  uVar3 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae0026e0);
  objc_msgSend$setKeyPath:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  objc_retain();
  uVar3 = uVar2;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_1);
  objc_msgSend$setFromValue:(uVar2);
  objc_release(uVar3);
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0x3ff0000000000000);
  objc_msgSend$setToValue:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  uVar3 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fd47ae147ae147b);
  objc_retain();
  uVar4 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae002700);
  objc_msgSend$setKeyPath:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  if ((param_4 & 1) == 0 && param_3 <= 0.0) {
    param_2 = param_1;
  }
  objc_retain();
  uVar4 = uVar3;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_2);
  objc_msgSend$setFromValue:(uVar3);
  objc_release(uVar4);
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0x3ff0000000000000);
  objc_msgSend$setToValue:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  uVar4 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fd47ae147ae147b);
  objc_retain();
  uVar5 = 0xd000000000000017;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000017,0x80000002ae002720);
  objc_msgSend$setKeyPath:(uVar4);
  objc_release(uVar4);
  objc_release(uVar5);
  objc_retain();
  uVar5 = uVar4;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_3);
  objc_msgSend$setFromValue:(uVar4);
  objc_release(uVar5);
  dVar14 = 0.0;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0);
  objc_msgSend$setToValue:(uVar4);
  objc_release(uVar4);
  objc_release(uVar5);
  uVar6 = _DAT_2d803c048;
  objc_allocWithZone();
  objc_msgSend$init();
  puVar7 = &DAT_2e1b6e9e0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b6e9e0,&DAT_2adff3070);
  swift_allocObject();
  dVar13 = _DAT_2adff5750;
  *(undefined8 *)(puVar7 + 0x18) = _UNK_2adff5758;
  *(double *)(puVar7 + 0x10) = dVar13;
  *(undefined8 *)(puVar7 + 0x20) = uVar2;
  *(undefined8 *)(puVar7 + 0x28) = uVar3;
  *(undefined8 *)(puVar7 + 0x30) = uVar4;
  uVar5 = 0;
  FUN_2ade658c8(0,&DAT_2e1b6f420,0x2d803c040);
  objc_retain(uVar2);
  objc_retain();
  objc_retain(uVar4);
  puVar8 = puVar7;
  $sSa10FoundationE19_bridgeToObjectiveCSo7NSArrayCyF(puVar7,uVar5);
  swift_release(puVar7);
  objc_msgSend$setAnimations:(uVar6);
  objc_release(puVar8);
  uVar11 = uVar6;
  objc_msgSend$animations();
  objc_retainAutoreleasedReturnValue();
  if (uVar11 != 0) {
    uVar9 = uVar11;
    $sSa10FoundationE36_unconditionallyBridgeFromObjectiveCySayxGSo7NSArrayCSgFZ();
    objc_release(uVar11);
    if (uVar9 >> 0x3e == 0) {
      uVar11 = *(ulong *)((uVar9 & 0xffffffffffffff8) + 0x10);
    }
    else {
      uVar11 = uVar9 & 0xffffffffffffff8;
      if (0x7fffffffffffffff < uVar9) {
        uVar11 = uVar9;
      }
      $ss18_CocoaArrayWrapperV8endIndexSivg();
    }
    if (uVar11 != 0) {
      uVar12 = 0;
      dVar15 = dVar14;
      do {
        if ((uVar9 & 0xc000000000000001) == 0) {
          if (*(ulong *)((uVar9 & 0xffffffffffffff8) + 0x10) <= uVar12) {
                    /* WARNING: Does not return */
            pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea3410);
            (*pcVar1)();
          }
          uVar10 = *(ulong *)(uVar9 + 0x20 + uVar12 * 8);
          objc_retain(uVar10);
          dVar14 = dVar13;
        }
        else {
          uVar10 = uVar12;
          $ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5(uVar12,uVar9);
          dVar14 = dVar13;
        }
        if (SCARRY8(uVar12,1)) {
                    /* WARNING: Does not return */
          pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea340c);
          (*pcVar1)();
        }
        uVar12 = uVar12 + 1;
        objc_msgSend$duration();
        dVar13 = dVar14;
        objc_release(uVar10);
        if (dVar14 < dVar15) {
          dVar14 = dVar15;
        }
        dVar15 = dVar14;
      } while (uVar12 != uVar11);
    }
    swift_bridgeObjectRelease(uVar9);
  }
  objc_msgSend$setDuration:(dVar14,uVar6);
  objc_release(uVar4);
  objc_release(uVar3);
  objc_release(uVar2);
  return uVar6;
}


//==== 2adea36c8 FUN_2adea36c8 (for 0x2adea373c)

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

ulong FUN_2adea36c8(undefined8 param_1,undefined8 param_2,double param_3,uint param_4)

{
  code *pcVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  ulong uVar6;
  undefined *puVar7;
  undefined *puVar8;
  ulong uVar9;
  ulong uVar10;
  ulong uVar11;
  ulong uVar12;
  double dVar13;
  double dVar14;
  double dVar15;
  
  uVar2 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fdccccccccccccd,0x3fa999999999999a);
  objc_retain();
  uVar3 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae0026e0);
  objc_msgSend$setKeyPath:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  objc_retain();
  uVar3 = uVar2;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0x3ff0000000000000);
  objc_msgSend$setFromValue:(uVar2);
  objc_release(uVar3);
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_1);
  objc_msgSend$setToValue:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  uVar3 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fdccccccccccccd,0x3fa999999999999a);
  objc_retain();
  uVar4 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae002700);
  objc_msgSend$setKeyPath:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  objc_retain();
  uVar4 = uVar3;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0x3ff0000000000000);
  objc_msgSend$setFromValue:(uVar3);
  objc_release(uVar4);
  if ((param_4 & 1) == 0 && param_3 <= 0.0) {
    param_2 = param_1;
  }
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_2);
  objc_msgSend$setToValue:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  uVar4 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fdccccccccccccd,0x3fa999999999999a);
  objc_retain();
  uVar5 = 0xd000000000000017;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000017,0x80000002ae002720);
  objc_msgSend$setKeyPath:(uVar4);
  objc_release(uVar4);
  objc_release(uVar5);
  objc_retain();
  dVar14 = 0.0;
  uVar5 = uVar4;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(0);
  objc_msgSend$setFromValue:(uVar4);
  objc_release(uVar5);
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_3);
  objc_msgSend$setToValue:(uVar4);
  objc_release(uVar4);
  objc_release(uVar5);
  uVar6 = _DAT_2d803c048;
  objc_allocWithZone();
  objc_msgSend$init();
  puVar7 = &DAT_2e1b6e9e0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b6e9e0,&DAT_2adff3070);
  swift_allocObject();
  dVar13 = _DAT_2adff5750;
  *(undefined8 *)(puVar7 + 0x18) = _UNK_2adff5758;
  *(double *)(puVar7 + 0x10) = dVar13;
  *(undefined8 *)(puVar7 + 0x20) = uVar2;
  *(undefined8 *)(puVar7 + 0x28) = uVar3;
  *(undefined8 *)(puVar7 + 0x30) = uVar4;
  uVar5 = 0;
  FUN_2ade658c8(0,&DAT_2e1b6f420,0x2d803c040);
  objc_retain(uVar2);
  objc_retain();
  objc_retain(uVar4);
  puVar8 = puVar7;
  $sSa10FoundationE19_bridgeToObjectiveCSo7NSArrayCyF(puVar7,uVar5);
  swift_release(puVar7);
  objc_msgSend$setAnimations:(uVar6);
  objc_release(puVar8);
  uVar11 = uVar6;
  objc_msgSend$animations();
  objc_retainAutoreleasedReturnValue();
  if (uVar11 != 0) {
    uVar9 = uVar11;
    $sSa10FoundationE36_unconditionallyBridgeFromObjectiveCySayxGSo7NSArrayCSgFZ();
    objc_release(uVar11);
    if (uVar9 >> 0x3e == 0) {
      uVar11 = *(ulong *)((uVar9 & 0xffffffffffffff8) + 0x10);
    }
    else {
      uVar11 = uVar9 & 0xffffffffffffff8;
      if (0x7fffffffffffffff < uVar9) {
        uVar11 = uVar9;
      }
      $ss18_CocoaArrayWrapperV8endIndexSivg();
    }
    if (uVar11 != 0) {
      uVar12 = 0;
      dVar15 = dVar14;
      do {
        if ((uVar9 & 0xc000000000000001) == 0) {
          if (*(ulong *)((uVar9 & 0xffffffffffffff8) + 0x10) <= uVar12) {
                    /* WARNING: Does not return */
            pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea3ac0);
            (*pcVar1)();
          }
          uVar10 = *(ulong *)(uVar9 + 0x20 + uVar12 * 8);
          objc_retain(uVar10);
          dVar14 = dVar13;
        }
        else {
          uVar10 = uVar12;
          $ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5(uVar12,uVar9);
          dVar14 = dVar13;
        }
        if (SCARRY8(uVar12,1)) {
                    /* WARNING: Does not return */
          pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea3abc);
          (*pcVar1)();
        }
        uVar12 = uVar12 + 1;
        objc_msgSend$duration();
        dVar13 = dVar14;
        objc_release(uVar10);
        if (dVar14 < dVar15) {
          dVar14 = dVar15;
        }
        dVar15 = dVar14;
      } while (uVar12 != uVar11);
    }
    swift_bridgeObjectRelease(uVar9);
  }
  objc_msgSend$setDuration:(dVar14,uVar6);
  objc_release(uVar4);
  objc_release(uVar3);
  objc_release(uVar2);
  return uVar6;
}


//==== 2adea3b40 FUN_2adea3b40 (for 0x2adea3bbc)

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

ulong FUN_2adea3b40(undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
                   ulong param_5)

{
  code *pcVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  ulong uVar5;
  undefined *puVar6;
  undefined *puVar7;
  ulong uVar8;
  ulong uVar9;
  ulong uVar10;
  ulong uVar11;
  double dVar12;
  double dVar13;
  double dVar14;
  
  uVar2 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fd47ae147ae147b);
  objc_retain();
  uVar3 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae0026e0);
  objc_msgSend$setKeyPath:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  objc_retain();
  uVar3 = uVar2;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_1);
  objc_msgSend$setFromValue:(uVar2);
  objc_release(uVar3);
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_3);
  objc_msgSend$setToValue:(uVar2);
  objc_release(uVar2);
  objc_release(uVar3);
  uVar3 = _DAT_2d803c1c8;
  objc_allocWithZone();
  objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fd47ae147ae147b);
  objc_retain();
  uVar4 = 0xd000000000000011;
  $sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(0xd000000000000011,0x80000002ae002700);
  objc_msgSend$setKeyPath:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  objc_retain();
  uVar4 = uVar3;
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_2);
  objc_msgSend$setFromValue:(uVar3);
  objc_release(uVar4);
  if ((param_5 & 1) == 0) {
    param_4 = param_3;
  }
  $s12CoreGraphics7CGFloatV10FoundationE19_bridgeToObjectiveCSo8NSNumberCyF(param_4);
  objc_msgSend$setToValue:(uVar3);
  objc_release(uVar3);
  objc_release(uVar4);
  uVar5 = _DAT_2d803c048;
  objc_allocWithZone();
  objc_msgSend$init();
  puVar6 = &DAT_2e1b6e9e0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b6e9e0,&DAT_2adff3070);
  swift_allocObject();
  dVar12 = _DAT_2adff5760;
  *(undefined8 *)(puVar6 + 0x18) = _UNK_2adff5768;
  *(double *)(puVar6 + 0x10) = dVar12;
  *(undefined8 *)(puVar6 + 0x20) = uVar2;
  *(undefined8 *)(puVar6 + 0x28) = uVar3;
  uVar4 = 0;
  FUN_2ade658c8(0,&DAT_2e1b6f420,0x2d803c040);
  objc_retain(uVar2);
  objc_retain(uVar3);
  puVar7 = puVar6;
  $sSa10FoundationE19_bridgeToObjectiveCSo7NSArrayCyF(puVar6,uVar4);
  swift_release(puVar6);
  objc_msgSend$setAnimations:(uVar5);
  objc_release(puVar7);
  uVar10 = uVar5;
  objc_msgSend$animations();
  objc_retainAutoreleasedReturnValue();
  if (uVar10 == 0) {
    dVar14 = 0.0;
    goto LAB_2adea3e98;
  }
  uVar8 = uVar10;
  $sSa10FoundationE36_unconditionallyBridgeFromObjectiveCySayxGSo7NSArrayCSgFZ();
  objc_release(uVar10);
  if (uVar8 >> 0x3e == 0) {
    uVar10 = *(ulong *)((uVar8 & 0xffffffffffffff8) + 0x10);
    if (uVar10 == 0) goto LAB_2adea3e8c;
LAB_2adea3df0:
    uVar11 = 0;
    dVar13 = 0.0;
    do {
      if ((uVar8 & 0xc000000000000001) == 0) {
        if (*(ulong *)((uVar8 & 0xffffffffffffff8) + 0x10) <= uVar11) {
                    /* WARNING: Does not return */
          pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea3e74);
          (*pcVar1)();
        }
        uVar9 = *(ulong *)(uVar8 + 0x20 + uVar11 * 8);
        objc_retain(uVar9);
        dVar14 = dVar12;
      }
      else {
        uVar9 = uVar11;
        $ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5(uVar11,uVar8);
        dVar14 = dVar12;
      }
      if (SCARRY8(uVar11,1)) {
                    /* WARNING: Does not return */
        pcVar1 = (code *)SoftwareBreakpoint(1,0x2adea3e68);
        (*pcVar1)();
      }
      uVar11 = uVar11 + 1;
      objc_msgSend$duration();
      dVar12 = dVar14;
      objc_release(uVar9);
      if (dVar14 < dVar13) {
        dVar14 = dVar13;
      }
      dVar13 = dVar14;
    } while (uVar11 != uVar10);
  }
  else {
    uVar10 = uVar8 & 0xffffffffffffff8;
    if (0x7fffffffffffffff < uVar8) {
      uVar10 = uVar8;
    }
    $ss18_CocoaArrayWrapperV8endIndexSivg();
    if (uVar10 != 0) goto LAB_2adea3df0;
LAB_2adea3e8c:
    dVar14 = 0.0;
  }
  swift_bridgeObjectRelease(uVar8);
LAB_2adea3e98:
  objc_msgSend$setDuration:(dVar14,uVar5);
  objc_release(uVar3);
  objc_release(uVar2);
  return uVar5;
}


//==== 2ade9ef14 FUN_2ade9ef14 (for 0x2ade9ef14)

/* WARNING: Removing unreachable block (ram,0x0002ade9f2ac) */
/* WARNING: Removing unreachable block (ram,0x0002ade9f334) */
/* WARNING: Removing unreachable block (ram,0x0002ade9f1f8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_2ade9ef14(undefined8 param_1,byte param_2,undefined8 param_3,undefined8 param_4)

{
  double *pdVar1;
  ulong *puVar2;
  code *pcVar3;
  bool bVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined8 uVar8;
  undefined8 *puVar9;
  undefined8 *puVar10;
  ulong *unaff_x20;
  double dVar11;
  undefined1 auVar12 [16];
  double dVar13;
  undefined8 uVar14;
  double local_170;
  double dStack_168;
  undefined8 local_160;
  undefined8 uStack_158;
  undefined8 local_100;
  undefined8 local_f8;
  
  puVar5 = &DAT_2e1b6f2d8;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b6f2d8,&DAT_2adff57a0);
  auVar12 = NEON_fmov(0x3ff0000000000000,8);
  dVar13 = auVar12._8_8_;
  dVar11 = auVar12._0_8_;
  if ((param_2 & 1) == 0) {
    swift_initStackObject();
    uVar14 = _DAT_2adff30c0;
    *(undefined8 *)(puVar5 + 0x18) = _UNK_2adff30c8;
    *(undefined8 *)(puVar5 + 0x10) = uVar14;
    *(undefined8 *)(puVar5 + 0x20) = 0x6c61566168706c61;
    *(undefined8 *)(puVar5 + 0x28) = 0xea00000000006575;
    uVar14 = _DAT_2d803c1c8;
    objc_allocWithZone();
    objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fda3d70a3d70a3d);
    *(undefined8 *)(puVar5 + 0x30) = uVar14;
    *(undefined8 *)(puVar5 + 0x38) = 0xd000000000000011;
    *(undefined8 *)(puVar5 + 0x40) = 0x80000002ae002610;
    uVar14 = _DAT_2d803c1c8;
    objc_allocWithZone();
    objc_msgSend$initWithPerceptualDuration:bounce:(0x3fe051eb851eb852,0x3fa999999999999a);
    *(undefined8 *)(puVar5 + 0x48) = uVar14;
    puVar6 = puVar5;
    FUN_2adea3490(puVar5);
    swift_setDeallocating(puVar5);
    puVar7 = &DAT_2e1b6f2e0;
    ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b6f2e0,&DAT_2adff57a8);
    swift_arrayDestroy(puVar5 + 0x20,2,puVar7);
    uStack_158 = _UNK_2adff5738;
    local_160 = _DAT_2adff5730;
    dStack_168 = _UNK_2adff5728;
    local_170 = _DAT_2adff5720;
    uVar14 = 0x3ff0000000000000;
  }
  else {
    swift_initStackObject();
    uVar14 = _DAT_2adff3730;
    *(undefined8 *)(puVar5 + 0x18) = _UNK_2adff3738;
    *(undefined8 *)(puVar5 + 0x10) = uVar14;
    *(undefined8 *)(puVar5 + 0x20) = 0x6c61566168706c61;
    *(undefined8 *)(puVar5 + 0x28) = 0xea00000000006575;
    uVar14 = _DAT_2d803c1c8;
    objc_allocWithZone();
    objc_msgSend$initWithPerceptualDuration:bounce:(0x3fd1eb851eb851ec,0x3fda3d70a3d70a3d);
    *(undefined8 *)(puVar5 + 0x30) = uVar14;
    puVar6 = puVar5;
    FUN_2adea3490(puVar5);
    swift_setDeallocating(puVar5);
    FUN_2ade65870(puVar5 + 0x20,&DAT_2e1b6f2e0,&DAT_2adff57a8);
    uVar14 = 0;
    uStack_158 = _UNK_2adff5748;
    local_160 = _DAT_2adff5740;
    local_170 = dVar11;
    dStack_168 = dVar13;
  }
  puVar5 = puVar6;
  FUN_2ade9b140(puVar6);
  swift_bridgeObjectRelease(puVar6);
  puVar7 = puVar5;
  $sSD10FoundationE19_bridgeToObjectiveCSo12NSDictionaryCyF(puVar5,_DAT_2d80a48a8,_DAT_2d80a6068 + 8,_DAT_2d80a48b8);
  swift_bridgeObjectRelease(puVar5);
  objc_msgSend$setAnimations:(param_1);
  objc_release(puVar7);
  puVar2 = _DAT_2d80a60e8;
  pdVar1 = (double *)((long)unaff_x20 + DAT_2e1b742d0);
  bVar4 = false;
  if ((*pdVar1 == 1.0) && (bVar4 = false, !NAN(pdVar1[1]))) {
    bVar4 = pdVar1[1] == 1.0;
  }
  if (bVar4) {
    pdVar1[1] = dVar13;
    *pdVar1 = dVar11;
  }
  else {
    puVar5 = &DAT_2adff5a50;
    swift_getKeyPath(&DAT_2adff5a50);
    (**(code **)((*puVar2 & *unaff_x20) + 0x638))((*puVar2 & *unaff_x20) + 0x638);
    swift_release(puVar5);
  }
  pdVar1 = (double *)((long)unaff_x20 + DAT_2e1b742d8);
  bVar4 = false;
  if ((*pdVar1 == 1.0) && (bVar4 = false, !NAN(pdVar1[1]))) {
    bVar4 = pdVar1[1] == 1.0;
  }
  if (bVar4) {
    pdVar1[1] = dVar13;
    *pdVar1 = dVar11;
  }
  else {
    puVar5 = &DAT_2adff5a78;
    swift_getKeyPath(&DAT_2adff5a78);
    (**(code **)((*puVar2 & *unaff_x20) + 0x638))((*puVar2 & *unaff_x20) + 0x638);
    swift_release(puVar5);
  }
  objc_msgSend$setAlphaValue:(uVar14,param_1);
  objc_msgSend$_setContentBlurRadius:(0,param_1);
  (**(code **)((*puVar2 & *unaff_x20) + 0x590))((*puVar2 & *unaff_x20) + 0x590,param_1);
  uVar8 = _DAT_2d8029db0;
  objc_opt_self(_DAT_2d8029db0);
  puVar5 = &DAT_2dc78fc20;
  swift_allocObject(&DAT_2dc78fc20,0x41,7);
  *(undefined8 *)(puVar5 + 0x10) = param_1;
  *(undefined8 *)(puVar5 + 0x30) = uStack_158;
  *(undefined8 *)(puVar5 + 0x28) = local_160;
  *(double *)(puVar5 + 0x20) = dStack_168;
  *(double *)(puVar5 + 0x18) = local_170;
  *(undefined8 *)(puVar5 + 0x38) = 0;
  puVar5[0x40] = param_2 & 1;
  puVar7 = &DAT_2dc78fc48;
  swift_allocObject(&DAT_2dc78fc48,0x20,7);
  *(code **)(puVar7 + 0x10) = FUN_2adea64c0;
  *(undefined **)(puVar7 + 0x18) = puVar5;
  uVar14 = DAT_2adff3008;
  local_100 = _DAT_2d80a6e48;
  local_f8 = DAT_2adff3008;
  puVar9 = &local_100;
  _Block_copy(puVar9);
  objc_retain(param_1);
//==== 2adf11f2c FUN_2adf11f2c (for 0x2adf12284)

/* WARNING: Removing unreachable block (ram,0x0002adf120f4) */
/* WARNING: Removing unreachable block (ram,0x0002adf12004) */
/* WARNING: Removing unreachable block (ram,0x0002adf1207c) */
/* WARNING: Removing unreachable block (ram,0x0002adf12208) */
/* WARNING: Removing unreachable block (ram,0x0002adf11f8c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_2adf11f2c(undefined8 param_1,long param_2,undefined8 param_3)

{
  long lVar1;
  undefined8 uVar2;
  long lVar3;
  long lVar4;
  undefined *puVar5;
  undefined *puVar6;
  long extraout_x8;
  long extraout_x8_00;
  long lVar7;
  long extraout_x8_01;
  long lVar8;
  long extraout_x8_02;
  long extraout_x8_03;
  long extraout_x12;
  long extraout_x12_00;
  long extraout_x12_01;
  long extraout_x12_02;
  long extraout_x12_03;
  long lVar9;
  long lVar10;
  long lVar11;
  long lVar12;
  long lVar13;
  code *pcVar14;
  ulong unaff_x30;
  long local_f0;
  long local_e8;
  long local_e0;
  long local_d8;
  long lStack_d0;
  long local_c8;
  long local_c0;
  long lStack_b8;
  long local_b0;
  long local_a8;
  long local_a0;
  undefined8 local_98;
  long local_90;
  long local_88;
  long local_80;
  long lStack_78;
  undefined8 local_70;
  long local_68;
  
  lVar3 = 0;
  local_98 = param_3;
  local_70 = param_1;
  $s7SwiftUI9_ShapeSetVMa();
  local_80 = *(long *)(lVar3 + -8);
  lStack_78 = lVar3;
  (*_DAT_2daa728b8)(*(undefined8 *)(local_80 + 0x40));
  lVar7 = (long)&local_f0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  local_88 = lVar7;
  $s7SwiftUI8MaterialV13_GlassVariantV16InteractionStateOMa();
  local_a8 = *(long *)(lVar3 + -8);
  local_a0 = lVar3;
  (*_DAT_2daa728b8)(*(undefined8 *)(local_a8 + 0x40));
  lVar7 = lVar7 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  local_b0 = lVar7;
  $s7SwiftUI8MaterialV13_GlassVariantV4SizeOMa();
  local_d8 = *(long *)(lVar3 + -8);
  lStack_d0 = lVar3;
  (*_DAT_2daa728b8)(*(undefined8 *)(local_d8 + 0x40));
  lVar7 = lVar7 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  $s7SwiftUI8MaterialV13_GlassVariantVMa();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_2daa728b8)(*(undefined8 *)(lVar8 + 0x40));
  lVar10 = lVar7 - (extraout_x8_02 + 0xfU & 0xfffffffffffffff0);
  (*_DAT_2daa728b8)();
  lVar9 = lVar10 - extraout_x12;
  (*_DAT_2daa728b8)();
  lVar12 = lVar9 - extraout_x12_00;
  (*_DAT_2daa728b8)();
  lVar13 = lVar12 - extraout_x12_01;
  (*_DAT_2daa728b8)();
  lVar11 = lVar13 - extraout_x12_02;
  (*_DAT_2daa728b8)();
  lVar4 = 0;
  $s7SwiftUI8MaterialVMa();
  local_c0 = *(long *)(lVar4 + -8);
  lStack_b8 = lVar4;
  (*_DAT_2daa728b8)(*(undefined8 *)(local_c0 + 0x40));
  local_c8 = (lVar11 - extraout_x12_03) - (extraout_x8_03 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_2adf11540();
  local_90 = param_2;
  if (*(char *)(param_2 + *(int *)(lVar4 + 0x18)) == '\x01') {
    local_e8 = lVar4;
    $s7SwiftUI5ColorV5clearACvgZ();
    local_e0 = lVar4;
    local_68 = lVar4;
    $s7SwiftUI8MaterialV13_GlassVariantV7regularAEvgZ(lVar10);
    lVar1 = lStack_d0;
    lVar4 = local_d8;
    local_f0 = lVar11 - extraout_x12_03;
    (**(code **)(local_d8 + 0x68))(lVar7,*_DAT_2d803f808,lStack_d0);
    $s7SwiftUI8MaterialV13_GlassVariantV4sizeyA2E4SizeOF(lVar9,lVar7);
    (**(code **)(lVar4 + 8))(lVar7,lVar1);
    pcVar14 = *(code **)(lVar8 + 8);
    (*pcVar14)(lVar10,lVar3);
    $s7SwiftUI8MaterialV13_GlassVariantV8adaptiveyAESbF(lVar12,0);
    (*pcVar14)(lVar9,lVar3);
    $s7SwiftUI8MaterialV13_GlassVariantV15excludingShadowAEyF(lVar13);
    (*pcVar14)(lVar12,lVar3);
    lVar8 = local_a0;
    lVar7 = local_a8;
    lVar4 = local_b0;
    (**(code **)(local_a8 + 0x68))(local_b0,*_DAT_2d803f800,local_a0);
    $s7SwiftUI8MaterialV13_GlassVariantV16interactionStateyA2E011InteractionG0OF(lVar11,lVar4);
    (**(code **)(lVar7 + 8))(lVar4,lVar8);
    (*pcVar14)(lVar13,lVar3);
    lVar4 = local_f0;
    $s7SwiftUI8MaterialV13_GlassVariantV14contentLensingyAESbF(local_f0,1);
    (*pcVar14)(lVar11,lVar3);
    lVar7 = local_c8;
    $s7SwiftUI8MaterialV6_glassyA2C13_GlassVariantVFZ(local_c8,lVar4);
    (*pcVar14)(lVar4,lVar3);
    lVar3 = local_90;
    FUN_2adf1255c(local_98);
    lVar4 = local_88;
    $s7SwiftUI9_ShapeSetV6shapes10smoothnessACSayAA03AnyC0VG_12CoreGraphics7CGFloatVtcfC(local_88,*(undefined8 *)(lVar3 + *(int *)(local_e8 + 0x14)));
    puVar6 = &DAT_2e1b70c58;
    ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b70c58,&DAT_2adffa188);
    puVar5 = puVar6;
    FUN_2adf13fb0();
    uVar2 = local_70;
    $s7SwiftUI4ViewPAAE14materialEffect_2inQrAA8MaterialV_AA9_ShapeSetVtF(local_70,lVar7,lVar4,puVar6,puVar5);
    (**(code **)(local_80 + 8))(lVar4,lStack_78);
    (**(code **)(local_c0 + 8))(lVar7,lStack_b8);
    swift_release(local_e0);
    puVar6 = &DAT_2e1b70c50;
    ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b70c50,&DAT_2adffa180);
    (**(code **)(*(long *)(puVar6 + -8) + 0x38))(uVar2,0,1,puVar6);
    return;
  }
  puVar6 = &DAT_2e1b70c50;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_2e1b70c50,&DAT_2adffa180);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) == 0) {
                    /* WARNING: Could not recover jumptable at 0x0002adf12558. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (**(code **)(*(long *)(puVar6 + -8) + 0x38))(local_70,1,1,puVar6);
    return;
  }
                    /* WARNING: Does not return */
  pcVar14 = (code *)SoftwareBreakpoint(0xc471,0x2adf12554);
  (*pcVar14)();
}


