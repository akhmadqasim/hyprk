// hyprk panels probe: NSAlert variants (2/3 buttons, checkbox, text field, destructive), sheets and a popover; dumps layer trees.
// Run: ./panels <outdir> light|dark alert2|alert3|alertcheck|alertdestructive|sheet|sheetalert|popover ; stays up until killed (60 s cap).
// Build: swiftc -swift-version 5 -O -o panels panels.swift
import AppKit
import QuartzCore
import ObjectiveC

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let scenario = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "alert2"
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


final class Panels: NSObject, NSApplicationDelegate {
    var win: NSWindow!
    var button: NSButton!
    func after(_ s: Double, _ f: @escaping () -> Void) {
        let t = Timer(timeInterval: s, repeats: false) { _ in f() }
        RunLoop.main.add(t, forMode: .common)
    }
    func others() -> [NSWindow] { NSApp.windows.filter { $0 !== win && $0.isVisible } }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        let sh = NSScreen.screens[0].frame.height
        // document-like window, top-left (455, 240) in global top-left points, 800 x 520 content
        win = NSWindow(contentRect: NSRect(x: 455, y: sh - 240 - 520, width: 800, height: 520),
                       styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        win.title = "hyprk panels probe"
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 520))
        let label = NSTextField(labelWithString: "hyprk test document")
        label.frame = NSRect(x: 24, y: 470, width: 300, height: 20); content.addSubview(label)
        button = NSButton(title: "Anchor", target: nil, action: nil)
        button.frame = NSRect(x: 350, y: 300, width: 100, height: 30); content.addSubview(button)
        win.contentView = content
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        after(0.8) { self.run() }
    }
    func makeAlert() -> NSAlert {
        let a = NSAlert()
        switch scenario {
        case "alert3":
            a.messageText = "Do you want to keep this new document “hyprk test”?"
            a.informativeText = "You can choose to save your changes, or delete this document immediately. You can’t undo this action."
            a.addButton(withTitle: "Save…"); a.addButton(withTitle: "Cancel"); a.addButton(withTitle: "Delete")
        case "alertcheck":
            a.messageText = "Rename the hyprk test item?"
            a.informativeText = "Type a new name for the item."
            let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 24)); tf.stringValue = "hyprk test"
            a.accessoryView = tf
            a.showsSuppressionButton = true
            a.addButton(withTitle: "Rename"); a.addButton(withTitle: "Cancel")
        case "alertdestructive":
            a.messageText = "Delete “hyprk test”?"
            a.informativeText = "This item will be deleted immediately. You can’t undo this action."
            a.addButton(withTitle: "Delete"); a.addButton(withTitle: "Cancel")
            a.buttons[0].hasDestructiveAction = true
            a.alertStyle = .critical
        default:
            a.messageText = "Are you sure you want to permanently erase the items in the Trash?"
            a.informativeText = "You can’t undo this action."
            a.addButton(withTitle: "Empty Trash"); a.addButton(withTitle: "Cancel")
            a.alertStyle = .warning
        }
        return a
    }
    func run() {
        switch scenario {
        case "popover":
            let p = NSPopover(); let vc = NSViewController()
            let v = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 140))
            let l = NSTextField(labelWithString: "hyprk test popover"); l.frame = NSRect(x: 20, y: 60, width: 220, height: 20)
            v.addSubview(l); vc.view = v; p.contentViewController = vc; p.behavior = .applicationDefined
            p.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            after(1.2) { self.write("panels-popover", self.others().map { dumpWindow($0) }) }
        case "sheet":
            let s = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 220), styleMask: [.titled], backing: .buffered, defer: false)
            let v = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 220))
            let l = NSTextField(labelWithString: "hyprk test sheet"); l.frame = NSRect(x: 20, y: 170, width: 300, height: 20); v.addSubview(l)
            let ok = NSButton(title: "OK", target: nil, action: nil); ok.frame = NSRect(x: 330, y: 16, width: 90, height: 28); ok.keyEquivalent = "\r"; v.addSubview(ok)
            let c = NSButton(title: "Cancel", target: nil, action: nil); c.frame = NSRect(x: 232, y: 16, width: 90, height: 28); v.addSubview(c)
            s.contentView = v
            win.beginSheet(s) { _ in }
            after(1.2) { self.write("panels-sheet", [dumpWindow(self.win)] + self.others().map { dumpWindow($0) }) }
        case "sheetalert":
            makeAlert().beginSheetModal(for: win) { _ in }
            after(1.2) { self.write("panels-sheetalert", [dumpWindow(self.win)] + self.others().map { dumpWindow($0) }) }
        default:
            let a = makeAlert()
            after(1.2) { self.write("panels-" + scenario, self.others().map { dumpWindow($0) }) }
            DispatchQueue.main.async { _ = a.runModal() }
        }
    }
    func write(_ name: String, _ obj: Any) {
        let path = "\(outDir)/\(name)-\(mode).json"
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: path)); print("wrote \(path) (\(data.count) bytes)"); fflush(stdout)
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let panels = Panels()
app.delegate = panels
Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { _ in exit(2) }
app.run()
