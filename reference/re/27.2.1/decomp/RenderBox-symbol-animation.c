// RenderBox.framework 27.2.1 (dyld cache, extracted), Ghidra 12.1.4: RB::Symbol::Animation (SF Symbol effect engine).
// DAT_ references annotated with their float value (/*f=...*/). RB effect ids: 1 variableColor, 2 pulse, 3 bounce, 4 scale, 5 appear,
// 6..8 replace variants (not mapped), 9 disappear, 10 wiggle, 11 rotate, 12 breathe, 13 drawOn, 14 drawOff (from Symbols -[NSSymbolEffect _rbAnimation] table @0x196a61330).
//==== 196b152dc Timing
/* RB::Symbol::Animation::Timing::Timing(RB::Animation const&) */
Timing * __thiscall RB::Symbol::Animation::Timing::Timing(Timing *this,Animation *param_1)
{
  TermOrArg *pTVar1;
  uint uVar2;
  undefined8 uVar3;
  TermOrArg *pTVar4;
  int iVar5;
  ulong uVar6;
  uint uVar7;
  Animation *pAVar8;
  undefined4 uVar9;
  uVar3 = DAT_196bd8f60/*f=0*/;
  *(undefined8 *)(this + 0x18) = 0;
  *(undefined8 *)(this + 0x20) = uVar3;
  pAVar8 = param_1;
  if (*(Animation **)(param_1 + 0x18) != (Animation *)0x0) {
    pAVar8 = *(Animation **)(param_1 + 0x18);
  }
  uVar2 = *(uint *)(param_1 + 0x20);
  if (uVar2 < 7) {
    pTVar4 = (TermOrArg *)0x0;
    if (uVar2 == 0) {
      iVar5 = 0;
      goto LAB_196b15358;
    }
    uVar6 = 0;
  }
  else {
    vector<RB::Animation::TermOrArg,6ul,unsigned_int>::reserve_slow
              ((vector<RB::Animation::TermOrArg,6ul,unsigned_int> *)this,uVar2);
    pTVar4 = *(TermOrArg **)(this + 0x18);
    uVar6 = (ulong)*(uint *)(this + 0x20);
  }
  pTVar1 = (TermOrArg *)this;
  if (pTVar4 != (TermOrArg *)0x0) {
    pTVar1 = pTVar4;
  }
  pTVar4 = pTVar1 + uVar6 * 4;
  uVar7 = uVar2;
  do {
    *(undefined4 *)pTVar4 = *(undefined4 *)pAVar8;
    uVar7 = uVar7 - 1;
    pTVar4 = pTVar4 + 4;
    pAVar8 = pAVar8 + 4;
  } while (uVar7 != 0);
  iVar5 = *(int *)(this + 0x20);
  pTVar4 = *(TermOrArg **)(this + 0x18);
LAB_196b15358:
  *(uint *)(this + 0x20) = iVar5 + uVar2;
  pTVar1 = (TermOrArg *)this;
  if (pTVar4 != (TermOrArg *)0x0) {
    pTVar1 = pTVar4;
  }
  uVar9 = RB::Animation::active_duration(pTVar1,(ulong)(iVar5 + uVar2));
  *(undefined4 *)(this + 0x28) = uVar9;
  pTVar4 = (TermOrArg *)this;
  if (*(TermOrArg **)(this + 0x18) != (TermOrArg *)0x0) {
    pTVar4 = *(TermOrArg **)(this + 0x18);
  }
  RB::Animation::prepare(pTVar4,(ulong)*(uint *)(this + 0x20),(State *)(this + 0x2c));
  return this;
}
//==== 196b153d0 Timing
/* RB::Symbol::Animation::Timing::Timing(RB::Animation const&) */
Timing * __thiscall RB::Symbol::Animation::Timing::Timing(Timing *this,Animation *param_1)
{
  TermOrArg *pTVar1;
  uint uVar2;
  undefined8 uVar3;
  TermOrArg *pTVar4;
  int iVar5;
  ulong uVar6;
  uint uVar7;
  Animation *pAVar8;
  undefined4 uVar9;
  uVar3 = DAT_196bd8f60/*f=0*/;
  *(undefined8 *)(this + 0x18) = 0;
  *(undefined8 *)(this + 0x20) = uVar3;
  pAVar8 = param_1;
  if (*(Animation **)(param_1 + 0x18) != (Animation *)0x0) {
    pAVar8 = *(Animation **)(param_1 + 0x18);
  }
  uVar2 = *(uint *)(param_1 + 0x20);
  if (uVar2 < 7) {
    pTVar4 = (TermOrArg *)0x0;
    if (uVar2 == 0) {
      iVar5 = 0;
      goto LAB_196b15358;
    }
    uVar6 = 0;
  }
  else {
    vector<RB::Animation::TermOrArg,6ul,unsigned_int>::reserve_slow
              ((vector<RB::Animation::TermOrArg,6ul,unsigned_int> *)this,uVar2);
    pTVar4 = *(TermOrArg **)(this + 0x18);
    uVar6 = (ulong)*(uint *)(this + 0x20);
  }
  pTVar1 = (TermOrArg *)this;
  if (pTVar4 != (TermOrArg *)0x0) {
    pTVar1 = pTVar4;
  }
  pTVar4 = pTVar1 + uVar6 * 4;
  uVar7 = uVar2;
  do {
    *(undefined4 *)pTVar4 = *(undefined4 *)pAVar8;
    uVar7 = uVar7 - 1;
    pTVar4 = pTVar4 + 4;
    pAVar8 = pAVar8 + 4;
  } while (uVar7 != 0);
  iVar5 = *(int *)(this + 0x20);
  pTVar4 = *(TermOrArg **)(this + 0x18);
LAB_196b15358:
  *(uint *)(this + 0x20) = iVar5 + uVar2;
  pTVar1 = (TermOrArg *)this;
  if (pTVar4 != (TermOrArg *)0x0) {
    pTVar1 = pTVar4;
  }
  uVar9 = RB::Animation::active_duration(pTVar1,(ulong)(iVar5 + uVar2));
  *(undefined4 *)(this + 0x28) = uVar9;
  pTVar4 = (TermOrArg *)this;
  if (*(TermOrArg **)(this + 0x18) != (TermOrArg *)0x0) {
    pTVar4 = *(TermOrArg **)(this + 0x18);
  }
  RB::Animation::prepare(pTVar4,(ulong)*(uint *)(this + 0x20),(State *)(this + 0x2c));
  return this;
}
//==== 196b15570 local_duration
/* RB::Symbol::Animation::local_duration(RB::Symbol::Model const&) const */
undefined1  [16] __thiscall RB::Symbol::Animation::local_duration(Animation *this,Model *param_1)
{
  uint uVar1;
  uint uVar2;
  code *pcVar3;
  long lVar4;
  uint uVar5;
  undefined4 *puVar6;
  ulong unaff_x30;
  float fVar7;
  uint uVar8;
  float fVar9;
  ulong uVar10;
  undefined8 uVar11;
  undefined1 auVar12 [16];
  float fVar13;
  undefined8 uVar14;
  if ((*(long *)(this + 0x48) != 0) && ((char)this[0xc] < '\0')) {
    uVar10 = (ulong)*(uint *)(*(long *)(this + 0x48) + 0x28);
    goto switchD_196b155d0_caseD_8;
  }
  uVar5 = *(uint *)(this + 4);
  uVar10 = 0;
  if (0xe < uVar5) goto switchD_196b155d0_caseD_8;
  switch(uVar5) {
  default:
    uVar10 = (ulong)(uint)DAT_196bd9510/*f=0.333333*/;
    break;
  case 1:
    lVar4 = Model::glyph_info(param_1);
    uVar8 = *(uint *)(lVar4 + 0x1d4);
    uVar2 = *(uint *)(this + 0xc);
    uVar5 = uVar2 >> 0x1e ^ 2;
    if (uVar5 < 2) {
      uVar1 = (uVar2 >> 0x1c & 1) + uVar8;
      if (uVar5 == 0) {
        if ((uVar2 >> 6 & 1) == 0) {
          fVar7 = (float)uVar1;
          if (fVar7 <= 1.0) {
            fVar7 = 1.0;
          }
          fVar7 = (float)NEON_fminnm(fVar7,0x40400000);
          uVar10 = (ulong)(uint)(DAT_196bd9510/*f=0.333333*/ + DAT_196bd9510/*f=0.333333*/ * fVar7);
        }
        else if (uVar8 < 4) {
          uVar10 = (ulong)(uint)((float)uVar8 * DAT_196bd9510/*f=0.333333*/);
        }
        else {
          uVar10 = (ulong)(uint)(DAT_196bd9510/*f=0.333333*/ + DAT_196bd953c/*f=0.0833333*/ * (float)uVar8 +
                                DAT_196bd9ea4/*f=0.0166667*/ * (float)(uVar8 * 2 - 8));
          uVar11 = NEON_frecpe(uVar10,4);
          uVar14 = NEON_frecps(uVar10,uVar11,4);
          fVar7 = (float)uVar14 * (float)uVar11;
          uVar11 = NEON_frecps(uVar10,CONCAT44((float)((ulong)uVar14 >> 0x20) *
                                               (float)((ulong)uVar11 >> 0x20),fVar7),4);
          uVar10 = (ulong)(uint)((float)uVar8 * DAT_196bd9ea8/*f=0.111111*/ * fVar7 * (float)uVar11);
        }
      }
      else {
        fVar7 = DAT_196bd9ea0/*f=1.33333*/;
        if (uVar1 != 3) {
          fVar7 = 2.5;
        }
        fVar13 = DAT_196bd9e94/*f=0.666667*/;
        if (2 < uVar1) {
          fVar13 = fVar7;
        }
        uVar10 = (ulong)(uint)fVar13;
      }
    }
    else {
      fVar7 = (float)uVar8;
      if (fVar7 <= 1.0) {
        fVar7 = 1.0;
      }
      fVar9 = (float)NEON_fminnm(fVar7,0x40400000);
      fVar7 = DAT_196bd9e94/*f=0.666667*/;
      fVar13 = DAT_196bd9510/*f=0.333333*/;
      if (uVar5 == 3) {
        fVar7 = DAT_196bd9510/*f=0.333333*/;
        fVar13 = DAT_196bd9e94/*f=0.666667*/;
      }
      uVar10 = (ulong)(uint)(fVar7 + fVar13 * fVar9);
    }
    break;
  case 2:
    uVar5 = 1;
    if (-1 < *(int *)(this + 0xc)) {
      uVar5 = 2;
    }
    uVar10 = (ulong)(uint)(float)uVar5;
    break;
  case 3:
    lVar4 = 4;
    if (((byte)this[0xc] & 0x10) != 0) {
      lVar4 = 0;
    }
    puVar6 = &DAT_196bd9e18/*f=0.433333*/;
    goto LAB_196b156d0;
  case 4:
  case 5:
    uVar10 = 0x3e800000;
    break;
  case 6:
    uVar5 = *(uint *)(this + 0xc);
    uVar8 = (uVar5 & 0x7800000) - 0x800000 >> 0x17;
    if (uVar8 < 5) {
      if (uVar8 - 2 < 3) {
        uVar10 = 0x3f800000;
        break;
      }
      if (uVar8 == 0) {
        uVar10 = (ulong)(uint)DAT_196bd9e94/*f=0.666667*/;
        break;
      }
      if (uVar8 == 1) {
        uVar10 = (ulong)DAT_196bd9e9c/*f=0.7*/;
        break;
      }
LAB_196b15810:
      uVar8 = 0x3e800000;
      if (uVar5 >> 0x1e < 3) {
        uVar8 = 0x3f000000;
      }
      uVar10 = (ulong)uVar8;
    }
    else {
      fVar7 = 0.0;
      if (uVar8 == 5) {
        uVar8 = 0;
      }
      else if (uVar8 == 6) {
        uVar8 = 8;
        fVar7 = DAT_196bd9e98/*f=0.083*/;
      }
      else {
        if (uVar8 != 7) goto LAB_196b15810;
        uVar8 = 8;
      }
      if (uVar5 >> 0x1e < 3) {
        fVar9 = (float)draw_duration(*(Model **)(this + 0x50),false,0,0.25,uVar8,0);
        fVar13 = fVar7;
        if (fVar7 <= fVar9) {
          fVar13 = fVar9;
        }
      }
      else {
        fVar7 = DAT_196bd9e98/*f=0.083*/;
        fVar13 = 0.0;
      }
      fVar9 = (float)draw_duration(param_1,true,0,0.25,uVar8,0);
      if (fVar7 <= fVar9) {
        fVar7 = fVar9;
      }
      uVar10 = (ulong)(uint)(fVar7 + fVar13);
    }
    break;
  case 8:
    break;
  case 9:
    uVar10 = (ulong)(uint)DAT_196bd9e90/*f=0.166667*/;
    break;
  case 10:
    lVar4 = 4;
    if (((byte)this[0xc] & 0x10) != 0) {
      lVar4 = 0;
    }
    puVar6 = &DAT_196bd9e10/*f=0.333333*/;
LAB_196b156d0:
    uVar10 = (ulong)*(uint *)((long)puVar6 + lVar4);
    break;
  case 0xb:
    uVar10 = 0x40000000;
    break;
  case 0xc:
    uVar10 = 0x40400000;
    break;
  case 0xd:
  case 0xe:
    fVar7 = 0.25;
    if (uVar5 != 0xd) {
      fVar7 = DAT_196bd9e90/*f=0.166667*/;
    }
    if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
      pcVar3 = (code *)SoftwareBreakpoint(0xc471,0x196b15630);
      (*pcVar3)();
    }
    auVar12 = draw_duration(param_1,uVar5 == 0xd,*(uint *)(this + 0xc),fVar7,0,0);
    return auVar12;
  }
switchD_196b155d0_caseD_8:
  auVar12._8_8_ = 0;
  auVar12._0_8_ = uVar10;
  return auVar12;
}
//==== 196b15904 intro_duration
/* RB::Symbol::Animation::intro_duration(RB::Symbol::Model const&) const */
undefined4 RB::Symbol::Animation::intro_duration(Model *param_1)
{
  int iVar1;
  bool bVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  iVar1 = *(int *)(param_1 + 4);
  if (iVar1 < 10) {
    if (iVar1 == 1) {
      return DAT_196bd9510/*f=0.333333*/;
    }
    if (iVar1 != 3) {
      return 0;
    }
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = DAT_196bd9eac/*f=0.433333*/;
  }
  else if (iVar1 == 10) {
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = DAT_196bd9510/*f=0.333333*/;
  }
  else {
    if (iVar1 != 0xb) {
      return 0;
    }
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = 0x40200000;
  }
  uVar4 = 0;
  if (!bVar2) {
    uVar4 = uVar3;
  }
  return uVar4;
}
//==== 196b15a9c begin_time_after
/* RB::Symbol::Animation::begin_time_after(double, RB::Symbol::Model const&) const */
undefined1  [16] __thiscall
RB::Symbol::Animation::begin_time_after(Animation *this,double param_1,Model *param_2)
{
  float fVar1;
  double dVar2;
  undefined1 auVar3 [16];
  float fVar4;
  ulong uVar5;
  float fVar6;
  undefined8 uVar7;
  undefined8 uVar8;
  double dVar9;
  if ((ulong)ABS(*(double *)(this + 0x30)) < 0x7ff0000000000000) {
    uVar5 = (ulong)*(uint *)(this + 0x18);
    uVar7 = NEON_frecpe(uVar5,4);
    uVar8 = NEON_frecps(uVar5,uVar7,4);
    fVar6 = (float)uVar8 * (float)uVar7;
    uVar7 = NEON_frecps(uVar5,CONCAT44((float)((ulong)uVar8 >> 0x20) * (float)((ulong)uVar7 >> 0x20)
                                       ,fVar6),4);
    fVar6 = fVar6 * (float)uVar7;
    dVar9 = param_1 - *(double *)(this + 0x30);
    if (((byte)this[0xd] >> 1 & 1) != 0) {
      fVar1 = (float)intro_duration((Model *)this);
      dVar9 = dVar9 - (double)(fVar1 * fVar6);
    }
    fVar1 = (float)local_duration(this,param_2);
    fVar4 = 0.0;
    if (1.0 < *(float *)(this + 0x1c)) {
      fVar4 = *(float *)(this + 0x20);
    }
    dVar2 = (double)(fVar4 + fVar1 * fVar6);
    dVar9 = *(double *)(this + 0x30) + dVar2 * (double)(long)(dVar9 / dVar2);
    if (((byte)this[0xd] >> 2 & 1) != 0) {
      fVar1 = (float)outro_duration((Model *)this);
      dVar9 = dVar9 + (double)(fVar1 * fVar6);
    }
  }
  else {
    dVar9 = INFINITY;
  }
  auVar3._8_8_ = 0;
  auVar3._0_8_ = dVar9;
  return auVar3;
}
//==== 196b15b9c outro_duration
/* RB::Symbol::Animation::outro_duration(RB::Symbol::Model const&) const */
undefined4 RB::Symbol::Animation::outro_duration(Model *param_1)
{
  int iVar1;
  bool bVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  iVar1 = *(int *)(param_1 + 4);
  if (iVar1 < 10) {
    if (iVar1 == 1) {
      return DAT_196bd9510/*f=0.333333*/;
    }
    if (iVar1 != 3) {
      return 0;
    }
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = DAT_196bd9eb4/*f=0.266667*/;
  }
  else if (iVar1 == 10) {
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = DAT_196bd9eb0/*f=0.416667*/;
  }
  else {
    if (iVar1 != 0xb) {
      return 0;
    }
    bVar2 = ((byte)param_1[0xc] & 0x10) == 0;
    uVar3 = 0x40200000;
  }
  uVar4 = 0;
  if (!bVar2) {
    uVar4 = uVar3;
  }
  return uVar4;
}
//==== 196b15c1c end_time
/* WARNING: Type propagation algorithm not settling */
/* RB::Symbol::Animation::end_time(RB::Symbol::Model const&) const */
undefined1  [16] __thiscall RB::Symbol::Animation::end_time(Animation *this,Model *param_1)
{
  Layer *pLVar1;
  uint uVar2;
  long lVar3;
  Layer *pLVar4;
  float fVar5;
  ulong uVar6;
  double dVar7;
  undefined1 auVar8 [16];
  float fVar9;
  float fVar10;
  undefined8 uVar11;
  undefined8 uVar12;
  double dVar13;
  if (((*(ulong *)(this + 0x30) & 0x7fffffffffffffff) < 0x7ff0000000000000) &&
     ((*(uint *)(this + 0x1c) & 0x7fffffff) < 0x7f800000)) {
    uVar6 = (ulong)*(uint *)(this + 0x18);
    uVar11 = NEON_frecpe(uVar6,4);
    uVar12 = NEON_frecps(uVar6,uVar11,4);
    fVar9 = (float)uVar12 * (float)uVar11;
    uVar11 = NEON_frecps(uVar6,CONCAT44((float)((ulong)uVar12 >> 0x20) *
                                        (float)((ulong)uVar11 >> 0x20),fVar9),4);
    fVar9 = fVar9 * (float)uVar11;
    fVar5 = (float)local_duration(this,param_1);
    fVar10 = *(float *)(this + 0x1c) + -1.0;
    if (fVar10 <= 0.0) {
      fVar10 = 0.0;
    }
    dVar13 = *(double *)(this + 0x30) +
             (double)(*(float *)(this + 0x1c) * fVar5 * fVar9 + *(float *)(this + 0x20) * fVar10);
    uVar2 = *(uint *)(this + 0xc);
    if ((uVar2 >> 6 & 1) != 0) {
      lVar3 = Model::glyph_info(param_1);
      pLVar4 = (Layer *)(lVar3 + 0x70);
      if (*(Layer **)(lVar3 + 0x1c0) != (Layer *)0x0) {
        pLVar4 = *(Layer **)(lVar3 + 0x1c0);
      }
      pLVar1 = pLVar4 + (ulong)*(uint *)(lVar3 + 0x1c8) * 0x70;
      if (*(uint *)(lVar3 + 0x1c8) == 0) {
        dVar7 = 0.0;
      }
      else {
        fVar5 = 0.0;
        do {
          fVar10 = (float)layer_delay(this,param_1,pLVar4);
          if (fVar10 <= fVar5) {
            fVar10 = fVar5;
          }
          fVar5 = fVar10;
          pLVar4 = pLVar4 + 0x70;
        } while (pLVar4 != pLVar1);
        dVar7 = (double)fVar5;
      }
      dVar13 = dVar13 + dVar7;
      uVar2 = *(uint *)(this + 0xc);
    }
    if ((uVar2 >> 9 & 1) != 0) {
      fVar5 = (float)intro_duration((Model *)this);
      dVar13 = dVar13 + (double)(fVar5 * fVar9);
    }
    if ((uVar2 >> 10 & 1) != 0) {
      fVar5 = (float)outro_duration((Model *)this);
      dVar13 = dVar13 + (double)(fVar5 * fVar9);
    }
    dVar7 = dVar13;
    if ((((uVar2 >> 7 & 1) == 0) && (*(long *)(this + 0x48) != 0)) &&
       (dVar7 = *(double *)(this + 0x30) + (double)*(float *)(*(long *)(this + 0x48) + 0x28),
       dVar7 <= dVar13)) {
      dVar7 = dVar13;
    }
  }
  else {
    dVar7 = INFINITY;
  }
  auVar8._8_8_ = 0;
  auVar8._0_8_ = dVar7;
  return auVar8;
}
//==== 196b15dc0 layer_delay
/* RB::Symbol::Animation::layer_delay(RB::Symbol::Model const&, RB::Symbol::Glyph::Layer const&)
   const */
float __thiscall RB::Symbol::Animation::layer_delay(Animation *this,Model *param_1,Layer *param_2)
{
  int iVar1;
  uint uVar2;
  long lVar3;
  uint uVar4;
  float fVar5;
  float fVar6;
  undefined8 uVar7;
  ulong uVar8;
  undefined8 uVar9;
  iVar1 = *(int *)(this + 4);
  if (iVar1 == 10 || iVar1 == 3) {
    lVar3 = Model::glyph_info(param_1);
    uVar2 = *(uint *)(lVar3 + 0x1d8);
    fVar5 = DAT_196bd9eb8/*f=0.05*/;
    if (4 < uVar2) {
      uVar8 = (ulong)(uint)((float)uVar2 + -1.0);
      uVar7 = NEON_frecpe(uVar8,4);
      uVar9 = NEON_frecps(uVar8,uVar7,4);
      fVar6 = (float)uVar9 * (float)uVar7;
      uVar7 = NEON_frecps(uVar8,CONCAT44((float)((ulong)uVar9 >> 0x20) *
                                         (float)((ulong)uVar7 >> 0x20),fVar6),4);
      fVar5 = DAT_196bd9ebc/*f=0.15*/ * fVar6 * (float)uVar7;
    }
    uVar4 = *(uint *)(param_2 + 0x48);
    if ((*(int *)(this + 4) == 3) && ((*(uint *)(this + 0xc) & 0x80000000) != 0)) {
      uVar4 = uVar2 + ~uVar4;
    }
    fVar6 = (float)uVar4;
  }
  else {
    if (iVar1 != 1) {
      return 0.0;
    }
    if (*(int *)(param_2 + 0x58) == -1) {
      return 0.0;
    }
    lVar3 = Model::glyph_info(param_1);
    uVar2 = *(uint *)(lVar3 + 0x1d4);
    if (3 < uVar2) {
      uVar8 = (ulong)(uint)(DAT_196bd9510/*f=0.333333*/ + DAT_196bd953c/*f=0.0833333*/ * (float)uVar2 +
                           DAT_196bd9ea4/*f=0.0166667*/ * (float)(uVar2 * 2 - 8));
      uVar7 = NEON_frecpe(uVar8,4);
      uVar9 = NEON_frecps(uVar8,uVar7,4);
      fVar6 = (float)uVar9 * (float)uVar7;
      uVar7 = NEON_frecps(uVar8,CONCAT44((float)((ulong)uVar9 >> 0x20) *
                                         (float)((ulong)uVar7 >> 0x20),fVar6),4);
      fVar5 = (float)NEON_ucvtf(*(undefined4 *)(param_2 + 0x58));
      return DAT_196bd9ea8/*f=0.111111*/ * fVar5 * fVar6 * (float)uVar7;
    }
    fVar5 = (float)NEON_ucvtf(*(undefined4 *)(param_2 + 0x58));
    fVar6 = DAT_196bd9510/*f=0.333333*/;
  }
  return fVar5 * fVar6;
}
//==== 196b172a0 local_time
/* RB::Symbol::Animation::local_time(float, RB::Symbol::Model const&, RB::Symbol::Glyph::Layer
   const*) const */
void RB::Symbol::Animation::local_time(float param_1,Model *param_2,Layer *param_3)
{
  TermOrArg *pTVar1;
  Layer *in_x2;
  float *in_x8;
  TermOrArg *pTVar2;
  uint uVar3;
  float fVar4;
  float fVar5;
  ulong uVar6;
  float fVar7;
  undefined8 uVar8;
  float fVar9;
  undefined8 uVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  uVar3 = *(uint *)(param_2 + 0xc);
  if (((uVar3 ^ 0xffffffff) & 0x10040) == 0) {
    fVar4 = (float)layer_delay((Animation *)param_2,(Model *)param_3,in_x2);
    param_1 = param_1 - fVar4;
    uVar3 = *(uint *)(param_2 + 0xc);
  }
  fVar9 = DAT_196bd72a8/*f=0.0001*/;
  fVar4 = DAT_196bd72a8/*f=0.0001*/;
  if (DAT_196bd72a8/*f=0.0001*/ <= param_1) {
    fVar4 = param_1;
  }
  fVar11 = fVar4 * *(float *)(param_2 + 0x18);
  if ((uVar3 >> 9 & 1) != 0) {
    fVar5 = (float)intro_duration(param_2);
    if (fVar11 < fVar5) {
      fVar9 = 0.0;
      fVar13 = 0.0;
      goto LAB_196b174c4;
    }
    fVar11 = fVar11 - fVar5;
    if ((uVar3 & 0x10040) == 0x40) {
      fVar5 = (float)layer_delay((Animation *)param_2,(Model *)param_3,in_x2);
      fVar11 = fVar11 - fVar5;
    }
    if (fVar11 <= fVar9) {
      fVar11 = fVar9;
    }
  }
  fVar5 = (float)local_duration((Animation *)param_2,(Model *)param_3);
  uVar3 = *(uint *)(param_2 + 0xc);
  if (((uVar3 >> 10 & 1) == 0) ||
     (fVar12 = fVar11 - *(float *)(param_2 + 0x1c) *
                        (fVar5 + *(float *)(param_2 + 0x20) * *(float *)(param_2 + 0x18)),
     fVar12 <= 0.0)) {
    fVar13 = 0.0;
    fVar12 = fVar11;
    if ((uVar3 >> 0xb & 1) != 0) {
      fVar12 = fVar5 + *(float *)(param_2 + 0x20) * *(float *)(param_2 + 0x18);
      fVar9 = 0.0;
      if (0.0 < fVar12) {
        uVar6 = (ulong)(uint)fVar12;
        uVar8 = NEON_frecpe(uVar6,4);
        uVar10 = NEON_frecps(uVar6,uVar8,4);
        fVar9 = (float)uVar10 * (float)uVar8;
        uVar8 = NEON_frecps(uVar6,CONCAT44((float)((ulong)uVar10 >> 0x20) *
                                           (float)((ulong)uVar8 >> 0x20),fVar9),4);
        fVar9 = fVar11 * fVar9 * (float)uVar8;
      }
      fVar13 = *(float *)(param_2 + 0x1c);
      if (fVar9 <= *(float *)(param_2 + 0x1c)) {
        fVar13 = fVar9;
      }
      fVar13 = (float)(int)fVar13;
      fVar12 = (fVar9 - fVar13) * fVar12;
    }
    if (((uVar3 >> 7 & 1) != 0) &&
       (pTVar2 = *(TermOrArg **)(param_2 + 0x48), pTVar2 != (TermOrArg *)0x0)) {
      fVar9 = 0.0;
      if (0.0 <= fVar12 * fVar5) {
        fVar9 = fVar12 * fVar5;
      }
      fVar12 = 1.0;
      if (fVar9 <= 1.0) {
        fVar12 = fVar9;
      }
      pTVar1 = pTVar2;
      if (*(TermOrArg **)(pTVar2 + 0x18) != (TermOrArg *)0x0) {
        pTVar1 = *(TermOrArg **)(pTVar2 + 0x18);
      }
      fVar12 = (float)RB::Animation::eval(fVar12,pTVar1,(ulong)*(uint *)(pTVar2 + 0x20),
                                          (State *)(pTVar2 + 0x2c));
    }
    if (fVar5 <= fVar12) {
      if ((((byte)param_2[0xd] >> 3 & 1) != 0) && (0.0 < *(float *)(param_2 + 0x20))) {
        uVar6 = (ulong)(uint)*(float *)(param_2 + 0x18);
        uVar8 = NEON_frecpe(uVar6,4);
        uVar10 = NEON_frecps(uVar6,uVar8,4);
        fVar4 = (float)uVar10 * (float)uVar8;
        uVar8 = NEON_frecps(uVar6,CONCAT44((float)((ulong)uVar10 >> 0x20) *
                                           (float)((ulong)uVar8 >> 0x20),fVar4),4);
        fVar4 = (((fVar5 + fVar11) - fVar12) +
                *(float *)(param_2 + 0x20) * *(float *)(param_2 + 0x18)) * fVar4 * (float)uVar8;
      }
      fVar9 = 1.4013e-45;
      fVar11 = fVar5;
    }
    else {
      fVar9 = 1.4013e-45;
      fVar11 = fVar12;
    }
  }
  else {
    fVar5 = (float)outro_duration(param_2);
    if (fVar5 <= fVar12) {
      fVar12 = fVar5;
    }
    fVar13 = 0.0;
    fVar9 = 2.8026e-45;
    fVar11 = fVar12;
  }
LAB_196b174c4:
  fVar7 = 0.0;
  fVar12 = 0.0;
  if (0.0 <= fVar11) {
    fVar12 = fVar11;
  }
  fVar11 = fVar5;
  if (fVar12 <= fVar5) {
    fVar11 = fVar12;
  }
  *in_x8 = fVar11;
  in_x8[1] = fVar13;
  if (0.0 < fVar5) {
    uVar6 = (ulong)(uint)fVar5;
    uVar8 = NEON_frecpe(uVar6,4);
    uVar10 = NEON_frecps(uVar6,uVar8,4);
    fVar7 = (float)uVar10 * (float)uVar8;
    uVar8 = NEON_frecps(uVar6,CONCAT44((float)((ulong)uVar10 >> 0x20) *
                                       (float)((ulong)uVar8 >> 0x20),fVar7),4);
    fVar7 = fVar7 * (float)uVar8;
  }
  in_x8[2] = fVar7;
  in_x8[3] = fVar4;
  in_x8[4] = fVar9;
  return;
}
//==== 196b176fc frame_delay
/* RB::Symbol::Animation::frame_delay(RB::Symbol::Model const&) const */
undefined4 __thiscall RB::Symbol::Animation::frame_delay(Animation *this,Model *param_1)
{
  int iVar1;
  Glyph *pGVar2;
  undefined4 uVar3;
  uVar3 = DAT_196bd9eb8/*f=0.05*/;
  if (1 < *(int *)(this + 4) - 1U) {
    if (*(int *)(this + 4) == 0) {
      pGVar2 = (Glyph *)Model::glyph_info(param_1);
      iVar1 = Model::should_variable_draw(param_1,pGVar2);
      if (iVar1 == 0) {
        return uVar3;
      }
    }
    uVar3 = 0;
  }
  return uVar3;
}
//==== 196b178f8 draw_duration
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
/* RB::Symbol::Animation::draw_duration(RB::Symbol::Model const&, bool, unsigned int, float,
   unsigned int, unsigned int) */
undefined1  [16]
RB::Symbol::Animation::draw_duration
          (Model *param_1,bool param_2,uint param_3,float param_4,uint param_5,uint param_6)
{
  TimingGroup *pTVar1;
  uint uVar2;
  Glyph *pGVar3;
  TimingGroup *pTVar4;
  long extraout_x8;
  long lVar5;
  ulong uVar6;
  undefined1 auVar7 [16];
  float fVar8;
  float fVar9;
  ulong uVar10;
  ulong uVar11;
  undefined8 uVar12;
  TimingGroup aTStack_70 [8];
  long local_68;
  local_68 = *_DAT_1e01cc7f0;
  pGVar3 = (Glyph *)Model::glyph_info(param_1);
  uVar2 = *(uint *)(pGVar3 + 0x1d8);
  uVar6 = (ulong)uVar2;
  if (uVar2 < 0x156) {
    (*_DAT_1e2125200)();
    pTVar4 = aTStack_70 + -(extraout_x8 + 0xfU & 0x1ffffffff0);
    func_0x0001981043d0(pTVar4,extraout_x8);
LAB_196b179b8:
    draw_timing_groups(pTVar4,pGVar3,param_2,param_3,param_4,param_5,param_6);
    if (uVar2 == 0) {
      uVar10 = 0;
      uVar12 = 0;
      goto LAB_196b17a4c;
    }
    lVar5 = 0;
    uVar11 = 0;
    do {
      pTVar1 = pTVar4 + lVar5 * 0xc;
      fVar8 = *(float *)(pTVar1 + 4);
      fVar9 = fVar8;
      if ((!param_2) && (fVar9 = fVar8 + DAT_196bd9ec4/*f=0.0333333*/, pTVar1[10] == (TimingGroup)0x0)) {
        fVar9 = fVar8;
      }
      uVar10 = uVar11;
      if ((0.0 < fVar9) &&
         (uVar10 = (ulong)(uint)(*(float *)pTVar1 + fVar9),
         *(float *)pTVar1 + fVar9 <= (float)uVar11)) {
        uVar10 = uVar11;
      }
      uVar12 = 0;
      lVar5 = lVar5 + 1;
      uVar6 = uVar6 - 1;
      uVar11 = uVar10;
    } while (uVar6 != 0);
    if (uVar2 < 0x156) goto LAB_196b17a4c;
  }
  else {
    pTVar4 = (TimingGroup *)func_0x000198107840(uVar6 * 0xc,0x1000040fd6f1ff4);
    if (pTVar4 != (TimingGroup *)0x0) goto LAB_196b179b8;
    uVar10 = 0;
  }
  uVar12 = 0;
  func_0x000198104520(pTVar4);
LAB_196b17a4c:
  if (*_DAT_1e01cc7f0 == local_68) {
    auVar7._8_8_ = uVar12;
    auVar7._0_8_ = uVar10;
    return auVar7;
  }
  auVar7 = func_0x000198104300();
  return auVar7;
}
//==== 196b17c84 pulse_keyframes
/* RB::Symbol::Animation::pulse_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&) const */
void __thiscall
RB::Symbol::Animation::pulse_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2)
{
  uint uVar1;
  undefined4 uVar2;
  undefined4 local_58;
  undefined8 local_54;
  ulong local_48;
  local_58 = 0x20000c;
  if (param_1[0x18] == (KeyframesArgs)0x1) {
    KeyframeStorage::clear(param_2);
  }
  else {
    uVar1 = *(uint *)(this + 0xc);
    KeyframeStorage::clear(param_2);
    if ((uVar1 & 8) != 0) {
      local_58 = 0x20082c;
    }
  }
  local_54 = 0;
  local_48 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
  KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_58);
  uVar2 = 0x3f800000;
  if (0x7fffffff < *(uint *)(this + 0xc)) {
    uVar2 = 0x3f000000;
  }
  KeyframeStorage::push_value((KeyframeStorage *)(float)1,uVar2,param_2,1);
  KeyframeStorage::push_value((KeyframeStorage *)0x0,uVar2,param_2,1);
  KeyframeStorage::push_value(param_2,1.0);
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b17d6c breathe_keyframes
//==== 196b17f68 variable_value_keyframes
/* RB::Symbol::Animation::variable_value_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&) const */
void __thiscall
RB::Symbol::Animation::variable_value_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2)
{
  uint uVar1;
  uint local_48 [4];
  undefined1 *local_38;
  uVar1 = 0x10;
  if (param_1[0x1a] == (KeyframesArgs)0x0) {
    uVar1 = 0x20;
  }
  KeyframeStorage::clear(param_2);
  local_48[0] = uVar1 << 0xf | (uVar1 >> 4) << 9 | 0xb;
  local_48[1] = 0;
  local_48[2] = 0;
  local_38 = &variable_value_keyframes(RB::Symbol::Animation::KeyframesArgs_const&,RB::Symbol::KeyframeStorage&)
              ::alpha_values;
  KeyframeStorage::push_keyframes(param_2,(Keyframes *)local_48);
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b17ff0 vc_intro_outro_keyframes
/* RB::Symbol::Animation::vc_intro_outro_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Animation::Time::Phase, RB::Symbol::Model const&) const
    */
void RB::Symbol::Animation::vc_intro_outro_keyframes
               (undefined8 param_1,undefined8 param_2,KeyframeStorage *param_3,int param_4)
{
  float fVar1;
  KeyframeStorage *pKVar2;
  undefined8 local_48;
  undefined4 local_40;
  ulong local_38;
  KeyframeStorage::clear(param_3);
  local_48 = DAT_196bd9e50/*f=?*/;
  local_40 = 0;
  local_38 = (ulong)*(uint *)(param_3 + 0x308) << 1 | 1;
  KeyframeStorage::push_keyframes(param_3,(Keyframes *)&local_48);
  pKVar2._0_4_ = (KeyframeStorage *)0x0;
  if (param_4 != 0) {
    pKVar2._0_4_ = (float)1;
  }
  fVar1 = 1.0;
  if (param_4 != 0) {
    fVar1 = 0.0;
  }
  KeyframeStorage::push_value(pKVar2._0_4_,DAT_196bd9510/*f=0.333333*/,param_3,1);
  KeyframeStorage::push_value(param_3,fVar1);
  KeyframeStorage::commit(param_3);
  return;
}
//==== 196b18094 vc_cumulative_keyframes
/* RB::Symbol::Animation::vc_cumulative_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Model const&) const */
void __thiscall
RB::Symbol::Animation::vc_cumulative_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2,Model *param_3)
{
  uint uVar1;
  undefined4 uVar2;
  float fVar3;
  uint uVar4;
  float fVar5;
  undefined8 uVar6;
  ulong uVar7;
  undefined8 uVar8;
  KeyframeStorage *pKVar9;
  float fVar10;
  float fVar11;
  undefined4 local_88;
  uint uStack_84;
  float local_80;
  ulong local_78;
  pKVar9 = (KeyframeStorage *)0x0;
  uVar1 = *(uint *)(param_1 + 0x14);
  if (((byte)this[0xf] >> 5 & 1) == 0) {
    if (*(int *)param_1 == 3) {
      pKVar9 = (KeyframeStorage *)Model::alpha(param_3,2);
    }
    else {
      pKVar9 = (KeyframeStorage *)(ulong)DAT_196bd7264/*f=0.3*/;
    }
  }
  uVar2 = 0x6000008;
  KeyframeStorage::clear(param_2);
  fVar3 = DAT_196bd9510/*f=0.333333*/;
  if (uVar1 == 0 || uVar1 - 1 == 0) {
    if (uVar1 == 0) {
      uVar2 = 1;
    }
    local_80 = 0.0;
    local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
    local_88 = uVar2;
    uStack_84 = uVar1;
    KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
    fVar3 = DAT_196bd9510/*f=0.333333*/;
    KeyframeStorage::push_value(pKVar9,DAT_196bd9510/*f=0.333333*/,param_2,1);
    KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar3,param_2,0);
    KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar3,param_2,1);
    KeyframeStorage::push_value(param_2,SUB84(pKVar9,0));
  }
  else {
    fVar11 = DAT_196bd9e94/*f=0.666667*/;
    if (uVar1 != 2) {
      fVar11 = 1.0;
    }
    fVar5 = DAT_196bd9510/*f=0.333333*/;
    if (3 < uVar1) {
      uVar7 = (ulong)(uint)(float)(uVar1 - 1);
      uVar6 = NEON_frecpe(uVar7,4);
      uVar8 = NEON_frecps(uVar7,uVar6,4);
      fVar5 = (float)uVar8 * (float)uVar6;
      uVar6 = NEON_frecps(uVar7,CONCAT44((float)((ulong)uVar8 >> 0x20) *
                                         (float)((ulong)uVar6 >> 0x20),fVar5),4);
      fVar5 = DAT_196bd9ed4/*f=0.666667*/ * fVar5 * (float)uVar6;
    }
    uVar4 = 0;
    do {
      local_80 = fVar5 * (float)uVar4;
      fVar10 = fVar11 - local_80;
      uVar4 = uVar4 + 1;
      local_88 = 0x6000008;
      local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      uStack_84 = uVar4;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
      KeyframeStorage::push_value(pKVar9,fVar3,param_2,1);
      KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar10,param_2,0);
      KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar3,param_2,1);
      KeyframeStorage::push_value(param_2,SUB84(pKVar9,0));
    } while (uVar1 != uVar4);
  }
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b18298 vc_cumulative_bounce_keyframes
/* RB::Symbol::Animation::vc_cumulative_bounce_keyframes(RB::Symbol::Animation::KeyframesArgs
   const&, RB::Symbol::KeyframeStorage&, RB::Symbol::Model const&) const */
void __thiscall
RB::Symbol::Animation::vc_cumulative_bounce_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2,Model *param_3)
{
  uint uVar1;
  uint uVar2;
  undefined4 uVar3;
  float fVar4;
  uint uVar5;
  uint uVar6;
  float fVar7;
  undefined8 uVar8;
  ulong uVar9;
  undefined8 uVar10;
  KeyframeStorage *pKVar11;
  undefined4 local_88;
  uint uStack_84;
  float local_80;
  ulong local_78;
  pKVar11 = (KeyframeStorage *)0x0;
  uVar2 = *(uint *)(param_1 + 0x14);
  if (((byte)this[0xf] >> 5 & 1) == 0) {
    if (*(int *)param_1 == 3) {
      pKVar11 = (KeyframeStorage *)Model::alpha(param_3,2);
    }
    else {
      pKVar11 = (KeyframeStorage *)(ulong)DAT_196bd7264/*f=0.3*/;
    }
  }
  uVar3 = 0x6000008;
  KeyframeStorage::clear(param_2);
  fVar4 = DAT_196bd9510/*f=0.333333*/;
  uVar6 = uVar2 - 1;
  if (uVar2 == 0 || uVar6 == 0) {
    if (uVar2 == 0) {
      uVar3 = 1;
    }
    local_80 = 0.0;
    local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
    local_88 = uVar3;
    uStack_84 = uVar2;
    KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
    fVar4 = DAT_196bd9510/*f=0.333333*/;
    KeyframeStorage::push_value(pKVar11,DAT_196bd9510/*f=0.333333*/,param_2,1);
    KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar4,param_2,0);
    KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar4,param_2,1);
    KeyframeStorage::push_value(param_2,SUB84(pKVar11,0));
  }
  else {
    fVar7 = DAT_196bd9510/*f=0.333333*/;
    if (3 < uVar2) {
      uVar9 = (ulong)(uint)(float)uVar6;
      uVar8 = NEON_frecpe(uVar9,4);
      uVar10 = NEON_frecps(uVar9,uVar8,4);
      fVar7 = (float)uVar10 * (float)uVar8;
      uVar8 = NEON_frecps(uVar9,CONCAT44((float)((ulong)uVar10 >> 0x20) *
                                         (float)((ulong)uVar8 >> 0x20),fVar7),4);
      fVar7 = DAT_196bd9e94/*f=0.666667*/ * fVar7 * (float)uVar8;
    }
    uVar5 = 0;
    do {
      uVar1 = uVar5 + 1;
      local_88 = 0x6000008;
      local_80 = fVar7 * (float)uVar5;
      local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      uStack_84 = uVar1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
      KeyframeStorage::push_value(pKVar11,fVar4,param_2,1);
      KeyframeStorage::push_value
                ((KeyframeStorage *)(float)1,fVar4 + (float)uVar6 * (fVar7 + fVar7),param_2,0);
      KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar4,param_2,1);
      KeyframeStorage::push_value(param_2,SUB84(pKVar11,0));
      uVar6 = uVar6 - 1;
      uVar5 = uVar1;
    } while (uVar1 != uVar2);
  }
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b1849c vc_sequential_keyframes
/* RB::Symbol::Animation::vc_sequential_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Model const&) const */
void __thiscall
RB::Symbol::Animation::vc_sequential_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2,Model *param_3)
{
  uint uVar1;
  undefined4 uVar2;
  uint uVar3;
  uint uVar4;
  uint uVar5;
  int iVar6;
  uint uVar7;
  float fVar8;
  float fVar9;
  undefined8 uVar10;
  ulong uVar11;
  undefined8 uVar12;
  KeyframeStorage *pKVar13;
  float fVar14;
  undefined4 local_98;
  uint uStack_94;
  float fStack_90;
  ulong local_88;
  pKVar13 = (KeyframeStorage *)0x0;
  uVar4 = *(uint *)(this + 0xc);
  if ((uVar4 >> 0x1d & 1) == 0) {
    if (*(int *)param_1 == 3) {
      pKVar13 = (KeyframeStorage *)Model::alpha(param_3,2);
      uVar4 = *(uint *)(this + 0xc);
    }
    else {
      pKVar13 = (KeyframeStorage *)(ulong)DAT_196bd7264/*f=0.3*/;
    }
  }
  uVar3 = *(uint *)(param_1 + 0x14);
  uVar4 = uVar4 & 0x10000040;
  if (uVar4 == 0x10000000) {
    uVar3 = uVar3 + 1;
  }
  KeyframeStorage::clear(param_2);
  fVar14 = DAT_196bd9510/*f=0.333333*/;
  if (uVar3 < 4) {
    if (((byte)this[0xc] >> 6 & 1) == 0) {
      uVar5 = 0;
      iVar6 = uVar3 - 1;
      uVar7 = uVar3;
      if (uVar3 == 0 || iVar6 == 0) {
        uVar7 = 1;
      }
      do {
        local_98 = 0x6000008;
        if (uVar4 == 0x10000000 && iVar6 == 0) {
          local_98 = 0x6000009;
        }
        uStack_94 = 1;
        if (uVar4 != 0x10000000 || iVar6 != 0) {
          uStack_94 = uVar5 + 1;
        }
        if (uVar3 == 0) {
          local_98 = 1;
          uStack_94 = 0;
        }
        uVar1 = uVar5 + 1;
        fStack_90 = (float)uVar5 * fVar14;
        local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
        KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
        iVar6 = iVar6 + -1;
        uVar5 = uVar1;
        fVar9 = fVar14;
      } while (uVar1 != uVar7);
    }
    else {
      local_98 = 0x100008;
      if (uVar3 != 0) {
        local_98 = 0x100408;
      }
      uStack_94 = 0;
      fStack_90 = 0.0;
      local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
      fVar14 = DAT_196bd9510/*f=0.333333*/;
      fVar9 = DAT_196bd9510/*f=0.333333*/;
    }
  }
  else {
    fVar8 = DAT_196bd9510/*f=0.333333*/ + DAT_196bd9ea4/*f=0.0166667*/ * (float)(uVar3 * 2 - 8);
    uVar11 = (ulong)(uint)(fVar8 + DAT_196bd953c/*f=0.0833333*/ * (float)uVar3);
    uVar10 = NEON_frecpe(uVar11,4);
    uVar12 = NEON_frecps(uVar11,uVar10,4);
    fVar9 = (float)uVar12 * (float)uVar10;
    uVar10 = NEON_frecps(uVar11,CONCAT44((float)((ulong)uVar12 >> 0x20) *
                                         (float)((ulong)uVar10 >> 0x20),fVar9),4);
    fVar9 = fVar9 * (float)uVar10;
    fVar14 = DAT_196bd9ea8/*f=0.111111*/ * fVar9;
    fVar9 = fVar8 * DAT_196bd9ea0/*f=1.33333*/ * fVar9;
    if (((byte)this[0xc] >> 6 & 1) == 0) {
      uVar7 = 1;
      do {
        uVar5 = uVar7;
        uVar2 = 0x6000008;
        if (uVar7 == uVar3) {
          uVar2 = 0x6000009;
          uVar5 = 1;
        }
        uStack_94 = uVar7;
        local_98 = 0x6000008;
        if (uVar4 == 0x10000000) {
          uStack_94 = uVar5;
          local_98 = uVar2;
        }
        fStack_90 = fVar14 * (float)(uVar7 - 1);
        local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
        KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
        uVar7 = uVar7 + 1;
      } while (uVar7 - uVar3 != 1);
    }
    else {
      local_98 = (undefined4)DAT_196bd9e58/*f=?*/;
      uStack_94 = (uint)((ulong)DAT_196bd9e58/*f=?*/ >> 0x20);
      fStack_90 = 0.0;
      local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
    }
  }
  KeyframeStorage::push_value(pKVar13,fVar14,param_2,1);
  KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
  KeyframeStorage::push_value(param_2,SUB84(pKVar13,0));
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b1878c vc_sequential_bounce_keyframes
/* RB::Symbol::Animation::vc_sequential_bounce_keyframes(RB::Symbol::Animation::KeyframesArgs
   const&, RB::Symbol::KeyframeStorage&, RB::Symbol::Model const&) const */
void __thiscall
RB::Symbol::Animation::vc_sequential_bounce_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2,Model *param_3)
{
  uint uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  bool bVar4;
  uint uVar5;
  int iVar6;
  uint uVar7;
  uint uVar8;
  float fVar9;
  KeyframeStorage *pKVar10;
  float fVar11;
  float fVar12;
  undefined8 uVar13;
  ulong uVar14;
  undefined8 uVar15;
  KeyframeStorage *pKVar16;
  float fVar17;
  float fVar18;
  KeyframeStorage *pKVar19;
  undefined4 local_a8;
  int iStack_a4;
  float local_a0;
  ulong local_98;
  pKVar16 = (KeyframeStorage *)0x0;
  uVar5 = *(uint *)(this + 0xc);
  if ((uVar5 >> 0x1d & 1) == 0) {
    if (*(int *)param_1 == 3) {
      pKVar16 = (KeyframeStorage *)Model::alpha(param_3,2);
      uVar5 = *(uint *)(this + 0xc);
    }
    else {
      pKVar16 = (KeyframeStorage *)(ulong)DAT_196bd7264/*f=0.3*/;
    }
  }
  uVar2 = 0x6000008;
  uVar5 = uVar5 & 0x10000000;
  uVar1 = *(int *)(param_1 + 0x14) + (uVar5 >> 0x1c);
  KeyframeStorage::clear(param_2);
  uVar3 = DAT_196bd9e94/*f=0.666667*/;
  fVar9 = DAT_196bd9510/*f=0.333333*/;
  uVar7 = uVar1 - 2;
  if (uVar1 < 2 || uVar7 == 0) {
    iVar6 = 0;
    uVar7 = uVar1;
    do {
      uVar7 = uVar7 - 1;
      local_a8 = uVar2;
      if (uVar7 == 0) {
        local_a8 = 0x6000009;
      }
      iStack_a4 = 1;
      if (uVar7 != 0) {
        iStack_a4 = iVar6 + 1;
      }
      if (uVar5 == 0) {
        iStack_a4 = iVar6 + 1;
        local_a8 = uVar2;
      }
      if (uVar1 == 0) {
        iStack_a4 = 0;
        local_a8 = 1;
      }
      local_a0 = 0.0;
      local_98 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_a8);
      pKVar10 = SUB84(pKVar16,0);
      pKVar19 = (float)1;
      if (iVar6 != 0) {
        pKVar10 = (float)1;
        pKVar19 = SUB84(pKVar16,0);
      }
      KeyframeStorage::push_value(pKVar19,fVar9,param_2,1);
      KeyframeStorage::push_value(pKVar10,fVar9,param_2,1);
      KeyframeStorage::push_value(param_2,(float)pKVar19);
    } while ((uVar1 != 0) && (bVar4 = iVar6 == 0, iVar6 = iVar6 + 1, bVar4));
  }
  else if (uVar1 == 3) {
    iVar6 = 0;
    do {
      if (uVar5 == 0) {
        iStack_a4 = iVar6 + 1;
        local_a8 = 0x6000008;
      }
      else {
        local_a8 = uVar2;
        if (iVar6 == 2) {
          local_a8 = 0x6000009;
        }
        iStack_a4 = 1;
        if (iVar6 != 2) {
          iStack_a4 = iVar6 + 1;
        }
      }
      local_a0 = fVar9;
      if (iVar6 != 2) {
        local_a0 = 0.0;
      }
      local_98 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_a8);
      if (iVar6 == 1) {
        KeyframeStorage::push_value(pKVar16,fVar9,param_2,1);
        KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
        KeyframeStorage::push_value(pKVar16,fVar9,param_2,1);
LAB_196b189e0:
        pKVar19 = (KeyframeStorage *)(float)1;
        pKVar10 = pKVar16;
      }
      else {
        if (iVar6 != 0) {
          KeyframeStorage::push_value(pKVar16,fVar9,param_2,1);
          goto LAB_196b189e0;
        }
        KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
        KeyframeStorage::push_value(pKVar16,uVar3,param_2,0);
        pKVar10 = (KeyframeStorage *)(float)1;
        pKVar19 = pKVar16;
      }
      KeyframeStorage::push_value(pKVar19,fVar9,param_2,1);
      KeyframeStorage::push_value(param_2,SUB84(pKVar10,0));
      iVar6 = iVar6 + 1;
    } while (iVar6 != 3);
  }
  else {
    uVar8 = 0;
    fVar9 = DAT_196bd9510/*f=0.333333*/ + DAT_196bd9ea4/*f=0.0166667*/ * (float)(uVar1 * 2 - 8);
    fVar11 = fVar9 + DAT_196bd953c/*f=0.0833333*/ * (float)uVar7;
    uVar14 = (ulong)(uint)(fVar11 + fVar11);
    uVar13 = NEON_frecpe(uVar14,4);
    uVar15 = NEON_frecps(uVar14,uVar13,4);
    fVar11 = (float)uVar15 * (float)uVar13;
    uVar13 = NEON_frecps(uVar14,CONCAT44((float)((ulong)uVar15 >> 0x20) *
                                         (float)((ulong)uVar13 >> 0x20),fVar11),4);
    fVar11 = fVar11 * (float)uVar13;
    fVar17 = DAT_196bd9ed8/*f=0.208333*/ * fVar11;
    fVar9 = fVar9 * 2.5 * fVar11;
    fVar11 = DAT_196bd9edc/*f=0.416667*/ * fVar11;
    do {
      if (uVar5 == 0) {
        iStack_a4 = uVar8 + 1;
        local_a8 = 0x6000008;
      }
      else {
        local_a8 = uVar2;
        if (uVar7 == 0xffffffff) {
          local_a8 = 0x6000009;
        }
        iStack_a4 = 1;
        if (uVar7 != 0xffffffff) {
          iStack_a4 = uVar8 + 1;
        }
      }
      local_a0 = 0.0;
      if (0.0 <= (float)uVar8 + -1.0) {
        local_a0 = (float)uVar8 + -1.0;
      }
      local_a0 = local_a0 * fVar17;
      local_98 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_a8);
      fVar18 = fVar11 * (float)uVar7;
      if (uVar8 == 0) {
        pKVar10 = (KeyframeStorage *)(float)1;
        KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
        KeyframeStorage::push_value(pKVar16,fVar18,param_2,0);
        KeyframeStorage::push_value(pKVar16,fVar17,param_2,1);
      }
      else {
        KeyframeStorage::push_value(pKVar16,fVar17,param_2,1);
        pKVar10 = (KeyframeStorage *)(float)1;
        bVar4 = uVar8 < uVar1 - 1;
        fVar12 = fVar9 - fVar17;
        if (bVar4) {
          KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
          KeyframeStorage::push_value(pKVar16,fVar18,param_2,0);
          pKVar10 = pKVar16;
          fVar12 = fVar17;
        }
        KeyframeStorage::push_value(pKVar10,fVar12,param_2,bVar4);
        KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar9,param_2,1);
        pKVar10 = pKVar16;
      }
      KeyframeStorage::push_value(param_2,SUB84(pKVar10,0));
      uVar8 = uVar8 + 1;
      uVar7 = uVar7 - 1;
    } while (uVar7 != 0xfffffffe);
  }
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b18c14 bounce_keyframes
/* RB::Symbol::Animation::bounce_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Animation::Time::Phase) const */
void __thiscall
RB::Symbol::Animation::bounce_keyframes
          (Animation *this,long param_1,KeyframeStorage *param_2,int param_4)
{
  long lVar1;
  uint uVar2;
  uint uVar3;
  float fVar4;
  undefined4 uVar5;
  float fVar6;
  bool bVar7;
  uint uVar8;
  float fVar9;
  KeyframeStorage *pKVar11;
  KeyframeStorage *pKVar12;
  KeyframeStorage *pKVar13;
  float fVar10;
  ulong local_98;
  float local_90;
  ulong local_88;
  uVar8 = *(uint *)(this + 0xc);
  KeyframeStorage::clear(param_2);
  fVar6 = DAT_196bd9ee8/*f=0.266667*/;
  uVar5 = DAT_196bd9ee0/*f=0.216667*/;
  if ((uVar8 >> 4 & 1) == 0) {
    uVar2 = *(uint *)(this + 0xc);
    uVar3 = *(uint *)(param_1 + 8);
    if ((uVar2 & 8) == 0) {
      uVar3 = 1;
    }
    fVar10 = 0.0;
    if ((1 < uVar3) &&
       (fVar9 = DAT_196bd9ee4/*f=0.15*/ / (float)(uVar3 - 1), fVar10 = DAT_196bd9eb8/*f=0.05*/, fVar9 <= DAT_196bd9eb8/*f=0.05*/))
    {
      fVar10 = fVar9;
    }
    bVar7 = (uVar8 & 0x80000000) != 0;
    fVar9 = fVar10;
    fVar4 = 0.0;
    if (bVar7) {
      fVar9 = -fVar10;
      fVar4 = fVar10 * (float)(uVar3 - 1);
    }
    pKVar11._0_4_ = (float)1.25;
    if (bVar7) {
      pKVar11._0_4_ = (float)0.75;
    }
    lVar1 = 4;
    if (bVar7) {
      lVar1 = 0;
    }
    if (uVar3 != 0) {
      uVar8 = 0;
                    /* WARNING: Load size is inaccurate */
      pKVar12._0_4_ = *(KeyframeStorage **)((long)&DAT_196bd9e78/*f=1.109*/ + lVar1);
      do {
        fVar10 = fVar4 + (float)uVar8 * fVar9;
        local_98 = CONCAT44(uVar8,(uVar2 & 8) << 0x16) | 2;
        local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
        local_90 = fVar10;
        KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
        KeyframeStorage::push_value((KeyframeStorage *)(float)1,uVar5,param_2,3);
        KeyframeStorage::push_value(pKVar11._0_4_,uVar5,param_2,4);
        KeyframeStorage::push_value(pKVar12._0_4_,fVar6 - fVar10,param_2,5);
        KeyframeStorage::push_value(param_2,1.0);
        uVar8 = uVar8 + 1;
      } while (uVar3 != uVar8);
    }
  }
  else {
    local_98 = DAT_196bd9e60/*f=?*/;
    local_90 = 0.0;
    local_88 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
    KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_98);
    uVar5 = DAT_196bd9ee0/*f=0.216667*/;
    lVar1 = 4;
    if ((uVar8 & 0x80000000) != 0) {
      lVar1 = 0;
    }
                    /* WARNING: Load size is inaccurate */
    pKVar11._0_4_ = *(KeyframeStorage **)((long)&DAT_196bd9e70/*f=1.059*/ + lVar1);
    if (param_4 == 2) {
      KeyframeStorage::push_value(pKVar11._0_4_,DAT_196bd9eb4/*f=0.266667*/,param_2,5);
      pKVar11._0_4_ = (float)1;
    }
    else {
                    /* WARNING: Load size is inaccurate */
      pKVar13._0_4_ = *(KeyframeStorage **)((long)&DAT_196bd9e68/*f=0.95*/ + lVar1);
      pKVar12._0_4_ = pKVar11._0_4_;
      if (param_4 != 1) {
        if (param_4 != 0) goto LAB_196b18e5c;
        pKVar12._0_4_ = (float)1;
      }
      KeyframeStorage::push_value(pKVar12._0_4_,DAT_196bd9ee0/*f=0.216667*/,param_2,3);
      KeyframeStorage::push_value(pKVar13._0_4_,uVar5,param_2,4);
    }
    KeyframeStorage::push_value(param_2,(float)pKVar11._0_4_);
  }
LAB_196b18e5c:
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b18e8c wiggle_keyframes
//==== 196b191bc rotate_keyframes
/* RB::Symbol::Animation::rotate_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Animation::Time::Phase) const */
void __thiscall
RB::Symbol::Animation::rotate_keyframes
          (Animation *this,long param_1,KeyframeStorage *param_2,int param_4)
{
  int iVar1;
  uint uVar2;
  bool bVar3;
  undefined8 uVar4;
  uint uVar5;
  uint uVar6;
  uint uVar7;
  float fVar8;
  float fVar9;
  undefined8 uVar10;
  float fVar11;
  undefined4 uVar12;
  KeyframeStorage *pKVar14;
  float fVar13;
  uint local_88;
  undefined8 local_84;
  ulong local_78;
  uVar7 = 0x400006;
  uVar5 = *(uint *)(this + 0xc);
  if ((*(byte *)(param_1 + 0x19) & 1) == 0) {
    uVar6 = *(uint *)(param_1 + 8);
    bVar3 = (uVar5 & 8) != 0;
    if (bVar3) {
      uVar7 = 0x400007;
    }
    else {
      uVar6 = 1;
    }
  }
  else {
    bVar3 = false;
    uVar6 = 1;
  }
  KeyframeStorage::clear(param_2);
  fVar13 = DAT_196bd9f08/*f=1.83333*/;
  uVar12 = DAT_196bd9e94/*f=0.666667*/;
  iVar1 = -2;
  if (-1 < (int)uVar5) {
    iVar1 = 2;
  }
  fVar11 = (float)iVar1 * DAT_196bd9d10/*f=3.14159*/;
  if ((uVar5 >> 4 & 1) == 0) {
    if (uVar6 < 2) {
      if (uVar6 == 0) goto LAB_196b19480;
      fVar13 = 0.0;
      uVar12 = 0x40000000;
    }
    else {
      fVar13 = DAT_196bd8f48/*f=0.133333*/;
      uVar12 = DAT_196bd9f0c/*f=1.86667*/;
      if ((uVar6 != 2) &&
         (fVar8 = DAT_196bd9eb4/*f=0.266667*/ / (float)(uVar6 - 1), uVar12 = DAT_196bd9f10/*f=1.73333*/, fVar8 <= DAT_196bd8f48/*f=0.133333*/
         )) {
        fVar13 = fVar8;
      }
    }
    uVar5 = 0;
    uVar2 = 0x2001000;
    if (!bVar3) {
      uVar2 = 0;
    }
    do {
      local_84 = CONCAT44(fVar13 * (float)uVar5,uVar5);
      local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      local_88 = uVar2 | uVar7;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
      KeyframeStorage::push_value((KeyframeStorage *)0x0,uVar12,param_2,10);
      KeyframeStorage::push_value(param_2,fVar11);
      uVar5 = uVar5 + 1;
    } while (uVar6 != uVar5);
    goto LAB_196b19480;
  }
  if ((param_4 == 0) && (1 < uVar6)) {
    uVar5 = 0;
    fVar9 = 0.25 / (float)(uVar6 - 1);
    fVar8 = DAT_196bd953c/*f=0.0833333*/;
    if (fVar9 <= DAT_196bd953c/*f=0.0833333*/) {
      fVar8 = fVar9;
    }
    pKVar14._0_4_ = (KeyframeStorage *)((float)iVar1 * DAT_196bd9f04/*f=0.529707*/);
    uVar2 = 0x2001000;
    if (!bVar3) {
      uVar2 = 0;
    }
    do {
      local_84 = CONCAT44(fVar8 * (float)uVar5,uVar5);
      local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      local_88 = uVar2 | uVar7;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
      KeyframeStorage::push_value((KeyframeStorage *)0x0,uVar12,param_2,0xb);
      KeyframeStorage::push_value(pKVar14._0_4_,fVar13 - fVar8 * (float)uVar5,param_2,0xc);
      KeyframeStorage::push_value(param_2,fVar11);
      uVar5 = uVar5 + 1;
    } while (uVar6 != uVar5);
    goto LAB_196b19480;
  }
  local_88 = 0x1000;
  if (!bVar3) {
    local_88 = 0;
  }
  local_88 = local_88 | uVar7;
  local_84 = 0;
  local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
  KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
  if (param_4 == 2) {
    uVar10 = 0x40200000;
    uVar4 = 0xd;
LAB_196b19470:
    KeyframeStorage::push_value((KeyframeStorage *)0x0,uVar10,param_2,uVar4);
  }
  else {
    if (param_4 == 1) {
      uVar10 = 0x40000000;
      uVar4 = 0xc;
      goto LAB_196b19470;
    }
    if (param_4 == 0) {
      uVar10 = 0x40200000;
      uVar4 = 0xb;
      goto LAB_196b19470;
    }
  }
  KeyframeStorage::push_value(param_2,fVar11);
LAB_196b19480:
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b194ac scale_keyframes
/* RB::Symbol::Animation::scale_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&) const */
undefined8 __thiscall
RB::Symbol::Animation::scale_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2)
{
  undefined4 uVar1;
  int iVar2;
  int iVar3;
  uint uVar4;
  uint uVar5;
  undefined8 uVar6;
  byte bVar7;
  undefined4 uVar8;
  uint uVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  uint local_88;
  uint uStack_84;
  float local_80;
  ulong local_78;
  iVar2 = *(int *)(param_1 + 0x1c);
  iVar3 = *(int *)(param_1 + 0x20);
  if (iVar2 < iVar3) {
    bVar7 = 0 < iVar3;
  }
  else {
    if (iVar2 <= iVar3) {
      return 0;
    }
    bVar7 = 2;
    if (iVar2 < 1) {
      bVar7 = 3;
    }
  }
  uVar4 = *(uint *)(this + 0xc);
  uVar5 = *(uint *)(param_1 + 8);
  if ((uVar4 & 8) == 0) {
    uVar5 = 1;
  }
  fVar12 = 0.0;
  if ((1 < uVar5) &&
     (fVar10 = DAT_196bd9ebc/*f=0.15*/ / (float)(uVar5 - 1), fVar12 = DAT_196bd9eb8/*f=0.05*/, fVar10 <= DAT_196bd9eb8/*f=0.05*/))
  {
    fVar12 = fVar10;
  }
  fVar10 = -fVar12;
  fVar11 = fVar12 * (float)(uVar5 - 1);
  if (bVar7 < 2) {
    fVar10 = 0.0;
    fVar11 = 0.0;
  }
  fVar13 = 0.0;
  if (bVar7 < 2) {
    fVar13 = fVar12;
  }
  fVar14 = 0.25;
  if (bVar7 < 2) {
    fVar14 = -(fVar12 * (float)(uVar5 - 1)) - -0.25;
  }
  uVar8 = 0x29;
  if (bVar7 != 3) {
    uVar8 = 1;
  }
  uVar1 = 0x28;
  if (bVar7 != 0) {
    uVar1 = uVar8;
  }
  KeyframeStorage::clear(param_2);
  if (uVar5 != 0) {
    uVar9 = 0;
    do {
      local_80 = fVar11 + (float)uVar9 * fVar10;
      fVar12 = (fVar14 + (float)uVar9 * fVar13) - local_80;
      local_78 = (ulong)*(uint *)(param_2 + 0x308) << 1 | 1;
      local_88 = (uVar4 & 8) << 0x16 | 3;
      uStack_84 = uVar9;
      KeyframeStorage::push_keyframes(param_2,(Keyframes *)&local_88);
      KeyframeStorage::push_value((KeyframeStorage *)0x0,fVar12,param_2,uVar1);
      KeyframeStorage::push_value(param_2,1.0);
      uVar9 = uVar9 + 1;
    } while (uVar5 != uVar9);
  }
  uVar6 = KeyframeStorage::commit(param_2);
  return uVar6;
}
//==== 196b19638 appear_disappear_keyframes
/* RB::Symbol::Animation::appear_disappear_keyframes(bool, RB::Symbol::Animation::KeyframesArgs
   const&, RB::Symbol::KeyframeStorage&) const */
void __thiscall
RB::Symbol::Animation::appear_disappear_keyframes
          (Animation *this,bool param_1,KeyframesArgs *param_2,KeyframeStorage *param_3)
{
  code *pcVar1;
  ulong unaff_x30;
  KeyframeStorage::clear(param_3);
  make_appear_disappear_keyframes
            (param_1,*(uint *)(this + 0xc),param_2,(TimingGroup *)0x0,param_3,0,0);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x196b196a4);
    (*pcVar1)();
  }
  KeyframeStorage::commit(param_3);
  return;
}
//==== 196b196a8 draw_on_off_keyframes
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
/* RB::Symbol::Animation::draw_on_off_keyframes(bool, RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&, RB::Symbol::Animation::Time&, RB::Symbol::Model const&) const */
undefined8 __thiscall
RB::Symbol::Animation::draw_on_off_keyframes
          (Animation *this,bool param_1,KeyframesArgs *param_2,KeyframeStorage *param_3,
          Time *param_4,Model *param_5)
{
  uint uVar1;
  uint uVar2;
  TimingGroup *pTVar3;
  int iVar4;
  Glyph *pGVar5;
  TimingGroup *pTVar6;
  KeyframesArgs *pKVar7;
  uint uVar8;
  long extraout_x8;
  long lVar9;
  undefined8 uVar10;
  ulong uVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  KeyframesArgs *local_90;
  undefined4 local_84;
  float local_80;
  undefined4 local_7c;
  long local_78;
  pTVar3 = (TimingGroup *)&local_90;
  local_78 = *_DAT_1e01cc7f0;
  uVar1 = *(uint *)(this + 0xc);
  local_90 = param_2;
  pGVar5 = (Glyph *)Model::glyph_info(param_5);
  uVar2 = *(uint *)(pGVar5 + 0x1d8);
  uVar11 = (ulong)uVar2;
  if (uVar2 < 0x156) {
    (*_DAT_1e2125200)();
    pTVar3 = (TimingGroup *)((long)&local_90 - (extraout_x8 + 0xfU & 0x1ffffffff0));
    func_0x0001981043d0(pTVar3,extraout_x8);
    pTVar6 = pTVar3;
LAB_196b19778:
    pKVar7 = (KeyframesArgs *)(ulong)*(uint *)(this + 0xc);
    fVar13 = 0.25;
    fVar12 = 0.25;
    if (!param_1) {
      fVar12 = DAT_196bd9e90/*f=0.166667*/;
    }
    uVar8 = 0;
    draw_timing_groups(pTVar6,pGVar5,param_1,*(uint *)(this + 0xc),fVar12,0,0);
    if (((uVar1 ^ 0xffffffff) & 0x80000008) == 0 && uVar2 == 1) {
      uVar1 = uVar1 & 0x7fffffff;
    }
    KeyframeStorage::clear(param_3);
    *(undefined4 *)(pTVar3 + -0x10) = 0;
    iVar4 = make_draw_on_off_keyframes_
                      (param_1,0.0,uVar1,param_5,pKVar7,uVar8,pTVar6,param_3,0,
                       *(uint *)(pTVar3 + -0x10));
    if (iVar4 != 0) {
      make_appear_disappear_keyframes
                (param_1,*(uint *)(this + 0xc) & 0x1fffffff | 0x40000000,local_90,pTVar6,param_3,
                 0x10,0);
    }
    if (((uVar1 ^ 0xffffffff) & 0x80000008) == 0) {
      fVar12 = 0.0;
      if (uVar2 != 0) {
        lVar9 = 0;
        do {
          pTVar3 = pTVar6 + lVar9 * 0xc;
          fVar14 = *(float *)(pTVar3 + 4);
          fVar13 = fVar14;
          if ((!param_1) && (fVar13 = fVar14 + DAT_196bd9ec4/*f=0.0333333*/, pTVar3[10] == (TimingGroup)0x0)) {
            fVar13 = fVar14;
          }
          fVar14 = fVar12;
          if ((0.0 < fVar13) &&
             (fVar14 = *(float *)pTVar3 + fVar13, *(float *)pTVar3 + fVar13 <= fVar12)) {
            fVar14 = fVar12;
          }
          fVar12 = fVar14;
          lVar9 = lVar9 + 1;
          uVar11 = uVar11 - 1;
          fVar13 = DAT_196bd9ec4/*f=0.0333333*/;
        } while (uVar11 != 0);
      }
      local_84 = 0x11;
      if (!param_1) {
        local_84 = 0x12;
      }
      local_80 = 0.0;
      if (0.0 <= fVar12) {
        local_80 = fVar12;
      }
      local_7c = 0;
      fVar14 = (float)Keyframes::Value::interpolant((Value *)&local_84,*(float *)param_4);
      *(float *)param_4 = fVar14 * fVar12;
      *(float *)(param_4 + 8) = *(float *)(param_4 + 8) * fVar13;
    }
    uVar10 = KeyframeStorage::commit(param_3);
    if (uVar2 < 0x156) goto LAB_196b198e0;
  }
  else {
    pTVar6 = (TimingGroup *)func_0x000198107840(uVar11 * 0xc,0x1000040fd6f1ff4);
    if (pTVar6 != (TimingGroup *)0x0) goto LAB_196b19778;
    uVar10 = 0;
  }
  func_0x000198104520(pTVar6);
LAB_196b198e0:
  if (*_DAT_1e01cc7f0 == local_78) {
    return uVar10;
  }
  uVar10 = func_0x000198104300();
  return uVar10;
}
//==== 196b19d20 replace_keyframes
/* RB::Symbol::Animation::replace_keyframes(RB::Symbol::Animation::KeyframesArgs const&,
   RB::Symbol::KeyframeStorage&) const */
void __thiscall
RB::Symbol::Animation::replace_keyframes
          (Animation *this,KeyframesArgs *param_1,KeyframeStorage *param_2)
{
  code *pcVar1;
  ulong unaff_x30;
  KeyframeStorage::clear(param_2);
  make_replace_keyframes(*(uint *)(this + 0xc),param_1,param_2);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x196b19d78);
    (*pcVar1)();
  }
  KeyframeStorage::commit(param_2);
  return;
}
//==== 196b19d7c make_appear_disappear_keyframes
/* RB::Symbol::Animation::make_appear_disappear_keyframes(bool, unsigned int,
   RB::Symbol::Animation::KeyframesArgs const&, RB::Symbol::Animation::TimingGroup const*,
   RB::Symbol::KeyframeStorage&, unsigned int, unsigned int) */
void RB::Symbol::Animation::make_appear_disappear_keyframes
               (bool param_1,uint param_2,KeyframesArgs *param_3,TimingGroup *param_4,
               KeyframeStorage *param_5,uint param_6,uint param_7)
{
  uint uVar1;
  uint uVar2;
  uint uVar3;
  float fVar4;
  undefined4 uVar5;
  ulong uVar6;
  float fVar7;
  KeyframeStorage *pKVar11;
  KeyframeStorage *pKVar12;
  float fVar8;
  KeyframeStorage *pKVar13;
  float fVar9;
  float fVar10;
  uint local_b8;
  undefined4 uStack_b4;
  float local_b0;
  ulong local_a8;
  uVar1 = param_2 & 8;
  uVar2 = *(uint *)(param_3 + 8);
  if (uVar1 == 0) {
    uVar2 = 1;
  }
  fVar10 = 0.25;
  if (!param_1) {
    fVar10 = DAT_196bd9e90/*f=0.166667*/;
  }
  uVar3 = uVar2 - 1;
  if (uVar2 == 0 || uVar3 == 0) {
    fVar7 = (float)uVar3;
    fVar9 = 0.0;
  }
  else {
    fVar8 = DAT_196bd9ebc/*f=0.15*/;
    fVar9 = DAT_196bd9eb8/*f=0.05*/;
    if (!param_1) {
      fVar8 = DAT_196bd9f1c/*f=0.1*/;
      fVar9 = DAT_196bd9ec4/*f=0.0333333*/;
    }
    fVar7 = (float)uVar3;
    if (fVar8 / fVar7 <= fVar9) {
      fVar9 = fVar8 / fVar7;
    }
  }
  fVar8 = fVar9;
  fVar4 = 0.0;
  if (param_1 == (int)param_2 < -0x40000000) {
    fVar8 = -fVar9;
    fVar4 = fVar9 * fVar7;
  }
  if (uVar2 != 0) {
    uVar6 = 0;
    pKVar11._0_4_ = (float)1.25;
    if (-0x40000001 < (int)param_2) {
      pKVar11._0_4_ = (float)1;
    }
    pKVar13._0_4_ = (float)0.75;
    if ((param_2 & 0xc0000000) != 0x40000000) {
      pKVar13._0_4_ = pKVar11._0_4_;
    }
    pKVar11._0_4_ = pKVar13._0_4_;
    if (!param_1) {
      pKVar11._0_4_ = (float)1;
    }
    uVar5 = 0xf;
    if (!param_1) {
      uVar5 = 0x10;
    }
    pKVar12._0_4_ = (float)1;
    if (!param_1) {
      pKVar12._0_4_ = pKVar13._0_4_;
    }
    uVar3 = (param_6 & 0x3ff) << 5 | uVar1 << 0x16 | (param_7 & 0x3ff) << 0xf;
    do {
      fVar7 = fVar4 + (float)(uVar6 & 0xffffffff) * fVar8;
      fVar9 = fVar7;
      if (uVar1 != 0 && param_4 != (TimingGroup *)0x0) {
        fVar9 = *(float *)(param_4 + uVar6 * 0xc);
      }
      fVar7 = fVar10 - fVar7;
      local_a8 = (ulong)*(uint *)(param_5 + 0x308) << 1 | 1;
      local_b8 = uVar3 | 0xd;
      uStack_b4 = (int)uVar6;
      local_b0 = fVar9;
      KeyframeStorage::push_keyframes(param_5,(Keyframes *)&local_b8);
      KeyframeStorage::push_value((KeyframeStorage *)(float)!param_1,fVar7,param_5,0xe);
      KeyframeStorage::push_value(param_5,(float)param_1);
      if ((float)pKVar13._0_4_ != 1.0) {
        local_a8 = (ulong)*(uint *)(param_5 + 0x308) << 1 | 1;
        local_b8 = uVar3 | 2;
        uStack_b4 = (int)uVar6;
        local_b0 = fVar9;
        KeyframeStorage::push_keyframes(param_5,(Keyframes *)&local_b8);
        KeyframeStorage::push_value(pKVar11._0_4_,fVar7,param_5,uVar5);
        KeyframeStorage::push_value(param_5,(float)pKVar12._0_4_);
      }
      uVar6 = uVar6 + 1;
    } while (uVar2 != uVar6);
  }
  return;
}
//==== 196b19fb0 make_draw_on_off_keyframes_
/* RB::Symbol::Animation::make_draw_on_off_keyframes_(bool, float, unsigned int, RB::Symbol::Model
   const&, RB::Symbol::Animation::KeyframesArgs const&, unsigned int,
   RB::Symbol::Animation::TimingGroup const*, RB::Symbol::KeyframeStorage&, unsigned int, unsigned
   int) */
undefined4
RB::Symbol::Animation::make_draw_on_off_keyframes_
          (bool param_1,float param_2,uint param_3,Model *param_4,KeyframesArgs *param_5,
          uint param_6,TimingGroup *param_7,KeyframeStorage *param_8,uint param_9,uint param_10)
{
  Layer *pLVar1;
  undefined4 uVar2;
  Glyph *pGVar3;
  uint uVar4;
  uint uVar5;
  KeyframeStorage *pKVar14;
  float fVar6;
  Glyph *this;
  undefined4 uVar7;
  long lVar8;
  long lVar9;
  int iVar10;
  float fVar11;
  undefined8 uVar12;
  KeyframeStorage *pKVar15;
  float fVar13;
  undefined4 local_bc;
  undefined4 local_b8;
  int iStack_b4;
  float local_b0;
  ulong local_a8;
  this = (Glyph *)Model::glyph_info(param_4);
  fVar6 = DAT_196bd9ec4/*f=0.0333333*/;
  uVar7 = 0x11;
  if (param_1 == 0) {
    uVar7 = 0x12;
  }
  uVar2 = 0;
  if (((param_3 ^ 0xffffffff) & 0x80000008) != 0) {
    uVar2 = uVar7;
  }
  uVar4 = *(uint *)(this + 0x1c8);
  if (uVar4 == 0) {
    local_bc = 0;
  }
  else {
    lVar9 = 0;
    iVar10 = 0;
    lVar8 = 0;
    local_bc = 0;
    uVar5 = (uint)param_1 | (param_3 & 0x40000000) >> 0x1e;
    pKVar15._0_4_ = (KeyframeStorage *)(float)(uVar5 ^ 1);
    uVar7 = 0x400000f;
    pKVar14._0_4_ = pKVar15._0_4_;
    if (!param_1) {
      pKVar14._0_4_ = (KeyframeStorage *)(float)uVar5;
    }
    fVar11 = DAT_196bd72a8/*f=0.0001*/;
    if (uVar5 == 0) {
      uVar7 = 0x400000e;
      fVar11 = DAT_196bd8f4c/*f=-0.0001*/;
    }
    do {
      pGVar3 = this + 0x70;
      if (*(Glyph **)(this + 0x1c0) != (Glyph *)0x0) {
        pGVar3 = *(Glyph **)(this + 0x1c0);
      }
      pLVar1 = (Layer *)(pGVar3 + lVar8 * 0x70);
      if ((param_9 & 0x3ff & *(uint *)(pLVar1 + 0x68)) == param_10) {
        if ((*(uint *)(pLVar1 + 0x68) >> 4 & 1) == 0) {
          local_bc = 1;
        }
        else {
          fVar13 = *(float *)(param_7 + (ulong)*(uint *)(pLVar1 + 0x48) * 0xc) + param_2;
          uVar12 = Glyph::layer_draw_duration(this,pLVar1);
          local_a8 = (ulong)*(uint *)(param_8 + 0x308) << 1 | 1;
          local_b8 = uVar7;
          iStack_b4 = iVar10;
          local_b0 = fVar13;
          KeyframeStorage::push_keyframes(param_8,(Keyframes *)&local_b8);
          KeyframeStorage::push_value(pKVar14._0_4_,uVar12,param_8,uVar2);
          if (param_1) {
            KeyframeStorage::push_value(param_8,(float)uVar5);
            if ((param_3 >> 0x1d & 1) != 0) {
LAB_196b1a278:
              local_b8 = 0x400000d;
              local_a8 = (ulong)*(uint *)(param_8 + 0x308) << 1 | 1;
              iStack_b4 = iVar10;
              local_b0 = fVar13;
              KeyframeStorage::push_keyframes(param_8,(Keyframes *)&local_b8);
              KeyframeStorage::push_value((KeyframeStorage *)(float)!param_1,0,param_8,0);
              KeyframeStorage::push_value(param_8,(float)param_1);
            }
          }
          else {
            if (((byte)pLVar1[0x6c] >> 1 & 1) != 0) {
              KeyframeStorage::push_value
                        ((KeyframeStorage *)(fVar11 + (float)pKVar15._0_4_),fVar6,param_8,0);
              KeyframeStorage::push_value
                        ((KeyframeStorage *)(fVar11 + (float)pKVar15._0_4_),0,param_8,0);
            }
            KeyframeStorage::push_value(param_8,(float)pKVar15._0_4_);
            if (((byte)pLVar1[0x6c] >> 1 & 1) != 0) {
              local_b8 = 0x4000010;
              local_b0 = fVar13 + (float)uVar12;
              local_a8 = (ulong)*(uint *)(param_8 + 0x308) << 1 | 1;
              iStack_b4 = iVar10;
              KeyframeStorage::push_keyframes(param_8,(Keyframes *)&local_b8);
              KeyframeStorage::push_value((KeyframeStorage *)(float)1,fVar6,param_8,0);
              KeyframeStorage::push_value((float)0.5,0,param_8,0);
              KeyframeStorage::push_value(param_8,0.0);
            }
            if ((param_3 >> 0x1d & 1) != 0) {
              fVar13 = fVar13 + (float)uVar12;
              if (((byte)pLVar1[0x6c] & 2) != 0) {
                fVar13 = fVar13 + fVar6;
              }
              goto LAB_196b1a278;
            }
          }
        }
      }
      lVar8 = lVar8 + 1;
      iVar10 = iVar10 + 1;
      lVar9 = lVar9 + 0x70;
    } while ((ulong)uVar4 * 0x70 != lVar9);
  }
  return local_bc;
}
//==== 196b1a66c make_replace_from_keyframes
//==== 196b1a960 make_replace_to_keyframes
//==== 196b1ad28 make_replace_keyframes
/* RB::Symbol::Animation::make_replace_keyframes(unsigned int, RB::Symbol::Animation::KeyframesArgs
   const&, RB::Symbol::KeyframeStorage&) */
void RB::Symbol::Animation::make_replace_keyframes
               (uint param_1,KeyframesArgs *param_2,KeyframeStorage *param_3)
{
  code *pcVar1;
  uint uVar2;
  ulong unaff_x30;
  float fVar3;
  uVar2 = *(uint *)(param_2 + 4);
  if ((uVar2 >> 8 & 1) != 0) {
    make_replace_from_keyframes(param_1,param_2,param_3,0,0);
    uVar2 = *(uint *)(param_2 + 4);
  }
  if ((uVar2 >> 9 & 1) == 0) {
    return;
  }
  if ((param_1 & 0xc0000000) == 0) {
    fVar3 = 0.25;
  }
  else {
    fVar3 = 0.0;
    if ((param_1 >> 0x1e < 3) && (fVar3 = 0.25, (param_1 & 0xc0000000) != 0x40000000)) {
      fVar3 = DAT_196bd9f24/*f=0.166667*/;
    }
  }
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) == 0) {
    make_replace_to_keyframes(fVar3,param_1,param_2,param_3,0,0);
    return;
  }
                    /* WARNING: Does not return */
  pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x196b1ade8);
  (*pcVar1)();
}
//==== 196b1adec eval_appear_disappear
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
/* RB::Symbol::Animation::eval_appear_disappear(float, bool, unsigned int, RB::AnimationLayer
   const&) */
undefined1  [16]
RB::Symbol::Animation::eval_appear_disappear
          (float param_1,bool param_2,uint param_3,AnimationLayer *param_4)
{
  uint uVar1;
  Keyframes *this;
  int iVar2;
  float fVar3;
  ulong uVar4;
  undefined1 auVar5 [16];
  ulong uVar6;
  undefined8 uVar7;
  undefined8 local_9b0;
  undefined4 local_9a8;
  undefined7 local_9a4;
  undefined1 uStack_99d;
  undefined7 uStack_99c;
  undefined4 local_994;
  undefined4 uStack_990;
  undefined8 local_988;
  KeyframeStorage aKStack_980 [768];
  long local_680;
  undefined8 local_678;
  long local_70;
  undefined8 local_68;
  undefined1 local_60;
  long local_58;
  local_58 = *_DAT_1e01cc7f0;
  local_9b0 = 0xff;
  local_9a8 = *(undefined4 *)(param_4 + 4);
  local_994 = 0;
  uStack_990 = 0;
  local_988 = 0;
  local_9a4 = 0;
  uStack_99d = 0;
  uStack_99c = 0;
  local_680 = 0;
  local_678 = DAT_196bd8fd0/*f=0*/;
  local_70 = 0;
  local_68 = DAT_196bd8fd0/*f=0*/;
  local_60 = 0;
  make_appear_disappear_keyframes
            (param_2,param_3,(KeyframesArgs *)&local_9b0,(TimingGroup *)0x0,aKStack_980,0,0);
  this = (Keyframes *)KeyframeStorage::commit(aKStack_980);
  fVar3 = DAT_196bd72a8/*f=0.0001*/;
  if (DAT_196bd72a8/*f=0.0001*/ <= param_1) {
    fVar3 = param_1;
  }
  uVar1 = *(uint *)this;
  if ((uVar1 & 0x1f) == 0) {
    uVar4 = 0x3f800000;
  }
  else {
    uVar6 = 0x3f800000;
    do {
      uVar4 = uVar6;
      if (*(long *)(this + 0x10) != 0 && (uVar1 >> 5 & uVar1 >> 0xf & 0x3ff) == 0) {
        uVar1 = uVar1 >> 0x19 & 3;
        if (uVar1 - 1 < 2) {
          iVar2 = *(int *)param_4;
LAB_196b1aef4:
          if (*(int *)(this + 4) != iVar2) goto LAB_196b1aec4;
        }
        else if (uVar1 != 0) {
          iVar2 = -1;
          goto LAB_196b1aef4;
        }
        uVar4 = Keyframes::eval(this,fVar3,aKStack_980);
        uVar4 = uVar4 & 0xffffffff;
        if ((*(uint *)this & 0x1f) != 2) {
          uVar4 = uVar6;
        }
      }
LAB_196b1aec4:
      this = this + 0x18;
      uVar1 = *(uint *)this;
      uVar6 = uVar4;
    } while ((uVar1 & 0x1f) != 0);
  }
  uVar7 = 0;
  if (local_70 != 0) {
    func_0x000198104520();
  }
  if (local_680 != 0) {
    func_0x000198104520();
  }
  if (*_DAT_1e01cc7f0 == local_58) {
    auVar5._8_8_ = uVar7;
    auVar5._0_8_ = uVar4;
    return auVar5;
  }
  auVar5 = func_0x000198104300();
  return auVar5;
}
//==== 196b1afac eval_replace
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */
/* RB::Symbol::Animation::eval_replace(float, bool, unsigned int, RB::AnimationLayer const&) */
undefined1  [16]
RB::Symbol::Animation::eval_replace(float param_1,bool param_2,uint param_3,AnimationLayer *param_4)
{
  Keyframes *this;
  undefined8 uVar1;
  uint uVar2;
  int iVar3;
  uint uVar4;
  float fVar5;
  ulong uVar6;
  undefined1 auVar7 [16];
  ulong uVar8;
  undefined4 local_9b0;
  uint uStack_9ac;
  undefined4 local_9a8;
  undefined4 uStack_9a4;
  undefined4 local_9a0;
  undefined4 uStack_99c;
  undefined3 uStack_998;
  undefined4 local_994;
  undefined4 uStack_990;
  undefined8 local_988;
  KeyframeStorage aKStack_980 [768];
  long local_680;
  undefined8 local_678;
  long local_70;
  undefined8 local_68;
  undefined1 local_60;
  long local_58;
  local_58 = *_DAT_1e01cc7f0;
  uVar4 = 0x200;
  if (!param_2) {
    uVar4 = 0x100;
  }
  local_9b0 = 0xff;
  uStack_9a4 = *(undefined4 *)(param_4 + 4);
  local_9a8 = 1;
  local_994 = 0;
  uStack_990 = 0;
  local_988 = 0;
  uStack_99c = 0;
  uStack_998 = 0;
  local_680 = 0;
  local_678 = DAT_196bd8fd0/*f=0*/;
  local_70 = 0;
  local_68 = DAT_196bd8fd0/*f=0*/;
  local_60 = 0;
  uStack_9ac = uVar4;
  local_9a0 = uStack_9a4;
  make_replace_keyframes(param_3,(KeyframesArgs *)&local_9b0,aKStack_980);
  this = (Keyframes *)KeyframeStorage::commit(aKStack_980);
  fVar5 = DAT_196bd72a8/*f=0.0001*/;
  if (DAT_196bd72a8/*f=0.0001*/ <= param_1) {
    fVar5 = param_1;
  }
  uVar2 = *(uint *)this;
  if ((uVar2 & 0x1f) == 0) {
    uVar6 = 0x3f800000;
  }
  else {
    uVar8 = 0x3f800000;
    do {
      uVar6 = uVar8;
      if (*(long *)(this + 0x10) != 0 && ((uVar4 ^ uVar2 >> 0xf) & uVar2 >> 5 & 0x3ff) == 0) {
        uVar2 = uVar2 >> 0x19 & 3;
        if (uVar2 - 1 < 2) {
          iVar3 = *(int *)param_4;
LAB_196b1b0c4:
          if (*(int *)(this + 4) != iVar3) goto LAB_196b1b094;
        }
        else if (uVar2 != 0) {
          iVar3 = -1;
          goto LAB_196b1b0c4;
        }
        uVar6 = Keyframes::eval(this,fVar5,aKStack_980);
        uVar6 = uVar6 & 0xffffffff;
        if ((*(uint *)this & 0x1f) != 2) {
          uVar6 = uVar8;
        }
      }
LAB_196b1b094:
      this = this + 0x18;
      uVar2 = *(uint *)this;
      uVar8 = uVar6;
    } while ((uVar2 & 0x1f) != 0);
  }
  uVar1 = 0;
  if (local_70 != 0) {
    func_0x000198104520();
  }
  if (local_680 != 0) {
    func_0x000198104520();
  }
  if (*_DAT_1e01cc7f0 == local_58) {
    auVar7._8_8_ = uVar1;
    auVar7._0_8_ = uVar6;
    return auVar7;
  }
  uVar1 = func_0x000198104300();
  KeyframeStorage::~KeyframeStorage(aKStack_980);
  auVar7 = func_0x000198104280(uVar1);
  return auVar7;
}
