// cham: shows what colour a CAChameleonLayer takes (the wallpaper tint WindowServer hands to each render context).
// A borderless grey-127 window is moved over the screen; left half = CAChameleonLayer at opacity 1 (plain),
// right half = the same with compositingFilter colorBlendMode. One capture per position, plus a time series.
// Build: swiftc -swift-version 5 -O -o cham cham.swift    Run: cham <outdir> <tag> <dark|light> [w h]
import AppKit
import QuartzCore
let a = CommandLine.arguments
let outDir = a.count > 1 ? a[1] : ".", tag = a.count > 2 ? a[2] : "c", mode = a.count > 3 ? a[3] : "dark"
let WW = CGFloat(Double(a.count > 4 ? a[4] : "320") ?? 320), HH = CGFloat(Double(a.count > 5 ? a[5] : "220") ?? 220)
class Win: NSWindow { override var canBecomeKey: Bool { true } }
class D: NSObject, NSApplicationDelegate {
    var win: Win!
    let sh = NSScreen.screens[0].frame.height, sw = NSScreen.screens[0].frame.width
    var steps: [(Double, () -> Void)] = []
    var log: [[String: Any]] = []
    func cap(_ x: CGFloat, _ y: CGFloat, _ name: String) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-R", "\(Int(x)),\(Int(y)),\(Int(WW)),\(Int(HH))", "\(outDir)/\(name).png"]; try? p.run(); p.waitUntilExit()
    }
    func run() {
        guard !steps.isEmpty else {
            if let d = try? JSONSerialization.data(withJSONObject: log, options: [.sortedKeys]) { try? d.write(to: URL(fileURLWithPath: "\(outDir)/\(tag)-cham-log.json")) }
            NSApp.terminate(nil); return
        }
        let (t, f) = steps.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + t) { f(); self.run() }
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        win = Win(contentRect: NSRect(x: 20, y: sh - 60 - HH, width: WW, height: HH), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false; win.isOpaque = true
        let v = NSView(frame: NSRect(x: 0, y: 0, width: WW, height: HH)); v.wantsLayer = true
        v.layer?.backgroundColor = CGColor(colorSpace: NSScreen.screens[0].colorSpace?.cgColorSpace ?? CGColorSpaceCreateDeviceRGB(), components: [127.0 / 255, 127.0 / 255, 127.0 / 255, 1])
        win.contentView = v
        if let cls = NSClassFromString("CAChameleonLayer") as? CALayer.Type {
            let c1 = cls.init(); c1.frame = NSRect(x: 0, y: 0, width: WW / 2, height: HH); v.layer?.addSublayer(c1)
            let c2 = cls.init(); c2.frame = NSRect(x: WW / 2, y: 0, width: WW / 2, height: HH); c2.compositingFilter = "colorBlendMode"; v.layer?.addSublayer(c2)
        }
        win.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        var k = 0
        for t in [0.15, 0.3, 0.5, 1.0, 1.5] {
            steps.append((t, { k += 1; let nm = "\(tag)-cham-t\(k)"; self.cap(20, 60, nm); self.log.append(["file": nm, "x": 20, "y": 60, "series": true]) }))
        }
        var pos: [(CGFloat, CGFloat)] = []
        let nx = 5, ny = 4
        for j in 0..<ny { for i in 0..<nx { pos.append((10 + CGFloat(i) * (sw - WW - 20) / CGFloat(nx - 1), 40 + CGFloat(j) * (sh - HH - 50) / CGFloat(ny - 1))) } }
        for (i, p) in pos.enumerated() {
            steps.append((0.0, { self.win.setFrame(NSRect(x: p.0, y: self.sh - p.1 - HH, width: WW, height: HH), display: true) }))
            steps.append((0.25, { let nm = "\(tag)-cham-p\(i)a"; self.cap(p.0.rounded(.down), p.1.rounded(.down), nm); self.log.append(["file": nm, "x": p.0, "y": p.1, "wait": 0.25]) }))
            steps.append((1.2, { let nm = "\(tag)-cham-p\(i)b"; self.cap(p.0.rounded(.down), p.1.rounded(.down), nm); self.log.append(["file": nm, "x": p.0, "y": p.1, "wait": 1.6]) }))
        }
        run()
    }
}
Timer.scheduledTimer(withTimeInterval: 120, repeats: false) { _ in exit(2) }
let app = NSApplication.shared; app.setActivationPolicy(.accessory)
let d = D(); app.delegate = d; app.run()
