; DesignLibrary.framework 27.2.1 (26B131) arm64e, dyld cache addresses, dyld_info -disassemble.
; Mac switch track+labels view body (type string at 0x195f9cd08: ModifiedContent<MacControlFill<Capsule>, _OverlayModifier<MacSwitchOffLabel/MacSwitchOnLabel/MacSwitchMixedLabel ...>, ClampedTintLuminosityModifier>)
; fn 0x195E349C4: .animation(.spring(response: 0.47, dampingFraction: 0.7, blendDuration: 0), value: ControlStateValue)  then  .animation(.easeInOut(duration: 0.2), value: InteractionState)
; stub 0x198123010 -> SwiftUICore 0x190ee11b8 Animation.spring(response:dampingFraction:blendDuration:); 0x198121740 -> View.animation(_:value:); 0x198123040 -> Animation.easeInOut(duration:)
0x195E34E28   bl       0x198122fe0          
0x195E34E2C   adrp     x16, 3               ; 0x195e37000
0x195E34E30   add      x16, x16, #0x7bc     
0x195E34E34   mov      x17, #0x720f         
0x195E34E38   pacia    x16, x17             
0x195E34E3C   mov      x2, x16              
0x195E34E40   sub      x3, x29, #0xf0       
0x195E34E44   mov      x8, x20              
0x195E34E48   mov      x4, x26              
0x195E34E4C   mov      x5, x19              
0x195E34E50   bl       0x198121ce0          
0x195E34E54   mov      x8, #0xae14          
0x195E34E58   movk     x8, #0xe147, lsl #16 
0x195E34E5C   movk     x8, #0x147a, lsl #32 
0x195E34E60   movk     x8, #0x3fde, lsl #48 
0x195E34E64   fmov     d0, x8               
0x195E34E68   mov      x8, #0x6666666666666666 
0x195E34E6C   movk     x8, #0x3fe6, lsl #48 
0x195E34E70   fmov     d1, x8               
0x195E34E74   movi.2d  v2, #0000000000000000 
0x195E34E78   bl       0x198123010          
0x195E34E7C   mov      x19, x0              
0x195E34E80   sub      x8, x29, #0x40       
0x195E34E84   ldur     x25, [x8, #-0x100]   
0x195E34E88   ldrsw    x26, [x25, #0x24]    
0x195E34E8C   mov      x0, x22              
0x195E34E90   mov      x1, x24              
0x195E34E94   bl       0x198104eb0          
0x195E34E98   mov      x22, x0              
0x195E34E9C   bl       0x195e377c8          
0x195E34EA0   mov      x5, x0               
0x195E34EA4   adrp     x3, 319716           ; 0x1e3f18000
0x195E34EA8   add      x3, x3, #0xee0       ; _$s13DesignLibrary17ControlStateValueON
0x195E34EAC   add      x1, x27, x26         
0x195E34EB0   mov      x26, x27             
0x195E34EB4   mov      x8, x23              
0x195E34EB8   mov      x0, x19              
0x195E34EBC   mov      x2, x24              
0x195E34EC0   mov      x4, x22              
0x195E34EC4   bl       0x198121740          
0x195E34EC8   mov      x0, x19              
0x195E34ECC   bl       0x198105020          
0x195E34ED0   ldr      x8, [x21, #0x8]!     
0x195E34ED4   mov      x0, x20              
0x195E34ED8   mov      x1, x24              
0x195E34EDC   mov      x17, x21             
0x195E34EE0   movk     x17, #0x4f8, lsl #48 
0x195E34EE4   blraa    x8, x17              
0x195E34EE8   ldrsw    x8, [x25, #0x38]     
0x195E34EEC   add      x8, x27, x8          
0x195E34EF0   ldr      x0, [x8]             
0x195E34EF4   ldrb     w1, [x8, #0x8]       
0x195E34EF8   bl       0x195db86fc          
0x195E34EFC   mov      x24, #0x0            
0x195E34F00   tbnz     w0, #0x0, 0x195e34f1c 
0x195E34F04   mov      x8, #-0x6666666666666667 
0x195E34F08   movk     x8, #0x999a          
0x195E34F0C   movk     x8, #0x3fc9, lsl #48 
0x195E34F10   fmov     d0, x8               
0x195E34F14   bl       0x198123040          
0x195E34F18   mov      x24, x0              
0x195E34F1C   ldrsw    x20, [x25, #0x28]    
0x195E34F20   adrp     x0, 359427           ; 0x1eda37000
0x195E34F24   add      x0, x0, #0x9a0       
0x195E34F28   adrp     x1, 359427           ; 0x1eda37000
0x195E34F2C   add      x1, x1, #0x6e0       
0x195E34F30   adrp     x2, 360              ; 0x195f9c000
0x195E34F34   add      x2, x2, #0xd30       
0x195E34F38   adrp     x16, 303948          ; 0x1e0180000
0x195E34F3C   ldr      x16, [x16, #0x498]   
0x195E34F40   mov      x17, #0xc6eb         
0x195E34F44   pacda    x16, x17             
0x195E34F48   mov      x19, x16             
0x195E34F4C   mov      x3, x16              
0x195E34F50   bl       0x195da23bc          
0x195E34F54   stp      x22, x0, [x29, #-0x100] 
0x195E34F58   adrp     x16, 303947          ; 0x1e017f000
0x195E34F5C   ldr      x16, [x16, #0x80]    
0x195E34F60   mov      x17, #0xc6eb         
0x195E34F64   pacda    x16, x17             
0x195E34F68   mov      x21, x16             
0x195E34F6C   sub      x2, x29, #0x100      
0x195E34F70   mov      x0, x16              
0x195E34F74   mov      x1, x28              
0x195E34F78   bl       0x198104eb0          
0x195E34F7C   mov      x22, x0              
0x195E34F80   bl       0x195e341f8          
0x195E34F84   mov      x5, x0               
0x195E34F88   adrp     x3, 319717           ; 0x1e3f19000
0x195E34F8C   add      x3, x3, #0x250       ; _$s13DesignLibrary16InteractionStateON
0x195E34F90   add      x1, x26, x20         
0x195E34F94   sub      x8, x29, #0x58       
0x195E34F98   ldur     x27, [x8, #-0x100]   
0x195E34F9C   mov      x8, x27              
0x195E34FA0   mov      x0, x24              
0x195E34FA4   mov      x2, x28              
0x195E34FA8   mov      x4, x22              
0x195E34FAC   mov      x20, x23             
0x195E34FB0   bl       0x198121740          
0x195E34FB4   mov      x0, x24              
0x195E34FB8   bl       0x198105020          

; other spring site (not the Mac switch; view with Binding<Bool>): spring(response: flag ? 0.23 : 0.46, dampingFraction: 0.75)
0x195DF57B8   cmp      w20, #0x0            
0x195DF57BC   mov      x8, #0x3d71          
0x195DF57C0   movk     x8, #0xd70a, lsl #16 
0x195DF57C4   movk     x8, #0x70a3, lsl #32 
0x195DF57C8   movk     x8, #0x3fdd, lsl #48 
0x195DF57CC   fmov     d0, x8               
0x195DF57D0   mov      x8, #0x3d71          
0x195DF57D4   movk     x8, #0xd70a, lsl #16 
0x195DF57D8   movk     x8, #0x70a3, lsl #32 
0x195DF57DC   movk     x8, #0x3fcd, lsl #48 
0x195DF57E0   fmov     d1, x8               
0x195DF57E4   fcsel    d0, d1, d0, ne       
0x195DF57E8   fmov     d1, #0.75000000      
0x195DF57EC   movi.2d  v2, #0000000000000000 
0x195DF57F0   bl       0x198123010          
0x195DF57F4   mov      x21, x0              
