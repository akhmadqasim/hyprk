import QtQuick
import QtTest
import ".."
import "../HyprK"

// Round 13 destinations and pop-up menus of Wi-Fi, Network (Firewall, a service, VPN), Battery, Menu Bar and Spotlight
// (MAC-ANSWERS-13.md R13.1, R13.2; reference/re/27.2.1/live/settings-r13/DESTINATIONS.md, popups.json): each row or
// button is clicked with the mouse and its destination checked: a pushed sub-pane (toolbar title, Go Back) or a sheet
// at the Mac's size and place. A sample of positions is compared with the Mac's AX frames (window coordinates, pt:
// ax-dest-*-dark.jsonl minus the window's 350,150). Every pop-up is opened and its items compared with the Mac's.
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_destinations_r13.qml
// No process runs here (plain qml): the lists are given. State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "wifi"; windowActive: true }

    TestCase {
        name: "SettingsDestinationsR13"
        when: windowShown

        property bool hadBattery: false
        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = 24 * 3600 * 1000; hadBattery = AppState.hasBattery; }
        function cleanupTestCase() { AppState._flush.stop(); AppState._patches = {}; AppState.hasBattery = hadBattery; }
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
        function at(item, s) {
            wait(20);   // columns are laid out on polish
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
        // open a sheet with its button and check the Mac's frame (x, y, w, h in the window)
        function openSheet(button, name, x, y, w, h) {
            const s = sheet(name);
            compare(s.shown, false);
            click(findChild(app, button));
            compare(s.shown, true);
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
        // every pop-up button under `item`
        function popups(item, out) {
            for (const c of item.children) {
                if (c.model !== undefined && c.currentIndex !== undefined && c.separators !== undefined) out.push(c);
                else popups(c, out);
            }
            return out;
        }
        // a pop-up with the Mac's items and checked item; it opens on a click and closes on Escape
        function checkPopup(p, items, checked) {
            compare(p.model, items);
            compare(p.model[p.currentIndex], checked);
            const menu = findChild(p, "menu");
            verify(menu);
            if (!p.enabled) return;
            click(p);
            tryVerify(() => menu.opened);
            menu.close();
            tryVerify(() => !menu.visible);
        }
        function wifiPane() {
            wait(30);   // the pane's first refresh answers "no nmcli" on the next turn of the loop
            const p = paneItem();
            p.status = "ok"; p.radioOn = true; p.device = { device: "wlan0", type: "wifi", state: "connected", connection: "Home" };
            p.networks = [{ inUse: true, ssid: "Home", signal: 80, secure: true }, { inUse: false, ssid: "Guest", signal: 50, secure: false }];
            wait(30);
            return p;
        }

        // ---------- Wi-Fi: Details…, Other…, Advanced… ----------
        function test_wifi_details() {
            app.open("wifi");
            const p = wifiPane();
            p.hwAddress = "02:00:00:00:00:01"; p.ipAddress = "192.0.2.10"; p.router = "192.0.2.1";
            const it = openSheet("wifiDetailsButton", "wifiDetails", 35, 100, 670, 425);
            // ax-dest-wifi--details-dark.jsonl
            near(at(it, "Automatically join this network").x, 265, 0.5, "x");
            near(at(it, "Automatically join this network").y, 130, 1.5, "row 1");
            near(at(it, "Private Wi-Fi address").y, 176.5, 2, "Private Wi-Fi address");
            near(at(it, "Wi‑Fi address").y, 271.5, 3, "Wi-Fi address");
            near(at(it, "Low Data mode").y, 317.5, 3.5, "Low Data mode");
            near(at(it, "Limit IP address tracking").y, 384.5, 4, "Limit IP address tracking");
            near(at(it, "Home").x, 85, 0.5, "name x"); near(at(it, "Home").y, 118, 1, "name y");
            near(at(it, "Connected").x, 98.5, 0.5, "state x"); near(at(it, "Connected").y, 135.5, 1, "state y");
            near(at(it, "TCP/IP").x, 51, 0.5, "TCP/IP x"); near(at(it, "TCP/IP").y, 165.5, 1, "TCP/IP y");
            near(at(it, "Hardware").y, 325.5, 1, "Hardware");
            near(pos(findChild(it, "detailCancel")).x, 545, 0.5, "Cancel x"); near(pos(findChild(it, "detailCancel")).y, 481, 0.5, "Cancel y");
            near(pos(findChild(it, "detailOK")).x, 619, 0.5, "OK x");
            near(at(it, "Forget This Network…").x - 12, 255, 0.5, "Forget x");
            verify(labels(it).indexOf("02:00:00:00:00:01") !== -1);
            // the six sections select; only the network's own row is on a shot
            mouseClick(findChild(it, "detailRow0"));
            compare(sheet("wifiDetails").current, 0);
            verify(labels(it).indexOf("Automatically join this network") === -1);
            mouseClick(findChild(it, "detailOwnRow"));
            verify(labels(it).indexOf("Automatically join this network") !== -1);
            keyClick(Qt.Key_Escape);
            closed("wifiDetails");
            sheet("wifiDetails").open();
            mouseClick(findChild(it, "detailOK"));
            closed("wifiDetails");
        }
        function test_wifi_other() {
            app.open("wifi");
            wifiPane();
            const it = openSheet("wifiOtherButton", "wifiOther", 170, 150, 400, 325);
            // ax-dest-wifi--other-dark.jsonl
            near(at(it, "Add a Wi‑Fi Network Profile").x, 238, 1, "placard x");
            near(at(it, "Add a Wi‑Fi Network Profile").y, 180.1, 1.5, "placard y");
            near(at(it, "Network Name").x, 200, 0.5, "Network Name x");
            near(at(it, "Network Name").y, 247.1, 2, "Network Name y");
            near(at(it, "Security").y, 284.1, 2.5, "Security");
            near(at(it, "Password").y, 322.4, 3, "Password");
            near(at(it, "Show password").y, 359.4, 3.5, "Show password");
            const ok = findChild(it, "wifiOtherOK");
            near(pos(ok).x, 484, 0.5, "OK x"); near(pos(ok).y, 431, 0.5, "OK y");
            near(pos(findChild(it, "wifiOtherCancel")).x, 410, 0.5, "Cancel x");
            compare(ok.enabled, false);
            findChild(it, "wifiOtherName").text = "Lab";
            compare(ok.enabled, true);
            mouseClick(ok);
            closed("wifiOther");
            compare(findChild(it, "wifiOtherName").text, "");
            sheet("wifiOther").open();
            mouseClick(findChild(it, "wifiOtherCancel"));
            closed("wifiOther");
        }
        function test_wifi_advanced() {
            app.open("wifi");
            const p = wifiPane();
            const it = openSheet("wifiAdvancedButton", "wifiAdvanced", 135, 52, 470, 532);
            wait(30);   // the sheet's own read answers first (no nmcli here)
            p.known = [{ name: "Home", security: "WPA2 Personal" }, { name: "Cafe", security: "None" }];
            // ax-dest-wifi--advanced-dark.jsonl
            near(at(it, "Require administrator authorization to").x, 165, 0.5, "heading x");
            near(at(it, "Require administrator authorization to").y, 72.1, 1, "heading y");
            near(at(it, "Change networks").y, 108.1, 1.5, "Change networks");
            near(at(it, "Turn Wi‑Fi on or off").y, 145.6, 2, "Turn Wi-Fi on or off");
            near(at(it, "Show legacy networks and options").y, 192.1, 2.5, "Show legacy networks and options");
            near(at(it, "Wi‑Fi MAC address").y, 238.6, 3, "Wi-Fi MAC address");
            near(at(it, "Known Networks").y, 294.6, 4.5, "Known Networks");   // +3.9: a one-row card is 36.5 pt on the Mac, 37.5 / 38 here
            near(at(it, "WPA2 Personal").x, 359, 0.5, "Security Type column");
            near(at(it, "WPA2 Personal").y, 352.5, 5, "first known network");
            verify(labels(it).indexOf("Cafe") !== -1);
            const done = findChild(it, "sheetDone");
            near(pos(done).x, 521, 0.5, "Done x"); near(pos(done).y, 540, 0.5, "Done y");
            mouseClick(done);
            closed("wifiAdvanced");
        }

        // ---------- Network: Wi-Fi, VPN, Firewall and a service push; More ----------
        function networkPane() {
            app.open("network");
            wait(30);   // the pane's first refresh answers with no devices on the next turn of the loop
            const p = paneItem();
            p.devices = [{ device: "wlan0", type: "wifi", state: "connected", connection: "Home" },
                         { device: "eth0", type: "ethernet", state: "unavailable", connection: "" }];
            wait(30);
            return p;
        }
        function test_network_rows_data() {
            return [
                { tag: "wlan0", sub: "wifi", title: "Wi‑Fi", has: "Ask to join networks" },
                { tag: "vpn", sub: "vpn", title: "VPN", has: "About VPNs & Privacy…" },
                { tag: "firewall", sub: "firewall", title: "Firewall", has: "Options…" },
                { tag: "eth0", sub: "svc:eth0", title: "Ethernet", has: "Delete Service…" }
            ];
        }
        function test_network_rows(d) {
            const p = networkPane();
            compare(app.subId, "");
            click(findChild(app, "networkRow-" + d.tag), 100);
            compare(app.subId, d.sub);
            compare(app.currentId, "network");      // the sidebar keeps Network
            compare(title(), d.title);
            verify(labels(p).indexOf(d.has) !== -1, d.has);
            verify(labels(p).indexOf("Other Services") === -1, "the root's rows are gone");
            app.go(-1);
            compare(app.subId, "");
            compare(title(), "Network");
            verify(labels(p).indexOf("Other Services") !== -1);
        }
        function test_network_firewall() {
            const p = networkPane();
            app.open("network", "firewall");
            wait(30);
            // ax-dest-network--firewall-dark.jsonl
            near(at(p, "Firewall").x, 300, 0.5, "Firewall x");
            near(at(p, "Firewall").y, 74, 1, "Firewall y");
            const opt = findChild(app, "firewallOptionsButton");
            near(pos(opt).x, 604, 2.5, "Options x"); near(pos(opt).y, 164, 2, "Options y");
            near(opt.width, 82, 0.5, "Options width");
            const it = openSheet("firewallOptionsButton", "firewallOptions", 120, 52, 500, 532);
            // ax-dest-network--firewall--options-dark.jsonl
            near(at(it, "Block all incoming connections").x, 150, 0.5, "x");
            near(at(it, "Block all incoming connections").y, 82.1, 1.5, "Block all incoming connections");
            verify(labels(it).indexOf("Allow incoming connections") !== -1);
            const pops = popups(it, []);
            verify(pops.length >= 3);
            checkPopup(pops[0], ["Allow incoming connections", "Block incoming connections"], "Allow incoming connections");
            near(pops[0].width, 233.5, 7.5, "the pop-up's width");   // +6.8: the text runs wider here
            near(pos(findChild(it, "firewallOptionsCancel")).x, 460, 0.5, "Cancel x");
            near(pos(findChild(it, "firewallOptionsOK")).x, 534, 0.5, "OK x");
            near(pos(findChild(it, "firewallOptionsOK")).y, 540, 0.5, "OK y");
            mouseClick(findChild(it, "firewallOptionsOK"));
            closed("firewallOptions");
            // the switch is the pane's value: the root's row follows it
            click(findChild(app, "firewallSwitch"));
            compare(p.firewallOn, false);
            app.go(-1);
            compare(findChild(app, "networkRow-firewall").sublabel, "Inactive");
            p.firewallOn = true;
            compare(findChild(app, "networkRow-firewall").sublabel, "Active");   // ax-dest-network-dark.jsonl "Firewall, Active"
        }
        function test_network_service() {
            const p = networkPane();
            app.open("network", "svc:eth0");
            wait(30);
            // ax-dest-network--usb-10-100-1000-lan-dark.jsonl
            near(at(p, "Ethernet").x, 300, 0.5, "name x");
            near(at(p, "Ethernet").y, 78, 1, "name y");
            near(at(p, "Not connected").x, 313.5, 0.5, "state x");
            near(at(p, "Not connected").y, 96, 1, "state y");
            const b = findChild(app, "serviceDetailsButton");
            near(pos(b).x, 634, 1.5, "Details x"); near(pos(b).y, 74, 0.5, "Details y");
            near(at(p, "Delete Service…").x - 12, 252, 0.5, "Delete Service x");
            near(at(p, "Delete Service…").y - 4, 140, 1.5, "Delete Service y");
            const it = openSheet("serviceDetailsButton", "serviceDetails", 35, 100, 670, 425);
            // ax-dest-network--usb-10-100-1000-lan--details-dark.jsonl
            near(at(it, "Name").x, 265, 0.5, "Name x"); near(at(it, "Name").y, 130, 1.5, "Name y");
            near(at(it, "Limit IP address tracking").y, 176, 2.5, "Limit IP address tracking");
            near(at(it, "Proxies").y, 293.5, 1, "Proxies");
            mouseClick(findChild(it, "detailCancel"));
            closed("serviceDetails");
        }
        function test_network_more_menu() {
            networkPane();
            const more = findChild(app, "networkMore");
            verify(more);
            compare(more.width, 61.5);
            // popups.json "network": the top level and its two submenus
            compare(more.titles(), ["Add Service…", "Add VPN Configuration", "Manage Virtual Interfaces…", "Set Service Order…", "Locations"]);
            compare(more.titles(more.items[1].sub), ["L2TP over IPSec…", "Cisco IPSec…", "IKEv2…"]);
            compare(more.titles(more.items[6].sub), ["Automatic", "Edit Locations…"]);
            compare(more.items[6].sub[0].checked, true);
            compare(more.items.filter(i => i.sep).length, 2);
            const menu = findChild(more, "menu");
            click(more);
            tryVerify(() => menu.opened);
            compare(menu.height, 152);              // the Mac's menu: 229 x 152, 3 pt over the button
            near(menu.width, 229, 6, "menu width");
            compare(menu.y, -155);
            more.close();
            tryVerify(() => !menu.visible);
        }
        function test_vpn_add_menu() {
            app.open("vpn");
            const p = paneItem();
            wait(30);
            // ax-dest-network--vpn-dark.jsonl: About VPNs & Privacy… at the left, Add and Help at the right
            near(at(p, "About VPNs & Privacy…").x - 12, 252, 0.5, "About x");
            const add = findChild(app, "vpnAdd");
            near(pos(add).x, 625, 0.5, "Add x");
            compare(add.width, 61);
            compare(add.titles(), ["L2TP over IPSec…", "Cisco IPSec…", "IKEv2…"]);
            const menu = findChild(add, "menu");
            click(add);
            tryVerify(() => menu.opened);
            add.close();
            tryVerify(() => !menu.visible);
        }

        // ---------- Battery: Options…, Low Power Mode ----------
        function test_battery() {
            AppState.hasBattery = true;
            app.open("battery");
            wait(30);
            const p = paneItem();
            checkPopup(popups(p, []).find(x => x.visible), ["Never", "Always", "Only on Battery", "Only on Power Adapter"], "Never");
            const it = openSheet("batteryOptionsButton", "batteryOptions", 135, 139, 470, 347);
            // ax-dest-battery--options-dark.jsonl
            near(at(it, "Slightly dim the display on battery").x, 165, 0.5, "x");
            near(at(it, "Slightly dim the display on battery").y, 169, 1.5, "row 1");
            near(at(it, "Prevent automatic sleeping on power adapter when the display is off").y, 206.5, 2, "row 2");
            near(at(it, "Wake for network access").y, 259.5, 2.5, "Wake for network access");
            near(at(it, "Optimize video streaming while on battery").y, 340.5, 3.5, "Optimize video streaming");
            const done = findChild(it, "sheetDone");
            near(pos(done).x, 521, 0.5, "Done x"); near(pos(done).y, 442, 0.5, "Done y");
            keyClick(Qt.Key_Escape);
            closed("batteryOptions");
        }

        // ---------- Menu Bar: Clock Options…, Battery Options…, pop-ups ----------
        function test_menubar_sheets() {
            app.open("controlcenter");
            let it = openSheet("menuBarClockButton", "menuBarClock", 135, 52, 470, 533);
            // ax-dest-controlCenter--clock-options-dark.jsonl
            near(at(it, "Date").x, 165, 0.5, "Date x"); near(at(it, "Date").y, 72, 1, "Date");
            near(at(it, "Show date").y, 108, 1.5, "Show date");
            near(at(it, "Show the day of the week").y, 145.5, 2, "Show the day of the week");
            near(at(it, "Time").y, 202, 2, "Time");
            near(at(it, "Style").y, 238, 2.5, "Style");
            near(at(it, "Flash the time separators").y, 275.5, 3, "Flash the time separators");
            near(at(it, "Display the time with seconds").y, 313, 3.5, "Display the time with seconds");
            near(at(it, "Announce the time").y, 359.5, 3.5, "Announce the time");
            near(at(it, "Interval").y, 397, 4, "Interval");
            near(at(it, "Voice").y, 435.2, 4.5, "Voice");
            verify(labels(it).indexOf("Analog") !== -1);
            // Interval, Voice and Customize Voice… follow Announce the time
            const interval = findChild(it, "clockInterval");
            compare(interval.enabled, false);
            mouseClick(findChild(it, "clockAnnounce"));
            compare(interval.enabled, true);
            mouseClick(findChild(it, "clockAnnounce"));
            const done = findChild(it, "sheetDone");
            near(pos(done).x, 521, 0.5, "Done x"); near(pos(done).y, 541, 0.5, "Done y");
            mouseClick(done);
            closed("menuBarClock");
            it = openSheet("menuBarBatteryButton", "menuBarBattery", 135, 207, 470, 210);
            // ax-dest-controlCenter--battery-options-dark.jsonl
            near(at(it, "Options").y, 227.1, 1, "Options");
            near(at(it, "Show Percentage").y, 263.1, 1.5, "Show Percentage");
            near(at(it, "Show Energy Mode").y, 300.6, 2, "Show Energy Mode");
            near(pos(findChild(it, "sheetDone")).y, 373, 0.5, "Done y");
            keyClick(Qt.Key_Escape);
            closed("menuBarBattery");
        }
        function test_menubar_popups() {
            app.open("controlcenter");
            wait(30);
            const pops = popups(paneItem(), []);
            // popups.json "controlCenter": the two at the top, then the controls' (off with their checkbox)
            checkPopup(pops[0], ["Always", "On Desktop Only", "In Full Screen Only", "Never"], "In Full Screen Only");
            checkPopup(pops[1], ["None", "5", "10", "15", "20", "30", "50"], "10");
            const show = pops.filter(p => p.model.length === 2 && p.model[0] === "Always Show");
            compare(show.length, 4);
            for (const p of show) compare(p.model, ["Always Show", "Show When Active"]);
            for (const p of show.filter(p => p.enabled)) checkPopup(p, ["Always Show", "Show When Active"], "Show When Active");
        }

        // ---------- Spotlight: Files ⓘ, Search Privacy…, the clipboard pop-up ----------
        function test_spotlight() {
            app.open("spotlight");
            wait(30);
            let it = openSheet("spotlightFilesInfo", "spotlightFileTypes", 120, 52, 500, 533);
            // ax-dest-search--info-dark.jsonl
            near(at(it, "Documents").x, 150, 0.5, "Documents x"); near(at(it, "Documents").y, 72.1, 1, "Documents");
            near(at(it, "Developer").y, 123.5, 2.5, "Developer");
            near(at(it, "Spreadsheets").y, 411.5, 4, "Spreadsheets");
            near(at(it, "Hidden File Types").y, 467.9, 5, "Hidden File Types");
            verify(labels(it).indexOf("No Hidden File Types") !== -1);
            near(pos(findChild(it, "sheetDone")).x, 536, 0.5, "Done x");
            near(pos(findChild(it, "sheetDone")).y, 541, 0.5, "Done y");
            mouseClick(findChild(it, "sheetDone"));
            closed("spotlightFileTypes");
            it = openSheet("spotlightPrivacyButton", "spotlightPrivacy", 135, 125, 470, 375);
            // ax-dest-search--search-privacy-dark.jsonl
            near(at(it, "Privacy").x, 165, 0.5, "Privacy x"); near(at(it, "Privacy").y, 145, 1, "Privacy");
            near(at(it, "Prevent Spotlight from searching these locations.").y, 162.5, 1.5, "its line");
            near(at(it, "No Locations Added").y, 275.5, 3, "No Locations Added");
            near(at(it, "About Search & Privacy…").x - 12, 155, 0.5, "About x");
            near(pos(findChild(it, "sheetDone")).y, 456, 0.5, "Done y");
            keyClick(Qt.Key_Escape);
            closed("spotlightPrivacy");
            const pop = findChild(app, "spotlightClipboardPopup");
            checkPopup(pop, ["30 minutes", "8 hours", "7 days"], "8 hours");   // popups.json "search"
        }

        // ---------- shared: the Help button is the Mac's 24 pt; a disabled radio that is on is grey ----------
        function test_help_button() {
            app.open("network");
            const p = networkPane();
            app.open("network", "svc:eth0");
            wait(30);
            const helps = [findChild(app, "serviceHelp")];
            compare(helps[0].width, 24); compare(helps[0].height, 24);
            near(pos(helps[0]).x, 696, 0.5, "Help x");     // ax-dest-network--usb-10-100-1000-lan-dark.jsonl 696,140
            near(pos(helps[0]).y, 140, 1.5, "Help y");
        }
    }
}
