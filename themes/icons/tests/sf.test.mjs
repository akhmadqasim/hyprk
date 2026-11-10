// Tests for the SF Symbols module (themes/icons/sf-symbols/sf.js). Run: node --test themes/icons/tests/sf.test.mjs
import { readFileSync, lstatSync, readlinkSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import assert from "node:assert/strict";

const icons = join(dirname(fileURLToPath(import.meta.url)), "..");
const root = join(icons, "..", "..");
const strip = file => readFileSync(file, "utf8").replace(/^\.pragma library\s*$/m, "").replace(/^\.import .*$/m, "");
const SF = new Function(strip(join(icons, "sf-symbols", "sf.js"))
    + "\nreturn { resolve, pick, layout, url, glyphs, surfaces, pointScale };")();
// hand-drawn glyph names: the shell's symbols.js table and the Finder's lib/symbols.js table
const handDrawn = file => [...readFileSync(join(root, file), "utf8").matchAll(/^\s+"([\w.]+)": \[/gm)].map(m => m[1]);

test("sf.js is generated from names.json and svg/", () => {
    execFileSync("node", [join(icons, "tools", "gen-sf.mjs"), "--check"], { stdio: "pipe" });
});

test("shell and Finder import the same file", () => {
    for (const link of ["shell/components/sf.js", "finder/qml/lib/sf.js"]) {
        assert.ok(lstatSync(join(root, link)).isSymbolicLink(), link);
        assert.ok(readlinkSync(join(root, link)).endsWith("themes/icons/sf-symbols/sf.js"), link);
    }
});

test("every hand-drawn glyph has a real symbol, except the known ones", () => {
    const missing = [...handDrawn("shell/components/symbols.js"), ...handDrawn("finder/qml/lib/symbols.js")]
        .filter(n => !SF.resolve(n));
    assert.deepEqual([...new Set(missing)].sort(), ["distro", "zoom"]);
});

test("names map through names.json", () => {
    assert.equal(SF.resolve("controlcenter"), "switch.2");
    assert.equal(SF.resolve("view.columns"), "rectangle.split.3x1");
    assert.equal(SF.resolve("speaker.fill"), "speaker.fill");   // real names work as they are
    assert.equal(SF.resolve("nope"), "");
});

test("pick: weight, AppKit default rendering, variable levels", () => {
    assert.equal(SF.pick("magnifyingglass", "semibold", "", -1), "magnifyingglass.semibold");
    assert.equal(SF.pick("display", "regular", "", -1), "display.regular.hierarchical");
    assert.equal(SF.pick("display", "regular", "monochrome", -1), "display.regular");
    assert.equal(SF.pick("siri", "semibold", "", -1), "siri.regular");   // falls back to regular
    assert.equal(SF.pick("wifi", "regular", "", 0), "wifi.regular.var-0");
    assert.equal(SF.pick("wifi", "regular", "", 0.2), "wifi.regular.var-20");
    assert.equal(SF.pick("wifi", "regular", "", 0.5), "wifi.regular.var-50");
    assert.equal(SF.pick("wifi", "regular", "", 1), "wifi.regular");
    assert.equal(SF.pick("speaker.wave.3.fill", "medium", "", 0.3), "speaker.wave.3.fill.medium.var-20");
});

test("pick: the Finder's 13 pt large-scale glyphs", () => {
    assert.equal(SF.pick("shared", "medium", "", -1, "large"), "person.2.medium-large");
    assert.equal(SF.pick("clock", "medium", "", -1, "large"), "clock.medium-large");
    assert.equal(SF.pick("magnifyingglass", "regular", "", -1, "large"), "magnifyingglass.medium-large");
    assert.equal(SF.pick("zoom", "medium", "", -1, "large"), "");                  // no SVG at all
    assert.equal(SF.pick("wifi", "regular", "", -1, "large"), "wifi.regular");      // no large file: the normal one
    for (const w of ["regular", "medium", "semibold"]) assert.ok(SF.glyphs["person.2." + w], w);
    assert.equal(SF.glyphs["clock.medium-large"][0], 13);                           // drawn at pointSize 13
    // the 27 glyphs of names.json finder (sidebarGlyph + toolbarGlyph) are in
    const names = JSON.parse(readFileSync(join(icons, "sf-symbols", "names.json"), "utf8"));
    const files = [...names.finder.sidebarGlyph.files, ...names.finder.toolbarGlyph.files];
    assert.equal(new Set(files).size, 27);
    for (const f of files) assert.ok(SF.glyphs[f.replace(/\.13pt-large\.svg$/, "-large")], f);
});

test("layout centres the advance and the cap-height centre in the box", () => {
    const g = SF.glyphs["wifi.regular"], s = 14 / g[0];
    const b = SF.layout("wifi.regular", 14, 16, false);
    assert.ok(Number.isInteger(b.w) && Number.isInteger(b.h) && Number.isInteger(b.x) && Number.isInteger(b.y));
    // glyph point (advance/2, baseline - cap/2) lands on the box centre
    assert.ok(Math.abs(b.x + (g[5] / 2 - b.vb[0]) * s - 8) < 1e-9);
    assert.ok(Math.abs(b.y + (g[3] - g[4] / 2 - b.vb[1]) * s - 8) < 1e-9);
    // the whole canvas fits in the image
    assert.ok(b.vb[0] <= 0 && b.vb[1] <= 0 && b.vb[0] + b.vb[2] >= g[1] && b.vb[1] + b.vb[3] >= g[2]);
    const c = SF.layout("wifi.regular", 14, 16, true);
    assert.deepEqual([c.x, c.y, c.w, c.h], [0, 0, 16, 16]);
});

test("url tints template paths and keeps multicolor colours", () => {
    const u = decodeURIComponent(SF.url("battery.100percent.bolt.regular.multicolor", "#ff0000", [0, 0, 32, 32]));
    assert.ok(u.startsWith("data:image/svg+xml;utf8,<svg"));
    assert.ok(u.includes('fill="#ff0000"') && u.includes('fill="#34c759"'));
    assert.ok(!SF.url("nope", "#000", [0, 0, 1, 1]));
});

test("surface sizes from names.json", () => {
    assert.deepEqual(SF.surfaces, { menubar: 15, ccToggle: 18, ccRound: 24, ccMedia: 17, ccPlay: 24, ccSlider: 16, ccOutput: 13, nc: 13 });
});
