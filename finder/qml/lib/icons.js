// Original drawn file-type icons (folder, generic document) as SVG data URLs.
// Used whenever there is no thumbnail; the generic document is the universal fallback.
.pragma library

function dataUrl(svg) {
    return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
}

// macOS-style blue folder on a 64x64 canvas, bottom aligned.
function folder(back, front, top) {
    return dataUrl(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
        + '<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
        + '<stop offset="0" stop-color="' + top + '"/><stop offset="0.12" stop-color="' + front + '"/>'
        + '<stop offset="1" stop-color="' + front + '"/></linearGradient></defs>'
        + '<path d="M5 13.5A3.5 3.5 0 0 1 8.5 10H23.2a3 3 0 0 1 2.2 1L28.6 14.6H55.5A3.5 3.5 0 0 1 59 18.1V51.5A3.5 3.5 0 0 1 55.5 55H8.5A3.5 3.5 0 0 1 5 51.5Z" fill="' + back + '"/>'
        + '<path d="M5 22A3.5 3.5 0 0 1 8.5 18.5H55.5A3.5 3.5 0 0 1 59 22V51.5A3.5 3.5 0 0 1 55.5 55H8.5A3.5 3.5 0 0 1 5 51.5Z" fill="url(#g)"/>'
        + '<path d="M5.5 52.6H58.5" stroke="#000" stroke-opacity="0.08" stroke-width="1"/>'
        + '</svg>');
}

// White page with a folded corner on a 64x64 canvas.
function document(dark) {
    const page = dark ? "#E9E9EB" : "#FFFFFF";
    return dataUrl(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
        + '<path d="M15 3.5H39.5L51.5 15.5V58.5A2 2 0 0 1 49.5 60.5H15A2 2 0 0 1 13 58.5V5.5A2 2 0 0 1 15 3.5Z" fill="' + page + '" stroke="#000" stroke-opacity="0.16" stroke-width="1"/>'
        + '<path d="M39.5 3.5V13.5A2 2 0 0 0 41.5 15.5H51.5Z" fill="#DCDCDE" stroke="#000" stroke-opacity="0.12" stroke-width="1" stroke-linejoin="round"/>'
        + '</svg>');
}

// Zipper strip printed on archives.
function zipper() {
    let d = "";
    for (let y = 8; y < 30; y += 4)
        d += "M30 " + y + "H32.4M31.6 " + (y + 2) + "H34";
    return dataUrl(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
        + '<path d="' + d + '" stroke="#8E8E93" stroke-width="1.4"/>'
        + '<rect x="29" y="30" width="6" height="8" rx="1.5" fill="none" stroke="#8E8E93" stroke-width="1.3"/>'
        + '</svg>');
}
