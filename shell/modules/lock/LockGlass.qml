import QtQuick
import QtQuick.Effects

// Glass of the notification and Now Playing cards on the lock screen (not seen on the Mac: ours). Its face
// (tint), a top-lit rim and the regular-glass drop shadow; no live blur and no compositor plugin (session
// lock surfaces are not layer surfaces, the plugin never sees them). Reduce Transparency / Increase
// Contrast: an opaque fill.
Item {
    id: g
    property real radius: height / 2
    property color face: LockTheme.cardFace
    property color solidColor: LockTheme.cardSolid
    property color rim: LockTheme.cardRim
    property color rimTop: LockTheme.cardRimTop
    property bool shadow: true

    RectangularShadow {
        visible: g.shadow && !LockTheme.solid
        anchors.fill: parent
        radius: g.radius
        blur: LockTheme.cardShadowBlur
        offset.y: LockTheme.cardShadowY
        color: LockTheme.cardShadow
    }
    Rectangle {
        anchors.fill: parent
        radius: g.radius
        color: LockTheme.solid ? g.solidColor : g.face
        border.width: 1
        border.color: g.rim
    }
    // brighter top edge, clipped to the upper half so it fades down the sides
    Item {
        visible: !LockTheme.solid
        width: parent.width
        height: Math.min(parent.height, g.radius)
        clip: true
        Rectangle {
            width: g.width
            height: g.height
            radius: g.radius
            color: "transparent"
            border.width: 1
            border.color: g.rimTop
        }
    }
}
