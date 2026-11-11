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
    // Clear and Tinted: a flat tile and the art mapped by its luminance (shaders/iconstyle.frag), the rule read from
    // the Mac's ClearLight / TintedLight Dock for icons without layers (WebStorm, Spotify; themes/icons/README.md).
    // The Mac's dark appearance has no other files for these styles (the Apple renditions fall back to the light
    // ones), so the same is drawn in both appearances
    readonly property bool _mapped: _clear || _tinted

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
    // Clear / Tinted tile: flat, the colour of the Apple renditions' tile (build-styles.py): Tinted sRGB 0,109,195,
    // Clear white at alpha 0.20 (the Mac's glass tile over the Dock: 176 -> 192)
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
                fillColor: root._clear ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 109 / 255, 195 / 255, 1)
                PathPolyline { path: IconShape.tilePoints(0) }
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
    // Dock would reload every icon every frame). Loaded once at loadSize * scale, then scaled.
    Image {
        id: art
        readonly property var f: root.trusted || !root._info ? { scale: 1, dx: 0, dy: 0 }
            : IconShape.fit(root._info, root.tiled ? root.body * root.inner : root.body, root.tiled ? 1.6 : 1.25)
        visible: root.ready && !root._mapped     // Clear / Tinted: drawn by the glyph below from this texture
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
    }
    // the art through the Clear / Tinted ramp: one quad sampling the art's own texture (no offscreen layer); built
    // only while one of those styles is on
    Loader {
        active: root._mapped && root.ready
        x: art.x
        y: art.y
        width: art.width
        height: art.height
        sourceComponent: ShaderEffect {
            property Item source: art
            property real clear: root._clear ? 1 : 0
            fragmentShader: Qt.resolvedUrl("shaders/iconstyle.frag.qsb")
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
