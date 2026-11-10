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

test("hyprctl getoption and eval snippets", () => {
    assert.equal(P.monitorMode({ width: 1920, height: 1080, refreshRate: 60 }), "1920x1080@60");
    assert.equal(P.parseHyprOption('{"option": "input:repeat_rate", "int": 25, "set": false }'), 25);
    assert.equal(P.parseHyprOption("no such option"), null);
    assert.equal(P.luaString('a"b\\c'), '"a\\"b\\\\c"');
    assert.equal(P.luaMonitor("DP-1", "3840x2160@60", 1.5),
        'hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "auto", scale = 1.5 })');
    assert.equal(P.luaInput(30.4, 500), "hl.config({ input = { repeat_rate = 30, repeat_delay = 500 } })");
});

test("battery detection", () => {
    assert.equal(P.hasBattery("Mains\nBattery\n"), true);
    assert.equal(P.hasBattery("Mains\n"), false);
    assert.equal(P.hasBattery(""), false);
});

test("appearance.json defaults and round trip", () => {
    assert.deepEqual(P.mergeState("", {}, P.normalizeAppearance), P.appearanceDefaults);
    assert.deepEqual(P.mergeState("{broken", {}, P.normalizeAppearance), P.appearanceDefaults);
    // file written by the shell with only {dark}
    const a = P.mergeState('{"dark": true}', {}, P.normalizeAppearance);
    assert.equal(a.mode, "dark");
    assert.equal(a.dark, true);
    const written = P.mergeState(JSON.stringify(a), { mode: "light", reduceTransparency: 1 }, P.normalizeAppearance);
    assert.equal(written.dark, false);
    assert.equal(written.reduceTransparency, true);
    assert.equal(P.mergeState('{"glass": 7}', {}, P.normalizeAppearance).glass, 1);
    assert.equal(P.mergeState('{"iconStyle": "neon"}', {}, P.normalizeAppearance).iconStyle, "default");
    assert.equal(P.mergeState('{"iconStyle": "clear"}', {}, P.normalizeAppearance).iconStyle, "clear");
    assert.equal(P.mergeState('{}', {}, P.normalizeAppearance).iconStyleVariant, "auto");
    assert.equal(P.mergeState('{"iconStyleVariant": "dark"}', {}, P.normalizeAppearance).iconStyleVariant, "dark");
    assert.equal(P.mergeState('{"iconStyleVariant": "dim"}', {}, P.normalizeAppearance).iconStyleVariant, "auto");
    assert.equal(P.mergeState('{"glass": "x"}', {}, P.normalizeAppearance).glass, 0.5);
    assert.equal(P.mergeState('{}', {}, P.normalizeAppearance).iconTint, "");
    assert.equal(P.mergeState('{"iconTint": "red"}', {}, P.normalizeAppearance).iconTint, "red");
    assert.equal(P.mergeState('{"iconTint": "teal"}', {}, P.normalizeAppearance).iconTint, "");
    // unknown keys from the shell survive
    assert.equal(P.mergeState(JSON.stringify({ extra: 5 }), {}, P.normalizeAppearance).extra, 5);
});

test("dock.json defaults and clamping", () => {
    assert.deepEqual(P.mergeState("", {}, P.normalizeDock), P.dockDefaults);
    // magnification is off on a clean account (macOS: com.apple.dock magnification 0), also when the key is missing
    assert.equal(P.dockDefaults.magnification, false);
    assert.equal(P.mergeState('{"autohide": true}', {}, P.normalizeDock).magnification, false);
    const d = P.mergeState('{"size": 500, "magnifiedSize": 10, "position": "top"}', {}, P.normalizeDock);
    assert.equal(d.size, 128);
    assert.equal(d.magnifiedSize, 128);
    assert.equal(d.position, "bottom");
    assert.equal(P.mergeState(JSON.stringify(d), { size: "abc" }, P.normalizeDock).size, 48);
});

test("sound.json defaults and clamping", () => {
    assert.deepEqual(P.mergeState("", {}, P.normalizeSound), P.soundDefaults);
    const s = P.mergeState('{"alertSound": "Nope", "alertVolume": 3, "uiSounds": 0}', {}, P.normalizeSound);
    assert.equal(s.alertSound, "Tink");
    assert.equal(s.alertVolume, 1);
    assert.equal(s.uiSounds, false);
    assert.equal(P.mergeState(JSON.stringify(s), { alertSound: "Funk" }, P.normalizeSound).alertSound, "Funk");
});

test("gecosName", () => {
    const pw = "root:x:0:0:root:/root:/bin/bash\nann:x:1000:1000:Ann Lee,,,:/home/ann.lee:/bin/bash\nbob:x:1001:1001::/home/bob:/bin/sh\n";
    assert.equal(P.gecosName(pw, "/home/ann.lee"), "Ann Lee");
    assert.equal(P.gecosName(pw, "/home/bob"), "bob");
    assert.equal(P.gecosName("", "/home/zed"), "zed");
});

test("prettyFileName", () => {
    assert.equal(P.prettyFileName("/w/png/Mac_Blue-dark.png"), "Mac Blue dark");
    assert.equal(P.prettyFileName(""), "");
    assert.equal(P.prettyFileName("/w/DefaultAerial.png"), "Default Aerial");
});

test("lock.json, input.json, notifications.json defaults", () => {
    assert.deepEqual(P.mergeState("", {}, P.normalizeLock), P.lockDefaults);
    assert.equal(P.mergeState('{"displayOffAfter": -5, "largeClock": "x"}', {}, P.normalizeLock).displayOffAfter, 0);
    assert.deepEqual(P.mergeState("", {}, P.normalizeInput), P.inputDefaults);
    assert.equal(P.mergeState('{"repeatRate": 999}', {}, P.normalizeInput).repeatRate, 100);
    assert.deepEqual(P.mergeState("", {}, P.normalizeNotifications), P.notificationsDefaults);
    const n = P.mergeState('{"apps": {"firefox.desktop": {"allow": false, "style": "weird"}}, "previews": "x"}', {}, P.normalizeNotifications);
    assert.deepEqual(n.apps["firefox.desktop"], { allow: false, sounds: true, style: "banners" });
    assert.equal(n.previews, "unlocked");
});

test("desktop apps list", () => {
    const apps = P.parseDesktopApps(fx("notify-apps.txt"));
    assert.deepEqual(apps.map(a => a.id), ["org.gnome.Calendar.desktop", "firefox_firefox.desktop", "org.gnome.Software.desktop"]);
    assert.equal(apps[1].icon, "/snap/firefox/current/default256.png");
    assert.deepEqual(P.parseDesktopApps(""), []);
});

test("icon style sub-choice carries over (PC #60 section 3)", () => {
    assert.deepEqual(P.iconStyleVariantsOf("default"), []);
    assert.deepEqual(P.iconStyleVariantsOf("dark"), ["dark", "auto"]);
    assert.deepEqual(P.iconStyleVariantsOf("tinted"), ["light", "dark", "auto"]);
    assert.equal(P.iconStyleVariantAfter("default", "auto", "clear"), "light");   // Default -> Clear = ClearLight
    assert.equal(P.iconStyleVariantAfter("tinted", "auto", "dark"), "auto");      // Tinted+Auto -> Dark = RegularAutomatic
    assert.equal(P.iconStyleVariantAfter("clear", "light", "dark"), "dark");      // Light is not offered by Dark: Always
    assert.equal(P.iconStyleVariantAfter("dark", "dark", "tinted"), "dark");
});
