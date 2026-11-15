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
    property int zooms: 0
    TrafficLights {
        id: tl
        x: 20; y: 20
        active: true            // a key window: the lights keep their colour when the pointer leaves
        onCloseClicked: root.closes++
        onZoomClicked: root.zooms++
        onFullScreenClicked: root.zooms++
    }

    TestCase {
        name: "TrafficLights"
        when: windowShown

        function light(i) { return tl.children[i]; }
        function glyph(i) { return findChild(light(i), "glyph"); }

        // R6.4 (LIGHTS-REA section 10): a disabled zoom lifts 14 -> 16 pt in one frame when pressed, never looks pressed,
        // never shows a glyph and does nothing on release; back on the usual spring with its undershoot (the Mac dips
        // 31 % of the lift under rest at 0.18 s)
        function test_disabled_zoom_lifts_in_one_frame() {
            const green = light(2);
            compare(green.modelData.k, "zoom");
            tl.zoomEnabled = false;
            mouseMove(green, 7, 7);
            wait(250);                                        // the other glyphs are in by now
            compare(glyph(2).opacity, 0);
            verify(glyph(0).opacity > 0.99);
            mousePress(green, 7, 7);
            verify(Math.abs(green.pressScaleX - 16 / 14) < 1e-6, "lift at once: " + green.pressScaleX);
            compare(green.pressScaleX, green.pressScaleY);
            compare(green.down, false);
            compare(green.pressMix, 0);
            wait(200);
            verify(Math.abs(green.pressScaleX - 16 / 14) < 1e-6);   // held unchanged
            mouseRelease(green, 7, 7);
            let low = 2;
            for (let i = 0; i < 40; i++) { wait(10); low = Math.min(low, green.pressScaleX); }
            verify(low < 0.99, "undershoot after the release: " + low);
            tryVerify(() => green.pressScaleX === 1, 2000);
            compare(root.zooms, 0);
            tl.zoomEnabled = true;
            mouseMove(root, 190, 55);
        }

        // R6.4: an inactive window's lights take their colour and full glyphs on the first hovered frame; a pressed
        // light lifts in one frame in the (lighter) pressed look and acts on release
        function test_inactive_window_glyphs_at_once() {
            const red = light(0);
            tl.active = false;
            mouseMove(root, 190, 55);
            wait(50);
            compare(glyph(0).opacity, 0);
            mouseMove(red, 7, 7);
            compare(glyph(0).opacity, 1);                     // no 70 ms wait, no fade
            compare(glyph(1).opacity, 1);
            const before = root.closes;
            mousePress(red, 7, 7);
            verify(Math.abs(red.pressScaleX - 16 / 14) < 1e-6, "lift at once: " + red.pressScaleX);
            compare(red.pressMix, 1);
            mouseRelease(red, 7, 7);
            compare(root.closes, before + 1);
            tryVerify(() => red.pressScaleX === 1, 2000);
            mouseMove(root, 190, 55);
            wait(30);
            verify(glyph(0).opacity < 1, "the fade-out still runs: " + glyph(0).opacity);
            tryCompare(glyph(0), "opacity", 0, 500);
            tl.active = true;
        }

        function test_press_bounces_and_returns() {
            const red = light(0);
            const before = root.closes;
            compare(red.pressScaleX, 1);
            mousePress(red, 7, 7);
            let peak = 1;
            for (let i = 0; i < 40; i++) { wait(10); peak = Math.max(peak, red.pressScaleX); }
            // the lift is 16 / 14; the measured spring (0.31 s / 0.5, LIGHTS-REA section 9) overshoots it to 16.33 pt
            // (1.166), less than the decoded 0.355 / 0.4's 16.51 (1.18)
            verify(peak > 16 / 14 + 0.015, "overshoot: " + peak);
            verify(peak < 16.45 / 14, "peak " + peak);
            tryVerify(() => Math.abs(red.pressScaleX - 16 / 14) < 0.002, 2000);
            compare(red.pressScaleX, red.pressScaleY);        // a press without travel is uniform
            mouseRelease(red, 7, 7);
            let low = 2;
            for (let i = 0; i < 40; i++) { wait(10); low = Math.min(low, red.pressScaleX); }
            verify(low < 0.99, "undershoot after the release: " + low);
            tryVerify(() => red.pressScaleX === 1 && red.pressScaleY === 1, 2000);
            compare(root.closes, before + 1);                 // the click acted
        }

        function test_drag_out_leans_and_cancels() {
            const red = light(0);
            const before = root.closes;
            mousePress(red, 7, 7);
            compare(red.pressMix, 1);                         // the pressed look at once
            mouseMove(red, 60, 7);                            // 53 pt right, outside the light
            wait(30);
            compare(red.pressMix, 1);                         // held for leaveFadeDelay (80 ms, measured)
            wait(110);
            // then it leaves on a 0.5 s critically damped fade (Tokens.lights.leaveFade, measured)
            verify(red.pressMix > 0.5 && red.pressMix < 1, "leave fade: " + red.pressMix);
            tryVerify(() => red.pressMix === 0, 2000);
            tryVerify(() => red.pressScaleX > red.pressScaleY + 0.01, 2000);   // stretched along the drag
            mouseRelease(red, 60, 7);
            tryVerify(() => red.pressScaleX === 1, 2000);
            compare(root.closes, before);                     // released outside: no action
        }
    }
}
