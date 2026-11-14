// motion-gaps.c: excerpts for MOTION-REA-27.2.1.md (macOS 27.2.1, 26B131).
// Dock = System/Library/CoreServices/Dock.app/Contents/MacOS/Dock, arm64e slice (llvm-lipo -thin arm64e).
// WindowManager = System/Library/CoreServices/WindowManager.app/Contents/MacOS/WindowManager, arm64e slice.
// Method names: ObjC metadata (`ipsw macho info --objc -V`). Pseudocode: Ghidra 12.2 headless (project
// ~/Downloads/macos/re-work/gh-motion-gaps), checked against `ipsw macho disass` where Ghidra lost a register.
// Constants read from the file with gaps-motion/tools/rd.py (address -> value).
// REA Evidence: WindowManager ev_c51505b387340984dd73907b123db2f8d1f1e916337baa30040e6bc09ca59046 (all functions),
// Dock ev_731b85061d02cd9faaa87e77ae983788b938162faed9f8bf9f70aadc2d15ba70 (0x100019000..0x100072400).

// ===================================================================================================
// A. Stack view choice. -[DOCKStack expandUsingHandler:fromKeyboard:ignoringMouseDraggedEvents:] 0x100019dc4
// ===================================================================================================
// 0x100019f58 orientation = [bar barOrientation]; (w, h) = [bar fLastBarRect].size     (x23, d8, d9)
// 0x10001a068 screen = [display screenBoundsExcludingMenuBar] converted to the Dock window
// 0x10001a098 stageH = orientation == 0 ? screen.h - barH : screen.h
//             stageW = orientation == 0 ? screen.w        : screen.w - barW
//             _stageFrame = { screen.x + (int)(stageW * 0.1), screen.y,          // 0.1 at 0x1002581f8
//                             (int)(stageW * 0.8), (int)(stageH * 0.8) }          // 0.8 at 0x100258438
// 0x10001a11c viewAs = self->_viewAs (byte +0x28):
//   1 (Fan):       class = orientation == 0 ? DOCKStackFanLayer : DOCKStackGridLayer
//   0 (Automatic): orientation != 0 -> Grid;
//                  else class = (_stageFrame.h * (1/64) < numberOfExpandedStackItems) ? Grid : Fan
//                  (0x10001a16c: fmul by 0x3f90000000000000 = 1/64, fcmp, csel mi)
//   other:         DOCKStackGridLayer      (List is handled before, by showStackAsMenu:)
// No CATransaction duration is set here; the animator is called at the end ("expand:").

// ===================================================================================================
// B. The pile on the tile. DOCKStack
// ===================================================================================================
// -[DOCKStack initWithTile:viewAs:displayAsStack:preferredItemSize:] 0x10000c3b4
//     self->_maxNumberOfCollapsedItems (+0x71) = 3;
// -[DOCKStack _loadCollapsedImages] 0x10000cc54: n = min(numberOfCollapsedStackItems, 3) images, index 0 first.
// -[DOCKStack _imageForCollapsedImages] 0x10000dbac: 128 x 128 pt bitmap (x display scale), drawn by block
// FUN_10000dea8 (asm 0x10000dfe8..0x10000e0e0):
void pile_draw(CGContextRef c, NSArray *images /* n <= 3, newest first */) {
    int n = images.count;
    CGRect r = { 6*n + 6, 18*n, 128 - 2*(6*n + 6), 128 - 2*(6*n + 6) };
    for (id img in images.reverseObjectEnumerator) {      // oldest (back) first, newest (front) last
        r = CGRectInset(r, -6, -6);                       // 0x10000e054: d4 = d5 = -6.0
        r.origin.y -= 12;                                 // 0x10000e07c: d10 = returned y + (-12)
        CGContextDrawImage(c, r, img);                    // no rotation, no shadow, no offset in x
    }
}
// n = 3: back (18, 36, 92, 92), middle (12, 18, 104, 104), front (6, 0, 116, 116)  [CG, y up, of 128]
// n = 2: back (12, 18, 104, 104), front (6, 0, 116, 116);  n = 1: (6, 0, 116, 116)
// -[DOCKStack getCollapsedLayoutFrames:count:] 0x100067df4 (where the fan items start / end):
//     s = tileSize < 32 ? 1 : tileSize < 48 ? 2 : 3;   (0x42000000 = 32.0, 0x42400000 = 48.0)
//     frame[i] = { s*(i+1), 3*s*i, W - 2*s*(i+1), H - 2*s*(i+1) }    (W, H = tile image bounds)
//     (asm 0x100067ee4: store, CGRectInset(r, s, s), y += 2s)

// ===================================================================================================
// C. Fan. DOCKStackFanLayer / DOCKStackFanItemLayer / DOCKStackFanAnimator
// ===================================================================================================
// -[DOCKStackFanLayer initWithStack:usingLayerSource:] 0x100071acc
//     _itemSize = _itemImageSize = (64, 64)                        // 0x4050000000000000 at 0x100071b44
// -[DOCKStackFanLayer expandedFrameForStage:relativeToLayer:withEdge:] 0x100071ec0
//     _numberOfViewableItems = (unsigned)(stage.size.height * (1/64));   // 0x100071fa0..0x100071fbc
//     frame = { (int)(tileMidX - tileW/2), trunc(tileMidY - tileH/2) - 24, tileW, tileH }  (root layer)
// -[DOCKStackFanLayer layout] 0x100072030 (asm, d8 = item height 64):
void fan_layout(DOCKStackFanLayer *self) {
    CGRect b = self.bounds;
    int x0 = (int)(b.origin.x + b.size.width * 0.5);
    int y  = (int)(b.origin.y + b.size.height * 0.5) + 64 * 0.5;     // first item
    for (CALayer *item in self->_itemLayers) {
        int dx = 3000 - (int)sqrt(9000000 - y*y);                     // 0xbb8, 0x895440
        double a = -atan(y / (3000.0 - dx));                          // 3000.0 at 0x100258428
        item.transform = CATransform3DMakeRotation(a, 0, 0, 1);
        item.position  = (CGPoint){ x0 + dx, x0 + y };               // as in the code (x0 used for both)
        item.bounds    = (CGRect){ 0, 0, 64, 64 };
        y = (int)(64 + y);                                            // next item one 64 pt step up
    }
}
// -[DOCKStackFanItemLayer layoutSublayers] 0x100042d78 (w = h = 64):
//     image layer = bounds;
//     label (textBackgroundLayer) position = LTR ? (-5, h/2) : (w + 5, h/2), anchorPoint (LTR ? 1 : 0, 0.5)
//                                            (anchor set in -_setText: 0x100042668)
//     glass backdrop square (int)(w * 0.875) = 56, centred;  shadow 1.5 w x 1.5 h, centre 15 below;
//     progress bar (int)(w * 0.6) x 10 at y 6;  close box centred at (0.1 w, 0.9 h).
// -[DOCKStackFanItemLayer _setText:] 0x100042474: label = glass pill, radius 13, group "dock-fan-background"
//     (non-glass fallback: ECRoundBackdropLayerController radius 4); text 13 pt system font
//     (+[DOCKStackExpandedItemLayer itemFont] 0x10001f894: CTFontCreateUIFontForLanguage, 13.0),
//     width = min(text width, 500) (0x100258068 = 500.0).
// -[DOCKStackFanAnimator expand:] 0x100063c2c
//     before: every item at the centre of its collapsed frame (getCollapsedLayoutFrames; items past the 3rd use
//             the last one), transform identity, label opacity 0; CATransaction flush.
//     then one CATransaction (no setAnimationDuration except Shift slow motion 5.0 s at 0x1000642e4):
//       D = [CATransaction animationDuration]                       // 0x1000642ec
//       tf = kCAMediaTimingFunctionEaseInEaseOut                    // 0x100064300
//       position: CAKeyframeAnimation along CGPathAddArc(centre (x0 + 3000, y), radius 3000) from the pile to
//                 the item's place (0x100064a..; same 3000 circle as layout), tf
//       transform: item rotation set to its layout angle (implicit)
//       label: opacity from presentation value to 1; transform scale 1e-5 -> identity, tf, duration D
//                 (1e-5 at 0x100258060)
//     no beginTime / no per-item delay in the function (no setBeginTime: call).
// -[DOCKStackFanAnimator collapse:] 0x100064d90: the same arc back to the collapsed frames, label scale
//     identity -> 1e-5, tf ease-in-out, duration D. Items 0..2 keep opacity (they become the pile); items past
//     the 3rd fade: Display as Stack: opacity -> 0 with beginTime = now + D - 0.05 (0x100258430 = -0.05),
//     duration 0.1 (0x1002581f8); Display as Folder: from 1 to 0 with beginTime now + D/3, duration 2D/3.
// -[DOCKFolder expandedStackValueForKey:atIndex:withItemInfo:maximumViewableItems:] 0x10001df18
//     if (count > i && i == max - 1)  text = "%@ More in Finder" with count - i  (0x10001dfbc)
//     if (count == i)                 text = "Open in Finder"                    (0x10001e090)

// ===================================================================================================
// D. Grid. DOCKStackGridLayer / DOCKStackGridAnimator
// ===================================================================================================
// -[DOCKStackGridLayer _sizeForStage:] 0x10001b4d4
CGSize grid_size(CGRect stage, int count, int pref /* default 3: defaultPreferredItemSize 0x100095e78 */) {
    double base = pref == -1 ? 128 : pref * 16 + 80;     base = clamp(base, 80, 512);
    double pitch = base + 28;
    int n = min(count, (int)((stage.w / pitch) * (stage.h / pitch)));
    int cols = (int)sqrt(n), rows = (int)((float)n / cols);
    if (n != (n / cols) * cols && n - (n / cols) * cols < rows) { cols++; rows = (int)((float)n / cols); }
    int cell = (int)(stage.w / cols);  if (stage.h < rows * cell) cell = (int)(stage.h / rows);
    cell = min(cell, min(base, (int)(2 * pitch)));
    _itemSize = (cell, cell);  _itemImageSize = (cell - 28, cell - 28);
    grid.rows = rows; grid.columns = cols; rowHeight = columnWidth = cell;
    double w = cols * cell + (scrollbarVisibility == 2 ? (scrollable ? 42 : 34) : 34);
    double h = rows * cell + (titleTextLayer ? 54 : 44);
    if (orientation == 1 || orientation == 2) w += 12;
    return (CGSize){ w, h };
}
// -[DOCKStackGridLayer _expandedFrameWithSize:forStage:relativeToLayer:withEdge:] 0x10001bc58 (bottom, asm
// 0x10001bd9c..0x10001bdf8): x = (int)(tileMidX - w/2), kept within [screen.x + 30, screen.maxX - 30 - w];
//     y = (int)edge + (magnification ? 5 : 11).
// -[DOCKStackGridLayer layout] 0x10001bfb8 (bottom Dock): glass background frame = bounds with y + 12 (the tail
//     band), centred on the tile's centre (setCenter:); grid frame = { 17, 24, W - 34, H - 44 } (- 10 more with a
//     title); title text at the top, width <= 0.75 W; 1 pt divider lines above and below the grid.
// -[DOCKStackGridLayer initWithStack:usingLayerSource:] 0x10001a794: background = ECCartoucheGlassLayerController
//     initWithSize:2 side:(orientation + 1) (non-glass: ECCartoucheBackdropLayerController radius 5).
// ECCartoucheGlassLayerController metrics by size (Dock Swift helpers):
//     radius 0x10018767c: size 1 -> 13, size 2 -> 26;  pointer square side 0x10018772c: 16 / 24;
//     pointer corner 0x1001877dc: 2.5 / 5;  pointer offset 0x10018788c: 4 / 5;
//     size table 0x100186e18: size 1 -> (15, 8); size 2, side 1..4 -> (34, 10), (10, 34), (34, 10), (10, 34)
//     (tables 0x100264060 / 0x100264080).
// -[DOCKStackGridItemLayer layoutSublayers] 0x10001f44c: imageLayer.frame = {14, 22, cell - 28, cell - 28};
//     textBackgroundLayer.frame = {1, 0, cell, 22}, text centred (kCAAlignmentCenter).
// -[DOCKStackGridAnimator expand:] 0x10001f9c0
//     panel.hidden = NO; opacity 0; transform scale(1e-5, 1e-5, 1); position = centre of the tile's image layer;
//     CATransaction flush; begin (Shift: 5.0 s); opacity 1; transform identity (0x10001fc34);
//     position = its frame position; commit.   No duration, no timing function set: CATransaction defaults.
// -[DOCKStackGridAnimator collapse:] 0x10002165c: the reverse (scale 1e-5, opacity 0, position = tile centre).
// Reduce Motion (axReduceMotion) in both animators: hidden / shown with actions disabled, no motion.

// ===================================================================================================
// E. Mission Control transition spring. WindowManagerAgent (REA ev_c515..., Ghidra 12.1.4 + ipsw asm)
// ===================================================================================================
// SingleSpaceTransitionModifier, FUN_1003aadb4 (asm 0x1003aae48..0x1003aaf30), when transitionMode is unset:
//   if (input.byte[+0x44] == 1)                      transitionMode = reducedMotion(...)   // 0x1003aae54
//   else if (tag(fromMode) >= 0xfe && tag(toMode) >= 0xfe)                               // 0x1003ad130:
//        spring = global 0x1005fdb08;                 // ldrb w8,[x9,#0x10]; cmp w8,#0xfe
//   else spring = SpringBehavior(dampingRatio 0x1005fdb30 = ExposeSpringDampingRatio 1.0,
//                                response     0x1005fdb38 = ExposeSpringResponse 0.25)       // 0x1003aaf04
//   transitionMode = standard(SingleSpaceStandardTrackableTransitionInternalModifier(spring))
// Static springs (FUN_10013441c(dampingRatio, response) -> SpringBehavior.init 0x100073a14):
//   0x1005fdb08 = (1.0, 0.38)  FUN_1001343cc (0x3fd851eb851eb852)
//   0x1005fdb18 = (1.0, 0.2)   FUN_100134408;  0x1005fdb28 = (1.0, 0.1) FUN_1001343e0
//   0x1005fdae8 = (1.0, 0.3)   FUN_1001343f4;  0x1005fdaf8 = (0.86, 0.15) FUN_1001343b0
// Trackpad: FUN_1003a72ac -> 0x1001345e4 (response x 0.6 when |velocity| > 5).
// SingleSpaceStandardTrackableTransitionInternalModifier init FUN_1003a5410:
//   +0x398 appIconAlphaTransitionScaleFactor = 2.0 (0x4000000000000000); +0x390 = 1.
// Tracking FUN_1003a733c: p = clamp(percent, 0, 1) for all windows; app icon alpha min(1, 2 p) (line 734),
//   max(0, 2 p - (2 + x)) (line 974).
// Per-value spring step (closed form) FUN_10003e8a8 (CGRect lanes), FUN_10003ea9c (3 lanes):
//   z = dampingRatio (+0x10), w2 = tension (+0x20), c/2 = friction/2 (+0x28 * 0.5)
//   z == 1:  x(t) = (x0 + (v0 + c/2 x0) t) e^(-c/2 t)
//   z  > 1:  cosh / sinh form;  z < 1: sincos form; each value keeps its own displacement and velocity.

// ===================================================================================================
// F. Round 2 (2026-11-14). WindowManagerAgent, same REA Evidence ev_c515..., objdump asm (gaps-motion/wm.dis),
//    types through `ipsw macho info --fixups` (GOT slot -> descriptor in the agent).
// ===================================================================================================
// SingleSpaceTransitionModifier.fromMode / toMode : SpaceWindowingMode   (GOT 0x1005d3120 -> 0x10052a208)
enum SpaceWindowingMode {               // single payload; 17 bytes: AppExposeTarget payload + tag byte at +0x10
    appExpose(AppExposeTarget),         // tag byte 0 (process: CanonicalProcessSerialNumber {hi, lo}) or 1 (bundle)
    freeform,                           // 0xff  \  extra inhabitants of the tag byte, counted down (Swift ABI):
    stageManager,                       // 0xfe   | inferred names; values 0xfc..0xff confirmed by the jump table
    missionControl,                     // 0xfd   | at 0x1003ad0d4 (init, 0x1003ace3c: sub w16, w8, #0xfc; cmp #3)
    showDesktop,                        // 0xfc  /
};
// 0x1003ad130 (outlined): x9 = self + fieldOffset; w8 = byte [x9 + 0x10]; cmp w8, #0xfe
// 0x1003aadb4 spring choice (asm 0x1003aaea0..0x1003aaf30):
//   if (tag(fromMode) < 0xfe || tag(toMode) < 0xfe) spring = SpringBehavior(1.0, 0.25);   // ExposeSpring
//   else                                            spring = global 0x1005fdb08 = (1.0, 0.38); // freeform <-> stageManager
// Init 0x1003acd70..0x1003ad0a8, child toggles (offsets: 0x998 stageManagerToggleModifier, 0x9a0 missionControlToggleModifier):
//   from {fc,fd} -> to fe: stageManagerToggle  (0x1003acf74);   from {fc,fd} -> to ff: missionControlToggle (0x1003ad030)
//   from fe -> to {fc,fd}: stageManagerToggle  (0x1003acec8);   from fe -> to ff: stageManagerToggle (0x1003acfcc)
//   from ff -> to {fc,fd}: missionControlToggle (0x1003ad030);  from ff -> to fe: stageManagerToggle (0x1003acfcc)
//   same tag: none.

// SpringBehavior.init(dampingRatio, response) 0x100073a14:
void spring_init(SpringBehavior *s, double zeta, double response) {
    double k = pow(6.283185307179586 / response, 2);        // 2 pi at 0x1004a1ce8
    double c = zeta * 2 * sqrt(k);
    s->dampingRatio = zeta;  s->response = response;         // +0x10, +0x18
    s->tension = k;          s->friction = c;                // +0x20, +0x28
    s->settlingDuration = CASpringAnimation(mass 1, stiffness k, damping c).settlingDuration;   // +0x30, 0x10007394c
}
// Step 0x10003e8a8 (CGRect, 4 lanes; 0x10003ea9c the same for 3), x = displacement, v = velocity, per lane:
void spring_step(SpringBehavior *s, double dt, double *x, double *v, double *e) {
    double b = s->friction * 0.5, k = s->tension, A = *v + b * *x, X, V;
    if (s->dampingRatio == 1.0) { X = *x + A * dt;                                V = A; }
    else if (s->dampingRatio > 1.0) { double r = sqrt(b*b - k), C = cosh(r*dt), S = sinh(r*dt);
        X = *x * C + A * S / r;  V = A * C + *x * r * S; }
    else { double r = sqrt(k - b*b), C = cos(r*dt), S = sin(r*dt);
        X = *x * C + A * S / r;  V = A * C - *x * r * S; }
    double d = exp(-b * dt);
    *x = X * d;  *v = (V - X * b) * d;  *e = (*x) * (*x) + pow(*v * 2 * b / k, 2);
}
// Mission Control (1.0, 0.25) from rest: p(t) = 1 - (1 + 8 pi t) e^(-8 pi t);
//   60 Hz: .067 .205 .358 .499 .619 .715 .791 .848 (frames 1..8)

// animate(cancelled, velocity): witness 0x1003a9840 -> 0x1003a72ac (asm):
void animate(Modifier *self, bool cancelled, double velocity) {
    SpringBehavior *sp = spring_for_velocity(self->springBehavior /* +0x360 */, velocity);  // 0x1001345e4:
    //   abs(velocity) > 5.0 (0x1005fdb48) ? SpringBehavior(z, response * 0.6 (0x1005fdb50)) : the same spring
    double target = cancelled ? 0.0 : 1.0;                   // 0x1003a72ec fcsel: velocity is dropped here
    layout_all_windows(self, sp, target);                    // 0x1003a733c: one SpringAnimation per value, no v0 set
}

// MissionControlSpaceComponent.State.windows : SingleSpaceComponentWindowModel (GOT 0x1005d2918)
//   { orderedSpaceWindowIDs, windowIDToWindow, persistentWindowIDToWindowIDs }  = SingleSpaceComponentInputModel.windows
// State assigned in 0x1002281c0 (field offset global 0x100606dd8, setter fragment 0x1002300c8) from
//   0x10022a2a4(&state, inputModel). Stage Manager's filteredInputModel exists only in StageManagerSpaceComponent.

// SpotlightUIInternal (dyld cache, ipsw dyld macho --swift): the Apps view
//   enum SpotlightXPCServerMessage { launchAppsBrowsing(OSSignpostIntervalState), prepare, activate, deactivate }
//   enum RootStackCoordinator.RootDestination { results, firstTimeExperience, pasteboardFTE, appsBrowsing }
//   enum SearchNavigationDestination { searchResults(..), appsBrowsing(AppsBrowsingConfiguration), ... }
//   struct AppsBrowsingConfiguration { let viewController: SearchResultsViewController }
