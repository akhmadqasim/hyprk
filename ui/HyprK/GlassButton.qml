import QtQuick
import "motion.js" as Motion

// Interactive Liquid Glass control (Control Center modules, Spotlight mode buttons): pressing lifts
// it by a couple of points on a bouncy spring (PressSpring); a drag while pressed stretches it along the drag and
// shifts it toward the pointer by SwiftUI's own rule (motion.js pressStretch, applyScale 0x190c225cc: well under a
// point on a Mac-sized button); while materializing it shrinks from its hidden scale around its centre
// (`materialize`, 0 hidden .. 1 shown). The host puts its glass material and content inside;
// HyprK has no glass of its own (the shell's Glass needs Quickshell).
// Reduce motion: no lift, no stretch (PressSpring).
Item {
    id: b
    property bool interactive: true          // clicks (a disabled button: enabled: false)
    property bool hoverable: false           // track `hovered` (costs a hit test per pointer move)
    property bool pressed: tap.containsPress // the press look clears while the pointer is outside, like macOS
    readonly property bool hovered: tap.containsMouse
    property real materialize: 1
    signal clicked()

    PressSpring { id: press; pressed: b.pressed; w: b.width; h: b.height }
    // the stretch follows the pointer only while pressed (no binding work at rest); it fades with the lift's spring
    readonly property var _st: tap.pressed && press.value > 0
        ? Motion.pressStretch(b.width, b.height, tap.startX, tap.startY, tap.mouseX, tap.mouseY) : [0, 0, 0, 0]
    transform: [
        Scale {
            origin.x: b.width / 2
            origin.y: b.height / 2
            readonly property real lift: press.scale - 1
            // reduce = false: under Reduce motion the host's glass already holds materialize at 1
            xScale: Motion.materializeScale(b.width, b.materialize, false) * (1 + lift + b._st[0] * press.value)
            yScale: Motion.materializeScale(b.height, b.materialize, false) * (1 + lift + b._st[1] * press.value)
        },
        Translate { x: b._st[2] * press.value; y: b._st[3] * press.value }
    ]
    MouseArea {
        id: tap
        property real startX: 0
        property real startY: 0
        anchors.fill: parent
        hoverEnabled: b.hoverable
        enabled: b.interactive
        onPressed: m => { startX = m.x; startY = m.y; }
        onClicked: b.clicked()
    }
}
