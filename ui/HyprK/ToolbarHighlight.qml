import QtQuick
import "motion.js" as Motion

// Hover and press light of the buttons on a glass capsule (window toolbars, the Liquid Glass preview). Hover (macOS 27.2.1
// read off the 23.09.23 recording, Tokens.toolbar.hover*, dark only): a disc round the button under the pointer, at once.
// Press: SwiftUI's FlexInteraction glow as its code draws it (motion.js glow*, GLASS-INTERACTION.md 4), light and dark:
// the BigGlow over the whole glass (the code's square layer, whose edge the Mac does not show: INTERACTIVE-GLASS-REA.md 1)
// and the LittleGlow blurred circle, min(1.5 x the pressed entry's shorter side, 160) pt, at the pointer on a critically damped 0.15 s spring (updateGlow 0x190c24650). While held: BigGlow opacity -> its preset on a
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
// `platter` (default: with a `source`): an AppKit toolbar item-group platter (Settings back / forward, Finder's
// capsules): ONE interactive NSGlassEffectView over the whole capsule (-[NSToolbarPlatterView initWithFrame:]
// 0x18af2584c, variant .automatic), so the whole capsule is one FlexInteraction entry: the press lifts it about its
// centre by its own size and the glow is sized by it. Measured (R7.1, controls/hold-shine-{settings,finder}-*.mov,
// pressed frames before the history menu opens): rims -3 / +3 px left / right, -1 / +1..2 px top / bottom (+3 x
// +1.5 pt; decoded ultraSmall lift on 74 x 36: +2.5 x +1.2 pt), the light a falloff from the pointer over the whole
// capsule (dark), the face to 255 (light). TOOLBAR-REA-27.2.1.md 2 read "no lift, an even 0.1 layer" off a still whose
// history menu was already open (settings/toolbar-backforward-rest-hover-press-dark.png: the menu at the bottom of the
// third panel; the clips show the lift ending and the capsule lit evenly once the menu opens). Ours opens no history
// menu, so that state is not drawn (LensGlass.platterPress stays 0). Without `platter` (the Appearance preview's
// SwiftUI glass buttons, merged in one capsule) each button is its own entry.
Item {
    id: h
    property var centres: []           // the buttons' centres, x in this item; y = height / 2
    // per centre, true for a disabled button: it gets neither the hover disc nor the press light, as on the Mac
    // (MAC-ANSWERS Q-finder-10 "Disabled: no hover"; judge-95-16 `09` held a disabled Forward: the capsule lit and the
    // divider stayed)
    property var disabled: []
    function off(x: real): bool {
        let best = -1;
        for (let i = 0; i < centres.length; i++) if (best < 0 || Math.abs(centres[i] - x) < Math.abs(centres[best] - x)) best = i;
        return best >= 0 && !!disabled[best];
    }
    property Item source: null
    property color backdrop: "black"   // the opaque colour under the capsule (the window's), with `source`
    readonly property bool hovered: hover.hovered && !off(hover.point.position.x)
    readonly property bool pressed: press.active && !off(pressX)
    property bool platter: source !== null
    function nearest(x: real): real {
        let best = centres.length > 0 ? centres[0] : width / 2;
        for (const c of centres) if (Math.abs(c - x) < Math.abs(best - x)) best = c;
        return best;
    }
    property real pressX: width / 2
    property point pressAt: Qt.point(width / 2, height / 2)   // where the press began (item px)
    readonly property real hoverX: nearest(hover.point.position.x)
    readonly property point discCentre: Qt.point(hoverX, height / 2)
    // the disc's value while hovered (and held): Tokens.toolbar.hoverLift (AppKit platters, dark only), or a SwiftUI glass
    // button's interaction fill (Tokens.toolbar.glassButtonFill, < 0 darkens: LensGlass disc)
    property real hoverFill: Tokens.toolbar.hoverLift
    readonly property real discLift: hovered ? hoverFill : 0
    readonly property point glowCentre: Qt.point(gx.value, gy.value)
    // the light's centre: the pressed button, then the pointer while held (it stays where it was after the release)
    property point _pointer: Qt.point(width / 2, height / 2)
    Spring { id: gx; target: h._pointer.x; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    Spring { id: gy; target: h._pointer.y; response: Tokens.motion.pressGlowFollow; damping: 1; epsilon: 0.05 }
    // the pressed button's glow (its own glass entry: _segW x height)
    // >= 0: the pressed entry's LittleGlow opacity, instead of its size preset's (a measured glass)
    property real littleOpacity: -1
    readonly property var _preset: Motion.glowPreset(_segW, height)
    readonly property var glowSet: littleOpacity >= 0 ? { big: _preset.big, little: littleOpacity, dissipation: _preset.dissipation } : _preset
    readonly property bool _far: press.active && Math.hypot(_pointer.x - pressAt.x, _pointer.y - pressAt.y) > glowSet.dissipation
    readonly property real _glowFast: press.active && !_far ? Tokens.motion.pressGlowRise : Tokens.motion.pressGlowFarResponse
    Spring { id: bigOp; target: h.pressed ? h.glowSet.big : 0; damping: 1; epsilon: 0.002
             response: press.active ? Tokens.motion.pressGlowRise : Tokens.motion.pressGlowFarResponse }
    Spring { id: littleOp; target: h.pressed ? h.glowSet.little * (h._far ? 0.5 : 1) : 0; damping: 1; epsilon: 0.002
             response: h._glowFast }
    Spring { id: glowScale; target: press.active ? (h._far ? 2 : 1) : 4; damping: 1; epsilon: 0.01; response: h._glowFast }
    readonly property real glowHalf: Motion.glowSize(_segW, height) * glowScale.value / 2
    readonly property real glowBig: bigOp.value
    readonly property real glowLittle: littleOp.value
    readonly property real glowDodge: Motion.glowDodge(Tokens.dark)
    readonly property var glowLut: Motion.glowLut()
    readonly property real glowRadius: Motion.glowLutRadius(glowHalf)
    readonly property bool lit: discLift !== 0 || glowBig > 0.002 || glowLittle > 0.002

    // ---- the press lift (with `source`) ----
    property bool lifts: source !== null
    // the pressed button's span [from, to] in this item's x: halfway to its neighbours' centres, the capsule's ends
    // outside; a platter is one entry, the whole capsule
    readonly property var _span: {
        if (centres.length < 2 || platter) return [0, width];
        const xs = centres.slice().sort((a, b) => a - b);
        let i = 0;
        for (let k = 1; k < xs.length; k++) if (Math.abs(xs[k] - pressX) < Math.abs(xs[i] - pressX)) i = k;
        return [i === 0 ? 0 : (xs[i - 1] + xs[i]) / 2, i === xs.length - 1 ? width : (xs[i] + xs[i + 1]) / 2];
    }
    readonly property real _segW: _span[1] - _span[0]
    readonly property real _capH: height
    PressSpring { id: lift; pressed: h.pressed && h.lifts; w: _segW; h: _capH }   // a disabled half: no lift
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

    HoverHandler { id: hover; enabled: h.hoverFill !== 0 }
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
            glowRadius: h.glowRadius
            glowDodge: h.glowDodge
            glowLut: h.glowLut
            additive: true
            backdrop: h.backdrop
        }
    }
}
