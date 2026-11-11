pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Provides the wallpaper and a pre-blurred copy used as the glass backdrop.
// All panels sample the blurred copy at their own screen position, so the
// material looks like frosted glass over the desktop without per-frame blur.
Singleton {
    id: root

    property string wallpaper: ""
    property string blurred: ""
    property real topLuma: 0.3                  // brightness behind the menu bar
    readonly property string url: wallpaper ? "file://" + wallpaper : ""
    readonly property string blurredUrl: blurred ? "file://" + blurred : ""
    readonly property int thumbWidth: 320       // one decode size shared by all wallpaper thumbnails
    property int width: Panels.screen ? Panels.screen.width : 1920
    property int height: Panels.screen ? Panels.screen.height : 1080
    // `wallpaper` is cut at the output's pixel size: decoded at the logical size a 2x output upscaled it, so 4 pt
    // stripes showed 4 px ramps and every glass sampled a softer backdrop than the Mac's. `blurred` stays logical
    readonly property real dpr: Panels.screen ? Panels.screen.devicePixelRatio : 1
    readonly property int pixelWidth: Math.round(width * dpr)
    readonly property int pixelHeight: Math.round(height * dpr)

    // ---------- other screens ----------
    // A screen whose pixel size differs from the primary's gets its own cut at its own pixel size (wallpaper.sh with
    // HYPRK_WALL_ONLY: no blur, no luma), so it is shown 1:1 like the primary's; screens of the same size share one
    // file and one decoded pixmap (the pixmap cache key is url + sourceSize). Until a cut is ready the screen shows the
    // primary's file scaled. The blurred copy and the glass stay the primary's (as before).
    function pixelSizeOf(scr) {
        return scr ? Qt.size(Math.round(scr.width * scr.devicePixelRatio), Math.round(scr.height * scr.devicePixelRatio))
                   : Qt.size(pixelWidth, pixelHeight);
    }
    function urlFor(scr) {
        const s = pixelSizeOf(scr);
        if (s.width === pixelWidth && s.height === pixelHeight) return url;
        const f = cuts[s.width + "x" + s.height];
        return f ? "file://" + f : url;
    }
    property var cuts: ({})           // "PWxPH" -> file, for pixel sizes other than the primary's
    // the distinct pixel sizes of the other screens ("PWxPH x WxH", logical size for the script's crop arguments)
    readonly property var otherSizes: {
        const out = [];
        for (const scr of Quickshell.screens) {
            const s = pixelSizeOf(scr), k = s.width + "x" + s.height;
            if ((s.width !== pixelWidth || s.height !== pixelHeight) && !out.some(o => o.key === k))
                out.push({ key: k, pw: s.width, ph: s.height, w: scr.width, h: scr.height });
        }
        return out;
    }
    onOtherSizesChanged: Qt.callLater(cutOthers)
    property var _queue: []
    function cutOthers() {
        if (!wallpaper) return;
        const keep = {};
        for (const o of otherSizes) if (cuts[o.key]) keep[o.key] = cuts[o.key];
        cuts = keep;
        _queue = otherSizes.slice();
        if (!other.running) _next();
    }
    function _next() {
        if (_queue.length === 0) return;
        other.size = _queue.shift();
        other.running = true;
    }
    Process {
        id: other
        property var size: null
        environment: ({ HYPRK_WALLPAPER: root.wallpaperSource, HYPRK_WALL_ONLY: "1" })
        command: size ? [Quickshell.shellDir + "/scripts/wallpaper.sh", String(size.w), String(size.h), "0",
                         Theme.dark ? "dark" : "light", String(size.pw), String(size.ph)] : ["true"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.startsWith("WALL="));
                if (line && other.size) {
                    const c = Object.assign({}, root.cuts);
                    c[other.size.key] = line.slice(5);
                    root.cuts = c;
                }
                Qt.callLater(root._next);
            }
        }
    }
    // the picture the primary's cut came from (the chosen file, or the script's default pick for the mode)
    property string wallpaperSource: ""

    function refresh() {
        proc.running = false;
        proc.running = true;
    }

    onWidthChanged: refresh()
    onHeightChanged: refresh()
    onDprChanged: refresh()
    Component.onCompleted: refresh()
    Connections {
        target: Theme
        function onDarkChanged() { root.refresh(); }
    }

    // state/wallpaper.json path (Settings > Wallpaper) wins over the default pick
    readonly property string chosen: Prefs.wallpaper.path || ""
    // later: the Process `environment` binding reads `chosen` too and may not have updated yet, so the
    // script ran with the previous wallpaper (bar text colour one wallpaper behind)
    onChosenChanged: Qt.callLater(refresh)

    Process {
        id: proc
        environment: ({ HYPRK_WALLPAPER: root.chosen })
        command: [Quickshell.shellDir + "/scripts/wallpaper.sh", String(root.width), String(root.height), String(Theme.glass.blurRadius), Theme.dark ? "dark" : "light", String(root.pixelWidth), String(root.pixelHeight)]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    if (line.startsWith("WALL=")) root.wallpaper = line.slice(5);
                    else if (line.startsWith("SRC=")) root.wallpaperSource = line.slice(4);
                    else if (line.startsWith("BLUR=")) root.blurred = line.slice(5);
                    else if (line.startsWith("LUMA=")) root.topLuma = parseFloat(line.slice(5)) || 0.3;
                }
                Theme.menuBarOnLight = root.topLuma > Theme.menuBarLumaThreshold;
                Theme.blurAvailable = root.blurred !== "";
                root.cutOthers();
            }
        }
    }
}
