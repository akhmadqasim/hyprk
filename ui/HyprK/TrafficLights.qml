import QtQuick
import QtQuick.Shapes
import "motion.js" as Motion

// Close / minimize / zoom, macOS 27.2.1 (MAC-ANSWERS.md Q-windows-07..10, 19; windows/lights-*.png): 14 pt discs
// 9 pt apart, drawn as glass: a lit top, a darker belt, a caustic glow in the lower centre, a specular rim (dark: arcs
// at top and bottom; light: a dark rim on the sides) and in light a soft coloured shadow below. The disc is one
// ShaderEffect (shaders/lights.frag) fed from `glass`, the table plugin/tools/lights_model.py fits to the Mac crops;
// the plugin title bar (plugin/src/Titlebar.cpp) draws the same formula from the same table. Glyphs fade in 0.07 s
// after the pointer enters the group. A pressed button is brighter while the pointer is on it and acts on release inside
// it; from mouse-down to mouse-up it lifts by 2 pt with a bounce and leans toward a dragged pointer (the Mac's
// FlexInteraction windowControl press, Tokens.lights.lift*, reference/re/27.2.1/LIGHTS-REA-27.2.1.md; it was a 1.15x jump).
// An inactive window shows grey discs, back in colour with their glyphs at once while the group is hovered, and its
// lights lift in one frame; a disabled zoom stays a grey disc without a glyph that only lifts (one frame) when pressed
// (R6.4, LIGHTS-REA section 10). Used by Settings and Finder.
// (Before: a three-stop fill in a 0.5 pt ring with a flat halo, `anchors.margins: -1`; it read as a plain disc.)
Row {
    id: tl
    property bool active: true
    // which of the table's halves the discs take: the app's appearance, or a title bar's own (Mission Control draws the
    // plugin's bars of dark terminals with the dark discs, as plugin/src/Titlebar.cpp does)
    property bool dark: Tokens.dark
    property bool zoomEnabled: true
    // false: the close light is a grey disc that does nothing (a window under a sheet: System Settings' sheets,
    // live/settings-r13 dest-*--*-options-*.png: close (230,230,235) light / (73,74,86) dark, the other two in colour)
    property bool closeEnabled: true
    // Q-windows-19 (27.2.1 default): green = full screen (two-triangle glyph), Option-click = zoom
    // (the glyph turns into + while Option is held). Off: green zooms and shows +.
    property bool fullScreenButton: true
    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()
    signal fullScreenClicked()
    spacing: Tokens.lights.spacing

    // [rest, pressed, inactive][close, minimize, zoom]: T rgb, M rgb, B rgb, sg, rim axis, rim power, rim rgb, e0, e1,
    // glow rgb, g0, veil (sRGB bytes; lights_model.py has the model and the residuals against the crops). veil 1: the
    // disc is a white layer over the window and the colours are its alpha x 255 (the dark inactive disc, R16.4)
    // generated: plugin/tools/lights_model.py emit (check: lights_model.py check)
    readonly property var glass: ({
        light: [
            [[254, 110, 99, 251, 112, 103, 246, 157, 149, 1.3, 1, 2.5, 184, 2, 0, 1, 0.2, 249, 22, 0, 0.14, 0], [251, 183, 54, 253, 193, 44, 257, 222, 87, 1, 1, 2, 155, 71, 0, 1, 0.25, 245, 119, 0, 0.135, 0], [89, 207, 33, 112, 209, 68, 180, 229, 155, 2, 1, 1.5, 26, 105, 3, 1, 0.25, 45, 160, 0, 0.137, 0]],
            [[255, 151, 135, 255, 157, 142, 255, 205, 193, 1.3, 1, 3, 255, 65, 57, 1, 0.5, 252, 20, 0, 0.175, 0], [255, 257, 80, 255, 253, 64, 255, 256, 124, 1, 1, 3, 254, 133, 0, 1, 0.3, 242, 123, 0, 0.208, 0], [129, 255, 52, 160, 255, 98, 241, 255, 198, 4, 1, 2, 61, 201, 31, 1, 0.45, 44, 157, 0, 0.187, 0]],
            [[248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0, 0], [248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0, 0], [248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0, 0]],
        ],
        dark: [
            [[252, 113, 105, 244, 81, 70, 236, 118, 114, 0.6, 0, 2.5, 255, 209, 200, 0.9, 0.36, 0, 0, 0, 0, 0], [249, 179, 22, 252, 182, -35, 257, 222, 84, 0.6, 0, 3, 255, 255, 118, 1, 0.4, 0, 0, 0, 0, 0], [127, 203, 43, -2, 188, -28, 135, 200, 102, 0.6, 0, 1.5, 143, 255, 132, 1, 0.45, 0, 0, 0, 0, 0]],
            [[255, 154, 139, 255, 117, 100, 255, 154, 145, 0.5, 0, 3, 255, 255, 244, 0.7, 0.67, 0, 0, 0, 0, 0], [255, 244, 8, 255, 249, -15, 255, 289, 113, 0.5, 0, 3, 254, 250, 162, 0.9, 0.72, 0, 0, 0, 0, 0], [153, 245, 52, -2, 227, -34, 163, 241, 123, 0.6, 0, 1.5, 143, 255, 132, 0.7, 0.67, 0, 0, 0, 0, 0]],
            [[50, 50, 50, 47, 47, 47, 33, 33, 33, 1.3, 0, 3, 238, 238, 238, 0.6, 0.24, 0, 0, 0, 0, 1], [50, 50, 50, 47, 47, 47, 33, 33, 33, 1.3, 0, 3, 238, 238, 238, 0.6, 0.24, 0, 0, 0, 0, 1], [50, 50, 50, 47, 47, 47, 33, 33, 33, 1.3, 0, 3, 238, 238, 238, 0.6, 0.24, 0, 0, 0, 0, 1]],
        ],
    })
    // The light inactive disc is not opaque: it reads (241,242,244) over a white bar (lights-inactive-light.png, R17.4),
    // (233,234,236) over System Settings' (242,242,242) inactive sidebar (settings/desktop-dock-inactive-light-*.png) and
    // (229,230,233) over the (236,237,238) sidebar under a sheet (finder/sheet-light.png, settings-r13 clock-options): .60
    // to .65 of the bar's change shows through the body, .31 through the side rim's outer pixel. The table's row is the
    // disc over white; shaders/lights.frag takes this share off (LIGHTS-REA section 14). Dark: the white veil of the table
    readonly property real inactiveThrough: 0.63
    readonly property int glassMargin: 5   // whole pt around the disc (glow, pressed disc); a half pt would shift it

    HoverHandler { id: hover }
    // hovered only while Option (Alt) is held; it updates with the next pointer event
    HoverHandler { id: optionHover; acceptedModifiers: Qt.AltModifier }
    // Glyphs: shown 0.07 s after entering (Q-windows-10), hidden at once on exit; nothing runs at rest. An inactive
    // window shows them in full on the first hovered frame, no wait and no fade (R6.4, lights-inactive-press-dark.mov:
    // pointer in at 0.383 s, all three in colour with full glyphs at 0.400 s; LIGHTS-REA section 10); the fade-out is
    // the same (not measured inactive). `_enteredInactive` keeps that state for the press too: without the liquidglass
    // plugin's client lights (plugin/src/ClientLights.hpp, which the app tells where this row is) Hyprland activates a
    // Qt window on the press (follow_mouse 2), before the light sees it, where the Mac's stays inactive.
    property bool _glyphs: false
    property bool _enteredInactive: false
    // the glyphs' change in this event jumps (the inactive entry); cleared once the bindings have settled, so the
    // fade-out on exit still runs
    property bool _glyphSnap: false
    function _endGlyphSnap() { _glyphSnap = false; }
    Timer { id: glyphDelay; interval: Tokens.reduceMotion ? 0 : Tokens.lights.glyphDelay; onTriggered: tl._glyphs = true }
    Connections {
        target: hover
        function onHoveredChanged() {
            if (hover.hovered) {
                tl._enteredInactive = !tl.active;
                if (tl._enteredInactive) {
                    tl._glyphSnap = true;
                    tl._glyphs = true;
                    Qt.callLater(tl._endGlyphSnap);
                } else glyphDelay.restart();
            } else { glyphDelay.stop(); tl._enteredInactive = false; tl._glyphs = false; }
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
            // how pressed the colour looks, 0..1: taken in one frame (mouse-down, back onto the button), given back on a
            // critically damped spring leaveFadeDelay after the pointer leaves the held button (Tokens.lights.leaveFade,
            // measured), at once on mouse-up (not measured: the window acts)
            Spring {
                id: pressLook
                response: Tokens.lights.leaveFade
                damping: 1
                epsilon: 0.002
                instant: Tokens.reduceMotion
            }
            // set here, not bound: whether to jump must be known before the target moves. Leaving the held button, the
            // fade waits leaveFadeDelay first (measured)
            Timer { id: leaveWait; interval: Tokens.lights.leaveFadeDelay; onTriggered: pressLook.target = 0 }
            onDownChanged: {
                leaveWait.stop();
                if (down || !ma.pressed || Tokens.reduceMotion) {
                    pressLook.target = down ? 1 : 0;
                    pressLook.snap();
                } else leaveWait.restart();
            }
            readonly property real pressMix: lit ? pressLook.value : 0
            readonly property color glyphColor: {
                if (!lit || pressMix <= 0 || pressMix >= 1) return c.glyph;
                const a = Qt.color(Tokens.lights[modelData.k].glyph), b = Qt.color(Tokens.lights[modelData.k].press.glyph), t = pressMix;
                return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t);
            }
            readonly property bool enabled_: (modelData.k !== "zoom" || tl.zoomEnabled) && (modelData.k !== "close" || tl.closeEnabled)
            readonly property bool lit: enabled_ && (tl.active || hover.hovered)
            // a disabled light takes the press (it lifts, R6.4) but never looks pressed and never acts
            readonly property bool down: ma.pressed && ma.containsMouse && enabled_
            width: Tokens.lights.size; height: width

            // The press (Tokens.lights.lift*; plugin/src/LightPress.cpp is the same maths): `flex` from mouse-down until
            // mouse-up or idleTimeout without pointer events, wherever the pointer goes (no cancel by distance). Target:
            // the lift on both axes, plus per axis k = (|d| - |di|) / thr + |di| / (4 thr) (d = travel since the press, di =
            // with the pointer clamped to the light): scale x +k, y -k, shift x = width sign(d) k (y alike), about the
            // centre; one spring for all, the same spring back (its numbers measured on Mac recordings, LIGHTS-REA sections
            // 8 and 9). Nothing runs at rest.
            // A disabled light, or any light of an inactive window, lifts in one frame instead (`snapLift`, set at the
            // press; R6.4: the disabled zoom and the inactive close each lift by the full 2 pt from one frame to the next
            // and hold still, no bounce). The way back is the usual spring: the disabled zoom's release dips 31 % of the
            // lift under rest at 0.18 s (spring fit 0.335 / 0.41; ours 0.31 / 0.5 within 0.057 of the lift, the tracking
            // spring 0.1 / 1.0 0.173). LIGHTS-REA section 10
            property bool snapLift: false
            property bool flex: false
            property real pressX: 0
            property real pressY: 0
            property real pointerX: 0
            property real pointerY: 0
            readonly property real liftK: (Math.max(width, height) + Tokens.lights.liftPoints) / Math.max(width, height) - 1
            readonly property real kx: flex ? Math.abs(Motion.flexStretch(pointerX - pressX, Math.max(0, Math.min(width, pointerX)) - pressX, Tokens.lights.stretchDistance)) : 0
            readonly property real ky: flex ? Math.abs(Motion.flexStretch(pointerY - pressY, Math.max(0, Math.min(height, pointerY)) - pressY, Tokens.lights.stretchDistance)) : 0
            // `snapLift` goes on before `flex` at the press and off before it at the end, so the way back always springs
            Spring { id: liftX; target: light.flex ? light.liftK + light.kx - light.ky : 0; response: Tokens.lights.liftResponse; damping: Tokens.lights.liftDamping; epsilon: 0.0005; instant: Tokens.reduceMotion || light.snapLift }
            Spring { id: liftY; target: light.flex ? light.liftK - light.kx + light.ky : 0; response: Tokens.lights.liftResponse; damping: Tokens.lights.liftDamping; epsilon: 0.0005; instant: Tokens.reduceMotion || light.snapLift }
            Spring { id: shiftX; target: light.flex ? light.width * Math.sign(light.pointerX - light.pressX) * light.kx : 0; response: Tokens.lights.liftResponse; damping: Tokens.lights.liftDamping; instant: Tokens.reduceMotion || light.snapLift }
            Spring { id: shiftY; target: light.flex ? light.height * Math.sign(light.pointerY - light.pressY) * light.ky : 0; response: Tokens.lights.liftResponse; damping: Tokens.lights.liftDamping; instant: Tokens.reduceMotion || light.snapLift }
            // the idle end of a snapped lift springs back too (not measured: the Mac clips hold 1.55 / 0.83 s)
            Timer { id: idle; interval: Tokens.lights.idleTimeout; onTriggered: { light.snapLift = false; light.flex = false; } }
            // for tests and captures: the light's current scale
            readonly property real pressScaleX: 1 + liftX.value
            readonly property real pressScaleY: 1 + liftY.value

            Item {
                id: body
                anchors.fill: parent
                transform: [
                    Scale { origin.x: body.width / 2; origin.y: body.height / 2; xScale: light.pressScaleX; yScale: light.pressScaleY },
                    Translate { x: shiftX.value; y: shiftY.value }
                ]

                ShaderEffect {
                    // the rest and pressed looks mixed by pressMix (a leave fade); either one as it is at 0 and 1
                    readonly property var g: {
                        const t = tl.glass[tl.dark ? "dark" : "light"], m = light.pressMix;
                        if (!light.lit) return t[2][index];
                        if (m <= 0) return t[0][index];
                        if (m >= 1) return t[1][index];
                        const a = t[0][index], b = t[1][index];
                        return a.map((v, i) => v + (b[i] - v) * m);
                    }
                    anchors.centerIn: parent
                    width: parent.width + 2 * tl.glassMargin; height: width
                    fragmentShader: Qt.resolvedUrl("shaders/lights.frag.qsb")
                    property size size: Qt.size(width, height)
                    // the disc stays 14 pt in the item: the press scales the whole item, so the edge's antialiasing takes
                    // the device px per pt after that scale
                    property real radius: Tokens.lights.size / 2
                    property real ppt: (Tokens.dpr > 0 ? Tokens.dpr : Screen.devicePixelRatio) * (light.pressScaleX + light.pressScaleY) / 2
                    property vector4d colT: Qt.vector4d(g[0] / 255, g[1] / 255, g[2] / 255, 1)
                    property vector4d colM: Qt.vector4d(g[3] / 255, g[4] / 255, g[5] / 255, 1)
                    property vector4d colB: Qt.vector4d(g[6] / 255, g[7] / 255, g[8] / 255, g[9])
                    property vector4d rim: Qt.vector4d(g[12] / 255, g[13] / 255, g[14] / 255, g[11])
                    property vector4d rimE: Qt.vector4d(g[15], g[16], g[10], !light.lit && !tl.dark && g[21] === 0 ? tl.inactiveThrough : g[21])
                    property vector4d glow: Qt.vector4d(g[17] / 255, g[18] / 255, g[19] / 255, g[20])
                }
                Item {
                    anchors.fill: parent
                    // Glyph on a 14 pt artboard, vector so the ink stays solid at 2x (hover centre 159,0,0 on the Mac).
                    // Round caps add half the stroke at each end, so the centre lines are the Q-windows-10 ink sizes minus
                    // one stroke. Full screen: two triangles making a 6 x 6 square split along the rising diagonal
                    // (lights-hover-light.png: 12 x 12 px at 2x, gap about 4 px across).
                    Shape {
                        id: glyph
                        objectName: "glyph"
                        width: 14; height: 14
                        scale: parent.width / 14
                        transformOrigin: Item.TopLeft
                        preferredRendererType: Shape.CurveRenderer
                        opacity: light.lit && tl._glyphs ? 1 : 0
                        visible: opacity > 0
                        Behavior on opacity {
                            enabled: !Tokens.reduceMotion && !tl._glyphSnap
                            NumberAnimation {
                                duration: tl._glyphs ? Tokens.lights.glyphIn : Tokens.lights.glyphOut
                                easing.type: tl._glyphs ? Easing.OutCubic : Easing.OutQuad
                            }
                        }
                        readonly property string kind: light.modelData.k !== "zoom" ? light.modelData.k
                                                      : tl.fullScreenButton && !optionHover.hovered ? "full" : "plus"
                        readonly property bool filled: kind === "full"
                        ShapePath {
                            strokeColor: glyph.filled ? "transparent" : light.glyphColor
                            fillColor: glyph.filled ? light.glyphColor : "transparent"
                            // fitted on lights-hover-{dark,light}.png over the disc model (plugin/tools/lights_model.py): the x
                            // reads 2.05 pt, the minus 2.0 x 7.9 pt, the triangles a 5.8 pt box (rms 9.6 -> 5.7, 7.9 -> 7.7,
                            // 10.0 -> 8.9 dark); + has no crop without Option and keeps the token. Pressed, the triangles are
                            // larger: corners 4.00 / 9.10 in the 14 pt box (the press crop, plugin/tools/lights_model.py); the
                            // pressed x is 2.21 pt from 4.42 to 9.58, the pressed minus 4.0 to 10.0 (round-capped strokes fitted
                            // to the glyph coverage of lights-press-{close,min}-{light,dark}.png: x rms .083 -> .068 light,
                            // .127 -> .092 dark, minus .042 -> .039 light, .087 dark unchanged)
                            strokeWidth: glyph.filled ? -1 : glyph.kind === "close" ? (light.down ? 2.21 : 2.05) : glyph.kind === "minimize" ? 2.0 : Tokens.lights.glyphStroke
                            capStyle: ShapePath.RoundCap
                            PathSvg {
                                path: ({
                                    close: light.down ? "M 4.42 4.42 L 9.58 9.58 M 9.58 4.42 L 4.42 9.58"
                                                      : "M 4.45 4.45 L 9.55 9.55 M 9.55 4.45 L 4.45 9.55",
                                    minimize: light.down ? "M 4 7 L 10 7" : "M 4.05 7 L 9.95 7",
                                    plus: "M 3.95 7 L 10.05 7 M 7 3.95 L 7 10.05",
                                    full: light.down ? "M 4 4 L 9.1 4 L 4 9.1 Z M 10 10 L 4.9 10 L 10 4.9 Z"
                                                     : "M 4.1 4.1 L 8.9 4.1 L 4.1 8.9 Z M 9.9 9.9 L 5.1 9.9 L 9.9 5.1 Z"
                                })[glyph.kind]
                            }
                        }
                    }
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                onPressed: mouse => {
                    light.pressX = light.pointerX = mouse.x;
                    light.pressY = light.pointerY = mouse.y;
                    light.snapLift = !light.enabled_ || !tl.active || tl._enteredInactive;
                    light.flex = true;
                    idle.restart();
                }
                onPositionChanged: mouse => {
                    if (!light.flex) return;
                    light.pointerX = mouse.x;
                    light.pointerY = mouse.y;
                    idle.restart();
                }
                onReleased: { light.snapLift = false; light.flex = false; idle.stop(); leaveWait.stop(); pressLook.target = 0; pressLook.snap(); }
                onCanceled: { light.snapLift = false; light.flex = false; idle.stop(); leaveWait.stop(); pressLook.target = 0; pressLook.snap(); }
                onClicked: mouse => {
                    if (!light.enabled_) return;   // the disabled zoom's release does nothing (R6.4)
                    if (light.modelData.k === "zoom" && tl.fullScreenButton && !(mouse.modifiers & Qt.AltModifier))
                        tl.fullScreenClicked();
                    else
                        tl[light.modelData.s]();
                }
            }
        }
    }
}
