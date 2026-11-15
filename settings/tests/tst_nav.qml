import QtQuick
import QtTest
import ".."
import "../HyprK"

// Sub-pane navigation (reference/re/27.2.1/SETTINGS-CLICK-AUDIT.md "Sub-pane chrome"): a pushed sub-pane gives the
// toolbar its title, Go Back / Go Forward walk one history of panes and sub-panes, the pane's own sidebar row pops it.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_nav.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "appearance"; windowActive: true }

    TestCase {
        name: "SettingsNav"
        when: windowShown

        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function title() { return findChild(app, "toolbarTitle").text; }
        function paneItem() { for (const c of app.children) if (c.contentHeight !== undefined) return c.contentItem.children[0].item; return null; }
        function texts(item, out) {
            for (const c of item.children) {
                if (!c.visible) continue;
                if (typeof c.text === "string" && c.text !== "") out.push(c.text);
                texts(c, out);
            }
            return out;
        }

        function test_1_push_and_back() {
            app.open("accessibility");
            compare(title(), "Accessibility");
            paneItem().page = "voiceover";          // what a row's click does
            compare(app.subId, "voiceover");
            compare(title(), "VoiceOver");
            compare(app.history.length, 3);         // appearance, accessibility, accessibility > voiceover
            // the content has no back link and no title of its own: "Accessibility" is nowhere in the pane
            verify(texts(paneItem(), []).indexOf("Accessibility") === -1);
            app.go(-1);
            compare(app.subId, "");
            compare(paneItem().page, "");
            compare(title(), "Accessibility");
            compare(app.history.length, 3);
            app.go(1);
            compare(paneItem().page, "voiceover");
            compare(title(), "VoiceOver");
        }
        function test_2_sidebar_row_pops() {
            compare(app.subId, "voiceover");
            app.open("accessibility");
            compare(app.subId, "");
            compare(paneItem().page, "");
            compare(title(), "Accessibility");
        }
        function test_3_root_scroll_kept() {
            const flick = Array.prototype.find.call(app.children, c => c.contentHeight !== undefined);
            tryVerify(() => flick.contentHeight > flick.height + 200);
            flick.contentY = 180;
            paneItem().page = "zoom";
            tryCompare(flick, "contentY", 0);
            app.go(-1);
            tryCompare(flick, "contentY", 180);
        }
        function test_4_link_into_sub_pane() {
            app.open("appearance");
            AppState.navigate("accessibility", "display");   // Appearance > More in Accessibility Settings…
            compare(app.currentId, "accessibility");
            compare(paneItem().page, "display");
            compare(title(), "Display");
            app.go(-1);
            compare(app.currentId, "appearance");
            compare(title(), "Appearance");
        }
    }
}
