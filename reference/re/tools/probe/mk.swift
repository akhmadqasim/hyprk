import AppKit
// mk x y vol|<keycode> [mods] : moves the pointer to x,y (visual marker), then immediately posts the key; prints unix time of both posts
let a = CommandLine.arguments
func now() -> Double { Date().timeIntervalSince1970 }
let m = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: Double(a[1])!, y: Double(a[2])!), mouseButton: .left)!
let t0 = now(); m.post(tap: .cghidEventTap)
var t1 = 0.0
if a[3] == "vol" {
  func key(_ down: Bool) {
    let ev = NSEvent.otherEvent(with: .systemDefined, location: .zero, modifierFlags: NSEvent.ModifierFlags(rawValue: down ? 0xa00 : 0xb00), timestamp: 0, windowNumber: 0, context: nil, subtype: 8, data1: Int((0 << 16) | ((down ? 0xa : 0xb) << 8)), data2: -1)!
    ev.cgEvent!.post(tap: .cghidEventTap)
  }
  t1 = now(); key(true); usleep(50000); key(false)
} else {
  var f: CGEventFlags = []
  if a.count > 4 { for s in a[4].split(separator: ",") { switch s { case "cmd": f.insert(.maskCommand); case "shift": f.insert(.maskShift); default: break } } }
  let d = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(Int(a[3])!), keyDown: true)!; d.flags = f
  let u = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(Int(a[3])!), keyDown: false)!; u.flags = f
  t1 = now(); d.post(tap: .cghidEventTap); usleep(60000); u.post(tap: .cghidEventTap)
}
print(String(format: "move %.6f key %.6f", t0, t1))
