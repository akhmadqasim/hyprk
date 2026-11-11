import QtQuick
import QtTest
import HyprK

// Controlled controls: the caller's binding survives a user change.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -import ui -input ui/tests
Item {
    id: root
    width: 400; height: 300

    QtObject {
        id: backend
        property bool on: false
        property int index: 0
        property real level: 0.2
    }

    Switch {
        id: sw
        x: 20; y: 20
        checked: backend.on
        onToggled: v => backend.on = v
    }
    Switch {
        id: mini
        x: 120; y: 20
        controlSize: "mini"
    }
    Switch {
        id: refusing          // a caller that rejects the change: the switch stays as it was
        x: 20; y: 60
        checked: false
    }
    Popup {
        id: pop
        x: 200; y: 150; width: 120
        model: ["A", "B", "C"]
        currentIndex: backend.index
        onActivated: i => backend.index = i
    }
    Slider {
        id: sl
        x: 20; y: 240; width: 200
        value: backend.level
        onMoved: v => backend.level = v
    }

    ToolbarHighlight {
        id: light
        x: 20; y: 100; width: 200; height: 37
        centres: [18.5, 55.5]
    }
    PressSpring { id: capLift; w: 78; h: 37 }
    GlassButton { id: flexBtn; x: 300; y: 150; width: 78; height: 37 }
    GlassButton { id: pairBtn; x: 300; y: 200; width: 74; height: 37; segments: [37, 37] }

    SignalSpy { id: toggledSpy; target: refusing; signalName: "toggled" }
    SignalSpy { id: movedSpy; target: sl; signalName: "moved" }
    SignalSpy { id: releasedSpy; target: sl; signalName: "released" }
    SignalSpy { id: committedSpy; target: sl; signalName: "committed" }

    TestCase {
        name: "HyprKControls"
        when: windowShown

        function test_switch_keeps_binding() {
            mouseClick(sw);
            compare(backend.on, true);
            compare(sw.checked, true);
            backend.on = false;              // external change still reaches the switch
            compare(sw.checked, false);
        }
        function test_switch_does_not_write_checked() {
            mouseClick(refusing);
            compare(toggledSpy.count, 1);
            compare(toggledSpy.signalArguments[0][0], true);
            compare(refusing.checked, false);
        }
        // NSSwitch 27.2.1 (Switch.qml): click, long press, drags
        function test_switch_long_press_toggles_on_release() {
            backend.on = false;
            mousePress(sw, 12, 12);
            wait(1000);
            compare(backend.on, false);          // nothing while held
            mouseRelease(sw, 12, 12);
            compare(backend.on, true);           // the Mac probe: held 0.77-0.80 s, flips at the release
            backend.on = false;
        }
        function test_switch_release_off_track_keeps_state() {
            backend.on = false;
            mousePress(sw, 12, 12);
            mouseMove(sw, 12, 60);
            mouseRelease(sw, 12, 60);            // same half, below the track: no toggle
            compare(backend.on, false);
        }
        function test_switch_drag_past_middle() {
            backend.on = false;
            mousePress(sw, 12, 12);              // on the knob's half
            mouseMove(sw, 24, 12);
            compare(backend.on, false);          // short of the middle (27)
            mouseMove(sw, 30, 12);
            compare(backend.on, false);          // the state waits for the release
            mouseRelease(sw, 30, 12);
            compare(backend.on, true);
            backend.on = false;
        }
        function test_switch_drag_across_and_back() {
            backend.on = false;
            mousePress(sw, 12, 12);
            mouseMove(sw, 40, 12);
            mouseMove(sw, 12, 12);
            mouseRelease(sw, 12, 12);            // back on the start side: no change, and no click toggle
            compare(backend.on, false);
        }
        function test_switch_small_drag_is_a_click() {
            backend.on = false;
            mousePress(sw, 10, 12);
            mouseMove(sw, 18, 12);               // 8 pt, never past the middle
            mouseRelease(sw, 18, 12);
            compare(backend.on, true);
            backend.on = false;
        }
        function test_switch_drag_from_empty_half() {
            backend.on = false;
            mousePress(sw, 30, 12);              // empty half: flips after 0.4 x 54 = 21.6 pt towards "on"
            mouseMove(sw, 45, 12);
            mouseMove(sw, 50, 12);
            mouseRelease(sw, 50, 60);            // released off the track, 20 pt along: still off
            compare(backend.on, false);
            mousePress(sw, 30, 12);
            mouseMove(sw, 53, 12);               // 23 pt: the knob has flipped
            mouseRelease(sw, 53, 60);
            compare(backend.on, true);
            backend.on = false;
        }
        function knobOf(c) {
            for (let i = 0; i < c.children.length; i++) if (c.children[i].restW !== undefined) return c.children[i];
            return null;
        }
        function test_switch_sizes() {
            compare(sw.width, 54); compare(sw.height, 24);
            compare(mini.width, 36); compare(mini.height, 16);
            const k = knobOf(mini);
            compare(k.width, 21); compare(k.height, 13);
            compare(k.x, 1.5);                       // off: 1.5 pt inset
        }
        // PC #60 section 4: the knob grows x1.56 from the mouse-down frame, easeInEaseOut 0.20 s (half at 0.10 s),
        // no overshoot, then shrinks on release. Sampled every 10 ms (the test clock is coarse: a sample can land a
        // frame late).
        function test_switch_press_lens() {
            const k = knobOf(refusing);
            mousePress(refusing);
            let peak = 0, early = -1;
            for (let t = 0; t < 400; t += 10) {
                wait(10);
                peak = Math.max(peak, k.width);
                if (early < 0 && t >= 100) early = k.width;
            }
            verify(early > 33 && early < 46, "width near 0.11 s: " + early);
            fuzzyCompare(peak, 32 * 1.56, 0.05);     // no overshoot past 49.9
            mouseRelease(refusing);
            tryCompare(k, "width", 32, 1000);
        }
        // the knob runs 4 % past the end before it settles (+0.75 pt on 18), it is not squashed
        function test_switch_overshoot() {
            const k = knobOf(sw);
            backend.on = false;
            tryCompare(k, "x", 2, 1000);
            backend.on = true;
            let maxX = 0;
            for (let t = 0; t < 600; t += 10) { wait(10); maxX = Math.max(maxX, k.x); }
            verify(maxX > 20.4 && maxX < 21, "max knob x " + maxX);
            compare(k.width, 32);
            fuzzyCompare(k.x, 20, 0.05);
        }
        function test_slider_press_lens() {
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            mousePress(sl, cx, sl.height / 2);
            tryCompare(k, "width", 25, 1000);
            compare(k.height, 20);
            mouseRelease(sl, cx, sl.height / 2);
            tryCompare(k, "width", 20, 1000);
        }
        // user report: pressing a slider's knob without moving must not move it or write a value
        function test_slider_press_without_move() {
            backend.level = 0.3;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            movedSpy.clear(); releasedSpy.clear(); committedSpy.clear();
            mousePress(sl, cx + 6, sl.height / 2);          // off-centre, still on the 20 pt knob
            tryCompare(k, "width", 25, 1000);
            fuzzyCompare(k.x + k.width / 2, cx, 0.01);      // grown around its centre
            compare(backend.level, 0.3);
            mouseRelease(sl, cx + 6, sl.height / 2);
            compare(movedSpy.count, 0); compare(releasedSpy.count, 0); compare(committedSpy.count, 0);
            compare(backend.level, 0.3);
            tryCompare(k, "width", 20, 1000);
            fuzzyCompare(k.x + k.width / 2, cx, 0.01);
            mousePress(sl, cx + 6, sl.height / 2);          // and a real drag keeps the grab offset
            mouseMove(sl, cx + 16, sl.height / 2);
            fuzzyCompare(backend.level, 0.3 + 10 / tr.usable, 0.001);
            mouseRelease(sl, cx + 16, sl.height / 2);
            compare(releasedSpy.count, 1); compare(committedSpy.count, 1);
            compare(sl.releaseModifiers, Qt.NoModifier);
        }
        // Control Center reads Shift at the release (it inverts the volume pop): the modifiers of the let-go
        // macOS (the 23.09.23 recording, frames 2622-2645): a press on the slider's track moves the knob and the value
        // on mouse-DOWN, not at the release; the release only commits
        function test_slider_track_press_changes_on_press() {
            backend.level = 0.1;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            movedSpy.clear(); committedSpy.clear();
            mousePress(sl, sl.width - 20, sl.height / 2);
            verify(movedSpy.count >= 1, "moved on press");
            verify(backend.level > 0.8, "value on press " + backend.level);
            compare(committedSpy.count, 0);
            mouseRelease(sl, sl.width - 20, sl.height / 2);
            compare(committedSpy.count, 1);
        }
        // FlexInteraction lift: the longer side grows 2.5 pt below 120 pt (GLASS-INTERACTION.md), released without overshoot
        function test_press_lift_by_longer_side() {
            capLift.pressed = true;
            tryVerify(() => Math.abs(capLift.scale - 80.5 / 78) < 0.0005 && !capLift.moving, 2000);
            capLift.pressed = false;
            let min = 2;
            for (let t = 0; t < 600; t += 10) { wait(10); min = Math.min(min, capLift.scale); }
            verify(min > 0.9995, "no undershoot after the release: " + min);
            tryCompare(capLift, "scale", 1, 1000);
        }
        // FlexInteraction drag stretch (applyScale): a drag inside the pressed glass stretches it along the drag by
        // |d| / (4 * 60000) and shifts it toward the pointer by width * k; nothing at rest
        function test_press_drag_stretch() {
            compare(flexBtn.transform[2].x, 0);
            mousePress(flexBtn, 10, 18);
            mouseMove(flexBtn, 70, 18, -1, Qt.LeftButton);
            const k = 60 / 240000;
            tryVerify(() => Math.abs(flexBtn.transform[2].x - 78 * k) < 0.002, 2000);
            verify(flexBtn.transform[1].xScale > flexBtn.transform[1].yScale, "stretched along x");
            mouseRelease(flexBtn, 70, 18);
            tryVerify(() => flexBtn.transform[2].x === 0, 1000);
        }
        // two merged buttons: the pressed one lifts by its own 37 pt (2.5 pt), only its outer end moves (1.25 pt)
        function test_press_merged_pair_grows_outer_edge() {
            mousePress(pairBtn, 10, 18);
            tryVerify(() => Math.abs(pairBtn.transform[1].yScale - 39.5 / 37) < 0.001, 2000);
            const t = pairBtn.transform[1];
            const left = t.origin.x - t.origin.x * t.xScale, right = t.origin.x + (74 - t.origin.x) * t.xScale - 74;
            verify(Math.abs(left + 1.25) < 0.02, "left end out 1.25 pt: " + left);
            verify(Math.abs(right) < 0.001, "right end stays: " + right);
            mouseRelease(pairBtn, 10, 18);
            mousePress(pairBtn, 60, 18);
            tryVerify(() => Math.abs(pairBtn.transform[1].origin.x) < 0.001 && pairBtn.transform[1].xScale > 1.016, 2000);
            mouseRelease(pairBtn, 60, 18);
        }
        // pressed knob lens: light uses the Mac's B2 model (ring shadow 8 down, 4 wide, blur 3, .4; fill light), dark keeps
        // the recording's fit (no ring, no fill light)
        function test_knob_lens_light_model() {
            const was = Tokens.dark;
            Tokens.dark = false;
            compare(Tokens.control.knobLensRingOpacity, 0.4);
            compare(Tokens.control.knobLensFillLight, 1);
            compare(Tokens.control.knobLensGain, 1);
            compare(Tokens.control.knobLensHaze, 0.1);
            compare(Tokens.control.knobLensKeyTop, 0);
            Tokens.dark = true;
            compare(Tokens.control.knobLensRingOpacity, 0);
            compare(Tokens.control.knobLensFillLight, 0);
            compare(Tokens.control.knobLensKeyTop, 0.135);
            Tokens.dark = was;
        }
        // FlexInteraction glow: the press light follows the pointer and dims beyond 50 pt from where the press began
        function test_press_light_follows_pointer() {
            Tokens.dark = true;
            mousePress(light, 18, 18);
            tryVerify(() => light.glowGain > 0.3, 1000);
            fuzzyCompare(light.glowCentre.x, 18, 1);
            mouseMove(light, 60, 18);
            tryVerify(() => Math.abs(light.glowCentre.x - 60) < 1, 1000);
            const near = light.glowGain;
            mouseMove(light, 120, 18);                       // 102 pt from the press
            tryVerify(() => Math.abs(light.glowGain - near / 2) < 0.01, 2000);
            mouseRelease(light, 120, 18);
            tryCompare(light, "glowGain", 0, 2000);
            Tokens.dark = false;
        }
        function test_slider_release_modifiers() {
            backend.level = 0.3;
            let tr = null; for (let i = 0; i < sl.children.length; i++) if (sl.children[i].usable !== undefined) tr = sl.children[i];
            const k = knobOf(tr);
            const cx = k.x + k.width / 2;
            releasedSpy.clear();
            mousePress(sl, cx, sl.height / 2);
            mouseMove(sl, cx + 10, sl.height / 2);
            mouseRelease(sl, cx + 10, sl.height / 2, Qt.LeftButton, Qt.ShiftModifier);
            compare(releasedSpy.count, 1);
            verify(sl.releaseModifiers & Qt.ShiftModifier);
            sl.forceActiveFocus();
            keyClick(Qt.Key_Left);                          // an arrow key: no modifiers
            compare(releasedSpy.count, 2);
            compare(sl.releaseModifiers, Qt.NoModifier);
        }
        function test_popup_keeps_binding() {
            mouseClick(pop);                 // opens the menu (a click leaves it open)
            // the menu is lifted so the current row sits on the button (5 px padding cancels the 5 px lift)
            const row = Tokens.control.menuItemHeight;
            mouseClick(root, pop.x + pop.width - 30, pop.y - pop.currentIndex * row + 2 * row + row / 2);
            compare(backend.index, 2);
            compare(pop.currentIndex, 2);
            backend.index = 1;
            compare(pop.currentIndex, 1);
        }
        // -[NSSliderCell _moveInDirection:]: a twentieth per arrow, Page Up / Down to the ends, no Home / End, no modifiers
        function test_slider_arrow_keys() {
            backend.level = 0.5;
            sl.forceActiveFocus();
            movedSpy.clear(); releasedSpy.clear(); committedSpy.clear();
            keyClick(Qt.Key_Right);
            fuzzyCompare(backend.level, 0.55, 1e-9);
            keyClick(Qt.Key_Up);
            fuzzyCompare(backend.level, 0.6, 1e-9);
            keyClick(Qt.Key_Left); keyClick(Qt.Key_Down);
            fuzzyCompare(backend.level, 0.5, 1e-9);
            compare(movedSpy.count, 4); compare(releasedSpy.count, 4); compare(committedSpy.count, 4);
            keyClick(Qt.Key_Home); keyClick(Qt.Key_End); keyClick(Qt.Key_Right, Qt.ShiftModifier);
            fuzzyCompare(backend.level, 0.5, 1e-9);
            compare(movedSpy.count, 4);
            keyClick(Qt.Key_PageUp);
            compare(backend.level, 1);
            keyClick(Qt.Key_Right);                 // at the end: nothing to report
            compare(movedSpy.count, 5);
            keyClick(Qt.Key_PageDown);
            compare(backend.level, 0);
            sl.tickMarks = 5; sl.onlyTicks = true;  // ticks only: one tick per press
            keyClick(Qt.Key_Right);
            fuzzyCompare(backend.level, 0.25, 1e-9);
            sl.tickMarks = 0; sl.onlyTicks = false;
        }
        function test_slider_keeps_binding() {
            mouseClick(sl, sl.width - 2, sl.height / 2);
            verify(backend.level > 0.9);
            backend.level = 0.5;
            compare(sl.value, 0.5);
        }
    }
}
