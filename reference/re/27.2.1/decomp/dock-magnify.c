// Dock 27.2.1 magnification (fish-eye). FUN_1000118d4 computes fishSize/realScale/currentFish; DockBar fSize = 3.0 (0x1001b5690),
// fishSpeed = 42.0 (0x1001b5684), moveSpeed 270.0, dropSpeed 350.0. K = pi (float 0x1002581d8).
// Per-tile edge mapping (asm 0x100011b68..0x100011ec0, reconstructed):
//   F = fishSize = 3*T;  Rs = realScale = ((L - T)/2) / sin(pi*T/(4F)) * fish.now
//   map(x) = x - Rs if x-c <= -F;  x + Rs if x-c >= F;  else x + Rs*sin(pi*(x-c)/(2F))     (c = fishCenter = pointer x)
//   tile size = map(right) - map(left), left/right = unmagnified tile edges
// Fish (enter/leave) duration, FUN_10005bf08: dur_ms = floor(42 * ln(|target - (T + currentFish)| / 2 + 1) + 1),
//   DockFloatAnimatedProperty created with _easingFunction = 1 -> p = 0.5 - 0.5*cos(pi*t) (0x10022eff4).

//==== 1000118d4 FUN_1000118d4 (asked 0x100011928)
undefined8 FUN_1000118d4(undefined8 param_1,double param_2,ID param_3)
{
  code *pcVar1;
  ID IVar2;
  ID IVar3;
  ulong unaff_x30;
  float extraout_s0;
  float extraout_s0_00;
  float extraout_s0_01;
  float extraout_s0_02;
  float extraout_s0_03;
  float extraout_s0_04;
  float extraout_s0_05;
  float extraout_s0_06;
  float extraout_s0_07;
  float extraout_s0_08;
  float extraout_s0_09;
  float extraout_s0_10;
  float extraout_s0_11;
  float extraout_s0_12;
  float fVar4;
  float extraout_s0_13;
  float extraout_s0_14;
  float extraout_s0_15;
  double extraout_d0;
  double extraout_d0_00;
  double dVar5;
  float fVar6;
  float fVar7;
  IVar2 = objc_stub::externalFishTile(param_3);
  IVar3 = objc_stub::barOrientation(param_3);
  if (IVar3 - 1 < 2) {
    objc_stub::lastCapturedMousePosition(param_3);
    if (IVar2 == 0) {
LAB_1000119dc:
      fVar7 = (float)param_2;
      objc_stub::barLeft(param_3);
      objc_stub::barRight(param_3);
      fVar4 = extraout_s0_03;
      if (fVar7 <= extraout_s0_03) {
        fVar4 = fVar7;
      }
      fVar6 = extraout_s0_02;
      if (extraout_s0_02 <= fVar7) {
        fVar6 = fVar4;
      }
      objc_stub::setFishCenter_(param_3,(ulong)(uint)fVar6);
    }
    else {
      objc_stub::fishCenter(param_3);
      dVar5 = extraout_d0;
LAB_100011950:
      objc_stub::setLastCapturedMousePosition_(param_3,dVar5);
      fVar4 = extraout_s0_00;
      FUN_10022d0d8(IVar2);
      objc_stub::tileSize(param_3);
      fVar7 = extraout_s0_01;
      FUN_10022d0b4(IVar2);
      FUN_10022f0ac();
      fVar6 = extraout_s0_01 * fVar7;
      FUN_10022d0a8(IVar2);
      FUN_10022f0ac();
      objc_stub::setFishCenter_(param_3,(ulong)(uint)(fVar4 + fVar6 * fVar7 * 0.5));
    }
  }
  else if (IVar3 == 0) {
    if (IVar2 == 0) {
      objc_stub::lastCapturedMousePosition(param_3);
      param_2 = extraout_d0_00;
      goto LAB_1000119dc;
    }
    objc_stub::fishCenter(param_3);
    dVar5 = (double)extraout_s0;
    objc_stub::lastCapturedMousePosition(param_3);
    goto LAB_100011950;
  }
  IVar2 = objc_stub::magnification(param_3);
  if ((int)IVar2 != 0) {
    objc_stub::largeSize(param_3);
    objc_stub::tileSize(param_3);
    if (extraout_s0_05 < extraout_s0_04) {
      objc_stub::fSize(param_3);
      objc_stub::tileSize(param_3);
      objc_stub::setFishSize_(param_3,(ulong)(uint)(extraout_s0_06 * extraout_s0_07));
      objc_stub::largeSize(param_3);
      objc_stub::tileSize(param_3);
      objc_stub::tileSize(param_3);
      dVar5 = (double)extraout_s0_10 * 0.5 * DAT_1002581c0;
      objc_stub::fishSize(param_3);
      dVar5 = dVar5 / ((double)extraout_s0_11 + (double)extraout_s0_11);
      _sin(dVar5);
      IVar2 = objc_stub::fish(param_3);
      fVar4 = extraout_s0_12;
      FUN_10022f0ac(IVar2);
      objc_stub::setRealScale_
                (param_3,(ulong)(uint)(float)((((double)(extraout_s0_08 - extraout_s0_09) * 0.5) /
                                              dVar5) * (double)fVar4));
      objc_stub::largeSize(param_3);
      objc_stub::tileSize(param_3);
      IVar2 = objc_stub::fish(param_3);
      fVar4 = extraout_s0_15;
      FUN_10022f0ac(IVar2);
      objc_stub::setCurrentFish_(param_3,(ulong)(uint)((extraout_s0_13 - extraout_s0_14) * fVar4));
      goto LAB_100011b38;
    }
  }
  objc_stub::setRealScale_(param_3,0);
  objc_stub::setCurrentFish_(param_3,0);
LAB_100011b38:
                    /* WARNING: Does not return */
  }
  return 0;
}

//==== 10005bf08 FUN_10005bf08 (asked 0x10005bf88)
undefined8 FUN_10005bf08(float param_1,undefined8 param_2,ID param_3)
{
  code *pcVar1;
  ID IVar2;
  ulong unaff_x30;
  float extraout_s0;
  float extraout_s0_00;
  float extraout_s0_01;
  float extraout_s0_02;
  undefined8 extraout_d0;
  double dVar3;
  objc_stub::tileSize(param_3);
  objc_stub::currentFish(param_3);
  IVar2 = objc_stub::fDragging(param_3);
  if ((int)IVar2 == 0) {
    dVar3 = (double)ABS(param_1 - (extraout_s0 + extraout_s0_00)) * 0.5 + 1.0;
    _log(dVar3);
    objc_stub::fishSpeed(param_3);
    dVar3 = (double)(long)(dVar3 * (double)extraout_s0_02 + 1.0);
  }
  else {
    objc_stub::moveSpeed(param_3);
    dVar3 = (double)extraout_s0_01;
  }
  IVar2 = objc_stub::fish(param_3);
  objc_stub::mainMillis(DAT_100329c20);
  FUN_10022efd4(param_2,extraout_d0,dVar3,IVar2);
                    /* WARNING: Does not return */
  }
  return 0;
}

//==== 10004e88c FUN_10004e88c (asked 0x10004e88c)
undefined8 FUN_10004e88c(double param_1,ID param_2)
{
  undefined8 uVar1;
  undefined4 uVar2;
  undefined4 extraout_s0;
  double dVar3;
  double dVar4;
  double dVar5;
  if (param_2 == 0) {
    return 0;
  }
  if ((*(byte *)(param_2 + 8) & 1) == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_10022f208();
  }
  dVar4 = *(double *)(param_2 + 0x28);
  if (dVar4 != 0.0) {
    param_1 = param_1 - *(double *)(param_2 + 0x20);
    dVar5 = dVar4;
    if (param_1 <= dVar4) {
      dVar5 = param_1;
    }
    dVar3 = 0.0;
    if (0.0 <= param_1) {
      dVar3 = dVar5;
    }
    if (dVar3 != dVar4) {
      if (*(long *)(param_2 + 0x18) == 0) {
        dVar3 = dVar3 / dVar4;
      }
      else {
        dVar4 = (dVar3 * DAT_1002581c0) / dVar4;
        _cos(dVar4);
        dVar3 = dVar4 * -0.5 + 0.5;
      }
      objc_stub::interpolate_(param_2,dVar3);
      uVar1 = 0;
      uVar2 = extraout_s0;
      goto LAB_10004e8e4;
    }
  }
  uVar2 = *(undefined4 *)(param_2 + 0x14);
  uVar1 = 1;
LAB_10004e8e4:
  *(undefined4 *)(param_2 + 0x10) = uVar2;
  return uVar1;
}

