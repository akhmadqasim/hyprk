// scrollerknob.m: offscreen (no window, no NSApp run loop) check of the scroller knob while the clip view is overscrolled.
// Build: clang -fobjc-arc -framework AppKit -o scrollerknob scrollerknob.m ; run: ./scrollerknob [overlay|legacy]
#import <AppKit/AppKit.h>
#import <objc/message.h>
@interface FlipDoc : NSView @end
@implementation FlipDoc - (BOOL)isFlipped { return YES; } @end
int main(int argc,char**argv){ @autoreleasepool{
  BOOL legacy = argc>1 && !strcmp(argv[1],"legacy");
  NSScrollView*sv=[[NSScrollView alloc] initWithFrame:NSMakeRect(0,0,400,600)];
  sv.hasVerticalScroller=YES; sv.scrollerStyle=legacy?NSScrollerStyleLegacy:NSScrollerStyleOverlay;
  sv.verticalScrollElasticity=NSScrollElasticityAllowed;
  sv.documentView=[[FlipDoc alloc] initWithFrame:NSMakeRect(0,0,400,3000)];
  NSClipView*cv=sv.contentView; NSScroller*sc=sv.verticalScroller;
  id imp=((id(*)(id,SEL))objc_msgSend)(sc,sel_registerName("scrollerImp"));
  printf("style=%s scroller frame=%s imp=%s clip=%s knobMinLength=%g trackEndInset=%g knobEndInset=%g\n",legacy?"legacy":"overlay",NSStringFromRect(sc.frame).UTF8String,object_getClassName(imp),NSStringFromRect(cv.bounds).UTF8String,
    ((double(*)(id,SEL))objc_msgSend)(imp,sel_registerName("knobMinLength")),((double(*)(id,SEL))objc_msgSend)(imp,sel_registerName("trackEndInset")),((double(*)(id,SEL))objc_msgSend)(imp,sel_registerName("knobEndInset")));
  double ys[]={0,-10,-35,-100,-300,-590,-700,1200,2400,2435,2500,2700,-1e9};
  for(int i=0;ys[i]>-1e8;i++){
    ((void(*)(id,SEL,BOOL))objc_msgSend)(cv,sel_registerName("_setDontConstrainScroll:"),YES);
    [cv setBoundsOrigin:NSMakePoint(0,ys[i])];
    [sv reflectScrolledClipView:cv];
    ((void(*)(id,SEL,BOOL))objc_msgSend)(cv,sel_registerName("_setDontConstrainScroll:"),NO);
    CGPoint st=((CGPoint(*)(id,SEL))objc_msgSend)(sv,sel_registerName("_stretchAmount"));
    NSRect k=[sc rectForPart:NSScrollerKnob], slot=[sc rectForPart:NSScrollerKnobSlot];
    double H=cv.bounds.size.height, model=fmax(H-fabs(st.y),0)/3000.0;
    printf("clipY=%7.1f stretch.y=%7.1f value=%.5f knobProportion=%.6f model=%.6f knobRect y=%.2f h=%.2f slot h=%.2f\n",cv.bounds.origin.y,st.y,sc.doubleValue,sc.knobProportion,model,k.origin.y,k.size.height,slot.size.height); }
} return 0; }
