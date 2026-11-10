// hyprk menu bar probe: a borderless window under the menu bar with a sharp test pattern (checkerboard, colour
// bars, black and white halves) so screenshots show whether the bar blurs, tints or dims what is under it, and
// what the open-menu title highlight is made of. Stays up for <seconds> with File/Edit/View/Window menus. macOS only.
// Build: swiftc -swift-version 5 -O -o menubar menubar.swift   Run: ./menubar light|dark [seconds]
import AppKit

let mode = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "light"
let secs = CommandLine.arguments.count > 2 ? Double(CommandLine.arguments[2])! : 30

final class Pattern: NSView {
    override func draw(_ r: NSRect) {
        let w = bounds.width, h = bounds.height
        // 0..30%: 4 pt checkerboard; 30..60%: colour bars; 60..80%: white; 80..100%: black
        NSColor.white.setFill(); bounds.fill()
        let cw = w * 0.3
        var y: CGFloat = 0
        while y < h {
            var x: CGFloat = 0
            while x < cw {
                if (Int(x / 4) + Int(y / 4)) % 2 == 0 { NSColor.black.setFill(); NSRect(x: x, y: y, width: 4, height: 4).fill() }
                x += 4
            }
            y += 4
        }
        let bars: [NSColor] = [.systemRed, .systemGreen, .systemBlue, .systemYellow, .systemPurple, .gray]
        let bw = w * 0.3 / CGFloat(bars.count)
        for (i, c) in bars.enumerated() { c.setFill(); NSRect(x: cw + CGFloat(i) * bw, y: 0, width: bw, height: h).fill() }
        NSColor.black.setFill(); NSRect(x: w * 0.8, y: 0, width: w * 0.2, height: h).fill()
    }
}

final class Win: NSWindow {
    override func constrainFrameRect(_ r: NSRect, to s: NSScreen?) -> NSRect { r }
}

final class D: NSObject, NSApplicationDelegate {
    var w: Win!
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.appearance = NSAppearance(named: mode == "dark" ? .darkAqua : .aqua)
        let main = NSMenu()
        for t in ["Probe", "File", "Edit", "View", "Window", "Help"] {
            let it = NSMenuItem(title: t, action: nil, keyEquivalent: ""); let m = NSMenu(title: t)
            for k in 1...6 { m.addItem(NSMenuItem(title: "\(t) item \(k)", action: #selector(noop), keyEquivalent: "")) }
            it.submenu = m; main.addItem(it)
        }
        NSApp.mainMenu = main
        let s = NSScreen.main!.frame
        w = Win(contentRect: NSRect(x: 0, y: s.height - 140, width: s.width, height: 140), styleMask: [.borderless], backing: .buffered, defer: false)
        w.contentView = Pattern()
        w.setFrame(NSRect(x: 0, y: s.height - 140, width: s.width, height: 140), display: true)
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        print("frame", w.frame, "screen", s, "visible", NSScreen.main!.visibleFrame); fflush(stdout)
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) { NSApp.terminate(nil) }
    }
    @objc func noop() {}
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let d = D()
app.delegate = d
app.run()
