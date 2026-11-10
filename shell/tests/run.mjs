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
    const widths = [44, 44, 44, -13, 44];
    const o = (amount, focus) => ({ base: 44, big: 88, amount, focus, range: 66, spacing: 2, sidePad: 8, dpr: 2 });
    const rest = DK.layout(widths, o(0, 0));
    test("dock rest layout", () => {
        assert.deepEqual(rest.w, [44, 44, 44, 13, 44]);
        assert.deepEqual(rest.x, [8, 54, 100, 146, 161]);
        assert.equal(rest.width, 213);
        assert.equal(rest.baseWidth, 213);
    });
    test("dock off: pointer moves nothing", () => {
        for (const f of [0, 30, 77, 150, 260]) assert.deepEqual(DK.layout(widths, o(0, f)), rest);
    });
    test("dock magnified under the pointer, separator fixed", () => {
        const l = DK.layout(widths, o(1, rest.center[1]));
        assert.equal(l.w[1], 88);
        assert.equal(l.w[3], 13);
        assert.ok(l.w[0] > 44 && l.w[0] < 88 && l.w[0] === l.w[2]);
        assert.equal(l.baseWidth, rest.baseWidth);
    });
    test("dock end tile stays full size past its centre", () => {
        const at = DK.layout(widths, o(1, rest.center[0])), past = DK.layout(widths, o(1, -20));
        assert.equal(at.w[0], 88);
        assert.deepEqual(past, at);
    });
    test("dock sizes continuous and device-pixel snapped", () => {
        let prev = DK.layout(widths, o(1, 0));
        for (let f = 0.5; f < 213; f += 0.5) {
            const l = DK.layout(widths, o(1, f));
            l.w.forEach((w, i) => { assert.equal(w * 2, Math.round(w * 2)); assert.ok(Math.abs(w - prev.w[i]) <= 1.5, `size jump at ${f}`); });
            l.x.forEach((x, i) => assert.ok(Math.abs(x - prev.x[i]) <= 3, `x jump at ${f}`));
            assert.equal(l.width, Math.round(l.width));
            prev = l;
        }
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
test("cycle right from all", () => assert.equal(SL.cycleMode("", 1), "apps"));
test("cycle left from all wraps", () => assert.equal(SL.cycleMode("", -1), "clipboard"));
test("cycle right from clipboard", () => assert.equal(SL.cycleMode("clipboard", 1), ""));
test("modeInfo placeholder", () => assert.equal(SL.modeInfo("files").placeholder, "Search Files"));
test("modeInfo none", () => assert.equal(SL.modeInfo(""), null));
test("app category dev", () => assert.equal(SL.appCategory(["Development", "IDE"]), "Developer Tools"));
test("app category other", () => assert.equal(SL.appCategory([]), "Other"));
test("app chips present only", () => assert.deepEqual(SL.appCategoryChips([{ categories: ["Game"] }, { categories: ["Utility"] }]), ["Games", "Utilities"]));
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

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
