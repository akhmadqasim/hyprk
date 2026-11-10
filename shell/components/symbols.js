// Original monochrome glyphs drawn on a 24x24 grid, SF-Symbols-like weight.
// Each symbol is a list of parts: { d: svg path, fill: bool, sw: stroke width }.
// Replace with extracted SF Symbols outlines (themes/icons) when available.
.pragma library

function rr(x, y, w, h, r) {
    return `M${x + r} ${y}H${x + w - r}A${r} ${r} 0 0 1 ${x + w} ${y + r}V${y + h - r}A${r} ${r} 0 0 1 ${x + w - r} ${y + h}H${x + r}A${r} ${r} 0 0 1 ${x} ${y + h - r}V${y + r}A${r} ${r} 0 0 1 ${x + r} ${y}Z`;
}
function circle(cx, cy, r) {
    return `M${cx - r} ${cy}A${r} ${r} 0 1 0 ${cx + r} ${cy}A${r} ${r} 0 1 0 ${cx - r} ${cy}Z`;
}
const F = d => ({ d: d, fill: true, sw: 0 });
const S = (d, sw) => ({ d: d, fill: false, sw: sw === undefined ? 1.8 : sw });

const wifiArcs = [
    F(circle(12, 18.6, 1.7)),
    S("M8.46 15.06A5 5 0 0 1 15.54 15.06", 2.1),
    S("M5.64 12.24A9 9 0 0 1 18.36 12.24", 2.1),
    S("M2.81 9.41A13 13 0 0 1 21.19 9.41", 2.1),
];

const symbols = {
    // generic distro mark (own drawing, shown when the icon theme has no logo for the distro):
    // a ring around a shell prompt chevron and cursor
    "distro": [S(circle(12, 12, 9.3), 1.9), S("M8.3 9.4L11.9 12L8.3 14.6", 1.9), S("M13.2 15H16.2", 1.9)],
    "wifi": wifiArcs,
    "wifi.slash": wifiArcs.concat([S("M4 3L20 21", 2.1)]),
    "battery": [S(rr(2.5, 7.5, 17, 9, 2.6), 1.3), F(rr(20.6, 10.4, 1.6, 3.2, 0.8))],
    "controlcenter": [S(rr(2.5, 4, 19, 7, 3.5), 1.5), F(circle(18, 7.5, 2.1)),
                      S(rr(2.5, 13, 19, 7, 3.5), 1.5), F(circle(6, 16.5, 2.1))],
    "magnifyingglass": [S(circle(10.2, 10.2, 6.4), 2.0), S("M15 15L20.5 20.5", 2.3)],
    "bluetooth": [S("M7 7.5L17 16.5L12 21V3L17 7.5L7 16.5", 1.8)],
    "moon": [F("M20.2 14.8A8.6 8.6 0 1 1 9.2 3.8A7.1 7.1 0 0 0 20.2 14.8Z")],
    "sun": [F(circle(12, 12, 4.2)),
            S("M12 2.5V4.6M12 19.4V21.5M2.5 12H4.6M19.4 12H21.5M5.3 5.3L6.8 6.8M17.2 17.2L18.7 18.7M5.3 18.7L6.8 17.2M17.2 6.8L18.7 5.3", 1.8)],
    "speaker": [F("M3.5 9H7.5L12.5 4.8V19.2L7.5 15H3.5Z"),
                S("M15.6 9.2A4 4 0 0 1 15.6 14.8", 1.8), S("M18.2 6.6A7.6 7.6 0 0 1 18.2 17.4", 1.8)],
    "speaker.slash": [F("M3.5 9H7.5L12.5 4.8V19.2L7.5 15H3.5Z"), S("M16 9.5L21 14.5M21 9.5L16 14.5", 1.8)],
    "play": [F("M7 4.6V19.4C7 20 7.6 20.3 8.1 20L20.2 12.6C20.7 12.3 20.7 11.7 20.2 11.4L8.1 4C7.6 3.7 7 4 7 4.6Z")],
    "pause": [F(rr(6, 4.5, 4, 15, 1)), F(rr(14, 4.5, 4, 15, 1))],
    "forward": [F("M2.5 6.3V17.7C2.5 18.3 3.1 18.6 3.6 18.3L11.8 12.6C12.2 12.3 12.2 11.7 11.8 11.4L3.6 5.7C3.1 5.4 2.5 5.7 2.5 6.3Z"),
                F("M12 6.3V17.7C12 18.3 12.6 18.6 13.1 18.3L21.3 12.6C21.7 12.3 21.7 11.7 21.3 11.4L13.1 5.7C12.6 5.4 12 5.7 12 6.3Z")],
    "backward": [F("M21.5 6.3V17.7C21.5 18.3 20.9 18.6 20.4 18.3L12.2 12.6C11.8 12.3 11.8 11.7 12.2 11.4L20.4 5.7C20.9 5.4 21.5 5.7 21.5 6.3Z"),
                 F("M12 6.3V17.7C12 18.3 11.4 18.6 10.9 18.3L2.7 12.6C2.3 12.3 2.3 11.7 2.7 11.4L10.9 5.7C11.4 5.4 12 5.7 12 6.3Z")],
    "airdrop": [F(circle(12, 14, 2.2)), S("M8.1 17.4A5.2 5.2 0 1 1 15.9 17.4", 1.7), S("M5.4 20.1A9 9 0 1 1 18.6 20.1", 1.7)],
    "display": [S(rr(2.5, 4, 19, 12.5, 2), 1.6), S("M9 20.5H15M12 16.5V20.5", 1.6)],
    "bell": [F("M12 2.8A6.2 6.2 0 0 0 5.8 9V13.4L4 16.3C3.7 16.8 4 17.3 4.6 17.3H19.4C20 17.3 20.3 16.8 20 16.3L18.2 13.4V9A6.2 6.2 0 0 0 12 2.8Z"),
             F("M9.5 18.6H14.5A2.5 2.5 0 0 1 9.5 18.6Z")],
    "xmark": [S("M6.5 6.5L17.5 17.5M17.5 6.5L6.5 17.5", 2.0)],
    "checkmark": [S("M5 12.6L9.6 17.2L19 6.8", 2.0)],
    "chevron.right": [S("M9 5.5L15.5 12L9 18.5", 2.0)],
    "chevron.down": [S("M5.5 9L12 15.5L18.5 9", 2.0)],
    "doc": [S("M6 2.8H13.5L18.5 7.8V20.2C18.5 20.8 18 21.2 17.5 21.2H6C5.5 21.2 5 20.8 5 20.2V3.8C5 3.2 5.5 2.8 6 2.8Z", 1.6), S("M13.5 2.8V7.8H18.5", 1.6)],
    "folder": [F("M2.5 6.5C2.5 5.4 3.4 4.5 4.5 4.5H9.2L11.2 6.5H19.5C20.6 6.5 21.5 7.4 21.5 8.5V18C21.5 19.1 20.6 20 19.5 20H4.5C3.4 20 2.5 19.1 2.5 18Z")],
    "equal": [S("M5 9H19M5 15H19", 2.2)],
    "square.grid": [F(rr(3, 3, 7.5, 7.5, 2)), F(rr(13.5, 3, 7.5, 7.5, 2)), F(rr(3, 13.5, 7.5, 7.5, 2)), F(rr(13.5, 13.5, 7.5, 7.5, 2))],
    "calendar": [S(rr(3, 4.5, 18, 16, 3), 1.6), S("M3 9.5H21M8 2.8V6M16 2.8V6", 1.6)],
    "keyboard": [S(rr(2, 6, 20, 12, 2.5), 1.6), S("M6 10H6.1M9.3 10H9.4M12.6 10H12.7M15.9 10H16M8 14H16", 2.0)],
    "screen.mirror": [S(rr(2.5, 3.5, 19, 12, 2), 1.6), F("M7.5 20.5L12 15.5L16.5 20.5Z")],
    "appstore": [S("M8.6 17.6L14.2 7.4M15.4 17.6L9.8 7.4M5.6 14.2H18.4", 1.8)],
    "ellipsis": [F(circle(5.5, 12, 1.6)), F(circle(12, 12, 1.6)), F(circle(18.5, 12, 1.6))],
    "person": [F(circle(12, 8, 4)), F("M4 20.5C4 16.4 7.6 13.8 12 13.8C16.4 13.8 20 16.4 20 20.5Z")],
};

function get(name) {
    return symbols[name] || [];
}
