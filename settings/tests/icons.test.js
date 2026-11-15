// Run: node --test settings/tests/*.test.js
// The icon ids Settings names (Panes.js) have their files in themes/icons/settings, nothing in Settings asks for the
// Material icon font any more (the shared HyprK controls in ui/ neither), and writes to the host desktop's
// settings (gsettings / dconf) only go through Backend.runHost (real session only).
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const icons = path.join(root, "..", "themes", "icons", "settings");
// Panes.js is a QML .js library (no exports): evaluate it and pick what the test needs
const P = new Function(fs.readFileSync(path.join(root, "Panes.js"), "utf8") + "; return { panes, rowIcons, extraIcons, hasRealIcon, iconPx, isRowIcon, cropIcons, isCropIcon, cropScale };")();
const styles = ["default-light", "default-dark", "dark-light", "dark-dark", "clear-light", "clear-dark", "tinted-light", "tinted-dark"];
const graphic = JSON.parse(fs.readFileSync(path.join(icons, "graphic.json"), "utf8"));
const built = Object.assign({}, graphic.icons, graphic.stacks, graphic.bitmaps);

test("row icons: one 48 px file per style, listed in graphic.json", () => {
    for (const id of P.rowIcons) {
        assert.deepEqual(built[id] && built[id].sizes, [48], id);
        for (const s of styles) assert.ok(fs.existsSync(path.join(icons, `${id}@48-${s}.png`)), `${id} ${s}`);
        assert.equal(P.iconPx(id, 50), 48);
    }
    for (const [id, e] of Object.entries(built)) if (e.sizes.length === 1 && e.sizes[0] === 48) assert.ok(P.isRowIcon(id), id);
});

test("crop icons (R14.3): the Mac's own tile, light and dark, at the size Panes.js names", () => {
    const crops = path.join(icons, "crops");
    const size = f => fs.readFileSync(f).readUInt32BE(16);          // PNG IHDR width
    const ids = Object.keys(P.cropIcons);
    assert.equal(ids.length, 27);
    for (const id of ids) {
        for (const m of ["light", "dark"]) {
            const f = path.join(crops, `${id}-${m}.png`);
            assert.ok(fs.existsSync(f), `${id} ${m}`);
            assert.equal(size(f), P.cropIcons[id][0], `${id} ${m} px`);
        }
        assert.ok(P.isCropIcon(id) && P.hasRealIcon(id) && !P.isRowIcon(id), id);
    }
    assert.equal(P.cropScale("privacy-camera" in P.cropIcons ? "privacy-camera" : "privacy-bluetooth"), 1.2);
    assert.deepEqual(fs.readdirSync(crops).sort(), ids.flatMap(id => [`${id}-dark.png`, `${id}-light.png`]).sort());
});

test("pane icons: 64 and 128 px per style", () => {
    for (const id of P.panes.map(p => p.id).concat(P.extraIcons))
        for (const px of [64, 128]) for (const s of styles) assert.ok(fs.existsSync(path.join(icons, `${id}@${px}-${s}.png`)), `${id}@${px} ${s}`);
    assert.equal(P.iconPx("wifi", 64), 64);
    assert.equal(P.iconPx("wifi", 65), 128);
    assert.equal(P.hasRealIcon("no-such-icon"), false);
});

test("every iconId in the panes is a known icon; no Material font left in settings/", () => {
    const files = [];
    (function walk(d) {
        for (const f of fs.readdirSync(d, { withFileTypes: true })) {
            if (f.name === "HyprK" || f.name === "tests") continue;      // HyprK: the shared controls (symlink to ui/)
            const p = path.join(d, f.name);
            if (f.isDirectory()) walk(p); else if (/\.(qml|js)$/.test(f.name)) files.push(p);
        }
    })(root);
    // rows the Mac has whose tile is not extracted from it yet: drawn as a plain coloured tile (settings/FALLBACKS.md)
    const notExtracted = ["ax-rtt",   // Accessibility > RTT (R12.1)
        "general-devicemanagement"];   // R13: General's Device Management
    for (const f of files) {
        const src = fs.readFileSync(f, "utf8");
        assert.ok(!/fontGlyph|font\.family:\s*"Material/.test(src), `${path.relative(root, f)} still asks for the glyph font`);
        for (const m of src.matchAll(/\b(?:iconId|icon): (?:[^;\n]*? )?"([a-z0-9-]+)"/g))
            if (/iconId|icon: "/.test(m[0]) && !/glyph/.test(m[0])) assert.ok(P.hasRealIcon(m[1]) || notExtracted.includes(m[1]), `${path.relative(root, f)}: ${m[1]}`);
    }
    const ui = path.join(root, "../ui/HyprK");           // the shared controls draw SF Symbols too (SfSymbol)
    for (const f of fs.readdirSync(ui).filter(f => /\.(qml|js)$/.test(f)))
        assert.ok(!/fontGlyph|Material Icons/.test(fs.readFileSync(path.join(ui, f), "utf8")), `ui/HyprK/${f} still asks for the glyph font`);
});

test("gsettings / dconf writes only through Backend.runHost", () => {
    const hits = [];
    (function walk(d) {
        for (const f of fs.readdirSync(d, { withFileTypes: true })) {
            if (f.name === "HyprK" || f.name === "tests") continue;
            const p = path.join(d, f.name);
            if (f.isDirectory()) walk(p);
            else if (/\.(qml|js|sh)$/.test(f.name))
                fs.readFileSync(p, "utf8").split("\n").forEach((line, i) => {
                    if (/gsettings["', ]+(set|reset)|dconf["', ]+(write|reset|load)/.test(line) && !/runHost\(/.test(line))
                        hits.push(`${path.relative(root, p)}:${i + 1}`);
                });
        }
    })(root);
    assert.deepEqual(hits, []);
    const backend = fs.readFileSync(path.join(root, "Backend.qml"), "utf8");
    assert.match(backend, /function runHost\(argv, cb\) \{\s*if \(realSession\) run\(argv, cb\);/);
    assert.match(fs.readFileSync(path.join(root, "QsInfo.qml"), "utf8"), /realSession: Quickshell\.env\("HYPRK_ALLOW_POWER"\) === "1"/);
});
