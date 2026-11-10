import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../lib/iconshape.js" as IconShape

// One app icon, drawn the macOS 26 way. Plain QtQuick (no Quickshell imports) so the
// Finder and Settings apps can use it too.
//
// - trusted icons (the user's extracted macOS icons) are drawn as they are;
// - icons that already are squircle tiles are scaled so their body matches the macOS
//   icon body (all tiles the same size);
// - everything else (round, square, free-form) is put on a standard squircle tile:
//   Apple continuous corner, system light/dark chiclet gradient, rim highlight, art at ~70%.
// The shape check (lib/iconshape.js) runs once per icon file per process on a 48 px
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

    readonly property var info: _info
    readonly property bool tiled: !trusted && _info !== null && !_info.squircle
    readonly property bool ready: trusted || _info !== null
    readonly property alias status: art.status   // Image.Ready once the art is drawn

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
    readonly property var _unit: IconShape.squirclePoints(100).map(p => Qt.point(p[0], p[1]))
    function _inset(d) {
        const k = (100 - 2 * d) / 100;
        return _unit.map(p => Qt.point(d + p.x * k, d + p.y * k));
    }

    Item {
        id: tile
        visible: root.tiled
        anchors.centerIn: parent
        width: root.size * root.body
        height: width

        Shape {
            width: 100
            height: 100
            scale: tile.width / 100
            transformOrigin: Item.TopLeft
            preferredRendererType: Shape.CurveRenderer

            // soft contact shadow (two offset passes, no blur pass needed)
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.rgba(0, 0, 0, root._clear ? 0 : root._dark ? 0.22 : 0.07)
                PathPolyline { path: root._unit.map(p => Qt.point(p.x, p.y + 2.2)) }
            }
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.rgba(0, 0, 0, root._clear ? 0 : root._dark ? 0.28 : 0.10)
                PathPolyline { path: root._unit.map(p => Qt.point(p.x, p.y + 0.9)) }
            }
            // edge: defines the tile against light backgrounds
            ShapePath {
                strokeColor: "transparent"
                fillColor: root._dark ? Qt.rgba(1, 1, 1, 0.14)
                         : root._clear ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.13)
                fillRule: ShapePath.OddEvenFill       // rings, so translucent (clear) layers do not stack
                PathMultiline { paths: [root._unit, root._inset(0.7)] }
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
                PathMultiline { paths: [root._inset(0.7), root._inset(1.8)] }
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
                PathPolyline { path: root._inset(1.8) }
            }
            // specular sheen on the upper half
            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0; y1: 2; x2: 0; y2: 50
                    GradientStop { position: 0; color: Qt.rgba(1, 1, 1, root._dark ? 0.10 : 0.55) }
                    GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
                }
                PathPolyline { path: root._inset(1.8) }
            }
        }
    }

    // ---------- art ----------
    // Plain Image, not IconImage: IconImage reloads whenever its size changes (the magnifying
    // Dock would reload every icon every frame). Loaded once at loadSize * scale, then scaled.
    Image {
        id: art
        readonly property var f: root.trusted || !root._info ? { scale: 1, dx: 0, dy: 0 }
            : IconShape.fit(root._info, root.tiled ? root.body * root.inner : root.body, root.tiled ? 1.6 : 1.25)
        visible: root.ready
        width: root.size * f.scale
        height: width
        x: (root.size - width) / 2 + f.dx * root.size
        y: (root.size - height) / 2 + f.dy * root.size
        sourceSize: Qt.size(Math.ceil(root.loadSize * f.scale), Math.ceil(root.loadSize * f.scale))
        fillMode: Image.PreserveAspectFit
        source: root.ready ? root.source : ""     // load once, at the final scale
        asynchronous: true
        smooth: true
        mipmap: true
        // Clear and Tinted styles show the art as a monochrome glyph, like macOS 26
        layer.enabled: root._clear || root._tinted
        layer.effect: MultiEffect { saturation: -1.0; brightness: root._tinted ? 0.35 : 0.08 }
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
                ctx.clearRect(0, 0, width, height);
                ctx.drawImage(url, 0, 0, width, height);
                const d = ctx.getImageData(0, 0, width, height).data;
                done(IconShape.store(url, IconShape.analyze(d, IconShape.SAMPLE, 4)));
            }
            // never leave an icon hidden if the canvas cannot paint (no window yet, odd format)
            Timer {
                interval: 1500; running: true
                onTriggered: if (root._info === null) probe.done({ squircle: false, extent: 1, cx: 0.5, cy: 0.5 })
            }
        }
    }
}
