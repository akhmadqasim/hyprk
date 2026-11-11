import QtQuick

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

    PressGlow { id: glow; pressed: press.active && Tokens.toolbar.pressGain > 0 }
    HoverHandler { id: hover; enabled: Tokens.toolbar.hoverLift > 0 }
    PointHandler {
        id: press
        acceptedButtons: Qt.LeftButton
        enabled: Tokens.toolbar.pressGain > 0
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
