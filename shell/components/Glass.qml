import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs
import qs.services

// Frosted glass material: the pre-blurred wallpaper sampled at this item's
// screen position, a tint, a 1px inner rim highlight, a hairline and a drop
// shadow. With Theme.solidMaterial (Reduce transparency or no blur) it is an
// opaque tinted surface. With the liquidglass compositor plugin
// (Theme.compositorGlass) it draws nothing itself: its shape is registered with
// the enclosing ShellWindow and the plugin renders the material.
Item {
    id: root

    property real radius: 20
    // screen-space position of this item's top-left corner
    property real sx: 0
    property real sy: 0
    property color tint: Theme.glass.tint
    property color solidColor: Theme.glass.solid
    property bool shadow: true
    // the Dock label's pointer marker: a 1x1 hole at (left + 1, top) that the plugin turns into Apple's pointer shape
    // (plugin/README.md "Dock label pointer"); the materialize and shadow holes are left out, the plugin reads neither
    property bool pointer: false
    // tint drawn on top of the plugin's glass (the plugin owns blur, rim, shadow)
    // default: none, the plugin's recipes carry Apple's probe values themselves (a dark-mode veil made dark menus
    // read 62 over white instead of the Mac's 120)
    property color pluginLift: "transparent"
    // optional 1px rim drawn over plugin glass (the plugin's own rim is subtle)
    property color pluginRim: "transparent"
    // Liquid Glass materialize progress (ShellWindow.glassMaterialize). The QML fallback fades.
    property real materialize: registeredWith ? registeredWith.glassMaterialize : 1

    // The shape is placed by placeHole() from this item's window position, rounded to whole points like the
    // compositor region: Region { item } truncated the origin and rounded the size up, so a glass inside a panel
    // scaled by 1.01 sat 1 pt off until the scale was exactly 1 and then snapped (Control Center open: a 3.5 % rim
    // pop at ~470 ms, mcap). It follows this item's own geometry like Region { item } did, and moving parents through
    // glassMoved() (ShellWindow.settleGlass).
    readonly property bool on: root.visible && Theme.compositorGlass
    Region {
        id: shape
        radius: root.radius
        // materialize < 1: a 1 px hole in the middle row, x = left + 1 + round(m (w - 3))
        Region { id: hole; intersection: Intersection.Subtract; width: 0; height: 1 }
        // shadow: false: a 1x1 hole one row below the middle row, centre column; the plugin then gives this shape
        // _Glass.regular's drop shadow for its size instead of the layer recipe's (plugin 53efda0)
        Region { id: shadowHole; intersection: Intersection.Subtract; width: 0; height: 1 }
        Region { id: pointerHole; intersection: Intersection.Subtract; width: 0; height: 1 }
    }
    function remeasure() { placeHole(); }
    // the shape and its marker holes from one rounded rect: corners rounded to whole points
    function placeHole() {
        const q = root.mapToItem(null, 0, 0), e = root.mapToItem(null, root.width, root.height);
        const px = Math.round(q.x), py = Math.round(q.y);
        const w = root.on ? Math.round(e.x) - px : 0, h = root.on ? Math.round(e.y) - py : 0;
        shape.x = px;
        shape.y = py;
        shape.width = Math.max(0, w);
        shape.height = Math.max(0, h);
        shadowHole.x = px + Math.floor(w / 2);
        shadowHole.y = py + Math.floor(h / 2) + 1;
        shadowHole.width = (!root.shadow && !root.pointer && root.on && w >= 4 && h >= 3) ? 1 : 0;
        pointerHole.x = px + 1;
        pointerHole.y = py;
        pointerHole.width = (root.pointer && root.on && w >= 3) ? 1 : 0;
        if (materialize >= 1 || root.pointer || !root.on || w < 4 || h < 2) {
            hole.width = 0;
            return;
        }
        hole.x = px + 1 + Math.round(Math.max(0, materialize) * (w - 3));
        hole.y = py + Math.floor(h / 2);
        hole.width = 1;
    }
    // a materializing glass also changes scale (ControlCenter Module): re-measure, not just the hole
    onMaterializeChanged: if (Theme.compositorGlass) remeasure()
    onOnChanged: placeHole()
    onXChanged: placeHole()
    onYChanged: placeHole()
    onShadowChanged: placeHole()
    onPointerChanged: placeHole()
    onWidthChanged: placeHole()
    onHeightChanged: placeHole()
    // re-measure every frame for a while (call when this glass starts to move or scale)
    function settle() { if (registeredWith) registeredWith.settleGlass(); }
    Connections {
        target: root.registeredWith
        function onGlassMoved() { root.remeasure(); }
    }
    // QsWindow.window is only set once the item is in a window, so follow it. `host`: register with another ShellWindow
    // of the same geometry instead (a different glass material for this shape, e.g. Notification Center buttons)
    property var host: null
    readonly property var hostWindow: host || QsWindow.window
    property var registeredWith: null
    function register(w) {
        if (registeredWith && registeredWith.unregisterGlass) registeredWith.unregisterGlass(shape);
        registeredWith = w && w.registerGlass ? w : null;
        if (registeredWith) registeredWith.registerGlass(shape);
        // the shape's first commit must already carry its materialize hole: without one the plugin
        // takes materialize = 1, so a surface created on open (Launchpad) showed one frame of
        // full, empty glass before it started to materialize
        placeHole();
    }
    onHostWindowChanged: register(hostWindow)
    Component.onCompleted: register(hostWindow)
    Component.onDestruction: register(null)

    Rectangle {
        anchors.fill: parent
        visible: Theme.compositorGlass && (root.pluginLift.a > 0 || root.pluginRim.a > 0)
        opacity: root.materialize   // the tint comes in with the glass (opacity clamps to 0..1)
        radius: root.radius
        color: root.pluginLift
        border.width: root.pluginRim.a > 0 ? 1 : 0
        border.color: root.pluginRim
    }

    Item {
        anchors.fill: parent
        visible: !Theme.compositorGlass
        opacity: Math.max(0, root.materialize)

        RectangularShadow {
            visible: root.shadow
            anchors.fill: parent
            radius: root.radius
            blur: Theme.glass.shadowRadius
            offset.y: Theme.glass.shadowYOffset
            color: Theme.glass.shadow
        }

        ClippingRectangle {
            anchors.fill: parent
            radius: root.radius
            color: "transparent"

            Image {
                visible: !Theme.solidMaterial
                x: -root.sx
                y: -root.sy
                width: Wallpaper.width
                height: Wallpaper.height
                // only load the backdrop when this material is the one shown
                source: !Theme.compositorGlass && !Theme.solidMaterial && Wallpaper.blurred ? "file://" + Wallpaper.blurred : ""
                sourceSize: Qt.size(Wallpaper.width, Wallpaper.height)
                cache: true
                asynchronous: true
                retainWhileLoading: true         // no transparent flash when the wallpaper changes
                smooth: false
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.solidMaterial ? root.solidColor : root.tint
            }
        }

        // inner rim: 1px border, brighter along the top like the lit edge of glass
        Rectangle {
            anchors.fill: parent
            radius: root.radius
            color: "transparent"
            border.width: Theme.glass.rimWidth
            border.color: Theme.glass.rimBottom
        }
        // brighter top border in two clipped steps (full, then half) so it fades
        // down the sides without an offscreen gradient mask
        Repeater {
            model: [{ h: 1.0, o: 1.0 }, { h: 2.0, o: 0.5 }]
            Item {
                required property var modelData
                width: root.width
                height: Math.min(root.height, root.radius * modelData.h)
                clip: true
                opacity: modelData.o
                Rectangle {
                    width: parent.width
                    height: root.height
                    radius: root.radius
                    color: "transparent"
                    border.width: Theme.glass.rimWidth
                    border.color: Theme.glass.rimTop
                }
            }
        }

        // outer hairline that separates the material from bright backgrounds
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: root.radius + 1
            color: "transparent"
            border.width: 1
            border.color: Theme.glass.hairline
        }
    }
}
