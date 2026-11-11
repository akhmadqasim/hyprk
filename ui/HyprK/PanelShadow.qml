import QtQuick

// Drop shadow of a regular-glass panel (alerts, sheets, popovers), drawn as stacked translucent rounded rectangles:
// no offscreen blur, nothing animating. Size rule from the 27.2.1 glass recipe (MAC-ANSWERS.md PC #67 C, "Size"):
// opacity 0.04 + 0.56 q, radius 4 + 20 q with q = clamp((D - 64) / 96), D = the shortest side; the y offset is the
// recipe's 8 pt (Q-finder-01 drop shadow y 8). Put it behind the body with the body's geometry and corner radius.
Item {
    id: root
    property real cornerRadius: 0
    readonly property real _q: Math.max(0, Math.min(1, (Math.min(width, height) - 64) / 96))
    readonly property real opacityTotal: 0.04 + 0.56 * _q
    readonly property real blur: 4 + 20 * _q
    property real offsetY: 8
    readonly property int steps: 12
    Repeater {
        model: root.steps
        Rectangle {
            required property int index
            // ring i spans the blur in equal steps; each adds a share so the centre reaches opacityTotal
            readonly property real grow: root.blur * (index + 1) / root.steps - root.blur / 2
            x: -grow
            y: -grow + root.offsetY
            width: root.width + 2 * grow
            height: root.height + 2 * grow
            radius: Math.max(0, root.cornerRadius + grow)
            color: Qt.rgba(0, 0, 0, 1 - Math.pow(1 - root.opacityTotal, 1 / root.steps))
        }
    }
}
