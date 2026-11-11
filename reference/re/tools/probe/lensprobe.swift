// lensprobe: SwiftUI glass with CONTENT LENSING (the Spotlight field recipe), built through SwiftUI/SwiftUICore SPI
// that has no public declaration:  content._glassEffect(_Glass.regular.surfaceSize(.large) + contentEffect = .lense, in: shape)
// AppKit's NSGlassEffectView._contentLensing never creates the glassForeground filter (7 property combinations tried),
// so the SPI is called by symbol name. Opaque values are carried in big POD buffers (passed/returned indirectly, the
// same ABI as resilient types); the opaque `some View` result is turned into `any View` by hand.
// lensprobe <config.json>
// config: { "pattern": "solid:90,90,90" (backdrop), "content": "gradx"|"grady"|"grad"|"checker:4"|..., "origin": [x,yTop], "size": [w,h],
//           "secs": 4, "dump": "/path.json",
//           "views": [ { "frame": [x,yTop,w,h], "shape": "capsule"|"rrect:40", "lense": true, "size": "large"|"medium"|"small"|"auto",
//                        "base": "regular"|"clear"|"dock", "inset": 0, "content": "none" } ] }
import AppKit
import SwiftUI

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


// ---- opaque storage
struct B64 { var a: UInt64 = 0, b: UInt64 = 0, c: UInt64 = 0, d: UInt64 = 0, e: UInt64 = 0, f: UInt64 = 0, g: UInt64 = 0, h: UInt64 = 0 }
struct B512 { var a = B64(), b = B64(), c = B64(), d = B64(), e = B64(), f = B64(), g = B64(), h = B64() }
struct B4096 { var a = B512(), b = B512(), c = B512(), d = B512(), e = B512(), f = B512(), g = B512(), h = B512() }

@_silgen_name("$s7SwiftUI6_GlassV7regularACvgZ") func _glassRegular() -> B512
@_silgen_name("$s7SwiftUI6_GlassV5clearACvgZ") func _glassClear() -> B512
@_silgen_name("$s7SwiftUI6_GlassV4dockACvgZ") func _glassDock() -> B512
@_silgen_name("$s7SwiftUI6_GlassV13ContentEffectV5lenseAEvgZ") func _ceLense() -> B512
@_silgen_name("$s7SwiftUI6_GlassV11SurfaceSizeV5largeAEvgZ") func _ssLarge() -> B512
@_silgen_name("$s7SwiftUI6_GlassV11SurfaceSizeV6mediumAEvgZ") func _ssMedium() -> B512
@_silgen_name("$s7SwiftUI6_GlassV11SurfaceSizeV5smallAEvgZ") func _ssSmall() -> B512
extension B512 {
    @_silgen_name("$s7SwiftUI6_GlassV13contentEffectAC07ContentE0Vvs") mutating func setContentEffect(_ e: __owned B512)
    @_silgen_name("$s7SwiftUI6_GlassV11surfaceSizeyA2C07SurfaceE0VF") func surfaceSize(_ s: B512) -> B512
}
extension View {
    @_silgen_name("$s7SwiftUI4ViewPAAE12_glassEffect_2inQrAA6_GlassV_qd__tAA5ShapeRd__lF") func _spiGlassEffect<S: Shape>(_ g: B512, in shape: S) -> B4096
}
@_silgen_name("swift_getOpaqueTypeMetadata2") func _opaqueMeta(_ req: UInt, _ args: UnsafeRawPointer, _ desc: UnsafeRawPointer, _ idx: UInt) -> (UnsafeRawPointer, UInt)
@_silgen_name("swift_getOpaqueTypeConformance2") func _opaqueConf(_ args: UnsafeRawPointer, _ desc: UnsafeRawPointer, _ idx: UInt) -> UnsafeRawPointer
@_silgen_name("swift_allocBox") func _allocBox(_ meta: UnsafeRawPointer) -> (UnsafeRawPointer, UnsafeMutableRawPointer)

struct ExistentialView { var b0: UInt = 0, b1: UInt = 0, b2: UInt = 0; var meta: UnsafeRawPointer; var wt: UnsafeRawPointer }

func glassed<V: View, S: Shape>(_ content: V, _ glass: B512, _ shape: S) -> AnyView {
    var raw = content._spiGlassEffect(glass, in: shape)
    let vEx: any View.Type = V.self, sEx: any Shape.Type = S.self
    let vp = unsafeBitCast(vEx, to: (UnsafeRawPointer, UnsafeRawPointer).self), sp = unsafeBitCast(sEx, to: (UnsafeRawPointer, UnsafeRawPointer).self)
    var args: [UnsafeRawPointer] = [vp.0, sp.0, vp.1, sp.1]
    let desc = UnsafeRawPointer(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "$s7SwiftUI4ViewPAAE12_glassEffect_2inQrAA6_GlassV_qd__tAA5ShapeRd__lFQOMQ")!)
    let meta = _opaqueMeta(0, &args, desc, 0).0
    let wt = _opaqueConf(&args, desc, 1)          // index 0 = the underlying type, 1 = its View conformance
    let vwt = meta.advanced(by: -8).load(as: UnsafeRawPointer.self)
    let size = vwt.advanced(by: 8 * 8).load(as: Int.self), flags = vwt.advanced(by: 8 * 10).load(as: UInt32.self)
    precondition(size <= MemoryLayout<B4096>.size, "opaque view too large: \(size)")
    var ex = ExistentialView(meta: meta, wt: wt)
    withUnsafeMutableBytes(of: &raw) { src in
        if flags & 0x20000 != 0 || size > 24 {        // not stored inline: boxed
            let box = _allocBox(meta)
            box.1.copyMemory(from: src.baseAddress!, byteCount: size)
            ex.b0 = UInt(bitPattern: box.0)
        } else {
            withUnsafeMutableBytes(of: &ex) { $0.baseAddress!.copyMemory(from: src.baseAddress!, byteCount: size) }
        }
    }
    let v = unsafeBitCast(ex, to: (any View).self)
    return AnyView(v)
}

class Flipped: NSView { override var isFlipped: Bool { true } }
class KeyWindow: NSWindow { override var canBecomeKey: Bool { true }; override var canBecomeMain: Bool { true } }

class D: NSObject, NSApplicationDelegate {
    var win: NSWindow!
    var hosts: [(NSView, [String: Any])] = []
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: (cfg["mode"] as? String ?? "dark") == "dark" ? .darkAqua : .aqua)
        let scr = NSScreen.screens[0]
        let o = arr(cfg["origin"]), sz = arr(cfg["size"]); let W = sz[0], H = sz[1]
        win = KeyWindow(contentRect: NSRect(x: o[0], y: scr.frame.height - o[1] - H, width: W, height: H), styleMask: [.borderless], backing: .buffered, defer: false)
        win.hasShadow = false; win.isOpaque = true; win.colorSpace = scr.colorSpace
        let cs = scr.colorSpace?.cgColorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let bg = Flipped(frame: NSRect(x: 0, y: 0, width: W, height: H)); bg.wantsLayer = true
        let pat = Flipped(frame: bg.bounds); pat.wantsLayer = true
        pat.layer?.contents = makePattern(cfg["pattern"] as? String ?? "solid:90,90,90", Int(W * 2), Int(H * 2), cs); pat.layer?.contentsScale = 2
        pat.layer?.magnificationFilter = .nearest; pat.layer?.minificationFilter = .nearest
        bg.addSubview(pat)
        for any in (cfg["views"] as? [Any]) ?? [] {
            let vc = any as! [String: Any]; let f = arr(vc["frame"]); let ins = num(vc["inset"])
            let cspec = vc["content"] as? String ?? cfg["content"] as? String ?? "grad"       // "none" = empty glass (backdrop tests)
            let img = makePattern(cspec == "none" ? "solid:0,0,0" : cspec, Int((f[2] - 2 * ins) * 2), Int((f[3] - 2 * ins) * 2), cs)
            let content = Image(decorative: img, scale: 2).interpolation(.none).opacity(cspec == "none" ? 0 : 1).frame(width: f[2] - 2 * ins, height: f[3] - 2 * ins).padding(ins)
            var g: B512
            switch vc["base"] as? String ?? "regular" { case "clear": g = _glassClear(); case "dock": g = _glassDock(); default: g = _glassRegular() }
            switch vc["size"] as? String ?? "auto" { case "large": g = g.surfaceSize(_ssLarge()); case "medium": g = g.surfaceSize(_ssMedium()); case "small": g = g.surfaceSize(_ssSmall()); default: break }
            if (vc["lense"] as? Bool) == true { g.setContentEffect(_ceLense()) }
            let shape = vc["shape"] as? String ?? "capsule"
            let v: AnyView
            if shape.hasPrefix("rrect:") { v = glassed(content, g, RoundedRectangle(cornerRadius: CGFloat(Double(shape.dropFirst(6))!), style: .continuous)) }
            else { v = glassed(content, g, Capsule()) }
            let host = NSHostingView(rootView: v)
            host.frame = NSRect(x: f[0], y: f[1], width: f[2], height: f[3])
            bg.addSubview(host); hosts.append((host, vc))
        }
        win.contentView = bg
        win.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            if let p = cfg["dump"] as? String {
                let out: [String: Any] = ["keyWindow": self.win.isKeyWindow, "views": self.hosts.map { h, vc -> Any in ["config": vc, "hostFrame": [h.frame.minX, h.frame.minY, h.frame.width, h.frame.height], "layers": h.layer.map { dumpLayer($0) } ?? [:]] as [String: Any] }]
                try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]).write(to: URL(fileURLWithPath: p))
            }
            print("READY"); fflush(stdout)
        }
        let et = Timer(timeInterval: Double(num(cfg["secs"])), repeats: false) { _ in print("END"); fflush(stdout); exit(0) }
        RunLoop.main.add(et, forMode: .common)
    }
}
// a bad SPI call must not leave a crash-report dialog on the screen
for sig in [SIGSEGV, SIGBUS, SIGILL, SIGTRAP, SIGABRT] { signal(sig) { _ in _exit(70) } }
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D(); app.delegate = d; app.run()
