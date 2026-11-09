pragma Singleton

import QtQuick
import QtCore

// Runs commands and reads/writes/watches state files.
// Under Quickshell: processes (QsProcess.qml) and inotify (QsWatch.qml).
// Under the plain `qml` tool: no processes; files go through XMLHttpRequest
// (run.sh sets QML_XHR_ALLOW_FILE_READ/WRITE) and watching is a 2 s poll.
QtObject {
    id: backend

    property Component _proc: Qt.createComponent("QsProcess.qml")
    property Component _watch: Qt.createComponent("QsWatch.qml")
    readonly property bool canRun: _proc.status === Component.Ready

    // hyprk checkout root (parent of settings/). Quickshell serves files from qs://
    // URLs, so ask it for the real directory; otherwise the file:// URL is real.
    readonly property string root: {
        const info = Qt.createComponent("QsInfo.qml");
        const dir = info.status === Component.Ready ? info.createObject(null).shellDir
                                                     : decodeURIComponent(new URL(String(Qt.resolvedUrl("."))).pathname);
        return dir.replace(/\/$/, "").replace(/\/[^\/]+$/, "");
    }
    readonly property string stateDir: root + "/state"

    // cb(code, stdout). code 127 = not supported / not installed.
    function run(argv, cb) {
        if (!canRun) { if (cb) Qt.callLater(cb, 127, ""); return; }
        const p = _proc.createObject(backend, { command: argv });
        p.done.connect((code, out) => { if (cb) cb(code, out); p.destroy(); });
    }

    // freedesktop thumbnail spec: ~/.cache/thumbnails/large/<md5 of file URI>.png
    readonly property string thumbDir: decodeURIComponent(new URL(String(StandardPaths.writableLocation(StandardPaths.GenericCacheLocation))).pathname) + "/thumbnails/large"
    function thumbFor(path) {
        return thumbDir + "/" + Qt.md5("file://" + encodeURI(path)) + ".png";
    }
    // Create missing thumbnails in the background (needs Quickshell + magick).
    function makeThumbs(paths, done) {
        const args = [root + "/settings/scripts/thumbs.sh"];
        for (const p of paths) args.push(p, thumbFor(p));
        run(args, done);
    }

    function _xhrRead(path, cb) {
        const x = new XMLHttpRequest();
        x.onreadystatechange = () => { if (x.readyState === XMLHttpRequest.DONE) cb(x.responseText || ""); };
        x.open("GET", "file://" + path);
        x.send();
    }

    // cb(text) now and whenever the file changes ("" when missing).
    function watch(path, cb) {
        if (_watch.status === Component.Ready) {
            _watch.createObject(backend, { path: path }).changed.connect(cb);
            return;
        }
        let last = null;
        const poll = () => _xhrRead(path, t => { if (t !== last) { last = t; cb(t); } });
        const t = Qt.createQmlObject('import QtQuick; Timer { interval: 2000; repeat: true; running: true }', backend);
        t.triggered.connect(poll);
        poll();
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
