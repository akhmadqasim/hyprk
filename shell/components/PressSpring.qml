import QtQuick
import qs
import qs.services
import "../lib/motion.js" as Motion

// Interactive glass press (SwiftUI FlexInteraction cursor presets, SPEC 10.3): while `pressed` the
// item lifts by a couple of points (ultraSmall below 120 pt: 2.5 pt, small 2.25, large 2), as
// `scale`, on a bouncy spring (response 0.25 s; damping 0.629 / 0.375 / 0.6 by size).
// Reduce motion: no lift. Set settlesGlass: false when nothing glass scales with it.
NcSpring {
    property bool pressed: false
    property real w: 0
    property real h: 0
    settlesGlass: true
    target: pressed && !A11y.reduceMotion ? 1 : 0
    response: Theme.anim.pressResponse
    damping: Motion.pressDamping(w, h)
    readonly property real scale: 1 + (Motion.pressScale(w, h) - 1) * value
}
