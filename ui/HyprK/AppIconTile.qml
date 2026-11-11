import QtQuick
import QtQuick.Shapes
import "iconshape.js" as IconShape

// One app icon, drawn the macOS 26 way. Plain QtQuick (no Quickshell imports) so the
// Finder and Settings apps can use it too.
//
// - trusted icons (the user's extracted macOS icons) are drawn as they are;
// - icons that already are squircle tiles are scaled so their body matches the macOS
//   icon body (all tiles the same size);
// - everything else (round, square, free-form) is put on a standard squircle tile:
//   Apple continuous corner, system light/dark chiclet gradient, rim highlight, art at ~70%.
// The shape check (iconshape.js) runs once per icon file per process on a 48 px
// offscreen canvas and is cached; nothing is analysed per frame.
Item {
    id: root

    property url source
    property real size: 48
    property real loadSize: size          // largest size the icon is drawn at (Dock magnification)
    property bool trusted: false          // already a macOS icon: draw as is
    property bool dark: false             // dark tile (Icon & widget style "Dark")
    property string style: dark ? "dark" : "default"   // default | dark | clear | tinted
    property color tint: "#007AFF"        // tinted style colour
    property real body: 0.8047            // icon body: 824 of 1024 (100/1024 inset per side, SPEC.md)
    property real inner: 0.70             // art body inside a tile
    // keep the decoded art in Qt's pixmap cache (shared by every Image of the same file and size); false for files
    // that are dropped as a whole set, so they are freed with the last Image instead of lingering in the cache
    property bool cache: true
    // the window's device pixel ratio when it is known (Quickshell: QsWindow.window.devicePixelRatio); 0 = the
    // screen's, which is the next integer on a fractional output (2 at 1.6). Only picks the file to load: the drawing
    // itself finds the device pixel grid in the shader
    property real dpr: 0
    // the caller picked the texture size itself: this sourceSize as it is (pixels for a file; an image provider gets
    // it times the window's ratio from Qt)
    property int decodeSize: 0

    readonly property var info: _info
    readonly property bool tiled: !trusted && _info !== null && !_info.squircle
    readonly property bool ready: trusted || _info !== null
    readonly property alias status: art.status   // Image.Ready once the art is drawn
    readonly property alias paintedWidth: art.paintedWidth     // the art's own box (it keeps its aspect ratio)
    readonly property alias paintedHeight: art.paintedHeight

    property var _info: null
    readonly property string _key: String(source)
    // _probe is assigned, not bound: the probe sets _info from inside the Loader, so a binding
    // on _info would unload the Loader while it is still being created (binding loop)
    property bool _probe: false
    function _lookup() {
        _info = trusted || _key === "" ? null : (IconShape.cached(_key) || null);
        // recreate the probe for a new source (delegates are reused with other icons)
        _probe = false;
        if (!trusted && _key !== "" && _info === null)
            Qt.callLater(() => { if (_info === null && !trusted && _key !== "") _probe = true; });
    }
    function _done(url, info) {
        if (url !== _key) return;
        _info = info;
        Qt.callLater(() => { if (_info !== null) _probe = false; });
    }
    on_KeyChanged: _lookup()
    onTrustedChanged: _lookup()
    Component.onCompleted: _lookup()

    implicitWidth: size
    implicitHeight: size

    // ---------- tile ----------
    readonly property bool _dark: style === "dark"
    readonly property bool _clear: style === "clear"
    readonly property bool _tinted: style === "tinted"
    // Clear and Tinted: a flat tile and the art mapped by its luminance (shaders/iconart.frag), the rule read from
    // Apple's tiles and code for icons without layers (themes/icons agent, b0ba729 / 53470ff; ramps in the shader).
    // The appearance (Tokens.dark) picks the light or the dark form: dark Tinted is a dark tile with a blue tint fading
    // down, dark Clear an opaque grey 43 tile
    readonly property bool _mapped: _clear || _tinted
    // the dark form of Clear / Tinted: the appearance by default; the shell binds the style's own Light / Dark / Auto
    property bool styleDark: Tokens.dark
    readonly property bool _darkMode: styleDark

    // built only for icons that get a tile (most icons are trusted or already squircles and never draw one);
    // the outlines are shared by every tile (IconShape.tilePoints)
    Loader {
        id: tile
        active: root.tiled
        anchors.centerIn: parent
        width: root.size * root.body
        height: width

        sourceComponent: root._mapped ? flatTile : fullTile
    }
    // Clear / Tinted tile: the colour of the Apple renditions' tile (build-styles.py): light Tinted sRGB 0,109,195,
    // light Clear white at alpha 0.20 (the Mac's glass tile over the Dock: 176 -> 192); dark Tinted 25 + 0.15 x
    // (0,122,249) x (1 - y) from top to bottom, dark Clear opaque 43
    Component {
        id: flatTile
        Item { Shape {
            width: 100
            height: 100
            scale: tile.width / 100
            transformOrigin: Item.TopLeft
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeColor: "transparent"
                fillColor: root._darkMode ? (root._clear ? Qt.rgba(43 / 255, 43 / 255, 43 / 255, 1) : "#191919")
                         : root._clear ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 109 / 255, 195 / 255, 1)
                fillGradient: root._darkMode && root._tinted ? darkTint : null
                PathPolyline { path: IconShape.tilePoints(0) }
            }
            LinearGradient {
                id: darkTint
                x1: 0; y1: 0; x2: 0; y2: 100
                GradientStop { position: 0; color: Qt.rgba(25 / 255, (25 + 0.15 * 122) / 255, (25 + 0.15 * 249) / 255, 1) }
                GradientStop { position: 1; color: Qt.rgba(25 / 255, 25 / 255, 25 / 255, 1) }
            }
        } }
    }
    Component {
        id: fullTile
        // an Item the Loader sizes, with the 100 x 100 outline scaled inside it (a Loader resizes its item)
        Item { Shape {
            width: 100
            height: 100
            scale: tile.width / 100
            transformOrigin: Item.TopLeft
            preferredRendererType: Shape.CurveRenderer

            // soft contact shadow (two offset passes, no blur pass needed)
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.rgba(0, 0, 0, root._clear ? 0 : root._dark ? 0.22 : 0.07)
                PathPolyline { path: IconShape.tilePoints(0, 2.2) }
            }
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.rgba(0, 0, 0, root._clear ? 0 : root._dark ? 0.28 : 0.10)
                PathPolyline { path: IconShape.tilePoints(0, 0.9) }
            }
            // edge: defines the tile against light backgrounds
            ShapePath {
                strokeColor: "transparent"
                fillColor: root._dark ? Qt.rgba(1, 1, 1, 0.14)
                         : root._clear ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.13)
                fillRule: ShapePath.OddEvenFill       // rings, so translucent (clear) layers do not stack
                PathMultiline { paths: [IconShape.tilePoints(0), IconShape.tilePoints(0.7)] }
            }
            // rim: bright at the top, darker at the bottom (the glass bevel / specular edge)
            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0; y1: 0; x2: 0; y2: 100
                    GradientStop { position: 0; color: root._dark ? "#77777D" : root._clear ? Qt.rgba(1, 1, 1, 0.85) : "#FFFFFF" }
                    GradientStop { position: 0.5; color: root._dark ? "#3C3C40" : root._clear ? Qt.rgba(1, 1, 1, 0.30) : "#F2F2F4" }
                    GradientStop { position: 1; color: root._dark ? "#2A2A2D" : root._clear ? Qt.rgba(1, 1, 1, 0.45) : "#CFCFD5" }
                }
                fillRule: ShapePath.OddEvenFill
                PathMultiline { paths: [IconShape.tilePoints(0.7), IconShape.tilePoints(1.8)] }
            }
            // body: the system chiclet gradient (IconRendering Fills.systemLight/DarkGradient,
            // placed from 10% to 90% of the height; SPEC.md "App icons")
            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0; y1: 10; x2: 0; y2: 90
                    GradientStop {
                        position: 0
                        color: root._dark ? "#1F1F1F" : root._clear ? Qt.rgba(1, 1, 1, 0.34)
                             : root._tinted ? Qt.lighter(root.tint, 1.25) : "#FFFFFF"
                    }
                    GradientStop {
                        position: 1
                        color: root._dark ? "#0F0F0F" : root._clear ? Qt.rgba(1, 1, 1, 0.16)
                             : root._tinted ? root.tint : "#F5F5F5"
                    }
                }
                PathPolyline { path: IconShape.tilePoints(1.8) }
            }
            // specular sheen on the upper half
            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0; y1: 2; x2: 0; y2: 50
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, root._dark ? 0.10 : 0.55) }
                    GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
                }
                PathPolyline { path: IconShape.tilePoints(1.8) }
            }
        } }
    }

    // ---------- art ----------
    // Plain Image, not IconImage: IconImage reloads whenever its size changes (the magnifying
    // Dock would reload every icon every frame). Loaded once for loadSize, then drawn by the shader below.
    // The Image itself is never shown: Qt's bilinear / mipmap draw is soft (Laplacian energy 0.40-0.81 of a Lanczos
    // downscale, 0.62 on a fractional output), so shaders/iconart.frag resamples the texture in one pass on the
    // device pixel grid. No mipmaps: the texture is at most 4x the drawn size.
    Image {
        id: art
        readonly property var f: root.trusted || !root._info ? { scale: 1, dx: 0, dy: 0 }
            : IconShape.fit(root._info, root.tiled ? root.body * root.inner : root.body, root.tiled ? 1.6 : 1.25)
        visible: false
        width: root.size * f.scale
        height: width
        x: (root.size - width) / 2 + f.dx * root.size
        y: (root.size - height) / 2 + f.dy * root.size
        // largest drawn size in device pixels (root.dpr: the window's real ratio when the app knows it)
        readonly property real ratio: Math.max(1, root.dpr > 0 ? root.dpr : Screen.devicePixelRatio)
        readonly property real exact: root.loadSize * f.scale * ratio
        readonly property real px: Math.ceil(exact - 0.01)
        // macOS icon files carry their size in the name (themes/icons: apps 128 / 256 / 512, system 128 / 512, style
        // renditions 256). The 128 px file when it is drawn 1:1 or at 2/3 and less (just above the drawn size it
        // keeps 0.83-0.92 of the detail: 128 drawn at 102), else 256 up to 256 px (0.93-1.01), else 512. Decoded as
        // it is, or halved a whole number of times (an exact 2x2 average) while it is 4x the size or more.
        // Anything else is decoded at px by Qt
        readonly property var named: /^(.*\/(apps|system)\/[^\/]+)-(128|256|512|1024)(-[a-z]+-[a-z]+)?\.png$/.exec(root._key)
        readonly property int fileSize: {
            if (!named) return 0;
            if (named[4] || named[3] !== "512") return Number(named[3]);
            if (Math.abs(128 - exact) < 0.5 || 128 >= 1.5 * exact) return 128;
            return exact <= 256.5 && named[2] === "apps" ? 256 : 512;
        }
        readonly property int decode: {
            let d = fileSize;
            while (d >= 4 * px && d > 16) d /= 2;
            return d;
        }
        // an image provider ("image://...") is asked for sourceSize times the window's real ratio by Qt itself, so it
        // gets the size in pt (in px it rendered 2x too large: 256 px for a 64 pt icon); a file is decoded at
        // sourceSize as given
        readonly property bool provided: root._key.indexOf("image:") === 0
        readonly property int pt: Math.ceil(root.loadSize * f.scale)
        sourceSize: root.decodeSize > 0 ? Qt.size(root.decodeSize, root.decodeSize)
                  : fileSize > 0 ? (decode === fileSize ? undefined : Qt.size(decode, decode))
                  : provided ? Qt.size(pt, pt) : Qt.size(px, px)
        fillMode: Image.PreserveAspectFit
        source: !root.ready ? ""     // load once, at the final scale
              : fileSize > 0 && !named[4] && fileSize !== Number(named[3]) ? named[1] + "-" + fileSize + ".png" : root.source
        asynchronous: true
        cache: root.cache
        smooth: true
    }
    // off while the size animates (Dock magnification), so the icon does not step by device pixels
    property bool _still: true
    onSizeChanged: { if (_still) _still = false; settle.restart(); }
    Timer { id: settle; interval: 150; onTriggered: root._still = true }
    // the art, resampled (and in Clear / Tinted mapped through the ramp): one quad sampling the art's own texture
    // (no offscreen layer), over the rows and columns the art covers
    Loader {
        active: root.ready && art.status === Image.Ready
        x: art.x + (art.width - art.paintedWidth) / 2
        y: art.y + (art.height - art.paintedHeight) / 2
        width: art.paintedWidth
        height: art.paintedHeight
        sourceComponent: ShaderEffect {
            property Item source: art
            property real clear: root._clear ? 1 : 0
            property real darkMode: root._darkMode ? 1 : 0
            // the art's rows in the tile's own 0..1 (dark Tinted's tile gradient runs under it)
            readonly property real tileSize: root.size * root.body
            property real tileTop: (art.y - (root.size - tileSize) / 2) / Math.max(1, tileSize)
            property real tileSpan: art.height / Math.max(1, tileSize)
            property real plain: root._mapped ? 0 : 1
            property real snap: root._still ? 1 : 0
            fragmentShader: Qt.resolvedUrl("shaders/iconart.frag.qsb")
        }
    }

    // ---------- one-time shape analysis ----------
    Loader {
        active: root._probe
        sourceComponent: Canvas {
            id: probe
            property string url              // fixed at creation, not bound to the source
            width: IconShape.SAMPLE
            height: IconShape.SAMPLE
            opacity: 0
            enabled: false
            renderTarget: Canvas.Image
            renderStrategy: Canvas.Immediate
            function done(info) { root._done(url, info); }
            Component.onCompleted: {
                url = root._key;
                const hit = IconShape.cached(url);
                if (hit) done(hit);
                else if (isImageLoaded(url)) requestPaint();
                else loadImage(url);
            }
            onImageLoaded: {
                if (isImageError(url)) done({ squircle: false, extent: 1, cx: 0.5, cy: 0.5 });
                else requestPaint();
            }
            onPaint: {
                if (!isImageLoaded(url)) return;
                const ctx = getContext("2d");
                const n = IconShape.SAMPLE;
                // The picture's own pixels, not a drawing of it: drawImage puts a pixmap that carries a device pixel
                // ratio (Quickshell's icon provider: the application's, 2) at 2 / 1.6 of the asked size on a 1.6
                // output, so the sample came back in the top left 0.8 and every such icon was fitted 1.25x too
                // large and off centre (extent 0.71 at 0.40 where it is 0.875 at 0.50). Alpha at the sample's grid,
                // 2 x 2 points per cell
                const img = ctx.createImageData(url);
                const w = img ? img.width : 0, h = img ? img.height : 0;
                if (w > 0 && h > 0) {
                    const p = img.data, m = new Array(n * n);
                    for (let y = 0; y < n; ++y)
                        for (let x = 0; x < n; ++x) {
                            let a = 0;
                            for (let j = 0; j < 2; ++j)
                                for (let i = 0; i < 2; ++i)
                                    a += p[(Math.min(h - 1, Math.floor((y + 0.25 + 0.5 * j) * h / n)) * w
                                            + Math.min(w - 1, Math.floor((x + 0.25 + 0.5 * i) * w / n))) * 4 + 3];
                            m[y * n + x] = a / 4;
                        }
                    done(IconShape.store(url, IconShape.analyze(m, n, 1)));
                    return;
                }
                ctx.clearRect(0, 0, width, height);
                ctx.drawImage(url, 0, 0, width, height);
                const d = ctx.getImageData(0, 0, width, height).data;
                done(IconShape.store(url, IconShape.analyze(d, n, 4)));
            }
            // never leave an icon hidden if the canvas cannot paint (no window yet, odd format)
            Timer {
                interval: 1500; running: true
                onTriggered: if (root._info === null) probe.done({ squircle: false, extent: 1, cx: 0.5, cy: 0.5 })
            }
        }
    }
}
