pragma Singleton

import QtQuick
import QtCore
import "lib/macicons.js" as MacIcons

// Runs commands and reads/writes/watches state files.
// Under Quickshell: processes (QsProcess.qml) and inotify (QsWatch.qml).
// Under the plain `qml` tool: no processes; files go through XMLHttpRequest
// (run.sh sets QML_XHR_ALLOW_FILE_READ/WRITE) and watching is a 2 s poll.
QtObject {
    id: backend

    property Component _proc: Qt.createComponent("QsProcess.qml")
    property Component _watch: Qt.createComponent("QsWatch.qml")
    property Component _stream: Qt.createComponent("QsStream.qml")
    readonly property bool canRun: _proc.status === Component.Ready

    // hyprk checkout root (parent of settings/). Quickshell serves files from qs://
    // URLs, so ask it for the real directory; otherwise the file:// URL is real.
    readonly property QtObject _info: {
        const c = Qt.createComponent("QsInfo.qml");
        return c.status === Component.Ready ? c.createObject(backend) : null;
    }
    readonly property string root: {
        const dir = _info ? _info.shellDir : decodeURIComponent(new URL(String(Qt.resolvedUrl("."))).pathname);
        return dir.replace(/\/$/, "").replace(/\/[^\/]+$/, "");
    }
    // True when the compositor blurs behind our translucent surfaces (Hyprland).
    // Otherwise the sidebar paints its own blurred wallpaper.
    readonly property bool compositorBlur: _info ? _info.hyprland : false
    // $HYPRK_STATE (the shell reads the same folder); without it (plain `qml`, no env access) the checkout's state/
    readonly property string stateDir: (_info && _info.stateDir) || root + "/state"

    // True only when hyprk is the login session (QsInfo.realSession). Settings of the HOST desktop (gsettings / dconf)
    // are written only then: in a nested preview on a GNOME host, or a standalone settings/run.sh, such a write would
    // change the user's real desktop. hyprk's own state ($HYPRK_STATE) is written either way.
    readonly property bool realSession: _info ? _info.realSession : false
    // A write to the host desktop's settings: runs only in the real session; cb(code, out), 0 without running otherwise
    function runHost(argv, cb) {
        if (realSession) run(argv, cb);
        else { console.log("hyprk settings: host setting not written outside the hyprk session:", argv.join(" ")); if (cb) Qt.callLater(cb, 0, ""); }
    }

    // cb(code, stdout). code 127 = not supported / not installed.
    function run(argv, cb) {
        if (!canRun) { if (cb) Qt.callLater(cb, 127, ""); return; }
        const p = _proc.createObject(backend, { command: argv });
        p.done.connect((code, out) => { if (cb) cb(code, out); p.destroy(); });
    }

    // Icon name or absolute path from a .desktop file -> image URL ("" if unknown).
    function iconUrl(icon) {
        if (!icon) return "";
        if (icon.startsWith("/")) return "file://" + icon;
        return _info ? _info.iconPath(icon) : "";
    }

    // An app's icon as the shell and Finder draw it: the mapped macOS icon (themes/icons/apple-map.txt, `mac` names it
    // directly) in the rendition of the Icon & widget style (look: { style, variant, dark }, iconStyle /
    // iconStyleVariant of appearance.json and the window mode; MacIcons.styled), else the icon theme's
    function appIconUrl(icon, appId, look, mac) {
        const m = mac || (_info && !_info.appleIcons ? "" : MacIcons.lookup([appId || "", icon || ""]));
        if (m) return "file://" + root + "/themes/icons/" + (look ? MacIcons.styled(m, look.style, look.variant, look.dark) : MacIcons.file(m));
        return iconUrl(icon);
    }

    // Long-running command: onLine(text) per stdout line, onEnd(code) when it stops
    // (127 = can't run). Returns the process (destroyed with `owner`) or null.
    function stream(owner, argv, onLine, onEnd) {
        if (!canRun) { if (onEnd) Qt.callLater(onEnd, 127); return null; }
        // The child gets SIGTERM when Settings dies, also from SIGKILL (Quickshell only kills its processes on a clean
        // exit; `nmcli monitor` and `pw-mon` stayed behind): setpriv sets PR_SET_PDEATHSIG and execs the command in
        // the same process. Without setpriv (util-linux) the command runs as before; sh exits 127 for a missing one.
        const p = _stream.createObject(owner, { command: ["sh", "-c",
            'command -v setpriv >/dev/null 2>&1 && exec setpriv --pdeathsig TERM "$@"; exec "$@"', "sh"].concat(argv) });
        p.line.connect(onLine);
        if (onEnd) p.ended.connect(onEnd);
        return p;
    }

    // A dispatcher on Hyprland's own socket (no process, in order); nothing outside Hyprland or under `qml`.
    function hyprDispatch(lua) { if (_info && _info.hyprland) _info.hyprDispatch(lua); }

    // Run Lua in Hyprland (`hyprctl eval`); cb(status) with "ok" | "missing" | "failed".
    // hyprctl prints "ok" on success and an error text otherwise.
    function hyprEval(lua, cb) {
        run(["hyprctl", "eval", lua], (c, out) => {
            const st = status(c);
            if (cb) cb(st === "ok" && out.trim() !== "ok" ? "failed" : st);
        });
    }

    // Shared reading of an exit code: "missing" (tool not installed or no process
    // support), "failed" (tool ran and failed) or "ok".
    function status(code) {
        return code === 127 ? "missing" : code !== 0 ? "failed" : "ok";
    }

    // freedesktop thumbnail spec: ~/.cache/thumbnails/large/<md5 of file URI>.png
    function _stdPath(location) {
        return decodeURIComponent(new URL(String(StandardPaths.writableLocation(location))).pathname);
    }
    readonly property string home: _stdPath(StandardPaths.HomeLocation)
    readonly property string thumbDir: _stdPath(StandardPaths.GenericCacheLocation) + "/thumbnails/large"
    // file:// URI escaped like GLib's g_filename_to_uri (keeps !$&'()*+,;=:@ and /).
    function fileUri(path) {
        return "file://" + path.split("/").map(seg => encodeURIComponent(seg)
            .replace(/%(21|24|26|27|28|29|2A|2B|2C|3B|3D|3A|40)/g, m => decodeURIComponent(m))).join("/");
    }
    function thumbFor(path) {
        return thumbDir + "/" + Qt.md5(fileUri(path)) + ".png";
    }
    // Create missing thumbnails in the background (needs Quickshell + magick).
    function makeThumbs(paths, done) {
        const args = [root + "/settings/scripts/thumbs.sh"];
        for (const p of paths) args.push(p, thumbFor(p), fileUri(p));
        run(args, done);
    }

    // One-off read of a small text file ("" when unreadable).
    function readText(path, cb) {
        if (canRun) run(["cat", path], (c, out) => cb(c === 0 ? out : ""));
        else _xhrRead(path, cb);
    }

    function _xhrRead(path, cb) {
        const x = new XMLHttpRequest();
        x.onreadystatechange = () => { if (x.readyState === XMLHttpRequest.DONE) cb(x.responseText || ""); };
        x.open("GET", "file://" + path);
        x.send();
    }

    // This computer's facts for General > About, Storage and Software Update: cb(text), the key=value lines of
    // settings/scripts/sysinfo.sh (Parsers.parseSysInfo). Read-only. Under the plain `qml` tool (no processes) the
    // files that can be read are put in the same lines; displays and the disk need the script.
    function sysInfo(cb) {
        if (canRun) { run([root + "/settings/scripts/sysinfo.sh"], (c, out) => cb(c === 0 ? out : "")); return; }
        const files = [["/sys/class/dmi/id/product_name", t => "model=" + t.trim()],
                       ["/sys/class/dmi/id/sys_vendor", t => "vendor=" + t.trim()],
                       ["/proc/sys/kernel/hostname", t => "host=" + t.trim()],
                       ["/proc/cpuinfo", t => "chip=" + ((/^model name\s*:\s*(.*)$/m.exec(t) || [])[1] || "")],
                       ["/proc/meminfo", t => "memTotalKb=" + ((/^MemTotal:\s*(\d+)/m.exec(t) || [])[1] || "")],
                       ["/etc/os-release", t => t.replace(/^(NAME|VERSION|VERSION_ID|PRETTY_NAME|LOGO)=/gm, "os.$1=")]];
        const out = [];
        let left = files.length;
        for (const f of files)
            _xhrRead(f[0], t => { out.push(f[1](t)); if (--left === 0) cb(out.join("\n")); });
    }

    // General > Storage: the size of each category on the system volume (settings/scripts/storage.sh: du at idle
    // priority, one category after another, off the UI thread as every Backend.run). storageSizes fills as they
    // arrive: { id: bytes }, -1 for a category this computer does not have; a missing id is still being sized. A scan
    // that is running is not started again, and the last sizes stay until the new ones replace them.
    property var storageSizes: ({})
    property bool storageBusy: false
    function storageScan(ids) {
        if (storageBusy || !canRun) return;
        storageBusy = true;
        const next = i => {
            if (i >= ids.length) { storageBusy = false; return; }
            run([root + "/settings/scripts/storage.sh", ids[i]], (c, out) => {
                const s = Object.assign({}, storageSizes), t = out.trim();
                s[ids[i]] = c !== 0 || t === "-" ? -1 : (parseInt(t) || 0);
                storageSizes = s;
                next(i + 1);
            });
        };
        next(0);
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
            run(["sh", "-c", 'mkdir -p "$(dirname "$1")" && t=$(mktemp "$1.XXXXXX") && printf "%s" "$2" > "$t" && mv "$t" "$1"', "sh", path, text]);
            return;
        }
        const x = new XMLHttpRequest();
        x.open("PUT", "file://" + path);
        x.send(text);
    }
}
