; DesignLibrary.framework 27.2.1 (26B131), arm64e, unslid shared-cache addresses (xcrun dyld_info -disassemble).
; Verify B2 excerpts: glass surface size classes, the content-lensing option, the Dock recipe branch.
; External stubs were resolved in a live process with tools/gotsym.c.

; ===== 1. Size classes -> reference dimension D (function 0x195F64144) =====================================
; 0x195e66a54 returns the configuration's GlassMaterialProvider.Size {dynamic(CGSize), minimum, medium, maximum, automatic}
; (16 byte payload + tag; tag 1 = one of the payload-less cases, index in the first word).
; table 0x195fb2068 (doubles): 48.0, 166.0, 201.3, 0.0  = minimum, medium, maximum, automatic
;   index 3 (automatic): flag 0x1000000 >> 24 = 1 -> "nil", the real shape metrics are used (minimumDistance of the shape)
;   dynamic(CGSize): D = min(width, height)
; D is stored as Environment.dimensions.minimumDistance AND .minimumDistanceOfLargestArea; every "normalized" recipe value
; is multiplied by it. So a glass with a fixed size class does NOT scale with its own height.
;   Dock.app: Configuration.dock + Size.medium  -> D = 166   (Dock 0x10011a534..0x10011a560, see Dock-glass-configuration.asm)
;   Spotlight field: _GlassVariant.regular.size(.large) -> Size.maximum -> D = 201.3
;   Notification Center: surfaceSize(.medium) -> D = 166
; Live check (tools/probe/lensprobe.swift, SwiftUI _Glass.dock.surfaceSize(.medium), 633x48 and 633x84): filter inputs
; InnerRefractionHeight 13.28 = 0.08*166, InnerRefractionAmount -29.88 = -0.18*166 at both heights; .automatic at 48: 3.84 / -8.64.
; _Glass.regular.surfaceSize(.large), 520x87: inner -60 / 20, outer 50.325 = 0.25*201.3 / 40.26 = 0.2*201.3, margin 70.455 = 0.35*201.3.

0x195F64638   sub      x8, x29, #0xe0
0x195F6463C   mov      x0, x28
0x195F64640   bl       0x195e66a54
0x195F64644   ldurb    w8, [x29, #-0xcf]
0x195F64648   cmp      w8, #0x1
0x195F6464C   b.ne     0x195f64664
0x195F64650   mov      w10, #0x1
0x195F64654   movi.2d  v8, #0000000000000000
0x195F64658   sub      x8, x29, #0x60
0x195F6465C   ldur     x23, [x8, #-0x100]
0x195F64660   b        0x195f646ac
0x195F64664   ldur     x8, [x29, #-0xe0]
0x195F64668   ldurb    w9, [x29, #-0xd0]
0x195F6466C   cmp      w9, #0x1
0x195F64670   sub      x9, x29, #0x60
0x195F64674   ldur     x23, [x9, #-0x100]
0x195F64678   b.ne     0x195f64698
0x195F6467C   adrp     x9, 78               ; 0x195fb2000
0x195F64680   add      x9, x9, #0x68
0x195F64684   ldr      d8, [x9, x8, lsl #3]
0x195F64688   lsl      w8, w8, #3
0x195F6468C   mov      w9, #0x1000000
0x195F64690   lsr      w10, w9, w8
0x195F64694   b        0x195f646ac
0x195F64698   mov      w10, #0x0
0x195F6469C   fmov     d0, x8
0x195F646A0   ldur     d1, [x29, #-0xd8]
0x195F646A4   fcmp     d1, d0
0x195F646A8   fcsel    d8, d1, d0, mi
0x195F646AC   sub      x8, x29, #0x68
0x195F646B0   ldur     x0, [x8, #-0x100]
0x195F646B4   sub      x8, x29, #0x78
0x195F646B8   ldur     x8, [x8, #-0x100]
0x195F646BC   sub      x9, x29, #0x70
0x195F646C0   ldur     x9, [x9, #-0x100]
0x195F646C4   movk     x9, #0xe3ba, lsl #48
0x195F646C8   sub      x11, x29, #0x70
0x195F646CC   stur     x9, [x11, #-0x100]
0x195F646D0   ldrsw    x8, [x8, #0x38]
0x195F646D4   add      x8, x0, x8
0x195F646D8   str      d8, [x8]
0x195F646DC   str      xzr, [x8, #0x8]
0x195F646E0   str      d8, [x8, #0x10]
0x195F646E4   strb     wzr, [x8, #0x18]

; ===== 2. DesignLibrary Size <-> SwiftUI _Glass.SurfaceSize (inside 0x195E67570) ============================
; stubs: 0x198121d30 = SwiftUI._Glass.SurfaceSize.small, 0x198121d40 = .medium, 0x198121d20 = .large, 0x198121d50 = .automatic
; (SwiftUICore getters store 1, 2, 3, 0: 0x190E848DC..0x190E84904). minimum -> small, medium -> medium, maximum -> large.

0x195E69164   ldrb     w8, [x25, #0x20]
0x195E69168   cmp      w8, #0x1
0x195E6916C   sub      x8, x29, #0x18
0x195E69170   ldur     x20, [x8, #-0x100]
0x195E69174   b.ne     0x195e691bc
0x195E69178   ldp      x8, x9, [x25, #0x10]
0x195E6917C   mov      w10, #0x2
0x195E69180   cmp      x10, x8
0x195E69184   ngcs     xzr, x9
0x195E69188   b.lo     0x195e69238
0x195E6918C   and      w8, w8, #0x3
0x195E69190   cmp      w8, #0x1
0x195E69194   b.gt     0x195e691a8
0x195E69198   cbnz     w8, 0x195e6a334
0x195E6919C   mov      x8, x27
0x195E691A0   bl       0x198121d30
0x195E691A4   b        0x195e691c4
0x195E691A8   cmp      w8, #0x2
0x195E691AC   b.ne     0x195e691bc
0x195E691B0   mov      x8, x27
0x195E691B4   bl       0x198121d20
0x195E691B8   b        0x195e691c4
0x195E691BC   mov      x8, x27
0x195E691C0   bl       0x198121d50
0x195E6A334   mov      x8, x27
0x195E6A338   bl       0x198121d40
0x195E6A33C   b        0x195e691c4

; ===== 3. Options.contentLensing -> _Glass.ContentEffect.lense (same function) ==============================
; GlassMaterialProvider.Options.contentLensing.getter 0x195E79964: rawValue 1.  ContentEffect.none/clip/lense getters
; 0x195E59CC8/CD4/CE0 store 1/2/3 (0 = automatic).  SwiftUI.Material._GlassVariant.contentLensing(_:) 0x19B811534 only
; inserts/removes that option bit.  Here: options at config+0x28; bit 0 set and the stored content effect still automatic
; (w8 == 0)  ->  stub 0x198121e40 = SwiftUI._Glass.ContentEffect.lense is written into the _Glass value.

0x195E69AC4   ldr      x21, [x23, #0x28]
0x195E69AC8   tst      x21, #0x180
0x195E69ACC   b.eq     0x195e69ae8
0x195E69AD0   tst      x21, #0x100
0x195E69AD4   mov      w8, #0x1
0x195E69AD8   cinc     w8, w8, ne
0x195E69ADC   sub      x9, x29, #0x120
0x195E69AE0   ldur     x9, [x9, #-0x100]
0x195E69AE4   strb     w8, [x25, x9]
0x195E69AE8   ldur     x22, [x29, #-0x90]
0x195E69AEC   ldur     x24, [x29, #-0xb0]
0x195E69AF0   tbnz     w21, #0x0, 0x195e69b0c
0x195E69AF4   bl       0x198105040
0x195E69AF8   mov      x0, x20
0x195E69AFC   bl       0x198104b20
0x195E69B00   mov      x0, x19
0x195E69B04   bl       0x198105040
0x195E69B08   b        0x195e69b74
0x195E69B0C   bl       0x198105040
0x195E69B10   mov      x0, x20
0x195E69B14   bl       0x198104b20
0x195E69B18   mov      x0, x19
0x195E69B1C   bl       0x198105040
0x195E69B20   sub      x8, x29, #0x40
0x195E69B24   ldur     w8, [x8, #-0x100]
0x195E69B28   cbnz     w8, 0x195e69b74
0x195E69B2C   sub      x8, x29, #0x8
0x195E69B30   ldur     x19, [x8, #-0x100]
0x195E69B34   movk     x19, #0xefda, lsl #48
0x195E69B38   sub      x8, x29, #0x138
0x195E69B3C   ldur     x20, [x8, #-0x100]
0x195E69B40   mov      x8, x20
0x195E69B44   bl       0x198121e40
0x195E69B48   sub      x8, x29, #0x48
0x195E69B4C   ldur     x8, [x8, #-0x100]
0x195E69B50   ldrsw    x8, [x8, #0x1c]
0x195E69B54   add      x0, x25, x8
0x195E69B58   mov      x1, x20
0x195E69B5C   sub      x8, x29, #0x60
0x195E69B60   ldur     x2, [x8, #-0x100]
0x195E69B64   sub      x8, x29, #0x58
0x195E69B68   ldur     x8, [x8, #-0x100]
0x195E69B6C   blraa    x8, x19
0x195E69B70   ldr      x21, [x23, #0x28]
0x195E69B74   stur     x21, [x29, #-0x88]

; ===== 4. BaseSpec (0x195EF8BA4): contentLensing parameters, only for ResolvedContentEffect.lense ===========
; w8 = context.contentEffect (none 0, clip 1, lense 2); w25 = (w8 < 2) = "not lense".
; lense: s10 = -5.0 (aberrationAmount), d12 = 0x3FF921FB54442D18 = pi/2 (aberrationAngle), s11 = 1.0 (edge opacity end);
; otherwise all three are 0.

0x195EF8E60   mov      x0, #0x0
0x195EF8E64   bl       0x195ed0900
0x195EF8E68   fmov     s0, #-5.00000000
0x195EF8E6C   ldrsw    x8, [x0, #0x2c]
0x195EF8E70   add      x8, x20, x8
0x195EF8E74   ldrb     w8, [x8]
0x195EF8E78   cmp      w8, #0x2
0x195EF8E7C   cset     w25, lo
0x195EF8E80   movi.2d  v1, #0000000000000000
0x195EF8E84   fcsel    s10, s1, s0, lo
0x195EF8E88   mov      x8, #0x2d18
0x195EF8E8C   movk     x8, #0x5444, lsl #16
0x195EF8E90   movk     x8, #0x21fb, lsl #32
0x195EF8E94   movk     x8, #0x3ff9, lsl #48
0x195EF8E98   fmov     d0, x8
0x195EF8E9C   movi.2d  v2, #0000000000000000
0x195EF8EA0   fcsel    d12, d2, d0, lo
0x195EF8EA4   fmov     s0, #1.00000000
0x195EF8EA8   fcsel    s11, s1, s0, lo
; ...
; Spec.contentLensing (Parameters.Lensing at spec+0x650): 4 floats from 0x195faa580 = { 16.0, -16.0, -3.3, 6.6 }
;   = refractionHeight, refractionAmount, refractionInset, aberrationHeight, zeroed when w25 is set (not lense);
; +0x660 aberrationAmount = s10, +0x664 aberrationInset = 0, +0x668 aberrationAngle = d12, +0x670 edgeDistances (0, 0),
; +0x678 edgeOpacities (0, s11).  Live dump of the CAFilter glassForeground (SwiftUI probe, .lense): RefractionAmount -16,
; RefractionHeight 16, RefractionOffset -3.3, AberrationAmount -5, AberrationHeight 6.6, AberrationAngle 1.5708, EdgeOpacityEnd 1.

0x195EF91F4   dup.4h   v0, w25
0x195EF91F8   ushll.4s v0, v0, #0x0
0x195EF91FC   shl.4s   v0, v0, #0x1f
0x195EF9200   cmge.4s  v0, v0, #0
0x195EF9204   adrp     x8, 177              ; 0x195faa000
0x195EF9208   ldr      q1, [x8, #0x580]
0x195EF920C   and.16b  v0, v0, v1
0x195EF9210   str      q0, [x21, #0x650]
0x195EF9214   str      s10, [x21, #0x660]
0x195EF9218   str      wzr, [x21, #0x664]
0x195EF921C   str      d12, [x21, #0x668]
0x195EF9220   movi     d0, #0000000000000000
0x195EF9224   str      d0, [x21, #0x670]
0x195EF9228   str      wzr, [x21, #0x678]
0x195EF922C   str      s11, [x21, #0x67c]

; ===== 5. DockRecipe.Other (0x195F0DCBC): which refraction the Dock recipe has ==============================
; x27 = (environment.colorScheme == .dark)   [SwiftUI.ColorScheme.dark, == via 0x1980ff320]
; x20 = isV2(context) 0x195ed53f0.   dark && v2 (this OS): blur 1.5 (0x3fc00000), refraction.normalizedInnerAmount -0.18,
; normalizedInnerHeight 0.08, outer 0.42 / 0.13 with outerOpacity 0.2 (filter inputs come out as outer amount/height 0);
; !v2: blur ParameterScale 48..160 -> 32.., inner -0.42 / 0.127.  (Constants: see recipes-annotated.c, DockRecipe.Other.)

0x195F0DE08   bl       0x195e7d9c0
0x195F0DE0C   mov      x3, x0
0x195F0DE10   add      x0, x24, x27
0x195F0DE14   mov      x1, x26
0x195F0DE18   mov      x2, x20
0x195F0DE1C   bl       0x1980ff320
0x195F0DE20   mov      x27, x0
0x195F0DE24   ldr      x8, [x25, #0x8]!
0x195F0DE28   mov      x0, x26
0x195F0DE2C   mov      x1, x20
0x195F0DE30   mov      x17, x25
0x195F0DE34   movk     x17, #0x4f8, lsl #48
0x195F0DE38   blraa    x8, x17
0x195F0DE3C   mov      x20, x24
0x195F0DE40   bl       0x195ed53f0
0x195F0DE44   mov      x20, x0
0x195F0DE48   add      x24, x19, #0x168
0x195F0DE4C   ldp      x0, x1, [x19, #0x168]
0x195F0DE50   ldp      x2, x3, [x19, #0x178]
0x195F0DE54   ldr      x4, [x19, #0x188]
0x195F0DE58   ldrb     w6, [x19, #0x191]
0x195F0DE5C   ldrb     w5, [x19, #0x190]
0x195F0DE60   bl       0x195eda468
0x195F0DE64   tbz      w27, #0x0, 0x195f0dfe0
0x195F0DE68   tbz      w20, #0x0, 0x195f0e114
0x195F0DE6C   mov      w8, #0x3fc00000
0x195F0DE70   str      x8, [x19, #0x168]
0x195F0DE74   movi.2d  v0, #0000000000000000
0x195F0DE78   stp      q0, q0, [x19, #0x170]
