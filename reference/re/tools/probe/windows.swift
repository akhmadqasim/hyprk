// hyprk window-chrome probe: builds plain titled windows (TextEdit-like), a utility panel and a toolbar window with a
// subtitle, then dumps titlebar metrics (heights, button frames, title font and colour), every backdrop / filter layer
// in the frame view, and the values of private NSWindow / NSThemeFrame getters whose names mention corner or shadow.
// Also dumps the standard NSCursor images (2x PNG + hotspot). macOS only.
// Build: swiftc -swift-version 5 -O -o windows windows.swift   Run: ./windows <outdir> light|dark [cursors]
import AppKit
import QuartzCore
import ObjectiveC

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let extra = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : ""

func r(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 100).rounded() / 100 } }

func colorInfo(_ c: NSColor?) -> Any {
    guard let c = c else { return NSNull() }
    var out: [String: Any] = ["desc": c.description]
    if let s = c.usingColorSpace(.sRGB) {
        out["srgb"] = [s.redComponent, s.greenComponent, s.blueComponent, s.alphaComponent].map { (Double($0) * 1000).rounded() / 1000 }
    }
    return out
}

func fontInfo(_ f: NSFont?) -> Any {
    guard let f = f else { return NSNull() }
    let traits = f.fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey: Any]
    return ["name": f.fontName, "family": f.familyName ?? "?", "size": Double(f.pointSize),
            "weight": (traits?[.weight] as? NSNumber)?.doubleValue ?? -9, "width": (traits?[.width] as? NSNumber)?.doubleValue ?? -9]
}

// private zero-argument getters whose names contain any of `keys`, with their values
func getters(_ o: NSObject, _ keys: [String]) -> [String: String] {
    var out: [String: String] = [:]
    var c: AnyClass? = type(of: o)
    while let cls = c, cls != NSResponder.self, cls != NSObject.self {
        var n: UInt32 = 0
        if let list = class_copyMethodList(cls, &n) {
            for i in 0..<Int(n) {
                let sel = method_getName(list[i]); let name = NSStringFromSelector(sel)
                if name.contains(":") || out[name] != nil { continue }
                let lname = name.lowercased()
                guard keys.contains(where: { lname.contains($0) }) else { continue }
                var rt = [CChar](repeating: 0, count: 64); method_getReturnType(list[i], &rt, 64)
                let t = String(cString: rt)
                // only plain getters: scalar, struct or object return; skip anything that sounds like an action
                if t == "v" || ["update", "invalidate", "reset", "set", "draw", "remove", "add", "make", "begin", "end", "flush", "recompute", "_did", "_will"].contains(where: { lname.hasPrefix($0) || lname.hasPrefix("_" + $0) }) { continue }
                if t.hasPrefix("^") || t.hasPrefix("r^") || t == "*" { out[name] = "<ptr \(t)>"; continue }
                if let v = o.value(forKey: name) { out[name] = String(describing: v).prefix(4000).description } else { out[name] = "nil (\(t))" }
            }
            free(list)
        }
        c = class_getSuperclass(cls)
    }
    return out
}

func layers(_ l: CALayer, _ path: String, _ out: inout [[String: Any]], _ owner: [ObjectIdentifier: NSView]) {
    let cls = "\(type(of: l))"
    let vname = owner[ObjectIdentifier(l)].map { "\(type(of: $0))" } ?? cls
    let p = path.isEmpty ? vname : path + " > " + vname
    var d: [String: Any] = [:]
    if cls.contains("Backdrop") { d["backdrop"] = true }
    if let fs = l.filters, !fs.isEmpty {
        d["filters"] = fs.map { f -> [String: Any] in
            guard let o = f as? NSObject else { return ["?": String(describing: f)] }
            var fd: [String: Any] = ["name": String(describing: o.value(forKey: "name") ?? "?")]
            for k in ["inputRadius", "inputAmount", "inputNormalizeEdges", "inputHardEdges"] where o.responds(to: NSSelectorFromString(k)) || true {
                if let v = (try? { () -> Any? in o.value(forKey: k) }()) ?? nil { fd[k] = String(describing: v) }
            }
            if let m = o.value(forKey: "inputColorMatrix") as? NSValue {
                var buf = [Float](repeating: 0, count: 20); m.getValue(&buf, size: 80)
                fd["inputColorMatrix"] = buf.map { (Double($0) * 10000).rounded() / 10000 }
            }
            return fd
        }
    }
    if let cf = l.compositingFilter { d["compositingFilter"] = String(describing: cf) }
    if let bg = l.backgroundColor { d["backgroundColor"] = colorInfo(NSColor(cgColor: bg)) }
    if l.borderWidth > 0 { d["border"] = ["width": l.borderWidth, "color": colorInfo(l.borderColor.flatMap { NSColor(cgColor: $0) })] }
    if l.cornerRadius > 0 { d["cornerRadius"] = l.cornerRadius; d["cornerCurve"] = l.cornerCurve.rawValue }
    if !d.isEmpty || owner[ObjectIdentifier(l)] != nil {
        d["path"] = p.split(separator: ">").suffix(5).joined(separator: ">")
        d["layer"] = cls
        d["frameInWindow"] = r(l.superlayer.map { $0.convert(l.frame, to: nil) } ?? l.frame)
        if l.isHidden { d["hidden"] = true }
        if l.opacity != 1 { d["opacity"] = l.opacity }
        out.append(d)
    }
    for s in l.sublayers ?? [] { layers(s, p, &out, owner) }
}

func viewTree(_ v: NSView, _ depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frameInWindow": r(v.convert(v.bounds, to: nil))]
    if v.isHidden { d["hidden"] = true }
    if let t = v as? NSTextField { d["text"] = t.stringValue; d["font"] = fontInfo(t.font); d["textColor"] = colorInfo(t.textColor)
        d["alignment"] = t.alignment.rawValue; d["lineBreak"] = t.lineBreakMode.rawValue }
    if let b = v as? NSButton { d["title"] = b.title; d["enabled"] = b.isEnabled }
    if let e = v as? NSVisualEffectView { d["visualEffect"] = ["material": e.material.rawValue, "blending": e.blendingMode.rawValue, "state": e.state.rawValue] }
    if v is NSGlassEffectView || "\(type(of: v))".contains("Glass") {
        for k in ["_variant", "_subvariant", "cornerRadius"] where v.responds(to: NSSelectorFromString(k)) { d[k] = String(describing: v.value(forKey: k) ?? "nil") }
    }
    if depth < 25, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { viewTree($0, depth + 1) } }
    return d
}

func dump(_ w: NSWindow, _ name: String) -> [String: Any] {
    var top: NSView = w.contentView!
    while let s = top.superview { top = s }
    var owner: [ObjectIdentifier: NSView] = [:]
    func map(_ v: NSView) { if let l = v.layer { owner[ObjectIdentifier(l)] = v }; v.subviews.forEach(map) }
    map(top)
    var root = top.layer!
    while let s = root.superlayer { root = s }
    var ls: [[String: Any]] = []
    layers(root, "", &ls, owner)
    var buttons: [String: Any] = [:]
    for (k, b) in [("close", NSWindow.ButtonType.closeButton), ("min", .miniaturizeButton), ("zoom", .zoomButton), ("proxy", .documentIconButton)] {
        if let v = w.standardWindowButton(b) {
            buttons[k] = ["frameInWindow": r(v.convert(v.bounds, to: nil)), "enabled": v.isEnabled, "hidden": v.isHidden, "class": "\(type(of: v))"]
        }
    }
    let frame = w.frame
    let tbh = frame.height - w.contentLayoutRect.height
    return ["name": name, "key": w.isKeyWindow, "frame": r(frame), "contentLayoutRect": r(w.contentLayoutRect),
            "titlebarHeight": Double(tbh), "styleMask": w.styleMask.rawValue, "toolbarStyle": w.toolbarStyle.rawValue,
            "titlebarSeparatorStyle": w.titlebarSeparatorStyle.rawValue, "backgroundColor": colorInfo(w.backgroundColor),
            "hasShadow": w.hasShadow, "buttons": buttons,
            "windowGetters": getters(w, ["corner", "shadow", "titlebar", "radius"]),
            "frameViewClass": "\(type(of: top))",
            "frameViewGetters": getters(top, ["corner", "shadow", "titlebar", "radius", "title", "button", "inset"]),
            "layers": ls, "views": viewTree(top)]
}

func pngData(_ img: NSImage) -> (Data, [Double])? {
    // largest representation
    let reps = img.representations
    let best = reps.max(by: { $0.pixelsWide * $0.pixelsHigh < $1.pixelsWide * $1.pixelsHigh })
    let pw = max(best?.pixelsWide ?? 0, Int(img.size.width * 2)), ph = max(best?.pixelsHigh ?? 0, Int(img.size.height * 2))
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4,
                                     hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
    rep.size = img.size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    img.draw(in: NSRect(origin: .zero, size: img.size))
    NSGraphicsContext.restoreGraphicsState()
    return (rep.representation(using: .png, properties: [:])!, [Double(pw), Double(ph)])
}

func dumpCursors() {
    var cs: [(String, NSCursor)] = [("arrow", .arrow), ("iBeam", .iBeam), ("pointingHand", .pointingHand), ("closedHand", .closedHand),
        ("openHand", .openHand), ("crosshair", .crosshair), ("disappearingItem", .disappearingItem), ("operationNotAllowed", .operationNotAllowed),
        ("dragLink", .dragLink), ("dragCopy", .dragCopy), ("contextualMenu", .contextualMenu), ("iBeamVertical", .iBeamCursorForVerticalLayout),
        ("resizeLeftRight", .resizeLeftRight), ("resizeUpDown", .resizeUpDown), ("resizeLeft", .resizeLeft), ("resizeRight", .resizeRight),
        ("resizeUp", .resizeUp), ("resizeDown", .resizeDown)]
    if #available(macOS 15.0, *) {
        cs.append(("columnResize", NSCursor.columnResize)); cs.append(("rowResize", NSCursor.rowResize))
        cs.append(("zoomIn", NSCursor.zoomIn)); cs.append(("zoomOut", NSCursor.zoomOut))
        let pos: [(String, NSCursor.FrameResizePosition)] = [("top", .top), ("left", .left), ("bottom", .bottom), ("right", .right),
            ("topLeft", .topLeft), ("topRight", .topRight), ("bottomLeft", .bottomLeft), ("bottomRight", .bottomRight)]
        for (n, p) in pos { cs.append(("frameResize-\(n)-all", NSCursor.frameResize(position: p, directions: .all))) }
        cs.append(("frameResize-left-inward", NSCursor.frameResize(position: .left, directions: .inward)))
        cs.append(("frameResize-left-outward", NSCursor.frameResize(position: .left, directions: .outward)))
    }
    var meta: [[String: Any]] = []
    try? FileManager.default.createDirectory(atPath: "\(outDir)/cursors", withIntermediateDirectories: true)
    for (n, c) in cs {
        let img = c.image
        var m: [String: Any] = ["name": n, "sizePt": [Double(img.size.width), Double(img.size.height)],
                                "hotSpotPt": [Double(c.hotSpot.x), Double(c.hotSpot.y)],
                                "reps": img.representations.map { "\($0.pixelsWide)x\($0.pixelsHigh)" }]
        if let (d, px) = pngData(img) { try? d.write(to: URL(fileURLWithPath: "\(outDir)/cursors/\(n).png")); m["png"] = "cursors/\(n).png"; m["px"] = px }
        meta.append(m)
    }
    let data = try! JSONSerialization.data(withJSONObject: meta, options: [.prettyPrinted, .sortedKeys])
    try! data.write(to: URL(fileURLWithPath: "\(outDir)/cursors.json"))
    print("cursors", meta.count)
}

final class Probe: NSObject, NSApplicationDelegate, NSToolbarDelegate {
    var doc: NSWindow!, util: NSPanel!, tbw: NSWindow!, fixed: NSWindow!
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        if extra == "cursors" { dumpCursors(); NSApp.terminate(nil); return }
        doc = NSWindow(contentRect: NSRect(x: 200, y: 300, width: 600, height: 360),
                       styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        doc.title = "Untitled document.txt"
        let sv = NSScrollView(); let tv = NSTextView(); tv.string = (0..<60).map { "Line \($0)" }.joined(separator: "\n")
        sv.documentView = tv; sv.hasVerticalScroller = true; doc.contentView = sv
        doc.representedURL = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
        util = NSPanel(contentRect: NSRect(x: 900, y: 300, width: 260, height: 200),
                       styleMask: [.titled, .closable, .utilityWindow, .resizable], backing: .buffered, defer: false)
        util.title = "Utility"
        tbw = NSWindow(contentRect: NSRect(x: 200, y: 750, width: 700, height: 260),
                       styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        tbw.title = "Inbox"; tbw.subtitle = "12 messages"
        let tb = NSToolbar(identifier: "p"); tb.delegate = self; tbw.toolbar = tb; tbw.toolbarStyle = .unified
        fixed = NSWindow(contentRect: NSRect(x: 1000, y: 650, width: 300, height: 200), styleMask: [.titled, .closable, .miniaturizable],
                         backing: .buffered, defer: false)
        fixed.title = "Fixed"
        for w in [tbw!, fixed!, util!, doc!] { w.makeKeyAndOrderFront(nil) }
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            var out: [String: Any] = ["mode": mode]
            out["docActive"] = dump(self.doc, "doc")
            out["utility"] = dump(self.util, "utility")
            out["toolbarSubtitle"] = dump(self.tbw, "toolbar")
            out["fixed"] = dump(self.fixed, "fixed")
            self.shot(self.doc, "doc-active"); self.shot(self.tbw, "toolbar-inactive")
            self.tbw.makeKeyAndOrderFront(nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                out["docInactive"] = dump(self.doc, "doc")
                out["toolbarActive"] = dump(self.tbw, "toolbar")
                self.shot(self.doc, "doc-inactive"); self.shot(self.tbw, "toolbar-active")
                let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
                try! data.write(to: URL(fileURLWithPath: "\(outDir)/probe-windows-\(mode).json"))
                print("wrote")
                NSApp.terminate(nil)
            }
        }
    }
    func shot(_ w: NSWindow, _ n: String) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-l", "\(w.windowNumber)", "\(outDir)/probe-\(n)-\(mode).png"]
        try? p.run(); p.waitUntilExit()
    }
    func toolbarDefaultItemIdentifiers(_ t: NSToolbar) -> [NSToolbarItem.Identifier] { [.init("a"), .flexibleSpace, .init("b")] }
    func toolbarAllowedItemIdentifiers(_ t: NSToolbar) -> [NSToolbarItem.Identifier] { [.init("a"), .flexibleSpace, .init("b")] }
    func toolbar(_ t: NSToolbar, itemForItemIdentifier id: NSToolbarItem.Identifier, willBeInsertedIntoToolbar f: Bool) -> NSToolbarItem? {
        let i = NSToolbarItem(itemIdentifier: id); i.image = NSImage(systemSymbolName: id.rawValue == "a" ? "tray" : "square.and.pencil", accessibilityDescription: nil)
        i.isBordered = true; i.label = id.rawValue; return i
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let probe = Probe()
app.delegate = probe
Timer.scheduledTimer(withTimeInterval: 25, repeats: false) { _ in print("timeout"); exit(2) }
app.run()
