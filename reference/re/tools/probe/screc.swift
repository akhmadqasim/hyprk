import Foundation
import ScreenCaptureKit
import AVFoundation
// screc <out.mov> <seconds> [x y w h]  : screen + system audio (no mic) via SCRecordingOutput, 60 fps
let a = CommandLine.arguments
let out = URL(fileURLWithPath: a[1]); let secs = Double(a[2])!
let sem = DispatchSemaphore(value: 0)
class D: NSObject, SCRecordingOutputDelegate, SCStreamDelegate {
  func recordingOutputDidStartRecording(_ r: SCRecordingOutput) { FileHandle.standardError.write("started \(Date().timeIntervalSince1970)\n".data(using: .utf8)!) }
  func recordingOutputDidFinishRecording(_ r: SCRecordingOutput) { sem.signal() }
  func recordingOutput(_ r: SCRecordingOutput, didFailWithError e: Error) { print("fail \(e)"); sem.signal() }
}
let d = D()
Task {
  do {
    let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
    let disp = content.displays.first!
    let filter = SCContentFilter(display: disp, excludingWindows: [])
    let cfg = SCStreamConfiguration()
    cfg.capturesAudio = true; cfg.captureMicrophone = false; cfg.excludesCurrentProcessAudio = false
    cfg.sampleRate = 48000; cfg.channelCount = 2
    cfg.minimumFrameInterval = CMTime(value: 1, timescale: 60)
    cfg.showsCursor = true
    if a.count >= 7 {
      cfg.sourceRect = CGRect(x: Double(a[3])!, y: Double(a[4])!, width: Double(a[5])!, height: Double(a[6])!)
      cfg.width = Int(Double(a[5])! * 2); cfg.height = Int(Double(a[6])! * 2)
    } else { cfg.width = disp.width * 2; cfg.height = disp.height * 2 }
    let stream = SCStream(filter: filter, configuration: cfg, delegate: d)
    let rc = SCRecordingOutputConfiguration(); rc.outputURL = out; rc.outputFileType = .mov; rc.videoCodecType = .h264
    let ro = SCRecordingOutput(configuration: rc, delegate: d)
    try stream.addRecordingOutput(ro)
    try await stream.startCapture()
    try await Task.sleep(nanoseconds: UInt64(secs * 1e9))
    try await stream.stopCapture()
  } catch { print("error \(error)"); sem.signal() }
}
sem.wait()
