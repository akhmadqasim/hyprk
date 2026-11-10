import QtQuick

// Close / minimize / zoom, macOS 27 (SPEC "13. Traffic lights"): 14 pt discs 9 pt apart,
// top-to-bottom gradient, 0.75 pt rim. Hovering the group reveals all three glyphs
// (spring 0.3); a press darkens only that button at once and acts on release inside it.
// An inactive window shows pale grey discs, back in colour while the group is hovered.
// Used by Settings and Finder; the plugin title bar draws the same (Tokens.lights).
Row {
    id: tl
    property bool active: true
    property bool zoomEnabled: true
    property bool fullScreenGlyph: false    // zoom = full screen (arrows) instead of zoom (+)
    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()
    spacing: Tokens.lights.spacing

    HoverHandler { id: hover }
    Spring { id: reveal; target: hover.hovered ? 1 : 0; response: Tokens.lights.glyphResponse; epsilon: 0.001; instant: Tokens.reduceMotion }

    Repeater {
        model: [
            { k: "close", s: "closeClicked" },
            { k: "minimize", s: "minimizeClicked" },
            { k: "zoom", s: "zoomClicked" }
        ]
        Item {
            id: light
            required property var modelData
            readonly property var c: Tokens.lights[modelData.k + "Set"]   // [top, bottom, pressed, glyph]
            readonly property bool enabled_: modelData.k !== "zoom" || tl.zoomEnabled
            readonly property bool lit: enabled_ && (tl.active || hover.hovered)
            readonly property bool down: ma.pressed && ma.containsMouse
            width: Tokens.lights.size; height: width

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: light.down ? light.c[2] : light.lit ? light.c[0] : Tokens.lights.inactive[0] }
                    GradientStop { position: 1; color: light.down ? light.c[2] : light.lit ? light.c[1] : Tokens.lights.inactive[1] }
                }
            }
            Rectangle { // rim over the fill (a Rectangle's own border would replace the fill under it)
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: Tokens.lights.rimWidth
                border.color: light.lit ? Tokens.lights.rim : Tokens.lights.inactiveRim
            }
            Canvas {
                id: glyph
                anchors.fill: parent
                opacity: light.lit ? reveal.value : 0   // not `visible`: a hidden Canvas may skip its paint
                readonly property color ink: light.c[3]
                onInkChanged: requestPaint()
                property string kind: light.modelData.k === "zoom" ? (tl.fullScreenGlyph ? "full" : "plus") : light.modelData.k
                onKindChanged: requestPaint()
                onPaint: {
                    // 14 pt artboard, scaled to the disc
                    const g = getContext("2d"), s = width / 14;
                    g.reset(); g.scale(s, s);
                    g.strokeStyle = ink; g.fillStyle = ink; g.lineCap = "round"; g.lineWidth = 1.2;
                    g.beginPath();
                    if (kind === "close") { g.moveTo(4.6, 4.6); g.lineTo(9.4, 9.4); g.moveTo(9.4, 4.6); g.lineTo(4.6, 9.4); g.stroke(); }
                    else if (kind === "minimize") { g.moveTo(3.8, 7); g.lineTo(10.2, 7); g.stroke(); }
                    else if (kind === "plus") { g.moveTo(3.8, 7); g.lineTo(10.2, 7); g.moveTo(7, 3.8); g.lineTo(7, 10.2); g.stroke(); }
                    else { // full screen: two corner triangles
                        g.moveTo(4.2, 4.2); g.lineTo(8.6, 4.2); g.lineTo(4.2, 8.6); g.closePath();
                        g.moveTo(9.8, 9.8); g.lineTo(5.4, 9.8); g.lineTo(9.8, 5.4); g.closePath(); g.fill();
                    }
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                enabled: light.enabled_
                onClicked: tl[light.modelData.s]()
            }
        }
    }
}
