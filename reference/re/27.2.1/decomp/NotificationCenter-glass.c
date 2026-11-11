// NotificationCenter.app 27.2.1, arm64e slice (lipo -thin arm64e), otool -tV + Ghidra 12.1.4 via REA.
// Type names from Swift reflection (__swift5_fieldmd / __swift5_types); owner of each body found as the
// function just before the type's View/ButtonStyle/ViewModifier resilient witness. Reconstructed Swift-ish
// pseudocode, annotated with addresses. Not original source.

// ===================================================================================================
// (a) Notification card / platter glass: NotificationBackgroundModifier.body  FUN_100119fe8
//     glass builder FUN_10011a374. Fields: showDetails Sb, isObscured Sb, @Env colorScheme,
//     @Env reduceMotion Sb, @Env bannerSlideProgress Sd.
// ===================================================================================================
_Glass FUN_10011a374(NotificationBackgroundModifier self) {
    _Glass g = _Glass.notificationCenter                     // 0x10011a4f8
                   .forceSubdued(self.isObscured);           // 0x10011a504 (byte self+1)
    double p = 1.0;                                          // 0x10011a550
    if (self.reduceMotion /*Env<Bool> FUN_100134544*/)       // 0x10011a54c
        p = self.bannerSlideProgress;  /*Env<Double> FUN_100134900, 0x10011a56c*/
    g = g.mix(with: _Glass.identity, by: 1.0 - p);           // 0x10011a52c / 0x10011a580
    return g.surfaceSize(.medium);                           // 0x10011a5a0 / 0x10011a5b0
}
// FUN_100119fe8:
content._glassEffect(FUN_10011a374(self),                    // 0x10011a27c
                     in: RoundedRectangle(cornerRadius: 20,  // fmov.2d v0,#20 @0x10011a240
                                          style: .continuous)) // 0x10011a1ec
       .background(Color.clear) ...                          // 0x10011a2b4

// DesignLibrary (dyld cache, 27.2.1/DesignLibrary): NotificationCenterRecipe Spec type
// (symbolic @0x195fd5690, witness 0x1eec7a608):
//   ConditionalModifiedSchema<... ModifiedSchema<ModifiedSchema<RegularBase, RegularDiffusionAmount>,
//        NotificationCenterRecipe.ShadowVibrancy>,
//     ApplyAdaptivityReducedTransparency @ReducedTransparency, ApplyAdaptivityIncreasedContrast @IncreaseContrast,
//     ApplyReducedMotion @ReducedMotion, ApplyReducedTransparency, ApplyIncreasedContrast,
//     ApplyShapeOutlineBase @ShapeOutlines, ApplyShapeOutlineBorders @(ShapeOutlines && !IncreaseContrast)>
//   = Regular recipe minus WindowActiveShadow and minus RegularRecipe.Inactive @InactiveCondition.
// ShadowVibrancy spec FUN_195f1ecc4:
//   shadow.vibrancyContribution = 1;  (+0x129) = 0;

// ===================================================================================================
// (c) Buttons: NotificationButtonStyle { height, width?, cornerRadius, padding, glass }  (accessor FUN_10006b8f8)
//     makeBody FUN_10006b9xx..0x10006c190 (witness 0x10006c190)
// ===================================================================================================
configuration.label
    .padding(.horizontal, padding)                           // 0x10006bde0
    .frame(width: width, height: height, alignment: .center) // 0x10006be44
    .background(RoundedRectangle(cornerRadius, .continuous)  // 0x10006bebc
                  .inset(...).fill(isPressed ? .quaternary : .clear)) // 0x10006bf44..0x10006bf84
    ._glassEffect(glass, in: RoundedRectangle(cornerRadius, .continuous)) // 0x10006c078
    ._glassEffectZIndex(1.0)                                 // 0x10006c0cc
    .glassEffectTransition(.identity);                       // 0x10006c128

// Call sites (height, width, cornerRadius, padding, glass); q-constants read from __const:
//  NotificationsContentSmallCloseButton  FUN_10005f5dc @0x10005f978:
//     h = lazyState ? 24 : 20, width nil, r = h/2, padding = flag ? 10 : 0,
//     glass = _Glass.notificationCenter.forceSubdued(true)          // per-card hover "x"
//  NotificationsListGroupShowLessButton  FUN_10006fb68 @0x10006fe08: (20, nil, 10, 10, .regular)
//  NotificationsConfirmCloseButton       FUN_100147278 @0x100147700: (20, nil, 10, 0, .regular)  (+hover, d1=10)
//  WidgetsTodayViewOnboardingBannerCloseButton FUN_1000e727c @0x1000e7474: (20, nil, 10 [0x1002d4b00], 0, .regular)
//  FUN_10017c490 (before WidgetsEditContainer witness; "widget-editor-button", "Clear All Notifications",
//                 "Clear Banners Only"):
//     @0x10017c924 Edit Widgets: (24, nil, 12, 10 [0x1002da440], .regular)
//     @0x10017cbd8 Clear All circle: (24, 24, 12, 0 [0x1002da450], .regular)
//     @0x10017ce58 (xmark/label variant): (24, nil, 12, 10, .regular)
//  NotificationsList FUN_1001a2b30 @0x1001a3124 "Clear All Notifications": (24, nil, 12, 10, .regular),
//     then .padding(.top,10).padding(.horizontal,16); GlassEffectContainer(spacing: 0) @0x1001a286c
//  MoreNotificationsButtonStyle ("N more") FUN_10003a928: label.padding(.horizontal,10).frame(height: 24)
//     .background(RoundedRectangle(.continuous) fill pressed ? .quaternary : .clear)
//     .background(Material._glass(.regular))              // 0x10003ace0 / 0x10003ad0c (Material, not _glassEffect)

// ===================================================================================================
// (b) Widgets: NC never calls _glassEffect for widgets; it only builds CHSWidgetTintParameters.
// ===================================================================================================
CHSWidgetTintParameters *FUN_1001560a4(bool subdued /*w0*/) {      // called from FUN_10015600c
    CHSMutableWidgetTintParameters *t = ...;                        // 0x1001560c8
    if (subdued) t.glassOptions = [CHSGlassOptions withSubduedGlass]; // 0x100156108..0x100156124
    return t;
}
// subdued = (WidgetTimeline._appearance == case 0)  (FUN_100153028; tst/cset eq @0x100155860, 0x100154e30)
// WidgetAppearance cases in declaration order: recessed, original, automatic  -> subdued == .recessed (guess on
// tag order). wantsSubduedGlass is only read for diagnostics @0x1001589a0.

// ===================================================================================================
// (d) Column backdrop: NotificationCenterBackground / NotificationCenterBackgroundView / NotificationBackdropLayer
// ===================================================================================================
// NotificationCenterBackground body FUN_100139bbc (witness 0x10013a1bc):
progress = controller.flag /*FUN_1001de6c0*/ ? 1.0 : panel.openProgress /*FUN_1001ddcb0: ldr d0,[x19,#0x68]*/;
NotificationCenterBackgroundView(isEmpty, progress)
    .frame(width: 376 /*0x4077800000000000 @0x100139e04*/, height: min(h1, h2) /*fcsel @0x100139ddc*/)
    .padding(.horizontal, 16)                                       // 0x100139e44
    ... .frame(width: geometry.width, alignment: .trailing);        // 0x100139fc0..0x10013a024
// NotificationCenterBackgroundView { @Env accessibilityReduceTransparency, isEmpty, progress } body FUN_10013a1c8:
_CALayerView<NotificationBackdropLayer>(update: FUN_10013a3e0).padding(EdgeInsets(all: -40)); // 0xc044.. @0x10013a1c8
void FUN_10013a3e0(layer, progress) {                               // update closure
    double r = reduceTransparency ? 0.0 : progress;                 // fcsel @0x10013a410
    FUN_10013a428(layer, r);
}
void FUN_10013a428(NotificationBackdropLayer *self, double r) {     // filters
    CAFilter *f = [CAFilter filterWithType:kCAFilterVariableBlur];  // 0x10013a468
    [f setValue:@YES     forKey:kCAFilterInputNormalizeEdges];      // 0x10013a47c
    [f setValue:@(1.5*r) forKey:kCAFilterInputRadius];              // fmov 1.5 @0x10013a49c
    [f setValue:@"mask"  forKey:kCAFilterInputSourceSublayerName];  // 0x10013a4c0
    [f setValue:nil      forKey:kCAFilterInputMaskImage];           // 0x10013a4ec
    self.filters = @[f];                                            // 0x10013a56c
}
void FUN_10013a870(NotificationBackdropLayer *self, CGRect bounds) {// layout (from FUN_10013ab84 path)
    self.windowServerAware = YES;                                   // 0x10013a8a8
    CALayer *m = self->maskLayer;
    m.frame = CGRectInset(bounds, 60, 60);                          // 0x404e.. @0x10013a8b8
    m.backgroundColor = CGColor.black;                              // 0x10013a8ec
    m.filters = @[[CAFilter gaussianBlur] inputRadius: 20];         // 0x10013a928 / fmov 20 @0x10013a93c
    m.name = @"mask";                                               // 0x10013a9e0
    m.cornerRadius = 40;                                            // 0x4044.. @0x10013aa08
    self.sublayers = @[m];                                          // 0x10013aa90
}
// No colorMatrix / dim / tint filter anywhere in this layer.

// NotificationsListShadowBackground { isEmpty, progress } body FUN_10013ade8 (witness 0x10013af8c):
RoundedRectangle(cornerRadius: 20, style: .continuous)              // 0x10013aebc
    .shadow(color: .black.opacity(0.2 * progress) /*0.2 @0x1002ce458*/, radius: 30 /*0x403e*/, x: 0, y: 0)
    .padding(.bottom, isEmpty ? -30 : 0);                           // 0x10013af0c
// ShadowBackground { cornerRadius, opacity, radius, offset } CALayer update FUN_1001ff490:
//   shadowOpacity=opacity, shadowRadius=radius, shadowOffset=offset, cornerRadius, shadowPathIsBounds=YES,
//   cornerCurve=continuous, punchoutShadow=YES.  (call sites/values not traced)
