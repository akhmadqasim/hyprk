
//######## SpecSchemaModifier (spec) 0x195ef3da8
// === 195ef3cd8 spec

/* WARNING: Removing unreachable block (ram,0x000195ef3d1c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef3cd8(undefined8 param_1,undefined8 param_2,long param_3)
{
  (*_DAT_1e2125200)();
  uVar1 = *unaff_x20;
  (**(code **)(extraout_x12 + 0x10))
            (&stack0xffffffffffffffd0 + -(extraout_x13 + 0xfU & 0xfffffffffffffff0),
             (long)unaff_x20 + (long)*(int *)(param_3 + 0x1c),extraout_x8);
  func_0x000198105070(param_1,uVar1,
                      &stack0xffffffffffffffd0 + -(extraout_x13 + 0xfU & 0xfffffffffffffff0));
  return;
}


//######## TextSpecSchemaModifier (spec) 0x195ef3da8
// === 195ef3cd8 spec

/* WARNING: Removing unreachable block (ram,0x000195ef3d1c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef3cd8(undefined8 param_1,undefined8 param_2,long param_3)
{
  (*_DAT_1e2125200)();
  uVar1 = *unaff_x20;
  (**(code **)(extraout_x12 + 0x10))
            (&stack0xffffffffffffffd0 + -(extraout_x13 + 0xfU & 0xfffffffffffffff0),
             (long)unaff_x20 + (long)*(int *)(param_3 + 0x1c),extraout_x8);
  func_0x000198105070(param_1,uVar1,
                      &stack0xffffffffffffffd0 + -(extraout_x13 + 0xfU & 0xfffffffffffffff0));
  return;
}


//######## ApplyPostProcessing.anon.ApplyStrength (params) 0x195ef49fc
// === 195ef49fc params

void FUN_195ef49fc(void)
{
  FUN_195ef3dac(*unaff_x20);
  return;
}


//######## ApplyPostProcessing.anon.DisableHDR (params) 0x195ef4a04
// === 195ef4a04 params

void FUN_195ef4a04(void)
{
  FUN_195e7cb60();
  return;
}


//######## DisableUncessaryLayers (params) 0x195ef4a28
// === 195ef4a28 params

void FUN_195ef4a28(undefined8 param_1,undefined8 param_2)
{
  FUN_195ebd0f0(param_2);
  return;
}


//######## ApplyAdaptivityReducedTransparency (spec) 0x195ef6adc
// === 195ef8020 spec

/* WARNING: Removing unreachable block (ram,0x000195ef8084) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef8020(long param_1,long param_2)
{
  uint5 uVar4;
  undefined1 auStack_220 [80];
  lVar6 = 0;
  func_0x000198120110();
  (*_DAT_1e2125200)(*(undefined8 *)(*(long *)(lVar6 + -8) + 0x40));
  local_230 = (long)&local_230 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uStack_c8 = <+0x6a8>;
  uVar9 = <+0x6c0>;
  uVar10 = <+0x6c8>;
  uVar11 = <+0x6d0>;
  uVar4 = <+0x6d8>;
  uVar2 = <+0x6dd>;
  uStack_88 = <+0x698>;
  local_90 = <+0x690>;
  local_80 = <+0x6a0>;
  if (((uStack_c8 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    puVar1 = (undefined8 *)(<+0x690>);
    uStack_128 = <+0x698>;
    local_130 = *puVar1;
    local_120 = <+0x6a0>;
    uStack_108 = <+0x6b8>;
    local_110 = <+0x6b0>;
    local_e8 = (undefined4)uVar4;
    local_e4 = (undefined1)(uVar4 >> 0x20);
    local_228 = param_2;
    uStack_118 = uStack_c8;
    local_100 = uVar9;
    uStack_f8 = uVar10;
    local_f0 = uVar11;
    local_e3 = uVar2;
    FUN_195ef7fcc(&local_130,&local_e0);
    FUN_195ef0f04(uVar9,uVar10,uVar11,(ulong)uVar4,uVar2);
    uStack_d8 = uStack_88;
    local_e0 = local_90;
    local_d0 = local_80;
    local_a8 = 0;
    uStack_a2 = 0;
    uStack_a0 = 0;
    local_b0 = 0.45f;
    uStack_9a = 0;
    uStack_98 = 0;
    uStack_bc = -1f;
    uStack_b4 = 1f;
    lVar7 = 0;
    FUN_195f3c68c();
    lVar5 = local_230;
    iVar3 = *(int *)(lVar7 + 0x18);
    lVar7 = local_230;
    (**(code **)(extraout_x12 + 0x68))(local_230,*_DAT_1e017dd58,lVar6);
    FUN_195e7d9c0();
    uVar8 = local_228 + iVar3;
    func_0x0001980ff320(uVar8,lVar5,lVar6,lVar7);
    (**(code **)(extraout_x12 + 8))(lVar5,lVar6);
    local_c0 = 0.2f;
    if ((uVar8 & 1) == 0) {
      local_c0 = 0.9f;
    }
    uStack_1a8 = CONCAT44(uStack_b4,local_c0);
    local_1b0 = CONCAT44(uStack_bc,local_c0);
    uStack_198 = local_a8;
    uStack_1a0 = local_b0;
    uStack_18a = CONCAT62(uStack_98,uStack_9a);
    local_192 = uStack_a2;
    uStack_190 = uStack_a0;
    uStack_1c8 = uStack_d8;
    local_1d0 = local_e0;
    uStack_1b8 = uStack_c8;
    uStack_1c0 = local_d0;
    uStack_158 = <+0x6b8>;
    local_160 = <+0x6b0>;
    uStack_150 = <+0x6c0>;
    uStack_148 = (undefined6)<+0x6c8>;
    uStack_13a = <+0x6d6>;
    local_142 = (undefined2)<+0x6ce>;
    uStack_140 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    uStack_178 = <+0x698>;
    local_180 = *puVar1;
    uStack_168 = <+0x6a8>;
    uStack_170 = <+0x6a0>;
    uStack_b8 = local_c0;
    FUN_195ef7fcc(&local_1d0,auStack_220);
    FUN_195dabb50(&local_180,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
    <+0x6b8> = CONCAT44(uStack_b4,uStack_b8);
    <+0x6b0> = CONCAT44(uStack_bc,local_c0);
    <+0x6c8> = CONCAT26(uStack_a2,local_a8);
    <+0x6c0> = local_b0;
    <+0x6d6> = CONCAT62(uStack_98,uStack_9a);
    <+0x6ce> = CONCAT62(uStack_a0,uStack_a2);
    <+0x698> = uStack_d8;
    *puVar1 = local_e0;
    <+0x6a8> = uStack_c8;
    <+0x6a0> = local_d0;
    FUN_195ef82d0(&local_e0);
  }
  return;
}


//######## ApplyAdaptivityIncreasedContrast (spec) 0x195ef6c08
// === 195ef7d88 spec

/* WARNING: Removing unreachable block (ram,0x000195ef7df4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef7d88(long param_1,long param_2)
{
  undefined1 auStack_180 [80];
  lVar5 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar10 = (long)&local_1d0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uStack_a8 = <+0x698>;
  local_b0 = <+0x690>;
  local_a0 = <+0x6a0>;
  uVar11 = <+0x6a8>;
  fVar13 = <+0x6b0>;
  uVar12 = <+0x6b4>;
  fVar14 = <+0x6b8>;
  puVar1 = (undefined8 *)(<+0x6bc>);
  uStack_d8 = <+0x6c4>;
  local_e0 = *puVar1;
  uStack_c8 = <+0x6d4>;
  uStack_d0 = <+0x6cc>;
  local_c0 = <+0x6dc>;
  if (((uVar11 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    puVar2 = (undefined8 *)(<+0x690>);
    uStack_198 = <+0x698>;
    local_1a0 = *puVar2;
    local_190 = <+0x6a0>;
    uStack_1c8 = <+0x6c4>;
    local_1d0 = *puVar1;
    uStack_1b8 = <+0x6d4>;
    uStack_1c0 = <+0x6cc>;
    local_1b0 = <+0x6dc>;
    lVar6 = 0;
    FUN_195f3c68c();
    iVar3 = *(int *)(lVar6 + 0x18);
    (**(code **)(lVar9 + 0x68))(lVar10,*_DAT_1e017dd58,lVar5);
    uStack_128 = uStack_a8;
    local_130 = local_b0;
    local_120 = local_a0;
    uStack_fc = uStack_d8;
    local_104 = local_e0;
    uStack_ec = uStack_c8;
    local_f4 = uStack_d0;
    local_e4 = local_c0;
    puVar7 = &local_130;
    uStack_118 = uVar11;
    local_110 = fVar13;
    uStack_10c = uVar12;
    local_108 = fVar14;
    FUN_195ef7fcc(puVar7,auStack_180);
    FUN_195e7d9c0();
    uVar8 = param_2 + iVar3;
    func_0x0001980ff320(uVar8,lVar10,lVar5,puVar7);
    (**(code **)(lVar9 + 8))(lVar10,lVar5);
    fVar4 = fVar14 + -0.5;
    if ((uVar8 & 1) == 0) {
      fVar13 = fVar13 + 0.5;
      fVar4 = fVar14;
    }
    FUN_195dabb50(puVar2,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
    <+0x698> = uStack_198;
    *puVar2 = local_1a0;
    <+0x6a0> = local_190;
    <+0x6a8> = uVar11;
    <+0x6b0> = fVar13;
    <+0x6b4> = uVar12;
    <+0x6b8> = fVar4;
    <+0x6c4> = uStack_1c8;
    *puVar1 = local_1d0;
    <+0x6d4> = uStack_1b8;
    <+0x6cc> = uStack_1c0;
    <+0x6dc> = local_1b0;
  }
  return;
}


//######## ApplyReducedMotion (spec) 0x195ef6d34
// === 195ef6d34 spec

void FUN_195ef6d34(long param_1)
{
  <refraction.normalizedInnerHeight> = 0;
  if (<+0x191> == '\0') {
    <blur.blurRadius> = (ulong)(uint)(<blur.blurRadius> * 4.0);
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  else if (<+0x191> == '\x02') {
    fVar1 = (float)<+0x178> * (float){d 2};
    fVar2 = (float)((ulong)<+0x178> >> 0x20) *
            (float)((ulong){d 2} >> 0x20);
    fVar3 = fVar1;
    if (fVar1 <= fVar2) {
      fVar3 = fVar2;
    }
    <+0x178> = fVar1;
    <+0x17c> = fVar3;
    <+0x180> = <+0x180> & 0xffffffffff;
    <+0x191> = 2;
    return;
  }
  return;
}


//######## ApplyReducedTransparency (spec) 0x195ef7300
// === 195ef7300 spec

void FUN_195ef7300(undefined8 param_1,undefined8 param_2)
{
  uVar1 = 0x100;
  if (unaff_x20[1] == 0) {
    uVar1 = 0;
  }
  FUN_195ef6da8(param_1,param_2,uVar1 | *unaff_x20);
  return;
}


//######## ApplyIncreasedContrast (spec) 0x195ef77a0
// === 195ef77a0 spec

void FUN_195ef77a0(undefined8 param_1,undefined8 param_2)
{
  FUN_195ef731c(param_1,param_2,*unaff_x20);
  return;
}


//######## ApplyShapeOutlineBase (spec) 0x195ef7b38
// === 195ef7b38 spec

void FUN_195ef7b38(undefined8 param_1,undefined8 param_2)
{
  uVar1 = 0x10000;
  if (unaff_x20[2] == 0) {
    uVar1 = 0;
  }
  uVar2 = 0x100;
  if (unaff_x20[1] == 0) {
    uVar2 = 0;
  }
  FUN_195ef77a8(param_1,param_2,uVar2 | *unaff_x20 | uVar1);
  return;
}


//######## ApplyShapeOutlineBorders (spec) 0x195ef7b68
// === 195ef7b6c spec

/* WARNING: Removing unreachable block (ram,0x000195ef7bc0) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef7b6c(long param_1,long param_2)
{
  ushort *puVar2;
  undefined1 auVar5 [16];
  undefined1 auVar33 [16];
  lVar6 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar12 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195f3c68c();
  iVar4 = *(int *)(lVar7 + 0x18);
  puVar8 = puVar12;
  (**(code **)(lVar10 + 0x68))(puVar12,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  uVar9 = param_2 + iVar4;
  func_0x0001980ff320(uVar9,puVar12,lVar6,puVar8);
  (**(code **)(lVar10 + 8))(puVar12,lVar6);
  lVar6 = 0;
  FUN_195ed0900();
  plVar1 = (long *)(param_2 + *(int *)(lVar6 + 0x1c));
  cVar3 = (char)plVar1[5];
  if (cVar3 < -0x60) {
    lVar11 = *plVar1;
    lVar10 = plVar1[4];
    lVar7 = plVar1[3];
    bVar13 = *(byte *)(plVar1 + 1) | (byte)lVar7;
    bVar15 = *(byte *)((long)plVar1 + 9) | (byte)((ulong)lVar7 >> 8);
    bVar17 = *(byte *)((long)plVar1 + 10) | (byte)((ulong)lVar7 >> 0x10);
    bVar19 = *(byte *)((long)plVar1 + 0xb) | (byte)((ulong)lVar7 >> 0x18);
    bVar21 = *(byte *)((long)plVar1 + 0xc) | (byte)((ulong)lVar7 >> 0x20);
    bVar22 = *(byte *)((long)plVar1 + 0xd) | (byte)((ulong)lVar7 >> 0x28);
    bVar23 = *(byte *)((long)plVar1 + 0xe) | (byte)((ulong)lVar7 >> 0x30);
    bVar24 = *(byte *)((long)plVar1 + 0xf) | (byte)((ulong)lVar7 >> 0x38);
    bVar25 = *(byte *)(plVar1 + 2) | (byte)lVar10;
    bVar26 = *(byte *)((long)plVar1 + 0x11) | (byte)((ulong)lVar10 >> 8);
    bVar27 = *(byte *)((long)plVar1 + 0x12) | (byte)((ulong)lVar10 >> 0x10);
    bVar28 = *(byte *)((long)plVar1 + 0x13) | (byte)((ulong)lVar10 >> 0x18);
    bVar29 = *(byte *)((long)plVar1 + 0x14) | (byte)((ulong)lVar10 >> 0x20);
    bVar30 = *(byte *)((long)plVar1 + 0x15) | (byte)((ulong)lVar10 >> 0x28);
    bVar31 = *(byte *)((long)plVar1 + 0x16) | (byte)((ulong)lVar10 >> 0x30);
    bVar32 = *(byte *)((long)plVar1 + 0x17) | (byte)((ulong)lVar10 >> 0x38);
    auVar33[1] = bVar15;
    auVar33[0] = bVar13;
    auVar33[2] = bVar17;
    auVar33[3] = bVar19;
    auVar33[4] = bVar21;
    auVar33[5] = bVar22;
    auVar33[6] = bVar23;
    auVar33[7] = bVar24;
    auVar33[8] = bVar25;
    auVar33[9] = bVar26;
    auVar33[10] = bVar27;
    auVar33[0xb] = bVar28;
    auVar33[0xc] = bVar29;
    auVar33[0xd] = bVar30;
    auVar33[0xe] = bVar31;
    auVar33[0xf] = bVar32;
    auVar5[1] = bVar15;
    auVar5[0] = bVar13;
    auVar5[2] = bVar17;
    auVar5[3] = bVar19;
    auVar5[4] = bVar21;
    auVar5[5] = bVar22;
    auVar5[6] = bVar23;
    auVar5[7] = bVar24;
    auVar5[8] = bVar25;
    auVar5[9] = bVar26;
    auVar5[10] = bVar27;
    auVar5[0xb] = bVar28;
    auVar5[0xc] = bVar29;
    auVar5[0xd] = bVar30;
    auVar5[0xe] = bVar31;
    auVar5[0xf] = bVar32;
    auVar33 = NEON_ext(auVar33,auVar5,8,1);
    lVar7 = CONCAT17(bVar24 | auVar33[7],
                     CONCAT16(bVar23 | auVar33[6],
                              CONCAT15(bVar22 | auVar33[5],
                                       CONCAT14(bVar21 | auVar33[4],
                                                CONCAT13(bVar19 | auVar33[3],
                                                         CONCAT12(bVar17 | auVar33[2],
                                                                  CONCAT11(bVar15 | auVar33[1],
                                                                           bVar13 | auVar33[0]))))))
                    );
    if ((cVar3 == -0x80 && lVar11 == 3) && lVar7 == 0) {
      puVar2 = (ushort *)(param_2 + *(int *)(lVar6 + 0x20));
      uVar14 = 0;
      uVar16 = 0;
      uVar18 = 0;
      if (2 < *puVar2 - 1 || (char)puVar2[1] != '\x01') {
        uVar14 = 0x66;
        uVar16 = 0x66;
        uVar18 = 0x66;
      }
      uVar20 = 0x3f;
      goto LAB_195ef7d60;
    }
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0x80;
    uVar20 = 0x3f;
    if ((cVar3 == -0x80 && lVar11 == 8) && lVar7 == 0) goto LAB_195ef7d60;
    if ((((cVar3 == -0x80 && lVar11 == 10) && lVar7 == 0) ||
        ((cVar3 == -0x80 && lVar11 == 0xb) && lVar7 == 0)) ||
       ((cVar3 == -0x80 && lVar11 == 0xf) && lVar7 == 0)) {
      uVar14 = 0x66;
      uVar16 = 0x66;
      uVar18 = 0x66;
      uVar20 = 0x3f;
      goto LAB_195ef7d60;
    }
  }
  uVar18 = 0xcc;
  if ((uVar9 & 1) == 0) {
    uVar18 = 0x4c;
  }
  uVar16 = 0xcc;
  uVar14 = 0xcd;
  uVar20 = 0x3e;
LAB_195ef7d60:
  <highlights.keyOpacity> = CONCAT13(uVar20,CONCAT12(uVar18,CONCAT11(uVar16,uVar14)));
  <highlights.fillOpacity> = CONCAT13(uVar20,CONCAT12(uVar18,CONCAT11(uVar16,uVar14)));
  <highlights.white> = 1f;
  return;
}


//######## BaseSpec (spec) 0x195ef8ba0
// === 195ef8ba4 spec

/* WARNING: Removing unreachable block (ram,0x000195ef8c64) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef8ba4(undefined8 <backdropScale>,double *param_2)
{
  undefined1 auStack_3f8 [4];
  undefined1 auStack_3f4 [404];
  undefined1 auStack_260 [408];
  puVar5 = &DAT_1eda3a940;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar5 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  uVar9 = (long)&local_4e0 - extraout_x8;
  lVar6 = 0;
  func_0x0001981217d0();
  lVar10 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  uVar11 = uVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ee8970(param_1);
  uVar29 = *_DAT_1e01830d0;
  pcVar12 = *(code **)(lVar10 + 0x68);
  (*pcVar12)(uVar11,uVar29,lVar6);
  uVar26 = 0.1f;
  uVar27 = 0;
  uVar14 = 0;
  uVar18 = 0;
  uVar22 = 0;
  uVar23 = 0;
  uVar24 = 0;
  uVar25 = 0;
  uVar7 = uVar11;
  func_0x0001981218c0();
  local_4e0 = uVar26;
  uStack_4d8 = uVar27;
  uStack_4d0 = uVar22;
  uStack_4c8 = uVar23;
  local_4c0 = uVar24;
  uStack_4b8 = uVar25;
  uStack_4b0 = uVar14;
  uStack_4a8 = uVar18;
  FUN_195ed53f0();
  (*pcVar12)(uVar11,uVar29,lVar6);
  uVar26 = 0.4f;
  uVar27 = 0;
  uVar14 = 1f;
  uVar18 = 0;
  uVar22 = 1f;
  uVar23 = 0;
  uVar24 = 1f;
  uVar25 = 0;
  func_0x0001981218c0();
  local_480 = uVar26;
  uStack_478 = uVar27;
  uStack_470 = uVar22;
  uStack_468 = uVar23;
  local_460 = uVar24;
  uStack_458 = uVar25;
  uStack_450 = uVar14;
  uStack_448 = uVar18;
  FUN_195ed53f0();
  uVar8 = uVar11;
  FUN_195ed53f0();
  lVar6 = 0;
  func_0x000198120110();
  (**(code **)(*(long *)(lVar6 + -8) + 0x38))(uVar9,1,1,lVar6);
  FUN_195eef0b0(auStack_260,param_2,uVar9);
  FUN_195ef92bc();
  FUN_195ed53f0();
  if ((uVar9 & 1) == 0) {
    local_4a0 = 0;
    uStack_498 = 0;
    uStack_488 = 0;
    local_490 = 0.0;
    dVar28 = 0.0;
    uVar14 = 0;
  }
  else {
    dVar15 = *param_2;
    uVar14 = -0.3;
    dVar28 = dVar15 * -1.6;
    if (0.5 <= dVar15) {
      uVar14 = -0.25;
      dVar28 = -dVar15;
    }
    local_490 = -dVar28;
    uStack_488 = 1.309;
    local_4a0 = {d 1.309};
    uStack_498 = {d 0.4};
  }
  if (DAT_1eda3b6c8 != -1) {
    func_0x000198104ff0(&DAT_1eda3b6c8,FUN_195eeb6ec);
  }
  uStack_418 = uRam00000001eda465a0;
  local_420 = _DAT_1eda46598;
  uStack_408 = uRam00000001eda465b0;
  uStack_410 = _DAT_1eda465a8;
  local_400 = DAT_1eda465b8;
  uStack_438 = uRam00000001eda46580;
  local_440 = _DAT_1eda46578;
  uStack_428 = uRam00000001eda46590;
  uStack_430 = _DAT_1eda46588;
  lVar6 = 0;
  FUN_195ed0900();
  bVar4 = *(byte *)((long)param_2 + (long)*(int *)(lVar6 + 0x2c)) < 2;
  uVar21 = 0;
  uVar29 = uVar21;
  if (!bVar4) {
    uVar29 = -5f;
  }
  uVar18 = 0;
  if (!bVar4) {
    uVar21 = 1f;
    uVar18 = 1.5708;
  }
  uVar22 = 64;
  if ((uVar11 & 1) == 0) {
    uVar22 = 48;
  }
  uVar23 = 64;
  if ((uVar8 & 1) == 0) {
    uVar23 = 48;
  }
  uVar24 = 64;
  if ((uVar7 & 1) == 0) {
    uVar24 = 48;
  }
  FUN_195eda2a0(&local_c8,param_2);
  func_0x000198104610(auStack_3f4,auStack_260,0x194);
  uVar27 = {d 0.625};
  uVar26 = {d 0.4};
  uVar25 = {f 0.25, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar25;
  <shadow.normalizedAmount> = uVar27;
  <shadow.normalizedHeight> = uVar26;
  <shadow.blurRadius> = 40;
  <shadow.opacity> = uVar22;
  uVar26 = {d 160};
  uVar25 = {d 0};
  uVar22 = {f 0, 1.4013e-45};
  <+0x38> = {d 0.000488281};
  <+0x30> = uVar26;
  <+0x48> = uVar25;
  <+0x40> = uVar22;
  <+0x50> = 0x201;
  <shadow.shadowRadius> = 24;
  <+0x91> = 0;
  uVar26 = {d 0};
  <shadow.offset.1> = {d 8};
  <shadow.offset.0> = uVar26;
  <shadow.ycc.black> = {d 0.0078125};
  <shadow.ycc.saturation> = 1.2f;
  <shadow.ycc.normalFill.b> =
       CONCAT17((char)((ulong)local_4e0 >> 0x18),
                CONCAT16((char)((ulong)local_4e0 >> 0x10),
                         CONCAT15((char)((ulong)local_4e0 >> 8),
                                  CONCAT14((char)local_4e0,(int)local_4c0))));
  <shadow.ycc.normalFill.r> =
       CONCAT17((char)((ulong)uStack_4d0 >> 0x18),
                CONCAT16((char)((ulong)uStack_4d0 >> 0x10),
                         CONCAT15((char)((ulong)uStack_4d0 >> 8),
                                  CONCAT14((char)uStack_4d0,(int)uStack_4b0))));
  <shadow.ycc.normalFill?nil> = 0;
  <shadow.ycc.dodgeFill.b> = 0;
  <shadow.ycc.dodgeFill.r> = 0;
  <shadow.ycc.dodgeFill?nil> = 1;
  <shadow.ycc.burnFill.b> = 0;
  <shadow.ycc.burnFill.r> = 0;
  <shadow.ycc.burnFill?nil> = 1;
  <shadow.vibrancyContribution> = uVar23;
  uVar23 = {d 160};
  <+0x100> = {d 0};
  <+0xf8> = uVar23;
  <+0x108> = 1;
  <+0x110> = 0;
  <+0x118> = 1;
  <+0x120> = 0;
  <+0x128> = 0x201;
  uVar23 = {d 0.0078125};
  <blur.opacities.1> = {d 3.05176e-05};
  <blur.opacity> = uVar23;
  <blur.opacities.3> = 3.05176e-05;
  <blur.distances.0.kind> = 1;
  <blur.distances.1.v> = -1f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.blurRadius> = 48;
  <+0x170> = 120;
  <+0x178> = {d 131072};
  <+0x188> = uVar25;
  <+0x180> = uVar22;
  <+0x190> = 0x201;
  <blur.outerRefractionBlurRadius> = 0;
  <blur.outerRefractionBlurRadius?nil> = 1;
  uVar27 = {d -0.8};
  uVar26 = {d 20};
  uVar23 = {d 0.25};
  <refraction.innerHeightRange.lo> = {d 0};
  <refraction.normalizedInnerHeight> = uVar23;
  <refraction.normalizedInnerAmount> = uVar27;
  <refraction.innerHeightRange.hi> = uVar26;
  uVar27 = {f 0, nan};
  uVar26 = {d 0.125};
  uVar23 = {d -60};
  <refraction.innerAmountRange.hi> = {f 0, nan};
  <refraction.innerAmountRange.lo> = uVar23;
  <refraction.outerHeightRange.lo> = uVar27;
  <refraction.normalizedOuterHeight> = uVar26;
  uVar27 = {f 0, nan};
  uVar26 = {f 0, nan};
  uVar23 = {f 0, nan};
  <refraction.normalizedOuterAmount> = {d 0.2};
  <refraction.outerHeightRange.hi> = uVar23;
  <refraction.outerAmountRange.hi> = uVar27;
  <refraction.outerAmountRange.lo> = uVar26;
  <refraction.outerOpacity> = 1f;
  <edgeBleed.opacity> = uVar24;
  <+0x210> = 160;
  <+0x218> = {d 3.05176e-05};
  <+0x228> = uVar25;
  <+0x220> = uVar22;
  <+0x230> = 0x201;
  <edgeBleed.normalizedHeight> = 0.35;
  <edgeBleed.normalizedBlurRadius> = 0.35;
  <edgeBleed.normalizedAmount> = 0.35;
  <edgeBleed.maxBlurRadius> = 120;
  <edgeBleed.ycc.black> = {d 0.0078125};
  <edgeBleed.ycc.saturation> = 1.2f;
  <edgeBleed.ycc.normalFill.b> = 0;
  <edgeBleed.ycc.normalFill.r> = 0;
  <edgeBleed.ycc.normalFill?nil> = 1;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.burnFill?nil> = 0x101;
  uVar22 = {d 3.05176e-05};
  <faceEffect.ycc.white> = {d 0.0078125};
  <faceEffect.opacity> = uVar22;
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((ulong)local_480 >> 0x18),
                CONCAT16((char)((ulong)local_480 >> 0x10),
                         CONCAT15((char)((ulong)local_480 >> 8),
                                  CONCAT14((char)local_480,(int)local_460))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((ulong)uStack_470 >> 0x18),
                CONCAT16((char)((ulong)uStack_470 >> 0x10),
                         CONCAT15((char)((ulong)uStack_470 >> 8),
                                  CONCAT14((char)uStack_470,(int)uStack_450))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  func_0x000198104610(<+0x2f4>,auStack_3f8,0x198);
  <ringShadow.maskAmount> = 0;
  <blurFill.darkenOpacity> = 0;
  <blurFill.blurRadius> = 0;
  <ringShadow.verticalOffset> = 0;
  <ringShadow.blurRadius> = 0;
  <ringShadow.strokeWidth> = 0;
  <ringShadow.opacity> = 0;
  <darkSpecular.spread> = uStack_488;
  <darkSpecular.height> = local_490;
  <darkSpecular.amount> = uStack_498;
  <darkSpecular.spreadSDR> = local_4a0;
  <darkSpecular.effectOffset> = dVar28;
  <darkSpecular.colorBias> = uVar14;
  <+0x4f8> = {d 0.0015625};
  <+0x500> = 18;
  <+0x539> = 0;
  <+0x540> = 50;
  <+0x579> = 0;
  <+0x580> = -50;
  <+0x5b9> = 0;
  uVar14 = {d 0.2};
  <+0x5c8> = {d -0.25};
  <+0x5c0> = uVar14;
  uVar14 = {d 0};
  <+0x5d8> = {d 0.0526316};
  <+0x5d0> = uVar14;
  uVar14 = {d 0.555556};
  <+0x5e8> = {d -0.2};
  <+0x5e0> = uVar14;
  uVar14 = {d 0};
  <+0x5f8> = {d -0.261799};
  <+0x5f0> = uVar14;
  <+0x600> = {f 1, 0};
  <+0x648> = local_400;
  <+0x630> = uStack_418;
  <+0x628> = local_420;
  <+0x640> = uStack_408;
  <+0x638> = uStack_410;
  <+0x610> = uStack_438;
  <+0x608> = local_440;
  <+0x620> = uStack_428;
  <+0x618> = uStack_430;
  iVar13 = -(uint)(-1 < (int)((uint)CONCAT12(bVar4,(ushort)bVar4) << 0x1f));
  iVar16 = -(uint)(-1 < (int)((uint)bVar4 << 0x1f));
  iVar17 = -(uint)(-1 < (int)((uint)bVar4 << 0x1f));
  iVar19 = -(uint)(-1 < (int)((uint)bVar4 << 0x1f));
  bVar20 = (byte){f 16, -16};
  uVar7 = (ulong){f 16, -16} >> 8;
  uVar8 = (ulong){f 16, -16} >> 0x10;
  uVar11 = (ulong){f 16, -16} >> 0x18;
  uVar9 = (ulong){f 16, -16} >> 0x20;
  uVar1 = (ulong){f 16, -16} >> 0x28;
  uVar2 = (ulong){f 16, -16} >> 0x30;
  uVar3 = (ulong){f 16, -16} >> 0x38;
  <+0x658> =
       CONCAT17((byte)((uint)iVar19 >> 0x18) & (byte)((ulong){d 19660.8} >> 0x38),
                CONCAT16((byte)((uint)iVar19 >> 0x10) & (byte)((ulong){d 19660.8} >> 0x30),
                         CONCAT15((byte)((uint)iVar19 >> 8) & (byte)((ulong){d 19660.8} >> 0x28),
                                  CONCAT14((byte)iVar19 & (byte)((ulong){d 19660.8} >> 0x20),
                                           CONCAT13((byte)((uint)iVar17 >> 0x18) &
                                                    (byte)((ulong){d 19660.8} >> 0x18),
                                                    CONCAT12((byte)((uint)iVar17 >> 0x10) &
                                                             (byte)((ulong){d 19660.8} >> 0x10),
                                                             CONCAT11((byte)((uint)iVar17 >> 8) &
                                                                      (byte)((ulong){d 19660.8}
                                                                            >> 8),
                                                                      (byte)iVar17 &
                                                                      (byte){d 19660.8})))))));
  <+0x650> =
       CONCAT17((byte)((uint)iVar16 >> 0x18) & (byte)uVar3,
                CONCAT16((byte)((uint)iVar16 >> 0x10) & (byte)uVar2,
                         CONCAT15((byte)((uint)iVar16 >> 8) & (byte)uVar1,
                                  CONCAT14((byte)iVar16 & (byte)uVar9,
                                           CONCAT13((byte)((uint)iVar13 >> 0x18) & (byte)uVar11,
                                                    CONCAT12((byte)((uint)iVar13 >> 0x10) &
                                                             (byte)uVar8,
                                                             CONCAT11((byte)((uint)iVar13 >> 8) &
                                                                      (byte)uVar7,
                                                                      (byte)iVar13 & bVar20)))))));
  <+0x660> = uVar29;
  <+0x664> = 0;
  <+0x668> = uVar18;
  <+0x670> = 0;
  <+0x678> = 0;
  <+0x67c> = uVar21;
  <+0x6a0> = 0;
  <+0x698> = 0;
  <+0x690> = 0;
  <+0x688> = 0;
  <+0x680> = 0;
  <+0x6a8> = 0xff0000000000;
  <+0x6b8> = 0;
  <+0x6b0> = 0;
  <+0x6c8> = 0;
  <+0x6c0> = 0;
  <+0x6d6> = 0;
  <+0x6ce> = 0;
  <+0x6e0> = local_c8;
  <+0x6e8> = local_c0;
  <+0x6f8> = uStack_b0;
  <+0x6f0> = local_b8;
  return;
}


//######## CameraRecipe.Modifier (spec) 0x195ef951c
// === 195efac28 spec

/* WARNING: Removing unreachable block (ram,0x000195efac90) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efac28(undefined8 <backdropScale>,long param_2)
{
  undefined1 auStack_80 [8];
  uVar5 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(uVar5 - 8);
  uVar6 = uVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar11 = auStack_80 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar6 & 1) == 0) {
    <blurFill.darkenOpacity> = 0;
    <blurFill.blurRadius> = 0;
    <ringShadow.verticalOffset> = 0;
    <ringShadow.opacity> = 0;
    <ringShadow.blurRadius> = 0;
    <ringShadow.strokeWidth> = 0;
    <darkSpecular.height> = 0;
    <ringShadow.maskAmount> = 0;
    <darkSpecular.spreadSDR> = 0;
    <darkSpecular.spread> = 0;
    <darkSpecular.effectOffset> = 0;
    <darkSpecular.amount> = 0;
    <darkSpecular.colorBias> = 0;
    (**(code **)(lVar9 + 0x68))(puVar11,*_DAT_1e01830d0,uVar5);
    uVar12 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar17 = 0;
    func_0x0001981218c0(puVar11);
    uVar3 = {f 1, 0.2};
    <faceEffect.ycc.white> = {d 0.000292969};
    <faceEffect.opacity> = uVar3;
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar17 >> 0x18),
                  CONCAT16((char)((uint)uVar17 >> 0x10),
                           CONCAT15((char)((uint)uVar17 >> 8),CONCAT14((char)uVar17,uVar16))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar14 >> 0x18),
                  CONCAT16((char)((uint)uVar14 >> 0x10),
                           CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar12))));
    <faceEffect.ycc.normalFill?nil> = 0;
    <faceEffect.ycc.dodgeFill.b> = 0;
    <faceEffect.ycc.dodgeFill.r> = 0;
    <faceEffect.ycc.dodgeFill?nil> = 1;
    <faceEffect.ycc.burnFill.b> = 0;
    <faceEffect.ycc.burnFill.r> = 0;
    <faceEffect.ycc.burnFill?nil> = 1;
    <faceEffect.maxLuminance> = 0.0078125;
    FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    uVar3 = {d 48};
    <+0x170> = {d 160};
    <blur.blurRadius> = uVar3;
    <+0x178> = {d 128};
    uVar3 = {f 0, 1.4013e-45};
    <+0x188> = {d 0};
    <+0x180> = uVar3;
    <+0x190> = 0x201;
    goto LAB_195efb090;
  }
  if (DAT_1eda3a158 != -1) {
    func_0x000198104ff0(&DAT_1eda3a158,FUN_195f38fd0);
  }
  lVar4 = DAT_1eda45918;
  if (*(long *)(DAT_1eda45918 + 0x10) == 0) {
    lVar10 = *(long *)(DAT_1eda45918 + 0xc0);
    if (*(char *)(DAT_1eda45918 + 200) != '\x01') goto LAB_195efae70;
LAB_195efaeb8:
    <ringShadow.maskAmount> = 0;
    <blurFill.darkenOpacity> = 0;
    <blurFill.blurRadius> = 0;
LAB_195efaec8:
    <ringShadow.verticalOffset> = 0;
    <ringShadow.blurRadius> = 0;
    <ringShadow.strokeWidth> = 0;
    <ringShadow.opacity> = 0;
  }
  else {
    puVar7 = &{f 2.24672e+13, 0};
    func_0x000198104dd0(&{f 2.24672e+13, 0});
    local_78 = lVar4;
    puVar8 = puVar7;
    FUN_195e79d24(DAT_1eda39d38);
    func_0x0001980fe060(&local_78,puVar7,puVar8);
    func_0x000198105020(puVar7);
    func_0x0001981048a0(lVar4 + 0x20);
    lVar10 = *(long *)(lVar4 + 0x58);
    cVar2 = *(char *)(lVar4 + 0x60);
    func_0x0001981048b0(lVar4 + 0x20);
    if (cVar2 == '\x01') goto LAB_195efaeb8;
LAB_195efae70:
    if (lVar10 == 2) {
      <ringShadow.maskAmount> = 0;
      goto LAB_195efaec8;
    }
    if (lVar10 == 1) goto LAB_195efaeb8;
    if (lVar10 == 0) {
      <blurFill.normalOpacity> = 0;
      <blurFill.lightenOpacity> = 0;
      <highlights.diffuseAmountScale> = 0;
      <highlights.diffuseHeightScale> = 0;
      <ringShadow.verticalOffset> = 0;
      <ringShadow.opacity> = 0;
      <ringShadow.blurRadius> = 0;
      <ringShadow.strokeWidth> = 0;
      <darkSpecular.height> = 0;
      <ringShadow.maskAmount> = 0;
      <darkSpecular.spreadSDR> = 0;
      <darkSpecular.spread> = 0;
      <darkSpecular.effectOffset> = 0;
      <darkSpecular.amount> = 0;
      <darkSpecular.colorBias> = 0;
    }
  }
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar3 = {f 0.25, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar3;
  (**(code **)(lVar9 + 0x68))(puVar11,*_DAT_1e01830d0,uVar5);
  uVar16 = 0.08f;
  uVar14 = 0.08f;
  uVar17 = 0.4f;
  uVar12 = uVar16;
  func_0x0001981218c0(puVar11);
  uVar3 = {f 1, 0.15};
  <faceEffect.ycc.white> = {d 9.76563e-05};
  <faceEffect.opacity> = uVar3;
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar17 >> 0x18),
                CONCAT16((char)((uint)uVar17 >> 0x10),
                         CONCAT15((char)((uint)uVar17 >> 8),CONCAT14((char)uVar17,uVar12))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((uint)uVar14 >> 0x18),
                CONCAT16((char)((uint)uVar14 >> 0x10),
                         CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar16))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  <highlights.keyYCC.black> = 0.15f;
  <highlights.keyYCC.white> = {d 0.025};
  <highlights.keyYCC.normalFill.b> = 0;
  <highlights.keyYCC.normalFill.r> = 0;
  <highlights.keyYCC.normalFill?nil> = 1;
  <highlights.keyYCC.burnFill.b> = 0;
  <highlights.keyYCC.burnFill.r> = 0;
  <highlights.keyYCC.burnFill?nil> = 1;
  <+0x411> = <+0x3c9>;
  <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
  <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
  <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
  <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
  <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
  <highlights.fillYCC.black> = <highlights.keyYCC.black>;
  <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
  <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  lVar9 = 0;
  FUN_195f3c68c();
  pfVar1 = (float *)(param_2 + *(int *)(lVar9 + 0x70));
  if ((*(char *)(pfVar1 + 1) == '\x01') || (fVar13 = *pfVar1, fVar13 <= 0.5)) {
    FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    fVar15 = 1.2;
  }
  else {
    fVar13 = fVar13 + -0.5;
    fVar13 = fVar13 + fVar13;
    fVar15 = 1.0;
    if (fVar13 <= 1.0) {
      fVar15 = fVar13;
    }
    fVar15 = fVar15 * 2.8 + 1.2;
    if (fVar13 < 0.0) {
      fVar15 = 1.2;
    }
    FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
  }
  <blur.blurRadius> = (ulong)(uint)fVar15;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
LAB_195efb090:
  uVar3 = {d 1.14441e-06};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar3;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  FUN_195eda468(<shadow.opacity>,<+0x30>,<+0x38>,<+0x40>,<+0x48>,<+0x50>
                ,<+0x51>);
  <refraction.outerOpacity> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x4a> = 0;
  <+0x42> = 0;
  return;
}


//######## CameraRecipe.Tweaks (params) 0x195ef9520
// === 195ef9b3c params

/* WARNING: Removing unreachable block (ram,0x000195ef9bb8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef9b3c(long param_1,undefined8 param_2)
{
  undefined1 auStack_b90 [272];
  undefined1 auStack_958 [272];
  undefined1 auStack_720 [272];
  undefined4 local_500 [2];
  lVar2 = 0;
  local_cc0 = param_2;
  func_0x0001981217d0();
  (*_DAT_1e2125200)(*(undefined8 *)(*(long *)(lVar2 + -8) + 0x40));
  lVar2 = (long)&local_d70 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  (**(code **)(extraout_x12 + 0x68))(lVar2,*_DAT_1e01830d0);
  uVar26 = 0.4f;
  uVar27 = 1f;
  uVar25 = uVar26;
  uVar19 = uVar26;
  func_0x0001981218c0(lVar2);
  local_cb0 = CONCAT44(uVar25,uVar26);
  local_cb8 = CONCAT44(uVar27,uVar19);
  lVar2 = <highlights.hdr>;
  local_ca8 = param_1;
  func_0x000198104610(&local_1b8,lVar2,0x10d);
  uVar25 = (undefined4)lVar2;
  iVar1 = (int)&local_1b8;
  FUN_195e7d8c0();
  uVar16 = local_cb0;
  uVar5 = local_cb8;
  local_cc8 = {d 0.0078125};
  if (iVar1 == 1) {
    local_14c = 0;
    local_144 = 0;
    local_1a8 = 0;
    local_d1c = 0;
    local_198 = 0;
    local_190 = 0;
    local_188 = 0;
    local_2a8 = 0;
    local_17c = 0;
    local_178 = 0;
    uVar6 = 1;
    uVar17 = 1;
    uVar7 = 1;
    local_138 = 0;
    local_130 = 0;
    local_128 = 0;
    local_120 = 0;
    local_118 = 0;
    local_1b4 = 1;
    uVar9 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar19 = 0;
    uVar26 = 0;
    uVar27 = 0;
    uVar28 = 0;
    uVar8 = 0;
    local_19c = uVar25;
    local_124 = in_w5;
  }
  else {
    uVar6 = (uint)local_164;
    local_1ba = local_161;
    local_1bc = local_163;
    uVar17 = (uint)local_150;
    local_1be = local_14d;
    local_1c0 = local_14f;
    uVar7 = (uint)local_13c;
    local_1c2 = local_139;
    local_1c4 = local_13b;
    local_1c6 = local_e9;
    local_1c8 = local_eb;
    local_1ca = local_d5;
    local_1cc = local_d7;
    local_1ce = local_c1;
    local_1d0 = local_c3;
    uVar9 = local_174;
    uVar10 = local_16c;
    uVar11 = local_160;
    uVar12 = local_158;
    uVar13 = local_1b0;
    uVar14 = local_c0;
    uVar15 = local_110;
    uVar19 = local_1b8;
    uVar26 = local_b8;
    uVar27 = local_b4;
    uVar28 = local_b0;
    uVar8 = local_ac;
    local_d1c = local_1a0;
    local_2a8 = local_180;
  }
  local_ce8 = CONCAT44(local_ce8._4_4_,local_19c);
  local_cf0 = CONCAT44(local_cf0._4_4_,local_2a8);
  local_d00 = CONCAT44(local_d00._4_4_,uVar6);
  local_28c = (undefined1)uVar6;
  local_289 = local_1ba;
  local_28b = local_1bc;
  local_d08 = CONCAT44(local_d08._4_4_,uVar17);
  local_278 = (undefined1)uVar17;
  local_277 = local_1c0;
  local_275 = local_1be;
  local_d30 = CONCAT44(local_d30._4_4_,uVar7);
  local_264 = (undefined1)uVar7;
  local_263 = local_1c4;
  local_261 = local_1c2;
  local_230 = {d 0.0078125};
  local_228 = 1.5f;
  local_224 = 0;
  local_21c = 0;
  local_214 = 1;
  local_211 = local_1c6;
  local_213 = local_1c8;
  local_210 = local_cb0;
  local_208 = local_cb8;
  local_200 = 0;
  local_1fd = local_1ca;
  local_1ff = local_1cc;
  local_1fc = 0;
  local_1f4 = 0;
  local_1ec = 1;
  local_1eb = local_1d0;
  local_1e9 = local_1ce;
  local_500[0] = 0;
  local_4f0 = 0;
  local_4f8 = 0;
  local_4e8 = 0;
  local_4b0 = 0;
  uStack_4b8 = 0;
  local_4c0 = 0;
  uStack_4c8 = 0;
  local_4d0 = 0;
  uStack_4d8 = 0;
  local_4e0 = 0;
  local_4ac = 1;
  local_4a0 = 0;
  local_4a8 = 0;
  local_498 = 1;
  local_48c = 0;
  local_494 = 0;
  local_484 = 1;
  local_478 = 0;
  local_480 = 0;
  local_470 = 0;
  local_438 = 0;
  uStack_440 = 0;
  local_448 = 0;
  uStack_450 = 0;
  local_458 = 0;
  uStack_460 = 0;
  local_468 = 0;
  local_434 = 1;
  local_428 = 0;
  local_430 = 0;
  local_420 = 1;
  local_414 = 0;
  local_41c = 0;
  local_40c = 1;
  uStack_3f8 = 0;
  uStack_400 = 0;
  local_3fb = 0;
  local_408 = 0;
  puVar3 = &local_2e0;
  local_d60 = local_188;
  local_d58 = local_118;
  local_d50 = local_120;
  local_d48 = local_124;
  local_d44 = local_128;
  local_d40 = local_130;
  local_d38 = local_138;
  local_d28 = local_190;
  local_d18 = local_1a8;
  local_d10 = local_198;
  local_cf8 = local_178;
  local_cf4 = local_17c;
  local_cdc = local_1b4;
  local_cd8 = local_144;
  local_cd0 = local_14c;
  local_2e0 = uVar19;
  local_2dc = local_1b4;
  local_2d8 = uVar13;
  local_2d0 = local_1a8;
  local_2c8 = local_d1c;
  local_2c4 = local_19c;
  local_2c0 = local_198;
  local_2b8 = local_190;
  local_2b0 = local_188;
  local_2a4 = local_17c;
  local_2a0 = local_178;
  local_29c = uVar9;
  local_294 = uVar10;
  local_288 = uVar11;
  local_280 = uVar12;
  local_274 = local_14c;
  local_26c = local_144;
  local_260 = local_138;
  local_258 = local_130;
  local_250 = local_128;
  local_24c = local_124;
  local_248 = local_120;
  local_240 = local_118;
  local_238 = uVar15;
  local_1e8 = uVar14;
  local_1e0 = uVar26;
  local_1dc = uVar27;
  local_1d8 = uVar28;
  local_1d4 = uVar8;
  FUN_195ed8068(puVar3,local_500);
  if (((ulong)puVar3 & 1) == 0) {
    local_3ec = local_cdc;
    local_3e0 = local_d18;
    local_3d8 = local_d1c;
    local_3d4 = (undefined4)local_ce8;
    local_3d0 = local_d10;
    local_3c8 = local_d28;
    local_3c0 = local_d60;
    local_3b8 = CONCAT44(local_cf4,(int)local_cf0);
    local_3b0 = local_cf8;
    local_39c = (undefined1)local_d00;
    local_39b = local_1bc;
    local_399 = local_1ba;
    local_388 = (undefined1)local_d08;
    local_387 = local_1c0;
    local_385 = local_1be;
    local_384 = local_cd0;
    local_37c = local_cd8;
    local_374 = (undefined1)local_d30;
    local_373 = local_1c4;
    local_371 = local_1c2;
    local_370 = local_d38;
    local_368 = local_d40;
    local_360 = local_d44;
    local_35c = local_d48;
    local_358 = local_d50;
    local_350 = local_d58;
    local_340 = local_cc8;
    local_338 = 1.5f;
    local_334 = 0;
    local_32c = 0;
    local_324 = 1;
    local_321 = local_1c6;
    local_323 = local_1c8;
    local_320 = uVar16;
    local_318 = uVar5;
    local_310 = 0;
    local_30d = local_1ca;
    local_30f = local_1cc;
    local_30c = 0;
    local_304 = 0;
    local_2fc = 1;
    local_2fb = local_1d0;
    local_2f9 = local_1ce;
    local_3f0 = uVar19;
    local_3e8 = uVar13;
    local_3ac = uVar9;
    local_3a4 = uVar10;
    local_398 = uVar11;
    local_390 = uVar12;
    local_348 = uVar15;
    local_2f8 = uVar14;
    local_2f0 = uVar26;
    local_2ec = uVar27;
    local_2e8 = uVar28;
    local_2e4 = uVar8;
    _CGPointMake(&local_3f0);
    func_0x000198104610(auStack_720,&local_3f0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_720);
  }
  func_0x000198104610(local_ca8 + 0x1e8,auStack_720,0x10d);
  uVar25 = SUB84(auStack_720,0);
  uVar19 = 0x10d;
  func_0x000198104610(&local_830);
  iVar1 = (int)&local_830;
  FUN_195e7d8c0();
  uVar16 = local_cb0;
  uVar9 = local_cb8;
  uVar5 = local_cc8;
  if (iVar1 == 1) {
    local_760 = 0;
    local_818 = 0;
    local_810 = 0;
    local_808 = 0;
    local_800 = 0;
    local_790 = 0;
    local_788 = 0;
    local_780 = 0;
    local_77c = 0;
    local_778 = 0;
    local_d1c = 1;
    uVar6 = 1;
    uVar7 = 1;
    local_738 = 0;
    local_730 = 0;
    local_72c = 0;
    local_728 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar20 = 0;
    uVar22 = 0;
    uVar23 = 0;
    uVar24 = 0;
    uVar8 = 0;
    local_82c = uVar19;
    local_814 = uVar17;
    local_79c = uVar25;
    uVar25 = 0;
    uVar19 = 0;
  }
  else {
    local_834 = local_7db;
    local_832 = local_7d9;
    local_838 = local_7c7;
    local_836 = local_7c5;
    local_83a = local_7b1;
    local_83c = local_7b3;
    local_d1c = (uint)local_764;
    local_83e = local_761;
    local_840 = local_763;
    uVar6 = (uint)local_750;
    local_842 = local_74d;
    local_844 = local_74f;
    uVar7 = (uint)local_73c;
    local_846 = local_739;
    local_848 = local_73b;
    uVar10 = local_774;
    uVar11 = local_76c;
    uVar12 = local_758;
    uVar13 = local_74c;
    uVar14 = local_744;
    uVar15 = local_7b0;
    uVar20 = local_828;
    uVar22 = local_7a8;
    uVar23 = local_798;
    uVar24 = local_820;
    uVar8 = local_724;
    uVar25 = local_830;
    uVar19 = local_7a0;
  }
  local_cd8 = CONCAT44(local_cd8._4_4_,local_82c);
  local_3b8 = local_cc8;
  local_3b0 = 1.5f;
  local_3a4 = 0;
  local_3ac = 0;
  local_39c = 1;
  local_39b = local_834;
  local_399 = local_832;
  local_398 = local_cb0;
  local_390 = local_cb8;
  local_388 = 0;
  local_387 = local_838;
  local_385 = local_836;
  local_384 = 0;
  local_37c = 0;
  local_374 = 1;
  local_373 = local_83c;
  local_371 = local_83a;
  local_cb8 = CONCAT44(local_cb8._4_4_,local_79c);
  local_cf0 = CONCAT44(local_cf0._4_4_,local_780);
  local_340 = CONCAT44(local_77c,local_780);
  local_d00 = CONCAT44(local_d00._4_4_,local_778);
  local_324 = (undefined1)local_d1c;
  local_321 = local_83e;
  local_323 = local_840;
  local_d28 = CONCAT44(local_d28._4_4_,uVar6);
  local_310 = (undefined1)uVar6;
  local_30d = local_842;
  local_30f = local_844;
  local_d30 = CONCAT44(local_d30._4_4_,uVar7);
  local_2fc = (undefined1)uVar7;
  local_2f9 = local_846;
  local_2fb = local_848;
  local_d40 = CONCAT44(local_d40._4_4_,local_730);
  puVar3 = &local_3f0;
  local_d48 = local_728;
  local_d44 = local_72c;
  local_d38 = local_738;
  local_d18 = local_800;
  local_d10 = local_808;
  local_d08 = local_810;
  local_cf8 = local_77c;
  local_cf4 = local_814;
  local_ce8 = local_788;
  local_cdc = local_818;
  local_cd0 = local_790;
  local_cb0 = local_760;
  local_3f0 = uVar25;
  local_3ec = local_82c;
  local_3e8 = uVar20;
  local_3e0 = uVar24;
  local_3d8 = local_818;
  local_3d4 = local_814;
  local_3d0 = local_810;
  local_3c8 = local_808;
  local_3c0 = local_800;
  local_370 = uVar15;
  local_368 = uVar22;
  local_360 = uVar19;
  local_35c = local_79c;
  local_358 = uVar23;
  local_350 = local_790;
  local_348 = local_788;
  local_338 = local_778;
  local_334 = uVar10;
  local_32c = uVar11;
  local_320 = local_760;
  local_318 = uVar12;
  local_30c = uVar13;
  local_304 = uVar14;
  local_2f8 = local_738;
  local_2f0 = local_730;
  local_2ec = local_72c;
  local_2e8 = local_728;
  local_2e4 = uVar8;
  FUN_195ed8068(puVar3,local_500);
  if (((ulong)puVar3 & 1) == 0) {
    local_60c = (undefined4)local_cd8;
    local_5f8 = local_cdc;
    local_5f4 = local_cf4;
    local_5f0 = local_d08;
    local_5e8 = local_d10;
    local_5e0 = local_d18;
    local_5d8 = uVar5;
    local_5d0 = 1.5f;
    local_5c4 = 0;
    local_5cc = 0;
    local_5bc = 1;
    local_5bb = local_834;
    local_5b9 = local_832;
    local_5b8 = uVar16;
    local_5b0 = uVar9;
    local_5a8 = 0;
    local_5a7 = local_838;
    local_5a5 = local_836;
    local_5a4 = 0;
    local_59c = 0;
    local_594 = 1;
    local_593 = local_83c;
    local_591 = local_83a;
    local_57c = (undefined4)local_cb8;
    local_570 = local_cd0;
    local_568 = local_ce8;
    local_560 = (undefined4)local_cf0;
    local_55c = local_cf8;
    local_558 = (undefined4)local_d00;
    local_544 = (undefined1)local_d1c;
    local_541 = local_83e;
    local_543 = local_840;
    local_540 = local_cb0;
    local_530 = (undefined1)local_d28;
    local_52d = local_842;
    local_52f = local_844;
    local_51c = (undefined1)local_d30;
    local_519 = local_846;
    local_51b = local_848;
    local_518 = local_d38;
    local_510 = (undefined4)local_d40;
    local_50c = local_d44;
    local_508 = local_d48;
    local_610 = uVar25;
    local_608 = uVar20;
    local_600 = uVar24;
    local_590 = uVar15;
    local_588 = uVar22;
    local_580 = uVar19;
    local_578 = uVar23;
    local_554 = uVar10;
    local_54c = uVar11;
    local_538 = uVar12;
    local_52c = uVar13;
    local_524 = uVar14;
    local_504 = uVar8;
    _CGPointMake(&local_610);
    func_0x000198104610(auStack_958,&local_610,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_958);
  }
  lVar2 = local_ca8;
  uVar4 = local_ca8 + 0x1e8;
  func_0x000198104610(uVar4,auStack_958,0x10d);
  FUN_195ed53f0();
  if ((uVar4 & 1) != 0) {
    func_0x000198104610(&local_a68,lVar2 + 0x1e8,0x10d);
    iVar1 = (int)&local_a68;
    FUN_195e7d8c0();
    if (iVar1 == 1) {
      local_97c = 0;
      local_984 = 0;
      local_990 = 0;
      local_998 = 0;
      local_a60 = 0;
      local_610 = 0;
      local_a58 = 0;
      local_cf4 = 0;
      uVar18 = 1;
      local_cb0 = CONCAT44(local_cb0._4_4_,1);
      local_cf8 = 1;
      local_9c8 = 0;
      local_9d0 = 0;
      local_9d8 = 0;
      local_9e0 = 0;
      local_9e8 = 0;
      uVar17 = 1;
      local_d44 = 1;
      local_d48 = 1;
      local_a28 = 0;
      local_a2c = 0;
      local_a30 = 0;
      local_a38 = 0;
      local_a40 = 0;
      uVar5 = 0;
      uVar9 = 0;
      uVar10 = 0;
      uVar11 = 0;
      uVar12 = 0;
      uVar13 = 0;
      uVar14 = 0;
      uVar15 = 0;
      uVar20 = 0;
      uVar22 = 0;
      uVar25 = 0;
      uVar19 = 0;
      uVar26 = 0;
      local_a64 = uVar6;
      local_a4c = uVar7;
      uVar27 = 0;
      uVar28 = 0;
      uVar21 = 0;
      uVar8 = 0;
    }
    else {
      local_d48 = (uint)local_a14;
      local_a6c = local_a13;
      local_a6a = local_a11;
      local_d44 = (uint)local_a00;
      local_a6e = local_9fd;
      local_a70 = local_9ff;
      uVar17 = (uint)local_9ec;
      local_a72 = local_9e9;
      local_a74 = local_9eb;
      uVar16 = (ulong)local_9d4;
      local_cf8 = (uint)local_99c;
      local_a76 = local_999;
      local_a78 = local_99b;
      local_cb0 = CONCAT44(local_cb0._4_4_,(uint)local_988);
      local_a7a = local_985;
      local_a7c = local_987;
      uVar18 = (uint)local_974;
      local_a7e = local_971;
      local_a80 = local_973;
      uVar5 = local_9ac;
      uVar9 = local_a1c;
      uVar10 = local_a24;
      uVar11 = local_a08;
      uVar12 = local_a10;
      uVar13 = local_9f4;
      uVar14 = local_9fc;
      uVar15 = local_9a4;
      uVar20 = local_970;
      uVar22 = local_9c0;
      uVar25 = local_9b8;
      uVar19 = local_9b4;
      uVar26 = local_9b0;
      local_610 = local_a68;
      local_cf4 = local_a50;
      uVar27 = local_968;
      uVar28 = local_964;
      uVar21 = local_960;
      uVar8 = local_95c;
    }
    local_ce8 = CONCAT44(local_ce8._4_4_,local_610);
    local_cd8 = CONCAT44(local_cd8._4_4_,local_a64);
    local_5f0 = 2.0944;
    local_d60 = CONCAT44(local_d60._4_4_,local_a30);
    local_d58 = CONCAT44(local_d58._4_4_,local_a2c);
    local_5d8 = CONCAT44(local_a2c,local_a30);
    local_d50 = CONCAT44(local_d50._4_4_,local_a28);
    local_5bc = (undefined1)local_d48;
    local_5b9 = local_a6a;
    local_5bb = local_a6c;
    local_5a8 = (undefined1)local_d44;
    local_5a7 = local_a70;
    local_5a5 = local_a6e;
    local_d40 = CONCAT44(local_d40._4_4_,uVar17);
    local_594 = (undefined1)uVar17;
    local_593 = local_a74;
    local_591 = local_a72;
    local_d28 = CONCAT44(local_d28._4_4_,local_9d8);
    local_d1c = (uint)uVar16;
    local_544 = (undefined1)local_cf8;
    local_541 = local_a76;
    local_543 = local_a78;
    local_530 = (undefined1)local_cb0;
    local_52d = local_a7a;
    local_52f = local_a7c;
    local_d08 = CONCAT44(local_d08._4_4_,uVar18);
    local_51c = (undefined1)uVar18;
    local_519 = local_a7e;
    local_51b = local_a80;
    puVar3 = &local_610;
    local_d70 = local_a40;
    uStack_d68 = local_a38;
    local_d38 = local_9e8;
    local_d30 = local_9e0;
    local_d18 = local_9d0;
    local_d10 = local_9c8;
    local_d00 = local_a60;
    local_cf0 = local_a58;
    local_cdc = local_a4c;
    local_cd0 = local_984;
    local_cc8 = local_97c;
    local_cc0 = local_998;
    local_cb8 = local_990;
    local_60c = local_a64;
    local_608 = local_a60;
    local_600 = local_a58;
    local_5f8 = local_cf4;
    local_5f4 = local_a4c;
    local_5e8 = local_a40;
    local_5e0 = local_a38;
    local_5d0 = local_a28;
    local_5cc = uVar10;
    local_5c4 = uVar9;
    local_5b8 = uVar12;
    local_5b0 = uVar11;
    local_5a4 = uVar14;
    local_59c = uVar13;
    local_590 = local_9e8;
    local_588 = local_9e0;
    local_580 = local_9d8;
    local_57c = local_d1c;
    local_578 = local_9d0;
    local_570 = local_9c8;
    local_568 = uVar22;
    local_560 = uVar25;
    local_55c = uVar19;
    local_558 = uVar26;
    local_554 = uVar5;
    local_54c = uVar15;
    local_540 = local_998;
    local_538 = local_990;
    local_52c = local_984;
    local_524 = local_97c;
    local_518 = uVar20;
    local_510 = uVar27;
    local_50c = uVar28;
    local_508 = uVar21;
    local_504 = uVar8;
    FUN_195ed8068(puVar3,local_500);
    if (((ulong)puVar3 & 1) == 0) {
      local_ca0 = (undefined4)local_ce8;
      local_c9c = (undefined4)local_cd8;
      local_c98 = local_d00;
      uStack_c90 = local_cf0;
      local_c88 = local_cf4;
      local_c84 = local_cdc;
      local_c80 = 2.0944;
      local_c78 = local_d70;
      uStack_c70 = uStack_d68;
      local_c68 = (undefined4)local_d60;
      local_c64 = (undefined4)local_d58;
      local_c60 = (undefined4)local_d50;
      local_c4c = (undefined1)local_d48;
      local_c4b = local_a6c;
      local_c49 = local_a6a;
      local_c38 = (undefined1)local_d44;
      local_c35 = local_a6e;
      local_c37 = local_a70;
      local_c24 = (undefined1)local_d40;
      local_c21 = local_a72;
      local_c23 = local_a74;
      local_c20 = local_d38;
      uStack_c18 = local_d30;
      local_c10 = (undefined4)local_d28;
      local_c0c = local_d1c;
      local_c08 = local_d18;
      uStack_c00 = local_d10;
      local_bd4 = (undefined1)local_cf8;
      local_bd1 = local_a76;
      local_bd3 = local_a78;
      local_bd0 = local_cc0;
      uStack_bc8 = local_cb8;
      local_bc0 = (undefined1)local_cb0;
      local_bbd = local_a7a;
      local_bbf = local_a7c;
      local_bbc = local_cd0;
      local_bb4 = local_cc8;
      local_bac = (undefined1)local_d08;
      local_ba9 = local_a7e;
      local_bab = local_a80;
      local_c5c = uVar10;
      local_c54 = uVar9;
      local_c48 = uVar12;
      uStack_c40 = uVar11;
      local_c34 = uVar14;
      local_c2c = uVar13;
      local_bf8 = uVar22;
      local_bf0 = uVar25;
      local_bec = uVar19;
      local_be8 = uVar26;
      local_be4 = uVar5;
      local_bdc = uVar15;
      local_ba8 = uVar20;
      local_ba0 = uVar27;
      local_b9c = uVar28;
      local_b98 = uVar21;
      local_b94 = uVar8;
      _CGPointMake(&local_ca0);
      func_0x000198104610(auStack_b90,&local_ca0,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_b90);
    }
    lVar2 = local_ca8;
    func_0x000198104610(local_ca8 + 0x1e8,auStack_b90,0x10d);
  }
  *(undefined8 *)(lVar2 + 8) = 0.0333333;
  return;
}


//######## CameraHDRRecipe.HDR (spec) 0x195ef9524
// === 195ef9524 spec

/* WARNING: Removing unreachable block (ram,0x000195ef956c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195ef9524(long param_1)
{
  lVar2 = 0;
  func_0x0001981217d0();
  (*_DAT_1e2125200)(*(undefined8 *)(*(long *)(lVar2 + -8) + 0x40));
  (**(code **)(extraout_x12 + 0x68))
            (&stack0xffffffffffffffe0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),*_DAT_1e01830d0);
  uVar6 = 0.7f;
  uVar3 = 0;
  uVar4 = 0;
  uVar5 = 0;
  func_0x0001981218c0(&stack0xffffffffffffffe0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0));
  uVar1 = {f 1, 0.3};
  <faceEffect.ycc.white> = {d 9.76563e-05};
  <faceEffect.opacity> = uVar1;
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar6 >> 0x18),
                CONCAT16((char)((uint)uVar6 >> 0x10),
                         CONCAT15((char)((uint)uVar6 >> 8),CONCAT14((char)uVar6,uVar5))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((uint)uVar4 >> 0x18),
                CONCAT16((char)((uint)uVar4 >> 0x10),
                         CONCAT15((char)((uint)uVar4 >> 8),CONCAT14((char)uVar4,uVar3))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  return;
}


//######## anon.CarPlayUltraSpec (spec) 0x195efba30
// === 195efba30 spec

void FUN_195efba30(undefined8 param_1,undefined8 param_2)
{
  uint3 *unaff_x20;
  FUN_195efb1d8(param_1,param_2,(ulong)*unaff_x20);
  return;
}


//######## anon.CarPlayUltraDockSpec (spec) 0x195efba40
// === 195efbd60 spec

/* WARNING: Removing unreachable block (ram,0x000195efbe9c) */
/* WARNING: Removing unreachable block (ram,0x000195efbe24) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efbd60(undefined8 <backdropScale>,double *param_2)
{
  undefined1 auStack_6f0 [8];
  puVar9 = &DAT_1eda3a940;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar9 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  lVar10 = 0;
  local_5e8 = auStack_6f0 + -extraout_x8;
  func_0x0001981217d0();
  lVar15 = *(long *)(lVar10 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar15 + 0x40));
  lVar26 = (long)(auStack_6f0 + -extraout_x8) - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar11 = 0;
  func_0x000198120110();
  uVar16 = *(ulong *)(lVar11 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(uVar16 + 0x40));
  uVar22 = lVar26 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  FUN_195ee8970(param_1);
  lVar12 = 0;
  FUN_195f3c68c();
  iVar33 = *(int *)(lVar12 + 0x18);
  uVar13 = uVar22;
  (**(code **)(uVar16 + 0x68))(uVar22,*_DAT_1e017dd58,lVar11);
  FUN_195e7d9c0();
  uVar14 = (long)param_2 + (long)iVar33;
  func_0x0001980ff320(uVar14,uVar22,lVar11,uVar13);
  local_628 = lVar11;
  local_5c0 = uVar16;
  (**(code **)(uVar16 + 8))(uVar22,lVar11);
  local_578 = param_2;
  FUN_195ed53f0();
  local_57c = (uint)uVar14;
  uVar39 = 0;
  if ((uVar14 & 1) == 0) {
    uVar39 = 0.9f;
  }
  uVar25 = *_DAT_1e01830d0;
  local_59c = uVar39;
  if ((uVar22 & 1) == 0) {
    pcVar24 = *(code **)(lVar15 + 0x68);
    (*pcVar24)(lVar26,uVar25,lVar10);
    bVar8 = (uVar14 & 1) == 0;
    if (bVar8) {
      uVar31 = 0.4f;
      uVar39 = 1f;
      uVar27 = 1f;
      uVar28 = 1f;
      func_0x0001981218c0(lVar26);
      uStack_588 = CONCAT44(uVar27,uVar39);
      local_590 = CONCAT44(uVar31,uVar28);
      (*pcVar24)(lVar26,uVar25,lVar10);
      uVar28 = 0.12f;
      uVar39 = 0;
      uVar25 = 0;
      uVar27 = 0;
      func_0x0001981218c0(lVar26);
      uStack_5a8 = CONCAT44(uVar25,uVar39);
      local_5b0 = CONCAT44(uVar28,uVar27);
      local_638 = {d 0.7};
      local_5cc = 1.03f;
      local_598 = (f 0.5, f 0.25);
      local_5dc = 0.5f;
    }
    else {
      uVar28 = 0.4f;
      uVar39 = 0;
      uVar25 = 0;
      uVar27 = 0;
      func_0x0001981218c0(lVar26);
      local_5b0 = 0;
      uStack_5a8 = 0;
      uStack_588 = CONCAT44(uVar25,uVar39);
      local_590 = CONCAT44(uVar28,uVar27);
      local_638 = {d 0.0078125};
      local_598 = (f 0.4, f 0.25);
      local_5cc = 0.6f;
      local_5dc = 0.2f;
    }
    local_5b4 = (uint)!bVar8;
    local_268 = 24;
    bStack_22f = 0;
    FUN_195eef528(&local_268,&local_460);
    uVar23 = local_230;
    uVar21 = local_240;
    puVar5 = local_5e8;
    local_2a0 = CONCAT44(uStack_254,local_258);
    uStack_2a8 = uStack_260;
    local_2b0 = local_268;
    uStack_298 = uStack_250;
    local_620 = CONCAT44(uStack_254,local_258);
    uStack_618 = uStack_250;
    uStack_608 = uStack_260;
    uStack_610 = local_268;
    uStack_288 = local_240;
    local_290 = uStack_248;
    uStack_27e = uStack_236;
    local_278 = (undefined2)(CONCAT17(bStack_22f,CONCAT16(local_230,uStack_236)) >> 0x30);
    local_280 = uStack_238;
    local_5c8 = uStack_248;
    uStack_270._3_1_ = (undefined1)uStack_23c;
    uStack_270 = CONCAT13(uStack_270._3_1_,CONCAT21(uStack_23e,uStack_23f));
    uStack_26c = (undefined3)((uint)uStack_23c >> 8);
    local_5d8 = CONCAT62(uStack_236,uStack_238);
    local_5ec = (uint)bStack_22f;
    puVar19 = (undefined8 *)(local_5c0 + 0x38);
    local_5c0 = CONCAT44(local_5c0._4_4_,1);
    (*(code *)*puVar19)(local_5e8,1,1,local_628);
    FUN_195eef0b0(&local_268,local_578,puVar5);
    FUN_195dabb50(puVar5,&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
    uVar27 = 0;
    uStack_2e8 = uStack_128;
    local_2f0 = local_130;
    uStack_2d8 = uStack_118;
    local_2e0 = uStack_120;
    uStack_2c8 = uStack_108;
    local_2d0 = local_110;
    uStack_2be = uStack_fe;
    uStack_2c6 = uStack_106;
    uStack_2c0 = uStack_100;
    uStack_300 = uStack_14c;
    uStack_318 = uStack_164;
    local_320 = local_16c;
    uStack_308 = uStack_154;
    local_303 = uStack_14f;
    uStack_310 = local_15c;
    uStack_338 = uStack_184;
    local_340 = local_18c;
    uStack_328 = uStack_174;
    uStack_330 = local_17c;
    uStack_350 = uStack_194;
    uStack_368 = uStack_1ac;
    local_370 = local_1b4;
    uStack_358 = uStack_19c;
    local_353 = uStack_197;
    uStack_360 = local_1a4;
    local_3f0 = CONCAT62(uStack_22e,CONCAT11(bStack_22f,local_230));
    uStack_388 = uStack_1cc;
    local_390 = local_1d4;
    uStack_378 = uStack_1bc;
    uStack_380 = local_1c4;
    uVar40 = 9;
    uVar41 = 0.3125;
    local_5e8 = (undefined1 *)CONCAT44(local_5e8._4_4_,2);
    uStack_3f8 = CONCAT62(uStack_236,uStack_238);
    local_400 = CONCAT44(uStack_23c,CONCAT22(uStack_23e,CONCAT11(uStack_23f,local_240)));
    uStack_39e = uStack_1de;
    uStack_3a0 = uStack_1e0;
    local_5f4 = 1f;
    local_6d0 = 0.125;
    uVar20 = 48;
    uVar42 = 0.4;
    local_6d8 = -0.8;
    local_6c8 = 0.2;
    uVar38 = 0xfff0000000000000;
    local_6dc = 0.3f;
    uVar25 = 1.33333f;
    uStack_3b8 = uStack_1f8;
    local_3c0 = local_200;
    uStack_3a8 = uStack_1e8;
    local_3a6 = uStack_1e6;
    uStack_3b0 = local_1f0;
    local_668 = 0;
    local_660 = local_e0;
    local_674 = 0;
    local_6e8 = 48;
    local_5f0 = 0;
    local_6a0 = 0;
    local_630 = local_f0;
    local_628 = local_e8;
    uStack_3c8 = uStack_208;
    local_3d0 = local_210;
    local_69c = 0;
    local_680 = 0;
    local_658 = local_140;
    local_650 = local_138;
    local_670 = (ulong)local_d8;
    uStack_3de = uStack_21e;
    uStack_3e0 = uStack_220;
    local_690 = 0;
    uStack_688 = 0;
    local_6a4 = local_258;
    uStack_3e8 = uStack_228;
    uStack_3e6 = uStack_226;
    local_698 = 0.0;
    uVar17 = 0;
    uStack_6b8 = uStack_260;
    local_6b0 = 0;
    uStack_408 = uStack_248;
    local_410 = uStack_250;
    local_648 = 0;
    local_640 = 0.0;
  }
  else {
    pcVar24 = *(code **)(lVar15 + 0x68);
    (*pcVar24)(lVar26,uVar25,lVar10);
    if ((uVar14 & 1) == 0) {
      uVar32 = 0.2f;
      uVar27 = 1f;
      local_5f4 = 1f;
      uVar28 = 1f;
      uVar31 = 1f;
      func_0x0001981218c0(lVar26);
      local_598 = 3.43323e-06;
      local_5f0 = 0;
      local_5cc = 1.03f;
      local_5dc = 0.4f;
    }
    else {
      uVar27 = 0;
      uVar28 = 0;
      uVar31 = 0;
      uVar32 = 0;
      func_0x0001981218c0(lVar26);
      local_5cc = 1f;
      local_598 = 9.76563e-05;
      local_5f4 = 0.65f;
      local_5dc = 0.1f;
      local_5f0 = 0.9f;
    }
    uStack_588 = CONCAT44(uVar28,uVar27);
    local_590 = CONCAT44(uVar32,uVar31);
    (*pcVar24)(lVar26,uVar25,lVar10);
    uVar31 = 0.3f;
    uVar25 = 0;
    uVar27 = 0;
    uVar28 = 0;
    func_0x0001981218c0(lVar26);
    puVar5 = local_5e8;
    local_5b0 = CONCAT44(uVar31,uVar28);
    uStack_5a8 = CONCAT44(uVar27,uVar25);
    uStack_618 = {d 24};
    local_620 = {d 12};
    uStack_608 = {d 160};
    uStack_610 = {d 64};
    uStack_2a8 = {d 160};
    local_2b0 = {d 64};
    uStack_298 = {d 24};
    local_2a0 = {d 12};
    local_290 = 0;
    uVar21 = 1;
    uStack_288 = 1;
    local_280 = 0;
    uStack_27e = 0;
    local_278 = 0x201;
    (**(code **)(local_5c0 + 0x38))(local_5e8,1,1,local_628);
    pdVar7 = local_578;
    FUN_195eef0b0(&local_268,local_578,puVar5);
    FUN_195dabb50(puVar5,&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
    local_5c0 = local_5c0 & 0xffffffff00000000;
    uVar25 = 0;
    local_5c8 = 0;
    local_5d8 = 0;
    local_5b4 = 0;
    local_5e8 = (undefined1 *)((ulong)local_5e8 & 0xffffffff00000000);
    dVar30 = *pdVar7;
    local_648 = -0.3;
    local_640 = dVar30 * -1.6;
    if (0.5 <= dVar30) {
      local_648 = -0.25;
      local_640 = -dVar30;
    }
    local_630 = local_f0;
    local_628 = local_e8;
    uStack_2e8 = uStack_128;
    local_2f0 = local_130;
    uStack_2d8 = uStack_118;
    local_2e0 = uStack_120;
    uStack_2c8 = uStack_108;
    local_2d0 = local_110;
    uStack_2be = uStack_fe;
    uStack_2c6 = uStack_106;
    uStack_2c0 = uStack_100;
    local_650 = local_138;
    local_658 = local_140;
    uStack_39e = uStack_1de;
    uStack_3a0 = uStack_1e0;
    uStack_3b8 = uStack_1f8;
    local_3c0 = local_200;
    uStack_3a8 = uStack_1e8;
    local_3a6 = uStack_1e6;
    uStack_3b0 = local_1f0;
    uStack_3c8 = uStack_208;
    local_3d0 = local_210;
    uStack_3f8 = CONCAT62(uStack_236,uStack_238);
    local_400 = CONCAT44(uStack_23c,CONCAT22(uStack_23e,CONCAT11(uStack_23f,local_240)));
    uStack_408 = uStack_248;
    local_410 = uStack_250;
    local_3f0 = CONCAT62(uStack_22e,CONCAT11(bStack_22f,local_230));
    uStack_3e8 = uStack_228;
    uStack_3de = uStack_21e;
    uStack_3e6 = uStack_226;
    uStack_3e0 = uStack_220;
    local_6a4 = local_258;
    uStack_6b8 = uStack_260;
    uStack_350 = uStack_194;
    uStack_368 = uStack_1ac;
    local_370 = local_1b4;
    uStack_358 = uStack_19c;
    local_353 = uStack_197;
    uStack_360 = local_1a4;
    uStack_388 = uStack_1cc;
    local_390 = local_1d4;
    uStack_378 = uStack_1bc;
    uStack_380 = local_1c4;
    uStack_300 = uStack_14c;
    uStack_318 = uStack_164;
    local_320 = local_16c;
    uStack_308 = uStack_154;
    local_303 = uStack_14f;
    uStack_310 = local_15c;
    uStack_338 = uStack_184;
    local_340 = local_18c;
    uStack_328 = uStack_174;
    uStack_330 = local_17c;
    local_698 = -local_640;
    local_670 = {f 0.15, 16};
    local_638 = NEON_fmov(1f,4);
    local_6e8 = 0;
    local_5ec = 2;
    local_6d8 = -0.5;
    local_6c8 = 0.25;
    uVar38 = 16;
    uVar20 = 64;
    uVar27 = 5f;
    local_690 = 8;
    uStack_688 = 4;
    local_680 = 5;
    local_668 = 1;
    local_660 = {d 0.000170898};
    local_674 = 0.5f;
    local_6b0 = 0.4;
    uVar17 = 1.309;
    local_6d0 = 0.2;
    local_6dc = 0.6f;
    local_69c = 0.1f;
    uVar23 = 1;
    uVar42 = 0;
    uVar41 = 0;
    uVar40 = 0;
    local_6a0 = uVar39;
  }
  local_6c0 = local_268;
  if (DAT_1eda3b6c8 != -1) {
    func_0x000198104ff0(&DAT_1eda3b6c8,FUN_195eeb6ec);
  }
  uVar6 = local_57c;
  bVar8 = (local_57c & 1) == 0;
  uVar18 = 0.000878906;
  if (bVar8) {
    uVar18 = 3.05176e-05;
  }
  uVar39 = 1f;
  if (bVar8) {
    uVar39 = 1.2f;
  }
  uVar28 = 0.5f;
  if (bVar8) {
    uVar28 = 1f;
  }
  uStack_438 = uRam00000001eda465a0;
  local_440 = _DAT_1eda46598;
  uStack_428 = uRam00000001eda465b0;
  uStack_430 = _DAT_1eda465a8;
  local_420 = DAT_1eda465b8;
  uStack_458 = uRam00000001eda46580;
  local_460 = _DAT_1eda46578;
  uStack_448 = uRam00000001eda46590;
  uStack_450 = _DAT_1eda46588;
  lVar10 = 0;
  FUN_195ed0900();
  uVar4 = {f 0.25, 0};
  bVar8 = *(byte *)((long)local_578 + (long)*(int *)(lVar10 + 0x2c)) < 2;
  uVar29 = 0;
  if (!bVar8) {
    uVar29 = 1.5708;
  }
  uVar31 = 0;
  uVar32 = 0;
  if (!bVar8) {
    uVar31 = 1f;
    uVar32 = -5f;
  }
  uStack_494 = (undefined4)uStack_408;
  uStack_490 = (undefined4)((ulong)uStack_408 >> 0x20);
  local_49c = (undefined4)local_410;
  uStack_498 = (undefined4)((ulong)local_410 >> 0x20);
  uStack_484 = (undefined4)uStack_3f8;
  uStack_480 = (undefined4)((ulong)uStack_3f8 >> 0x20);
  local_48c = (undefined4)local_400;
  uStack_488 = (undefined4)((ulong)local_400 >> 0x20);
  local_47c = (undefined4)local_3f0;
  uStack_478 = (undefined4)((ulong)local_3f0 >> 0x20);
  uStack_46a = uStack_3de;
  uStack_472 = (undefined2)uStack_3e6;
  uStack_470 = (undefined4)((uint6)uStack_3e6 >> 0x10);
  uStack_4d2 = (undefined2)uStack_3c8;
  uStack_4d0 = (undefined6)((ulong)uStack_3c8 >> 0x10);
  local_4da = (undefined2)local_3d0;
  uStack_4d8 = (undefined6)((ulong)local_3d0 >> 0x10);
  uStack_4a8 = uStack_39e;
  uStack_4ba = (undefined2)uStack_3b0;
  uStack_4b8 = (undefined6)((ulong)uStack_3b0 >> 0x10);
  uStack_4c2 = (undefined2)uStack_3b8;
  uStack_4c0 = (undefined6)((ulong)uStack_3b8 >> 0x10);
  local_4ca = (undefined2)local_3c0;
  uStack_4c8 = (undefined6)((ulong)local_3c0 >> 0x10);
  uStack_50e = (undefined6)uStack_378;
  uStack_508 = (undefined2)((ulong)uStack_378 >> 0x30);
  local_516 = (undefined6)uStack_380;
  uStack_510 = (undefined2)((ulong)uStack_380 >> 0x30);
  uStack_4fe = (undefined6)uStack_368;
  uStack_4f8 = (undefined2)((ulong)uStack_368 >> 0x30);
  local_506 = (undefined6)local_370;
  uStack_500 = (undefined2)((ulong)local_370 >> 0x30);
  local_4f6 = (undefined6)uStack_360;
  uStack_4f0 = (undefined2)((ulong)uStack_360 >> 0x30);
  uStack_51e = (undefined6)uStack_388;
  uStack_518 = (undefined2)((ulong)uStack_388 >> 0x30);
  local_526 = (undefined6)local_390;
  uStack_520 = (undefined2)((ulong)local_390 >> 0x30);
  uStack_555 = (undefined5)uStack_328;
  uStack_550 = (undefined3)((ulong)uStack_328 >> 0x28);
  local_55d = (undefined5)uStack_330;
  uStack_558 = (undefined3)((ulong)uStack_330 >> 0x28);
  uStack_545 = (undefined5)uStack_318;
  uStack_540 = (undefined3)((ulong)uStack_318 >> 0x28);
  local_54d = (undefined5)local_320;
  uStack_548 = (undefined3)((ulong)local_320 >> 0x28);
  local_53d = (undefined5)uStack_310;
  uStack_538 = (undefined3)((ulong)uStack_310 >> 0x28);
  uStack_565 = (undefined5)uStack_338;
  uStack_560 = (undefined3)((ulong)uStack_338 >> 0x28);
  local_56d = (undefined5)local_340;
  uStack_568 = (undefined3)((ulong)local_340 >> 0x28);
  <+0x8> = {d 0};
  <backdropScale> = uVar4;
  <shadow.normalizedHeight> = uVar42;
  <shadow.normalizedAmount> = uVar41;
  <shadow.blurRadius> = uVar40;
  <+0x70> = uStack_618;
  <+0x68> = local_620;
  <+0x60> = uStack_608;
  <shadow.shadowRadius> = uStack_610;
  uVar42 = {d 0};
  <shadow.offset.1> = {d 8};
  <shadow.offset.0> = uVar42;
  <shadow.ycc.white> = local_638;
  <shadow.vibrancyContribution> = local_6e8;
  uVar42 = {d 160};
  <+0x100> = {d 0};
  <+0xf8> = uVar42;
  uVar42 = {d 0.0078125};
  <blur.opacities.1> = {d 3.05176e-05};
  <blur.opacity> = uVar42;
  uVar42 = {d 0.25};
  <refraction.innerHeightRange.lo> = {d 0};
  <refraction.normalizedInnerHeight> = uVar42;
  <refraction.normalizedInnerAmount> = local_6d8;
  uVar42 = {d -60};
  <refraction.innerAmountRange.hi> = {f 0, nan};
  <refraction.innerAmountRange.lo> = uVar42;
  <refraction.normalizedOuterAmount> = local_6c8;
  <refraction.outerAmountRange.lo> = uVar38;
  <refraction.normalizedOuterHeight> = local_6d0;
  <refraction.outerHeightRange.lo> = uVar38;
  <refraction.outerOpacity> = local_6dc;
  uVar38 = {d 0};
  uVar42 = {f 0, 1.4013e-45};
  <+0x48> = {d 0};
  <+0x40> = uVar42;
  <+0x188> = uVar38;
  <+0x180> = uVar42;
  <+0x228> = uVar38;
  <+0x220> = uVar42;
  uVar42 = {d 0.35};
  <edgeBleed.normalizedBlurRadius> = {d 0.7};
  <edgeBleed.normalizedAmount> = uVar42;
  <edgeBleed.ycc.black> = local_59c;
  <edgeBleed.ycc.white> = uVar28;
  <edgeBleed.ycc.saturation> = uVar39;
  <faceEffect.ycc.black> = local_5dc;
  <faceEffect.ycc.white> = local_5cc;
  <faceEffect.maxLuminance> = local_5f4;
  <faceEffect.maxLuminanceSDR> = local_5f4;
  <highlights.inset> = local_6c0;
  uStack_4e9 = (undefined1)local_353;
  uStack_4e8 = (undefined2)((uint3)local_353 >> 8);
  <highlights.white> = uStack_6b8;
  <highlights.fillOpacity> = local_6a4;
  <+0x342> = uStack_3de;
  <+0x33a> = CONCAT26(uStack_3e0,uStack_3e6);
  <+0x324> = CONCAT44(uStack_484,uStack_488);
  <+0x31c> = CONCAT44(local_48c,uStack_490);
  <+0x334> = CONCAT26(uStack_472,CONCAT24(uStack_3e8,uStack_478));
  <+0x32c> = CONCAT44(local_47c,uStack_480);
  <+0x314> = CONCAT44(uStack_494,uStack_498);
  <+0x30c> = CONCAT44(local_49c,uStack_4a0);
  <+0x372> = CONCAT26(uStack_3a8,uStack_4b8);
  <+0x36a> = CONCAT26(uStack_4ba,uStack_4c0);
  <+0x382> = uStack_39e;
  <+0x37a> = CONCAT26(uStack_3a0,local_3a6);
  <+0x352> = CONCAT26(uStack_4d2,uStack_4d8);
  <+0x34a> = CONCAT26(local_4da,uStack_4e0);
  <+0x362> = CONCAT26(uStack_4c2,uStack_4c8);
  <+0x35a> = CONCAT26(local_4ca,uStack_4d0);
  <+0x3c9> = CONCAT53(uStack_350,local_353);
  <+0x3b2> = CONCAT62(uStack_4fe,uStack_500);
  <+0x3aa> = CONCAT62(local_506,uStack_508);
  <+0x3c2> = CONCAT17(uStack_4e9,CONCAT52(uStack_358,uStack_4f0));
  <+0x3ba> = CONCAT62(local_4f6,uStack_4f8);
  <+0x392> = CONCAT62(uStack_51e,uStack_520);
  <+0x38a> = CONCAT62(local_526,uStack_528);
  <+0x3a2> = CONCAT62(uStack_50e,uStack_510);
  <+0x39a> = CONCAT62(local_516,uStack_518);
  <+0x3f9> = CONCAT53(uStack_545,uStack_548);
  <+0x3f1> = CONCAT53(local_54d,uStack_550);
  <+0x409> = CONCAT53(uStack_308,uStack_538);
  <+0x401> = CONCAT53(local_53d,uStack_540);
  <+0x3d9> = CONCAT53(uStack_565,uStack_568);
  <+0x3d1> = CONCAT53(local_56d,uStack_570);
  <+0x3e9> = CONCAT53(uStack_555,uStack_558);
  <+0x3e1> = CONCAT53(local_55d,uStack_560);
  <highlights.keyOffset> = local_658;
  <highlights.fillOffset> = local_650;
  <+0x462> = uStack_2be;
  <+0x45a> = CONCAT26(uStack_2c0,uStack_2c6);
  <+0x458> = CONCAT62(uStack_2c6,uStack_2c8);
  <+0x450> = local_2d0;
  <+0x448> = uStack_2d8;
  <+0x440> = local_2e0;
  <+0x438> = uStack_2e8;
  <highlights.spread> = local_2f0;
  <highlights.amount> = local_630;
  <highlights.curvature> = local_628;
  <highlights.diffuseHeightScale> = local_660;
  <highlights.diffuseAmountScale> = local_670;
  <blurFill.lightenOpacity> = local_6a0;
  <blurFill.darkenOpacity> = local_5f0;
  <blurFill.normalOpacity> = local_674;
  <ringShadow.verticalOffset> = local_690;
  <ringShadow.strokeWidth> = uStack_688;
  <ringShadow.blurRadius> = local_680;
  <ringShadow.opacity> = local_69c;
  <ringShadow.maskAmount> = local_668;
  <darkSpecular.height> = local_698;
  <darkSpecular.spread> = uVar17;
  <darkSpecular.spreadSDR> = uVar17;
  <darkSpecular.amount> = local_6b0;
  <darkSpecular.effectOffset> = local_640;
  <darkSpecular.colorBias> = local_648;
  <+0x4f8> = {d 0.0078125};
  uVar17 = {d 0.0938673};
  <+0x508> = {d 1.60617};
  <+0x500> = uVar17;
  uVar17 = {d 0.0275344};
  <+0x548> = {d 16.0801};
  <+0x540> = uVar17;
  uVar17 = {d -0.334168};
  <+0x588> = {d 12.9487};
  <+0x580> = uVar17;
  uVar17 = {d 0.101389};
  <+0x5c8> = {d -0.152778};
  <+0x5c0> = uVar17;
  uVar17 = {d 0.194444};
  <+0x5d8> = {d -0.416667};
  <+0x5d0> = uVar17;
  <+0x600> = {d 0.0078125};
  <+0x630> = uStack_438;
  <+0x628> = local_440;
  <+0x640> = uStack_428;
  <+0x638> = uStack_430;
  <+0x610> = uStack_458;
  <+0x608> = local_460;
  <+0x620> = uStack_448;
  <+0x618> = uStack_450;
  iVar33 = -(uint)(-1 < (int)((uint)CONCAT12(bVar8,(ushort)bVar8) << 0x1f));
  iVar34 = -(uint)(-1 < (int)((uint)bVar8 << 0x1f));
  iVar35 = -(uint)(-1 < (int)((uint)bVar8 << 0x1f));
  iVar36 = -(uint)(-1 < (int)((uint)bVar8 << 0x1f));
  bVar37 = (byte){f 16, -16};
  uVar14 = (ulong){f 16, -16} >> 8;
  uVar13 = (ulong){f 16, -16} >> 0x10;
  uVar22 = (ulong){f 16, -16} >> 0x18;
  uVar16 = (ulong){f 16, -16} >> 0x20;
  uVar1 = (ulong){f 16, -16} >> 0x28;
  uVar2 = (ulong){f 16, -16} >> 0x30;
  uVar3 = (ulong){f 16, -16} >> 0x38;
  <+0x658> =
       CONCAT17((byte)((uint)iVar36 >> 0x18) & (byte)((ulong){d 19660.8} >> 0x38),
                CONCAT16((byte)((uint)iVar36 >> 0x10) & (byte)((ulong){d 19660.8} >> 0x30),
                         CONCAT15((byte)((uint)iVar36 >> 8) & (byte)((ulong){d 19660.8} >> 0x28),
                                  CONCAT14((byte)iVar36 & (byte)((ulong){d 19660.8} >> 0x20),
                                           CONCAT13((byte)((uint)iVar35 >> 0x18) &
                                                    (byte)((ulong){d 19660.8} >> 0x18),
                                                    CONCAT12((byte)((uint)iVar35 >> 0x10) &
                                                             (byte)((ulong){d 19660.8} >> 0x10),
                                                             CONCAT11((byte)((uint)iVar35 >> 8) &
                                                                      (byte)((ulong){d 19660.8}
                                                                            >> 8),
                                                                      (byte)iVar35 &
                                                                      (byte){d 19660.8})))))));
  <+0x650> =
       CONCAT17((byte)((uint)iVar34 >> 0x18) & (byte)uVar3,
                CONCAT16((byte)((uint)iVar34 >> 0x10) & (byte)uVar2,
                         CONCAT15((byte)((uint)iVar34 >> 8) & (byte)uVar1,
                                  CONCAT14((byte)iVar34 & (byte)uVar16,
                                           CONCAT13((byte)((uint)iVar33 >> 0x18) & (byte)uVar22,
                                                    CONCAT12((byte)((uint)iVar33 >> 0x10) &
                                                             (byte)uVar13,
                                                             CONCAT11((byte)((uint)iVar33 >> 8) &
                                                                      (byte)uVar14,
                                                                      (byte)iVar33 & bVar37)))))));
  <+0x660> = uVar32;
  <+0x668> = uVar29;
  <+0x67c> = uVar31;
  <+0x670> = 0;
  <+0x6e0> = 0;
  <shadow.ycc.dodgeFill.b> = 0;
  <shadow.ycc.dodgeFill.r> = 0;
  <shadow.ycc.burnFill.b> = 0;
  <shadow.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.normalFill.b> = 0;
  <edgeBleed.ycc.normalFill.r> = 0;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <+0x5e8> = 0;
  <+0x5e0> = 0;
  <+0x698> = 0;
  <+0x690> = 0;
  <+0x688> = 0;
  <+0x680> = 0;
  <+0x6b8> = 0;
  <+0x6b0> = 0;
  <+0x6c8> = 0;
  <+0x6c0> = 0;
  <+0x6d6> = 0;
  <+0x6ce> = 0;
  <+0x6f8> = 0;
  <+0x6f0> = 0;
  <shadow.opacity> = uVar20;
  <+0x30> = 160;
  <+0x38> = local_598;
  <+0x50> = 0x201;
  <+0x78> = local_5c8;
  <+0x80> = uVar21;
  <+0x84> = CONCAT31(uStack_26c,uStack_270._3_1_);
  <+0x81> = uStack_270;
  <+0x88> = local_5d8;
  <+0x90> = uVar23;
  <+0x91> = (char)local_5ec;
  <shadow.ycc.black> = 0;
  <shadow.ycc.normalFill.r> = uStack_5a8;
  <shadow.ycc.normalFill.b> = local_5b0;
  <shadow.ycc.normalFill?nil> = (char)local_5b4;
  <shadow.ycc.dodgeFill?nil> = 1;
  <shadow.ycc.burnFill?nil> = 1;
  <+0x108> = 1;
  <+0x110> = 0;
  <+0x118> = 1;
  <+0x120> = 0;
  <+0x128> = 1;
  <+0x129> = (char)local_5e8;
  <blur.opacities.3> = 3.05176e-05;
  <blur.distances.0.kind> = 1;
  <blur.distances.1.v> = -1f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.blurRadius> = uVar20;
  <+0x170> = 160;
  <+0x178> = uVar25;
  <+0x17c> = 4f;
  <+0x190> = 0x201;
  <blur.outerRefractionBlurRadius> = uVar27;
  <blur.outerRefractionBlurRadius?nil> = (char)local_5c0;
  <refraction.innerHeightRange.hi> = 20;
  <refraction.outerHeightRange.hi> = 0x7ff0000000000000;
  <refraction.outerAmountRange.hi> = 0x7ff0000000000000;
  <edgeBleed.opacity> = 64;
  <+0x210> = 160;
  <+0x218> = uVar18;
  <+0x230> = 0x201;
  <edgeBleed.normalizedHeight> = 0.35;
  <edgeBleed.maxBlurRadius> = 160;
  <edgeBleed.ycc.normalFill?nil> = 1;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill?nil> = 1;
  <+0x29d> = ((byte)uVar6 ^ 0xff) & 1;
  <faceEffect.opacity> = 1f;
  <faceEffect.ycc.saturation> = 1f;
  <faceEffect.ycc.normalFill.r> = uStack_588;
  <faceEffect.ycc.normalFill.b> = local_590;
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill?nil> = 1;
  <+0x411> = CONCAT53(uStack_300,local_303);
  <+0x510> = 0;
  <+0x518> = 1;
  <+0x520> = 0;
  <+0x528> = 1;
  <+0x539> = 1;
  <+0x550> = 0;
  <+0x558> = 1;
  <+0x560> = 0;
  <+0x568> = 1;
  <+0x579> = 1;
  <+0x590> = 0;
  <+0x598> = 1;
  <+0x5a0> = 0;
  <+0x5a8> = 1;
  <+0x5b9> = 1;
  <+0x5f0> = 0;
  <+0x5f8> = -2.58082;
  <+0x648> = local_420;
  <+0x664> = 0;
  <+0x678> = 0;
  <+0x6a0> = 0;
  <+0x6a8> = 0xff0000000000;
  <+0x6e8> = 0;
  FUN_195eda2a0(&local_d0);
  FUN_195dabb50(&local_2b0,&DAT_1eda3b6c0,0x195fa8230);
  <+0x6e8> = uStack_c8;
  <+0x6e0> = local_d0;
  <+0x6f8> = uStack_b8;
  <+0x6f0> = uStack_c0;
  return;
}


//######## CartouchePopoverRecipe.anon.Refraction (spec) 0x195efce14
// === 195efce14 spec

void FUN_195efce14(long param_1)
{
  <refraction.innerHeightRange.lo> = 5;
  <refraction.innerHeightRange.hi> = 5;
  return;
}


//######## ChicletRecipe.anon.Modifier (spec) 0x195efcfb8
// === 195efe304 spec

/* WARNING: Removing unreachable block (ram,0x000195efe3d8) */
/* WARNING: Removing unreachable block (ram,0x000195efe360) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efe304(undefined8 <backdropScale>,long param_2)
{
  lVar5 = 0;
  func_0x0001981217d0();
  lVar10 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar13 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  func_0x000198120110();
  lVar11 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  uVar14 = (long)puVar13 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar7 + 0x18);
  uVar8 = uVar14;
  (**(code **)(lVar11 + 0x68))(uVar14,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  uVar9 = param_2 + iVar2;
  func_0x0001980ff320(uVar9,uVar14,lVar6,uVar8);
  (**(code **)(lVar11 + 8))(uVar14,lVar6);
  if ((uVar9 & 1) == 0) {
    uVar14 = 0;
    FUN_195ed0900();
    bVar3 = (*(ushort *)(param_2 + *(int *)(uVar14 + 0x14) + 1) & 0x420) != 0;
  }
  else {
    bVar3 = false;
  }
  FUN_195ed53f0();
  <ringShadow.maskAmount> = 0;
  <blurFill.darkenOpacity> = 0;
  <blurFill.blurRadius> = 0;
  <ringShadow.verticalOffset> = 0;
  <ringShadow.blurRadius> = 0;
  <ringShadow.strokeWidth> = 0;
  <ringShadow.opacity> = 0;
  if ((uVar14 & 1) == 0) {
    FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    uVar12 = {d 90};
    <+0x170> = {d 235};
    <blur.blurRadius> = uVar12;
    <+0x178> = {d 512};
    uVar12 = {f 0, 1.4013e-45};
    <+0x188> = {d 0};
    <+0x180> = uVar12;
    <+0x190> = 0x201;
    <refraction.outerOpacity> = 0.5f;
  }
  else {
    lVar6 = 0;
    FUN_195ed0900();
    bVar4 = (*(ulong *)(param_2 + *(int *)(lVar6 + 0x14)) & 0x4000) != 0;
    uVar12 = (f 2, f -0);
    if (bVar4) {
      uVar12 = 0.25f;
    }
    puVar1 = &DAT_1e3f0d2a0;
    if (bVar4) {
      puVar1 = (undefined *)0x0;
    }
    FUN_195efb144(<backdropScale>,<+0x8>);
    <backdropScale> = uVar12;
    <+0x8> = puVar1;
  }
  <refraction.normalizedInnerAmount> = -0.65;
  <refraction.normalizedInnerHeight> = 0.15;
  <refraction.normalizedOuterAmount> = 0.35;
  <refraction.normalizedOuterHeight> = 0.13;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  FUN_195eda468(<shadow.opacity>,<+0x30>,<+0x38>,<+0x40>,<+0x48>,<+0x50>
                ,<+0x51>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  (**(code **)(lVar10 + 0x68))(puVar13,*_DAT_1e01830d0,lVar5);
  uVar15 = 0;
  uVar16 = 0;
  uVar17 = 0;
  uVar18 = 0;
  func_0x0001981218c0(puVar13);
  <faceEffect.opacity> = 1f;
  bVar4 = (uVar9 & 1) == 0;
  uVar19 = 0.05f;
  if (bVar4) {
    uVar19 = 0.12f;
  }
  uVar21 = 0.3f;
  if (bVar4) {
    uVar21 = 0.8f;
  }
  uVar20 = 0.8f;
  if (bVar4) {
    uVar20 = 1.2f;
  }
  <faceEffect.ycc.black> = uVar19;
  <faceEffect.ycc.white> = uVar21;
  <faceEffect.ycc.saturation> = uVar20;
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar18 >> 0x18),
                CONCAT16((char)((uint)uVar18 >> 0x10),
                         CONCAT15((char)((uint)uVar18 >> 8),CONCAT14((char)uVar18,uVar17))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((uint)uVar16 >> 0x18),
                CONCAT16((char)((uint)uVar16 >> 0x10),
                         CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  if (bVar3) {
    <faceEffect.ycc.white> = 1f;
  }
  if ((uVar14 & 1) != 0) {
    <highlights.keyYCC.white> = 0.85f;
    <highlights.fillYCC.white> = 0.85f;
  }
  return;
}


//######## ChicletRecipe.anon.IncreasedContrast (spec) 0x195efcfbc
// === 195efe0d0 spec

/* WARNING: Removing unreachable block (ram,0x000195efe1a4) */
/* WARNING: Removing unreachable block (ram,0x000195efe12c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efe0d0(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar6 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar8 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(uVar3 - 8);
  uVar4 = uVar3;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar9 = (long)puVar8 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar4 & 1) != 0) {
    <faceEffect.ycc.black> = 9.76563e-05;
    lVar5 = 0;
    FUN_195f3c68c();
    iVar1 = *(int *)(lVar5 + 0x18);
    (**(code **)(lVar7 + 0x68))(lVar9,*_DAT_1e017dd58,uVar3);
    uVar4 = param_2 + iVar1;
    func_0x000198120100(uVar4,lVar9);
    (**(code **)(lVar7 + 8))(lVar9,uVar3);
    (**(code **)(lVar6 + 0x68))(puVar8,*_DAT_1e01830d0,lVar2);
    uVar13 = 0.75f;
    if ((uVar4 & 1) == 0) {
      uVar13 = 0.35f;
    }
    uVar10 = 0;
    uVar11 = 0;
    uVar12 = 0;
    func_0x0001981218c0(puVar8);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar11 >> 0x18),
                  CONCAT16((char)((uint)uVar11 >> 0x10),
                           CONCAT15((char)((uint)uVar11 >> 8),CONCAT14((char)uVar11,uVar10))));
    <faceEffect.ycc.normalFill?nil> = 0;
    <highlights.keyOpacity> = 5.49317e-05;
  }
  return;
}


//######## ChicletRecipe.anon.PostProcess (params) 0x195efcfc0
// === 195efd51c params

/* WARNING: Removing unreachable block (ram,0x000195efd590) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efd51c(long param_1,long param_2)
{
  undefined1 auStack_848 [272];
  undefined1 auStack_610 [272];
  undefined4 local_2c8 [2];
  uVar6 = 0;
  func_0x000198120110();
  lVar15 = *(long *)(uVar6 - 8);
  uVar7 = uVar6;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar15 + 0x40));
  lVar23 = (long)&local_9e0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar7 & 1) == 0) {
    lVar8 = 0;
    FUN_195f3c68c();
    iVar10 = *(int *)(lVar8 + 0x18);
    lVar8 = lVar23;
    (**(code **)(lVar15 + 0x68))(lVar23,*_DAT_1e017dd58,uVar6);
    FUN_195e7d9c0();
    uVar7 = param_2 + iVar10;
    func_0x0001980ff320(uVar7,lVar23,uVar6,lVar8);
    (**(code **)(lVar15 + 8))(lVar23,uVar6);
    bVar3 = (uVar7 & 1) == 0;
    local_95c = 0.7f;
    if (bVar3) {
      local_95c = 0.6f;
    }
    local_960 = 1.2f;
    if (bVar3) {
      local_960 = 1.1f;
    }
    iVar10 = (int)<highlights.hdr>;
    uVar5 = 0x10d;
    func_0x000198104610(&local_4e8);
    iVar4 = (int)&local_4e8;
    FUN_195e7d8c0();
    uVar2 = local_95c;
    uVar1 = local_960;
    if (iVar4 == 1) {
      local_4d8 = 0;
      local_4d0 = 0;
      local_4c8 = 0;
      local_4c0 = 0;
      local_4b8 = 0;
      local_448 = 0;
      local_440 = 0;
      local_438 = 0;
      local_434 = 0;
      local_430 = 0;
      local_9bc = 1;
      local_9c0 = 1;
      uVar14 = 1;
      local_3f0 = 0;
      local_3e8 = 0;
      local_3e4 = 0;
      local_3e0 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      uVar24 = 0;
      uVar26 = 0;
      uVar28 = 0;
      uVar30 = 0;
      uVar22 = 0;
      local_4e4 = iVar10;
      local_4cc = uVar5;
      uVar5 = 1;
      uVar25 = 0;
      uVar29 = 0;
    }
    else {
      local_4ec = local_493;
      local_4ea = local_491;
      local_4f0 = local_47f;
      local_4ee = local_47d;
      local_4f2 = local_469;
      local_4f4 = local_46b;
      local_9bc = (uint)local_41c;
      local_4f6 = local_419;
      local_4f8 = local_41b;
      local_9c0 = (uint)local_408;
      local_4fa = local_405;
      local_4fc = local_407;
      uVar14 = (uint)local_3f4;
      local_4fe = local_3f1;
      local_500 = local_3f3;
      uVar16 = local_404;
      uVar17 = local_42c;
      uVar18 = local_424;
      uVar19 = local_418;
      uVar20 = local_410;
      uVar21 = local_3fc;
      uVar24 = local_468;
      uVar26 = local_4e0;
      uVar28 = local_460;
      uVar30 = local_450;
      uVar22 = local_3dc;
      uVar5 = local_454;
      uVar25 = local_4e8;
      uVar29 = local_458;
    }
    local_180 = local_95c;
    local_17c = 1f;
    local_178 = local_960;
    local_16c = 0;
    local_174 = 0;
    local_164 = 1;
    local_161 = local_4ea;
    local_163 = local_4ec;
    local_160 = 0;
    local_158 = 0;
    local_150 = 1;
    local_14f = local_4f0;
    local_14d = local_4ee;
    local_14c = 0;
    local_144 = 0;
    local_13c = 1;
    local_13b = local_4f4;
    local_139 = local_4f2;
    local_990 = CONCAT44(local_990._4_4_,local_438);
    local_ec = (undefined1)local_9bc;
    local_e9 = local_4f6;
    local_eb = local_4f8;
    local_d8 = (undefined1)local_9c0;
    local_d5 = local_4fa;
    local_d7 = local_4fc;
    local_9c8 = CONCAT44(local_9c8._4_4_,uVar14);
    local_c4 = (undefined1)uVar14;
    local_c1 = local_4fe;
    local_c3 = local_500;
    local_9d8 = CONCAT44(local_9d8._4_4_,local_3e8);
    local_2c8[0] = 0;
    local_2b8 = 0;
    local_2c0 = 0;
    local_2b0 = 0;
    local_278 = 0;
    uStack_280 = 0;
    local_288 = 0;
    uStack_290 = 0;
    local_298 = 0;
    uStack_2a0 = 0;
    local_2a8 = 0;
    local_274 = 1;
    local_268 = 0;
    local_270 = 0;
    local_260 = 1;
    local_254 = 0;
    local_25c = 0;
    local_24c = 1;
    local_240 = 0;
    local_248 = 0;
    local_238 = 0;
    local_200 = 0;
    uStack_208 = 0;
    local_210 = 0;
    uStack_218 = 0;
    local_220 = 0;
    uStack_228 = 0;
    local_230 = 0;
    local_1fc = 1;
    local_1f0 = 0;
    local_1f8 = 0;
    local_1e8 = 1;
    local_1dc = 0;
    local_1e4 = 0;
    local_1d4 = 1;
    uStack_1c0 = 0;
    uStack_1c8 = 0;
    local_1c3 = 0;
    local_1d0 = 0;
    puVar9 = &local_1b8;
    local_9e0 = local_3e0;
    local_9dc = local_3e4;
    local_9d0 = local_3f0;
    local_9b8 = local_4b8;
    local_9b0 = local_4c0;
    local_9a8 = local_4c8;
    local_99c = local_430;
    local_998 = local_434;
    local_994 = local_4cc;
    local_988 = local_440;
    local_980 = local_4d0;
    local_97c = local_4e4;
    local_978 = local_448;
    local_970 = local_4d8;
    local_968 = param_1;
    local_1b8 = uVar25;
    local_1b4 = local_4e4;
    local_1b0 = uVar26;
    local_1a8 = local_4d8;
    local_1a0 = local_4d0;
    local_19c = local_4cc;
    local_198 = local_4c8;
    local_190 = local_4c0;
    local_188 = local_4b8;
    local_138 = uVar24;
    local_130 = uVar28;
    local_128 = uVar29;
    local_124 = uVar5;
    local_120 = uVar30;
    local_118 = local_448;
    local_110 = local_440;
    local_108 = local_438;
    local_104 = local_434;
    local_100 = local_430;
    local_fc = uVar17;
    local_f4 = uVar18;
    local_e8 = uVar19;
    local_e0 = uVar20;
    local_d4 = uVar16;
    local_cc = uVar21;
    local_c0 = local_3f0;
    local_b8 = local_3e8;
    local_b4 = local_3e4;
    local_b0 = local_3e0;
    local_ac = uVar22;
    FUN_195ed8068(puVar9,local_2c8);
    if (((ulong)puVar9 & 1) == 0) {
      local_3d4 = local_97c;
      local_3c8 = local_970;
      local_3c0 = local_980;
      local_3bc = local_994;
      local_3b8 = local_9a8;
      local_3b0 = local_9b0;
      local_3a8 = local_9b8;
      local_3a0 = uVar2;
      local_39c = 1f;
      local_398 = uVar1;
      local_38c = 0;
      local_394 = 0;
      local_384 = 1;
      local_383 = local_4ec;
      local_381 = local_4ea;
      local_378 = 0;
      local_380 = 0;
      local_370 = 1;
      local_36f = local_4f0;
      local_36d = local_4ee;
      local_36c = 0;
      local_364 = 0;
      local_35c = 1;
      local_35b = local_4f4;
      local_359 = local_4f2;
      local_338 = local_978;
      local_330 = local_988;
      local_328 = (undefined4)local_990;
      local_324 = local_998;
      local_320 = local_99c;
      local_30c = (undefined1)local_9bc;
      local_309 = local_4f6;
      local_30b = local_4f8;
      local_2f8 = (undefined1)local_9c0;
      local_2f5 = local_4fa;
      local_2f7 = local_4fc;
      local_2e4 = (undefined1)local_9c8;
      local_2e1 = local_4fe;
      local_2e3 = local_500;
      local_2e0 = local_9d0;
      local_2d8 = (undefined4)local_9d8;
      local_2d4 = local_9dc;
      local_2d0 = local_9e0;
      local_3d8 = uVar25;
      local_3d0 = uVar26;
      local_358 = uVar24;
      local_350 = uVar28;
      local_348 = uVar29;
      local_344 = uVar5;
      local_340 = uVar30;
      local_31c = uVar17;
      local_314 = uVar18;
      local_308 = uVar19;
      local_300 = uVar20;
      local_2f4 = uVar16;
      local_2ec = uVar21;
      local_2cc = uVar22;
      _CGPointMake(&local_3d8);
      func_0x000198104610(auStack_610,&local_3d8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_610);
    }
    param_1 = local_968;
    func_0x000198104610(local_968 + 0x1e8,auStack_610,0x10d);
    uVar5 = 0x10d;
    func_0x000198104610(&local_720,auStack_610);
    iVar10 = (int)&local_720;
    FUN_195e7d8c0();
    uVar2 = local_95c;
    uVar1 = local_960;
    if (iVar10 == 1) {
      uVar11 = 1;
      local_708 = 0;
      local_710 = 0;
      local_718 = 0;
      local_720 = 0;
      uVar12 = 1;
      uVar13 = 1;
      local_6a0 = 0;
      local_698 = 0;
      local_690 = 0;
      local_688 = 0;
      local_680 = 0;
      local_678 = 0;
      local_628 = 0;
      local_620 = 0;
      local_61c = 0;
      local_618 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      uVar24 = 0;
      uVar26 = 0;
      uVar28 = 0;
      uVar22 = 0;
      local_71c = uVar5;
      local_68c = uVar14;
      uVar5 = 1;
      uVar25 = 0;
      uVar29 = 0;
      uVar27 = 0;
    }
    else {
      uVar11 = (uint)local_6cc;
      local_722 = local_6c9;
      local_724 = local_6cb;
      uVar12 = (uint)local_6b8;
      local_726 = local_6b5;
      local_728 = local_6b7;
      uVar13 = (uint)local_6a4;
      local_72a = local_6a1;
      local_72c = local_6a3;
      local_72e = local_651;
      local_730 = local_653;
      local_732 = local_63d;
      local_734 = local_63f;
      local_736 = local_629;
      local_738 = local_62b;
      uVar16 = local_6d4;
      uVar17 = local_6dc;
      uVar18 = local_6c8;
      uVar19 = local_6c0;
      uVar20 = local_6b4;
      uVar21 = local_6ac;
      uVar24 = local_6f0;
      uVar26 = local_6f8;
      uVar28 = local_700;
      uVar22 = local_614;
      uVar5 = local_704;
      uVar25 = local_6e8;
      uVar29 = local_6e4;
      uVar27 = local_6e0;
    }
    local_384 = (undefined1)uVar11;
    local_381 = local_722;
    local_383 = local_724;
    local_988 = CONCAT44(local_988._4_4_,uVar12);
    local_370 = (undefined1)uVar12;
    local_36f = local_728;
    local_36d = local_726;
    local_9a8 = CONCAT44(local_9a8._4_4_,uVar13);
    local_35c = (undefined1)uVar13;
    local_35b = local_72c;
    local_359 = local_72a;
    local_328 = local_95c;
    local_324 = 1f;
    local_320 = local_960;
    local_31c = 0;
    local_314 = 0;
    local_30c = 1;
    local_309 = local_72e;
    local_30b = local_730;
    local_308 = 0;
    local_300 = 0;
    local_2f8 = 1;
    local_2f5 = local_732;
    local_2f7 = local_734;
    local_2f4 = 0;
    local_2ec = 0;
    local_2e4 = 1;
    local_2e3 = local_738;
    local_2e1 = local_736;
    puVar9 = &local_3d8;
    local_9d8 = local_678;
    local_9d0 = local_680;
    local_9c8 = local_688;
    local_9c0 = local_68c;
    local_9bc = local_690;
    local_9b8 = local_698;
    local_9b0 = local_6a0;
    local_99c = local_618;
    local_998 = local_61c;
    local_994 = local_620;
    local_990 = local_628;
    local_980 = local_720;
    local_97c = local_71c;
    local_978 = local_718;
    local_970 = local_710;
    local_960 = local_708;
    local_95c = uVar11;
    local_3d8 = local_720;
    local_3d4 = local_71c;
    local_3d0 = local_718;
    local_3c8 = local_710;
    local_3c0 = local_708;
    local_3bc = uVar5;
    local_3b8 = uVar28;
    local_3b0 = uVar26;
    local_3a8 = uVar24;
    local_3a0 = uVar25;
    local_39c = uVar29;
    local_398 = uVar27;
    local_394 = uVar17;
    local_38c = uVar16;
    local_380 = uVar18;
    local_378 = uVar19;
    local_36c = uVar20;
    local_364 = uVar21;
    local_358 = local_6a0;
    local_350 = local_698;
    local_348 = local_690;
    local_344 = local_68c;
    local_340 = local_688;
    local_338 = local_680;
    local_330 = local_678;
    local_2e0 = local_628;
    local_2d8 = local_620;
    local_2d4 = local_61c;
    local_2d0 = local_618;
    local_2cc = uVar22;
    FUN_195ed8068(puVar9,local_2c8);
    if (((ulong)puVar9 & 1) == 0) {
      local_958 = local_980;
      local_954 = local_97c;
      local_950 = local_978;
      uStack_948 = local_970;
      local_940 = local_960;
      local_904 = (undefined1)local_95c;
      local_903 = local_724;
      local_901 = local_722;
      local_8f0 = (undefined1)local_988;
      local_8ef = local_728;
      local_8ed = local_726;
      local_8dc = (undefined1)local_9a8;
      local_8db = local_72c;
      local_8d9 = local_72a;
      local_8d8 = local_9b0;
      uStack_8d0 = local_9b8;
      local_8c8 = local_9bc;
      local_8c4 = local_9c0;
      local_8c0 = local_9c8;
      uStack_8b8 = local_9d0;
      local_8b0 = local_9d8;
      local_8a8 = uVar2;
      local_8a4 = 1f;
      local_8a0 = uVar1;
      local_89c = 0;
      local_894 = 0;
      local_88c = 1;
      local_889 = local_72e;
      local_88b = local_730;
      local_888 = 0;
      uStack_880 = 0;
      local_878 = 1;
      local_875 = local_732;
      local_877 = local_734;
      local_874 = 0;
      local_86c = 0;
      local_864 = 1;
      local_863 = local_738;
      local_861 = local_736;
      local_860 = local_990;
      local_858 = local_994;
      local_854 = local_998;
      local_850 = local_99c;
      local_93c = uVar5;
      local_938 = uVar28;
      uStack_930 = uVar26;
      local_928 = uVar24;
      local_920 = uVar25;
      uStack_91c = uVar29;
      local_918 = uVar27;
      local_914 = uVar17;
      local_90c = uVar16;
      local_900 = uVar18;
      uStack_8f8 = uVar19;
      local_8ec = uVar20;
      local_8e4 = uVar21;
      local_84c = uVar22;
      _CGPointMake(&local_958);
      func_0x000198104610(auStack_848,&local_958,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_848);
    }
    func_0x000198104610(<highlights.hdr>,auStack_848,0x10d);
  }
  uVar16 = {d -0.0078125};
  <tinting.distances.1> = {d 0};
  <tinting.opacity> = uVar16;
  <tinting?nil> = 0;
  return;
}


//######## AppIconsRecipe.AppIconsMac (spec) 0x195efcffc
// === 195efe728 spec

/* WARNING: Removing unreachable block (ram,0x000195efe7fc) */
/* WARNING: Removing unreachable block (ram,0x000195efe784) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efe728(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar6 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar4 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(uVar4 - 8);
  uVar8 = uVar4;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar10 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar8 & 1) != 0) {
    lVar5 = 0;
    FUN_195f3c68c();
    if (*(char *)(param_2 + *(int *)(lVar5 + 0x3c)) == '\x01') {
      iVar1 = *(int *)(lVar5 + 0x18);
      lVar5 = lVar10;
      (**(code **)(lVar7 + 0x68))(lVar10,*_DAT_1e017dd58,uVar4);
      FUN_195e7d9c0();
      uVar8 = param_2 + iVar1;
      func_0x0001980ff320(uVar8,lVar10,uVar4,lVar5);
      (**(code **)(lVar7 + 8))(lVar10,uVar4);
      if ((uVar8 & 1) == 0) {
        lVar7 = 0;
        FUN_195ed0900();
        uVar8 = *(ulong *)(param_2 + *(int *)(lVar7 + 0x14));
        <darkSpecular.spreadSDR> = 1.85005;
        <darkSpecular.spread> = 1.85005;
        <darkSpecular.colorBias> = -0.5;
        (**(code **)(lVar6 + 0x68))(puVar9,*_DAT_1e01830d0,lVar3);
        uVar11 = 0;
        uVar12 = 0;
        uVar13 = 0;
        uVar14 = 0;
        func_0x0001981218c0(puVar9);
        uVar2 = {f 1, 0.25};
        <faceEffect.ycc.white> = {d 0.025};
        <faceEffect.opacity> = uVar2;
        <faceEffect.ycc.normalFill.b> =
             CONCAT17((char)((uint)uVar14 >> 0x18),
                      CONCAT16((char)((uint)uVar14 >> 0x10),
                               CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
        <faceEffect.ycc.normalFill.r> =
             CONCAT17((char)((uint)uVar12 >> 0x18),
                      CONCAT16((char)((uint)uVar12 >> 0x10),
                               CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar11))));
        <faceEffect.ycc.normalFill?nil> = 0;
        <faceEffect.ycc.dodgeFill.b> = 0;
        <faceEffect.ycc.dodgeFill.r> = 0;
        <faceEffect.ycc.dodgeFill?nil> = 1;
        <faceEffect.ycc.burnFill.b> = 0;
        <faceEffect.ycc.burnFill.r> = 0;
        <faceEffect.ycc.burnFill?nil> = 1;
        <faceEffect.maxLuminance> = 0.0015625;
        if ((uVar8 & 0x42000) != 0) {
          <faceEffect.ycc.white> = 1.06f;
        }
      }
      else {
        <darkSpecular.spreadSDR> = 1.85005;
        <darkSpecular.spread> = 1.85005;
        <darkSpecular.colorBias> = -0.5;
        (**(code **)(lVar6 + 0x68))(puVar9,*_DAT_1e01830d0,lVar3);
        uVar11 = 0;
        uVar12 = 0;
        uVar13 = 0;
        uVar14 = 0;
        func_0x0001981218c0(puVar9);
        uVar2 = {f 1, 0.05};
        <faceEffect.ycc.white> = {d 0.000878906};
        <faceEffect.opacity> = uVar2;
        <faceEffect.ycc.normalFill.b> =
             CONCAT17((char)((uint)uVar14 >> 0x18),
                      CONCAT16((char)((uint)uVar14 >> 0x10),
                               CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
        <faceEffect.ycc.normalFill.r> =
             CONCAT17((char)((uint)uVar12 >> 0x18),
                      CONCAT16((char)((uint)uVar12 >> 0x10),
                               CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar11))));
        <faceEffect.ycc.normalFill?nil> = 0;
        <faceEffect.ycc.dodgeFill.b> = 0;
        <faceEffect.ycc.dodgeFill.r> = 0;
        <faceEffect.ycc.dodgeFill?nil> = 1;
        <faceEffect.ycc.burnFill.b> = 0;
        <faceEffect.ycc.burnFill.r> = 0;
        <faceEffect.ycc.burnFill?nil> = 1;
        <faceEffect.maxLuminance> = 0.0078125;
      }
    }
  }
  return;
}


//######## ClearSpec.anon.Modifier (spec) 0x195efeb98
// === 195f020d8 spec

/* WARNING: Removing unreachable block (ram,0x000195f023c8) */
/* WARNING: Removing unreachable block (ram,0x000195f0218c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f020d8(undefined8 <backdropScale>,long param_2)
{
  ushort *puVar1;
  undefined1 auVar13 [16];
  undefined1 auStack_220 [8];
  undefined1 auStack_200 [416];
  puVar4 = &DAT_1eda3a940;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar4 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  puVar10 = auStack_220 + -extraout_x8;
  uVar5 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(uVar5 - 8);
  uVar12 = uVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar9 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar2 = {f 0.5, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar2;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = 1f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  <refraction.normalizedInnerAmount> = -1;
  <refraction.normalizedInnerHeight> = 0.36;
  <refraction.outerOpacity> = 0;
  local_204 = *_DAT_1e01830d0;
  local_210 = *(code **)(lVar7 + 0x68);
  (*local_210)(lVar9,local_204,uVar5);
  uVar15 = 1f;
  uVar14 = 1f;
  uVar17 = 0;
  uVar11 = func_0x0001981218c0(lVar9);
  bVar3 = (uVar12 & 1) == 0;
  uVar16 = 0.125f;
  if (bVar3) {
    uVar16 = 0.075f;
  }
  uVar18 = 1.08f;
  if (bVar3) {
    uVar18 = 1.15f;
  }
  <faceEffect.ycc.black> = uVar16;
  <faceEffect.ycc.white> = uVar18;
  <faceEffect.ycc.saturation> = 1.06f;
  uVar11 = uVar11 & 0xffffffff;
  uVar14 = uVar14 & 0xffffffff;
  <faceEffect.ycc.normalFill.b> = (char)uVar14;
  <+0x2b9> = (char)(uVar14 >> 8);
  <+0x2ba> = (char)(uVar14 >> 0x10);
  <+0x2bb> = (char)(uVar14 >> 0x18);
  <faceEffect.ycc.normalFill.a> = (char)uVar17;
  <+0x2bd> = (char)((uint)uVar17 >> 8);
  <+0x2be> = (char)((uint)uVar17 >> 0x10);
  <+0x2bf> = (char)((uint)uVar17 >> 0x18);
  <faceEffect.ycc.normalFill.r> = (char)uVar11;
  <+0x2b1> = (char)(uVar11 >> 8);
  <+0x2b2> = (char)(uVar11 >> 0x10);
  <+0x2b3> = (char)(uVar11 >> 0x18);
  <faceEffect.ycc.normalFill.g> = (char)uVar15;
  <+0x2b5> = (char)((uint)uVar15 >> 8);
  <+0x2b6> = (char)((uint)uVar15 >> 0x10);
  <+0x2b7> = (char)((uint)uVar15 >> 0x18);
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  FUN_195eda468(<shadow.opacity>,<+0x30>,<+0x38>,<+0x40>,<+0x48>,<+0x50>
                ,<+0x51>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  FUN_195dabb50(<shadow.vibrancyContribution>,&DAT_1eda3b6c0,0x195fa8230);
  <shadow.vibrancyContribution> = 0;
  <+0x129> = 0;
  if ((uVar12 & 1) != 0) {
    uVar16 = *_DAT_1e017dd68;
    lVar7 = 0;
    func_0x000198120110();
    lVar8 = *(long *)(lVar7 + -8);
    local_218 = uVar5;
    (**(code **)(lVar8 + 0x68))(puVar10,uVar16,lVar7);
    (**(code **)(lVar8 + 0x38))(puVar10,0,1,lVar7);
    FUN_195eef0b0(auStack_200,param_2,puVar10);
    FUN_195dabb50(puVar10,&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
    FUN_195edac00(<highlights.inset>);
    func_0x000198104610(<highlights.inset>,auStack_200,0x188);
    <highlights.diffuseHeightScale> = {d 0.000170898};
    <highlights.diffuseAmountScale> = 0.15f;
    <blur.blurRadius> = 0.75f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
    <refraction.normalizedInnerAmount> = -0.65;
    (*local_210)(lVar9,local_204,local_218);
    uVar16 = 0.25f;
    uVar5 = 0.25f;
    uVar15 = 1f;
    uVar12 = func_0x0001981218c0(lVar9);
    <highlights.keyYCC.black> = 0.15f;
    <highlights.keyYCC.white> = {d 0.0078125};
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    uVar12 = uVar12 & 0xffffffff;
    uVar5 = uVar5 & 0xffffffff;
    <highlights.keyYCC.dodgeFill.b> = (char)uVar5;
    <+0x3b5> = (char)(uVar5 >> 8);
    <+0x3b6> = (char)(uVar5 >> 0x10);
    <+0x3b7> = (char)(uVar5 >> 0x18);
    <highlights.keyYCC.dodgeFill.a> = (char)uVar15;
    <+0x3b9> = (char)((uint)uVar15 >> 8);
    <+0x3ba> = (char)((uint)uVar15 >> 0x10);
    <+0x3bb> = (char)((uint)uVar15 >> 0x18);
    <highlights.keyYCC.dodgeFill.r> = (char)uVar12;
    <+0x3ad> = (char)(uVar12 >> 8);
    <+0x3ae> = (char)(uVar12 >> 0x10);
    <+0x3af> = (char)(uVar12 >> 0x18);
    <highlights.keyYCC.dodgeFill.g> = (char)uVar16;
    <+0x3b1> = (char)((uint)uVar16 >> 8);
    <+0x3b2> = (char)((uint)uVar16 >> 0x10);
    <+0x3b3> = (char)((uint)uVar16 >> 0x18);
    <highlights.keyYCC.dodgeFill?nil> = 0;
    <highlights.keyYCC.burnFill.b> = 0;
    <highlights.keyYCC.burnFill.r> = 0;
    <highlights.keyYCC.burnFill?nil> = 1;
    <+0x411> = <+0x3c9>;
    <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
    <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
    <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
    <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
    <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
    <highlights.fillYCC.black> = <highlights.keyYCC.black>;
    <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
    <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  }
  lVar7 = 0;
  FUN_195ed0900();
  puVar1 = (ushort *)(param_2 + *(int *)(lVar7 + 0x20));
  if ((((char)puVar1[1] == '\x01') && (uVar6 = (uint)*puVar1, 0x2c < uVar6 - 8)) &&
     ((1 << (ulong)(uVar6 & 0x1f) & 0x6fU) == 0)) {
    auVar13 = NEON_fmov(1f,4);
    <blur.opacities.2> = auVar13._8_8_;
    <blur.opacities.0> = auVar13._0_8_;
    <faceEffect.ycc.black> = {d 0.0053125};
  }
  return;
}


//######## ClearDiffusionAmount (spec) 0x195efeb9c
// === 195efeb9c spec

void FUN_195efeb9c(ulong param_1,long param_2)
{
  uVar2 = param_1;
  FUN_195ed53f0();
  if ((uVar2 & 1) != 0) {
    lVar3 = 0;
    FUN_195f3c68c();
    pfVar1 = (float *)(param_2 + *(int *)(lVar3 + 0x70));
    if (*(char *)(pfVar1 + 1) != '\x01') {
      fVar4 = *pfVar1;
      if (0.5 <= fVar4) {
        if (0.5 < fVar4) {
          <blurFill.blurRadius> = 16f;
          <blurFill.lightenOpacity> = 0;
          <blurFill.normalOpacity> = fVar4 + -0.5 + fVar4 + -0.5;
        }
      }
      else {
        fVar4 = fVar4 + fVar4;
        if (<+0x191> == '\0') {
          <blur.blurRadius> = (ulong)(uint)(fVar4 * <blur.blurRadius>);
          <+0x178> = 0;
          <+0x170> = 0;
          <+0x188> = 0;
          <+0x180> = 0;
          <+0x190> = 0;
        }
        else if (<+0x191> == '\x02') {
          <+0x178> =
               CONCAT44((float)((ulong)<+0x178> >> 0x20) * fVar4,
                        (float)<+0x178> * fVar4);
          <+0x180> = <+0x180> & 0xffffffffff;
          <+0x191> = 2;
        }
      }
    }
  }
  return;
}


//######## DiffusionBlur (spec) 0x195efedd4
// === 195efec74 spec

void FUN_195efec74(ulong param_1,double *param_2)
{
  uVar3 = param_1;
  FUN_195ed53f0();
  if ((uVar3 & 1) == 0) {
    return;
  }
  lVar4 = 0;
  FUN_195ed0900();
  uVar3 = *(ulong *)((long)param_2 + (long)*(int *)(lVar4 + 0x14)) & 0x4000;
  lVar4 = 4;
  if (uVar3 != 0) {
    lVar4 = 0xc;
  }
  fVar9 = *(float *)(unaff_x20 + lVar4);
  fVar8 = *(float *)(unaff_x20 + (uVar3 >> 0xb));
  lVar4 = 0;
  FUN_195f3c68c();
  pfVar1 = (float *)((long)param_2 + (long)*(int *)(lVar4 + 0x70));
  if (*(char *)(pfVar1 + 1) == '\x01') {
    bVar2 = *(byte *)(unaff_x20 + 0x10);
    fVar7 = 0.5;
  }
  else {
    fVar7 = *pfVar1;
    if (fVar7 <= 0.0) {
      bVar2 = *(byte *)(unaff_x20 + 0x10);
      fVar5 = 0.0;
      goto joined_r0x000195efedcc;
    }
    if (fVar7 <= 0.5) {
      fVar5 = fVar7 + fVar7;
      bVar2 = *(byte *)(unaff_x20 + 0x10);
      goto joined_r0x000195efedcc;
    }
    bVar2 = *(byte *)(unaff_x20 + 0x10);
  }
  fVar5 = 1.0;
joined_r0x000195efedcc:
  fVar6 = 1.0;
  if ((bVar2 & 1) != 0) {
    fVar6 = (float)*param_2;
  }
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = (ulong)(uint)(fVar6 * (fVar8 + (fVar9 - fVar8) * fVar5));
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  if (0.5 < fVar7) {
    <blurFill.blurRadius> = 16f;
    <blurFill.lightenOpacity> = 0;
    <blurFill.normalOpacity> = fVar7 + -0.5 + fVar7 + -0.5;
  }
  return;
}


//######## ClearRecipe.anon.IncreasedContrast (spec) 0x195efedd8
// === 195efedd8 spec

/* WARNING: Removing unreachable block (ram,0x000195efee2c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195efedd8(long param_1)
{
  uVar1 = 0;
  func_0x0001981217d0();
  lVar3 = *(long *)(uVar1 - 8);
  uVar2 = uVar1;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar3 + 0x40));
  FUN_195ed53f0();
  if ((uVar2 & 1) != 0) {
    <faceEffect.ycc.black> = 9.76563e-05;
    (**(code **)(lVar3 + 0x68))
              (&stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),*_DAT_1e01830d0
               ,uVar1);
    uVar7 = 0.35f;
    uVar4 = 0;
    uVar5 = 0;
    uVar6 = 0;
    func_0x0001981218c0(&stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0));
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar7 >> 0x18),
                  CONCAT16((char)((uint)uVar7 >> 0x10),
                           CONCAT15((char)((uint)uVar7 >> 8),CONCAT14((char)uVar7,uVar6))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar5 >> 0x18),
                  CONCAT16((char)((uint)uVar5 >> 0x10),
                           CONCAT15((char)((uint)uVar5 >> 8),CONCAT14((char)uVar5,uVar4))));
    <faceEffect.ycc.normalFill?nil> = 0;
    <highlights.keyOpacity> = 5.49317e-05;
  }
  return;
}


//######## HomescreenCloseAndResizeRecipe.anon.Modifier (spec) 0x195efef54
// === 195efef54 spec

void FUN_195efef54(long param_1)
{
  undefined1 auVar2 [16];
  uVar1 = (uint)param_1;
  auVar2 = NEON_fmov(1f,4);
  <blur.opacities.2> = auVar2._8_8_;
  <blur.opacities.0> = auVar2._0_8_;
  <faceEffect.ycc.black> = 0.0053125;
  FUN_195ed53f0();
  if ((uVar1 & 1) != 0) {
    <highlights.keyYCC.white> = 0.9f;
    <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
    <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
    <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
    <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
    <+0x411> = <+0x3c9>;
    <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
    <highlights.fillYCC.black> = <highlights.keyYCC.black>;
    <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
    <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  }
  return;
}


//######## PosterSwitcherRecipe.anon.Modifier (spec) 0x195eff008
// === 195eff008 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195eff008(long param_1)
{
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = 7f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  <refraction.normalizedOuterHeight> = 1;
  <refraction.normalizedOuterAmount> = 2;
  <refraction.outerOpacity> = 0.6f;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,
                <+0x218>,<+0x220>,
                <+0x228>,<+0x230>,
                <+0x231>);
  <edgeBleed.opacity> = 0.6f;
  <+0x218> = 0;
  <+0x210> = 0;
  <+0x228> = 0;
  <+0x220> = 0;
  <+0x230> = 0;
  <edgeBleed.ycc.black> = {d 0.0078125};
  <edgeBleed.ycc.saturation> = 1f;
  <edgeBleed.ycc.normalFill.b> = 0;
  <edgeBleed.ycc.normalFill.r> = 0;
  <edgeBleed.ycc.normalFill?nil> = 1;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.burnFill?nil> = 1;
  <edgeBleed.normalizedHeight> = 1;
  <edgeBleed.maxBlurRadius> = 120;
  uVar1 = {d 2};
  <edgeBleed.normalizedBlurRadius> = {d 1};
  <edgeBleed.normalizedAmount> = uVar1;
  return;
}


//######## WatchPasscodeRecipe.anon.Modifier (spec) 0x195eff138
// === 195f00e24 spec

/* WARNING: Removing unreachable block (ram,0x000195f00e78) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f00e24(undefined8 <backdropScale>,long param_2)
{
  lVar3 = 0;
  func_0x000198120110();
  lVar6 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar7 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar6 + 0x68))(puVar7,*_DAT_1e017dd68,lVar3);
  uVar5 = param_2 + iVar1;
  func_0x000198120100(uVar5,puVar7);
  (**(code **)(lVar6 + 8))(puVar7,lVar3);
  uVar8 = 0.48f;
  if ((uVar5 & 1) == 0) {
    uVar8 = 0.08f;
  }
  <faceEffect.opacity> = 1f;
  <faceEffect.ycc.black> = uVar8;
  <faceEffect.ycc.white> = {d 0.0078125};
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill.r> = 0;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  lVar3 = 0;
  FUN_195ed0900();
  bVar2 = (*(ulong *)(param_2 + *(int *)(lVar3 + 0x14)) & 4) != 0;
  uVar9 = -0.5;
  if (bVar2) {
    uVar9 = -0.38;
  }
  uVar10 = 0.18;
  if (bVar2) {
    uVar10 = 0.115;
  }
  <refraction.normalizedInnerAmount> = uVar9;
  <refraction.normalizedInnerHeight> = uVar10;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = 3.5f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = 3f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.opacities.3> = (f 1, f -44);
  uVar9 = {d 0.0078125};
  <blur.opacities.1> = {d 3.05176e-05};
  <blur.opacity> = uVar9;
  FUN_195dabb50(<highlights.spread>,&DAT_1eb9cad28,&{f 2.38425e-40, 2.52234e-44});
  <highlights.spread> = 1.65806;
  <+0x469> = 0;
  <highlights.keyYCC.black> = 0.55f;
  uVar9 = {d 0.0140625};
  <highlights.keyYCC.white> = {d 0.0140625};
  <highlights.keyYCC.normalFill.b> = 0;
  <highlights.keyYCC.normalFill.r> = 0;
  <highlights.keyYCC.normalFill?nil> = 1;
  <highlights.keyYCC.dodgeFill.b> = 0;
  <highlights.keyYCC.dodgeFill.r> = 0;
  <highlights.keyYCC.dodgeFill?nil> = 1;
  <highlights.keyYCC.burnFill.b> = 0;
  <highlights.keyYCC.burnFill.r> = 0;
  <highlights.keyYCC.burnFill?nil> = 1;
  <highlights.fillYCC.black> = 0.55f;
  <highlights.fillYCC.white> = uVar9;
  <highlights.fillYCC.normalFill.b> = 0;
  <highlights.fillYCC.normalFill.r> = 0;
  <highlights.fillYCC.normalFill?nil> = 1;
  <highlights.fillYCC.dodgeFill.b> = 0;
  <highlights.fillYCC.dodgeFill.r> = 0;
  <highlights.fillYCC.dodgeFill?nil> = 1;
  <highlights.fillYCC.burnFill.b> = 0;
  <highlights.fillYCC.burnFill.r> = 0;
  <highlights.fillYCC.burnFill?nil> = 1;
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar9 = {f 0.25, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar9;
  return;
}


//######## LockScreenControlsRecipe.Modifier (spec) 0x195eff174
// === 195f016fc spec

/* WARNING: Removing unreachable block (ram,0x000195f01764) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f016fc(undefined8 <backdropScale>,double *param_2)
{
  undefined1 auStack_b0 [8];
  lVar6 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar11 = auStack_b0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195ed0900();
  local_88 = *(ulong *)((long)param_2 + (long)*(int *)(lVar7 + 0x14));
  lVar7 = 0;
  FUN_195f3c68c();
  lVar7 = (long)*(int *)(lVar7 + 0x18);
  local_8c = *_DAT_1e017dd68;
  pcVar13 = *(code **)(lVar10 + 0x68);
  (*pcVar13)(puVar11,local_8c,lVar6);
  uVar8 = (long)param_2 + lVar7;
  local_98 = pcVar13;
  func_0x000198120100(uVar8,puVar11);
  local_a8 = (undefined8 *)(lVar10 + 8);
  pcVar12 = (code *)*local_a8;
  (*pcVar12)(puVar11,lVar6);
  uVar2 = local_8c;
  uVar19 = 0.48f;
  if ((uVar8 & 1) == 0) {
    uVar19 = 0.075f;
  }
  local_a0 = pcVar12;
  (*pcVar13)(puVar11,local_8c,lVar6);
  uVar8 = (long)param_2 + lVar7;
  func_0x000198120100(uVar8,puVar11);
  (*pcVar12)(puVar11,lVar6);
  uVar20 = 1.1f;
  if ((uVar8 & 1) == 0) {
    uVar20 = 1.15f;
  }
  (*local_98)(puVar11,uVar2,lVar6);
  uVar3 = local_88;
  uVar8 = (long)param_2 + lVar7;
  func_0x000198120100(uVar8,puVar11);
  (*local_a0)(puVar11,lVar6);
  fVar18 = 1.0;
  fVar14 = fVar18;
  if ((uVar8 & 1) == 0) {
    fVar14 = 1.06;
  }
  <faceEffect.opacity> = 1f;
  <faceEffect.ycc.black> = uVar19;
  <faceEffect.ycc.white> = uVar20;
  <faceEffect.ycc.saturation> = fVar14;
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill.r> = 0;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  bVar4 = (uVar3 & 4) != 0;
  <faceEffect.maxLuminance> = 0.0078125;
  uVar17 = -0.5;
  if (bVar4) {
    uVar17 = -0.38;
  }
  uVar16 = 0.18;
  if (bVar4) {
    uVar16 = 0.115;
  }
  fVar14 = fVar18;
  if (bVar4) {
    fVar14 = 0.7;
  }
  <refraction.normalizedInnerAmount> = uVar17;
  <refraction.normalizedInnerHeight> = uVar16;
  <refraction.outerOpacity> = fVar14 * <refraction.outerOpacity>;
  dVar15 = *param_2;
  uVar8 = <blur.blurRadius>;
  FUN_195eda468(uVar8,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = (ulong)(uint)(float)(dVar15 * 6.0);
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = 3f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.opacities.3> = (f 1, f -44);
  uVar17 = {d 0.0078125};
  <blur.opacities.1> = {d 3.05176e-05};
  <blur.opacity> = uVar17;
  FUN_195ed53f0();
  uVar5 = (uint)uVar8;
  if ((uVar8 & 1) == 0) {
    puVar9 = <highlights.spread>;
    FUN_195dabb50(puVar9,&DAT_1eb9cad28,&{f 2.38425e-40, 2.52234e-44});
    uVar5 = (uint)puVar9;
    <highlights.spread> = 1.22173;
    <+0x469> = 0;
    if ((uVar3 & 4) != 0) {
      fVar18 = 0.4;
    }
    uVar17 = <highlights.keyOpacity>;
    <highlights.keyOpacity> =
         CONCAT44((float)((ulong)uVar17 >> 0x20) * fVar18,(float)uVar17 * fVar18);
    <highlights.keyYCC.black> = 0.55f;
    uVar17 = {d 0.0140625};
    <highlights.keyYCC.white> = {d 0.0140625};
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.b> = 0;
    <highlights.keyYCC.dodgeFill.r> = 0;
    <highlights.keyYCC.dodgeFill?nil> = 1;
    <highlights.keyYCC.burnFill.b> = 0;
    <highlights.keyYCC.burnFill.r> = 0;
    <highlights.keyYCC.burnFill?nil> = 1;
    <highlights.fillYCC.black> = 0.55f;
    <highlights.fillYCC.white> = uVar17;
    <highlights.fillYCC.normalFill.b> = 0;
    <highlights.fillYCC.normalFill.r> = 0;
    <highlights.fillYCC.normalFill?nil> = 1;
    <highlights.fillYCC.dodgeFill.b> = 0;
    <highlights.fillYCC.dodgeFill.r> = 0;
    <highlights.fillYCC.dodgeFill?nil> = 1;
    <highlights.fillYCC.burnFill.b> = 0;
    <highlights.fillYCC.burnFill.r> = 0;
    <highlights.fillYCC.burnFill?nil> = 1;
  }
  FUN_195ed53f0();
  bVar4 = (uVar5 & (uVar3 & 0x4000) == 0) == 0;
  uVar17 = (f 2, f -0);
  if (bVar4) {
    uVar17 = 0.25f;
  }
  puVar1 = &DAT_1e3f0d2a0;
  if (bVar4) {
    puVar1 = (undefined *)0x0;
  }
  FUN_195efb144(<backdropScale>,<+0x8>);
  <backdropScale> = uVar17;
  <+0x8> = puVar1;
  if (((uint)uVar3 >> 2 & 1) != 0) {
    FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                  <+0x230>,<+0x231>);
    <+0x22a> = 0;
    <+0x222> = 0;
    <+0x210> = 0;
    <edgeBleed.opacity> = 0;
    <+0x220> = 0;
    <+0x218> = 0;
  }
  return;
}


//######## LockScreenControlsRecipe.ReducedTransparencyOverride (spec) 0x195eff178
// === 195f014dc spec

/* WARNING: Removing unreachable block (ram,0x000195f015b4) */
/* WARNING: Removing unreachable block (ram,0x000195f0153c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f014dc(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar6 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar8 = &stack0xffffffffffffff90 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar9 = (long)puVar8 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  lVar4 = lVar9;
  (**(code **)(lVar7 + 0x68))(lVar9,*_DAT_1e017dd58,lVar3);
  FUN_195e7d9c0();
  uVar5 = param_2 + iVar1;
  func_0x0001980ff320(uVar5,lVar9,lVar3,lVar4);
  (**(code **)(lVar7 + 8))(lVar9,lVar3);
  if (((uVar5 & 1) == 0) &&
     (<faceEffect.ycc.white> = 1f, <faceEffect.ycc.normalFill?nil> != '\x01')) {
    uVar13 = <faceEffect.ycc.normalFill.a>;
    (**(code **)(lVar6 + 0x68))(puVar8,*_DAT_1e01830d0,lVar2);
    uVar10 = 1f;
    uVar11 = 1f;
    uVar12 = 1f;
    func_0x0001981218c0(puVar8);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar11 >> 0x18),
                  CONCAT16((char)((uint)uVar11 >> 0x10),
                           CONCAT15((char)((uint)uVar11 >> 8),CONCAT14((char)uVar11,uVar10))));
    <faceEffect.ycc.normalFill?nil> = 0;
  }
  return;
}


//######## LockScreenNotificationsRecipe.anon.Modifier (spec) 0x195eff1b4
// === 195f01dec spec

/* WARNING: Removing unreachable block (ram,0x000195f01ec4) */
/* WARNING: Removing unreachable block (ram,0x000195f01e4c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f01dec(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = &stack0xffffffffffffff90 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar12 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  lVar5 = lVar12;
  (**(code **)(lVar9 + 0x68))(lVar12,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,lVar12,lVar4,lVar5);
  (**(code **)(lVar9 + 8))(lVar12,lVar4);
  uVar7 = 0;
  FUN_195ed0900();
  uVar11 = *(ulong *)(param_2 + *(int *)(uVar7 + 0x14));
  FUN_195ed53f0();
  if ((uVar7 & 1) != 0) {
    <highlights.keyYCC.white> = 0.9f;
    <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
    <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
    <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
    <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
    <+0x411> = <+0x3c9>;
    <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
    <highlights.fillYCC.black> = <highlights.keyYCC.black>;
    <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
    <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  }
  if (((uint)uVar11 >> 0x18 & 1) != 0) {
    (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
    bVar2 = (uVar11 & 4) != 0;
    if ((uVar6 & 1) == 0) {
      uVar16 = 0.8f;
      if (bVar2) {
        uVar16 = 0.75f;
      }
      uVar17 = 1.03f;
      if (bVar2) {
        uVar17 = 0.8f;
      }
      uVar13 = 1f;
      uVar14 = 1f;
      uVar15 = 1f;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar14 >> 0x18),
                    CONCAT16((char)((uint)uVar14 >> 0x10),
                             CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
      <faceEffect.ycc.normalFill?nil> = 0;
      <faceEffect.ycc.black> = 0.25f;
    }
    else {
      uVar16 = 0.6f;
      if (bVar2) {
        uVar16 = 0.65f;
      }
      uVar17 = 0;
      uVar13 = 0;
      uVar14 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar14))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar17))));
      <faceEffect.ycc.normalFill?nil> = 0;
      <faceEffect.ycc.black> = 0.2f;
      uVar17 = 0.75f;
    }
    <faceEffect.ycc.white> = uVar17;
    <faceEffect.ycc.saturation> = 2f;
  }
  return;
}


//######## ClearEntryFieldRecipe.anon.Modifier (spec) 0x195eff228
// === 195eff228 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195eff228(undefined8 <backdropScale>)
{
  <blur.distances.1.v> = 0;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.opacities.2> = 0;
  <blur.opacities.0> = 0;
  <+0x141> = 0;
  <blur.distances.3.kind> = 0;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.opacity> = 0;
  <faceEffect.ycc.black> = 0;
  <+0x170> = 0;
  <blur.blurRadius> = 0;
  <+0x180> = 0;
  <+0x178> = 0;
  <+0x18a> = 0;
  <+0x182> = 0;
  uVar1 = NEON_fmov(1f,4);
  <faceEffect.ycc.white> = uVar1;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill.r> = 0;
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar1 = {f 1, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar1;
  return;
}


//######## AlarmSliderRecipe.Modifier (spec) 0x195eff31c
// === 195f009b4 spec

/* WARNING: Removing unreachable block (ram,0x000195f00a8c) */
/* WARNING: Removing unreachable block (ram,0x000195f00a14) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f009b4(undefined8 <backdropScale>,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar12 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar13 = (long)puVar12 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  lVar5 = lVar13;
  (**(code **)(lVar9 + 0x68))(lVar13,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,lVar13,lVar4,lVar5);
  (**(code **)(lVar9 + 8))(lVar13,lVar4);
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar10 = {f 1, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar10;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = 5f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  uVar10 = {d 0};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar10;
  <refraction.outerOpacity> = 1f;
  <refraction.normalizedOuterAmount> = 0.9;
  <refraction.normalizedOuterHeight> = 0.15;
  bVar2 = (uVar6 & 1) == 0;
  uVar10 = -0.3;
  if (bVar2) {
    uVar10 = -1;
  }
  uVar11 = 0.15;
  if (bVar2) {
    uVar11 = 0.36;
  }
  <refraction.normalizedInnerAmount> = uVar10;
  <refraction.normalizedInnerHeight> = uVar11;
  uVar7 = <edgeBleed.opacity>;
  FUN_195eda468(uVar7,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <edgeBleed.opacity> = 1f;
  <+0x218> = 0;
  <+0x210> = 0;
  <+0x228> = 0;
  <+0x220> = 0;
  <+0x230> = 0;
  <edgeBleed.normalizedHeight> = 0.5;
  uVar10 = {d 1};
  <edgeBleed.normalizedBlurRadius> = {d 0.35};
  <edgeBleed.normalizedAmount> = uVar10;
  <edgeBleed.ycc.black> = {d 0.0078125};
  <edgeBleed.ycc.saturation> = 1f;
  <edgeBleed.ycc.normalFill.b> = 0;
  <edgeBleed.ycc.normalFill.r> = 0;
  <edgeBleed.ycc.normalFill?nil> = 1;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.burnFill?nil> = 1;
  FUN_195ed53f0();
  if ((uVar7 & 1) != 0) {
    <faceEffect.ycc.black> = 0.01875;
    <darkSpecular.colorBias> = -0.4;
    uVar10 = {d 0.7};
    <darkSpecular.effectOffset> = {d 0};
    <darkSpecular.amount> = uVar10;
    uVar10 = {d 12};
    <ringShadow.strokeWidth> = {d 3};
    <ringShadow.verticalOffset> = uVar10;
    <ringShadow.blurRadius> = 4;
    <ringShadow.opacity> = 0.2f;
    <darkSpecular.height> = 0;
    <ringShadow.maskAmount> = 0;
    FUN_195dabb50(<highlights.spread>,&DAT_1eb9cad28,&{f 2.38425e-40, 2.52234e-44});
    <highlights.spread> = 1.74533;
    <+0x469> = 0;
    <highlights.diffuseHeightScale> = {d 0.000229492};
    <highlights.diffuseAmountScale> = 0.16f;
    <highlights.amount> = 0.5;
    bVar2 = (uVar6 & 1) == 0;
    if (bVar2) {
      uVar10 = 0;
      uVar11 = 0;
      uVar16 = 0.9f;
      uVar15 = {d 0.125};
    }
    else {
      (**(code **)(lVar8 + 0x68))(puVar12,*_DAT_1e01830d0,lVar3);
      uVar14 = 0.6f;
      uVar18 = 1f;
      uVar16 = uVar14;
      uVar17 = uVar14;
      func_0x0001981218c0(puVar12);
      uVar10 = CONCAT44(uVar16,uVar14);
      uVar11 = CONCAT44(uVar18,uVar17);
      uVar16 = 0.06f;
      uVar15 = {d 0.025};
    }
    <highlights.keyYCC.black> = uVar16;
    <highlights.keyYCC.white> = uVar15;
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.r> = uVar10;
    <highlights.keyYCC.dodgeFill.b> = uVar11;
    <highlights.keyYCC.dodgeFill?nil> = bVar2;
    <highlights.keyYCC.burnFill.b> = 0;
    <highlights.keyYCC.burnFill.r> = 0;
    <highlights.keyYCC.burnFill?nil> = 1;
    <highlights.fillYCC.black> = uVar16;
    <highlights.fillYCC.white> = uVar15;
    <highlights.fillYCC.normalFill.b> = 0;
    <highlights.fillYCC.normalFill.r> = 0;
    <highlights.fillYCC.normalFill?nil> = 1;
    <highlights.fillYCC.dodgeFill.r> = uVar10;
    <highlights.fillYCC.dodgeFill.b> = uVar11;
    <highlights.fillYCC.dodgeFill?nil> = bVar2;
    <highlights.fillYCC.burnFill.b> = 0;
    <highlights.fillYCC.burnFill.r> = 0;
    <highlights.fillYCC.burnFill?nil> = 1;
  }
  return;
}


//######## AlarmSliderRecipe.anon.Highlights (spec) 0x195eff320
// === 195eff320 spec

void FUN_195eff320(long param_1)
{
  uVar1 = (uint)param_1;
  FUN_195ed53f0();
  if ((uVar1 & 1) != 0) {
    fVar2 = (float){d 0.0140625};
    fVar3 = (float)((ulong){d 0.0140625} >> 0x20);
    <highlights.keyYCC.white> =
         CONCAT44((float)((ulong)<highlights.keyYCC.white> >> 0x20) * fVar3,
                  (float)<highlights.keyYCC.white> * fVar2);
    <highlights.fillYCC.white> =
         CONCAT44((float)((ulong)<highlights.fillYCC.white> >> 0x20) * fVar3,
                  (float)<highlights.fillYCC.white> * fVar2);
  }
  return;
}


//######## AlarmSliderRedRecipe.anon.Highlights (spec) 0x195eff3a4
// === 195f01114 spec

/* WARNING: Removing unreachable block (ram,0x000195f011e8) */
/* WARNING: Removing unreachable block (ram,0x000195f01170) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f01114(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar3 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(uVar3 - 8);
  uVar4 = uVar3;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  lVar11 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar4 & 1) != 0) {
    lVar5 = 0;
    FUN_195f3c68c();
    iVar1 = *(int *)(lVar5 + 0x18);
    lVar5 = lVar11;
    (**(code **)(lVar8 + 0x68))(lVar11,*_DAT_1e017dd58,uVar3);
    FUN_195e7d9c0();
    uVar4 = param_2 + iVar1;
    func_0x0001980ff320(uVar4,lVar11,uVar3,lVar5);
    (**(code **)(lVar8 + 8))(lVar11,uVar3);
    uVar15 = *_DAT_1e01830d0;
    pcVar10 = *(code **)(lVar7 + 0x68);
    if ((uVar4 & 1) == 0) {
      uVar6 = 0.9f;
      uVar12 = {d 0.125};
    }
    else {
      (*pcVar10)(puVar9,uVar15,lVar2);
      func_0x0001981218c0(0.6f,0.6f,0.6f,1f,puVar9);
      uVar6 = 0.06f;
      uVar12 = {d 0.025};
    }
    <highlights.fillYCC.black> = uVar6;
    <highlights.fillYCC.white> = uVar12;
    <highlights.fillYCC.normalFill.b> = 0;
    <highlights.fillYCC.normalFill.r> = 0;
    <highlights.fillYCC.normalFill?nil> = 1;
    <highlights.fillYCC.burnFill.b> = 0;
    <highlights.fillYCC.burnFill.r> = 0;
    <highlights.fillYCC.burnFill?nil> = 1;
    <highlights.fillYCC.dodgeFill.b> = 0;
    <highlights.fillYCC.dodgeFill.r> = 0;
    <highlights.fillYCC.dodgeFill?nil> = 1;
    (*pcVar10)(puVar9,uVar15,lVar2);
    uVar6 = 1f;
    func_0x0001981218c0(1f,0,0,1f,puVar9);
    FUN_195f7fc20();
    uVar14 = 0.4f;
    uVar15 = 0.8f;
    uVar13 = 2f;
    FUN_195f7f998();
    <highlights.fillYCC.normalFill.b> =
         CONCAT17((char)((uint)uVar15 >> 0x18),
                  CONCAT16((char)((uint)uVar15 >> 0x10),
                           CONCAT15((char)((uint)uVar15 >> 8),CONCAT14((char)uVar15,uVar14))));
    <highlights.fillYCC.normalFill.r> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar6))));
    <highlights.fillYCC.normalFill?nil> = 0;
    <highlights.keyYCC.dodgeFill.b> = <highlights.fillYCC.dodgeFill.b>;
    <highlights.keyYCC.dodgeFill.r> = <highlights.fillYCC.dodgeFill.r>;
    <highlights.keyYCC.burnFill.g> = <highlights.fillYCC.burnFill.g>;
    <highlights.keyYCC.dodgeFill?nil> = <highlights.fillYCC.dodgeFill?nil>;
    <+0x3c9> = <+0x411>;
    <highlights.keyYCC.saturation> = <highlights.fillYCC.saturation>;
    <highlights.keyYCC.black> = <highlights.fillYCC.black>;
    <highlights.keyYCC.normalFill.a> = <highlights.fillYCC.normalFill.a>;
    <highlights.keyYCC.normalFill.g> = <highlights.fillYCC.normalFill.g>;
  }
  return;
}


//######## ContactsQuickActionRecipe.anon.Modifier (spec) 0x195eff3e0
// === 195f01ba0 spec

/* WARNING: Removing unreachable block (ram,0x000195f01bf4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f01ba0(undefined8 <backdropScale>,long param_2)
{
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  puVar5 = puVar9;
  (**(code **)(lVar7 + 0x68))(puVar9,*_DAT_1e017dd58,lVar3);
  FUN_195e7d9c0();
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,puVar9,lVar3,puVar5);
  (**(code **)(lVar7 + 8))(puVar9,lVar3);
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar8 = {f 1, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar8;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = 5f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  uVar8 = {d 0};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar8;
  <refraction.outerOpacity> = 1f;
  <refraction.normalizedOuterAmount> = 0.9;
  <refraction.normalizedOuterHeight> = 0.15;
  bVar2 = (uVar6 & 1) == 0;
  uVar8 = -0.3;
  if (bVar2) {
    uVar8 = -1;
  }
  uVar10 = 0.15;
  if (bVar2) {
    uVar10 = 0.36;
  }
  <refraction.normalizedInnerAmount> = uVar8;
  <refraction.normalizedInnerHeight> = uVar10;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <edgeBleed.opacity> = 1f;
  <+0x218> = 0;
  <+0x210> = 0;
  <+0x228> = 0;
  <+0x220> = 0;
  <+0x230> = 0;
  <edgeBleed.normalizedHeight> = 0.5;
  uVar8 = {d 1};
  <edgeBleed.normalizedBlurRadius> = {d 0.35};
  <edgeBleed.normalizedAmount> = uVar8;
  <edgeBleed.ycc.black> = {d 0.0078125};
  <edgeBleed.ycc.saturation> = 1f;
  <edgeBleed.ycc.normalFill.b> = 0;
  <edgeBleed.ycc.normalFill.r> = 0;
  <edgeBleed.ycc.normalFill?nil> = 1;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.burnFill?nil> = 1;
  return;
}


//######## HomeModularFaceRecipe.anon.Modifier (spec) 0x195eff41c
// === 195f013e8 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f013e8(long param_1)
{
  <blur.distances.0.v> = -328f;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = -32f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  uVar1 = {f 1, 0.1};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar1;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = 8f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  <refraction.normalizedInnerAmount> = -1.1;
  <refraction.normalizedInnerHeight> = 0.36;
  FUN_195dabb50(<highlights.keyHeight>,&DAT_1eda3b6c0,0x195fa8230);
  <highlights.keyHeight> = 2;
  <+0x349> = 0;
  FUN_195dabb50(<highlights.fillHeight>,&DAT_1eda3b6c0,0x195fa8230);
  <highlights.fillHeight> = 2;
  <+0x389> = 0;
  return;
}


//######## HomescreenFolderAndAppLibraryPodRecipe.Modifier (spec) 0x195eff458
// === 195eff458 spec

void FUN_195eff458(long param_1)
{
  uVar1 = (uint)param_1;
  FUN_195ed53f0();
  if ((uVar1 & 1) != 0) {
    <faceEffect.ycc.black> = 0.0059375;
    <highlights.keyYCC.white> = 0.9f;
    <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
    <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
    <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
    <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
    <+0x411> = <+0x3c9>;
    <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
    <highlights.fillYCC.black> = <highlights.keyYCC.black>;
    <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
    <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  }
  return;
}


//######## ControlClearSpec (spec) 0x195f027d0
// === 195f02fe4 spec

/* WARNING: Removing unreachable block (ram,0x000195f03120) */
/* WARNING: Removing unreachable block (ram,0x000195f030a8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f02fe4(undefined8 <backdropScale>,double *param_2)
{
  puVar8 = &DAT_1eda3a940;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar8 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  lVar9 = 0;
  local_618 = (long)&local_6a0 - extraout_x8;
  func_0x0001981217d0();
  lVar14 = *(long *)(lVar9 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar14 + 0x40));
  lVar21 = ((long)&local_6a0 - extraout_x8) - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar10 = 0;
  func_0x000198120110();
  lVar15 = *(long *)(lVar10 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar15 + 0x40));
  lVar19 = lVar21 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  puVar11 = param_1;
  FUN_195ee8970();
  uVar7 = (uint)puVar11;
  local_538 = param_2;
  FUN_195ed53f0();
  lVar12 = 0;
  local_53c = uVar7;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar12 + 0x18);
  lVar12 = lVar19;
  (**(code **)(lVar15 + 0x68))(lVar19,*_DAT_1e017dd58,lVar10);
  FUN_195e7d9c0();
  uVar13 = (long)param_2 + (long)iVar1;
  func_0x0001980ff320(uVar13,lVar19,lVar10,lVar12);
  local_620 = lVar15;
  (**(code **)(lVar15 + 8))(lVar19,lVar10);
  uVar34 = *_DAT_1e01830d0;
  pcVar18 = *(code **)(lVar14 + 0x68);
  (*pcVar18)(lVar21,uVar34,lVar9);
  uVar22 = 0;
  uVar23 = 0;
  uVar24 = 0;
  uVar26 = 0;
  uVar27 = 0;
  uVar28 = 0;
  uVar29 = 1f;
  uVar30 = 0;
  func_0x0001981218c0(lVar21);
  local_610 = uVar29;
  uStack_608 = uVar30;
  local_600 = uVar27;
  uStack_5f8 = uVar28;
  local_5f0 = uVar24;
  uStack_5e8 = uVar26;
  local_5e0 = uVar22;
  uStack_5d8 = uVar23;
  (*pcVar18)(lVar21,uVar34,lVar9);
  uVar22 = 0;
  uVar23 = 0;
  uVar24 = 0;
  uVar26 = 0;
  uVar27 = 0;
  uVar28 = 0;
  uVar29 = 0;
  uVar30 = 0;
  func_0x0001981218c0(lVar21);
  lVar12 = 0;
  local_580 = uVar29;
  uStack_578 = uVar30;
  uStack_570 = uVar24;
  uStack_568 = uVar26;
  local_560 = uVar27;
  uStack_558 = uVar28;
  uStack_550 = uVar22;
  uStack_548 = uVar23;
  FUN_195ed0900();
  uVar20 = *(ulong *)((long)local_538 + (long)*(int *)(lVar12 + 0x14));
  (*pcVar18)(lVar21,uVar34,lVar9);
  local_5c8 = (undefined4)uVar13;
  bVar6 = (uVar20 & 8) != 0;
  if ((uVar13 & 1) == 0) {
    uVar7 = 0.4f;
    if (bVar6) {
      uVar7 = 0.85f;
    }
    uVar29 = 0;
    uVar13 = (ulong)uVar7;
    uVar22 = 1f;
    uVar23 = 0;
    uVar24 = 1f;
    uVar26 = 0;
    uVar27 = 1f;
    uVar28 = 0;
    func_0x0001981218c0(lVar21);
    uVar34 = 0.5f;
    local_5c4 = 1.03f;
    local_5c0 = uVar13;
    uStack_5b8 = uVar29;
    uStack_5b0 = uVar24;
    uStack_5a8 = uVar26;
    local_5a0 = uVar27;
    uStack_598 = uVar28;
    uStack_590 = uVar22;
    uStack_588 = uVar23;
  }
  else {
    uVar7 = 0;
    if (bVar6) {
      uVar7 = 0.78f;
    }
    uVar29 = 0;
    uVar13 = (ulong)uVar7;
    uVar22 = 0;
    uVar23 = 0;
    uVar24 = 0;
    uVar26 = 0;
    uVar27 = 0;
    uVar28 = 0;
    func_0x0001981218c0(lVar21);
    local_5c4 = 0.6f;
    uVar34 = 0.2f;
    local_5c0 = uVar13;
    uStack_5b8 = uVar29;
    uStack_5b0 = uVar24;
    uStack_5a8 = uVar26;
    local_5a0 = uVar27;
    uStack_598 = uVar28;
    uStack_590 = uVar22;
    uStack_588 = uVar23;
  }
  lVar12 = local_618;
  (**(code **)(local_620 + 0x38))(local_618,1,1,lVar10);
  pdVar5 = local_538;
  if ((local_53c & 1) == 0) {
    FUN_195eef0b0(&local_268,local_538,lVar12);
    FUN_195ef92bc(lVar12);
    uStack_2a8 = uStack_128;
    local_2b0 = local_130;
    uStack_298 = uStack_118;
    uStack_2a0 = uStack_120;
    uStack_288 = uStack_108;
    local_290 = local_110;
    uStack_27e = uStack_fe;
    uStack_286 = uStack_106;
    uStack_280 = uStack_100;
    uStack_2c0 = uStack_14c;
    uStack_2d8 = uStack_164;
    local_2e0 = local_16c;
    uStack_2c8 = uStack_154;
    local_2c3 = uStack_14f;
    uStack_2d0 = local_15c;
    uStack_2f8 = uStack_184;
    local_300 = local_18c;
    uStack_2e8 = uStack_174;
    uStack_2f0 = local_17c;
    uStack_310 = uStack_194;
    uStack_328 = uStack_1ac;
    local_330 = local_1b4;
    uStack_318 = uStack_19c;
    local_313 = uStack_197;
    uStack_320 = local_1a4;
    uStack_348 = uStack_1cc;
    local_350 = local_1d4;
    uStack_338 = uStack_1bc;
    uStack_340 = local_1c4;
    uStack_35e = uStack_1de;
    uStack_360 = uStack_1e0;
    uVar35 = 0;
    uStack_378 = uStack_1f8;
    local_380 = local_200;
    uStack_368 = uStack_1e8;
    local_366 = local_1e6;
    uStack_370 = uStack_1f0;
    uStack_388 = uStack_208;
    local_390 = local_210;
    uVar32 = 0;
    uVar30 = 0;
    uStack_39e = uStack_21e;
    uStack_3a0 = uStack_220;
    uVar31 = 0;
    uVar24 = 0;
    uStack_3b8 = uStack_238;
    local_3c0 = local_240;
    uStack_3a8 = uStack_228;
    local_3a6 = local_226;
    uStack_3b0 = uStack_230;
    uVar28 = 0;
    uVar27 = 0;
    uVar26 = 0;
    dVar36 = 0.0;
    uStack_3c8 = uStack_248;
    local_3d0 = local_250;
    uVar29 = 0;
    uVar22 = local_260;
    uVar23 = local_268;
    uStack_628 = local_138;
    local_630 = local_140;
    uVar33 = local_258;
  }
  else {
    FUN_195eef0b0(&local_268,local_538,lVar12);
    FUN_195ef92bc(lVar12);
    uStack_2a8 = uStack_128;
    local_2b0 = local_130;
    uStack_298 = uStack_118;
    uStack_2a0 = uStack_120;
    uStack_288 = uStack_108;
    local_290 = local_110;
    uStack_27e = uStack_fe;
    uStack_286 = uStack_106;
    uStack_280 = uStack_100;
    uStack_35e = uStack_1de;
    uStack_360 = uStack_1e0;
    uStack_378 = uStack_1f8;
    local_380 = local_200;
    uStack_368 = uStack_1e8;
    local_366 = local_1e6;
    uStack_370 = uStack_1f0;
    uStack_388 = uStack_208;
    local_390 = local_210;
    uStack_39e = uStack_21e;
    uStack_3a0 = uStack_220;
    uStack_3b8 = uStack_238;
    local_3c0 = local_240;
    uStack_3a8 = uStack_228;
    local_3a6 = local_226;
    uStack_3b0 = uStack_230;
    uStack_3c8 = uStack_248;
    local_3d0 = local_250;
    uStack_310 = uStack_194;
    uStack_328 = uStack_1ac;
    local_330 = local_1b4;
    uStack_318 = uStack_19c;
    local_313 = uStack_197;
    uStack_320 = local_1a4;
    uStack_348 = uStack_1cc;
    local_350 = local_1d4;
    uStack_338 = uStack_1bc;
    uStack_340 = local_1c4;
    uStack_2c0 = uStack_14c;
    dVar36 = *pdVar5 * -2.0;
    uVar26 = 0.5;
    uVar24 = 1;
    uVar31 = 3;
    uVar30 = 4;
    uVar35 = 8;
    uVar29 = -0.3;
    uStack_2d8 = uStack_164;
    local_2e0 = local_16c;
    uStack_2c8 = uStack_154;
    local_2c3 = uStack_14f;
    uStack_2d0 = local_15c;
    uVar27 = 2.0944;
    uVar28 = 1.5708;
    local_d8 = 0.15f;
    uVar32 = 0.1f;
    uStack_2f8 = uStack_184;
    local_300 = local_18c;
    uStack_2e8 = uStack_174;
    uStack_2f0 = local_17c;
    uVar22 = local_260;
    uVar23 = local_268;
    uStack_628 = local_138;
    local_630 = local_140;
    local_e0 = {d 0.000170898};
    uVar33 = local_258;
  }
  if (DAT_1eda3b6c8 != -1) {
    uStack_658 = 0;
    uStack_648 = 0;
    uStack_678 = 0;
    uStack_668 = 0;
    uStack_698 = 0;
    uStack_688 = 0;
    local_6a0 = uVar29;
    uStack_690 = uVar28;
    local_680 = uVar27;
    dStack_670 = dVar36;
    local_660 = uVar26;
    uStack_650 = uVar24;
    local_640 = local_e0;
    local_634 = local_d8;
    local_620 = local_f0;
    local_618 = local_e8;
    func_0x000198104ff0(&DAT_1eda3b6c8,FUN_195eeb6ec);
    local_e8 = local_618;
    local_f0 = local_620;
    local_d8 = local_634;
    local_e0 = local_640;
    uVar24 = uStack_650;
    uVar26 = local_660;
    dVar36 = dStack_670;
    uVar27 = local_680;
    uVar28 = uStack_690;
    uVar29 = local_6a0;
  }
  <faceEffect.ycc.black> = uVar34;
  local_3d8 = DAT_1eda465b8;
  uVar4 = uRam00000001eda465b0;
  uVar2 = {d 0.25};
  bVar6 = (local_53c & 1) == 0;
  uVar16 = -0.15;
  if (bVar6) {
    uVar16 = -0.25;
  }
  uVar17 = -0.2;
  if (bVar6) {
    uVar17 = -0.25;
  }
  uVar25 = 0.16;
  if (bVar6) {
    uVar25 = 0.2;
  }
  uStack_450 = (undefined4)uStack_3c8;
  uStack_44c = (undefined4)((ulong)uStack_3c8 >> 0x20);
  local_458 = (undefined4)local_3d0;
  uStack_454 = (undefined4)((ulong)local_3d0 >> 0x20);
  uStack_440 = (undefined4)uStack_3b8;
  uStack_43c = (undefined4)((ulong)uStack_3b8 >> 0x20);
  local_448 = (undefined4)local_3c0;
  uStack_444 = (undefined4)((ulong)local_3c0 >> 0x20);
  local_438 = (undefined4)uStack_3b0;
  uStack_434 = (undefined4)((ulong)uStack_3b0 >> 0x20);
  uStack_426 = uStack_39e;
  uStack_42e = (undefined2)local_3a6;
  uStack_42c = (undefined4)((uint6)local_3a6 >> 0x10);
  uStack_48e = (undefined2)uStack_388;
  uStack_48c = (undefined6)((ulong)uStack_388 >> 0x10);
  local_496 = (undefined2)local_390;
  uStack_494 = (undefined6)((ulong)local_390 >> 0x10);
  uStack_47e = (undefined2)uStack_378;
  uStack_47c = (undefined6)((ulong)uStack_378 >> 0x10);
  local_486 = (undefined2)local_380;
  uStack_484 = (undefined6)((ulong)local_380 >> 0x10);
  local_476 = (undefined2)uStack_370;
  uStack_474 = (undefined6)((ulong)uStack_370 >> 0x10);
  uStack_464 = uStack_35e;
  uStack_4ca = (undefined6)uStack_338;
  uStack_4c4 = (undefined2)((ulong)uStack_338 >> 0x30);
  local_4d2 = (undefined6)uStack_340;
  uStack_4cc = (undefined2)((ulong)uStack_340 >> 0x30);
  uStack_4ba = (undefined6)uStack_328;
  uStack_4b4 = (undefined2)((ulong)uStack_328 >> 0x30);
  local_4c2 = (undefined6)local_330;
  uStack_4bc = (undefined2)((ulong)local_330 >> 0x30);
  local_4b2 = (undefined6)uStack_320;
  uStack_4ac = (undefined2)((ulong)uStack_320 >> 0x30);
  uStack_4da = (undefined6)uStack_348;
  uStack_4d4 = (undefined2)((ulong)uStack_348 >> 0x30);
  local_4e2 = (undefined6)local_350;
  uStack_4dc = (undefined2)((ulong)local_350 >> 0x30);
  uStack_515 = (undefined5)uStack_2e8;
  uStack_510 = (undefined3)((ulong)uStack_2e8 >> 0x28);
  local_51d = (undefined5)uStack_2f0;
  uStack_518 = (undefined3)((ulong)uStack_2f0 >> 0x28);
  uStack_505 = (undefined5)uStack_2d8;
  uStack_500 = (undefined3)((ulong)uStack_2d8 >> 0x28);
  local_50d = (undefined5)local_2e0;
  uStack_508 = (undefined3)((ulong)local_2e0 >> 0x28);
  local_4fd = (undefined5)uStack_2d0;
  uStack_4f8 = (undefined3)((ulong)uStack_2d0 >> 0x28);
  uStack_525 = (undefined5)uStack_2f8;
  uStack_520 = (undefined3)((ulong)uStack_2f8 >> 0x28);
  local_52d = (undefined5)local_300;
  uStack_528 = (undefined3)((ulong)local_300 >> 0x28);
  uStack_410 = (undefined2)uRam00000001eda46580;
  uStack_40e = (undefined6)((ulong)uRam00000001eda46580 >> 0x10);
  local_418 = (undefined2)_DAT_1eda46578;
  uStack_416 = (undefined6)((ulong)_DAT_1eda46578 >> 0x10);
  uStack_3e0 = (undefined2)uRam00000001eda465b0;
  uStack_3de = (undefined6)((ulong)uRam00000001eda465b0 >> 0x10);
  local_3e8 = (undefined2)_DAT_1eda465a8;
  uStack_3e6 = (undefined6)((ulong)_DAT_1eda465a8 >> 0x10);
  uStack_3f0 = (undefined2)uRam00000001eda465a0;
  uStack_3ee = (undefined6)((ulong)uRam00000001eda465a0 >> 0x10);
  local_3f8 = (undefined2)_DAT_1eda46598;
  uStack_3f6 = (undefined6)((ulong)_DAT_1eda46598 >> 0x10);
  uStack_400 = (undefined2)uRam00000001eda46590;
  uStack_3fe = (undefined6)((ulong)uRam00000001eda46590 >> 0x10);
  local_408 = (undefined2)_DAT_1eda46588;
  uStack_406 = (undefined6)((ulong)_DAT_1eda46588 >> 0x10);
  <shadow.blurRadius> = {d 0};
  <shadow.normalizedAmount> = uVar2;
  uVar2 = {d 0};
  <shadow.offset.1> = {d 7};
  <shadow.offset.0> = uVar2;
  uVar7 = 0.001f;
  if (bVar6) {
    uVar7 = 0.1f;
  }
  uStack_4a5 = (undefined1)local_313;
  uStack_4a4 = (undefined2)((uint3)local_313 >> 8);
  <backdropScale> = 0.25f;
  <shadow.ycc.normalFill.b> =
       CONCAT17((char)((ulong)local_610 >> 0x18),
                CONCAT16((char)((ulong)local_610 >> 0x10),
                         CONCAT15((char)((ulong)local_610 >> 8),
                                  CONCAT14((char)local_610,(int)local_600))));
  <shadow.ycc.normalFill.r> =
       CONCAT17((char)((ulong)local_5f0 >> 0x18),
                CONCAT16((char)((ulong)local_5f0 >> 0x10),
                         CONCAT15((char)((ulong)local_5f0 >> 8),
                                  CONCAT14((char)local_5f0,(int)local_5e0))));
  uVar2 = {f 1, 0};
  <blur.opacities.1> = {d 9.76563e-05};
  <blur.opacity> = uVar2;
  uVar2 = {d 0.1};
  <refraction.innerHeightRange.lo> = {d 0};
  <refraction.normalizedInnerHeight> = uVar2;
  <refraction.normalizedInnerAmount> = uVar16;
  uVar3 = {f 0, nan};
  uVar16 = {d 0};
  uVar2 = {d -60};
  <refraction.innerAmountRange.hi> = {f 0, nan};
  <refraction.innerAmountRange.lo> = uVar2;
  <refraction.outerHeightRange.lo> = uVar3;
  <refraction.normalizedOuterHeight> = uVar16;
  uVar3 = {f 0, nan};
  uVar16 = {f 0, nan};
  uVar2 = {f 0, nan};
  <refraction.normalizedOuterAmount> = {d 0};
  <refraction.outerHeightRange.hi> = uVar3;
  <refraction.outerAmountRange.hi> = uVar16;
  <refraction.outerAmountRange.lo> = uVar2;
  <shadow.normalizedHeight> = 0;
  <+0x8> = 0;
  <shadow.opacity> = (ulong)uVar7;
  <+0x50> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <+0x48> = 0;
  <+0x40> = 0;
  <shadow.shadowRadius> = 8;
  <+0x91> = 0;
  uVar2 = {d 0.0078125};
  <shadow.ycc.black> = {d 0.0078125};
  <shadow.ycc.saturation> = 1f;
  <shadow.ycc.normalFill?nil> = 0;
  <shadow.ycc.dodgeFill.b> = 0;
  <shadow.ycc.dodgeFill.r> = 0;
  <shadow.ycc.dodgeFill?nil> = 1;
  <shadow.ycc.burnFill.b> = 0;
  <shadow.ycc.burnFill.r> = 0;
  <shadow.ycc.burnFill?nil> = 1;
  <shadow.vibrancyContribution> = 0;
  <+0x129> = 0;
  <blur.opacities.3> = -524288;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = 0;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.outerRefractionBlurRadius> = 0;
  <+0x18a> = 0;
  <+0x182> = 0;
  <+0x170> = 0;
  <blur.blurRadius> = 0;
  <+0x180> = 0;
  <+0x178> = 0;
  <blur.outerRefractionBlurRadius?nil> = 1;
  <refraction.innerHeightRange.hi> = 20;
  <refraction.outerOpacity> = 0;
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  <edgeBleed.normalizedAmount> = 0;
  <edgeBleed.normalizedHeight> = 0;
  <edgeBleed.normalizedBlurRadius> = 0.35;
  <edgeBleed.maxBlurRadius> = 120;
  <edgeBleed.ycc.black> = uVar2;
  <edgeBleed.ycc.saturation> = 1f;
  <edgeBleed.ycc.normalFill.b> =
       CONCAT17((char)((ulong)local_580 >> 0x18),
                CONCAT16((char)((ulong)local_580 >> 0x10),
                         CONCAT15((char)((ulong)local_580 >> 8),
                                  CONCAT14((char)local_580,(int)local_560))));
  <edgeBleed.ycc.normalFill.r> =
       CONCAT17((char)((ulong)uStack_570 >> 0x18),
                CONCAT16((char)((ulong)uStack_570 >> 0x10),
                         CONCAT15((char)((ulong)uStack_570 >> 8),
                                  CONCAT14((char)uStack_570,(int)uStack_550))));
  <edgeBleed.ycc.normalFill?nil> = 0;
  <edgeBleed.ycc.dodgeFill.b> = 0;
  <edgeBleed.ycc.dodgeFill.r> = 0;
  <edgeBleed.ycc.dodgeFill?nil> = 1;
  <edgeBleed.ycc.burnFill.b> = 0;
  <edgeBleed.ycc.burnFill.r> = 0;
  <edgeBleed.ycc.burnFill?nil> = 1;
  <+0x29d> = ((byte)local_5c8 ^ 0xff) & 1;
  <faceEffect.opacity> = 1f;
  <faceEffect.ycc.white> = local_5c4;
  <faceEffect.ycc.saturation> = 1f;
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)(local_5c0 >> 0x18),
                CONCAT16((char)(local_5c0 >> 0x10),
                         CONCAT15((char)(local_5c0 >> 8),CONCAT14((char)local_5c0,(int)local_5a0))))
  ;
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((ulong)uStack_5b0 >> 0x18),
                CONCAT16((char)((ulong)uStack_5b0 >> 0x10),
                         CONCAT15((char)((ulong)uStack_5b0 >> 8),
                                  CONCAT14((char)uStack_5b0,(int)uStack_590))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  <highlights.inset> = uVar23;
  <highlights.white> = uVar22;
  <highlights.fillOpacity> = uVar33;
  <+0x342> = uStack_39e;
  <+0x33a> = CONCAT26(uStack_3a0,local_3a6);
  <+0x324> = CONCAT44(uStack_440,uStack_444);
  <+0x31c> = CONCAT44(local_448,uStack_44c);
  <+0x334> = CONCAT26(uStack_42e,CONCAT24(uStack_3a8,uStack_434));
  <+0x32c> = CONCAT44(local_438,uStack_43c);
  <+0x314> = CONCAT44(uStack_450,uStack_454);
  <+0x30c> = CONCAT44(local_458,uStack_45c);
  <+0x372> = CONCAT26(uStack_368,uStack_474);
  <+0x36a> = CONCAT26(local_476,uStack_47c);
  <+0x382> = uStack_35e;
  <+0x37a> = CONCAT26(uStack_360,local_366);
  <+0x352> = CONCAT26(uStack_48e,uStack_494);
  <+0x34a> = CONCAT26(local_496,uStack_49c);
  <+0x362> = CONCAT26(uStack_47e,uStack_484);
  <+0x35a> = CONCAT26(local_486,uStack_48c);
  <+0x3c9> = CONCAT53(uStack_310,local_313);
  <+0x3b2> = CONCAT62(uStack_4ba,uStack_4bc);
  <+0x3aa> = CONCAT62(local_4c2,uStack_4c4);
  <+0x3c2> = CONCAT17(uStack_4a5,CONCAT52(uStack_318,uStack_4ac));
  <+0x3ba> = CONCAT62(local_4b2,uStack_4b4);
  <+0x392> = CONCAT62(uStack_4da,uStack_4dc);
  <+0x38a> = CONCAT62(local_4e2,uStack_4e4);
  <+0x3a2> = CONCAT62(uStack_4ca,uStack_4cc);
  <+0x39a> = CONCAT62(local_4d2,uStack_4d4);
  <+0x411> = CONCAT53(uStack_2c0,local_2c3);
  <+0x3f9> = CONCAT53(uStack_505,uStack_508);
  <+0x3f1> = CONCAT53(local_50d,uStack_510);
  <+0x409> = CONCAT53(uStack_2c8,uStack_4f8);
  <+0x401> = CONCAT53(local_4fd,uStack_500);
  <+0x3d9> = CONCAT53(uStack_525,uStack_528);
  <+0x3d1> = CONCAT53(local_52d,uStack_530);
  <+0x3e9> = CONCAT53(uStack_515,uStack_518);
  <+0x3e1> = CONCAT53(local_51d,uStack_520);
  <highlights.keyOffset> = local_630;
  <highlights.fillOffset> = uStack_628;
  <+0x462> = uStack_27e;
  <+0x45a> = CONCAT26(uStack_280,uStack_286);
  <+0x458> = CONCAT62(uStack_286,uStack_288);
  <+0x450> = local_290;
  <+0x448> = uStack_298;
  <+0x440> = uStack_2a0;
  <+0x438> = uStack_2a8;
  <highlights.spread> = local_2b0;
  <highlights.amount> = local_f0;
  <highlights.curvature> = local_e8;
  <highlights.diffuseHeightScale> = local_e0;
  <highlights.diffuseAmountScale> = local_d8;
  <blurFill.darkenOpacity> = 0;
  <blurFill.blurRadius> = 0;
  <ringShadow.verticalOffset> = uVar35;
  <ringShadow.strokeWidth> = uVar30;
  <ringShadow.blurRadius> = uVar31;
  <ringShadow.opacity> = uVar32;
  <ringShadow.maskAmount> = 0;
  <darkSpecular.amount> = uVar26;
  <darkSpecular.spreadSDR> = uVar27;
  <darkSpecular.colorBias> = uVar29;
  <darkSpecular.effectOffset> = dVar36;
  <darkSpecular.spread> = uVar28;
  <darkSpecular.height> = uVar24;
  <+0x539> = 0;
  <+0x540> = 0;
  <+0x579> = 0;
  <+0x580> = 0;
  <+0x5b9> = 0;
  <+0x500> = 0;
  <+0x4f8> = 0;
  <+0x600> = local_3d8;
  <+0x5f8> = uVar4;
  <+0x5e2> = CONCAT26(uStack_3f0,uStack_3f6);
  <+0x5da> = CONCAT26(local_3f8,uStack_3fe);
  <+0x5f2> = CONCAT26(uStack_3e0,uStack_3e6);
  <+0x5ea> = CONCAT26(local_3e8,uStack_3ee);
  <+0x5c2> = CONCAT26(uStack_410,uStack_416);
  <+0x5ba> = CONCAT26(local_418,uStack_41e);
  <+0x5d2> = CONCAT26(uStack_400,uStack_406);
  <+0x5ca> = CONCAT26(local_408,uStack_40e);
  <+0x608> = uVar25;
  <+0x610> = uVar17;
  <+0x618> = 0;
  uVar22 = {d 0.0526316};
  <+0x628> = {d 0.555556};
  <+0x620> = uVar22;
  uVar22 = {d -0.2};
  <+0x638> = {d 0};
  <+0x630> = uVar22;
  <+0x640> = -0.261799;
  <+0x648> = 1f;
  <+0x67c> = 0;
  <+0x664> = 0;
  <+0x65c> = 0;
  <+0x674> = 0;
  <+0x66c> = 0;
  <+0x654> = 0;
  <+0x64c> = 0;
  uVar22 = {d 1};
  <+0x688> = {d 0.25};
  <+0x680> = uVar22;
  <+0x6a0> = 0;
  <+0x698> = 0;
  <+0x690> = 0;
  <+0x6a8> = 0xff0000000000;
  <+0x6e0> = 0;
  <+0x6e8> = 0;
  <+0x6d6> = 0;
  <+0x6ce> = 0;
  <+0x6c8> = 0;
  <+0x6c0> = 0;
  <+0x6b8> = 0;
  <+0x6b0> = 0;
  <+0x6f8> = 0;
  <+0x6f0> = 0;
  FUN_195eda2a0(&local_d0,pdVar5);
  <+0x6e8> = uStack_c8;
  <+0x6e0> = local_d0;
  <+0x6f8> = uStack_b8;
  <+0x6f0> = uStack_c0;
  return;
}


//######## anon.ControlParametersModifier (params) 0x195f027d4
// === 195f071b4 params

/* WARNING: Removing unreachable block (ram,0x000195f072b8) */
/* WARNING: Removing unreachable block (ram,0x000195f07240) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f071b4(undefined4 <backdropScale>,long param_2)
{
  undefined1 auStack_1ca8 [272];
  undefined1 auStack_1a70 [272];
  undefined1 auStack_1838 [272];
  undefined1 auStack_1600 [272];
  undefined1 auStack_13c8 [272];
  undefined1 auStack_1190 [272];
  undefined1 auStack_f58 [272];
  undefined1 auStack_d20 [276];
  undefined4 local_9c8 [2];
  (*_DAT_1e2125200)();
  lVar5 = 0;
  func_0x0001981217d0();
  lVar14 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar14 + 0x40));
  puVar9 = (undefined8 *)((long)&local_1ee0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0));
  lVar6 = 0;
  func_0x000198120110();
  lVar15 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar15 + 0x40));
  lVar34 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195f3c68c();
  iVar4 = *(int *)(lVar7 + 0x18);
  lVar8 = lVar34;
  (**(code **)(lVar15 + 0x68))(lVar34,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  lVar7 = param_2 + iVar4;
  local_1dd0 = param_2;
  func_0x0001980ff320(lVar7,lVar34,lVar6,lVar8);
  local_1de4 = (uint)lVar7;
  (**(code **)(lVar15 + 8))(lVar34,lVar6);
  <backdropScale> = 1f;
  uVar47 = *_DAT_1e01830d0;
  local_1dc8 = (undefined8 *)(lVar14 + 0x68);
  pcVar35 = (code *)*local_1dc8;
  local_1dd8 = lVar5;
  local_1dc0 = param_1;
  (*pcVar35)(puVar9,uVar47,lVar5);
  uVar48 = 1f;
  uVar39 = 1f;
  uVar46 = 1f;
  uVar42 = 0;
  local_1de0 = puVar9;
  func_0x0001981218c0();
  if (DAT_1eda3b1e0 != -1) {
    puVar9 = (undefined8 *)0x0;
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
  }
  fVar2 = DAT_1eda46354;
  fVar1 = DAT_1eda46350;
  uVar32 = CONCAT44(uVar39,uVar48);
  uVar26 = CONCAT44(uVar42,uVar46);
  uStack_e8 = ram0x0001eda46320;
  local_f0 = ram0x0001eda46318;
  uStack_d8 = ram0x0001eda46330;
  local_e0 = ram0x0001eda46328;
  uStack_c8 = ram0x0001eda46340;
  local_d0 = ram0x0001eda46338;
  uStack_c3 = DAT_1eda46344._1_3_;
  uStack_c0 = ram0x0001eda46348;
  uStack_f8 = _DAT_1eda46310;
  local_100 = _DAT_1eda46308;
  if (DAT_1eda46304 == 1.0) {
    local_148 = {d 0.0078125};
    local_140 = 1f;
    uStack_124 = 0;
    local_12c = 0;
    local_11c = 0x100000000;
    uStack_10c = 0;
    local_114 = 0;
    uVar28 = 1;
    local_104 = 1;
    puVar9 = &local_148;
    local_13c = uVar32;
    local_134 = uVar26;
    FUN_195ed7db4(puVar9,&local_100);
    if (((((ulong)puVar9 & 1) != 0) && (fVar1 == 1.0)) && (fVar2 == 1.0)) {
      uVar32 = 0;
      uVar26 = 0;
      uVar17 = 0;
      uVar16 = 0;
      uVar48 = 0;
      uVar11 = 0;
      uVar18 = 0;
      goto LAB_195f074e4;
    }
  }
  uVar28 = 0;
  uVar48 = 1f;
  uVar16 = 0.0078125;
  uVar17 = 0x100000000;
  uVar11 = {f 1, 0};
  uVar18 = {d 0.0078125};
LAB_195f074e4:
  puVar10 = local_1dc0;
  *(undefined8 *)(local_1dc0 + 0x46) = uVar18;
  *(undefined8 *)(local_1dc0 + 0x44) = uVar11;
  *(undefined8 *)(local_1dc0 + 0x48) = uVar32;
  *(undefined8 *)(local_1dc0 + 0x4a) = uVar26;
  *(undefined8 *)(local_1dc0 + 0x4e) = 0;
  *(undefined8 *)(local_1dc0 + 0x4c) = 0;
  *(undefined8 *)(local_1dc0 + 0x50) = uVar17;
  *(undefined8 *)(local_1dc0 + 0x54) = 0;
  *(undefined8 *)(local_1dc0 + 0x52) = 0;
  *(undefined8 *)(local_1dc0 + 0x56) = uVar16;
  local_1dc0[0x58] = uVar48;
  *(undefined1 *)(local_1dc0 + 0x59) = uVar28;
  FUN_195ed53f0();
  if (((ulong)puVar9 & 1) == 0) {
    local_1e00 = CONCAT44(local_1e00._4_4_,uVar47);
    local_1e08 = pcVar35;
    func_0x000198104610(&local_be8,puVar10 + 0x7a,0x10d);
    iVar4 = (int)&local_be8;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      local_b74 = 0;
      local_b2c = 0;
      local_b24 = 0;
      local_b18 = 0;
      local_b10 = 0;
      local_b04 = 0;
      local_afc = 0;
      uVar19 = 0;
      local_be0 = 0;
      local_be8 = 0;
      local_bd8 = 0;
      uVar21 = 1;
      uVar23 = 1;
      uVar36 = 1;
      local_b58 = 0;
      local_b50 = 0;
      local_b48 = 0;
      local_b40 = 0;
      local_b38 = 0;
      local_b34 = 0;
      local_b30 = 0;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,1);
      local_1df0 = CONCAT44(local_1df0._4_4_,1);
      local_1df8 = CONCAT44(local_1df8._4_4_,1);
      local_af0 = 0;
      local_ae8 = 0;
      local_ae4 = 0;
      local_ae0 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar30 = 0;
      uVar24 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar47 = 0;
      local_be4 = in_w6;
      local_bcc = in_w7;
      uVar48 = 0;
      uVar39 = 0;
    }
    else {
      uVar21 = (uint)local_b94;
      local_bec = local_b93;
      local_bea = local_b91;
      uVar23 = (uint)local_b80;
      local_bee = local_b7d;
      local_bf0 = local_b7f;
      uVar36 = (uint)local_b6c;
      local_bf2 = local_b69;
      local_bf4 = local_b6b;
      local_1e10 = CONCAT44(local_1e10._4_4_,local_b54);
      local_1dd0 = CONCAT44(local_1dd0._4_4_,(uint)local_b1c);
      local_bf6 = local_b19;
      local_bf8 = local_b1b;
      local_1df0 = CONCAT44(local_1df0._4_4_,(uint)local_b08);
      local_bfa = local_b05;
      local_bfc = local_b07;
      local_1df8 = CONCAT44(local_1df8._4_4_,(uint)local_af4);
      local_bfe = local_af1;
      local_c00 = local_af3;
      uVar19 = (uint)local_adc;
      uVar32 = local_ba4;
      uVar26 = local_b9c;
      uVar11 = local_b90;
      uVar30 = local_b88;
      uVar24 = local_b7c;
      uVar18 = local_bc8;
      uVar16 = local_bc0;
      uVar17 = local_bb8;
      uVar20 = local_b68;
      uVar38 = local_b60;
      uVar47 = local_ba8;
      uVar48 = local_bb0;
      uVar39 = local_bac;
    }
    local_c04 = local_bf8;
    local_c02 = local_bf6;
    local_c08 = local_bfc;
    local_c06 = local_bfa;
    local_c0c = local_c00;
    local_c0a = local_bfe;
    local_1e80 = CONCAT44(local_1e80._4_4_,local_be8);
    local_1e50 = CONCAT44(local_1e50._4_4_,local_be4);
    local_240 = 1f;
    local_1e58 = CONCAT44(local_1e58._4_4_,local_bcc);
    local_1e70 = CONCAT44(local_1e70._4_4_,uVar21);
    local_204 = (undefined1)uVar21;
    local_203 = local_bec;
    local_201 = local_bea;
    local_1e78 = CONCAT44(local_1e78._4_4_,uVar23);
    local_1f0 = (undefined1)uVar23;
    local_1ef = local_bf0;
    local_1ed = local_bee;
    local_1e88 = CONCAT44(local_1e88._4_4_,uVar36);
    local_1dc = (undefined1)uVar36;
    local_1d9 = local_bf2;
    local_1db = local_bf4;
    local_1e98 = CONCAT44(local_1e98._4_4_,local_b58);
    local_1c4 = (undefined4)local_1e10;
    local_1eb8 = CONCAT44(local_1eb8._4_4_,local_b38);
    local_1ec0 = CONCAT44(local_1ec0._4_4_,local_b34);
    local_1ec8 = CONCAT44(local_1ec8._4_4_,local_b30);
    local_18c = (undefined1)local_1dd0;
    local_189 = local_bf6;
    local_18b = local_bf8;
    local_178 = (undefined1)local_1df0;
    local_175 = local_bfa;
    local_177 = local_bfc;
    local_164 = (undefined1)local_1df8;
    local_161 = local_bfe;
    local_163 = local_c00;
    local_1ed8 = CONCAT44(local_1ed8._4_4_,local_ae8);
    local_1e60 = CONCAT44(local_1e60._4_4_,uVar19);
    local_14c = (undefined1)uVar19;
    local_9c8[0] = 0;
    local_9b8 = 0;
    local_9c0 = 0;
    local_9b0 = 0;
    local_978 = 0;
    uStack_980 = 0;
    local_988 = 0;
    uStack_990 = 0;
    local_998 = 0;
    uStack_9a0 = 0;
    local_9a8 = 0;
    local_974 = 1;
    local_968 = 0;
    local_970 = 0;
    local_960 = 1;
    local_954 = 0;
    local_95c = 0;
    local_94c = 1;
    local_940 = 0;
    local_948 = 0;
    local_938 = 0;
    local_900 = 0;
    uStack_908 = 0;
    local_910 = 0;
    uStack_918 = 0;
    local_920 = 0;
    uStack_928 = 0;
    local_930 = 0;
    local_8fc = 1;
    local_8f0 = 0;
    local_8f8 = 0;
    local_8e8 = 1;
    local_8dc = 0;
    local_8e4 = 0;
    local_8d4 = 1;
    uStack_8c0 = 0;
    uStack_8c8 = 0;
    local_8c3 = 0;
    local_8d0 = 0;
    puVar10 = &local_258;
    local_1ee0._0_4_ = local_ae0;
    local_1ee0._4_4_ = local_ae4;
    local_1ed0 = local_af0;
    local_1eb0 = local_b40;
    local_1ea8 = local_b48;
    local_1ea0 = local_b50;
    local_1e90 = local_be0;
    local_1e68 = local_bd8;
    local_1e48 = local_afc;
    local_1e40 = local_b04;
    local_1e38 = local_b10;
    local_1e30 = local_b18;
    local_1e28 = local_b24;
    local_1e20 = local_b2c;
    local_1e18 = local_b74;
    local_258 = local_be8;
    local_254 = local_be4;
    local_250 = local_be0;
    local_248 = local_bd8;
    local_23c = local_bcc;
    local_238 = uVar18;
    local_230 = uVar16;
    local_228 = uVar17;
    local_220 = uVar48;
    local_21c = uVar39;
    local_218 = uVar47;
    local_214 = uVar32;
    local_20c = uVar26;
    local_200 = uVar11;
    local_1f8 = uVar30;
    local_1ec = uVar24;
    local_1e4 = local_b74;
    local_1d8 = uVar20;
    local_1d0 = uVar38;
    local_1c8 = local_b58;
    local_1c0 = local_b50;
    local_1b8 = local_b48;
    local_1b0 = local_b40;
    local_1a8 = local_b38;
    local_1a4 = local_b34;
    local_1a0 = local_b30;
    local_19c = local_b2c;
    local_194 = local_b24;
    local_188 = local_b18;
    local_180 = local_b10;
    local_174 = local_b04;
    local_16c = local_afc;
    local_160 = local_af0;
    local_158 = local_ae8;
    local_154 = local_ae4;
    local_150 = local_ae0;
    FUN_195ed8068(puVar10,local_9c8);
    if (((ulong)puVar10 & 1) == 0) {
      local_368 = (undefined4)local_1e80;
      local_364 = (undefined4)local_1e50;
      local_360 = local_1e90;
      local_358 = local_1e68;
      local_350 = 1f;
      local_34c = (undefined4)local_1e58;
      local_314 = (undefined1)local_1e70;
      local_313 = local_bec;
      local_311 = local_bea;
      local_300 = (undefined1)local_1e78;
      local_2fd = local_bee;
      local_2ff = local_bf0;
      local_2f4 = local_1e18;
      local_2ec = (undefined1)local_1e88;
      local_2e9 = local_bf2;
      local_2eb = local_bf4;
      local_2d8 = (undefined4)local_1e98;
      local_2d4 = (undefined4)local_1e10;
      local_2d0 = local_1ea0;
      local_2c8 = local_1ea8;
      local_2c0 = local_1eb0;
      local_2b8 = (undefined4)local_1eb8;
      local_2b4 = (undefined4)local_1ec0;
      local_2b0 = (undefined4)local_1ec8;
      local_2ac = local_1e20;
      local_2a4 = local_1e28;
      local_29c = (undefined1)local_1dd0;
      local_299 = local_c02;
      local_29b = local_c04;
      local_298 = local_1e30;
      local_290 = local_1e38;
      local_288 = (undefined1)local_1df0;
      local_285 = local_c06;
      local_287 = local_c08;
      local_284 = local_1e40;
      local_27c = local_1e48;
      local_274 = (undefined1)local_1df8;
      local_271 = local_c0a;
      local_273 = local_c0c;
      local_270 = local_1ed0;
      local_268 = (undefined4)local_1ed8;
      local_264 = local_1ee0._4_4_;
      local_260 = (undefined4)local_1ee0;
      local_25c = (undefined1)local_1e60;
      local_348 = uVar18;
      local_340 = uVar16;
      local_338 = uVar17;
      local_330 = uVar48;
      local_32c = uVar39;
      local_328 = uVar47;
      local_324 = uVar32;
      local_31c = uVar26;
      local_310 = uVar11;
      local_308 = uVar30;
      local_2fc = uVar24;
      local_2e8 = uVar20;
      local_2e0 = uVar38;
      _CGPointMake(&local_368);
      func_0x000198104610(auStack_d20,&local_368,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_d20);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_d20,0x10d);
    func_0x000198104610(&local_e30,auStack_d20,0x10d);
    iVar4 = (int)&local_e30;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      local_d74 = 0;
      local_d6c = 0;
      local_d60 = 0;
      local_d58 = 0;
      local_d4c = 0;
      local_d44 = 0;
      uVar19 = 0;
      local_d90 = 0;
      uVar21 = 1;
      local_d88 = 0;
      uVar23 = 1;
      uVar36 = 1;
      local_d80 = 0;
      local_d7c = 0;
      local_d78 = 0;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,1);
      local_1df0 = CONCAT44(local_1df0._4_4_,1);
      local_1df8 = CONCAT44(local_1df8._4_4_,1);
      local_d38 = 0;
      local_d30 = 0;
      local_d2c = 0;
      local_d28 = 0;
      local_e30 = 0;
      local_e28 = 0;
      local_e20 = 0;
      local_e18 = 0;
      local_e10 = 0;
      uVar32 = 0;
      uVar22 = 0;
      uVar27 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      local_d9c = 0x95f07be0;
      uVar47 = 0;
      uVar48 = 0;
      uVar39 = 0;
      uVar46 = 0;
    }
    else {
      uVar30 = (ulong)local_e2c;
      uVar24 = (ulong)local_e14;
      uVar21 = (uint)local_ddc;
      local_e34 = local_ddb;
      local_e32 = local_dd9;
      uVar23 = (uint)local_dc8;
      local_e36 = local_dc5;
      local_e38 = local_dc7;
      uVar36 = (uint)local_db4;
      local_e3a = local_db1;
      local_e3c = local_db3;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,(uint)local_d64);
      local_e3e = local_d61;
      local_e40 = local_d63;
      local_1df0 = CONCAT44(local_1df0._4_4_,(uint)local_d50);
      local_e42 = local_d4d;
      local_e44 = local_d4f;
      local_1df8 = CONCAT44(local_1df8._4_4_,(uint)local_d3c);
      local_e46 = local_d39;
      local_e48 = local_d3b;
      uVar19 = (uint)local_d24;
      uVar32 = local_dec;
      uVar22 = local_de4;
      uVar27 = local_dd8;
      uVar26 = local_dd0;
      uVar11 = local_dc4;
      uVar18 = local_dbc;
      uVar16 = local_e00;
      uVar17 = local_db0;
      uVar20 = local_da8;
      uVar38 = local_d98;
      uVar47 = local_df8;
      uVar48 = local_df4;
      uVar39 = local_df0;
      uVar46 = local_da0;
    }
    local_1e90 = CONCAT44(local_1e90._4_4_,local_e30);
    local_364 = (undefined4)uVar30;
    local_1e98 = CONCAT44(local_1e98._4_4_,local_364);
    local_1eb0 = CONCAT44(local_1eb0._4_4_,local_e18);
    local_34c = (undefined4)uVar24;
    local_1eb8 = CONCAT44(local_1eb8._4_4_,local_34c);
    local_340 = 0.8;
    local_1e48 = CONCAT44(local_1e48._4_4_,uVar21);
    local_314 = (undefined1)uVar21;
    local_311 = local_e32;
    local_313 = local_e34;
    local_1e50 = CONCAT44(local_1e50._4_4_,uVar23);
    local_300 = (undefined1)uVar23;
    local_2ff = local_e38;
    local_2fd = local_e36;
    local_1e60 = CONCAT44(local_1e60._4_4_,uVar36);
    local_2ec = (undefined1)uVar36;
    local_2eb = local_e3c;
    local_2e9 = local_e3a;
    local_1e70 = CONCAT44(local_1e70._4_4_,local_d9c);
    local_1e78 = CONCAT44(local_1e78._4_4_,local_d80);
    local_1e80 = CONCAT44(local_1e80._4_4_,local_d7c);
    local_1e88 = CONCAT44(local_1e88._4_4_,local_d78);
    local_29c = (undefined1)local_1dd0;
    local_299 = local_e3e;
    local_29b = local_e40;
    local_288 = (undefined1)local_1df0;
    local_285 = local_e42;
    local_287 = local_e44;
    local_274 = (undefined1)local_1df8;
    local_271 = local_e46;
    local_273 = local_e48;
    local_1ed0 = CONCAT44(local_1ed0._4_4_,local_d30);
    local_1ed8 = CONCAT44(local_1ed8._4_4_,local_d2c);
    local_1e40 = CONCAT44(local_1e40._4_4_,uVar19);
    local_25c = (undefined1)uVar19;
    puVar10 = &local_368;
    local_1ee0._4_4_ = local_d28;
    local_1ec8 = local_d38;
    local_1ec0 = local_e10;
    local_1ea8 = local_e20;
    local_1ea0 = local_e28;
    local_1e68 = local_d88;
    local_1e58 = local_d90;
    local_1e38 = local_d44;
    local_1e30 = local_d4c;
    local_1e28 = local_d58;
    local_1e20 = local_d60;
    local_1e18 = local_d6c;
    local_1e10 = local_d74;
    local_368 = local_e30;
    local_360 = local_e28;
    local_358 = local_e20;
    local_350 = local_e18;
    local_348 = local_e10;
    local_338 = uVar16;
    local_330 = uVar47;
    local_32c = uVar48;
    local_328 = uVar39;
    local_324 = uVar32;
    local_31c = uVar22;
    local_310 = uVar27;
    local_308 = uVar26;
    local_2fc = uVar11;
    local_2f4 = uVar18;
    local_2e8 = uVar17;
    local_2e0 = uVar20;
    local_2d8 = uVar46;
    local_2d4 = local_d9c;
    local_2d0 = uVar38;
    local_2c8 = local_d90;
    local_2c0 = local_d88;
    local_2b8 = local_d80;
    local_2b4 = local_d7c;
    local_2b0 = local_d78;
    local_2ac = local_d74;
    local_2a4 = local_d6c;
    local_298 = local_d60;
    local_290 = local_d58;
    local_284 = local_d4c;
    local_27c = local_d44;
    local_270 = local_d38;
    local_268 = local_d30;
    local_264 = local_d2c;
    local_260 = local_d28;
    FUN_195ed8068(puVar10,local_9c8);
    if (((ulong)puVar10 & 1) == 0) {
      local_478 = (undefined4)local_1e90;
      local_474 = (undefined4)local_1e98;
      local_470 = local_1ea0;
      local_468 = local_1ea8;
      local_460 = (undefined4)local_1eb0;
      local_45c = (undefined4)local_1eb8;
      local_458 = local_1ec0;
      local_450 = 0.8;
      local_424 = (undefined1)local_1e48;
      local_423 = local_e34;
      local_421 = local_e32;
      local_410 = (undefined1)local_1e50;
      local_40d = local_e36;
      local_40f = local_e38;
      local_3fc = (undefined1)local_1e60;
      local_3f9 = local_e3a;
      local_3fb = local_e3c;
      local_3e4 = (undefined4)local_1e70;
      local_3d8 = local_1e58;
      local_3d0 = local_1e68;
      local_3c8 = (undefined4)local_1e78;
      local_3c4 = (undefined4)local_1e80;
      local_3c0 = (undefined4)local_1e88;
      local_3bc = local_1e10;
      local_3b4 = local_1e18;
      local_3ac = (undefined1)local_1dd0;
      local_3a9 = local_e3e;
      local_3ab = local_e40;
      local_3a8 = local_1e20;
      local_3a0 = local_1e28;
      local_398 = (undefined1)local_1df0;
      local_395 = local_e42;
      local_397 = local_e44;
      local_394 = local_1e30;
      local_38c = local_1e38;
      local_384 = (undefined1)local_1df8;
      local_381 = local_e46;
      local_383 = local_e48;
      local_380 = local_1ec8;
      local_378 = (undefined4)local_1ed0;
      local_374 = (undefined4)local_1ed8;
      local_370 = local_1ee0._4_4_;
      local_36c = (undefined1)local_1e40;
      local_448 = uVar16;
      local_440 = uVar47;
      local_43c = uVar48;
      local_438 = uVar39;
      local_434 = uVar32;
      local_42c = uVar22;
      local_420 = uVar27;
      local_418 = uVar26;
      local_40c = uVar11;
      local_404 = uVar18;
      local_3f8 = uVar17;
      local_3f0 = uVar20;
      local_3e8 = uVar46;
      local_3e0 = uVar38;
      _CGPointMake(&local_478);
      func_0x000198104610(auStack_f58,&local_478,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_f58);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_f58,0x10d);
    func_0x000198104610(&local_1068,auStack_f58,0x10d);
    iVar4 = (int)&local_1068;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      local_fa4 = 0;
      local_f98 = 0;
      local_f90 = 0;
      local_f84 = 0;
      local_f7c = 0;
      uVar36 = 0;
      local_fc0 = 0;
      uVar23 = 1;
      local_fb8 = 0;
      uVar21 = 1;
      uVar19 = 1;
      local_fb4 = 0;
      local_fb0 = 0;
      uVar37 = 1;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,1);
      local_1df0 = CONCAT44(local_1df0._4_4_,1);
      local_f70 = 0;
      local_f68 = 0;
      local_f64 = 0;
      local_f60 = 0;
      local_1068 = 0;
      local_1060 = 0;
      local_1058 = 0;
      local_1050 = 0;
      local_1048 = 0;
      local_1040 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar43 = 0;
      uVar44 = 0;
      uVar45 = 0;
      uVar47 = 0;
      uVar48 = 0;
      uVar39 = 0;
      uVar46 = 0;
      local_3e4 = 0x9999999a;
    }
    else {
      uVar22 = (ulong)local_1064;
      uVar27 = (ulong)local_104c;
      uVar23 = (uint)local_1014;
      local_106c = local_1013;
      local_106a = local_1011;
      uVar21 = (uint)local_1000;
      local_106e = local_ffd;
      local_1070 = local_fff;
      uVar19 = (uint)local_fec;
      local_1072 = local_fe9;
      local_1074 = local_feb;
      uVar37 = (uint)local_f9c;
      local_1076 = local_f99;
      local_1078 = local_f9b;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,(uint)local_f88);
      local_107a = local_f85;
      local_107c = local_f87;
      local_1df0 = CONCAT44(local_1df0._4_4_,(uint)local_f74);
      local_107e = local_f71;
      local_1080 = local_f73;
      uVar36 = (uint)local_f5c;
      uVar32 = local_1024;
      uVar26 = local_101c;
      uVar11 = local_1010;
      uVar18 = local_1008;
      uVar16 = local_ffc;
      uVar17 = local_ff4;
      uVar20 = local_fac;
      uVar38 = local_fe8;
      uVar43 = local_fe0;
      uVar44 = local_fd0;
      uVar45 = local_fc8;
      uVar47 = local_1030;
      uVar48 = local_102c;
      uVar39 = local_1028;
      uVar46 = local_fd8;
      local_3e4 = local_fd4;
    }
    local_1e78 = CONCAT44(local_1e78._4_4_,local_1068);
    local_474 = (undefined4)uVar22;
    local_1e88 = CONCAT44(local_1e88._4_4_,local_474);
    local_1ea0 = CONCAT44(local_1ea0._4_4_,local_1050);
    local_45c = (undefined4)uVar27;
    local_1ea8 = CONCAT44(local_1ea8._4_4_,local_45c);
    local_448 = 0.5;
    local_1e38 = CONCAT44(local_1e38._4_4_,uVar23);
    local_424 = (undefined1)uVar23;
    local_421 = local_106a;
    local_423 = local_106c;
    local_1e40 = CONCAT44(local_1e40._4_4_,uVar21);
    local_410 = (undefined1)uVar21;
    local_40f = local_1070;
    local_40d = local_106e;
    local_1e50 = CONCAT44(local_1e50._4_4_,uVar19);
    local_3fc = (undefined1)uVar19;
    local_3fb = local_1074;
    local_3f9 = local_1072;
    local_1e60 = CONCAT44(local_1e60._4_4_,local_3e4);
    local_1e58 = CONCAT44(local_1e58._4_4_,local_fb8);
    local_1e68 = CONCAT44(local_1e68._4_4_,local_fb4);
    local_1e70 = CONCAT44(local_1e70._4_4_,local_fb0);
    local_1e80 = CONCAT44(local_1e80._4_4_,uVar37);
    local_3ac = (undefined1)uVar37;
    local_3a9 = local_1076;
    local_3ab = local_1078;
    local_398 = (undefined1)local_1dd0;
    local_395 = local_107a;
    local_397 = local_107c;
    local_384 = (undefined1)local_1df0;
    local_381 = local_107e;
    local_383 = local_1080;
    local_1ec8 = CONCAT44(local_1ec8._4_4_,local_f68);
    local_1ed0 = CONCAT44(local_1ed0._4_4_,local_f64);
    local_1ed8 = CONCAT44(local_1ed8._4_4_,local_f60);
    local_1e30 = CONCAT44(local_1e30._4_4_,uVar36);
    local_36c = (undefined1)uVar36;
    puVar10 = &local_478;
    local_1ec0 = local_f70;
    local_1eb8 = local_1040;
    local_1eb0 = local_1048;
    local_1e98 = local_1058;
    local_1e90 = local_1060;
    local_1e48 = local_fc0;
    local_1e28 = local_f7c;
    local_1e20 = local_f84;
    local_1e18 = local_f90;
    local_1e10 = local_f98;
    local_1df8 = local_fa4;
    local_478 = local_1068;
    local_470 = local_1060;
    local_468 = local_1058;
    local_460 = local_1050;
    local_458 = local_1048;
    local_450 = local_1040;
    local_440 = uVar47;
    local_43c = uVar48;
    local_438 = uVar39;
    local_434 = uVar32;
    local_42c = uVar26;
    local_420 = uVar11;
    local_418 = uVar18;
    local_40c = uVar16;
    local_404 = uVar17;
    local_3f8 = uVar38;
    local_3f0 = uVar43;
    local_3e8 = uVar46;
    local_3e0 = uVar44;
    local_3d8 = uVar45;
    local_3d0 = local_fc0;
    local_3c8 = local_fb8;
    local_3c4 = local_fb4;
    local_3c0 = local_fb0;
    local_3bc = uVar20;
    local_3b4 = local_fa4;
    local_3a8 = local_f98;
    local_3a0 = local_f90;
    local_394 = local_f84;
    local_38c = local_f7c;
    local_380 = local_f70;
    local_378 = local_f68;
    local_374 = local_f64;
    local_370 = local_f60;
    FUN_195ed8068(puVar10,local_9c8);
    if (((ulong)puVar10 & 1) == 0) {
      local_588 = (undefined4)local_1e78;
      local_584 = (undefined4)local_1e88;
      local_580 = local_1e90;
      local_578 = local_1e98;
      local_570 = (undefined4)local_1ea0;
      local_56c = (undefined4)local_1ea8;
      local_568 = local_1eb0;
      local_560 = local_1eb8;
      local_558 = 0.5;
      local_534 = (undefined1)local_1e38;
      local_533 = local_106c;
      local_531 = local_106a;
      local_520 = (undefined1)local_1e40;
      local_51d = local_106e;
      local_51f = local_1070;
      local_50c = (undefined1)local_1e50;
      local_509 = local_1072;
      local_50b = local_1074;
      local_4f4 = (undefined4)local_1e60;
      local_4e0 = local_1e48;
      local_4d8 = (undefined4)local_1e58;
      local_4d4 = (undefined4)local_1e68;
      local_4d0 = (undefined4)local_1e70;
      local_4c4 = local_1df8;
      local_4bc = (undefined1)local_1e80;
      local_4b9 = local_1076;
      local_4bb = local_1078;
      local_4b8 = local_1e10;
      local_4b0 = local_1e18;
      local_4a8 = (undefined1)local_1dd0;
      local_4a5 = local_107a;
      local_4a7 = local_107c;
      local_4a4 = local_1e20;
      local_49c = local_1e28;
      local_494 = (undefined1)local_1df0;
      local_491 = local_107e;
      local_493 = local_1080;
      local_490 = local_1ec0;
      local_488 = (undefined4)local_1ec8;
      local_484 = (undefined4)local_1ed0;
      local_480 = (undefined4)local_1ed8;
      local_47c = (undefined1)local_1e30;
      local_550 = uVar47;
      local_54c = uVar48;
      local_548 = uVar39;
      local_544 = uVar32;
      local_53c = uVar26;
      local_530 = uVar11;
      local_528 = uVar18;
      local_51c = uVar16;
      local_514 = uVar17;
      local_508 = uVar38;
      local_500 = uVar43;
      local_4f8 = uVar46;
      local_4f0 = uVar44;
      local_4e8 = uVar45;
      local_4cc = uVar20;
      _CGPointMake(&local_588);
      func_0x000198104610(auStack_1190,&local_588,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1190);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_1190,0x10d);
    func_0x000198104610(&local_12a0,auStack_1190,0x10d);
    iVar4 = (int)&local_12a0;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      local_125c = 0;
      local_1254 = 0;
      local_1248 = 0;
      local_1240 = 0;
      local_1234 = 0;
      local_122c = 0;
      local_119c = 0;
      uVar36 = 1;
      local_1198 = 0;
      uVar37 = 1;
      uVar31 = 1;
      local_588 = 0;
      local_1298 = 0;
      local_1290 = 0;
      local_1288 = 0;
      local_1280 = 0;
      local_1278 = 0;
      local_1270 = 0;
      local_1268 = 0;
      local_1264 = 0;
      local_1260 = 0;
      uVar25 = 1;
      uVar29 = 1;
      uVar33 = 1;
      local_1220 = 0;
      local_1218 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar43 = 0;
      uVar44 = 0;
      uVar47 = 0;
      local_129c = uVar23;
      uVar48 = 0;
      uVar39 = 0;
      uVar46 = 0;
      uVar28 = 0;
    }
    else {
      uVar25 = (uint)local_124c;
      local_12a2 = local_1249;
      local_12a4 = local_124b;
      uVar29 = (uint)local_1238;
      local_12a6 = local_1235;
      local_12a8 = local_1237;
      uVar33 = (uint)local_1224;
      local_12aa = local_1221;
      local_12ac = local_1223;
      uVar36 = (uint)local_11d4;
      local_12ae = local_11d1;
      local_12b0 = local_11d3;
      uVar37 = (uint)local_11c0;
      local_12b2 = local_11bd;
      local_12b4 = local_11bf;
      uVar31 = (uint)local_11ac;
      local_12b6 = local_11a9;
      local_12b8 = local_11ab;
      uVar32 = local_11c8;
      uVar26 = local_11b4;
      uVar11 = local_11bc;
      uVar18 = local_11e4;
      uVar16 = local_11dc;
      uVar17 = local_11d0;
      uVar20 = local_1208;
      uVar38 = local_1200;
      uVar43 = local_11f8;
      uVar44 = local_11a8;
      uVar47 = local_11a0;
      uVar19 = local_1284;
      uVar21 = local_120c;
      local_588 = local_12a0;
      uVar48 = local_11f0;
      uVar39 = local_11ec;
      uVar46 = local_11e8;
      uVar28 = local_1194;
    }
    local_1e70 = CONCAT44(local_1e70._4_4_,local_588);
    local_1e28 = CONCAT44(local_1e28._4_4_,local_129c);
    local_1e40 = CONCAT44(local_1e40._4_4_,local_1288);
    local_1e48 = CONCAT44(local_1e48._4_4_,uVar19);
    local_1e78 = CONCAT44(local_1e78._4_4_,local_1268);
    local_1e88 = CONCAT44(local_1e88._4_4_,local_1264);
    local_1ea0 = CONCAT44(local_1ea0._4_4_,local_1260);
    local_1eb8 = CONCAT44(local_1eb8._4_4_,uVar25);
    local_534 = (undefined1)uVar25;
    local_531 = local_12a2;
    local_533 = local_12a4;
    local_1ec0 = CONCAT44(local_1ec0._4_4_,uVar29);
    local_520 = (undefined1)uVar29;
    local_51f = local_12a8;
    local_51d = local_12a6;
    local_1ec8 = CONCAT44(local_1ec8._4_4_,uVar33);
    local_50c = (undefined1)uVar33;
    local_50b = local_12ac;
    local_509 = local_12aa;
    local_4f8 = 1f;
    local_1e38 = CONCAT44(local_1e38._4_4_,uVar21);
    local_1e50 = CONCAT44(local_1e50._4_4_,uVar36);
    local_4bc = (undefined1)uVar36;
    local_4b9 = local_12ae;
    local_4bb = local_12b0;
    local_1e90 = CONCAT44(local_1e90._4_4_,uVar37);
    local_4a8 = (undefined1)uVar37;
    local_4a5 = local_12b2;
    local_4a7 = local_12b4;
    local_1eb0 = CONCAT44(local_1eb0._4_4_,uVar31);
    local_494 = (undefined1)uVar31;
    local_491 = local_12b6;
    local_493 = local_12b8;
    local_1e98 = CONCAT44(local_1e98._4_4_,local_119c);
    local_1ea8 = CONCAT44(local_1ea8._4_4_,local_1198);
    puVar10 = &local_588;
    local_1ed8 = local_1218;
    local_1ed0 = local_1220;
    local_1e80 = local_1298;
    local_1e68 = local_1270;
    local_1e60 = local_1278;
    local_1e58 = local_1280;
    local_1e30 = local_1290;
    local_1e20 = local_1254;
    local_1e18 = local_125c;
    local_1e10 = local_122c;
    local_1df8 = local_1240;
    local_1df0 = local_1234;
    local_1dd0 = local_1248;
    local_584 = local_129c;
    local_580 = local_1298;
    local_578 = local_1290;
    local_570 = local_1288;
    local_56c = uVar19;
    local_568 = local_1280;
    local_560 = local_1278;
    local_558 = local_1270;
    local_550 = local_1268;
    local_54c = local_1264;
    local_548 = local_1260;
    local_544 = local_125c;
    local_53c = local_1254;
    local_530 = local_1248;
    local_528 = local_1240;
    local_51c = local_1234;
    local_514 = local_122c;
    local_508 = local_1220;
    local_500 = local_1218;
    local_4f4 = uVar21;
    local_4f0 = uVar20;
    local_4e8 = uVar38;
    local_4e0 = uVar43;
    local_4d8 = uVar48;
    local_4d4 = uVar39;
    local_4d0 = uVar46;
    local_4cc = uVar18;
    local_4c4 = uVar16;
    local_4b8 = uVar17;
    local_4b0 = uVar32;
    local_4a4 = uVar11;
    local_49c = uVar26;
    local_490 = uVar44;
    local_488 = uVar47;
    local_484 = local_119c;
    local_480 = local_1198;
    local_47c = uVar28;
    FUN_195ed8068(puVar10,local_9c8);
    if (((ulong)puVar10 & 1) == 0) {
      local_698 = (undefined4)local_1e70;
      local_694 = (undefined4)local_1e28;
      local_690 = local_1e80;
      local_688 = local_1e30;
      local_680 = (undefined4)local_1e40;
      local_67c = (undefined4)local_1e48;
      local_678 = local_1e58;
      local_670 = local_1e60;
      local_668 = local_1e68;
      local_660 = (undefined4)local_1e78;
      local_65c = (undefined4)local_1e88;
      local_658 = (undefined4)local_1ea0;
      local_654 = local_1e18;
      local_64c = local_1e20;
      local_644 = (undefined1)local_1eb8;
      local_643 = local_12a4;
      local_641 = local_12a2;
      local_640 = local_1dd0;
      local_638 = local_1df8;
      local_630 = (undefined1)local_1ec0;
      local_62d = local_12a6;
      local_62f = local_12a8;
      local_62c = local_1df0;
      local_624 = local_1e10;
      local_61c = (undefined1)local_1ec8;
      local_619 = local_12aa;
      local_61b = local_12ac;
      local_618 = local_1ed0;
      local_610 = local_1ed8;
      local_608 = 1f;
      local_604 = (undefined4)local_1e38;
      local_5cc = (undefined1)local_1e50;
      local_5c9 = local_12ae;
      local_5cb = local_12b0;
      local_5b8 = (undefined1)local_1e90;
      local_5b5 = local_12b2;
      local_5b7 = local_12b4;
      local_5a4 = (undefined1)local_1eb0;
      local_5a1 = local_12b6;
      local_5a3 = local_12b8;
      local_594 = (undefined4)local_1e98;
      local_590 = (undefined4)local_1ea8;
      local_600 = uVar20;
      local_5f8 = uVar38;
      local_5f0 = uVar43;
      local_5e8 = uVar48;
      local_5e4 = uVar39;
      local_5e0 = uVar46;
      local_5dc = uVar18;
      local_5d4 = uVar16;
      local_5c8 = uVar17;
      local_5c0 = uVar32;
      local_5b4 = uVar11;
      local_5ac = uVar26;
      local_5a0 = uVar44;
      local_598 = uVar47;
      local_58c = uVar28;
      _CGPointMake(&local_698);
      func_0x000198104610(auStack_13c8,&local_698,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_13c8);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_13c8,0x10d);
    func_0x000198104610(&local_14d8,auStack_13c8,0x10d);
    iVar4 = (int)&local_14d8;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      uVar23 = 0;
      local_13ec = 0;
      local_13f4 = 0;
      local_1408 = 0;
      local_146c = 0;
      local_1428 = 0;
      local_1430 = 0;
      uVar31 = 1;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,1);
      uVar36 = 1;
      local_14c8 = 0;
      local_14c0 = 0;
      local_14b8 = 0;
      local_14b0 = 0;
      local_14a8 = 0;
      local_14a0 = 0;
      local_149c = 0;
      local_1498 = 0;
      uVar37 = 1;
      uVar25 = 1;
      uVar29 = 1;
      local_1458 = 0;
      local_1450 = 0;
      local_1448 = 0;
      local_1440 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar30 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar43 = 0;
      local_14bc = uVar19;
      uVar47 = 0;
      uVar48 = 0;
      uVar39 = 0;
      uVar46 = 0;
      uVar42 = 0;
      uVar40 = 0;
    }
    else {
      uVar37 = (uint)local_1484;
      local_14da = local_1481;
      local_14dc = local_1483;
      uVar25 = (uint)local_1470;
      local_14de = local_146d;
      local_14e0 = local_146f;
      uVar29 = (uint)local_145c;
      local_14e2 = local_1459;
      local_14e4 = local_145b;
      local_1df0 = CONCAT44(local_1df0._4_4_,local_1444);
      uVar36 = (uint)local_140c;
      local_14e6 = local_1409;
      local_14e8 = local_140b;
      local_1dd0 = CONCAT44(local_1dd0._4_4_,(uint)local_13f8);
      local_14ea = local_13f5;
      local_14ec = local_13f7;
      uVar31 = (uint)local_13e4;
      local_14ee = local_13e1;
      local_14f0 = local_13e3;
      uVar23 = (uint)local_13cc;
      uVar32 = local_1464;
      uVar26 = local_1494;
      uVar11 = local_148c;
      uVar18 = local_1480;
      uVar30 = local_1478;
      uVar16 = local_1414;
      uVar17 = local_141c;
      uVar20 = local_1400;
      uVar38 = local_13e0;
      uVar43 = local_14d0;
      uVar21 = local_14d4;
      uVar47 = local_14d8;
      uVar48 = local_1424;
      uVar39 = local_1420;
      uVar46 = local_13d8;
      uVar42 = local_13d4;
      uVar40 = local_13d0;
    }
    local_1e38 = CONCAT44(local_1e38._4_4_,uVar21);
    local_1e50 = CONCAT44(local_1e50._4_4_,local_14c0);
    local_1e60 = CONCAT44(local_1e60._4_4_,local_14bc);
    local_1e80 = CONCAT44(local_1e80._4_4_,local_14a0);
    local_1e88 = CONCAT44(local_1e88._4_4_,local_149c);
    local_1e90 = CONCAT44(local_1e90._4_4_,local_1498);
    local_1ea8 = CONCAT44(local_1ea8._4_4_,uVar37);
    local_644 = (undefined1)uVar37;
    local_641 = local_14da;
    local_643 = local_14dc;
    local_1eb0 = CONCAT44(local_1eb0._4_4_,uVar25);
    local_630 = (undefined1)uVar25;
    local_62f = local_14e0;
    local_62d = local_14de;
    local_1eb8 = CONCAT44(local_1eb8._4_4_,uVar29);
    local_61c = (undefined1)uVar29;
    local_61b = local_14e4;
    local_619 = local_14e2;
    local_1ed0 = CONCAT44(local_1ed0._4_4_,local_1448);
    local_604 = (undefined4)local_1df0;
    local_5f8 = 0.8;
    local_1e48 = CONCAT44(local_1e48._4_4_,local_1428);
    local_1e98 = CONCAT44(local_1e98._4_4_,uVar36);
    local_5cc = (undefined1)uVar36;
    local_5c9 = local_14e6;
    local_5cb = local_14e8;
    local_5b8 = (undefined1)local_1dd0;
    local_5b5 = local_14ea;
    local_5b7 = local_14ec;
    local_1ea0 = CONCAT44(local_1ea0._4_4_,uVar31);
    local_5a4 = (undefined1)uVar31;
    local_5a1 = local_14ee;
    local_5a3 = local_14f0;
    local_1e28 = CONCAT44(local_1e28._4_4_,uVar23);
    local_58c = (undefined1)uVar23;
    puVar10 = &local_698;
    local_1ed8 = local_1440;
    local_1ec8 = local_1450;
    local_1ec0 = local_1458;
    local_1e78 = local_14a8;
    local_1e70 = local_14b0;
    local_1e68 = local_14b8;
    local_1e58 = local_1430;
    local_1e40 = local_14c8;
    local_1e30 = uVar32;
    local_1e20 = local_146c;
    local_1e18 = local_13f4;
    local_1e10 = local_13ec;
    local_1df8 = local_1408;
    local_698 = uVar47;
    local_694 = uVar21;
    local_690 = uVar43;
    local_688 = local_14c8;
    local_680 = local_14c0;
    local_67c = local_14bc;
    local_678 = local_14b8;
    local_670 = local_14b0;
    local_668 = local_14a8;
    local_660 = local_14a0;
    local_65c = local_149c;
    local_658 = local_1498;
    local_654 = uVar26;
    local_64c = uVar11;
    local_640 = uVar18;
    local_638 = uVar30;
    local_62c = local_146c;
    local_624 = uVar32;
    local_618 = local_1458;
    local_610 = local_1450;
    local_608 = local_1448;
    local_600 = local_1440;
    local_5f0 = local_1430;
    local_5e8 = local_1428;
    local_5e4 = uVar48;
    local_5e0 = uVar39;
    local_5dc = uVar17;
    local_5d4 = uVar16;
    local_5c8 = local_1408;
    local_5c0 = uVar20;
    local_5b4 = local_13f4;
    local_5ac = local_13ec;
    local_5a0 = uVar38;
    local_598 = uVar46;
    local_594 = uVar42;
    local_590 = uVar40;
    FUN_195ed8068(puVar10,local_9c8);
    uVar13 = (undefined4)uVar32;
    if (((ulong)puVar10 & 1) == 0) {
      local_7a4 = (undefined4)local_1e38;
      local_798 = local_1e40;
      local_790 = (undefined4)local_1e50;
      local_78c = (undefined4)local_1e60;
      local_788 = local_1e68;
      local_780 = local_1e70;
      local_778 = local_1e78;
      local_770 = (undefined4)local_1e80;
      local_76c = (undefined4)local_1e88;
      local_768 = (undefined4)local_1e90;
      local_754 = (undefined1)local_1ea8;
      local_753 = local_14dc;
      local_751 = local_14da;
      local_740 = (undefined1)local_1eb0;
      local_73d = local_14de;
      local_73f = local_14e0;
      local_73c = local_1e20;
      local_734 = local_1e30;
      local_72c = (undefined1)local_1eb8;
      local_729 = local_14e2;
      local_72b = local_14e4;
      local_728 = local_1ec0;
      local_720 = local_1ec8;
      local_718 = (undefined4)local_1ed0;
      local_714 = (undefined4)local_1df0;
      local_710 = local_1ed8;
      local_708 = 0.8;
      local_700 = local_1e58;
      local_6f8 = (undefined4)local_1e48;
      local_6dc = (undefined1)local_1e98;
      local_6d9 = local_14e6;
      local_6db = local_14e8;
      local_6d8 = local_1df8;
      local_6c8 = (undefined1)local_1dd0;
      local_6c5 = local_14ea;
      local_6c7 = local_14ec;
      local_6c4 = local_1e18;
      local_6bc = local_1e10;
      local_6b4 = (undefined1)local_1ea0;
      local_6b1 = local_14ee;
      local_6b3 = local_14f0;
      local_69c = (undefined1)local_1e28;
      local_7a8 = uVar47;
      local_7a0 = uVar43;
      local_764 = uVar26;
      local_75c = uVar11;
      local_750 = uVar18;
      local_748 = uVar30;
      local_6f4 = uVar48;
      local_6f0 = uVar39;
      local_6ec = uVar17;
      local_6e4 = uVar16;
      local_6d0 = uVar20;
      local_6b0 = uVar38;
      local_6a8 = uVar46;
      local_6a4 = uVar42;
      local_6a0 = uVar40;
      _CGPointMake(&local_7a8);
      func_0x000198104610(auStack_1600,&local_7a8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1600);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_1600,0x10d);
    func_0x000198104610(&local_1710,auStack_1600,0x10d);
    iVar4 = (int)&local_1710;
    FUN_195e7d8c0();
    if (iVar4 == 1) {
      local_16cc = 0;
      local_16c4 = 0;
      local_16b8 = 0;
      local_16b0 = 0;
      local_16a4 = 0;
      local_1708 = 0;
      uVar29 = 1;
      local_1700 = 0;
      uVar25 = 1;
      uVar19 = 1;
      local_16f8 = 0;
      local_16f0 = 0;
      local_16e8 = 0;
      local_16e0 = 0;
      local_16d8 = 0;
      local_16d4 = 0;
      local_16d0 = 0;
      uVar23 = 1;
      uVar36 = 1;
      uVar37 = 1;
      local_1690 = 0;
      local_1688 = 0;
      local_1680 = 0;
      local_1678 = 0;
      local_1670 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar47 = 0;
      uVar48 = 0;
      local_16f4 = uVar21;
      uVar39 = 0;
      uVar46 = 0;
      uVar42 = 0;
      uVar40 = 0;
      uVar41 = 0;
      uVar28 = 0;
    }
    else {
      uVar23 = (uint)local_16bc;
      local_1712 = local_16b9;
      local_1714 = local_16bb;
      uVar36 = (uint)local_16a8;
      local_1716 = local_16a5;
      local_1718 = local_16a7;
      uVar37 = (uint)local_1694;
      local_171a = local_1691;
      local_171c = local_1693;
      uVar30 = (ulong)local_167c;
      uVar19 = (uint)local_1644;
      local_171e = local_1641;
      local_1720 = local_1643;
      uVar25 = (uint)local_1630;
      local_1722 = local_162d;
      local_1724 = local_162f;
      uVar29 = (uint)local_161c;
      local_1726 = local_1619;
      local_1728 = local_161b;
      uVar32 = local_1640;
      uVar26 = local_162c;
      uVar11 = local_169c;
      uVar18 = local_1624;
      uVar16 = local_164c;
      uVar17 = local_1654;
      uVar20 = local_1638;
      uVar38 = local_1618;
      uVar47 = local_1660;
      uVar48 = local_165c;
      uVar13 = local_170c;
      uVar39 = local_1710;
      uVar46 = local_1658;
      uVar42 = local_1610;
      uVar40 = local_160c;
      uVar41 = local_1608;
      uVar28 = local_1604;
    }
    local_1dc8 = (undefined8 *)((ulong)local_1dc8 & 0xffffffffffff | 0xb2e4000000000000);
    local_1e28 = CONCAT44(local_1e28._4_4_,uVar13);
    local_1e38 = CONCAT44(local_1e38._4_4_,local_16f8);
    local_1e48 = CONCAT44(local_1e48._4_4_,local_16f4);
    local_1e68 = CONCAT44(local_1e68._4_4_,local_16d8);
    local_1e70 = CONCAT44(local_1e70._4_4_,local_16d4);
    local_1e78 = CONCAT44(local_1e78._4_4_,local_16d0);
    local_1e98 = CONCAT44(local_1e98._4_4_,uVar23);
    local_754 = (undefined1)uVar23;
    local_751 = local_1712;
    local_753 = local_1714;
    local_1ea0 = CONCAT44(local_1ea0._4_4_,uVar36);
    local_740 = (undefined1)uVar36;
    local_73f = local_1718;
    local_73d = local_1716;
    local_1ea8 = CONCAT44(local_1ea8._4_4_,uVar37);
    local_72c = (undefined1)uVar37;
    local_72b = local_171c;
    local_729 = local_171a;
    local_1ec0 = CONCAT44(local_1ec0._4_4_,local_1680);
    local_714 = (undefined4)uVar30;
    local_1ec8 = CONCAT44(local_1ec8._4_4_,local_714);
    local_700 = 0.5;
    local_1e80 = CONCAT44(local_1e80._4_4_,uVar19);
    local_6dc = (undefined1)uVar19;
    local_6d9 = local_171e;
    local_6db = local_1720;
    local_1e88 = CONCAT44(local_1e88._4_4_,uVar25);
    local_6c8 = (undefined1)uVar25;
    local_6c5 = local_1722;
    local_6c7 = local_1724;
    local_1e90 = CONCAT44(local_1e90._4_4_,uVar29);
    local_6b4 = (undefined1)uVar29;
    local_6b1 = local_1726;
    local_6b3 = local_1728;
    puVar10 = &local_7a8;
    local_1ed8 = local_1670;
    local_1ed0 = local_1678;
    local_1eb8 = local_1688;
    local_1eb0 = local_1690;
    local_1e60 = local_16e0;
    local_1e58 = local_16e8;
    local_1e50 = local_16f0;
    local_1e40 = local_1700;
    local_1e30 = local_1708;
    local_1e20 = uVar11;
    local_1e18 = local_16b0;
    local_1e10 = local_16a4;
    local_1df8 = local_16b8;
    local_1df0 = local_16c4;
    local_1dd0 = local_16cc;
    local_7a8 = uVar39;
    local_7a4 = uVar13;
    local_7a0 = local_1708;
    local_798 = local_1700;
    local_790 = local_16f8;
    local_78c = local_16f4;
    local_788 = local_16f0;
    local_780 = local_16e8;
    local_778 = local_16e0;
    local_770 = local_16d8;
    local_76c = local_16d4;
    local_768 = local_16d0;
    local_764 = local_16cc;
    local_75c = local_16c4;
    local_750 = local_16b8;
    local_748 = local_16b0;
    local_73c = local_16a4;
    local_734 = uVar11;
    local_728 = local_1690;
    local_720 = local_1688;
    local_718 = local_1680;
    local_710 = local_1678;
    local_708 = local_1670;
    local_6f8 = uVar47;
    local_6f4 = uVar48;
    local_6f0 = uVar46;
    local_6ec = uVar17;
    local_6e4 = uVar16;
    local_6d8 = uVar32;
    local_6d0 = uVar20;
    local_6c4 = uVar26;
    local_6bc = uVar18;
    local_6b0 = uVar38;
    local_6a8 = uVar42;
    local_6a4 = uVar40;
    local_6a0 = uVar41;
    local_69c = uVar28;
    FUN_195ed8068(puVar10,local_9c8);
    uVar12 = (undefined4)uVar11;
    if (((ulong)puVar10 & 1) == 0) {
      local_8b4 = (undefined4)local_1e28;
      local_8b0 = local_1e30;
      local_8a8 = local_1e40;
      local_8a0 = (undefined4)local_1e38;
      local_89c = (undefined4)local_1e48;
      local_898 = local_1e50;
      local_890 = local_1e58;
      local_888 = local_1e60;
      local_880 = (undefined4)local_1e68;
      local_87c = (undefined4)local_1e70;
      local_878 = (undefined4)local_1e78;
      local_874 = local_1dd0;
      local_86c = local_1df0;
      local_864 = (undefined1)local_1e98;
      local_863 = local_1714;
      local_861 = local_1712;
      local_860 = local_1df8;
      local_858 = local_1e18;
      local_850 = (undefined1)local_1ea0;
      local_84d = local_1716;
      local_84f = local_1718;
      local_84c = local_1e10;
      local_844 = local_1e20;
      local_83c = (undefined1)local_1ea8;
      local_839 = local_171a;
      local_83b = local_171c;
      local_838 = local_1eb0;
      local_830 = local_1eb8;
      local_828 = (undefined4)local_1ec0;
      local_824 = (undefined4)local_1ec8;
      local_820 = local_1ed0;
      local_818 = local_1ed8;
      local_810 = 0.5;
      local_7ec = (undefined1)local_1e80;
      local_7e9 = local_171e;
      local_7eb = local_1720;
      local_7d8 = (undefined1)local_1e88;
      local_7d5 = local_1722;
      local_7d7 = local_1724;
      local_7c4 = (undefined1)local_1e90;
      local_7c1 = local_1726;
      local_7c3 = local_1728;
      local_8b8 = uVar39;
      local_808 = uVar47;
      local_804 = uVar48;
      local_800 = uVar46;
      local_7fc = uVar17;
      local_7f4 = uVar16;
      local_7e8 = uVar32;
      local_7e0 = uVar20;
      local_7d4 = uVar26;
      local_7cc = uVar18;
      local_7c0 = uVar38;
      local_7b8 = uVar42;
      local_7b4 = uVar40;
      local_7b0 = uVar41;
      local_7ac = uVar28;
      _CGPointMake(&local_8b8);
      func_0x000198104610(auStack_1838,&local_8b8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1838);
    }
    puVar10 = local_1dc0;
    lVar7 = local_1dd8;
    func_0x000198104610(local_1dc0 + 0x7a,auStack_1838,0x10d);
    puVar9 = local_1de0;
    (*local_1e08)(local_1dc8,local_1de0,local_1e00 & 0xffffffff,lVar7);
    uVar39 = 0.2f;
    uVar46 = 1f;
    uVar42 = 1f;
    uVar47 = uVar39;
    uVar48 = uVar39;
    func_0x0001981218c0(puVar9);
    local_1dc8 = (undefined8 *)CONCAT44(uVar47,uVar39);
    local_1dd0 = CONCAT44(uVar42,uVar48);
    bVar3 = (local_1de4 & 1) == 0;
    if (bVar3) {
      uVar46 = 1.25f;
    }
    local_1dd8 = CONCAT44(local_1dd8._4_4_,uVar46);
    uVar47 = 0.6f;
    if (bVar3) {
      uVar47 = 0.9f;
    }
    func_0x000198104610(&local_1948,puVar10 + 0x7a,0x10d);
    iVar4 = (int)&local_1948;
    FUN_195e7d8c0();
    puVar9 = local_1dc8;
    lVar7 = local_1dd0;
    if (iVar4 == 1) {
      local_1de4 = 0;
      local_808 = 0;
      local_804 = 0;
      local_1890 = 0;
      uVar19 = 1;
      uVar21 = 1;
      uVar23 = 1;
      local_1850 = 0;
      local_1848 = 0;
      local_1844 = 0;
      local_1840 = 0;
      local_1948 = 0;
      local_1940 = 0;
      local_1938 = 0;
      local_1930 = 0;
      local_1928 = 0;
      local_1920 = 0;
      local_1918 = 0;
      local_18b4 = 1;
      uVar32 = 0;
      uVar26 = 0;
      uVar30 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar43 = 0;
      uVar44 = 0;
      local_192c = uVar13;
      uVar48 = 0;
    }
    else {
      local_194c = local_18f3;
      local_194a = local_18f1;
      local_1950 = local_18df;
      local_194e = local_18dd;
      local_1952 = local_18c9;
      local_1954 = local_18cb;
      uVar19 = (uint)local_187c;
      local_1956 = local_1879;
      local_1958 = local_187b;
      uVar21 = (uint)local_1868;
      local_195a = local_1865;
      local_195c = local_1867;
      uVar23 = (uint)local_1854;
      local_195e = local_1851;
      local_1960 = local_1853;
      local_1de4 = (uint)local_183c;
      uVar32 = local_1864;
      uVar26 = local_188c;
      uVar30 = local_1884;
      uVar11 = local_1878;
      uVar18 = local_1870;
      uVar16 = local_185c;
      uVar17 = local_18c8;
      uVar20 = local_18c0;
      uVar38 = local_18b0;
      uVar43 = local_18a8;
      uVar44 = local_18a0;
      uVar12 = local_1944;
      uVar48 = local_18b8;
      local_808 = local_1898;
      local_804 = local_1894;
    }
    local_1e48 = CONCAT44(local_1e48._4_4_,local_1948);
    local_1e50 = CONCAT44(local_1e50._4_4_,uVar12);
    local_1e68 = CONCAT44(local_1e68._4_4_,local_1930);
    local_1e70 = CONCAT44(local_1e70._4_4_,local_192c);
    uVar39 = (undefined4)local_1dd8;
    local_87c = (undefined4)local_1dd8;
    local_878 = 1.2f;
    local_86c = 0;
    local_874 = 0;
    local_864 = 1;
    local_861 = local_194a;
    local_863 = local_194c;
    local_860 = local_1dc8;
    local_858 = local_1dd0;
    local_850 = 0;
    local_84f = local_1950;
    local_84d = local_194e;
    local_84c = 0;
    local_844 = 0;
    local_83c = 1;
    local_83b = local_1954;
    local_839 = local_1952;
    local_1df0 = CONCAT44(local_1df0._4_4_,local_18b4);
    local_1df8 = CONCAT44(local_1df8._4_4_,local_808);
    local_1e00 = CONCAT44(local_1e00._4_4_,local_804);
    local_1e08 = (code *)CONCAT44(local_1e08._4_4_,local_1890);
    local_1e10 = CONCAT44(local_1e10._4_4_,uVar19);
    local_7ec = (undefined1)uVar19;
    local_7e9 = local_1956;
    local_7eb = local_1958;
    local_1e18 = CONCAT44(local_1e18._4_4_,uVar21);
    local_7d8 = (undefined1)uVar21;
    local_7d5 = local_195a;
    local_7d7 = local_195c;
    local_1e20 = CONCAT44(local_1e20._4_4_,uVar23);
    local_7c4 = (undefined1)uVar23;
    local_7c1 = local_195e;
    local_7c3 = local_1960;
    local_1e30 = CONCAT44(local_1e30._4_4_,local_1848);
    local_1e38 = CONCAT44(local_1e38._4_4_,local_1844);
    local_1e40 = CONCAT44(local_1e40._4_4_,local_1840);
    local_7ac = (undefined1)local_1de4;
    puVar10 = &local_8b8;
    local_1e88 = local_1918;
    local_1e80 = local_1920;
    local_1e78 = local_1928;
    local_1e60 = local_1938;
    local_1e58 = local_1940;
    local_1e28 = local_1850;
    local_8b8 = local_1948;
    local_8b4 = uVar12;
    local_8b0 = local_1940;
    local_8a8 = local_1938;
    local_8a0 = local_1930;
    local_89c = local_192c;
    local_898 = local_1928;
    local_890 = local_1920;
    local_888 = local_1918;
    local_880 = uVar47;
    local_838 = uVar17;
    local_830 = uVar20;
    local_828 = uVar48;
    local_824 = local_18b4;
    local_820 = uVar38;
    local_818 = uVar43;
    local_810 = uVar44;
    local_800 = local_1890;
    local_7fc = uVar26;
    local_7f4 = uVar30;
    local_7e8 = uVar11;
    local_7e0 = uVar18;
    local_7d4 = uVar32;
    local_7cc = uVar16;
    local_7c0 = local_1850;
    local_7b8 = local_1848;
    local_7b4 = local_1844;
    local_7b0 = local_1840;
    FUN_195ed8068(puVar10,local_9c8);
    local_1de0 = (undefined8 *)CONCAT44(local_1de0._4_4_,uVar47);
    if (((ulong)puVar10 & 1) == 0) {
      local_ad8 = (undefined4)local_1e48;
      local_ad4 = (undefined4)local_1e50;
      local_ad0 = local_1e58;
      local_ac8 = local_1e60;
      local_ac0 = (undefined4)local_1e68;
      local_abc = (undefined4)local_1e70;
      local_ab8 = local_1e78;
      local_ab0 = local_1e80;
      local_aa8 = local_1e88;
      local_a9c = uVar39;
      local_a98 = 1.2f;
      local_a8c = 0;
      local_a94 = 0;
      local_a84 = 1;
      local_a83 = local_194c;
      local_a81 = local_194a;
      local_a80 = puVar9;
      local_a78 = lVar7;
      local_a70 = 0;
      local_a6f = local_1950;
      local_a6d = local_194e;
      local_a6c = 0;
      local_a64 = 0;
      local_a5c = 1;
      local_a5b = local_1954;
      local_a59 = local_1952;
      local_a44 = (undefined4)local_1df0;
      local_a28 = (undefined4)local_1df8;
      local_a24 = (undefined4)local_1e00;
      local_a20 = local_1e08._0_4_;
      local_a0c = (undefined1)local_1e10;
      local_a09 = local_1956;
      local_a0b = local_1958;
      local_9f8 = (undefined1)local_1e18;
      local_9f5 = local_195a;
      local_9f7 = local_195c;
      local_9e4 = (undefined1)local_1e20;
      local_9e1 = local_195e;
      local_9e3 = local_1960;
      local_9e0 = local_1e28;
      local_9d8 = (undefined4)local_1e30;
      local_9d4 = (undefined4)local_1e38;
      local_9d0 = (undefined4)local_1e40;
      local_9cc = (undefined1)local_1de4;
      local_aa0 = uVar47;
      local_a58 = uVar17;
      local_a50 = uVar20;
      local_a48 = uVar48;
      local_a40 = uVar38;
      local_a38 = uVar43;
      local_a30 = uVar44;
      local_a1c = uVar26;
      local_a14 = uVar30;
      local_a08 = uVar11;
      local_a00 = uVar18;
      local_9f4 = uVar32;
      local_9ec = uVar16;
      _CGPointMake(&local_ad8);
      func_0x000198104610(auStack_1a70,&local_ad8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1a70);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_1a70,0x10d);
    func_0x000198104610(&local_1b80,auStack_1a70,0x10d);
    iVar4 = (int)&local_1b80;
    FUN_195e7d8c0();
    puVar9 = local_1dc8;
    lVar7 = local_1dd0;
    if (iVar4 == 1) {
      local_ad8 = 0;
      local_1b68 = 0;
      local_1b60 = 0;
      local_1b58 = 0;
      local_1b50 = 0;
      local_1b48 = 0;
      local_1b44 = 0;
      local_1b40 = 0;
      uVar19 = 1;
      uVar21 = 1;
      uVar36 = 1;
      local_1b00 = 0;
      local_1af8 = 0;
      local_1af0 = 0;
      local_1ae8 = 0;
      local_1ae0 = 0;
      local_1ad8 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar11 = 0;
      uVar18 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar20 = 0;
      uVar38 = 0;
      uVar43 = 0;
      uVar28 = 0;
      local_1b7c = uVar23;
      local_1b64 = uVar12;
      uVar47 = 0;
      uVar48 = 0;
      uVar39 = 0;
    }
    else {
      uVar19 = (uint)local_1b2c;
      local_1b82 = local_1b29;
      local_1b84 = local_1b2b;
      uVar21 = (uint)local_1b18;
      local_1b86 = local_1b15;
      local_1b88 = local_1b17;
      uVar36 = (uint)local_1b04;
      local_1b8a = local_1b01;
      local_1b8c = local_1b03;
      uVar30 = (ulong)local_1aec;
      local_1b8e = local_1ab1;
      local_1b90 = local_1ab3;
      local_1b92 = local_1a9d;
      local_1b94 = local_1a9f;
      local_1b96 = local_1a89;
      local_1b98 = local_1a8b;
      uVar32 = local_1b20;
      uVar26 = local_1b14;
      uVar11 = local_1b0c;
      uVar18 = local_1b3c;
      uVar16 = local_1b34;
      uVar17 = local_1b28;
      uVar20 = local_1a88;
      uVar38 = local_1b78;
      uVar43 = local_1b70;
      uVar28 = local_1a74;
      local_ad8 = local_1b80;
      uVar47 = local_1a80;
      uVar48 = local_1a7c;
      uVar39 = local_1a78;
    }
    uVar42 = (undefined4)local_1dd8;
    local_1dd0 = CONCAT44(local_1dd0._4_4_,local_ad8);
    local_1dc8 = (undefined8 *)CONCAT44(local_1dc8._4_4_,local_1b7c);
    local_1dd8 = CONCAT44(local_1dd8._4_4_,local_1b68);
    local_1e08 = (code *)CONCAT44(local_1e08._4_4_,local_1b48);
    local_1e10 = CONCAT44(local_1e10._4_4_,local_1b44);
    local_1e18 = CONCAT44(local_1e18._4_4_,local_1b40);
    local_1e20 = CONCAT44(local_1e20._4_4_,uVar19);
    local_a84 = (undefined1)uVar19;
    local_a81 = local_1b82;
    local_a83 = local_1b84;
    local_1e28 = CONCAT44(local_1e28._4_4_,uVar21);
    local_a70 = (undefined1)uVar21;
    local_a6f = local_1b88;
    local_a6d = local_1b86;
    local_1e30 = CONCAT44(local_1e30._4_4_,uVar36);
    local_a5c = (undefined1)uVar36;
    local_a5b = local_1b8c;
    local_a59 = local_1b8a;
    local_1e48 = CONCAT44(local_1e48._4_4_,local_1af0);
    local_a44 = (undefined4)uVar30;
    local_1e50 = CONCAT44(local_1e50._4_4_,local_a44);
    uVar46 = local_1de0._0_4_;
    local_a28 = local_1de0._0_4_;
    local_a24 = uVar42;
    local_a20 = 1.2f;
    local_a1c = 0;
    local_a14 = 0;
    local_a0c = 1;
    local_a09 = local_1b8e;
    local_a0b = local_1b90;
    local_a08 = puVar9;
    local_a00 = lVar7;
    local_9f8 = 0;
    local_9f5 = local_1b92;
    local_9f7 = local_1b94;
    local_9f4 = 0;
    local_9ec = 0;
    local_9e4 = 1;
    local_9e3 = local_1b98;
    local_9e1 = local_1b96;
    puVar10 = &local_ad8;
    local_1e68 = local_1ad8;
    local_1e60 = local_1ae0;
    local_1e58 = local_1ae8;
    local_1e40 = local_1af8;
    local_1e38 = local_1b00;
    local_1e00 = local_1b50;
    local_1df8 = local_1b58;
    local_1df0 = local_1b60;
    local_1de4 = local_1b64;
    local_ad4 = local_1b7c;
    local_ad0 = uVar38;
    local_ac8 = uVar43;
    local_ac0 = local_1b68;
    local_abc = local_1b64;
    local_ab8 = local_1b60;
    local_ab0 = local_1b58;
    local_aa8 = local_1b50;
    local_aa0 = local_1b48;
    local_a9c = local_1b44;
    local_a98 = local_1b40;
    local_a94 = uVar18;
    local_a8c = uVar16;
    local_a80 = uVar17;
    local_a78 = uVar32;
    local_a6c = uVar26;
    local_a64 = uVar11;
    local_a58 = local_1b00;
    local_a50 = local_1af8;
    local_a48 = local_1af0;
    local_a40 = local_1ae8;
    local_a38 = local_1ae0;
    local_a30 = local_1ad8;
    local_9e0 = uVar20;
    local_9d8 = uVar47;
    local_9d4 = uVar48;
    local_9d0 = uVar39;
    local_9cc = uVar28;
    FUN_195ed8068(puVar10,local_9c8);
    if (((ulong)puVar10 & 1) == 0) {
      local_1db8 = (undefined4)local_1dd0;
      local_1db4 = local_1dc8._0_4_;
      local_1da0 = (undefined4)local_1dd8;
      local_1d9c = local_1de4;
      local_1d98 = local_1df0;
      uStack_1d90 = local_1df8;
      local_1d88 = local_1e00;
      local_1d80 = local_1e08._0_4_;
      local_1d7c = (undefined4)local_1e10;
      local_1d78 = (undefined4)local_1e18;
      local_1d64 = (undefined1)local_1e20;
      local_1d63 = local_1b84;
      local_1d61 = local_1b82;
      local_1d50 = (undefined1)local_1e28;
      local_1d4f = local_1b88;
      local_1d4d = local_1b86;
      local_1d3c = (undefined1)local_1e30;
      local_1d3b = local_1b8c;
      local_1d39 = local_1b8a;
      local_1d38 = local_1e38;
      uStack_1d30 = local_1e40;
      local_1d28 = (undefined4)local_1e48;
      local_1d24 = (undefined4)local_1e50;
      local_1d20 = local_1e58;
      uStack_1d18 = local_1e60;
      local_1d10 = local_1e68;
      local_1d08 = uVar46;
      local_1d04 = uVar42;
      local_1d00 = 1.2f;
      local_1cfc = 0;
      local_1cf4 = 0;
      local_1cec = 1;
      local_1ce9 = local_1b8e;
      local_1ceb = local_1b90;
      local_1ce8 = puVar9;
      uStack_1ce0 = lVar7;
      local_1cd8 = 0;
      local_1cd5 = local_1b92;
      local_1cd7 = local_1b94;
      local_1cd4 = 0;
      local_1ccc = 0;
      local_1cc4 = 1;
      local_1cc3 = local_1b98;
      local_1cc1 = local_1b96;
      local_1db0 = uVar38;
      uStack_1da8 = uVar43;
      local_1d74 = uVar18;
      local_1d6c = uVar16;
      local_1d60 = uVar17;
      uStack_1d58 = uVar32;
      local_1d4c = uVar26;
      local_1d44 = uVar11;
      local_1cc0 = uVar20;
      local_1cb8 = uVar47;
      local_1cb4 = uVar48;
      local_1cb0 = uVar39;
      local_1cac = uVar28;
      _CGPointMake(&local_1db8);
      func_0x000198104610(auStack_1ca8,&local_1db8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1ca8);
    }
    func_0x000198104610(local_1dc0 + 0x7a,auStack_1ca8,0x10d);
  }
  return;
}


//######## ControlSliderRecipe.anon.SliderSpecModifier (spec) 0x195f02810
// === 195f04360 spec

/* WARNING: Removing unreachable block (ram,0x000195f04434) */
/* WARNING: Removing unreachable block (ram,0x000195f043bc) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f04360(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar8 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar11 = puVar8 + -(extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar5 + 0x18);
  puVar6 = puVar11;
  (**(code **)(lVar10 + 0x68))(puVar11,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar2;
  func_0x0001980ff320(uVar7,puVar11,lVar4,puVar6);
  (**(code **)(lVar10 + 8))(puVar11,lVar4);
  puVar1 = (undefined4 *)(param_2 + *(int *)(lVar5 + 0x20));
  if (*(char *)(puVar1 + 4) == '\x01') {
    (**(code **)(lVar9 + 0x68))(puVar8,*_DAT_1e01830d0,lVar3);
    fVar13 = 0.478;
    uVar12 = 0;
    func_0x0001981218c0(0,0.478f,1f,1f);
    puVar11 = puVar8;
  }
  else {
    uVar12 = *puVar1;
    fVar13 = (float)puVar1[1];
  }
  FUN_195f7fc20();
  fVar13 = fVar13 * 0.25;
  uVar14 = 0.45f;
  uVar15 = 1f;
  FUN_195f7f998();
  <shadow.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar15 >> 0x18),
                CONCAT16((char)((uint)uVar15 >> 0x10),
                         CONCAT15((char)((uint)uVar15 >> 8),CONCAT14((char)uVar15,uVar14))));
  <shadow.ycc.normalFill.r> =
       CONCAT17((char)((uint)fVar13 >> 0x18),
                CONCAT16((char)((uint)fVar13 >> 0x10),
                         CONCAT15((char)((uint)fVar13 >> 8),CONCAT14(SUB41(fVar13,0),uVar12))));
  <shadow.ycc.normalFill?nil> = 0;
  if (<+0x51> == '\0') {
    <shadow.opacity> = (ulong)(uint)(<shadow.opacity> * 1.8);
    <+0x38> = 0;
    <+0x30> = 0;
    <+0x48> = 0;
    <+0x40> = 0;
    <+0x50> = 0;
  }
  else if (<+0x51> == '\x02') {
    <+0x38> =
         CONCAT44((float)((ulong)<+0x38> >> 0x20) * 1.8,
                  (float)<+0x38> * 1.8);
    <+0x40> = <+0x40> & 0xffffffffff;
    <+0x51> = 2;
  }
  <blur.opacity> = 1f;
  FUN_195ed53f0();
  if (((ulong)puVar11 & 1) == 0) {
    puVar11 = *(undefined1 **)(<blur.blurRadius>);
    FUN_195eda468(puVar11,<+0x170>,<+0x178>,
                  <+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    <blur.blurRadius> = 2f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  <refraction.normalizedInnerHeight> = <refraction.normalizedInnerHeight> * 1.8;
  <refraction.normalizedInnerAmount> = <refraction.normalizedInnerAmount> + <refraction.normalizedInnerAmount>;
  <+0x610> = 0;
  <+0x608> = 0;
  FUN_195ed53f0();
  if (((ulong)puVar11 & 1) != 0) {
    <+0x680> = 0;
    <+0x620> = 0;
    uVar12 = 0.4f;
    if ((uVar7 & 1) == 0) {
      uVar12 = 0.15f;
    }
    <ringShadow.opacity> = uVar12;
  }
  return;
}


//######## ControlSliderRecipe.anon.SliderParametersModifier (params) 0x195f02814
// === 195f046b8 params

/* WARNING: Removing unreachable block (ram,0x000195f04744) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f046b8(long param_1,long param_2)
{
  undefined1 auStack_1960 [272];
  undefined1 auStack_1728 [272];
  undefined1 auStack_14f0 [272];
  undefined1 auStack_12b8 [272];
  undefined1 auStack_1080 [272];
  undefined1 auStack_e48 [272];
  undefined1 auStack_c10 [276];
  undefined4 local_8b8 [2];
  (*_DAT_1e2125200)();
  lVar5 = 0;
  func_0x0001981217d0();
  lVar12 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar12 + 0x40));
  puVar7 = (undefined4 *)((long)&local_1b60 - (extraout_x8 + 0xfU & 0xfffffffffffffff0));
  puVar6 = (undefined4 *)0x0;
  FUN_195f3c68c();
  puVar24 = (undefined4 *)(param_2 + (int)puVar6[8]);
  local_1a80 = param_2;
  if (*(char *)(puVar24 + 4) == '\x01') {
    (**(code **)(lVar12 + 0x68))(puVar7,*_DAT_1e01830d0,lVar5);
    uVar15 = 0.478f;
    uVar56 = 0;
    uVar57 = 1f;
    fVar52 = 1.0;
    func_0x0001981218c0();
    local_1a98 = CONCAT44(local_1a98._4_4_,uVar56);
    local_1a90 = uVar15 & 0xffffffff;
    local_1a88 = CONCAT44(local_1a88._4_4_,uVar57);
    puVar6 = puVar7;
  }
  else {
    local_1a88 = CONCAT44(local_1a88._4_4_,puVar24[2]);
    local_1a90 = (ulong)(uint)puVar24[1];
    local_1a98 = CONCAT44(local_1a98._4_4_,*puVar24);
    fVar52 = (float)puVar24[3];
  }
  pfVar13 = &DAT_1eda46304;
  local_1a78 = param_1;
  if (<faceEffects?nil> == '\x01') {
    pfVar28 = &DAT_1eda46354;
    pfVar43 = &DAT_1eda46350;
    puVar24 = &DAT_1eda4634c;
    puVar39 = &DAT_1eda46344;
    puVar18 = &DAT_1eda4633c;
    puVar35 = &DAT_1eda46334;
    puVar20 = &DAT_1eda46314;
    puVar14 = (undefined8 *)&DAT_1eda4630c;
    puVar17 = &DAT_1eda4631c;
    puVar21 = &DAT_1eda46324;
    puVar22 = &DAT_1eda4632c;
    if (DAT_1eda3b1e0 != -1) {
      puVar6 = (undefined4 *)0x0;
      local_1ab0 = &DAT_1eda4632c;
      local_1aa8 = &DAT_1eda46324;
      local_1aa0 = &DAT_1eda4631c;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      puVar17 = local_1aa0;
      puVar21 = local_1aa8;
      puVar22 = local_1ab0;
    }
    bVar3 = true;
  }
  else {
    pfVar13 = (float *)(<faceEffects.opacity>);
    puVar14 = (undefined8 *)(<faceEffects.ycc.white>);
    puVar20 = (undefined8 *)(<faceEffects.ycc.normalFill.r>);
    puVar17 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
    puVar21 = (undefined8 *)(<faceEffects.ycc.normalFill?nil>);
    puVar22 = (undefined8 *)(<faceEffects.ycc.dodgeFill.g>);
    puVar35 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
    puVar18 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
    puVar39 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
    puVar24 = (undefined4 *)(<faceEffects.ycc.burnFill?nil>);
    pfVar28 = (float *)(<faceEffects.maxLuminanceSDR>);
    pfVar43 = (float *)(<faceEffects.maxLuminance>);
    bVar3 = DAT_1eda3b1e0 == -1;
  }
  fVar53 = *pfVar28;
  fVar54 = *pfVar43;
  uVar56 = *puVar24;
  uVar19 = *puVar18;
  uVar37 = *puVar22;
  uVar40 = *puVar21;
  uVar44 = *puVar17;
  uVar29 = *puVar20;
  uVar36 = *puVar14;
  fVar55 = *pfVar13;
  puVar18 = (undefined8 *)*puVar39;
  puVar20 = (undefined8 *)*puVar35;
  if (!bVar3) {
    puVar6 = (undefined4 *)0x0;
    local_1aa8 = (undefined8 *)*puVar35;
    local_1aa0 = (undefined8 *)*puVar39;
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    puVar18 = local_1aa0;
    puVar20 = local_1aa8;
  }
  fVar2 = DAT_1eda46354;
  fVar1 = DAT_1eda46350;
  uStack_d8 = ram0x0001eda46330;
  local_e0 = ram0x0001eda46328;
  uStack_c8 = ram0x0001eda46340;
  uStack_d0 = ram0x0001eda46338;
  local_c3 = DAT_1eda46344._1_3_;
  uStack_c0 = ram0x0001eda46348;
  uStack_f8 = _DAT_1eda46310;
  local_100 = _DAT_1eda46308;
  uStack_e8 = ram0x0001eda46320;
  uStack_f0 = ram0x0001eda46318;
  if (fVar55 == DAT_1eda46304) {
    local_148 = 0.1f;
    local_104 = (undefined1)uVar56;
    puVar6 = &local_148;
    local_144 = uVar36;
    local_13c = uVar29;
    local_134 = uVar44;
    local_12c = uVar40;
    local_124 = uVar37;
    local_11c = puVar20;
    local_114 = uVar19;
    local_10c = puVar18;
    FUN_195ed7db4(puVar6,&local_100);
    if (((((ulong)puVar6 & 1) != 0) && (fVar54 == fVar1)) && (fVar53 == fVar2)) {
      uVar15 = 0;
      uVar36 = 0;
      uVar29 = 0;
      uVar44 = 0;
      uVar40 = 0;
      uVar37 = 0;
      puVar20 = (undefined8 *)0x0;
      uVar19 = 0;
      puVar18 = (undefined8 *)0x0;
      uVar16 = 0;
      fVar53 = 0.0;
      uVar23 = 1;
      goto LAB_195f049ec;
    }
  }
  uVar23 = 0;
  uVar15 = (ulong)(uint)fVar55 | (f 0, f 0.1);
  uVar16 = CONCAT44(fVar54,uVar56);
LAB_195f049ec:
  lVar5 = local_1a78;
  *(ulong *)(local_1a78 + 0x110) = uVar15;
  *(undefined8 *)(local_1a78 + 0x118) = uVar36;
  *(undefined8 *)(local_1a78 + 0x120) = uVar29;
  *(undefined8 *)(local_1a78 + 0x128) = uVar44;
  *(undefined8 *)(local_1a78 + 0x130) = uVar40;
  *(undefined8 *)(local_1a78 + 0x138) = uVar37;
  *(undefined8 **)(local_1a78 + 0x140) = puVar20;
  *(undefined8 *)(local_1a78 + 0x148) = uVar19;
  *(undefined8 **)(local_1a78 + 0x150) = puVar18;
  *(undefined8 *)(local_1a78 + 0x158) = uVar16;
  *(float *)(local_1a78 + 0x160) = fVar53;
  *(undefined1 *)(local_1a78 + 0x164) = uVar23;
  FUN_195ed53f0();
  if (((ulong)puVar6 & 1) == 0) {
    iVar8 = (int)lVar5 + 0x1e8;
    uVar56 = 0x10d;
    func_0x000198104610(&local_ad8);
    iVar4 = (int)&local_ad8;
    FUN_195e7d8c0();
    uVar19 = {d 3.05176e-05};
    if (iVar4 == 1) {
      local_a00 = 0;
      local_9f4 = 0;
      local_9ec = 0;
      uVar9 = 0;
      local_ad0 = 0;
      local_ad8 = 0;
      local_ac8 = 0;
      local_240 = 0;
      local_ab8 = 0;
      local_ab0 = 0;
      local_aa8 = 0;
      local_a24 = 0;
      local_a20 = 0;
      uVar31 = 1;
      uVar11 = 1;
      local_1b0c = 1;
      local_9e0 = 0;
      local_9d8 = 0;
      local_9d4 = 0;
      local_9d0 = 0;
      local_a44 = 1;
      uVar29 = 0;
      uVar36 = 0;
      uVar15 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar57 = 0;
      local_ad4 = iVar8;
      local_abc = uVar56;
      uVar56 = 0;
    }
    else {
      local_adc = local_a83;
      local_ada = local_a81;
      local_ae0 = local_a6f;
      local_ade = local_a6d;
      local_ae2 = local_a59;
      local_ae4 = local_a5b;
      uVar31 = (uint)local_a0c;
      local_ae6 = local_a09;
      local_ae8 = local_a0b;
      uVar11 = (uint)local_9f8;
      local_aea = local_9f5;
      local_aec = local_9f7;
      local_1b0c = (uint)local_9e4;
      local_aee = local_9e1;
      local_af0 = local_9e3;
      uVar9 = (uint)local_9cc;
      uVar29 = local_a1c;
      uVar36 = local_a14;
      uVar15 = local_a08;
      uVar37 = local_a58;
      uVar40 = local_a50;
      uVar44 = local_a40;
      uVar16 = local_a38;
      uVar49 = local_a30;
      uVar57 = local_a28;
      local_240 = local_ac0;
      uVar56 = local_a48;
    }
    uVar25 = local_1a98 & 0xffffffff | local_1a90 << 0x20;
    uVar41 = CONCAT44(fVar52 * 0.5,(undefined4)local_1a88);
    local_af4 = local_ae8;
    local_af2 = local_ae6;
    local_af8 = local_aec;
    local_af6 = local_aea;
    local_afc = local_af0;
    local_afa = local_aee;
    local_1ac0 = CONCAT44(local_1ac0._4_4_,local_ad8);
    local_1aa8 = (undefined8 *)CONCAT44(local_1aa8._4_4_,local_ad4);
    local_1ab0 = (undefined8 *)CONCAT44(local_1ab0._4_4_,local_240);
    local_1ac8 = CONCAT44(local_1ac8._4_4_,local_abc);
    local_220 = {d 3.05176e-05};
    local_218 = 1.2f;
    local_214 = 0;
    local_20c = 0;
    local_204 = 1;
    local_203 = local_adc;
    local_201 = local_ada;
    local_200 = 0;
    local_1f8 = 0;
    local_1f0 = 1;
    local_1ef = local_ae0;
    local_1ed = local_ade;
    local_1dc = 0;
    local_1d9 = local_ae2;
    local_1db = local_ae4;
    local_1aa0 = (undefined8 *)CONCAT44(local_1aa0._4_4_,local_a44);
    local_1ad8 = CONCAT44(local_1ad8._4_4_,local_a24);
    local_1ae8 = CONCAT44(local_1ae8._4_4_,local_a20);
    local_1af8 = CONCAT44(local_1af8._4_4_,uVar31);
    local_18c = (undefined1)uVar31;
    local_189 = local_ae6;
    local_18b = local_ae8;
    local_1b00 = CONCAT44(local_1b00._4_4_,uVar11);
    local_178 = (undefined1)uVar11;
    local_175 = local_aea;
    local_177 = local_aec;
    local_164 = (undefined1)local_1b0c;
    local_161 = local_aee;
    local_163 = local_af0;
    local_1b20 = CONCAT44(local_1b20._4_4_,local_9d8);
    local_1b28 = CONCAT44(local_1b28._4_4_,local_9d4);
    local_1b30 = CONCAT44(local_1b30._4_4_,local_9d0);
    local_1a98 = CONCAT44(local_1a98._4_4_,uVar9);
    local_14c = (undefined1)uVar9;
    local_8b8[0] = 0;
    local_8a8 = 0;
    local_8b0 = 0;
    local_8a0 = 0;
    local_868 = 0;
    uStack_880 = 0;
    local_888 = 0;
    uStack_870 = 0;
    uStack_878 = 0;
    uStack_890 = 0;
    local_898 = 0;
    local_864 = 1;
    local_858 = 0;
    local_860 = 0;
    local_850 = 1;
    local_844 = 0;
    local_84c = 0;
    local_83c = 1;
    local_830 = 0;
    local_838 = 0;
    local_828 = 0;
    local_7f0 = 0;
    uStack_7f8 = 0;
    local_800 = 0;
    uStack_808 = 0;
    local_810 = 0;
    uStack_818 = 0;
    local_820 = 0;
    local_7ec = 1;
    local_7e0 = 0;
    local_7e8 = 0;
    local_7d8 = 1;
    local_7cc = 0;
    local_7d4 = 0;
    local_7c4 = 1;
    uStack_7b0 = 0;
    uStack_7b8 = 0;
    local_7b3 = 0;
    local_7c0 = 0;
    puVar6 = &local_258;
    local_1b18 = local_9e0;
    local_1b08 = local_aa8;
    local_1af0 = local_ab0;
    local_1ae0 = local_ab8;
    local_1ad0 = local_ad0;
    local_1ab8 = local_ac8;
    local_1a90 = local_9ec;
    local_1a88 = local_9f4;
    local_1a80 = local_a00;
    local_258 = local_ad8;
    local_254 = local_ad4;
    local_250 = local_ad0;
    local_248 = local_ac8;
    local_23c = local_abc;
    local_238 = local_ab8;
    local_230 = local_ab0;
    local_228 = local_aa8;
    local_1ec = uVar25;
    local_1e4 = uVar41;
    local_1d8 = uVar37;
    local_1d0 = uVar40;
    local_1c8 = uVar56;
    local_1c4 = local_a44;
    local_1c0 = uVar44;
    local_1b8 = uVar16;
    local_1b0 = uVar49;
    local_1a8 = uVar57;
    local_1a4 = local_a24;
    local_1a0 = local_a20;
    local_19c = uVar29;
    local_194 = uVar36;
    local_188 = uVar15;
    local_180 = local_a00;
    local_174 = local_9f4;
    local_16c = local_9ec;
    local_160 = local_9e0;
    local_158 = local_9d8;
    local_154 = local_9d4;
    local_150 = local_9d0;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_368 = (undefined4)local_1ac0;
      local_364 = local_1aa8._0_4_;
      local_360 = local_1ad0;
      local_358 = local_1ab8;
      local_350 = local_1ab0._0_4_;
      local_34c = (undefined4)local_1ac8;
      local_348 = local_1ae0;
      local_340 = local_1af0;
      local_338 = local_1b08;
      local_330 = uVar19;
      local_328 = 1.2f;
      local_31c = 0;
      local_324 = 0;
      local_314 = 1;
      local_313 = local_adc;
      local_311 = local_ada;
      local_308 = 0;
      local_310 = 0;
      local_300 = 1;
      local_2ff = local_ae0;
      local_2fd = local_ade;
      local_2ec = 0;
      local_2eb = local_ae4;
      local_2e9 = local_ae2;
      local_2d4 = local_1aa0._0_4_;
      local_2b4 = (undefined4)local_1ad8;
      local_2b0 = (undefined4)local_1ae8;
      local_29c = (undefined1)local_1af8;
      local_299 = local_af2;
      local_29b = local_af4;
      local_290 = local_1a80;
      local_288 = (undefined1)local_1b00;
      local_285 = local_af6;
      local_287 = local_af8;
      local_284 = local_1a88;
      local_27c = local_1a90;
      local_274 = (undefined1)local_1b0c;
      local_271 = local_afa;
      local_273 = local_afc;
      local_270 = local_1b18;
      local_268 = (undefined4)local_1b20;
      local_264 = (undefined4)local_1b28;
      local_260 = (undefined4)local_1b30;
      local_25c = (undefined1)local_1a98;
      local_2fc = uVar25;
      local_2f4 = uVar41;
      local_2e8 = uVar37;
      local_2e0 = uVar40;
      local_2d8 = uVar56;
      local_2d0 = uVar44;
      local_2c8 = uVar16;
      local_2c0 = uVar49;
      local_2b8 = uVar57;
      local_2ac = uVar29;
      local_2a4 = uVar36;
      local_298 = uVar15;
      _CGPointMake(&local_368);
      func_0x000198104610(auStack_c10,&local_368,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_c10);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_c10,0x10d);
    func_0x000198104610(&local_d20,auStack_c10,0x10d);
    iVar8 = (int)&local_d20;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      local_c5c = 0;
      local_c50 = 0;
      local_c48 = 0;
      local_c3c = 0;
      local_c34 = 0;
      uVar31 = 0;
      local_c80 = 0;
      uVar11 = 1;
      local_c78 = 0;
      uVar9 = 1;
      uVar27 = 1;
      local_c70 = 0;
      local_c6c = 0;
      local_c68 = 0;
      local_1b0c = 1;
      local_1a80 = CONCAT44(local_1a80._4_4_,1);
      local_1a88 = CONCAT44(local_1a88._4_4_,1);
      local_c28 = 0;
      local_c20 = 0;
      local_c1c = 0;
      local_c18 = 0;
      local_d20 = 0;
      local_d18 = 0;
      local_d10 = 0;
      local_d08 = 0;
      local_d00 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar38 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar30 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar41 = 0;
      uVar56 = 0;
      uVar57 = 0;
      uVar47 = 0;
      uVar50 = 0;
      local_34c = (int)local_8b8;
    }
    else {
      uVar25 = (ulong)local_d1c;
      uVar11 = (uint)local_ccc;
      local_d24 = local_ccb;
      local_d22 = local_cc9;
      uVar9 = (uint)local_cb8;
      local_d26 = local_cb5;
      local_d28 = local_cb7;
      uVar27 = (uint)local_ca4;
      local_d2a = local_ca1;
      local_d2c = local_ca3;
      uVar15 = (ulong)local_c8c;
      local_1b0c = (uint)local_c54;
      local_d2e = local_c51;
      local_d30 = local_c53;
      local_1a80 = CONCAT44(local_1a80._4_4_,(uint)local_c40);
      local_d32 = local_c3d;
      local_d34 = local_c3f;
      local_1a88 = CONCAT44(local_1a88._4_4_,(uint)local_c2c);
      local_d36 = local_c29;
      local_d38 = local_c2b;
      uVar31 = (uint)local_c14;
      uVar19 = local_cdc;
      uVar29 = local_cd4;
      uVar36 = local_cc8;
      uVar38 = local_cc0;
      uVar37 = local_cb4;
      uVar40 = local_cac;
      uVar30 = local_c64;
      uVar44 = local_cf0;
      uVar16 = local_ca0;
      uVar49 = local_c98;
      uVar41 = local_c88;
      uVar56 = local_ce8;
      uVar57 = local_ce4;
      uVar47 = local_ce0;
      uVar50 = local_c90;
      local_34c = local_d04;
    }
    local_1b08 = CONCAT44(local_1b08._4_4_,local_d20);
    local_364 = (undefined4)uVar25;
    local_1b18 = CONCAT44(local_1b18._4_4_,local_364);
    local_1b30 = CONCAT44(local_1b30._4_4_,local_d08);
    local_1b38 = CONCAT44(local_1b38._4_4_,local_34c);
    local_340 = 1;
    local_330 = CONCAT44(uVar57,uVar56);
    local_1ac0 = CONCAT44(local_1ac0._4_4_,uVar11);
    local_314 = (undefined1)uVar11;
    local_311 = local_d22;
    local_313 = local_d24;
    local_1ac8 = CONCAT44(local_1ac8._4_4_,uVar9);
    local_300 = (undefined1)uVar9;
    local_2ff = local_d28;
    local_2fd = local_d26;
    local_1ad8 = CONCAT44(local_1ad8._4_4_,uVar27);
    local_2ec = (undefined1)uVar27;
    local_2eb = local_d2c;
    local_2e9 = local_d2a;
    local_2d4 = (undefined4)uVar15;
    local_1ae8 = CONCAT44(local_1ae8._4_4_,local_2d4);
    local_1af0 = CONCAT44(local_1af0._4_4_,local_c70);
    local_1af8 = CONCAT44(local_1af8._4_4_,local_c6c);
    local_1b00 = CONCAT44(local_1b00._4_4_,local_c68);
    local_29c = (undefined1)local_1b0c;
    local_299 = local_d2e;
    local_29b = local_d30;
    local_288 = (undefined1)local_1a80;
    local_285 = local_d32;
    local_287 = local_d34;
    local_274 = (undefined1)local_1a88;
    local_271 = local_d36;
    local_273 = local_d38;
    local_1b50 = CONCAT44(local_1b50._4_4_,local_c20);
    local_1b60 = CONCAT44(local_1b60._4_4_,local_c18);
    local_1ab8 = CONCAT44(local_1ab8._4_4_,uVar31);
    local_25c = (undefined1)uVar31;
    puVar6 = &local_368;
    local_1b54 = local_c1c;
    local_1b48 = local_c28;
    local_1b40 = local_d00;
    local_1b28 = local_d10;
    local_1b20 = local_d18;
    local_1ae0 = local_c78;
    local_1ad0 = local_c80;
    local_1ab0 = (undefined8 *)local_c34;
    local_1aa8 = (undefined8 *)local_c3c;
    local_1aa0 = (undefined8 *)local_c48;
    local_1a98 = local_c50;
    local_1a90 = local_c5c;
    local_368 = local_d20;
    local_360 = local_d18;
    local_358 = local_d10;
    local_350 = local_d08;
    local_348 = local_d00;
    local_338 = uVar44;
    local_328 = uVar47;
    local_324 = uVar19;
    local_31c = uVar29;
    local_310 = uVar36;
    local_308 = uVar38;
    local_2fc = uVar37;
    local_2f4 = uVar40;
    local_2e8 = uVar16;
    local_2e0 = uVar49;
    local_2d8 = uVar50;
    local_2d0 = uVar41;
    local_2c8 = local_c80;
    local_2c0 = local_c78;
    local_2b8 = local_c70;
    local_2b4 = local_c6c;
    local_2b0 = local_c68;
    local_2ac = uVar30;
    local_2a4 = local_c5c;
    local_298 = local_c50;
    local_290 = local_c48;
    local_284 = local_c3c;
    local_27c = local_c34;
    local_270 = local_c28;
    local_268 = local_c20;
    local_264 = local_c1c;
    local_260 = local_c18;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_478 = (undefined4)local_1b08;
      local_474 = (undefined4)local_1b18;
      local_470 = local_1b20;
      local_468 = local_1b28;
      local_460 = (undefined4)local_1b30;
      local_45c = (undefined4)local_1b38;
      local_458 = local_1b40;
      local_450 = 1;
      local_424 = (undefined1)local_1ac0;
      local_423 = local_d24;
      local_421 = local_d22;
      local_410 = (undefined1)local_1ac8;
      local_40d = local_d26;
      local_40f = local_d28;
      local_3fc = (undefined1)local_1ad8;
      local_3f9 = local_d2a;
      local_3fb = local_d2c;
      local_3e4 = (undefined4)local_1ae8;
      local_3d8 = local_1ad0;
      local_3d0 = local_1ae0;
      local_3c8 = (undefined4)local_1af0;
      local_3c4 = (undefined4)local_1af8;
      local_3c0 = (undefined4)local_1b00;
      local_3b4 = local_1a90;
      local_3ac = (undefined1)local_1b0c;
      local_3a9 = local_d2e;
      local_3ab = local_d30;
      local_3a8 = local_1a98;
      local_3a0 = local_1aa0;
      local_398 = (undefined1)local_1a80;
      local_395 = local_d32;
      local_397 = local_d34;
      local_394 = local_1aa8;
      local_38c = local_1ab0;
      local_384 = (undefined1)local_1a88;
      local_381 = local_d36;
      local_383 = local_d38;
      local_380 = local_1b48;
      local_378 = (undefined4)local_1b50;
      local_374 = local_1b54;
      local_370 = (undefined4)local_1b60;
      local_36c = (undefined1)local_1ab8;
      local_448 = uVar44;
      local_440 = uVar56;
      local_43c = uVar57;
      local_438 = uVar47;
      local_434 = uVar19;
      local_42c = uVar29;
      local_420 = uVar36;
      local_418 = uVar38;
      local_40c = uVar37;
      local_404 = uVar40;
      local_3f8 = uVar16;
      local_3f0 = uVar49;
      local_3e8 = uVar50;
      local_3e0 = uVar41;
      local_3bc = uVar30;
      _CGPointMake(&local_478);
      func_0x000198104610(auStack_e48,&local_478,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_e48);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_e48,0x10d);
    func_0x000198104610(&local_f58,auStack_e48,0x10d);
    iVar8 = (int)&local_f58;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      local_e94 = 0;
      local_e88 = 0;
      local_e80 = 0;
      local_e74 = 0;
      local_e6c = 0;
      uVar31 = 0;
      local_ec0 = 0;
      uVar11 = 1;
      local_eb8 = 0;
      uVar9 = 1;
      uVar27 = 1;
      local_eb0 = 0;
      local_ea8 = 0;
      local_ea4 = 0;
      local_ea0 = 0;
      uVar45 = 1;
      local_1a80 = CONCAT44(local_1a80._4_4_,1);
      local_1a88 = CONCAT44(local_1a88._4_4_,1);
      local_e60 = 0;
      local_e58 = 0;
      local_e54 = 0;
      local_e50 = 0;
      local_f58 = 0;
      local_f50 = 0;
      local_f48 = 0;
      local_f40 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar15 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar25 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar41 = 0;
      uVar56 = 0;
      uVar57 = 0;
      uVar47 = 0;
      uVar50 = 0;
      local_45c = (int)&local_368;
    }
    else {
      uVar38 = (ulong)local_f54;
      uVar11 = (uint)local_f04;
      local_f5c = local_f03;
      local_f5a = local_f01;
      uVar9 = (uint)local_ef0;
      local_f5e = local_eed;
      local_f60 = local_eef;
      uVar27 = (uint)local_edc;
      local_f62 = local_ed9;
      local_f64 = local_edb;
      uVar30 = (ulong)local_ec4;
      uVar45 = (uint)local_e8c;
      local_f66 = local_e89;
      local_f68 = local_e8b;
      local_1a80 = CONCAT44(local_1a80._4_4_,(uint)local_e78);
      local_f6a = local_e75;
      local_f6c = local_e77;
      local_1a88 = CONCAT44(local_1a88._4_4_,(uint)local_e64);
      local_f6e = local_e61;
      local_f70 = local_e63;
      uVar31 = (uint)local_e4c;
      uVar19 = local_f14;
      uVar29 = local_f0c;
      uVar36 = local_f00;
      uVar15 = local_ef8;
      uVar37 = local_eec;
      uVar40 = local_ee4;
      uVar25 = local_e9c;
      uVar44 = local_f30;
      uVar16 = local_f28;
      uVar49 = local_ed8;
      uVar41 = local_ed0;
      uVar56 = local_f20;
      uVar57 = local_f1c;
      uVar47 = local_f18;
      uVar50 = local_ec8;
      local_45c = local_f3c;
    }
    local_474 = (undefined4)uVar38;
    local_1b20 = CONCAT44(local_1b20._4_4_,local_474);
    local_1b40 = CONCAT44(local_1b40._4_4_,local_f40);
    local_1b38 = CONCAT44(local_1b38._4_4_,local_45c);
    local_458 = 1.5708;
    local_1ac0 = CONCAT44(local_1ac0._4_4_,uVar11);
    local_424 = (undefined1)uVar11;
    local_421 = local_f5a;
    local_423 = local_f5c;
    local_1ac8 = CONCAT44(local_1ac8._4_4_,uVar9);
    local_410 = (undefined1)uVar9;
    local_40f = local_f60;
    local_40d = local_f5e;
    local_1ad8 = CONCAT44(local_1ad8._4_4_,uVar27);
    local_3fc = (undefined1)uVar27;
    local_3fb = local_f64;
    local_3f9 = local_f62;
    local_3e4 = (undefined4)uVar30;
    local_1ae8 = CONCAT44(local_1ae8._4_4_,local_3e4);
    local_1af8 = CONCAT44(local_1af8._4_4_,local_ea8);
    local_1b00 = CONCAT44(local_1b00._4_4_,local_ea4);
    local_1b08 = CONCAT44(local_1b08._4_4_,local_ea0);
    local_1b18 = CONCAT44(local_1b18._4_4_,uVar45);
    local_3ac = (undefined1)uVar45;
    local_3a9 = local_f66;
    local_3ab = local_f68;
    local_398 = (undefined1)local_1a80;
    local_395 = local_f6a;
    local_397 = local_f6c;
    local_384 = (undefined1)local_1a88;
    local_381 = local_f6e;
    local_383 = local_f70;
    local_1b50 = CONCAT44(local_1b50._4_4_,local_e58);
    local_1b60 = CONCAT44(local_1b60._4_4_,local_e50);
    local_1ab8 = CONCAT44(local_1ab8._4_4_,uVar31);
    local_36c = (undefined1)uVar31;
    puVar6 = &local_478;
    local_1b54 = local_e54;
    local_1b48 = local_e60;
    local_1b30 = local_f48;
    local_1b28 = local_f50;
    local_1b0c = local_f58;
    local_1af0 = local_eb0;
    local_1ae0 = local_eb8;
    local_1ad0 = local_ec0;
    local_1ab0 = (undefined8 *)local_e6c;
    local_1aa8 = (undefined8 *)local_e74;
    local_1aa0 = (undefined8 *)local_e80;
    local_1a98 = local_e88;
    local_1a90 = local_e94;
    local_478 = local_f58;
    local_470 = local_f50;
    local_468 = local_f48;
    local_460 = local_f40;
    local_450 = uVar44;
    local_448 = uVar16;
    local_440 = uVar56;
    local_43c = uVar57;
    local_438 = uVar47;
    local_434 = uVar19;
    local_42c = uVar29;
    local_420 = uVar36;
    local_418 = uVar15;
    local_40c = uVar37;
    local_404 = uVar40;
    local_3f8 = uVar49;
    local_3f0 = uVar41;
    local_3e8 = uVar50;
    local_3e0 = local_ec0;
    local_3d8 = local_eb8;
    local_3d0 = local_eb0;
    local_3c8 = local_ea8;
    local_3c4 = local_ea4;
    local_3c0 = local_ea0;
    local_3bc = uVar25;
    local_3b4 = local_e94;
    local_3a8 = local_e88;
    local_3a0 = local_e80;
    local_394 = local_e74;
    local_38c = local_e6c;
    local_380 = local_e60;
    local_378 = local_e58;
    local_374 = local_e54;
    local_370 = local_e50;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_588 = local_1b0c;
      local_584 = (undefined4)local_1b20;
      local_580 = local_1b28;
      local_578 = local_1b30;
      local_570 = (undefined4)local_1b40;
      local_56c = (undefined4)local_1b38;
      local_568 = 1.5708;
      local_534 = (undefined1)local_1ac0;
      local_533 = local_f5c;
      local_531 = local_f5a;
      local_520 = (undefined1)local_1ac8;
      local_51d = local_f5e;
      local_51f = local_f60;
      local_50c = (undefined1)local_1ad8;
      local_509 = local_f62;
      local_50b = local_f64;
      local_4f4 = (undefined4)local_1ae8;
      local_4f0 = local_1ad0;
      local_4e8 = local_1ae0;
      local_4e0 = local_1af0;
      local_4d8 = (undefined4)local_1af8;
      local_4d4 = (undefined4)local_1b00;
      local_4d0 = (undefined4)local_1b08;
      local_4c4 = local_1a90;
      local_4bc = (undefined1)local_1b18;
      local_4b9 = local_f66;
      local_4bb = local_f68;
      local_4b8 = local_1a98;
      local_4b0 = local_1aa0;
      local_4a8 = (undefined1)local_1a80;
      local_4a5 = local_f6a;
      local_4a7 = local_f6c;
      local_4a4 = local_1aa8;
      local_49c = local_1ab0;
      local_494 = (undefined1)local_1a88;
      local_491 = local_f6e;
      local_493 = local_f70;
      local_490 = local_1b48;
      local_488 = (undefined4)local_1b50;
      local_484 = local_1b54;
      local_480 = (undefined4)local_1b60;
      local_47c = (undefined1)local_1ab8;
      local_560 = uVar44;
      local_558 = uVar16;
      local_550 = uVar56;
      local_54c = uVar57;
      local_548 = uVar47;
      local_544 = uVar19;
      local_53c = uVar29;
      local_530 = uVar36;
      local_528 = uVar15;
      local_51c = uVar37;
      local_514 = uVar40;
      local_508 = uVar49;
      local_500 = uVar41;
      local_4f8 = uVar50;
      local_4cc = uVar25;
      _CGPointMake(&local_588);
      func_0x000198104610(auStack_1080,&local_588,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1080);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_1080,0x10d);
    func_0x000198104610(&local_1190,auStack_1080,0x10d);
    iVar8 = (int)&local_1190;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      local_10cc = 0;
      local_10c0 = 0;
      local_10b8 = 0;
      local_10ac = 0;
      local_10a4 = 0;
      uVar9 = 0;
      local_10e8 = 0;
      uVar31 = 1;
      local_10e0 = 0;
      uVar11 = 1;
      uVar27 = 1;
      local_10dc = 0;
      local_10d8 = 0;
      uVar45 = 1;
      local_1a80 = CONCAT44(local_1a80._4_4_,1);
      local_1a88 = CONCAT44(local_1a88._4_4_,1);
      local_1098 = 0;
      local_1090 = 0;
      local_108c = 0;
      local_1088 = 0;
      local_1190 = 0;
      local_1188 = 0;
      local_1180 = 0;
      local_1178 = 0;
      local_1170 = 0;
      local_1168 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar38 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar41 = 0;
      uVar51 = 0;
      uVar56 = 0;
      uVar57 = 0;
      uVar47 = 0;
      uVar50 = 0;
      local_56c = (int)&local_478;
    }
    else {
      uVar15 = (ulong)local_118c;
      uVar31 = (uint)local_113c;
      local_1194 = local_113b;
      local_1192 = local_1139;
      uVar11 = (uint)local_1128;
      local_1196 = local_1125;
      local_1198 = local_1127;
      uVar27 = (uint)local_1114;
      local_119a = local_1111;
      local_119c = local_1113;
      uVar25 = (ulong)local_10fc;
      uVar45 = (uint)local_10c4;
      local_119e = local_10c1;
      local_11a0 = local_10c3;
      local_1a80 = CONCAT44(local_1a80._4_4_,(uint)local_10b0);
      local_11a2 = local_10ad;
      local_11a4 = local_10af;
      local_1a88 = CONCAT44(local_1a88._4_4_,(uint)local_109c);
      local_11a6 = local_1099;
      local_11a8 = local_109b;
      uVar9 = (uint)local_1084;
      uVar19 = local_114c;
      uVar29 = local_1144;
      uVar36 = local_1138;
      uVar37 = local_1130;
      uVar40 = local_1124;
      uVar38 = local_111c;
      uVar44 = local_10d4;
      uVar16 = local_1110;
      uVar49 = local_1108;
      uVar41 = local_10f8;
      uVar51 = local_10f0;
      uVar56 = local_1158;
      uVar57 = local_1154;
      uVar47 = local_1150;
      uVar50 = local_1100;
      local_56c = local_1174;
    }
    local_1b00 = CONCAT44(local_1b00._4_4_,local_1190);
    local_1b0c = (uint)uVar15;
    local_1b28 = CONCAT44(local_1b28._4_4_,local_1178);
    local_1b30 = CONCAT44(local_1b30._4_4_,local_56c);
    local_558 = 0.5;
    local_1ac0 = CONCAT44(local_1ac0._4_4_,uVar31);
    local_534 = (undefined1)uVar31;
    local_531 = local_1192;
    local_533 = local_1194;
    local_1ac8 = CONCAT44(local_1ac8._4_4_,uVar11);
    local_520 = (undefined1)uVar11;
    local_51f = local_1198;
    local_51d = local_1196;
    local_1ad8 = CONCAT44(local_1ad8._4_4_,uVar27);
    local_50c = (undefined1)uVar27;
    local_50b = local_119c;
    local_509 = local_119a;
    local_4f4 = (undefined4)uVar25;
    local_1ae8 = CONCAT44(local_1ae8._4_4_,local_4f4);
    local_1ae0 = CONCAT44(local_1ae0._4_4_,local_10e0);
    local_1af0 = CONCAT44(local_1af0._4_4_,local_10dc);
    local_1af8 = CONCAT44(local_1af8._4_4_,local_10d8);
    local_1b08 = CONCAT44(local_1b08._4_4_,uVar45);
    local_4bc = (undefined1)uVar45;
    local_4b9 = local_119e;
    local_4bb = local_11a0;
    local_4a8 = (undefined1)local_1a80;
    local_4a5 = local_11a2;
    local_4a7 = local_11a4;
    local_494 = (undefined1)local_1a88;
    local_491 = local_11a6;
    local_493 = local_11a8;
    local_1b50 = CONCAT44(local_1b50._4_4_,local_1090);
    local_1b60 = CONCAT44(local_1b60._4_4_,local_1088);
    local_1ab8 = CONCAT44(local_1ab8._4_4_,uVar9);
    local_47c = (undefined1)uVar9;
    puVar6 = &local_588;
    local_1b54 = local_108c;
    local_1b48 = local_1098;
    local_1b40 = local_1168;
    local_1b38 = local_1170;
    local_1b20 = local_1180;
    local_1b18 = local_1188;
    local_1ad0 = local_10e8;
    local_1ab0 = (undefined8 *)local_10a4;
    local_1aa8 = (undefined8 *)local_10ac;
    local_1aa0 = (undefined8 *)local_10b8;
    local_1a98 = local_10c0;
    local_1a90 = local_10cc;
    local_588 = local_1190;
    local_584 = local_1b0c;
    local_580 = local_1188;
    local_578 = local_1180;
    local_570 = local_1178;
    local_568 = local_1170;
    local_560 = local_1168;
    local_550 = uVar56;
    local_54c = uVar57;
    local_548 = uVar47;
    local_544 = uVar19;
    local_53c = uVar29;
    local_530 = uVar36;
    local_528 = uVar37;
    local_51c = uVar40;
    local_514 = uVar38;
    local_508 = uVar16;
    local_500 = uVar49;
    local_4f8 = uVar50;
    local_4f0 = uVar41;
    local_4e8 = uVar51;
    local_4e0 = local_10e8;
    local_4d8 = local_10e0;
    local_4d4 = local_10dc;
    local_4d0 = local_10d8;
    local_4cc = uVar44;
    local_4c4 = local_10cc;
    local_4b8 = local_10c0;
    local_4b0 = local_10b8;
    local_4a4 = local_10ac;
    local_49c = local_10a4;
    local_490 = local_1098;
    local_488 = local_1090;
    local_484 = local_108c;
    local_480 = local_1088;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_698 = (undefined4)local_1b00;
      local_694 = local_1b0c;
      local_690 = local_1b18;
      local_688 = local_1b20;
      local_680 = (undefined4)local_1b28;
      local_67c = (undefined4)local_1b30;
      local_678 = local_1b38;
      local_670 = local_1b40;
      local_668 = 0.5;
      local_644 = (undefined1)local_1ac0;
      local_643 = local_1194;
      local_641 = local_1192;
      local_630 = (undefined1)local_1ac8;
      local_62d = local_1196;
      local_62f = local_1198;
      local_61c = (undefined1)local_1ad8;
      local_619 = local_119a;
      local_61b = local_119c;
      local_604 = (undefined4)local_1ae8;
      local_5f0 = local_1ad0;
      local_5e8 = (undefined4)local_1ae0;
      local_5e4 = (undefined4)local_1af0;
      local_5e0 = (undefined4)local_1af8;
      local_5d4 = local_1a90;
      local_5cc = (undefined1)local_1b08;
      local_5c9 = local_119e;
      local_5cb = local_11a0;
      local_5c8 = local_1a98;
      local_5c0 = local_1aa0;
      local_5b8 = (undefined1)local_1a80;
      local_5b5 = local_11a2;
      local_5b7 = local_11a4;
      local_5b4 = local_1aa8;
      local_5ac = local_1ab0;
      local_5a4 = (undefined1)local_1a88;
      local_5a1 = local_11a6;
      local_5a3 = local_11a8;
      local_5a0 = local_1b48;
      local_598 = (undefined4)local_1b50;
      local_594 = local_1b54;
      local_590 = (undefined4)local_1b60;
      local_58c = (undefined1)local_1ab8;
      local_660 = uVar56;
      local_65c = uVar57;
      local_658 = uVar47;
      local_654 = uVar19;
      local_64c = uVar29;
      local_640 = uVar36;
      local_638 = uVar37;
      local_62c = uVar40;
      local_624 = uVar38;
      local_618 = uVar16;
      local_610 = uVar49;
      local_608 = uVar50;
      local_600 = uVar41;
      local_5f8 = uVar51;
      local_5dc = uVar44;
      _CGPointMake(&local_698);
      func_0x000198104610(auStack_12b8,&local_698,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_12b8);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_12b8,0x10d);
    func_0x000198104610(&local_13c8,auStack_12b8,0x10d);
    iVar8 = (int)&local_13c8;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      local_1384 = 0;
      local_137c = 0;
      local_1370 = 0;
      local_1368 = 0;
      local_135c = 0;
      local_1354 = 0;
      local_698 = 0;
      uVar42 = 1;
      local_13c0 = 0;
      uVar33 = 1;
      local_1b0c = 1;
      local_13b8 = 0;
      local_13b0 = 0;
      local_13a8 = 0;
      local_13a0 = 0;
      local_1398 = 0;
      local_1390 = 0;
      local_138c = 0;
      local_1388 = 0;
      uVar9 = 1;
      uVar27 = 1;
      uVar45 = 1;
      local_1348 = 0;
      local_1340 = 0;
      local_1338 = 0;
      local_1330 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar15 = 0;
      uVar40 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar56 = 0;
      uVar57 = 0;
      uVar47 = 0;
      uVar50 = 0;
      uVar48 = 0;
      uVar46 = 0;
      uVar23 = 0;
    }
    else {
      uVar9 = (uint)local_1374;
      local_13ca = local_1371;
      local_13cc = local_1373;
      uVar27 = (uint)local_1360;
      local_13ce = local_135d;
      local_13d0 = local_135f;
      uVar45 = (uint)local_134c;
      local_13d2 = local_1349;
      local_13d4 = local_134b;
      uVar38 = (ulong)local_1334;
      local_1b0c = (uint)local_12fc;
      local_13d6 = local_12f9;
      local_13d8 = local_12fb;
      uVar33 = (uint)local_12e8;
      local_13da = local_12e5;
      local_13dc = local_12e7;
      uVar42 = (uint)local_12d4;
      local_13de = local_12d1;
      local_13e0 = local_12d3;
      uVar19 = local_12f8;
      uVar29 = local_12e4;
      uVar36 = local_12dc;
      uVar37 = local_1304;
      uVar15 = local_130c;
      uVar40 = local_12f0;
      uVar44 = local_12d0;
      uVar16 = local_1320;
      uVar56 = local_1318;
      uVar31 = local_13c4;
      uVar11 = local_13ac;
      local_698 = local_13c8;
      uVar57 = local_1314;
      uVar47 = local_1310;
      uVar50 = local_12c8;
      uVar48 = local_12c4;
      uVar46 = local_12c0;
      uVar23 = local_12bc;
    }
    local_1ad0 = CONCAT44(local_1ad0._4_4_,local_698);
    local_1ab0 = (undefined8 *)CONCAT44(local_1ab0._4_4_,uVar31);
    local_1ac8 = CONCAT44(local_1ac8._4_4_,local_13b0);
    local_1ad8 = CONCAT44(local_1ad8._4_4_,uVar11);
    local_1af8 = CONCAT44(local_1af8._4_4_,local_1390);
    local_1b00 = CONCAT44(local_1b00._4_4_,local_138c);
    local_1b08 = CONCAT44(local_1b08._4_4_,local_1388);
    local_1b28 = CONCAT44(local_1b28._4_4_,uVar9);
    local_644 = (undefined1)uVar9;
    local_641 = local_13ca;
    local_643 = local_13cc;
    local_1b30 = CONCAT44(local_1b30._4_4_,uVar27);
    local_630 = (undefined1)uVar27;
    local_62f = local_13d0;
    local_62d = local_13ce;
    local_1b38 = CONCAT44(local_1b38._4_4_,uVar45);
    local_61c = (undefined1)uVar45;
    local_61b = local_13d4;
    local_619 = local_13d2;
    local_1b50 = CONCAT44(local_1b50._4_4_,local_1338);
    local_1b54 = (undefined4)uVar38;
    local_5f8 = 1;
    local_5cc = (undefined1)local_1b0c;
    local_5c9 = local_13d6;
    local_5cb = local_13d8;
    local_1b20 = CONCAT44(local_1b20._4_4_,uVar33);
    local_5b8 = (undefined1)uVar33;
    local_5b5 = local_13da;
    local_5b7 = local_13dc;
    local_1b18 = CONCAT44(local_1b18._4_4_,uVar42);
    local_5a4 = (undefined1)uVar42;
    local_5a1 = local_13de;
    local_5a3 = local_13e0;
    puVar6 = &local_698;
    local_1b60 = local_1330;
    local_1b48 = local_1340;
    local_1b40 = local_1348;
    local_1af0 = local_1398;
    local_1ae8 = local_13a0;
    local_1ae0 = local_13a8;
    local_1ac0 = local_13c0;
    local_1ab8 = local_13b8;
    local_1aa8 = (undefined8 *)local_1354;
    local_1aa0 = (undefined8 *)local_1370;
    local_1a98 = local_135c;
    local_1a90 = local_137c;
    local_1a88 = local_1368;
    local_1a80 = local_1384;
    local_694 = uVar31;
    local_690 = local_13c0;
    local_688 = local_13b8;
    local_680 = local_13b0;
    local_67c = uVar11;
    local_678 = local_13a8;
    local_670 = local_13a0;
    local_668 = local_1398;
    local_660 = local_1390;
    local_65c = local_138c;
    local_658 = local_1388;
    local_654 = local_1384;
    local_64c = local_137c;
    local_640 = local_1370;
    local_638 = local_1368;
    local_62c = local_135c;
    local_624 = local_1354;
    local_618 = local_1348;
    local_610 = local_1340;
    local_608 = local_1338;
    local_604 = local_1b54;
    local_600 = local_1330;
    local_5f0 = uVar16;
    local_5e8 = uVar56;
    local_5e4 = uVar57;
    local_5e0 = uVar47;
    local_5dc = uVar15;
    local_5d4 = uVar37;
    local_5c8 = uVar19;
    local_5c0 = uVar40;
    local_5b4 = uVar29;
    local_5ac = uVar36;
    local_5a0 = uVar44;
    local_598 = uVar50;
    local_594 = uVar48;
    local_590 = uVar46;
    local_58c = uVar23;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_7a8 = (undefined4)local_1ad0;
      local_7a4 = local_1ab0._0_4_;
      local_7a0 = local_1ac0;
      local_798 = local_1ab8;
      local_790 = (undefined4)local_1ac8;
      local_78c = (undefined4)local_1ad8;
      local_788 = local_1ae0;
      local_780 = local_1ae8;
      local_778 = local_1af0;
      local_770 = (undefined4)local_1af8;
      local_76c = (undefined4)local_1b00;
      local_768 = (undefined4)local_1b08;
      local_764 = local_1a80;
      local_75c = local_1a90;
      local_754 = (undefined1)local_1b28;
      local_753 = local_13cc;
      local_751 = local_13ca;
      local_750 = local_1aa0;
      local_748 = local_1a88;
      local_740 = (undefined1)local_1b30;
      local_73d = local_13ce;
      local_73f = local_13d0;
      local_73c = local_1a98;
      local_734 = local_1aa8;
      local_72c = (undefined1)local_1b38;
      local_729 = local_13d2;
      local_72b = local_13d4;
      local_728 = local_1b40;
      local_720 = local_1b48;
      local_718 = (undefined4)local_1b50;
      local_714 = local_1b54;
      local_710 = local_1b60;
      local_708 = 1;
      local_6dc = (undefined1)local_1b0c;
      local_6d9 = local_13d6;
      local_6db = local_13d8;
      local_6c8 = (undefined1)local_1b20;
      local_6c5 = local_13da;
      local_6c7 = local_13dc;
      local_6b4 = (undefined1)local_1b18;
      local_6b1 = local_13de;
      local_6b3 = local_13e0;
      local_700 = uVar16;
      local_6f8 = uVar56;
      local_6f4 = uVar57;
      local_6f0 = uVar47;
      local_6ec = uVar15;
      local_6e4 = uVar37;
      local_6d8 = uVar19;
      local_6d0 = uVar40;
      local_6c4 = uVar29;
      local_6bc = uVar36;
      local_6b0 = uVar44;
      local_6a8 = uVar50;
      local_6a4 = uVar48;
      local_6a0 = uVar46;
      local_69c = uVar23;
      _CGPointMake(&local_7a8);
      func_0x000198104610(auStack_14f0,&local_7a8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_14f0);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_14f0,0x10d);
    func_0x000198104610(&local_1600,auStack_14f0,0x10d);
    iVar8 = (int)&local_1600;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      uVar9 = 0;
      local_15bc = 0;
      local_15b4 = 0;
      local_15a8 = 0;
      local_15a0 = 0;
      local_1594 = 0;
      local_158c = 0;
      local_1560 = 0;
      uVar34 = 1;
      local_7a8 = 0;
      uVar42 = 1;
      uVar27 = 1;
      local_15f8 = 0;
      local_15f0 = 0;
      local_15e8 = 0;
      local_15e0 = 0;
      local_15d8 = 0;
      local_15d0 = 0;
      local_15c8 = 0;
      local_15c4 = 0;
      local_15c0 = 0;
      uVar45 = 1;
      uVar33 = 1;
      uVar32 = 1;
      local_1580 = 0;
      local_1578 = 0;
      local_1570 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar56 = 0;
      local_15fc = uVar31;
      uVar57 = 0;
      uVar47 = 0;
      uVar50 = 0;
      uVar48 = 0;
      uVar46 = 0;
    }
    else {
      uVar45 = (uint)local_15ac;
      local_1602 = local_15a9;
      local_1604 = local_15ab;
      uVar33 = (uint)local_1598;
      local_1606 = local_1595;
      local_1608 = local_1597;
      uVar32 = (uint)local_1584;
      local_160a = local_1581;
      local_160c = local_1583;
      uVar15 = (ulong)local_156c;
      uVar27 = (uint)local_1534;
      local_160e = local_1531;
      local_1610 = local_1533;
      uVar42 = (uint)local_1520;
      local_1612 = local_151d;
      local_1614 = local_151f;
      uVar34 = (uint)local_150c;
      local_1616 = local_1509;
      local_1618 = local_150b;
      uVar9 = (uint)local_14f4;
      uVar19 = local_1530;
      uVar29 = local_151c;
      uVar36 = local_1514;
      uVar37 = local_153c;
      uVar40 = local_1544;
      uVar44 = local_1528;
      uVar16 = local_1508;
      uVar49 = local_1558;
      uVar56 = local_1550;
      uVar11 = local_15e4;
      local_7a8 = local_1600;
      uVar57 = local_154c;
      uVar47 = local_1548;
      uVar50 = local_1500;
      uVar48 = local_14fc;
      uVar46 = local_14f8;
    }
    local_1ab0 = (undefined8 *)CONCAT44(local_1ab0._4_4_,local_7a8);
    local_1aa8 = (undefined8 *)CONCAT44(local_1aa8._4_4_,local_15fc);
    local_1ac0 = CONCAT44(local_1ac0._4_4_,local_15e8);
    local_1ad0 = CONCAT44(local_1ad0._4_4_,uVar11);
    local_1af8 = CONCAT44(local_1af8._4_4_,local_15c8);
    local_1b00 = CONCAT44(local_1b00._4_4_,local_15c4);
    local_1b28 = CONCAT44(local_1b28._4_4_,uVar45);
    local_754 = (undefined1)uVar45;
    local_751 = local_1602;
    local_753 = local_1604;
    local_1b30 = CONCAT44(local_1b30._4_4_,uVar33);
    local_740 = (undefined1)uVar33;
    local_73f = local_1608;
    local_73d = local_1606;
    local_1b38 = CONCAT44(local_1b38._4_4_,uVar32);
    local_72c = (undefined1)uVar32;
    local_72b = local_160c;
    local_729 = local_160a;
    local_714 = (undefined4)uVar15;
    local_1b50 = CONCAT44(local_1b50._4_4_,local_714);
    local_710 = 3.49066;
    uVar23 = (undefined1)uVar27;
    local_6d9 = local_160e;
    local_6db = local_1610;
    local_1b18 = CONCAT44(local_1b18._4_4_,uVar42);
    local_6c8 = (undefined1)uVar42;
    local_6c5 = local_1612;
    local_6c7 = local_1614;
    local_1b20 = CONCAT44(local_1b20._4_4_,uVar34);
    local_6b4 = (undefined1)uVar34;
    local_6b1 = local_1616;
    local_6b3 = local_1618;
    puVar6 = &local_7a8;
    local_1b54 = local_1570;
    local_1b48 = local_1578;
    local_1b40 = local_1580;
    local_1b0c = local_15c0;
    local_1b08 = local_15a0;
    local_1af0 = local_15d0;
    local_1ae8 = local_15d8;
    local_1ae0 = local_15e0;
    local_1ad8 = local_1560;
    local_1ac8 = local_15f0;
    local_1ab8 = local_15f8;
    local_1aa0 = (undefined8 *)local_158c;
    local_1a98 = local_15a8;
    local_1a90 = local_1594;
    local_1a88 = local_15b4;
    local_1a80 = local_15bc;
    local_7a4 = local_15fc;
    local_7a0 = local_15f8;
    local_798 = local_15f0;
    local_790 = local_15e8;
    local_78c = uVar11;
    local_788 = local_15e0;
    local_780 = local_15d8;
    local_778 = local_15d0;
    local_770 = local_15c8;
    local_76c = local_15c4;
    local_768 = local_15c0;
    local_764 = local_15bc;
    local_75c = local_15b4;
    local_750 = local_15a8;
    local_748 = local_15a0;
    local_73c = local_1594;
    local_734 = local_158c;
    local_728 = local_1580;
    local_720 = local_1578;
    local_718 = local_1570;
    local_708 = local_1560;
    local_700 = uVar49;
    local_6f8 = uVar56;
    local_6f4 = uVar57;
    local_6f0 = uVar47;
    local_6ec = uVar40;
    local_6e4 = uVar37;
    local_6dc = uVar23;
    local_6d8 = uVar19;
    local_6d0 = uVar44;
    local_6c4 = uVar29;
    local_6bc = uVar36;
    local_6b0 = uVar16;
    local_6a8 = uVar50;
    local_6a4 = uVar48;
    local_6a0 = uVar46;
    local_69c = (char)uVar9;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_9c8 = local_1ab0._0_4_;
      local_9c4 = local_1aa8._0_4_;
      local_9c0 = local_1ab8;
      local_9b8 = local_1ac8;
      local_9b0 = (undefined4)local_1ac0;
      local_9ac = (undefined4)local_1ad0;
      local_9a8 = local_1ae0;
      local_9a0 = local_1ae8;
      local_998 = local_1af0;
      local_990 = (undefined4)local_1af8;
      local_98c = (undefined4)local_1b00;
      local_988 = local_1b0c;
      local_984 = local_1a80;
      local_97c = local_1a88;
      local_974 = (undefined1)local_1b28;
      local_973 = local_1604;
      local_971 = local_1602;
      local_970 = local_1a98;
      local_968 = local_1b08;
      local_960 = (undefined1)local_1b30;
      local_95d = local_1606;
      local_95f = local_1608;
      local_95c = local_1a90;
      local_954 = local_1aa0;
      local_94c = (undefined1)local_1b38;
      local_949 = local_160a;
      local_94b = local_160c;
      local_948 = local_1b40;
      local_940 = local_1b48;
      local_938 = local_1b54;
      local_934 = (undefined4)local_1b50;
      local_930 = 3.49066;
      local_928 = local_1ad8;
      local_8f9 = local_160e;
      local_8fb = local_1610;
      local_8e8 = (undefined1)local_1b18;
      local_8e5 = local_1612;
      local_8e7 = local_1614;
      local_8d4 = (undefined1)local_1b20;
      local_8d1 = local_1616;
      local_8d3 = local_1618;
      local_920 = uVar49;
      local_918 = uVar56;
      local_914 = uVar57;
      local_910 = uVar47;
      local_90c = uVar40;
      local_904 = uVar37;
      local_8fc = uVar23;
      local_8f8 = uVar19;
      local_8f0 = uVar44;
      local_8e4 = uVar29;
      local_8dc = uVar36;
      local_8d0 = uVar16;
      local_8c8 = uVar50;
      local_8c4 = uVar48;
      local_8c0 = uVar46;
      local_8bc = (char)uVar9;
      _CGPointMake(&local_9c8);
      func_0x000198104610(auStack_1728,&local_9c8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1728);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_1728,0x10d);
    func_0x000198104610(&local_1838,auStack_1728,0x10d);
    iVar8 = (int)&local_1838;
    FUN_195e7d8c0();
    if (iVar8 == 1) {
      local_17f4 = 0;
      local_17ec = 0;
      local_17e0 = 0;
      local_17d8 = 0;
      local_17cc = 0;
      local_17c4 = 0;
      local_9c8 = 0;
      local_1830 = 0;
      uVar33 = 1;
      local_1820 = 0;
      local_1818 = 0;
      local_1810 = 0;
      local_1808 = 0;
      local_1800 = 0;
      local_17fc = 0;
      local_17f8 = 0;
      local_1b0c = 1;
      uVar31 = 1;
      uVar45 = 1;
      local_17b8 = 0;
      local_17b0 = 0;
      local_17a8 = 0;
      local_17a0 = 0;
      local_1798 = 0;
      uVar19 = 0;
      uVar29 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar44 = 0;
      uVar16 = 0;
      uVar49 = 0;
      uVar56 = 0;
      uVar57 = 0;
      uVar23 = 1;
      uVar26 = 1;
      local_1834 = uVar11;
      local_181c = uVar27;
      local_934 = uVar9;
      uVar47 = 0;
      uVar50 = 0;
      uVar48 = 0;
      uVar46 = 0;
      uVar10 = 0;
    }
    else {
      local_1b0c = (uint)local_17e4;
      local_183a = local_17e1;
      local_183c = local_17e3;
      uVar31 = (uint)local_17d0;
      local_183e = local_17cd;
      local_1840 = local_17cf;
      uVar45 = (uint)local_17bc;
      local_1842 = local_17b9;
      local_1844 = local_17bb;
      local_1846 = local_1769;
      local_1848 = local_176b;
      local_184a = local_1755;
      local_184c = local_1757;
      uVar33 = (uint)local_1744;
      local_184e = local_1741;
      local_1850 = local_1743;
      uVar19 = local_1768;
      uVar29 = local_174c;
      uVar36 = local_1754;
      uVar37 = local_1774;
      uVar40 = local_177c;
      uVar44 = local_1760;
      uVar16 = local_1740;
      uVar49 = local_1828;
      uVar56 = local_1788;
      uVar57 = local_1784;
      uVar23 = local_176c;
      uVar26 = local_1758;
      local_9c8 = local_1838;
      local_934 = local_17a4;
      uVar47 = local_1780;
      uVar50 = local_1738;
      uVar48 = local_1734;
      uVar46 = local_1730;
      uVar10 = local_172c;
    }
    local_1aa8 = (undefined8 *)CONCAT44(local_1aa8._4_4_,local_9c8);
    local_1aa0 = (undefined8 *)CONCAT44(local_1aa0._4_4_,local_1834);
    local_1ab0 = (undefined8 *)CONCAT44(local_1ab0._4_4_,local_1820);
    local_1ac0 = CONCAT44(local_1ac0._4_4_,local_181c);
    local_1ae0 = CONCAT44(local_1ae0._4_4_,local_1800);
    local_1ae8 = CONCAT44(local_1ae8._4_4_,local_17fc);
    local_1af0 = CONCAT44(local_1af0._4_4_,local_17f8);
    local_974 = (undefined1)local_1b0c;
    local_971 = local_183a;
    local_973 = local_183c;
    local_1b18 = CONCAT44(local_1b18._4_4_,uVar31);
    local_960 = (undefined1)uVar31;
    local_95f = local_1840;
    local_95d = local_183e;
    local_1b20 = CONCAT44(local_1b20._4_4_,uVar45);
    local_94c = (undefined1)uVar45;
    local_94b = local_1844;
    local_949 = local_1842;
    local_1b38 = CONCAT44(local_1b38._4_4_,local_17a8);
    local_1b40 = CONCAT44(local_1b40._4_4_,local_934);
    local_920 = 0.25;
    local_8f9 = local_1846;
    local_8fb = local_1848;
    local_8e5 = local_184a;
    local_8e7 = local_184c;
    local_1b08 = CONCAT44(local_1b08._4_4_,uVar33);
    local_8d4 = (undefined1)uVar33;
    local_8d1 = local_184e;
    local_8d3 = local_1850;
    puVar6 = &local_9c8;
    local_1b50 = local_1798;
    local_1b48 = local_17a0;
    local_1b30 = local_17b0;
    local_1b28 = local_17b8;
    local_1b00 = local_17f4;
    local_1af8 = local_17d8;
    local_1ad8 = local_1808;
    local_1ad0 = local_1810;
    local_1ac8 = local_1818;
    local_1ab8 = local_1830;
    local_1a98 = local_17c4;
    local_1a90 = local_17ec;
    local_1a88 = local_17cc;
    local_1a80 = local_17e0;
    local_9c4 = local_1834;
    local_9c0 = local_1830;
    local_9b8 = uVar49;
    local_9b0 = local_1820;
    local_9ac = local_181c;
    local_9a8 = local_1818;
    local_9a0 = local_1810;
    local_998 = local_1808;
    local_990 = local_1800;
    local_98c = local_17fc;
    local_988 = local_17f8;
    local_984 = local_17f4;
    local_97c = local_17ec;
    local_970 = local_17e0;
    local_968 = local_17d8;
    local_95c = local_17cc;
    local_954 = local_17c4;
    local_948 = local_17b8;
    local_940 = local_17b0;
    local_938 = local_17a8;
    local_930 = local_17a0;
    local_928 = local_1798;
    local_918 = uVar56;
    local_914 = uVar57;
    local_910 = uVar47;
    local_90c = uVar40;
    local_904 = uVar37;
    local_8fc = uVar23;
    local_8f8 = uVar19;
    local_8f0 = uVar44;
    local_8e8 = uVar26;
    local_8e4 = uVar36;
    local_8dc = uVar29;
    local_8d0 = uVar16;
    local_8c8 = uVar50;
    local_8c4 = uVar48;
    local_8c0 = uVar46;
    local_8bc = uVar10;
    FUN_195ed8068(puVar6,local_8b8);
    if (((ulong)puVar6 & 1) == 0) {
      local_1a70 = local_1aa8._0_4_;
      local_1a6c = local_1aa0._0_4_;
      local_1a68 = local_1ab8;
      local_1a58 = local_1ab0._0_4_;
      local_1a54 = (undefined4)local_1ac0;
      local_1a50 = local_1ac8;
      uStack_1a48 = local_1ad0;
      local_1a40 = local_1ad8;
      local_1a38 = (undefined4)local_1ae0;
      local_1a34 = (undefined4)local_1ae8;
      local_1a30 = (undefined4)local_1af0;
      local_1a2c = local_1b00;
      local_1a24 = local_1a90;
      local_1a1c = (undefined1)local_1b0c;
      local_1a1b = local_183c;
      local_1a19 = local_183a;
      local_1a18 = local_1a80;
      uStack_1a10 = local_1af8;
      local_1a08 = (undefined1)local_1b18;
      local_1a05 = local_183e;
      local_1a07 = local_1840;
      local_1a04 = local_1a88;
      local_19fc = local_1a98;
      local_19f4 = (undefined1)local_1b20;
      local_19f1 = local_1842;
      local_19f3 = local_1844;
      local_19f0 = local_1b28;
      uStack_19e8 = local_1b30;
      local_19e0 = (undefined4)local_1b38;
      local_19dc = (undefined4)local_1b40;
      local_19d8 = local_1b48;
      uStack_19d0 = local_1b50;
      local_19c8 = 0.25;
      local_19a1 = local_1846;
      local_19a3 = local_1848;
      local_198d = local_184a;
      local_198f = local_184c;
      local_197c = (undefined1)local_1b08;
      local_1979 = local_184e;
      local_197b = local_1850;
      uStack_1a60 = uVar49;
      local_19c0 = uVar56;
      local_19bc = uVar57;
      local_19b8 = uVar47;
      local_19b4 = uVar40;
      local_19ac = uVar37;
      local_19a4 = uVar23;
      local_19a0 = uVar19;
      uStack_1998 = uVar44;
      local_1990 = uVar26;
      local_198c = uVar36;
      local_1984 = uVar29;
      local_1978 = uVar16;
      local_1970 = uVar50;
      local_196c = uVar48;
      local_1968 = uVar46;
      local_1964 = uVar10;
      _CGPointMake(&local_1a70);
      func_0x000198104610(auStack_1960,&local_1a70,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_1960);
    }
    func_0x000198104610(local_1a78 + 0x1e8,auStack_1960,0x10d);
  }
  return;
}


//######## ControlLoupeRecipe.anon.LoupeSpecModifier (spec) 0x195f02850
// === 195f03b64 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f03b64(ulong param_1)
{
  <refraction.normalizedInnerAmount> = -0.3;
  <refraction.normalizedInnerHeight> = 0.095;
  <+0x640> = 0.200713;
  uVar1 = {d 0.012};
  <+0x628> = {d 0.235294};
  <+0x620> = uVar1;
  uVar1 = {d 0};
  <+0x638> = {d -0.135};
  <+0x630> = uVar1;
  <+0x648> = {d 0.0078125};
  uVar2 = param_1;
  FUN_195ed53f0();
  if ((uVar2 & 1) != 0) {
    <ringShadow.opacity> = 0.07f;
    <ringShadow.blurRadius> = 4;
    <ringShadow.verticalOffset> = 12;
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <shadow.opacity> = 0.02f;
    <+0x38> = 0;
    <+0x30> = 0;
    <+0x48> = 0;
    <+0x40> = 0;
    <+0x50> = 0;
    <+0x608> = 0.25;
  }
  return;
}


//######## ControlLoupeRecipe.anon.LoupeParametersModifier (params) 0x195f02854
// === 195f03c3c params

/* WARNING: Removing unreachable block (ram,0x000195f03cac) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f03c3c(long param_1,long param_2)
{
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar25 = (long)&local_280 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar5 + 0x18);
  lVar5 = lVar25;
  (**(code **)(lVar9 + 0x68))(lVar25,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  param_2 = param_2 + iVar2;
  func_0x0001980ff320(param_2,lVar25,lVar4,lVar5);
  local_268 = CONCAT44(local_268._4_4_,(int)param_2);
  (**(code **)(lVar9 + 8))(lVar25,lVar4);
  pfVar12 = &DAT_1eda46304;
  lVar5 = DAT_1eda3b1e0;
  if (<faceEffects?nil> == '\x01') {
    pfVar26 = &DAT_1eda46354;
    pfVar24 = &DAT_1eda46350;
    puVar22 = &DAT_1eda4634c;
    puVar7 = &DAT_1eda46344;
    puVar28 = &DAT_1eda4633c;
    puVar8 = &DAT_1eda46334;
    puVar27 = &DAT_1eda46314;
    local_260 = (ulong *)&DAT_1eda4630c;
    puVar17 = &DAT_1eda46324;
    puVar19 = &DAT_1eda4631c;
    plVar21 = &DAT_1eda4632c;
    if (DAT_1eda3b1e0 != -1) {
      local_278 = &DAT_1eda46324;
      local_270 = &DAT_1eda4631c;
      local_280 = &DAT_1eda4632c;
      local_260 = (ulong *)&DAT_1eda4630c;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      lVar5 = -1;
      puVar17 = local_278;
      puVar19 = local_270;
      plVar21 = local_280;
    }
  }
  else {
    pfVar12 = (float *)(<faceEffects.opacity>);
    local_260 = (ulong *)(<faceEffects.ycc.white>);
    puVar27 = (undefined8 *)(<faceEffects.ycc.normalFill.r>);
    puVar8 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
    puVar28 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
    puVar7 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
    puVar22 = (uint *)(<faceEffects.ycc.burnFill?nil>);
    pfVar24 = (float *)(<faceEffects.maxLuminance>);
    pfVar26 = (float *)(<faceEffects.maxLuminanceSDR>);
    puVar17 = (undefined8 *)(<faceEffects.ycc.normalFill?nil>);
    puVar19 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
    plVar21 = (long *)(<faceEffects.ycc.dodgeFill.g>);
  }
  fVar30 = *pfVar26;
  fVar34 = *pfVar24;
  uVar1 = *puVar22;
  uVar16 = *puVar7;
  uVar18 = *puVar8;
  uVar29 = *puVar17;
  uVar23 = *local_260;
  uVar3 = 0.06f;
  if ((local_268 & 1) == 0) {
    uVar3 = 0;
  }
  fVar35 = *pfVar12;
  puVar7 = (undefined8 *)*plVar21;
  puVar8 = (undefined8 *)*puVar19;
  plVar20 = (long *)*puVar27;
  local_260 = (ulong *)*puVar28;
  if (lVar5 != -1) {
    local_280 = (long *)*puVar27;
    local_278 = (undefined8 *)*puVar19;
    local_270 = (undefined8 *)*plVar21;
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    puVar7 = local_270;
    puVar8 = local_278;
    plVar20 = local_280;
  }
  fVar32 = DAT_1eda46354;
  fVar33 = DAT_1eda46350;
  fVar31 = DAT_1eda46304;
  uStack_d8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  local_e0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  uStack_c8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_d0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  local_c0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_b8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  uStack_b3 = DAT_1eda46344._1_3_;
  uStack_b0 = (undefined5)
              (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_))
              >> 0x18);
  uStack_e8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_f0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  puVar27 = (undefined8 *)(ulong)uVar1;
  if (fVar35 == DAT_1eda46304) {
    local_104 = local_260;
    local_f4 = (undefined1)uVar1;
    puVar6 = &local_138;
    local_270 = (undefined8 *)(ulong)uVar1;
    local_138 = uVar3;
    local_134 = uVar23;
    local_12c = plVar20;
    local_124 = puVar8;
    local_11c = uVar29;
    local_114 = puVar7;
    local_10c = uVar18;
    local_fc = uVar16;
    FUN_195ed7db4(puVar6,&local_f0);
    puVar27 = local_270;
    if (((((ulong)puVar6 & 1) == 0) || (fVar34 != fVar33)) || (fVar30 != fVar32))
    goto LAB_195f03f44;
    uVar10 = 0;
    uVar23 = 0;
    plVar20 = (long *)0x0;
    puVar8 = (undefined8 *)0x0;
    uVar29 = 0;
    puVar7 = (undefined8 *)0x0;
    uVar18 = 0;
    local_260 = (ulong *)0x0;
    uVar16 = 0;
    uVar15 = 0;
    bVar11 = true;
    fVar30 = 0.0;
    uVar13 = 1;
  }
  else {
LAB_195f03f44:
    bVar11 = false;
    uVar13 = 0;
    uVar10 = CONCAT44(uVar3,fVar35);
    uVar15 = (ulong)puVar27 | (ulong)(uint)fVar34 << 0x20;
  }
  <faceEffects.opacity> = uVar10;
  <faceEffects.ycc.white> = uVar23;
  *(long **)(<faceEffects.ycc.normalFill.r>) = plVar20;
  *(undefined8 **)(<faceEffects.ycc.normalFill.b>) = puVar8;
  <faceEffects.ycc.normalFill?nil> = uVar29;
  *(undefined8 **)(<faceEffects.ycc.dodgeFill.g>) = puVar7;
  <faceEffects.ycc.dodgeFill.a> = uVar18;
  *(ulong **)(<faceEffects.ycc.burnFill.r>) = local_260;
  <faceEffects.ycc.burnFill.b> = uVar16;
  <faceEffects.ycc.burnFill?nil> = uVar15;
  <faceEffects.maxLuminanceSDR> = fVar30;
  <faceEffects?nil> = uVar13;
  if (bVar11) {
    uVar15 = (ulong)DAT_1eda4634c;
    local_260 = (ulong *)CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
    uVar16 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    puVar7 = (undefined8 *)CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
    uVar18 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
    puVar8 = (undefined8 *)CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
    uVar29 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
    plVar20 = (long *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
    uVar23 = (ulong)DAT_1eda46310;
    puVar27 = (undefined8 *)(ulong)DAT_1eda46308;
    fVar30 = DAT_1eda46354;
    fVar32 = DAT_1eda46354;
    fVar31 = DAT_1eda46304;
    fVar34 = DAT_1eda46304;
    fVar33 = DAT_1eda46350;
    fVar35 = DAT_1eda46350;
  }
  else {
    puVar27 = (undefined8 *)(uVar10 >> 0x20);
    uVar23 = uVar23 >> 0x20;
    fVar34 = (float)uVar10;
    fVar35 = (float)(uVar15 >> 0x20);
  }
  uVar1 = 1f;
  if ((local_268 & 1) == 0) {
    uVar1 = 1.03f;
  }
  uStack_158 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_160 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_150 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_148 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_143 = DAT_1eda46344._1_3_;
  uStack_140 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_178 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_180 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_168 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_170 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar34 == fVar31) {
    local_1c8 = SUB84(puVar27,0);
    local_268 = (ulong)uVar1 | uVar23 << 0x20;
    local_194 = local_260;
    local_184 = (undefined1)uVar15;
    puVar6 = &local_1c8;
    local_270 = puVar27;
    local_1c4 = local_268;
    local_1bc = plVar20;
    local_1b4 = puVar8;
    local_1ac = uVar29;
    local_1a4 = puVar7;
    local_19c = uVar18;
    local_18c = uVar16;
    FUN_195ed7db4(puVar6,&local_180);
    puVar27 = local_270;
    if (((((ulong)puVar6 & 1) == 0) || (fVar35 != fVar33)) || (fVar30 != fVar32))
    goto LAB_195f04118;
    uVar23 = 0;
    local_268 = 0;
    plVar20 = (long *)0x0;
    puVar8 = (undefined8 *)0x0;
    uVar29 = 0;
    puVar7 = (undefined8 *)0x0;
    uVar18 = 0;
    local_260 = (ulong *)0x0;
    uVar16 = 0;
    uVar10 = 0;
    bVar11 = true;
    fVar30 = 0.0;
    uVar13 = 1;
  }
  else {
    local_268 = (ulong)uVar1 | uVar23 << 0x20;
LAB_195f04118:
    bVar11 = false;
    uVar13 = 0;
    uVar23 = (ulong)(uint)fVar34 | (long)puVar27 << 0x20;
    uVar10 = uVar15 & 0xffffffff | (ulong)(uint)fVar35 << 0x20;
  }
  <faceEffects.opacity> = uVar23;
  <faceEffects.ycc.white> = local_268;
  *(long **)(<faceEffects.ycc.normalFill.r>) = plVar20;
  *(undefined8 **)(<faceEffects.ycc.normalFill.b>) = puVar8;
  <faceEffects.ycc.normalFill?nil> = uVar29;
  *(undefined8 **)(<faceEffects.ycc.dodgeFill.g>) = puVar7;
  <faceEffects.ycc.dodgeFill.a> = uVar18;
  *(ulong **)(<faceEffects.ycc.burnFill.r>) = local_260;
  <faceEffects.ycc.burnFill.b> = uVar16;
  <faceEffects.ycc.burnFill?nil> = uVar10;
  <faceEffects.maxLuminanceSDR> = fVar30;
  <faceEffects?nil> = uVar13;
  if (bVar11) {
    uVar10 = (ulong)DAT_1eda4634c;
    local_260 = (ulong *)CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
    uVar16 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    puVar7 = (undefined8 *)CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
    uVar18 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
    puVar8 = (undefined8 *)CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
    uVar29 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
    plVar20 = (long *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
    uVar15 = CONCAT44(DAT_1eda46310,DAT_1eda4630c);
    local_268 = (ulong)DAT_1eda46308;
    fVar30 = DAT_1eda46354;
    fVar32 = DAT_1eda46354;
    fVar31 = DAT_1eda46304;
    fVar33 = DAT_1eda46350;
    fVar34 = DAT_1eda46350;
  }
  else {
    fVar34 = (float)(uVar10 >> 0x20);
    uVar15 = local_268;
    local_268 = uVar23 >> 0x20;
  }
  uStack_1e8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_1f0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_1e0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_1d8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_1d3 = DAT_1eda46344._1_3_;
  uStack_1d0 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_208 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_210 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_1f8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_200 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar31 == 1.0) {
    local_258 = (undefined4)local_268;
    local_224 = local_260;
    local_214 = (undefined1)uVar10;
    puVar6 = &local_258;
    local_254 = uVar15;
    local_24c = plVar20;
    local_244 = puVar8;
    local_23c = uVar29;
    local_234 = puVar7;
    local_22c = uVar18;
    local_21c = uVar16;
    FUN_195ed7db4(puVar6,&local_210);
    if (((((ulong)puVar6 & 1) != 0) && (fVar34 == fVar33)) && (fVar30 == fVar32)) {
      uVar23 = 0;
      uVar16 = 0;
      local_260 = (ulong *)0x0;
      uVar18 = 0;
      puVar7 = (undefined8 *)0x0;
      uVar29 = 0;
      puVar8 = (undefined8 *)0x0;
      plVar20 = (long *)0x0;
      uVar15 = 0;
      uVar14 = 0;
      fVar30 = 0.0;
      uVar13 = 1;
      goto LAB_195f04290;
    }
  }
  uVar13 = 0;
  uVar14 = local_268 << 0x20 | 1f;
  uVar23 = uVar10 & 0xffffffff | (ulong)(uint)fVar34 << 0x20;
LAB_195f04290:
  <faceEffects.opacity> = uVar14;
  <faceEffects.ycc.white> = uVar15;
  *(long **)(<faceEffects.ycc.normalFill.r>) = plVar20;
  *(undefined8 **)(<faceEffects.ycc.normalFill.b>) = puVar8;
  <faceEffects.ycc.normalFill?nil> = uVar29;
  *(undefined8 **)(<faceEffects.ycc.dodgeFill.g>) = puVar7;
  <faceEffects.ycc.dodgeFill.a> = uVar18;
  *(ulong **)(<faceEffects.ycc.burnFill.r>) = local_260;
  <faceEffects.ycc.burnFill.b> = uVar16;
  <faceEffects.ycc.burnFill?nil> = uVar23;
  <faceEffects.maxLuminanceSDR> = fVar30;
  <faceEffects?nil> = uVar13;
  return;
}


//######## ControlCenterRecipe.anon.IdiomModifier (spec) 0x195f0a2bc
// === 195f0b388 spec

void FUN_195f0b388(long param_1,long param_2)
{
  lVar3 = 0;
  FUN_195f3c68c();
  bVar1 = *(byte *)(param_2 + *(int *)(lVar3 + 0x3c));
  if (bVar1 < 3) {
    if (bVar1 == 1) {
      if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
        pcVar2 = (code *)SoftwareBreakpoint(0xc471,0x195f0b600);
        (*pcVar2)();
      }
      FUN_195f0ad5c(param_1,param_2);
      return;
    }
    if (bVar1 == 2) {
      FUN_195eda468(<blur.blurRadius>,<+0x170>,
                    <+0x178>,<+0x180>,
                    <+0x188>,<+0x190>,
                    <+0x191>);
      <blur.blurRadius> = 0.5f;
      <+0x178> = 0;
      <+0x170> = 0;
      <+0x188> = 0;
      <+0x180> = 0;
      <+0x190> = 0;
      <faceEffect.ycc.black> = 0.2f;
      <faceEffect.ycc.white> = {d 0.225};
      <faceEffect.ycc.normalFill.b> = 0;
      <faceEffect.ycc.normalFill.r> = 0;
      <faceEffect.ycc.normalFill?nil> = 1;
      <faceEffect.ycc.dodgeFill.b> = 0;
      <faceEffect.ycc.dodgeFill.r> = 0;
      <faceEffect.ycc.dodgeFill?nil> = 1;
      <faceEffect.ycc.burnFill.b> = 0;
      <faceEffect.ycc.burnFill.r> = 0;
      <faceEffect.ycc.burnFill?nil> = 1;
      <refraction.normalizedInnerHeight> = 0.116667;
      <refraction.normalizedInnerAmount> = -1;
      <refraction.normalizedOuterHeight> = 0.116667;
      <refraction.normalizedOuterAmount> = 0.173333;
      <refraction.outerOpacity> = 0.3f;
      <blur.distances.0.v> = 0.466667f;
      <blur.distances.0.kind> = 1;
      <darkSpecular.colorBias> = -0.35;
    }
  }
  else {
    if (bVar1 == 3) {
      if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
        pcVar2 = (code *)SoftwareBreakpoint(0xc471,0x195f0b5b8);
        (*pcVar2)();
      }
      FUN_195f0ab90(param_1,param_2);
      return;
    }
    if (bVar1 == 4) {
      if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
        pcVar2 = (code *)SoftwareBreakpoint(0xc471,0x195f0b5dc);
        (*pcVar2)();
      }
      FUN_195f0afdc(param_1,param_2);
      return;
    }
    if (bVar1 == 5) {
      FUN_195eda468(<blur.blurRadius>,<+0x170>,
                    <+0x178>,<+0x180>,
                    <+0x188>,<+0x190>,
                    <+0x191>);
      <blur.blurRadius> = 0.5f;
      <+0x178> = 0;
      <+0x170> = 0;
      <+0x188> = 0;
      <+0x180> = 0;
      <+0x190> = 0;
      <faceEffect.ycc.black> = 0.2f;
      <faceEffect.ycc.white> = {d 0.225};
      <faceEffect.ycc.normalFill.b> = 0;
      <faceEffect.ycc.normalFill.r> = 0;
      <faceEffect.ycc.normalFill?nil> = 1;
      <faceEffect.ycc.dodgeFill.b> = 0;
      <faceEffect.ycc.dodgeFill.r> = 0;
      <faceEffect.ycc.dodgeFill?nil> = 1;
      <faceEffect.ycc.burnFill.b> = 0;
      <faceEffect.ycc.burnFill.r> = 0;
      <faceEffect.ycc.burnFill?nil> = 1;
      <refraction.normalizedOuterHeight> = 0.116667;
      <refraction.normalizedOuterAmount> = 0.173333;
      <refraction.outerOpacity> = 0.3f;
      <blur.distances.0.v> = 0.466667f;
      <blur.distances.0.kind> = 1;
      <darkSpecular.colorBias> = -0.35;
      <refraction.normalizedInnerHeight> = 0.4427;
      <refraction.normalizedInnerAmount> = -1.8595;
    }
  }
  return;
}


//######## ControlCenterRecipe.anon.RTExtra (spec) 0x195f0a2c0
// === 195f0cdb4 spec

/* WARNING: Removing unreachable block (ram,0x000195f0ce08) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0cdb4(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x000198120110();
  lVar5 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar5 + 0x40));
  puVar6 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  FUN_195f3c68c();
  if (*(char *)(param_2 + *(int *)(lVar3 + 0x3c)) == '\x01') {
    iVar1 = *(int *)(lVar3 + 0x18);
    (**(code **)(lVar5 + 0x68))(puVar6,*_DAT_1e017dd58,lVar2);
    puVar4 = &DAT_1eda3a8e0;
    FUN_195f0cf6c(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
    param_2 = param_2 + iVar1;
    func_0x0001980ff320(param_2,puVar6,lVar2,puVar4);
    (**(code **)(lVar5 + 8))(puVar6,lVar2);
    uVar7 = {f -0.25, -0.11} ^
            ({f -0.25, -0.11} ^ {f 0.05, 0.1}) &
            CONCAT44(-(uint)((int)param_2 << 0x1f < 0),-(uint)((int)param_2 << 0x1f < 0));
    uVar8 = <faceEffect.ycc.black>;
    <faceEffect.ycc.black> =
         CONCAT44((float)((ulong)uVar8 >> 0x20) + (float)(uVar7 >> 0x20),(float)uVar8 + (float)uVar7
                 );
  }
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = 10f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  return;
}


//######## ControlCenterRecipe.anon.MacICExtra (spec) 0x195f0a2c4
// === 195f0a2c4 spec

/* WARNING: Removing unreachable block (ram,0x000195f0a318) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0a2c4(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar8 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar7 + 0x68))(puVar8,*_DAT_1e017dd58,lVar3);
  puVar5 = &DAT_1eda3a8e0;
  FUN_195f0cf6c(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,puVar8,lVar3,puVar5);
  (**(code **)(lVar7 + 8))(puVar8,lVar3);
  bVar2 = (uVar6 & 1) == 0;
  lVar3 = 0x2a8;
  if (bVar2) {
    lVar3 = 0x2a4;
  }
  fVar9 = 0.55;
  if (bVar2) {
    fVar9 = -0.2;
  }
  *(float *)(param_1 + lVar3) = *(float *)(param_1 + lVar3) + fVar9;
  return;
}


//######## ControlCenterRecipe.anon.PhonePadIC (spec) 0x195f0a444
// === 195f0a444 spec

void FUN_195f0a444(long param_1)
{
  <faceEffect.ycc.saturation> = 0.8f;
  <faceEffect.ycc.black> = <faceEffect.ycc.black> + 0.2;
  return;
}


//######## ControlCenterRecipe.FallbackModifier (params) 0x195f0a4ac
// === 195f0b604 params

/* WARNING: Removing unreachable block (ram,0x000195f0b6f0) */
/* WARNING: Removing unreachable block (ram,0x000195f0b674) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0b604(long param_1,long param_2)
{
  undefined1 auVar2 [16];
  undefined1 auVar3 [16];
  undefined1 auVar43 [16];
  undefined1 auStack_600 [8];
  lVar6 = 0;
  local_580 = param_1;
  func_0x000198120110();
  local_598 = *(long *)(lVar6 + -8);
  local_590 = lVar6;
  (*_DAT_1e2125200)(*(undefined8 *)(local_598 + 0x40));
  lVar6 = 0;
  local_5a0 = auStack_600 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  func_0x0001981217d0();
  lVar13 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar13 + 0x40));
  lVar31 = (long)(auStack_600 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0)) -
           (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195ed0900();
  uVar8 = (ulong)*(uint3 *)(param_2 + *(int *)(lVar7 + 0x20));
  local_5a8 = lVar7;
  local_588 = param_2;
  FUN_195e5f470(uVar8,0x10014);
  if ((uVar8 & 1) == 0) {
    if (*(char *)(local_580 + 0xd4) == '\x01') {
      local_a4 = 0;
      uVar36 = 0;
      uVar38 = 0;
      uVar35 = 0;
      uVar37 = 0;
      local_c8 = 6.0;
      uVar39 = 0;
      uVar41 = 0;
      uVar42 = 0;
      uVar40 = 0;
    }
    else {
      local_c8 = 6.0;
      if (6.0 < *(float *)(local_580 + 0xac)) {
        local_c8 = *(float *)(local_580 + 0xac);
      }
      uVar36 = (uint)((ulong)*(undefined8 *)(local_580 + 0xac) >> 0x20);
      auVar2 = *(undefined1 (*) [16])(local_580 + 0xbc);
      auVar43._4_4_ = 0;
      auVar43._0_4_ = uVar36;
      auVar43._8_4_ = (int)((ulong)*(undefined8 *)(local_580 + 0xb4) >> 0x20);
      auVar43._12_4_ = 0;
      auVar43 = NEON_ext(auVar43,auVar2,8,1);
      uVar38 = (undefined4)*(undefined8 *)(local_580 + 0xb4);
      uVar35 = auVar43._0_4_;
      uVar37 = auVar43._8_4_;
      uVar39 = auVar2._4_4_;
      uVar42 = auVar2._12_4_;
      uVar41 = auVar2._8_4_;
      uVar40 = (undefined4)*(undefined8 *)(local_580 + 0xcc);
      local_a4 = (undefined4)((ulong)*(undefined8 *)(local_580 + 0xcc) >> 0x20);
    }
    uStack_bc = CONCAT44(uVar37,uVar35);
    local_c4 = CONCAT44(uVar38,uVar36);
    uStack_ac = CONCAT44(uVar40,uVar42);
    local_b4 = CONCAT44(uVar41,uVar39);
    FUN_195ed0ce8(&local_c8);
  }
  (**(code **)(lVar13 + 0x68))(lVar31,*_DAT_1e01830d0,lVar6);
  fVar47 = 1.0;
  uVar35 = 1f;
  uVar37 = 1f;
  uVar40 = 1f;
  func_0x0001981218c0(lVar31);
  if (DAT_1eda3b1e0 != -1) {
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
  }
  fVar44 = DAT_1eda46354;
  fVar45 = DAT_1eda46350;
  fVar46 = DAT_1eda46304;
  uVar27 = CONCAT44(uVar37,uVar35);
  uVar34 = CONCAT44(extraout_s3,uVar40);
  uStack_f8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_100 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  uStack_e8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_f0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_e0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_d8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_d3 = DAT_1eda46344._1_3_;
  uStack_d0 = (undefined5)
              (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_))
              >> 0x18);
  uStack_108 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_110 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  if (DAT_1eda46304 == 1.0) {
    local_158 = {d 0.000292969};
    local_150 = 1.4f;
    uStack_134 = 0;
    local_13c = 0;
    local_12c = 0x100000000;
    uStack_11c = 0;
    local_124 = 0;
    bVar5 = true;
    local_114 = 1;
    puVar9 = &local_158;
    local_14c = uVar27;
    local_144 = uVar34;
    FUN_195ed7db4(puVar9,&local_110);
    if (((((ulong)puVar9 & 1) == 0) || (fVar45 != 1.0)) || (fVar44 != 1.0)) goto LAB_195f0b924;
    uVar14 = 0;
    uVar19 = 0;
    uVar27 = 0;
    uVar34 = 0;
    uVar25 = 0;
    uVar28 = 0;
    fVar47 = 0.0;
    uVar17 = 1;
    uVar30 = 0;
    uVar21 = 0;
  }
  else {
LAB_195f0b924:
    bVar5 = false;
    uVar17 = 0;
    uVar28 = 0.0078125;
    uVar25 = 0x100000000;
    uVar19 = 0.075;
    uVar14 = (f 1, f 0.15);
    uVar30 = {f 1, 0.15};
    uVar21 = {d 0.075};
  }
  local_5f0 = (float *)(local_580 + 0x118);
  *(undefined8 *)(local_580 + 0x118) = uVar21;
  *(undefined8 *)(local_580 + 0x110) = uVar30;
  puStack_5b0 = (ulong *)(local_580 + 0x120);
  local_5b8 = (undefined8 *)(local_580 + 0x128);
  *(undefined8 *)(local_580 + 0x120) = uVar27;
  *(undefined8 *)(local_580 + 0x128) = uVar34;
  puStack_5c0 = (undefined8 *)(local_580 + 0x130);
  *(undefined8 *)(local_580 + 0x138) = 0;
  *(undefined8 *)(local_580 + 0x130) = 0;
  local_5c8 = (undefined8 *)(local_580 + 0x138);
  local_5d0 = (undefined8 *)(local_580 + 0x140);
  *(undefined8 *)(local_580 + 0x140) = uVar25;
  local_5d8 = (undefined8 *)(local_580 + 0x148);
  local_5e0 = (undefined8 *)(local_580 + 0x150);
  local_5e8 = (undefined4 *)(local_580 + 0x158);
  *(undefined8 *)(local_580 + 0x150) = 0;
  *local_5d8 = 0;
  *(ulong *)(local_580 + 0x158) = uVar28;
  *(undefined1 *)(local_580 + 0x164) = uVar17;
  *(float *)(local_580 + 0x160) = fVar47;
  if ((uVar8 & 1) != 0) {
    if (bVar5) {
      uVar8 = (ulong)DAT_1eda46308;
      uVar19 = CONCAT44(DAT_1eda46310,DAT_1eda4630c);
      uVar27 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      uVar34 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar30 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      uVar21 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      uVar25 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar26 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar32 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar28 = (ulong)DAT_1eda4634c;
      fVar47 = DAT_1eda46354;
      fVar44 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar48 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
    }
    else {
      uVar32 = 0;
      uVar26 = 0;
      uVar21 = 0;
      uVar30 = 0;
      uVar8 = uVar14 >> 0x20;
      fVar48 = (float)uVar14;
    }
    uStack_198 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_1a0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_188 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    local_190 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    uStack_178 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_180 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    local_170 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_168 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    uStack_163 = DAT_1eda46344._1_3_;
    uStack_160 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    if (fVar48 == fVar46) {
      local_1e8 = (undefined4)uVar8;
      local_1a4 = (undefined1)uVar28;
      puVar10 = &local_1e8;
      local_5f8 = uVar19;
      local_1e4 = uVar19;
      local_1dc = uVar27;
      local_1d4 = uVar34;
      local_1cc = uVar30;
      local_1c4 = uVar21;
      local_1bc = uVar25;
      local_1b4 = uVar26;
      local_1ac = uVar32;
      FUN_195ed7db4(puVar10,&local_1a0);
      uVar19 = local_5f8;
      if (((((ulong)puVar10 & 1) == 0) || (fVar45 != 0.8)) || (fVar47 != fVar44))
      goto LAB_195f0bb10;
      uVar14 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar25 = 0;
      uVar21 = 0;
      uVar30 = 0;
      uVar34 = 0;
      uVar27 = 0;
      uVar19 = 0;
      uVar8 = 0;
      fVar47 = 0.0;
      bVar5 = true;
      uVar17 = 1;
    }
    else {
LAB_195f0bb10:
      bVar5 = false;
      uVar17 = 0;
      uVar8 = (ulong)(uint)fVar48 | uVar8 << 0x20;
      uVar14 = uVar28 & 0xffffffff | 0.000878906;
    }
    *(ulong *)(local_580 + 0x110) = uVar8;
    *(ulong *)(local_580 + 0x118) = uVar19;
    *(undefined8 *)(local_580 + 0x120) = uVar27;
    *(undefined8 *)(local_580 + 0x128) = uVar34;
    *(undefined8 *)(local_580 + 0x130) = uVar30;
    *(undefined8 *)(local_580 + 0x138) = uVar21;
    *(undefined8 *)(local_580 + 0x140) = uVar25;
    *(undefined8 *)(local_580 + 0x148) = uVar26;
    *(undefined8 *)(local_580 + 0x150) = uVar32;
    *(ulong *)(local_580 + 0x158) = uVar14;
    *(float *)(local_580 + 0x160) = fVar47;
    *(undefined1 *)(local_580 + 0x164) = uVar17;
    if (bVar5) {
      uVar28 = (ulong)DAT_1eda46308;
      uVar19 = CONCAT44(DAT_1eda46310,DAT_1eda4630c);
      uVar27 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      uVar34 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar30 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      uVar21 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      uVar25 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar26 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar32 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar14 = (ulong)DAT_1eda4634c;
      fVar44 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar47 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
      fVar48 = DAT_1eda46350;
    }
    else {
      uVar28 = uVar8 >> 0x20;
      fVar47 = (float)uVar8;
      fVar48 = (float)(uVar14 >> 0x20);
    }
    uStack_228 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_230 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_218 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    local_220 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    uStack_208 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_210 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    local_200 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_1f8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    uStack_1f3 = DAT_1eda46344._1_3_;
    uStack_1f0 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    if (fVar47 == fVar46) {
      local_278 = (undefined4)uVar28;
      local_234 = (undefined1)uVar14;
      puVar10 = &local_278;
      local_5f8 = uVar19;
      local_274 = uVar19;
      local_26c = uVar27;
      local_264 = uVar34;
      local_25c = uVar30;
      local_254 = uVar21;
      local_24c = uVar25;
      local_244 = uVar26;
      local_23c = uVar32;
      FUN_195ed7db4(puVar10,&local_230);
      uVar19 = local_5f8;
      if (((((ulong)puVar10 & 1) == 0) || (fVar48 != fVar45)) || (fVar44 != 0.8))
      goto LAB_195f0bc84;
      uVar35 = 0;
      uVar8 = 0;
      uVar32 = 0;
      uVar26 = 0;
      uVar25 = 0;
      uVar21 = 0;
      uVar30 = 0;
      uVar34 = 0;
      uVar27 = 0;
      uVar19 = 0;
      uVar28 = 0;
      uVar17 = 1;
    }
    else {
LAB_195f0bc84:
      uVar17 = 0;
      uVar28 = (ulong)(uint)fVar47 | uVar28 << 0x20;
      uVar8 = uVar14 & 0xffffffff | (ulong)(uint)fVar48 << 0x20;
      uVar35 = 0.8f;
    }
    *(ulong *)(local_580 + 0x110) = uVar28;
    *(ulong *)(local_580 + 0x118) = uVar19;
    *(undefined8 *)(local_580 + 0x120) = uVar27;
    *(undefined8 *)(local_580 + 0x128) = uVar34;
    *(undefined8 *)(local_580 + 0x130) = uVar30;
    *(undefined8 *)(local_580 + 0x138) = uVar21;
    *(undefined8 *)(local_580 + 0x140) = uVar25;
    *(undefined8 *)(local_580 + 0x148) = uVar26;
    *(undefined8 *)(local_580 + 0x150) = uVar32;
    *(ulong *)(local_580 + 0x158) = uVar8;
    *(undefined4 *)(local_580 + 0x160) = uVar35;
    *(undefined1 *)(local_580 + 0x164) = uVar17;
  }
  lVar6 = local_580;
  uVar8 = local_588;
  puVar10 = _DAT_1e017dd58;
  lVar7 = *(long *)(local_588 + (long)*(int *)(local_5a8 + 0x14));
  if (((uint)lVar7 >> 4 & 1) != 0) {
    if (*(char *)(local_580 + 0xd4) == '\x01') {
      local_27c = 0;
      local_29c = 0;
      uStack_294 = 0;
      uVar37 = 0;
      uVar40 = 0;
      uVar38 = 0;
      uVar35 = 0;
    }
    else {
      uVar36 = (uint)((ulong)*(undefined8 *)(local_580 + 0xac) >> 0x20);
      uVar40 = (undefined4)*(undefined8 *)(local_580 + 0xc4);
      uVar38 = (undefined4)((ulong)*(undefined8 *)(local_580 + 0xc4) >> 0x20);
      auVar2._4_4_ = 0;
      auVar2._0_4_ = uVar36;
      auVar2._8_4_ = (int)((ulong)*(undefined8 *)(local_580 + 0xb4) >> 0x20);
      auVar2._12_4_ = 0;
      auVar3._12_4_ = uVar38;
      auVar3._0_12_ = *(undefined1 (*) [12])(local_580 + 0xbc);
      auVar43 = NEON_ext(auVar2,auVar3,8,1);
      local_29c = CONCAT44((int)*(undefined8 *)(local_580 + 0xb4),uVar36);
      uStack_294 = CONCAT44(auVar43._8_4_,auVar43._0_4_);
      uVar37 = (undefined4)((ulong)*(undefined8 *)*(undefined1 (*) [12])(local_580 + 0xbc) >> 0x20);
      uVar35 = (undefined4)*(undefined8 *)(local_580 + 0xcc);
      local_27c = (undefined4)((ulong)*(undefined8 *)(local_580 + 0xcc) >> 0x20);
    }
    uStack_284 = CONCAT44(uVar35,uVar38);
    local_28c = CONCAT44(uVar40,uVar37);
    local_2a0 = 20f;
    local_5a8 = lVar7;
    FUN_195ed0ce8(&local_2a0);
    lVar31 = 0;
    FUN_195f3c68c();
    lVar13 = local_590;
    lVar7 = local_598;
    puVar4 = local_5a0;
    iVar1 = *(int *)(lVar31 + 0x18);
    (**(code **)(local_598 + 0x68))(local_5a0,*puVar10,local_590);
    puVar9 = &DAT_1eda3a8e0;
    FUN_195f0cf6c(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
    uVar8 = uVar8 + (long)iVar1;
    func_0x0001980ff320(uVar8,puVar4,lVar13,puVar9);
    (**(code **)(lVar7 + 8))(puVar4,lVar13);
    bVar5 = *(char *)(lVar6 + 0x164) != '\x01';
    fVar47 = DAT_1eda46354;
    if ((uVar8 & 1) == 0) {
      if (bVar5) {
        puVar16 = (undefined4 *)(local_580 + 0x114);
        fVar47 = *(float *)(local_580 + 0x160);
        fVar49 = *(float *)(local_580 + 0x15c);
        puVar10 = (undefined4 *)(local_580 + 0x11c);
        fVar48 = *(float *)(local_580 + 0x110);
        puVar18 = puStack_5b0;
        puVar9 = local_5b8;
        puVar11 = puStack_5c0;
        puVar20 = local_5c8;
        puVar22 = local_5d0;
        puVar23 = local_5d8;
        puVar24 = local_5e0;
        puVar12 = local_5e8;
      }
      else {
        puVar10 = &DAT_1eda46310;
        puVar16 = &DAT_1eda46308;
        puVar18 = &DAT_1eda46314;
        puVar9 = &DAT_1eda4631c;
        puVar11 = &DAT_1eda46324;
        puVar20 = &DAT_1eda4632c;
        puVar22 = &DAT_1eda46334;
        puVar23 = &DAT_1eda4633c;
        puVar24 = &DAT_1eda46344;
        puVar12 = &DAT_1eda4634c;
        fVar44 = DAT_1eda46354;
        fVar46 = DAT_1eda46304;
        fVar48 = DAT_1eda46304;
        fVar45 = DAT_1eda46350;
        fVar49 = DAT_1eda46350;
      }
      uVar35 = *puVar12;
      uVar26 = *puVar24;
      uVar21 = *puVar23;
      uVar30 = *puVar22;
      uVar25 = *puVar20;
      uVar34 = *puVar11;
      uVar27 = *puVar9;
      uVar19 = *puVar18;
      uVar37 = *puVar16;
      uStack_2c8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
      local_2d0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
      uStack_2c0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
      uStack_2b8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
      local_2b3 = DAT_1eda46344._1_3_;
      uStack_2b0 = (undefined5)
                   (CONCAT17((undefined1)DAT_1eda4634c,
                             CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
      uStack_2e8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
      local_2f0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
      uStack_2d8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
      uStack_2e0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
      uVar8 = CONCAT44(*puVar10,0x6666) | 0.648438f;
      if (fVar48 == fVar46) {
        local_2f4 = (undefined1)uVar35;
        puVar10 = &local_338;
        local_5f8 = uVar8;
        local_338 = uVar37;
        local_334 = uVar8;
        local_32c = uVar19;
        local_324 = uVar27;
        local_31c = uVar34;
        local_314 = uVar25;
        local_30c = uVar30;
        local_304 = uVar21;
        local_2fc = uVar26;
        FUN_195ed7db4(puVar10,&local_2f0);
        uVar8 = local_5f8;
        if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
        goto LAB_195f0c2d8;
        uVar28 = 0;
        uVar8 = 0;
        uVar19 = 0;
        uVar27 = 0;
        uVar34 = 0;
        uVar25 = 0;
        uVar30 = 0;
        uVar21 = 0;
        uVar26 = 0;
        uVar14 = 0;
        bVar5 = true;
        fVar47 = 0.0;
        uVar17 = 1;
      }
      else {
LAB_195f0c2d8:
        bVar5 = false;
        uVar17 = 0;
        uVar28 = CONCAT44(uVar37,fVar48);
        uVar14 = CONCAT44(fVar49,uVar35);
      }
      *(ulong *)(local_580 + 0x110) = uVar28;
      *(ulong *)(local_580 + 0x118) = uVar8;
      *(ulong *)(local_580 + 0x120) = uVar19;
      *(undefined8 *)(local_580 + 0x128) = uVar27;
      *(undefined8 *)(local_580 + 0x130) = uVar34;
      *(undefined8 *)(local_580 + 0x138) = uVar25;
      *(undefined8 *)(local_580 + 0x140) = uVar30;
      *(undefined8 *)(local_580 + 0x148) = uVar21;
      *(undefined8 *)(local_580 + 0x150) = uVar26;
      *(ulong *)(local_580 + 0x158) = uVar14;
      *(float *)(local_580 + 0x160) = fVar47;
      *(undefined1 *)(local_580 + 0x164) = uVar17;
      if (bVar5) {
        uVar14 = (ulong)DAT_1eda4634c;
        uVar21 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
        uVar26 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
        uVar25 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
        uVar30 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
        uVar27 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
        uVar34 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
        uVar19 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
        uVar29 = (ulong)DAT_1eda46308;
        uVar8 = (ulong)DAT_1eda4630c;
        fVar44 = DAT_1eda46354;
        fVar47 = DAT_1eda46354;
        fVar46 = DAT_1eda46304;
        fVar48 = DAT_1eda46304;
        fVar45 = DAT_1eda46350;
        fVar49 = DAT_1eda46350;
      }
      else {
        uVar29 = uVar28 >> 0x20;
        fVar48 = (float)uVar28;
        fVar49 = (float)(uVar14 >> 0x20);
      }
      uStack_378 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
      local_380 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
      uStack_368 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
      local_370 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
      uStack_358 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
      local_360 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
      local_350 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
      uStack_348 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
      uStack_343 = DAT_1eda46344._1_3_;
      uStack_340 = (undefined5)
                   (CONCAT17((undefined1)DAT_1eda4634c,
                             CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
      if (fVar48 != fVar46) {
LAB_195f0c614:
        uVar28 = uVar8 & 0xffffffff | 0.00273437;
        uVar8 = (ulong)(uint)fVar48 | uVar29 << 0x20;
        goto LAB_195f0c660;
      }
      local_3c8 = (undefined4)uVar29;
      local_3c4 = uVar8 & 0xffffffff | 0.00273437;
      local_384 = (undefined1)uVar14;
      puVar10 = &local_3c8;
      local_5f8 = uVar19;
      local_3bc = uVar19;
      local_3b4 = uVar27;
      local_3ac = uVar34;
      local_3a4 = uVar25;
      local_39c = uVar30;
      local_394 = uVar21;
      local_38c = uVar26;
      FUN_195ed7db4(puVar10,&local_380);
      uVar19 = local_5f8;
      if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
      goto LAB_195f0c614;
LAB_195f0c5b8:
      uVar8 = 0;
      uVar28 = 0;
      uVar19 = 0;
      uVar27 = 0;
      uVar34 = 0;
      uVar25 = 0;
      uVar30 = 0;
      uVar21 = 0;
      uVar26 = 0;
      uVar14 = 0;
      fVar47 = 0.0;
      uVar17 = 1;
    }
    else {
      if (bVar5) {
        fVar47 = *(float *)(local_580 + 0x160);
        fVar49 = *(float *)(local_580 + 0x15c);
        fVar48 = *(float *)(local_580 + 0x110);
        pfVar15 = local_5f0;
        puVar18 = puStack_5b0;
        puVar9 = local_5b8;
        puVar11 = puStack_5c0;
        puVar20 = local_5c8;
        puVar22 = local_5d0;
        puVar23 = local_5d8;
        puVar24 = local_5e0;
        puVar10 = local_5e8;
      }
      else {
        pfVar15 = (float *)&DAT_1eda4630c;
        puVar18 = &DAT_1eda46314;
        puVar9 = &DAT_1eda4631c;
        puVar11 = &DAT_1eda46324;
        puVar20 = &DAT_1eda4632c;
        puVar22 = &DAT_1eda46334;
        puVar23 = &DAT_1eda4633c;
        puVar24 = &DAT_1eda46344;
        puVar10 = &DAT_1eda4634c;
        fVar44 = DAT_1eda46354;
        fVar46 = DAT_1eda46304;
        fVar48 = DAT_1eda46304;
        fVar45 = DAT_1eda46350;
        fVar49 = DAT_1eda46350;
      }
      uVar35 = *puVar10;
      uVar26 = *puVar24;
      uVar21 = *puVar23;
      uVar30 = *puVar22;
      uVar25 = *puVar20;
      uVar34 = *puVar11;
      uVar27 = *puVar9;
      uVar19 = *puVar18;
      uVar8 = *(ulong *)pfVar15;
      uStack_2c8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
      local_2d0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
      uStack_2c0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
      uStack_2b8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
      local_2b3 = DAT_1eda46344._1_3_;
      uStack_2b0 = (undefined5)
                   (CONCAT17((undefined1)DAT_1eda4634c,
                             CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
      uStack_2e8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
      local_2f0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
      uStack_2d8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
      uStack_2e0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
      if (fVar48 == fVar46) {
        local_338 = 0.1f;
        local_2f4 = (undefined1)uVar35;
        puVar10 = &local_338;
        local_334 = uVar8;
        local_32c = uVar19;
        local_324 = uVar27;
        local_31c = uVar34;
        local_314 = uVar25;
        local_30c = uVar30;
        local_304 = uVar21;
        local_2fc = uVar26;
        FUN_195ed7db4(puVar10,&local_2f0);
        if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
        goto LAB_195f0bfd0;
        uVar14 = 0;
        uVar8 = 0;
        uVar19 = 0;
        uVar27 = 0;
        uVar34 = 0;
        uVar25 = 0;
        uVar30 = 0;
        uVar21 = 0;
        uVar26 = 0;
        uVar28 = 0;
        bVar5 = true;
        fVar47 = 0.0;
        uVar17 = 1;
      }
      else {
LAB_195f0bfd0:
        bVar5 = false;
        uVar17 = 0;
        uVar14 = (ulong)(uint)fVar48 | (f 0, f 0.1);
        uVar28 = CONCAT44(fVar49,uVar35);
      }
      *(ulong *)(local_580 + 0x110) = uVar14;
      *(ulong *)(local_580 + 0x118) = uVar8;
      *(ulong *)(local_580 + 0x120) = uVar19;
      *(undefined8 *)(local_580 + 0x128) = uVar27;
      *(undefined8 *)(local_580 + 0x130) = uVar34;
      *(undefined8 *)(local_580 + 0x138) = uVar25;
      *(undefined8 *)(local_580 + 0x140) = uVar30;
      *(undefined8 *)(local_580 + 0x148) = uVar21;
      *(undefined8 *)(local_580 + 0x150) = uVar26;
      *(ulong *)(local_580 + 0x158) = uVar28;
      *(float *)(local_580 + 0x160) = fVar47;
      *(undefined1 *)(local_580 + 0x164) = uVar17;
      if (bVar5) {
        uVar28 = (ulong)DAT_1eda4634c;
        uVar21 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
        uVar26 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
        uVar25 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
        uVar30 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
        uVar27 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
        uVar34 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
        uVar19 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
        uVar8 = (ulong)DAT_1eda46310;
        uVar29 = (ulong)DAT_1eda46308;
        fVar44 = DAT_1eda46354;
        fVar47 = DAT_1eda46354;
        fVar46 = DAT_1eda46304;
        fVar48 = DAT_1eda46304;
        fVar45 = DAT_1eda46350;
        fVar49 = DAT_1eda46350;
      }
      else {
        uVar29 = uVar14 >> 0x20;
        uVar8 = uVar8 >> 0x20;
        fVar48 = (float)uVar14;
        fVar49 = (float)(uVar28 >> 0x20);
      }
      uStack_358 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
      local_360 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
      local_350 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
      uStack_348 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
      uStack_343 = DAT_1eda46344._1_3_;
      uStack_340 = (undefined5)
                   (CONCAT17((undefined1)DAT_1eda4634c,
                             CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
      uStack_378 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
      local_380 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
      uStack_368 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
      local_370 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
      if (fVar48 == fVar46) {
        local_3c8 = (undefined4)uVar29;
        local_5f8 = uVar8 << 0x20 | 0.5f;
        local_384 = (undefined1)uVar28;
        puVar10 = &local_3c8;
        local_3c4 = local_5f8;
        local_3bc = uVar19;
        local_3b4 = uVar27;
        local_3ac = uVar34;
        local_3a4 = uVar25;
        local_39c = uVar30;
        local_394 = uVar21;
        local_38c = uVar26;
        FUN_195ed7db4(puVar10,&local_380);
        uVar8 = local_5f8;
        if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
        goto LAB_195f0c45c;
        uVar29 = 0;
        uVar8 = 0;
        uVar19 = 0;
        uVar27 = 0;
        uVar34 = 0;
        uVar25 = 0;
        uVar30 = 0;
        uVar21 = 0;
        uVar26 = 0;
        uVar14 = 0;
        bVar5 = true;
        fVar47 = 0.0;
        uVar17 = 1;
      }
      else {
        uVar8 = uVar8 << 0x20 | 0.5f;
LAB_195f0c45c:
        bVar5 = false;
        uVar17 = 0;
        uVar29 = (ulong)(uint)fVar48 | uVar29 << 0x20;
        uVar14 = uVar28 & 0xffffffff | (ulong)(uint)fVar49 << 0x20;
      }
      *(ulong *)(local_580 + 0x110) = uVar29;
      *(ulong *)(local_580 + 0x118) = uVar8;
      *(ulong *)(local_580 + 0x120) = uVar19;
      *(undefined8 *)(local_580 + 0x128) = uVar27;
      *(undefined8 *)(local_580 + 0x130) = uVar34;
      *(undefined8 *)(local_580 + 0x138) = uVar25;
      *(undefined8 *)(local_580 + 0x140) = uVar30;
      *(undefined8 *)(local_580 + 0x148) = uVar21;
      *(undefined8 *)(local_580 + 0x150) = uVar26;
      *(ulong *)(local_580 + 0x158) = uVar14;
      *(float *)(local_580 + 0x160) = fVar47;
      *(undefined1 *)(local_580 + 0x164) = uVar17;
      if (bVar5) {
        uVar14 = (ulong)DAT_1eda4634c;
        uVar21 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
        uVar26 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
        uVar25 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
        uVar30 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
        uVar27 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
        uVar34 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
        uVar19 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
        uVar33 = (ulong)DAT_1eda46308;
        uVar8 = (ulong)DAT_1eda4630c;
        fVar44 = DAT_1eda46354;
        fVar47 = DAT_1eda46354;
        fVar46 = DAT_1eda46304;
        fVar48 = DAT_1eda46304;
        fVar45 = DAT_1eda46350;
        fVar49 = DAT_1eda46350;
      }
      else {
        uVar33 = uVar29 >> 0x20;
        fVar48 = (float)uVar29;
        fVar49 = (float)(uVar14 >> 0x20);
      }
      uStack_408 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
      local_410 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
      uStack_3f8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
      local_400 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
      uStack_3e8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
      local_3f0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
      local_3e0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
      uStack_3d8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
      uStack_3d3 = DAT_1eda46344._1_3_;
      uStack_3d0 = (undefined5)
                   (CONCAT17((undefined1)DAT_1eda4634c,
                             CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
      if (fVar48 == fVar46) {
        local_458 = (undefined4)uVar33;
        local_454 = uVar8 & 0xffffffff | 0.000292969;
        local_414 = (undefined1)uVar14;
        puVar10 = &local_458;
        local_5f8 = uVar19;
        local_44c = uVar19;
        local_444 = uVar27;
        local_43c = uVar34;
        local_434 = uVar25;
        local_42c = uVar30;
        local_424 = uVar21;
        local_41c = uVar26;
        FUN_195ed7db4(puVar10,&local_410);
        uVar19 = local_5f8;
        if (((((ulong)puVar10 & 1) != 0) && (fVar49 == fVar45)) && (fVar47 == fVar44))
        goto LAB_195f0c5b8;
      }
      uVar28 = uVar8 & 0xffffffff | 0.000292969;
      uVar8 = (ulong)(uint)fVar48 | uVar33 << 0x20;
LAB_195f0c660:
      uVar17 = 0;
      uVar14 = uVar14 & 0xffffffff | (ulong)(uint)fVar49 << 0x20;
    }
    puVar10 = _DAT_1e017dd58;
    *(ulong *)(local_580 + 0x110) = uVar8;
    *(ulong *)(local_580 + 0x118) = uVar28;
    *(ulong *)(local_580 + 0x120) = uVar19;
    *(undefined8 *)(local_580 + 0x128) = uVar27;
    *(undefined8 *)(local_580 + 0x130) = uVar34;
    *(undefined8 *)(local_580 + 0x138) = uVar25;
    *(undefined8 *)(local_580 + 0x140) = uVar30;
    *(undefined8 *)(local_580 + 0x148) = uVar21;
    *(undefined8 *)(local_580 + 0x150) = uVar26;
    *(ulong *)(local_580 + 0x158) = uVar14;
    *(float *)(local_580 + 0x160) = fVar47;
    *(undefined1 *)(local_580 + 0x164) = uVar17;
    lVar7 = local_5a8;
  }
  uVar8 = local_588;
  if (((uint)lVar7 >> 3 & 1) == 0) {
    return;
  }
  lVar13 = 0;
  FUN_195f3c68c();
  lVar7 = local_590;
  lVar6 = local_598;
  puVar4 = local_5a0;
  iVar1 = *(int *)(lVar13 + 0x18);
  (**(code **)(local_598 + 0x68))(local_5a0,*puVar10,local_590);
  puVar9 = &DAT_1eda3a8e0;
  FUN_195f0cf6c(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar8 = uVar8 + (long)iVar1;
  func_0x0001980ff320(uVar8,puVar4,lVar7,puVar9);
  (**(code **)(lVar6 + 8))(puVar4,lVar7);
  bVar5 = *(char *)(local_580 + 0x164) != '\x01';
  fVar47 = DAT_1eda46354;
  if ((uVar8 & 1) == 0) {
    if (bVar5) {
      puVar16 = (undefined4 *)(local_580 + 0x114);
      fVar47 = *(float *)(local_580 + 0x160);
      fVar49 = *(float *)(local_580 + 0x15c);
      puVar10 = (undefined4 *)(local_580 + 0x11c);
      fVar48 = *(float *)(local_580 + 0x110);
      puVar9 = local_5d8;
      puVar11 = local_5e0;
      puVar12 = local_5e8;
      pfVar15 = local_5f0;
      puVar18 = puStack_5b0;
      puVar20 = local_5b8;
      puVar22 = puStack_5c0;
      puVar23 = local_5c8;
      puVar24 = local_5d0;
    }
    else {
      puVar10 = &DAT_1eda46310;
      puVar16 = &DAT_1eda46308;
      puVar9 = &DAT_1eda4633c;
      puVar11 = &DAT_1eda46344;
      puVar12 = &DAT_1eda4634c;
      pfVar15 = (float *)&DAT_1eda4630c;
      puVar18 = &DAT_1eda46314;
      puVar20 = &DAT_1eda4631c;
      puVar22 = &DAT_1eda46324;
      puVar23 = &DAT_1eda4632c;
      puVar24 = &DAT_1eda46334;
      fVar44 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar48 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
      fVar49 = DAT_1eda46350;
    }
    uVar35 = *puVar12;
    uVar26 = *puVar11;
    uVar21 = *puVar9;
    uVar30 = *puVar24;
    uVar25 = *puVar23;
    uVar34 = *puVar22;
    uVar27 = *puVar20;
    uVar8 = *puVar18;
    uVar37 = *puVar16;
    uStack_478 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_480 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    uStack_470 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_468 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    local_463 = DAT_1eda46344._1_3_;
    uStack_460 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_498 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_4a0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_488 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    uStack_490 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    if (fVar48 == fVar46) {
      local_588 = CONCAT44(*puVar10,*pfVar15 + -0.1);
      local_4a4 = (undefined1)uVar35;
      puVar10 = &local_4e8;
      local_4e8 = uVar37;
      local_4e4 = local_588;
      local_4dc = uVar8;
      local_4d4 = uVar27;
      local_4cc = uVar34;
      local_4c4 = uVar25;
      local_4bc = uVar30;
      local_4b4 = uVar21;
      local_4ac = uVar26;
      FUN_195ed7db4(puVar10,&local_4a0);
      if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
      goto LAB_195f0cb88;
      uVar19 = 0;
      local_588 = 0;
      uVar8 = 0;
      uVar27 = 0;
      uVar34 = 0;
      uVar25 = 0;
      uVar30 = 0;
      uVar21 = 0;
      uVar26 = 0;
      uVar14 = 0;
      bVar5 = true;
      fVar47 = 0.0;
      uVar17 = 1;
    }
    else {
      local_588 = CONCAT44(*puVar10,*pfVar15 + -0.1);
LAB_195f0cb88:
      bVar5 = false;
      uVar17 = 0;
      uVar19 = CONCAT44(uVar37,fVar48);
      uVar14 = CONCAT44(fVar49,uVar35);
    }
    *(ulong *)(local_580 + 0x110) = uVar19;
    *(ulong *)(local_580 + 0x118) = local_588;
    *(ulong *)(local_580 + 0x120) = uVar8;
    *(undefined8 *)(local_580 + 0x128) = uVar27;
    *(undefined8 *)(local_580 + 0x130) = uVar34;
    *(undefined8 *)(local_580 + 0x138) = uVar25;
    *(undefined8 *)(local_580 + 0x140) = uVar30;
    *(undefined8 *)(local_580 + 0x148) = uVar21;
    *(undefined8 *)(local_580 + 0x150) = uVar26;
    *(ulong *)(local_580 + 0x158) = uVar14;
    *(float *)(local_580 + 0x160) = fVar47;
    *(undefined1 *)(local_580 + 0x164) = uVar17;
    if (bVar5) {
      uVar14 = (ulong)DAT_1eda4634c;
      uVar21 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar26 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar25 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      uVar30 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar27 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar34 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      uVar8 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      uVar28 = (ulong)DAT_1eda46308;
      local_588 = (ulong)DAT_1eda4630c;
      fVar44 = DAT_1eda46354;
      fVar47 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar48 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
      fVar49 = DAT_1eda46350;
    }
    else {
      uVar28 = uVar19 >> 0x20;
      fVar48 = (float)uVar19;
      fVar49 = (float)(uVar14 >> 0x20);
    }
    uVar19 = 0.000878906;
  }
  else {
    if (bVar5) {
      puVar16 = (undefined4 *)(local_580 + 0x114);
      fVar47 = *(float *)(local_580 + 0x160);
      fVar49 = *(float *)(local_580 + 0x15c);
      puVar10 = (undefined4 *)(local_580 + 0x11c);
      fVar48 = *(float *)(local_580 + 0x110);
      puVar9 = local_5d8;
      puVar11 = local_5e0;
      puVar12 = local_5e8;
      pfVar15 = local_5f0;
      puVar18 = puStack_5b0;
      puVar20 = local_5b8;
      puVar22 = puStack_5c0;
      puVar23 = local_5c8;
      puVar24 = local_5d0;
    }
    else {
      puVar10 = &DAT_1eda46310;
      puVar16 = &DAT_1eda46308;
      puVar9 = &DAT_1eda4633c;
      puVar11 = &DAT_1eda46344;
      puVar12 = &DAT_1eda4634c;
      pfVar15 = (float *)&DAT_1eda4630c;
      puVar18 = &DAT_1eda46314;
      puVar20 = &DAT_1eda4631c;
      puVar22 = &DAT_1eda46324;
      puVar23 = &DAT_1eda4632c;
      puVar24 = &DAT_1eda46334;
      fVar44 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar48 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
      fVar49 = DAT_1eda46350;
    }
    uVar35 = *puVar12;
    uVar26 = *puVar11;
    uVar21 = *puVar9;
    uVar30 = *puVar24;
    uVar25 = *puVar23;
    uVar34 = *puVar22;
    uVar27 = *puVar20;
    uVar8 = *puVar18;
    uVar37 = *puVar16;
    uStack_478 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_480 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    uStack_470 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_468 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    local_463 = DAT_1eda46344._1_3_;
    uStack_460 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_498 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_4a0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_488 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    uStack_490 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    if (fVar48 == fVar46) {
      local_588 = CONCAT44(*puVar10,*pfVar15 + -0.3);
      local_4a4 = (undefined1)uVar35;
      puVar10 = &local_4e8;
      local_4e8 = uVar37;
      local_4e4 = local_588;
      local_4dc = uVar8;
      local_4d4 = uVar27;
      local_4cc = uVar34;
      local_4c4 = uVar25;
      local_4bc = uVar30;
      local_4b4 = uVar21;
      local_4ac = uVar26;
      FUN_195ed7db4(puVar10,&local_4a0);
      if (((((ulong)puVar10 & 1) == 0) || (fVar49 != fVar45)) || (fVar47 != fVar44))
      goto LAB_195f0cad0;
      uVar19 = 0;
      local_588 = 0;
      uVar8 = 0;
      uVar27 = 0;
      uVar34 = 0;
      uVar25 = 0;
      uVar30 = 0;
      uVar21 = 0;
      uVar26 = 0;
      uVar14 = 0;
      bVar5 = true;
      fVar47 = 0.0;
      uVar17 = 1;
    }
    else {
      local_588 = CONCAT44(*puVar10,*pfVar15 + -0.3);
LAB_195f0cad0:
      bVar5 = false;
      uVar17 = 0;
      uVar19 = CONCAT44(uVar37,fVar48);
      uVar14 = CONCAT44(fVar49,uVar35);
    }
    *(ulong *)(local_580 + 0x110) = uVar19;
    *(ulong *)(local_580 + 0x118) = local_588;
    *(ulong *)(local_580 + 0x120) = uVar8;
    *(undefined8 *)(local_580 + 0x128) = uVar27;
    *(undefined8 *)(local_580 + 0x130) = uVar34;
    *(undefined8 *)(local_580 + 0x138) = uVar25;
    *(undefined8 *)(local_580 + 0x140) = uVar30;
    *(undefined8 *)(local_580 + 0x148) = uVar21;
    *(undefined8 *)(local_580 + 0x150) = uVar26;
    *(ulong *)(local_580 + 0x158) = uVar14;
    *(float *)(local_580 + 0x160) = fVar47;
    *(undefined1 *)(local_580 + 0x164) = uVar17;
    if (bVar5) {
      uVar14 = (ulong)DAT_1eda4634c;
      uVar21 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar26 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar25 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      uVar30 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar27 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar34 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      uVar8 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      uVar28 = (ulong)DAT_1eda46308;
      local_588 = (ulong)DAT_1eda4630c;
      fVar44 = DAT_1eda46354;
      fVar47 = DAT_1eda46354;
      fVar46 = DAT_1eda46304;
      fVar48 = DAT_1eda46304;
      fVar45 = DAT_1eda46350;
      fVar49 = DAT_1eda46350;
    }
    else {
      uVar28 = uVar19 >> 0x20;
      fVar48 = (float)uVar19;
      fVar49 = (float)(uVar14 >> 0x20);
    }
    uVar19 = 0.000292969;
  }
  uStack_508 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_510 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_500 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_4f8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_4f3 = DAT_1eda46344._1_3_;
  uStack_4f0 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_528 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_530 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_518 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_520 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar48 == fVar46) {
    local_578 = (undefined4)uVar28;
    uVar19 = local_588 & 0xffffffff | uVar19;
    local_534 = (undefined1)uVar14;
    puVar10 = &local_578;
    local_588 = uVar8;
    local_574 = uVar19;
    local_56c = uVar8;
    local_564 = uVar27;
    local_55c = uVar34;
    local_554 = uVar25;
    local_54c = uVar30;
    local_544 = uVar21;
    local_53c = uVar26;
    FUN_195ed7db4(puVar10,&local_530);
    if (((((ulong)puVar10 & 1) != 0) && (fVar49 == fVar45)) && (fVar47 == fVar44)) {
      uVar8 = 0;
      uVar19 = 0;
      local_588 = 0;
      uVar27 = 0;
      uVar34 = 0;
      uVar25 = 0;
      uVar30 = 0;
      uVar21 = 0;
      uVar26 = 0;
      uVar14 = 0;
      fVar47 = 0.0;
      uVar17 = 1;
      goto LAB_195f0cd48;
    }
  }
  else {
    uVar19 = local_588 & 0xffffffff | uVar19;
    local_588 = uVar8;
  }
  uVar17 = 0;
  uVar8 = (ulong)(uint)fVar48 | uVar28 << 0x20;
  uVar14 = uVar14 & 0xffffffff | (ulong)(uint)fVar49 << 0x20;
LAB_195f0cd48:
  *(ulong *)(local_580 + 0x110) = uVar8;
  *(ulong *)(local_580 + 0x118) = uVar19;
  *(ulong *)(local_580 + 0x120) = local_588;
  *(undefined8 *)(local_580 + 0x128) = uVar27;
  *(undefined8 *)(local_580 + 0x130) = uVar34;
  *(undefined8 *)(local_580 + 0x138) = uVar25;
  *(undefined8 *)(local_580 + 0x140) = uVar30;
  *(undefined8 *)(local_580 + 0x148) = uVar21;
  *(undefined8 *)(local_580 + 0x150) = uVar26;
  *(ulong *)(local_580 + 0x158) = uVar14;
  *(float *)(local_580 + 0x160) = fVar47;
  *(undefined1 *)(local_580 + 0x164) = uVar17;
  return;
}


//######## DockRecipe.Phone (spec) 0x195f0d020
// === 195f0e404 spec

/* WARNING: Removing unreachable block (ram,0x000195f0e4d8) */
/* WARNING: Removing unreachable block (ram,0x000195f0e460) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0e404(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(uVar4 - 8);
  uVar5 = uVar4;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar11 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  lVar6 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar6 + 0x18);
  lVar6 = lVar11;
  (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e017dd58,uVar4);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar1;
  func_0x0001980ff320(uVar7,lVar11,uVar4,lVar6);
  (**(code **)(lVar9 + 8))(lVar11,uVar4);
  if ((uVar7 & 1) == 0) {
    if ((uVar5 & 1) != 0) {
      <refraction.normalizedInnerAmount> = -0.4;
      <refraction.normalizedInnerHeight> = 0.2;
      <refraction.normalizedOuterAmount> = 0.42;
      <refraction.normalizedOuterHeight> = 0.13;
      <refraction.outerOpacity> = 0.2f;
      <faceEffect.ycc.black> = 0.125f;
      <faceEffect.ycc.white> = {d 0.0109375};
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
      uVar12 = 1f;
      uVar13 = 1f;
      uVar15 = 1f;
      uVar16 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
      FUN_195eda468(<shadow.opacity>,<+0x30>,
                    <+0x38>,<+0x40>,
                    <+0x48>,<+0x50>,
                    <+0x51>);
      <+0x4a> = 0;
      <+0x42> = 0;
      <+0x40> = 0;
      <+0x38> = 0;
      <+0x30> = 0;
      <shadow.opacity> = 0;
      <highlights.keyYCC.white> = 0.9f;
      goto LAB_195f0ea84;
    }
    FUN_195eda468(<blur.blurRadius>,<+0x170>,
                  <+0x178>,<+0x180>,
                  <+0x188>,<+0x190>,
                  <+0x191>);
    <blur.blurRadius> = 2f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
    <refraction.normalizedInnerAmount> = -0.42;
    <refraction.normalizedInnerHeight> = 0.127;
    <refraction.normalizedOuterAmount> = 0.42;
    <refraction.normalizedOuterHeight> = 0.13;
    <refraction.outerOpacity> = 0.2f;
    puVar2 = _DAT_1e01830d0;
    uVar14 = {d 0.0109375};
    <faceEffect.ycc.black> = 0.1f;
    <faceEffect.ycc.white> = uVar14;
    (**(code **)(lVar8 + 0x68))(puVar10,*puVar2,lVar3);
    uVar16 = 0.1f;
    uVar12 = 1f;
    uVar13 = 1f;
    uVar15 = 1f;
    func_0x0001981218c0(puVar10);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar16 >> 0x18),
                  CONCAT16((char)((uint)uVar16 >> 0x10),
                           CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
    <faceEffect.ycc.normalFill?nil> = 0;
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <shadow.opacity> = 0.1f;
    <+0x38> = 0;
    <+0x30> = 0;
    <+0x48> = 0;
    <+0x40> = 0;
    <+0x50> = 0;
    <highlights.keyYCC.black> = 0.65f;
    <highlights.keyYCC.white> = {d 0.025};
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.b> = 0;
    <highlights.keyYCC.dodgeFill.r> = 0;
  }
  else {
    if ((uVar5 & 1) == 0) {
      FUN_195eda468(<blur.blurRadius>,<+0x170>,
                    <+0x178>,<+0x180>,
                    <+0x188>,<+0x190>,
                    <+0x191>);
      uVar14 = {d 48};
      <+0x170> = {d 160};
      <blur.blurRadius> = uVar14;
      <+0x178> = {d 32};
      uVar14 = {f 0, 1.4013e-45};
      <+0x188> = {d 0};
      <+0x180> = uVar14;
      <+0x190> = 0x201;
      <refraction.normalizedInnerAmount> = -0.42;
      <refraction.normalizedInnerHeight> = 0.127;
      <refraction.normalizedOuterAmount> = 0.42;
      <refraction.normalizedOuterHeight> = 0.13;
      <refraction.outerOpacity> = 0.2f;
      <faceEffect.ycc.black> = 0.0046875;
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
      uVar16 = 0.1f;
      uVar12 = 0;
      uVar13 = 0;
      uVar15 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
      FUN_195eda468(<shadow.opacity>,<+0x30>,
                    <+0x38>,<+0x40>,
                    <+0x48>,<+0x50>,
                    <+0x51>);
      <+0x4a> = 0;
      <+0x42> = 0;
      <+0x40> = 0;
      <+0x38> = 0;
      <+0x30> = 0;
      <shadow.opacity> = 0;
      <highlights.keyYCC.black> = 0.3f;
      uVar14 = {d 0.04375};
    }
    else {
      <refraction.normalizedInnerAmount> = -0.44;
      <refraction.normalizedInnerHeight> = 0.2;
      <refraction.normalizedOuterAmount> = 0.42;
      <refraction.normalizedOuterHeight> = 0.13;
      <refraction.outerOpacity> = 0.2f;
      <faceEffect.ycc.black> = 0.0078125;
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
      uVar16 = 0.1f;
      uVar12 = 0;
      uVar13 = 0;
      uVar15 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
      FUN_195eda468(<shadow.opacity>,<+0x30>,
                    <+0x38>,<+0x40>,
                    <+0x48>,<+0x50>,
                    <+0x51>);
      <+0x4a> = 0;
      <+0x42> = 0;
      <+0x40> = 0;
      <+0x38> = 0;
      <+0x30> = 0;
      <shadow.opacity> = 0;
      <highlights.keyYCC.black> = 0.25f;
      uVar14 = {d 0.025};
    }
    <highlights.keyYCC.white> = uVar14;
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.b> = 0;
    <highlights.keyYCC.dodgeFill.r> = 0;
  }
  <highlights.keyYCC.dodgeFill?nil> = 1;
  <highlights.keyYCC.burnFill.b> = 0;
  <highlights.keyYCC.burnFill.r> = 0;
  <highlights.keyYCC.burnFill?nil> = 1;
LAB_195f0ea84:
  <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
  <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
  <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
  <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
  <+0x411> = <+0x3c9>;
  <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
  <highlights.fillYCC.black> = <highlights.keyYCC.black>;
  <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
  <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  return;
}


//######## DockRecipe.Other (spec) 0x195f0d024
// === 195f0dcbc spec

/* WARNING: Removing unreachable block (ram,0x000195f0dd90) */
/* WARNING: Removing unreachable block (ram,0x000195f0dd18) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0dcbc(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  uVar11 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  uVar6 = uVar11;
  (**(code **)(lVar9 + 0x68))(uVar11,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar1;
  func_0x0001980ff320(uVar7,uVar11,lVar4,uVar6);
  (**(code **)(lVar9 + 8))(uVar11,lVar4);
  FUN_195ed53f0();
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  uVar14 = {d 48};
  if ((uVar7 & 1) == 0) {
    if ((uVar11 & 1) != 0) {
      <blur.blurRadius> = 1.5f;
      <+0x178> = 0;
      <+0x170> = 0;
      <+0x188> = 0;
      <+0x180> = 0;
      <+0x190> = 0;
      <refraction.normalizedInnerAmount> = -0.18;
      <refraction.normalizedInnerHeight> = 0.08;
      <refraction.normalizedOuterAmount> = 0.42;
      <refraction.normalizedOuterHeight> = 0.13;
      <refraction.outerOpacity> = 0.2f;
      puVar2 = _DAT_1e01830d0;
      uVar14 = {d 0.03125};
      <faceEffect.ycc.black> = 0.15f;
      <faceEffect.ycc.white> = uVar14;
      (**(code **)(lVar8 + 0x68))(puVar10,*puVar2,lVar3);
      uVar12 = 1f;
      uVar13 = 1f;
      uVar15 = 1f;
      uVar16 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
      FUN_195eda468(<shadow.opacity>,<+0x30>,
                    <+0x38>,<+0x40>,
                    <+0x48>,<+0x50>,
                    <+0x51>);
      <+0x4a> = 0;
      <+0x42> = 0;
      <+0x40> = 0;
      <+0x38> = 0;
      <+0x30> = 0;
      <shadow.opacity> = 0;
      <darkSpecular.spread> = 2.0944;
      <highlights.keyYCC.white> = 0.9f;
      goto LAB_195f0e3c8;
    }
    <+0x170> = {d 160};
    <blur.blurRadius> = uVar14;
    <+0x178> = {d 32};
    uVar14 = {f 0, 1.4013e-45};
    <+0x188> = {d 0};
    <+0x180> = uVar14;
    <+0x190> = 0x201;
    <refraction.normalizedInnerAmount> = -0.42;
    <refraction.normalizedInnerHeight> = 0.127;
    <refraction.normalizedOuterAmount> = 0.42;
    <refraction.normalizedOuterHeight> = 0.13;
    <refraction.outerOpacity> = 0.2f;
    <faceEffect.ycc.black> = 0.15f;
    puVar2 = _DAT_1e01830d0;
    <faceEffect.ycc.white> = {d 0.0109375};
    (**(code **)(lVar8 + 0x68))(puVar10,*puVar2,lVar3);
    uVar16 = 0.1f;
    uVar12 = 1f;
    uVar13 = 1f;
    uVar15 = 1f;
    func_0x0001981218c0(puVar10);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar16 >> 0x18),
                  CONCAT16((char)((uint)uVar16 >> 0x10),
                           CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
    <faceEffect.ycc.normalFill?nil> = 0;
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <shadow.opacity> = 0.15f;
    <+0x38> = 0;
    <+0x30> = 0;
    <+0x48> = 0;
    <+0x40> = 0;
    <+0x50> = 0;
    <highlights.keyYCC.black> = 0.65f;
    uVar14 = {d 0.025};
LAB_195f0e3a0:
    <highlights.keyYCC.white> = uVar14;
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.b> = 0;
    <highlights.keyYCC.dodgeFill.r> = 0;
    <highlights.keyYCC.dodgeFill?nil> = 1;
    <highlights.keyYCC.burnFill.b> = 0;
    <highlights.keyYCC.burnFill.r> = 0;
  }
  else {
    if ((uVar11 & 1) == 0) {
      <+0x170> = {d 160};
      <blur.blurRadius> = uVar14;
      <+0x178> = {d 32};
      uVar14 = {f 0, 1.4013e-45};
      <+0x188> = {d 0};
      <+0x180> = uVar14;
      <+0x190> = 0x201;
      <refraction.normalizedInnerAmount> = -0.42;
      <refraction.normalizedInnerHeight> = 0.127;
      <refraction.normalizedOuterAmount> = 0.42;
      <refraction.normalizedOuterHeight> = 0.13;
      <refraction.outerOpacity> = 0.2f;
      <faceEffect.ycc.black> = 0.00273437;
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
      uVar16 = 0.1f;
      uVar12 = 0;
      uVar13 = 0;
      uVar15 = 0;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar16 >> 0x18),
                    CONCAT16((char)((uint)uVar16 >> 0x10),
                             CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
      FUN_195eda468(<shadow.opacity>,<+0x30>,
                    <+0x38>,<+0x40>,
                    <+0x48>,<+0x50>,
                    <+0x51>);
      <shadow.opacity> = 0.05f;
      <+0x38> = 0;
      <+0x30> = 0;
      <+0x48> = 0;
      <+0x40> = 0;
      <+0x50> = 0;
      <highlights.keyYCC.black> = 0.3f;
      uVar14 = {d 0.04375};
      goto LAB_195f0e3a0;
    }
    <blur.blurRadius> = 1.5f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
    <refraction.normalizedInnerAmount> = -0.18;
    <refraction.normalizedInnerHeight> = 0.08;
    <refraction.normalizedOuterAmount> = 0.42;
    <refraction.normalizedOuterHeight> = 0.13;
    <faceEffect.maxLuminance> = 0.000488281;
    <refraction.outerOpacity> = 0.2f;
    puVar2 = _DAT_1e01830d0;
    uVar14 = {d 0.03125};
    <faceEffect.ycc.black> = 0.05f;
    <faceEffect.ycc.white> = uVar14;
    (**(code **)(lVar8 + 0x68))(puVar10,*puVar2,lVar3);
    uVar16 = 0.02f;
    uVar12 = 0;
    uVar13 = 0;
    uVar15 = 0;
    func_0x0001981218c0(puVar10);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar16 >> 0x18),
                  CONCAT16((char)((uint)uVar16 >> 0x10),
                           CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,uVar15))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar13 >> 0x18),
                  CONCAT16((char)((uint)uVar13 >> 0x10),
                           CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
    <faceEffect.ycc.normalFill?nil> = 0;
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <+0x4a> = 0;
    <+0x42> = 0;
    <+0x40> = 0;
    <+0x38> = 0;
    <+0x30> = 0;
    <shadow.opacity> = 0;
    <darkSpecular.spread> = 2.0944;
    <highlights.keyYCC.black> = 0.25f;
    <highlights.keyYCC.white> = {d 0.025};
    <highlights.keyYCC.normalFill.b> = 0;
    <highlights.keyYCC.normalFill.r> = 0;
    <highlights.keyYCC.normalFill?nil> = 1;
    <highlights.keyYCC.dodgeFill.b> = 0;
    <highlights.keyYCC.dodgeFill.r> = 0;
    <highlights.keyYCC.dodgeFill?nil> = 1;
    <highlights.keyYCC.burnFill.b> = 0;
    <highlights.keyYCC.burnFill.r> = 0;
  }
  <highlights.keyYCC.burnFill?nil> = 1;
LAB_195f0e3c8:
  <highlights.fillYCC.dodgeFill.b> = <highlights.keyYCC.dodgeFill.b>;
  <highlights.fillYCC.dodgeFill.r> = <highlights.keyYCC.dodgeFill.r>;
  <highlights.fillYCC.burnFill.g> = <highlights.keyYCC.burnFill.g>;
  <highlights.fillYCC.dodgeFill?nil> = <highlights.keyYCC.dodgeFill?nil>;
  <+0x411> = <+0x3c9>;
  <highlights.fillYCC.saturation> = <highlights.keyYCC.saturation>;
  <highlights.fillYCC.black> = <highlights.keyYCC.black>;
  <highlights.fillYCC.normalFill.a> = <highlights.keyYCC.normalFill.a>;
  <highlights.fillYCC.normalFill.g> = <highlights.keyYCC.normalFill.g>;
  return;
}


//######## DockRecipe.ReducedTransparency (spec) 0x195f0d028
// === 195f0da94 spec

/* WARNING: Removing unreachable block (ram,0x000195f0db68) */
/* WARNING: Removing unreachable block (ram,0x000195f0daf0) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0da94(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar6 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar8 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(uVar3 - 8);
  uVar4 = uVar3;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar9 = (long)puVar8 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar4 & 1) != 0) {
    lVar5 = 0;
    FUN_195f3c68c();
    iVar1 = *(int *)(lVar5 + 0x18);
    lVar5 = lVar9;
    (**(code **)(lVar7 + 0x68))(lVar9,*_DAT_1e017dd58,uVar3);
    FUN_195e7d9c0();
    uVar4 = param_2 + iVar1;
    func_0x0001980ff320(uVar4,lVar9,uVar3,lVar5);
    (**(code **)(lVar7 + 8))(lVar9,uVar3);
    if ((uVar4 & 1) == 0) {
      <faceEffect.ycc.black> = 0.00335938;
      (**(code **)(lVar6 + 0x68))(puVar8,*_DAT_1e01830d0,lVar2);
      uVar13 = 0.1f;
      uVar10 = 1f;
      uVar11 = 1f;
      uVar12 = 1f;
      func_0x0001981218c0(puVar8);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar11 >> 0x18),
                    CONCAT16((char)((uint)uVar11 >> 0x10),
                             CONCAT15((char)((uint)uVar11 >> 8),CONCAT14((char)uVar11,uVar10))));
      <faceEffect.ycc.normalFill?nil> = 0;
    }
  }
  return;
}


//######## DockRecipe.IncreasedContrast (spec) 0x195f0d02c
// === 195f0d818 spec

/* WARNING: Removing unreachable block (ram,0x000195f0d8ec) */
/* WARNING: Removing unreachable block (ram,0x000195f0d874) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0d818(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar4 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(uVar4 - 8);
  uVar5 = uVar4;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  lVar10 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar5 & 1) != 0) {
    lVar6 = 0;
    FUN_195f3c68c();
    iVar2 = *(int *)(lVar6 + 0x18);
    lVar6 = lVar10;
    (**(code **)(lVar8 + 0x68))(lVar10,*_DAT_1e017dd58,uVar4);
    FUN_195e7d9c0();
    uVar5 = param_2 + iVar2;
    func_0x0001980ff320(uVar5,lVar10,uVar4,lVar6);
    (**(code **)(lVar8 + 8))(lVar10,uVar4);
    puVar1 = (undefined8 *)(lVar7 + 0x68);
    if ((uVar5 & 1) == 0) {
      <faceEffect.ycc.black> = 0.000292969;
      (*(code *)*puVar1)((ulong)puVar1 & 0xffffffffffff | 0xb2e4000000000000,puVar9,*_DAT_1e01830d0,
                         lVar3);
      uVar14 = 0.12f;
      uVar11 = 1f;
      uVar12 = 1f;
      uVar13 = 1f;
    }
    else {
      <faceEffect.ycc.black> = {d 0.000170898};
      (*(code *)*puVar1)(puVar9,*_DAT_1e01830d0,lVar3);
      uVar14 = 0.15f;
      uVar11 = 0;
      uVar12 = 0;
      uVar13 = 0;
    }
    func_0x0001981218c0(puVar9);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar14 >> 0x18),
                  CONCAT16((char)((uint)uVar14 >> 0x10),
                           CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar12 >> 0x18),
                  CONCAT16((char)((uint)uVar12 >> 0x10),
                           CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar11))));
    <faceEffect.ycc.normalFill?nil> = 0;
    <highlights.keyOpacity> = 0.000488281;
  }
  return;
}


//######## DockAppSwitcherRecipe.anon.AppSwitcher (spec) 0x195f0d030
// === 195f0d030 spec

/* WARNING: Removing unreachable block (ram,0x000195f0d084) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0d030(long param_1,long param_2)
{
  uVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(uVar3 - 8);
  uVar4 = uVar3;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar8 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar4 & 1) != 0) {
    lVar5 = 0;
    FUN_195f3c68c();
    iVar2 = *(int *)(lVar5 + 0x18);
    puVar6 = puVar8;
    (**(code **)(lVar7 + 0x68))(puVar8,*_DAT_1e017dd58,uVar3);
    FUN_195e7d9c0();
    uVar4 = param_2 + iVar2;
    func_0x0001980ff320(uVar4,puVar8,uVar3,puVar6);
    (**(code **)(lVar7 + 8))(puVar8,uVar3);
    FUN_195eda468(<blur.blurRadius>,<+0x170>,
                  <+0x178>,<+0x180>,
                  <+0x188>,<+0x190>,
                  <+0x191>);
    uVar1 = 3.5f;
    if ((uVar4 & 1) == 0) {
      uVar1 = 2f;
    }
    <blur.blurRadius> = uVar1;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  return;
}


//######## FocusBorderRecipe.anon.DisableInactiveSDR (params) 0x195f0eb1c
// === 195f0eb1c params

void FUN_195f0eb1c(long param_1)
{
  undefined1 auVar2 [16];
  uVar1 = 0;
  if (<+0x400> != '\x01') {
    uVar1 = (ulong)<+0x3e0>;
  }
  <+0x3e0> = uVar1;
  <+0x3e8> = 1f;
  auVar2 = NEON_fmov(1,8);
  <+0x3f8> = auVar2._8_8_;
  <+0x3f0> = auVar2._0_8_;
  <+0x400> = 0;
  return;
}


//######## FocusBorderRecipe.anon.Modifier (params) 0x195f0eb48
// === 195f0edf8 params

/* WARNING: Removing unreachable block (ram,0x000195f0ef0c) */
/* WARNING: Removing unreachable block (ram,0x000195f0ef84) */
/* WARNING: Removing unreachable block (ram,0x000195f0ee90) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f0edf8(long param_1,long param_2,undefined8 param_3,undefined8 param_4,
                  undefined4 param_5,undefined4 param_6)
{
  undefined1 (*pauVar1) [12];
  undefined1 auVar41 [16];
  undefined1 auStack_2260 [12];
  undefined1 auStack_2018 [272];
  undefined1 auStack_1de0 [272];
  undefined1 auStack_1ba8 [272];
  undefined1 auStack_1970 [272];
  undefined1 auStack_1738 [272];
  undefined1 auStack_1500 [272];
  undefined1 auStack_12c8 [272];
  undefined1 auStack_1090 [272];
  undefined1 auStack_e58 [276];
  undefined4 local_ad0 [2];
  (*_DAT_1e2125200)();
  lVar5 = 0;
  local_2140 = param_1;
  func_0x0001981217d0();
  local_2148 = *(long *)(lVar5 + -8);
  local_2150 = lVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(local_2148 + 0x40));
  lVar6 = 0;
  local_2158 = auStack_2260 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  func_0x000198120110();
  local_2160 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(local_2160 + 0x40));
  lVar25 = (long)(auStack_2260 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0)) -
           (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  func_0x0001981221e0();
  lVar13 = *(long *)(lVar7 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar13 + 0x40));
  lVar20 = lVar25 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195ed0900();
  iVar4 = *(int *)(lVar5 + 0x30);
  func_0x0001981221b0(lVar20);
  lVar5 = param_2 + iVar4;
  func_0x000198122190(lVar5,lVar20);
  uVar24 = local_2148;
  local_2168 = CONCAT44(local_2168._4_4_,(int)lVar5);
  (**(code **)(lVar13 + 8))(lVar20,lVar7);
  lVar7 = 0;
  FUN_195f3c68c();
  lVar5 = local_2160;
  iVar4 = *(int *)(lVar7 + 0x18);
  lVar7 = lVar25;
  (**(code **)(local_2160 + 0x68))(lVar25,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  param_2 = param_2 + iVar4;
  func_0x0001980ff320(param_2,lVar25,lVar6,lVar7);
  local_2174 = (uint)param_2;
  (**(code **)(lVar5 + 8))(lVar25,lVar6);
  lVar5 = local_2140;
  bVar3 = (local_2168 & 1) == 0;
  local_c0 = 0.15f;
  if (bVar3) {
    local_c0 = 0.3f;
  }
  uVar39 = 2.71875f;
  if (bVar3) {
    uVar39 = 2.96875f;
  }
  local_138 = 10;
  if (bVar3) {
    local_138 = 20;
  }
  local_140 = 0;
  auVar41 = NEON_fmov(1,8);
  uStack_128 = auVar41._8_8_;
  local_130 = auVar41._0_8_;
  uStack_118 = {d 1};
  uStack_120 = {d 0};
  local_110 = (ulong)uVar39 << 0x20;
  uStack_108 = {d 0.0078125};
  local_100 = 1f;
  local_f4 = 0;
  local_fc = 0;
  local_ec = 1;
  local_e8 = 0;
  uStack_e0 = 0;
  local_d8 = 1;
  local_cc = 0;
  local_d4 = 0;
  local_c4 = 1;
  local_b8 = 0;
  FUN_195ed0d6c(&local_140);
  puVar2 = local_2158;
  local_2188 = *(code **)(uVar24 + 0x68);
  local_2180 = CONCAT44(local_2180._4_4_,*_DAT_1e01830d0);
  (*local_2188)(local_2158,*_DAT_1e01830d0,local_2150);
  uVar43 = 0x8f;
  uVar45 = 0xc2;
  uVar47 = 0xf5;
  uVar49 = 0x3d;
  uVar32 = 1f;
  uVar38 = 1f;
  func_0x0001981218c0(puVar2);
  func_0x000198104610(&local_d20,lVar5 + 0x1e8,0x10d);
  iVar4 = (int)&local_d20;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_cac = 0;
    local_c64 = 0;
    local_c5c = 0;
    local_c50 = 0;
    uStack_c48 = 0;
    local_c3c = 0;
    local_c34 = 0;
    uVar39 = 0;
    uVar31 = 0;
    uVar34 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    uVar59 = 0;
    uVar61 = 0;
    local_ce4 = 0;
    local_ce0 = 0;
    uVar12 = 1;
    uVar18 = 1;
    local_ca0 = 0;
    uStack_c98 = 0;
    local_c90 = 0;
    local_c88 = 0;
    uStack_c80 = 0;
    local_c78 = 0;
    local_c70 = 0;
    uStack_c6c = 0;
    local_c68 = 0;
    local_2160 = CONCAT44(local_2160._4_4_,1);
    local_2168 = CONCAT44(local_2168._4_4_,1);
    local_2170 = CONCAT44(local_2170._4_4_,1);
    local_c28 = 0;
    local_c20 = 0;
    local_c1c = 0;
    local_c18 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar29 = 0;
    uVar15 = 0;
    uVar16 = 0;
    local_c8c = 0x95f0f1a4;
    uVar17 = 0;
    local_d04 = param_6;
    uVar30 = 0;
  }
  else {
    uVar31 = (undefined4)local_d18;
    uVar34 = (undefined4)((ulong)local_d18 >> 0x20);
    uVar44 = (undefined1)local_d08;
    uVar46 = (undefined1)((uint)local_d08 >> 8);
    uVar48 = (undefined1)((uint)local_d08 >> 0x10);
    uVar50 = (undefined1)((uint)local_d08 >> 0x18);
    uVar51 = (undefined1)local_d00;
    uVar52 = (undefined1)((ulong)local_d00 >> 8);
    uVar53 = (undefined1)((ulong)local_d00 >> 0x10);
    uVar54 = (undefined1)((ulong)local_d00 >> 0x18);
    uVar55 = (undefined1)((ulong)local_d00 >> 0x20);
    uVar56 = (undefined1)((ulong)local_d00 >> 0x28);
    uVar59 = (undefined1)((ulong)local_d00 >> 0x30);
    uVar61 = (undefined1)((ulong)local_d00 >> 0x38);
    local_d24 = local_ccb;
    local_d22 = local_cc9;
    uVar12 = (uint)local_cb8;
    local_d26 = local_cb5;
    local_d28 = local_cb7;
    uVar18 = (uint)local_ca4;
    local_d2a = local_ca1;
    local_d2c = local_ca3;
    local_2160 = CONCAT44(local_2160._4_4_,(uint)local_c54);
    local_d2e = local_c51;
    local_d30 = local_c53;
    local_2168 = CONCAT44(local_2168._4_4_,(uint)local_c40);
    local_d32 = local_c3d;
    local_d34 = local_c3f;
    local_2170 = CONCAT44(local_2170._4_4_,(uint)local_c2c);
    local_d36 = local_c29;
    local_d38 = local_c2b;
    uVar39 = (uint)local_c14;
    uVar9 = local_cc8;
    uVar10 = uStack_cc0;
    uVar11 = local_cb4;
    uVar29 = local_d20;
    uVar15 = local_cf8;
    uVar16 = local_cf0;
    uVar17 = local_d10;
    param_5 = local_d1c;
    uVar30 = local_ce8;
  }
  local_2148 = (ulong)(uVar24 + 0x68) & 0xffffffffffff | 0xb2e4000000000000;
  uVar63 = CONCAT44(CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43))),extraout_s2);
  local_d3c = local_d30;
  local_d3a = local_d2e;
  local_d40 = local_d34;
  local_d3e = local_d32;
  local_d44 = local_d38;
  local_d42 = local_d36;
  local_248 = CONCAT44(uVar34,uVar31);
  local_238 = CONCAT13(uVar50,CONCAT12(uVar48,CONCAT11(uVar46,uVar44)));
  local_21d8 = CONCAT44(local_21d8._4_4_,local_d04);
  local_230 = CONCAT17(uVar61,CONCAT16(uVar59,CONCAT15(uVar56,CONCAT14(uVar55,CONCAT13(uVar54,
                                                  CONCAT12(uVar53,CONCAT11(uVar52,uVar51)))))));
  local_21e0 = CONCAT44(local_21e0._4_4_,local_ce4);
  local_21e8 = CONCAT44(local_21e8._4_4_,local_ce0);
  local_1fc = 0;
  local_1fb = local_d24;
  local_1f9 = local_d22;
  local_21f0 = CONCAT44(local_21f0._4_4_,uVar12);
  local_1e8 = (undefined1)uVar12;
  local_1e7 = local_d28;
  local_1e5 = local_d26;
  local_21f8 = CONCAT44(local_21f8._4_4_,uVar18);
  local_1d4 = (undefined1)uVar18;
  local_1d1 = local_d2a;
  local_1d3 = local_d2c;
  local_2210 = CONCAT44(local_2210._4_4_,local_c90);
  local_2218 = CONCAT44(local_2218._4_4_,local_c8c);
  local_2238 = CONCAT44(local_2238._4_4_,local_c70);
  local_184 = (undefined1)local_2160;
  local_181 = local_d2e;
  local_183 = local_d30;
  local_170 = (undefined1)local_2168;
  local_16d = local_d32;
  local_16f = local_d34;
  local_15c = (undefined1)local_2170;
  local_159 = local_d36;
  local_15b = local_d38;
  local_21c8 = CONCAT44(local_21c8._4_4_,uVar39);
  local_144 = (undefined1)uVar39;
  local_ad0[0] = 0;
  local_ac8 = 0;
  uStack_ac0 = 0;
  local_ab8 = 0;
  local_a80 = 0;
  uStack_a98 = 0;
  local_aa0 = 0;
  uStack_a88 = 0;
  uStack_a90 = 0;
  uStack_aa8 = 0;
  local_ab0 = 0;
  local_a7c = 1;
  local_a78 = 0;
  uStack_a70 = 0;
  local_a68 = 1;
  local_a5c = 0;
  local_a64 = 0;
  local_a54 = 1;
  local_a50 = 0;
  uStack_a48 = 0;
  local_a40 = 0;
  local_a08 = 0;
  uStack_a10 = 0;
  local_a18 = 0;
  uStack_a20 = 0;
  local_a28 = 0;
  uStack_a30 = 0;
  local_a38 = 0;
  local_a04 = 1;
  local_a00 = 0;
  uStack_9f8 = 0;
  local_9f0 = 1;
  local_9e4 = 0;
  local_9ec = 0;
  local_9dc = 1;
  uStack_9c8 = 0;
  local_9d8 = 0;
  uStack_9d0 = 0;
  local_9cb = 0;
  puVar8 = &local_250;
  local_2254 = local_c18;
  local_2250 = local_c1c;
  uStack_224c = local_c20;
  local_2248 = local_c28;
  local_2240 = local_c68;
  local_223c = uStack_c6c;
  local_2230 = local_c78;
  local_2228 = uStack_c80;
  local_2220 = local_c88;
  local_2208 = uStack_c98;
  local_2200 = local_ca0;
  local_21cc = param_5;
  local_21c0 = local_c34;
  local_21b8 = local_c3c;
  local_21b0 = uStack_c48;
  local_21a8 = local_c50;
  local_21a0 = local_c5c;
  local_2198 = local_c64;
  local_2190 = local_cac;
  local_250 = uVar29;
  local_24c = param_5;
  uStack_240 = uVar17;
  local_234 = local_d04;
  uStack_228 = uVar15;
  local_220 = uVar16;
  local_218 = uVar30;
  local_214 = local_ce4;
  local_210 = local_ce0;
  local_20c = CONCAT44(uVar38,uVar32);
  local_204 = uVar63;
  local_1f8 = uVar9;
  uStack_1f0 = uVar10;
  local_1e4 = uVar11;
  local_1dc = local_cac;
  local_1d0 = local_ca0;
  uStack_1c8 = uStack_c98;
  local_1c0 = local_c90;
  local_1bc = local_c8c;
  local_1b8 = local_c88;
  uStack_1b0 = uStack_c80;
  local_1a8 = local_c78;
  local_1a0 = local_c70;
  uStack_19c = uStack_c6c;
  local_198 = local_c68;
  local_194 = local_c64;
  local_18c = local_c5c;
  local_180 = local_c50;
  uStack_178 = uStack_c48;
  local_16c = local_c3c;
  local_164 = local_c34;
  local_158 = local_c28;
  local_150 = local_c20;
  local_14c = local_c1c;
  local_148 = local_c18;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_35c = local_21cc;
    local_344 = (undefined4)local_21d8;
    local_324 = (undefined4)local_21e0;
    local_320 = (undefined4)local_21e8;
    local_30c = 0;
    local_30b = local_d24;
    local_309 = local_d22;
    local_2f8 = (undefined1)local_21f0;
    local_2f7 = local_d28;
    local_2f5 = local_d26;
    local_2ec = local_2190;
    local_2e4 = (undefined1)local_21f8;
    local_2e3 = local_d2c;
    local_2e1 = local_d2a;
    local_2e0 = local_2200;
    uStack_2d8 = local_2208;
    local_2d0 = (undefined4)local_2210;
    local_2cc = (undefined4)local_2218;
    local_2c8 = local_2220;
    uStack_2c0 = local_2228;
    local_2b8 = local_2230;
    local_2b0 = (undefined4)local_2238;
    uStack_2ac = local_223c;
    local_2a8 = local_2240;
    local_2a4 = local_2198;
    local_29c = local_21a0;
    local_294 = (undefined1)local_2160;
    local_291 = local_d3a;
    local_293 = local_d3c;
    local_290 = local_21a8;
    uStack_288 = local_21b0;
    local_280 = (undefined1)local_2168;
    local_27d = local_d3e;
    local_27f = local_d40;
    local_27c = local_21b8;
    local_274 = local_21c0;
    local_26c = (undefined1)local_2170;
    local_269 = local_d42;
    local_26b = local_d44;
    local_268 = local_2248;
    local_260 = uStack_224c;
    local_25c = local_2250;
    local_258 = local_2254;
    local_254 = (undefined1)local_21c8;
    local_360 = uVar29;
    local_358 = CONCAT44(uVar34,uVar31);
    uStack_350 = uVar17;
    local_348 = CONCAT13(uVar50,CONCAT12(uVar48,CONCAT11(uVar46,uVar44)));
    local_340 = CONCAT17(uVar61,CONCAT16(uVar59,CONCAT15(uVar56,CONCAT14(uVar55,CONCAT13(uVar54,
                                                  CONCAT12(uVar53,CONCAT11(uVar52,uVar51)))))));
    uStack_338 = uVar15;
    local_330 = uVar16;
    local_328 = uVar30;
    local_31c = CONCAT44(uVar38,uVar32);
    local_314 = uVar63;
    local_308 = uVar9;
    uStack_300 = uVar10;
    local_2f4 = uVar11;
    _CGPointMake(&local_360);
    func_0x000198104610(auStack_e58,&local_360,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_e58);
  }
  lVar5 = local_2140;
  func_0x000198104610(local_2140 + 0x1e8,auStack_e58,0x10d);
  puVar2 = local_2158;
  (*local_2188)(local_2158,local_2180 & 0xffffffff,local_2150);
  uVar43 = 10;
  uVar45 = 0xd7;
  uVar47 = 0xa3;
  uVar49 = 0x3d;
  uVar32 = 1f;
  uVar38 = 1f;
  func_0x0001981218c0(puVar2);
  func_0x000198104610(&local_f68,lVar5 + 0x1e8,0x10d);
  iVar4 = (int)&local_f68;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    uVar14 = 0;
    local_e7c = 0;
    local_e84 = 0;
    local_e98 = 0;
    local_f10 = 0;
    uStack_f08 = 0;
    local_efc = 0;
    local_ef4 = 0;
    uVar33 = 0;
    uVar36 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    uVar59 = 0;
    uVar61 = 0;
    uVar57 = 0;
    uVar58 = 0;
    uVar60 = 0;
    uVar62 = 0;
    uVar12 = 1;
    local_21cc = 1;
    local_f48 = 0;
    local_f40 = 0;
    local_f38 = 0;
    local_f30 = 0;
    local_f2c = 0;
    local_f28 = 0;
    uVar18 = 1;
    uVar19 = 1;
    uVar27 = 1;
    local_ee8 = 0;
    uStack_ee0 = 0;
    local_ed8 = 0;
    local_ed0 = 0;
    uStack_ec8 = 0;
    local_ec0 = 0;
    local_eb8 = 0;
    uStack_eb4 = 0;
    local_eb0 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar29 = 0;
    local_f64 = uVar39;
    uVar30 = 0;
    uVar31 = 0;
    uVar34 = 0;
    uVar37 = 0;
  }
  else {
    uVar44 = (undefined1)local_f60;
    uVar46 = (undefined1)((ulong)local_f60 >> 8);
    uVar48 = (undefined1)((ulong)local_f60 >> 0x10);
    uVar50 = (undefined1)((ulong)local_f60 >> 0x18);
    uVar51 = (undefined1)((ulong)local_f60 >> 0x20);
    uVar52 = (undefined1)((ulong)local_f60 >> 0x28);
    uVar53 = (undefined1)((ulong)local_f60 >> 0x30);
    uVar54 = (undefined1)((ulong)local_f60 >> 0x38);
    uVar55 = (undefined1)local_f58;
    uVar56 = (undefined1)((ulong)local_f58 >> 8);
    uVar59 = (undefined1)((ulong)local_f58 >> 0x10);
    uVar61 = (undefined1)((ulong)local_f58 >> 0x18);
    uVar57 = (undefined1)((ulong)local_f58 >> 0x20);
    uVar58 = (undefined1)((ulong)local_f58 >> 0x28);
    uVar60 = (undefined1)((ulong)local_f58 >> 0x30);
    uVar62 = (undefined1)((ulong)local_f58 >> 0x38);
    uVar18 = (uint)local_f14;
    local_f6a = local_f11;
    local_f6c = local_f13;
    uVar19 = (uint)local_f00;
    local_f6e = local_efd;
    local_f70 = local_eff;
    uVar27 = (uint)local_eec;
    local_f72 = local_ee9;
    local_f74 = local_eeb;
    local_2148 = CONCAT44(local_2148._4_4_,local_ed4);
    local_f76 = local_e99;
    local_f78 = local_e9b;
    local_21cc = (uint)local_e88;
    local_f7a = local_e85;
    local_f7c = local_e87;
    uVar12 = (uint)local_e74;
    local_f7e = local_e71;
    local_f80 = local_e73;
    uVar33 = (undefined4)local_e70;
    uVar36 = (undefined4)((ulong)local_e70 >> 0x20);
    uVar14 = (uint)local_e5c;
    uVar9 = local_f24;
    uVar10 = local_f1c;
    uVar11 = uStack_e90;
    uVar29 = local_e60;
    param_5 = local_f4c;
    uVar30 = local_f68;
    uVar31 = local_f50;
    uVar34 = local_e68;
    uVar37 = local_e64;
  }
  uVar15 = CONCAT44(CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43))),extraout_s2_00);
  local_2198 = CONCAT44(local_2198._4_4_,local_f64);
  local_358 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
  uStack_350 = CONCAT17(uVar62,CONCAT16(uVar60,CONCAT15(uVar58,CONCAT14(uVar57,CONCAT13(uVar61,
                                                  CONCAT12(uVar59,CONCAT11(uVar56,uVar55)))))));
  local_21a0 = CONCAT44(local_21a0._4_4_,param_5);
  local_21c0 = CONCAT44(local_21c0._4_4_,local_f30);
  local_21c8 = CONCAT44(local_21c8._4_4_,local_f2c);
  local_21d8 = CONCAT44(local_21d8._4_4_,local_f28);
  local_21e8 = CONCAT44(local_21e8._4_4_,uVar18);
  local_30c = (undefined1)uVar18;
  local_309 = local_f6a;
  local_30b = local_f6c;
  local_21f0 = CONCAT44(local_21f0._4_4_,uVar19);
  local_2f8 = (undefined1)uVar19;
  local_2f7 = local_f70;
  local_2f5 = local_f6e;
  local_21f8 = CONCAT44(local_21f8._4_4_,uVar27);
  local_2e4 = (undefined1)uVar27;
  local_2e3 = local_f74;
  local_2e1 = local_f72;
  local_2210 = CONCAT44(local_2210._4_4_,local_ed8);
  local_2cc = (undefined4)local_2148;
  local_2230 = CONCAT44(local_2230._4_4_,local_eb8);
  local_2238 = CONCAT44(local_2238._4_4_,uStack_eb4);
  local_294 = 0;
  local_291 = local_f76;
  local_293 = local_f78;
  local_280 = (undefined1)local_21cc;
  local_27d = local_f7a;
  local_27f = local_f7c;
  local_21e0 = CONCAT44(local_21e0._4_4_,uVar12);
  local_26c = (undefined1)uVar12;
  local_269 = local_f7e;
  local_26b = local_f80;
  local_268 = CONCAT44(uVar36,uVar33);
  local_2170 = CONCAT44(local_2170._4_4_,uVar14);
  local_254 = (undefined1)uVar14;
  puVar8 = &local_360;
  local_223c = local_eb0;
  local_2228 = local_ec0;
  local_2220 = uStack_ec8;
  local_2218 = local_ed0;
  local_2208 = uStack_ee0;
  local_2200 = local_ee8;
  local_21b8 = local_f38;
  local_21b0 = local_f40;
  local_21a8 = local_f48;
  local_2190 = local_ef4;
  local_2188 = (code *)local_efc;
  local_2180 = uStack_f08;
  local_2168 = local_e84;
  local_2160 = local_e7c;
  local_2158 = (undefined1 *)local_f10;
  local_2150 = local_e98;
  local_360 = uVar30;
  local_35c = local_f64;
  local_348 = uVar31;
  local_344 = param_5;
  local_340 = local_f48;
  uStack_338 = local_f40;
  local_330 = local_f38;
  local_328 = local_f30;
  local_324 = local_f2c;
  local_320 = local_f28;
  local_31c = uVar9;
  local_314 = uVar10;
  local_308 = local_f10;
  uStack_300 = uStack_f08;
  local_2f4 = local_efc;
  local_2ec = local_ef4;
  local_2e0 = local_ee8;
  uStack_2d8 = uStack_ee0;
  local_2d0 = local_ed8;
  local_2c8 = local_ed0;
  uStack_2c0 = uStack_ec8;
  local_2b8 = local_ec0;
  local_2b0 = local_eb8;
  uStack_2ac = uStack_eb4;
  local_2a8 = local_eb0;
  local_2a4 = CONCAT44(uVar38,uVar32);
  local_29c = uVar15;
  local_290 = local_e98;
  uStack_288 = uVar11;
  local_27c = local_e84;
  local_274 = local_e7c;
  local_260 = uVar34;
  local_25c = uVar37;
  local_258 = uVar29;
  uVar39 = local_21cc;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_46c = (undefined4)local_2198;
    local_454 = (undefined4)local_21a0;
    local_450 = local_21a8;
    uStack_448 = local_21b0;
    local_440 = local_21b8;
    local_438 = (undefined4)local_21c0;
    local_434 = (undefined4)local_21c8;
    local_430 = (undefined4)local_21d8;
    local_41c = (undefined1)local_21e8;
    local_41b = local_f6c;
    local_419 = local_f6a;
    local_418 = local_2158;
    uStack_410 = local_2180;
    local_408 = (undefined1)local_21f0;
    local_407 = local_f70;
    local_405 = local_f6e;
    local_404 = local_2188;
    local_3fc = local_2190;
    local_3f4 = (undefined1)local_21f8;
    local_3f3 = local_f74;
    local_3f1 = local_f72;
    local_3f0 = local_2200;
    uStack_3e8 = local_2208;
    local_3e0 = (undefined4)local_2210;
    local_3dc = (undefined4)local_2148;
    local_3d8 = local_2218;
    uStack_3d0 = local_2220;
    local_3c8 = local_2228;
    local_3c0 = (undefined4)local_2230;
    uStack_3bc = (undefined4)local_2238;
    local_3b8 = local_223c;
    local_3a4 = 0;
    local_3a1 = local_f76;
    local_3a3 = local_f78;
    local_3a0 = local_2150;
    local_390 = (undefined1)local_21cc;
    local_38d = local_f7a;
    local_38f = local_f7c;
    local_38c = local_2168;
    local_384 = local_2160;
    local_37c = (undefined1)local_21e0;
    local_379 = local_f7e;
    local_37b = local_f80;
    local_364 = (undefined1)local_2170;
    local_470 = uVar30;
    local_468 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
    uStack_460 = CONCAT17(uVar62,CONCAT16(uVar60,CONCAT15(uVar58,CONCAT14(uVar57,CONCAT13(uVar61,
                                                  CONCAT12(uVar59,CONCAT11(uVar56,uVar55)))))));
    local_458 = uVar31;
    local_42c = uVar9;
    local_424 = uVar10;
    local_3b4 = CONCAT44(uVar38,uVar32);
    local_3ac = uVar15;
    uStack_398 = uVar11;
    local_378 = CONCAT44(uVar36,uVar33);
    local_370 = uVar34;
    local_36c = uVar37;
    local_368 = uVar29;
    _CGPointMake(&local_470);
    func_0x000198104610(auStack_1090,&local_470,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1090);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1090,0x10d);
  func_0x000198104610(&local_11a0,auStack_1090,0x10d);
  iVar4 = (int)&local_11a0;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    uVar18 = 0;
    local_10b4 = 0;
    local_10bc = 0;
    local_112c = 0;
    local_10e4 = 0;
    local_10dc = 0;
    uVar30 = 0;
    uVar31 = 0;
    local_368 = 0;
    local_36c = 0;
    local_370 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    uVar59 = 0;
    uVar61 = 0;
    local_21cc = 1;
    local_1164 = 0;
    local_1160 = 0;
    uVar12 = 1;
    uVar14 = 1;
    uVar19 = 1;
    local_1120 = 0;
    uStack_1118 = 0;
    local_1110 = 0;
    local_1108 = 0;
    uStack_1100 = 0;
    local_10f8 = 0;
    local_10f0 = 0;
    uStack_10ec = 0;
    local_2148 = CONCAT44(local_2148._4_4_,1);
    local_10e8 = 0;
    uVar9 = 0;
    uVar24 = 0;
    uVar22 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar32 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    uVar38 = 0;
    local_119c = param_5;
    local_1184 = uVar39;
    uVar29 = 0;
  }
  else {
    uVar43 = (undefined1)local_1198;
    uVar45 = (undefined1)((ulong)local_1198 >> 8);
    uVar47 = (undefined1)((ulong)local_1198 >> 0x10);
    uVar49 = (undefined1)((ulong)local_1198 >> 0x18);
    uVar44 = (undefined1)((ulong)local_1198 >> 0x20);
    uVar46 = (undefined1)((ulong)local_1198 >> 0x28);
    uVar48 = (undefined1)((ulong)local_1198 >> 0x30);
    uVar50 = (undefined1)((ulong)local_1198 >> 0x38);
    uVar51 = (undefined1)local_1190;
    uVar52 = (undefined1)((ulong)local_1190 >> 8);
    uVar53 = (undefined1)((ulong)local_1190 >> 0x10);
    uVar54 = (undefined1)((ulong)local_1190 >> 0x18);
    uVar55 = (undefined1)((ulong)local_1190 >> 0x20);
    uVar56 = (undefined1)((ulong)local_1190 >> 0x28);
    uVar59 = (undefined1)((ulong)local_1190 >> 0x30);
    uVar61 = (undefined1)((ulong)local_1190 >> 0x38);
    uVar12 = (uint)local_114c;
    local_11a2 = local_1149;
    local_11a4 = local_114b;
    uVar14 = (uint)local_1138;
    local_11a6 = local_1135;
    local_11a8 = local_1137;
    uVar19 = (uint)local_1124;
    local_11aa = local_1121;
    local_11ac = local_1123;
    local_2150 = CONCAT44(local_2150._4_4_,local_110c);
    local_2148 = CONCAT44(local_2148._4_4_,(uint)local_10d4);
    local_11ae = local_10d1;
    local_11b0 = local_10d3;
    local_11b2 = local_10bd;
    local_11b4 = local_10bf;
    local_21cc = (uint)local_10ac;
    local_11b6 = local_10a9;
    local_11b8 = local_10ab;
    uVar30 = (undefined4)local_10a8;
    uVar31 = (undefined4)((ulong)local_10a8 >> 0x20);
    uVar18 = (uint)local_1094;
    uVar9 = local_1134;
    uVar24 = local_115c;
    uVar22 = local_1154;
    uVar10 = local_1148;
    uVar11 = uStack_1140;
    uVar32 = local_11a0;
    uVar15 = local_1180;
    uVar16 = local_1178;
    uVar17 = local_1170;
    uVar38 = local_1168;
    uVar29 = local_1188;
    local_370 = local_10a0;
    local_36c = local_109c;
    local_368 = local_1098;
  }
  local_2190 = CONCAT44(local_2190._4_4_,local_119c);
  local_468 = CONCAT17(uVar50,CONCAT16(uVar48,CONCAT15(uVar46,CONCAT14(uVar44,CONCAT13(uVar49,
                                                  CONCAT12(uVar47,CONCAT11(uVar45,uVar43)))))));
  uStack_460 = CONCAT17(uVar61,CONCAT16(uVar59,CONCAT15(uVar56,CONCAT14(uVar55,CONCAT13(uVar54,
                                                  CONCAT12(uVar53,CONCAT11(uVar52,uVar51)))))));
  local_2198 = CONCAT44(local_2198._4_4_,local_1184);
  local_21c0 = CONCAT44(local_21c0._4_4_,local_1164);
  local_21c8 = CONCAT44(local_21c8._4_4_,local_1160);
  local_21d8 = CONCAT44(local_21d8._4_4_,uVar12);
  local_41c = (undefined1)uVar12;
  local_419 = local_11a2;
  local_41b = local_11a4;
  local_21e0 = CONCAT44(local_21e0._4_4_,uVar14);
  local_408 = (undefined1)uVar14;
  local_407 = local_11a8;
  local_405 = local_11a6;
  local_21e8 = CONCAT44(local_21e8._4_4_,uVar19);
  local_3f4 = (undefined1)uVar19;
  local_3f3 = local_11ac;
  local_3f1 = local_11aa;
  local_2200 = CONCAT44(local_2200._4_4_,local_1110);
  local_3dc = (undefined4)local_2150;
  local_2220 = CONCAT44(local_2220._4_4_,local_10f0);
  local_2228 = CONCAT44(local_2228._4_4_,uStack_10ec);
  local_2230 = CONCAT44(local_2230._4_4_,local_10e8);
  local_3a4 = (undefined1)local_2148;
  local_3a1 = local_11ae;
  local_3a3 = local_11b0;
  local_3a0 = 0;
  uStack_398 = 0;
  local_390 = 1;
  local_38d = local_11b2;
  local_38f = local_11b4;
  local_37c = (undefined1)local_21cc;
  local_37b = local_11b8;
  local_379 = local_11b6;
  local_21a0 = CONCAT44(uVar31,uVar30);
  local_378 = CONCAT44(uVar31,uVar30);
  local_21b8 = CONCAT44(local_21b8._4_4_,local_370);
  local_21b0 = CONCAT44(local_21b0._4_4_,local_36c);
  local_21a8 = CONCAT44(local_21a8._4_4_,local_368);
  local_2160 = CONCAT44(local_2160._4_4_,uVar18);
  local_364 = (undefined1)uVar18;
  puVar8 = &local_470;
  local_2218 = local_10f8;
  local_2210 = uStack_1100;
  local_2208 = local_1108;
  local_21f8 = uStack_1118;
  local_21f0 = local_1120;
  local_2188 = (code *)local_10dc;
  local_2180 = local_10e4;
  local_2170 = local_112c;
  local_2168 = local_10b4;
  local_2158 = (undefined1 *)local_10bc;
  local_470 = uVar32;
  local_46c = local_119c;
  local_458 = uVar29;
  local_454 = local_1184;
  local_450 = uVar15;
  uStack_448 = uVar16;
  local_440 = uVar17;
  local_438 = uVar38;
  local_434 = local_1164;
  local_430 = local_1160;
  local_42c = uVar24;
  local_424 = uVar22;
  local_418 = uVar10;
  uStack_410 = uVar11;
  local_404 = uVar9;
  local_3fc = local_112c;
  local_3f0 = local_1120;
  uStack_3e8 = uStack_1118;
  local_3e0 = local_1110;
  local_3d8 = local_1108;
  uStack_3d0 = uStack_1100;
  local_3c8 = local_10f8;
  local_3c0 = local_10f0;
  uStack_3bc = uStack_10ec;
  local_3b8 = local_10e8;
  local_3b4 = local_10e4;
  local_3ac = local_10dc;
  local_38c = local_10bc;
  local_384 = local_10b4;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_57c = (undefined4)local_2190;
    local_564 = (undefined4)local_2198;
    local_544 = (undefined4)local_21c0;
    local_540 = (undefined4)local_21c8;
    local_52c = (undefined1)local_21d8;
    local_52b = local_11a4;
    local_529 = local_11a2;
    local_518 = (undefined1)local_21e0;
    local_517 = local_11a8;
    local_515 = local_11a6;
    local_50c = local_2170;
    local_504 = (undefined1)local_21e8;
    local_503 = local_11ac;
    local_501 = local_11aa;
    local_500 = local_21f0;
    uStack_4f8 = local_21f8;
    local_4f0 = (undefined4)local_2200;
    local_4ec = (undefined4)local_2150;
    local_4e8 = local_2208;
    uStack_4e0 = local_2210;
    local_4d8 = local_2218;
    local_4d0 = (undefined4)local_2220;
    uStack_4cc = (undefined4)local_2228;
    local_4c8 = (undefined4)local_2230;
    local_4c4 = local_2180;
    local_4bc = local_2188;
    local_4b4 = (undefined1)local_2148;
    local_4b1 = local_11ae;
    local_4b3 = local_11b0;
    local_4b0 = 0;
    uStack_4a8 = 0;
    local_4a0 = 1;
    local_49d = local_11b2;
    local_49f = local_11b4;
    local_49c = local_2158;
    local_494 = local_2168;
    local_48c = (undefined1)local_21cc;
    local_48b = local_11b8;
    local_489 = local_11b6;
    local_488 = local_21a0;
    local_480 = (undefined4)local_21b8;
    local_47c = (undefined4)local_21b0;
    local_478 = (undefined4)local_21a8;
    local_474 = (undefined1)local_2160;
    local_580 = uVar32;
    local_578 = CONCAT17(uVar50,CONCAT16(uVar48,CONCAT15(uVar46,CONCAT14(uVar44,CONCAT13(uVar49,
                                                  CONCAT12(uVar47,CONCAT11(uVar45,uVar43)))))));
    uStack_570 = CONCAT17(uVar61,CONCAT16(uVar59,CONCAT15(uVar56,CONCAT14(uVar55,CONCAT13(uVar54,
                                                  CONCAT12(uVar53,CONCAT11(uVar52,uVar51)))))));
    local_568 = uVar29;
    local_560 = uVar15;
    local_558 = uVar16;
    local_550 = uVar17;
    local_548 = uVar38;
    local_53c = uVar24;
    local_534 = uVar22;
    local_528 = uVar10;
    uStack_520 = uVar11;
    local_514 = uVar9;
    _CGPointMake(&local_580);
    func_0x000198104610(auStack_12c8,&local_580,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_12c8);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_12c8,0x10d);
  func_0x000198104610(&local_13d8,auStack_12c8,0x10d);
  iVar4 = (int)&local_13d8;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_1364 = 0;
    local_131c = 0;
    local_1314 = 0;
    local_1308 = 0;
    uStack_1300 = 0;
    local_12f4 = 0;
    local_12ec = 0;
    uVar39 = 0;
    uVar30 = 0;
    uVar31 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uStack_1338 = 0;
    uVar12 = 1;
    local_1330 = 0;
    uVar18 = 1;
    uVar14 = 1;
    local_1328 = 0;
    uStack_1324 = 0;
    local_1320 = 0;
    local_2148 = CONCAT44(local_2148._4_4_,1);
    local_2150 = CONCAT44(local_2150._4_4_,1);
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,1);
    local_12e0 = 0;
    local_12d8 = 0;
    local_12d4 = 0;
    local_12d0 = 0;
    local_13d8 = 0;
    local_13d0 = 0;
    local_13c8 = 0;
    local_13c0 = 0;
    local_13b8 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar26 = 0;
    uVar11 = 0;
    uVar15 = 0;
    uVar32 = 0;
    uVar16 = 0;
    uVar17 = 0;
    local_1344 = 0x95f10264;
    uVar38 = 0;
    uVar29 = 0;
  }
  else {
    uVar22 = (ulong)local_13d4;
    uVar24 = (ulong)local_13bc;
    uVar30 = (undefined4)local_13a8;
    uVar31 = (undefined4)((ulong)local_13a8 >> 0x20);
    uVar43 = (undefined1)local_1398;
    uVar45 = (undefined1)((uint)local_1398 >> 8);
    uVar47 = (undefined1)((uint)local_1398 >> 0x10);
    uVar49 = (undefined1)((uint)local_1398 >> 0x18);
    uVar12 = (uint)local_1384;
    local_13dc = local_1383;
    local_13da = local_1381;
    uVar18 = (uint)local_1370;
    local_13de = local_136d;
    local_13e0 = local_136f;
    uVar14 = (uint)local_135c;
    local_13e2 = local_1359;
    local_13e4 = local_135b;
    uVar44 = (undefined1)local_1358;
    uVar46 = (undefined1)((ulong)local_1358 >> 8);
    uVar48 = (undefined1)((ulong)local_1358 >> 0x10);
    uVar50 = (undefined1)((ulong)local_1358 >> 0x18);
    uVar51 = (undefined1)((ulong)local_1358 >> 0x20);
    uVar52 = (undefined1)((ulong)local_1358 >> 0x28);
    uVar53 = (undefined1)((ulong)local_1358 >> 0x30);
    uVar54 = (undefined1)((ulong)local_1358 >> 0x38);
    local_2148 = CONCAT44(local_2148._4_4_,(uint)local_130c);
    local_13e6 = local_1309;
    local_13e8 = local_130b;
    local_2150 = CONCAT44(local_2150._4_4_,(uint)local_12f8);
    local_13ea = local_12f5;
    local_13ec = local_12f7;
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,(uint)local_12e4);
    local_13ee = local_12e1;
    local_13f0 = local_12e3;
    uVar39 = (uint)local_12cc;
    uVar9 = local_1394;
    uVar10 = local_138c;
    uVar26 = local_1380;
    uVar11 = uStack_1378;
    uVar15 = local_136c;
    uVar32 = local_13a0;
    uVar16 = uStack_1350;
    uVar17 = local_1340;
    uVar38 = local_139c;
    uVar29 = local_1348;
  }
  local_21f0 = CONCAT44(local_21f0._4_4_,local_13d8);
  local_57c = (undefined4)uVar22;
  local_21f8 = CONCAT44(local_21f8._4_4_,local_57c);
  local_2210 = CONCAT44(local_2210._4_4_,local_13c0);
  local_564 = (undefined4)uVar24;
  local_2218 = CONCAT44(local_2218._4_4_,local_564);
  local_558 = 1;
  local_550 = CONCAT44(uVar31,uVar30);
  local_540 = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
  local_21a8 = CONCAT44(local_21a8._4_4_,uVar12);
  local_52c = (undefined1)uVar12;
  local_529 = local_13da;
  local_52b = local_13dc;
  local_21b0 = CONCAT44(local_21b0._4_4_,uVar18);
  local_518 = (undefined1)uVar18;
  local_517 = local_13e0;
  local_515 = local_13de;
  local_21c0 = CONCAT44(local_21c0._4_4_,uVar14);
  local_504 = (undefined1)uVar14;
  local_503 = local_13e4;
  local_501 = local_13e2;
  local_500 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
  local_21d8 = CONCAT44(local_21d8._4_4_,local_1328);
  local_21e0 = CONCAT44(local_21e0._4_4_,uStack_1324);
  local_21e8 = CONCAT44(local_21e8._4_4_,local_1320);
  local_4b4 = (undefined1)local_2148;
  local_4b1 = local_13e6;
  local_4b3 = local_13e8;
  local_4a0 = (undefined1)local_2150;
  local_49d = local_13ea;
  local_49f = local_13ec;
  local_48c = SUB81(local_2158,0);
  local_489 = local_13ee;
  local_48b = local_13f0;
  local_2230 = CONCAT44(local_2230._4_4_,local_12d8);
  local_2238 = CONCAT44(local_2238._4_4_,local_12d4);
  local_21a0 = CONCAT44(local_21a0._4_4_,uVar39);
  local_474 = (undefined1)uVar39;
  puVar8 = &local_580;
  local_223c = local_12d0;
  local_2228 = local_12e0;
  local_2220 = local_13b8;
  local_2208 = local_13c8;
  local_2200 = local_13d0;
  local_21cc = local_1344;
  local_21c8 = local_1330;
  local_21b8 = uStack_1338;
  local_2198 = local_12ec;
  local_2190 = local_12f4;
  local_2188 = (code *)uStack_1300;
  local_2180 = local_1308;
  local_2170 = local_1314;
  local_2168 = local_131c;
  local_2160 = local_1364;
  local_580 = local_13d8;
  local_578 = local_13d0;
  uStack_570 = local_13c8;
  local_568 = local_13c0;
  local_560 = local_13b8;
  local_548 = uVar32;
  local_544 = uVar38;
  local_53c = uVar9;
  local_534 = uVar10;
  local_528 = uVar26;
  uStack_520 = uVar11;
  local_514 = uVar15;
  local_50c = local_1364;
  uStack_4f8 = uVar16;
  local_4f0 = uVar29;
  local_4ec = local_1344;
  local_4e8 = uVar17;
  uStack_4e0 = uStack_1338;
  local_4d8 = local_1330;
  local_4d0 = local_1328;
  uStack_4cc = uStack_1324;
  local_4c8 = local_1320;
  local_4c4 = local_131c;
  local_4bc = local_1314;
  local_4b0 = local_1308;
  uStack_4a8 = uStack_1300;
  local_49c = local_12f4;
  local_494 = local_12ec;
  local_488 = local_12e0;
  local_480 = local_12d8;
  local_47c = local_12d4;
  local_478 = local_12d0;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_690 = (undefined4)local_21f0;
    local_68c = (undefined4)local_21f8;
    local_688 = local_2200;
    uStack_680 = local_2208;
    local_678 = (undefined4)local_2210;
    local_674 = (undefined4)local_2218;
    local_670 = local_2220;
    local_668 = 1;
    local_63c = (undefined1)local_21a8;
    local_63b = local_13dc;
    local_639 = local_13da;
    local_628 = (undefined1)local_21b0;
    local_625 = local_13de;
    local_627 = local_13e0;
    local_61c = local_2160;
    local_614 = (undefined1)local_21c0;
    local_611 = local_13e2;
    local_613 = local_13e4;
    local_5fc = local_21cc;
    uStack_5f0 = local_21b8;
    local_5e8 = local_21c8;
    local_5e0 = (undefined4)local_21d8;
    uStack_5dc = (undefined4)local_21e0;
    local_5d8 = (undefined4)local_21e8;
    local_5d4 = local_2168;
    local_5cc = local_2170;
    local_5c4 = (undefined1)local_2148;
    local_5c1 = local_13e6;
    local_5c3 = local_13e8;
    local_5c0 = local_2180;
    uStack_5b8 = local_2188;
    local_5b0 = (undefined1)local_2150;
    local_5ad = local_13ea;
    local_5af = local_13ec;
    local_5ac = local_2190;
    local_5a4 = local_2198;
    local_59c = SUB81(local_2158,0);
    local_599 = local_13ee;
    local_59b = local_13f0;
    local_598 = local_2228;
    local_590 = (undefined4)local_2230;
    local_58c = (undefined4)local_2238;
    local_588 = local_223c;
    local_584 = (undefined1)local_21a0;
    local_660 = CONCAT44(uVar31,uVar30);
    local_658 = uVar32;
    local_654 = uVar38;
    local_650 = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
    local_64c = uVar9;
    local_644 = uVar10;
    local_638 = uVar26;
    uStack_630 = uVar11;
    local_624 = uVar15;
    local_610 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
    uStack_608 = uVar16;
    local_600 = uVar29;
    local_5f8 = uVar17;
    _CGPointMake(&local_690);
    func_0x000198104610(auStack_1500,&local_690,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1500);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1500,0x10d);
  func_0x000198104610(&local_1610,auStack_1500,0x10d);
  iVar4 = (int)&local_1610;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_159c = 0;
    local_1554 = 0;
    local_154c = 0;
    local_1540 = 0;
    uStack_1538 = 0;
    local_152c = 0;
    local_1524 = 0;
    uVar39 = 0;
    uVar29 = 0;
    uVar30 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    local_1580 = 0;
    uVar18 = 1;
    local_1578 = 0;
    uVar14 = 1;
    local_21cc = 1;
    uStack_1570 = 0;
    local_1568 = 0;
    local_1560 = 0;
    uStack_155c = 0;
    local_1558 = 0;
    local_2148 = CONCAT44(local_2148._4_4_,1);
    local_2150 = CONCAT44(local_2150._4_4_,1);
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,1);
    local_1518 = 0;
    local_1510 = 0;
    local_150c = 0;
    local_1508 = 0;
    local_1610 = 0;
    local_1608 = 0;
    local_1600 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar24 = 0;
    uVar22 = 0;
    uVar11 = 0;
    uVar32 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    local_15f4 = uVar12;
    uVar38 = 0;
  }
  else {
    uVar26 = (ulong)local_160c;
    uVar29 = (undefined4)local_15f0;
    uVar30 = (undefined4)((ulong)local_15f0 >> 0x20);
    uVar43 = (undefined1)local_15e0;
    uVar45 = (undefined1)((ulong)local_15e0 >> 8);
    uVar47 = (undefined1)((ulong)local_15e0 >> 0x10);
    uVar49 = (undefined1)((ulong)local_15e0 >> 0x18);
    uVar44 = (undefined1)((ulong)local_15e0 >> 0x20);
    uVar46 = (undefined1)((ulong)local_15e0 >> 0x28);
    uVar48 = (undefined1)((ulong)local_15e0 >> 0x30);
    uVar50 = (undefined1)((ulong)local_15e0 >> 0x38);
    uVar51 = (undefined1)local_15d4;
    uVar52 = (undefined1)((uint)local_15d4 >> 8);
    uVar53 = (undefined1)((uint)local_15d4 >> 0x10);
    uVar54 = (undefined1)((uint)local_15d4 >> 0x18);
    uVar18 = (uint)local_15bc;
    local_1614 = local_15bb;
    local_1612 = local_15b9;
    uVar14 = (uint)local_15a8;
    local_1616 = local_15a5;
    local_1618 = local_15a7;
    local_21cc = (uint)local_1594;
    local_161a = local_1591;
    local_161c = local_1593;
    local_2160 = CONCAT44(local_2160._4_4_,local_157c);
    local_2148 = CONCAT44(local_2148._4_4_,(uint)local_1544);
    local_161e = local_1541;
    local_1620 = local_1543;
    local_2150 = CONCAT44(local_2150._4_4_,(uint)local_1530);
    local_1622 = local_152d;
    local_1624 = local_152f;
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,(uint)local_151c);
    local_1626 = local_1519;
    local_1628 = local_151b;
    uVar39 = (uint)local_1504;
    uVar9 = local_15cc;
    uVar10 = local_15c4;
    uVar24 = local_15b8;
    uVar22 = uStack_15b0;
    uVar11 = local_15a4;
    uVar32 = local_15d8;
    uVar15 = local_1590;
    uVar16 = uStack_1588;
    uVar17 = local_15e8;
    uVar38 = local_15d0;
  }
  local_2208 = CONCAT44(local_2208._4_4_,local_1610);
  local_68c = (undefined4)uVar26;
  local_2210 = CONCAT44(local_2210._4_4_,local_68c);
  local_678 = 0.9f;
  local_21b0 = CONCAT44(local_21b0._4_4_,local_15f4);
  local_670 = CONCAT44(uVar30,uVar29);
  local_660 = CONCAT17(uVar50,CONCAT16(uVar48,CONCAT15(uVar46,CONCAT14(uVar44,CONCAT13(uVar49,
                                                  CONCAT12(uVar47,CONCAT11(uVar45,uVar43)))))));
  local_654 = CONCAT13(uVar54,CONCAT12(uVar53,CONCAT11(uVar52,uVar51)));
  local_21b8 = CONCAT44(local_21b8._4_4_,uVar18);
  local_63c = (undefined1)uVar18;
  local_639 = local_1612;
  local_63b = local_1614;
  local_21c8 = CONCAT44(local_21c8._4_4_,uVar14);
  local_628 = (undefined1)uVar14;
  local_627 = local_1618;
  local_625 = local_1616;
  local_614 = (undefined1)local_21cc;
  local_613 = local_161c;
  local_611 = local_161a;
  local_21c0 = CONCAT44(local_21c0._4_4_,local_1580);
  local_5fc = (undefined4)local_2160;
  local_21f0 = CONCAT44(local_21f0._4_4_,local_1560);
  local_21f8 = CONCAT44(local_21f8._4_4_,uStack_155c);
  local_2200 = CONCAT44(local_2200._4_4_,local_1558);
  local_5c4 = (undefined1)local_2148;
  local_5c1 = local_161e;
  local_5c3 = local_1620;
  local_5b0 = (undefined1)local_2150;
  local_5ad = local_1622;
  local_5af = local_1624;
  local_59c = SUB81(local_2158,0);
  local_599 = local_1626;
  local_59b = local_1628;
  local_2230 = CONCAT44(local_2230._4_4_,local_1510);
  local_2238 = CONCAT44(local_2238._4_4_,local_150c);
  local_21a8 = CONCAT44(local_21a8._4_4_,uVar39);
  local_584 = (undefined1)uVar39;
  puVar8 = &local_690;
  local_223c = local_1508;
  local_2228 = local_1518;
  local_2220 = local_1600;
  local_2218 = local_1608;
  local_21e8 = local_1568;
  local_21e0 = uStack_1570;
  local_21d8 = local_1578;
  local_21a0 = local_1524;
  local_2198 = local_152c;
  local_2190 = uStack_1538;
  local_2188 = (code *)local_1540;
  local_2180 = local_154c;
  local_2170 = local_1554;
  local_2168 = local_159c;
  local_690 = local_1610;
  local_688 = local_1608;
  uStack_680 = local_1600;
  local_674 = local_15f4;
  local_668 = uVar17;
  local_658 = uVar32;
  local_650 = uVar38;
  local_64c = uVar9;
  local_644 = uVar10;
  local_638 = uVar24;
  uStack_630 = uVar22;
  local_624 = uVar11;
  local_61c = local_159c;
  local_610 = uVar15;
  uStack_608 = uVar16;
  local_600 = local_1580;
  local_5f8 = local_1578;
  uStack_5f0 = uStack_1570;
  local_5e8 = local_1568;
  local_5e0 = local_1560;
  uStack_5dc = uStack_155c;
  local_5d8 = local_1558;
  local_5d4 = local_1554;
  local_5cc = local_154c;
  local_5c0 = local_1540;
  uStack_5b8 = uStack_1538;
  local_5ac = local_152c;
  local_5a4 = local_1524;
  local_598 = local_1518;
  local_590 = local_1510;
  local_58c = local_150c;
  local_588 = local_1508;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_7a0 = (undefined4)local_2208;
    local_79c = (undefined4)local_2210;
    local_798 = local_2218;
    uStack_790 = local_2220;
    local_788 = 0.9f;
    local_784 = (undefined4)local_21b0;
    local_74c = (undefined1)local_21b8;
    local_74b = local_1614;
    local_749 = local_1612;
    local_738 = (undefined1)local_21c8;
    local_735 = local_1616;
    local_737 = local_1618;
    local_72c = local_2168;
    local_724 = (undefined1)local_21cc;
    local_721 = local_161a;
    local_723 = local_161c;
    local_710 = (undefined4)local_21c0;
    local_70c = (undefined4)local_2160;
    local_708 = local_21d8;
    uStack_700 = local_21e0;
    local_6f8 = local_21e8;
    local_6f0 = (undefined4)local_21f0;
    uStack_6ec = (undefined4)local_21f8;
    local_6e8 = (undefined4)local_2200;
    local_6e4 = local_2170;
    local_6dc = local_2180;
    local_6d4 = (undefined1)local_2148;
    local_6d1 = local_161e;
    local_6d3 = local_1620;
    local_6d0 = local_2188;
    uStack_6c8 = local_2190;
    local_6c0 = (undefined1)local_2150;
    local_6bd = local_1622;
    local_6bf = local_1624;
    local_6bc = local_2198;
    local_6b4 = local_21a0;
    local_6ac = SUB81(local_2158,0);
    local_6a9 = local_1626;
    local_6ab = local_1628;
    local_6a8 = local_2228;
    local_6a0 = (undefined4)local_2230;
    local_69c = (undefined4)local_2238;
    local_698 = local_223c;
    local_694 = (undefined1)local_21a8;
    local_780 = CONCAT44(uVar30,uVar29);
    local_778 = uVar17;
    local_770 = CONCAT17(uVar50,CONCAT16(uVar48,CONCAT15(uVar46,CONCAT14(uVar44,CONCAT13(uVar49,
                                                  CONCAT12(uVar47,CONCAT11(uVar45,uVar43)))))));
    local_768 = uVar32;
    local_764 = CONCAT13(uVar54,CONCAT12(uVar53,CONCAT11(uVar52,uVar51)));
    local_760 = uVar38;
    local_75c = uVar9;
    local_754 = uVar10;
    local_748 = uVar24;
    uStack_740 = uVar22;
    local_734 = uVar11;
    local_720 = uVar15;
    uStack_718 = uVar16;
    _CGPointMake(&local_7a0);
    func_0x000198104610(auStack_1738,&local_7a0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1738);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1738,0x10d);
  func_0x000198104610(&local_1848,auStack_1738,0x10d);
  iVar4 = (int)&local_1848;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_17d4 = 0;
    local_178c = 0;
    local_1784 = 0;
    local_1778 = 0;
    uStack_1770 = 0;
    local_1764 = 0;
    local_175c = 0;
    uVar18 = 0;
    uVar29 = 0;
    uVar30 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    local_17b0 = 0;
    uVar39 = 1;
    uStack_17a8 = 0;
    uVar12 = 1;
    uVar14 = 1;
    local_17a0 = 0;
    local_1798 = 0;
    uStack_1794 = 0;
    local_1790 = 0;
    local_2148 = CONCAT44(local_2148._4_4_,1);
    local_2150 = CONCAT44(local_2150._4_4_,1);
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,1);
    local_1750 = 0;
    local_1748 = 0;
    local_1744 = 0;
    local_1740 = 0;
    local_1848 = 0;
    local_1840 = 0;
    local_1838 = 0;
    local_1830 = 0;
    uVar9 = 0;
    uVar26 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar15 = 0;
    uVar32 = 0;
    uVar16 = 0;
    uVar17 = 0;
    local_17b4 = 0x95f10cd0;
    uVar63 = 0;
    uVar38 = 0;
  }
  else {
    uVar24 = (ulong)local_1844;
    uVar22 = (ulong)local_182c;
    uVar29 = (undefined4)local_1820;
    uVar30 = (undefined4)((ulong)local_1820 >> 0x20);
    uVar43 = (undefined1)local_180c;
    uVar45 = (undefined1)((uint)local_180c >> 8);
    uVar47 = (undefined1)((uint)local_180c >> 0x10);
    uVar49 = (undefined1)((uint)local_180c >> 0x18);
    uVar44 = (undefined1)local_1808;
    uVar46 = (undefined1)((uint)local_1808 >> 8);
    uVar48 = (undefined1)((uint)local_1808 >> 0x10);
    uVar50 = (undefined1)((uint)local_1808 >> 0x18);
    uVar39 = (uint)local_17f4;
    local_184c = local_17f3;
    local_184a = local_17f1;
    uVar12 = (uint)local_17e0;
    local_184e = local_17dd;
    local_1850 = local_17df;
    uVar14 = (uint)local_17cc;
    local_1852 = local_17c9;
    local_1854 = local_17cb;
    local_2148 = CONCAT44(local_2148._4_4_,(uint)local_177c);
    local_1856 = local_1779;
    local_1858 = local_177b;
    local_2150 = CONCAT44(local_2150._4_4_,(uint)local_1768);
    local_185a = local_1765;
    local_185c = local_1767;
    local_2158 = (undefined1 *)CONCAT44(local_2158._4_4_,(uint)local_1754);
    local_185e = local_1751;
    local_1860 = local_1753;
    uVar18 = (uint)local_173c;
    uVar9 = local_1804;
    uVar26 = local_17fc;
    uVar10 = local_17f0;
    uVar11 = uStack_17e8;
    uVar15 = local_17dc;
    uVar32 = local_1810;
    uVar16 = local_17c8;
    uVar17 = uStack_17c0;
    uVar63 = local_1818;
    uVar38 = local_17b8;
  }
  local_21f8 = CONCAT44(local_21f8._4_4_,local_1848);
  local_79c = (undefined4)uVar24;
  local_2200 = CONCAT44(local_2200._4_4_,local_79c);
  local_2220 = CONCAT44(local_2220._4_4_,local_1830);
  local_784 = (undefined4)uVar22;
  local_2218 = CONCAT44(local_2218._4_4_,local_784);
  local_780 = 1.309;
  local_778 = CONCAT44(uVar30,uVar29);
  local_764 = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
  local_760 = CONCAT13(uVar50,CONCAT12(uVar48,CONCAT11(uVar46,uVar44)));
  local_21a8 = CONCAT44(local_21a8._4_4_,uVar39);
  local_74c = (undefined1)uVar39;
  local_749 = local_184a;
  local_74b = local_184c;
  local_21b0 = CONCAT44(local_21b0._4_4_,uVar12);
  local_738 = (undefined1)uVar12;
  local_737 = local_1850;
  local_735 = local_184e;
  local_21c0 = CONCAT44(local_21c0._4_4_,uVar14);
  local_724 = (undefined1)uVar14;
  local_723 = local_1854;
  local_721 = local_1852;
  local_21e0 = CONCAT44(local_21e0._4_4_,local_1798);
  local_21e8 = CONCAT44(local_21e8._4_4_,uStack_1794);
  local_21f0 = CONCAT44(local_21f0._4_4_,local_1790);
  local_6d4 = (undefined1)local_2148;
  local_6d1 = local_1856;
  local_6d3 = local_1858;
  local_6c0 = (undefined1)local_2150;
  local_6bd = local_185a;
  local_6bf = local_185c;
  local_6ac = SUB81(local_2158,0);
  local_6a9 = local_185e;
  local_6ab = local_1860;
  local_2230 = CONCAT44(local_2230._4_4_,local_1748);
  local_2238 = CONCAT44(local_2238._4_4_,local_1744);
  local_21a0 = CONCAT44(local_21a0._4_4_,uVar18);
  local_694 = (undefined1)uVar18;
  puVar8 = &local_7a0;
  local_223c = local_1740;
  local_2228 = local_1750;
  local_2210 = local_1838;
  local_2208 = local_1840;
  local_21d8 = local_17a0;
  local_21cc = local_17b4;
  local_21c8 = uStack_17a8;
  local_21b8 = local_17b0;
  local_2198 = local_175c;
  local_2190 = local_1764;
  local_2188 = (code *)uStack_1770;
  local_2180 = local_1778;
  local_2170 = local_1784;
  local_2168 = local_178c;
  local_2160 = local_17d4;
  local_7a0 = local_1848;
  local_798 = local_1840;
  uStack_790 = local_1838;
  local_788 = local_1830;
  local_770 = uVar63;
  local_768 = uVar32;
  local_75c = uVar9;
  local_754 = uVar26;
  local_748 = uVar10;
  uStack_740 = uVar11;
  local_734 = uVar15;
  local_72c = local_17d4;
  local_720 = uVar16;
  uStack_718 = uVar17;
  local_710 = uVar38;
  local_70c = local_17b4;
  local_708 = local_17b0;
  uStack_700 = uStack_17a8;
  local_6f8 = local_17a0;
  local_6f0 = local_1798;
  uStack_6ec = uStack_1794;
  local_6e8 = local_1790;
  local_6e4 = local_178c;
  local_6dc = local_1784;
  local_6d0 = local_1778;
  uStack_6c8 = uStack_1770;
  local_6bc = local_1764;
  local_6b4 = local_175c;
  local_6a8 = local_1750;
  local_6a0 = local_1748;
  local_69c = local_1744;
  local_698 = local_1740;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_8b0 = (undefined4)local_21f8;
    local_8ac = (undefined4)local_2200;
    local_8a8 = local_2208;
    uStack_8a0 = local_2210;
    local_898 = (undefined4)local_2220;
    local_894 = (undefined4)local_2218;
    local_890 = 1.309;
    local_85c = (undefined1)local_21a8;
    local_85b = local_184c;
    local_859 = local_184a;
    local_848 = (undefined1)local_21b0;
    local_845 = local_184e;
    local_847 = local_1850;
    local_83c = local_2160;
    local_834 = (undefined1)local_21c0;
    local_831 = local_1852;
    local_833 = local_1854;
    local_81c = local_21cc;
    local_818 = local_21b8;
    local_810 = local_21c8;
    local_808 = local_21d8;
    local_800 = (undefined4)local_21e0;
    uStack_7fc = (undefined4)local_21e8;
    local_7f8 = (undefined4)local_21f0;
    local_7f4 = local_2168;
    local_7ec = local_2170;
    local_7e4 = (undefined1)local_2148;
    local_7e1 = local_1856;
    local_7e3 = local_1858;
    local_7e0 = local_2180;
    uStack_7d8 = local_2188;
    local_7d0 = (undefined1)local_2150;
    local_7cd = local_185a;
    local_7cf = local_185c;
    local_7cc = local_2190;
    local_7c4 = local_2198;
    local_7bc = SUB81(local_2158,0);
    local_7b9 = local_185e;
    local_7bb = local_1860;
    local_7b8 = local_2228;
    local_7b0 = (undefined4)local_2230;
    local_7ac = (undefined4)local_2238;
    local_7a8 = local_223c;
    local_7a4 = (undefined1)local_21a0;
    local_888 = CONCAT44(uVar30,uVar29);
    local_880 = uVar63;
    local_878 = uVar32;
    local_874 = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
    local_870 = CONCAT13(uVar50,CONCAT12(uVar48,CONCAT11(uVar46,uVar44)));
    local_86c = uVar9;
    local_864 = uVar26;
    local_858 = uVar10;
    uStack_850 = uVar11;
    local_844 = uVar15;
    local_830 = uVar16;
    uStack_828 = uVar17;
    local_820 = uVar38;
    _CGPointMake(&local_8b0);
    func_0x000198104610(auStack_1970,&local_8b0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1970);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1970,0x10d);
  func_0x000198104610(&local_1a80,auStack_1970,0x10d);
  iVar4 = (int)&local_1a80;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    uVar14 = 0;
    local_1a3c = 0;
    local_1a34 = 0;
    local_1a28 = 0;
    uStack_1a20 = 0;
    local_1a14 = 0;
    local_1a0c = 0;
    uVar34 = 0;
    uVar37 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    local_8b0 = 0;
    uVar28 = 1;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar23 = 1;
    uVar18 = 1;
    local_1a70 = 0;
    local_1a68 = 0;
    local_1a60 = 0;
    local_1a58 = 0;
    local_1a50 = 0;
    local_1a48 = 0;
    local_1a44 = 0;
    local_1a40 = 0;
    uVar19 = 1;
    uVar27 = 1;
    uVar21 = 1;
    local_1a00 = 0;
    uStack_19f8 = 0;
    local_19f0 = 0;
    local_19e8 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    uVar32 = 0;
    uVar63 = 0;
    uVar38 = 0;
    uVar29 = 0;
    uVar30 = 0;
    uVar31 = 0;
  }
  else {
    uVar44 = (undefined1)local_1a78;
    uVar46 = (undefined1)((ulong)local_1a78 >> 8);
    uVar48 = (undefined1)((ulong)local_1a78 >> 0x10);
    uVar50 = (undefined1)((ulong)local_1a78 >> 0x18);
    uVar51 = (undefined1)((ulong)local_1a78 >> 0x20);
    uVar52 = (undefined1)((ulong)local_1a78 >> 0x28);
    uVar53 = (undefined1)((ulong)local_1a78 >> 0x30);
    uVar54 = (undefined1)((ulong)local_1a78 >> 0x38);
    uVar19 = (uint)local_1a2c;
    local_1a82 = local_1a29;
    local_1a84 = local_1a2b;
    uVar27 = (uint)local_1a18;
    local_1a86 = local_1a15;
    local_1a88 = local_1a17;
    uVar21 = (uint)local_1a04;
    local_1a8a = local_1a01;
    local_1a8c = local_1a03;
    uVar26 = (ulong)local_19ec;
    uVar18 = (uint)local_19b4;
    local_1a8e = local_19b1;
    local_1a90 = local_19b3;
    uVar23 = (uint)local_19a0;
    local_1a92 = local_199d;
    local_1a94 = local_199f;
    uVar28 = (uint)local_198c;
    local_1a96 = local_1989;
    local_1a98 = local_198b;
    uVar34 = (undefined4)local_1988;
    uVar37 = (undefined4)((ulong)local_1988 >> 0x20);
    uVar43 = (undefined1)local_197c;
    uVar45 = (undefined1)((uint)local_197c >> 8);
    uVar47 = (undefined1)((uint)local_197c >> 0x10);
    uVar49 = (undefined1)((uint)local_197c >> 0x18);
    uVar14 = (uint)local_1974;
    uVar9 = local_1994;
    uVar10 = local_199c;
    uVar11 = local_19bc;
    uVar15 = local_19c4;
    uVar16 = uStack_19a8;
    uVar17 = local_19b0;
    uVar32 = local_1978;
    uVar63 = local_19d8;
    uVar38 = local_19d0;
    uVar39 = local_1a7c;
    uVar12 = local_1a64;
    local_8b0 = local_1a80;
    uVar29 = uStack_19cc;
    uVar30 = local_19c8;
    uVar31 = local_1980;
  }
  local_2190 = CONCAT44(local_2190._4_4_,local_8b0);
  local_2188 = (code *)CONCAT44(local_2188._4_4_,uVar39);
  local_2198 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
  local_8a8 = CONCAT17(uVar54,CONCAT16(uVar53,CONCAT15(uVar52,CONCAT14(uVar51,CONCAT13(uVar50,
                                                  CONCAT12(uVar48,CONCAT11(uVar46,uVar44)))))));
  local_21a0 = CONCAT44(local_21a0._4_4_,local_1a68);
  local_21b0 = CONCAT44(local_21b0._4_4_,uVar12);
  local_21d8 = CONCAT44(local_21d8._4_4_,local_1a44);
  local_21e0 = CONCAT44(local_21e0._4_4_,local_1a40);
  local_2200 = CONCAT44(local_2200._4_4_,uVar19);
  local_85c = (undefined1)uVar19;
  local_859 = local_1a82;
  local_85b = local_1a84;
  local_2208 = CONCAT44(local_2208._4_4_,uVar27);
  local_848 = (undefined1)uVar27;
  local_847 = local_1a88;
  local_845 = local_1a86;
  local_2210 = CONCAT44(local_2210._4_4_,uVar21);
  local_834 = (undefined1)uVar21;
  local_833 = local_1a8c;
  local_831 = local_1a8a;
  local_2228 = CONCAT44(local_2228._4_4_,local_19f0);
  local_81c = (undefined4)uVar26;
  local_2230 = CONCAT44(local_2230._4_4_,local_81c);
  local_810 = 1;
  local_21e8 = CONCAT44(local_21e8._4_4_,uVar18);
  local_7e4 = (undefined1)uVar18;
  local_7e1 = local_1a8e;
  local_7e3 = local_1a90;
  local_21f8 = CONCAT44(local_21f8._4_4_,uVar23);
  local_7d0 = (undefined1)uVar23;
  local_7cd = local_1a92;
  local_7cf = local_1a94;
  local_21f0 = CONCAT44(local_21f0._4_4_,uVar28);
  local_7bc = (undefined1)uVar28;
  local_7b9 = local_1a96;
  local_7bb = local_1a98;
  local_7b8 = CONCAT44(uVar37,uVar34);
  local_7ac = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
  local_2170 = CONCAT44(local_2170._4_4_,uVar14);
  local_7a4 = (undefined1)uVar14;
  puVar8 = &local_8b0;
  local_2238 = local_19e8;
  local_2220 = uStack_19f8;
  local_2218 = local_1a00;
  local_21cc = local_1a48;
  local_21c8 = local_1a50;
  local_21c0 = local_1a58;
  local_21b8 = local_1a60;
  local_21a8 = local_1a70;
  local_2180 = local_1a0c;
  local_2168 = local_1a14;
  local_2160 = local_1a28;
  local_2158 = (undefined1 *)local_1a34;
  local_2150 = uStack_1a20;
  local_2148 = local_1a3c;
  local_8ac = uVar39;
  uStack_8a0 = local_1a70;
  local_898 = local_1a68;
  local_894 = uVar12;
  local_890 = local_1a60;
  local_888 = local_1a58;
  local_880 = local_1a50;
  local_878 = local_1a48;
  local_874 = local_1a44;
  local_870 = local_1a40;
  local_86c = local_1a3c;
  local_864 = local_1a34;
  local_858 = local_1a28;
  uStack_850 = uStack_1a20;
  local_844 = local_1a14;
  local_83c = local_1a0c;
  local_830 = local_1a00;
  uStack_828 = uStack_19f8;
  local_820 = local_19f0;
  local_818 = local_19e8;
  local_808 = uVar63;
  local_800 = uVar38;
  uStack_7fc = uVar29;
  local_7f8 = uVar30;
  local_7f4 = uVar15;
  local_7ec = uVar11;
  local_7e0 = uVar17;
  uStack_7d8 = uVar16;
  local_7cc = uVar10;
  local_7c4 = uVar9;
  local_7b0 = uVar31;
  local_7a8 = uVar32;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_9c0 = (undefined4)local_2190;
    local_9bc = local_2188._0_4_;
    local_9b8 = local_2198;
    uStack_9b0 = local_21a8;
    local_9a8 = (undefined4)local_21a0;
    local_9a4 = (undefined4)local_21b0;
    local_9a0 = local_21b8;
    uStack_998 = local_21c0;
    local_990 = local_21c8;
    local_988 = local_21cc;
    local_984 = (undefined4)local_21d8;
    local_980 = (undefined4)local_21e0;
    local_97c = local_2148;
    local_974 = local_2158;
    local_96c = (undefined1)local_2200;
    local_96b = local_1a84;
    local_969 = local_1a82;
    local_968 = local_2160;
    uStack_960 = local_2150;
    local_958 = (undefined1)local_2208;
    local_955 = local_1a86;
    local_957 = local_1a88;
    local_954 = local_2168;
    local_94c = local_2180;
    local_944 = (undefined1)local_2210;
    local_941 = local_1a8a;
    local_943 = local_1a8c;
    local_940 = local_2218;
    uStack_938 = local_2220;
    local_930 = (undefined4)local_2228;
    local_92c = (undefined4)local_2230;
    local_928 = local_2238;
    local_920 = 1;
    local_8f4 = (undefined1)local_21e8;
    local_8f1 = local_1a8e;
    local_8f3 = local_1a90;
    local_8e0 = (undefined1)local_21f8;
    local_8dd = local_1a92;
    local_8df = local_1a94;
    local_8cc = (undefined1)local_21f0;
    local_8c9 = local_1a96;
    local_8cb = local_1a98;
    local_8b4 = (undefined1)local_2170;
    local_918 = uVar63;
    local_910 = uVar38;
    uStack_90c = uVar29;
    local_908 = uVar30;
    local_904 = uVar15;
    local_8fc = uVar11;
    local_8f0 = uVar17;
    uStack_8e8 = uVar16;
    local_8dc = uVar10;
    local_8d4 = uVar9;
    local_8c8 = CONCAT44(uVar37,uVar34);
    local_8c0 = uVar31;
    local_8bc = CONCAT13(uVar49,CONCAT12(uVar47,CONCAT11(uVar45,uVar43)));
    local_8b8 = uVar32;
    _CGPointMake(&local_9c0);
    func_0x000198104610(auStack_1ba8,&local_9c0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1ba8);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1ba8,0x10d);
  func_0x000198104610(&local_1cb8,auStack_1ba8,0x10d);
  iVar4 = (int)&local_1cb8;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_1c74 = 0;
    local_1c6c = 0;
    local_1c60 = 0;
    uStack_1c58 = 0;
    local_1c4c = 0;
    local_1c44 = 0;
    uVar30 = 0;
    uVar31 = 0;
    uVar45 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar55 = 0;
    local_1bb4 = 0;
    uVar14 = 1;
    local_1bb0 = 0;
    uVar23 = 1;
    uVar28 = 1;
    local_9c0 = 0;
    local_1cb0 = 0;
    local_1ca8 = 0;
    local_1ca0 = 0;
    local_1c98 = 0;
    local_1c90 = 0;
    local_1c88 = 0;
    local_1c80 = 0;
    local_1c7c = 0;
    local_1c78 = 0;
    uVar19 = 1;
    uVar27 = 1;
    uVar21 = 1;
    local_1c38 = 0;
    uStack_1c30 = 0;
    uVar9 = 0;
    uVar24 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar32 = 0;
    uVar17 = 0;
    uVar38 = 0;
    uVar63 = 0;
    local_1cb4 = uVar39;
    uVar29 = 0;
    uVar43 = 0;
  }
  else {
    uVar19 = (uint)local_1c64;
    local_1cba = local_1c61;
    local_1cbc = local_1c63;
    uVar27 = (uint)local_1c50;
    local_1cbe = local_1c4d;
    local_1cc0 = local_1c4f;
    uVar21 = (uint)local_1c3c;
    local_1cc2 = local_1c39;
    local_1cc4 = local_1c3b;
    uVar30 = (undefined4)local_1c20;
    uVar31 = (undefined4)((ulong)local_1c20 >> 0x20);
    uVar45 = (undefined1)local_1c10;
    uVar47 = (undefined1)((ulong)local_1c10 >> 8);
    uVar49 = (undefined1)((ulong)local_1c10 >> 0x10);
    uVar44 = (undefined1)((ulong)local_1c10 >> 0x18);
    uVar46 = (undefined1)((ulong)local_1c10 >> 0x20);
    uVar48 = (undefined1)((ulong)local_1c10 >> 0x28);
    uVar50 = (undefined1)((ulong)local_1c10 >> 0x30);
    uVar51 = (undefined1)((ulong)local_1c10 >> 0x38);
    uVar52 = (undefined1)uStack_1c04;
    uVar53 = (undefined1)((uint)uStack_1c04 >> 8);
    uVar54 = (undefined1)((uint)uStack_1c04 >> 0x10);
    uVar55 = (undefined1)((uint)uStack_1c04 >> 0x18);
    uVar14 = (uint)local_1bec;
    local_1cc6 = local_1be9;
    local_1cc8 = local_1beb;
    uVar23 = (uint)local_1bd8;
    local_1cca = local_1bd5;
    local_1ccc = local_1bd7;
    uVar28 = (uint)local_1bc4;
    local_1cce = local_1bc1;
    local_1cd0 = local_1bc3;
    uVar9 = local_1bd4;
    uVar24 = local_1bcc;
    uVar10 = local_1bfc;
    uVar11 = local_1bf4;
    uVar15 = local_1be8;
    uVar16 = uStack_1be0;
    uVar32 = local_1c08;
    uVar17 = local_1bc0;
    uVar38 = local_1bb8;
    uVar63 = uStack_1c18;
    uVar18 = local_1c9c;
    uVar12 = local_1c24;
    local_9c0 = local_1cb8;
    uVar29 = local_1c00;
    uVar43 = local_1bac;
  }
  local_2188 = (code *)CONCAT44(local_2188._4_4_,local_9c0);
  local_2180 = CONCAT44(local_2180._4_4_,local_1cb4);
  local_2198 = CONCAT44(local_2198._4_4_,local_1ca0);
  local_21a0 = CONCAT44(local_21a0._4_4_,uVar18);
  local_21e0 = CONCAT44(local_21e0._4_4_,local_1c7c);
  local_21f8 = CONCAT44(local_21f8._4_4_,local_1c78);
  local_2210 = CONCAT44(local_2210._4_4_,uVar19);
  local_96c = (undefined1)uVar19;
  local_969 = local_1cba;
  local_96b = local_1cbc;
  local_2218 = CONCAT44(local_2218._4_4_,uVar27);
  local_958 = (undefined1)uVar27;
  local_957 = local_1cc0;
  local_955 = local_1cbe;
  local_2220 = CONCAT44(local_2220._4_4_,uVar21);
  local_944 = (undefined1)uVar21;
  local_943 = local_1cc4;
  local_941 = local_1cc2;
  local_930 = 0.7f;
  local_2190 = CONCAT44(local_2190._4_4_,uVar12);
  local_928 = CONCAT44(uVar31,uVar30);
  local_918 = CONCAT17(uVar51,CONCAT16(uVar50,CONCAT15(uVar48,CONCAT14(uVar46,CONCAT13(uVar44,
                                                  CONCAT12(uVar49,CONCAT11(uVar47,uVar45)))))));
  uStack_90c = CONCAT13(uVar55,CONCAT12(uVar54,CONCAT11(uVar53,uVar52)));
  local_21a8 = CONCAT44(local_21a8._4_4_,uVar14);
  local_8f4 = (undefined1)uVar14;
  local_8f1 = local_1cc6;
  local_8f3 = local_1cc8;
  local_21e8 = CONCAT44(local_21e8._4_4_,uVar23);
  local_8e0 = (undefined1)uVar23;
  local_8dd = local_1cca;
  local_8df = local_1ccc;
  local_2208 = CONCAT44(local_2208._4_4_,uVar28);
  local_8cc = (undefined1)uVar28;
  local_8c9 = local_1cce;
  local_8cb = local_1cd0;
  local_21f0 = CONCAT44(local_21f0._4_4_,local_1bb4);
  local_2200 = CONCAT44(local_2200._4_4_,local_1bb0);
  puVar8 = &local_9c0;
  local_2230 = uStack_1c30;
  local_2228 = local_1c38;
  local_21d8 = local_1cb0;
  local_21cc = local_1c80;
  local_21c8 = local_1ca8;
  local_21c0 = local_1c88;
  local_21b8 = local_1c90;
  local_21b0 = local_1c98;
  local_2170 = local_1c74;
  local_2168 = local_1c60;
  local_2160 = local_1c44;
  local_2158 = (undefined1 *)uStack_1c58;
  local_2150 = local_1c4c;
  local_2148 = local_1c6c;
  local_9bc = local_1cb4;
  local_9b8 = local_1cb0;
  uStack_9b0 = local_1ca8;
  local_9a8 = local_1ca0;
  local_9a4 = uVar18;
  local_9a0 = local_1c98;
  uStack_998 = local_1c90;
  local_990 = local_1c88;
  local_988 = local_1c80;
  local_984 = local_1c7c;
  local_980 = local_1c78;
  local_97c = local_1c74;
  local_974 = local_1c6c;
  local_968 = local_1c60;
  uStack_960 = uStack_1c58;
  local_954 = local_1c4c;
  local_94c = local_1c44;
  local_940 = local_1c38;
  uStack_938 = uStack_1c30;
  local_92c = uVar12;
  local_920 = uVar63;
  local_910 = uVar32;
  local_908 = uVar29;
  local_904 = uVar10;
  local_8fc = uVar11;
  local_8f0 = uVar15;
  uStack_8e8 = uVar16;
  local_8dc = uVar9;
  local_8d4 = uVar24;
  local_8c8 = uVar17;
  local_8c0 = uVar38;
  local_8bc = local_1bb4;
  local_8b8 = local_1bb0;
  local_8b4 = uVar43;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_be0 = local_2188._0_4_;
    local_bdc = (undefined4)local_2180;
    local_bd8 = local_21d8;
    uStack_bd0 = local_21c8;
    local_bc8 = (undefined4)local_2198;
    local_bc4 = (undefined4)local_21a0;
    local_bc0 = local_21b0;
    uStack_bb8 = local_21b8;
    local_bb0 = local_21c0;
    local_ba8 = local_21cc;
    local_ba4 = (undefined4)local_21e0;
    local_ba0 = (undefined4)local_21f8;
    local_b9c = local_2170;
    local_b94 = local_2148;
    local_b8c = (undefined1)local_2210;
    local_b8b = local_1cbc;
    local_b89 = local_1cba;
    local_b88 = local_2168;
    uStack_b80 = local_2158;
    local_b78 = (undefined1)local_2218;
    local_b75 = local_1cbe;
    local_b77 = local_1cc0;
    local_b74 = local_2150;
    local_b6c = local_2160;
    local_b64 = (undefined1)local_2220;
    local_b61 = local_1cc2;
    local_b63 = local_1cc4;
    local_b60 = local_2228;
    uStack_b58 = local_2230;
    local_b50 = 0.7f;
    local_b4c = (undefined4)local_2190;
    local_b14 = (undefined1)local_21a8;
    local_b11 = local_1cc6;
    local_b13 = local_1cc8;
    local_b00 = (undefined1)local_21e8;
    local_afd = local_1cca;
    local_aff = local_1ccc;
    local_aec = (undefined1)local_2208;
    local_ae9 = local_1cce;
    local_aeb = local_1cd0;
    local_adc = (undefined4)local_21f0;
    local_ad8 = (undefined4)local_2200;
    local_b48 = CONCAT44(uVar31,uVar30);
    local_b40 = uVar63;
    local_b38 = CONCAT17(uVar51,CONCAT16(uVar50,CONCAT15(uVar48,CONCAT14(uVar46,CONCAT13(uVar44,
                                                  CONCAT12(uVar49,CONCAT11(uVar47,uVar45)))))));
    local_b30 = uVar32;
    uStack_b2c = CONCAT13(uVar55,CONCAT12(uVar54,CONCAT11(uVar53,uVar52)));
    local_b28 = uVar29;
    local_b24 = uVar10;
    local_b1c = uVar11;
    local_b10 = uVar15;
    uStack_b08 = uVar16;
    local_afc = uVar9;
    local_af4 = uVar24;
    local_ae8 = uVar17;
    local_ae0 = uVar38;
    local_ad4 = uVar43;
    _CGPointMake(&local_be0);
    func_0x000198104610(auStack_1de0,&local_be0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_1de0);
  }
  func_0x000198104610(local_2140 + 0x1e8,auStack_1de0,0x10d);
  func_0x000198104610(&local_1ef0,auStack_1de0,0x10d);
  iVar4 = (int)&local_1ef0;
  FUN_195e7d8c0();
  if (iVar4 == 1) {
    local_1eac = 0;
    local_1ea4 = 0;
    local_1e98 = 0;
    uStack_1e90 = 0;
    local_1e84 = 0;
    local_1e7c = 0;
    uVar31 = 0;
    uVar34 = 0;
    uVar47 = 0;
    uVar49 = 0;
    uVar44 = 0;
    uVar46 = 0;
    uVar48 = 0;
    uVar50 = 0;
    uVar51 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    local_1de8 = 0;
    local_be0 = 0;
    uVar19 = 1;
    uVar21 = 1;
    local_1ee8 = 0;
    local_1ee0 = 0;
    local_1ed8 = 0;
    local_1ed0 = 0;
    local_1ec8 = 0;
    local_1ec0 = 0;
    local_1eb8 = 0;
    local_1eb4 = 0;
    local_1eb0 = 0;
    uVar39 = 1;
    uVar14 = 1;
    uVar27 = 1;
    local_1e70 = 0;
    uStack_1e68 = 0;
    local_1e60 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar11 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    uVar32 = 0;
    uVar63 = 0;
    uVar43 = 1;
    uVar38 = 0;
    uVar29 = 0;
    local_1eec = uVar12;
    local_1ed4 = uVar18;
    uVar30 = 0;
    uVar45 = 0;
  }
  else {
    uVar39 = (uint)local_1e9c;
    local_1ef2 = local_1e99;
    local_1ef4 = local_1e9b;
    uVar14 = (uint)local_1e88;
    local_1ef6 = local_1e85;
    local_1ef8 = local_1e87;
    uVar27 = (uint)local_1e74;
    local_1efa = local_1e71;
    local_1efc = local_1e73;
    uVar24 = (ulong)local_1e5c;
    uVar47 = (undefined1)local_1e50;
    uVar49 = (undefined1)((ulong)local_1e50 >> 8);
    uVar44 = (undefined1)((ulong)local_1e50 >> 0x10);
    uVar46 = (undefined1)((ulong)local_1e50 >> 0x18);
    uVar48 = (undefined1)((ulong)local_1e50 >> 0x20);
    uVar50 = (undefined1)((ulong)local_1e50 >> 0x28);
    uVar51 = (undefined1)((ulong)local_1e50 >> 0x30);
    uVar52 = (undefined1)((ulong)local_1e50 >> 0x38);
    uVar31 = (undefined4)uStack_1e48;
    uVar34 = (undefined4)((ulong)uStack_1e48 >> 0x20);
    uVar53 = (undefined1)local_1e38;
    uVar54 = (undefined1)((uint)local_1e38 >> 8);
    uVar55 = (undefined1)((uint)local_1e38 >> 0x10);
    uVar56 = (undefined1)((uint)local_1e38 >> 0x18);
    local_1efe = local_1e21;
    local_1f00 = local_1e23;
    uVar19 = (uint)local_1e10;
    local_1f02 = local_1e0d;
    local_1f04 = local_1e0f;
    uVar21 = (uint)local_1dfc;
    local_1f06 = local_1df9;
    local_1f08 = local_1dfb;
    uVar9 = uStack_1e18;
    uVar10 = local_1e0c;
    uVar11 = local_1e04;
    uVar15 = local_1e34;
    uVar16 = local_1e2c;
    uVar17 = local_1e20;
    uVar32 = uStack_1e3c;
    uVar63 = local_1df8;
    uVar43 = local_1e24;
    uVar38 = local_1df0;
    uVar29 = local_1dec;
    local_be0 = local_1ef0;
    uVar30 = local_1e40;
    uVar45 = local_1de4;
  }
  local_21d8 = CONCAT44(local_21d8._4_4_,local_be0);
  local_2170 = CONCAT44(local_2170._4_4_,local_1eec);
  local_2180 = CONCAT44(local_2180._4_4_,local_1ed8);
  local_2188 = (code *)CONCAT44(local_2188._4_4_,local_1ed4);
  local_21b0 = CONCAT44(local_21b0._4_4_,local_1eb8);
  local_21c0 = CONCAT44(local_21c0._4_4_,local_1eb4);
  local_21f0 = CONCAT44(local_21f0._4_4_,uVar39);
  local_b8c = (undefined1)uVar39;
  local_b89 = local_1ef2;
  local_b8b = local_1ef4;
  local_2200 = CONCAT44(local_2200._4_4_,uVar14);
  local_b78 = (undefined1)uVar14;
  local_b77 = local_1ef8;
  local_b75 = local_1ef6;
  local_2208 = CONCAT44(local_2208._4_4_,uVar27);
  local_b64 = (undefined1)uVar27;
  local_b63 = local_1efc;
  local_b61 = local_1efa;
  local_2228 = CONCAT44(local_2228._4_4_,local_1e60);
  local_b4c = (undefined4)uVar24;
  local_2220 = CONCAT44(local_2220._4_4_,local_b4c);
  local_b48 = 1.5708;
  local_b40 = CONCAT17(uVar52,CONCAT16(uVar51,CONCAT15(uVar50,CONCAT14(uVar48,CONCAT13(uVar46,
                                                  CONCAT12(uVar44,CONCAT11(uVar49,uVar47)))))));
  local_b38 = CONCAT44(uVar34,uVar31);
  local_b28 = CONCAT13(uVar56,CONCAT12(uVar55,CONCAT11(uVar54,uVar53)));
  local_b11 = local_1efe;
  local_b13 = local_1f00;
  local_21e0 = CONCAT44(local_21e0._4_4_,uVar19);
  local_b00 = (undefined1)uVar19;
  local_afd = local_1f02;
  local_aff = local_1f04;
  local_21f8 = CONCAT44(local_21f8._4_4_,uVar21);
  local_aec = (undefined1)uVar21;
  local_ae9 = local_1f06;
  local_aeb = local_1f08;
  local_21e8 = CONCAT44(local_21e8._4_4_,local_1de8);
  puVar8 = &local_be0;
  local_2218 = uStack_1e68;
  local_2210 = local_1e70;
  local_21cc = local_1eb0;
  local_21c8 = local_1ee0;
  local_21b8 = local_1ee8;
  local_21a8 = local_1ec0;
  local_21a0 = local_1ec8;
  local_2198 = local_1ea4;
  local_2190 = local_1ed0;
  local_2168 = uStack_1e90;
  local_2160 = local_1e98;
  local_2158 = (undefined1 *)local_1e7c;
  local_2150 = local_1eac;
  local_2148 = local_1e84;
  local_bdc = local_1eec;
  local_bd8 = local_1ee8;
  uStack_bd0 = local_1ee0;
  local_bc8 = local_1ed8;
  local_bc4 = local_1ed4;
  local_bc0 = local_1ed0;
  uStack_bb8 = local_1ec8;
  local_bb0 = local_1ec0;
  local_ba8 = local_1eb8;
  local_ba4 = local_1eb4;
  local_ba0 = local_1eb0;
  local_b9c = local_1eac;
  local_b94 = local_1ea4;
  local_b88 = local_1e98;
  uStack_b80 = uStack_1e90;
  local_b74 = local_1e84;
  local_b6c = local_1e7c;
  local_b60 = local_1e70;
  uStack_b58 = uStack_1e68;
  local_b50 = local_1e60;
  local_b30 = uVar30;
  uStack_b2c = uVar32;
  local_b24 = uVar15;
  local_b1c = uVar16;
  local_b14 = uVar43;
  local_b10 = uVar17;
  uStack_b08 = uVar9;
  local_afc = uVar10;
  local_af4 = uVar11;
  local_ae8 = uVar63;
  local_ae0 = uVar38;
  local_adc = uVar29;
  local_ad8 = local_1de8;
  local_ad4 = uVar45;
  FUN_195ed8068(puVar8,local_ad0);
  if (((ulong)puVar8 & 1) == 0) {
    local_2130 = CONCAT44((undefined4)local_2170,(int)local_21d8);
    uStack_2128 = local_21b8;
    local_2120 = local_21c8;
    local_2118 = CONCAT44(local_2188._0_4_,(int)local_2180);
    local_2110 = local_2190;
    uStack_2108 = local_21a0;
    local_2100 = local_21a8;
    local_20f8 = (undefined4)local_21b0;
    local_20f4 = (undefined4)local_21c0;
    local_20f0 = local_21cc;
    local_20ec = local_2150;
    local_20e4 = local_2198;
    local_20dc = (undefined1)local_21f0;
    local_20db = local_1ef4;
    local_20d9 = local_1ef2;
    local_20d8 = local_2160;
    uStack_20d0 = local_2168;
    local_20c8 = (undefined1)local_2200;
    local_20c5 = local_1ef6;
    local_20c7 = local_1ef8;
    local_20c4 = local_2148;
    local_20bc = local_2158;
    local_20b4 = (undefined1)local_2208;
    local_20b1 = local_1efa;
    local_20b3 = local_1efc;
    local_20b0 = local_2210;
    uStack_20a8 = local_2218;
    local_20a0 = (undefined4)local_2228;
    local_209c = (undefined4)local_2220;
    local_2098 = 1.5708;
    local_2061 = local_1efe;
    local_2063 = local_1f00;
    local_2050 = (undefined1)local_21e0;
    local_204d = local_1f02;
    local_204f = local_1f04;
    local_203c = (undefined1)local_21f8;
    local_2039 = local_1f06;
    local_203b = local_1f08;
    local_2028 = (undefined4)local_21e8;
    local_2090 = CONCAT17(uVar52,CONCAT16(uVar51,CONCAT15(uVar50,CONCAT14(uVar48,CONCAT13(uVar46,
                                                  CONCAT12(uVar44,CONCAT11(uVar49,uVar47)))))));
    uStack_2088 = CONCAT44(uVar34,uVar31);
    local_2080 = uVar30;
    uStack_207c = uVar32;
    local_2078 = CONCAT13(uVar56,CONCAT12(uVar55,CONCAT11(uVar54,uVar53)));
    local_2074 = uVar15;
    local_206c = uVar16;
    local_2064 = uVar43;
    local_2060 = uVar17;
    uStack_2058 = uVar9;
    local_204c = uVar10;
    local_2044 = uVar11;
    local_2038 = uVar63;
    local_2030 = uVar38;
    local_202c = uVar29;
    local_2024 = uVar45;
    _CGPointMake(&local_2130);
    func_0x000198104610(auStack_2018,&local_2130,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_2018);
  }
  lVar5 = local_2140;
  func_0x000198104610(local_2140 + 0x1e8,auStack_2018,0x10d);
  uStack_2128 = {d 76.8};
  local_2130 = {f 8, -16};
  local_2120 = {f -3, 0};
  local_2118 = 1.5708;
  uStack_2108 = {d 0.0078125};
  local_2110 = {d 0};
  FUN_195ed0ef0(&local_2130);
  if (*(char *)(lVar5 + 0x10c) == '\x01') {
    uVar32 = 0;
    uVar38 = 0;
    uVar29 = 0;
    uVar30 = 0;
    fVar35 = 0.0;
    dVar40 = 0.0;
    dVar42 = 0.0;
    bVar3 = true;
  }
  else {
    fVar35 = *(float *)(lVar5 + 0x108);
    dVar40 = *(double *)(lVar5 + 0xf8);
    dVar42 = *(double *)(lVar5 + 0x100);
    uVar29 = (undefined4)*(undefined8 *)(lVar5 + 0xf0);
    uVar30 = (undefined4)((ulong)*(undefined8 *)(lVar5 + 0xf0) >> 0x20);
    uVar32 = (undefined4)*(undefined8 *)(lVar5 + 0xe8);
    uVar38 = (undefined4)((ulong)*(undefined8 *)(lVar5 + 0xe8) >> 0x20);
    bVar3 = *(double *)(lVar5 + 0xd8) == 0.0;
  }
  if (((bVar3) &&
      ((((byte){f 1.4013e-45, 2.8026e-45} & ~-((double)CONCAT44(uVar38,uVar32) == 0.0)) +
        ((byte)((ulong){f 1.4013e-45, 2.8026e-45} >> 0x20) & ~-((double)CONCAT44(uVar30,uVar29) == 0.0)) +
        ((byte){f 5.60519e-45, 1.12104e-44} & ~-(dVar40 == 0.0)) +
        ((byte)((ulong){f 5.60519e-45, 1.12104e-44} >> 0x20) & ~-(dVar42 == 0.0)) & 0xf) == 0)) && (fVar35 == 0.0)
     ) {
    uVar32 = 0;
    uVar38 = 0;
    uVar29 = 0;
    uVar30 = 0;
    fVar35 = 0.0;
    dVar40 = 0.0;
    dVar42 = 0.0;
  }
  lVar7 = -(ulong)((double)CONCAT44(uVar38,uVar32) == 0.0);
  lVar6 = -(ulong)((double)CONCAT44(uVar30,uVar29) == 0.0);
  lVar13 = -(ulong)(dVar40 == 0.0);
  lVar20 = -(ulong)(dVar42 == 0.0);
  auVar41[1] = ~(byte)((ulong)lVar7 >> 8);
  auVar41[0] = ~(byte)lVar7;
  auVar41[2] = ~(byte)((ulong)lVar7 >> 0x10);
  auVar41[3] = ~(byte)((ulong)lVar7 >> 0x18);
  auVar41[4] = ~(byte)lVar6;
  auVar41[5] = ~(byte)((ulong)lVar6 >> 8);
  auVar41[6] = ~(byte)((ulong)lVar6 >> 0x10);
  auVar41[7] = ~(byte)((ulong)lVar6 >> 0x18);
  auVar41[8] = ~(byte)lVar13;
  auVar41[9] = ~(byte)((ulong)lVar13 >> 8);
  auVar41[10] = ~(byte)((ulong)lVar13 >> 0x10);
  auVar41[0xb] = ~(byte)((ulong)lVar13 >> 0x18);
  auVar41[0xc] = ~(byte)lVar20;
  auVar41[0xd] = ~(byte)((ulong)lVar20 >> 8);
  auVar41[0xe] = ~(byte)((ulong)lVar20 >> 0x10);
  auVar41[0xf] = ~(byte)((ulong)lVar20 >> 0x18);
  uVar39 = NEON_umaxv(auVar41,4);
  if (((uVar39 & 1) == 0) && (fVar35 == 0.0)) {
    uVar32 = 0;
    uVar38 = 0;
    uVar29 = 0;
    uVar30 = 0;
    fVar35 = 0.0;
    uVar43 = 1;
    dVar40 = 0.0;
    dVar42 = 0.0;
  }
  else {
    uVar43 = 0;
  }
  *(undefined8 *)(lVar5 + 0xd8) = 0;
  *(undefined8 *)(lVar5 + 0xe0) = 0;
  *(ulong *)(lVar5 + 0xf0) = CONCAT44(uVar30,uVar29);
  *(ulong *)(lVar5 + 0xe8) = CONCAT44(uVar38,uVar32);
  *(double *)(lVar5 + 0x100) = dVar42;
  *(double *)(lVar5 + 0xf8) = dVar40;
  *(float *)(lVar5 + 0x108) = fVar35;
  *(undefined1 *)(lVar5 + 0x10c) = uVar43;
  if (*(char *)(lVar5 + 0xd4) == '\x01') {
    local_bf0 = 0;
    uVar38 = 0;
    uVar34 = 0;
    uVar30 = 0;
    uVar37 = 0;
    uVar29 = 0;
    uVar33 = 0;
    uVar32 = 0;
    uVar31 = 0;
  }
  else {
    local_bf0 = *(undefined4 *)(lVar5 + 0xcc);
    pauVar1 = (undefined1 (*) [12])(lVar5 + 0xac);
    uVar37 = (undefined4)((ulong)*(undefined8 *)(lVar5 + 0xb4) >> 0x20);
    uVar34 = (undefined4)((ulong)*(undefined8 *)*pauVar1 >> 0x20);
    uVar38 = SUB124(*pauVar1,0);
    uVar30 = SUB124(*pauVar1,8);
    pauVar1 = (undefined1 (*) [12])(lVar5 + 0xbc);
    uVar9 = *(undefined8 *)(lVar5 + 0xc4);
    uVar43 = (undefined1)((ulong)uVar9 >> 0x38);
    uVar33 = (undefined4)((ulong)*(undefined8 *)*pauVar1 >> 0x20);
    uVar32 = SUB124(*pauVar1,8);
    uVar29 = SUB124(*pauVar1,0);
    uVar31 = (undefined4)
             (CONCAT14(uVar43,CONCAT13((char)((ulong)uVar9 >> 0x30),
                                       CONCAT12((char)((ulong)uVar9 >> 0x28),
                                                CONCAT11((char)((ulong)uVar9 >> 0x20),uVar43)))) >>
             8);
  }
  uStack_c08 = CONCAT44(uVar37,uVar30);
  local_c10 = CONCAT44(uVar34,uVar38);
  uStack_bf8 = CONCAT44(uVar31,uVar32);
  uStack_c00 = CONCAT44(uVar33,uVar29);
  local_bec = 0;
  FUN_195ed0ce8(&local_c10);
  uVar9 = {f 0.8, 0.3};
  *(undefined8 *)(lVar5 + 0x4d8) = {d 8};
  *(undefined8 *)(lVar5 + 0x4d0) = uVar9;
  *(undefined1 *)(lVar5 + 0x4e0) = 0;
  uVar9 = (f -0.8, f 0.15);
  if ((local_2174 & 1) == 0) {
    uVar9 = (f -0.9, f 0.2);
  }
  *(undefined8 *)(lVar5 + 0x4b8) = uVar9;
  *(undefined8 *)(lVar5 + 0x4c0) = 0.75;
  *(undefined1 *)(lVar5 + 0x4c8) = 0;
  *(undefined8 *)(lVar5 + 0x4e8) = 1;
  uVar9 = {d -0.24};
  *(undefined8 *)(lVar5 + 0x4f8) = {d -0.8};
  *(undefined8 *)(lVar5 + 0x4f0) = uVar9;
  *(undefined8 *)(lVar5 + 0x500) = 30;
  *(undefined1 *)(lVar5 + 0x508) = 0;
  return;
}


//######## GlassWindowActiveShadow (spec) 0x195f12408
// === 195f126bc spec

/* WARNING: Removing unreachable block (ram,0x000195f12710) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f126bc(long param_1,long param_2)
{
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar10 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  puVar6 = puVar10;
  (**(code **)(lVar9 + 0x68))(puVar10,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar1;
  func_0x0001980ff320(uVar7,puVar10,lVar4,puVar6);
  (**(code **)(lVar9 + 8))(puVar10,lVar4);
  lVar4 = 0;
  FUN_195ed0900();
  uVar8 = (ulong)*(uint3 *)(param_2 + *(int *)(lVar4 + 0x20));
  FUN_195e5f470(uVar8,0x1001e);
  FUN_195eda468(<shadow.opacity>,<+0x30>,
                <+0x38>,<+0x40>,
                <+0x48>,<+0x50>,
                <+0x51>);
  bVar3 = (uVar7 & 1) == 0;
  uVar11 = 0.7f;
  if (bVar3) {
    uVar11 = 0.6f;
  }
  uVar12 = 0.8f;
  if (bVar3) {
    uVar12 = 0.7f;
  }
  if ((uVar8 & 1) == 0) {
    uVar11 = uVar12;
  }
  <shadow.opacity> = (ulong)uVar11;
  <+0x38> = 0;
  <+0x30> = 0;
  <+0x48> = 0;
  <+0x40> = 0;
  <+0x50> = 0;
  FUN_195f12a4c(<shadow.shadowRadius>);
  <shadow.shadowRadius> = 24;
  <+0x91> = 0;
  uVar2 = {d 0};
  <shadow.offset.1> = {d 10};
  <shadow.offset.0> = uVar2;
  return;
}


//######## GlassWindowInactiveShadow (spec) 0x195f1240c
// === 195f12884 spec

/* WARNING: Removing unreachable block (ram,0x000195f128d8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f12884(long param_1,long param_2)
{
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar10 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  puVar6 = puVar10;
  (**(code **)(lVar9 + 0x68))(puVar10,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar1;
  func_0x0001980ff320(uVar7,puVar10,lVar4,puVar6);
  (**(code **)(lVar9 + 8))(puVar10,lVar4);
  lVar4 = 0;
  FUN_195ed0900();
  uVar8 = (ulong)*(uint3 *)(param_2 + *(int *)(lVar4 + 0x20));
  FUN_195e5f470(uVar8,0x1001e);
  FUN_195eda468(<shadow.opacity>,<+0x30>,
                <+0x38>,<+0x40>,
                <+0x48>,<+0x50>,
                <+0x51>);
  bVar3 = (uVar7 & 1) == 0;
  uVar11 = 0.55f;
  if (bVar3) {
    uVar11 = 0.45f;
  }
  uVar12 = 0.65f;
  if (bVar3) {
    uVar12 = 0.55f;
  }
  if ((uVar8 & 1) == 0) {
    uVar11 = uVar12;
  }
  <shadow.opacity> = (ulong)uVar11;
  <+0x38> = 0;
  <+0x30> = 0;
  <+0x48> = 0;
  <+0x40> = 0;
  <+0x50> = 0;
  FUN_195f12a4c(<shadow.shadowRadius>);
  <shadow.shadowRadius> = 16;
  <+0x91> = 0;
  uVar2 = {d 0};
  <shadow.offset.1> = {d 4};
  <shadow.offset.0> = uVar2;
  return;
}


//######## IdentityRecipe.anon.Modifier (params) 0x195f13ae8
// === 195f13ae8 params

void FUN_195f13ae8(undefined8 param_1,undefined8 param_2)
{
  FUN_195f12ab4(param_2,0);
  return;
}


//######## KeyboardRecipe.anon.Highlights (params) 0x195f13ce4
// === 195f141ec params

void FUN_195f141ec(ulong param_1)
{
  undefined1 auStack_830 [272];
  undefined4 local_610 [2];
  func_0x000198104610(&local_1b8,<highlights.hdr>,0x10d);
  iVar1 = (int)&local_1b8;
  FUN_195e7d8c0();
  if (iVar1 == 1) {
    uVar10 = 0;
    uVar3 = 0;
    uVar4 = 0;
    uVar5 = 0;
    uVar6 = 0;
    uVar7 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar17 = 0;
    uVar18 = 0;
    uVar19 = 0;
    uVar20 = 0;
    uVar33 = 0;
    uVar34 = 0;
    uVar35 = 0;
    uVar36 = 0;
    uVar37 = 0;
    uVar42 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar46 = 0;
    uVar47 = 0;
    uVar51 = 0;
    uVar32 = 0;
    uVar41 = 0;
    uVar44 = 0;
    uVar48 = 0;
    uVar49 = 0;
    uVar50 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar38 = 0;
    uVar39 = 0;
    uVar21 = 1;
    uVar29 = 1;
    uVar30 = 1;
    uVar11 = 1;
    uVar28 = 1;
    uVar12 = 1;
  }
  else {
    local_1bc = local_163;
    local_1ba = local_161;
    local_1be = local_14d;
    local_1c0 = local_14f;
    local_1c2 = local_139;
    local_1c4 = local_13b;
    local_d14 = local_124;
    local_1c6 = local_e9;
    local_1c8 = local_eb;
    local_1ca = local_d5;
    local_1cc = local_d7;
    local_1ce = local_c1;
    local_1d0 = local_c3;
    uVar10 = (uint)local_ac;
    uVar3 = local_fc;
    uVar4 = local_f4;
    uVar5 = local_e8;
    uVar6 = local_e0;
    uVar7 = local_cc;
    uVar13 = local_d4;
    uVar14 = local_174;
    uVar15 = local_16c;
    uVar17 = local_160;
    uVar18 = local_158;
    uVar19 = local_14c;
    uVar20 = local_144;
    uVar33 = local_1b0;
    uVar34 = local_1a8;
    uVar35 = local_198;
    uVar36 = local_190;
    uVar37 = local_188;
    uVar42 = local_138;
    uVar43 = local_130;
    uVar45 = local_120;
    uVar46 = local_118;
    uVar47 = local_110;
    uVar51 = local_c0;
    uVar32 = local_1b8;
    uVar41 = local_178;
    uVar44 = local_128;
    uVar48 = local_108;
    uVar49 = local_104;
    uVar50 = local_100;
    uVar52 = local_b8;
    uVar53 = local_b4;
    uVar54 = local_b0;
    in_w5 = local_1b4;
    in_w6 = local_19c;
    uVar38 = local_180;
    uVar39 = local_17c;
    uVar21 = local_164;
    uVar29 = local_150;
    uVar30 = local_13c;
    uVar11 = local_ec;
    uVar28 = local_d8;
    uVar12 = local_c4;
  }
  local_2c8 = 1f;
  local_289 = local_1ba;
  local_28b = local_1bc;
  local_277 = local_1c0;
  local_275 = local_1be;
  local_263 = local_1c4;
  local_261 = local_1c2;
  local_24c = local_d14;
  local_211 = local_1c6;
  local_213 = local_1c8;
  local_1fd = local_1ca;
  local_1ff = local_1cc;
  local_1e9 = local_1ce;
  local_1eb = local_1d0;
  uVar31 = (undefined1)uVar10;
  local_610[0] = 0;
  local_600 = 0;
  local_608 = 0;
  local_5f8 = 0;
  local_5c0 = 0;
  uStack_5d8 = 0;
  local_5e0 = 0;
  uStack_5c8 = 0;
  uStack_5d0 = 0;
  uStack_5e8 = 0;
  local_5f0 = 0;
  local_5bc = 1;
  local_5b0 = 0;
  local_5b8 = 0;
  local_5a8 = 1;
  local_59c = 0;
  local_5a4 = 0;
  local_594 = 1;
  local_588 = 0;
  local_590 = 0;
  local_580 = 0;
  local_548 = 0;
  uStack_550 = 0;
  local_558 = 0;
  uStack_560 = 0;
  local_568 = 0;
  uStack_570 = 0;
  local_578 = 0;
  local_544 = 1;
  local_538 = 0;
  local_540 = 0;
  local_530 = 1;
  local_524 = 0;
  local_52c = 0;
  local_51c = 1;
  uStack_508 = 0;
  uStack_510 = 0;
  local_50b = 0;
  local_518 = 0;
  puVar2 = &local_2e0;
  uVar8 = in_w5;
  uVar9 = in_w6;
  local_2e0 = uVar32;
  local_2dc = in_w5;
  local_2d8 = uVar33;
  local_2d0 = uVar34;
  local_2c4 = in_w6;
  local_2c0 = uVar35;
  local_2b8 = uVar36;
  local_2b0 = uVar37;
  local_2a8 = uVar38;
  local_2a4 = uVar39;
  local_2a0 = uVar41;
  local_29c = uVar14;
  local_294 = uVar15;
  local_28c = uVar21;
  local_288 = uVar17;
  local_280 = uVar18;
  local_278 = uVar29;
  local_274 = uVar19;
  local_26c = uVar20;
  local_264 = uVar30;
  local_260 = uVar42;
  local_258 = uVar43;
  local_250 = uVar44;
  local_248 = uVar45;
  local_240 = uVar46;
  local_238 = uVar47;
  local_230 = uVar48;
  local_22c = uVar49;
  local_228 = uVar50;
  local_224 = uVar3;
  local_21c = uVar4;
  local_214 = uVar11;
  local_210 = uVar5;
  local_208 = uVar6;
  local_200 = uVar28;
  local_1fc = uVar13;
  local_1f4 = uVar7;
  local_1ec = uVar12;
  local_1e8 = uVar51;
  local_1e0 = uVar52;
  local_1dc = uVar53;
  local_1d8 = uVar54;
  local_1d4 = uVar31;
  FUN_195ed8068(puVar2,local_610);
  if (((ulong)puVar2 & 1) == 0) {
    local_3d8 = 1f;
    local_39b = local_1bc;
    local_399 = local_1ba;
    local_385 = local_1be;
    local_387 = local_1c0;
    local_371 = local_1c2;
    local_373 = local_1c4;
    local_35c = local_d14;
    local_321 = local_1c6;
    local_323 = local_1c8;
    local_30d = local_1ca;
    local_30f = local_1cc;
    local_2f9 = local_1ce;
    local_2fb = local_1d0;
    local_3f0 = uVar32;
    local_3ec = in_w5;
    local_3e8 = uVar33;
    local_3e0 = uVar34;
    local_3d4 = in_w6;
    local_3d0 = uVar35;
    local_3c8 = uVar36;
    local_3c0 = uVar37;
    local_3b8 = uVar38;
    local_3b4 = uVar39;
    local_3b0 = uVar41;
    local_3ac = uVar14;
    local_3a4 = uVar15;
    local_39c = uVar21;
    local_398 = uVar17;
    local_390 = uVar18;
    local_388 = uVar29;
    local_384 = uVar19;
    local_37c = uVar20;
    local_374 = uVar30;
    local_370 = uVar42;
    local_368 = uVar43;
    local_360 = uVar44;
    local_358 = uVar45;
    local_350 = uVar46;
    local_348 = uVar47;
    local_340 = uVar48;
    local_33c = uVar49;
    local_338 = uVar50;
    local_334 = uVar3;
    local_32c = uVar4;
    local_324 = uVar11;
    local_320 = uVar5;
    local_318 = uVar6;
    local_310 = uVar28;
    local_30c = uVar13;
    local_304 = uVar7;
    local_2fc = uVar12;
    local_2f8 = uVar51;
    local_2f0 = uVar52;
    local_2ec = uVar53;
    local_2e8 = uVar54;
    local_2e4 = uVar31;
    _CGPointMake(&local_3f0);
    func_0x000198104610(auStack_830,&local_3f0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_830);
  }
  uVar27 = <highlights.hdr>;
  func_0x000198104610(uVar27,auStack_830,0x10d);
  FUN_195ed53f0();
  if ((uVar27 & 1) == 0) {
    func_0x000198104610(&local_720,<highlights.hdr>,0x10d);
    iVar1 = (int)&local_720;
    FUN_195e7d8c0();
    if (iVar1 == 1) {
      uVar27 = 0;
      uVar23 = 0;
      uVar24 = 0;
      uVar3 = 0;
      uVar4 = 0;
      uVar5 = 0;
      uVar6 = 0;
      uVar7 = 0;
      uVar13 = 0;
      uVar26 = 0;
      uVar16 = 0;
      uVar25 = 0;
      uVar14 = 0;
      uVar15 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar33 = 0;
      uVar34 = 0;
      uVar35 = 0;
      uVar36 = 0;
      uVar32 = 0;
      uVar41 = 0;
      uVar44 = 0;
      uVar48 = 0;
      uVar49 = 0;
      uVar11 = 1;
      uVar28 = 1;
      uVar12 = 0;
      uVar50 = 0;
      uVar52 = 0;
      uVar53 = 0;
      uVar54 = 0;
      uVar38 = 0;
      uVar39 = 0;
      uVar40 = 0;
      uVar21 = 1;
      uVar29 = 1;
      uVar30 = 1;
      uVar31 = 1;
    }
    else {
      local_832 = local_6c9;
      local_834 = local_6cb;
      local_836 = local_6b5;
      local_838 = local_6b7;
      local_83a = local_6a1;
      local_83c = local_6a3;
      local_83e = local_651;
      local_840 = local_653;
      local_842 = local_63d;
      local_844 = local_63f;
      local_846 = local_629;
      local_848 = local_62b;
      uVar27 = local_650;
      uVar23 = local_634;
      uVar24 = local_63c;
      uVar3 = local_6b4;
      uVar4 = local_6ac;
      uVar5 = local_6dc;
      uVar6 = local_6d4;
      uVar7 = local_6c8;
      uVar13 = local_6c0;
      uVar26 = local_65c;
      uVar16 = local_664;
      uVar25 = local_648;
      uVar14 = local_628;
      uVar15 = local_678;
      uVar17 = local_680;
      uVar18 = local_718;
      uVar19 = local_710;
      uVar20 = local_688;
      uVar33 = local_700;
      uVar34 = local_698;
      uVar35 = local_6f8;
      uVar36 = local_6f0;
      uVar32 = local_708;
      uVar41 = local_6e8;
      uVar44 = local_6e4;
      uVar48 = local_6e0;
      uVar49 = local_690;
      uVar11 = local_654;
      uVar28 = local_640;
      uVar12 = local_614;
      uVar8 = local_71c;
      uVar9 = local_704;
      uVar10 = local_68c;
      uVar50 = local_720;
      uVar52 = local_670;
      uVar53 = local_66c;
      uVar54 = local_668;
      uVar38 = local_620;
      uVar39 = local_61c;
      uVar40 = local_618;
      uVar21 = local_6cc;
      uVar29 = local_6b8;
      uVar30 = local_6a4;
      uVar31 = local_62c;
    }
    local_399 = local_832;
    local_39b = local_834;
    local_387 = local_838;
    local_385 = local_836;
    local_373 = local_83c;
    local_371 = local_83a;
    local_370 = 0.785398;
    local_321 = local_83e;
    local_323 = local_840;
    local_30d = local_842;
    local_30f = local_844;
    local_2f9 = local_846;
    local_2fb = local_848;
    puVar2 = &local_3f0;
    local_3f0 = uVar50;
    local_3ec = uVar8;
    local_3e8 = uVar18;
    local_3e0 = uVar19;
    local_3d8 = uVar32;
    local_3d4 = uVar9;
    local_3d0 = uVar33;
    local_3c8 = uVar35;
    local_3c0 = uVar36;
    local_3b8 = uVar41;
    local_3b4 = uVar44;
    local_3b0 = uVar48;
    local_3ac = uVar5;
    local_3a4 = uVar6;
    local_39c = uVar21;
    local_398 = uVar7;
    local_390 = uVar13;
    local_388 = uVar29;
    local_384 = uVar3;
    local_37c = uVar4;
    local_374 = uVar30;
    local_368 = uVar34;
    local_360 = uVar49;
    local_35c = uVar10;
    local_358 = uVar20;
    local_350 = uVar17;
    local_348 = uVar15;
    local_340 = uVar52;
    local_33c = uVar53;
    local_338 = uVar54;
    local_334 = uVar16;
    local_32c = uVar26;
    local_324 = uVar11;
    local_320 = uVar27;
    local_318 = uVar25;
    local_310 = uVar28;
    local_30c = uVar24;
    local_304 = uVar23;
    local_2fc = uVar31;
    local_2f8 = uVar14;
    local_2f0 = uVar38;
    local_2ec = uVar39;
    local_2e8 = uVar40;
    local_2e4 = uVar12;
    FUN_195ed8068(puVar2,local_610);
    if (((ulong)puVar2 & 1) == 0) {
      local_4ab = local_834;
      local_4a9 = local_832;
      local_495 = local_836;
      local_497 = local_838;
      local_481 = local_83a;
      local_483 = local_83c;
      local_480 = 0.785398;
      local_431 = local_83e;
      local_433 = local_840;
      local_41d = local_842;
      local_41f = local_844;
      local_409 = local_846;
      local_40b = local_848;
      local_500 = uVar50;
      local_4fc = uVar8;
      local_4f8 = uVar18;
      local_4f0 = uVar19;
      local_4e8 = uVar32;
      local_4e4 = uVar9;
      local_4e0 = uVar33;
      local_4d8 = uVar35;
      local_4d0 = uVar36;
      local_4c8 = uVar41;
      local_4c4 = uVar44;
      local_4c0 = uVar48;
      local_4bc = uVar5;
      local_4b4 = uVar6;
      local_4ac = uVar21;
      local_4a8 = uVar7;
      local_4a0 = uVar13;
      local_498 = uVar29;
      local_494 = uVar3;
      local_48c = uVar4;
      local_484 = uVar30;
      local_478 = uVar34;
      local_470 = uVar49;
      local_46c = uVar10;
      local_468 = uVar20;
      local_460 = uVar17;
      local_458 = uVar15;
      local_450 = uVar52;
      local_44c = uVar53;
      local_448 = uVar54;
      local_444 = uVar16;
      local_43c = uVar26;
      local_434 = uVar11;
      local_430 = uVar27;
      local_428 = uVar25;
      local_420 = uVar28;
      local_41c = uVar24;
      local_414 = uVar23;
      local_40c = uVar31;
      local_408 = uVar14;
      local_400 = uVar38;
      local_3fc = uVar39;
      local_3f8 = uVar40;
      local_3f4 = uVar12;
      _CGPointMake(&local_500);
      func_0x000198104610(&local_958,&local_500,0x10d);
    }
    else {
      FUN_195e7d8d4(&local_958);
    }
    func_0x000198104610(<highlights.hdr>,&local_958,0x10d);
    func_0x000198104610(&local_a68,&local_958,0x10d);
    iVar1 = (int)&local_a68;
    FUN_195e7d8c0();
    if (iVar1 == 1) {
      uVar10 = 1;
      uVar8 = 1;
      uVar3 = 0;
      uVar4 = 0;
      uVar5 = 0;
      uVar6 = 0;
      uVar7 = 0;
      uVar13 = 0;
      uVar14 = 0;
      uVar15 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar33 = 0;
      uVar34 = 0;
      uVar35 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar42 = 0;
      uVar43 = 0;
      uVar45 = 0;
      uVar46 = 0;
      local_da8 = 0;
      uVar28 = 0;
      uVar32 = 0;
      uVar41 = 0;
      uVar44 = 0;
      uVar48 = 0;
      uVar49 = 0;
      local_dac = 0;
      uVar50 = 0;
      uVar52 = 0;
      uVar53 = 0;
      uVar54 = 0;
      uVar38 = 0;
      uVar39 = 0;
      uVar12 = 1;
      uVar21 = 1;
      uVar29 = 1;
      uVar11 = 1;
    }
    else {
      uVar25 = (ulong)local_a64;
      uVar27 = (ulong)local_a4c;
      local_a6c = local_a13;
      local_a6a = local_a11;
      uVar10 = (uint)local_a00;
      local_a6e = local_9fd;
      local_a70 = local_9ff;
      uVar8 = (uint)local_9ec;
      local_a72 = local_9e9;
      local_a74 = local_9eb;
      uVar26 = (ulong)local_9d4;
      local_a76 = local_999;
      local_a78 = local_99b;
      local_a7a = local_985;
      local_a7c = local_987;
      local_a7e = local_971;
      local_a80 = local_973;
      uVar3 = local_9a4;
      uVar4 = local_998;
      uVar5 = local_990;
      uVar6 = local_984;
      uVar7 = local_97c;
      uVar13 = local_a24;
      uVar14 = local_a1c;
      uVar15 = local_a10;
      uVar17 = local_a08;
      uVar18 = local_9fc;
      uVar19 = local_9f4;
      uVar20 = local_9ac;
      uVar33 = local_a40;
      uVar34 = local_a38;
      uVar35 = local_9e8;
      uVar36 = local_9e0;
      uVar37 = local_9d0;
      uVar42 = local_9c8;
      uVar43 = local_9c0;
      uVar45 = local_a60;
      uVar46 = local_a58;
      local_da8 = local_970;
      uVar28 = local_95c;
      uVar32 = local_a68;
      uVar41 = local_a50;
      uVar44 = local_9b8;
      uVar48 = local_9b4;
      uVar49 = local_9b0;
      local_dac = local_968;
      uVar50 = local_964;
      uVar52 = local_960;
      uVar53 = local_a30;
      uVar54 = local_a2c;
      uVar38 = local_a28;
      uVar39 = local_9d8;
      uVar12 = local_a14;
      uVar21 = local_99c;
      uVar29 = local_988;
      uVar11 = local_974;
    }
    local_4e0 = 1.309;
    local_4a9 = local_a6a;
    local_4ab = local_a6c;
    uVar30 = (undefined1)uVar10;
    local_497 = local_a70;
    local_495 = local_a6e;
    uVar31 = (undefined1)uVar8;
    local_483 = local_a74;
    local_481 = local_a72;
    local_431 = local_a76;
    local_433 = local_a78;
    local_41d = local_a7a;
    local_41f = local_a7c;
    local_409 = local_a7e;
    local_40b = local_a80;
    puVar2 = &local_500;
    local_500 = uVar32;
    local_4fc = (int)uVar25;
    local_4f8 = uVar45;
    local_4f0 = uVar46;
    local_4e8 = uVar41;
    local_4e4 = (int)uVar27;
    local_4d8 = uVar33;
    local_4d0 = uVar34;
    local_4c8 = uVar53;
    local_4c4 = uVar54;
    local_4c0 = uVar38;
    local_4bc = uVar13;
    local_4b4 = uVar14;
    local_4ac = uVar12;
    local_4a8 = uVar15;
    local_4a0 = uVar17;
    local_498 = uVar30;
    local_494 = uVar18;
    local_48c = uVar19;
    local_484 = uVar31;
    local_480 = uVar35;
    local_478 = uVar36;
    local_470 = uVar39;
    local_46c = (int)uVar26;
    local_468 = uVar37;
    local_460 = uVar42;
    local_458 = uVar43;
    local_450 = uVar44;
    local_44c = uVar48;
    local_448 = uVar49;
    local_444 = uVar20;
    local_43c = uVar3;
    local_434 = uVar21;
    local_430 = uVar4;
    local_428 = uVar5;
    local_420 = uVar29;
    local_41c = uVar6;
    local_414 = uVar7;
    local_40c = uVar11;
    local_408 = local_da8;
    local_400 = local_dac;
    local_3fc = uVar50;
    local_3f8 = uVar52;
    local_3f4 = uVar28;
    FUN_195ed8068(puVar2,local_610);
    if (((ulong)puVar2 & 1) != 0) goto LAB_195f15bf0;
    local_c80 = 1.309;
    local_c4b = local_a6c;
    local_c49 = local_a6a;
    local_c35 = local_a6e;
    local_c37 = local_a70;
    local_c21 = local_a72;
    local_c23 = local_a74;
    local_bd1 = local_a76;
    local_bd3 = local_a78;
    local_bbd = local_a7a;
    local_bbf = local_a7c;
    local_ce6 = local_a7e;
    local_ce8 = local_a80;
    local_ca0 = uVar32;
    local_c9c = (int)uVar25;
    local_c98 = uVar45;
    uStack_c90 = uVar46;
    local_c88 = uVar41;
    local_c84 = (int)uVar27;
    local_c78 = uVar33;
    uStack_c70 = uVar34;
    local_c68 = uVar53;
    local_c64 = uVar54;
    local_c60 = uVar38;
    local_c54 = uVar14;
    local_c4c = uVar12;
    local_c48 = uVar15;
    uStack_c40 = uVar17;
    local_c38 = uVar30;
    local_c34 = uVar18;
    local_c2c = uVar19;
    local_c24 = uVar31;
    local_c20 = uVar35;
    uStack_c18 = uVar36;
    local_c10 = uVar39;
    local_c0c = (int)uVar26;
    local_c08 = uVar37;
    uStack_c00 = uVar42;
    local_bf8 = uVar43;
    local_bf0 = uVar44;
    local_bec = uVar48;
    local_be8 = uVar49;
    local_be4 = uVar20;
    local_bdc = uVar3;
    local_bd4 = uVar21;
    local_bd0 = uVar4;
    local_bc8 = uVar5;
    local_bc0 = uVar29;
    local_bbc = uVar6;
    local_bb4 = uVar7;
    local_bac = uVar11;
    local_b98 = uVar52;
    local_b9c = uVar50;
  }
  else {
    func_0x000198104610(&local_720,<highlights.hdr>,0x10d);
    iVar1 = (int)&local_720;
    FUN_195e7d8c0();
    if (iVar1 == 1) {
      uVar27 = 0;
      uVar3 = 0;
      uVar23 = 0;
      uVar4 = 0;
      uVar24 = 0;
      uVar5 = 0;
      uVar26 = 0;
      uVar6 = 0;
      uVar16 = 0;
      uVar7 = 0;
      uVar25 = 0;
      uVar13 = 0;
      uVar22 = param_1;
      uVar14 = 0;
      uVar15 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar33 = 0;
      uVar34 = 0;
      uVar35 = 0;
      uVar36 = 0;
      uVar32 = 0;
      uVar41 = 0;
      uVar44 = 0;
      uVar48 = 0;
      uVar49 = 0;
      uVar50 = 0;
      uVar52 = 0;
      uVar53 = 0;
      uVar11 = 0;
      uVar54 = 0;
      uVar38 = 0;
      uVar39 = 0;
      uVar40 = 0;
      uVar28 = 1;
      uVar12 = 1;
      uVar21 = 1;
      uVar29 = 1;
      uVar30 = 1;
      uVar31 = 1;
    }
    else {
      uVar22 = (ulong)local_704;
      local_cba = local_6c9;
      local_cbc = local_6cb;
      local_cbe = local_6b5;
      local_cc0 = local_6b7;
      local_cc2 = local_6a1;
      local_cc4 = local_6a3;
      local_cc6 = local_651;
      local_cc8 = local_653;
      local_cca = local_63d;
      local_ccc = local_63f;
      local_cce = local_629;
      local_cd0 = local_62b;
      uVar27 = local_648;
      uVar3 = local_6b4;
      uVar23 = local_63c;
      uVar4 = local_6ac;
      uVar24 = local_634;
      uVar5 = local_6dc;
      uVar26 = local_664;
      uVar6 = local_6d4;
      uVar16 = local_65c;
      uVar7 = local_6c8;
      uVar25 = local_650;
      uVar13 = local_6c0;
      uVar14 = local_698;
      uVar15 = local_688;
      uVar17 = local_680;
      uVar18 = local_678;
      uVar19 = local_718;
      uVar20 = local_710;
      uVar33 = local_700;
      uVar34 = local_6f8;
      uVar35 = local_6f0;
      uVar36 = local_628;
      uVar32 = local_720;
      uVar41 = local_708;
      uVar44 = local_6e8;
      uVar48 = local_6e4;
      uVar49 = local_6e0;
      uVar50 = local_620;
      uVar52 = local_61c;
      uVar53 = local_618;
      uVar11 = local_614;
      uVar8 = local_71c;
      uVar9 = local_68c;
      uVar54 = local_690;
      uVar38 = local_670;
      uVar39 = local_66c;
      uVar40 = local_668;
      uVar28 = local_654;
      uVar12 = local_6cc;
      uVar21 = local_6b8;
      uVar29 = local_6a4;
      uVar30 = local_640;
      uVar31 = local_62c;
    }
    local_399 = local_cba;
    local_39b = local_cbc;
    local_387 = local_cc0;
    local_385 = local_cbe;
    local_373 = local_cc4;
    local_371 = local_cc2;
    local_370 = 0.436332;
    local_321 = local_cc6;
    local_323 = local_cc8;
    local_30d = local_cca;
    local_30f = local_ccc;
    local_2f9 = local_cce;
    local_2fb = local_cd0;
    puVar2 = &local_3f0;
    local_3f0 = uVar32;
    local_3ec = uVar8;
    local_3e8 = uVar19;
    local_3e0 = uVar20;
    local_3d8 = uVar41;
    local_3d4 = (uint)uVar22;
    local_3d0 = uVar33;
    local_3c8 = uVar34;
    local_3c0 = uVar35;
    local_3b8 = uVar44;
    local_3b4 = uVar48;
    local_3b0 = uVar49;
    local_3ac = uVar5;
    local_3a4 = uVar6;
    local_39c = uVar12;
    local_398 = uVar7;
    local_390 = uVar13;
    local_388 = uVar21;
    local_384 = uVar3;
    local_37c = uVar4;
    local_374 = uVar29;
    local_368 = uVar14;
    local_360 = uVar54;
    local_35c = uVar9;
    local_358 = uVar15;
    local_350 = uVar17;
    local_348 = uVar18;
    local_340 = uVar38;
    local_33c = uVar39;
    local_338 = uVar40;
    local_334 = uVar26;
    local_32c = uVar16;
    local_324 = uVar28;
    local_320 = uVar25;
    local_318 = uVar27;
    local_310 = uVar30;
    local_30c = uVar23;
    local_304 = uVar24;
    local_2fc = uVar31;
    local_2f8 = uVar36;
    local_2f0 = uVar50;
    local_2ec = uVar52;
    local_2e8 = uVar53;
    local_2e4 = uVar11;
    FUN_195ed8068(puVar2,local_610);
    if (((ulong)puVar2 & 1) == 0) {
      local_4ab = local_cbc;
      local_4a9 = local_cba;
      local_495 = local_cbe;
      local_497 = local_cc0;
      local_481 = local_cc2;
      local_483 = local_cc4;
      local_480 = 0.436332;
      local_431 = local_cc6;
      local_433 = local_cc8;
      local_41d = local_cca;
      local_41f = local_ccc;
      local_409 = local_cce;
      local_40b = local_cd0;
      local_500 = uVar32;
      local_4fc = uVar8;
      local_4f8 = uVar19;
      local_4f0 = uVar20;
      local_4e8 = uVar41;
      local_4e4 = (uint)uVar22;
      local_4e0 = uVar33;
      local_4d8 = uVar34;
      local_4d0 = uVar35;
      local_4c8 = uVar44;
      local_4c4 = uVar48;
      local_4c0 = uVar49;
      local_4bc = uVar5;
      local_4b4 = uVar6;
      local_4ac = uVar12;
      local_4a8 = uVar7;
      local_4a0 = uVar13;
      local_498 = uVar21;
      local_494 = uVar3;
      local_48c = uVar4;
      local_484 = uVar29;
      local_478 = uVar14;
      local_470 = uVar54;
      local_46c = uVar9;
      local_468 = uVar15;
      local_460 = uVar17;
      local_458 = uVar18;
      local_450 = uVar38;
      local_44c = uVar39;
      local_448 = uVar40;
      local_444 = uVar26;
      local_43c = uVar16;
      local_434 = uVar28;
      local_430 = uVar25;
      local_428 = uVar27;
      local_420 = uVar30;
      local_41c = uVar23;
      local_414 = uVar24;
      local_40c = uVar31;
      local_408 = uVar36;
      local_400 = uVar50;
      local_3fc = uVar52;
      local_3f8 = uVar53;
      local_3f4 = uVar11;
      _CGPointMake(&local_500);
      func_0x000198104610(&local_958,&local_500,0x10d);
    }
    else {
      FUN_195e7d8d4(&local_958);
    }
    func_0x000198104610(<highlights.hdr>,&local_958,0x10d);
    func_0x000198104610(&local_a68,&local_958,0x10d);
    iVar1 = (int)&local_a68;
    FUN_195e7d8c0();
    if (iVar1 == 1) {
      uVar10 = 1;
      uVar8 = 1;
      uVar3 = 0;
      uVar4 = 0;
      uVar5 = 0;
      uVar6 = 0;
      uVar7 = 0;
      uVar13 = 0;
      uVar14 = 0;
      uVar15 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar33 = 0;
      uVar34 = 0;
      uVar35 = 0;
      uVar36 = 0;
      uVar37 = 0;
      uVar42 = 0;
      uVar43 = 0;
      uVar45 = 0;
      uVar46 = 0;
      local_da8 = 0;
      uVar32 = 0;
      uVar41 = 0;
      uVar44 = 0;
      uVar48 = 0;
      uVar49 = 0;
      local_dac = 0;
      uVar50 = 0;
      uVar52 = 0;
      uVar28 = 0;
      uVar53 = 0;
      uVar54 = 0;
      uVar38 = 0;
      uVar39 = 0;
      uVar12 = 1;
      uVar21 = 1;
      uVar29 = 1;
      uVar11 = 1;
    }
    else {
      uVar24 = (ulong)local_a64;
      uVar26 = (ulong)local_a4c;
      local_cd4 = local_a13;
      local_cd2 = local_a11;
      uVar10 = (uint)local_a00;
      local_cd6 = local_9fd;
      local_cd8 = local_9ff;
      uVar8 = (uint)local_9ec;
      local_cda = local_9e9;
      local_cdc = local_9eb;
      uVar23 = (ulong)local_9d4;
      local_cde = local_999;
      local_ce0 = local_99b;
      local_ce2 = local_985;
      local_ce4 = local_987;
      local_ce6 = local_971;
      local_ce8 = local_973;
      uVar3 = local_9a4;
      uVar4 = local_998;
      uVar5 = local_990;
      uVar6 = local_984;
      uVar7 = local_97c;
      uVar13 = local_a24;
      uVar14 = local_a1c;
      uVar15 = local_a10;
      uVar17 = local_a08;
      uVar18 = local_9fc;
      uVar19 = local_9f4;
      uVar20 = local_9ac;
      uVar33 = local_a40;
      uVar34 = local_a38;
      uVar35 = local_9e8;
      uVar36 = local_9e0;
      uVar37 = local_9d0;
      uVar42 = local_9c8;
      uVar43 = local_9c0;
      uVar45 = local_a60;
      uVar46 = local_a58;
      local_da8 = local_970;
      uVar32 = local_a68;
      uVar41 = local_a50;
      uVar44 = local_9b8;
      uVar48 = local_9b4;
      uVar49 = local_9b0;
      local_dac = local_968;
      uVar50 = local_964;
      uVar52 = local_960;
      uVar28 = local_95c;
      uVar53 = local_a30;
      uVar54 = local_a2c;
      uVar38 = local_a28;
      uVar39 = local_9d8;
      uVar12 = local_a14;
      uVar21 = local_99c;
      uVar29 = local_988;
      uVar11 = local_974;
    }
    local_4e0 = 1.5708;
    local_4a9 = local_cd2;
    local_4ab = local_cd4;
    uVar30 = (undefined1)uVar10;
    local_497 = local_cd8;
    local_495 = local_cd6;
    uVar31 = (undefined1)uVar8;
    local_483 = local_cdc;
    local_481 = local_cda;
    local_431 = local_cde;
    local_433 = local_ce0;
    local_41d = local_ce2;
    local_41f = local_ce4;
    local_409 = local_ce6;
    local_40b = local_ce8;
    puVar2 = &local_500;
    local_500 = uVar32;
    local_4fc = (int)uVar24;
    local_4f8 = uVar45;
    local_4f0 = uVar46;
    local_4e8 = uVar41;
    local_4e4 = (int)uVar26;
    local_4d8 = uVar33;
    local_4d0 = uVar34;
    local_4c8 = uVar53;
    local_4c4 = uVar54;
    local_4c0 = uVar38;
    local_4bc = uVar13;
    local_4b4 = uVar14;
    local_4ac = uVar12;
    local_4a8 = uVar15;
    local_4a0 = uVar17;
    local_498 = uVar30;
    local_494 = uVar18;
    local_48c = uVar19;
    local_484 = uVar31;
    local_480 = uVar35;
    local_478 = uVar36;
    local_470 = uVar39;
    local_46c = (int)uVar23;
    local_468 = uVar37;
    local_460 = uVar42;
    local_458 = uVar43;
    local_450 = uVar44;
    local_44c = uVar48;
    local_448 = uVar49;
    local_444 = uVar20;
    local_43c = uVar3;
    local_434 = uVar21;
    local_430 = uVar4;
    local_428 = uVar5;
    local_420 = uVar29;
    local_41c = uVar6;
    local_414 = uVar7;
    local_40c = uVar11;
    local_408 = local_da8;
    local_400 = local_dac;
    local_3fc = uVar50;
    local_3f8 = uVar52;
    local_3f4 = uVar28;
    FUN_195ed8068(puVar2,local_610);
    if (((ulong)puVar2 & 1) != 0) {
LAB_195f15bf0:
      uVar32 = (undefined4)uVar13;
      FUN_195e7d8d4(&local_b90);
      goto LAB_195f15d88;
    }
    local_c80 = 1.5708;
    local_c4b = local_cd4;
    local_c49 = local_cd2;
    local_c35 = local_cd6;
    local_c37 = local_cd8;
    local_c21 = local_cda;
    local_c23 = local_cdc;
    local_bd1 = local_cde;
    local_bd3 = local_ce0;
    local_bbd = local_ce2;
    local_bbf = local_ce4;
    local_ca0 = uVar32;
    local_c9c = (int)uVar24;
    local_c98 = uVar45;
    uStack_c90 = uVar46;
    local_c88 = uVar41;
    local_c84 = (int)uVar26;
    local_c78 = uVar33;
    uStack_c70 = uVar34;
    local_c68 = uVar53;
    local_c64 = uVar54;
    local_c60 = uVar38;
    local_c54 = uVar14;
    local_c4c = uVar12;
    local_c48 = uVar15;
    uStack_c40 = uVar17;
    local_c38 = uVar30;
    local_c34 = uVar18;
    local_c2c = uVar19;
    local_c24 = uVar31;
    local_c20 = uVar35;
    uStack_c18 = uVar36;
    local_c10 = uVar39;
    local_c0c = (int)uVar23;
    local_c08 = uVar37;
    uStack_c00 = uVar42;
    local_bf8 = uVar43;
    local_bf0 = uVar44;
    local_bec = uVar48;
    local_be8 = uVar49;
    local_be4 = uVar20;
    local_bdc = uVar3;
    local_bd4 = uVar21;
    local_bd0 = uVar4;
    local_bc8 = uVar5;
    local_bc0 = uVar29;
    local_bbc = uVar6;
    local_bb4 = uVar7;
    local_bac = uVar11;
    local_b98 = uVar52;
    local_b9c = uVar50;
  }
  uVar32 = (undefined4)uVar13;
  local_ba8 = local_da8;
  local_ba0 = local_dac;
  local_c5c = uVar13;
  local_bab = local_ce8;
  local_ba9 = local_ce6;
  local_b94 = uVar28;
  _CGPointMake(&local_ca0);
  func_0x000198104610(&local_b90,&local_ca0,0x10d);
LAB_195f15d88:
  func_0x000198104610(<highlights.hdr>,&local_b90,0x10d);
  func_0x000198104610(&local_958,<highlights.hdr>,0x10d);
  iVar1 = (int)&local_958;
  FUN_195e7d8c0();
  if (iVar1 == 1) {
    uVar3 = 0;
    uVar4 = 0;
    uVar5 = 0;
    uVar6 = 0;
    uVar7 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar17 = 0;
    uVar18 = 0;
    uVar19 = 0;
    uVar20 = 0;
    uVar33 = 0;
    uVar34 = 0;
    uVar35 = 0;
    uVar36 = 0;
    uVar37 = 0;
    uVar42 = 0;
    uVar43 = 0;
    uVar45 = 0;
    uVar46 = 0;
    uVar47 = 0;
    uVar51 = 0;
    uVar41 = 0;
    uVar44 = 0;
    uVar48 = 0;
    uVar49 = 0;
    uVar50 = 0;
    uVar52 = 0;
    uVar53 = 0;
    uVar54 = 0;
    uVar38 = 0;
    uVar39 = 0;
    uVar40 = 0;
    uVar11 = 1;
    uVar28 = 1;
    uVar12 = 1;
    uVar21 = 1;
    uVar29 = 1;
    uVar30 = 1;
    uVar31 = 0;
  }
  else {
    local_ca2 = local_901;
    local_ca4 = local_903;
    local_ca6 = local_8ed;
    local_ca8 = local_8ef;
    local_caa = local_8d9;
    local_cac = local_8db;
    local_cae = local_889;
    local_cb0 = local_88b;
    local_cb2 = local_875;
    local_cb4 = local_877;
    local_cb6 = local_861;
    local_cb8 = local_863;
    uVar3 = local_888;
    uVar4 = local_86c;
    uVar5 = local_874;
    uVar6 = local_8ec;
    uVar7 = local_8e4;
    uVar13 = local_914;
    uVar14 = local_90c;
    uVar15 = local_900;
    uVar17 = local_894;
    uVar18 = local_89c;
    uVar19 = local_8f8;
    uVar20 = local_880;
    uVar33 = local_860;
    uVar34 = local_8b0;
    uVar35 = local_950;
    uVar36 = local_8b8;
    uVar37 = local_948;
    uVar42 = local_8c0;
    uVar43 = local_938;
    uVar45 = local_930;
    uVar46 = local_928;
    uVar47 = local_8d8;
    uVar51 = local_8d0;
    uVar41 = local_940;
    uVar44 = local_920;
    uVar48 = local_91c;
    uVar49 = local_918;
    uVar10 = local_954;
    uVar8 = local_93c;
    uVar32 = local_8c4;
    uVar50 = local_958;
    uVar52 = local_8a8;
    uVar53 = local_8a4;
    uVar54 = local_8a0;
    uVar38 = local_858;
    uVar39 = local_854;
    uVar40 = local_850;
    uVar11 = local_904;
    uVar28 = local_8f0;
    uVar12 = local_8dc;
    uVar21 = local_88c;
    uVar29 = local_878;
    uVar30 = local_864;
    uVar31 = local_84c;
  }
  local_6c9 = local_ca2;
  local_6cb = local_ca4;
  local_6b7 = local_ca8;
  local_6b5 = local_ca6;
  local_6a3 = local_cac;
  local_6a1 = local_caa;
  local_690 = 0;
  local_651 = local_cae;
  local_653 = local_cb0;
  local_63d = local_cb2;
  local_63f = local_cb4;
  local_629 = local_cb6;
  local_62b = local_cb8;
  puVar2 = &local_720;
  local_720 = uVar50;
  local_71c = uVar10;
  local_718 = uVar35;
  local_710 = uVar37;
  local_708 = uVar41;
  local_704 = uVar8;
  local_700 = uVar43;
  local_6f8 = uVar45;
  local_6f0 = uVar46;
  local_6e8 = uVar44;
  local_6e4 = uVar48;
  local_6e0 = uVar49;
  local_6dc = uVar13;
  local_6d4 = uVar14;
  local_6cc = uVar11;
  local_6c8 = uVar15;
  local_6c0 = uVar19;
  local_6b8 = uVar28;
  local_6b4 = uVar6;
  local_6ac = uVar7;
  local_6a4 = uVar12;
  local_6a0 = uVar47;
  local_698 = uVar51;
  local_68c = uVar32;
  local_688 = uVar42;
  local_680 = uVar36;
  local_678 = uVar34;
  local_670 = uVar52;
  local_66c = uVar53;
  local_668 = uVar54;
  local_664 = uVar18;
  local_65c = uVar17;
  local_654 = uVar21;
  local_650 = uVar3;
  local_648 = uVar20;
  local_640 = uVar29;
  local_63c = uVar5;
  local_634 = uVar4;
  local_62c = uVar30;
  local_628 = uVar33;
  local_620 = uVar38;
  local_61c = uVar39;
  local_618 = uVar40;
  local_614 = uVar31;
  FUN_195ed8068(puVar2,local_610);
  if (((ulong)puVar2 & 1) == 0) {
    local_b3b = local_ca4;
    local_b39 = local_ca2;
    local_b25 = local_ca6;
    local_b27 = local_ca8;
    local_b11 = local_caa;
    local_b13 = local_cac;
    local_b00 = 0;
    local_ac1 = local_cae;
    local_ac3 = local_cb0;
    local_aad = local_cb2;
    local_aaf = local_cb4;
    local_a99 = local_cb6;
    local_a9b = local_cb8;
    local_b90 = uVar50;
    local_b8c = uVar10;
    local_b88 = uVar35;
    local_b80 = uVar37;
    local_b78 = uVar41;
    local_b74 = uVar8;
    local_b70 = uVar43;
    local_b68 = uVar45;
    local_b60 = uVar46;
    local_b58 = uVar44;
    local_b54 = uVar48;
    local_b50 = uVar49;
    local_b4c = uVar13;
    local_b44 = uVar14;
    local_b3c = uVar11;
    local_b38 = uVar15;
    local_b30 = uVar19;
    local_b28 = uVar28;
    local_b24 = uVar6;
    local_b1c = uVar7;
    local_b14 = uVar12;
    local_b10 = uVar47;
    local_b08 = uVar51;
    local_afc = uVar32;
    local_af8 = uVar42;
    local_af0 = uVar36;
    local_ae8 = uVar34;
    local_ae0 = uVar52;
    local_adc = uVar53;
    local_ad8 = uVar54;
    local_ad4 = uVar18;
    local_acc = uVar17;
    local_ac4 = uVar21;
    local_ac0 = uVar3;
    local_ab8 = uVar20;
    local_ab0 = uVar29;
    local_aac = uVar5;
    local_aa4 = uVar4;
    local_a9c = uVar30;
    local_a98 = uVar33;
    local_a90 = uVar38;
    local_a8c = uVar39;
    local_a88 = uVar40;
    local_a84 = uVar31;
    _CGPointMake(&local_b90);
    func_0x000198104610(&local_a68,&local_b90,0x10d);
  }
  else {
    FUN_195e7d8d4(&local_a68);
  }
  func_0x000198104610(<highlights.hdr>,&local_a68,0x10d);
  return;
}


//######## KeyboardRecipe.anon.KeyboardDiffusionAmount (spec) 0x195f13ce8
// === 195f140d4 spec

void FUN_195f140d4(ulong param_1,long param_2)
{
  uVar3 = param_1;
  FUN_195ed53f0();
  if ((uVar3 & 1) != 0) {
    lVar4 = 0;
    FUN_195f3c68c();
    pfVar1 = (float *)(param_2 + *(int *)(lVar4 + 0x70));
    if ((*(char *)(pfVar1 + 1) != '\x01') && (fVar5 = *pfVar1, 0.5 < fVar5)) {
      dVar7 = (double)fVar5 + -0.5;
      dVar7 = dVar7 + dVar7;
      dVar8 = 1.0;
      if (dVar7 <= 1.0) {
        dVar8 = dVar7;
      }
      if (dVar7 < 0.0) {
        dVar8 = 0.0;
      }
      cVar2 = *(char *)(param_2 + *(int *)(lVar4 + 0x3c));
      if (cVar2 == '\x02') {
        fVar5 = 4.0;
      }
      else {
        if (cVar2 != '\x03') {
          return;
        }
        fVar5 = 7.0;
      }
      uStack_68 = <+0x170>;
      local_70 = <blur.blurRadius>;
      uStack_60 = <+0x178>;
      uStack_58 = (undefined2)<+0x180>;
      uStack_4e = <+0x18a>;
      local_56 = (undefined6)<+0x182>;
      uStack_50 = (undefined2)((ulong)<+0x182> >> 0x30);
      fVar6 = 0.0;
      FUN_195ed79cc();
      FUN_195f1631c(&local_70);
      <blur.blurRadius> =
           (ulong)(uint)(fVar5 * (float)dVar8 + fVar6 * (float)(1.0 - dVar8));
      <+0x178> = 0;
      <+0x170> = 0;
      <+0x188> = 0;
      <+0x180> = 0;
      <+0x190> = 0;
    }
  }
  return;
}


//######## KeyboardRecipe.anon.Modifier (spec) 0x195f13cec
// === 195f1637c spec

/* WARNING: Removing unreachable block (ram,0x000195f16464) */
/* WARNING: Removing unreachable block (ram,0x000195f163ec) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1637c(long param_1,long param_2)
{
  undefined1 auStack_b0 [8];
  lVar4 = 0;
  func_0x0001981217d0();
  lVar10 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar15 = auStack_b0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  func_0x000198120110();
  lVar11 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  uVar16 = (long)puVar15 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar6 + 0x18);
  (**(code **)(lVar11 + 0x68))(uVar16,*_DAT_1e017dd58,lVar5);
  puVar7 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar14 = param_2 + iVar2;
  func_0x0001980ff320(uVar14,uVar16,lVar5,puVar7);
  (**(code **)(lVar11 + 8))(uVar16,lVar5);
  FUN_195ed53f0();
  if ((uVar16 & 1) == 0) {
LAB_195f16654:
    <ringShadow.maskAmount> = 0;
    <blurFill.darkenOpacity> = 0;
    <blurFill.blurRadius> = 0;
  }
  else {
    if (DAT_1eda3a158 != -1) {
      func_0x000198104ff0(&DAT_1eda3a158,FUN_195f38fd0);
    }
    lVar5 = DAT_1eda45918;
    if (*(long *)(DAT_1eda45918 + 0x10) == 0) {
      lVar11 = *(long *)(DAT_1eda45918 + 0xd0);
      if (*(char *)(DAT_1eda45918 + 0xd8) != '\x01') goto LAB_195f16610;
      goto LAB_195f16654;
    }
    puVar8 = &{f 2.25031e+13, 0};
    func_0x000198104dd0(&{f 2.25031e+13, 0});
    local_a8 = lVar5;
    puVar7 = &DAT_1eda3b100;
    FUN_195eab224(DAT_1eda39d38,&DAT_1eda3b100,FUN_195f38ce0,
                  &TargetProtocolConformanceDescriptor_195fb0408);
    func_0x0001980fe060(&local_a8,puVar8,puVar7);
    func_0x000198105020(puVar8);
    func_0x0001981048a0(lVar5 + 0x20);
    lVar11 = *(long *)(lVar5 + 0x68);
    cVar1 = *(char *)(lVar5 + 0x70);
    func_0x0001981048b0(lVar5 + 0x20);
    if (cVar1 == '\x01') goto LAB_195f16654;
LAB_195f16610:
    if (lVar11 != 2) {
      if (lVar11 != 1) {
        if (lVar11 == 0) {
          <blurFill.darkenOpacity> = 0;
          <blurFill.blurRadius> = 0;
          <ringShadow.verticalOffset> = 0;
          <ringShadow.opacity> = 0;
          <ringShadow.blurRadius> = 0;
          <ringShadow.strokeWidth> = 0;
          <darkSpecular.height> = 0;
          <ringShadow.maskAmount> = 0;
          <darkSpecular.spreadSDR> = 0;
          <darkSpecular.spread> = 0;
          <darkSpecular.effectOffset> = 0;
          <darkSpecular.amount> = 0;
          <darkSpecular.colorBias> = 0;
        }
        goto LAB_195f16674;
      }
      goto LAB_195f16654;
    }
    <ringShadow.maskAmount> = 0;
  }
  <ringShadow.verticalOffset> = 0;
  <ringShadow.blurRadius> = 0;
  <ringShadow.strokeWidth> = 0;
  <ringShadow.opacity> = 0;
LAB_195f16674:
  FUN_195ed53f0();
  uVar16 = <shadow.opacity>;
  FUN_195eda468(uVar16,<+0x30>,<+0x38>,
                <+0x40>,<+0x48>,
                <+0x50>,<+0x51>);
  FUN_195ed53f0();
  if ((uVar16 & 1) == 0) {
    FUN_195ed53f0();
    uVar9 = <blur.blurRadius>;
    FUN_195eda468(uVar9,<+0x170>,<+0x178>,
                  <+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    uVar12 = 64;
    if ((uVar16 & 1) == 0) {
      uVar12 = 48;
    }
    <blur.blurRadius> = uVar12;
    <+0x170> = 120;
    <+0x178> = {d 512};
    uVar12 = {f 0, 1.4013e-45};
    <+0x188> = {d 0};
    <+0x180> = uVar12;
    <+0x190> = 0x201;
  }
  else {
    cVar1 = *(char *)(param_2 + *(int *)(lVar6 + 0x3c));
    uVar9 = <blur.blurRadius>;
    FUN_195eda468(uVar9,<+0x170>,<+0x178>,
                  <+0x180>,<+0x188>,
                  <+0x190>,<+0x191>);
    if (cVar1 == '\x03') {
      if ((uVar14 & 1) == 0) {
        uVar12 = 3.5f;
      }
      else {
        uVar12 = 4f;
      }
    }
    else if (cVar1 == '\x02') {
      if ((uVar14 & 1) == 0) {
        uVar12 = 1.5f;
      }
      else {
        uVar12 = 2f;
      }
    }
    else {
      uVar12 = 2.5f;
    }
    <blur.blurRadius> = uVar12;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  uVar12 = {d 0.0078125};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar12;
  <blur.distances.0.v> = 0.5f;
  <blur.distances.0.kind> = 1;
  <blur.distances.1.v> = -66.67f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = -1f;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  FUN_195ed53f0();
  bVar3 = (uVar9 & 1) == 0;
  uVar12 = 0.66;
  if (bVar3) {
    uVar12 = 0.36;
  }
  uVar13 = -0.3;
  if (bVar3) {
    uVar13 = -1;
  }
  <refraction.normalizedInnerHeight> = uVar12;
  <refraction.normalizedInnerAmount> = uVar13;
  <refraction.outerOpacity> = 0;
  <refraction.normalizedOuterHeight> = 0.1;
  <refraction.normalizedOuterAmount> = 0.24;
  FUN_195ed53f0();
  bVar3 = (uVar14 & 1) == 0;
  if ((uVar9 & 1) == 0) {
    uVar20 = 0.35f;
    if (bVar3) {
      uVar20 = 0.3f;
    }
    uVar19 = 0.11f;
    if (bVar3) {
      uVar19 = 0.98f;
    }
    uVar22 = 0.1f;
    uVar18 = uVar22;
    if (bVar3) {
      uVar18 = 0.93f;
    }
    uVar17 = uVar22;
    if (bVar3) {
      uVar17 = 0.91f;
    }
    uVar21 = 0.4f;
    if (bVar3) {
      uVar21 = 0.9f;
    }
    if (bVar3) {
      uVar22 = 0.45f;
    }
    (**(code **)(lVar10 + 0x68))(puVar15,*_DAT_1e01830d0,lVar4);
    func_0x0001981218c0(puVar15);
    uVar23 = 0.8f;
  }
  else {
    uVar20 = 0.75f;
    if (bVar3) {
      uVar20 = 0.7f;
    }
    uVar17 = 0.15f;
    uVar19 = uVar17;
    if (bVar3) {
      uVar19 = 0.91f;
    }
    uVar18 = uVar17;
    if (bVar3) {
      uVar18 = 0.88f;
    }
    if (bVar3) {
      uVar17 = 0.87f;
    }
    uVar23 = 1.4f;
    if (bVar3) {
      uVar23 = 0.8f;
    }
    uVar21 = 0.5f;
    if (bVar3) {
      uVar21 = 0.88f;
    }
    uVar22 = 0.1f;
    if (bVar3) {
      uVar22 = 0.4f;
    }
    (**(code **)(lVar10 + 0x68))(puVar15,*_DAT_1e01830d0,lVar4);
    func_0x0001981218c0(puVar15);
  }
  <faceEffect.opacity> = 1f;
  <faceEffect.ycc.black> = uVar22;
  <faceEffect.ycc.white> = uVar21;
  <faceEffect.ycc.saturation> = uVar23;
  <faceEffect.ycc.normalFill.r> = CONCAT44(uVar18,uVar17);
  <faceEffect.ycc.normalFill.b> = CONCAT44(uVar20,uVar19);
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  <faceEffect.maxLuminance> = 0.0078125;
  lVar4 = 0;
  FUN_195ed0900();
  if ((*(byte *)(param_2 + *(int *)(lVar4 + 0x14) + 3) & 1) != 0) {
    if ((uVar14 & 1) == 0) {
      <faceEffect.ycc.black> = 0.55f;
      uVar14 = 0.000488281;
    }
    else {
      uVar14 = 0.000170898;
    }
    <faceEffect.ycc.normalFill.r> = CONCAT44(uVar18,uVar17);
    <faceEffect.ycc.normalFill.b> = uVar14 | uVar19;
    <faceEffect.ycc.normalFill?nil> = 0;
  }
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,
                <+0x218>,<+0x220>,
                <+0x228>,<+0x230>,
                <+0x231>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  <+0x22a> = 0;
  <+0x222> = 0;
  return;
}


//######## MonogramRecipe.anon.Modifier (params) 0x195f16f24
// === 195f17064 params

/* WARNING: Removing unreachable block (ram,0x000195f17174) */
/* WARNING: Removing unreachable block (ram,0x000195f170f8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f17064(long param_1,long param_2,undefined8 param_3,undefined8 param_4,
                  undefined4 param_5,undefined8 param_6,undefined4 param_7)
{
  ushort uVar3;
  uint3 uVar4;
  uint3 uVar5;
  uint3 *puVar20;
  uint3 *puVar26;
  undefined1 auVar42 [16];
  undefined1 auVar43 [16];
  undefined1 auVar44 [16];
  undefined1 auVar45 [16];
  undefined1 auVar53 [16];
  uint3 *local_47e0;
  undefined1 auStack_46c0 [272];
  undefined1 auStack_4488 [272];
  undefined1 auStack_4250 [272];
  undefined1 auStack_4018 [272];
  undefined1 auStack_3de0 [272];
  undefined1 auStack_3ba8 [272];
  undefined1 auStack_3970 [272];
  undefined1 auStack_3738 [272];
  undefined1 auStack_3500 [272];
  undefined1 auStack_32c8 [272];
  undefined1 auStack_3090 [272];
  undefined1 auStack_2e58 [272];
  undefined1 auStack_2c20 [272];
  undefined1 auStack_29e8 [272];
  undefined1 auStack_27b0 [272];
  undefined1 auStack_2578 [276];
  undefined4 local_1b00 [2];
  (*_DAT_1e2125200)();
  lVar9 = 0;
  local_47f8 = param_2;
  func_0x0001981217d0();
  local_47d8 = *(undefined8 **)(lVar9 + -8);
  local_47e8 = lVar9;
  (*_DAT_1e2125200)(*(undefined8 *)((long)local_47d8 + 0x40));
  lVar36 = (long)&local_48f0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar9 = 0;
  local_47f0 = lVar36;
  func_0x000198120110();
  local_4800 = *(long *)(lVar9 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(local_4800 + 0x40));
  lVar36 = lVar36 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  if (<blur?nil> == '\x01') {
    local_d8 = 0;
    local_b4 = 0;
    auVar42 = ZEXT816(0);
  }
  else {
    local_d8 = <blur.radius>;
    auVar42._0_12_ = SUB1612(*(undefined1 (*) [16])(<blur.distances.3>),4);
    auVar42._12_4_ = (int)<blur.opacities.3>;
    local_b4 = (undefined4)((ulong)<blur.opacities.3> >> 0x20);
  }
  local_cc = 0;
  local_d4 = 0;
  uStack_bc = auVar42._8_8_;
  local_c4 = auVar42._0_8_;
  FUN_195ed0ce8(&local_d8);
  if (<blur?nil> == '\x01') {
    local_f0 = 0;
    local_dc = 0;
    local_100 = 0;
    uStack_f8 = 0;
  }
  else {
    local_dc = <blur.opacity>;
    local_f0 = <blur.distances.3>;
    local_100 = <blur.radius>;
    uStack_f8 = <blur.distances.1>;
  }
  local_47e0 = (uint3 *)(<+0x131>);
  auVar42 = NEON_fmov(1f,4);
  uStack_e4 = auVar42._8_8_;
  local_ec = auVar42._0_8_;
  FUN_195ed0ce8(&local_100);
  if (<blur?nil> == '\x01') {
    local_104 = 0;
    auVar43 = ZEXT816(0);
    local_114 = 0;
    uStack_110 = 0;
    uStack_10c = 0;
    uStack_108 = 0;
  }
  else {
    auVar42 = *(undefined1 (*) [16])(<blur.radius>);
    auVar53._0_8_ = auVar42._0_8_ >> 0x20;
    auVar53._8_8_ = auVar42._8_8_ >> 0x20;
    auVar53 = NEON_ext(auVar53,*(undefined1 (*) [16])(<blur.distances.3>),8,1);
    auVar43._0_8_ = auVar42._4_8_;
    auVar43._8_4_ = auVar53._0_4_;
    auVar43._12_4_ = auVar53._8_4_;
    local_114 = (undefined4)((ulong)*(undefined8 *)*(undefined1 (*) [16])(<blur.distances.3>) >> 0x20);
    uStack_110 = (undefined4)<blur.opacities.1>;
    uStack_10c = (undefined4)((ulong)<blur.opacities.1> >> 0x20);
    uStack_108 = (undefined4)<blur.opacities.3>;
    local_104 = (undefined4)((ulong)<blur.opacities.3> >> 0x20);
  }
  local_128 = 0;
  uStack_11c = auVar43._8_8_;
  local_124 = auVar43._0_8_;
  FUN_195ed0ce8(&local_128);
  puVar1 = (undefined2 *)(<+0x1a9>);
  puVar2 = (undefined2 *)(<+0x1bd>);
  uVar3 = <edgeBleed.ycc.burnFill?nil>;
  local_1ec = 0;
  if ((uVar3 & 0xff00) == 0x200) {
    local_137 = 0;
    local_160 = 1;
    local_14c = 1;
    local_138 = 1;
    local_178 = 0;
    local_1a0 = 0;
    uStack_198 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uStack_168 = 0;
    local_148 = 0;
    uStack_140 = 0;
    local_15c = 0;
    uStack_154 = 0;
    local_188 = 0;
    uStack_180 = 0;
  }
  else {
    local_14c = <edgeBleed.ycc.dodgeFill?nil>;
    local_15c = *(undefined8 *)((long)local_47e0 + 0x7b);
    uStack_154 = *(undefined8 *)((long)local_47e0 + 0x83);
    local_160 = <edgeBleed.ycc.normalFill?nil>;
    uStack_168 = *(undefined8 *)((long)local_47e0 + 0x6f);
    uVar41 = (undefined4)*(undefined8 *)((long)local_47e0 + 0x67);
    uVar47 = (undefined4)((ulong)*(undefined8 *)((long)local_47e0 + 0x67) >> 0x20);
    local_178 = <edgeBleed.ycc.white>;
    uStack_180 = <edgeBleed.distances.1>;
    local_188 = <edgeBleed.opacity>;
    uStack_198 = *(undefined8 *)((long)local_47e0 + 0x3f);
    local_1a0 = *(undefined8 *)((long)local_47e0 + 0x37);
    local_148 = <edgeBleed.ycc.burnFill.r>;
    uStack_140 = <edgeBleed.ycc.burnFill.b>;
    local_1c14 = *puVar1;
    local_1c12 = <+0x1ab>;
    local_1c18 = *puVar2;
    local_1c16 = <+0x1bf>;
    local_138 = (undefined1)uVar3;
    local_137 = (undefined1)(uVar3 >> 8);
  }
  local_15f = local_1c14;
  local_15d = local_1c12;
  local_14b = local_1c18;
  local_149 = local_1c16;
  local_190 = 0;
  local_170 = CONCAT44(uVar47,uVar41);
  FUN_195ed0c24(&local_1a0);
  uVar3 = <edgeBleed.ycc.burnFill?nil>;
  local_260 = 0;
  local_270 = 0;
  if ((uVar3 & 0xff00) == 0x200) {
    local_1a7 = 0;
    local_1e0 = 0;
    uStack_1d8 = 0;
    local_1d0 = 1;
    local_200 = 0;
    local_1f8 = 0;
    local_1e4 = 0;
    local_1bc = 1;
    local_1a8 = 1;
    local_210 = 0;
    uStack_208 = 0;
    local_1b8 = 0;
    uStack_1b0 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uStack_1c4 = 0;
  }
  else {
    local_1bc = <edgeBleed.ycc.dodgeFill?nil>;
    uStack_1c4 = *(undefined8 *)((long)local_47e0 + 0x83);
    uVar41 = (undefined4)*(undefined8 *)((long)local_47e0 + 0x7b);
    uVar47 = (undefined4)((ulong)*(undefined8 *)((long)local_47e0 + 0x7b) >> 0x20);
    local_1d0 = <edgeBleed.ycc.normalFill?nil>;
    local_1e0 = *(undefined8 *)((long)local_47e0 + 0x67);
    uStack_1d8 = *(undefined8 *)((long)local_47e0 + 0x6f);
    local_1e4 = <edgeBleed.ycc.saturation>;
    local_1ec = *(undefined8 *)((long)local_47e0 + 0x5b);
    local_1f8 = <edgeBleed.opacity>;
    local_200 = <edgeBleed.blurRadius>;
    uStack_208 = *(undefined8 *)((long)local_47e0 + 0x3f);
    local_210 = *(undefined8 *)((long)local_47e0 + 0x37);
    uStack_1b0 = <edgeBleed.ycc.burnFill.b>;
    local_1b8 = <edgeBleed.ycc.burnFill.r>;
    local_1c1c = *puVar1;
    local_1c1a = <+0x1ab>;
    local_1c1e = <+0x1bf>;
    local_1c20 = *puVar2;
    local_1a8 = (undefined1)uVar3;
    local_1a7 = (undefined1)(uVar3 >> 8);
  }
  local_1cf = local_1c1c;
  local_1cd = local_1c1a;
  local_1bb = local_1c20;
  local_1b9 = local_1c1e;
  uVar59 = 0;
  local_1f4 = 0;
  local_1cc = CONCAT44(uVar47,uVar41);
  FUN_195ed0c24(&local_210);
  uVar3 = <edgeBleed.ycc.burnFill?nil>;
  if ((uVar3 & 0xff00) == 0x200) {
    local_217 = 0;
    local_240 = 1;
    local_22c = 1;
    local_218 = 1;
    local_258 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uStack_248 = 0;
    local_228 = 0;
    uStack_220 = 0;
    local_23c = 0;
    uStack_234 = 0;
    local_280 = 0;
    uStack_278 = 0;
  }
  else {
    local_22c = <edgeBleed.ycc.dodgeFill?nil>;
    local_23c = *(undefined8 *)((long)local_47e0 + 0x7b);
    uStack_234 = *(undefined8 *)((long)local_47e0 + 0x83);
    local_240 = <edgeBleed.ycc.normalFill?nil>;
    uStack_248 = *(undefined8 *)((long)local_47e0 + 0x6f);
    uVar41 = (undefined4)*(undefined8 *)((long)local_47e0 + 0x67);
    uVar47 = (undefined4)((ulong)*(undefined8 *)((long)local_47e0 + 0x67) >> 0x20);
    local_258 = <edgeBleed.ycc.white>;
    local_260 = <edgeBleed.distances.1>;
    local_270 = <edgeBleed.blurRadius>;
    uVar59 = <edgeBleed.opacity>;
    uStack_278 = *(undefined8 *)((long)local_47e0 + 0x3f);
    local_280 = *(undefined8 *)((long)local_47e0 + 0x37);
    local_228 = <edgeBleed.ycc.burnFill.r>;
    uStack_220 = <edgeBleed.ycc.burnFill.b>;
    local_1c24 = *puVar1;
    local_1c22 = <+0x1ab>;
    local_1c26 = <+0x1bf>;
    local_1c28 = *puVar2;
    local_218 = (undefined1)uVar3;
    local_217 = (undefined1)(uVar3 >> 8);
  }
  local_23f = local_1c24;
  local_23d = local_1c22;
  local_22b = local_1c28;
  local_229 = local_1c26;
  local_25c = 0;
  local_250 = CONCAT44(uVar47,uVar41);
  local_268 = uVar59;
  FUN_195ed0c24(&local_280);
  uVar3 = <edgeBleed.ycc.burnFill?nil>;
  local_350 = 0;
  if ((uVar3 & 0xff00) == 0x200) {
    local_287 = 0;
    local_2c0 = 0;
    uStack_2b8 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uStack_2e8 = 0;
    local_2b0 = 1;
    local_2c8 = 0;
    local_2e0 = 0;
    local_29c = 1;
    local_288 = 1;
    local_2d8 = 0;
    uStack_2d0 = 0;
    local_298 = 0;
    uStack_290 = 0;
    local_2ac = 0;
    uStack_2a4 = 0;
  }
  else {
    local_29c = <edgeBleed.ycc.dodgeFill?nil>;
    local_2ac = *(undefined8 *)((long)local_47e0 + 0x7b);
    uStack_2a4 = *(undefined8 *)((long)local_47e0 + 0x83);
    local_2b0 = <edgeBleed.ycc.normalFill?nil>;
    local_2c0 = *(undefined8 *)((long)local_47e0 + 0x67);
    uStack_2b8 = *(undefined8 *)((long)local_47e0 + 0x6f);
    local_2c8 = <edgeBleed.ycc.white>;
    uStack_2d0 = <edgeBleed.distances.1>;
    local_2d8 = <edgeBleed.opacity>;
    local_2e0 = <edgeBleed.blurRadius>;
    uStack_2e8 = *(undefined8 *)((long)local_47e0 + 0x3f);
    uVar41 = (undefined4)*(undefined8 *)((long)local_47e0 + 0x37);
    uVar47 = (undefined4)((ulong)*(undefined8 *)((long)local_47e0 + 0x37) >> 0x20);
    uStack_290 = <edgeBleed.ycc.burnFill.b>;
    local_298 = <edgeBleed.ycc.burnFill.r>;
    local_1c2c = *puVar1;
    local_1c2a = <+0x1ab>;
    local_1c30 = *puVar2;
    local_1c2e = <+0x1bf>;
    local_288 = (undefined1)uVar3;
    local_287 = (undefined1)(uVar3 >> 8);
  }
  local_2af = local_1c2c;
  local_2ad = local_1c2a;
  local_29b = local_1c30;
  local_299 = local_1c2e;
  local_2f0 = CONCAT44(uVar47,uVar41);
  local_2c4 = 1f;
  FUN_195ed0c24(&local_2f0);
  lVar10 = 0;
  FUN_195f3c68c();
  lVar6 = local_4800;
  iVar8 = *(int *)(lVar10 + 0x18);
  lVar11 = lVar36;
  (**(code **)(local_4800 + 0x68))(lVar36,*_DAT_1e017dd58,lVar9);
  FUN_195e7d9c0();
  lVar10 = local_47f8 + iVar8;
  func_0x0001980ff320(lVar10,lVar36,lVar9,lVar11);
  (**(code **)(lVar6 + 8))(lVar36,lVar9);
  local_3a8 = 0;
  local_390 = 1;
  if ((<edgeBleed.ycc.burnFill?nil> & 0xff00) == 0x200) {
    local_320 = 1;
    local_30c = 1;
    local_2f8 = 1;
    local_338 = 0;
    local_360 = 0;
    uStack_358 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uStack_328 = 0;
    local_308 = 0;
    uStack_300 = 0;
    local_31c = 0;
    uStack_314 = 0;
    local_348 = 0;
    uStack_340 = 0;
  }
  else {
    local_30c = <edgeBleed.ycc.dodgeFill?nil>;
    local_31c = *(undefined8 *)((long)local_47e0 + 0x7b);
    uStack_314 = *(undefined8 *)((long)local_47e0 + 0x83);
    local_320 = <edgeBleed.ycc.normalFill?nil>;
    uStack_328 = *(undefined8 *)((long)local_47e0 + 0x6f);
    uVar41 = (undefined4)*(undefined8 *)((long)local_47e0 + 0x67);
    uVar47 = (undefined4)((ulong)*(undefined8 *)((long)local_47e0 + 0x67) >> 0x20);
    local_338 = <edgeBleed.ycc.white>;
    uStack_340 = <edgeBleed.distances.1>;
    local_348 = <edgeBleed.opacity>;
    local_350 = <edgeBleed.blurRadius>;
    uStack_358 = *(undefined8 *)((long)local_47e0 + 0x3f);
    local_360 = *(undefined8 *)((long)local_47e0 + 0x37);
    local_308 = <edgeBleed.ycc.burnFill.r>;
    uStack_300 = <edgeBleed.ycc.burnFill.b>;
    local_1c34 = *puVar1;
    local_1c32 = <+0x1ab>;
    local_1c38 = *puVar2;
    local_1c36 = <+0x1bf>;
    local_2f8 = (undefined1)<edgeBleed.ycc.burnFill?nil>;
  }
  local_31f = local_1c34;
  local_31d = local_1c32;
  local_30b = local_1c38;
  local_309 = local_1c36;
  local_2f7 = ((byte)lVar10 ^ 0xff) & 1;
  local_330 = CONCAT44(uVar47,uVar41);
  FUN_195ed0c24(&local_360);
  uVar3 = <edgeBleed.ycc.burnFill?nil>;
  if ((uVar3 & 0xff00) == 0x200) {
    local_367 = 0;
    local_3a0 = 0;
    uStack_398 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_37c = 1;
    local_368 = 1;
    local_3b8 = 0;
    uStack_3b0 = 0;
    local_378 = 0;
    uStack_370 = 0;
    local_38c = 0;
    uStack_384 = 0;
  }
  else {
    local_37c = <edgeBleed.ycc.dodgeFill?nil>;
    local_38c = *(undefined8 *)((long)local_47e0 + 0x7b);
    uStack_384 = *(undefined8 *)((long)local_47e0 + 0x83);
    local_390 = <edgeBleed.ycc.normalFill?nil>;
    local_3a0 = *(undefined8 *)((long)local_47e0 + 0x67);
    uStack_398 = *(undefined8 *)((long)local_47e0 + 0x6f);
    local_3a8 = <edgeBleed.ycc.white>;
    uStack_3b0 = <edgeBleed.distances.1>;
    local_3b8 = <edgeBleed.opacity>;
    uVar41 = (undefined4)<edgeBleed.blurRadius>;
    uVar47 = (undefined4)((ulong)<edgeBleed.blurRadius> >> 0x20);
    local_378 = <edgeBleed.ycc.burnFill.r>;
    uStack_370 = <edgeBleed.ycc.burnFill.b>;
    local_1c3c = *puVar1;
    local_1c3a = <+0x1ab>;
    local_1c40 = *puVar2;
    local_1c3e = <+0x1bf>;
    local_368 = (undefined1)uVar3;
    local_367 = (undefined1)(uVar3 >> 8);
  }
  local_38f = local_1c3c;
  local_38d = local_1c3a;
  local_37b = local_1c40;
  local_379 = local_1c3e;
  uStack_3c8 = 0;
  local_3d0 = 0;
  local_3c0 = CONCAT44(uVar47,uVar41);
  FUN_195ed0c24(&local_3d0);
  local_1c80 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1c78 = (undefined1)uVar59;
  uStack_1c77 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1c75 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1c74 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1c68 = (undefined4)uVar13;
  uStack_1c64 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1c63 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1c61 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1c70 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1c6c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1c60 = <shadow.opacity>;
  uStack_1c58 = <shadow.vibrancyContribution>;
  local_1c50 = <shadow?nil>;
  local_1cc0 = <shadow.inset>;
  uStack_1cb8 = <shadow.blurRadius>;
  local_1cb0 = <shadow.shadowRadius>;
  uStack_1ca8 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1c88 = <shadow.ycc.dodgeFill.r>;
  uStack_1c98 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1c94 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_1ca0 = (undefined4)<shadow.ycc.saturation>;
  uStack_1c9c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1c90 = (undefined4)uVar59;
  uStack_1c8c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1c8b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1c89 = (undefined1)((ulong)uVar59 >> 0x38);
  local_1ce0 = <shadow.offset.0>;
  uStack_1cd8 = <shadow.offset.1>;
  local_1cd0 = <shadow.amount>;
  uStack_1cc8 = <shadow.height>;
  iVar8 = (int)&local_1ce0;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_40c = 1;
    local_420 = 0;
    local_3e0 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_41c = 0;
    uStack_414 = 0;
    local_3f4 = 0;
    uStack_3ec = 0;
    uStack_430 = 0;
    local_408 = 0;
    uStack_400 = 0;
    local_3d8 = 0;
    local_460 = 0;
    uStack_458 = 0;
    local_3f8 = 1;
    local_3e4 = 1;
    local_428 = 0;
    local_3dc = extraout_w11;
    local_448 = 0;
    uStack_440 = 0;
  }
  else {
    uVar41 = (undefined4)uStack_1cb8;
    uVar47 = (undefined4)((ulong)uStack_1cb8 >> 0x20);
    local_41c = CONCAT44(uStack_1c98,uStack_1c9c);
    uStack_414 = CONCAT44(local_1c90,uStack_1c94);
    local_1ce4 = uStack_1c8b;
    local_1ce2 = uStack_1c89;
    local_1ce6 = uStack_1c75;
    local_1ce8 = uStack_1c77;
    uStack_3ec = CONCAT44(uStack_1c68,uStack_1c6c);
    local_3f4 = CONCAT44(local_1c70,uStack_1c74);
    local_1cea = uStack_1c61;
    local_1cec = uStack_1c63;
    local_3e0 = (undefined4)local_1c60;
    uStack_430 = local_1cb0;
    local_408 = uStack_1c88;
    uStack_400 = local_1c80;
    local_3d8 = uStack_1c58;
    local_460 = local_1ce0;
    uStack_458 = uStack_1cd8;
    local_3f8 = uStack_1c78;
    local_3e4 = uStack_1c64;
    local_428 = uStack_1ca8;
    local_3dc = local_1c60._4_4_;
    local_448 = uStack_1cc8;
    uStack_440 = local_1cc0;
    local_40c = uStack_1c8c;
    local_420 = local_1ca0;
  }
  local_40b = local_1ce4;
  local_409 = local_1ce2;
  local_3f7 = local_1ce8;
  local_3f5 = local_1ce6;
  local_3e3 = local_1cec;
  local_3e1 = local_1cea;
  local_450 = 0;
  local_438 = CONCAT44(uVar47,uVar41);
  FUN_195ed0d6c(&local_460);
  local_1d20 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1d18 = (undefined1)uVar59;
  uStack_1d17 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1d15 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1d14 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1d08 = (undefined4)uVar13;
  uStack_1d04 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1d03 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1d01 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1d10 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1d0c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1d00 = <shadow.opacity>;
  uStack_1cf8 = <shadow.vibrancyContribution>;
  local_1cf0 = <shadow?nil>;
  local_1d60 = <shadow.inset>;
  uStack_1d58 = <shadow.blurRadius>;
  local_1d50 = <shadow.shadowRadius>;
  uStack_1d48 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1d28 = <shadow.ycc.dodgeFill.r>;
  uStack_1d38 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1d34 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_1d40 = (undefined4)<shadow.ycc.saturation>;
  uStack_1d3c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1d30 = (undefined4)uVar59;
  uStack_1d2c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1d2b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1d29 = (undefined1)((ulong)uVar59 >> 0x38);
  local_1d80 = <shadow.offset.0>;
  uStack_1d78 = <shadow.offset.1>;
  local_1d70 = <shadow.amount>;
  uStack_1d68 = <shadow.height>;
  iVar8 = (int)&local_1d80;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_4ac = 0;
    uStack_4a4 = 0;
    local_49c = 1;
    uVar41 = 0;
    uVar47 = 0;
    local_470 = 0;
    local_484 = 0;
    uStack_47c = 0;
    local_4e0 = 0;
    uStack_4d8 = 0;
    local_498 = 0;
    uStack_490 = 0;
    local_4b8 = 0;
    local_468 = 0;
    local_488 = 1;
    local_474 = 1;
    local_4b0 = 0;
    local_4c0 = 0;
    local_46c = extraout_w11_00;
    local_4f0 = 0;
    uStack_4e8 = 0;
  }
  else {
    uVar41 = (undefined4)local_1d60;
    uVar47 = (undefined4)((ulong)local_1d60 >> 0x20);
    local_4ac = CONCAT44(uStack_1d38,uStack_1d3c);
    uStack_4a4 = CONCAT44(local_1d30,uStack_1d34);
    local_1d84 = uStack_1d2b;
    local_1d82 = uStack_1d29;
    local_1d86 = uStack_1d15;
    local_1d88 = uStack_1d17;
    uStack_47c = CONCAT44(uStack_1d08,uStack_1d0c);
    local_484 = CONCAT44(local_1d10,uStack_1d14);
    local_1d8a = uStack_1d01;
    local_1d8c = uStack_1d03;
    local_470 = (undefined4)local_1d00;
    local_4e0 = local_1d70;
    uStack_4d8 = uStack_1d68;
    local_498 = uStack_1d28;
    uStack_490 = local_1d20;
    local_4b8 = uStack_1d48;
    local_468 = uStack_1cf8;
    local_488 = uStack_1d18;
    local_474 = uStack_1d04;
    local_4b0 = local_1d40;
    local_4c0 = local_1d50;
    local_46c = local_1d00._4_4_;
    local_4f0 = local_1d80;
    uStack_4e8 = uStack_1d78;
    local_49c = uStack_1d2c;
  }
  local_49b = local_1d84;
  local_499 = local_1d82;
  local_487 = local_1d88;
  local_485 = local_1d86;
  local_473 = local_1d8c;
  local_471 = local_1d8a;
  local_4d0 = CONCAT44(uVar47,uVar41);
  local_4c8 = 20;
  FUN_195ed0d6c(&local_4f0);
  local_1dc0 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1db8 = (undefined1)uVar59;
  uStack_1db7 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1db5 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1db4 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1da8 = (undefined4)uVar13;
  uStack_1da4 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1da3 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1da1 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1db0 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1dac = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1da0 = <shadow.opacity>;
  uStack_1d98 = <shadow.vibrancyContribution>;
  local_1d90 = <shadow?nil>;
  local_1e00 = <shadow.inset>;
  uStack_1df8 = <shadow.blurRadius>;
  local_1df0 = <shadow.shadowRadius>;
  uStack_1de8 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1dc8 = <shadow.ycc.dodgeFill.r>;
  uStack_1dd8 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1dd4 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_1de0 = (undefined4)<shadow.ycc.saturation>;
  uStack_1ddc = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1dd0 = (undefined4)uVar59;
  uStack_1dcc = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1dcb = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1dc9 = (undefined1)((ulong)uVar59 >> 0x38);
  local_1e20 = <shadow.offset.0>;
  uStack_1e18 = <shadow.offset.1>;
  local_1e10 = <shadow.amount>;
  uStack_1e08 = <shadow.height>;
  iVar8 = (int)&local_1e20;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_52c = 1;
    local_540 = 0;
    local_500 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_53c = 0;
    uStack_534 = 0;
    local_514 = 0;
    uStack_50c = 0;
    uStack_558 = 0;
    local_528 = 0;
    uStack_520 = 0;
    local_570 = 0;
    local_4f8 = 0;
    local_580 = 0;
    uStack_578 = 0;
    local_518 = 1;
    local_504 = 1;
    local_550 = 0;
    local_548 = 0;
    local_4fc = extraout_w11_01;
  }
  else {
    uVar41 = (undefined4)local_1e00;
    uVar47 = (undefined4)((ulong)local_1e00 >> 0x20);
    local_53c = CONCAT44(uStack_1dd8,uStack_1ddc);
    uStack_534 = CONCAT44(local_1dd0,uStack_1dd4);
    local_1e24 = uStack_1dcb;
    local_1e22 = uStack_1dc9;
    local_1e26 = uStack_1db5;
    local_1e28 = uStack_1db7;
    uStack_50c = CONCAT44(uStack_1da8,uStack_1dac);
    local_514 = CONCAT44(local_1db0,uStack_1db4);
    local_1e2a = uStack_1da1;
    local_1e2c = uStack_1da3;
    local_500 = (undefined4)local_1da0;
    uStack_558 = uStack_1df8;
    local_528 = uStack_1dc8;
    uStack_520 = local_1dc0;
    local_570 = local_1e10;
    local_4f8 = uStack_1d98;
    local_580 = local_1e20;
    uStack_578 = uStack_1e18;
    local_518 = uStack_1db8;
    local_504 = uStack_1da4;
    local_550 = local_1df0;
    local_548 = uStack_1de8;
    local_4fc = local_1da0._4_4_;
    local_52c = uStack_1dcc;
    local_540 = local_1de0;
  }
  local_52b = local_1e24;
  local_529 = local_1e22;
  local_517 = local_1e28;
  local_515 = local_1e26;
  local_503 = local_1e2c;
  local_501 = local_1e2a;
  local_568 = 0;
  local_560 = CONCAT44(uVar47,uVar41);
  FUN_195ed0d6c(&local_580);
  local_1e60 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1e58 = (undefined1)uVar59;
  uStack_1e57 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1e55 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1e54 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1e48 = (undefined4)uVar13;
  uStack_1e44 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1e43 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1e41 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1e50 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1e4c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1e40 = <shadow.opacity>;
  uStack_1e38 = <shadow.vibrancyContribution>;
  local_1e30 = <shadow?nil>;
  local_1ea0 = <shadow.inset>;
  uStack_1e98 = <shadow.blurRadius>;
  local_1e90 = <shadow.shadowRadius>;
  uStack_1e88 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1e68 = <shadow.ycc.dodgeFill.r>;
  uStack_1e78 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1e74 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_1e80 = (undefined4)<shadow.ycc.saturation>;
  uStack_1e7c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1e70 = (undefined4)uVar59;
  uStack_1e6c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1e6b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1e69 = (undefined1)((ulong)uVar59 >> 0x38);
  local_1ec0 = <shadow.offset.0>;
  uStack_1eb8 = <shadow.offset.1>;
  local_1eb0 = <shadow.amount>;
  uStack_1ea8 = <shadow.height>;
  iVar8 = (int)&local_1ec0;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_5cc = 0;
    uStack_5c4 = 0;
    local_5bc = 1;
    local_590 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_5a4 = 0;
    uStack_59c = 0;
    uStack_5f8 = 0;
    local_5b8 = 0;
    uStack_5b0 = 0;
    local_588 = 0;
    local_5d8 = 0;
    local_5a8 = 1;
    local_594 = 1;
    local_5d0 = 0;
    local_58c = extraout_w11_02;
    local_610 = 0;
    uStack_608 = 0;
    local_5f0 = 0;
    uStack_5e8 = 0;
  }
  else {
    uVar41 = (undefined4)local_1eb0;
    uVar47 = (undefined4)((ulong)local_1eb0 >> 0x20);
    local_5cc = CONCAT44(uStack_1e78,uStack_1e7c);
    uStack_5c4 = CONCAT44(local_1e70,uStack_1e74);
    local_1ec4 = uStack_1e6b;
    local_1ec2 = uStack_1e69;
    local_1ec6 = uStack_1e55;
    local_1ec8 = uStack_1e57;
    uStack_59c = CONCAT44(uStack_1e48,uStack_1e4c);
    local_5a4 = CONCAT44(local_1e50,uStack_1e54);
    local_1eca = uStack_1e41;
    local_1ecc = uStack_1e43;
    local_590 = (undefined4)local_1e40;
    uStack_5f8 = uStack_1ea8;
    local_5b8 = uStack_1e68;
    uStack_5b0 = local_1e60;
    local_588 = uStack_1e38;
    local_5d8 = uStack_1e88;
    local_5a8 = uStack_1e58;
    local_594 = uStack_1e44;
    local_5d0 = local_1e80;
    local_58c = local_1e40._4_4_;
    local_610 = local_1ec0;
    uStack_608 = uStack_1eb8;
    local_5f0 = local_1ea0;
    uStack_5e8 = uStack_1e98;
    local_5bc = uStack_1e6c;
  }
  local_5bb = local_1ec4;
  local_5b9 = local_1ec2;
  local_5a7 = local_1ec8;
  local_5a5 = local_1ec6;
  local_593 = local_1ecc;
  local_591 = local_1eca;
  local_600 = CONCAT44(uVar47,uVar41);
  local_5e0 = 0;
  FUN_195ed0d6c(&local_610);
  local_1f00 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1ef8 = (undefined1)uVar59;
  uStack_1ef7 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1ef5 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1ef4 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1ee8 = (undefined4)uVar13;
  uStack_1ee4 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1ee3 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1ee1 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1ef0 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1eec = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1ee0 = <shadow.opacity>;
  uStack_1ed8 = <shadow.vibrancyContribution>;
  local_1ed0 = <shadow?nil>;
  local_1f40 = <shadow.inset>;
  uStack_1f38 = <shadow.blurRadius>;
  local_1f30 = <shadow.shadowRadius>;
  uStack_1f28 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1f08 = <shadow.ycc.dodgeFill.r>;
  uStack_1f18 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1f14 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_1f20 = (undefined4)<shadow.ycc.saturation>;
  uStack_1f1c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1f10 = (undefined4)uVar59;
  uStack_1f0c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1f0b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1f09 = (undefined1)((ulong)uVar59 >> 0x38);
  local_1f60 = <shadow.offset.0>;
  uStack_1f58 = <shadow.offset.1>;
  local_1f50 = <shadow.amount>;
  uStack_1f48 = <shadow.height>;
  iVar8 = (int)&local_1f60;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_64c = 1;
    local_668 = 0;
    local_660 = 0;
    local_620 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_65c = 0;
    uStack_654 = 0;
    local_634 = 0;
    uStack_62c = 0;
    uStack_688 = 0;
    local_680 = 0;
    uStack_678 = 0;
    local_648 = 0;
    uStack_640 = 0;
    local_618 = 0;
    local_670 = 0;
    local_6a0 = 0;
    uStack_698 = 0;
    local_638 = 1;
    local_624 = 1;
    local_61c = extraout_w11_03;
  }
  else {
    uVar41 = (undefined4)local_1f50;
    uVar47 = (undefined4)((ulong)local_1f50 >> 0x20);
    local_668 = (undefined4)uStack_1f28;
    local_65c = CONCAT44(uStack_1f18,uStack_1f1c);
    uStack_654 = CONCAT44(local_1f10,uStack_1f14);
    local_1f64 = uStack_1f0b;
    local_1f62 = uStack_1f09;
    local_1f66 = uStack_1ef5;
    local_1f68 = uStack_1ef7;
    uStack_62c = CONCAT44(uStack_1ee8,uStack_1eec);
    local_634 = CONCAT44(local_1ef0,uStack_1ef4);
    local_1f6a = uStack_1ee1;
    local_1f6c = uStack_1ee3;
    local_620 = (undefined4)local_1ee0;
    uStack_688 = uStack_1f48;
    local_680 = local_1f40;
    uStack_678 = uStack_1f38;
    local_648 = uStack_1f08;
    uStack_640 = local_1f00;
    local_618 = uStack_1ed8;
    local_670 = local_1f30;
    local_6a0 = local_1f60;
    uStack_698 = uStack_1f58;
    local_638 = uStack_1ef8;
    local_624 = uStack_1ee4;
    local_61c = local_1ee0._4_4_;
    local_660 = local_1f20;
    local_64c = uStack_1f0c;
  }
  local_64b = local_1f64;
  local_649 = local_1f62;
  local_637 = local_1f68;
  local_635 = local_1f66;
  local_623 = local_1f6c;
  local_621 = local_1f6a;
  local_690 = CONCAT44(uVar47,uVar41);
  local_664 = 0.9f;
  FUN_195ed0d6c(&local_6a0);
  local_1fa0 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_1f98 = (undefined1)uVar59;
  uStack_1f97 = (undefined2)((ulong)uVar59 >> 8);
  uStack_1f95 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_1f94 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_1f88 = (undefined4)uVar13;
  uStack_1f84 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_1f83 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_1f81 = (undefined1)((ulong)uVar13 >> 0x38);
  local_1f90 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_1f8c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_1f80 = <shadow.opacity>;
  uStack_1f78 = <shadow.vibrancyContribution>;
  local_1f70 = <shadow?nil>;
  local_1fe0 = <shadow.inset>;
  uStack_1fd8 = <shadow.blurRadius>;
  local_1fd0 = <shadow.shadowRadius>;
  uStack_1fc8 = (undefined4)<shadow.ycc.black>;
  uStack_1fc4 = (undefined4)((ulong)<shadow.ycc.black> >> 0x20);
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_1fa8 = <shadow.ycc.dodgeFill.r>;
  uStack_1fb8 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_1fb4 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  uStack_1fc0 = (undefined4)<shadow.ycc.saturation>;
  uStack_1fbc = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_1fb0 = (undefined4)uVar59;
  uStack_1fac = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_1fab = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_1fa9 = (undefined1)((ulong)uVar59 >> 0x38);
  local_2000 = <shadow.offset.0>;
  uStack_1ff8 = <shadow.offset.1>;
  local_1ff0 = <shadow.amount>;
  uStack_1fe8 = <shadow.height>;
  iVar8 = (int)&local_2000;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_6ec = 0;
    uStack_6e4 = 0;
    local_6dc = 1;
    local_6c4 = 0;
    uStack_6bc = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_720 = 0;
    uStack_718 = 0;
    local_710 = 0;
    uStack_708 = 0;
    local_6d8 = 0;
    uStack_6d0 = 0;
    local_6a8 = 0;
    local_6c8 = 1;
    local_6b4 = 1;
    local_6b0 = 0;
    local_700 = 0;
    local_6ac = extraout_w11_04;
    local_730 = 0;
    uStack_728 = 0;
  }
  else {
    local_6ec = CONCAT44(uStack_1fb8,uStack_1fbc);
    uStack_6e4 = CONCAT44(local_1fb0,uStack_1fb4);
    local_2004 = uStack_1fab;
    local_2002 = uStack_1fa9;
    local_2006 = uStack_1f95;
    local_2008 = uStack_1f97;
    uStack_6bc = CONCAT44(uStack_1f88,uStack_1f8c);
    local_6c4 = CONCAT44(local_1f90,uStack_1f94);
    local_200a = uStack_1f81;
    local_200c = uStack_1f83;
    uVar41 = uStack_1fc4;
    uVar47 = uStack_1fc0;
    local_720 = local_1ff0;
    uStack_718 = uStack_1fe8;
    local_710 = local_1fe0;
    uStack_708 = uStack_1fd8;
    local_6d8 = uStack_1fa8;
    uStack_6d0 = local_1fa0;
    local_6a8 = uStack_1f78;
    local_6c8 = uStack_1f98;
    local_6b4 = uStack_1f84;
    local_6b0 = (undefined4)local_1f80;
    local_700 = local_1fd0;
    local_6ac = local_1f80._4_4_;
    local_730 = local_2000;
    uStack_728 = uStack_1ff8;
    local_6dc = uStack_1fac;
  }
  local_6db = local_2004;
  local_6d9 = local_2002;
  local_6c7 = local_2008;
  local_6c5 = local_2006;
  local_6b3 = local_200c;
  local_6b1 = local_200a;
  local_6f8 = 0;
  local_6f4 = CONCAT44(uVar47,uVar41);
  FUN_195ed0d6c(&local_730);
  local_2040 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_2038 = (undefined1)uVar59;
  uStack_2037 = (undefined2)((ulong)uVar59 >> 8);
  uStack_2035 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_2034 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_2028 = (undefined4)uVar13;
  uStack_2024 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_2023 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_2021 = (undefined1)((ulong)uVar13 >> 0x38);
  local_2030 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_202c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_2020 = <shadow.opacity>;
  uStack_2018 = <shadow.vibrancyContribution>;
  local_2010 = <shadow?nil>;
  local_2080 = <shadow.inset>;
  uStack_2078 = <shadow.blurRadius>;
  local_2070 = <shadow.shadowRadius>;
  uStack_2068 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_2048 = <shadow.ycc.dodgeFill.r>;
  uStack_2058 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_2054 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_2060 = (undefined4)<shadow.ycc.saturation>;
  uStack_205c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_2050 = (undefined4)uVar59;
  uStack_204c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_204b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_2049 = (undefined1)((ulong)uVar59 >> 0x38);
  local_20a0 = <shadow.offset.0>;
  uStack_2098 = <shadow.offset.1>;
  local_2090 = <shadow.amount>;
  uStack_2088 = <shadow.height>;
  iVar8 = (int)&local_20a0;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_76c = 1;
    local_740 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_77c = 0;
    uStack_774 = 0;
    local_754 = 0;
    uStack_74c = 0;
    uStack_798 = 0;
    local_738 = 0;
    local_7c0 = 0;
    uStack_7b8 = 0;
    local_788 = 0;
    local_790 = 0;
    local_758 = 1;
    local_744 = 1;
    local_73c = extraout_w11_05;
    local_7b0 = 0;
    uStack_7a8 = 0;
    local_768 = 0;
    uStack_760 = 0;
  }
  else {
    uVar41 = (undefined4)local_2080;
    uVar47 = (undefined4)((ulong)local_2080 >> 0x20);
    local_77c = CONCAT44(uStack_2058,uStack_205c);
    uStack_774 = CONCAT44(local_2050,uStack_2054);
    local_20a4 = uStack_204b;
    local_20a2 = uStack_2049;
    local_20a6 = uStack_2035;
    local_20a8 = uStack_2037;
    uStack_74c = CONCAT44(uStack_2028,uStack_202c);
    local_754 = CONCAT44(local_2030,uStack_2034);
    local_20aa = uStack_2021;
    local_20ac = uStack_2023;
    local_740 = (undefined4)local_2020;
    uStack_798 = uStack_2078;
    local_738 = uStack_2018;
    local_7c0 = local_20a0;
    uStack_7b8 = uStack_2098;
    local_788 = uStack_2068;
    local_790 = local_2070;
    local_758 = uStack_2038;
    local_744 = uStack_2024;
    local_73c = local_2020._4_4_;
    local_7b0 = local_2090;
    uStack_7a8 = uStack_2088;
    local_768 = uStack_2048;
    uStack_760 = local_2040;
    local_76c = uStack_204c;
  }
  local_76b = local_20a4;
  local_769 = local_20a2;
  local_757 = local_20a8;
  local_755 = local_20a6;
  local_743 = local_20ac;
  local_741 = local_20aa;
  local_7a0 = CONCAT44(uVar47,uVar41);
  local_780 = 1f;
  FUN_195ed0d6c(&local_7c0);
  local_20e0 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_20d8 = (undefined1)uVar59;
  uStack_20d7 = (undefined2)((ulong)uVar59 >> 8);
  uStack_20d5 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_20d4 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_20c8 = (undefined4)uVar13;
  uStack_20c4 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_20c3 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_20c1 = (undefined1)((ulong)uVar13 >> 0x38);
  local_20d0 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_20cc = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_20c0 = <shadow.opacity>;
  uStack_20b8 = <shadow.vibrancyContribution>;
  local_20b0 = <shadow?nil>;
  local_2120 = <shadow.inset>;
  uStack_2118 = <shadow.blurRadius>;
  local_2110 = <shadow.shadowRadius>;
  uStack_2108 = <shadow.ycc.black>;
  local_2100 = <shadow.ycc.saturation>;
  uStack_20f8 = <shadow.ycc.normalFill.g>;
  local_20f0 = <shadow.ycc.normalFill.a>;
  uStack_20e8 = <shadow.ycc.dodgeFill.r>;
  local_2140 = <shadow.offset.0>;
  uStack_2138 = <shadow.offset.1>;
  local_2130 = <shadow.amount>;
  uStack_2128 = <shadow.height>;
  iVar8 = (int)&local_2140;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_7e4 = 0;
    uStack_7dc = 0;
    local_7e8 = 1;
    local_7d0 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_840 = 0;
    uStack_838 = 0;
    local_830 = 0;
    uStack_828 = 0;
    local_7f8 = 0;
    uStack_7f0 = 0;
    local_7c8 = 0;
    local_7d4 = 1;
    local_810 = 0;
    local_820 = 0;
    local_7cc = extraout_w10;
    local_850 = 0;
    uStack_848 = 0;
  }
  else {
    uVar41 = (undefined4)uStack_2108;
    uVar47 = (undefined4)((ulong)uStack_2108 >> 0x20);
    local_2144 = local_20f0._5_2_;
    local_2142 = local_20f0._7_1_;
    local_2148 = uStack_20d7;
    local_2146 = uStack_20d5;
    local_7e4 = CONCAT44(local_20d0,uStack_20d4);
    uStack_7dc = CONCAT44(uStack_20c8,uStack_20cc);
    local_214a = uStack_20c1;
    local_214c = uStack_20c3;
    local_7d0 = (undefined4)local_20c0;
    local_840 = local_2130;
    uStack_838 = uStack_2128;
    local_830 = local_2120;
    uStack_828 = uStack_2118;
    local_7f8 = uStack_20e8;
    uStack_7f0 = local_20e0;
    local_7c8 = uStack_20b8;
    local_7d4 = uStack_20c4;
    local_810 = (undefined4)local_2100;
    local_820 = local_2110;
    local_7cc = local_20c0._4_4_;
    local_850 = local_2140;
    uStack_848 = uStack_2138;
    local_7e8 = uStack_20d8;
  }
  local_7fb = local_2144;
  local_7f9 = local_2142;
  local_7e7 = local_2148;
  local_7e5 = local_2146;
  local_7d3 = local_214c;
  local_7d1 = local_214a;
  local_818 = CONCAT44(uVar47,uVar41);
  uStack_804 = 0;
  local_80c = 0;
  local_7fc = 1;
  FUN_195ed0d6c(&local_850);
  local_2180 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_2178 = (undefined1)uVar59;
  uStack_2177 = (undefined2)((ulong)uVar59 >> 8);
  uStack_2175 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_2174 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_2168 = (undefined4)uVar13;
  uStack_2164 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_2163 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_2161 = (undefined1)((ulong)uVar13 >> 0x38);
  local_2170 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_216c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_2160 = <shadow.opacity>;
  uStack_2158 = <shadow.vibrancyContribution>;
  local_2150 = <shadow?nil>;
  local_21c0 = <shadow.inset>;
  uStack_21b8 = <shadow.blurRadius>;
  local_21b0 = <shadow.shadowRadius>;
  uStack_21a8 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_2188 = <shadow.ycc.dodgeFill.r>;
  uStack_2198 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_2194 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_21a0 = (undefined4)<shadow.ycc.saturation>;
  uStack_219c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_2190 = (undefined4)uVar59;
  uStack_218c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_218b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_2189 = (undefined1)((ulong)uVar59 >> 0x38);
  local_21e0 = <shadow.offset.0>;
  uStack_21d8 = <shadow.offset.1>;
  local_21d0 = <shadow.amount>;
  uStack_21c8 = <shadow.height>;
  iVar8 = (int)&local_21e0;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_860 = 0;
    local_89c = 0;
    uStack_894 = 0;
    local_874 = 0;
    uStack_86c = 0;
    local_8a0 = 0;
    local_858 = 0;
    local_8a8 = 0;
    local_8b0 = 0;
    local_8d0 = 0;
    uStack_8c8 = 0;
    local_88c = 1;
    local_878 = 1;
    local_864 = 1;
    local_85c = extraout_w10_00;
    local_8c0 = 0;
    uStack_8b8 = 0;
    local_888 = 0;
    uStack_880 = 0;
  }
  else {
    local_89c = CONCAT44(uStack_2198,uStack_219c);
    uStack_894 = CONCAT44(local_2190,uStack_2194);
    local_21e4 = uStack_218b;
    local_21e2 = uStack_2189;
    local_21e6 = uStack_2175;
    local_21e8 = uStack_2177;
    uStack_86c = CONCAT44(uStack_2168,uStack_216c);
    local_874 = CONCAT44(local_2170,uStack_2174);
    local_21ea = uStack_2161;
    local_21ec = uStack_2163;
    local_860 = (undefined4)local_2160;
    local_8a0 = local_21a0;
    local_858 = uStack_2158;
    local_8a8 = uStack_21a8;
    local_8b0 = local_21b0;
    local_8d0 = local_21d0;
    uStack_8c8 = uStack_21c8;
    local_88c = uStack_218c;
    local_878 = uStack_2178;
    local_864 = uStack_2164;
    local_85c = local_2160._4_4_;
    local_8c0 = local_21c0;
    uStack_8b8 = uStack_21b8;
    local_888 = uStack_2188;
    uStack_880 = local_2180;
  }
  local_88b = local_21e4;
  local_889 = local_21e2;
  local_877 = local_21e8;
  local_875 = local_21e6;
  local_863 = local_21ec;
  local_861 = local_21ea;
  uStack_8d8 = {d 2.6};
  local_8e0 = {d 0};
  FUN_195ed0d6c(&local_8e0);
  local_2220 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_2218 = (undefined1)uVar59;
  uStack_2217 = (undefined2)((ulong)uVar59 >> 8);
  uStack_2215 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_2214 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_2208 = (undefined4)uVar13;
  uStack_2204 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_2203 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_2201 = (undefined1)((ulong)uVar13 >> 0x38);
  local_2210 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_220c = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_2200 = <shadow.opacity>;
  uStack_21f8 = <shadow.vibrancyContribution>;
  local_21f0 = <shadow?nil>;
  local_2260 = <shadow.inset>;
  uStack_2258 = <shadow.blurRadius>;
  local_2250 = <shadow.shadowRadius>;
  uStack_2248 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_2228 = <shadow.ycc.dodgeFill.r>;
  uStack_2238 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_2234 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_2240 = (undefined4)<shadow.ycc.saturation>;
  uStack_223c = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_2230 = (undefined4)uVar59;
  uStack_222c = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_222b = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_2229 = (undefined1)((ulong)uVar59 >> 0x38);
  local_2280 = <shadow.offset.0>;
  uStack_2278 = <shadow.offset.1>;
  local_2270 = <shadow.amount>;
  uStack_2268 = <shadow.height>;
  iVar8 = (int)&local_2280;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_92c = 0;
    uStack_924 = 0;
    local_8f0 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_904 = 0;
    uStack_8fc = 0;
    local_960 = 0;
    uStack_958 = 0;
    local_950 = 0;
    uStack_948 = 0;
    local_918 = 0;
    uStack_910 = 0;
    local_91c = 1;
    local_908 = 1;
    local_8f4 = 1;
    local_930 = 0;
    local_940 = 0;
    local_8ec = extraout_w11_06;
    local_970 = 0;
    uStack_968 = 0;
  }
  else {
    uVar41 = (undefined4)uStack_2248;
    uVar47 = (undefined4)((ulong)uStack_2248 >> 0x20);
    local_92c = CONCAT44(uStack_2238,uStack_223c);
    uStack_924 = CONCAT44(local_2230,uStack_2234);
    local_2284 = uStack_222b;
    local_2282 = uStack_2229;
    local_2286 = uStack_2215;
    local_2288 = uStack_2217;
    uStack_8fc = CONCAT44(uStack_2208,uStack_220c);
    local_904 = CONCAT44(local_2210,uStack_2214);
    local_228a = uStack_2201;
    local_228c = uStack_2203;
    local_8f0 = (undefined4)local_2200;
    local_960 = local_2270;
    uStack_958 = uStack_2268;
    local_950 = local_2260;
    uStack_948 = uStack_2258;
    local_918 = uStack_2228;
    uStack_910 = local_2220;
    local_91c = uStack_222c;
    local_908 = uStack_2218;
    local_8f4 = uStack_2204;
    local_930 = local_2240;
    local_940 = local_2250;
    local_8ec = local_2200._4_4_;
    local_970 = local_2280;
    uStack_968 = uStack_2278;
  }
  local_91b = local_2284;
  local_919 = local_2282;
  local_907 = local_2288;
  local_905 = local_2286;
  local_8f3 = local_228c;
  local_8f1 = local_228a;
  local_938 = CONCAT44(uVar47,uVar41);
  local_8e8 = 0;
  FUN_195ed0d6c(&local_970);
  local_22c0 = <shadow.ycc.dodgeFill.b>;
  uVar59 = <shadow.ycc.dodgeFill?nil>;
  uVar13 = <shadow.ycc.burnFill.a>;
  uStack_22b8 = (undefined1)uVar59;
  uStack_22b7 = (undefined2)((ulong)uVar59 >> 8);
  uStack_22b5 = (undefined1)((ulong)uVar59 >> 0x18);
  uStack_22b4 = (undefined4)((ulong)uVar59 >> 0x20);
  uStack_22a8 = (undefined4)uVar13;
  uStack_22a4 = (undefined1)((ulong)uVar13 >> 0x20);
  uStack_22a3 = (undefined2)((ulong)uVar13 >> 0x28);
  uStack_22a1 = (undefined1)((ulong)uVar13 >> 0x38);
  local_22b0 = (undefined4)<shadow.ycc.burnFill.g>;
  uStack_22ac = (undefined4)((ulong)<shadow.ycc.burnFill.g> >> 0x20);
  local_22a0 = <shadow.opacity>;
  uStack_2298 = <shadow.vibrancyContribution>;
  local_2290 = <shadow?nil>;
  local_2300 = <shadow.inset>;
  uStack_22f8 = <shadow.blurRadius>;
  local_22f0 = <shadow.shadowRadius>;
  uStack_22e8 = <shadow.ycc.black>;
  uVar59 = <shadow.ycc.normalFill.a>;
  uStack_22c8 = <shadow.ycc.dodgeFill.r>;
  uStack_22d8 = (undefined4)<shadow.ycc.normalFill.g>;
  uStack_22d4 = (undefined4)((ulong)<shadow.ycc.normalFill.g> >> 0x20);
  local_22e0 = (undefined4)<shadow.ycc.saturation>;
  uStack_22dc = (undefined4)((ulong)<shadow.ycc.saturation> >> 0x20);
  local_22d0 = (undefined4)uVar59;
  uStack_22cc = (undefined1)((ulong)uVar59 >> 0x20);
  uStack_22cb = (undefined2)((ulong)uVar59 >> 0x28);
  uStack_22c9 = (undefined1)((ulong)uVar59 >> 0x38);
  local_2320 = <shadow.offset.0>;
  uStack_2318 = <shadow.offset.1>;
  local_2310 = <shadow.amount>;
  uStack_2308 = <shadow.height>;
  iVar8 = (int)&local_2320;
  FUN_195e7da18();
  if (iVar8 == 1) {
    local_9ac = 1;
    local_9c0 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_9bc = 0;
    uStack_9b4 = 0;
    local_994 = 0;
    uStack_98c = 0;
    uStack_9d8 = 0;
    local_9a8 = 0;
    uStack_9a0 = 0;
    local_978 = 0;
    local_a00 = 0;
    uStack_9f8 = 0;
    local_9c8 = 0;
    local_9d0 = 0;
    local_998 = 1;
    local_984 = 1;
    local_97c = extraout_w11_07;
    local_9f0 = 0;
    uStack_9e8 = 0;
  }
  else {
    uVar41 = (undefined4)local_2300;
    uVar47 = (undefined4)((ulong)local_2300 >> 0x20);
    local_9bc = CONCAT44(uStack_22d8,uStack_22dc);
    uStack_9b4 = CONCAT44(local_22d0,uStack_22d4);
    local_2324 = uStack_22cb;
    local_2322 = uStack_22c9;
    local_2326 = uStack_22b5;
    local_2328 = uStack_22b7;
    uStack_98c = CONCAT44(uStack_22a8,uStack_22ac);
    local_994 = CONCAT44(local_22b0,uStack_22b4);
    local_232a = uStack_22a1;
    local_232c = uStack_22a3;
    uStack_9d8 = uStack_22f8;
    local_9a8 = uStack_22c8;
    uStack_9a0 = local_22c0;
    local_978 = uStack_2298;
    local_a00 = local_2320;
    uStack_9f8 = uStack_2318;
    local_9c8 = uStack_22e8;
    local_9d0 = local_22f0;
    local_998 = uStack_22b8;
    local_984 = uStack_22a4;
    local_97c = local_22a0._4_4_;
    local_9f0 = local_2310;
    uStack_9e8 = uStack_2308;
    local_9c0 = local_22e0;
    local_9ac = uStack_22cc;
  }
  local_9ab = local_2324;
  local_9a9 = local_2322;
  local_997 = local_2328;
  local_995 = local_2326;
  local_983 = local_232c;
  local_981 = local_232a;
  local_9e0 = CONCAT44(uVar47,uVar41);
  local_980 = 0;
  FUN_195ed0d6c(&local_a00);
  uVar59 = {d 20};
  <refraction.innerAmount> = {d -50};
  <refraction.innerHeight> = uVar59;
  uVar59 = {d 16};
  <refraction.outerAmount> = {d 10};
  <refraction.outerHeight> = uVar59;
  uVar59 = {d 4};
  <refraction.outerDistances.1> = {d -1};
  <refraction.outerDistances.0> = uVar59;
  <refraction.outerOpacity> = 0;
  <refraction?nil> = 0;
  if (<faceEffects?nil> == '\x01') {
    pfVar28 = &DAT_1eda46354;
    pfVar30 = &DAT_1eda46350;
    puVar25 = &DAT_1eda4634c;
    puVar26 = (uint3 *)((long)&DAT_1eda46334 + 5);
    if (DAT_1eda3b1e0 != -1) {
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    }
    bVar7 = true;
    puVar20 = (uint3 *)((long)&DAT_1eda46324 + 1);
  }
  else {
    puVar25 = (uint *)(<faceEffects.ycc.burnFill?nil>);
    pfVar28 = (float *)(<faceEffects.maxLuminanceSDR>);
    puVar26 = local_47e0 + 5;
    pfVar30 = (float *)(<faceEffects.maxLuminance>);
    bVar7 = DAT_1eda3b1e0 == -1;
    puVar20 = local_47e0;
  }
  fVar57 = *pfVar28;
  fVar58 = *pfVar30;
  uVar24 = *puVar25;
  uVar4 = *puVar20;
  uVar5 = *puVar26;
  if (!bVar7) {
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
  }
  if ((((((DAT_1eda46304 == 0.0) && (DAT_1eda46308 == 0.0)) && (DAT_1eda4630c == 1.0)) &&
       ((DAT_1eda46310 == 1.0 && ((char)DAT_1eda46324 == '\x01')))) &&
      ((DAT_1eda46334._4_1_ == '\x01' &&
       (((char)DAT_1eda4634c == '\x01' && (fVar58 == DAT_1eda46350)))))) &&
     (fVar57 == DAT_1eda46354)) {
    uVar59 = 0;
    uVar21 = 0;
    uVar22 = 0;
    fVar57 = 0.0;
    auVar44 = ZEXT816(0);
    uVar34 = 1;
  }
  else {
    uVar34 = 0;
    auVar42 = NEON_ext(ZEXT316(uVar4),ZEXT316(uVar4),0xf,1);
    auVar45._1_15_ = auVar42._1_15_;
    auVar45[0] = 1;
    uVar21 = (ulong)uVar5 << 0x28 | 0x100000000;
    auVar44._4_12_ = SUB1612(ZEXT816(0),4);
    auVar44._0_4_ = auVar45._0_4_;
    uVar22 = (ulong)uVar24 & 0xffffff00 | (ulong)(uint)fVar58 << 0x20 | 1;
    uVar59 = 0.0078125;
  }
  <faceEffects.opacity> = 0;
  <faceEffects.ycc.white> = uVar59;
  <faceEffects.ycc.normalFill.r> = 0;
  <faceEffects.ycc.normalFill.b> = 0;
  <faceEffects.ycc.dodgeFill.g> = auVar44._8_8_;
  <faceEffects.ycc.normalFill?nil> = auVar44._0_8_;
  <faceEffects.ycc.dodgeFill.a> = uVar21;
  <faceEffects.ycc.burnFill.r> = 0;
  <faceEffects.ycc.burnFill.b> = 0;
  <faceEffects.ycc.burnFill?nil> = uVar22;
  <faceEffects.maxLuminanceSDR> = fVar57;
  <faceEffects?nil> = uVar34;
  func_0x000198104610(&local_2440,<highlights.hdr>,0x10d);
  iVar8 = (int)&local_2440;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_23d4 = 0;
    local_23cc = 0;
    local_2384 = 0;
    local_237c = 0;
    local_2370 = 0;
    local_2368 = 0;
    local_235c = 0;
    uVar24 = 0;
    local_2438 = 0;
    local_2440 = 0;
    uVar46 = 0;
    uVar50 = 0;
    local_af8 = 0;
    local_2420 = 0;
    local_2418 = 0;
    local_2410 = 0;
    uVar35 = 1;
    uVar37 = 1;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_2390 = 0;
    local_238c = 0;
    local_2388 = 0;
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_4800 = CONCAT44(local_4800._4_4_,1);
    local_4808 = CONCAT44(local_4808._4_4_,1);
    local_2348 = 0;
    local_2340 = 0;
    local_233c = 0;
    local_2338 = 0;
    uVar59 = 0;
    uVar21 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    uVar41 = 0;
    uVar47 = 0;
    local_243c = param_5;
    local_2424 = param_7;
    uVar60 = 0;
  }
  else {
    uVar46 = (undefined4)local_2430;
    uVar50 = (undefined4)((ulong)local_2430 >> 0x20);
    uVar35 = (uint)local_23ec;
    local_2444 = local_23eb;
    local_2442 = local_23e9;
    uVar37 = (uint)local_23d8;
    local_2446 = local_23d5;
    local_2448 = local_23d7;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_23c4);
    local_244a = local_23c1;
    local_244c = local_23c3;
    local_4810 = (code *)CONCAT44(local_4810._4_4_,local_23ac);
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_2374);
    local_244e = local_2371;
    local_2450 = local_2373;
    local_4800 = CONCAT44(local_4800._4_4_,(uint)local_2360);
    local_2452 = local_235d;
    local_2454 = local_235f;
    local_4808 = CONCAT44(local_4808._4_4_,(uint)local_234c);
    local_2456 = local_2349;
    local_2458 = local_234b;
    uVar24 = (uint)local_2334;
    uVar59 = local_2354;
    uVar21 = local_23fc;
    uVar13 = local_23f4;
    uVar14 = local_23e8;
    uVar16 = local_23e0;
    uVar18 = local_23c0;
    uVar23 = local_23b8;
    uVar54 = local_23a8;
    uVar55 = local_23a0;
    uVar56 = local_2398;
    uVar41 = local_2400;
    uVar47 = local_23b0;
    local_af8 = local_2428;
    uVar60 = local_2404;
  }
  local_245c = local_2450;
  local_245a = local_244e;
  local_2460 = local_2454;
  local_245e = local_2452;
  local_2464 = local_2458;
  local_2462 = local_2456;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_2440);
  local_4850 = CONCAT44(local_4850._4_4_,local_243c);
  local_4868 = CONCAT44(uVar50,uVar46);
  local_b00 = CONCAT44(uVar50,uVar46);
  local_4888 = CONCAT44(local_4888._4_4_,local_af8);
  local_4860 = CONCAT44(local_4860._4_4_,local_2424);
  local_ad8 = 0.25f;
  local_4878 = CONCAT44(local_4878._4_4_,uVar35);
  local_abc = (undefined1)uVar35;
  local_abb = local_2444;
  local_ab9 = local_2442;
  local_4880 = CONCAT44(local_4880._4_4_,uVar37);
  local_aa8 = (undefined1)uVar37;
  local_aa7 = local_2448;
  local_aa5 = local_2446;
  local_a94 = SUB81(local_47e0,0);
  local_a91 = local_244a;
  local_a93 = local_244c;
  local_a7c = local_4810._0_4_;
  local_48b8 = CONCAT44(local_48b8._4_4_,local_2390);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_238c);
  local_48c8 = CONCAT44(local_48c8._4_4_,local_2388);
  local_a44 = (undefined1)local_47f8;
  local_a41 = local_244e;
  local_a43 = local_2450;
  local_a30 = (undefined1)local_4800;
  local_a2d = local_2452;
  local_a2f = local_2454;
  local_a1c = (undefined1)local_4808;
  local_a19 = local_2456;
  local_a1b = local_2458;
  local_48d8 = CONCAT44(local_48d8._4_4_,local_2340);
  local_48e0 = CONCAT44(local_48e0._4_4_,local_233c);
  local_48e8 = CONCAT44(local_48e8._4_4_,local_2338);
  local_4870 = CONCAT44(local_4870._4_4_,uVar24);
  local_a04 = (undefined1)uVar24;
  local_1b00[0] = 0;
  local_1af0 = 0;
  local_1af8 = 0;
  local_1ae8 = 0;
  local_1ab0 = 0;
  uStack_1ab8 = 0;
  local_1ac0 = 0;
  uStack_1ac8 = 0;
  local_1ad0 = 0;
  uStack_1ad8 = 0;
  local_1ae0 = 0;
  local_1aac = 1;
  local_1aa0 = 0;
  local_1aa8 = 0;
  local_1a98 = 1;
  local_1a8c = 0;
  local_1a94 = 0;
  local_1a84 = 1;
  local_1a78 = 0;
  local_1a80 = 0;
  local_1a70 = 0;
  local_1a38 = 0;
  uStack_1a40 = 0;
  local_1a48 = 0;
  uStack_1a50 = 0;
  local_1a58 = 0;
  uStack_1a60 = 0;
  local_1a68 = 0;
  local_1a34 = 1;
  local_1a28 = 0;
  local_1a30 = 0;
  local_1a20 = 1;
  local_1a14 = 0;
  local_1a1c = 0;
  local_1a0c = 1;
  uStack_19f8 = 0;
  uStack_1a00 = 0;
  local_19fb = 0;
  local_1a08 = 0;
  puVar12 = &local_b10;
  local_48d0 = local_2348;
  local_48b0 = local_2438;
  local_48a0 = local_2410;
  local_4898 = local_2418;
  local_4890 = local_2420;
  local_4858 = uVar59;
  local_4848 = local_235c;
  local_4840 = local_2368;
  local_4838 = local_2370;
  local_4830 = local_237c;
  local_4828 = local_2384;
  local_4820 = local_23cc;
  local_4818 = local_23d4;
  local_b10 = local_2440;
  local_b0c = local_243c;
  local_b08 = local_2438;
  local_af4 = local_2424;
  local_af0 = local_2420;
  local_ae8 = local_2418;
  local_ae0 = local_2410;
  local_ad4 = uVar60;
  local_ad0 = uVar41;
  local_acc = uVar21;
  local_ac4 = uVar13;
  local_ab8 = uVar14;
  local_ab0 = uVar16;
  local_aa4 = local_23d4;
  local_a9c = local_23cc;
  local_a90 = uVar18;
  local_a88 = uVar23;
  local_a80 = uVar47;
  local_a78 = uVar54;
  local_a70 = uVar55;
  local_a68 = uVar56;
  local_a60 = local_2390;
  local_a5c = local_238c;
  local_a58 = local_2388;
  local_a54 = local_2384;
  local_a4c = local_237c;
  local_a40 = local_2370;
  local_a38 = local_2368;
  local_a2c = local_235c;
  local_a24 = uVar59;
  local_a18 = local_2348;
  local_a10 = local_2340;
  local_a0c = local_233c;
  local_a08 = local_2338;
  FUN_195ed8068(puVar12,local_1b00);
  uVar46 = (undefined4)uVar59;
  if (((ulong)puVar12 & 1) == 0) {
    local_c20 = (undefined4)local_48a8;
    local_c1c = (undefined4)local_4850;
    local_c18 = local_48b0;
    local_c10 = local_4868;
    local_c08 = (undefined4)local_4888;
    local_c04 = (undefined4)local_4860;
    local_c00 = local_4890;
    local_bf8 = local_4898;
    local_bf0 = local_48a0;
    local_be8 = 0.25f;
    local_bcc = (undefined1)local_4878;
    local_bcb = local_2444;
    local_bc9 = local_2442;
    local_bb8 = (undefined1)local_4880;
    local_bb5 = local_2446;
    local_bb7 = local_2448;
    local_bb4 = local_4818;
    local_bac = local_4820;
    local_ba4 = SUB81(local_47e0,0);
    local_ba1 = local_244a;
    local_ba3 = local_244c;
    local_b8c = local_4810._0_4_;
    local_b70 = (undefined4)local_48b8;
    local_b6c = (undefined4)local_48c0;
    local_b68 = (undefined4)local_48c8;
    local_b64 = local_4828;
    local_b5c = local_4830;
    local_b54 = (undefined1)local_47f8;
    local_b51 = local_245a;
    local_b53 = local_245c;
    local_b50 = local_4838;
    local_b48 = local_4840;
    local_b40 = (undefined1)local_4800;
    local_b3d = local_245e;
    local_b3f = local_2460;
    local_b3c = local_4848;
    local_b34 = local_4858;
    local_b2c = (undefined1)local_4808;
    local_b29 = local_2462;
    local_b2b = local_2464;
    local_b28 = local_48d0;
    local_b20 = (undefined4)local_48d8;
    local_b1c = (undefined4)local_48e0;
    local_b18 = (undefined4)local_48e8;
    local_b14 = (undefined1)local_4870;
    local_be4 = uVar60;
    local_be0 = uVar41;
    local_bdc = uVar21;
    local_bd4 = uVar13;
    local_bc8 = uVar14;
    local_bc0 = uVar16;
    local_ba0 = uVar18;
    local_b98 = uVar23;
    local_b90 = uVar47;
    local_b88 = uVar54;
    local_b80 = uVar55;
    local_b78 = uVar56;
    _CGPointMake(&local_c20);
    func_0x000198104610(auStack_2578,&local_c20,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_2578);
  }
  func_0x000198104610(<highlights.hdr>,auStack_2578,0x10d);
  func_0x000198104610(&local_2688,auStack_2578,0x10d);
  iVar8 = (int)&local_2688;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    uVar24 = 0;
    local_259c = 0;
    local_25a4 = 0;
    local_25b0 = 0;
    local_25b8 = 0;
    local_25c4 = 0;
    local_25cc = 0;
    local_261c = 0;
    local_25e8 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_25f0 = 0;
    uVar38 = 1;
    uVar35 = 1;
    local_25f8 = 0;
    local_2600 = 0;
    local_2608 = 0;
    uVar37 = 1;
    uVar29 = 1;
    uVar27 = 1;
    local_2648 = 0;
    local_2688 = 0;
    local_2680 = 0;
    local_2678 = 0;
    local_2670 = 0;
    local_2668 = 0;
    local_2660 = 0;
    local_2658 = 0;
    local_2650 = 0;
    uVar22 = 0;
    uVar59 = 0;
    uVar31 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar41 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar50 = 0;
    uVar52 = 0;
    uVar49 = 0;
    local_c04 = (int)&local_b10;
  }
  else {
    uVar21 = (ulong)local_2684;
    uVar27 = (uint)local_2634;
    local_268c = local_2633;
    local_268a = local_2631;
    uVar29 = (uint)local_2620;
    local_268e = local_261d;
    local_2690 = local_261f;
    uVar37 = (uint)local_260c;
    local_2692 = local_2609;
    local_2694 = local_260b;
    uVar35 = (uint)local_25bc;
    local_2696 = local_25b9;
    local_2698 = local_25bb;
    uVar38 = (uint)local_25a8;
    local_269a = local_25a5;
    local_269c = local_25a7;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_2594);
    local_269e = local_2591;
    local_26a0 = local_2593;
    uVar24 = (uint)local_257c;
    uVar22 = local_263c;
    uVar59 = local_2644;
    uVar31 = local_2628;
    uVar13 = local_2630;
    uVar14 = local_2614;
    uVar41 = local_2584;
    uVar16 = local_25e0;
    uVar18 = local_2590;
    uVar46 = local_25f4;
    uVar47 = local_25d8;
    uVar60 = local_25d4;
    uVar50 = local_25d0;
    uVar52 = local_2588;
    uVar49 = local_2580;
    local_c04 = local_266c;
  }
  local_4898 = CONCAT44(local_4898._4_4_,local_2688);
  local_c1c = (undefined4)uVar21;
  local_48a0 = CONCAT44(local_48a0._4_4_,local_c1c);
  local_48b8 = CONCAT44(local_48b8._4_4_,local_2670);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_c04);
  local_48e0 = CONCAT44(local_48e0._4_4_,local_2650);
  local_be4 = 2f;
  local_4890 = CONCAT44(local_4890._4_4_,local_2648);
  local_4880 = CONCAT44(local_4880._4_4_,uVar27);
  local_bcc = (undefined1)uVar27;
  local_bc9 = local_268a;
  local_bcb = local_268c;
  local_4878 = CONCAT44(local_4878._4_4_,uVar29);
  local_bb8 = (undefined1)uVar29;
  local_bb7 = local_2690;
  local_bb5 = local_268e;
  local_4870 = CONCAT44(local_4870._4_4_,uVar37);
  local_ba4 = (undefined1)uVar37;
  local_ba3 = local_2694;
  local_ba1 = local_2692;
  local_4850 = CONCAT44(local_4850._4_4_,local_25f8);
  local_4848 = CONCAT44(local_4848._4_4_,uVar46);
  local_4858 = CONCAT44(local_4858._4_4_,uVar35);
  local_b54 = (undefined1)uVar35;
  local_b51 = local_2696;
  local_b53 = local_2698;
  local_4888 = CONCAT44(local_4888._4_4_,uVar38);
  local_b40 = (undefined1)uVar38;
  local_b3d = local_269a;
  local_b3f = local_269c;
  local_b2c = SUB81(local_47e0,0);
  local_b29 = local_269e;
  local_b2b = local_26a0;
  local_4830 = CONCAT44(local_4830._4_4_,uVar24);
  local_b14 = (undefined1)uVar24;
  puVar12 = &local_c20;
  local_48d8 = local_2658;
  local_48d0 = local_2660;
  local_48c8 = local_2668;
  local_48b0 = local_2678;
  local_48a8 = local_2680;
  local_4868 = local_2608;
  local_4860 = local_2600;
  local_4840 = local_25f0;
  local_4838 = local_25e8;
  local_4828 = local_25a4;
  local_4820 = local_259c;
  local_4818 = local_25b8;
  local_4810 = (code *)local_25b0;
  local_4808 = local_25cc;
  local_4800 = local_25c4;
  local_47f8 = local_261c;
  local_c20 = local_2688;
  local_c18 = local_2680;
  local_c10 = local_2678;
  local_c08 = local_2670;
  local_c00 = local_2668;
  local_bf8 = local_2660;
  local_bf0 = local_2658;
  local_be8 = local_2650;
  local_be0 = local_2648;
  local_bdc = uVar59;
  local_bd4 = uVar22;
  local_bc8 = uVar13;
  local_bc0 = uVar31;
  local_bb4 = local_261c;
  local_bac = uVar14;
  local_ba0 = local_2608;
  local_b98 = local_2600;
  local_b90 = local_25f8;
  local_b8c = uVar46;
  local_b88 = local_25f0;
  local_b80 = local_25e8;
  local_b78 = uVar16;
  local_b70 = uVar47;
  local_b6c = uVar60;
  local_b68 = uVar50;
  local_b64 = local_25cc;
  local_b5c = local_25c4;
  local_b50 = local_25b8;
  local_b48 = local_25b0;
  local_b3c = local_25a4;
  local_b34 = local_259c;
  local_b28 = uVar18;
  local_b20 = uVar52;
  local_b1c = uVar41;
  local_b18 = uVar49;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_d30 = (undefined4)local_4898;
    local_d2c = (undefined4)local_48a0;
    local_d28 = local_48a8;
    local_d20 = local_48b0;
    local_d18 = (undefined4)local_48b8;
    local_d14 = (undefined4)local_48c0;
    local_d10 = local_48c8;
    local_d08 = local_48d0;
    local_d00 = local_48d8;
    local_cf8 = (undefined4)local_48e0;
    local_cf4 = 2f;
    local_cf0 = (undefined4)local_4890;
    local_cdc = (undefined1)local_4880;
    local_cdb = local_268c;
    local_cd9 = local_268a;
    local_cc8 = (undefined1)local_4878;
    local_cc5 = local_268e;
    local_cc7 = local_2690;
    local_cc4 = local_47f8;
    local_cb4 = (undefined1)local_4870;
    local_cb1 = local_2692;
    local_cb3 = local_2694;
    local_cb0 = local_4868;
    local_ca8 = local_4860;
    local_ca0 = (undefined4)local_4850;
    local_c9c = (undefined4)local_4848;
    local_c98 = local_4840;
    local_c90 = local_4838;
    local_c74 = local_4808;
    local_c6c = local_4800;
    local_c64 = (undefined1)local_4858;
    local_c61 = local_2696;
    local_c63 = local_2698;
    local_c60 = local_4818;
    local_c58 = local_4810;
    local_c50 = (undefined1)local_4888;
    local_c4d = local_269a;
    local_c4f = local_269c;
    local_c4c = local_4828;
    local_c44 = local_4820;
    local_c3c = SUB81(local_47e0,0);
    local_c39 = local_269e;
    local_c3b = local_26a0;
    local_c24 = (undefined1)local_4830;
    local_cec = uVar59;
    local_ce4 = uVar22;
    local_cd8 = uVar13;
    local_cd0 = uVar31;
    local_cbc = uVar14;
    local_c88 = uVar16;
    local_c80 = uVar47;
    local_c7c = uVar60;
    local_c78 = uVar50;
    local_c38 = uVar18;
    local_c30 = uVar52;
    local_c2c = uVar41;
    local_c28 = uVar49;
    _CGPointMake(&local_d30);
    func_0x000198104610(auStack_27b0,&local_d30,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_27b0);
  }
  func_0x000198104610(<highlights.hdr>,auStack_27b0,0x10d);
  func_0x000198104610(&local_28c0,auStack_27b0,0x10d);
  iVar8 = (int)&local_28c0;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    uVar24 = 0;
    local_27d4 = 0;
    local_27e8 = 0;
    local_27f0 = 0;
    local_27fc = 0;
    local_2804 = 0;
    local_2854 = 0;
    local_2820 = 0;
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_2828 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    uVar35 = 1;
    local_2830 = 0;
    local_2838 = 0;
    local_2840 = 0;
    uVar37 = 1;
    uVar29 = 1;
    uVar27 = 1;
    local_28c0 = 0;
    local_28b8 = 0;
    local_28b0 = 0;
    local_28a8 = 0;
    local_28a0 = 0;
    local_2898 = 0;
    local_2890 = 0;
    local_2888 = 0;
    local_2884 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar41 = 0;
    uVar54 = 0;
    uVar55 = 0;
    local_282c = uVar46;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar52 = 0;
  }
  else {
    uVar31 = (ulong)local_28bc;
    uVar22 = (ulong)local_28a4;
    uVar27 = (uint)local_286c;
    local_28c4 = local_286b;
    local_28c2 = local_2869;
    uVar29 = (uint)local_2858;
    local_28c6 = local_2855;
    local_28c8 = local_2857;
    uVar37 = (uint)local_2844;
    local_28ca = local_2841;
    local_28cc = local_2843;
    uVar35 = (uint)local_27f4;
    local_28ce = local_27f1;
    local_28d0 = local_27f3;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_27e0);
    local_28d2 = local_27dd;
    local_28d4 = local_27df;
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_27cc);
    local_28d6 = local_27c9;
    local_28d8 = local_27cb;
    uVar24 = (uint)local_27b4;
    uVar59 = local_27dc;
    uVar13 = local_2874;
    uVar14 = local_287c;
    uVar16 = local_2860;
    uVar18 = local_2868;
    uVar23 = local_284c;
    uVar41 = local_27bc;
    uVar54 = local_2818;
    uVar55 = local_27c8;
    uVar47 = local_2810;
    uVar60 = local_280c;
    uVar46 = local_2808;
    uVar50 = local_27c0;
    uVar52 = local_27b8;
  }
  local_4890 = CONCAT44(local_4890._4_4_,local_28c0);
  local_d2c = (undefined4)uVar31;
  local_4898 = CONCAT44(local_4898._4_4_,local_d2c);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_28a8);
  local_d14 = (undefined4)uVar22;
  local_48b8 = CONCAT44(local_48b8._4_4_,local_d14);
  local_48d8 = CONCAT44(local_48d8._4_4_,local_2888);
  local_48e0 = CONCAT44(local_48e0._4_4_,local_2884);
  local_cf0 = 1f;
  local_4888 = CONCAT44(local_4888._4_4_,uVar27);
  local_cdc = (undefined1)uVar27;
  local_cd9 = local_28c2;
  local_cdb = local_28c4;
  local_4880 = CONCAT44(local_4880._4_4_,uVar29);
  local_cc8 = (undefined1)uVar29;
  local_cc7 = local_28c8;
  local_cc5 = local_28c6;
  local_4878 = CONCAT44(local_4878._4_4_,uVar37);
  local_cb4 = (undefined1)uVar37;
  local_cb3 = local_28cc;
  local_cb1 = local_28ca;
  local_4858 = CONCAT44(local_4858._4_4_,local_2830);
  local_4850 = CONCAT44(local_4850._4_4_,local_282c);
  local_4860 = CONCAT44(local_4860._4_4_,uVar35);
  local_c64 = (undefined1)uVar35;
  local_c61 = local_28ce;
  local_c63 = local_28d0;
  local_c50 = SUB81(local_47e0,0);
  local_c4d = local_28d2;
  local_c4f = local_28d4;
  local_c3c = (undefined1)local_47f8;
  local_c39 = local_28d6;
  local_c3b = local_28d8;
  local_4838 = CONCAT44(local_4838._4_4_,uVar24);
  local_c24 = (undefined1)uVar24;
  puVar12 = &local_d30;
  local_48d0 = local_2890;
  local_48c8 = local_2898;
  local_48c0 = local_28a0;
  local_48a8 = local_28b0;
  local_48a0 = local_28b8;
  local_4870 = local_2840;
  local_4868 = local_2838;
  local_4848 = local_2828;
  local_4840 = local_2820;
  local_4830 = uVar59;
  local_4828 = local_27d4;
  local_4820 = local_27f0;
  local_4818 = local_27e8;
  local_4810 = (code *)local_2804;
  local_4808 = local_27fc;
  local_4800 = local_2854;
  local_d30 = local_28c0;
  local_d28 = local_28b8;
  local_d20 = local_28b0;
  local_d18 = local_28a8;
  local_d10 = local_28a0;
  local_d08 = local_2898;
  local_d00 = local_2890;
  local_cf8 = local_2888;
  local_cf4 = local_2884;
  local_cec = uVar14;
  local_ce4 = uVar13;
  local_cd8 = uVar18;
  local_cd0 = uVar16;
  local_cc4 = local_2854;
  local_cbc = uVar23;
  local_cb0 = local_2840;
  local_ca8 = local_2838;
  local_ca0 = local_2830;
  local_c9c = local_282c;
  local_c98 = local_2828;
  local_c90 = local_2820;
  local_c88 = uVar54;
  local_c80 = uVar47;
  local_c7c = uVar60;
  local_c78 = uVar46;
  local_c74 = local_2804;
  local_c6c = local_27fc;
  local_c60 = local_27f0;
  local_c58 = local_27e8;
  local_c4c = uVar59;
  local_c44 = local_27d4;
  local_c38 = uVar55;
  local_c30 = uVar50;
  local_c2c = uVar41;
  local_c28 = uVar52;
  FUN_195ed8068(puVar12,local_1b00);
  uVar49 = (undefined4)uVar59;
  if (((ulong)puVar12 & 1) == 0) {
    local_e40 = (undefined4)local_4890;
    local_e3c = (undefined4)local_4898;
    local_e38 = local_48a0;
    local_e30 = local_48a8;
    local_e28 = (undefined4)local_48b0;
    local_e24 = (undefined4)local_48b8;
    local_e20 = local_48c0;
    local_e18 = local_48c8;
    local_e10 = local_48d0;
    local_e08 = (undefined4)local_48d8;
    local_e04 = (undefined4)local_48e0;
    local_e00 = 1f;
    local_dec = (undefined1)local_4888;
    local_deb = local_28c4;
    local_de9 = local_28c2;
    local_dd8 = (undefined1)local_4880;
    local_dd5 = local_28c6;
    local_dd7 = local_28c8;
    local_dd4 = local_4800;
    local_dc4 = (undefined1)local_4878;
    local_dc1 = local_28ca;
    local_dc3 = local_28cc;
    local_dc0 = local_4870;
    local_db8 = local_4868;
    local_db0 = (undefined4)local_4858;
    local_dac = (undefined4)local_4850;
    local_da8 = local_4848;
    local_da0 = local_4840;
    local_d84 = local_4810;
    local_d7c = local_4808;
    local_d74 = (undefined1)local_4860;
    local_d71 = local_28ce;
    local_d73 = local_28d0;
    local_d70 = local_4820;
    local_d68 = local_4818;
    local_d60 = SUB81(local_47e0,0);
    local_d5d = local_28d2;
    local_d5f = local_28d4;
    local_d5c = local_4830;
    local_d54 = local_4828;
    local_d4c = (undefined1)local_47f8;
    local_d49 = local_28d6;
    local_d4b = local_28d8;
    local_d34 = (undefined1)local_4838;
    local_dfc = uVar14;
    local_df4 = uVar13;
    local_de8 = uVar18;
    local_de0 = uVar16;
    local_dcc = uVar23;
    local_d98 = uVar54;
    local_d90 = uVar47;
    local_d8c = uVar60;
    local_d88 = uVar46;
    local_d48 = uVar55;
    local_d40 = uVar50;
    local_d3c = uVar41;
    local_d38 = uVar52;
    _CGPointMake(&local_e40);
    func_0x000198104610(auStack_29e8,&local_e40,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_29e8);
  }
  func_0x000198104610(<highlights.hdr>,auStack_29e8,0x10d);
  lVar9 = local_47f0;
  local_47d8 = (undefined8 *)((long)local_47d8 + 0x68);
  local_4810 = (code *)*local_47d8;
  local_4808 = CONCAT44(local_4808._4_4_,*_DAT_1e01830d0);
  (*local_4810)(local_47f0,*_DAT_1e01830d0,local_47e8);
  uVar47 = 1f;
  uVar41 = func_0x0001981218c0(lVar9);
  func_0x000198104610(&local_2af8,<highlights.hdr>,0x10d);
  iVar8 = (int)&local_2af8;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    uVar35 = 0;
    local_2a0c = 0;
    local_2a14 = 0;
    local_2a20 = 0;
    local_2a28 = 0;
    local_2a34 = 0;
    local_2a3c = 0;
    local_2a8c = 0;
    uVar48 = 0;
    uVar51 = 0;
    uVar37 = 1;
    uVar27 = 1;
    local_2a40 = 0;
    uVar29 = 1;
    local_2a44 = 0;
    local_2a48 = 0;
    local_2a50 = 0;
    local_2a58 = 0;
    local_2a60 = 0;
    local_2a68 = 0;
    local_2a70 = 0;
    local_2a78 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    uVar38 = 1;
    local_2ad8 = 0;
    local_2ad0 = 0;
    local_2ac8 = 0;
    local_2ac0 = 0;
    local_2abc = 0;
    local_2ab8 = 0;
    uVar21 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    local_2a64 = 0x95f19e90;
    uVar16 = 0;
    local_2af4 = uVar49;
    local_2adc = uVar24;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar52 = 0;
    uVar49 = 0;
  }
  else {
    uVar48 = (undefined4)local_2ae8;
    uVar51 = (undefined4)((ulong)local_2ae8 >> 0x20);
    local_2afc = local_2aa3;
    local_2afa = local_2aa1;
    uVar38 = (uint)local_2a90;
    local_2afe = local_2a8d;
    local_2b00 = local_2a8f;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_2a7c);
    local_2b02 = local_2a79;
    local_2b04 = local_2a7b;
    uVar29 = (uint)local_2a2c;
    local_2b06 = local_2a29;
    local_2b08 = local_2a2b;
    uVar27 = (uint)local_2a18;
    local_2b0a = local_2a15;
    local_2b0c = local_2a17;
    uVar37 = (uint)local_2a04;
    local_2b0e = local_2a01;
    local_2b10 = local_2a03;
    uVar35 = (uint)local_29ec;
    uVar21 = local_2a98;
    uVar59 = local_2aa0;
    uVar13 = local_2a84;
    uVar14 = local_2a00;
    uVar16 = local_2af0;
    uVar60 = local_2af8;
    uVar46 = local_2ae0;
    uVar50 = local_29f8;
    uVar52 = local_29f4;
    uVar49 = local_29f0;
  }
  local_4848 = CONCAT44(local_4848._4_4_,local_2af4);
  local_e30 = CONCAT44(uVar51,uVar48);
  local_4850 = CONCAT44(local_4850._4_4_,local_2adc);
  local_48e0 = CONCAT44(local_48e0._4_4_,local_2ac0);
  local_48e8 = CONCAT44(local_48e8._4_4_,local_2abc);
  local_dec = 0;
  local_de9 = local_2afa;
  local_deb = local_2afc;
  local_48c0 = CONCAT44(local_48c0._4_4_,uVar38);
  local_dd8 = (undefined1)uVar38;
  local_dd7 = local_2b00;
  local_dd5 = local_2afe;
  local_dc4 = SUB81(local_47e0,0);
  local_dc3 = local_2b04;
  local_dc1 = local_2b02;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_2a68);
  local_48a0 = CONCAT44(local_48a0._4_4_,local_2a64);
  local_4880 = CONCAT44(local_4880._4_4_,local_2a48);
  local_4870 = CONCAT44(local_4870._4_4_,local_2a44);
  local_4868 = CONCAT44(local_4868._4_4_,local_2a40);
  local_4878 = CONCAT44(local_4878._4_4_,uVar29);
  local_d74 = (undefined1)uVar29;
  local_d71 = local_2b06;
  local_d73 = local_2b08;
  local_4860 = CONCAT44(local_4860._4_4_,uVar27);
  local_d60 = (undefined1)uVar27;
  local_d5d = local_2b0a;
  local_d5f = local_2b0c;
  local_4858 = CONCAT44(local_4858._4_4_,uVar37);
  local_d4c = (undefined1)uVar37;
  local_d49 = local_2b0e;
  local_d4b = local_2b10;
  local_4840 = CONCAT44(local_4840._4_4_,uVar35);
  local_d34 = (undefined1)uVar35;
  puVar12 = &local_e40;
  local_48ec = local_2ab8;
  local_48d8 = local_2ac8;
  local_48d0 = local_2ad0;
  local_48c8 = local_2ad8;
  local_48b8 = local_2a78;
  local_48b0 = local_2a70;
  local_4898 = local_2a60;
  local_4890 = local_2a58;
  local_4888 = local_2a50;
  local_4838 = local_2a14;
  local_4830 = local_2a0c;
  local_4828 = local_2a28;
  local_4820 = local_2a20;
  local_4818 = local_2a3c;
  local_4800 = local_2a34;
  local_47f8 = local_2a8c;
  local_e40 = uVar60;
  local_e3c = local_2af4;
  local_e38 = uVar16;
  local_e28 = uVar46;
  local_e24 = local_2adc;
  local_e20 = local_2ad8;
  local_e18 = local_2ad0;
  local_e10 = local_2ac8;
  local_e08 = local_2ac0;
  local_e04 = local_2abc;
  local_e00 = local_2ab8;
  local_dfc = CONCAT44(extraout_s1,uVar41);
  local_df4 = CONCAT44(extraout_s3,uVar47);
  local_de8 = uVar59;
  local_de0 = uVar21;
  local_dd4 = local_2a8c;
  local_dcc = uVar13;
  local_dc0 = local_2a78;
  local_db8 = local_2a70;
  local_db0 = local_2a68;
  local_dac = local_2a64;
  local_da8 = local_2a60;
  local_da0 = local_2a58;
  local_d98 = local_2a50;
  local_d90 = local_2a48;
  local_d8c = local_2a44;
  local_d88 = local_2a40;
  local_d84 = local_2a3c;
  local_d7c = local_2a34;
  local_d70 = local_2a28;
  local_d68 = local_2a20;
  local_d5c = local_2a14;
  local_d54 = local_2a0c;
  local_d48 = uVar14;
  local_d40 = uVar50;
  local_d3c = uVar52;
  local_d38 = uVar49;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_f4c = (undefined4)local_4848;
    local_f34 = (undefined4)local_4850;
    local_f30 = local_48c8;
    local_f28 = local_48d0;
    local_f20 = local_48d8;
    local_f18 = (undefined4)local_48e0;
    local_f14 = (undefined4)local_48e8;
    local_f10 = local_48ec;
    local_efc = 0;
    local_efb = local_2afc;
    local_ef9 = local_2afa;
    local_ee8 = (undefined1)local_48c0;
    local_ee7 = local_2b00;
    local_ee5 = local_2afe;
    local_ee4 = local_47f8;
    local_ed4 = SUB81(local_47e0,0);
    local_ed3 = local_2b04;
    local_ed1 = local_2b02;
    local_ed0 = local_48b8;
    local_ec8 = local_48b0;
    local_ec0 = (undefined4)local_48a8;
    local_ebc = (undefined4)local_48a0;
    local_eb8 = local_4898;
    local_eb0 = local_4890;
    local_ea8 = local_4888;
    local_ea0 = (undefined4)local_4880;
    local_e9c = (undefined4)local_4870;
    local_e98 = (undefined4)local_4868;
    local_e94 = local_4818;
    local_e8c = local_4800;
    local_e84 = (undefined1)local_4878;
    local_e81 = local_2b06;
    local_e83 = local_2b08;
    local_e80 = local_4828;
    local_e78 = local_4820;
    local_e70 = (undefined1)local_4860;
    local_e6d = local_2b0a;
    local_e6f = local_2b0c;
    local_e6c = local_4838;
    local_e64 = local_4830;
    local_e5c = (undefined1)local_4858;
    local_e59 = local_2b0e;
    local_e5b = local_2b10;
    local_e44 = (undefined1)local_4840;
    local_f50 = uVar60;
    local_f48 = uVar16;
    local_f40 = CONCAT44(uVar51,uVar48);
    local_f38 = uVar46;
    local_f0c = CONCAT44(extraout_s1,uVar41);
    local_f04 = CONCAT44(extraout_s3,uVar47);
    local_ef8 = uVar59;
    local_ef0 = uVar21;
    local_edc = uVar13;
    local_e58 = uVar14;
    local_e50 = uVar50;
    local_e4c = uVar52;
    local_e48 = uVar49;
    _CGPointMake(&local_f50);
    func_0x000198104610(auStack_2c20,&local_f50,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_2c20);
  }
  func_0x000198104610(<highlights.hdr>,auStack_2c20,0x10d);
  func_0x000198104610(&local_2d30,auStack_2c20,0x10d);
  iVar8 = (int)&local_2d30;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_2cbc = 0;
    local_2c74 = 0;
    local_2c6c = 0;
    local_2c60 = 0;
    local_2c58 = 0;
    local_2c4c = 0;
    local_2c44 = 0;
    uVar24 = 0;
    uVar50 = 0;
    uVar52 = 0;
    local_2ca8 = 0;
    uVar35 = 1;
    local_2ca0 = 0;
    uVar27 = 1;
    uVar29 = 1;
    local_2c98 = 0;
    local_2c90 = 0;
    local_2c88 = 0;
    local_2c80 = 0;
    local_2c7c = 0;
    local_2c78 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_4800 = CONCAT44(local_4800._4_4_,1);
    local_2c38 = 0;
    local_2c30 = 0;
    local_2c2c = 0;
    local_2c28 = 0;
    local_2d30 = 0;
    local_2d28 = 0;
    uVar59 = 0;
    uVar22 = 0;
    uVar31 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    local_2d14 = uVar37;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
  }
  else {
    uVar21 = (ulong)local_2d2c;
    uVar50 = (undefined4)local_2d08;
    uVar52 = (undefined4)((ulong)local_2d08 >> 0x20);
    uVar35 = (uint)local_2cdc;
    local_2d34 = local_2cdb;
    local_2d32 = local_2cd9;
    uVar27 = (uint)local_2cc8;
    local_2d36 = local_2cc5;
    local_2d38 = local_2cc7;
    uVar29 = (uint)local_2cb4;
    local_2d3a = local_2cb1;
    local_2d3c = local_2cb3;
    local_4818 = CONCAT44(local_4818._4_4_,local_2c9c);
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_2c64);
    local_2d3e = local_2c61;
    local_2d40 = local_2c63;
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_2c50);
    local_2d42 = local_2c4d;
    local_2d44 = local_2c4f;
    local_4800 = CONCAT44(local_4800._4_4_,(uint)local_2c3c);
    local_2d46 = local_2c39;
    local_2d48 = local_2c3b;
    uVar24 = (uint)local_2c24;
    uVar59 = local_2cec;
    uVar22 = local_2ce4;
    uVar31 = local_2cd8;
    uVar13 = local_2cd0;
    uVar14 = local_2cc4;
    uVar16 = local_2cb0;
    uVar18 = local_2d10;
    uVar23 = local_2d00;
    uVar41 = local_2d18;
    uVar47 = local_2cf8;
    uVar60 = local_2cf4;
    uVar46 = local_2cf0;
  }
  local_48c0 = CONCAT44(local_48c0._4_4_,local_2d30);
  local_f4c = (undefined4)uVar21;
  local_48c8 = CONCAT44(local_48c8._4_4_,local_f4c);
  local_f40 = 3.5;
  local_4860 = CONCAT44(local_4860._4_4_,local_2d14);
  local_f28 = CONCAT44(uVar52,uVar50);
  local_4868 = CONCAT44(local_4868._4_4_,uVar35);
  local_efc = (undefined1)uVar35;
  local_ef9 = local_2d32;
  local_efb = local_2d34;
  local_4870 = CONCAT44(local_4870._4_4_,uVar27);
  local_ee8 = (undefined1)uVar27;
  local_ee7 = local_2d38;
  local_ee5 = local_2d36;
  local_4888 = CONCAT44(local_4888._4_4_,uVar29);
  local_ed4 = (undefined1)uVar29;
  local_ed3 = local_2d3c;
  local_ed1 = local_2d3a;
  local_4880 = CONCAT44(local_4880._4_4_,local_2ca0);
  local_ebc = (undefined4)local_4818;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_2c80);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_2c7c);
  local_48b8 = CONCAT44(local_48b8._4_4_,local_2c78);
  local_e84 = SUB81(local_47e0,0);
  local_e81 = local_2d3e;
  local_e83 = local_2d40;
  local_e70 = (undefined1)local_47f8;
  local_e6d = local_2d42;
  local_e6f = local_2d44;
  local_e5c = (undefined1)local_4800;
  local_e59 = local_2d46;
  local_e5b = local_2d48;
  local_48e0 = CONCAT44(local_48e0._4_4_,local_2c30);
  local_48e8 = CONCAT44(local_48e8._4_4_,local_2c2c);
  local_4858 = CONCAT44(local_4858._4_4_,uVar24);
  local_e44 = (undefined1)uVar24;
  puVar12 = &local_f50;
  local_48ec = local_2c28;
  local_48d8 = local_2c38;
  local_48d0 = local_2d28;
  local_48a0 = local_2c88;
  local_4898 = local_2c90;
  local_4890 = local_2c98;
  local_4878 = local_2ca8;
  local_4850 = local_2c44;
  local_4848 = local_2c4c;
  local_4840 = local_2c58;
  local_4838 = local_2c60;
  local_4830 = local_2c6c;
  local_4828 = local_2c74;
  local_4820 = local_2cbc;
  local_f50 = local_2d30;
  local_f48 = local_2d28;
  local_f38 = uVar41;
  local_f34 = local_2d14;
  local_f30 = uVar18;
  local_f20 = uVar23;
  local_f18 = uVar47;
  local_f14 = uVar60;
  local_f10 = uVar46;
  local_f0c = uVar59;
  local_f04 = uVar22;
  local_ef8 = uVar31;
  local_ef0 = uVar13;
  local_ee4 = uVar14;
  local_edc = local_2cbc;
  local_ed0 = uVar16;
  local_ec8 = local_2ca8;
  local_ec0 = local_2ca0;
  local_eb8 = local_2c98;
  local_eb0 = local_2c90;
  local_ea8 = local_2c88;
  local_ea0 = local_2c80;
  local_e9c = local_2c7c;
  local_e98 = local_2c78;
  local_e94 = local_2c74;
  local_e8c = local_2c6c;
  local_e80 = local_2c60;
  local_e78 = local_2c58;
  local_e6c = local_2c4c;
  local_e64 = local_2c44;
  local_e58 = local_2c38;
  local_e50 = local_2c30;
  local_e4c = local_2c2c;
  local_e48 = local_2c28;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_1060 = (undefined4)local_48c0;
    local_105c = (undefined4)local_48c8;
    local_1058 = local_48d0;
    local_1050 = 3.5;
    local_1044 = (undefined4)local_4860;
    local_100c = (undefined1)local_4868;
    local_100b = local_2d34;
    local_1009 = local_2d32;
    local_ff8 = (undefined1)local_4870;
    local_ff5 = local_2d36;
    local_ff7 = local_2d38;
    local_fec = local_4820;
    local_fe4 = (undefined1)local_4888;
    local_fe1 = local_2d3a;
    local_fe3 = local_2d3c;
    local_fd8 = local_4878;
    local_fd0 = (undefined4)local_4880;
    local_fcc = (undefined4)local_4818;
    local_fc8 = local_4890;
    local_fc0 = local_4898;
    local_fb8 = local_48a0;
    local_fb0 = (undefined4)local_48a8;
    local_fac = (undefined4)local_48b0;
    local_fa8 = (undefined4)local_48b8;
    local_fa4 = local_4828;
    local_f9c = local_4830;
    local_f94 = SUB81(local_47e0,0);
    local_f91 = local_2d3e;
    local_f93 = local_2d40;
    local_f90 = local_4838;
    local_f88 = local_4840;
    local_f80 = (undefined1)local_47f8;
    local_f7d = local_2d42;
    local_f7f = local_2d44;
    local_f7c = local_4848;
    local_f74 = local_4850;
    local_f6c = (undefined1)local_4800;
    local_f69 = local_2d46;
    local_f6b = local_2d48;
    local_f68 = local_48d8;
    local_f60 = (undefined4)local_48e0;
    local_f5c = (undefined4)local_48e8;
    local_f58 = local_48ec;
    local_f54 = (undefined1)local_4858;
    local_1048 = uVar41;
    local_1040 = uVar18;
    local_1038 = CONCAT44(uVar52,uVar50);
    local_1030 = uVar23;
    local_1028 = uVar47;
    local_1024 = uVar60;
    local_1020 = uVar46;
    local_101c = uVar59;
    local_1014 = uVar22;
    local_1008 = uVar31;
    local_1000 = uVar13;
    local_ff4 = uVar14;
    local_fe0 = uVar16;
    _CGPointMake(&local_1060);
    func_0x000198104610(auStack_2e58,&local_1060,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_2e58);
  }
  func_0x000198104610(<highlights.hdr>,auStack_2e58,0x10d);
  func_0x000198104610(&local_2f68,auStack_2e58,0x10d);
  iVar8 = (int)&local_2f68;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_2ef4 = 0;
    local_2eac = 0;
    local_2ea4 = 0;
    local_2e98 = 0;
    local_2e90 = 0;
    local_2e84 = 0;
    local_2e7c = 0;
    uVar24 = 0;
    local_2ec8 = 0;
    uVar35 = 1;
    local_2ec0 = 0;
    uVar37 = 1;
    uVar27 = 1;
    local_2eb8 = 0;
    local_2eb4 = 0;
    local_2eb0 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_4800 = CONCAT44(local_4800._4_4_,1);
    local_2e70 = 0;
    local_2e68 = 0;
    local_2e64 = 0;
    local_2e60 = 0;
    local_2f68 = 0;
    local_2f60 = 0;
    local_2f58 = 0;
    local_2f50 = 0;
    local_2f48 = 0;
    uVar59 = 0;
    uVar21 = 0;
    uVar32 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar41 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    local_2ed4 = 0x95f1a9ac;
    uVar54 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
  }
  else {
    uVar22 = (ulong)local_2f64;
    uVar31 = (ulong)local_2f4c;
    uVar35 = (uint)local_2f14;
    local_2f6c = local_2f13;
    local_2f6a = local_2f11;
    uVar37 = (uint)local_2f00;
    local_2f6e = local_2efd;
    local_2f70 = local_2eff;
    uVar27 = (uint)local_2eec;
    local_2f72 = local_2ee9;
    local_2f74 = local_2eeb;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_2e9c);
    local_2f76 = local_2e99;
    local_2f78 = local_2e9b;
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_2e88);
    local_2f7a = local_2e85;
    local_2f7c = local_2e87;
    local_4800 = CONCAT44(local_4800._4_4_,(uint)local_2e74);
    local_2f7e = local_2e71;
    local_2f80 = local_2e73;
    uVar24 = (uint)local_2e5c;
    uVar59 = local_2f24;
    uVar21 = local_2f1c;
    uVar32 = local_2f10;
    uVar13 = local_2f08;
    uVar14 = local_2efc;
    uVar41 = local_2f2c;
    uVar16 = local_2ee8;
    uVar18 = local_2ee0;
    uVar23 = local_2ed0;
    uVar54 = local_2f38;
    uVar47 = local_2f30;
    uVar60 = local_2f28;
    uVar46 = local_2ed8;
  }
  local_48a0 = CONCAT44(local_48a0._4_4_,local_2f68);
  local_105c = (undefined4)uVar22;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_105c);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_2f50);
  local_1044 = (undefined4)uVar31;
  local_48c8 = CONCAT44(local_48c8._4_4_,local_1044);
  local_1038 = 1;
  local_4858 = CONCAT44(local_4858._4_4_,uVar35);
  local_100c = (undefined1)uVar35;
  local_1009 = local_2f6a;
  local_100b = local_2f6c;
  local_4860 = CONCAT44(local_4860._4_4_,uVar37);
  local_ff8 = (undefined1)uVar37;
  local_ff7 = local_2f70;
  local_ff5 = local_2f6e;
  local_4870 = CONCAT44(local_4870._4_4_,uVar27);
  local_fe4 = (undefined1)uVar27;
  local_fe3 = local_2f74;
  local_fe1 = local_2f72;
  local_4880 = CONCAT44(local_4880._4_4_,local_2ed4);
  local_4888 = CONCAT44(local_4888._4_4_,local_2eb8);
  local_4890 = CONCAT44(local_4890._4_4_,local_2eb4);
  local_4898 = CONCAT44(local_4898._4_4_,local_2eb0);
  local_f94 = SUB81(local_47e0,0);
  local_f91 = local_2f76;
  local_f93 = local_2f78;
  local_f80 = (undefined1)local_47f8;
  local_f7d = local_2f7a;
  local_f7f = local_2f7c;
  local_f6c = (undefined1)local_4800;
  local_f69 = local_2f7e;
  local_f6b = local_2f80;
  local_48e0 = CONCAT44(local_48e0._4_4_,local_2e68);
  local_48e8 = CONCAT44(local_48e8._4_4_,local_2e64);
  local_4850 = CONCAT44(local_4850._4_4_,uVar24);
  local_f54 = (undefined1)uVar24;
  puVar12 = &local_1060;
  local_48ec = local_2e60;
  local_48d8 = local_2e70;
  local_48d0 = local_2f48;
  local_48b8 = local_2f58;
  local_48b0 = local_2f60;
  local_4878 = local_2ec0;
  local_4868 = local_2ec8;
  local_4848 = local_2e7c;
  local_4840 = local_2e84;
  local_4838 = local_2e90;
  local_4830 = local_2e98;
  local_4828 = local_2ea4;
  local_4820 = local_2eac;
  local_4818 = local_2ef4;
  local_1060 = local_2f68;
  local_1058 = local_2f60;
  local_1050 = local_2f58;
  local_1048 = local_2f50;
  local_1040 = local_2f48;
  local_1030 = uVar54;
  local_1028 = uVar47;
  local_1024 = uVar41;
  local_1020 = uVar60;
  local_101c = uVar59;
  local_1014 = uVar21;
  local_1008 = uVar32;
  local_1000 = uVar13;
  local_ff4 = uVar14;
  local_fec = local_2ef4;
  local_fe0 = uVar16;
  local_fd8 = uVar18;
  local_fd0 = uVar46;
  local_fcc = local_2ed4;
  local_fc8 = uVar23;
  local_fc0 = local_2ec8;
  local_fb8 = local_2ec0;
  local_fb0 = local_2eb8;
  local_fac = local_2eb4;
  local_fa8 = local_2eb0;
  local_fa4 = local_2eac;
  local_f9c = local_2ea4;
  local_f90 = local_2e98;
  local_f88 = local_2e90;
  local_f7c = local_2e84;
  local_f74 = local_2e7c;
  local_f68 = local_2e70;
  local_f60 = local_2e68;
  local_f5c = local_2e64;
  local_f58 = local_2e60;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_1170 = (undefined4)local_48a0;
    local_116c = (undefined4)local_48a8;
    local_1168 = local_48b0;
    local_1160 = local_48b8;
    local_1158 = (undefined4)local_48c0;
    local_1154 = (undefined4)local_48c8;
    local_1150 = local_48d0;
    local_1148 = 1;
    local_111c = (undefined1)local_4858;
    local_111b = local_2f6c;
    local_1119 = local_2f6a;
    local_1108 = (undefined1)local_4860;
    local_1105 = local_2f6e;
    local_1107 = local_2f70;
    local_10fc = local_4818;
    local_10f4 = (undefined1)local_4870;
    local_10f1 = local_2f72;
    local_10f3 = local_2f74;
    local_10dc = (undefined4)local_4880;
    local_10d0 = local_4868;
    local_10c8 = local_4878;
    local_10c0 = (undefined4)local_4888;
    local_10bc = (undefined4)local_4890;
    local_10b8 = (undefined4)local_4898;
    local_10b4 = local_4820;
    local_10ac = local_4828;
    local_10a4 = SUB81(local_47e0,0);
    local_10a1 = local_2f76;
    local_10a3 = local_2f78;
    local_10a0 = local_4830;
    local_1098 = local_4838;
    local_1090 = (undefined1)local_47f8;
    local_108d = local_2f7a;
    local_108f = local_2f7c;
    local_108c = local_4840;
    local_1084 = local_4848;
    local_107c = (undefined1)local_4800;
    local_1079 = local_2f7e;
    local_107b = local_2f80;
    local_1078 = local_48d8;
    local_1070 = (undefined4)local_48e0;
    local_106c = (undefined4)local_48e8;
    local_1068 = local_48ec;
    local_1064 = (undefined1)local_4850;
    local_1140 = uVar54;
    local_1138 = uVar47;
    local_1134 = uVar41;
    local_1130 = uVar60;
    local_112c = uVar59;
    local_1124 = uVar21;
    local_1118 = uVar32;
    local_1110 = uVar13;
    local_1104 = uVar14;
    local_10f0 = uVar16;
    local_10e8 = uVar18;
    local_10e0 = uVar46;
    local_10d8 = uVar23;
    _CGPointMake(&local_1170);
    func_0x000198104610(auStack_3090,&local_1170,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3090);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3090,0x10d);
  func_0x000198104610(&local_31a0,auStack_3090,0x10d);
  iVar8 = (int)&local_31a0;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3134 = 0;
    local_312c = 0;
    local_30e4 = 0;
    local_30dc = 0;
    local_30d0 = 0;
    local_30c8 = 0;
    local_30bc = 0;
    local_30b4 = 0;
    uVar35 = 0;
    uVar50 = 0;
    uVar52 = 0;
    local_3108 = 0;
    uVar24 = 1;
    local_3100 = 0;
    uVar37 = 1;
    uVar27 = 1;
    local_30f8 = 0;
    local_30f0 = 0;
    local_30ec = 0;
    local_30e8 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_4800 = CONCAT44(local_4800._4_4_,1);
    local_30a8 = 0;
    local_30a0 = 0;
    local_309c = 0;
    local_3098 = 0;
    local_31a0 = 0;
    local_3198 = 0;
    local_3190 = 0;
    local_3188 = 0;
    uVar59 = 0;
    uVar22 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    local_310c = 0x95f1af44;
    uVar23 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
  }
  else {
    uVar21 = (ulong)local_319c;
    uVar32 = (ulong)local_3184;
    uVar50 = (undefined4)local_3170;
    uVar52 = (undefined4)((ulong)local_3170 >> 0x20);
    uVar24 = (uint)local_314c;
    local_31a4 = local_314b;
    local_31a2 = local_3149;
    uVar37 = (uint)local_3138;
    local_31a6 = local_3135;
    local_31a8 = local_3137;
    uVar27 = (uint)local_3124;
    local_31aa = local_3121;
    local_31ac = local_3123;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_30d4);
    local_31ae = local_30d1;
    local_31b0 = local_30d3;
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_30c0);
    local_31b2 = local_30bd;
    local_31b4 = local_30bf;
    local_4800 = CONCAT44(local_4800._4_4_,(uint)local_30ac);
    local_31b6 = local_30a9;
    local_31b8 = local_30ab;
    uVar35 = (uint)local_3094;
    uVar59 = local_315c;
    uVar22 = local_3154;
    uVar13 = local_3148;
    uVar14 = local_3140;
    uVar16 = local_3120;
    uVar18 = local_3118;
    uVar23 = local_3178;
    uVar41 = local_3168;
    uVar47 = local_3164;
    uVar60 = local_3160;
    uVar46 = local_3110;
  }
  local_48b0 = CONCAT44(local_48b0._4_4_,local_31a0);
  local_116c = (undefined4)uVar21;
  local_48b8 = CONCAT44(local_48b8._4_4_,local_116c);
  local_48d8 = CONCAT44(local_48d8._4_4_,local_3188);
  local_1154 = (undefined4)uVar32;
  local_48d0 = CONCAT44(local_48d0._4_4_,local_1154);
  local_1150 = 0.872665;
  local_1140 = CONCAT44(uVar52,uVar50);
  local_4860 = CONCAT44(local_4860._4_4_,uVar24);
  local_111c = (undefined1)uVar24;
  local_1119 = local_31a2;
  local_111b = local_31a4;
  local_4868 = CONCAT44(local_4868._4_4_,uVar37);
  local_1108 = (undefined1)uVar37;
  local_1107 = local_31a8;
  local_1105 = local_31a6;
  local_4878 = CONCAT44(local_4878._4_4_,uVar27);
  local_10f4 = (undefined1)uVar27;
  local_10f3 = local_31ac;
  local_10f1 = local_31aa;
  local_4888 = CONCAT44(local_4888._4_4_,local_310c);
  local_4898 = CONCAT44(local_4898._4_4_,local_30f0);
  local_48a0 = CONCAT44(local_48a0._4_4_,local_30ec);
  local_48a8 = CONCAT44(local_48a8._4_4_,local_30e8);
  local_10a4 = SUB81(local_47e0,0);
  local_10a1 = local_31ae;
  local_10a3 = local_31b0;
  local_1090 = (undefined1)local_47f8;
  local_108d = local_31b2;
  local_108f = local_31b4;
  local_107c = (undefined1)local_4800;
  local_1079 = local_31b6;
  local_107b = local_31b8;
  local_48e8 = CONCAT44(local_48e8._4_4_,local_30a0);
  local_4858 = CONCAT44(local_4858._4_4_,uVar35);
  local_1064 = (undefined1)uVar35;
  puVar12 = &local_1170;
  local_48f0 = local_3098;
  local_48ec = local_309c;
  local_48e0 = local_30a8;
  local_48c8 = local_3190;
  local_48c0 = local_3198;
  local_4890 = local_30f8;
  local_4880 = local_3100;
  local_4870 = local_3108;
  local_4850 = local_30b4;
  local_4848 = local_30bc;
  local_4840 = local_30c8;
  local_4838 = local_30d0;
  local_4830 = local_30dc;
  local_4828 = local_30e4;
  local_4820 = local_312c;
  local_4818 = local_3134;
  local_1170 = local_31a0;
  local_1168 = local_3198;
  local_1160 = local_3190;
  local_1158 = local_3188;
  local_1148 = uVar23;
  local_1138 = uVar41;
  local_1134 = uVar47;
  local_1130 = uVar60;
  local_112c = uVar59;
  local_1124 = uVar22;
  local_1118 = uVar13;
  local_1110 = uVar14;
  local_1104 = local_3134;
  local_10fc = local_312c;
  local_10f0 = uVar16;
  local_10e8 = uVar18;
  local_10e0 = uVar46;
  local_10dc = local_310c;
  local_10d8 = local_3108;
  local_10d0 = local_3100;
  local_10c8 = local_30f8;
  local_10c0 = local_30f0;
  local_10bc = local_30ec;
  local_10b8 = local_30e8;
  local_10b4 = local_30e4;
  local_10ac = local_30dc;
  local_10a0 = local_30d0;
  local_1098 = local_30c8;
  local_108c = local_30bc;
  local_1084 = local_30b4;
  local_1078 = local_30a8;
  local_1070 = local_30a0;
  local_106c = local_309c;
  local_1068 = local_3098;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_1280 = (undefined4)local_48b0;
    local_127c = (undefined4)local_48b8;
    local_1278 = local_48c0;
    local_1270 = local_48c8;
    local_1268 = (undefined4)local_48d8;
    local_1264 = (undefined4)local_48d0;
    local_1260 = 0.872665;
    local_122c = (undefined1)local_4860;
    local_122b = local_31a4;
    local_1229 = local_31a2;
    local_1218 = (undefined1)local_4868;
    local_1215 = local_31a6;
    local_1217 = local_31a8;
    local_1214 = local_4818;
    local_120c = local_4820;
    local_1204 = (undefined1)local_4878;
    local_1201 = local_31aa;
    local_1203 = local_31ac;
    local_11ec = (undefined4)local_4888;
    local_11e8 = local_4870;
    local_11e0 = local_4880;
    local_11d8 = local_4890;
    local_11d0 = (undefined4)local_4898;
    local_11cc = (undefined4)local_48a0;
    local_11c8 = (undefined4)local_48a8;
    local_11c4 = local_4828;
    local_11bc = local_4830;
    local_11b4 = SUB81(local_47e0,0);
    local_11b1 = local_31ae;
    local_11b3 = local_31b0;
    local_11b0 = local_4838;
    local_11a8 = local_4840;
    local_11a0 = (undefined1)local_47f8;
    local_119d = local_31b2;
    local_119f = local_31b4;
    local_119c = local_4848;
    local_1194 = local_4850;
    local_118c = (undefined1)local_4800;
    local_1189 = local_31b6;
    local_118b = local_31b8;
    local_1188 = local_48e0;
    local_1180 = (undefined4)local_48e8;
    local_117c = local_48ec;
    local_1178 = local_48f0;
    local_1174 = (undefined1)local_4858;
    local_1258 = uVar23;
    local_1250 = CONCAT44(uVar52,uVar50);
    local_1248 = uVar41;
    local_1244 = uVar47;
    local_1240 = uVar60;
    local_123c = uVar59;
    local_1234 = uVar22;
    local_1228 = uVar13;
    local_1220 = uVar14;
    local_1200 = uVar16;
    local_11f8 = uVar18;
    local_11f0 = uVar46;
    _CGPointMake(&local_1280);
    func_0x000198104610(auStack_32c8,&local_1280,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_32c8);
  }
  func_0x000198104610(<highlights.hdr>,auStack_32c8,0x10d);
  func_0x000198104610(&local_33d8,auStack_32c8,0x10d);
  iVar8 = (int)&local_33d8;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3364 = 0;
    local_331c = 0;
    local_3314 = 0;
    local_3308 = 0;
    local_3300 = 0;
    local_32f4 = 0;
    local_32ec = 0;
    uVar37 = 0;
    uVar46 = 0;
    uVar50 = 0;
    local_3348 = 0;
    uVar35 = 1;
    local_3340 = 0;
    uVar27 = 1;
    uVar29 = 1;
    local_3338 = 0;
    local_3330 = 0;
    local_3328 = 0;
    local_3324 = 0;
    local_3320 = 0;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_47f8 = CONCAT44(local_47f8._4_4_,1);
    local_4800 = CONCAT44(local_4800._4_4_,1);
    local_32e0 = 0;
    local_32d8 = 0;
    local_32d4 = 0;
    local_32d0 = 0;
    local_33d8 = 0;
    local_33d0 = 0;
    local_33c8 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar21 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
  }
  else {
    uVar22 = (ulong)local_33d4;
    uVar46 = (undefined4)local_33b0;
    uVar50 = (undefined4)((ulong)local_33b0 >> 0x20);
    uVar35 = (uint)local_3384;
    local_33dc = local_3383;
    local_33da = local_3381;
    uVar27 = (uint)local_3370;
    local_33de = local_336d;
    local_33e0 = local_336f;
    uVar29 = (uint)local_335c;
    local_33e2 = local_3359;
    local_33e4 = local_335b;
    local_4818 = CONCAT44(local_4818._4_4_,local_3344);
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_330c);
    local_33e6 = local_3309;
    local_33e8 = local_330b;
    local_47f8 = CONCAT44(local_47f8._4_4_,(uint)local_32f8);
    local_33ea = local_32f5;
    local_33ec = local_32f7;
    local_4800 = CONCAT44(local_4800._4_4_,(uint)local_32e4);
    local_33ee = local_32e1;
    local_33f0 = local_32e3;
    uVar37 = (uint)local_32cc;
    uVar59 = local_3394;
    uVar13 = local_338c;
    uVar21 = local_3380;
    uVar14 = local_3378;
    uVar16 = local_336c;
    uVar18 = local_3358;
    uVar23 = local_3350;
    uVar54 = local_33b8;
    uVar55 = local_33a8;
    uVar24 = local_33bc;
    uVar41 = local_33a0;
    uVar47 = local_339c;
    uVar60 = local_3398;
  }
  local_48b8 = CONCAT44(local_48b8._4_4_,local_33d8);
  local_127c = (undefined4)uVar22;
  local_48c0 = CONCAT44(local_48c0._4_4_,local_127c);
  local_1268 = 0.8f;
  local_4860 = CONCAT44(local_4860._4_4_,uVar24);
  local_1258 = CONCAT44(uVar50,uVar46);
  local_4868 = CONCAT44(local_4868._4_4_,uVar35);
  local_122c = (undefined1)uVar35;
  local_1229 = local_33da;
  local_122b = local_33dc;
  local_4878 = CONCAT44(local_4878._4_4_,uVar27);
  local_1218 = (undefined1)uVar27;
  local_1217 = local_33e0;
  local_1215 = local_33de;
  local_4880 = CONCAT44(local_4880._4_4_,uVar29);
  local_1204 = (undefined1)uVar29;
  local_1203 = local_33e4;
  local_1201 = local_33e2;
  local_4870 = CONCAT44(local_4870._4_4_,local_3348);
  local_11ec = (undefined4)local_4818;
  local_48a0 = CONCAT44(local_48a0._4_4_,local_3328);
  local_48a8 = CONCAT44(local_48a8._4_4_,local_3324);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_3320);
  local_11b4 = SUB81(local_47e0,0);
  local_11b1 = local_33e6;
  local_11b3 = local_33e8;
  local_11a0 = (undefined1)local_47f8;
  local_119d = local_33ea;
  local_119f = local_33ec;
  local_118c = (undefined1)local_4800;
  local_1189 = local_33ee;
  local_118b = local_33f0;
  local_48e0 = CONCAT44(local_48e0._4_4_,local_32d8);
  local_48e8 = CONCAT44(local_48e8._4_4_,local_32d4);
  local_4858 = CONCAT44(local_4858._4_4_,uVar37);
  local_1174 = (undefined1)uVar37;
  puVar12 = &local_1280;
  local_48ec = local_32d0;
  local_48d8 = local_32e0;
  local_48d0 = local_33c8;
  local_48c8 = local_33d0;
  local_4898 = local_3330;
  local_4890 = local_3338;
  local_4888 = local_3340;
  local_4850 = local_32ec;
  local_4848 = local_32f4;
  local_4840 = local_3300;
  local_4838 = local_3308;
  local_4830 = local_3314;
  local_4828 = local_331c;
  local_4820 = local_3364;
  local_1280 = local_33d8;
  local_1278 = local_33d0;
  local_1270 = local_33c8;
  local_1264 = uVar24;
  local_1260 = uVar54;
  local_1250 = uVar55;
  local_1248 = uVar41;
  local_1244 = uVar47;
  local_1240 = uVar60;
  local_123c = uVar59;
  local_1234 = uVar13;
  local_1228 = uVar21;
  local_1220 = uVar14;
  local_1214 = uVar16;
  local_120c = local_3364;
  local_1200 = uVar18;
  local_11f8 = uVar23;
  local_11f0 = local_3348;
  local_11e8 = local_3340;
  local_11e0 = local_3338;
  local_11d8 = local_3330;
  local_11d0 = local_3328;
  local_11cc = local_3324;
  local_11c8 = local_3320;
  local_11c4 = local_331c;
  local_11bc = local_3314;
  local_11b0 = local_3308;
  local_11a8 = local_3300;
  local_119c = local_32f4;
  local_1194 = local_32ec;
  local_1188 = local_32e0;
  local_1180 = local_32d8;
  local_117c = local_32d4;
  local_1178 = local_32d0;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_1390 = (undefined4)local_48b8;
    local_138c = (undefined4)local_48c0;
    local_1388 = local_48c8;
    local_1380 = local_48d0;
    local_1378 = 0.8f;
    local_1374 = (undefined4)local_4860;
    local_133c = (undefined1)local_4868;
    local_133b = local_33dc;
    local_1339 = local_33da;
    local_1328 = (undefined1)local_4878;
    local_1325 = local_33de;
    local_1327 = local_33e0;
    local_131c = local_4820;
    local_1314 = (undefined1)local_4880;
    local_1311 = local_33e2;
    local_1313 = local_33e4;
    local_1300 = (undefined4)local_4870;
    local_12fc = (undefined4)local_4818;
    local_12f8 = local_4888;
    local_12f0 = local_4890;
    local_12e8 = local_4898;
    local_12e0 = (undefined4)local_48a0;
    local_12dc = (undefined4)local_48a8;
    local_12d8 = (undefined4)local_48b0;
    local_12d4 = local_4828;
    local_12cc = local_4830;
    local_12c4 = SUB81(local_47e0,0);
    local_12c1 = local_33e6;
    local_12c3 = local_33e8;
    local_12c0 = local_4838;
    local_12b8 = local_4840;
    local_12b0 = (undefined1)local_47f8;
    local_12ad = local_33ea;
    local_12af = local_33ec;
    local_12ac = local_4848;
    local_12a4 = local_4850;
    local_129c = (undefined1)local_4800;
    local_1299 = local_33ee;
    local_129b = local_33f0;
    local_1298 = local_48d8;
    local_1290 = (undefined4)local_48e0;
    local_128c = (undefined4)local_48e8;
    local_1288 = local_48ec;
    local_1284 = (undefined1)local_4858;
    local_1370 = uVar54;
    local_1368 = CONCAT44(uVar50,uVar46);
    local_1360 = uVar55;
    local_1358 = uVar41;
    local_1354 = uVar47;
    local_1350 = uVar60;
    local_134c = uVar59;
    local_1344 = uVar13;
    local_1338 = uVar21;
    local_1330 = uVar14;
    local_1324 = uVar16;
    local_1310 = uVar18;
    local_1308 = uVar23;
    _CGPointMake(&local_1390);
    func_0x000198104610(auStack_3500,&local_1390,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3500);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3500,0x10d);
  func_0x000198104610(&local_3610,auStack_3500,0x10d);
  iVar8 = (int)&local_3610;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_35cc = 0;
    local_35c4 = 0;
    local_35b8 = 0;
    local_35b0 = 0;
    local_35a4 = 0;
    local_359c = 0;
    uVar37 = 0;
    local_352c = 0;
    uVar49 = 0;
    uVar48 = 0;
    local_1378 = 0;
    local_35f0 = 0;
    local_35e8 = 0;
    local_35e0 = 0;
    local_48ec = 0;
    local_35d4 = 0;
    uVar27 = 1;
    local_35d0 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_3590 = 0;
    local_3588 = 0;
    local_3580 = 0;
    local_3578 = 0;
    local_3570 = 0;
    local_3568 = 0;
    uVar39 = 1;
    uVar33 = 1;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar54 = 0;
    uVar52 = 0;
  }
  else {
    uVar49 = (undefined4)local_3600;
    uVar48 = (undefined4)((ulong)local_3600 >> 0x20);
    uVar27 = (uint)local_35bc;
    local_3612 = local_35b9;
    local_3614 = local_35bb;
    uVar29 = (uint)local_35a8;
    local_3616 = local_35a5;
    local_3618 = local_35a7;
    uVar38 = (uint)local_3594;
    local_361a = local_3591;
    local_361c = local_3593;
    uVar21 = (ulong)local_357c;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_3544);
    local_361e = local_3541;
    local_3620 = local_3543;
    uVar33 = (uint)local_3530;
    local_3622 = local_352d;
    local_3624 = local_352f;
    uVar39 = (uint)local_351c;
    local_3626 = local_3519;
    local_3628 = local_351b;
    uVar37 = (uint)local_3504;
    uVar59 = local_3538;
    uVar13 = local_3540;
    uVar14 = local_3524;
    uVar16 = local_354c;
    uVar18 = local_3554;
    uVar23 = local_3518;
    uVar41 = local_355c;
    uVar47 = local_3558;
    uVar60 = local_3510;
    uVar46 = local_350c;
    uVar50 = local_3508;
    uVar54 = local_3608;
    uVar24 = local_360c;
    uVar35 = local_35f4;
    uVar52 = local_3610;
    local_1378 = local_35f8;
    local_48ec = local_35d8;
  }
  local_4848 = CONCAT44(local_4848._4_4_,uVar24);
  local_48b8 = CONCAT44(uVar48,uVar49);
  local_1380 = CONCAT44(uVar48,uVar49);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_1378);
  local_4858 = CONCAT44(local_4858._4_4_,uVar35);
  local_4850 = CONCAT44(local_4850._4_4_,local_35d4);
  local_4868 = CONCAT44(local_4868._4_4_,local_35d0);
  local_4860 = CONCAT44(local_4860._4_4_,uVar27);
  local_133c = (undefined1)uVar27;
  local_1339 = local_3612;
  local_133b = local_3614;
  local_4870 = CONCAT44(local_4870._4_4_,uVar29);
  local_1328 = (undefined1)uVar29;
  local_1327 = local_3618;
  local_1325 = local_3616;
  local_4878 = CONCAT44(local_4878._4_4_,uVar38);
  local_1314 = (undefined1)uVar38;
  local_1313 = local_361c;
  local_1311 = local_361a;
  local_4890 = CONCAT44(local_4890._4_4_,local_3580);
  local_12fc = (undefined4)uVar21;
  local_4898 = CONCAT44(local_4898._4_4_,local_12fc);
  local_12e0 = 0.25f;
  local_12c4 = SUB81(local_47e0,0);
  local_12c1 = local_361e;
  local_12c3 = local_3620;
  local_48e0 = CONCAT44(local_48e0._4_4_,uVar33);
  local_12b0 = (undefined1)uVar33;
  local_12ad = local_3622;
  local_12af = local_3624;
  local_48d8 = CONCAT44(local_48d8._4_4_,uVar39);
  local_129c = (undefined1)uVar39;
  local_1299 = local_3626;
  local_129b = local_3628;
  local_4840 = CONCAT44(local_4840._4_4_,uVar37);
  local_1284 = (undefined1)uVar37;
  puVar12 = &local_1390;
  local_48e8 = local_35e0;
  local_48d0 = local_35e8;
  local_48c8 = local_35f0;
  local_48b0 = local_3568;
  local_48a8 = local_3570;
  local_48a0 = local_3578;
  local_4888 = local_3588;
  local_4880 = local_3590;
  local_4838 = local_352c;
  local_4830 = local_35b0;
  local_4828 = local_35b8;
  local_4820 = local_35c4;
  local_4818 = local_35a4;
  local_4800 = local_35cc;
  local_47f8 = local_359c;
  local_1390 = uVar52;
  local_138c = uVar24;
  local_1388 = uVar54;
  local_1374 = uVar35;
  local_1370 = local_35f0;
  local_1368 = local_35e8;
  local_1360 = local_35e0;
  local_1358 = local_48ec;
  local_1354 = local_35d4;
  local_1350 = local_35d0;
  local_134c = local_35cc;
  local_1344 = local_35c4;
  local_1338 = local_35b8;
  local_1330 = local_35b0;
  local_1324 = local_35a4;
  local_131c = local_359c;
  local_1310 = local_3590;
  local_1308 = local_3588;
  local_1300 = local_3580;
  local_12f8 = local_3578;
  local_12f0 = local_3570;
  local_12e8 = local_3568;
  local_12dc = uVar41;
  local_12d8 = uVar47;
  local_12d4 = uVar18;
  local_12cc = uVar16;
  local_12c0 = uVar13;
  local_12b8 = uVar59;
  local_12ac = local_352c;
  local_12a4 = uVar14;
  local_1298 = uVar23;
  local_1290 = uVar60;
  local_128c = uVar46;
  local_1288 = uVar50;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_149c = (undefined4)local_4848;
    local_1490 = local_48b8;
    local_1488 = (undefined4)local_48c0;
    local_1484 = (undefined4)local_4858;
    local_1480 = local_48c8;
    local_1478 = local_48d0;
    local_1470 = local_48e8;
    local_1468 = local_48ec;
    local_1464 = (undefined4)local_4850;
    local_1460 = (undefined4)local_4868;
    local_145c = local_4800;
    local_1454 = local_4820;
    local_144c = (undefined1)local_4860;
    local_144b = local_3614;
    local_1449 = local_3612;
    local_1448 = local_4828;
    local_1440 = local_4830;
    local_1438 = (undefined1)local_4870;
    local_1435 = local_3616;
    local_1437 = local_3618;
    local_1434 = local_4818;
    local_142c = local_47f8;
    local_1424 = (undefined1)local_4878;
    local_1421 = local_361a;
    local_1423 = local_361c;
    local_1420 = local_4880;
    local_1418 = local_4888;
    local_1410 = (undefined4)local_4890;
    local_140c = (undefined4)local_4898;
    local_1408 = local_48a0;
    local_1400 = local_48a8;
    local_13f8 = local_48b0;
    local_13f0 = 0.25f;
    local_13d4 = SUB81(local_47e0,0);
    local_13d1 = local_361e;
    local_13d3 = local_3620;
    local_13c0 = (undefined1)local_48e0;
    local_13bd = local_3622;
    local_13bf = local_3624;
    local_13bc = local_4838;
    local_13ac = (undefined1)local_48d8;
    local_13a9 = local_3626;
    local_13ab = local_3628;
    local_1394 = (undefined1)local_4840;
    local_14a0 = uVar52;
    local_1498 = uVar54;
    local_13ec = uVar41;
    local_13e8 = uVar47;
    local_13e4 = uVar18;
    local_13dc = uVar16;
    local_13d0 = uVar13;
    local_13c8 = uVar59;
    local_13b4 = uVar14;
    local_13a8 = uVar23;
    local_13a0 = uVar60;
    local_139c = uVar46;
    local_1398 = uVar50;
    _CGPointMake(&local_14a0);
    func_0x000198104610(auStack_3738,&local_14a0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3738);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3738,0x10d);
  func_0x000198104610(&local_3848,auStack_3738,0x10d);
  iVar8 = (int)&local_3848;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3804 = 0;
    local_37fc = 0;
    local_37f0 = 0;
    local_37e8 = 0;
    local_37dc = 0;
    local_37d4 = 0;
    uVar37 = 0;
    uVar49 = 0;
    uVar48 = 0;
    local_1488 = 0;
    local_3828 = 0;
    local_3820 = 0;
    local_3818 = 0;
    local_380c = 0;
    uVar27 = 1;
    local_3808 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_37c8 = 0;
    local_37c0 = 0;
    local_37b8 = 0;
    local_37b0 = 0;
    local_37a8 = 0;
    local_37a0 = 0;
    local_3798 = 0;
    uVar39 = 1;
    uVar33 = 1;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    uVar59 = 0;
    uVar21 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
    uVar54 = 0;
    uVar50 = 0;
    uVar52 = 0;
    local_140c = (int)&local_1390;
  }
  else {
    uVar49 = (undefined4)local_3838;
    uVar48 = (undefined4)((ulong)local_3838 >> 0x20);
    uVar27 = (uint)local_37f4;
    local_384a = local_37f1;
    local_384c = local_37f3;
    uVar29 = (uint)local_37e0;
    local_384e = local_37dd;
    local_3850 = local_37df;
    uVar38 = (uint)local_37cc;
    local_3852 = local_37c9;
    local_3854 = local_37cb;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_377c);
    local_3856 = local_3779;
    local_3858 = local_377b;
    uVar33 = (uint)local_3768;
    local_385a = local_3765;
    local_385c = local_3767;
    uVar39 = (uint)local_3754;
    local_385e = local_3751;
    local_3860 = local_3753;
    uVar37 = (uint)local_373c;
    uVar59 = local_3770;
    uVar21 = local_3778;
    uVar13 = local_375c;
    uVar14 = local_3764;
    uVar16 = local_3784;
    uVar18 = local_378c;
    uVar23 = local_3750;
    uVar41 = local_3790;
    uVar47 = local_3748;
    uVar60 = local_3744;
    uVar46 = local_3740;
    uVar54 = local_3840;
    uVar24 = local_3844;
    uVar35 = local_382c;
    uVar50 = local_3848;
    local_1488 = local_3830;
    uVar52 = local_3810;
    local_140c = local_37b4;
  }
  local_4840 = CONCAT44(local_4840._4_4_,uVar24);
  local_48b8 = CONCAT44(uVar48,uVar49);
  local_1490 = CONCAT44(uVar48,uVar49);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_1488);
  local_4850 = CONCAT44(local_4850._4_4_,uVar35);
  local_4848 = CONCAT44(local_4848._4_4_,local_380c);
  local_4860 = CONCAT44(local_4860._4_4_,local_3808);
  local_4858 = CONCAT44(local_4858._4_4_,uVar27);
  local_144c = (undefined1)uVar27;
  local_1449 = local_384a;
  local_144b = local_384c;
  local_4868 = CONCAT44(local_4868._4_4_,uVar29);
  local_1438 = (undefined1)uVar29;
  local_1437 = local_3850;
  local_1435 = local_384e;
  local_4870 = CONCAT44(local_4870._4_4_,uVar38);
  local_1424 = (undefined1)uVar38;
  local_1423 = local_3854;
  local_1421 = local_3852;
  local_4888 = CONCAT44(local_4888._4_4_,local_37b8);
  local_4890 = CONCAT44(local_4890._4_4_,local_140c);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_3798);
  local_13ec = 2f;
  local_13d4 = SUB81(local_47e0,0);
  local_13d1 = local_3856;
  local_13d3 = local_3858;
  local_48e0 = CONCAT44(local_48e0._4_4_,uVar33);
  local_13c0 = (undefined1)uVar33;
  local_13bd = local_385a;
  local_13bf = local_385c;
  local_48d8 = CONCAT44(local_48d8._4_4_,uVar39);
  local_13ac = (undefined1)uVar39;
  local_13a9 = local_385e;
  local_13ab = local_3860;
  local_4838 = CONCAT44(local_4838._4_4_,uVar37);
  local_1394 = (undefined1)uVar37;
  puVar12 = &local_14a0;
  local_48e8 = local_3818;
  local_48d0 = local_3820;
  local_48c8 = local_3828;
  local_48a8 = local_37a0;
  local_48a0 = local_37a8;
  local_4898 = local_37b0;
  local_4880 = local_37c0;
  local_4878 = local_37c8;
  local_4830 = local_37e8;
  local_4828 = local_37f0;
  local_4820 = local_37fc;
  local_4818 = local_37d4;
  local_4800 = local_37dc;
  local_47f8 = local_3804;
  local_14a0 = uVar50;
  local_149c = uVar24;
  local_1498 = uVar54;
  local_1484 = uVar35;
  local_1480 = local_3828;
  local_1478 = local_3820;
  local_1470 = local_3818;
  local_1468 = uVar52;
  local_1464 = local_380c;
  local_1460 = local_3808;
  local_145c = local_3804;
  local_1454 = local_37fc;
  local_1448 = local_37f0;
  local_1440 = local_37e8;
  local_1434 = local_37dc;
  local_142c = local_37d4;
  local_1420 = local_37c8;
  local_1418 = local_37c0;
  local_1410 = local_37b8;
  local_1408 = local_37b0;
  local_1400 = local_37a8;
  local_13f8 = local_37a0;
  local_13f0 = local_3798;
  local_13e8 = uVar41;
  local_13e4 = uVar18;
  local_13dc = uVar16;
  local_13d0 = uVar21;
  local_13c8 = uVar59;
  local_13bc = uVar14;
  local_13b4 = uVar13;
  local_13a8 = uVar23;
  local_13a0 = uVar47;
  local_139c = uVar60;
  local_1398 = uVar46;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_15ac = (undefined4)local_4840;
    local_15a0 = local_48b8;
    local_1598 = (undefined4)local_48c0;
    local_1594 = (undefined4)local_4850;
    local_1590 = local_48c8;
    local_1588 = local_48d0;
    local_1580 = local_48e8;
    local_1574 = (undefined4)local_4848;
    local_1570 = (undefined4)local_4860;
    local_156c = local_47f8;
    local_1564 = local_4820;
    local_155c = (undefined1)local_4858;
    local_155b = local_384c;
    local_1559 = local_384a;
    local_1558 = local_4828;
    local_1550 = local_4830;
    local_1548 = (undefined1)local_4868;
    local_1545 = local_384e;
    local_1547 = local_3850;
    local_1544 = local_4800;
    local_153c = local_4818;
    local_1534 = (undefined1)local_4870;
    local_1531 = local_3852;
    local_1533 = local_3854;
    local_1530 = local_4878;
    local_1528 = local_4880;
    local_1520 = (undefined4)local_4888;
    local_151c = (undefined4)local_4890;
    local_1518 = local_4898;
    local_1510 = local_48a0;
    local_1508 = local_48a8;
    local_1500 = (undefined4)local_48b0;
    local_14fc = 2f;
    local_14e4 = SUB81(local_47e0,0);
    local_14e1 = local_3856;
    local_14e3 = local_3858;
    local_14d0 = (undefined1)local_48e0;
    local_14cd = local_385a;
    local_14cf = local_385c;
    local_14bc = (undefined1)local_48d8;
    local_14b9 = local_385e;
    local_14bb = local_3860;
    local_14a4 = (undefined1)local_4838;
    local_15b0 = uVar50;
    local_15a8 = uVar54;
    local_1578 = uVar52;
    local_14f8 = uVar41;
    local_14f4 = uVar18;
    local_14ec = uVar16;
    local_14e0 = uVar21;
    local_14d8 = uVar59;
    local_14cc = uVar14;
    local_14c4 = uVar13;
    local_14b8 = uVar23;
    local_14b0 = uVar47;
    local_14ac = uVar60;
    local_14a8 = uVar46;
    _CGPointMake(&local_15b0);
    func_0x000198104610(auStack_3970,&local_15b0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3970);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3970,0x10d);
  func_0x000198104610(&local_3a80,auStack_3970,0x10d);
  iVar8 = (int)&local_3a80;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3a3c = 0;
    local_3a34 = 0;
    local_3a28 = 0;
    local_3a20 = 0;
    local_3a14 = 0;
    local_3a0c = 0;
    uVar27 = 0;
    uVar52 = 0;
    uVar49 = 0;
    local_1598 = 0;
    local_3a60 = 0;
    local_3a58 = 0;
    local_3a44 = 0;
    uVar37 = 1;
    local_3a40 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_3a00 = 0;
    local_39f8 = 0;
    local_39f0 = 0;
    local_39e8 = 0;
    local_39e0 = 0;
    local_39d8 = 0;
    local_39d0 = 0;
    local_39cc = 0;
    uVar40 = 1;
    uVar39 = 1;
    uVar33 = 1;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar56 = 0;
    local_3a7c = uVar24;
    local_3a64 = uVar35;
    uVar46 = 0;
    uVar50 = 0;
  }
  else {
    uVar52 = (undefined4)local_3a70;
    uVar49 = (undefined4)((ulong)local_3a70 >> 0x20);
    uVar37 = (uint)local_3a2c;
    local_3a82 = local_3a29;
    local_3a84 = local_3a2b;
    uVar29 = (uint)local_3a18;
    local_3a86 = local_3a15;
    local_3a88 = local_3a17;
    uVar38 = (uint)local_3a04;
    local_3a8a = local_3a01;
    local_3a8c = local_3a03;
    uVar21 = (ulong)local_39ec;
    uVar33 = (uint)local_39b4;
    local_3a8e = local_39b1;
    local_3a90 = local_39b3;
    uVar39 = (uint)local_39a0;
    local_3a92 = local_399d;
    local_3a94 = local_399f;
    uVar40 = (uint)local_398c;
    local_3a96 = local_3989;
    local_3a98 = local_398b;
    uVar27 = (uint)local_3974;
    uVar59 = local_39c4;
    uVar13 = local_39a8;
    uVar14 = local_39b0;
    uVar16 = local_3994;
    uVar18 = local_399c;
    uVar23 = local_39bc;
    uVar54 = local_3a50;
    uVar55 = local_3988;
    uVar41 = local_3980;
    uVar47 = local_397c;
    uVar60 = local_3978;
    uVar56 = local_3a78;
    uVar46 = local_3a80;
    local_1598 = local_3a68;
    uVar50 = local_3a48;
  }
  local_47d8 = (undefined8 *)((ulong)local_47d8 & 0xffffffffffff | 0xb2e4000000000000);
  local_4838 = CONCAT44(local_4838._4_4_,local_3a7c);
  local_48b8 = CONCAT44(uVar49,uVar52);
  local_15a0 = CONCAT44(uVar49,uVar52);
  local_48c0 = CONCAT44(local_48c0._4_4_,local_1598);
  local_4848 = CONCAT44(local_4848._4_4_,local_3a64);
  local_4840 = CONCAT44(local_4840._4_4_,local_3a44);
  local_4858 = CONCAT44(local_4858._4_4_,local_3a40);
  local_4850 = CONCAT44(local_4850._4_4_,uVar37);
  local_155c = (undefined1)uVar37;
  local_1559 = local_3a82;
  local_155b = local_3a84;
  local_4860 = CONCAT44(local_4860._4_4_,uVar29);
  local_1548 = (undefined1)uVar29;
  local_1547 = local_3a88;
  local_1545 = local_3a86;
  local_4868 = CONCAT44(local_4868._4_4_,uVar38);
  local_1534 = (undefined1)uVar38;
  local_1533 = local_3a8c;
  local_1531 = local_3a8a;
  local_4880 = CONCAT44(local_4880._4_4_,local_39f0);
  local_151c = (undefined4)uVar21;
  local_4888 = CONCAT44(local_4888._4_4_,local_151c);
  local_48a8 = CONCAT44(local_48a8._4_4_,local_39d0);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_39cc);
  local_14f8 = 1f;
  local_48e0 = CONCAT44(local_48e0._4_4_,uVar33);
  local_14e4 = (undefined1)uVar33;
  local_14e1 = local_3a8e;
  local_14e3 = local_3a90;
  local_48d8 = CONCAT44(local_48d8._4_4_,uVar39);
  local_14d0 = (undefined1)uVar39;
  local_14cd = local_3a92;
  local_14cf = local_3a94;
  local_48d0 = CONCAT44(local_48d0._4_4_,uVar40);
  local_14bc = (undefined1)uVar40;
  local_14b9 = local_3a96;
  local_14bb = local_3a98;
  local_4830 = CONCAT44(local_4830._4_4_,uVar27);
  local_14a4 = (undefined1)uVar27;
  puVar12 = &local_15b0;
  uVar15 = uVar16;
  uVar17 = uVar18;
  local_48e8 = local_3a58;
  local_48c8 = local_3a60;
  local_48a0 = local_39d8;
  local_4898 = local_39e0;
  local_4890 = local_39e8;
  local_4878 = local_39f8;
  local_4870 = local_3a00;
  local_4828 = local_3a14;
  local_4820 = local_3a34;
  local_4818 = local_3a3c;
  local_4800 = local_3a0c;
  local_47f8 = local_3a20;
  local_47e0 = (uint3 *)local_3a28;
  local_15b0 = uVar46;
  local_15ac = local_3a7c;
  local_15a8 = uVar56;
  local_1594 = local_3a64;
  local_1590 = local_3a60;
  local_1588 = local_3a58;
  local_1580 = uVar54;
  local_1578 = uVar50;
  local_1574 = local_3a44;
  local_1570 = local_3a40;
  local_156c = local_3a3c;
  local_1564 = local_3a34;
  local_1558 = local_3a28;
  local_1550 = local_3a20;
  local_1544 = local_3a14;
  local_153c = local_3a0c;
  local_1530 = local_3a00;
  local_1528 = local_39f8;
  local_1520 = local_39f0;
  local_1518 = local_39e8;
  local_1510 = local_39e0;
  local_1508 = local_39d8;
  local_1500 = local_39d0;
  local_14fc = local_39cc;
  local_14f4 = uVar59;
  local_14ec = uVar23;
  local_14e0 = uVar14;
  local_14d8 = uVar13;
  local_14cc = uVar18;
  local_14c4 = uVar16;
  local_14b8 = uVar55;
  local_14b0 = uVar41;
  local_14ac = uVar47;
  local_14a8 = uVar60;
  FUN_195ed8068(puVar12,local_1b00);
  uVar49 = (undefined4)uVar17;
  uVar52 = (undefined4)uVar15;
  if (((ulong)puVar12 & 1) == 0) {
    local_16bc = (undefined4)local_4838;
    local_16b0 = local_48b8;
    local_16a8 = (undefined4)local_48c0;
    local_16a4 = (undefined4)local_4848;
    local_16a0 = local_48c8;
    local_1698 = local_48e8;
    local_1684 = (undefined4)local_4840;
    local_1680 = (undefined4)local_4858;
    local_167c = local_4818;
    local_1674 = local_4820;
    local_166c = (undefined1)local_4850;
    local_166b = local_3a84;
    local_1669 = local_3a82;
    local_1668 = local_47e0;
    local_1660 = local_47f8;
    local_1658 = (undefined1)local_4860;
    local_1655 = local_3a86;
    local_1657 = local_3a88;
    local_1654 = local_4828;
    local_164c = local_4800;
    local_1644 = (undefined1)local_4868;
    local_1641 = local_3a8a;
    local_1643 = local_3a8c;
    local_1640 = local_4870;
    local_1638 = local_4878;
    local_1630 = (undefined4)local_4880;
    local_162c = (undefined4)local_4888;
    local_1628 = local_4890;
    local_1620 = local_4898;
    local_1618 = local_48a0;
    local_1610 = (undefined4)local_48a8;
    local_160c = (undefined4)local_48b0;
    local_1608 = 1f;
    local_15f4 = (undefined1)local_48e0;
    local_15f1 = local_3a8e;
    local_15f3 = local_3a90;
    local_15e0 = (undefined1)local_48d8;
    local_15dd = local_3a92;
    local_15df = local_3a94;
    local_15cc = (undefined1)local_48d0;
    local_15c9 = local_3a96;
    local_15cb = local_3a98;
    local_15b4 = (undefined1)local_4830;
    local_16c0 = uVar46;
    local_16b8 = uVar56;
    local_1690 = uVar54;
    local_1688 = uVar50;
    local_1604 = uVar59;
    local_15fc = uVar23;
    local_15f0 = uVar14;
    local_15e8 = uVar13;
    local_15dc = uVar18;
    local_15d4 = uVar16;
    local_15c8 = uVar55;
    local_15c0 = uVar41;
    local_15bc = uVar47;
    local_15b8 = uVar60;
    _CGPointMake(&local_16c0);
    func_0x000198104610(auStack_3ba8,&local_16c0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3ba8);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3ba8,0x10d);
  lVar9 = local_47f0;
  (*local_4810)(local_47d8,local_47f0,local_4808 & 0xffffffff,local_47e8);
  uVar47 = 1f;
  uVar41 = func_0x0001981218c0(lVar9);
  func_0x000198104610(&local_3cb8,<highlights.hdr>,0x10d);
  iVar8 = (int)&local_3cb8;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3c4c = 0;
    local_3c44 = 0;
    uVar37 = 0;
    local_3bcc = 0;
    local_3bd4 = 0;
    local_3be0 = 0;
    local_3be8 = 0;
    uVar48 = 0;
    uVar51 = 0;
    uVar24 = 1;
    local_3c7c = 0;
    local_3c78 = 0;
    uVar35 = 1;
    uVar27 = 1;
    local_3c38 = 0;
    local_3c30 = 0;
    local_3c28 = 0;
    local_3c20 = 0;
    local_3c18 = 0;
    local_3c10 = 0;
    local_3c08 = 0;
    local_3c04 = 0;
    local_3c00 = 0;
    local_3bb0 = 0;
    local_3bb4 = 0;
    local_3bb8 = 0;
    local_47d8 = (undefined8 *)CONCAT44(local_47d8._4_4_,1);
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_3bc0 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar21 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    local_3c24 = 0x95f1cb74;
    uVar54 = 0;
    local_3cb4 = uVar52;
    local_3c9c = uVar49;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
  }
  else {
    uVar48 = (undefined4)local_3ca8;
    uVar51 = (undefined4)((ulong)local_3ca8 >> 0x20);
    uVar24 = (uint)local_3c64;
    local_3cba = local_3c61;
    local_3cbc = local_3c63;
    uVar35 = (uint)local_3c50;
    local_3cbe = local_3c4d;
    local_3cc0 = local_3c4f;
    uVar27 = (uint)local_3c3c;
    local_3cc2 = local_3c39;
    local_3cc4 = local_3c3b;
    local_3cc6 = local_3be9;
    local_3cc8 = local_3beb;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_3bd8);
    local_3cca = local_3bd5;
    local_3ccc = local_3bd7;
    local_47d8 = (undefined8 *)CONCAT44(local_47d8._4_4_,(uint)local_3bc4);
    local_3cce = local_3bc1;
    local_3cd0 = local_3bc3;
    uVar37 = (uint)local_3bac;
    uVar59 = local_3c74;
    uVar13 = local_3c6c;
    uVar14 = local_3c60;
    uVar21 = local_3c58;
    uVar16 = local_3c98;
    uVar18 = local_3c90;
    uVar23 = local_3c88;
    uVar54 = local_3cb0;
    uVar60 = local_3cb8;
    uVar46 = local_3ca0;
    uVar50 = local_3c80;
  }
  local_4820 = CONCAT44(local_4820._4_4_,local_3cb4);
  local_16b0 = CONCAT44(uVar51,uVar48);
  local_4828 = CONCAT44(local_4828._4_4_,local_3c9c);
  local_4838 = CONCAT44(local_4838._4_4_,local_3c7c);
  local_4840 = CONCAT44(local_4840._4_4_,local_3c78);
  local_4830 = CONCAT44(local_4830._4_4_,uVar24);
  local_166c = (undefined1)uVar24;
  local_1669 = local_3cba;
  local_166b = local_3cbc;
  local_4848 = CONCAT44(local_4848._4_4_,uVar35);
  local_1658 = (undefined1)uVar35;
  local_1657 = local_3cc0;
  local_1655 = local_3cbe;
  local_4850 = CONCAT44(local_4850._4_4_,uVar27);
  local_1644 = (undefined1)uVar27;
  local_1643 = local_3cc4;
  local_1641 = local_3cc2;
  local_4868 = CONCAT44(local_4868._4_4_,local_3c28);
  local_4870 = CONCAT44(local_4870._4_4_,local_3c24);
  local_4890 = CONCAT44(local_4890._4_4_,local_3c08);
  local_4898 = CONCAT44(local_4898._4_4_,local_3c04);
  local_48a0 = CONCAT44(local_48a0._4_4_,local_3c00);
  local_15f4 = 0;
  local_15f1 = local_3cc6;
  local_15f3 = local_3cc8;
  local_15e0 = SUB81(local_47e0,0);
  local_15dd = local_3cca;
  local_15df = local_3ccc;
  local_15cc = SUB81(local_47d8,0);
  local_15c9 = local_3cce;
  local_15cb = local_3cd0;
  local_48b8 = CONCAT44(local_48b8._4_4_,local_3bb8);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_3bb4);
  local_48a8 = CONCAT44(local_48a8._4_4_,local_3bb0);
  local_4818 = CONCAT44(local_4818._4_4_,uVar37);
  local_15b4 = (undefined1)uVar37;
  puVar12 = &local_16c0;
  local_48c0 = local_3bc0;
  local_4888 = local_3c10;
  local_4880 = local_3c18;
  local_4878 = local_3c20;
  local_4860 = local_3c30;
  local_4858 = local_3c38;
  local_4810 = (code *)local_3bd4;
  local_4808 = local_3bcc;
  local_4800 = local_3be8;
  local_47f8 = local_3be0;
  local_47f0 = local_3c44;
  local_47e8 = local_3c4c;
  local_16c0 = uVar60;
  local_16bc = local_3cb4;
  local_16b8 = uVar54;
  local_16a8 = uVar46;
  local_16a4 = local_3c9c;
  local_16a0 = uVar16;
  local_1698 = uVar18;
  local_1690 = uVar23;
  local_1688 = uVar50;
  local_1684 = local_3c7c;
  local_1680 = local_3c78;
  local_167c = uVar59;
  local_1674 = uVar13;
  local_1668 = uVar14;
  local_1660 = uVar21;
  local_1654 = local_3c4c;
  local_164c = local_3c44;
  local_1640 = local_3c38;
  local_1638 = local_3c30;
  local_1630 = local_3c28;
  local_162c = local_3c24;
  local_1628 = local_3c20;
  local_1620 = local_3c18;
  local_1618 = local_3c10;
  local_1610 = local_3c08;
  local_160c = local_3c04;
  local_1608 = local_3c00;
  local_1604 = CONCAT44(extraout_s1_00,uVar41);
  local_15fc = CONCAT44(extraout_s3_00,uVar47);
  local_15f0 = local_3be8;
  local_15e8 = local_3be0;
  local_15dc = local_3bd4;
  local_15d4 = local_3bcc;
  local_15c8 = local_3bc0;
  local_15c0 = local_3bb8;
  local_15bc = local_3bb4;
  local_15b8 = local_3bb0;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_17cc = (undefined4)local_4820;
    local_17b4 = (undefined4)local_4828;
    local_1794 = (undefined4)local_4838;
    local_1790 = (undefined4)local_4840;
    local_177c = (undefined1)local_4830;
    local_177b = local_3cbc;
    local_1779 = local_3cba;
    local_1768 = (undefined1)local_4848;
    local_1767 = local_3cc0;
    local_1765 = local_3cbe;
    local_1764 = local_47e8;
    local_175c = local_47f0;
    local_1754 = (undefined1)local_4850;
    local_1753 = local_3cc4;
    local_1751 = local_3cc2;
    local_1750 = local_4858;
    local_1748 = local_4860;
    local_1740 = (undefined4)local_4868;
    local_173c = (undefined4)local_4870;
    local_1738 = local_4878;
    local_1730 = local_4880;
    local_1728 = local_4888;
    local_1720 = (undefined4)local_4890;
    local_171c = (undefined4)local_4898;
    local_1718 = (undefined4)local_48a0;
    local_1704 = 0;
    local_1701 = local_3cc6;
    local_1703 = local_3cc8;
    local_1700 = local_4800;
    local_16f8 = local_47f8;
    local_16f0 = SUB81(local_47e0,0);
    local_16ed = local_3cca;
    local_16ef = local_3ccc;
    local_16ec = local_4810;
    local_16e4 = local_4808;
    local_16dc = SUB81(local_47d8,0);
    local_16d9 = local_3cce;
    local_16db = local_3cd0;
    local_16d8 = local_48c0;
    local_16d0 = (undefined4)local_48b8;
    local_16cc = (undefined4)local_48b0;
    local_16c8 = (undefined4)local_48a8;
    local_16c4 = (undefined1)local_4818;
    local_17d0 = uVar60;
    local_17c8 = uVar54;
    local_17c0 = CONCAT44(uVar51,uVar48);
    local_17b8 = uVar46;
    local_17b0 = uVar16;
    local_17a8 = uVar18;
    local_17a0 = uVar23;
    local_1798 = uVar50;
    local_178c = uVar59;
    local_1784 = uVar13;
    local_1778 = uVar14;
    local_1770 = uVar21;
    local_1714 = CONCAT44(extraout_s1_00,uVar41);
    local_170c = CONCAT44(extraout_s3_00,uVar47);
    _CGPointMake(&local_17d0);
    func_0x000198104610(auStack_3de0,&local_17d0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_3de0);
  }
  func_0x000198104610(<highlights.hdr>,auStack_3de0,0x10d);
  func_0x000198104610(&local_3ef0,auStack_3de0,0x10d);
  iVar8 = (int)&local_3ef0;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_3eac = 0;
    local_3ea4 = 0;
    local_3e98 = 0;
    local_3e90 = 0;
    local_3e84 = 0;
    local_3e7c = 0;
    uVar37 = 0;
    local_3ee8 = 0;
    local_17d0 = 0;
    uVar49 = 0;
    uVar48 = 0;
    local_17b8 = 0;
    local_3ed0 = 0;
    local_3ec8 = 0;
    local_3ec0 = 0;
    local_1798 = 0;
    local_3eb4 = 0;
    uVar27 = 1;
    local_3eb0 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_3e70 = 0;
    uVar40 = 1;
    uVar39 = 1;
    uVar33 = 1;
    local_3e50 = 0;
    local_3e58 = 0;
    local_3e60 = 0;
    uVar59 = 0;
    uVar22 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar52 = 0;
  }
  else {
    uVar49 = (undefined4)local_3ee0;
    uVar48 = (undefined4)((ulong)local_3ee0 >> 0x20);
    uVar27 = (uint)local_3e9c;
    local_3ef2 = local_3e99;
    local_3ef4 = local_3e9b;
    uVar29 = (uint)local_3e88;
    local_3ef6 = local_3e85;
    local_3ef8 = local_3e87;
    uVar38 = (uint)local_3e74;
    local_3efa = local_3e71;
    local_3efc = local_3e73;
    uVar21 = (ulong)local_3e5c;
    uVar33 = (uint)local_3e24;
    local_3efe = local_3e21;
    local_3f00 = local_3e23;
    uVar39 = (uint)local_3e10;
    local_3f02 = local_3e0d;
    local_3f04 = local_3e0f;
    uVar40 = (uint)local_3dfc;
    local_3f06 = local_3df9;
    local_3f08 = local_3dfb;
    uVar37 = (uint)local_3de4;
    uVar59 = local_3e34;
    uVar22 = local_3e18;
    uVar13 = local_3e20;
    uVar14 = local_3e0c;
    uVar16 = local_3e04;
    uVar18 = local_3e2c;
    uVar23 = local_3df8;
    uVar54 = local_3e48;
    uVar41 = local_3e40;
    uVar47 = local_3e3c;
    uVar60 = local_3e38;
    uVar46 = local_3df0;
    uVar50 = local_3dec;
    uVar52 = local_3de8;
    uVar24 = local_3eec;
    uVar35 = local_3ed4;
    local_17d0 = local_3ef0;
    local_17b8 = local_3ed8;
    local_1798 = local_3eb8;
  }
  local_4898 = CONCAT44(local_4898._4_4_,local_17d0);
  local_4810 = (code *)CONCAT44(local_4810._4_4_,uVar24);
  local_4850 = CONCAT44(uVar48,uVar49);
  local_17c0 = CONCAT44(uVar48,uVar49);
  local_4858 = CONCAT44(local_4858._4_4_,local_17b8);
  local_4820 = CONCAT44(local_4820._4_4_,uVar35);
  local_4890 = CONCAT44(local_4890._4_4_,local_1798);
  local_4818 = CONCAT44(local_4818._4_4_,local_3eb4);
  local_4830 = CONCAT44(local_4830._4_4_,local_3eb0);
  local_4828 = CONCAT44(local_4828._4_4_,uVar27);
  local_177c = (undefined1)uVar27;
  local_1779 = local_3ef2;
  local_177b = local_3ef4;
  local_4838 = CONCAT44(local_4838._4_4_,uVar29);
  local_1768 = (undefined1)uVar29;
  local_1767 = local_3ef8;
  local_1765 = local_3ef6;
  local_4840 = CONCAT44(local_4840._4_4_,uVar38);
  local_1754 = (undefined1)uVar38;
  local_1753 = local_3efc;
  local_1751 = local_3efa;
  local_1748 = 3.5;
  local_48c0 = CONCAT44(local_48c0._4_4_,local_3e60);
  local_173c = (undefined4)uVar21;
  local_48b8 = CONCAT44(local_48b8._4_4_,local_173c);
  local_4880 = CONCAT44(local_4880._4_4_,uVar33);
  local_1704 = (undefined1)uVar33;
  local_1701 = local_3efe;
  local_1703 = local_3f00;
  local_4878 = CONCAT44(local_4878._4_4_,uVar39);
  local_16f0 = (undefined1)uVar39;
  local_16ed = local_3f02;
  local_16ef = local_3f04;
  local_4870 = CONCAT44(local_4870._4_4_,uVar40);
  local_16dc = (undefined1)uVar40;
  local_16d9 = local_3f06;
  local_16db = local_3f08;
  local_4808 = CONCAT44(local_4808._4_4_,uVar37);
  local_16c4 = (undefined1)uVar37;
  puVar12 = &local_17d0;
  local_48b0 = local_3e58;
  local_48a8 = local_3e50;
  local_48a0 = local_3ee8;
  local_4888 = local_3ec0;
  local_4868 = local_3ec8;
  local_4860 = local_3ed0;
  local_4848 = local_3e70;
  local_4800 = local_3e84;
  local_47f8 = local_3e90;
  local_47f0 = local_3ea4;
  local_47e8 = local_3eac;
  local_47e0 = (uint3 *)local_3e7c;
  local_47d8 = (undefined8 *)local_3e98;
  local_17cc = uVar24;
  local_17c8 = local_3ee8;
  local_17b4 = uVar35;
  local_17b0 = local_3ed0;
  local_17a8 = local_3ec8;
  local_17a0 = local_3ec0;
  local_1794 = local_3eb4;
  local_1790 = local_3eb0;
  local_178c = local_3eac;
  local_1784 = local_3ea4;
  local_1778 = local_3e98;
  local_1770 = local_3e90;
  local_1764 = local_3e84;
  local_175c = local_3e7c;
  local_1750 = local_3e70;
  local_1740 = local_3e60;
  local_1738 = local_3e58;
  local_1730 = local_3e50;
  local_1728 = uVar54;
  local_1720 = uVar41;
  local_171c = uVar47;
  local_1718 = uVar60;
  local_1714 = uVar59;
  local_170c = uVar18;
  local_1700 = uVar13;
  local_16f8 = uVar22;
  local_16ec = uVar14;
  local_16e4 = uVar16;
  local_16d8 = uVar23;
  local_16d0 = uVar46;
  local_16cc = uVar50;
  local_16c8 = uVar52;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_18e0 = (undefined4)local_4898;
    local_18dc = local_4810._0_4_;
    local_18d8 = local_48a0;
    local_18d0 = local_4850;
    local_18c8 = (undefined4)local_4858;
    local_18c4 = (undefined4)local_4820;
    local_18c0 = local_4860;
    local_18b8 = local_4868;
    local_18b0 = local_4888;
    local_18a8 = (undefined4)local_4890;
    local_18a4 = (undefined4)local_4818;
    local_18a0 = (undefined4)local_4830;
    local_189c = local_47e8;
    local_1894 = local_47f0;
    local_188c = (undefined1)local_4828;
    local_188b = local_3ef4;
    local_1889 = local_3ef2;
    local_1888 = local_47d8;
    local_1880 = local_47f8;
    local_1878 = (undefined1)local_4838;
    local_1875 = local_3ef6;
    local_1877 = local_3ef8;
    local_1874 = local_4800;
    local_186c = local_47e0;
    local_1864 = (undefined1)local_4840;
    local_1861 = local_3efa;
    local_1863 = local_3efc;
    local_1860 = local_4848;
    local_1858 = 3.5;
    local_1850 = (undefined4)local_48c0;
    local_184c = (undefined4)local_48b8;
    local_1848 = local_48b0;
    local_1840 = local_48a8;
    local_1814 = (undefined1)local_4880;
    local_1811 = local_3efe;
    local_1813 = local_3f00;
    local_1800 = (undefined1)local_4878;
    local_17fd = local_3f02;
    local_17ff = local_3f04;
    local_17ec = (undefined1)local_4870;
    local_17e9 = local_3f06;
    local_17eb = local_3f08;
    local_17d4 = (undefined1)local_4808;
    local_1838 = uVar54;
    local_1830 = uVar41;
    local_182c = uVar47;
    local_1828 = uVar60;
    local_1824 = uVar59;
    local_181c = uVar18;
    local_1810 = uVar13;
    local_1808 = uVar22;
    local_17fc = uVar14;
    local_17f4 = uVar16;
    local_17e8 = uVar23;
    local_17e0 = uVar46;
    local_17dc = uVar50;
    local_17d8 = uVar52;
    _CGPointMake(&local_18e0);
    func_0x000198104610(auStack_4018,&local_18e0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_4018);
  }
  func_0x000198104610(<highlights.hdr>,auStack_4018,0x10d);
  func_0x000198104610(&local_4128,auStack_4018,0x10d);
  iVar8 = (int)&local_4128;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_40e4 = 0;
    local_40dc = 0;
    local_40d0 = 0;
    local_40c8 = 0;
    local_40bc = 0;
    local_40b4 = 0;
    uVar27 = 0;
    local_4120 = 0;
    local_18e0 = 0;
    uVar49 = 0;
    uVar48 = 0;
    local_18c8 = 0;
    local_4108 = 0;
    local_4100 = 0;
    local_40f8 = 0;
    local_18a8 = 0;
    local_40ec = 0;
    uVar37 = 1;
    local_40e8 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_40a8 = 0;
    local_40a0 = 0;
    local_4098 = 0;
    local_4090 = 0;
    uVar40 = 1;
    uVar39 = 1;
    uVar33 = 1;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar52 = 0;
    local_4124 = uVar24;
  }
  else {
    uVar49 = (undefined4)local_4118;
    uVar48 = (undefined4)((ulong)local_4118 >> 0x20);
    uVar37 = (uint)local_40d4;
    local_412a = local_40d1;
    local_412c = local_40d3;
    uVar29 = (uint)local_40c0;
    local_412e = local_40bd;
    local_4130 = local_40bf;
    uVar38 = (uint)local_40ac;
    local_4132 = local_40a9;
    local_4134 = local_40ab;
    uVar22 = (ulong)local_4094;
    uVar33 = (uint)local_405c;
    local_4136 = local_4059;
    local_4138 = local_405b;
    uVar39 = (uint)local_4048;
    local_413a = local_4045;
    local_413c = local_4047;
    uVar40 = (uint)local_4034;
    local_413e = local_4031;
    local_4140 = local_4033;
    uVar27 = (uint)local_401c;
    uVar59 = local_406c;
    uVar13 = local_4050;
    uVar14 = local_4058;
    uVar16 = local_4044;
    uVar18 = local_403c;
    uVar23 = local_4064;
    uVar54 = local_4030;
    uVar55 = local_4080;
    uVar41 = local_4078;
    uVar47 = local_4074;
    uVar60 = local_4070;
    uVar46 = local_4028;
    uVar50 = local_4024;
    uVar52 = local_4020;
    uVar35 = local_410c;
    local_18e0 = local_4128;
    local_18c8 = local_4110;
    local_18a8 = local_40f0;
  }
  local_48b8 = CONCAT44(local_48b8._4_4_,local_18e0);
  local_4810 = (code *)CONCAT44(local_4810._4_4_,local_4124);
  local_4870 = CONCAT44(uVar48,uVar49);
  local_18d0 = CONCAT44(uVar48,uVar49);
  local_4878 = CONCAT44(local_4878._4_4_,local_18c8);
  local_4820 = CONCAT44(local_4820._4_4_,uVar35);
  local_48b0 = CONCAT44(local_48b0._4_4_,local_18a8);
  local_4818 = CONCAT44(local_4818._4_4_,local_40ec);
  local_4830 = CONCAT44(local_4830._4_4_,local_40e8);
  local_4828 = CONCAT44(local_4828._4_4_,uVar37);
  local_188c = (undefined1)uVar37;
  local_1889 = local_412a;
  local_188b = local_412c;
  local_4838 = CONCAT44(local_4838._4_4_,uVar29);
  local_1878 = (undefined1)uVar29;
  local_1877 = local_4130;
  local_1875 = local_412e;
  local_4840 = CONCAT44(local_4840._4_4_,uVar38);
  local_1864 = (undefined1)uVar38;
  local_1863 = local_4134;
  local_1861 = local_4132;
  local_4858 = CONCAT44(local_4858._4_4_,local_4098);
  local_184c = (undefined4)uVar22;
  local_4860 = CONCAT44(local_4860._4_4_,local_184c);
  local_1840 = 1;
  local_48a0 = CONCAT44(local_48a0._4_4_,uVar33);
  local_1814 = (undefined1)uVar33;
  local_1811 = local_4136;
  local_1813 = local_4138;
  local_4898 = CONCAT44(local_4898._4_4_,uVar39);
  local_1800 = (undefined1)uVar39;
  local_17fd = local_413a;
  local_17ff = local_413c;
  local_4890 = CONCAT44(local_4890._4_4_,uVar40);
  local_17ec = (undefined1)uVar40;
  local_17e9 = local_413e;
  local_17eb = local_4140;
  local_4808 = CONCAT44(local_4808._4_4_,uVar27);
  local_17d4 = (undefined1)uVar27;
  puVar12 = &local_18e0;
  local_48c0 = local_4120;
  local_48a8 = local_40f8;
  local_4888 = local_4100;
  local_4880 = local_4108;
  local_4868 = local_4090;
  local_4850 = local_40a0;
  local_4848 = local_40a8;
  local_4800 = local_40bc;
  local_47f8 = local_40c8;
  local_47f0 = local_40dc;
  local_47e8 = local_40e4;
  local_47e0 = (uint3 *)local_40b4;
  local_47d8 = (undefined8 *)local_40d0;
  local_18dc = local_4124;
  local_18d8 = local_4120;
  local_18c4 = uVar35;
  local_18c0 = local_4108;
  local_18b8 = local_4100;
  local_18b0 = local_40f8;
  local_18a4 = local_40ec;
  local_18a0 = local_40e8;
  local_189c = local_40e4;
  local_1894 = local_40dc;
  local_1888 = local_40d0;
  local_1880 = local_40c8;
  local_1874 = local_40bc;
  local_186c = local_40b4;
  local_1860 = local_40a8;
  local_1858 = local_40a0;
  local_1850 = local_4098;
  local_1848 = local_4090;
  local_1838 = uVar55;
  local_1830 = uVar41;
  local_182c = uVar47;
  local_1828 = uVar60;
  local_1824 = uVar59;
  local_181c = uVar23;
  local_1810 = uVar14;
  local_1808 = uVar13;
  local_17fc = uVar16;
  local_17f4 = uVar18;
  local_17e8 = uVar54;
  local_17e0 = uVar46;
  local_17dc = uVar50;
  local_17d8 = uVar52;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_19f0 = (undefined4)local_48b8;
    local_19ec = local_4810._0_4_;
    local_19e8 = local_48c0;
    local_19e0 = local_4870;
    local_19d8 = (undefined4)local_4878;
    local_19d4 = (undefined4)local_4820;
    local_19d0 = local_4880;
    local_19c8 = local_4888;
    local_19c0 = local_48a8;
    local_19b8 = (undefined4)local_48b0;
    local_19b4 = (undefined4)local_4818;
    local_19b0 = (undefined4)local_4830;
    local_19ac = local_47e8;
    local_19a4 = local_47f0;
    local_199c = (undefined1)local_4828;
    local_199b = local_412c;
    local_1999 = local_412a;
    local_1998 = local_47d8;
    local_1990 = local_47f8;
    local_1988 = (undefined1)local_4838;
    local_1985 = local_412e;
    local_1987 = local_4130;
    local_1984 = local_4800;
    local_197c = local_47e0;
    local_1974 = (undefined1)local_4840;
    local_1971 = local_4132;
    local_1973 = local_4134;
    local_1970 = local_4848;
    local_1968 = local_4850;
    local_1960 = (undefined4)local_4858;
    local_195c = (undefined4)local_4860;
    local_1958 = local_4868;
    local_1950 = 1;
    local_1924 = (undefined1)local_48a0;
    local_1921 = local_4136;
    local_1923 = local_4138;
    local_1910 = (undefined1)local_4898;
    local_190d = local_413a;
    local_190f = local_413c;
    local_18fc = (undefined1)local_4890;
    local_18f9 = local_413e;
    local_18fb = local_4140;
    local_18e4 = (undefined1)local_4808;
    local_1948 = uVar55;
    local_1940 = uVar41;
    local_193c = uVar47;
    local_1938 = uVar60;
    local_1934 = uVar59;
    local_192c = uVar23;
    local_1920 = uVar14;
    local_1918 = uVar13;
    local_190c = uVar16;
    local_1904 = uVar18;
    local_18f8 = uVar54;
    local_18f0 = uVar46;
    local_18ec = uVar50;
    local_18e8 = uVar52;
    _CGPointMake(&local_19f0);
    func_0x000198104610(auStack_4250,&local_19f0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_4250);
  }
  func_0x000198104610(<highlights.hdr>,auStack_4250,0x10d);
  func_0x000198104610(&local_4360,auStack_4250,0x10d);
  iVar8 = (int)&local_4360;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    uVar24 = 0;
    local_4274 = 0;
    local_427c = 0;
    local_4288 = 0;
    local_4290 = 0;
    local_42a4 = 0;
    local_19f0 = 0;
    uVar46 = 0;
    uVar50 = 0;
    uVar27 = 1;
    local_4320 = 0;
    uVar29 = 1;
    uVar38 = 1;
    local_42e0 = 0;
    local_42d8 = 0;
    local_42d0 = 0;
    local_4258 = 0;
    local_425c = 0;
    local_4260 = 0;
    local_4268 = 0;
    local_47d8 = (undefined8 *)CONCAT44(local_47d8._4_4_,1);
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,1);
    local_47e8 = CONCAT44(local_47e8._4_4_,1);
    local_42a8 = 0;
    local_42ac = 0;
    local_42b0 = 0;
    local_42b8 = 0;
    local_42c0 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar21 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar56 = 0;
    uVar41 = 0;
    local_42cc = 0x95f1dbc0;
    uVar15 = 0;
    uVar47 = 0;
    uVar60 = 0;
  }
  else {
    uVar46 = (undefined4)local_4350;
    uVar50 = (undefined4)((ulong)local_4350 >> 0x20);
    uVar27 = (uint)local_430c;
    local_4362 = local_4309;
    local_4364 = local_430b;
    uVar29 = (uint)local_42f8;
    local_4366 = local_42f5;
    local_4368 = local_42f7;
    uVar38 = (uint)local_42e4;
    local_436a = local_42e1;
    local_436c = local_42e3;
    local_47e8 = CONCAT44(local_47e8._4_4_,(uint)local_4294);
    local_436e = local_4291;
    local_4370 = local_4293;
    local_47e0 = (uint3 *)CONCAT44(local_47e0._4_4_,(uint)local_4280);
    local_4372 = local_427d;
    local_4374 = local_427f;
    local_47d8 = (undefined8 *)CONCAT44(local_47d8._4_4_,(uint)local_426c);
    local_4376 = local_4269;
    local_4378 = local_426b;
    uVar24 = (uint)local_4254;
    uVar59 = local_431c;
    uVar13 = local_4314;
    uVar14 = local_4308;
    uVar16 = local_4300;
    uVar21 = local_42f4;
    uVar18 = local_42ec;
    uVar23 = local_429c;
    uVar54 = local_4340;
    uVar55 = local_4338;
    uVar56 = local_4330;
    uVar41 = local_4324;
    uVar15 = local_4358;
    uVar35 = local_435c;
    uVar37 = local_4344;
    local_19f0 = local_4360;
    uVar47 = local_4348;
    uVar60 = local_4328;
  }
  local_4828 = CONCAT44(local_4828._4_4_,local_19f0);
  local_4820 = CONCAT44(local_4820._4_4_,uVar35);
  local_19e0 = CONCAT44(uVar50,uVar46);
  local_4830 = CONCAT44(local_4830._4_4_,uVar37);
  local_4840 = CONCAT44(local_4840._4_4_,local_4320);
  local_4838 = CONCAT44(local_4838._4_4_,uVar27);
  local_199c = (undefined1)uVar27;
  local_1999 = local_4362;
  local_199b = local_4364;
  local_4848 = CONCAT44(local_4848._4_4_,uVar29);
  local_1988 = (undefined1)uVar29;
  local_1987 = local_4368;
  local_1985 = local_4366;
  local_4850 = CONCAT44(local_4850._4_4_,uVar38);
  local_1974 = (undefined1)uVar38;
  local_1973 = local_436c;
  local_1971 = local_436a;
  local_4868 = CONCAT44(local_4868._4_4_,local_42d0);
  local_4870 = CONCAT44(local_4870._4_4_,local_42cc);
  local_1958 = 0.872665;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_42b0);
  local_48a0 = CONCAT44(local_48a0._4_4_,local_42ac);
  local_4898 = CONCAT44(local_4898._4_4_,local_42a8);
  local_1924 = (undefined1)local_47e8;
  local_1921 = local_436e;
  local_1923 = local_4370;
  local_1910 = SUB81(local_47e0,0);
  local_190d = local_4372;
  local_190f = local_4374;
  local_18fc = SUB81(local_47d8,0);
  local_18f9 = local_4376;
  local_18fb = local_4378;
  local_4888 = CONCAT44(local_4888._4_4_,local_4260);
  local_4880 = CONCAT44(local_4880._4_4_,local_425c);
  local_4878 = CONCAT44(local_4878._4_4_,local_4258);
  local_4818 = CONCAT44(local_4818._4_4_,uVar24);
  local_18e4 = (undefined1)uVar24;
  puVar12 = &local_19f0;
  local_48b8 = local_42c0;
  local_48b0 = local_42b8;
  local_4890 = local_4268;
  local_4860 = local_42d8;
  local_4858 = local_42e0;
  local_4810 = (code *)local_427c;
  local_4808 = local_4274;
  local_4800 = local_4290;
  local_47f8 = local_4288;
  local_47f0 = local_42a4;
  local_19ec = uVar35;
  local_19e8 = uVar15;
  local_19d8 = uVar47;
  local_19d4 = uVar37;
  local_19d0 = uVar54;
  local_19c8 = uVar55;
  local_19c0 = uVar56;
  local_19b8 = uVar60;
  local_19b4 = uVar41;
  local_19b0 = local_4320;
  local_19ac = uVar59;
  local_19a4 = uVar13;
  local_1998 = uVar14;
  local_1990 = uVar16;
  local_1984 = uVar21;
  local_197c = uVar18;
  local_1970 = local_42e0;
  local_1968 = local_42d8;
  local_1960 = local_42d0;
  local_195c = local_42cc;
  local_1950 = local_42c0;
  local_1948 = local_42b8;
  local_1940 = local_42b0;
  local_193c = local_42ac;
  local_1938 = local_42a8;
  local_1934 = local_42a4;
  local_192c = uVar23;
  local_1920 = local_4290;
  local_1918 = local_4288;
  local_190c = local_427c;
  local_1904 = local_4274;
  local_18f8 = local_4268;
  local_18f0 = local_4260;
  local_18ec = local_425c;
  local_18e8 = local_4258;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_1c10 = (undefined4)local_4828;
    local_1c0c = (undefined4)local_4820;
    local_1bf4 = (undefined4)local_4830;
    local_1bd0 = (undefined4)local_4840;
    local_1bbc = (undefined1)local_4838;
    local_1bbb = local_4364;
    local_1bb9 = local_4362;
    local_1ba8 = (undefined1)local_4848;
    local_1ba5 = local_4366;
    local_1ba7 = local_4368;
    local_1b94 = (undefined1)local_4850;
    local_1b91 = local_436a;
    local_1b93 = local_436c;
    local_1b90 = local_4858;
    local_1b88 = local_4860;
    local_1b80 = (undefined4)local_4868;
    local_1b7c = (undefined4)local_4870;
    local_1b78 = 0.872665;
    local_1b70 = local_48b8;
    local_1b68 = local_48b0;
    local_1b60 = (undefined4)local_48a8;
    local_1b5c = (undefined4)local_48a0;
    local_1b58 = (undefined4)local_4898;
    local_1b54 = local_47f0;
    local_1b44 = (undefined1)local_47e8;
    local_1b41 = local_436e;
    local_1b43 = local_4370;
    local_1b40 = local_4800;
    local_1b38 = local_47f8;
    local_1b30 = SUB81(local_47e0,0);
    local_1b2d = local_4372;
    local_1b2f = local_4374;
    local_1b2c = local_4810;
    local_1b24 = local_4808;
    local_1b1c = SUB81(local_47d8,0);
    local_1b19 = local_4376;
    local_1b1b = local_4378;
    local_1b18 = local_4890;
    local_1b10 = (undefined4)local_4888;
    local_1b0c = (undefined4)local_4880;
    local_1b08 = (undefined4)local_4878;
    local_1b04 = (undefined1)local_4818;
    local_1c08 = uVar15;
    local_1c00 = CONCAT44(uVar50,uVar46);
    local_1bf8 = uVar47;
    local_1bf0 = uVar54;
    local_1be8 = uVar55;
    local_1be0 = uVar56;
    local_1bd8 = uVar60;
    local_1bd4 = uVar41;
    local_1bcc = uVar59;
    local_1bc4 = uVar13;
    local_1bb8 = uVar14;
    local_1bb0 = uVar16;
    local_1ba4 = uVar21;
    local_1b9c = uVar18;
    local_1b4c = uVar23;
    _CGPointMake(&local_1c10);
    func_0x000198104610(auStack_4488,&local_1c10,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_4488);
  }
  func_0x000198104610(<highlights.hdr>,auStack_4488,0x10d);
  func_0x000198104610(&local_4598,auStack_4488,0x10d);
  iVar8 = (int)&local_4598;
  FUN_195e7d8c0();
  if (iVar8 == 1) {
    local_4554 = 0;
    local_454c = 0;
    local_4540 = 0;
    local_4538 = 0;
    local_452c = 0;
    local_4524 = 0;
    local_4590 = 0;
    local_1c10 = 0;
    uVar49 = 0;
    uVar48 = 0;
    local_1bf8 = 0;
    local_4578 = 0;
    local_4570 = 0;
    local_4568 = 0;
    local_1bd8 = 0;
    local_455c = 0;
    uVar24 = 1;
    local_4558 = 0;
    uVar27 = 1;
    uVar29 = 1;
    local_4518 = 0;
    local_4510 = 0;
    uVar38 = 1;
    uVar33 = 1;
    local_44f8 = 0;
    local_4500 = 0;
    uVar59 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar16 = 0;
    uVar18 = 0;
    uVar23 = 0;
    uVar54 = 0;
    uVar55 = 0;
    uVar41 = 0;
    uVar47 = 0;
    uVar60 = 0;
    uVar34 = 1;
    uVar46 = 0;
    uVar50 = 0;
    uVar52 = 0;
    local_4594 = uVar35;
    local_457c = uVar37;
    uVar19 = 0;
  }
  else {
    uVar49 = (undefined4)local_4588;
    uVar48 = (undefined4)((ulong)local_4588 >> 0x20);
    uVar24 = (uint)local_4544;
    local_459a = local_4541;
    local_459c = local_4543;
    uVar27 = (uint)local_4530;
    local_459e = local_452d;
    local_45a0 = local_452f;
    uVar29 = (uint)local_451c;
    local_45a2 = local_4519;
    local_45a4 = local_451b;
    uVar21 = (ulong)local_4504;
    uVar33 = (uint)local_44cc;
    local_45a6 = local_44c9;
    local_45a8 = local_44cb;
    uVar38 = (uint)local_44b8;
    local_45aa = local_44b5;
    local_45ac = local_44b7;
    local_45ae = local_44a1;
    local_45b0 = local_44a3;
    uVar59 = local_44dc;
    uVar13 = local_44c0;
    uVar14 = local_44c8;
    uVar16 = local_44ac;
    uVar18 = local_44b4;
    uVar23 = local_44d4;
    uVar54 = local_44a0;
    uVar55 = local_44f0;
    uVar41 = local_44e8;
    uVar47 = local_44e4;
    uVar60 = local_44e0;
    uVar34 = local_44a4;
    uVar46 = local_4498;
    uVar50 = local_4494;
    uVar52 = local_4490;
    local_1c10 = local_4598;
    local_1bf8 = local_4580;
    local_1bd8 = local_4560;
    uVar19 = local_448c;
  }
  local_4808 = CONCAT44(local_4808._4_4_,local_1c10);
  local_4800 = CONCAT44(local_4800._4_4_,local_4594);
  local_4848 = CONCAT44(uVar48,uVar49);
  local_1c00 = CONCAT44(uVar48,uVar49);
  local_4850 = CONCAT44(local_4850._4_4_,local_1bf8);
  local_4810 = (code *)CONCAT44(local_4810._4_4_,local_457c);
  local_4888 = CONCAT44(local_4888._4_4_,local_1bd8);
  local_4890 = CONCAT44(local_4890._4_4_,local_455c);
  local_4820 = CONCAT44(local_4820._4_4_,local_4558);
  local_4818 = CONCAT44(local_4818._4_4_,uVar24);
  local_1bbc = (undefined1)uVar24;
  local_1bb9 = local_459a;
  local_1bbb = local_459c;
  local_4828 = CONCAT44(local_4828._4_4_,uVar27);
  local_1ba8 = (undefined1)uVar27;
  local_1ba7 = local_45a0;
  local_1ba5 = local_459e;
  local_4830 = CONCAT44(local_4830._4_4_,uVar29);
  local_1b94 = (undefined1)uVar29;
  local_1b93 = local_45a4;
  local_1b91 = local_45a2;
  local_1b80 = 0.7f;
  local_1b7c = (undefined4)uVar21;
  local_48a8 = CONCAT44(local_48a8._4_4_,local_1b7c);
  local_4878 = CONCAT44(local_4878._4_4_,uVar33);
  local_1b44 = (undefined1)uVar33;
  local_1b41 = local_45a6;
  local_1b43 = local_45a8;
  local_4870 = CONCAT44(local_4870._4_4_,uVar38);
  local_1b30 = (undefined1)uVar38;
  local_1b2d = local_45aa;
  local_1b2f = local_45ac;
  local_1b19 = local_45ae;
  local_1b1b = local_45b0;
  puVar12 = &local_1c10;
  local_48b0 = local_4500;
  local_48a0 = local_44f8;
  local_4898 = local_4590;
  local_4880 = local_4568;
  local_4868 = local_4554;
  local_4860 = local_4570;
  local_4858 = local_4578;
  local_4840 = local_4510;
  local_4838 = local_4518;
  local_47f8 = local_4538;
  local_47f0 = local_4540;
  local_47e8 = local_454c;
  local_47e0 = (uint3 *)local_4524;
  local_47d8 = (undefined8 *)local_452c;
  local_1c0c = local_4594;
  local_1c08 = local_4590;
  local_1bf4 = local_457c;
  local_1bf0 = local_4578;
  local_1be8 = local_4570;
  local_1be0 = local_4568;
  local_1bd4 = local_455c;
  local_1bd0 = local_4558;
  local_1bcc = local_4554;
  local_1bc4 = local_454c;
  local_1bb8 = local_4540;
  local_1bb0 = local_4538;
  local_1ba4 = local_452c;
  local_1b9c = local_4524;
  local_1b90 = local_4518;
  local_1b88 = local_4510;
  local_1b78 = local_4500;
  local_1b70 = local_44f8;
  local_1b68 = uVar55;
  local_1b60 = uVar41;
  local_1b5c = uVar47;
  local_1b58 = uVar60;
  local_1b54 = uVar59;
  local_1b4c = uVar23;
  local_1b40 = uVar14;
  local_1b38 = uVar13;
  local_1b2c = uVar18;
  local_1b24 = uVar16;
  local_1b1c = uVar34;
  local_1b18 = uVar54;
  local_1b10 = uVar46;
  local_1b0c = uVar50;
  local_1b08 = uVar52;
  local_1b04 = uVar19;
  FUN_195ed8068(puVar12,local_1b00);
  if (((ulong)puVar12 & 1) == 0) {
    local_47d0 = (undefined4)local_4808;
    local_47cc = (undefined4)local_4800;
    local_47c8 = local_4898;
    uStack_47c0 = local_4848;
    local_47b8 = CONCAT44(local_4810._0_4_,(int)local_4850);
    local_47b0 = local_4858;
    local_47a8 = local_4860;
    local_47a0 = local_4880;
    local_4798 = (undefined4)local_4888;
    local_4794 = (undefined4)local_4890;
    local_4790 = (undefined4)local_4820;
    local_478c = local_4868;
    local_4784 = local_47e8;
    local_477c = (undefined1)local_4818;
    local_477b = local_459c;
    local_4779 = local_459a;
    local_4778 = local_47f0;
    uStack_4770 = local_47f8;
    local_4768 = (undefined1)local_4828;
    local_4765 = local_459e;
    local_4767 = local_45a0;
    local_4764 = local_47d8;
    local_475c = local_47e0;
    local_4754 = (undefined1)local_4830;
    local_4751 = local_45a2;
    local_4753 = local_45a4;
    local_4750 = local_4838;
    uStack_4748 = local_4840;
    local_4740 = 0.7f;
    local_473c = (undefined4)local_48a8;
    local_4738 = local_48b0;
    uStack_4730 = local_48a0;
    local_4704 = (undefined1)local_4878;
    local_4701 = local_45a6;
    local_4703 = local_45a8;
    local_46f0 = (undefined1)local_4870;
    local_46ed = local_45aa;
    local_46ef = local_45ac;
    local_46d9 = local_45ae;
    local_46db = local_45b0;
    local_4728 = uVar55;
    local_4720 = uVar41;
    local_471c = uVar47;
    local_4718 = uVar60;
    local_4714 = uVar59;
    local_470c = uVar23;
    local_4700 = uVar14;
    uStack_46f8 = uVar13;
    local_46ec = uVar18;
    local_46e4 = uVar16;
    local_46dc = uVar34;
    local_46d8 = uVar54;
    local_46d0 = uVar46;
    local_46cc = uVar50;
    local_46c8 = uVar52;
    local_46c4 = uVar19;
    _CGPointMake(&local_47d0);
    func_0x000198104610(auStack_46c0,&local_47d0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_46c0);
  }
  func_0x000198104610(<highlights.hdr>,auStack_46c0,0x10d);
  if (<+0x438> == '\x01') {
    uVar47 = 0;
    uVar41 = 0;
    local_47cc = 0;
    local_47d0 = 0;
    local_47c8 = 0;
    uStack_47c0 = 0;
    local_47b8 = 0;
  }
  else {
    uVar41 = <+0x428>;
    uVar47 = <+0x42c>;
    local_47b8 = <+0x420>;
    local_47d0 = <+0x408>;
    local_47cc = <+0x40c>;
    local_47c8 = <+0x410>;
    uStack_47c0 = <+0x418>;
  }
  local_47b0 = CONCAT44(uVar47,uVar41);
  local_47a8 = 0;
  FUN_195ed0ef0(&local_47d0);
  return;
}


//######## RegularBlurModifier (spec) 0x195f1e798
// === 195f1e798 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1e798(ulong param_1)
{
  uVar4 = param_1;
  FUN_195ed53f0();
  bVar3 = (uVar4 & 1) == 0;
  uVar1 = 64;
  if (bVar3) {
    uVar1 = 48;
  }
  uVar5 = 2f;
  if (bVar3) {
    uVar5 = 4f;
  }
  FUN_195f234d4(<blur.opacity>);
  uVar2 = {d 0.0078125};
  <blur.opacities.1> = {d 3.05176e-05};
  <blur.opacity> = uVar2;
  <blur.opacities.3> = 3.05176e-05;
  <blur.distances.0.kind> = 1;
  <blur.distances.1.v> = -1f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.blurRadius> = uVar1;
  <+0x170> = 160;
  <+0x178> = 1.33333f;
  <+0x17c> = uVar5;
  uVar1 = {f 0, 1.4013e-45};
  <+0x188> = {d 0};
  <+0x180> = uVar1;
  <+0x190> = 0x201;
  <blur.outerRefractionBlurRadius> = 0;
  <blur.outerRefractionBlurRadius?nil> = 1;
  return;
}


//######## RegularDiffusionAmount (spec) 0x195f1e85c
// === 195f22ea0 spec

/* WARNING: Removing unreachable block (ram,0x000195f22f84) */
/* WARNING: Removing unreachable block (ram,0x000195f22f0c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f22ea0(long param_1,long param_2)
{
  undefined4 auStack_e0 [4];
  ulong local_d0 [3];
  lVar4 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar11 = (long)local_d0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar5 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(uVar5 - 8);
  uVar6 = uVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  lVar12 = lVar11 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar6 & 1) != 0) {
    lVar7 = 0;
    FUN_195f3c68c();
    pfVar1 = (float *)(param_2 + *(int *)(lVar7 + 0x70));
    if ((*(char *)(pfVar1 + 1) != '\x01') && (fVar20 = *pfVar1, 0.00034526698 <= ABS(fVar20 + -0.5))
       ) {
      iVar3 = *(int *)(lVar7 + 0x18);
      (**(code **)(lVar10 + 0x68))(lVar12,*_DAT_1e017dd58,uVar5);
      puVar8 = &DAT_1eda3a8e0;
      FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
      uVar6 = param_2 + iVar3;
      func_0x0001980ff320(uVar6,lVar12,uVar5,puVar8);
      (**(code **)(lVar10 + 8))(lVar12,uVar5);
      fVar15 = (float)((ulong)<blurFill.lightenOpacity> >> 0x20);
      fVar13 = (float)<blurFill.lightenOpacity>;
      if (fVar13 <= 0.0) {
        uVar16 = {d 0.00273437};
        if (fVar15 <= 0.0) {
          uVar16 = 0;
        }
      }
      else {
        uVar16 = {f 0.9, 0};
        if (0.0 < fVar15) {
          uVar16 = 0.00273437;
        }
      }
      if (0.5 <= fVar20) {
        dVar18 = (double)fVar20 + -0.5 + (double)fVar20 + -0.5;
        if (dVar18 < 0.0) {
          dVar18 = 0.0;
        }
        dVar14 = 1.0;
        if (dVar18 <= 1.0) {
          dVar14 = dVar18;
        }
        fVar20 = (float)(1.0 - dVar14);
        fVar19 = (float)dVar14;
        <blurFill.normalOpacity> = <blurFill.normalOpacity> * fVar20 + fVar19;
        <blurFill.lightenOpacity> =
             CONCAT44((float)((ulong)uVar16 >> 0x20) * fVar19 + fVar15 * fVar20,
                      (float)uVar16 * fVar19 + fVar13 * fVar20);
        if (<faceEffect.ycc.normalFill?nil> != '\x01') {
          uVar21 = <faceEffect.ycc.normalFill.a>;
          if ((uVar6 & 1) == 0) {
            (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e01830d0,lVar4);
            uVar22 = 1f;
          }
          else {
            uVar22 = <faceEffect.ycc.black>;
            (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e01830d0,lVar4);
          }
          uVar25 = 0.5f;
          uVar23 = uVar22;
          uVar24 = uVar22;
          func_0x0001981218c0(lVar11);
          *(undefined4 *)(lVar12 + -0x10) = uVar21;
          FUN_195f7f598();
          <faceEffect.ycc.normalFill.b> =
               CONCAT17((char)((uint)uVar25 >> 0x18),
                        CONCAT16((char)((uint)uVar25 >> 0x10),
                                 CONCAT15((char)((uint)uVar25 >> 8),CONCAT14((char)uVar25,uVar23))))
          ;
          <faceEffect.ycc.normalFill.r> =
               CONCAT17((char)((uint)uVar24 >> 0x18),
                        CONCAT16((char)((uint)uVar24 >> 0x10),
                                 CONCAT15((char)((uint)uVar24 >> 8),CONCAT14((char)uVar24,uVar22))))
          ;
          <faceEffect.ycc.normalFill?nil> = 0;
        }
      }
      else {
        uVar16 = NEON_fmov(0.75f,4);
        dVar18 = (double)fVar20 + (double)fVar20;
        if (dVar18 < 0.0) {
          dVar18 = 0.0;
        }
        dVar14 = 1.0;
        if (dVar18 <= 1.0) {
          dVar14 = dVar18;
        }
        fVar20 = (float)(1.0 - dVar14);
        local_d0[2] = (ulong)(uint)fVar20;
        fVar19 = (float)dVar14;
        local_d0[0] = (ulong)(uint)fVar19;
        <blurFill.normalOpacity> = fVar20 * 0.0 + <blurFill.normalOpacity> * fVar19;
        local_d0[1] = 0;
        uStack_b8 = 0;
        <blurFill.lightenOpacity> =
             CONCAT44(fVar15 * fVar19 + fVar15 * (float)((ulong)uVar16 >> 0x20) * fVar20,
                      fVar13 * fVar19 + fVar13 * (float)uVar16 * fVar20);
        if (<faceEffect.ycc.normalFill?nil> != '\x01') {
          uVar21 = <faceEffect.ycc.normalFill.r>;
          uVar22 = <faceEffect.ycc.normalFill.g>;
          uVar23 = <faceEffect.ycc.normalFill.b>;
          uVar24 = <faceEffect.ycc.normalFill.a>;
          if ((uVar6 & 1) == 0) {
            (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e01830d0,lVar4);
            uVar25 = 1f;
          }
          else {
            uVar25 = <faceEffect.ycc.black>;
            (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e01830d0,lVar4);
          }
          uVar17 = 0;
          func_0x0001981218c0(uVar25,uVar25,uVar25,lVar11);
          *(undefined4 *)(lVar12 + -0x10) = uVar17;
          FUN_195f7f598();
          <faceEffect.ycc.normalFill.b> =
               CONCAT17((char)((uint)uVar24 >> 0x18),
                        CONCAT16((char)((uint)uVar24 >> 0x10),
                                 CONCAT15((char)((uint)uVar24 >> 8),CONCAT14((char)uVar24,uVar23))))
          ;
          <faceEffect.ycc.normalFill.r> =
               CONCAT17((char)((uint)uVar22 >> 0x18),
                        CONCAT16((char)((uint)uVar22 >> 0x10),
                                 CONCAT15((char)((uint)uVar22 >> 8),CONCAT14((char)uVar22,uVar21))))
          ;
          <faceEffect.ycc.normalFill?nil> = 0;
        }
        if ((uVar6 & 1) != 0) {
          pdVar2 = (double *)(param_2 + *(int *)(lVar7 + 0x38));
          if (*(char *)((long)pdVar2 + 0x19) == '\x01') {
            dVar14 = 48.0;
          }
          else {
            dVar18 = 48.0;
            if (*(char *)(pdVar2 + 1) != '\x01') {
              dVar18 = *pdVar2;
            }
            dVar14 = pdVar2[2];
            if (*(char *)(pdVar2 + 3) == '\x01') {
              dVar14 = dVar18;
            }
          }
          uStack_a8 = {d 1.06812e-05};
          local_b0 = {f 64, 104};
          local_a0 = 0;
          local_9c = 1;
          local_98 = 0;
          local_94 = 1;
          fVar20 = (float)dVar14;
          FUN_195ed73f8();
          fVar20 = fVar20 * (float)local_d0[2] + <faceEffect.maxLuminance> * (float)local_d0[0];
          <faceEffect.maxLuminance> = fVar20;
          <faceEffect.maxLuminanceSDR> = fVar20;
        }
      }
    }
  }
  return;
}


//######## RegularBase.anon.Base (spec) 0x195f1e860
// === 195f20248 spec

/* WARNING: Removing unreachable block (ram,0x000195f2039c) */
/* WARNING: Removing unreachable block (ram,0x000195f20324) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f20248(undefined8 param_1,double *param_2)
{
  undefined1 auStack_1fe0 [4];
  undefined1 auStack_1d90 [1792];
  undefined1 auStack_1680 [282];
  undefined1 auStack_5c0 [288];
  (*_DAT_1e2125200)();
  puVar30 = &DAT_1eda3a940;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar30 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  lVar9 = 0;
  local_1dc0 = auStack_1fe0 + -extraout_x8;
  func_0x0001981217d0();
  lVar15 = *(long *)(lVar9 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar15 + 0x40));
  lVar26 = (long)(auStack_1fe0 + -extraout_x8) - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar10 = 0;
  func_0x000198120110();
  lVar16 = *(long *)(lVar10 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar16 + 0x40));
  lVar23 = lVar26 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  local_1ef0 = param_1;
  FUN_195ee8970(param_1);
  lVar11 = 0;
  FUN_195f3c68c();
  iVar4 = *(int *)(lVar11 + 0x18);
  local_1eb0 = lVar11;
  (**(code **)(lVar16 + 0x68))(lVar23,*_DAT_1e017dd58,lVar10);
  puVar12 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar13 = (long)param_2 + (long)iVar4;
  func_0x0001980ff320(uVar13,lVar23,lVar10,puVar12);
  (**(code **)(lVar16 + 8))(lVar23,lVar10);
  uVar14 = 0;
  FUN_195ed0900();
  uVar24 = *(ulong *)((long)param_2 + (long)*(int *)(uVar14 + 0x14));
  local_1e48 = uVar14;
  local_1da0 = param_2;
  FUN_195ed53f0();
  local_1e7c = (uint)uVar13;
  local_1f04 = (uint)uVar14;
  if ((uVar13 & 1) == 0) {
    if ((uVar14 & 1) == 0) {
      uVar31 = *_DAT_1e01830d0;
      pcVar22 = *(code **)(lVar15 + 0x68);
      (*pcVar22)(lVar26,uVar31,lVar9);
      local_1ee4 = 0.4f;
      if ((uVar24 & 8) != 0) {
        local_1ee4 = 0.85f;
      }
      uVar37 = 1f;
      local_1f0c = 1f;
      uVar39 = 1f;
      local_1f08 = 1f;
      func_0x0001981218c0(lVar26);
      local_1f00 = CONCAT44(uVar39,uVar37);
      (*pcVar22)(lVar26,uVar31,lVar9);
      uVar33 = 0.12f;
      uVar31 = 0;
      uVar37 = 0;
      uVar39 = 0;
      func_0x0001981218c0(lVar26);
      local_1e70 = (ulong)local_1e70._4_4_ << 0x20;
      local_1e58 = CONCAT44(uVar37,uVar31);
      local_1e60 = CONCAT44(uVar33,uVar39);
      local_1db8 = 0.5f;
      local_1e50 = (f 0.5, f 0.25);
      local_1db0 = 1.03f;
      local_1dac = 0.9f;
      local_1db4 = 1.2f;
      local_1ef8 = 3.05176e-05;
      uVar36 = {d 0.7};
      goto LAB_195f207f8;
    }
    uVar31 = *_DAT_1e01830d0;
    pcVar22 = *(code **)(lVar15 + 0x68);
    (*pcVar22)(lVar26,uVar31,lVar9);
    local_1ee4 = 0.2f;
    uVar37 = 1f;
    local_1f0c = 1f;
    uVar39 = 1f;
    local_1f08 = 1f;
    func_0x0001981218c0(lVar26);
    local_1ef8 = 3.05176e-05;
    local_1e50 = 3.43323e-06;
    local_1da8 = 0;
    local_1db0 = 1.03f;
    local_1db8 = 0.4f;
    local_1da4 = 0.9f;
    local_1dac = 0.9f;
    local_1db4 = 1.2f;
    local_1ee8 = 1.2f;
    local_1d94 = 1.0;
LAB_195f20c24:
    local_1f00 = CONCAT44(uVar39,uVar37);
    (*pcVar22)(lVar26,uVar31,lVar9);
    uVar33 = 0.3f;
    uVar31 = 0;
    uVar37 = 0;
    uVar39 = 0;
    func_0x0001981218c0(lVar26);
    puVar7 = local_1dc0;
    local_1e60 = CONCAT44(uVar33,uVar39);
    local_1e58 = CONCAT44(uVar37,uVar31);
    uStack_2c8 = {d 160};
    local_2d0 = {d 64};
    uStack_1e98 = {d 24};
    local_1ea0 = {d 4};
    uStack_2b8 = {d 24};
    local_2c0 = {d 4};
    uStack_2a8 = 1;
    local_2b0 = 0;
    local_2a0 = 0;
    uStack_29e = 0;
    local_298 = 0x201;
    uStack_338 = {d 3.05176e-05};
    local_340 = {d 0.0078125};
    local_330 = 3.05176e-05;
    uStack_328 = CONCAT31(uStack_328._1_3_,1);
    local_320 = local_320 & 0xffffff00;
    uStack_324 = -1f;
    uStack_31c = 0;
    uStack_318 = uStack_318 & 0xffffff00;
    uStack_314 = 0;
    uStack_1e88 = {d 160};
    local_1e90 = {d 64};
    uStack_300 = {d 160};
    local_308 = {d 64};
    local_2f8 = {d 512};
    uStack_2e8 = {d 0};
    local_2f0 = {f 0, 1.4013e-45};
    local_2e0 = 0x201;
    local_2dc = 0;
    uStack_2db = 0;
    uStack_2da = 0x40a0;
    local_2d8 = 0;
    local_310 = 0;
    (**(code **)(lVar16 + 0x38))(local_1dc0,1,1,lVar10);
    pdVar29 = local_1da0;
    FUN_195eef0b0(&local_288,local_1da0,puVar7);
    FUN_195dabb50(puVar7,&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
    local_f70 = 0;
    uVar19 = 0;
    local_777 = 0;
    dVar32 = *pdVar29;
    local_1de8 = -0.3;
    local_1e28 = dVar32 * -1.6;
    if (0.5 <= dVar32) {
      local_1de8 = -0.25;
      local_1e28 = -dVar32;
    }
    local_1dc0 = (undefined1 *)local_108;
    local_1dc8 = local_110;
    uStack_378 = uStack_148;
    local_380 = local_150;
    uStack_368 = uStack_138;
    local_370 = uStack_140;
    local_360 = local_130;
    uStack_34e = uStack_11e;
    local_1dd0 = local_158;
    local_1dd8 = local_160;
    uStack_42e = uStack_1fe;
    uStack_438 = uStack_208;
    uStack_440 = local_210;
    uStack_448 = uStack_218;
    local_450 = local_220;
    uStack_458 = uStack_228;
    local_460 = local_230;
    uStack_498 = uStack_268;
    local_4a0 = local_270;
    uStack_488 = uStack_258;
    local_490 = local_260;
    uStack_478 = uStack_248;
    local_480 = local_250;
    uStack_46e = uStack_23e;
    uStack_476 = uStack_246;
    uStack_470 = uStack_240;
    local_1f10 = local_278;
    local_1f20 = local_288;
    uStack_1f18 = local_280;
    uStack_3e0 = uStack_1b4;
    uStack_3e8 = uStack_1bc;
    uStack_3e3 = uStack_1b7;
    local_3f0 = local_1c4;
    uStack_3f8 = uStack_1cc;
    local_400 = local_1d4;
    uStack_418 = uStack_1ec;
    local_420 = local_1f4;
    uStack_408 = uStack_1dc;
    local_410 = local_1e4;
    uStack_398 = uStack_174;
    local_3a0 = local_17c;
    uStack_3a8 = uStack_184;
    local_3b0 = local_18c;
    uStack_3c8 = uStack_1a4;
    local_3d0 = local_1ac;
    uStack_3b8 = uStack_194;
    local_3c0 = local_19c;
    local_1e20 = -local_1e28;
    uVar36 = NEON_fmov(1f,4);
    local_1ddc = 8f;
    uVar28 = 64;
    uVar38 = 0;
    uVar27 = 2;
    local_1e40 = -0.5;
    local_1e38 = 0.25;
    local_1f28 = 16;
    local_1e10 = 8;
    local_1e08 = {f 0.15, 16};
    local_1e00 = 4;
    uStack_1df8 = 5;
    local_1df0 = 1;
    local_1e14 = 0.5f;
    local_1de0 = 0.65f;
    local_1e30 = 0.4;
    uVar17 = 1.309;
    uVar18 = 0.2;
    local_1ed0 = 0.6f;
    local_1e78 = 0.35;
    local_1e18 = 0.06f;
    uVar40 = 0;
    uVar35 = 0;
    uVar34 = 0;
    uVar25 = 1;
    uVar20 = 1;
    uVar31 = 0;
  }
  else {
    if ((uVar14 & 1) != 0) {
      uVar31 = *_DAT_1e01830d0;
      pcVar22 = *(code **)(lVar15 + 0x68);
      (*pcVar22)(lVar26,uVar31,lVar9);
      uVar37 = 0;
      local_1da4 = 0;
      uVar39 = 0;
      local_1f08 = 0;
      local_1ee4 = 0;
      func_0x0001981218c0(lVar26);
      pdVar29 = (double *)((long)local_1da0 + (long)*(int *)(local_1eb0 + 0x38));
      if (*(char *)((long)pdVar29 + 0x19) == '\x01') {
        dVar32 = 48.0;
      }
      else if (*(char *)(pdVar29 + 3) == '\x01') {
        dVar32 = 48.0;
        if (*(char *)(pdVar29 + 1) != '\x01') {
          dVar32 = *pdVar29;
        }
      }
      else {
        dVar32 = pdVar29[2];
      }
      uStack_c8 = {d 1.14441e-06};
      local_d0 = {f 64, 104};
      local_bc = 1;
      local_c0 = 0;
      local_b8 = 0;
      local_b4 = 1;
      local_1d94 = (float)dVar32;
      FUN_195ed73f8();
      local_1db0 = 1.125f;
      local_1ef8 = 0.000878906;
      local_1db4 = 1f;
      local_1f0c = 0.5f;
      local_1dac = 0.125f;
      local_1e50 = 9.76563e-05;
      local_1ee8 = 1.3f;
      local_1da8 = 0.9f;
      local_1db8 = 0.125f;
      goto LAB_195f20c24;
    }
    (**(code **)(lVar15 + 0x68))(lVar26,*_DAT_1e01830d0,lVar9);
    local_1ee4 = 0.4f;
    if ((uVar24 & 8) != 0) {
      local_1ee4 = 0.78f;
    }
    uVar31 = 0;
    local_1dac = 0;
    uVar37 = 0;
    local_1f08 = 0;
    func_0x0001981218c0(lVar26);
    local_1e60 = 0;
    local_1e58 = 0;
    local_1f00 = CONCAT44(uVar37,uVar31);
    local_1e70 = CONCAT44(local_1e70._4_4_,1);
    local_1e50 = (f 0.4, f 0.25);
    local_1f0c = 0.5f;
    local_1db4 = 1f;
    local_1db0 = 0.6f;
    local_1db8 = 0.2f;
    local_1ef8 = 0.000878906;
    uVar36 = {d 0.0078125};
LAB_195f207f8:
    local_f90 = 24;
    local_f57 = 0;
    bVar8 = (uVar24 & 0x40) != 0;
    uVar34 = 40;
    if (bVar8) {
      uVar34 = 9;
    }
    uVar35 = 0.625;
    if (bVar8) {
      uVar35 = 0.3125;
    }
    FUN_195da95b4(&local_f90,&local_1690,&DAT_1eda3b6c0,0x195fa8230);
    uVar27 = local_f57;
    puVar7 = local_1dc0;
    uStack_1e98 = uStack_f78;
    local_1ea0 = local_f80;
    uStack_1e88 = puStack_f88;
    local_1e90 = local_f90;
    uStack_2c8 = puStack_f88;
    local_2d0 = local_f90;
    uStack_2b8 = uStack_f78;
    local_2c0 = local_f80;
    uStack_2a8 = uStack_f68;
    local_2b0 = local_f70;
    uStack_29e = uStack_f5e;
    local_298 = (undefined2)(CONCAT17(local_f57,CONCAT16(local_f58,uStack_f5e)) >> 0x30);
    local_2a0 = local_f60;
    local_290 = CONCAT13((char)uStack_f64,CONCAT21(uStack_f66,uStack_f67));
    uStack_28c = (undefined3)((uint)uStack_f64 >> 8);
    uVar19 = CONCAT62(uStack_f5e,local_f60);
    uStack_338 = {d 3.05176e-05};
    local_340 = {d 0.0078125};
    local_330 = 3.05176e-05;
    uStack_328 = CONCAT31(uStack_328._1_3_,1);
    local_320 = local_320 & 0xffffff00;
    uStack_324 = -1f;
    uStack_31c = 0;
    uStack_318 = uStack_318 & 0xffffff00;
    uStack_314 = 0;
    uStack_300 = {d 160};
    local_308 = {d 48};
    local_2f8 = {d 512};
    uStack_2e8 = {d 0};
    local_2f0 = {f 0, 1.4013e-45};
    local_2e0 = 0x201;
    local_2dc = 0;
    uStack_2db = 0;
    uStack_2da = 0;
    local_2d8 = 1;
    local_310 = 0;
    (**(code **)(lVar16 + 0x38))(local_1dc0,1,1,lVar10);
    pdVar29 = local_1da0;
    FUN_195eef0b0(&local_288,local_1da0,puVar7);
    FUN_195dabb50(puVar7,&DAT_1eda3a940,&{f 2.85714e-40, 9.80909e-45});
    local_1de0 = local_fc;
    local_1ddc = local_100;
    local_1dc0 = (undefined1 *)local_108;
    local_1dc8 = local_110;
    uStack_378 = uStack_148;
    local_380 = local_150;
    uStack_368 = uStack_138;
    local_370 = uStack_140;
    local_360 = local_130;
    uStack_34e = uStack_11e;
    local_1dd0 = local_158;
    local_1dd8 = local_160;
    uStack_398 = uStack_174;
    local_3a0 = local_17c;
    uStack_3a8 = uStack_184;
    local_3b0 = local_18c;
    uStack_3c8 = uStack_1a4;
    local_3d0 = local_1ac;
    uStack_3b8 = uStack_194;
    local_3c0 = local_19c;
    uStack_3e0 = uStack_1b4;
    uStack_3e8 = uStack_1bc;
    uStack_3e3 = uStack_1b7;
    local_3f0 = local_1c4;
    uStack_3f8 = uStack_1cc;
    local_400 = local_1d4;
    uVar28 = 48;
    uStack_408 = uStack_1dc;
    local_410 = local_1e4;
    uStack_418 = uStack_1ec;
    local_420 = local_1f4;
    uVar40 = 0.4;
    local_1e40 = -0.8;
    local_1e38 = 0.2;
    local_1f28 = 0xfff0000000000000;
    local_1ed0 = 0.3f;
    local_1e78 = 0.7;
    local_777 = 2;
    local_1ee8 = 1f;
    local_1e08 = (ulong)local_f8;
    uStack_42e = uStack_1fe;
    uVar18 = 0.125;
    local_1df0 = 0;
    uStack_438 = uStack_208;
    uStack_440 = local_210;
    local_1e14 = 0;
    uVar38 = 48;
    local_1da8 = 0;
    local_1da4 = 0;
    local_1e18 = 0;
    uStack_448 = uStack_218;
    local_450 = local_220;
    uStack_458 = uStack_228;
    local_460 = local_230;
    local_1e00 = 0;
    uStack_1df8 = 0;
    uStack_46e = uStack_23e;
    uStack_470 = uStack_240;
    local_1e10 = 0;
    local_1d94 = 1.0;
    uStack_478 = uStack_248;
    uStack_476 = uStack_246;
    local_480 = local_250;
    local_1e20 = 0.0;
    uVar17 = 0;
    local_1e30 = 0;
    local_1f10 = local_278;
    uStack_488 = uStack_258;
    local_490 = local_260;
    local_1f20 = local_288;
    uStack_1f18 = local_280;
    uStack_498 = uStack_268;
    local_4a0 = local_270;
    local_1e28 = 0.0;
    local_1de8 = 0;
    uVar25 = uStack_f68;
    uVar20 = local_f58;
    uVar31 = (undefined4)local_1e70;
  }
  local_818 = uVar19;
  if (DAT_1eda3b6c8 != -1) {
    local_1e70 = CONCAT44(local_1e70._4_4_,uVar31);
    local_1eb8 = uVar19;
    local_1ea8 = local_f70;
    func_0x000198104ff0(&DAT_1eda3b6c8,FUN_195eeb6ec);
    local_f70 = local_1ea8;
    local_818 = local_1eb8;
    uVar31 = (undefined4)local_1e70;
  }
  uVar13 = local_1e48;
  uStack_5f8 = uRam00000001eda465a0;
  local_600 = _DAT_1eda46598;
  uStack_5e8 = uRam00000001eda465b0;
  local_5f0 = _DAT_1eda465a8;
  local_5e0 = DAT_1eda465b8;
  uStack_608 = uRam00000001eda46590;
  local_610 = _DAT_1eda46588;
  uStack_618 = uRam00000001eda46580;
  local_620 = _DAT_1eda46578;
  local_1ea8 = CONCAT44(local_1ea8._4_4_,
                        (uint)*(byte *)((long)pdVar29 + (long)*(int *)(local_1e48 + 0x2c)));
  local_870 = 160;
  local_868 = local_1e50;
  uStack_1e68 = {d 0};
  local_1e70 = {f 0, 1.4013e-45};
  uStack_858 = {d 0};
  local_860 = {f 0, 1.4013e-45};
  local_850 = 0x201;
  uStack_830 = uStack_1e98;
  local_838 = local_1ea0;
  uStack_840 = uStack_1e88;
  local_848 = local_1e90;
  local_81f = local_290;
  uStack_81b = uStack_28c;
  uStack_800 = {d 8};
  local_808 = {d 0};
  local_7f8 = 0;
  local_7ec = local_1e58;
  local_7e4 = local_1e60;
  local_7dc = (undefined1)uVar31;
  local_7d0 = 0;
  local_7d8 = 0;
  local_7c8 = 1;
  local_7bc = 0;
  local_7c4 = 0;
  local_7b4 = 1;
  uStack_7a0 = {d 0};
  local_7a8 = {d 160};
  local_798 = 1;
  local_790 = 0;
  local_788 = 1;
  local_780 = 0;
  local_778 = 1;
  uStack_666 = uStack_46e;
  uStack_668 = uStack_470;
  uStack_670 = uStack_478;
  local_66e = (undefined2)uStack_476;
  uStack_66c = (undefined4)((uint6)uStack_476 >> 0x10);
  uStack_678 = (undefined4)local_480;
  uStack_674 = (undefined4)((ulong)local_480 >> 0x20);
  uStack_680 = (undefined4)uStack_488;
  uStack_67c = (undefined4)((ulong)uStack_488 >> 0x20);
  local_688 = (undefined4)local_490;
  uStack_684 = (undefined4)((ulong)local_490 >> 0x20);
  uStack_690 = (undefined4)uStack_498;
  uStack_68c = (undefined4)((ulong)uStack_498 >> 0x20);
  local_698 = (undefined4)local_4a0;
  uStack_694 = (undefined4)((ulong)local_4a0 >> 0x20);
  uStack_6a4 = uStack_42e;
  uStack_6ae = uStack_438;
  uStack_6b6 = (undefined2)uStack_440;
  uStack_6b4 = (undefined6)((ulong)uStack_440 >> 0x10);
  uStack_6be = (undefined2)uStack_448;
  uStack_6bc = (undefined6)((ulong)uStack_448 >> 0x10);
  local_6c6 = (undefined2)local_450;
  uStack_6c4 = (undefined6)((ulong)local_450 >> 0x10);
  uStack_6ce = (undefined2)uStack_458;
  uStack_6cc = (undefined6)((ulong)uStack_458 >> 0x10);
  local_6d6 = (undefined2)local_460;
  uStack_6d4 = (undefined6)((ulong)local_460 >> 0x10);
  uStack_71a = (undefined6)uStack_418;
  uStack_714 = (undefined2)((ulong)uStack_418 >> 0x30);
  local_722 = (undefined6)local_420;
  uStack_71c = (undefined2)((ulong)local_420 >> 0x30);
  uStack_6e2 = uStack_3e0;
  uStack_6ea = uStack_3e8;
  uStack_6e5 = (undefined1)uStack_3e3;
  uStack_6e4 = (undefined2)((uint3)uStack_3e3 >> 8);
  local_6f2 = (undefined6)local_3f0;
  uStack_6ec = (undefined2)((ulong)local_3f0 >> 0x30);
  uStack_6fa = (undefined6)uStack_3f8;
  uStack_6f4 = (undefined2)((ulong)uStack_3f8 >> 0x30);
  local_702 = (undefined6)local_400;
  uStack_6fc = (undefined2)((ulong)local_400 >> 0x30);
  uStack_70a = (undefined6)uStack_408;
  uStack_704 = (undefined2)((ulong)uStack_408 >> 0x30);
  local_712 = (undefined6)local_410;
  uStack_70c = (undefined2)((ulong)local_410 >> 0x30);
  uStack_765 = (undefined5)uStack_3c8;
  uStack_760 = (undefined3)((ulong)uStack_3c8 >> 0x28);
  local_76d = (undefined5)local_3d0;
  uStack_768 = (undefined3)((ulong)local_3d0 >> 0x28);
  uStack_735 = uStack_398;
  local_73d = (undefined5)local_3a0;
  uStack_738 = (undefined3)((ulong)local_3a0 >> 0x28);
  uStack_745 = (undefined5)uStack_3a8;
  uStack_740 = (undefined3)((ulong)uStack_3a8 >> 0x28);
  local_74d = (undefined5)local_3b0;
  uStack_748 = (undefined3)((ulong)local_3b0 >> 0x28);
  uStack_755 = (undefined5)uStack_3b8;
  uStack_750 = (undefined3)((ulong)uStack_3b8 >> 0x28);
  local_75d = (undefined5)local_3c0;
  uStack_758 = (undefined3)((ulong)local_3c0 >> 0x28);
  local_890 = uVar40;
  local_888 = uVar35;
  local_880 = uVar34;
  local_878 = uVar28;
  local_828 = local_f70;
  local_820 = uVar25;
  local_810 = uVar20;
  local_80f = uVar27;
  local_7f4 = uVar36;
  local_7b0 = uVar38;
  func_0x000198104610(auStack_5c0,&local_890,0x11a);
  uVar36 = uStack_300;
  uVar6 = local_1e7c;
  uVar1 = local_1f04;
  uStack_650 = (undefined2)uStack_338;
  uStack_64e = (undefined6)((ulong)uStack_338 >> 0x10);
  local_658 = (undefined2)local_340;
  uStack_656 = (undefined6)((ulong)local_340 >> 0x10);
  uStack_640 = (undefined2)uStack_328;
  uStack_63e = (undefined6)(CONCAT44(uStack_324,uStack_328) >> 0x10);
  local_648 = (undefined2)local_330;
  uStack_646 = (undefined6)((ulong)local_330 >> 0x10);
  uStack_630 = (undefined2)uStack_318;
  uStack_62e = (undefined6)(CONCAT44(uStack_314,uStack_318) >> 0x10);
  local_638 = (undefined2)local_320;
  uStack_636 = (undefined6)(CONCAT44(uStack_31c,local_320) >> 0x10);
  local_628 = CONCAT71(uStack_30f,local_310);
  local_5d0 = CONCAT13(uStack_2db,CONCAT12(local_2dc,uStack_2de));
  uStack_5cc = uStack_2da;
  uStack_5ca = local_2d8;
  local_1f2c = (uint)local_2e0._1_1_;
  if ((local_1f04 & 1) == 0) {
    cVar3 = *(char *)((long)pdVar29 + (long)*(int *)(uVar13 + 0x28));
    if (cVar3 != '\0') {
      uVar21 = (uint)local_1ea8;
      if (cVar3 == '\x01') {
        local_1ee8 = 1.3f;
        if ((local_1e7c & 1) == 0) {
          local_1ee8 = 1.1f;
        }
        puVar12 = &local_890;
        FUN_195ef576c(puVar12,&local_f90);
        puVar30 = (undefined *)0x0;
        uVar36 = 0;
        local_1e50 = 0;
        local_1e48 = 0;
        local_1e58 = 0;
        local_1e60 = local_1e60 & 0xffffffff00000000;
        local_1f2c = 0;
        local_1ee4 = 0;
        local_1ed8 = 0.666667f;
        lVar9 = 0.5f;
      }
      else {
        local_1ee8 = 1.3f;
        if ((local_1e7c & 1) == 0) {
          local_1ee8 = 1.1f;
        }
        puVar12 = &local_890;
        FUN_195ef576c(puVar12,&local_f90);
        puVar30 = (undefined *)0x0;
        local_1ed8 = 0;
        uVar36 = 0;
        local_1e50 = 0;
        local_1e48 = 0;
        local_1e58 = 0;
        local_1e60 = local_1e60 & 0xffffffff00000000;
        local_1f2c = 0;
        local_1ee4 = 0;
        lVar9 = 0.25f;
      }
      goto LAB_195f214e0;
    }
    local_1e60 = CONCAT44(local_1e60._4_4_,(uint)(byte)local_2e0);
    local_1ed8 = local_308;
    local_1e58 = uStack_2e8;
    local_1e50 = local_2f0;
    local_1e48 = local_2f8;
    FUN_195f23434(&local_340,&local_f90);
    puVar12 = &local_890;
    FUN_195ef576c(puVar12,&local_f90);
    puVar30 = (undefined *)0x0;
    lVar9 = 0.25f;
  }
  else {
    local_1e60 = CONCAT44(local_1e60._4_4_,(uint)(byte)local_2e0);
    local_1e50 = local_2f0;
    local_1e48 = local_2f8;
    local_1e58 = uStack_2e8;
    local_1ed8 = local_308;
    if ((*(ulong *)((long)pdVar29 + (long)*(int *)(local_1eb0 + 0x78)) & 0xfffffffffffffffd) == 0) {
      local_1ee0 = uStack_300;
      if (DAT_1eda3a158 != -1) {
        func_0x000198104ff0(&DAT_1eda3a158,FUN_195f38fd0);
      }
      lVar9 = DAT_1eda45918;
      if (*(long *)(DAT_1eda45918 + 0x10) == 0) {
        bVar2 = *(byte *)(DAT_1eda45918 + 0xd9);
        FUN_195f23434(&local_340,&local_f90);
        puVar12 = &local_890;
        FUN_195ef576c(puVar12,&local_f90);
      }
      else {
        puVar30 = &{f 2.25055e+13, 0};
        func_0x000198104dd0(&{f 2.25055e+13, 0});
        local_1690 = lVar9;
        puVar12 = &DAT_1eda3b100;
        FUN_195eab224(DAT_1eda39d38,&DAT_1eda3b100,FUN_195f38ce0,
                      &TargetProtocolConformanceDescriptor_195fb0408);
        func_0x0001980fe060(&local_1690,puVar30,puVar12);
        FUN_195f23434(&local_340,&local_f90);
        FUN_195ef576c(&local_890,&local_f90);
        func_0x000198105020(puVar30);
        func_0x0001981048a0(lVar9 + 0x20);
        bVar2 = *(byte *)(lVar9 + 0x71);
        puVar12 = (undefined8 *)(lVar9 + 0x20);
        func_0x0001981048b0();
      }
      uVar36 = local_1ee0;
      if ((bVar2 == 2) || ((bVar2 & 1) != 0)) {
        puVar30 = &UNK_1e3f14ac0;
        if (0.33333333333333354 < *pdVar29) {
          puVar30 = &UNK_1e3f14a90;
        }
        lVar9 = 2;
      }
      else {
        puVar30 = (undefined *)0x0;
        lVar9 = 0.25f;
      }
    }
    else {
      FUN_195f23434(&local_340,&local_f90);
      puVar12 = &local_890;
      FUN_195ef576c(puVar12,&local_f90);
      puVar30 = (undefined *)0x0;
      local_1da4 = 0;
      lVar9 = 0.25f;
      local_1da8 = 0;
    }
  }
  uVar21 = (uint)local_1ea8;
LAB_195f214e0:
  pdVar29 = local_1da0;
  FUN_195ed53f0();
  if (((ulong)puVar12 & 1) == 0) {
    FUN_195eda2a0(&local_f0,pdVar29);
    local_1da0 = (double *)CONCAT44(local_1da0._4_4_,local_f0);
    local_1e7c = uStack_ec;
    local_1e90 = CONCAT44(local_1e90._4_4_,local_e8);
    local_1ea0 = local_e0;
  }
  else {
    local_1da0 = (double *)CONCAT44(local_1da0._4_4_,1.2f);
    local_1e7c = 0;
    local_1e90 = CONCAT44(local_1e90._4_4_,1f);
    uStack_d8 = 0;
    local_1ea0 = 0;
  }
  local_1ea8 = uStack_d8;
  FUN_195f23488(&local_890);
  FUN_195f234d4(&local_340);
  bVar8 = 1 < uVar21;
  local_1ebc = 0;
  uVar31 = 0;
  if (bVar8) {
    uVar31 = 1f;
  }
  local_1eb0 = CONCAT44(local_1eb0._4_4_,uVar31);
  local_1eb8 = 0;
  if (bVar8) {
    local_1ebc = -5f;
    local_1eb8 = 1.5708;
  }
  local_1ecc = 0;
  local_1ec0 = 0;
  if (bVar8) {
    local_1ec0 = 6.6f;
  }
  local_1ec8 = local_1ecc;
  local_1ec4 = local_1ecc;
  if (bVar8) {
    local_1ec8 = -16f;
    local_1ec4 = -3.3f;
  }
  if (bVar8) {
    local_1ecc = 16f;
  }
  FUN_195dabb50(&local_2d0,&DAT_1eda3b6c0,0x195fa8230);
  local_13a4 = local_1d94;
  bVar8 = ((uVar6 | uVar1 ^ 0xffffffff) & 1) == 0;
  local_13a0 = local_1d94;
  if (bVar8) {
    local_13a0 = 0.94;
  }
  uVar34 = uVar17;
  if (bVar8) {
    uVar34 = 1.67552;
  }
  if (bVar8) {
    uVar17 = 1.85005;
  }
  uVar1 = (uVar6 ^ 0xffffffff) & 1;
  local_1fdc = local_13a0;
  local_1f40 = uVar34;
  uStack_1f38 = uVar17;
  local_1f04 = uVar1;
  local_1690 = lVar9;
  local_1688 = puVar30;
  func_0x000198104610(auStack_1680,auStack_5c0,0x11a);
  uVar5 = local_1ee4;
  uVar33 = local_1ee8;
  uVar38 = local_1ef8;
  uVar28 = local_1f00;
  uVar39 = local_1f08;
  uVar37 = local_1f0c;
  uVar31 = local_1f10;
  uVar40 = uStack_1f18;
  uVar19 = local_1f20;
  uVar35 = local_1f28;
  uStack_155e = CONCAT26(uStack_650,uStack_656);
  local_1566 = CONCAT26(local_658,uStack_65e);
  uStack_154e = CONCAT26(uStack_640,uStack_646);
  uStack_1556 = CONCAT26(local_648,uStack_64e);
  local_1546 = CONCAT26(local_638,uStack_63e);
  uStack_153e = uStack_636;
  uStack_1530 = local_628;
  uStack_1538 = uStack_630;
  uStack_1536 = uStack_62e;
  local_1528 = local_1ed8;
  local_1518 = local_1e48;
  local_1510 = local_1e50;
  local_1508 = local_1e58;
  local_1500 = (undefined1)local_1e60;
  uVar27 = (undefined1)local_1f2c;
  uStack_14f8 = CONCAT11(uStack_5c9,uStack_5ca);
  local_14fe = CONCAT24(uStack_5cc,local_5d0);
  uStack_1fb8 = {d 0};
  local_1fc0 = {d 0.25};
  uStack_14e8 = {d 0};
  local_14f0 = {d 0.25};
  local_14e0 = 20;
  local_14d8 = local_1e40;
  uStack_1fc8 = {f 0, nan};
  local_1fd0 = {d -60};
  uStack_14c8 = {f 0, nan};
  local_14d0 = {d -60};
  local_14b8 = local_1f28;
  local_14b0 = 0x7ff0000000000000;
  local_14a8 = local_1e38;
  local_14a0 = local_1f28;
  local_1498 = 0x7ff0000000000000;
  local_1490 = local_1ed0;
  local_1488 = 64;
  local_1480 = 160;
  local_1478 = local_1ef8;
  uStack_1468 = uStack_1e68;
  local_1470 = local_1e70;
  local_1460 = 0x201;
  local_1458 = 0.35;
  local_1450 = 0.35;
  local_1448 = local_1e78;
  local_1440 = 160;
  local_1438 = local_1dac;
  local_1434 = local_1f0c;
  local_1430 = local_1db4;
  uStack_1424 = 0;
  local_142c = 0;
  local_141c = 1;
  uStack_1410 = 0;
  local_1418 = 0;
  local_1408 = 1;
  uStack_13fc = 0;
  local_1404 = 0;
  local_13f4 = 1;
  local_13f3 = (undefined1)uVar1;
  local_13f0 = 1f;
  local_13ec = local_1db8;
  local_13e8 = local_1db0;
  local_13e4 = local_1ee8;
  local_13e0 = local_1f00;
  local_13d8 = local_1f08;
  local_13d4 = local_1ee4;
  local_13d0 = 0;
  uStack_13c4 = 0;
  local_13cc = 0;
  local_13bc = 1;
  uStack_13b0 = 0;
  local_13b8 = 0;
  local_13a8 = 1;
  local_1398 = local_1f20;
  local_1390 = uStack_1f18;
  local_1388 = local_1f10;
  uStack_137c = CONCAT44(uStack_690,uStack_694);
  local_1384 = CONCAT44(local_698,uStack_69c);
  uStack_136c = CONCAT44(uStack_680,uStack_684);
  uStack_1374 = CONCAT44(local_688,uStack_68c);
  uStack_135c = CONCAT24(uStack_670,uStack_674);
  local_1364 = CONCAT44(uStack_678,uStack_67c);
  uStack_134e = uStack_666;
  uStack_1356 = local_66e;
  uStack_1354 = (undefined6)(CONCAT26(uStack_668,CONCAT42(uStack_66c,local_66e)) >> 0x10);
  uStack_133e = CONCAT26(uStack_6ce,uStack_6d4);
  local_1346 = CONCAT26(local_6d6,uStack_6dc);
  uStack_132e = CONCAT26(uStack_6be,uStack_6c4);
  uStack_1336 = CONCAT26(local_6c6,uStack_6cc);
  uStack_131e = CONCAT26(uStack_6ae,uStack_6b4);
  local_1326 = CONCAT26(uStack_6b6,uStack_6bc);
  uStack_130e = uStack_6a4;
  uStack_12fe = CONCAT62(uStack_71a,uStack_71c);
  local_1306 = CONCAT62(local_722,uStack_724);
  uStack_12ee = CONCAT62(uStack_70a,uStack_70c);
  uStack_12f6 = CONCAT62(local_712,uStack_714);
  uStack_12de = CONCAT62(uStack_6fa,uStack_6fc);
  local_12e6 = CONCAT62(local_702,uStack_704);
  uStack_12ce = CONCAT52(uStack_6ea,uStack_6ec);
  uStack_12d6 = CONCAT62(local_6f2,uStack_6f4);
  uStack_12c6 = (undefined7)(CONCAT53(uStack_6e2,CONCAT21(uStack_6e4,uStack_6e5)) >> 8);
  local_12c7 = uStack_6e5;
  uStack_12b7 = CONCAT53(uStack_765,uStack_768);
  local_12bf = CONCAT53(local_76d,uStack_770);
  uStack_12a7 = CONCAT53(uStack_755,uStack_758);
  uStack_12af = CONCAT53(local_75d,uStack_760);
  uStack_1297 = CONCAT53(uStack_745,uStack_748);
  local_129f = CONCAT53(local_74d,uStack_750);
  uStack_1287 = CONCAT53(uStack_735,uStack_738);
  uStack_128f = CONCAT53(local_73d,uStack_740);
  local_1270 = local_1dd8;
  local_1268 = local_1dd0;
  uStack_122e = uStack_34e;
  uStack_1240 = local_360;
  uStack_1248 = uStack_368;
  local_1250 = local_370;
  uStack_1258 = uStack_378;
  local_1260 = local_380;
  local_1220 = local_1dc8;
  local_1218 = local_1dc0;
  local_1210 = local_1ddc;
  local_120c = local_1de0;
  local_1208 = local_1e08;
  local_1200 = local_1da4;
  local_11fc = local_1da8;
  local_11f8 = local_1e14;
  local_11f0 = local_1e10;
  local_11e8 = local_1e00;
  local_11e0 = uStack_1df8;
  local_11d8 = local_1e18;
  local_11d0 = local_1df0;
  local_11c8 = local_1e20;
  local_11b0 = local_1e30;
  local_11a8 = local_1e28;
  local_11a0 = local_1de8;
  local_1f48 = {d 0.0078125};
  local_1198 = {d 0.0078125};
  uStack_1f58 = {d 1.60617};
  local_1f60 = {d 0.0938673};
  uStack_1188 = {d 1.60617};
  local_1190 = {d 0.0938673};
  local_1180 = 0;
  local_1178 = 1;
  local_1170 = 0;
  local_1168 = 1;
  local_1157 = 1;
  uStack_1f68 = {d 16.0801};
  local_1f70 = {d 0.0275344};
  uStack_1148 = {d 16.0801};
  local_1150 = {d 0.0275344};
  local_1140 = 0;
  local_1138 = 1;
  local_1130 = 0;
  local_1128 = 1;
  local_1117 = 1;
  uStack_1f78 = {d 12.9487};
  local_1f80 = {d -0.334168};
  uStack_1108 = {d 12.9487};
  local_1110 = {d -0.334168};
  local_1100 = 0;
  local_10f8 = 1;
  local_10f0 = 0;
  local_10e8 = 1;
  local_10d7 = 1;
  uStack_1f88 = {d -0.152778};
  local_1f90 = {d 0.101389};
  uStack_10c8 = {d -0.152778};
  local_10d0 = {d 0.101389};
  uStack_1080 = uStack_618;
  local_1088 = local_620;
  uStack_1060 = uStack_5f8;
  local_1068 = local_600;
  uStack_1050 = uStack_5e8;
  uStack_1058 = local_5f0;
  uStack_1f98 = {d -0.416667};
  local_1fa0 = {d 0.194444};
  uStack_10b8 = {d -0.416667};
  local_10c0 = {d 0.194444};
  local_10a0 = 0;
  uStack_10a8 = 0;
  local_10b0 = 0;
  local_1fa8 = {d 0.0078125};
  local_1098 = -2.58082;
  local_1090 = {d 0.0078125};
  uStack_1070 = uStack_608;
  local_1078 = local_610;
  local_1048 = local_5e0;
  local_1040 = local_1ecc;
  local_103c = local_1ec8;
  local_1038 = local_1ec4;
  local_1034 = local_1ec0;
  local_1030 = local_1ebc;
  local_102c = 0;
  local_1028 = local_1eb8;
  local_1020 = 0;
  local_1018 = 0;
  local_1014 = (undefined4)local_1eb0;
  local_ff0 = 0;
  uStack_ff8 = 0;
  local_1000 = 0;
  uStack_1008 = 0;
  local_1010 = 0;
  local_fe8 = 0xff0000000000;
  uStack_fba = 0;
  uStack_fc0 = 0;
  uStack_fd8 = 0;
  local_fe0 = 0;
  uStack_fc8 = 0;
  local_fc2 = 0;
  uStack_fd0 = 0;
  local_fb0 = local_1da0._0_4_;
  local_fac = local_1e7c;
  local_fa8 = (undefined4)local_1e90;
  local_fa0 = local_1ea0;
  local_f98 = local_1ea8;
  local_1fd8 = uVar18;
  local_1ee0 = uVar36;
  local_1520 = uVar36;
  local_14ff = uVar27;
  local_14c0 = uVar18;
  local_11c0 = uVar34;
  local_11b8 = uVar17;
  func_0x000198104610(local_1ef0,&local_1690,0x700);
  local_f90 = lVar9;
  puStack_f88 = puVar30;
  func_0x000198104610(&local_f80,auStack_5c0,0x11a);
  uStack_de8 = uStack_1fb8;
  local_df0 = local_1fc0;
  local_dd8 = local_1e40;
  uStack_dc8 = uStack_1fc8;
  local_dd0 = local_1fd0;
  local_dc0 = local_1fd8;
  local_da8 = local_1e38;
  local_d90 = local_1ed0;
  uStack_d68 = uStack_1e68;
  local_d70 = local_1e70;
  local_d48 = local_1e78;
  local_d38 = local_1dac;
  local_d34 = uVar37;
  local_d30 = local_1db4;
  local_cec = local_1db8;
  local_ce8 = local_1db0;
  local_ce4 = uVar33;
  local_cd8 = uVar39;
  local_cd4 = uVar5;
  local_ca4 = local_1d94;
  local_ca0 = local_1fdc;
  local_c98 = uVar19;
  local_c90 = uVar40;
  local_c88 = uVar31;
  uStack_e5e = CONCAT26(uStack_650,uStack_656);
  local_e66 = CONCAT26(local_658,uStack_65e);
  uStack_e4e = CONCAT26(uStack_640,uStack_646);
  uStack_e56 = CONCAT26(local_648,uStack_64e);
  local_e46 = CONCAT26(local_638,uStack_63e);
  uStack_e3e = uStack_636;
  uStack_e30 = local_628;
  uStack_e38 = uStack_630;
  uStack_e36 = uStack_62e;
  local_db8 = uVar35;
  local_da0 = uVar35;
  uStack_c7c = CONCAT44(uStack_690,uStack_694);
  local_c84 = CONCAT44(local_698,uStack_69c);
  uStack_c6c = CONCAT44(uStack_680,uStack_684);
  uStack_c74 = CONCAT44(local_688,uStack_68c);
  uStack_c5c = CONCAT24(uStack_670,uStack_674);
  local_c64 = CONCAT44(uStack_678,uStack_67c);
  uStack_c4e = uStack_666;
  uStack_c56 = local_66e;
  uStack_c54 = (undefined6)(CONCAT26(uStack_668,CONCAT42(uStack_66c,local_66e)) >> 0x10);
  uStack_c3e = CONCAT26(uStack_6ce,uStack_6d4);
  local_c46 = CONCAT26(local_6d6,uStack_6dc);
  uStack_c2e = CONCAT26(uStack_6be,uStack_6c4);
  uStack_c36 = CONCAT26(local_6c6,uStack_6cc);
  uStack_c1e = CONCAT26(uStack_6ae,uStack_6b4);
  local_c26 = CONCAT26(uStack_6b6,uStack_6bc);
  uStack_c0e = uStack_6a4;
  uStack_bc6 = (undefined7)(CONCAT53(uStack_6e2,CONCAT21(uStack_6e4,uStack_6e5)) >> 8);
  uStack_bde = CONCAT62(uStack_6fa,uStack_6fc);
  local_be6 = CONCAT62(local_702,uStack_704);
  uStack_bce = CONCAT52(uStack_6ea,uStack_6ec);
  uStack_bd6 = CONCAT62(local_6f2,uStack_6f4);
  local_bc7 = uStack_6e5;
  uStack_bfe = CONCAT62(uStack_71a,uStack_71c);
  local_c06 = CONCAT62(local_722,uStack_724);
  uStack_bee = CONCAT62(uStack_70a,uStack_70c);
  uStack_bf6 = CONCAT62(local_712,uStack_714);
  uStack_b97 = CONCAT53(uStack_745,uStack_748);
  local_b9f = CONCAT53(local_74d,uStack_750);
  uStack_b87 = CONCAT53(uStack_735,uStack_738);
  uStack_b8f = CONCAT53(local_73d,uStack_740);
  uStack_bb7 = CONCAT53(uStack_765,uStack_768);
  local_bbf = CONCAT53(local_76d,uStack_770);
  uStack_ba7 = CONCAT53(uStack_755,uStack_758);
  uStack_baf = CONCAT53(local_75d,uStack_760);
  local_b70 = local_1dd8;
  local_b68 = local_1dd0;
  uStack_b2e = uStack_34e;
  uStack_b40 = local_360;
  uStack_b48 = uStack_368;
  local_b50 = local_370;
  uStack_b58 = uStack_378;
  local_b60 = local_380;
  local_b20 = local_1dc8;
  local_b18 = local_1dc0;
  local_b10 = local_1ddc;
  local_b0c = local_1de0;
  local_b08 = local_1e08;
  local_b00 = local_1da4;
  local_afc = local_1da8;
  local_af8 = local_1e14;
  local_e28 = local_1ed8;
  local_e20 = local_1ee0;
  local_e18 = local_1e48;
  local_e10 = local_1e50;
  local_e00 = (undefined1)local_1e60;
  uStack_df8 = CONCAT11(uStack_5c9,uStack_5ca);
  local_dfe = CONCAT24(uStack_5cc,local_5d0);
  local_e08 = local_1e58;
  local_de0 = 20;
  local_db0 = 0x7ff0000000000000;
  local_d98 = 0x7ff0000000000000;
  local_d88 = 64;
  local_d80 = 160;
  local_d78 = uVar38;
  local_d60 = 0x201;
  local_d58 = 0.35;
  local_d50 = 0.35;
  local_d40 = 160;
  uStack_d24 = 0;
  local_d2c = 0;
  local_d1c = 1;
  uStack_d10 = 0;
  local_d18 = 0;
  local_d08 = 1;
  uStack_cfc = 0;
  local_d04 = 0;
  local_cf4 = 1;
  local_cf3 = (undefined1)local_1f04;
  local_cf0 = 1f;
  local_ce0 = uVar28;
  local_cd0 = 0;
  uStack_cc4 = 0;
  local_ccc = 0;
  local_cbc = 1;
  uStack_cb0 = 0;
  local_cb8 = 0;
  local_ca8 = 1;
  local_af0 = local_1e10;
  local_ae8 = local_1e00;
  local_ae0 = uStack_1df8;
  local_ad8 = local_1e18;
  local_ad0 = local_1df0;
  local_ac8 = local_1e20;
  local_ac0 = local_1f40;
  local_ab8 = uStack_1f38;
  local_ab0 = local_1e30;
  local_aa8 = local_1e28;
  local_aa0 = local_1de8;
  local_a98 = local_1f48;
  uStack_a88 = uStack_1f58;
  local_a90 = local_1f60;
  local_a80 = 0;
  local_a78 = 1;
  local_a70 = 0;
  local_a68 = 1;
  local_a57 = 1;
  uStack_a48 = uStack_1f68;
  local_a50 = local_1f70;
  local_a40 = 0;
  local_a38 = 1;
  local_a30 = 0;
  local_a28 = 1;
  local_a17 = 1;
  uStack_a08 = uStack_1f78;
  local_a10 = local_1f80;
  local_a00 = 0;
  local_9f8 = 1;
  local_9f0 = 0;
  local_9e8 = 1;
  local_9d7 = 1;
  uStack_9c8 = uStack_1f88;
  local_9d0 = local_1f90;
  uStack_9b8 = uStack_1f98;
  local_9c0 = local_1fa0;
  local_9a0 = 0;
  uStack_9a8 = 0;
  local_9b0 = 0;
  local_998 = -2.58082;
  local_990 = local_1fa8;
  uStack_960 = uStack_5f8;
  local_968 = local_600;
  uStack_950 = uStack_5e8;
  uStack_958 = local_5f0;
  uStack_980 = uStack_618;
  local_988 = local_620;
  uStack_970 = uStack_608;
  uStack_978 = local_610;
  local_948 = local_5e0;
  local_940 = local_1ecc;
  local_93c = local_1ec8;
  local_938 = local_1ec4;
  local_934 = local_1ec0;
  local_930 = local_1ebc;
  local_92c = 0;
  local_928 = local_1eb8;
  local_920 = 0;
  local_918 = 0;
  local_914 = (undefined4)local_1eb0;
  local_8f0 = 0;
  uStack_8f8 = 0;
  local_900 = 0;
  uStack_908 = 0;
  local_910 = 0;
  local_8e8 = 0xff0000000000;
  uStack_8ba = 0;
  uStack_8c0 = 0;
  uStack_8d8 = 0;
  local_8e0 = 0;
  uStack_8c8 = 0;
  local_8c2 = 0;
  uStack_8d0 = 0;
  local_8b0 = local_1da0._0_4_;
  local_8ac = local_1e7c;
  local_8a8 = (undefined4)local_1e90;
  local_8a0 = local_1ea0;
  local_898 = local_1ea8;
  local_dff = uVar27;
  FUN_195ee891c(&local_1690,auStack_1d90);
  FUN_195ee8970(&local_f90);
  return;
}


//######## RegularBase.ReducedMotionBlurOpacities (spec) 0x195f1e864
// === 195f1e864 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1e864(long param_1)
{
  uVar1 = {d 0.0078125};
  <blur.opacities.2> = {d 0.00273437};
  <blur.opacities.0> = uVar1;
  return;
}


//######## RegularBase.anon.IncreasedDiffusion (spec) 0x195f1e878
// === 195f2244c spec

/* WARNING: Removing unreachable block (ram,0x000195f22520) */
/* WARNING: Removing unreachable block (ram,0x000195f224a8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2244c(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  uVar10 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar8 + 0x68))(uVar10,*_DAT_1e017dd58,lVar3);
  puVar5 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,uVar10,lVar3,puVar5);
  (**(code **)(lVar8 + 8))(uVar10,lVar3);
  FUN_195ed53f0();
  lVar3 = 0;
  FUN_195ed0900();
  if ((*(byte *)(param_2 + *(int *)(lVar3 + 0x14) + 3) & 1) != 0) {
    if ((uVar6 & 1) == 0) {
      if (<faceEffect.ycc.normalFill?nil> != '\x01') {
        <faceEffect.ycc.normalFill.a> = 0.8f;
      }
      <faceEffect.ycc.black> = 0.25f;
      uVar12 = 1.03f;
    }
    else {
      if ((uVar10 & 1) == 0) {
        if (<faceEffect.ycc.normalFill?nil> != '\x01') {
          <faceEffect.ycc.normalFill.a> = 0.6f;
        }
      }
      else {
        (**(code **)(lVar7 + 0x68))(puVar9,*_DAT_1e01830d0,lVar2);
        uVar12 = 0.6f;
        uVar11 = 0;
        uVar13 = 0;
        uVar14 = 0;
        func_0x0001981218c0(puVar9);
        <faceEffect.ycc.normalFill.b> =
             CONCAT17((char)((uint)uVar12 >> 0x18),
                      CONCAT16((char)((uint)uVar12 >> 0x10),
                               CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar14))));
        <faceEffect.ycc.normalFill.r> =
             CONCAT17((char)((uint)uVar13 >> 0x18),
                      CONCAT16((char)((uint)uVar13 >> 0x10),
                               CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar11))));
        <faceEffect.ycc.normalFill?nil> = 0;
      }
      <faceEffect.ycc.black> = 0.2f;
      uVar12 = 0.75f;
    }
    <faceEffect.ycc.white> = uVar12;
    <faceEffect.ycc.saturation> = 2f;
  }
  return;
}


//######## RegularBase.Adaptivity (spec) 0x195f1e87c
// === 195f22008 spec

/* WARNING: Removing unreachable block (ram,0x000195f2206c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f22008(long param_1,long param_2)
{
  uint5 *puVar1;
  undefined1 auStack_200 [80];
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  uVar9 = (long)&local_210 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195ed0900();
  if ((*(byte *)(param_2 + *(int *)(lVar4 + 0x14) + 3) & 1) != 0) {
    return;
  }
  lVar5 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar5 + 0x18);
  local_210 = lVar5;
  (**(code **)(lVar7 + 0x68))(uVar9,*_DAT_1e017dd58,lVar3);
  puVar8 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar2;
  func_0x0001980ff320(uVar6,uVar9,lVar3,puVar8);
  (**(code **)(lVar7 + 8))(uVar9,lVar3);
  FUN_195ed53f0();
  if ((uVar9 & 1) == 0) {
    local_204 = 2;
    uVar11 = (f 0.3, f 0.18);
    uVar13 = 0.0046875;
    uVar12 = 0.01f;
    uVar10 = 0.05f;
  }
  else {
    uVar11 = 0;
    uVar10 = 0;
    uVar12 = 0;
    local_204 = 0;
    uVar13 = 0.1f;
  }
  FUN_195ed53f0();
  local_82 = (undefined2)((ulong)uVar11 >> 0x30);
  uStack_88 = (undefined6)uVar11;
  uStack_7a = 0;
  uStack_80 = (undefined6)uVar10;
  uStack_73 = (undefined1)local_204;
  if ((uVar9 & 1) == 0) {
    if ((uVar6 & 1) == 0) {
      uStack_b8 = {f 0.6, 0.25};
      local_c0 = {d 0.0078125};
      local_b0 = 0x100000000;
      uStack_aa = 0;
      local_a4 = 0x201;
      local_a8 = 0;
      uStack_98 = {d 1.06812e-05};
      local_a0 = {f 0.1, -0.15};
      if (1 < *(byte *)(param_2 + *(int *)(lVar4 + 0x28)) - 1) goto LAB_195f22394;
      puVar8 = (undefined8 *)((ulong)&local_c0 | 8);
      puVar1 = (uint5 *)(param_2 + *(int *)(local_210 + 0x6c));
      if (*(char *)((long)puVar1 + 5) == '\x01') {
        local_c0 = 0;
      }
      else {
        uVar9 = (ulong)*puVar1;
        local_c0 = 0;
        if ((uVar9 & 0xff00000000) != 0x100000000) {
          local_c0 = uVar9 & 0xffffffff;
        }
      }
      *puVar8 = 0;
      puVar8[1] = 0;
      *(undefined8 *)((long)puVar8 + 0xe) = 0;
    }
    else {
      uStack_b8 = {d 3.05176e-05};
      local_c0 = {d 0.000292969};
      local_b0 = 0x100000000;
      uStack_aa = 0;
      local_a4 = 0x201;
      local_a8 = 0;
      uStack_98 = {d 1.06812e-05};
      local_a0 = {f 0.1, -0.15};
      if (1 < *(byte *)(param_2 + *(int *)(lVar4 + 0x28)) - 1) goto LAB_195f22394;
      local_c0 = 0;
      uStack_b8 = 0;
      local_a4 = 0;
      local_b0 = 0;
    }
    local_a8 = 0;
    uStack_aa = 0;
    uStack_98 = CONCAT44(0.45f,(undefined4)uStack_98);
    local_a0 = CONCAT44(-0.2f,(undefined4)local_a0);
  }
  else {
    puVar8 = (undefined8 *)((ulong)&local_c0 | 8);
    if ((uVar6 & 1) == 0) {
      uStack_98 = {d 0.0078125};
      local_a0 = {d -0.0078125};
      local_c0 = 0.2f;
    }
    else {
      uStack_98 = {d 0.0078125};
      local_a0 = {d -0.0078125};
      local_c0 = 0.075f;
    }
    *puVar8 = 0;
    puVar8[1] = 0;
    *(undefined8 *)((long)puVar8 + 0xe) = 0;
  }
LAB_195f22394:
  uStack_74 = 0;
  uStack_188 = uStack_98;
  local_190 = local_a0;
  uStack_178 = uStack_88;
  uStack_16a = CONCAT17(uStack_73,(uint7)uVar12 << 0x10);
  local_172 = local_82;
  uStack_170 = uStack_80;
  uStack_198 = CONCAT26(uStack_a2,CONCAT24(local_a4,local_a8));
  uStack_1a0 = CONCAT26(uStack_aa,local_b0);
  uStack_1a8 = uStack_b8;
  local_1b0 = local_c0;
  uStack_138 = uStack_98;
  local_140 = local_a0;
  uStack_128 = uStack_88;
  local_122 = local_82;
  uStack_120 = uStack_80;
  uStack_158 = uStack_b8;
  local_160 = local_c0;
  uStack_108 = <+0x698>;
  local_110 = <+0x690>;
  uStack_f8 = <+0x6a8>;
  uStack_100 = <+0x6a0>;
  uStack_e8 = <+0x6b8>;
  local_f0 = <+0x6b0>;
  uStack_e0 = <+0x6c0>;
  uStack_ca = <+0x6d6>;
  uStack_d0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
  uStack_d8 = (undefined6)<+0x6c8>;
  local_d2 = (undefined2)((ulong)<+0x6c8> >> 0x30);
  uStack_180 = uVar13;
  uStack_150 = uStack_1a0;
  uStack_148 = uStack_198;
  uStack_130 = uVar13;
  uStack_11a = uStack_16a;
  local_90 = uVar13;
  uStack_78 = uVar12;
  FUN_195ef7fcc(&local_1b0,auStack_200);
  FUN_195dabb50(&local_110,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
  <+0x6a8> = uStack_148;
  <+0x6a0> = uStack_150;
  <+0x6b8> = uStack_138;
  <+0x6b0> = local_140;
  <+0x6c8> = CONCAT26(local_122,uStack_128);
  <+0x6c0> = uStack_130;
  <+0x6d6> = uStack_11a;
  <+0x6ce> = CONCAT62(uStack_120,local_122);
  <+0x698> = uStack_158;
  <+0x690> = local_160;
  FUN_195ef82d0(&local_c0);
  return;
}


//######## FixedBlur (spec) 0x195f1e988
// === 195f1e988 spec

void FUN_195f1e988(void)
{
  FUN_195f1e880(*unaff_x20,unaff_x20[1]);
  return;
}


//######## BlurRadius (spec) 0x195f1e990
// === 195f1e990 spec

void FUN_195f1e990(ulong param_1)
{
  uVar9 = *unaff_x20;
  uVar5 = <+0x180>;
  uVar6 = <+0x188>;
  uVar7 = <+0x190>;
  cVar3 = <+0x191>;
  if (cVar3 == '\x02') {
    uVar5 = uVar5 & 0xffffffffff;
  }
  else {
    uVar1 = <+0x170>;
    uVar2 = <+0x178>;
    uVar8 = <blur.blurRadius>;
    uVar4 = param_1;
    FUN_195ed53f0();
    FUN_195eda468(uVar8,uVar1,uVar2,uVar5,uVar6,uVar7,cVar3);
    uVar6 = 0;
    uVar1 = 64;
    if ((uVar4 & 1) == 0) {
      uVar1 = 48;
    }
    <blur.blurRadius> = uVar1;
    <+0x170> = 160;
    uVar7 = 1;
    uVar5 = 0x100000000;
  }
  <+0x178> = uVar9;
  <+0x180> = uVar5;
  <+0x188> = uVar6;
  <+0x190> = uVar7;
  <+0x191> = 2;
  return;
}


//######## InactiveFaceEffect (spec) 0x195f1ea64
// === 195f22710 spec

/* WARNING: Removing unreachable block (ram,0x000195f227e4) */
/* WARNING: Removing unreachable block (ram,0x000195f2276c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f22710(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  uVar11 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar9 + 0x68))(uVar11,*_DAT_1e017dd58,lVar3);
  puVar5 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,uVar11,lVar3,puVar5);
  (**(code **)(lVar9 + 8))(uVar11,lVar3);
  FUN_195ed53f0();
  if ((uVar11 & 1) == 0) {
    if ((uVar6 & 1) == 0) {
      <faceEffect.ycc.white> = 0.95f;
      lVar3 = 0;
      FUN_195ed0900();
      if ((*(byte *)(param_2 + *(int *)(lVar3 + 0x14) + 3) & 1) != 0) {
        uVar7 = 0.75f;
        goto LAB_195f229e0;
      }
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar2);
      uVar7 = 1f;
      uVar12 = 1f;
      uVar13 = 1f;
    }
    else {
      lVar3 = 0;
      FUN_195ed0900();
      if ((*(byte *)(param_2 + *(int *)(lVar3 + 0x14) + 3) & 1) != 0) {
        uVar7 = 0.4f;
        goto LAB_195f229d4;
      }
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar2);
      uVar7 = 0;
      uVar12 = 0;
      uVar13 = 0;
    }
    uVar14 = 0.35f;
    func_0x0001981218c0(puVar10);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar14 >> 0x18),
                  CONCAT16((char)((uint)uVar14 >> 0x10),
                           CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar12 >> 0x18),
                  CONCAT16((char)((uint)uVar12 >> 0x10),
                           CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar7))));
    <faceEffect.ycc.normalFill?nil> = 0;
  }
  else {
    if ((uVar6 & 1) == 0) {
      uVar7 = 0.96f;
LAB_195f229e0:
      <faceEffect.ycc.white> = uVar7;
      return;
    }
    uVar7 = 0.08f;
LAB_195f229d4:
    <faceEffect.ycc.black> = uVar7;
  }
  return;
}


//######## InactiveHighlights (params) 0x195f1ea68
// === 195f25320 params

void FUN_195f25320(long param_1,long param_2)
{
  undefined1 auVar26 [16];
  undefined1 auStack_500 [272];
  undefined4 local_1b8 [2];
  lVar5 = 0;
  FUN_195ed0900();
  uVar13 = *(ulong *)(param_2 + *(int *)(lVar5 + 0x14));
  if ((uVar13 & 6) != 2) {
    if (((uint)uVar13 >> 0x17 & 1) == 0) {
      func_0x000198104610(&local_3d8,<highlights.hdr>,0x10d);
      iVar4 = (int)&local_3d8;
      FUN_195e7d8c0();
      if (iVar4 == 1) {
        uVar6 = 0;
        uVar8 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar11 = 0;
        uVar14 = 0;
        uVar15 = 0;
        uVar16 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar27 = 0;
        uVar28 = 0;
        uVar29 = 0;
        uVar30 = 0;
        uVar31 = 0;
        uVar35 = 0;
        uVar36 = 0;
        uVar37 = 0;
        uVar38 = 0;
        uVar39 = 0;
        uVar43 = 0;
        uVar34 = 0;
        uVar24 = 0x95f2539c;
        uVar40 = 0;
        uVar41 = 0;
        uVar42 = 0;
        uVar44 = 0;
        uVar45 = 0;
        uVar46 = 0;
        uVar25 = 0;
        uVar32 = 0;
        uVar33 = 0;
        uVar21 = 1;
        uVar22 = 1;
        uVar23 = 1;
        uVar1 = 1;
        uVar2 = 1;
        uVar3 = 1;
        uVar12 = 0;
      }
      else {
        local_3dc = local_383;
        local_3da = local_381;
        local_3de = local_36d;
        local_3e0 = local_36f;
        local_3e2 = local_359;
        local_3e4 = local_35b;
        local_3e6 = local_309;
        local_3e8 = local_30b;
        local_3ea = local_2f5;
        local_3ec = local_2f7;
        local_3ee = local_2e1;
        local_3f0 = local_2e3;
        uVar6 = local_31c;
        uVar8 = local_314;
        uVar9 = local_308;
        uVar10 = local_300;
        uVar11 = local_2ec;
        uVar14 = local_2f4;
        uVar15 = local_394;
        uVar16 = local_38c;
        uVar17 = local_380;
        uVar18 = local_378;
        uVar19 = local_36c;
        uVar20 = local_364;
        uVar27 = local_3d0;
        uVar28 = local_3c8;
        uVar29 = local_3b8;
        uVar30 = local_3b0;
        uVar31 = local_3a8;
        uVar35 = local_358;
        uVar36 = local_350;
        uVar37 = local_340;
        uVar38 = local_338;
        uVar39 = local_330;
        uVar43 = local_2e0;
        uVar34 = local_398;
        uVar24 = local_344;
        uVar40 = local_328;
        uVar41 = local_324;
        uVar42 = local_320;
        uVar44 = local_2d8;
        uVar45 = local_2d4;
        uVar46 = local_2d0;
        in_w5 = local_3d4;
        in_w6 = local_3bc;
        uVar25 = local_3d8;
        uVar32 = local_3a0;
        uVar33 = local_39c;
        uVar21 = local_384;
        uVar22 = local_370;
        uVar23 = local_35c;
        uVar1 = local_30c;
        uVar2 = local_2f8;
        uVar3 = local_2e4;
        uVar12 = local_2cc;
      }
      local_2b0 = 0;
      local_271 = local_3da;
      local_273 = local_3dc;
      local_25f = local_3e0;
      local_25d = local_3de;
      local_24b = local_3e4;
      local_249 = local_3e2;
      local_238 = 0;
      local_1f9 = local_3e6;
      local_1fb = local_3e8;
      local_1e5 = local_3ea;
      local_1e7 = local_3ec;
      local_1d1 = local_3ee;
      local_1d3 = local_3f0;
      local_1b8[0] = 0;
      local_1a8 = 0;
      local_1b0 = 0;
      local_1a0 = 0;
      local_168 = 0;
      uStack_180 = 0;
      local_188 = 0;
      uStack_170 = 0;
      uStack_178 = 0;
      uStack_190 = 0;
      local_198 = 0;
      local_164 = 1;
      local_158 = 0;
      local_160 = 0;
      local_150 = 1;
      local_144 = 0;
      local_14c = 0;
      local_13c = 1;
      local_130 = 0;
      local_138 = 0;
      local_128 = 0;
      local_f0 = 0;
      uStack_f8 = 0;
      local_100 = 0;
      uStack_108 = 0;
      local_110 = 0;
      uStack_118 = 0;
      local_120 = 0;
      local_ec = 1;
      local_e0 = 0;
      local_e8 = 0;
      local_d8 = 1;
      local_cc = 0;
      local_d4 = 0;
      local_c4 = 1;
      uStack_b0 = 0;
      uStack_b8 = 0;
      local_b3 = 0;
      local_c0 = 0;
      puVar7 = &local_2c8;
      local_2c8 = uVar25;
      local_2c4 = in_w5;
      local_2c0 = uVar27;
      local_2b8 = uVar28;
      local_2ac = in_w6;
      local_2a8 = uVar29;
      local_2a0 = uVar30;
      local_298 = uVar31;
      local_290 = uVar32;
      local_28c = uVar33;
      local_288 = uVar34;
      local_284 = uVar15;
      local_27c = uVar16;
      local_274 = uVar21;
      local_270 = uVar17;
      local_268 = uVar18;
      local_260 = uVar22;
      local_25c = uVar19;
      local_254 = uVar20;
      local_24c = uVar23;
      local_248 = uVar35;
      local_240 = uVar36;
      local_234 = uVar24;
      local_230 = uVar37;
      local_228 = uVar38;
      local_220 = uVar39;
      local_218 = uVar40;
      local_214 = uVar41;
      local_210 = uVar42;
      local_20c = uVar6;
      local_204 = uVar8;
      local_1fc = uVar1;
      local_1f8 = uVar9;
      local_1f0 = uVar10;
      local_1e8 = uVar2;
      local_1e4 = uVar14;
      local_1dc = uVar11;
      local_1d4 = uVar3;
      local_1d0 = uVar43;
      local_1c8 = uVar44;
      local_1c4 = uVar45;
      local_1c0 = uVar46;
      local_1bc = uVar12;
      FUN_195ed8068(puVar7,local_1b8);
      if (((ulong)puVar7 & 1) == 0) {
        local_5f8 = 0;
        local_5bb = local_3dc;
        local_5b9 = local_3da;
        local_5a5 = local_3de;
        local_5a7 = local_3e0;
        local_591 = local_3e2;
        local_593 = local_3e4;
        local_580 = 0;
        local_541 = local_3e6;
        local_543 = local_3e8;
        local_52d = local_3ea;
        local_52f = local_3ec;
        local_519 = local_3ee;
        local_51b = local_3f0;
        local_610 = uVar25;
        local_60c = in_w5;
        local_608 = uVar27;
        uStack_600 = uVar28;
        uStack_5f4 = in_w6;
        local_5f0 = uVar29;
        uStack_5e8 = uVar30;
        local_5e0 = uVar31;
        local_5d8 = uVar32;
        uStack_5d4 = uVar33;
        local_5d0 = uVar34;
        local_5cc = uVar15;
        local_5c4 = uVar16;
        local_5bc = uVar21;
        local_5b8 = uVar17;
        uStack_5b0 = uVar18;
        local_5a8 = uVar22;
        local_5a4 = uVar19;
        local_59c = uVar20;
        local_594 = uVar23;
        local_590 = uVar35;
        uStack_588 = uVar36;
        local_57c = uVar24;
        local_578 = uVar37;
        uStack_570 = uVar38;
        local_568 = uVar39;
        local_560 = uVar40;
        local_55c = uVar41;
        local_558 = uVar42;
        local_554 = uVar6;
        local_54c = uVar8;
        local_544 = uVar1;
        local_540 = uVar9;
        uStack_538 = uVar10;
        local_530 = uVar2;
        local_52c = uVar14;
        local_524 = uVar11;
        local_51c = uVar3;
        local_518 = uVar43;
        local_510 = uVar44;
        local_50c = uVar45;
        local_508 = uVar46;
        local_504 = uVar12;
        _CGPointMake(&local_610);
        func_0x000198104610(auStack_500,&local_610,0x10d);
      }
      else {
        FUN_195e7d8d4(auStack_500);
      }
      func_0x000198104610(<highlights.hdr>,auStack_500,0x10d);
    }
    uVar13 = 0;
    if (<+0x400> != '\x01') {
      uVar13 = (ulong)<+0x3e0>;
    }
    <+0x3e0> = uVar13;
    <+0x3e8> = 1f;
    auVar26 = NEON_fmov(1,8);
    <+0x3f8> = auVar26._8_8_;
    <+0x3f0> = auVar26._0_8_;
    <+0x400> = 0;
  }
  return;
}


//######## InactiveDarkSpecular (params) 0x195f1ea6c
// === 195f2599c params

void FUN_195f2599c(long param_1)
{
  uVar1 = (uint)param_1;
  FUN_195ed53f0();
  if ((uVar1 & 1) == 0) {
    return;
  }
  if (<darkSpecular?nil> == '\x01') {
    dVar9 = 1.0;
    dVar7 = 0.0;
    dVar6 = 0.0;
    uVar4 = 0;
    uVar5 = 0;
    uVar3 = 0;
    dVar8 = 0.0;
LAB_195f25a28:
    func_0x000198121790(uVar3,0);
    if (((((uVar1 & 1) == 0) || (func_0x000198121790(uVar5,0), (uVar1 & 1) == 0)) ||
        (func_0x000198121790(uVar4,0), (uVar1 & 1) == 0)) ||
       (((dVar9 != 1.0 || (dVar6 != 0.0)) || (dVar7 != 0.0)))) goto LAB_195f25aac;
    <darkSpecular.colorBias> = 0;
    <darkSpecular.spreadSDR> = 0;
    <darkSpecular.spread> = 0;
    <darkSpecular.effectOffset> = 0;
    <darkSpecular.amount> = 0;
    <darkSpecular.angle> = 0;
    <darkSpecular.height> = 0;
    <darkSpecular?nil> = 1;
    dVar7 = 0.0;
    dVar6 = 0.0;
    uVar4 = 0;
    uVar5 = 0;
    uVar3 = 0;
    dVar8 = 0.0;
  }
  else {
    dVar6 = <darkSpecular.effectOffset>;
    dVar9 = <darkSpecular.amount>;
    uVar4 = <darkSpecular.spreadSDR>;
    uVar5 = <darkSpecular.spread>;
    uVar3 = <darkSpecular.angle>;
    dVar8 = <darkSpecular.height>;
    dVar7 = <darkSpecular.colorBias> * 0.75;
    if (dVar8 == 0.0) goto LAB_195f25a28;
LAB_195f25aac:
    <darkSpecular.height> = dVar8;
    <darkSpecular.angle> = uVar3;
    <darkSpecular.spread> = uVar5;
    <darkSpecular.spreadSDR> = uVar4;
    <darkSpecular.amount> = dVar9;
    <darkSpecular.effectOffset> = dVar6;
    <darkSpecular.colorBias> = dVar7;
    <darkSpecular?nil> = 0;
    if (dVar8 != 0.0) {
      bVar2 = false;
      goto LAB_195f25b0c;
    }
  }
  func_0x000198121790(uVar3,0);
  if (((uVar1 & 1) != 0) && (func_0x000198121790(uVar5,0), (uVar1 & 1) != 0)) {
    func_0x000198121790(uVar4,0);
  }
  bVar2 = true;
LAB_195f25b0c:
  <darkSpecular.height> = dVar8;
  <darkSpecular.angle> = uVar3;
  <darkSpecular.spread> = uVar5;
  <darkSpecular.spreadSDR> = uVar4;
  <darkSpecular.amount> = 0.5;
  <darkSpecular.effectOffset> = dVar6;
  <darkSpecular.colorBias> = dVar7;
  <darkSpecular?nil> = 0;
  if (((bVar2) && (func_0x000198121790(uVar3,0), (uVar1 & 1) != 0)) &&
     (func_0x000198121790(2.0944,0), (uVar1 & 1) != 0)) {
    func_0x000198121790(uVar4,0);
  }
  <darkSpecular.height> = dVar8;
  <darkSpecular.angle> = uVar3;
  <darkSpecular.spread> = 2.0944;
  <darkSpecular.spreadSDR> = uVar4;
  <darkSpecular.amount> = 0.5;
  <darkSpecular.effectOffset> = dVar6;
  <darkSpecular.colorBias> = dVar7;
  <darkSpecular?nil> = 0;
  if (((dVar8 == 0.0) && (func_0x000198121790(uVar3,0), (uVar1 & 1) != 0)) &&
     (func_0x000198121790(2.0944,0), (uVar1 & 1) != 0)) {
    func_0x000198121790(2.0944,0);
  }
  <darkSpecular.height> = dVar8;
  <darkSpecular.angle> = uVar3;
  <darkSpecular.spreadSDR> = 2.0944;
  <darkSpecular.spread> = 2.0944;
  <darkSpecular.amount> = 0.5;
  <darkSpecular.effectOffset> = dVar6;
  <darkSpecular.colorBias> = dVar7;
  <darkSpecular?nil> = 0;
  return;
}


//######## DisableShadow (spec) 0x195f1ea70
// === 195f1ea70 spec

void FUN_195f1ea70(long param_1)
{
  FUN_195eda468(<shadow.opacity>,<+0x30>,
                <+0x38>,<+0x40>,
                <+0x48>,<+0x50>,
                <+0x51>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  return;
}


//######## DisableOuterRefaction (spec) 0x195f1eab8
// === 195f1eab8 spec

void FUN_195f1eab8(long param_1)
{
  <refraction.outerOpacity> = 0;
  <refraction.normalizedOuterAmount> = 0;
  <refraction.outerHeightRange.hi> = 0;
  <refraction.outerAmountRange.hi> = 0;
  <refraction.outerAmountRange.lo> = 0;
  <refraction.outerHeightRange.lo> = 0;
  <refraction.normalizedOuterHeight> = 0;
  return;
}


//######## DisableEdgeBleed (spec) 0x195f1eacc
// === 195f1eacc spec

void FUN_195f1eacc(long param_1)
{
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,
                <+0x218>,<+0x220>,
                <+0x228>,<+0x230>,
                <+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  return;
}


//######## DisableRingShadow (spec) 0x195f1eb1c
// === 195f1eb1c spec

void FUN_195f1eb1c(long param_1)
{
  <ringShadow.opacity> = 0;
  return;
}


//######## InactiveFrost (spec) 0x195f1eb24
// === 195f1eb24 spec

void FUN_195f1eb24(long param_1,long param_2)
{
  lVar1 = 0;
  FUN_195ed0900();
  if (*(byte *)(param_2 + *(int *)(lVar1 + 0x28)) - 1 < 2) {
    FUN_195eda468(<blur.blurRadius>,<+0x170>,
                  <+0x178>,<+0x180>,
                  <+0x188>,<+0x190>,
                  <+0x191>);
    <blur.blurRadius> = 1f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  return;
}


//######## DisableBlur (spec) 0x195f1eb94
// === 195f1eb94 spec

void FUN_195f1eb94(long param_1)
{
  <blur.distances.1.v> = 0;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.opacities.2> = 0;
  <blur.opacities.0> = 0;
  <+0x141> = 0;
  <blur.distances.3.kind> = 0;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.opacity> = 0;
  <+0x170> = 0;
  <blur.blurRadius> = 0;
  <+0x180> = 0;
  <+0x178> = 0;
  <+0x18a> = 0;
  <+0x182> = 0;
  return;
}


//######## WatchSmartStackRecipe.anon.Modifier (spec) 0x195f1ec0c
// === 195f1ec0c spec

void FUN_195f1ec0c(void)
{
  FUN_195f25c38(0.4f);
  return;
}


//######## HomeLiveActivityRecipe.anon.Modifier (spec) 0x195f1ec30
// === 195f1ec30 spec

void FUN_195f1ec30(void)
{
  FUN_195f25c38(0.5f);
  return;
}


//######## WatchSmartStackFaceRecipe.anon.Modifier (spec) 0x195f1ec4c
// === 195f1ec4c spec

void FUN_195f1ec4c(long param_1,long param_2)
{
  lVar1 = 0;
  FUN_195f3c68c();
  lVar1 = *(long *)(param_2 + *(int *)(lVar1 + 0x24));
  if (*(long *)(lVar1 + 0x10) != 0) {
    uVar3 = *(undefined8 *)(lVar1 + 0x30);
    uVar2 = *(undefined8 *)(lVar1 + 0x28);
    <faceEffect.ycc.black> = 0;
    <faceEffect.ycc.white> = 0;
    <faceEffect.ycc.normalFill.b> = uVar3;
    <faceEffect.ycc.normalFill.r> = uVar2;
    <faceEffect.ycc.normalFill?nil> = 0;
    <highlights.keyYCC.saturation> = 1.5f;
    <highlights.fillYCC.saturation> = 1.5f;
  }
  return;
}


//######## NotificationCenterRecipe.anon.ShadowVibrancy (spec) 0x195f1ecc4
// === 195f1ecc4 spec

void FUN_195f1ecc4(long param_1)
{
  FUN_195dabb50(<shadow.vibrancyContribution>,&DAT_1eda3b6c0,0x195fa8230);
  <shadow.vibrancyContribution> = 1;
  <+0x129> = 0;
  return;
}


//######## InactiveAdaptivity.Modifier (spec) 0x195f1ed08
// === 195f22a04 spec

/* WARNING: Removing unreachable block (ram,0x000195f22a6c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f22a04(long param_1,long param_2)
{
  undefined1 auStack_1a0 [80];
  lVar4 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = auStack_1a0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar5 + 0x18);
  (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e017dd58,lVar4);
  puVar6 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar7 = param_2 + iVar1;
  func_0x0001980ff320(uVar7,puVar10,lVar4,puVar6);
  (**(code **)(lVar8 + 8))(puVar10,lVar4);
  uVar9 = <+0x6a8>;
  if (((uVar9 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    uStack_128 = <+0x698>;
    local_130 = <+0x690>;
    local_120 = <+0x6a0>;
    local_150 = <+0x6c0>;
    uStack_148 = (undefined6)<+0x6c8>;
    uStack_13a = <+0x6d6>;
    uStack_142 = (undefined2)<+0x6ce>;
    uStack_140 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    bVar3 = (uVar7 & 1) == 0;
    fVar11 = 0.05;
    if (bVar3) {
      fVar11 = -0.05;
    }
    uVar12 = 0.9f;
    if (bVar3) {
      uVar12 = 0.97f;
    }
    uStack_98 = <+0x6b8>;
    local_a0 = <+0x6b0>;
    uVar7 = (ulong)uStack_98 >> 0x20;
    uVar2 = (ulong)local_a0 >> 0x20;
    uStack_f8 = <+0x6a8>;
    uStack_100 = <+0x6a0>;
    uStack_e8 = <+0x6b8>;
    local_f0 = <+0x6b0>;
    uStack_e0 = <+0x6c0>;
    uStack_d8 = (undefined6)<+0x6c8>;
    uStack_ca = <+0x6d6>;
    local_d2 = (undefined2)<+0x6ce>;
    uStack_d0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    uStack_108 = <+0x698>;
    local_110 = <+0x690>;
    local_b0 = <+0x6a0>;
    uStack_7a = <+0x6d6>;
    uStack_80 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    local_82 = (undefined2)((ulong)<+0x6c8> >> 0x30);
    local_c0 = local_110;
    uStack_b8 = uStack_108;
    uStack_a8 = uVar9;
    uStack_90 = uStack_e0;
    uStack_88 = uStack_d8;
    FUN_195ef7fcc(&local_c0,auStack_1a0);
    FUN_195dabb50(&local_110,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
    <+0x698> = uStack_128;
    <+0x690> = local_130;
    <+0x6a0> = local_120;
    <+0x6a8> = uVar9;
    <+0x6b0> = 0.1f;
    <+0x6b4> = fVar11 + (float)uVar2;
    <+0x6b8> = uVar12;
    <+0x6bc> = fVar11 + (float)uVar7;
    <+0x6c8> = CONCAT26(uStack_142,uStack_148);
    <+0x6c0> = local_150;
    <+0x6d6> = uStack_13a;
    <+0x6ce> = CONCAT62(uStack_140,uStack_142);
  }
  return;
}


//######## CursorAccessoryRecipe.anon.Modifier (params) 0x195f1ed0c
// === 195f1ed0c params

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1ed0c(long param_1)
{
  uVar1 = {d -0.0078125};
  <tinting.distances.1> = {d 0};
  <tinting.opacity> = uVar1;
  <tinting?nil> = 0;
  <blurFill.darkenOpacity> = 0;
  <blurFill.blurRadius> = 0;
  <blurFill?nil> = 1;
  uVar2 = {d 0};
  uVar1 = {d 1};
  <ringShadow.strokeWidth> = 0;
  <ringShadow.verticalOffset> = 0;
  <ringShadow.opacity> = uVar2;
  <ringShadow.blurRadius> = uVar1;
  <ringShadow.maskAmount> = 1;
  <ringShadow?nil> = 0;
  return;
}


//######## MenuRecipe.Inactive (spec) 0x195f1f1a0
// === 195f1fe80 spec

/* WARNING: Removing unreachable block (ram,0x000195f1ff58) */
/* WARNING: Removing unreachable block (ram,0x000195f1fee0) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1fe80(long param_1,long param_2)
{
  undefined1 auVar12 [16];
  lVar3 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  uVar10 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar5 + 0x18);
  (**(code **)(lVar8 + 0x68))(uVar10,*_DAT_1e017dd58,lVar4);
  puVar6 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar13 = param_2 + iVar2;
  func_0x0001980ff320(uVar13,uVar10,lVar4,puVar6);
  (**(code **)(lVar8 + 8))(uVar10,lVar4);
  FUN_195ed53f0();
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  uVar1 = 64;
  if ((uVar10 & 1) == 0) {
    uVar1 = 48;
  }
  <blur.blurRadius> = uVar1;
  <+0x170> = 160;
  <+0x178> = {d 2.09715e+06};
  uVar1 = {f 0, 1.4013e-45};
  <+0x188> = {d 0};
  <+0x180> = uVar1;
  <+0x190> = 0x201;
  auVar12 = NEON_fmov(1f,4);
  <blur.opacities.2> = auVar12._8_8_;
  <blur.opacities.0> = auVar12._0_8_;
  <blur.distances.0.v> = 0;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = 0;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  lVar4 = 0;
  FUN_195ed0900();
  if ((*(byte *)(param_2 + *(int *)(lVar4 + 0x14) + 3) & 1) == 0) {
    puVar6 = (undefined8 *)(lVar7 + 0x68);
    if ((uVar13 & 1) == 0) {
      <faceEffect.ycc.black> = 0.0053125;
      (*(code *)*puVar6)((ulong)puVar6 & 0xffffffffffff | 0xb2e4000000000000,puVar9,*_DAT_1e01830d0,
                         lVar3);
      uVar13 = 0.96f;
      uVar14 = 0.04f;
    }
    else {
      <faceEffect.ycc.black> = {f 0.15, 0.3};
      (*(code *)*puVar6)(puVar9,*_DAT_1e01830d0,lVar3);
      uVar13 = 0;
      uVar14 = 0;
    }
    uVar11 = (undefined4)uVar13;
    uVar10 = func_0x0001981218c0(puVar9);
    uVar10 = uVar10 & 0xffffffff;
    uVar13 = uVar13 & 0xffffffff;
    <faceEffect.ycc.normalFill.b> = (char)uVar13;
    <+0x2b9> = (char)(uVar13 >> 8);
    <+0x2ba> = (char)(uVar13 >> 0x10);
    <+0x2bb> = (char)(uVar13 >> 0x18);
    <faceEffect.ycc.normalFill.a> = (char)uVar14;
    <+0x2bd> = (char)((uint)uVar14 >> 8);
    <+0x2be> = (char)((uint)uVar14 >> 0x10);
    <+0x2bf> = (char)((uint)uVar14 >> 0x18);
    <faceEffect.ycc.normalFill.r> = (char)uVar10;
    <+0x2b1> = (char)(uVar10 >> 8);
    <+0x2b2> = (char)(uVar10 >> 0x10);
    <+0x2b3> = (char)(uVar10 >> 0x18);
    <faceEffect.ycc.normalFill.g> = (char)uVar11;
    <+0x2b5> = (char)((uint)uVar11 >> 8);
    <+0x2b6> = (char)((uint)uVar11 >> 0x10);
    <+0x2b7> = (char)((uint)uVar11 >> 0x18);
    <faceEffect.ycc.normalFill?nil> = 0;
  }
  FUN_195eda468(<shadow.opacity>,<+0x30>,
                <+0x38>,<+0x40>,
                <+0x48>,<+0x50>,
                <+0x51>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  <refraction.outerHeightRange.lo> = 0;
  <refraction.normalizedOuterHeight> = 0;
  <refraction.normalizedOuterAmount> = 0;
  <refraction.outerHeightRange.hi> = 0;
  <refraction.outerAmountRange.hi> = 0;
  <refraction.outerAmountRange.lo> = 0;
  <refraction.outerOpacity> = 0;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,
                <+0x218>,<+0x220>,
                <+0x228>,<+0x230>,
                <+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  if (*(byte *)(param_2 + *(int *)(lVar4 + 0x28)) - 1 < 2) {
    <blur.blurRadius> = 1f;
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  return;
}


//######## MenuRecipe.AdaptivityInactive (spec) 0x195f1f1a4
// === 195f1fbe4 spec

/* WARNING: Removing unreachable block (ram,0x000195f1fc4c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1fbe4(long param_1,long param_2)
{
  undefined1 auStack_230 [80];
  ushort uStack_d2;
  lVar4 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar11 = auStack_230 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar5 + 0x18);
  (**(code **)(lVar8 + 0x68))(puVar11,*_DAT_1e017dd58,lVar4);
  puVar6 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar7 = param_2 + iVar2;
  func_0x0001980ff320(uVar7,puVar11,lVar4,puVar6);
  (**(code **)(lVar8 + 8))(puVar11,lVar4);
  uVar10 = <+0x690>;
  uVar12 = <+0x698>;
  uVar13 = <+0x6a0>;
  uVar9 = <+0x6a8>;
  local_a0 = <+0x6b0>;
  uStack_98 = <+0x6b8>;
  uStack_90 = <+0x6c0>;
  uStack_88 = (undefined6)<+0x6c8>;
  uStack_7a = <+0x6d6>;
  local_82 = (undefined2)<+0x6ce>;
  uStack_80 = (undefined6)((ulong)<+0x6ce> >> 0x10);
  if (((uVar9 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    local_120 = <+0x6b0>;
    uStack_118 = <+0x6b8>;
    uStack_110 = <+0x6c0>;
    uStack_108 = (undefined6)<+0x6c8>;
    uStack_fa = <+0x6d6>;
    local_102 = (undefined2)<+0x6ce>;
    uStack_100 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    local_140 = uVar10;
    uStack_138 = uVar12;
    local_130 = uVar13;
    uStack_128 = uVar9;
    FUN_195ef7fcc(&local_140,&local_f0);
    FUN_195ef0f04(uVar10,uVar12,uVar13,uVar9,uVar9 >> 0x28);
    uStack_aa = uStack_7a;
    uStack_b0 = uStack_80;
    bVar3 = (uVar7 & 1) != 0;
    uVar1 = -(uint)bVar3;
    local_d0 = {f 0.3, -0.2} ^ ({f 0.3, -0.2} ^ {f 0.07, -0.1}) & uVar1;
    uStack_cc = {d 0.0059375} ^ ({d 0.0059375} ^ {d 0.000878907}) & uVar1;
    uStack_c8 = {d 5.49317e-05} ^ ({d 5.49317e-05} ^ {f 0.8, 0.3}) & uVar1;
    uStack_c4 = {f 0.55, 0.07} ^ ({f 0.55, 0.07} ^ {f 0.3, 64}) & uVar1;
    local_1e0 = 0;
    if (!bVar3) {
      local_1e0 = 0.04f;
    }
    uStack_b8 = uStack_88;
    local_b2 = local_82;
    uStack_c0 = uStack_90;
    local_e0 = 0;
    uStack_d2 = (ushort)(uVar9 >> 0x30);
    uStack_e8 = 0;
    uStack_da = 0;
    uStack_d8 = 0;
    local_1c0 = CONCAT44(uStack_cc,local_d0);
    uStack_1b8 = CONCAT44(uStack_c4,uStack_c8);
    uStack_1a8 = uStack_88;
    uStack_1b0 = uStack_90;
    uStack_19a = uStack_7a;
    local_1a2 = local_82;
    uStack_1a0 = uStack_80;
    uStack_1d0 = 0;
    lStack_1c8 = (ulong)uStack_d2 << 0x30;
    uStack_1d8 = 0;
    local_170 = <+0x6b0>;
    uStack_168 = <+0x6b8>;
    uStack_160 = <+0x6c0>;
    uStack_158 = (undefined6)<+0x6c8>;
    uStack_14a = <+0x6d6>;
    local_152 = (undefined2)<+0x6ce>;
    uStack_150 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    uStack_188 = <+0x698>;
    local_190 = <+0x690>;
    uStack_180 = <+0x6a0>;
    uStack_178 = <+0x6a8>;
    local_f0 = local_1e0;
    FUN_195ef7fcc(&local_1e0,auStack_230);
    FUN_195dabb50(&local_190,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
    <+0x6b8> = CONCAT44(uStack_c4,uStack_c8);
    <+0x6b0> = CONCAT44(uStack_cc,local_d0);
    <+0x6c8> = CONCAT26(local_b2,uStack_b8);
    <+0x6c0> = uStack_c0;
    <+0x6d6> = uStack_aa;
    <+0x6ce> = CONCAT62(uStack_b0,local_b2);
    <+0x698> = uStack_e8;
    <+0x690> = local_f0;
    <+0x6a8> = CONCAT26(uStack_d2,uStack_d8);
    <+0x6a0> = CONCAT26(uStack_da,local_e0);
    FUN_195ef82d0(&local_f0);
  }
  return;
}


//######## RegularMapsNavigationSignRecipe.anon.Modifier (spec) 0x195f1f5d4
// === 195f1f5d4 spec

/* WARNING: Removing unreachable block (ram,0x000195f1f6a8) */
/* WARNING: Removing unreachable block (ram,0x000195f1f630) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f1f5d4(long param_1,long param_2)
{
  lVar2 = 0;
  func_0x0001981217d0();
  lVar7 = *(long *)(lVar2 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar9 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar3 = 0;
  func_0x000198120110();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  lVar10 = (long)puVar9 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar8 + 0x68))(lVar10,*_DAT_1e017dd58,lVar3);
  puVar5 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,lVar10,lVar3,puVar5);
  (**(code **)(lVar8 + 8))(lVar10,lVar3);
  if ((uVar6 & 1) != 0) {
    <faceEffect.maxLuminance> = 0.0078125;
    (**(code **)(lVar7 + 0x68))(puVar9,*_DAT_1e01830d0,lVar2);
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0.75f;
    func_0x0001981218c0(puVar9);
    <faceEffect.ycc.normalFill.b> =
         CONCAT17((char)((uint)uVar14 >> 0x18),
                  CONCAT16((char)((uint)uVar14 >> 0x10),
                           CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar13))));
    <faceEffect.ycc.normalFill.r> =
         CONCAT17((char)((uint)uVar12 >> 0x18),
                  CONCAT16((char)((uint)uVar12 >> 0x10),
                           CONCAT15((char)((uint)uVar12 >> 8),CONCAT14((char)uVar12,uVar11))));
    <faceEffect.ycc.normalFill?nil> = 0;
  }
  return;
}


//######## CampoCardRecipe.anon.Modifier (spec) 0x195f1f810
// === 195f22c90 spec

/* WARNING: Removing unreachable block (ram,0x000195f22ce8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f22c90(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar8 = &stack0xffffffffffffffb0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  (**(code **)(lVar7 + 0x68))(puVar8,*_DAT_1e017dd58,lVar3);
  puVar5 = &DAT_1eda3a8e0;
  FUN_195eab224(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,puVar8,lVar3,puVar5);
  (**(code **)(lVar7 + 8))(puVar8,lVar3);
  if ((uVar6 & 1) == 0) {
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <shadow.opacity> = 0.2f;
    <+0x38> = 0;
    <+0x30> = 0;
    <+0x48> = 0;
    <+0x40> = 0;
    <+0x50> = 0;
    uVar2 = {d 0};
    <shadow.offset.1> = {d 4};
    <shadow.offset.0> = uVar2;
    FUN_195dabb50(<shadow.shadowRadius>,&DAT_1eda3b6c0,0x195fa8230);
    <shadow.shadowRadius> = 12;
    <+0x91> = 0;
    <ringShadow.opacity> = 0;
  }
  else {
    <faceEffect.ycc.black> = 0.1f;
  }
  fVar9 = 0.7;
  if (*(char *)(param_2 + *(int *)(lVar4 + 0x3c)) != '\b') {
    fVar9 = 1.0;
  }
  <+0x650> =
       CONCAT44((float)((ulong){f 14, -32} >> 0x20) * fVar9,(float){f 14, -32} * fVar9);
  <+0x658> = fVar9 * -2.5;
  <+0x660> = 0;
  return;
}


//######## ScrimRecipe.anon.Modifier (params) 0x195f26088
// === 195f2bd4c params

/* WARNING: Removing unreachable block (ram,0x000195f2be2c) */
/* WARNING: Removing unreachable block (ram,0x000195f2bdb4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2bd4c(undefined4 <backdropScale>,long param_2)
{
  undefined1 (*pauVar1) [12];
  undefined1 auStack_150 [8];
  lVar5 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar16 = auStack_150 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  lVar20 = (long)puVar16 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  if (<+0x35> == '\x01') {
    local_90 = 0;
    uStack_8c = 0;
    uVar21 = 0;
    uVar23 = 0;
    uVar25 = 0;
    uVar24 = 0;
    uVar22 = 0;
    uVar26 = 0;
    uVar28 = 0;
    uVar27 = 0;
  }
  else {
    local_90 = <edgeBleed.ycc.normalFill.r>;
    uStack_8c = <edgeBleed.ycc.normalFill.b>;
    pauVar1 = (undefined1 (*) [12])(<+0x2b>);
    uVar24 = (undefined4)((ulong)<+0x2d> >> 0x20);
    uVar23 = (undefined4)((ulong)*(undefined8 *)*pauVar1 >> 0x20);
    uVar21 = SUB124(*pauVar1,0);
    uVar25 = SUB124(*pauVar1,8);
    pauVar1 = (undefined1 (*) [12])(<+0x2f>);
    uVar27 = (undefined4)((ulong)<+0x31> >> 0x20);
    uVar26 = (undefined4)((ulong)*(undefined8 *)*pauVar1 >> 0x20);
    uVar22 = SUB124(*pauVar1,0);
    uVar28 = SUB124(*pauVar1,8);
  }
  uStack_a8 = CONCAT44(uVar24,uVar25);
  local_b0 = CONCAT44(uVar23,uVar21);
  uStack_98 = CONCAT44(uVar27,uVar28);
  uStack_a0 = CONCAT44(uVar26,uVar22);
  FUN_195f12ab4(param_2,0);
  FUN_195ed0ce8(&local_b0);
  <backdropScale> = 0.25f;
  uVar17 = {d -0.0078125};
  <+0x77> = {d 524288};
  <+0x75> = uVar17;
  <+0x79> = 0;
  lVar7 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar7 + 0x18);
  lVar7 = lVar20;
  (**(code **)(lVar10 + 0x68))(lVar20,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  uVar14 = param_2 + iVar2;
  func_0x0001980ff320(uVar14,lVar20,lVar6,lVar7);
  (**(code **)(lVar10 + 8))(lVar20,lVar6);
  (**(code **)(lVar9 + 0x68))(puVar16,*_DAT_1e01830d0,lVar5);
  if ((uVar14 & 1) == 0) {
    uVar21 = 0.1f;
    uVar22 = 1f;
    uVar25 = 1f;
    uVar28 = 1f;
    func_0x0001981218c0(puVar16);
    uVar14 = 0.95f;
    uVar15 = 0.2f;
  }
  else {
    uVar21 = 0.4f;
    uVar22 = 0;
    uVar25 = 0;
    uVar28 = 0;
    func_0x0001981218c0(puVar16);
    uVar14 = 0.6f;
    uVar15 = 0.15f;
  }
  uVar14 = uVar14 | 0.0078125;
  if (DAT_1eda3b1e0 != -1) {
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
  }
  fVar4 = DAT_1eda46354;
  fVar3 = DAT_1eda46350;
  uVar17 = CONCAT44(uVar25,uVar22);
  uVar18 = CONCAT44(uVar21,uVar28);
  uStack_d8 = ram0x0001eda46330;
  local_e0 = ram0x0001eda46328;
  uStack_c8 = ram0x0001eda46340;
  uStack_d0 = ram0x0001eda46338;
  local_c3 = DAT_1eda46344._1_3_;
  uStack_c0 = ram0x0001eda46348;
  uStack_f8 = _DAT_1eda46310;
  local_100 = _DAT_1eda46308;
  uStack_e8 = ram0x0001eda46320;
  uStack_f0 = ram0x0001eda46318;
  if (DAT_1eda46304 == 1.0) {
    uStack_124 = 0;
    local_12c = 0;
    local_11c = 0x100000000;
    uStack_10c = 0;
    local_114 = 0;
    uVar19 = 1;
    local_104 = 1;
    puVar8 = &local_148;
    local_148 = uVar15;
    local_144 = uVar14;
    local_13c = uVar17;
    local_134 = uVar18;
    FUN_195ed7db4(puVar8,&local_100);
    if (((((ulong)puVar8 & 1) != 0) && (fVar3 == 1.0)) && (fVar4 == 1.0)) {
      uVar11 = 0;
      uVar14 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar13 = 0;
      uVar12 = 0;
      uVar21 = 0;
      goto LAB_195f2c108;
    }
  }
  uVar19 = 0;
  uVar21 = 1f;
  uVar11 = (ulong)uVar15 << 0x20 | 1f;
  uVar12 = 0.0078125;
  uVar13 = 0x100000000;
LAB_195f2c108:
  <+0x44> = uVar11;
  <+0x46> = uVar14;
  <shadow.shadowRadius> = uVar17;
  <+0x4a> = uVar18;
  <+0x4e> = 0;
  <+0x4c> = 0;
  <shadow.ycc.black> = uVar13;
  <shadow.ycc.white> = 0;
  <+0x52> = 0;
  <+0x56> = uVar12;
  <highlights.fill.ycc.dodgeFill.b> = uVar21;
  <+0x59> = uVar19;
  return;
}


//######## ScrimRecipe.anon.ScrimBlurBase (spec) 0x195f2608c
// === 195f2608c spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2608c(long param_1,undefined8 param_2)
{
  undefined1 auVar2 [16];
  FUN_195f234d4(<blur.opacity>);
  auVar2 = NEON_fmov(1f,4);
  <blur.opacities.1> = auVar2._8_8_;
  <blur.opacity> = auVar2._0_8_;
  <blur.opacities.3> = 1f;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = 0;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.blurRadius> = 48;
  <+0x170> = 120;
  <+0x178> = {d 8192};
  uVar1 = {f 0, 1.4013e-45};
  <+0x188> = {d 0};
  <+0x180> = uVar1;
  <+0x190> = 0x201;
  <blur.outerRefractionBlurRadius> = 0;
  <blur.outerRefractionBlurRadius?nil> = 1;
  FUN_195eda2a0(&local_40,param_2);
  <+0x6e8> = uStack_38;
  <+0x6e0> = local_40;
  <+0x6f8> = uStack_28;
  <+0x6f0> = uStack_30;
  return;
}


//######## ScrimRecipe.anon.ScrimReducedTransparency (params) 0x195f2613c
// === 195f2ad68 params

/* WARNING: Removing unreachable block (ram,0x000195f2ae58) */
/* WARNING: Removing unreachable block (ram,0x000195f2addc) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2ad68(long param_1,long param_2)
{
  undefined1 auStack_380 [8];
  lVar4 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar5 = 0;
  local_2f0 = (undefined8 *)(auStack_380 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0));
  func_0x000198120110();
  lVar10 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  lVar31 = (long)(auStack_380 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0)) -
           (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  FUN_195f3c68c();
  iVar3 = *(int *)(lVar6 + 0x18);
  lVar6 = lVar31;
  (**(code **)(lVar10 + 0x68))(lVar31,*_DAT_1e017dd58,lVar5);
  FUN_195e7d9c0();
  uVar22 = param_2 + iVar3;
  func_0x0001980ff320(uVar22,lVar31,lVar5,lVar6);
  (**(code **)(lVar10 + 8))(lVar31,lVar5);
  pfVar21 = (float *)(<faceEffects.opacity>);
  if ((uVar22 & 1) == 0) {
    pfVar15 = &DAT_1eda46304;
    lVar6 = DAT_1eda3b1e0;
    if (<faceEffects?nil> == '\x01') {
      pfVar33 = &DAT_1eda46354;
      pfVar30 = &DAT_1eda46350;
      puVar7 = &DAT_1eda4634c;
      puVar8 = &DAT_1eda46344;
      puVar27 = &DAT_1eda4633c;
      puVar29 = &DAT_1eda46334;
      local_2f0 = (undefined8 *)&DAT_1eda4630c;
      puVar28 = &DAT_1eda46314;
      pfVar21 = (float *)&DAT_1eda46324;
      puVar23 = &DAT_1eda4631c;
      puVar26 = &DAT_1eda4632c;
      if (DAT_1eda3b1e0 != -1) {
        local_310 = &DAT_1eda4632c;
        pfStack_308 = (float *)&DAT_1eda46324;
        local_2f8 = &DAT_1eda46314;
        local_2f0 = (undefined8 *)&DAT_1eda4630c;
        local_300 = &DAT_1eda4631c;
        func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
        lVar6 = -1;
        puVar28 = local_2f8;
        pfVar21 = pfStack_308;
        puVar23 = local_300;
        puVar26 = local_310;
      }
    }
    else {
      local_2f0 = (undefined8 *)(<faceEffects.ycc.white>);
      puVar29 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
      puVar27 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
      puVar8 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
      puVar7 = (undefined4 *)(<faceEffects.ycc.burnFill?nil>);
      pfVar30 = (float *)(<faceEffects.maxLuminance>);
      pfVar33 = (float *)(<faceEffects.maxLuminanceSDR>);
      pfVar15 = pfVar21;
      puVar28 = (undefined8 *)(<faceEffects.ycc.normalFill.r>);
      pfVar21 = (float *)(<faceEffects.ycc.normalFill?nil>);
      puVar23 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
      puVar26 = (undefined8 *)(<faceEffects.ycc.dodgeFill.g>);
    }
    fVar44 = *pfVar33;
    fVar45 = *pfVar30;
    uVar40 = *puVar7;
    uVar20 = *puVar8;
    uVar36 = *puVar27;
    uVar32 = *puVar26;
    uVar22 = *(ulong *)pfVar21;
    uVar25 = *puVar23;
    puVar28 = (undefined8 *)*puVar28;
    puVar27 = (undefined8 *)*local_2f0;
    fVar46 = *pfVar15;
    local_2f0 = (undefined8 *)*puVar29;
    if (lVar6 != -1) {
      local_2f8 = puVar27;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      puVar27 = local_2f8;
    }
    fVar41 = DAT_1eda46354;
    fVar42 = DAT_1eda46350;
    fVar43 = DAT_1eda46304;
    uStack_d8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    local_e0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    uStack_c8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_d0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    local_c0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_b8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    uStack_b3 = DAT_1eda46344._1_3_;
    uStack_b0 = (undefined5)
                (CONCAT17((undefined1)DAT_1eda4634c,
                          CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_e8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_f0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    if (fVar46 == DAT_1eda46304) {
      local_138 = 0.15f;
      local_10c = local_2f0;
      local_f4 = (undefined1)uVar40;
      puVar7 = &local_138;
      local_134 = puVar27;
      local_12c = puVar28;
      local_124 = uVar25;
      local_11c = uVar22;
      local_114 = uVar32;
      local_104 = uVar36;
      local_fc = uVar20;
      FUN_195ed7db4(puVar7,&local_f0);
      if (((((ulong)puVar7 & 1) == 0) || (fVar45 != fVar42)) || (fVar44 != fVar41))
      goto LAB_195f2b37c;
      uVar11 = 0;
      puVar27 = (undefined8 *)0x0;
      puVar28 = (undefined8 *)0x0;
      uVar25 = 0;
      uVar22 = 0;
      uVar32 = 0;
      local_2f0 = (undefined8 *)0x0;
      uVar36 = 0;
      uVar20 = 0;
      uVar18 = 0;
      bVar13 = true;
      fVar44 = 0.0;
      uVar14 = 1;
    }
    else {
LAB_195f2b37c:
      bVar13 = false;
      uVar14 = 0;
      uVar11 = (ulong)(uint)fVar46 | (f 0, f 0.15);
      uVar18 = CONCAT44(fVar45,uVar40);
    }
    <faceEffects.opacity> = uVar11;
    *(undefined8 **)(<faceEffects.ycc.white>) = puVar27;
    *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar28;
    <faceEffects.ycc.normalFill.b> = uVar25;
    <faceEffects.ycc.normalFill?nil> = uVar22;
    <faceEffects.ycc.dodgeFill.g> = uVar32;
    *(undefined8 **)(<faceEffects.ycc.dodgeFill.a>) = local_2f0;
    <faceEffects.ycc.burnFill.r> = uVar36;
    <faceEffects.ycc.burnFill.b> = uVar20;
    <faceEffects.ycc.burnFill?nil> = uVar18;
    <faceEffects.maxLuminanceSDR> = fVar44;
    <faceEffects?nil> = uVar14;
    if (bVar13) {
      uVar18 = (ulong)DAT_1eda4634c;
      uVar36 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar32 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      local_2f0 = (undefined8 *)CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar25 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar22 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      puVar28 = (undefined8 *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      uVar12 = (ulong)DAT_1eda46310;
      puVar29 = (undefined8 *)(ulong)DAT_1eda46308;
      fVar44 = DAT_1eda46354;
      fVar41 = DAT_1eda46354;
      fVar43 = DAT_1eda46304;
      fVar45 = DAT_1eda46304;
      fVar42 = DAT_1eda46350;
      fVar46 = DAT_1eda46350;
      local_2f8 = (undefined8 *)CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    }
    else {
      puVar29 = (undefined8 *)(uVar11 >> 0x20);
      uVar12 = (ulong)puVar27 >> 0x20;
      fVar45 = (float)uVar11;
      fVar46 = (float)(uVar18 >> 0x20);
      local_2f8 = (undefined8 *)uVar20;
    }
    uStack_178 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_180 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_168 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    local_170 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    uStack_158 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_160 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    local_150 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_148 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    uStack_143 = DAT_1eda46344._1_3_;
    uStack_140 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    if (fVar45 == fVar43) {
      local_1c8 = SUB84(puVar29,0);
      puVar27 = (undefined8 *)(uVar12 << 0x20 | 0.86f);
      local_19c = local_2f0;
      local_18c = local_2f8;
      local_184 = (undefined1)uVar18;
      puVar7 = &local_1c8;
      local_300 = puVar29;
      local_1c4 = puVar27;
      local_1bc = puVar28;
      local_1b4 = uVar25;
      local_1ac = uVar22;
      local_1a4 = uVar32;
      local_194 = uVar36;
      FUN_195ed7db4(puVar7,&local_180);
      puVar29 = local_300;
      if (((((ulong)puVar7 & 1) == 0) || (fVar46 != fVar42)) || (fVar44 != fVar41))
      goto LAB_195f2b834;
      uVar11 = 0;
      puVar27 = (undefined8 *)0x0;
      puVar28 = (undefined8 *)0x0;
      uVar25 = 0;
      uVar22 = 0;
      uVar32 = 0;
      local_2f0 = (undefined8 *)0x0;
      uVar36 = 0;
      uVar18 = 0;
      bVar13 = true;
      fVar44 = 0.0;
      uVar14 = 1;
      puVar29 = (undefined8 *)0;
    }
    else {
      puVar27 = (undefined8 *)(uVar12 << 0x20 | 0.86f);
LAB_195f2b834:
      bVar13 = false;
      uVar14 = 0;
      uVar11 = (ulong)(uint)fVar45 | (long)puVar29 << 0x20;
      uVar18 = uVar18 & 0xffffffff | (ulong)(uint)fVar46 << 0x20;
      puVar29 = local_2f8;
    }
    <faceEffects.opacity> = uVar11;
    *(undefined8 **)(<faceEffects.ycc.white>) = puVar27;
    *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar28;
    <faceEffects.ycc.normalFill.b> = uVar25;
    <faceEffects.ycc.normalFill?nil> = uVar22;
    <faceEffects.ycc.dodgeFill.g> = uVar32;
    *(undefined8 **)(<faceEffects.ycc.dodgeFill.a>) = local_2f0;
    <faceEffects.ycc.burnFill.r> = uVar36;
    *(undefined8 **)(<faceEffects.ycc.burnFill.b>) = puVar29;
    <faceEffects.ycc.burnFill?nil> = uVar18;
    <faceEffects.maxLuminanceSDR> = fVar44;
    <faceEffects?nil> = uVar14;
    if (bVar13) {
      uVar18 = (ulong)DAT_1eda4634c;
      uVar36 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      puVar29 = (undefined8 *)CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar32 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      local_2f0 = (undefined8 *)CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar25 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      uVar22 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      puVar28 = (undefined8 *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      local_2f8 = (undefined8 *)(ulong)DAT_1eda46308;
      puVar27 = (undefined8 *)(ulong)DAT_1eda4630c;
      fVar44 = DAT_1eda46354;
      fVar41 = DAT_1eda46354;
      fVar43 = DAT_1eda46304;
      fVar45 = DAT_1eda46304;
      fVar42 = DAT_1eda46350;
      fVar46 = DAT_1eda46350;
    }
    else {
      local_2f8 = (undefined8 *)(uVar11 >> 0x20);
      fVar45 = (float)uVar11;
      fVar46 = (float)(uVar18 >> 0x20);
    }
    uStack_1e8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_1f0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    uStack_1e0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_1d8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    local_1d3 = DAT_1eda46344._1_3_;
    uStack_1d0 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_208 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_210 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_1f8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    uStack_200 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    if (fVar45 == fVar43) {
      local_258 = SUB84(local_2f8,0);
      uVar11 = (ulong)puVar27 & 0xffffffff | 0.00273437;
      local_22c = local_2f0;
      local_214 = (undefined1)uVar18;
      puVar7 = &local_258;
      local_254 = uVar11;
      local_24c = puVar28;
      local_244 = uVar25;
      local_23c = uVar22;
      local_234 = uVar32;
      local_224 = uVar36;
      local_21c = puVar29;
      FUN_195ed7db4(puVar7,&local_210);
      if (((((ulong)puVar7 & 1) != 0) && (fVar46 == fVar42)) && (fVar44 == fVar41)) {
        uVar12 = 0;
        uVar11 = 0;
        puVar28 = (undefined8 *)0x0;
        uVar25 = 0;
        uVar22 = 0;
        uVar32 = 0;
        local_2f0 = (undefined8 *)0x0;
        uVar36 = 0;
        puVar29 = (undefined8 *)0x0;
        uVar18 = 0;
        fVar44 = 0.0;
        uVar14 = 1;
        goto LAB_195f2bc24;
      }
    }
    else {
      uVar11 = (ulong)puVar27 & 0xffffffff | 0.00273437;
    }
    uVar14 = 0;
    uVar12 = (ulong)(uint)fVar45 | (long)local_2f8 << 0x20;
    uVar18 = uVar18 & 0xffffffff | (ulong)(uint)fVar46 << 0x20;
LAB_195f2bc24:
    <faceEffects.opacity> = uVar12;
    <faceEffects.ycc.white> = uVar11;
    *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar28;
    <faceEffects.ycc.normalFill.b> = uVar25;
    <faceEffects.ycc.normalFill?nil> = uVar22;
    <faceEffects.ycc.dodgeFill.g> = uVar32;
    *(undefined8 **)(<faceEffects.ycc.dodgeFill.a>) = local_2f0;
    <faceEffects.ycc.burnFill.r> = uVar36;
    *(undefined8 **)(<faceEffects.ycc.burnFill.b>) = puVar29;
    <faceEffects.ycc.burnFill?nil> = uVar18;
    <faceEffects.maxLuminanceSDR> = fVar44;
    <faceEffects?nil> = uVar14;
    return;
  }
  local_310 = (undefined8 *)(<faceEffects.ycc.white>);
  puStack_318 = (ulong *)(<faceEffects.ycc.normalFill?nil>);
  local_320 = (undefined8 *)(<faceEffects.ycc.dodgeFill.g>);
  puStack_328 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
  local_330 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
  puStack_338 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
  local_340 = (uint *)(<faceEffects.ycc.burnFill?nil>);
  pfStack_348 = (float *)(<faceEffects.maxLuminance>);
  local_350 = (float *)(<faceEffects.maxLuminanceSDR>);
  lVar6 = DAT_1eda3b1e0;
  pfStack_308 = pfVar21;
  local_300 = (undefined8 *)lVar9;
  local_2f8 = (undefined8 *)lVar4;
  if (<faceEffects?nil> == '\x01') {
    puVar29 = &DAT_1eda46314;
    puVar8 = &DAT_1eda4632c;
    puVar28 = (undefined8 *)&DAT_1eda4630c;
    puVar16 = &DAT_1eda46324;
    puVar27 = &DAT_1eda4631c;
    puVar23 = &DAT_1eda4633c;
    pfVar21 = &DAT_1eda46304;
    puVar26 = &DAT_1eda46344;
    puVar24 = &DAT_1eda4634c;
    pfVar15 = &DAT_1eda46350;
    pfVar30 = &DAT_1eda46354;
    puVar35 = &DAT_1eda46334;
    if (DAT_1eda3b1e0 != -1) {
      local_360 = &DAT_1eda4631c;
      local_358 = &DAT_1eda46314;
      local_370 = &DAT_1eda46324;
      local_368 = (undefined8 *)&DAT_1eda4630c;
      local_378 = &DAT_1eda4632c;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      lVar6 = -1;
      puVar29 = local_358;
      puVar8 = local_378;
      puVar28 = local_368;
      puVar16 = local_370;
      puVar27 = local_360;
    }
  }
  else {
    puVar29 = (undefined8 *)(<faceEffects.ycc.normalFill.r>);
    puVar27 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
    puVar8 = local_320;
    puVar28 = local_310;
    puVar16 = puStack_318;
    puVar23 = local_330;
    puVar26 = puStack_338;
    puVar24 = local_340;
    pfVar15 = pfStack_348;
    pfVar30 = local_350;
    puVar35 = puStack_328;
  }
  fVar44 = *pfVar30;
  fVar45 = *pfVar15;
  uVar1 = *puVar24;
  uVar19 = *puVar26;
  uVar20 = *puVar23;
  uVar36 = *puVar35;
  uVar32 = *puVar8;
  uVar22 = *puVar16;
  uVar25 = *puVar27;
  puVar28 = (undefined8 *)*puVar28;
  fVar46 = *pfVar21;
  puVar27 = (undefined8 *)*puVar29;
  if (lVar6 != -1) {
    local_358 = (undefined8 *)*puVar29;
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    puVar27 = local_358;
  }
  fVar41 = DAT_1eda46354;
  fVar42 = DAT_1eda46350;
  fVar43 = DAT_1eda46304;
  uStack_d8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  local_e0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  uStack_c8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_d0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  local_c0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_b8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  uStack_b3 = DAT_1eda46344._1_3_;
  uStack_b0 = (undefined5)
              (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_))
              >> 0x18);
  uStack_e8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_f0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  puVar29 = (undefined8 *)(ulong)uVar1;
  if (fVar46 == DAT_1eda46304) {
    local_138 = 0.05f;
    local_f4 = (undefined1)uVar1;
    puVar7 = &local_138;
    local_358 = (undefined8 *)(ulong)uVar1;
    local_134 = puVar28;
    local_12c = puVar27;
    local_124 = uVar25;
    local_11c = uVar22;
    local_114 = uVar32;
    local_10c = uVar36;
    local_104 = uVar20;
    local_fc = uVar19;
    FUN_195ed7db4(puVar7,&local_f0);
    puVar29 = local_358;
    if (((((ulong)puVar7 & 1) == 0) || (fVar45 != fVar42)) || (fVar44 != fVar41))
    goto LAB_195f2b184;
    uVar11 = 0;
    puVar28 = (undefined8 *)0x0;
    puVar27 = (undefined8 *)0x0;
    uVar25 = 0;
    uVar22 = 0;
    uVar32 = 0;
    uVar36 = 0;
    uVar20 = 0;
    uVar19 = 0;
    uVar18 = 0;
    bVar13 = true;
    fVar44 = 0.0;
    uVar14 = 1;
  }
  else {
LAB_195f2b184:
    bVar13 = false;
    uVar14 = 0;
    uVar11 = (ulong)(uint)fVar46 | (f 0, f 0.05);
    uVar18 = (ulong)puVar29 | (ulong)(uint)fVar45 << 0x20;
  }
  <faceEffects.opacity> = uVar11;
  *(undefined8 **)(<faceEffects.ycc.white>) = puVar28;
  *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar27;
  <faceEffects.ycc.normalFill.b> = uVar25;
  <faceEffects.ycc.normalFill?nil> = uVar22;
  <faceEffects.ycc.dodgeFill.g> = uVar32;
  <faceEffects.ycc.dodgeFill.a> = uVar36;
  <faceEffects.ycc.burnFill.r> = uVar20;
  <faceEffects.ycc.burnFill.b> = uVar19;
  <faceEffects.ycc.burnFill?nil> = uVar18;
  <faceEffects.maxLuminanceSDR> = fVar44;
  <faceEffects?nil> = uVar14;
  if (bVar13) {
    uVar18 = (ulong)DAT_1eda4634c;
    uVar20 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
    uVar19 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    uVar32 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
    uVar36 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
    uVar25 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
    uVar22 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
    puVar27 = (undefined8 *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
    uVar12 = (ulong)DAT_1eda46310;
    puVar29 = (undefined8 *)(ulong)DAT_1eda46308;
    fVar44 = DAT_1eda46354;
    fVar41 = DAT_1eda46354;
    fVar43 = DAT_1eda46304;
    fVar45 = DAT_1eda46304;
    fVar42 = DAT_1eda46350;
    fVar46 = DAT_1eda46350;
  }
  else {
    puVar29 = (undefined8 *)(uVar11 >> 0x20);
    uVar12 = (ulong)puVar28 >> 0x20;
    fVar45 = (float)uVar11;
    fVar46 = (float)(uVar18 >> 0x20);
  }
  uStack_178 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_180 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_168 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  local_170 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  uStack_158 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_160 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  local_150 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_148 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  uStack_143 = DAT_1eda46344._1_3_;
  uStack_140 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  if (fVar45 == fVar43) {
    local_1c8 = SUB84(puVar29,0);
    local_358 = (undefined8 *)(uVar12 << 0x20 | 0.5f);
    local_184 = (undefined1)uVar18;
    puVar7 = &local_1c8;
    local_360 = puVar29;
    local_1c4 = local_358;
    local_1bc = puVar27;
    local_1b4 = uVar25;
    local_1ac = uVar22;
    local_1a4 = uVar32;
    local_19c = uVar36;
    local_194 = uVar20;
    local_18c = uVar19;
    FUN_195ed7db4(puVar7,&local_180);
    puVar8 = local_358;
    puVar29 = local_360;
    if (((((ulong)puVar7 & 1) == 0) || (fVar46 != fVar42)) || (fVar44 != fVar41))
    goto LAB_195f2b680;
    uVar11 = 0;
    puVar8 = (undefined8 *)0x0;
    puVar27 = (undefined8 *)0x0;
    uVar25 = 0;
    uVar22 = 0;
    uVar32 = 0;
    uVar36 = 0;
    uVar20 = 0;
    uVar19 = 0;
    uVar18 = 0;
    bVar13 = true;
    fVar44 = 0.0;
    uVar14 = 1;
  }
  else {
    puVar8 = (undefined8 *)(uVar12 << 0x20 | 0.5f);
LAB_195f2b680:
    bVar13 = false;
    uVar14 = 0;
    uVar11 = (ulong)(uint)fVar45 | (long)puVar29 << 0x20;
    uVar18 = uVar18 & 0xffffffff | (ulong)(uint)fVar46 << 0x20;
  }
  <faceEffects.opacity> = uVar11;
  *(undefined8 **)(<faceEffects.ycc.white>) = puVar8;
  *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar27;
  <faceEffects.ycc.normalFill.b> = uVar25;
  <faceEffects.ycc.normalFill?nil> = uVar22;
  <faceEffects.ycc.dodgeFill.g> = uVar32;
  <faceEffects.ycc.dodgeFill.a> = uVar36;
  <faceEffects.ycc.burnFill.r> = uVar20;
  <faceEffects.ycc.burnFill.b> = uVar19;
  <faceEffects.ycc.burnFill?nil> = uVar18;
  <faceEffects.maxLuminanceSDR> = fVar44;
  <faceEffects?nil> = uVar14;
  if (bVar13) {
    uVar18 = (ulong)DAT_1eda4634c;
    uVar20 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
    uVar19 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    uVar32 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
    uVar36 = CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
    uVar25 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
    uVar22 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
    puVar27 = (undefined8 *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
    puVar29 = (undefined8 *)(ulong)DAT_1eda46308;
    puVar8 = (undefined8 *)(ulong)DAT_1eda4630c;
    fVar44 = DAT_1eda46354;
    fVar41 = DAT_1eda46354;
    fVar43 = DAT_1eda46304;
    fVar45 = DAT_1eda46304;
    fVar42 = DAT_1eda46350;
    fVar46 = DAT_1eda46350;
  }
  else {
    puVar29 = (undefined8 *)(uVar11 >> 0x20);
    fVar45 = (float)uVar11;
    fVar46 = (float)(uVar18 >> 0x20);
  }
  uStack_1e8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_1f0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_1e0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_1d8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_1d3 = DAT_1eda46344._1_3_;
  uStack_1d0 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_208 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_210 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_1f8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_200 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar45 == fVar43) {
    local_258 = SUB84(puVar29,0);
    uVar11 = (ulong)puVar8 & 0xffffffff | 0.000292969;
    local_214 = (undefined1)uVar18;
    puVar7 = &local_258;
    local_360 = puVar29;
    local_358 = puVar27;
    local_254 = uVar11;
    local_24c = puVar27;
    local_244 = uVar25;
    local_23c = uVar22;
    local_234 = uVar32;
    local_22c = uVar36;
    local_224 = uVar20;
    local_21c = uVar19;
    FUN_195ed7db4(puVar7,&local_210);
    puVar27 = local_358;
    puVar29 = local_360;
    if (((((ulong)puVar7 & 1) == 0) || (fVar46 != fVar42)) || (fVar44 != fVar41))
    goto LAB_195f2b9e4;
    uVar18 = 0;
    uVar19 = 0;
    uVar20 = 0;
    uVar36 = 0;
    uVar32 = 0;
    uVar22 = 0;
    uVar25 = 0;
    puVar27 = (undefined8 *)0x0;
    uVar11 = 0;
    uVar12 = 0;
    fVar44 = 0.0;
    uVar14 = 1;
  }
  else {
    uVar11 = (ulong)puVar8 & 0xffffffff | 0.000292969;
LAB_195f2b9e4:
    uVar14 = 0;
    uVar12 = (ulong)(uint)fVar45 | (long)puVar29 << 0x20;
    uVar18 = uVar18 & 0xffffffff | (ulong)(uint)fVar46 << 0x20;
  }
  puVar29 = local_2f0;
  <faceEffects.opacity> = uVar12;
  <faceEffects.ycc.white> = uVar11;
  *(undefined8 **)(<faceEffects.ycc.normalFill.r>) = puVar27;
  <faceEffects.ycc.normalFill.b> = uVar25;
  <faceEffects.ycc.normalFill?nil> = uVar22;
  <faceEffects.ycc.dodgeFill.g> = uVar32;
  <faceEffects.ycc.dodgeFill.a> = uVar36;
  <faceEffects.ycc.burnFill.r> = uVar20;
  <faceEffects.ycc.burnFill.b> = uVar19;
  <faceEffects.ycc.burnFill?nil> = uVar18;
  puVar7 = _DAT_1e01830d0;
  <faceEffects.maxLuminanceSDR> = fVar44;
  <faceEffects?nil> = uVar14;
  (**(code **)((long)local_300 + 0x68))(local_2f0,*puVar7,local_2f8);
  uVar40 = 0.3f;
  uVar37 = 0;
  uVar38 = 0;
  uVar39 = 0;
  func_0x0001981218c0(puVar29);
  if (<faceEffects?nil> == '\x01') {
    puVar7 = &DAT_1eda46308;
    local_2f0 = (undefined8 *)&DAT_1eda4630c;
    puVar16 = &DAT_1eda46324;
    puVar29 = &DAT_1eda4632c;
    puVar27 = &DAT_1eda46334;
    puVar8 = &DAT_1eda4633c;
    puVar28 = &DAT_1eda46344;
    puVar24 = &DAT_1eda4634c;
    fVar41 = DAT_1eda46354;
    fVar44 = DAT_1eda46354;
    fVar43 = DAT_1eda46304;
    fVar45 = DAT_1eda46304;
    fVar42 = DAT_1eda46350;
    fVar46 = DAT_1eda46350;
  }
  else {
    puVar7 = (undefined4 *)(<faceEffects.ycc.black>);
    fVar44 = *local_350;
    fVar46 = *pfStack_348;
    fVar45 = *pfStack_308;
    local_2f0 = local_310;
    puVar16 = puStack_318;
    puVar29 = local_320;
    puVar27 = puStack_328;
    puVar8 = local_330;
    puVar28 = puStack_338;
    puVar24 = local_340;
  }
  uVar2 = *puVar7;
  local_2f0 = (undefined8 *)*local_2f0;
  uVar34 = *puVar29;
  uVar19 = *puVar27;
  uVar20 = *puVar8;
  uVar36 = *puVar28;
  local_2f8 = (undefined8 *)(ulong)*puVar24;
  uVar25 = CONCAT44(uVar38,uVar37);
  uVar32 = CONCAT44(uVar40,uVar39);
  uVar22 = *puVar16 & 0xffffffffffffff00;
  uStack_278 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_280 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_270 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_268 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_263 = DAT_1eda46344._1_3_;
  uStack_260 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_298 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_2a0 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_288 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_290 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar45 == fVar43) {
    local_2a4 = (undefined1)*puVar24;
    puVar7 = &local_2e8;
    local_2e8 = uVar2;
    local_2e4 = local_2f0;
    local_2dc = uVar25;
    local_2d4 = uVar32;
    local_2cc = uVar22;
    local_2c4 = uVar34;
    local_2bc = uVar19;
    local_2b4 = uVar20;
    local_2ac = uVar36;
    FUN_195ed7db4(puVar7,&local_2a0);
    if (((((ulong)puVar7 & 1) != 0) && (fVar46 == fVar42)) && (fVar44 == fVar41)) {
      uVar11 = 0;
      uVar36 = 0;
      uVar20 = 0;
      uVar19 = 0;
      uVar34 = 0;
      uVar22 = 0;
      uVar32 = 0;
      uVar25 = 0;
      local_2f0 = (undefined8 *)0x0;
      uVar17 = 0;
      fVar44 = 0.0;
      uVar14 = 1;
      goto LAB_195f2bbcc;
    }
  }
  uVar14 = 0;
  uVar17 = CONCAT44(uVar2,fVar45);
  uVar11 = (ulong)local_2f8 | (ulong)(uint)fVar46 << 0x20;
LAB_195f2bbcc:
  <faceEffects.opacity> = uVar17;
  *(undefined8 **)(<faceEffects.ycc.white>) = local_2f0;
  <faceEffects.ycc.normalFill.r> = uVar25;
  <faceEffects.ycc.normalFill.b> = uVar32;
  <faceEffects.ycc.normalFill?nil> = uVar22;
  <faceEffects.ycc.dodgeFill.g> = uVar34;
  <faceEffects.ycc.dodgeFill.a> = uVar19;
  <faceEffects.ycc.burnFill.r> = uVar20;
  <faceEffects.ycc.burnFill.b> = uVar36;
  <faceEffects.ycc.burnFill?nil> = uVar11;
  <faceEffects.maxLuminanceSDR> = fVar44;
  <faceEffects?nil> = uVar14;
  return;
}


//######## ScrimRecipe.anon.ScrimIncreasedContrast (params) 0x195f26140
// === 195f2a324 params

/* WARNING: Removing unreachable block (ram,0x000195f2a398) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2a324(long param_1,long param_2)
{
  undefined1 auStack_210 [8];
  lVar5 = 0;
  func_0x000198120110();
  lVar11 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  puVar29 = auStack_210 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  FUN_195f3c68c();
  iVar3 = *(int *)(lVar6 + 0x18);
  puVar7 = puVar29;
  (**(code **)(lVar11 + 0x68))(puVar29,*_DAT_1e017dd58,lVar5);
  FUN_195e7d9c0();
  uVar10 = param_2 + iVar3;
  func_0x0001980ff320(uVar10,puVar29,lVar5,puVar7);
  (**(code **)(lVar11 + 8))(puVar29,lVar5);
  pfVar24 = (float *)(<faceEffects.opacity>);
  if ((uVar10 & 1) == 0) {
    pfVar25 = &DAT_1eda46304;
    lVar5 = DAT_1eda3b1e0;
    if (<faceEffects?nil> == '\x01') {
      pfVar30 = &DAT_1eda46354;
      pfVar28 = &DAT_1eda46350;
      puVar9 = &DAT_1eda4634c;
      puVar18 = &DAT_1eda46344;
      puVar26 = &DAT_1eda4633c;
      local_1e0 = (float *)&DAT_1eda46314;
      puVar13 = (ulong *)&DAT_1eda4630c;
      pfVar8 = (float *)&DAT_1eda46308;
      puVar16 = &DAT_1eda4631c;
      puVar17 = &DAT_1eda46324;
      puVar21 = &DAT_1eda46334;
      puVar23 = &DAT_1eda4632c;
      if (DAT_1eda3b1e0 != -1) {
        local_200 = &DAT_1eda46334;
        local_1f8 = &DAT_1eda4632c;
        local_1e8 = &DAT_1eda4631c;
        local_1e0 = (float *)&DAT_1eda46314;
        local_1f0 = &DAT_1eda46324;
        func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
        lVar5 = -1;
        puVar16 = local_1e8;
        puVar17 = local_1f0;
        puVar21 = local_200;
        puVar23 = local_1f8;
      }
    }
    else {
      pfVar8 = (float *)(<faceEffects.ycc.black>);
      puVar13 = (ulong *)(<faceEffects.ycc.white>);
      local_1e0 = (float *)(<faceEffects.ycc.normalFill.r>);
      puVar26 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
      puVar18 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
      puVar9 = (undefined4 *)(<faceEffects.ycc.burnFill?nil>);
      pfVar28 = (float *)(<faceEffects.maxLuminance>);
      pfVar30 = (float *)(<faceEffects.maxLuminanceSDR>);
      puVar16 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
      puVar17 = (undefined8 *)(<faceEffects.ycc.normalFill?nil>);
      puVar21 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
      puVar23 = (undefined8 *)(<faceEffects.ycc.dodgeFill.g>);
      pfVar25 = pfVar24;
    }
    fVar34 = *pfVar30;
    fVar33 = *pfVar28;
    uVar1 = *puVar9;
    uVar31 = *puVar18;
    uVar27 = *puVar26;
    uVar19 = *puVar23;
    pfVar24 = (float *)*puVar17;
    uVar20 = *puVar16;
    uVar22 = *(undefined8 *)local_1e0;
    uVar10 = *puVar13;
    fVar35 = *pfVar8;
    fVar39 = *pfVar25;
    pfVar25 = (float *)*puVar21;
    if (lVar5 != -1) {
      local_1e0 = (float *)*puVar21;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      pfVar25 = local_1e0;
    }
    fVar36 = DAT_1eda46354;
    fVar38 = DAT_1eda46350;
    fVar40 = DAT_1eda46304;
    uStack_e8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    uStack_f0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    uStack_d8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_e0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    uStack_d0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_c8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    local_c3 = DAT_1eda46344._1_3_;
    uStack_c0 = (undefined5)
                (CONCAT17((undefined1)DAT_1eda4634c,
                          CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_f8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_100 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    if (fVar39 == DAT_1eda46304) {
      local_104 = (undefined1)uVar1;
      pfVar8 = &local_148;
      local_1e0 = pfVar24;
      local_148 = fVar35 + 0.5;
      local_144 = uVar10;
      local_13c = uVar22;
      local_134 = uVar20;
      local_12c = pfVar24;
      local_124 = uVar19;
      local_11c = pfVar25;
      local_114 = uVar27;
      local_10c = uVar31;
      FUN_195ed7db4(pfVar8,&local_100);
      pfVar24 = local_1e0;
      if (((((ulong)pfVar8 & 1) == 0) || (fVar33 != fVar38)) || (fVar34 != fVar36))
      goto LAB_195f2a824;
      uVar12 = 0;
      uVar10 = 0;
      uVar22 = 0;
      uVar20 = 0;
      pfVar24 = (float *)0x0;
      uVar19 = 0;
      pfVar25 = (float *)0x0;
      uVar27 = 0;
      uVar31 = 0;
      uVar15 = 0;
      bVar4 = true;
      fVar34 = 0.0;
      uVar14 = 1;
    }
    else {
LAB_195f2a824:
      bVar4 = false;
      uVar14 = 0;
      uVar12 = CONCAT44(fVar35 + 0.5,fVar39);
      uVar15 = CONCAT44(fVar33,uVar1);
    }
    <faceEffects.opacity> = uVar12;
    <faceEffects.ycc.white> = uVar10;
    <faceEffects.ycc.normalFill.r> = uVar22;
    <faceEffects.ycc.normalFill.b> = uVar20;
    *(float **)(<faceEffects.ycc.normalFill?nil>) = pfVar24;
    <faceEffects.ycc.dodgeFill.g> = uVar19;
    *(float **)(<faceEffects.ycc.dodgeFill.a>) = pfVar25;
    <faceEffects.ycc.burnFill.r> = uVar27;
    <faceEffects.ycc.burnFill.b> = uVar31;
    <faceEffects.ycc.burnFill?nil> = uVar15;
    <faceEffects.maxLuminanceSDR> = fVar34;
    <faceEffects?nil> = uVar14;
    if (bVar4) {
      uVar15 = (ulong)DAT_1eda4634c;
      uVar27 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
      uVar31 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
      uVar19 = CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
      pfVar25 = (float *)CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
      uVar20 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
      pfVar24 = (float *)CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
      uVar22 = CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
      local_1e0 = (float *)(ulong)DAT_1eda46308;
      uVar10 = (ulong)DAT_1eda4630c;
      fVar34 = DAT_1eda46354;
      fVar36 = DAT_1eda46354;
      fVar40 = DAT_1eda46304;
      fVar35 = DAT_1eda46304;
      fVar38 = DAT_1eda46350;
      fVar33 = DAT_1eda46350;
    }
    else {
      local_1e0 = (float *)(uVar12 >> 0x20);
      fVar35 = (float)uVar12;
      fVar33 = (float)(uVar15 >> 0x20);
    }
    uStack_168 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
    local_170 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
    uStack_160 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
    uStack_158 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
    local_153 = DAT_1eda46344._1_3_;
    uStack_150 = (undefined5)
                 (CONCAT17((undefined1)DAT_1eda4634c,
                           CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)) >> 0x18);
    uStack_188 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
    local_190 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
    uStack_178 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
    uStack_180 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
    if (fVar35 == fVar40) {
      local_1d8 = SUB84(local_1e0,0);
      local_1e8 = (undefined8 *)(uVar10 & 0xffffffff | 0.000878906);
      local_194 = (undefined1)uVar15;
      puVar9 = &local_1d8;
      local_1d4 = (ulong)local_1e8;
      local_1cc = uVar22;
      local_1c4 = uVar20;
      local_1bc = pfVar24;
      local_1b4 = uVar19;
      local_1ac = pfVar25;
      local_1a4 = uVar27;
      local_19c = uVar31;
      FUN_195ed7db4(puVar9,&local_190);
      if (((((ulong)puVar9 & 1) == 0) || (fVar33 != fVar38)) || (fVar34 != fVar36))
      goto LAB_195f2ab6c;
      uVar10 = 0;
      local_1e8 = (undefined8 *)0x0;
      uVar22 = 0;
      uVar20 = 0;
      pfVar24 = (float *)0x0;
      uVar19 = 0;
      pfVar25 = (float *)0x0;
      uVar27 = 0;
      uVar31 = 0;
      uVar12 = 0;
      fVar34 = 0.0;
      uVar14 = 1;
    }
    else {
      local_1e8 = (undefined8 *)(uVar10 & 0xffffffff | 0.000878906);
LAB_195f2ab6c:
      uVar14 = 0;
      uVar10 = (ulong)(uint)fVar35 | (long)local_1e0 << 0x20;
      uVar12 = uVar15 & 0xffffffff | (ulong)(uint)fVar33 << 0x20;
    }
    <faceEffects.opacity> = uVar10;
    *(undefined8 **)(<faceEffects.ycc.white>) = local_1e8;
    <faceEffects.ycc.normalFill.r> = uVar22;
    <faceEffects.ycc.normalFill.b> = uVar20;
    *(float **)(<faceEffects.ycc.normalFill?nil>) = pfVar24;
    <faceEffects.ycc.dodgeFill.g> = uVar19;
    *(float **)(<faceEffects.ycc.dodgeFill.a>) = pfVar25;
    <faceEffects.ycc.burnFill.r> = uVar27;
    <faceEffects.ycc.burnFill.b> = uVar31;
    <faceEffects.ycc.burnFill?nil> = uVar12;
    goto LAB_195f2abe4;
  }
  if (<faceEffects?nil> == '\x01') {
    pfVar24 = &DAT_1eda46304;
    pfVar25 = &DAT_1eda46354;
    pfVar8 = &DAT_1eda46350;
    puVar9 = &DAT_1eda4634c;
    puVar26 = &DAT_1eda46344;
    puVar18 = &DAT_1eda4633c;
    local_1e8 = &DAT_1eda46314;
    puVar32 = &DAT_1eda46310;
    local_1e0 = (float *)&DAT_1eda4630c;
    pfVar28 = (float *)&DAT_1eda46308;
    puVar16 = &DAT_1eda4631c;
    puVar17 = &DAT_1eda46324;
    puVar21 = &DAT_1eda4632c;
    puVar23 = &DAT_1eda46334;
    if (DAT_1eda3b1e0 != -1) {
      local_208 = &DAT_1eda46334;
      local_200 = &DAT_1eda4632c;
      local_1e8 = &DAT_1eda46314;
      local_1e0 = (float *)&DAT_1eda4630c;
      local_1f8 = &DAT_1eda46324;
      local_1f0 = &DAT_1eda4631c;
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
      puVar16 = local_1f0;
      puVar17 = local_1f8;
      puVar21 = local_200;
      puVar23 = local_208;
    }
    bVar4 = true;
  }
  else {
    local_1e0 = (float *)(<faceEffects.ycc.white>);
    local_1e8 = (undefined8 *)(<faceEffects.ycc.normalFill.r>);
    puVar16 = (undefined8 *)(<faceEffects.ycc.normalFill.b>);
    puVar17 = (undefined8 *)(<faceEffects.ycc.normalFill?nil>);
    puVar21 = (undefined8 *)(<faceEffects.ycc.dodgeFill.g>);
    puVar23 = (undefined8 *)(<faceEffects.ycc.dodgeFill.a>);
    puVar18 = (undefined8 *)(<faceEffects.ycc.burnFill.r>);
    puVar26 = (undefined8 *)(<faceEffects.ycc.burnFill.b>);
    puVar9 = (undefined4 *)(<faceEffects.ycc.burnFill?nil>);
    pfVar25 = (float *)(<faceEffects.maxLuminanceSDR>);
    pfVar8 = (float *)(<faceEffects.maxLuminance>);
    pfVar28 = (float *)(<faceEffects.ycc.black>);
    puVar32 = (undefined4 *)(<faceEffects.ycc.saturation>);
    bVar4 = DAT_1eda3b1e0 == -1;
  }
  fVar34 = *pfVar25;
  fVar39 = *pfVar8;
  uVar1 = *puVar9;
  uVar27 = *puVar26;
  uVar19 = *puVar18;
  uVar20 = *puVar17;
  uVar22 = *puVar16;
  uVar31 = *local_1e8;
  uVar2 = *puVar32;
  fVar33 = *local_1e0;
  fVar35 = *pfVar28;
  fVar40 = *pfVar24;
  pfVar24 = (float *)*puVar21;
  puVar26 = (undefined8 *)*puVar23;
  if (!bVar4) {
    local_1e8 = (undefined8 *)*puVar23;
    local_1e0 = (float *)*puVar21;
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    pfVar24 = local_1e0;
    puVar26 = local_1e8;
  }
  fVar37 = DAT_1eda46354;
  fVar36 = DAT_1eda46350;
  fVar38 = DAT_1eda46304;
  uStack_e8 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_f0 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  uStack_d8 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_e0 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_d0 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_c8 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_c3 = DAT_1eda46344._1_3_;
  uStack_c0 = (undefined5)
              (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_))
              >> 0x18);
  uStack_f8 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_100 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  local_1e0 = (float *)uVar31;
  if (fVar40 == DAT_1eda46304) {
    local_1e8 = (undefined8 *)CONCAT44(uVar2,fVar33 + -0.5);
    local_104 = (undefined1)uVar1;
    pfVar25 = &local_148;
    local_1f0 = (undefined8 *)(ulong)(uint)fVar35;
    local_148 = fVar35;
    local_144 = (ulong)local_1e8;
    local_13c = uVar31;
    local_134 = uVar22;
    local_12c = uVar20;
    local_124 = pfVar24;
    local_11c = puVar26;
    local_114 = uVar19;
    local_10c = uVar27;
    FUN_195ed7db4(pfVar25,&local_100);
    puVar18 = local_1f0;
    if (((((ulong)pfVar25 & 1) == 0) || (fVar39 != fVar36)) || (fVar34 != fVar37))
    goto LAB_195f2a9d8;
    uVar12 = 0;
    local_1e8 = (undefined8 *)0x0;
    local_1e0 = (float *)0x0;
    uVar22 = 0;
    uVar20 = 0;
    pfVar24 = (float *)0x0;
    puVar26 = (undefined8 *)0x0;
    uVar19 = 0;
    uVar27 = 0;
    uVar10 = 0;
    bVar4 = true;
    fVar34 = 0.0;
    uVar14 = 1;
  }
  else {
    local_1e8 = (undefined8 *)CONCAT44(uVar2,fVar33 + -0.5);
    puVar18 = (undefined8 *)(ulong)(uint)fVar35;
LAB_195f2a9d8:
    bVar4 = false;
    uVar14 = 0;
    uVar12 = (ulong)(uint)fVar40 | (long)puVar18 << 0x20;
    uVar10 = CONCAT44(fVar39,uVar1);
  }
  <faceEffects.opacity> = uVar12;
  *(undefined8 **)(<faceEffects.ycc.white>) = local_1e8;
  *(float **)(<faceEffects.ycc.normalFill.r>) = local_1e0;
  <faceEffects.ycc.normalFill.b> = uVar22;
  <faceEffects.ycc.normalFill?nil> = uVar20;
  *(float **)(<faceEffects.ycc.dodgeFill.g>) = pfVar24;
  *(undefined8 **)(<faceEffects.ycc.dodgeFill.a>) = puVar26;
  <faceEffects.ycc.burnFill.r> = uVar19;
  <faceEffects.ycc.burnFill.b> = uVar27;
  <faceEffects.ycc.burnFill?nil> = uVar10;
  <faceEffects.maxLuminanceSDR> = fVar34;
  <faceEffects?nil> = uVar14;
  if (bVar4) {
    uVar15 = (ulong)DAT_1eda46308;
    local_1e8 = (undefined8 *)(ulong)DAT_1eda4630c;
    local_1e0 = (float *)CONCAT44(DAT_1eda46314._4_4_,(undefined4)DAT_1eda46314);
    uVar22 = CONCAT44(DAT_1eda4631c._4_4_,(undefined4)DAT_1eda4631c);
    uVar20 = CONCAT44(DAT_1eda46324._4_4_,(undefined4)DAT_1eda46324);
    pfVar24 = (float *)CONCAT44(DAT_1eda4632c._4_4_,(undefined4)DAT_1eda4632c);
    puVar26 = (undefined8 *)CONCAT44(DAT_1eda46334._4_4_,(undefined4)DAT_1eda46334);
    uVar19 = CONCAT44(DAT_1eda4633c._4_4_,(undefined4)DAT_1eda4633c);
    uVar27 = CONCAT44(DAT_1eda46344._4_4_,(undefined4)DAT_1eda46344);
    uVar10 = (ulong)DAT_1eda4634c;
    fVar34 = DAT_1eda46354;
    fVar37 = DAT_1eda46354;
    fVar38 = DAT_1eda46304;
    fVar35 = DAT_1eda46304;
    fVar36 = DAT_1eda46350;
    fVar33 = DAT_1eda46350;
  }
  else {
    uVar15 = uVar12 >> 0x20;
    fVar35 = (float)uVar12;
    fVar33 = (float)(uVar10 >> 0x20);
  }
  uStack_168 = CONCAT44((undefined4)DAT_1eda46334,DAT_1eda4632c._4_4_);
  local_170 = CONCAT44((undefined4)DAT_1eda4632c,DAT_1eda46324._4_4_);
  uStack_160 = CONCAT44((undefined4)DAT_1eda4633c,DAT_1eda46334._4_4_);
  uStack_158 = (undefined5)CONCAT44((undefined4)DAT_1eda46344,DAT_1eda4633c._4_4_);
  local_153 = DAT_1eda46344._1_3_;
  uStack_150 = (undefined5)
               (CONCAT17((undefined1)DAT_1eda4634c,CONCAT43(DAT_1eda46344._4_4_,DAT_1eda46344._1_3_)
                        ) >> 0x18);
  uStack_188 = CONCAT44((undefined4)DAT_1eda46314,DAT_1eda46310);
  local_190 = CONCAT44(DAT_1eda4630c,DAT_1eda46308);
  uStack_178 = CONCAT44((undefined4)DAT_1eda46324,DAT_1eda4631c._4_4_);
  uStack_180 = CONCAT44((undefined4)DAT_1eda4631c,DAT_1eda46314._4_4_);
  if (fVar35 == fVar38) {
    local_1d8 = (undefined4)uVar15;
    uVar12 = (ulong)local_1e8 & 0xffffffff | 0.000292969;
    local_194 = (undefined1)uVar10;
    puVar9 = &local_1d8;
    local_1e8 = (undefined8 *)uVar15;
    local_1d4 = uVar12;
    local_1cc = local_1e0;
    local_1c4 = uVar22;
    local_1bc = uVar20;
    local_1b4 = pfVar24;
    local_1ac = puVar26;
    local_1a4 = uVar19;
    local_19c = uVar27;
    FUN_195ed7db4(puVar9,&local_190);
    if (((((ulong)puVar9 & 1) == 0) || (fVar33 != fVar36)) || (fVar34 != fVar37))
    goto LAB_195f2abb8;
    uVar10 = 0;
    uVar27 = 0;
    uVar19 = 0;
    puVar26 = (undefined8 *)0x0;
    pfVar24 = (float *)0x0;
    uVar20 = 0;
    uVar22 = 0;
    local_1e0 = (float *)0x0;
    uVar12 = 0;
    uVar15 = 0;
    fVar34 = 0.0;
    uVar14 = 1;
  }
  else {
    uVar12 = (ulong)local_1e8 & 0xffffffff | 0.000292969;
    local_1e8 = (undefined8 *)uVar15;
LAB_195f2abb8:
    uVar14 = 0;
    uVar15 = (ulong)(uint)fVar35 | (long)local_1e8 << 0x20;
    uVar10 = uVar10 & 0xffffffff | (ulong)(uint)fVar33 << 0x20;
  }
  <faceEffects.opacity> = uVar15;
  <faceEffects.ycc.white> = uVar12;
  *(float **)(<faceEffects.ycc.normalFill.r>) = local_1e0;
  <faceEffects.ycc.normalFill.b> = uVar22;
  <faceEffects.ycc.normalFill?nil> = uVar20;
  *(float **)(<faceEffects.ycc.dodgeFill.g>) = pfVar24;
  *(undefined8 **)(<faceEffects.ycc.dodgeFill.a>) = puVar26;
  <faceEffects.ycc.burnFill.r> = uVar19;
  <faceEffects.ycc.burnFill.b> = uVar27;
  <faceEffects.ycc.burnFill?nil> = uVar10;
LAB_195f2abe4:
  <faceEffects.maxLuminanceSDR> = fVar34;
  <faceEffects?nil> = uVar14;
  return;
}


//######## ScrimRecipe.anon.ScrimShapeOutlines (params) 0x195f26144
// === 195f26ac8 params

/* WARNING: Removing unreachable block (ram,0x000195f26bd0) */
/* WARNING: Removing unreachable block (ram,0x000195f26b58) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f26ac8(ulong param_1,long param_2,undefined8 param_3,undefined8 param_4,
                  undefined4 param_5,undefined8 param_6,undefined4 param_7)
{
  undefined1 auStack_11b0 [12];
  undefined1 auStack_ee8 [272];
  undefined1 auStack_cb0 [272];
  undefined1 auStack_a78 [272];
  undefined1 auStack_840 [276];
  undefined4 local_5f8 [2];
  (*_DAT_1e2125200)();
  uVar4 = 0;
  func_0x000198120110();
  local_10c0 = *(long *)(uVar4 - 8);
  local_10b0 = uVar4;
  (*_DAT_1e2125200)(*(undefined8 *)(local_10c0 + 0x40));
  lVar5 = 0;
  local_10c8 = auStack_11b0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  func_0x0001981217d0();
  local_10e0 = *(long *)(lVar5 + -8);
  local_10d8 = lVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(local_10e0 + 0x40));
  local_10e8 = (long)(auStack_11b0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0)) -
               (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195ed0900();
  local_10d0 = *(ulong *)(param_2 + *(int *)(lVar5 + 0x14));
  local_10b8 = param_2;
  local_1090 = param_1;
  func_0x000198104610(&local_708,<highlights.hdr>,0x10d);
  iVar3 = (int)&local_708;
  FUN_195e7d8c0();
  if (iVar3 == 1) {
    local_644 = 0;
    local_638 = 0;
    local_624 = 0;
    local_61c = 0;
    uVar13 = 0;
    local_700 = 0;
    local_708 = 0;
    local_6f8 = 0;
    uVar22 = 1;
    uVar30 = 1;
    uVar32 = 1;
    local_678 = 0;
    local_670 = 0;
    local_668 = 0;
    local_660 = 0;
    local_658 = 0;
    local_654 = 0;
    local_650 = 0;
    local_1098 = CONCAT44(local_1098._4_4_,1);
    local_10a0 = CONCAT44(local_10a0._4_4_,1);
    local_10a8 = CONCAT44(local_10a8._4_4_,1);
    local_610 = 0;
    local_608 = 0;
    local_604 = 0;
    local_600 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    uVar18 = 0;
    uVar19 = 0;
    uVar20 = 0;
    uVar21 = 0;
    uVar36 = 0;
    uVar38 = 0;
    uVar42 = 0;
    uVar44 = 0;
    uVar24 = 0;
    local_674 = 0x95f26c50;
    local_704 = param_5;
    local_6ec = param_7;
    uVar45 = 0;
    uVar47 = 0;
  }
  else {
    uVar22 = (uint)local_6b4;
    local_70c = local_6b3;
    local_70a = local_6b1;
    uVar30 = (uint)local_6a0;
    local_70e = local_69d;
    local_710 = local_69f;
    uVar32 = (uint)local_68c;
    local_712 = local_689;
    local_714 = local_68b;
    local_1098 = CONCAT44(local_1098._4_4_,(uint)local_63c);
    local_716 = local_639;
    local_718 = local_63b;
    local_10a0 = CONCAT44(local_10a0._4_4_,(uint)local_628);
    local_71a = local_625;
    local_71c = local_627;
    local_10a8 = CONCAT44(local_10a8._4_4_,(uint)local_614);
    local_71e = local_611;
    local_720 = local_613;
    uVar13 = (uint)local_5fc;
    uVar9 = local_64c;
    uVar10 = local_630;
    uVar15 = local_6c4;
    uVar16 = local_6bc;
    uVar17 = local_6b0;
    uVar18 = local_6a8;
    uVar19 = local_69c;
    uVar20 = local_694;
    uVar21 = local_6e8;
    uVar36 = local_6e0;
    uVar38 = local_6d8;
    uVar42 = local_688;
    uVar44 = local_680;
    uVar24 = local_6c8;
    uVar45 = local_6d0;
    uVar47 = local_6cc;
  }
  local_724 = local_718;
  local_722 = local_716;
  local_728 = local_71c;
  local_726 = local_71a;
  local_72c = local_720;
  local_72a = local_71e;
  local_1148 = CONCAT44(local_1148._4_4_,local_708);
  local_1110 = CONCAT44(local_1110._4_4_,local_704);
  local_1a0 = 1f;
  local_1120 = CONCAT44(local_1120._4_4_,local_6ec);
  local_1138 = CONCAT44(local_1138._4_4_,uVar22);
  local_164 = (undefined1)uVar22;
  local_163 = local_70c;
  local_161 = local_70a;
  local_1140 = CONCAT44(local_1140._4_4_,uVar30);
  local_150 = (undefined1)uVar30;
  local_14f = local_710;
  local_14d = local_70e;
  local_1150 = CONCAT44(local_1150._4_4_,uVar32);
  local_13c = (undefined1)uVar32;
  local_139 = local_712;
  local_13b = local_714;
  local_1160 = CONCAT44(local_1160._4_4_,local_678);
  local_1168 = CONCAT44(local_1168._4_4_,local_674);
  local_ec = (undefined1)local_1098;
  local_e9 = local_716;
  local_eb = local_718;
  local_d8 = (undefined1)local_10a0;
  local_d5 = local_71a;
  local_d7 = local_71c;
  local_c4 = (undefined1)local_10a8;
  local_c1 = local_71e;
  local_c3 = local_720;
  local_1130 = CONCAT44(local_1130._4_4_,uVar13);
  local_ac = (undefined1)uVar13;
  local_5f8[0] = 0;
  local_5e8 = 0;
  local_5f0 = 0;
  local_5e0 = 0;
  local_5a8 = 0;
  uStack_5b0 = 0;
  local_5b8 = 0;
  uStack_5c0 = 0;
  local_5c8 = 0;
  uStack_5d0 = 0;
  local_5d8 = 0;
  local_5a4 = 1;
  local_598 = 0;
  local_5a0 = 0;
  local_590 = 1;
  local_584 = 0;
  local_58c = 0;
  local_57c = 1;
  local_570 = 0;
  local_578 = 0;
  local_568 = 0;
  local_530 = 0;
  uStack_538 = 0;
  local_540 = 0;
  uStack_548 = 0;
  local_550 = 0;
  uStack_558 = 0;
  local_560 = 0;
  local_52c = 1;
  local_520 = 0;
  local_528 = 0;
  local_518 = 1;
  local_50c = 0;
  local_514 = 0;
  local_504 = 1;
  uStack_4f0 = 0;
  uStack_4f8 = 0;
  local_4f3 = 0;
  local_500 = 0;
  puVar6 = &local_1b8;
  local_11a4 = local_600;
  local_11a0 = local_604;
  uStack_119c = local_608;
  local_1198 = local_610;
  local_118c = local_650;
  local_1188 = local_654;
  local_1184 = local_658;
  local_1180 = local_660;
  local_1178 = local_668;
  local_1170 = local_670;
  local_1158 = local_700;
  local_1128 = local_6f8;
  local_1118 = local_61c;
  local_1108 = local_624;
  local_1100 = uVar10;
  local_10f8 = local_638;
  local_10f0 = local_644;
  local_1b8 = local_708;
  local_1b4 = local_704;
  local_1b0 = local_700;
  local_1a8 = local_6f8;
  local_19c = local_6ec;
  local_198 = uVar21;
  local_190 = uVar36;
  local_188 = uVar38;
  local_180 = uVar45;
  local_17c = uVar47;
  local_178 = uVar24;
  local_174 = uVar15;
  local_16c = uVar16;
  local_160 = uVar17;
  local_158 = uVar18;
  local_14c = uVar19;
  local_144 = uVar20;
  local_138 = uVar42;
  local_130 = uVar44;
  local_128 = local_678;
  local_124 = local_674;
  local_120 = local_670;
  local_118 = local_668;
  local_110 = local_660;
  local_108 = local_658;
  local_104 = local_654;
  local_100 = local_650;
  local_fc = uVar9;
  local_f4 = local_644;
  local_e8 = local_638;
  local_e0 = uVar10;
  local_d4 = local_624;
  local_cc = local_61c;
  local_c0 = local_610;
  local_b8 = local_608;
  local_b4 = local_604;
  local_b0 = local_600;
  FUN_195ed8068(puVar6,local_5f8);
  uVar12 = (undefined4)uVar10;
  if (((ulong)puVar6 & 1) == 0) {
    local_2c8 = (undefined4)local_1148;
    local_2c4 = (undefined4)local_1110;
    local_2c0 = local_1158;
    local_2b8 = local_1128;
    local_2b0 = 1f;
    local_2ac = (undefined4)local_1120;
    local_274 = (undefined1)local_1138;
    local_273 = local_70c;
    local_271 = local_70a;
    local_260 = (undefined1)local_1140;
    local_25d = local_70e;
    local_25f = local_710;
    local_24c = (undefined1)local_1150;
    local_249 = local_712;
    local_24b = local_714;
    local_238 = (undefined4)local_1160;
    local_234 = (undefined4)local_1168;
    local_230 = local_1170;
    local_228 = local_1178;
    local_220 = local_1180;
    local_218 = local_1184;
    local_214 = local_1188;
    local_210 = local_118c;
    local_204 = local_10f0;
    local_1fc = (undefined1)local_1098;
    local_1f9 = local_722;
    local_1fb = local_724;
    local_1f8 = local_10f8;
    local_1f0 = local_1100;
    local_1e8 = (undefined1)local_10a0;
    local_1e5 = local_726;
    local_1e7 = local_728;
    local_1e4 = local_1108;
    local_1dc = local_1118;
    local_1d4 = (undefined1)local_10a8;
    local_1d1 = local_72a;
    local_1d3 = local_72c;
    local_1d0 = local_1198;
    local_1c8 = uStack_119c;
    local_1c4 = local_11a0;
    local_1c0 = local_11a4;
    local_1bc = (undefined1)local_1130;
    local_2a8 = uVar21;
    local_2a0 = uVar36;
    local_298 = uVar38;
    local_290 = uVar45;
    local_28c = uVar47;
    local_288 = uVar24;
    local_284 = uVar15;
    local_27c = uVar16;
    local_270 = uVar17;
    local_268 = uVar18;
    local_25c = uVar19;
    local_254 = uVar20;
    local_248 = uVar42;
    local_240 = uVar44;
    local_20c = uVar9;
    _CGPointMake(&local_2c8);
    func_0x000198104610(auStack_840,&local_2c8,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_840);
  }
  uVar4 = local_1090;
  func_0x000198104610(local_1090 + 0x1e8,auStack_840,0x10d);
  lVar5 = local_10e8;
  (**(code **)(local_10e0 + 0x68))(local_10e8,*_DAT_1e01830d0,local_10d8);
  uVar24 = 0;
  uVar45 = 0;
  uVar47 = 0;
  uVar39 = 1f;
  func_0x0001981218c0(lVar5);
  func_0x000198104610(&local_950,uVar4 + 0x1e8,0x10d);
  iVar3 = (int)&local_950;
  FUN_195e7d8c0();
  if (iVar3 == 1) {
    local_864 = 0;
    local_86c = 0;
    local_878 = 0;
    local_880 = 0;
    local_904 = 0;
    local_8b0 = 0;
    uVar33 = 1;
    uVar30 = 1;
    local_8b8 = 0;
    uVar22 = 1;
    local_8c0 = 0;
    local_8c8 = 0;
    local_8d0 = 0;
    uVar32 = 1;
    local_950 = 0;
    local_948 = 0;
    local_940 = 0;
    local_938 = 0;
    local_930 = 0;
    local_928 = 0;
    local_920 = 0;
    local_918 = 0;
    local_914 = 0;
    local_118c = 1;
    local_910 = 0;
    uVar9 = 0;
    uVar10 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar17 = 0;
    uVar18 = 0;
    uVar19 = 0;
    uVar48 = 0;
    local_94c = uVar13;
    local_8bc = uVar12;
    uVar12 = 0;
    uVar43 = 0;
    uVar41 = 0;
    uVar40 = 0;
    uVar37 = 0;
    uVar11 = 0;
  }
  else {
    uVar4 = (ulong)local_934;
    local_118c = (uint)local_8fc;
    local_952 = local_8f9;
    local_954 = local_8fb;
    local_956 = local_8e5;
    local_958 = local_8e7;
    uVar32 = (uint)local_8d4;
    local_95a = local_8d1;
    local_95c = local_8d3;
    uVar22 = (uint)local_884;
    local_95e = local_881;
    local_960 = local_883;
    uVar30 = (uint)local_870;
    local_962 = local_86d;
    local_964 = local_86f;
    uVar33 = (uint)local_85c;
    local_966 = local_859;
    local_968 = local_85b;
    uVar9 = local_8dc;
    uVar10 = local_8e4;
    uVar15 = local_88c;
    uVar16 = local_894;
    uVar17 = local_90c;
    uVar18 = local_858;
    uVar19 = local_8a8;
    uVar48 = local_848;
    uVar12 = local_8a0;
    uVar43 = local_89c;
    uVar41 = local_898;
    uVar40 = local_850;
    uVar37 = local_84c;
    uVar11 = local_844;
  }
  local_1130 = CONCAT44(local_1130._4_4_,local_950);
  local_1138 = CONCAT44(local_1138._4_4_,local_94c);
  local_1158 = CONCAT44(local_1158._4_4_,local_938);
  local_2ac = (undefined4)uVar4;
  local_1160 = CONCAT44(local_1160._4_4_,local_2ac);
  local_1180 = CONCAT44(local_1180._4_4_,local_918);
  local_274 = (undefined1)local_118c;
  local_271 = local_952;
  local_273 = local_954;
  local_260 = 0;
  local_25f = local_958;
  local_25d = local_956;
  local_1128 = CONCAT44(local_1128._4_4_,uVar32);
  local_24c = (undefined1)uVar32;
  local_24b = local_95c;
  local_249 = local_95a;
  local_1100 = CONCAT44(local_1100._4_4_,local_8c0);
  local_10f8 = CONCAT44(local_10f8._4_4_,local_8bc);
  local_1108 = CONCAT44(local_1108._4_4_,uVar22);
  local_1fc = (undefined1)uVar22;
  local_1f9 = local_95e;
  local_1fb = local_960;
  local_1118 = CONCAT44(local_1118._4_4_,uVar30);
  local_1e8 = (undefined1)uVar30;
  local_1e5 = local_962;
  local_1e7 = local_964;
  local_1140 = CONCAT44(local_1140._4_4_,uVar33);
  local_1d4 = (undefined1)uVar33;
  local_1d1 = local_966;
  local_1d3 = local_968;
  puVar6 = &local_2c8;
  local_1188 = local_910;
  local_1184 = local_914;
  local_1178 = local_920;
  local_1170 = local_928;
  local_1168 = local_930;
  local_1150 = local_940;
  local_1148 = local_948;
  local_1120 = local_8d0;
  local_1110 = local_8c8;
  local_10f0 = local_8b8;
  local_10e8 = local_8b0;
  local_10e0 = local_904;
  local_10d8 = local_86c;
  local_10a8 = local_864;
  local_10a0 = local_880;
  local_1098 = local_878;
  local_2c8 = local_950;
  local_2c4 = local_94c;
  local_2c0 = local_948;
  local_2b8 = local_940;
  local_2b0 = local_938;
  local_2a8 = local_930;
  local_2a0 = local_928;
  local_298 = local_920;
  local_290 = local_918;
  local_28c = local_914;
  local_288 = local_910;
  local_284 = uVar17;
  local_27c = local_904;
  local_270 = CONCAT44(uVar45,uVar24);
  local_268 = CONCAT44(uVar39,uVar47);
  local_25c = uVar10;
  local_254 = uVar9;
  local_248 = local_8d0;
  local_240 = local_8c8;
  local_238 = local_8c0;
  local_234 = local_8bc;
  local_230 = local_8b8;
  local_228 = local_8b0;
  local_220 = uVar19;
  local_218 = uVar12;
  local_214 = uVar43;
  local_210 = uVar41;
  local_20c = uVar16;
  local_204 = uVar15;
  local_1f8 = local_880;
  local_1f0 = local_878;
  local_1e4 = local_86c;
  local_1dc = local_864;
  local_1d0 = uVar18;
  local_1c8 = uVar40;
  local_1c4 = uVar37;
  local_1c0 = uVar48;
  local_1bc = uVar11;
  FUN_195ed8068(puVar6,local_5f8);
  if (((ulong)puVar6 & 1) == 0) {
    local_3d8 = (undefined4)local_1130;
    local_3d4 = (undefined4)local_1138;
    local_3d0 = local_1148;
    local_3c8 = local_1150;
    local_3c0 = (undefined4)local_1158;
    local_3bc = (undefined4)local_1160;
    local_3b8 = local_1168;
    local_3b0 = local_1170;
    local_3a8 = local_1178;
    local_3a0 = (undefined4)local_1180;
    local_39c = local_1184;
    local_398 = local_1188;
    local_38c = local_10e0;
    local_384 = (undefined1)local_118c;
    local_383 = local_954;
    local_381 = local_952;
    local_370 = 0;
    local_36f = local_958;
    local_36d = local_956;
    local_35c = (undefined1)local_1128;
    local_35b = local_95c;
    local_359 = local_95a;
    local_358 = local_1120;
    local_350 = local_1110;
    local_348 = (undefined4)local_1100;
    local_344 = (undefined4)local_10f8;
    local_340 = local_10f0;
    local_338 = local_10e8;
    local_30c = (undefined1)local_1108;
    local_309 = local_95e;
    local_30b = local_960;
    local_308 = local_10a0;
    local_300 = local_1098;
    local_2f8 = (undefined1)local_1118;
    local_2f5 = local_962;
    local_2f7 = local_964;
    local_2f4 = local_10d8;
    local_2ec = local_10a8;
    local_2e4 = (undefined1)local_1140;
    local_2e1 = local_966;
    local_2e3 = local_968;
    local_394 = uVar17;
    local_380 = CONCAT44(uVar45,uVar24);
    local_378 = CONCAT44(uVar39,uVar47);
    local_36c = uVar10;
    local_364 = uVar9;
    local_330 = uVar19;
    local_328 = uVar12;
    local_324 = uVar43;
    local_320 = uVar41;
    local_31c = uVar16;
    local_314 = uVar15;
    local_2e0 = uVar18;
    local_2d8 = uVar40;
    local_2d4 = uVar37;
    local_2d0 = uVar48;
    local_2cc = uVar11;
    _CGPointMake(&local_3d8);
    func_0x000198104610(auStack_a78,&local_3d8,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_a78);
  }
  uVar26 = local_10d0 & 6;
  func_0x000198104610(local_1090 + 0x1e8,auStack_a78,0x10d);
  lVar7 = 0;
  FUN_195f3c68c();
  uVar23 = local_10b0;
  lVar5 = local_10c0;
  puVar1 = local_10c8;
  iVar3 = *(int *)(lVar7 + 0x18);
  puVar8 = local_10c8;
  (**(code **)(local_10c0 + 0x68))(local_10c8,*_DAT_1e017dd58,local_10b0);
  FUN_195e7d9c0();
  uVar4 = local_10b8 + iVar3;
  func_0x0001980ff320(uVar4,puVar1,uVar23,puVar8);
  puVar31 = (undefined8 *)(lVar5 + 8);
  (*(code *)*puVar31)(puVar1,uVar23);
  bVar2 = uVar26 != 2;
  uVar24 = (undefined4)uVar4;
  if ((uVar4 & 1) == 0) {
    if (bVar2) {
      func_0x000198104610(&local_b88,local_1090 + 0x1e8,0x10d);
      iVar3 = (int)&local_b88;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        local_ab8 = 0;
        local_aa4 = 0;
        local_a9c = 0;
        uVar13 = 0;
        local_ad8 = 0;
        uVar22 = 1;
        local_ad4 = 0;
        uVar30 = 1;
        uVar32 = 1;
        local_ad0 = 0;
        uVar33 = 1;
        local_a90 = 0;
        uVar34 = 1;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_a88 = 0;
        local_a84 = 0;
        local_a80 = 0;
        local_b88 = 0;
        local_b80 = 0;
        local_b78 = 0;
        local_b70 = 0;
        local_b68 = 0;
        local_b60 = 0;
        local_b58 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar4 = 0;
        uVar15 = 0;
        uVar26 = 0;
        uVar16 = 0;
        uVar25 = 0;
        uVar27 = 0;
        uVar28 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        local_b6c = uVar24;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
      }
      else {
        uVar23 = (ulong)local_b84;
        uVar22 = (uint)local_b34;
        local_ffc = local_b33;
        local_ffa = local_b31;
        uVar30 = (uint)local_b20;
        local_ffe = local_b1d;
        local_1000 = local_b1f;
        uVar32 = (uint)local_b0c;
        local_1002 = local_b09;
        local_1004 = local_b0b;
        puVar31 = (undefined8 *)(ulong)local_af4;
        uVar33 = (uint)local_abc;
        local_1006 = local_ab9;
        local_1008 = local_abb;
        uVar34 = (uint)local_aa8;
        local_100a = local_aa5;
        local_100c = local_aa7;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_a94);
        local_100e = local_a91;
        local_1010 = local_a93;
        uVar13 = (uint)local_a7c;
        uVar9 = local_ac4;
        uVar10 = local_ab0;
        uVar4 = local_b44;
        uVar15 = local_b3c;
        uVar26 = local_b30;
        uVar16 = local_b28;
        uVar25 = local_b1c;
        uVar27 = local_b14;
        uVar28 = local_acc;
        uVar17 = local_b08;
        uVar18 = local_b00;
        uVar19 = local_af0;
        uVar20 = local_ae8;
        uVar21 = local_ae0;
        uVar24 = local_b4c;
        uVar45 = local_b48;
        uVar47 = local_af8;
      }
      local_1100 = CONCAT44(local_1100._4_4_,local_b88);
      local_3d4 = (undefined4)uVar23;
      local_1108 = CONCAT44(local_1108._4_4_,local_3d4);
      local_1120 = CONCAT44(local_1120._4_4_,local_b70);
      local_1128 = CONCAT44(local_1128._4_4_,local_b6c);
      local_3a0 = 0.05f;
      local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
      local_384 = (undefined1)uVar22;
      local_381 = local_ffa;
      local_383 = local_ffc;
      local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
      local_370 = (undefined1)uVar30;
      local_36f = local_1000;
      local_36d = local_ffe;
      local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
      local_35c = (undefined1)uVar32;
      local_35b = local_1004;
      local_359 = local_1002;
      local_344 = SUB84(puVar31,0);
      local_10e8 = CONCAT44(local_10e8._4_4_,local_344);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_ad8);
      local_10e0 = CONCAT44(local_10e0._4_4_,local_ad4);
      local_10f0 = CONCAT44(local_10f0._4_4_,local_ad0);
      local_10f8 = CONCAT44(local_10f8._4_4_,uVar33);
      local_30c = (undefined1)uVar33;
      local_309 = local_1006;
      local_30b = local_1008;
      local_1140 = CONCAT44(local_1140._4_4_,uVar34);
      local_2f8 = (undefined1)uVar34;
      local_2f5 = local_100a;
      local_2f7 = local_100c;
      local_2e4 = (undefined1)local_1098;
      local_2e1 = local_100e;
      local_2e3 = local_1010;
      local_1158 = CONCAT44(local_1158._4_4_,local_a88);
      local_1160 = CONCAT44(local_1160._4_4_,local_a84);
      local_1168 = CONCAT44(local_1168._4_4_,local_a80);
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_2cc = (undefined1)uVar13;
      puVar6 = &local_3d8;
      local_1150 = local_a90;
      local_1148 = local_b58;
      local_1138 = local_b60;
      local_1130 = local_b68;
      local_1118 = local_b78;
      local_1110 = local_b80;
      local_10b0 = local_a9c;
      local_10a8 = local_aa4;
      local_10a0 = local_ab8;
      local_3d8 = local_b88;
      local_3d0 = local_b80;
      local_3c8 = local_b78;
      local_3c0 = local_b70;
      local_3bc = local_b6c;
      local_3b8 = local_b68;
      local_3b0 = local_b60;
      local_3a8 = local_b58;
      local_39c = uVar24;
      local_398 = uVar45;
      local_394 = uVar4;
      local_38c = uVar15;
      local_380 = uVar26;
      local_378 = uVar16;
      local_36c = uVar25;
      local_364 = uVar27;
      local_358 = uVar17;
      local_350 = uVar18;
      local_348 = uVar47;
      local_340 = uVar19;
      local_338 = uVar20;
      local_330 = uVar21;
      local_328 = local_ad8;
      local_324 = local_ad4;
      local_320 = local_ad0;
      local_31c = uVar28;
      local_314 = uVar9;
      local_308 = local_ab8;
      local_300 = uVar10;
      local_2f4 = local_aa4;
      local_2ec = local_a9c;
      local_2e0 = local_a90;
      local_2d8 = local_a88;
      local_2d4 = local_a84;
      local_2d0 = local_a80;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) == 0) {
        local_4e8 = (undefined4)local_1100;
        local_4e4 = (undefined4)local_1108;
        local_4e0 = local_1110;
        local_4d8 = local_1118;
        local_4d0 = (undefined4)local_1120;
        local_4cc = (undefined4)local_1128;
        local_4c8 = local_1130;
        local_4c0 = local_1138;
        local_4b8 = local_1148;
        local_4b0 = 0.05f;
        local_494 = (undefined1)local_10c0;
        local_493 = local_ffc;
        local_491 = local_ffa;
        local_480 = SUB81(local_10c8,0);
        local_47d = local_ffe;
        local_47f = local_1000;
        local_46c = (undefined1)local_10d8;
        local_469 = local_1002;
        local_46b = local_1004;
        local_454 = (undefined4)local_10e8;
        local_438 = (undefined4)local_10d0;
        local_434 = (undefined4)local_10e0;
        local_430 = (undefined4)local_10f0;
        local_41c = (undefined1)local_10f8;
        local_419 = local_1006;
        local_41b = local_1008;
        local_418 = local_10a0;
        local_408 = (undefined1)local_1140;
        local_405 = local_100a;
        local_407 = local_100c;
        local_404 = local_10a8;
        local_3fc = local_10b0;
        local_3f4 = (undefined1)local_1098;
        local_3f1 = local_100e;
        local_3f3 = local_1010;
        local_3f0 = local_1150;
        local_3e8 = (undefined4)local_1158;
        local_3e4 = (undefined4)local_1160;
        local_3e0 = (undefined4)local_1168;
        local_3dc = (byte)local_10b8;
        local_4ac = uVar24;
        local_4a8 = uVar45;
        local_4a4 = uVar4;
        local_49c = uVar15;
        local_490 = uVar26;
        local_488 = uVar16;
        local_47c = uVar25;
        local_474 = uVar27;
        local_468 = uVar17;
        local_460 = uVar18;
        local_458 = uVar47;
        local_450 = uVar19;
        local_448 = uVar20;
        local_440 = uVar21;
        local_42c = uVar28;
        local_424 = uVar9;
        local_410 = uVar10;
        _CGPointMake(&local_4e8);
        func_0x000198104610(auStack_cb0,&local_4e8,0x10d);
      }
      else {
        FUN_195e7d8d4(auStack_cb0);
      }
      func_0x000198104610(local_1090 + 0x1e8,auStack_cb0,0x10d);
      func_0x000198104610(&local_dc0,auStack_cb0,0x10d);
      iVar3 = (int)&local_dc0;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        uVar13 = 0;
        local_cd4 = 0;
        local_cdc = 0;
        local_cf0 = 0;
        local_d20 = 0;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_d28 = 0;
        uVar35 = 1;
        uVar30 = 1;
        local_d30 = 0;
        local_d38 = 0;
        local_d40 = 0;
        uVar34 = 1;
        uVar33 = 1;
        uVar32 = 1;
        local_d80 = 0;
        local_dc0 = 0;
        local_db8 = 0;
        local_db0 = 0;
        local_da8 = 0;
        local_da0 = 0;
        local_d98 = 0;
        local_d90 = 0;
        local_d88 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar15 = 0;
        uVar16 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        uVar36 = 0;
        uVar38 = 0;
        local_d2c = uVar22;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
        uVar12 = 0;
        uVar39 = 0;
        uVar48 = 0;
      }
      else {
        uVar27 = (ulong)local_dbc;
        uVar28 = (ulong)local_da4;
        uVar32 = (uint)local_d6c;
        local_1014 = local_d6b;
        local_1012 = local_d69;
        uVar33 = (uint)local_d58;
        local_1016 = local_d55;
        local_1018 = local_d57;
        uVar34 = (uint)local_d44;
        local_101a = local_d41;
        local_101c = local_d43;
        uVar30 = (uint)local_cf4;
        local_101e = local_cf1;
        local_1020 = local_cf3;
        uVar35 = (uint)local_ce0;
        local_1022 = local_cdd;
        local_1024 = local_cdf;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_ccc);
        local_1026 = local_cc9;
        local_1028 = local_ccb;
        uVar13 = (uint)local_cb4;
        uVar9 = local_d04;
        uVar10 = local_ce8;
        uVar15 = local_d74;
        uVar16 = local_d7c;
        uVar17 = local_d60;
        uVar18 = local_d68;
        uVar19 = local_d4c;
        uVar20 = local_d54;
        uVar21 = local_cfc;
        uVar36 = local_cc8;
        uVar38 = local_d18;
        uVar24 = local_d10;
        uVar45 = local_d0c;
        uVar47 = local_d08;
        uVar12 = local_cc0;
        uVar39 = local_cbc;
        uVar48 = local_cb8;
      }
      local_1120 = CONCAT44(local_1120._4_4_,local_dc0);
      local_4e4 = (undefined4)uVar27;
      local_1128 = CONCAT44(local_1128._4_4_,local_4e4);
      local_1140 = CONCAT44(local_1140._4_4_,local_da8);
      local_4cc = (undefined4)uVar28;
      local_1148 = CONCAT44(local_1148._4_4_,local_4cc);
      local_1168 = CONCAT44(local_1168._4_4_,local_d88);
      local_4ac = 0.35f;
      local_1118 = CONCAT44(local_1118._4_4_,local_d80);
      local_1108 = CONCAT44(local_1108._4_4_,uVar32);
      local_494 = (undefined1)uVar32;
      local_491 = local_1012;
      local_493 = local_1014;
      local_1100 = CONCAT44(local_1100._4_4_,uVar33);
      local_480 = (undefined1)uVar33;
      local_47f = local_1018;
      local_47d = local_1016;
      local_10f8 = CONCAT44(local_10f8._4_4_,uVar34);
      local_46c = (undefined1)uVar34;
      local_46b = local_101c;
      local_469 = local_101a;
      local_10d8 = CONCAT44(local_10d8._4_4_,local_d30);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_d2c);
      local_10e0 = CONCAT44(local_10e0._4_4_,uVar30);
      local_41c = (undefined1)uVar30;
      local_419 = local_101e;
      local_41b = local_1020;
      local_1110 = CONCAT44(local_1110._4_4_,uVar35);
      local_408 = (undefined1)uVar35;
      local_405 = local_1022;
      local_407 = local_1024;
      local_3f4 = (undefined1)local_1098;
      local_3f1 = local_1026;
      local_3f3 = local_1028;
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_3dc = (byte)uVar13;
      puVar6 = &local_4e8;
      local_1160 = local_d90;
      local_1158 = local_d98;
      local_1150 = local_da0;
      local_1138 = local_db0;
      local_1130 = local_db8;
      local_10f0 = local_d40;
      local_10e8 = local_d38;
      local_10c8 = (undefined1 *)local_d28;
      local_10c0 = local_d20;
      local_10b0 = local_cdc;
      local_10a8 = local_cd4;
      local_10a0 = local_cf0;
      local_4e8 = local_dc0;
      local_4e0 = local_db8;
      local_4d8 = local_db0;
      local_4d0 = local_da8;
      local_4c8 = local_da0;
      local_4c0 = local_d98;
      local_4b8 = local_d90;
      local_4b0 = local_d88;
      local_4a8 = local_d80;
      local_4a4 = uVar16;
      local_49c = uVar15;
      local_490 = uVar18;
      local_488 = uVar17;
      local_47c = uVar20;
      local_474 = uVar19;
      local_468 = local_d40;
      local_460 = local_d38;
      local_458 = local_d30;
      local_454 = local_d2c;
      local_450 = local_d28;
      local_448 = local_d20;
      local_440 = uVar38;
      local_438 = uVar24;
      local_434 = uVar45;
      local_430 = uVar47;
      local_42c = uVar9;
      local_424 = uVar21;
      local_418 = local_cf0;
      local_410 = uVar10;
      local_404 = local_cdc;
      local_3fc = local_cd4;
      local_3f0 = uVar36;
      local_3e8 = uVar12;
      local_3e4 = uVar39;
      local_3e0 = uVar48;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) != 0) goto LAB_195f2a14c;
      local_ff8 = (undefined4)local_1120;
      local_ff4 = (undefined4)local_1128;
      local_ff0 = local_1130;
      uStack_fe8 = local_1138;
      local_fe0 = (undefined4)local_1140;
      local_fdc = (undefined4)local_1148;
      local_fd8 = local_1150;
      uStack_fd0 = local_1158;
      local_fc8 = local_1160;
      local_fc0 = (undefined4)local_1168;
      local_fbc = 0.35f;
      local_fb8 = (undefined4)local_1118;
      local_fa4 = (undefined1)local_1108;
      local_fa3 = local_1014;
      local_fa1 = local_1012;
      local_f90 = (undefined1)local_1100;
      local_f8d = local_1016;
      local_f8f = local_1018;
      local_f7c = (undefined1)local_10f8;
      local_f79 = local_101a;
      local_f7b = local_101c;
      local_f78 = local_10f0;
      local_f70 = local_10e8;
      local_f68 = (undefined4)local_10d8;
      local_f64 = (undefined4)local_10d0;
      local_f60 = local_10c8;
      local_f58 = local_10c0;
      local_f2c = (undefined1)local_10e0;
      local_f29 = local_101e;
      local_f2b = local_1020;
      local_f28 = local_10a0;
      local_f18 = (undefined1)local_1110;
      local_f15 = local_1022;
      local_f17 = local_1024;
      local_f14 = local_10b0;
      local_f0c = local_10a8;
      local_f04 = (undefined1)local_1098;
      local_f01 = local_1026;
      local_f03 = local_1028;
      local_fb4 = uVar16;
      local_fac = uVar15;
      local_fa0 = uVar18;
      local_f98 = uVar17;
      local_f8c = uVar20;
      local_f84 = uVar19;
      local_f50 = uVar38;
      local_f48 = uVar24;
      local_f44 = uVar45;
      local_f40 = uVar47;
      local_f3c = uVar9;
      local_f34 = uVar21;
      local_f20 = uVar10;
      local_f00 = uVar36;
      local_ef8 = uVar12;
      local_ef4 = uVar39;
      local_ef0 = uVar48;
      goto LAB_195f2a2c0;
    }
    func_0x000198104610(&local_b88,local_1090 + 0x1e8,0x10d);
    iVar3 = (int)&local_b88;
    FUN_195e7d8c0();
    if (iVar3 == 1) {
      local_ab0 = 0;
      local_aa4 = 0;
      local_a9c = 0;
      uVar13 = 0;
      local_ad8 = 0;
      uVar22 = 1;
      local_ad4 = 0;
      uVar30 = 1;
      uVar32 = 1;
      local_ad0 = 0;
      uVar33 = 1;
      local_a90 = 0;
      uVar34 = 1;
      local_1098 = CONCAT44(local_1098._4_4_,1);
      local_a88 = 0;
      local_a84 = 0;
      local_a80 = 0;
      local_b88 = 0;
      local_b80 = 0;
      local_b78 = 0;
      local_b70 = 0;
      local_b68 = 0;
      local_b60 = 0;
      local_b58 = 0;
      uVar9 = 0;
      uVar10 = 0;
      uVar4 = 0;
      uVar15 = 0;
      uVar26 = 0;
      uVar16 = 0;
      uVar25 = 0;
      uVar27 = 0;
      uVar28 = 0;
      uVar29 = uVar23;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      local_b6c = uVar24;
      uVar24 = 0;
      uVar45 = 0;
      uVar47 = 0;
    }
    else {
      uVar23 = (ulong)local_b84;
      uVar22 = (uint)local_b34;
      local_b8c = local_b33;
      local_b8a = local_b31;
      uVar30 = (uint)local_b20;
      local_b8e = local_b1d;
      local_b90 = local_b1f;
      uVar32 = (uint)local_b0c;
      local_b92 = local_b09;
      local_b94 = local_b0b;
      uVar29 = (ulong)local_af4;
      uVar33 = (uint)local_abc;
      local_b96 = local_ab9;
      local_b98 = local_abb;
      uVar34 = (uint)local_aa8;
      local_b9a = local_aa5;
      local_b9c = local_aa7;
      local_1098 = CONCAT44(local_1098._4_4_,(uint)local_a94);
      local_b9e = local_a91;
      local_ba0 = local_a93;
      uVar13 = (uint)local_a7c;
      uVar9 = local_ac4;
      uVar10 = local_ab8;
      uVar4 = local_b44;
      uVar15 = local_b3c;
      uVar26 = local_b30;
      uVar16 = local_b28;
      uVar25 = local_b1c;
      uVar27 = local_b14;
      uVar28 = local_acc;
      uVar17 = local_b08;
      uVar18 = local_b00;
      uVar19 = local_af0;
      uVar20 = local_ae8;
      uVar21 = local_ae0;
      uVar24 = local_b4c;
      uVar45 = local_b48;
      uVar47 = local_af8;
    }
    local_1100 = CONCAT44(local_1100._4_4_,local_b88);
    local_3d4 = (undefined4)uVar23;
    local_1108 = CONCAT44(local_1108._4_4_,local_3d4);
    local_1120 = CONCAT44(local_1120._4_4_,local_b70);
    local_1128 = CONCAT44(local_1128._4_4_,local_b6c);
    local_3a0 = 0;
    local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
    local_384 = (undefined1)uVar22;
    local_381 = local_b8a;
    local_383 = local_b8c;
    local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
    local_370 = (undefined1)uVar30;
    local_36f = local_b90;
    local_36d = local_b8e;
    local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
    local_35c = (undefined1)uVar32;
    local_35b = local_b94;
    local_359 = local_b92;
    local_344 = (undefined4)uVar29;
    local_10e8 = CONCAT44(local_10e8._4_4_,local_344);
    local_10d0 = CONCAT44(local_10d0._4_4_,local_ad8);
    local_10e0 = CONCAT44(local_10e0._4_4_,local_ad4);
    local_10f0 = CONCAT44(local_10f0._4_4_,local_ad0);
    local_10f8 = CONCAT44(local_10f8._4_4_,uVar33);
    local_30c = (undefined1)uVar33;
    local_309 = local_b96;
    local_30b = local_b98;
    local_1138 = CONCAT44(local_1138._4_4_,uVar34);
    local_2f8 = (undefined1)uVar34;
    local_2f5 = local_b9a;
    local_2f7 = local_b9c;
    local_2e4 = (undefined1)local_1098;
    local_2e1 = local_b9e;
    local_2e3 = local_ba0;
    local_1158 = CONCAT44(local_1158._4_4_,local_a88);
    local_1160 = CONCAT44(local_1160._4_4_,local_a84);
    local_1168 = CONCAT44(local_1168._4_4_,local_a80);
    local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
    local_2cc = (undefined1)uVar13;
    puVar6 = &local_3d8;
    local_1150 = local_a90;
    local_1148 = local_b58;
    local_1140 = local_b60;
    local_1130 = local_b68;
    local_1118 = local_b78;
    local_1110 = local_b80;
    local_10b0 = local_a9c;
    local_10a8 = local_aa4;
    local_10a0 = local_ab0;
    local_3d8 = local_b88;
    local_3d0 = local_b80;
    local_3c8 = local_b78;
    local_3c0 = local_b70;
    local_3bc = local_b6c;
    local_3b8 = local_b68;
    local_3b0 = local_b60;
    local_3a8 = local_b58;
    local_39c = uVar24;
    local_398 = uVar45;
    local_394 = uVar4;
    local_38c = uVar15;
    local_380 = uVar26;
    local_378 = uVar16;
    local_36c = uVar25;
    local_364 = uVar27;
    local_358 = uVar17;
    local_350 = uVar18;
    local_348 = uVar47;
    local_340 = uVar19;
    local_338 = uVar20;
    local_330 = uVar21;
    local_328 = local_ad8;
    local_324 = local_ad4;
    local_320 = local_ad0;
    local_31c = uVar28;
    local_314 = uVar9;
    local_308 = uVar10;
    local_300 = local_ab0;
    local_2f4 = local_aa4;
    local_2ec = local_a9c;
    local_2e0 = local_a90;
    local_2d8 = local_a88;
    local_2d4 = local_a84;
    local_2d0 = local_a80;
    FUN_195ed8068(puVar6,local_5f8);
    if (((ulong)puVar6 & 1) == 0) {
      local_4e8 = (undefined4)local_1100;
      local_4e4 = (undefined4)local_1108;
      local_4e0 = local_1110;
      local_4d8 = local_1118;
      local_4d0 = (undefined4)local_1120;
      local_4cc = (undefined4)local_1128;
      local_4c8 = local_1130;
      local_4c0 = local_1140;
      local_4b8 = local_1148;
      local_4b0 = 0;
      local_494 = (undefined1)local_10c0;
      local_493 = local_b8c;
      local_491 = local_b8a;
      local_480 = SUB81(local_10c8,0);
      local_47d = local_b8e;
      local_47f = local_b90;
      local_46c = (undefined1)local_10d8;
      local_469 = local_b92;
      local_46b = local_b94;
      local_454 = (undefined4)local_10e8;
      local_438 = (undefined4)local_10d0;
      local_434 = (undefined4)local_10e0;
      local_430 = (undefined4)local_10f0;
      local_41c = (undefined1)local_10f8;
      local_419 = local_b96;
      local_41b = local_b98;
      local_410 = local_10a0;
      local_408 = (undefined1)local_1138;
      local_405 = local_b9a;
      local_407 = local_b9c;
      local_404 = local_10a8;
      local_3fc = local_10b0;
      local_3f4 = (undefined1)local_1098;
      local_3f1 = local_b9e;
      local_3f3 = local_ba0;
      local_3f0 = local_1150;
      local_3e8 = (undefined4)local_1158;
      local_3e4 = (undefined4)local_1160;
      local_3e0 = (undefined4)local_1168;
      local_3dc = (byte)local_10b8;
      local_4ac = uVar24;
      local_4a8 = uVar45;
      local_4a4 = uVar4;
      local_49c = uVar15;
      local_490 = uVar26;
      local_488 = uVar16;
      local_47c = uVar25;
      local_474 = uVar27;
      local_468 = uVar17;
      local_460 = uVar18;
      local_458 = uVar47;
      local_450 = uVar19;
      local_448 = uVar20;
      local_440 = uVar21;
      local_42c = uVar28;
      local_424 = uVar9;
      local_418 = uVar10;
      _CGPointMake(&local_4e8);
      func_0x000198104610(auStack_cb0,&local_4e8,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_cb0);
    }
    func_0x000198104610(local_1090 + 0x1e8,auStack_cb0,0x10d);
    func_0x000198104610(&local_dc0,auStack_cb0,0x10d);
    iVar3 = (int)&local_dc0;
    FUN_195e7d8c0();
    if (iVar3 == 1) {
      local_cd4 = 0;
      local_cdc = 0;
      local_ce8 = 0;
      local_cf0 = 0;
      local_d20 = 0;
      local_1098 = CONCAT44(local_1098._4_4_,1);
      local_d28 = 0;
      uVar34 = 1;
      uVar22 = 1;
      local_d30 = 0;
      local_d38 = 0;
      local_d40 = 0;
      uVar30 = 1;
      uVar33 = 1;
      uVar32 = 1;
      local_d80 = 0;
      local_dc0 = 0;
      local_db8 = 0;
      local_db0 = 0;
      local_da8 = 0;
      local_da0 = 0;
      local_d98 = 0;
      local_d90 = 0;
      local_d88 = 0;
      uVar9 = 0;
      uVar10 = 0;
      uVar15 = 0;
      uVar16 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      uVar36 = 0;
      bVar14 = 0;
      local_d2c = uVar13;
      uVar24 = 0;
      uVar45 = 0;
      uVar47 = 0;
      uVar12 = 0;
      uVar39 = 0;
      uVar48 = 0;
    }
    else {
      uVar25 = (ulong)local_dbc;
      uVar28 = (ulong)local_da4;
      uVar32 = (uint)local_d6c;
      local_dc4 = local_d6b;
      local_dc2 = local_d69;
      uVar33 = (uint)local_d58;
      local_dc6 = local_d55;
      local_dc8 = local_d57;
      uVar30 = (uint)local_d44;
      local_dca = local_d41;
      local_dcc = local_d43;
      uVar22 = (uint)local_cf4;
      local_dce = local_cf1;
      local_dd0 = local_cf3;
      uVar34 = (uint)local_ce0;
      local_dd2 = local_cdd;
      local_dd4 = local_cdf;
      local_1098 = CONCAT44(local_1098._4_4_,(uint)local_ccc);
      local_dd6 = local_cc9;
      local_dd8 = local_ccb;
      uVar9 = local_d04;
      uVar10 = local_d74;
      uVar15 = local_d7c;
      uVar16 = local_d60;
      uVar17 = local_d68;
      uVar18 = local_d4c;
      uVar19 = local_d54;
      uVar20 = local_cfc;
      uVar21 = local_cc8;
      uVar36 = local_d18;
      bVar14 = local_cb4;
      uVar24 = local_d10;
      uVar45 = local_d0c;
      uVar47 = local_d08;
      uVar12 = local_cc0;
      uVar39 = local_cbc;
      uVar48 = local_cb8;
    }
    local_1120 = CONCAT44(local_1120._4_4_,local_dc0);
    local_4e4 = (undefined4)uVar25;
    local_1128 = CONCAT44(local_1128._4_4_,local_4e4);
    local_1140 = CONCAT44(local_1140._4_4_,local_da8);
    local_4cc = (undefined4)uVar28;
    local_1148 = CONCAT44(local_1148._4_4_,local_4cc);
    local_1168 = CONCAT44(local_1168._4_4_,local_d88);
    local_4ac = 0.05f;
    local_1118 = CONCAT44(local_1118._4_4_,local_d80);
    local_1108 = CONCAT44(local_1108._4_4_,uVar32);
    local_494 = (undefined1)uVar32;
    local_491 = local_dc2;
    local_493 = local_dc4;
    local_1100 = CONCAT44(local_1100._4_4_,uVar33);
    local_480 = (undefined1)uVar33;
    local_47f = local_dc8;
    local_47d = local_dc6;
    local_10f8 = CONCAT44(local_10f8._4_4_,uVar30);
    local_46c = (undefined1)uVar30;
    local_46b = local_dcc;
    local_469 = local_dca;
    local_10d8 = CONCAT44(local_10d8._4_4_,local_d30);
    local_10d0 = CONCAT44(local_10d0._4_4_,local_d2c);
    local_10e0 = CONCAT44(local_10e0._4_4_,uVar22);
    local_41c = (undefined1)uVar22;
    local_419 = local_dce;
    local_41b = local_dd0;
    local_1110 = CONCAT44(local_1110._4_4_,uVar34);
    local_408 = (undefined1)uVar34;
    local_405 = local_dd2;
    local_407 = local_dd4;
    local_3f4 = (undefined1)local_1098;
    local_3f1 = local_dd6;
    local_3f3 = local_dd8;
    puVar6 = &local_4e8;
    local_1160 = local_d90;
    local_1158 = local_d98;
    local_1150 = local_da0;
    local_1138 = local_db0;
    local_1130 = local_db8;
    local_10f0 = local_d40;
    local_10e8 = local_d38;
    local_10c8 = (undefined1 *)local_d28;
    local_10c0 = local_d20;
    local_10b8 = local_cdc;
    local_10b0 = local_cd4;
    local_10a8 = local_cf0;
    local_10a0 = local_ce8;
    local_4e8 = local_dc0;
    local_4e0 = local_db8;
    local_4d8 = local_db0;
    local_4d0 = local_da8;
    local_4c8 = local_da0;
    local_4c0 = local_d98;
    local_4b8 = local_d90;
    local_4b0 = local_d88;
    local_4a8 = local_d80;
    local_4a4 = uVar15;
    local_49c = uVar10;
    local_490 = uVar17;
    local_488 = uVar16;
    local_47c = uVar19;
    local_474 = uVar18;
    local_468 = local_d40;
    local_460 = local_d38;
    local_458 = local_d30;
    local_454 = local_d2c;
    local_450 = local_d28;
    local_448 = local_d20;
    local_440 = uVar36;
    local_438 = uVar24;
    local_434 = uVar45;
    local_430 = uVar47;
    local_42c = uVar9;
    local_424 = uVar20;
    local_418 = local_cf0;
    local_410 = local_ce8;
    local_404 = local_cdc;
    local_3fc = local_cd4;
    local_3f0 = uVar21;
    local_3e8 = uVar12;
    local_3e4 = uVar39;
    local_3e0 = uVar48;
    local_3dc = bVar14;
    FUN_195ed8068(puVar6,local_5f8);
    if (((ulong)puVar6 & 1) != 0) goto LAB_195f2a14c;
    local_ff8 = (undefined4)local_1120;
    local_ff4 = (undefined4)local_1128;
    local_ff0 = local_1130;
    uStack_fe8 = local_1138;
    local_fe0 = (undefined4)local_1140;
    local_fdc = (undefined4)local_1148;
    local_fd8 = local_1150;
    uStack_fd0 = local_1158;
    local_fc8 = local_1160;
    local_fc0 = (undefined4)local_1168;
    local_fbc = 0.05f;
    local_fb8 = (undefined4)local_1118;
    local_fa4 = (undefined1)local_1108;
    local_fa3 = local_dc4;
    local_fa1 = local_dc2;
    local_f90 = (undefined1)local_1100;
    local_f8d = local_dc6;
    local_f8f = local_dc8;
    local_f7c = (undefined1)local_10f8;
    local_f79 = local_dca;
    local_f7b = local_dcc;
    local_f78 = local_10f0;
    local_f70 = local_10e8;
    local_f68 = (undefined4)local_10d8;
    local_f64 = (undefined4)local_10d0;
    local_f60 = local_10c8;
    local_f58 = local_10c0;
    local_f2c = (undefined1)local_10e0;
    local_f29 = local_dce;
    local_f2b = local_dd0;
    local_f28 = local_10a8;
    local_f20 = local_10a0;
    local_f18 = (undefined1)local_1110;
    local_f15 = local_dd2;
    local_f17 = local_dd4;
    local_f14 = local_10b8;
    local_f0c = local_10b0;
    local_f04 = (undefined1)local_1098;
    local_f01 = local_dd6;
    local_f03 = local_dd8;
    local_fb4 = uVar15;
    local_fac = uVar10;
    local_fa0 = uVar17;
    local_f98 = uVar16;
    local_f8c = uVar19;
    local_f84 = uVar18;
    local_f50 = uVar36;
    local_f48 = uVar24;
    local_f44 = uVar45;
    local_f40 = uVar47;
    local_f3c = uVar9;
    local_f34 = uVar20;
    local_f00 = uVar21;
    local_ef8 = uVar12;
    local_ef4 = uVar39;
    local_ef0 = uVar48;
    local_eec = bVar14;
  }
  else {
    if (bVar2) {
      func_0x000198104610(&local_b88,local_1090 + 0x1e8,0x10d);
      iVar3 = (int)&local_b88;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        local_ab8 = 0;
        local_aa4 = 0;
        local_a9c = 0;
        uVar13 = 0;
        local_ad8 = 0;
        uVar22 = 1;
        local_ad4 = 0;
        uVar30 = 1;
        uVar32 = 1;
        local_ad0 = 0;
        uVar33 = 1;
        local_a90 = 0;
        uVar34 = 1;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_a88 = 0;
        local_a84 = 0;
        local_a80 = 0;
        local_b88 = 0;
        local_b80 = 0;
        local_b78 = 0;
        local_b70 = 0;
        local_b68 = 0;
        local_b60 = 0;
        local_b58 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar4 = 0;
        uVar15 = 0;
        uVar26 = 0;
        uVar16 = 0;
        uVar25 = 0;
        uVar27 = 0;
        uVar28 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        local_b6c = uVar24;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
      }
      else {
        uVar23 = (ulong)local_b84;
        uVar22 = (uint)local_b34;
        local_105c = local_b33;
        local_105a = local_b31;
        uVar30 = (uint)local_b20;
        local_105e = local_b1d;
        local_1060 = local_b1f;
        uVar32 = (uint)local_b0c;
        local_1062 = local_b09;
        local_1064 = local_b0b;
        puVar31 = (undefined8 *)(ulong)local_af4;
        uVar33 = (uint)local_abc;
        local_1066 = local_ab9;
        local_1068 = local_abb;
        uVar34 = (uint)local_aa8;
        local_106a = local_aa5;
        local_106c = local_aa7;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_a94);
        local_106e = local_a91;
        local_1070 = local_a93;
        uVar13 = (uint)local_a7c;
        uVar9 = local_ac4;
        uVar10 = local_ab0;
        uVar4 = local_b44;
        uVar15 = local_b3c;
        uVar26 = local_b30;
        uVar16 = local_b28;
        uVar25 = local_b1c;
        uVar27 = local_b14;
        uVar28 = local_acc;
        uVar17 = local_b08;
        uVar18 = local_b00;
        uVar19 = local_af0;
        uVar20 = local_ae8;
        uVar21 = local_ae0;
        uVar24 = local_b4c;
        uVar45 = local_b48;
        uVar47 = local_af8;
      }
      local_1100 = CONCAT44(local_1100._4_4_,local_b88);
      local_3d4 = (undefined4)uVar23;
      local_1108 = CONCAT44(local_1108._4_4_,local_3d4);
      local_1120 = CONCAT44(local_1120._4_4_,local_b70);
      local_1128 = CONCAT44(local_1128._4_4_,local_b6c);
      local_3a0 = 0.6f;
      local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
      local_384 = (undefined1)uVar22;
      local_381 = local_105a;
      local_383 = local_105c;
      local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
      local_370 = (undefined1)uVar30;
      local_36f = local_1060;
      local_36d = local_105e;
      local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
      local_35c = (undefined1)uVar32;
      local_35b = local_1064;
      local_359 = local_1062;
      local_344 = SUB84(puVar31,0);
      local_10e8 = CONCAT44(local_10e8._4_4_,local_344);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_ad8);
      local_10e0 = CONCAT44(local_10e0._4_4_,local_ad4);
      local_10f0 = CONCAT44(local_10f0._4_4_,local_ad0);
      local_10f8 = CONCAT44(local_10f8._4_4_,uVar33);
      local_30c = (undefined1)uVar33;
      local_309 = local_1066;
      local_30b = local_1068;
      local_1140 = CONCAT44(local_1140._4_4_,uVar34);
      local_2f8 = (undefined1)uVar34;
      local_2f5 = local_106a;
      local_2f7 = local_106c;
      local_2e4 = (undefined1)local_1098;
      local_2e1 = local_106e;
      local_2e3 = local_1070;
      local_1158 = CONCAT44(local_1158._4_4_,local_a88);
      local_1160 = CONCAT44(local_1160._4_4_,local_a84);
      local_1168 = CONCAT44(local_1168._4_4_,local_a80);
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_2cc = (undefined1)uVar13;
      puVar6 = &local_3d8;
      local_1150 = local_a90;
      local_1148 = local_b58;
      local_1138 = local_b60;
      local_1130 = local_b68;
      local_1118 = local_b78;
      local_1110 = local_b80;
      local_10b0 = local_a9c;
      local_10a8 = local_aa4;
      local_10a0 = local_ab8;
      local_3d8 = local_b88;
      local_3d0 = local_b80;
      local_3c8 = local_b78;
      local_3c0 = local_b70;
      local_3bc = local_b6c;
      local_3b8 = local_b68;
      local_3b0 = local_b60;
      local_3a8 = local_b58;
      local_39c = uVar24;
      local_398 = uVar45;
      local_394 = uVar4;
      local_38c = uVar15;
      local_380 = uVar26;
      local_378 = uVar16;
      local_36c = uVar25;
      local_364 = uVar27;
      local_358 = uVar17;
      local_350 = uVar18;
      local_348 = uVar47;
      local_340 = uVar19;
      local_338 = uVar20;
      local_330 = uVar21;
      local_328 = local_ad8;
      local_324 = local_ad4;
      local_320 = local_ad0;
      local_31c = uVar28;
      local_314 = uVar9;
      local_308 = local_ab8;
      local_300 = uVar10;
      local_2f4 = local_aa4;
      local_2ec = local_a9c;
      local_2e0 = local_a90;
      local_2d8 = local_a88;
      local_2d4 = local_a84;
      local_2d0 = local_a80;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) == 0) {
        local_4e8 = (undefined4)local_1100;
        local_4e4 = (undefined4)local_1108;
        local_4e0 = local_1110;
        local_4d8 = local_1118;
        local_4d0 = (undefined4)local_1120;
        local_4cc = (undefined4)local_1128;
        local_4c8 = local_1130;
        local_4c0 = local_1138;
        local_4b8 = local_1148;
        local_4b0 = 0.6f;
        local_494 = (undefined1)local_10c0;
        local_493 = local_105c;
        local_491 = local_105a;
        local_480 = SUB81(local_10c8,0);
        local_47d = local_105e;
        local_47f = local_1060;
        local_46c = (undefined1)local_10d8;
        local_469 = local_1062;
        local_46b = local_1064;
        local_454 = (undefined4)local_10e8;
        local_438 = (undefined4)local_10d0;
        local_434 = (undefined4)local_10e0;
        local_430 = (undefined4)local_10f0;
        local_41c = (undefined1)local_10f8;
        local_419 = local_1066;
        local_41b = local_1068;
        local_418 = local_10a0;
        local_408 = (undefined1)local_1140;
        local_405 = local_106a;
        local_407 = local_106c;
        local_404 = local_10a8;
        local_3fc = local_10b0;
        local_3f4 = (undefined1)local_1098;
        local_3f1 = local_106e;
        local_3f3 = local_1070;
        local_3f0 = local_1150;
        local_3e8 = (undefined4)local_1158;
        local_3e4 = (undefined4)local_1160;
        local_3e0 = (undefined4)local_1168;
        local_3dc = (byte)local_10b8;
        local_4ac = uVar24;
        local_4a8 = uVar45;
        local_4a4 = uVar4;
        local_49c = uVar15;
        local_490 = uVar26;
        local_488 = uVar16;
        local_47c = uVar25;
        local_474 = uVar27;
        local_468 = uVar17;
        local_460 = uVar18;
        local_458 = uVar47;
        local_450 = uVar19;
        local_448 = uVar20;
        local_440 = uVar21;
        local_42c = uVar28;
        local_424 = uVar9;
        local_410 = uVar10;
        _CGPointMake(&local_4e8);
        func_0x000198104610(auStack_cb0,&local_4e8,0x10d);
      }
      else {
        FUN_195e7d8d4(auStack_cb0);
      }
      func_0x000198104610(local_1090 + 0x1e8,auStack_cb0,0x10d);
      func_0x000198104610(&local_dc0,auStack_cb0,0x10d);
      iVar3 = (int)&local_dc0;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        local_cf0 = 0;
        local_cdc = 0;
        local_cd4 = 0;
        uVar13 = 0;
        local_d0c = 0;
        uVar22 = 1;
        local_d08 = 0;
        uVar30 = 1;
        uVar32 = 1;
        local_cc8 = 0;
        uVar33 = 1;
        local_cc0 = 0;
        uVar34 = 1;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_cbc = 0;
        local_cb8 = 0;
        local_dc0 = 0;
        local_db8 = 0;
        local_db0 = 0;
        local_da8 = 0;
        local_da0 = 0;
        local_d98 = 0;
        local_d90 = 0;
        local_d88 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar15 = 0;
        uVar16 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        uVar36 = 0;
        uVar38 = 0;
        uVar42 = 0;
        uVar44 = 0;
        uVar46 = 0;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
      }
      else {
        uVar26 = (ulong)local_dbc;
        uVar4 = (ulong)local_da4;
        uVar22 = (uint)local_d6c;
        local_1074 = local_d6b;
        local_1072 = local_d69;
        uVar30 = (uint)local_d58;
        local_1076 = local_d55;
        local_1078 = local_d57;
        uVar32 = (uint)local_d44;
        local_107a = local_d41;
        local_107c = local_d43;
        uVar27 = (ulong)local_d2c;
        uVar33 = (uint)local_cf4;
        local_107e = local_cf1;
        local_1080 = local_cf3;
        uVar34 = (uint)local_ce0;
        local_1082 = local_cdd;
        local_1084 = local_cdf;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_ccc);
        local_1086 = local_cc9;
        local_1088 = local_ccb;
        uVar13 = (uint)local_cb4;
        uVar9 = local_cfc;
        uVar10 = local_ce8;
        uVar15 = local_d7c;
        uVar16 = local_d74;
        uVar17 = local_d68;
        uVar18 = local_d60;
        uVar19 = local_d54;
        uVar20 = local_d4c;
        uVar21 = local_d04;
        uVar36 = local_d40;
        uVar38 = local_d38;
        uVar42 = local_d28;
        uVar44 = local_d20;
        uVar46 = local_d18;
        uVar24 = local_d80;
        uVar45 = local_d30;
        uVar47 = local_d10;
      }
      local_10f0 = CONCAT44(local_10f0._4_4_,local_dc0);
      local_4e4 = (undefined4)uVar26;
      local_10f8 = CONCAT44(local_10f8._4_4_,local_4e4);
      local_1110 = CONCAT44(local_1110._4_4_,local_da8);
      local_4cc = (undefined4)uVar4;
      local_1120 = CONCAT44(local_1120._4_4_,local_4cc);
      local_1148 = CONCAT44(local_1148._4_4_,local_d88);
      local_4ac = 0.93f;
      local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
      local_494 = (undefined1)uVar22;
      local_491 = local_1072;
      local_493 = local_1074;
      local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
      local_480 = (undefined1)uVar30;
      local_47f = local_1078;
      local_47d = local_1076;
      local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
      local_46c = (undefined1)uVar32;
      local_46b = local_107c;
      local_469 = local_107a;
      local_454 = (uint)uVar27;
      local_10e8 = CONCAT44(local_10e8._4_4_,local_454);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_d0c);
      local_10e0 = CONCAT44(local_10e0._4_4_,local_d08);
      local_1118 = CONCAT44(local_1118._4_4_,uVar33);
      local_41c = (undefined1)uVar33;
      local_419 = local_107e;
      local_41b = local_1080;
      local_1140 = CONCAT44(local_1140._4_4_,uVar34);
      local_408 = (undefined1)uVar34;
      local_405 = local_1082;
      local_407 = local_1084;
      local_3f4 = (undefined1)local_1098;
      local_3f1 = local_1086;
      local_3f3 = local_1088;
      local_1158 = CONCAT44(local_1158._4_4_,local_cc0);
      local_1160 = CONCAT44(local_1160._4_4_,local_cbc);
      local_1168 = CONCAT44(local_1168._4_4_,local_cb8);
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_3dc = (byte)uVar13;
      puVar6 = &local_4e8;
      local_1150 = local_cc8;
      local_1138 = local_d90;
      local_1130 = local_d98;
      local_1128 = local_da0;
      local_1108 = local_db0;
      local_1100 = local_db8;
      local_10b0 = local_cd4;
      local_10a8 = local_cdc;
      local_10a0 = local_cf0;
      local_4e8 = local_dc0;
      local_4e0 = local_db8;
      local_4d8 = local_db0;
      local_4d0 = local_da8;
      local_4c8 = local_da0;
      local_4c0 = local_d98;
      local_4b8 = local_d90;
      local_4b0 = local_d88;
      local_4a8 = uVar24;
      local_4a4 = uVar15;
      local_49c = uVar16;
      local_490 = uVar17;
      local_488 = uVar18;
      local_47c = uVar19;
      local_474 = uVar20;
      local_468 = uVar36;
      local_460 = uVar38;
      local_458 = uVar45;
      local_450 = uVar42;
      local_448 = uVar44;
      local_440 = uVar46;
      local_438 = uVar47;
      local_434 = local_d0c;
      local_430 = local_d08;
      local_42c = uVar21;
      local_424 = uVar9;
      local_418 = local_cf0;
      local_410 = uVar10;
      local_404 = local_cdc;
      local_3fc = local_cd4;
      local_3f0 = local_cc8;
      local_3e8 = local_cc0;
      local_3e4 = local_cbc;
      local_3e0 = local_cb8;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) != 0) goto LAB_195f2a14c;
      local_ff8 = (undefined4)local_10f0;
      local_ff4 = (undefined4)local_10f8;
      local_fe0 = (undefined4)local_1110;
      local_fdc = (undefined4)local_1120;
      local_fc0 = (undefined4)local_1148;
      local_fbc = 0.93f;
      local_fa4 = (undefined1)local_10c0;
      local_fa3 = local_1074;
      local_fa1 = local_1072;
      local_f90 = SUB81(local_10c8,0);
      local_f8d = local_1076;
      local_f8f = local_1078;
      local_f7c = (undefined1)local_10d8;
      local_f79 = local_107a;
      local_f7b = local_107c;
      local_f64 = (undefined4)local_10e8;
      local_f44 = (undefined4)local_10d0;
      local_f40 = (undefined4)local_10e0;
      local_f2c = (undefined1)local_1118;
      local_f29 = local_107e;
      local_f2b = local_1080;
      local_f28 = local_10a0;
      local_f18 = (undefined1)local_1140;
      local_f15 = local_1082;
      local_f17 = local_1084;
      local_f04 = (undefined1)local_1098;
      local_f01 = local_1086;
      local_f03 = local_1088;
      local_fb8 = uVar24;
      local_fb4 = uVar15;
      local_fac = uVar16;
      local_fa0 = uVar17;
      local_f98 = uVar18;
      local_f8c = uVar19;
      local_f84 = uVar20;
      local_f78 = uVar36;
      local_f70 = uVar38;
      local_f68 = uVar45;
      local_f60 = uVar42;
      local_f58 = uVar44;
      local_f50 = uVar46;
      local_f48 = uVar47;
      local_f3c = uVar21;
      local_f34 = uVar9;
      local_f20 = uVar10;
    }
    else {
      func_0x000198104610(&local_b88,local_1090 + 0x1e8,0x10d);
      iVar3 = (int)&local_b88;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        local_ab8 = 0;
        local_aa4 = 0;
        local_a9c = 0;
        uVar13 = 0;
        local_ad8 = 0;
        uVar22 = 1;
        local_ad4 = 0;
        uVar30 = 1;
        uVar32 = 1;
        local_ad0 = 0;
        uVar33 = 1;
        local_a90 = 0;
        uVar34 = 1;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_a88 = 0;
        local_a84 = 0;
        local_a80 = 0;
        local_b88 = 0;
        local_b80 = 0;
        local_b78 = 0;
        local_b70 = 0;
        local_b68 = 0;
        local_b60 = 0;
        local_b58 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar4 = 0;
        uVar15 = 0;
        uVar26 = 0;
        uVar16 = 0;
        uVar25 = 0;
        uVar27 = 0;
        uVar28 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        local_b6c = uVar24;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
      }
      else {
        uVar23 = (ulong)local_b84;
        uVar22 = (uint)local_b34;
        local_102c = local_b33;
        local_102a = local_b31;
        uVar30 = (uint)local_b20;
        local_102e = local_b1d;
        local_1030 = local_b1f;
        uVar32 = (uint)local_b0c;
        local_1032 = local_b09;
        local_1034 = local_b0b;
        puVar31 = (undefined8 *)(ulong)local_af4;
        uVar33 = (uint)local_abc;
        local_1036 = local_ab9;
        local_1038 = local_abb;
        uVar34 = (uint)local_aa8;
        local_103a = local_aa5;
        local_103c = local_aa7;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_a94);
        local_103e = local_a91;
        local_1040 = local_a93;
        uVar13 = (uint)local_a7c;
        uVar9 = local_ac4;
        uVar10 = local_ab0;
        uVar4 = local_b44;
        uVar15 = local_b3c;
        uVar26 = local_b30;
        uVar16 = local_b28;
        uVar25 = local_b1c;
        uVar27 = local_b14;
        uVar28 = local_acc;
        uVar17 = local_b08;
        uVar18 = local_b00;
        uVar19 = local_af0;
        uVar20 = local_ae8;
        uVar21 = local_ae0;
        uVar24 = local_b4c;
        uVar45 = local_b48;
        uVar47 = local_af8;
      }
      local_1100 = CONCAT44(local_1100._4_4_,local_b88);
      local_3d4 = (undefined4)uVar23;
      local_1108 = CONCAT44(local_1108._4_4_,local_3d4);
      local_1120 = CONCAT44(local_1120._4_4_,local_b70);
      local_1128 = CONCAT44(local_1128._4_4_,local_b6c);
      local_3a0 = 0.9f;
      local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
      local_384 = (undefined1)uVar22;
      local_381 = local_102a;
      local_383 = local_102c;
      local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
      local_370 = (undefined1)uVar30;
      local_36f = local_1030;
      local_36d = local_102e;
      local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
      local_35c = (undefined1)uVar32;
      local_35b = local_1034;
      local_359 = local_1032;
      local_344 = SUB84(puVar31,0);
      local_10e8 = CONCAT44(local_10e8._4_4_,local_344);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_ad8);
      local_10e0 = CONCAT44(local_10e0._4_4_,local_ad4);
      local_10f0 = CONCAT44(local_10f0._4_4_,local_ad0);
      local_10f8 = CONCAT44(local_10f8._4_4_,uVar33);
      local_30c = (undefined1)uVar33;
      local_309 = local_1036;
      local_30b = local_1038;
      local_1140 = CONCAT44(local_1140._4_4_,uVar34);
      local_2f8 = (undefined1)uVar34;
      local_2f5 = local_103a;
      local_2f7 = local_103c;
      local_2e4 = (undefined1)local_1098;
      local_2e1 = local_103e;
      local_2e3 = local_1040;
      local_1158 = CONCAT44(local_1158._4_4_,local_a88);
      local_1160 = CONCAT44(local_1160._4_4_,local_a84);
      local_1168 = CONCAT44(local_1168._4_4_,local_a80);
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_2cc = (undefined1)uVar13;
      puVar6 = &local_3d8;
      local_1150 = local_a90;
      local_1148 = local_b58;
      local_1138 = local_b60;
      local_1130 = local_b68;
      local_1118 = local_b78;
      local_1110 = local_b80;
      local_10b0 = local_a9c;
      local_10a8 = local_aa4;
      local_10a0 = local_ab8;
      local_3d8 = local_b88;
      local_3d0 = local_b80;
      local_3c8 = local_b78;
      local_3c0 = local_b70;
      local_3bc = local_b6c;
      local_3b8 = local_b68;
      local_3b0 = local_b60;
      local_3a8 = local_b58;
      local_39c = uVar24;
      local_398 = uVar45;
      local_394 = uVar4;
      local_38c = uVar15;
      local_380 = uVar26;
      local_378 = uVar16;
      local_36c = uVar25;
      local_364 = uVar27;
      local_358 = uVar17;
      local_350 = uVar18;
      local_348 = uVar47;
      local_340 = uVar19;
      local_338 = uVar20;
      local_330 = uVar21;
      local_328 = local_ad8;
      local_324 = local_ad4;
      local_320 = local_ad0;
      local_31c = uVar28;
      local_314 = uVar9;
      local_308 = local_ab8;
      local_300 = uVar10;
      local_2f4 = local_aa4;
      local_2ec = local_a9c;
      local_2e0 = local_a90;
      local_2d8 = local_a88;
      local_2d4 = local_a84;
      local_2d0 = local_a80;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) == 0) {
        local_4e8 = (undefined4)local_1100;
        local_4e4 = (undefined4)local_1108;
        local_4e0 = local_1110;
        local_4d8 = local_1118;
        local_4d0 = (undefined4)local_1120;
        local_4cc = (undefined4)local_1128;
        local_4c8 = local_1130;
        local_4c0 = local_1138;
        local_4b8 = local_1148;
        local_4b0 = 0.9f;
        local_494 = (undefined1)local_10c0;
        local_493 = local_102c;
        local_491 = local_102a;
        local_480 = SUB81(local_10c8,0);
        local_47d = local_102e;
        local_47f = local_1030;
        local_46c = (undefined1)local_10d8;
        local_469 = local_1032;
        local_46b = local_1034;
        local_454 = (undefined4)local_10e8;
        local_438 = (undefined4)local_10d0;
        local_434 = (undefined4)local_10e0;
        local_430 = (undefined4)local_10f0;
        local_41c = (undefined1)local_10f8;
        local_419 = local_1036;
        local_41b = local_1038;
        local_418 = local_10a0;
        local_408 = (undefined1)local_1140;
        local_405 = local_103a;
        local_407 = local_103c;
        local_404 = local_10a8;
        local_3fc = local_10b0;
        local_3f4 = (undefined1)local_1098;
        local_3f1 = local_103e;
        local_3f3 = local_1040;
        local_3f0 = local_1150;
        local_3e8 = (undefined4)local_1158;
        local_3e4 = (undefined4)local_1160;
        local_3e0 = (undefined4)local_1168;
        local_3dc = (byte)local_10b8;
        local_4ac = uVar24;
        local_4a8 = uVar45;
        local_4a4 = uVar4;
        local_49c = uVar15;
        local_490 = uVar26;
        local_488 = uVar16;
        local_47c = uVar25;
        local_474 = uVar27;
        local_468 = uVar17;
        local_460 = uVar18;
        local_458 = uVar47;
        local_450 = uVar19;
        local_448 = uVar20;
        local_440 = uVar21;
        local_42c = uVar28;
        local_424 = uVar9;
        local_410 = uVar10;
        _CGPointMake(&local_4e8);
        func_0x000198104610(auStack_cb0,&local_4e8,0x10d);
      }
      else {
        FUN_195e7d8d4(auStack_cb0);
      }
      func_0x000198104610(local_1090 + 0x1e8,auStack_cb0,0x10d);
      func_0x000198104610(&local_dc0,auStack_cb0,0x10d);
      iVar3 = (int)&local_dc0;
      FUN_195e7d8c0();
      if (iVar3 == 1) {
        local_ce8 = 0;
        local_cdc = 0;
        local_cd4 = 0;
        uVar13 = 0;
        local_d0c = 0;
        uVar22 = 1;
        local_d08 = 0;
        uVar30 = 1;
        uVar32 = 1;
        local_cc8 = 0;
        uVar33 = 1;
        local_cc0 = 0;
        uVar34 = 1;
        local_1098 = CONCAT44(local_1098._4_4_,1);
        local_cbc = 0;
        local_cb8 = 0;
        local_dc0 = 0;
        local_db8 = 0;
        local_db0 = 0;
        local_da8 = 0;
        local_da0 = 0;
        local_d98 = 0;
        local_d90 = 0;
        local_d88 = 0;
        uVar9 = 0;
        uVar10 = 0;
        uVar15 = 0;
        uVar16 = 0;
        uVar17 = 0;
        uVar18 = 0;
        uVar19 = 0;
        uVar20 = 0;
        uVar21 = 0;
        uVar36 = 0;
        uVar38 = 0;
        uVar42 = 0;
        uVar44 = 0;
        uVar46 = 0;
        uVar24 = 0;
        uVar45 = 0;
        uVar47 = 0;
      }
      else {
        uVar26 = (ulong)local_dbc;
        uVar4 = (ulong)local_da4;
        uVar22 = (uint)local_d6c;
        local_1044 = local_d6b;
        local_1042 = local_d69;
        uVar30 = (uint)local_d58;
        local_1046 = local_d55;
        local_1048 = local_d57;
        uVar32 = (uint)local_d44;
        local_104a = local_d41;
        local_104c = local_d43;
        uVar27 = (ulong)local_d2c;
        uVar33 = (uint)local_cf4;
        local_104e = local_cf1;
        local_1050 = local_cf3;
        uVar34 = (uint)local_ce0;
        local_1052 = local_cdd;
        local_1054 = local_cdf;
        local_1098 = CONCAT44(local_1098._4_4_,(uint)local_ccc);
        local_1056 = local_cc9;
        local_1058 = local_ccb;
        uVar13 = (uint)local_cb4;
        uVar9 = local_cfc;
        uVar10 = local_cf0;
        uVar15 = local_d7c;
        uVar16 = local_d74;
        uVar17 = local_d68;
        uVar18 = local_d60;
        uVar19 = local_d54;
        uVar20 = local_d4c;
        uVar21 = local_d04;
        uVar36 = local_d40;
        uVar38 = local_d38;
        uVar42 = local_d28;
        uVar44 = local_d20;
        uVar46 = local_d18;
        uVar24 = local_d80;
        uVar45 = local_d30;
        uVar47 = local_d10;
      }
      local_10f0 = CONCAT44(local_10f0._4_4_,local_dc0);
      local_4e4 = (undefined4)uVar26;
      local_10f8 = CONCAT44(local_10f8._4_4_,local_4e4);
      local_1110 = CONCAT44(local_1110._4_4_,local_da8);
      local_4cc = (undefined4)uVar4;
      local_1120 = CONCAT44(local_1120._4_4_,local_4cc);
      local_1148 = CONCAT44(local_1148._4_4_,local_d88);
      local_4ac = 1f;
      local_10c0 = CONCAT44(local_10c0._4_4_,uVar22);
      local_494 = (undefined1)uVar22;
      local_491 = local_1042;
      local_493 = local_1044;
      local_10c8 = (undefined1 *)CONCAT44(local_10c8._4_4_,uVar30);
      local_480 = (undefined1)uVar30;
      local_47f = local_1048;
      local_47d = local_1046;
      local_10d8 = CONCAT44(local_10d8._4_4_,uVar32);
      local_46c = (undefined1)uVar32;
      local_46b = local_104c;
      local_469 = local_104a;
      local_454 = (uint)uVar27;
      local_10e8 = CONCAT44(local_10e8._4_4_,local_454);
      local_10d0 = CONCAT44(local_10d0._4_4_,local_d0c);
      local_10e0 = CONCAT44(local_10e0._4_4_,local_d08);
      local_1118 = CONCAT44(local_1118._4_4_,uVar33);
      local_41c = (undefined1)uVar33;
      local_419 = local_104e;
      local_41b = local_1050;
      local_1140 = CONCAT44(local_1140._4_4_,uVar34);
      local_408 = (undefined1)uVar34;
      local_405 = local_1052;
      local_407 = local_1054;
      local_3f4 = (undefined1)local_1098;
      local_3f1 = local_1056;
      local_3f3 = local_1058;
      local_1158 = CONCAT44(local_1158._4_4_,local_cc0);
      local_1160 = CONCAT44(local_1160._4_4_,local_cbc);
      local_1168 = CONCAT44(local_1168._4_4_,local_cb8);
      local_10b8 = CONCAT44(local_10b8._4_4_,uVar13);
      local_3dc = (byte)uVar13;
      puVar6 = &local_4e8;
      local_1150 = local_cc8;
      local_1138 = local_d90;
      local_1130 = local_d98;
      local_1128 = local_da0;
      local_1108 = local_db0;
      local_1100 = local_db8;
      local_10b0 = local_cd4;
      local_10a8 = local_cdc;
      local_10a0 = local_ce8;
      local_4e8 = local_dc0;
      local_4e0 = local_db8;
      local_4d8 = local_db0;
      local_4d0 = local_da8;
      local_4c8 = local_da0;
      local_4c0 = local_d98;
      local_4b8 = local_d90;
      local_4b0 = local_d88;
      local_4a8 = uVar24;
      local_4a4 = uVar15;
      local_49c = uVar16;
      local_490 = uVar17;
      local_488 = uVar18;
      local_47c = uVar19;
      local_474 = uVar20;
      local_468 = uVar36;
      local_460 = uVar38;
      local_458 = uVar45;
      local_450 = uVar42;
      local_448 = uVar44;
      local_440 = uVar46;
      local_438 = uVar47;
      local_434 = local_d0c;
      local_430 = local_d08;
      local_42c = uVar21;
      local_424 = uVar9;
      local_418 = uVar10;
      local_410 = local_ce8;
      local_404 = local_cdc;
      local_3fc = local_cd4;
      local_3f0 = local_cc8;
      local_3e8 = local_cc0;
      local_3e4 = local_cbc;
      local_3e0 = local_cb8;
      FUN_195ed8068(puVar6,local_5f8);
      if (((ulong)puVar6 & 1) != 0) {
LAB_195f2a14c:
        FUN_195e7d8d4(auStack_ee8);
        goto LAB_195f2a2e0;
      }
      local_ff8 = (undefined4)local_10f0;
      local_ff4 = (undefined4)local_10f8;
      local_fe0 = (undefined4)local_1110;
      local_fdc = (undefined4)local_1120;
      local_fc0 = (undefined4)local_1148;
      local_fbc = 1f;
      local_fa4 = (undefined1)local_10c0;
      local_fa3 = local_1044;
      local_fa1 = local_1042;
      local_f90 = SUB81(local_10c8,0);
      local_f8d = local_1046;
      local_f8f = local_1048;
      local_f7c = (undefined1)local_10d8;
      local_f79 = local_104a;
      local_f7b = local_104c;
      local_f64 = (undefined4)local_10e8;
      local_f44 = (undefined4)local_10d0;
      local_f40 = (undefined4)local_10e0;
      local_f2c = (undefined1)local_1118;
      local_f29 = local_104e;
      local_f2b = local_1050;
      local_f20 = local_10a0;
      local_f18 = (undefined1)local_1140;
      local_f15 = local_1052;
      local_f17 = local_1054;
      local_f04 = (undefined1)local_1098;
      local_f01 = local_1056;
      local_f03 = local_1058;
      local_fb8 = uVar24;
      local_fb4 = uVar15;
      local_fac = uVar16;
      local_fa0 = uVar17;
      local_f98 = uVar18;
      local_f8c = uVar19;
      local_f84 = uVar20;
      local_f78 = uVar36;
      local_f70 = uVar38;
      local_f68 = uVar45;
      local_f60 = uVar42;
      local_f58 = uVar44;
      local_f50 = uVar46;
      local_f48 = uVar47;
      local_f3c = uVar21;
      local_f34 = uVar9;
      local_f28 = uVar10;
    }
    local_f00 = local_1150;
    local_ef8 = (undefined4)local_1158;
    local_ef4 = (undefined4)local_1160;
    local_ef0 = (undefined4)local_1168;
    local_ff0 = local_1100;
    uStack_fe8 = local_1108;
    local_fd8 = local_1128;
    uStack_fd0 = local_1130;
    local_fc8 = local_1138;
    local_f14 = local_10a8;
    local_f0c = local_10b0;
LAB_195f2a2c0:
    local_eec = (byte)local_10b8;
  }
  _CGPointMake(&local_ff8);
  func_0x000198104610(auStack_ee8,&local_ff8,0x10d);
LAB_195f2a2e0:
  func_0x000198104610(local_1090 + 0x1e8,auStack_ee8,0x10d);
  return;
}


//######## ScrimRecipe.anon.ScrimBlurReducedMotion (spec) 0x195f26148
// === 195f26148 spec

void FUN_195f26148(long param_1)
{
  if (<+0x191> == '\0') {
    <blur.blurRadius> = (ulong)(uint)(<blur.blurRadius> * 4.0);
    <+0x178> = 0;
    <+0x170> = 0;
    <+0x188> = 0;
    <+0x180> = 0;
    <+0x190> = 0;
  }
  else if (<+0x191> == '\x02') {
    fVar1 = (float)<+0x178> * (float){d 2};
    fVar2 = (float)((ulong)<+0x178> >> 0x20) *
            (float)((ulong){d 2} >> 0x20);
    fVar3 = fVar1;
    if (fVar1 <= fVar2) {
      fVar3 = fVar2;
    }
    <+0x178> = fVar1;
    <+0x17c> = fVar3;
    <+0x180> = <+0x180> & 0xffffffffff;
    <+0x191> = 2;
    return;
  }
  return;
}


//######## ScrimRecipe.anon.ScrimBlurReducedTransparency (spec) 0x195f261b8
// === 195f261b8 spec

void FUN_195f261b8(long param_1)
{
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = 15f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  return;
}


//######## SidebarRecipe.InactiveFaceEffect (params) 0x195f2c1ec
// === 195f2d594 params

/* WARNING: Removing unreachable block (ram,0x000195f2d670) */
/* WARNING: Removing unreachable block (ram,0x000195f2d5f8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2d594(long param_1,long param_2)
{
  undefined1 auStack_120 [8];
  lVar4 = 0;
  func_0x0001981217d0();
  lVar10 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar15 = auStack_120 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar5 = 0;
  func_0x000198120110();
  lVar11 = *(long *)(uVar5 - 8);
  uVar6 = uVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  lVar18 = (long)puVar15 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar6 & 1) == 0) {
    return;
  }
  lVar7 = 0;
  FUN_195ed0900();
  if ((*(byte *)(param_2 + *(int *)(lVar7 + 0x14)) & 0x18) != 0) {
    return;
  }
  lVar7 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar7 + 0x18);
  (**(code **)(lVar11 + 0x68))(lVar18,*_DAT_1e017dd58,uVar5);
  puVar8 = &DAT_1eda3a8e0;
  FUN_195f2dc18(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,lVar18,uVar5,puVar8);
  (**(code **)(lVar11 + 8))(lVar18,uVar5);
  (**(code **)(lVar10 + 0x68))(puVar15,*_DAT_1e01830d0,lVar4);
  if ((uVar6 & 1) == 0) {
    uVar23 = 0.2f;
    uVar9 = 1f;
    uVar21 = 1f;
    uVar22 = 1f;
    func_0x0001981218c0(puVar15);
    if (DAT_1eda3b1e0 != -1) {
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    }
    fVar3 = DAT_1eda46354;
    fVar2 = DAT_1eda46350;
    uVar14 = CONCAT44(uVar21,uVar9);
    uVar16 = CONCAT44(uVar23,uVar22);
    uStack_a8 = ram0x0001eda46330;
    local_b0 = ram0x0001eda46328;
    uStack_98 = ram0x0001eda46340;
    uStack_a0 = ram0x0001eda46338;
    local_93 = DAT_1eda46344._1_3_;
    uStack_90 = ram0x0001eda46348;
    uStack_c8 = _DAT_1eda46310;
    local_d0 = _DAT_1eda46308;
    uStack_b8 = ram0x0001eda46320;
    uStack_c0 = ram0x0001eda46318;
    if (DAT_1eda46304 == 1.0) {
      local_118 = {d 0.0096875};
      local_110 = 1.2f;
      uStack_f4 = 0;
      local_fc = 0;
      local_ec = 0x100000000;
      uStack_dc = 0;
      local_e4 = 0;
      local_d4 = 1;
      puVar8 = &local_118;
      local_10c = uVar14;
      local_104 = uVar16;
      FUN_195ed7db4(puVar8,&local_d0);
      if (((((ulong)puVar8 & 1) != 0) && (fVar2 == 0.85)) && (fVar3 == 0.85)) goto LAB_195f2d9a0;
    }
    uVar9 = 0.85f;
    uVar12 = 0.0015625;
    uVar19 = {d 3.43323e-06};
    uVar20 = {d 0.025};
  }
  else {
    uVar9 = 0;
    uVar21 = 0;
    uVar22 = 0;
    uVar23 = 0;
    func_0x0001981218c0(puVar15);
    if (DAT_1eda3b1e0 != -1) {
      func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
    }
    fVar3 = DAT_1eda46354;
    fVar2 = DAT_1eda46350;
    uVar14 = CONCAT44(uVar21,uVar9);
    uVar16 = CONCAT44(uVar23,uVar22);
    uStack_a8 = ram0x0001eda46330;
    local_b0 = ram0x0001eda46328;
    uStack_98 = ram0x0001eda46340;
    uStack_a0 = ram0x0001eda46338;
    local_93 = DAT_1eda46344._1_3_;
    uStack_90 = ram0x0001eda46348;
    uStack_c8 = _DAT_1eda46310;
    local_d0 = _DAT_1eda46308;
    uStack_b8 = ram0x0001eda46320;
    uStack_c0 = ram0x0001eda46318;
    if (DAT_1eda46304 == 1.0) {
      local_118 = {d 3.05176e-05};
      local_110 = 0.6f;
      uStack_f4 = 0;
      local_fc = 0;
      local_ec = 0x100000000;
      uStack_dc = 0;
      local_e4 = 0;
      local_d4 = 1;
      puVar8 = &local_118;
      local_10c = uVar14;
      local_104 = uVar16;
      FUN_195ed7db4(puVar8,&local_d0);
      if (((((ulong)puVar8 & 1) != 0) && (fVar2 == 1.0)) && (fVar3 == 1.0)) {
LAB_195f2d9a0:
        uVar17 = 1;
        uVar14 = 0;
        uVar16 = 0;
        uVar13 = 0;
        uVar12 = 0;
        uVar9 = 0;
        uVar19 = 0;
        uVar20 = 0;
        goto LAB_195f2d9e0;
      }
    }
    uVar9 = 1f;
    uVar12 = 0.0078125;
    uVar19 = {f 1, 0.1};
    uVar20 = {d 9.76563e-05};
  }
  uVar17 = 0;
  uVar13 = 0x100000000;
LAB_195f2d9e0:
  <faceEffects.ycc.white> = uVar20;
  <faceEffects.opacity> = uVar19;
  <faceEffects.ycc.normalFill.r> = uVar14;
  <faceEffects.ycc.normalFill.b> = uVar16;
  <faceEffects.ycc.dodgeFill.g> = 0;
  <faceEffects.ycc.normalFill?nil> = 0;
  <faceEffects.ycc.dodgeFill.a> = uVar13;
  <faceEffects.ycc.burnFill.b> = 0;
  <faceEffects.ycc.burnFill.r> = 0;
  <faceEffects.ycc.burnFill?nil> = uVar12;
  <faceEffects.maxLuminanceSDR> = uVar9;
  <faceEffects?nil> = uVar17;
  return;
}


//######## SidebarRecipe.anon.Shadow (spec) 0x195f2c1f0
// === 195f2da6c spec

/* WARNING: Removing unreachable block (ram,0x000195f2dac4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2da6c(long param_1,long param_2)
{
  lVar4 = 0;
  func_0x0001981207e0();
  lVar7 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar8 = &stack0xffffffffffffffb0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195ed0900();
  pcVar1 = (char *)(param_2 + *(int *)(lVar5 + 0x1c));
  cVar2 = *pcVar1;
  if ((pcVar1[0x28] & 0xe0U) == 0x20 && cVar2 != '\x02') {
    lVar5 = 0;
    FUN_195f3c68c();
    iVar3 = *(int *)(lVar5 + 0x14);
    (**(code **)(lVar7 + 0x68))(puVar8,*_DAT_1e017efe8,lVar4);
    puVar6 = &DAT_1eb9cb9f8;
    FUN_195f2dc18(&DAT_1eb9cb9f8,_DAT_1e017f000,_DAT_1e017f010);
    param_2 = param_2 + iVar3;
    func_0x0001980ff320(param_2,puVar8,lVar4,puVar6);
    (**(code **)(lVar7 + 8))(puVar8,lVar4);
    FUN_195f12a4c(<shadow.shadowRadius>);
    <shadow.shadowRadius> = 0;
    <+0x91> = 0;
    uVar9 = -1;
    if ((((uint)(cVar2 != '\x01') ^ (uint)param_2) & 1) == 0) {
      uVar9 = 1;
    }
    <shadow.offset.0> = uVar9;
    <shadow.offset.1> = 0;
  }
  return;
}


//######## SidebarRecipe.anon.DisableHighlights (spec) 0x195f2c1f4
// === 195f2c1f4 spec

void FUN_195f2c1f4(long param_1,long param_2)
{
  lVar2 = 0;
  FUN_195ed0900();
  pcVar1 = (char *)(param_2 + *(int *)(lVar2 + 0x1c));
  if ((pcVar1[0x28] & 0xe0U) == 0x20 && *pcVar1 != '\x02') {
    <highlights.keyOpacity> = 0;
    <highlights.diffuseHeightScale> = 0;
  }
  return;
}


//######## SidebarRecipe.anon.Planar (spec) 0x195f2c24c
// === 195f2c24c spec

void FUN_195f2c24c(long param_1,long param_2)
{
  lVar2 = 0;
  FUN_195ed0900();
  pcVar1 = (char *)(param_2 + *(int *)(lVar2 + 0x1c));
  if ((pcVar1[0x28] & 0xe0U) == 0x20 && *pcVar1 != '\x02') {
    FUN_195eda468(<shadow.opacity>,<+0x30>,
                  <+0x38>,<+0x40>,
                  <+0x48>,<+0x50>,
                  <+0x51>);
    <highlights.keyOpacity> = 0;
    <refraction.outerOpacity> = 0;
    <+0x30> = 0;
    <shadow.opacity> = 0;
    <+0x40> = 0;
    <+0x38> = 0;
    <+0x4a> = 0;
    <+0x42> = 0;
    <edgeBleed.ycc.saturation> = 1.5f;
    <ringShadow.opacity> = 0;
    <darkSpecular.height> = 0;
  }
  return;
}


//######## SidebarRecipe.anon.FaceEffect (spec) 0x195f2c2dc
// === 195f2cf7c spec

/* WARNING: Removing unreachable block (ram,0x000195f2d054) */
/* WARNING: Removing unreachable block (ram,0x000195f2cfdc) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2cf7c(long param_1,long param_2)
{
  undefined1 auStack_70 [8];
  lVar3 = 0;
  func_0x0001981217d0();
  lVar10 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  puVar13 = auStack_70 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar11 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  lVar14 = (long)puVar13 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195ed0900();
  pcVar1 = (char *)(param_2 + *(int *)(lVar5 + 0x1c));
  if ((pcVar1[0x28] & 0xe0U) != 0x20 || *pcVar1 == '\x02') {
    return;
  }
  lVar6 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar6 + 0x18);
  local_68 = lVar6;
  (**(code **)(lVar11 + 0x68))(lVar14,*_DAT_1e017dd58,lVar4);
  puVar7 = &DAT_1eda3a8e0;
  FUN_195f2dc18(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
  uVar8 = param_2 + iVar2;
  func_0x0001980ff320(uVar8,lVar14,lVar4,puVar7);
  (**(code **)(lVar11 + 8))(lVar14,lVar4);
  uVar12 = *(ulong *)(param_2 + *(int *)(lVar5 + 0x14));
  (**(code **)(lVar10 + 0x68))(puVar13,*_DAT_1e01830d0,lVar3);
  if ((uVar12 & 0x18) == 0) {
    if ((uVar8 & 1) != 0) {
      uVar15 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar9 = 0;
      goto LAB_195f2d1f8;
    }
    uVar9 = 0.2f;
  }
  else {
    if ((uVar8 & 1) != 0) {
      uVar9 = 0.6f;
      uVar15 = 0;
      uVar18 = 0;
      uVar19 = 0;
      goto LAB_195f2d1f8;
    }
    uVar9 = 0.8f;
  }
  uVar15 = 1f;
  uVar18 = 1f;
  uVar19 = 1f;
LAB_195f2d1f8:
  func_0x0001981218c0(puVar13);
  lVar3 = *(long *)(param_2 + *(int *)(local_68 + 0x78));
  <faceEffect.opacity> = 1f;
  if ((uVar8 & 1) == 0) {
    uVar16 = 1f;
    if (lVar3 != 2) {
      uVar16 = 0.85f;
    }
    <faceEffect.ycc.black> = 0.4f;
    <faceEffect.ycc.white> = {d 0.025};
    <faceEffect.ycc.normalFill.r> = CONCAT44(uVar18,uVar15);
    <faceEffect.ycc.normalFill.b> = CONCAT44(uVar9,uVar19);
    <faceEffect.ycc.normalFill?nil> = 0;
    <faceEffect.ycc.dodgeFill.r> = 0;
    <faceEffect.ycc.dodgeFill.b> = 0;
    <faceEffect.ycc.dodgeFill?nil> = 1;
    <faceEffect.ycc.burnFill.r> = 0;
    <faceEffect.ycc.burnFill.b> = 0;
    <faceEffect.ycc.burnFill?nil> = 1;
    <faceEffect.maxLuminance> = uVar16;
    <faceEffect.maxLuminanceSDR> = uVar16;
    <edgeBleed.ycc.black> = {d 0.00273437};
  }
  else {
    <faceEffect.ycc.black> = {d 3.05176e-05};
    <faceEffect.ycc.saturation> = 0.6f;
    <faceEffect.ycc.normalFill.r> = CONCAT44(uVar18,uVar15);
    <faceEffect.ycc.normalFill.b> = CONCAT44(uVar9,uVar19);
    <faceEffect.ycc.normalFill?nil> = 0;
    <faceEffect.ycc.dodgeFill.r> = 0;
    <faceEffect.ycc.dodgeFill.b> = 0;
    <faceEffect.ycc.dodgeFill?nil> = 1;
    <faceEffect.ycc.burnFill.r> = 0;
    <faceEffect.ycc.burnFill.b> = 0;
    <faceEffect.ycc.burnFill?nil> = 1;
    uVar17 = NEON_fmov(1f,4);
    <faceEffect.maxLuminance> = uVar17;
    <edgeBleed.ycc.black> = 0.1f;
  }
  return;
}


//######## SidebarRecipe.anon.AXFaceContrast (spec) 0x195f2c2e0
// === 195f2d314 spec

/* WARNING: Removing unreachable block (ram,0x000195f2d3e8) */
/* WARNING: Removing unreachable block (ram,0x000195f2d370) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2d314(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar10 = &stack0xffffffffffffffa0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar11 = (long)puVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  FUN_195ed0900();
  pcVar1 = (char *)(param_2 + *(int *)(lVar5 + 0x1c));
  if (((pcVar1[0x28] & 0xe0U) == 0x20 && *pcVar1 != '\x02') &&
     ((*(byte *)(param_2 + *(int *)(lVar5 + 0x14)) >> 4 & 1) != 0)) {
    lVar5 = 0;
    FUN_195f3c68c();
    iVar2 = *(int *)(lVar5 + 0x18);
    (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e017dd58,lVar4);
    puVar6 = &DAT_1eda3a8e0;
    FUN_195f2dc18(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
    uVar7 = param_2 + iVar2;
    func_0x0001980ff320(uVar7,lVar11,lVar4,puVar6);
    (**(code **)(lVar9 + 8))(lVar11,lVar4);
    if ((uVar7 & 1) == 0) {
      <faceEffect.ycc.black> = 0.00273437;
      (**(code **)(lVar8 + 0x68))(puVar10,*_DAT_1e01830d0,lVar3);
      uVar12 = 1f;
      uVar13 = 1f;
      uVar14 = 1f;
      uVar15 = 0.75f;
      func_0x0001981218c0(puVar10);
      <faceEffect.ycc.normalFill.b> =
           CONCAT17((char)((uint)uVar15 >> 0x18),
                    CONCAT16((char)((uint)uVar15 >> 0x10),
                             CONCAT15((char)((uint)uVar15 >> 8),CONCAT14((char)uVar15,uVar14))));
      <faceEffect.ycc.normalFill.r> =
           CONCAT17((char)((uint)uVar13 >> 0x18),
                    CONCAT16((char)((uint)uVar13 >> 0x10),
                             CONCAT15((char)((uint)uVar13 >> 8),CONCAT14((char)uVar13,uVar12))));
      <faceEffect.ycc.normalFill?nil> = 0;
    }
  }
  return;
}


//######## SidebarRecipe.anon.SidebarDiffusionAmount (spec) 0x195f2c2e4
// === 195f2cbac spec

/* WARNING: Removing unreachable block (ram,0x000195f2cc90) */
/* WARNING: Removing unreachable block (ram,0x000195f2cc18) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2cbac(long param_1,long param_2)
{
  undefined4 auStack_c0 [4];
  double local_b0 [3];
  lVar3 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  lVar10 = (long)local_b0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  uVar4 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(uVar4 - 8);
  uVar5 = uVar4;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar11 = lVar10 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  if ((uVar5 & 1) != 0) {
    lVar6 = 0;
    FUN_195f3c68c();
    pfVar1 = (float *)(param_2 + *(int *)(lVar6 + 0x70));
    if ((*(char *)(pfVar1 + 1) != '\x01') && (fVar22 = *pfVar1, 0.00034526698 <= ABS(fVar22 + -0.5))
       ) {
      iVar2 = *(int *)(lVar6 + 0x18);
      (**(code **)(lVar9 + 0x68))(lVar11,*_DAT_1e017dd58,uVar4);
      puVar7 = &DAT_1eda3a8e0;
      FUN_195f2dc18(&DAT_1eda3a8e0,_DAT_1e017dd80,_DAT_1e017dd90);
      uVar5 = param_2 + iVar2;
      func_0x0001980ff320(uVar5,lVar11,uVar4,puVar7);
      (**(code **)(lVar9 + 8))(lVar11,uVar4);
      fVar12 = (float)<blurFill.lightenOpacity>;
      fVar13 = (float)((ulong)<blurFill.lightenOpacity> >> 0x20);
      if (0.5 <= fVar22) {
        dVar17 = (double)fVar22 + -0.5 + (double)fVar22 + -0.5;
        if (dVar17 < 0.0) {
          dVar17 = 0.0;
        }
        local_b0[0] = 1.0;
        if (dVar17 <= 1.0) {
          local_b0[0] = dVar17;
        }
        fVar22 = (float)local_b0[0];
        fVar20 = (float)(1.0 - local_b0[0]);
        <blurFill.normalOpacity> = <blurFill.normalOpacity> * fVar20 + fVar22;
        uVar16 = NEON_rev64(CONCAT44(fVar20,fVar22),4);
        <blurFill.lightenOpacity> =
             CONCAT44(fVar13 * fVar20 + fVar13 * (float)((ulong)uVar16 >> 0x20),
                      fVar12 * fVar22 + fVar12 * (float)uVar16);
        if (<faceEffect.ycc.normalFill?nil> != '\x01') {
          local_b0[1] = 0.0;
          uStack_98 = 0;
          local_b0[2] = (double)CONCAT44(fVar20,fVar22);
          uVar23 = <faceEffect.ycc.normalFill.a>;
          (**(code **)(lVar8 + 0x68))(lVar10,*_DAT_1e01830d0,lVar3);
          if ((uVar5 & 1) == 0) {
            uVar19 = 1f;
            uVar14 = 1f;
            uVar15 = 1f;
          }
          else {
            uVar19 = 0;
            uVar14 = 0;
            uVar15 = 0;
          }
          uVar18 = 0.5f;
          func_0x0001981218c0(lVar10);
          *(undefined4 *)(lVar11 + -0x10) = uVar23;
          FUN_195f7f598();
          <faceEffect.ycc.normalFill.b> =
               CONCAT17((char)((uint)uVar18 >> 0x18),
                        CONCAT16((char)((uint)uVar18 >> 0x10),
                                 CONCAT15((char)((uint)uVar18 >> 8),CONCAT14((char)uVar18,uVar15))))
          ;
          <faceEffect.ycc.normalFill.r> =
               CONCAT17((char)((uint)uVar14 >> 0x18),
                        CONCAT16((char)((uint)uVar14 >> 0x10),
                                 CONCAT15((char)((uint)uVar14 >> 8),CONCAT14((char)uVar14,uVar19))))
          ;
          <faceEffect.ycc.normalFill?nil> = 0;
          fVar22 = SUB84(local_b0[2],0);
        }
        fVar12 = 0.15;
        if ((uVar5 & 1) == 0) {
          fVar12 = <faceEffect.ycc.black>;
        }
        <faceEffect.ycc.black> = fVar12 * fVar22 + <faceEffect.ycc.black> * fVar20;
      }
      else {
        uVar16 = NEON_fmov(0.75f,4);
        dVar17 = (double)fVar22 + (double)fVar22;
        dVar21 = 1.0;
        if (dVar17 <= 1.0) {
          dVar21 = dVar17;
        }
        uVar23 = SUB84(dVar21,0);
        uVar19 = (int)((ulong)dVar21 >> 0x20);
        if (dVar17 < 0.0) {
          uVar23 = 0;
          uVar19 = 0;
        }
        fVar20 = (float)(1.0 - (double)CONCAT44(uVar19,uVar23));
        fVar22 = (float)(double)CONCAT44(uVar19,uVar23);
        <blurFill.normalOpacity> = fVar20 * 0.25 + <blurFill.normalOpacity> * fVar22;
        <blurFill.lightenOpacity> =
             CONCAT44(fVar13 * fVar22 + fVar13 * (float)((ulong)uVar16 >> 0x20) * fVar20,
                      fVar12 * fVar22 + fVar12 * (float)uVar16 * fVar20);
      }
    }
  }
  return;
}


//######## FaceEffectNormalFill (spec) 0x195f2e2bc
// === 195f2e2bc spec

void FUN_195f2e2bc(long param_1)
{
  uVar1 = *unaff_x20;
  <faceEffect.ycc.normalFill.b> = unaff_x20[1];
  <faceEffect.ycc.normalFill.r> = uVar1;
  <faceEffect.ycc.normalFill?nil> = 0;
  return;
}


//######## SiriRecipe.anon.SiriModifier (spec) 0x195f2ebf0
// === 195f30b54 spec

/* WARNING: Removing unreachable block (ram,0x000195f30bb8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f30b54(undefined8 <backdropScale>,double *param_2)
{
  lVar4 = 0;
  local_68 = param_2;
  func_0x0001981220e0();
  local_70 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(local_70 + 0x40));
  lVar14 = (long)&local_90 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  local_88 = lVar14;
  (*_DAT_1e2125200)();
  uVar10 = lVar14 - extraout_x12;
  puVar5 = &DAT_1eb9cbb18;
  local_90 = uVar10;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9cbb18,&{f 2.23252e-40, 1.54143e-44});
  local_78 = puVar5;
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar5 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  lVar14 = uVar10 - extraout_x8_00;
  puVar5 = &DAT_1eb9cbb20;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(undefined8 *)(*(long *)(puVar5 + -8) + 0x40));
  lVar16 = lVar14 - (extraout_x8_01 + 0xfU & 0xfffffffffffffff0);
  (*_DAT_1e2125200)();
  lVar15 = lVar16 - extraout_x12_00;
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar11 = {f 0.5, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar11;
  <refraction.normalizedInnerAmount> = -0.72;
  <refraction.normalizedInnerHeight> = 0.4;
  <refraction.normalizedOuterAmount> = 0.4;
  <refraction.normalizedOuterHeight> = 0.4;
  <refraction.outerOpacity> = 1f;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,<+0x178>,<+0x180>,<+0x188>,
                <+0x190>,<+0x191>);
  <blur.blurRadius> = 8f;
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  uVar11 = {f 0.75, 0};
  <blur.opacities.2> = {d 0.0078125};
  <blur.opacities.0> = uVar11;
  <blur.distances.0.v> = -60f;
  <blur.distances.0.kind> = 0;
  <blur.distances.1.v> = -1f;
  <blur.distances.1.kind> = 0;
  <blur.distances.2.v> = 0;
  <blur.distances.2.kind> = 0;
  <blur.distances.3.v> = 0;
  <blur.distances.3.kind> = 0;
  <blur.outerRefractionBlurRadius> = 0;
  <blur.outerRefractionBlurRadius?nil> = 1;
  <faceEffect.ycc.black> = 0.1f;
  <faceEffect.ycc.white> = {d 0.03125};
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill.r> = 0;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.maxLuminance> = 0.0078125;
  <faceEffect.ycc.burnFill?nil> = 1;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  pdVar13 = local_68;
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  FUN_195eda468(<shadow.opacity>,<+0x30>,<+0x38>,<+0x40>,<+0x48>,<+0x50>
                ,<+0x51>);
  <+0x4a> = 0;
  <+0x42> = 0;
  <+0x40> = 0;
  <+0x38> = 0;
  <+0x30> = 0;
  <shadow.opacity> = 0;
  dVar17 = *pdVar13;
  uVar11 = -0.3;
  if (0.5 <= dVar17) {
    uVar11 = -0.25;
  }
  dVar18 = dVar17 * 1.6;
  if (0.5 <= dVar17) {
    dVar18 = dVar17;
  }
  <darkSpecular.height> = dVar18;
  <darkSpecular.spreadSDR> = 1.309;
  <darkSpecular.spread> = 1.309;
  <darkSpecular.colorBias> = uVar11;
  uVar11 = {d 0.4};
  <darkSpecular.effectOffset> = {d 0};
  <darkSpecular.amount> = uVar11;
  <blurFill.darkenOpacity> = {d 3.05176e-05};
  lVar6 = 0;
  FUN_195ed0900();
  uVar10 = (ulong)*(uint3 *)((long)pdVar13 + (long)*(int *)(lVar6 + 0x20));
  FUN_195e5f470(uVar10,0x1000a);
  uVar11 = {f 0.99, 0};
  local_7c = (uint)uVar10;
  if (((uVar10 & 1) == 0) && (*(char *)((long)pdVar13 + (long)*(int *)(lVar6 + 0x2c)) != '\x02'))
  goto LAB_195f311cc;
  <+0x8> = {d 0};
  <backdropScale> = uVar11;
  <blur.opacity> = 0;
  <blurFill.lightenOpacity> = 0;
  <blurFill.normalOpacity> = 0;
  uVar11 = {d 0};
  <faceEffect.ycc.white> = {d 0.0078125};
  <faceEffect.opacity> = uVar11;
  <faceEffect.ycc.normalFill.r> = 0;
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  iVar1 = *(int *)(lVar6 + 0x34);
  lVar7 = 0;
  func_0x000198122150();
  lVar6 = (long)pdVar13 + (long)iVar1;
  (**(code **)(*(long *)(lVar7 + -8) + 0x30))(lVar6,1,lVar7);
  bVar3 = (int)lVar6 != 1;
  if (bVar3) {
    func_0x000198122110(lVar15);
    pcVar12 = *(code **)(local_70 + 0x38);
  }
  else {
    pcVar12 = *(code **)(local_70 + 0x38);
  }
  lVar7 = local_70;
  (*pcVar12)(lVar15,!bVar3,1,lVar4);
  func_0x0001981220c0(lVar16);
  (*pcVar12)(lVar16,0,1,lVar4);
  lVar6 = (long)*(int *)(local_78 + 0x30);
  FUN_195f32bdc(lVar15,lVar14);
  FUN_195f32bdc(lVar16,lVar14 + lVar6);
  pcVar12 = *(code **)(lVar7 + 0x30);
  lVar7 = lVar14;
  (*pcVar12)(lVar14,1,lVar4);
  if ((int)lVar7 == 1) {
    FUN_195dabb50(lVar16,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
    FUN_195dabb50(lVar15,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
    lVar6 = lVar14 + lVar6;
    (*pcVar12)(lVar6,1,lVar4);
    pdVar13 = local_68;
    if ((int)lVar6 != 1) {
LAB_195f310f8:
      pdVar13 = local_68;
      FUN_195dabb50(lVar14,&DAT_1eb9cbb18,&{f 2.23252e-40, 1.54143e-44});
      goto LAB_195f31110;
    }
    FUN_195dabb50(lVar14,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
  }
  else {
    lVar7 = lVar14 + lVar6;
    (*pcVar12)(lVar7,1,lVar4);
    lVar2 = local_70;
    uVar10 = local_90;
    if ((int)lVar7 == 1) {
      FUN_195dabb50(lVar16,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
      FUN_195dabb50(lVar15,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
      goto LAB_195f310f8;
    }
    (**(code **)(local_70 + 0x10))(local_90,lVar14,lVar4);
    lVar7 = local_88;
    lVar8 = local_88;
    (**(code **)(lVar2 + 0x20))(local_88,lVar14 + lVar6,lVar4);
    FUN_195f2eafc();
    uVar9 = uVar10;
    func_0x0001980ff320(uVar10,lVar7,lVar4,lVar8);
    pcVar12 = *(code **)(lVar2 + 8);
    (*pcVar12)(lVar7,lVar4);
    (*pcVar12)(uVar10,lVar4);
    FUN_195dabb50(lVar16,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
    FUN_195dabb50(lVar15,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
    FUN_195dabb50(lVar14,&DAT_1eb9cbb20,&{f 2.23258e-40, 9.80909e-45});
    pdVar13 = local_68;
    if ((uVar9 & 1) != 0) goto LAB_195f31140;
LAB_195f31110:
    <+0x608> = 0.25;
    <+0x610> = -0.45;
    <+0x648> = 0.0078125;
    <+0x620> = 0;
    <+0x618> = 0;
    <+0x630> = 0;
    <+0x628> = 0;
    <+0x640> = 0;
    <+0x638> = 0;
  }
LAB_195f31140:
  if ((local_7c & 1) != 0) {
    lVar4 = 0;
    FUN_195f3c68c();
    pdVar13 = (double *)((long)pdVar13 + (long)*(int *)(lVar4 + 0x38));
    dVar17 = 0.45714285714285713;
    if (((ulong)pdVar13[1] & 0xff) != 1 && *(char *)((long)pdVar13 + 0x19) != '\x01') {
      dVar17 = *pdVar13 / 105.0;
    }
    <ringShadow.verticalOffset> = dVar17 * 32.0;
    <ringShadow.strokeWidth> = dVar17 * 12.0;
    <ringShadow.blurRadius> = dVar17 * 12.0;
    <ringShadow.opacity> = 0.4f;
    <ringShadow.maskAmount> = 0;
    return;
  }
LAB_195f311cc:
  <ringShadow.opacity> = 0;
  return;
}


//######## SiriRecipe.anon.ComposeModifier (spec) 0x195f2ebf4
// === 195f312d4 spec

/* WARNING: Removing unreachable block (ram,0x000195f31330) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f312d4(undefined8 <backdropScale>,double *param_2)
{
  undefined1 auVar5 [16];
  lVar1 = 0;
  func_0x0001981217d0();
  lVar2 = *(long *)(lVar1 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar2 + 0x40));
  lVar3 = (long)&local_90 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  FUN_195efb144(<backdropScale>,<+0x8>);
  uVar6 = {f 0.5, 0};
  <+0x8> = {d 0};
  <backdropScale> = uVar6;
  <refraction.normalizedInnerHeight> = 0.269;
  <refraction.normalizedInnerAmount> = -0.538;
  uVar9 = {d 0.269};
  uVar7 = {f 0, nan};
  uVar6 = {d 0.065};
  <refraction.outerHeightRange.lo> = {d 0};
  <refraction.normalizedOuterHeight> = uVar6;
  <refraction.normalizedOuterAmount> = uVar9;
  <refraction.outerHeightRange.hi> = uVar7;
  uVar6 = {d 0};
  <refraction.outerAmountRange.hi> = {f 0, nan};
  <refraction.outerAmountRange.lo> = uVar6;
  <refraction.outerOpacity> = 1f;
  <blur.opacity> = 0;
  <blurFill.lightenOpacity> = 0;
  <blurFill.normalOpacity> = 0;
  uVar6 = {d 0};
  <faceEffect.ycc.white> = {d 0.0078125};
  <faceEffect.opacity> = uVar6;
  <faceEffect.ycc.normalFill.b> = 0;
  <faceEffect.ycc.normalFill.r> = 0;
  <faceEffect.ycc.normalFill?nil> = 1;
  <faceEffect.ycc.dodgeFill.b> = 0;
  <faceEffect.ycc.dodgeFill.r> = 0;
  <faceEffect.ycc.dodgeFill?nil> = 1;
  <faceEffect.ycc.burnFill.b> = 0;
  <faceEffect.ycc.burnFill.r> = 0;
  <faceEffect.ycc.burnFill?nil> = 1;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,<+0x218>,<+0x220>,<+0x228>,
                <+0x230>,<+0x231>);
  <ringShadow.opacity> = 0;
  <+0x6e4> = 0.0078125;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  <+0x22a> = 0;
  <+0x222> = 0;
  auVar5 = NEON_fmov(1,8);
  <+0x6f8> = auVar5._8_8_;
  <+0x6f0> = auVar5._0_8_;
  FUN_195dabb50(<+0x690>,&DAT_1eda3b9a0,&{f 2.36685e-40, 9.80909e-45});
  <+0x690> = 0;
  <+0x6a0> = 0;
  <+0x698> = 0;
  <+0x6a8> = 0xff0000000000;
  <+0x6b8> = 0;
  <+0x6b0> = 0;
  <+0x6c8> = 0;
  <+0x6c0> = 0;
  <+0x6d6> = 0;
  <+0x6ce> = 0;
  (**(code **)(lVar2 + 0x68))(lVar3,*_DAT_1e01830d0,lVar1);
  uVar6 = 0;
  uVar7 = 0;
  uVar8 = 0;
  uVar9 = 0;
  uVar10 = 1f;
  uVar11 = 0;
  uVar12 = 0;
  uStack_80 = func_0x0001981218c0(0,lVar3);
  local_70 = CONCAT44(uVar11,uVar10);
  local_90 = uVar8;
  uStack_88 = uVar9;
  uStack_68 = uVar12;
  uStack_60 = uVar6;
  uStack_58 = uVar7;
  FUN_195f23488(<shadow.normalizedHeight>);
  uVar6 = {d 0.129};
  <shadow.normalizedAmount> = {d 0.108};
  <shadow.normalizedHeight> = uVar6;
  <shadow.blurRadius> = 0;
  <shadow.opacity> = 0.18f;
  <+0x38> = 0;
  <+0x30> = 0;
  <+0x48> = 0;
  <+0x40> = 0;
  <+0x50> = 0;
  <shadow.shadowRadius> = 20;
  <+0x91> = 0;
  uVar6 = {d 0};
  <shadow.offset.1> = {d 4};
  <shadow.offset.0> = uVar6;
  <shadow.ycc.black> = {d 0.00273437};
  <shadow.ycc.saturation> = 1f;
  uStack_80 = uStack_80 & 0xffffffff;
  local_90 = local_90 & 0xffffffff;
  <shadow.ycc.normalFill.b> = (char)local_90;
  <+0xbd> = (char)(local_90 >> 8);
  <+0xbe> = (char)(local_90 >> 0x10);
  <+0xbf> = (char)(local_90 >> 0x18);
  <shadow.ycc.normalFill.a> = (char)local_70;
  <+0xc1> = (char)((ulong)local_70 >> 8);
  <+0xc2> = (char)((ulong)local_70 >> 0x10);
  <+0xc3> = (char)((ulong)local_70 >> 0x18);
  <shadow.ycc.normalFill.r> = (char)uStack_80;
  <+0xb5> = (char)(uStack_80 >> 8);
  <+0xb6> = (char)(uStack_80 >> 0x10);
  <+0xb7> = (char)(uStack_80 >> 0x18);
  <shadow.ycc.normalFill.g> = (char)uStack_60;
  <+0xb9> = (char)((ulong)uStack_60 >> 8);
  <+0xba> = (char)((ulong)uStack_60 >> 0x10);
  <+0xbb> = (char)((ulong)uStack_60 >> 0x18);
  <shadow.ycc.normalFill?nil> = 0;
  <shadow.ycc.dodgeFill.r> = 0;
  <shadow.ycc.dodgeFill.b> = 0;
  <shadow.ycc.dodgeFill?nil> = 1;
  <shadow.ycc.burnFill.b> = 0;
  <shadow.ycc.burnFill.r> = 0;
  <shadow.ycc.burnFill?nil> = 1;
  <shadow.vibrancyContribution> = 0;
  <+0x129> = 0;
  dVar4 = *param_2;
  uVar6 = -0.3;
  if (0.5 <= dVar4) {
    uVar6 = -0.25;
  }
  <darkSpecular.spreadSDR> = 1.309;
  <darkSpecular.spread> = 1.309;
  <darkSpecular.colorBias> = uVar6;
  <darkSpecular.height> = dVar4 * 5.0;
  uVar6 = {d 0.4};
  <darkSpecular.effectOffset> = {d 0};
  <darkSpecular.amount> = uVar6;
  return;
}


//######## SiriRecipe.anon.SiriWaveModifier (params) 0x195f2ebf8
// === 195f2f3e8 params

void FUN_195f2f3e8(undefined8 param_1,undefined8 param_2,long param_3,long param_4)
{
  undefined1 auStack_5e0 [352];
  undefined4 local_480 [2];
  undefined1 auStack_468 [328];
  undefined1 auStack_320 [352];
  float local_1c0 [88];
  uVar5 = (undefined4)((ulong)param_1 >> 0x20);
  uVar3 = (undefined4)param_1;
  lVar2 = 0;
  FUN_195ed0900();
  iVar1 = *(int *)(lVar2 + 0x34);
  lVar2 = 0;
  func_0x000198122150();
  param_4 = param_4 + iVar1;
  (**(code **)(*(long *)(lVar2 + -8) + 0x30))(param_4,1,lVar2);
  if ((int)param_4 != 1) {
    func_0x000198122140();
    uVar4 = uVar3;
    func_0x0001981220f0();
    FUN_195f2e3fc(auStack_468);
    local_480[0] = uVar3;
    local_478 = CONCAT44(uVar5,uVar4);
    uStack_470 = param_2;
    func_0x000198104610(local_1c0,local_480,0x15c);
    if (local_1c0[0] <= 0.0) {
      FUN_195eb5390(local_1c0);
      FUN_195ecf8f4(auStack_320);
    }
    else {
      func_0x000198104610(auStack_5e0,local_480,0x15c);
      _CGPointMake(auStack_5e0);
      func_0x000198104610(auStack_320,auStack_5e0,0x15c);
    }
    FUN_195dabb50(param_3 + 0x510,&DAT_1eda3b118,&{f 2.55272e-40, 9.80909e-45});
    func_0x000198104610(param_3 + 0x510,auStack_320,0x15c);
  }
  return;
}


//######## SiriRecipe.anon.SiriHighlightsModifier (params) 0x195f2ebfc
// === 195f2f530 params

/* WARNING: Removing unreachable block (ram,0x000195f2f5a4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f2f530(long param_1,long param_2)
{
  undefined1 auStack_e40 [12];
  undefined1 auStack_b90 [272];
  undefined1 auStack_958 [272];
  undefined1 auStack_720 [272];
  undefined4 local_3d8 [2];
  lVar6 = 0;
  func_0x0001981217d0();
  lVar14 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar14 + 0x40));
  lVar7 = 0;
  FUN_195ed0900();
  uVar8 = (ulong)*(uint3 *)(param_2 + *(int *)(lVar7 + 0x20));
  FUN_195e5f470(uVar8,0x1000a);
  if ((uVar8 & 1) != 0) {
    lVar7 = 0;
    FUN_195f3c68c();
    pdVar1 = (double *)(param_2 + *(int *)(lVar7 + 0x38));
    dVar24 = *pdVar1;
    dVar15 = pdVar1[1];
    cVar2 = *(char *)((long)pdVar1 + 0x19);
    (**(code **)(lVar14 + 0x68))
              (auStack_e40 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),*_DAT_1e01830d0,lVar6);
    uVar12 = 1f;
    uVar33 = 1f;
    uVar26 = 1f;
    uVar28 = 1f;
    func_0x0001981218c0(auStack_e40 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0));
    uVar8 = CONCAT44(uVar33,uVar12);
    local_d88 = CONCAT44(uVar28,uVar26);
    lVar6 = <highlights.hdr>;
    local_d80 = param_1;
    func_0x000198104610(&local_5f8,lVar6,0x10d);
    uVar11 = (uint)lVar6;
    iVar4 = (int)&local_5f8;
    FUN_195e7d8c0();
    uVar3 = local_d88;
    local_db8 = {d 0.0078125};
    if (iVar4 == 1) {
      local_514 = 0;
      local_50c = 0;
      local_5f0 = 0;
      local_5f8 = 0;
      local_544 = 0;
      local_540 = 0;
      local_df0 = 1;
      uVar13 = 1;
      local_500 = 0;
      local_4f8 = 0;
      local_4f4 = 0;
      local_4f0 = 0;
      uVar5 = 1;
      uVar10 = 0;
      uVar17 = 0;
      uVar19 = 0;
      uVar18 = 0;
      dVar27 = 0.0;
      uVar20 = 0;
      uVar21 = 0;
      uVar22 = 0;
      uVar16 = 0;
      local_5f4 = uVar11;
      local_564 = extraout_w17;
      uVar12 = 0;
      uVar33 = 0;
    }
    else {
      local_5fc = local_5a3;
      local_5fa = local_5a1;
      local_600 = local_58f;
      local_5fe = local_58d;
      local_604 = local_57b;
      local_602 = local_579;
      uVar5 = (uint)local_52c;
      local_606 = local_529;
      local_608 = local_52b;
      local_df0 = (uint)local_518;
      local_60a = local_515;
      local_60c = local_517;
      uVar13 = (uint)local_504;
      local_60e = local_501;
      local_610 = local_503;
      uVar10 = local_53c;
      uVar17 = local_534;
      uVar19 = local_528;
      uVar18 = local_520;
      dVar27 = local_570;
      uVar20 = local_560;
      uVar21 = local_558;
      uVar22 = local_550;
      uVar16 = local_4ec;
      uVar12 = local_568;
      uVar33 = local_548;
    }
    dVar32 = 0.2670375521557719;
    if (cVar2 != '\x01' && ((ulong)dVar15 & 0xff) != 1) {
      dVar32 = (dVar24 / 719.0) * 4.0;
    }
    local_dd8 = CONCAT44(local_dd8._4_4_,local_5f8);
    local_1a0 = 1f;
    uStack_d98 = {d 0.75};
    local_da0 = {d 1.39626};
    uStack_190 = {d 0.75};
    local_198 = {d 1.39626};
    local_188 = 0.5;
    local_180 = {d 0.0078125};
    local_178 = 1f;
    local_16c = 0;
    local_174 = 0;
    local_164 = 1;
    local_163 = local_5fc;
    local_161 = local_5fa;
    local_158 = local_d88;
    local_150 = 0;
    local_14f = local_600;
    local_14d = local_5fe;
    local_14c = 0;
    local_144 = 0;
    local_13c = 1;
    local_13b = local_604;
    local_139 = local_602;
    local_138 = 2.44346;
    local_de8 = CONCAT44(local_de8._4_4_,uVar5);
    local_ec = (undefined1)uVar5;
    local_e9 = local_606;
    local_eb = local_608;
    local_d8 = (undefined1)local_df0;
    local_d5 = local_60a;
    local_d7 = local_60c;
    local_df8 = CONCAT44(local_df8._4_4_,uVar13);
    local_c4 = (undefined1)uVar13;
    local_c1 = local_60e;
    local_c3 = local_610;
    local_e10 = CONCAT44(local_e10._4_4_,local_4f0);
    local_3d8[0] = 0;
    local_3c8 = 0;
    local_3d0 = 0;
    local_3c0 = 0;
    local_388 = 0;
    uStack_390 = 0;
    local_398 = 0;
    uStack_3a0 = 0;
    local_3a8 = 0;
    uStack_3b0 = 0;
    local_3b8 = 0;
    local_384 = 1;
    local_378 = 0;
    local_380 = 0;
    local_370 = 1;
    local_364 = 0;
    local_36c = 0;
    local_35c = 1;
    local_350 = 0;
    local_358 = 0;
    local_348 = 0;
    local_310 = 0;
    uStack_318 = 0;
    local_320 = 0;
    uStack_328 = 0;
    local_330 = 0;
    uStack_338 = 0;
    local_340 = 0;
    local_30c = 1;
    local_300 = 0;
    local_308 = 0;
    local_2f8 = 1;
    local_2ec = 0;
    local_2f4 = 0;
    local_2e4 = 1;
    uStack_2d0 = 0;
    uStack_2d8 = 0;
    local_2d3 = 0;
    local_2e0 = 0;
    puVar9 = &local_1b8;
    local_e08 = local_4f4;
    local_e04 = local_4f8;
    local_e00 = (double)local_500;
    local_dec = local_5f4;
    local_de0 = local_5f0;
    local_dcc = local_540;
    local_dc8 = local_544;
    local_dc4 = local_564;
    local_dc0 = local_50c;
    local_db0 = (double)local_514;
    local_1b8 = local_5f8;
    local_1b4 = local_5f4;
    local_1b0 = local_5f0;
    local_1a8 = dVar32;
    local_160 = uVar8;
    local_130 = dVar27;
    local_128 = uVar12;
    local_120 = uVar20;
    local_118 = uVar21;
    local_110 = uVar22;
    local_108 = uVar33;
    local_104 = local_544;
    local_100 = local_540;
    local_fc = uVar10;
    local_f4 = uVar17;
    local_e8 = uVar19;
    local_e0 = uVar18;
    local_d4 = local_514;
    local_cc = local_50c;
    local_c0 = local_500;
    local_b8 = local_4f8;
    local_b4 = local_4f4;
    local_b0 = local_4f0;
    local_ac = uVar16;
    FUN_195ed8068(puVar9,local_3d8);
    local_da8 = uVar8;
    if (((ulong)puVar9 & 1) == 0) {
      local_d78 = (undefined4)local_dd8;
      local_d74 = local_dec;
      local_d70 = local_de0;
      local_d60 = 1f;
      uStack_d50 = uStack_d98;
      local_d58 = local_da0;
      local_d48 = 0.5;
      local_d40 = local_db8;
      local_d38 = 1f;
      local_d2c = 0;
      local_d34 = 0;
      local_d24 = 1;
      local_d23 = local_5fc;
      local_d21 = local_5fa;
      uStack_d18 = uVar3;
      local_d10 = 0;
      local_d0f = local_600;
      local_d0d = local_5fe;
      local_d0c = 0;
      local_d04 = 0;
      local_cfc = 1;
      local_cfb = local_604;
      local_cf9 = local_602;
      local_cf8 = 2.44346;
      local_ce4 = local_dc4;
      local_cc8 = CONCAT44(local_dc8,uVar33);
      local_cc0 = local_dcc;
      local_cac = (undefined1)local_de8;
      local_ca9 = local_606;
      local_cab = local_608;
      local_c98 = (undefined1)local_df0;
      local_c95 = local_60a;
      local_c97 = local_60c;
      local_c94 = local_db0;
      local_c8c = local_dc0;
      local_c84 = (undefined1)local_df8;
      local_c81 = local_60e;
      local_c83 = local_610;
      local_c80 = local_e00;
      local_c78 = CONCAT44(local_e08,local_e04);
      local_c70 = (undefined4)local_e10;
      dStack_d68 = dVar32;
      local_d20 = uVar8;
      local_cf0 = dVar27;
      local_ce8 = uVar12;
      local_ce0 = uVar20;
      uStack_cd8 = uVar21;
      local_cd0 = uVar22;
      local_cbc = uVar10;
      local_cb4 = uVar17;
      local_ca8 = uVar19;
      uStack_ca0 = uVar18;
      local_c6c = uVar16;
      _CGPointMake(&local_d78);
      func_0x000198104610(auStack_720,&local_d78,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_720);
    }
    local_db0 = dVar32;
    func_0x000198104610(local_d80 + 0x1e8,auStack_720,0x10d);
    uVar11 = (uint)auStack_720;
    uVar12 = 0x10d;
    func_0x000198104610(&local_830);
    iVar4 = (int)&local_830;
    FUN_195e7d8c0();
    uVar10 = local_d88;
    uVar8 = local_da8;
    dVar15 = local_db0;
    uVar3 = local_db8;
    if (iVar4 == 1) {
      local_7c4 = 0;
      local_7bc = 0;
      local_dc8 = 0;
      local_810 = 0;
      local_808 = 0;
      local_800 = 0;
      local_7f8 = 0;
      local_7f4 = 0;
      local_7f0 = 0;
      uVar5 = 1;
      local_e04 = 1;
      local_e08 = 1;
      local_7b0 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      dVar24 = 0.0;
      uVar33 = 0;
      uVar16 = 0;
      local_82c = uVar11;
      local_814 = uVar12;
      uVar12 = 0;
      uVar26 = 0;
      uVar28 = 0;
    }
    else {
      uVar5 = (uint)local_7dc;
      local_832 = local_7d9;
      local_834 = local_7db;
      local_e04 = (uint)local_7c8;
      local_836 = local_7c5;
      local_838 = local_7c7;
      local_e08 = (uint)local_7b4;
      local_83a = local_7b1;
      local_83c = local_7b3;
      local_83e = local_761;
      local_840 = local_763;
      local_842 = local_74d;
      local_844 = local_74f;
      local_846 = local_739;
      local_848 = local_73b;
      uVar17 = local_7ec;
      uVar18 = local_7e4;
      uVar19 = local_7d8;
      uVar20 = local_7d0;
      uVar21 = local_828;
      dVar24 = local_820;
      uVar33 = local_818;
      uVar16 = local_724;
      local_dc8 = local_830;
      uVar12 = local_730;
      uVar26 = local_72c;
      uVar28 = local_728;
    }
    local_df8 = CONCAT44(local_df8._4_4_,local_7f0);
    local_e00 = (double)CONCAT44(local_e00._4_4_,uVar5);
    local_274 = (undefined1)uVar5;
    local_271 = local_832;
    local_273 = local_834;
    local_260 = (undefined1)local_e04;
    local_25f = local_838;
    local_25d = local_836;
    local_24c = (undefined1)local_e08;
    local_24b = local_83c;
    local_249 = local_83a;
    local_240 = local_db0;
    local_238 = 1f;
    uStack_228 = uStack_d98;
    local_230 = local_da0;
    local_220 = 0.5;
    local_218 = local_db8;
    local_210 = 1f;
    local_20c = 0;
    local_204 = 0;
    local_1fc = 1;
    local_1f9 = local_83e;
    local_1fb = local_840;
    local_1f8 = local_da8;
    local_1f0 = local_d88;
    local_1e8 = 0;
    local_1e5 = local_842;
    local_1e7 = local_844;
    local_1e4 = 0;
    local_1dc = 0;
    local_1d4 = 1;
    local_1d3 = local_848;
    local_1d1 = local_846;
    local_1d0 = 2.26893;
    puVar9 = &local_2c8;
    local_e10 = local_7b0;
    local_df0 = local_7f4;
    local_dec = local_7f8;
    local_de8 = local_800;
    local_de0 = local_808;
    local_dd8 = local_810;
    local_dcc = local_814;
    local_dc4 = local_82c;
    local_dc0 = local_7bc;
    local_d88 = local_7c4;
    local_2c8 = local_dc8;
    local_2c4 = local_82c;
    local_2c0 = uVar21;
    local_2b8 = dVar24;
    local_2b0 = uVar33;
    local_2ac = local_814;
    local_2a8 = local_810;
    local_2a0 = local_808;
    local_298 = local_800;
    local_290 = local_7f8;
    local_28c = local_7f4;
    local_288 = local_7f0;
    local_284 = uVar17;
    local_27c = uVar18;
    local_270 = uVar19;
    local_268 = uVar20;
    local_25c = local_7c4;
    local_254 = local_7bc;
    local_248 = local_7b0;
    local_1c8 = uVar12;
    local_1c4 = uVar26;
    local_1c0 = uVar28;
    local_1bc = uVar16;
    uVar11 = local_e08;
    FUN_195ed8068(puVar9,local_3d8);
    if (((ulong)puVar9 & 1) == 0) {
      local_d78 = local_dc8;
      local_d74 = local_dc4;
      local_d5c = local_dcc;
      local_d58 = local_dd8;
      uStack_d50 = local_de0;
      local_d48 = local_de8;
      local_d40 = CONCAT44(local_df0,local_dec);
      local_d38 = (undefined4)local_df8;
      local_d24 = SUB81(local_e00,0);
      local_d23 = local_834;
      local_d21 = local_832;
      local_d10 = (undefined1)local_e04;
      local_d0f = local_838;
      local_d0d = local_836;
      local_d0c = local_d88;
      local_d04 = local_dc0;
      local_cfc = (undefined1)local_e08;
      local_cfb = local_83c;
      local_cf9 = local_83a;
      local_cf8 = local_e10;
      local_cf0 = dVar15;
      local_ce8 = 1f;
      uStack_cd8 = uStack_d98;
      local_ce0 = local_da0;
      local_cd0 = 0.5;
      local_cc8 = uVar3;
      local_cc0 = 1f;
      local_cbc = 0;
      local_cb4 = 0;
      local_cac = 1;
      local_ca9 = local_83e;
      local_cab = local_840;
      local_ca8 = uVar8;
      uStack_ca0 = uVar10;
      local_c98 = 0;
      local_c95 = local_842;
      local_c97 = local_844;
      local_c94 = 0;
      local_c8c = 0;
      local_c84 = 1;
      local_c83 = local_848;
      local_c81 = local_846;
      local_c80 = 2.26893;
      local_c78 = CONCAT44(uVar26,uVar12);
      local_d70 = uVar21;
      dStack_d68 = dVar24;
      local_d60 = uVar33;
      local_d34 = uVar17;
      local_d2c = uVar18;
      local_d20 = uVar19;
      uStack_d18 = uVar20;
      local_c70 = uVar28;
      local_c6c = uVar16;
      _CGPointMake(&local_d78);
      func_0x000198104610(auStack_958,&local_d78,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_958);
    }
    func_0x000198104610(local_d80 + 0x1e8,auStack_958,0x10d);
    func_0x000198104610(&local_a68,auStack_958,0x10d);
    iVar4 = (int)&local_a68;
    FUN_195e7d8c0();
    uVar3 = {d 0.000170898};
    if (iVar4 == 1) {
      local_998 = 0;
      local_990 = 0;
      local_984 = 0;
      local_97c = 0;
      local_dc4 = 0;
      local_e34 = 0;
      local_a2c = 0;
      uVar5 = 1;
      local_a28 = 0;
      local_dec = 1;
      local_df0 = 1;
      local_9e8 = 0;
      local_9e0 = 0.0;
      local_9d8 = 0;
      local_9d0 = 0;
      local_9c8 = 0;
      local_9c0 = 0;
      local_9b8 = 0;
      local_9b4 = 0;
      local_9b0 = 0;
      local_e30 = 1;
      local_d88 = CONCAT44(local_d88._4_4_,1);
      local_da0 = CONCAT44(local_da0._4_4_,1);
      uVar10 = 0;
      uVar17 = 0;
      uVar18 = 0;
      uVar19 = 0;
      uVar20 = 0;
      uVar21 = 0;
      uVar22 = 0;
      uVar23 = 0;
      uVar25 = 0;
      dVar15 = 0.0;
      uVar29 = 0;
      uVar30 = 0;
      uVar31 = 0;
      uVar34 = 0;
      local_a64 = uVar11;
      local_a4c = in_w6;
      uVar12 = 0;
      uVar16 = 0;
    }
    else {
      uVar5 = (uint)local_a14;
      local_a6a = local_a11;
      local_a6c = local_a13;
      local_dec = (uint)local_a00;
      local_a6e = local_9fd;
      local_a70 = local_9ff;
      local_df0 = (uint)local_9ec;
      local_a72 = local_9e9;
      local_a74 = local_9eb;
      uVar8 = (ulong)local_9d4;
      local_e30 = (uint)local_99c;
      local_a76 = local_999;
      local_a78 = local_99b;
      local_d88 = CONCAT44(local_d88._4_4_,(uint)local_988);
      local_a7a = local_985;
      local_a7c = local_987;
      local_da0 = CONCAT44(local_da0._4_4_,(uint)local_974);
      local_a7e = local_971;
      local_a80 = local_973;
      uVar10 = local_9a4;
      uVar17 = local_a24;
      uVar18 = local_a1c;
      uVar19 = local_a10;
      uVar20 = local_a08;
      uVar21 = local_9fc;
      uVar22 = local_9f4;
      uVar23 = local_9ac;
      uVar25 = local_a60;
      dVar15 = local_a58;
      uVar29 = local_a48;
      uVar30 = local_a40;
      uVar31 = local_a38;
      uVar34 = local_970;
      local_dc4 = local_a68;
      local_e34 = local_a50;
      uVar12 = local_a30;
      uVar16 = local_95c;
    }
    local_dd8 = CONCAT44(local_dd8._4_4_,local_a4c);
    local_de8 = CONCAT44(local_de8._4_4_,local_a28);
    local_de0 = CONCAT44(local_de0._4_4_,uVar5);
    local_494 = (undefined1)uVar5;
    local_491 = local_a6a;
    local_493 = local_a6c;
    local_480 = (undefined1)local_dec;
    local_47f = local_a70;
    local_47d = local_a6e;
    local_46c = (undefined1)local_df0;
    local_46b = local_a74;
    local_469 = local_a72;
    local_e08 = (uint)uVar8;
    local_41c = (undefined1)local_e30;
    local_419 = local_a76;
    local_41b = local_a78;
    local_408 = (undefined1)local_d88;
    local_405 = local_a7a;
    local_407 = local_a7c;
    local_3f4 = (undefined1)local_da0;
    local_3f1 = local_a7e;
    local_3f3 = local_a80;
    local_3e8 = {d 0.000170898};
    local_3e0 = 0.15f;
    puVar9 = &local_4e8;
    local_e2c = local_9b0;
    local_e28 = local_9b4;
    uStack_e24 = local_9b8;
    local_e20 = local_9c0;
    local_e18 = local_9c8;
    local_e10 = local_9d0;
    local_e04 = local_9d8;
    local_e00 = local_9e0;
    local_df8 = local_9e8;
    local_dcc = local_a2c;
    local_dc8 = local_a64;
    local_dc0 = local_97c;
    local_db8 = local_984;
    local_db0 = (double)local_990;
    local_da8 = local_998;
    local_4e8 = local_dc4;
    local_4e4 = local_a64;
    local_4e0 = uVar25;
    local_4d8 = dVar15;
    local_4d0 = local_e34;
    local_4cc = local_a4c;
    local_4c8 = uVar29;
    local_4c0 = uVar30;
    local_4b8 = uVar31;
    local_4b0 = uVar12;
    local_4ac = local_a2c;
    local_4a8 = local_a28;
    local_4a4 = uVar17;
    local_49c = uVar18;
    local_490 = uVar19;
    local_488 = uVar20;
    local_47c = uVar21;
    local_474 = uVar22;
    local_468 = local_9e8;
    local_460 = local_9e0;
    local_458 = local_9d8;
    local_454 = local_e08;
    local_450 = local_9d0;
    local_448 = local_9c8;
    local_440 = local_9c0;
    local_438 = local_9b8;
    local_434 = local_9b4;
    local_430 = local_9b0;
    local_42c = uVar23;
    local_424 = uVar10;
    local_418 = local_998;
    local_410 = local_990;
    local_404 = local_984;
    local_3fc = local_97c;
    local_3f0 = uVar34;
    local_3dc = uVar16;
    FUN_195ed8068(puVar9,local_3d8);
    if (((ulong)puVar9 & 1) == 0) {
      local_d78 = local_dc4;
      local_d74 = local_dc8;
      local_d60 = local_e34;
      local_d5c = (undefined4)local_dd8;
      local_d40 = CONCAT44(local_dcc,uVar12);
      local_d38 = (undefined4)local_de8;
      local_d24 = (undefined1)local_de0;
      local_d23 = local_a6c;
      local_d21 = local_a6a;
      local_d10 = (undefined1)local_dec;
      local_d0d = local_a6e;
      local_d0f = local_a70;
      local_cfc = (undefined1)local_df0;
      local_cf9 = local_a72;
      local_cfb = local_a74;
      local_cf8 = local_df8;
      local_cf0 = local_e00;
      local_ce8 = local_e04;
      local_ce4 = local_e08;
      local_ce0 = local_e10;
      uStack_cd8 = local_e18;
      local_cd0 = local_e20;
      local_cc8 = CONCAT44(local_e28,uStack_e24);
      local_cc0 = local_e2c;
      local_cac = (undefined1)local_e30;
      local_ca9 = local_a76;
      local_cab = local_a78;
      local_ca8 = local_da8;
      uStack_ca0 = local_db0;
      local_c98 = (undefined1)local_d88;
      local_c95 = local_a7a;
      local_c97 = local_a7c;
      local_c94 = local_db8;
      local_c8c = local_dc0;
      local_c84 = (undefined1)local_da0;
      local_c81 = local_a7e;
      local_c83 = local_a80;
      local_c78 = uVar3;
      local_c70 = 0.15f;
      local_d70 = uVar25;
      dStack_d68 = dVar15;
      local_d58 = uVar29;
      uStack_d50 = uVar30;
      local_d48 = uVar31;
      local_d34 = uVar17;
      local_d2c = uVar18;
      local_d20 = uVar19;
      uStack_d18 = uVar20;
      local_d0c = uVar21;
      local_d04 = uVar22;
      local_cbc = uVar23;
      local_cb4 = uVar10;
      local_c80 = uVar34;
      local_c6c = uVar16;
      _CGPointMake(&local_d78);
      func_0x000198104610(auStack_b90,&local_d78,0x10d);
    }
    else {
      FUN_195e7d8d4(auStack_b90);
    }
    lVar6 = local_d80;
    func_0x000198104610(local_d80 + 0x1e8,auStack_b90,0x10d);
    FUN_195ecf8a8(&local_d78);
    func_0x000198104610(lVar6 + 0x670,&local_d78,0x1e4);
  }
  return;
}


//######## SiriRecipe.anon.ComposeHighlightsModifier (params) 0x195f2ec00
// === 195f315e8 params

/* WARNING: Removing unreachable block (ram,0x000195f31678) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f315e8(long param_1,double *param_2,undefined8 param_3,undefined8 param_4,
                  undefined4 param_5,undefined4 param_6)
{
  undefined1 auStack_1100 [4];
  undefined1 auStack_ed8 [272];
  undefined1 auStack_ca0 [272];
  undefined1 auStack_a68 [272];
  undefined1 auStack_830 [272];
  undefined4 local_610 [2];
  (*_DAT_1e2125200)();
  lVar3 = 0;
  func_0x0001981217d0();
  (*_DAT_1e2125200)(*(undefined8 *)(*(long *)(lVar3 + -8) + 0x40));
  local_1020 = *param_2;
  (**(code **)(extraout_x12 + 0x68))
            (auStack_1100 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0),*_DAT_1e01830d0);
  uVar23 = 1f;
  uVar24 = 1f;
  uVar19 = 1f;
  uVar27 = 1f;
  func_0x0001981218c0(auStack_1100 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0));
  local_1028 = uVar23 & 0xffffffff;
  local_1030 = uVar24 & 0xffffffff;
  local_1038 = uVar19 & 0xffffffff;
  local_1040 = uVar27 & 0xffffffff;
  local_ff0 = param_1;
  func_0x000198104610(&local_1b8,<highlights.hdr>,0x10d);
  iVar2 = (int)&local_1b8;
  FUN_195e7d8c0();
  if (iVar2 == 1) {
    local_f4 = 0;
    local_e8 = 0;
    local_d4 = 0;
    local_cc = 0;
    local_17c = 0;
    local_178 = 0;
    uVar9 = 1;
    uVar18 = 1;
    uVar20 = 1;
    local_138 = 0;
    local_130 = 0;
    local_128 = 0;
    local_120 = 0;
    local_118 = 0;
    local_110 = 0;
    local_108 = 0;
    local_104 = 0;
    local_100 = 0;
    local_ff8 = CONCAT44(local_ff8._4_4_,1);
    local_1000 = CONCAT44(local_1000._4_4_,1);
    local_1008 = (double)CONCAT44(local_1008._4_4_,1);
    local_c0 = 0;
    local_b8 = 0;
    local_b4 = 0;
    local_b0 = 0;
    uVar4 = 0;
    uVar6 = 0;
    uVar7 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar25 = 0;
    uVar26 = 0;
    uVar28 = 0;
    uVar29 = 0;
    uVar22 = 0;
    local_1b4 = param_5;
    local_19c = param_6;
    uVar32 = 0;
    uVar31 = 0;
  }
  else {
    uVar9 = (uint)local_164;
    local_1ba = local_161;
    local_1bc = local_163;
    uVar18 = (uint)local_150;
    local_1be = local_14d;
    local_1c0 = local_14f;
    uVar20 = (uint)local_13c;
    local_1c2 = local_139;
    local_1c4 = local_13b;
    local_1044 = local_124;
    local_ff8 = CONCAT44(local_ff8._4_4_,(uint)local_ec);
    local_1c6 = local_e9;
    local_1c8 = local_eb;
    local_1000 = CONCAT44(local_1000._4_4_,(uint)local_d8);
    local_1ca = local_d5;
    local_1cc = local_d7;
    local_1008 = (double)CONCAT44(local_1008._4_4_,(uint)local_c4);
    local_1ce = local_c1;
    local_1d0 = local_c3;
    uVar4 = local_fc;
    uVar6 = local_e0;
    uVar7 = local_174;
    uVar11 = local_16c;
    uVar12 = local_160;
    uVar13 = local_158;
    uVar14 = local_14c;
    uVar15 = local_144;
    uVar16 = local_1b0;
    uVar25 = local_1a8;
    uVar26 = local_198;
    uVar28 = local_190;
    uVar29 = local_188;
    uVar22 = local_1b8;
    uVar32 = local_1a0;
    uVar31 = local_180;
  }
  local_1070 = CONCAT44(local_1070._4_4_,local_19c);
  local_1080 = CONCAT44(local_1080._4_4_,local_17c);
  local_1090 = CONCAT44(local_1090._4_4_,local_178);
  local_1098 = CONCAT44(local_1098._4_4_,uVar9);
  local_28c = (undefined1)uVar9;
  local_289 = local_1ba;
  local_28b = local_1bc;
  local_10a0 = CONCAT44(local_10a0._4_4_,uVar18);
  local_278 = (undefined1)uVar18;
  local_277 = local_1c0;
  local_275 = local_1be;
  local_10a8 = CONCAT44(local_10a8._4_4_,uVar20);
  local_264 = (undefined1)uVar20;
  local_263 = local_1c4;
  local_261 = local_1c2;
  local_24c = local_1044;
  local_214 = (undefined1)local_ff8;
  local_211 = local_1c6;
  local_213 = local_1c8;
  local_200 = (undefined1)local_1000;
  local_1fd = local_1ca;
  local_1ff = local_1cc;
  local_1ec = SUB81(local_1008,0);
  local_1e9 = local_1ce;
  local_1eb = local_1d0;
  local_1d4 = 1;
  local_610[0] = 0;
  local_600 = 0;
  local_608 = 0;
  local_5f8 = 0;
  local_5c0 = 0;
  uStack_5d8 = 0;
  local_5e0 = 0;
  uStack_5c8 = 0;
  uStack_5d0 = 0;
  uStack_5e8 = 0;
  local_5f0 = 0;
  local_5bc = 1;
  local_5b0 = 0;
  local_5b8 = 0;
  local_5a8 = 1;
  local_59c = 0;
  local_5a4 = 0;
  local_594 = 1;
  local_588 = 0;
  local_590 = 0;
  local_580 = 0;
  local_548 = 0;
  uStack_550 = 0;
  local_558 = 0;
  uStack_560 = 0;
  local_568 = 0;
  uStack_570 = 0;
  local_578 = 0;
  local_544 = 1;
  local_538 = 0;
  local_540 = 0;
  local_530 = 1;
  local_524 = 0;
  local_52c = 0;
  local_51c = 1;
  uStack_508 = 0;
  uStack_510 = 0;
  local_50b = 0;
  local_518 = 0;
  puVar5 = &local_2e0;
  local_10fc = local_b0;
  local_10f8 = local_b4;
  uStack_10f4 = local_b8;
  local_10f0 = local_c0;
  local_10e4 = local_100;
  local_10e0 = local_104;
  uStack_10dc = local_108;
  local_10d8 = local_110;
  local_10d0 = local_118;
  local_10c8 = local_120;
  local_10bc = local_128;
  local_10b8 = local_130;
  local_10b0 = local_138;
  local_1088 = local_cc;
  local_1078 = local_d4;
  local_1064 = local_1b4;
  local_1060 = uVar6;
  local_1058 = local_e8;
  local_1050 = local_f4;
  local_2e0 = uVar22;
  local_2dc = local_1b4;
  local_2d8 = uVar16;
  local_2d0 = uVar25;
  local_2c8 = uVar32;
  local_2c4 = local_19c;
  local_2c0 = uVar26;
  local_2b8 = uVar28;
  local_2b0 = uVar29;
  local_2a8 = uVar31;
  local_2a4 = local_17c;
  local_2a0 = local_178;
  local_29c = uVar7;
  local_294 = uVar11;
  local_288 = uVar12;
  local_280 = uVar13;
  local_274 = uVar14;
  local_26c = uVar15;
  local_260 = local_138;
  local_258 = local_130;
  local_250 = local_128;
  local_248 = local_120;
  local_240 = local_118;
  local_238 = local_110;
  local_230 = local_108;
  local_22c = local_104;
  local_228 = local_100;
  local_224 = uVar4;
  local_21c = local_f4;
  local_210 = local_e8;
  local_208 = uVar6;
  local_1fc = local_d4;
  local_1f4 = local_cc;
  local_1e8 = local_c0;
  local_1e0 = local_b8;
  local_1dc = local_b4;
  local_1d8 = local_b0;
  FUN_195ed8068(puVar5,local_610);
  uVar8 = (undefined4)uVar6;
  if (((ulong)puVar5 & 1) == 0) {
    local_3ec = local_1064;
    local_3d4 = (undefined4)local_1070;
    local_3b8 = CONCAT44((undefined4)local_1080,uVar31);
    local_3b0 = (undefined4)local_1090;
    local_39c = (undefined1)local_1098;
    local_39b = local_1bc;
    local_399 = local_1ba;
    local_388 = (undefined1)local_10a0;
    local_387 = local_1c0;
    local_385 = local_1be;
    local_374 = (undefined1)local_10a8;
    local_373 = local_1c4;
    local_371 = local_1c2;
    local_370 = local_10b0;
    local_368 = local_10b8;
    local_360 = local_10bc;
    local_35c = local_1044;
    local_358 = local_10c8;
    local_350 = local_10d0;
    local_348 = local_10d8;
    local_340 = uStack_10dc;
    local_33c = local_10e0;
    local_338 = local_10e4;
    local_32c = local_1050;
    local_324 = (undefined1)local_ff8;
    local_321 = local_1c6;
    local_323 = local_1c8;
    local_320 = local_1058;
    local_318 = local_1060;
    local_310 = (undefined1)local_1000;
    local_30d = local_1ca;
    local_30f = local_1cc;
    local_30c = local_1078;
    local_304 = local_1088;
    local_2fc = SUB81(local_1008,0);
    local_2f9 = local_1ce;
    local_2fb = local_1d0;
    local_2f8 = local_10f0;
    local_2f0 = uStack_10f4;
    local_2ec = local_10f8;
    local_2e8 = local_10fc;
    local_2e4 = 1;
    local_3f0 = uVar22;
    local_3e8 = uVar16;
    local_3e0 = (double)uVar25;
    local_3d8 = uVar32;
    local_3d0 = uVar26;
    uStack_3c8 = uVar28;
    local_3c0 = uVar29;
    local_3ac = uVar7;
    local_3a4 = uVar11;
    local_398 = uVar12;
    local_390 = uVar13;
    local_384 = uVar14;
    local_37c = uVar15;
    local_334 = uVar4;
    _CGPointMake(&local_3f0);
    func_0x000198104610(auStack_830,&local_3f0,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_830);
  }
  local_1008 = local_1020 * 2.5;
  local_ff8 = local_1028 | local_1030 << 0x20;
  local_1000 = local_1038 | local_1040 << 0x20;
  func_0x000198104610(local_ff0 + 0x1e8,auStack_830,0x10d);
  func_0x000198104610(&local_940,auStack_830,0x10d);
  iVar2 = (int)&local_940;
  FUN_195e7d8c0();
  uVar24 = local_ff8;
  uVar23 = local_1000;
  dVar1 = local_1008;
  uVar4 = {d 0.0078125};
  if (iVar2 == 1) {
    local_854 = 0;
    local_33c = 0;
    local_338 = 0;
    uVar18 = 1;
    uVar20 = 1;
    local_848 = 0;
    local_840 = 0;
    local_83c = 0;
    local_838 = 0;
    local_940 = 0;
    local_938 = 0;
    local_1044 = 1;
    uVar6 = 0;
    uVar7 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar25 = 0;
    uVar10 = 0;
    local_8ac = extraout_w17;
    uVar22 = 0;
    uVar32 = 0;
  }
  else {
    local_944 = local_8eb;
    local_942 = local_8e9;
    local_948 = local_8d7;
    local_946 = local_8d5;
    local_94c = local_8c3;
    local_94a = local_8c1;
    local_1044 = (uint)local_874;
    local_94e = local_871;
    local_950 = local_873;
    uVar18 = (uint)local_860;
    local_952 = local_85d;
    local_954 = local_85f;
    uVar20 = (uint)local_84c;
    local_956 = local_849;
    local_958 = local_84b;
    uVar6 = local_884;
    uVar7 = local_87c;
    uVar11 = local_870;
    uVar12 = local_868;
    uVar13 = local_85c;
    uVar14 = local_8b8;
    uVar15 = local_8a8;
    uVar16 = local_8a0;
    uVar25 = local_898;
    uVar10 = local_834;
    uVar8 = local_93c;
    uVar22 = local_8b0;
    uVar32 = local_890;
    local_33c = local_88c;
    local_338 = local_888;
  }
  local_1080 = CONCAT44(local_1080._4_4_,local_940);
  local_1088 = CONCAT44(local_1088._4_4_,uVar8);
  local_3e0 = local_1008;
  local_3d8 = 0.1f;
  uStack_1018 = {d 0.75};
  local_1020 = (double){d 1.0472};
  uStack_3c8 = {d 0.75};
  local_3d0 = {d 1.0472};
  local_3c0 = 0.5;
  local_3b8 = {d 0.0078125};
  local_3b0 = 1f;
  local_3a4 = 0;
  local_3ac = 0;
  local_39c = 1;
  local_39b = local_944;
  local_399 = local_942;
  local_398 = local_ff8;
  local_390 = local_1000;
  local_388 = 0;
  local_387 = local_948;
  local_385 = local_946;
  local_384 = 0;
  local_37c = 0;
  local_374 = 1;
  local_373 = local_94c;
  local_371 = local_94a;
  local_370 = 0;
  local_1030 = CONCAT44(local_1030._4_4_,local_8ac);
  local_1038 = CONCAT44(local_1038._4_4_,local_33c);
  local_1040 = CONCAT44(local_1040._4_4_,local_338);
  local_324 = (undefined1)local_1044;
  local_321 = local_94e;
  local_323 = local_950;
  local_1050 = CONCAT44(local_1050._4_4_,uVar18);
  local_310 = (undefined1)uVar18;
  local_30d = local_952;
  local_30f = local_954;
  local_1058 = CONCAT44(local_1058._4_4_,uVar20);
  local_2fc = (undefined1)uVar20;
  local_2f9 = local_956;
  local_2fb = local_958;
  local_1070 = CONCAT44(local_1070._4_4_,local_83c);
  local_1078 = CONCAT44(local_1078._4_4_,local_838);
  puVar5 = &local_3f0;
  local_1090 = local_938;
  local_1064 = local_840;
  local_1060 = local_848;
  local_1028 = local_854;
  local_3f0 = local_940;
  local_3ec = uVar8;
  local_3e8 = local_938;
  local_368 = uVar14;
  local_360 = uVar22;
  local_358 = uVar15;
  local_350 = uVar16;
  local_348 = uVar25;
  local_340 = uVar32;
  local_334 = uVar6;
  local_32c = uVar7;
  local_320 = uVar11;
  local_318 = uVar12;
  local_30c = uVar13;
  local_304 = local_854;
  local_2f8 = local_848;
  local_2f0 = local_840;
  local_2ec = local_83c;
  local_2e8 = local_838;
  local_2e4 = uVar10;
  FUN_195ed8068(puVar5,local_610);
  if (((ulong)puVar5 & 1) == 0) {
    local_500 = (undefined4)local_1080;
    local_4fc = (undefined4)local_1088;
    local_4f8 = local_1090;
    local_4f0 = dVar1;
    local_4e8 = 0.1f;
    uStack_4d8 = uStack_1018;
    local_4e0 = local_1020;
    local_4d0 = 0.5;
    local_4c8 = uVar4;
    local_4c0 = 1f;
    local_4b4 = 0;
    local_4bc = 0;
    local_4ac = 1;
    local_4ab = local_944;
    local_4a9 = local_942;
    local_4a8 = uVar24;
    local_4a0 = uVar23;
    local_498 = 0;
    local_497 = local_948;
    local_495 = local_946;
    local_494 = 0;
    local_48c = 0;
    local_484 = 1;
    local_483 = local_94c;
    local_481 = local_94a;
    local_480 = 0;
    local_46c = (undefined4)local_1030;
    local_450 = CONCAT44((undefined4)local_1038,uVar32);
    local_448 = (undefined4)local_1040;
    local_434 = (undefined1)local_1044;
    local_431 = local_94e;
    local_433 = local_950;
    local_420 = (undefined1)local_1050;
    local_41d = local_952;
    local_41f = local_954;
    local_414 = local_1028;
    local_40c = (undefined1)local_1058;
    local_409 = local_956;
    local_40b = local_958;
    local_408 = local_1060;
    local_400 = local_1064;
    local_3fc = (undefined4)local_1070;
    local_3f8 = (undefined4)local_1078;
    local_478 = (double)uVar14;
    local_470 = uVar22;
    local_468 = uVar15;
    uStack_460 = uVar16;
    local_458 = uVar25;
    local_444 = uVar6;
    local_43c = uVar7;
    local_430 = uVar11;
    local_428 = uVar12;
    local_41c = uVar13;
    local_3f4 = uVar10;
    _CGPointMake(&local_500);
    func_0x000198104610(auStack_a68,&local_500,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_a68);
  }
  func_0x000198104610(local_ff0 + 0x1e8,auStack_a68,0x10d);
  uVar22 = 0x10d;
  func_0x000198104610(&local_b78,auStack_a68);
  iVar2 = (int)&local_b78;
  FUN_195e7d8c0();
  uVar24 = local_ff8;
  uVar23 = local_1000;
  dVar1 = local_1008;
  if (iVar2 == 1) {
    local_500 = 0;
    local_b58 = 0;
    local_b50 = 0;
    local_b48 = 0;
    local_b40 = 0;
    local_b3c = 0;
    local_b38 = 0;
    uVar18 = 1;
    uVar20 = 1;
    local_1064 = 1;
    local_af8 = 0;
    uVar19 = 0;
    uVar6 = 0;
    uVar7 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar32 = 0;
    uVar10 = 0;
    local_b74 = uVar22;
    local_b5c = uVar8;
    uVar22 = 0;
    uVar31 = 0;
    uVar8 = 0;
  }
  else {
    uVar18 = (uint)local_b24;
    local_b7a = local_b21;
    local_b7c = local_b23;
    uVar20 = (uint)local_b10;
    local_b7e = local_b0d;
    local_b80 = local_b0f;
    local_1064 = (uint)local_afc;
    local_b82 = local_af9;
    local_b84 = local_afb;
    local_b86 = local_aa9;
    local_b88 = local_aab;
    local_b8a = local_a95;
    local_b8c = local_a97;
    local_b8e = local_a81;
    local_b90 = local_a83;
    uVar19 = local_b0c;
    uVar6 = local_b04;
    uVar7 = local_b34;
    uVar11 = local_b2c;
    uVar12 = local_b20;
    uVar13 = local_b18;
    uVar14 = local_b70;
    uVar15 = local_b68;
    uVar32 = local_b60;
    uVar10 = local_a6c;
    local_500 = local_b78;
    uVar22 = local_a78;
    uVar31 = local_a74;
    uVar8 = local_a70;
  }
  local_1000 = CONCAT44(local_1000._4_4_,local_500);
  local_ff8 = CONCAT44(local_ff8._4_4_,local_b74);
  local_1008 = (double)CONCAT44(local_1008._4_4_,local_b5c);
  local_1040 = CONCAT44(local_1040._4_4_,local_b40);
  local_4c8 = CONCAT44(local_b3c,local_b40);
  local_1050 = CONCAT44(local_1050._4_4_,local_b38);
  local_1058 = CONCAT44(local_1058._4_4_,uVar18);
  local_4ac = (undefined1)uVar18;
  local_4a9 = local_b7a;
  local_4ab = local_b7c;
  local_1060 = CONCAT44(local_1060._4_4_,uVar20);
  local_498 = (undefined1)uVar20;
  local_497 = local_b80;
  local_495 = local_b7e;
  local_484 = (undefined1)local_1064;
  local_483 = local_b84;
  local_481 = local_b82;
  local_478 = dVar1;
  local_470 = 0.45f;
  uStack_460 = uStack_1018;
  local_468 = local_1020;
  local_458 = 0.5;
  local_450 = uVar4;
  local_448 = 1f;
  local_444 = 0;
  local_43c = 0;
  local_434 = 1;
  local_431 = local_b86;
  local_433 = local_b88;
  local_430 = uVar24;
  local_428 = uVar23;
  local_420 = 0;
  local_41d = local_b8a;
  local_41f = local_b8c;
  local_41c = 0;
  local_414 = 0;
  local_40c = 1;
  local_40b = local_b90;
  local_409 = local_b8e;
  local_408 = 0;
  puVar5 = &local_500;
  local_1070 = local_af8;
  local_1044 = local_b3c;
  local_1038 = local_b48;
  local_1030 = local_b50;
  local_1028 = local_b58;
  local_4fc = local_b74;
  local_4f8 = uVar14;
  local_4f0 = (double)uVar15;
  local_4e8 = uVar32;
  local_4e4 = local_b5c;
  local_4e0 = local_b58;
  uStack_4d8 = local_b50;
  local_4d0 = local_b48;
  local_4c0 = local_b38;
  local_4bc = uVar7;
  local_4b4 = uVar11;
  local_4a8 = uVar12;
  local_4a0 = uVar13;
  local_494 = uVar19;
  local_48c = uVar6;
  local_480 = local_af8;
  local_400 = uVar22;
  local_3fc = uVar31;
  local_3f8 = uVar8;
  local_3f4 = uVar10;
  uVar18 = local_1064;
  FUN_195ed8068(puVar5,local_610);
  if (((ulong)puVar5 & 1) == 0) {
    local_720 = (undefined4)local_1000;
    local_71c = (undefined4)local_ff8;
    local_704 = local_1008._0_4_;
    local_700 = local_1028;
    local_6f8 = local_1030;
    local_6f0 = local_1038;
    local_6e8 = (undefined4)local_1040;
    local_6e4 = local_1044;
    local_6e0 = (undefined4)local_1050;
    local_6cc = (undefined1)local_1058;
    local_6cb = local_b7c;
    local_6c9 = local_b7a;
    local_6b8 = (undefined1)local_1060;
    local_6b7 = local_b80;
    local_6b5 = local_b7e;
    local_6a4 = (undefined1)local_1064;
    local_6a3 = local_b84;
    local_6a1 = local_b82;
    local_6a0 = local_1070;
    local_698 = dVar1;
    local_690 = 0.45f;
    uStack_680 = uStack_1018;
    local_688 = local_1020;
    local_678 = 0.5;
    local_670 = uVar4;
    local_668 = 1f;
    local_664 = 0;
    local_65c = 0;
    local_654 = 1;
    local_651 = local_b86;
    local_653 = local_b88;
    local_650 = uVar24;
    local_648 = uVar23;
    local_640 = 0;
    local_63d = local_b8a;
    local_63f = local_b8c;
    local_63c = 0;
    local_634 = 0;
    local_62c = 1;
    local_62b = local_b90;
    local_629 = local_b8e;
    local_628 = 0;
    local_620 = CONCAT44(uVar31,uVar22);
    local_718 = uVar14;
    local_710 = uVar15;
    local_708 = uVar32;
    local_6dc = uVar7;
    local_6d4 = uVar11;
    local_6c8 = uVar12;
    local_6c0 = uVar13;
    local_6b4 = uVar19;
    local_6ac = uVar6;
    local_618 = uVar8;
    local_614 = uVar10;
    _CGPointMake(&local_720);
    func_0x000198104610(auStack_ca0,&local_720,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_ca0);
  }
  func_0x000198104610(local_ff0 + 0x1e8,auStack_ca0,0x10d);
  func_0x000198104610(&local_db0,auStack_ca0,0x10d);
  iVar2 = (int)&local_db0;
  FUN_195e7d8c0();
  uVar4 = {d 0.000170898};
  if (iVar2 == 1) {
    local_d3c = 0;
    local_cd8 = 0;
    local_ccc = 0;
    local_cc4 = 0;
    local_720 = 0;
    local_708 = 0;
    local_d74 = 0;
    uVar20 = 1;
    local_d70 = 0;
    local_1064 = 1;
    uVar17 = 1;
    local_d30 = 0;
    local_d28 = 0;
    local_d20 = 0;
    local_d18 = 0;
    local_d10 = 0;
    local_d08 = 0;
    local_d00 = 0;
    local_cfc = 0;
    local_cf8 = 0;
    uVar21 = 1;
    local_ff8 = CONCAT44(local_ff8._4_4_,1);
    local_1000 = CONCAT44(local_1000._4_4_,1);
    uVar6 = 0;
    uVar7 = 0;
    uVar11 = 0;
    uVar12 = 0;
    uVar13 = 0;
    uVar14 = 0;
    uVar15 = 0;
    uVar16 = 0;
    uVar25 = 0;
    uVar26 = 0;
    uVar28 = 0;
    uVar29 = 0;
    uVar30 = 0;
    uVar33 = 0;
    local_dac = uVar18;
    local_d94 = uVar9;
    uVar22 = 0;
    uVar10 = 0;
  }
  else {
    uVar20 = (uint)local_d5c;
    local_db2 = local_d59;
    local_db4 = local_d5b;
    local_1064 = (uint)local_d48;
    local_db6 = local_d45;
    local_db8 = local_d47;
    uVar17 = (uint)local_d34;
    local_dba = local_d31;
    local_dbc = local_d33;
    uVar19 = (ulong)local_d1c;
    uVar21 = (uint)local_ce4;
    local_dbe = local_ce1;
    local_dc0 = local_ce3;
    local_ff8 = CONCAT44(local_ff8._4_4_,(uint)local_cd0);
    local_dc2 = local_ccd;
    local_dc4 = local_ccf;
    local_1000 = CONCAT44(local_1000._4_4_,(uint)local_cbc);
    local_dc6 = local_cb9;
    local_dc8 = local_cbb;
    uVar6 = local_cec;
    uVar7 = local_ce0;
    uVar11 = local_d6c;
    uVar12 = local_d64;
    uVar13 = local_d58;
    uVar14 = local_d50;
    uVar15 = local_d44;
    uVar16 = local_cf4;
    uVar25 = local_da8;
    uVar26 = local_da0;
    uVar28 = local_d90;
    uVar29 = local_d88;
    uVar30 = local_d80;
    uVar33 = local_cb8;
    local_720 = local_db0;
    local_708 = local_d98;
    uVar22 = local_d78;
    uVar10 = local_ca4;
  }
  local_1038 = CONCAT44(local_1038._4_4_,local_720);
  local_1040 = CONCAT44(local_1040._4_4_,local_dac);
  local_10d0 = CONCAT44(local_10d0._4_4_,local_708);
  local_1050 = CONCAT44(local_1050._4_4_,local_d94);
  local_1060 = CONCAT44(local_1060._4_4_,local_d70);
  local_1058 = CONCAT44(local_1058._4_4_,uVar20);
  local_6cc = (undefined1)uVar20;
  local_6c9 = local_db2;
  local_6cb = local_db4;
  local_6b8 = (undefined1)local_1064;
  local_6b7 = local_db8;
  local_6b5 = local_db6;
  local_1070 = CONCAT44(local_1070._4_4_,uVar17);
  local_6a4 = (undefined1)uVar17;
  local_6a3 = local_dbc;
  local_6a1 = local_dba;
  local_1088 = CONCAT44(local_1088._4_4_,local_d20);
  local_68c = (undefined4)uVar19;
  local_1090 = CONCAT44(local_1090._4_4_,local_68c);
  local_10b0 = CONCAT44(local_10b0._4_4_,local_d00);
  local_10b8 = CONCAT44(local_10b8._4_4_,local_cfc);
  local_670 = CONCAT44(local_cfc,local_d00);
  local_10c8 = CONCAT44(local_10c8._4_4_,uVar21);
  local_654 = (undefined1)uVar21;
  local_651 = local_dbe;
  local_653 = local_dc0;
  local_640 = (undefined1)local_ff8;
  local_63d = local_dc2;
  local_63f = local_dc4;
  local_62c = (undefined1)local_1000;
  local_629 = local_dc6;
  local_62b = local_dc8;
  local_620 = {d 0.000170898};
  local_618 = 0.15f;
  puVar5 = &local_720;
  local_10bc = local_cf8;
  local_10a8 = local_d08;
  local_10a0 = local_d10;
  local_1098 = local_d18;
  local_1080 = local_d28;
  local_1078 = local_d30;
  local_1044 = local_d74;
  local_1030 = local_d3c;
  local_1028 = local_cc4;
  local_1020 = (double)local_ccc;
  local_1008 = (double)local_cd8;
  local_71c = local_dac;
  local_718 = uVar25;
  local_710 = uVar26;
  local_704 = local_d94;
  local_700 = uVar28;
  local_6f8 = uVar29;
  local_6f0 = uVar30;
  local_6e8 = uVar22;
  local_6e4 = local_d74;
  local_6e0 = local_d70;
  local_6dc = uVar11;
  local_6d4 = uVar12;
  local_6c8 = uVar13;
  local_6c0 = uVar14;
  local_6b4 = uVar15;
  local_6ac = local_d3c;
  local_6a0 = local_d30;
  local_698 = (double)local_d28;
  local_690 = local_d20;
  local_688 = local_d18;
  uStack_680 = local_d10;
  local_678 = local_d08;
  local_668 = local_cf8;
  local_664 = uVar16;
  local_65c = uVar6;
  local_650 = uVar7;
  local_648 = local_cd8;
  local_63c = local_ccc;
  local_634 = local_cc4;
  local_628 = uVar33;
  local_614 = uVar10;
  FUN_195ed8068(puVar5,local_610);
  if (((ulong)puVar5 & 1) == 0) {
    local_fe8 = (undefined4)local_1038;
    local_fe4 = (undefined4)local_1040;
    local_fd0 = (undefined4)local_10d0;
    local_fcc = (undefined4)local_1050;
    local_fac = local_1044;
    local_fa8 = (undefined4)local_1060;
    local_f94 = (undefined1)local_1058;
    local_f93 = local_db4;
    local_f91 = local_db2;
    local_f80 = (undefined1)local_1064;
    local_f7d = local_db6;
    local_f7f = local_db8;
    local_f74 = local_1030;
    local_f6c = (undefined1)local_1070;
    local_f69 = local_dba;
    local_f6b = local_dbc;
    local_f68 = local_1078;
    uStack_f60 = local_1080;
    local_f58 = (undefined4)local_1088;
    local_f54 = (undefined4)local_1090;
    local_f50 = local_1098;
    uStack_f48 = local_10a0;
    local_f40 = local_10a8;
    local_f38 = (undefined4)local_10b0;
    local_f34 = (undefined4)local_10b8;
    local_f30 = local_10bc;
    local_f1c = (undefined1)local_10c8;
    local_f19 = local_dbe;
    local_f1b = local_dc0;
    uStack_f10 = local_1008;
    local_f08 = (undefined1)local_ff8;
    local_f05 = local_dc2;
    local_f07 = local_dc4;
    local_f04 = local_1020;
    local_efc = local_1028;
    local_ef4 = (undefined1)local_1000;
    local_ef1 = local_dc6;
    local_ef3 = local_dc8;
    local_ee8 = uVar4;
    local_ee0 = 0.15f;
    local_fe0 = uVar25;
    uStack_fd8 = uVar26;
    local_fc8 = uVar28;
    uStack_fc0 = uVar29;
    local_fb8 = uVar30;
    local_fb0 = uVar22;
    local_fa4 = uVar11;
    local_f9c = uVar12;
    local_f90 = uVar13;
    uStack_f88 = uVar14;
    local_f7c = uVar15;
    local_f2c = uVar16;
    local_f24 = uVar6;
    local_f18 = uVar7;
    local_ef0 = uVar33;
    local_edc = uVar10;
    _CGPointMake(&local_fe8);
    func_0x000198104610(auStack_ed8,&local_fe8,0x10d);
  }
  else {
    FUN_195e7d8d4(auStack_ed8);
  }
  func_0x000198104610(local_ff0 + 0x1e8,auStack_ed8,0x10d);
  return;
}


//######## SiriRecipe.anon.SiriContourGradientModifier (params) 0x195f2ec04
// === 195f30624 params

/* WARNING: Removing unreachable block (ram,0x000195f30708) */
/* WARNING: Removing unreachable block (ram,0x000195f30690) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f30624(long param_1,long param_2)
{
  uint3 *puVar1;
  ushort uVar3;
  undefined1 auStack_d0 [8];
  lVar5 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar5 + -8);
  local_c8 = lVar5;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar11 = auStack_d0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar13 = (long)puVar11 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  FUN_195ed0900();
  puVar1 = (uint3 *)(param_2 + *(int *)(lVar6 + 0x20));
  uVar3 = (ushort)*puVar1;
  cVar2 = *(char *)((long)puVar1 + 2);
  uVar7 = (ulong)*puVar1;
  FUN_195e5f470(uVar7,0x1000f);
  if ((uVar7 & 1) != 0) {
    lVar6 = 0;
    FUN_195f3c68c();
    iVar4 = *(int *)(lVar6 + 0x18);
    (**(code **)(lVar9 + 0x68))(lVar13,*_DAT_1e017dd58,lVar5);
    uVar7 = param_2 + iVar4;
    func_0x000198120100(uVar7,lVar13);
    (**(code **)(lVar9 + 8))(lVar13,lVar5);
    if ((uVar7 & 1) != 0) {
      puVar10 = (undefined8 *)(<+0x858>);
      if (<+0x88c> == '\x01') {
        if (DAT_1eda3b1f0 != -1) {
          func_0x000198104ff0(&DAT_1eda3b1f0,FUN_195ed69d8);
        }
        puVar10 = (undefined8 *)&DAT_1eda463b8;
      }
      uVar15 = *puVar10;
      uVar18 = puVar10[3];
      uVar17 = puVar10[2];
      uVar21 = puVar10[5];
      uVar20 = puVar10[4];
      <+0x860> = puVar10[1];
      <+0x858> = uVar15;
      <+0x870> = uVar18;
      <+0x868> = uVar17;
      <+0x880> = uVar21;
      <+0x878> = uVar20;
      <+0x888> = 0;
      goto LAB_195f3090c;
    }
  }
  lVar5 = local_c8;
  if ((cVar2 == '\x01') && (0x24 < uVar3 - 0x10 && 9 < uVar3)) {
    if (0xc < uVar3) {
      if (uVar3 != 0xd) {
        if (uVar3 != 0xe) {
          (**(code **)(lVar8 + 0x68))(puVar11,*_DAT_1e01830d0,local_c8);
          uVar24 = 0.01569f;
          uVar25 = 0.07843f;
          uVar26 = 0.102f;
          uVar23 = 1f;
          func_0x0001981218c0(puVar11);
          uVar27 = 0.2f;
          uVar22 = 0.3359f;
          uVar14 = uVar24;
          uVar16 = uVar25;
          uVar19 = uVar26;
          goto LAB_195f308cc;
        }
        uVar27 = *_DAT_1e01830d0;
        pcVar12 = *(code **)(lVar8 + 0x68);
        (*pcVar12)(puVar11,uVar27,local_c8);
        uVar23 = 0.5f;
        goto LAB_195f3087c;
      }
LAB_195f309ac:
      uVar27 = *_DAT_1e01830d0;
      pcVar12 = *(code **)(lVar8 + 0x68);
      (*pcVar12)(puVar11,uVar27,local_c8);
      uVar24 = 0;
      uVar25 = 0;
      uVar26 = 0;
      uVar23 = 1f;
      func_0x0001981218c0(puVar11);
      (*pcVar12)(puVar11,uVar27,lVar5);
      uVar22 = 0.5f;
      goto LAB_195f308c4;
    }
    if (uVar3 != 10) {
      if (uVar3 == 0xb) goto LAB_195f309ac;
      goto LAB_195f3083c;
    }
    uVar27 = *_DAT_1e01830d0;
    pcVar12 = *(code **)(lVar8 + 0x68);
    (*pcVar12)(puVar11,uVar27,local_c8);
    uVar24 = 0;
    uVar25 = 0;
    uVar26 = 0;
    uVar23 = 1f;
    func_0x0001981218c0(puVar11);
    (*pcVar12)(puVar11,uVar27,lVar5);
    uVar14 = 0;
    uVar16 = 0;
    uVar19 = 0;
    uVar22 = 0;
    func_0x0001981218c0(puVar11);
    uVar27 = 0.5f;
  }
  else {
LAB_195f3083c:
    uVar27 = *_DAT_1e01830d0;
    pcVar12 = *(code **)(lVar8 + 0x68);
    (*pcVar12)(puVar11,uVar27,local_c8);
    uVar23 = 1f;
LAB_195f3087c:
    uVar26 = 0;
    uVar25 = 0;
    uVar24 = 0;
    func_0x0001981218c0(puVar11);
    (*pcVar12)(puVar11,uVar27,lVar5);
    uVar22 = 0.2f;
LAB_195f308c4:
    uVar19 = 0;
    uVar16 = 0;
    uVar14 = 0;
    uVar27 = 0;
    func_0x0001981218c0(puVar11);
  }
LAB_195f308cc:
  <+0x858> = uVar27;
  <+0x85c> = uVar24;
  <+0x860> = uVar25;
  <+0x864> = uVar26;
  <+0x868> = uVar23;
  <+0x86c> = uVar14;
  <+0x870> = uVar16;
  <+0x874> = uVar19;
  <+0x878> = uVar22;
  <+0x880> = 3.14159;
  <+0x888> = 1f;
LAB_195f3090c:
  <+0x88c> = 0;
  return;
}


//######## TabRecipe.Normal (spec) 0x195f32cc4
// === 195f33380 spec

/* WARNING: Removing unreachable block (ram,0x000195f3345c) */
/* WARNING: Removing unreachable block (ram,0x000195f333e4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f33380(long param_1,long param_2)
{
  undefined1 auStack_1b0 [80];
  lVar5 = 0;
  func_0x0001981217d0();
  lVar9 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  puVar13 = auStack_1b0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  func_0x000198120110();
  lVar10 = *(long *)(lVar6 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar10 + 0x40));
  lVar16 = (long)puVar13 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar7 = 0;
  FUN_195f3c68c();
  iVar4 = *(int *)(lVar7 + 0x18);
  lVar7 = lVar16;
  (**(code **)(lVar10 + 0x68))(lVar16,*_DAT_1e017dd58,lVar6);
  FUN_195e7d9c0();
  uVar8 = param_2 + iVar4;
  func_0x0001980ff320(uVar8,lVar16,lVar6,lVar7);
  (**(code **)(lVar10 + 8))(lVar16,lVar6);
  <faceEffect.ycc.black> = 0.0078125;
  (**(code **)(lVar9 + 0x68))(puVar13,*_DAT_1e01830d0,lVar5);
  uVar20 = 0.15f;
  uVar17 = 1f;
  uVar18 = 1f;
  uVar19 = 1f;
  func_0x0001981218c0(puVar13);
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar20 >> 0x18),
                CONCAT16((char)((uint)uVar20 >> 0x10),
                         CONCAT15((char)((uint)uVar20 >> 8),CONCAT14((char)uVar20,uVar19))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((uint)uVar18 >> 0x18),
                CONCAT16((char)((uint)uVar18 >> 0x10),
                         CONCAT15((char)((uint)uVar18 >> 8),CONCAT14((char)uVar18,uVar17))));
  <faceEffect.ycc.normalFill?nil> = 0;
  <faceEffect.ycc.saturation> = 1f;
  uVar11 = <+0x6a8>;
  if (((uVar11 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    uVar15 = <+0x690>;
    uVar14 = <+0x698>;
    uVar12 = <+0x6a0>;
    puVar1 = (undefined8 *)(<+0x6b0>);
    local_f0 = *puVar1;
    puVar2 = (undefined8 *)(<+0x6b8>);
    uStack_e8 = *puVar2;
    puVar3 = (undefined8 *)(<+0x6c0>);
    local_b0 = (undefined6)uVar12;
    uStack_aa = (undefined2)((ulong)uVar12 >> 0x30);
    uStack_a8 = (undefined6)uVar11;
    uStack_a2 = (undefined2)(uVar11 >> 0x30);
    local_a0 = CONCAT44(local_a0._4_4_,*(undefined4 *)puVar1);
    uStack_98 = CONCAT44(uStack_98._4_4_,*(undefined4 *)puVar2);
    local_90 = *puVar3;
    uStack_88 = (undefined6)<+0x6c8>;
    uStack_7a = <+0x6d6>;
    uStack_82 = (undefined2)<+0x6ce>;
    uStack_80 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    local_110 = uVar15;
    uStack_108 = uVar14;
    local_100 = uVar12;
    uStack_f8 = uVar11;
    local_c0 = uVar15;
    uStack_b8 = uVar14;
    if ((uVar8 & 1) == 0) {
      local_a0 = CONCAT44(<+0x6b4> + -0.05,*(undefined4 *)puVar1);
      uStack_98 = CONCAT44(<+0x6bc> + -0.05,*(undefined4 *)puVar2);
      local_e0 = *puVar3;
      uStack_d8 = (undefined6)<+0x6c8>;
      uStack_ca = <+0x6d6>;
      uStack_d2 = (undefined2)<+0x6ce>;
      uStack_d0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
      FUN_195ef7fcc(&local_110,&local_160);
    }
    else {
      local_e0 = *puVar3;
      uStack_d8 = (undefined6)<+0x6c8>;
      uStack_ca = <+0x6d6>;
      uStack_d2 = (undefined2)<+0x6ce>;
      uStack_d0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
      local_f0 = *puVar1;
      uStack_e8 = *puVar2;
      FUN_195ef7fcc(&local_110,&local_160);
      FUN_195ef0f04(uVar15,uVar14,uVar12,uVar11,uVar11 >> 0x28);
      uStack_98 = {d 0.0078125};
      local_a0 = {d -0.0078125};
      local_c0 = 0.15f;
      uStack_b8 = 0;
      local_b0 = 0;
      uStack_aa = 0;
      uStack_a8 = 0;
    }
    uStack_138 = uStack_98;
    local_140 = local_a0;
    uStack_128 = uStack_88;
    uStack_130 = local_90;
    uStack_11a = uStack_7a;
    local_122 = uStack_82;
    uStack_120 = uStack_80;
    uStack_148 = CONCAT26(uStack_a2,uStack_a8);
    uStack_150 = CONCAT26(uStack_aa,local_b0);
    uStack_158 = uStack_b8;
    local_160 = local_c0;
    uStack_e8 = <+0x6b8>;
    local_f0 = <+0x6b0>;
    local_e0 = <+0x6c0>;
    uStack_d8 = (undefined6)<+0x6c8>;
    uStack_ca = <+0x6d6>;
    uStack_d2 = (undefined2)<+0x6ce>;
    uStack_d0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    uStack_108 = <+0x698>;
    local_110 = <+0x690>;
    uStack_f8 = <+0x6a8>;
    local_100 = <+0x6a0>;
    FUN_195ef7fcc(&local_160,auStack_1b0);
    FUN_195f33ac4(&local_110);
    <+0x6b8> = uStack_98;
    <+0x6b0> = local_a0;
    <+0x6c8> = CONCAT26(uStack_82,uStack_88);
    <+0x6c0> = local_90;
    <+0x6d6> = uStack_7a;
    <+0x6ce> = CONCAT62(uStack_80,uStack_82);
    <+0x698> = uStack_b8;
    <+0x690> = local_c0;
    <+0x6a8> = CONCAT26(uStack_a2,uStack_a8);
    <+0x6a0> = CONCAT26(uStack_aa,local_b0);
    FUN_195ef82d0(&local_c0);
  }
  return;
}


//######## TabRecipe.Inactive (spec) 0x195f32cc8
// === 195f33728 spec

/* WARNING: Removing unreachable block (ram,0x000195f33808) */
/* WARNING: Removing unreachable block (ram,0x000195f33790) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f33728(long param_1,long param_2)
{
  undefined1 auStack_1c0 [80];
  lVar4 = 0;
  func_0x0001981217d0();
  lVar8 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar8 + 0x40));
  puVar12 = auStack_1c0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar5 = 0;
  func_0x000198120110();
  lVar9 = *(long *)(lVar5 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar9 + 0x40));
  lVar15 = (long)puVar12 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  lVar6 = 0;
  FUN_195f3c68c();
  iVar2 = *(int *)(lVar6 + 0x18);
  lVar6 = lVar15;
  (**(code **)(lVar9 + 0x68))(lVar15,*_DAT_1e017dd58,lVar5);
  FUN_195e7d9c0();
  uVar7 = param_2 + iVar2;
  func_0x0001980ff320(uVar7,lVar15,lVar5,lVar6);
  (**(code **)(lVar9 + 8))(lVar15,lVar5);
  bVar3 = (uVar7 & 1) == 0;
  uVar16 = 0;
  if (bVar3) {
    uVar16 = 0.75f;
  }
  uVar17 = 1f;
  if (bVar3) {
    uVar17 = 0.95f;
  }
  uVar19 = 0.07f;
  if (bVar3) {
    uVar19 = 0.3f;
  }
  <faceEffect.ycc.black> = uVar16;
  <faceEffect.ycc.white> = uVar17;
  (**(code **)(lVar8 + 0x68))(puVar12,*_DAT_1e01830d0,lVar4);
  uVar16 = 1f;
  uVar17 = 1f;
  uVar18 = 1f;
  func_0x0001981218c0(puVar12);
  <faceEffect.ycc.normalFill.b> =
       CONCAT17((char)((uint)uVar19 >> 0x18),
                CONCAT16((char)((uint)uVar19 >> 0x10),
                         CONCAT15((char)((uint)uVar19 >> 8),CONCAT14((char)uVar19,uVar18))));
  <faceEffect.ycc.normalFill.r> =
       CONCAT17((char)((uint)uVar17 >> 0x18),
                CONCAT16((char)((uint)uVar17 >> 0x10),
                         CONCAT15((char)((uint)uVar17 >> 8),CONCAT14((char)uVar17,uVar16))));
  <faceEffect.ycc.normalFill?nil> = 0;
  uVar10 = <+0x6a8>;
  if (((uVar10 ^ 0xffffffffffffffff) & 0xff0000000000) != 0) {
    uVar14 = <+0x690>;
    uVar13 = <+0x698>;
    uVar11 = <+0x6a0>;
    puVar1 = (undefined8 *)(<+0x6b0>);
    local_c0 = (undefined6)uVar11;
    uStack_ba = (undefined2)((ulong)uVar11 >> 0x30);
    uStack_b8 = (undefined6)uVar10;
    uStack_b2 = (undefined2)(uVar10 >> 0x30);
    uStack_a8 = <+0x6b8>;
    local_b0 = *puVar1;
    uStack_a0 = <+0x6c0>;
    uStack_98 = (undefined6)<+0x6c8>;
    uStack_8a = <+0x6d6>;
    local_92 = (undefined2)<+0x6ce>;
    uStack_90 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    local_120 = uVar14;
    uStack_118 = uVar13;
    local_110 = uVar11;
    uStack_108 = uVar10;
    local_d0 = uVar14;
    uStack_c8 = uVar13;
    if ((uVar7 & 1) == 0) {
      uVar7 = (ulong)local_b0 >> 0x20;
      local_b0 = CONCAT44((int)uVar7,0.1f);
      uVar7 = (ulong)uStack_a8 >> 0x20;
      uStack_a8 = CONCAT44((int)uVar7,1f);
      uStack_f8 = <+0x6b8>;
      local_100 = *puVar1;
      uStack_f0 = <+0x6c0>;
      uStack_e8 = (undefined6)<+0x6c8>;
      uStack_da = <+0x6d6>;
      local_e2 = (undefined2)<+0x6ce>;
      uStack_e0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
      FUN_195ef7fcc(&local_120,&local_170);
    }
    else {
      uStack_f8 = <+0x6b8>;
      local_100 = *puVar1;
      uStack_f0 = <+0x6c0>;
      uStack_e8 = (undefined6)<+0x6c8>;
      uStack_da = <+0x6d6>;
      local_e2 = (undefined2)<+0x6ce>;
      uStack_e0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
      FUN_195ef7fcc(&local_120,&local_170);
      FUN_195ef0f04(uVar14,uVar13,uVar11,uVar10,uVar10 >> 0x28);
      uStack_a8 = {d 0.0078125};
      local_b0 = {d -0.0078125};
      local_d0 = 0.07f;
      uStack_c8 = 0;
      local_c0 = 0;
      uStack_ba = 0;
      uStack_b8 = 0;
    }
    uStack_148 = uStack_a8;
    local_150 = local_b0;
    uStack_138 = uStack_98;
    uStack_140 = uStack_a0;
    uStack_12a = uStack_8a;
    local_132 = local_92;
    uStack_130 = uStack_90;
    uStack_158 = CONCAT26(uStack_b2,uStack_b8);
    uStack_160 = CONCAT26(uStack_ba,local_c0);
    uStack_168 = uStack_c8;
    local_170 = local_d0;
    uStack_f8 = <+0x6b8>;
    local_100 = <+0x6b0>;
    uStack_f0 = <+0x6c0>;
    uStack_e8 = (undefined6)<+0x6c8>;
    uStack_da = <+0x6d6>;
    local_e2 = (undefined2)<+0x6ce>;
    uStack_e0 = (undefined6)((ulong)<+0x6ce> >> 0x10);
    uStack_118 = <+0x698>;
    local_120 = <+0x690>;
    uStack_108 = <+0x6a8>;
    local_110 = <+0x6a0>;
    FUN_195ef7fcc(&local_170,auStack_1c0);
    FUN_195f33ac4(&local_120);
    <+0x6b8> = uStack_a8;
    <+0x6b0> = local_b0;
    <+0x6c8> = CONCAT26(local_92,uStack_98);
    <+0x6c0> = uStack_a0;
    <+0x6d6> = uStack_8a;
    <+0x6ce> = CONCAT62(uStack_90,local_92);
    <+0x698> = uStack_c8;
    <+0x690> = local_d0;
    <+0x6a8> = CONCAT26(uStack_b2,uStack_b8);
    <+0x6a0> = CONCAT26(uStack_ba,local_c0);
    FUN_195ef82d0(&local_d0);
  }
  return;
}


//######## TabRecipe.ApplyReducedTransparency (spec) 0x195f32ccc
// === 195f33084 spec

/* WARNING: Removing unreachable block (ram,0x000195f3315c) */
/* WARNING: Removing unreachable block (ram,0x000195f330e4) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f33084(long param_1,long param_2)
{
  undefined1 auVar12 [16];
  lVar3 = 0;
  func_0x0001981217d0();
  lVar6 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar6 + 0x40));
  puVar8 = &stack0xffffffffffffff90 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar4 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  lVar9 = (long)puVar8 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  <refraction.outerOpacity> = 0;
  <refraction.normalizedOuterAmount> = 0;
  <refraction.outerHeightRange.hi> = 0;
  <refraction.outerAmountRange.hi> = 0;
  <refraction.outerAmountRange.lo> = 0;
  <refraction.innerAmountRange.hi> = 0;
  <refraction.innerAmountRange.lo> = 0;
  <refraction.outerHeightRange.lo> = 0;
  <refraction.normalizedOuterHeight> = 0;
  <refraction.innerHeightRange.lo> = 0;
  <refraction.normalizedInnerHeight> = 0;
  <refraction.normalizedInnerAmount> = 0;
  <refraction.innerHeightRange.hi> = 0;
  FUN_195eda468(<edgeBleed.opacity>,<+0x210>,
                <+0x218>,<+0x220>,
                <+0x228>,<+0x230>,
                <+0x231>);
  <+0x22a> = 0;
  <+0x222> = 0;
  <+0x210> = 0;
  <edgeBleed.opacity> = 0;
  <+0x220> = 0;
  <+0x218> = 0;
  auVar12 = NEON_fmov(1f,4);
  <blur.opacities.2> = auVar12._8_8_;
  <blur.opacities.0> = auVar12._0_8_;
  FUN_195eda468(<blur.blurRadius>,<+0x170>,
                <+0x178>,<+0x180>,
                <+0x188>,<+0x190>,
                <+0x191>);
  <blur.blurRadius> = 10f;
  lVar5 = 0;
  FUN_195f3c68c();
  <+0x178> = 0;
  <+0x170> = 0;
  <+0x188> = 0;
  <+0x180> = 0;
  <+0x190> = 0;
  iVar1 = *(int *)(lVar5 + 0x18);
  lVar5 = lVar9;
  (**(code **)(lVar7 + 0x68))(lVar9,*_DAT_1e017dd58,lVar4);
  FUN_195e7d9c0();
  uVar11 = param_2 + iVar1;
  func_0x0001980ff320(uVar11,lVar9,lVar4,lVar5);
  (**(code **)(lVar7 + 8))(lVar9,lVar4);
  bVar2 = (uVar11 & 1) == 0;
  uVar13 = 0.1f;
  if (bVar2) {
    uVar13 = 0.85f;
  }
  uVar15 = 0.5f;
  if (bVar2) {
    uVar15 = 1f;
  }
  uVar14 = 0.7f;
  if (bVar2) {
    uVar14 = 0.9f;
  }
  <faceEffect.ycc.black> = uVar13;
  <faceEffect.ycc.white> = uVar15;
  <faceEffect.ycc.saturation> = uVar14;
  fVar10 = 0.0;
  if (<faceEffect.ycc.normalFill?nil> != '\x01') {
    fVar10 = <faceEffect.ycc.normalFill.a>;
  }
  fVar16 = 0.15;
  if (0.15 < fVar10) {
    fVar16 = fVar10;
  }
  (**(code **)(lVar6 + 0x68))(puVar8,*_DAT_1e01830d0,lVar3);
  uVar13 = 1f;
  uVar15 = 1f;
  uVar11 = func_0x0001981218c0(puVar8);
  uVar11 = uVar11 & 0xffffffff;
  <faceEffect.ycc.normalFill.b> = (char)uVar15;
  <+0x2b9> = (char)((uint)uVar15 >> 8);
  <+0x2ba> = (char)((uint)uVar15 >> 0x10);
  <+0x2bb> = (char)((uint)uVar15 >> 0x18);
  <faceEffect.ycc.normalFill.a> = SUB41(fVar16,0);
  <+0x2bd> = (char)((uint)fVar16 >> 8);
  <+0x2be> = (char)((uint)fVar16 >> 0x10);
  <+0x2bf> = (char)((uint)fVar16 >> 0x18);
  <faceEffect.ycc.normalFill.r> = (char)uVar11;
  <+0x2b1> = (char)(uVar11 >> 8);
  <+0x2b2> = (char)(uVar11 >> 0x10);
  <+0x2b3> = (char)(uVar11 >> 0x18);
  <faceEffect.ycc.normalFill.g> = (char)uVar13;
  <+0x2b5> = (char)((uint)uVar13 >> 8);
  <+0x2b6> = (char)((uint)uVar13 >> 0x10);
  <+0x2b7> = (char)((uint)uVar13 >> 0x18);
  <faceEffect.ycc.normalFill?nil> = 0;
  return;
}


//######## TabRecipe.ApplyIncreasedContrast (spec) 0x195f32cd0
// === 195f32cd0 spec

/* WARNING: Removing unreachable block (ram,0x000195f32d24) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f32cd0(long param_1,long param_2)
{
  lVar3 = 0;
  func_0x000198120110();
  lVar7 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar7 + 0x40));
  puVar8 = &stack0xffffffffffffffc0 + -(extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195f3c68c();
  iVar1 = *(int *)(lVar4 + 0x18);
  puVar5 = puVar8;
  (**(code **)(lVar7 + 0x68))(puVar8,*_DAT_1e017dd58,lVar3);
  FUN_195e7d9c0();
  uVar6 = param_2 + iVar1;
  func_0x0001980ff320(uVar6,puVar8,lVar3,puVar5);
  (**(code **)(lVar7 + 8))(puVar8,lVar3);
  bVar2 = (uVar6 & 1) == 0;
  lVar3 = 0x2a8;
  if (bVar2) {
    lVar3 = 0x2a4;
  }
  fVar9 = -0.5;
  if (bVar2) {
    fVar9 = 0.5;
  }
  uVar10 = 0.7f;
  if (bVar2) {
    uVar10 = 0.8f;
  }
  *(float *)(param_1 + lVar3) = *(float *)(param_1 + lVar3) + fVar9;
  <faceEffect.ycc.saturation> = uVar10;
  return;
}


//######## V2TextDefaults (spec) 0x195f33f48
// === 195f33f48 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f33f48(long param_1,double *param_2)
{
  lVar5 = 0;
  FUN_195ef0f6c();
  uVar2 = {d 8};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x28));
  puVar1[1] = {d 4};
  *puVar1 = uVar2;
  puVar1[2] = 5;
  *(undefined4 *)(puVar1 + 3) = 0;
  puVar1[4] = 0;
  uVar4 = {d 2.0944};
  uVar3 = {d 1.5708};
  uVar2 = {d 1};
  dVar6 = *param_2;
  dVar7 = dVar6 * -2.0;
  if (0.5 <= dVar6) {
    dVar7 = -dVar6;
  }
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x2c));
  puVar1[1] = {d 1.5708};
  *puVar1 = uVar2;
  puVar1[3] = uVar4;
  puVar1[2] = uVar3;
  puVar1[4] = 0.5;
  puVar1[5] = dVar7;
  puVar1[6] = -0.2;
  return;
}


//######## TextRegularAODSpec (spec) 0x195f33ff4
// === 195f35b78 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f35b78(long param_1)
{
  puVar6 = &DAT_1eb9ca9c0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9ca9c0,&{f 2.42977e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar6 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  puVar8 = &stack0xffffffffffffffd0 + -extraout_x8;
  func_0x000198123100(puVar8,0.5,0.5,1,
                      0.37);
  lVar7 = 0;
  func_0x000198123120();
  (**(code **)(*(long *)(lVar7 + -8) + 0x38))(puVar8,0,1,lVar7);
  FUN_195ef581c(puVar8,param_1);
  lVar7 = 0;
  FUN_195ef0f6c();
  uVar9 = {d 0.0078125};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x14));
  puVar1[1] = {d 3.05176e-05};
  *puVar1 = uVar9;
  puVar1[2] = 3.05176e-05;
  *(undefined1 *)(puVar1 + 3) = 1;
  *(undefined4 *)((long)puVar1 + 0x1c) = -1f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x18));
  puVar1[5] = 0;
  puVar1[4] = 0;
  puVar1[7] = 0;
  puVar1[6] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar7 + 0x1c));
  *puVar2 = 0;
  uVar3 = {d 1};
  uVar9 = {d 0};
  *(undefined8 *)(puVar2 + 4) = {d 1};
  *(undefined8 *)(puVar2 + 2) = uVar9;
  uVar5 = {d 60};
  uVar4 = {d -10};
  *(undefined8 *)(puVar2 + 8) = {d 60};
  *(undefined8 *)(puVar2 + 6) = uVar4;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 0;
  *(undefined8 *)(puVar2 + 0x28) = uVar3;
  *(undefined8 *)(puVar2 + 0x26) = uVar9;
  *(undefined8 *)(puVar2 + 0x2c) = uVar5;
  *(undefined8 *)(puVar2 + 0x2a) = uVar4;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar9 = {d 9.76563e-05};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x20));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar9;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.0078125};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar9 = NEON_fmov(1f,4);
  puVar1[5] = uVar9;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x28));
  *puVar1 = 0;
  puVar1[1] = 0;
  puVar1[2] = 1;
  *(undefined4 *)(puVar1 + 3) = 0;
  puVar1[4] = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x2c));
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  puVar1[5] = 0;
  puVar1[6] = 0;
  puVar1[4] = 1;
  return;
}


//######## TintedFaceEffectsOverride (spec) 0x195f33ff8
// === 195f33ff8 spec

void FUN_195f33ff8(long param_1)
{
  lVar1 = 0;
  FUN_195ef0f6c();
  *(undefined4 *)(param_1 + *(int *)(lVar1 + 0x20)) = 0;
  return;
}


//######## TextRegularClearSpec (spec) 0x195f3402c
// === 195f36200 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f36200(long param_1)
{
  puVar5 = &DAT_1eb9ca9c0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9ca9c0,&{f 2.42977e-40, 9.80909e-45});
  plVar6 = (long *)(puVar5 + -8);
  (*_DAT_1e2125200)(*(long *)(*plVar6 + 0x40) + 0xfU & 0xfffffffffffffff0);
  puVar8 = &stack0xffffffffffffffd0 + -extraout_x8;
  FUN_195ed53f0();
  func_0x000198123100(puVar8,0.5,0.5,1,
                      0.37);
  lVar7 = 0;
  func_0x000198123120();
  (**(code **)(*(long *)(lVar7 + -8) + 0x38))(puVar8,0,1,lVar7);
  FUN_195ef581c(puVar8,param_1);
  lVar7 = 0;
  FUN_195ef0f6c();
  uVar9 = {f 1, 0};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x14));
  puVar1[1] = {d 3.05176e-05};
  *puVar1 = uVar9;
  puVar1[2] = 3.05176e-05;
  *(undefined1 *)(puVar1 + 3) = 1;
  *(undefined4 *)((long)puVar1 + 0x1c) = -1f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  uVar3 = {d -80};
  uVar9 = {d -20};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x18));
  puVar1[1] = {d -80};
  *puVar1 = uVar9;
  puVar1[3] = uVar3;
  puVar1[2] = uVar9;
  uVar3 = {d 6};
  uVar9 = {d 0};
  puVar1[5] = {d 6};
  puVar1[4] = uVar9;
  puVar1[7] = uVar3;
  puVar1[6] = uVar9;
  uVar9 = 80;
  if (((ulong)plVar6 & 1) == 0) {
    uVar9 = 50;
  }
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar7 + 0x1c));
  *puVar2 = 1f;
  uVar4 = {d 1};
  uVar3 = {d 0};
  *(undefined8 *)(puVar2 + 4) = {d 1};
  *(undefined8 *)(puVar2 + 2) = uVar3;
  *(undefined8 *)(puVar2 + 6) = 10;
  *(undefined8 *)(puVar2 + 8) = uVar9;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 1f;
  *(undefined8 *)(puVar2 + 0x28) = uVar4;
  *(undefined8 *)(puVar2 + 0x26) = uVar3;
  *(undefined8 *)(puVar2 + 0x2a) = 10;
  *(undefined8 *)(puVar2 + 0x2c) = uVar9;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar9 = {f 0, 0.2};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x20));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar9;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.000488281};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar9 = NEON_fmov(1f,4);
  puVar1[5] = uVar9;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## TextRegularLegacyFrostedSpec (spec) 0x195f34030
// === 195f367d0 spec

/* WARNING: Removing unreachable block (ram,0x000195f3687c) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f367d0(long param_1)
{
  puVar8 = &DAT_1eb9ca9c0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9ca9c0,&{f 2.42977e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar8 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  lVar12 = (long)&local_70 - extraout_x8;
  uVar9 = 0;
  func_0x0001981217d0();
  lVar11 = *(long *)(uVar9 - 8);
  uVar10 = uVar9;
  (*_DAT_1e2125200)(*(undefined8 *)(lVar11 + 0x40));
  lVar13 = lVar12 - (extraout_x8_00 + 0xfU & 0xfffffffffffffff0);
  FUN_195ed53f0();
  bVar3 = (uVar10 & 1) == 0;
  if (bVar3) {
    (**(code **)(lVar11 + 0x68))(lVar13,*_DAT_1e01830d0,uVar9);
    uVar18 = 1f;
    uVar14 = 1f;
    uVar15 = 1f;
    uVar16 = 1f;
    uVar17 = 0;
    func_0x0001981218c0(lVar13);
    uVar19 = 40;
    uVar20 = 64;
    local_70 = CONCAT17((char)((uint)uVar15 >> 0x18),
                        CONCAT16((char)((uint)uVar15 >> 0x10),
                                 CONCAT15((char)((uint)uVar15 >> 8),CONCAT14((char)uVar15,uVar14))))
    ;
    uStack_68 = CONCAT17((char)((uint)uVar17 >> 0x18),
                         CONCAT16((char)((uint)uVar17 >> 0x10),
                                  CONCAT15((char)((uint)uVar17 >> 8),CONCAT14((char)uVar17,uVar16)))
                        );
    uVar21 = 8;
  }
  else {
    uVar18 = 0;
    uVar20 = 0;
    uVar21 = 0;
    uVar19 = 0;
    uStack_68 = 0;
    local_70 = 0;
  }
  func_0x000198123100(lVar12,0.5,0.5,1,
                      0.37);
  lVar11 = 0;
  func_0x000198123120();
  (**(code **)(*(long *)(lVar11 + -8) + 0x38))(lVar12,0,1,lVar11);
  FUN_195ef581c(lVar12,param_1);
  lVar11 = 0;
  FUN_195ef0f6c();
  uVar4 = {d 3.05176e-05};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar11 + 0x14));
  puVar1[1] = {d 3.05176e-05};
  *puVar1 = uVar4;
  puVar1[2] = 3.05176e-05;
  *(undefined1 *)(puVar1 + 3) = 1;
  *(undefined4 *)((long)puVar1 + 0x1c) = -1f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  uVar5 = {d -50};
  uVar4 = {d -20};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar11 + 0x18));
  puVar1[1] = {d -50};
  *puVar1 = uVar4;
  puVar1[3] = uVar5;
  puVar1[2] = uVar4;
  uVar5 = {d 6};
  uVar4 = {d 0};
  puVar1[5] = {d 6};
  puVar1[4] = uVar4;
  puVar1[7] = uVar5;
  puVar1[6] = uVar4;
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar11 + 0x1c));
  *puVar2 = 1f;
  uVar5 = {d 0.75};
  uVar4 = {d 0};
  *(undefined8 *)(puVar2 + 4) = {d 0.75};
  *(undefined8 *)(puVar2 + 2) = uVar4;
  uVar7 = {d 50};
  uVar6 = {d 10};
  *(undefined8 *)(puVar2 + 8) = {d 50};
  *(undefined8 *)(puVar2 + 6) = uVar6;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 1f;
  *(undefined8 *)(puVar2 + 0x28) = uVar5;
  *(undefined8 *)(puVar2 + 0x26) = uVar4;
  *(undefined8 *)(puVar2 + 0x2c) = uVar7;
  *(undefined8 *)(puVar2 + 0x2a) = uVar6;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar4 = {d 3.05176e-05};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar11 + 0x20));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar4;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.000878906};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar11 + 0x24));
  *puVar1 = uVar20;
  puVar1[1] = uVar21;
  puVar1[2] = uVar19;
  *(undefined4 *)(puVar1 + 3) = uVar18;
  *(undefined4 *)((long)puVar1 + 0x1c) = uVar18;
  uVar19 = {d 0};
  puVar1[5] = {d 0.0078125};
  puVar1[4] = uVar19;
  puVar1[7] = uStack_68;
  puVar1[6] = local_70;
  *(bool *)(puVar1 + 8) = !bVar3;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## TVPortraitClockTextSpec (spec) 0x195f3406c
// === 195f36b6c spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f36b6c(long param_1)
{
  puVar6 = &DAT_1eb9ca9c0;
  ___swift_instantiateConcreteTypeFromMangledNameV2(&DAT_1eb9ca9c0,&{f 2.42977e-40, 9.80909e-45});
  (*_DAT_1e2125200)(*(long *)(*(long *)(puVar6 + -8) + 0x40) + 0xfU & 0xfffffffffffffff0);
  puVar8 = &stack0xffffffffffffffd0 + -extraout_x8;
  func_0x000198123100(puVar8,0.2,0.2,1,
                      0.2);
  lVar7 = 0;
  func_0x000198123120();
  (**(code **)(*(long *)(lVar7 + -8) + 0x38))(puVar8,0,1,lVar7);
  FUN_195ef581c(puVar8,param_1);
  lVar7 = 0;
  FUN_195ef0f6c();
  uVar9 = {d 0.0078125};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x14));
  puVar1[1] = {f 0.6, 0};
  *puVar1 = uVar9;
  puVar1[2] = 3.05176e-05;
  *(undefined1 *)(puVar1 + 3) = 1;
  *(undefined4 *)((long)puVar1 + 0x1c) = -5f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = -2f;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  uVar3 = {d -80};
  uVar9 = {d -20};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x18));
  puVar1[1] = {d -80};
  *puVar1 = uVar9;
  puVar1[3] = uVar3;
  puVar1[2] = uVar9;
  uVar3 = {d 8.5};
  uVar9 = {d 0};
  puVar1[5] = {d 8.5};
  puVar1[4] = uVar9;
  puVar1[7] = uVar3;
  puVar1[6] = uVar9;
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar7 + 0x1c));
  *puVar2 = 1f;
  uVar5 = {d 1.4};
  uVar4 = {d 0};
  *(undefined8 *)(puVar2 + 4) = {d 1.4};
  *(undefined8 *)(puVar2 + 2) = uVar4;
  uVar3 = {d 50};
  uVar9 = {d 10};
  *(undefined8 *)(puVar2 + 8) = {d 50};
  *(undefined8 *)(puVar2 + 6) = uVar9;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 0.6f;
  *(undefined8 *)(puVar2 + 0x28) = uVar5;
  *(undefined8 *)(puVar2 + 0x26) = uVar4;
  *(undefined8 *)(puVar2 + 0x2c) = uVar3;
  *(undefined8 *)(puVar2 + 0x2a) = uVar9;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar9 = {f 1, -0.05};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x20));
  puVar1[1] = {d 0.04375};
  *puVar1 = uVar9;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.0078125};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar7 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar9 = NEON_fmov(1f,4);
  puVar1[5] = uVar9;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## FlowStencilBaseSpec (spec) 0x195f340a8
// === 195f35dfc spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f35dfc(long param_1,long param_2)
{
  lVar5 = 0;
  FUN_195ed0900();
  uVar6 = *(ulong *)(param_2 + *(int *)(lVar5 + 0x14));
  lVar5 = 0;
  FUN_195ef0f6c();
  uVar7 = {d 0.0078125};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x14));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar7;
  puVar1[2] = (f 1, f 100);
  *(undefined1 *)(puVar1 + 3) = 0;
  *(undefined4 *)((long)puVar1 + 0x1c) = -80f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 9f;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  uVar3 = {d -75};
  uVar7 = {d 0};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x18));
  puVar1[1] = {d -75};
  *puVar1 = uVar7;
  puVar1[3] = uVar3;
  puVar1[2] = uVar7;
  uVar3 = {d 11};
  uVar7 = {d 0};
  puVar1[5] = {d 11};
  puVar1[4] = uVar7;
  puVar1[7] = uVar3;
  puVar1[6] = uVar7;
  uVar7 = 1.5;
  if ((uVar6 & 4) != 0) {
    uVar7 = 2;
  }
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar5 + 0x1c));
  *puVar2 = 1f;
  *(undefined8 *)(puVar2 + 2) = 0;
  *(undefined8 *)(puVar2 + 4) = uVar7;
  uVar4 = {d 70};
  uVar3 = {d 0};
  *(undefined8 *)(puVar2 + 8) = {d 70};
  *(undefined8 *)(puVar2 + 6) = uVar3;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 1f;
  *(undefined8 *)(puVar2 + 0x26) = 0;
  *(undefined8 *)(puVar2 + 0x28) = uVar7;
  *(undefined8 *)(puVar2 + 0x2c) = uVar4;
  *(undefined8 *)(puVar2 + 0x2a) = uVar3;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar7 = {f 1, 0.1};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x20));
  puVar1[1] = {d 0.025};
  *puVar1 = uVar7;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.025};
  *(undefined4 *)((long)puVar1 + 0x54) = 1.2f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar5 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar7 = NEON_fmov(1f,4);
  puVar1[5] = uVar7;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## FlowStencilMiniOverrides (spec) 0x195f340ac
// === 195f340ac spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f340ac(long param_1)
{
  lVar4 = 0;
  FUN_195ef0f6c();
  uVar3 = {d -55};
  uVar2 = {d 0};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x18));
  puVar1[1] = {d -55};
  *puVar1 = uVar2;
  puVar1[3] = uVar3;
  puVar1[2] = uVar2;
  uVar3 = {d 7};
  uVar2 = {d 0};
  puVar1[5] = {d 7};
  puVar1[4] = uVar2;
  puVar1[7] = uVar3;
  puVar1[6] = uVar2;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x1c));
  *(undefined4 *)puVar1 = 1f;
  uVar2 = {d 0.2};
  puVar1[2] = {d 1};
  puVar1[1] = uVar2;
  uVar2 = {d 0};
  puVar1[4] = {d 70};
  puVar1[3] = uVar2;
  puVar1[5] = 0;
  *(undefined1 *)(puVar1 + 6) = 1;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x5c) = 0;
  *(undefined8 *)((long)puVar1 + 0x54) = 0;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined8 *)((long)puVar1 + 100) = 0;
  *(undefined8 *)((long)puVar1 + 0x7c) = 0;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x81) = 0;
  *(undefined1 *)((long)puVar1 + 0x89) = 1;
  puVar1[0x1f] = puVar1[0xd];
  puVar1[0x1e] = puVar1[0xc];
  puVar1[0x21] = puVar1[0xf];
  puVar1[0x20] = puVar1[0xe];
  *(undefined8 *)((long)puVar1 + 0x112) = *(undefined8 *)((long)puVar1 + 0x82);
  *(undefined8 *)((long)puVar1 + 0x10a) = *(undefined8 *)((long)puVar1 + 0x7a);
  puVar1[0x17] = puVar1[5];
  puVar1[0x16] = puVar1[4];
  puVar1[0x19] = puVar1[7];
  puVar1[0x18] = puVar1[6];
  puVar1[0x1b] = puVar1[9];
  puVar1[0x1a] = puVar1[8];
  puVar1[0x1d] = puVar1[0xb];
  puVar1[0x1c] = puVar1[10];
  puVar1[0x13] = puVar1[1];
  puVar1[0x12] = *puVar1;
  puVar1[0x15] = puVar1[3];
  puVar1[0x14] = puVar1[2];
  return;
}


//######## FlowSolidBaseOverrides (spec) 0x195f341b0
// === 195f341b0 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f341b0(void)
{
  FUN_195f35000({d 0},{d 0});
  return;
}


//######## FlowSolidMiniOverrides (spec) 0x195f341c4
// === 195f341c4 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f341c4(long param_1)
{
  lVar4 = 0;
  FUN_195ef0f6c();
  uVar3 = {d 4.5};
  uVar2 = {d 0};
  lVar1 = param_1 + *(int *)(lVar4 + 0x18);
  *(undefined8 *)(lVar1 + 0x28) = {d 4.5};
  *(undefined8 *)(lVar1 + 0x20) = uVar2;
  *(undefined8 *)(lVar1 + 0x38) = uVar3;
  *(undefined8 *)(lVar1 + 0x30) = uVar2;
  uVar2 = {d 0.025};
  param_1 = param_1 + *(int *)(lVar4 + 0x20);
  <+0x4> = {d 0.025};
  <+0xc> = 1f;
  <shadow.normalizedHeight> = 0;
  <shadow.normalizedAmount> = 0;
  <shadow.blurRadius> = 1;
  <+0x2c> = 0;
  <+0x24> = 0;
  <+0x34> = 1;
  <+0x38> = 0;
  <+0x40> = 0;
  <+0x48> = 1;
  <+0x4c> = uVar2;
  <+0x54> = 1.2f;
  <shadow.shadowRadius> = 0;
  <+0x60> = 0;
  <+0x68> = 1;
  <+0x74> = 0;
  <+0x6c> = 0;
  <+0x7c> = 1;
  <+0x80> = 0;
  <+0x88> = 0;
  <+0x90> = 1;
  return;
}


//######## HomeFaceFlowRingShadow (spec) 0x195f342f4
// === 195f342f4 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f342f4(long param_1)
{
  lVar3 = 0;
  FUN_195ef0f6c();
  uVar2 = {d 12};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar3 + 0x28));
  puVar1[1] = {d 4};
  *puVar1 = uVar2;
  puVar1[2] = 5;
  *(undefined4 *)(puVar1 + 3) = 0.1f;
  puVar1[4] = 0;
  return;
}


//######## HomeFaceFlowBaseSpec (spec) 0x195f34348
// === 195f35fd0 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f35fd0(long param_1,long param_2)
{
  lVar8 = 0;
  FUN_195ed0900();
  uVar9 = *(ulong *)(param_2 + *(int *)(lVar8 + 0x14));
  uVar11 = 0;
  if ((uVar9 & 4) != 0) {
    uVar11 = 72f;
  }
  lVar8 = 0;
  FUN_195ef0f6c();
  uVar12 = {d 0.0078125};
  uVar10 = {f 1, 0.25};
  puVar1 = (undefined4 *)(param_1 + *(int *)(lVar8 + 0x14));
  *puVar1 = uVar11;
  *(undefined8 *)(puVar1 + 3) = uVar12;
  *(undefined8 *)(puVar1 + 1) = uVar10;
  puVar1[5] = 300f;
  *(undefined1 *)(puVar1 + 6) = 0;
  puVar1[7] = -240f;
  *(undefined1 *)(puVar1 + 8) = 0;
  puVar1[9] = 27f;
  *(undefined1 *)(puVar1 + 10) = 0;
  puVar1[0xb] = 0;
  *(undefined1 *)(puVar1 + 0xc) = 0;
  uVar12 = {d -135};
  uVar10 = {d 0};
  puVar2 = (undefined8 *)(param_1 + *(int *)(lVar8 + 0x18));
  if (((uint)uVar9 >> 2 & 1) == 0) {
    puVar2[1] = {d -135};
    *puVar2 = uVar10;
    puVar2[3] = uVar12;
    puVar2[2] = uVar10;
    uVar12 = {d 21};
    uVar10 = {d 0};
    puVar2[5] = {d 21};
    puVar2[4] = uVar10;
    puVar2[7] = uVar12;
    puVar2[6] = uVar10;
    uVar10 = {d 3.43323e-06};
    uVar12 = {d 0.025};
  }
  else {
    puVar2[5] = 0;
    puVar2[4] = 0;
    puVar2[7] = 0;
    puVar2[6] = 0;
    puVar2[1] = 0;
    *puVar2 = 0;
    puVar2[3] = 0;
    puVar2[2] = 0;
    uVar10 = {d 0.0078125};
    uVar12 = {d 0.0078125};
  }
  puVar1 = (undefined4 *)(param_1 + *(int *)(lVar8 + 0x1c));
  *puVar1 = 1f;
  uVar4 = {d 2};
  uVar3 = {d 0};
  *(undefined8 *)(puVar1 + 4) = {d 2};
  *(undefined8 *)(puVar1 + 2) = uVar3;
  uVar6 = {d 85};
  uVar5 = {d 0};
  *(undefined8 *)(puVar1 + 8) = {d 85};
  *(undefined8 *)(puVar1 + 6) = uVar5;
  *(undefined8 *)(puVar1 + 10) = 0.5;
  *(undefined1 *)(puVar1 + 0xc) = 0;
  *(undefined8 *)(puVar1 + 0xe) = 0;
  *(undefined1 *)(puVar1 + 0x10) = 1;
  uVar7 = {d 0.03125};
  *(undefined8 *)(puVar1 + 0x11) = {d 0.03125};
  puVar1[0x13] = 1.6f;
  *(undefined8 *)(puVar1 + 0x14) = 0;
  *(undefined8 *)(puVar1 + 0x16) = 0;
  *(undefined1 *)(puVar1 + 0x18) = 1;
  *(undefined8 *)(puVar1 + 0x1b) = 0;
  *(undefined8 *)(puVar1 + 0x19) = 0;
  *(undefined1 *)(puVar1 + 0x1d) = 1;
  *(undefined8 *)(puVar1 + 0x1e) = 0;
  *(undefined8 *)(puVar1 + 0x20) = 0;
  *(undefined2 *)(puVar1 + 0x22) = 1;
  puVar1[0x24] = 1f;
  *(undefined8 *)(puVar1 + 0x28) = uVar4;
  *(undefined8 *)(puVar1 + 0x26) = uVar3;
  *(undefined8 *)(puVar1 + 0x2c) = uVar6;
  *(undefined8 *)(puVar1 + 0x2a) = uVar5;
  *(undefined8 *)(puVar1 + 0x2e) = 0.5;
  *(undefined1 *)(puVar1 + 0x30) = 0;
  *(undefined8 *)(puVar1 + 0x32) = 0;
  *(undefined1 *)(puVar1 + 0x34) = 1;
  *(undefined8 *)(puVar1 + 0x35) = uVar7;
  puVar1[0x37] = 1.6f;
  *(undefined8 *)(puVar1 + 0x38) = 0;
  *(undefined8 *)(puVar1 + 0x3a) = 0;
  *(undefined1 *)(puVar1 + 0x3c) = 1;
  *(undefined8 *)(puVar1 + 0x3f) = 0;
  *(undefined8 *)(puVar1 + 0x3d) = 0;
  *(undefined1 *)(puVar1 + 0x41) = 1;
  *(undefined8 *)(puVar1 + 0x42) = 0;
  *(undefined8 *)(puVar1 + 0x44) = 0;
  *(undefined2 *)(puVar1 + 0x46) = 1;
  puVar1 = (undefined4 *)(param_1 + *(int *)(lVar8 + 0x20));
  *puVar1 = 1f;
  *(undefined8 *)(puVar1 + 1) = uVar12;
  puVar1[3] = 1f;
  *(undefined8 *)(puVar1 + 4) = 0;
  *(undefined8 *)(puVar1 + 6) = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)(puVar1 + 0xb) = 0;
  *(undefined8 *)(puVar1 + 9) = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)(puVar1 + 0xe) = 0;
  *(undefined8 *)(puVar1 + 0x10) = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  *(undefined8 *)(puVar1 + 0x13) = uVar10;
  puVar1[0x15] = 1f;
  *(undefined8 *)(puVar1 + 0x16) = 0;
  *(undefined8 *)(puVar1 + 0x18) = 0;
  *(undefined1 *)(puVar1 + 0x1a) = 1;
  *(undefined8 *)(puVar1 + 0x1d) = 0;
  *(undefined8 *)(puVar1 + 0x1b) = 0;
  *(undefined1 *)(puVar1 + 0x1f) = 1;
  *(undefined8 *)(puVar1 + 0x20) = 0;
  *(undefined8 *)(puVar1 + 0x22) = 0;
  *(undefined1 *)(puVar1 + 0x24) = 1;
  puVar2 = (undefined8 *)(param_1 + *(int *)(lVar8 + 0x24));
  puVar2[4] = 0;
  puVar2[1] = 0;
  *puVar2 = 0;
  puVar2[3] = 0;
  puVar2[2] = 0;
  uVar10 = NEON_fmov(1f,4);
  puVar2[5] = uVar10;
  puVar2[6] = 0;
  puVar2[7] = 0;
  *(undefined1 *)(puVar2 + 8) = 1;
  *(undefined8 *)((long)puVar2 + 0x4c) = 0;
  *(undefined8 *)((long)puVar2 + 0x44) = 0;
  *(undefined1 *)((long)puVar2 + 0x54) = 1;
  puVar2[0xb] = 0;
  puVar2[0xc] = 0;
  *(undefined2 *)(puVar2 + 0xd) = 1;
  return;
}


//######## WatchPhotosClearSpec (spec) 0x195f34ec0
// === 195f3648c spec

/* WARNING: Removing unreachable block (ram,0x000195f364e8) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f3648c(long param_1)
{
  undefined1 auVar19 [16];
  lVar3 = 0;
  func_0x0001981217d0();
  lVar5 = *(long *)(lVar3 + -8);
  (*_DAT_1e2125200)(*(undefined8 *)(lVar5 + 0x40));
  lVar6 = (long)&local_a0 - (extraout_x8 + 0xfU & 0xfffffffffffffff0);
  lVar4 = 0;
  FUN_195ef0f6c();
  uVar9 = {d 0.0078125};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x14));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar9;
  puVar1[2] = (f 1, f 100);
  *(undefined1 *)(puVar1 + 3) = 0;
  *(undefined4 *)((long)puVar1 + 0x1c) = -80f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 9f;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  uVar11 = {d -24};
  uVar9 = {d -16};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x18));
  puVar1[1] = {d -24};
  *puVar1 = uVar9;
  puVar1[3] = uVar11;
  puVar1[2] = uVar9;
  uVar11 = {d 4};
  uVar9 = {d 2};
  puVar1[5] = {d 4};
  puVar1[4] = uVar9;
  puVar1[7] = uVar11;
  puVar1[6] = uVar9;
  uVar16 = *_DAT_1e01830d0;
  pcVar7 = *(code **)(lVar5 + 0x68);
  (*pcVar7)(lVar6,uVar16,lVar3);
  uVar8 = 0.2f;
  uVar15 = 1f;
  uVar17 = 0;
  uVar18 = 0;
  uVar10 = 0;
  uVar12 = 0;
  uVar14 = 0;
  uVar9 = uVar8;
  uVar11 = uVar8;
  uVar13 = uVar8;
  func_0x0001981218c0(lVar6);
  local_80 = CONCAT44(uVar17,uVar15);
  local_a0 = uVar13;
  uStack_98 = uVar14;
  uStack_90 = uVar9;
  uStack_88 = uVar10;
  uStack_78 = uVar18;
  uStack_70 = uVar11;
  uStack_68 = uVar12;
  (*pcVar7)(lVar6,uVar16,lVar3);
  uVar16 = 1f;
  uVar11 = uVar8;
  uVar13 = uVar8;
  func_0x0001981218c0(lVar6);
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar4 + 0x1c));
  *puVar2 = 1f;
  auVar19 = NEON_fmov(0.5,8);
  *(long *)(puVar2 + 4) = auVar19._8_8_;
  *(long *)(puVar2 + 2) = auVar19._0_8_;
  uVar9 = {d 0};
  *(undefined8 *)(puVar2 + 8) = {d 60};
  *(undefined8 *)(puVar2 + 6) = uVar9;
  *(undefined8 *)(puVar2 + 10) = 0.5;
  *(undefined1 *)(puVar2 + 0xc) = 0;
  *(undefined8 *)(puVar2 + 0xe) = 0.436332;
  *(undefined1 *)(puVar2 + 0x10) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0.025;
  puVar2[0x13] = 1f;
  *(undefined8 *)(puVar2 + 0x14) = 0;
  *(undefined8 *)(puVar2 + 0x16) = 0;
  *(undefined1 *)(puVar2 + 0x18) = 1;
  *(ulong *)(puVar2 + 0x1b) =
       CONCAT17((char)((ulong)local_80 >> 0x18),
                CONCAT16((char)((ulong)local_80 >> 0x10),
                         CONCAT15((char)((ulong)local_80 >> 8),
                                  CONCAT14((char)local_80,(int)local_a0))));
  *(ulong *)(puVar2 + 0x19) =
       CONCAT17((char)((ulong)uStack_70 >> 0x18),
                CONCAT16((char)((ulong)uStack_70 >> 0x10),
                         CONCAT15((char)((ulong)uStack_70 >> 8),
                                  CONCAT14((char)uStack_70,(int)uStack_90))));
  *(undefined1 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)(puVar2 + 0x1e) = 0;
  *(undefined8 *)(puVar2 + 0x20) = 0;
  *(undefined2 *)(puVar2 + 0x22) = 1;
  puVar2[0x24] = 1f;
  *(long *)(puVar2 + 0x28) = auVar19._8_8_;
  *(long *)(puVar2 + 0x26) = auVar19._0_8_;
  uVar9 = {d 0};
  *(undefined8 *)(puVar2 + 0x2c) = {d 50};
  *(undefined8 *)(puVar2 + 0x2a) = uVar9;
  *(undefined8 *)(puVar2 + 0x2e) = 0.5;
  *(undefined1 *)(puVar2 + 0x30) = 0;
  *(undefined8 *)(puVar2 + 0x32) = 0.0872665;
  *(undefined1 *)(puVar2 + 0x34) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0.025;
  puVar2[0x37] = 1f;
  *(undefined8 *)(puVar2 + 0x38) = 0;
  *(undefined8 *)(puVar2 + 0x3a) = 0;
  *(undefined1 *)(puVar2 + 0x3c) = 1;
  *(ulong *)(puVar2 + 0x3f) =
       CONCAT17((char)((uint)uVar16 >> 0x18),
                CONCAT16((char)((uint)uVar16 >> 0x10),
                         CONCAT15((char)((uint)uVar16 >> 8),CONCAT14((char)uVar16,(int)uVar13))));
  *(ulong *)(puVar2 + 0x3d) =
       CONCAT17((char)((ulong)uVar11 >> 0x18),
                CONCAT16((char)((ulong)uVar11 >> 0x10),
                         CONCAT15((char)((ulong)uVar11 >> 8),CONCAT14((char)uVar11,(int)uVar8))));
  *(undefined1 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)(puVar2 + 0x42) = 0;
  *(undefined8 *)(puVar2 + 0x44) = 0;
  *(undefined2 *)(puVar2 + 0x46) = 1;
  uVar9 = {f 1, 0.25};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x20));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar9;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.000878906};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar4 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar9 = NEON_fmov(1f,4);
  puVar1[5] = uVar9;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## WatchPhotosMiniOverrides (spec) 0x195f34fec
// === 195f34fec spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f34fec(void)
{
  FUN_195f35000({d 0},{d 0});
  return;
}


//######## WatchPhotosFrostOverrides (spec) 0x195f35048
// === 195f35048 spec

void FUN_195f35048(long param_1)
{
  lVar1 = 0;
  FUN_195ef0f6c();
  *(undefined4 *)(param_1 + *(int *)(lVar1 + 0x14)) = 10f;
  param_1 = param_1 + *(int *)(lVar1 + 0x20);
  <+0x4> = {d 0.0140625};
  <+0xc> = 1f;
  <shadow.normalizedHeight> = 0;
  <shadow.normalizedAmount> = 0;
  <shadow.blurRadius> = 1;
  <+0x2c> = 0;
  <+0x24> = 0;
  <+0x34> = 1;
  <+0x38> = 0;
  <+0x40> = 0;
  <+0x48> = 1;
  <+0x4c> = {d 5.00488e-05};
  <+0x54> = 1f;
  <shadow.shadowRadius> = 0;
  <+0x60> = 0;
  <+0x68> = 1;
  <+0x74> = 0;
  <+0x6c> = 0;
  <+0x7c> = 1;
  <+0x80> = 0;
  <+0x88> = 0;
  <+0x90> = 1;
  return;
}


//######## WatchPhotosAODSpec (spec) 0x195f35210
// === 195f35210 spec

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f35210(long param_1)
{
  lVar3 = 0;
  FUN_195ef0f6c();
  uVar4 = {d 0.0078125};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar3 + 0x14));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar4;
  puVar1[2] = (f 1, f 100);
  *(undefined1 *)(puVar1 + 3) = 0;
  *(undefined4 *)((long)puVar1 + 0x1c) = -80f;
  *(undefined1 *)(puVar1 + 4) = 0;
  *(undefined4 *)((long)puVar1 + 0x24) = 9f;
  *(undefined1 *)(puVar1 + 5) = 0;
  *(undefined4 *)((long)puVar1 + 0x2c) = 0;
  *(undefined1 *)(puVar1 + 6) = 0;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar3 + 0x18));
  puVar1[5] = 0;
  puVar1[4] = 0;
  puVar1[7] = 0;
  puVar1[6] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  puVar2 = (undefined4 *)(param_1 + *(int *)(lVar3 + 0x1c));
  *puVar2 = 0;
  *(undefined8 *)(puVar2 + 2) = 0;
  *(undefined8 *)(puVar2 + 4) = 0;
  *(undefined8 *)(puVar2 + 6) = 0;
  *(undefined8 *)(puVar2 + 8) = 50;
  *(undefined8 *)(puVar2 + 10) = 0;
  *(undefined1 *)(puVar2 + 0xc) = 1;
  *(undefined8 *)(puVar2 + 0xe) = 0;
  *(undefined1 *)(puVar2 + 0x10) = 1;
  *(undefined8 *)(puVar2 + 0x13) = 0;
  *(undefined8 *)(puVar2 + 0x11) = 0;
  *(undefined8 *)(puVar2 + 0x17) = 0;
  *(undefined8 *)(puVar2 + 0x15) = 0;
  *(undefined8 *)(puVar2 + 0x1b) = 0;
  *(undefined8 *)(puVar2 + 0x19) = 0;
  *(undefined8 *)(puVar2 + 0x1f) = 0;
  *(undefined8 *)(puVar2 + 0x1d) = 0;
  *(undefined8 *)((long)puVar2 + 0x81) = 0;
  *(undefined1 *)((long)puVar2 + 0x89) = 1;
  puVar2[0x24] = 0;
  *(undefined8 *)(puVar2 + 0x28) = 0;
  *(undefined8 *)(puVar2 + 0x2a) = 0;
  *(undefined8 *)(puVar2 + 0x26) = 0;
  *(undefined8 *)(puVar2 + 0x37) = 0;
  *(undefined8 *)(puVar2 + 0x35) = 0;
  *(undefined8 *)(puVar2 + 0x2c) = 50;
  *(undefined8 *)(puVar2 + 0x2e) = 0;
  *(undefined1 *)(puVar2 + 0x30) = 1;
  *(undefined8 *)(puVar2 + 0x32) = 0;
  *(undefined1 *)(puVar2 + 0x34) = 1;
  *(undefined8 *)(puVar2 + 0x3b) = 0;
  *(undefined8 *)(puVar2 + 0x39) = 0;
  *(undefined8 *)(puVar2 + 0x3f) = 0;
  *(undefined8 *)(puVar2 + 0x3d) = 0;
  *(undefined8 *)(puVar2 + 0x43) = 0;
  *(undefined8 *)(puVar2 + 0x41) = 0;
  *(undefined8 *)((long)puVar2 + 0x111) = 0;
  *(undefined1 *)((long)puVar2 + 0x119) = 1;
  uVar4 = {d 9.76563e-05};
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar3 + 0x20));
  puVar1[1] = {d 0.0078125};
  *puVar1 = uVar4;
  puVar1[2] = 0;
  puVar1[3] = 0;
  *(undefined1 *)(puVar1 + 4) = 1;
  *(undefined8 *)((long)puVar1 + 0x2c) = 0;
  *(undefined8 *)((long)puVar1 + 0x24) = 0;
  *(undefined1 *)((long)puVar1 + 0x34) = 1;
  puVar1[7] = 0;
  puVar1[8] = 0;
  *(undefined1 *)(puVar1 + 9) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = {d 0.0078125};
  *(undefined4 *)((long)puVar1 + 0x54) = 1f;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined1 *)(puVar1 + 0xd) = 1;
  *(undefined8 *)((long)puVar1 + 0x74) = 0;
  *(undefined8 *)((long)puVar1 + 0x6c) = 0;
  *(undefined1 *)((long)puVar1 + 0x7c) = 1;
  puVar1[0x10] = 0;
  puVar1[0x11] = 0;
  *(undefined1 *)(puVar1 + 0x12) = 1;
  puVar1 = (undefined8 *)(param_1 + *(int *)(lVar3 + 0x24));
  puVar1[4] = 0;
  puVar1[1] = 0;
  *puVar1 = 0;
  puVar1[3] = 0;
  puVar1[2] = 0;
  uVar4 = NEON_fmov(1f,4);
  puVar1[5] = uVar4;
  puVar1[6] = 0;
  puVar1[7] = 0;
  *(undefined1 *)(puVar1 + 8) = 1;
  *(undefined8 *)((long)puVar1 + 0x4c) = 0;
  *(undefined8 *)((long)puVar1 + 0x44) = 0;
  *(undefined1 *)((long)puVar1 + 0x54) = 1;
  puVar1[0xb] = 0;
  puVar1[0xc] = 0;
  *(undefined2 *)(puVar1 + 0xd) = 1;
  return;
}


//######## VibrantFillRecipe.anon.Modifier (params) 0x195f36e64
// === 195f36fa4 params

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
void FUN_195f36fa4(undefined4 <backdropScale>,long param_2)
{
  undefined1 auVar16 [16];
  float local_98 [5];
  lVar6 = 0;
  FUN_195ed0900();
  puVar1 = (ulong *)(param_2 + *(int *)(lVar6 + 0x1c));
  uVar13 = puVar1[5];
  if ((uVar13 & 0xe0) != 0x40) {
    return;
  }
  uVar11 = *puVar1;
  uVar2 = puVar1[1];
  uVar14 = puVar1[2];
  uVar17 = puVar1[3];
  dVar18 = (double)puVar1[4];
  FUN_195f12ab4(param_2,0);
  <backdropScale> = 0.25f;
  if ((uVar13 & 0x1f) == 1) {
    return;
  }
  local_98[0] = (float)dVar18;
  local_98[3] = 0.0;
  local_98[4] = 0.0;
  local_98[1] = 0.0;
  local_98[2] = 0.0;
  auVar16 = NEON_fmov(1f,4);
  uStack_7c = auVar16._8_8_;
  local_84 = auVar16._0_8_;
  local_74 = 1f;
  FUN_195ed0ce8(local_98);
  if (DAT_1eda3b1e0 != -1) {
    func_0x000198104ff0(&DAT_1eda3b1e0,FUN_195ed3888);
  }
  fVar4 = DAT_1eda46354;
  fVar3 = DAT_1eda46350;
  uVar13 = uVar2 >> 0x20 | uVar14 << 0x20;
  uVar14 = uVar14 >> 0x20 | uVar17 << 0x20;
  uVar17 = uVar17 >> 0x20 & 0xff;
  uStack_b8 = ram0x0001eda46330;
  local_c0 = ram0x0001eda46328;
  uStack_a8 = ram0x0001eda46340;
  uStack_b0 = ram0x0001eda46338;
  local_a3 = DAT_1eda46344._1_3_;
  uStack_a0 = ram0x0001eda46348;
  uStack_d8 = _DAT_1eda46310;
  local_e0 = _DAT_1eda46308;
  uStack_c8 = ram0x0001eda46320;
  uStack_d0 = ram0x0001eda46318;
  if (DAT_1eda46304 == 1.0) {
    local_128 = (undefined4)uVar11;
    uStack_124 = (undefined4)(uVar11 >> 0x20);
    local_120 = (undefined4)uVar2;
    uStack_104 = 0;
    local_fc = 0x100000000;
    uStack_ec = 0;
    local_f4 = 0;
    uVar15 = 1;
    local_e4 = 1;
    puVar7 = &local_128;
    local_11c = uVar13;
    local_114 = uVar14;
    local_10c = uVar17;
    FUN_195ed7db4(puVar7,&local_e0);
    if (((ulong)puVar7 & 1) != 0) {
      bVar5 = false;
      if ((fVar3 == 1.0) && (bVar5 = false, !NAN(fVar4))) {
        bVar5 = fVar4 == 1.0;
      }
      if (bVar5) {
        uVar9 = 0;
        uVar11 = 0;
        uVar13 = 0;
        uVar14 = 0;
        uVar12 = 0;
        uVar10 = 0;
        uVar8 = 0;
        uVar17 = 0;
        goto LAB_195f3714c;
      }
    }
  }
  uVar15 = 0;
  uVar8 = 1f;
  uVar9 = uVar11 << 0x20 | 1f;
  uVar11 = uVar11 >> 0x20 | uVar2 << 0x20;
  uVar10 = 0.0078125;
  uVar12 = 0x100000000;
LAB_195f3714c:
  <+0x44> = uVar9;
  <+0x46> = uVar11;
  <shadow.shadowRadius> = uVar13;
  <+0x4a> = uVar14;
  <+0x4e> = 0;
  <+0x4c> = uVar17;
  <shadow.ycc.black> = uVar12;
  <+0x52> = 0;
  <shadow.ycc.white> = 0;
  <+0x56> = uVar10;
  <highlights.fill.ycc.dodgeFill.b> = uVar8;
  <+0x59> = uVar15;
  return;
}

