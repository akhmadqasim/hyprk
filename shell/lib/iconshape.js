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

// Apple continuous-corner rounded rect ("squircle") outline as points in a size x size box.
// Corner radius 0.225 of the side (macOS icon template: 185.4 on the 824 body) and the
// continuous-corner curve that spans 1.528665 r (SPEC.md "App icons"; the same constant as
// CoreAnimation's continuous corners), sampled from its three cubic segments per corner.
var CORNER = 0.225;
function squirclePoints(size, steps) {
    steps = steps || 8;
    var r = size * CORNER, w = size, pts = [];
    // one corner (top-right), in coordinates relative to the corner: [dx from right edge, dy from top]
    var segs = [
        [[1.52866483, 0], [1.08849296, 0], [0.86840694, 0], [0.63149399, 0.07491100]],
        [[0.63149399, 0.07491100], [0.37282383, 0.16905956], [0.16905956, 0.37282383], [0.07491100, 0.63149399]],
        [[0.07491100, 0.63149399], [0, 0.86840694], [0, 1.08849296], [0, 1.52866483]]
    ];
    var corner = [];
    for (var k = 0; k < 3; k++)
        for (var i = (k === 0 ? 0 : 1); i <= steps; i++) {
            var t = i / steps, u = 1 - t, c = segs[k];
            var bx = u*u*u*c[0][0] + 3*u*u*t*c[1][0] + 3*u*t*t*c[2][0] + t*t*t*c[3][0];
            var by = u*u*u*c[0][1] + 3*u*u*t*c[1][1] + 3*u*t*t*c[2][1] + t*t*t*c[3][1];
            corner.push([bx * r, by * r]);
        }
    // clockwise from the top edge: top-right, bottom-right, bottom-left, top-left
    var maps = [function (p) { return [w - p[0], p[1]]; }, function (p) { return [w - p[1], w - p[0]]; },
                function (p) { return [p[0], w - p[1]]; }, function (p) { return [p[1], p[0]]; }];
    for (var m = 0; m < 4; m++)
        for (var j = 0; j < corner.length; j++) pts.push(maps[m](corner[j]));
    return pts;
}
