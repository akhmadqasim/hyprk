// thick: NSGlassEffectView probe for the Liquid Glass slider (NSGlassTintAmount) and for size dependence.
// Build: swiftc -swift-version 5 -O -o thick thick.swift
// Run:   thick <outdir> <tag> [dark|light] [all|mat|size|ramp|hold <seconds>|dockbg <seconds>]
//   mat   : variants (regular, clear, dock, controlCenter, notificationCenter, sidebar, regular.menu) at 150x64 over
//           white / grey 127 / black / blue (69,83,206) / 4 pt stripes.
//   size  : regular and clear at 120x24, 120x36, 160x64, 64x64, 200x200 (r 28 and r 100), 500x500 over grey, white,
//           black and stripes.
//   ramp  : uniform grey levels and a few colours under regular 64 / 96 / 200 pt, clear, dock, controlCenter, sidebar.
//   hold  : keeps the mat scene up and dumps the filter inputs once per second (to see whether a running app
//           picks up a changed NSGlassTintAmount).
//   dockbg: borderless window at the bottom of the screen that cycles stripes / white / grey / black / blue behind
//           the real Dock and captures the Dock strip for each.
//   ccbg  : the same at the top right of the screen (560 x 800 pt), behind the real Control Center panel (open it
//           by hand or with a synthetic click while the first backdrop is up).
//   ramp also holds a 500 x 500 regular panel (name regular500).
//   ccsin : controlCenter glass (288x64 and 160x64) and clear glass over a sinusoidal 8 pt pattern, 114.8 +- 16 grey
//           levels: what the real Control Center tiles see behind them (panel blur + 10 % dim over 4 pt stripes).
// Every scene writes <tag>-<scene>.json (layout rects in capture pixels + the glassBackground filter inputs of every
// view) and <tag>-<scene>.png (screencapture of the window content).
import AppKit
import QuartzCore

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "."
let tag = args.count > 2 ? args[2] : "t"
let mode = args.count > 3 ? args[3] : "dark"
let scenario = args.count > 4 ? args[4] : "all"
let holdSecs = args.count > 5 ? Double(args[5]) ?? 20 : 20

func plain(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID {
        let c = v as! CGColor
        return (c.components ?? []).map { Double($0) }
    }
    if let a = v as? [Any] { return a.map { plain($0) } }
    if let nv = v as? NSValue {
        var size = 0, align = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &align)
        let enc = String(cString: nv.objCType)
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fdcislqCISLQB".contains($0) }
        if size > 0, size <= 256, !kinds.isEmpty, kinds.allSatisfy({ $0 == "f" }) || kinds.allSatisfy({ $0 == "d" }) {
            var buf = [UInt8](repeating: 0, count: size)
            nv.getValue(&buf, size: size)
            if kinds.first == "f" { return buf.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }.map { Double($0) } }
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Double.self)) }
        }
    }
    return String(describing: v)
}

// glassBackground filter inputs and backdrop layer settings below a view's layer
func glassInfo(_ root: CALayer) -> [String: Any] {
    var out: [String: Any] = [:]
    var others: [String] = []
    func walk(_ l: CALayer) {
        let cls = "\(type(of: l))"
        if cls.contains("Backdrop") {
            var b: [String: Any] = [:]
            for k in ["scale", "marginWidth", "groupName", "lumaUpdateRate", "blurRadius", "saturation"] where l.responds(to: NSSelectorFromString(k)) {
                b[k] = plain(l.value(forKey: k))
            }
            if out["backdrop"] == nil { out["backdrop"] = b }
        }
        for f in (l.filters ?? []) + (l.backgroundFilters ?? []) {
            guard let o = f as? NSObject else { continue }
            let name = (o.responds(to: NSSelectorFromString("name")) ? o.value(forKey: "name") as? String : nil) ?? "?"
            let type = (o.responds(to: NSSelectorFromString("type")) ? o.value(forKey: "type") as? String : nil) ?? "?"
            var inputs: [String: Any] = [:]
            if o.responds(to: NSSelectorFromString("inputKeys")), let ks = o.value(forKey: "inputKeys") as? [String] {
                for k in ks { if let v = o.value(forKey: k) { inputs[k] = plain(v) } }
            }
            if type == "glassBackground" || name == "glassBackground" {
                if out["glass"] == nil { out["glass"] = inputs; out["glassLayer"] = cls; out["glassCornerRadius"] = l.cornerRadius }
            } else { others.append("\(cls):\(type)"); if out["other:" + type] == nil { out["other:" + type] = inputs } }
        }
        if let m = l.mask { walk(m) }
        for s in l.sublayers ?? [] { walk(s) }
    }
    walk(root)
    out["otherFilters"] = others
    return out
}

struct Item { let name: String; let variant: Int; let sub: String?; let clear: Bool; let frame: NSRect; let radius: CGFloat; let bg: String }

class Bands: NSView {
    // (name, rect in view coords)
    var bands: [(String, NSRect)] = []
    var space: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    override var isFlipped: Bool { true }
    override func draw(_ dirty: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor { CGColor(colorSpace: space, components: [r / 255, g / 255, b / 255, 1])! }
        for (name, r) in bands {
            switch name {
            case "white": ctx.setFillColor(col(255, 255, 255)); ctx.fill(r)
            case "grey": ctx.setFillColor(col(127, 127, 127)); ctx.fill(r)
            case "black": ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            case "blue": ctx.setFillColor(col(69, 83, 206)); ctx.fill(r)
            case "stripes":
                ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
                ctx.setFillColor(col(255, 255, 255))
                var x = r.minX
                while x < r.maxX { ctx.fill(NSRect(x: x, y: r.minY, width: min(4, r.maxX - x), height: r.height)); x += 8 }
            case "sin":
                var x = r.minX
                while x < r.maxX {
                    let v = 114.8 + 16.0 * sin(2 * Double.pi * Double(x + 0.25) / 8.0)
                    ctx.setFillColor(col(CGFloat(v), CGFloat(v), CGFloat(v))); ctx.fill(NSRect(x: x, y: r.minY, width: 0.5, height: r.height)); x += 0.5
                }
            default:
                if name.hasPrefix("rgb:") {
                    let c = name.dropFirst(4).split(separator: ",").map { CGFloat(Double($0) ?? 0) }
                    if c.count == 3 { ctx.setFillColor(col(c[0], c[1], c[2])); ctx.fill(r) }
                }
            }
        }
    }
}

class Win: NSWindow { override var canBecomeKey: Bool { true }; override var canBecomeMain: Bool { true } }

class D: NSObject, NSApplicationDelegate {
    var win: Win!
    var bg: Bands!
    var views: [(Item, NSGlassEffectView)] = []
    let screenH = NSScreen.screens[0].frame.height
    var scenes: [(String, NSSize, [(String, NSRect)], [Item])] = []

    func after(_ t: Double, _ f: @escaping () -> Void) { DispatchQueue.main.asyncAfter(deadline: .now() + t, execute: f) }

    func capture(_ rectTopLeft: NSRect, _ path: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-R", "\(Int(rectTopLeft.minX)),\(Int(rectTopLeft.minY)),\(Int(rectTopLeft.width)),\(Int(rectTopLeft.height))", path]
        try? p.run(); p.waitUntilExit()
    }
    func writeJSON(_ name: String, _ obj: Any) {
        if let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]) {
            try? d.write(to: URL(fileURLWithPath: "\(outDir)/\(name).json"))
        }
    }

    func matScene() -> (String, NSSize, [(String, NSRect)], [Item]) {
        let cfgs: [(String, Int, String?, Bool)] = [("regular", 0, nil, false), ("clear", 0, nil, true), ("dock", 3, nil, false),
            ("controlCenter", 9, nil, false), ("notificationCenter", 10, nil, false), ("sidebar", 17, nil, false), ("regular.menu", 0, "menu", false)]
        let bandNames = ["white", "grey", "black", "blue", "stripes"]
        let W = CGFloat(cfgs.count) * 170 + 20, bh: CGFloat = 100
        var bands: [(String, NSRect)] = []; var items: [Item] = []
        for (j, b) in bandNames.enumerated() {
            bands.append((b, NSRect(x: 0, y: CGFloat(j) * bh, width: W, height: bh)))
            for (i, c) in cfgs.enumerated() {
                items.append(Item(name: c.0, variant: c.1, sub: c.2, clear: c.3,
                                  frame: NSRect(x: 20 + CGFloat(i) * 170, y: CGFloat(j) * bh + 18, width: 150, height: 64), radius: 20, bg: b))
            }
        }
        return ("mat", NSSize(width: W, height: bh * CGFloat(bandNames.count)), bands, items)
    }
    func sizeScene(_ style: String, _ bgName: String) -> (String, NSSize, [(String, NSRect)], [Item]) {
        let W: CGFloat = 960, H: CGFloat = 540
        let clear = style == "clear"
        let fr: [(NSRect, CGFloat)] = [
            (NSRect(x: 20, y: 20, width: 120, height: 24), 12), (NSRect(x: 20, y: 64, width: 120, height: 36), 18),
            (NSRect(x: 20, y: 120, width: 160, height: 64), 28), (NSRect(x: 20, y: 204, width: 64, height: 64), 32),
            (NSRect(x: 20, y: 290, width: 160, height: 64), 12),
            (NSRect(x: 200, y: 20, width: 200, height: 200), 28), (NSRect(x: 200, y: 240, width: 200, height: 200), 100),
            (NSRect(x: 430, y: 20, width: 500, height: 500), 28)]
        let items = fr.map { Item(name: style, variant: 0, sub: nil, clear: clear, frame: $0.0, radius: $0.1, bg: bgName) }
        return ("size-\(style)-\(bgName)", NSSize(width: W, height: H), [(bgName, NSRect(x: 0, y: 0, width: W, height: H))], items)
    }

    // uniform backdrop per scene: regular 160x64, regular 200x200, clear, dock, controlCenter, sidebar (160x64)
    func rampScene(_ rgb: String) -> (String, NSSize, [(String, NSRect)], [Item]) {
        let W: CGFloat = 1300, H: CGFloat = 540
        var items: [Item] = [Item(name: "regular", variant: 0, sub: nil, clear: false, frame: NSRect(x: 20, y: 20, width: 160, height: 64), radius: 28, bg: rgb),
                             Item(name: "regular500", variant: 0, sub: nil, clear: false, frame: NSRect(x: 780, y: 20, width: 500, height: 500), radius: 28, bg: rgb),
                             Item(name: "menu200", variant: 0, sub: "menu", clear: false, frame: NSRect(x: 200, y: 240, width: 200, height: 200), radius: 28, bg: rgb),
                             Item(name: "notificationCenter", variant: 10, sub: nil, clear: false, frame: NSRect(x: 420, y: 180, width: 160, height: 64), radius: 28, bg: rgb),
                             Item(name: "regular200", variant: 0, sub: nil, clear: false, frame: NSRect(x: 200, y: 20, width: 200, height: 200), radius: 28, bg: rgb)]
        let more: [(String, Int, Bool, CGFloat, CGFloat)] = [("clear", 0, true, 20, 100), ("dock", 3, false, 420, 20), ("controlCenter", 9, false, 420, 100), ("sidebar", 17, false, 590, 20), ("regular96", 0, false, 590, 100)]
        for m in more { items.append(Item(name: m.0, variant: m.1, sub: nil, clear: m.2, frame: NSRect(x: m.3, y: m.4, width: 160, height: m.0 == "regular96" ? 96 : 64), radius: 28, bg: rgb)) }
        return ("ramp-" + rgb.dropFirst(4).replacingOccurrences(of: ",", with: "_"), NSSize(width: W, height: H), [(rgb, NSRect(x: 0, y: 0, width: W, height: H))], items)
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        if scenario == "dockbg" { dockBG(); return }
        if scenario == "ccbg" { dockBG(top: true); return }
        if scenario == "all" || scenario == "mat" || scenario == "hold" { scenes.append(matScene()) }
        if scenario == "ramp" {
            settle = 0.7
            for g in [0, 16, 32, 48, 64, 96, 127, 160, 192, 224, 255] { scenes.append(rampScene("rgb:\(g),\(g),\(g)")) }
            for c in ["255,0,0", "0,255,0", "0,0,255", "230,140,40", "69,83,206", "40,160,90"] { scenes.append(rampScene("rgb:" + c)) }
        }
        if scenario == "ccsin" {
            let W: CGFloat = 700, H: CGFloat = 200
            let items = [Item(name: "controlCenter288", variant: 9, sub: nil, clear: false, frame: NSRect(x: 20, y: 20, width: 288, height: 64), radius: 28, bg: "sin"),
                         Item(name: "controlCenter160", variant: 9, sub: nil, clear: false, frame: NSRect(x: 330, y: 20, width: 160, height: 64), radius: 28, bg: "sin"),
                         Item(name: "controlCenter288x128", variant: 9, sub: nil, clear: false, frame: NSRect(x: 20, y: 100, width: 288, height: 90), radius: 28, bg: "sin"),
                         Item(name: "clear160", variant: 0, sub: nil, clear: true, frame: NSRect(x: 510, y: 20, width: 160, height: 64), radius: 28, bg: "sin")]
            scenes.append(("ccsin", NSSize(width: W, height: H), [("sin", NSRect(x: 0, y: 0, width: W, height: H))], items))
        }
        if scenario == "all" || scenario == "size" {
            for st in ["regular", "clear"] { for b in ["grey", "white", "black", "stripes"] { scenes.append(sizeScene(st, b)) } }
        }
        win = Win(contentRect: NSRect(x: 20, y: screenH - 60 - 540, width: 1300, height: 540), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false
        win.isOpaque = true
        bg = Bands(frame: NSRect(x: 0, y: 0, width: 1300, height: 540))
        if let cs = NSScreen.screens[0].colorSpace?.cgColorSpace { bg.space = cs }
        win.contentView = bg
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        after(0.5) { self.next() }
    }

    var idx = 0
    var settle = 1.2
    func next() {
        guard idx < scenes.count else { NSApp.terminate(nil); return }
        let (name, size, bands, items) = scenes[idx]; idx += 1
        for (_, v) in views { v.removeFromSuperview() }
        views = []
        let top: CGFloat = 60, left: CGFloat = 20
        win.setFrame(NSRect(x: left, y: screenH - top - size.height, width: size.width, height: size.height), display: true)
        bg.frame = NSRect(origin: .zero, size: size)
        bg.bands = bands; bg.needsDisplay = true
        for it in items {
            let g = NSGlassEffectView(frame: it.frame)
            g.cornerRadius = it.radius
            g.setValue(it.variant, forKey: "_variant")
            if let sv = it.sub { g.setValue(sv, forKey: "_subvariant") }
            if it.clear { g.style = .clear }
            g.contentView = NSView(frame: NSRect(origin: .zero, size: it.frame.size))
            bg.addSubview(g); views.append((it, g))
        }
        NSApp.activate(ignoringOtherApps: true); win.makeKeyAndOrderFront(nil)
        if scenario == "hold" { holdLoop(name, size, 0); return }
        after(settle) {
            self.dump(name, size)
            self.capture(NSRect(x: left, y: top, width: size.width, height: size.height), "\(outDir)/\(tag)-\(name).png")
            self.next()
        }
    }
    func dump(_ name: String, _ size: NSSize, suffix: String = "") {
        var arr: [[String: Any]] = []
        for (it, g) in views {
            var d: [String: Any] = ["name": it.name, "bg": it.bg, "radius": it.radius,
                                    "rect": [it.frame.minX * 2, it.frame.minY * 2, it.frame.width * 2, it.frame.height * 2],
                                    "sizePt": [it.frame.width, it.frame.height]]
            if let l = g.layer { d.merge(glassInfo(l)) { a, _ in a } }
            arr.append(d)
        }
        let tint = UserDefaults.standard.object(forKey: "NSGlassTintAmount")
        writeJSON("\(tag)-\(name)\(suffix)", ["scene": name, "sizePx": [size.width * 2, size.height * 2], "mode": mode,
                                              "defaultsTint": plain(tint), "appActive": NSApp.isActive, "key": win.isKeyWindow, "items": arr])
    }
    func holdLoop(_ name: String, _ size: NSSize, _ i: Int) {
        if Double(i) > holdSecs { NSApp.terminate(nil); return }
        after(1.0) {
            self.dump(name, size, suffix: String(format: "-hold%02d", i))
            // one line per second: regular-over-grey blur fill + face fill, clear blur radius
            var line = "hold \(i)"
            for (it, g) in self.views where it.bg == "grey" && (it.name == "regular" || it.name == "clear") {
                if let l = g.layer, let gl = glassInfo(l)["glass"] as? [String: Any] {
                    line += " \(it.name): N=\(gl["inputBlurFillNormalOpacity"] ?? "?") fill=\(gl["inputFaceColorMatrixFillColor"] ?? "?") maxLuma=\(gl["inputFaceColorMatrixMaxLuma"] ?? "?") blur=\(gl["inputBlurRadius"] ?? "?")"
                }
            }
            print(line); fflush(stdout)
            self.holdLoop(name, size, i + 1)
        }
    }

    // window behind the real Dock
    func dockBG(top: Bool = false) {
        let full = NSScreen.screens[0].frame.width
        let sw: CGFloat = top ? 560 : full
        let H: CGFloat = top ? 800 : 120
        let x0: CGFloat = top ? full - sw : 0
        win = Win(contentRect: NSRect(x: x0, y: top ? screenH - H : 0, width: sw, height: H), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false; win.isOpaque = true
        bg = Bands(frame: NSRect(x: 0, y: 0, width: sw, height: H))
        if let cs = NSScreen.screens[0].colorSpace?.cgColorSpace { bg.space = cs }
        win.contentView = bg
        win.level = .normal
        win.orderFrontRegardless()
        let names = ["stripes", "white", "grey", "black", "blue"]
        var i = 0
        func step() {
            guard i < names.count else { NSApp.terminate(nil); return }
            let nm = names[i]; i += 1
            self.bg.bands = [(nm, NSRect(x: 0, y: 0, width: sw, height: H))]; self.bg.needsDisplay = true
            self.after(holdSecs) {
                self.capture(NSRect(x: x0, y: top ? 0 : self.screenH - H, width: sw, height: H), "\(outDir)/\(tag)-\(top ? "cc" : "dock")-\(nm).png")
                step()
            }
        }
        step()
    }
}
Timer.scheduledTimer(withTimeInterval: 90, repeats: false) { _ in print("timeout"); exit(2) }
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let d = D(); app.delegate = d; app.run()
