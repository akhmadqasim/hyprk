import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/hud.js" as HudLib

// Volume / brightness HUD (macOS 27.2.1, MAC-ANSWERS.md HUD (27.2.1)): a clear glass capsule at the
// top right below the menu bar (layer hyprk-hud: the plugin's "clear" recipe) with an SF Symbol and
// a bar of 16 dashes. Fades and grows in 50 ms after the change, hides 1.05 s after the last one;
// further changes only move the bar fill, and volume <-> brightness crossfades inside the capsule.
// Tokens and state: services/Hud.qml. The window is unmapped while hidden and nothing animates then.
ShellWindow {
    id: win

    readonly property QtObject m: Hud.metrics
    readonly property QtObject mo: Hud.motion
    // Reduce motion: fades only, no scale (Theme.travel), durations capped (Theme.ms)
    readonly property real startScale: 1 - Theme.travel(1 - mo.appearScale)
    readonly property real endScale: 1 - Theme.travel(1 - mo.hideScale)

    screen: Hud.screen
    namespace: "hyprk-hud"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins.top: Theme.menuBar.height + m.gap
    margins.right: m.gap
    implicitWidth: Math.ceil(m.width)
    implicitHeight: Math.ceil(m.height)
    acceptsInput: false                 // never takes clicks

    // alpha of glass and content together (the plugin glass follows through glassOpacity)
    property real alpha: 0
    property bool mapped: false
    visible: mapped
    glassOpacity: alpha

    Connections {
        target: Hud
        function onShownChanged() { Hud.shown ? win.appear() : win.disappear(); }
    }
    function appear() {
        fadeOut.stop();
        shrink.stop();
        if (!mapped) {
            // fresh: everything starts where it should be, then waits for the 50 ms delay
            volumeLayer.snap();
            brightnessLayer.snap();
            grow.target = startScale;
            grow.snap();
            alpha = 0;
            mapped = true;
            delay.start();
        } else {
            begin();                    // came back while hiding: no delay
        }
    }
    function begin() {
        fadeIn.from = alpha;
        fadeIn.restart();
        grow.target = 1;
    }
    function disappear() {
        delay.stop();
        fadeIn.stop();
        if (alpha <= 0) { mapped = false; return; }
        fadeOut.from = alpha;
        fadeOut.restart();
        shrink.from = grow.value;
        shrink.restart();
        settleGlass(fadeOut.duration + 50);
    }

    Timer { id: delay; interval: win.mo.showDelay; onTriggered: win.begin() }
    NumberAnimation {
        id: fadeIn
        target: win; property: "alpha"; to: 1
        duration: Theme.ms(win.mo.appearDuration)
        easing.type: Easing.BezierSpline; easing.bezierCurve: win.mo.appearCurve
    }
    NumberAnimation {
        id: fadeOut
        target: win; property: "alpha"; to: 0
        duration: Theme.ms(win.mo.hideDuration)
        easing.type: Easing.BezierSpline; easing.bezierCurve: win.mo.hideCurve
        onFinished: if (!Hud.shown) win.mapped = false
    }
    // grows in on a spring; shrinks out on the fade's curve
    Spring { id: grow; target: 1; response: win.mo.appearResponse; damping: 1; epsilon: 0.0005; settlesGlass: true }
    NumberAnimation {
        id: shrink
        target: grow; property: "value"; to: win.endScale
        duration: Theme.ms(win.mo.hideDuration)
        easing.type: Easing.BezierSpline; easing.bezierCurve: win.mo.hideCurve
    }

    Item {
        id: capsule
        x: win.width - width            // the capsule ends exactly `gap` from the screen edge
        width: win.m.width
        height: win.m.height
        scale: grow.value

        Glass {
            anchors.fill: parent
            radius: height / 2
            // QML fallback: sample the blurred wallpaper where the capsule sits
            sx: (win.screen ? win.screen.width : 0) - win.m.gap - win.m.width
            sy: Theme.menuBar.height + win.m.gap
            tint: Theme.glass.tintClear
            shadow: false               // the clear recipe has no drop shadow
            pluginLift: "transparent"   // white content on clear glass in light and dark alike (measured)
            opacity: Theme.compositorGlass ? 1 : win.alpha
        }

        Item {
            anchors.fill: parent
            opacity: win.alpha
            Layer {
                id: volumeLayer
                active: Hud.kind === "volume"
                symbol: Hud.volumeSymbol
                level: Hud.volumeLevel
            }
            Layer {
                id: brightnessLayer
                active: Hud.kind === "brightness"
                symbol: "sun.max.fill"
                level: Hud.brightness
            }
        }
    }

    // ---------- SF Symbols (themes/icons/sf-symbols/svg, regular weight) ----------
    // Loaded here, not through components/Symbol.qml, which draws the 24 px symbols.js set.
    // baselineY: names.json files[<file>].baselineY (points at the 32 pt render size).
    readonly property string svgDir: Theme.hyprkRoot + "/themes/icons/sf-symbols/svg/"
    readonly property real glyphScale: m.glyphSize / 32
    property var glyphs: ({})
    function addGlyph(name, text, baselineY, left) {
        let paths = HudLib.svgPaths(text);
        const g = Object.assign({}, glyphs);
        g[name] = { paths: paths, baselineY: baselineY, left: left };
        // speaker.wave.1.fill is not extracted: speaker.wave.2.fill without its outer wave
        if (name === "speaker.wave.2.fill")
            g["speaker.wave.1.fill"] = { paths: HudLib.withoutOuterWave(paths), baselineY: baselineY, left: left };
        glyphs = g;
    }
    Repeater {
        model: [
            { name: "speaker.wave.2.fill", baselineY: 28.5, sun: false },
            { name: "speaker.wave.3.fill", baselineY: 30, sun: false },
            { name: "speaker.slash.fill", baselineY: 30.5, sun: false },
            { name: "sun.max.fill", baselineY: 31.5, sun: true }
        ]
        Item {
            required property var modelData
            FileView {
                path: win.svgDir + modelData.name + ".regular.svg"
                blockLoading: true
                onLoaded: win.addGlyph(modelData.name, text(), modelData.baselineY,
                                       modelData.sun ? win.m.glyphLeftSun : win.m.glyphLeft)
            }
        }
    }

    readonly property var dashList: HudLib.dashes(m.barLength, m.dashes, m.dashGap)

    // one glyph + bar; volume and brightness each have one so they can crossfade
    component Layer: Item {
        id: layer
        property bool active
        property string symbol
        property real level
        anchors.fill: parent
        opacity: active ? 1 : 0
        visible: opacity > 0
        // crossfade only while the HUD is on screen; a fresh HUD starts with the right layer
        Behavior on opacity {
            enabled: win.alpha > 0
            NumberAnimation { duration: Theme.ms(win.mo.crossfade) }
        }
        function snap() { fill.snap(); }
        // jumps while the window is unmapped (a change while the Control Center is open animates nothing)
        Spring {
            id: fill
            target: layer.level * win.m.barLength
            response: win.mo.fillResponse
            damping: 1
            epsilon: 0.05
            instant: !win.mapped
        }

        Item {
            readonly property var g: win.glyphs[layer.symbol]
            visible: !!g
            x: g ? g.left : 0
            y: g ? win.m.glyphBaseline - g.baselineY * win.glyphScale : 0
            Repeater {
                model: parent.g ? parent.g.paths : []
                Shape {
                    required property var modelData
                    preferredRendererType: Shape.CurveRenderer
                    transform: Scale { xScale: win.glyphScale; yScale: win.glyphScale }
                    ShapePath {
                        fillColor: Qt.rgba(1, 1, 1, modelData.opacity)
                        fillRule: ShapePath.WindingFill
                        strokeColor: "transparent"
                        strokeWidth: 0
                        PathSvg { path: modelData.d }
                    }
                }
            }
        }

        Bar { color: win.m.empty; width: win.m.barLength }
        // filled part: the same dashes clipped at the level, so it can stop inside a dash
        Item {
            x: win.m.barX
            width: Math.max(0, fill.value)
            height: parent.height
            clip: true
            Bar { x: 0; color: win.m.fill; width: win.m.barLength }
        }
    }

    // the dashes; the bar's outer ends are round (radius = half the height)
    component Bar: Item {
        id: bar
        property color color
        x: win.m.barX
        y: win.m.barY
        height: win.m.dashHeight
        Repeater {
            model: win.dashList
            Rectangle {
                required property var modelData
                required property int index
                readonly property real r: win.m.dashHeight / 2
                x: modelData.x
                width: modelData.w
                height: bar.height
                color: bar.color
                topLeftRadius: index === 0 ? r : 0
                bottomLeftRadius: index === 0 ? r : 0
                topRightRadius: index === win.dashList.length - 1 ? r : 0
                bottomRightRadius: index === win.dashList.length - 1 ? r : 0
                antialiasing: true
            }
        }
    }
}
