__NSElasticDeltaForReboundDelta:
0x18A64D7EC   pacibsp                       
0x18A64D7F0   stp      d9, d8, [sp, #-0x20]! 
0x18A64D7F4   stp      x29, x30, [sp, #0x10] 
0x18A64D7F8   add      x29, sp, #0x10       
0x18A64D7FC   mov.16b  v8, v0               
0x18A64D800   bl       _NSScrollViewRubberbandStiffness 
0x18A64D804   fmov     d1, #1.00000000      
0x18A64D808   fcmp     d0, d1               
0x18A64D80C   fcsel    d0, d1, d0, mi       
0x18A64D810   fdiv     d0, d8, d0           
0x18A64D814   ldp      x29, x30, [sp, #0x10] 
0x18A64D818   ldp      d9, d8, [sp], #0x20  
0x18A64D81C   retab                         
__NSReboundDeltaForElasticDelta:
0x18A64D1F8   pacibsp                       
0x18A64D1FC   stp      d9, d8, [sp, #-0x20]! 
0x18A64D200   stp      x29, x30, [sp, #0x10] 
0x18A64D204   add      x29, sp, #0x10       
0x18A64D208   mov.16b  v8, v0               
0x18A64D20C   bl       _NSScrollViewRubberbandStiffness 
0x18A64D210   fmul     d0, d8, d0           
0x18A64D214   ldp      x29, x30, [sp, #0x10] 
0x18A64D218   ldp      d9, d8, [sp], #0x20  
0x18A64D21C   retab                         
__NSElasticDeltaForTimeDelta2:
0x18AE6C204   pacibsp                       
0x18AE6C208   stp      d13, d12, [sp, #-0x40]! 
0x18AE6C20C   stp      d11, d10, [sp, #0x10] 
0x18AE6C210   stp      d9, d8, [sp, #0x20]  
0x18AE6C214   stp      x29, x30, [sp, #0x30] 
0x18AE6C218   add      x29, sp, #0x30       
0x18AE6C21C   mov.16b  v11, v3              
0x18AE6C220   mov.16b  v8, v2               
0x18AE6C224   mov.16b  v10, v1              
0x18AE6C228   mov.16b  v9, v0               
0x18AE6C22C   adrp     x2, 404072           ; 0x1ed8d4000
0x18AE6C230   add      x2, x2, #0x8c8       ; __MergedGlobals.36
0x18AE6C234   ldarb    w8, [x2]             
0x18AE6C238   cmp      w8, #0x1             
0x18AE6C23C   b.ne     0x18ae6c2c4          
0x18AE6C240   adrp     x8, 404072           ; 0x1ed8d4000
0x18AE6C244   add      x8, x8, #0x8d8       
0x18AE6C248   ldar     x8, [x8]             
0x18AE6C24C   fmov     d12, x8              
0x18AE6C250   adrp     x2, 404072           ; 0x1ed8d4000
0x18AE6C254   add      x2, x2, #0x8c9       
0x18AE6C258   ldarb    w8, [x2]             
0x18AE6C25C   cmp      w8, #0x1             
0x18AE6C260   b.ne     0x18ae6c2e8          
0x18AE6C264   adrp     x8, 404072           ; 0x1ed8d4000
0x18AE6C268   add      x8, x8, #0x8e0       
0x18AE6C26C   ldar     x8, [x8]             
0x18AE6C270   fmov     d0, x8               
0x18AE6C274   fnmul    d1, d8, d11          
0x18AE6C278   fdiv     d0, d1, d0           
0x18AE6C27C   bl       0x19010c630          
0x18AE6C280   mov.16b  v11, v0              
0x18AE6C284   bl       _NSScrollViewScrollVelocityMax 
0x18AE6C288   fcmp     d10, d0              
0x18AE6C28C   fcsel    d10, d10, d0, mi     
0x18AE6C290   bl       _NSScrollViewScrollVelocityMax 
0x18AE6C294   fneg     d1, d0               
0x18AE6C298   fneg     d2, d10              
0x18AE6C29C   fcmp     d10, d1              
0x18AE6C2A0   fcsel    d0, d0, d2, mi       
0x18AE6C2A4   fmul     d0, d8, d0           
0x18AE6C2A8   fmadd    d0, d0, d12, d9      
0x18AE6C2AC   fmul     d0, d11, d0          
0x18AE6C2B0   ldp      x29, x30, [sp, #0x30] 
0x18AE6C2B4   ldp      d9, d8, [sp, #0x20]  
0x18AE6C2B8   ldp      d11, d10, [sp, #0x10] 
0x18AE6C2BC   ldp      d13, d12, [sp], #0x40 
0x18AE6C2C0   retab                         
0x18AE6C2C4   adrp     x0, 359027           ; 0x1e28df000
0x18AE6C2C8   add      x0, x0, #0x380       
0x18AE6C2CC   adrp     x8, 2434             ; 0x18b7ee000
0x18AE6C2D0   ldr      d0, [x8, #0x738]     
0x18AE6C2D4   add      x1, x2, #0x10        
0x18AE6C2D8   mov      x3, #0x0             
0x18AE6C2DC   bl       __NSGetCGFloatAppConfig 
0x18AE6C2E0   mov.16b  v12, v0              
0x18AE6C2E4   b        0x18ae6c250          
0x18AE6C2E8   adrp     x0, 359027           ; 0x1e28df000
0x18AE6C2EC   add      x0, x0, #0x3a0       
0x18AE6C2F0   adrp     x8, 2433             ; 0x18b7ed000
0x18AE6C2F4   ldr      d0, [x8, #0x740]     
0x18AE6C2F8   add      x1, x2, #0x17        
0x18AE6C2FC   mov      x3, #0x0             
0x18AE6C300   bl       __NSGetCGFloatAppConfig 
0x18AE6C304   b        0x18ae6c274          
__NSHyperbolicElasticDeltaForReboundDelta:
0x18AE6C3B8   fcmp     d2, #0.0             
0x18AE6C3BC   b.ls     0x18ae6c3f0          
0x18AE6C3C0   fabs     d3, d0               
0x18AE6C3C4   fmul     d1, d3, d1           
0x18AE6C3C8   fdiv     d1, d1, d2           
0x18AE6C3CC   fmov     d3, #1.00000000      
0x18AE6C3D0   fadd     d1, d1, d3           
0x18AE6C3D4   fdiv     d1, d3, d1           
0x18AE6C3D8   fsub     d1, d3, d1           
0x18AE6C3DC   fneg     d3, d1               
0x18AE6C3E0   fcmp     d0, #0.0             
0x18AE6C3E4   fcsel    d0, d3, d1, mi       
0x18AE6C3E8   fmul     d0, d2, d0           
0x18AE6C3EC   ret                           
0x18AE6C3F0   fmov     d1, #20.00000000     
0x18AE6C3F4   fdiv     d0, d0, d1           
0x18AE6C3F8   ret                           
__NSHyperbolicReboundDeltaForElasticDelta:
0x18AE6C3FC   fcmp     d1, #0.0             
0x18AE6C400   b.ls     0x18ae6c450          
0x18AE6C404   fcmp     d2, #0.0             
0x18AE6C408   b.ls     0x18ae6c450          
0x18AE6C40C   fabs     d3, d0               
0x18AE6C410   fdiv     d3, d3, d2           
0x18AE6C414   fmov     d4, #1.00000000      
0x18AE6C418   fsub     d5, d4, d3           
0x18AE6C41C   fdiv     d5, d4, d5           
0x18AE6C420   fmov     d6, #-1.00000000     
0x18AE6C424   fadd     d5, d5, d6           
0x18AE6C428   fcmp     d3, d4               
0x18AE6C42C   adrp     x8, 2435             ; 0x18b7ef000
0x18AE6C430   ldr      d3, [x8, #0xa18]     
0x18AE6C434   fcsel    d3, d5, d3, lt       
0x18AE6C438   fneg     d4, d3               
0x18AE6C43C   fcmp     d0, #0.0             
0x18AE6C440   fcsel    d0, d4, d3, mi       
0x18AE6C444   fmul     d0, d2, d0           
0x18AE6C448   fdiv     d0, d0, d1           
0x18AE6C44C   ret                           
0x18AE6C450   fmov     d1, #20.00000000     
0x18AE6C454   fmul     d0, d0, d1           
0x18AE6C458   ret                           
_NSScrollViewRubberbandStiffness:
0x18B1D0FA4   adrp     x2, 403209           ; 0x1ed8d9000
0x18B1D0FA8   add      x2, x2, #0xe8a       
0x18B1D0FAC   ldarb    w8, [x2]             
0x18B1D0FB0   cmp      w8, #0x1             
0x18B1D0FB4   b.ne     0x18b1d0fcc          
0x18B1D0FB8   adrp     x8, 403209           ; 0x1ed8d9000
0x18B1D0FBC   add      x8, x8, #0xea8       
0x18B1D0FC0   ldar     x8, [x8]             
0x18B1D0FC4   fmov     d0, x8               
0x18B1D0FC8   ret                           
0x18B1D0FCC   adrp     x0, 358197           ; 0x1e2905000
0x18B1D0FD0   add      x0, x0, #0xc00       
0x18B1D0FD4   fmov     d0, #20.00000000     
0x18B1D0FD8   add      x1, x2, #0x1e        
0x18B1D0FDC   mov      x3, #0x0             
0x18B1D0FE0   b        __NSGetCGFloatAppConfig 
_NSScrollViewRubberbandDirectionLockStretchRatio:
0x18B1D0FE4   adrp     x2, 403209           ; 0x1ed8d9000
0x18B1D0FE8   add      x2, x2, #0xe8b       
0x18B1D0FEC   ldarb    w8, [x2]             
0x18B1D0FF0   cmp      w8, #0x1             
0x18B1D0FF4   b.ne     0x18b1d100c          
0x18B1D0FF8   adrp     x8, 403209           ; 0x1ed8d9000
0x18B1D0FFC   add      x8, x8, #0xeb0       
0x18B1D1000   ldar     x8, [x8]             
0x18B1D1004   fmov     d0, x8               
0x18B1D1008   ret                           
0x18B1D100C   adrp     x0, 358196           ; 0x1e2905000
0x18B1D1010   add      x0, x0, #0xc20       
0x18B1D1014   fmov     d0, #1.00000000      
0x18B1D1018   add      x1, x2, #0x25        
0x18B1D101C   mov      x3, #0x0             
0x18B1D1020   b        __NSGetCGFloatAppConfig 
_NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch:
0x18B1D1024   adrp     x2, 403208           ; 0x1ed8d9000
0x18B1D1028   add      x2, x2, #0xe8c       
0x18B1D102C   ldarb    w8, [x2]             
0x18B1D1030   cmp      w8, #0x1             
0x18B1D1034   b.ne     0x18b1d104c          
0x18B1D1038   adrp     x8, 403208           ; 0x1ed8d9000
0x18B1D103C   add      x8, x8, #0xeb8       
0x18B1D1040   ldar     x8, [x8]             
0x18B1D1044   fmov     d0, x8               
0x18B1D1048   ret                           
0x18B1D104C   adrp     x0, 358196           ; 0x1e2905000
0x18B1D1050   add      x0, x0, #0xc40       
0x18B1D1054   fmov     d0, #10.00000000     
0x18B1D1058   add      x1, x2, #0x2c        
0x18B1D105C   mov      x3, #0x0             
0x18B1D1060   b        __NSGetCGFloatAppConfig 
