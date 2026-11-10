.pragma library
// App icon shape analysis for the macOS 26 icon tile (components/AppIconTile.qml).
//
// macOS 26 draws every app icon as the same squircle. Icons that are not in that shape
// (round, square, free-form Linux icons) are put inside a standard squircle tile. Here we
// decide, from the icon's alpha channel, whether an icon already is a squircle-like tile,
// and where its visible body sits so all icons can be scaled to the same visual size.
//
// Pure functions + one process-wide cache (".pragma library" is shared by every importer),
// so each icon file is analysed once per process, not per instance or per frame.

var SAMPLE = 48;          // icons are drawn into a SAMPLE x SAMPLE canvas for analysis
var cache = {};

function cached(url) { return cache[url]; }
function store(url, info) { cache[url] = info; return info; }

// alpha: array-like of SAMPLE*SAMPLE*4 RGBA bytes (Canvas ImageData.data) or of n*n alphas
// when stride === 1. Returns { squircle, extent, cx, cy } in 0..1 units of the image:
//   squircle  the icon already is a filled rounded-square tile (no extra tile needed)
//   extent    size of the opaque body (max of width/height of its bounding box)
//   cx, cy    centre of that body
function analyze(data, n, stride) {
    n = n || SAMPLE;
    stride = stride || 4;
    var a = function (x, y) { return data[(y * n + x) * stride + (stride - 1)]; };
    var x0 = n, y0 = n, x1 = -1, y1 = -1, x, y;
    for (y = 0; y < n; y++)
        for (x = 0; x < n; x++)
            if (a(x, y) >= 128) {
                if (x < x0) x0 = x;
                if (x > x1) x1 = x;
                if (y < y0) y0 = y;
                if (y > y1) y1 = y;
            }
    if (x1 < 0) return { squircle: false, extent: 1, cx: 0.5, cy: 0.5 };
    var w = x1 - x0 + 1, h = y1 - y0 + 1;
    var info = { squircle: false, extent: Math.max(w, h) / n, cx: (x0 + x1 + 1) / 2 / n, cy: (y0 + y1 + 1) / 2 / n };

    // filled share of the bounding box: squircle ~0.95, circle 0.785, free-form far less
    var solid = 0;
    for (y = y0; y <= y1; y++)
        for (x = x0; x <= x1; x++)
            if (a(x, y) >= 128) solid++;
    var coverage = solid / (w * h);

    // the very corners of the box must be clear (rounded), else it is a plain square
    var c = Math.max(1, Math.round(Math.min(w, h) * 0.04));
    var corners = [[x0, y0, 1, 1], [x1, y0, -1, 1], [x0, y1, 1, -1], [x1, y1, -1, -1]];
    var cornerAlpha = 0, cells = 0;
    for (var k = 0; k < 4; k++)
        for (var i = 0; i < c; i++)
            for (var j = 0; j < c; j++) {
                cornerAlpha += a(corners[k][0] + corners[k][2] * i, corners[k][1] + corners[k][3] * j);
                cells++;
            }
    var aspect = w / h;
    info.squircle = info.extent >= 0.6 && aspect > 0.9 && aspect < 1.11
                    && coverage >= 0.86 && cornerAlpha / cells < 96;
    return info;
}

// Scale and offset that put the icon body at `target` (share of the drawn size), centred.
// Returns { scale, dx, dy } where dx/dy are offsets in units of the drawn size.
function fit(info, target, maxScale) {
    var s = Math.min(maxScale || 1.6, Math.max(0.6, target / info.extent));
    return { scale: s, dx: (0.5 - info.cx) * s, dy: (0.5 - info.cy) * s };
}

// Continuous-corner squircle outline (superellipse |x|^5 + |y|^5 = 1, close to Apple's icon
// mask, ~22% corner) as points in a size x size box.
function squirclePoints(size, steps) {
    steps = steps || 24;
    var r = size / 2, pts = [], e = 2 / 5;
    for (var q = 0; q < 4 * steps; q++) {
        var t = q / (4 * steps) * 2 * Math.PI;
        var ct = Math.cos(t), st = Math.sin(t);
        pts.push([r + r * (ct < 0 ? -1 : 1) * Math.pow(Math.abs(ct), e),
                  r + r * (st < 0 ? -1 : 1) * Math.pow(Math.abs(st), e)]);
    }
    return pts;
}
