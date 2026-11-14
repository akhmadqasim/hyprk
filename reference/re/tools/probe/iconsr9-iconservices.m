#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <dlfcn.h>
// render <outdir> <appearance: light|dark|default> [sizes...]
@interface NSObject (IS)
- (id)initWithType:(NSString*)t; - (id)initWithURL:(NSURL*)u; - (id)initWithBundleIdentifier:(NSString*)b;
- (id)initWithSize:(CGSize)s scale:(double)sc; - (long long)appearanceVariant;
- (id)imageForDescriptor:(id)d; - (id)prepareImageForDescriptor:(id)d; - (CGImageRef)CGImage;
@end
int main(int argc,char**argv){@autoreleasepool{
  dlopen("/System/Library/PrivateFrameworks/IconServices.framework/IconServices",RTLD_NOW);
  NSString*out=@(argv[1]); NSString*ap=@(argv[2]);
  [[NSFileManager defaultManager] createDirectoryAtPath:out withIntermediateDirectories:YES attributes:nil error:nil];
  NSString*F=[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures/hyprk-gallery/icons"];
  NSArray*items=@[
   @[@"folder-generic",@"t",@"public.folder"],@[@"folder-desktop",@"t",@"com.apple.desktop-folder"],@[@"folder-documents",@"t",@"com.apple.documents-folder"],
   @[@"folder-downloads",@"t",@"com.apple.downloads-folder"],@[@"folder-applications",@"t",@"com.apple.applications-folder"],@[@"folder-home",@"t",@"com.apple.home-folder"],
   @[@"folder-library",@"t",@"com.apple.library-folder"],@[@"folder-tagged-red",@"u",[F stringByAppendingPathComponent:@"Red"]],
   @[@"trash-empty",@"t",@"com.apple.trash-empty"],@[@"trash-full",@"t",@"com.apple.trash-full"],@[@"volume-external",@"t",@"com.apple.storage-external"],
   @[@"doc-txt",@"u",[F stringByAppendingPathComponent:@"Sample.txt"]],@[@"doc-pdf",@"u",[F stringByAppendingPathComponent:@"Sample.pdf"]],
   @[@"doc-zip",@"u",[F stringByAppendingPathComponent:@"Sample.zip"]],@[@"doc-jpg",@"u",[F stringByAppendingPathComponent:@"Sample.jpg"]],
   @[@"doc-png",@"u",[F stringByAppendingPathComponent:@"Sample.png"]],@[@"doc-md",@"u",[F stringByAppendingPathComponent:@"Sample.md"]],
   @[@"doc-json",@"u",[F stringByAppendingPathComponent:@"Sample.json"]],@[@"alias-folder",@"u",[F stringByAppendingPathComponent:@"Target alias"]],
   @[@"app-finder",@"b",@"com.apple.finder"],@[@"app-safari",@"b",@"com.apple.Safari"],@[@"app-system-settings",@"b",@"com.apple.systempreferences"],@[@"app-textedit",@"b",@"com.apple.TextEdit"]];
  NSArray*sizes=@[@16,@32,@64,@128,@512];
  Class IS=NSClassFromString(@"ISIcon"), TI=NSClassFromString(@"ISTypeIcon"), D=NSClassFromString(@"ISImageDescriptor");
  for(NSArray*it in items){
    id icon=nil; NSString*k=it[1];
    if([k isEqual:@"t"]) icon=[[TI alloc] initWithType:it[2]];
    else if([k isEqual:@"u"]) icon=[[IS alloc] initWithURL:[NSURL fileURLWithPath:it[2]]];
    else icon=[[IS alloc] initWithBundleIdentifier:it[2]];
    for(NSNumber*s in sizes){
      id d=[[D alloc] initWithSize:CGSizeMake(s.intValue==64?32:s.doubleValue,s.intValue==64?32:s.doubleValue) scale:(s.intValue==64?2:1)];
      if([ap isEqual:@"light"]) ((void(*)(id,SEL,long long))objc_msgSend)(d,@selector(setAppearance:),0); else if([ap isEqual:@"dark"]) ((void(*)(id,SEL,long long))objc_msgSend)(d,@selector(setAppearance:),1);
      if([it[0] isEqual:@"folder-generic"] && s.intValue==16) fprintf(stderr,"%s descriptor appearance=%lld variant=%lld\n",argv[2],((long long(*)(id,SEL))objc_msgSend)(d,@selector(appearance)),[d appearanceVariant]);
      id img=[icon prepareImageForDescriptor:d];
      if(!img) img=[icon imageForDescriptor:d];
      CGImageRef cg=[img CGImage]; if(s.intValue==16&&[it[0] hasPrefix:@"app-f"]) fprintf(stderr,"%s px %zu x %zu class %s\n",[it[0] UTF8String],CGImageGetWidth(cg),CGImageGetHeight(cg),object_getClassName(img));
      if(!cg){fprintf(stderr,"no image %s %d\n",[it[0] UTF8String],s.intValue);continue;}
      NSBitmapImageRep*r=[[NSBitmapImageRep alloc] initWithCGImage:cg];
      NSString*p=[out stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d.png",it[0],s.intValue]];
      [[r representationUsingType:NSBitmapImageFileTypePNG properties:@{}] writeToFile:p atomically:YES];
    }
  }
}}
