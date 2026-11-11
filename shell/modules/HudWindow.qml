import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/hud.js" as HudLib

// Volume / brightness HUD (macOS 27.2.1, MAC-ANSWERS.md "REA 27.2.1" section 1, SystemBannerUI): a glass
// capsule at the top right, 10 pt below the menu bar, on the Control Center recipe (layer hyprk-hud), with an
// SF Symbol and a bar of 16 dashes.
// Motion (exact springs, lib/spring.js via components/SpringCurve.qml): one progress `shownness` drives scale
// 0.9 -> 1 and opacity 0 -> 1 (BannerContentController: _scaleFactor 0.9, _opacity 0).
// - appear: interpolatingSpring(mass 2, stiffness 300, damping 50) (response 0.513 s, ratio 1.021, which SwiftUI
//   clamps to critical: lib/spring.js fromPhysics), also when a
//   press brings back a HUD that is hiding;
// - hide: spring(response 0.48669, dampingFraction 1) to 0, and the window goes at 0.48669 s (the dismissal
//   completion's asyncAfter), where the spring stands at 0.986;
// - the content (bar fill, volume <-> brightness crossfade) moves on spring(response 0.2, dampingFraction 0.85).
// The glass fades by mixing towards identity by 1 - opacity under an .opacity(opacity) view, so it is drawn at
// opacity^2 (the recording's alpha fits opacity^2, RMS 0.017; the reason is an inference) and the content at opacity.
// Tokens and state: services/Hud.qml. The window is unmapped while hidden and nothing animates then.
ShellWindow {
    id: win

    readonly property QtObject m: Hud.metrics
    readonly property QtObject mo: Hud.motion

    screen: Hud.screen
    namespace: "hyprk-hud"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins.top: Theme.menuBar.height + m.gap
    margins.right: m.gap
    implicitWidth: Math.ceil(m.width)
    // one clear row under the capsule for ShellWindow's glass opacity marker: when the growing glass reached the bottom
    // row the region union swallowed the 1x1 marker and the glass jumped to full opacity mid-appear (mcap: 0.71 -> 0.92
    // in one frame, with one frame of a different glass look)
    implicitHeight: Math.ceil(m.height) + 1
    acceptsInput: false                 // never takes clicks

    // 0 hidden .. 1 shown: opacity of the content; scale 0.9 + 0.1 x (Reduce motion: no scale, Theme.travel)
    property real shownness: 0
    readonly property real glassAlpha: shownness * shownness
    property bool mapped: false
    visible: mapped
    glassOpacity: glassAlpha

    Connections {
        target: Hud
        function onShownChanged() { Hud.shown ? win.appear() : win.disappear(); }
    }
    function appear() {
        if (!mapped) {
            // fresh: everything starts where it should be, then waits for the 3 frame hosting delay
            volumeLayer.snap();
            brightnessLayer.snap();
            motion.snap(0);
            mapped = true;
            delay.start();
        } else {
            begin();                    // came back while hiding: no delay
        }
    }
    function begin() {
        motion.spring = mo.appear;
        motion.cutAt = 0;
        motion.go(1);
        settleGlass(motion.duration + 50);
    }
    function disappear() {
        delay.stop();
        if (shownness <= 0) { motion.stop(); mapped = false; return; }
        motion.spring = mo.hide;
        motion.cutAt = mo.hideSeconds;
        motion.go(0);
        settleGlass(motion.duration + 50);
    }

    Timer { id: delay; interval: win.mo.showDelay; onTriggered: win.begin() }
    SpringCurve {
        id: motion
        target: win
        property: "shownness"
        onFinished: if (!Hud.shown) win.mapped = false
    }

    Item {
        id: capsule
        x: win.width - width            // the capsule ends exactly `gap` from the screen edge
        width: win.m.width
        height: win.m.height
        scale: 1 - Theme.travel(1 - win.mo.appearScale) * (1 - win.shownness)

        Glass {
            anchors.fill: parent
            radius: height / 2
            // QML fallback: sample the blurred wallpaper where the capsule sits
            sx: (win.screen ? win.screen.width : 0) - win.m.gap - win.m.width
            sy: Theme.menuBar.height + win.m.gap
            // the Control Center recipe, like a Control Center module (no drop shadow)
            tint: Theme.cc.tileTint
            solidColor: Theme.cc.tileSolid
            pluginLift: Theme.cc.pluginLift
            shadow: false
            opacity: Theme.compositorGlass ? 1 : win.glassAlpha
        }

        Item {
            anchors.fill: parent
            opacity: win.shownness
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
        // paths from the left: speaker body, then its waves from the inside out
        const paths = HudLib.svgPaths(text).sort((a, b) => a.maxX - b.maxX);
        const g = Object.assign({}, glyphs);
        g[name] = { paths: paths, baselineY: baselineY, left: left };
        glyphs = g;
    }
    Repeater {
        model: [
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

    // one SF Symbol of win.glyphs, with an opacity per path
    component Glyph: Item {
        id: glyph
        property string name
        property var ops: []          // opacity per path (default 1)
        readonly property var g: win.glyphs[name]
        visible: !!g && opacity > 0
        x: g ? g.left : 0
        y: g ? win.m.glyphBaseline - g.baselineY * win.glyphScale : 0
        Repeater {
            model: glyph.g ? glyph.g.paths : []
            Shape {
                required property var modelData
                required property int index
                opacity: glyph.ops[index] ?? 1
                visible: opacity > 0
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
    // one glyph + bar; volume and brightness each have one so they can crossfade
    component Layer: Item {
        id: lay
        property bool active
        property string symbol
        property real level
        anchors.fill: parent
        opacity: 0
        visible: opacity > 0
        // crossfade only while the HUD is on screen; a fresh HUD starts with the right layer
        onActiveChanged: if (win.shownness > 0) crossfade.go(active ? 1 : 0); else crossfade.snap(active ? 1 : 0)
        onLevelChanged: if (win.mapped) fill.go(level * win.m.barLength); else fill.snap(level * win.m.barLength)
        function snap() { crossfade.snap(active ? 1 : 0); fill.snap(level * win.m.barLength); glyphGo(false); }
        property real fillLength: 0
        SpringCurve { id: crossfade; target: lay; property: "opacity"; spring: win.mo.content }
        SpringCurve { id: fill; target: lay; property: "fillLength"; spring: win.mo.content }

        // Glyph. Volume: speaker.wave.1 / .2 / .3 are one drawing, speaker.wave.3.fill with 1, 2 or 3 of its waves
        // (the same paths on the same baseline: wave.2's body and waves are wave.3's 1.53 units higher on a canvas
        // whose baseline is 1.5 higher), and speaker.slash.fill. A change of symbol fades only what differs, on the
        // content spring: a wave fades in or out, the slash cross-fades with the whole speaker. Mac: SystemBannerUI
        // swaps Image(systemName:) inside the value's withAnimation(spring 0.2 / 0.85) with no symbol effect (REA 1),
        // and the recording shows the HUD's glyphs cross-fading in about 3 frames with both visible (volume <->
        // brightness); that the same fade runs between wave counts, layer by layer, is inferred (no recording of it).
        readonly property bool volume: symbol !== "sun.max.fill"
        // opacities [speaker, wave 1, wave 2, wave 3, slash]: shown = from + (to - from) x mix
        property var glyphFrom: [1, 0, 0, 0, 0]
        property var glyphTo: [1, 0, 0, 0, 0]
        property real glyphMix: 1
        function glyphOp(k) { return glyphFrom[k] + (glyphTo[k] - glyphFrom[k]) * glyphMix; }
        function glyphGo(animated) {
            if (!volume) return;
            const cur = [0, 1, 2, 3, 4].map(glyphOp);
            const slash = symbol === "speaker.slash.fill";
            const waves = symbol === "speaker.wave.1.fill" ? 1 : symbol === "speaker.wave.2.fill" ? 2 : symbol === "speaker.wave.3.fill" ? 3 : 0;
            // muted: the speaker fades out with the waves it had
            const to = slash ? [0, glyphTo[1], glyphTo[2], glyphTo[3], 1] : [1, waves >= 1 ? 1 : 0, waves >= 2 ? 1 : 0, waves >= 3 ? 1 : 0, 0];
            glyphFade.snap(animated ? 0 : 1);
            glyphFrom = animated ? cur : to;
            glyphTo = to;
            if (animated) glyphFade.go(1);
        }
        onSymbolChanged: glyphGo(win.mapped && win.shownness > 0 && opacity > 0)
        SpringCurve { id: glyphFade; target: lay; property: "glyphMix"; spring: win.mo.content }

        Loader {
            active: !lay.volume
            sourceComponent: Glyph { name: "sun.max.fill" }
        }
        Loader {
            active: lay.volume
            sourceComponent: Item {
                Glyph {
                    name: "speaker.wave.3.fill"
                    opacity: lay.glyphOp(0)
                    ops: [1, lay.glyphOp(1), lay.glyphOp(2), lay.glyphOp(3)]
                }
                Glyph { name: "speaker.slash.fill"; opacity: lay.glyphOp(4) }
            }
        }

        Bar { color: win.m.empty; width: win.m.barLength }
        // filled part: the same dashes clipped at the level, so it can stop inside a dash
        Item {
            x: win.m.barX
            width: Math.max(0, lay.fillLength)
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
