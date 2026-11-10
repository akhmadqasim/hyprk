// Notification Center panel spring: why code says ratio 1.25 and the screen shows 1.0.
// macOS 27.2.1 (26B131), arm64e. Tools: REA (Ghidra 12.1.4 provider) on the NotificationCenter arm64e slice and on
// raw dumps of SwiftUICore code read from the dyld shared cache; dyld_info -disassemble for the asm excerpts.
// SwiftUICore addresses are unslid cache addresses (image base 0x190404000 + export offset).

//==== NotificationCenter 0x1001910a4: static init of the panel animation DAT_1003c1388
//   d0 = 0.3 (@0x1002dbd50), d1 = -0.2 (@0x1002dbd58), d2 = 0
void FUN_1001910d8(double duration,double bounce,double initialVelocity)   // REA pseudocode, names added
{
  double stiffness = duration <= 0 ? INFINITY : (6.283185307179586/duration)*(6.283185307179586/duration);
  double ratio;                                   // inlined SwiftUI Spring(duration:bounce:) -> dampingRatio
  if (bounce <= -1.0)      ratio = INFINITY;
  else if (bounce < 0.0)   ratio = 1.0/(bounce + 1.0);        // -0.2 -> 1.25
  else if (bounce == 0.0)  ratio = 1.0;
  else                     ratio = 1.0 - min(bounce,1.0);
  SwiftUI::Animation::interpolatingSpring(/*mass*/1.0, stiffness /*438.649*/,
                                          (sqrt(stiffness)+sqrt(stiffness))*ratio /*52.360*/, initialVelocity);
}

//==== NotificationCenter 0x100190fe0: static init of DAT_1003c13b8 (the OTHER "0.3 / 1.25" spring)
//   100190fe4 ldr d0,[0x1002dbd50] (0.3) ; fmov d1,#1.25 ; movi d2,#0
//   100190ff0 bl  SwiftUI.Animation.spring(response:dampingFraction:blendDuration:)   -> FluidSpringAnimation

//==== SwiftUICore 0x190d2440c  static Animation.interpolatingSpring(mass:stiffness:damping:initialVelocity:)
//   boxes SpringAnimation { mass @+0x10, stiffness @+0x18, damping @+0x20, initialVelocity @+0x28,
//                           timingCurve @+0x30..0x4f = 0, @+0x50 = 1 (nil) }

//==== SwiftUICore 0x190d236ec  SpringAnimation.animate(value:time:context:)  (generic; Double path 0x190d234ac and
//     AnimatablePair<CGFloat,..> path 0x190d23240 build the same model)
//   self = x20: [0]=mass [1]=stiffness [2]=damping [3]=initialVelocity
  w0    = SQRT(stiffness / mass);                         // local_d0  SpringModel.angularFrequency
  zeta  = damping / (SQRT(mass*stiffness) + SQRT(mass*stiffness));   // dStack_c8
  if (1.0 <= zeta) {                                      // <-- every ratio >= 1 takes the critical form
    B  = w0 - initialVelocity;                            // local_b0
    wd = 0.0;                                             // local_c0
  } else {
    wd = w0 * SQRT(1.0 - zeta*zeta);
    B  = (w0*zeta - initialVelocity) / wd;
  }
  A = 1.0;                                                // local_b8
  duration = cached ?? SpringModel.duration(epsilon: timingCurve == nil ? 0.001 : 1e-6);   // 0x190d23bf0
  if (duration <= time) return nil;                       // finished
  x = SpringModel.sample(at: time);                       // 0x190d23e28
  if (time >= 6.283185307179586 / SQRT(stiffness)) context.isLogicallyComplete = 1;   // *(ctx+0x19) = 1
  return value * x;

//==== SwiftUICore 0x190d23e28  SpringModel.sample(at:)   model = x20: [0]=w0 [1]=zeta [2]=wd [3]=A [4]=B
double FUN_190d23e28(double t)
{
  double r;
  if (1.0 <= model[1]) {
    r = (model[3] + t*model[4]) * exp(-(t*model[0]));     // (A + B t) e^(-w0 t): zeta itself is NOT used
  } else {
    double zw = model[1]*model[0];
    r = exp(-(t*zw)) * (model[3]*cos(t*model[2]) + sin(t*model[2])*model[4]);
  }
  return 1.0 - r;
}

//==== SwiftUICore 0x190d23bf0  SpringModel.duration(epsilon:)   (zeta >= 1 branch)
//   t = 0, 0.1, 0.2, ... (max 1023 steps); returns the first t at which |1 - sample(t)| < epsilon and stays below it
//   for more than 1 s.  w0 = 20.944, epsilon 0.001: |err| = 2.2e-3 at 0.4 s, 3.2e-4 at 0.5 s  ->  duration 0.5 s.
//   (zeta < 1 branch: -ln(epsilon/(|A|+|B|)) / (zeta*w0).)

//==== SwiftUICore 0x190edef7c  Animation.spring(response:dampingFraction:blendDuration:)  (merged with interactiveSpring)
//   boxes FluidSpringAnimation { response @+0x10, dampingFraction @+0x18, blendDuration @+0x20 }
//==== SwiftUICore 0x190c23768  FluidSpringAnimation.animate<Double>  -- numeric integration, ratio not clamped
// _$s7SwiftUI20FluidSpringAnimationV7animate5value4time7contextxSgx_SdAA0E7ContextVyxGztAA16VectorArithmeticRzlFSd_Tg5:
// 0x190C23A54   fcmp     d1, #0.0             
// 0x190C23A58   b.ls     0x190c23acc          
// 0x190C23A5C   mov      x8, #0x2d18          
// 0x190C23A60   movk     x8, #0x5444, lsl #16 
// 0x190C23A64   movk     x8, #0x21fb, lsl #32 
// 0x190C23A68   movk     x8, #0x4019, lsl #48 
// 0x190C23A6C   fmov     d2, x8               
// 0x190C23A70   fdiv     d2, d2, d1           
// 0x190C23A74   fmul     d2, d2, d2           
// 0x190C23A78   b        0x190c23ad4          
// 0x190C23A7C   ldur     d3, [x29, #-0x98]    
// 0x190C23A80   fadd     d3, d12, d3          
// 0x190C23A84   fsub     d3, d11, d3          
// 0x190C23A88   fdiv     d3, d3, d13          
// 0x190C23A8C   fmov     d4, #1.00000000      
// 0x190C23A90   fcmp     d3, d4               
// 0x190C23A94   fcsel    d5, d4, d3, gt       
// 0x190C23A98   fcmp     d3, #0.0             
// 0x190C23A9C   movi.2d  v3, #0000000000000000 
// 0x190C23AA0   fcsel    d3, d5, d3, ge       
// 0x190C23AA4   fmul     d5, d3, d3           
// 0x190C23AA8   fadd     d3, d3, d3           
// 0x190C23AAC   fmov     d6, #3.00000000      
// 0x190C23AB0   fsub     d3, d6, d3           
// 0x190C23AB4   fmul     d3, d5, d3           
// 0x190C23AB8   fsub     d3, d4, d3           
// 0x190C23ABC   fmul     d2, d2, d3           
// 0x190C23AC0   fadd     d1, d1, d2           
// 0x190C23AC4   fcmp     d1, #0.0             
// 0x190C23AC8   b.hi     0x190c23a5c          
// 0x190C23ACC   mov      x8, #0x7ff0000000000000 
// 0x190C23AD0   fmov     d2, x8               
// 0x190C23AD4   mov      x8, #-0x70000000001  
// 0x190C23AD8   movk     x8, #0x40e5, lsl #48 
// 0x190C23ADC   fmov     d3, x8               
// 0x190C23AE0   fcmp     d2, d3               
// 0x190C23AE4   fcsel    d2, d3, d2, gt       
//    ...
// 0x190C23AE8   ldur     d3, [x29, #-0xa0]    
// 0x190C23AEC   fadd     d3, d12, d3          
// 0x190C23AF0   fsub     d3, d11, d3          
// 0x190C23AF4   ldur     x8, [x29, #-0x88]    
// 0x190C23AF8   fcmp     d1, d3               
// 0x190C23AFC   ccmp     x8, #0x0, #0x0, ls   
// 0x190C23B00   b.ne     0x190c23b0c          
// 0x190C23B04   mov      w8, #0x1             
// 0x190C23B08   strb     w8, [x22, #0x19]     
// 0x190C23B0C   ldur     d1, [x29, #-0xa8]    
// 0x190C23B10   fsub     d3, d11, d1          
// 0x190C23B14   fmov     d4, #1.00000000      
// 0x190C23B18   fcmp     d3, d4               
// 0x190C23B1C   b.le     0x190c23b34          
// 0x190C23B20   mov      x8, #0x1111111111111111 
// 0x190C23B24   movk     x8, #0xbf91, lsl #48 
// 0x190C23B28   fmov     d1, x8               
// 0x190C23B2C   fadd     d1, d11, d1          
// 0x190C23B30   stur     d1, [x29, #-0xa8]    
// 0x190C23B34   fcmp     d1, d11              
// 0x190C23B38   b.pl     0x190c23bb4          
// 0x190C23B3C   fsqrt    d3, d2               
// 0x190C23B40   fadd     d3, d3, d3           
// 0x190C23B44   fnmul    d3, d0, d3           
// 0x190C23B48   ldp      d7, d4, [x29, #-0xb8] 
// 0x190C23B4C   ldur     d0, [x29, #-0xc0]    
// 0x190C23B50   mov      x8, #0x1b4f          
// 0x190C23B54   movk     x8, #0xb4e8, lsl #16 
// 0x190C23B58   movk     x8, #0x4e81, lsl #32 
// 0x190C23B5C   movk     x8, #0x3f5b, lsl #48 
// 0x190C23B60   fmov     d5, x8               
// 0x190C23B64   mov      x8, #0x1b4f          
// 0x190C23B68   movk     x8, #0xb4e8, lsl #16 
// 0x190C23B6C   movk     x8, #0x4e81, lsl #32 
// 0x190C23B70   movk     x8, #0x3f6b, lsl #48 
// 0x190C23B74   fmov     d6, x8               
// 0x190C23B78   fmul     d4, d4, d5           
// 0x190C23B7C   fadd     d7, d4, d7           
// 0x190C23B80   fmul     d4, d7, d6           
// 0x190C23B84   fadd     d0, d0, d4           
// 0x190C23B88   fmul     d4, d3, d7           
// 0x190C23B8C   fsub     d16, d8, d0          
// 0x190C23B90   fmul     d16, d2, d16         
// 0x190C23B94   fadd     d4, d4, d16          
// 0x190C23B98   fmul     d16, d4, d5          
// 0x190C23B9C   fadd     d7, d7, d16          
// 0x190C23BA0   fadd     d1, d1, d6           
// 0x190C23BA4   fcmp     d1, d11              
// 0x190C23BA8   b.mi     0x190c23b78          
//   In words (d1 = response, d0 = dampingFraction, d8 = target, d11 = time):
//     k = (2*pi/response)^2, capped at 45000;  c = 2*sqrt(k)*dampingFraction        // no min(ratio,1)
//     if (response <= time - start) context.isLogicallyComplete = 1
//     loop with h = 1/300 s:  v += a*h/2;  x += v*h;  a = -c*v + k*(target - x);  v += a*h/2;  t += h
//   So dampingFraction 1.25 stays overdamped here (banners, list reflow), unlike SpringAnimation above.

//==== NotificationCenter 0x100176de0 MainController open (from "Center open requested"), order of events
//   FUN_1001d3768(animated)            // model: isAnimating = 1, signpost begin
//   [window makeKeyAndOrderFront:]     // window is ordered front BEFORE the animation is started
//   if (oldDisplay == newDisplay)  FUN_1001d39d8: DispatchQueue.main.async { FUN_1001e18b0 -> withAnimation(DAT_1003c1388, .logicallyComplete) }
//   else                           DispatchQueue.main.async { FUN_1001771f4 }
//   No asyncAfter / DispatchTime in this path. asyncAfter exists at 3 sites only: 0x1001926a0 (0.2 s, widget
//   configuration, func 0x1001911fc), 0x1001956a4 (func 0x100194f50) and 0x10029fea0 (generic helper 0x10029fbe4).
