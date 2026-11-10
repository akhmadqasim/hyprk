// hyprk menu probe: an app whose menu bar has test menus (plain rows, state rows, icon rows, long menu, tiny menu,
// submenu), a status item with a wide menu, an optional solid backdrop window and a test window for full screen.
// Every menu window (pull-down, submenu, context) is dumped as JSON (views with frames/fonts, layers with filters)
// 0.4 s after it opens. Control while running by writing one line to <outdir>/cmd:
//   bg white|black|grey|none   fs (toggle full screen of the test window)   ctx x y (context menu at window point)
//   dump <name>                quit
// Build: swiftc -swift-version 5 -O -o menus menus.swift
// Run:   ./menus <outdir> light|dark|system [bg] [-AppleAccentColor -1]   (argument domain sets accent for this app only)
import AppKit
import QuartzCore
import ObjectiveC

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "system"
let bgArg = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "none"

func r(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 100).rounded() / 100 } }
func s(_ v: Any?) -> Any {
    guard let v = v else { return NSNull() }
    if let n = v as? NSNumber { return n }
    if let t = v as? String { return t }
    if CFGetTypeID(v as CFTypeRef) == CGColor.typeID { let c = v as! CGColor; return (c.components ?? []).map { Double($0) } }
    if let a = v as? [Any] { return a.map { s($0) } }
    if let nv = v as? NSValue {
        let enc = String(cString: nv.objCType); var size = 0, al = 0
        NSGetSizeAndAlignment(nv.objCType, &size, &al)
        let kinds = enc.split(separator: "=").dropFirst().joined().filter { "fdcislqCISLQB".contains($0) }
        if size > 0, size <= 512, !kinds.isEmpty, kinds.allSatisfy({ $0 == "d" }) {
            var buf = [UInt8](repeating: 0, count: size); nv.getValue(&buf, size: size)
            return buf.withUnsafeBytes { Array($0.bindMemory(to: Double.self)) }
        }
        return String(describing: nv)
    }
    return String(describing: v)
}
func filt(_ f: Any) -> Any {
    guard let o = f as? NSObject else { return String(describing: f) }
    var d: [String: Any] = [:]
    for k in ["name", "type"] where o.responds(to: NSSelectorFromString(k)) { d[k] = s(o.value(forKey: k)) }
    if o.responds(to: NSSelectorFromString("inputKeys")), let ks = o.value(forKey: "inputKeys") as? [String] {
        var inp: [String: Any] = [:]
        for k in ks { if let v = o.value(forKey: k) { inp[k] = s(v) } }
        d["inputs"] = inp
    }
    return d
}
func dumpLayer(_ l: CALayer, _ depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: l))", "frame": r(l.frame)]
    if l.opacity != 1 { d["opacity"] = l.opacity }
    if let n = l.name { d["name"] = n }
    if l.isHidden { d["hidden"] = true }
    if l.cornerRadius != 0 { d["cornerRadius"] = l.cornerRadius }
    if let c = l.backgroundColor { d["bg"] = s(c) }
    if l.borderWidth != 0 { d["border"] = [l.borderWidth, s(l.borderColor)] }
    if l.shadowOpacity != 0 { d["shadow"] = [l.shadowOpacity, l.shadowRadius, l.shadowOffset.height] }
    if let cf = l.compositingFilter { d["compositingFilter"] = (cf as? String) ?? filt(cf) }
    if let fs = l.filters, !fs.isEmpty { d["filters"] = fs.map { filt($0) } }
    if l.contents != nil { d["contents"] = true }
    if let m = l.mask { d["mask"] = dumpLayer(m, depth + 1) }
    if let subs = l.sublayers, !subs.isEmpty, depth < 30 { d["sublayers"] = subs.map { dumpLayer($0, depth + 1) } }
    return d
}
func dumpView(_ v: NSView, _ depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frame": r(v.frame)]
    if v.isHidden { d["hidden"] = true }
    if v.alphaValue != 1 { d["alpha"] = v.alphaValue }
    if let t = v as? NSTextField {
        d["text"] = t.stringValue
        if let f = t.font { d["font"] = "\(f.fontName) \(f.pointSize)"; d["traits"] = s(f.fontDescriptor.object(forKey: .traits)) }
        d["textColor"] = String(describing: t.textColor)
    }
    if let i = v as? NSImageView, let img = i.image { d["image"] = "\(img.name() ?? "?") \(img.size)"; d["tint"] = String(describing: i.contentTintColor) }
    if let g = v as? NSGlassEffectView { d["glassStyle"] = g.style.rawValue; d["glassCornerRadius"] = g.cornerRadius
        for k in ["_variant", "_subvariant"] { d[k] = s(g.value(forKey: k)) } }
    if depth < 30, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { dumpView($0, depth + 1) } }
    return d
}
func dumpWindow(_ w: NSWindow) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: w))", "frame": r(w.frame), "level": w.level.rawValue, "number": w.windowNumber,
                            "hasShadow": w.hasShadow, "alpha": w.alphaValue]
    var top: NSView? = w.contentView
    while let p = top?.superview { top = p }
    if let v = top { d["views"] = dumpView(v) }
    var l = w.contentView?.layer
    while let p = l?.superlayer { l = p }
    if let l = l { d["layers"] = dumpLayer(l) }
    return d
}
func write(_ name: String, _ obj: Any) {
    let path = "\(outDir)/\(name).json"
    if let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]) {
        try? data.write(to: URL(fileURLWithPath: path)); print("wrote \(path)"); fflush(stdout)
    }
}
func sym(_ n: String) -> NSImage? { NSImage(systemSymbolName: n, accessibilityDescription: nil) }

final class P: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var bg: NSWindow?
    var test: NSWindow!
    var status: NSStatusItem!
    var opened = 0
    @objc func noop(_ sender: Any?) { print("ACTION \((sender as? NSMenuItem)?.title ?? "?") \(CACurrentMediaTime())"); fflush(stdout) }

    func add(_ m: NSMenu, _ t: String, _ k: String = "", _ mods: NSEvent.ModifierFlags = [.command], img: String? = nil,
             state: NSControl.StateValue = .off, enabled: Bool = true, indent: Int = 0) -> NSMenuItem {
        let it = NSMenuItem(title: t, action: enabled ? #selector(noop(_:)) : nil, keyEquivalent: k)
        it.keyEquivalentModifierMask = mods; it.target = self; it.state = state; it.isEnabled = enabled; it.indentationLevel = indent
        if let i = img { it.image = sym(i) }
        m.addItem(it); return it
    }
    func menu(_ t: String) -> NSMenu { let m = NSMenu(title: t); m.autoenablesItems = false; m.delegate = self; return m }

    func build() {
        let main = NSMenu()
        func top(_ m: NSMenu) { let it = NSMenuItem(title: m.title, action: nil, keyEquivalent: ""); it.submenu = m; main.addItem(it) }
        let app = menu("MenuProbe")
        _ = add(app, "About MenuProbe"); app.addItem(.separator())
        _ = add(app, "Settings…", ","); app.addItem(.separator())
        _ = add(app, "Hide MenuProbe", "h"); _ = add(app, "Hide Others", "h", [.command, .option]); _ = add(app, "Show All", enabled: false)
        app.addItem(.separator()); _ = add(app, "Quit MenuProbe", "q")
        top(app)
        // plain: no state, no images
        let plain = menu("Plain")
        _ = add(plain, "New Folder", "N", [.command, .shift]); _ = add(plain, "New Window", "n")
        _ = add(plain, "Force Quit…", "\u{1b}", [.command, .option]); _ = add(plain, "Emoji & Symbols", "e", [.function])
        _ = add(plain, "Lock Screen", "q", [.command, .control]);
        _ = add(plain, "Move to Bin", "\u{8}"); _ = add(plain, "Zoom In", "+"); _ = add(plain, "Disabled Row", enabled: false)
        plain.addItem(.separator())
        let sub = menu("Sort By"); for t in ["Name", "Kind", "Date Modified", "Size"] { _ = add(sub, t) }
        let si = add(plain, "Sort By"); plain.setSubmenu(sub, for: si)
        let alt = add(plain, "Close Window", "w"); _ = alt
        let alt2 = add(plain, "Close All Windows", "w", [.command, .option]); alt2.isAlternate = true
        top(plain)
        // states
        let st = menu("States")
        _ = add(st, "Checked Row", state: .on); _ = add(st, "Mixed Row", state: .mixed); _ = add(st, "Off Row")
        _ = add(st, "Indent 1", indent: 1); _ = add(st, "Indent 2", indent: 2); _ = add(st, "Checked Disabled", state: .on, enabled: false)
        _ = add(st, "With Shortcut", "s", state: .on)
        top(st)
        // icons
        let ic = menu("Icons")
        _ = add(ic, "New Window", "n", img: "macwindow"); _ = add(ic, "Copy", "c", img: "doc.on.doc"); _ = add(ic, "Bin", "\u{8}", img: "trash")
        _ = add(ic, "No Icon Row"); _ = add(ic, "Checked Icon", img: "star", state: .on)
        top(ic)
        // long
        let lg = menu("Long"); for i in 1...90 { _ = add(lg, "Long item \(i)") }
        top(lg)
        // tiny
        let tn = menu("A"); _ = add(tn, "A"); top(tn)
        NSApp.mainMenu = main
        // status item with a wide menu
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        status.button?.title = "MP"
        let sm = menu("Status"); _ = add(sm, "A very wide status item menu row to test the right edge clamp of pull-down menus against the screen edge, padded with more words", "x"); _ = add(sm, "Second row")
        status.menu = sm
    }

    func setBG(_ c: String) {
        bg?.orderOut(nil); bg = nil
        guard c != "none" else { return }
        let f = NSScreen.main!.frame
        let w = NSWindow(contentRect: f, styleMask: [.borderless], backing: .buffered, defer: false)
        w.backgroundColor = c == "white" ? .white : c == "black" ? .black : NSColor(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        w.hasShadow = false; w.isReleasedWhenClosed = false
        w.setFrame(f, display: true); w.orderFront(nil); w.order(.below, relativeTo: test.windowNumber)
        bg = w
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        if mode != "system" { NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua) }
        build()
        test = NSWindow(contentRect: NSRect(x: 400, y: 300, width: 600, height: 400), styleMask: [.titled, .closable, .miniaturizable, .resizable],
                        backing: .buffered, defer: false)
        test.title = "Menu probe"; test.isReleasedWhenClosed = false; test.collectionBehavior = [.fullScreenPrimary]
        let cv = NSView(); cv.wantsLayer = true; cv.layer?.backgroundColor = NSColor(srgbRed: 0.85, green: 0.25, blue: 0.2, alpha: 1).cgColor
        test.contentView = cv
        test.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        setBG(bgArg)
        let t = Timer(timeInterval: 0.15, repeats: true) { _ in self.poll() }
        RunLoop.main.add(t, forMode: .common)
        print("ready accent=\(UserDefaults.standard.object(forKey: "AppleAccentColor") ?? "nil")"); fflush(stdout)
    }

    func poll() {
        let p = "\(outDir)/cmd"
        guard let c = try? String(contentsOfFile: p, encoding: .utf8) else { return }
        try? FileManager.default.removeItem(atPath: p)
        let a = c.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").map(String.init)
        guard let k = a.first else { return }
        print("CMD \(a)"); fflush(stdout)
        switch k {
        case "bg": setBG(a.count > 1 ? a[1] : "none")
        case "fs": test.toggleFullScreen(nil)
        case "ctx":
            let m = menu("Context")
            _ = add(m, "Get Info", "i"); _ = add(m, "Rename"); m.addItem(.separator()); _ = add(m, "Copy", "c", img: "doc.on.doc"); _ = add(m, "Paste")
            let x = Double(a[1])!, y = Double(a[2])!
            DispatchQueue.main.async { m.popUp(positioning: nil, at: NSPoint(x: x, y: y), in: self.test.contentView) }
        case "dump": dumpAll(a.count > 1 ? a[1] : "dump")
        case "quit": NSApp.terminate(nil)
        default: break
        }
    }

    func dumpAll(_ name: String) {
        let ws = NSApp.windows.filter { $0.isVisible && $0 !== bg && $0 !== test }
        write(name, ws.map { dumpWindow($0) })
        for w in ws { print("WIN \(name) \(type(of: w)) \(r(w.frame)) level \(w.level.rawValue)") }
        fflush(stdout)
    }
    func menuWillOpen(_ m: NSMenu) {
        opened += 1
        let name = "\(m.title.replacingOccurrences(of: " ", with: ""))-\(mode)-\(opened)"
        print("OPEN \(m.title) \(CACurrentMediaTime())"); fflush(stdout)
        let t = Timer(timeInterval: 0.4, repeats: false) { _ in self.dumpAll(name) }
        RunLoop.main.add(t, forMode: .common)
    }
    func menuDidClose(_ m: NSMenu) { print("CLOSE \(m.title) \(CACurrentMediaTime())"); fflush(stdout) }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let p = P()
app.delegate = p
Timer.scheduledTimer(withTimeInterval: 900, repeats: false) { _ in exit(0) }
app.run()
