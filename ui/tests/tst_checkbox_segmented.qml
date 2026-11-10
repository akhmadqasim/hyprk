import QtQuick
import QtTest
import HyprK

// Checkbox and SegmentedControl: controlled state, mouse, keyboard, disabled, motion.
// Run: QT_QPA_PLATFORM=offscreen qmltestrunner -import ui -input ui/tests
Item {
    id: root
    width: 400; height: 300

    QtObject {
        id: backend
        property bool on: false
        property int index: 0
    }

    Checkbox {
        id: cb
        x: 20; y: 20
        text: "Show warnings"
        checked: backend.on
        onToggled: v => backend.on = v
    }
    Checkbox {
        id: refusing          // a caller that rejects the change: the box stays as it was
        x: 20; y: 50
        checked: false
    }
    Checkbox {
        id: mixedBox
        x: 20; y: 80
        mixed: true
    }
    Checkbox {
        id: disabledBox
        x: 20; y: 110
        enabled: false
    }
    SegmentedControl {
        id: seg
        x: 20; y: 150
        model: ["One", "Two", { text: "Three", glyph: "star" }]
        currentIndex: backend.index
        onActivated: i => backend.index = i
    }
    SegmentedControl {
        id: fixedSeg
        x: 20; y: 200
        segmentWidth: 46
        model: [{ glyph: "grid_view" }, { glyph: "list" }]
        currentIndex: 0
    }

    SignalSpy { id: refusingSpy; target: refusing; signalName: "toggled" }
    SignalSpy { id: mixedSpy; target: mixedBox; signalName: "toggled" }
    SignalSpy { id: disabledSpy; target: disabledBox; signalName: "toggled" }
    SignalSpy { id: segSpy; target: seg; signalName: "activated" }

    TestCase {
        name: "HyprKCheckboxSegmented"
        when: windowShown

        function init() {
            Tokens.reduceMotion = true;                    // reset without motion
            backend.on = false;
            backend.index = 0;
            Tokens.reduceMotion = false;
            refusingSpy.clear(); mixedSpy.clear(); disabledSpy.clear(); segSpy.clear();
        }

        // ---------- Checkbox ----------
        function test_checkbox_keeps_binding() {
            mouseClick(cb);
            compare(backend.on, true);
            compare(cb.checked, true);
            mouseClick(cb, cb.width - 4, cb.height / 2);   // the label toggles too
            compare(backend.on, false);
            backend.on = true;                             // external change still reaches the box
            compare(cb.checked, true);
        }
        function test_checkbox_does_not_write_checked() {
            mouseClick(refusing);
            compare(refusingSpy.count, 1);
            compare(refusingSpy.signalArguments[0][0], true);
            compare(refusing.checked, false);
        }
        function test_checkbox_mixed_asks_for_on() {
            mouseClick(mixedBox);
            compare(mixedSpy.count, 1);
            compare(mixedSpy.signalArguments[0][0], true);
            verify(mixedBox.mixed);
        }
        function test_checkbox_pressed_clears_outside() {
            mousePress(refusing);
            verify(refusing.pressed);
            mouseMove(root, 380, 280);
            verify(!refusing.pressed);
            mouseRelease(root, 380, 280);
            compare(refusingSpy.count, 0);                 // released outside: no action
        }
        function test_checkbox_disabled() {
            mouseClick(disabledBox);
            compare(disabledSpy.count, 0);
            compare(disabledBox.opacity, Tokens.control.disabledOpacity);
        }
        function test_checkbox_space() {
            cb.forceActiveFocus();
            keyClick(Qt.Key_Space);
            compare(backend.on, true);
            keyClick(Qt.Key_Space);
            compare(backend.on, false);
        }
        function test_checkbox_accessible() {
            compare(cb.Accessible.role, Accessible.CheckBox);
            compare(cb.Accessible.name, "Show warnings");
            backend.on = true;
            compare(cb.Accessible.checked, true);
            compare(mixedBox.Accessible.checkStateMixed, true);
        }
        function test_checkbox_tick_wipes_in() {
            backend.on = true;
            const w = findChild(cb, "wipe");
            verify(w.width < Tokens.control.checkboxSize); // still moving on the first frame
            tryCompare(w, "width", Tokens.control.checkboxSize, 1000);
        }
        function test_checkbox_reduce_motion_instant() {
            Tokens.reduceMotion = true;
            backend.on = true;
            compare(findChild(cb, "wipe").width, Tokens.control.checkboxSize);
        }

        // ---------- SegmentedControl ----------
        function segX(c, i) { return (i + 0.5) * c.width / c.count; }

        function test_segmented_keeps_binding() {
            mouseClick(seg, segX(seg, 2), seg.height / 2);
            compare(segSpy.count, 1);
            compare(backend.index, 2);
            compare(seg.currentIndex, 2);
            backend.index = 1;
            compare(seg.currentIndex, 1);
        }
        function test_segmented_click_current_does_nothing() {
            mouseClick(seg, segX(seg, 0), seg.height / 2);
            compare(segSpy.count, 0);
        }
        function test_segmented_drag_release_picks_segment() {
            mousePress(seg, segX(seg, 0), seg.height / 2);
            mouseMove(seg, segX(seg, 1), seg.height / 2);
            compare(seg.pressedIndex, 1);
            mouseRelease(seg, segX(seg, 1), seg.height / 2);
            compare(backend.index, 1);
        }
        function test_segmented_release_outside_cancels() {
            mousePress(seg, segX(seg, 1), seg.height / 2);
            mouseMove(root, 380, 290);
            compare(seg.pressedIndex, -1);
            mouseRelease(root, 380, 290);
            compare(segSpy.count, 0);
        }
        function test_segmented_arrows() {
            seg.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(backend.index, 1);
            keyClick(Qt.Key_Right);
            keyClick(Qt.Key_Right);                        // stops at the last segment
            compare(backend.index, 2);
            keyClick(Qt.Key_Left);
            compare(backend.index, 1);
        }
        function test_segmented_disabled() {
            seg.enabled = false;
            mouseClick(seg, segX(seg, 2), seg.height / 2);
            seg.forceActiveFocus();
            keyClick(Qt.Key_Right);
            seg.enabled = true;
            compare(segSpy.count, 0);
        }
        function test_segmented_equal_and_fixed_widths() {
            compare(fixedSeg.implicitWidth, 2 * 46);
            verify(seg.implicitWidth > 0);
            compare(seg.implicitWidth % 3, 0);             // three equal segments
        }
        function test_segmented_pill_slides() {
            const pill = findChild(seg, "pill");
            backend.index = 2;
            wait(50);
            const mid = (pill.x - seg.selectionInset) / (seg.width / 3);
            verify(mid > 0 && mid < 2, "pill in flight at " + mid);
            tryCompare(pill, "x", 2 * seg.width / 3 + seg.selectionInset, 2000);
        }
        function test_segmented_reduce_motion_jumps() {
            Tokens.reduceMotion = true;
            backend.index = 2;
            compare(seg.currentIndex, 2);
            const pill = findChild(seg, "pill");
            compare(pill.x, 2 * seg.width / 3 + seg.selectionInset);
        }
        function test_segmented_accessible() {
            compare(seg.Accessible.role, Accessible.Grouping);
        }
    }
}
