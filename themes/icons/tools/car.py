#!/usr/bin/env python3 -I
"""Minimal reader for Apple compiled asset catalogs (Assets.car), bitmap renditions only.

BOM store -> RENDITIONS tree -> CSI blocks. Decodes the compressions macOS 27 uses for icons:
0 raw, 2 gzip, 4 lzfse (both plain and as KCBC chunks). liblzfse is loaded with ctypes.
Written for reference/ASSETS.md (own IPSW, local theming). No Linux tool for .car existed.

  car.py list <Assets.car> [name-substring]
  car.py dump <Assets.car> <outdir> [name-substring]     # PNGs: <facet>__<w>x<h>@<scale>x_<n>.png
  car.py best <Assets.car> <out.png> <name-substring>    # biggest square ARGB rendition of a facet
  car.py bvg <CoreGlyphs Assets.car> <outdir> <symbol,symbol,...>   # raw SF Symbols vector blobs
"""
import ctypes, gzip, os, struct, sys
from PIL import Image

_lz = ctypes.CDLL("liblzfse.so.1")
_lz.lzfse_decode_buffer.restype = ctypes.c_size_t
_lz.lzfse_decode_buffer.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_void_p]


def lzfse(data, hint):
    cap = max(hint, 1 << 16)
    while cap < (1 << 31):
        buf = ctypes.create_string_buffer(cap)
        n = _lz.lzfse_decode_buffer(buf, cap, data, len(data), None)
        if 0 < n < cap:
            return buf.raw[:n]
        cap *= 2
    raise ValueError("lzfse failed")


class Car:
    def __init__(self, path):
        d = self.d = open(path, "rb").read()
        assert d[:8] == b"BOMStore", "not a BOM store"
        _, idxoff, idxlen, varoff, varlen = struct.unpack_from(">IIIII", d, 12)
        cnt = struct.unpack_from(">I", d, idxoff)[0]
        self.blocks = [struct.unpack_from(">II", d, idxoff + 4 + 8 * i) for i in range(cnt)]
        nv = struct.unpack_from(">I", d, varoff)[0]
        self.vars = {}
        p = varoff + 4
        for _ in range(nv):
            bi, ln = struct.unpack_from(">IB", d, p); p += 5
            self.vars[d[p:p + ln].decode()] = bi; p += ln

    def blk(self, i):
        o, n = self.blocks[i]
        return self.d[o:o + n]

    def tree(self, name):
        t = self.blk(self.vars[name])
        child = struct.unpack_from(">I", t, 8)[0]
        i = child
        b = self.blk(i)
        while not struct.unpack_from(">H", b, 0)[0]:
            i = struct.unpack_from(">I", b, 12)[0]; b = self.blk(i)
        out = []
        while True:
            leaf, n, fwd, back = struct.unpack_from(">HHII", b, 0)
            for k in range(n):
                v, key = struct.unpack_from(">II", b, 12 + 8 * k)
                out.append((self.blk(key), self.blk(v)))
            if not fwd: break
            b = self.blk(fwd)
        return out

    def renditions(self):
        kf = self.blk(self.vars["KEYFORMAT"])
        n = struct.unpack_from("<I", kf, 8)[0]
        tokens = list(struct.unpack_from("<%dI" % n, kf, 12))
        names = {}
        for k, v in self.tree("FACETKEYS"):
            na = struct.unpack_from("<H", v, 4)[0]
            attrs = dict(struct.unpack_from("<HH", v, 6 + 4 * j) for j in range(na))
            names[attrs.get(17)] = k.decode("latin1")
        for k, v in self.tree("RENDITIONS"):
            vals = struct.unpack_from("<%dH" % (len(k) // 2), k)
            attrs = dict(zip(tokens, vals))
            if v[:4] != b"ISTC": continue
            yield names.get(attrs.get(17), "?"), attrs, parse_csi(v)


def parse_csi(v):
    flags = struct.unpack_from("<I", v, 8)[0]
    w, h, scale = struct.unpack_from("<III", v, 12)
    pix = v[24:28][::-1].decode("latin1")
    layout = struct.unpack_from("<H", v, 36)[0]
    name = v[40:168].split(b"\0")[0].decode("latin1")
    tlvlen, bmc = struct.unpack_from("<I", v, 168)[0], struct.unpack_from("<I", v, 172)[0]
    ps = 180 + bmc * 4 + tlvlen   # fixed header is 180 bytes, then bmc u32 lengths, then TLVs
    payload = v[ps:]
    tag = payload[:4][::-1].decode("latin1")
    comp = struct.unpack_from("<I", payload, 8)[0] if tag == "CELM" and len(payload) >= 16 else None
    return dict(w=w, h=h, scale=scale, pix=pix, layout=layout, name=name, tag=tag, comp=comp,
                payload=payload, flags=flags)


def decode(r):
    """-> PIL RGBA image or None when the compression is not supported."""
    if r["tag"] != "CELM": return None
    w, h, pix, comp = r["w"], r["h"], r["pix"], r["comp"]
    bpp = {"ARGB": 4, "GA8 ": 2}.get(pix)
    if bpp is None: return None
    data = r["payload"][16:]
    if comp not in (0, 2, 4): return None

    def chunks(dec):
        out = bytearray(); off = 0; rows = 0
        while rows < h:
            assert data[off:off + 4] == b"KCBC"
            ch, clen = struct.unpack_from("<II", data, off + 12)
            raw = dec(data[off + 20:off + 20 + clen], ch)
            sr = len(raw) // ch
            for y in range(ch): out += raw[y * sr:y * sr + w * bpp]
            rows += ch; off += 20 + clen
        return bytes(out)

    if comp == 0: px = data
    elif data[:4] == b"KCBC":
        px = chunks((lambda b, ch: lzfse(b, w * bpp * ch * 2)) if comp == 4 else (lambda b, ch: gzip.decompress(b)))
    else:
        px = lzfse(data, w * h * bpp * 2) if comp == 4 else gzip.decompress(data)
    if len(px) != w * h * bpp:
        sr = len(px) // h
        px = b"".join(px[y * sr:y * sr + w * bpp] for y in range(h))
    if bpp == 4:
        im = Image.frombuffer("RGBA", (w, h), px, "raw", "BGRA", 0, 1)
        # CoreUI stores premultiplied alpha
        a = im.getchannel("A")
        import numpy as np
        arr = np.asarray(im).astype("float32")
        al = arr[..., 3:4] / 255.0
        arr[..., :3] = (arr[..., :3] / (al + (al == 0))).clip(0, 255)
        return Image.fromarray(arr.round().astype("uint8"), "RGBA")
    return Image.frombuffer("LA", (w, h), px, "raw", "LA", 0, 1).convert("RGBA")


def main(argv):
    cmd, path = argv[1], argv[2]
    car = Car(path)
    if cmd == "list":
        pat = argv[3] if len(argv) > 3 else ""
        for fname, attrs, r in car.renditions():
            if pat in fname or pat in r["name"]:
                print(f'{fname}\t{r["name"]}\t{r["w"]}x{r["h"]}@{r["scale"]}x\t{r["pix"]}\tlayout={r["layout"]}\t{r["tag"]}/{r["comp"]}')
    elif cmd == "dump":
        out, pat = argv[3], argv[4] if len(argv) > 4 else ""
        os.makedirs(out, exist_ok=True)
        for n, (fname, attrs, r) in enumerate(car.renditions()):
            if pat in fname or pat in r["name"]:
                im = decode(r)
                if im: im.save(f'{out}/{fname}__{r["w"]}x{r["h"]}@{r["scale"]}x_{n}.png')
    elif cmd == "bvg":
        # CoreGlyphs.bundle: facet name = SF Symbol name; layout 1022 renditions are "DWAR" blobs that
        # hold a "BVG " vector (Apple's binary vector format, not decoded here). One blob per weight
        # master (rendition key attribute 26: 1, 4, 9 = ultralight/regular/black masters, apparently).
        out, names = argv[3], set(argv[4].split(","))
        os.makedirs(out, exist_ok=True)
        for fname, attrs, r in car.renditions():
            if fname in names and r["layout"] == 1022 and r["payload"][:4] == b"DWAR" and r["payload"][12:16] == b"BVG ":
                open(f'{out}/{fname}.w{attrs.get(26)}.bvg', "wb").write(r["payload"][12:])
    elif cmd == "best":
        out, pat = argv[3], argv[4]
        best = None
        for fname, attrs, r in car.renditions():
            if (pat in fname or pat in r["name"]) and r["w"] == r["h"] and r["tag"] == "CELM" and r["pix"] == "ARGB":
                if best is None or r["w"] > best["w"]: best = r
        if not best: sys.exit("none")
        im = decode(best)
        if not im: sys.exit("unsupported compression %s" % best["comp"])
        im.save(out); print(best["name"], im.size)


if __name__ == "__main__":
    main(sys.argv)
