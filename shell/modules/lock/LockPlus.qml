import QtQuick

// Vibrant lock ink: draws its children's coverage as `lift` added to whatever is behind (plus-lighter,
// lockplus.frag), the way every glyph, dot, ring and label of the 27.2.1 lock screen is drawn
// (LOCKSCREEN-27.2.1.md A2-A6). Children are drawn in any opaque colour; only their alpha counts.
// The layer is rendered again only when a child changes (a still lock redraws nothing).
Item {
    id: p
    property vector3d lift: Qt.vector3d(0.3, 0.3, 0.3)
    property real edge: 0          // clock only: white top line strength
    property real edgePx: 2        // and its decay in device px
    property real rim: 0           // clock only: 1 px dark outer rim

    layer.enabled: visible && opacity > 0
    layer.smooth: true
    layer.effect: ShaderEffect {
        property vector4d lift: Qt.vector4d(p.lift.x, p.lift.y, p.lift.z, 0)
        property size texel: Qt.size(1 / Math.max(1, width * Screen.devicePixelRatio), 1 / Math.max(1, height * Screen.devicePixelRatio))
        property real edge: p.edge
        property real edgePx: p.edgePx
        property real rim: p.rim
        fragmentShader: Qt.resolvedUrl("lockplus.frag.qsb")
    }
}
