// glasspost: post the WindowServer coordinated notification that System Settings posts after writing NSGlassTintAmount
// (same call as AppKit 0x18b4c4f80: SLSPostCoordinatedDistributedNotificationFenced(cid, 12, fencePort, block, 0.5)).
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#include <mach/mach.h>
extern int SLSMainConnectionID(void);
extern void SLSPostCoordinatedDistributedNotificationFenced(int cid, int type, mach_port_t fence, void (^completion)(void), double timeout);
extern void mach_right_send_release(mach_port_t);
@interface CAFenceHandle : NSObject
+ (instancetype)newFenceFromDefaultServer;
- (mach_port_t)copyPort;
- (void)invalidate;
@end
int main(int c,char**v){ @autoreleasepool{
  [NSApplication sharedApplication];
  Class F=NSClassFromString(@"CAFenceHandle"); id fence=F?[F newFenceFromDefaultServer]:nil; mach_port_t port=fence?[fence copyPort]:0;
  __block BOOL done=NO;
  SLSPostCoordinatedDistributedNotificationFenced(SLSMainConnectionID(), 12, port, ^{ done=YES; }, 0.5);
  if(port) mach_right_send_release(port);
  [fence invalidate];
  NSDate*end=[NSDate dateWithTimeIntervalSinceNow:1.5];
  while(!done && [end timeIntervalSinceNow]>0) [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
  printf("posted type 12, fence %s, completion %s\n", port?"yes":"no", done?"called":"not called");
} return 0; }
