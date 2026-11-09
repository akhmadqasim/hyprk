import QtQuick
import Quickshell.Io

// Long-running command, one signal per stdout line (Backend.stream). Quickshell only.
Process {
    id: proc
    signal line(string text)
    signal ended(int code)
    property bool _ended: false
    running: true
    stdout: SplitParser { onRead: data => proc.line(data) }
    onExited: code => { proc._ended = true; proc.ended(code); }
    // FailedToStart (binary missing) never emits exited, only running=false.
    onRunningChanged: if (!running && !_ended) Qt.callLater(() => { if (!proc._ended) { proc._ended = true; proc.ended(127); } })
}
