// Dock (27.2.1, 26B131) /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock arm64e slice. Ghidra 12.1.4 pseudocode.
// Tile ivars: 0x68 bitfield (bit0 _bouncing, bit1 _bounceEnding, bit2 _bounceStop, bit3 _notifyBounce, bit5 _needUpdate),
// 0xe0 float _bounceNow, 0xe4 float _bouncePeriod, 0x108 double _bounceST, 0x110 double _bounceDur. mainMillis = ms clock.
// Launch (handleDockEventAppLaunch 0x10008e134): _bouncePeriod = 350.0 (0x43af0000), _bounceDur = 120000.0, notifyBounce = 0.
// Attention (handleDockEventAppNeedsAttention 0x10009140c): period 2000.0 (0x44fa0000), dur = duration*1000, notifyBounce = 1.
// AddBounce (0x100091590): period 2000.0, dur 350.0, notifyBounce = 1.
// Height (-[Tile updateRect] 0x100012088, bottom dock): launch: offset = bounceNow * ((rectH - 8) * 0.2 + 6) * (1 - autoHide.now)
//                     attention: offset = bounceNow * ((rectH + 1) * (1 - autoHide.now) + dock.autoHideOffset)
// DockGlobals defaults (0x1001a66d4..): bounce-duration 60, bounce-secondary-duration 3, bounce-secondary-interval 60 (seconds).

//==== 10002d9f4 updateBouncing (asked 0x10002d9f4)
/* Function Stack Size: 0x10 bytes */
void Tile::updateBouncing(ID param_1,SEL param_2)
{
  int iVar1;
  bool bVar2;
  ID IVar3;
  byte bVar4;
  int iVar5;
  int iVar6;
  float fVar7;
  float fVar8;
  double extraout_d0;
  double extraout_d0_00;
  double extraout_d0_01;
  double extraout_d0_02;
  double extraout_d0_03;
  double dVar9;
  float fVar10;
  float fVar11;
  undefined *local_b0;
  undefined8 local_a8;
  code *local_a0;
  undefined *puStack_98;
  ID local_90;
  undefined *local_88;
  undefined8 local_80;
  code *local_78;
  undefined *puStack_70;
  ID local_68;
  bVar4 = *(byte *)(param_1 + 0x68);
  if ((bVar4 & 1) == 0) {
    return;
  }
  if ((bVar4 >> 3 & 1) == 0) {
    if (*(double *)(param_1 + 0x110) == 0.0) {
      *(undefined4 *)(param_1 + 0xe0) = 0;
      *(byte *)(param_1 + 0x68) = bVar4 & 0xf6;
      goto LAB_10002ddb4;
    }
    if ((bVar4 >> 2 & 1) != 0) {
      fVar7 = *(float *)(param_1 + 0xe4);
      objc_stub::mainMillis(DAT_100329c20);
      dVar9 = (double)(fVar7 + fVar7);
      *(double *)(param_1 + 0x110) =
           ((double)(long)((extraout_d0_00 - *(double *)(param_1 + 0x108)) / dVar9) + 1.0) * dVar9;
      *(byte *)(param_1 + 0x68) = *(byte *)(param_1 + 0x68) & 0xfb | 2;
    }
    objc_stub::mainMillis(DAT_100329c20);
    bVar4 = *(byte *)(param_1 + 0x68);
    if (*(double *)(param_1 + 0x110) <= extraout_d0_01 - *(double *)(param_1 + 0x108)) {
      if ((bVar4 >> 1 & 1) != 0) {
        *(byte *)(param_1 + 0x68) = bVar4 & 0xfe;
        *(undefined4 *)(param_1 + 0xe0) = 0;
        goto LAB_10002ddb4;
      }
      *(byte *)(param_1 + 0x68) = bVar4 | 4;
    }
    if ((bVar4 & 1) == 0) goto LAB_10002ddb4;
    objc_stub::mainMillis(DAT_100329c20);
    fVar11 = *(float *)(param_1 + 0xe4);
    dVar9 = (extraout_d0_02 - *(double *)(param_1 + 0x108)) + (double)fVar11;
    _fmod(dVar9,(double)(fVar11 + fVar11));
    fVar8 = (float)dVar9;
    fVar7 = fVar11 * 2.0 - fVar8;
    if (fVar8 <= fVar11) {
      fVar7 = fVar8;
    }
    *(float *)(param_1 + 0xe0) = 1.0 - (fVar7 * fVar7) / (fVar11 * fVar11);
    bVar4 = *(byte *)(param_1 + 0x68);
    *(byte *)(param_1 + 0x68) = bVar4 | 0x20;
  }
  else {
    local_88 = PTR___NSConcreteStackBlock_1002ee408;
    local_80 = DAT_100258058;
    local_78 = FUN_10002de64;
    puStack_70 = &DAT_1002cc1c0;
    local_68 = param_1;
    CATransaction::begin((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,&local_88);
    CATransaction::setDisableActions_((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,1);
    IVar3 = objc_stub::dockConnection(DAT_100329c20);
    _SLSTransactionCreate();
    (*local_78)(&local_88,IVar3);
    _SLSTransactionCommitUsingMethod(IVar3,4);
    _CFRelease(IVar3);
    CATransaction::commit((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0);
    objc_stub::mainMillis(DAT_100329c20);
    if (*(double *)(param_1 + 0x110) <= extraout_d0 - *(double *)(param_1 + 0x108)) {
      *(byte *)(param_1 + 0x68) = *(byte *)(param_1 + 0x68) | 4;
    }
    if (*(double *)(param_1 + 0x110) == 0.0) {
      *(undefined4 *)(param_1 + 0xe0) = 0;
      *(byte *)(param_1 + 0x68) = *(byte *)(param_1 + 0x68) & 0xfe;
      IVar3 = dock(param_1);
      objc_stub::decrementNotificationCount(IVar3);
    }
    else {
      bVar4 = *(byte *)(param_1 + 0x68);
      if ((bVar4 >> 2 & 1) != 0) {
        *(byte *)(param_1 + 0x68) = bVar4 & 0xfb | 2;
      }
      if ((bVar4 & 1) != 0) {
        objc_stub::mainMillis(DAT_100329c20);
        dVar9 = extraout_d0_03 - *(double *)(param_1 + 0x108);
        _fmod(dVar9,(double)(int)(*(float *)(param_1 + 0xe4) + 0.5));
        fVar8 = (float)dVar9;
        fVar7 = 500.0;
        if (fVar8 <= 500.0) {
          fVar11 = 1.0;
LAB_10002dd3c:
          fVar10 = fVar7 * 0.5;
          iVar5 = (int)(fVar8 + fVar10 + 0.5);
          iVar6 = (int)(fVar7 + 0.5);
          iVar1 = 0;
          if (iVar6 != 0) {
            iVar1 = iVar5 / iVar6;
          }
          fVar8 = (float)(iVar5 - iVar1 * iVar6);
          fVar7 = (float)iVar6 - fVar8;
          if (fVar8 <= fVar10) {
            fVar7 = fVar8;
          }
          *(float *)(param_1 + 0xe0) = (1.0 - (fVar7 * fVar7) / (fVar10 * fVar10)) * fVar11;
          bVar4 = *(byte *)(param_1 + 0x68);
        }
        else {
          fVar8 = fVar8 + -500.0;
          fVar7 = 326.0;
          if (fVar8 <= 326.0) {
            bVar2 = false;
            fVar11 = 0.5;
          }
          else {
            fVar8 = fVar8 + -326.0;
            fVar7 = 212.0;
            if (fVar8 <= 212.0) {
              bVar2 = false;
              fVar11 = 0.25;
            }
            else {
              fVar8 = fVar8 + -212.0;
              fVar11 = 0.125;
              bVar2 = true;
              fVar7 = 138.0;
            }
          }
          if (!bVar2) goto LAB_10002dd3c;
          *(undefined4 *)(param_1 + 0xe0) = 0;
          bVar4 = *(byte *)(param_1 + 0x68);
          if ((bVar4 >> 1 & 1) != 0) {
            IVar3 = dock(param_1);
            objc_stub::decrementNotificationCount(IVar3);
            bVar4 = *(byte *)(param_1 + 0x68) & 0xfe;
          }
        }
        *(byte *)(param_1 + 0x68) = bVar4 | 0x20;
      }
    }
    bVar4 = *(byte *)(param_1 + 0x68);
  }
  if ((bVar4 & 1) != 0) {
    return;
  }
LAB_10002ddb4:
  local_b0 = PTR___NSConcreteStackBlock_1002ee408;
  local_a8 = DAT_100258058;
  local_a0 = FUN_10002dec0;
  puStack_98 = &DAT_1002cc1c0;
  local_90 = param_1;
  CATransaction::begin((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,&local_b0);
  CATransaction::setDisableActions_((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,1);
  IVar3 = objc_stub::dockConnection(DAT_100329c20);
  _SLSTransactionCreate();
  (*local_a0)(&local_b0,IVar3);
  _SLSTransactionCommitUsingMethod(IVar3,4);
  _CFRelease(IVar3);
  CATransaction::commit((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0);
  return;
}

//==== 100012088 updateRect (asked 0x100012088)
/* Function Stack Size: 0x10 bytes */
void Tile::updateRect(ID param_1,SEL param_2)
{
  code *pcVar1;
  int iVar2;
  ID IVar3;
  undefined8 uVar4;
  ulong unaff_x30;
  float extraout_s0;
  float extraout_s0_00;
  float fVar5;
  float extraout_s0_01;
  float fVar6;
  float extraout_s0_02;
  double in_d0;
  double extraout_d0;
  ulong in_d1;
  ulong in_d2;
  ulong in_d3;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  FloatRect FVar13;
  iVar2 = (int)*(undefined8 *)(param_1 + 0x20);
  FUN_10022f088();
  uVar4 = *(undefined8 *)(param_1 + 0x20);
  if (iVar2 == 0) {
    FUN_10022f1d4(uVar4);
    FUN_10022f1c4(*(undefined8 *)(param_1 + 0x20));
  }
  else {
    objc_stub::mainMillis(DAT_100329c20);
    in_d0 = extraout_d0;
    FUN_10004e9c4();
    FUN_10022f1f8(*(undefined8 *)(param_1 + 0x20));
    if ((in_d0 == 0.0) ||
       (*(byte *)(param_1 + 0x68) = *(byte *)(param_1 + 0x68) | 0x20, (int)uVar4 != 0)) {
      FUN_10022efac(*(undefined8 *)(param_1 + 0x20));
    }
  }
  FUN_10022f1b0(*(undefined8 *)(param_1 + 0x20));
  if ((*(byte *)(param_1 + 0x68) & 1) != 0) {
    if ((*(byte *)(param_1 + 0x68) >> 3 & 1) == 0) {
      fVar12 = 6.0;
      fVar9 = 8.0;
      fVar7 = 0.0;
      fVar8 = DAT_1002580c0;
    }
    else {
      IVar3 = dock(param_1);
      objc_stub::autoHideOffset(IVar3);
      fVar9 = 0.0;
      fVar8 = 1.0;
      fVar12 = 1.0;
      fVar7 = extraout_s0;
    }
    IVar3 = dock(param_1);
    IVar3 = objc_stub::barOrientation(IVar3);
    fVar5 = (float)in_d2;
    fVar10 = SUB84(in_d0,0);
    if (IVar3 == 2) {
      fVar11 = *(float *)(param_1 + 0xe0);
      IVar3 = dock(param_1);
      IVar3 = objc_stub::autoHide(IVar3);
      fVar6 = extraout_s0_02;
      FUN_10022f0ac(IVar3);
      fVar11 = fVar11 * (fVar7 + (1.0 - fVar6) * (fVar12 + fVar8 * ((fVar5 - fVar10) - fVar9)));
      in_d0 = (double)(ulong)(uint)(fVar10 - fVar11);
      in_d2 = (ulong)(uint)(fVar5 - fVar11);
    }
    else if (IVar3 == 1) {
      fVar11 = *(float *)(param_1 + 0xe0);
      IVar3 = dock(param_1);
      IVar3 = objc_stub::autoHide(IVar3);
      fVar6 = extraout_s0_01;
      FUN_10022f0ac(IVar3);
      fVar11 = fVar11 * (fVar7 + (1.0 - fVar6) * (fVar12 + fVar8 * ((fVar5 - fVar10) - fVar9)));
      in_d0 = (double)(ulong)(uint)(fVar10 + fVar11);
      in_d2 = (ulong)(uint)(fVar5 + fVar11);
    }
    else if (IVar3 == 0) {
      fVar10 = *(float *)(param_1 + 0xe0);
      IVar3 = dock(param_1);
      IVar3 = objc_stub::autoHide(IVar3);
      fVar5 = extraout_s0_00;
      FUN_10022f0ac(IVar3);
      fVar8 = -(fVar10 * (fVar7 + (1.0 - fVar5) *
                                  (fVar12 + fVar8 * (((float)in_d3 - (float)in_d1) - fVar9))));
      in_d1 = (ulong)(uint)((float)in_d1 + fVar8);
      in_d3 = (ulong)(uint)((float)in_d3 + fVar8);
    }
  }
  FVar13.field0_0x0 = SUB84(in_d0,0);
  FVar13.field1_0x4 = (undefined4)in_d1;
  FVar13.field2_0x8 = (undefined4)in_d2;
  FVar13.field3_0xc = (undefined4)in_d3;
  setGlobalFrame_(param_1,FVar13);
                    /* WARNING: Does not return */
  }
  FUN_10022f1c4(in_d0,in_d1,in_d2,in_d3,*(undefined8 *)(param_1 + 0x20));
  return;
}

