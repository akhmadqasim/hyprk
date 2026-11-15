import QtQuick
import QtQuick.Shapes
import qs
import "symbols.js" as Symbols
import "sf.js" as SF

// SF Symbol glyph: the real outline rendered on macOS 27.2.1 (themes/icons/sf-symbols, via sf.js), tinted
// to `color`. Names map through names.json (e.g. "controlcenter" -> switch.2); real SF names work too.
// The hand-drawn glyphs in symbols.js are only the fallback for names without an SVG.
// The glyph is rasterised once per name, colour and size (Image cache), never per frame.
Item {
    id: root

    property string name
    property real size: 16                       // layout box, size x size
    property color color: Theme.color.label
    // Surface the glyph sits on, for the point size macOS uses there (sf.js surfaces, names.json R3b-2):
    // "menubar", "ccToggle", "ccRound", "ccMedia", "ccPlay", "ccSlider", "ccOutput", "nc"; "" = size-based.
    property string surface: ""
    property real pointSize: surface ? SF.surfaces[surface] : size * SF.pointScale
    // Compared with the reference shots: menu bar and Finder toolbar glyphs match regular, Control Center
    // toggle glyphs semibold (screens/macos27-control-center.png). Not measured elsewhere: regular.
    property string weight: surface === "ccToggle" ? "semibold" : "regular"
    property string renderingMode: ""            // "" = AppKit's default, "hierarchical", "multicolor"
    property real variableValue: -1              // 0..1: level (wifi, speaker.wave.3.fill); < 0 = none

    // A scale per path of the glyph (sf.js path order), about the glyph's ink centre: the SF Symbols bounce by layer
    // (HyprK SymbolBounce.scales). Empty, or all 1: the glyph is one image, as always.
    property var layerScales: []
    readonly property bool layered: {
        if (!box) return false;
        for (let i = 0; i < layerScales.length; i++) if (layerScales[i] !== 1) return true;
        return false;
    }
    // ink centre in the image's coordinates (the bounds of the paths' points, control points included)
    readonly property point inkCentre: {
        if (!box) return Qt.point(0, 0);
        let x0 = Infinity, x1 = -Infinity, y0 = Infinity, y1 = -Infinity;
        for (const p of SF.glyphs[key][6]) {
            const n = p[0].match(/-?\d+(?:\.\d+)?/g) || [];
            for (let i = 0; i + 1 < n.length; i += 2) {
                const x = parseFloat(n[i]), y = parseFloat(n[i + 1]);
                x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y);
            }
        }
        const k = box.w / box.vb[2];
        return Qt.point(((x0 + x1) / 2 - box.vb[0]) * k, ((y0 + y1) / 2 - box.vb[1]) * k);
    }

    readonly property string key: Symbols.handDrawnOnly(name) ? "" : SF.pick(name, weight, renderingMode, variableValue)
    readonly property var box: key ? SF.layout(key, pointSize, size, false) : null
    // glyph units (points at 32 pt, SVG coordinates) -> item coordinates: x = origin.x + gx * unit
    readonly property real unit: pointSize / 32
    readonly property point origin: box ? Qt.point(box.x - box.vb[0] * unit, box.y - box.vb[1] * unit) : Qt.point(0, 0)

    implicitWidth: size
    implicitHeight: size

    Image {
        visible: root.box !== null && !root.layered
        x: root.box ? root.box.x : 0
        y: root.box ? root.box.y : 0
        width: root.box ? root.box.w : 0
        height: root.box ? root.box.h : 0
        // rendered at device pixels: Qt applies the devicePixelRatio itself only to URLs ending in "svg". On a 1.6
        // output Screen.devicePixelRatio says 2: the glyph is rasterised at 2x and drawn at 0.8, the Mac's own path for a
        // scaled mode (render at 2x, downsample); at the window's 1.6 it read 3 % softer (SCALING-AUDIT.md, glyphs)
        sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
        source: root.box ? SF.url(root.key, Qt.rgba(root.color.r, root.color.g, root.color.b, 1).toString(), root.box.vb) : ""
        opacity: root.color.a                    // Qt SVG ignores #AARRGGBB
        smooth: true
    }

    // the same picture, one image per path (the same rasteriser, so nothing changes when the bounce starts or ends)
    Repeater {
        model: root.layered ? SF.glyphs[root.key][6].length : 0
        Image {
            required property int index
            readonly property real s: root.layerScales[index] ?? 1
            x: root.box.x; y: root.box.y; width: root.box.w; height: root.box.h
            sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
            source: SF.url(root.key, Qt.rgba(root.color.r, root.color.g, root.color.b, 1).toString(), root.box.vb, index)
            opacity: root.color.a
            smooth: true
            transform: Scale { origin.x: root.inkCentre.x; origin.y: root.inkCentre.y; xScale: s; yScale: s }
        }
    }

    Loader {
        active: !root.box && root.name !== ""
        sourceComponent: Item {
            Repeater {
                model: Symbols.get(root.name)

                Shape {
                    required property var modelData
                    width: 24
                    height: 24
                    preferredRendererType: Shape.CurveRenderer
                    transform: Scale {
                        xScale: root.size / 24
                        yScale: root.size / 24
                    }

                    ShapePath {
                        fillColor: modelData.fill ? root.color : "transparent"
                        strokeColor: modelData.fill ? "transparent" : root.color
                        strokeWidth: modelData.fill ? 0 : modelData.sw
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        PathSvg { path: modelData.d }
                    }
                }
            }
        }
    }
}
