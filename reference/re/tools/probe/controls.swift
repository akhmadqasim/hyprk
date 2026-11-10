// hyprk control gallery probe: one window with the standard AppKit controls in every state, then dumps each
// control's frame (window and screen points), class, cell, bezel and the backdrop/glass layers under it, and saves a
// 2x picture of the window. Stays open for <seconds> so presses can be recorded. macOS only.
// Build: swiftc -swift-version 5 -O -o controls controls.swift   Run: ./controls <outdir> light|dark [seconds]
import AppKit
import QuartzCore

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let secs = CommandLine.arguments.count > 3 ? Double(CommandLine.arguments[3])! : 4

func r(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 10).rounded() / 10 } }

final class Flipped: NSView { override var isFlipped: Bool { true } }

final class D: NSObject, NSApplicationDelegate {
    var w: NSWindow!
    var items: [(String, NSView)] = []
    func add(_ name: String, _ v: NSView, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat? = nil) {
        v.translatesAutoresizingMaskIntoConstraints = true
        if let c = v as? NSControl { c.sizeToFit() } else { v.setFrameSize(v.fittingSize) }
        var f = v.frame; f.origin = NSPoint(x: x, y: y); if let wd = width { f.size.width = wd }
        v.frame = f
        w.contentView!.addSubview(v); items.append((name, v))
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        w = NSWindow(contentRect: NSRect(x: 120, y: 120, width: 760, height: 520), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        w.title = "Controls"
        w.contentView = Flipped()
        func cb(_ t: String, _ s: NSControl.StateValue, _ en: Bool = true) -> NSButton {
            let b = NSButton(checkboxWithTitle: t, target: nil, action: nil); b.allowsMixedState = true; b.state = s; b.isEnabled = en; return b
        }
        add("checkbox-off", cb("Off", .off), 20, 20)
        add("checkbox-on", cb("On", .on), 20, 48)
        add("checkbox-mixed", cb("Mixed", .mixed), 20, 76)
        add("checkbox-disabled-off", cb("Disabled", .off, false), 20, 104)
        add("checkbox-disabled-on", cb("Disabled on", .on, false), 20, 132)
        let r1 = NSButton(radioButtonWithTitle: "Radio on", target: nil, action: nil); r1.state = .on
        let r2 = NSButton(radioButtonWithTitle: "Radio off", target: nil, action: nil); r2.state = .off
        add("radio-on", r1, 20, 170); add("radio-off", r2, 20, 198)
        let seg = NSSegmentedControl(labels: ["One", "Two", "Three"], trackingMode: .selectOne, target: nil, action: nil); seg.selectedSegment = 1
        add("segmented", seg, 200, 20)
        let segS = NSSegmentedControl(labels: ["Small", "Seg"], trackingMode: .selectOne, target: nil, action: nil); segS.controlSize = .small; segS.selectedSegment = 0
        add("segmented-small", segS, 200, 60)
        let sw1 = NSSwitch(); sw1.state = .on; add("switch-on", sw1, 200, 100)
        let sw2 = NSSwitch(); sw2.state = .off; add("switch-off", sw2, 270, 100)
        let swm = NSSwitch(); swm.state = .on; swm.controlSize = .mini; add("switch-mini-on", swm, 340, 104)
        let sl = NSSlider(value: 40, minValue: 0, maxValue: 100, target: nil, action: nil); add("slider", sl, 200, 150, 220)
        let slt = NSSlider(value: 60, minValue: 0, maxValue: 100, target: nil, action: nil); slt.numberOfTickMarks = 5; add("slider-ticks", slt, 200, 185, 220)
        let pop = NSPopUpButton(frame: .zero, pullsDown: false); pop.addItems(withTitles: ["Automatic", "Light", "Dark"]); add("popup", pop, 200, 230)
        let tf = NSTextField(string: "Text field"); add("textfield", tf, 200, 270, 200)
        let tfp = NSTextField(string: ""); tfp.placeholderString = "Placeholder"; add("textfield-placeholder", tfp, 200, 305, 200)
        let sf = NSSearchField(); sf.placeholderString = "Search"; add("searchfield", sf, 200, 340, 200)
        let st = NSStepper(); st.integerValue = 3; add("stepper", st, 420, 270)
        let b1 = NSButton(title: "Cancel", target: nil, action: nil); add("push", b1, 460, 20)
        let b2 = NSButton(title: "OK", target: nil, action: nil); b2.keyEquivalent = "\r"; add("push-default", b2, 560, 20)
        let b3 = NSButton(title: "Disabled", target: nil, action: nil); b3.isEnabled = false; add("push-disabled", b3, 460, 60)
        let b4 = NSButton(title: "Large", target: nil, action: nil); b4.controlSize = .large; add("push-large", b4, 460, 100)
        let b5 = NSButton(title: "Small", target: nil, action: nil); b5.controlSize = .small; add("push-small", b5, 580, 104)
        let hb = NSButton(title: "", target: nil, action: nil); hb.bezelStyle = .helpButton; add("help", hb, 460, 150)
        let gb = NSButton(image: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!, target: nil, action: nil); gb.bezelStyle = .toolbar; add("icon-button", gb, 520, 150)
        let pi = NSProgressIndicator(); pi.isIndeterminate = false; pi.doubleValue = 60; pi.style = .bar; add("progress", pi, 460, 200, 200)
        let sp = NSProgressIndicator(); sp.style = .spinning; sp.startAnimation(nil); add("spinner", sp, 460, 240)
        let cw = NSColorWell(style: .default); cw.color = .systemBlue; add("colorwell", cw, 540, 240)
        let dp = NSDatePicker(); dp.datePickerStyle = .textFieldAndStepper; add("datepicker", dp, 460, 300)
        let lvl = NSLevelIndicator(); lvl.levelIndicatorStyle = .continuousCapacity; lvl.maxValue = 10; lvl.doubleValue = 6; add("level", lvl, 460, 340, 160)
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.dump() }
        DispatchQueue.main.asyncAfter(deadline: .now() + max(secs, 2.5)) { NSApp.terminate(nil) }
    }
    func layers(_ l: CALayer, _ depth: Int, _ out: inout [[String: Any]]) {
        var d: [String: Any] = ["class": "\(type(of: l))", "frame": r(l.frame), "depth": depth]
        if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius }
        if let c = l.backgroundColor { d["bg"] = String(describing: c) }
        if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map { ($0 as? NSObject)?.value(forKey: "name") as? String ?? "\($0)" } }
        if l.shadowOpacity != 0 { d["shadow"] = [l.shadowOpacity, Float(l.shadowRadius), Float(l.shadowOffset.height)] }
        if l.borderWidth != 0 { d["border"] = [Double(l.borderWidth), String(describing: l.borderColor)] }
        out.append(d)
        if depth < 12 { for s in l.sublayers ?? [] { layers(s, depth + 1, &out) } }
    }
    func dump() {
        var arr: [[String: Any]] = []
        for (name, v) in items {
            let inWin = v.convert(v.bounds, to: nil)
            let onScreen = w.convertToScreen(inWin)
            let screenH = NSScreen.main!.frame.height
            var d: [String: Any] = ["name": name, "class": "\(type(of: v))", "frameInWindow": r(inWin),
                                    "screenTopLeft": r(CGRect(x: onScreen.minX, y: screenH - onScreen.maxY, width: onScreen.width, height: onScreen.height)),
                                    "intrinsic": [Double(v.intrinsicContentSize.width), Double(v.intrinsicContentSize.height)]]
            if let c = v as? NSControl, let cell = c.cell { d["cell"] = "\(type(of: cell))"; d["controlSize"] = c.controlSize.rawValue; d["font"] = c.font.map { "\($0.fontName) \($0.pointSize)" } ?? "" }
            if let b = v as? NSButton { d["bezel"] = b.bezelStyle.rawValue }
            var ls: [[String: Any]] = []
            if let l = v.layer { layers(l, 0, &ls) }
            d["layers"] = ls
            arr.append(d)
        }
        let data = try! JSONSerialization.data(withJSONObject: ["mode": mode, "windowFrame": r(w.frame), "controls": arr], options: [.prettyPrinted, .sortedKeys])
        try! data.write(to: URL(fileURLWithPath: "\(outDir)/controls-\(mode).json"))
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-o", "-l", "\(w.windowNumber)", "\(outDir)/controls-\(mode).png"]
        try? p.run(); p.waitUntilExit()
        print("wrote controls-\(mode).json/.png"); fflush(stdout)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D()
app.delegate = d
app.run()
