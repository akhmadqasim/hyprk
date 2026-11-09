import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs
import qs.services

// Frosted glass material: the pre-blurred wallpaper sampled at this item's
// screen position, a tint, a 1px inner rim highlight and a drop shadow.
// With Theme.solidMaterial (Reduce transparency or no blur) it becomes an
// opaque tinted surface instead.
Item {
    id: root

    property real radius: 20
    // screen-space position of this item's top-left corner
    property real sx: 0
    property real sy: 0
    property color tint: Theme.glass.tint
    property color solidColor: Theme.glass.solid
    property bool shadow: true
    // QML material only without the compositor plugin; with it the plugin
    // draws tint, rim and shadow from this item's shape (see ShellWindow)
    readonly property bool qmlMaterial: !Theme.compositorGlass

    // shape for the plugin, registered with the enclosing ShellWindow
    Region {
        id: shape
        item: root.visible && Theme.compositorGlass ? root : null
        radius: root.radius
    }
    Component.onCompleted: {
        const w = QsWindow.window;
        if (w && w.glassRegions !== undefined) w.glassRegions.push(shape);
    }
    Component.onDestruction: {
        const w = QsWindow.window;
        if (!w || w.glassRegions === undefined) return;
        const rest = [];
        for (let i = 0; i < w.glassRegions.length; i++)
            if (w.glassRegions[i] !== shape) rest.push(w.glassRegions[i]);
        w.glassRegions = rest;
    }

    RectangularShadow {
        visible: root.shadow && root.qmlMaterial
        anchors.fill: clip
        radius: root.radius
        blur: Theme.glass.shadowRadius
        offset.y: Theme.glass.shadowYOffset
        color: Theme.glass.shadow
    }

    ClippingRectangle {
        id: clip
        visible: root.qmlMaterial
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
        visible: root.qmlMaterial
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: Theme.glass.rimWidth
        border.color: Theme.glass.rimBottom
    }
    // brighter top border in two clipped steps (full, then half) so it fades
    // down the sides without an offscreen gradient mask
    Repeater {
        model: root.qmlMaterial ? [{ h: 1.0, o: 1.0 }, { h: 2.0, o: 0.5 }] : []
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
        visible: root.qmlMaterial
        anchors.fill: parent
        anchors.margins: -1
        radius: root.radius + 1
        color: "transparent"
        border.width: 1
        border.color: Theme.glass.hairline
    }
}
