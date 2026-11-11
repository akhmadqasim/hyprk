#!/usr/bin/env python3 -I
"""CoreUI BVG vector glyph decoder (macOS 27.2.1 CoreGlyphs Assets.car), path part.

Reconstructed from CoreUI in the 27.2.1 dyld cache:
  CSIBVGNibbleReader readNibble 0x18f2e5d44 / readByte 0x18f2e5b70 / readValue 0x18f2e5bdc
  CSIBVGPathDecoder::createDecodedPath 0x18f2e5484, ReadState::consumeFlag 0x18f2e5d98
  decodeGenericValue 0x18f2e5e34, CSIBVGCoding::CommandByte::resolvedSVGCommand 0x18f2e60f4
  tables 0x18f32b8f0.. (kIntegerLargeBits, kIntegerSmallBits, integerWidths, halfNibbleDecimalWidths,
  decimalWidths, exponentWidths, kPowersOf10)
"""
import struct

LARGE = [8, 10, 12, 14]          # CSIBVGCoding::kIntegerLargeBits
SMALL = [4, 6, 8, 10]            # CSIBVGCoding::kIntegerSmallBits
INTW = [4, 8, 12, 32]            # integerWidths
HALFDEC = [10, 14, 26, 38]       # halfNibbleDecimalWidths
DECW = [12, 16, 28, 40]          # decimalWidths
EXPW = [8, 12]                   # exponentWidths
CMDS = "LCSQTHVZlcsqthv"          # high nibble of the command byte (0 / 8 become M / m at a subpath start)


class Reader:
    def __init__(self, data):
        self.d, self.pos, self.half = data, 0, 0

    def more(self):
        return self.pos < len(self.d)

    def nibble(self):
        if self.pos >= len(self.d): raise EOFError
        b = self.d[self.pos]
        v = (b >> 4) if self.half == 0 else (b & 15)
        self.pos += self.half; self.half ^= 1
        return v

    def peek(self):
        b = self.d[self.pos]
        return (b >> 4) if self.half == 0 else (b & 15)

    def byte(self):
        if self.half == 0:
            if self.pos >= len(self.d): raise EOFError
            v = self.d[self.pos]; self.pos += 1; return v
        if self.pos + 1 >= len(self.d): raise EOFError
        v = ((self.d[self.pos] & 15) << 4) | (self.d[self.pos + 1] >> 4); self.pos += 1
        return v

    def value(self, n):
        if n == 2: return self.byte()
        v = 0
        for _ in range(n): v = (v << 4) | self.nibble()
        return v


def count_digits(v):
    return len(str(v))


def generic(r, wc):
    n0 = r.nibble()
    if wc:
        bits = INTW[(n0 >> 1) & 3]
        ip = ((n0 & 1) << bits) | r.value(bits >> 2)
    else:
        ip = n0 & 7
    val = float(ip)
    if not n0 & 8: return val
    n1 = r.nibble()
    if not n1 & 4:
        n2 = r.nibble(); mode = n1 & 3; zeros = 0
        if mode == 0:
            frac = n2
        elif mode == 1:
            w = HALFDEC[(n2 >> 2) & 3] - 2
            frac = ((n2 & 3) << w) | r.value(w >> 2)
        elif mode == 2:
            w = DECW[n2 & 3]
            frac = r.value(w >> 2); zeros = (n2 >> 2) & 3
        else:
            n3 = r.nibble(); w = HALFDEC[(n3 >> 2) & 3] - 2
            frac = ((n3 & 3) << w) | r.value(w >> 2); zeros = n2
        if frac: val += frac / 10 ** (count_digits(frac) + zeros)
        if not n1 & 8: return val
    n = r.nibble()
    if not n & 4: raise ValueError("bad exponent nibble")
    e = r.value(EXPW[n & 1] >> 2)
    return val / 10 ** e if n & 2 else val * 10 ** e


def decode_path(data):
    """section bytes -> list of (command letter, [floats])"""
    r = Reader(data)
    if r.byte() != 0: raise ValueError("path version")
    nseg, npts = r.value(4), r.value(4)
    out, open_ = [], False
    while r.more():
        try: cmd = r.byte()
        except EOFError: break          # as CoreUI: a failed command read ends the path
        if cmd > 0xEF: raise ValueError("command byte %#x" % cmd)
        if cmd & 0xF0 == 0x70:
            out.append(("Z", [])); open_ = False; continue
        if cmd & 3:
            sets = r.value(cmd & 3); flag = r.byte(); wc = 0
        else:
            nb = r.nibble(); flag = 8 | ((nb >> 2) & 3); wc = nb & 3; sets = 1
        hi = cmd >> 4
        letter = CMDS[hi]
        if hi in (0, 8) and not open_: letter = "M" if hi == 0 else "m"
        open_ = True
        vals = []
        while True:
            # consumeFlag
            if flag & 4: wc = r.nibble()
            pairs = (flag >> 4) + 1 if flag & 8 else r.value(flag >> 4)
            sets -= 1
            sx = -1.0 if flag & 2 else 1.0
            sy = -1.0 if flag & 1 else 1.0
            for _ in range(pairs):
                if not r.more(): break
                if cmd & 8:
                    p = r.peek()
                    bx = LARGE[wc] if p & 8 else SMALL[wc]
                    by = LARGE[wc] if p & 4 else SMALL[wc]
                    v = r.value((bx + by) >> 2)
                    x = (v >> (by - 1)) & ((1 << (bx - 1)) - 1)
                    y = v & ((1 << (by - 1)) - 1)
                    x, y = float(x), float(y)
                else:
                    x = generic(r, wc); y = generic(r, wc)
                vals += [x * sx if x else 0.0, y * sy if y else 0.0]
            if sets == 0 or not r.more(): break
            flag = r.byte()
        if vals and cmd & 4: vals.pop()
        out.append((letter, vals))
    return dict(segments=nseg, points=npts, commands=out)


def container(blob):
    """BVG blob (after the 12-byte DWAR header as car.py dumps it) -> header fields and section byte strings"""
    assert blob[:4] == b"BVG "
    ver, fl = blob[4], blob[5]
    w = fl & 15
    fmt = {1: "<B", 2: "<H", 4: "<I"}[w]
    p = 6
    def rd():
        nonlocal p
        v = struct.unpack_from(fmt, blob, p)[0]; p += w; return v
    size, end = rd(), rd(); n = blob[p]; p += 1
    offs = [rd() for _ in range(n + 1)]
    secs = [blob[offs[i]:offs[i + 1]] for i in range(n)]
    return dict(version=ver, flags=fl, size=size, end=end, offsets=offs, sections=secs, tail=blob[end:])


def to_d(cmds):
    return " ".join(c + (" " + " ".join("%g" % v for v in vals) if vals else "") for c, vals in cmds)


def paths(blob):
    """-> (transform string, [path dicts]) : every section that is path data (version 0, u16 segment and point
    counts, then a command stream that decodes to exactly that many points), in document order"""
    c = container(blob)
    m, out = "", []
    for si, s in enumerate(c["sections"]):
        if s.startswith(b"matrix("): m = s.decode(); continue
        if len(s) < 6 or s[:2] != b"\x00\x00": continue
        try:
            p = decode_path(s)
        except (ValueError, EOFError, IndexError):
            continue
        npts = sum(len(v) for _, v in p["commands"]) // 2
        p["decoded_points"] = npts; p["section"] = si
        out.append(p)
    return m, out


def svg(blob, size=None):
    """BVG blob -> standalone SVG (all path layers filled black, monochrome rendering), viewBox in points"""
    m, ps = paths(blob)
    body = "".join(f'<path fill-rule="nonzero" fill="rgb(0%, 0%, 0%)" d="{to_d(p["commands"])}"/>\n' for p in ps)
    return ('<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">\n'
            f'<g transform="{m}">\n{body}</g>\n</svg>\n')


def decode_numbers(data):
    """CSIBVGNumericListDecoder::createDecodedString 0x18f2e58cc: section bytes -> list of numbers"""
    r = Reader(data)
    if r.byte() != 0: raise ValueError("list version")
    hdr = r.byte()
    sets = hdr & 0x1F if hdr & 0x40 else r.value(hdr & 3)
    if not sets: raise ValueError("empty list")
    flag = r.byte(); wc = 0; out = []
    while r.more():
        if flag & 4: wc = r.nibble()
        pairs = (flag >> 4) + 1 if flag & 8 else r.value(flag >> 4)
        sets -= 1
        sx = -1.0 if flag & 2 else 1.0
        sy = -1.0 if flag & 1 else 1.0
        while pairs and r.more():
            if hdr & 0x80:
                p = r.peek()
                bx = LARGE[wc] if p & 8 else SMALL[wc]
                by = LARGE[wc] if p & 4 else SMALL[wc]
                v = r.value((bx + by) >> 2)
                x, y = float((v >> (by - 1)) & ((1 << (bx - 1)) - 1)), float(v & ((1 << (by - 1)) - 1))
            else:
                x, y = generic(r, wc), generic(r, wc)
            x = x * sx if x else 0.0; y = y * sy if y else 0.0
            pairs -= 1
            out.append(x)
            if hdr & 0x20 and pairs == 0 and sets == 0: break
            out.append(y)
        if sets == 0: break
        flag = r.byte()
    return out


WEIGHTS = {"ultralight": 1, "thin": 2, "light": 3, "regular": 4, "medium": 5, "semibold": 6, "bold": 7, "heavy": 8, "black": 9}


def canonical(cmds):
    """commands -> absolute segments [('M', x, y) | ('L', x, y) | ('C', x1, y1, x2, y2, x, y) | ('Z',)]: relative
    coordinates resolved, H / V as L, S / T / Q as C (Q raised to cubic), so the three weight masters line up"""
    out = []; cx = cy = sx = sy = 0.0; lc = None; lq = None
    for c, v in cmds:
        C, rel = c.upper(), c.islower()
        if C == "Z":
            out.append(("Z",)); cx, cy = sx, sy; lc = lq = None; continue
        n = {"M": 2, "L": 2, "C": 6, "S": 4, "Q": 4, "T": 2, "H": 1, "V": 1}[C]
        for i in range(0, len(v), n):
            g = v[i:i + n]
            ox, oy = (cx, cy) if rel else (0.0, 0.0)
            if C == "H": x, y = (cx + g[0] if rel else g[0]), cy; out.append(("L", x, y)); lc = lq = None
            elif C == "V": x, y = cx, (cy + g[0] if rel else g[0]); out.append(("L", x, y)); lc = lq = None
            elif C in "ML":
                x, y = ox + g[0], oy + g[1]
                if C == "M" and i == 0: out.append(("M", x, y)); sx, sy = x, y
                else: out.append(("L", x, y))
                lc = lq = None
            elif C == "C":
                x1, y1, x2, y2, x, y = ox + g[0], oy + g[1], ox + g[2], oy + g[3], ox + g[4], oy + g[5]
                out.append(("C", x1, y1, x2, y2, x, y)); lc = (x2, y2); lq = None
            elif C == "S":
                x1, y1 = (2 * cx - lc[0], 2 * cy - lc[1]) if lc else (cx, cy)
                x2, y2, x, y = ox + g[0], oy + g[1], ox + g[2], oy + g[3]
                out.append(("C", x1, y1, x2, y2, x, y)); lc = (x2, y2); lq = None
            else:   # Q / T
                if C == "Q": qx, qy, x, y = ox + g[0], oy + g[1], ox + g[2], oy + g[3]
                else: (qx, qy), x, y = ((2 * cx - lq[0], 2 * cy - lq[1]) if lq else (cx, cy)), ox + g[0], oy + g[1]
                out.append(("C", cx + 2 / 3 * (qx - cx), cy + 2 / 3 * (qy - cy), x + 2 / 3 * (qx - x), y + 2 / 3 * (qy - y), x, y))
                lq = (qx, qy); lc = None
            cx, cy = x, y
    return out


def seg_d(segs, k=1.0, dx=0.0, dy=0.0):
    """absolute segments -> path data, mapped by x * k + dx, y * k + dy"""
    parts = []
    for s in segs:
        if s[0] == "Z": parts.append("Z"); continue
        parts.append(s[0] + " " + " ".join("%.6g" % (v * k + (dx if i % 2 == 0 else dy)) for i, v in enumerate(s[1:])))
    return " ".join(parts)


def interpolate(blobs, weight):
    """{1: blob, 4: blob, 9: blob} (the weight masters, rendition attribute 26) -> (matrix numbers, [segment lists])
    at a weight, linear in the weight index (1 ultralight .. 9 black) between the two enclosing masters"""
    import re as _re
    w = WEIGHTS[weight] if isinstance(weight, str) else weight
    lo, hi = (1, 4) if w <= 4 else (4, 9)
    t = (w - lo) / (hi - lo)
    (ma, pa), (mb, pb) = paths(blobs[lo]), paths(blobs[hi])
    if len(pa) != len(pb): raise ValueError("masters differ in path count")
    out = []
    for a, b in zip(pa, pb):
        A, B = canonical(a["commands"]), canonical(b["commands"])
        if [s[0] for s in A] != [s[0] for s in B]: raise ValueError("masters differ in segments")
        out.append([(sa[0],) + tuple(x + (y - x) * t for x, y in zip(sa[1:], sb[1:])) for sa, sb in zip(A, B)])
    fa = [float(x) for x in _re.findall(r"-?[\d.]+", ma)]; fb = [float(x) for x in _re.findall(r"-?[\d.]+", mb)]
    return [x + (y - x) * t for x, y in zip(fa, fb)], out


# AppKit's symbol image at pointSize 32 (themes/icons/sf-symbols/svg, rendered on the Mac) = the three masters
# blended as W4 + u (W1 - W4) + v (W9 - W4), scaled by K (points per 13-unit) with the font baseline at the image
# origin's x: least squares over 10 symbols x 3 weights against those renders, residual 0.001 pt in every case.
K32 = 3.1409
BLEND = {"regular": (0.182, 0.0), "medium": (0.148, 0.165), "semibold": (0.123, 0.291)}


def bbox13(blob):
    """section 0: the glyph box 0 0 w h in the matrix's (13 pt) units"""
    for s in container(blob)["sections"]:
        if s[:1] == b"\x00" and s[1:2] not in (b"\x00", b""):
            try:
                v = decode_numbers(s)
            except (ValueError, EOFError, IndexError):
                continue
            if len(v) == 4 and v[0] == 0 and v[1] == 0: return v[2], v[3]
    return None


def layered(blob, by_section):
    """monochrome drawing from the document tree. A layer is a class "monochrome-<n>" (class records in order);
    its shape is all path nodes carrying that class, as one compound path (nonzero), so a node can belong to
    several layers (display: the screen is the hole of layer 0; rectangle.on.rectangle: the front rectangle is
    a knockout layer and, with its inner outline, the drawn layer after it). A layer styled
    -sfsymbols-clear-behind: true cuts its shape out of the layers drawn before it; opacity 0 layers are not
    drawn. The node's own opacity attribute is ignored (it repeats its first class)."""
    try:
        T = tree(blob)
    except (IndexError, struct.error, KeyError, ValueError):
        return list(by_section.values())
    nodes = [n for n in T["nodes"] if n["element"] == "path" and isinstance(n["attrs"].get("d"), tuple)]
    mono = [c for c in T["classes"] if c["mode"] == "monochrome"]
    if not mono: return list(by_section.values())
    drawn = []
    for c in mono:
        segs = [x for n in nodes if any(k is c for k in n["classes"]) and n["attrs"]["d"][1] in by_section
                for x in by_section[n["attrs"]["d"][1]]]
        if not segs: continue
        style = T["blocks"].get(c["decl"], {})
        if (style.get("-sfsymbols-clear-behind") or ["false"])[0] == "true":
            drawn = [r for r in (subtract(x, segs) for x in drawn) if r]
        if float((style.get("opacity") or ["1"])[0]) > 0: drawn.append(segs)
    return drawn


def blended(blobs, weight):
    """(matrix numbers, bbox w h, [segment lists]) for regular / medium / semibold"""
    import re as _re
    u, v = BLEND[weight]
    mats, segs, boxes = {}, {}, {}
    for w in (1, 4, 9):
        m, ps = paths(blobs[w])
        mats[w] = [float(x) for x in _re.findall(r"-?[\d.]+", m)]
        segs[w] = [canonical(p["commands"]) for p in ps]
        boxes[w] = bbox13(blobs[w])
    mix = lambda a, b, c: a + u * (b - a) + v * (c - a)
    out = []
    for A, B, C in zip(segs[4], segs[1], segs[9]):
        if not ([s[0] for s in A] == [s[0] for s in B] == [s[0] for s in C]): raise ValueError("masters differ")
        out.append([(a[0],) + tuple(mix(x, y, z) for x, y, z in zip(a[1:], b[1:], c[1:])) for a, b, c in zip(A, B, C)])
    sections = [p["section"] for p in paths(blobs[4])[1]]
    out = layered(blobs[4], dict(zip(sections, out)))
    m = [mix(x, y, z) for x, y, z in zip(mats[4], mats[1], mats[9])]
    box = tuple(mix(x, y, z) for x, y, z in zip(boxes[4], boxes[1], boxes[9]))
    return m, box, out


def appkit_svg(blobs, weight, margins=None):
    """SVG in the style of themes/icons/sf-symbols/svg (32 pt NSImage canvas) + metadata for names.json.
    Canvas rule read off the 30 Mac renders (10 symbols x 3 weights): glyph bottom 3 pt above the canvas bottom,
    height = ceil(glyph height + 6); glyph left = the left side bearing snapped to 0.5 pt (all 30 exact); width =
    ceil(left + glyph width + bearing) (25 of 30 exact, the rest 1 pt narrow: the advance is not decoded)."""
    import math
    m, (bw, bh), segs = blended(blobs, weight)
    s, tx, ty = m[0], m[4], m[5]
    k = K32 * s
    gw, gh, lsb = K32 * bw, K32 * bh, -K32 * tx
    rsb = lsb
    if margins:   # rendition TLV 0x3fa per master: [7, 13, ?, capHeight, ?, left, top, right, bottom] (13 pt units)
        u, v = BLEND[weight]
        mix = lambda i: margins[4][i] + u * (margins[1][i] - margins[4][i]) + v * (margins[9][i] - margins[4][i])
        lsb, rsb = K32 * mix(5), K32 * mix(7)
    H = math.ceil(gh + 6 - 1e-6)
    top = H - 3 - gh
    left = max(0.0, round(lsb * 2) / 2)          # a negative bearing (overhang) puts the glyph at the edge
    W = math.ceil(left + gw + max(0.0, rsb) - 1e-6)
    dx, dy = left + K32 * tx, top + K32 * ty      # glyph box left at `left`; dy = the font baseline in the canvas
    body = "".join(f'<path fill-rule="nonzero" fill="rgb(0%, 0%, 0%)" fill-opacity="1" d="{seg_d(p, k, dx, dy)}"/>\n' for p in segs)
    svgtext = ('<?xml version="1.0" encoding="UTF-8"?>\n'
               f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{W}pt" height="{H}pt" viewBox="0 0 {W} {H}">\n'
               f'{body}</svg>\n')
    base = round((dy - 3.1) * 2) / 2
    snap = lambda v: round(v * 2) / 2
    fl = lambda v: math.floor(v * 2 + 1e-6) / 2
    ce = lambda v: math.ceil(v * 2 - 1e-6) / 2
    gx, gy = fl(left), fl(top)
    meta = dict(pointSize=32, size=[W, H], alignmentRect=[round((left - lsb) * 2) / 2, base - 22.5, ce(gw + lsb + rsb), 22.5], baselineY=base,
                capHeight=22.5, glyphRect=[gx, gy, ce(left + gw) - gx, ce(top + gh) - gy], paths=len(segs),
                fillOpacities=[1.0], hierarchyLevels=[0] * len(segs), fontBaselineY=round(dy, 3))
    return svgtext, meta


ATOMS = ("svg g viewBox path rect circle ellipse line polyline polygon width height x y cx cy r rx ry fill opacity "
         "transform d points id class x1 y1 x2 y2 none 0 1 0.0 -sfsymbols-motion-group -sfsymbols-variable-threshold "
         "-sfsymbols-layer-tags -sfsymbols-always-rotates -sfsymbols-draw-reverses-motion-groups "
         "-sfsymbols-variable-value-mode -sfsymbols-vc-continuous -sfsymbols-always-pulses -sfsymbols-clear-behind "
         "-sfsymbols-fill-action -sfsymbols-indices -sfsymbols-variable-draw -sfsymbols-clipstroke-attachments "
         "-sfsymbols-wiggle-style -sfsymbols-rotates-clockwise color draw erase .defaults true false primary secondary "
         "tertiary multicolor hierarchical monochrome data-clipstroke-keyframes LayerTree s ra da black "
         "controlAccentColor knockout labelColor secondaryLabelColor tertiaryLabelColor quaternaryLabelColor "
         "systemBlueColor systemBrownColor systemCyanColor systemGrayColor systemGreenColor systemIndigoColor "
         "systemMintColor systemOrangeColor systemPinkColor systemPurpleColor systemRedColor systemTealColor "
         "systemYellowColor tintColor white custom").split()   # _CSIBVGPredefinedStrings (89 CFStrings), in order
MODES = {0x80: "monochrome", 0x81: "multicolor", 0x82: "hierarchical"}


def tree(blob):
    """the document tail (1-byte index variant, flags 0x12 blobs): class records, declaration blocks, nodes.
    Atom index < 89 = predefined string, else section (index - 89) of the container."""
    c = container(blob); t = c["tail"]; secs = c["sections"]
    w = c["flags"] & 15; fmt = {1: "<B", 2: "<H", 4: "<I"}[w]
    atom = lambda i: ATOMS[i] if i < len(ATOMS) else ("sec", i - len(ATOMS))
    n = t[0]; classes = []; p = 1
    for _ in range(n):
        a, b, v, off = t[p], t[p + 1], t[p + 2], struct.unpack_from(fmt, t, p + 3)[0]; p += 3 + w
        classes.append(dict(mode=MODES.get(a, ".defaults" if a == 0 else a), layer=b, value=None if v == 0xFF else atom(v), decl=off))
    blocks = {}
    while p < len(t) and p in {cl["decl"] for cl in classes} | ({p} if not blocks else set()) or (blocks and p <= max(cl["decl"] for cl in classes)):
        start, cnt = p, t[p]; p += 1; decls = {}
        for _ in range(cnt):
            k, nv = t[p], t[p + 1]; vals = [atom(x) for x in t[p + 2:p + 2 + nv]]; p += 2 + nv
            decls[atom(k)] = vals
        blocks[start] = decls
    area = p; nref = t[p]; p += 1
    refs = [(atom(t[p + (1 + w) * i]), struct.unpack_from(fmt, t, p + (1 + w) * i + 1)[0]) for i in range(nref)]
    p += (1 + w) * nref
    nodes = []
    while p < len(t):
        el, ident, na, nc, nch = t[p:p + 5]; p += 5
        attrs = {atom(t[p + 2 * i]): atom(t[p + 2 * i + 1]) for i in range(na)}; p += 2 * na
        cls = list(t[p:p + nc]); p += nc
        kids = [struct.unpack_from(fmt, t, p + w * i)[0] for i in range(nch)]; p += w * nch
        nodes.append(dict(element=atom(el), attrs=attrs, classes=[classes[i] for i in cls], children=kids))
    for nd in nodes:
        style = {}
        for cl in nd["classes"]:
            if cl["mode"] == "monochrome": style.update(blocks.get(cl["decl"], {}))
        nd["mono"] = style
    return dict(classes=classes, blocks=blocks, nodes=nodes, refs=refs)


# ---------- knockouts (-sfsymbols-clear-behind): the layer's shape is cut out of the layers drawn before it.
# AppKit's renders (themes/icons/sf-symbols/svg, pdftocairo) carry the result as plain paths, so it is done here
# geometrically on the Bezier segments: split both outlines where they cross, keep the drawn outline outside the
# knockout and the knockout outline inside the drawn shape, chain the pieces into loops, orient for nonzero.

def _pieces(segs):
    """absolute segments -> closed subpaths of pieces ('L', p0, p1) / ('C', p0, c1, c2, p1)"""
    subs, cur, start, pt = [], None, None, None
    for s in segs:
        if s[0] == "M":
            if cur: subs.append(cur)
            cur, start, pt = [], (s[1], s[2]), (s[1], s[2])
        elif s[0] == "L":
            cur.append(("L", pt, (s[1], s[2]))); pt = (s[1], s[2])
        elif s[0] == "C":
            cur.append(("C", pt, (s[1], s[2]), (s[3], s[4]), (s[5], s[6]))); pt = (s[5], s[6])
        else:
            if pt != start and cur is not None: cur.append(("L", pt, start))
            pt = start
            if cur: subs.append(cur)
            cur = None
    if cur: subs.append(cur)
    return subs


def _at(pc, t):
    if pc[0] == "L":
        (x0, y0), (x1, y1) = pc[1], pc[2]; return (x0 + (x1 - x0) * t, y0 + (y1 - y0) * t)
    p0, c1, c2, p1 = pc[1:]; u = 1 - t
    return tuple(u * u * u * a + 3 * u * u * t * b + 3 * u * t * t * c + t * t * t * d for a, b, c, d in zip(p0, c1, c2, p1))


def _split(pc, t0, t1, a, b):
    """the part of a piece between t0 and t1, its end points forced to a and b"""
    if pc[0] == "L": return ("L", a, b)
    def sub(p, t):   # de Casteljau: (left, right) at t
        p0, p1, p2, p3 = p
        l = lambda u, v: (u[0] + (v[0] - u[0]) * t, u[1] + (v[1] - u[1]) * t)
        a1, b1, c1 = l(p0, p1), l(p1, p2), l(p2, p3); a2, b2 = l(a1, b1), l(b1, c1); m = l(a2, b2)
        return (p0, a1, a2, m), (m, b2, c1, p3)
    q = pc[1:]
    if t1 < 1: q = sub(q, t1)[0]
    if t0 > 0: q = sub(q, t0 / t1)[1]
    return ("C", a, q[1], q[2], b)


def _flat(pc, n=32):
    return [(i / n, _at(pc, i / n)) for i in range(n + 1)]


def _poly(subs, n=32):
    out = []
    for sub in subs:
        pts = []
        for pc in sub: pts += [p for _, p in _flat(pc, n)][:-1]
        out.append(pts)
    return out


def _winding(polys, p):
    x, y = p; w = 0
    for pts in polys:
        for i in range(len(pts)):
            (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % len(pts)]
            if y0 <= y < y1 or y1 <= y < y0:
                xi = x0 + (y - y0) * (x1 - x0) / (y1 - y0)
                if xi > x: w += 1 if y1 > y0 else -1
    return w


def _cross_pts(A, B):
    """intersections of two pieces on their flattenings -> [(ta, tb, point)]"""
    fa, fb = _flat(A), _flat(B)
    ax = [p[0] for _, p in fa]; ay = [p[1] for _, p in fa]; bx = [p[0] for _, p in fb]; by = [p[1] for _, p in fb]
    if max(ax) < min(bx) or max(bx) < min(ax) or max(ay) < min(by) or max(by) < min(ay): return []
    out = []
    for i in range(len(fa) - 1):
        (t0, p0), (t1, p1) = fa[i], fa[i + 1]
        for j in range(len(fb) - 1):
            (s0, q0), (s1, q1) = fb[j], fb[j + 1]
            d = (p1[0] - p0[0]) * (q1[1] - q0[1]) - (p1[1] - p0[1]) * (q1[0] - q0[0])
            if abs(d) < 1e-12: continue
            u = ((q0[0] - p0[0]) * (q1[1] - q0[1]) - (q0[1] - p0[1]) * (q1[0] - q0[0])) / d
            v = ((q0[0] - p0[0]) * (p1[1] - p0[1]) - (q0[1] - p0[1]) * (p1[0] - p0[0])) / d
            if 0 <= u < 1 and 0 <= v < 1:
                out.append((t0 + (t1 - t0) * u, s0 + (s1 - s0) * v, (p0[0] + (p1[0] - p0[0]) * u, p0[1] + (p1[1] - p0[1]) * u)))
    return out


def _deriv(pc, t):
    if pc[0] == "L": return (pc[2][0] - pc[1][0], pc[2][1] - pc[1][1])
    p0, c1, c2, p1 = pc[1:]; u = 1 - t
    return tuple(3 * u * u * (b - a) + 6 * u * t * (c - b) + 3 * t * t * (d - c) for a, b, c, d in zip(p0, c1, c2, p1))


def subtract(Psegs, Ksegs, eps=0.5):
    """area of P (nonzero) minus the area of K (nonzero) -> segments (nonzero). Both outlines are split wherever
    any two pieces cross (also P with P, K with K: overlapping subpaths); a piece is kept when the result region
    (wind P != 0 and wind K == 0) lies on exactly one side of it, oriented with the region on its left."""
    P, K = _pieces(Psegs), _pieces(Ksegs)
    allp = [pc for s in P for pc in s] + [pc for s in K for pc in s]
    cuts = [[] for _ in allp]
    for i in range(len(allp)):
        for j in range(i + 1, len(allp)):
            for ta, tb, pt in _cross_pts(allp[i], allp[j]):
                if (ta < 1e-6 or ta > 1 - 1e-6) and (tb < 1e-6 or tb > 1 - 1e-6): continue   # shared end points
                cuts[i].append((ta, pt)); cuts[j].append((tb, pt))
    pp, kp = _poly(P), _poly(K)
    inside = lambda q: _winding(pp, q) != 0 and _winding(kp, q) == 0
    edges = []
    for pc, cs in zip(allp, cuts):
        cs = sorted(c for c in cs if 1e-6 < c[0] < 1 - 1e-6)
        ts = [(0.0, pc[1])] + cs + [(1.0, pc[-1])]
        for (t0, a), (t1, b) in zip(ts, ts[1:]):
            if t1 - t0 < 1e-9: continue
            e = _split(pc, t0, t1, a, b)
            m = _at(e, 0.5); dx, dy = _deriv(e, 0.5); n = (dx * dx + dy * dy) ** 0.5 or 1
            left = (m[0] + dy / n * eps, m[1] - dx / n * eps)     # y down: left of travel = (dy, -dx)
            right = (m[0] - dy / n * eps, m[1] + dx / n * eps)
            li, ri = inside(left), inside(right)
            if li == ri: continue
            if ri: e = ("L", e[2], e[1]) if e[0] == "L" else ("C", e[4], e[3], e[2], e[1])
            edges.append(e)
    key = lambda p: (round(p[0], 2), round(p[1], 2))
    starts = {}
    for i, e in enumerate(edges): starts.setdefault(key(e[1]), []).append(i)
    used, out = set(), []
    for i in range(len(edges)):
        if i in used: continue
        loop, j = [], i
        while j is not None and j not in used:
            used.add(j); loop.append(edges[j])
            nxt = [k for k in starts.get(key(edges[j][-1]), []) if k not in used]
            j = nxt[0] if nxt else None
        out.append(("M",) + loop[0][1])
        for pc in loop: out.append(("L",) + pc[2] if pc[0] == "L" else ("C",) + pc[2] + pc[3] + pc[4])
        out.append(("Z",))
    return out


def from_car(car_path, names):
    """{symbol: ({1|4|9: BVG blob}, {1|4|9: TLV 0x3fa floats})} for the given SF Symbol names (facet names)"""
    import os, sys as _s
    here = os.path.dirname(os.path.abspath(__file__))
    if here not in _s.path: _s.path.insert(0, here)
    import car as C
    c = C.Car(car_path)
    kf = c.blk(c.vars["KEYFORMAT"]); n = struct.unpack_from("<I", kf, 8)[0]
    toks = list(struct.unpack_from("<%dI" % n, kf, 12))
    facet = {}
    for k, v in c.tree("FACETKEYS"):
        na = struct.unpack_from("<H", v, 4)[0]
        at = dict(struct.unpack_from("<HH", v, 6 + 4 * j) for j in range(na))
        facet[at.get(17)] = k.decode("latin1")
    want, out = set(names), {}
    for k, v in c.tree("RENDITIONS"):
        at = dict(zip(toks, struct.unpack_from("<%dH" % (len(k) // 2), k)))
        nm = facet.get(at.get(17))
        if nm not in want or v[:4] != b"ISTC" or struct.unpack_from("<H", v, 36)[0] != 1022: continue
        w = at.get(26)
        csi = C.parse_csi(v)
        if csi["payload"][:4] == b"DWAR" and csi["payload"][12:16] == b"BVG ":
            out.setdefault(nm, ({}, {}))[0][w] = csi["payload"][12:]
        tlvlen, bmc = struct.unpack_from("<II", v, 168); p = 180 + bmc * 4; end = p + tlvlen
        while p < end:
            t, l = struct.unpack_from("<II", v, p)
            if t == 0x3FA: out.setdefault(nm, ({}, {}))[1][w] = list(struct.unpack_from("<II8f", v, p + 8))
            p += 8 + l
    return out


if __name__ == "__main__":
    # bvg.py <CoreGlyphs Assets.car> <outdir> <symbol,symbol,...> [weights=regular,medium,semibold]
    #   -> <outdir>/<symbol>.<weight>.svg (as themes/icons/sf-symbols/svg) + <outdir>/names-files.json (metadata)
    import sys, os, json
    car_path, outdir, names = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
    weights = (sys.argv[4] if len(sys.argv) > 4 else "regular,medium,semibold").split(",")
    os.makedirs(outdir, exist_ok=True)
    got, meta = from_car(car_path, names), {}
    for nm in names:
        if nm not in got or set(got[nm][0]) != {1, 4, 9}:
            print("missing", nm); continue
        for wt in weights:
            svgtext, m = appkit_svg(got[nm][0], wt, got[nm][1] if set(got[nm][1]) == {1, 4, 9} else None)
            open(f"{outdir}/{nm}.{wt}.svg", "w").write(svgtext)
            meta[f"{nm}.{wt}.svg"] = dict(symbol=nm, weight=wt, mode="mono", **m)
    json.dump(meta, open(f"{outdir}/names-files.json", "w"), indent=1)
    print(len(meta), "files")
