// Dock 27.2.1 Cmd-Tab (ASAppSwitcher / BezelIconList). Feature AppSwitcher/OutOfProcessAppSwitcher checked at 0x10008259c (no domain plist = off).
// show: windows ordered in at system level 0x1f2, no animation. hide (not immediate): CATransaction, kCAMediaTimingFunctionEaseInEaseOut,
//   layer opacity -> 0, no explicit duration (CATransaction default 0.25 s).

//==== 10003919c show: (asked 0x10003919C)
/* Function Stack Size: 0x14 bytes */
void BezelIconList::show_(ID param_1,SEL param_2,bool param_3)
{
  ID IVar1;
  ID IVar2;
  ID IVar3;
  ID self;
  ID IVar4;
  undefined4 uVar5;
  long lVar6;
  long lVar7;
  undefined8 local_1f0;
  long lStack_1e8;
  long *local_1e0;
  undefined8 uStack_1d8;
  undefined8 local_1d0;
  undefined8 uStack_1c8;
  undefined8 uStack_1c0;
  undefined8 uStack_1b8;
  undefined8 local_1b0;
  long lStack_1a8;
  long *local_1a0;
  undefined8 uStack_198;
  undefined8 local_190;
  undefined8 uStack_188;
  undefined8 uStack_180;
  undefined8 uStack_178;
  undefined1 auStack_168 [128];
  undefined1 auStack_e8 [128];
  long local_68;
  local_68 = *(long *)PTR____stack_chk_guard_1002ee410;
  if ((*(byte *)(param_1 + 0x68) & 1) == 0) {
    *(undefined1 *)(param_1 + 0x68) = 1;
    *(char *)(param_1 + 0x69) = (char)param_3;
    lStack_1a8 = 0;
    local_1b0 = 0;
    uStack_198 = 0;
    local_1a0 = (long *)0x0;
    uStack_188 = 0;
    local_190 = 0;
    uStack_178 = 0;
    uStack_180 = 0;
    IVar1 = *(ID *)(param_1 + 0x18);
    IVar2 = objc_stub::countByEnumeratingWithState_objects_count_(IVar1,&local_1b0,auStack_e8,0x10);
    if (IVar2 != 0) {
      lVar6 = *local_1a0;
      do {
        lVar7 = 0;
        do {
          if (*local_1a0 != lVar6) {
            _objc_enumerationMutation(IVar1);
          }
          objc_stub::layout(*(ID *)(lStack_1a8 + lVar7 * 8));
          lVar7 = lVar7 + 1;
          IVar2 = IVar2 - 1;
        } while (IVar2 != 0);
        IVar2 = objc_stub::countByEnumeratingWithState_objects_count_
                          (IVar1,&local_1b0,auStack_e8,0x10);
      } while (IVar2 != 0);
    }
    IVar1 = objc_stub::cid(*(ID *)(param_1 + 8));
    IVar3 = objc_stub::dockConnection(DAT_100329c20);
    _SLSTransactionCreate();
    lStack_1e8 = 0;
    local_1f0 = 0;
    uStack_1d8 = 0;
    local_1e0 = (long *)0x0;
    self = *(ID *)(param_1 + 0x10);
    uStack_1c8 = 0;
    local_1d0 = 0;
    uStack_1b8 = 0;
    uStack_1c0 = 0;
    IVar2 = objc_stub::countByEnumeratingWithState_objects_count_(self,&local_1f0,auStack_168,0x10);
    if (IVar2 != 0) {
      lVar6 = *local_1e0;
      do {
        lVar7 = 0;
        do {
          if (*local_1e0 != lVar6) {
            _objc_enumerationMutation(self);
          }
          IVar4 = objc_stub::wid(*(ID *)(lStack_1e8 + lVar7 * 8));
          _SLSTransactionSetWindowSystemLevel(IVar3,IVar4,0x1f2);
          _SLSTransactionOrderWindowGroup(IVar3,IVar4,1,0);
          lVar7 = lVar7 + 1;
          IVar2 = IVar2 - 1;
        } while (IVar2 != 0);
        IVar2 = objc_stub::countByEnumeratingWithState_objects_count_
                          (self,&local_1f0,auStack_168,0x10);
      } while (IVar2 != 0);
    }
    _SLSTransactionCommit(IVar3,0);
    _CFRelease(IVar3);
    IVar2 = ECModalEventController::sharedController((ID)PTR_ECModalEventController_1002edb28);
    ECModalEventController::addHandler_externalEventSource_usingMouseHysteresis_(IVar2,param_1,1,0);
    uVar5 = 0x3fc41cfe;
    if (*(char *)(param_1 + 0x69) == '\0') {
      uVar5 = 0x3fc410fe;
    }
    _CGSSetEventCapture(IVar1,0,uVar5,1);
    IVar2 = objc_stub::coreDragIsDragging(DAT_100329bc8);
    uVar5 = 3;
    if ((int)IVar2 == 0) {
      uVar5 = 0xd;
    }
    _CoreCursorSet(IVar1,uVar5);
    _CGSForceShowCursor(IVar1);
    thunk_FUN_100106588(IVar1);
    *(undefined1 *)(param_1 + 0x6a) = 1;
  }
  if (*(long *)PTR____stack_chk_guard_1002ee410 == local_68) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  ___stack_chk_fail();
}

//==== 10008154c FUN_10008154c (asked 0x10008154c)
void FUN_10008154c(long param_1,undefined8 param_2)
{
  code *pcVar1;
  ulong unaff_x30;
  CATransaction::begin((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0);
  CATransaction::setCompletionBlock_((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,param_2);
  (**(code **)(param_1 + 0x10))(param_1);
                    /* WARNING: Does not return */
  }
  CATransaction::commit((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0);
  return;
}

//==== 1000396d4 FUN_1000396d4 (asked 0x1000396d4)
void FUN_1000396d4(long param_1)
{
  undefined *self;
  ID IVar1;
  ID self_00;
  long lVar2;
  long lVar3;
  undefined8 local_110;
  long lStack_108;
  long *local_100;
  undefined8 uStack_f8;
  undefined8 local_f0;
  undefined8 uStack_e8;
  undefined8 uStack_e0;
  undefined8 uStack_d8;
  undefined1 auStack_c8 [128];
  long local_48;
  self = PTR__OBJC_CLASS___CATransaction_1002ee1d0;
  local_48 = *(long *)PTR____stack_chk_guard_1002ee410;
  IVar1 = CAMediaTimingFunction::functionWithName_
                    ((ID)PTR__OBJC_CLASS___CAMediaTimingFunction_1002ee158,
                     *(undefined8 *)PTR__kCAMediaTimingFunctionEaseInEaseOut_1002ee370);
  CATransaction::setAnimationTimingFunction_((ID)self,IVar1);
  uStack_e8 = 0;
  local_f0 = 0;
  uStack_d8 = 0;
  uStack_e0 = 0;
  lStack_108 = 0;
  local_110 = 0;
  uStack_f8 = 0;
  local_100 = (long *)0x0;
  self_00 = *(ID *)(*(long *)(param_1 + 0x20) + 0x18);
  IVar1 = objc_stub::countByEnumeratingWithState_objects_count_(self_00,&local_110,auStack_c8,0x10);
  if (IVar1 != 0) {
    lVar2 = *local_100;
    do {
      lVar3 = 0;
      do {
        if (*local_100 != lVar2) {
          _objc_enumerationMutation(self_00);
        }
        objc_stub::setOpacity_(*(ID *)(lStack_108 + lVar3 * 8),0);
        lVar3 = lVar3 + 1;
        IVar1 = IVar1 - 1;
      } while (IVar1 != 0);
      IVar1 = objc_stub::countByEnumeratingWithState_objects_count_
                        (self_00,&local_110,auStack_c8,0x10);
    } while (IVar1 != 0);
  }
  if (*(long *)PTR____stack_chk_guard_1002ee410 == local_48) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  ___stack_chk_fail(0);
}

