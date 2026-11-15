import QtQuick
import "motion.js" as Motion

// SF Symbols `.bounce` on a glyph (motion.js symbolBounce; INTERACTIVE-GLASS-REA.md 3): play() runs the scale
// 1 -> peak (0.217 s) -> trough (0.433 s) -> 1 (0.583 s), one value per frame (FrameClock). Bind the glyph's `scale`
// to `value` (Item.scale turns about the item's centre, as the Mac's glyph does: its ink centre stays within 0.5 px).
// `name`: the SF Symbol, for its measured amplitude. A play() while one runs starts it again (the Mac's behaviour for a
// second trigger within 0.58 s was not captured). Reduce Motion: no bounce (not measured on the Mac).
// By layer (the volume HUD's speaker, MOTION-REA "Round R11.4"; the sliders' end glyphs, INTERACTIVE-GLASS-REA.md 8):
// the Mac runs the same curve on every layer of the symbol about the symbol's centre, each layer `stagger` seconds
// after the one before. `layers` and `stagger` come from `name` (motion.js symbolBounceLayers); bind layer k's scale to
// at(k), or a per-path list to `scales` (path order of the outline data). `amp` overrides the [peak, trough] of `name`.
Item {
    id: b
    visible: false
    width: 0
    height: 0
    property string name: ""
    property bool reduceMotion: Tokens.reduceMotion
    property var amp: Motion.symbolBounceAmp(name)
    readonly property var _amp: amp
    property int layers: Motion.symbolBounceLayers(name)
    property real stagger: layers > 1 ? Motion.symbolBounceStagger : 0
    // the scale of each path of `name` (a one-layer symbol: [value])
    readonly property var scales: Motion.symbolBounceLayerOf(name).map(k => at(k))
    // seconds since play(), -1 when idle
    property real t: -1
    function at(k: int): real { return t < 0 ? 1 : Motion.symbolBounce(t - k * stagger, _amp[0], _amp[1]); }
    property real value: 1
    readonly property bool running: clock.running
    function play(): void {
        if (reduceMotion) return;
        clock.stop();
        value = 1;
        t = 0;
        clock.start();
    }
    FrameClock {
        id: clock
        watchdog: true
        onTick: {
            const t = elapsed / 1000;
            b.t = t;
            b.value = Motion.symbolBounce(t, b._amp[0], b._amp[1]);
            if (t >= 0.58333 + b.stagger * Math.max(0, b.layers - 1)) { b.value = 1; b.t = -1; stop(); }
        }
        onStalled: { b.value = 1; b.t = -1; stop(); }
    }
}
