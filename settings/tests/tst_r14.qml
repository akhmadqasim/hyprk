import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../Panes.js" as Panes

// Round 14 (reference/re/MAC-ANSWERS-14.md, re/27.2.1/live/settings-r14): the labels of R14.1, the Firewall > Options
// application list (R14.2), the row tiles cut from the Mac's rows (R14.3), what Accessibility's small controls open
// (R14.4), Displays' Add menu and the Sound > Input list (R14.5), and the application lists without invented names.
// Each destination is opened with the mouse and its frame compared with the Mac's (window pt = screen pt - 350,150).
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_r14.qml
// No process runs here (plain qml): the lists are given. State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "wifi"; windowActive: true }

    TestCase {
        name: "SettingsR14"
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
        function at(item, s) {
            wait(20);
            const t = texts(item, []).find(t => t.text === s);
            verify(t, "text shown: " + s);
            const p = t.mapToItem(root, t.leftPadding || 0, t.topPadding || 0);
            return { x: p.x, y: p.y };
        }
        function near(got, want, tol, what) { verify(Math.abs(got - want) <= tol, what + ": " + got + " against the Mac's " + want); }
        function pos(item) { const p = item.mapToItem(root, 0, 0); return { x: p.x, y: p.y }; }
        function click(item, dx) {
            verify(item, "item exists");
            wait(30);
            const f = flick();
            const y = item.mapToItem(f.contentItem, 0, 0).y;
            if (y < f.contentY + 60 || y + item.height > f.contentY + f.height - 10)
                f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, y - 200));
            wait(30);
            mouseClick(item, dx === undefined ? item.width / 2 : dx, item.height / 2);
        }
        function sheet(name) { const s = findChild(app, name); verify(s, "sheet " + name); return s; }
        function sheetItem(name) { return findChild(root.parent, name + "Sheet"); }
        function shownSheet(name, x, y, w, h) {
            compare(sheet(name).shown, true);
            const it = sheetItem(name);
            verify(it && it.visible);
            compare(it.card.width, w);
            compare(it.card.height, h);
            near(pos(it.card).x, x, 0.5, name + " x");
            near(pos(it.card).y, y, 0.5, name + " y");
            return it;
        }
        function closed(name) {
            compare(sheet(name).shown, false);
            tryCompare(sheetItem(name), "visible", false);
        }
        function esc(name) { keyClick(Qt.Key_Escape); closed(name); }
        // the "Show Detail" button of an AxRow: 17 x 17, 11.5 pt from the row's end
        function showDetail(row) { verify(row, "row exists"); click(row, row.width - 20); }
        function images(item, out) {
            for (const c of item.children) {
                if (c.visible && c.source !== undefined && c.sourceSize !== undefined && String(c.source) !== "") out.push(c);
                images(c, out);
            }
            return out;
        }

        // ---------- R14.1 labels ----------
        function test_labels_wifi() {
            app.open("wifi");
            wait(30);
            const p = paneItem();
            p.status = "ok"; p.radioOn = true; p.device = { device: "wlan0", type: "wifi", state: "connected", connection: "Home" };
            p.networks = [{ inUse: true, ssid: "Home", signal: 80, secure: true }];
            wait(30);
            click(findChild(app, "wifiOtherButton"));
            let it = shownSheet("wifiOther", 170, 150, 400, 325);
            for (const s of ["Add a Wi‑Fi Network Profile", "Enter the name and security type of the profile you want to add.", "Network Name",
                             "Security", "Password", "Show password", "Cancel", "OK"]) verify(has(it, s), s);
            compare(findChild(it, "wifiOtherOK").enabled, false);
            esc("wifiOther");
            click(findChild(app, "wifiAdvancedButton"));
            it = shownSheet("wifiAdvanced", 135, 52, 470, 532);
            for (const s of ["Require administrator authorization to", "Change networks", "Turn Wi‑Fi on or off", "Show legacy networks and options",
                             "Wi‑Fi MAC address", "Known Networks", "Network Name", "Security Type", "Done"]) verify(has(it, s), s);
            esc("wifiAdvanced");
            click(findChild(app, "wifiDetailsButton"));
            it = shownSheet("wifiDetails", 35, 100, 670, 425);
            for (const s of ["TCP/IP", "DNS", "WINS", "802.1X", "Proxies", "Hardware", "Automatically join this network", "Private Wi-Fi address",
                             "Wi‑Fi address", "Low Data mode", "Limit IP address tracking", "IP address", "Router", "Forget This Network…", "Cancel", "OK"])
                verify(has(it, s), s);
            compare(findChild(app, "wifiDetails").sections, ["TCP/IP", "DNS", "WINS", "802.1X", "Proxies", "Hardware"]);
            esc("wifiDetails");
        }
        function test_labels_network_menus() {
            app.open("vpn");
            wait(30);
            const add = findChild(app, "vpnAdd");
            compare(add.width, 61);
            compare(add.titles(), ["L2TP over IPSec…", "Cisco IPSec…", "IKEv2…"]);
            click(add);
            const m = findChild(add, "menu");
            tryVerify(() => m.opened);
            verify(m.y > 0, "the Add menu opens below the button");
            near(m.height, 82, 0.5, "menu height");
            m.close();
            app.open("network");
            wait(30);
            const more = findChild(app, "networkMore");
            compare(more.titles(), ["Add Service…", "Add VPN Configuration", "Manage Virtual Interfaces…", "Set Service Order…", "Locations"]);
            compare(more.items.map(i => i.sep === true), [false, false, true, false, false, true, false]);
            compare(more.titles(more.items[1].sub), ["L2TP over IPSec…", "Cisco IPSec…", "IKEv2…"]);
            compare(more.titles(more.items[6].sub), ["Automatic", "Edit Locations…"]);
            compare(more.items[6].sub[0].checked, true);
        }
        function test_labels_firewall() {
            app.open("network", "firewall");
            wait(40);
            const p = paneItem();
            verify(has(p, "The firewall is turned on and set up to prevent unauthorized applications, programs, and services from accepting incoming connections."));
            p.firewallOn = false;
            wait(20);
            // not captured (R14.1): the extension's own string for the off state, nothing made up
            verify(has(p, "This computer’s firewall is currently turned off. All incoming connections to this computer are allowed."));
            p.firewallOn = true;
        }

        // ---------- R14.2 Firewall > Options: the application list ----------
        function test_firewall_list() {
            app.open("network", "firewall");
            wait(40);
            click(findChild(app, "firewallOptionsButton"));
            const it = shownSheet("firewallOptions", 120, 52, 500, 532);
            const names = ["AirPlayXPCHelper", "audioclocksyncd", "avconferenced", "com.apple.WebKit.Networking"];
            for (const made of ["Finder", "Terminal", "Music"]) verify(!has(it, made), "no " + made);
            let y = 148;                                   // AX: the list starts 96 pt under the sheet's top (298 - 202)
            for (let i = 0; i < names.length; i++) {
                const row = findChild(it, "firewallApp" + i);
                verify(row, "row " + i);
                compare(row.width, 460);
                compare(row.height, i === 3 ? 40 : 32);    // a name on two lines: AX row 6, 490 -> 530
                near(pos(row).x, 140, 0.5, "row x"); near(pos(row).y, y, 1.5, "row " + i + " y");
                const icon = findChild(row, "firewallAppIcon"), name = findChild(row, "firewallAppName"), pop = findChild(row, "firewallAppPopup");
                compare(icon.width, 16); compare(icon.height, 16);
                near(pos(icon).x - pos(row).x, 10, 0.01, "icon x"); near(pos(icon).y - pos(row).y, 4, 0.01, "icon y");
                compare(icon.status, Image.Ready);
                near(pos(name).x - pos(row).x, 28, 0.01, "name x"); near(pos(name).y - pos(row).y, 4, 0.01, "name y");
                compare(name.text, names[i]);
                compare(name.lineCount, i === 3 ? 2 : 1);
                near(pos(pop).x + pop.width - pos(row).x, 450, 0.01, "pop-up right edge");
                near(pos(pop).y - pos(row).y, 4, 0.01, "pop-up y");
                compare(pop.height, 24);
                near(pop.width, 233.5, 8, "pop-up width");
                compare(pop.model, ["Allow incoming connections", "Block incoming connections"]);
                compare(pop.currentIndex, 0);
                compare(pop.dots.length, 2);               // green, red
                y += row.height;
            }
            verify(!findChild(it, "firewallApp4"));
            for (const s of ["Block all incoming connections", "Automatically allow built-in software to receive incoming connections",
                             "Automatically allow downloaded signed software to receive incoming connections", "Enable stealth mode"]) verify(has(it, s), s);
            mouseClick(findChild(it, "firewallOptionsCancel"));
            closed("firewallOptions");
        }

        // ---------- R14.3 row tiles ----------
        function test_tiles_registry() {
            compare(Object.keys(Panes.cropIcons).length, 27);
            for (const id of Object.keys(Panes.cropIcons)) verify(Panes.hasRealIcon(id) && !Panes.isRowIcon(id), id);
            compare(Panes.cropScale("privacy-bluetooth"), 1.2);        // 48 px file, 40 px tile: 24 pt art for the 20 pt tile
            compare(Panes.cropScale("focus-dnd"), 64 / 52);
        }
        function tileOf(row) { return images(row, []).find(i => /\/crops\//.test(String(i.source))); }
        function test_tiles_privacy_data() {
            return ["fulldisk", "passkeys", "appmanagement", "automation", "bluetooth", "developertools", "devicecontrol", "focus", "inputmonitoring",
                    "localnetwork", "motion", "remotedesktop", "speech", "sensitive", "blocked", "analytics", "advertising", "aireport", "filevault",
                    "accessories", "background"].map(id => ({ tag: id }));
        }
        function test_tiles_privacy(d) {
            app.open("privacy");
            wait(30);
            const row = findChild(app, "privacyRow-" + d.tag);
            verify(row);
            const img = tileOf(row);
            verify(img, "the Mac's tile is drawn");
            verify(String(img.source).endsWith("/themes/icons/settings/crops/privacy-" + d.tag + (Theme.dark ? "-dark.png" : "-light.png")));
            tryCompare(img, "status", Image.Ready);
            compare(img.sourceSize.width, 48);
            compare(img.width, 24);                         // the 20 pt tile with its shadow, 1:1 at 2x
            near(img.mapToItem(row, 0, 0).x, 8, 0.01, "the tile 10 pt in the card");
        }
        function test_tiles_focus_data() { return ["dnd", "driving", "mindfulness", "reduce", "sleep", "work"].map(id => ({ tag: id })); }
        function test_tiles_focus(d) {
            app.open("focus");
            wait(30);
            const row = findChild(app, "focusRow-" + d.tag);
            verify(row);
            const img = tileOf(row);
            verify(img, "the Mac's tile is drawn");
            verify(String(img.source).indexOf("/crops/focus-" + d.tag + "-") !== -1);
            tryCompare(img, "status", Image.Ready);
            compare(img.sourceSize.width, 64);
            compare(img.width, 32);                         // the 26 pt tile with its shadow
            near(img.mapToItem(row, 0, 0).x, 10, 0.01, "the tile 13 pt in the card (dest-focus-light.png)");
        }
        function test_tiles_focus_label() {
            app.open("focus");
            wait(30);
            near(at(paneItem(), "Do Not Disturb").x, 252 + 52, 0.6, "the label 13 pt after the tile");
        }

        // ---------- R14.4 Accessibility ----------
        function test_a11y_hover_text_info() {
            app.open("accessibility", "hovertext");
            wait(40);
            showDetail(findChild(app, "hoverTextRow"));
            const it = shownSheet("hoverTextSettings", 135, 57, 470, 510);
            for (const s of ["Hover Text Settings", "Activation modifier", "⌘ Command", "Triple-press modifier to set activation lock", "Appearance",
                             "Shares appearance settings with Hover Color", "Text size", "pt", "Text font", "Text color", "Background color",
                             "Border color", "Element-highlight color", "Done"]) verify(has(it, s), s);
            // acc-hover-text--info-dark.png, px / 2: the title's ink at 331 px, the cards' rows
            near(at(it, "Hover Text Settings").x, 165.5, 0.6, "title x");
            near(at(it, "Activation modifier").y, 113.5, 2, "first row");
            near(at(it, "Text size").y, 260, 2.5, "Text size");
            near(at(it, "Element-highlight color").y, 451.5, 3, "last row");
            mouseClick(findChild(it, "sheetDone"));
            closed("hoverTextSettings");
        }
        function test_a11y_voice_info() {
            app.open("accessibility", "readspeak");
            wait(40);
            showDetail(findChild(app, "systemVoiceRow"));
            // 750 x 450: 10 pt wider than the 740 pt window, centred on it
            const it = shownSheet("voiceInfo", -5, 87.5, 750, 450);
            for (const s of ["English", "Voice", "Voice 4", "Rate", "Pitch", "Speech Volume", "Reset Voice Settings", "Reverts all voice changes to defaults.",
                             "Done", "Bangla", "Aman", "Bulgarian", "Daria", "Danish", "Sara"]) verify(has(it, s), s);
            near(at(it, "Bangla").y - pos(it.card).y, 113.5, 1.5, "the fourth row of the language list");
            const rate = findChild(it, "voiceRate"), pitch = findChild(it, "voicePitch"), volume = findChild(it, "voiceVolume");
            compare(rate.tickMarks, 21); compare(pitch.tickMarks, 21); compare(volume.tickMarks, 20);
            rate.moved(0.9);
            compare(rate.value, 0.9);
            mouseClick(findChild(it, "voiceReset"));
            compare(rate.value, 0.5);
            const done = findChild(it, "voiceDone");
            compare(done.primary, false);
            near(pos(done).x - pos(it.card).x, 666, 0.5, "Done x"); near(pos(done).y - pos(it.card).y, 406, 0.5, "Done y");
            mouseClick(done);
            closed("voiceInfo");
        }
        function test_a11y_voice_control_menu() {
            app.open("accessibility", "voicecontrol");
            wait(40);
            const b = findChild(app, "voiceControlMore");
            verify(b);
            compare(b.width, 61.5); compare(b.height, 24);
            compare(b.titles(), ["Import Vocabulary…", "Export Vocabulary…", "Delete All Vocabulary…", "Import Custom Commands…",
                                 "Export Custom Commands…", "Delete All Custom Commands…"]);
            compare(b.items[3].sep, true);
            click(b);
            const m = findChild(b, "menu");
            tryVerify(() => m.opened);
            verify(m.y < 0, "the menu opens upward");
            near(m.height, 165, 0.5, "menu height");      // 223 x 165 on the Mac
            near(m.width, 223, 12, "menu width");
            m.close();
            tryVerify(() => !m.visible);
        }
        function test_a11y_switch_control() {
            app.open("accessibility", "switchcontrol");
            wait(40);
            const bar = findChild(app, "switchListBar");
            verify(bar);
            compare(bar.glyphs.map(g => g.on), [true, false, false]);   // "−" and "…" disabled without a selected row
            click(bar, 37);                                 // "−": nothing
            click(bar, 62);                                 // "…": nothing
            compare(sheet("switchAdd").shown, false);
            click(bar, 12);                                 // "+"
            const it = shownSheet("switchAdd", 237.5, 251, 265, 122);
            verify(has(it, "Press your switch now…"));
            verify(findChild(it, "switchAddSpinner"));
            compare(findChild(it, "switchAddDone").enabled, false);
            near(pos(findChild(it, "switchAddCancel")).x - pos(it.card).x, 110, 0.5, "Cancel x");
            near(pos(findChild(it, "switchAddDone")).x - pos(it.card).x, 190, 0.5, "Done x");
            mouseClick(findChild(it, "switchAddDone"));
            compare(sheet("switchAdd").shown, true);
            mouseClick(findChild(it, "switchAddCancel"));
            closed("switchAdd");
        }
        function subPage() { return Array.prototype.find.call(paneItem().children, c => c.item !== undefined && c.setSource !== undefined).item; }
        function test_a11y_captions_add() {
            app.open("accessibility", "captions");
            wait(40);
            const pg = subPage();
            compare(pg.styles, ["Transparent Background", "Classic", "Large Text", "Outline Text"]);
            const bar = findChild(app, "captionListBar");
            compare(bar.glyphs.map(g => g.on), [true, false]);
            click(bar, 12);                                 // "+": the style exists at once, selected, and the editor opens
            compare(pg.styles.length, 5);
            compare(pg.styles[4], "Untitled");
            compare(pg.style, 4);
            let it = shownSheet("captionEditor", 70, 52, 600, 533);
            for (const s of ["Style name", "Background", "Background color", "Black", "Background opacity", "Transparent", "Text", "Text color",
                             "White", "Text size", "Medium", "Font", "System Font Medium", "Allow video to override", "Cancel", "OK"]) verify(has(it, s), s);
            compare(findChild(it, "captionName").text, "Untitled");
            // acc-captions--add-dark.png, px / 2 from the sheet's corner (141, 104)
            near(at(it, "Background").x - pos(it.card).x, 30, 0.6, "heading x");
            near(at(it, "Background color").y - pos(it.card).y, 222.5, 2, "Background color");
            near(at(it, "Text color").y - pos(it.card).y, 360, 2, "Text color");
            near(at(it, "Font").y - pos(it.card).y, 442.5, 3, "Font");
            near(pos(findChild(it, "captionCancel")).x - pos(it.card).x, 440, 0.5, "Cancel x");
            near(pos(findChild(it, "captionOK")).y - pos(it.card).y, 489, 0.5, "OK y");
            esc("captionEditor");                        // Escape closes the editor and keeps the style
            compare(pg.styles.length, 5);
            compare(pg.style, 4);
            click(bar, 12);
            compare(pg.styles[5], "Untitled 2");
            it = shownSheet("captionEditor", 70, 52, 600, 533);
            mouseClick(findChild(it, "captionCancel"));     // so does Cancel
            closed("captionEditor");
            compare(pg.styles.length, 6);
            // the selected style made here has "Edit…"; the Mac's four have not
            const row = findChild(app, "captionStyle5");
            verify(findChild(row, "captionEdit").visible);
            verify(!findChild(findChild(app, "captionStyle0"), "captionEdit").visible);
            click(findChild(row, "captionEdit"));
            it = shownSheet("captionEditor", 70, 52, 600, 533);
            findChild(it, "captionName").text = "Mine";
            mouseClick(findChild(it, "captionOK"));
            closed("captionEditor");
            compare(pg.styles[5], "Mine");
            compare(bar.glyphs.map(g => g.on), [true, true]);
            click(bar, 37);                                 // "−" removes it; the first style is selected again
            compare(pg.styles.length, 5);
            compare(pg.style, 0);
            compare(bar.glyphs.map(g => g.on), [true, false]);
        }
        function test_a11y_colour_well() {
            app.open("accessibility", "display");
            wait(40);
            const well = findChild(app, "pointerOutlineWell"), fill = findChild(app, "pointerFillWell"), colors = findChild(app, "colors");
            verify(well && fill && colors);
            compare(well.width, 48); compare(well.height, 24);
            compare(colors.shown, false);
            click(well);
            compare(colors.shown, true);
            compare(well.active, true);
            const panel = findChild(root.parent, "colorsPanel");
            verify(panel && panel.visible);
            compare(panel.width, 266); compare(panel.height, 430);
            verify(has(panel, "Colors"));
            for (let i = 0; i < 5; i++) tryCompare(findChild(panel, "colorMode" + i), "status", Image.Ready);
            const wheel = findChild(panel, "colorWheel");
            compare(wheel.width, 177.5);
            compare(String(findChild(panel, "colorSwatch").color), "#ffffff");
            // the wheel's right end is red; the brightness capsule's right end is black
            mouseClick(wheel, wheel.width - 2, wheel.height / 2);
            verify(well.value.r > 0.99 && well.value.g < 0.05 && well.value.b < 0.05, "red: " + well.value);
            compare(String(findChild(panel, "colorSwatch").color), String(well.value));
            const track = findChild(panel, "colorBrightness");
            mouseClick(track, track.width - 2, track.height / 2);
            compare(String(well.value), "#000000");
            compare(fill.active, false);
            click(fill);                                    // the panel moves to the other well
            compare(fill.active, true); compare(well.active, false);
            mouseClick(findChild(panel, "colorPanelClose"));
            compare(colors.shown, false);
            compare(fill.active, false);
            verify(!panel.visible);
        }
        function test_a11y_zoom_combo() {
            app.open("accessibility", "zoom");
            wait(40);
            const combo = findChild(app, "zoomModifierCombo");
            verify(combo);
            compare(combo.width, 150); compare(combo.height, 24);
            compare(combo.model, ["⌃ Control", "⌥ Option", "⌘ Command"]);
            const before = AppState.accessibility.zoomModifier;
            const list = findChild(combo, "comboList");
            compare(combo.opened, false);
            click(combo, 134);                              // the arrow button, 23.5 x 17.5 at 122.5
            tryVerify(() => combo.opened);
            compare(list.width, 158); compare(list.height, 64);
            near(list.y, combo.height, 2.5, "directly under the field");
            compare(findChild(list.contentItem, "comboRow" + combo.currentIndex).on, true);
            keyClick(Qt.Key_Escape);
            tryVerify(() => !combo.opened);
            compare(AppState.accessibility.zoomModifier, before);   // Escape leaves the value
            click(combo, 134);
            tryVerify(() => combo.opened);
            mouseClick(findChild(list.contentItem, "comboRow2"));
            tryVerify(() => !combo.opened);
            compare(AppState.accessibility.zoomModifier, "command");
            compare(combo.text, "⌘ Command");
            AppState.set("accessibility", { zoomModifier: before });
        }

        // ---------- R14.5 Displays "+", Sound > Input ----------
        function test_displays_add() {
            app.open("displays");
            wait(40);
            const add = findChild(app, "displaysAdd");
            verify(add);
            compare(add.width, 61); compare(add.height, 24);
            near(pos(add).x, 659, 0.5, "Add x"); near(pos(add).y, 171, 0.5, "Add y");
            const p = paneItem();
            p.monitors = [{ name: "eDP-1", description: "Built-in", width: 2560, height: 1600, focused: true },
                          { name: "DP-1", description: "Studio", width: 3840, height: 2160 }, { name: "DP-2", description: "Side", width: 1920, height: 1080 }];
            p.status = "ok"; p.sel = 0;
            wait(20);
            compare(add.items.length, 3);
            compare(add.items[0].title, "Mirror or extend to");
            compare(add.items[0].header, true);
            compare(add.items.slice(1).map(i => i.title), ["Studio", "Side"]);
            compare(add.items[1].glyph, "display");
            click(add);
            const m = findChild(add, "menu");
            tryVerify(() => m.opened);
            near(m.height, 82, 0.5, "menu height");        // 175 x 82 for a heading and two displays
            verify(m.x <= -5, "5 pt left of the button, or further to stay in the window (no popup surface here)");
            verify(m.y > 0);
            const head = findChild(m.contentItem, "menuRow0");
            wait(50);                                       // the menu's rows are laid out on polish
            mouseClick(head);                               // the heading is disabled: it takes the press and nothing happens
            verify(m.opened);
            mouseClick(findChild(m.contentItem, "menuRow1"));
            tryVerify(() => !m.visible);
        }
        function test_sound_input() {
            app.open("sound");
            wait(40);
            const p = paneItem();
            p.status = "ok";
            p.sinks = [{ id: 1, name: "Speakers", isDefault: true, volume: 0.5, muted: false }];
            p.sources = [{ id: 7, name: "Microphone", isDefault: true, volume: 0.6, muted: false }, { id: 8, name: "Camera", isDefault: false, volume: 1, muted: false },
                         { id: 9, name: "Loopback", isDefault: false, volume: 1, muted: false }];
            wait(20);
            const table = findChild(app, "soundTable");
            compare(table.width, 468);
            compare(table.height, 28 + 24);
            verify(has(p, "Output volume") && !has(p, "Input volume"));
            click(texts(p, []).find(t => t.text === "Input").parent, 5);
            wait(20);
            compare(table.height, 100);                     // 28 + 3 x 24 (the Mac's area: 100.5)
            near(at(table, "Name").x - pos(table).x, 8.5, 0.6, "Name x");
            near(at(table, "Type").x - pos(table).x, 306.5, 0.6, "Type x");
            const row = findChild(table, "soundRow0");
            compare(row.height, 24);
            near(pos(row).y - pos(table).y, 28, 0.01, "the header is 28 pt");
            near(at(row, "Microphone").x - pos(row).x, 10, 0.6, "name x");
            near(at(row, "Built-in").x - pos(row).x, 308, 0.6, "type x");
            verify(row.color.a > findChild(table, "soundRow1").color.a, "the default device's row is highlighted");
            verify(has(p, "Input volume") && has(p, "Input level") && !has(p, "Output volume") && !has(p, "Balance"));
            const vol = findChild(app, "soundInputVolume");
            compare(vol.value, 0);                          // no wpctl here
            p.inVol = { ok: true, volume: 0.6, muted: false };
            compare(vol.value, 0.6);
            compare(vol.tickMarks, 7);
            const bars = findChild(app, "soundInputLevel");
            compare(Array.prototype.filter.call(bars.children, c => c.width === 7 && c.height === 15).length, 15);
            near(bars.width, 14 * 17 + 7, 0.01, "15 bars, 17 pt apart");
        }

        // ---------- application lists: nothing the captures do not show ----------
        function test_no_invented_apps() {
            app.open("privacy");
            wait(30);
            const p = paneItem();
            compare(findChild(app, "privacyRow-contacts").sublabel, "None");
            compare(findChild(app, "privacyRow-photos").sublabel, "None");
            compare(findChild(app, "privacyRow-camera").value, "0");
            compare(findChild(app, "privacyRow-location").value, "");
            for (const id of ["location", "contacts", "files", "fulldisk", "media", "photos", "appmanagement", "automation", "bluetooth", "camera",
                              "developertools", "devicecontrol", "focus", "inputmonitoring", "localnetwork", "microphone", "screenrecording", "speech"]) {
                app.open("privacy", id);
                wait(20);
                const shown = labels(p);
                for (const name of ["Safari", "Terminal", "Finder", "Music"]) verify(shown.indexOf(name) === -1, id + ": " + name);
            }
            app.open("privacy", "screenrecording");
            wait(20);
            compare(labels(p).filter(s => s === "No Items").length, 2);
        }
    }
}
