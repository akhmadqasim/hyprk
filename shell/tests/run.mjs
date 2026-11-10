// Plain node test runner for shell/lib/*.js and ui/HyprK/*.js (QML ".pragma library" files),
// plus checks on the shared HyprK module.
// Usage: node shell/tests/run.mjs
import { readFileSync, readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import assert from "node:assert/strict";

const here = dirname(fileURLToPath(import.meta.url));
const hyprk = join(here, "..", "..", "ui", "HyprK");
function load(name, dir = join(here, "..", "lib")) {
    const src = readFileSync(join(dir, name), "utf8").replace(/^\.pragma library\s*$/m, "");
    const names = [...src.matchAll(/^function (\w+)/gm)].map(m => m[1]);
    return new Function(src + "\nreturn {" + names.join(",") + "};")();
}

const S = load("search.js"), C = load("clock.js"), ST = load("state.js");
const SL = load("spotlight.js");
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

// ---- Dock (lib/dock.js, dock defaults in lib/state.js) ----
const DK = load("dock.js");
test("dock magnification off by default", () => assert.equal(ST.dockDefaults().magnification, false));
test("dock tile: absent size is 64 (Q-dock-02)", () => {
    assert.equal(ST.dockTile(ST.dockDefaults()), 64);
    assert.equal(ST.dockTile({}), 64);
    assert.equal(ST.dockTile(null), 64);
    assert.equal(ST.dockTile({ size: "x" }), 64);
    assert.equal(ST.dockTile(ST.parse('{"autohide": true}', ST.dockDefaults())), 64);
    assert.equal(ST.dockTile(ST.parse('{"size": 33}', ST.dockDefaults())), 33);
});
test("dock tile: slider value is the tile in pt, clamped 16..128", () => {
    assert.deepEqual([16, 33, 48, 64, 128].map(s => ST.dockTile({ size: s })), [16, 33, 48, 64, 128]);
    assert.equal(ST.dockTile({ size: 47.6 }), 48);
    assert.equal(ST.dockTile({ size: 4 }), 16);
    assert.equal(ST.dockTile({ size: 300 }), 128);
});
test("dock magnified ratio from the sliders", () => {
    assert.equal(ST.magnifyRatio(ST.dockDefaults()), 2);
    assert.equal(ST.magnifyRatio({ size: 64, magnifiedSize: 128 }), 2);
    assert.equal(ST.magnifyRatio({ size: 48, magnifiedSize: 48 }), 1);
    assert.equal(ST.magnifyRatio({ size: "x" }), 2);
});
test("dock.json without the key keeps magnification off", () => {
    assert.equal(ST.parse('{"autohide": true}', ST.dockDefaults()).magnification, false);
    assert.equal(ST.parse('{"magnification": true}', ST.dockDefaults()).magnification, true);
});
{
    // 27.2.1 AX frames (reference/re/27.2.1/live/dock/dock-geometry.json): 17 apps and 2 separators
    const cells = Array(17).fill("tile");
    cells.splice(12, 0, "separator");
    cells.splice(16, 0, "separator");
    const lay = (tile, fish, focus, large) => DK.layout(cells, { tile, large: large || 2 * tile, fish, focus, dpr: 2 });
    test("dock geometry at the measured tile sizes (Q-dock-02..04)", () => {
        // tile: background width x height, item, separator, circle radius
        const mac = { 32: [615, 46, 34, 15.3, 14], 33: [633, 47, 35, 15.8, 14], 48: [947, 68, 52, 23.4, 21.1], 64: [1235, 84, 68, 30.6, 27.6] };
        for (const t in mac) {
            const [w, h, item, sep, r] = mac[t], g = DK.metrics(+t), l = lay(+t, 0, 0);
            assert.ok(Math.abs(l.baseWidth - w) <= 1, `width at ${t}: ${l.baseWidth}`);
            assert.equal(l.width, l.baseWidth);
            assert.equal(g.height, h);
            assert.equal(g.item, item);
            assert.ok(Math.abs(g.separator - sep) < 1e-9);
            assert.ok(Math.abs(g.radiusCircle - r) < 1e-9);
            assert.equal(g.bottomGap, 5);
        }
        assert.ok(Math.abs(DK.metrics(64).radius - 31.1) < 1e-9);   // continuous-corner fit at 64
        // the items abut: each starts where the last one ended
        const l = lay(64, 0, 0);
        for (let i = 1; i < l.x.length; i++) assert.ok(Math.abs(l.x[i] - (l.x[i - 1] + l.w[i - 1])) <= 0.5);
        assert.ok(Math.abs(l.x[0] - 8.9) <= 0.5);
    });
    test("dock tile size shrinks to fit the screen", () => {
        assert.equal(DK.fitTile(64, 17, 2, 1710), 64);
        const t = DK.fitTile(64, 17, 2, 1000);
        assert.ok(t < 64 && lay(t, 0, 0).baseWidth <= 1000 && lay(t + 1, 0, 0).baseWidth > 1000);
    });
    test("dock off: pointer moves nothing", () => {
        const rest = lay(64, 0, 0);
        for (const f of [0, 30, 300, 900]) assert.deepEqual(lay(64, 0, f), rest);
    });
    test("dock fisheye: Dock.app closed form T + (L - T) cos(pi d / 6T), nothing past 3.5 T", () => {
        for (let d = 0; d <= 160; d += 5) {
            const want = 64 + 64 * Math.cos(Math.PI * d / 384);
            assert.ok(Math.abs(DK.magnifiedSize(64, 128, 1, d, 0) - want) < 1e-9, `d ${d}`);
        }
        assert.equal(DK.magnifiedSize(64, 128, 1, 224, 0), 64);
        assert.equal(DK.magnifiedSize(64, 128, 1, 500, 0), 64);
        assert.ok(DK.magnifiedSize(64, 128, 1, 220, 0) > 64);
        // the ramp scales the whole curve: half way, half the growth under the pointer
        assert.ok(Math.abs(DK.magnifiedSize(64, 128, 0.5, 0, 0) - 96) < 1e-9);
        // against the 81-position recording (R2): the code's curve is within 4.6 pt (MAC-ANSWERS.md: up to 4.5)
        const m = [[0, 128], [35, 125.7], [75, 117.7], [115, 104.5], [155, 87.6], [195, 70.8], [235, 64]];
        for (const [d, s] of m) assert.ok(Math.abs(DK.magnifiedSize(64, 128, 1, d, 0) - s) < 4.6, `d ${d}`);
    });
    test("dock fisheye at five pointer positions: largest tile under the pointer, Dock widens by 2 Rs", () => {
        const rest = lay(64, 0, 0), rs = DK.fishShift(64, 128, 1);
        assert.ok(Math.abs(rs - 32 / Math.sin(Math.PI / 12)) < 1e-9);
        for (const i of [0, 4, 9, 14, 18]) {
            if (cells[i] === "separator") continue;
            const l = lay(64, 1, rest.center[i]);
            assert.ok(Math.abs(l.size[i] - 128) <= 0.5, `tile ${i}: ${l.size[i]}`);
            assert.ok(l.size.every((s, j) => cells[j] === "separator" || s <= l.size[i]));
            const inner = i > 0 && i < 18;
            if (inner) assert.ok(Math.abs(l.width - (rest.baseWidth + 2 * rs)) <= 1, `width ${l.width}`);
            assert.equal(l.baseWidth, rest.baseWidth);
        }
    });
    test("dock fisheye: continuous, device-pixel snapped, no feedback past the ends", () => {
        let prev = lay(64, 1, -50);
        assert.deepEqual(prev, lay(64, 1, 0));            // the pointer is clamped to the bar
        for (let f = 0.5; f < 1235; f += 0.5) {
            const l = lay(64, 1, f);
            l.w.forEach((w, i) => { assert.equal(w * 2, Math.round(w * 2)); assert.ok(Math.abs(w - prev.w[i]) <= 1.5, `size jump at ${f}`); });
            l.x.forEach((x, i) => assert.ok(Math.abs(x - prev.x[i]) <= 3, `x jump at ${f}`));
            assert.equal(l.width, Math.round(l.width));
            prev = l;
        }
    });
    test("dock magnification ramp: 147 ms for 64 -> 128 either way (fishSpeed 42)", () => {
        assert.equal(DK.fishDuration(64), 147);
        assert.equal(DK.fishDuration(-64), 147);
        assert.equal(DK.fishDuration(0), 1);
    });
    test("dock attention bounce: 2 s cycle, hops 500 / 326 / 212 ms at 1 / 0.5 / 0.25 of tile + 1", () => {
        const H = DK.attentionHeight(64);
        assert.equal(H, 65);
        assert.ok(Math.abs(DK.attentionOffset(250, H, -1) - 65) < 1e-9);
        assert.ok(Math.abs(DK.attentionOffset(663, H, -1) - 32.5) < 1e-9);
        assert.ok(Math.abs(DK.attentionOffset(932, H, -1) - 16.25) < 1e-9);
        for (const t of [0, 500, 826, 1038, 1500, 1999]) assert.equal(DK.attentionOffset(t, H, -1), 0);
        assert.ok(Math.abs(DK.attentionOffset(2250, H, -1) - 65) < 1e-9);
        // 60 s, then 3 s bursts every 60 s: quiet at 61 s, bouncing at 120.25 s, quiet again at 124.25 s
        assert.equal(DK.attentionOffset(61250, H, -1), 0);
        assert.ok(DK.attentionOffset(120250, H, -1) > 0);
        assert.equal(DK.attentionOffset(124250, H, -1), 0);
        assert.equal(DK.nextAttentionStart(61000), 120000);
        assert.equal(DK.nextAttentionStart(125000), 180000);
        // answered at 300 ms: the cycle in progress lands at its rest point (1038 ms), then nothing
        assert.equal(DK.attentionEnd(300), 1038);
        assert.ok(DK.attentionOffset(600, H, 300) > 0);
        assert.equal(DK.attentionOffset(1100, H, 300), 0);
        assert.equal(DK.attentionOffset(2250, H, 300), 0);
        assert.equal(DK.attentionPlaying(1100, 300), false);
        assert.equal(DK.attentionPlaying(1100, -1), true);
    });
    test("dock sections: recents after their own separator, at most 3, off puts running apps after pinned", () => {
        const p = [{ id: "a" }], run = [{ id: "r" }], rec = [{ id: "x" }, { id: "r" }, { id: "y" }, { id: "z" }, { id: "w" }];
        const o = [{ id: "dl" }, { id: "tr" }];
        const ids = l => l.map(i => i.separator ? "|" : i.id).join(" ");
        assert.equal(ids(DK.sections(p, run, rec, true, o)), "a | r x y z | dl tr");
        assert.equal(ids(DK.sections(p, [], [], true, o)), "a | dl tr");
        assert.equal(ids(DK.sections(p, run, rec, false, o)), "a r | dl tr");
        assert.equal(ids(DK.pushRecent([{ id: "x" }, { id: "y" }, { id: "z" }], { id: "y" }, 3).map(i => ({ id: i.id }))), "y x z");
        assert.equal(DK.pushRecent([{ id: "x" }, { id: "y" }, { id: "z" }], { id: "n" }, 3).length, 3);
    });
    test("dock label: text + 2 x 14, at least 41 (DOCKLabelLayer, Q-dock-08)", () => {
        assert.equal(DK.labelWidth(39.5), 67.5);   // "Finder"
        assert.equal(DK.labelWidth(5), 41);
        assert.equal(DK.labelWidth(900), 628);
    });
    test("dock label fade and autohide slide: cosine in-out fits of the Mac's per-frame data", () => {
        const cos = x => 0.5 - 0.5 * Math.cos(Math.PI * Math.min(1, Math.max(0, x)));
        // reconciliation-42.json: label alpha after leaving the Dock, 17 ms steps, from the last full frame; 300 ms
        const alpha = [.997, .985, .94, .90, .87, .79, .70, .62, .53, .48, .38, .28, .19, .125, .07, .05, .009, 0];
        let e = 0;
        alpha.forEach((a, i) => { e += (1 - cos((i * 1000 / 60 + 8) / 300) - a) ** 2; });
        assert.ok(Math.sqrt(e / alpha.length) < 0.03, `label rms ${Math.sqrt(e / alpha.length)}`);
        // dock-live.json autohide: top edge per frame while showing (tile 33, 52 pt of travel), 210 ms
        const show = [1105, 1100, 1094, 1087, 1083, 1077, 1070, 1065, 1060, 1057, 1055].map(y => (1107 - y) / 52);
        e = 0;
        show.forEach((p, i) => { e += (cos((i * 1000 / 60 + 34) / 210) - p) ** 2; });
        assert.ok(Math.sqrt(e / show.length) < 0.025, `slide rms ${Math.sqrt(e / show.length)}`);
    });
    test("dock bounce height from the tile size (Dock.app: (tile - 8) * 0.2 + 6)", () => {
        assert.ok(Math.abs(DK.bounceHeight(33) - 11) < 1e-9);
        assert.ok(Math.abs(DK.bounceHeight(64) - 17.2) < 1e-9);
        assert.ok(DK.bounceHeight(48) > 11 && DK.bounceHeight(48) < 17.2);
    });
    test("dock bounce: a pure parabola of 700 ms, on the ground only at the hop boundary", () => {
        assert.equal(DK.bounceOffset(0, 22), 0);
        assert.equal(DK.bounceOffset(700, 22), 0);
        assert.equal(DK.bounceOffset(350, 22), 22);
        assert.equal(DK.bounceOffset(350 + 1400, 22), 22);
        for (let t = 1; t < 700; t += 7) assert.ok(DK.bounceOffset(t, 22) > 0, `t ${t}`);
        // mirror image about the top, 4u(1-u)
        for (const t of [10, 100, 250]) assert.ok(Math.abs(DK.bounceOffset(t, 1) - DK.bounceOffset(700 - t, 1)) < 1e-9);
        assert.ok(Math.abs(DK.bounceOffset(175, 1) - 0.75) < 1e-9);
        // no hold: 0.4 of the period is below the top (0.96)
        assert.ok(Math.abs(DK.bounceOffset(280, 1) - 0.96) < 1e-9);
    });
    test("dock bounce end: the bounce in progress finishes, at the next multiple of 700 ms", () => {
        assert.equal(DK.bounceEnd(0), 700);
        assert.equal(DK.bounceEnd(1), 700);
        assert.equal(DK.bounceEnd(699), 700);
        assert.equal(DK.bounceEnd(700), 1400);
        assert.equal(DK.bounceEnd(6000), 6300);
        assert.equal(DK.bounceOffset(DK.bounceEnd(1234), 22), 0);   // lands on the ground
    });
}
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


// ---- icon shape (macOS 26 squircle tile) ----
const IS = load("iconshape.js", hyprk);
function mask(n, inside) {   // n*n alpha array (stride 1)
    const a = new Uint8Array(n * n);
    for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) a[y * n + x] = inside((x + 0.5) / n, (y + 0.5) / n) ? 255 : 0;
    return a;
}
const sq = (m, e) => (x, y) => x > m && x < 1 - m && y > m && y < 1 - m
    && Math.pow(Math.abs(x - 0.5) / (0.5 - m), e) + Math.pow(Math.abs(y - 0.5) / (0.5 - m), e) <= 1;
test("squircle detected", () => assert.ok(IS.analyze(mask(48, sq(0.06, 5)), 48, 1).squircle));
test("rounded rect detected", () => assert.ok(IS.analyze(mask(48, sq(0.1, 4)), 48, 1).squircle));
test("circle is tiled", () => assert.ok(!IS.analyze(mask(48, sq(0.05, 2)), 48, 1).squircle));
test("plain square is tiled", () => assert.ok(!IS.analyze(mask(48, (x, y) => x > 0.1 && x < 0.9 && y > 0.1 && y < 0.9), 48, 1).squircle));
test("small glyph is tiled", () => assert.ok(!IS.analyze(mask(48, sq(0.3, 5)), 48, 1).squircle));
test("wide logo is tiled", () => assert.ok(!IS.analyze(mask(48, (x, y) => y > 0.35 && y < 0.65), 48, 1).squircle));
test("empty icon", () => assert.equal(IS.analyze(new Uint8Array(48 * 48), 48, 1).squircle, false));
test("rgba stride", () => {
    const a = mask(48, sq(0.06, 5)), rgba = new Uint8Array(48 * 48 * 4);
    a.forEach((v, i) => { rgba[i * 4 + 3] = v; });
    assert.ok(IS.analyze(rgba, 48, 4).squircle);
});
test("extent and centre", () => {
    const i = IS.analyze(mask(48, (x, y) => x > 0.5 && y > 0.5), 48, 1);
    assert.equal(i.extent, 0.5); assert.equal(i.cx, 0.75); assert.equal(i.cy, 0.75);
});
test("fit scales body to target and centres it", () => {
    const f = IS.fit({ extent: 0.5, cx: 0.75, cy: 0.5 }, 0.6, 2);
    assert.ok(Math.abs(f.scale - 1.2) < 1e-9); assert.ok(Math.abs(f.dx + 0.3) < 1e-9); assert.equal(f.dy, 0);
});
test("fit clamps", () => assert.equal(IS.fit({ extent: 0.1, cx: 0.5, cy: 0.5 }, 0.6, 1.6).scale, 1.6));
test("cache", () => { IS.store("u", { squircle: true }); assert.ok(IS.cached("u").squircle); assert.equal(IS.cached("v"), undefined); });
test("squircle points in box", () => {
    const p = IS.squirclePoints(100);
    assert.ok(p.every(([x, y]) => x >= 0 && x <= 100 && y >= 0 && y <= 100));
    // continuous corner: the diagonal point sits at ~0.93 of the half-diagonal (circle 0.71, square 1)
    const d = Math.max(...p.map(([x, y]) => Math.abs(x - 50) === Math.abs(y - 50) ? Math.abs(x - 50) : 0));
    assert.ok(d > 40 && d < 50);
});

// ---- spotlight modes, files, actions, clipboard ----
test("modes order", () => assert.deepEqual(SL.modes().map(m => m.id), ["apps", "files", "actions", "clipboard"]));
test("mode key super+2", () => assert.equal(SL.modeForKey(0x32, true, false, false), "files"));
test("mode key ctrl+4", () => assert.equal(SL.modeForKey(0x34, false, true, false), "clipboard"));
test("mode key alt+1", () => assert.equal(SL.modeForKey(0x31, false, false, true), "apps"));
test("mode key plain digit", () => assert.equal(SL.modeForKey(0x31, false, false, false), ""));
test("mode key 5", () => assert.equal(SL.modeForKey(0x35, true, false, false), ""));
test("modeInfo placeholder is the mode name (Q-panels-24)", () => assert.equal(SL.modeInfo("files").placeholder, "Files"));
test("modeInfo none", () => assert.equal(SL.modeInfo(""), null));
const xbel = `<?xml version="1.0"?><xbel>
<bookmark href="file:///home/u/Docs/a%20b.pdf" added="2026-01-01T00:00:00Z" modified="2026-01-02T00:00:00Z" visited="2026-01-02T00:00:00Z"><info><metadata><mime:mime-type type="application/pdf"/></metadata></info></bookmark>
<bookmark href="file:///home/u/new.txt" modified="2026-03-01T00:00:00Z"><info><metadata><mime:mime-type type="text/plain"/></metadata></info></bookmark>
<bookmark href="https://example.com" modified="2026-04-01T00:00:00Z"></bookmark>
<bookmark href="file:///home/u/R&amp;D.md" modified="2026-02-01T00:00:00Z"></bookmark>
</xbel>`;
test("xbel newest first, file only", () => assert.deepEqual(SL.parseXbel(xbel).map(r => r.path), ["/home/u/new.txt", "/home/u/R&D.md", "/home/u/Docs/a b.pdf"]));
test("xbel mime", () => assert.equal(SL.parseXbel(xbel).find(r => r.path.endsWith(".pdf")).mime, "application/pdf"));
test("xbel limit", () => assert.equal(SL.parseXbel(xbel, 1).length, 1));
test("xbel garbage", () => assert.deepEqual(SL.parseXbel("<nope"), []));
test("fileRow dir slash", () => assert.deepEqual(SL.fileRow("/home/u/Music/", "/home/u"), { path: "/home/u/Music", name: "Music", dir: "~", isDir: true }));
test("fileRow nested", () => assert.equal(SL.fileRow("/home/u/a/b.txt", "/home/u").dir, "~/a"));
test("fileRow outside home", () => assert.equal(SL.fileRow("/etc/hosts", "/home/u").dir, "/etc"));
test("fileIcon video mime", () => assert.equal(SL.fileIcon("/x.webm", false, "video/webm"), "video-x-generic"));
test("fileIcon dir", () => assert.equal(SL.fileIcon("/x", true, ""), "folder"));
test("fileIcon mime", () => assert.equal(SL.fileIcon("/x.pdf", false, "application/pdf"), "application-pdf"));
test("fileIcon ext", () => assert.equal(SL.fileIcon("/x/Photo.JPG", false, ""), "image-x-generic"));
test("fileIcon dotdir no ext", () => assert.equal(SL.fileIcon("/x.d/README", false, ""), "text-x-generic"));
test("matchesQuery basename", () => assert.ok(SL.matchesQuery("/home/u/Report.pdf", "repo")));
test("matchesQuery dir only", () => assert.ok(!SL.matchesQuery("/home/u/report/x.txt", "repo")));
test("matchesQuery trailing slash", () => assert.ok(SL.matchesQuery("/home/u/Reports/", "reports")));
test("search cmd fd", () => {
    const c = SL.searchCommand("fdfind", "a b", "/home/u", 10);
    assert.equal(c[0], "fdfind"); assert.ok(c.includes("--fixed-strings")); assert.deepEqual(c.slice(-3), ["--", "a b", "/home/u"]);
});
test("search cmd plocate passes args", () => assert.deepEqual(SL.searchCommand("plocate", "x", "/h", 5).slice(-4), ["sh", "x", "/h", "5"]));
test("search cmd find escapes glob", () => assert.equal(SL.searchCommand("find", "a*b", "/h", 5)[4], "a\\*b"));
test("merge recents first, dedup", () => {
    const r = [{ path: "/h/a.txt", name: "a.txt" }, { path: "/h/z.txt", name: "z.txt" }];
    const h = [{ path: "/h/b-a.txt", name: "b-a.txt" }, { path: "/h/a.txt", name: "a.txt" }];
    assert.deepEqual(SL.mergeFiles(r, h, "a").map(x => x.path), ["/h/a.txt", "/h/b-a.txt"]);
});
const acts = [{ id: "dark-mode", title: "Turn On Dark Mode", keywords: ["appearance"] }, { id: "lock", title: "Lock Screen" },
              { id: "dnd", title: "Turn On Do Not Disturb" }];
test("quick key exact wins", () => assert.equal(SL.rankActions(acts, "ls", { lock: "ls" }, S.score)[0].id, "lock"));
test("quick key beats name", () => assert.equal(SL.rankActions(acts, "dm", { "dark-mode": "dm", dnd: "d" }, S.score)[0].id, "dark-mode"));
test("action by name", () => assert.equal(SL.rankActions(acts, "lock", {}, S.score)[0].id, "lock"));
test("action by keyword", () => assert.equal(SL.rankActions(acts, "appear", {}, S.score)[0].id, "dark-mode"));
test("action empty query lists all", () => assert.equal(SL.rankActions(acts, "", {}, S.score).length, 3));
test("action no match", () => assert.equal(SL.rankActions(acts, "zzz", {}, S.score).length, 0));
test("quickKeyAction", () => assert.equal(SL.quickKeyAction({ lock: "ls" }, " LS "), "lock"));
test("quickKeyAction none", () => assert.equal(SL.quickKeyAction({ lock: "ls" }, "l"), ""));
test("normQuickKey", () => assert.equal(SL.normQuickKey(" SM "), "sm"));
test("normQuickKey rejects", () => assert.equal(SL.normQuickKey("a b"), ""));
test("normQuickKey too long", () => assert.equal(SL.normQuickKey("abcdefg"), ""));
test("setQuickKey moves key", () => assert.deepEqual(SL.setQuickKey({ a: "x", b: "y" }, "b", "x"), { b: "x" }));
test("setQuickKey clear", () => assert.deepEqual(SL.setQuickKey({ a: "x" }, "a", ""), {}));
test("retention", () => assert.equal(SL.retentionMs("8h"), 8 * 3600e3));
test("retention off", () => assert.equal(SL.retentionMs("off"), 0));
test("retention label", () => assert.equal(SL.retentionLabel("7d"), "7 Days"));
test("nextExpiry oldest", () => assert.equal(SL.nextExpiry([{ ts: 500 }, { ts: 200 }, { ts: 0 }], 100), 300));
test("nextExpiry none", () => assert.equal(SL.nextExpiry([{ ts: 0 }], 100), 0));
test("quickKeyLabel key", () => assert.equal(SL.quickKeyLabel({ a: "sm" }, "a", false), "SM"));
test("quickKeyLabel offer", () => assert.equal(SL.quickKeyLabel({}, "a", true), "Add Quick Keys"));
test("quickKeyLabel none", () => assert.equal(SL.quickKeyLabel({}, "a", false), ""));
test("search cmd plocate basename", () => assert.ok(SL.searchCommand("plocate", "x", "/h", 5)[2].includes("plocate -b")));
test("clip line builtin", () => {
    const it = SL.parseClipLine("/s/clipboard/1700000000000_abcdef0123.txt\ttext/plain\thello world");
    assert.deepEqual(it, { id: "abcdef0123", file: "/s/clipboard/1700000000000_abcdef0123.txt", mime: "text/plain", ts: 1700000000000, text: "hello world" });
});
test("clip line image", () => assert.equal(SL.parseClipLine("/s/1_ab.png\timage/png\t").mime, "image/png"));
test("clip line bad", () => assert.equal(SL.parseClipLine("garbage"), null));
test("clip line cliphist text", () => assert.equal(SL.parseClipLine("12\thi there", true).text, "hi there"));
test("clip line cliphist image", () => assert.equal(SL.parseClipLine("13\t[[ binary data 2 KiB png 10x10 ]]", true).mime, "image/png"));
test("addClip moves dup to top", () => assert.deepEqual(SL.addClip([{ id: "a" }, { id: "b" }], { id: "b", n: 2 }).map(i => i.id), ["b", "a"]));
test("addClip cap", () => assert.equal(SL.addClip([{ id: "a" }, { id: "b" }], { id: "c" }, 2).length, 2));
test("pruneClips", () => assert.deepEqual(SL.pruneClips([{ ts: 1000 }, { ts: 9000 }, { ts: 0 }], 10000, 5000).map(i => i.ts), [9000, 0]));
test("filterClips", () => assert.equal(SL.filterClips([{ text: "Hello", mime: "text/plain" }, { text: "", mime: "image/png" }], "image").length, 1));
test("clipTitle collapses", () => assert.equal(SL.clipTitle({ mime: "text/plain", text: "  a \n b " }), "a b"));
test("clipTitle image", () => assert.equal(SL.clipTitle({ mime: "image/png" }), "Image"));
test("relTime", () => assert.deepEqual([30e3, 300e3, 7200e3, 100000e3, 400000e3].map(d => SL.relTime(1e9 - d, 1e9)),
    ["Just now", "5 min ago", "2 hr ago", "Yesterday", "4 days ago"]));


// ---- scripts/clipboard.sh (built-in clipboard store) ----
{
    const { execFileSync } = await import("node:child_process");
    const { mkdtempSync, rmSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const dir = mkdtempSync(join(tmpdir(), "hyprk-clip-"));
    const sh = join(here, "..", "scripts", "clipboard.sh");
    const run = (args, input, env) => execFileSync(sh, args, { input: input || "", env: Object.assign({}, process.env, { HYPRK_CLIP_DIR: dir }, env || {}) }).toString();
    run(["store", "3", "0"], "first");
    run(["store", "3", "0"], "second");
    run(["store", "3", "0"], "first");                       // duplicate moves to the top
    run(["store", "3", "0"], "secret", { CLIPBOARD_STATE: "sensitive" });
    run(["store", "3", "0"], "");
    const lines = run(["list", "0"]).trim().split("\n").map(l => SL.parseClipLine(l));
    test("clip store dedup + order", () => assert.deepEqual(lines.map(i => i.text.trim()), ["first", "second"]));
    test("clip store skips sensitive", () => assert.ok(!lines.some(i => i.text.includes("secret"))));
    for (const n of ["3", "4", "5"]) run(["store", "3", "0"], "item" + n);
    test("clip store cap", () => assert.equal(run(["list", "0"]).trim().split("\n").length, 3));
    run(["clear"]);
    test("clip clear", () => assert.equal(run(["list", "0"]).trim(), ""));
    rmSync(dir, { recursive: true, force: true });
}

// ---- Liquid Glass motion (ui/HyprK/motion.js) ----
const M = load("motion.js", hyprk);
const near = (a, b, e = 1e-6) => assert.ok(Math.abs(a - b) < e, `${a} != ${b}`);
test("hidden scale caps at 1.2 for small glass", () => near(M.hiddenScale(40), 1.2));
test("hidden scale is +16 pt for large glass", () => near(M.hiddenScale(640), 656 / 640));
test("materialize scale: hidden, shown, reduce motion", () => {
    near(M.materializeScale(640, 0, false), 656 / 640);
    near(M.materializeScale(640, 1, false), 1);
    near(M.materializeScale(640, 0, true), 1);
});
test("press lift: ultraSmall 2.5 pt below 120", () => near(M.pressScale(54, 54), 56.5 / 54));
test("press lift: small 2.25 at 120, large 2 from 160", () => {
    near(M.pressScale(120, 300), 122.25 / 120);
    near(M.pressScale(200, 300), 202 / 200);
});
test("press damping by size", () => {
    near(M.pressDamping(64, 64), 0.629);
    near(M.pressDamping(120, 120), 0.375);
    near(M.pressDamping(160, 400), 0.6);
});
test("spring settles at target, overshoots at damping 0.7", () => {
    let x = 0, v = 0, peak = 0;
    for (let i = 0; i < 120; i++) { [x, v] = M.springStep(x, v, 1, 0.5, 0.7, 1 / 60); peak = Math.max(peak, x); }
    near(x, 1, 1e-3);
    assert.ok(peak > 1.03 && peak < 1.07, "overshoot " + peak);
});
test("critically damped spring does not overshoot", () => {
    let x = 0, v = 0, peak = 0;
    for (let i = 0; i < 120; i++) { [x, v] = M.springStep(x, v, 1, 0.25, 1, 1 / 60); peak = Math.max(peak, x); }
    assert.ok(peak <= 1 + 1e-9, "peak " + peak);
});
test("mode buttons start inside the field, end in place", () => {
    near(M.emergeOffset(0, 1, 68, 66), 0);
    // at 0 every button is shifted to the same x as button 0 minus the travel
    near(0 * 66 - M.emergeOffset(0, 0, 68, 66), 3 * 66 - M.emergeOffset(3, 0, 68, 66));
});

// ---- shared HyprK module (ui/HyprK) ----
{
    const qml = n => readFileSync(join(hyprk, n), "utf8");
    const qmldir = qml("qmldir");
    test("HyprK qmldir lists every QML file", () => {
        const listed = new Set([...qmldir.matchAll(/^(?:singleton )?\w+ \d+\.\d+ (\S+)$/gm)].map(m => m[1]));
        for (const f of readdirSync(hyprk).filter(f => f.endsWith(".qml")))
            assert.ok(listed.has(f), f + " missing from qmldir");
    });
    // controlled controls: they report, the caller owns the state (a write breaks the caller's binding)
    test("Switch never writes checked", () => assert.ok(!/\bsw\.checked\s*=[^=]/.test(qml("Switch.qml"))));
    test("Popup never writes currentIndex", () => assert.ok(!/currentIndex\s*=[^=]/.test(qml("Popup.qml"))));
    test("Slider never writes value", () => assert.ok(!/\bs\.value\s*=[^=]/.test(qml("Slider.qml"))));
    // the plugin title bar draws the same traffic lights (plugin/src/Titlebar.cpp)
    test("traffic lights: plugin colours match Tokens.lights", () => {
        const cpp = readFileSync(join(here, "..", "..", "plugin", "src", "Titlebar.cpp"), "utf8");
        const tokens = qml("Tokens.qml");
        const hex = c => c.toLowerCase();
        const toHex = (r, g, b) => [r, g, b].map(x => Math.round(x * 255).toString(16).padStart(2, "0")).join("");
        // QML colour -> [rrggbb, alpha]
        const parse = c => {
            c = c.trim();
            let m = c.match(/^"#([0-9A-Fa-f]{6})"$/);
            if (m) return [hex(m[1]), 1];
            m = c.match(/^Qt\.rgba\(([^,]+),\s*([^,]+),\s*([^,]+),\s*([^)]+)\)$/);
            return [toHex(+m[1], +m[2], +m[3]), +m[4]];
        };
        const sets = {};
        for (const k of ["close", "minimize", "zoom"]) {
            const m = tokens.match(new RegExp(k + "Set: t\\.dark \\? \\[(.*)\\]\\s*:\\s*\\[(.*)\\]"));
            const split = s => s.match(/"#[0-9A-Fa-f]{6}"|Qt\.rgba\([^)]*\)/g).map(parse);
            sets[k] = { dark: split(m[1]), light: split(m[2]) };
        }
        const grad = [...cpp.match(/LIGHT_GRADIENT\[2\]\[3\]\[2\] = \{([\s\S]*?)\};/)[1].matchAll(/\{0x([0-9A-F]{6}), ([\d.]+)f?\}/g)]
            .map(m => [hex(m[1]), +m[2]]);
        const pressed = [...cpp.match(/LIGHT_PRESSED\[2\]\[3\] = \{([^;]*)\};/)[1].matchAll(/0x([0-9A-F]{6})/g)].map(m => hex(m[1]));
        const glyph = [...cpp.match(/GLYPH_RGB\[3\]\s*= \{([^;]*)\};/)[1].matchAll(/0x([0-9A-F]{6})/g)].map(m => hex(m[1]));
        ["light", "dark"].forEach((mode, d) => ["close", "minimize", "zoom"].forEach((k, b) => {
            const t = sets[k][mode];
            for (const stop of [0, 1]) {
                const [rgb, a] = grad[(d * 3 + b) * 2 + stop];
                assert.equal(rgb, t[stop][0], `${mode} ${k} stop ${stop}`);
                near(a, t[stop][1], 0.006);
            }
            assert.equal(pressed[d * 3 + b], t[2][0], `${mode} ${k} pressed`);
            if (mode === "light") assert.equal(glyph[b], t[3][0], `${k} glyph`);
        }));
        assert.match(cpp, /GLYPH_SPRING\s*= 0\.3;/);
        assert.match(tokens, /glyphResponse: 0\.3\b/);
    });
}

// ---- lock screen (shell/modules/lock/lock.js) ----
{
    const LK = load("lock.js", join(here, "..", "modules", "lock"));
    const d = new Date(2026, 10, 10, 16, 5);
    test("lock clock 12h has no AM/PM", () => assert.equal(LK.time(d, false), "4:05"));
    test("lock clock 24h", () => assert.equal(LK.time(d, true), "16:05"));
    test("lock clock midnight 12h", () => assert.equal(LK.time(new Date(2026, 10, 10, 0, 7), false), "12:07"));
    test("lock date month first", () => assert.equal(LK.date(d, true), "Tuesday, November 10"));
    test("lock date day first", () => assert.equal(LK.date(d, false), "Tuesday 10 November"));
    test("full name from GECOS", () => assert.equal(LK.fullName("aq:x:1000:1000:Akhmad Qasim,,,:/home/aq:/bin/bash\n", "aq"), "Akhmad Qasim"));
    test("full name falls back to login", () => assert.equal(LK.fullName("aq:x:1000:1000::/home/aq:/bin/bash", "aq"), "aq"));
    test("initials", () => { assert.equal(LK.initials("Akhmad Qasim"), "AQ"); assert.equal(LK.initials("alto"), "A"); assert.equal(LK.initials("A B C"), "AC"); assert.equal(LK.initials(""), ""); });
    const rows = [{ nid: 3, time: 300, summary: "s3", body: "b3" }, { nid: 2, time: 200, summary: "s2", body: "b2" }, { nid: 1, time: 100, summary: "s1", body: "b1" }];
    test("lock notifs since the lock, newest first", () => assert.deepEqual(LK.lockNotifs(rows, 150, 3, { previews: "always" }).map(r => r.nid), [3, 2]));
    test("lock notifs capped", () => assert.equal(LK.lockNotifs(rows, 0, 2, {}).length, 2));
    test("lock notifs hide previews when unlocked-only", () => { const r = LK.lockNotifs(rows, 0, 3, { previews: "unlocked" })[0]; assert.equal(r.body, ""); assert.equal(r.summary, ""); assert.equal(rows[0].body, "b3"); });
    test("lock notifs off when whenLocked is false", () => assert.equal(LK.lockNotifs(rows, 0, 3, { whenLocked: false }).length, 0));
    const devs = JSON.stringify({ keyboards: [{ name: "virt", layout: "us", main: false }, { name: "kb", layout: "us,de(neo)", active_layout_index: 1, active_keymap: "German (Neo 2)", capsLock: true, main: true }] });
    test("keyboard: main one, layouts, caps", () => { const k = LK.keyboard(devs); assert.deepEqual(k.layouts, ["us", "de(neo)"]); assert.equal(k.index, 1); assert.equal(k.capsLock, true); });
    test("keyboard: layout label", () => assert.equal(LK.layoutLabel(LK.keyboard(devs)), "DE"));
    test("keyboard: bad json", () => assert.equal(LK.keyboard("{"), null));
    test("shake starts and ends at rest", () => { assert.equal(LK.shake(0, 14, 3, 1.6), 0); assert.equal(LK.shake(1, 14, 3, 1.6), 0); });
    test("shake stays within amplitude and decays", () => {
        let peak = 0, late = 0;
        for (let t = 0; t <= 1; t += 0.01) { const v = Math.abs(LK.shake(t, 14, 3, 1.6)); peak = Math.max(peak, v); if (t > 0.7) late = Math.max(late, v); }
        assert.ok(peak <= 14 && peak > 8, "peak " + peak); assert.ok(late < peak / 3, "late " + late);
    });
}

// ---- volume / brightness HUD (lib/hud.js) ----
{
    const H = load("hud.js");
    test("hud: volume symbols", () => {
        assert.equal(H.volumeSymbol(3 / 16, false), "speaker.wave.1.fill");   // measured
        assert.equal(H.volumeSymbol(7 / 16, false), "speaker.wave.2.fill");   // measured
        assert.equal(H.volumeSymbol(0.9, false), "speaker.wave.3.fill");
        assert.equal(H.volumeSymbol(0.5, true), "speaker.slash.fill");
        assert.equal(H.volumeSymbol(0, false), "speaker.slash.fill");
    });
    test("hud: volume symbol thresholds 0.001 / 0.333 / 0.667 (SystemBannerUI)", () => {
        assert.equal(H.volumeSymbol(0.0009, false), "speaker.slash.fill");
        assert.equal(H.volumeSymbol(0.001, false), "speaker.wave.1.fill");
        assert.equal(H.volumeSymbol(0.3329, false), "speaker.wave.1.fill");
        assert.equal(H.volumeSymbol(0.333, false), "speaker.wave.2.fill");
        assert.equal(H.volumeSymbol(0.6669, false), "speaker.wave.2.fill");
        assert.equal(H.volumeSymbol(0.667, false), "speaker.wave.3.fill");
    });
    test("hud: clamp", () => { assert.equal(H.clamp01(1.4), 1); assert.equal(H.clamp01(-1), 0); assert.equal(H.clamp01("x"), 0); });
    test("hud: 16 dashes over 214 pt, first one a gap longer", () => {
        const d = H.dashes(214, 16, 1);
        assert.equal(d.length, 16);
        assert.equal(d[0].x, 0);
        assert.ok(Math.abs(d[15].x + d[15].w - 214) < 1e-9);
        assert.ok(Math.abs(d[0].w - d[1].w - 1) < 1e-9);
        assert.ok(Math.abs(d[2].x - d[1].x - 214 / 16) < 1e-9);
    });
    const svg = '<svg><path fill-rule="nonzero" fill="rgb(0%, 0%, 0%)" fill-opacity="1" d="M 34.9 27.9 L 39.8 17.2 Z"/>' +
                '<path fill-opacity="0.3" d="M 29.1 23.8 L 32.7 17.2 Z"/><path d="M 21.8 31 L 5 14.3 Z"/></svg>';
    test("hud: svg paths", () => {
        const p = H.svgPaths(svg);
        assert.equal(p.length, 3);
        assert.equal(p[1].opacity, 0.3);
        assert.equal(p[0].maxX, 39.8);
    });
    test("hud: wave.1 drops the outer wave", () => {
        const p = H.withoutOuterWave(H.svgPaths(svg));
        assert.equal(p.length, 2);
        assert.ok(p.every(x => x.maxX < 34));
    });
}

// ---- Applications window categories (lib/appcategories.js) ----
{
    const AC = load("appcategories.js");
    test("terminal is productivity, as on the Mac", () => assert.equal(AC.groupOf(["System", "TerminalEmulator"]), "Productivity & Finance"));
    test("text editor beats utility", () => assert.equal(AC.groupOf(["GNOME", "GTK", "Utility", "TextEditor"]), "Productivity & Finance"));
    test("mail client is productivity", () => assert.equal(AC.groupOf(["Network", "Email"]), "Productivity & Finance"));
    test("calculator is a utility", () => assert.equal(AC.groupOf(["GNOME", "GTK", "Utility", "Calculator"]), "Utilities"));
    test("browser is information", () => assert.equal(AC.groupOf(["Network", "WebBrowser"]), "Information & Reading"));
    test("game", () => assert.equal(AC.groupOf(["Game", "BoardGame"]), "Games"));
    test("no categories is other", () => assert.equal(AC.groupOf(undefined), "Other"));
    test("chips list only groups in use, in the Mac's order", () => assert.deepEqual(
        AC.present([{ categories: ["Game"] }, { categories: ["Utility"] }, { categories: [] }, { categories: ["Development", "Utility"] }]),
        ["Utilities", "Developer Tools", "Games", "Other"]));
    test("IDE is developer tools", () => assert.equal(AC.groupOf(["Development", "IDE"]), "Developer Tools"));
}

// ---- Apps panel grid (lib/appsgrid.js, Q-dock-23..26) ----
{
    const AG = load("appsgrid.js");
    const m = AG.metrics();
    test("apps grid: 7 columns of 115 fill the 844 panel, first centre 77", () => {
        near(AG.cellX(0) + m.pitch / 2, 77);
        near(AG.cellX(6) + m.pitch / 2, 77 + 6 * 115);
        assert.ok(AG.cellX(0) > 0 && AG.cellX(6) + m.pitch < m.width);
    });
    test("apps grid: A-Z from 187 when browsing, 20 for a category", () => {
        assert.equal(AG.gridTop(true), 187);
        assert.equal(AG.gridTop(false), 20);
    });
    test("apps grid: first screen = suggestions + visible rows", () => {
        assert.equal(AG.visibleRows(true), 4);          // 187, 289, 391, 493 (cut by the 520 panel)
        assert.equal(AG.firstScreen(), 35);
    });
    test("apps grid: keyboard moves clamp to the items", () => {
        assert.equal(AG.move(-1, 1, 0, 10), 0);
        assert.equal(AG.move(0, 0, 1, 10), 7);
        assert.equal(AG.move(7, 0, 1, 10), 9);
        assert.equal(AG.move(3, -1, -1, 10), 0);
        assert.equal(AG.move(0, 1, 0, 0), -1);
    });
    test("apps suggestions: distinct, entries or wrappers, capped", () => {
        const a = { id: "a" }, b = { id: "b" }, c = { id: "c" }, h = { id: "h", noDisplay: true };
        assert.deepEqual(AG.suggestions([[{ entry: b }, h], [a, b, { action: 1 }], [c]], 2).map(e => e.id), ["b", "a"]);
        assert.deepEqual(AG.suggestions([[], null, [c]], 7).map(e => e.id), ["c"]);
    });
}

// ---- exact springs as BezierSpline curves (lib/spring.js, components/SpringCurve.qml) ----
{
    const SP = load("spring.js");
    const src = n => readFileSync(join(here, "..", n), "utf8");
    // evaluate a BezierSpline list at time fraction f, as Qt does (find the segment, solve x for the parameter)
    const evalSpline = (c, f) => {
        let p0 = [0, 0];
        for (let i = 0; i < c.length; i += 6) {
            const p1 = [c[i], c[i + 1]], p2 = [c[i + 2], c[i + 3]], p3 = [c[i + 4], c[i + 5]];
            if (f <= p3[0] + 1e-12) {
                const bz = (u, k) => (1 - u) ** 3 * p0[k] + 3 * (1 - u) ** 2 * u * p1[k] + 3 * (1 - u) * u * u * p2[k] + u ** 3 * p3[k];
                let lo = 0, hi = 1;
                for (let j = 0; j < 60; j++) { const m = (lo + hi) / 2; if (bz(m, 0) < f) lo = m; else hi = m; }
                return bz(lo, 1);
            }
            p0 = p3;
        }
        return 1;
    };
    // closed form x(t), independent of the library: the ODE x'' = -w^2 (x - 1) - 2 z w x' integrated finely (RK4)
    const reference = (s, v0, T) => {
        const w = 2 * Math.PI / s.response, z = s.ratio, h = 1e-5, out = [];
        let x = 0, v = v0;
        const f = (x, v) => [v, -w * w * (x - 1) - 2 * z * w * v];
        for (let t = 0; t <= T + h / 2; t += h) {
            out.push(x);
            const k1 = f(x, v), k2 = f(x + h / 2 * k1[0], v + h / 2 * k1[1]);
            const k3 = f(x + h / 2 * k2[0], v + h / 2 * k2[1]), k4 = f(x + h * k3[0], v + h * k3[1]);
            x += h / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]);
            v += h / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]);
        }
        return t => out[Math.round(t / h)];
    };
    // a plan (0 -> 1, cut or settled) against the reference: the value the animation shows at every ms
    const worstError = (s, v0, cut) => {
        const p = SP.plan(s, 0, 1, v0, cut), ref = reference(s, v0, p.seconds);
        let worst = 0;
        for (let t = 0; t <= p.seconds; t += 0.001) worst = Math.max(worst, Math.abs(p.to * evalSpline(p.curve, t / p.seconds) - ref(t)));
        return { p, worst };
    };
    const springs = {
        "Notification Center Spring(0.3, -0.2)": [SP.fromBounce(0.3, -0.2)],
        "HUD appear interpolatingSpring(2, 300, 50)": [SP.fromPhysics(2, 300, 50)],
        "HUD hide spring(0.48669, 1), cut at 0.48669 s": [SP.fromResponse(0.48669, 1), 0.48669],
        "HUD content spring(0.2, 0.85)": [SP.fromResponse(0.2, 0.85)],
        "Control Center Spring(0.25, -0.027)": [SP.fromBounce(0.25, -0.027)],
        "Spotlight open x / alpha Spring(0.28, 0.41)": [SP.fromBounce(0.28, 0.41)],
        "Spotlight open y Spring(0.28, 0.32)": [SP.fromBounce(0.28, 0.32)],
        "Spotlight close Spring(0.45, 0.05)": [SP.fromBounce(0.45, 0.05)],
    };
    for (const [name, [s, cut]] of Object.entries(springs))
        test(`spring curve: ${name} within 0.0025 of the closed form`, () => {
            const { p, worst } = worstError(s, 0, cut);
            assert.ok(worst < 0.0025, `worst ${worst}`);
            assert.ok(p.curve.length % 6 === 0 && p.curve.at(-2) === 1 && p.curve.at(-1) === 1, "ends at (1, 1)");
            assert.ok(p.curve.every((c, i) => i % 2 || i < 2 || c >= p.curve[i - 2] - 1e-12), "time never goes back");
        });
    test("spring curve: retargeting with velocity stays exact", () => {
        for (const v0 of [-20, -3, 4, 30]) {
            const { worst } = worstError(SP.fromResponse(0.2, 0.85), v0);
            assert.ok(worst < 0.0025, `v0 ${v0}: worst ${worst}`);
        }
    });
    test("spring curve: Apple notations", () => {
        const b = SP.fromBounce(0.25, -0.027), k = (2 * Math.PI / 0.25) ** 2;
        assert.ok(Math.abs(k - 631.65) < 0.01 && Math.abs(2 * b.ratio * Math.sqrt(k) - 51.66) < 0.01, "CC: stiffness 631.65, damping 51.66");
        const n = SP.fromBounce(0.3, -0.2);
        assert.ok(Math.abs(n.ratio - 1.25) < 1e-12 && Math.abs((2 * Math.PI / 0.3) ** 2 - 438.65) < 0.01);
        const h = SP.fromPhysics(2, 300, 50);
        assert.ok(Math.abs(2 * Math.PI / h.response - 12.247) < 1e-3 && Math.abs(h.ratio - 1.0206) < 1e-4, "HUD: w0 12.25, ratio 1.02");
        assert.ok(Math.abs(SP.fromBounce(0.45, 0.05).ratio - 0.95) < 1e-12);
    });
    test("spring curve: HUD appear values (MAC-ANSWERS: 0.34, 0.69, 0.87, 0.95, 0.98 at 0.1..0.5 s)", () => {
        const h = SP.fromPhysics(2, 300, 50);
        [0.34, 0.69, 0.87, 0.95, 0.98].forEach((x, i) => assert.ok(Math.abs(SP.value(h, 0, (i + 1) / 10) - x) < 0.01, `${(i + 1) / 10} s`));
    });
    test("spring curve: HUD hide stops at 0.986 at 0.48669 s", () => {
        const p = SP.plan(SP.fromResponse(0.48669, 1), 1, 0, 0, 0.48669);
        assert.equal(p.duration, 487);
        assert.ok(Math.abs(p.to - 0.0136) < 0.001, `to ${p.to}`);
    });
    test("spring curve: CC close 95 % at 0.19 s (MAC-ANSWERS)", () => {
        const c = SP.fromBounce(0.25, -0.027);
        assert.ok(SP.value(c, 0, 0.18) < 0.95 && SP.value(c, 0, 0.2) > 0.95);
    });
    test("spring curve: Spotlight alpha first reaches 0 at 0.12 s on close", () => {
        const t = SP.firstCrossing(SP.fromBounce(0.28, 0.41), 0, 0.001);
        assert.ok(t > 0.115 && t < 0.13, `t ${t}`);
    });
    test("spring curve: the modules use the library, with Apple's numbers", () => {
        assert.match(src("modules/NotificationCenter.qml"), /SpringLib\.fromBounce\(0\.3, -0\.2\)/);
        assert.match(src("modules/ControlCenterWindow.qml"), /SpringLib\.fromBounce\(0\.25, -0\.027\)/);
        const hud = src("services/Hud.qml");
        for (const re of [/fromPhysics\(2, 300, 50\)/, /fromResponse\(0\.48669, 1\)/, /fromResponse\(0\.2, 0\.85\)/]) assert.match(hud, re);
        const sl = src("modules/Spotlight.qml");
        for (const re of [/fromBounce\(0\.28, 0\.41\)/, /fromBounce\(0\.28, 0\.32\)/, /fromBounce\(0\.45, 0\.05\)/]) assert.match(sl, re);
        assert.ok(!/slideCurve/.test(src("modules/NotificationCenter.qml")), "no hand-fitted NC curve left");
    });
}

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
