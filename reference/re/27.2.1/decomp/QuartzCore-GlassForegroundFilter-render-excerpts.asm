; QuartzCore 27.2.1 (26B131): CA::OGL::GlassForegroundFilter::render 0x18DEBDD14 (xcrun dyld_info -disassemble), input read-out.
; keys: 0x1ad inputRefractionAmount, 0x1b1 inputRefractionHeight (default 100, uploaded as 1/height), 0x1b2 inputRefractionOffset
; (default -10), 0x149 inputAberrationAmount (default -15), 0x14b inputAberrationHeight (default 20, as 1/height), 0x14c
; inputAberrationOffset, 0x14a inputAberrationAngle (sincos -> aberration_dir), 0x183 / 0x180 inputEdgeStart / End (defaults -4.5 / -3),
; 0x182 / 0x181 edge opacities (defaults 0 / 1), 0x1ae inputRefractionAngle (sincos -> refraction_dir). Nothing is rescaled.
0x18DEBDDDC   str      q0, [sp, #0x30]
0x18DEBDDE0   adrp     x8, 601              ; 0x18e116000
0x18DEBDDE4   ldr      d0, [x8, #0xbd0]
0x18DEBDDE8   mov      x0, x23
0x18DEBDDEC   mov      w1, #0x1ad
0x18DEBDDF0   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDDF4   str      q0, [sp, #0x60]
0x18DEBDDF8   mov      x8, #0x4059000000000000
0x18DEBDDFC   fmov     d0, x8
0x18DEBDE00   mov      x0, x23
0x18DEBDE04   mov      w1, #0x1b1
0x18DEBDE08   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE0C   fmov     d9, #1.00000000
0x18DEBDE10   fdiv     d0, d9, d0
0x18DEBDE14   str      q0, [sp, #0x20]
0x18DEBDE18   fmov     d0, #-10.00000000
0x18DEBDE1C   mov      x0, x23
0x18DEBDE20   mov      w1, #0x1b2
0x18DEBDE24   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE28   str      q0, [sp, #0x70]
0x18DEBDE2C   fmov     d0, #-15.00000000
0x18DEBDE30   mov      x0, x23
0x18DEBDE34   mov      w1, #0x149
0x18DEBDE38   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE3C   ldr      q1, [sp, #0x70]
0x18DEBDE40   mov.d    v1[1], v0[0]
0x18DEBDE44   str      q1, [sp, #0x70]
0x18DEBDE48   ldr      q0, [sp, #0x60]
0x18DEBDE4C   ldr      q1, [sp, #0x20]
0x18DEBDE50   mov.d    v0[1], v1[0]
0x18DEBDE54   fcvtn    v0.2s, v0.2d
0x18DEBDE58   str      q0, [sp, #0x60]
0x18DEBDE5C   fmov     d0, #20.00000000
0x18DEBDE60   mov      x0, x23
0x18DEBDE64   mov      w1, #0x14b
0x18DEBDE68   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE6C   fdiv     d14, d9, d0
0x18DEBDE70   movi.2d  v0, #0000000000000000
0x18DEBDE74   mov      x0, x23
0x18DEBDE78   mov      w1, #0x14c
0x18DEBDE7C   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE80   mov.16b  v13, v0
0x18DEBDE84   movi.2d  v0, #0000000000000000
0x18DEBDE88   mov      x0, x23
0x18DEBDE8C   mov      w1, #0x14a
0x18DEBDE90   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDE94   fcvt     s0, d0
0x18DEBDE98   bl       0x1900f9ab0
0x18DEBDE9C   mov.s    v1[1], v0[0]
0x18DEBDEA0   str      q1, [sp, #0x20]
0x18DEBDEA4   fmov     d0, #-4.50000000
0x18DEBDEA8   mov      x0, x23
0x18DEBDEAC   mov      w1, #0x183
0x18DEBDEB0   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDEB4   mov.16b  v10, v0
0x18DEBDEB8   fmov     d0, #-3.00000000
0x18DEBDEBC   mov      x0, x23
0x18DEBDEC0   mov      w1, #0x180
0x18DEBDEC4   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDEC8   mov.16b  v9, v0
0x18DEBDECC   movi.2d  v0, #0000000000000000
0x18DEBDED0   mov      x0, x23
0x18DEBDED4   mov      w1, #0x182
0x18DEBDED8   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDEDC   str      q0, [sp, #0x10]
0x18DEBDEE0   fmov     d0, #1.00000000
0x18DEBDEE4   mov      x0, x23
0x18DEBDEE8   mov      w1, #0x181
0x18DEBDEEC   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDEF0   ldr      q2, [sp, #0x10]
0x18DEBDEF4   mov.d    v2[1], v0[0]
0x18DEBDEF8   fmov.2d  v0, #1.00000000
0x18DEBDEFC   fcmgt.2d v0, v2, v0
0x18DEBDF00   fcmlt.2d v1, v2, #0.0
0x18DEBDF04   mov.16b  v3, v2
0x18DEBDF08   bic.16b  v2, v1, v0
0x18DEBDF0C   xtn.2s   v2, v2
0x18DEBDF10   orr.16b  v0, v1, v0
0x18DEBDF14   xtn.2s   v11, v0
0x18DEBDF18   fmov.2s  v0, #1.00000000
0x18DEBDF1C   bic.8b   v15, v0, v2
0x18DEBDF20   fcvtn    v12.2s, v3.2d
0x18DEBDF24   movi.2d  v0, #0000000000000000
0x18DEBDF28   mov      x0, x23
0x18DEBDF2C   mov      w1, #0x1ae
0x18DEBDF30   bl       __ZNK2CA6Render13KeyValueArray13get_float_keyEjd
0x18DEBDF34   fcvt     s0, d0
0x18DEBDF38   bl       0x1900f9ab0
0x18DEBDF3C   mov.s    v1[1], v0[0]
0x18DEBDF40   str      q1, [sp, #0x10]
0x18DEBDF44   ldr      x8, [x19, #0x2e8]
0x18DEBDF48   cmp      x8, x20
0x18DEBDF4C   b.eq     0x18debdf70
0x18DEBDF50   movi.2d  v0, #0000000000000000
0x18DEBDF54   mov      x0, x19
0x18DEBDF58   mov      x1, x20
0x18DEBDF5C   mov      w2, #0x0
0x18DEBDF60   mov      w3, #0x0
0x18DEBDF64   mov      w4, #0x0
