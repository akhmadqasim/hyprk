; Dock.app 27.2.1 (26B131) /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock, arm64e (otool -tV), function 0x10011a444.
; The Dock platter glass: DesignLibrary.GlassMaterialProvider.Configuration.dock, then .size = Size.medium, then adaptive(false).
; (Other sites: 0x1000ba154/168 Configuration.regular with Size.minimum / .maximum; 0x10011a340 Configuration.appIcons with
;  Size.minimum; 0x100186868 Configuration.cartouchePopover with Size.minimum / .medium.)
; Size.medium = reference dimension 166 pt (DesignLibrary 0x195F6467C, table 0x195fb2068), so the Dock's refraction is
; 0.08*166 = 13.28 pt high and -0.18*166 = -29.88 pt deep whatever the Dock's own height is.
000000010011a524	bl	0x1000b9f10
000000010011a528	sub	x26, x9, x8
000000010011a52c	mov	sp, x26
000000010011a530	mov	x8, x20
000000010011a534	bl	0x100231f6c ; symbol stub for: _$s13DesignLibrary21GlassMaterialProviderV13ConfigurationV4dockAEvgZ
000000010011a538	adrp	x8, 468 ; 0x1002ee000
000000010011a53c	ldr	x8, [x8, #0xc98] ; literal pool symbol address: _$s13DesignLibrary21GlassMaterialProviderV4SizeO6mediumyA2EmFWC
000000010011a540	ldr	w1, [x8]
000000010011a544	ldr	x8, [x25, #0x68]!
000000010011a548	mov	x0, x26
000000010011a54c	mov	x2, x24
000000010011a550	mov	x17, x25
000000010011a554	movk	x17, #0xb2e4, lsl #48
000000010011a558	blraa	x8, x17
000000010011a55c	mov	x0, x26
000000010011a560	bl	0x100231f7c ; symbol stub for: _$s13DesignLibrary21GlassMaterialProviderV13ConfigurationV4sizeAC4SizeOvs
000000010011a564	tbnz	w23, #0x0, 0x10011a5ac
000000010011a568	mov	x8, x22
000000010011a56c	mov	w0, #0x0
000000010011a570	bl	0x100231fac ; symbol stub for: _$s13DesignLibrary21GlassMaterialProviderV13ConfigurationV8adaptiveyAESbF
