// ncbg: full-screen solid backdrop at level -2147483600, just above desktop icons and desktop widgets (-2147483601) (hides desktop icons and desktop widgets),
// so Notification Center glass can be measured over known colours. Reads "r g b" (0-255) from the file given as
// argv[1] every 0.1 s ("checker N" = N pt black/white checkerboard); "quit" in the file terminates. Ignores mouse events. Usage: ncbg <colourfile>
import AppKit
let path = CommandLine.arguments[1]
class D: NSObject, NSApplicationDelegate {
    var win: NSWindow!; var last = ""
    func applicationDidFinishLaunching(_ n: Notification) {
        let f = NSScreen.screens[0].frame
        win = NSWindow(contentRect: f, styleMask: [.borderless], backing: .buffered, defer: false)
        win.level = NSWindow.Level(rawValue: -2147483600)
        win.collectionBehavior = [.canJoinAllSpaces, .stationary]
        win.ignoresMouseEvents = true; win.hasShadow = false
        win.orderFrontRegardless()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in self.poll() }; poll()
    }
    func poll() {
        guard let s = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t == last { return }; last = t
        if t == "quit" { NSApp.terminate(nil) }
        if t.hasPrefix("checker") {   // "checker N": black/white checkerboard with N pt squares
            let n = CGFloat(Double(t.split(separator: " ").last!) ?? 8)
            let img = NSImage(size: NSSize(width: 2*n, height: 2*n), flipped: false) { r in
                NSColor.white.setFill(); r.fill(); NSColor.black.setFill()
                NSRect(x: 0, y: 0, width: n, height: n).fill(); NSRect(x: n, y: n, width: n, height: n).fill(); return true }
            win.backgroundColor = NSColor(patternImage: img); return
        }
        let c = t.split(separator: " ").compactMap { Double($0) }
        if c.count == 3 { win.backgroundColor = NSColor(srgbRed: c[0]/255, green: c[1]/255, blue: c[2]/255, alpha: 1) }
    }
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let d = D(); app.delegate = d; app.run()
