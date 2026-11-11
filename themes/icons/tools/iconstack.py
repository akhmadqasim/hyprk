#!/usr/bin/env python3 -I
"""Icon Composer icon stacks in a macOS 27 Assets.car: decode and render them flat.

macOS 27.2.1 app cars hold ONE pre-rendered bitmap per app icon (the Default style, appearance
NSAppearanceNameSystem / UIAppearanceAny, used by build-apps.py) plus the layered source that
IconRendering composes at run time for the other styles: an `<icon>.iconstack` rendition (layout 1019)
per appearance (DarkAqua / Aqua / ISAppearanceTintable, ids per car in APPEARANCEKEYS) whose children are
a background fill (gradient part 247 or colour part 217) and IconGroups (layout 1020, part 246); a group's
children are SVG layers (part 181, LZFSE-compressed "DWAR" blobs) or deepmap2 bitmaps (dmp2.py). Per appearance the stack can swap the
background fill and give each layer a fill colour or gradient (COLR / GGRA renditions, by name).
No Dark / Clear / Tinted bitmap is stored in any of the 72 cars (themes/icons/README.md "Styles").

Record layouts (all little endian, found by reading the cars; field names are ours):
  CSI TLV 0x3f4 children: u32 count, u32 0, then per child
      u32 flags, i32 x, i32 y, i32 w, i32 h (1024 canvas units; 0,0,0,0 = whole canvas), u32 blendMode (CGBlendMode),
      f32 opacity,
      u32 keylen, keylen bytes of (u16 attribute, u16 value) rendition-key pairs (1 element, 2 part, 17 name id)
  CSI TLV 0x3fc fills: u32 count, u32 0, then per child u32 ?, u32 ?, u32 len, name[len] (COLR or GGRA name, "" = own colours)
  CSI TLV 0x3fd glass per child (20 bytes; CoreUI 27.2.1 -[_CUILayerStackRendition _initWithCSIHeader:version:] at
      0x18f2af564 reads them into the child's CUINamedIconLayerGroup / layer): u32 hasSpecular (bit 0), f32 translucency,
      u32 shadowStyle, f32 shadowOpacity, u32 specularPlacement
  CSI TLV 0x3fe refraction per child (12 bytes): f32 refractionStrength, f32 refractionHeight, u32 not read
      Both are decoded into node["glass"] (Stack.glass) and printed; the flat render does not use them: how
      IconRendering turns them into pixels is not decoded (reference/ASSETS.md)
  COLR "RLOC": u32 1, u32 colour space (1 sRGB, 2 Gray Gamma 2.2, 3 Display P3, 4 extended sRGB, 6 extended gray), u32 n, n doubles
  GGRA "ARGG": u32 stops, u32 type (1 linear, 0 = one colour, Icon Composer "automatic gradient"), u32 0,
      f32 x0 y0 x1 y1 (unit square), then per stop f32 location, u32 len, colour name[len]

flat() renders the FLAT composite: no Liquid Glass. groups() hands the stack to icr.py (IconRendering's composition:
shadows, translucency, highlights, the style modes), one image per group as IconRendering bakes them.
Against Apple's own pre-rendered Default bitmaps the flat render of the Aqua stack is rms 2-15 (512 px).

  iconstack.py <Assets.car> <icon name> <dark|light|tintable>     # prints the decoded tree
"""
import io, os, struct, subprocess, sys
import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import car as C
import dmp2

APPEARANCE = {"dark": ("NSAppearanceNameDarkAqua", "UIAppearanceDark"),
              "light": ("NSAppearanceNameAqua", "UIAppearanceLight"),
              "tintable": ("ISAppearanceTintable",)}
# Icon Composer's "automatic gradient" from one colour. groups() (what icr.py composes) builds it as
# IconRendering does: auto_gradient(). flat() keeps the older FITTED lightening of the start point (0.3, best fit
# to Apps' pre-rendered bitmap) because build-styles.py's fitted Dock rule was made on that picture.
AUTO_GRADIENT = 0.3
import json
AUTO = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "icr-params.json")))["fills"]


def _enc(lin):
    a = np.abs(lin)
    return np.sign(lin) * np.where(a <= 0.0031308, a * 12.92, 1.055 * a ** (1 / 2.4) - 0.055)


def _lin(c):
    c = np.asarray(c, float); a = np.abs(c)
    return np.sign(c) * np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)


P3_TO_SRGB = np.array([[1.2249, -0.2247, 0.0], [-0.0420, 1.0419, 0.0], [-0.0197, -0.0786, 1.0979]])


def auto_gradient(rgb):
    """Icon.Fill.automaticGradient(colour) -> [(location, rgb)], IconRendering 27.2.1 0x1cfd2c2a8 with
    ICRRenderingParameters.Fills.AutomaticGradient: Y = BT.709 luma of the components; the lightening is picked by
    Y (<= 0.25 dim, <= 0.5 midDim, <= 0.75 midBright, else bright); c' = c + saturationBoost (c - Y); the second
    colour is c' + l (1 - c') for l >= 0, c' + l c' for l < 0, clamped to 0..1. l > 0: that colour at location 0
    and the given one at 1 - basePosition; l <= 0: the given one at basePosition and the changed one at 1."""
    a = AUTO["automaticGradient"]; c = np.asarray(rgb, float)
    y = float(c @ [0.2126, 0.7152, 0.0722])
    l = a["dimLightening"] if y <= 0.25 else a["midDimLightening"] if y <= 0.5 else \
        a["midBrightLightening"] if y <= 0.75 else a["brightLightening"]
    m = c + a["saturationBoost"] * (c - y)
    m = np.clip(m + l * (1 - m) if l >= 0 else m + l * m, 0, 1)
    return [(0.0, m), (1.0 - a["basePosition"], c)] if l > 0 else [(a["basePosition"], c), (1.0, m)]


class Stack:
    def __init__(self, path, extended=False):
        self.extended = extended      # keep Display P3 fills unclipped (extended sRGB), for icr.py
        # IconRendering hands every IconColor to RenderBox as Display P3 (RBColorSpace 3). The Mac's Spotlight tile
        # only fits when the car's sRGB-tagged components are used as they are, as P3 (Dark magnifier red 0, rms
        # 11.5 -> 8.8; Default 28.2 -> 14.2): measured, the loader itself was not read
        self.p3 = extended
        self.path = path
        c = self.car = C.Car(path)
        kf = c.blk(c.vars["KEYFORMAT"]); n = struct.unpack_from("<I", kf, 8)[0]
        self.toks = list(struct.unpack_from("<%dI" % n, kf, 12))
        self.names = {}
        for k, v in c.tree("FACETKEYS"):
            na = struct.unpack_from("<H", v, 4)[0]
            at = dict(struct.unpack_from("<HH", v, 6 + 4 * j) for j in range(na))
            self.names[at.get(17)] = k.decode()
        self.appearances = {k.decode(): struct.unpack_from("<H", v)[0] for k, v in c.tree("APPEARANCEKEYS")} \
            if "APPEARANCEKEYS" in c.vars else {}
        self.byid, self.byname = {}, {}
        for k, v in c.tree("RENDITIONS"):
            if v[:4] != b"ISTC": continue
            at = dict(zip(self.toks, struct.unpack_from("<%dH" % (len(k) // 2), k)))
            self.byid.setdefault((at.get(2), at.get(17)), []).append((at, v))
            self.byname.setdefault(self.names.get(at.get(17)), []).append((at, v))

    def appearance_id(self, which):
        for name in APPEARANCE[which]:
            if name in self.appearances: return self.appearances[name]
        return None

    @staticmethod
    def pick(lst, app):
        """the rendition for appearance id `app`, else the appearance-less one"""
        fallback = None
        for at, v in lst:
            a = at.get(7, 0)
            if at.get(24): continue          # the wide-gamut (RGBW) twin of a bitmap
            if a == app: return at, v
            if a == 0 and fallback is None: fallback = (at, v)
        return fallback

    @staticmethod
    def tlvs(v):
        tlvlen, bmc = struct.unpack_from("<II", v, 168)
        p = 180 + bmc * 4; end = p + tlvlen; out = {}
        while p < end:
            t, l = struct.unpack_from("<II", v, p); out[t] = v[p + 8:p + 8 + l]; p += 8 + l
        return out

    @staticmethod
    def glass(t, n):
        """the n children's glass settings from a stack's or group's TLVs (0x3fd, 0x3fe), None where absent"""
        out = [None] * n
        d = t.get(0x3fd)
        for i in range(min(n, struct.unpack_from("<I", d, 0)[0]) if d else 0):
            sp, tr, style, sop, place = struct.unpack_from("<IfIfI", d, 8 + 20 * i)
            out[i] = dict(specular=bool(sp & 1), translucency=tr, shadowStyle=style, shadowOpacity=sop, specularPlacement=place)
        e = t.get(0x3fe)
        for i in range(min(n, struct.unpack_from("<I", e, 0)[0]) if e else 0):
            st, h = struct.unpack_from("<ff", e, 8 + 12 * i)
            out[i] = dict(out[i] or {}, refractionStrength=st, refractionHeight=h)
        return out

    @staticmethod
    def children(d):
        cnt = struct.unpack_from("<I", d, 0)[0]; o = 8; out = []
        for _ in range(cnt):
            _a, x, y, w, h, bm, op, kl = struct.unpack_from("<IiiiiIfI", d, o); o += 32
            key = dict(struct.unpack_from("<HH", d, o + 4 * j) for j in range(kl // 4)); o += kl
            key.pop(0, None)
            out.append(dict(rect=(x, y, w, h), opacity=op, blend=bm, key=key))
        return out

    @staticmethod
    def fills(d):
        cnt = struct.unpack_from("<I", d, 0)[0]; o = 8; out = []
        for _ in range(cnt):
            _a, _b, ln = struct.unpack_from("<III", d, o)
            out.append(d[o + 12:o + 12 + ln].rstrip(b"\0").decode() or None); o += 12 + ln
        return out

    def colour(self, cs, rgb, a=1.0):
        """components in the car's colour space -> straight (extended) sRGB RGBA"""
        rgb = np.asarray(rgb, float)
        if cs == 2: rgb = _enc(np.clip(rgb, 0, None) ** 2.2)          # Gray Gamma 2.2
        elif cs == 3 or (cs == 1 and self.extended and self.p3): rgb = _enc(P3_TO_SRGB @ _lin(rgb))   # Display P3
        # extended sRGB: a Display P3 colour outside sRGB keeps its negative component, as in IconRendering's
        # extended-range working space (the composite is clipped once, at the end)
        return np.append(rgb if self.extended else np.clip(rgb, 0, 1), min(max(a, 0.0), 1.0))

    def fill(self, name, app, raw=False):
        """COLR -> straight sRGB RGBA array (raw: (colour space, rgb, alpha) as stored), GGRA -> gradient dict,
        None when missing"""
        r = self.pick(self.byname.get(name, []), app)
        if not r: return None
        pl = C.parse_csi(r[1])["payload"]
        if pl[:4] == b"ARGG": return self.gradient(pl, app)
        cs, nc = struct.unpack_from("<II", pl, 8)
        comps = struct.unpack_from("<%dd" % nc, pl, 16)
        if nc <= 2: rgb, a = np.array([comps[0]] * 3), (comps[1] if nc == 2 else 1.0)
        else: rgb, a = np.array(comps[:3]), (comps[3] if nc > 3 else 1.0)
        return (cs, rgb, a) if raw else self.colour(cs, rgb, a)

    def gradient(self, pl, app):
        nst, typ = struct.unpack_from("<II", pl, 4)
        x0, y0, x1, y1 = struct.unpack_from("<ffff", pl, 16); o = 32; stops = []; auto = None
        for _ in range(nst):
            loc, ln = struct.unpack_from("<fI", pl, o)
            nm = pl[o + 8:o + 8 + ln].rstrip(b"\0").decode()
            stops.append((loc, self.fill(nm, app))); o += 8 + ln
            if typ == 0 and auto is None:                             # automatic gradient: IconRendering's two stops
                raw = self.fill(nm, app, raw=True)
                if isinstance(raw, tuple):
                    auto = [(l, self.colour(raw[0], c, raw[2])) for l, c in auto_gradient(raw[1])]
        return dict(type=typ, p0=(x0, y0), p1=(x1, y1), stops=stops, auto=auto)

    def svg(self, v):
        pl = C.parse_csi(v)["payload"]
        _flag, ln = struct.unpack_from("<II", pl, 4); data = pl[12:12 + ln]
        return C.lzfse(data, 1 << 20) if data[:3] == b"bvx" else data

    @staticmethod
    def bitmap(csi):
        """bitmap layer (deepmap2, ARGB or gray+alpha, premultiplied) -> HxWx4 premultiplied float"""
        if csi["tag"] != "CELM" or csi["comp"] != 11: raise ValueError(f"compression {csi['comp']}")
        a = dmp2.decode(csi["payload"][16:]).astype(np.float32) / 255
        if a.shape[2] == 2: a = np.dstack([a[..., 0]] * 3 + [a[..., 1]])
        return a

    def has_stack(self, stem):
        return any(struct.unpack_from("<H", v, 36)[0] == 1019 for _, v in self.byname.get(stem, []))

    def tree(self, stem, which):
        app = self.appearance_id(which)
        top = self.pick([x for x in self.byname.get(stem, []) if struct.unpack_from("<H", x[1], 36)[0] == 1019], app)
        if top is None: return None
        out = []
        tt = self.tlvs(top[1])
        kids = self.children(tt[0x3f4])
        for ch, gl in zip(kids, self.glass(tt, len(kids))):
            part, fid = ch["key"].get(2), ch["key"].get(17)
            r = self.pick(self.byid.get((part, fid), []), app)
            node = dict(ch, name=self.names.get(fid), part=part, glass=gl)
            if r is None: continue
            if part in (247, 217):
                node["fill"] = self.fill(node["name"], app)
            elif part == 246:
                gt = self.tlvs(r[1])
                layers = self.children(gt[0x3f4])
                fl = self.fills(gt[0x3fc]) if 0x3fc in gt else [None] * len(layers)
                node["layers"] = []
                for L, F, G in zip(layers, fl, self.glass(gt, len(layers))):
                    L["glass"] = G
                    lr = self.pick(self.byid.get((L["key"].get(2), L["key"].get(17)), []), app)
                    if lr is None: continue
                    csi = C.parse_csi(lr[1])
                    L.update(name=self.names.get(L["key"].get(17)), fill=self.fill(F, app) if F else None, fillname=F,
                             svg=None, bitmap=None)
                    if csi["pix"] == "SVG ": L["svg"] = self.svg(lr[1])
                    else:
                        try: L["bitmap"] = self.bitmap(csi)
                        except (ValueError, KeyError) as e:
                            print(f"skip layer {L['name']}: {e}", file=sys.stderr); continue
                    node["layers"].append(L)
            out.append(node)
        return out


def render_svg(svg, rect, N):
    """SVG layer placed at rect (1024 canvas units) -> NxN premultiplied float RGBA"""
    s = N / 1024.0
    x, y, w, h = rect if rect[2] else (0, 0, 1024, 1024)
    W, H = max(1, round(w * s)), max(1, round(h * s))
    png = subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), "--keep-aspect-ratio"], input=svg,
                         capture_output=True, check=True).stdout
    im = np.asarray(Image.open(io.BytesIO(png)).convert("RGBA")).astype(np.float32) / 255
    im[..., :3] *= im[..., 3:4]
    out = np.zeros((N, N, 4), np.float32)
    X, Y = round(x * s), round(y * s)
    sx, sy, dx, dy = max(0, -X), max(0, -Y), max(0, X), max(0, Y)
    ww, hh = min(im.shape[1] - sx, N - dx), min(im.shape[0] - sy, N - dy)
    if ww > 0 and hh > 0: out[dy:dy + hh, dx:dx + ww] = im[sy:sy + hh, sx:sx + ww]
    return out


def render_bitmap(bm, rect, N):
    """bitmap layer placed at rect (1024 canvas units) -> NxN premultiplied float RGBA"""
    s = N / 1024.0
    x, y, w, h = rect if rect[2] else (0, 0, 1024, 1024)
    W, H = max(1, round(w * s)), max(1, round(h * s))
    im = Image.fromarray((bm * 255).round().astype("uint8"), "RGBa").resize((W, H), Image.LANCZOS)
    im = np.asarray(im).astype(np.float32) / 255
    out = np.zeros((N, N, 4), np.float32)
    X, Y = round(x * s), round(y * s)
    sx, sy, dx, dy = max(0, -X), max(0, -Y), max(0, X), max(0, Y)
    ww, hh = min(im.shape[1] - sx, N - dx), min(im.shape[0] - sy, N - dy)
    if ww > 0 and hh > 0: out[dy:dy + hh, dx:dx + ww] = im[sy:sy + hh, sx:sx + ww]
    return out


def render_fill(f, N, rect=None, auto=False):
    """colour or gradient -> NxN premultiplied. rect (x0, y0, x1, y1 px) is the gradient's unit square (None: the
    canvas); auto: the automatic gradient as IconRendering builds it (else flat()'s fitted lightening)"""
    out = np.zeros((N, N, 4), np.float32)
    if not isinstance(f, dict):
        out[...] = np.append(f[:3] * f[3], f[3]); return out
    rx0, ry0, rx1, ry1 = rect or (0, 0, N, N)
    yy, xx = np.mgrid[0:N, 0:N].astype(np.float32) + 0.5
    xx = (xx - rx0) / max(rx1 - rx0, 1e-6); yy = (yy - ry0) / max(ry1 - ry0, 1e-6)
    (x0, y0), (x1, y1) = f["p0"], f["p1"]
    # the vector between the points in px, so a slanted gradient keeps its angle in a non-square rect
    dx, dy = (x1 - x0) * (rx1 - rx0), (y1 - y0) * (ry1 - ry0)
    t = np.clip(((xx - x0) * (rx1 - rx0) * dx + (yy - y0) * (ry1 - ry0) * dy) / max(dx * dx + dy * dy, 1e-9), 0, 1)
    stops = [(l, c) for l, c in f["stops"] if c is not None and not isinstance(c, dict)]
    if auto and f.get("auto"): stops = f["auto"]
    locs = [l for l, _ in stops]; cols = np.array([c for _, c in stops])
    if len(stops) == 1:
        top = cols[0].copy(); top[:3] += (1 - top[:3]) * AUTO_GRADIENT
        locs, cols = [0.0, 1.0], np.array([top, cols[0]])
    cols = cols.copy(); cols[:, :3] *= cols[:, 3:4]      # stops are interpolated premultiplied (a clear stop has no hue)
    for ch in range(4): out[..., ch] = np.interp(t, locs, cols[:, ch])
    return out


def comp(dst, src, mode="normal"):
    """premultiplied RGBA src onto premultiplied RGBA dst with a blend mode (a layer inside its group: IconRendering
    draws each layer with drawShape:fill:alpha:blendMode:, 0x1cfd42e9c)"""
    if mode == "normal": return src + dst * (1 - src[..., 3:4])
    if mode == "plusLighter": return np.minimum(dst + src, 1)
    sa, da = src[..., 3:4], dst[..., 3:4]
    cs = src[..., :3] / np.maximum(sa, 1e-6); cb = dst[..., :3] / np.maximum(da, 1e-6)
    if mode == "plusDarker": b = np.maximum(cb + cs - 1, 0)
    elif mode == "multiply": b = cb * cs
    elif mode == "screen": b = cb + cs - cb * cs
    elif mode == "overlay": b = np.where(cb <= 0.5, 2 * cb * cs, 1 - 2 * (1 - cb) * (1 - cs))
    elif mode == "darken": b = np.minimum(cb, cs)
    elif mode == "lighten": b = np.maximum(cb, cs)
    elif mode == "colorDodge": b = np.minimum(1, cb / np.maximum(1 - cs, 1e-6))
    elif mode == "colorBurn": b = 1 - np.minimum(1, (1 - cb) / np.maximum(cs, 1e-6))
    elif mode == "softLight": b = (1 - 2 * cs) * cb * cb + 2 * cs * cb
    elif mode == "hardLight": b = np.where(cs <= 0.5, 2 * cb * cs, 1 - 2 * (1 - cb) * (1 - cs))
    elif mode == "difference": b = np.abs(cb - cs)
    elif mode == "exclusion": b = cb + cs - 2 * cb * cs
    else: b = cs                                                    # hue / saturation / color / luminosity: not ported
    rgb = src[..., :3] * (1 - da) + dst[..., :3] * (1 - sa) + sa * da * b
    return np.concatenate([rgb, sa + da - sa * da], -1)


def over(dst, src, op=1.0):
    src = src * op
    return src + dst * (1 - src[..., 3:4])


# CGBlendMode (the car's u32) -> IconRendering's Icon.BlendMode name
BLEND = {0: "normal", 1: "multiply", 2: "screen", 3: "overlay", 4: "darken", 5: "lighten", 6: "colorDodge", 7: "colorBurn",
         8: "softLight", 9: "hardLight", 10: "difference", 11: "exclusion", 12: "hue", 13: "saturation", 14: "color",
         15: "luminosity", 26: "plusDarker", 27: "plusLighter"}


def layer_fill(L, l, N):
    """a layer's fill as IconRendering lays it out (0x1cfd42e9c): the layer is the clip, the fill a rect. A
    gradient's unit square is the bounding rect of what the layer draws; Icon.Fill.system is IconRendering's own
    gradient (ICRRenderingParameters.Fills), top to bottom (GradientPlacement.default 0,0 -> 0,1) over the whole
    canvas (supportsChicletAlignmentForSystemFills). The bounding rect is taken from the rendered alpha here."""
    f = L["fill"]
    if not isinstance(f, dict): return render_fill(f, N)
    sysname = (L.get("fillname") or "").rsplit("/", 1)[-1]
    if sysname in ("system-light", "system-dark"):
        st = AUTO["systemDarkGradient" if sysname == "system-dark" else "systemLightGradient"]
        return render_fill(dict(p0=(0.0, 0.0), p1=(0.0, 1.0), stops=[(x["location"], np.array(x["color"])) for x in st]), N)
    a = l[..., 3] > 1 / 255
    ys = np.nonzero(a.any(1))[0]; xs = np.nonzero(a.any(0))[0]
    rect = (xs[0], ys[0], xs[-1] + 1, ys[-1] + 1) if len(ys) else None
    return render_fill(f, N, rect, auto=True)


def groups(tree, N):
    """the stack as IconRendering sees it: (background fill or None, [group]) with one premultiplied N x N image
    per Icon Composer group (IconRendering bakes a group into one image, FinalizedIcon.Layer) and its glass record"""
    fill, out = None, []
    for ch in tree:
        if "layers" not in ch:
            if ch.get("fill") is not None: fill = ch["fill"]
            # Icon.Fill.system: the car's own copy of these two gradients is not what IconRendering draws
            # (ICRRenderingParameters.Fills.systemLightGradient / systemDarkGradient)
            if (ch.get("name") or "").endswith(("/system-light", "/system-dark")): fill = ch["name"].rsplit("/", 1)[1]
            continue
        g = np.zeros((N, N, 4), np.float32); shape = np.zeros((N, N), np.float32)
        for L in ch["layers"]:
            l = render_svg(L["svg"], L["rect"], N) if L["svg"] is not None else render_bitmap(L["bitmap"], L["rect"], N)
            # the group's shape for the SDF: IconRendering draws the layers again in one solid colour at alpha 1
            # (0x1cfd45064 -> 0x1cfd42e9c with its mask flag), so a fill's or the layer's own opacity is not in it
            shape = shape + l[..., 3] * (1 - shape)
            if L["fill"] is not None: l = layer_fill(L, l, N) * l[..., 3:4]
            g = comp(g, l * L["opacity"], BLEND.get(L.get("blend", 0), "normal"))
        gl = ch.get("glass") or {}
        out.append(dict(img=g, shape=shape, opacity=ch["opacity"], blend=BLEND.get(ch.get("blend", 0), "normal"), name=ch["name"],
                        specular=gl.get("specular", False), translucency=gl.get("translucency", 0.0),
                        shadowStyle=gl.get("shadowStyle", 0), shadowOpacity=gl.get("shadowOpacity", 0.0),
                        specularPlacement=gl.get("specularPlacement", 0)))
    return fill, out


def fill_stops(f):
    """a background fill -> [(location, straight rgb)] for IconRendering's chiclet gradient (drawn over 10 % .. 90 %
    of the height whatever the fill's own points, 0x1cfd72690)"""
    if f is None: return None
    if isinstance(f, str): return f                              # "system-light" / "system-dark": IconRendering's own
    if not isinstance(f, dict): return [(0.0, f[:3]), (1.0, f[:3])]
    if f.get("auto"): return sorted([(l, c[:3]) for l, c in f["auto"]], key=lambda s: s[0])
    stops = [(l, c[:3]) for l, c in f["stops"] if c is not None and not isinstance(c, dict)]
    return sorted(stops, key=lambda s: s[0])


def flat(tree, N=1024, layers_only=False):
    """composite of the 1024 canvas at NxN, premultiplied; layers_only drops the background fill"""
    img = np.zeros((N, N, 4), np.float32)
    for ch in tree:
        if "layers" not in ch:
            if not layers_only and ch.get("fill") is not None: img = over(img, render_fill(ch["fill"], N), ch["opacity"])
            continue
        g = np.zeros((N, N, 4), np.float32)
        for L in ch["layers"]:
            l = render_svg(L["svg"], L["rect"], N) if L["svg"] is not None else render_bitmap(L["bitmap"], L["rect"], N)
            if L["fill"] is not None: l = render_fill(L["fill"], N) * l[..., 3:4]
            g = over(g, l, L["opacity"])
        img = over(img, g, ch["opacity"])
    return img


if __name__ == "__main__":
    s = Stack(sys.argv[1])
    for ch in s.tree(sys.argv[2], sys.argv[3]) or []:
        fmt = lambda g: "" if not g else " ".join(f"{k}={round(v, 3) if isinstance(v, float) else v}" for k, v in g.items())
        print(ch["name"], ch["rect"], round(ch["opacity"], 3), "fill" if "fill" in ch else "", fmt(ch.get("glass")))
        for L in ch.get("layers", []):
            f = L["fill"]
            print("   ", L["name"], L["rect"], round(L["opacity"], 3), "gradient" if isinstance(f, dict) else f, fmt(L.get("glass")))
