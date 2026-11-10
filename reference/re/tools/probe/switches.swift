// hyprk switch probe: one window with an NSSwitch at regular, small and mini size (off and on), at fixed screen
// positions, for 60 fps recordings of clicks and press-and-hold. While running it samples the presentation layers of
// every switch at 240 Hz and writes the changes (layer path, frame, opacity, background colour) as JSON lines, so the
// knob travel and press growth can be read without video. Changes nothing outside its own process.
// Build: swiftc -swift-version 5 -O -o switches switches.swift
// Run:   ./switches <out.jsonl> <seconds>     (window content origin printed on stdout, in global top-left points)
import AppKit
import QuartzCore

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "switches.jsonl"
let secs = CommandLine.arguments.count > 2 ? Double(CommandLine.arguments[2])! : 30

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 220), styleMask: [.titled, .closable],
                   backing: .buffered, defer: false)
win.title = "Switch probe"
let content = NSView(frame: win.contentView!.bounds)
win.contentView = content

var switches: [(String, NSSwitch)] = []
for (i, (name, size)) in [("regular", NSControl.ControlSize.regular), ("small", .small), ("mini", .mini)].enumerated() {
    for (j, on) in [false, true].enumerated() {
        let s = NSSwitch()
        s.controlSize = size
        s.state = on ? .on : .off
        s.setFrameSize(s.intrinsicContentSize)
        s.setFrameOrigin(NSPoint(x: 40 + j * 160, y: 160 - i * 60))
        s.wantsLayer = true
        content.addSubview(s)
        switches.append(("\(name)-\(on ? "on" : "off")", s))
    }
}

let fh = FileManager.default.createFile(atPath: out, contents: nil) ? FileHandle(forWritingAtPath: out)! : nil
func emit(_ o: [String: Any]) {
    if let d = try? JSONSerialization.data(withJSONObject: o, options: [.sortedKeys]) {
        fh?.write(d); fh?.write("\n".data(using: .utf8)!)
    }
}
func rr(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 100).rounded() / 100 } }
func col(_ c: CGColor?) -> [Double]? {
    guard let c = c, let s = c.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)
    else { return nil }
    return (s.components ?? []).map { (Double($0) * 1000).rounded() / 1000 }
}

var last: [String: String] = [:]
let t0 = CACurrentMediaTime()
func sample() {
    let t = CACurrentMediaTime() - t0
    for (name, s) in switches {
        guard let root = s.layer else { continue }
        var stack: [(CALayer, String)] = [(root, "0")]
        while let (l, path) = stack.popLast() {
            let p = l.presentation() ?? l
            let f = p.convert(p.bounds, to: (root.presentation() ?? root))
            var o: [String: Any] = ["frame": rr(f), "op": (Double(p.opacity) * 1000).rounded() / 1000,
                                    "cls": "\(type(of: l))"]
            if let bc = col(p.backgroundColor) { o["bg"] = bc }
            if p.isHidden { o["hidden"] = true }
            let key = "\(o)"
            let id = "\(name)/\(path)"
            if last[id] != key {
                last[id] = key
                var e = o; e["t"] = (t * 10000).rounded() / 10000; e["sw"] = name; e["path"] = path
                e["state"] = s.state == .on ? 1 : 0
                emit(e)
            }
            for (k, sub) in (l.sublayers ?? []).enumerated() { stack.append((sub, "\(path).\(k)")) }
        }
    }
}

win.setFrameTopLeftPoint(NSPoint(x: 200, y: NSScreen.main!.frame.height - 200))
win.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    let h = NSScreen.main!.frame.height
    for (name, s) in switches {
        let r = s.convert(s.bounds, to: nil)
        let g = win.convertToScreen(r)
        print(name, "global-topleft", [g.minX, h - g.maxY, g.width, g.height])
    }
    fflush(stdout)
}
let timer = Timer(timeInterval: 1.0 / 240, repeats: true) { _ in sample() }
RunLoop.main.add(timer, forMode: .common)
RunLoop.main.add(timer, forMode: .eventTracking)
DispatchQueue.main.asyncAfter(deadline: .now() + secs) { app.terminate(nil) }
app.run()
