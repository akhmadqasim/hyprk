// Dock 27.2.1 minimise. effectDur (ms, DockBar 0x150): genie 500 (0x43fa0000), suck 400, scale 200 (doCommand 0x10002f05c, FUN_1000568a4).
// Window anim (FUN_100053ca0 minimise, FUN_100054204 restore): genie = pref genie-speed (default 0.5 s, x10 with Shift),
//   scale 0.25 s (2.5), suck 0.4 s (4.0). Genie falls back to scale when min(w,h) of target < 5.
// WATransaction default duration 0.25 (FUN_100007f34), default timing = timingFunctionForType(0) = bezier(0.25,0.1,0.25,1.0).
// WATimingFunction table 0x100258470: 0 (0.25,0.1,0.25,1) 1 linear 2 (0.42,0,1,1) 3 (0,0,0.58,1) 4 (0.42,0,0.58,1) 5 spring(m 1, k 100, c 10).

//==== 1000568a4 FUN_1000568a4 (asked 0x1000569a4)
undefined8 FUN_1000568a4(undefined8 param_1,undefined4 param_2,int param_3,undefined4 *param_4)
{
  ID IVar1;
  undefined8 uVar2;
  ID IVar3;
  undefined4 local_40;
  undefined4 local_3c;
  undefined2 local_38;
  int local_36;
  FUN_1000534f4();
  uVar2 = param_1;
  _os_log_type_enabled();
  if ((int)uVar2 != 0) {
    local_40 = (undefined4)DAT_100258090;
    local_38 = 0x400;
    local_3c = param_2;
    local_36 = param_3;
    __os_log_impl(0x100000000,param_1,0,"SetEnumPreference preference=%d, value=%d",&local_40,0xe);
  }
  IVar3 = 1;
  if (param_3 == 2) {
    IVar3 = 2;
  }
  IVar1 = 3;
  if (param_3 != 3) {
    IVar1 = IVar3;
  }
  IVar3 = objc_stub::minimizeEffect(DAT_100329ba8);
  if (IVar1 != IVar3) {
    objc_stub::setMinimizeEffect_(DAT_100329ba8,IVar1);
    IVar3 = objc_stub::minimizeEffect(DAT_100329ba8);
    if (IVar3 == 1) {
      uVar2 = 0x43fa0000;
    }
    else {
      IVar3 = objc_stub::minimizeEffect(DAT_100329ba8);
      uVar2 = 0x43c80000;
      if (IVar3 != 3) {
        uVar2 = 0x43480000;
      }
    }
    objc_stub::setEffectDur_(DAT_100329ba8,uVar2);
    FUN_100080fb4(IVar1);
    FUN_100018870();
  }
  *param_4 = 0;
  return 0;
}

//==== 100053ca0 FUN_100053ca0 (asked 0x100053e94)
undefined8
FUN_100053ca0(undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,ID param_5
             ,undefined8 param_6)
{
  bool bVar1;
  ID IVar2;
  ID IVar3;
  ID IVar4;
  uint uVar5;
  float fVar6;
  double dVar7;
  undefined8 uVar8;
  ulong uVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  undefined *local_100;
  undefined8 local_f8;
  code *local_f0;
  undefined *puStack_e8;
  ID local_e0;
  ID local_d8;
  undefined *local_d0;
  undefined8 local_c8;
  code *local_c0;
  undefined *puStack_b8;
  ID local_b0;
  ID local_a8;
  undefined *local_a0;
  undefined8 local_98;
  code *local_90;
  undefined *puStack_88;
  ID local_80;
  ID local_78;
  IVar2 = objc_stub::slowMotionAllowed(DAT_100329c20);
  if ((int)IVar2 == 0) {
    uVar5 = 1;
  }
  else {
    bVar1 = ECModalEventController::shiftKeyDown((ID)PTR_ECModalEventController_1002edb28);
    uVar5 = bVar1 ^ 1;
  }
  IVar3 = objc_stub::perfLogWindow(DAT_100329c20);
  IVar2 = objc_stub::perfLogWithPerfAnalysisWindow(DAT_100329c20);
  FUN_1000385b4(IVar3,IVar2,"Window",&cf_minimize);
  objc_stub::frame(param_5);
  uVar10 = param_3;
  uVar11 = param_4;
  IVar4 = objc_stub::minimizeEffect(DAT_100329ba8);
  dVar7 = (double)NEON_fminnm(param_3,param_4);
  IVar2 = 2;
  if (5.0 <= dVar7) {
    IVar2 = 1;
  }
  if (IVar4 != 1) {
    IVar2 = IVar4;
  }
  if (IVar2 == 3) {
    dVar7 = DAT_100258380;
    if (uVar5 == 0) {
      dVar7 = 4.0;
    }
    FUN_100018c98(dVar7);
    local_100 = PTR___NSConcreteStackBlock_1002ee408;
    local_f8 = DAT_100258058;
    local_f0 = FUN_10005791c;
    puStack_e8 = &DAT_1002cd1f8;
    local_e0 = param_5;
    local_d8 = IVar3;
    FUN_10006afc0(&local_100);
    FUN_10022d15c(param_6);
    _CGRectInset();
    objc_stub::suckTo_suck_(param_5,1);
  }
  else if (IVar2 == 2) {
    dVar7 = 0.25;
    if (uVar5 == 0) {
      dVar7 = 2.5;
    }
    FUN_100018c98(dVar7);
    local_d0 = PTR___NSConcreteStackBlock_1002ee408;
    local_c8 = DAT_100258058;
    local_c0 = FUN_1000578b0;
    puStack_b8 = &DAT_1002cd1f8;
    local_b0 = param_5;
    local_a8 = IVar3;
    FUN_10006afc0(&local_d0);
    FUN_10022d15c(param_6);
    _CGRectInset();
    objc_stub::setSystemFrame_(param_5);
  }
  else {
    dVar7 = 0.0;
    if (IVar2 == 1) {
      if (DAT_10031efb0 == -1.0) {
        fVar6 = 0.5;
        FUN_1000065f0(&cf_genie_speed);
        DAT_10031efb0 = fVar6;
      }
      uVar9 = (ulong)(uint)(DAT_10031efb0 * 10.0);
      fVar6 = DAT_10031efb0;
      if (uVar5 == 0) {
        fVar6 = DAT_10031efb0 * 10.0;
      }
      dVar7 = (double)fVar6;
      FUN_100018c98(dVar7);
      local_a0 = PTR___NSConcreteStackBlock_1002ee408;
      local_98 = DAT_100258058;
      local_90 = FUN_1000577d0;
      puStack_88 = &DAT_1002cd1f8;
      uVar8 = DAT_100258058;
      local_80 = param_5;
      local_78 = IVar3;
      FUN_10006afc0(&local_a0);
      FUN_10022d15c(param_6);
      _CGRectInset();
      IVar2 = objc_stub::frame(param_5);
      FUN_100057834();
      objc_stub::genieTo_direction_genie_(param_5,uVar8,uVar9,uVar10,uVar11,IVar2,1);
    }
  }
  FUN_10006afc0(0);
  IVar2 = DAT_100329be0;
  IVar3 = objc_stub::wid(param_5);
  objc_stub::prepareWindowForMinMax_duration_(IVar2,dVar7,IVar3);
  return 0;
}

//==== 100007f34 FUN_100007f34 (asked 0x100007f34)
undefined8 * FUN_100007f34(undefined8 param_1)
{
  if (DAT_100329c10 == (undefined8 *)0x0) {
    DAT_100329c10 = operator_new(param_1,0x10a0c40035d04d6);
    *DAT_100329c10 = 0;
    DAT_100329c10[1] = 0;
    DAT_100329c10[2] = 0x3fd0000000000000;
    DAT_100329c10[3] = 0;
    DAT_100329c10[4] = 0;
    DAT_100329c10[5] = 0;
    *(undefined4 *)(DAT_100329c10 + 6) = 0;
    DAT_100329c10[7] = 0;
    DAT_100329c10[8] = 0;
    FUN_100007f9c();
  }
  return DAT_100329c10;
}

