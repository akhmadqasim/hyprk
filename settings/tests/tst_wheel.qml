import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../Panes.js" as Panes

// A mouse wheel scrolls every pane that overflows, and the sidebar, wherever the pointer is: no control or overlay in a
// pane may swallow the wheel (AppKit sends a wheel the control does not use up to the enclosing scroll view).
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_wheel.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "appearance"; windowActive: true }

    TestCase {
        name: "SettingsWheel"
        when: windowShown

        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function flick() { for (const c of app.children) if (c.contentHeight !== undefined) return c; return null; }
        function sidebarList() { return findChild(app, "sidebarList"); }

        // scroll views inside the pane that scroll vertically themselves (the Liquid Glass preview's article): the
        // wheel belongs to them there, as on the Mac
        function innerViews(item, out) {
            for (const c of item.children) {
                if (!c.visible) continue;
                if (c.contentHeight !== undefined && c.flickableDirection !== undefined && c.contentHeight > c.height + 0.5) out.push(c);
                innerViews(c, out);
            }
            return out;
        }
        function over(views, x, y) {
            for (const v of views) {
                const p = app.mapToItem(v, x, y);
                if (p.x >= 0 && p.y >= 0 && p.x < v.width && p.y < v.height) return true;
            }
            return false;
        }

        function test_panes_data() { return Panes.panes.map(p => ({ tag: p.id, id: p.id })); }
        function test_panes(d) {
            app.currentId = d.id;
            const f = flick();
            tryVerify(() => f.contentHeight > 100, 3000);
            wait(150);
            if (f.contentHeight <= f.height + 0.5) skip("fits: nothing to scroll");
            const inner = innerViews(f.contentItem, []);
            const dead = [];
            for (let y = 70; y < app.height - 10; y += 37) {
                for (let x = f.x + 30; x < app.width - 20; x += 61) {
                    f.contentY = 0;
                    if (over(inner, x, y)) continue;
                    mouseWheel(app, x, y, 0, -120);
                    wait(1);
                    if (!(f.contentY > 0 || f.verticalVelocity > 0 || f.moving)) { wait(60); if (!(f.contentY > 0)) dead.push(x + "," + y); }
                }
            }
            f.contentY = 0;
            compare(dead.join(" "), "", "the wheel does not scroll the pane at these points");
        }

        function test_sidebar() {
            app.currentId = "appearance";
            const l = sidebarList();
            verify(l);
            verify(l.contentHeight > l.height);
            const y0 = l.originY - l.topMargin;
            for (const y of [80, 120, 300, 600]) {      // over the search field, the rows and the foot
                l.contentY = y0;
                mouseWheel(app, 110, y, 0, -120);
                tryVerify(() => l.contentY > y0, 1000, "the wheel does not scroll the sidebar at y " + y);
                wait(300);
            }
            l.contentY = y0;
        }
    }
}
