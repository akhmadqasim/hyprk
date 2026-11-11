// momentum.m: offscreen probe of AppKit's private scroll-momentum calculators (macOS 27.2.1).
// Build: clang -fobjc-arc -framework AppKit -o momentum momentum.m
// arm64 (not arm64e) build so raw function addresses can be called.
// Usage: ./momentum info | stub <hexaddr>... | rubber <coef> <clip_h> <step> <n> | class <name>... | keys <hexaddr>... | lits <hexaddr>... | cfg | sample <class> vx vy [decel] [doc_h clip_h y0]
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>
static void*H(void){ static void*h; if(!h) h=dlopen("/System/Library/Frameworks/AppKit.framework/AppKit",RTLD_NOW); return h; }
static intptr_t slide(void){ // anchor: exported __NSHyperbolicElasticDeltaForReboundDelta, static address 0x18AE6C3B8 in AppKit 27.2.1
  void *p=dlsym(H(),"_NSHyperbolicElasticDeltaForReboundDelta"); if(!p){fprintf(stderr,"anchor missing\n");exit(2);}
  return (intptr_t)((uintptr_t)p & 0x0000007fffffffffULL) - (intptr_t)0x18AE6C3B8; }
static void dumpClass(const char*n){ Class c=objc_getClass(n); if(!c){printf("no class %s\n",n);return;}
  printf("== %s : %s size %zu\n",n,class_getName(class_getSuperclass(c)),class_getInstanceSize(c));
  unsigned k; Ivar*iv=class_copyIvarList(c,&k); for(unsigned i=0;i<k;i++) printf("  ivar +%#tx %s %s\n",ivar_getOffset(iv[i]),ivar_getName(iv[i]),ivar_getTypeEncoding(iv[i])?:"");
  Method*m=class_copyMethodList(c,&k); for(unsigned i=0;i<k;i++) printf("  - %s  %s\n",sel_getName(method_getName(m[i])),method_getTypeEncoding(m[i]));
  m=class_copyMethodList(object_getClass(c),&k); for(unsigned i=0;i<k;i++) printf("  + %s  %s\n",sel_getName(method_getName(m[i])),method_getTypeEncoding(m[i])); }
int main(int argc,char**argv){ @autoreleasepool{
  if(argc<2) return 1; NSString*cmd=@(argv[1]);
  if([cmd isEqual:@"info"]){
    id a=[objc_getClass("_NSScrollingMomentumCalculator") alloc]; printf("default alloc class: %s\n",object_getClassName(a));
    dumpClass("_NSScrollingMomentumCalculator");dumpClass("_NSScrollingMomentumCatesCalculator");dumpClass("_NSScrollingMomentumBasCalculator");
  } else if([cmd isEqual:@"class"]){ for(int i=2;i<argc;i++) dumpClass(argv[i]);
  } else if([cmd isEqual:@"rubber"]){ // rubber <coef> <clip_h> <step> <n> : overscroll past the top edge in n steps of <step> pt
    double c=atof(argv[2]), H=atof(argv[3]), st=atof(argv[4]); int n=atoi(argv[5]);
    id f=((id(*)(id,SEL,CGRect,CGPoint,CGSize,BOOL,double))objc_msgSend)([objc_getClass("_NSScrollingRubberbandFilter") alloc],sel_registerName("initWithDocumentFrame:constrainedClippingOrigin:clippingSize:isFlipped:pointsPerPixel:"),CGRectMake(0,0,800,5000),CGPointMake(0,0),CGSizeMake(800,H),YES,0.5);
    printf("defaults: hyperbolicCoefficient=%g dynamicDampeningThreshold=%g\n",((double(*)(id,SEL))objc_msgSend)(f,sel_registerName("hyperbolicCoefficient")),((double(*)(id,SEL))objc_msgSend)(f,sel_registerName("dynamicDampeningThreshold")));
    if(c>=0) ((void(*)(id,SEL,double))objc_msgSend)(f,sel_registerName("setHyperbolicCoefficient:"),c);
    double sum=0, pos=0;
    for(int i=1;i<=n;i++){ ((void(*)(id,SEL,CGPoint,CGPoint))objc_msgSend)(f,sel_registerName("addDelta:velocity:"),CGPointMake(0,st),CGPointMake(0,st*60));
      CGPoint fd=((CGPoint(*)(id,SEL))objc_msgSend)(f,sel_registerName("filteredDelta"));
      CGPoint sp=((CGPoint(*)(id,SEL))objc_msgSend)(f,sel_registerName("scrollPosition"));
      BOOL stz=((BOOL(*)(id,SEL))objc_msgSend)(f,sel_registerName("isStretched")); sum+=st; pos+=fd.y;
      // the caller normally moves the clip origin by filteredDelta: feed it back
      ((void(*)(id,SEL,CGPoint))objc_msgSend)(f,sel_registerName("setConstrainedClippingOrigin:"),CGPointMake(0,0));
      double model=c>0? H*(1-1/(1+fabs(sum)*c/H)) : fabs(sum)/20;
      if(i<=3||i%(n/10>0?n/10:1)==0) printf("finger=%8.2f filteredDelta.y=%9.4f cumulative=%9.4f scrollPos.y=%9.4f stretched=%d model=%9.4f\n",sum,fd.y,pos,sp.y,stz,model); }
  } else if([cmd isEqual:@"stub"]){ // decode objc_msgSend selector stubs: adrp x1,page ; ldr/add x1 -> selector name
    intptr_t s=slide();
    for(int i=2;i<argc;i++){ uintptr_t a=strtoull(argv[i],0,16); uint32_t*c=(uint32_t*)(a+s); uint32_t i0=c[0],i1=c[1];
      if((i0&0x9f00001f)==0x90000001){ int64_t imm=((int64_t)((i0>>5)&0x7ffff)<<2)|((i0>>29)&3); if(imm&(1<<20)) imm-=(1<<21);
        uintptr_t page=(((uintptr_t)c)&~0xfffULL)+(imm<<12); const char*n=0;
        if((i1&0xffc003ff)==0xf9400021) n=*(const char**)(page+(((i1>>10)&0xfff)<<3));
        else if((i1&0xffc003ff)==0x91000021) n=(const char*)(page+((i1>>10)&0xfff));
        printf("%#lx\t%s\n",a,n?(const char*)((uintptr_t)n&0x7fffffffffULL):"?"); }
      else { Dl_info di; if(dladdr((void*)c,&di)&&di.dli_sname) printf("%#lx\t[%s+%#lx]\n",a,di.dli_sname,(uintptr_t)c-(uintptr_t)di.dli_saddr); else printf("%#lx\t? %08x %08x\n",a,i0,i1);} }
  } else if([cmd isEqual:@"keys"]){ intptr_t s=slide(); printf("slide %#tx\n",s);
    for(int i=2;i<argc;i++){ uintptr_t a=strtoull(argv[i],0,16); CFStringRef str=(CFStringRef)(a+s); printf("%#lx\t%s\n",a,[(__bridge NSString*)str UTF8String]); }
  } else if([cmd isEqual:@"lits"]){ intptr_t s=slide();
    for(int i=2;i<argc;i++){ uintptr_t a=strtoull(argv[i],0,16); printf("%#lx\t%.17g\n",a,*(double*)(a+s)); }
  } else if([cmd isEqual:@"cfg"]){
    // non-exported config getters, called by static address + slide (27.2.1 only)
    struct{const char*n;uintptr_t a;} fn[]={{"NSScrollViewScrollVelocityMax",0x18B1D0F60},{"NSScrollViewScrollVelocityZeroingTimeout",0x18B1D0F1C},{"NSScrollViewRubberbandStiffness",0x18B1D0FA4},{"NSScrollViewRubberbandDirectionLockStretchRatio",0x18B1D0FE4},{"NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch",0x18B1D1024},{"NSScrollingBehaviorMinAcceleratedStoppableVelocity",0x18B1D1064},{"NSScrollingVFDReducedFPS",0x18B1D10A8},{"NSScrollingVFDVelocityThreshold",0x18B1D10EC},{"NSScrollingTouchMomentumMinimumSpeed",0x18B1D11A0},{0,0}};
    intptr_t s=slide(); for(int i=0;fn[i].n;i++){ double(*f)(void)=(void*)(fn[i].a+s); printf("%s() = %.17g\n",fn[i].n,f()); }
  } else if([cmd isEqual:@"sample"]){
    Class c=objc_getClass(argv[2]); double vx=atof(argv[3]),vy=atof(argv[4]); double decel=argc>5?atof(argv[5]):0;
    double doch=argc>6?atof(argv[6]):1e6, cliph=argc>7?atof(argv[7]):600, y0=argc>8?atof(argv[8]):5e5;
    SEL s=sel_registerName("initWithInitialOrigin:initialVelocity:documentFrame:constrainedClippingOrigin:clippingSize:tolerance:decelerationRate:shouldRoundCalculations:");
    id o=((id(*)(id,SEL,CGPoint,CGPoint,CGRect,CGPoint,CGSize,CGSize,double,BOOL))objc_msgSend)([c alloc],s,CGPointMake(0,y0),CGPointMake(vx,vy),CGRectMake(0,0,800,doch),CGPointMake(0,y0),CGSizeMake(800,cliph),CGSizeMake(1,1),decel,NO);
    printf("class %s v=(%g,%g) decelArg=%g doc_h=%g clip_h=%g y0=%g\n",object_getClassName(o),vx,vy,decel,doch,cliph,y0);
    if([o respondsToSelector:sel_registerName("calculateDestination")]) ((void(*)(id,SEL))objc_msgSend)(o,sel_registerName("calculateDestination"));
    CGPoint d=((CGPoint(*)(id,SEL))objc_msgSend)(o,sel_registerName("destinationOrigin"));
    double dur=((double(*)(id,SEL))objc_msgSend)(o,sel_registerName("durationUntilStop"));
    double dr=((double(*)(id,SEL))objc_msgSend)(o,sel_registerName("decelerationRate"));
    printf("destination=(%.6f,%.6f) travel_y=%.6f durationUntilStop=%.6f decelerationRate=%.9g\n",d.x,d.y,d.y-y0,dur,dr);
    double ts[400]; int n=0; if(getenv("FINE")){ double st=atof(getenv("FINE")); for(double t=0;t<=dur+st&&n<399;t+=st) ts[n++]=t; } else { double b[]={0,0.008333,0.016667,0.05,0.1,0.2,0.3,0.5,0.75,1,1.5,2,3,4,6}; for(int i=0;i<15;i++) ts[n++]=b[i]; } ts[n]=-1;
    for(int i=0;ts[i]>=0;i++){ double t=ts[i];
      CGPoint p=((CGPoint(*)(id,SEL,double))objc_msgSend)(o,sel_registerName("positionAfterDuration:"),t);
      double v=((double(*)(id,SEL,double))objc_msgSend)(o,sel_registerName("velocityAfterDuration:"),t);
      BOOL rb=((BOOL(*)(id,SEL,double))objc_msgSend)(o,sel_registerName("isRubberBandingAfterDuration:"),t);
      printf("t=%.6f dx=%.6f dy=%.6f speed=%.6f rubber=%d\n",t,p.x,p.y-y0,v,rb); }
  }
} return 0; }
