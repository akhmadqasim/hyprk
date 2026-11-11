; AppKit 27.2.1 (26B131) arm64e. Drag-time rubber band: hyperbolic maths inlined in the filter; coefficient set per input device.
; stretch = floor(D*(1 - 1/(1 + c*|d|/D))), D = clip size on the axis (_clippingSize +0x20/+0x28), c = _hyperbolicCoefficient (+0x90): trackpad 0.075, touch 0.55.

; ===== -[_NSScrollingRubberbandFilter init] (default c = 0.55 at lit 0x18b7efa28) =====
-[_NSScrollingRubberbandFilter init]:
ACA39B8 pacibsp
ACA39BC sub      sp, sp, #0x30
ACA39C0 stp      x20, x19, [sp, #0x10]
ACA39C4 stp      x29, x30, [sp, #0x20]
ACA39C8 add      x29, sp, #0x20
ACA39CC adrp     x8, 350919           ; 0x1e076a000
ACA39D0 ldr      x8, [x8, #0xe28]
ACA39D4 stp      x0, x8, [sp]
ACA39D8 adrp     x8, 350878           ; 0x1e0741000
ACA39DC ldr      x1, [x8, #0x238]
ACA39E0 mov      x0, sp
ACA39E4 bl       0x19010ce60
ACA39E8 mov      x19, x0
ACA39EC cbz      x0, 0x18aca3a6c
ACA39F0 adrp     x8, 349390           ; 0x1e0171000
ACA39F4 ldr      x0, [x8, #0xe08]
ACA39F8 bl       0x19010ce90
ACA39FC mov      x8, #0x3ff0000000000000
ACA3A00 adrp     x9, 349390           ; 0x1e0171000
ACA3A04 ldr      x9, [x9, #0x968]
ACA3A08 ldr      q0, [x9]
ACA3A0C adrp     x9, 349390           ; 0x1e0171000
ACA3A10 ldr      x9, [x9, #0x978]
ACA3A14 ldr      q1, [x9]
ACA3A18 stp      q0, q1, [x19, #0x10]
ACA3A1C adrp     x9, 349390           ; 0x1e0171000
ACA3A20 ldr      x9, [x9, #0x970]
ACA3A24 ldp      q0, q1, [x9]
ACA3A28 stp      q0, q1, [x19, #0x30]
ACA3A2C adrp     x9, 349377           ; 0x1e0164000
ACA3A30 ldr      x9, [x9, #0xd18]
ACA3A34 ldp      q0, q1, [x9]
ACA3A38 stur     q0, [x19, #0x58]
ACA3A3C str      x0, [x19, #0x8]
ACA3A40 str      x8, [x19, #0x50]
ACA3A44 stur     q1, [x19, #0x68]
ACA3A48 ldr      q0, [x9, #0x20]
ACA3A4C stur     q0, [x19, #0x78]
ACA3A50 adrp     x8, 2892             ; 0x18b7ef000
ACA3A54 ldr      q0, [x8, #0xa20]
ACA3A58 stur     q0, [x19, #0x88]
ACA3A5C ldr      w8, [x19, #0x98]
ACA3A60 and      w8, w8, #0xfffffff8
ACA3A64 orr      w8, w8, #0x6
ACA3A68 str      w8, [x19, #0x98]
ACA3A6C mov      x0, x19
ACA3A70 ldp      x29, x30, [sp, #0x20]
ACA3A74 ldp      x20, x19, [sp, #0x10]
ACA3A78 add      sp, sp, #0x30
ACA3A7C retab

; ===== -[_NSScrollingRubberbandFilter addDelta:velocity:] =====
-[_NSScrollingRubberbandFilter addDelta:velocity:]:
ACA3CD8 pacibsp
ACA3CDC sub      sp, sp, #0x140
ACA3CE0 stp      d15, d14, [sp, #0xb0]
ACA3CE4 stp      d13, d12, [sp, #0xc0]
ACA3CE8 stp      d11, d10, [sp, #0xd0]
ACA3CEC stp      d9, d8, [sp, #0xe0]
ACA3CF0 stp      x28, x27, [sp, #0xf0]
ACA3CF4 stp      x24, x23, [sp, #0x100]
ACA3CF8 stp      x22, x21, [sp, #0x110]
ACA3CFC stp      x20, x19, [sp, #0x120]
ACA3D00 stp      x29, x30, [sp, #0x130]
ACA3D04 add      x29, sp, #0x130
ACA3D08 str      d3, [sp, #0x80]
ACA3D0C str      d2, [sp, #0x98]
ACA3D10 mov      x19, x0
ACA3D14 mov      x21, x0
ACA3D18 ldr      d18, [x21, #0xd0]!
ACA3D1C ldp      d14, d9, [x21, #-0x30]
ACA3D20 ldp      d2, d10, [x21, #-0xb0]
ACA3D24 stur     d2, [x29, #-0x88]
ACA3D28 ldp      d5, d4, [x21, #-0x70]
ACA3D2C ldur     d6, [x21, #-0x60]
ACA3D30 stp      d6, d4, [sp, #0x60]
ACA3D34 fmul     d7, d1, d4
ACA3D38 ldp      d19, d4, [x21, #-0x80]
ACA3D3C stp      d5, d4, [sp, #0x70]
ACA3D40 fmadd    d4, d4, d0, d7
ACA3D44 stp      d1, d0, [sp, #0x88]
ACA3D48 fmul     d1, d1, d6
ACA3D4C fmadd    d1, d5, d0, d1
ACA3D50 fadd     d13, d4, d18
ACA3D54 ldr      d0, [x21, #0x8]
ACA3D58 fadd     d0, d1, d0
ACA3D5C stp      d0, d19, [sp, #0x38]
ACA3D60 adrp     x8, 349390           ; 0x1e0171000
ACA3D64 ldr      x8, [x8, #0x968]
ACA3D68 ldr      q0, [x8]
ACA3D6C str      q0, [x21]
ACA3D70 ldur     w8, [x21, #-0x38]
ACA3D74 tst      w8, #0x2
ACA3D78 cset     w23, eq
ACA3D7C tst      w8, #0x4
ACA3D80 cset     w24, eq
ACA3D84 ldp      d1, d0, [x21, #-0x48]
ACA3D88 str      d1, [sp, #0x48]
ACA3D8C str      d0, [sp, #0x58]
ACA3D90 ldp      d4, d5, [x21, #-0xa0]
ACA3D94 stp      d5, d4, [sp, #0x20]
ACA3D98 ldp      d6, d15, [x21, #-0x90]
ACA3D9C str      d6, [sp, #0x18]
ACA3DA0 ldp      d8, d11, [x21, #-0xc0]
ACA3DA4 ands     w20, w8, #0x1
ACA3DA8 fmov     d0, #1.00000000
ACA3DAC fmov     d1, #-1.00000000
ACA3DB0 fcsel    d0, d1, d0, ne
ACA3DB4 stur     d0, [x29, #-0x90]
ACA3DB8 stp      d8, d11, [sp]
ACA3DBC mov.16b  v0, v14
ACA3DC0 mov.16b  v1, v9
ACA3DC4 mov.16b  v3, v10
ACA3DC8 mov.16b  v7, v15
ACA3DCC mov      x0, x20
ACA3DD0 bl       __NSStretchOfClipBoundsForDocumentFrame
ACA3DD4 str      d0, [sp, #0x10]
ACA3DD8 fabs     d12, d0
ACA3DDC ldr      d5, [sp, #0x40]
ACA3DE0 fcmp     d12, d5
ACA3DE4 cset     w22, pl
ACA3DE8 str      d1, [sp, #0x50]
ACA3DEC fabs     d0, d1
ACA3DF0 str      d0, [sp, #0x30]
ACA3DF4 fsub     d0, d14, d13
ACA3DF8 ldr      d14, [sp, #0x38]
ACA3DFC ldur     d1, [x29, #-0x90]
ACA3E00 fmadd    d1, d1, d14, d9
ACA3E04 stp      d8, d11, [sp]
ACA3E08 ldur     d2, [x29, #-0x88]
ACA3E0C stur     d10, [x29, #-0x90]
ACA3E10 mov.16b  v3, v10
ACA3E14 mov.16b  v9, v5
ACA3E18 ldp      d5, d4, [sp, #0x20]
ACA3E1C ldr      d6, [sp, #0x18]
ACA3E20 mov.16b  v7, v15
ACA3E24 mov      x0, x20
ACA3E28 bl       __NSStretchOfClipBoundsForDocumentFrame
ACA3E2C mov.16b  v11, v0
ACA3E30 mov.16b  v8, v1
ACA3E34 fcmp     d1, #0.0
ACA3E38 cset     w8, ne
ACA3E3C fcmp     d0, #0.0
ACA3E40 cset     w9, ne
ACA3E44 fadd     d0, d14, d1
ACA3E48 ands     w10, w24, w8
ACA3E4C fcsel    d14, d0, d14, ne
ACA3E50 ldr      d2, [sp, #0x30]
ACA3E54 fadd     d0, d13, d11
ACA3E58 ands     w11, w23, w9
ACA3E5C fcsel    d10, d0, d13, ne
ACA3E60 mov.16b  v13, v2
ACA3E64 fcmp     d2, d9
ACA3E68 cset     w20, pl
ACA3E6C bic      w23, w8, w10
ACA3E70 bic      w24, w9, w11
ACA3E74 b.mi     0x18aca3f34
ACA3E78 fcmp     d12, d9
ACA3E7C cset     w8, mi
ACA3E80 and      w8, w8, w24
ACA3E84 cmp      w8, #0x1
ACA3E88 b.ne     0x18aca3fa8
ACA3E8C mov.16b  v15, v12
ACA3E90 fcmp     d14, #0.0
ACA3E94 b.eq     0x18aca3eac
ACA3E98 fdiv     d0, d10, d14
ACA3E9C fabs     d12, d0
ACA3EA0 bl       _NSScrollViewRubberbandDirectionLockStretchRatio
ACA3EA4 fcmp     d12, d0
ACA3EA8 b.mi     0x18aca3ec8
ACA3EAC fabs     d12, d10
ACA3EB0 bl       _NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch
ACA3EB4 fcmp     d12, d0
ACA3EB8 b.pl     0x18aca3fa0
ACA3EBC ldr      d0, [x21]
ACA3EC0 fadd     d0, d10, d0
ACA3EC4 str      d0, [x21]
ACA3EC8 fcmp     d15, d9
ACA3ECC b.mi     0x18aca4020
ACA3ED0 mov.16b  v12, v15
ACA3ED4 ldur     d15, [x29, #-0x88]
ACA3ED8 fcmp     d15, #0.0
ACA3EDC ldp      d7, d6, [sp, #0x50]
ACA3EE0 ldr      d16, [sp, #0x48]
ACA3EE4 b.ls     0x18aca4198
ACA3EE8 fcmp     d6, #0.0
ACA3EEC b.ls     0x18aca4198
ACA3EF0 fdiv     d0, d12, d15
ACA3EF4 fmov     d1, #1.00000000
ACA3EF8 fsub     d2, d1, d0
ACA3EFC fdiv     d2, d1, d2
ACA3F00 fmov     d3, #-1.00000000
ACA3F04 fadd     d2, d2, d3
ACA3F08 fcmp     d0, d1
ACA3F0C adrp     x8, 2892             ; 0x18b7ef000
ACA3F10 ldr      d0, [x8, #0xa18]
ACA3F14 fcsel    d0, d2, d0, lt
ACA3F18 fneg     d1, d0
ACA3F1C ldr      d17, [sp, #0x10]
ACA3F20 fcmp     d17, #0.0
ACA3F24 fcsel    d0, d1, d0, mi
ACA3F28 fmul     d0, d15, d0
ACA3F2C fdiv     d0, d0, d6
ACA3F30 b        0x18aca41a4
ACA3F34 fcmp     d12, d9
ACA3F38 b.mi     0x18aca3f68
ACA3F3C cbz      w23, 0x18aca3fcc
ACA3F40 fcmp     d10, #0.0
ACA3F44 b.eq     0x18aca3fe8
ACA3F48 fdiv     d0, d14, d10
ACA3F4C fabs     d11, d0
ACA3F50 bl       _NSScrollViewRubberbandDirectionLockStretchRatio
ACA3F54 fcmp     d11, d0
ACA3F58 b.pl     0x18aca3fe8
ACA3F5C mov      w8, #0x0
ACA3F60 movi.2d  v14, #0000000000000000
ACA3F64 b        0x18aca400c
ACA3F68 cbz      w24, 0x18aca4038
ACA3F6C mov.16b  v15, v12
ACA3F70 fabs     d0, d14
ACA3F74 fabs     d12, d10
ACA3F78 fcmp     d0, d12
ACA3F7C b.lt     0x18aca3fa0
ACA3F80 bl       _NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch
ACA3F84 fcmp     d12, d0
ACA3F88 b.pl     0x18aca3fa0
ACA3F8C ldr      d0, [x21]
ACA3F90 fadd     d1, d10, d0
ACA3F94 movi.2d  v0, #0000000000000000
ACA3F98 mov.16b  v12, v15
ACA3F9C b        0x18aca3fd8
ACA3FA0 mov      w24, #0x1
ACA3FA4 mov.16b  v12, v15
ACA3FA8 fcmp     d12, d9
ACA3FAC b.pl     0x18aca4038
ACA3FB0 cbz      w24, 0x18aca4038
ACA3FB4 fadd     d0, d11, d10
ACA3FB8 fabs     d1, d0
ACA3FBC fcmp     d1, d9
ACA3FC0 b.ge     0x18aca3fd4
ACA3FC4 mov      w24, #0x1
ACA3FC8 b        0x18aca4038
ACA3FCC mov      w8, #0x0
ACA3FD0 b        0x18aca400c
ACA3FD4 fsub     d1, d10, d0
ACA3FD8 mov      w24, #0x0
ACA3FDC mov.16b  v10, v0
ACA3FE0 str      d1, [x21]
ACA3FE4 b        0x18aca4038
ACA3FE8 fabs     d11, d14
ACA3FEC bl       _NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch
ACA3FF0 fcmp     d11, d0
ACA3FF4 b.pl     0x18aca4034
ACA3FF8 mov      w8, #0x0
ACA3FFC ldr      d0, [x19, #0xd8]
ACA4000 fadd     d0, d14, d0
ACA4004 movi.2d  v14, #0000000000000000
ACA4008 str      d0, [x19, #0xd8]
ACA400C ldp      d7, d6, [sp, #0x50]
ACA4010 ldr      d16, [sp, #0x48]
ACA4014 ldur     d15, [x29, #-0x88]
ACA4018 ldr      d17, [sp, #0x10]
ACA401C b        0x18aca40ec
ACA4020 mov      w22, #0x0
ACA4024 movi.2d  v10, #0000000000000000
ACA4028 ldp      d7, d6, [sp, #0x50]
ACA402C ldr      d16, [sp, #0x48]
ACA4030 b        0x18aca4264
ACA4034 mov      w23, #0x1
ACA4038 fcmp     d13, d9
ACA403C b.pl     0x18aca4058
ACA4040 cbz      w23, 0x18aca4058
ACA4044 fadd     d0, d8, d14
ACA4048 fabs     d1, d0
ACA404C fcmp     d1, d9
ACA4050 b.ge     0x18aca40ac
ACA4054 mov      w23, #0x1
ACA4058 fcmp     d12, d9
ACA405C cset     w8, pl
ACA4060 orn      w9, w8, w24
ACA4064 fcmp     d10, #0.0
ACA4068 cset     w10, gt
ACA406C tst      w9, #0x1
ACA4070 csel     w9, w8, w10, ne
ACA4074 fcmp     d13, d9
ACA4078 ldp      d7, d6, [sp, #0x50]
ACA407C ldr      d16, [sp, #0x48]
ACA4080 ldur     d15, [x29, #-0x88]
ACA4084 ldr      d17, [sp, #0x10]
ACA4088 b.pl     0x18aca40a0
ACA408C cbz      w23, 0x18aca40a0
ACA4090 fcmp     d14, #0.0
ACA4094 cset     w8, gt
ACA4098 tbnz     w9, #0x0, 0x18aca40ec
ACA409C b        0x18aca4260
ACA40A0 mov      x8, x20
ACA40A4 cbnz     w9, 0x18aca40ec
ACA40A8 b        0x18aca4260
ACA40AC fcmp     d12, d9
ACA40B0 cset     w8, pl
ACA40B4 fsub     d1, d14, d0
ACA40B8 str      d1, [x19, #0xd8]
ACA40BC orn      w9, w8, w24
ACA40C0 fcmp     d10, #0.0
ACA40C4 cset     w10, gt
ACA40C8 tst      w9, #0x1
ACA40CC csel     w9, w8, w10, ne
ACA40D0 mov      x8, x20
ACA40D4 mov.16b  v14, v0
ACA40D8 ldp      d7, d6, [sp, #0x50]
ACA40DC ldr      d16, [sp, #0x48]
ACA40E0 ldur     d15, [x29, #-0x88]
ACA40E4 ldr      d17, [sp, #0x10]
ACA40E8 tbz      w9, #0x0, 0x18aca4260
ACA40EC fcmp     d15, #0.0
ACA40F0 b.ls     0x18aca413c
ACA40F4 fcmp     d6, #0.0
ACA40F8 b.ls     0x18aca413c
ACA40FC fdiv     d0, d12, d15
ACA4100 fmov     d1, #1.00000000
ACA4104 fsub     d2, d1, d0
ACA4108 fdiv     d2, d1, d2
ACA410C fmov     d3, #-1.00000000
ACA4110 fadd     d2, d2, d3
ACA4114 fcmp     d0, d1
ACA4118 adrp     x9, 2891             ; 0x18b7ef000
ACA411C ldr      d0, [x9, #0xa18]
ACA4120 fcsel    d0, d2, d0, lt
ACA4124 fneg     d1, d0
ACA4128 fcmp     d17, #0.0
ACA412C fcsel    d0, d1, d0, mi
ACA4130 fmul     d0, d15, d0
ACA4134 fdiv     d0, d0, d6
ACA4138 b        0x18aca4144
ACA413C fmov     d0, #20.00000000
ACA4140 fmul     d0, d17, d0
ACA4144 fsub     d0, d0, d10
ACA4148 fcmp     d10, #0.0
ACA414C b.le     0x18aca41a8
ACA4150 fcmp     d15, #0.0
ACA4154 b.ls     0x18aca4188
ACA4158 fabs     d1, d0
ACA415C fmul     d1, d6, d1
ACA4160 fdiv     d1, d1, d15
ACA4164 fmov     d2, #1.00000000
ACA4168 fadd     d1, d1, d2
ACA416C fdiv     d1, d2, d1
ACA4170 fsub     d1, d2, d1
ACA4174 fneg     d2, d1
ACA4178 fcmp     d0, #0.0
ACA417C fcsel    d1, d2, d1, mi
ACA4180 fmul     d1, d15, d1
ACA4184 b        0x18aca4190
ACA4188 fmov     d1, #20.00000000
ACA418C fdiv     d1, d0, d1
ACA4190 frintp   d1, d1
ACA4194 b        0x18aca41ec
ACA4198 fmov     d0, #20.00000000
ACA419C ldr      d17, [sp, #0x10]
ACA41A0 fmul     d0, d17, d0
ACA41A4 mov      w8, #0x1
ACA41A8 fcmp     d15, #0.0
ACA41AC b.ls     0x18aca41e0
ACA41B0 fabs     d1, d0
ACA41B4 fmul     d1, d6, d1
ACA41B8 fdiv     d1, d1, d15
ACA41BC fmov     d2, #1.00000000
ACA41C0 fadd     d1, d1, d2
ACA41C4 fdiv     d1, d2, d1
ACA41C8 fsub     d1, d2, d1
ACA41CC fneg     d2, d1
ACA41D0 fcmp     d0, #0.0
ACA41D4 fcsel    d1, d2, d1, mi
ACA41D8 fmul     d1, d15, d1
ACA41DC b        0x18aca41e8
ACA41E0 fmov     d1, #20.00000000
ACA41E4 fdiv     d1, d0, d1
ACA41E8 frintm   d1, d1
ACA41EC fcmp     d15, #0.0
ACA41F0 b.ls     0x18aca4240
ACA41F4 fcmp     d6, #0.0
ACA41F8 b.ls     0x18aca4240
ACA41FC fabs     d2, d1
ACA4200 fdiv     d2, d2, d15
ACA4204 fmov     d3, #1.00000000
ACA4208 fsub     d4, d3, d2
ACA420C fdiv     d4, d3, d4
ACA4210 fmov     d5, #-1.00000000
ACA4214 fadd     d4, d4, d5
ACA4218 fcmp     d2, d3
ACA421C adrp     x9, 2891             ; 0x18b7ef000
ACA4220 ldr      d2, [x9, #0xa18]
ACA4224 fcsel    d2, d4, d2, lt
ACA4228 fneg     d3, d2
ACA422C fcmp     d1, #0.0
ACA4230 fcsel    d2, d3, d2, mi
ACA4234 fmul     d2, d15, d2
ACA4238 fdiv     d2, d2, d6
ACA423C b        0x18aca4248
ACA4240 fmov     d2, #20.00000000
ACA4244 fmul     d2, d1, d2
ACA4248 fsub     d10, d17, d1
ACA424C fsub     d0, d2, d0
ACA4250 str      d0, [x21]
ACA4254 fcmp     d12, d9
ACA4258 b.mi     0x18aca42ac
ACA425C mov      w22, #0x1
ACA4260 cbz      w8, 0x18aca44b8
ACA4264 fcmp     d16, #0.0
ACA4268 b.le     0x18aca42c4
ACA426C fcmp     d7, #0.0
ACA4270 b.pl     0x18aca42c4
ACA4274 movi.2d  v1, #0000000000000000
ACA4278 fcmp     d13, d16
ACA427C b.mi     0x18aca4498
ACA4280 fsub     d0, d13, d16
ACA4284 fcmp     d0, #0.0
ACA4288 b.ls     0x18aca4498
ACA428C ldur     d1, [x29, #-0x90]
ACA4290 fminnm   d1, d1, d6
ACA4294 fcmp     d1, #0.0
ACA4298 cset     w8, ls
ACA429C b.hi     0x18aca43a0
ACA42A0 fmov     d1, #-20.00000000
ACA42A4 fmul     d0, d0, d1
ACA42A8 b        0x18aca43e4
ACA42AC fabs     d0, d10
ACA42B0 fcmp     d0, d9
ACA42B4 b.le     0x18aca42e4
ACA42B8 mov      w22, #0x1
ACA42BC tbnz     w8, #0x0, 0x18aca4264
ACA42C0 b        0x18aca44b8
ACA42C4 ldur     d0, [x29, #-0x90]
ACA42C8 fminnm   d0, d0, d6
ACA42CC fcmp     d0, #0.0
ACA42D0 cset     w8, ls
ACA42D4 b.hi     0x18aca42f0
ACA42D8 fmov     d0, #20.00000000
ACA42DC fmul     d0, d7, d0
ACA42E0 b        0x18aca4330
ACA42E4 mov      w22, #0x0
ACA42E8 cbnz     w8, 0x18aca4264
ACA42EC b        0x18aca44b8
ACA42F0 ldur     d4, [x29, #-0x90]
ACA42F4 fdiv     d0, d13, d4
ACA42F8 fmov     d1, #1.00000000
ACA42FC fsub     d2, d1, d0
ACA4300 fdiv     d2, d1, d2
ACA4304 fmov     d3, #-1.00000000
ACA4308 fadd     d2, d2, d3
ACA430C fcmp     d0, d1
ACA4310 adrp     x9, 2891             ; 0x18b7ef000
ACA4314 ldr      d0, [x9, #0xa18]
ACA4318 fcsel    d0, d2, d0, lt
ACA431C fneg     d1, d0
ACA4320 fcmp     d7, #0.0
ACA4324 fcsel    d0, d1, d0, mi
ACA4328 fmul     d0, d4, d0
ACA432C fdiv     d0, d0, d6
ACA4330 fsub     d0, d0, d14
ACA4334 ldur     d1, [x29, #-0x90]
ACA4338 fcmp     d1, #0.0
ACA433C b.ls     0x18aca4374
ACA4340 fabs     d1, d0
ACA4344 fmul     d1, d6, d1
ACA4348 ldur     d3, [x29, #-0x90]
ACA434C fdiv     d1, d1, d3
ACA4350 fmov     d2, #1.00000000
ACA4354 fadd     d1, d1, d2
ACA4358 fdiv     d1, d2, d1
ACA435C fsub     d1, d2, d1
ACA4360 fneg     d2, d1
ACA4364 fcmp     d0, #0.0
ACA4368 fcsel    d1, d2, d1, mi
ACA436C fmul     d1, d3, d1
ACA4370 b        0x18aca437c
ACA4374 fmov     d1, #20.00000000
ACA4378 fdiv     d1, d0, d1
ACA437C frintp   d2, d1
ACA4380 frintm   d1, d1
ACA4384 fcmp     d14, #0.0
ACA4388 fcsel    d1, d2, d1, gt
ACA438C fsub     d14, d7, d1
ACA4390 tbz      w8, #0x0, 0x18aca4450
ACA4394 fmov     d2, #20.00000000
ACA4398 fmul     d1, d1, d2
ACA439C b        0x18aca4494
ACA43A0 fabs     d1, d0
ACA43A4 ldur     d5, [x29, #-0x90]
ACA43A8 fdiv     d1, d1, d5
ACA43AC fmov     d2, #1.00000000
ACA43B0 fsub     d3, d2, d1
ACA43B4 fdiv     d3, d2, d3
ACA43B8 fmov     d4, #-1.00000000
ACA43BC fadd     d3, d3, d4
ACA43C0 fcmp     d1, d2
ACA43C4 adrp     x9, 2891             ; 0x18b7ef000
ACA43C8 ldr      d1, [x9, #0xa18]
ACA43CC fcsel    d1, d3, d1, lt
ACA43D0 fneg     d2, d1
ACA43D4 fcmp     d0, #0.0
ACA43D8 fcsel    d0, d2, d1, gt
ACA43DC fmul     d0, d5, d0
ACA43E0 fdiv     d0, d0, d6
ACA43E4 fsub     d0, d0, d14
ACA43E8 ldur     d1, [x29, #-0x90]
ACA43EC fcmp     d1, #0.0
ACA43F0 b.ls     0x18aca4428
ACA43F4 fabs     d1, d0
ACA43F8 fmul     d1, d6, d1
ACA43FC ldur     d3, [x29, #-0x90]
ACA4400 fdiv     d1, d1, d3
ACA4404 fmov     d2, #1.00000000
ACA4408 fadd     d1, d1, d2
ACA440C fdiv     d1, d2, d1
ACA4410 fsub     d1, d2, d1
ACA4414 fneg     d2, d1
ACA4418 fcmp     d0, #0.0
ACA441C fcsel    d1, d2, d1, mi
ACA4420 fmul     d1, d3, d1
ACA4424 b        0x18aca4430
ACA4428 fmov     d1, #20.00000000
ACA442C fdiv     d1, d0, d1
ACA4430 frintp   d2, d1
ACA4434 frintm   d1, d1
ACA4438 fcmp     d14, #0.0
ACA443C fcsel    d1, d2, d1, gt
ACA4440 fabs     d2, d1
ACA4444 fadd     d2, d7, d2
ACA4448 fadd     d14, d16, d2
ACA444C cbnz     w8, 0x18aca4394
ACA4450 fabs     d2, d1
ACA4454 ldur     d7, [x29, #-0x90]
ACA4458 fdiv     d2, d2, d7
ACA445C fmov     d3, #1.00000000
ACA4460 fsub     d4, d3, d2
ACA4464 fdiv     d4, d3, d4
ACA4468 fmov     d5, #-1.00000000
ACA446C fadd     d4, d4, d5
ACA4470 fcmp     d2, d3
ACA4474 adrp     x8, 2891             ; 0x18b7ef000
ACA4478 ldr      d2, [x8, #0xa18]
ACA447C fcsel    d2, d4, d2, lt
ACA4480 fneg     d3, d2
ACA4484 fcmp     d1, #0.0
ACA4488 fcsel    d1, d3, d2, mi
ACA448C fmul     d1, d7, d1
ACA4490 fdiv     d1, d1, d6
ACA4494 fsub     d1, d1, d0
ACA4498 str      d1, [x19, #0xd8]
ACA449C mov      w8, #0x1
ACA44A0 fabs     d0, d14
ACA44A4 fcmp     d0, d9
ACA44A8 mov      w9, #0x1
ACA44AC csel     w9, wzr, w9, le
ACA44B0 fcmp     d13, d9
ACA44B4 csel     w20, w8, w9, pl
ACA44B8 orr      w8, w22, w20
ACA44BC ldp      w10, w9, [x19, #0x98]
ACA44C0 bfxil    w9, w8, #0, #1
ACA44C4 ldp      d1, d4, [sp, #0x80]
ACA44C8 ldr      d0, [sp, #0x60]
ACA44CC fmul     d0, d1, d0
ACA44D0 ldr      d3, [sp, #0x98]
ACA44D4 ldp      d2, d5, [sp, #0x68]
ACA44D8 fmadd    d0, d5, d3, d0
ACA44DC fmul     d1, d1, d2
ACA44E0 str      w9, [x19, #0x9c]
ACA44E4 fcmp     d14, #0.0
ACA44E8 movi.2d  v2, #0000000000000000
ACA44EC fccmp    d4, d2, #0x4, eq
ACA44F0 fcsel    d0, d2, d0, ne
ACA44F4 fcmp     d10, #0.0
ACA44F8 ldr      d4, [sp, #0x90]
ACA44FC fccmp    d4, d2, #0x4, eq
ACA4500 fneg     d2, d14
ACA4504 ldr      d4, [sp, #0x78]
ACA4508 fnmadd   d1, d4, d3, d1
ACA450C mov      x8, #-0x8000000000000000
ACA4510 fmov     d3, x8
ACA4514 fcsel    d1, d3, d1, ne
ACA4518 tst      w10, #0x1
ACA451C fcsel    d2, d14, d2, eq
ACA4520 fneg     d3, d0
ACA4524 fcsel    d0, d0, d3, eq
ACA4528 ldp      d3, d4, [x19, #0xa0]
ACA452C fsub     d3, d3, d10
ACA4530 fadd     d4, d4, d2
ACA4534 stp      d3, d4, [x19, #0xa0]
ACA4538 ldp      d3, d4, [x19, #0xb0]
ACA453C fsub     d3, d3, d10
ACA4540 fadd     d2, d2, d4
ACA4544 stp      d3, d2, [x19, #0xb0]
ACA4548 stp      d1, d0, [x19, #0xc0]
ACA454C ldp      x29, x30, [sp, #0x130]
ACA4550 ldp      x20, x19, [sp, #0x120]
ACA4554 ldp      x22, x21, [sp, #0x110]
ACA4558 ldp      x24, x23, [sp, #0x100]
ACA455C ldp      x28, x27, [sp, #0xf0]
ACA4560 ldp      d9, d8, [sp, #0xe0]
ACA4564 ldp      d11, d10, [sp, #0xd0]
ACA4568 ldp      d13, d12, [sp, #0xc0]
ACA456C ldp      d15, d14, [sp, #0xb0]
ACA4570 add      sp, sp, #0x140
ACA4574 retab

; ===== trackpad: -[NSScrollingBehaviorConcurrentVBL _scrollView:trackGestureScrollWithEvent:] tail (0.075) =====
A66B970 ldr      x0, [x20]
A66B974 bl       0x19007bcc0 ; setPerfLogger:
A66B978 ldr      x8, [x19, x23]
A66B97C ldr      x20, [x25]
A66B980 cmp      x8, #0x2
A66B984 b.ne     0x18a66b9bc
A66B988 adrp     x8, 406099           ; 0x1ed8be000
A66B98C ldrsw    x8, [x8, #0xbc8]
A66B990 add      x8, x19, x8
A66B994 ldr      x21, [x8]
A66B998 adrp     x8, 410839           ; 0x1eeb42000
A66B99C add      x0, x8, #0xd80       ; _OBJC_CLASS_$__NSScrollingConcurrentSwipeVBLPreprocessFilter
A66B9A0 bl       0x19010cc80
A66B9A4 mov      x2, x20
A66B9A8 bl       0x1900594c0 ; initWithConstantData:
A66B9AC mov      x20, x0
A66B9B0 mov      x2, x21
A66B9B4 bl       0x190077eb0 ; setGestureAxis:
A66B9B8 b        0x18a66b9d4
A66B9BC adrp     x8, 410825           ; 0x1eeb34000
A66B9C0 add      x0, x8, #0xae8       ; _OBJC_CLASS_$__NSScrollingConcurrentEventVBLPreprocessFilter
A66B9C4 bl       0x19010cc80
A66B9C8 mov      x2, x20
A66B9CC bl       0x1900594c0 ; initWithConstantData:
A66B9D0 mov      x20, x0
A66B9D4 mov      x0, x20
A66B9D8 bl       0x19010ccc0
A66B9DC mov      x20, x0
A66B9E0 adrp     x8, 406099           ; 0x1ed8be000
A66B9E4 ldrsw    x8, [x8, #0xbd4]
A66B9E8 add      x8, x19, x8
A66B9EC mov      x9, #0x3333333333333333
A66B9F0 movk     x9, #0x3fb3, lsl #48
A66B9F4 str      x9, [x8]
A66B9F8 adrp     x8, 4483             ; 0x18b7ee000
A66B9FC ldr      d0, [x8, #0x568]
A66BA00 bl       0x1900789d0 ; setHyperbolicCoefficient:
A66BA04 ldr      x2, [x19, x22]
A66BA08 mov      x0, x20
A66BA0C bl       0x190077270 ; setEventMonitor:
A66BA10 mov      x0, x20
A66BA14 mov      x2, x19
A66BA18 bl       0x19007d7f0 ; setScrollStateDelegate:
A66BA1C mov      x0, x19
A66BA20 mov      x2, x20
A66BA24 mov      w3, #0x1

; ===== touch: -[NSScrollingBehaviorConcurrentVBL scrollView:scrollWithDelta:timestamp:startTimestamp:state:] (0.55, min speed 250) =====
A8FB38C ldp      d11, d10, [sp], #0x70
A8FB390 autibsp
A8FB394 eor      x16, x30, x30, lsl #1
A8FB398 tbz      x16, #0x3e, 0x18a8fb3a0
A8FB39C brk      #0xc471
A8FB3A0 b        0x19010cfc0
A8FB3A4 mov      x20, x0
A8FB3A8 adrp     x8, 410186           ; 0x1eeb45000
A8FB3AC add      x0, x8, #0xb70       ; _OBJC_CLASS_$__NSScrollingMomentumBasCalculator
A8FB3B0 bl       0x19010ce70
A8FB3B4 adrp     x22, 405443          ; 0x1ed8be000
A8FB3B8 add      x22, x22, #0xba4
A8FB3BC ldrsw    x8, [x22]
A8FB3C0 add      x8, x19, x8
A8FB3C4 str      x0, [x8]
A8FB3C8 bl       _NSScrollingTouchMomentumMinimumSpeed
A8FB3CC adrp     x8, 3826             ; 0x18b7ed000
A8FB3D0 ldr      d1, [x8, #0x5a0]
A8FB3D4 fmul     d0, d0, d1
A8FB3D8 ldrsw    x8, [x22, #0x4]
A8FB3DC add      x8, x19, x8
A8FB3E0 str      d0, [x8]
A8FB3E4 adrp     x8, 410197           ; 0x1eeb50000
A8FB3E8 add      x0, x8, #0x830       ; _OBJC_CLASS_$__NSScrollingConcurrentGestureMonitor
A8FB3EC bl       0x19010cc80
A8FB3F0 mov      x21, x0
A8FB3F4 ldrsw    x8, [x22, #0x10]
A8FB3F8 add      x25, x19, x8
A8FB3FC ldr      x0, [x25]
A8FB400 bl       0x190046670 ; canScrollHorizontally
A8FB404 mov      x22, x0
A8FB408 ldr      x0, [x25]
A8FB40C bl       0x190046680 ; canScrollVertically
A8FB410 mov      x4, x0
A8FB414 mov      x0, x21
A8FB418 mov.16b  v0, v11
A8FB41C mov.16b  v1, v10
A8FB420 mov.16b  v2, v9
A8FB424 mov.16b  v3, v8
A8FB428 mov      x2, x20
A8FB42C mov      x3, x22
A8FB430 bl       0x190059a40 ; initWithDelta:timestamp:startTimestamp:predominantAxisMode:canScrollHorizontally:canScrollVertically:
A8FB434 str      x0, [x19, x23]
A8FB438 ldr      x0, [x25]
A8FB43C bl       0x190068740 ; perfLogger
A8FB440 mov      x2, x0
A8FB444 ldr      x0, [x19, x23]
A8FB448 bl       0x19007bcc0 ; setPerfLogger:
A8FB44C ldr      x8, [x19, x24]
A8FB450 ldr      x20, [x25]
A8FB454 cmp      x8, #0x2
A8FB458 b.ne     0x18a8fb490
A8FB45C adrp     x8, 405443           ; 0x1ed8be000
A8FB460 ldrsw    x8, [x8, #0xbc8]
A8FB464 add      x8, x19, x8
A8FB468 ldr      x21, [x8]
A8FB46C adrp     x8, 410183           ; 0x1eeb42000
A8FB470 add      x0, x8, #0xd80       ; _OBJC_CLASS_$__NSScrollingConcurrentSwipeVBLPreprocessFilter
A8FB474 bl       0x19010cc80
A8FB478 mov      x2, x20
A8FB47C bl       0x1900594c0 ; initWithConstantData:
A8FB480 mov      x20, x0
A8FB484 mov      x2, x21
A8FB488 bl       0x190077eb0 ; setGestureAxis:
A8FB48C b        0x18a8fb4a8
A8FB490 adrp     x8, 410169           ; 0x1eeb34000
A8FB494 add      x0, x8, #0xae8       ; _OBJC_CLASS_$__NSScrollingConcurrentEventVBLPreprocessFilter
A8FB498 bl       0x19010cc80
A8FB49C mov      x2, x20
A8FB4A0 bl       0x1900594c0 ; initWithConstantData:
A8FB4A4 mov      x20, x0
A8FB4A8 mov      x0, x20
A8FB4AC bl       0x19010ccc0
A8FB4B0 mov      x20, x0
A8FB4B4 adrp     x8, 405443           ; 0x1ed8be000
A8FB4B8 ldrsw    x8, [x8, #0xbd4]
A8FB4BC add      x8, x19, x8
A8FB4C0 mov      x9, #-0x6666666666666667
A8FB4C4 movk     x9, #0x999a
A8FB4C8 movk     x9, #0x3fe1, lsl #48
A8FB4CC str      x9, [x8]
A8FB4D0 adrp     x8, 3826             ; 0x18b7ed000
A8FB4D4 ldr      d0, [x8, #0xea0]
A8FB4D8 bl       0x1900789d0 ; setHyperbolicCoefficient:
A8FB4DC ldr      x2, [x19, x23]
A8FB4E0 mov      x0, x20
A8FB4E4 bl       0x190077270 ; setEventMonitor:
