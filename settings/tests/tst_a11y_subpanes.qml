import QtQuick
import QtTest
import ".."
import "../HyprK"

// Every Accessibility sub-pane opens with the Mac's chrome and the Mac's content height (reference/re/MAC-ANSWERS-12.md
// R12.1, re/27.2.1/live/settings-r12/ax-acc-*-00-light.jsonl): the toolbar title is the sub-pane's name, Go Back is
// enabled and Go Forward is not, the sidebar stays on Accessibility, and the content has no back link.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_a11y_subpanes.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "accessibility"; windowActive: true }

    TestCase {
        name: "AccessibilitySubPanes"
        when: windowShown

        // id, toolbar title, a label of its first group, the Mac's AXScrollArea content height (0: ours has no group
        // for the AirPods connected to that Mac)
        readonly property var panes: [
            ["voiceover", "VoiceOver", "Open VoiceOver Utility…", 189], ["zoom", "Zoom", "Use keyboard shortcuts to zoom", 394.5],
            ["hovertext", "Hover Text", "Hover Typing", 238], ["display", "Display", "Show window title icons", 1316.5],
            ["motion", "Motion", "Vehicle Motion Cues", 308.5], ["readspeak", "Read & Speak", "Accessibility Reader", 606],
            ["audiodesc", "Audio Descriptions", "Play audio descriptions when available", 128],
            ["voicecontrol", "Voice Control", "Show hints", 564.5], ["keyboard", "Keyboard", "Full Keyboard Access", 576],
            ["pointer", "Pointer Control", "Double-click speed", 562], ["switchcontrol", "Switch Control", "Auto scanning", 1202],
            ["hearingdevices", "Hearing Devices", "MFi Hearing Devices", 202], ["audio", "Audio", "Play stereo audio as mono", 0],
            ["rtt", "RTT", "RTT relay number", 260], ["captions", "Subtitles and Captioning", "Show on skip back", 627.5],
            ["livecaptions", "Live Captions", "Live Captions in FaceTime", 545], ["namerecognition", "Name Recognition", "Set Up", 128],
            ["livespeech", "Live Speech", "Add Category…", 405.5], ["personalvoice", "Personal Voice", "No Personal Voices", 414],
            ["vocalshortcuts", "Vocal Shortcuts", "Set Up", 142], ["siri", "Siri", "Spoken Responses", 264.5],
            ["shortcut", "Shortcut", "Vehicle Motion Cues", 702]]

        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function flick() { return Array.prototype.find.call(app.children, c => c.contentHeight !== undefined); }
        function paneItem() { return flick().contentItem.children[0].item; }
        function subLoader() { return Array.prototype.find.call(paneItem().children, c => c.item !== undefined && c.setSource !== undefined); }
        function texts(item, out) {
            for (const c of item.children) {
                if (!c.visible) continue;
                if (typeof c.text === "string" && c.text !== "") out.push(c.text);
                texts(c, out);
            }
            return out;
        }

        function test_registry() {
            compare(panes.length, 22);
            compare(paneItem()._rows.map(r => r.id), panes.map(p => p[0]));   // the Mac's order
        }
        function test_open_data() { return panes.map(p => ({ tag: p[0], title: p[1], label: p[2], height: p[3] })); }
        function test_open(d) {
            app.open("accessibility");
            const before = app.history.length;
            paneItem().page = d.tag;                      // what a row's click does
            // one frame: the title and the content are there as soon as the click returns (R12.2: a cut, no push)
            compare(findChild(app, "toolbarTitle").text, d.title);
            compare(subLoader().status, Loader.Ready);
            verify(subLoader().item !== null);
            compare(app.currentId, "accessibility");      // the sidebar keeps Accessibility selected
            compare(app.subId, d.tag);
            verify(app.historyPos > 0);                   // Go Back enabled
            compare(app.historyPos, app.history.length - 1);   // Go Forward disabled
            const t = texts(paneItem(), []);
            verify(t.indexOf(d.label) !== -1, d.label);
            verify(t.indexOf("Accessibility") === -1);    // no in-content back link or title
            verify(t.indexOf(d.title) === -1 || d.title === t.find(x => x === d.title));
            if (d.height > 0) {
                // ours: the toolbar's 52 pt are part of the document (the Help button is the Mac's 24 pt since R13)
                const want = d.height + 52;
                tryVerify(() => flick().contentHeight >= want - 2.5 && flick().contentHeight <= want + 0.5, 1000);
            }
            app.go(-1);
            compare(app.subId, "");
            compare(findChild(app, "toolbarTitle").text, "Accessibility");
            verify(app.historyPos < app.history.length - 1);   // Go Forward enabled after going back
        }
    }
}
