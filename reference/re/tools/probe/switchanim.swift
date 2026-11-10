// hyprk switch animation probe: one regular NSSwitch. Flips it (performClick, or wait for real clicks with "manual")
// and samples at 240 Hz (a) the knob presentation frame and (b) every CAAnimation attached to any layer of the switch
// (class, keyPath, spring parameters, duration, from/to, timing function). Writes JSON lines.
// Build: swiftc -swift-version 5 -O -o switchanim switchanim.swift
// Run:   ./switchanim <out.jsonl> <seconds> [manual]
import AppKit
import QuartzCore

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "switchanim.jsonl"
let secs = CommandLine.arguments.count > 2 ? Double(CommandLine.arguments[2])! : 6
let manual = CommandLine.arguments.count > 3
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 100), styleMask: [.titled], backing: .buffered, defer: false)
win.title = "Switch anim probe"
let sw = NSSwitch()
sw.controlSize = .regular
sw.setFrameSize(sw.intrinsicContentSize)
sw.setFrameOrigin(NSPoint(x: 70, y: 40))
sw.wantsLayer = true
win.contentView!.addSubview(sw)
FileManager.default.createFile(atPath: out, contents: nil)
let fh = FileHandle(forWritingAtPath: out)!
func emit(_ o: [String: Any]) {
    if let d = try? JSONSerialization.data(withJSONObject: o, options: [.sortedKeys]) { fh.write(d); fh.write("\n".data(using: .utf8)!) }
}
func desc(_ a: CAAnimation) -> [String: Any] {
    var o: [String: Any] = ["class": "\(type(of: a))", "duration": a.duration, "beginTime": a.beginTime, "speed": a.speed,
                            "fillMode": a.fillMode.rawValue, "removedOnCompletion": a.isRemovedOnCompletion]
    if let tf = a.timingFunction {
        var c = [Float](repeating: 0, count: 8)
        for i in 0..<4 { tf.getControlPoint(at: i, values: &c[i * 2]) }
        o["timingFunction"] = c.map { Double($0) }; o["timingFunctionDesc"] = "\(tf)"
    }
    if let p = a as? CAPropertyAnimation { o["keyPath"] = p.keyPath ?? ""; o["additive"] = p.isAdditive }
    if let b = a as? CABasicAnimation {
        o["from"] = "\(b.fromValue ?? "nil")"; o["to"] = "\(b.toValue ?? "nil")"; o["by"] = "\(b.byValue ?? "nil")"
    }
    if let s = a as? CASpringAnimation {
        o["mass"] = s.mass; o["stiffness"] = s.stiffness; o["damping"] = s.damping; o["initialVelocity"] = s.initialVelocity
        o["settlingDuration"] = s.settlingDuration
        if #available(macOS 14.0, *) { o["perceptualDuration"] = s.perceptualDuration; o["bounce"] = s.bounce; o["allowsOverdamping"] = s.allowsOverdamping }
    }
    if let g = a as? CAAnimationGroup { o["group"] = (g.animations ?? []).map { desc($0) } }
    o["debug"] = a.debugDescription
    return o
}
var seen = Set<String>()
var lastFrame = ""
let t0 = CACurrentMediaTime()
func sample() {
    let now = CACurrentMediaTime(); let t = now - t0
    guard let root = sw.layer else { return }
    var stack: [(CALayer, String)] = [(root, "0")]
    while let (l, path) = stack.popLast() {
        for k in l.animationKeys() ?? [] {
            guard let a = l.animation(forKey: k) else { continue }
            let id = "\(path)|\(k)|\(Unmanaged.passUnretained(a).toOpaque())"
            if !seen.contains(id) {
                seen.insert(id)
                var o = desc(a); o["ev"] = "anim"; o["t"] = t; o["path"] = path; o["key"] = k; o["layerClass"] = "\(type(of: l))"
                o["layerFrame"] = "\(l.frame)"; o["mediaNow"] = now; o["layerTime"] = l.convertTime(now, from: nil)
                emit(o)
            }
        }
        for (k, sub) in (l.sublayers ?? []).enumerated() { stack.append((sub, "\(path).\(k)")) }
    }
    // knob = topmost white 32x20-ish layer: log every sublayer frame of the first container
    var fr: [String: [Double]] = [:]
    stack = [(root, "0")]
    while let (l, path) = stack.popLast() {
        let p = l.presentation() ?? l
        let f = p.convert(p.bounds, to: root.presentation() ?? root)
        if f.width < 53 { fr[path] = [f.origin.x, f.origin.y, f.width, f.height].map { (v: CGFloat) -> Double in (Double(v) * 1000).rounded() / 1000 } }
        for (k, sub) in (l.sublayers ?? []).enumerated() { stack.append((sub, "\(path).\(k)")) }
    }
    let key = "\(fr)"
    if key != lastFrame { lastFrame = key; emit(["ev": "frame", "t": t, "frames": fr, "state": sw.state == .on ? 1 : 0]) }
}
win.setFrameTopLeftPoint(NSPoint(x: 200, y: NSScreen.main!.frame.height - 200))
win.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
let timer = Timer(timeInterval: 1.0 / 240, repeats: true) { _ in sample() }
RunLoop.main.add(timer, forMode: .common)
if !manual {
    for (i, d) in [1.5, 3.0].enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + d) { emit(["ev": "performClick", "t": CACurrentMediaTime() - t0, "n": i]); sw.performClick(nil) }
    }
} else {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        let r = sw.convert(sw.bounds, to: nil); let g = win.convertToScreen(r)
        print("switch global-topleft", [g.minX, NSScreen.main!.frame.height - g.maxY, g.width, g.height]); fflush(stdout)
    }
}
DispatchQueue.main.asyncAfter(deadline: .now() + secs) { app.terminate(nil) }
app.run()
