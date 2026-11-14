// glassr8: Mac REA round 8 probe (macOS 27.2.1). Wide glass shapes and a held SwiftUI slider knob; dumps the full
// layer tree with EVERY ObjC property of the private CA classes (CASDFLayer + its CASDF*Effect, CASDFElementLayer,
// CABackdropLayer, CAPortalLayer, ...) and every CAFilter input, captures the window, and runs causal toggles:
//   ovalOff  : gradientOvalization -> 0 on every CASDFElementLayer, recapture
//   ovalOne  : gradientOvalization -> 1, recapture
// Extra shapes (right bottom) only record which gradientOvalization each shape gets.
// then holds the SwiftUI Slider knob with an in-process synthetic mouse-down (NSWindow.sendEvent, own window only),
// dumps and captures while held, and releases.
// Build: swiftc -swift-version 5 -O -o glassr8 glassr8.swift
// Run:   glassr8 <outdir> <dark|light> [grey 0..255 backdrop] [sweep]
//   sweep: only a grid of SwiftUI rounded rects (width x height x radius) -> log-<mode>-sweep.json with the
//          gradientOvalization each one gets, then quit.
import AppKit
import SwiftUI
import QuartzCore
import ObjectiveC

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "."
let mode = args.count > 2 ? args[2] : "dark"
let grey = args.count > 3 ? CGFloat(Double(args[3]) ?? 128) / 255 : 0.5
let sweep = args.count > 4 && args[4] == "sweep"
let sweepSizes: [(CGFloat, CGFloat, CGFloat)] = [(300, 56, 12), (300, 63, 12), (300, 64, 12), (300, 65, 12), (300, 80, 12), (300, 100, 12),
    (300, 120, 12), (64, 64, 12), (65, 65, 12), (80, 80, 12), (100, 100, 20), (64, 300, 12), (300, 100, 50), (300, 100, 0), (500, 90, 24), (520, 87, 22)]
let L: CGFloat = 40, T: CGFloat = 80          // window content origin on screen (pt, top-left)
let W: CGFloat = 1360, H: CGFloat = 640

func plain(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    let cf = v as CFTypeRef
    if CFGetTypeID(cf) == CGColor.typeID {
        let c = v as! CGColor
        return ["space": (c.colorSpace?.name as String?) ?? "?", "c": (c.components ?? []).map { Double($0) }] as [String: Any]
    }
    if CFGetTypeID(cf) == CGPath.typeID { return "CGPath \((v as! CGPath).boundingBox)" }
    if CFGetTypeID(cf) == CGImage.typeID { let i = v as! CGImage; return "CGImage \(i.width)x\(i.height) bpc \(i.bitsPerComponent)" }
    if let a = v as? [Any] { return a.map { plain($0) } }
    if let d = v as? [String: Any] { return d.mapValues { plain($0) } }
    if let nv = v as? NSValue {
        var size = 0, align = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &align)
        let enc = String(cString: nv.objCType)
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fdcislqCISLQB".contains($0) }
        if size > 0, size <= 256, !kinds.isEmpty, kinds.allSatisfy({ $0 == "d" }) {
            var buf = [UInt8](repeating: 0, count: size); nv.getValue(&buf, size: size)
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Double.self)) }
        }
        if size > 0, size <= 256, !kinds.isEmpty, kinds.allSatisfy({ $0 == "f" }) {
            var buf = [UInt8](repeating: 0, count: size); nv.getValue(&buf, size: size)
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }.map { Double($0) }
        }
        return "\(enc): \(nv)"
    }
    if let o = v as? NSObject, NSStringFromClass(type(of: o)).hasPrefix("CASDF") { return allProps(o) }
    return String(String(describing: v).prefix(400))
}
// every declared ObjC property of the object's class chain, stopping at CALayer / NSObject (those are dumped by hand)
func allProps(_ o: NSObject) -> [String: Any] {
    var d: [String: Any] = ["_class": NSStringFromClass(type(of: o))]
    var c: AnyClass? = type(of: o)
    while let cc = c, cc != CALayer.self, cc != NSObject.self {
        var n: UInt32 = 0
        if let ps = class_copyPropertyList(cc, &n) {
            for i in 0..<Int(n) {
                let name = String(cString: property_getName(ps[i]))
                if name == "delegate" || name == "superlayer" || name == "sourceLayer" { continue }
                if o.responds(to: NSSelectorFromString(name)) { d[name] = plain(o.value(forKey: name)) }
            }
            free(ps)
        }
        c = class_getSuperclass(cc)
    }
    return d
}
func kv(_ o: NSObject, _ k: String) -> Any? { o.responds(to: NSSelectorFromString(k)) ? o.value(forKey: k) : nil }
func filterInfo(_ f: Any) -> [String: Any] {
    guard let o = f as? NSObject else { return ["?": String(describing: f)] }
    var d: [String: Any] = ["class": NSStringFromClass(type(of: o))]
    for k in ["name", "type", "enabled", "cachesInputImage"] { if let v = kv(o, k) { d[k] = plain(v) } }
    if let ks = kv(o, "inputKeys") as? [String] {
        var inp: [String: Any] = [:]
        for k in ks { inp[k] = plain(o.value(forKey: k)) }
        d["inputs"] = inp
    }
    if let ks = kv(o, "outputKeys") as? [String], !ks.isEmpty { d["outputKeys"] = ks }
    return d
}
var owner: [ObjectIdentifier: NSView] = [:]
func mapViews(_ v: NSView) { if let l = v.layer { owner[ObjectIdentifier(l)] = v }; v.subviews.forEach(mapViews) }
func layerTree(_ l: CALayer, _ depth: Int = 0) -> [String: Any] {
    let cls = NSStringFromClass(type(of: l))
    var d: [String: Any] = ["class": cls, "frame": [l.frame.minX, l.frame.minY, l.frame.width, l.frame.height]]
    if let v = owner[ObjectIdentifier(l)] { d["view"] = NSStringFromClass(type(of: v)) }
    if let n = l.name { d["name"] = n }
    if l.opacity != 1 { d["opacity"] = l.opacity }
    if l.isHidden { d["hidden"] = true }
    if let c = l.backgroundColor { d["backgroundColor"] = plain(c) }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius; d["cornerCurve"] = l.cornerCurve.rawValue }
    if l.masksToBounds { d["masksToBounds"] = true }
    if !CATransform3DIsIdentity(l.transform) { d["transform"] = "\(l.transform)" }
    if let cf = l.compositingFilter { d["compositingFilter"] = (cf as? String) ?? filterInfo(cf) }
    if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map(filterInfo) }
    if let fs = l.backgroundFilters, !fs.isEmpty { d["backgroundFilters"] = fs.map(filterInfo) }
    if let c = l.contents { d["contents"] = plain(c) }
    if let m = kv(l, "meshTransform") { d["meshTransform"] = String(describing: m).prefix(200) }
    if let c = l.borderColor, l.borderWidth > 0 { d["border"] = [plain(c), l.borderWidth] }
    if l.shadowOpacity != 0 { d["shadow"] = [l.shadowOpacity, l.shadowRadius, l.shadowOffset.width, l.shadowOffset.height] }
    if let sl = l as? CAShapeLayer { d["shape"] = ["fill": plain(sl.fillColor), "path": plain(sl.path)] }
    if let ks = l.animationKeys(), !ks.isEmpty { d["animations"] = ks }
    if cls.hasPrefix("CA") && cls != "CALayer" && cls != "CAShapeLayer" && cls != "CATransformLayer" || cls.contains("SDF") || cls.contains("Lift") {
        d["props"] = allProps(l)
    }
    if let m = l.mask { d["mask"] = layerTree(m, depth + 1) }
    if depth < 60, let subs = l.sublayers, !subs.isEmpty { d["sublayers"] = subs.map { layerTree($0, depth + 1) } }
    return d
}
func walk(_ l: CALayer, _ f: (CALayer) -> Void) { f(l); if let m = l.mask { walk(m, f) }; (l.sublayers ?? []).forEach { walk($0, f) } }

class Win: NSWindow { override var canBecomeKey: Bool { true }; override var canBecomeMain: Bool { true } }

var sliderValue = 0.5
struct Panel: View {
    let v = Binding<Double>(get: { sliderValue }, set: { sliderValue = $0 })
    var body: some View {
        if sweep { return AnyView(ZStack(alignment: .topLeading) {
            Color(white: grey)
            ForEach(0..<sweepSizes.count, id: \.self) { i in
                let (w, h, r) = sweepSizes[i]
                Color.clear.frame(width: w, height: h).glassEffect(.regular, in: RoundedRectangle(cornerRadius: r))
                    .offset(x: CGFloat(i % 4) * 330 + 10, y: CGFloat(i / 4) * 150 + 10)
            }
        }.frame(width: W, height: H, alignment: .topLeading)) }
        return AnyView(ZStack(alignment: .topLeading) {
            Color(white: grey)
            // A: wide capsule (Spotlight bar like), B: wide rounded rect (Spotlight results like)
            Capsule().fill(Color.clear).frame(width: 640, height: 56).glassEffect(.regular, in: Capsule()).offset(x: 40, y: 40)
            Color.clear.frame(width: 640, height: 260).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24)).offset(x: 40, y: 130)
            // E: white fill with a SwiftUI Slider on it, F: Slider on the grey
            Color.white.frame(width: 400, height: 80).offset(x: 40, y: 430)
            Slider(value: v).frame(width: 300).offset(x: 90, y: 458)
            Slider(value: v).frame(width: 300).offset(x: 90, y: 560)
            // extra shapes: which gradientOvalization does each get?
            Color.clear.frame(width: 300, height: 56).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28)).offset(x: 480, y: 430)
            Color.clear.frame(width: 300, height: 56).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12)).offset(x: 480, y: 500)
            Color.clear.frame(width: 56, height: 56).glassEffect(.regular, in: Circle()).offset(x: 480, y: 570)
            Color.clear.frame(width: 120, height: 56).glassEffect(.regular, in: Ellipse()).offset(x: 560, y: 570)
            Color.clear.frame(width: 300, height: 56).glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12)).offset(x: 800, y: 430)
            Color.clear.frame(width: 300, height: 56).glassEffect(.regular, in: Rectangle()).offset(x: 800, y: 500)
            Color.clear.frame(width: 300, height: 56).glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12)).offset(x: 800, y: 570)
        }.frame(width: W, height: H, alignment: .topLeading))
    }
}

class D: NSObject, NSApplicationDelegate {
    var win: Win!
    var host: NSHostingView<Panel>!
    var steps: [(Double, () -> Void)] = []
    var log: [String: Any] = [:]
    func writeJSON(_ name: String, _ obj: Any) {
        if let d = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys, .prettyPrinted]) { try? d.write(to: URL(fileURLWithPath: "\(outDir)/\(name).json")) }
    }
    func capture(_ name: String) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-o", "-l", "\(win.windowNumber)", "\(outDir)/\(name).png"]
        try? p.run(); p.waitUntilExit()
    }
    func dump(_ name: String) {
        owner = [:]; mapViews(win.contentView!)
        writeJSON(name, ["mode": mode, "grey": grey, "windowOrigin": [L, T], "layers": layerTree(win.contentView!.superview!.layer ?? win.contentView!.layer!)])
    }
    func elements() -> [CALayer] { var r: [CALayer] = []; walk(win.contentView!.superview!.layer!) { if NSStringFromClass(type(of: $0)) == "CASDFElementLayer" { r.append($0) } }; return r }
    func sdfLayers() -> [CALayer] { var r: [CALayer] = []; walk(win.contentView!.superview!.layer!) { if NSStringFromClass(type(of: $0)) == "CASDFLayer" { r.append($0) } }; return r }
    func elemInfo(_ e: CALayer) -> [String: Any] {
        let r = e.convert(e.bounds, to: win.contentView!.layer!)
        return ["inWindow": [r.minX, r.minY, r.width, r.height], "cornerRadius": e.cornerRadius, "cornerCurve": e.cornerCurve.rawValue,
                "oval": plain(e.value(forKey: "gradientOvalization"))]
    }
    var savedOval: [(CALayer, Any?)] = []
    func setOval(_ v: Double) {
        CATransaction.begin(); CATransaction.setDisableActions(true)
        for e in elements() { e.setValue(v, forKey: "gradientOvalization") }
        CATransaction.commit()
    }
    func restoreOval() { CATransaction.begin(); CATransaction.setDisableActions(true); for (e, v) in savedOval { e.setValue(v, forKey: "gradientOvalization") }; CATransaction.commit() }
    // slider knob centre in window coords: find the LiftLayer / knob by walking views is fragile; use the slider frame
    func knobPoint(_ yTop: CGFloat) -> NSPoint { NSPoint(x: 90 + 150, y: H - (yTop + 11)) }   // value 0.5 -> middle
    func mouse(_ t: NSEvent.EventType, _ p: NSPoint) -> NSEvent {
        NSEvent.mouseEvent(with: t, location: p, modifierFlags: [], timestamp: ProcessInfo.processInfo.systemUptime,
                           windowNumber: win.windowNumber, context: nil, eventNumber: 0, clickCount: 1, pressure: t == .leftMouseUp ? 0 : 1)!
    }
    func hold(_ tag: String, _ yTop: CGFloat, then: @escaping () -> Void) {
        let p = knobPoint(yTop)
        let tm = Timer(timeInterval: 0.6, repeats: false) { _ in
            self.dump("tree-\(mode)-held-\(tag)")
            self.capture("cap-\(mode)-held-\(tag)")
            NSApp.postEvent(self.mouse(.leftMouseUp, p), atStart: false)
        }
        RunLoop.main.add(tm, forMode: .common)
        let tm2 = Timer(timeInterval: 0.25, repeats: false) { _ in       // a tiny move keeps it pressed, no value jump
            NSApp.postEvent(self.mouse(.leftMouseDragged, NSPoint(x: p.x + 0.5, y: p.y)), atStart: false)
        }
        RunLoop.main.add(tm2, forMode: .common)
        win.sendEvent(mouse(.leftMouseDown, p))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: then)
    }
    func run() {
        guard !steps.isEmpty else { writeJSON("log-\(mode)", log); NSApp.terminate(nil); return }
        let (t, f) = steps.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + t) { f(); self.run() }
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        let sh = NSScreen.screens[0].frame.height
        win = Win(contentRect: NSRect(x: L, y: sh - T - H, width: W, height: H), styleMask: [.titled], backing: .buffered, defer: false)
        win.title = "glassr8"
        host = NSHostingView(rootView: Panel())
        host.frame = NSRect(x: 0, y: 0, width: W, height: H)
        let root = NSView(frame: host.frame); root.wantsLayer = true
        root.addSubview(host)
        // C / D: AppKit NSGlassEffectView, same sizes
        for (fr, r) in sweep ? [] : [(NSRect(x: 720, y: H - 40 - 56, width: 600, height: 56), CGFloat(28)), (NSRect(x: 720, y: H - 130 - 260, width: 600, height: 260), 24)] {
            let g = NSGlassEffectView(frame: fr); g.cornerRadius = r; g.contentView = NSView(frame: NSRect(origin: .zero, size: fr.size)); root.addSubview(g)
        }
        win.contentView = root
        win.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        if sweep {
            steps = [(2.0, { self.writeJSON("log-\(mode)-sweep", ["sizes": sweepSizes.map { [$0.0, $0.1, $0.2] }, "elements": self.elements().map { self.elemInfo($0) }]) })]
            run(); return
        }
        steps = [
            (2.0, { self.dump("tree-\(mode)"); self.capture("cap-\(mode)") }),
            (0.2, { self.savedOval = self.elements().map { ($0, $0.value(forKey: "gradientOvalization")) }
                    self.log["elements"] = self.elements().map { self.elemInfo($0) }
                    self.setOval(0) }),
            (0.6, { self.capture("cap-\(mode)-oval0") }),
            (0.1, { self.setOval(1) }),
            (0.6, { self.capture("cap-\(mode)-oval1") }),
            (0.1, { self.restoreOval() }),
            (0.6, { self.capture("cap-\(mode)-restored") }),
            (0.3, { self.hold("white", 458) { } }),
            (1.2, { self.hold("grey", 560) { } }),
            (1.2, { }),
        ]
        run()
    }
}
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D(); app.delegate = d
app.run()
