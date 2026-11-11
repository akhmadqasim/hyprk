; AppKit 27.2.1 (26B131) arm64e, dyld_info -disassemble. Scroll momentum. Selector stubs resolved with tools/probe/momentum.m (stub).
; Summary: default calculator = Cates (NSScrollBehaviorAnimationType 0). k = NSScrollingBehaviorMomentumConstant = 1000.
;   T = cbrt(|v0|/(4k)); x(t) = x0 + sign(v0)*k*(T^4 - (T-t)^4); v(t) = 4k(T-t)^3. Edge: stretch(tau) = 0.31*v_e*tau*exp(-20*tau/1.6).
;   Bas (type 1): factor 0.998/ms. Velocity = EMA(alpha 0.2) of delta/dt, reset if dt > 0.2 s or sign flips, dt < 2 ms ignored.

; ===== +[_NSScrollingMomentumCalculator allocWithZone:] (class cluster) =====
+[_NSScrollingMomentumCalculator allocWithZone:]:
ACFD73C pacibsp
ACFD740 sub      sp, sp, #0xc0
ACFD744 stp      x20, x19, [sp, #0xa0]
ACFD748 stp      x29, x30, [sp, #0xb0]
ACFD74C add      x29, sp, #0xb0
ACFD750 mov      x19, x2
ACFD754 mov      x20, x0
ACFD758 adrp     x8, 349391           ; 0x1e01cc000
ACFD75C ldr      x8, [x8, #0x7f0]
ACFD760 ldr      x8, [x8]
ACFD764 stur     x8, [x29, #-0x18]
ACFD768 adrp     x8, 350838           ; 0x1e0773000
ACFD76C ldr      x0, [x8, #0xef0]     ; _OBJC_CLASS_$__NSScrollingMomentumCalculator@got
ACFD770 bl       0x19010ceb0
ACFD774 cmp      x20, x0
ACFD778 b.eq     0x18acfd7c4
ACFD77C adrp     x8, 350829           ; 0x1e076a000
ACFD780 ldr      x8, [x8, #0xfc8]
ACFD784 stp      x20, x8, [sp, #0x10]
ACFD788 adrp     x8, 432950           ; 0x1f4833000
ACFD78C add      x1, x8, #0x1d0
ACFD790 add      x0, sp, #0x10
ACFD794 mov      x2, x19
ACFD798 bl       0x19010ce60
ACFD79C adrp     x8, 349391           ; 0x1e01cc000
ACFD7A0 ldr      x8, [x8, #0x7f0]
ACFD7A4 ldr      x8, [x8]
ACFD7A8 ldur     x9, [x29, #-0x18]
ACFD7AC cmp      x8, x9
ACFD7B0 b.ne     0x18acfd8f4
ACFD7B4 ldp      x29, x30, [sp, #0xb0]
ACFD7B8 ldp      x20, x19, [sp, #0xa0]
ACFD7BC add      sp, sp, #0xc0
ACFD7C0 retab
ACFD7C4 adrp     x3, 404443           ; 0x1ed8d8000
ACFD7C8 add      x3, x3, #0xb68       ; __MergedGlobals
ACFD7CC ldarb    w8, [x3]
ACFD7D0 cmp      w8, #0x1
ACFD7D4 b.ne     0x18acfd7fc
ACFD7D8 adrp     x8, 404443           ; 0x1ed8d8000
ACFD7DC add      x8, x8, #0xb70
ACFD7E0 ldar     x0, [x8]
ACFD7E4 cbz      x0, 0x18acfd818
ACFD7E8 cmp      x0, #0x1
ACFD7EC b.ne     0x18acfd8f8
ACFD7F0 adrp     x8, 350838           ; 0x1e0773000
ACFD7F4 add      x8, x8, #0xee8       ; (null)@got
ACFD7F8 b        0x18acfd820
ACFD7FC adrp     x0, 359372           ; 0x1e28c9000
ACFD800 add      x0, x0, #0xd00
ACFD804 add      x2, x3, #0x8
ACFD808 mov      x1, #0x0
ACFD80C mov      x4, #0x0
ACFD810 bl       __NSGetNSIntegerAppConfig
ACFD814 cbnz     x0, 0x18acfd7e8
ACFD818 adrp     x8, 350838           ; 0x1e0773000
ACFD81C add      x8, x8, #0xef8       ; (null)@got
ACFD820 ldr      x0, [x8]
ACFD824 bl       0x19010ceb0
ACFD828 cbz      x0, 0x18acfd868
ACFD82C ldur     x8, [x29, #-0x18]
ACFD830 adrp     x9, 349391           ; 0x1e01cc000
ACFD834 ldr      x9, [x9, #0x7f0]
ACFD838 ldr      x9, [x9]

; ===== Cates: calculateDestination, cached properties, position =====
-[_NSScrollingMomentumCatesCalculator calculateDestination]:
ACFE284 pacibsp
ACFE288 sub      sp, sp, #0xc0
ACFE28C stp      d15, d14, [sp, #0x50]
ACFE290 stp      d13, d12, [sp, #0x60]
ACFE294 stp      d11, d10, [sp, #0x70]
ACFE298 stp      d9, d8, [sp, #0x80]
ACFE29C stp      x22, x21, [sp, #0x90]
ACFE2A0 stp      x20, x19, [sp, #0xa0]
ACFE2A4 stp      x29, x30, [sp, #0xb0]
ACFE2A8 add      x29, sp, #0xb0
ACFE2AC mov      x19, x0
ACFE2B0 adrp     x8, 404442           ; 0x1ed8d8000
ACFE2B4 add      x8, x8, #0xb69
ACFE2B8 ldarb    w8, [x8]
ACFE2BC cmp      w8, #0x2
ACFE2C0 b.eq     0x18acfe2f8
ACFE2C4 mov      x20, x1
ACFE2C8 cbz      w8, 0x18acfe6d8
ACFE2CC mov      x0, x19
ACFE2D0 bl       0x19010ce70
ACFE2D4 bl       0x1901091c0
ACFE2D8 mov      x21, x0
ACFE2DC mov      x0, x20
ACFE2E0 bl       0x190109210
ACFE2E4 stp      x19, x0, [sp, #0x8]
ACFE2E8 str      x21, [sp]
ACFE2EC adrp     x0, 359295           ; 0x1e287d000
ACFE2F0 add      x0, x0, #0x4a0
ACFE2F4 bl       0x190108fb0
ACFE2F8 add      x0, x19, #0x8
ACFE2FC bl       0x19010d0b0
ACFE300 ldr      d8, [x19, #0x90]
ACFE304 fcmp     d8, #0.0
ACFE308 b.hi     0x18acfe330
ACFE30C adrp     x2, 404442           ; 0x1ed8d8000
ACFE310 add      x2, x2, #0xb6a
ACFE314 ldarb    w8, [x2]
ACFE318 cmp      w8, #0x1
ACFE31C b.ne     0x18acfe6fc
ACFE320 adrp     x8, 404442           ; 0x1ed8d8000
ACFE324 add      x8, x8, #0xb78
ACFE328 ldar     x8, [x8]
ACFE32C fmov     d8, x8
ACFE330 mov      x20, x19
ACFE334 ldr      d0, [x20, #0x20]!
ACFE338 mov      x8, #-0x4010000000000000
ACFE33C str      x8, [x20, #0xb8]
ACFE340 fmov     d1, #1.00000000
ACFE344 movi.2d  v2, #0xffffffffffffffff
ACFE348 fneg.2d  v2, v2
ACFE34C mov.16b  v3, v2
ACFE350 bsl.16b  v3, v1, v0
ACFE354 str      q3, [sp, #0x40]
ACFE358 ldr      d3, [x20, #0x8]
ACFE35C bif.16b  v1, v3, v2
ACFE360 stp      q3, q1, [sp, #0x20]
ACFE364 ldur     d10, [x20, #-0x10]
ACFE368 fabs     d0, d0
ACFE36C fmov     d1, #4.00000000
ACFE370 fmul     d14, d8, d1
ACFE374 fdiv     d0, d0, d14
ACFE378 adrp     x8, 2801             ; 0x18b7ef000
ACFE37C ldr      d9, [x8, #0xb48]
ACFE380 mov.16b  v1, v9
ACFE384 bl       0x1900fa180
ACFE388 fmul     d0, d8, d0
ACFE38C ldr      q1, [sp, #0x40]
ACFE390 fmadd    d0, d1, d0, d10
ACFE394 ldrb     w8, [x20, #0x78]
ACFE398 str      d14, [sp, #0x18]
ACFE39C tbnz     w8, #0x0, 0x18acfe3d0
ACFE3A0 mov      x21, x19
ACFE3A4 str      d0, [x21, #0xc8]!
ACFE3A8 ldur     d10, [x21, #-0xb0]
ACFE3AC ldr      q0, [sp, #0x20]
ACFE3B0 fabs     d0, d0
ACFE3B4 fdiv     d0, d0, d14
ACFE3B8 mov.16b  v1, v9
ACFE3BC bl       0x1900fa180
ACFE3C0 fmul     d0, d8, d0
ACFE3C4 ldr      q1, [sp, #0x30]
ACFE3C8 fmadd    d0, d1, d0, d10
ACFE3CC b        0x18acfe458
ACFE3D0 frinta   d1, d0
ACFE3D4 fabd     d2, d0, d1
ACFE3D8 fmov     d10, #0.12500000
ACFE3DC fcmp     d2, d10
ACFE3E0 fcsel    d0, d1, d0, mi
ACFE3E4 fmov     d11, #-0.50000000
ACFE3E8 fadd     d1, d0, d11
ACFE3EC frintp   d1, d1
ACFE3F0 fmov     d12, #0.50000000
ACFE3F4 fadd     d2, d0, d12
ACFE3F8 frintm   d2, d2
ACFE3FC fcmp     d0, #0.0
ACFE400 fcsel    d0, d1, d2, gt
ACFE404 mov      x21, x19
ACFE408 str      d0, [x21, #0xc8]!
ACFE40C ldur     d13, [x21, #-0xb0]
ACFE410 ldr      q0, [sp, #0x20]
ACFE414 fabs     d0, d0
ACFE418 fdiv     d0, d0, d14
ACFE41C mov.16b  v1, v9
ACFE420 bl       0x1900fa180
ACFE424 fmul     d0, d8, d0
ACFE428 ldr      q1, [sp, #0x30]
ACFE42C fmadd    d0, d1, d0, d13
ACFE430 frinta   d1, d0
ACFE434 fabd     d2, d0, d1
ACFE438 fcmp     d2, d10
ACFE43C fcsel    d0, d1, d0, mi
ACFE440 fadd     d1, d0, d11
ACFE444 frintp   d1, d1
ACFE448 fadd     d2, d0, d12
ACFE44C frintm   d2, d2
ACFE450 fcmp     d0, #0.0
ACFE454 fcsel    d0, d1, d2, gt
ACFE458 str      d0, [x19, #0xd0]
ACFE45C mov      x0, x19
ACFE460 bl       __catesCalculateCachedProperties
ACFE464 ldp      d13, d14, [x19, #0xc8]
ACFE468 ldp      d15, d9, [x19, #0x70]
ACFE46C ldp      d0, d1, [x19, #0x40]
ACFE470 ldp      d2, d3, [x19, #0x50]
ACFE474 ldp      d10, d11, [x19, #0x60]
ACFE478 mov.16b  v4, v10
ACFE47C mov.16b  v5, v11
ACFE480 mov.16b  v6, v15
ACFE484 mov.16b  v7, v9
ACFE488 bl       __NSExpandedDocFrame
ACFE48C mov.16b  v4, v0
ACFE490 mov.16b  v12, v3
ACFE494 stp      d10, d11, [sp]
ACFE498 mov.16b  v10, v1
ACFE49C mov.16b  v0, v13
ACFE4A0 mov.16b  v13, v2
ACFE4A4 mov.16b  v1, v14
ACFE4A8 mov.16b  v2, v15
ACFE4AC mov.16b  v3, v9
ACFE4B0 mov.16b  v9, v4
ACFE4B4 mov.16b  v5, v10
ACFE4B8 mov.16b  v6, v13
ACFE4BC mov.16b  v7, v12
ACFE4C0 mov      w0, #0x1
ACFE4C4 bl       __NSStretchOfClipBoundsForDocumentFrame
ACFE4C8 fabs     d2, d0
ACFE4CC str      xzr, [x19, #0x100]
ACFE4D0 ldr      d3, [x19, #0x80]
ACFE4D4 fcmp     d2, d3
ACFE4D8 b.pl     0x18acfe4ec
ACFE4DC fabs     d2, d1
ACFE4E0 ldr      d3, [x19, #0x88]
ACFE4E4 fcmp     d2, d3
ACFE4E8 b.mi     0x18acfe530
ACFE4EC ldp      d3, d2, [x19, #0xb0]
ACFE4F0 fcmp     d2, d3
ACFE4F4 b.ge     0x18acfe544
ACFE4F8 ldp      d3, d2, [x19, #0xc8]
ACFE4FC fsub     d2, d2, d1
ACFE500 str      d2, [x19, #0xd0]
ACFE504 movi.2d  v1, #0000000000000000
ACFE508 mov      w8, #0x1
ACFE50C fcmp     d0, #0.0
ACFE510 ldr      d11, [sp, #0x18]
ACFE514 b.mi     0x18acfe568
ACFE518 b.gt     0x18acfe568
ACFE51C fsub     d0, d3, d0
ACFE520 fsub     d1, d2, d1
ACFE524 stp      d0, d1, [x19, #0x30]
ACFE528 mov      x0, x19
ACFE52C bl       __catesCalculateCachedProperties
ACFE530 ldr      q0, [x21]
ACFE534 str      q0, [x19, #0x30]
ACFE538 mov      x8, #-0x4010000000000000
ACFE53C str      x8, [x19, #0xd8]
ACFE540 b        0x18acfe660
ACFE544 ldp      d3, d2, [x19, #0xc8]
ACFE548 fsub     d3, d3, d0
ACFE54C str      d3, [x19, #0xc8]
ACFE550 movi.2d  v0, #0000000000000000
ACFE554 mov      w8, #0x2
ACFE558 fcmp     d1, #0.0
ACFE55C ldr      d11, [sp, #0x18]
ACFE560 b.eq     0x18acfe51c
ACFE564 b.vs     0x18acfe51c
ACFE568 str      x8, [x19, #0x100]
ACFE56C fsub     d0, d3, d0
ACFE570 mov      x22, x19
ACFE574 str      d0, [x22, #0x30]!
ACFE578 fsub     d0, d2, d1
ACFE57C str      d0, [x19, #0x38]
ACFE580 mov      x0, x19
ACFE584 bl       __catesCalculateCachedProperties
ACFE588 ldp      d0, d1, [x19, #0x10]
ACFE58C ldp      d2, d3, [x19, #0x70]
ACFE590 ldp      d4, d5, [x19, #0x60]
ACFE594 stp      d4, d5, [sp]
ACFE598 mov.16b  v4, v9
ACFE59C mov.16b  v5, v10
ACFE5A0 mov.16b  v6, v13
ACFE5A4 mov.16b  v7, v12
ACFE5A8 mov      w0, #0x1
ACFE5AC bl       __NSStretchOfClipBoundsForDocumentFrame
ACFE5B0 mov.16b  v9, v0
ACFE5B4 mov.16b  v10, v1
ACFE5B8 adrp     x8, 349299           ; 0x1e0171000
ACFE5BC ldr      x8, [x8, #0x978]
ACFE5C0 ldp      d0, d1, [x8]
ACFE5C4 mov.16b  v2, v9
ACFE5C8 mov.16b  v3, v10
ACFE5CC bl       0x190108df0
ACFE5D0 tbz      w0, #0x0, 0x18acfe640
ACFE5D4 ldr      d9, [x19, #0xc0]
ACFE5D8 ldp      d0, d1, [x19, #0x10]
ACFE5DC ldp      d2, d3, [x19, #0x30]
ACFE5E0 fabd     d0, d2, d0
ACFE5E4 fabd     d1, d3, d1
ACFE5E8 bl       0x19010c8e0
ACFE5EC fsub     d0, d9, d0
ACFE5F0 fdiv     d0, d0, d8
ACFE5F4 ldr      d8, [x19, #0xa8]
ACFE5F8 fmov     d1, #0.25000000
ACFE5FC bl       0x1900fa180
ACFE600 fsub     d1, d8, d0
ACFE604 fsub     d0, d8, d1
ACFE608 str      d1, [x19, #0xd8]
ACFE60C fmov     d1, #3.00000000
ACFE610 bl       0x1900fa180
ACFE614 fmul     d0, d11, d0
ACFE618 ldp      d1, d2, [x19, #0xb0]
ACFE61C fdiv     d1, d1, d9
ACFE620 fmul     d1, d1, d0
ACFE624 fdiv     d2, d2, d9
ACFE628 fmul     d0, d2, d0
ACFE62C ldp      q2, q3, [sp, #0x30]
ACFE630 fmul     d1, d3, d1
ACFE634 fmul     d0, d2, d0
ACFE638 stp      d1, d0, [x19, #0xf0]
ACFE63C b        0x18acfe658
ACFE640 stp      d9, d10, [x19, #0xe0]
ACFE644 str      xzr, [x19, #0xd8]
ACFE648 ldr      q0, [x20]
ACFE64C str      q0, [x19, #0xf0]
ACFE650 ldr      q0, [x22]
ACFE654 str      q0, [x21]
ACFE658 mov      x0, x19
ACFE65C bl       __catesCalculateCachedProperties
ACFE660 ldr      d0, [x19, #0x90]
ACFE664 fcmp     d0, #0.0
ACFE668 b.hi     0x18acfe6a0
ACFE66C ldr      d0, [x19, #0xa8]
ACFE670 fmov     d1, #2.00000000
ACFE674 fcmp     d0, d1
ACFE678 b.le     0x18acfe6a0
ACFE67C ldr      d0, [x19, #0xd8]
ACFE680 fcmp     d0, #0.0
ACFE684 b.pl     0x18acfe6a0
ACFE688 fmov     d0, #2.00000000
ACFE68C mov      x0, x19
ACFE690 bl       __catesPositionAfterDuration
ACFE694 stp      d0, d1, [x19, #0x30]
ACFE698 mov      x0, x19
ACFE69C bl       __catesCalculateToReachDestination
ACFE6A0 add      x0, x19, #0x8
ACFE6A4 ldp      x29, x30, [sp, #0xb0]
ACFE6A8 ldp      x20, x19, [sp, #0xa0]
ACFE6AC ldp      x22, x21, [sp, #0x90]
ACFE6B0 ldp      d9, d8, [sp, #0x80]
ACFE6B4 ldp      d11, d10, [sp, #0x70]
ACFE6B8 ldp      d13, d12, [sp, #0x60]
ACFE6BC ldp      d15, d14, [sp, #0x50]
ACFE6C0 add      sp, sp, #0xc0
ACFE6C4 autibsp
ACFE6C8 eor      x16, x30, x30, lsl #1
ACFE6CC tbz      x16, #0x3e, 0x18acfe6d4
ACFE6D0 brk      #0xc471
ACFE6D4 b        0x19010d0d0
ACFE6D8 adrp     x0, 359295           ; 0x1e287d000
ACFE6DC add      x0, x0, #0x620
ACFE6E0 adrp     x2, 404442           ; 0x1ed8d8000
ACFE6E4 add      x2, x2, #0xb69
ACFE6E8 mov      w1, #0x0
ACFE6EC mov      x3, #0x0
ACFE6F0 bl       __NSGetBoolAppConfig
ACFE6F4 cbnz     w0, 0x18acfe2cc
ACFE6F8 b        0x18acfe2f8
ACFE6FC adrp     x0, 359371           ; 0x1e28c9000
ACFE700 add      x0, x0, #0xd20
ACFE704 adrp     x8, 2799             ; 0x18b7ed000
ACFE708 ldr      d0, [x8, #0x5a0]
ACFE70C add      x1, x2, #0xe
ACFE710 mov      x3, #0x0
ACFE714 bl       __NSGetCGFloatAppConfig
ACFE718 mov.16b  v8, v0
ACFE71C b        0x18acfe330
__catesCalculateCachedProperties:
ACFE720 pacibsp
ACFE724 stp      d15, d14, [sp, #-0x60]!
ACFE728 stp      d13, d12, [sp, #0x10]
ACFE72C stp      d11, d10, [sp, #0x20]
ACFE730 stp      d9, d8, [sp, #0x30]
ACFE734 stp      x20, x19, [sp, #0x40]
ACFE738 stp      x29, x30, [sp, #0x50]
ACFE73C add      x29, sp, #0x50
ACFE740 mov      x19, x0
ACFE744 add      x0, x0, #0x8
ACFE748 bl       0x19010d0a0
ACFE74C ldr      d8, [x19, #0x90]
ACFE750 fcmp     d8, #0.0
ACFE754 b.hi     0x18acfe77c
ACFE758 adrp     x2, 404442           ; 0x1ed8d8000
ACFE75C add      x2, x2, #0xb6a
ACFE760 ldarb    w8, [x2]
ACFE764 cmp      w8, #0x1
ACFE768 b.ne     0x18acfe880
ACFE76C adrp     x8, 404442           ; 0x1ed8d8000
ACFE770 add      x8, x8, #0xb78
ACFE774 ldar     x8, [x8]
ACFE778 fmov     d8, x8
ACFE77C ldur     q0, [x19, #0xc8]
ACFE780 ldr      q1, [x19, #0x10]
ACFE784 fabd.2d  v0, v1, v0
ACFE788 str      q0, [x19, #0xb0]
ACFE78C mov      d1, v0[1]
ACFE790 bl       0x19010c8e0
ACFE794 fdiv     d2, d0, d8
ACFE798 str      d0, [x19, #0xc0]
ACFE79C fmov     d1, #0.25000000
ACFE7A0 mov.16b  v0, v2
ACFE7A4 bl       0x1900fa180
ACFE7A8 str      d0, [x19, #0xa8]
ACFE7AC add      x0, x19, #0x8
ACFE7B0 bl       0x19010d0a0
ACFE7B4 ldr      d0, [x19, #0xd8]
ACFE7B8 fcmp     d0, #0.0
ACFE7BC b.ge     0x18acfe7c8
ACFE7C0 ldr      d0, [x19, #0xa8]
ACFE7C4 b        0x18acfe860
ACFE7C8 movi.2d  v11, #0000000000000000
ACFE7CC fmov     d0, #1.50000000
ACFE7D0 fmov     d12, #0.50000000
ACFE7D4 adrp     x8, 2799             ; 0x18b7ed000
ACFE7D8 ldr      d13, [x8, #0xaa8]
ACFE7DC fmov     d14, #1.50000000
ACFE7E0 fmul     d0, d0, d12
ACFE7E4 fadd     d8, d0, d11
ACFE7E8 ldr      d9, [x19, #0xe0]
ACFE7EC ldr      d10, [x19, #0xf0]
ACFE7F0 bl       _NSScrollViewRubberbandStiffness
ACFE7F4 mov.16b  v3, v0
ACFE7F8 mov.16b  v0, v9
ACFE7FC mov.16b  v1, v10
ACFE800 mov.16b  v2, v8
ACFE804 bl       __NSElasticDeltaForTimeDelta2
ACFE808 fabs     d15, d0
ACFE80C ldr      d9, [x19, #0xe8]
ACFE810 ldr      d10, [x19, #0xf8]
ACFE814 bl       _NSScrollViewRubberbandStiffness
ACFE818 mov.16b  v3, v0
ACFE81C mov.16b  v0, v9
ACFE820 mov.16b  v1, v10
ACFE824 mov.16b  v2, v8
ACFE828 bl       __NSElasticDeltaForTimeDelta2
ACFE82C fabs     d0, d0
ACFE830 fcmp     d15, d12
ACFE834 cset     w8, mi
ACFE838 fcmp     d0, d12
ACFE83C cset     w9, mi
ACFE840 tst      w8, w9
ACFE844 fcsel    d11, d11, d8, ne
ACFE848 fcsel    d14, d8, d14, ne
ACFE84C fsub     d0, d14, d11
ACFE850 fcmp     d0, d13
ACFE854 b.gt     0x18acfe7e0
ACFE858 ldr      d0, [x19, #0xd8]
ACFE85C fadd     d0, d11, d0
ACFE860 str      d0, [x19, #0xa0]
ACFE864 ldp      x29, x30, [sp, #0x50]
ACFE868 ldp      x20, x19, [sp, #0x40]
ACFE86C ldp      d9, d8, [sp, #0x30]
ACFE870 ldp      d11, d10, [sp, #0x20]
ACFE874 ldp      d13, d12, [sp, #0x10]
ACFE878 ldp      d15, d14, [sp], #0x60
ACFE87C retab
ACFE880 adrp     x0, 359371           ; 0x1e28c9000
ACFE884 add      x0, x0, #0xd20
ACFE888 adrp     x8, 2799             ; 0x18b7ed000
ACFE88C ldr      d0, [x8, #0x5a0]
ACFE890 add      x1, x2, #0xe
ACFE894 mov      x3, #0x0
ACFE898 bl       __NSGetCGFloatAppConfig
ACFE89C mov.16b  v8, v0
ACFE8A0 b        0x18acfe77c
__catesPositionAfterDuration:
ACFE8A4 pacibsp
ACFE8A8 stp      d13, d12, [sp, #-0x60]!
ACFE8AC stp      d11, d10, [sp, #0x10]
ACFE8B0 stp      d9, d8, [sp, #0x20]
ACFE8B4 stp      x22, x21, [sp, #0x30]
ACFE8B8 stp      x20, x19, [sp, #0x40]
ACFE8BC stp      x29, x30, [sp, #0x50]
ACFE8C0 add      x29, sp, #0x50
ACFE8C4 mov.16b  v10, v0
ACFE8C8 mov      x19, x0
ACFE8CC add      x0, x0, #0x8
ACFE8D0 bl       0x19010d0a0
ACFE8D4 ldp      d8, d9, [x19, #0x30]
ACFE8D8 ldr      d0, [x19, #0xd8]
ACFE8DC fcmp     d0, #0.0
ACFE8E0 cset     w8, ge
ACFE8E4 fcmp     d10, d0
ACFE8E8 csel     w20, wzr, w8, lt
ACFE8EC cmp      w20, #0x1
ACFE8F0 b.ne     0x18acfe9d8
ACFE8F4 fsub     d11, d10, d0
ACFE8F8 ldr      x8, [x19, #0x100]
ACFE8FC cmp      x8, #0x2
ACFE900 b.eq     0x18acfe974
ACFE904 cmp      x8, #0x1
ACFE908 b.ne     0x18acfe9d8
ACFE90C ldr      w21, [x19, #0x98]
ACFE910 ldr      d0, [x19, #0xe0]
ACFE914 fneg     d12, d0
ACFE918 ldr      d13, [x19, #0xf0]
ACFE91C bl       _NSScrollViewRubberbandStiffness
ACFE920 mov.16b  v3, v0
ACFE924 mov.16b  v0, v12
ACFE928 mov.16b  v1, v13
ACFE92C mov.16b  v2, v11
ACFE930 bl       __NSElasticDeltaForTimeDelta2
ACFE934 tbz      w21, #0x0, 0x18acfe96c
ACFE938 frinta   d1, d0
ACFE93C fabd     d2, d0, d1
ACFE940 fmov     d3, #0.12500000
ACFE944 fcmp     d2, d3
ACFE948 fcsel    d0, d1, d0, mi
ACFE94C fmov     d1, #-0.50000000
ACFE950 fadd     d1, d0, d1
ACFE954 frintp   d1, d1
ACFE958 fmov     d2, #0.50000000
ACFE95C fadd     d2, d0, d2
ACFE960 frintm   d2, d2
ACFE964 fcmp     d0, #0.0
ACFE968 fcsel    d0, d1, d2, gt
ACFE96C fsub     d8, d8, d0
ACFE970 b        0x18acfe9d8
ACFE974 ldr      w21, [x19, #0x98]
ACFE978 ldr      d0, [x19, #0xe8]
ACFE97C fneg     d12, d0
ACFE980 ldr      d13, [x19, #0xf8]
ACFE984 bl       _NSScrollViewRubberbandStiffness
ACFE988 mov.16b  v3, v0
ACFE98C mov.16b  v0, v12
ACFE990 mov.16b  v1, v13
ACFE994 mov.16b  v2, v11
ACFE998 bl       __NSElasticDeltaForTimeDelta2
ACFE99C tbz      w21, #0x0, 0x18acfe9d4
ACFE9A0 frinta   d1, d0
ACFE9A4 fabd     d2, d0, d1
ACFE9A8 fmov     d3, #0.12500000
ACFE9AC fcmp     d2, d3
ACFE9B0 fcsel    d0, d1, d0, mi
ACFE9B4 fmov     d1, #-0.50000000
ACFE9B8 fadd     d1, d0, d1
ACFE9BC frintp   d1, d1
ACFE9C0 fmov     d2, #0.50000000
ACFE9C4 fadd     d2, d0, d2
ACFE9C8 frintm   d2, d2
ACFE9CC fcmp     d0, #0.0
ACFE9D0 fcsel    d0, d1, d2, gt
ACFE9D4 fsub     d9, d9, d0
ACFE9D8 ldr      d0, [x19, #0xc0]
ACFE9DC fcmp     d0, #0.0
ACFE9E0 b.le     0x18acfea5c
ACFE9E4 ldr      d11, [x19, #0x90]
ACFE9E8 fcmp     d11, #0.0
ACFE9EC b.hi     0x18acfea14
ACFE9F0 adrp     x2, 404442           ; 0x1ed8d8000
ACFE9F4 add      x2, x2, #0xb6a
ACFE9F8 ldarb    w8, [x2]
ACFE9FC cmp      w8, #0x1
ACFEA00 b.ne     0x18acfeba0
ACFEA04 adrp     x8, 404442           ; 0x1ed8d8000
ACFEA08 add      x8, x8, #0xb78
ACFEA0C ldar     x8, [x8]
ACFEA10 fmov     d11, x8
ACFEA14 ldr      d0, [x19, #0xa8]
ACFEA18 fsub     d0, d0, d10
ACFEA1C movi.2d  v1, #0000000000000000
ACFEA20 fmaxnm   d0, d0, d1
ACFEA24 ldr      d10, [x19, #0xc0]
ACFEA28 fmov     d1, #4.00000000
ACFEA2C bl       0x1900fa180
ACFEA30 fmul     d0, d11, d0
ACFEA34 fsub     d0, d10, d0
ACFEA38 fdiv     d1, d0, d10
ACFEA3C ldp      d2, d0, [x19, #0x10]
ACFEA40 cbz      w20, 0x18acfea70
ACFEA44 ldr      x8, [x19, #0x100]
ACFEA48 cmp      x8, #0x1
ACFEA4C b.ne     0x18acfea70
ACFEA50 ldr      w8, [x19, #0x98]
ACFEA54 and      w8, w8, #0x1
ACFEA58 b        0x18acfead0
ACFEA5C ldr      d8, [x19, #0x30]
ACFEA60 ldrb     w8, [x19, #0x98]
ACFEA64 tbnz     w8, #0x0, 0x18acfeb1c
ACFEA68 ldr      d9, [x19, #0x38]
ACFEA6C b        0x18acfeb7c
ACFEA70 ldr      w9, [x19, #0x98]
ACFEA74 and      w8, w9, #0x1
ACFEA78 ldr      d3, [x19, #0xc8]
ACFEA7C fsub     d3, d3, d2
ACFEA80 fmul     d3, d1, d3
ACFEA84 tbz      w9, #0x0, 0x18acfeabc
ACFEA88 frinta   d4, d3
ACFEA8C fabd     d5, d3, d4
ACFEA90 fmov     d6, #0.12500000
ACFEA94 fcmp     d5, d6
ACFEA98 fcsel    d3, d4, d3, mi
ACFEA9C fmov     d4, #-0.50000000
ACFEAA0 fadd     d4, d3, d4
ACFEAA4 frintp   d4, d4
ACFEAA8 fmov     d5, #0.50000000
ACFEAAC fadd     d5, d3, d5
ACFEAB0 frintm   d5, d5
ACFEAB4 fcmp     d3, #0.0
ACFEAB8 fcsel    d3, d4, d5, gt
ACFEABC fadd     d8, d2, d3
ACFEAC0 cbz      w20, 0x18acfead0
ACFEAC4 ldr      x9, [x19, #0x100]
ACFEAC8 cmp      x9, #0x2
ACFEACC b.eq     0x18acfeb7c
ACFEAD0 ldr      d2, [x19, #0xd0]
ACFEAD4 fsub     d2, d2, d0
ACFEAD8 fmul     d1, d1, d2
ACFEADC cbz      w8, 0x18acfeb14
ACFEAE0 frinta   d2, d1
ACFEAE4 fabd     d3, d1, d2
ACFEAE8 fmov     d4, #0.12500000
ACFEAEC fcmp     d3, d4
ACFEAF0 fcsel    d1, d2, d1, mi
ACFEAF4 fmov     d2, #-0.50000000
ACFEAF8 fadd     d2, d1, d2
ACFEAFC frintp   d2, d2
ACFEB00 fmov     d3, #0.50000000
ACFEB04 fadd     d3, d1, d3
ACFEB08 frintm   d3, d3
ACFEB0C fcmp     d1, #0.0
ACFEB10 fcsel    d1, d2, d3, gt
ACFEB14 fadd     d9, d0, d1
ACFEB18 b        0x18acfeb7c
ACFEB1C frinta   d0, d8
ACFEB20 fabd     d1, d8, d0
ACFEB24 fmov     d2, #0.12500000
ACFEB28 fcmp     d1, d2
ACFEB2C fcsel    d0, d0, d8, mi
ACFEB30 fmov     d1, #-0.50000000
ACFEB34 fadd     d3, d0, d1
ACFEB38 frintp   d3, d3
ACFEB3C fmov     d4, #0.50000000
ACFEB40 fadd     d5, d0, d4
ACFEB44 frintm   d5, d5
ACFEB48 fcmp     d0, #0.0
ACFEB4C fcsel    d8, d3, d5, gt
ACFEB50 ldr      d0, [x19, #0x38]
ACFEB54 frinta   d3, d0
ACFEB58 fabd     d5, d0, d3
ACFEB5C fcmp     d5, d2
ACFEB60 fcsel    d0, d3, d0, mi
ACFEB64 fadd     d1, d0, d1
ACFEB68 frintp   d1, d1
ACFEB6C fadd     d2, d0, d4
ACFEB70 frintm   d2, d2
ACFEB74 fcmp     d0, #0.0
ACFEB78 fcsel    d9, d1, d2, gt
ACFEB7C mov.16b  v0, v8
ACFEB80 mov.16b  v1, v9
ACFEB84 ldp      x29, x30, [sp, #0x50]
ACFEB88 ldp      x20, x19, [sp, #0x40]
ACFEB8C ldp      x22, x21, [sp, #0x30]
ACFEB90 ldp      d9, d8, [sp, #0x20]
ACFEB94 ldp      d11, d10, [sp, #0x10]
ACFEB98 ldp      d13, d12, [sp], #0x60
ACFEB9C retab
ACFEBA0 adrp     x0, 359371           ; 0x1e28c9000
ACFEBA4 add      x0, x0, #0xd20
ACFEBA8 adrp     x8, 2799             ; 0x18b7ed000
ACFEBAC ldr      d0, [x8, #0x5a0]
ACFEBB0 add      x1, x2, #0xe
ACFEBB4 mov      x3, #0x0
ACFEBB8 bl       __NSGetCGFloatAppConfig
ACFEBBC mov.16b  v11, v0
ACFEBC0 b        0x18acfea14
__catesCalculateToReachDestination:
ACFEBC4 pacibsp
ACFEBC8 sub      sp, sp, #0xb0
ACFEBCC stp      d11, d10, [sp, #0x70]
ACFEBD0 stp      d9, d8, [sp, #0x80]
ACFEBD4 stp      x20, x19, [sp, #0x90]
ACFEBD8 stp      x29, x30, [sp, #0xa0]
ACFEBDC add      x29, sp, #0xa0
ACFEBE0 mov      x19, x0
ACFEBE4 add      x0, x0, #0x8
ACFEBE8 bl       0x19010d0a0
ACFEBEC ldr      d8, [x19, #0x90]
ACFEBF0 fcmp     d8, #0.0
ACFEBF4 b.hi     0x18acfec1c
ACFEBF8 adrp     x2, 404442           ; 0x1ed8d8000
ACFEBFC add      x2, x2, #0xb6a
ACFEC00 ldarb    w8, [x2]
ACFEC04 cmp      w8, #0x1
ACFEC08 b.ne     0x18acfefd0
ACFEC0C adrp     x8, 404442           ; 0x1ed8d8000
ACFEC10 add      x8, x8, #0xb78
ACFEC14 ldar     x8, [x8]
ACFEC18 fmov     d8, x8
ACFEC1C mov      x8, #-0x4010000000000000
ACFEC20 str      x8, [x19, #0xd8]
ACFEC24 ldr      q0, [x19, #0x30]
ACFEC28 stur     q0, [x19, #0xc8]
ACFEC2C adrp     x20, 404442          ; 0x1ed8d8000
ACFEC30 add      x20, x20, #0xb69
ACFEC34 ldarb    w8, [x20]
ACFEC38 cmp      w8, #0x2
ACFEC3C b.eq     0x18acfec5c
ACFEC40 cbz      w8, 0x18acfef64
ACFEC44 ldp      d0, d1, [x19, #0x30]
ACFEC48 bl       0x1901091d0
ACFEC4C str      x0, [sp]
ACFEC50 adrp     x0, 359371           ; 0x1e28c9000
ACFEC54 add      x0, x0, #0xd40
ACFEC58 bl       0x190108fb0
ACFEC5C fmov     d0, #1.00000000
ACFEC60 movi.2d  v1, #0xffffffffffffffff
ACFEC64 fneg.2d  v1, v1
ACFEC68 ldp      d2, d3, [x19, #0x20]
ACFEC6C mov.16b  v4, v1
ACFEC70 bsl.16b  v4, v0, v2
ACFEC74 stp      q3, q4, [sp, #0x40]
ACFEC78 bif.16b  v0, v3, v1
ACFEC7C stur     q0, [x29, #-0x40]
ACFEC80 fabs     d0, d2
ACFEC84 fmov     d1, #4.00000000
ACFEC88 fmul     d10, d8, d1
ACFEC8C fdiv     d0, d0, d10
ACFEC90 adrp     x8, 2801             ; 0x18b7ef000
ACFEC94 ldr      d9, [x8, #0xb48]
ACFEC98 mov.16b  v1, v9
ACFEC9C bl       0x1900fa180
ACFECA0 fmul     d0, d8, d0
ACFECA4 ldr      q1, [sp, #0x50]
ACFECA8 fmul     d0, d1, d0
ACFECAC str      q0, [sp, #0x50]
ACFECB0 ldr      q0, [sp, #0x40]
ACFECB4 fabs     d0, d0
ACFECB8 fdiv     d0, d0, d10
ACFECBC mov.16b  v1, v9
ACFECC0 bl       0x1900fa180
ACFECC4 fmul     d0, d8, d0
ACFECC8 ldur     q1, [x29, #-0x40]
ACFECCC fmul     d0, d1, d0
ACFECD0 ldrb     w8, [x19, #0x98]
ACFECD4 tbnz     w8, #0x0, 0x18acfed00
ACFECD8 fmul     d1, d0, d0
ACFECDC ldr      q3, [sp, #0x50]
ACFECE0 fmadd    d1, d3, d3, d1
ACFECE4 fsqrt    d9, d1
ACFECE8 ldr      q1, [x19, #0x30]
ACFECEC ldr      q2, [x19, #0x10]
ACFECF0 fsub.2d  v1, v1, v2
ACFECF4 mov.d    v3[1], v0[0]
ACFECF8 str      q3, [sp, #0x50]
ACFECFC b        0x18acfed84
ACFED00 ldr      q3, [sp, #0x50]
ACFED04 mov.d    v3[1], v0[0]
ACFED08 frinta.2d v0, v3
ACFED0C fabd.2d  v1, v3, v0
ACFED10 fmov.2d  v2, #0.12500000
ACFED14 fcmgt.2d v1, v2, v1
ACFED18 bif.16b  v0, v3, v1
ACFED1C fcmgt.2d v1, v0, #0.0
ACFED20 fmov.2d  v3, #-0.50000000
ACFED24 fadd.2d  v4, v0, v3
ACFED28 frintp.2d v4, v4
ACFED2C fmov.2d  v5, #0.50000000
ACFED30 fadd.2d  v0, v0, v5
ACFED34 frintm.2d v0, v0
ACFED38 bsl.16b  v1, v4, v0
ACFED3C fmul.2d  v0, v1, v1
ACFED40 mov      d0, v0[1]
ACFED44 str      q1, [sp, #0x50]
ACFED48 fmadd    d0, d1, d1, d0
ACFED4C fsqrt    d9, d0
ACFED50 ldr      q0, [x19, #0x30]
ACFED54 ldr      q1, [x19, #0x10]
ACFED58 fsub.2d  v0, v0, v1
ACFED5C frinta.2d v1, v0
ACFED60 fabd.2d  v4, v0, v1
ACFED64 fcmgt.2d v2, v2, v4
ACFED68 bit.16b  v0, v1, v2
ACFED6C fcmgt.2d v1, v0, #0.0
ACFED70 fadd.2d  v2, v0, v3
ACFED74 frintp.2d v2, v2
ACFED78 fadd.2d  v0, v0, v5
ACFED7C frintm.2d v0, v0
ACFED80 bsl.16b  v1, v2, v0
ACFED84 str      q1, [sp, #0x40]
ACFED88 mov      d11, v1[1]
ACFED8C fmul.d   d0, d11, v1[1]
ACFED90 fmadd    d0, d1, d1, d0
ACFED94 fsqrt    d0, d0
ACFED98 stur     q0, [x29, #-0x40]
ACFED9C ldr      d0, [x19, #0xa8]
ACFEDA0 fmov     d1, #3.00000000
ACFEDA4 bl       0x1900fa180
ACFEDA8 fmov     d1, #0.50000000
ACFEDAC ldur     q2, [x29, #-0x40]
ACFEDB0 fcmp     d2, d1
ACFEDB4 b.ls     0x18acfee24
ACFEDB8 fmul     d2, d10, d0
ACFEDBC ldr      q0, [sp, #0x40]
ACFEDC0 fcmp     d0, #0.0
ACFEDC4 mov.16b  v1, v0
ACFEDC8 ldr      q0, [sp, #0x50]
ACFEDCC b.eq     0x18acfede0
ACFEDD0 fmov     x8, d1
ACFEDD4 fmov     x9, d0
ACFEDD8 eor      x8, x9, x8
ACFEDDC tbnz     x8, #0x3f, 0x18acfee48
ACFEDE0 fcmp     d11, #0.0
ACFEDE4 b.eq     0x18acfedf8
ACFEDE8 fmov     x8, d11
ACFEDEC mov.d    x9, v0[1]
ACFEDF0 eor      x8, x9, x8
ACFEDF4 tbnz     x8, #0x3f, 0x18acfee48
ACFEDF8 ldarb    w8, [x20]
ACFEDFC ldur     q0, [x29, #-0x40]
ACFEE00 fcmp     d0, d9
ACFEE04 b.le     0x18acfee84
ACFEE08 cmp      w8, #0x2
ACFEE0C b.eq     0x18acfee70
ACFEE10 str      q2, [sp, #0x30]
ACFEE14 cbz      w8, 0x18acff01c
ACFEE18 adrp     x0, 359371           ; 0x1e28c9000
ACFEE1C add      x0, x0, #0xda0
ACFEE20 b        0x18acfee64
ACFEE24 ldarb    w8, [x20]
ACFEE28 cmp      w8, #0x2
ACFEE2C b.eq     0x18acfee40
ACFEE30 cbz      w8, 0x18acfefac
ACFEE34 adrp     x0, 359371           ; 0x1e28c9000
ACFEE38 add      x0, x0, #0xd60
ACFEE3C bl       0x190108fb0
ACFEE40 stp      xzr, xzr, [x19, #0xa0]
ACFEE44 b        0x18acfef10
ACFEE48 ldarb    w8, [x20]
ACFEE4C cmp      w8, #0x2
ACFEE50 b.eq     0x18acfee6c
ACFEE54 str      q2, [sp, #0x30]
ACFEE58 cbz      w8, 0x18acfeff4
ACFEE5C adrp     x0, 359371           ; 0x1e28c9000
ACFEE60 add      x0, x0, #0xd80
ACFEE64 bl       0x190108fb0
ACFEE68 ldp      q2, q1, [sp, #0x30]
ACFEE6C ldur     q0, [x29, #-0x40]
ACFEE70 dup.2d   v0, v0[0]
ACFEE74 fdiv.2d  v0, v1, v0
ACFEE78 fmul.2d  v0, v0, v2[0]
ACFEE7C str      q0, [x19, #0x20]
ACFEE80 b        0x18acfef10
ACFEE84 cmp      w8, #0x2
ACFEE88 b.eq     0x18acfee9c
ACFEE8C cbz      w8, 0x18acff048
ACFEE90 adrp     x0, 359371           ; 0x1e28c9000
ACFEE94 add      x0, x0, #0xdc0
ACFEE98 bl       0x190108fb0
ACFEE9C ldp      d0, d1, [x19, #0x20]
ACFEEA0 fmul     d1, d1, d1
ACFEEA4 fmadd    d0, d0, d0, d1
ACFEEA8 fsqrt    d0, d0
ACFEEAC str      q0, [sp, #0x50]
ACFEEB0 fmov     d1, #0.75000000
ACFEEB4 ldur     q0, [x29, #-0x40]
ACFEEB8 bl       0x1900fa180
ACFEEBC fmov     d1, #4.00000000
ACFEEC0 fmul     d0, d0, d1
ACFEEC4 ldr      q1, [sp, #0x50]
ACFEEC8 fdiv     d0, d1, d0
ACFEECC fmov     d1, #4.00000000
ACFEED0 bl       0x1900fa180
ACFEED4 mov.16b  v8, v0
ACFEED8 fcmp     d0, d0
ACFEEDC b.vs     0x18acff06c
ACFEEE0 str      d8, [x19, #0x90]
ACFEEE4 ldur     q0, [x29, #-0x40]
ACFEEE8 fdiv     d0, d0, d8
ACFEEEC fmov     d1, #0.25000000
ACFEEF0 bl       0x1900fa180
ACFEEF4 ldur     q1, [x29, #-0x40]
ACFEEF8 dup.2d   v1, v1[0]
ACFEEFC ldp      q3, q2, [sp, #0x40]
ACFEF00 fdiv.2d  v1, v3, v1
ACFEF04 fmul.2d  v1, v1, v2[0]
ACFEF08 stp      d0, d0, [x19, #0xa0]
ACFEF0C str      q1, [x19, #0x20]
ACFEF10 mov      x0, x19
ACFEF14 bl       __catesCalculateCachedProperties
ACFEF18 ldarb    w8, [x20]
ACFEF1C cmp      w8, #0x2
ACFEF20 b.eq     0x18acfef4c
ACFEF24 cbz      w8, 0x18acfef88
ACFEF28 ldr      d0, [x19, #0x20]
ACFEF2C ldr      d1, [x19, #0xa0]
ACFEF30 ldur     q2, [x29, #-0x40]
ACFEF34 stp      d9, d2, [sp, #0x18]
ACFEF38 stp      d1, d8, [sp, #0x8]
ACFEF3C str      d0, [sp]
ACFEF40 adrp     x0, 359371           ; 0x1e28c9000
ACFEF44 add      x0, x0, #0xe00
ACFEF48 bl       0x190108fb0
ACFEF4C ldp      x29, x30, [sp, #0xa0]
ACFEF50 ldp      x20, x19, [sp, #0x90]
ACFEF54 ldp      d9, d8, [sp, #0x80]
ACFEF58 ldp      d11, d10, [sp, #0x70]
ACFEF5C add      sp, sp, #0xb0
ACFEF60 retab
ACFEF64 adrp     x0, 359295           ; 0x1e287d000
ACFEF68 add      x0, x0, #0x620
ACFEF6C adrp     x2, 404442           ; 0x1ed8d8000
ACFEF70 add      x2, x2, #0xb69
ACFEF74 mov      w1, #0x0
ACFEF78 mov      x3, #0x0
ACFEF7C bl       __NSGetBoolAppConfig
ACFEF80 cbnz     w0, 0x18acfec44
ACFEF84 b        0x18acfec5c
ACFEF88 adrp     x0, 359295           ; 0x1e287d000
ACFEF8C add      x0, x0, #0x620
ACFEF90 adrp     x2, 404442           ; 0x1ed8d8000
ACFEF94 add      x2, x2, #0xb69
ACFEF98 mov      w1, #0x0
ACFEF9C mov      x3, #0x0
ACFEFA0 bl       __NSGetBoolAppConfig
ACFEFA4 cbnz     w0, 0x18acfef28
ACFEFA8 b        0x18acfef4c
ACFEFAC adrp     x0, 359295           ; 0x1e287d000
ACFEFB0 add      x0, x0, #0x620
ACFEFB4 adrp     x2, 404442           ; 0x1ed8d8000
ACFEFB8 add      x2, x2, #0xb69
ACFEFBC mov      w1, #0x0
ACFEFC0 mov      x3, #0x0
ACFEFC4 bl       __NSGetBoolAppConfig
ACFEFC8 cbnz     w0, 0x18acfee34
ACFEFCC b        0x18acfee40
ACFEFD0 adrp     x0, 359371           ; 0x1e28c9000
ACFEFD4 add      x0, x0, #0xd20
ACFEFD8 adrp     x8, 2799             ; 0x18b7ed000
ACFEFDC ldr      d0, [x8, #0x5a0]
ACFEFE0 add      x1, x2, #0xe
ACFEFE4 mov      x3, #0x0
ACFEFE8 bl       __NSGetCGFloatAppConfig
ACFEFEC mov.16b  v8, v0
ACFEFF0 b        0x18acfec1c
ACFEFF4 adrp     x0, 359295           ; 0x1e287d000
ACFEFF8 add      x0, x0, #0x620
ACFEFFC adrp     x2, 404442           ; 0x1ed8d8000
ACFF000 add      x2, x2, #0xb69
ACFF004 mov      w1, #0x0
ACFF008 mov      x3, #0x0
ACFF00C bl       __NSGetBoolAppConfig
ACFF010 ldp      q2, q1, [sp, #0x30]
ACFF014 cbnz     w0, 0x18acfee5c
ACFF018 b        0x18acfee6c
ACFF01C adrp     x0, 359294           ; 0x1e287d000
ACFF020 add      x0, x0, #0x620
ACFF024 adrp     x2, 404441           ; 0x1ed8d8000
ACFF028 add      x2, x2, #0xb69
ACFF02C mov      w1, #0x0
ACFF030 mov      x3, #0x0
ACFF034 bl       __NSGetBoolAppConfig
ACFF038 ldp      q2, q1, [sp, #0x30]
ACFF03C ldur     q0, [x29, #-0x40]
ACFF040 cbnz     w0, 0x18acfee18
ACFF044 b        0x18acfee70
ACFF048 adrp     x0, 359294           ; 0x1e287d000
ACFF04C add      x0, x0, #0x620
ACFF050 adrp     x2, 404441           ; 0x1ed8d8000
ACFF054 add      x2, x2, #0xb69
ACFF058 mov      w1, #0x0
ACFF05C mov      x3, #0x0
ACFF060 bl       __NSGetBoolAppConfig
ACFF064 cbnz     w0, 0x18acfee90
ACFF068 b        0x18acfee9c
ACFF06C ldarb    w8, [x20]
ACFF070 cmp      w8, #0x2
ACFF074 b.eq     0x18acfee40
ACFF078 cbz      w8, 0x18acff088
ACFF07C adrp     x0, 359370           ; 0x1e28c9000
ACFF080 add      x0, x0, #0xde0
ACFF084 b        0x18acfee3c
ACFF088 adrp     x0, 359294           ; 0x1e287d000
ACFF08C add      x0, x0, #0x620
ACFF090 adrp     x2, 404441           ; 0x1ed8d8000
ACFF094 add      x2, x2, #0xb69
ACFF098 mov      w1, #0x0
ACFF09C mov      x3, #0x0
ACFF0A0 bl       __NSGetBoolAppConfig
ACFF0A4 cbz      w0, 0x18acfee40
ACFF0A8 b        0x18acff07c

; ===== Cates: velocityAfterDuration: / isRubberBandingAfterDuration: =====
-[_NSScrollingMomentumCatesCalculator velocityAfterDuration:]:
ACFF1AC pacibsp
ACFF1B0 stp      d15, d14, [sp, #-0x60]!
ACFF1B4 stp      d13, d12, [sp, #0x10]
ACFF1B8 stp      d11, d10, [sp, #0x20]
ACFF1BC stp      d9, d8, [sp, #0x30]
ACFF1C0 stp      x20, x19, [sp, #0x40]
ACFF1C4 stp      x29, x30, [sp, #0x50]
ACFF1C8 add      x29, sp, #0x50
ACFF1CC mov.16b  v8, v0
ACFF1D0 mov      x19, x0
ACFF1D4 add      x0, x0, #0x8
ACFF1D8 bl       0x19010d0b0
ACFF1DC ldr      d0, [x19, #0xd8]
ACFF1E0 fcmp     d0, #0.0
ACFF1E4 fccmp    d8, d0, #0x8, ge
ACFF1E8 b.ge     0x18acff240
ACFF1EC ldr      d0, [x19, #0x90]
ACFF1F0 fcmp     d0, #0.0
ACFF1F4 b.hi     0x18acff21c
ACFF1F8 adrp     x2, 404441           ; 0x1ed8d8000
ACFF1FC add      x2, x2, #0xb6a
ACFF200 ldarb    w8, [x2]
ACFF204 cmp      w8, #0x1
ACFF208 b.ne     0x18acff318
ACFF20C adrp     x8, 404441           ; 0x1ed8d8000
ACFF210 add      x8, x8, #0xb78
ACFF214 ldar     x8, [x8]
ACFF218 fmov     d0, x8
ACFF21C ldr      d1, [x19, #0xa8]
ACFF220 fsub     d2, d1, d8
ACFF224 fmov     d1, #4.00000000
ACFF228 fmul     d8, d0, d1
ACFF22C fmov     d1, #3.00000000
ACFF230 mov.16b  v0, v2
ACFF234 bl       0x1900fa180
ACFF238 fmul     d8, d8, d0
ACFF23C b        0x18acff2f0
ACFF240 fsub     d8, d8, d0
ACFF244 ldr      d9, [x19, #0xe0]
ACFF248 ldr      d10, [x19, #0xf0]
ACFF24C bl       _NSScrollViewRubberbandStiffness
ACFF250 mov.16b  v3, v0
ACFF254 mov.16b  v0, v9
ACFF258 mov.16b  v1, v10
ACFF25C mov.16b  v2, v8
ACFF260 bl       __NSElasticDeltaForTimeDelta2
ACFF264 mov.16b  v9, v0
ACFF268 ldr      d10, [x19, #0xe8]
ACFF26C ldr      d11, [x19, #0xf8]
ACFF270 bl       _NSScrollViewRubberbandStiffness
ACFF274 mov.16b  v3, v0
ACFF278 mov.16b  v0, v10
ACFF27C mov.16b  v1, v11
ACFF280 mov.16b  v2, v8
ACFF284 bl       __NSElasticDeltaForTimeDelta2
ACFF288 mov.16b  v10, v0
ACFF28C adrp     x8, 2798             ; 0x18b7ed000
ACFF290 ldr      d14, [x8, #0xc50]
ACFF294 fadd     d8, d8, d14
ACFF298 ldr      d11, [x19, #0xe0]
ACFF29C ldr      d12, [x19, #0xf0]
ACFF2A0 bl       _NSScrollViewRubberbandStiffness
ACFF2A4 mov.16b  v3, v0
ACFF2A8 mov.16b  v0, v11
ACFF2AC mov.16b  v1, v12
ACFF2B0 mov.16b  v2, v8
ACFF2B4 bl       __NSElasticDeltaForTimeDelta2
ACFF2B8 mov.16b  v11, v0
ACFF2BC ldr      d12, [x19, #0xe8]
ACFF2C0 ldr      d13, [x19, #0xf8]
ACFF2C4 bl       _NSScrollViewRubberbandStiffness
ACFF2C8 mov.16b  v3, v0
ACFF2CC mov.16b  v0, v12
ACFF2D0 mov.16b  v1, v13
ACFF2D4 mov.16b  v2, v8
ACFF2D8 bl       __NSElasticDeltaForTimeDelta2
ACFF2DC fabd     d2, d11, d9
ACFF2E0 fabd     d1, d0, d10
ACFF2E4 mov.16b  v0, v2
ACFF2E8 bl       0x19010c8e0
ACFF2EC fdiv     d8, d0, d14
ACFF2F0 add      x0, x19, #0x8
ACFF2F4 bl       0x19010d0d0
ACFF2F8 mov.16b  v0, v8
ACFF2FC ldp      x29, x30, [sp, #0x50]
ACFF300 ldp      x20, x19, [sp, #0x40]
ACFF304 ldp      d9, d8, [sp, #0x30]
ACFF308 ldp      d11, d10, [sp, #0x20]
ACFF30C ldp      d13, d12, [sp, #0x10]
ACFF310 ldp      d15, d14, [sp], #0x60
ACFF314 retab
ACFF318 adrp     x0, 359370           ; 0x1e28c9000
ACFF31C add      x0, x0, #0xd20
ACFF320 adrp     x8, 2798             ; 0x18b7ed000
ACFF324 ldr      d0, [x8, #0x5a0]
ACFF328 add      x1, x2, #0xe
ACFF32C mov      x3, #0x0
ACFF330 bl       __NSGetCGFloatAppConfig
ACFF334 b        0x18acff21c
-[_NSScrollingMomentumCatesCalculator positionAfterDuration:]:
ACFF338 pacibsp
ACFF33C stp      d9, d8, [sp, #-0x30]!
ACFF340 stp      x20, x19, [sp, #0x10]
ACFF344 stp      x29, x30, [sp, #0x20]
ACFF348 add      x29, sp, #0x20
ACFF34C mov.16b  v8, v0
ACFF350 mov      x19, x0
ACFF354 add      x0, x0, #0x8
ACFF358 bl       0x19010d0b0
ACFF35C mov      x0, x19
ACFF360 mov.16b  v0, v8
ACFF364 bl       __catesPositionAfterDuration
ACFF368 mov.16b  v8, v0
ACFF36C mov.16b  v9, v1
ACFF370 add      x0, x19, #0x8
ACFF374 bl       0x19010d0d0
ACFF378 mov.16b  v0, v8
ACFF37C mov.16b  v1, v9
ACFF380 ldp      x29, x30, [sp, #0x20]
ACFF384 ldp      x20, x19, [sp, #0x10]
ACFF388 ldp      d9, d8, [sp], #0x30
ACFF38C retab
-[_NSScrollingMomentumCatesCalculator isRubberBandingAfterDuration:]:
ACFF390 ldr      d1, [x0, #0xd8]
ACFF394 fcmp     d1, #0.0
ACFF398 cset     w8, ge
ACFF39C fcmp     d0, d1
ACFF3A0 csel     w0, wzr, w8, lt
ACFF3A4 ret

; ===== Bas init (0.998, ln 0.998) =====
-[_NSScrollingMomentumBasCalculator init]:
ACFF3A8 pacibsp
ACFF3AC sub      sp, sp, #0x20
ACFF3B0 stp      x29, x30, [sp, #0x10]
ACFF3B4 add      x29, sp, #0x10
ACFF3B8 adrp     x8, 350827           ; 0x1e076a000
ACFF3BC ldr      x8, [x8, #0xfd8]
ACFF3C0 stp      x0, x8, [sp]
ACFF3C4 adrp     x8, 350786           ; 0x1e0741000
ACFF3C8 ldr      x1, [x8, #0x238]
ACFF3CC mov      x0, sp
ACFF3D0 bl       0x19010ce60
ACFF3D4 cbz      x0, 0x18acff418
ACFF3D8 mov      x8, #0xe56
ACFF3DC movk     x8, #0xb22d, lsl #16
ACFF3E0 movk     x8, #0xef9d, lsl #32
ACFF3E4 movk     x8, #0x3fef, lsl #48
ACFF3E8 dup.2d   v0, x8
ACFF3EC mov      x8, #0xcc09
ACFF3F0 movk     x8, #0xffe7, lsl #16
ACFF3F4 movk     x8, #0x6680, lsl #32
ACFF3F8 movk     x8, #0xbf60, lsl #48
ACFF3FC dup.2d   v1, x8
ACFF400 stp      q0, q1, [x0, #0xa0]
ACFF404 mov      x8, #-0x1
ACFF408 str      x8, [x0, #0xf8]
ACFF40C str      wzr, [x0, #0xc0]
ACFF410 mov      x8, #-0x4010000000000000
ACFF414 str      x8, [x0, #0xc8]
ACFF418 ldp      x29, x30, [sp, #0x10]
ACFF41C add      sp, sp, #0x20
ACFF420 retab

; ===== _NS1DVelocityFilter init / addDelta:withTimestamp: / filteredVelocity =====
-[_NS1DVelocityFilter init]:
A462520 pacibsp
A462524 sub      sp, sp, #0x30
A462528 stp      x20, x19, [sp, #0x10]
A46252C stp      x29, x30, [sp, #0x20]
A462530 add      x29, sp, #0x20
A462534 adrp     x8, 353032           ; 0x1e076a000
A462538 ldr      x8, [x8, #0x680]
A46253C stp      x0, x8, [sp]
A462540 adrp     x8, 352991           ; 0x1e0741000
A462544 ldr      x1, [x8, #0x238]
A462548 mov      x0, sp
A46254C bl       0x19010ce60
A462550 mov      x19, x0
A462554 cbz      x0, 0x18a462590
A462558 adrp     x8, 5005             ; 0x18b7ef000
A46255C ldr      q0, [x8, #0x2b0]
A462560 stur     q0, [x19, #0x8]
A462564 adrp     x8, 406630           ; 0x1ed8c8000
A462568 add      x0, x8, #0x948       ; _OBJC_CLASS_$__NS1DVelocityFilterIvars
A46256C bl       0x19010ce90
A462570 mov      x8, #-0x6666666666666667
A462574 movk     x8, #0x999a
A462578 movk     x8, #0x3fc9, lsl #48
A46257C str      x0, [x19, #0x18]
A462580 str      x8, [x0, #0x8]
A462584 ldr      x8, [x19, #0x18]
-[_NS1DVelocityFilter addDelta:withTimestamp:]:
A636360 pacibsp
A636364 sub      sp, sp, #0x50
A636368 stp      d11, d10, [sp, #0x10]
A63636C stp      d9, d8, [sp, #0x20]
A636370 stp      x20, x19, [sp, #0x30]
A636374 stp      x29, x30, [sp, #0x40]
A636378 add      x29, sp, #0x40
A63637C mov.16b  v8, v1
A636380 mov.16b  v9, v0
A636384 mov      x19, x0
A636388 adrp     x8, 4535             ; 0x18b7ed000
A63638C ldr      d0, [x8, #0x8b0]
A636390 ldr      d1, [x0, #0x10]
A636394 fsub     d10, d8, d1
A636398 fcmp     d10, d0
A63639C b.le     0x18a6363ac
A6363A0 mov      x0, x19
A6363A4 bl       0x19006e980 ; reset
A6363A8 b        0x18a636440
A6363AC fcmp     d10, #0.0
A6363B0 b.le     0x18a636440
A6363B4 fcmp     d9, #0.0
A6363B8 b.eq     0x18a6363d8
A6363BC fmov     x8, d9
A6363C0 ldr      x9, [x19, #0x18]
A6363C4 ldr      x9, [x9, #0x10]
A6363C8 eor      x8, x9, x8
A6363CC tbz      x8, #0x3f, 0x18a6363d8
A6363D0 mov      x0, x19
A6363D4 bl       0x19006e980 ; reset
A6363D8 adrp     x8, 4536             ; 0x18b7ee000
A6363DC ldr      d0, [x8, #0x5a8]
A6363E0 fcmp     d10, d0
A6363E4 b.ge     0x18a636414
A6363E8 adrp     x8, 396812           ; 0x1eb442000
A6363EC add      x8, x8, #0x1d1       ; _sNSScrollVelocityFilterDebugEnabledComputedValue
A6363F0 ldarb    w8, [x8]
A6363F4 cmp      w8, #0x2
A6363F8 b.eq     0x18a636444
A6363FC cbz      w8, 0x18a63645c
A636400 str      d10, [sp]
A636404 adrp     x0, 361088           ; 0x1e28b6000
A636408 add      x0, x0, #0x580
A63640C bl       0x190108fb0
A636410 b        0x18a636444
A636414 ldr      x8, [x19, #0x18]
A636418 ldr      d0, [x8, #0x10]
A63641C fcmp     d0, d0
A636420 b.vs     0x18a636480
A636424 ldr      d1, [x8, #0x8]
A636428 fdiv     d2, d9, d10
A63642C fmov     d3, #1.00000000
A636430 fsub     d3, d3, d1
A636434 fmul     d0, d0, d3
A636438 fmadd    d0, d1, d2, d0
A63643C str      d0, [x8, #0x10]
A636440 str      d8, [x19, #0x10]
-[_NS1DVelocityFilter filteredVelocity]:
AB37960 pacibsp
AB37964 sub      sp, sp, #0x30
AB37968 stp      d9, d8, [sp, #0x10]
AB3796C stp      x29, x30, [sp, #0x20]
AB37970 add      x29, sp, #0x20
AB37974 movi.2d  v0, #0000000000000000
AB37978 ldr      x8, [x0, #0x18]
AB3797C ldr      d1, [x8, #0x10]
AB37980 fcmp     d1, d1
AB37984 fcsel    d8, d1, d0, vc
AB37988 ldr      d0, [x0, #0x8]
AB3798C fcmp     d0, #0.0
AB37990 b.eq     0x18ab379b4
AB37994 fcmp     d8, d0
AB37998 fcsel    d1, d8, d0, mi
AB3799C fneg     d0, d0
AB379A0 fcmp     d8, d0
AB379A4 fcsel    d0, d0, d8, mi
AB379A8 fmov     x8, d8
AB379AC tst      x8, #0x8000000000000000
AB379B0 fcsel    d8, d1, d0, eq
AB379B4 adrp     x8, 395531           ; 0x1eb442000
AB379B8 add      x8, x8, #0x1d1       ; _sNSScrollVelocityFilterDebugEnabledComputedValue
AB379BC ldarb    w8, [x8]
AB379C0 cmp      w8, #0x2
AB379C4 b.eq     0x18ab379dc
AB379C8 cbz      w8, 0x18ab379f0
AB379CC str      d8, [sp]
AB379D0 adrp     x0, 359807           ; 0x1e28b6000
AB379D4 add      x0, x0, #0x5a0
AB379D8 bl       0x190108fb0
AB379DC mov.16b  v0, v8
AB379E0 ldp      x29, x30, [sp, #0x20]
AB379E4 ldp      d9, d8, [sp, #0x10]
AB379E8 add      sp, sp, #0x30
AB379EC retab
AB379F0 adrp     x0, 359807           ; 0x1e28b6000
AB379F4 add      x0, x0, #0x5e0
AB379F8 adrp     x2, 395531           ; 0x1eb442000
AB379FC add      x2, x2, #0x1d1       ; _sNSScrollVelocityFilterDebugEnabledComputedValue
AB37A00 mov      w1, #0x0
AB37A04 mov      x3, #0x0
AB37A08 bl       __NSGetBoolAppConfig
AB37A0C cbnz     w0, 0x18ab379cc
AB37A10 b        0x18ab379dc

; ===== -[NSScrollingBehaviorConcurrentVBL _animateMomentum] / _animateFreeMomentum =====
-[NSScrollingBehaviorConcurrentVBL _animateMomentum]:
A698790 sub      sp, sp, #0x50
A6987A0 add      x29, sp, #0x40
A6987A4 mov      x19, x0
A6987A8 adrp     x8, 406074           ; 0x1ed8d2000
A6987AC add      x8, x8, #0x93a
A6987B0 ldarb    w8, [x8]
A6987B4 cmp      w8, #0x2
A6987B8 b.eq     0x18a6987f0
A6987BC mov      x20, x1
A6987C0 cbz      w8, 0x18a6988e0
A6987C4 mov      x0, x19
A6987C8 bl       0x19010ce70
A6987CC bl       0x1901091c0
A6987D0 mov      x21, x0
A6987D4 mov      x0, x20
A6987D8 bl       0x190109210
A6987E0 str      x21, [sp]
A6987E4 adrp     x0, 360933           ; 0x1e287d000
A6987E8 add      x0, x0, #0x4a0
A6987EC bl       0x190108fb0
A6987F0 adrp     x21, 406054          ; 0x1ed8be000
A6987F4 add      x21, x21, #0xbb8
A6987F8 ldrsw    x8, [x21]
A6987FC add      x22, x19, x8
A698800 ldr      x0, [x22]
A698804 bl       0x19006a490 ; preprocessFilter
A698808 mov      x20, x0
A69880C mov      x2, #0x0
A698810 bl       0x19007d7f0 ; setScrollStateDelegate:
A698814 ldr      x2, [x22]
A698818 movi.2d  v0, #0000000000000000
A69881C mov      x0, x20
A698820 bl       0x190070d80 ; scrollingVBLMonitor:synchronizeForTimestamp:
A698824 ldrsw    x8, [x21, #0xc]
A698828 add      x8, x19, x8
A69882C ldr      x8, [x8]
A698830 cmp      x8, #0x2
A698834 b.lo     0x18a698874
A698838 cmp      x8, #0x4
A69883C b.eq     0x18a6988b8
A698840 cmp      x8, #0x2
A698844 b.ne     0x18a698860
A698848 mov      x0, x19
A69884C mov      w2, #0x2
A698850 bl       0x19007efc0 ; setState:
A698854 mov      x0, x19
A698858 bl       0x190004760 ; _animateSwipePageAlignment
A69885C cbnz     w0, 0x18a69888c
A69886C add      sp, sp, #0x50
A698870 retab
A698874 mov      x0, x19
A698878 mov      w2, #0x2
A69887C bl       0x19007efc0 ; setState:
A698880 mov      x0, x19
A698884 bl       0x190004690 ; _animateFreeMomentum
A698888 cbz      w0, 0x18a698860
A69888C mov      x0, x19
A698890 mov      w2, #0x3
A6988A0 add      sp, sp, #0x50
A6988B4 b        0x19007efc0 ; setState:
A6988B8 mov      x0, x19
A6988C8 add      sp, sp, #0x50
A6988DC b        0x1900342f0 ; _stopGestureScrollTracking
A6988E0 adrp     x0, 360933           ; 0x1e287d000
A6988E4 add      x0, x0, #0x620
A6988E8 adrp     x2, 406074           ; 0x1ed8d2000
A6988EC add      x2, x2, #0x93a
A6988F0 mov      w1, #0x0
A6988F4 mov      x3, #0x0
A6988F8 bl       __NSGetBoolAppConfig
A6988FC cbnz     w0, 0x18a6987c4
A698900 b        0x18a6987f0
-[NSScrollingBehaviorConcurrentVBL _isTouchMomentum]:
A8FAAF0 add      x29, sp, #0x10
A8FAAF4 adrp     x8, 405444           ; 0x1ed8be000
A8FAAF8 ldrsw    x8, [x8, #0xba4]
A8FAAFC add      x8, x0, x8
A8FAB00 ldr      x19, [x8]
A8FAB04 adrp     x8, 410187           ; 0x1eeb45000
A8FAB08 add      x0, x8, #0xb70       ; _OBJC_CLASS_$__NSScrollingMomentumBasCalculator
A8FAB0C bl       0x19010ce70
A8FAB10 cmp      x19, x0
A8FAB14 cset     w0, eq
A8FAB20 retab
-[NSScrollingBehaviorConcurrentVBL _animateFreeMomentum]:
A8FAB50 add      x29, sp, #0x90
A8FAB54 sub      sp, sp, #0x180
A8FAB58 mov      x19, x0
A8FAB5C sub      x8, x29, #0xc0
A8FAB60 stp      xzr, x8, [x29, #-0xc0]
A8FAB64 adrp     x8, 3827             ; 0x18b7ed000
A8FAB68 ldr      d0, [x8, #0x628]
A8FAB6C stur     d0, [x29, #-0xb0]
A8FAB70 adrp     x8, 3834             ; 0x18b7f4000
A8FAB74 add      x8, x8, #0xb80
A8FAB78 stp      xzr, xzr, [x29, #-0xa0]
A8FAB7C stur     x8, [x29, #-0xa8]
A8FAB80 sub      x8, x29, #0xf0
A8FAB84 stp      xzr, x8, [x29, #-0xf0]
A8FAB88 stur     d0, [x29, #-0xe0]
A8FAB8C adrp     x8, 3834             ; 0x18b7f4000
A8FAB90 add      x8, x8, #0xb80
A8FAB94 stp      xzr, xzr, [x29, #-0xd0]
A8FAB98 stur     x8, [x29, #-0xd8]
A8FAB9C add      x8, sp, #0xf0
A8FABA0 stp      xzr, x8, [sp, #0xf0]
A8FABA4 str      d0, [sp, #0x100]
A8FABA8 adrp     x8, 3834             ; 0x18b7f4000
A8FABAC add      x8, x8, #0xb80
A8FABB0 stp      xzr, xzr, [sp, #0x110]
A8FABB4 str      x8, [sp, #0x108]
A8FABB8 add      x8, sp, #0xb0
A8FABBC stp      xzr, x8, [sp, #0xb0]
A8FABC0 adrp     x8, 3827             ; 0x18b7ed000
A8FABC4 ldr      d0, [x8, #0x9a8]
A8FABC8 str      d0, [sp, #0xc0]
A8FABCC adrp     x8, 3834             ; 0x18b7f4000
A8FABD0 add      x8, x8, #0xb80
A8FABD4 str      x8, [sp, #0xc8]
A8FABD8 movi.2d  v0, #0000000000000000
A8FABDC adrp     x8, 405444           ; 0x1ed8be000
A8FABE0 ldrsw    x23, [x8, #0xbb8]
A8FABE4 add      x8, x0, x23
A8FABE8 ldr      x0, [x8]
A8FABEC stp      q0, q0, [sp, #0xd0]
A8FABF0 mov      x2, #0x0
A8FABF4 bl       0x19007c480 ; setPreprocessFilter:
A8FABF8 ldr      x0, [x19, x23]
A8FABFC bl       0x190082680 ; sharedData
A8FAC00 add      x8, sp, #0x70
A8FAC04 adrp     x16, 350418          ; 0x1e01cc000
A8FAC08 ldr      x16, [x16, #0x7d0]
A8FAC0C mov      x17, x8
A8FAC10 movk     x17, #0x6ae1, lsl #48
A8FAC14 pacda    x16, x17
A8FAC18 str      x16, [sp, #0x70]
A8FAC1C adrp     x9, 3827             ; 0x18b7ed000
A8FAC20 ldr      d0, [x9, #0x570]
A8FAC24 str      d0, [sp, #0x78]
A8FAC28 add      x8, x8, #0x10
A8FAC2C adrp     x16, 0               ; 0x18a8fa000
A8FAC30 add      x16, x16, #0xf80     ; ___56-[NSScrollingBehaviorConcurrentVBL _animateFreeMomentum]_block_invoke
A8FAC34 pacia    x16, x8
A8FAC38 adrp     x8, 360228           ; 0x1e281e000
A8FAC3C add      x8, x8, #0x348       ; ___block_descriptor_64_e8_32r40r48r56r_e42_v16?0"_NSScrollingConcurrentSharedData"8l
A8FAC44 add      x8, sp, #0xb0
A8FAC48 sub      x9, x29, #0xc0
A8FAC50 add      x8, sp, #0xf0
A8FAC54 sub      x9, x29, #0xf0
A8FAC5C add      x2, sp, #0x70
A8FAC60 bl       0x190088a80 ; threadSafePropertyAccess:
A8FAC64 adrp     x8, 405444           ; 0x1ed8be000
A8FAC68 ldrsw    x22, [x8, #0xbb4]
A8FAC6C add      x8, x19, x22
A8FAC70 ldr      x0, [x8]
A8FAC74 bl       0x190046670 ; canScrollHorizontally
A8FAC78 tbnz     w0, #0x0, 0x18a8fac84
A8FAC7C ldur     x8, [x29, #-0xe8]
A8FAC80 str      xzr, [x8, #0x20]
A8FAC84 ldr      x0, [x19, x22]
A8FAC88 bl       0x190046680 ; canScrollVertically
A8FAC8C ldur     x8, [x29, #-0xe8]
A8FAC90 cbz      w0, 0x18a8fac9c
A8FAC94 ldr      d0, [x8, #0x28]
A8FAC98 b        0x18a8faca4
A8FAC9C str      xzr, [x8, #0x28]
A8FACA0 movi.2d  v0, #0000000000000000
A8FACA4 ldr      d1, [x8, #0x20]!
A8FACA8 adrp     x9, 405444           ; 0x1ed8be000
A8FACAC ldrsw    x9, [x9, #0xba8]
A8FACB0 add      x9, x19, x9
A8FACB4 ldr      d2, [x9]
A8FACB8 fmul     d0, d0, d0
A8FACBC fmadd    d0, d1, d1, d0
A8FACC0 fmul     d1, d2, d2
A8FACC4 fcmp     d0, d1
A8FACC8 b.ge     0x18a8facdc
A8FACCC adrp     x9, 350327           ; 0x1e0171000
A8FACD0 ldr      x9, [x9, #0x968]
A8FACD4 ldr      q0, [x9]
A8FACD8 str      q0, [x8]
A8FACDC mov      x0, x19
A8FACE0 bl       0x19001c4b0 ; _isTouchMomentum
A8FACE4 cbz      w0, 0x18a8fad3c
A8FACE8 ldur     x8, [x29, #-0xb8]
A8FACEC ldr      d9, [x8, #0x20]
A8FACF0 ldr      x0, [x19, x22]
A8FACF4 bl       0x19005c670 ; initialClipOrigin
A8FACF8 mov.16b  v8, v0
A8FACFC ldur     x8, [x29, #-0xb8]
A8FAD00 ldr      d10, [x8, #0x28]
A8FAD04 ldr      x0, [x19, x22]
A8FAD08 bl       0x19005c670 ; initialClipOrigin
A8FAD0C fsub     d0, d9, d8
A8FAD10 fsub     d1, d10, d1
A8FAD14 bl       0x19010c8e0
A8FAD18 mov.16b  v2, v0
A8FAD1C ldur     x8, [x29, #-0xe8]
A8FAD20 ldp      d0, d1, [x8, #0x20]
A8FAD24 mov      x0, x19
A8FAD28 bl       0x190013c80 ; _fastScrollMultiplierForLiftOffVelocity:dragDistance:
A8FAD2C ldur     x8, [x29, #-0xe8]
A8FAD30 ldr      q1, [x8, #0x20]
A8FAD34 fmul.2d  v0, v1, v0[0]
A8FAD38 str      q0, [x8, #0x20]
A8FAD3C ldr      x0, [x19, x23]
A8FAD40 bl       0x190049730 ; constantData
A8FAD44 bl       0x19005c730 ; initialOriginConstraintLoc
A8FAD48 mov.16b  v9, v0
A8FAD4C mov.16b  v8, v1
A8FAD50 ldr      x8, [sp, #0xb8]
A8FAD54 ldr      d10, [x8, #0x20]
A8FAD58 ldr      x0, [x19, x23]
A8FAD5C bl       0x190049730 ; constantData
A8FAD60 bl       0x19005c6b0 ; initialDocumentFrame
A8FAD64 mov.16b  v15, v0
A8FAD68 str      d8, [sp, #0x38]
A8FAD6C ldr      x8, [sp, #0xb8]
A8FAD70 ldr      d8, [x8, #0x28]
A8FAD74 ldr      x0, [x19, x23]
A8FAD78 bl       0x190049730 ; constantData
A8FAD7C bl       0x19005c6b0 ; initialDocumentFrame
A8FAD80 mov.16b  v13, v1
A8FAD84 adrp     x8, 405444           ; 0x1ed8be000
A8FAD88 ldrsw    x8, [x8, #0xba4]
A8FAD8C add      x8, x19, x8
A8FAD90 ldr      x0, [x8]
A8FAD94 bl       0x19010cc80
A8FAD98 mov      x20, x0
A8FAD9C ldur     x26, [x29, #-0xb8]
A8FADA0 ldur     x25, [x29, #-0xe8]
A8FADA4 ldr      x24, [sp, #0xb8]
A8FADA8 ldr      x21, [sp, #0xf8]
A8FADAC ldr      x0, [x19, x22]
A8FADB0 bl       0x190069410 ; pointsPerPixel
A8FADB4 mov.16b  v11, v0
A8FADB8 mov.16b  v12, v1
A8FADBC ldr      x0, [x19, x22]
A8FADC0 bl       0x19004c920 ; decelerationRate
A8FADC4 mov.16b  v14, v0
A8FADC8 ldr      x0, [x19, x22]
A8FADCC cbz      x0, 0x18a8faddc
A8FADD0 add      x8, sp, #0x40
A8FADD4 bl       0x1900414c0 ; affineTransformToClipView
A8FADD8 b        0x18a8fade8
A8FADDC movi.2d  v0, #0000000000000000
A8FADE0 stp      q0, q0, [sp, #0x50]
A8FADE4 str      q0, [sp, #0x40]
A8FADE8 fsub     d0, d10, d15
A8FADEC fadd     d9, d9, d0
A8FADF0 fsub     d0, d8, d13
A8FADF4 ldr      d1, [sp, #0x38]
A8FADF8 fadd     d8, d1, d0
A8FADFC add      x0, sp, #0x40
A8FAE00 bl       0x190103c50
A8FAE04 mov      x2, x0
A8FAE08 ldp      d0, d1, [x26, #0x20]
A8FAE0C ldp      d2, d3, [x25, #0x20]
A8FAE10 ldp      d4, d5, [x24, #0x20]
A8FAE14 ldp      d6, d7, [x24, #0x30]
A8FAE18 ldp      d16, d17, [x21, #0x20]
A8FAE28 str      d9, [sp]
A8FAE2C mov      x0, x20
A8FAE30 bl       0x19005a460 ; initWithInitialOrigin:initialVelocity:documentFrame:constrainedClippingOrigin:clippingSize:tolerance:decelerationRate:shouldRoundCalculations:
A8FAE34 mov      x20, x0
A8FAE38 ldur     x25, [x29, #-0xb8]
A8FAE3C ldur     x24, [x29, #-0xe8]
A8FAE40 mov      x0, #0x0
A8FAE44 mov      w1, #0x502a
A8FAE48 movk     w1, #0xfe, lsl #16
A8FAE4C bl       0x19010c580
A8FAE50 mov      x21, x0
A8FAE54 mov      x0, x19
A8FAE58 bl       0x190054c80 ; gestureToken
A8FAE5C mov      x4, x0
A8FAE60 ldp      d0, d1, [x25, #0x20]
A8FAE64 ldp      d2, d3, [x24, #0x20]
A8FAE68 mov      x0, x19
A8FAE6C mov      x2, x20
A8FAE70 mov      x3, x21
A8FAE74 bl       0x190005370 ; _asynchronouslyAllowDelegateToAdjustMomentum:withInitialOrigin:velocity:synchronousTimeout:gestureToken:
A8FAE78 mov      x21, x0
A8FAE7C adrp     x8, 410170           ; 0x1eeb34000
A8FAE80 add      x0, x8, #0xa98       ; _OBJC_CLASS_$__NSScrollingConcurrentMomentumAnimation
A8FAE84 bl       0x19010cc80
A8FAE88 ldr      x3, [x19, x22]
A8FAE8C mov      x2, x20
A8FAE90 bl       0x19005aa70 ; initWithMomentumCalculator:constantData:
A8FAE94 mov      x22, x0
A8FAE98 mov      x2, x19
A8FAE9C bl       0x19007d7f0 ; setScrollStateDelegate:
A8FAEA0 ldr      x0, [x19, x23]
A8FAEA4 mov      x2, x22
A8FAEA8 bl       0x19007c480 ; setPreprocessFilter:
A8FAEAC mov      x0, x20
A8FAEB0 bl       0x19010ced0
A8FAEB4 mov      x0, x22
A8FAEB8 bl       0x19010ced0
A8FAEBC add      x0, sp, #0xb0
A8FAEC0 mov      w1, #0x8
A8FAEC4 bl       0x19010b010
A8FAEC8 add      x0, sp, #0xf0
A8FAECC mov      w1, #0x8
A8FAED0 bl       0x19010b010
A8FAED4 sub      x0, x29, #0xf0
A8FAED8 mov      w1, #0x8
A8FAEDC bl       0x19010b010
A8FAEE0 sub      x0, x29, #0xc0
A8FAEE4 mov      w1, #0x8
A8FAEE8 bl       0x19010b010
A8FAEEC mov      x0, x21
A8FAEF0 add      sp, sp, #0x180
A8FAF1C retab
A8FAF20 b        0x18a8faf44
A8FAF24 b        0x18a8faf44
A8FAF28 b        0x18a8faf44
A8FAF2C b        0x18a8faf44
A8FAF30 b        0x18a8faf44
A8FAF34 b        0x18a8faf44
A8FAF38 b        0x18a8faf44
A8FAF3C b        0x18a8faf44
A8FAF40 b        0x18a8faf44
A8FAF44 mov      x19, x0
A8FAF48 add      x0, sp, #0xb0
A8FAF4C mov      w1, #0x8
A8FAF50 bl       0x19010b010
A8FAF54 add      x0, sp, #0xf0
A8FAF58 mov      w1, #0x8
A8FAF5C bl       0x19010b010
A8FAF60 sub      x0, x29, #0xf0
A8FAF64 mov      w1, #0x8
A8FAF68 bl       0x19010b010
A8FAF6C sub      x0, x29, #0xc0
A8FAF70 mov      w1, #0x8
A8FAF74 bl       0x19010b010
A8FAF78 mov      x0, x19
A8FAF7C bl       0x1900f84e0
___56-[NSScrollingBehaviorConcurrentVBL _animateFreeMomentum]_block_invoke:
A8FAF80 ldr      x8, [x0, #0x20]
A8FAF84 ldr      x8, [x8, #0x8]
A8FAF88 ldp      q0, q1, [x1, #0x90]
A8FAF8C stp      q0, q1, [x8, #0x20]
A8FAF90 ldr      x8, [x0, #0x28]
A8FAF94 ldr      x8, [x8, #0x8]
A8FAF98 ldur     q0, [x1, #0x48]
A8FAF9C str      q0, [x8, #0x20]
A8FAFA0 ldr      x8, [x0, #0x30]
A8FAFA4 ldr      x8, [x8, #0x8]
A8FAFA8 ldr      q0, [x1, #0xd0]
A8FAFAC str      q0, [x8, #0x20]
A8FAFB0 ldr      x8, [x0, #0x38]
A8FAFB4 ldr      x8, [x8, #0x8]
A8FAFB8 ldur     q0, [x1, #0x58]
A8FAFBC str      q0, [x8, #0x20]
A8FAFC0 ret

; ===== -[NSScrollingBehaviorConcurrentVBL scrollStateEvent:sender:] =====
-[NSScrollingBehaviorConcurrentVBL scrollStateEvent:sender:]:
A66D4BC sub      sp, sp, #0x70
A66D4D4 add      x29, sp, #0x60
A66D4D8 mov      x20, x2
A66D4DC mov      x21, x1
A66D4E0 mov      x19, x0
A66D4E4 adrp     x8, 406097           ; 0x1ed8be000
A66D4E8 ldrsw    x23, [x8, #0xb9c]
A66D4EC add      x0, x0, x23
A66D4F0 bl       0x19010d250
A66D4F4 adrp     x8, 396756           ; 0x1eb441000
A66D4F8 add      x8, x8, #0xbe2       ; _sNSScrollingBehaviorDebugStateChangesComputedValue
A66D4FC ldarb    w8, [x8]
A66D500 cmp      w8, #0x2
A66D504 b.eq     0x18a66d550
A66D508 cbz      w8, 0x18a66d8d0
A66D50C mov      x0, x19
A66D510 bl       0x19010ce70
A66D514 bl       0x1901091c0
A66D518 mov      x22, x0
A66D51C mov      x0, x21
A66D520 bl       0x190109210
A66D524 mov      x21, x0
A66D528 mov      x0, x19
A66D52C bl       0x190085730 ; state
A66D530 adrp     x8, 352404           ; 0x1e0701000
A66D534 add      x8, x8, #0x820       ; _scrollStateEvent:sender:.debugStateStrings
A66D538 ldr      x8, [x8, x20, lsl #3]
A66D544 adrp     x0, 360991           ; 0x1e288c000
A66D548 add      x0, x0, #0x40
A66D54C bl       0x190108fb0
A66D550 cmp      x20, #0x9
A66D554 b.gt     0x18a66d584
A66D558 sub      x8, x20, #0x6
A66D55C cmp      x8, #0x2
A66D560 b.hs     0x18a66d5ac
A66D564 adrp     x8, 406097           ; 0x1ed8be000
A66D568 ldrsw    x8, [x8, #0xbb8]
A66D56C add      x8, x19, x8
A66D570 ldr      x0, [x8]
A66D574 bl       0x190082680 ; sharedData
A66D578 adrp     x2, 360949           ; 0x1e2862000
A66D57C add      x2, x2, #0xb18       ; ___block_literal_global.125
A66D580 b        0x18a66d5d0
A66D584 cmp      x20, #0xb
A66D588 b.eq     0x18a66d5d8
A66D58C cmp      x20, #0xa
A66D590 b.ne     0x18a66d5f0
A66D594 adrp     x8, 406097           ; 0x1ed8be000
A66D598 ldrsw    x8, [x8, #0xbd8]
A66D59C add      x8, x19, x8
A66D5A0 ldr      w9, [x8]
A66D5A4 orr      w9, w9, #0x1
A66D5A8 b        0x18a66d5ec
A66D5AC cmp      x20, #0x5
A66D5B0 b.ne     0x18a66d5f0
A66D5B4 adrp     x8, 406097           ; 0x1ed8be000
A66D5B8 ldrsw    x8, [x8, #0xbb8]
A66D5BC add      x8, x19, x8
A66D5C0 ldr      x0, [x8]
A66D5C4 bl       0x190082680 ; sharedData
A66D5C8 adrp     x2, 360881           ; 0x1e281e000
A66D5CC add      x2, x2, #0x268       ; ___block_literal_global.123
A66D5D0 bl       0x190088a80 ; threadSafePropertyAccess:
A66D5D4 b        0x18a66d5f0
A66D5D8 adrp     x8, 406097           ; 0x1ed8be000
A66D5DC ldrsw    x8, [x8, #0xbd8]
A66D5E0 add      x8, x19, x8
A66D5E4 ldr      w9, [x8]
A66D5E8 and      w9, w9, #0xfffffffe
A66D5EC str      w9, [x8]
A66D5F0 adrp     x8, 406097           ; 0x1ed8be000
A66D5F4 ldrsw    x8, [x8, #0xbc4]
A66D5F8 add      x8, x19, x8
A66D5FC ldr      x8, [x8]
A66D600 cmp      x8, #0x3
A66D604 b.ne     0x18a66d638
A66D608 add      x0, x19, x23
A66D620 add      sp, sp, #0x70
A66D634 b        0x19010d260
A66D638 mov      x0, x19
A66D63C bl       0x190085730 ; state
A66D640 cmp      x0, #0x2
A66D644 b.le     0x18a66d674
A66D648 cmp      x0, #0x3
A66D64C b.eq     0x18a66d6b4
A66D650 cmp      x0, #0x4
A66D654 b.eq     0x18a66d708
A66D658 cmp      x0, #0x5
A66D65C b.ne     0x18a66d608
A66D660 cmp      x20, #0xb
A66D664 b.eq     0x18a66d7a8
A66D668 cmp      x20, #0x4
A66D66C b.ne     0x18a66d738
A66D670 b        0x18a66d7a8
A66D674 cmp      x0, #0x1
A66D678 b.eq     0x18a66d744
A66D67C cmp      x0, #0x2
A66D680 b.ne     0x18a66d608
A66D684 cmp      x20, #0x8
A66D688 b.eq     0x18a66d7d4
A66D68C cmp      x20, #0x2
A66D690 b.eq     0x18a66d7b4
A66D694 cmp      x20, #0x1
A66D698 b.ne     0x18a66d608
A66D69C adrp     x8, 406097           ; 0x1ed8be000
A66D6A0 ldrsw    x8, [x8, #0xbd8]
A66D6A4 add      x8, x19, x8
A66D6A8 ldrb     w8, [x8]
A66D6AC tbnz     w8, #0x0, 0x18a66d81c
A66D6B0 b        0x18a66d608
A66D6B4 cmp      x20, #0x5
A66D6B8 b.gt     0x18a66d768
A66D6BC cmp      x20, #0x1
A66D6C0 b.eq     0x18a66d7e4
A66D6C4 cmp      x20, #0x2
A66D6C8 b.ne     0x18a66d608
A66D6CC adrp     x8, 406097           ; 0x1ed8be000
A66D6D0 ldrsw    x8, [x8, #0xbd8]
A66D6D4 add      x8, x19, x8
A66D6D8 ldrb     w8, [x8]
A66D6DC tbz      w8, #0x0, 0x18a66d608
A66D6E0 adrp     x8, 406097           ; 0x1ed8be000
A66D6E4 ldrsw    x8, [x8, #0xbb4]
A66D6E8 add      x8, x19, x8
A66D6EC ldr      x0, [x8]
A66D6F0 bl       0x1900566b0 ; hasSwipeForwardingResponder
A66D6F4 cbz      w0, 0x18a66d7c8
A66D6F8 mov      x0, x19
A66D6FC bl       0x19001c260 ; _isStretched
A66D700 tbz      w0, #0x0, 0x18a66d7c8
A66D704 b        0x18a66d608
A66D708 adrp     x8, 406097           ; 0x1ed8be000
A66D70C ldrsw    x8, [x8, #0xbdc]
A66D710 add      x9, x19, x8
A66D714 ldr      x9, [x9]
A66D718 cbz      x9, 0x18a66d728
A66D71C mov      w10, #0x1
A66D720 strb     w10, [x9]
A66D724 str      xzr, [x19, x8]
A66D728 cmp      x20, #0x8
A66D72C b.gt     0x18a66d77c
A66D730 cmp      x20, #0x1
A66D734 b.eq     0x18a66d81c
A66D738 cmp      x20, #0x2
A66D73C b.eq     0x18a66d7c8
A66D740 b        0x18a66d608
A66D744 cmp      x20, #0x4
A66D748 b.le     0x18a66d798
A66D74C cmp      x20, #0x5
A66D750 b.eq     0x18a66d7a8
A66D754 cmp      x20, #0xc
A66D758 b.eq     0x18a66d8c4
A66D75C cmp      x20, #0xb
A66D760 b.eq     0x18a66d7a8
A66D764 b        0x18a66d608
A66D768 cmp      x20, #0x6
A66D76C b.eq     0x18a66d828
A66D770 cmp      x20, #0x7
A66D774 b.eq     0x18a66d78c
A66D778 b        0x18a66d608
A66D77C cmp      x20, #0x9
A66D780 b.eq     0x18a66d78c
A66D784 cmp      x20, #0xb
A66D788 b.ne     0x18a66d608
A66D78C mov      x0, x19
A66D790 bl       0x1900342f0 ; _stopGestureScrollTracking
A66D794 b        0x18a66d608
A66D798 cmp      x20, #0x3
A66D79C b.eq     0x18a66d7a8
A66D7A0 cmp      x20, #0x4
A66D7A4 b.ne     0x18a66d608
A66D7A8 mov      x0, x19
A66D7AC bl       0x190004700 ; _animateMomentum
A66D7B0 b        0x18a66d608
A66D7B4 adrp     x8, 406097           ; 0x1ed8be000
A66D7B8 ldrsw    x8, [x8, #0xbd8]
A66D7BC add      x8, x19, x8
A66D7C0 ldrb     w8, [x8]
A66D7C4 tbz      w8, #0x0, 0x18a66d608
A66D7C8 mov      x0, x19
A66D7CC bl       0x1900064e0 ; _beginPhysicalScroll
A66D7D0 b        0x18a66d608
A66D7D4 mov      x0, x19
A66D7D8 mov      w2, #0x3
A66D7DC bl       0x19007efc0 ; setState:
A66D7E0 b        0x18a66d608
A66D7E4 adrp     x8, 406097           ; 0x1ed8be000
A66D7E8 ldrsw    x8, [x8, #0xbd8]
A66D7EC add      x8, x19, x8
A66D7F0 ldrb     w8, [x8]
A66D7F4 tbz      w8, #0x0, 0x18a66d608
A66D7F8 adrp     x8, 406097           ; 0x1ed8be000
A66D7FC ldrsw    x8, [x8, #0xbb4]
A66D800 add      x8, x19, x8
A66D804 ldr      x0, [x8]
A66D808 bl       0x1900566b0 ; hasSwipeForwardingResponder
A66D80C cbz      w0, 0x18a66d81c
A66D810 mov      x0, x19
A66D814 bl       0x19001c260 ; _isStretched
A66D818 tbnz     w0, #0x0, 0x18a66d608
A66D81C mov      x0, x19
A66D820 bl       0x19008dd60 ; waitForEvent
A66D824 b        0x18a66d608
A66D828 adrp     x8, 406097           ; 0x1ed8be000
A66D82C ldrsw    x8, [x8, #0xbb4]
A66D830 add      x8, x19, x8
A66D834 ldr      x0, [x8]
A66D838 bl       0x19004c920 ; decelerationRate
A66D83C fcmp     d0, #0.0
A66D840 b.hi     0x18a66d608
A66D844 mov      x0, x19
A66D848 bl       0x19001c260 ; _isStretched
A66D84C tbnz     w0, #0x0, 0x18a66d608
A66D850 adrp     x8, 406097           ; 0x1ed8be000
A66D854 ldrsw    x20, [x8, #0xbd8]
A66D858 add      x8, x19, x20
A66D85C ldrb     w8, [x8]
A66D860 tbnz     w8, #0x1, 0x18a66d608
A66D864 adrp     x8, 406097           ; 0x1ed8be000
A66D868 ldrsw    x21, [x8, #0xbbc]
A66D86C add      x8, x19, x21
A66D870 ldr      x0, [x8]
A66D874 bl       0x19004d6d0 ; deltaIsAccelerated
A66D878 movi.2d  v8, #0000000000000000
A66D87C cbz      w0, 0x18a66d888
A66D880 bl       _NSScrollingBehaviorMinAcceleratedStoppableVelocity
A66D884 mov.16b  v8, v0
A66D888 ldr      x0, [x19, x21]
A66D88C bl       0x19008d0a0 ; velocity
A66D890 fabs     d0, d1
A66D894 fcmp     d0, d8
A66D898 b.ge     0x18a66d8b0
A66D89C ldr      x0, [x19, x21]
A66D8A0 bl       0x19008d0a0 ; velocity
A66D8A4 fabs     d0, d0
A66D8A8 fcmp     d0, d8
A66D8AC b.lt     0x18a66d608
A66D8B0 ldrb     w8, [x19, x20]
A66D8B4 tbz      w8, #0x0, 0x18a66d78c
A66D8B8 mov      x0, x19
A66D8BC bl       0x1900474b0 ; checkForGestureContinuance
A66D8C0 b        0x18a66d608
A66D8C4 mov      x0, x19
A66D8C8 bl       0x190039e80 ; _updatePageReferenceNumber
A66D8CC b        0x18a66d608
A66D8D0 adrp     x0, 360991           ; 0x1e288c000
A66D8D4 add      x0, x0, #0x1e0
A66D8D8 adrp     x2, 396756           ; 0x1eb441000
A66D8DC add      x2, x2, #0xbe2       ; _sNSScrollingBehaviorDebugStateChangesComputedValue
A66D8E0 mov      w1, #0x0
A66D8E4 mov      x3, #0x0
A66D8E8 bl       __NSGetBoolAppConfig
A66D8EC cbnz     w0, 0x18a66d50c
A66D8F0 b        0x18a66d550

; ===== -[_NSScrollingConcurrentMomentumAnimation scrollingVBLMonitor:synchronizeForTimestamp:] (head) =====
-[_NSScrollingConcurrentMomentumAnimation scrollingVBLMonitor:synchronizeForTimestamp:]:
A7F38F8 add      x29, sp, #0x60
A7F38FC sub      sp, sp, #0x200
A7F3900 mov      x20, x2
A7F3904 mov      x21, x1
A7F3908 mov      x19, x0
A7F390C ldr      d1, [x0, #0x10]
A7F3910 fsub     d8, d0, d1
A7F3914 ldr      x0, [x0, #0x28]
A7F3918 bl       0x1900509f0 ; durationUntilStop
A7F391C mov.16b  v11, v0
A7F3920 ldr      x0, [x19, #0x28]
A7F3924 bl       0x19004da80 ; destinationOrigin
A7F3928 sub      x8, x29, #0x80
A7F392C stp      xzr, x8, [x29, #-0x80]
A7F3930 adrp     x8, 4090             ; 0x18b7ed000
A7F3934 ldr      d12, [x8, #0x5b0]
A7F3938 stur     d12, [x29, #-0x70]
A7F393C stur     xzr, [x29, #-0x68]
A7F3940 fcmp     d8, d11
A7F3944 b.pl     0x18a7f3ba0
A7F3948 sub      x8, x29, #0xb0
A7F394C stp      xzr, x8, [x29, #-0xb0]
A7F3950 adrp     x8, 4090             ; 0x18b7ed000
A7F3954 ldr      d9, [x8, #0x628]
A7F3958 stur     d9, [x29, #-0xa0]
A7F395C adrp     x8, 4097             ; 0x18b7f4000
A7F3960 add      x8, x8, #0xb80
A7F3964 stp      xzr, xzr, [x29, #-0x90]
A7F3968 stur     x8, [x29, #-0x98]
A7F396C ldr      x0, [x19, #0x28]
A7F3970 mov.16b  v0, v8
A7F3974 bl       0x1900697b0 ; positionAfterDuration:
A7F3978 stp      d0, d1, [x29, #-0x90]
A7F397C sub      x8, x29, #0xd0
A7F3980 stp      xzr, x8, [x29, #-0xd0]
A7F3984 ldr      x0, [x19, #0x28]
A7F3988 stur     d12, [x29, #-0xc0]
A7F398C mov.16b  v0, v8
A7F3990 bl       0x19008d0b0 ; velocityAfterDuration:
A7F3994 stur     d0, [x29, #-0xb8]
A7F3998 sub      x8, x29, #0x100
A7F399C stp      xzr, x8, [x29, #-0x100]
A7F39A0 stur     d9, [x29, #-0xf0]
A7F39A4 adrp     x8, 4097             ; 0x18b7f4000
A7F39A8 add      x8, x8, #0xb80
A7F39AC stp      xzr, xzr, [x29, #-0xe0]
A7F39B0 ldr      x0, [x19, #0x28]
A7F39B4 stur     x8, [x29, #-0xe8]
A7F39B8 mov.16b  v0, v8
A7F39BC bl       0x19008d0e0 ; velocityVectorAfterDuration:
A7F39C0 stp      d0, d1, [x29, #-0xe0]
A7F39C4 add      x22, sp, #0x130
A7F39C8 stp      xzr, x22, [sp, #0x130]
A7F39CC str      d9, [sp, #0x140]
A7F39D0 adrp     x8, 4097             ; 0x18b7f4000
A7F39D4 add      x8, x8, #0xb80
A7F39D8 stp      xzr, xzr, [sp, #0x150]
A7F39DC ldr      x0, [x19, #0x28]
A7F39E0 str      x8, [sp, #0x148]
A7F39E4 bl       0x19004da80 ; destinationOrigin
A7F39EC add      x8, sp, #0x110
A7F39F0 stp      xzr, x8, [sp, #0x110]
A7F39F4 str      d12, [sp, #0x120]
A7F39F8 strb     wzr, [sp, #0x128]
A7F39FC add      x9, sp, #0xe0
A7F3A00 stp      xzr, x9, [sp, #0xe0]
A7F3A04 str      d9, [sp, #0xf0]
A7F3A08 adrp     x10, 4097            ; 0x18b7f4000
A7F3A0C add      x10, x10, #0xb80

; ===== config getters =====
_NSScrollViewScrollVelocityZeroingTimeout:
B1D0F1C adrp     x2, 403209           ; 0x1ed8d9000
B1D0F20 add      x2, x2, #0xe88       ; __MergedGlobals
B1D0F24 ldarb    w8, [x2]
B1D0F28 cmp      w8, #0x1
B1D0F2C b.ne     0x18b1d0f44
B1D0F30 adrp     x8, 403209           ; 0x1ed8d9000
B1D0F34 add      x8, x8, #0xe98
B1D0F38 ldar     x8, [x8]
B1D0F3C fmov     d0, x8
B1D0F40 ret
B1D0F44 adrp     x0, 358197           ; 0x1e2905000
B1D0F48 add      x0, x0, #0xbc0
B1D0F4C adrp     x8, 1565             ; 0x18b7ed000
B1D0F50 ldr      d0, [x8, #0x6c8]
B1D0F54 add      x1, x2, #0x10
B1D0F58 mov      x3, #0x0
B1D0F5C b        __NSGetCGFloatAppConfig
_NSScrollViewScrollVelocityMax:
B1D0F60 adrp     x2, 403209           ; 0x1ed8d9000
B1D0F64 add      x2, x2, #0xe89
B1D0F68 ldarb    w8, [x2]
B1D0F6C cmp      w8, #0x1
B1D0F70 b.ne     0x18b1d0f88
B1D0F74 adrp     x8, 403209           ; 0x1ed8d9000
B1D0F78 add      x8, x8, #0xea0
B1D0F7C ldar     x8, [x8]
B1D0F80 fmov     d0, x8
B1D0F84 ret
B1D0F88 adrp     x0, 358197           ; 0x1e2905000
B1D0F8C add      x0, x0, #0xbe0
B1D0F90 adrp     x8, 1567             ; 0x18b7ef000
B1D0F94 ldr      d0, [x8, #0xaf8]
B1D0F98 add      x1, x2, #0x17
B1D0F9C mov      x3, #0x0
B1D0FA0 b        __NSGetCGFloatAppConfig
_NSScrollViewRubberbandStiffness:
B1D0FA4 adrp     x2, 403209           ; 0x1ed8d9000
B1D0FA8 add      x2, x2, #0xe8a
B1D0FAC ldarb    w8, [x2]
B1D0FB0 cmp      w8, #0x1
B1D0FB4 b.ne     0x18b1d0fcc
B1D0FB8 adrp     x8, 403209           ; 0x1ed8d9000
B1D0FBC add      x8, x8, #0xea8
B1D0FC0 ldar     x8, [x8]
B1D0FC4 fmov     d0, x8
B1D0FC8 ret
B1D0FCC adrp     x0, 358197           ; 0x1e2905000
B1D0FD0 add      x0, x0, #0xc00
B1D0FD4 fmov     d0, #20.00000000
B1D0FD8 add      x1, x2, #0x1e
B1D0FDC mov      x3, #0x0
B1D0FE0 b        __NSGetCGFloatAppConfig
_NSScrollViewRubberbandDirectionLockStretchRatio:
B1D0FE4 adrp     x2, 403209           ; 0x1ed8d9000
B1D0FE8 add      x2, x2, #0xe8b
B1D0FEC ldarb    w8, [x2]
B1D0FF0 cmp      w8, #0x1
B1D0FF4 b.ne     0x18b1d100c
B1D0FF8 adrp     x8, 403209           ; 0x1ed8d9000
B1D0FFC add      x8, x8, #0xeb0
B1D1000 ldar     x8, [x8]
B1D1004 fmov     d0, x8
B1D1008 ret
B1D100C adrp     x0, 358196           ; 0x1e2905000
B1D1010 add      x0, x0, #0xc20
B1D1014 fmov     d0, #1.00000000
B1D1018 add      x1, x2, #0x25
B1D101C mov      x3, #0x0
B1D1020 b        __NSGetCGFloatAppConfig
_NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch:
B1D1024 adrp     x2, 403208           ; 0x1ed8d9000
B1D1028 add      x2, x2, #0xe8c
B1D102C ldarb    w8, [x2]
B1D1030 cmp      w8, #0x1
B1D1034 b.ne     0x18b1d104c
B1D1038 adrp     x8, 403208           ; 0x1ed8d9000
B1D103C add      x8, x8, #0xeb8
B1D1040 ldar     x8, [x8]
B1D1044 fmov     d0, x8
B1D1048 ret
B1D104C adrp     x0, 358196           ; 0x1e2905000
B1D1050 add      x0, x0, #0xc40
B1D1054 fmov     d0, #10.00000000
B1D1058 add      x1, x2, #0x2c
B1D105C mov      x3, #0x0
B1D1060 b        __NSGetCGFloatAppConfig
_NSScrollingBehaviorMinAcceleratedStoppableVelocity:
B1D1064 adrp     x2, 403208           ; 0x1ed8d9000
B1D1068 add      x2, x2, #0xe8d
B1D106C ldarb    w8, [x2]
B1D1070 cmp      w8, #0x1
B1D1074 b.ne     0x18b1d108c
B1D1078 adrp     x8, 403208           ; 0x1ed8d9000
B1D107C add      x8, x8, #0xec0
B1D1080 ldar     x8, [x8]
B1D1084 fmov     d0, x8
B1D1088 ret
B1D108C adrp     x0, 358196           ; 0x1e2905000
B1D1090 add      x0, x0, #0xc60
B1D1094 adrp     x8, 1564             ; 0x18b7ed000
B1D1098 ldr      d0, [x8, #0x5a8]
B1D109C add      x1, x2, #0x33
B1D10A0 mov      x3, #0x0
B1D10A4 b        __NSGetCGFloatAppConfig
_NSScrollingVFDReducedFPS:
B1D10A8 adrp     x2, 403208           ; 0x1ed8d9000
B1D10AC add      x2, x2, #0xe8e
B1D10B0 ldarb    w8, [x2]
B1D10B4 cmp      w8, #0x1
B1D10B8 b.ne     0x18b1d10d0
B1D10BC adrp     x8, 403208           ; 0x1ed8d9000
B1D10C0 add      x8, x8, #0xec8
B1D10C4 ldar     x8, [x8]
B1D10C8 fmov     d0, x8
B1D10CC ret
B1D10D0 adrp     x0, 358196           ; 0x1e2905000
B1D10D4 add      x0, x0, #0xc80
B1D10D8 mov      x8, #0x404e000000000000
B1D10DC fmov     d0, x8
B1D10E0 add      x1, x2, #0x3a
B1D10E4 mov      x3, #0x0
B1D10E8 b        __NSGetCGFloatAppConfig
_NSScrollingVFDVelocityThreshold:
B1D10EC adrp     x2, 403208           ; 0x1ed8d9000
B1D10F0 add      x2, x2, #0xe8f
B1D10F4 ldarb    w8, [x2]
B1D10F8 cmp      w8, #0x1
B1D10FC b.ne     0x18b1d1114
B1D1100 adrp     x8, 403208           ; 0x1ed8d9000
B1D1104 add      x8, x8, #0xed0
B1D1108 ldar     x8, [x8]
B1D110C fmov     d0, x8
B1D1110 ret
B1D1114 adrp     x0, 358196           ; 0x1e2905000
B1D1118 add      x0, x0, #0xca0
B1D111C mov      x8, #0x4074000000000000
B1D1120 fmov     d0, x8
B1D1124 add      x1, x2, #0x41
B1D1128 mov      x3, #0x0
B1D112C b        __NSGetCGFloatAppConfig
_NSScrollViewScrollingPerformanceAnalysisEnabled:
B1D1130 adrp     x8, 393845           ; 0x1eb446000
B1D1134 add      x8, x8, #0xf48       ; _sNSScrollViewScrollingPerformanceAnalysisEnabledComputedValue
B1D1138 ldarb    w8, [x8]
B1D113C cbz      w8, 0x18b1d114c
B1D1140 cmp      w8, #0x2
B1D1144 cset     w0, ne
B1D1148 ret
B1D114C adrp     x0, 358196           ; 0x1e2905000
B1D1150 add      x0, x0, #0xcc0
B1D1154 adrp     x2, 393845           ; 0x1eb446000
B1D1158 add      x2, x2, #0xf48       ; _sNSScrollViewScrollingPerformanceAnalysisEnabledComputedValue
B1D115C mov      w1, #0x1
B1D1160 mov      x3, #0x0
B1D1164 b        __NSGetBoolAppConfig
_NSScrollViewScrollingPerformanceAnalysisLogToPAPerf:
B1D1168 adrp     x8, 393845           ; 0x1eb446000
B1D116C add      x8, x8, #0xf49       ; _sNSScrollViewScrollingPerformanceAnalysisLogToPAPerfComputedValue
B1D1170 ldarb    w8, [x8]
B1D1174 cbz      w8, 0x18b1d1184
B1D1178 cmp      w8, #0x2
B1D117C cset     w0, ne
B1D1180 ret
B1D1184 adrp     x0, 358196           ; 0x1e2905000
B1D1188 add      x0, x0, #0xce0
B1D118C adrp     x2, 393845           ; 0x1eb446000
B1D1190 add      x2, x2, #0xf49       ; _sNSScrollViewScrollingPerformanceAnalysisLogToPAPerfComputedValue
B1D1194 mov      w1, #0x1
B1D1198 mov      x3, #0x0
B1D119C b        __NSGetBoolAppConfig
_NSScrollingTouchMomentumMinimumSpeed:
B1D11A0 adrp     x2, 403208           ; 0x1ed8d9000
B1D11A4 add      x2, x2, #0xe90
B1D11A8 ldarb    w8, [x2]
B1D11AC cmp      w8, #0x1
