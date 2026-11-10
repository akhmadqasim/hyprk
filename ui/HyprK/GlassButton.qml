import QtQuick
import "motion.js" as Motion

// Interactive Liquid Glass control (Control Center modules, Spotlight mode buttons): pressing lifts
// it by a couple of points on a bouncy spring (PressSpring), a drag past a slider end stretches it
// (`stretch`, -1..1 along x), and while materializing it shrinks from its hidden scale around its
// centre (`materialize`, 0 hidden .. 1 shown). The host puts its glass material and content inside;
// HyprK has no glass of its own (the shell's Glass needs Quickshell).
// Reduce motion: no lift (PressSpring).
Item {
    id: b
    property bool interactive: true          // clicks (a disabled button: enabled: false)
    property bool hoverable: false           // track `hovered` (costs a hit test per pointer move)
    property bool pressed: tap.containsPress // the press look clears while the pointer is outside, like macOS
    readonly property bool hovered: tap.containsMouse
    property real materialize: 1
    property real stretch: 0
    signal clicked()

    PressSpring { id: press; pressed: b.pressed; w: b.width; h: b.height }
    transform: Scale {
        origin.x: b.width / 2
        origin.y: b.height / 2
        readonly property real lift: press.scale - 1
        readonly property real squish: Tokens.motion.pressSquish * Math.abs(b.stretch) * press.value
        // reduce = false: under Reduce motion the host's glass already holds materialize at 1
        xScale: Motion.materializeScale(b.width, b.materialize, false) * (1 + lift + squish)
        yScale: Motion.materializeScale(b.height, b.materialize, false) * (1 + lift - squish / 2)
    }
    MouseArea {
        id: tap
        anchors.fill: parent
        hoverEnabled: b.hoverable
        enabled: b.interactive
        onClicked: b.clicked()
    }
}
