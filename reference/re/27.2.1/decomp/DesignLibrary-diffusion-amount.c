// Liquid Glass slider (NSGlassTintAmount) -> glass recipe. macOS 27.2.1 (26B131), arm64e, dyld shared cache.
// Addresses are unslid cache VAs. Read from `dyld_info -disassemble` output (AppKit, DesignLibrary); constants read
// in-process from the mapped cache. Reconstructed pseudocode, not original source.
// Live check of every formula below: reference/re/27.2.1/live/verify/C/tint-params-by-variant.json (exact match).

// ===================================================================================================
// 1. AppKit: who reads the default
// ===================================================================================================
// String "NSGlassTintAmount" 0x18b7f5a80 (AppKit __cstring, file tag "AppKit/NSGlassEffectView.swift").
// The only other copy in the cache is UIKitCore (Catalyst; next to "UIViewGlassTintAmountDidChangeNotification").
// Dock has its own copy: -[DockGlassMaterialEnvironment tintAmount] 0x100177F10 / setTintAmount: 0x100177F44, and it
// imports EnvironmentValues.glassDiffusion.setter, _Glass.Diffusion.amount(_:) and
// kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName. No copy in CoreMaterial, QuartzCore, SkyLight,
// SwiftUI, SwiftUICore, DesignLibrary, ControlCenter or NotificationCenter.
//
// enum NSGlassEffectView.Legibility { case tintAmount(Float); case standard; case increased }   (AppKit exports)
//   static systemLegibility()                          AppKit+0xF556B0
//   static setSystemLegibility(_:completionHandler:)   0x18b31ee4c
//   static previewSystemLegibility(_:)                 0x18b31ef24   (local NSNotification only)
//   static commitSystemLegibility(completionHandler:)  0x18b31efc8
//
// 0x18b3176b0  current value (cached static at 0x1eb431e38: Float, tag byte +4, nil byte +5; "read defaults" flag 0x1eb431e3d)
Legibility current() {
    Float? v = UserDefaults.standard.float?("NSGlassTintAmount");      // helper 0x18b4ef760
    return .tintAmount(v ?? 0.5);                                       // 0x3f000000 @0x18b317738
}
// 0x18b32a68c  write
void store(Legibility? l) {
    if (l == nil)            { _NSSetGlobalDefault("NSGlassDiffusionSetting", nil); _NSSetGlobalDefault("NSGlassTintAmount", nil); }
    else if case .tintAmount(x) { _NSSetGlobalDefault("NSGlassDiffusionSetting", nil); _NSSetGlobalDefault("NSGlassTintAmount", NSNumber(float: x)); }
    else /* standard | increased */ { _NSSetGlobalDefault("NSGlassDiffusionSetting", Int(0 | 1)); _NSSetGlobalDefault("NSGlassTintAmount", nil); }
}
// 0x18b32a810 also sets NSGlassEverEditedInSettings / NSGlassEverEditedInBuddy (bundle id com.apple.systempreferences /
// com.apple.SetupAssistant) and NSGlassBuddyTintAmount.
// 0x18b31ee4c setSystemLegibility: store(l); cache = l; then 0x18b4c4f80:
//     SLSPostCoordinatedDistributedNotificationFenced(SLSMainConnectionID(), 12, fencePort, block, 0.5 /*s*/);
// 0x18b4c4d48 (once per process): observes kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName on
//     SLSCoordinatedLocalNotificationCenter(); handler 0x18b4c4ee8: [NSGlassEffectView _legibilityNeedsUpdate];
//     post NSGlassEffectDiffusionDidChangeNotification; entangle the update on the fence.
// => `defaults write -g NSGlassTintAmount` alone reaches only apps launched afterwards. Running apps need the
//    WindowServer coordinated notification (type 12) that System Settings posts.   (live: confirmed)
//
// 0x18b328f44  bridge into SwiftUI (called from the hosting-view environment builder 0x18b2b393c)
void apply(inout EnvironmentValues env) {
    switch current() {
    case .tintAmount(x): env.glassDiffusion = _Glass.Diffusion.amount(x);   // 0x18b32904c
    case .standard:      env.glassDiffusion = .automatic;                    // 0x18b329074
    case .increased:     env.glassDiffusion = .increased;                    // 0x18b32903c
    }
}
// SwiftUICore: EnvironmentValues.glassDiffusion (+0xA85608), _Glass.Diffusion { amount(Float), automatic, increased }.
// DesignLibrary: GlassMaterialProvider.Environment.diffusion : ResolvedDiffusion (field 24, offset via metadata+0x70).

// ===================================================================================================
// 2. DesignLibrary: recipe modifiers that read the amount
// ===================================================================================================
// Spec offsets used: blur.radius 0x168 (ParameterScale, kind byte 0x191), faceEffect.ycc.black 0x2a4, .white 0x2a8,
// .saturation 0x2ac, .normalFill rgba 0x2b0..0x2bc (nil flag 0x2c0), faceEffect.maxLuminance 0x2ec, maxLuminanceSDR 0x2f0,
// blurFill.blurRadius 0x48c, .lightenOpacity 0x490, .darkenOpacity 0x494, .normalOpacity 0x498.
// All four start with: if (!isV2(ctx) /*0x195ed53f0*/) return;  if (env.diffusion is not .amount) return;
// mix(A, w, B) = B*(1-w) + A*w per component, on Color.Resolved (sRGB-encoded r,g,b,opacity)   0x195f7f598

// ---- RegularDiffusionAmount (spec)  thunk 0x195f1e85c -> 0x195f22ea0
void RegularDiffusionAmount(Spec *s, Context *c) {
    float a = c->env.diffusion.amount;
    if (fabsf(a - 0.5f) < 0.00034526698f) return;                 // 0x39b504f3 @0x195f23000: 0.5 is the neutral recipe
    bool dark = c->env.colorScheme == .dark;                       // 0x195f230b8
    float L = s->blurFill.lightenOpacity, D = s->blurFill.darkenOpacity, N = s->blurFill.normalOpacity;
    // "full" target of the pair: 0.9 for whichever of lighten/darken is in use (> 0)   consts 0x195fad020 / 0x195fad028
    float Lt = L > 0 ? 0.9f : 0, Dt = D > 0 ? 0.9f : 0;
    if (a >= 0.5f) {                                               // 0x195f231ec
        double t = clamp(2.0 * (a - 0.5), 0, 1);
        s->blurFill.normalOpacity  = N * (1 - t) + t;              // -> 1
        s->blurFill.lightenOpacity = L * (1 - t) + Lt * t;
        s->blurFill.darkenOpacity  = D * (1 - t) + Dt * t;
        if (s->faceEffect.ycc.normalFill != nil) {
            float k = dark ? s->faceEffect.ycc.black : 1.0f;       // grey of the face black level, or white
            s->faceEffect.ycc.normalFill = mix(Color(sRGB, k, k, k, opacity: 0.5), t, s->faceEffect.ycc.normalFill);
        }
    } else {                                                       // 0x195f2312c
        double u = clamp(2.0 * a, 0, 1);
        s->blurFill.normalOpacity  = N * u;                        // -> 0
        s->blurFill.lightenOpacity = L * (0.75 + 0.25 * u);        // fmov.2s #0.75 @0x195f23130
        s->blurFill.darkenOpacity  = D * (0.75 + 0.25 * u);
        if (s->faceEffect.ycc.normalFill != nil) {
            float k = dark ? s->faceEffect.ycc.black : 1.0f;
            s->faceEffect.ycc.normalFill = mix(s->faceEffect.ycc.normalFill, u, Color(sRGB, k, k, k, opacity: 0));
        }
        if (dark) {                                                // 0x195f23324
            // d = dimensions.minimumDistanceOfLargestArea ?? dimensions.minimumDistance ?? 48   (pt)
            // MappingRange{64, 104 -> 0.6, 0.45} @0x195facff0, linear, clamped (eval 0x195ed73f8)
            float m = lerp(0.6f, 0.45f, clamp((d - 64) / 40, 0, 1));
            s->faceEffect.maxLuminance = s->faceEffect.maxLuminanceSDR = m * (1 - u) + s->faceEffect.maxLuminance * u;
        }
    }
}
// RegularBase.Base (0x195f20248) sets the dark maxLuminance it starts from: MappingRange{64, 104 -> 0.6, 0.35}
// @0x195facf70 (loaded at 0x195f20b9c). Shadow ranges there: {64, 160} @0x195faa8e0 -> radius {4, 24} @0x195facf80.

// ---- ClearDiffusionAmount (spec)  0x195efeb9c       (Clear, Dock, Control Center and the other ClearSpec recipes)
void ClearDiffusionAmount(Spec *s, Context *c) {
    float a = c->env.diffusion.amount;
    if (a < 0.5f) {
        if (s->blur.radius.kind == constant)   s->blur.radius.value *= 2 * a;          // 0x195efec54
        else if (s->blur.radius.kind == 2)     s->blur.radius.pair  *= 2 * a;          // 0x195efec08
    } else if (a > 0.5f) {
        s->blurFill.blurRadius = 16;                                // 0x41800000 @0x195efec3c
        s->blurFill.lightenOpacity = s->blurFill.darkenOpacity = 0;
        s->blurFill.normalOpacity = 2 * (a - 0.5f);
    }
}
// ---- DiffusionBlur { highMemory:(clear, neutral), lowMemory:(clear, neutral), scaleByPixelLength } (spec) 0x195efec74
//      (ClearSpec recipes that carry their own blur pair: app icons, lock screen controls)
//      radius = clear + (neutral - clear) * clamp(2a, 0, 1)   [* pixelLength]; a > 0.5: same blurFill block as above.
//      .automatic / .increased: radius = neutral.

// ---- SidebarRecipe.SidebarDiffusionAmount (spec)  thunk 0x195f2c2e4 -> 0x195f2cbac
void SidebarDiffusionAmount(Spec *s, Context *c) {
    float a = c->env.diffusion.amount;
    if (fabsf(a - 0.5f) < 0.00034526698f) return;
    bool dark = c->env.colorScheme == .dark;
    if (a < 0.5f) {
        double u = clamp(2.0 * a, 0, 1);
        s->blurFill.normalOpacity = s->blurFill.normalOpacity * u + 0.25 * (1 - u);   // floor 0.25, not 0
        s->blurFill.lightenOpacity *= 0.75 + 0.25 * u;  s->blurFill.darkenOpacity *= 0.75 + 0.25 * u;
    } else {
        double t = clamp(2.0 * (a - 0.5), 0, 1);
        s->blurFill.normalOpacity = s->blurFill.normalOpacity * (1 - t) + t;          // lighten / darken unchanged
        if (s->faceEffect.ycc.normalFill != nil)
            s->faceEffect.ycc.normalFill = mix(dark ? Color(0, 0, 0, 0.5) : Color(1, 1, 1, 0.5), t, s->faceEffect.ycc.normalFill);
        s->faceEffect.ycc.black = s->faceEffect.ycc.black * (1 - t) + (dark ? 0.15f /*0x3e19999a*/ : s->faceEffect.ycc.black) * t;
    }
}
// ---- RegularBase.IncreasedDiffusion (spec) thunk 0x195f1e878 -> 0x195f2244c: runs only when context flag byte 3 bit 0
//      is set (the legacy "increased" setting, not the slider). dark+v2: normalFill (0,0,0,0.6), ycc black 0.2,
//      white 0.75, saturation 2.0; light: normalFill alpha 0.8, black 0.25, white 1.03, saturation 2.0.
// ---- KeyboardRecipe.KeyboardDiffusionAmount (spec) 0x195f140d4: not read (no keyboard glass on macOS).

// ===================================================================================================
// 3. Which recipe carries which modifier (Schema type strings in __swift5_typeref, decoded symbolic references)
// ===================================================================================================
// 0x195fd4cf4 Regular:            RegularBase + RegularDiffusionAmount + GlassWindowActiveShadow + Inactive ...
// 0x195fd5602 Menu:               RegularBase + RegularDiffusionAmount + MenuRecipe.Inactive + Adaptivity ...
// 0x195fd5690 NotificationCenter: RegularBase + RegularDiffusionAmount + ShadowVibrancy ...
// 0x195fd5b3c Sidebar:            RegularBase + SidebarDiffusionAmount + Shadow + Planar + FaceEffect ...
// 0x195fd41b4 Clear:              ClearSpec + ClearDiffusionAmount + ApplyAccessibility ...
// 0x195fd4ade / 0x195fd4b64 Dock: ClearSpec + DockRecipe.Phone|Other (+ AppSwitcher) + ClearDiffusionAmount ...
// 0x195fd493a ControlCenter:      ClearSpec + IdiomModifier + ... + ClearDiffusionAmount (last)

// ===================================================================================================
// 4. Follow-ups (verify C2)
// ===================================================================================================
// - What the filter does with these inputs (blur fill, face, edge bleed, maxLuma / maxLumaSDR): QuartzCore-glassBackground-shader.c
// - Why Regular glass drops to backdrop scale 0.125 at a = 1: DesignLibrary-backdrop-scale.c
// - How a changed value reaches running apps: AppKit-Dock-glass-notification.c
// - Light Regular: maxLuminance 1 but maxLuminanceSDR 0.94 (0x3f70a3d7 @0x195f21600 in RegularBase.Base); the
//   filter uses the SDR value on an SDR display, so light glass is luminance-limited too.
