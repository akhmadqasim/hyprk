import QtQuick
import QtQuick.Effects

// Capsule platter behind a group of window-toolbar items (macOS 27.2.1 NSToolbarPlatterView, Tokens.toolbar):
// a flat raised capsule, not a glass strip. Put the items on top of it. Static: nothing animates.
Item {
    id: p
    property real radius: height / 2

    implicitHeight: Tokens.toolbar.platterHeight

    RectangularShadow {
        anchors.fill: parent
        radius: p.radius
        blur: Tokens.toolbar.shadowRadius
        offset.y: Tokens.toolbar.shadowOffsetY
        color: Tokens.toolbar.shadow
    }
    Rectangle {
        anchors.fill: parent
        radius: p.radius
        color: Tokens.toolbar.face
        border.width: 1
        border.color: Tokens.toolbar.rim
    }
    // dark: the top and bottom edges are lit, the sides are not (two clipped bands of one border)
    Repeater {
        model: Tokens.toolbar.rimLit.a > 0 ? 2 : 0
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
