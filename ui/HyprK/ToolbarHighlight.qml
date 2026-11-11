import QtQuick
import "motion.js" as Motion

// Hover and press light of the buttons on a glass capsule (window toolbars, the Liquid Glass preview; macOS 27.2.1 read
// off the 23.09.23 recording, Tokens.toolbar.hover* / press*): hovering lights a disc round the button under the pointer
// at once; a press brightens the whole capsule, disc included, by a gain that is flat over the disc and falls off
// linearly beyond it, rising over 9 frames
// and falling for about 0.8 s after the release (PressGlow). While held the light follows the pointer as SwiftUI's
// FlexInteraction glow does (updateGlow 0x190c24650: the glow layer sits at the gesture location, on a critically
// damped spring of 0.15 s; more than 50 pt from where the press began it dims to half on a 0.5 s spring); the hover
// disc stays on the button. Put it above the capsule's buttons: it only watches the
// pointer (HoverHandler, PointHandler: the buttons keep their own clicks). Dark only (no light data).
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
    readonly property real glowGain: Tokens.toolbar.pressGain * glow.value * far.value
    // the light's centre: the pressed button, then the pointer while held (it stays where it was after the release)
    property point _pointer: Qt.point(width / 2, height / 2)
    Spring { id: gx; target: h._pointer.x; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    Spring { id: gy; target: h._pointer.y; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    Spring {   // 1 near where the press began, pressGlowFar beyond pressGlowDissipation pt
        id: far
        target: press.active && Math.hypot(h._pointer.x - h.pressAt.x, h._pointer.y - h.pressAt.y) > Tokens.motion.pressGlowDissipation
                ? Tokens.motion.pressGlowFar : 1
        initial: 1
        response: Tokens.motion.pressGlowFarResponse; damping: 1; epsilon: 0.005
    }
    readonly property bool lit: discLift > 0 || glowGain > 0

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

    PressGlow { id: glow; pressed: press.active && Tokens.toolbar.pressGain > 0 }
    HoverHandler { id: hover; enabled: Tokens.toolbar.hoverLift > 0 }
    PointHandler {
        id: press
        acceptedButtons: Qt.LeftButton
        enabled: Tokens.toolbar.pressGain > 0 || h.lifts
        onPointChanged: if (active) h._pointer = point.position
        onActiveChanged: if (active) {
            h.pressX = h.nearest(point.position.x);
            h.pressAt = point.position;
            h._pointer = point.position;
            gx.from(point.position.x);    // the glow sits at the gesture location from the first frame
            gy.from(point.position.y);
            far.snap();
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
            glowGain: h.glowGain
            additive: true
            backdrop: h.backdrop
        }
    }
}
