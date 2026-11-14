import QtQuick
import QtTest
import HyprK

// The traffic lights' press (Tokens.lights.lift*, FlexInteraction windowControl): lift with a bounce from mouse-down,
// the same spring back after mouse-up, a click still acts, press-drag-out does not, nothing moves at rest.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -import ui -input ui/tests
Item {
    id: root
    width: 200; height: 60

    property int closes: 0
    TrafficLights {
        id: tl
        x: 20; y: 20
        onCloseClicked: root.closes++
    }

    TestCase {
        name: "TrafficLights"
        when: windowShown

        function light(i) { return tl.children[i]; }

        function test_press_bounces_and_returns() {
            const red = light(0);
            compare(red.pressScaleX, 1);
            mousePress(red, 7, 7);
            let peak = 1;
            for (let i = 0; i < 40; i++) { wait(10); peak = Math.max(peak, red.pressScaleX); }
            // the lift is 16 / 14; the 0.355 s / 0.4 spring overshoots it (to about 1.18)
            verify(peak > 16 / 14 + 0.02, "overshoot: " + peak);
            verify(peak < 1.2, "peak " + peak);
            tryVerify(() => Math.abs(red.pressScaleX - 16 / 14) < 0.002, 2000);
            compare(red.pressScaleX, red.pressScaleY);        // a press without travel is uniform
            mouseRelease(red, 7, 7);
            let low = 2;
            for (let i = 0; i < 40; i++) { wait(10); low = Math.min(low, red.pressScaleX); }
            verify(low < 0.99, "undershoot after the release: " + low);
            tryVerify(() => red.pressScaleX === 1 && red.pressScaleY === 1, 2000);
            compare(root.closes, 1);                          // the click acted
        }

        function test_drag_out_leans_and_cancels() {
            const red = light(0);
            const before = root.closes;
            mousePress(red, 7, 7);
            mouseMove(red, 60, 7);                            // 53 pt right, outside the light
            tryVerify(() => red.pressScaleX > red.pressScaleY + 0.01, 2000);   // stretched along the drag
            mouseRelease(red, 60, 7);
            tryVerify(() => red.pressScaleX === 1, 2000);
            compare(root.closes, before);                     // released outside: no action
        }
    }
}
