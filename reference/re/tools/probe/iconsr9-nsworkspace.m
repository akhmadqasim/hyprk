#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
// render2 <outdir> aqua|darkAqua : NSWorkspace icons drawn under the given NSAppearance
int main(int argc,char**argv){@autoreleasepool{
  NSString*out=@(argv[1]); BOOL dark=strcmp(argv[2],"darkAqua")==0;
  [[NSFileManager defaultManager] createDirectoryAtPath:out withIntermediateDirectories:YES attributes:nil error:nil];
  NSString*F=[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures/hyprk-gallery/icons"];
  NSWorkspace*ws=[NSWorkspace sharedWorkspace];
  NSImage*(^T)(NSString*)=^(NSString*t){return [ws iconForContentType:[UTType typeWithIdentifier:t]];};
  NSImage*(^U)(NSString*)=^(NSString*p){return [ws iconForFile:p];};
  NSImage*(^B)(NSString*)=^(NSString*b){return [ws iconForFile:[[ws URLForApplicationWithBundleIdentifier:b] path]];};
  NSArray*items=@[
   @[@"folder-generic",T(@"public.folder")],@[@"folder-desktop",T(@"com.apple.desktop-folder")],@[@"folder-documents",T(@"com.apple.documents-folder")],
   @[@"folder-downloads",T(@"com.apple.downloads-folder")],@[@"folder-applications",T(@"com.apple.applications-folder")],@[@"folder-home",T(@"com.apple.home-folder")],
   @[@"folder-library",T(@"com.apple.library-folder")],@[@"folder-tagged-red",U([F stringByAppendingPathComponent:@"Red"])],
   @[@"trash-empty",T(@"com.apple.trash-empty")],@[@"trash-full",T(@"com.apple.trash-full")],@[@"volume-external",T(@"com.apple.storage-external")],
   @[@"doc-txt",U([F stringByAppendingPathComponent:@"Sample.txt"])],@[@"doc-pdf",U([F stringByAppendingPathComponent:@"Sample.pdf"])],
   @[@"doc-zip",U([F stringByAppendingPathComponent:@"Sample.zip"])],@[@"doc-jpg",U([F stringByAppendingPathComponent:@"Sample.jpg"])],
   @[@"doc-png",U([F stringByAppendingPathComponent:@"Sample.png"])],@[@"doc-md",U([F stringByAppendingPathComponent:@"Sample.md"])],
   @[@"doc-json",U([F stringByAppendingPathComponent:@"Sample.json"])],@[@"alias-folder",U([F stringByAppendingPathComponent:@"Target alias"])],
   @[@"app-finder",B(@"com.apple.finder")],@[@"app-safari",B(@"com.apple.Safari")],@[@"app-system-settings",B(@"com.apple.systempreferences")],@[@"app-textedit",B(@"com.apple.TextEdit")]];
  NSAppearance*ap=[NSAppearance appearanceNamed:dark?NSAppearanceNameDarkAqua:NSAppearanceNameAqua];
  [ap performAsCurrentDrawingAppearance:^{
  for(NSArray*it in items) for(NSNumber*s in @[@16,@32,@64,@128,@512]){
    int px=s.intValue; NSImage*im=it[1];
    NSBitmapImageRep*r=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:px pixelsHigh:px bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    [NSGraphicsContext saveGraphicsState]; [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:r]];
    [im drawInRect:NSMakeRect(0,0,px,px) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:@{NSImageHintCTM:[NSAffineTransform transform]}];
    [NSGraphicsContext restoreGraphicsState];
    [[r representationUsingType:NSBitmapImageFileTypePNG properties:@{}] writeToFile:[out stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d.png",it[0],px]] atomically:YES];
  }}];
}}
