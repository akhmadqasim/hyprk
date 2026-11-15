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
// [{ d, opacity, minX, maxX, minY, maxY }] in viewBox units (the bounds are those of the path's points, control
// points included: enough for the ink centre a bounce turns about).
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
        let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
        for (let i = 0; i + 1 < nums.length; i += 2) {
            const x = parseFloat(nums[i]), y = parseFloat(nums[i + 1]);
            minX = Math.min(minX, x); maxX = Math.max(maxX, x);
            minY = Math.min(minY, y); maxY = Math.max(maxY, y);
        }
        out.push({ d: d[1], opacity: op ? parseFloat(op[1]) : 1, minX: minX, maxX: maxX, minY: minY, maxY: maxY });
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

// Centre of the ink of svgPaths() output, in viewBox units: { x, y }.
function inkCentre(paths) {
    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
    for (const p of paths || []) {
        minX = Math.min(minX, p.minX); maxX = Math.max(maxX, p.maxX);
        minY = Math.min(minY, p.minY); maxY = Math.max(maxY, p.maxY);
    }
    return maxX >= minX ? { x: (minX + maxX) / 2, y: (minY + maxY) / 2 } : { x: 0, y: 0 };
}

// The glyph bounces when the level arrives at an end from another level (SystemBannerUI 27.2.1
// SymbolEffectState.update 0x2aed4af5c: nothing when the value equals previousValue; else previousValue = value and
// valueLabelSeed += 1 when the value is exactly 0 or 1; the seed is the value of the glyph's discrete
// .symbolEffect(.bounce), SliderBannerImageView.body 0x2aed644bc). `prev` < 0: no level seen yet.
function bouncesAt(prev, level) {
    return level !== prev && (level === 0 || level === 1);
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
