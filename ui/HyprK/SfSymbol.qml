import QtQuick
import QtQuick.Shapes
import "sfpaths.js" as Sf

// An SF Symbol drawn from its real outline (sfpaths.js) at `pointSize`, in one colour. The item is the glyph's ink
// box, so it can be placed by the numbers measured on a Mac shot; `advance` and `bearing` give the symbol's layout
// frame (what AppKit and SwiftUI lay an image out by) for callers that place it as the Mac does. Names not in the
// table draw nothing; add them with ui/scripts/sfpaths.py from themes/icons/sf-symbols.
Item {
    id: g
    property string name
    property string weight: "regular"
    property real pointSize: 13
    property color color: Tokens.label
    readonly property var glyph: Sf.get(name, weight)
    readonly property real unit: pointSize / (glyph && glyph.pt ? glyph.pt : 32)   // "pt": outlines kept at another size
    readonly property real advance: glyph ? (glyph.a ? glyph.a[1] : glyph.rect[2]) * unit : 0   // width of the layout frame
    readonly property real bearing: glyph && glyph.a ? (glyph.rect[0] - glyph.a[0]) * unit : 0  // frame's left edge to the ink
    // a scale per path about the centre of the ink box: the SF Symbols bounce by layer (SymbolBounce.scales)
    property var layerScales: []
    implicitWidth: glyph ? glyph.rect[2] * unit : 0
    implicitHeight: glyph ? glyph.rect[3] * unit : 0
    Repeater {
        model: g.glyph ? g.glyph.d : []
        Shape {
            required property string modelData
            required property int index
            readonly property real s: g.layerScales[index] ?? 1
            opacity: g.glyph.o ? g.glyph.o[index] : 1   // variable symbols (wifi.var-50): the dimmed layers
            preferredRendererType: Shape.CurveRenderer
            transform: [Translate { x: -g.glyph.rect[0]; y: -g.glyph.rect[1] }, Scale { xScale: g.unit; yScale: g.unit },
                        Scale { origin.x: g.width / 2; origin.y: g.height / 2; xScale: s; yScale: s }]
            ShapePath {
                fillColor: g.color
                strokeColor: "transparent"
                strokeWidth: 0
                fillRule: g.glyph.rule === "evenodd" ? ShapePath.OddEvenFill : ShapePath.WindingFill
                PathSvg { path: modelData }
            }
        }
    }
}
