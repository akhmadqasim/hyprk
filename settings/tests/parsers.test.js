// Run: node --test settings/tests/
// Fixtures are captured command output (real ones from this PC, plus hand-written
// "not available" cases in the formats the tools print).
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const P = require("../Parsers.js");

const fx = name => fs.readFileSync(path.join(__dirname, "fixtures", name), "utf8");

test("nmcli terse split handles escaped colons", () => {
    assert.deepEqual(P.splitTerse("*:Home\\:5G:82:WPA2"), ["*", "Home:5G", "82", "WPA2"]);
});

test("nmcli devices: no wifi hardware", () => {
    const devs = P.parseNmcliDevices(fx("nmcli-devices-nowifi.txt"));
    assert.equal(devs.length, 4);
    assert.equal(P.wifiDevice(devs), null);
});

test("nmcli devices: wifi present", () => {
    const wifi = P.wifiDevice(P.parseNmcliDevices(fx("nmcli-devices-wifi.txt")));
    assert.deepEqual(wifi, { device: "wlp2s0", type: "wifi", state: "connected", connection: "Home:5G" });
});

test("nmcli not running gives no devices", () => {
    assert.deepEqual(P.parseNmcliDevices(fx("nmcli-not-running.txt")), []);
});

test("nmcli wifi list dedupes, drops hidden, sorts", () => {
    const nets = P.parseNmcliWifi(fx("nmcli-wifi-list.txt"));
    assert.deepEqual(nets.map(n => n.ssid), ["Home:5G", "Cafe Free", "Office"]);
    assert.equal(nets[0].inUse, true);
    assert.equal(nets[0].signal, 82);
    assert.equal(nets[1].secure, false);
    assert.deepEqual(P.parseNmcliWifi(""), []);
});

test("wpctl sinks from real status", () => {
    const sinks = P.parseWpctlSinks(fx("wpctl-status.txt"));
    assert.equal(sinks.length, 2);
    assert.deepEqual(sinks[0], { id: 37, name: "Built-in Audio Analog Stereo", isDefault: true, volume: 0.48, muted: false });
    assert.equal(sinks[1].name, "Navi 21/23 HDMI/DP Audio Controller Digital Stereo (HDMI 2)");
    assert.equal(sinks[1].isDefault, false);
});

test("wpctl: no sinks, and Video section is ignored", () => {
    assert.deepEqual(P.parseWpctlSinks(fx("wpctl-status-nosinks.txt")), []);
    assert.deepEqual(P.parseWpctlSinks(""), []);
});

test("wpctl volume", () => {
    assert.deepEqual(P.parseWpctlVolume(fx("wpctl-volume.txt")), { ok: true, volume: 0.48, muted: false });
    assert.deepEqual(P.parseWpctlVolume(fx("wpctl-volume-muted.txt")), { ok: true, volume: 0.35, muted: true });
    assert.equal(P.parseWpctlVolume("Could not connect to PipeWire").ok, false);
});

test("bluetoothctl show", () => {
    const bt = P.parseBluetoothShow(fx("bt-show.txt"));
    assert.deepEqual(bt, { available: true, powered: true, name: "gigabyte-h410m", discoverable: false });
    assert.equal(P.parseBluetoothShow(fx("bt-show-nocontroller.txt")).available, false);
    assert.equal(P.parseBluetoothShow("").available, false);
});

test("bluetoothctl devices", () => {
    assert.deepEqual(P.parseBluetoothDevices(fx("bt-devices.txt")), [{ mac: "68:3E:C0:CC:F5:04", name: "AirPods Pro" }]);
    assert.deepEqual(P.parseBluetoothDevices(fx("bt-connected.txt")), []);
});

test("hyprctl monitors", () => {
    const mons = P.parseHyprMonitors(fx("hyprctl-monitors.json"));
    assert.equal(mons.length, 2);
    assert.equal(mons[0].width, 3840);
    assert.equal(mons[0].refreshRate, 60);
    assert.equal(mons[0].scale, 1.5);
    assert.equal(mons[1].description, "Generic 24");
    assert.deepEqual(P.parseHyprMonitors("HYPRLAND_INSTANCE_SIGNATURE not set!"), []);
    assert.deepEqual(P.parseHyprMonitors("{}"), []);
});

test("battery detection", () => {
    assert.equal(P.hasBattery("Mains\nBattery\n"), true);
    assert.equal(P.hasBattery("Mains\n"), false);
    assert.equal(P.hasBattery(""), false);
});

test("appearance.json defaults and round trip", () => {
    assert.deepEqual(P.readState("", P.normalizeAppearance), P.appearanceDefaults);
    assert.deepEqual(P.readState("{broken", P.normalizeAppearance), P.appearanceDefaults);
    // file written by the shell with only {dark}
    const a = P.readState('{"dark": true}', P.normalizeAppearance);
    assert.equal(a.mode, "dark");
    assert.equal(a.dark, true);
    const written = JSON.parse(P.writeState(a, { mode: "light", reduceTransparency: 1 }, P.normalizeAppearance));
    assert.equal(written.dark, false);
    assert.equal(written.reduceTransparency, true);
    assert.equal(P.readState('{"glass": 7}', P.normalizeAppearance).glass, 1);
    assert.equal(P.readState('{"glass": "x"}', P.normalizeAppearance).glass, 0.5);
    // unknown keys from the shell survive
    assert.equal(JSON.parse(P.writeState({ extra: 5 }, {}, P.normalizeAppearance)).extra, 5);
});

test("dock.json defaults and clamping", () => {
    assert.deepEqual(P.readState("", P.normalizeDock), P.dockDefaults);
    const d = P.readState('{"size": 500, "magnifiedSize": 10, "position": "top"}', P.normalizeDock);
    assert.equal(d.size, 128);
    assert.equal(d.magnifiedSize, 128);
    assert.equal(d.position, "bottom");
    assert.equal(JSON.parse(P.writeState(d, { size: "abc" }, P.normalizeDock)).size, 48);
});
