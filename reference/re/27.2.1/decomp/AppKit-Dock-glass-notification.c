// How a changed Liquid Glass slider value (NSGlassTintAmount) reaches running apps. macOS 27.2.1 (26B131), arm64e.
// AppKit addresses are unslid dyld cache VAs; Dock addresses are from /System/Library/CoreServices/Dock.app (arm64e).
// Reconstructed pseudocode. Live check: live/verify/C2/notification-live.log, tools/probe/glasspost.m.

// ---- sender (System Settings, through AppKit) --------------------------------------------------------------
// NSGlassEffectView.Legibility.setSystemLegibility(_:completionHandler:) 0x18b31ee4c: writes the global default, then
void postGlassAppearanceChange(void (^completion)(void)) {                     // 0x18b4c4f80
    CAFenceHandle *fence = [CAFenceHandle newFenceFromDefaultServer];
    mach_port_t port = fence ? [fence copyPort] : 0;
    SLSPostCoordinatedDistributedNotificationFenced(SLSMainConnectionID(), 12, port, completion, 0.5 /*s*/);
    mach_right_send_release(port);  [fence invalidate];
}

// ---- AppKit apps ------------------------------------------------------------------------------------------
// 0x18b4c4d48 (once per process, from every Legibility read): observes
//   kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName on SLSCoordinatedLocalNotificationCenter().
void handler(void) {                                                           // 0x18b4c4ee8
    if ([NSGlassEffectView _legibilityNeedsUpdate])
        [NSNotificationCenter.defaultCenter postNotificationName:NSGlassEffectDiffusionDidChangeNotification object:nil];
    mach_port_t fence = SLSCopyCoordinatedDistributedNotificationFencePort();
    [<class @got 0x1e07726a8> entangleUpdateOnFenceRight:fence];              // commit lands in the same frame as other apps
    mach_right_send_release(fence);
}
// +[NSGlassEffectView _legibilityNeedsUpdate] 0x18b317694 -> 0x18b32a01c: this is the re-read.
BOOL legibilityNeedsUpdate(void) {
    Legibility now = current();                    // 0x18b3176b0: flag 0x1eb431e3d set -> UserDefaults.standard float
                                                   // "NSGlassTintAmount" (helper 0x18b4ef760), nil -> 0.5; flag clear ->
                                                   // the preview value held at 0x1eb431e38 (previewSystemLegibility)
    BOOL same = (now == lastApplied /*0x1ed8d0774*/);
    lastApplied = now;
    return !same;
}
// Observers of NSGlassEffectDiffusionDidChangeNotification:
//   0x18b2b3db8 (ref 0x18b2b3fa4): addObserver:selector:@selector(globalEnvironmentDidChange:) together with the
//     table row-size, HDR-suppression and reduce-desktop-tinting notifications: the SwiftUI environment of the
//     hosting view is rebuilt, and NSGlassEffectView.Legibility.apply(to: &EnvironmentValues) 0x18b328f44 sets
//     env.glassDiffusion = .amount(current()).
//   0x18b47413c (ref 0x18b474894): a block observer (block 0x18b4948f4), same purpose for another view class.
// Nothing polls the default: `defaults write` alone changes nothing in a running app (measured: 3 s, no change),
// the notification does (measured: filter inputs change within the next 1 s sample).

// ---- Dock -------------------------------------------------------------------------------------------------
// DockCore.SystemAppearanceMonitor, -activate 0x1001e6098 -> 0x1001e58c4:
//   SLSCoordinatedLocalNotificationCenter().publisher(for: kSLSCoordinatedGlassAppearanceSettingsChangeNotificationName)
//       .sink { [weak self] _ in self?.update() }          // 0x1001e5b0c, closure 0x1001e67b8 -> 0x1001e6048
void SystemAppearanceMonitor_update(void) {                                    // 0x1001e5cec
    theme = SLSGetAppearanceThemeLegacy();
    cont  = SLSCopyCoordinatedDistributedNotificationContinuationBlock();
    dispatch_async(main, ^{                                                    // 0x1001e61e4
        readSettings();            // 0x1001e5600: [NSUserDefaults.standardUserDefaults objectForKey:@"NSGlassTintAmount"]
                                   //             -> floatForKey:, 0.5 when unset (0x1001e5638..0x1001e56d8)
        for (observer in observers) [observer appearanceDidChange:...];        // 0x1001e62a0
        cont();                                                                // releases the WindowServer fence
    });
}
// The value ends in -[DockGlassMaterialEnvironment setTintAmount:] 0x100177f44 (ivar read by tintAmount 0x100177f10),
// which the Dock passes on as EnvironmentValues.glassDiffusion = .amount(x).
