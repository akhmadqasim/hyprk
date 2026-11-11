import QtQuick
import QtTest
import "../HyprK"
import "../HyprK/rubberband.js" as RB

// Rubber-band maths (rubberband.js) against the Mac's numbers (MAC-ANSWERS.md "Rubber-band scroll constants"),
// and the fitted easings evaluated by Qt itself (AnimationController steps the real NumberAnimation).
Item {
    id: root
    width: 200; height: 200
    property real val: 0
    NumberAnimation { id: probe; target: root; property: "val" }
    AnimationController { id: ctl; animation: probe }

    // value of a plan segment at time t (s) through Qt's easing
    function qtAt(seg, t) {
        probe.from = seg.from; probe.to = seg.to; probe.duration = Math.round(seg.duration * 1000);
        if (seg.quart || !seg.curve) probe.easing.type = Easing.OutQuart;
        else { probe.easing.type = Easing.BezierSpline; probe.easing.bezierCurve = seg.curve; }
        ctl.reload();
        ctl.progress = Math.min(1, t / seg.duration);
        return root.val;
    }

    TestCase {
        name: "RubberBand"
        when: windowShown

        function test_constants() {
            compare(RB.STIFFNESS, 20);
            compare(RB.MIN_DELTA_BEFORE_STRETCH, 10);
            compare(RB.C_TRACKPAD, 0.075);
            compare(RB.RATE, 12.5);
        }
        function test_decay_mac_numbers() {
            const mac = [[0.05, 53.5], [0.1, 28.7], [0.2, 8.2], [0.3, 2.4], [0.4, 0.67], [0.5, 0.19]];
            for (const [t, x] of mac) fuzzyCompare(RB.decay(100, 0, t), x, 0.05);
            compare(RB.decay(100, 0, 0), 100);
        }
        function test_linear_and_hyperbolic() {
            // D <= 0 falls back to the classic d / stiffness
            compare(RB.elastic(100, 0), 5);
            compare(RB.rebound(5, 0), 100);
            // D (1 - 1/(1 + |d| c / D)): D 500, d 100 -> 500 (1 - 1/1.015)
            fuzzyCompare(RB.elastic(100, 500), 500 * (1 - 1 / 1.015), 1e-9);
            fuzzyCompare(RB.elastic(-100, 500), -500 * (1 - 1 / 1.015), 1e-9);
            // starts at slope c, never reaches D, and rebound is its inverse
            fuzzyCompare(RB.elastic(0.001, 500) / 0.001, 0.075, 1e-4);
            verify(RB.elastic(1e7, 500) < 500);
            for (const d of [1, 10, 100, 1000, -250]) fuzzyCompare(RB.rebound(RB.elastic(d, 500), 500), d, 1e-6);
            compare(RB.rebound(600, 500), 500 * 999 / 0.075);
        }
        function test_filter_probe() {
            // MAC-ANSWERS "Which rubber-band model": D 600, d 15/50/100/200/300/400/500 -> 1/3/7/14/21/28/35 pt
            const d = [15, 50, 100, 200, 300, 400, 500], mac = [1, 3, 7, 14, 21, 28, 35];
            for (let i = 0; i < d.length; i++) compare(RB.stretch(d[i], 600), mac[i]);
            compare(RB.stretch(-100, 600), -7);
        }
        function test_step_min_delta_then_stretch() {
            // at the top edge (lo 0) pulling up 6 + 6 pt: nothing for the first 10 pt, then the whole 12 pt count
            let r = RB.step(0, -6, 0, 1000, 600, 0);
            compare(r.pos, 0); compare(r.pull, -6);
            r = RB.step(r.pos, -6, 0, 1000, 600, r.pull);
            compare(r.pull, -12);
            compare(r.pos, RB.stretch(-12, 600));
            // more pull accumulates: 112 pt in all -> floor(8.27)
            const r2 = RB.step(r.pos, -100, 0, 1000, 600, r.pull);
            compare(r2.pos, -8);
            // pushing back in: the pull is undone first, the rest scrolls 1:1
            const r3 = RB.step(r2.pos, 150, 0, 1000, 600, r2.pull);
            compare(r3.pos, 38); compare(r3.pull, 0);
            // at the bottom edge too; inside the bounds deltas are 1:1
            compare(RB.step(1000, 300, 0, 1000, 600, 0).pos, 1021);
            compare(RB.step(300, 25, 0, 1000, 600, 0).pos, 325);
        }
        function test_return_curve_through_qt() {
            const plan = RB.planReturn(0, -100, 0);
            compare(plan.length, 1);
            fuzzyCompare(RB.restTime(100, 0), 0.42, 0.011);  // AppKit: |x| < 0.5 pt from 0.42 s (bisected to 0.01 s)
            fuzzyCompare(plan[0].duration, 0.61, 0.011);     // ours runs on to 0.05 pt
            const mac = [[0.05, 53.5], [0.1, 28.7], [0.2, 8.2], [0.3, 2.4], [0.4, 0.67]];
            for (const [t, x] of mac) fuzzyCompare(-qtAt(plan[0], t), x, 0.1);
            compare(qtAt(plan[0], plan[0].duration), 0);
        }
        function test_return_with_velocity() {
            // still moving outwards at release: it goes further out first (x0 + 0.31 v t) e^(-12.5 t)
            const plan = RB.planReturn(0, -20, 1000);
            verify(RB.decay(20, 1000, 0.03) > 20);
            fuzzyCompare(-qtAt(plan[0], 0.03), RB.decay(20, 1000, 0.03), 0.2);
            fuzzyCompare(-qtAt(plan[0], 0.15), RB.decay(20, 1000, 0.15), 0.1);
        }
        function test_momentum_quartic() {
            // Cates: T = (v / 4000)^(1/3), distance = 1000 T^4, so v(0) = 4 distance / T
            fuzzyCompare(RB.momentumDuration(4000), 1, 1e-9);
            fuzzyCompare(RB.momentumDistance(4000), 1000, 1e-9);
            fuzzyCompare(RB.momentumVelocity(4000, 0), 4000, 1e-9);
            const plan = RB.planMomentum(0, 1000, 0, 1e6);
            compare(plan.length, 1);
            verify(plan[0].quart);
            for (const t of [0.1, 0.3, 0.5]) fuzzyCompare(qtAt(plan[0], t), RB.momentumAt(1000, t), 0.01);
            // a tiny flick does not move
            compare(RB.planMomentum(0, 10, 0, 1000).length, 0);
        }
        function test_momentum_hits_edge_and_bounces() {
            const plan = RB.planMomentum(100, 3000, 0, 300);
            compare(plan.length, 3);
            compare(plan[0].to, 300);
            fuzzyCompare(qtAt(plan[0], plan[0].duration / 2), 100 + RB.momentumAt(3000, plan[0].duration / 2), 0.3);
            // peak 1 / 12.5 s after the edge: 0.31 vE / (12.5 e)
            const vE = RB.momentumVelocity(3000, plan[0].duration);
            fuzzyCompare(plan[1].to - 300, 0.31 * vE / (12.5 * Math.E), 1e-6);
            fuzzyCompare(qtAt(plan[1], 0.04), 300 + RB.decay(0, vE, 0.04), 0.3);
            fuzzyCompare(qtAt(plan[2], 0.12), 300 + RB.decay(0, vE, 0.2), 0.1);
            compare(qtAt(plan[2], plan[2].duration), 300);
            // upwards too
            const up = RB.planMomentum(50, -3000, 0, 300);
            compare(up[0].to, 0);
            verify(up[1].to < 0);
        }
    }
}
