; AppKit 27.2.1 (26B131). Scroller knob while overscrolled.
; -[NSScrollView reflectScrolledClipView:]: knobProportion = max(visible - |stretch|, 0) / documentLength (vertical; horizontal has no max), value = (clip.y - doc.y)/(doc - visible) clamped 0..1 by NSScroller.
; -[NSScrollerImp _rectForPart:metrics:]: usable = length - 2*(trackEndInset + knobEndInset); knobLength = max(proportion*usable, knobMinLength); knobPos = insets + value*(usable - knobLength).
; knobMinLength: overlay 26 (regular and small), legacy 20. trackEndInset 3.

; ===== reflectScrolledClipView: (value / proportion block) =====
A464718 bl       0x190036570 ; _tileWithoutRecursing
A46471C mov      x0, x19
A464720 bl       0x19004f700 ; documentView
A464724 mov      x21, x0
A464728 mov      x0, x20
A46472C bl       0x1900455b0 ; bounds
A464730 mov.16b  v9, v0
A464734 mov.16b  v8, v1
A464738 str      d2, [sp, #0x18]
A46473C mov.16b  v13, v3
A464740 mov      x0, x20
A464744 bl       0x190011d50 ; _effectiveContentFrame
A464748 stp      d1, d0, [sp, #0x8]
A46474C mov.16b  v11, v2
A464750 mov.16b  v14, v3
A464754 mov      x0, x19
A464758 bl       0x1900346e0 ; _stretchAmount
A46475C mov.16b  v12, v0
A464760 mov      w8, #-0x60000000
A464764 ldr      w9, [x19, x23]
A464768 bics     wzr, w8, w9
A46476C b.ne     0x18a46481c
A464770 mov.16b  v10, v1
A464774 mov      x0, x20
A464778 bl       0x19005ec30 ; isFlipped
A46477C movi.2d  v0, #0000000000000000
A464780 fcmp     d14, d13
A464784 ldr      d1, [sp, #0x8]
A464788 fsub     d1, d8, d1
A46478C fsub     d2, d14, d13
A464790 fdiv     d1, d1, d2
A464794 fcsel    d1, d0, d1, eq
A464798 fmov     d2, #1.00000000
A46479C fsub     d2, d2, d1
A4647A0 cmp      w0, #0x0
A4647A4 fcsel    d15, d1, d2, ne
A4647A8 fabs     d1, d10
A4647AC fsub     d1, d13, d1
A4647B0 fmaxnm   d0, d1, d0
A4647B4 fdiv     d13, d0, d14
A4647B8 ldr      x0, [x19, x24]
A4647BC mov.16b  v0, v15
A4647C0 bl       0x190076910 ; setDoubleValue:
A4647C4 ldr      x0, [x19, x24]
A4647C8 mov.16b  v0, v13
A4647CC bl       0x190079b50 ; setKnobProportion:
A4647D0 mov      x0, x21
A4647D4 bl       0x190003fe0 ; _allowDynamicContentSizeChangesWhileScrolling
A4647D8 cbz      w0, 0x18a46481c
A4647DC ldr      x0, [x19, x24]
A4647E0 adrp     x8, 439353           ; 0x1f589d000
A4647E4 add      x1, x8, #0x413
A4647E8 bl       0x19010cea0
A4647EC tbz      w0, #0x0, 0x18a46481c
A4647F0 ldr      x0, [x19, x24]
A4647F4 adrp     x8, 439353           ; 0x1f589d000
A4647F8 add      x1, x8, #0x42c
A4647FC bl       0x19010cea0
A464800 tbz      w0, #0x0, 0x18a46481c
A464804 ldr      x0, [x19, x24]
A464808 mov.16b  v0, v15
A46480C bl       0x19002fe70 ; _setThumbingDoubleValue:
A464810 ldr      x0, [x19, x24]
A464814 mov.16b  v0, v13
A464818 bl       0x19002fe80 ; _setThumbingKnobProportion:
A46481C ldr      w8, [x19, x23]
A464820 mov      w9, #0x50000000
A464824 bics     wzr, w9, w8
A464828 b.ne     0x18a46486c
A46482C movi.2d  v0, #0000000000000000
A464830 ldp      d1, d3, [sp, #0x10]
A464834 fcmp     d11, d3
A464838 fsub     d1, d9, d1
A46483C fsub     d2, d11, d3
A464840 fdiv     d1, d1, d2
A464844 fcsel    d0, d0, d1, eq
A464848 fabs     d1, d12
A46484C fsub     d1, d3, d1
A464850 fdiv     d10, d1, d11
A464854 ldr      x0, [x19, x25]
A464858 bl       0x190076910 ; setDoubleValue:
A46485C ldr      x0, [x19, x25]
A464860 mov.16b  v0, v10
A464864 bl       0x190079b50 ; setKnobProportion:
A464868 ldr      w8, [x19, x23]
A46486C tbz      w8, #0x17, 0x18a464894
A464870 tbz      w8, #0x16, 0x18a464884
A464874 mov      x0, x19

; ===== -[NSScrollView _stretchAmount] =====
-[NSScrollView _stretchAmount]:
A464DDC pacibsp
A464DE0 sub      sp, sp, #0x80
A464DE4 stp      d15, d14, [sp, #0x20]
A464DE8 stp      d13, d12, [sp, #0x30]
A464DEC stp      d11, d10, [sp, #0x40]
A464DF0 stp      d9, d8, [sp, #0x50]
A464DF4 stp      x20, x19, [sp, #0x60]
A464DF8 stp      x29, x30, [sp, #0x70]
A464DFC add      x29, sp, #0x70
A464E00 adrp     x8, 397239           ; 0x1eb41b000
A464E04 ldrsw    x8, [x8, #0x9ac]
A464E08 add      x19, x0, x8
A464E0C ldr      x0, [x19]
A464E10 bl       0x1900455b0 ; bounds
A464E14 stp      d1, d0, [sp, #0x10]
A464E18 mov.16b  v10, v2
A464E1C mov.16b  v11, v3
A464E20 ldr      x0, [x19]
A464E24 bl       0x190011d50 ; _effectiveContentFrame
A464E28 mov.16b  v12, v0
A464E2C mov.16b  v13, v1
A464E30 mov.16b  v14, v2
A464E34 mov.16b  v15, v3
A464E38 ldr      x0, [x19]
A464E3C mov.16b  v2, v10
A464E40 mov.16b  v3, v11
A464E44 bl       0x19000b200 ; _constrainBoundsRectAndAlignIfNeeded:
A464E48 mov.16b  v8, v0
A464E4C mov.16b  v9, v1
A464E50 ldr      x0, [x19]
A464E54 bl       0x19005ec30 ; isFlipped
A464E58 stp      d8, d9, [sp]
A464E5C ldp      d1, d0, [sp, #0x10]
A464E60 mov.16b  v2, v10
A464E64 mov.16b  v3, v11

; ===== -[NSScrollerImp _rectForPart:metrics:] (head) =====
-[NSScrollerImp _rectForPart:metrics:]:
B03C0E0 sub      sp, sp, #0x80
B03C100 add      x29, sp, #0x70
B03C104 mov      x21, x3
B03C108 mov      x20, x2
B03C10C mov      x19, x0
B03C110 bl       0x190089d60 ; trackEndInset
B03C114 mov.16b  v8, v0
B03C118 mov      x0, x19
B03C11C bl       0x190060dd0 ; knobEndInset
B03C120 mov.16b  v13, v0
B03C124 cmp      x21, #0x2
B03C128 b.eq     0x18b03c180
B03C12C cmp      x21, #0x1
B03C130 b.eq     0x18b03c15c
B03C134 movi.2d  v11, #0000000000000000
B03C138 movi.2d  v9, #0000000000000000
B03C13C movi.2d  v10, #0000000000000000
B03C140 cbnz     x21, 0x18b03c1a4
B03C144 mov      x0, x19
B03C148 bl       0x19000baf0 ; _contractedTrackBoxWidth
B03C14C mov.16b  v10, v0
B03C150 mov      x0, x19
B03C154 bl       0x19000bb00 ; _contractedTrackWidth
B03C158 b        0x18b03c170
B03C15C mov      x0, x19
B03C160 bl       0x190089d20 ; trackBoxWidth
B03C164 mov.16b  v10, v0
B03C168 mov      x0, x19
B03C16C bl       0x190089f00 ; trackWidth
B03C170 mov.16b  v9, v0
B03C174 mov      x0, x19
B03C178 bl       0x190060e10 ; knobMinLength
B03C17C b        0x18b03c1a0
B03C180 mov      x0, x19
B03C184 bl       0x190013900 ; _expandedTrackBoxWidth
B03C188 mov.16b  v10, v0
B03C18C mov      x0, x19
B03C190 bl       0x190013910 ; _expandedTrackWidth
B03C194 mov.16b  v9, v0
B03C198 mov      x0, x19
B03C19C bl       0x1900138d0 ; _expandedKnobMinLength
B03C1A0 mov.16b  v11, v0
B03C1A4 mov      x0, x19
B03C1A8 bl       0x19004f860 ; doubleValue
B03C1AC sub      x8, x20, #0x1
B03C1B0 cmp      x8, #0x3
B03C1B4 b.hs     0x18b03c294
B03C1B8 mov.16b  v12, v0
B03C1BC str      d10, [sp, #0x8]
B03C1C0 ldrb     w8, [x19, #0x88]
B03C1C4 tbnz     w8, #0x0, 0x18b03c2f4
B03C1C8 ldr      d0, [x19, #0x78]
B03C1CC fadd     d15, d8, d13
B03C1D0 fmov     d14, #-2.00000000
B03C1D4 fmadd    d10, d15, d14, d0
B03C1D8 mov      x0, x19
B03C1DC bl       0x19005e120 ; isAvoidingOtherScrollerThumb
B03C1E0 movi.2d  v13, #0000000000000000
B03C1E4 cbz      w0, 0x18b03c1f8
B03C1E8 mov      x0, x19
B03C1EC bl       0x190060e20 ; knobOverlapEndInset
B03C1F0 mov.16b  v13, v0
B03C1F4 fmadd    d10, d0, d14, d10
B03C1F8 mov      x0, x19
B03C1FC bl       0x190060de0 ; knobInset
B03C200 mov.16b  v14, v0
B03C204 mov      x0, x19
B03C208 bl       0x190060e30 ; knobProportion
B03C20C fmul     d0, d10, d0
B03C210 fcmp     d0, d11
B03C214 fcsel    d0, d11, d0, mi
B03C218 str      d0, [x19, #0x18]
B03C21C mov      x0, x19
B03C220 bl       0x190089eb0 ; trackSideInset
B03C224 mov.16b  v11, v0
B03C228 mov      x0, x19
B03C22C bl       0x19008c6e0 ; userInterfaceLayoutDirection
B03C230 cbnz     x0, 0x18b03c240
B03C234 ldr      d0, [x19, #0x70]
B03C238 ldr      d1, [sp, #0x8]
B03C23C fsub     d11, d0, d1
B03C240 fadd     d0, d14, d11
B03C244 fadd     d1, d15, d13
B03C248 ldr      d11, [x19, #0x18]
B03C24C fsub     d2, d10, d11
B03C250 fmadd    d10, d12, d2, d1
B03C254 fmov     d1, #-2.00000000
B03C258 fmadd    d1, d14, d1, d9
B03C25C fmov     d2, #1.00000000
B03C260 fadd     d2, d0, d2
B03C264 fcmp     d14, #0.0
B03C268 fcsel    d0, d2, d0, ne
B03C26C fmov     d2, #-1.00000000
B03C270 fadd     d2, d1, d2
B03C274 fcsel    d9, d2, d1, ne
B03C278 cmp      x20, #0x3
B03C27C b.eq     0x18b03c3b4
B03C280 cmp      x20, #0x1
B03C284 b.ne     0x18b03c408

; ===== knobMinLength =====
-[NSRegularLegacyScrollerImp knobMinLength]:
A463360 fmov     d0, #20.00000000
A463364 ret
-[NSRegularOverlayScrollerImp knobMinLength]:
A463434 fmov     d0, #26.00000000
A463438 ret
-[NSSmallOverlayScrollerImp knobMinLength]:
A5B590C fmov     d0, #26.00000000
A5B5910 ret
