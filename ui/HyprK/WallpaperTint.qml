import QtQuick
import "chameleon.js" as Ch

// Mean colour of the wallpaper for the sidebar chameleon tint (chameleon.js, MAC-ANSWERS.md C3.1): the Mac
// averages the wallpaper under the window; one mean of the whole wallpaper is enough here. The file is decoded
// once at 16 x 16 and averaged when `path` changes, never per frame. `tint` is null until it is known.
Item {
    id: root
    property string path
    property var tint: null
    width: 16; height: 16
    opacity: 0               // drawn (a hidden Canvas may skip its paint) but never seen
    enabled: false
    readonly property string _url: path ? (path.indexOf("://") > 0 ? path : "file://" + path) : ""
    on_UrlChanged: { tint = null; if (_url) canvas.loadImage(_url); }
    Canvas {
        id: canvas
        width: 16; height: 16
        renderTarget: Canvas.Image
        onImageLoaded: requestPaint()
        onPaint: {
            if (!root._url || !isImageLoaded(root._url)) return;
            const g = getContext("2d");
            g.clearRect(0, 0, 16, 16);
            g.drawImage(root._url, 0, 0, 16, 16);
            const d = g.getImageData(0, 0, 16, 16).data;
            let r = 0, gr = 0, b = 0;
            for (let i = 0; i < d.length; i += 4) { r += d[i]; gr += d[i + 1]; b += d[i + 2]; }
            const n = d.length / 4 * 255;
            root.tint = { r: Ch.quantise(r / n), g: Ch.quantise(gr / n), b: Ch.quantise(b / n) };
            unloadImage(root._url);   // the decoded copy is not needed again
        }
    }
}
