import QtQuick
import QtTest
import ".."
import "../HyprK"

// Rows, buttons and tabs that navigate (MAC-ANSWERS-12.md R12.3, reference/re/27.2.1/live/settings-r12/NAV-ROWS.md):
// each one is clicked with the mouse and its destination checked: a pushed sub-pane (toolbar title, Go Back), a sheet
// (shown, closed by Done / Escape) or a tab's content. Geometry of a sample is compared with the Mac's AX frames
// (window coordinates, pt: ax-nav-*-dark.jsonl minus the window's 350,150).
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_destinations.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "general"; windowActive: true }

    TestCase {
        name: "SettingsDestinations"
        when: windowShown

        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function title() { return findChild(app, "toolbarTitle").text; }
        function flick() { return Array.prototype.find.call(app.children, c => c.contentHeight !== undefined); }
        function paneItem() { return flick().contentItem.children[0].item; }
        function texts(item, out) {
            for (const c of item.children) {
                if (!c.visible) continue;
                if (typeof c.text === "string" && c.text !== "" && c.font !== undefined) out.push(c);
                texts(c, out);
            }
            return out;
        }
        function labels(item) { return texts(item, []).map(t => t.text); }
        // the window position of the visible text `s` under `item` (its frame's left and top, pt)
        function at(item, s) {
            wait(20);   // columns are laid out on polish
            const t = texts(item, []).find(t => t.text === s);
            verify(t, "text shown: " + s);
            const p = t.mapToItem(root, t.leftPadding || 0, t.topPadding || 0);
            return { x: p.x, y: p.y };
        }
        function near(got, want, tol, what) { verify(Math.abs(got - want) <= tol, what + ": " + got + " against the Mac's " + want); }
        // scroll the pane so that `item` is in view, then click it
        function click(item, dx) {
            verify(item, "item exists");
            wait(30);   // the pane's column is laid out on polish
            const f = flick();
            const y = item.mapToItem(f.contentItem, 0, 0).y;
            if (y < f.contentY + 60 || y + item.height > f.contentY + f.height - 10)
                f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, y - 200));
            wait(30);
            mouseClick(item, dx === undefined ? item.width / 2 : dx, item.height / 2);
        }
        function sheet(name) { const s = findChild(app, name); verify(s, "sheet " + name); return s; }
        // a sheet's own item (it lives in the window, outside the pane)
        function sheetItem(name) { return findChild(root.parent, name + "Sheet"); }

        // ---------- General: 11 rows push their sub-panes ----------
        function test_general_rows_data() {
            return [
                { tag: "about", title: "About", has: "Name" },
                { tag: "softwareupdate", title: "Software Update", has: "Automatic Updates" },
                { tag: "storage", title: "Storage", has: "Macintosh HD" },
                { tag: "airdrop", title: "AirDrop & Continuity", has: "Known AirDrop Contacts" },
                { tag: "datetime", title: "Date & Time", has: "24-hour time" },
                { tag: "language", title: "Language & Region", has: "Preferred Languages" },
                { tag: "loginitems", title: "Login Items", has: "Open at Login" },
                { tag: "sharing", title: "Sharing", has: "Remote Login" },
                { tag: "startupdisk", title: "Startup Disk", has: "Select the system you want to use to start up your computer" },
                { tag: "timemachine", title: "Time Machine", has: "Options…" },
                { tag: "transfer", title: "Transfer or Reset", has: "Migration Assistant" }
            ];
        }
        function test_general_rows(d) {
            app.open("general");
            compare(app.subId, "");
            click(findChild(app, "generalRow-" + d.tag), 100);
            compare(app.subId, d.tag);
            compare(title(), d.title);
            verify(labels(paneItem()).indexOf(d.has) !== -1, d.has);
            verify(labels(paneItem()).indexOf("Software Update") === -1 || d.tag === "softwareupdate", "the root's rows are gone");
            tryCompare(flick(), "contentY", 0);
            app.go(-1);
            compare(app.subId, "");
            compare(title(), "General");
        }
        function test_general_about_buttons() {
            app.open("general", "about");
            click(findChild(app, "aboutStorageSettings"));
            compare(app.subId, "storage");
            compare(title(), "Storage");
            app.open("general", "about");
            click(findChild(app, "aboutDisplaySettings"));
            compare(app.currentId, "displays");
        }
        // ax-nav-general--dateAndTime-dark.jsonl, ax-nav-general--sharing-dark.jsonl, ax-nav-general--airDropAndHandoff-dark.jsonl
        function test_general_geometry() {
            app.open("general", "datetime");
            let p = paneItem();
            wait(30);
            near(at(p, "Set time and date automatically").y, 74, 1.5, "Date & Time row 1");
            near(at(p, "Source").y, 111.5, 1.5, "Source");
            near(at(p, "Date and time").y, 161.5, 2, "Date and time");
            near(at(p, "24-hour time").y, 198.5, 2, "24-hour time");
            near(at(p, "Time zone").y, 282.5, 3, "Time zone");
            near(at(p, "Time zone").x, 262, 0.5, "Time zone x");
            app.open("general", "sharing");
            p = paneItem();
            wait(30);
            near(at(p, "Content & Media").y, 64, 1, "Sharing heading");
            near(at(p, "File Sharing").y, 108, 2, "File Sharing");
            near(at(p, "Accessories & Internet").y, 331, 3, "second heading");
            near(at(p, "Remote Management").y, 589, 4, "Remote Management");
            app.open("general", "airdrop");
            p = paneItem();
            wait(30);
            near(at(p, "AirDrop").y, 64, 1, "AirDrop heading");
            near(at(p, "Known AirDrop Contacts").y, 181, 2, "Known AirDrop Contacts");
            near(at(p, "Continuity").y, 312, 3, "Continuity heading");
            near(at(p, "Widgets & iPhone Mirroring").y, 404.5, 4, "third heading");
            // the Mac's "iPhone" row (its own phone, 53 pt) is not here: what follows sits that much higher
            near(at(p, "AirPlay Receiver").y, 623 - 53, 6, "AirPlay Receiver");
            app.open("general", "transfer");
            p = paneItem();
            wait(30);
            near(at(p, "Migration Assistant").x, 296, 1, "Migration Assistant x");
            near(at(p, "Migration Assistant").y, 79, 1.5, "Migration Assistant y");
        }

        // ---------- sheets ----------
        function test_sheets_data() {
            return [
                { tag: "dockShortcuts", pane: "dock", w: 470, h: 326, has: "Keyboard & Mouse Shortcuts" },
                { tag: "dockHotCorners", pane: "dock", w: 630, h: 193, has: "Done" },
                { tag: "displaysAdvanced", pane: "displays", w: 470, h: 432, has: "Link to Mac or iPad" },
                { tag: "displaysNightShift", pane: "displays", w: 470, h: 331, has: "Turn on until tomorrow" },
                { tag: "keyboardShortcuts", pane: "keyboard", w: 670, h: 468, has: "Turn Dock hiding on/off" },
                { tag: "keyboardInputSources", pane: "keyboard", w: 640, h: 509, has: "All Input Sources" },
                { tag: "keyboardTextReplacements", pane: "keyboard", w: 470, h: 182, has: "On my way!" },
                { tag: "keyboardDictation", pane: "keyboard", w: 420, h: 403, has: "Select languages:", noDone: true },
                { tag: "keyboardPrivacy", pane: "keyboard", w: 482, h: 550, has: "Siri, Dictation & Privacy", noDone: true, noEscape: true }
            ];
        }
        function test_sheets(d) {
            app.open(d.pane);
            const s = sheet(d.tag);
            compare(s.shown, false);
            click(findChild(app, d.tag + "Button"));
            compare(s.shown, true);
            const item = sheetItem(d.tag);
            verify(item && item.visible);
            compare(item.card.width, d.w);
            compare(item.card.height, d.h);
            near(item.card.mapToItem(root, 0, 0).x, (740 - d.w) / 2, 0.5, "centred");
            verify(labels(item).indexOf(d.has) !== -1, d.has);
            keyClick(Qt.Key_Escape);
            compare(s.shown, !!d.noEscape);
            if (d.noEscape) {
                mouseClick(findChild(item, "privacyOK"));
                compare(s.shown, false);
            } else if (!d.noDone) {
                s.open();
                mouseClick(findChild(item, "sheetDone"));
                compare(s.shown, false);
            } else {
                s.open();
                mouseClick(findChild(item, "dictationCancel"));
                compare(s.shown, false);
            }
            tryCompare(item, "visible", false);
        }
        // sheet contents against the Mac's AX frames (window coordinates)
        function test_sheet_geometry() {
            app.open("dock");
            sheet("dockShortcuts").open();
            let it = sheetItem("dockShortcuts");
            near(at(it, "Keyboard & Mouse Shortcuts").x, 165, 0.5, "heading x");
            near(at(it, "Keyboard & Mouse Shortcuts").y, 169.1, 1.5, "heading y");
            near(at(it, "Mission Control").y, 248.6, 2.5, "Mission Control");
            near(at(it, "Show Desktop").y, 325.1, 3, "Show Desktop");
            const done = findChild(it, "sheetDone").mapToItem(root, 0, 0);
            near(done.x, 521, 0.5, "Done x"); near(done.y, 431, 1, "Done y");
            sheet("dockShortcuts").close();
            app.open("displays");
            sheet("displaysNightShift").open();
            it = sheetItem("displaysNightShift");
            near(at(it, "Schedule").y, 243.1, 2, "Schedule");
            near(at(it, "Turn on until tomorrow").y, 281.4, 2, "Turn on until tomorrow");
            near(at(it, "Color temperature").y, 318.9, 2.5, "Color temperature");
            sheet("displaysNightShift").close();
            app.open("keyboard");
            sheet("keyboardInputSources").open();
            it = sheetItem("keyboardInputSources");
            near(at(it, "Show Input menu in menu bar").x, 280, 0.5, "x");
            near(at(it, "Show Input menu in menu bar").y, 88.1, 1.5, "row 1");
            near(at(it, "Spelling").y, 331.1, 4, "Spelling");
            near(at(it, "For single quotes").y, 454.1, 6, "For single quotes");
            sheet("keyboardInputSources").close();
        }
        function test_dictation_ok_enables() {
            app.open("keyboard");
            const s = sheet("keyboardDictation");
            s.open();
            const item = sheetItem("keyboardDictation");
            const ok = findChild(item, "dictationOK");
            compare(ok.enabled, false);
            s.changed = true;
            compare(ok.enabled, true);
            mouseClick(ok);
            compare(s.shown, false);
            compare(s.changed, false);
        }
        function test_keyboard_shortcut_groups() {
            app.open("keyboard");
            sheet("keyboardShortcuts").open();
            const item = sheetItem("keyboardShortcuts");
            verify(labels(item).indexOf("Turn Dock hiding on/off") !== -1);
            mouseClick(findChild(item, "sheetSidebarRow4"));
            verify(labels(item).indexOf("Turn Dock hiding on/off") === -1);
            verify(labels(item).indexOf("To change a shortcut, double-click the key combination, then type the new keys.") !== -1);
            sheet("keyboardShortcuts").close();
        }

        // ---------- Notifications: Summarize and an application ----------
        function test_notifications() {
            app.open("notifications");
            const p = paneItem();
            click(findChild(app, "notifSummarizeRow"), 100);
            compare(app.subId, "summarize");
            compare(title(), "Summarize Notifications");
            near(at(p, "Summarize Notifications").y, 74, 1.5, "Summarize label");
            verify(labels(p).indexOf("Show previews") === -1);
            const before = AppState.notifications.summarize;
            click(findChild(app, "notifSummarizeSwitch"));
            compare(AppState.notifications.summarize, !before);
            AppState.set("notifications", { summarize: before });
            app.go(-1);
            compare(title(), "Notifications");
            p.apps = [{ id: "org.example.Finder", name: "Finder", icon: "" }];   // no process runs here: the list is given
            tryVerify(() => findChild(app, "notifAppRow0") !== null);
            click(findChild(app, "notifAppRow0"), 100);
            compare(app.subId, "app:org.example.Finder");
            compare(title(), "Finder");
            // ax-nav-notifications--app-finder-dark.jsonl
            near(at(p, "Allow notifications").x, 300, 0.5, "Allow notifications x");
            near(at(p, "Allow notifications").y, 74, 1, "Allow notifications y");
            near(at(p, "Alert Style").y, 281.1, 2, "Alert Style");
            near(at(p, "Badge application icon").y, 327.5, 2.5, "Badge application icon");
            near(at(p, "Show previews").y, 411.5, 3.5, "Show previews");
            click(findChild(app, "notifStylePersistent"), 8);
            compare(AppState.notifications.apps["org.example.Finder"].style, "alerts");
            click(findChild(app, "notifAllowSwitch"));
            compare(AppState.notifications.apps["org.example.Finder"].allow, false);
            AppState.set("notifications", { apps: {} });
            app.go(-1);
            compare(app.subId, "");
        }

        // ---------- Trackpad: three tabs swap the content in place ----------
        function test_trackpad_tabs() {
            app.open("trackpad");
            const p = paneItem(), tabs = findChild(app, "trackpadTabs");
            compare(tabs.width, 468);
            near(tabs.mapToItem(root, 0, 0).y, 210, 0.5, "tab bar y");
            verify(labels(p).indexOf("Tracking speed") !== -1);
            near(at(p, "Tracking speed").y, 262, 1.5, "Tracking speed");
            near(at(p, "Look up & data detectors").y, 431, 3, "Look up & data detectors");
            mouseClick(tabs, 230, 12);
            compare(p.tab, 1);
            wait(30);
            verify(labels(p).indexOf("Tracking speed") === -1);
            near(at(p, "Natural scrolling").y, 262, 1.5, "Natural scrolling");
            near(at(p, "Rotate").y, 421, 3, "Rotate");
            mouseClick(tabs, 400, 12);
            compare(p.tab, 2);
            wait(30);
            near(at(p, "Swipe between pages").y, 262, 1.5, "Swipe between pages");
            near(at(p, "Show Desktop").y, 521, 4, "Show Desktop");
            compare(title(), "Trackpad");
            compare(app.subId, "");
        }
    }
}
