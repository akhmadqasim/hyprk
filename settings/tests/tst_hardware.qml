import QtQuick
import QtTest
import ".."
import "../HyprK"
import "../Parsers.js" as P
import "../Panes.js" as Panes

// Absent hardware and the shared brightness (the user's choices of 2026-11-15, settings/FALLBACKS.md "Absent
// hardware" and "Brightness"): each hardware-bound pane, row and control hidden without its hardware and shown with
// it, the rows around it closed up; Displays' Brightness slider on AppState.brightness (the shell's state file) both
// ways; several displays. AppState.hw and AppState.brightness are set as scripts/hardware.sh and the shell would
// (Backend runs nothing under qmltestrunner).
// Run: QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen qmltestrunner -input settings/tests/tst_hardware.qml
// State is never written: AppState's write timers are held.
Item {
    id: root
    width: 740; height: 625

    SettingsApp { id: app; anchors.fill: parent; currentId: "appearance"; windowActive: true }

    TestCase {
        name: "SettingsHardware"
        when: windowShown

        readonly property var all: P.parseHardware("wifi=1\nbluetooth=1\nbattery=0\ntrackpad=1\nmouse=1\nkeyboardBacklight=1\nambientLight=1\n", "")
        function hw(patch) { const h = Object.assign({}, all, patch || {}); h.airdrop = h.wifi && h.bluetooth; AppState.hw = h; wait(30); }
        function initTestCase() { AppState.debounce = AppState.appearanceDebounce = AppState.brightnessThrottle = 24 * 3600 * 1000; }
        function cleanup() { AppState._flush.stop(); AppState._brightnessFlush.stop(); AppState._patches = {}; AppState.hasBattery = false; hw(); }
        function cleanupTestCase() { AppState.brightnessLoaded = false; AppState.brightness = P.normalizeBrightness({}); }
        function flick() { return Array.prototype.find.call(app.children, c => c.contentHeight !== undefined); }
        function paneItem() { return flick().contentItem.children[0].item; }
        function ids() { return app.visiblePanes.map(p => p.id); }
        function named(name) { const it = findChild(app, name); verify(it, name); return it; }
        function docY(item) { return item.mapToItem(flick().contentItem, 0, 0).y; }

        // ---------- the sidebar ----------
        function test_pane_data() {
            return [{ tag: "wifi", key: "wifi", pane: "wifi" }, { tag: "bluetooth", key: "bluetooth", pane: "bluetooth" },
                    { tag: "trackpad", key: "trackpad", pane: "trackpad" }, { tag: "mouse", key: "mouse", pane: "mouse" }];
        }
        function test_pane(d) {
            hw();
            const n = ids().length;
            verify(ids().indexOf(d.pane) !== -1, d.pane + " listed with its hardware");
            hw({ [d.key]: false });
            verify(ids().indexOf(d.pane) === -1, d.pane + " not listed without it");
            compare(ids().length, n - 1);
            hw();                                         // plugged in while running
            verify(ids().indexOf(d.pane) !== -1, d.pane + " back");
        }
        function test_battery_pane() {
            verify(ids().indexOf("battery") === -1 && ids().indexOf("energy") !== -1);
            AppState.hasBattery = true;
            verify(ids().indexOf("battery") !== -1 && ids().indexOf("energy") === -1);
        }
        function test_open_pane_goes_with_its_hardware() {
            app.open("wifi");
            compare(app.currentId, "wifi");
            hw({ wifi: false });
            compare(app.currentId, "bluetooth");          // the first pane of the list takes its place
            compare(app.history.length, 1);
            hw({ wifi: false, bluetooth: false });
            compare(app.currentId, "network");
            app.open("displays");
            hw({ trackpad: false });                      // a pane that stays is left alone
            compare(app.currentId, "displays");
        }

        // ---------- rows and controls ----------
        function test_menu_bar_controls() {
            app.open("controlcenter");
            wait(50);
            const wifi = named("menuBarWifiControl"), bt = named("menuBarBluetoothControl"), air = named("menuBarAirdropControl"), bat = named("menuBarBatteryControl");
            compare([wifi.visible, bt.visible, air.visible, bat.visible], [true, true, true, false]);
            const y = docY(wifi);
            hw({ wifi: false });
            compare([wifi.visible, bt.visible, air.visible], [false, true, false]);   // AirDrop needs Wi-Fi too
            compare(docY(bt), y);                         // Bluetooth's row is where Wi-Fi's was
            hw({ bluetooth: false });
            compare([wifi.visible, bt.visible, air.visible], [true, false, false]);
            AppState.hasBattery = true;
            compare(bat.visible, true);
        }
        function test_network_wifi_row() {
            app.open("network");
            wait(50);
            const p = paneItem();
            p.devices = [{ device: "wlan0", type: "wifi", state: "connected", connection: "Home" },
                     { device: "enp5s0", type: "ethernet", state: "connected", connection: "Wired" }];
            wait(30);
            compare(p.shownDevices.map(d => d.device), ["wlan0", "enp5s0"]);
            const y = docY(named("networkRow-wlan0"));
            hw({ wifi: false });
            compare(p.shownDevices.map(d => d.device), ["enp5s0"]);
            verify(!findChild(app, "networkRow-wlan0"));
            compare(docY(named("networkRow-enp5s0")), y);  // Ethernet's row moved up
            hw();
            verify(findChild(app, "networkRow-wlan0"));
            p.devices = [];
        }
        function test_keyboard_backlight_rows() {
            app.open("keyboard");
            wait(50);
            const row = named("keyboardBrightnessAuto"), popup = named("keyboardBacklight");
            compare([row.visible, popup.visible], [true, true]);
            hw({ keyboardBacklight: false });
            compare([row.visible, popup.visible], [false, false]);
        }
        function test_airdrop_card() {
            app.open("general", "airdrop");
            wait(50);
            const card = named("airdropCard");
            compare(card.visible, true);
            hw({ bluetooth: false });
            compare(card.visible, false);
            hw({ wifi: false });
            compare(card.visible, false);
        }
        function test_ambient_light_rows() {
            app.open("displays");
            wait(50);
            compare([named("displaysAutoBrightness").visible, named("displaysTrueTone").visible], [true, true]);
            hw({ ambientLight: false });
            compare([named("displaysAutoBrightness").visible, named("displaysTrueTone").visible], [false, false]);
        }

        // ---------- brightness: one level with the shell ----------
        function test_brightness_follows_the_shell() {
            app.open("displays");
            wait(50);
            const s = named("displaysBrightness");
            AppState.brightnessLoaded = false;
            AppState.brightness = P.normalizeBrightness({});
            compare([s.enabled, s.value], [false, 1]);    // no shell, or nothing can dim the display: disabled, full
            AppState.set("brightness", { value: 0.2 });   // nothing is written before the shell's file was read
            compare(AppState._patches.brightness, undefined);
            // the shell's file arrives (Control Center's slider, a key)
            AppState.brightnessLoaded = true;
            AppState.brightness = P.mergeState('{"value":0.6,"available":true,"source":"ddc","probe":0}', null, P.normalizeBrightness);
            compare([s.enabled, s.value], [true, 0.6]);
            AppState.brightness = P.mergeState('{"value":0.875,"available":true,"source":"ddc","probe":0}', null, P.normalizeBrightness);
            compare(s.value, 0.875);
            AppState.brightness = P.mergeState('{"value":0.875,"available":false,"source":"","probe":0}', null, P.normalizeBrightness);
            compare([s.enabled, s.value], [false, 1]);
        }
        function test_brightness_slider_writes() {
            app.open("displays");
            wait(50);
            const s = named("displaysBrightness");
            AppState.brightnessLoaded = true;
            AppState.brightness = P.mergeState('{"value":0.9,"available":true,"source":"stub","probe":4}', null, P.normalizeBrightness);
            const f = flick();
            f.contentY = Math.max(0, Math.min(f.contentHeight - f.height, docY(s) - 200));
            wait(30);
            mousePress(s, s.width / 2, s.height / 2);
            mouseMove(s, s.width / 2 - 20, s.height / 2);
            mouseRelease(s, s.width / 2 - 20, s.height / 2);
            verify(AppState._patches.brightness !== undefined, "a move is queued for the state file");
            const v = AppState._patches.brightness.value;
            verify(v > 0.1 && v < 0.6, "the level under the pointer: " + v);
            compare(s.value, AppState.brightness.value);
            // what goes to the file keeps the shell's own keys
            compare([AppState.brightness.available, AppState.brightness.source, AppState.brightness.probe], [true, "stub", 4]);
            // a drag is written every brightnessThrottle ms, on its own timer: the other keys' writes keep their delay
            verify(AppState._brightnessFlush.running && !AppState._flush.running);
        }
        function test_brightness_probe_on_open() {
            AppState.brightnessLoaded = true;
            AppState.brightness = P.mergeState('{"value":0.5,"available":false,"source":"","probe":2}', null, P.normalizeBrightness);
            app.open("appearance");
            app.open("displays");
            wait(50);
            compare(AppState.brightness.probe, 3);        // asks the shell to look at the monitors again
            compare(AppState.brightness.value, 0.5);      // and sends no other level
        }

        // ---------- several displays ----------
        function test_several_displays() {
            app.open("displays");
            wait(50);
            const p = paneItem();
            const twins = P.parseHyprMonitors(JSON.stringify([
                { id: 0, name: "DP-1", model: "N27p", width: 2560, height: 1440, x: 0, y: 0, scale: 1, focused: true, refreshRate: 60 },
                { id: 1, name: "DP-2", model: "N27p", width: 2560, height: 1440, x: 2560, y: 0, scale: 1, refreshRate: 60 }]));
            p.monitors = [twins[0]]; p.status = "ok"; p.sel = 0;
            wait(50);
            compare(named("displayName-0").text, "N27p");
            verify(!findChild(app, "displayName-1"));
            compare([named("displaysUseAs").visible, named("displaysArrangeButton").visible], [false, false]);
            p.monitors = twins;
            wait(50);
            compare([named("displayName-0").text, named("displayName-1").text], ["N27p (1)", "N27p (2)"]);
            compare([named("displaysUseAs").visible, named("displaysArrangeButton").visible], [true, true]);
            compare(P.displayRole(p.monitors, p.sel), "Main display");
            p.sel = 1;
            compare(P.displayRole(p.monitors, p.sel), "Extended display");
            compare(p.mon.name, "DP-2");
            p.monitors = []; p.status = "missing";
        }
    }
}
