; SpotlightUIInternal 27.2.1 arm64e. Caller FUN_2ade99418 (invocation): d0 = 1.12 (0x3ff1eb851eb851ec), d1 = 0.95, d2 = 0, w0 = Bool from a class method (vtable +0x460)
0x2ADE99854   add      x8, x16, #0x460      
0x2ADE99858   ldr      x9, [x16, #0x460]    
0x2ADE9985C   mov      x20, x22             
0x2ADE99860   mov      x17, x8              
0x2ADE99864   movk     x17, #0xfa5a, lsl #48 
0x2ADE99868   blraa    x9, x17              
0x2ADE9986C   mov      x8, #0x51ec          
0x2ADE99870   movk     x8, #0x1eb8, lsl #16 
0x2ADE99874   movk     x8, #0xeb85, lsl #32 
0x2ADE99878   movk     x8, #0x3ff1, lsl #48 
0x2ADE9987C   fmov     d0, x8               
0x2ADE99880   mov      x8, #0x6666666666666666 
0x2ADE99884   movk     x8, #0x3fee, lsl #48 
0x2ADE99888   fmov     d1, x8               
0x2ADE9988C   and      w0, w0, #0x1         
0x2ADE99890   movi.2d  v2, #0000000000000000 
0x2ADE99894   bl       0x2adea2ff0          
0x2ADE99898   mov      x20, x0              

; FUN_2adea2ff0(xScale d0, yScale d1, translation d2, flag w0): three CASpringAnimation initWithPerceptualDuration:bounce: (stub 0x2b005ec50)
;  transform.scale.x: duration 0.28, bounce = flag ? 0.41 : 0.32, from d0 to 1
;  transform.scale.y: duration 0.28, bounce 0.32, from (flag || d2 > 0) ? d1 : d0  to 1
;  transform.translation.y: duration 0.28, bounce 0.32, from d2 to 0
0x2ADEA2FF0   pacibsp                       
0x2ADEA2FF4   sub      sp, sp, #0xa0        
0x2ADEA2FF8   stp      d13, d12, [sp, #0x10] 
0x2ADEA2FFC   stp      d11, d10, [sp, #0x20] 
0x2ADEA3000   stp      d9, d8, [sp, #0x30]  
0x2ADEA3004   stp      x28, x27, [sp, #0x40] 
0x2ADEA3008   stp      x26, x25, [sp, #0x50] 
0x2ADEA300C   stp      x24, x23, [sp, #0x60] 
0x2ADEA3010   stp      x22, x21, [sp, #0x70] 
0x2ADEA3014   stp      x20, x19, [sp, #0x80] 
0x2ADEA3018   stp      x29, x30, [sp, #0x90] 
0x2ADEA301C   add      x29, sp, #0x90       
0x2ADEA3020   mov.16b  v8, v2               
0x2ADEA3024   mov.16b  v11, v1              
0x2ADEA3028   mov.16b  v12, v0              
0x2ADEA302C   mov      x20, x0              
0x2ADEA3030   tst      w0, #0x1             
0x2ADEA3034   mov      x8, #0x147b          
0x2ADEA3038   movk     x8, #0x47ae, lsl #16 
0x2ADEA303C   movk     x8, #0x7ae1, lsl #32 
0x2ADEA3040   movk     x8, #0x3fd4, lsl #48 
0x2ADEA3044   fmov     d9, x8               
0x2ADEA3048   mov      x8, #0xa3d           
0x2ADEA304C   movk     x8, #0xa3d7, lsl #16 
0x2ADEA3050   movk     x8, #0x3d70, lsl #32 
0x2ADEA3054   movk     x8, #0x3fda, lsl #48 
0x2ADEA3058   fmov     d0, x8               
0x2ADEA305C   fcsel    d13, d0, d9, ne      
0x2ADEA3060   adrp     x23, 172441          ; 0x2d803c000
0x2ADEA3064   ldr      x0, [x23, #0x1c8]    
0x2ADEA3068   bl       0x2b007a180          
0x2ADEA306C   mov      x8, #0x51ec          
0x2ADEA3070   movk     x8, #0x1eb8, lsl #16 
0x2ADEA3074   movk     x8, #0xeb85, lsl #32 
0x2ADEA3078   movk     x8, #0x3fd1, lsl #48 
0x2ADEA307C   fmov     d10, x8              
0x2ADEA3080   mov.16b  v0, v10              
0x2ADEA3084   mov.16b  v1, v13              
0x2ADEA3088   bl       0x2b005ec50          
0x2ADEA308C   adrp     x8, 351              ; 0x2ae002000
0x2ADEA3090   add      x8, x8, #0x700       
0x2ADEA3094   sub      x21, x8, #0x20       
0x2ADEA3098   bl       0x2b007a1d0          
0x2ADEA309C   mov      x19, x0              
0x2ADEA30A0   mov      x24, #0x11           
0x2ADEA30A4   movk     x24, #0xd000, lsl #48 
0x2ADEA30A8   orr      x1, x21, #0x8000000000000000 
0x2ADEA30AC   mov      x0, #0x11            
0x2ADEA30B0   movk     x0, #0xd000, lsl #48 
0x2ADEA30B4   bl       0x2b0079270          
0x2ADEA30B8   mov      x21, x0              
0x2ADEA30BC   mov      x0, x19              
0x2ADEA30C0   mov      x2, x21              
0x2ADEA30C4   bl       0x2b005fec0          
0x2ADEA30C8   mov      x0, x19              
0x2ADEA30CC   bl       0x2b007a1c0          
0x2ADEA30D0   mov      x0, x21              
0x2ADEA30D4   bl       0x2b007a1c0          
0x2ADEA30D8   mov      x0, x19              
0x2ADEA30DC   bl       0x2b007a1d0          
0x2ADEA30E0   mov      x19, x0              
0x2ADEA30E4   mov.16b  v0, v12              
0x2ADEA30E8   bl       0x2b0093cc0          
0x2ADEA30EC   mov      x21, x0              
0x2ADEA30F0   mov      x0, x19              
0x2ADEA30F4   mov      x2, x21              
0x2ADEA30F8   bl       0x2b003f180          
0x2ADEA30FC   mov      x0, x21              
0x2ADEA3100   bl       0x2b007a1c0          
0x2ADEA3104   fmov     d0, #1.00000000      
0x2ADEA3108   bl       0x2b0093cc0          
0x2ADEA310C   mov      x21, x0              
0x2ADEA3110   mov      x0, x19              
0x2ADEA3114   mov      x2, x21              
0x2ADEA3118   bl       0x2b003f570          
0x2ADEA311C   mov      x0, x19              
0x2ADEA3120   bl       0x2b007a1c0          
0x2ADEA3124   mov      x0, x21              
0x2ADEA3128   bl       0x2b007a1c0          
0x2ADEA312C   ldr      x0, [x23, #0x1c8]    
0x2ADEA3130   bl       0x2b007a180          
0x2ADEA3134   mov.16b  v0, v10              
0x2ADEA3138   mov.16b  v1, v9               
0x2ADEA313C   bl       0x2b005ec50          
0x2ADEA3140   adrp     x8, 351              ; 0x2ae002000
0x2ADEA3144   add      x8, x8, #0x720       
0x2ADEA3148   sub      x22, x8, #0x20       
0x2ADEA314C   bl       0x2b007a1d0          
0x2ADEA3150   mov      x21, x0              
0x2ADEA3154   orr      x1, x22, #0x8000000000000000 
0x2ADEA3158   mov      x0, #0x11            
0x2ADEA315C   movk     x0, #0xd000, lsl #48 
0x2ADEA3160   bl       0x2b0079270          
0x2ADEA3164   mov      x22, x0              
0x2ADEA3168   mov      x0, x21              
0x2ADEA316C   mov      x2, x22              
0x2ADEA3170   bl       0x2b005fec0          
0x2ADEA3174   mov      x0, x21              
0x2ADEA3178   bl       0x2b007a1c0          
0x2ADEA317C   mov      x0, x22              
0x2ADEA3180   bl       0x2b007a1c0          
0x2ADEA3184   fcmp     d8, #0.0             
0x2ADEA3188   cset     w8, gt               
0x2ADEA318C   orr      w8, w20, w8          
0x2ADEA3190   tst      w8, #0x1             
0x2ADEA3194   fcsel    d11, d11, d12, ne    
0x2ADEA3198   mov      x0, x21              
0x2ADEA319C   bl       0x2b007a1d0          
0x2ADEA31A0   mov      x21, x0              
0x2ADEA31A4   mov.16b  v0, v11              
0x2ADEA31A8   bl       0x2b0093cc0          
0x2ADEA31AC   mov      x20, x0              
0x2ADEA31B0   mov      x0, x21              
0x2ADEA31B4   mov      x2, x20              
0x2ADEA31B8   bl       0x2b003f180          
0x2ADEA31BC   mov      x0, x20              
0x2ADEA31C0   bl       0x2b007a1c0          
0x2ADEA31C4   fmov     d0, #1.00000000      
0x2ADEA31C8   bl       0x2b0093cc0          
0x2ADEA31CC   mov      x20, x0              
0x2ADEA31D0   mov      x0, x21              
0x2ADEA31D4   mov      x2, x20              
0x2ADEA31D8   bl       0x2b003f570          
0x2ADEA31DC   mov      x0, x21              
0x2ADEA31E0   bl       0x2b007a1c0          
0x2ADEA31E4   mov      x0, x20              
0x2ADEA31E8   bl       0x2b007a1c0          
0x2ADEA31EC   ldr      x0, [x23, #0x1c8]    
0x2ADEA31F0   bl       0x2b007a180          
0x2ADEA31F4   mov.16b  v0, v10              
0x2ADEA31F8   mov.16b  v1, v9               
0x2ADEA31FC   bl       0x2b005ec50          
0x2ADEA3200   adrp     x8, 351              ; 0x2ae002000
0x2ADEA3204   add      x8, x8, #0x740       
0x2ADEA3208   sub      x22, x8, #0x20       
0x2ADEA320C   bl       0x2b007a1d0          
0x2ADEA3210   mov      x20, x0              
0x2ADEA3214   orr      x0, x24, #0x6        
0x2ADEA3218   orr      x1, x22, #0x8000000000000000 
0x2ADEA321C   bl       0x2b0079270          
0x2ADEA3220   mov      x22, x0              
0x2ADEA3224   mov      x0, x20              
0x2ADEA3228   mov      x2, x22              
0x2ADEA322C   bl       0x2b005fec0          
0x2ADEA3230   mov      x0, x20              
