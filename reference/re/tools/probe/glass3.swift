// glass3: NSGlassEffectView probe for (1) the sidebar variants (17, 18) colour response and full layer tree,
// (2) the blur kernel of the glassBackground filter (edge / line / dot response at chosen radius and backdrop scale).
// Build: swiftc -swift-version 5 -O -o glass3 glass3.swift
// Run:   glass3 <outdir> <tag> <dark|light> <tree|sb|blur|nat|nat3> [tint] [x] [-NSGlassTintAmount <tint>]
//   nat3 : regular panels 64 / 96 / 120 / 200 / 300 pt, menu 160, sidebar 17 (200) and 18 (300), each centred on a
//          black/white edge (edge-bleed blur vs size).
//   tree : regular, sidebar 17 / 18 at 160x64 and 240x500 over grey; dumps every layer below the window content.
//   sb   : the same views over ~50 uniform backdrops, at each tint value; one PNG per backdrop.
//   blur : one regular glass view 1000x200 whose glassBackground inputs are overridden to "blur only"
//          (BlurOpacity0..3 = 1, no fill / face / bleed / refraction / rim / shadow), radius r and backdrop scale s
//          swept, over a sharp vertical edge (several sub-cell phases), a 1 px line, a horizontal edge and a dot.
//   nat  : untouched recipes (regular 160x64, regular 400x200, clear, dock, controlCenter, sidebar) over the edge and
//          line patterns at each tint value.
// The slider value: give ONE tint in the list and append "-NSGlassTintAmount <a>" to the command line (argument
// domain of this process only; the global default and other apps are not touched).
// blur: a 7th argument "r:<list>" replaces the radius list; env G3_SCALES=<list> the backdrop scales; G3_PATS=edge
// keeps only the phase-0 vertical edge.
// Env G3_LEFT / G3_TOP move the window (default 20 / 60 pt from the top-left).
import AppKit
import QuartzCore

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "."
let tag = args.count > 2 ? args[2] : "t"
let mode = args.count > 3 ? args[3] : "dark"
let scenario = args.count > 4 ? args[4] : "tree"
let tints: [Float] = args.count > 5 ? args[5].split(separator: ",").compactMap { Float($0) } : [0, 0.5, 1]
let extra = args.count > 6 ? args[6] : ""

func plain(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID {
        let c = v as! CGColor
        return ["cs": (c.colorSpace?.name as String?) ?? "?", "c": (c.components ?? []).map { Double($0) }] as [String: Any]
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
    return String(String(describing: v).prefix(300))
}
func kv(_ o: NSObject, _ k: String) -> Any? { o.responds(to: NSSelectorFromString(k)) ? o.value(forKey: k) : nil }

func filterInfo(_ f: Any) -> [String: Any] {
    guard let o = f as? NSObject else { return ["?": String(describing: f)] }
    var d: [String: Any] = [:]
    if let n = kv(o, "name") { d["name"] = plain(n) }
    if let t = kv(o, "type") { d["type"] = plain(t) }
    if let e = kv(o, "enabled") { d["enabled"] = plain(e) }
    if let ks = kv(o, "inputKeys") as? [String] {
        var inp: [String: Any] = [:]
        for k in ks { if let v = o.value(forKey: k) { inp[k] = plain(v) } }
        d["inputs"] = inp
    }
    return d
}
var owner: [ObjectIdentifier: NSView] = [:]
func mapViews(_ v: NSView) { if let l = v.layer { owner[ObjectIdentifier(l)] = v }; v.subviews.forEach(mapViews) }

func layerTree(_ l: CALayer, _ depth: Int = 0) -> [String: Any] {
    let cls = "\(type(of: l))"
    var d: [String: Any] = ["class": cls, "frame": [l.frame.minX, l.frame.minY, l.frame.width, l.frame.height]]
    if let v = owner[ObjectIdentifier(l)] { d["view"] = "\(type(of: v))" }
    if let n = l.name { d["name"] = n }
    if l.opacity != 1 { d["opacity"] = l.opacity }
    if l.isHidden { d["hidden"] = true }
    if let c = l.backgroundColor { d["backgroundColor"] = plain(c) }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius }
    if l.masksToBounds { d["masksToBounds"] = true }
    if let cf = l.compositingFilter { d["compositingFilter"] = (cf as? String) ?? filterInfo(cf) }
    if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map(filterInfo) }
    if let fs = l.backgroundFilters, !fs.isEmpty { d["backgroundFilters"] = fs.map(filterInfo) }
    if l.contents != nil { d["contents"] = String("\(type(of: l.contents!))".prefix(60)) }
    if let c = l.borderColor, l.borderWidth > 0 { d["border"] = [plain(c), l.borderWidth] }
    if l.shadowOpacity != 0 { d["shadow"] = [l.shadowOpacity, l.shadowRadius] }
    for k in ["scale", "marginWidth", "groupName", "captureOnly", "windowServerAware", "zoom", "allowsInPlaceFiltering", "tracksLuma",
              "usesGlobalGroupNamespace", "allowsGroupBlending", "allowsGroupOpacity", "effect", "effects", "foregroundColor",
              "fillColor", "contentsMultiplyColor", "sourceLayerRenderId", "allowsHitTesting", "colorMatrix", "bleedAmount", "statisticsType",
              "blurRadius", "saturation", "luminanceAmount", "colorMap"] {
        if let v = kv(l, k) {
            let p = plain(v)
            if let n = p as? NSNumber, k.hasPrefix("allows") || k == "captureOnly" || k == "zoom", n.doubleValue == (k == "allowsGroupOpacity" || k == "allowsHitTesting" ? 1 : 0) { continue }
            d[k] = p
        }
    }
    if let sl = l as? CAShapeLayer, let c = sl.fillColor { d["shapeFill"] = plain(c) }
    if let m = l.mask { d["mask"] = layerTree(m, depth + 1) }
    if depth < 40, let subs = l.sublayers, !subs.isEmpty { d["sublayers"] = subs.map { layerTree($0, depth + 1) } }
    return d
}
func viewTree(_ v: NSView, _ depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frame": [v.frame.minX, v.frame.minY, v.frame.width, v.frame.height]]
    if v.isHidden { d["hidden"] = true }
    if v.alphaValue != 1 { d["alpha"] = v.alphaValue }
    if depth < 20, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { viewTree($0, depth + 1) } }
    return d
}
// the layer that carries the glassBackground filter, with the index of the filter
func findGlass(_ root: CALayer) -> (CALayer, Int)? {
    if let fs = root.filters {
        for (i, f) in fs.enumerated() {
            if let o = f as? NSObject, (kv(o, "type") as? String) == "glassBackground" || (kv(o, "name") as? String) == "glassBackground" { return (root, i) }
        }
    }
    if let m = root.mask, let r = findGlass(m) { return r }
    for s in root.sublayers ?? [] { if let r = findGlass(s) { return r } }
    return nil
}
func glassInputs(_ root: CALayer) -> [String: Any] {
    guard let (l, i) = findGlass(root), let o = l.filters?[i] as? NSObject else { return [:] }
    var d = filterInfo(o)
    var b: [String: Any] = ["class": "\(type(of: l))"]
    for k in ["scale", "marginWidth", "groupName"] { if let v = kv(l, k) { b[k] = plain(v) } }
    d["backdrop"] = b
    return d
}

class Bands: NSView {
    var pattern = "rgb:127,127,127"
    var phase: CGFloat = 0
    var space: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    override var isFlipped: Bool { true }
    override func draw(_ dirty: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.setShouldAntialias(false)
        func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor { CGColor(colorSpace: space, components: [r / 255, g / 255, b / 255, 1])! }
        let r = bounds
        let p = pattern.split(separator: ":").map(String.init)
        let x0 = 650 + phase, y0 = 120 + phase
        switch p[0] {
        case "rgb":
            let c = p[1].split(separator: ",").map { CGFloat(Double($0) ?? 0) }
            ctx.setFillColor(col(c[0], c[1], c[2])); ctx.fill(r)
        case "edgeV":   // black left, white right, edge at x0
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255)); ctx.fill(NSRect(x: x0, y: 0, width: r.maxX - x0, height: r.height))
        case "edges3":  // white | black | white | black, edges at 230, 650, 1070 (+ phase)
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255))
            ctx.fill(NSRect(x: 0, y: 0, width: 230 + phase, height: r.height)); ctx.fill(NSRect(x: 650 + phase, y: 0, width: 420, height: r.height))
        case "edgeH":
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255)); ctx.fill(NSRect(x: 0, y: y0, width: r.width, height: r.maxY - y0))
        case "lineV":   // white line, width in device px
            let w = CGFloat(Double(p.count > 1 ? p[1] : "1") ?? 1) / 2
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255)); ctx.fill(NSRect(x: x0, y: 0, width: w, height: r.height))
        case "lineH":
            let w = CGFloat(Double(p.count > 1 ? p[1] : "1") ?? 1) / 2
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255)); ctx.fill(NSRect(x: 0, y: y0, width: r.width, height: w))
        case "dot":     // white square, side in device px
            let w = CGFloat(Double(p.count > 1 ? p[1] : "8") ?? 8) / 2
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255)); ctx.fill(NSRect(x: x0, y: y0, width: w, height: w))
        case "stripes": // period in device px (half white)
            let w = CGFloat(Double(p.count > 1 ? p[1] : "16") ?? 16) / 2
            ctx.setFillColor(col(0, 0, 0)); ctx.fill(r)
            ctx.setFillColor(col(255, 255, 255))
            var x = r.minX + phase
            while x < r.maxX { ctx.fill(NSRect(x: x, y: 0, width: w / 2, height: r.height)); x += w }
        default: break
        }
    }
}
class Win: NSWindow { override var canBecomeKey: Bool { true }; override var canBecomeMain: Bool { true } }
struct Item { let name: String; let variant: Int; let sub: String?; let clear: Bool; let frame: NSRect; let radius: CGFloat }

class D: NSObject, NSApplicationDelegate {
    var win: Win!
    var bg: Bands!
    var views: [(Item, NSGlassEffectView)] = []
    let screenH = NSScreen.screens[0].frame.height
    let W: CGFloat = 1300, H: CGFloat = 540
    let top = CGFloat(Double(ProcessInfo.processInfo.environment["G3_TOP"] ?? "60") ?? 60)
    let left = CGFloat(Double(ProcessInfo.processInfo.environment["G3_LEFT"] ?? "20") ?? 20)
    var patches: [NSView] = []
    // CAChameleonLayer patches: plain at opacity 1, colorBlendMode at opacity 1, colorBlendMode at opacity 0.1 (as in the sidebar)
    func addPatches() {
        guard let cls = NSClassFromString("CAChameleonLayer") as? CALayer.Type else { return }
        for (i, cfg) in [(nil as String?, Float(1)), ("colorBlendMode", 1), ("colorBlendMode", 0.1)].enumerated() {
            let v = NSView(frame: NSRect(x: 1130, y: 20 + CGFloat(i) * 80, width: 150, height: 60))
            v.wantsLayer = true
            let c = cls.init(); c.frame = v.bounds; c.opacity = cfg.1
            if let f = cfg.0 { c.compositingFilter = f }
            v.layer?.addSublayer(c)
            bg.addSubview(v); patches.append(v)
        }
    }
    var steps: [(Double, () -> Void)] = []
    var log: [[String: Any]] = []

    func capture(_ r: NSRect, _ path: String) {   // r in window coords (top-left origin, pt)
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-R", "\(Int(left + r.minX)),\(Int(top + r.minY)),\(Int(r.width)),\(Int(r.height))", path]
        try? p.run(); p.waitUntilExit()
    }
    func writeJSON(_ name: String, _ obj: Any) {
        if let d = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]) { try? d.write(to: URL(fileURLWithPath: "\(outDir)/\(name).json")) }
    }
    // The slider value is given at launch: append "-NSGlassTintAmount <a>" to the command line (argument domain; AppKit
    // reads UserDefaults.standard). Changing the argument domain later + _legibilityNeedsUpdate has no effect.
    func setTint(_ a: Float) {}
    func setItems(_ items: [Item]) {
        for (_, v) in views { v.removeFromSuperview() }
        views = []
        for it in items {
            let g = NSGlassEffectView(frame: it.frame)
            g.cornerRadius = it.radius
            g.setValue(it.variant, forKey: "_variant")
            if let sv = it.sub { g.setValue(sv, forKey: "_subvariant") }
            if it.clear { g.style = .clear }
            g.contentView = NSView(frame: NSRect(origin: .zero, size: it.frame.size))
            bg.addSubview(g); views.append((it, g))
        }
    }
    func itemsInfo() -> [[String: Any]] {
        views.map { (it, g) in
            var d: [String: Any] = ["name": it.name, "variant": it.variant, "rect": [it.frame.minX * 2, it.frame.minY * 2, it.frame.width * 2, it.frame.height * 2]]
            if let l = g.layer { d["glass"] = glassInputs(l) }
            return d
        }
    }
    func run() {
        guard !steps.isEmpty else { writeJSON("\(tag)-\(scenario)-log", log); NSApp.terminate(nil); return }
        let (t, f) = steps.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + t) { f(); self.run() }
    }
    func sbItems() -> [Item] {
        [Item(name: "regular", variant: 0, sub: nil, clear: false, frame: NSRect(x: 20, y: 20, width: 160, height: 64), radius: 20),
         Item(name: "sb17", variant: 17, sub: nil, clear: false, frame: NSRect(x: 200, y: 20, width: 160, height: 64), radius: 20),
         Item(name: "sb18", variant: 18, sub: nil, clear: false, frame: NSRect(x: 380, y: 20, width: 160, height: 64), radius: 20),
         Item(name: "sb17tall", variant: 17, sub: nil, clear: false, frame: NSRect(x: 580, y: 20, width: 240, height: 500), radius: 20),
         Item(name: "sb18tall", variant: 18, sub: nil, clear: false, frame: NSRect(x: 860, y: 20, width: 240, height: 500), radius: 20),
         Item(name: "regular200", variant: 0, sub: nil, clear: false, frame: NSRect(x: 20, y: 120, width: 200, height: 200), radius: 28),
         Item(name: "sb17_200", variant: 17, sub: nil, clear: false, frame: NSRect(x: 240, y: 120, width: 200, height: 200), radius: 28),
         Item(name: "sb18_200", variant: 18, sub: nil, clear: false, frame: NSRect(x: 240, y: 330, width: 200, height: 200), radius: 28)]
    }
    // override the filter of the first view: blur only
    func override(_ r: Double, _ s: Double) -> [String: Any] {
        guard let g = views.first?.1, let root = g.layer, let (l, i) = findGlass(root), var fs = l.filters, let o = (fs[i] as? NSObject)?.copy() as? NSObject else { return ["err": "no glass"] }
        let set: [String: Double] = ["inputBlurRadius": r, "inputBlurOpacity0": 1, "inputBlurOpacity1": 1, "inputBlurOpacity2": 1, "inputBlurOpacity3": 1,
            "inputBlurFillNormalOpacity": 0, "inputBlurFillDarkenOpacity": 0, "inputBlurFillLightenOpacity": 0, "inputFaceOpacity": 0,
            "inputBleedOpacity": 0, "inputInnerRefractionAmount": 0, "inputOuterRefractionAmount": 0, "inputRefractionOpacity": 0,
            "inputKeyFillHighlightAmount": 0, "inputShadowOpacity": 0, "inputRingShadowOpacity": 0, "inputSDRShadowOpacity": 0]
        for (k, v) in set { o.setValue(v, forKey: k) }
        if let e = extra.split(separator: "=").first, extra.contains("="), let v = Double(extra.split(separator: "=")[1]) { o.setValue(v, forKey: String(e)) }
        fs[i] = o
        CATransaction.begin(); CATransaction.setDisableActions(true)
        l.filters = fs
        if s > 0 { l.setValue(s, forKey: "scale") }
        CATransaction.commit()
        return [:]
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        win = Win(contentRect: NSRect(x: left, y: screenH - top - H, width: W, height: H), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false; win.isOpaque = true
        bg = Bands(frame: NSRect(x: 0, y: 0, width: W, height: H))
        if let cs = NSScreen.screens[0].colorSpace?.cgColorSpace { bg.space = cs }
        win.contentView = bg
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        let full = NSRect(x: 0, y: 0, width: W, height: H)
        func show(_ pat: String, _ ph: CGFloat = 0) { bg.pattern = pat; bg.phase = ph; bg.needsDisplay = true }

        if scenario == "tree" {
            steps.append((0.3, { self.setItems(self.sbItems()); self.addPatches(); show("rgb:127,127,127") }))
            for a in tints {
                steps.append((0.2, { self.setTint(a) }))
                steps.append((1.0, {
                    owner = [:]; mapViews(self.bg)
                    self.writeJSON("\(tag)-tree-a\(a)", ["mode": mode, "tint": a, "defaults": plain(UserDefaults.standard.object(forKey: "NSGlassTintAmount")),
                        "items": self.itemsInfo(), "views": viewTree(self.bg), "layers": self.bg.layer.map { layerTree($0) } ?? [:],
                        "windowLayerSuper": self.bg.layer?.superlayer.map { "\(type(of: $0))" } ?? "nil"])
                    self.capture(full, "\(outDir)/\(tag)-tree-a\(a).png")
                }))
            }
        }
        if scenario == "sb" {
            var cols: [String] = []
            for g in [0, 16, 32, 48, 64, 96, 127, 160, 192, 224, 255] { cols.append("\(g),\(g),\(g)") }
            cols += ["255,0,0", "0,255,0", "0,0,255", "230,140,40", "69,83,206", "40,160,90", "255,255,0", "0,255,255", "255,0,255"]
            var seed: UInt64 = 12345
            func rnd() -> Int { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return Int((seed >> 33) % 196) + 30 }
            for _ in 0..<30 { cols.append("\(rnd()),\(rnd()),\(rnd())") }
            steps.append((0.3, { self.setItems(self.sbItems()); self.addPatches(); show("rgb:127,127,127") }))
            for a in tints {
                steps.append((0.2, { self.setTint(a) }))
                steps.append((1.0, { self.writeJSON("\(tag)-sb-a\(a)", ["mode": mode, "tint": a, "items": self.itemsInfo(), "colors": cols]) }))
                for c in cols {
                    steps.append((0.0, { show("rgb:" + c) }))
                    steps.append((0.4, { self.capture(full, "\(outDir)/\(tag)-sb-a\(a)-\(c.replacingOccurrences(of: ",", with: "_")).png") }))
                }
            }
        }
        if scenario == "blur" {
            let item = Item(name: "blur", variant: 0, sub: nil, clear: false, frame: NSRect(x: 150, y: 20, width: 1000, height: 200), radius: 28)
            let radii: [Double] = extra.hasPrefix("r:") ? extra.dropFirst(2).split(separator: ",").compactMap { Double($0) } : [0, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 8, 12, 16, 24]
            let env = ProcessInfo.processInfo.environment
            let scales: [Double] = env["G3_SCALES"].map { $0.split(separator: ",").compactMap { Double($0) } } ?? [0.5, 0.25, 0.125, 1]
            let edgeOnly = env["G3_PATS"] == "edge"
            steps.append((0.3, { self.setItems([item]); show("edgeV") }))
            steps.append((1.0, { self.log.append(["natural": self.itemsInfo()]) }))
            var n = 0
            for s in scales { for r in radii {
                var pats: [(String, CGFloat)] = [("edgeV", 0), ("edgeV", 1.5), ("edgeV", 5), ("lineV:1", 0), ("lineV:1", 1.5), ("lineV:8", 0)]
                if edgeOnly { pats = [("edgeV", 0)] }
                if !edgeOnly, [2.0, 4, 8].contains(r) { pats += [("edgeH", 0), ("dot:8", 0), ("stripes:16", 0)] }
                for (pat, ph) in pats {
                    n += 1; let id = n
                    steps.append((0.0, { show(pat, ph); _ = self.override(r, s) }))
                    steps.append((0.35, {
                        _ = self.override(r, s)
                    }))
                    steps.append((0.12, {
                        let f = String(format: "%@-blur-%03d.png", tag, id)
                        let info = self.itemsInfo()
                        self.capture(item.frame, "\(outDir)/\(f)")
                        let gl = (info.first?["glass"] as? [String: Any]) ?? [:]
                        let inp = (gl["inputs"] as? [String: Any]) ?? [:]
                        self.log.append(["file": f, "pattern": pat, "phase": ph, "r": r, "s": s, "readR": inp["inputBlurRadius"] ?? NSNull(), "readOp0": inp["inputBlurOpacity0"] ?? NSNull(),
                                         "readFace": inp["inputFaceOpacity"] ?? NSNull(), "backdrop": gl["backdrop"] ?? NSNull(), "rect": [item.frame.minX, item.frame.minY, item.frame.width, item.frame.height]])
                    }))
                }
            } }
        }
        if scenario == "nat3" {   // panels of several heights, each centred on one edge of "edges3"
            func it(_ n: String, _ v: Int, _ sub: String?, _ col: Int, _ y: CGFloat, _ h: CGFloat) -> Item {
                Item(name: n, variant: v, sub: sub, clear: false, frame: NSRect(x: 30 + CGFloat(col) * 420, y: y, width: 400, height: h), radius: 28) }
            let items = [it("regular200", 0, nil, 0, 20, 200), it("regular300", 0, nil, 0, 230, 300),
                         it("regular120", 0, nil, 1, 20, 120), it("regular96", 0, nil, 1, 150, 96), it("menu160", 0, "menu", 1, 256, 160), it("regular64", 0, nil, 1, 426, 64),
                         it("sb17_200", 17, nil, 2, 20, 200), it("sb18_300", 18, nil, 2, 230, 300)]
            steps.append((0.3, { self.setItems(items); show("edges3") }))
            for a in tints {
                steps.append((1.2, { self.writeJSON("\(tag)-nat3-a\(a)", ["mode": mode, "tint": a, "items": self.itemsInfo()]) }))
                for (pat, ph) in [("edges3", CGFloat(0)), ("edges3", 3.5), ("rgb:255,255,255", 0), ("rgb:0,0,0", 0), ("rgb:127,127,127", 0)] {
                    steps.append((0.0, { show(pat, ph) }))
                    steps.append((0.5, { self.capture(full, "\(outDir)/\(tag)-nat3-a\(a)-\(pat.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: ",", with: "_"))-p\(ph).png") }))
                }
            }
        }
        if scenario == "nat" {
            let items = [Item(name: "regular", variant: 0, sub: nil, clear: false, frame: NSRect(x: 450, y: 20, width: 400, height: 64), radius: 28),
                         Item(name: "clear", variant: 0, sub: nil, clear: true, frame: NSRect(x: 450, y: 100, width: 400, height: 64), radius: 28),
                         Item(name: "dock", variant: 3, sub: nil, clear: false, frame: NSRect(x: 450, y: 180, width: 400, height: 64), radius: 28),
                         Item(name: "controlCenter", variant: 9, sub: nil, clear: false, frame: NSRect(x: 450, y: 260, width: 400, height: 64), radius: 28),
                         Item(name: "sidebar", variant: 17, sub: nil, clear: false, frame: NSRect(x: 450, y: 340, width: 400, height: 64), radius: 28),
                         Item(name: "regular200", variant: 0, sub: nil, clear: false, frame: NSRect(x: 30, y: 320, width: 400, height: 200), radius: 28),
                         Item(name: "regular120", variant: 0, sub: nil, clear: false, frame: NSRect(x: 450, y: 410, width: 400, height: 120), radius: 28),
                         Item(name: "controlCenter200", variant: 9, sub: nil, clear: false, frame: NSRect(x: 870, y: 320, width: 400, height: 200), radius: 28)]
            steps.append((0.3, { self.setItems(items); show("edgeV") }))
            for a in tints {
                steps.append((0.2, { self.setTint(a) }))
                steps.append((1.0, { self.writeJSON("\(tag)-nat-a\(a)", ["mode": mode, "tint": a, "items": self.itemsInfo()]) }))
                for (pat, ph) in [("edgeV", CGFloat(0)), ("edgeV", 1.5), ("edgeV", 5), ("lineV:1", 0), ("lineV:8", 0), ("stripes:16", 0), ("rgb:255,255,255", 0), ("rgb:0,0,0", 0)] {
                    steps.append((0.0, { show(pat, ph) }))
                    steps.append((0.45, { self.capture(full, "\(outDir)/\(tag)-nat-a\(a)-\(pat.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: ",", with: "_"))-p\(ph).png") }))
                }
            }
        }
        run()
    }
}
Timer.scheduledTimer(withTimeInterval: 420, repeats: false) { _ in print("timeout"); exit(2) }
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let d = D(); app.delegate = d; app.run()
