; SystemBannerUI 27.2.1 arm64e: static animation initialisers. stub 0x2b00a1c10 -> SwiftUICore 0x190d2440c Animation.interpolatingSpring(mass:stiffness:damping:initialVelocity:); stub 0x2b00955f0 -> 0x190ee11b8 Animation.spring(response:dampingFraction:blendDuration:)
; constants: [0x2aed89048]=300.0 [..50]=0.2 [..58]=0.85 [..60]=0.62832 [..68]=0.73333 [..70]=0.48669; 0x4049000000000000 = 50.0
0x2AED436A4   pacibsp                       
0x2AED436A8   stp      x29, x30, [sp, #-0x10]! 
0x2AED436AC   mov      x29, sp              
0x2AED436B0   adrp     x8, 70               ; 0x2aed89000
0x2AED436B4   ldr      d1, [x8, #0x48]      
0x2AED436B8   mov      x8, #0x4049000000000000 
0x2AED436BC   fmov     d2, x8               
0x2AED436C0   fmov     d0, #2.00000000      
0x2AED436C4   movi.2d  v3, #0000000000000000 
0x2AED436C8   bl       0x2b00a1c10          
0x2AED436CC   adrp     x8, 208563           ; 0x2e1bf6000
0x2AED436D0   str      x0, [x8, #0x780]     
0x2AED436D4   ldp      x29, x30, [sp], #0x10 
0x2AED436D8   retab                         
0x2AED436DC   pacibsp                       
0x2AED436E0   stp      x29, x30, [sp, #-0x10]! 
0x2AED436E4   mov      x29, sp              
0x2AED436E8   adrp     x8, 70               ; 0x2aed89000
0x2AED436EC   ldr      d0, [x8, #0x50]      
0x2AED436F0   adrp     x8, 70               ; 0x2aed89000
0x2AED436F4   ldr      d1, [x8, #0x58]      
0x2AED436F8   movi.2d  v2, #0000000000000000 
0x2AED436FC   bl       0x2b00955f0          
0x2AED43700   adrp     x8, 208563           ; 0x2e1bf6000
0x2AED43704   str      x0, [x8, #0x788]     
0x2AED43708   ldp      x29, x30, [sp], #0x10 
0x2AED4370C   retab                         
0x2AED43710   pacibsp                       
0x2AED43714   stp      x29, x30, [sp, #-0x10]! 
0x2AED43718   mov      x29, sp              
0x2AED4371C   adrp     x8, 70               ; 0x2aed89000
0x2AED43720   ldr      d0, [x8, #0x60]      
0x2AED43724   adrp     x8, 70               ; 0x2aed89000
0x2AED43728   ldr      d1, [x8, #0x68]      
0x2AED4372C   movi.2d  v2, #0000000000000000 
0x2AED43730   bl       0x2b00955f0          
0x2AED43734   adrp     x8, 208563           ; 0x2e1bf6000
0x2AED43738   str      x0, [x8, #0x5d8]     
0x2AED4373C   ldp      x29, x30, [sp], #0x10 
0x2AED43740   retab                         
0x2AED43744   pacibsp                       
0x2AED43748   stp      x29, x30, [sp, #-0x10]! 
0x2AED4374C   mov      x29, sp              
0x2AED43750   adrp     x8, 70               ; 0x2aed89000
0x2AED43754   ldr      d0, [x8, #0x70]      
0x2AED43758   fmov     d1, #1.00000000      
0x2AED4375C   movi.2d  v2, #0000000000000000 
0x2AED43760   bl       0x2b00955f0          
0x2AED43764   adrp     x8, 208563           ; 0x2e1bf6000
0x2AED43768   str      x0, [x8, #0x778]     
0x2AED4376C   ldp      x29, x30, [sp], #0x10 
0x2AED43770   retab                         

; SwiftUICore SpringAnimation.animate (Double path 0x190d234ac): zeta = damping/(2*sqrt(mass*stiffness)); fcmp zeta,1.0; b.pl -> critical-damping branch (zeta >= 1 treated as 1)
0x190D234DC   fmov     d3, #1.00000000      
0x190D234E0   ldp      d0, d2, [x20, #0x10] 
0x190D234E4   ldp      d1, d11, [x20]       
0x190D234E8   fmul     d4, d11, d1          
0x190D234EC   fsqrt    d4, d4               
0x190D234F0   fadd     d4, d4, d4           
0x190D234F4   fdiv     d0, d0, d4           
0x190D234F8   fdiv     d1, d11, d1          
0x190D234FC   fsqrt    d1, d1               
0x190D23500   fcmp     d0, d3               
0x190D23504   b.pl     0x190d23528          
0x190D23508   fmul     d4, d0, d0           
0x190D2350C   fsub     d3, d3, d4           
0x190D23510   fsqrt    d3, d3               
0x190D23514   fmul     d3, d1, d3           
0x190D23518   fmul     d4, d1, d0           
0x190D2351C   fsub     d2, d4, d2           
0x190D23520   fdiv     d2, d2, d3           
0x190D23524   b        0x190d23530          
0x190D23528   fsub     d2, d1, d2           
0x190D2352C   movi.2d  v3, #0000000000000000 
