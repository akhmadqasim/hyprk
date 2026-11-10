// winpoll: polls the on-screen window list every 4 ms and prints changes of windows whose owner contains argv[1]
// (time since epoch, id, layer, alpha, bounds, name). Runs argv[2] seconds. Usage: winpoll "Notification" 6
import CoreGraphics; import Foundation
let owner = CommandLine.arguments[1]; let secs = Double(CommandLine.arguments[2]) ?? 5
var last: [Int: String] = [:]; let t0 = Date()
setvbuf(stdout, nil, _IOLBF, 0)
while Date().timeIntervalSince(t0) < secs {
    let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
    var now: [Int: String] = [:]
    for w in list {
        guard let o = w[kCGWindowOwnerName as String] as? String, o.contains(owner) else { continue }
        let id = w[kCGWindowNumber as String] as! Int
        let b = w[kCGWindowBounds as String] as! [String: Double]
        now[id] = String(format: "layer %d alpha %.3f bounds %.0f %.0f %.0f %.0f %@", w[kCGWindowLayer as String] as! Int,
            w[kCGWindowAlpha as String] as! Double, b["X"]!, b["Y"]!, b["Width"]!, b["Height"]!, (w[kCGWindowName as String] as? String) ?? "")
    }
    let ts = Date().timeIntervalSince1970
    for (id, s) in now where last[id] != s { print(String(format: "%.4f", ts), id, s) }
    for (id, _) in last where now[id] == nil { print(String(format: "%.4f", ts), id, "GONE") }
    last = now; usleep(4000)
}
