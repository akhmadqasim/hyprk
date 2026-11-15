import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../Parsers.js" as P

// Round 15 (reference/re/MAC-ANSWERS-15.md, reference/re/27.2.1/live/settings-r15/): General > About, Storage and
// Software Update. Each is opened from its row, given the Mac's own values (the pages read this computer's through
// Backend, which runs nothing under qmltestrunner) and compared with the Mac's AX frames (window pt: the dump's frame
// minus the window's 350,150); the buttons, the ⓘ sheets and the states (calculating / sized, checking / up to date)
// are driven with the mouse. Rows the Mac has and this copy leaves out (settings/FALLBACKS.md "General") move what is
// under them up by their own height, which the expected numbers say.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_r15.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "general"; windowActive: true }

    TestCase {
        name: "SettingsRound15"
        when: windowShown

        readonly property real gb: 1e9
        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; }
        function title() { return findChild(app, "toolbarTitle").text; }
        function flick() { return Array.prototype.find.call(app.children, c => c.contentHeight !== undefined); }
        function page() { return findChild(app, "generalSub").item; }
        // an item's place in the document (window pt at scroll offset 0)
        function at(item) { verify(item, "item exists"); const p = item.mapToItem(root, 0, 0); return { x: p.x, y: p.y + flick().contentY, w: item.width, h: item.height }; }
        function named(name) { const it = findChild(app, name); verify(it, name); return it; }
        function texts(item, out) {
            for (const c of item.children) {
                if (!c.visible) continue;
                if (typeof c.text === "string" && c.text !== "" && c.font !== undefined) out.push(c);
                texts(c, out);
            }
            return out;
        }
        function text(s) { const t = texts(page(), []).find(t => t.text === s); verify(t, "text shown: " + s); return t; }
        function has(s) { return texts(page(), []).some(t => t.text === s); }
        function near(got, want, tol, what) { verify(Math.abs(got - want) <= tol, what + ": " + got + " against the Mac's " + want); }
        function click(item) {
            const f = flick(), y = item.mapToItem(f.contentItem, 0, 0).y;
            if (y < f.contentY + 60 || y + item.height > f.contentY + f.height - 10) f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, y - 200));
            wait(30);
            mouseClick(item, item.width / 2, item.height / 2);
        }
        function push(sub, name) {
            app.open("general");
            click(named("generalRow-" + sub));
            compare(app.subId, sub);
            compare(title(), name);
            wait(40);
            return page();
        }
        function sheet(name) { return findChild(root.parent, name + "Sheet"); }

        // ---------- About ----------
        readonly property var macInfo: ({ model: "MacBook Air", vendor: "15-inch, M2, 2023", host: "Mac", chip: "Apple M2", memory: "8 GB",
            osName: "macOS", osLabel: "macOS Golden Gate", osVersion: "27.2.1", osPretty: "macOS Golden Gate 27.2.1", osLogo: "",
            displays: [{ name: "Built-in Liquid Retina Display", size: "15.3-inch (2880 × 1864)" }], diskName: "", avail: 51.65e9, size: 245.11e9, autoUpdates: "" })
        function test_about_layout() {
            const p = push("about", "About");
            p.info = macInfo;
            wait(60);
            // ax-about-00-dark.jsonl: hero text frames at 204 and 237, the first card at 271, rows 37 apart
            near(at(named("aboutModel")).y + named("aboutModel").height / 2, 204.1 + 15.5, 0.75, "model name centre");
            near(at(named("aboutModel")).x + named("aboutModel").width / 2, 486, 0.75, "model name centred");
            near(at(named("aboutModelLine")).y + named("aboutModelLine").height / 2, 237.1 + 7, 0.75, "model line centre");
            near(at(named("aboutName")).y, 271, 0.5, "first card");
            near(at(text("Name")).y + text("Name").height / 2, 289, 1, "Name");
            near(at(text("Chip")).y + text("Chip").height / 2, 326, 1, "Chip");
            near(at(text("Memory")).y + text("Memory").height / 2, 363, 1, "Memory");
            near(at(text("Apple M2")).x + text("Apple M2").width, 710, 0.5, "values end 10 pt in");
            near(at(text("Chip")).x, 262, 0.5, "labels 10 pt in");
            // the Mac's card has two more rows (Serial number, Coverage: 37 + 41) and its system card one more (53)
            near(at(text("macOS")).y + 20, 489.1 - 78, 1, "system heading");   // SectionHeader: 20 pt top padding in the item
            near(at(named("aboutSystem")).y, 515 - 78, 0.5, "system card");
            compare(named("aboutSystem").height, 52);
            verify(has("macOS Golden Gate") && has("Version 27.2.1"));
            near(at(text("Version 27.2.1")).y + text("Version 27.2.1").height / 2, 541 - 78, 1, "version centre");
            near(at(named("aboutDisplay")).y, 676 - 131, 0.5, "display row");
            verify(has("15.3-inch (2880 × 1864)"));
            let b = at(named("aboutDisplaySettings"));
            near(b.y, 739 - 131, 0.5, "Display Settings… y"); near(b.x + b.w, 710, 0.5, "Display Settings… right edge"); compare(b.h, 24);
            near(at(named("aboutDisk")).y, 829 - 131, 0.5, "disk row");
            verify(has("Macintosh HD") && has("51.65 GB available of 245.11 GB"));
            b = at(named("aboutStorageSettings"));
            near(b.y, 892 - 131, 0.5, "Storage Settings… y"); near(b.x + b.w, 710, 0.5, "Storage Settings… right edge");
            b = at(named("aboutSystemReport"));
            near(b.y, 946 - 131, 0.5, "System Report… y"); near(b.x + b.w / 2, 486.25, 1, "System Report… centred");
            // left out (settings/FALLBACKS.md): Apple's rows and the hidden AppleCare coverage
            for (const s of ["Serial number", "Coverage Expired", "Details…", "Intel-Based Apps"]) verify(!has(s), "no " + s);
        }
        function test_about_two_displays() {
            const p = push("about", "About");
            p.info = Object.assign({}, macInfo, { displays: [{ name: "N27p", size: "27-inch (3840 × 2160)" }, { name: "N27p", size: "27-inch (3840 × 2160)" }] });
            wait(60);
            const rows = texts(p, []).filter(t => t.text === "N27p");
            compare(rows.length, 2);
            near(at(rows[1]).y - at(rows[0]).y, 53, 0.5, "display rows 53 apart");
        }
        function test_about_buttons() {
            let p = push("about", "About");
            p.info = macInfo;
            wait(60);                                      // the Displays rows are laid out before click() scrolls to a button
            click(named("aboutStorageSettings"));          // R15.1: navigates to General > Storage
            compare(app.subId, "storage"); compare(title(), "Storage");
            app.go(-1);
            compare(app.subId, "about");
            click(named("aboutDisplaySettings"));          // R15.1: navigates to the Displays pane; Go Back returns
            compare(app.currentId, "displays"); compare(app.subId, "");
            app.go(-1);
            compare(app.currentId, "general"); compare(app.subId, "about");
            click(named("aboutSystemReport"));             // launches another application on the Mac: the press only
            compare(app.subId, "about");
        }

        // ---------- Storage ----------
        readonly property var macCats: [{ id: "applications", name: "Applications", symbol: "appstore" }, { id: "developer", name: "Developer", symbol: "doc" },
            { id: "documents", name: "Documents", symbol: "doc" }, { id: "icloud", name: "iCloud Drive", symbol: "doc" }, { id: "mail", name: "Mail", symbol: "doc" },
            { id: "music", name: "Music", app: "Music" }, { id: "photos", name: "Photos", app: "Photos" }, { id: "trash", name: "Trash", symbol: "trash" }]
        readonly property var macSizes: ({ applications: 30.08 * gb, developer: 1.42 * gb, documents: 17 * gb, icloud: 0.1114 * gb, mail: 1.44 * gb,
            music: 0.5127 * gb, photos: 3.44 * gb, trash: 0, otherusers: 3.4e6, system: 30.81 * gb })
        function storage(sizes) {
            const p = push("storage", "Storage");
            p.cats = macCats; p.systemName = "macOS"; p.size = 245.11 * gb; p.avail = 51.79 * gb; p.sizes = sizes;
            wait(60);
            return p;
        }
        function test_storage_calculating() {
            const p = storage({ documents: 17 * gb });
            // live/settings-r12/ax-nav-general--storage-dark.jsonl: Documents [262,104,30,21], then "Calculating…"
            let b = at(named("storagePart-documents"));
            near(b.x, 262, 0.5, "Documents part x"); near(b.y, 104, 0.5, "bar y"); near(b.w, 30, 0.5, "Documents part"); compare(b.h, 21);
            near(at(named("storageRest")).x, 293, 0.5, "Calculating… part");
            verify(!named("storageSystem").visible, "no system part while calculating");
            verify(has("Calculating…"));
            compare(texts(named("storageLegend"), []).map(t => t.text), ["Documents", "Calculating…"]);
            // every category is listed, the unsized ones with a spinner (16 pt, AX 611.5 + the text to 710)
            for (const c of macCats) verify(findChild(app, "storageRow-" + c.id), c.id + " listed while calculating");
            const sp = named("storageSpinner-applications");
            verify(sp.visible && sp.running); compare(sp.width, 16);
            near(at(sp).x, 612, 1.5, "spinner x");
            verify(!named("storageSize-applications").visible);
            compare(named("storageSize-documents").text, "17 GB");
            verify(named("storageSpinner-systemdata").visible, "System Data waits for the others");
            compare(at(named("storageRow-applications")).h, 42);
            compare(at(named("storageRow-developer")).h, 43);   // its separator on top: the pitch is 43
        }
        function test_storage_done() {
            const p = storage(macSizes);
            compare(named("storageUsed").text, "193.32 GB of 245.11 GB used");
            near(at(named("storageUsed")).x + named("storageUsed").width, 710, 0.5, "used text right edge");
            near(at(named("storageDisk")).x, 262, 0.5, "disk name x");
            // ax-storage-00-dark.jsonl: the parts, largest first, 1 pt apart
            const want = { applications: [262, 54], documents: [317, 30], photos: [348, 5.5], mail: [354.5, 1.5], developer: [357, 1.5], music: [359.5, 1] };
            for (const id in want) {
                const b = at(named("storagePart-" + id));
                near(b.x, want[id][0], 0.5, id + " part x"); near(b.w, want[id][1], 0.5, id + " part width");
            }
            verify(!findChild(app, "storagePart-icloud"), "0.11 GB has no part");
            near(at(named("storageRest")).x, 361.5, 0.5, "System Data part"); near(named("storageRest").width, 197.5, 1.5, "System Data part width");
            near(at(named("storageSystem")).x, 560, 1.5, "system part"); near(named("storageSystem").width, 55, 1, "system part width");
            near(at(named("storageFree")).x, 616, 1, "available part"); near(at(named("storageFree")).x + named("storageFree").width, 710, 0.5, "bar end");
            compare(String(named("storagePart-applications").color), Theme.dark ? "#eb534e" : "#eb4c46");
            // storage-00-*.png: the legend has no Music (1 pt) and no macOS
            compare(texts(named("storageLegend"), []).map(t => t.text), ["Applications", "Documents", "Photos", "Mail", "Developer", "System Data"]);
            // the Mac's list starts at 297.5 under Recommendations (ax-storage-00: the card 468 x 80 at 207.5, its
            // button 123.5 x 24 ending 10 pt inside the card)
            const up = 0;
            const rec = named("storageRecommendations");
            near(at(rec).y + rec.height - 80, 207.5, 0.5, "Recommendations card top"); near(at(rec).y + rec.height, 287.5, 0.5, "Recommendations card bottom");
            const sb = at(named("storageStoreInICloud"));
            near(sb.x + sb.w, 710, 1, "Store in iCloud… right edge");
            near(at(named("storageRow-applications")).y, 297.5 - up, 0.5, "first row");
            const rows = ["applications", "developer", "documents", "icloud", "mail", "music", "photos"];
            for (let i = 0; i < rows.length; i++) near(at(named("storageRow-" + rows[i])).y + (i > 0 ? 1 : 0), 297.5 - up + 43 * i, 0.5, rows[i] + " row");
            verify(!findChild(app, "storageRow-trash"), "an empty category is not listed once sized");
            near(at(named("storageRow-otherusers")).y, 607.5 - up, 0.5, "second card");
            let i = at(named("storageInfo-applications"));
            near(i.x, 691.5, 1, "ⓘ x"); near(i.y, 310 - up, 1, "ⓘ y"); compare(i.w, 17);   // its ink is 691.5..708 on the stills, as the Mac's
            const s = named("storageSize-applications");
            compare(s.text, "30.08 GB");
            near(at(s).x + s.width, 680, 0.5, "size ends 11.5 before the ⓘ");
            // no ⓘ on Other Users & Shared and System Data: the size ends 10 pt in
            verify(!named("storageInfo-otherusers").visible && !named("storageInfo-systemdata").visible && named("storageInfo-system").visible);
            near(at(named("storageSize-systemdata")).x + named("storageSize-systemdata").width, 710, 0.5, "System Data size right edge");
            compare(named("storageSize-otherusers").text, "3.4 MB");
            compare(named("storageSize-systemdata").text, "108.5 GB");   // what is left of the used space
            flick().contentY = Math.max(0, flick().contentHeight - flick().height);
            const help = Array.prototype.filter.call(texts(p, []), t => t.text === "?")[0];
            near(at(help.parent).y, 745.5 - up, 0.5, "Help y"); near(at(help.parent).x, 696, 0.5, "Help x");
            flick().contentY = 0;
        }
        function test_storage_none() {
            const p = storage(Object.assign({}, macSizes, { otherusers: -1 }));
            verify(!findChild(app, "storageRow-otherusers"), "a category this computer does not have is not listed");
        }
        function test_storage_info_sheet() {
            const p = storage(macSizes);
            click(named("storageInfo-developer"));
            const s = sheet("storageInfo");
            tryVerify(() => s && s.shown);
            // R15.2 storage--developer-info: 470 x 400 at 135,112
            compare(s.cardWidth, 470); compare(s.cardHeight, 400); compare(s.cardY, 112);
            compare(named("storageInfoTitle").text, "Developer – 1.42 GB");
            p.sheetItems = P.parseStorageList("10\t/a/Small\n1420000000\t/opt/Command Line Tools\n");
            wait(40);
            const row = findChild(s, "storageInfoRow0");
            verify(row, "first table row");
            compare(texts(row, []).map(t => t.text), ["Command Line Tools", "1.42 GB"]);
            compare(row.height, 24);
            const del = named("storageInfoDelete");
            verify(!del.enabled, "Delete… is disabled: nothing is deleted here");
            const d = del.mapToItem(root, 0, 0);
            near(d.x, 501, 0.5, "Delete… x"); near(d.y, 403, 0.5, "Delete… y"); compare(del.width, 74);
            const done = findChild(s, "sheetDone"), dp = done.mapToItem(root, 0, 0);
            near(dp.x, 521, 0.5, "Done x"); near(dp.y, 468, 0.5, "Done y");
            mouseClick(done);
            tryVerify(() => !s.shown);
        }

        // ---------- Software Update ----------
        function update() {
            const p = push("softwareupdate", "Software Update");
            p.installed = "macOS Golden Gate 27.2.1";
            wait(40);
            return p;
        }
        function test_update_checking() {
            const p = update();
            verify(p.checking, "it checks when opened");
            // ax-software-update-checking-dark.jsonl
            near(at(named("updateChecking")).y, 64, 0.5, "checking card"); compare(named("updateChecking").height, 36);
            const sp = at(named("updateSpinner"));
            near(sp.x, 694, 0.5, "spinner x"); near(sp.y, 74, 0.5, "spinner y"); compare(sp.w, 16); compare(sp.h, 16);
            verify(named("updateSpinner").running);
            near(at(text("Checking for updates…")).x, 262, 0.5, "checking text");
            near(at(named("updateInstalled")).y, 110, 0.5, "Installed card");
            near(at(text("macOS Golden Gate 27.2.1")).x + text("macOS Golden Gate 27.2.1").width, 710, 0.5, "installed value");
            near(at(named("updateAutomatic")).y, 156, 0.5, "Automatic Updates card");
            near(at(named("updateBeta")).y + 1, 195, 0.5, "Beta Updates row");
            near(at(named("updateBeta")).y + named("updateBeta").height, 233, 0.5, "card end");
            const i = at(named("updateAutomaticInfo"));
            near(i.x, 691.5, 1, "ⓘ x"); near(i.y, 165.5, 0.5, "ⓘ y");
            near(at(text("On")).x + text("On").width, 680, 0.5, "value before the ⓘ");
            near(at(named("updateLicense")).y, 253, 0.5, "licence line");
            near(at(named("updateLicense")).x + named("updateLicense").width / 2, 486, 0.75, "licence line centred");
            const help = texts(p, []).find(t => t.text === "?").parent;
            near(at(help).x, 700, 0.5, "Help x"); near(at(help).y, 319, 0.5, "Help y");
            verify(!named("updateUpToDate").visible);
        }
        function test_update_idle_and_check() {
            const p = update();
            p.checkTime = 150;
            tryVerify(() => !p.checking, 2000, "the check ends");
            wait(40);
            // ax-software-update-idle-dark.jsonl
            verify(!named("updateChecking").visible && !named("updateInstalled").visible);
            const st = at(named("updateStatus"));
            compare(named("updateStatus").text, "Your Mac is up to date.");
            near(st.x, 298, 0.5, "status x"); near(st.y + st.h / 2, 82.5, 1, "status centre");
            const sys = at(named("updateStatusSystem"));
            compare(named("updateStatusSystem").text, "macOS Golden Gate 27.2.1");
            near(sys.x, 298, 0.5, "system x"); near(sys.y + sys.h / 2, 98.5, 1, "system centre");
            const b = at(named("updateCheck"));
            near(b.x + b.w, 710, 0.5, "Check for Updates right edge"); near(b.y, 78, 0.5, "Check for Updates y"); compare(b.h, 24); near(b.w, 137.5, 2, "Check for Updates width");
            near(at(named("updateAutomatic")).y, 125.5, 0.5, "Automatic Updates card");
            near(at(named("updateLicense")).y, 222.5, 0.5, "licence line");
            const help = texts(p, []).find(t => t.text === "?").parent;
            near(at(help).y, 288.5, 0.5, "Help y");
            // Check for Updates checks again
            p.checkTime = 400;
            click(named("updateCheck"));
            verify(p.checking && named("updateChecking").visible && named("updateSpinner").running);
            tryVerify(() => !p.checking, 3000);
        }
        function test_update_automatic_sheet() {
            const p = update();
            p.checking = false; p.automatic = "Off";
            wait(40);
            verify(has("Off"));
            click(named("updateAutomaticInfo"));
            const s = sheet("updateAuto");
            tryVerify(() => s && s.shown);
            // R15.3 software-update--automatic-updates-info: 470 x 274 at 135,175
            compare(s.cardWidth, 470); compare(s.cardHeight, 274); compare(s.cardY, 175);
            const sw = ["updateAutoDownload", "updateAutoInstall", "updateAutoSecurity"].map(n => findChild(s, n));
            const ys = [231.5, 269, 315.5];
            for (let i = 0; i < 3; i++) {
                verify(sw[i], "switch " + i);
                const q = sw[i].mapToItem(root, 0, 0);
                near(q.x, 539, 1, "switch x"); near(q.y, ys[i], 1, "switch y");
                verify(!sw[i].checked, "the switches show this computer's setting");
            }
            mouseClick(sw[0]);
            tryVerify(() => sw[0].checked);
            compare(p.automatic, "Off");   // a change stays in the sheet: nothing is written
            const done = findChild(s, "sheetDone"), dp = done.mapToItem(root, 0, 0);
            near(dp.x, 521, 0.5, "Done x"); near(dp.y, 405, 0.5, "Done y");
            mouseClick(done);
            tryVerify(() => !s.shown);
            click(named("updateBetaInfo"));   // an Apple Account sheet on the Mac: the press only
            compare(app.subId, "softwareupdate");
        }
    }
}
