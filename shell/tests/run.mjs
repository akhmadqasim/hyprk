// Plain node test runner for shell/lib/*.js (QML ".pragma library" files).
// Usage: node shell/tests/run.mjs
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import assert from "node:assert/strict";

const here = dirname(fileURLToPath(import.meta.url));
function load(name) {
    const src = readFileSync(join(here, "..", "lib", name), "utf8").replace(/^\.pragma library\s*$/m, "");
    const names = [...src.matchAll(/^function (\w+)/gm)].map(m => m[1]);
    return new Function(src + "\nreturn {" + names.join(",") + "};")();
}

const S = load("search.js"), C = load("clock.js"), ST = load("state.js");
let pass = 0, fail = 0;
function test(name, fn) {
    try { fn(); pass++; } catch (e) { fail++; console.error("FAIL " + name + "\n  " + e.message); }
}

// ---- search ranking ----
const apps = [
    { id: "org.gnome.Nautilus", name: "Files", genericName: "File Manager", keywords: ["folder", "finder"], startupClass: "org.gnome.Nautilus" },
    { id: "firefox", name: "Firefox", genericName: "Web Browser", keywords: ["internet"] },
    { id: "code", name: "Visual Studio Code", genericName: "Text Editor", keywords: [] },
    { id: "org.gnome.TextEditor", name: "Text Editor", genericName: "Text Editor", keywords: [] },
    { id: "hidden", name: "Firefox Helper", noDisplay: true },
    { id: "com.mitchellh.ghostty", name: "Ghostty", genericName: "Terminal", keywords: ["shell"], startupClass: "com.mitchellh.ghostty" },
];
test("exact name wins", () => assert.equal(S.rank(apps, "files")[0].id, "org.gnome.Nautilus"));
test("prefix", () => assert.equal(S.rank(apps, "fir")[0].id, "firefox"));
test("noDisplay hidden", () => assert.ok(!S.rank(apps, "firefox").some(e => e.id === "hidden")));
test("word prefix", () => assert.equal(S.rank(apps, "code")[0].id, "code"));
test("initials", () => assert.equal(S.rank(apps, "vsc")[0].id, "code"));
test("name prefix beats generic", () => assert.equal(S.rank(apps, "text")[0].id, "org.gnome.TextEditor"));
test("keyword", () => assert.equal(S.rank(apps, "finder")[0].id, "org.gnome.Nautilus"));
test("generic", () => assert.equal(S.rank(apps, "terminal")[0].id, "com.mitchellh.ghostty"));
// Ghostty-like entry: no GenericName, Keywords=terminal
const apps2 = apps.concat([{ id: "app.center", name: "App Center" }, { id: "epson", name: "Epson Printer Utility" },
                           { id: "x.ghostty", name: "Ghostty", keywords: ["terminal", "tty", "pty"] }]);
test("keyword finds terminal app", () => assert.ok(S.rank(apps2, "terminal").some(e => e.id === "x.ghostty")));
test("keyword ranks above mid-name substring", () => {
    const r = S.rank(apps2, "te").map(e => e.id);
    assert.ok(r.indexOf("x.ghostty") !== -1 && r.indexOf("x.ghostty") < r.indexOf("epson"));
});
test("own name prefix ranks above keyword", () => {
    const r = S.rank(apps2, "te").map(e => e.id);
    assert.ok(r.indexOf("org.gnome.TextEditor") < r.indexOf("x.ghostty"));
});
test("generic word prefix", () => assert.equal(S.rank([{ id: "a", name: "Zed", genericName: "Code Editor" }], "edi")[0].id, "a"));
test("empty query", () => assert.equal(S.rank(apps, "  ").length, 0));
test("no match", () => assert.equal(S.rank(apps, "zzzz").length, 0));
test("limit", () => assert.equal(S.rank(apps, "e", 2).length, 2));

// ---- entry matching ----
test("match exact id", () => assert.equal(S.matchEntry(apps, "firefox").id, "firefox"));
test("match case/class", () => assert.equal(S.matchEntry(apps, "org.gnome.nautilus").id, "org.gnome.Nautilus"));
test("match last segment", () => assert.equal(S.matchEntry(apps, "ghostty").id, "com.mitchellh.ghostty"));
test("match .desktop suffix", () => assert.equal(S.matchEntry(apps, "firefox.desktop").id, "firefox"));
test("match none", () => assert.equal(S.matchEntry(apps, "unknown-app"), null));
test("match empty", () => assert.equal(S.matchEntry(apps, ""), null));

// ---- calculator ----
test("calc add", () => assert.equal(S.calc("2+2"), 4));
test("calc precedence", () => assert.equal(S.calc("2+3*4"), 14));
test("calc parens", () => assert.equal(S.calc("(2+3)*4"), 20));
test("calc unary", () => assert.equal(S.calc("-3*-2"), 6));
test("calc power right assoc", () => assert.equal(S.calc("2^3^2"), 512));
test("calc decimal comma", () => assert.equal(S.calc("1,5*2"), 3));
test("calc symbols", () => assert.equal(S.calc("6×7"), 42));
test("calc spaces", () => assert.equal(S.calc(" 10 / 4 "), 2.5));
test("calc modulo", () => assert.equal(S.calc("10%3"), 1));
test("calc bare number is not a calc", () => assert.equal(S.calc("42"), null));
test("calc text", () => assert.equal(S.calc("firefox"), null));
test("calc injection", () => assert.equal(S.calc("alert(1)"), null));
test("calc div zero", () => assert.equal(S.calc("1/0"), null));
test("calc unbalanced", () => assert.equal(S.calc("(1+2"), null));
test("calc trailing op", () => assert.equal(S.calc("1+"), null));
test("format float", () => assert.equal(S.formatNumber(0.1 + 0.2), "0.3"));
test("format int", () => assert.equal(S.formatNumber(1e6), "1000000"));

// ---- clock ----
const d = new Date(2026, 10, 10, 2, 55, 7);   // Tue 10 Nov 2026 02:55:07
test("clock 24h", () => assert.equal(C.format(d), "Tue 10 Nov  02:55"));
test("clock 12h", () => assert.equal(C.format(d, { use24h: false }), "Tue 10 Nov  2:55 AM"));
test("clock noon 12h", () => assert.equal(C.format(new Date(2026, 10, 10, 12, 5), { use24h: false }), "Tue 10 Nov  12:05 PM"));
test("clock midnight 12h", () => assert.equal(C.format(new Date(2026, 10, 10, 0, 5), { use24h: false }), "Tue 10 Nov  12:05 AM"));
test("clock seconds", () => assert.equal(C.format(d, { seconds: true }), "Tue 10 Nov  02:55:07"));
test("clock en_US", () => assert.equal(C.format(d, C.styleFor("en_US.UTF-8")), "Tue Nov 10  2:55 AM"));
test("clock en_GB", () => assert.equal(C.format(d, C.styleFor("en_GB.UTF-8")), "Tue 10 Nov  02:55"));
test("clock de_DE", () => assert.equal(C.format(d, C.styleFor("de_DE.UTF-8")), "Tue 10 Nov  02:55"));
test("clock C locale", () => assert.deepEqual(C.styleFor("C"), { use24h: true, monthFirst: false }));
test("clock empty locale", () => assert.deepEqual(C.styleFor(""), { use24h: true, monthFirst: false }));
test("clock en_AU 12h day first", () => assert.equal(C.format(new Date(2026, 10, 10, 16, 5), C.styleFor("en_AU.UTF-8")), "Tue 10 Nov  4:05 PM"));
test("relative now", () => assert.equal(C.relative(1000, 30000), "now"));
test("relative minutes", () => assert.equal(C.relative(0, 5 * 60000), "5m ago"));
test("relative hours", () => assert.equal(C.relative(0, 2 * 3600000), "2h ago"));

// ---- state defaults ----
const defs = { dark: false, reduceTransparency: false, accent: "blue" };
test("state valid", () => assert.deepEqual(ST.parse('{"dark":true}', defs), { dark: true, reduceTransparency: false, accent: "blue" }));
test("state invalid json", () => assert.deepEqual(ST.parse("{oops", defs), defs));
test("state empty", () => assert.deepEqual(ST.parse("", defs), defs));
test("state wrong type", () => assert.equal(ST.parse('{"dark":"yes"}', defs).dark, false));
test("state null", () => assert.equal(ST.parse('{"dark":null}', defs).dark, false));
test("state array", () => assert.deepEqual(ST.parse("[1]", defs), defs));
test("state unknown key", () => assert.ok(!("x" in ST.parse('{"x":1}', defs))));
test("state no mutation", () => { ST.parse('{"dark":true}', defs); assert.equal(defs.dark, false); });

// ---- fallback detection ----
test("battery none", () => assert.equal(ST.hasBattery([]), false));
test("battery null", () => assert.equal(ST.hasBattery(null), false));
test("battery mouse is not laptop", () => assert.equal(ST.hasBattery([{ type: 2, isPresent: true, powerSupply: false }]), false));
test("battery laptop", () => assert.equal(ST.hasBattery([{ type: 2, isPresent: true, powerSupply: true }]), true));
test("battery not present", () => assert.equal(ST.hasBattery([{ type: 2, isPresent: false, powerSupply: true }]), false));
test("bluetooth none", () => assert.equal(ST.hasBluetooth(null), false));
test("bluetooth adapter", () => assert.equal(ST.hasBluetooth({}), true));
test("audio not ready", () => assert.equal(ST.hasAudio(false, { audio: {} }), false));
test("audio no sink", () => assert.equal(ST.hasAudio(true, null), false));
test("audio ok", () => assert.equal(ST.hasAudio(true, { audio: {} }), true));
test("wifi none", () => assert.equal(ST.wifiDevice([{ type: 0 }]), null));
test("wifi found", () => assert.equal(ST.wifiDevice([{ type: 0 }, { type: 1, name: "wlan0" }]).name, "wlan0"));
test("player none", () => assert.equal(ST.pickPlayer([]), null));
test("player playing first", () => assert.equal(ST.pickPlayer([{ id: 1, canControl: true, playbackState: 2 }, { id: 2, playbackState: 1 }]).id, 2));
test("player controllable", () => assert.equal(ST.pickPlayer([{ id: 1, canControl: false }, { id: 2, canControl: true }]).id, 2));

// ---- notification rules, input lua ----
const np = { apps: { "firefox": { allow: false }, "org.gnome.Nautilus": { style: "alerts", sounds: false }, "x": { style: "weird" } } };
test("notif default", () => assert.deepEqual(ST.notifRule(np, ["unknown"]), { allow: true, style: "banners", sounds: true }));
test("notif no prefs", () => assert.deepEqual(ST.notifRule(null, ["a"]), { allow: true, style: "banners", sounds: true }));
test("notif blocked", () => assert.equal(ST.notifRule(np, ["firefox"]).allow, false));
test("notif desktop suffix + case", () => assert.equal(ST.notifRule(np, ["org.gnome.nautilus.desktop"]).style, "alerts"));
test("notif second key", () => assert.equal(ST.notifRule(np, ["", "Firefox"]).allow, false));
test("notif sounds off", () => assert.equal(ST.notifRule(np, ["org.gnome.Nautilus"]).sounds, false));
test("notif bad style", () => assert.equal(ST.notifRule(np, ["x"]).style, "banners"));
test("lua input", () => assert.equal(ST.luaInput({ repeatRate: 30, repeatDelay: 250 }), "hl.config({ input = { repeat_rate = 30, repeat_delay = 250 } })"));
test("lua input clamps", () => assert.equal(ST.luaInput({ repeatRate: 999, repeatDelay: 5 }), "hl.config({ input = { repeat_rate = 100, repeat_delay = 100 } })"));
test("lua input defaults", () => assert.equal(ST.luaInput({}), "hl.config({ input = { repeat_rate = 25, repeat_delay = 600 } })"));

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
