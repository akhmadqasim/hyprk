import QtQuick
import QtQuick.Shapes

// Close / minimize / zoom, macOS 27.2.1 (MAC-ANSWERS.md Q-windows-07..10, 19; windows/lights-*.png): 14 pt discs
// 9 pt apart, drawn as glass: a lit top, a darker belt, a caustic glow in the lower centre, a specular rim (dark: arcs
// at top and bottom; light: a dark rim on the sides) and in light a soft coloured shadow below. The disc is one
// ShaderEffect (shaders/lights.frag) fed from `glass`, the table plugin/tools/lights_model.py fits to the Mac crops;
// the plugin title bar (plugin/src/Titlebar.cpp) draws the same formula from the same table. Glyphs fade in 0.07 s
// after the pointer enters the group; a pressed button grows to 1.15x, brighter, and acts on release inside it. An
// inactive window shows grey discs, back in colour while the group is hovered. Used by Settings and Finder.
// (Before: a three-stop fill in a 0.5 pt ring with a flat halo, `anchors.margins: -1`; it read as a plain disc.)
Row {
    id: tl
    property bool active: true
    property bool zoomEnabled: true
    // Q-windows-19 (27.2.1 default): green = full screen (two-triangle glyph), Option-click = zoom
    // (the glyph turns into + while Option is held). Off: green zooms and shows +.
    property bool fullScreenButton: true
    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()
    signal fullScreenClicked()
    spacing: Tokens.lights.spacing

    // [rest, pressed, inactive][close, minimize, zoom]: T rgb, M rgb, B rgb, sg, rim axis, rim power, rim rgb, e0, e1,
    // glow rgb, g0 (sRGB bytes; lights_model.py has the model and the residuals against the crops)
    // generated: plugin/tools/lights_model.py emit (check: lights_model.py check)
    readonly property var glass: ({
        light: [
            [[237, 119, 106, 234, 121, 109, 233, 160, 152, 1.3, 1, 2.5, 167, 24, 10, 1, 0.2, 225, 26, 0, 0.14], [241, 186, 82, 244, 195, 79, 250, 224, 109, 1, 1, 2.5, 131, 59, 0, 1, 0.2, 229, 112, 0, 0.129], [121, 204, 67, 136, 207, 90, 190, 227, 162, 1.3, 1, 2, 43, 94, 18, 1, 0.25, 52, 154, 0, 0.13]],
            [[255, 157, 140, 255, 162, 146, 255, 207, 196, 1.3, 1, 3, 255, 85, 72, 1, 0.55, 222, 25, 0, 0.174], [255, 257, 111, 255, 253, 103, 255, 256, 143, 0.8, 1, 3, 247, 92, 0, 0.8, 0.16, 222, 116, 0, 0.197], [162, 255, 91, 183, 255, 121, 244, 255, 203, 2, 1, 3, 76, 178, 44, 1, 0.35, 52, 151, 0, 0.177]],
            [[248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0], [248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0], [248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0]],
        ],
        dark: [
            [[234, 121, 110, 226, 93, 78, 220, 124, 117, 0.6, 0, 2.5, 255, 197, 188, 1, 0.45, 0, 0, 0, 0], [239, 183, 86, 241, 184, -12, 249, 223, 145, 0.7, 0, 1.5, 255, 244, 114, 1, 0.6, 0, 0, 0, 0], [129, 200, 112, 78, 185, -6, 133, 197, 137, 0.6, 0, 1.5, 175, 255, 140, 1, 0.4, 0, 0, 0, 0]],
            [[255, 159, 143, 255, 126, 107, 255, 160, 148, 0.5, 0, 3, 255, 253, 244, 0.7, 0.67, 0, 0, 0, 0], [255, 245, 117, 255, 247, -7, 255, 277, 154, 0.7, 0, 1.5, 254, 250, 152, 0.8, 0.76, 0, 0, 0, 0], [156, 241, 135, 94, 223, -6, 155, 230, 160, 0.6, 0, 1.5, 175, 255, 140, 0.7, 0.67, 0, 0, 0, 0]],
            [[81, 82, 88, 78, 79, 85, 67, 68, 74, 1.3, 0, 3, 243, 243, 240, 0.6, 0.24, 0, 0, 0, 0], [81, 82, 88, 78, 79, 85, 67, 68, 74, 1.3, 0, 3, 243, 243, 240, 0.6, 0.24, 0, 0, 0, 0], [81, 82, 88, 78, 79, 85, 67, 68, 74, 1.3, 0, 3, 243, 243, 240, 0.6, 0.24, 0, 0, 0, 0]],
        ],
    })
    readonly property int glassMargin: 5   // whole pt around the disc (glow, pressed disc); a half pt would shift it

    HoverHandler { id: hover }
    // hovered only while Option (Alt) is held; it updates with the next pointer event
    HoverHandler { id: optionHover; acceptedModifiers: Qt.AltModifier }
    // Glyphs: shown 0.07 s after entering (Q-windows-10), hidden at once on exit; nothing runs at rest.
    property bool _glyphs: false
    Timer { id: glyphDelay; interval: Tokens.reduceMotion ? 0 : Tokens.lights.glyphDelay; onTriggered: tl._glyphs = true }
    Connections {
        target: hover
        function onHoveredChanged() {
            if (hover.hovered) glyphDelay.restart();
            else { glyphDelay.stop(); tl._glyphs = false; }
        }
    }

    Repeater {
        model: [
            { k: "close", s: "closeClicked" },
            { k: "minimize", s: "minimizeClicked" },
            { k: "zoom", s: "zoomClicked" }
        ]
        Item {
            id: light
            required property var modelData
            required property int index
            // {fill: [top, centre, bottom], ring: [5 stops], glyph, glow} (Tokens.lights)
            readonly property var c: !lit ? Tokens.lights.inactive : down ? Tokens.lights[modelData.k].press : Tokens.lights[modelData.k]
            readonly property bool enabled_: modelData.k !== "zoom" || tl.zoomEnabled
            readonly property bool lit: enabled_ && (tl.active || hover.hovered)
            readonly property bool down: ma.pressed && ma.containsMouse
            width: Tokens.lights.size; height: width

            ShaderEffect {
                readonly property var g: tl.glass[Tokens.dark ? "dark" : "light"][!light.lit ? 2 : light.down ? 1 : 0][index]
                anchors.centerIn: parent
                width: parent.width + 2 * tl.glassMargin; height: width
                fragmentShader: Qt.resolvedUrl("shaders/lights.frag.qsb")
                property size size: Qt.size(width, height)
                property real radius: Tokens.lights.size / 2 * (light.down ? Tokens.lights.pressedScale : 1)
                property real ppt: Screen.devicePixelRatio
                property vector4d colT: Qt.vector4d(g[0] / 255, g[1] / 255, g[2] / 255, 1)
                property vector4d colM: Qt.vector4d(g[3] / 255, g[4] / 255, g[5] / 255, 1)
                property vector4d colB: Qt.vector4d(g[6] / 255, g[7] / 255, g[8] / 255, g[9])
                property vector4d rim: Qt.vector4d(g[12] / 255, g[13] / 255, g[14] / 255, g[11])
                property vector4d rimE: Qt.vector4d(g[15], g[16], g[10], 0)
                property vector4d glow: Qt.vector4d(g[17] / 255, g[18] / 255, g[19] / 255, g[20])
            }
            Item {
                anchors.fill: parent
                scale: light.down ? Tokens.lights.pressedScale : 1
                // Glyph on a 14 pt artboard, vector so the ink stays solid at 2x (hover centre 159,0,0 on the Mac).
                // Round caps add half the stroke at each end, so the centre lines are the Q-windows-10 ink sizes minus
                // one stroke. Full screen: two triangles making a 6 x 6 square split along the rising diagonal
                // (lights-hover-light.png: 12 x 12 px at 2x, gap about 4 px across).
                Shape {
                    id: glyph
                    width: 14; height: 14
                    scale: parent.width / 14
                    transformOrigin: Item.TopLeft
                    preferredRendererType: Shape.CurveRenderer
                    opacity: light.lit && tl._glyphs ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        enabled: !Tokens.reduceMotion
                        NumberAnimation {
                            duration: tl._glyphs ? Tokens.lights.glyphIn : Tokens.lights.glyphOut
                            easing.type: tl._glyphs ? Easing.OutCubic : Easing.OutQuad
                        }
                    }
                    readonly property string kind: light.modelData.k !== "zoom" ? light.modelData.k
                                                  : tl.fullScreenButton && !optionHover.hovered ? "full" : "plus"
                    readonly property bool filled: kind === "full"
                    ShapePath {
                        strokeColor: glyph.filled ? "transparent" : light.c.glyph
                        fillColor: glyph.filled ? light.c.glyph : "transparent"
                        // fitted on lights-hover-{dark,light}.png over the disc model (plugin/tools/lights_model.py): the x
                        // reads 2.05 pt, the minus 2.0 x 7.9 pt, the triangles a 5.8 pt box (rms 9.6 -> 5.7, 7.9 -> 7.7,
                        // 10.0 -> 8.9 dark); + has no crop without Option and keeps the token
                        strokeWidth: glyph.filled ? -1 : glyph.kind === "close" ? 2.05 : glyph.kind === "minimize" ? 2.0 : Tokens.lights.glyphStroke
                        capStyle: ShapePath.RoundCap
                        PathSvg {
                            path: ({
                                close: "M 4.45 4.45 L 9.55 9.55 M 9.55 4.45 L 4.45 9.55",
                                minimize: "M 4.05 7 L 9.95 7",
                                plus: "M 3.95 7 L 10.05 7 M 7 3.95 L 7 10.05",
                                full: "M 4.1 4.1 L 8.9 4.1 L 4.1 8.9 Z M 9.9 9.9 L 5.1 9.9 L 9.9 5.1 Z"
                            })[glyph.kind]
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
