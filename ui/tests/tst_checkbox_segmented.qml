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

    SegmentedControl {
        id: iconSeg
        x: 200; y: 200
        segmentWidth: 46
        reduceMotion: true
        model: [{ icon: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><rect width='24' height='24'/></svg>" },
                { glyph: "list" }, { glyph: "grid_view" }, { glyph: "star" }]
        currentIndex: 2
    }

    SignalSpy { id: refusingSpy; target: refusing; signalName: "toggled" }
    SignalSpy { id: mixedSpy; target: mixedBox; signalName: "toggled" }
    SignalSpy { id: disabledSpy; target: disabledBox; signalName: "toggled" }
    SignalSpy { id: iconSpy; target: iconSeg; signalName: "activated" }
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
        function test_segmented_icon_defaults_and_options() {
            const img = findChild(iconSeg, "icon");
            compare(img.width, 16);
            compare(img.height, 16);
            compare(img.sourceSize.width, 32);             // rendered at 2x
            compare(img.opacity, 1);
            iconSeg.iconSize = 24;
            iconSeg.iconOpacity = 0.85;
            compare(img.width, 24);
            compare(img.sourceSize.width, 48);
            compare(img.opacity, 0.85);
            iconSeg.iconSize = 16;
            iconSeg.iconOpacity = 1;
        }
        function test_segmented_separator_boundaries() {
            compare(iconSeg.separatorBoundaries, null);    // default: every inner boundary
            for (let b = 1; b < 4; b++) verify(findChild(iconSeg, "separator" + b).visible);
            iconSeg.separatorBoundaries = [2, 3];          // not between segment 0 and 1
            verify(!findChild(iconSeg, "separator1").visible);
            verify(findChild(iconSeg, "separator2").visible);
            verify(findChild(iconSeg, "separator3").visible);
            iconSeg.separatorBoundaries = [];
            for (let b = 1; b < 4; b++) verify(!findChild(iconSeg, "separator" + b).visible);
            iconSeg.separatorBoundaries = null;
        }
        function test_segmented_separator_spacing() {
            iconSeg.reduceMotion = true;
            iconSeg.separatorBoundaries = [2, 3];
            iconSeg.separatorSpacing = 1;
            compare(iconSeg.implicitWidth, 4 * 46 + 2);
            iconSeg.width = iconSeg.implicitWidth;
            const pill = findChild(iconSeg, "pill");
            iconSeg.currentIndex = 2;
            compare(pill.x, 2 * 46 + 1 + iconSeg.selectionInset);     // after one gap
            iconSeg.currentIndex = 3;
            compare(pill.x, 3 * 46 + 2 + iconSeg.selectionInset);     // after two gaps
            compare(pill.width, 46 - 2 * iconSeg.selectionInset);
            iconSeg.currentIndex = 1;
            compare(pill.x, 46 + iconSeg.selectionInset);              // no gap before segment 1
            compare(findChild(iconSeg, "separator2").x, 92);           // the 1px gap 92..93
            compare(findChild(iconSeg, "separator3").x, 139);
            iconSpy.clear();
            iconSeg.currentIndex = 0;
            mouseClick(iconSeg, 100, 22);                              // inside segment 2 (93..139)
            compare(iconSpy.signalArguments[0][0], 2);
            mouseClick(iconSeg, 91.5, 22);                             // left of the gap middle: segment 1
            compare(iconSpy.signalArguments[1][0], 1);
            iconSeg.separatorSpacing = 0;
            iconSeg.separatorBoundaries = null;
            iconSeg.width = iconSeg.implicitWidth;
            iconSeg.currentIndex = 2;
        }
        function test_segmented_separator_color() {
            compare(findChild(iconSeg, "separator1").color, Tokens.control.separator);
            iconSeg.separatorColor = "red";
            compare(findChild(iconSeg, "separator1").color, "#ff0000");
            iconSeg.separatorColor = Qt.binding(() => Tokens.control.separator);
        }
        function test_segmented_separator_fade() {
            const next = findChild(iconSeg, "separator2");  // touches the pill on segment 2
            compare(next.opacity, 0);
            iconSeg.separatorFade = false;
            compare(next.opacity, 1);
            iconSeg.separatorFade = true;
        }
        function test_segmented_accessible() {
            compare(seg.Accessible.role, Accessible.Grouping);
        }
    }
}
