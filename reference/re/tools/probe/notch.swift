import CoreGraphics
import Foundation
// notch x y dv dh count interval_ms : line-unit (mouse wheel) scroll events
let a = CommandLine.arguments
let x = Double(a[1])!, y = Double(a[2])!, dv = Int32(a[3])!, dh = Int32(a[4])!, n = Int(a[5])!, ms = UInt32(a[6])!
CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)!.post(tap: .cghidEventTap)
usleep(200000)
for _ in 0..<n { let e = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 2, wheel1: dv, wheel2: dh, wheel3: 0)!
  FileHandle.standardError.write("notch \(Date().timeIntervalSince1970) pointDelta v=\(e.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)) h=\(e.getIntegerValueField(.scrollWheelEventPointDeltaAxis2)) continuous=\(e.getIntegerValueField(.scrollWheelEventIsContinuous))\n".data(using: .utf8)!)
  if a.count > 7 { e.flags = .maskShift }
  e.post(tap: .cghidEventTap); usleep(ms * 1000) }
