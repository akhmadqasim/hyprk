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
      u32 ?, i32 x, i32 y, i32 w, i32 h (1024 canvas units; 0,0,0,0 = whole canvas), u32 ?, f32 opacity,
      u32 keylen, keylen bytes of (u16 attribute, u16 value) rendition-key pairs (1 element, 2 part, 17 name id)
  CSI TLV 0x3fc fills: u32 count, u32 0, then per child u32 ?, u32 ?, u32 len, name[len] (COLR or GGRA name, "" = own colours)
  CSI TLV 0x3fd / 0x3fe: per-child glass parameters (shadow, translucency, specular): reference/ASSETS.md, not used
  COLR "RLOC": u32 1, u32 colour space (1 sRGB, 2 Gray Gamma 2.2, 3 Display P3, 4 extended sRGB, 6 extended gray), u32 n, n doubles
  GGRA "ARGG": u32 stops, u32 type (1 linear, 0 = one colour, Icon Composer "automatic gradient"), u32 0,
      f32 x0 y0 x1 y1 (unit square), then per stop f32 location, u32 len, colour name[len]

What this renders is the FLAT composite: no Liquid Glass (layer shadows, translucency; build-styles.py adds the
chiclet's specular edge with glass.py).
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
# Icon Composer's "automatic gradient" from one colour: lighter at the start point. The amount is not in
# the car (IconRendering computes it); 0.3 is the best fit to Apps' pre-rendered bitmap (rms 15.7 -> 14.1).
AUTO_GRADIENT = 0.3


def _enc(lin):
    return np.where(lin <= 0.0031308, lin * 12.92, 1.055 * np.abs(lin) ** (1 / 2.4) * np.sign(lin) - 0.055)


def _lin(c):
    c = np.asarray(c, float)
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


P3_TO_SRGB = np.array([[1.2249, -0.2247, 0.0], [-0.0420, 1.0419, 0.0], [-0.0197, -0.0786, 1.0979]])


class Stack:
    def __init__(self, path):
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
    def children(d):
        cnt = struct.unpack_from("<I", d, 0)[0]; o = 8; out = []
        for _ in range(cnt):
            _a, x, y, w, h, _c, op, kl = struct.unpack_from("<IiiiiIfI", d, o); o += 32
            key = dict(struct.unpack_from("<HH", d, o + 4 * j) for j in range(kl // 4)); o += kl
            key.pop(0, None)
            out.append(dict(rect=(x, y, w, h), opacity=op, key=key))
        return out

    @staticmethod
    def fills(d):
        cnt = struct.unpack_from("<I", d, 0)[0]; o = 8; out = []
        for _ in range(cnt):
            _a, _b, ln = struct.unpack_from("<III", d, o)
            out.append(d[o + 12:o + 12 + ln].rstrip(b"\0").decode() or None); o += 12 + ln
        return out

    def fill(self, name, app):
        """COLR -> straight sRGB RGBA array, GGRA -> gradient dict, None when missing"""
        r = self.pick(self.byname.get(name, []), app)
        if not r: return None
        pl = C.parse_csi(r[1])["payload"]
        if pl[:4] == b"ARGG": return self.gradient(pl, app)
        cs, nc = struct.unpack_from("<II", pl, 8)
        comps = struct.unpack_from("<%dd" % nc, pl, 16)
        if nc <= 2: rgb, a = np.array([comps[0]] * 3), (comps[1] if nc == 2 else 1.0)
        else: rgb, a = np.array(comps[:3]), (comps[3] if nc > 3 else 1.0)
        if cs == 2: rgb = _enc(np.clip(rgb, 0, None) ** 2.2)          # Gray Gamma 2.2
        elif cs == 3: rgb = _enc(P3_TO_SRGB @ _lin(rgb))              # Display P3
        return np.clip(np.append(rgb, a), 0, 1)

    def gradient(self, pl, app):
        nst, typ = struct.unpack_from("<II", pl, 4)
        x0, y0, x1, y1 = struct.unpack_from("<ffff", pl, 16); o = 32; stops = []
        for _ in range(nst):
            loc, ln = struct.unpack_from("<fI", pl, o)
            stops.append((loc, self.fill(pl[o + 8:o + 8 + ln].rstrip(b"\0").decode(), app))); o += 8 + ln
        return dict(type=typ, p0=(x0, y0), p1=(x1, y1), stops=stops)

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
        for ch in self.children(self.tlvs(top[1])[0x3f4]):
            part, fid = ch["key"].get(2), ch["key"].get(17)
            r = self.pick(self.byid.get((part, fid), []), app)
            node = dict(ch, name=self.names.get(fid), part=part)
            if r is None: continue
            if part in (247, 217):
                node["fill"] = self.fill(node["name"], app)
            elif part == 246:
                gt = self.tlvs(r[1])
                layers = self.children(gt[0x3f4])
                fl = self.fills(gt[0x3fc]) if 0x3fc in gt else [None] * len(layers)
                node["layers"] = []
                for L, F in zip(layers, fl):
                    lr = self.pick(self.byid.get((L["key"].get(2), L["key"].get(17)), []), app)
                    if lr is None: continue
                    csi = C.parse_csi(lr[1])
                    L.update(name=self.names.get(L["key"].get(17)), fill=self.fill(F, app) if F else None, svg=None, bitmap=None)
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


def render_fill(f, N):
    """colour or gradient over the whole canvas -> NxN premultiplied"""
    out = np.zeros((N, N, 4), np.float32)
    if not isinstance(f, dict):
        out[...] = np.append(f[:3] * f[3], f[3]); return out
    yy, xx = (np.mgrid[0:N, 0:N].astype(np.float32) + 0.5) / N
    (x0, y0), (x1, y1) = f["p0"], f["p1"]
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((xx - x0) * dx + (yy - y0) * dy) / max(dx * dx + dy * dy, 1e-9), 0, 1)
    stops = [(l, c) for l, c in f["stops"] if c is not None and not isinstance(c, dict)]
    locs = [l for l, _ in stops]; cols = np.array([c for _, c in stops])
    if len(stops) == 1:
        top = cols[0].copy(); top[:3] += (1 - top[:3]) * AUTO_GRADIENT
        locs, cols = [0.0, 1.0], np.array([top, cols[0]])
    for ch in range(4): out[..., ch] = np.interp(t, locs, cols[:, ch])
    out[..., :3] *= out[..., 3:4]
    return out


def over(dst, src, op=1.0):
    src = src * op
    return src + dst * (1 - src[..., 3:4])


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
        print(ch["name"], ch["rect"], round(ch["opacity"], 3), "fill" if "fill" in ch else "")
        for L in ch.get("layers", []):
            f = L["fill"]
            print("   ", L["name"], L["rect"], round(L["opacity"], 3), "gradient" if isinstance(f, dict) else f)
