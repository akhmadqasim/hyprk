import QtQuick
import "motion.js" as Motion

// Liquid Glass appear and disappear of one glass surface (SwiftUI glass materialize transition,
// liquid-glass-re notes/round3): `value` springs to 1 while `shown` and back to 0 when not, on the
// transition spring (response 0.5, damping 0.7). The surface's glass takes `progress` as its
// materialize (the plugin ramps lensing, blur, tint, rim and shadow; the QML fallback fades), its
// content takes `progress` as opacity, and its transform takes scaleFor(width) / scaleFor(height):
// from min((dim + 16) / dim, 1.2) down to 1 around the surface's anchor (MaterializeScale).
// Reduce motion: a 0.15 s dissolve, no scale. `active` stays true until it has dematerialized.
// Set `initial: 0` on surfaces created on open, so they materialize from creation.
Spring {
    property bool shown: false
    target: shown ? 1 : 0
    response: Tokens.reduceMotion ? Tokens.motion.crossfade : Tokens.motion.materializeResponse
    damping: Tokens.reduceMotion ? 1 : Tokens.motion.materializeDamping

    settlesGlass: true

    readonly property real progress: Motion.clamp01(value)
    readonly property bool active: shown || moving
    function scaleFor(dim) { return Motion.materializeScale(dim, value, Tokens.reduceMotion); }
}
