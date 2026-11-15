import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../panes/privacy/PrivacyData.js" as PD
import "../panes/KeyboardData.js" as KD

// Round 13 (reference/re/MAC-ANSWERS-13.md, reference/re/27.2.1/live/settings-r13/): every new destination is opened
// with the mouse and checked (a pushed sub-pane: toolbar title and Go Back; a sheet: its size, place and closing; the
// Wallpaper popover), every pop-up button's menu is opened and its items, checked item and separators compared with
// popups.json (US spelling, as the app), and the 14 Keyboard Shortcuts groups are selected in turn. A sample of
// positions is compared with the Mac's AX frames (window pt: the dump's frame minus the window's 350,150).
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_r13.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "general"; windowActive: true }

    TestCase {
        name: "SettingsRound13"
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
        function has(item, s) { return labels(item).indexOf(s) !== -1; }
        // the document position of the visible text `s` under `item` (window pt at scroll offset 0)
        function at(item, s) {
            wait(20);
            const t = texts(item, []).find(t => t.text === s);
            verify(t, "text shown: " + s);
            const p = t.mapToItem(root, t.leftPadding || 0, t.topPadding || 0);
            return { x: p.x, y: p.y + (item === paneItem() ? flick().contentY : 0) };
        }
        function near(got, want, tol, what) { verify(Math.abs(got - want) <= tol, what + ": " + got + " against the Mac's " + want); }
        function reveal(item) {
            verify(item, "item exists");
            wait(30);
            const f = flick();
            const y = item.mapToItem(f.contentItem, 0, 0).y;
            if (y < f.contentY + 60 || y + item.height > f.contentY + f.height - 10)
                f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, y - 200));
            wait(30);
        }
        function click(item, dx) { reveal(item); mouseClick(item, dx === undefined ? item.width / 2 : dx, item.height / 2); }
        function sheet(name) { const s = findChild(app, name); verify(s, "sheet " + name); return s; }
        function sheetItem(name) { return findChild(root.parent, name + "Sheet"); }

        // ---------- sub-panes ----------
        function test_focus_rows_data() {
            return [
                { tag: "dnd", title: "Do Not Disturb", has: "Add Schedule…" },
                { tag: "driving", title: "Driving", has: "Delete Focus…" },
                { tag: "mindfulness", title: "Mindfulness", has: "Add Filter…" },
                { tag: "reduce", title: "Reduce Interruptions", has: "No Schedules" },
                { tag: "sleep", title: "Sleep", has: "No Focus filters" },
                { tag: "work", title: "Work", has: "Allowed Apps" },
                { tag: "status", title: "Focus Status", has: "Share From" }
            ];
        }
        function test_focus_rows(d) {
            app.open("focus");
            compare(app.subId, "");
            click(findChild(app, "focusRow-" + d.tag), 100);
            compare(app.subId, d.tag);
            compare(title(), d.title);
            verify(has(paneItem(), d.has), d.has);
            verify(!has(paneItem(), "Add Focus…"), "the root's content is gone");
            app.go(-1);
            compare(app.subId, "");
            compare(title(), "Focus");
            verify(has(paneItem(), "Add Focus…"));
        }
        function test_privacy_rows_data() { return PD.all().map(c => ({ tag: c.id, title: c.title })); }
        function test_privacy_rows(d) {
            app.open("privacy");
            compare(app.subId, "");
            click(findChild(app, "privacyRow-" + d.tag), 100);
            compare(app.subId, d.tag);
            compare(title(), d.title);
            verify(labels(paneItem()).length > 0, "the sub-pane has content");
            verify(!has(paneItem(), "Allow applications from"), "the root's content is gone");
            app.go(-1);
            compare(app.subId, "");
            compare(title(), "Privacy & Security");
        }
        function test_privacy_count() { compare(PD.all().length, 33); }
        function test_general_rows_data() {
            return [
                { tag: "passwords", title: "AutoFill & Passwords", has: "Verification Codes" },
                { tag: "devicemanagement", title: "Device Management", has: "No profiles installed" }
            ];
        }
        function test_general_rows(d) {
            app.open("general");
            click(findChild(app, "generalRow-" + d.tag), 100);
            compare(app.subId, d.tag);
            compare(title(), d.title);
            verify(has(paneItem(), d.has), d.has);
            app.go(-1);
            compare(title(), "General");
        }
        function test_passwords_dismiss() {
            app.open("general", "passwords");
            const promo = findChild(app, "passwordsPromo");
            verify(promo.visible);
            wait(50);   // the sub-pane's column is laid out on polish
            mouseClick(findChild(app, "passwordsDismiss"));
            verify(!promo.visible);
            verify(!has(paneItem(), "All Your Passwords in One Place"));
        }

        // ---------- sheets ----------
        function test_sheets_data() {
            return [
                { tag: "lockAccessibility", pane: "lockscreen", w: 470, h: 479, y: 73, has: "Accessibility Keyboard *" },
                { tag: "privacyAdvanced", pane: "privacy", w: 470, h: 199, y: 213, has: "Log out automatically after inactivity" },
                { tag: "wallpaperScreenSaver", pane: "wallpaper", w: 500, h: 548, y: 52, has: "Start Screen Saver…" },
                { tag: "locationDetails", pane: "privacy", sub: "location", w: 470, h: 533, y: 52, has: "Show location icon in Control Center when System Services request your location" },
                { tag: "adTargeting", pane: "privacy", sub: "advertising", w: 500, h: 400, y: 112, has: "Ad Targeting Information", close: "adTargetingClose" }
            ];
        }
        function test_sheets(d) {
            app.open(d.pane, d.sub || "");
            const s = sheet(d.tag);
            compare(s.shown, false);
            click(findChild(app, d.tag + "Button"));
            compare(s.shown, true);
            const item = sheetItem(d.tag);
            verify(item && item.visible);
            compare(item.card.width, d.w);
            compare(item.card.height, d.h);
            const p = item.card.mapToItem(root, 0, 0);
            near(p.x, (740 - d.w) / 2, 0.5, "centred");
            near(p.y, d.y, 0.5, "the sheet's y");
            verify(has(item, d.has), d.has);
            keyClick(Qt.Key_Escape);
            compare(s.shown, false);
            s.open();
            mouseClick(findChild(item, d.close || "sheetDone"));
            compare(s.shown, false);
            tryCompare(item, "visible", false);
        }
        // sheet contents against the Mac's AX frames
        function test_sheet_geometry() {
            app.open("lockscreen");
            sheet("lockAccessibility").open();
            let it = sheetItem("lockAccessibility");
            for (let i = 0; i < 6; i++) {   // ax-dest-lockScreen--accessibility-options: switches 539,129.5 every 37.5
                const sw = findChild(it, "lockAx" + i).mapToItem(root, 0, 0);
                near(sw.x, 539, 1, "switch x"); near(sw.y, 129.5 + i * 37.5, 2, "switch " + i);
            }
            let done = findChild(it, "sheetDone").mapToItem(root, 0, 0);
            near(done.x, 521, 0.5, "Done x"); near(done.y, 508, 1, "Done y");
            sheet("lockAccessibility").close();
            app.open("privacy");
            sheet("privacyAdvanced").open();
            it = sheetItem("privacyAdvanced");
            const sw = findChild(it, "privacyAdminSwitch").mapToItem(root, 0, 0);
            near(sw.x, 539, 1, "admin switch x"); near(sw.y, 243.5, 3, "admin switch y");
            done = findChild(it, "sheetDone").mapToItem(root, 0, 0);
            near(done.x, 521, 0.5, "Done x"); near(done.y, 368, 1, "Done y");
            sheet("privacyAdvanced").close();
            app.open("wallpaper");
            sheet("wallpaperScreenSaver").open();
            it = sheetItem("wallpaperScreenSaver");
            near(at(it, "Start Screen Saver…").x, 150, 0.5, "x");
            near(at(it, "Start Screen Saver…").y, 203, 2.5, "Start Screen Saver…");
            near(at(it, "Use Screen Saver").y, 240.5, 2.5, "Use Screen Saver");
            done = findChild(it, "sheetDone").mapToItem(root, 0, 0);
            near(done.x, 536, 0.5, "Done x"); near(done.y, 556, 1, "Done y");
            sheet("wallpaperScreenSaver").close();
        }
        function test_clock_popover() {
            app.open("wallpaper");
            const pop = findChild(app, "wallpaperClockPopover");
            verify(pop && !pop.shown);
            click(findChild(app, "wallpaperClockButton"));
            compare(pop.shown, true);
            verify(pop.visible);
            verify(has(pop, "Show large clock"));
            verify(has(pop, "On Lock Screen"));
            verify(has(pop, "Weight"));
            wait(700);   // the popover grows out of its arrow
            // under the button (ax: button 578.5,153 145.5 x 24; the popover's content from y 200.5); inside the window here
            const face = findChild(pop, "clockFace0");
            const p = face.mapToItem(root, 0, 0);
            near(p.y, 253, 3, "faces' y");
            verify(p.x > 232 && findChild(pop, "clockFace5").mapToItem(root, 38, 0).x < 740, "inside the window");
            compare(pop.face, 0);
            mouseClick(findChild(pop, "clockFace3"));
            compare(pop.face, 3);
            fuzzyCompare(findChild(pop, "clockWeight").value, 0.7067, 1e-6);
            mouseClick(root, 300, 500);   // a click outside closes it
            compare(pop.shown, false);
        }

        // ---------- pop-up buttons: R13.2 popups.json ----------
        readonly property var colors: ["Automatic", "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite", "Choose Color…"]
        readonly property var times: ["For 1 minute", "For 2 minutes", "For 3 minutes", "For 5 minutes", "For 10 minutes", "For 20 minutes", "For 30 minutes",
            "For 1 hour", "For 1 hour, 30 minutes", "For 2 hours", "For 2 hours, 30 minutes", "For 3 hours", "Never"]
        function test_popups_data() {
            return [
                { tag: "highlightPopup", pane: "appearance", model: colors, seps: [0, 8], index: 0 },
                { tag: "folderColorPopup", pane: "appearance", model: ["Automatic", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Graphite", "Choose Color…"], seps: [0, 8], index: 0 },
                { tag: "sidebarIconSizePopup", pane: "appearance", model: ["Small", "Medium", "Large"] },
                { tag: "dockPosition", pane: "dock", model: ["Left", "Bottom", "Right"] },
                { tag: "dockMinimize", pane: "dock", model: ["Genie Effect", "Scale Effect"] },
                { tag: "dockDoubleClick", pane: "dock", model: ["Fill", "Zoom", "Minimize", "No Action"], seps: [2], index: 1 },
                { tag: "dockClickWallpaper", pane: "dock", model: ["Always", "Only in Stage Manager"], index: 0 },
                { tag: "dockShowWindows", pane: "dock", model: ["All at Once", "One at a Time"], index: 0 },
                { tag: "dockDimWidgets", pane: "dock", model: ["Automatically", "Always", "Never"], index: 0 },
                { tag: "dockBrowser", pane: "dock", model: ["Safari"], index: 0 },
                { tag: "dockPreferTabs", pane: "dock", model: ["Never", "Always", "In Full Screen"], index: 2 },
                { tag: "displaysColorProfile", pane: "displays", index: 9, seps: [9], model: ["ACES CG Linear (Academy Color Encoding System AP1)", "Adobe RGB (1998)",
                    "SMPTE RP 431-2-2007 DCI (P3)", "Display P3", "Generic RGB Profile", "Rec. ITU-R BT.2020-1", "Rec. ITU-R BT.709-5", "ROMM RGB: ISO 22028-2:2013",
                    "sRGB IEC61966-2.1", "Color LCD", "Customize…"] },
                { tag: "displaysTV", pane: "displays", model: ["Ask What to Show", "Mirror Entire Screen", "Choose Window or App", "Use as Extended Display"], index: 0 },
                { tag: "wallpaperFill", pane: "wallpaper", model: ["Fill Screen", "Fit to Screen", "Stretch to Fill Screen", "Center", "Tile"], index: 0 },
                { tag: "notifPreviews", pane: "notifications", model: ["Always", "When Unlocked", "Never"] },
                { tag: "notifMirroring", pane: "notifications", model: ["Notifications Off", "Allow Notifications"] },
                { tag: "soundAlert", pane: "sound", first: "Boop", count: 14 },
                { tag: "soundEffectsThrough", pane: "sound", first: "Selected Sound Output Device" },
                { tag: "lockOffBattery", pane: "lockscreen", model: times, index: 4, hidden: !AppState.hasBattery },
                { tag: "lockOffAdapter", pane: "lockscreen", model: times },
                { tag: "lockRequirePassword", pane: "lockscreen", first: "Immediately" },
                { tag: "privacyAllowApps", pane: "privacy", model: ["App Store", "App Store & Known Developers"], index: 1 },
                { tag: "keyboardBacklight", pane: "keyboard", model: ["After 5 Seconds", "After 10 Seconds", "After 30 Seconds", "After 1 Minute", "After 5 Minutes", "Never"], index: 2 },
                { tag: "keyboardGlobe", pane: "keyboard", model: ["Change Input Source", "Show Emoji & Symbols", "Start Dictation (Press 🌐 Twice)", "Do Nothing"], index: 1 },
                { tag: "keyboardDictationShortcut", pane: "keyboard", count: 7, last: "Customize…", seps: [0, 5], index: 0 },
                { tag: "trackpadLookUp", pane: "trackpad", model: ["Off", "Force Click with One Finger", "Tap with Three Fingers"], index: 1 },
                { tag: "trackpadSecondary", pane: "trackpad", model: ["Off", "Click with Two Fingers", "Click in Bottom-Right Corner", "Click in Bottom-Left Corner"], index: 1 },
                { tag: "aiReportDuration", pane: "privacy", sub: "aireport", model: ["15 minutes"], index: 0 },
                { tag: "accessoriesPopup", pane: "privacy", sub: "accessories", model: ["Ask for new accessories"], index: 0 },
                { tag: "passwordsCodesIn", pane: "general", sub: "passwords", model: ["Passwords"], index: 0 }
            ];
        }
        function test_popups(d) {
            app.open(d.pane, d.sub || "");
            wait(30);
            const pop = findChild(app, d.tag);
            verify(pop, "pop-up " + d.tag);
            if (d.model) compare(pop.model, d.model);
            if (d.first) compare(pop.model[0], d.first);
            if (d.last) compare(pop.model[pop.model.length - 1], d.last);
            if (d.count) compare(pop.model.length, d.count);
            if (d.index !== undefined) compare(pop.currentIndex, d.index);
            compare(pop.separators, d.seps || (d.tag === "soundEffectsThrough" ? pop.separators : []));
            if (d.hidden) return;
            // the menu opens over the button and closes on a click outside, the value unchanged
            const menu = findChild(pop, "menu"), before = pop.currentIndex;
            reveal(pop);
            mouseClick(pop);
            tryVerify(() => menu.opened);
            mouseClick(root, 5, 300);
            tryVerify(() => !menu.visible);
            compare(pop.currentIndex, before);
        }
        // an item that acts instead of being chosen leaves the choice as it was
        function test_popup_action_items() {
            app.open("displays");
            const pop = findChild(app, "displaysColorProfile");
            pop.activated(10);
            compare(pop.currentIndex, 9);
            pop.activated(3);
            compare(pop.currentIndex, 3);
            pop.activated(9);
            app.open("appearance");
            const hl = findChild(app, "highlightPopup"), was = AppState.appearance.highlight;
            hl.activated(9);
            compare(AppState.appearance.highlight, was);
        }
        function test_notifications_mirroring() {
            app.open("notifications");
            const pop = findChild(app, "notifMirroring"), was = AppState.notifications.whenMirroring;
            pop.activated(1);
            compare(AppState.notifications.whenMirroring, true);
            compare(pop.currentIndex, 1);
            pop.activated(0);
            compare(AppState.notifications.whenMirroring, false);
            AppState.set("notifications", { whenMirroring: was });
        }

        // ---------- Keyboard Shortcuts: the 14 groups (R13.3) ----------
        function test_shortcut_groups_data() {
            const rows = [1, 2, 9, 5, 10, 2, 7, 2, 7, 3, 10, 1, 0, 0];
            return KD.shortcutGroups.map((g, i) => ({ tag: g.title, index: i, rows: rows[i], kind: g.kind,
                first: g.rows ? g.rows[0].t : i === 12 ? "Use F1, F2, etc. keys as standard function keys" : "Select keyboard" }));
        }
        function test_shortcut_groups(d) {
            compare(KD.shortcutGroups.length, 14);
            app.open("keyboard");
            const s = sheet("keyboardShortcuts");
            s.open();
            const item = sheetItem("keyboardShortcuts");
            mouseClick(findChild(item, "sheetSidebarRow" + d.index));
            wait(30);
            compare(KD.shortcutGroups[d.index].rows ? KD.shortcutGroups[d.index].rows.length : 0, d.rows);
            verify(has(item, d.first), d.first);
            const instruction = "To change a shortcut, double-click the key combination, then type the new keys.";
            compare(has(item, instruction), d.kind === "list" || d.kind === "apps");
            compare(findChild(item, "shortcutsRestore").visible, d.index !== 11 && d.index !== 12);
            if (d.rows > 0) {   // ax-ks-NN: the first row's name at y 151, x 303 (Dock, Display) or 312; App Shortcuts' heading at 314
                const t = texts(findChild(item, "shortcutRow0"), []).find(t => t.text === d.first);
                verify(t, "the first row's name");
                const p = t.mapToItem(root, 0, 0);
                near(p.y, 151, 1.5, "first row y");
                near(p.x, d.index < 2 ? 303 : d.index === 11 ? 314 : 312, 1, "first row x");
            }
            s.close();
        }
        function test_shortcut_rows() {
            app.open("keyboard");
            const s = sheet("keyboardShortcuts");
            s.open();
            const item = sheetItem("keyboardShortcuts");
            mouseClick(findChild(item, "sheetSidebarRow2"));   // Mission Control
            wait(30);
            near(at(item, "Game Overlay").y, 343, 1.5, "Game Overlay");
            near(at(item, "Quick Note").y, 319, 1.5, "Quick Note");
            verify(labels(item).filter(t => t === "none").length === 3);
            const box = findChild(item, "shortcutBox1"), mixed = findChild(item, "shortcutBox6");
            compare(box.checked, false);                       // Show Notification Center: off on the Mac
            compare(mixed.mixed, true);                        // the collapsed Mission Control group
            mouseClick(box);
            compare(box.checked, true);
            mouseClick(findChild(item, "shortcutsRestore"));
            compare(box.checked, false);
            mouseClick(findChild(item, "sheetSidebarRow6"));   // Screenshots: a two-line row is 40 tall
            wait(30);
            compare(findChild(item, "shortcutRow3").height, 40);
            near(at(item, "Screenshot and recording options").y, 263, 1.5, "after the tall row");
            mouseClick(findChild(item, "sheetSidebarRow13"));  // Modifier Keys
            wait(30);
            near(at(item, "Select keyboard").y, 108, 1.5, "Select keyboard");
            near(at(item, "Caps Lock (⇪) key").y, 204.2, 2, "Caps Lock");
            near(at(item, "Globe (🌐︎) key").y, 357.2, 3, "Globe");
            compare(findChild(item, "modifierKey0").model, ["⇪ Caps Lock"]);
            mouseClick(findChild(item, "sheetSidebarRow12"));  // Function Keys
            wait(30);
            near(at(item, "Use F1, F2, etc. keys as standard function keys").y, 108, 1.5, "Function Keys");
            compare(findChild(item, "shortcutsFnSwitch").checked, false);
            s.close();
        }

        // ---------- positions against the Mac's AX frames ----------
        function test_geometry_focus() {
            app.open("focus");
            let p = paneItem();
            wait(40);
            near(at(p, "Do Not Disturb").y, 82, 1.5, "first mode");
            near(at(p, "Work").y, 347, 2, "Work");
            near(findChild(app, "focusAdd").mapToItem(root, 0, 0).y, 391, 1.5, "Add Focus…");
            near(at(p, "Share across devices").y, 435, 2, "Share across devices");
            app.open("focus", "dnd");
            wait(40);
            near(at(p, "Do Not Disturb").x, 293, 3.5, "name x"); near(at(p, "Do Not Disturb").y, 78.5, 1.5, "name y");
            near(at(p, "Intelligent Breakthrough and Silencing").y, 129, 1.5, "Intelligent");
            near(at(p, "Allow Notifications").y, 229, 1.5, "Allow Notifications");
            near(at(p, "Set a Schedule").y, 438.5, 2, "Set a Schedule");
            near(at(p, "No Schedules").y, 505.5, 2, "No Schedules");
            near(at(p, "Focus Filters").y, 605, 2.5, "Focus Filters");
            near(at(p, "No Focus filters").y, 658, 3, "No Focus filters");
            app.open("focus", "sleep");
            wait(40);
            near(at(p, "Sleep").x, 296, 0.5, "name x"); near(at(p, "Sleep").y, 81.5, 1.5, "name y");
            near(at(p, "Allow Notifications").y, 235, 1.5, "Allow Notifications");
            near(at(p, "Focus Filters").y, 542.5, 2.5, "Focus Filters");
            app.open("focus", "driving");
            wait(40);
            verify(!has(p, "Allowed Apps") && !has(p, "Focus Filters") && !has(p, "Set a Schedule"));
            app.open("focus", "status");
            wait(40);
            near(at(p, "Share Focus status").y, 74, 1, "Share Focus status");
            near(at(p, "Share From").y, 160, 1.5, "Share From");
            near(at(p, "Do Not Disturb").y, 211.5, 1.5, "first switch row");
            near(at(p, "Work").y, 399, 2, "last switch row");
        }
        function test_geometry_privacy() {
            app.open("privacy");
            let p = paneItem();
            wait(40);
            // ax-dest-privacyAndSecurity--advanced-dark.jsonl (the root behind the sheet): row tops + the label's inset
            near(at(p, "Location Services").y, 139.5 + 13, 2, "Location Services");
            near(at(p, "Calendars").y, 191.5 + 9, 1.5, "Calendars");
            near(at(p, "App Management").y, 677.5 + 13, 2.5, "App Management");
            near(at(p, "Speech Recognition").y, 1236.5 + 13, 3, "Speech Recognition");
            near(at(p, "Apple Intelligence Report").y, 1487.5 + 13, 3, "Apple Intelligence Report");
            near(at(p, "Security").y, 1559.6, 3, "Security");
            near(at(p, "FileVault").y, 1633 + 13, 3, "FileVault");
            near(at(p, "Lockdown Mode").y, 1771 + 13, 3.5, "Lockdown Mode");
            // no application is listed (the Mac's are redacted, R13 and R14): a table class is its line and the strip
            app.open("privacy", "appmanagement");
            wait(40);
            near(at(p, "Allow the applications below to update or delete other applications.").y, 74, 1, "the line");
            verify(!findChild(app, "privacySwitch0"), "no sample application");
            // a class with applications on the Mac shows the Mac's line for none (SecurityPrivacyExtension.appex)
            app.open("privacy", "camera");
            wait(40);
            verify(findChild(app, "privacyEmpty").visible);
            compare(findChild(app, "privacyEmpty").text, "Applications that have requested access to your camera will appear here.");
            near(findChild(app, "privacyEmpty").mapToItem(root, 0, 0).y, 322.5, 1, "the empty line");
            app.open("privacy", "calendars");
            wait(40);
            const e = findChild(app, "privacyEmpty").mapToItem(root, 0, 0);
            near(e.y, 322.5, 1, "the empty line"); near(e.x, 338.8, 4, "its x");
            app.open("privacy", "analytics");
            wait(40);
            near(at(p, "Share Mac Analytics").y, 123.1, 1.5, "Share Mac Analytics");
            near(at(p, "Improve Assistive Voice Features").y, 277.1, 2, "Improve Assistive Voice Features");
            near(at(p, "Share iCloud Analytics").y, 431.1, 2.5, "Share iCloud Analytics");
            app.open("privacy", "filevault");
            wait(40);
            near(at(p, "Password Reset").y, 160, 1.5, "Password Reset");
            near(at(p, "Recovery Key").y, 229.5, 1.5, "Recovery Key");
            app.open("privacy", "photos");
            wait(40);
            compare(findChild(app, "privacyEmpty").text, "Applications that have requested access to your photos will appear here.");
            for (const name of ["Safari", "Terminal", "Finder", "Music"])
                for (const id of ["location", "contacts", "files", "fulldisk", "media", "photos", "camera", "microphone", "screenrecording"]) {
                    app.open("privacy", id);
                    wait(20);
                    verify(labels(p).indexOf(name) === -1, id + " lists no " + name);
                }
        }
        function test_geometry_general() {
            app.open("general");
            let p = paneItem();
            wait(40);
            // ax-general-light.jsonl: the rows at 394 (AppleCare), 452 (AirDrop), 510 (AutoFill), 862 (Device Management),
            // 920 (Transfer). AppleCare & Warranty is hidden by the user's choice (2026-11-15, settings/FALLBACKS.md):
            // no such row or sub-pane, and the rows after it are 58 pt (its card and gap) higher than the Mac's
            verify(!findChild(app, "generalRow-applecare"), "no AppleCare & Warranty row");
            verify(labels(p).indexOf("AppleCare & Warranty") === -1, "no AppleCare & Warranty label");
            verify(p.subs.applecare === undefined, "no AppleCare & Warranty sub-pane");
            near(findChild(app, "generalRow-airdrop").mapToItem(root, 0, 0).y, 394, 1, "AirDrop & Continuity");
            near(findChild(app, "generalRow-passwords").mapToItem(root, 0, 0).y + flick().contentY, 452, 1.5, "AutoFill & Passwords");
            near(findChild(app, "generalRow-devicemanagement").mapToItem(root, 0, 0).y + flick().contentY, 804, 2.5, "Device Management");
            near(findChild(app, "generalRow-transfer").mapToItem(root, 0, 0).y + flick().contentY, 862, 2.5, "Transfer or Reset");
            app.open("general", "passwords");
            wait(40);
            near(at(p, "All Your Passwords in One Place").x, 299, 0.5, "tile title x");
            near(at(p, "All Your Passwords in One Place").y, 78, 1, "tile title y");
            near(at(p, "AutoFill Passwords and Passkeys").y, 236.5, 1.5, "AutoFill Passwords and Passkeys");
            near(at(p, "AutoFill from").y, 322.5, 1.5, "AutoFill from");
            near(at(p, "Verification Codes").y, 430.5, 2, "Verification Codes");
            near(at(p, "Set Up Codes In").y, 542.5, 2, "Set Up Codes In");
            app.open("general", "devicemanagement");
            wait(40);
            near(at(p, "No profiles installed").y, 222, 1.5, "No profiles installed");
            near(at(p, "No profiles installed").x, 425.8, 1.5, "its x");
        }
    }
}
