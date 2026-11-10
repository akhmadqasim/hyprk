// hyprk toolbar probe: a standard AppKit window (unified toolbar, sidebar split view, scroll view) like Finder and
// System Settings, then lists every glass / material surface in it: CABackdropLayers with their filters, glass
// views with variant and subvariant, visual effect views, corner radii, shadows. macOS only.
// Build: swiftc -swift-version 5 -O -o toolbar toolbar.swift   Run: ./toolbar <outdir> light|dark [unified|expanded|compact]
import AppKit
import QuartzCore

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let style = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "unified"

func r(_ x: CGRect) -> [Double] { [x.origin.x, x.origin.y, x.width, x.height].map { (Double($0) * 10).rounded() / 10 } }

func kv(_ o: NSObject, _ k: String) -> Any? {
    guard o.responds(to: NSSelectorFromString(k)) else { return nil }
    return o.value(forKey: k)
}

func filterInfo(_ f: Any) -> [String: Any] {
    guard let o = f as? NSObject else { return ["?": String(describing: f)] }
    var d: [String: Any] = [:]
    if let n = kv(o, "name") { d["name"] = String(describing: n) }
    if let t = kv(o, "type") { d["type"] = String(describing: t) }
    if let ks = kv(o, "inputKeys") as? [String] {
        var inp: [String: String] = [:]
        for k in ks { if let v = o.value(forKey: k) { inp[k] = String(describing: v).prefix(160).description } }
        d["inputs"] = inp
    }
    return d
}

// owning view for each layer, so a backdrop can be named by its view class
var owner: [ObjectIdentifier: NSView] = [:]
func mapViews(_ v: NSView) {
    if let l = v.layer { owner[ObjectIdentifier(l)] = v }
    v.subviews.forEach(mapViews)
}

var surfaces: [[String: Any]] = []
func walk(_ l: CALayer, _ path: [String], _ win: NSWindow) {
    let cls = "\(type(of: l))"
    let v = owner[ObjectIdentifier(l)]
    let name = v.map { "\(type(of: $0))" } ?? cls
    let p = path + [name]
    var hit: [String: Any] = [:]
    if cls.contains("Backdrop") { hit["backdrop"] = true }
    if let fs = l.filters, !fs.isEmpty { hit["filters"] = fs.map(filterInfo) }
    if let fs = l.backgroundFilters, !fs.isEmpty { hit["backgroundFilters"] = fs.map(filterInfo) }
    if let cf = l.compositingFilter { hit["compositingFilter"] = String(describing: cf) }
    if let v = v {
        let vc = "\(type(of: v))"
        if v is NSGlassEffectView || vc.lowercased().contains("glass") {
            hit["glassView"] = vc
            for k in ["_variant", "_subvariant", "_adaptiveAppearance", "_interactionState", "_scrimState", "_subduedState",
                      "cornerRadius", "style"] {
                if let x = try? catchKV(v, k) { hit[k] = String(describing: x) }
            }
        }
        if let e = v as? NSVisualEffectView { hit["visualEffect"] = ["material": e.material.rawValue, "blending": e.blendingMode.rawValue, "state": e.state.rawValue] }
    }
    if !hit.isEmpty {
        hit["path"] = p.suffix(6).joined(separator: " > ")
        hit["layerClass"] = cls
        hit["frameInWindow"] = r(l.superlayer.map { $0.convert(l.frame, to: nil) } ?? l.frame)
        if let v = v, let _ = v.window { hit["viewFrameInWindow"] = r(v.convert(v.bounds, to: nil)) }
        hit["cornerRadius"] = Double(l.cornerRadius)
        if l.shadowOpacity != 0 { hit["shadow"] = ["opacity": l.shadowOpacity, "radius": l.shadowRadius, "offset": [l.shadowOffset.width, l.shadowOffset.height]] }
        if let c = l.backgroundColor { hit["backgroundColor"] = String(describing: c) }
        hit["hidden"] = l.isHidden
        hit["opacity"] = l.opacity
        surfaces.append(hit)
    }
    for s in l.sublayers ?? [] { walk(s, p, win) }
}

// value(forKey:) on an unknown key raises an ObjC exception, which Swift cannot catch: only ask when the selector exists
func catchKV(_ o: NSObject, _ k: String) throws -> Any? {
    if o.responds(to: NSSelectorFromString(k)) { return o.value(forKey: k) }
    let ivar = class_getInstanceVariable(type(of: o), k)
    if ivar != nil { return o.value(forKey: k) }
    return nil
}

func viewTree(_ v: NSView, _ depth: Int = 0) -> [String: Any] {
    var d: [String: Any] = ["class": "\(type(of: v))", "frameInWindow": r(v.convert(v.bounds, to: nil))]
    if v.isHidden { d["hidden"] = true }
    if let c = v as? NSControl, let cell = c.cell { d["cell"] = "\(type(of: cell))" }
    if let b = v as? NSButton { d["bezel"] = b.bezelStyle.rawValue; d["bordered"] = b.isBordered }
    if let s = v as? NSSegmentedControl { d["segments"] = s.segmentCount; d["segmentStyle"] = s.segmentStyle.rawValue }
    if depth < 30, !v.subviews.isEmpty { d["subviews"] = v.subviews.map { viewTree($0, depth + 1) } }
    return d
}

final class SidebarVC: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let rows = ["Favourites", "AirDrop", "Recents", "Applications", "Desktop", "Documents", "Downloads", "Locations", "iCloud Drive", "Network"]
    override func loadView() {
        let sv = NSScrollView(); let tv = NSTableView()
        tv.addTableColumn(NSTableColumn(identifier: .init("c"))); tv.headerView = nil
        tv.style = .sourceList; tv.dataSource = self; tv.delegate = self
        sv.documentView = tv; sv.drawsBackground = false
        view = sv
    }
    func numberOfRows(in tableView: NSTableView) -> Int { rows.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let t = NSTextField(labelWithString: rows[row]); return t
    }
}

final class ContentVC: NSViewController {
    override func loadView() {
        let sv = NSScrollView(); let tv = NSTextView()
        tv.string = (0..<200).map { "Line \($0) of document content under the toolbar." }.joined(separator: "\n")
        sv.documentView = tv; sv.hasVerticalScroller = true
        view = sv
    }
}

final class Probe: NSObject, NSApplicationDelegate, NSToolbarDelegate {
    var win: NSWindow!
    let ids: [NSToolbarItem.Identifier] = [.toggleSidebar, .sidebarTrackingSeparator, .init("nav"), .init("title"), .flexibleSpace,
                                          .init("view"), .init("group"), .init("share"), .init("tag"), .init("action"), .init("search")]
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        win = NSWindow(contentRect: NSRect(x: 200, y: 200, width: 980, height: 560),
                       styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        win.title = "Downloads"
        let split = NSSplitViewController()
        let side = NSSplitViewItem(sidebarWithViewController: SidebarVC())
        split.addSplitViewItem(side)
        split.addSplitViewItem(NSSplitViewItem(viewController: ContentVC()))
        win.contentViewController = split
        win.setContentSize(NSSize(width: 980, height: 560))
        let tb = NSToolbar(identifier: "probe"); tb.delegate = self; tb.displayMode = .iconOnly
        win.toolbar = tb
        win.toolbarStyle = style == "expanded" ? .expanded : style == "compact" ? .unifiedCompact : .unified
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.dump() }
    }
    func toolbarDefaultItemIdentifiers(_ t: NSToolbar) -> [NSToolbarItem.Identifier] { ids }
    func toolbarAllowedItemIdentifiers(_ t: NSToolbar) -> [NSToolbarItem.Identifier] { ids }
    func toolbar(_ t: NSToolbar, itemForItemIdentifier id: NSToolbarItem.Identifier, willBeInsertedIntoToolbar f: Bool) -> NSToolbarItem? {
        func img(_ s: String) -> NSImage { NSImage(systemSymbolName: s, accessibilityDescription: s)! }
        switch id.rawValue {
        case "nav":
            let g = NSToolbarItemGroup(itemIdentifier: id, images: [img("chevron.left"), img("chevron.right")], selectionMode: .momentary,
                                       labels: ["Back", "Forward"], target: nil, action: nil)
            g.controlRepresentation = .expanded
            return g
        case "title":
            let i = NSToolbarItem(itemIdentifier: id); i.view = NSTextField(labelWithString: "Downloads"); return i
        case "view":
            let g = NSToolbarItemGroup(itemIdentifier: id, images: [img("square.grid.2x2"), img("list.bullet"), img("rectangle.split.3x1"), img("rectangle.grid.1x2")],
                                       selectionMode: .selectOne, labels: ["Icons", "List", "Columns", "Gallery"], target: nil, action: nil)
            g.controlRepresentation = .expanded; g.selectedIndex = 0
            return g
        case "group":
            let i = NSToolbarItem(itemIdentifier: id); i.image = img("square.grid.3x1.below.line.grid.1x2"); i.isBordered = true; i.label = "Group"; return i
        case "share":
            let i = NSSharingServicePickerToolbarItem(itemIdentifier: id); return i
        case "tag":
            let i = NSToolbarItem(itemIdentifier: id); i.image = img("tag"); i.isBordered = true; i.label = "Tags"; return i
        case "action":
            let i = NSToolbarItem(itemIdentifier: id); i.image = img("ellipsis.circle"); i.isBordered = true; i.label = "Action"; return i
        case "search":
            return NSSearchToolbarItem(itemIdentifier: id)
        default: return nil
        }
    }
    func dump() {
        var top: NSView? = win.contentView
        while let s = top?.superview { top = s }
        mapViews(top!)
        var root = top!.layer
        while let s = root?.superlayer { root = s }
        walk(root!, [], win)
        let out: [String: Any] = ["mode": mode, "toolbarStyle": style, "windowFrame": r(win.frame),
                                  "contentLayoutRect": r(win.contentLayoutRect), "surfaces": surfaces, "views": viewTree(top!)]
        let path = "\(outDir)/toolbar-\(style)-\(mode).json"
        let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
        try! data.write(to: URL(fileURLWithPath: path))
        print("wrote \(path)", surfaces.count, "surfaces")
        // window picture without the shadow, 2x
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        p.arguments = ["-x", "-o", "-l", "\(win.windowNumber)", "\(outDir)/toolbar-\(style)-\(mode).png"]
        try? p.run(); p.waitUntilExit()
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let probe = Probe()
app.delegate = probe
Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in print("timeout"); exit(2) }
app.run()
