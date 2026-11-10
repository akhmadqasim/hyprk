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
