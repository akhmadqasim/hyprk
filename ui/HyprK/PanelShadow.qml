import QtQuick

// Drop shadow of a regular-glass panel (alerts, sheets, popovers), drawn as stacked translucent rounded rectangles:
// no offscreen blur, nothing animating. Size rule from the 27.2.1 glass recipe (MAC-ANSWERS.md PC #67 C, "Size"):
// opacity 0.04 + 0.56 q, radius 4 + 20 q with q = clamp((D - 64) / 96), D = the shortest side; the y offset is the
// recipe's 8 pt (Q-finder-01 drop shadow y 8). Put it behind the body with the body's geometry and corner radius.
Item {
    id: root
    property real cornerRadius: 0
    readonly property real _q: Math.max(0, Math.min(1, (Math.min(width, height) - 64) / 96))
    // `sigma` > 0: a Gaussian shadow instead (the shape's blur by a Gaussian of that sigma, pt), `density` its full
    // opacity: 24 rings at the Gaussian's quantiles, so a point d outside the edge is under the share 1 - Phi(d / sigma)
    // of them (System Settings' sheets, settings/controls/SubSheet.qml)
    property real sigma: 0
    property real density: -1
    readonly property real opacityTotal: density >= 0 ? density : 0.04 + 0.56 * _q
    readonly property real blur: 4 + 20 * _q
    property real offsetY: 8
    // 24 rings for a light shadow (2 levels per ring over a light window); 12 for a dense one: over a dark window a
    // thinner ring changes an 8 bit level by less than a half and is lost (a 45 % shadow over 27 stopped at 21)
    readonly property int steps: sigma > 0 && opacityTotal <= 0.3 ? 24 : 12
    // the normal quantiles of (i + 0.5) / steps, upper half
    readonly property var _z: steps === 24 ? [0.0522, 0.1573, 0.2641, 0.3741, 0.4888, 0.6103, 0.7416, 0.8871, 1.0545, 1.2582, 1.5341, 2.0368]
                                           : [0.1047, 0.3186, 0.5485, 0.8122, 1.1503, 1.7317]
    Repeater {
        model: root.steps
        Rectangle {
            required property int index
            // ring i spans the blur in equal steps; each adds a share so the centre reaches opacityTotal
            readonly property real grow: root.sigma > 0 ? root.sigma * (index < root.steps / 2 ? -root._z[root.steps / 2 - 1 - index] : root._z[index - root.steps / 2])
                                                        : root.blur * (index + 1) / root.steps - root.blur / 2
            x: -grow
            y: -grow + root.offsetY
            width: root.width + 2 * grow
            height: root.height + 2 * grow
            radius: Math.max(0, root.cornerRadius + grow)
            color: Qt.rgba(0, 0, 0, 1 - Math.pow(1 - root.opacityTotal, 1 / root.steps))
        }
    }
}
