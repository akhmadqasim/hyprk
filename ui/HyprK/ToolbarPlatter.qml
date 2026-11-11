import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// Capsule platter behind a group of window-toolbar items (macOS 27.2.1 NSToolbarPlatterView, Tokens.toolbar):
// a flat raised capsule, not a glass strip. Put the items on top of it. Static: nothing animates. 
Item {
    id: p
    property real radius: height / 2
    // the 27.2.1 platter's shading (Tokens.toolbar.relief*): light, an opaque face 253 / 248 / 252 top to bottom (the
    // translucent face let the drop shadow darken its lower half to 246); a 1 px edge, dark on the sides (light 191,
    // dark 11) and lit at the top and bottom in dark. Off: the flat look (the Finder tab bar track uses it)
    property bool relief: false
    // the relief's side darkening at dy pt from the middle (Tokens.toolbar.reliefSide*)
    function reliefSideAt(dy: real): color {
        const c = Tokens.toolbar.reliefSide, s = Tokens.toolbar.reliefSideSigma;
        const d = Math.max(0, dy - Tokens.toolbar.reliefSideFlat);
        return Qt.rgba(c.r, c.g, c.b, c.a * Math.exp(-d * d / (2 * s * s)));
    }

    implicitHeight: Tokens.toolbar.platterHeight

    RectangularShadow {
        anchors.fill: parent
        radius: p.radius
        blur: Tokens.toolbar.shadowRadius
        offset.y: Tokens.toolbar.shadowOffsetY
        color: Tokens.toolbar.shadow
    }
    Rectangle {
        visible: !p.relief || Tokens.dark
        anchors.fill: parent
        radius: p.radius
        color: p.relief ? Qt.rgba(1, 1, 1, Tokens.toolbar.reliefDarkFaceAlpha) : Tokens.toolbar.face
        border.width: p.relief ? 0 : 1
        border.color: Tokens.toolbar.rim
    }
    Rectangle {
        visible: p.relief && !Tokens.dark
        anchors.fill: parent
        radius: p.radius
        gradient: Gradient {
            GradientStop { position: 0.08; color: Tokens.toolbar.reliefTop }
            GradientStop { position: 0.36; color: Tokens.toolbar.reliefMid }
            GradientStop { position: 0.62; color: Tokens.toolbar.reliefLow }
        }
    }
    Rectangle {   // the 1 px edge (0.5 pt)
        visible: p.relief
        anchors.fill: parent
        radius: p.radius
        color: "transparent"
        border.width: 0.5
        border.color: Tokens.toolbar.reliefEdge
    }
    // its sides darker: the same 0.5 pt ring, faded in around the middle of the ends (flat, then Gaussian in y). A band clipped
    // to the middle third started and stopped in one pixel row, so the round ends looked cut off (user report).
    Shape {
        visible: p.relief
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: -1
            fillRule: ShapePath.OddEvenFill
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: 0; y2: p.height
                GradientStop { position: 0.5 + -17.5 / Math.max(1, p.height); color: p.reliefSideAt(17.5) }
                GradientStop { position: 0.5 + -15.5 / Math.max(1, p.height); color: p.reliefSideAt(15.5) }
                GradientStop { position: 0.5 + -14.5 / Math.max(1, p.height); color: p.reliefSideAt(14.5) }
                GradientStop { position: 0.5 + -13.5 / Math.max(1, p.height); color: p.reliefSideAt(13.5) }
                GradientStop { position: 0.5 + -12.5 / Math.max(1, p.height); color: p.reliefSideAt(12.5) }
                GradientStop { position: 0.5 + -11.5 / Math.max(1, p.height); color: p.reliefSideAt(11.5) }
                GradientStop { position: 0.5 + -9 / Math.max(1, p.height); color: p.reliefSideAt(9) }
                GradientStop { position: 0.5 + -6 / Math.max(1, p.height); color: p.reliefSideAt(6) }
                GradientStop { position: 0.5 + -4 / Math.max(1, p.height); color: p.reliefSideAt(4) }
                GradientStop { position: 0.5 + -3 / Math.max(1, p.height); color: p.reliefSideAt(3) }
                GradientStop { position: 0.5 + -2 / Math.max(1, p.height); color: p.reliefSideAt(2) }
                GradientStop { position: 0.5 + -1 / Math.max(1, p.height); color: p.reliefSideAt(1) }
                GradientStop { position: 0.5 + 0 / Math.max(1, p.height); color: p.reliefSideAt(0) }
                GradientStop { position: 0.5 + 1 / Math.max(1, p.height); color: p.reliefSideAt(1) }
                GradientStop { position: 0.5 + 2 / Math.max(1, p.height); color: p.reliefSideAt(2) }
                GradientStop { position: 0.5 + 3 / Math.max(1, p.height); color: p.reliefSideAt(3) }
                GradientStop { position: 0.5 + 4 / Math.max(1, p.height); color: p.reliefSideAt(4) }
                GradientStop { position: 0.5 + 6 / Math.max(1, p.height); color: p.reliefSideAt(6) }
                GradientStop { position: 0.5 + 9 / Math.max(1, p.height); color: p.reliefSideAt(9) }
                GradientStop { position: 0.5 + 11.5 / Math.max(1, p.height); color: p.reliefSideAt(11.5) }
                GradientStop { position: 0.5 + 12.5 / Math.max(1, p.height); color: p.reliefSideAt(12.5) }
                GradientStop { position: 0.5 + 13.5 / Math.max(1, p.height); color: p.reliefSideAt(13.5) }
                GradientStop { position: 0.5 + 14.5 / Math.max(1, p.height); color: p.reliefSideAt(14.5) }
                GradientStop { position: 0.5 + 15.5 / Math.max(1, p.height); color: p.reliefSideAt(15.5) }
                GradientStop { position: 0.5 + 17.5 / Math.max(1, p.height); color: p.reliefSideAt(17.5) }
            }
            PathRectangle { x: 0; y: 0; width: p.width; height: p.height; radius: p.radius }
            PathRectangle { x: 0.5; y: 0.5; width: p.width - 1; height: p.height - 1; radius: p.radius - 0.5 }
        }
    }
    // dark: the top and bottom edges are lit, the sides are not (two clipped bands of one border)
    Repeater {
        model: Tokens.toolbar.rimLit.a > 0 && !p.relief ? 2 : 0
        Item {
            required property int index
            y: index === 0 ? 0 : p.height - height
            width: p.width
            height: Math.round(p.radius * 0.6)
            clip: true
            Rectangle {
                y: -parent.y
                width: p.width
                height: p.height
                radius: p.radius
                color: "transparent"
                border.width: 1
                border.color: Tokens.toolbar.rimLit
            }
        }
    }
}
