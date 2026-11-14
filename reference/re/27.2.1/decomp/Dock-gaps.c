// Dock gaps REA, macOS 27.2.1 (26B131). Static only. Sources:
//   Dock arm64e (sha256 05afb171...), DockHelper.xpc arm64e (sha256 7edeba80...), AppKit and CoreUI from the dyld cache.
// Ghidra 12.1.4 pseudocode is decompiler output, not source. "// asm:" blocks are hand reconstructions from the
// disassembly (llvm-objdump on the thinned Dock, ipsw dyld disass on AppKit / CoreUI); each line names the address.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 1. Hover label width: -[ECCartoucheGlassLayerController setContentLayer:] body FUN_100186bdc (Dock)
//    REA Evidence ev_e4dbe2676da50722b45856cc9dc299b19dc1d395359c8e59d16bd0cc24e42b5c (rea decompile, Ghidra 12.1.4)
// asm: 100186ce4 content.bounds -> (w, h)          (selector bounds, selref 0x1003129d0)
// asm: 100186d04 r   = [self radiusFor:size]        (13 for size 1, FUN_10018767c)
// asm: 100186d08 H   = 2r > 26 ? max(h, 2r) : max(h, 26)
// asm: 100186d58 pad = max(r, 13)                   (fmov #13, fcsel mi)
// asm: 100186d84 (minW, tailH) = FUN_100186e18(size, side)   size 1 -> (15, 8); size 2 -> table 0x100264060/80; else (34, 10)
// asm: 100186da0 layer.bounds = (0, 0, w + 2*pad, H + tailH)  -> "Finder": (ceil(textW) + 26, 34)
// asm: 100186ddc content.frame = (pad, tailH, w, h)            -> text box at x 13, y 8
//
// -[DOCKLabelLayer _updateLabelImage:orientation:] 0x10003f44c then reads the backdrop layer's bounds back:
// asm: 10003f608 [backdrop setContentLayer:textLayer]  (selref 0x100315080)
// asm: 10003f61c (x, y, w, h) = backdrop.layer.bounds
// asm: 10003f638 h = max(h, 26)
// asm: 10003f704 [self setBounds:(x, y, w, h)]; backdrop.layer.frame = same
// So the label width is the cartouche's: text + 2*13. Ghidra's pseudocode of 0x10003f44c shows the image width here,
// which is wrong (register reuse); the asm above is the reading to trust.
//
// Text width, FUN_10001494c: CTLineCreateWithAttributedString, w = ceil(CTLineGetTypographicBounds) (fcvtpu at 1000149ec),
// truncated in the middle (CTLineCreateTruncatedLine type 2) when w > 600 (cmp #0x259).
// Attributes, init block 0x10003ec8c: font = CTFontCreateUIFontForLanguage(kCTFontUIFontSystem = 2, 14.0, NULL)
// (10003ee14), dictionaries of exactly 2 keys {kCTFontAttributeName, kCTForegroundColorAttributeName} (10003eef4..):
// no kern / tracking attribute. Second style: CTFontDescriptorCreateForUIType(2, 11.0) + feature (type 6, selector 0)
// = monospaced digits (10003ee28..10003eeac).

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 1b. Label shape: -[ECCartoucheGlassLayerController layout] body FUN_100186fc0, side 1 (bottom Dock) = jump case 0x1001870dc
// asm: 100187044 (minW 15, tailH 8) = FUN_100186e18
// asm: 100187060 r = radiusFor: (13)  [sp+0x48];  100187074 off = cartoucheVerticalOffsetFor: (4);  100187088 s = cartoucheRectSideLengthFor: (16)
// asm: 1001870e8 bodyW = max(W, minW + 2r) = max(W, 41);  bodyX = (W - bodyW) / 2
// asm: 1001870fc bodyH = H - tailH;  100187294 bodyY = H - bodyH = 8
// asm: 100187104 tailX = round(center - minW/2), clamped to the body's minX + r .. maxX - r
// asm: 100187258 sqY = H - (-off) - s  (= H - 12)
// asm: 10018727c CATransform3DMakeRotation(0.785398 = pi/4 from 0x100264058, 0, 0, 1)
// asm: 10018728c sqRadius = cartoucheRadiusFor: (2.5)
// asm: 1001873cc smooth-union smoothness 25.0 (0x4039000000000000), shapes: body rect radius r, square (s x s) radius 2.5

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2. Dock menu: DockHelper.xpc presents it with AppKit. DockHelper FUN_10000aa2c
//    REA Evidence ev_9a0fbb7ebfe65a66c38a31e9a71905acae4c813669b430af14f8db78cd1216a1 (rea decompile-all DockHelper)
  objc_stub::setFrame_display_
            (IVar4,(double)param_1,(double)((float)extraout_d0 - param_4),
             (double)(param_3 - param_1),(double)(param_4 - param_2),0);
  objc_stub::makeKeyAndOrderFront_(IVar4);
  IVar8 = objc_stub::contentView(IVar4);
  IVar8 = objc_stub::_popUpMenuRelativeToRect_inView_preferredEdge_flags_options_
                    (self,0,0,(double)(param_3 - param_1),(double)(param_4 - param_2),IVar8,uVar9,
                     uVar11,0);
  if (IVar10 != 0) {
    FUN_10000aeb0(IVar10);
  }
  objc_stub::orderOut_(IVar4);
// preferredEdge = DAT_100010528[direction] = {0, 2, 1, 1}; flags 0x100 when opened from the keyboard; options nil.

// AppKit: every NSPopupMenuWindow is made with style mask 0x8000 (-[NSPopupMenuWindow initWithContextMenuImpl:],
// mov w2 #0x8000 at 0x18aa88d3c), and +[NSPopupMenuWindow frameViewClassForStyleMask:] 0x18aa8e2b8 maps 0x8000 to
// _NSPopupMenuWindowPopoverFrame. Its mask path:
// asm: -[_NSPopupMenuWindowPopoverFrame _copyFrameMaskPathInRect:] 0x18aa8858c
//   if anchorSize == NSZeroSize -> nil (no shape)
//   edgeCode = anchorEdge < 4 ? {1, 4, 3, 2}[anchorEdge] (table 0x18b7ef0b0) : 1000 (no arrow)
//   arrowPos = (anchorEdge is 1 or 3) ? anchorPoint.x - (bounds.x - rect.x) : rect.h - anchorPoint.y
//   return CUICreateMenuPath(rect, 1, 1, 1, 1, edgeCode, 1.0, arrowPos)        (tail call 0x18aa886ac)
//
// CoreUI _CUICreateMenuPath 0x18f272c7c / __CUICreateMenuPath 0x18f272ce4:
//   code = {0x64, 0x67, 0x66, 0x62}[edgeCode - 1] (0x18f3287b8)
//   0x64 -> edge 0, 0x66 -> edge 2: pos = maxY - pos*s;  0x62 -> edge 1, 0x67 -> edge 3: pos = pos*s;  else no arrow
//   arrowWidth  = 23.5 * s   (0x18f3287a8 = 0x4037800000000000)   (0 when no arrow)
//   arrowHeight = 13.0 * s   (fmov #13 at 0x18f272dd8)
//   cornerRadius= 12.0 * s   (fmov #12 at 0x18f272dd0)
//   __CUICreateNewPopoverPathWithArrowPosition 0x18f272e24: pos clamped to [w/2, span - w/2] (span = rect.h for edge 0/2,
//   rect.w for 1/3), centred when span < arrowWidth, no arrow when pos is not finite; -> __CUIContinuousRoundedRectBezierPathWithCornerRadius
// CoreUI __pathForRoundedRectWithAnchor 0x18f2fcfbc:
//   body = continuous rounded rect of rect, radius = min(r, floor(min(w, h) / 2) - 1)     (0x18f2fd0b0..0x18f2fd100)
//   arrow, local frame (x = out of the body, y = along the edge), then rotated by edge * pi/2 and translated to the
//   anchor point (0x18f2fd2ac..0x18f2fd3b0):
//     move   (0,  W/2 + 1)
//     arcTo  t1 (0,  W/2 - 0.08h)  t2 (-h, 0)              radius 0.60h     (base fillet)
//     arcTo  t1 (-h, 0)            t2 (0, 0.08h - W/2)     radius 0.42h     (tip)
//     arcTo  t1 (0, 0.08h - W/2)   t2 (0, -W/2 - 1)        radius 0.60h     (base fillet)
//   constants 0.6 = 0x3fe3333333333333, 0.42 = 0x3fdae147ae147ae1, 0.08 = 0x3fb47ae147ae147b; W = d4, h = d5 (0x18f2fcff4)
//   then the arrow is spliced into the body outline (0x18f2fd4d0..).

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 3. Drop on the Trash tile
bool DOCKTrashTile::dragDrop_(ID param_1,SEL param_2,OpaqueCoreDrag *param_3)

{
  int iVar1;
  ID IVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  long lVar5;
  dispatch_queue_t pdVar6;
  undefined *local_90;
  undefined8 local_88;
  code *local_80;
  undefined *puStack_78;
  long local_70;
  ID IStack_68;
  byte local_60;
  undefined8 local_58;
  undefined8 local_50;
  undefined8 local_48;
  
  Tile::setSelected_(param_1,0);
  _os_unfair_lock_lock(&DAT_100329c18);
  IVar2 = Tile::dock(param_1);
  IVar2 = objc_stub::labelLayer(IVar2);
  objc_stub::detach(IVar2);
  _os_unfair_lock_unlock(&DAT_100329c18);
  IVar2 = objc_stub::currentDragContents(DAT_100329bc8);
  if (IVar2 == 0) {
    uVar3 = FUN_100023800(param_3);
    objc_stub::setCurrentDragContents_(DAT_100329bc8,uVar3);
  }
  IVar2 = objc_stub::currentDragContents(DAT_100329bc8);
  if ((((uint)IVar2 >> 0xe & 1) == 0) &&
     (IVar2 = objc_stub::currentDragContents(DAT_100329bc8), ((uint)IVar2 >> 0xf & 1) == 0)) {
    IVar2 = objc_stub::currentDragContents(DAT_100329bc8);
    if (((uint)IVar2 >> 4 & 1) == 0) {
      _CoreDragSetStandardDropLocation(param_3,0x74727368);
      _CoreDragSetDropActions(param_3,0x20);
    }
  }
  else {
    local_48 = 0;
    iVar1 = _CoreDragGetPasteboardRef(param_3,&local_48);
    if (iVar1 == 0) {
      local_50 = 0;
      iVar1 = _PasteboardGetItemIdentifier(local_48,1,&local_50);
      uVar4 = local_48;
      uVar3 = local_50;
      if (iVar1 == 0) {
        local_58 = 0;
        IVar2 = objc_stub::dragFileFlavor(DAT_100329c20);
        iVar1 = _PasteboardCopyItemFlavorData(uVar4,uVar3,IVar2,&local_58);
        if (iVar1 == 0) {
          uVar3 = _CFDataGetBytePtr(local_58);
          uVar4 = _CFDataGetLength(local_58);
          lVar5 = _CFURLCreateWithBytes(0,uVar3,uVar4,0x8000100,0);
          if (lVar5 != 0) {
            IVar2 = objc_stub::currentDragContents(DAT_100329bc8);
            pdVar6 = _dispatch_get_global_queue(0x19,0);
            local_90 = PTR___NSConcreteStackBlock_1002ee408;
            local_88 = DAT_100258058;
            local_80 = FUN_1000718fc;
            puStack_78 = &DAT_1002cd368;
            local_70 = lVar5;
            IStack_68 = param_1;
            local_60 = (byte)((uint)IVar2 >> 0xf) & 1;
            _dispatch_async(pdVar6,&local_90);
          }
          _CFRelease(local_58);
        }
      }
    }
  }
  objc_stub::setLastDragRef_(DAT_100329bc8,param_3);
  objc_stub::setLastDragRefError_(DAT_100329bc8,0);
  FUN_10019dd34(&cf_AXDraggingDestinationDragAccepted,param_1);
  return 1;
}
undefined8 FUN_1000518f4(undefined8 param_1)

{
  code *pcVar1;
  undefined8 uVar2;
  ID IVar3;
  ulong unaff_x30;
  
  uVar2 = _objc_autoreleasePoolPush();
  IVar3 = NSFileManager::defaultManager((ID)PTR__OBJC_CLASS___NSFileManager_1002edf90);
  IVar3 = NSFileManager::trashItemAtURL_resultingItemURL_error_(IVar3,param_1,0,0);
  if ((int)IVar3 != 0) {
    _AudioServicesPlaySystemSound(0x10);
  }
  _objc_autoreleasePoolPop(uVar2);
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x10005197c);
    (*pcVar1)();
  }
  return 0;
}
void FUN_1000718fc(long param_1)

{
  code *pcVar1;
  ulong unaff_x30;
  undefined *local_48;
  undefined8 local_40;
  code *local_38;
  undefined *puStack_30;
  undefined8 local_28;
  
  if (*(char *)(param_1 + 0x30) == '\x01') {
    FUN_100051980();
    local_48 = PTR___NSConcreteStackBlock_1002ee408;
    local_40 = DAT_100258058;
    local_38 = FUN_1000719b4;
    puStack_30 = &DAT_1002cc320;
    local_28 = *(undefined8 *)(param_1 + 0x28);
    _dispatch_async(PTR___dispatch_main_q_1002ee418,&local_48);
    return;
  }
  if (((unaff_x30 ^ unaff_x30 << 1) >> 0x3e & 1) != 0) {
                    /* WARNING: Does not return */
    pcVar1 = (code *)SoftwareBreakpoint(0xc471,0x1000719b0);
    (*pcVar1)();
  }
  FUN_1000518f4(*(undefined8 *)(param_1 + 0x20));
  return;
}
// Drag classifier FUN_100023800 (first pasteboard item): flavor "local-volume-url" -> 0x8000 (eject),
// "owensdock" -> 0x10, "stackitem" -> 0x2000, "local-file-url" -> 0x4000, "trashlabel" -> 0x200.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 4a. Stack grid size
CGSize DOCKStackGridLayer::_sizeForStage_(ID param_1,SEL param_2,CGRect param_3)

{
  ID *pIVar1;
  byte *pbVar2;
  byte bVar3;
  ID IVar4;
  int iVar5;
  int iVar6;
  long lVar7;
  long lVar8;
  int iVar9;
  int iVar10;
  double dVar11;
  double dVar12;
  double dVar13;
  double dVar14;
  CGSize CVar15;
  
  dVar12 = param_3.field1_0x10.field1_0x8;
  dVar13 = *(double *)PTR__CGSizeZero_1002eea08;
  dVar14 = *(double *)(PTR__CGSizeZero_1002eea08 + 8);
  if ((*(long *)(param_1 + (long)DOCKStackLayer::_layerSource) != 0) &&
     (IVar4 = objc_stub::numberOfItemsForLayer_
                        (*(ID *)(param_1 + (long)DOCKStackLayer::_layerSource),
                         param_3.field0_0x0.field0_0x0,param_3.field0_0x0.field1_0x8,param_1),
     IVar4 != 0)) {
    dVar14 = 128.0;
    if (*(int *)(param_1 + (long)DOCKStackExpandedLayer::_preferredItemSize) != -1) {
      dVar14 = (double)(*(int *)(param_1 + (long)DOCKStackExpandedLayer::_preferredItemSize) << 4) +
               80.0;
    }
    dVar11 = 80.0;
    if ((80.0 <= dVar14) && (dVar11 = dVar14, 512.0 < dVar14)) {
      dVar11 = 512.0;
    }
    dVar14 = dVar11 + 28.0;
    iVar5 = (int)((param_3.field1_0x10.field0_0x0 / dVar14) * (dVar12 / dVar14));
    if (IVar4 <= (ulong)(long)iVar5) {
      iVar5 = (int)IVar4;
    }
    iVar10 = (int)SQRT((double)iVar5);
    iVar9 = (int)((float)iVar5 / (float)iVar10);
    iVar6 = 0;
    if (iVar10 != 0) {
      iVar6 = iVar5 / iVar10;
    }
    if (iVar5 != iVar6 * iVar10 && iVar5 - iVar6 * iVar10 < iVar9) {
      iVar10 = iVar10 + 1;
      iVar9 = (int)((float)iVar5 / (float)iVar10);
    }
    iVar5 = (int)(param_3.field1_0x10.field0_0x0 / (double)iVar10);
    if (dVar12 < (double)(iVar9 * iVar5)) {
      iVar5 = (int)(dVar12 / (double)iVar9);
    }
    if ((double)(int)(dVar14 + dVar14) <= dVar11) {
      dVar11 = (double)(int)(dVar14 + dVar14);
    }
    dVar12 = (double)iVar5;
    if (dVar11 <= (double)iVar5) {
      dVar12 = dVar11;
    }
    iVar5 = (int)dVar12;
    pIVar1 = (ID *)(param_1 + (long)_gridLayer);
    objc_stub::setRows_(*pIVar1,(long)iVar9);
    objc_stub::setColumns_(*pIVar1,(long)iVar10);
    objc_stub::setRowHeight_(*pIVar1,(long)iVar5);
    objc_stub::setColumnWidth_(*pIVar1,(long)iVar5);
    lVar7 = (long)_hasScrollableContent;
    pbVar2 = (byte *)(param_1 + lVar7);
    bVar3 = 0x10;
    if (IVar4 <= (ulong)(long)(iVar10 * iVar9)) {
      bVar3 = 0;
    }
    *pbVar2 = *pbVar2 & 0xef | bVar3;
    lVar8 = (long)DOCKStackExpandedLayer::_itemSize;
    *(double *)(param_1 + lVar8) = (double)iVar5;
    ((double *)(param_1 + lVar8))[1] = (double)iVar5;
    lVar8 = (long)DOCKStackExpandedLayer::_itemImageSize;
    *(double *)(param_1 + lVar8) = (double)(iVar5 + -0x1c);
    ((double *)(param_1 + lVar8))[1] = (double)(iVar5 + -0x1c);
    lVar8 = *(long *)(param_1 + (long)_scrollbarVisibility);
    if (lVar8 == 2) {
      iVar6 = 0x22;
      if ((*(byte *)(param_1 + lVar7) & 0x10) != 0) {
        iVar6 = 0x2a;
      }
      dVar13 = (double)(iVar6 + iVar10 * iVar5);
    }
    else {
      dVar14 = (double)(iVar10 * iVar5 + 0x22);
      dVar12 = dVar13;
      if (lVar8 == 0) {
        dVar12 = dVar14;
      }
      dVar13 = dVar14;
      if (lVar8 != 1) {
        dVar13 = dVar12;
      }
    }
    iVar10 = 0x2c;
    if (*(long *)(param_1 + (long)_titleTextLayer) != 0) {
      iVar10 = 0x36;
    }
    dVar14 = (double)(iVar10 + iVar9 * iVar5);
    IVar4 = objc_stub::barOrientation(DAT_100329ba8);
    if ((IVar4 == 1) || (IVar4 = objc_stub::barOrientation(DAT_100329ba8), IVar4 == 2)) {
      dVar13 = dVar13 + 12.0;
    }
  }
  CVar15.field1_0x8 = dVar14;
  CVar15.field0_0x0 = dVar13;
  return CVar15;
}
// NOTE: the casts Ghidra prints as (int) on the sqrt and the rows division are fcvtps (round up):
// 10001b5d4 fcvtps w23 (columns = ceil(sqrt(n))), 10001b5e4 / 10001b608 fcvtps w22 (rows = ceil(n / columns)).

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 4b. Stack fan layout
void DOCKStackFanLayer::layout(ID param_1,SEL param_2)

{
  int iVar1;
  double dVar2;
  int iVar3;
  int iVar4;
  ID IVar5;
  ID IVar6;
  int iVar7;
  int iVar8;
  undefined8 uVar9;
  long lVar10;
  ID IVar11;
  long lVar12;
  bool bVar13;
  double extraout_d0;
  double dVar14;
  double in_d1;
  double in_d2;
  double in_d3;
  double dVar15;
  double dVar16;
  double dVar17;
  double dVar18;
  long lStack_158;
  long *local_150;
  undefined1 auStack_120 [128];
  long local_a0;
  
  local_a0 = *(long *)PTR____stack_chk_guard_1002ee410;
  lVar10 = (long)DOCKStackLayer::_layerSource;
  IVar5 = objc_stub::numberOfItemsForLayer_(*(ID *)(param_1 + lVar10),param_1);
  objc_stub::bounds(param_1);
  iVar4 = FUN_1000071f8();
  if (IVar5 != 0) {
    IVar11 = 0;
    lVar12 = (long)_numberOfViewableItems;
    do {
      if (*(ulong *)(param_1 + lVar12) <= IVar11) break;
      IVar6 = objc_stub::makeLayerForLayer_(*(ID *)(param_1 + lVar10),param_1);
      objc_stub::addObject_(*(ID *)(param_1 + (long)_itemLayers),IVar6);
      objc_stub::insertSublayer_atIndex_(param_1,IVar6,0);
      IVar11 = IVar11 + 1;
    } while (IVar5 != IVar11);
  }
  lVar12 = (long)_itemLayers;
  IVar5 = objc_stub::count(*(ID *)(param_1 + lVar12));
  if (IVar5 != 0) {
    IVar11 = *(ID *)(param_1 + lVar10);
    uVar9 = *(undefined8 *)(param_1 + lVar12);
    IVar6 = objc_stub::display(DAT_100329ba8);
    objc_stub::scaleFactor(IVar6);
    objc_stub::setContentInLayers_withDataRange_forLayer_usingScaleFactor_
              (IVar11,uVar9,0,IVar5,param_1);
  }
  dVar15 = *(double *)(param_1 + (long)DOCKStackExpandedLayer::_itemSize + 8);
  lStack_158 = 0;
  local_160 = 0;
  uStack_148 = 0;
  local_150 = (long *)0x0;
  uStack_138 = 0;
  local_140 = 0;
  uStack_128 = 0;
  uStack_130 = 0;
  IVar11 = *(ID *)(param_1 + lVar12);
  IVar5 = objc_stub::countByEnumeratingWithState_objects_count_(IVar11,&local_160,auStack_120,0x10);
  dVar2 = DAT_100258428;
  if (IVar5 != 0) {
    iVar8 = 0;
    iVar7 = 0;
    dVar18 = dVar15 * 0.5;
    lVar10 = *local_150;
    bVar13 = true;
    do {
      lVar12 = 0;
      do {
        if (*local_150 != lVar10) {
          _objc_enumerationMutation(IVar11);
        }
        IVar6 = *(ID *)(lStack_158 + lVar12 * 8);
        iVar1 = (int)(dVar18 + (double)(int)(in_d1 + in_d3 * 0.5));
        iVar3 = (int)(extraout_d0 + in_d2 * 0.5);
        if (!bVar13) {
          iVar1 = iVar7;
          iVar3 = iVar8;
        }
        iVar8 = iVar3;
        dVar17 = (double)(3000 - (int)SQRT((double)(9000000 - iVar1 * iVar1)));
        dVar16 = (double)iVar1;
        dVar14 = (double)_atan(dVar16 / (dVar2 - dVar17));
        _CATransform3DMakeRotation(&local_1e0,(double)-(float)dVar14,0,0,0x3ff0000000000000);
        uStack_218 = uStack_198;
        local_220 = local_1a0;
        uStack_208 = uStack_188;
        uStack_210 = uStack_190;
        uStack_1f8 = uStack_178;
        local_200 = local_180;
        uStack_1e8 = uStack_168;
        uStack_1f0 = uStack_170;
        uStack_258 = uStack_1d8;
        local_260 = local_1e0;
        uStack_248 = uStack_1c8;
        uStack_250 = uStack_1d0;
        uStack_238 = uStack_1b8;
        local_240 = local_1c0;
        uStack_228 = uStack_1a8;
        uStack_230 = uStack_1b0;
        objc_stub::setTransform_(IVar6,&local_260);
        objc_stub::setPosition_
                  (IVar6,dVar18 + ((double)(int)((double)iVar8 + dVar17) - dVar18),
                   dVar18 + ((double)(int)((double)iVar8 + dVar16) - dVar18));
        objc_stub::setBounds_(IVar6,0,0,dVar15,dVar15);
        bVar13 = false;
        iVar7 = (int)(dVar15 + dVar16);
        lVar12 = lVar12 + 1;
        IVar5 = IVar5 - 1;
      } while (IVar5 != 0);
      IVar5 = objc_stub::countByEnumeratingWithState_objects_count_
                        (IVar11,&local_160,auStack_120,0x10);
      bVar13 = false;
    } while (IVar5 != 0);
  }
  IVar5 = 0;
  if (iVar4 != 0) {
    IVar5 = CATransaction::setDisableActions_((ID)PTR__OBJC_CLASS___CATransaction_1002ee1d0,0);
  }
  if (*(long *)PTR____stack_chk_guard_1002ee410 != local_a0) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail(IVar5);
  }
  return;
}
CGRect DOCKStackFanLayer::expandedFrameForStage_relativeToLayer_withEdge_
                 (ID param_1,SEL param_2,CGRect param_3,ID param_4,double param_5)

{
  ID IVar1;
  undefined8 extraout_d0;
  double extraout_d0_00;
  double extraout_d0_01;
  double dVar2;
  double dVar3;
  double dVar4;
  double dVar5;
  double dVar6;
  CGRect CVar7;
  
  dVar3 = param_3.field1_0x10.field0_0x0;
  dVar2 = param_3.field0_0x0.field1_0x8;
  dVar5 = param_3.field1_0x10.field1_0x8;
  objc_stub::bounds(param_4,param_3.field0_0x0.field0_0x0);
  dVar4 = dVar3;
  dVar6 = dVar5;
  IVar1 = objc_stub::superlayer(param_4);
  objc_stub::frame(param_4);
  objc_stub::convertRect_toLayer_(IVar1,extraout_d0,dVar2,dVar4,0);
  dVar6 = (double)(long)((dVar2 + dVar6 * 0.5) - dVar5 * 0.5) + -24.0;
  *(long *)(param_1 + (long)_numberOfViewableItems) =
       (long)(param_3.field1_0x10.field1_0x8 * 0.015625);
  IVar1 = objc_stub::superlayer(param_1);
  objc_stub::convertRect_fromLayer_
            (IVar1,(double)(int)((extraout_d0_00 + dVar4 * 0.5) - dVar3 * 0.5),0);
  CVar7.field0_0x0.field1_0x8 = dVar6;
  CVar7.field0_0x0.field0_0x0 = extraout_d0_01;
  CVar7.field1_0x10.field1_0x8 = dVar5;
  CVar7.field1_0x10.field0_0x0 = dVar3;
  return CVar7;
}
// DAT_100258428 = 3000.0
