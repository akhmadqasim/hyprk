// hyprk control gallery probe: one window with the standard AppKit controls in every state and size, then dumps each
// control's frame (window and screen points), class, cell, bezel, focus-ring bounds, view tree and the full layer tree
// under it (filters with inputs, shadows, animations), and saves a 2x picture of the window. Stays open for <seconds>
// so presses can be recorded. macOS only.
// Build: swiftc -swift-version 5 -O -o controls controls.swift
// Run:   ./controls <outdir> light|dark [seconds] [phases]
//   phases (comma list, optional):
//     focus    - makes each control first responder in turn and saves focus-<name>-<mode>.png (full keyboard access
//                is forced on inside this process only; no user setting is changed)
//     inactive - saves controls-<mode>-inactive.png with a second window key
//     sample   - samples running Core Animation animations at 120 Hz until exit -> controls-motion-<mode>.json
//                (press controls from outside meanwhile)
import AppKit
import QuartzCore
import ObjectiveC

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let secs = CommandLine.arguments.count > 3 ? Double(CommandLine.arguments[3])! : 4
let phases = Set((CommandLine.arguments.count > 4 ? CommandLine.arguments[4] : "").split(separator: ",").map(String.init))

func r(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 10).rounded() / 10 } }

var strDepth = 0
func str(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let s = v as? String { return s }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID {
        let c = v as! CGColor
        return ["color": (c.components ?? []).map { (Double($0) * 10000).rounded() / 10000 }, "space": (c.colorSpace?.name as String?) ?? "?"]
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
        let enc = String(cString: nv.objCType)
        var size = 0, align = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &align)
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fdcislqCISLQB".contains($0) }
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
                guard let t = attrs.dropFirst().first, "cislqCISLQfdB@{".contains(t) else { continue }
                if obj.responds(to: NSSelectorFromString(name)) { out[name] = str(obj.value(forKey: name)) }
            }
            free(list)
        }
        c = class_getSuperclass(cls)
    }
    return out
}

func dumpFilter(_ f: Any) -> Any {
    guard let o = f as? NSObject else { return String(describing: f) }
    var d: [String: Any] = ["class": "\(type(of: o))"]
    for k in ["name", "type", "enabled"] where o.responds(to: NSSelectorFromString(k)) { d[k] = str(o.value(forKey: k)) }
    if o.responds(to: NSSelectorFromString("inputKeys")), let ks = o.value(forKey: "inputKeys") as? [String] {
        var inputs: [String: Any] = [:]
        for k in ks { if let v = o.value(forKey: k) { inputs[k] = str(v) } }
        d["inputs"] = inputs
    }
    return d
}

func dumpAnimation(_ a: CAAnimation) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: a))", "duration": a.duration, "beginTime": a.beginTime, "speed": a.speed,
                            "fillMode": a.fillMode.rawValue]
    if let f = a.timingFunction { d["timingFunction"] = str(f) }
    if let p = a as? CAPropertyAnimation { d["keyPath"] = p.keyPath ?? ""; d["additive"] = p.isAdditive }
    if let b = a as? CABasicAnimation { d["from"] = str(b.fromValue); d["to"] = str(b.toValue); d["by"] = str(b.byValue) }
    if let s = a as? CASpringAnimation {
        d["mass"] = s.mass; d["stiffness"] = s.stiffness; d["damping"] = s.damping
        d["initialVelocity"] = s.initialVelocity; d["settlingDuration"] = s.settlingDuration
    }
    if let k = a as? CAKeyframeAnimation {
        d["values"] = str(k.values); d["keyTimes"] = str(k.keyTimes); d["calculationMode"] = k.calculationMode.rawValue
    }
    if let g = a as? CAAnimationGroup { d["animations"] = (g.animations ?? []).map { dumpAnimation($0) } }
    return d
}

func dumpLayer(_ l: CALayer, depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: l))", "frame": r(l.frame)]
    if l.opacity != 1 { d["opacity"] = l.opacity }
    if let n = l.name { d["name"] = n }
    if l.isHidden { d["hidden"] = true }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius; d["cornerCurve"] = l.cornerCurve.rawValue }
    if l.masksToBounds { d["masksToBounds"] = true }
    if let c = l.backgroundColor { d["bg"] = str(c) }
    if l.borderWidth != 0 { d["borderWidth"] = l.borderWidth; d["borderColor"] = str(l.borderColor) }
    if l.shadowOpacity != 0 {
        d["shadow"] = ["opacity": l.shadowOpacity, "radius": l.shadowRadius, "offset": [l.shadowOffset.width, l.shadowOffset.height],
                       "color": str(l.shadowColor)]
    }
    if let cf = l.compositingFilter { d["compositingFilter"] = (cf as? String) ?? dumpFilter(cf) }
    if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map { dumpFilter($0) } }
    if let fs = l.backgroundFilters, !fs.isEmpty { d["backgroundFilters"] = fs.map { dumpFilter($0) } }
    if !CATransform3DIsIdentity(l.transform) { let t = l.transform; d["transform"] = [t.m11, t.m12, t.m21, t.m22, t.m41, t.m42] }
    if l.contents != nil { d["hasContents"] = true }
    if let s = l as? CAShapeLayer {
        if let c = s.fillColor { d["fill"] = str(c) }
        if let c = s.strokeColor { d["stroke"] = str(c); d["lineWidth"] = s.lineWidth }
        if let p = s.path { d["pathBounds"] = r(p.boundingBox) }
    }
    if let t = l as? CATextLayer, let s = t.string { d["text"] = "\(s)" }
    if NSStringFromClass(type(of: l)).contains("Backdrop") || NSStringFromClass(type(of: l)).contains("Glass") {
        let p = props(l, stop: CALayer.self); if !p.isEmpty { d["props"] = p }
    }
    if let keys = l.animationKeys(), !keys.isEmpty {
        var an: [String: Any] = [:]
        for k in keys { if let a = l.animation(forKey: k) { an[k] = dumpAnimation(a) } }
        d["animations"] = an
    }
    if let m = l.mask { d["mask"] = dumpLayer(m, depth: depth + 1) }
    if let subs = l.sublayers, !subs.isEmpty, depth < 30 { d["sublayers"] = subs.map { dumpLayer($0, depth: depth + 1) } }
    return d
}

func dumpView(_ v: NSView, depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frame": r(v.frame)]
    if v.isHidden { d["hidden"] = true }
    if v.alphaValue != 1 { d["alpha"] = v.alphaValue }
    if let g = v as? NSGlassEffectView {
        d["glassStyle"] = g.style.rawValue; d["glassCornerRadius"] = g.cornerRadius
        for k in ["_variant", "_subvariant"] { d[k] = str(g.value(forKey: k)) }
    }
    if let e = v as? NSVisualEffectView { d["material"] = e.material.rawValue; d["state"] = e.state.rawValue }
    if depth < 20, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { dumpView($0, depth: depth + 1) } }
    return d
}

func motion(_ root: CALayer) -> [[String: Any]] {
    var anims: [[String: Any]] = []
    func walk(_ l: CALayer, _ path: String) {
        if let keys = l.animationKeys(), !keys.isEmpty {
            for k in keys {
                if let a = l.animation(forKey: k) {
                    var e = dumpAnimation(a); e["layer"] = path; e["key"] = k
                    if let p = l.presentation() {
                        e["presFrame"] = r(p.frame); e["presOpacity"] = p.opacity
                        e["presScale"] = [p.transform.m11, p.transform.m22]
                        if let c = p.backgroundColor { e["presBg"] = str(c) }
                    }
                    anims.append(e)
                }
            }
        }
        for (i, s) in (l.sublayers ?? []).enumerated() { walk(s, "\(path)/\(i):\(type(of: s))") }
    }
    walk(root, "root")
    return anims
}

// what the sampler records for each watched control: presentation geometry and colours of every layer, per tick
let watch: Set<String> = ["switch-on", "switch-off", "switch-small-on", "slider", "slider-ticks", "segmented", "segmented-large",
                          "checkbox-off", "checkbox-on", "radio-off", "push", "push-default", "popup", "push-glass", "stepper", "help"]
func compact(_ m: CALayer) -> [Any] {
    let l = m.presentation() ?? m
    var o: [Any] = ["\(type(of: m))", r(l.frame)]
    var e: [String: Any] = [:]
    if let c = l.backgroundColor { e["bg"] = str(c) }
    if l.opacity != 1 { e["op"] = l.opacity }
    if l.isHidden { e["hidden"] = true }
    if !CATransform3DIsIdentity(l.transform) { let t = l.transform; e["tf"] = [t.m11, t.m22, t.m41, t.m42] }
    if l.shadowOpacity != 0 { e["sh"] = [l.shadowOpacity, Float(l.shadowRadius), Float(l.shadowOffset.height)] }
    if l.cornerRadius != 0 { e["cr"] = l.cornerRadius }
    if let s = l as? CAShapeLayer, let c = s.fillColor { e["fill"] = str(c) }
    if let fs = m.filters, !fs.isEmpty { e["filters"] = fs.map { dumpFilter($0) } }
    if !e.isEmpty { o.append(e) }
    let subs = (m.sublayers ?? []).map { compact($0) }
    if !subs.isEmpty { o.append(subs) }
    return o
}

final class Flipped: NSView { override var isFlipped: Bool { true } }

final class D: NSObject, NSApplicationDelegate {
    var w: NSWindow!
    var items: [(String, NSView)] = []
    var samples: [[String: Any]] = []
    func add(_ name: String, _ v: NSView, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat? = nil) {
        v.translatesAutoresizingMaskIntoConstraints = true
        if let c = v as? NSControl { c.sizeToFit() } else { v.setFrameSize(v.fittingSize) }
        var f = v.frame; f.origin = NSPoint(x: x, y: y); if let wd = width { f.size.width = wd }
        v.frame = f
        w.contentView!.addSubview(v); items.append((name, v))
    }
    func item(_ n: String) -> NSView? { items.first { $0.0 == n }?.1 }
    func after(_ s: Double, _ f: @escaping () -> Void) {
        let t = Timer(timeInterval: s, repeats: false) { _ in f() }
        RunLoop.main.add(t, forMode: .common)
    }
    func capture(_ name: String) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-o", "-l", "\(w.windowNumber)", "\(outDir)/\(name).png"]
        try? p.run(); p.waitUntilExit()
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        w = NSWindow(contentRect: NSRect(x: 120, y: 120, width: 900, height: 560), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        w.title = "Controls"
        w.contentView = Flipped()
        func cb(_ t: String, _ s: NSControl.StateValue, _ en: Bool = true, _ size: NSControl.ControlSize = .regular) -> NSButton {
            let b = NSButton(checkboxWithTitle: t, target: nil, action: nil); b.allowsMixedState = true; b.state = s; b.isEnabled = en; b.controlSize = size; return b
        }
        func radio(_ t: String, _ s: NSControl.StateValue, _ en: Bool = true, _ size: NSControl.ControlSize = .regular) -> NSButton {
            let b = NSButton(radioButtonWithTitle: t, target: nil, action: nil); b.state = s; b.isEnabled = en; b.controlSize = size; return b
        }
        func seg(_ l: [String], _ size: NSControl.ControlSize, _ en: Bool = true) -> NSSegmentedControl {
            let s = NSSegmentedControl(labels: l, trackingMode: .selectOne, target: nil, action: nil); s.controlSize = size; s.selectedSegment = 0; s.isEnabled = en; return s
        }
        func sw(_ on: Bool, _ size: NSControl.ControlSize = .regular, _ en: Bool = true) -> NSSwitch {
            let s = NSSwitch(); s.state = on ? .on : .off; s.controlSize = size; s.isEnabled = en; return s
        }
        func pop(_ size: NSControl.ControlSize, _ en: Bool = true, pulls: Bool = false) -> NSPopUpButton {
            let p = NSPopUpButton(frame: .zero, pullsDown: pulls); p.addItems(withTitles: pulls ? ["Pull-down", "One", "Two"] : ["Automatic", "Light", "Dark"])
            p.controlSize = size; p.isEnabled = en; return p
        }
        func push(_ t: String, _ size: NSControl.ControlSize = .regular, _ en: Bool = true) -> NSButton {
            let b = NSButton(title: t, target: nil, action: nil); b.controlSize = size; b.isEnabled = en; return b
        }
        // original gallery (positions kept)
        add("checkbox-off", cb("Off", .off), 20, 20)
        add("checkbox-on", cb("On", .on), 20, 48)
        add("checkbox-mixed", cb("Mixed", .mixed), 20, 76)
        add("checkbox-disabled-off", cb("Disabled", .off, false), 20, 104)
        add("checkbox-disabled-on", cb("Disabled on", .on, false), 20, 132)
        add("radio-on", radio("Radio on", .on), 20, 170); add("radio-off", radio("Radio off", .off), 20, 198)
        let segR = seg(["One", "Two", "Three"], .regular); segR.selectedSegment = 1; add("segmented", segR, 200, 20)
        add("segmented-small", seg(["Small", "Seg"], .small), 200, 60)
        add("switch-on", sw(true), 200, 100)
        add("switch-off", sw(false), 270, 100)
        add("switch-mini-on", sw(true, .mini), 340, 104)
        add("slider", NSSlider(value: 40, minValue: 0, maxValue: 100, target: nil, action: nil), 200, 150, 220)
        let slt = NSSlider(value: 60, minValue: 0, maxValue: 100, target: nil, action: nil); slt.numberOfTickMarks = 5; add("slider-ticks", slt, 200, 185, 220)
        add("popup", pop(.regular), 200, 230)
        add("textfield", NSTextField(string: "Text field"), 200, 270, 200)
        let tfp = NSTextField(string: ""); tfp.placeholderString = "Placeholder"; add("textfield-placeholder", tfp, 200, 305, 200)
        let sf = NSSearchField(); sf.placeholderString = "Search"; add("searchfield", sf, 200, 340, 200)
        let st = NSStepper(); st.integerValue = 3; add("stepper", st, 420, 270)
        add("push", push("Cancel"), 460, 20)
        let b2 = push("OK"); b2.keyEquivalent = "\r"; add("push-default", b2, 560, 20)
        add("push-disabled", push("Disabled", .regular, false), 460, 60)
        add("push-large", push("Large", .large), 460, 100)
        add("push-small", push("Small", .small), 580, 104)
        let hb = NSButton(title: "", target: nil, action: nil); hb.bezelStyle = .helpButton; add("help", hb, 460, 150)
        let gb = NSButton(image: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!, target: nil, action: nil); gb.bezelStyle = .toolbar; add("icon-button", gb, 520, 150)
        let pi = NSProgressIndicator(); pi.isIndeterminate = false; pi.doubleValue = 60; pi.style = .bar; add("progress", pi, 460, 200, 200)
        let sp = NSProgressIndicator(); sp.style = .spinning; sp.startAnimation(nil); add("spinner", sp, 460, 240)
        let cw = NSColorWell(style: .default); cw.color = .systemBlue; add("colorwell", cw, 540, 240)
        let dp = NSDatePicker(); dp.datePickerStyle = .textFieldAndStepper; add("datepicker", dp, 460, 300)
        let lvl = NSLevelIndicator(); lvl.levelIndicatorStyle = .continuousCapacity; lvl.maxValue = 10; lvl.doubleValue = 6; add("level", lvl, 460, 340, 160)
        // extra sizes and states
        add("segmented-mini", seg(["Mini", "Seg"], .mini), 680, 20)
        add("segmented-large", seg(["Large", "Seg"], .large), 680, 45)
        add("segmented-disabled", seg(["Off", "Seg"], .regular, false), 680, 85)
        add("push-mini", push("Mini", .mini), 680, 125)
        add("switch-small-on", sw(true, .small), 680, 160); add("switch-small-off", sw(false, .small), 740, 160)
        add("switch-on-disabled", sw(true, .regular, false), 680, 195); add("switch-off-disabled", sw(false, .regular, false), 750, 195)
        add("popup-small", pop(.small), 680, 230)
        add("popup-mini", pop(.mini), 680, 262)
        add("popup-disabled", pop(.regular, false), 680, 290)
        add("pulldown", pop(.regular, pulls: true), 680, 322)
        let sts = NSStepper(); sts.controlSize = .small; add("stepper-small", sts, 680, 358)
        let stm = NSStepper(); stm.controlSize = .mini; add("stepper-mini", stm, 720, 360)
        add("checkbox-small", cb("Small", .on, true, .small), 20, 230)
        add("checkbox-mini", cb("Mini", .on, true, .mini), 20, 255)
        add("checkbox-large", cb("Large", .on, true, .large), 20, 276)
        add("radio-small", radio("Small", .on, true, .small), 20, 305)
        add("radio-mini", radio("Mini", .on, true, .mini), 20, 330)
        add("radio-disabled-on", radio("Disabled on", .on, false), 20, 352)
        add("radio-disabled-off", radio("Disabled", .off, false), 20, 378)
        let gl = push("Glass"); gl.bezelStyle = .glass; add("push-glass", gl, 20, 410)
        let sld = NSSlider(value: 40, minValue: 0, maxValue: 100, target: nil, action: nil); sld.isEnabled = false; add("slider-disabled", sld, 200, 400, 220)
        let sls = NSSlider(value: 40, minValue: 0, maxValue: 100, target: nil, action: nil); sls.controlSize = .small; add("slider-small", sls, 200, 435, 220)
        let slm = NSSlider(value: 40, minValue: 0, maxValue: 100, target: nil, action: nil); slm.controlSize = .mini; add("slider-mini", slm, 200, 465, 220)
        let slts = NSSlider(value: 50, minValue: 0, maxValue: 100, target: nil, action: nil); slts.numberOfTickMarks = 9; slts.allowsTickMarkValuesOnly = true; add("slider-ticks9", slts, 200, 495, 220)
        let tfr = NSTextField(string: "Rounded"); tfr.bezelStyle = .roundedBezel; add("textfield-rounded", tfr, 460, 400, 200)
        let tfs = NSTextField(string: "Square bezel"); tfs.bezelStyle = .squareBezel; add("textfield-square", tfs, 460, 435, 200)
        let tfd = NSTextField(string: "Disabled"); tfd.isEnabled = false; add("textfield-disabled", tfd, 460, 470, 200)
        let tfsm = NSTextField(string: "Small field"); tfsm.controlSize = .small; tfsm.font = .systemFont(ofSize: NSFont.smallSystemFontSize); add("textfield-small", tfsm, 460, 505, 200)
        add("label", NSTextField(labelWithString: "Label 13"), 680, 400)
        let l2 = NSTextField(labelWithString: "Secondary 11"); l2.font = .systemFont(ofSize: 11); l2.textColor = .secondaryLabelColor; add("label-secondary", l2, 680, 425)
        let l3 = NSTextField(labelWithString: "Disabled label"); l3.textColor = .disabledControlTextColor; add("label-disabled", l3, 680, 448)
        let l4 = NSTextField(labelWithString: "Tertiary label"); l4.textColor = .tertiaryLabelColor; add("label-tertiary", l4, 680, 472)
        let combo = NSComboBox(); combo.addItems(withObjectValues: ["One", "Two"]); combo.stringValue = "Combo"; add("combobox", combo, 680, 500, 150)

        if phases.contains("focus"), let m = class_getInstanceMethod(NSApplication.self, NSSelectorFromString("isFullKeyboardAccessEnabled")) {
            let block: @convention(block) (AnyObject) -> Bool = { _ in true }
            method_setImplementation(m, imp_implementationWithBlock(block))
        }
        w.makeKeyAndOrderFront(nil)
        w.makeFirstResponder(nil)
        NSApp.activate(ignoringOtherApps: true)
        after(1.5) { self.dump(); self.next() }
        after(max(secs, 2.5)) { self.finish() }
    }
    var queue: [String] = []
    func next() {
        if phases.contains("focus") && queue.isEmpty && !focusDone {
            focusDone = true
            queue = ["push", "push-default", "push-small", "push-glass", "help", "switch-on", "switch-off", "checkbox-on", "checkbox-off",
                     "radio-on", "popup", "pulldown", "segmented", "slider", "textfield", "textfield-rounded", "searchfield", "stepper", "colorwell", "combobox"]
        }
        if !queue.isEmpty {
            let n = queue.removeFirst()
            if let v = item(n) { w.makeFirstResponder(v) }
            after(0.7) {
                var fr: [String: Any] = ["name": n, "firstResponder": "\(type(of: self.w.firstResponder!))"]
                if let v = self.item(n) { fr["focusRingMaskBounds"] = r(v.focusRingMaskBounds); fr["frameInWindow"] = r(v.convert(v.bounds, to: nil)) }
                self.focusInfo.append(fr)
                self.capture("focus-\(n)-\(mode)")
                self.next()
            }
            return
        }
        if phases.contains("focus") && !focusWritten {
            focusWritten = true; w.makeFirstResponder(nil)
            let data = try! JSONSerialization.data(withJSONObject: ["windowFrame": r(w.frame), "focus": focusInfo], options: [.prettyPrinted, .sortedKeys])
            try! data.write(to: URL(fileURLWithPath: "\(outDir)/focus-\(mode).json"))
        }
        if phases.contains("inactive") && !inactiveDone {
            inactiveDone = true
            let w2 = NSWindow(contentRect: NSRect(x: 1200, y: 120, width: 200, height: 120), styleMask: [.titled], backing: .buffered, defer: false)
            w2.title = "Other"; w2.makeKeyAndOrderFront(nil)
            after(0.8) { self.capture("controls-\(mode)-inactive"); w2.orderOut(nil); self.w.makeKeyAndOrderFront(nil); print("inactive done"); fflush(stdout) }
            return
        }
        if phases.contains("sample") && !sampling {
            sampling = true
            let start = CACurrentMediaTime()
            var last = ""
            let t = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
                guard let s = self, let root = s.w.contentView?.layer else { return }
                let a = motion(root).filter { ($0["key"] as? String) != "CUIIndeterminateProgressAnimation" }
                var snap: [String: Any] = [:]
                for (n, v) in s.items where watch.contains(n) { if let l = v.layer { snap[n] = compact(l) } }
                let key = String(describing: a) + String(describing: snap)
                if key != last { last = key; s.samples.append(["t": CACurrentMediaTime() - start, "wall": Date().timeIntervalSince1970, "animations": a, "layers": snap]) }
            }
            RunLoop.main.add(t, forMode: .common)
            print(String(format: "sampling from %.4f", Date().timeIntervalSince1970)); fflush(stdout)
        }
    }
    var focusDone = false, focusWritten = false, inactiveDone = false, sampling = false
    var focusInfo: [[String: Any]] = []
    func finish() {
        if sampling {
            let data = try! JSONSerialization.data(withJSONObject: samples, options: [.prettyPrinted, .sortedKeys])
            try! data.write(to: URL(fileURLWithPath: "\(outDir)/controls-motion-\(mode).json"))
        }
        NSApp.terminate(nil)
    }
    func dump() {
        var arr: [[String: Any]] = []
        let screenH = NSScreen.screens[0].frame.height
        for (name, v) in items {
            let inWin = v.convert(v.bounds, to: nil)
            let onScreen = w.convertToScreen(inWin)
            var d: [String: Any] = ["name": name, "class": "\(type(of: v))", "frameInWindow": r(inWin),
                                    "screenTopLeft": r(CGRect(x: onScreen.minX, y: screenH - onScreen.maxY, width: onScreen.width, height: onScreen.height)),
                                    "intrinsic": [Double(v.intrinsicContentSize.width), Double(v.intrinsicContentSize.height)],
                                    "alignmentRectInsets": [v.alignmentRectInsets.top, v.alignmentRectInsets.left, v.alignmentRectInsets.bottom, v.alignmentRectInsets.right],
                                    "focusRingMaskBounds": r(v.focusRingMaskBounds)]
            if let c = v as? NSControl, let cell = c.cell { d["cell"] = "\(type(of: cell))"; d["controlSize"] = c.controlSize.rawValue; d["font"] = c.font.map { "\($0.fontName) \($0.pointSize)" } ?? "" }
            if let b = v as? NSButton { d["bezel"] = b.bezelStyle.rawValue }
            if let t = v as? NSTextField, let c = t.textColor { d["textColor"] = String(describing: c.usingColorSpace(.sRGB) ?? c) }
            d["views"] = dumpView(v)
            if let l = v.layer { d["layers"] = dumpLayer(l) }
            arr.append(d)
        }
        let data = try! JSONSerialization.data(withJSONObject: ["mode": mode, "windowFrame": r(w.frame), "contentTopInWindow": Double(w.frame.height - w.contentLayoutRect.maxY),
                                                                "controls": arr], options: [.prettyPrinted, .sortedKeys])
        try! data.write(to: URL(fileURLWithPath: "\(outDir)/controls-\(mode).json"))
        capture("controls-\(mode)")
        print("wrote controls-\(mode).json/.png"); fflush(stdout)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D()
app.delegate = d
app.run()
