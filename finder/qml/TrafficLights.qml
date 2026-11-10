import QtQuick

// Close / minimize / zoom, macOS 27 (SPEC "13. Traffic lights"): 14 pt discs 9 pt apart,
// top-to-bottom gradient, 0.75 pt rim. Hovering the group reveals all three glyphs;
// a press darkens only that button at once and acts on release inside it. An inactive
// window shows pale grey discs, back in colour while the group is hovered.
// Same constants and drawing as settings/controls/TrafficLights.qml and the plugin title bar
// (zoom maximizes here, so only the + glyph; the glyph fade is a 300 ms ease, not the spring).
Row {
    id: root

    required property var window
    property bool active: true
    spacing: Theme.lights.spacing

    HoverHandler { id: hover }

    Repeater {
        model: [
            { k: "close", act: () => root.window.close() },
            { k: "minimize", act: () => root.window.showMinimized() },
            { k: "zoom", act: () => root.window.visibility === Window.Maximized ? root.window.showNormal() : root.window.showMaximized() }
        ]

        Item {
            id: light
            required property var modelData
            readonly property var c: Theme.lights[modelData.k + "Set"]   // [top, bottom, pressed, glyph]
            readonly property bool lit: root.active || hover.hovered
            readonly property bool down: ma.pressed && ma.containsMouse
            width: Theme.lights.size
            height: width

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: light.down ? light.c[2] : light.lit ? light.c[0] : Theme.lights.inactive[0] }
                    GradientStop { position: 1; color: light.down ? light.c[2] : light.lit ? light.c[1] : Theme.lights.inactive[1] }
                }
            }
            Rectangle { // rim over the fill (a Rectangle's own border would replace the fill under it)
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: Theme.lights.rimWidth
                border.color: light.lit ? Theme.lights.rim : Theme.lights.inactiveRim
            }
            Canvas {
                anchors.fill: parent
                opacity: light.lit && hover.hovered ? 1 : 0   // not `visible`: a hidden Canvas may skip its paint
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }  // ~spring(0.3, 1)
                readonly property color ink: light.c[3]
                onInkChanged: requestPaint()
                onPaint: {
                    // 14 pt artboard, scaled to the disc
                    const g = getContext("2d"), s = width / 14, k = light.modelData.k;
                    g.reset(); g.scale(s, s);
                    g.strokeStyle = ink; g.lineCap = "round"; g.lineWidth = 1.2;
                    g.beginPath();
                    if (k === "close") { g.moveTo(4.6, 4.6); g.lineTo(9.4, 9.4); g.moveTo(9.4, 4.6); g.lineTo(4.6, 9.4); }
                    else if (k === "minimize") { g.moveTo(3.8, 7); g.lineTo(10.2, 7); }
                    else { g.moveTo(3.8, 7); g.lineTo(10.2, 7); g.moveTo(7, 3.8); g.lineTo(7, 10.2); }   // zoom (+): maximizes
                    g.stroke();
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                onClicked: light.modelData.act()
            }
        }
    }
}
