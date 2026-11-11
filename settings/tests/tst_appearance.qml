import QtQuick
import QtTest
import ".."
import "../HyprK"

// Appearance pane against the 27.2.1 Mac (MAC-ANSWERS.md PC #60, re/27.2.1/live/settings/appearance/layout.json):
// section heights, the Liquid Glass end buttons, wheel scrolling and the overlay scroll bar.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_appearance.qml
// State is never written: the test holds AppState's write timer and checks the queued patch instead.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "appearance"; windowActive: true }

    TestCase {
        name: "SettingsAppearance"
        when: windowShown

        function initTestCase() {
            AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000;   // never reaches the state file
            AppState.set("appearance", { iconStyle: "dark", iconStyleVariant: "dark", glass: 0.5 });
        }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function flick() { for (const c of app.children) if (c.contentHeight !== undefined) return c; return null; }
        function column() {
            const f = flick();
            for (const c of f.contentItem.children) if (c.item) return c.item;
            return null;
        }
        function heights() {
            const col = column();
            const out = [];
            for (const c of col.children) if (c.visible && c.height > 0 && c.width > 0) out.push(c.height);
            return out;
        }

        // cards 319, heading 30 + 16 + 10 over card 100, card 145.5, heading over card 75, card 189, button row
        // 20 + 24; document 1036.5 under the 52 pt toolbar, 573 visible, max offset 463.5
        function test_a_layout() {
            tryVerify(() => column() !== null && column().height > 900, 3000);
            AppState.set("appearance", { iconStyle: "dark", iconStyleVariant: "dark" });
            tryVerify(() => heights()[2] === 145.5, 1000);
            // a heading's 30 = the column's 10 + its own 20 top padding
            compare(heights(), [319, 20 + 16 + 10 + 100, 145.5, 20 + 16 + 10 + 75, 189, 10 + 24]);
            compare(column().spacing, 10);
            compare(flick().contentHeight, 52 + 1036.5);
            compare(flick().contentHeight - flick().height, 463.5);
            compare(column().mapToItem(app, 0, 0).y, 52 + 12);
            AppState.set("appearance", { iconStyle: "default" });
            tryVerify(() => heights()[2] === 129, 1000);  // no radio row with Default
            AppState.set("appearance", { iconStyle: "dark" });
        }
        // the end buttons step NSGlassTintAmount by -0.1 / +0.1 and the value is written (queued) at once
        function test_b_glass_end_buttons() {
            const sl = findChild(app, "glassSlider");
            verify(sl);
            const right = findChild(sl, "rightEnd"), left = findChild(sl, "leftEnd");
            compare(AppState.appearance.glass, 0.5);
            mouseClick(right);
            fuzzyCompare(AppState.appearance.glass, 0.6, 1e-9);
            fuzzyCompare(AppState._patches.appearance.glass, 0.6, 1e-9);
            mousePress(left);
            verify(left.pressed);                         // pressed state while held
            mouseRelease(left);
            mouseClick(left);
            fuzzyCompare(AppState.appearance.glass, 0.4, 1e-9);
            fuzzyCompare(AppState._patches.appearance.glass, 0.4, 1e-9);
        }
        // wheel to the bottom: the last card and the button row are on screen; the overlay knob shows, then fades
        function test_c_wheel_and_scroller() {
            const f = flick();
            f.contentY = 0;
            const sc = findChild(app, "knob").parent;
            for (let i = 0; i < 40 && f.contentY < 463.5; i++) { mouseWheel(app, 500, 400, 0, -120); wait(20); }
            tryCompare(f, "contentY", 463.5, 2000);
            const col = column();
            const footer = col.children[col.children.length - 1];
            const p = footer.mapToItem(app, 0, 0);
            verify(p.y + footer.height <= app.height - 20 + 0.01, "button row bottom " + (p.y + footer.height));
            compare(sc.opacity, 1);
            tryCompare(sc, "opacity", 0, 2000);          // 0.6 s hold + 0.15 s fade
        }
        function test_d_scroller_drag() {
            const f = flick();
            f.contentY = 0;
            const sc = findChild(app, "knob").parent;
            sc.poke();
            const knob = findChild(app, "knob");
            fuzzyCompare(knob.height, (625 - 52 - 6) * 625 / 1088.5, 0.01);   // 325.6 (Mac 325.5)
            mousePress(sc, 3, knob.height / 2);
            mouseMove(sc, 3, sc.height - knob.height / 2);
            mouseRelease(sc, 3, sc.height - knob.height / 2);
            fuzzyCompare(f.contentY, 463.5, 1.5);           // mouse positions are whole points
        }
    }
}
