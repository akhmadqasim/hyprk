import QtQuick
import "chameleon.js" as Ch

// Mean colour of the wallpaper for the chameleon tint (chameleon.js, MAC-ANSWERS.md C3.1): the Mac averages the
// wallpaper under the window. With `screenSize` and `windowSize` set (points) it is the mean of the part of the picture
// under that window centred on the screen, as the desktop shows it (aspect fill: shell/modules/Background.qml
// PreserveAspectCrop); without them, of the whole picture. The file is decoded once per `path` at 64 px (smooth
// scaled, so each pixel is the mean of its area) and that part of its pixels is averaged, area-weighted at the edges,
// when the path or a size changes, never per frame. The pixels are read from the image, not drawn and read back: at a
// device pixel ratio of 2, getImageData(0, 0, w, h) returns only the top-left quarter of a w x h canvas (TahoeDark:
// (64.8,52.6,182.1) for (36.4,52.6,157.9)). Against the full-size picture the scaled copy reads 0.5 level low on
// TahoeDark / TahoeLight (the same at 64 to 512 px; flat colours exact), under a 6-bit step. `tint` is null until known.
Item {
    id: root
    property string path
    property var tint: null
    property size screenSize: Qt.size(0, 0)
    property size windowSize: Qt.size(0, 0)
    width: 16; height: 16
    opacity: 0               // in the scene (a hidden Canvas may skip its paint) but never seen
    enabled: false
    readonly property string _url: path ? (path.indexOf("://") > 0 ? path : "file://" + path) : ""
    readonly property bool _region: windowSize.width > 0 && windowSize.height > 0
    // waits for the screen's size before the first mean when a window is given
    readonly property bool _ready: !_region || (screenSize.width > 0 && screenSize.height > 0)
    property string _held: ""   // the url in the canvas's cache (64 px, kept for a size change)
    on_UrlChanged: {
        tint = null;
        if (_held && _held !== _url) canvas.unloadImage(_held);
        _held = _url;
        if (!_url) return;
        canvas.loadImage(_url, Qt.size(64, 64));
        // a copy still in Qt's pixmap cache (this picture shown again, another WallpaperTint) is ready at once and
        // emits no imageLoaded
        if (canvas.isImageLoaded(_url)) canvas.requestPaint();
    }
    onScreenSizeChanged: canvas.requestPaint()
    onWindowSizeChanged: canvas.requestPaint()
    // the overlap of pixel [i, i + 1] with [a, b]
    function _cover(i, a, b) { return Math.max(0, Math.min(i + 1, b) - Math.max(i, a)); }
    Canvas {
        id: canvas
        width: 16; height: 16
        renderTarget: Canvas.Image
        onImageLoaded: requestPaint()
        onPaint: {
            const u = root._url;
            if (!u || !root._ready || !isImageLoaded(u)) return;
            const im = getContext("2d").createImageData(u);   // the 64 px copy, RGBA
            const iw = im.width, ih = im.height, d = im.data;
            if (!iw || !ih) return;
            // the centred window in the centred aspect fill: a centred rect of the window's size x s
            let sw = iw, sh = ih;
            if (root._region) {
                const s = Math.min(iw / root.screenSize.width, ih / root.screenSize.height);
                sw = Math.min(iw, root.windowSize.width * s);
                sh = Math.min(ih, root.windowSize.height * s);
            }
            const x0 = (iw - sw) / 2, x1 = x0 + sw, y0 = (ih - sh) / 2, y1 = y0 + sh;
            let r = 0, gr = 0, b = 0, n = 0;
            for (let y = Math.floor(y0); y < y1; y++) {
                const wy = root._cover(y, y0, y1);
                for (let x = Math.floor(x0); x < x1; x++) {
                    const w = wy * root._cover(x, x0, x1), i = (y * iw + x) * 4;
                    r += w * d[i]; gr += w * d[i + 1]; b += w * d[i + 2]; n += w;
                }
            }
            n *= 255;
            const t = { r: Ch.quantise(r / n), g: Ch.quantise(gr / n), b: Ch.quantise(b / n) }, o = root.tint;
            if (!o || o.r !== t.r || o.g !== t.g || o.b !== t.b) root.tint = t;   // a repaint of the same mean is no change
        }
    }
}
