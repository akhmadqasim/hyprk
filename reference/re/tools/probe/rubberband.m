#import <AppKit/AppKit.h>
#include <dlfcn.h>
#include <math.h>
typedef double (*F3)(double,double,double);
typedef double (*F0)(void);
int main(){ @autoreleasepool {
  void *h=dlopen("/System/Library/Frameworks/AppKit.framework/AppKit",RTLD_NOW);
  F3 t=(F3)dlsym(h,"_NSElasticDeltaForTimeDelta");
  const char *g[]={"NSScrollViewRubberbandStiffness","NSScrollViewRubberbandDirectionLockStretchRatio","NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch","NSScrollViewScrollVelocityMax","NSScrollingBehaviorMinAcceleratedStoppableVelocity"};
  for(int i=0;i<5;i++){F0 f=(F0)dlsym(h,g[i]); if(f) printf("%s = %g\n",g[i],f()); else printf("%s missing\n",g[i]);}
  double a=t(1,0,1), b=t(0,1,1), c=t(1,0,0.1), d=t(0,1,0.1);
  printf("t(1,0,1)=%.9g t(0,1,1)=%.9g t(1,0,.1)=%.9g t(0,1,.1)=%.9g\n",a,b,c,d);
  double C2=-20.0*0.1/log(c); printf("C2(from t=.1)=%.9g  C1=%.9g\n",C2, d/(0.1*c));
  for(double tt=0;tt<=0.6001;tt+=0.05) printf("t=%.2f decay(x0=100,v=0)=%.3f\n",tt,t(100,0,tt));
}}
