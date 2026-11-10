.pragma library

// Pure helpers for the volume and brightness HUD (services/Hud.qml, modules/HudWindow.qml).

function clamp01(v) {
    return Math.max(0, Math.min(1, Number(v) || 0));
}

// SF Symbol for a volume level (SystemBannerUI 27.2.1, MAC-ANSWERS.md "REA 27.2.1" section 1):
// "speaker." + slash below 0.001, wave.1 below 0.333, wave.2 below 0.667, else wave.3 (symbolVariant fill).
// Muted shows the slash too (the level is 0 then).
function volumeSymbol(level, muted) {
    if (muted || level < 0.001) return "speaker.slash.fill";
    if (level < 0.333) return "speaker.wave.1.fill";
    if (level < 0.667) return "speaker.wave.2.fill";
    return "speaker.wave.3.fill";
}

// Paths of an SF Symbol SVG (themes/icons/sf-symbols/svg, pdftocairo output):
// [{ d, opacity, maxX }] in viewBox units.
function svgPaths(text) {
    const out = [];
    const re = /<path\b[^>]*>/g;
    let m;
    while ((m = re.exec(String(text || ""))) !== null) {
        const tag = m[0];
        const d = /\sd="([^"]+)"/.exec(tag);
        if (!d) continue;
        const op = /fill-opacity="([^"]+)"/.exec(tag);
        const nums = d[1].match(/-?\d+(?:\.\d+)?/g) || [];
        let maxX = -Infinity;
        for (let i = 0; i + 1 < nums.length; i += 2) maxX = Math.max(maxX, parseFloat(nums[i]));
        out.push({ d: d[1], opacity: op ? parseFloat(op[1]) : 1, maxX: maxX });
    }
    return out;
}

// speaker.wave.1.fill is not in the extracted set: it is speaker.wave.2.fill without its outer
// wave (the path that reaches furthest right), on the same canvas.
function withoutOuterWave(paths) {
    if (!paths || paths.length < 2) return paths || [];
    let far = 0;
    for (let i = 1; i < paths.length; i++) if (paths[i].maxX > paths[far].maxX) far = i;
    return paths.filter((p, i) => i !== far);
}

// Level bar: `cells` cells of length / cells; every cell but the first starts with a gap
// (measured: the first dash is one gap longer than the others). Returns [{ x, w }].
function dashes(length, cells, gap) {
    const pitch = length / cells, out = [];
    for (let i = 0; i < cells; i++) {
        const x = i * pitch + (i > 0 ? gap : 0);
        out.push({ x: x, w: (i + 1) * pitch - x });
    }
    return out;
}
