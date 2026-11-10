// Finder glyphs as SVG data URLs, so they render with any Qt Quick backend (software included).
// Real SF Symbols from macOS 27.2.1 (sf.js, names mapped through themes/icons/sf-symbols/names.json);
// the original glyphs on a 24x24 grid below only for names without an SVG ("zoom").
// Parts: S = stroked path, F = filled path.
.pragma library
.import "sf.js" as SF

function rr(x, y, w, h, r) {
    return "M" + (x + r) + " " + y + "H" + (x + w - r) + "A" + r + " " + r + " 0 0 1 " + (x + w) + " " + (y + r)
         + "V" + (y + h - r) + "A" + r + " " + r + " 0 0 1 " + (x + w - r) + " " + (y + h)
         + "H" + (x + r) + "A" + r + " " + r + " 0 0 1 " + x + " " + (y + h - r)
         + "V" + (y + r) + "A" + r + " " + r + " 0 0 1 " + (x + r) + " " + y + "Z";
}
function circle(cx, cy, r) {
    return "M" + (cx - r) + " " + cy + "A" + r + " " + r + " 0 1 0 " + (cx + r) + " " + cy
         + "A" + r + " " + r + " 0 1 0 " + (cx - r) + " " + cy + "Z";
}
function S(d, w) { return { d: d, fill: false, w: w === undefined ? 1.6 : w }; }
function F(d) { return { d: d, fill: true, w: 0 }; }

const table = {
    "clock": [S(circle(12, 12, 9)), S("M12 6.5V12L15.5 14", 1.7)],
    "applications": [S("M13 3.8L5.6 20M11 3.8L18.4 20M3.6 15.4H20.4", 1.7)],
    "desktop": [S(rr(2.5, 4.5, 19, 15, 2.5)), F(rr(4.8, 14.2, 14.4, 3.2, 0.8))],
    "doc": [S("M6.5 2.8H13.2L18.5 8.1V19A2.2 2.2 0 0 1 16.3 21.2H7.7A2.2 2.2 0 0 1 5.5 19V5A2.2 2.2 0 0 1 7.7 2.8Z"),
            S("M13 3V8.4H18.3", 1.5)],
    "download": [S(circle(12, 12, 9)), S("M12 7V16.5M8 12.8L12 16.8L16 12.8", 1.7)],
    "shared": [S("M2.5 7.2A1.7 1.7 0 0 1 4.2 5.5H8.6L10.4 7.3H18.3A1.7 1.7 0 0 1 20 9V11.2"),
               S("M2.5 7.2V17.3A1.7 1.7 0 0 0 4.2 19H12"), S("M2.5 10H20", 1.4),
               F(circle(17.6, 14.4, 2.1)), F("M13.4 21.2C13.4 18.9 15.3 17.6 17.6 17.6S21.8 18.9 21.8 21.2Z")],
    "icloud": [S("M7 18.5H17.2A4.3 4.3 0 0 0 17.6 9.9A6 6 0 0 0 6.2 10.6A4 4 0 0 0 7 18.5Z")],
    "airdrop": [F(circle(12, 15.6, 1.8)), S("M8.6 18.2A4.6 4.6 0 1 1 15.4 18.2", 1.6),
                S("M5.9 20.2A8 8 0 1 1 18.1 20.2", 1.6)],
    "drive": [S(rr(2.5, 7, 19, 10, 2.5)), F(circle(17.5, 12, 1.1)), S("M5.5 12H11", 1.4)],
    "trash": [S("M4 6.5H20M9.5 6.5V4.5A1 1 0 0 1 10.5 3.5H13.5A1 1 0 0 1 14.5 4.5V6.5"),
              S("M6 6.5L7 19.5A1.5 1.5 0 0 0 8.5 21H15.5A1.5 1.5 0 0 0 17 19.5L18 6.5"),
              S("M10 10V17.5M14 10V17.5", 1.4)],
    "network": [S(circle(12, 12, 9)), S("M3 12H21M12 3C9 6 9 18 12 21M12 3C15 6 15 18 12 21", 1.4)],
    "eject": [F("M12 5L19 13H5Z"), F(rr(5, 15.5, 14, 2.6, 0.8))],

    "chevron.left": [S("M15 4.5L7.5 12L15 19.5", 2.1)],
    "chevron.right": [S("M9 4.5L16.5 12L9 19.5", 2.1)],
    "chevron.down": [S("M7 10L12 15L17 10", 2.2)],
    "chevron.small.right": [S("M10 7L15 12L10 17", 1.6)],
    "view.icons": [S(rr(4, 4, 6.8, 6.8, 1.8)), S(rr(13.2, 4, 6.8, 6.8, 1.8)), S(rr(4, 13.2, 6.8, 6.8, 1.8)), S(rr(13.2, 13.2, 6.8, 6.8, 1.8))],
    "view.list": [F(circle(4.6, 6, 1.3)), F(circle(4.6, 12, 1.3)), F(circle(4.6, 18, 1.3)),
                  S("M8.5 6H20.5M8.5 12H20.5M8.5 18H20.5", 1.7)],
    "view.columns": [S(rr(2.5, 4, 19, 16, 2.6)), S("M9 4V20M15 4V20", 1.6)],
    "view.gallery": [S(rr(2.5, 3.5, 19, 12, 2.6)), S("M3 19.5H4.5M7 19.5H8.5M11 19.5H12.5M15 19.5H16.5M19.5 19.5H21", 2.2)],
    "group": [S(rr(2, 4.5, 5.6, 6, 1.2), 1.6), S(rr(9.2, 4.5, 5.6, 6, 1.2), 1.6), S(rr(16.4, 4.5, 5.6, 6, 1.2), 1.6),
              S(rr(2, 13.5, 5.6, 6, 1.2), 1.6), S(rr(9.2, 13.5, 5.6, 6, 1.2), 1.6), S(rr(16.4, 13.5, 5.6, 6, 1.2), 1.6)],
    "share": [S("M8.5 9.5H6.5A1.5 1.5 0 0 0 5 11V19.5A1.5 1.5 0 0 0 6.5 21H17.5A1.5 1.5 0 0 0 19 19.5V11A1.5 1.5 0 0 0 17.5 9.5H15.5"),
              S("M12 14.5V2.8M8.5 6.2L12 2.7L15.5 6.2")],
    "tag": [S("M3.5 4.8V11L12.9 20.4A1.5 1.5 0 0 0 15 20.4L20.4 15A1.5 1.5 0 0 0 20.4 12.9L11 3.5H4.8A1.3 1.3 0 0 0 3.5 4.8Z"),
            S(circle(7.8, 7.8, 1.2), 1.3)],
    "ellipsis": [F(circle(5, 12, 1.8)), F(circle(12, 12, 1.8)), F(circle(19, 12, 1.8))],
    "magnifyingglass": [S(circle(10.3, 10.3, 6.5), 2.0), S("M15.2 15.2L20.6 20.6", 2.3)],
    "xmark": [S("M6 6L18 18M18 6L6 18", 2.0)],
    "xmark.circle": [F(circle(12, 12, 9)), { d: "M8.8 8.8L15.2 15.2M15.2 8.8L8.8 15.2", fill: false, w: 1.7, knock: true }],
    "minus": [S("M5 12H19", 2.6)],
    "zoom": [F("M6 8.5V18H15.5Z"), F("M18 15.5V6H8.5Z")],
    "eye": [S("M2.5 12C5 7.5 8.3 5.5 12 5.5S19 7.5 21.5 12C19 16.5 15.7 18.5 12 18.5S5 16.5 2.5 12Z"), S(circle(12, 12, 3.2))],
    "plus": [S("M12 5V19M5 12H19", 1.8)],
    "arrow.up.down": [S("M8 19V5M4.5 8.5L8 5L11.5 8.5M16 5V19M12.5 15.5L16 19L19.5 15.5", 1.5)],
};

// Point size relative to SF.pointScale for names drawn smaller than their SF Symbol:
// chevron.small.right is chevron.forward at the ink height of the old drawing (11.6 of 24); not measured on a Mac.
const scale = { "chevron.small.right": 0.65 };

function has(name) { return table.hasOwnProperty(name) || SF.resolve(name) !== ""; }

// SF Symbol file key for `name` ("" when it has none) and its point size in a `size` box.
function sfKey(name, weight) { return SF.pick(name, weight || "regular", "", -1); }
function pointSize(name, size) { return size * SF.pointScale * (scale[name] || 1); }

// SVG markup of the hand-drawn `name` in `color` (CSS color string). knock parts are drawn in `knockColor`.
function svg(name, color, knockColor) {
    const parts = table[name] || [];
    let body = "";
    for (const p of parts) {
        const c = p.knock ? (knockColor || "#fff") : color;
        body += p.fill
            ? '<path d="' + p.d + '" fill="' + c + '"/>'
            : '<path d="' + p.d + '" fill="none" stroke="' + c + '" stroke-width="' + p.w
              + '" stroke-linecap="round" stroke-linejoin="round"/>';
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">' + body + "</svg>";
}

// Image URL of `name` in `color` (opaque CSS colour), filling a square box: drawn into a box of any size,
// it shows the glyph at the same point size and placement as Symbol.qml at that size.
function url(name, color, knockColor) {
    const key = sfKey(name);
    if (key)
        return SF.url(key, color, SF.layout(key, pointSize(name, 24), 24, true).vb);
    return "data:image/svg+xml;utf8," + encodeURIComponent(svg(name, color, knockColor));
}
