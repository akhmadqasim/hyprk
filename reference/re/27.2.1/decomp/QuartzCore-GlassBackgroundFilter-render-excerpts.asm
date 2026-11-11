18debc4e0:     	adrp	x8, 0x18e117000 <_hash.asso_values+0x914>
18debc4e4:     	ldr	d0, [x8, #0x8]
18debc4e8:     	mov	x0, x22
18debc4ec:     	mov	w1, #0x1a1              ; =417   <<inputMaxHeadroom>>
18debc4f0:     	bl	0x18dd7bf60 get_float
18debc4f4:     	fcvt	s0, d0
18debc4f8:     	fmov	s8, #1.00000000
18debc4fc:     	adrp	x8, 0x18e118000 <_hash.asso_values+0x1914>
18debc500:     	ldr	s1, [x8, #0xaa8]
18debc504:     	fcmp	s0, s1
18debc508:     	b.le	0x18debc534 <__ZNK2CA3OGL21GlassBackgroundFilter6renderEPKNS_6Render6FilterEPKNS0_5LayerERNS0_7ContextEfPPNS0_7SurfaceEPfS8_PKNS_11ColorMatrixE+0x4e0>
18debc50c:     	fcmp	s11, s0
18debc510:     	fcsel	s1, s0, s11, gt
18debc514:     	fmov	s2, #-1.00000000
18debc518:     	fadd	s3, s1, s2
18debc51c:     	fmov	s4, #1.00000000
18debc520:     	fcmp	s1, s4
18debc524:     	movi.2d	v1, #0000000000000000
18debc528:     	fcsel	s1, s1, s3, mi
18debc52c:     	fadd	s0, s0, s2
18debc530:     	fdiv	s8, s1, s0
18debc534:     	movi.2d	v0, #0000000000000000
18debc538:     	mov	x0, x22
18debc53c:     	mov	w1, #0x1be              ; =446   <<inputSDRShadowOpacity>>
18debc540:     	bl	0x18dd7bf60 get_float
18debc544:     	fcvt	s0, d0
18debc548:     	fcmp	s0, #0.0
18debc54c:     	b.le	0x18debc560 <__ZNK2CA3OGL21GlassBackgroundFilter6renderEPKNS_6Render6FilterEPKNS0_5LayerERNS0_7ContextEfPPNS0_7SurfaceEPfS8_PKNS_11ColorMatrixE+0x50c>
18debc550:     	fmsub	s0, s8, s0, s0
18debc554:     	ldur	s1, [x29, #-0xcc]
18debc558:     	fadd	s0, s0, s1
18debc55c:     	stur	s0, [x29, #-0xcc]
18debc560:     	movi.2d	v0, #0000000000000000
18debc564:     	stp	q0, q0, [sp, #0x390]
18debc568:     	stp	q0, q0, [sp, #0x370]
18debc56c:     	str	q0, [sp, #0x360]
18debc570:     	fmov	d0, #1.00000000
18debc574:     	mov	x0, x22
18debc578:     	mov	w1, #0x1c7              ; =455   <<inputShadowColorMatrixWhite>>
18debca40:     	mov	x0, x22
18debca44:     	mov	w1, #0x19c              ; =412   <<inputKeyFillHighlightHeight>>
18debca48:     	bl	0x18dd7bf60 get_float
18debca4c:     	str	d0, [sp, #0x88]
18debca50:     	movi.2d	v0, #0000000000000000
18debca54:     	mov	x0, x22
18debca58:     	mov	w1, #0x199              ; =409   <<inputKeyFillHighlightAngle>>
18debca5c:     	bl	0x18dd7bf60 get_float
18debca60:     	bl	0x19010bd40 <_objc_msgSend$zoom+0x1f91560>
18debca64:     	mov.16b	v11, v0
18debca68:     	mov.16b	v12, v1
18debca6c:     	movi.2d	v0, #0000000000000000
18debca70:     	mov	x0, x22
18debca74:     	mov	w1, #0x19d              ; =413   <<inputKeyFillHighlightSpread>>
18debca78:     	bl	0x18dd7bf60 get_float
18debca7c:     	fcvt	s10, d0
18debca80:     	fcvt	d0, s10
18debca84:     	mov	x0, x22
18debca88:     	mov	w1, #0x19e              ; =414   <<inputKeyFillHighlightSpreadSDR>>
18debca8c:     	bl	0x18dd7bf60 get_float
18debca90:     	fcvt	s0, d0
18debca94:     	fsub	s1, s10, s0
18debca98:     	ldr	s2, [sp, #0x320]
18debca9c:     	fmadd	s0, s1, s2, s0
18debcaa0:     	bl	0x19010c2e0 <_objc_msgSend$zoom+0x1f91b00>
18debcaa4:     	str	s0, [sp, #0x18c]
18debcaa8:     	movi.2d	v0, #0000000000000000
18debcaac:     	mov	x0, x22
18debcab0:     	mov	w1, #0x198              ; =408   <<inputKeyFillHighlightAmount>>
18debcab4:     	bl	0x18dd7bf60 get_float
18debcab8:     	str	d0, [sp, #0x268]
18debcabc:     	movi.2d	v0, #0000000000000000
18debcac0:     	mov	x0, x22
18debcac4:     	mov	w1, #0x19b              ; =411   <<inputKeyFillHighlightEffectOffset>>
18debcac8:     	bl	0x18dd7bf60 get_float
18debcacc:     	str	d0, [sp, #0x78]
18debcad0:     	movi.2d	v0, #0000000000000000
18debcad4:     	mov	x0, x22
18debcad8:     	mov	w1, #0x19a              ; =410   <<inputKeyFillHighlightColorBias>>
18debcadc:     	bl	0x18dd7bf60 get_float
18debcae0:     	str	d0, [sp, #0x70]
18debcae4:     	mov	x0, x22
18debcae8:     	bl	0x18de19c38 <__ZN2CA6Render28get_glass_filter_fill_radiusEPKNS0_13KeyValueArrayE>
18debcaec:     	str	d0, [sp, #0x80]
18debcaf0:     	movi.2d	v0, #0000000000000000
18debcd60:     	adrp	x8, 0x1ed92c000 <__ZL8timebase+0x8>
18debcd64:     	ldr	x8, [x8, #0x420]
18debcd68:     	cmn	x8, #0x1
18debcd6c:     	b.ne	0x18debdb00 <__ZNK2CA3OGL21GlassBackgroundFilter6renderEPKNS_6Render6FilterEPKNS0_5LayerERNS0_7ContextEfPPNS0_7SurfaceEPfS8_PKNS_11ColorMatrixE+0x1aac>
18debcd70:     	ldr	q0, [sp, #0x250]
18debcd74:     	zip1.4s	v2, v0, v0
18debcd78:     	ldp	q0, q1, [sp, #0x300]
18debcd7c:     	fmul.4s	v0, v1, v0[0]
18debcd80:     	stp	q0, q2, [sp, #0x20]
18debcd84:     	fmov	d0, #1.00000000
18debcd88:     	ldr	d1, [sp, #0x268]
18debcd8c:     	fdiv	d13, d0, d1
18debcd90:     	fmov	d15, #-2.00000000
18debcd94:     	ldr	s0, [sp, #0x248]
18debcd98:     	fmul	s0, s8, s0
18debcd9c:     	str	q0, [sp, #0x50]
18debcda0:     	ldr	d0, [sp, #0x288]
18debcda4:     	fcvt	s0, d0
18debcda8:     	str	s0, [sp, #0x24c]
18debcdac:     	ldr	d0, [sp, #0x280]
18debcdb0:     	fcvt	s0, d0
18debcdb4:     	str	s0, [sp, #0x250]
18debcdb8:     	ldr	d0, [sp, #0x270]
18debcdbc:     	fcvt	s0, d0
18debcdc0:     	str	s0, [sp, #0x268]
18debcdc4:     	ldr	d0, [sp, #0x88]
18debcdc8:     	fcvt	s0, d0
18debcdcc:     	str	s0, [sp, #0x2c8]
18debcdd0:     	ldr	d0, [sp, #0x78]
18debcdd4:     	fcvt	s0, d0
18debcdd8:     	str	s0, [sp, #0x310]
18debcddc:     	ldr	d0, [sp, #0x70]
18debcde0:     	fcvt	s0, d0
18debcde4:     	str	s0, [sp, #0x280]
18debcde8:     	bic.8b	v0, v9, v10
18debcdec:     	str	q0, [sp, #0x270]
18debcdf0:     	fcvt	s0, d11
18debcdf4:     	str	s0, [sp, #0x288]
18debcdf8:     	adrp	x8, 0x1ed92c000 <__ZL8timebase+0x8>
18debcdfc:     	ldr	s0, [x8, #0x3b0]
18debce00:     	fcmp	s0, #0.0
18debce04:     	fcsel	s0, s0, s12, ne
18debce08:     	ldr	s1, [x19, #0x268]
18debce0c:     	fmov	s12, #1.00000000
18debce10:     	fdiv	s1, s12, s1
18debce14:     	bl	0x1900fa190 <_objc_msgSend$zoom+0x1f7f9b0>
18debce18:     	str	s0, [x28, #0xc]
18debce1c:     	mov	x0, x22
18debce20:     	mov	w1, #0x178              ; =376   <<inputClampPreserveHue>>
