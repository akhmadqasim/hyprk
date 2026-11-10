import QtQuick
import QtTest
import "../HyprK/controls.js" as G

// Control geometry per size against the 27.2.1 control gallery (reference/re/MAC-ANSWERS.md Q-settings-15..-22,
// re/27.2.1/live/controls/controls-light.json frames).
TestCase {
    name: "HyprKGeometry"

    function test_push() {
        compare(G.push("regular"), { height: 24, radius: 6, padding: 12 });
        compare(G.push("small"), { height: 20, radius: 5, padding: 10 });
        compare(G.push("mini"), { height: 16, radius: 4, padding: 8 });
        compare(G.push("large"), { height: 28, radius: 14, padding: 14 });
        compare(G.push("bogus").height, 24);
    }
    function test_switch_knob_frames() {
        // knob layer frames in the gallery: off x 2, on x 20 (regular); small on 16; mini on 13.5 (track at 9)
        const r = G.switchTrack("regular"), s = G.switchTrack("small"), m = G.switchTrack("mini");
        compare([r.width, r.height, r.knobWidth, r.knobHeight], [54, 24, 32, 20]);
        compare(G.switchKnobX(r, 0), 2);
        compare(G.switchKnobX(r, 1), 20);
        compare(G.switchKnobX(s, 1), 16);
        compare([m.width, m.height, m.knobWidth, m.knobHeight], [36, 16, 21, 13]);
        compare(G.switchKnobX(m, 1), 13.5);
        compare(G.switchKnobX(m, 0), 1.5);
    }
    function test_checkbox() {
        compare(G.checkbox("regular"), { size: 16, radius: 5.5, dot: 5 });
        compare(G.checkbox("small").size, 14);
        compare(G.checkbox("mini"), { size: 12, radius: 3.5, dot: 4 });
        compare(G.checkbox("large").radius, 6.5);
    }
    function test_slider_ticks() {
        // 220 wide, 5 ticks: dots at x 9, 59, 109, 159, 209 (2 wide), y 14
        const m = G.slider("regular");
        compare(m.track, 6); compare(m.tickY, 14);
        const xs = [0, 1, 2, 3, 4].map(i => G.tickX(220, m.knobWidth, i, 5) - m.tick / 2);
        compare(xs, [9, 59, 109, 159, 209]);
        compare(G.slider("small").track, 4); compare(G.slider("mini").height, 12);
    }
}
