// Displays "Looks like" picker: state file, scale-policy.lua report() parsing, chiclets, fallbacks.
// fixtures/scale-report.json is a real report() from a headless Hyprland 0.57.2 with
// HYPRK_NATIVE_HEADLESS_4K=3840x2160 HYPRK_PHYS_MM_HEADLESS_4K=597x336 (and 1920x1080 / 598x336 for HEADLESS_HD).
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const P = require("../Parsers.js");

const report = P.parseScaleReport(fs.readFileSync(path.join(__dirname, "fixtures", "scale-report.json"), "utf8"));
const out = name => report.outputs.find(o => o.name === name);

test("displays.json keeps only WxH sizes per output", () => {
    assert.deepEqual(P.normalizeDisplays(null), { looksLike: {} });
    assert.deepEqual(P.normalizeDisplays({ looksLike: { "DP-1": "2560x1440", "HDMI-A-1": "big", 'a"b': "1x1" }, other: 1 }),
                     { looksLike: { "DP-1": "2560x1440" }, other: 1 });
    assert.deepEqual(P.mergeState("not json", null, P.normalizeDisplays), { looksLike: {} });
});

test("scale report: 4K is HiDPI with the SPEC 14.4 sizes that have a clean scale", () => {
    const o = out("HEADLESS-4K");
    assert.equal(o.hidpi, true);
    assert.equal(o.virtual, false);
    assert.deepEqual(o.def, [1920, 1080]);
    assert.deepEqual(o.choices.map(P.sizeKey),
        ["1024x576", "1152x648", "1280x720", "1600x900", "1920x1080", "2048x1152", "2304x1296", "2560x1440", "3200x1800", "3840x2160"]);
    assert.equal(o.choices.find(c => c.isDefault).w, 1920);
});

test("scale report: 1080p is a 1x list, virtual outputs are flagged", () => {
    const o = out("HEADLESS-HD");
    assert.equal(o.hidpi, false);
    assert.equal(o.choices[o.choices.length - 1].isDefault, true);
    assert.equal(out("MBA").virtual, true);
    assert.equal(out("WAYLAND-1").virtual, true);
});

test("scale report: bad input gives null, bad entries are dropped", () => {
    assert.equal(P.parseScaleReport(""), null);
    assert.equal(P.parseScaleReport("ok"), null);
    assert.equal(P.parseScaleReport('{"outputs": 3}'), null);
    const r = P.parseScaleReport('{"policy":"off","outputs":[{"name":"DP-1","choices":[{"w":0,"h":1},{"w":1920,"h":1080,"scale":2,"default":true}]}, 5]}');
    assert.equal(r.policy, "off");
    assert.equal(r.outputs.length, 1);
    assert.deepEqual(r.outputs[0].choices, [{ w: 1920, h: 1080, scale: 2, isDefault: true }]);
});

test("chiclets: smallest, middle picks, Default, largest (5 for 4K)", () => {
    const c = P.looksLikeChiclets(out("HEADLESS-4K").choices);
    assert.deepEqual(c.map(P.sizeKey), ["1024x576", "1280x720", "1920x1080", "2560x1440", "3840x2160"]);
    assert.deepEqual(c.map(x => x.label), ["Larger Text", "", "Default", "", "More Space"]);
    assert.deepEqual(P.looksLikeChiclets([]), []);
    // fewer than 5 choices: all of them, Default label wins over the end labels
    const two = P.looksLikeChiclets([{ w: 1000, h: 1, isDefault: true }, { w: 2000, h: 1, isDefault: false }]);
    assert.deepEqual(two.map(x => x.label), ["Default", "More Space"]);
});

test("picker block reasons (FALLBACKS.md)", () => {
    assert.match(P.looksLikeBlock(null, null), /could not run/);
    assert.match(P.looksLikeBlock({ policy: "off", outputs: [] }, out("HEADLESS-4K")), /HYPRK_SCALE_POLICY=off/);
    assert.match(P.looksLikeBlock(report, out("MBA")), /virtual display/);
    assert.match(P.looksLikeBlock(report, Object.assign({}, out("HEADLESS-4K"), { source: "env", env: "HYPRK_LOOKS_LIKE" })),
                 /Set by HYPRK_LOOKS_LIKE for this session/);
    assert.equal(P.looksLikeBlock(report, out("HEADLESS-4K")), "");
});

test("selected size: saved choice if offered, else what Hyprland runs; env wins", () => {
    const o = out("HEADLESS-4K");
    assert.equal(P.looksLikeSelected(o, "2560x1440"), "2560x1440");
    assert.equal(P.looksLikeSelected(o, "1504x846"), "1920x1080");
    assert.equal(P.looksLikeSelected(o, ""), "1920x1080");
    assert.equal(P.looksLikeSelected(Object.assign({}, o, { source: "env", looks: [3200, 1800] }), "2560x1440"), "3200x1800");
    assert.equal(P.looksLikeSelected(null, "2560x1440"), "");
});

test("hyprctl eval snippets for scale-policy.lua", () => {
    assert.equal(P.luaScaleSet("/opt/hyprk", "DP-1", "2560x1440"),
                 'dofile("/opt/hyprk/config/hypr/scale-policy.lua").set("DP-1", "2560x1440")');
    assert.equal(P.luaScaleSet("/opt/hyprk", "DP-1", ""), 'dofile("/opt/hyprk/config/hypr/scale-policy.lua").set("DP-1", "")');
    assert.equal(P.luaScaleReport("/opt/hyprk", "/tmp/r.json"), 'dofile("/opt/hyprk/config/hypr/scale-policy.lua").report("/tmp/r.json")');
    assert.equal(P.sizeText(1920, 1080), "1920 × 1080");
});

// ---------- several displays, brightness state, absent hardware (2026-11-15) ----------
const mons = P.parseHyprMonitors(fs.readFileSync(path.join(__dirname, "fixtures", "hyprctl-monitors.json"), "utf8"));
// this PC's real session: two Lenovo N27p side by side (DP-1, DP-2), 2560x1440 at 1x
const twins = P.parseHyprMonitors(JSON.stringify([
    { id: 0, name: "DP-1", description: "Lenovo Group Limited N27p UMA11762", model: "N27p", width: 2560, height: 1440, x: 0, y: 0, scale: 1, focused: true, mirrorOf: "none" },
    { id: 1, name: "DP-2", description: "Lenovo Group Limited N27p UMA79344", model: "N27p", width: 2560, height: 1440, x: 2560, y: 0, scale: 1, mirrorOf: "none" }]));

test("monitors keep their place in the layout", () => {
    assert.deepEqual(mons.map(m => [m.id, m.x, m.y, m.mirrorOf]), [[0, 0, 0, ""], [1, 2560, 0, ""]]);
});

test("display names: the model, else the description; two of one model are numbered", () => {
    assert.deepEqual(P.displayNames(mons), ["DELL U2720Q", "Generic 24"]);
    assert.deepEqual(P.displayNames(twins), ["N27p (1)", "N27p (2)"]);
    assert.deepEqual(P.displayNames([]), []);
});

test("Use as: the display at the origin is the main one, the others extend, a mirror names its source", () => {
    assert.deepEqual([0, 1].map(i => P.displayRole(twins, i)), ["Main display", "Extended display"]);
    const mirrored = twins.map((m, i) => i === 1 ? Object.assign({}, m, { mirrorOf: "DP-1" }) : m);
    assert.equal(P.displayRole(mirrored, 1), "Mirror for N27p (1)");
    assert.equal(P.mainDisplay([{ x: 100, y: 0 }, { x: 0, y: 0 }]), 1);
    assert.equal(P.mainDisplay([{ x: 5, y: 5 }]), 0);
    assert.equal(P.displayRole(twins, 9), "");
});

test("Arrange: the layout scaled into the box and centred", () => {
    assert.deepEqual(P.arrangement(twins, 430, 200),
                     [{ x: 0, y: 39.53125, w: 215, h: 120.9375 }, { x: 215, y: 39.53125, w: 215, h: 120.9375 }]);
    // sizes are in layout units: a 4K display at 1.5 is 2560 wide beside a 1920 one
    const r = P.arrangement(mons, 448, 144);
    assert.deepEqual(r.map(a => Math.round(a.w)), [256, 192]);
    assert.equal(Math.round(r[1].x), 256);
    assert.deepEqual(P.arrangement([], 10, 10), []);
});

test("brightness.json: the shell's state, clamped; no file = not available", () => {
    assert.deepEqual(P.normalizeBrightness(null), { value: 1, available: false, source: "", probe: 0 });
    assert.deepEqual(P.normalizeBrightness({ value: 0.25, available: true, source: "ddc", probe: 2 }), { value: 0.25, available: true, source: "ddc", probe: 2 });
    assert.deepEqual(P.normalizeBrightness({ value: 7, available: "yes", source: 3, probe: "x" }), { value: 1, available: false, source: "", probe: 0 });
    // a slider move over the shell's file keeps what the shell decided
    assert.deepEqual(P.mergeState('{"value":0.6,"available":true,"source":"stub","probe":1}', { value: 0.31237 }, P.normalizeBrightness),
                     { value: 0.3124, available: true, source: "stub", probe: 1 });
    assert.equal(P.mergeState("", null, P.normalizeBrightness).available, false);
});

test("hardware.sh lines: each item hidden and shown; HYPRK_HW wins; no answer hides nothing", () => {
    const none = P.parseHardware("wifi=0\nbluetooth=0\nbattery=0\ntrackpad=0\nmouse=0\nkeyboardBacklight=0\nambientLight=0\n", "");
    assert.deepEqual(none, { wifi: false, bluetooth: false, battery: false, trackpad: false, mouse: false, keyboardBacklight: false, ambientLight: false, airdrop: false });
    const all = P.parseHardware("wifi=1\nbluetooth=1\nbattery=1\ntrackpad=1\nmouse=1\nkeyboardBacklight=1\nambientLight=1\n", "");
    assert.deepEqual(all, { wifi: true, bluetooth: true, battery: true, trackpad: true, mouse: true, keyboardBacklight: true, ambientLight: true, airdrop: true });
    // this PC: Bluetooth and a mouse only. AirDrop needs Wi-Fi too
    const pc = P.parseHardware("wifi=0\nbluetooth=1\nbattery=0\ntrackpad=0\nmouse=1\nkeyboardBacklight=0\nambientLight=0\n", "");
    assert.deepEqual([pc.wifi, pc.bluetooth, pc.airdrop, pc.trackpad, pc.mouse], [false, true, false, false, true]);
    assert.deepEqual(P.parseHardware("wifi=0\n", "wifi=1,trackpad=0,bogus=1").wifi, true);
    assert.equal(P.parseHardware("wifi=0\n", "wifi=1,trackpad=0").trackpad, false);
    assert.deepEqual(P.parseHardware("", ""), Object.assign({}, P.hardwareDefaults, { airdrop: true }));
});

test("the sidebar lists a pane only with its hardware", () => {
    const Panes = new Function(fs.readFileSync(path.join(__dirname, "..", "Panes.js"), "utf8") + "; return { panes, visible };")();
    const ids = hw => Panes.visible(false, "", hw).map(p => p.id);
    const all = P.parseHardware("", "");
    for (const [key, id] of [["wifi", "wifi"], ["bluetooth", "bluetooth"], ["trackpad", "trackpad"], ["mouse", "mouse"]]) {
        assert.ok(ids(all).includes(id), id + " shown");
        const without = ids(Object.assign({}, all, { [key]: false }));
        assert.ok(!without.includes(id), id + " hidden");
        assert.equal(without.length, ids(all).length - 1);        // nothing else goes
    }
    assert.deepEqual(ids(undefined), ids(all));
    assert.ok(Panes.visible(true, "", all).some(p => p.id === "battery") && !ids(all).includes("battery"));
    // the list closes up: Bluetooth is first without Wi-Fi
    assert.equal(ids(Object.assign({}, all, { wifi: false }))[0], "bluetooth");
});

test("scripts/hardware.sh prints every key once as 0 or 1", () => {
    const out = require("node:child_process").spawnSync(path.join(__dirname, "..", "scripts", "hardware.sh"), { encoding: "utf8" }).stdout;
    assert.deepEqual(out.trim().split("\n").map(l => l.replace(/=[01]$/, "")),
                     ["wifi", "bluetooth", "battery", "trackpad", "mouse", "keyboardBacklight", "ambientLight"]);
});
