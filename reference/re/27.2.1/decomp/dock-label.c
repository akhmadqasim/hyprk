// Dock 27.2.1 hover label. DOCKLabelLayer, glass always on (FUN_1000b4d40 returns 1).
// Font: CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 14.0); text max width 600 (middle-truncated); image h = capH + 2*floor((floor(asc+desc+5)-capH)/2).
// Layer bounds = (image w, max(26, image h)). Backdrop (FUN_10003f170): bottom dock -> ECCartoucheGlassLayerController(size 1, side 1),
//   side docks -> ECRoundGlassLayerController radius 13. Glass config: GlassMaterialProvider.Configuration.cartouchePopover, Size.minimum, adaptive(false).
// Cartouche size 1: radiusFor 13, cartoucheRectSideLength 16 (45-deg rotated square), cartoucheRadius 2.5, cartoucheVerticalOffset 4,
//   FUN_100186e18 -> (15, 8): min body width 15 + 2*13; layout smoothness 25.0. (size 2: 26 / 24 / 5 / 5).
// Fade out: -[DockBar blendAwayLabel] blend 1 -> 0 over 300 ms (0x1002583f0), cosine ease-in-out; attach sets blend 1 with no animation.

//==== 100014588 attach: (asked 0x100014588)
/* Function Stack Size: 0x18 bytes */
void DOCKLabelLayer::attach_(ID param_1,SEL param_2,ID param_3)
{
  undefined8 *puVar1;
  code *pcVar2;
  int iVar3;
  ID IVar4;
  ID self;
  class_t *pcVar5;
  ulong uVar6;
  long lVar7;
  ulong unaff_x30;
  float extraout_s0;
  if (param_3 == 0) goto LAB_10001479c;
  IVar4 = objc_stub::stack(param_3);
  IVar4 = objc_stub::expanded(IVar4);
  if ((IVar4 & 1) != 0) goto LAB_10001479c;
  lVar7 = (long)_source;
  IVar4 = *(ID *)(param_1 + lVar7);
  self = *(ID *)(param_1 + lVar7);
  puVar1 = (undefined8 *)(param_1 + (long)_blend);
  FUN_10022f0c0(0x3f800000,*puVar1);
  FUN_10022f108(0,*puVar1);
  FUN_10022efac(*puVar1);
  *(ID *)(param_1 + lVar7) = param_3;
  *(undefined1 *)(param_1 + (long)_needUpdate) = 1;
  objc_stub::setHidden_(param_1,0);
  if (IVar4 == param_3) goto LAB_10001479c;
  IVar4 = objc_stub::dock(param_3);
  IVar4 = objc_stub::display(IVar4);
  objc_stub::scaleFactor(IVar4);
  objc_stub::labelDetached(self);
  if (*(long *)(param_1 + lVar7) != 0) {
    objc_stub::setLabelNeedsUpdate_(*(ID *)(param_1 + lVar7),0);
    objc_stub::labelAttached(*(ID *)(param_1 + lVar7));
  }
  iVar3 = 0;
  thunk_FUN_1000b4d40();
  IVar4 = objc_stub::dock(param_3);
  IVar4 = objc_stub::barOrientation(IVar4);
  uVar6 = *(ulong *)(param_1 + (long)_backdrop);
  if (iVar3 == 0) {
    if (IVar4 != 0) goto LAB_100014734;
    pcVar5 = &objc::class_t::ECCartoucheBackdropLayerController;
  }
  else if (IVar4 == 0) {
    pcVar5 = &objc::class_t::ECCartoucheGlassLayerController;
  }
  else {
LAB_100014734:
    pcVar5 = &objc::class_t::ECRoundBackdropLayerController;
  }
  _objc_opt_class(pcVar5);
  _objc_opt_isKindOfClass(uVar6,pcVar5);
  if ((uVar6 & 1) == 0) {
    updateBackground(param_1);
  }
  IVar4 = objc_stub::dock(param_3);
  IVar4 = objc_stub::barOrientation(IVar4);
  _updateLabelImage_orientation_(param_1,extraout_s0,IVar4);
  thunk_FUN_100167ae4(0);
LAB_10001479c:
    return;
  }
                    /* WARNING: Does not return */
}

//==== 10003f44c _updateLabelImage:orientation: (asked 0x10003F44C)
   _objc_retain_fixup */
/* Function Stack Size: 0x1c bytes */
void DOCKLabelLayer::_updateLabelImage_orientation_
               (ID param_1,SEL param_2,float param_3,long_long param_4)
{
  uint uVar1;
  ID IVar2;
  ID IVar3;
  ID IVar4;
  ID IVar5;
  ID IVar6;
  undefined *self;
  class_t *self_00;
  long lVar7;
  long lVar8;
  long lVar9;
  double extraout_d0;
  double extraout_d0_00;
  undefined8 uVar10;
  double dVar11;
  double dVar12;
  double dVar13;
  double dVar14;
  undefined8 local_c0;
  undefined *local_b8;
  undefined8 local_b0;
  code *local_a8;
  undefined *puStack_a0;
  float local_98;
  lVar7 = (long)_source;
  IVar2 = objc_stub::secondaryLabel(*(ID *)(param_1 + lVar7));
  local_b8 = PTR___NSConcreteStackBlock_1002ee408;
  local_b0 = DAT_100258088;
  local_a8 = FUN_10003f84c;
  puStack_a0 = &DAT_1002ccb50;
  local_98 = param_3;
  IVar3 = objc_stub::labelImage_(*(ID *)(param_1 + lVar7),&local_b8);
  if (IVar3 != 0) {
    IVar4 = objc_stub::isBeta(*(ID *)(param_1 + lVar7));
    IVar5 = IVar3;
    _CGImageGetWidth(IVar3);
    IVar6 = IVar3;
    _CGImageGetHeight();
    self = PTR__OBJC_CLASS___CALayer_1002ee150;
    _objc_opt_new();
    dVar11 = (double)(ulong)(long)((float)IVar5 / param_3);
    dVar12 = (double)(ulong)(long)((float)IVar6 / param_3);
    uVar10 = 0;
    objc_stub::setBounds_((ID)self,0,0,dVar11);
    objc_stub::setContents_((ID)self,IVar3);
    objc_stub::setContentsScale_((ID)self,(double)param_3);
    if (IVar2 != 0) {
      IVar2 = objc_stub::darkDock(DAT_100329c20);
      local_c0 = 0;
      FUN_1000a4f34(0,(uint)IVar2 ^ 1,&local_c0);
      objc_stub::setCompositingFilter_((ID)self,local_c0);
    }
    lVar9 = (long)_backdrop;
    objc_stub::setContentLayer_(*(ID *)(param_1 + lVar9),self);
    IVar2 = objc_stub::layer(*(ID *)(param_1 + lVar9));
    objc_stub::bounds(IVar2);
    dVar13 = 26.0;
    if (26.0 <= dVar12) {
      dVar13 = dVar12;
    }
    if ((int)IVar4 == 0) {
      lVar8 = (long)_flagLayer;
      if (*(ID *)(param_1 + lVar8) != 0) {
        objc_stub::removeFromSuperlayer(*(ID *)(param_1 + lVar8));
        *(undefined8 *)(param_1 + lVar8) = 0;
      }
    }
    else {
      if ((DAT_100329c08 & 1) == 0) {
        objc_stub::frame((ID)self);
        objc_stub::setFrame_((ID)self,extraout_d0_00 + 12.0);
      }
      dVar11 = dVar11 + 12.0;
      lVar8 = (long)_flagLayer;
      if (*(long *)(param_1 + lVar8) == 0) {
        self_00 = &objc::class_t::ECFlagLayer;
        _objc_alloc();
        IVar2 = objc_stub::initWithStyle_((ID)self_00,1);
        IVar3 = objc_stub::layer(*(ID *)(param_1 + lVar9));
        objc_stub::addSublayer_(IVar3,IVar2);
        *(ID *)(param_1 + lVar8) = IVar2;
      }
    }
    objc_stub::setBounds_(param_1,extraout_d0,uVar10,dVar11,dVar13);
    IVar2 = objc_stub::layer(*(ID *)(param_1 + lVar9));
    objc_stub::setFrame_(IVar2,extraout_d0,uVar10,dVar11,dVar13);
    objc_stub::layout(*(ID *)(param_1 + lVar9));
    if (*(long *)(param_1 + lVar8) != 0) {
      IVar2 = objc_stub::secondaryLabel(*(ID *)(param_1 + lVar7));
      dVar12 = 6.0;
      if (IVar2 == 0) {
        IVar2 = objc_stub::secondaryLabelImage(*(ID *)(param_1 + lVar7));
        dVar12 = 8.0;
        if (IVar2 != 0) {
          dVar12 = 6.0;
        }
      }
      uVar1 = 0;
      thunk_FUN_1000b4d40();
      dVar14 = dVar12 + 8.0;
      if ((param_4 == 0 & uVar1) == 0) {
        dVar14 = dVar12;
      }
      dVar12 = extraout_d0;
      _CGRectGetMaxY(extraout_d0,uVar10,dVar11,dVar13);
      dVar11 = dVar11 + -20.0;
      if (DAT_100329c08 == 0) {
        dVar11 = 10.0;
      }
      objc_stub::setFrame_
                (*(ID *)(param_1 + lVar8),dVar11,dVar12 - (dVar14 + 9.0),0x4022000000000000,
                 0x4022000000000000);
      objc_stub::layout(*(ID *)(param_1 + lVar8));
    }
  }
  return;
}

//==== 10005c470 blendAwayLabel (asked 0x10005C470)
/* Function Stack Size: 0x10 bytes */
void DockBar::blendAwayLabel(ID param_1,SEL param_2)
{
  code *pcVar1;
  ID IVar2;
  ulong unaff_x30;
  undefined8 extraout_d0;
  undefined8 uVar3;
  undefined8 extraout_d0_00;
  IVar2 = objc_stub::rollTile(param_1);
  if (IVar2 == 0) {
    return;
  }
  IVar2 = objc_stub::autoHideOn(param_1);
  uVar3 = DAT_1002583f0;
  if ((int)IVar2 != 0) {
    IVar2 = objc_stub::autoHide(param_1);
    uVar3 = extraout_d0;
    FUN_10022f0f8(IVar2);
  }
  IVar2 = objc_stub::labelLayer(param_1);
  FUN_10022e1cc(IVar2);
  objc_stub::mainMillis(DAT_100329c20);
  FUN_10022efd4(0,extraout_d0_00,uVar3,IVar2);
  IVar2 = objc_stub::labelLayer(param_1);
  FUN_10022e208(IVar2,1);
  IVar2 = objc_stub::labelLayer(param_1);
  IVar2 = objc_stub::source(IVar2);
  objc_stub::labelDetached(IVar2);
    setRollTile_(param_1,0);
    return;
  }
                    /* WARNING: Does not return */
}

//==== 10003f170 FUN_10003f170 (asked 0x10003f170)
ID FUN_10003f170(long param_1,ID param_2,ulong param_3,undefined8 param_4)
{
  undefined8 uVar1;
  code *pcVar2;
  ID IVar3;
  class_t *pcVar4;
  ulong unaff_x30;
  float extraout_s0;
  float extraout_s0_00;
  undefined8 extraout_d0;
  undefined8 extraout_d0_00;
  IVar3 = param_2;
  thunk_FUN_1000b4d40();
  if ((int)IVar3 == 0) {
    uVar1 = 8;
    if ((int)param_3 == 0) {
      uVar1 = 2;
    }
    if (param_1 == 0) {
      pcVar4 = &objc::class_t::ECCartoucheBackdropLayerController;
      _objc_alloc();
      objc_stub::scaleFactor(param_2);
      IVar3 = objc_stub::initWithSize_side_radius_material_materialStyle_darkMode_scaleFactor_
                        ((ID)pcVar4,0x4010000000000000,extraout_d0_00,1,1,uVar1,param_4,param_3);
    }
    else {
      pcVar4 = &objc::class_t::ECRoundBackdropLayerController;
      _objc_alloc();
      objc_stub::scaleFactor(param_2);
      IVar3 = objc_stub::initWithRadius_material_materialStyle_groupName_darkMode_scaleFactor_
                        ((ID)pcVar4,0x4010000000000000,extraout_d0,uVar1,param_4,0,param_3);
    }
  }
  else if (param_1 == 0) {
    pcVar4 = &objc::class_t::ECCartoucheGlassLayerController;
    _objc_alloc();
    objc_stub::scaleFactor(param_2);
    IVar3 = objc_stub::initWithSize_side_scaleFactor_((ID)pcVar4,(double)extraout_s0_00,1,1);
  }
  else {
    pcVar4 = &objc::class_t::ECRoundGlassLayerController;
    _objc_alloc();
    objc_stub::scaleFactor(param_2);
    IVar3 = objc_stub::initWithRadius_backdropGroupName_glassSize_scaleFactor_colorScheme_
                      ((ID)pcVar4,0x402a000000000000,(double)extraout_s0,0,1,param_3 & 0xffffffff);
  }
                    /* WARNING: Does not return */
  }
  return IVar3;
}

//==== 10003f84c FUN_10003f84c (asked 0x10003f84c)
ulong FUN_10003f84c(long param_1,long param_2,long param_3,long param_4)
{
  ID *pIVar1;
  ID *pIVar2;
  undefined8 *puVar3;
  code *pcVar4;
  ID IVar5;
  ID IVar6;
  uint uVar7;
  ulong uVar8;
  ulong unaff_x30;
  double dVar9;
  double dVar10;
  undefined1 auVar11 [16];
  float fVar12;
  undefined *local_130;
  undefined8 local_128;
  code *local_120;
  undefined *puStack_118;
  long local_110;
  long local_108;
  long local_100;
  double local_f8;
  undefined8 local_f0;
  undefined8 uStack_e8;
  double local_e0;
  double dStack_d8;
  float local_d0;
  uint local_cc;
  uint uStack_c8;
  uint local_c4;
  uint uStack_c0;
  double local_b8;
  double local_b0;
  uint local_a4;
  double local_a0;
  double local_98;
  uint local_8c [3];
  fVar12 = *(float *)(param_1 + 0x20);
  local_a4 = 0;
  local_b8 = 0.0;
  local_b0 = 0.0;
  IVar5 = objc_stub::darkDock(DAT_100329c20);
  pIVar2 = &DAT_10032a2a8;
  if (param_3 != 0) {
    pIVar2 = &DAT_10032a298;
  }
  pIVar1 = &DAT_10032a2a0;
  if (param_3 != 0) {
    pIVar1 = &DAT_10032a290;
  }
  if ((int)IVar5 == 0) {
    pIVar2 = pIVar1;
  }
  IVar5 = *pIVar2;
  IVar6 = objc_stub::objectForKeyedSubscript_
                    (IVar5,*(undefined8 *)PTR__kCTFontAttributeName_1002eea90);
  if (IVar6 == 0) {
    dVar9 = 0.0;
  }
  else {
    dVar9 = (double)_CTFontGetCapHeight(IVar6);
  }
  local_8c[0] = 0;
  local_98 = 0.0;
  local_a0 = 0.0;
  FUN_10001494c(param_2,IVar5,local_8c,&local_98,&local_a0);
  if (param_2 == 0) {
    uVar8 = 0;
  }
  else {
    if (param_3 == 0) {
      local_c4 = 0;
      param_3 = 0;
    }
    else {
      IVar5 = objc_stub::darkDock(DAT_100329c20);
      puVar3 = &DAT_10032a2b8;
      if ((int)IVar5 == 0) {
        puVar3 = &DAT_10032a2b0;
      }
      FUN_10001494c(param_3,*puVar3,&local_a4,&local_b0,&local_b8);
      local_c4 = local_a4;
      if (param_4 != 0) {
        local_c4 = local_a4 + 0xe;
        local_a4 = local_c4;
      }
    }
    local_cc = local_8c[0];
    if (local_8c[0] <= local_c4) {
      local_cc = local_c4;
    }
    uVar7 = (uint)(local_98 + local_a0 + 5.0);
    if (param_3 == 0) {
      dVar10 = 0.0;
    }
    else {
      uVar7 = (uint)((double)(long)(local_b0 + local_b8) + (double)uVar7);
      dVar10 = (double)(long)(local_a0 + local_b0);
    }
    local_f8 = (double)(long)(((double)uVar7 - (double)(long)(dVar9 + dVar10)) * 0.5);
    uStack_c8 = (uint)((double)(long)(dVar9 + dVar10) + local_f8 * 2.0);
    uVar8 = (ulong)(uint)(int)(fVar12 * (float)local_cc);
    local_130 = PTR___NSConcreteStackBlock_1002ee408;
    local_128 = DAT_100258058;
    local_120 = FUN_100014b80;
    puStack_118 = &DAT_1002ccb70;
    auVar11 = NEON_fmov(0x402c000000000000,8);
    uStack_e8 = auVar11._8_8_;
    local_f0 = auVar11._0_8_;
    local_e0 = local_b0;
    dStack_d8 = local_a0;
    uStack_c0 = local_8c[0];
    local_110 = param_3;
    local_108 = param_4;
    local_100 = param_2;
    local_d0 = fVar12;
    FUN_10000dc98(uVar8,(int)(fVar12 * (float)uStack_c8),0xf9,&local_130);
  }
                    /* WARNING: Does not return */
  }
  return uVar8;
}

//==== 10018767c FUN_10018767c (asked 0x10018767c)
undefined8 FUN_10018767c(char param_1)
{
  code *pcVar1;
  undefined8 uVar2;
  uVar2 = 0x402a000000000000;
  if (param_1 != '\x01') {
    if (param_1 != '\x02') {
      FUN_1000b72ac(0x402a000000000000,0);
      Swift::__diagnoseUnexpectedEnumCaseValue();
                    /* WARNING: Does not return */
    }
    uVar2 = 0x403a000000000000;
  }
  return uVar2;
}

//==== 10018772c FUN_10018772c (asked 0x10018772c)
undefined8 FUN_10018772c(char param_1)
{
  code *pcVar1;
  undefined8 uVar2;
  uVar2 = 0x4030000000000000;
  if (param_1 != '\x01') {
    if (param_1 != '\x02') {
      FUN_1000b72ac(0x4030000000000000,0);
      Swift::__diagnoseUnexpectedEnumCaseValue();
                    /* WARNING: Does not return */
    }
    uVar2 = 0x4038000000000000;
  }
  return uVar2;
}

//==== 1001877dc FUN_1001877dc (asked 0x1001877dc)
undefined8 FUN_1001877dc(char param_1)
{
  code *pcVar1;
  undefined8 uVar2;
  uVar2 = 0x4004000000000000;
  if (param_1 != '\x01') {
    if (param_1 != '\x02') {
      FUN_1000b72ac(0x4004000000000000,0);
      Swift::__diagnoseUnexpectedEnumCaseValue();
                    /* WARNING: Does not return */
    }
    uVar2 = 0x4014000000000000;
  }
  return uVar2;
}

//==== 10018788c FUN_10018788c (asked 0x10018788c)
undefined8 FUN_10018788c(char param_1)
{
  code *pcVar1;
  undefined8 uVar2;
  uVar2 = 0x4010000000000000;
  if (param_1 != '\x01') {
    if (param_1 != '\x02') {
      FUN_1000b72ac(0x4010000000000000,0);
      Swift::__diagnoseUnexpectedEnumCaseValue();
                    /* WARNING: Does not return */
    }
    uVar2 = 0x4014000000000000;
  }
  return uVar2;
}

