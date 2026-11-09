import QtQuick
import QtQuick.Shapes
import qs
import "symbols.js" as Symbols

// Vector glyph from symbols.js, colorable and resolution independent.
Item {
    id: root

    property string name
    property real size: 16
    property color color: Theme.color.label

    implicitWidth: size
    implicitHeight: size

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
