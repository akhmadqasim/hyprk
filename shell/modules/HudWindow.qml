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
import "../HyprK/motion.js" as Motion

// Volume / brightness HUD (macOS 27.2.1, MAC-ANSWERS.md "REA 27.2.1" section 1, SystemBannerUI): a glass
// capsule at the top right, 10 pt below the menu bar, on the Control Center recipe (layer hyprk-hud), with an
// SF Symbol and a bar of 16 dashes.
// Motion (exact springs, lib/spring.js): one progress `shownness` drives scale
// 0.9 -> 1 and opacity 0 -> 1 (BannerContentController: _scaleFactor 0.9, _opacity 0). The scale's anchor is the
// capsule's horizontal centre 10 pt above its top (the banner's top edge with its _topMargin 10), not its centre:
// R3.4 / R6.2 clips, the capsule sits 4.3 pt x (1 - o) higher while it grows (Hud.motion.anchorAbove).
// - appear: interpolatingSpring(mass 2, stiffness 300, damping 50) (response 0.513 s, ratio 1.021, which SwiftUI
//   clamps to critical: lib/spring.js fromPhysics), also when a
//   press brings back a HUD that is hiding;
// - hide: spring(response 0.48669, dampingFraction 1) to 0, and the window goes at 0.48669 s (the dismissal
//   completion's asyncAfter), where the spring stands at 0.986;
// - the content (bar fill, volume <-> brightness crossfade) moves on spring(response 0.2, dampingFraction 0.85).
//   Every volume step slides the fill one dash on that spring (R11.4 clips: 40 steps fit it at rms .014 of a step);
//   the dashes stay, the speaker's wave count changes in one frame, and the glyph bounces layer by layer when the
//   level arrives at 0 or full (MOTION-REA "Round R11.4").
// The glass is drawn at opacity^2, appearing and hiding alike (below); the content at the opacity, from the first
// frame (MOTION-AUDIT.md "HUD", "Round J20"). SystemBannerUI (BannerSlider.body 0x2aed61dd8, cache
// address) puts one .opacity(opacity) on the content and wraps it in
// _glassEffect(.controlCenter.mix(with: .identity, by: 1 - opacity)): the content fades with the spring, the glass
// with the mix, read here as a second factor (inferred; the Mac's dismiss recording fits s^2 at rms 0.017). Content at
// opacity^2 as well was tried: dismiss 222-233 ms on screen against the Mac's 283 (content at opacity: 282-291).
// One value per frame of this window (components/FrameSpring).
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
    // room above the capsule for the top anchor: scaled about a point anchorAbove over its top, the capsule's top rises
    // to anchorAbove x (1 - appearScale) = 1 pt above its resting place
    readonly property real room: Math.ceil(mo.anchorAbove * (1 - mo.appearScale))
    margins.top: Theme.menuBar.height + m.gap - room
    margins.right: m.gap
    implicitWidth: Math.ceil(m.width)
    // one clear row under the capsule for ShellWindow's glass opacity marker: when the growing glass reached the bottom
    // row the region union swallowed the 1x1 marker and the glass jumped to full opacity mid-appear (mcap: 0.71 -> 0.92
    // in one frame, with one frame of a different glass look)
    implicitHeight: room + Math.ceil(m.height) + 1
    acceptsInput: false                 // never takes clicks

    // 0 hidden .. 1 shown: the spring and the content's opacity; scale 0.9 + 0.1 x (Reduce motion: no scale, Theme.travel)
    property real shownness: 0
    // the glass at opacity^2 both ways. R3.4 over grey 127 (MOTION-AUDIT.md "HUD, Round R3.4"), interior darkening
    // against the spring value: appear o^2 rms .054 vs o .177, hide o^2 .050; relay #18's appear alpha fits o^2 at .017
    // (MAC-ANSWERS.md REA section 1). verify/A hud-appear-fit.json tied o and o^2 (.0097-.0173 vs .012-.013), but its
    // alpha mixes glass and content. Also no jump when a press brings back a hiding HUD (was o^2 -> o).
    // No extra factor while animating: the Mac's whole glass steps about 3 % at o .99 (R5.1 saw 2 levels in the rows
    // under the bar), and the plugin already draws .95-.98 of the asked alpha between .5 and .95. On screen against the
    // R3.4 clip (top anchor, 3 runs): o^2 rms .021, x .97 below .99 .028, R5.1's x .925 .046 (MOTION-AUDIT.md "HUD",
    // "Round J20"; R5.1's .925 was fitted about the capsule's centre)
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
            // fresh: everything starts where it should be, then waits for the hosting delay (Hud.motion.showDelay)
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
    }
    function disappear() {
        delay.stop();
        if (shownness <= 0) { motion.stop(); mapped = false; return; }
        motion.spring = mo.hide;
        motion.cutAt = mo.hideSeconds;
        motion.go(0);
    }
    // the glass follows the scale, re-measured in the frame that draws it (settleGlass() runs on Qt's 16 ms timer)
    // (on the scaled item's own scale, not on shownness: a handler on shownness may run before the scale binding
    // updates, so the glass trailed by a frame; the alert had exactly that, MOTION-AUDIT.md follow-up)

    Timer { id: delay; interval: win.mo.showDelay; onTriggered: win.begin() }
    FrameSpring {
        id: motion
        target: win
        property: "shownness"
        onFinished: if (!Hud.shown) win.mapped = false
    }

    // the scaled frame: the capsule plus the anchorAbove above it, scaled about its top centre
    Item {
        id: scaled
        x: win.width - width            // the capsule ends exactly `gap` from the screen edge
        y: win.room - win.mo.anchorAbove
        width: win.m.width
        height: win.mo.anchorAbove + win.m.height
        transformOrigin: Item.Top
        scale: 1 - Theme.travel(1 - win.mo.appearScale) * (1 - win.shownness)
        onScaleChanged: win.glassMoved()

        Item {
            id: capsule
            y: win.mo.anchorAbove
            width: win.m.width
            height: win.m.height

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
                // the spring value itself, from the first frame: glyph o^1.06, bar o^0.90 on the Mac (3 clips, top anchor;
                // MOTION-AUDIT.md "HUD", "Round J20"). Its faint first frames (bar +4 levels at t0 + 18 ms) are the HUD's
                // first visible frame, 18 ms after the pop
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
        g[name] = { paths: paths, baselineY: baselineY, left: left, centre: HudLib.inkCentre(paths) };
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
        property var scales: []       // scale per path about the glyph's ink centre (default 1): the bounce, by layer
        readonly property var g: win.glyphs[name]
        // ink centre in the layer's coordinates (a bounce turns about it)
        readonly property real cx: g ? x + g.centre.x * win.glyphScale : 0
        readonly property real cy: g ? y + g.centre.y * win.glyphScale : 0
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
                // p -> glyphScale x (c + s x (p - c)), c the ink centre in the path's units
                readonly property real s: glyph.scales[index] ?? 1
                x: win.glyphScale * glyph.g.centre.x * (1 - s)
                y: win.glyphScale * glyph.g.centre.y * (1 - s)
                transform: Scale { xScale: win.glyphScale * s; yScale: win.glyphScale * s }
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
        onLevelChanged: {
            if (win.mapped) fill.go(level * win.m.barLength); else fill.snap(level * win.m.barLength);
            // the glyph bounces when a step brings the level onto 0 or 1 (lib/hud.js bouncesAt, SystemBannerUI
            // SymbolEffectState); a fresh HUD does not (its glyph view is made with the new seed: inferred, a discrete
            // symbol effect plays on a change of its value), nor a step that leaves the level at the end
            const hit = HudLib.bouncesAt(seenLevel, level);
            seenLevel = level;
            if (hit && active && win.mapped && win.shownness > 0) bounce.play();
        }
        property real seenLevel: -1
        // SF Symbols .bounce, default options (BounceSymbolEffect(), SymbolEffectOptions.default): HyprK SymbolBounce,
        // the curve of the Control Center slider's end glyphs (INTERACTIVE-GLASS-REA.md 3). The speaker bounces by
        // layer (Hud.motion.bounceStagger, R11.4 clips); the sun's bounce is not recorded: whole glyph, as before
        SymbolBounce {
            id: bounce
            name: "sun.max.fill"
            amp: lay.volume ? win.mo.bounceAmp : Motion.symbolBounceAmp(name)
            layers: lay.volume ? 4 : 1
            stagger: lay.volume ? win.mo.bounceStagger : 0
            reduceMotion: A11y.reduceMotion
        }
        function snap() { crossfade.snap(active ? 1 : 0); fill.snap(level * win.m.barLength); }
        property real fillLength: 0
        SpringCurve { id: crossfade; target: lay; property: "opacity"; spring: win.mo.content }
        SpringCurve { id: fill; target: lay; property: "fillLength"; spring: win.mo.content }

        // Glyph. Volume: speaker.wave.1 / .2 / .3 are one drawing, speaker.wave.3.fill with 1, 2 or 3 of its waves
        // (the same paths on the same baseline: wave.2's body and waves are wave.3's 1.53 units higher on a canvas
        // whose baseline is 1.5 higher), and speaker.slash.fill. A change of symbol shows in one frame, no fade (R11.4
        // clips: 3 -> 2 waves, 2 -> 1 and 1 wave -> slash each complete in a single frame, the frame before the fill
        // starts to move; was a fade on the content spring, inferred). Volume <-> brightness still cross-fades (above).
        readonly property bool volume: symbol !== "sun.max.fill"
        readonly property bool slashed: symbol === "speaker.slash.fill"
        readonly property int waveCount: symbol === "speaker.wave.1.fill" ? 1 : symbol === "speaker.wave.2.fill" ? 2
                                         : symbol === "speaker.wave.3.fill" ? 3 : 0

        Loader {
            active: !lay.volume
            sourceComponent: Glyph {
                name: "sun.max.fill"
                scales: [bounce.value, bounce.value]
            }
        }
        Loader {
            active: lay.volume
            sourceComponent: Item {
                // layers in the Mac's order: speaker, then the waves from the inside out
                Glyph {
                    name: "speaker.wave.3.fill"
                    visible: !!g && !lay.slashed
                    ops: [1, lay.waveCount >= 1 ? 1 : 0, lay.waveCount >= 2 ? 1 : 0, lay.waveCount >= 3 ? 1 : 0]
                    scales: [bounce.at(0), bounce.at(1), bounce.at(2), bounce.at(3)]
                }
                // the slash leads, the speaker follows (paths: speaker, slash)
                Glyph {
                    name: "speaker.slash.fill"
                    visible: !!g && lay.slashed
                    scales: [bounce.at(1), bounce.at(0)]
                }
            }
        }

        // empty dashes: plus-lighter, the glass under them + 28 (Hud.metrics.emptyLift); only the coverage of the white
        // is used, the output alpha is 0 so the premultiplied blend adds (shaders/plustext.frag, as StatusModulePanel)
        Bar {
            color: "#FFFFFF"
            width: win.m.barLength
            layer.enabled: true
            layer.effect: ShaderEffect {
                property real lift: win.m.emptyLift
                fragmentShader: Qt.resolvedUrl("../shaders/plustext.frag.qsb")
            }
        }
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
