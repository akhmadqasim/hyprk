import QtQuick
import QtQuick.Shapes
import "panels.js" as P

// NSPopover as on macOS 27.2.1 (LIVE-27.2.1.md, MAC-ANSWERS.md Q-windows-17, Q-finder-25): radius 20, a 9 pt
// arrow on the anchor's centre, content inset 13. Opens with a spring from 12.5 % (response 0.25 s, damping 0.9)
// growing out of the arrow tip; closes with a 0.128 s fade on CA's default curve, no scale (Tokens.panel). The live popover is regular glass; drawn
// flat with the menu fill. Fill the window with it and call openAt(anchorItem); children go into `body` at the
// inset, and bodyWidth / bodyHeight size it. Escape or a click outside closes it.
Item {
    id: root
    property real bodyWidth: 252
    property real bodyHeight: 99
    property bool shown: false
    property real inset: P.popover.inset      // content inset
    property real anchorGap: 0                // arrow tip to the anchor
    default property alias content: inner.data
    signal closed()

    property rect anchorRect: Qt.rect(0, 0, 0, 0)
    readonly property var place: P.popoverPlacement(anchorRect, bodyWidth, bodyHeight, width, height, anchorGap)

    function openAt(item) {
        const p = item.mapToItem(root, 0, 0);
        anchorRect = Qt.rect(p.x, p.y, item.width, item.height);
        fade.stop();
        body.opacity = 1;
        shown = true;
        if (Tokens.reduceMotion) grow.snap(); else grow.from(Tokens.panel.popoverFrom);
        forceActiveFocus();
    }
    function close() {
        if (!shown) return;
        shown = false;
        fade.restart();
        closed();
    }

    visible: shown || body.opacity > 0
    Keys.onEscapePressed: close()
    MouseArea { anchors.fill: parent; enabled: root.shown; acceptedButtons: Qt.AllButtons; onPressed: root.close() }

    Spring { id: grow; target: 1; response: Tokens.panel.popoverResponse; damping: Tokens.panel.popoverDamping; epsilon: 0.001 }
    FrameAnim { id: fade; target: body; property: "opacity"; to: 0; duration: Tokens.panel.popoverFadeOut; curve: Tokens.panel.popoverFadeCurve }

    Item {
        id: body
        opacity: 0
        x: root.place.x
        y: root.place.y
        width: root.bodyWidth
        height: root.bodyHeight
        transform: Scale {
            origin.x: root.place.arrowX
            origin.y: root.place.below ? -P.popover.arrow : root.bodyHeight + P.popover.arrow
            xScale: grow.value
            yScale: grow.value
        }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

        PanelShadow { anchors.fill: parent; cornerRadius: P.popover.radius }
        // body and arrow as one outline (drawn for an arrow on top; mirrored when the popover sits above)
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale { origin.y: root.bodyHeight / 2; yScale: root.place.below ? 1 : -1 }
            ShapePath {
                id: sp
                readonly property real r: P.popover.radius
                readonly property real w: root.bodyWidth
                readonly property real h: root.bodyHeight
                readonly property real ax: root.place.arrowX
                readonly property real aw: P.popover.arrowWidth / 2
                fillColor: Tokens.panel.popoverFill
                strokeColor: Tokens.panel.popoverRim
                strokeWidth: 0.5
                startX: sp.r; startY: 0
                PathLine { x: sp.ax - sp.aw; y: 0 }
                PathQuad { x: sp.ax; y: -P.popover.arrow; controlX: sp.ax - 2; controlY: -P.popover.arrow }
                PathQuad { x: sp.ax + sp.aw; y: 0; controlX: sp.ax + 2; controlY: -P.popover.arrow }
                PathLine { x: sp.w - sp.r; y: 0 }
                PathArc { x: sp.w; y: sp.r; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: sp.w; y: sp.h - sp.r }
                PathArc { x: sp.w - sp.r; y: sp.h; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: sp.r; y: sp.h }
                PathArc { x: 0; y: sp.h - sp.r; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: 0; y: sp.r }
                PathArc { x: sp.r; y: 0; radiusX: sp.r; radiusY: sp.r }
            }
            // glass rim light (PC #67 B, key at the top, fill at the bottom): a 1 pt bright band, then an 8 pt
            // diffuse band; drawn as a gradient over the same outline. Mirrored with the shape when the arrow points down.
            ShapePath {
                strokeWidth: -1
                fillGradient: LinearGradient {
                    x1: 0; y1: -P.popover.arrow; x2: 0; y2: sp.h
                    GradientStop { position: 0; color: Tokens.panel.popoverKey }
                    GradientStop { position: (P.popover.arrow + 1) / (sp.h + P.popover.arrow); color: Tokens.panel.popoverDiffuse }
                    GradientStop { position: (P.popover.arrow + 8) / (sp.h + P.popover.arrow); color: "transparent" }
                    GradientStop { position: 1 - 8 / (sp.h + P.popover.arrow); color: "transparent" }
                    GradientStop { position: 1; color: Tokens.panel.popoverDiffuse }
                }
                startX: sp.r; startY: 0
                PathLine { x: sp.ax - sp.aw; y: 0 }
                PathQuad { x: sp.ax; y: -P.popover.arrow; controlX: sp.ax - 2; controlY: -P.popover.arrow }
                PathQuad { x: sp.ax + sp.aw; y: 0; controlX: sp.ax + 2; controlY: -P.popover.arrow }
                PathLine { x: sp.w - sp.r; y: 0 }
                PathArc { x: sp.w; y: sp.r; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: sp.w; y: sp.h - sp.r }
                PathArc { x: sp.w - sp.r; y: sp.h; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: sp.r; y: sp.h }
                PathArc { x: 0; y: sp.h - sp.r; radiusX: sp.r; radiusY: sp.r }
                PathLine { x: 0; y: sp.r }
                PathArc { x: sp.r; y: 0; radiusX: sp.r; radiusY: sp.r }
            }
        }
        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: root.inset
        }
    }
}
