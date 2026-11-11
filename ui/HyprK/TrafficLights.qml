import QtQuick
import QtQuick.Shapes

// Close / minimize / zoom, macOS 27.2.1 (MAC-ANSWERS.md Q-windows-07..10, 19; windows/lights-*.png): 14 pt discs
// 9 pt apart, a three-stop fill in a 0.5 pt ring, a 1 pt glow outside light discs. Glyphs fade in 0.07 s after the
// pointer enters the group; a pressed button grows to 1.15x, brighter, with a stronger glow, and
// acts on release inside it. An inactive window shows pale grey discs, back in colour while
// the group is hovered. Used by Settings and Finder; the plugin title bar draws the same (Tokens.lights).
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
            // {fill: [top, centre, bottom], ring: [5 stops], glyph, glow} (Tokens.lights)
            readonly property var c: !lit ? Tokens.lights.inactive : down ? Tokens.lights[modelData.k].press : Tokens.lights[modelData.k]
            readonly property bool enabled_: modelData.k !== "zoom" || tl.zoomEnabled
            readonly property bool lit: enabled_ && (tl.active || hover.hovered)
            readonly property bool down: ma.pressed && ma.containsMouse
            width: Tokens.lights.size; height: width

            Item {
                anchors.fill: parent
                scale: light.down ? Tokens.lights.pressedScale : 1
                Rectangle { // 1 pt halo
                    anchors.fill: parent
                    anchors.margins: -1
                    radius: width / 2
                    color: light.c.glow
                    visible: color.a > 0
                }
                Rectangle { // ring
                    anchors.fill: parent
                    radius: width / 2
                    gradient: Gradient {
                        GradientStop { position: 0; color: light.c.ring[0] }
                        GradientStop { position: 0.2; color: light.c.ring[1] }
                        GradientStop { position: 0.5; color: light.c.ring[2] }
                        GradientStop { position: 0.8; color: light.c.ring[3] }
                        GradientStop { position: 1; color: light.c.ring[4] }
                    }
                }
                Rectangle { // fill
                    anchors.fill: parent
                    anchors.margins: Tokens.lights.rimWidth
                    radius: width / 2
                    gradient: Gradient {
                        GradientStop { position: 0; color: light.c.fill[0] }
                        GradientStop { position: 0.5; color: light.c.fill[1] }
                        GradientStop { position: 1; color: light.c.fill[2] }
                    }
                }
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
                        strokeWidth: glyph.filled ? -1 : Tokens.lights.glyphStroke
                        capStyle: ShapePath.RoundCap
                        PathSvg {
                            path: ({
                                close: "M 4.45 4.45 L 9.55 9.55 M 9.55 4.45 L 4.45 9.55",
                                minimize: "M 4.2 7 L 9.8 7",
                                plus: "M 3.95 7 L 10.05 7 M 7 3.95 L 7 10.05",
                                full: "M 4 4 L 8.9 4 L 4 8.9 Z M 10 10 L 5.1 10 L 10 5.1 Z"
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
