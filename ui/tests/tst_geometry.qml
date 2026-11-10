import QtQuick
import QtTest
import HyprK
import "../HyprK/controls.js" as G
import "../HyprK/motion.js" as M

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
    // PC #60 section 4 (probe-switch-knob-series-dark.json, 60 Hz): from the start of movement 50 % at about 0.10 s,
    // the end at about 0.233 s, peak +4.2 % at about 0.33 s. The Mac then snaps the last 1.8 % home at about 0.45 s
    // (36.32 -> 36 in the series); the spring here gets within 1 % by 0.49 s instead. Stepped at 60 Hz as drawn.
    function test_switch_travel_curve() {
        const r = Tokens.motion.switchTravelResponse, d = Tokens.motion.switchTravelDamping, dt = 1 / 60;
        let x = 0, v = 0, t50 = -1, tEnd = -1, peak = 0, tPeak = 0, settled = -1;
        for (let i = 1; i <= 60; i++) {
            [x, v] = M.springStep(x, v, 1, r, d, dt);
            const t = i * dt;
            if (t50 < 0 && x >= 0.5) t50 = t;
            if (tEnd < 0 && x >= 1) tEnd = t;
            if (x > peak) { peak = x; tPeak = t; }
            if (Math.abs(x - 1) > 0.01) settled = -1; else if (settled < 0) settled = t;
        }
        verify(Math.abs(t50 - 0.100) <= 0.017, "50 % at " + t50);
        verify(Math.abs(tEnd - 0.233) <= 0.025, "end at " + tEnd);
        verify(peak > 1.035 && peak < 1.047, "peak " + peak);
        verify(Math.abs(tPeak - 0.33) <= 0.035, "peak at " + tPeak);
        verify(settled > 0 && settled <= 0.5, "within 1 % at " + settled);
    }
    // press lens: CAMediaTimingFunction easeInEaseOut over 0.20 s, no delay
    function test_switch_lens_timing() {
        compare(Tokens.motion.switchLensIn, 200);
        compare(Tokens.motion.switchLensCurve.slice(0, 4), [0.42, 0, 0.58, 1]);
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
