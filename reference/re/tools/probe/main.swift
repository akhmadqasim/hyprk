// hyprk live probe: shows real AppKit glass, menus, popovers and alerts and dumps their layer trees,
// filters, view metrics and running animations as JSON. macOS only.
// Build: swiftc -swift-version 5 -O -o probe main.swift    Run: ./probe <outdir> [light|dark] [ui|variants|variants2|motion|motion2]
import AppKit
import QuartzCore
import ObjectiveC

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let scenario = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "ui"
let t0 = CACurrentMediaTime()

var strDepth = 0
func str(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID {
        let c = v as! CGColor
        return ["color": (c.components ?? []).map { Double($0) }, "space": (c.colorSpace?.name as String?) ?? "?"]
    }
    if let a = v as? [Any] { return a.map { str($0) } }
    if let f = v as? CAMediaTimingFunction {
        var p = [Float](repeating: 0, count: 8)
        for i in 0..<4 { f.getControlPoint(at: i, values: &p[i * 2]) }
        return ["timing": [p[2], p[3], p[4], p[5]]]
    }
    if let an = v as? CAAnimation { return dumpAnimation(an) }
    if let l = v as? CALayer { return "layer:\(type(of: l))" }
    if let nv = v as? NSValue {
        // structs made only of floats or doubles (CAColorMatrix, CGRect, ...) become number arrays
        let enc = String(cString: nv.objCType)
        var size = 0, align = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &align)
        let body = enc.drop(while: { $0 != "=" }).dropFirst().filter { !"{}".contains($0) && !$0.isLetter || "fd".contains($0) }
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fdcislqCISLQB".contains($0) }
        _ = body
        if size > 0, size <= 1024, !kinds.isEmpty, kinds.allSatisfy({ $0 == "f" }) || kinds.allSatisfy({ $0 == "d" }) {
            var buf = [UInt8](repeating: 0, count: size)
            nv.getValue(&buf, size: size)
            if kinds.first == "f" { return buf.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }.map { Double($0) } }
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Double.self)) }
        }
        return String(describing: nv)
    }
    if let o = v as? NSObject, NSStringFromClass(type(of: o)).hasPrefix("CA"), strDepth < 2 {
        strDepth += 1; defer { strDepth -= 1 }
        var d = props(o, stop: NSObject.self); d["class"] = "\(type(of: o))"
        return d
    }
    return String(describing: v)
}

// every declared ObjC property of obj's classes below `stop`
func props(_ obj: NSObject, stop: AnyClass) -> [String: Any] {
    var out: [String: Any] = [:]
    var c: AnyClass? = type(of: obj)
    let skip: Set<String> = ["delegate", "superlayer", "sublayers", "mask", "contents", "hash", "superclass", "description",
                             "debugDescription", "layoutManager", "actions", "style", "modelLayer", "presentationLayer"]
    while let cls = c, cls != stop {
        var n: UInt32 = 0
        if let list = class_copyPropertyList(cls, &n) {
            for i in 0..<Int(n) {
                let name = String(cString: property_getName(list[i]))
                if skip.contains(name) || out[name] != nil { continue }
                let attrs = String(cString: property_getAttributes(list[i])!)
                // only value types and objects KVC can box safely
                guard let t = attrs.dropFirst().first, "cislqCISLQfdB@{".contains(t) else { continue }
                if obj.responds(to: NSSelectorFromString(name)) { out[name] = str(obj.value(forKey: name)) }
            }
            free(list)
        }
        c = class_getSuperclass(cls)
    }
    return out
}

let filterInputs = ["inputRadius", "inputAmount", "inputColorMatrix", "inputBias", "inputScale", "inputColor", "inputAngle",
    "inputRefractionAmount", "inputRefractionHeight", "inputRefractionOffset", "inputAberrationAmount", "inputAberrationAngle",
    "inputAberrationHeight", "inputAberrationOffset", "inputEdgeStart", "inputEdgeEnd", "inputEdgeOpacityStart",
    "inputEdgeOpacityEnd", "inputFade", "inputNormalizeEdges", "inputClamp", "inputClampPreserveHue", "inputDither",
    "inputSourceSublayerName", "inputMaskImage", "inputQuality", "inputIntermediateBitDepth", "inputHardEdges",
    "inputColor0", "inputColor1", "inputReversed", "inputBounds", "inputHeight", "inputSpread", "inputCurvature",
    "inputOpacity", "inputOffset", "inputBlurRadius", "inputSaturation", "inputBrightness", "inputContrast", "inputWhite",
    "inputBlack", "inputMaxLuminance", "inputHeadroom", "inputNormalFill", "inputDodgeFill", "inputBurnFill", "inputLinear",
    "inputCornerRadius", "inputCornerCurve", "inputInset", "inputDistances", "inputOpacities", "inputTintColor",
    "inputBackColor", "inputAddWhite", "inputValues", "inputMode", "inputSize", "inputCenter"]

func dumpFilter(_ f: Any) -> Any {
    guard let o = f as? NSObject else { return String(describing: f) }
    var d: [String: Any] = ["class": "\(type(of: o))"]
    for k in ["name", "type", "enabled", "cachesInputImage"] where o.responds(to: NSSelectorFromString(k)) {
        d[k] = str(o.value(forKey: k))
    }
    var keys = filterInputs
    if o.responds(to: NSSelectorFromString("inputKeys")), let ks = o.value(forKey: "inputKeys") as? [String] {
        keys = ks; d["inputKeys"] = ks
    }
    var inputs: [String: Any] = [:]
    for k in keys {
        if let v = o.value(forKey: k) { inputs[k] = str(v) }
    }
    d["inputs"] = inputs
    return d
}

func dumpAnimation(_ a: CAAnimation) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: a))", "duration": a.duration, "beginTime": a.beginTime,
                            "speed": a.speed, "fillMode": a.fillMode.rawValue, "removedOnCompletion": a.isRemovedOnCompletion]
    if let f = a.timingFunction { d["timingFunction"] = str(f) }
    if let p = a as? CAPropertyAnimation { d["keyPath"] = p.keyPath ?? ""; d["additive"] = p.isAdditive }
    if let b = a as? CABasicAnimation { d["from"] = str(b.fromValue); d["to"] = str(b.toValue); d["by"] = str(b.byValue) }
    if let s = a as? CASpringAnimation {
        d["mass"] = s.mass; d["stiffness"] = s.stiffness; d["damping"] = s.damping
        d["initialVelocity"] = s.initialVelocity; d["settlingDuration"] = s.settlingDuration
    }
    if let k = a as? CAKeyframeAnimation {
        d["values"] = str(k.values); d["keyTimes"] = str(k.keyTimes); d["calculationMode"] = k.calculationMode.rawValue
        d["timingFunctions"] = str(k.timingFunctions)
    }
    if let g = a as? CAAnimationGroup { d["animations"] = (g.animations ?? []).map { dumpAnimation($0) } }
    d["extra"] = props(a, stop: CAAnimation.self).filter { !["keyPath", "fromValue", "toValue", "byValue", "values", "keyTimes",
        "mass", "stiffness", "damping", "initialVelocity", "timingFunctions", "animations", "additive"].contains($0.key) }
    return d
}

func r(_ x: CGRect) -> [Double] { [Double(x.origin.x), Double(x.origin.y), Double(x.width), Double(x.height)] }

func dumpLayer(_ l: CALayer, depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: l))", "frame": r(l.frame), "opacity": l.opacity]
    if let n = l.name { d["name"] = n }
    if l.isHidden { d["hidden"] = true }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius; d["cornerCurve"] = l.cornerCurve.rawValue }
    if l.masksToBounds { d["masksToBounds"] = true }
    if let c = l.backgroundColor { d["backgroundColor"] = str(c) }
    if l.borderWidth != 0 { d["borderWidth"] = l.borderWidth; d["borderColor"] = str(l.borderColor) }
    if l.shadowOpacity != 0 {
        d["shadow"] = ["opacity": l.shadowOpacity, "radius": l.shadowRadius, "offset": [l.shadowOffset.width, l.shadowOffset.height],
                       "color": str(l.shadowColor)]
    }
    if let cf = l.compositingFilter { d["compositingFilter"] = (cf as? String) ?? dumpFilter(cf) }
    if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map { dumpFilter($0) } }
    if let fs = l.backgroundFilters, !fs.isEmpty { d["backgroundFilters"] = fs.map { dumpFilter($0) } }
    if !CATransform3DIsIdentity(l.transform) {
        let t = l.transform
        d["transform"] = [t.m11, t.m12, t.m21, t.m22, t.m41, t.m42]
    }
    if l.contents != nil { d["hasContents"] = true; d["contentsScale"] = l.contentsScale }
    if type(of: l) != CALayer.self {
        let p = props(l, stop: CALayer.self)
        if !p.isEmpty { d["props"] = p }
    }
    if let keys = l.animationKeys(), !keys.isEmpty {
        var an: [String: Any] = [:]
        for k in keys { if let a = l.animation(forKey: k) { an[k] = dumpAnimation(a) } }
        d["animations"] = an
        if let p = l.presentation() { d["presentation"] = ["frame": r(p.frame), "opacity": p.opacity] }
    }
    if let m = l.mask { d["mask"] = dumpLayer(m, depth: depth + 1) }
    if let subs = l.sublayers, !subs.isEmpty, depth < 40 { d["sublayers"] = subs.map { dumpLayer($0, depth: depth + 1) } }
    return d
}

func dumpView(_ v: NSView, depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frame": r(v.frame)]
    if v.isHidden { d["hidden"] = true }
    if v.alphaValue != 1 { d["alpha"] = v.alphaValue }
    if let t = v as? NSTextField {
        d["text"] = t.stringValue
        if let f = t.font { d["font"] = "\(f.fontName) \(f.pointSize)"; d["weight"] = str(f.fontDescriptor.object(forKey: .traits)) }
        d["textColor"] = String(describing: t.textColor)
    }
    if let i = v as? NSImageView, let img = i.image { d["image"] = "\(img.name() ?? "?") \(img.size)"; d["tint"] = String(describing: i.contentTintColor) }
    if let e = v as? NSVisualEffectView { d["material"] = e.material.rawValue; d["blending"] = e.blendingMode.rawValue; d["state"] = e.state.rawValue }
    if let g = v as? NSGlassEffectView { d["glassStyle"] = g.style.rawValue; d["glassCornerRadius"] = g.cornerRadius }
    if depth < 40, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { dumpView($0, depth: depth + 1) } }
    return d
}

func rootLayer(_ w: NSWindow) -> CALayer? {
    var l = w.contentView?.layer
    while let s = l?.superlayer { l = s }
    return l
}

func dumpWindow(_ w: NSWindow) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: w))", "frame": r(w.frame), "alpha": w.alphaValue, "hasShadow": w.hasShadow,
                            "level": w.level.rawValue, "opaque": w.isOpaque, "visible": w.isVisible,
                            "number": w.windowNumber, "styleMask": w.styleMask.rawValue]
    d["backgroundColor"] = String(describing: w.backgroundColor)
    var top: NSView? = w.contentView
    while let s = top?.superview { top = s }
    if let v = top { d["views"] = dumpView(v) }
    if let l = rootLayer(w) { d["layers"] = dumpLayer(l) }
    return d
}

func write(_ name: String, _ obj: Any) {
    let path = "\(outDir)/\(name)-\(mode).json"
    if let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]) {
        try? data.write(to: URL(fileURLWithPath: path))
        print("wrote \(path) (\(data.count) bytes)")
    } else { print("FAILED to serialise \(name)") }
}

// keeps only what moves, so a time series stays small
func motion(_ w: NSWindow) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: w))", "frame": r(w.frame), "alpha": w.alphaValue, "visible": w.isVisible]
    var anims: [[String: Any]] = []
    func walk(_ l: CALayer, _ path: String) {
        if let keys = l.animationKeys(), !keys.isEmpty {
            for k in keys {
                if let a = l.animation(forKey: k) {
                    var e = dumpAnimation(a); e["layer"] = path; e["key"] = k
                    if let p = l.presentation() {
                        e["presOpacity"] = p.opacity; e["presFrame"] = r(p.frame)
                        e["presScale"] = [p.transform.m11, p.transform.m22]
                    }
                    anims.append(e)
                }
            }
        }
        for (i, s) in (l.sublayers ?? []).enumerated() { walk(s, "\(path)/\(i):\(type(of: s))") }
    }
    if let l = rootLayer(w) { walk(l, "root") }
    d["animations"] = anims
    return d
}

let a2: NSAlert = { let a = NSAlert(); a.messageText = "Are you sure you want to permanently erase the items in the Trash?"; a.informativeText = "You can’t undo this action."; a.addButton(withTitle: "Empty Trash"); a.addButton(withTitle: "Cancel"); return a }()

final class Probe: NSObject, NSApplicationDelegate {
    var win: NSWindow!
    var samples: [[String: Any]] = []
    var sampler: Timer?
    var popover: NSPopover?
    var button: NSButton!

    func others() -> [NSWindow] { NSApp.windows.filter { $0 !== win && $0.isVisible } }

    func startSampling(_ label: String) {
        samples = []
        let start = CACurrentMediaTime()
        let t = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            guard let s = self else { return }
            s.samples.append(["t": CACurrentMediaTime() - start,
                              "windows": NSApp.windows.filter { $0 !== s.win }.map { motion($0) }])
        }
        RunLoop.main.add(t, forMode: .common)
        sampler = t
    }

    func stopSampling(_ name: String) {
        sampler?.invalidate(); sampler = nil
        // drop consecutive identical samples
        var out: [[String: Any]] = []; var last = ""
        for s in samples {
            let key = String(describing: s["windows"]!)
            if key != last { out.append(s); last = key }
        }
        write(name, out)
    }

    func after(_ s: Double, _ f: @escaping () -> Void) {
        let t = Timer(timeInterval: s, repeats: false) { _ in f() }
        RunLoop.main.add(t, forMode: .common)
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        win = NSWindow(contentRect: NSRect(x: 200, y: 200, width: 760, height: 520),
                       styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        win.title = "hyprk probe"
        let bg = NSView(frame: win.contentView!.bounds)
        bg.wantsLayer = true
        // known backdrop: vertical colour bars with a white and a black band
        let cols: [NSColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .white, .black]
        for (i, c) in cols.enumerated() {
            let v = NSView(frame: NSRect(x: CGFloat(i) * 95, y: 0, width: 95, height: 520))
            v.wantsLayer = true; v.layer?.backgroundColor = c.cgColor; bg.addSubview(v)
        }
        win.contentView = bg
        let specs: [(NSGlassEffectView.Style, NSRect, CGFloat)] = [
            (.regular, NSRect(x: 20, y: 440, width: 200, height: 44), 22),
            (.regular, NSRect(x: 20, y: 300, width: 120, height: 120), 24),
            (.regular, NSRect(x: 20, y: 40, width: 340, height: 240), 28),
            (.clear, NSRect(x: 400, y: 440, width: 200, height: 44), 22),
            (.clear, NSRect(x: 400, y: 300, width: 120, height: 120), 24),
            (.clear, NSRect(x: 400, y: 40, width: 340, height: 240), 28),
        ]
        for (style, frame, radius) in specs {
            let g = NSGlassEffectView(frame: frame)
            g.style = style; g.cornerRadius = radius
            let label = NSTextField(labelWithString: style == .regular ? "regular" : "clear")
            label.frame = NSRect(x: 12, y: 12, width: 100, height: 18)
            let content = NSView(frame: NSRect(origin: .zero, size: frame.size)); content.addSubview(label)
            g.contentView = content
            bg.addSubview(g)
        }
        button = NSButton(title: "Anchor", target: nil, action: nil)
        button.frame = NSRect(x: 620, y: 450, width: 100, height: 30)
        bg.addSubview(button)
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        if scenario == "motion" { after(2.5) { self.stepMotion() } } else if scenario == "motion2" { after(2.5) { self.stepMotion2() } } else if scenario.hasPrefix("variants") { after(1.0) { self.stepVariants() } } else { after(1.5) { self.stepGlass() } }
    }

    // every GlassMaterialProvider.Variant (private _variant) and known subvariant at three sizes
    var variantResults: [[String: Any]] = []
    func interesting(_ l: CALayer, _ path: String, _ out: inout [[String: Any]]) {
        var d = dumpLayer(l, depth: 99)   // depth 99: no sublayers
        d.removeValue(forKey: "sublayers")
        if d["filters"] != nil || d["backgroundFilters"] != nil || d["compositingFilter"] != nil || d["props"] != nil
            || d["backgroundColor"] != nil || d["shadow"] != nil || l is CAGradientLayer {
            d["path"] = path; out.append(d)
        }
        if let m = l.mask { interesting(m, path + "/mask", &out) }
        for (i, s) in (l.sublayers ?? []).enumerated() { interesting(s, "\(path)/\(i):\(type(of: s))", &out) }
    }
    func stepVariants() {
        let names = ["regular", "clear", "dock", "appIcons", "widgets", "text", "avplayer", "facetime", "controlCenter",
                     "notificationCenter", "monogram", "bubbles", "identity", "focusBorder", "focusPlatter", "keyboard", "sidebar",
                     "abuttedSidebar", "inspector", "control", "loupe", "slider", "camera", "cartouchePopover"]
        let subs = ["menu", "window", "documentModalWindow", "sheet", "spotlightField", "searchResults", "compose", "listening",
                    "thinking", "response", "entryField", "focusedButtonFill", "customizeSheet", "volumeSlider", "siriSnippet",
                    "lockscreenNotifications", "lockscreenControls", "homescreenFolder", "transientCanvas", "cursorAccessory"]
        var configs: [(String, Int, String?, [String: Int])] = []
        // AppKit's private _variant is DesignLibrary's Variant index + 1 (0 and 1 both give regular); checked by matching
        // the dock, controlCenter and sidebar recipes. The public style property selects clear.
        for (i, n) in names.enumerated() where i != 1 { configs.append((n, i == 0 ? 0 : i + 1, nil, [:])) }
        configs.append(("clear", 0, nil, ["styleClear": 1]))
        for sv in subs { configs.append(("regular." + sv, 0, sv, [:])) }
        for k in ["_adaptiveAppearance", "_interactionState", "_scrimState", "_subduedState"] {
            for v in 1...2 { configs.append(("regular+\(k)=\(v)", 0, nil, [k: v])) }
        }
        configs.append(("regular+inactiveApp", 0, nil, ["inactive": 1]))
        configs.append(("regular.menu+inactiveApp", 0, "menu", ["inactive": 1]))
        configs.append(("regular.window+inactiveApp", 0, "window", ["inactive": 1]))
        // variants2: raw _variant values past the public Variant list, alone and with the Spotlight subvariant
        // (DesignLibrary's internal Base also has menu, siriSnippet, siri, carplayUltra, vibrantFill)
        if scenario == "variants2" {
            configs = []
            let lo = Int(ProcessInfo.processInfo.environment["RAW_LO"] ?? "24") ?? 24
            let hi = Int(ProcessInfo.processInfo.environment["RAW_HI"] ?? "40") ?? 40
            for v in lo...hi {
                configs.append(("raw\(v)", v, nil, [:]))
                for sv in ["spotlightField", "searchResults", "listening"] { configs.append(("raw\(v).\(sv)", v, sv, [:])) }
            }
        }
        // D = shortest side; Apple's recipes scale with it (ramps over 48/64 to 120/160 pt)
        let ds: [Int] = scenario == "variants2" ? [56, 160] : [24, 32, 44, 64, 96, 128, 160, 240, 400]
        let sizes: [(NSRect, CGFloat)] = ds.map { d in
            let dd = CGFloat(d)
            return (NSRect(x: 20, y: 60, width: min(max(dd * 1.6, 120), 700), height: dd), min(dd / 2, 28))
        }
        var idx = 0
        func next() {
            guard idx < configs.count else {
                write("variants", self.variantResults); NSApp.terminate(nil); return
            }
            let (name, variant, sub, extra) = configs[idx]; idx += 1
            print("config \(name)"); fflush(stdout)
            // glass resolves differently in an inactive window, so hold focus unless the config asks otherwise
            if extra["inactive"] == nil { NSApp.activate(ignoringOtherApps: true); self.win.makeKeyAndOrderFront(nil) }
            var views: [NSGlassEffectView] = []
            for (frame, radius) in sizes {
                let g = NSGlassEffectView(frame: frame)
                g.cornerRadius = radius
                g.setValue(variant, forKey: "_variant")
                if let sv = sub { g.setValue(sv, forKey: "_subvariant") }
                if extra["styleClear"] != nil { g.style = .clear }
                for (k, v) in extra where k != "inactive" && k != "styleClear" { g.setValue(v, forKey: k) }
                g.contentView = NSView(frame: NSRect(origin: .zero, size: frame.size))
                self.win.contentView!.addSubview(g); views.append(g)
            }
            if extra["inactive"] != nil { NSApp.deactivate() }
            self.after(extra["inactive"] != nil ? 0.8 : 0.3) {
                for g in views {
                    var layers: [[String: Any]] = []
                    if let l = g.layer { self.interesting(l, "glass", &layers) }
                    self.variantResults.append(["config": name, "size": [g.frame.width, g.frame.height],
                                                "cornerRadius": g.cornerRadius, "layers": layers, "appActive": NSApp.isActive, "keyWindow": self.win.isKeyWindow,
                                                "variantReadback": str(g.value(forKey: "_variant")),
                                                "subvariantReadback": str(g.value(forKey: "_subvariant"))])
                    g.removeFromSuperview()
                }
                next()
            }
        }
        next()
    }

    // timed sequence for a screen recording; prints each event time relative to launch
    var second: NSWindow?
    func mark(_ what: String) { print(String(format: "EVENT %.3f %@", CACurrentMediaTime() - t0, what)); fflush(stdout) }
    func stepMotion() {
        let p = NSPopover(); let vc = NSViewController()
        vc.view = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 140))
        p.contentViewController = vc; p.behavior = .applicationDefined; popover = p
        let a = NSAlert(); a.messageText = "Empty the Trash?"; a.informativeText = "You can’t undo this action."
        a.addButton(withTitle: "Empty Trash"); a.addButton(withTitle: "Cancel")
        let menu = makeMenu()
        after(0.0) { self.mark("popover-show"); p.show(relativeTo: self.button.bounds, of: self.button, preferredEdge: .minY) }
        after(1.3) { self.mark("popover-close"); p.close() }
        after(2.6) { self.mark("sheet-begin"); a.beginSheetModal(for: self.win) { _ in } }
        after(4.1) { self.mark("sheet-end"); if let sh = self.win.attachedSheet { self.win.endSheet(sh) } }
        after(5.6) { self.mark("menu-popup"); menu.popUp(positioning: nil, at: NSPoint(x: 240, y: 300), in: self.win.contentView) }
        after(6.8) { self.mark("menu-cancel"); menu.cancelTracking() }
        after(8.0) {
            let w = NSWindow(contentRect: NSRect(x: 330, y: 330, width: 420, height: 280),
                             styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            w.title = "second"; w.isReleasedWhenClosed = false; self.second = w
            self.mark("window-open"); w.makeKeyAndOrderFront(nil)
        }
        after(9.5) { self.mark("window-close"); self.second?.performClose(nil) }
        after(11.0) { self.mark("alert-modal"); DispatchQueue.main.async { _ = a2.runModal() } }
        after(12.5) { self.mark("alert-modal-end"); NSApp.abortModal() }
        after(14.0) { self.mark("end"); NSApp.terminate(nil) }
    }

    func stepMotion2() {
        func make(_ b: NSWindow.AnimationBehavior, _ title: String) -> NSWindow {
            let w = NSWindow(contentRect: NSRect(x: 330, y: 330, width: 420, height: 280),
                             styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            w.title = title; w.isReleasedWhenClosed = false; w.animationBehavior = b; return w
        }
        let doc = make(.documentWindow, "document"), util = make(.utilityWindow, "utility"), alertW = make(.alertPanel, "alertPanel")
        after(0.0) { self.mark("doc-open"); doc.makeKeyAndOrderFront(nil) }
        after(1.5) { self.mark("doc-close"); doc.close() }
        after(3.0) { self.mark("utility-open"); util.makeKeyAndOrderFront(nil) }
        after(4.5) { self.mark("utility-close"); util.close() }
        after(6.0) { self.mark("alertpanel-open"); alertW.makeKeyAndOrderFront(nil) }
        after(7.5) { self.mark("alertpanel-close"); alertW.close() }
        after(9.0) { self.mark("alert-modal"); DispatchQueue.main.async { _ = a2.runModal() } }
        after(10.5) { self.mark("alert-modal-click"); a2.buttons.last?.performClick(nil) }
        after(12.0) { self.mark("miniaturize"); self.win.miniaturize(nil) }
        after(14.0) { self.mark("deminiaturize"); self.win.deminiaturize(nil) }
        after(16.0) { self.mark("end"); NSApp.terminate(nil) }
    }

    func stepGlass() {
        write("glass", dumpWindow(win))
        after(0.3) { self.stepMenu() }
    }

    func makeMenu() -> NSMenu {
        let m = NSMenu(title: "Probe")
        m.addItem(withTitle: "New Folder", action: #selector(noop), keyEquivalent: "n")
        m.addItem(withTitle: "Get Info", action: #selector(noop), keyEquivalent: "i")
        let checked = m.addItem(withTitle: "Show Preview", action: #selector(noop), keyEquivalent: "")
        checked.state = .on
        m.addItem(.separator())
        let disabled = m.addItem(withTitle: "Disabled Item", action: nil, keyEquivalent: "")
        disabled.isEnabled = false
        let sub = NSMenu(title: "Sort By")
        for t in ["Name", "Kind", "Date Modified"] { sub.addItem(withTitle: t, action: #selector(noop), keyEquivalent: "") }
        let subItem = m.addItem(withTitle: "Sort By", action: nil, keyEquivalent: "")
        m.setSubmenu(sub, for: subItem)
        m.addItem(.separator())
        let img = m.addItem(withTitle: "Move to Trash", action: #selector(noop), keyEquivalent: "\u{8}")
        img.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
        m.autoenablesItems = false
        for i in m.items where i !== disabled { i.target = self }
        return m
    }
    @objc func noop() {}

    func stepMenu() {
        let menu = makeMenu()
        startSampling("menu")
        after(0.7) {
            write("menu", self.others().map { dumpWindow($0) })
            // highlight an item and open the submenu to capture selection + submenu metrics
            if let item = menu.items.first(where: { $0.title == "Sort By" }) {
                let sel = NSSelectorFromString("_setHighlightedItem:") // not public; guarded
                if menu.responds(to: sel) { menu.perform(sel, with: item) }
            }
        }
        after(1.3) {
            write("menu-highlight", self.others().map { dumpWindow($0) })
            menu.cancelTracking()
        }
        after(2.2) {
            self.stopSampling("menu-motion")
            self.stepPopover()
        }
        // blocks in event tracking mode until cancelTracking; timers above run in common modes
        after(0.1) { menu.popUp(positioning: nil, at: NSPoint(x: 240, y: 300), in: self.win.contentView) }
    }

    func stepPopover() {
        let p = NSPopover()
        let vc = NSViewController()
        let v = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 140))
        let l = NSTextField(labelWithString: "Popover content"); l.frame = NSRect(x: 20, y: 60, width: 200, height: 20)
        v.addSubview(l); vc.view = v
        p.contentViewController = vc; p.behavior = .applicationDefined
        popover = p
        startSampling("popover")
        p.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        after(0.8) { write("popover", self.others().map { dumpWindow($0) }); p.close() }
        after(1.6) { self.stopSampling("popover-motion"); self.stepAlert() }
    }

    func stepAlert() {
        let a = NSAlert()
        a.messageText = "Are you sure you want to permanently erase the items in the Trash?"
        a.informativeText = "You can’t undo this action."
        a.addButton(withTitle: "Empty Trash"); a.addButton(withTitle: "Cancel")
        a.alertStyle = .warning
        startSampling("alert")
        a.beginSheetModal(for: win) { _ in }
        after(1.0) {
            write("alert", self.others().map { dumpWindow($0) })
            if let sheet = self.win.attachedSheet { self.win.endSheet(sheet) }
        }
        after(2.0) { self.stopSampling("alert-motion"); self.stepTooltipAndFinish() }
    }

    func stepTooltipAndFinish() {
        // system metrics that need no window
        var m: [String: Any] = [:]
        m["menuFont"] = "\(NSFont.menuFont(ofSize: 0).fontName) \(NSFont.menuFont(ofSize: 0).pointSize)"
        m["menuBarFont"] = "\(NSFont.menuBarFont(ofSize: 0).fontName) \(NSFont.menuBarFont(ofSize: 0).pointSize)"
        m["systemFont"] = "\(NSFont.systemFont(ofSize: 0).fontName) \(NSFont.systemFont(ofSize: 0).pointSize)"
        m["titleBarFont"] = "\(NSFont.titleBarFont(ofSize: 0).fontName) \(NSFont.titleBarFont(ofSize: 0).pointSize)"
        m["toolTipsFont"] = "\(NSFont.toolTipsFont(ofSize: 0).fontName) \(NSFont.toolTipsFont(ofSize: 0).pointSize)"
        m["menuBarThickness"] = NSStatusBar.system.thickness
        m["menuBarHeight"] = NSApp.mainMenu?.menuBarHeight ?? -1
        if let s = NSScreen.main {
            m["screen"] = r(s.frame); m["visibleFrame"] = r(s.visibleFrame); m["scale"] = s.backingScaleFactor
            m["safeAreaTop"] = s.safeAreaInsets.top
        }
        m["titlebarHeight"] = win.frame.height - win.contentLayoutRect.height
        var colors: [String: Any] = [:]
        NSApp.effectiveAppearance.performAsCurrentDrawingAppearance {
            for (n, c) in [("label", NSColor.labelColor), ("secondaryLabel", .secondaryLabelColor), ("tertiaryLabel", .tertiaryLabelColor),
                           ("separator", .separatorColor), ("selectedContentBackground", .selectedContentBackgroundColor),
                           ("controlAccent", .controlAccentColor), ("windowBackground", .windowBackgroundColor),
                           ("selectedMenuItemText", .selectedMenuItemTextColor), ("controlBackground", .controlBackgroundColor),
                           ("underPageBackground", .underPageBackgroundColor), ("disabledControlText", .disabledControlTextColor)] {
                if let x = c.usingColorSpace(.sRGB) {
                    colors[n] = [x.redComponent, x.greenComponent, x.blueComponent, x.alphaComponent].map { (Double($0) * 1000).rounded() / 1000 }
                }
            }
        }
        m["colors"] = colors
        m["reduceMotion"] = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        m["reduceTransparency"] = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        m["windowNumber"] = win.windowNumber
        write("metrics", m)
        after(0.2) { NSApp.terminate(nil) }
    }
}

let app = NSApplication.shared
let napGuard = ProcessInfo.processInfo.beginActivity(options: [.userInitiated, .latencyCritical], reason: "probe")
app.setActivationPolicy(.regular)
let probe = Probe()
app.delegate = probe
// hard stop so a stuck modal never leaves the app running
Timer.scheduledTimer(withTimeInterval: scenario.hasPrefix("variants") ? 120 : 25, repeats: false) { _ in print("timeout"); exit(2) }
app.run()
