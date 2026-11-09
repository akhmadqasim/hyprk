pragma Singleton

import QtQuick
import QtCore

// Runs commands and reads/writes state files.
// Commands need Quickshell (QsProcess.qml). Files fall back to XMLHttpRequest
// under the plain `qml` tool (run.sh sets QML_XHR_ALLOW_FILE_READ/WRITE).
QtObject {
    id: backend

    // hyprk checkout root. Under Quickshell, resolvedUrl gives qs:// URLs, so ask Quickshell.
    property Component _info: Qt.createComponent("QsInfo.qml")
    readonly property string root: (_info.status === Component.Ready
            ? _info.createObject(backend).shellDir + "/.."
            : Qt.resolvedUrl("..").toString().replace(/^file:\/\//, ""))
        .replace(/\/[^\/]+\/\.\.\/?$/, "").replace(/\/$/, "")
    readonly property string stateDir: root + "/state"

    property Component _proc: Qt.createComponent("QsProcess.qml")
    readonly property bool canRun: _proc.status === Component.Ready

    // cb(code, stdout). code 127 = not supported / not installed.
    function run(argv, cb) {
        if (!canRun) { if (cb) Qt.callLater(cb, 127, ""); return; }
        const p = _proc.createObject(backend, { command: argv });
        p.done.connect((code, out) => { if (cb) cb(code, out); p.destroy(); });
    }

    // freedesktop thumbnail spec: ~/.cache/thumbnails/large/<md5 of file URI>.png
    readonly property string thumbDir: String(StandardPaths.writableLocation(StandardPaths.GenericCacheLocation)).replace(/^file:\/\//, "") + "/thumbnails/large"
    function thumbFor(path) {
        return thumbDir + "/" + Qt.md5("file://" + encodeURI(path)) + ".png";
    }
    // Create missing thumbnails in the background (needs Quickshell + magick).
    function makeThumbs(paths, done) {
        const args = [root + "/settings/scripts/thumbs.sh"];
        for (const p of paths) args.push(p, thumbFor(p));
        run(args, done);
    }

    function readFile(path, cb) {
        if (canRun) { run(["cat", path], (code, out) => cb(code === 0 ? out : "")); return; }
        const x = new XMLHttpRequest();
        x.onreadystatechange = () => { if (x.readyState === XMLHttpRequest.DONE) cb(x.responseText || ""); };
        x.open("GET", "file://" + path);
        x.send();
    }

    // Atomic write (tmp + mv) so the shell never reads half a file.
    function writeFile(path, text) {
        if (canRun) {
            run(["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf "%s" "$2" > "$1.tmp" && mv "$1.tmp" "$1"', "sh", path, text]);
            return;
        }
        const x = new XMLHttpRequest();
        x.open("PUT", "file://" + path);
        x.send(text);
    }
}
