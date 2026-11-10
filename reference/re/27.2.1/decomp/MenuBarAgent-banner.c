// MenuBarAgent 27.2.1 arm64e: SystemBannerTimeoutMode -> seconds (asm)
0x10031D44C   pacibsp                       
0x10031D450   sub      sp, sp, #0x20        
0x10031D454   stp      x29, x30, [sp, #0x10] 
0x10031D458   add      x29, sp, #0x10       
0x10031D45C   and      w8, w1, #0xff        
0x10031D460   cmp      w8, #0x1             
0x10031D464   b.ne     0x10031d498          
0x10031D468   fmov     d0, #1.00000000      
0x10031D46C   mov      x16, x0              
0x10031D470   cmp      x16, #0x3            
0x10031D474   csel     x16, x16, xzr, ls    
0x10031D478   adrp     x17, 0               ; 0x10031d000
0x10031D47C   add      x17, x17, #0x4fc     
0x10031D480   ldrsw    x16, [x17, x16, lsl #2] 
0x10031D484   adr      x17, #0              
0x10031D488   add      x16, x17, x16        
0x10031D48C   br       x16                  
0x10031D490   fmov     d0, #4.00000000      
0x10031D494   b        0x10031d4a4          
0x10031D498   fmov     d0, x0               
0x10031D49C   b        0x10031d4a4          
0x10031D4A0   fmov     d0, #20.00000000     
0x10031D4A4   ldp      x29, x30, [sp, #0x10] 
0x10031D4A8   add      sp, sp, #0x20        
0x10031D4AC   retab                         
0x10031D4B0   adrp     x8, 269              ; 0x10042a000
0x10031D4B4   add      x8, x8, #0x9f0       
0x10031D4B8   sub      x8, x8, #0x20        
0x10031D4BC   str      wzr, [sp, #0x8]      
0x10031D4C0   mov      w9, #0xcf            
0x10031D4C4   str      x9, [sp]             
0x10031D4C8   adrp     x0, 267              ; 0x100428000
0x10031D4CC   add      x0, x0, #0x930       
0x10031D4D0   adrp     x5, 269              ; 0x10042a000
0x10031D4D4   add      x5, x5, #0x9c0       
0x10031D4D8   orr      x4, x8, #0x8000000000000000 
0x10031D4DC   mov      w1, #0xb             
0x10031D4E0   mov      w2, #0x2             
0x10031D4E4   mov      x3, #0x3e            
0x10031D4E8   movk     x3, #0xd000, lsl #48 
0x10031D4EC   mov      w6, #0x2e            
0x10031D4F0   mov      w7, #0x2             
0x10031D4F4   bl       _$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_SSAHSus6UInt32VtF 
0x10031D4F8   brk      #0x1                 
0x10031D4FC   udf      #0x20                
0x10031D500   udf      #0xc                 
0x10031D504   udf      #0x1c                
0x10031D508   udf      #0x2c                
0x10031D50C   pacibsp                       
0x10031D510   stp      x28, x27, [sp, #-0x60]! 
0x10031D514   stp      x26, x25, [sp, #0x10] 
// FluidSpring configuration statics (asm)
0x10007B05C   adrp     x8, 887              ; 0x1003f2000
0x10007B060   ldr      q0, [x8, #0x890]     
0x10007B064   adrp     x8, 1159             ; 0x100502000
0x10007B068   add      x8, x8, #0x410       
0x10007B06C   str      q0, [x8]             
0x10007B070   mov      x9, #0x3fe0000000000000 
0x10007B074   b        0x10007b148          
0x10007B078   adrp     x8, 887              ; 0x1003f2000
0x10007B07C   ldr      q0, [x8, #0x890]     
0x10007B080   adrp     x8, 1159             ; 0x100502000
0x10007B084   add      x8, x8, #0x3d0       
0x10007B088   str      q0, [x8]             
0x10007B08C   mov      x9, #0x3fe0000000000000 
0x10007B090   b        0x10007b148          
0x10007B094   adrp     x8, 887              ; 0x1003f2000
0x10007B098   ldr      q0, [x8, #0x8a0]     
0x10007B09C   adrp     x8, 1159             ; 0x100502000
0x10007B0A0   add      x8, x8, #0x450       
0x10007B0A4   str      q0, [x8]             
0x10007B0A8   mov      x9, #0x6666666666666666 
0x10007B0AC   movk     x9, #0x3fd6, lsl #48 
0x10007B0B0   b        0x10007b148          
0x10007B0B4   adrp     x8, 887              ; 0x1003f2000
0x10007B0B8   ldr      q0, [x8, #0x890]     
0x10007B0BC   adrp     x8, 1159             ; 0x100502000
0x10007B0C0   add      x8, x8, #0x490       
0x10007B0C4   str      q0, [x8]             
0x10007B0C8   mov      x9, #0x934b          
0x10007B0CC   movk     x9, #0xd052, lsl #16 
0x10007B0D0   movk     x9, #0x25ed, lsl #32 
0x10007B0D4   movk     x9, #0x3fdf, lsl #48 
0x10007B0D8   b        0x10007b148          
0x10007B0DC   adrp     x8, 887              ; 0x1003f2000
0x10007B0E0   ldr      q0, [x8, #0x8b0]     
0x10007B0E4   adrp     x8, 1159             ; 0x100502000
0x10007B0E8   add      x8, x8, #0x390       
0x10007B0EC   str      q0, [x8]             
0x10007B0F0   mov      x9, #-0x6666666666666667 
0x10007B0F4   movk     x9, #0x999a          
0x10007B0F8   movk     x9, #0x3fe9, lsl #48 
0x10007B0FC   b        0x10007b148          
0x10007B100   adrp     x8, 887              ; 0x1003f2000
0x10007B104   ldr      q0, [x8, #0x8a0]     
0x10007B108   adrp     x8, 1159             ; 0x100502000
0x10007B10C   add      x8, x8, #0x4d0       
0x10007B110   str      q0, [x8]             
0x10007B114   mov      x9, #0x6666666666666666 
0x10007B118   movk     x9, #0x3fd6, lsl #48 
0x10007B11C   b        0x10007b148          
0x10007B120   adrp     x8, 887              ; 0x1003f2000
0x10007B124   ldr      q0, [x8, #0x8b0]     
0x10007B128   adrp     x8, 1159             ; 0x100502000
0x10007B12C   add      x8, x8, #0x510       
0x10007B130   str      q0, [x8]             
0x10007B134   mov      x9, #0xf5c3          
0x10007B138   movk     x9, #0x5c28, lsl #16 
0x10007B13C   movk     x9, #0xc28f, lsl #32 
0x10007B140   movk     x9, #0x3fc5, lsl #48 
0x10007B144   b        0x10007b148          
0x10007B148   stp      xzr, xzr, [x8, #0x18] 
0x10007B14C   str      x9, [x8, #0x10]      
0x10007B150   strb     wzr, [x8, #0x28]     
0x10007B154   stp      xzr, xzr, [x8, #0x30] 
0x10007B158   ret                           
0x10007B15C   pacibsp                       
