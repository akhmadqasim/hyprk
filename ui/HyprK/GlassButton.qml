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

    // Buttons merged into this one glass (widths, left to right; the Appearance preview's share | more capsule). In
    // SwiftUI each button is its own glass entry (GlassContainer.InteractionStorage per Entry.StableID): the pressed one
    // lifts by its own size and only its outer edge moves; the neighbour's end stays (recording: the far end moves
    // 0.35 pt, the union's blend, not drawn). Empty: the whole glass is one button.
    property var segments: []
    readonly property int _seg: {
        if (segments.length < 2) return -1;
        let x = 0;
        for (let i = 0; i < segments.length; i++) { x += segments[i]; if (tap.startX < x) return i; }
        return segments.length - 1;
    }
    readonly property real _segW: _seg >= 0 ? segments[_seg] : width

    PressSpring { id: press; pressed: b.pressed; w: b._segW; h: b.height }
    // the stretch follows the pointer only while pressed (no binding work at rest); it fades with the lift's spring
    readonly property var _st: tap.pressed && press.value > 0
        ? Motion.pressStretch(b.width, b.height, tap.startX, tap.startY, tap.mouseX, tap.mouseY) : [0, 0, 0, 0]
    transform: [
        // reduce = false: under Reduce motion the host's glass already holds materialize at 1
        Scale {
            origin.x: b.width / 2
            origin.y: b.height / 2
            xScale: Motion.materializeScale(b.width, b.materialize, false)
            yScale: Motion.materializeScale(b.height, b.materialize, false)
        },
        Scale {
            readonly property real lift: press.scale - 1
            readonly property bool first: b._seg === 0
            readonly property bool last: b._seg === b.segments.length - 1
            origin.x: b._seg < 0 ? b.width / 2 : first ? b.width : 0
            origin.y: b.height / 2
            xScale: (b._seg < 0 ? 1 + lift : first || last ? 1 + b._segW * lift / 2 / Math.max(b.width, 1) : 1)
                    + b._st[0] * press.value
            yScale: 1 + lift + b._st[1] * press.value
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
