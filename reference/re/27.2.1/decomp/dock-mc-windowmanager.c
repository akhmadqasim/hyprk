// Mission Control springs, 27.2.1. Not Dock code: WindowManager.framework (dyld cache) + WindowManagerAgent (WindowManager.app).
// 1) WindowManager.framework WindowManagerPreferencesController init, defaults (key string, Double default at +0x10):
//    ExposeSpringDampingRatio 1.0, ExposeSpringResponse 0.25, SpacesBarExitSpringResponse 0.125, ExposeTrackpadVelocityThreshold 5.0,
//    ExposeTrackpadSpringResponseScale 0.6, MissionControlAppIconSize 48.0 (key at 0x1d2b1ff80), AnimationSpeed 1.0.
0x1D2A7AD9C   mov      x1, #0x4048000000000000 
0x1D2A7ADA0   str      x1, [x5, #0x10]      
0x1D2A7ADA4   adrp     x16, 108297          ; 0x1ed183000
0x1D2A7ADA8   ldr      x16, [x16, #0x788]   
0x1D2A7ADAC   add      x5, x20, x16         
0x1D2A7ADB0   adrp     x16, 166             ; 0x1d2b20000
0x1D2A7ADB4   add      x16, x16, #0x50      
0x1D2A7ADB8   sub      x16, x16, #0x20      
0x1D2A7ADBC   orr      x16, x16, #0x8000000000000000 
0x1D2A7ADC0   stp      x9, x16, [x5]        
0x1D2A7ADC4   mov      x7, #0x3ff0000000000000 
0x1D2A7ADC8   str      x7, [x5, #0x10]      
0x1D2A7ADCC   adrp     x16, 108297          ; 0x1ed183000
0x1D2A7ADD0   ldr      x16, [x16, #0x790]   
0x1D2A7ADD4   add      x5, x20, x16         
0x1D2A7ADD8   adrp     x16, 166             ; 0x1d2b20000
0x1D2A7ADDC   add      x16, x16, #0x30      
0x1D2A7ADE0   sub      x16, x16, #0x20      
0x1D2A7ADE4   orr      x16, x16, #0x8000000000000000 
0x1D2A7ADE8   stp      x25, x16, [x5]       
0x1D2A7ADEC   mov      x8, #0x3fd0000000000000 
0x1D2A7ADF0   str      x8, [x5, #0x10]      
0x1D2A7ADF4   adrp     x16, 108297          ; 0x1ed183000
0x1D2A7ADF8   ldr      x16, [x16, #0x798]   
0x1D2A7ADFC   add      x5, x20, x16         
0x1D2A7AE00   adrp     x16, 166             ; 0x1d2b20000
0x1D2A7AE04   add      x16, x16, #0x10      
0x1D2A7AE08   sub      x16, x16, #0x20      
0x1D2A7AE0C   orr      x16, x16, #0x8000000000000000 
0x1D2A7AE10   stp      x12, x16, [x5]       
0x1D2A7AE14   mov      x16, #0x3fc0000000000000 
0x1D2A7AE18   str      x16, [x5, #0x10]     
0x1D2A7AE1C   adrp     x16, 108297          ; 0x1ed183000
0x1D2A7AE20   ldr      x16, [x16, #0x7a0]   
0x1D2A7AE24   add      x5, x20, x16         
0x1D2A7AE28   adrp     x16, 165             ; 0x1d2b1f000
0x1D2A7AE2C   add      x16, x16, #0xff0     
0x1D2A7AE30   sub      x16, x16, #0x20      
0x1D2A7AE34   orr      x16, x16, #0x8000000000000000 
0x1D2A7AE38   stp      x4, x16, [x5]        
0x1D2A7AE3C   str      x0, [x5, #0x10]      
0x1D2A7AE40   adrp     x16, 108297          ; 0x1ed183000
0x1D2A7AE44   ldr      x16, [x16, #0x7a8]   
0x1D2A7AE48   add      x0, x20, x16         
0x1D2A7AE4C   adrp     x16, 165             ; 0x1d2b1f000
0x1D2A7AE50   add      x16, x16, #0xfc0     
0x1D2A7AE54   sub      x16, x16, #0x20      
0x1D2A7AE58   orr      x16, x16, #0x8000000000000000 
0x1D2A7AE5C   add      x5, x9, #0x9         
// 2) WindowManagerAgent SpringBehavior.init(dampingRatio:response:) 0x100073a14: tension=(2pi/response)^2, friction=dampingRatio*2*sqrt(tension),
//    settlingDuration = CASpringAnimation(mass 1, stiffness tension, damping friction).settlingDuration (0x10007394c).
100073a0c	ldp	d9, d8, [sp], #0x30
100073a10	retab
100073a14	pacibsp
100073a18	stp	d11, d10, [sp, #-0x30]!
100073a1c	stp	d9, d8, [sp, #0x10]
100073a20	stp	x29, x30, [sp, #0x20]
100073a24	add	x29, sp, #0x20
100073a28	mov.16b	v8, v1
100073a2c	mov.16b	v9, v0
100073a30	adrp	x8, 1070 ; 0x1004a1000
100073a34	ldr	d0, [x8, #0xce8]
100073a38	fdiv	d0, d0, d1
100073a3c	fmul	d10, d0, d0
100073a40	fsqrt	d0, d10
100073a44	fadd	d0, d0, d0
100073a48	fmul	d11, d9, d0
100073a4c	mov.16b	v0, v10
100073a50	mov.16b	v1, v11
100073a54	bl	0x10007394c
100073a58	stp	d9, d8, [x20, #0x10]
100073a5c	stp	d10, d11, [x20, #0x20]
100073a60	str	d0, [x20, #0x30]
100073a64	mov	x0, x20
100073a68	ldp	x29, x30, [sp, #0x20]
100073a6c	ldp	d9, d8, [sp, #0x10]
100073a70	ldp	d11, d10, [sp], #0x30
100073a74	retab
100073a78	mov	x0, x20
100073a7c	ret
100073a80	mov	x0, x20
100073a84	mov	w1, #0x38
// 3) Spring factories: expose 0x100134554 (ExposeSpringDampingRatio, ExposeSpringResponse), spacesBarExit 0x1001345a0 (1.0, 0.125),
//    trackpad 0x1001345e4 (response *= 0.6 when |velocity| > 5.0).
100134560	stp	x29, x30, [sp, #0x20]
100134564	add	x29, sp, #0x20
100134568	mov	x0, x20
10013456c	adrp	x8, 1225 ; 0x1005fd000
100134570	ldr	d8, [x8, #0xb30]
100134574	adrp	x8, 1225 ; 0x1005fd000
100134578	ldr	d9, [x8, #0xb38]
10013457c	bl	0x100134780
100134580	mov.16b	v0, v8
100134584	mov.16b	v1, v9
100134588	mov	x20, x0
10013458c	bl	0x100073a14
100134590	ldp	x29, x30, [sp, #0x20]
100134594	ldp	x20, x19, [sp, #0x10]
100134598	ldp	d9, d8, [sp], #0x30
10013459c	retab
1001345a0	pacibsp
1001345a4	stp	d9, d8, [sp, #-0x30]!
1001345a8	stp	x20, x19, [sp, #0x10]
1001345ac	stp	x29, x30, [sp, #0x20]
1001345b0	add	x29, sp, #0x20
1001345b4	mov	x0, x20
1001345b8	adrp	x8, 1225 ; 0x1005fd000
1001345bc	ldr	d8, [x8, #0xb40]
1001345c0	bl	0x100134780
1001345c4	fmov	d0, #1.00000000
1001345c8	mov.16b	v1, v8
1001345cc	mov	x20, x0
1001345d0	bl	0x100073a14
1001345d4	ldp	x29, x30, [sp, #0x20]
1001345d8	ldp	x20, x19, [sp, #0x10]
1001345dc	ldp	d9, d8, [sp], #0x30
1001345e0	retab
1001345e4	pacibsp
1001345e8	stp	d9, d8, [sp, #-0x30]!
1001345ec	stp	x20, x19, [sp, #0x10]
1001345f0	stp	x29, x30, [sp, #0x20]
1001345f4	add	x29, sp, #0x20
1001345f8	mov	x17, x20
1001345fc	fabs	d0, d0
100134600	ldr	x16, [x20]
100134604	movk	x17, #0x6ae1, lsl #48
100134608	autda	x16, x17
10013460c	mov	x17, x16
100134610	xpacd	x17
100134614	cmp	x16, x17
100134618	b.eq	0x100134620
10013461c	brk	#0xc472
100134620	adrp	x8, 1225 ; 0x1005fd000
100134624	ldr	d1, [x8, #0xb48]
100134628	fcmp	d1, d0
10013462c	b.pl	0x100134668
100134630	ldp	d8, d0, [x20, #0x10]
100134634	adrp	x8, 1225 ; 0x1005fd000
100134638	ldr	d1, [x8, #0xb50]
10013463c	fmul	d9, d0, d1
100134640	mov	x0, x16
100134644	bl	0x100134780
100134648	mov.16b	v0, v8
10013464c	mov.16b	v1, v9
100134650	mov	x20, x0
100134654	bl	0x100073a14
100134658	ldp	x29, x30, [sp, #0x20]
