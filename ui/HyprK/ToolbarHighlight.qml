import QtQuick
import "motion.js" as Motion

// Hover and press light of the buttons on a glass capsule (window toolbars, the Liquid Glass preview). Hover (macOS 27.2.1
// read off the 23.09.23 recording, Tokens.toolbar.hover*, dark only): a disc round the button under the pointer, at once.
// Press: SwiftUI's FlexInteraction glow as its code draws it (motion.js glow*, GLASS-INTERACTION.md 4), light and dark:
// the BigGlow square and the LittleGlow blurred circle, both min(1.5 x the pressed button's shorter side, 160) pt, at the
// pointer on a critically damped 0.15 s spring (updateGlow 0x190c24650). While held: BigGlow opacity -> its preset on a
// 0.1 s spring; LittleGlow -> its preset (0.1 s), or half of it with the glow scaled x2 once the pointer is more than the
// dissipation distance from where the press began (0.5 s). Released: both fade to 0 while the glow grows to x4 (0.5 s).
// All springs damping 1. Put it above the capsule's buttons: it only watches the
// pointer (HoverHandler, PointHandler: the buttons keep their own clicks).
// With `source` (the capsule and its content, not containing this item) and `backdrop` it draws the light itself: a
// LensGlass that adds the light over `source` as drawn on `backdrop`, made only while something is lit. Without, bind a LensGlass's disc / glow to it.
// With `source` it also lifts the capsule (`source` and this light) as SwiftUI's FlexInteraction lifts a pressed glass
// button (motion.js pressScale / pressStretch through PressSpring, as GlassButton): each button is its own glass entry
// (GlassContainer.InteractionStorage per Entry.StableID), so the pressed one grows by its own size and only its outer
// end moves; the capsule's height grows with it; a drag while held stretches it (sub-point on a Mac-sized capsule).
// Nothing runs at rest (the spring sleeps; the transforms are identity).
Item {
    id: h
    property var centres: []           // the buttons' centres, x in this item; y = height / 2
    property Item source: null
    property color backdrop: "black"   // the opaque colour under the capsule (the window's), with `source`
    readonly property bool hovered: hover.hovered
    function nearest(x: real): real {
        let best = centres.length > 0 ? centres[0] : width / 2;
        for (const c of centres) if (Math.abs(c - x) < Math.abs(best - x)) best = c;
        return best;
    }
    property real pressX: width / 2
    property point pressAt: Qt.point(width / 2, height / 2)   // where the press began (item px)
    readonly property real hoverX: nearest(hover.point.position.x)
    readonly property point discCentre: Qt.point(hoverX, height / 2)
    readonly property real discLift: hovered ? Tokens.toolbar.hoverLift : 0
    readonly property point glowCentre: Qt.point(gx.value, gy.value)
    // the light's centre: the pressed button, then the pointer while held (it stays where it was after the release)
    property point _pointer: Qt.point(width / 2, height / 2)
    Spring { id: gx; target: h._pointer.x; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    Spring { id: gy; target: h._pointer.y; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    // the pressed button's glow (its own glass entry: _segW x height)
    readonly property var _glowSet: Motion.glowPreset(_segW, height)
    readonly property bool _far: press.active && Math.hypot(_pointer.x - pressAt.x, _pointer.y - pressAt.y) > _glowSet.dissipation
    readonly property real _glowFast: press.active && !_far ? Tokens.motion.pressGlowRise : Tokens.motion.pressGlowFarResponse
    Spring { id: bigOp; target: press.active ? h._glowSet.big : 0; damping: 1; epsilon: 0.002
             response: press.active ? Tokens.motion.pressGlowRise : Tokens.motion.pressGlowFarResponse }
    Spring { id: littleOp; target: press.active ? h._glowSet.little * (h._far ? 0.5 : 1) : 0; damping: 1; epsilon: 0.002
             response: h._glowFast }
    Spring { id: glowScale; target: press.active ? (h._far ? 2 : 1) : 4; damping: 1; epsilon: 0.01; response: h._glowFast }
    readonly property real glowHalf: Motion.glowSize(_segW, height) * glowScale.value / 2
    readonly property real glowBig: bigOp.value
    readonly property real glowLittle: littleOp.value
    readonly property real glowDodge: Motion.glowDodge(Tokens.dark)
    readonly property var glowLut: Motion.glowLut(1)
    readonly property bool lit: discLift > 0 || glowBig > 0.002 || glowLittle > 0.002

    // ---- the press lift (with `source`) ----
    property bool lifts: source !== null
    // the pressed button's span [from, to] in this item's x: halfway to its neighbours' centres, the capsule's ends outside
    readonly property var _span: {
        if (centres.length < 2) return [0, width];
        const xs = centres.slice().sort((a, b) => a - b);
        let i = 0;
        for (let k = 1; k < xs.length; k++) if (Math.abs(xs[k] - pressX) < Math.abs(xs[i] - pressX)) i = k;
        return [i === 0 ? 0 : (xs[i - 1] + xs[i]) / 2, i === xs.length - 1 ? width : (xs[i] + xs[i + 1]) / 2];
    }
    readonly property real _segW: _span[1] - _span[0]
    readonly property real _capH: height
    PressSpring { id: lift; pressed: press.active && h.lifts; w: _segW; h: _capH }
    readonly property var _st: press.active && lift.value > 0
        ? Motion.pressStretch(width, height, pressAt.x, pressAt.y, _pointer.x, _pointer.y) : [0, 0, 0, 0]
    // [x scale, y scale, x origin, x shift, y shift] of the capsule while pressed
    readonly property var liftGeometry: {
        const l = lift.scale - 1;
        const whole = _span[0] <= 0 && _span[1] >= width;
        const first = _span[0] <= 0, last = _span[1] >= width;
        return [(whole ? 1 + l : first || last ? 1 + _segW * l / 2 / Math.max(width, 1) : 1) + _st[0] * lift.value,
                1 + l + _st[1] * lift.value,
                whole ? width / 2 : first ? width : 0,
                _st[2] * lift.value, _st[3] * lift.value];
    }
    Scale { id: liftScale; origin.x: h.liftGeometry[2]; origin.y: h.height / 2; xScale: h.liftGeometry[0]; yScale: h.liftGeometry[1] }
    Translate { id: liftShift; x: h.liftGeometry[3]; y: h.liftGeometry[4] }
    transform: lifts ? [liftScale, liftShift] : []
    onSourceChanged: if (source && lifts && source.transform.length === 0) source.transform = [liftScale, liftShift];
    Component.onCompleted: if (source && lifts && source.transform.length === 0) source.transform = [liftScale, liftShift];

    HoverHandler { id: hover; enabled: Tokens.toolbar.hoverLift > 0 }
    PointHandler {
        id: press
        acceptedButtons: Qt.LeftButton
        onPointChanged: if (active) h._pointer = point.position
        onActiveChanged: if (active) {
            h.pressX = h.nearest(point.position.x);
            h.pressAt = point.position;
            h._pointer = point.position;
            gx.from(point.position.x);    // the glow sits at the gesture location from the first frame
            gy.from(point.position.y);
        }
    }
    Loader {
        active: h.source !== null && h.lit
        anchors.fill: parent
        sourceComponent: LensGlass {
            source: h.source
            origin: h.mapToItem(h.source, 0, 0)
            discCentre: h.discCentre
            discLift: h.discLift
            glowCentre: h.glowCentre
            glowHalf: h.glowHalf
            glowBig: h.glowBig
            glowLittle: h.glowLittle
            glowRadius: h.glowHalf
            glowDodge: h.glowDodge
            glowLut: h.glowLut
            additive: true
            backdrop: h.backdrop
        }
    }
}
