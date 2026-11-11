import QtQuick
import QtQuick.Shapes
import ".."
import "sfpaths.js" as Sf

// An SF Symbol drawn from its real outline (sfpaths.js) at `pointSize`, in one colour. The item is the glyph's ink
// box, so it can be placed by the numbers measured on a Mac shot. Names not in the table draw nothing.
Item {
    id: g
    property string name
    property string weight: "regular"
    property real pointSize: 13
    property color color: Theme.label
    readonly property var glyph: Sf.get(name, weight)
    readonly property real unit: pointSize / 32
    implicitWidth: glyph ? glyph.rect[2] * unit : 0
    implicitHeight: glyph ? glyph.rect[3] * unit : 0
    Repeater {
        model: g.glyph ? g.glyph.d : []
        Shape {
            required property string modelData
            preferredRendererType: Shape.CurveRenderer
            transform: [Translate { x: -g.glyph.rect[0]; y: -g.glyph.rect[1] }, Scale { xScale: g.unit; yScale: g.unit }]
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
