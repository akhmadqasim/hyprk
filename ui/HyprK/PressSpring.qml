import QtQuick
import "motion.js" as Motion

// Interactive glass press (SwiftUI FlexInteraction cursor parameters, motion.js pressScale / GLASS-INTERACTION.md):
// while `pressed` the longer side grows by a couple of points (2.5 pt while it is under 120 pt, then 2.25 -> 2), as a
// uniform `scale`, on a bouncy spring (response 0.25 s; damping 0.629, or 0.375 -> 0.6 by size); after the release it
// settles back without overshoot (Tokens.motion.pressRelease*, measured).
// Reduce motion: no lift. Set settlesGlass: false when nothing glass scales with it.
Spring {
    property bool pressed: false
    property real w: 0
    property real h: 0
    settlesGlass: true
    target: pressed && !Tokens.reduceMotion ? 1 : 0
    response: pressed ? Tokens.motion.pressResponse : Tokens.motion.pressReleaseResponse
    damping: pressed ? Motion.pressDamping(w, h) : Tokens.motion.pressReleaseDamping
    readonly property real scale: 1 + (Motion.pressScale(w, h) - 1) * value
}
