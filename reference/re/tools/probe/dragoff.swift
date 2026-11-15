import CoreGraphics
import Foundation
// dragoff x0 y0 x1 y1 moveSec holdSec [upMode]  one process, hidSystemState source, clickState 1, pressure set
let a = CommandLine.arguments.dropFirst().map { Double($0) ?? 0 }
let src = CGEventSource(stateID: .hidSystemState)!
func ev(_ t: CGEventType, _ x: Double, _ y: Double, _ dx: Double = 0, _ dy: Double = 0) {
  let e = CGEvent(mouseEventSource: src, mouseType: t, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)!
  e.setIntegerValueField(.mouseEventClickState, value: 1)
  e.setDoubleValueField(.mouseEventPressure, value: t == .leftMouseUp ? 0 : 1)
  e.setIntegerValueField(.mouseEventDeltaX, value: Int64(dx)); e.setIntegerValueField(.mouseEventDeltaY, value: Int64(dy))
  e.post(tap: .cghidEventTap)
}
let x0=a[0],y0=a[1],x1=a[2],y1=a[3],ms=a[4],hs=a[5]
ev(.leftMouseDown,x0,y0); usleep(30000)
let n = Int(ms*120); var px=x0, py=y0
for i in 1...n { let t=Double(i)/Double(n); let x=x0+(x1-x0)*t, y=y0+(y1-y0)*t; ev(.leftMouseDragged,x,y,x-px,y-py); px=x;py=y; usleep(UInt32(ms*1e6/Double(n))) }
// hold: keep sending zero-delta drags at 60 Hz
let hn = Int(hs*60); for _ in 0..<hn { ev(.leftMouseDragged,x1,y1); usleep(16667) }
print(String(format: "%.6f", Date().timeIntervalSince1970))
ev(.leftMouseUp,x1,y1)
