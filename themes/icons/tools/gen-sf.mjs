// Generate themes/icons/sf-symbols/sf.js from names.json and svg/ (SF Symbols rendered on macOS 27.2.1,
// reference/re/MAC-ANSWERS.md R3b): the outlines as path data, plus the code that tints and places them.
// shell/components/sf.js and finder/qml/lib/sf.js are symlinks to the output.
// Usage: node themes/icons/tools/gen-sf.mjs [--check]     (--check fails when sf.js is stale)
import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const dir = join(dirname(fileURLToPath(import.meta.url)), "..", "sf-symbols");
const names = JSON.parse(readFileSync(join(dir, "names.json"), "utf8"));
const outFile = join(dir, "sf.js");

// Path data rounded to 1/100 pt at 32 pt (under 0.01 px at 2x for any size we draw), spaces trimmed.
// pdftocairo ends every subpath with "Z M x y"; the trailing move is dropped.
function compact(d) {
    return d.replace(/-?\d+\.\d+/g, n => String(Math.round(parseFloat(n) * 100) / 100))
        .replace(/\s*([MLCZ])\s*/g, "$1").replace(/M[\d.\s-]+$/, "").trim();
}
function hex(rgb) {
    const c = rgb.match(/[\d.]+/g).map(v => Math.round(parseFloat(v) * 2.55));
    return "#" + c.map(v => v.toString(16).padStart(2, "0")).join("");
}

// Only the glyphs the shell and Finder can show (Settings uses the IconServices PNGs).
// R3b symbols of the shell and Finder, plus every symbol of the menu bar, Control Center and Notification
// Center lists (R3b-2).
const wanted = new Set();
for (const s of Object.values(names.symbols)) {
    if (!s.surfaces.some(x => x === "shell" || x === "finder")) continue;
    wanted.add(s.symbol);
    for (const e of s.extras || []) wanted.add(e.symbol);
}
for (const list of ["menubar", "controlcenter", "notificationcenter"])
    for (const e of names[list]) if (e.symbol && /symbol/.test(e.kind)) wanted.add(e.symbol);

const problems0 = [];
const aliases = {};
for (const [pc, s] of Object.entries(names.symbols))
    if (s.surfaces.some(x => x === "shell" || x === "finder") && pc !== s.symbol) aliases[pc] = s.symbol;

// One file per symbol, weight and variant: SF Symbols scale linearly (R3b: the 16 pt alignment rect is exactly
// half the 32 pt one), so the largest rendering (32 pt, else the surface size of R3b-2) serves every size.
// Skipped: tint-<colour> files (the tint is our colour), asset.* and the battery composites (not symbols).
const best = {};
for (const file of readdirSync(join(dir, "svg")).sort()) {
    const m = names.files[file];
    if (!m) { problems0.push(`svg/${file} is not in names.json`); continue; }
    if (!m.symbol || !wanted.has(m.symbol) || m.mode === "tint") continue;
    const rest = file.slice(m.symbol.length + 1 + m.weight.length).replace(/^\.\d+pt/, "").replace(/\.svg$/, "");
    const key = m.symbol + "." + m.weight + rest;
    if (!best[key] || m.pointSize > names.files[best[key]].pointSize) best[key] = file;
}
const glyphs = {}, hierarchical = new Set(), problems = problems0;
for (const [key, file] of Object.entries(best).sort((a, b) => a[0] < b[0] ? -1 : 1)) {
    const m = names.files[file];
    const svg = readFileSync(join(dir, "svg", file), "utf8");
    if (/<(?!svg|path|\?xml|\/svg)/.test(svg)) problems.push(`svg/${file}: elements other than <path>`);
    const parts = [];
    for (const p of svg.matchAll(/<path ([^>]*)\/>/g)) {
        const a = Object.fromEntries([...p[1].matchAll(/([\w-]+)="([^"]*)"/g)].map(x => [x[1], x[2]]));
        if (a["fill-rule"] !== "nonzero") problems.push(`svg/${file}: fill-rule ${a["fill-rule"]}`);
        const part = [compact(a.d)];
        const op = parseFloat(a["fill-opacity"] ?? "1");
        const color = a.fill === "rgb(0%, 0%, 0%)" ? "" : hex(a.fill);   // black = template (tinted)
        if (op !== 1 || color) part.push(op);
        if (color) part.push(color);
        parts.push(part);
    }
    // [point size, canvas width, height, baseline y, cap height, advance, parts]; canvas = viewBox
    glyphs[key] = [m.pointSize, m.size[0], m.size[1], m.baselineY, m.capHeight, m.alignmentRect[2], parts];
    if (m.mode === "mono" && m.appkitDefaultRendering === "hierarchical") hierarchical.add(m.symbol);
}
for (const s of wanted) if (!glyphs[s + ".regular"]) problems.push(`${s}: no regular svg`);

// Point size per surface from the R3b-2 lists (measured on Apple's 27 screenshots, about +-1 pt).
const surfaceOf = { menubar: ["menubar", "Wi-Fi"], ccToggle: ["controlcenter", "Wi-Fi tile"],
    ccRound: ["controlcenter", "Screen Mirroring button"], ccMedia: ["controlcenter", "Now Playing previous"],
    ccPlay: ["controlcenter", "Now Playing play"], ccSlider: ["controlcenter", "Sound slider min"],
    ccOutput: ["controlcenter", "Sound output button"], nc: ["notificationcenter", "Clear / close button"] };
const surfaces = {};
for (const [k, [list, element]] of Object.entries(surfaceOf)) {
    const e = names[list].find(x => x.element === element);
    if (!e) { problems.push(`${list}: no element "${element}"`); continue; }
    surfaces[k] = e.size ?? Math.max(...e.sizes);   // menu bar: rendered 13/14/15, measured ~15-15.5
}
if (problems.length) { console.error(problems.join("\n")); process.exit(1); }

const out = `.pragma library
// GENERATED by themes/icons/tools/gen-sf.mjs from themes/icons/sf-symbols (names.json, svg/). Do not edit.
// SF Symbols as rendered by macOS 27.2.1 (reference/re/MAC-ANSWERS.md R3b), tinted and placed like AppKit.
// shell/components/sf.js and finder/qml/lib/sf.js are symlinks to this file.

// hyprk glyph name -> SF Symbol name (names.json "symbols"); real SF names work as they are.
const aliases = ${JSON.stringify(aliases, null, 1).replace(/\n\s*/g, " ")};

// Symbols AppKit draws hierarchical when no rendering mode is set (names.json appkitDefaultRendering).
const hierarchicalDefault = ${JSON.stringify([...hierarchical])};

// Point size of the glyphs on each surface (names.json menubar / controlcenter / notificationcenter):
// menubar status items, ccToggle (Wi-Fi/Bluetooth/AirDrop/Focus tiles), ccRound (round buttons), ccMedia
// (previous/next), ccPlay (play/pause), ccSlider (slider ends), ccOutput (sound output), nc (Notification Center).
const surfaces = ${JSON.stringify(surfaces)};

// Point size per unit of a Symbol's \`size\` box. Measured: Control Center toggle glyphs are 0.49 of the
// 68 px circle in reference/screens/macos27-control-center.png (shell: size = 0.56 of the circle -> 0.875);
// menu bar Wi-Fi there is ~1.1 x the clock font size (statusIconSize 16 -> 14 pt next to 13 pt text);
// the 27.2.1 Finder toolbar glyphs are 16.7 pt (screens/27.2.1/finder-toolbar-light.png), 0.85 of
// its 24 px box at the Finder's 44/36 scale.
// Used where no surface size is given.
const pointScale = 0.875;
// key -> [point size of the file, canvas width, height, baseline y, cap height, advance, parts], in points at
// that size. part = [path, fill opacity (default 1), fixed colour (multicolor; default: the tint)]
const glyphs = {
${Object.entries(glyphs).map(([k, v]) => `${JSON.stringify(k)}: ${JSON.stringify(v)}`).join(",\n")}
};

function resolve(name) {
    const s = aliases[name] || name;
    return glyphs[s + ".regular"] ? s : "";
}

// File key for a glyph name, weight ("regular" | "medium" | "semibold"), rendering mode ("" = AppKit's
// default, "monochrome", "hierarchical", "multicolor") and variable value (0..1, < 0 = none). "" when the
// name has no SVG. A variable value picks the level file (wifi, speaker.wave.3.fill): layer i of 3 lights
// when value > i/3, as AppKit draws it (var-20 = 1 lit, var-50 = 2 lit).
function pick(name, weight, mode, value) {
    const s = resolve(name);
    if (!s) return "";
    const w = glyphs[s + "." + weight] ? weight : "regular";
    const k = s + "." + w;
    if (value >= 0 && glyphs[k + ".var-0"])
        return value <= 0 ? k + ".var-0" : value <= 1 / 3 ? k + ".var-20" : value <= 2 / 3 ? k + ".var-50" : k;
    const m = mode || (hierarchicalDefault.indexOf(s) !== -1 ? "hierarchical" : "");
    return m && glyphs[k + "." + m] ? k + "." + m : k;
}

// Where to draw glyph \`key\` at \`pointSize\` in a \`box\` x \`box\` item: the advance is centred
// horizontally and the cap-height centre vertically, as AppKit centres a symbol next to text.
// Returns { x, y, w, h } (item coordinates; w and h whole points, x and y whole when box is) and
// vb (the SVG viewBox, glyph units). clip = keep the image to the box (for image-url consumers).
function layout(key, pointSize, box, clip) {
    const g = glyphs[key];
    if (!g) return null;
    const s = pointSize / g[0];
    const ax = g[5] / 2, ay = g[3] - g[4] / 2;
    let w = box, h = box;
    if (!clip) {
        w = Math.ceil(2 * Math.max(box / (2 * s), ax, g[1] - ax) * s);
        h = Math.ceil(2 * Math.max(box / (2 * s), ay, g[2] - ay) * s);
        if (box % 1 === 0 && (w - box) % 2) w++;
        if (box % 1 === 0 && (h - box) % 2) h++;
    }
    return { x: (box - w) / 2, y: (box - h) / 2, w: w, h: h, vb: [ax - w / (2 * s), ay - h / (2 * s), w / s, h / s] };
}

// data: URL of glyph \`key\` in \`color\` (opaque CSS colour; apply alpha as opacity) over viewBox vb.
function url(key, color, vb) {
    const g = glyphs[key];
    if (!g) return "";
    let body = "";
    for (const p of g[6])
        body += '<path d="' + p[0] + '" fill="' + (p[2] || color) + '"'
              + (p.length > 1 && p[1] !== 1 ? ' fill-opacity="' + p[1] + '"' : "") + "/>";
    const v = vb.map(n => Math.round(n * 1000) / 1000).join(" ");
    return "data:image/svg+xml;utf8," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="' + v + '">' + body + "</svg>");
}
`;

if (process.argv.includes("--check")) {
    if (!existsSync(outFile) || readFileSync(outFile, "utf8") !== out) {
        console.error("sf.js is stale: run node themes/icons/tools/gen-sf.mjs");
        process.exit(1);
    }
} else {
    writeFileSync(outFile, out);
    console.log(`wrote ${outFile}: ${Object.keys(glyphs).length} glyphs, ${(out.length / 1024).toFixed(0)} KB`);
}
