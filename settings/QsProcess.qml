import QtQuick
import Quickshell.Io

// One-shot command, created by Backend.run(). Only loads under Quickshell;
// under the plain `qml` tool this file fails to compile and Backend reports
// commands as unsupported.
Process {
    id: proc
    signal done(int code, string out)
    property bool _exited: false
    running: true
    stdout: StdioCollector { id: out }
    stderr: StdioCollector {}
    onExited: (code, status) => { proc._exited = true; proc.done(code, out.text); }
    // FailedToStart (binary missing) never emits exited, only running=false.
    onRunningChanged: if (!running && !_exited) Qt.callLater(() => { if (!proc._exited) { proc._exited = true; proc.done(127, ""); } })
}
