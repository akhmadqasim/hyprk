// Accessibility state, Hyprland Lua and screen-filter shader (panes/accessibility/A11y.js).
// Run: node --test settings/tests/
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const A = require("../panes/accessibility/A11y.js");
const P = require("../Parsers.js");

const template = fs.readFileSync(path.join(__dirname, "../../config/hypr/shaders/a11y-filter.frag"), "utf8");

test("normalize: garbage gives defaults", () => {
    for (const bad of [null, undefined, 3, "x", [], { pointerSize: "huge" }])
        assert.equal(A.normalize(bad).pointerSize, 1);
    assert.deepEqual(A.normalize({}), A.defaults);
});

test("normalize: clamps, enums, booleans, colours, keeps unknown keys", () => {
    const o = A.normalize({ pointerSize: 9, filterIntensity: -1, displayContrast: 2, speechRate: "0.3",
        filterType: "sepia", invertMode: "x", zoomModifier: "fn", zoomStyle: "pip",
        zoomKeys: 1, tintColor: "red", future: 7 });
    assert.equal(o.pointerSize, 4);
    assert.equal(o.filterIntensity, 0);
    assert.equal(o.displayContrast, 1);
    assert.equal(o.speechRate, 0.3);
    assert.equal(o.filterType, "grayscale");
    assert.equal(o.invertMode, "smart");
    assert.equal(o.zoomModifier, "control");
    assert.equal(o.zoomStyle, "pip");
    assert.equal(o.zoomKeys, true);
    assert.equal(o.tintColor, "#FF8080");
    assert.equal(o.future, 7);
});

test("appearance keeps a11y flags as booleans", () => {
    const o = P.normalizeAppearance({ reduceMotion: 1, increaseContrast: "yes" });
    assert.equal(o.reduceMotion, true);
    assert.equal(o.increaseContrast, true);
    assert.equal(P.normalizeAppearance({}).reduceMotion, false);
});

test("shader: defines follow the #version line, one per feature", () => {
    const a = A.normalize({ invertColors: true, invertMode: "classic", colorFilters: true, filterType: "deuteranopia",
        filterIntensity: 0.5, tintColor: "#FF0000", displayContrast: 0.25 });
    const src = A.shaderSource(template, a);
    const lines = src.split("\n");
    assert.equal(lines[0], "#version 300 es");
    assert.deepEqual(lines.slice(1, 6), ["#define INVERT 1", "#define FILTER 3", "#define INTENSITY 0.5",
        "#define TINT vec3(1.0, 0.0, 0.0)", "#define CONTRAST 1.25"]);
    assert.ok(!/CONTRAST/.test(A.shaderSource(template, A.defaults).split("\n").slice(1, 7).join("\n")));
    assert.ok(src.endsWith(template.slice(template.indexOf("\n") + 1)));
});

test("shader: smart invert, off states, bad template", () => {
    const smart = A.shaderSource(template, A.normalize({ invertColors: true }));
    assert.match(smart, /#define INVERT 2/);
    assert.match(smart, /#define FILTER 0/);
    assert.equal(A.shaderSource("void main(){}", A.defaults), "");
    assert.equal(A.shaderSource("", A.defaults), "");
    assert.equal(A.needsShader(A.defaults), false);
    assert.equal(A.needsShader(A.normalize({ displayContrast: 0.1 })), true);
    assert.equal(A.glslColor("#80FF00"), "vec3(0.502, 1.0, 0.0)");
});

test("lua: never starts with a dash (hyprctl would read a flag)", () => {
    const lua = A.luaApply(A.defaults, {}, "/r", "/s");
    assert.notEqual(lua[0], "-");
});

test("lua: unbinds every key it may bind before binding", () => {
    const lua = A.luaApply(A.normalize({ zoomKeys: true, zoomScroll: true, zoomModifier: "option", speakSelection: true }), {}, "/r", "/s");
    const lines = lua.split("\n");
    for (const [key] of A.zoomBinds.concat([[A.voiceOverKey], [A.speakKey], ["ALT + mouse_up"]])) {
        const u = lines.indexOf(`hl.unbind("${key}")`);
        const b = lines.findIndex(l => l.startsWith(`hl.bind("${key}"`));
        assert.ok(u >= 0 && b > u, key);
    }
    assert.match(lua, /hl\.bind\("ALT \+ mouse_up", hl\.dsp\.exec_cmd\("'\/r\/settings\/scripts\/a11y-zoom\.sh' in"\)\)/);
    assert.ok(!/hl\.bind\("CTRL \+ mouse_up"/.test(lua));
});

test("lua: off state binds only VoiceOver and clears the shader", () => {
    const lua = A.luaApply(A.defaults, {}, "/r", "/s");
    assert.equal((lua.match(/hl\.bind\(/g) || []).length, 1);
    assert.match(lua, /screen_shader = ""/);
    assert.ok(!/a11y-screen\.frag/.test(lua));
    assert.match(lua, /setcursor .* 24"/);
    assert.match(lua, /hyprk_motion\(false\)/);
    assert.match(lua, /active_border = "rgba\(0000001f\)"/);
});

test("lua: reduce motion, increase contrast, pointer size, shader path, VoiceOver at login", () => {
    const a = A.normalize({ pointerSize: 2.5, colorFilters: true, voiceOver: true });
    const lua = A.luaApply(a, { reduceMotion: true, increaseContrast: true }, "/r", "/s");
    assert.match(lua, /if hyprk_motion then hyprk_motion\(true\) else .*leaf = "windows", enabled = false.* end/);
    assert.match(lua, /active_border = "rgba\(000000a6\)"/);
    assert.match(lua, /HYPRCURSOR_SIZE", "60"/);
    assert.match(lua, /screen_shader = "\/s\/a11y-screen\.frag"/);
    assert.match(lua, /a11y-orca\.sh' restore/);
    assert.ok(lua.indexOf('screen_shader = ""') < lua.indexOf("a11y-screen.frag"));
});

test("lua: paths with quotes stay one shell word and one Lua string", () => {
    const lua = A.luaApply(A.normalize({ zoomKeys: true }), {}, `/home/o'neil "x"`, "/s");
    assert.ok(lua.includes(`hl.dsp.exec_cmd("'/home/o'\\\\''neil \\"x\\"/settings/scripts/a11y-zoom.sh' toggle")`));
});
