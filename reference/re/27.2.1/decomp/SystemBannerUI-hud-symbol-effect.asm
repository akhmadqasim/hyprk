; SystemBannerUI.framework 27.2.1 (26B131), dyld cache addresses; ipsw dyld disass --cache <DSC>.a2s --demangle (PC, 2026-11-15).
; 1. SymbolEffectState.update(value: d0), x20 = &state { valueLabelSeed: UInt32 @0, previousValue: Double? @8, tag @0x10 }
0x2aed4af5c:  81 06 40 fd   ldr	d1, [x20, #0x8]
0x2aed4af60:  88 42 40 39   ldrb	w8, [x20, #0x10]
0x2aed4af64:  1f 05 00 71   cmp	w8, #0x1
0x2aed4af68:  00 14 61 1e   fccmp	d0, d1, #0, ne
0x2aed4af6c:  40 01 00 54   b.eq	loc_2aed4af94 ; ⤵ 0x28
0x2aed4af70:  80 06 00 fd   str	d0, [x20, #0x8]
0x2aed4af74:  9f 42 00 39   strb	wzr, [x20, #0x10]
0x2aed4af78:  08 20 60 1e   fcmp	d0, #0.00000000
0x2aed4af7c:  01 10 6e 1e   fmov	d1, #1.00000000
0x2aed4af80:  04 14 61 1e   fccmp	d0, d1, #0x4, ne
0x2aed4af84:  81 00 00 54   b.ne	loc_2aed4af94 ; ⤵ 0x10
0x2aed4af88:  88 02 40 b9   ldr	w8, [x20]
0x2aed4af8c:  08 05 00 11   add	w8, w8, #0x1
0x2aed4af90:  88 02 00 b9   str	w8, [x20]
0x2aed4af94:  ; loc_2aed4af94
0x2aed4af94:  c0 03 5f d6   ret

; 2. its caller on every content set (SystemBannerContentController content didSet, 0x2aed4adf0): sliderCurrentValue = nil, value = content.value (witness +0x40), update
0x2aed4ae90:  e8 03 16 aa   mov	x8, x22
0x2aed4ae94:  09 0d 44 f8   ldr	x9, [x8, #0x40]!
0x2aed4ae98:  f4 03 00 aa   mov	x20, x0
0x2aed4ae9c:  e0 03 15 aa   mov	x0, x21
0x2aed4aea0:  e1 03 16 aa   mov	x1, x22
0x2aed4aea4:  f1 03 08 aa   mov	x17, x8
0x2aed4aea8:  71 27 ea f2   movk	x17, #0x513b, lsl #0x30
0x2aed4aeac:  31 09 3f d7   blraa	x9, x17
0x2aed4aeb0:  08 1c a0 4e   mov	v8.16b, v0.16b
0x2aed4aeb4:  f4 01 00 f0   adrp	x20, 0x2aed89000
0x2aed4aeb8:  94 e2 30 91   add	x20, x20, #0xc38 ; "0\xd9\xe62"
0x2aed4aebc:  80 22 04 91   add	x0, x20, #0x108
0x2aed4aec0:  34 ce 4c 94   bl	j__swift_getKeyPath
0x2aed4aec4:  f5 03 00 aa   mov	x21, x0
0x2aed4aec8:  e0 03 14 aa   mov	x0, x20
0x2aed4aecc:  31 ce 4c 94   bl	j__swift_getKeyPath
0x2aed4aed0:  f6 03 00 aa   mov	x22, x0
0x2aed4aed4:  e0 03 00 91   mov	x0, sp
0x2aed4aed8:  e1 03 13 aa   mov	x1, x19
0x2aed4aedc:  e2 03 15 aa   mov	x2, x21
0x2aed4aee0:  e3 03 16 aa   mov	x3, x22
0x2aed4aee4:  eb 25 4d 94   bl	j__$s7Combine9PublishedV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAHyqd__ACyxGGtcRld
0x2aed4aee8:  f3 03 00 aa   mov	x19, x0
0x2aed4aeec:  00 1d a8 4e   mov	v0.16b, v8.16b
0x2aed4aef0:  f4 03 01 aa   mov	x20, x1
0x2aed4aef4:  1a 00 00 94   bl	0x2aed4af5c
0x2aed4aef8:  e0 03 00 91   mov	x0, sp
0x2aed4aefc:  01 00 80 52   mov	w1, #0
0x2aed4af00:  f1 03 17 aa   mov	x17, x23
0x2aed4af04:  b1 e8 e1 f2   movk	x17, #0xf45, lsl #0x30
0x2aed4af08:  71 0a 3f d7   blraa	x19, x17

; 3. SliderBannerImageView.body (0x2aed644bc): Image.symbolVariant -> .symbolEffect(BounceSymbolEffect(), options: .default, value: seed) -> font 26 / 21 -> scaleEffect(isInflated ? 1.1 : 1, anchor: .trailing)
0x2aed645fc:  cd 25 4d 94   bl	j__$s7SwiftUI4ViewPAAE13symbolVariantyQrAA14SymbolVariantsVF
0x2aed64600:  e8 03 16 aa   mov	x8, x22
0x2aed64604:  1f 01 4d 94   bl	j__$s7Symbols18BounceSymbolEffectVACycfC
0x2aed64608:  00 00 80 d2   mov	x0, #0
0x2aed6460c:  6b ff ff 97   bl	0x2aed643b8
0x2aed64610:  a8 c3 01 d1   sub	x8, fp, #0x70
0x2aed64614:  00 01 10 f8   stur	x0, [x8, #-0x100]
0x2aed64618:  08 1c 80 b9   ldrsw	x8, [x0, #0x1c]
0x2aed6461c:  a8 02 08 8b   add	x8, x21, x8
0x2aed64620:  14 01 40 f9   ldr	x20, [x8]
0x2aed64624:  b4 1d 00 b4   cbz	x20, loc_2aed649d8 ; ⤵ 0x3b4
0x2aed64628:  e0 03 14 aa   mov	x0, x20
0x2aed64630:  e8 98 ff 97   bl	0x2aed4a9d0
0x2aed64634:  f7 03 00 aa   mov	x23, x0
0x2aed64638:  e0 03 14 aa   mov	x0, x20
0x2aed64640:  80 74 19 b0   adrp	x0, 0x2e1bf5000
0x2aed64644:  00 40 2e 91   add	x0, x0, #0xb90 ; data_2e1bf5b90 (SystemBannerUI/__DATA.__data)
0x2aed64648:  21 01 00 f0   adrp	x1, 0x2aed8b000
0x2aed6464c:  21 20 24 91   add	x1, x1, #0x908 ; "lb"
0x2aed64650:  81 7a ff 97   bl	___swift_instantiateConcreteTypeFromMangledNameV2
0x2aed64654:  08 24 80 b9   ldrsw	x8, [x0, #0x24]
0x2aed64658:  74 02 08 8b   add	x20, x19, x8
0x2aed6465c:  80 74 19 b0   adrp	x0, 0x2e1bf5000
0x2aed64660:  00 60 2e 91   add	x0, x0, #0xb98 ; data_2e1bf5b98 (SystemBannerUI/__DATA.__data)
0x2aed64664:  21 01 00 f0   adrp	x1, 0x2aed8b000
0x2aed64668:  21 40 24 91   add	x1, x1, #0x910 ; "\x88b"
0x2aed6466c:  7a 7a ff 97   bl	___swift_instantiateConcreteTypeFromMangledNameV2
0x2aed64670:  f8 03 00 aa   mov	x24, x0
0x2aed64674:  08 28 80 b9   ldrsw	x8, [x0, #0x28]
0x2aed64678:  88 02 08 8b   add	x8, x20, x8
0x2aed6467c:  17 01 00 b9   str	w23, [x8]
0x2aed64680:  e8 03 1b aa   mov	x8, x27
0x2aed64684:  f3 25 4d 94   bl	j__$s7Symbols19SymbolEffectOptionsV7defaultACvgZ
0x2aed64688:  08 27 80 b9   ldrsw	x8, [x24, #0x24]
0x2aed6468c:  e9 03 19 aa   mov	x9, x25
0x2aed647d8:  28 01 00 f0   adrp	x8, 0x2aed8b000
0x2aed647dc:  00 4d 44 fd   ldr	d0, [x8, #0x898] ; "\x9a\x99\x99\x99\x99\x99\xf1?SliderBannerImageView"
0x2aed647e0:  0f 02 00 94   bl	_OUTLINED_FUNCTION_0
0x2aed647e4:  16 51 00 a9   stp	x22, x20, [x8]
0x2aed647e8:  a8 c3 01 d1   sub	x8, fp, #0x70
0x2aed647ec:  19 01 50 f8   ldur	x25, [x8, #-0x100]
0x2aed647f0:  28 1b 80 b9   ldrsw	x8, [x25, #0x18]
0x2aed647f4:  a8 02 08 8b   add	x8, x21, x8
0x2aed647f8:  08 01 40 39   ldrb	w8, [x8]
0x2aed647fc:  1f 01 00 71   cmp	w8, #0
0x2aed64800:  01 10 6e 1e   fmov	d1, #1.00000000
0x2aed64804:  0a 1c 61 1e   fcsel	d10, d0, d1, ne
0x2aed64808:  be a2 4c 94   bl	j__$s7SwiftUI9UnitPointV8trailingACvgZ
0x2aed6480c:  08 1c a0 4e   mov	v8.16b, v0.16b

; 4. BannerSlider's HStack content (0x2aed62950) builds it with variant 0 and isInflated false
0x2aed62c34:  88 17 80 b9   ldrsw	x8, [x28, #0x14]
0x2aed62c38:  08 03 08 8b   add	x8, x24, x8
0x2aed62c3c:  1f 01 00 39   strb	wzr, [x8]
0x2aed62c40:  00 00 80 d2   mov	x0, #0
0x2aed62c44:  d8 a3 ff 97   bl	0x2aed4bba4
0x2aed62c48:  f4 03 00 aa   mov	x20, x0
0x2aed62c4c:  80 74 19 d0   adrp	x0, 0x2e1bf4000
0x2aed62c50:  00 60 3c 91   add	x0, x0, #0xf18 ; data_2e1bf4f18 (SystemBannerUI/__DATA.__data)
0x2aed62c54:  50 ff ff b0   adrp	x16, 0x2aed4b000
0x2aed62c58:  10 92 2e 91   add	x16, x16, #0xba4
0x2aed62c5c:  51 12 81 d2   mov	x17, #0x892
0x2aed62c60:  30 02 c1 da   pacia	x16, x17
0x2aed62c64:  e1 03 10 aa   mov	x1, x16
0x2aed62c68:  30 01 00 f0   adrp	x16, 0x2aed89000
0x2aed62c6c:  10 12 2e 91   add	x16, x16, #0xb84 ; "\xe5\xdf\xcb+\x9c?"
0x2aed62c70:  71 dd 98 d2   mov	x17, #0xc6eb
0x2aed62c74:  30 0a c1 da   pacda	x16, x17
0x2aed62c78:  e2 03 10 aa   mov	x2, x16
0x2aed62c7c:  eb 00 00 94   bl	0x2aed63028
0x2aed62c80:  e1 03 00 aa   mov	x1, x0
0x2aed62c84:  e0 03 14 aa   mov	x0, x20
0x2aed62c88:  36 85 4c 94   bl	j__$s7SwiftUI17EnvironmentObjectVACyxGycfC
0x2aed62c8c:  88 1b 80 b9   ldrsw	x8, [x28, #0x18]
0x2aed62c90:  08 03 08 8b   add	x8, x24, x8
0x2aed62c94:  1f 01 00 39   strb	wzr, [x8]
0x2aed62c98:  bc 03 16 f8   stur	x28, [fp, #-0xa0]

; 5. TickedTrackMask.path(in:) 0x2aed66984: for i in 1 ..< tickCount: rect x = width * i / tickCount, width = tickWidth * tickProgress; tickProgress = showTicks && isEnabled ? 1 : 0 (0x2aed66314)
0x2aed669d4:  88 21 60 1e   fcmp	d12, #0.00000000
0x2aed669d8:  a8 ca 42 fa   ccmp	x21, #0x2, #0x8, gt
0x2aed669dc:  ab 03 00 54   b.lt	loc_2aed66a50 ; ⤵ 0x74
0x2aed669e0:  ac 09 6c 1e   fmul	d12, d13, d12
0x2aed669e4:  af 02 63 9e   ucvtf	d15, x21
0x2aed669e8:  08 fe e7 d2   mov	x8, #0x3ff0000000000000
0x2aed669ec:  e8 7f 03 a9   stp	x8, xzr, [sp, #0x30]
0x2aed669f0:  ff 23 04 a9   stp	xzr, x8, [sp, #0x40]
0x2aed669f4:  34 00 80 52   mov	w20, #0x1
0x2aed669f8:  ff 7f 05 a9   stp	xzr, xzr, [sp, #0x50]
0x2aed669fc:  ; loc_2aed669fc
0x2aed669fc:  96 06 00 91   add	x22, x20, #0x1
0x2aed66a00:  c6 7e ff 97   bl	_OUTLINED_FUNCTION_0
0x2aed66a04:  9f bc 4c 94   bl	j__CGRectGetWidth
0x2aed66a08:  81 02 63 9e   ucvtf	d1, x20
0x2aed66a0c:  00 08 61 1e   fmul	d0, d0, d1
0x2aed66a10:  0d 18 6f 1e   fdiv	d13, d0, d15
0x2aed66a14:  c1 7e ff 97   bl	_OUTLINED_FUNCTION_0
0x2aed66a18:  96 bc 4c 94   bl	j__CGRectGetMinY
0x2aed66a1c:  0e 1c a0 4e   mov	v14.16b, v0.16b
0x2aed66a20:  be 7e ff 97   bl	_OUTLINED_FUNCTION_0
0x2aed66a24:  8b bc 4c 94   bl	j__CGRectGetHeight
0x2aed66a28:  03 1c a0 4e   mov	v3.16b, v0.16b
0x2aed66a2c:  e0 c3 00 91   add	x0, sp, #0x30
0x2aed66a30:  f4 23 00 91   add	x20, sp, #0x8
0x2aed66a34:  a0 1d ad 4e   mov	v0.16b, v13.16b
0x2aed66a38:  c1 1d ae 4e   mov	v1.16b, v14.16b
0x2aed66a3c:  82 1d ac 4e   mov	v2.16b, v12.16b
0x2aed66a40:  b0 1c 4d 94   bl	j__$s7SwiftUI4PathV7addRect_9transformySo6CGRectV_So17CGAffineTransformVtF
0x2aed66a44:  f4 03 16 aa   mov	x20, x22
0x2aed66a48:  bf 02 16 eb   cmp	x21, x22
0x2aed66a4c:  81 fd ff 54   b.ne	loc_2aed669fc ; ⤴ -0x50
0x2aed66a50:  ; loc_2aed66a50
