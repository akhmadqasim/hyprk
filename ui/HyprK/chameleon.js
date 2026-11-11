.pragma library
// Sidebar "chameleon" tint (MAC-ANSWERS.md C3.1, 27.2.1): sidebar glass carries a CAChameleonLayer, a colour-blend
// fill of the mean wallpaper colour at opacity 0.10 dark / 0.05 light, above the sidebar colour f:
//   out = f + (SetLum(tint, Lum(f)) - f) * opacity,   Lum = 0.30 R + 0.59 G + 0.11 B   (encoded sRGB values)
// The tint is quantised to 6 bits per channel: min(trunc(c * 64), 63) / 63. Off when "Tint window background with
// wallpaper colour" is off. Colours are {r, g, b} in 0..1 (QML colours work too).

function quantise(c) { return Math.min(Math.trunc(c * 64), 63) / 63; }
function lum(c) { return 0.30 * c.r + 0.59 * c.g + 0.11 * c.b; }

// W3C compositing ClipColor / SetLum (the colour blend mode)
function clipColor(c) {
    const l = lum(c), n = Math.min(c.r, c.g, c.b), x = Math.max(c.r, c.g, c.b);
    let o = { r: c.r, g: c.g, b: c.b };
    if (n < 0) o = { r: l + (o.r - l) * l / (l - n), g: l + (o.g - l) * l / (l - n), b: l + (o.b - l) * l / (l - n) };
    if (x > 1) o = { r: l + (o.r - l) * (1 - l) / (x - l), g: l + (o.g - l) * (1 - l) / (x - l), b: l + (o.b - l) * (1 - l) / (x - l) };
    return o;
}
function setLum(c, l) {
    const d = l - lum(c);
    return clipColor({ r: c.r + d, g: c.g + d, b: c.b + d });
}

// f: sidebar colour, tint: mean wallpaper colour (already quantised) or null, dark: appearance. Returns {r, g, b}.
function apply(f, tint, dark) {
    if (!tint) return { r: f.r, g: f.g, b: f.b };
    const a = dark ? 0.10 : 0.05;
    const t = setLum(tint, lum(f));
    return { r: f.r + (t.r - f.r) * a, g: f.g + (t.g - f.g) * a, b: f.b + (t.b - f.b) * a };
}
