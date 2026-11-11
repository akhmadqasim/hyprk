import QtQuick
import QtQuick.Effects

// Capsule platter behind a group of window-toolbar items (macOS 27.2.1 NSToolbarPlatterView, Tokens.toolbar):
// a flat raised capsule, not a glass strip. Put the items on top of it. Static: nothing animates.
Item {
    id: p
    property real radius: height / 2
    // the 27.2.1 platter's shading (Tokens.toolbar.relief*): light, an opaque face 253 / 248 / 252 top to bottom (the
    // translucent face let the drop shadow darken its lower half to 246); a 1 px edge, dark on the sides (light 191,
    // dark 11) and lit at the top and bottom in dark. Off: the flat look (the Finder tab bar track uses it)
    property bool relief: false

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
        color: Tokens.toolbar.face
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
    Item {        // its sides darker: the same edge clipped to the straight middle third
        visible: p.relief
        y: Math.round(p.height / 3)
        width: p.width
        height: p.height - 2 * y
        clip: true
        Rectangle {
            y: -parent.y
            width: p.width
            height: p.height
            radius: p.radius
            color: "transparent"
            border.width: 0.5
            border.color: Tokens.toolbar.reliefSide
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
