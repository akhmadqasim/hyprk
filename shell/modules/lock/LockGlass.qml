import QtQuick
import QtQuick.Effects

// Glass on the lock screen. The backdrop under it is already the blurred lock wallpaper, so the
// material is its face (tint), a top-lit rim and the regular-glass drop shadow; no live blur and no
// compositor plugin (session lock surfaces are not layer surfaces, the plugin never sees them).
// Reduce Transparency / Increase Contrast: an opaque fill.
Item {
    id: g
    property real radius: height / 2
    property color face: LockTheme.fieldFace
    property color solidColor: LockTheme.fieldSolid
    property color rim: LockTheme.fieldRim
    property color rimTop: LockTheme.fieldRimTop
    property bool shadow: true

    RectangularShadow {
        visible: g.shadow && !LockTheme.solid
        anchors.fill: parent
        radius: g.radius
        blur: LockTheme.fieldShadowBlur
        offset.y: LockTheme.fieldShadowY
        color: LockTheme.fieldShadow
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
