// glassfit: controlled Liquid Glass measurements.
// glassfit <config.json>
// A borderless window with a pixel-exact test pattern, NSGlassEffectViews on top, optional overrides of the
// CABackdropLayer `glassBackground` filter inputs (to isolate one term of the shader), and a JSON dump of every
// filter input and CASDF effect (including the key/fill highlight colours).
// The window can become key (inactive windows get a different recipe: no outer refraction, no shadow, spread 120 deg);
// "policy": "accessory" + "activate": false keeps it inactive on purpose.
// config: { "mode": "dark"|"light", "pattern": "grad"|"gradx"|"grady"|"checker:N"|"grid:N"|"vstripes:N"|"hstripes:N"|"solid:r,g,b"|
//           "cols:r,g,b:r,g,b:...", "origin": [x, yTop], "size": [w, h], "secs": 8, "dump": "/path.json", "level": "normal"|"desktop",
//           "views": [ { "frame": [x, yTop, w, h], "radius": 20, "variant": 0, "subvariant": "menu", "clear": false,
//                        "override": { "inputBlurRadius": 0 }, "hideHighlight": false, "tint": [r,g,b,a] } ],
//                        "kv": { "_contentLensing": true }, "contentPattern": "grad", "contentInset": 0 } ],
//           "dumpWindowsAt": [2.5], "popupMenu": [x, yTop],
//           "controls": [ { "kind": "glassButton"|"switch"|"slider", "frame": [x, yTop, w, h] } ] }
// Pattern "grad": R = x px mod 256, G = y px mod 256, B = 128, drawn in the display colour space, so a captured pixel
// gives back the source position that the glass sampled.
import AppKit

let cfgPath = CommandLine.arguments[1]
let cfg = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: cfgPath))) as! [String: Any]
func num(_ a: Any?) -> CGFloat { CGFloat((a as? NSNumber)?.doubleValue ?? 0) }
func arr(_ a: Any?) -> [CGFloat] { ((a as? [Any]) ?? []).map { num($0) } }

func jsonable(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID {
        let c = v as! CGColor
        return ["color": (c.components ?? []).map { Double($0) }, "space": (c.colorSpace?.name as String?) ?? "?"]
    }
    if let a = v as? [Any] { return a.map { jsonable($0) } }
    if let nv = v as? NSValue {
        var size = 0, align = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &align)
        let enc = String(cString: nv.objCType)
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fd".contains($0) }
        if size > 0, size <= 1024, !kinds.isEmpty {
            var buf = [UInt8](repeating: 0, count: size)
            nv.getValue(&buf, size: size)
            if kinds.first == "f" { return buf.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }.map { Double($0) } }
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Double.self)) }
        }
    }
    return String(describing: v)
}
func props(_ obj: NSObject, stop: AnyClass) -> [String: Any] {
    var out: [String: Any] = [:]
    var c: AnyClass? = type(of: obj)
    while let cls = c, cls != stop {
        var n: UInt32 = 0
        if let list = class_copyPropertyList(cls, &n) {
            for i in 0..<Int(n) {
                let name = String(cString: property_getName(list[i]))
                let attrs = String(cString: property_getAttributes(list[i])!)
                guard let t = attrs.dropFirst().first, "cislqCISLQfdB@{^".contains(t), out[name] == nil else { continue }
                if ["hash", "superclass", "description", "debugDescription"].contains(name) { continue }
                if obj.responds(to: NSSelectorFromString(name)) { out[name] = jsonable(obj.value(forKey: name)) }
            }
            free(list)
        }
        c = class_getSuperclass(cls)
    }
    return out
}
func dumpLayer(_ l: CALayer) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: l))", "name": l.name ?? "", "frame": [l.frame.minX, l.frame.minY, l.frame.width, l.frame.height],
                            "opacity": l.opacity, "hidden": l.isHidden]
    if let fs = l.filters, !fs.isEmpty {
        d["filters"] = fs.map { f -> Any in
            guard let o = f as? NSObject else { return "\(f)" }
            var fd: [String: Any] = ["name": jsonable(o.value(forKey: "name")), "type": jsonable(o.value(forKey: "type"))]
            if let ks = o.value(forKey: "inputKeys") as? [String] {
                var ins: [String: Any] = [:]
                for k in ks { if let v = o.value(forKey: k) { ins[k] = jsonable(v) } }
                fd["inputs"] = ins
            }
            return fd
        }
    }
    if let cf = l.compositingFilter { d["compositingFilter"] = "\(cf)" }
    if let bc = l.backgroundColor { d["backgroundColor"] = jsonable(bc) }
    if let bc = l.borderColor, l.borderWidth > 0 { d["border"] = [jsonable(bc), l.borderWidth] }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius; d["cornerCurve"] = l.cornerCurve.rawValue }
    if l.masksToBounds { d["masksToBounds"] = true }
    if !CATransform3DIsIdentity(l.transform) { let t = l.transform; d["transform"] = [t.m11, t.m12, t.m21, t.m22, t.m41, t.m42] }
    if l.contents != nil { d["contents"] = "\(type(of: l.contents!))"; d["contentsMultiplyColor"] = jsonable(l.value(forKey: "contentsMultiplyColor")) }
    if l.mask != nil { d["mask"] = dumpLayer(l.mask!) }
    if l.shadowOpacity > 0 { d["shadow"] = [Double(l.shadowOpacity), Double(l.shadowRadius), Double(l.shadowOffset.width), Double(l.shadowOffset.height)] }
    if l.responds(to: NSSelectorFromString("effect")), let e = l.value(forKey: "effect") as? NSObject {
        var ed = props(e, stop: NSObject.self); ed["class"] = "\(type(of: e))"; d["effect"] = ed
    }
    if "\(type(of: l))".contains("Backdrop") {
        var bd: [String: Any] = [:]
        for k in ["scale", "marginWidth", "groupName", "captureOnly", "zoom"] where l.responds(to: NSSelectorFromString(k)) { bd[k] = jsonable(l.value(forKey: k)) }
        d["backdrop"] = bd
    }
    if "\(type(of: l))".contains("SDF") {
        var sd: [String: Any] = [:]
        for k in ["smoothness", "cornerRadius", "cornerCurve", "shape", "path"] where l.responds(to: NSSelectorFromString(k)) { sd[k] = jsonable(l.value(forKey: k)) }
        d["sdf"] = sd
    }
    if let s = l.sublayers, !s.isEmpty { d["sublayers"] = s.map { dumpLayer($0) } }
    return d
}

func makePattern(_ spec: String, _ wpx: Int, _ hpx: Int, _ cs: CGColorSpace) -> CGImage {
    var px = [UInt8](repeating: 255, count: wpx * hpx * 4)
    let parts = spec.split(separator: ":").map(String.init)
    func rgb(_ s: String) -> [UInt8] { s.split(separator: ",").map { UInt8(Int($0)!) } }
    for y in 0..<hpx {
        for x in 0..<wpx {
            var c: [UInt8] = [0, 0, 0]
            switch parts[0] {
            case "grad": c = [UInt8(x & 255), UInt8(y & 255), 128]
            case "gradx": let v = UInt8(x & 255); c = [v, v, v]
            case "grady": let v = UInt8(y & 255); c = [v, v, v]
            case "checker": let n = Int(parts[1])!; let v: UInt8 = ((x / n + y / n) & 1) == 0 ? 255 : 0; c = [v, v, v]
            case "grid": let n = Int(parts[1])!; let v: UInt8 = (x % n == 0 || y % n == 0) ? 255 : 0; c = [v, v, v]
            case "vstripes": let n = Int(parts[1])!; let v: UInt8 = ((x / n) & 1) == 0 ? 255 : 0; c = [v, v, v]
            case "hstripes": let n = Int(parts[1])!; let v: UInt8 = ((y / n) & 1) == 0 ? 255 : 0; c = [v, v, v]
            case "solid": c = rgb(parts[1])
            case "hsplit": c = x < wpx / 2 ? rgb(parts[1]) : rgb(parts[2])
            case "vsplit": c = y < hpx / 2 ? rgb(parts[1]) : rgb(parts[2])
            case "cols": let k = parts.count - 1; c = rgb(parts[1 + min(k - 1, x * k / wpx)])
            default: break
            }
            let i = (y * wpx + x) * 4
            px[i] = c[0]; px[i + 1] = c[1]; px[i + 2] = c[2]
        }
    }
    let ctx = CGContext(data: &px, width: wpx, height: hpx, bitsPerComponent: 8, bytesPerRow: wpx * 4, space: cs,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    return ctx.makeImage()!
}

class Flipped: NSView { override var isFlipped: Bool { true } }
class KeyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class D: NSObject, NSApplicationDelegate {
    var win: NSWindow!
    var glasses: [(NSView, [String: Any])] = []
    var isolated: [NSView] = []
    var resets = 0
    func find(_ l: CALayer, _ pred: (CALayer) -> Bool, _ out: inout [CALayer]) {
        if pred(l) { out.append(l) }
        for s in l.sublayers ?? [] { find(s, pred, &out) }
    }
    // hides everything in a control except its glass lens group, so the lens refracts the test pattern
    func isolateLens(_ v: NSView) {
        guard let root = v.layer else { return }
        var ls: [CALayer] = []
        find(root, { ($0.filters ?? []).contains { (($0 as? NSObject)?.value(forKey: "name") as? String) == "glassBackground" } }, &ls)
        guard let k = ls.first?.superlayer else { return }
        var keep = Set<ObjectIdentifier>()
        var a: CALayer? = k
        while let x = a { keep.insert(ObjectIdentifier(x)); a = x.superlayer }
        func walk(_ l: CALayer, _ inside: Bool) {
            let ins = inside || l === k
            if !ins && !keep.contains(ObjectIdentifier(l)) { if !l.isHidden { l.isHidden = true; resets += 1 }; return }
            for s in l.sublayers ?? [] { walk(s, ins) }
        }
        walk(root, false)
        // remove the lens's own shading (ring shadow, dark specular, key/fill highlight) so only the geometry is left
        guard flatLens else { return }
        for l in ls {
            for k in ["inputRingShadowOpacity", "inputShadowOpacity", "inputKeyFillHighlightHeight", "inputSDRShadowOpacity"] {
                let kp = "filters.glassBackground.\(k)"
                if let cur = l.value(forKeyPath: kp) as? NSNumber, abs(cur.doubleValue) > 1e-6 { l.setValue(0, forKeyPath: kp); resets += 1 }
            }
        }
        var hs: [CALayer] = []
        find(k, { $0.responds(to: NSSelectorFromString("effect")) && "\(type(of: $0.value(forKey: "effect") ?? 0))".contains("Highlight") }, &hs)
        for l in hs where !l.isHidden { l.isHidden = true; resets += 1 }
    }
    var flatLens: Bool { (cfg["flatLens"] as? Bool) == true }
    func applyOverrides() {
        for v in isolated { isolateLens(v) }
        for (g, vc) in glasses {
            guard let root = g.layer else { continue }
            if let ov = vc["override"] as? [String: Any] {
                var ls: [CALayer] = []
                find(root, { ($0.filters ?? []).contains { (($0 as? NSObject)?.value(forKey: "name") as? String) == "glassBackground" } }, &ls)
                for l in ls {
                    for (k, v) in (vc["layerKV"] as? [String: Any]) ?? [:] {
                        if let nv = v as? NSNumber, let cur = l.value(forKey: k) as? NSNumber, abs(cur.doubleValue - nv.doubleValue) > 1e-6 { l.setValue(nv, forKey: k); resets += 1 }
                    }
                    for (k, v) in ov {
                        let kp = "filters.glassBackground.\(k)"
                        let cur = l.value(forKeyPath: kp) as? NSNumber
                        if let nv = v as? NSNumber, cur == nil || abs(cur!.doubleValue - nv.doubleValue) > 1e-6 { l.setValue(nv, forKeyPath: kp); resets += 1 }
                    }
                }
            }
            if (vc["hideHighlight"] as? Bool) == true {
                var ls: [CALayer] = []
                find(root, { $0.responds(to: NSSelectorFromString("effect")) && "\(type(of: $0.value(forKey: "effect") ?? 0))".contains("Highlight") }, &ls)
                for l in ls where !l.isHidden { l.isHidden = true; resets += 1 }
            }
            if let eo = vc["effect"] as? [String: Any] {
                var ls: [CALayer] = []
                find(root, { $0.responds(to: NSSelectorFromString("effect")) && "\(type(of: $0.value(forKey: "effect") ?? 0))".contains("Highlight") }, &ls)
                for l in ls {
                    guard let e = l.value(forKey: "effect") as? NSObject, let c = e.copy() as? NSObject else { continue }
                    var changed = false
                    for (k, v) in eo { if let nv = v as? NSNumber, let cur = c.value(forKey: k) as? NSNumber, abs(cur.doubleValue - nv.doubleValue) > 1e-6 { c.setValue(nv, forKey: k); changed = true } }
                    if changed { l.setValue(c, forKey: "effect"); resets += 1 }
                }
            }
        }
    }
    @objc func noop() {}
    func applicationDidFinishLaunching(_ n: Notification) {
        let mode = cfg["mode"] as? String ?? "dark"
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        let scr = NSScreen.screens[0]
        let o = arr(cfg["origin"]), sz = arr(cfg["size"])
        let W = sz[0], H = sz[1]
        win = KeyWindow(contentRect: NSRect(x: o[0], y: scr.frame.height - o[1] - H, width: W, height: H), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false
        win.isOpaque = true
        if (cfg["level"] as? String) == "desktop" { win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1) }
        if (cfg["level"] as? String) == "floating" { win.level = .floating }
        win.colorSpace = scr.colorSpace
        let bg = Flipped(frame: NSRect(x: 0, y: 0, width: W, height: H))
        bg.wantsLayer = true
        let cs = scr.colorSpace?.cgColorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let img = makePattern(cfg["pattern"] as? String ?? "grad", Int(W * 2), Int(H * 2), cs)
        let pat = Flipped(frame: bg.bounds); pat.wantsLayer = true
        pat.layer?.contents = img; pat.layer?.contentsScale = 2; pat.layer?.magnificationFilter = .nearest; pat.layer?.minificationFilter = .nearest
        pat.layer?.contentsGravity = .resize
        bg.addSubview(pat)
        for any in (cfg["views"] as? [Any]) ?? [] {
            let vc = any as! [String: Any]
            let f = arr(vc["frame"])
            let gv = NSGlassEffectView(frame: NSRect(x: f[0], y: f[1], width: f[2], height: f[3]))
            gv.cornerRadius = num(vc["radius"])
            if let va = vc["variant"] as? NSNumber { gv.setValue(va, forKey: "_variant") }
            if let sv = vc["subvariant"] as? String { gv.setValue(sv, forKey: "_subvariant") }
            if (vc["clear"] as? Bool) == true { gv.style = .clear }
            if let t = vc["tint"] as? [Any] { let c = t.map { num($0) }; gv.tintColor = NSColor(srgbRed: c[0], green: c[1], blue: c[2], alpha: c[3]) }
            for (k, v) in (vc["kv"] as? [String: Any]) ?? [:] { gv.setValue(v, forKey: k) }
            let cv = NSView(frame: gv.bounds)
            if let label = vc["label"] as? String {
                let tf = NSTextField(labelWithString: label); tf.font = .systemFont(ofSize: num(vc["labelSize"]) > 0 ? num(vc["labelSize"]) : 20, weight: .semibold)
                tf.sizeToFit(); tf.frame.origin = NSPoint(x: 12, y: (f[3] - tf.frame.height) / 2); cv.addSubview(tf)
            }
            // "contentPattern": a test pattern drawn as the glass CONTENT (to measure content lensing, glassForeground)
            if let cp = vc["contentPattern"] as? String {
                let ins = num(vc["contentInset"])
                let pv = Flipped(frame: cv.bounds.insetBy(dx: ins, dy: ins)); pv.wantsLayer = true
                pv.layer?.contents = makePattern(cp, Int(pv.frame.width * 2), Int(pv.frame.height * 2), cs); pv.layer?.contentsScale = 2
                pv.layer?.magnificationFilter = .nearest; pv.layer?.minificationFilter = .nearest; pv.layer?.contentsGravity = .resize
                cv.addSubview(pv)
            }
            gv.contentView = cv
            bg.addSubview(gv)
            glasses.append((gv, vc))
        }
        for any in (cfg["controls"] as? [Any]) ?? [] {
            let cc = any as! [String: Any]
            let f = arr(cc["frame"]); let fr = NSRect(x: f[0], y: f[1], width: f[2], height: f[3])
            let before = bg.subviews.count
            defer { if (cc["isolateLens"] as? Bool) == true, bg.subviews.count > before { isolated.append(bg.subviews.last!) } }
            switch cc["kind"] as? String ?? "" {
            case "glassButton":
                let b = NSButton(title: cc["title"] as? String ?? "Glass", target: nil, action: nil); b.bezelStyle = .glass; b.frame = fr
                if let cs = cc["controlSize"] as? NSNumber { b.controlSize = NSControl.ControlSize(rawValue: cs.uintValue)! }
                bg.addSubview(b)
            case "switch":
                let s = NSSwitch(frame: fr); s.state = (cc["on"] as? Bool) == true ? .on : .off
                if let cs = cc["controlSize"] as? NSNumber { s.controlSize = NSControl.ControlSize(rawValue: cs.uintValue)!; s.sizeToFit(); s.frame.origin = fr.origin }
                bg.addSubview(s)
            case "slider":
                let s = NSSlider(value: Double(num(cc["value"])), minValue: 0, maxValue: 1, target: nil, action: nil); s.frame = fr; bg.addSubview(s)
            default: break
            }
        }
        win.contentView = bg
        win.makeKeyAndOrderFront(nil)
        if (cfg["activate"] as? Bool) != false { NSApp.activate(ignoringOtherApps: true) }
        let ot = Timer(timeInterval: 0.05, repeats: true) { _ in self.applyOverrides() }
        RunLoop.main.add(ot, forMode: .common)
        // "dumpAt": [seconds]: dumps the whole content layer tree (controls included) while e.g. a knob is held
        for (i, t) in arr(cfg["dumpAt"]).enumerated() {
            let dt = Timer(timeInterval: Double(t), repeats: false) { _ in
                guard let p = cfg["dump"] as? String, let root = self.win.contentView?.layer else { return }
                let data = try! JSONSerialization.data(withJSONObject: dumpLayer(root), options: [.prettyPrinted, .sortedKeys])
                try! data.write(to: URL(fileURLWithPath: p.replacingOccurrences(of: ".json", with: ".t\(i).json")))
                print("DUMP \(i)"); fflush(stdout)
            }
            RunLoop.main.add(dt, forMode: .common)
        }
        // "dumpWindowsAt": [seconds]: dumps the layer trees of all OTHER windows of this app (an open menu is one)
        for (i, t) in arr(cfg["dumpWindowsAt"]).enumerated() {
            let dt = Timer(timeInterval: Double(t), repeats: false) { _ in
                guard let p = cfg["dump"] as? String else { return }
                var out: [Any] = []
                for w in NSApp.windows where w !== self.win && w.isVisible {
                    var wd: [String: Any] = ["class": "\(type(of: w))", "frame": [w.frame.minX, scr.frame.height - w.frame.maxY, w.frame.width, w.frame.height], "level": w.level.rawValue]
                    if let fl = w.contentView?.superview?.layer ?? w.contentView?.layer { wd["layers"] = dumpLayer(fl) }
                    func views(_ v: NSView) -> [String: Any] { ["class": "\(type(of: v))", "frame": [v.frame.minX, v.frame.minY, v.frame.width, v.frame.height], "sub": v.subviews.map { views($0) }] }
                    if let fv = w.contentView?.superview ?? w.contentView { wd["views"] = views(fv) }
                    out.append(wd)
                }
                let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
                try! data.write(to: URL(fileURLWithPath: p.replacingOccurrences(of: ".json", with: ".w\(i).json")))
                print("WDUMP \(i) n=\(out.count)"); fflush(stdout)
            }
            RunLoop.main.add(dt, forMode: .common)
        }
        // "popupMenu": [x, yTop]: pops up a plain context menu there after 1.6 s (same _NSGlassEffectWindow as system menus)
        if let pm = cfg["popupMenu"] as? [Any] {
            let pt = pm.map { num($0) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                let menu = NSMenu()
                for (i, t) in ["New Window", "Open…", "Close", "-", "Get Info", "Rename", "Duplicate", "-", "Sort By", "Show View Options"].enumerated() {
                    if t == "-" { menu.addItem(.separator()) } else { let it = menu.addItem(withTitle: t, action: #selector(D.noop), keyEquivalent: i == 0 ? "n" : ""); it.target = self }
                }
                print("MENU"); fflush(stdout)
                menu.popUp(positioning: nil, at: NSPoint(x: pt[0], y: pt[1]), in: bg)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if let p = cfg["dump"] as? String {
                var out: [String: Any] = ["resets": self.resets, "keyWindow": self.win.isKeyWindow, "appActive": NSApp.isActive, "screenColorSpace": scr.colorSpace?.localizedName ?? "?",
                                          "windowFrame": [self.win.frame.minX, scr.frame.height - self.win.frame.maxY, self.win.frame.width, self.win.frame.height]]
                out["views"] = self.glasses.map { g, vc -> Any in ["config": vc, "layers": g.layer.map { dumpLayer($0) } ?? [:]] as [String: Any] }
                let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
                try! data.write(to: URL(fileURLWithPath: p))
            }
            print("READY resets=\(self.resets)"); fflush(stdout)
        }
        let et = Timer(timeInterval: Double(num(cfg["secs"])), repeats: false) { _ in print("END resets=\(self.resets)"); fflush(stdout); exit(0) }
        RunLoop.main.add(et, forMode: .common)
    }
}
let app = NSApplication.shared
app.setActivationPolicy((cfg["policy"] as? String) == "accessory" ? .accessory : .regular)
let d = D(); app.delegate = d; app.run()
