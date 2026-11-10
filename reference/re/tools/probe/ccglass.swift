// ccglass: NSGlassEffectView variants over white / grey 127 / black columns, to match Control Center tile pixels.
// ccglass <seconds> [light|dark]   window at (100,100) top-left, 3 columns x 160 wide; rows: variant 0, 9, 10, 5
import AppKit
let secs = CommandLine.arguments.count > 1 ? Double(CommandLine.arguments[1])! : 6
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "dark"
class D: NSObject, NSApplicationDelegate {
    var win: NSWindow!
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        let variants = [0, 9, 10, 5]
        let H = CGFloat(variants.count) * 90 + 20
        let sh = NSScreen.screens[0].frame.height
        win = NSWindow(contentRect: NSRect(x: 100, y: sh - 100 - H, width: 480, height: H), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false
        let bg = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: H))
        for (i, g) in [1.0, 127.0 / 255, 0.0].enumerated() {
            let v = NSView(frame: NSRect(x: CGFloat(i) * 160, y: 0, width: 160, height: H)); v.wantsLayer = true
            v.layer?.backgroundColor = NSColor(srgbRed: g, green: g, blue: g, alpha: 1).cgColor; bg.addSubview(v)
            for (j, va) in variants.enumerated() {
                let gv = NSGlassEffectView(frame: NSRect(x: CGFloat(i) * 160 + 10, y: H - 10 - CGFloat(j + 1) * 90 + 13, width: 140, height: 64))
                gv.cornerRadius = 32
                gv.setValue(va, forKey: "_variant")
                gv.contentView = NSView(frame: gv.bounds)
                bg.addSubview(gv)
            }
        }
        win.contentView = bg
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        Timer.scheduledTimer(withTimeInterval: secs, repeats: false) { _ in NSApp.terminate(nil) }
    }
}
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D(); app.delegate = d; app.run()
