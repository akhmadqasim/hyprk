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
    // tint drawn on top of the plugin's glass (the plugin owns blur, rim, shadow)
    property color pluginLift: "transparent"

    Region {
        id: shape
        item: root.visible && Theme.compositorGlass ? root : null
        radius: root.radius
    }
    function remeasure() {
        shape.item = null;
        shape.item = Qt.binding(() => root.visible && Theme.compositorGlass ? root : null);
    }
    Connections {
        target: root.registeredWith
        function onGlassMoved() { root.remeasure(); }
    }
    // QsWindow.window is only set once the item is in a window, so follow it
    readonly property var hostWindow: QsWindow.window
    property var registeredWith: null
    function register(w) {
        if (registeredWith && registeredWith.unregisterGlass) registeredWith.unregisterGlass(shape);
        registeredWith = w && w.registerGlass ? w : null;
        if (registeredWith) registeredWith.registerGlass(shape);
    }
    onHostWindowChanged: register(hostWindow)
    Component.onCompleted: register(hostWindow)
    Component.onDestruction: register(null)

    Rectangle {
        anchors.fill: parent
        visible: Theme.compositorGlass
        radius: root.radius
        color: root.pluginLift
    }

    Item {
        anchors.fill: parent
        visible: !Theme.compositorGlass

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
                source: Wallpaper.blurred ? "file://" + Wallpaper.blurred : ""
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
