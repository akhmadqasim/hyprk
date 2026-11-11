import QtQuick
import QtQuick.Effects

// Capsule platter behind a group of window-toolbar items (macOS 27.2.1 NSToolbarPlatterView, Tokens.toolbar):
// a flat raised capsule, not a glass strip. Put the items on top of it. Static: nothing animates. 
Item {
    id: p
    property real radius: height / 2
    // the 27.2.1 platter's shading (Tokens.toolbar.relief*): light, an opaque face inside the edge (the translucent
    // face let the drop shadow darken its lower half to 246) with a lit row under the top and over the bottom edge, a
    // darker band at a quarter of the height and darker round ends below it; a 1 px edge, dark on the sides (light
    // 191, dark 11) and lit at the top and bottom in dark. The light shape is Tokens.toolbar.reliefHeight tall (37 pt:
    // its edge rows lie outside the 36 pt face). Off: the flat look (the Finder tab bar track uses it)
    property bool relief: false
    // the relief's side darkening at dy pt from the middle (Tokens.toolbar.reliefSide*)
    function sideMaskAt(dy: real): color {
        const sg = Tokens.toolbar.reliefSideSigma;
        const d = Math.max(0, dy - Tokens.toolbar.reliefSideFlat);
        const a = Math.exp(-d * d / (2 * sg * sg));
        return Qt.rgba(1, 1, 1, 0.5 - Math.sin(Math.asin(1 - 2 * a) / 3));   // inverse smoothstep
    }

    function innerMaskAt(dy: real): color {
        const a = Math.max(0, Math.min(1, (dy - Tokens.toolbar.reliefInnerFrom) / (Tokens.toolbar.reliefInnerTo - Tokens.toolbar.reliefInnerFrom)));
        return Qt.rgba(1, 1, 1, 0.5 - Math.sin(Math.asin(1 - 2 * a) / 3));
    }
    function glowAt(i: int): color { return Qt.rgba(1, 1, 1, Tokens.toolbar.reliefGlow[i] ?? 0); }
    // light: the face's shade at d pt from a round end, as a stop of the face's horizontal gradient
    function endPos(i: int): real { return Math.min(0.5, Tokens.toolbar.reliefEnd[i][0] / Math.max(1, width - 1)); }
    function endColor(i: int): color { const v = Tokens.toolbar.reliefEnd[i][1] / 255; return Qt.rgba(v, v, v, 1); }

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
    // light face, inside the edge. Two layers, so it needs no shader: across, the lower half's shade towards the
    // round ends (Tokens.toolbar.reliefEnd); over it, top to bottom, the lit row, the band and the lit row above the
    // bottom edge, see-through below the band (rows of a 36 pt face, Tokens.toolbar.reliefRows)
    Item {
        visible: p.relief && !Tokens.dark
        anchors.fill: parent; anchors.margins: 0.5
        Rectangle {
            anchors.fill: parent
            radius: height / 2 - Math.max(0, p.height / 2 - p.radius)
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: p.endPos(0); color: p.endColor(0) }
                GradientStop { position: p.endPos(1); color: p.endColor(1) }
                GradientStop { position: p.endPos(2); color: p.endColor(2) }
                GradientStop { position: p.endPos(3); color: p.endColor(3) }
                GradientStop { position: p.endPos(4); color: p.endColor(4) }
                GradientStop { position: p.endPos(5); color: p.endColor(5) }
                GradientStop { position: 1 - p.endPos(5); color: p.endColor(5) }
                GradientStop { position: 1 - p.endPos(4); color: p.endColor(4) }
                GradientStop { position: 1 - p.endPos(3); color: p.endColor(3) }
                GradientStop { position: 1 - p.endPos(2); color: p.endColor(2) }
                GradientStop { position: 1 - p.endPos(1); color: p.endColor(1) }
                GradientStop { position: 1 - p.endPos(0); color: p.endColor(0) }
            }
        }
        Rectangle {
            anchors.fill: parent
            radius: height / 2 - Math.max(0, p.height / 2 - p.radius)
            gradient: Gradient {
                GradientStop { position: 0.007; color: "#FFFFFF" }
                GradientStop { position: 0.021; color: "#FFFFFF" }
                GradientStop { position: 0.035; color: Tokens.toolbar.reliefTop }
                GradientStop { position: 0.062; color: Tokens.toolbar.reliefTop }
                GradientStop { position: 0.188; color: Tokens.toolbar.reliefMid }
                GradientStop { position: 0.368; color: Tokens.toolbar.reliefMid }
                GradientStop { position: 0.535; color: Qt.alpha(Tokens.toolbar.reliefMid, 0) }
                GradientStop { position: 0.965; color: Qt.alpha(Tokens.toolbar.reliefTop, 0) }
                GradientStop { position: 0.979; color: "#FFFFFF" }
                GradientStop { position: 0.993; color: "#FFFFFF" }
            }
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
    // its sides darker: the same 0.5 pt ring in the side colour, faded in around the middle of the ends (flat, then
    // Gaussian in y) by an alpha mask. Drawn as a Rectangle border so the edge stays 1 px: the ring as a Shape
    // (CurveRenderer) spread over 3 px (row through the middle, dark, 2x: 25 36 48 61 where the Mac has 10 62)
    Item {
        visible: p.relief
        anchors.fill: parent
        layer.enabled: visible
        layer.effect: MultiEffect {
            maskEnabled: true; maskSource: sideMask
            maskThresholdMin: 0.5; maskSpreadAtMin: 1.0   // smoothstep(0, 1, mask alpha): sideMaskAt() inverts it
        }
        Rectangle {
            anchors.fill: parent
            radius: p.radius
            color: "transparent"
            border.width: 0.5
            border.color: Tokens.toolbar.reliefSide
        }
    }
    Rectangle {
        id: sideMask
        visible: false
        layer.enabled: p.relief
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.5 + -17.5 / Math.max(1, p.height); color: p.sideMaskAt(17.5) }
            GradientStop { position: 0.5 + -15.5 / Math.max(1, p.height); color: p.sideMaskAt(15.5) }
            GradientStop { position: 0.5 + -14.5 / Math.max(1, p.height); color: p.sideMaskAt(14.5) }
            GradientStop { position: 0.5 + -13.5 / Math.max(1, p.height); color: p.sideMaskAt(13.5) }
            GradientStop { position: 0.5 + -12.5 / Math.max(1, p.height); color: p.sideMaskAt(12.5) }
            GradientStop { position: 0.5 + -11.5 / Math.max(1, p.height); color: p.sideMaskAt(11.5) }
            GradientStop { position: 0.5 + -9 / Math.max(1, p.height); color: p.sideMaskAt(9) }
            GradientStop { position: 0.5 + -6 / Math.max(1, p.height); color: p.sideMaskAt(6) }
            GradientStop { position: 0.5 + -4 / Math.max(1, p.height); color: p.sideMaskAt(4) }
            GradientStop { position: 0.5 + -3 / Math.max(1, p.height); color: p.sideMaskAt(3) }
            GradientStop { position: 0.5 + -2 / Math.max(1, p.height); color: p.sideMaskAt(2) }
            GradientStop { position: 0.5 + -1 / Math.max(1, p.height); color: p.sideMaskAt(1) }
            GradientStop { position: 0.5 + 0 / Math.max(1, p.height); color: p.sideMaskAt(0) }
            GradientStop { position: 0.5 + 1 / Math.max(1, p.height); color: p.sideMaskAt(1) }
            GradientStop { position: 0.5 + 2 / Math.max(1, p.height); color: p.sideMaskAt(2) }
            GradientStop { position: 0.5 + 3 / Math.max(1, p.height); color: p.sideMaskAt(3) }
            GradientStop { position: 0.5 + 4 / Math.max(1, p.height); color: p.sideMaskAt(4) }
            GradientStop { position: 0.5 + 6 / Math.max(1, p.height); color: p.sideMaskAt(6) }
            GradientStop { position: 0.5 + 9 / Math.max(1, p.height); color: p.sideMaskAt(9) }
            GradientStop { position: 0.5 + 11.5 / Math.max(1, p.height); color: p.sideMaskAt(11.5) }
            GradientStop { position: 0.5 + 12.5 / Math.max(1, p.height); color: p.sideMaskAt(12.5) }
            GradientStop { position: 0.5 + 13.5 / Math.max(1, p.height); color: p.sideMaskAt(13.5) }
            GradientStop { position: 0.5 + 14.5 / Math.max(1, p.height); color: p.sideMaskAt(14.5) }
            GradientStop { position: 0.5 + 15.5 / Math.max(1, p.height); color: p.sideMaskAt(15.5) }
            GradientStop { position: 0.5 + 17.5 / Math.max(1, p.height); color: p.sideMaskAt(17.5) }
        }
    }
    // dark: the row glow under the lit top edge and over the bottom one (Tokens.toolbar.reliefGlow)
    Rectangle {
        visible: p.relief && Tokens.toolbar.reliefGlow.length > 0
        anchors.fill: parent; anchors.margins: 1
        radius: Math.max(0, p.radius - 1)
        gradient: Gradient {
            GradientStop { position: 0 / Math.max(1, p.height - 2); color: p.glowAt(0) }
            GradientStop { position: 0.5 / Math.max(1, p.height - 2); color: p.glowAt(1) }
            GradientStop { position: 1 / Math.max(1, p.height - 2); color: p.glowAt(2) }
            GradientStop { position: 1.5 / Math.max(1, p.height - 2); color: p.glowAt(3) }
            GradientStop { position: 2 / Math.max(1, p.height - 2); color: p.glowAt(4) }
            GradientStop { position: 2.5 / Math.max(1, p.height - 2); color: p.glowAt(5) }
            GradientStop { position: 3 / Math.max(1, p.height - 2); color: p.glowAt(6) }
            GradientStop { position: 4 / Math.max(1, p.height - 2); color: p.glowAt(7) }
            GradientStop { position: 5 / Math.max(1, p.height - 2); color: p.glowAt(8) }
            GradientStop { position: 1 - 5 / Math.max(1, p.height - 2); color: p.glowAt(8) }
            GradientStop { position: 1 - 4 / Math.max(1, p.height - 2); color: p.glowAt(7) }
            GradientStop { position: 1 - 3 / Math.max(1, p.height - 2); color: p.glowAt(6) }
            GradientStop { position: 1 - 2.5 / Math.max(1, p.height - 2); color: p.glowAt(5) }
            GradientStop { position: 1 - 2 / Math.max(1, p.height - 2); color: p.glowAt(4) }
            GradientStop { position: 1 - 1.5 / Math.max(1, p.height - 2); color: p.glowAt(3) }
            GradientStop { position: 1 - 1 / Math.max(1, p.height - 2); color: p.glowAt(2) }
            GradientStop { position: 1 - 0.5 / Math.max(1, p.height - 2); color: p.glowAt(1) }
            GradientStop { position: 1 - 0 / Math.max(1, p.height - 2); color: p.glowAt(0) }
        }
    }
    // dark: the second px ring (Tokens.toolbar.reliefInner), masked out towards the middle of the sides. Static: one texture
    Item {
        visible: p.relief && Tokens.toolbar.reliefInner.a > 0
        anchors.fill: parent
        layer.enabled: visible
        layer.effect: MultiEffect {
            maskEnabled: true; maskSource: innerMask
            maskThresholdMin: 0.5; maskSpreadAtMin: 1.0
        }
        Rectangle {
            anchors.fill: parent; anchors.margins: 0.5
            radius: Math.max(0, p.radius - 0.5)
            color: "transparent"
            border.width: 0.5
            border.color: Tokens.toolbar.reliefInner
        }
    }
    Rectangle {
        id: innerMask
        visible: false
        layer.enabled: p.relief && Tokens.toolbar.reliefInner.a > 0
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.5 + -17 / Math.max(1, p.height); color: p.innerMaskAt(17) }
            GradientStop { position: 0.5 + -14 / Math.max(1, p.height); color: p.innerMaskAt(14) }
            GradientStop { position: 0.5 + -11 / Math.max(1, p.height); color: p.innerMaskAt(11) }
            GradientStop { position: 0.5 + -8 / Math.max(1, p.height); color: p.innerMaskAt(8) }
            GradientStop { position: 0.5 + -5 / Math.max(1, p.height); color: p.innerMaskAt(5) }
            GradientStop { position: 0.5 + 5 / Math.max(1, p.height); color: p.innerMaskAt(5) }
            GradientStop { position: 0.5 + 8 / Math.max(1, p.height); color: p.innerMaskAt(8) }
            GradientStop { position: 0.5 + 11 / Math.max(1, p.height); color: p.innerMaskAt(11) }
            GradientStop { position: 0.5 + 14 / Math.max(1, p.height); color: p.innerMaskAt(14) }
            GradientStop { position: 0.5 + 17 / Math.max(1, p.height); color: p.innerMaskAt(17) }
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
