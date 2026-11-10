import QtQuick

// Close / minimize / zoom, macOS 27 (SPEC "13. Traffic lights"): 14 pt discs 9 pt apart,
// top-to-bottom gradient, 0.75 pt rim. Hovering the group reveals all three glyphs
// (spring 0.3); a pressed button grows to 1.15x with a brighter fill (MAC-ANSWERS.md Q-windows-08)
// and acts on release inside it. An inactive window shows pale grey discs, back in colour while
// the group is hovered. Used by Settings and Finder; the plugin title bar draws the same (Tokens.lights).
Row {
    id: tl
    property bool active: true
    property bool zoomEnabled: true
    // Q-windows-19 (27.2.1 default): green = full screen (two-triangle glyph), Option-click = zoom
    // (the glyph turns into + while Option is held). Off: green zooms and shows +.
    property bool fullScreenButton: false
    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()
    signal fullScreenClicked()
    spacing: Tokens.lights.spacing

    HoverHandler { id: hover }
    // hovered only while Option (Alt) is held; it updates with the next pointer event
    HoverHandler { id: optionHover; acceptedModifiers: Qt.AltModifier }
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

            Item {
                anchors.fill: parent
                scale: light.down ? Tokens.lights.pressedScale : 1
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
                    property string kind: light.modelData.k !== "zoom" ? light.modelData.k
                                        : tl.fullScreenButton && !optionHover.hovered ? "full" : "plus"
                    onKindChanged: requestPaint()
                    onPaint: {
                        // 14 pt artboard, scaled to the disc. Round caps add half the stroke at each end, so the
                        // centre lines are the Q-windows-10 ink sizes minus one stroke.
                        const g = getContext("2d"), s = width / 14;
                        g.reset(); g.scale(s, s);
                        g.strokeStyle = ink; g.fillStyle = ink; g.lineCap = "round"; g.lineWidth = Tokens.lights.glyphStroke;
                        g.beginPath();
                        if (kind === "close") { g.moveTo(4.45, 4.45); g.lineTo(9.55, 9.55); g.moveTo(9.55, 4.45); g.lineTo(4.45, 9.55); g.stroke(); }
                        else if (kind === "minimize") { g.moveTo(4.2, 7); g.lineTo(9.8, 7); g.stroke(); }
                        else if (kind === "plus") { g.moveTo(3.95, 7); g.lineTo(10.05, 7); g.moveTo(7, 3.95); g.lineTo(7, 10.05); g.stroke(); }
                        else { // full screen: two corner triangles, 6 x 6 pt together
                            g.moveTo(4, 4); g.lineTo(8.7, 4); g.lineTo(4, 8.7); g.closePath();
                            g.moveTo(10, 10); g.lineTo(5.3, 10); g.lineTo(10, 5.3); g.closePath(); g.fill();
                        }
                    }
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                enabled: light.enabled_
                onClicked: mouse => {
                    if (light.modelData.k === "zoom" && tl.fullScreenButton && !(mouse.modifiers & Qt.AltModifier))
                        tl.fullScreenClicked();
                    else
                        tl[light.modelData.s]();
                }
            }
        }
    }
}
